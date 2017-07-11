module Types exposing (..)

-- imports

import Http
import Material


-- layout

import Modules.Layout.Types exposing (LayoutMsg, LayoutModel)


type alias Model =
    { user : Maybe User
    , beacons : Beacons
    , jwt : String
    , error : Maybe Http.Error
    , mdl : Material.Model
    , layout : LayoutModel
    }


type alias User =
    { id : String
    , email : String
    }


type alias Beacon =
    { name : String
    , userId : String
    , deployName : String
    }


type alias Beacons =
    List Beacon


type alias Mdl =
    Material.Model



-- state updates


type Msg
    -- None type is defined but doesnt cause any updates. It lets us piggyback on type assertions that require `Html Msg`
    = None
    | FetchBeacons
    | NewBeacons (Result Http.Error Beacons)
      -- material design types
    | Mdl (Material.Msg Msg)
      -- layout types
    | LayoutMsg LayoutMsg
