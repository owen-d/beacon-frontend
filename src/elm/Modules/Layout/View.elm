module Modules.Layout.View exposing (..)

import Array
import Html exposing (..)
import Material.Footer as Footer
import Material.Layout as Layout
import Material.Options as Options exposing (css)
import Modules.Layout.Types exposing (LayoutMsg(SelectTab), TabWrapper)
import Modules.Route.Types exposing (Route(BeaconsRoute))
import Modules.Signin.Types exposing (SigninMsg(Signout))
import Types exposing (Model, Msg(Mdl, LayoutMsg, None, MsgFor_SigninMsg))


view : (Model -> Html Msg) -> List TabWrapper -> Model -> Html Msg
view viewFn tabs model =
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader
        , selectedTab model.route tabs
        , Layout.onSelectTab <| selectTab tabs
        , Layout.transparentHeader
        ]
        { header = header model
        , drawer = []
        , tabs = ( List.map (\( name, _ ) -> text name) tabs, [] )
        , main =
            [ stylesheet
            , viewFn model
            , viewFooter
            ]
        }


header : Model -> List (Html Msg)
header model =
    [ Layout.row
        [ css "height" "6em"
        , css "transition" "height 333ms ease-in-out 0s"
        ]
        [ Layout.title [] [ text "Beacon Thing" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link
                [ Options.onClick <| MsgFor_SigninMsg Signout
                , Layout.href "javascript:void(0)"
                ]
                [ text <|
                    if model.jwt == Nothing then
                        "Sign in"
                    else
                        "Sign out"
                ]
            ]
        ]
    ]


viewFooter : Html Msg
viewFooter =
    -- temporary hack for displaying footer @ bottom when not enough content on page
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


selectedTab : Route -> List TabWrapper -> Layout.Property m
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
        |> \x ->
            case x of
                Just idx ->
                    Layout.selectedTab idx

                Nothing ->
                    Options.nop


stylesheet : Html a
stylesheet =
    Options.stylesheet """
  .mdl-layout__header--transparent {
    background: url('https://getmdl.io/assets/demos/transparent.jpg') center / cover;
  }
  .mdl-layout__header--transparent .mdl-layout__drawer-button {
    /* This background is dark, so we set text to white. Use 87% black instead if
       your background is light. */
    color: white;
  }
  .elm-overlay {
    z-index : 2
  }
"""
