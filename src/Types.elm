module Types exposing (..)

-- imports

import Http
import Material


type alias Model =
    { user : Maybe User
    , beacons : Beacons
    , jwt : String
    , error : Maybe Http.Error
    , mdl : Material.Model
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
    = FetchBeacons
    | NewBeacons (Result Http.Error Beacons)
      -- material design types
    | Mdl (Material.Msg Msg)
