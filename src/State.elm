module State exposing (..)

-- imports

import Types exposing (..)
import Material
import Modules.Layout.State as LayoutState
import Modules.Beacons.Types as BeaconTypes
import Modules.Beacons.State as BeaconState
import Modules.Route.Routing exposing (parseLocation)


-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        Mdl msg_ ->
            Material.update Mdl msg_ model

        LocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        LayoutMsg msg ->
            LayoutState.updateLayout msg model

        BeaconsMsg msg ->
            BeaconState.update msg model



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
