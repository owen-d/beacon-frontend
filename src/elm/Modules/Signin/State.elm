module Modules.Signin.State exposing (..)

-- imports

import Http
import Material
import Modules.Route.Types exposing (Route(BeaconsRoute))
import Modules.Signin.Types as SigninTypes exposing (..)
import Modules.Signin.Utils as SigninUtils exposing (signinUser)
import Modules.Storage.Local exposing (..)
import Navigation
import Types exposing (Msg(MsgFor_SigninMsg, None), Model)
import Utils exposing (lift, isLoggedIn, apiUrl)


initGoogleSigninEndpoint : String
initGoogleSigninEndpoint =
    (++) apiUrl "/auth/google/init"


update : SigninMsg -> Model -> ( Model, Cmd Msg )
update msg ({ signin } as model) =
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
                lift MsgFor_SigninMsg ( { signin | state = Just state, code = Just code }, signinUser state code )
                    |> mapModel

            MsgFor_LocalStorageMsg msg_ ->
                handleLocalStorageMsg msg_ model

            NewUserInfo msg_ ->
                newUserInfo msg_ model


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


newUserInfo : Result Http.Error UserInfo -> Model -> ( Model, Cmd Msg )
newUserInfo res model =
    case res of
        Ok userinfo ->
            ({ model | jwt = Just userinfo.jwt, user = Just userinfo.user, route = BeaconsRoute }, storageSet (jwtLocalKey, userinfo.jwt))

        Err e ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ storageReceive (Receive >> MsgFor_LocalStorageMsg >> MsgFor_SigninMsg)
        , storageSetReceive (always None)
        ]
