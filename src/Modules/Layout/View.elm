module Modules.Layout.View exposing (..)

import Modules.Layout.Types exposing (LayoutMsg(SelectTab))
import Types exposing (Model, Msg(Mdl, LayoutMsg, None))
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Layout as Layout
import Material.Scheme
import Material.Color as Color
import Material.Options as Options
import Material.Footer as Footer


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
            , tabs = ( [ text "Beacons", text "Deployments", text "Messages" ], [] )
            , main =
                -- wrap with div setting background color
                [ [ viewFn model
                  , viewFooter
                  ]
                    |> Options.div [ Color.background Color.primaryDark ]
                ]
            }


viewFooter : Html Msg
viewFooter =
    Footer.mini []
        { left =
            Footer.left []
                [ Footer.logo [] [ Footer.html <| text "Relevant links:" ]
                , Footer.links []
                    [ Footer.linkItem [ Footer.href "#footer1" ] [ Footer.html <| text "Link 1" ]
                    , Footer.linkItem [ Footer.href "#footer2" ] [ Footer.html <| text "Link 2" ]
                    , Footer.linkItem [ Footer.href "#footer3" ] [ Footer.html <| text "Link 3" ]
                    ]
                ]
        , right =
            Footer.right []
                [ Footer.logo [] [ Footer.html <| text "Mini Footer Right Section" ]
                , Footer.socialButton [ Options.css "margin-right" "6px" ] []
                , Footer.socialButton [ Options.css "margin-right" "6px" ] []
                , Footer.socialButton [ Options.css "margin-right" "0px" ] []
                ]
        }
