module Modules.Deployments.Utils exposing (..)

import Http
import Json.Decode as Decode
import Modules.Deployments.Types exposing (..)
import Modules.Messages.Utils exposing (decodeMessage)
import Utils exposing (..)


fetchDeployments : String -> Cmd Msg
fetchDeployments jwt =
    let
        url =
            "http://localhost:8080/deployments"
    in
        Http.send NewDeployments
            (authReq
                (Just jwt)
                { defaultReqParams | url = url }
                decodeDeployments
            )



-- (Http.get url decodeDeployments)


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
