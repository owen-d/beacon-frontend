module Modules.Messages.Utils exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Modules.Messages.Types exposing (..)


decodeMessage : Decode.Decoder Message
decodeMessage =
    Decode.map3 Message
        (Decode.field "name" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "url" Decode.string)


encodeMessage : Message -> Encode.Value
encodeMessage msg =
    let
        attributes =
            [ ( "name", Encode.string msg.name )
            , ( "title", Encode.string msg.title )
            , ( "url", Encode.string msg.url )
            ]
    in
        Encode.object attributes
