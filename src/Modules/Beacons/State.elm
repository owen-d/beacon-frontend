module Modules.Beacons.State exposing (..)

import Types exposing (Model, Msg(..))
import Modules.Beacons.Types exposing (..)
import Modules.Beacons.Utils exposing (..)
import Material.Table as Table
import Set exposing (Set)
import Http


update : BeaconsMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( bModel, cmd ) =
            case msg of
                -- Click on master checkbox
                ToggleAll ->
                    toggleAll model.beacons

                -- Click on specific checkbox `idx`
                Toggle idx ->
                    toggleBkn idx model.beacons

                Reorder field ->
                    reorder field model.beacons

                NewBeacons res ->
                    newBeacons res model.beacons

                FetchBeacons ->
                    ( model.beacons
                    , fetchBeacons model.jwt
                        -- enclose BeaconsMsg as Msg variant BeaconsMsg (same name)
                        |> Cmd.map (\x -> BeaconsMsg x)
                    )
    in
        ( { model | beacons = bModel }, cmd )


toggleAll : BeaconsModel -> ( BeaconsModel, Cmd Msg )
toggleAll model =
    { model
        | selected =
            if allSelected model then
                Set.empty
            else
                List.map .name model.beacons |> Set.fromList
    }
        ! []


toggleBkn : String -> BeaconsModel -> ( BeaconsModel, Cmd Msg )
toggleBkn idx model =
    { model | selected = toggle idx model.selected } ! []


reorder : OrderField -> BeaconsModel -> ( BeaconsModel, Cmd Msg )
reorder field model =
    {- if rotating field is currently selected, rotate it -}
    if (==) field model.orderField then
        { model | order = rotate model.order } ! []
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
    Set.size model.selected == List.length model.beacons
