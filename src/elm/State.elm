module State exposing (..)

-- imports

import Material
import Material.Layout
import Modules.Beacons.State as BeaconState
import Modules.Deployments.State as DeploymentState
import Modules.Layout.State as LayoutState
import Modules.Messages.State as MessagesState
import Modules.Route.Types exposing (Route(..))
import Task
import Types exposing (..)


-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        Delayed msg ->
            ( model, Task.perform identity <| Task.succeed msg )

        Mdl msg_ ->
            Material.update Mdl msg_ model

        LayoutMsg msg ->
            LayoutState.updateLayout update msg model

        BeaconsMsg msg ->
            BeaconState.update msg model

        DeploymentsMsg msg ->
            DeploymentState.update msg model

        MessagesMsg msg ->
            MessagesState.update msg model

        Unauthenticated ->
            { model | route = SigninRoute } ! []



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Material.Layout.subs Mdl model.mdl
