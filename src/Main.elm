module App exposing (main)

import Html
import Types exposing (..)
import State exposing (..)
import View exposing (..)

-- each dir should have: utils (async, helpers), State (update fns, etc), View (rendering logic), Types (models, etc)


main : Program Never Model Msg
main =
    Html.program
        { init = State.init
        , update = State.update
        , subscriptions = State.subscriptions
        , view = View.view
        }
