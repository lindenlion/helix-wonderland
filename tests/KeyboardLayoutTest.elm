module KeyboardLayoutTest exposing (suite)

import Expect
import Keyboard.Layout as Layout exposing (Finger(..), Layout(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Keyboard.Layout"
        [ describe "fingers"
            [ test "f is the left index finger on every layout" <|
                \_ ->
                    List.map (\l -> Layout.fingerFor l 'f') Layout.all
                        |> Expect.equal (List.repeat 4 (Just LeftIndex))
            , test "h and j belong to the right index finger on every layout" <|
                \_ ->
                    List.concatMap (\l -> [ Layout.fingerFor l 'h', Layout.fingerFor l 'j' ]) Layout.all
                        |> Expect.equal (List.repeat 8 (Just RightIndex))
            , test "ö is the right little finger on German and Swiss keyboards" <|
                \_ ->
                    [ Layout.fingerFor GermanQwertz 'ö', Layout.fingerFor SwissQwertz 'ö' ]
                        |> Expect.equal [ Just RightLittle, Just RightLittle ]
            , test "on AZERTY, a is a top-row key for the left little finger" <|
                \_ -> Layout.fingerFor FrenchAzerty 'a' |> Expect.equal (Just LeftLittle)
            , test "on AZERTY, z is pressed by the left ring finger" <|
                \_ -> Layout.fingerFor FrenchAzerty 'z' |> Expect.equal (Just LeftRing)
            , test "the space bar is for thumbs" <|
                \_ -> Layout.fingerFor UsQwerty ' ' |> Expect.equal (Just Thumb)
            , test "characters that are not on the keyboard have no finger" <|
                \_ -> Layout.fingerFor UsQwerty 'ö' |> Expect.equal Nothing
            ]
        , describe "home row"
            [ test "QWERTY rests on asdf and jkl;" <|
                \_ -> Layout.homeKeys UsQwerty |> Expect.equal { left = [ 'a', 's', 'd', 'f' ], right = [ 'j', 'k', 'l', ';' ] }
            , test "Swiss QWERTZ rests on asdf and jklö" <|
                \_ -> Layout.homeKeys SwissQwertz |> Expect.equal { left = [ 'a', 's', 'd', 'f' ], right = [ 'j', 'k', 'l', 'ö' ] }
            , test "AZERTY rests on qsdf and jklm" <|
                \_ -> Layout.homeKeys FrenchAzerty |> Expect.equal { left = [ 'q', 's', 'd', 'f' ], right = [ 'j', 'k', 'l', 'm' ] }
            , test "the stretch keys are g and h everywhere" <|
                \_ -> List.map Layout.stretchKeys Layout.all |> Expect.equal (List.repeat 4 [ 'g', 'h' ])
            ]
        , describe "detecting the layout from a key press"
            [ test "z typed by the physical Y key means QWERTZ" <|
                \_ -> Layout.detect UsQwerty { code = "KeyY", key = "z" } |> Expect.equal (Just GermanQwertz)
            , test "a Swiss player is not switched to German by z" <|
                \_ -> Layout.detect SwissQwertz { code = "KeyY", key = "z" } |> Expect.equal Nothing
            , test "$ right of the home row means Swiss" <|
                \_ -> Layout.detect GermanQwertz { code = "Backslash", key = "$" } |> Expect.equal (Just SwissQwertz)
            , test "ß means German" <|
                \_ -> Layout.detect SwissQwertz { code = "Minus", key = "ß" } |> Expect.equal (Just GermanQwertz)
            , test "a typed by the physical Q key means AZERTY" <|
                \_ -> Layout.detect GermanQwertz { code = "KeyQ", key = "a" } |> Expect.equal (Just FrenchAzerty)
            , test "a correct setting is left alone" <|
                \_ -> Layout.detect UsQwerty { code = "KeyZ", key = "z" } |> Expect.equal Nothing
            , test "ordinary letters say nothing about the layout" <|
                \_ -> Layout.detect FrenchAzerty { code = "KeyJ", key = "j" } |> Expect.equal Nothing
            ]
        ]
