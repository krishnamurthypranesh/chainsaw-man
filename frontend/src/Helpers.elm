module Helpers exposing (..)


stringFromMaybeString : Maybe String -> String
stringFromMaybeString maybeString =
    case maybeString of
        Nothing ->
            ""

        Just val ->
            val
