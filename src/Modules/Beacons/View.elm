module Modules.Beacons.View exposing (..)

import Modules.Beacons.Types exposing (..)
import Material.Table as Table
import Material.Options as Options
import Html exposing (..)
import Types exposing (Msg)

viewBeaconTable : BeaconsModel -> Html Msg
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
            (model.beacons
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
