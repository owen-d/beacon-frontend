module Main exposing (..)

import Modules.Route.Routing exposing (parseLocation, handleRouteChange)
import Navigation
import State exposing (..)
import Types exposing (..)
import View exposing (..)

-- each dir should have: utils (async, helpers), State (update fns, etc), View (rendering logic), Types (models, etc)



main : Program Never Model Msg
main =
    Navigation.program LocationChange
        { init = handleRouteChange model << parseLocation
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
