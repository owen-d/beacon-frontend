module Modules.Deployments.State exposing (..)

import Http
import Material
import Material.Table as Table
import Modules.Deployments.Types as DepTypes exposing (..)
import Modules.Deployments.Utils exposing (..)
import Modules.Messages.Types exposing (Message, EditMsg(..), createMessage)
import Types exposing (Msg(DeploymentsMsg))
import Utils exposing (lift)


update : DepTypes.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg ({ deployments } as model) =
    let
        ( dModel, cmd ) =
            case msg of
                Mdl msg_ ->
                    lift DeploymentsMsg (Material.update Mdl msg_ model.deployments)

                -- Click on specific checkbox `idx`
                Toggle dep ->
                    toggleDep dep model.deployments

                Reorder field ->
                    reorder field model.deployments

                NewDeployments res ->
                    newDeployments res model.deployments

                FetchDeployments ->
                    lift DeploymentsMsg ( model.deployments, fetchDeployments model.jwt )

                SelectTab idx ->
                    selectTab idx model.deployments

                MsgFor_EditDep msg_ ->
                    editDep msg_ model.deployments

                PostDeployment dep ->
                    lift DeploymentsMsg ( deployments, postDeployment model.jwt dep )

                PostDeploymentResponse msg_ ->
                    handlePostedDeployment msg_ model.deployments
    in
        ( { model | deployments = dModel }, cmd )


toggleDep : Deployment -> Model -> ( Model, Cmd Types.Msg )
toggleDep dep model =
    let
        m_ =
            { model | selected = toggle (key dep) model.selected }
    in
        { m_ | editingDep = dep } ! []


reorder : OrderField -> Model -> ( Model, Cmd Types.Msg )
reorder field model =
    {- if rotating field is currently selected, rotate it -}
    if (==) field model.orderField then
        { model | order = rotate model.order } ! []
    else
        {- otherwise, change selected field, re-initialize order & recurse -}
        reorder field { model | order = Nothing, orderField = field }


newDeployments : Result Http.Error Deployments -> Model -> ( Model, Cmd Types.Msg )
newDeployments res model =
    case res of
        Ok deployments ->
            ( { model | deployments = deployments }, Cmd.none )

        Err e ->
            ( { model | deploymentsErr = Just e }, Cmd.none )


rotate : Maybe Table.Order -> Maybe Table.Order
rotate order =
    case order of
        Just Table.Ascending ->
            Just Table.Descending

        Just Table.Descending ->
            Nothing

        Nothing ->
            Just (Table.Ascending)



{- Toggle whether or not a set `set` contains an element `x`. -}


toggle : comparable -> Maybe comparable -> Maybe comparable
toggle new selected =
    case selected of
        Just old ->
            -- toggle off
            if old == new then
                Nothing
                -- set new dep
            else
                Just new

        -- if none selected, set new dep
        Nothing ->
            Just new



{- True iff all rows are currently selected. -}


key : Deployment -> String
key =
    .name


selectTab : Int -> Model -> ( Model, Cmd Types.Msg )
selectTab idx model =
    ( { model | curTab = idx }, Cmd.none )


editDep : EditDep -> Model -> ( Model, Cmd Types.Msg )
editDep msg ({ editingDep } as model) =
    let
        updated =
            case msg of
                EditDepName str ->
                    { editingDep | name = str }

                EditDepMsgName str ->
                    { editingDep | messageName = Just str }

                MsgFor_EditMsg editMsg ->
                    { editingDep | message = Just (updateMsg editMsg editingDep.message) }
    in
        { model | editingDep = updated } ! []


updateMsg : EditMsg -> Maybe Message -> Message
updateMsg updateMsg msg =
    -- msg could be a Nothing
    let
        msgDefaults =
            Maybe.withDefault createMessage msg
    in
        case updateMsg of
            EditMsgName str ->
                { msgDefaults | name = str }

            EditMsgTitle str ->
                { msgDefaults | title = str }

            EditMsgUrl str ->
                { msgDefaults | url = str }


handlePostedDeployment : Result Http.Error Deployment -> Model -> ( Model, Cmd Types.Msg )
handlePostedDeployment res model =
    case res of
        Ok dep ->
            -- add dep to dep list
            let
                m_ =
                    { model | deployments = dep :: (.deployments model) }
            in
                { m_ | editingDep = blankDep } ! []

        -- add err prop to errstack
        Err e ->
            { model | deploymentsErr = Just e } ! []
