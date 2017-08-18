module Utils exposing (..)

-- imports

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Modules.Route.Types exposing (Route(SigninRoute))
import Time
import Types


type alias ReqParams a =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect a
    , timeout : Maybe Time.Time
    , withCredentials : Bool
    }


apiUrl : String
apiUrl =
    "https://api.sharecro.ws/v1"


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



-- authReq should require a jwt, handling its existence should happen before it gets here


authReq :
    String
    -> ReqParams a
    -> Decode.Decoder b
    -> Http.Request b
authReq jwt ({ headers } as reqParams) decoder =
    let
        params =
            { reqParams | expect = Http.expectJson decoder }
    in
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



-- isLoggedIn will redirect to signin page if no jwt present, otherwise it will lazily delegate to another update


isLoggedIn : Types.Model -> (String -> ( Types.Model, Cmd Types.Msg )) -> ( Types.Model, Cmd Types.Msg )
isLoggedIn model passthrough =
    case model.jwt of
        Nothing ->
            { model | route = SigninRoute } ! []

        Just jwt ->
            passthrough jwt
