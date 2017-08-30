module Modules.Signin.State exposing (..)

-- imports

import Http
import Material
import Modules.Beacons.Types as BeaconTypes
import Modules.Route.Types exposing (Route(BeaconsRoute, SigninRoute))
import Modules.Signin.Types as SigninTypes exposing (..)
import Modules.Signin.Utils as SigninUtils exposing (signinUser)
import Modules.Storage.Local exposing (..)
import Navigation
import Task
import Types exposing (Msg(MsgFor_SigninMsg, None, BeaconsMsg), Model)
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

            Signout ->
                signout model


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
            { model | jwt = Just userinfo.jwt, user = Just userinfo.user, route = BeaconsRoute }
                ! [ Cmd.batch
                        [ storageSet ( jwtLocalKey, userinfo.jwt )
                        , Task.perform identity <| Task.succeed <| BeaconsMsg BeaconTypes.FetchBeacons
                        ]
                  ]

        Err e ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ storageReceive (Receive >> MsgFor_LocalStorageMsg >> MsgFor_SigninMsg)
        , storageSetReceive (always None)
        ]


signout : Model -> ( Model, Cmd Msg )
signout model =
    ( { model | jwt = Nothing, route = SigninRoute }, storageRemove jwtLocalKey )
