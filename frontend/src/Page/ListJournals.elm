module Page.ListJournals exposing (..)

import Html exposing (..)
import Http exposing (get)
import Page.MorningJournal exposing (MorningJournal, morningJournalDecoder, morningJournalsListDecoder)
import RemoteData exposing (WebData)


type alias Model =
    { journalEntries : WebData (List MorningJournal) }


type Msg
    = FetchJournalEntries
    | JournalEntriesReceived (WebData (List MorningJournal))


init : ( Model, Cmd Msg )
init =
    ( { journalEntries = RemoteData.Loading }, fetchJournalEntries )


fetchJournalEntries : Cmd Msg
fetchJournalEntries =
    Http.get
        { url = "http://localhost:8080"
        , expect =
            morningJournalsListDecoder |> Http.expectJson (RemoteData.fromResult >> JournalEntriesReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchJournalEntries ->
            ( { model | journalEntries = RemoteData.Loading }, fetchJournalEntries )

        JournalEntriesReceived response ->
            ( { model | journalEntries = response }, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text "To be implemented..." ]
