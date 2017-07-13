module View exposing (..)

-- imports

import Types exposing (..)
import Http
import Html exposing (Html, text)
import Modules.Layout.View as LayoutView
import Modules.Beacons.View as BeaconsView


-- view


view : Model -> Html.Html Msg
view model =
    LayoutView.view
        mainView
        model


mainView : Model -> Html.Html Msg
mainView model =
    Html.div []
        [ BeaconsView.view model]


viewError : Maybe Http.Error -> Html.Html msg
viewError err =
    case err of
        Nothing ->
            Html.div [] [ Html.text "no errror!" ]

        Just e ->
            Html.div [] [ Html.text ("Error" ++ (toString e)) ]
