module Utils exposing (..)

-- imports

import Http
import Types exposing (..)
import Time
import Json.Decode as Decode


fetchBeacons : String -> Cmd Msg
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


type alias ReqParams a =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect a
    , timeout : Maybe Time.Time
    , withCredentials : Bool
    }


defaultReqParams : ReqParams String
defaultReqParams =
    { method = "GET"
    , headers = []
    , url = ""
    , body = Http.emptyBody
    , expect = Http.expectString
    , timeout = Just (Time.minute * 30)
    , withCredentials = False
    }


authReq :
    Maybe String
    -> ReqParams a
    -> Decode.Decoder b
    -> Http.Request b
authReq token ({ headers } as reqParams) decoder =
    let
        params =
            { reqParams | expect = Http.expectJson decoder }
    in
        case token of
            Nothing ->
                Http.request params

            Just jwt ->
                Http.request { params | headers = (List.append headers [ (Http.header "x-jwt" jwt) ]) }


inject : (a -> b) -> (b -> c) -> a -> c
inject subTypeCtor superTypeCtor msg =
    subTypeCtor msg
        |> superTypeCtor
