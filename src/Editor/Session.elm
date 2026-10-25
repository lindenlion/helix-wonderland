module Editor.Session exposing
    ( Session, start, buffer, keystrokes, recentKeys
    , Outcome(..), press, matches, matchingLines
    )

{-| One player working on one text: the buffer plus what the status line
and the score need (keystrokes, the last few keys).

Chapters decide which commands are unlocked by passing a predicate to
`press`. A locked command is reported, not run, so the chapter can explain
that it comes later.

@docs Session, start, buffer, keystrokes, recentKeys
@docs Outcome, press, matches, matchingLines

-}

import Editor.Core as Core exposing (Buffer, Command, Mode(..))
import Editor.Keymap as Keymap


type Session
    = Session
        { buffer : Buffer
        , keystrokes : Int
        , recentKeys : List String
        }


start : String -> Session
start text =
    Session { buffer = Core.fromString text, keystrokes = 0, recentKeys = [] }


buffer : Session -> Buffer
buffer (Session s) =
    s.buffer


keystrokes : Session -> Int
keystrokes (Session s) =
    s.keystrokes


{-| The last Normal-mode keys, oldest first, as Helix shows them in its
status line.
-}
recentKeys : Session -> List String
recentKeys (Session s) =
    List.reverse s.recentKeys


type Outcome
    = Ran { command : Command, before : Buffer, session : Session }
    | Locked
    | Ignored


press : (Command -> Bool) -> String -> Session -> Outcome
press isUnlocked key (Session s) =
    case Keymap.commandFor (Core.mode s.buffer) key of
        Just command ->
            if isUnlocked command then
                Ran
                    { command = command
                    , before = s.buffer
                    , session =
                        Session
                            { buffer = Core.apply command s.buffer
                            , keystrokes = s.keystrokes + 1
                            , recentKeys = remember (Core.mode s.buffer) key s.recentKeys
                            }
                    }

            else
                Locked

        Nothing ->
            Ignored


remember : Mode -> String -> List String -> List String
remember mode key recent =
    case mode of
        Normal ->
            List.take 5
                ((if key == "Escape" then
                    "esc"

                  else
                    key
                 )
                    :: recent
                )

        Insert ->
            recent


{-| Does the text read like the target? Extra spaces, spaces at the ends of
lines and empty lines don't count, so a child who deletes a word with `e`
(leaving two spaces) has still done it right.
-}
matches : String -> Session -> Bool
matches target session =
    normalize (Core.toString (buffer session)) == normalize target


{-| How many lines of the target already read right, line by line.
-}
matchingLines : String -> Session -> Int
matchingLines target session =
    List.map2 (==) (normalize target) (normalize (Core.toString (buffer session)))
        |> List.filter identity
        |> List.length


normalize : String -> List String
normalize text =
    String.lines text
        |> List.map (String.words >> String.join " ")
        |> List.filter (not << String.isEmpty)
