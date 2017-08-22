port module Modules.Storage.Local exposing (..)

-- port for getting from local storage


port storageGet : String -> Cmd msg


port storageReceive : (( String, Maybe String ) -> msg) -> Sub msg


port storageSet : (String, String) -> Cmd msg


port storageSetReceive : (() -> msg) -> Sub msg


type LocalStorageMsg
    = Fetch String
    | Receive ( String, Maybe String )
    | Save ( String, String )
