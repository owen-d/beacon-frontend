module Modules.Messages.Types exposing (..)

import Http


type alias Message =
    { name : String
    , title : String
    , url : String
    }


type alias Messages =
    List Message


createMessage : Message
createMessage =
    { name = ""
    , title = ""
    , url = ""
    }


type EditMsg
    = EditMsgName String
    | EditMsgTitle String
    | EditMsgUrl String


type Msg
    = NewMessages (Result Http.Error Messages)
    | PostMessage Message
    | PostMessageResponse (Result Http.Error Message)
