module Modules.Deployments.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Material.Button as Button
import Material.Card as Card
import Material.Chip as Chip
import Material.List as Lists
import Material.Options as Options exposing (nop, when)
import Material.Table as Table
import Material.Tabs as Tabs
import Material.Textfield as Textfield
import Material.Toggles as Toggles
import Modules.Deployments.State exposing (..)
import Modules.Deployments.Types as DeploymentTypes exposing (..)
import Modules.Messages.Types as MsgTypes exposing (EditMsg(..), blankMsg)
import Modules.Messages.View exposing (editMessage)
import Modules.Utils.View exposing (..)
import Set
import Types exposing (Msg(DeploymentsMsg))


viewDeploymentsTable : List Int -> Types.Model -> Html Types.Msg
viewDeploymentsTable prefix model =
    let
        dModel =
            model.deployments

        comparer : (Order -> Order) -> Deployment -> Deployment -> Order
        comparer =
            case model.deployments.orderField of
                DName ->
                    (\mapper a b -> compare (.name a) (.name b) |> mapper)

                DMessage ->
                    (\mapper a b ->
                        compare (Maybe.withDefault "" <| .messageName a)
                            (Maybe.withDefault "" <| .messageName b)
                            |> mapper
                    )

        sorter =
            case model.deployments.order of
                Just Table.Ascending ->
                    List.sortWith (comparer identity)

                Just Table.Descending ->
                    List.sortWith (comparer reverse)

                Nothing ->
                    identity

        headers =
            [ Table.th [] []
            , sortingHeader dModel DName
            , sortingHeader dModel DMessage
            ]
    in
        Table.table []
            [ Table.thead []
                [ Table.tr []
                    headers
                ]
            , Table.tbody []
                (sorter dModel.deployments
                    |> List.indexedMap
                        (\idx dep ->
                            Table.tr
                                [ Table.selected |> when (isSelected (key dep) dModel.selected)
                                , Options.onClick (Toggle dep |> DeploymentsMsg)
                                ]
                                [ Table.td []
                                    [ Toggles.checkbox (\a -> Mdl a |> DeploymentsMsg)
                                        (List.append prefix [ idx ])
                                        dModel.mdl
                                        [ Options.onToggle (Toggle dep |> DeploymentsMsg)
                                        , Toggles.value <| isSelected (key dep) dModel.selected
                                        ]
                                        []
                                    ]
                                , Table.td [] [ text dep.name ]
                                , Table.td [] [ text <| Maybe.withDefault "" dep.messageName ]
                                ]
                                :: if (isSelected (key dep) dModel.selected) then
                                    -- show diff'd beacon selections
                                    let
                                        selectedBkns =
                                            (.selected << .beacons) model

                                        -- show beacons currently existing on the deployment
                                        currentBknsCard =
                                            Table.tr []
                                                [ Table.td [ Options.attribute <| Html.Attributes.colspan <| List.length headers ]
                                                    [ deploymentCard "Current beacons" dep.beacons ]
                                                ]
                                                :: []

                                        diffBkns =
                                            dep.beacons
                                                |> Set.fromList
                                                |> Set.diff selectedBkns
                                                |> Set.toList
                                    in
                                        if List.length diffBkns > 0 then
                                            Table.tr []
                                                [ Table.td [ Options.attribute <| Html.Attributes.colspan <| List.length headers ]
                                                    [ deploymentCard "New beacons" diffBkns
                                                    , saveDepButton (List.append prefix [ idx, 0 ]) "save to campaign" dep
                                                    ]
                                                ]
                                                :: currentBknsCard
                                        else
                                            currentBknsCard
                                   else
                                    []
                        )
                    |> List.concat
                )
            ]


sortingHeader : Model -> OrderField -> Html Types.Msg
sortingHeader model field =
    let
        title =
            case field of
                DName ->
                    "Name"

                DMessage ->
                    "Message"

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
            , Options.onClick (Reorder field |> DeploymentsMsg)
            ]
            [ text title ]


view : Types.Model -> Html Types.Msg
view ({ deployments } as model) =
    let
        prefix =
            [ 0 ]
    in
        [ deploymentsTabs (List.append prefix [ 0 ]) model ]
            |> div
                [ style
                    [ ( "text-align", "center" )
                    , ( "margin-top", ".6em" )
                    , ( "margin-bottom", ".6em" )
                    ]
                ]
            |> (\x -> Options.div [ Options.center ] [ x ])


deploymentsTabs : List Int -> Types.Model -> Html Types.Msg
deploymentsTabs prefix ({ deployments } as model) =
    Tabs.render (DeploymentsMsg << Mdl)
        (List.append prefix [ 0 ])
        deployments.mdl
        [ Tabs.ripple
        , Tabs.onSelectTab (DeploymentsMsg << SelectTab)
        , Tabs.activeTab deployments.curTab
        ]
        [ Tabs.label
            []
            [ text "Existing" ]
        , Tabs.label
            []
            -- for similar tab sizes
            [ Options.span [ Options.css "width" "8em" ] [ text "New" ] ]
        ]
        [ case deployments.curTab of
            1 ->
                editDeployment (List.append prefix [ 1 ]) model

            _ ->
                viewDeploymentsTable (List.append prefix [ 2 ]) model
        ]
        |> \x ->
            Options.div [ Options.css "min-height" "25rem" ] [ x ]
                |> (\x -> Options.div [ Options.center ] [ x ])


