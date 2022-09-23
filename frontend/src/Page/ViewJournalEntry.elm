module Page.ViewJournalEntry exposing (..)

import Browser.Navigation as Nav
import Common.JournalEntry exposing (JournalEntry, JournalId, emptyJournalEntry, idToString, journalEntryDecoder)
import Common.JournalTheme as JournalTheme exposing (themeValueToFormattedString)
import Error exposing (errorFromHttpError)
import Helpers exposing (dateTimeFromTs)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import RemoteData exposing (WebData)
import Time


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


type OutMsg
    = OpenModal Modal
    | CloseModal


type Modal
    = DummyModal


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        JournalEntryReceived journalEntry ->
            ( { model | journalEntry = journalEntry }, Cmd.none, CloseModal )


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
        [ viewJournalEntry model.journalEntry
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
            viewFetchError (errorFromHttpError httpError)


viewEntry : JournalEntry -> Html Msg
viewEntry entry =
    div [ class "container" ]
        [ buildJournalEntryHtml entry
        ]


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


buildJournalEntryHtml : JournalEntry -> Html Msg
buildJournalEntryHtml entry =
    div []
        [ div [ class "row" ]
            [ div [ class "col" ]
                [ text "Morning Journal"
                ]
            , div [ class "col", class "text-end" ]
                [ text (dateTimeFromTs (Time.millisToPosix (entry.createdAt * 1000)))
                ]
            ]
        , div [ class "row", class "gy-2" ]
            [ div [ class "card", style "width" "100%" ]
                [ div [ class "card-header", class "text-center" ] [ text (themeValueToFormattedString entry.theme.theme) ]
                , div [ class "card-body" ]
                    [ p [ class "card-text" ]
                        [ blockquote [ class "blockquote" ]
                            [ p []
                                [ text entry.content.quote
                                ]
                            ]
                        ]
                    , p
                        [ class "card-text"
                        ]
                        [ strong [] [ text entry.content.idea_nudge ]
                        ]
                    , p [ class "card-text" ]
                        [ text entry.content.idea
                        ]
                    , hr [] []
                    , p [ class "card-text" ]
                        [ strong []
                            [ text entry.content.thought_nudge
                            ]
                        ]
                    , p [ class "card-text" ] [ text entry.content.thought ]
                    ]
                ]
            ]
        ]


viewModal : Model -> Html Msg
viewModal model =
    div [] []



-- TODO: The colour of the nav bar has to be changed according to the theme chosen, to implement this the theme data will be required as part of the journal entry


buildNavBar : Model -> Html Msg
buildNavBar model =
    let
        journalEntry =
            case model.journalEntry of
                RemoteData.Success journal ->
                    journal

                _ ->
                    emptyJournalEntry

        ( colorAttr, navBarTextColor ) =
            case journalEntry.theme.theme of
                JournalTheme.None ->
                    ( class "bg-light", "black" )

                _ ->
                    ( style "background-color" journalEntry.theme.accentColor, "white" )
    in
    nav
        [ class "navbar navbar-expand-lg sticky-top"
        , colorAttr
        ]
        [ div [ class "container-fluid" ]
            [ a [ href "/", class "navbar-brand", style "color" navBarTextColor ]
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
                        [ a [ class "nav-link", attribute "aria-current" "page", href "/", style "color" navBarTextColor ] [ text "Home" ]
                        ]
                    , li [ class "nav-item" ]
                        [ a [ class "nav-link", href "/journals/new", style "color" navBarTextColor ] [ text "New Journal Entry" ]
                        ]
                    , li [ class "nav-item" ]
                        [ a [ class "nav-link", href "/journals/entries", style "color" navBarTextColor ] [ text "List Journal Entries" ]
                        ]
                    ]
                ]
            ]
        ]
