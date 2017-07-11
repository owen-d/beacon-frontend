module Lib.Layout.State exposing (..)

import Types exposing (Model, Msg(LayoutMsg))
import Lib.Layout.Types exposing (..)


updateLayout : LayoutMsg -> Model -> (Model, Cmd Msg)
updateLayout msg model =
    case msg of
        SelectTab num ->
            let
                _ = Debug.log "SelectTab: " num
            in
                model ! []
