module Playthrough exposing (Run, finishedWith, send, sendAll, start, toastCount)

{-| Helpers for playing a chapter in a test: messages in, model and effects
out, no browser involved. Each chapter's test module wraps `send` with its
own `update` function.
-}

import Chapter.Contract exposing (Effect(..))


type alias Run model =
    { model : model
    , effects : List Effect
    }


start : model -> Run model
start model =
    { model = model, effects = [] }


send : (msg -> model -> ( model, List Effect )) -> msg -> Run model -> Run model
send update msg run =
    let
        ( model, effects ) =
            update msg run.model
    in
    { model = model, effects = run.effects ++ effects }


sendAll : (msg -> model -> ( model, List Effect )) -> List msg -> Run model -> Run model
sendAll update msgs run =
    List.foldl (send update) run msgs


{-| The tarts the chapter reported when it finished, if it did.
-}
finishedWith : Run model -> Maybe Int
finishedWith run =
    run.effects
        |> List.filterMap
            (\effect ->
                case effect of
                    Finish score ->
                        Just score.tarts

                    _ ->
                        Nothing
            )
        |> List.head


toastCount : Run model -> Int
toastCount run =
    run.effects
        |> List.filter
            (\effect ->
                case effect of
                    ShowToast _ ->
                        True

                    _ ->
                        False
            )
        |> List.length
