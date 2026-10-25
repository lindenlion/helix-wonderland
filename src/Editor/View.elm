module Editor.View exposing (modeName, position, view)

{-| Draws a buffer the way Helix does: line numbers in the gutter, the
selection in purple, the cursor as a block (or, in Insert mode, as a bar in
front of the character where typing goes).
-}

import Editor.Core as Core exposing (Buffer, Mode(..))
import Html exposing (Html)
import Html.Attributes as A


{-| What Helix's status line shows on the left: NOR or INS.
-}
modeName : Buffer -> String
modeName buffer =
    case Core.mode buffer of
        Normal ->
            "NOR"

        Insert ->
            "INS"


{-| What Helix's status line shows on the right: line:column.
-}
position : Buffer -> String
position buffer =
    let
        ( line, column ) =
            Core.cursorLineColumn buffer
    in
    String.fromInt line ++ ":" ++ String.fromInt column


type Look
    = Plain
    | Selected
    | Cursor
    | InsertionPoint


view : Buffer -> Html msg
view buffer =
    let
        ( cursorLine, _ ) =
            Core.cursorLineColumn buffer

        lookAt =
            lookFor buffer
    in
    Html.div [ A.class "editor" ]
        (Core.toString buffer
            |> linesWithOffsets
            |> List.indexedMap
                (\index ( offset, line ) ->
                    viewLine (index + 1 == cursorLine) (index + 1) (cells lookAt offset line)
                )
        )


{-| Each line with the position of its first character. The newline that
ends a line is kept as a final space, because the cursor can rest on it.
-}
linesWithOffsets : String -> List ( Int, String )
linesWithOffsets text =
    let
        lines =
            String.lines text
                -- The text always ends with a newline, which makes one empty line too many.
                |> List.reverse
                |> List.drop 1
                |> List.reverse

        withOffset line ( offset, done ) =
            ( offset + String.length line + 1, ( offset, line ++ " " ) :: done )
    in
    List.foldl withOffset ( 0, [] ) lines
        |> Tuple.second
        |> List.reverse


lookFor : Buffer -> Int -> Look
lookFor buffer =
    let
        ( first, last ) =
            Core.selectionRange buffer

        head =
            Core.head buffer
    in
    case Core.mode buffer of
        Insert ->
            \index ->
                if index == head then
                    InsertionPoint

                else
                    Plain

        Normal ->
            \index ->
                if index == head then
                    Cursor

                else if index >= first && index <= last then
                    Selected

                else
                    Plain


{-| Neighbouring characters that look the same are grouped into one run,
so a line becomes a handful of spans instead of one per character.
-}
cells : (Int -> Look) -> Int -> String -> List ( Look, String )
cells lookAt offset line =
    String.toList line
        |> List.indexedMap (\index char -> ( lookAt (offset + index), char ))
        |> List.foldr
            (\( look, char ) runs ->
                case runs of
                    ( runLook, text ) :: rest ->
                        if runLook == look then
                            ( look, String.cons char text ) :: rest

                        else
                            ( look, String.fromChar char ) :: runs

                    [] ->
                        [ ( look, String.fromChar char ) ]
            )
            []


viewLine : Bool -> Int -> List ( Look, String ) -> Html msg
viewLine isCurrent number runs =
    Html.div [ A.classList [ ( "editor-line", True ), ( "current", isCurrent ) ] ]
        [ Html.span [ A.class "editor-gutter" ] [ Html.text (String.fromInt number) ]
        , Html.span [ A.class "editor-code" ] (List.map viewRun runs)
        ]


viewRun : ( Look, String ) -> Html msg
viewRun ( look, text ) =
    case look of
        Plain ->
            Html.text text

        Selected ->
            Html.span [ A.class "selected" ] [ Html.text text ]

        Cursor ->
            Html.span [ A.class "cursor" ] [ Html.text text ]

        InsertionPoint ->
            Html.span [ A.class "insertion-point" ] [ Html.text text ]
