module Modules.Signin.State exposing (..)

-- imports

import Material
import Modules.Signin.Types as SigninTypes exposing (..)
import Types exposing (Msg(MsgFor_SigninMsg), Model)
import Utils exposing (lift, isLoggedIn)


update : SigninMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        mapModel : ( SigninModel, Cmd Msg ) -> ( Model, Cmd Msg )
        mapModel ( signinMod, cmd ) =
            ( { model | signin = signinMod }, cmd )
    in
        case msg of
            Mdl msg_ ->
                lift MsgFor_SigninMsg (Material.update Mdl msg_ model.signin)
                    |> mapModel

            InitiateGoogleSignin ->
                model ! []
