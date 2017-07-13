module Modules.Beacons.View exposing (..)

import Modules.Beacons.Types exposing (..)
import Modules.Beacons.State exposing (..)
import Material.Table as Table
import Material.Options as Options exposing (nop, when)
import Material.Button as Button
import Material.Toggles as Toggles
import Html exposing (..)
import Html.Attributes exposing (style)
import Types exposing (Msg(Mdl, BeaconsMsg), Model)
import Components.Prefixes exposing (prefixes)
import Set exposing (Set)


viewBeaconTable : List Int -> Model -> Html Msg
viewBeaconTable prefix model =
    let
        bModel =
            model.beacons

        comparer : (Order -> Order) -> Beacon -> Beacon -> Order
        comparer =
            case model.beacons.orderField of
                BName ->
                    (\mapper a b -> compare (.name a) (.name b) |> mapper)

                -- tmp hack until we implement this field
                BEnabled ->
                    (\mapper a b -> EQ)

                BDeployment ->
                    (\mapper a b -> compare (.deployName a) (.deployName b) |> mapper)

        sorter =
            case model.beacons.order of
                Just Table.Ascending ->
                    List.sortWith (comparer identity)

                Just Table.Descending ->
                    List.sortWith (comparer reverse)

                Nothing ->
                    identity
    in
        Table.table []
            [ Table.thead []
                [ Table.tr []
                    [ Table.th []
                        [ Toggles.checkbox
                            {- append -1 to index for MDL. table data will use indexedMap,
                               therefore taking the spots 0->
                            -}
                            Mdl
                            (List.append prefix [ -1 ])
                            model.mdl
                            [ Options.onToggle (ToggleAll |> BeaconsMsg)
                            , Toggles.value (allSelected model.beacons)
                            ]
                            []
                        ]
                    , sortingHeader bModel BName
                    , sortingHeader bModel BDeployment
                    , sortingHeader bModel BEnabled
                    ]
                ]
            , Table.tbody []
                (sorter bModel.beacons
                    |> List.indexedMap
                        (\idx bkn ->
                            Table.tr [ Table.selected |> when (Set.member (key bkn) bModel.selected) ]
                                [ Table.td []
                                    [ Toggles.checkbox Mdl
                                        (List.append prefix [ idx ])
                                        model.mdl
                                        [ Options.onToggle (Toggle (key bkn) |> BeaconsMsg)
                                        , Toggles.value <| Set.member (key bkn) bModel.selected
                                        ]
                                        []
                                    ]
                                , Table.td [] [ text bkn.name ]
                                , Table.td [] [ text bkn.deployName ]
                                , Table.td [] [ text "true" ]
                                ]
                        )
                )
            ]
            |> (\x -> Options.div [ Options.center ] [ x ])


sortingHeader : BeaconsModel -> OrderField -> Html Msg
sortingHeader model field =
    let
        title =
            case field of
                BName ->
                    "Id"

                BEnabled ->
                    "Enabled"

                BDeployment ->
                    "Current Deployment"

        match =
            (==) model.orderField field
    in
        Table.th
            [ model.order
                |> (\x ->
                        if match then
                            x
                        else
                            Nothing
                   )
                |> Maybe.map Table.sorted
                |> Maybe.withDefault nop
            , Options.onClick (Reorder field |> BeaconsMsg)
            ]
            [ text title ]


view : Model -> Html Msg
view model =
    let
        prefix =
            prefixes.beaconsView
    in
        [ viewBeaconTable (List.append prefix [ 0 ]) model
        , Button.render Mdl
            (List.append prefix [ 1 ])
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick (FetchBeacons |> BeaconsMsg)
            , Options.css "float" "right"
            ]
            [ text "fetch beacons" ]
        ]
            |> div
                [ style
                    [ ( "text-align", "center" )
                    , ( "margin-top", ".6em" )
                    , ( "margin-bottom", ".6em" )
                    ]
                ]
            |> (\x -> Options.div [ Options.center ] [ x ])


reverse : Order -> Order
reverse order =
    case order of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ
