module Lib.Layout.View exposing (..)

import Types exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Layout as Layout
import Material


view : (Model -> Html msg) -> Model -> Html msg
view viewFn model =
    -- Cannot find variable `Mdl`
    Layout.render Material.Model
        model.mdl
        [ Layout.fixedHeader
        ]
        { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "counter" ] ]
        , drawer = []
        , tabs = ( [], [] )
        , main = [ viewFn model ]
        }
