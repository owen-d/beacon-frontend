module Modules.Beacons.Types exposing (..)

import Http
import Material
import Material.Table as Table
import Set exposing (Set)


type alias BeaconsModel =
    { order : Maybe Table.Order
    , orderField : OrderField
    , selected : Set String
    , beacons : Beacons
    , beaconsErr : Maybe Http.Error
    , mdl : Material.Model
    }


type OrderField
    = BName
    | BEnabled
    | BDeployment


type alias Beacon =
    { name : String
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
    , mdl = Material.model
    }


type BeaconsMsg
    = Toggle String
    | ToggleAll
    | Reorder OrderField
    | NewBeacons (Result Http.Error Beacons)
    | FetchBeacons
    | NewDeployment (Set String)
    | Mdl (Material.Msg BeaconsMsg)
