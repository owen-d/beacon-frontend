module Modules.Layout.State exposing (..)

import Modules.Layout.Types exposing (..)
import Modules.Route.Routing exposing (routeInit)
import Task
import Types exposing (Model, Msg(LayoutMsg))


updateLayout : LayoutMsg -> Model -> ( Model, Cmd Msg )
updateLayout msg model =
    let
        model2 =
            case msg of
                SelectTab route ->
                    { model | route = route }
    in
        ( model2, Task.perform routeInit (Task.succeed model2.route) )
