module Modules.Signin.View exposing (..)

-- imports

import Html exposing (..)
import Html.Attributes exposing (src, style)
import Material.Button as Button
import Material.Card as Card
import Material.Options as Options
import Material.Typography as Typo
import Modules.Signin.Types as SigninTypes exposing (SigninMsg(..), SigninModel)
import Types exposing (Model, Msg(MsgFor_SigninMsg))


{-
   Shit i need:
   1) Signin box - done
   2) google icon - done
   3) clicking icon will kick off a request to api/oauth/google, which generates a state param & redirects to google's oauth endpoint.
   4) successful redirect will send user to sharecrows/signin/google, which will proxy the code/state param & handle user upsert
-}


googleButtonPath : String
googleButtonPath =
    "static/img/btn_google_dark.svg"


signinCard : List Int -> SigninModel -> Html Msg
signinCard prefix model =
    Card.view []
        [ Card.title [] [ Card.head [] [ Options.styled p [ Typo.title ] [ text "Sign in" ] ] ]
        , Card.actions []
            [ Button.render (MsgFor_SigninMsg << Mdl)
                (List.append prefix [ 1 ])
                model.mdl
                [ Button.raised
                , Button.ripple
                , Options.onClick <| MsgFor_SigninMsg InitiateGoogleSignin
                ]
                [ img
                    [ src googleButtonPath
                    , style [ ( "height", "100%" ) ]
                    ]
                    []
                , text "google"
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    let
        prefix =
            [ 0 ]
    in
        signinCard prefix model.signin
            :: []
            |> Options.div [ Options.center ]


googleAuthorizeView : Model -> Html Msg
googleAuthorizeView model =
    view model
