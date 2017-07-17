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
