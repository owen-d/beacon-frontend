module Lib.Layout.View exposing (..)

import Lib.Layout.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Layout as Layout


{- view will wrap a model & view fn where the model has signature {a | mdl: Material.Model} -}
view : ({ a | mdl : Mdl } -> Html msg) -> a -> Html msg
view viewFn model =
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader
        ]
        { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "counter" ] ]
        , drawer = []
        , tabs = ( [], [] )
        , main = [ viewFn model ]
        }
