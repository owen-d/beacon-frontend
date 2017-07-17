module Types exposing (..)

-- imports

import Material
import Modules.Beacons.Types as BeaconTypes exposing (BeaconsMsg, BeaconsModel)
import Modules.Deployments.Types as Deployments
import Modules.Layout.Types exposing (LayoutMsg)
import Modules.Route.Types exposing (Route(BeaconsRoute))
import Navigation exposing (Location)


type alias Model =
    { user : Maybe User
    , beacons : BeaconsModel
    , jwt : String
    , mdl : Material.Model
    , route : Route
    , deployments : Deployments.Model
    }


model : Model
model =
    { user = Nothing
    , beacons = BeaconTypes.model
    , jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTQzOTYzOTksImlhdCI6MTQ5ODg0NDM5OSwidXNlcl9pZCI6IjZiYTdiODEwLTlkYWQtMTFkMS04MGI0LTAwYzA0ZmQ0MzBjOCJ9._Mn0COXwcs9l4NqqAbbosXWCTMentdy4xj9ZqgKhEF0"
    , mdl = Material.model
    , route = BeaconsRoute
    , deployments = Deployments.model
    }



type alias User =
    { id : String
    , email : String
    }



-- state updates


type
    Msg
    -- None type is defined but doesnt cause any updates. It lets us piggyback on type assertions that require `Html Msg`
    = None
      -- material design types
    | Mdl (Material.Msg Msg)
      -- layout types
    | LayoutMsg LayoutMsg
    | BeaconsMsg BeaconsMsg
    | LocationChange Location
    | DeploymentsMsg Deployments.Msg
