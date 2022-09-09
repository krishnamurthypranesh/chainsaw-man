module Page.NewJournalEntry exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Common.JournalEntry as MorningJournal
import Common.JournalSection as JournalSection
import Error exposing (buildHttpErrorMessage)
import Helpers exposing (stringFromMaybeString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (string)



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , journal : MorningJournal.MorningJournal
    , createJournalEntryError : Maybe String
    }



-- UPDATE


type Msg
    = StoreAmorFatiThoughts String
    | StorePremeditatioMalorumVice String
    | StorePremeditatioMalorumStrategy String
    | CreateMorningJournalEntry
    | JournalEntryCreated (Result Http.Error MorningJournal.MorningJournal)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreAmorFatiThoughts thoughts ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "amor_fati" "thoughts" thoughts }, Cmd.none )

        StorePremeditatioMalorumVice vice ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "premeditatio_malorum" "vice" vice }, Cmd.none )

        StorePremeditatioMalorumStrategy strategy ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "premeditatio_malorum" "strategy" strategy }, Cmd.none )

        CreateMorningJournalEntry ->
            ( model, createMorningJournalEntry model.journal )

        JournalEntryCreated (Ok _) ->
            ( model, Cmd.none )

        JournalEntryCreated (Err error) ->
            ( { model | createJournalEntryError = Just (buildHttpErrorMessage error) }, Cmd.none )


createMorningJournalEntry : MorningJournal.MorningJournal -> Cmd Msg
createMorningJournalEntry journal =
    Http.post
        { url = "http://localhost:8080/journalEntry/create/"
        , body = Http.jsonBody (MorningJournal.newMorningJournalEncoder journal)
        , expect = Http.expectJson JournalEntryCreated MorningJournal.morningJournalDecoder
        }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "New Morning Journal Entry" ]
        , newJournalEntryForm model
        ]


newJournalEntryForm : Model -> Html Msg
newJournalEntryForm model =
    let
        -- amor fati
        thankYou =
            JournalSection.getField model.journal.content.amorFati "thank_you"

        thoughts =
            JournalSection.getField model.journal.content.amorFati "thoughts"

        -- premeditatio malorum
        vice =
            JournalSection.getField model.journal.content.premeditatioMalorum "vice"

        premeditatioMalorumStrategy =
            JournalSection.getField model.journal.content.premeditatioMalorum "strategy"
    in
    div [ class "container" ]
        [ div [ class "row", id "amor-fati" ]
            [ h2 [ class "display-2" ] [ text model.journal.content.amorFati.title ]
            , p [ class "lead" ]
                [ text "Your fate is to go through life each day. What happens is dictated by it and you can only react to what happens. So, you might as well love your fate"
                ]
            , label [ class "form-label" ] [ text "You've woken up today! Many people will not have the privilege to do so today. So, say thank you for waking up today!" ]
            , br [] []
            , label [ class "form-label" ]
                [ text "What is something that you're glad happened to you in the last 6 months? It can be something you learnt, someone you met, a situation, etc. But, it should be something that you ddin't expect to happen" ]
            , div
                [ class "input-group mb-3" ]
                [ textarea [ cols 100, rows 10, placeholder "Amor Fati", value thoughts.value, onInput StoreAmorFatiThoughts ] []
                ]
            ]
        , div [ class "row", id "premeditatio-malorum" ]
            [ h2 [] [ text model.journal.content.premeditatioMalorum.title ]
            , p [ class "lead" ] [ text "Unexpectdness adds weight to disaster. Whatever that disaster might be to you, think about it, see it happen to you in your minds eye and then think of what you can do handle it when it does happen to you" ]
            , label [ class "form-label" ]
                [ text "What's a vice you think you might encounter today?" ]
            , div
                [ class "input-group mb-3" ]
                [ input [ placeholder "", value vice.value, onInput StorePremeditatioMalorumVice ] []
                ]
            , br [] []
            , label [ class "form-label" ]
                [ text "How will you handle this vice?"
                ]
            , div [ class "input-grouop mb-3" ]
                [ textarea [ cols 100, rows 10, placeholder "", value premeditatioMalorumStrategy.value, onInput StorePremeditatioMalorumStrategy ] []
                ]
            ]
        , br [] []
        , div [ class "row" ]
            [ button [ type_ "button", onClick CreateMorningJournalEntry, class "btn btn-primary" ] [ text "Save Journal Entry" ]
            , br [] []
            , br [] []
            , buildErrorMessage model.createJournalEntryError
            ]
        ]


buildErrorMessage : Maybe String -> Html Msg
buildErrorMessage error =
    case error of
        Nothing ->
            div [ class "error-notifier alert alert-danger hidden" ] [ text "" ]

        Just val ->
            div [ class "alert alert-danger" ] [ text val ]



-- INIT


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( initialModel navKey, Cmd.none )


initialModel : Nav.Key -> Model
initialModel navKey =
    let
        journal =
            MorningJournal.emptyMorningJournal
    in
    { navKey = navKey, journal = journal, createJournalEntryError = Nothing }
