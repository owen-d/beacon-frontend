module State exposing (..)

-- imports

import Types exposing (..)
import Utils exposing (..)
import Material


-- state initialization


initModel : Model
initModel =
    { user = Nothing
    , beacons = []
    , jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTQzOTYzOTksImlhdCI6MTQ5ODg0NDM5OSwidXNlcl9pZCI6IjZiYTdiODEwLTlkYWQtMTFkMS04MGI0LTAwYzA0ZmQ0MzBjOCJ9._Mn0COXwcs9l4NqqAbbosXWCTMentdy4xj9ZqgKhEF0"
    , error = Nothing
    , mdl = Material.model
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchBeacons ->
            ( model, fetchBeacons model.jwt )

        NewBeacons res ->
            case res of
                Ok bkns ->
                    ( { model | beacons = bkns }, Cmd.none )

                Err e ->
                    ( { model | error = Just e }, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
