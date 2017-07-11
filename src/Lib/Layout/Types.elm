module Lib.Layout.Types exposing (..)

import Material


type Msg
    = Mdl (Material.Msg Msg)


type alias Mdl =
    Material.Model
