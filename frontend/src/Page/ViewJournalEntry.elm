module Page.ViewJournalEntry exposing (..)

import Browser.Navigation as Nav
import Common.JournalEntry exposing (JournalEntry, JournalId, idToString, journalEntryDecoder)
import Error exposing (buildHttpErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import RemoteData exposing (WebData)


type alias Model =
    { navKey : Nav.Key
    , journalEntry : WebData JournalEntry
    }


init : JournalId -> Nav.Key -> ( Model, Cmd Msg )
init journalId navKey =
    ( initialModel navKey, fetchJournalEntry journalId )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , journalEntry = RemoteData.Loading
    }



-- UPDATE


type Msg
    = JournalEntryReceived (WebData JournalEntry)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        JournalEntryReceived journalEntry ->
            ( { model | journalEntry = journalEntry }, Cmd.none )


fetchJournalEntry : JournalId -> Cmd Msg
fetchJournalEntry journalId =
    Http.get
        { url = "http://localhost:8080/journal/entries/" ++ idToString journalId
        , expect =
            journalEntryDecoder
                |> Http.expectJson (RemoteData.fromResult >> JournalEntryReceived)
        }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Journal Entry" ]
        , viewJournalEntry model.journalEntry
        ]


viewJournalEntry : WebData JournalEntry -> Html Msg
viewJournalEntry entry =
    case entry of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading journal entry..." ]

        RemoteData.Success data ->
            viewEntry data

        RemoteData.Failure httpError ->
            viewFetchError (buildHttpErrorMessage httpError)


viewEntry : JournalEntry -> Html Msg
viewEntry entry =
    div [] [ text "Journal entry loaded..." ]


viewFetchError : String -> Html Msg
viewFetchError err =
    let
        heading =
            "Counldn't fetch the requested journal entry"
    in
    div []
        [ h3 [] [ text err ]
        , text ("Error: " ++ err)
        ]
