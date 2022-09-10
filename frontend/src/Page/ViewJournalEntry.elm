module Page.ViewJournalEntry exposing (..)

import Browser.Navigation as Nav
import Common.JournalEntry exposing (JournalEntry, JournalId, idToString, journalEntryDecoder)
import Common.JournalSection exposing (getField)
import Error exposing (buildHttpErrorMessage)
import Helpers exposing (dateTimeFromts)
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
            viewFetchError (buildHttpErrorMessage httpError)


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
                [ text (dateTimeFromts (Time.millisToPosix (entry.createdAt * 1000)))
                ]
            ]
        , div [ class "row", class "gy-2" ]
            [ div [ class "card", style "width" "100%" ]
                [ div [ class "card-header" ] [ text "Amor Fati" ]
                , div [ class "card-body" ]
                    [ p [ class "card-text" ]
                        [ strong []
                            [ text "What is something that you're glad happened to you in the last 6 months? It can be something you learnt, someone you met, a situation, etc. But, it should be something that you ddin't expect to happen"
                            ]
                        ]
                    , p [ class "card-text" ]
                        [ text (getField entry.content.amorFati "thoughts").value
                        ]
                    ]
                ]
            , div [ class "card", style "width" "100%" ]
                [ div [ class "card-header" ] [ text "Premeditatio Malorum" ]
                , div [ class "card-body" ]
                    [ div [ class "row gy-1" ]
                        [ p [ class "card-text" ]
                            [ strong []
                                [ text "What's a vice you think you might encounter today?"
                                ]
                            ]
                        , p [ class "card-text" ]
                            [ text (getField entry.content.premeditatioMalorum "vice").value
                            ]
                        , hr [] []
                        , p [ class "card-text" ]
                            [ strong []
                                [ text "How will you handle this vice?"
                                ]
                            ]
                        , p [ class "card-text" ]
                            [ text (getField entry.content.premeditatioMalorum "strategy").value
                            ]
                        ]
                    ]
                ]
            ]
        ]
