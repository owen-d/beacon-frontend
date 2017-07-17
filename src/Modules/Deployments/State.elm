module Modules.Deployments.State exposing (..)

import Http
import Material
import Material.Table as Table
import Modules.Deployments.Types as DepTypes exposing (..)
import Modules.Deployments.Utils exposing (..)
import Set exposing (Set)
import Types exposing (Msg(DeploymentsMsg))
import Utils exposing (lift)


update : DepTypes.Msg -> Types.Model -> ( Types.Model, Cmd Types.Msg )
update msg ({ deployments } as model) =
    let
        ( dModel, cmd ) =
            case msg of
                Mdl msg_ ->
                    lift DeploymentsMsg (Material.update Mdl msg_ model.deployments)

                -- Click on master checkbox
                ToggleAll ->
                    toggleAll model.deployments

                -- Click on specific checkbox `idx`
                Toggle idx ->
                    toggleDep idx model.deployments

                Reorder field ->
                    reorder field model.deployments

                NewDeployments res ->
                    newDeployments res model.deployments

                FetchDeployments ->
                    lift DeploymentsMsg (model.deployments, fetchDeployments model.jwt)
    in
        ( { model | deployments = dModel }, cmd )



toggleAll : Model -> ( Model, Cmd Types.Msg )
toggleAll model =
    { model
        | selected =
            if allSelected model then
                Set.empty
            else
                List.map .name model.deployments |> Set.fromList
    }
        ! []


toggleDep : String -> Model -> ( Model, Cmd Types.Msg )
toggleDep idx model =
    { model | selected = toggle idx model.selected } ! []


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


toggle : comparable -> Set comparable -> Set comparable
toggle x set =
    if Set.member x set then
        Set.remove x set
    else
        Set.insert x set



{- True iff all rows are currently selected. -}


allSelected : Model -> Bool
allSelected model =
    let
        ln =
            List.length model.deployments
    in
        (Set.size model.selected == ln) && ((/=) ln 0)


key : Deployment -> String
key =
    .name
