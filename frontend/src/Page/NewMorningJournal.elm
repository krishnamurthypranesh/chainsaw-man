module Page.NewMorningJournal exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Error exposing (buildHttpErrorMessage)
import Helpers exposing (stringFromMaybeString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (string)
import Page.AmorFati as AmorFati
import Page.MorningJournal as MorningJournal



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , journal : MorningJournal.MorningJournal
    , createJournalEntryError : Maybe String
    }



-- UPDATE


type Msg
    = StoreAmorFatiThankYou String
    | StoreAmorFatiThoughts String
    | CreateMorningJournalEntry
    | JournalEntryCreated (Result Http.Error MorningJournal.MorningJournal)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreAmorFatiThankYou thankYou ->
            let
                oldJournal =
                    model.journal

                oldAmorFati =
                    oldJournal.content.amorFati

                newJournal =
                    { oldJournal | content = MorningJournal.setAmorFati oldJournal.content (AmorFati.updateThankYou oldAmorFati thankYou) }
            in
            ( { model | journal = newJournal }, Cmd.none )

        StoreAmorFatiThoughts thoughts ->
            let
                oldJournal =
                    model.journal

                oldAmorFati =
                    oldJournal.content.amorFati

                newJournal =
                    { oldJournal | content = MorningJournal.setAmorFati oldJournal.content (AmorFati.updateThoughts oldAmorFati thoughts) }
            in
            ( { model | journal = newJournal }, Cmd.none )

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
    div []
        [ div [ id "amor-fati" ]
            [ h2 [] [ text "Amor Fati" ]
            , div [] [ text "Your fate is to go through life each day. What happens is dictated by it and you can only react to what happens. So, you might as well love your fate" ]
            , br [] []
            , div [] [ text "You've woken up today! Many people will not have the privilege to do so today. So, say thank you for waking up today!" ]
            , input [ placeholder "Say Thank You", value model.journal.content.amorFati.thankYou, onInput StoreAmorFatiThankYou ] []
            , br [] []
            , input [ placeholder "Amor Fati", value model.journal.content.amorFati.thoughts, onInput StoreAmorFatiThoughts ] []
            ]
        , br [] []
        , div [] [ button [ type_ "button", onClick CreateMorningJournalEntry ] [ text "Save Journal Entry" ] ]
        , div [ class "error-notifier" ] [ text (Helpers.stringFromMaybeString model.createJournalEntryError) ]
        ]



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
