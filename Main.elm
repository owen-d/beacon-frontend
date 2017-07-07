module Main exposing (..)

import Html
import Html.Events
import Http
import Json.Decode as Decode
import Time


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
    , error : Maybe Http.Error
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
    ( Model Nothing [] "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTQzOTYzOTksImlhdCI6MTQ5ODg0NDM5OSwidXNlcl9pZCI6IjZiYTdiODEwLTlkYWQtMTFkMS04MGI0LTAwYzA0ZmQ0MzBjOCJ9._Mn0COXwcs9l4NqqAbbosXWCTMentdy4xj9ZqgKhEF0" Nothing, Cmd.none )



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
                    ( { model | error = Just e }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.button [ Html.Events.onClick FetchBeacons ] [ Html.text "fetch beacons" ]
        , viewError model.error
        , Html.div [] (List.map viewBeacon (List.reverse model.beacons))
        ]


viewError : Maybe Http.Error -> Html.Html msg
viewError err =
    case err of
        Nothing ->
            Html.div [] [ Html.text "no errror!" ]

        Just e ->
            Html.div [] [ Html.text ("Error" ++ (toString e)) ]


viewBeacon : Beacon -> Html.Html msg
viewBeacon bkn =
    Html.div []
        [ Html.text bkn.name
        , Html.text bkn.userId
        , Html.text bkn.deployName
        ]



-- HTTP


fetchBeacons : String -> Cmd Msg
fetchBeacons jwt =
    let
        url =
            "http://localhost:8080/beacons"
    in
        Http.send NewBeacons
            (authReq
                (Just jwt)
                { defaultReqParams | url = url }
                decodeBeacons
            )



-- (Http.get url decodeBeacons)


decodeBeacons : Decode.Decoder Beacons
decodeBeacons =
    Decode.field "beacons"
        (Decode.list
            (Decode.map3 Beacon
                (Decode.field "name" Decode.string)
                (Decode.field "user_id" Decode.string)
                (Decode.field "deploy_name" Decode.string)
            )
        )


type alias ReqParams a =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect a
    , timeout : Maybe Time.Time
    , withCredentials : Bool
    }


defaultReqParams : ReqParams String
defaultReqParams =
    { method = "GET"
    , headers = []
    , url = ""
    , body = Http.emptyBody
    , expect = Http.expectString
    , timeout = Just (Time.minute * 30)
    , withCredentials = False
    }


authReq :
    Maybe String
    -> ReqParams a
    -> Decode.Decoder b
    -> Http.Request b
authReq token ({ headers } as reqParams) decoder =
    let
        params =
            { reqParams | expect = Http.expectJson decoder }
    in
        case token of
            Nothing ->
                Http.request params

            Just jwt ->
                Http.request { params | headers = (List.append headers [ (Http.header "x-jwt" jwt) ]) }
