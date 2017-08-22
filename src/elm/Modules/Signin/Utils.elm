module Modules.Signin.Utils exposing (..)

-- imports

import Http exposing (jsonBody)
import Json.Decode as Decode
import Modules.Signin.Types exposing(..)
import Utils exposing (..)


signinUser : String -> String -> Cmd SigninMsg
signinUser state code =
    let
        url =
            (++) apiUrl "/auth/google/authorize"
    in
        Http.send NewUserInfo (Http.get url decodeUserInfo)


decodeUserInfo : Decode.Decoder UserInfo
decodeUserInfo =
    Decode.map2 UserInfo
        (Decode.field "jwt" Decode.string)
        (Decode.field "user" decodeUser)


decodeUser : Decode.Decoder User
decodeUser =
    Decode.map2 User
        (Decode.field "id" Decode.string)
        (Decode.field "email" Decode.string)
