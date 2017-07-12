module Modules.Beacons.Utils exposing (..)

import Types exposing (Msg)
import Modules.Beacons.Types exposing (..)
import Utils exposing (..)
import Http
import Json.Decode as Decode

fetchBeacons : String -> Cmd BeaconsMsg
fetchBeacons jwt =
    let
        url =
            "http://localhost:8080/beacons"
    in
        Http.send NewBeacons
            (authReq
                (Just jwt)
                { defaultReqParams | url = url }
                decodeBeacons
            )



-- (Http.get url decodeBeacons)


decodeBeacons : Decode.Decoder Beacons
decodeBeacons =
    Decode.field "beacons"
        (Decode.list
            (Decode.map3 Beacon
                (Decode.field "name" Decode.string)
                (Decode.field "user_id" Decode.string)
                (Decode.field "deploy_name" Decode.string)
            )
        )
