module Main exposing (..)

import Material
import Material.Layout as Layout
import Modules.Route.Routing exposing (delta2url, location2messages)
import Modules.Signin.State as SigninState
import RouteUrl
import State exposing (..)
import Types exposing (..)
import View exposing (..)


-- each dir should have: utils (async, helpers), State (update fns, etc), View (rendering logic), Types (models, etc)


main : RouteUrl.RouteUrlProgram Flags Model Msg
main =
    RouteUrl.programWithFlags
        { init = init
        , delta2url = delta2url
        , location2messages = location2messages
        , update = State.update
        , subscriptions = subs
        , view = View.view
        }


init : Flags -> ( Model, Cmd Msg )
init ({ jwt } as flags) =
    ( { model | jwt = jwt, mdl = Layout.setTabsWidth 873 model.mdl }, Cmd.batch [ Layout.sub0 Mdl ] )


subs : Model -> Sub Msg
subs model =
    Sub.batch
        [ Material.subscriptions Mdl model
        , SigninState.subscriptions model
        ]
