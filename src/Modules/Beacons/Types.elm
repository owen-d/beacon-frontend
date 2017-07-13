module Modules.Beacons.Types exposing (..)

import Http
import Set exposing (Set)
import Material.Table as Table


type alias BeaconsModel =
    { order : Maybe Table.Order
    , orderField : OrderField
    , selected : Set String
    , beacons : Beacons
    , beaconsErr : Maybe Http.Error
    }


type OrderField
    = BName
    | BEnabled
    | BDeployment


type alias Beacon =
    { name : String
    , userId : String
    , deployName : String
    }


type alias Beacons =
    List Beacon


model : BeaconsModel
model =
    { order = Just Table.Ascending
    , orderField = BName
    , selected = Set.empty
    , beacons = []
    , beaconsErr = Nothing
    }


type BeaconsMsg
    = Toggle String
    | ToggleAll
    | Reorder OrderField
    | NewBeacons (Result Http.Error Beacons)
    | FetchBeacons
