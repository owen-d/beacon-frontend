module Modules.Deployments.Utils exposing (..)

import Http exposing (jsonBody)
import Json.Decode as Decode
import Json.Encode as Encode
import Modules.Deployments.Types exposing (..)
import Modules.Messages.Utils exposing (decodeMessage, encodeMessage)
import Utils exposing (..)


fetchDeployments : String -> Cmd Msg
fetchDeployments jwt =
    let
        url =
            (++) apiUrl "/deployments"
    in
        Http.send NewDeployments
            (authReq
                (Just jwt)
                { defaultReqParams | url = url }
                decodeDeployments
            )


fetchDeploymentBeacons : String -> String -> Cmd Msg
fetchDeploymentBeacons jwt name =
    let
        url =
            apiUrl ++ "/deployments" ++ "/" ++ name ++ "/beacons"
    in
        Http.send DeploymentBeaconNames
            (authReq
                (Just jwt)
                { defaultReqParams | url = url }
                (decodeDeploymentBeacons name)
            )


decodeDeploymentBeacons : String -> Decode.Decoder ( String, List String )
decodeDeploymentBeacons name =
    Decode.map (\a -> ( name, a ))
        (Decode.field "beacons"
            (Decode.list
                (Decode.field "name" Decode.string)
            )
        )


decodeDeployments : Decode.Decoder Deployments
decodeDeployments =
    Decode.field "deployments"
        (Decode.list
            (Decode.map4 Deployment
                (Decode.field "name" Decode.string)
                (Decode.field "message_name" (Decode.maybe Decode.string))
                (Decode.map (Maybe.withDefault [])
                    (Decode.field "beacon_names" (Decode.maybe (Decode.list Decode.string)))
                )
                -- if message isn't included in response, default to nothing
                (Decode.oneOf
                    [ (Decode.field "message" <| Decode.maybe decodeMessage)
                    , (Decode.succeed Nothing)
                    ]
                )
            )
        )


encodeDeployment : Deployment -> Encode.Value
encodeDeployment dep =
    let
        baseAttrs =
            [ ( "name", Encode.string dep.name )
            , ( "beacon_names", List.map Encode.string dep.beacons |> Encode.list )
            ]

        optionalAttrs =
            [ ( "messageName", Maybe.map Encode.string dep.messageName )
            , ( "message", Maybe.map encodeMessage dep.message )
            ]
                |> maybeDecode
                |> List.take 1
    in
        Encode.object <| List.append baseAttrs optionalAttrs


postDeployment : String -> Deployment -> Cmd Msg
postDeployment jwt dep =
    let
        url =
            (++) apiUrl "/deployments"

        params =
            { defaultReqParams | url = url }

        params_1 =
            { params | method = "POST" }

        params_2 =
            { params_1 | body = jsonBody <| encodeDeployment dep }
    in
        Http.send PostDeploymentResponse
            (authReq
                (Just jwt)
                params_2
                (Decode.succeed dep)
            )
