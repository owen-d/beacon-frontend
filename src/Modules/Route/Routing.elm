module Modules.Route.Routing exposing (..)

import Modules.Beacons.Utils exposing (fetchBeacons)
import Modules.Deployments.Utils exposing (fetchDeployments)
import Modules.Route.Types exposing (..)
import Navigation exposing (Location)
import Types exposing (Model, Msg(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map BeaconsRoute top
        , map BeaconsRoute (s "beacons")
        , map MessagesRoute (s "messages")
        , map DeploymentsRoute (s "deployments")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parsePath matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


routeInit : Model -> Cmd Msg
routeInit ({ route } as model) =
    case route of
        BeaconsRoute ->
            fetchBeacons model.jwt |> Cmd.map BeaconsMsg

        MessagesRoute ->
            Cmd.none

        DeploymentsRoute ->
            fetchDeployments model.jwt |> Cmd.map DeploymentsMsg

        NotFoundRoute ->
            Cmd.none

handleRouteChange : Model -> Route -> ( Model, Cmd Msg )
handleRouteChange model newRoute =
    let
        model_ =
            { model | route = newRoute }
    in
        ( model_, routeInit model_ )
