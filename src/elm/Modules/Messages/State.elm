module Modules.Messages.State exposing (..)

import Http
import Material
import Material.Table as Table
import Modules.Messages.Types as MsgTypes exposing (..)
import Modules.Messages.Utils exposing (..)
import Modules.Utils.View exposing (toggle)
import Types exposing (Msg(MessagesMsg), Model)
import Utils exposing (lift, isLoggedIn)


update : MsgTypes.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg ({ messages } as model) =
    let
        mapMessageModel : (MsgTypes.Model, Cmd Types.Msg) -> (Types.Model, Cmd Types.Msg)
        mapMessageModel (msgMod, cmd) =
            ({ model | messages = msgMod }, cmd)
    in
        case msg of
            Mdl msg_ ->
                lift MessagesMsg (Material.update Mdl msg_ messages)
                    |> mapMessageModel

            -- Click on specific checkbox `idx`
            Toggle msg_ ->
                toggleMsg msg_ messages
                    |> mapMessageModel

            Reorder field ->
                reorder field messages
                    |> mapMessageModel

            NewMessages res ->
                newMessages res messages
                    |> mapMessageModel

            FetchMessages ->
                isLoggedIn model <|
                    \jwt -> lift MessagesMsg ( model, fetchMessages jwt )

            MsgFor_EditMsg msg_ ->
                { messages | editingMsg = updateMsg msg_ messages.editingMsg } ! []
                    |> mapMessageModel

            PostMessage msg_ ->
                isLoggedIn model <|
                    \jwt -> lift MessagesMsg ( model, postMessage jwt msg_ )

            PostMessageResponse msg_ ->
                handlePostedMessage msg_ messages
                    |> mapMessageModel

            SelectTab idx ->
                selectTab idx messages
                    |> mapMessageModel


updateMsg : EditMsg -> Message -> Message
updateMsg updateMsg msg =
    case updateMsg of
        EditMsgName str ->
            { msg | name = str }

        EditMsgTitle str ->
            { msg | title = str }

        EditMsgUrl str ->
            { msg | url = str }


toggleMsg : Message -> MsgTypes.Model -> ( MsgTypes.Model, Cmd Types.Msg )
toggleMsg msg model =
    let
        toggled =
            toggle (key msg) model.selected

        m1 =
            { model | selected = toggled }

        -- if we just untoggled, reset editing msg to empty msg
        -- so that new msgs can be created without fields needing to be erased
    in
        if toggled == Nothing then
            { m1 | editingMsg = blankMsg } ! []
        else
            { m1 | editingMsg = msg } ! []


reorder : OrderField -> MsgTypes.Model -> ( MsgTypes.Model, Cmd Types.Msg )
reorder field model =
    {- if rotating field is currently selected, rotate it -}
    if (==) field model.orderField then
        { model | order = rotate model.order } ! []
    else
        {- otherwise, change selected field, re-initialize order & recurse -}
        reorder field { model | order = Nothing, orderField = field }


rotate : Maybe Table.Order -> Maybe Table.Order
rotate order =
    case order of
        Just Table.Ascending ->
            Just Table.Descending

        Just Table.Descending ->
            Nothing

        Nothing ->
            Just (Table.Ascending)


key : Message -> String
key =
    .name


newMessages : Result Http.Error Messages -> MsgTypes.Model -> ( MsgTypes.Model, Cmd Types.Msg )
newMessages res model =
    case res of
        Ok msgs ->
            ( { model | messages = msgs }, Cmd.none )

        Err e ->
            ( { model | httpErr = Just e }, Cmd.none )


handlePostedMessage : Result Http.Error Message -> MsgTypes.Model -> ( MsgTypes.Model, Cmd Types.Msg )
handlePostedMessage res model =
    case res of
        Ok msg ->
            -- add dep to dep list
            let
                m_ =
                    { model | messages = msg :: (.messages model) }
            in
                { m_ | editingMsg = blankMsg } ! []

        -- add err prop to errstack
        Err e ->
            { model | httpErr = Just e } ! []


selectTab : Int -> MsgTypes.Model -> ( MsgTypes.Model, Cmd Types.Msg )
selectTab idx model =
    ( { model | curTab = idx }, Cmd.none )
