module Modules.Deployments.State exposing (..)

import Modules.Deployments.Types as DepTypes exposing (..)
import Types


update : DepTypes.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg ({ deployments } as model) =
    let
        ( dModel, cmd ) =
            case msg of
                SetTableState newState ->
                    ( { deployments | tableState = newState }, Cmd.none )
    in
        ( { model | deployments = dModel }, cmd )
