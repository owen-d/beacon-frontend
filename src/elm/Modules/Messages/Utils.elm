module Modules.Messages.Utils exposing (..)

import Http exposing (jsonBody)
import Json.Decode as Decode
import Json.Encode as Encode
import Modules.Messages.Types exposing (..)
import Utils exposing (..)


decodeMessage : Decode.Decoder Message
decodeMessage =
    Decode.map3 Message
        (Decode.field "name" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "url" Decode.string)


decodeMessages : Decode.Decoder Messages
decodeMessages =
    Decode.field "messages"
        (Decode.list decodeMessage)


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


fetchMessages : String -> Cmd Msg
fetchMessages jwt =
    let
        url =
            (++) apiUrl "/messages"
    in
        Http.send NewMessages
            (authReq
                jwt
                { defaultReqParams | url = url }
                decodeMessages
            )


postMessage : String -> Message -> Cmd Msg
postMessage jwt msg =
    let
        url =
            (++) apiUrl "/messages"

        params =
            { defaultReqParams | url = url }

        params_1 =
            { params | method = "POST" }

        params_2 =
            { params_1 | body = jsonBody <| encodeMessage msg }
    in
        Http.send PostMessageResponse
            (authReq
                jwt
                params_2
                (Decode.succeed msg)
            )
