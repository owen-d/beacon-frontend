module View exposing (..)

-- imports

import Html exposing (Html, text, node)
import Html.Attributes exposing (name, content)
import Modules.Beacons.View as BeaconsView
import Modules.Deployments.View as DeploymentsView
import Modules.Layout.Types exposing (TabWrapper)
import Modules.Layout.View as LayoutView
import Modules.Messages.View as MessagesView
import Modules.Route.Types exposing (Route(..))
import Types exposing (..)


-- view


tabs : List TabWrapper
tabs =
    [ ( "Beacons", BeaconsRoute ), ( "Campaigns", DeploymentsRoute ), ( "Messages", MessagesRoute ) ]


view : Model -> Html.Html Msg
view model =
    LayoutView.view
        (addViewportMeta page)
        tabs
        model


page : Model -> Html Msg
page model =
    case model.route of
        DeploymentsRoute ->
            DeploymentsView.view model

        BeaconsRoute ->
            BeaconsView.view model

        MessagesRoute ->
            MessagesView.view model

        _ ->
            BeaconsView.view model



-- for injecting viewport meta tag via elm reactor


addViewportMeta : (Model -> Html Msg) -> Model -> Html Msg
addViewportMeta mapper model =
    Html.div []
        [ node "meta" [ name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" ] []
        , mapper model
        ]
