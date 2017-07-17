module Modules.Deployments.Types exposing (..)

import Http
import Material
import Material.Table as Table
import Set exposing (Set)


type alias Model =
    { order : Maybe Table.Order
    , orderField : OrderField
    , selected : Set String
    , deployments : Deployments
    , deploymentsErr : Maybe Http.Error
    , mdl : Material.Model
    , curTab : Int
    , editingDeployment : Maybe Deployment
    }


type OrderField
    = DName
    | DMessage


type alias Deployment =
    { userId : String
    , name : String
    , messageName : String
    , beacons : List String
    }


type alias Message =
    { name : String
    , title : String
    , url : String
    , lang : String
    }


type alias Deployments =
    List Deployment


model : Model
model =
    { order = Just Table.Ascending
    , orderField = DName
    , selected = Set.empty
    , deployments = []
    , deploymentsErr = Nothing
    , mdl = Material.model
    , curTab = 0
    , editingDeployment = Nothing
    }


type Msg
    = Toggle String
    | ToggleAll
    | Reorder OrderField
    | NewDeployments (Result Http.Error Deployments)
    | FetchDeployments
    | Mdl (Material.Msg Msg)
    | SelectTab Int
