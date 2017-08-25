module Modules.Signin.Types exposing (..)

-- imports

import Http
import Material
import Modules.Storage.Local exposing (..)


type alias SigninModel =
    { mdl : Material.Model
    , state : Maybe String
    , code : Maybe String
    }


model : SigninModel
model =
    { mdl = Material.model
    , state = Nothing
    , code = Nothing
    }


type alias User =
    { id : String
    , email : String
    }


type alias UserInfo =
    { jwt : String
    , user : User
    }


jwtLocalKey : String
jwtLocalKey =
    "sharecrows-jwt"


type SigninMsg
    = Mdl (Material.Msg SigninMsg)
    | InitiateGoogleSignin
    | HandleGoogleSignin String String
    | NewUserInfo (Result Http.Error UserInfo)
    | MsgFor_LocalStorageMsg LocalStorageMsg
    | Signout
