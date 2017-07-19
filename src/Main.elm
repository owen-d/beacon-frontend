module Main exposing (..)

import Modules.Route.Routing exposing (parseLocation, routeInit)
import Navigation exposing (Location)
import State exposing (..)
import Types exposing (..)
import View exposing (..)


-- each dir should have: utils (async, helpers), State (update fns, etc), View (rendering logic), Types (models, etc)


init : Location -> ( Model, Cmd Msg )
init route =
    let
        model_ =
            { model | route = parseLocation route }
    in
        ( model_, routeInit model )


main : Program Never Model Msg
main =
    Navigation.program LocationChange
        { init = init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
