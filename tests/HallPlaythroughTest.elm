module HallPlaythroughTest exposing (suite)

{-| Play chapter 2 the way a child would: read the story, press keys, wait
for Alice to walk. No browser involved, just messages in, model and effects
out.
-}

import Chapter.Contract exposing (Context, Effect(..))
import Chapter.Hall as Hall
import Expect
import Keyboard.Layout exposing (Layout(..))
import Language exposing (Language(..))
import Test exposing (Test, describe, test)
import Texts


context : Context
context =
    { texts = Texts.forLanguage German, layout = SwissQwertz }


type alias Run =
    { model : Hall.Model
    , effects : List Effect
    }


start : Run
start =
    { model = Hall.init, effects = [] }


send : Hall.Msg -> Run -> Run
send msg run =
    let
        ( model, effects ) =
            Hall.update context msg run.model
    in
    { model = model, effects = run.effects ++ effects }


{-| Press keys in order; each character of the string is one key.
-}
press : String -> Run -> Run
press keys run =
    String.toList keys
        |> List.foldl (\char -> send (Hall.KeyPressed (String.fromChar char))) run


{-| Let time pass in 16 ms frames, long enough for any walk on this map.
-}
wait : Run -> Run
wait run =
    List.foldl (\_ -> send (Hall.Frame 16)) run (List.range 1 400)


{-| Read every open dialog to the end (Enter reveals, Enter continues).
-}
readStory : Run -> Run
readStory run =
    List.foldl (\_ -> send (Hall.KeyPressed "Enter")) run (List.range 1 12)


finishedWith : Run -> Maybe Int
finishedWith run =
    run.effects
        |> List.filterMap
            (\effect ->
                case effect of
                    Finish score ->
                        Just score.tarts

                    _ ->
                        Nothing
            )
        |> List.head


toasts : Run -> Int
toasts run =
    run.effects
        |> List.filter
            (\effect ->
                case effect of
                    ShowToast _ ->
                        True

                    _ ->
                        False
            )
        |> List.length


suite : Test
suite =
    describe "Chapter 2: The Hall of Doors"
        [ test "the fastest route with counts earns three tarts" <|
            \_ ->
                start
                    |> readStory
                    |> press "5k8l"
                    |> wait
                    |> readStory
                    |> press "9l5j"
                    |> wait
                    |> readStory
                    |> finishedWith
                    |> Expect.equal (Just 3)
        , test "walking without counts still finishes, with one tart" <|
            \_ ->
                start
                    |> readStory
                    |> press "kkkkkllllllll"
                    |> wait
                    |> readStory
                    |> press "llllllllljjjjj"
                    |> wait
                    |> readStory
                    |> finishedWith
                    |> Expect.equal (Just 1)
        , test "keys pressed during the story do not move Alice" <|
            \_ ->
                start
                    |> press "kkk"
                    |> wait
                    |> .model
                    |> .alice
                    |> Expect.equal { x = 1, y = 10 }
        , test "walking into a wall stops the rest of a count" <|
            \_ ->
                start
                    |> readStory
                    |> press "9h"
                    |> wait
                    |> .model
                    |> .alice
                    |> Expect.equal { x = 1, y = 10 }
        , test "the curtain stays locked without the key" <|
            \_ ->
                start
                    |> readStory
                    |> press "17l"
                    |> wait
                    |> (\run -> ( finishedWith run, toasts run ))
                    |> Expect.equal ( Nothing, 1 )
        , test "arrow keys show a hint instead of moving" <|
            \_ ->
                start
                    |> readStory
                    |> send (Hall.KeyPressed "ArrowRight")
                    |> wait
                    |> (\run -> ( run.model.alice, toasts run ))
                    |> Expect.equal ( { x = 1, y = 10 }, 1 )
        , test "a count cannot start with 0" <|
            \_ ->
                start
                    |> readStory
                    |> press "0"
                    |> .model
                    |> .pendingCount
                    |> Expect.equal ""
        ]
