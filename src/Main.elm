module Main exposing (..)

import Material
import Material.Layout as Layout
import Modules.Route.Routing exposing (parseLocation, handleRouteChange)
import Navigation exposing (Location)
import State exposing (..)
import Types exposing (..)
import View exposing (..)


-- each dir should have: utils (async, helpers), State (update fns, etc), View (rendering logic), Types (models, etc)


main : Program Never Model Msg
main =
    Navigation.program LocationChange
        { init = handleRouteChange model << parseLocation
        , update = State.update
        , subscriptions = Material.subscriptions Mdl
        , view = View.view
        }


init : Location -> ( Model, Cmd Msg )
init loc =
    let
        ( mod, cmd ) =
            handleRouteChange model <| parseLocation loc
    in
        ( { mod | mdl = Layout.setTabsWidth 873 mod.mdl }, Cmd.batch [ cmd, Layout.sub0 Mdl ] )
