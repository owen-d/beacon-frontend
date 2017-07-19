module Modules.Layout.View exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Color as Color
import Material.Footer as Footer
import Material.Layout as Layout
import Material.Options as Options
import Material.Scheme
import Modules.Layout.Types exposing (LayoutMsg(SelectTab), TabWrapper)
import Modules.Route.Types exposing (Route(BeaconsRoute))
import Types exposing (Model, Msg(Mdl, LayoutMsg, None))


tabPath : String -> String
tabPath str =
    String.toLower str
        |> (++) "#"


view : (Model -> Html Msg) -> List TabWrapper -> Model -> Html Msg
view viewFn tabs model =
    Material.Scheme.topWithScheme Color.BlueGrey Color.Pink <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.selectedTab <| selectedTab model.route tabs
            , Layout.onSelectTab <| selectTab tabs
            ]
            { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "beaconthing" ] ]
            , drawer = []
            , tabs = ( List.map (\( name, _ ) -> text name) tabs, [] )
            , main =
                -- wrap with div setting background color
                [ [ viewFn model
                  , viewFooter
                  ]
                    |> Options.div []
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
                , Footer.socialButton [ Options.css "margin-right" "0.5em" ] []
                , Footer.socialButton [ Options.css "margin-right" "0.5em" ] []
                , Footer.socialButton [ Options.css "margin-right" "0em" ] []
                ]
        }



{- find which route is at a tab index -}


selectTab : List TabWrapper -> Int -> Msg
selectTab tabs idx =
    Array.fromList tabs
        |> Array.get idx
        |> Maybe.map (\( _, route ) -> route)
        |> Maybe.withDefault BeaconsRoute
        |> SelectTab
        |> LayoutMsg



{- find the idx for a given route -}


selectedTab : Route -> List TabWrapper -> Int
selectedTab route tabs =
    -- find index of the route which is selected
    List.indexedMap
        (\idx ( _, route_ ) ->
            if route == route_ then
                idx
            else
                -- toss anything not matching desired route
                -1
        )
        tabs
        |> List.filter (\a -> (>=) a 0)
        |> List.head
        |> Maybe.withDefault 0
