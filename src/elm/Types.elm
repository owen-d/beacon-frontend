module Types exposing (..)

-- imports

import Material
import Modules.Beacons.Types as BeaconTypes exposing (BeaconsMsg, BeaconsModel)
import Modules.Deployments.Types as Deployments
import Modules.Layout.Types exposing (LayoutMsg)
import Modules.Messages.Types as Messages
import Modules.Route.Types exposing (Route(..))
import Modules.Signin.Types as SigninTypes exposing (SigninMsg, SigninModel, User)


type alias Model =
    { user : Maybe User
    , beacons : BeaconsModel
    , jwt : Maybe String
    , mdl : Material.Model
    , route : Route
    , deployments : Deployments.Model
    , messages : Messages.Model
    , signin : SigninModel
    }


model : Model
model =
    { user = Nothing
    , beacons = BeaconTypes.model
    , jwt = Nothing
    , mdl = Material.model
    , route = NotFoundRoute
    , deployments = Deployments.model
    , messages = Messages.model
    , signin = SigninTypes.model
    }


type alias Flags =
    { jwt : Maybe String }



-- state updates


type
    Msg
    -- None type is defined but doesnt cause any updates. It lets us piggyback on type assertions that require `Html Msg`
    = None
      -- Delayed type is useful for executing a delayed command via tasks.
    | Delayed Msg
      -- material design types
    | Mdl (Material.Msg Msg)
      -- layout types
    | LayoutMsg LayoutMsg
    | BeaconsMsg BeaconsMsg
    | DeploymentsMsg Deployments.Msg
    | MessagesMsg Messages.Msg
    | Unauthenticated
    | MsgFor_SigninMsg SigninMsg
