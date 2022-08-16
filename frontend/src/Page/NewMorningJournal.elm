module Page.NewMorningJournal exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Common.JournalSection as JournalSection
import Common.MorningJournal as MorningJournal
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
    = StoreAmorFatiThankYou String
    | StoreAmorFatiThoughts String
    | StorePremeditatioMalorumVice String
    | StorePremeditatioMalorumStrategy String
    | StoreSympatheiaPerson String
    | StoreSympatheiaRelationship String
    | StoreSympatheiaStrategy String
    | StoreSympatheiaGrowth String
    | CreateMorningJournalEntry
    | JournalEntryCreated (Result Http.Error MorningJournal.MorningJournal)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreAmorFatiThankYou thankYou ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "amor_fati" "thank_you" thankYou }, Cmd.none )

        StoreAmorFatiThoughts thoughts ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "amor_fati" "thoughts" thoughts }, Cmd.none )

        StorePremeditatioMalorumVice vice ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "premeditatio_malorum" "vice" vice }, Cmd.none )

        StorePremeditatioMalorumStrategy strategy ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "premeditatio_malorum" "strategy" strategy }, Cmd.none )

        StoreSympatheiaPerson person ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "sympatheia" "person" person }, Cmd.none )

        StoreSympatheiaRelationship rel ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "sympatheia" "relationship" rel }, Cmd.none )

        StoreSympatheiaStrategy strategy ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "sympatheia" "strategy" strategy }, Cmd.none )

        StoreSympatheiaGrowth growth ->
            ( { model | journal = MorningJournal.updateJournalContent model.journal "sympatheia" "self_growth" growth }, Cmd.none )

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

        -- sympatheia
        person =
            JournalSection.getField model.journal.content.sympatheia "person"

        relationship =
            JournalSection.getField model.journal.content.sympatheia "relationship"

        sympatheiaStrategy =
            JournalSection.getField model.journal.content.sympatheia "strategy"

        sympatheiaGrowth =
            JournalSection.getField model.journal.content.sympatheia "self_growth"

        -- memento mori
    in
    div []
        [ div [ id "amor-fati" ]
            [ h2 [] [ text "Amor Fati" ]
            , div [] [ text "Your fate is to go through life each day. What happens is dictated by it and you can only react to what happens. So, you might as well love your fate" ]
            , br [] []
            , div [] [ text "You've woken up today! Many people will not have the privilege to do so today. So, say thank you for waking up today!" ]
            , input [ placeholder "Say Thank You", value thankYou.value, onInput StoreAmorFatiThankYou ] []
            , br [] []
            , input [ placeholder "Amor Fati", value thoughts.value, onInput StoreAmorFatiThoughts ] []
            ]
        , div []
            [ h2 [] [ text "Premeditatio Malorum" ]
            , div [] [ text "Unexpectdness adds weight to disaster. Whatever that disaster might be to you, think about it, see it happen to you in your minds eye and then think of what you can do handle it when it does happen to you" ]
            , br [] []
            , input [ placeholder "What's a vice you think you might encounter today?", value vice.value, onInput StorePremeditatioMalorumVice ] []
            , br [] []
            , input [ placeholder "How will you handle this vice?", value premeditatioMalorumStrategy.value, onInput StorePremeditatioMalorumStrategy ] []
            ]
        , div []
            [ h2 [] [ text "Sympatheia" ]
            , div [] [ text "Revere nature, and look after each other. Life is short—the fruit of this life is a good character and acts for the common good." ]
            , br [] []
            , input [ placeholder "Sympatheia", value person.value, onInput StoreSympatheiaPerson ] []
            , br [] []
            , input [ placeholder "Sympatheia", value relationship.value, onInput StoreSympatheiaRelationship ] []
            , br [] []
            , input [ placeholder "How will you help this person today?", value sympatheiaStrategy.value, onInput StoreSympatheiaStrategy ] []
            , br [] []
            , input [ placeholder "How will you help this person today?", value sympatheiaGrowth.value, onInput StoreSympatheiaGrowth ] []
            ]
        , br [] []
        , div [] [ button [ type_ "button", onClick CreateMorningJournalEntry ] [ text "Save Journal Entry" ] ]
        , div [ class "error-notifier" ] [ text (stringFromMaybeString model.createJournalEntryError) ]
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
