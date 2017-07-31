module Main exposing (..)

import Material
import Material.Layout as Layout
import Modules.Route.Routing exposing (delta2url, location2messages)
import RouteUrl
import State exposing (..)
import Types exposing (..)
import View exposing (..)


-- each dir should have: utils (async, helpers), State (update fns, etc), View (rendering logic), Types (models, etc)


main : RouteUrl.RouteUrlProgram Never Model Msg
main =
    RouteUrl.program
        { init = init
        , delta2url = delta2url
        , location2messages = location2messages
        , update = State.update
        , subscriptions = Material.subscriptions Mdl
        , view = View.view
        }


init : ( Model, Cmd Msg )
init =
    ( { model | mdl = Layout.setTabsWidth 873 model.mdl }, Cmd.batch [ Layout.sub0 Mdl ] )
