module Modules.Layout.State exposing (..)

import Modules.Layout.Types exposing (..)
import Modules.Route.Routing exposing (routeInit)
import Types exposing (Model, Msg(LayoutMsg))


updateLayout : (Msg -> Model -> ( Model, Cmd Msg )) -> LayoutMsg -> Model -> ( Model, Cmd Msg )



-- super is the parent update fn. It allows us to do recursive calls to the parent.


updateLayout super msg model =
    let
        model2 =
            case msg of
                SelectTab route ->
                    { model | route = route }
    in
        super (routeInit model2.route) model2
