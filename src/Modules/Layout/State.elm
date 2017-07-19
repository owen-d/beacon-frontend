module Modules.Layout.State exposing (..)

import Modules.Layout.Types exposing (..)
import Modules.Route.Routing exposing (handleRouteChange)
import Types exposing (Model, Msg(LayoutMsg))


updateLayout : LayoutMsg -> Model -> ( Model, Cmd Msg )
updateLayout msg model =
    case msg of
        SelectTab route ->
            handleRouteChange model route
