module Modules.Deployments.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Material.Button as Button
import Material.Options as Options
import Material.Options as Options exposing (nop, when)
import Material.Table as Table
import Material.Tabs as Tabs
import Material.Textfield as Textfield
import Material.Toggles as Toggles
import Modules.Deployments.State exposing (..)
import Modules.Deployments.Types as DeploymentTypes exposing (..)
import Modules.Utils.View exposing (..)
import Set exposing (Set)
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
                    (\mapper a b -> compare (.messageName a) (.messageName b) |> mapper)

        sorter =
            case model.deployments.order of
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
                    [ Table.th []
                        [ Toggles.checkbox
                            {- append -1 to index for MDL. table data will use indexedMap,
                               therefore taking the spots 0->
                            -}
                            (\a -> Mdl a |> DeploymentsMsg)
                            (List.append prefix [ -1 ])
                            model.mdl
                            [ Options.onToggle (ToggleAll |> DeploymentsMsg)
                            , Toggles.value (allSelected dModel)
                            ]
                            []
                        ]
                    , sortingHeader dModel DName
                    , sortingHeader dModel DMessage
                    ]
                ]
            , Table.tbody []
                (sorter dModel.deployments
                    |> List.indexedMap
                        (\idx dep ->
                            Table.tr [ Table.selected |> when (Set.member (key dep) dModel.selected) ]
                                [ Table.td []
                                    [ Toggles.checkbox (\a -> Mdl a |> DeploymentsMsg)
                                        (List.append prefix [ idx ])
                                        dModel.mdl
                                        [ Options.onToggle (Toggle (key dep) |> DeploymentsMsg)
                                        , Toggles.value <| Set.member (key dep) dModel.selected
                                        ]
                                        []
                                    ]
                                , Table.td [] [ text dep.name ]
                                , Table.td [] [ text dep.messageName ]
                                ]
                        )
                )
            ]
            -- buttons
            :: Button.render (DeploymentsMsg << Mdl)
                (List.append prefix [ 1 ])
                dModel.mdl
                [ Button.raised
                , Button.ripple
                , Options.onClick (FetchDeployments |> DeploymentsMsg)
                , Options.css "float" "right"
                ]
                [ text "fetch deployments" ]
            :: []
            |> Options.div [ Options.center ]


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
            [ Options.center ]
            [ text "Deployments" ]
        , Tabs.label
            [ Options.center ]
            [ text "Edit" ]
        ]
        [ case deployments.curTab of
            1 ->
                editDeployment (List.append prefix [ 1 ]) model

            _ ->
                viewDeploymentsTable (List.append prefix [ 2 ]) model
        ]


editDeployment : List Int -> Types.Model -> Html Types.Msg
editDeployment prefix ({ deployments } as model) =
    -- name field
    -- sub-tabs for using msg name or inlining a new msg
    -- message name field
    -- message value field
    -- url field
    -- lang field
    [ Textfield.render (DeploymentsMsg << Mdl)
        (List.append prefix [ 0 ])
        deployments.mdl
        [ Textfield.label "Deployment Name"
        , Textfield.floatingLabel
        , Textfield.text_
        ]
        []
    , Textfield.render (DeploymentsMsg << Mdl)
        (List.append prefix [ 1 ])
        deployments.mdl
        [ Textfield.label "Message Name"
        , Textfield.floatingLabel
        , Textfield.text_
        ]
        []
    , Textfield.render (DeploymentsMsg << Mdl)
        (List.append prefix [ 2 ])
        deployments.mdl
        [ Textfield.label "Notification snippet"
        , Textfield.floatingLabel
        , Textfield.text_
        ]
        []
    , Textfield.render (DeploymentsMsg << Mdl)
        (List.append prefix [ 3 ])
        deployments.mdl
        [ Textfield.label "url"
        , Textfield.floatingLabel
        , Textfield.text_
        ]
        []
    ]
        |> Options.div []
