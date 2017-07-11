module Modules.Layout.State exposing (..)

import Types exposing (Model, Msg(LayoutMsg))
import Modules.Layout.Types exposing (..)


updateLayout : LayoutMsg -> Model -> ( Model, Cmd Msg )
updateLayout msg model =
    let
        layout =
            model.layout
    in
        case msg of
            SelectTab msg ->
                { model | layout = selectTab msg layout } ! []


selectTab : Int -> LayoutModel -> LayoutModel
selectTab num layout =
    { layout | selectedTab = num }
