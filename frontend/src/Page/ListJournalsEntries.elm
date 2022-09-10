module Page.ListJournalsEntries exposing (..)

import Common.JournalEntry exposing (JournalEntry, ListJournalEntriesInput, idToString, journalEntriesListDecoder, journalEntryDecoder, listJournalEntriesInputEncoder)
import Error exposing (errorFromHttpError)
import Helpers exposing (dateTimeFromts)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, scope)
import Http exposing (get)
import RemoteData exposing (WebData)
import Time exposing (millisToPosix)


type alias Model =
    { journalEntries : WebData (List JournalEntry)
    , input : ListJournalEntriesInput
    }


type Msg
    = FetchJournalEntries
    | JournalEntriesReceived (WebData (List JournalEntry))


init : ( Model, Cmd Msg )
init =
    let
        model =
            { journalEntries = RemoteData.Loading, input = ListJournalEntriesInput 0 0 "" }
    in
    ( model, fetchJournalEntries model.input )


fetchJournalEntries : ListJournalEntriesInput -> Cmd Msg
fetchJournalEntries input =
    Http.post
        { url = "http://localhost:8080/journals/entries/"
        , body = Http.jsonBody (listJournalEntriesInputEncoder input)
        , expect =
            journalEntriesListDecoder |> Http.expectJson (RemoteData.fromResult >> JournalEntriesReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchJournalEntries ->
            ( { model | journalEntries = RemoteData.Loading }, fetchJournalEntries model.input )

        JournalEntriesReceived response ->
            ( { model | journalEntries = response }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.journalEntries of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div [ class "d-flex justify-content-center" ]
                [ div [ class "spinner-border", attribute "role" "status" ]
                    [ span [ class "visually-hidden" ] [ text "Loading..." ]
                    ]
                ]

        RemoteData.Success response ->
            div []
                [ buildListTable response
                ]

        -- div [] [ text ("Retreived " ++ String.fromInt (List.length response) ++ " journal entries from the backend...") ]
        RemoteData.Failure httpError ->
            text (errorFromHttpError httpError)


buildListTable : List JournalEntry -> Html Msg
buildListTable journalEntries =
    let
        tableHeaders =
            thead []
                [ tr []
                    [ th [ scope "col" ] [ text "ID" ]
                    , th [ scope "col" ] [ text "Type" ]
                    , th [ scope "col" ] [ text "Created At" ]
                    , th [ scope "col" ] [ text "" ]
                    ]
                ]

        tableRows =
            List.map tableRowFromJournalEntry journalEntries
    in
    table [ class "table table-light table-striped" ]
        [ tableHeaders
        , tbody [] tableRows
        ]


tableRowFromJournalEntry : JournalEntry -> Html Msg
tableRowFromJournalEntry entry =
    let
        createdTS =
            Time.millisToPosix (entry.createdAt * 1000)
    in
    tr []
        [ th [ scope "row" ]
            [ text (idToString entry.id)
            ]
        , td [] [ text "Morning Journal" ]
        , td [] [ text (dateTimeFromts createdTS) ]
        , td []
            [ a [ href ("/journals/entries/" ++ idToString entry.id ++ "") ] [ text "View" ]
            ]
        ]
