module Modules.Messages.Types exposing (..)


type alias Message =
    { name : String
    , title : String
    , url : String
    }


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
