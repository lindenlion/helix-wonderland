module Progress exposing (Progress, decoder, empty, encode, record, tartsFor)

{-| Tarts earned per chapter. Only the best result for a chapter is kept.
-}

import Chapter.Id as ChapterId exposing (ChapterId)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Progress
    = Progress (Dict String Int)


empty : Progress
empty =
    Progress Dict.empty


tartsFor : ChapterId -> Progress -> Int
tartsFor id (Progress best) =
    Dict.get (ChapterId.toKey id) best |> Maybe.withDefault 0


record : ChapterId -> Int -> Progress -> Progress
record id tarts ((Progress best) as progress) =
    Progress (Dict.insert (ChapterId.toKey id) (max tarts (tartsFor id progress)) best)


decoder : Decoder Progress
decoder =
    Decode.map Progress (Decode.dict Decode.int)


encode : Progress -> Encode.Value
encode (Progress best) =
    Encode.dict identity Encode.int best
