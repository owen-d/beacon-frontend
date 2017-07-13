module Modules.Beacons.View exposing (..)

import Modules.Beacons.Types exposing (..)
import Material.Table as Table
import Material.Options as Options exposing (nop)
import Material.Button as Button
import Html exposing (..)
import Html.Attributes exposing (style)
import Types exposing (Msg(Mdl, BeaconsMsg), Model)
import Components.Prefixes exposing (prefixes)


viewBeaconTable : List Int -> Model -> Html Msg
viewBeaconTable prefix model =
    let
        bModel =
            model.beacons

        sorter =
            case model.beacons.order of
                Just Table.Ascending ->
                    List.sortBy .name

                Just Table.Descending ->
                    List.sortWith (\a b -> reverse (.name a) (.name b))

                Nothing ->
                    identity
    in
        Table.table []
            [ Table.thead []
                [ Table.tr []
                    [ Table.th
                        [ bModel.order
                            |> Maybe.map Table.sorted
                            |> Maybe.withDefault nop
                        , Options.onClick (Reorder |> BeaconsMsg)
                        ]
                        [ text "Id" ]
                    , Table.th [] [ text "Current Deployment" ]
                    , Table.th [] [ text "Enabled" ]
                    ]
                ]
            , Table.tbody []
                (sorter bModel.beacons
                    |> List.map
                        (\bkn ->
                            Table.tr []
                                [ Table.td [] [ text bkn.name ]
                                , Table.td [] [ text bkn.deployName ]
                                , Table.td [] [ text "true" ]
                                ]
                        )
                )
            ]
            |> (\x -> Options.div [ Options.center ] [ x ])


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


reverse : comparable -> comparable -> Order
reverse x y =
    case compare x y of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ
