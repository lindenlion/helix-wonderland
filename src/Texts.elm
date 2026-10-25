module Texts exposing (Texts, ChapterInfo, HallTexts, ResultTexts, forLanguage)

{-| Every word the player reads, per language.

`Texts` is a record, so each language must fill in every field: a missing
German line is a compile error, not a blank on screen. German follows Swiss
spelling (ss instead of ß).

@docs Texts, ChapterInfo, HallTexts, ResultTexts, forLanguage

-}

import Chapter.Id exposing (ChapterId(..))
import Keyboard.Layout exposing (Finger(..))
import Language exposing (Language(..))
import Speaker exposing (Speaker(..))


type alias Texts =
    { logo : { before : String, small : String, after : String }
    , tagline : String
    , portNotice : String
    , notPortedYet : String
    , menuHint : String
    , menu : String
    , soundOn : String
    , soundOff : String
    , continueHint : String
    , footer : String
    , keyboardLegend : String
    , space : String
    , nextKey : String -> String -> String
    , finger : Finger -> String
    , speaker : Speaker -> String
    , layoutDetected : String -> String
    , chapter : ChapterId -> ChapterInfo
    , results : ResultTexts
    , hall : HallTexts
    }


type alias ChapterInfo =
    { name : String
    , skill : String
    , lesson : String
    }


type alias ResultTexts =
    { title : String
    , next : String
    , replay : String
    , menu : String
    , keystrokes : String
    , fewestPossible : String
    , usedCount : String
    , yes : String
    , notYet : String
    }


type alias HallTexts =
    { intro1 : String
    , intro2 : String
    , intro3 : String
    , intro4 : String
    , keyFound : String
    , countLesson : String
    , locked : String
    , finale : String
    , findKey : String
    , goToCurtain : String
    , countTip : String
    , azertyTip : String
    , arrows : String
    }


forLanguage : Language -> Texts
forLanguage language =
    case language of
        English ->
            english

        German ->
            german



-- ENGLISH


english : Texts
english =
    { logo = { before = "Helix", small = "in", after = "Wonderland" }
    , tagline = "Learn the Helix editor and ten-finger typing, one chapter of Alice at a time."
    , portNotice = "This is the Elm rebuild. Chapter 2 has moved over; the others still live in the prototype."
    , notPortedYet = "still in the prototype"
    , menuHint = "j / k to choose · Enter to play"
    , menu = "Menu"
    , soundOn = "Sound on"
    , soundOff = "Sound off"
    , continueHint = "Enter ⏎ to continue"
    , footer = "Story and characters from Lewis Carroll's Alice's Adventures in Wonderland (1865), which is in the public domain. Helix is a free, open-source editor; this game is not affiliated with it."
    , keyboardLegend = "Each colour is one finger. Matching colours, matching finger."
    , space = "space"
    , nextKey = \key finger -> "Next key: " ++ key ++ " · " ++ finger
    , finger =
        \finger ->
            case finger of
                LeftLittle ->
                    "left little finger"

                LeftRing ->
                    "left ring finger"

                LeftMiddle ->
                    "left middle finger"

                LeftIndex ->
                    "left index finger"

                RightIndex ->
                    "right index finger"

                RightMiddle ->
                    "right middle finger"

                RightRing ->
                    "right ring finger"

                RightLittle ->
                    "right little finger"

                Thumb ->
                    "thumb"
    , speaker =
        \speaker ->
            case speaker of
                Narrator ->
                    "Narrator"

                Alice ->
                    "Alice"

                WhiteRabbit ->
                    "White Rabbit"
    , layoutDetected = \layout -> "Your keyboard looks like " ++ layout ++ ". Switched."
    , chapter =
        \id ->
            case id of
                RabbitHole ->
                    { name = "Down the Rabbit Hole", skill = "Home row typing", lesson = "Fingers live on the home row." }

                HallOfDoors ->
                    { name = "The Hall of Doors", skill = "Helix: move with h j k l, counts", lesson = "h ← j ↓ k ↑ l →, and 5j walks five steps." }

                DrinkMe ->
                    { name = "Drink Me", skill = "Typing words, new keys e and i", lesson = "Words with e and i, thumb on the space bar." }

                PoolOfTears ->
                    { name = "The Pool of Tears", skill = "Helix: w e b select, d deletes, x lines, u undo", lesson = "Select first, then act." }

                Caterpillar ->
                    { name = "Advice from a Caterpillar", skill = "Helix: i and a insert, Esc returns", lesson = "i inserts before, a after, Esc goes back to NOR." }
    , results =
        { title = "Chapter complete!"
        , next = "Next"
        , replay = "Play again"
        , menu = "Menu"
        , keystrokes = "Keystrokes"
        , fewestPossible = "Fewest possible"
        , usedCount = "Used a count"
        , yes = "yes"
        , notYet = "not yet"
        }
    , hall =
        { intro1 = "Alice found herself in a long, low hall. There were doors all round it, but they were all locked."
        , intro2 = "Oh my ears and whiskers, how late it's getting!"
        , intro3 = "In Helix you move without the mouse and without the arrow keys. Your right hand already rests on the keys you need."
        , intro4 = "h moves left, j down, k up, l right. A trick: the j has a hook that hangs down. Find the tiny golden key."
        , keyFound = "A tiny golden key! It must open one of these doors."
        , countLesson = "A faster way to walk: type a number first. 8l walks eight steps right. Helix calls this a count. Try it on your way to the little curtain in the bottom-right corner."
        , locked = "The little door is locked. Where is that key?"
        , finale = "Behind the curtain was a little door about fifteen inches high. The key fitted! But Alice could not even get her head through the doorway."
        , findKey = "Find the tiny golden key."
        , goToCurtain = "Walk to the little curtain, bottom right."
        , countTip = "Type a number first, like 5j, to walk five steps."
        , azertyTip = "On AZERTY, digits need Shift: Shift+5, then j."
        , arrows = "Arrow keys are for rabbits in a hurry. Keep your fingers home: h j k l."
        }
    }



