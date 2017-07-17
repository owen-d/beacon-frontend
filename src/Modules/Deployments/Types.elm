module Modules.Deployments.Types exposing (..)

import Table as SortTable


type alias Model =
    { deployments : Deployments
    , tableState : SortTable.State
    }


type alias Deployment =
    { userId : String
    , deployName : String
    , messageName : String
    , beacons : List String
    }


type alias Deployments =
    List Deployment


model : Model
model =
    { deployments = testDeployments
    , tableState = SortTable.initialSort "deployName"
    }


type Msg
    = SetTableState SortTable.State


testDeployments : Deployments
testDeployments =
    [ { userId = "a", deployName = "dep1", messageName = "msg1", beacons = [] }, { userId = "a", deployName = "dep2", messageName = "msg2", beacons = [] } ]
