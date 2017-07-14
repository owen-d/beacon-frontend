module Modules.Route.Routing exposing (..)

import Modules.Route.Types exposing (..)
import Navigation exposing (Location)
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
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

