module Modules.Beacons.Utils exposing (..)

import Http
import Json.Decode as Decode
import Modules.Beacons.Types exposing (..)
import Utils exposing (..)


fetchBeacons : String -> Cmd BeaconsMsg
fetchBeacons jwt =
    let
        url =
            (++) apiUrl "/beacons"
    in
        Http.send NewBeacons
            (authReq
                jwt
                { defaultReqParams | url = url }
                decodeBeacons
            )



-- (Http.get url decodeBeacons)


decodeBeacons : Decode.Decoder Beacons
decodeBeacons =
    Decode.field "beacons"
        (Decode.list
            (Decode.map2 Beacon
                (Decode.field "name" Decode.string)
                (Decode.field "deploy_name" Decode.string)
            )
        )
