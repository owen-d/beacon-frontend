module Lib.Layout.View exposing (..)

import Types exposing (Model, Msg(Mdl))
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Layout as Layout


view : (Model -> Html Msg) -> Model -> Html Msg
view viewFn model =
    -- Cannot find variable `Mdl`
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader
        ]
        { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "counter" ] ]
        , drawer = []
        , tabs = ( [], [] )
        , main = [ viewFn model ]
        }
