module Modules.Deployments.State exposing (..)

import Http
import Material
import Material.Table as Table
import Modules.Deployments.Types as DepTypes exposing (..)
import Modules.Deployments.Utils exposing (..)
import Modules.Messages.State exposing (updateMsg)
import Modules.Messages.Types exposing (Message, EditMsg(..), createMessage)
import Modules.Utils.View exposing (toggle)
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
                    toggleDep dep deployments

                Reorder field ->
                    reorder field deployments

                NewDeployments res ->
                    newDeployments res deployments

                FetchDeployments ->
                    lift DeploymentsMsg ( deployments, fetchDeployments model.jwt )

                SelectTab idx ->
                    selectTab idx deployments

                SelectMsgTab idx ->
                    selectMsgTab idx deployments

                MsgFor_EditDep msg_ ->
                    editDep msg_ deployments

                PostDeployment dep ->
                    lift DeploymentsMsg ( deployments, postDeployment model.jwt dep )

                PostDeploymentResponse msg_ ->
                    handlePostedDeployment msg_ deployments
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



{- True iff all rows are currently selected. -}


key : Deployment -> String
key =
    .name


selectMsgTab : Int -> Model -> ( Model, Cmd Types.Msg )
selectMsgTab idx model =
    { model | curMsgTab = idx } ! []


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
                    -- msg could be a Nothing
                    let
                        msgDefaults =
                            Maybe.withDefault createMessage editingDep.message
                    in
                        { editingDep | message = Just (updateMsg editMsg msgDefaults) }
    in
        { model | editingDep = updated } ! []


handlePostedDeployment : Result Http.Error Deployment -> Model -> ( Model, Cmd Types.Msg )
handlePostedDeployment res model =
    case res of
        Ok dep ->
            -- add dep to dep list
            let
                m1 =
                    { model | deployments = dep :: (.deployments model) }

                m2 =
                    { m1 | curTab = 0 }
            in
                { m2 | editingDep = blankDep } ! []

        -- add err prop to errstack
        Err e ->
            { model | deploymentsErr = Just e } ! []
