module Keyboard.Layout exposing
    ( Layout(..), all, name, toKey, fromKey
    , Finger(..), allFingers, fingerFor, rows, homeKeys, stretchKeys
    , needsShiftForDigits, detect
    )

{-| Physical keyboard layouts: where each letter sits and which finger
presses it.

The game always reacts to the character a key _types_ (the browser's
`KeyboardEvent.key`), so Helix commands work on every layout. The layout only
matters for teaching: the on-screen keyboard, finger hints and home-row
lessons.

@docs Layout, all, name, toKey, fromKey
@docs Finger, allFingers, fingerFor, rows, homeKeys, stretchKeys
@docs needsShiftForDigits, detect

-}


type Layout
    = UsQwerty
    | GermanQwertz
    | SwissQwertz
    | FrenchAzerty


all : List Layout
all =
    [ GermanQwertz, SwissQwertz, UsQwerty, FrenchAzerty ]


name : Layout -> String
name layout =
    case layout of
        UsQwerty ->
            "QWERTY"

        GermanQwertz ->
            "QWERTZ DE"

        SwissQwertz ->
            "QWERTZ CH"

        FrenchAzerty ->
            "AZERTY"


{-| Stable name for saving the setting. Never change these.
-}
toKey : Layout -> String
toKey layout =
    case layout of
        UsQwerty ->
            "us"

        GermanQwertz ->
            "de"

        SwissQwertz ->
            "ch"

        FrenchAzerty ->
            "fr"


fromKey : String -> Maybe Layout
fromKey key =
    all |> List.filter (\layout -> toKey layout == key) |> List.head


type Finger
    = LeftLittle
    | LeftRing
    | LeftMiddle
    | LeftIndex
    | RightIndex
    | RightMiddle
    | RightRing
    | RightLittle
    | Thumb


allFingers : List Finger
allFingers =
    [ LeftLittle, LeftRing, LeftMiddle, LeftIndex, RightIndex, RightMiddle, RightRing, RightLittle, Thumb ]


{-| The three letter rows, top to bottom, as the characters typed without
Shift. Dead keys (like the Swiss ¨) are shown as their symbol.
-}
rows : Layout -> List String
rows layout =
    case layout of
        UsQwerty ->
            [ "qwertyuiop[]", "asdfghjkl;'", "zxcvbnm,./" ]

        GermanQwertz ->
            [ "qwertzuiopü+", "asdfghjklöä#", "yxcvbnm,.-" ]

        SwissQwertz ->
            [ "qwertzuiopü¨", "asdfghjklöä$", "yxcvbnm,.-" ]

        FrenchAzerty ->
            [ "azertyuiop^$", "qsdfghjklmù*", "wxcvbn,;:!" ]


{-| Which finger presses a key, in standard ten-finger typing: each column
belongs to one finger, the index fingers take two columns each, and the
little fingers take everything on the outside.
-}
fingerFor : Layout -> Char -> Maybe Finger
fingerFor layout char =
    if char == ' ' then
        Just Thumb

    else
        rows layout
            |> List.filterMap (columnOf char)
            |> List.head
            |> Maybe.map fingerForColumn


fingerForColumn : Int -> Finger
fingerForColumn column =
    case column of
        0 ->
            LeftLittle

        1 ->
            LeftRing

        2 ->
            LeftMiddle

        3 ->
            LeftIndex

        4 ->
            LeftIndex

        5 ->
            RightIndex

        6 ->
            RightIndex

        7 ->
            RightMiddle

        8 ->
            RightRing

        _ ->
            RightLittle


columnOf : Char -> String -> Maybe Int
columnOf char row =
    String.indexes (String.fromChar char) row |> List.head


{-| Where the eight fingers rest: the home row without the two middle
columns. On QWERTY that is `asdf` and `jkl;`.
-}
homeKeys : Layout -> { left : List Char, right : List Char }
homeKeys layout =
    let
        homeRow =
            rows layout |> List.drop 1 |> List.head |> Maybe.withDefault "" |> String.toList
    in
    { left = List.take 4 homeRow
    , right = homeRow |> List.drop 6 |> List.take 4
    }


{-| The two home-row keys the index fingers reach sideways for (`g` and `h`).
-}
stretchKeys : Layout -> List Char
stretchKeys layout =
    rows layout |> List.drop 1 |> List.head |> Maybe.withDefault "" |> String.toList |> List.drop 4 |> List.take 2


{-| On AZERTY the number row types symbols; digits need Shift. Worth a hint
when a chapter teaches counts like `5j`.
-}
needsShiftForDigits : Layout -> Bool
needsShiftForDigits layout =
    layout == FrenchAzerty


{-| Guess the layout from one key press: `code` names the physical key (as
on a US keyboard), `key` is what it typed. Returns a layout only when the
press contradicts the current one, so a correct setting is never changed.

The German and Swiss layouts share all letters, so they are told apart by
the key right of the home row (`#` versus `$`) or by `ß`, which only German
keyboards have.

-}
detect : Layout -> { code : String, key : String } -> Maybe Layout
detect current press =
    let
        isQwertzFamily =
            current == GermanQwertz || current == SwissQwertz

        evidence =
            case ( press.code, press.key ) of
                ( "KeyY", "z" ) ->
                    Just QwertzFamily

                ( "KeyZ", "y" ) ->
                    Just QwertzFamily

                ( "Minus", "ß" ) ->
                    Just (Exactly GermanQwertz)

                ( "Backslash", "#" ) ->
                    Just (Exactly GermanQwertz)

                ( "Backslash", "$" ) ->
                    Just (Exactly SwissQwertz)

                ( "KeyQ", "a" ) ->
                    Just (Exactly FrenchAzerty)

                ( "KeyA", "q" ) ->
                    Just (Exactly FrenchAzerty)

                ( "Semicolon", "m" ) ->
                    Just (Exactly FrenchAzerty)

                ( "KeyZ", "z" ) ->
                    Just (Exactly UsQwerty)

                ( "Semicolon", ";" ) ->
                    Just (Exactly UsQwerty)

                _ ->
                    Nothing
    in
    case evidence of
        Just QwertzFamily ->
            if isQwertzFamily then
                Nothing

            else
                Just GermanQwertz

        Just (Exactly layout) ->
            if layout == current then
                Nothing

            else
                Just layout

        Nothing ->
            Nothing


type Evidence
    = QwertzFamily
    | Exactly Layout
