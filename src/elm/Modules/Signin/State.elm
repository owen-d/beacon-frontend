module Modules.Signin.State exposing (..)

-- imports

import Material
import Modules.Signin.Types as SigninTypes exposing (..)
import Modules.Storage.Local exposing (..)
import Navigation
import Types exposing (Msg(MsgFor_SigninMsg, None), Model)
import Utils exposing (lift, isLoggedIn, apiUrl)


initGoogleSigninEndpoint : String
initGoogleSigninEndpoint =
    (++) apiUrl "/auth/google/init"


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
                ( model, Navigation.load initGoogleSigninEndpoint )

            HandleGoogleSignin state code ->
                model ! []

            MsgFor_LocalStorageMsg msg_ ->
                handleLocalStorageMsg msg_ model


handleLocalStorageMsg : LocalStorageMsg -> Model -> ( Model, Cmd Msg )
handleLocalStorageMsg msg model =
    case msg of
        Fetch key ->
            ( model, storageGet key )

        Receive ( key, box ) ->
            if key == jwtLocalKey then
                { model | jwt = box } ! []
            else
                model ! []

        Save ( key, val ) ->
            ( model, storageSet ( key, val ) )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ storageReceive (Receive >> MsgFor_LocalStorageMsg >> MsgFor_SigninMsg)
        , storageSetReceive (always None)
        ]
