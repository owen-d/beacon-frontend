module View exposing (..)

-- imports

import Types exposing (..)
import Html exposing (Html, text)
import Modules.Layout.View as LayoutView
import Modules.Beacons.View as BeaconsView


-- view


view : Model -> Html.Html Msg
view model =
    LayoutView.view
        page
        model



page : Model -> Html Msg
page model =
    case model.route of
        _ ->
            BeaconsView.view model
