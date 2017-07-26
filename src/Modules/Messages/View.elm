module Modules.Messages.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Material.Options as Options exposing (nop, when)
import Material.Table as Table
import Material.Toggles as Toggles
import Modules.Messages.State exposing (..)
import Modules.Messages.Types exposing (..)
import Modules.Utils.View exposing (..)
import Types exposing (Msg(MessagesMsg))

view : Types.Model -> Html Types.Msg
view ({ messages } as model) =
    let
        prefix =
            [ 0 ]
    in
        [viewMessagesTable prefix model]
            |> div
                [ style
                    [ ( "text-align", "center" )
                    , ( "margin-top", ".6em" )
                    , ( "margin-bottom", ".6em" )
                    ]
                ]
            |> (\x -> Options.div [ Options.center ] [ x ])

viewMessagesTable : List Int -> Types.Model -> Html Types.Msg
viewMessagesTable prefix ({messages} as model )=
    let
        comparer : (Order -> Order) -> Message -> Message -> Order
        comparer =
            case messages.orderField of
                Name ->
                    \mapper a b -> compare (.name a) (.name b) |> mapper

                Title ->
                    \mapper a b -> compare (.title a) (.title b) |> mapper

                Url ->
                    \mapper a b -> compare (.url a) (.url b) |> mapper

        sorter =
            case messages.order of
                Just Table.Ascending ->
                    List.sortWith (comparer identity)

                Just Table.Descending ->
                    List.sortWith (comparer reverse)

                Nothing ->
                    identity
    in
        Table.table []
            [ Table.thead []
                [ Table.tr []
                    [ Table.th [] []
                    , sortingHeader messages Name
                    , sortingHeader messages Title
                    , sortingHeader messages Url
                    ]
                ]
            , Table.tbody []
                (sorter messages.messages
                    |> List.indexedMap
                        (\idx msg ->
                            Table.tr
                                [ Table.selected |> when (isSelected (key msg) messages.selected)
                                , Options.onClick (Toggle msg |> MessagesMsg)
                                ]
                                [ Table.td []
                                    [ Toggles.checkbox (\a -> Mdl a |> MessagesMsg)
                                        (List.append prefix [ idx ])
                                        messages.mdl
                                        [ Options.onToggle (Toggle msg |> MessagesMsg)
                                        , Toggles.value <| isSelected (key msg) messages.selected
                                        ]
                                        []
                                    ]
                                , Table.td [] [ text msg.name ]
                                , Table.td [] [ text msg.title ]
                                , Table.td [] [ text msg.url ]
                                ]
                        )
                )
            ]

sortingHeader : Model -> OrderField -> Html Types.Msg
sortingHeader model field =
    let
        title =
            case field of
                Name ->
                    "Name"

                Title ->
                    "Title"
                Url ->
                    "Url"

        match =
            (==) model.orderField field
    in
        Table.th
            [ model.order
                |> (\x ->
                        if match then
                            x
                        else
                            Nothing
                   )
                |> Maybe.map Table.sorted
                |> Maybe.withDefault nop
            , Options.onClick (Reorder field |> MessagesMsg)
            ]
            [ text title ]
