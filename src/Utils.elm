module Utils exposing (..)

-- imports

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Time


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



{- lift will map a val like (model, cmd a) -> (model, cmd b) -}


lift : (a -> b) -> ( m, Cmd a ) -> ( m, Cmd b )
lift mapper ( model, cmd ) =
    ( model, Cmd.map mapper cmd )



-- Decoder util for optional fields


maybeDecode : List ( String, Maybe Encode.Value ) -> List ( String, Encode.Value )
maybeDecode col =
    col
        |> List.filterMap
            (\( field, val ) ->
                case val of
                    Just x ->
                        Just ( field, x )

                    Nothing ->
                        Nothing
            )
