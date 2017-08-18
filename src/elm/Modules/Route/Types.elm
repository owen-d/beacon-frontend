module Modules.Route.Types exposing (..)


type Route
    = BeaconsRoute
    | MessagesRoute
    | DeploymentsRoute
    | NotFoundRoute
    | SigninRoute
    | GoogleAuthorizeRoute (Maybe String) (Maybe String)
