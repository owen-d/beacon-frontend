module Modules.Beacons.State exposing (..)

import Http
import Material
import Material.Table as Table
import Modules.Beacons.Types as BeaconTypes exposing (..)
import Modules.Beacons.Utils exposing (..)
import Modules.Deployments.Types as DepTypes
import Modules.Route.Types exposing (Route(..))
import Set exposing (Set)
import Types exposing (Model, Msg(BeaconsMsg, DeploymentsMsg))
import Utils exposing (lift, isLoggedIn, batchMsgs)


update : BeaconsMsg -> Model -> ( Model, Cmd Msg )
update msg ({ beacons } as model) =
    case msg of
        Mdl msg_ ->
            let
                ( bModel, bMsg ) =
                    Material.update Mdl msg_ beacons
            in
                ( { model | beacons = bModel }, Cmd.map BeaconsMsg bMsg )

        -- Click on master checkbox
        ToggleAll ->
            { model | beacons = toggleAll beacons } ! []

        -- Click on specific checkbox `idx`
        Toggle idx ->
            { model | beacons = toggleBkn idx beacons } ! []

        Reorder field ->
            { model | beacons = reorder field beacons } ! []

        NewBeacons res ->
            let
                ( beacons_, msg ) =
                    newBeacons res beacons
            in
                ( { model | beacons = beacons_ }, msg )

        FetchBeacons ->
            isLoggedIn model <|
                \jwt -> (lift BeaconsMsg (model, fetchBeacons jwt))

        NewDeployment bknNames ->
            newDeployment model


toggleAll : BeaconsModel -> BeaconsModel
toggleAll model =
    { model
        | selected =
            if allSelected model then
                Set.empty
            else
                List.map .name model.beacons |> Set.fromList
    }


toggleBkn : String -> BeaconsModel -> BeaconsModel
toggleBkn idx model =
    { model | selected = toggle idx model.selected }


reorder : OrderField -> BeaconsModel -> BeaconsModel
reorder field model =
    {- if rotating field is currently selected, rotate it -}
    if (==) field model.orderField then
        { model | order = rotate model.order }
    else
        {- otherwise, change selected field, re-initialize order & recurse -}
        reorder field { model | order = Nothing, orderField = field }


newBeacons : Result Http.Error Beacons -> BeaconsModel -> ( BeaconsModel, Cmd Msg )
newBeacons res model =
    case res of
        Ok bkns ->
            ( { model | beacons = bkns }, Cmd.none )

        Err e ->
            ( { model | beaconsErr = Just e }, Cmd.none )


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


allSelected : BeaconsModel -> Bool
allSelected model =
    let
        ln =
            List.length model.beacons
    in
        (Set.size model.selected == ln) && ((/=) ln 0)


key : Beacon -> String
key =
    .name


newDeployment : Model -> ( Model, Cmd Msg )
newDeployment ({ beacons, deployments } as model) =
    let
        deps =
            { deployments | curTab = 0 }

        model_ =
            { model | deployments = deps }
    in
        -- change route to edit dep page
        ({ model_ | route = DeploymentsRoute }, batchMsgs [DeploymentsMsg DepTypes.FetchDeployments])
