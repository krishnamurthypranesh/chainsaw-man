module Page.ListJournalsEntries exposing (..)

import Common.JournalEntry exposing (JournalEntry, ListJournalEntriesInput, idToString, journalEntriesListDecoder, journalEntryDecoder, listJournalEntriesInputEncoder)
import Common.JournalTheme exposing (ThemeValue(..), themeValueToFormattedString)
import Error exposing (errorFromHttpError)
import Helpers exposing (dateTimeFromTs)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, id, scope, type_)
import Http
import RemoteData exposing (WebData)
import Time exposing (millisToPosix)


type alias Model =
    { journalEntries : WebData (List JournalEntry)
    , input : ListJournalEntriesInput
    }


type Msg
    = FetchJournalEntries
    | JournalEntriesReceived (WebData (List JournalEntry))


type OutMsg
    = OpenModal Modal
    | CloseModal


type Modal
    = DummyModal


init : ( Model, Cmd Msg )
init =
    let
        model =
            { journalEntries = RemoteData.Loading, input = ListJournalEntriesInput 0 0 None }
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


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        FetchJournalEntries ->
            ( { model | journalEntries = RemoteData.Loading }, fetchJournalEntries model.input, CloseModal )

        JournalEntriesReceived response ->
            ( { model | journalEntries = response }, Cmd.none, CloseModal )


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
                    [ th [ scope "col" ] [ text "Idea" ]
                    , th [ scope "col" ] [ text "Theme" ]
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
            [ text entry.content.idea
            ]
        , td [] [ text (themeValueToFormattedString entry.theme.theme) ]
        , td [] [ text (dateTimeFromTs createdTS) ]
        , td []
            [ a [ href ("/journals/entries/" ++ idToString entry.id ++ "") ] [ text "View" ]
            ]
        ]


viewModal : Model -> Html Msg
viewModal model =
    div [] []


buildNavBar : Model -> Html Msg
buildNavBar model =
    nav
        [ class "navbar navbar-expand-lg sticky-top bg-light"
        ]
        [ div [ class "container-fluid" ]
            [ a [ href "/", class "navbar-brand" ]
                [ text "Painted Porch" ]
            , button
                [ class "navbar-toggler"
                , type_ "button"
                , attribute "data-bs-toggle" "collapse"
                , attribute "data-bs-target" "#navbarNav"
                , attribute "aria-controls" "navbarNav"
                , attribute "aria-expanded" "false"
                , attribute "aria-label" "Toggle navigation"
                ]
                [ span [ class "navbar-toggler-icon" ] []
                ]
            , div [ class "collapse navbar-collapse", id "navbarNav" ]
                [ ul [ class "navbar-nav" ]
                    [ li [ class "nav-item" ]
                        [ a [ class "nav-link", attribute "aria-current" "page", href "/" ] [ text "Home" ]
                        ]
                    , li [ class "nav-item" ]
                        [ a [ class "nav-link", href "/journals/new" ] [ text "New Journal Entry" ]
                        ]
                    , li [ class "nav-item" ]
                        [ a [ class "nav-link", href "/journals/entries" ] [ text "List Journal Entries" ]
                        ]
                    ]
                ]
            ]
        ]
