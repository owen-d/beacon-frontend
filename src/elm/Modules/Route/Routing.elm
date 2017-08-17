module Modules.Route.Routing exposing (..)

import Modules.Beacons.Types exposing (BeaconsMsg(FetchBeacons))
import Modules.Deployments.Types as DepTypes exposing (Msg(FetchDeployments))
import Modules.Layout.Types exposing (LayoutMsg(SelectTab))
import Modules.Messages.Types as MsgTypes exposing (Msg(FetchMessages))
import Modules.Route.Types exposing (..)
import Navigation exposing (Location)
import RouteUrl exposing (..)
import Types exposing (Model, Msg(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map BeaconsRoute top
        , map BeaconsRoute (s "beacons")
        , map MessagesRoute (s "messages")
        , map DeploymentsRoute (s "deployments")
        , map SigninRoute (s "signin")
        ]



-- routeInit returns a Msg instead of a Cmd msg, to be used with RouteUrl's location2messages signature


routeInit : Route -> Types.Msg
routeInit route =
    case route of
        BeaconsRoute ->
            BeaconsMsg FetchBeacons

        MessagesRoute ->
            MessagesMsg FetchMessages

        DeploymentsRoute ->
            DeploymentsMsg FetchDeployments

        SigninRoute ->
            None
        NotFoundRoute ->
            None



-- recieve new & old models & indicate potential url change
-- this allows us to map state changing actions to model state, & subsequently
-- change the url to match


delta2url : Model -> Model -> Maybe UrlChange
delta2url model1 model2 =
    if model1.route /= model2.route then
        -- gen new path component
        { entry = RouteUrl.NewEntry
        , url = urlOf model2
        }
            |> Just
    else
        Nothing



-- receive manual url changes & return msgs associated


location2messages : Location -> List Types.Msg
location2messages loc =
    case (parsePath matchers loc) of
        Just route ->
            routeInit route :: []

        Nothing ->
            -- routeInit BeaconsRoute :: []
            SelectTab BeaconsRoute
                |> LayoutMsg
                |> Delayed
                |> \a -> a :: []


urlOf : Model -> String
urlOf { route } =
    "/"
        ++ case route of
            BeaconsRoute ->
                "beacons"

            MessagesRoute ->
                "messages"

            DeploymentsRoute ->
                "campaigns"

            NotFoundRoute ->
                ""

            SigninRoute ->
                "signin"
