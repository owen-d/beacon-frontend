module Modules.Messages.Utils exposing (..)


import Json.Decode as Decode
import Modules.Messages.Types exposing (..)

decodeMessage : Decode.Decoder Message
decodeMessage =
    Decode.map3 Message
        (Decode.field "name" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "url" Decode.string)
