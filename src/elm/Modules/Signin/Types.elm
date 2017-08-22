module Modules.Signin.Types exposing (..)

-- imports

import Material
import Modules.Storage.Local exposing(..)


type alias SigninModel =
    { mdl : Material.Model }

jwtLocalKey : String
jwtLocalKey =
    "sharecrows-jwt"

model : SigninModel
model =
    { mdl = Material.model }


type SigninMsg
    = Mdl (Material.Msg SigninMsg)
    | InitiateGoogleSignin
    | HandleGoogleSignin String String
    | MsgFor_LocalStorageMsg LocalStorageMsg
