module Modules.Utils.View exposing (..)

reverse : Order -> Order
reverse order =
    case order of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ

isSelected : String -> Maybe String -> Bool
isSelected id selected =
    (==) selected <| Just id


{- Toggle whether or not a set `set` contains an element `x`. -}


toggle : comparable -> Maybe comparable -> Maybe comparable
toggle new selected =
    case selected of
        Just old ->
            -- toggle off
            if old == new then
                Nothing
                -- set new
            else
                Just new

        -- if none selected, set new
        Nothing ->
            Just new


