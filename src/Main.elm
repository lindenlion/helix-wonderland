module Main exposing (main)

{-| The game shell: settings, screens, and routing between chapters.

This is the one place where chapters meet the outside world. A chapter asks
for things through `Chapter.Contract.Effect`; `applyEffect` below carries
them out (sound, toasts, saving progress). Adding a chapter means adding a
case to `Chapter` and to the three functions under CHAPTERS; the compiler
points at each one.

-}

import Browser
import Browser.Events
import Chapter.Contract as Contract exposing (Context, Effect(..), Score)
import Chapter.Hall as Hall
import Chapter.Id as ChapterId exposing (ChapterId(..))
import Html exposing (Html)
import Html.Attributes as A
import Json.Decode as Decode exposing (Decoder)
import Keyboard.Layout as Layout exposing (Layout)
import Keyboard.View
import Language exposing (Language)
import Ports
import Progress exposing (Progress)
import Settings exposing (Settings)
import Texts exposing (Texts)
import Ui.Chrome as Chrome
import Ui.Results
import Ui.Title


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { settings : Settings
    , progress : Progress
    , screen : Screen
    , selectedChapter : ChapterId
    , toast : Maybe Toast
    , flash : Maybe Flash
    }


type Screen
    = Title
    | Playing Chapter
    | Results ChapterId Score


{-| One case per chapter that has been rebuilt in Elm.
-}
type Chapter
    = HallChapter Hall.Model


type alias Toast =
    { text : Texts -> String, remaining : Float }


type alias Flash =
    { key : String, ok : Bool, remaining : Float }


toastMilliseconds : Float
toastMilliseconds =
    2800


flashMilliseconds : Float
flashMilliseconds =
    170


