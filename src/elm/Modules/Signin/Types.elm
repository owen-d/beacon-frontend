module Modules.Signin.Types exposing (..)

-- imports

import Material


type alias SigninModel =
    { mdl : Material.Model }


model : SigninModel
model =
    { mdl = Material.model }


type SigninMsg
    = Mdl (Material.Msg SigninMsg)
    | InitiateGoogleSignin
