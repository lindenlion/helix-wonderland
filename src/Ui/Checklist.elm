module Ui.Checklist exposing (goal, view)

{-| The step-by-step objectives in the editor chapters, and the box showing
what the text should look like when it's done.
-}

import Html exposing (Html)
import Html.Attributes as A


{-| Ticks finished steps; the first unfinished one is highlighted as the
thing to do now.
-}
view : List ( Bool, String ) -> Html msg
view steps =
    let
        firstOpen =
            steps
                |> List.indexedMap Tuple.pair
                |> List.filter (\( _, ( done, _ ) ) -> not done)
                |> List.head
                |> Maybe.map Tuple.first
    in
    Html.ul [ A.class "checklist" ]
        (List.indexedMap
            (\index ( done, label ) ->
                Html.li [ A.classList [ ( "done", done ), ( "now", Just index == firstOpen ) ] ]
                    [ Html.text label ]
            )
            steps
        )


goal : String -> String -> Html msg
goal label text =
    Html.div [ A.class "goal" ]
        [ Html.span [ A.class "eyebrow" ] [ Html.text label ]
        , Html.pre [ A.class "goal-text" ] [ Html.text text ]
        ]
