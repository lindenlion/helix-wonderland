module Ui.Results exposing (view)

{-| The card shown after a chapter: tarts, the lesson in one line, stats.
-}

import Chapter.Contract exposing (Score)
import Chapter.Id as ChapterId exposing (ChapterId)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Texts exposing (Texts)
import Ui.Tarts as Tarts


view :
    { texts : Texts
    , chapter : ChapterId
    , score : Score
    , onNext : msg
    , onReplay : msg
    , onMenu : msg
    }
    -> Html msg
view { texts, chapter, score, onNext, onReplay, onMenu } =
    let
        info =
            texts.chapter chapter

        button class msg label key =
            Html.button [ A.class class, E.onClick msg ] [ Html.text (label ++ " "), Html.kbd [] [ Html.text key ] ]
    in
    Html.div [ A.class "card" ]
        [ Html.span [ A.class "eyebrow" ] [ Html.text (String.fromInt (ChapterId.number chapter) ++ " · " ++ info.name) ]
        , Html.h2 [] [ Html.text texts.results.title ]
        , Tarts.view "large" score.tarts
        , Html.p [ A.class "lesson" ] [ Html.text info.lesson ]
        , Html.div [ A.class "stats" ]
            (List.map (\stat -> Html.span [] [ Html.text (stat.label texts), Html.b [] [ Html.text (stat.value texts) ] ]) score.stats)
        , Html.div [ A.class "actions" ]
            [ button "primary" onNext texts.results.next "Enter"
            , button "" onReplay texts.results.replay "r"
            , button "" onMenu texts.results.menu "m"
            ]
        ]
