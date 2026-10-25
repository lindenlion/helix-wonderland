module Ui.TheEnd exposing (view)

{-| The card after the last chapter: all tarts collected so far, and a peek
at what comes next.
-}

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Texts exposing (Texts)
import Ui.Tarts as Tarts


view : { texts : Texts, totalTarts : Int, onMenu : msg } -> Html msg
view { texts, totalTarts, onMenu } =
    Html.div [ A.class "card" ]
        [ Html.h2 [] [ Html.text texts.theEnd.title ]
        , Tarts.view "large" (round (toFloat totalTarts / 5))
        , Html.p [ A.class "big" ] [ Html.text (texts.theEnd.tarts totalTarts) ]
        , Html.p [] [ Html.text texts.theEnd.teaser ]
        , Html.div [ A.class "actions" ]
            [ Html.button [ A.class "primary", E.onClick onMenu ]
                [ Html.text (texts.menu ++ " "), Html.kbd [] [ Html.text "Enter" ] ]
            ]
        ]
