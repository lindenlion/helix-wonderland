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


view : { texts : Texts, progress : Progress, selected : ChapterId, onStart : ChapterId -> msg } -> Html msg
view { texts, progress, selected, onStart } =
    Html.div [ A.class "card" ]
        [ Html.h1 [ A.class "logo" ]
            [ Html.span [ A.class "logo-accent" ] [ Html.text texts.logo.before ]
            , Html.text " "
            , Html.small [] [ Html.text texts.logo.small ]
            , Html.text (" " ++ texts.logo.after)
            ]
        , Html.p [ A.class "tagline" ] [ Html.text texts.tagline ]
        , Html.p [ A.class "notice" ] [ Html.text texts.portNotice ]
        , Html.ol [ A.class "chapters" ]
            (List.map (chapterItem texts progress selected onStart) ChapterId.all)
        , Html.p [ A.class "hint" ] [ Html.text texts.menuHint ]
        ]


chapterItem : Texts -> Progress -> ChapterId -> (ChapterId -> msg) -> ChapterId -> Html msg
chapterItem texts progress selected onStart id =
    let
        info =
            texts.chapter id

        playable =
            ChapterId.isPorted id
    in
    Html.li
        [ A.classList [ ( "selected", id == selected ), ( "unavailable", not playable ) ]
        , E.onClick (onStart id)
        ]
        [ Html.span [ A.class "chapter-number" ] [ Html.text (String.fromInt (ChapterId.number id)) ]
        , Html.span [ A.class "chapter-text" ]
            [ Html.span [ A.class "chapter-name" ] [ Html.text info.name ]
            , Html.span [ A.class "chapter-skill" ] [ Html.text info.skill ]
            ]
        , if playable then
            Tarts.view "small" (Progress.tartsFor id progress)

          else
            Html.span [ A.class "chapter-status" ] [ Html.text texts.notPortedYet ]
        ]
