module State exposing (..)

-- imports

import Material
import Modules.Beacons.State as BeaconState
import Modules.Layout.State as LayoutState
import Modules.Route.Routing exposing (parseLocation)
import Types exposing (..)


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
