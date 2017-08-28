module Modules.Deployments.State exposing (..)

import Dict exposing (Dict)
import Http
import Material
import Material.Table as Table
import Modules.Deployments.Types as DepTypes exposing (..)
import Modules.Deployments.Utils exposing (..)
import Modules.Messages.State exposing (updateMsg)
import Modules.Messages.Types exposing (Message, EditMsg(..), createMessage)
import Modules.Utils.View exposing (toggle)
import Types exposing (Msg(DeploymentsMsg))
import Utils exposing (lift, isLoggedIn, uniqAppend)


update : DepTypes.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg ({ deployments } as model) =
    let
        mapDepModel : ( DepTypes.Model, Cmd Types.Msg ) -> ( Types.Model, Cmd Types.Msg )
        mapDepModel ( depMod, cmd ) =
            ( { model | deployments = depMod }, cmd )
    in
        case msg of
            Mdl msg_ ->
                lift DeploymentsMsg (Material.update Mdl msg_ model.deployments)
                    |> mapDepModel

            -- Click on specific checkbox `idx`
            Toggle dep ->
                isLoggedIn model <|
                    \jwt -> mapDepModel <| toggleDep jwt dep deployments

            Reorder field ->
                reorder field deployments
                    |> mapDepModel

            NewDeployments res ->
                newDeployments res deployments
                    |> mapDepModel

            FetchDeployments ->
                isLoggedIn model <|
                    \jwt -> lift DeploymentsMsg ( model, fetchDeployments jwt )

            SelectTab idx ->
                selectTab idx deployments
                    |> mapDepModel

            SelectMsgTab idx ->
                selectMsgTab idx deployments
                    |> mapDepModel

            MsgFor_EditDep msg_ ->
                editDep msg_ deployments
                    |> mapDepModel

            PostDeployment dep ->
                isLoggedIn model <|
                    \jwt -> lift DeploymentsMsg ( model, postDeployment jwt dep )

            PostDeploymentResponse msg_ ->
                handlePostedDeployment msg_ deployments
                    |> mapDepModel

            DeploymentBeaconNames msg_ ->
                handleDeploymentBeacons msg_ deployments
                    |> mapDepModel


toggleDep : String -> Deployment -> Model -> ( Model, Cmd Types.Msg )
toggleDep jwt dep model =
    let
        toggled =
            toggle (key dep) model.selected

        m_ =
            { model | selected = toggled }

        cmd =
            case toggled of
                Just name ->
                    fetchDeploymentBeacons jwt dep.name
                        |> Cmd.map DeploymentsMsg

                Nothing ->
                    Cmd.none
    in
        { m_ | editingDep = dep } ! [ cmd ]


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
    let
        -- need a fn to extract bknNames into a dict: <depName, bNames>, as deployments endpoint shallowly fetches
        -- deployments metadata. This allows us to retained cached beacons.
        toDict : Deployments -> Dict String (List String)
        toDict deps =
            List.map (\dep -> ( dep.name, dep.beacons )) deps
                |> Dict.fromList
    in
        case res of
            Ok deployments ->
                let
                    bknsDict =
                        toDict model.deployments

                    depsWithBkns =
                        List.map (\dep -> { dep | beacons = Maybe.withDefault [] <| Dict.get dep.name bknsDict }) deployments
                in
                    ( { model | deployments = depsWithBkns }, Cmd.none )

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

                EditDepMsgName msg_ ->
                    { editingDep | messageName = msg_ }

                MsgFor_EditMsg editMsg ->
                    -- msg could be a Nothing
                    let
                        msgDefaults =
                            Maybe.withDefault createMessage editingDep.message

                        -- since msgname takes priority on a new campaign, we unselect any msgName from the editDep model
                        dep_1 =
                            { editingDep | messageName = Nothing }
                    in
                        { dep_1 | message = Just (updateMsg editMsg msgDefaults) }
    in
        { model | editingDep = updated } ! []


handlePostedDeployment : Result Http.Error Deployment -> Model -> ( Model, Cmd Types.Msg )
handlePostedDeployment res model =
    case res of
        Ok dep ->
            -- add dep to dep list
            let
                updatedDeps =
                    uniqAppend .name False model.deployments dep
                m1 =
                    { model | deployments = updatedDeps }

                m2 =
                    { m1 | curTab = 0 }
            in
                { m2 | editingDep = blankDep } ! []

        -- add err prop to errstack
        Err e ->
            { model | deploymentsErr = Just e } ! []


handleDeploymentBeacons : Result Http.Error ( String, List String ) -> Model -> ( Model, Cmd Types.Msg )
handleDeploymentBeacons res model =
    let
        injectBNames : String -> List String -> Deployments -> Deployments
        injectBNames name bNames deps =
            List.map
                (\bkn ->
                    if bkn.name == name then
                        { bkn | beacons = bNames }
                    else
                        bkn
                )
                deps
    in
        case res of
            Ok ( depName, bNames ) ->
                { model | deployments = injectBNames depName bNames model.deployments } ! []

            Err e ->
                { model | deploymentsErr = Just e } ! []
