module Modules.Signin.Utils exposing (..)

-- imports

import Http exposing (jsonBody)
import Json.Decode as Decode
import Modules.Signin.Types exposing (..)
import QueryString exposing (empty, add, render)
import Utils exposing (..)


signinUser : String -> String -> Cmd SigninMsg
signinUser state code =
    let
        baseUrl =
            (++) apiUrl "/auth/google/authorize"

        url =
            empty
                |> add "state" state
                |> add "code" code
                |> render
                |> (++) baseUrl
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
