module Modules.Layout.Types exposing (..)

import Modules.Route.Types exposing (Route)


type LayoutMsg
    = SelectTab Route



type alias TabWrapper =
    ( String, Route )
