module Route exposing (..)

import Common.JournalEntry exposing (JournalId)
import Html exposing (a)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | ListJournalEntries
    | NewJournalEntry



-- | ViewJournalEntry JournalId
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
        [ map NewJournalEntry top -- if no route is found, take the user to the journal creation page
        , map ListJournalEntries (s "journalEntries")
        , map NewJournalEntry (s "journalEntry" </> s "morning" </> s "new")

        -- , map ViewJournalEntry (s "journalEntry" </>  )
        -- add route for home page
        ]