editDeployment : List Int -> Types.Model -> Html Types.Msg
editDeployment prefix rootModel =
    -- NOTE: textfields with the floatingLabel property require the value to be linked to the model (current fix)
    -- See: https://github.com/debois/elm-mdl/issues/278
    -- name field
    -- sub-tabs for using msg name or inlining a new msg
    -- message name field
    -- message value field
    -- url field
    -- lang field
    let
        ({ editingDep, mdl } as model) =
            rootModel.deployments
    in
        List.indexedMap
            (\idx ( label, val, rxn ) ->
                Textfield.render (DeploymentsMsg << Mdl)
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
            -- TBD: add a selectbox for current msgnames w/ onInput signature (DeploymentsMsg << EditDepMsgName)
            [ ( "a name for the campaign"
              , editingDep.name
              , DeploymentsMsg << MsgFor_EditDep << EditDepName
              )
            ]
            |> List.concat
            -- add tabs for using existing msg or inline msg
            |> (\a ->
                    List.append a
                        [ editDepMsgTabs (List.append prefix [ 1 ]) rootModel ]
               )
            -- add button at end
            |> (\a ->
                    List.append a
                        [ saveDepButton (List.append prefix [ 2 ]) "save campaign" editingDep ]
               )
            |> Options.div []


saveDepButton : List Int -> String -> Deployment -> Html Types.Msg
saveDepButton prefix buttonText dep =
    Button.render (DeploymentsMsg << Mdl)
        (List.append prefix [ 0 ])
        model.mdl
        [ Button.raised
        , Button.ripple
        , Options.css "float" "right"
        , Options.onClick <| DeploymentsMsg <| PostDeployment dep
        ]
        [ text buttonText ]


editDepMsgTabs : List Int -> Types.Model -> Html Types.Msg
editDepMsgTabs prefix model =
    let
        { editingDep, mdl, curMsgTab } =
            model.deployments
    in
        Tabs.render (DeploymentsMsg << Mdl)
            (List.append prefix [ 0 ])
            mdl
            [ Tabs.ripple
            , Tabs.onSelectTab (DeploymentsMsg << SelectMsgTab)
            , Tabs.activeTab curMsgTab
            ]
            [ Tabs.label
                []
                [ text "saved messages" ]
            , Tabs.label
                []
                [ text "new message" ]
            ]
            [ let
                newPrefix =
                    (List.append prefix [ 1 ])
              in
                case curMsgTab of
                    0 ->
                        viewMsgs newPrefix model

                    _ ->
                        editMessage newPrefix
                            (DeploymentsMsg << MsgFor_EditDep << MsgFor_EditMsg)
                            (Maybe.withDefault
                                blankMsg
                                editingDep.message
                            )
                            mdl
            ]


viewMsgs : List Int -> Types.Model -> Html Types.Msg
viewMsgs prefix ({ deployments, messages } as model) =
    let
        { editingDep, mdl } =
            deployments

        checkboxLi k msg =
            let
                toggleMsgName =
                    (EditDepMsgName (toggle msg.name editingDep.messageName)
                        |> MsgFor_EditDep
                        |> DeploymentsMsg
                    )
            in
                Lists.li [ Options.onClick toggleMsgName ]
                    [ Lists.content [] [ text msg.name ]
                    , Toggles.checkbox (DeploymentsMsg << Mdl)
                        (List.append prefix [ k ])
                        mdl
                        [ Options.onToggle toggleMsgName
                        , Toggles.ripple
                        , Toggles.value <| editingDep.messageName == (Just msg.name)
                        ]
                        []
                        :: []
                        |> Options.div [ Options.css "float" "right" ]
                    ]
    in
        Lists.ul [] <|
            List.indexedMap
                (\idx msg ->
                    checkboxLi idx msg
                )
                messages.messages


deploymentCard : String -> List String -> Html msg
deploymentCard title bkns =
    let
        mesh : List (List String) -> List String -> Int -> List (List String)
        mesh accum col chunksize =
            if (List.isEmpty col) then
                accum
            else
                mesh
                    (List.append accum <|
                        List.take chunksize col
                            :: []
                    )
                    (List.drop chunksize col)
                    chunksize

        bknMesh =
            mesh [] bkns 4

        cell =
            Options.css "margin" "0.75rem 0.5rem"

        row =
            List.map
                (\bkn ->
                    Chip.span [ cell ]
                        [ Chip.content []
                            [ text <| String.right 8 bkn ]
                        ]
                )
    in
        Card.view []
            [ Card.title
                []
                [ Card.head [] [ text title ] ]
            , (List.map
                (\bkns ->
                    row bkns
                )
                bknMesh
              )
                |> List.concat
                |> Options.div
                    [ Options.css "display" "flex"
                    , Options.css "flex-wrap" "wrap"
                    , Options.css "flex-direction" "row"
                    ]
                |> (\a -> Card.actions [] [ a ])
            ]
