module Lib.Layout.Types exposing (..)

import Material


type Msg
    = Maybe Mdl (Material.Msg Msg)


type alias Mdl =
    Material.Model
