module Modules.Layout.View exposing (..)

import Modules.Layout.Types exposing (LayoutMsg(SelectTab))
import Types exposing (Model, Msg(Mdl, LayoutMsg))
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Layout as Layout
import Material.Scheme
import Material.Color as Color
import Material.Options as Options


view : (Model -> Html Msg) -> Model -> Html Msg
view viewFn model =
    -- Cannot find variable `Mdl`
    Material.Scheme.topWithScheme Color.BlueGrey Color.Pink <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.selectedTab model.layout.selectedTab
            , Layout.onSelectTab (\x -> SelectTab x |> LayoutMsg)
            ]
            { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "beaconthing" ] ]
            , drawer = []
            , tabs = ( [ text "Deployments", text "Messages", text "Beacons" ], [] )
            , main =
                -- wrap with div setting background color
                [ [ viewFn model ]
                    |> Options.div [ Color.background Color.primaryDark ]
                ]
            }
