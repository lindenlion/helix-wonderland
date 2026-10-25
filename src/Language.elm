module Language exposing (Language(..), all, fromCode, toCode)

{-| The languages the game is written in. Adding one means adding a case
here and a full `Texts` record in `Texts.elm`; the compiler then lists every
place that still needs it.
-}


type Language
    = English
    | German


all : List Language
all =
    [ English, German ]


{-| Short code for buttons and for saving the setting.
-}
toCode : Language -> String
toCode language =
    case language of
        English ->
            "EN"

        German ->
            "DE"


fromCode : String -> Maybe Language
fromCode code =
    case String.toUpper code of
        "EN" ->
            Just English

        "DE" ->
            Just German

        _ ->
            Nothing
