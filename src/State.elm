module State exposing (..)

-- imports

import Types exposing (..)
import Material
import Modules.Layout.State as LayoutState
import Modules.Beacons.Types as BeaconTypes
import Modules.Beacons.State as BeaconState


-- state initialization


initModel : Model
initModel =
    { user = Nothing
    , beacons = BeaconTypes.model
    , jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTQzOTYzOTksImlhdCI6MTQ5ODg0NDM5OSwidXNlcl9pZCI6IjZiYTdiODEwLTlkYWQtMTFkMS04MGI0LTAwYzA0ZmQ0MzBjOCJ9._Mn0COXwcs9l4NqqAbbosXWCTMentdy4xj9ZqgKhEF0"
    , mdl = Material.model
    , layout = { selectedTab = 0 }
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        Mdl msg_ ->
            Material.update Mdl msg_ model

        LayoutMsg msg ->
            LayoutState.updateLayout msg model

        BeaconsMsg msg ->
            BeaconState.update msg model



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
