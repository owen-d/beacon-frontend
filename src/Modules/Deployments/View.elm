module Modules.Deployments.View exposing (..)

import Html exposing (..)
import Material.Options as Options
import Modules.Deployments.Types as DeploymentTypes exposing (..)
import Table as SortTable
import Types exposing (Msg(DeploymentsMsg))


config : SortTable.Config Deployment Types.Msg
config =
    SortTable.config
        { toId = .deployName
        , toMsg = DeploymentsMsg << SetTableState
        , columns =
            [ SortTable.stringColumn "Name" .deployName
            , SortTable.stringColumn "Message" .messageName
            ]
        }


viewDeploymentsTable : DeploymentTypes.Model -> Html Types.Msg
viewDeploymentsTable { deployments, tableState } =
    Options.div []
        [ h1 [] [ text "Your Deployments" ]
        , SortTable.view config tableState deployments
        ]


view : Types.Model -> Html Types.Msg
view { deployments } =
    viewDeploymentsTable deployments
