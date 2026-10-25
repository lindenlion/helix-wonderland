module PoolPlaythroughTest exposing (suite)

{-| Play chapter 4 with real Helix keystrokes.
-}

import Chapter.Contract exposing (Context)
import Chapter.Pool as Pool
import Editor.Core as Core exposing (Mode(..))
import Editor.Session as Session
import Expect
import Keyboard.Layout exposing (Layout(..))
import Language exposing (Language(..))
import Playthrough exposing (Run)
import Test exposing (Test, describe, test)
import Texts


inEnglish : Context
inEnglish =
    { texts = Texts.forLanguage English, layout = UsQwerty }


press : List String -> Run Pool.Model -> Run Pool.Model
press keys =
    Playthrough.sendAll (Pool.update inEnglish) (List.map Pool.KeyPressed keys)


readStory : Run Pool.Model -> Run Pool.Model
readStory =
    press (List.repeat 12 "Enter")


{-| `h` stops at the start of a line, so plenty of them get there from
anywhere on it.
-}
toLineStart : List String
toLineStart =
    List.repeat 40 "h"


{-| Line by line: go to the line start, `w` until the junk is selected, `d`.
The third line is all tears: `x` selects it, `d` removes it.
-}
cleanThePoem : List String
cleanThePoem =
    List.concat
        [ toLineStart ++ List.repeat 5 "w" ++ [ "d" ]
        , "j" :: toLineStart ++ [ "w", "w", "d" ]
        , [ "j", "x", "d" ]
        , toLineStart ++ List.repeat 6 "w" ++ [ "d" ]
        , "j" :: toLineStart ++ List.repeat 6 "w" ++ [ "d" ]
        ]


text : Run Pool.Model -> String
text run =
    run.model.work
        |> Maybe.map (.session >> Session.buffer >> Core.toString)
        |> Maybe.withDefault ""


suite : Test
suite =
    describe "Chapter 4: The Pool of Tears"
        [ test "cleaning the poem without mistakes earns three tarts" <|
            \_ ->
                Playthrough.start Pool.init
                    |> readStory
                    |> press cleanThePoem
                    |> readStory
                    |> Playthrough.finishedWith
                    |> Expect.equal (Just 3)
        , test "the cleaned poem is exactly Carroll's" <|
            \_ ->
                Playthrough.start Pool.init
                    |> readStory
                    |> press cleanThePoem
                    |> text
                    |> String.lines
                    |> List.map String.trimRight
                    |> Expect.equal [ "How doth the little crocodile", "Improve his shining tail,", "And pour the waters of the Nile", "On every golden scale!", "" ]
        , test "deleting a word of the poem is a mistake, and u brings it back" <|
            \_ ->
                Playthrough.start Pool.init
                    |> readStory
                    |> press [ "w", "d" ]
                    |> (\run -> ( run.model.wrongDeletions, Playthrough.toastCount run, text (press [ "u" ] run) ))
                    |> Expect.equal ( 1, 1, (Texts.forLanguage English).pool.poem ++ "\n" )
        , test "one mistake, undone, still finishes with two tarts" <|
            \_ ->
                Playthrough.start Pool.init
                    |> readStory
                    |> press [ "w", "d", "u" ]
                    |> press cleanThePoem
                    |> readStory
                    |> Playthrough.finishedWith
                    |> Expect.equal (Just 2)
        , test "Insert mode is locked in this chapter" <|
            \_ ->
                Playthrough.start Pool.init
                    |> readStory
                    |> press [ "i", "x" ]
                    |> (\run ->
                            ( run.model.work |> Maybe.map (.session >> Session.buffer >> Core.mode)
                            , Playthrough.toastCount run
                            )
                       )
                    |> Expect.equal ( Just Normal, 1 )
        , test "the poem follows the language until the first key, then stays" <|
            \_ ->
                Playthrough.start Pool.init
                    |> readStory
                    |> Playthrough.send (Pool.update { inEnglish | texts = Texts.forLanguage German }) (Pool.KeyPressed "l")
                    |> press [ "l" ]
                    |> .model
                    |> .work
                    |> Maybe.map (.puzzle >> .junk)
                    |> Expect.equal (Just "platsch")
        ]