{-| Flags from JavaScript: the browser language and anything saved earlier.
Bad or missing data never stops the game; it falls back to defaults.
-}
init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        decodeFlag field decoder fallback =
            Decode.decodeValue (Decode.field field decoder) flags
                |> Result.withDefault fallback

        defaults =
            Settings.guess (decodeFlag "browserLanguage" Decode.string "en")
    in
    ( { settings = decodeFlag "settings" (Settings.decoder defaults) defaults
      , progress = decodeFlag "progress" Progress.decoder Progress.empty
      , screen = Title
      , selectedChapter = HallOfDoors
      , toast = Nothing
      , flash = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = KeyDown KeyPress
    | Frame Float
    | ChoseLanguage Language
    | ChoseLayout Layout
    | ToggledSound
    | OpenedMenu
    | StartedChapter ChapterId


type alias KeyPress =
    { key : String, code : String }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyDown press ->
            detectLayout press model
                |> andThen (handleKey press.key)

        Frame milliseconds ->
            { model
                | toast = countDown milliseconds model.toast
                , flash = countDown milliseconds model.flash
            }
                |> stepCurrentChapter (Tick milliseconds)

        ChoseLanguage language ->
            saveSettings (\s -> { s | language = language }) model

        ChoseLayout layout ->
            saveSettings (\s -> { s | layout = layout }) model

        ToggledSound ->
            saveSettings (\s -> { s | soundOn = not s.soundOn }) model

        OpenedMenu ->
            ( { model | screen = Title }, Cmd.none )

        StartedChapter id ->
            startChapter id model


handleKey : String -> Model -> ( Model, Cmd Msg )
handleKey key model =
    case model.screen of
        Title ->
            case key of
                "j" ->
                    ( { model | selectedChapter = shiftChapter 1 model.selectedChapter }, Cmd.none )

                "k" ->
                    ( { model | selectedChapter = shiftChapter -1 model.selectedChapter }, Cmd.none )

                "ArrowDown" ->
                    ( { model | selectedChapter = shiftChapter 1 model.selectedChapter }, Cmd.none )

                "ArrowUp" ->
                    ( { model | selectedChapter = shiftChapter -1 model.selectedChapter }, Cmd.none )

                "Enter" ->
                    startChapter model.selectedChapter model

                _ ->
                    ( model, Cmd.none )

        Playing _ ->
            stepCurrentChapter (Key key) model

        Results id _ ->
            case key of
                "Enter" ->
                    case nextPlayable id of
                        Just next ->
                            startChapter next model

                        Nothing ->
                            ( { model | screen = Title }, Cmd.none )

                "r" ->
                    startChapter id model

                "m" ->
                    ( { model | screen = Title }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


startChapter : ChapterId -> Model -> ( Model, Cmd Msg )
startChapter id model =
    case newChapter id of
        Just chapter ->
            ( { model | screen = Playing chapter, selectedChapter = id }, Cmd.none )

        Nothing ->
            ( { model | selectedChapter = id, toast = Just { text = .notPortedYet, remaining = toastMilliseconds } }, Cmd.none )


stepCurrentChapter : ChapterInput -> Model -> ( Model, Cmd Msg )
stepCurrentChapter input model =
    case model.screen of
        Playing chapter ->
            let
                ( next, effects ) =
                    stepChapter (context model) input chapter
            in
            applyEffects (chapterId chapter) effects { model | screen = Playing next }

        _ ->
            ( model, Cmd.none )


applyEffects : ChapterId -> List Effect -> Model -> ( Model, Cmd Msg )
applyEffects id effects model =
    List.foldl (\effect ( current, cmd ) -> applyEffect id effect current |> Tuple.mapSecond (\c -> Cmd.batch [ cmd, c ]))
        ( model, Cmd.none )
        effects


applyEffect : ChapterId -> Effect -> Model -> ( Model, Cmd Msg )
applyEffect id effect model =
    case effect of
        PlaySound sound ->
            ( model, playSound model (Contract.soundName sound) )

        ShowToast text ->
            ( { model | toast = Just { text = text, remaining = toastMilliseconds } }, Cmd.none )

        FlashKey key ok ->
            ( { model | flash = Just { key = key, ok = ok, remaining = flashMilliseconds } }, Cmd.none )

        Finish score ->
            let
                progress =
                    Progress.record id score.tarts model.progress
            in
            ( { model | screen = Results id score, progress = progress }
            , Cmd.batch [ Ports.saveProgress (Progress.encode progress), playSound model "fanfare" ]
            )


{-| If a key press shows the keyboard layout setting is wrong, fix it and
say so.
-}
detectLayout : KeyPress -> Model -> ( Model, Cmd Msg )
detectLayout press model =
    case Layout.detect model.settings.layout press of
        Just layout ->
            saveSettings (\s -> { s | layout = layout })
                { model | toast = Just { text = \t -> t.layoutDetected (Layout.name layout), remaining = toastMilliseconds } }

        Nothing ->
            ( model, Cmd.none )


saveSettings : (Settings -> Settings) -> Model -> ( Model, Cmd Msg )
saveSettings change model =
    let
        settings =
            change model.settings
    in
    ( { model | settings = settings }, Ports.saveSettings (Settings.encode settings) )


playSound : Model -> String -> Cmd Msg
playSound model name =
    if model.settings.soundOn then
        Ports.playSound name

    else
        Cmd.none


context : Model -> Context
context model =
    { texts = Texts.forLanguage model.settings.language
    , layout = model.settings.layout
    }


shiftChapter : Int -> ChapterId -> ChapterId
shiftChapter delta id =
    let
        count =
            List.length ChapterId.all

        target =
            modBy count (ChapterId.number id - 1 + delta) + 1
    in
    ChapterId.all
        |> List.filter (\other -> ChapterId.number other == target)
        |> List.head
        |> Maybe.withDefault id


nextPlayable : ChapterId -> Maybe ChapterId
nextPlayable id =
    ChapterId.next id
        |> Maybe.andThen
            (\next ->
                if ChapterId.isPorted next then
                    Just next

                else
                    nextPlayable next
            )


countDown : Float -> Maybe { a | remaining : Float } -> Maybe { a | remaining : Float }
countDown milliseconds timer =
    timer
        |> Maybe.map (\t -> { t | remaining = t.remaining - milliseconds })
        |> Maybe.andThen
            (\t ->
                if t.remaining > 0 then
                    Just t

                else
                    Nothing
            )


andThen : (Model -> ( Model, Cmd Msg )) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen next ( model, cmd ) =
    let
        ( nextModel, nextCmd ) =
            next model
    in
    ( nextModel, Cmd.batch [ cmd, nextCmd ] )



-- CHAPTERS


type ChapterInput
    = Key String
    | Tick Float


newChapter : ChapterId -> Maybe Chapter
newChapter id =
    case id of
        HallOfDoors ->
            Just (HallChapter Hall.init)

        _ ->
            Nothing


chapterId : Chapter -> ChapterId
chapterId chapter =
    case chapter of
        HallChapter _ ->
            HallOfDoors


stepChapter : Context -> ChapterInput -> Chapter -> ( Chapter, List Effect )
stepChapter ctx input chapter =
    case chapter of
        HallChapter hall ->
            let
                msg =
                    case input of
                        Key key ->
                            Hall.KeyPressed key

                        Tick milliseconds ->
                            Hall.Frame milliseconds
            in
            Hall.update ctx msg hall |> Tuple.mapFirst HallChapter


viewChapter : Context -> Chapter -> Contract.View Msg
viewChapter ctx chapter =
    case chapter of
        HallChapter hall ->
            Hall.view ctx hall



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onKeyDown keyDecoder
        , Browser.Events.onAnimationFrameDelta Frame
        ]


{-| Plain key presses only: browser shortcuts (Ctrl, Alt, Cmd) are left
alone, except Ctrl+[ which terminals and Helix treat as Escape.
-}
keyDecoder : Decoder Msg
keyDecoder =
    Decode.map5
        (\key code ctrl alt meta ->
            if ctrl && (key == "[" || code == "BracketLeft") then
                Decode.succeed (KeyDown { key = "Escape", code = "Escape" })

            else if ctrl || alt || meta then
                Decode.fail "shortcut"

            else
                Decode.succeed (KeyDown { key = key, code = code })
        )
        (Decode.field "key" Decode.string)
        (Decode.field "code" Decode.string)
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "altKey" Decode.bool)
        (Decode.field "metaKey" Decode.bool)
        |> Decode.andThen identity



-- VIEW


view : Model -> Html Msg
view model =
    let
        ctx =
            context model

        texts =
            ctx.texts

        screen =
            case model.screen of
                Playing chapter ->
                    viewChapter ctx chapter

                Title ->
                    { stage = overlay Hall.backdrop (Ui.Title.view { texts = texts, progress = model.progress, selected = model.selectedChapter, onStart = StartedChapter })
                    , panel = Html.p [ A.class "big" ] [ Html.text texts.tagline ]
                    , status = idleStatus
                    , keyboard = { target = Nothing, helpers = [ "j", "k" ] }
                    }

                Results id score ->
                    { stage =
                        overlay Hall.backdrop
                            (Ui.Results.view
                                { texts = texts
                                , chapter = id
                                , score = score
                                , onNext = Maybe.map StartedChapter (nextPlayable id)
                                , onReplay = StartedChapter id
                                , onMenu = OpenedMenu
                                }
                            )
                    , panel = Html.p [ A.class "lesson" ] [ Html.text (texts.chapter id).lesson ]
                    , status = idleStatus
                    , keyboard = { target = Nothing, helpers = [] }
                    }
    in
    Html.div [ A.class "app" ]
        [ Chrome.header
            { texts = texts
            , settings = model.settings
            , onLanguage = ChoseLanguage
            , onLayout = ChoseLayout
            , onToggleSound = ToggledSound
            , onMenu = OpenedMenu
            }
        , Html.main_ [ A.class "stage" ]
            [ screen.stage
            , case model.toast of
                Just toast ->
                    Html.div [ A.class "toast", A.attribute "role" "status" ] [ Html.text (toast.text texts) ]

                Nothing ->
                    Html.text ""
            ]
        , Html.section [ A.class "panel", A.attribute "aria-live" "polite" ] [ screen.panel ]
        , Chrome.statusLine screen.status
        , Keyboard.View.view
            { texts = texts
            , layout = model.settings.layout
            , focus = screen.keyboard
            , flash = Maybe.map (\f -> { key = f.key, ok = f.ok }) model.flash
            }
        , Html.p [ A.class "footer" ] [ Html.text texts.footer ]
        ]


overlay : Html Msg -> Html Msg -> Html Msg
overlay background card =
    Html.div [ A.class "stage-scene" ]
        [ background
        , Html.div [ A.class "overlay" ] [ card ]
        ]


idleStatus : Contract.Status
idleStatus =
    { mode = "NOR", file = "wonderland.txt", pendingKeys = "", position = "1:1" }
