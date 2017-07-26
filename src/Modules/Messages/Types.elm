module Modules.Messages.Types exposing (..)

import Http
import Material
import Material.Table as Table


type alias Message =
    { name : String
    , title : String
    , url : String
    }


type alias Model =
    { order : Maybe Table.Order
    , orderField : OrderField
    , selected : Maybe String
    , messages : Messages
    , httpErr : Maybe Http.Error
    , mdl : Material.Model
    , curTab : Int
    , editingMsg : Message
    }


model : Model
model =
    { order = Just Table.Ascending
    , orderField = Name
    , selected = Nothing
    , messages = []
    , httpErr = Nothing
    , mdl = Material.model
    , curTab = 0
    , editingMsg = blankMsg
    }

blankMsg : Message
blankMsg =
    Message "" "" ""

type alias Messages =
    List Message


createMessage : Message
createMessage =
    { name = ""
    , title = ""
    , url = ""
    }


type OrderField
    = Name
    | Title
    | Url


type EditMsg
    = EditMsgName String
    | EditMsgTitle String
    | EditMsgUrl String


type Msg
    = Toggle Message
    | Reorder OrderField
    | NewMessages (Result Http.Error Messages)
    | FetchMessages
    | Mdl (Material.Msg Msg)
    | MsgFor_EditMsg EditMsg
    | PostMessage Message
    | PostMessageResponse (Result Http.Error Message)
