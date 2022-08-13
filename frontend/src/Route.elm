module Route exposing (..)

import Html exposing (a)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | JournalEntries



-- add route for home page


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map JournalEntries top
        , map JournalEntries (s "journalEntries")

        -- add route for home page
        ]
