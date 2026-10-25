port module Ports exposing (playSound, saveProgress, saveSettings)

{-| The only doors to JavaScript. The JS side lives in `public/index.html`.
-}

import Json.Encode as Encode


port playSound : String -> Cmd msg


port saveSettings : Encode.Value -> Cmd msg


port saveProgress : Encode.Value -> Cmd msg
