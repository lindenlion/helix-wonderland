module Pixel.Sprite exposing (Sprite, fromRows, size, view, viewAt)

{-| Pixel art drawn from text, one character per pixel.

    fromRows [ ( 'k', "#1a1020" ), ( 'y', "#f2d16b" ) ]
        [ "..kk.."
        , ".yyyy."
        ]

`.` is transparent. Each row is turned into runs of same-coloured pixels
once, when the sprite is defined, so drawing it stays cheap.

-}

import Dict
import Svg exposing (Svg)
import Svg.Attributes as A


type Sprite
    = Sprite
        { width : Int
        , height : Int
        , runs : List Run
        }


type alias Run =
    { x : Int, y : Int, length : Int, color : String }


fromRows : List ( Char, String ) -> List String -> Sprite
fromRows palette rows =
    let
        colors =
            Dict.fromList palette
    in
    Sprite
        { width = rows |> List.map String.length |> List.maximum |> Maybe.withDefault 0
        , height = List.length rows
        , runs =
            List.indexedMap (\y row -> rowRuns (\c -> Dict.get c colors) y row) rows
                |> List.concat
        }


rowRuns : (Char -> Maybe String) -> Int -> String -> List Run
rowRuns colorOf y row =
    let
        step ( x, char ) runs =
            case ( colorOf char, runs ) of
                ( Just color, previous :: rest ) ->
                    if previous.color == color && previous.x + previous.length == x then
                        { previous | length = previous.length + 1 } :: rest

                    else
                        { x = x, y = y, length = 1, color = color } :: runs

                ( Just color, [] ) ->
                    [ { x = x, y = y, length = 1, color = color } ]

                ( Nothing, _ ) ->
                    runs
    in
    String.toList row
        |> List.indexedMap Tuple.pair
        |> List.foldl step []


size : Sprite -> { width : Int, height : Int }
size (Sprite s) =
    { width = s.width, height = s.height }


{-| Draw at the origin, one SVG unit per pixel.
-}
view : Sprite -> Svg msg
view (Sprite s) =
    Svg.g []
        (List.map
            (\run ->
                Svg.rect
                    [ A.x (String.fromInt run.x)
                    , A.y (String.fromInt run.y)
                    , A.width (String.fromInt run.length)
                    , A.height "1"
                    , A.fill run.color
                    ]
                    []
            )
            s.runs
        )


{-| Draw with the top-left corner at a position, scaled by `pixelSize`.
-}
viewAt : { x : Float, y : Float, pixelSize : Float } -> Sprite -> Svg msg
viewAt { x, y, pixelSize } sprite =
    Svg.g
        [ A.transform
            ("translate(" ++ String.fromFloat x ++ " " ++ String.fromFloat y ++ ") scale(" ++ String.fromFloat pixelSize ++ ")")
        ]
        [ view sprite ]
