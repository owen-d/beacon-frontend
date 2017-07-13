module Modules.Beacons.View exposing (..)

import Modules.Beacons.Types exposing (..)
import Material.Table as Table
import Material.Options as Options
import Material.Button as Button
import Html exposing (..)
import Types exposing (Msg(Mdl, BeaconsMsg), Model)
import Components.Prefixes exposing (prefixes)


viewBeaconTable : Model -> Html Msg
viewBeaconTable model =
    Table.table []
        [ Table.thead []
            [ Table.tr []
                [ Table.th [ Table.ascending ] [ text "Id" ]
                , Table.th [] [ text "Current Deployment" ]
                , Table.th [] [ text "Enabled" ]
                ]
            ]
        , Table.tbody []
            (model.beacons.beacons
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
    Options.div [ Options.center ]
        [ viewBeaconTable model
        , Button.render Mdl
            (List.append prefixes.beaconsView [0])
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick (FetchBeacons |> BeaconsMsg)
            ]
            [ text "fetch beacons" ]
        ]
