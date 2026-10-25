module RabbitHolePlaythroughTest exposing (suite)

{-| Play chapter 1 with a fixed random seed, so every run sees the same jars.
-}

import Chapter.Contract exposing (Context)
import Chapter.RabbitHole as RabbitHole
import Chapter.Story as Story
import Expect
import Keyboard.Layout exposing (Layout(..))
import Language exposing (Language(..))
import Playthrough exposing (Run)
import Random
import Test exposing (Test, describe, test)
import Texts


contextFor : Layout -> Context
contextFor layout =
    { texts = Texts.forLanguage German, layout = layout }


start : Run RabbitHole.Model
start =
    Playthrough.start (RabbitHole.init (Random.initialSeed 42))


{-| A player who reads the story and always presses the letter of the jar
to catch next. `mistakeEvery` presses a wrong key now and then (0 = never).
Stops when the chapter reports its score, or after `fuel` moves.
-}
play : Layout -> Int -> Int -> Run RabbitHole.Model -> Run RabbitHole.Model
play layout mistakeEvery fuel run =
    let
        send =
            Playthrough.send (RabbitHole.update (contextFor layout))

        jarToCatch =
            run.model.jars |> List.sortBy .y |> List.head
    in
    if fuel <= 0 || Playthrough.finishedWith run /= Nothing then
        run

    else if Story.isTalking run.model.story then
        play layout mistakeEvery (fuel - 1) (send (RabbitHole.KeyPressed "Enter") run)

    else
        case jarToCatch of
            Just jar ->
                let
                    withMistake =
                        if mistakeEvery > 0 && modBy mistakeEvery fuel == 0 then
                            send (RabbitHole.KeyPressed "z")

                        else
                            identity
                in
                play layout mistakeEvery (fuel - 1) (run |> withMistake |> send (RabbitHole.KeyPressed (String.fromChar jar.letter)))

            Nothing ->
                play layout mistakeEvery (fuel - 1) (send (RabbitHole.Frame 50) run)


lettersSeen : Layout -> List Char
lettersSeen layout =
    let
        collect fuel run seen =
            if fuel <= 0 || Playthrough.finishedWith run /= Nothing then
                seen

            else
                let
                    send =
                        Playthrough.send (RabbitHole.update (contextFor layout))

                    next =
                        if Story.isTalking run.model.story then
                            send (RabbitHole.KeyPressed "Enter") run

                        else
                            case run.model.jars |> List.sortBy .y |> List.head of
                                Just jar ->
                                    send (RabbitHole.KeyPressed (String.fromChar jar.letter)) run

                                Nothing ->
                                    send (RabbitHole.Frame 50) run
                in
                collect (fuel - 1) next (List.map .letter run.model.jars ++ seen)
    in
    collect 5000 start []


suite : Test
suite =
    describe "Chapter 1: Down the Rabbit Hole"
        [ test "catching every jar without a mistake earns three tarts" <|
            \_ ->
                start
                    |> play SwissQwertz 0 5000
                    |> Playthrough.finishedWith
                    |> Expect.equal (Just 3)
        , test "all forty jars must be caught to land" <|
            \_ ->
                start
                    |> play SwissQwertz 0 5000
                    |> .model
                    |> .hits
                    |> Expect.equal 40
        , test "frequent wrong keys cost tarts" <|
            \_ ->
                start
                    |> play SwissQwertz 3 5000
                    |> Playthrough.finishedWith
                    |> Expect.equal (Just 1)
        , test "a Swiss keyboard practises ö, never ;" <|
            \_ ->
                lettersSeen SwissQwertz
                    |> (\letters -> ( List.member 'ö' letters, List.member ';' letters ))
                    |> Expect.equal ( True, False )
        , test "a French keyboard practises q and m for the little fingers" <|
            \_ ->
                lettersSeen FrenchAzerty
                    |> (\letters -> ( List.member 'q' letters && List.member 'm' letters, List.member 'a' letters ))
                    |> Expect.equal ( True, False )
        , test "jars that float away are not counted as caught, and come back" <|
            \_ ->
                start
                    |> Playthrough.sendAll (RabbitHole.update (contextFor UsQwerty)) (List.repeat 8 (RabbitHole.KeyPressed "Enter"))
                    |> Playthrough.sendAll (RabbitHole.update (contextFor UsQwerty)) (List.repeat 600 (RabbitHole.Frame 50))
                    |> (\run -> ( run.model.hits, run.model.stage, List.isEmpty run.model.jars ))
                    |> Expect.equal ( 0, 0, False )
        ]
