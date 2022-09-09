module Page.ListJournalsEntries exposing (..)

import Common.JournalEntry exposing (JournalEntry, journalEntriesListDecoder, journalEntryDecoder)
import Html exposing (..)
import Http exposing (get)
import RemoteData exposing (WebData)


type alias Model =
    { journalEntries : WebData (List JournalEntry) }


type Msg
    = FetchJournalEntries
    | JournalEntriesReceived (WebData (List JournalEntry))


init : ( Model, Cmd Msg )
init =
    ( { journalEntries = RemoteData.Loading }, fetchJournalEntries )


fetchJournalEntries : Cmd Msg
fetchJournalEntries =
    Http.get
        { url = "http://localhost:8080/journal/entries/"
        , expect =
            journalEntriesListDecoder |> Http.expectJson (RemoteData.fromResult >> JournalEntriesReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchJournalEntries ->
            ( { model | journalEntries = RemoteData.Loading }, fetchJournalEntries )

        JournalEntriesReceived response ->
            ( { model | journalEntries = response }, Cmd.none )


view : Model -> Html Msg
view _ =
    div [] [ text "To be implemented..." ]
