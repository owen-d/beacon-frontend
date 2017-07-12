module Types exposing (..)

-- imports

import Material


-- layout

import Modules.Layout.Types exposing (LayoutMsg, LayoutModel)
import Modules.Beacons.Types exposing (BeaconsMsg, BeaconsModel)


type alias Model =
    { user : Maybe User
    , beacons : BeaconsModel
    , jwt : String
    , mdl : Material.Model
    , layout : LayoutModel
    }


type alias User =
    { id : String
    , email : String
    }



type alias Mdl =
    Material.Model



-- state updates


type Msg
    -- None type is defined but doesnt cause any updates. It lets us piggyback on type assertions that require `Html Msg`
    = None
      -- material design types
    | Mdl (Material.Msg Msg)
      -- layout types
    | LayoutMsg LayoutMsg
    | BeaconsMsg BeaconsMsg
