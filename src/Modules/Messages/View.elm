module Modules.Messages.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Material.Button as Button
import Material.Options as Options exposing (nop, when)
import Material.Table as Table
import Material.Tabs as Tabs
import Material.Textfield as Textfield
import Material.Toggles as Toggles
import Modules.Messages.State exposing (..)
import Modules.Messages.Types as MsgTypes exposing (..)
import Modules.Utils.View exposing (..)
import Types exposing (Msg(MessagesMsg))


view : Types.Model -> Html Types.Msg
view ({ messages } as model) =
    let
        prefix =
            [ 0 ]
    in
        [ messageTabs (List.append prefix [ 0 ]) model ]
            |> div
                [ style
                    [ ( "text-align", "center" )
                    , ( "margin-top", ".6em" )
                    , ( "margin-bottom", ".6em" )
                    ]
                ]
            |> (\x -> Options.div [ Options.center ] [ x ])


viewMessagesTable : List Int -> Types.Model -> Html Types.Msg
viewMessagesTable prefix ({ messages } as model) =
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


messageTabs : List Int -> Types.Model -> Html Types.Msg
messageTabs prefix ({ messages } as model) =
    Tabs.render (MessagesMsg << Mdl)
        (List.append prefix [ 0 ])
        messages.mdl
        [ Tabs.ripple
        , Tabs.onSelectTab (MessagesMsg << SelectTab)
        , Tabs.activeTab messages.curTab
        ]
        [ Tabs.label
            []
            [ text "Messages" ]
        , Tabs.label
            []
            -- for similar tab sizes
            [ Options.span [ Options.css "width" "8em" ] [ text "Edit" ] ]
        ]
        [ case messages.curTab of
            1 ->
                editMessage (List.append prefix [ 1 ]) messages

            _ ->
                viewMessagesTable (List.append prefix [ 2 ]) model
        ]
        |> \x ->
            Options.div [ Options.css "min-height" "25rem" ] [ x ]
                |> (\x -> Options.div [ Options.center ] [ x ])


editMessage : List Int -> MsgTypes.Model -> Html Types.Msg
editMessage prefix { editingMsg, mdl } =
    -- NOTE: textfields with the floatingLabel property require the value to be linked to the model (current fix)
    -- See: https://github.com/debois/elm-mdl/issues/278
    -- name field
    -- sub-tabs for using msg name or inlining a new msg
    -- message name field
    -- message value field
    -- url field
    -- lang field
    List.indexedMap
        (\idx ( label, val, rxn ) ->
            Textfield.render (MessagesMsg << Mdl)
                -- use prefix + 0 as base for each textfield component
                (List.append prefix [ 0, idx ])
                mdl
                [ Textfield.label label
                , Textfield.floatingLabel
                , Textfield.text_
                , Textfield.value val
                , Options.onInput rxn
                ]
                []
                -- add line breaks between
                :: [ br [] [] ]
        )
        -- TBD: add a selectbox for current msgnames w/ onInput signature (MessagesMsg << EditDepMsgName)
        [ ( "Message Name"
          , editingMsg.name
          , MessagesMsg << MsgFor_EditMsg << EditMsgName
          )
        , ( "Title"
          , editingMsg.title
          , MessagesMsg << MsgFor_EditMsg << EditMsgTitle
          )
        , ( "Url"
          , editingMsg.url
          , MessagesMsg << MsgFor_EditMsg << EditMsgUrl
          )
        ]
        |> List.concat
        -- add button at end
        |> (\a ->
                List.append a
                    [ Button.render (MessagesMsg << Mdl)
                        (List.append prefix [ 1 ])
                        model.mdl
                        [ Button.raised
                        , Button.ripple
                        , Options.css "float" "right"
                        , Options.onClick <| MessagesMsg <| PostMessage editingMsg
                        ]
                        [ text "create message" ]
                    ]
           )
        |> Options.div []
