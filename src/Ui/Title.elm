module Ui.Title exposing (view)

{-| The title card with the chapter list. `j` / `k` move the selection
(handled in `Main`), so even the menu practises Helix keys.
-}

import Chapter.Id as ChapterId exposing (ChapterId)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Progress exposing (Progress)
import Texts exposing (Texts)
import Ui.Tarts as Tarts


view :
    { texts : Texts
    , progress : Progress
    , selected : ChapterId
    , unlockAll : Bool
    , onStart : ChapterId -> msg
    , onToggleUnlock : msg
    }
    -> Html msg
view { texts, progress, selected, unlockAll, onStart, onToggleUnlock } =
    Html.div [ A.class "card" ]
        [ Html.h1 [ A.class "logo" ]
            [ Html.span [ A.class "logo-accent" ] [ Html.text texts.logo.before ]
            , Html.text " "
            , Html.small [] [ Html.text texts.logo.small ]
            , Html.text (" " ++ texts.logo.after)
            ]
        , Html.p [ A.class "tagline" ] [ Html.text texts.tagline ]
        , Html.ol [ A.class "chapters" ]
            (List.map (chapterItem texts progress unlockAll selected onStart) ChapterId.all)
        , Html.p [ A.class "hint" ] [ Html.text texts.menuHint ]
        , Html.div [ A.class "actions" ]
            [ Html.button [ A.class "quiet", E.onClick onToggleUnlock ]
                [ Html.text
                    (if unlockAll then
                        texts.allUnlocked

                     else
                        texts.unlockAll
                    )
                ]
            ]
        ]


chapterItem : Texts -> Progress -> Bool -> ChapterId -> (ChapterId -> msg) -> ChapterId -> Html msg
chapterItem texts progress unlockAll selected onStart id =
    let
        info =
            texts.chapter id

        open =
            Progress.isOpen { unlockAll = unlockAll } id progress

        tarts =
            Progress.tartsFor id progress

        status =
            if not open then
                Html.span [ A.class "chapter-status" ] [ Html.text texts.locked ]

            else if tarts == 0 && ChapterId.number id == 1 then
                Html.span [ A.class "chapter-status start" ] [ Html.text texts.startHere ]

            else
                Tarts.view "small" tarts
    in
    Html.li
        [ A.classList [ ( "selected", id == selected ), ( "locked", not open ) ]
        , E.onClick (onStart id)
        ]
        [ Html.span [ A.class "chapter-number" ] [ Html.text (String.fromInt (ChapterId.number id)) ]
        , Html.span [ A.class "chapter-text" ]
            [ Html.span [ A.class "chapter-name" ] [ Html.text info.name ]
            , Html.span [ A.class "chapter-skill" ] [ Html.text info.skill ]
            ]
        , status
        ]
