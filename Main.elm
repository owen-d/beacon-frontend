module Main exposing (..)

import Html
import Html.Events
import Json.Decode as Decode
import Http


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { user : Maybe User
    , beacons : Beacons
    , jwt : String
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


init : ( Model, Cmd Msg )
init =
    ( Model Nothing [] "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTQzOTYzOTksImlhdCI6MTQ5ODg0NDM5OSwidXNlcl9pZCI6IjZiYTdiODEwLTlkYWQtMTFkMS04MGI0LTAwYzA0ZmQ0MzBjOCJ9._Mn0COXwcs9l4NqqAbbosXWCTMentdy4xj9ZqgKhEF0", Cmd.none )



-- UPDATE


type Msg
    = FetchBeacons
    | NewBeacons (Result Http.Error Beacons)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchBeacons ->
            ( model, fetchBeacons model.jwt )

        NewBeacons res ->
            case res of
                Ok bkns ->
                    ( { model | beacons = bkns }, Cmd.none )

                Err e ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.button [ Html.Events.onClick FetchBeacons ] [ Html.text "fetch beacons" ]
        , Html.div [] (List.map viewBeacon (List.reverse model.beacons))
        ]


viewBeacon : Beacon -> Html.Html msg
viewBeacon bkn =
    Html.div []
        [ Html.text bkn.name
        , Html.text bkn.userId
        , Html.text bkn.deployName
        ]



-- HTTP


fetchBeacons : string -> Cmd Msg
fetchBeacons jwt =
    let
        url =
            "http://localhost:8080/beacons/"
    in
        Http.send NewBeacons (Http.get url decodeBeacons)


decodeBeacons : Decode.Decoder Beacons
decodeBeacons =
    Decode.field "beacons"
        (Decode.list
            (Decode.map3 Beacon
                (Decode.field "name" Decode.string)
                (Decode.field "userId" Decode.string)
                (Decode.field "deployName" Decode.string)
            )
        )
