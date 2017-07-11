module Modules.Layout.Types exposing (..)


type LayoutMsg
    = SelectTab Int


type alias LayoutModel =
    { selectedTab : Int }
