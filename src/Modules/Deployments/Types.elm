module Modules.Deployments.Types exposing (..)

import Http
import Material
import Material.Table as Table
import Modules.Messages.Types exposing (Message, createMessage, EditMsg(..))


type alias Model =
    { order : Maybe Table.Order
    , orderField : OrderField
    , selected : Maybe String
    , deployments : Deployments
    , deploymentsErr : Maybe Http.Error
    , mdl : Material.Model
    , curTab : Int
    , editingDep : Deployment
    }


type OrderField
    = DName
    | DMessage


type EditDep
    = EditDepName String
    | EditDepMsgName String
    | MsgFor_EditMsg EditMsg


type alias Deployment =
    { name : String
    , messageName : Maybe String
    , beacons : List String
    , message : Maybe Message
    }


type alias Deployments =
    List Deployment


model : Model
model =
    { order = Just Table.Ascending
    , orderField = DName
    , selected = Nothing
    , deployments = []
    , deploymentsErr = Nothing
    , mdl = Material.model
    , curTab = 0
    , editingDep = blankDep
    }


blankDep : Deployment
blankDep =
    Deployment "" Nothing [] Nothing

type Msg
    = Toggle Deployment
    | Reorder OrderField
    | NewDeployments (Result Http.Error Deployments)
    | FetchDeployments
    | Mdl (Material.Msg Msg)
    | SelectTab Int
    | MsgFor_EditDep EditDep
    | PostedDeployment (Result Http.Error Deployment)
