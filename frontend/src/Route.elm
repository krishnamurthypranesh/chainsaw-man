module Route exposing (..)

import Common.Journal exposing (JournalId)
import Html exposing (a)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | ListJournalEntries
    | NewMorningJournalEntry
    | ViewJournalEntry JournalId



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
        [ map NewMorningJournalEntry top -- if no route is found, take the user to the journal creation page
        , map ListJournalEntries (s "journalEntries")
        , map NewMorningJournalEntry (s "journalEntry" </> s "morning" </> s "new")

        -- , map ViewJournalEntry (s "journalEntry" </>  )
        -- add route for home page
        ]
