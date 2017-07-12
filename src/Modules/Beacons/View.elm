module Modules.Beacons.View exposing (..)

import Material.Table as Table
import Material.Options as Options
import Html exposing (..)
import Types exposing (..)


viewBeaconTable : Beacons -> Html Msg
viewBeaconTable bkns =
    Table.table []
        [ Table.thead []
            [ Table.tr []
                [ Table.th [] [ text "Id" ]
                , Table.th [] [ text "Current Deployment" ]
                , Table.th [] [ text "Enabled" ]
                ]
            ]
        , Table.tbody []
            (bkns
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
