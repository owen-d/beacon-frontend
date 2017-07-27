module Modules.Layout.State exposing (..)

import Modules.Layout.Types exposing (..)
import Modules.Messages.Types exposing (Msg(FetchMessages))
import Modules.Route.Routing exposing (routeInit)
import Modules.Route.Types exposing (..)
import Task
import Types exposing (Model, Msg(..))


updateLayout : (Types.Msg -> Model -> ( Model, Cmd Types.Msg )) -> LayoutMsg -> Model -> ( Model, Cmd Types.Msg )
updateLayout super msg model =
    -- super is the parent update fn. It allows us to do recursive calls to the parent.
    let
        model2 =
            case msg of
                SelectTab route ->
                    { model | route = route }

        otherMsgs =
            case model2.route of
                DeploymentsRoute ->
                    -- since campaigns can use existing messages, we also fetch those
                    if List.isEmpty model2.messages.messages then
                        [ MessagesMsg FetchMessages ]
                    else
                        []

                _ ->
                    []
    in
        -- if multiple msgs, send via cmd.batch, otherwise recur
        if (List.isEmpty otherMsgs) then
            super (routeInit model2.route) model2
        else
            ( model2
            , routeInit model2.route
                :: otherMsgs
                |> batchMsgs
            )


batchMsgs : List Types.Msg -> Cmd Types.Msg
batchMsgs msgs =
    List.map
        (\msg ->
            Task.perform identity <| Task.succeed <| msg
        )
        msgs
        |> Cmd.batch