-- GERMAN (Swiss spelling: ss, never ß)


german : Texts
german =
    { logo = { before = "Helix", small = "im", after = "Wunderland" }
    , tagline = "Lerne den Helix-Editor und das Zehnfingersystem, Kapitel für Kapitel mit Alice."
    , portNotice = "Dies ist der Neubau in Elm. Kapitel 2 ist schon umgezogen, die anderen gibt es vorerst nur im Prototyp."
    , notPortedYet = "noch im Prototyp"
    , menuHint = "j / k zum Wählen · Enter zum Spielen"
    , menu = "Menü"
    , soundOn = "Ton an"
    , soundOff = "Ton aus"
    , continueHint = "Enter ⏎ zum Weiterlesen"
    , footer = "Geschichte und Figuren aus Lewis Carrolls Alice im Wunderland (1865), gemeinfrei. Helix ist ein freier Open-Source-Editor; dieses Spiel gehört nicht zum Helix-Projekt."
    , keyboardLegend = "Jede Farbe ist ein Finger. Gleiche Farbe, gleicher Finger."
    , space = "Leertaste"
    , nextKey = \key finger -> "Nächste Taste: " ++ key ++ " · " ++ finger
    , finger =
        \finger ->
            case finger of
                LeftLittle ->
                    "linker kleiner Finger"

                LeftRing ->
                    "linker Ringfinger"

                LeftMiddle ->
                    "linker Mittelfinger"

                LeftIndex ->
                    "linker Zeigefinger"

                RightIndex ->
                    "rechter Zeigefinger"

                RightMiddle ->
                    "rechter Mittelfinger"

                RightRing ->
                    "rechter Ringfinger"

                RightLittle ->
                    "rechter kleiner Finger"

                Thumb ->
                    "Daumen"
    , speaker =
        \speaker ->
            case speaker of
                Narrator ->
                    "Erzähler"

                Alice ->
                    "Alice"

                WhiteRabbit ->
                    "Weisses Kaninchen"
    , layoutDetected = \layout -> "Deine Tastatur sieht nach " ++ layout ++ " aus. Umgestellt."
    , chapter =
        \id ->
            case id of
                RabbitHole ->
                    { name = "Hinunter in den Kaninchenbau", skill = "Grundreihe tippen", lesson = "Die Finger wohnen auf der Grundreihe." }

                HallOfDoors ->
                    { name = "Der Saal der Türen", skill = "Helix: bewegen mit h j k l, Counts", lesson = "h ← j ↓ k ↑ l →, und 5j geht fünf Schritte." }

                DrinkMe ->
                    { name = "Trink mich", skill = "Wörter tippen, neue Tasten e und i", lesson = "Wörter mit e und i, Daumen auf der Leertaste." }

                PoolOfTears ->
                    { name = "Der Tränenteich", skill = "Helix: w e b wählen, d löscht, x Zeilen, u zurück", lesson = "Erst auswählen, dann handeln." }

                Caterpillar ->
                    { name = "Die Raupe gibt Rat", skill = "Helix: i und a einfügen, Esc zurück", lesson = "i fügt davor ein, a dahinter, Esc zurück zu NOR." }
    , results =
        { title = "Kapitel geschafft!"
        , next = "Weiter"
        , replay = "Nochmal"
        , menu = "Menü"
        , keystrokes = "Tastendrücke"
        , fewestPossible = "Am wenigsten möglich"
        , usedCount = "Count benutzt"
        , yes = "ja"
        , notYet = "noch nicht"
        }
    , hall =
        { intro1 = "Alice stand in einem langen, niedrigen Saal. Ringsum waren Türen, aber alle waren verschlossen."
        , intro2 = "Bei meinen Ohren und Schnurrhaaren, wie spät es schon ist!"
        , intro3 = "In Helix bewegst du dich ohne Maus und ohne Pfeiltasten. Deine rechte Hand liegt schon auf den richtigen Tasten."
        , intro4 = "h geht nach links, j nach unten, k nach oben, l nach rechts. Merkhilfe: das j hat unten einen Haken. Finde den winzigen goldenen Schlüssel."
        , keyFound = "Ein winziger goldener Schlüssel! Er passt bestimmt in eine dieser Türen."
        , countLesson = "Schneller laufen: tippe zuerst eine Zahl. 8l geht acht Schritte nach rechts. Helix nennt das einen Count. Probier es auf dem Weg zum kleinen Vorhang unten rechts."
        , locked = "Die kleine Tür ist verschlossen. Wo ist der Schlüssel?"
        , finale = "Hinter dem Vorhang war eine kleine Tür, kaum vierzig Zentimeter hoch. Der Schlüssel passte! Aber Alice bekam nicht einmal den Kopf durch die Öffnung."
        , findKey = "Finde den winzigen goldenen Schlüssel."
        , goToCurtain = "Geh zum kleinen Vorhang unten rechts."
        , countTip = "Tippe zuerst eine Zahl, zum Beispiel 5j, für fünf Schritte."
        , azertyTip = "Auf AZERTY brauchen Ziffern die Umschalttaste: Umschalt+5, dann j."
        , arrows = "Pfeiltasten sind für eilige Kaninchen. Lass die Finger zu Hause: h j k l."
        }
    }
