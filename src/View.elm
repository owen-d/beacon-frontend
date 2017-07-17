module View exposing (..)

-- imports

import Html exposing (Html, text)
import Modules.Beacons.View as BeaconsView
import Modules.Deployments.View as DeploymentsView
import Modules.Layout.Types exposing (TabWrapper)
import Modules.Layout.View as LayoutView
import Modules.Route.Types exposing (Route(..))
import Types exposing (..)


-- view


tabs : List TabWrapper
tabs =
    [ ( "Beacons", BeaconsRoute ), ( "Deployments", DeploymentsRoute ), ( "Messages", MessagesRoute ) ]


view : Model -> Html.Html Msg
view model =
    LayoutView.view
        page
        tabs
        model


page : Model -> Html Msg
page model =
    case model.route of
        DeploymentsRoute ->
            DeploymentsView.view model

        BeaconsRoute ->
            BeaconsView.view model
        _ ->
            DeploymentsView.view model
