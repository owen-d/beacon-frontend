module Modules.Signin.View exposing (..)

-- imports
import Html exposing (..)
import Material.Card as Card
import Types exposing (Model, Msg)

{-
  Shit i need:
  1) Signin box
  2) google icon
  3) clicking icon will kick off a request to api/oauth/google, which generates a state param & redirects to google's oauth endpoint.
  4) successful redirect will send user to sharecrows/signin/google/success, which will proxy the code/state param & handle user upsert
-}

signinCard : Html Msg
signinCard =
    Card.view []
        [Card.title [] [Card.head [] [text "Sign in"]]
        , Card.actions []
            [text "google"]]

view : Model -> Html Msg
view model =
    signinCard
