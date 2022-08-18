module Route exposing (..)

import Html exposing (a)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | JournalEntries
    | NewMorningJournal



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
        [ map NewMorningJournal top -- if no route is found, take the user to the journal creation page
        , map JournalEntries (s "journalEntries")
        , map NewMorningJournal (s "journalEntry" </> s "morning" </> s "new")

        -- add route for home page
        ]
