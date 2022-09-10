module Page.NewJournalEntry exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Common.JournalEntry exposing (JournalEntry, emptyMorningJournal, journalEntryDecoder, newMorningJournalEncoder, updateJournalContent)
import Common.JournalSection as JournalSection
import Common.Toast as Toast
import Error exposing (errorFromHttpError)
import Helpers exposing (stringFromMaybeString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (int, string)
import Logger exposing (logMessage)
import Process
import Task



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , journal : JournalEntry
    , createJournalEntryError : Maybe String
    , toastData : Toast.Model
    }



-- UPDATE


type Msg
    = StoreAmorFatiThoughts String
    | StorePremeditatioMalorumVice String
    | StorePremeditatioMalorumStrategy String
    | CreateMorningJournalEntry
    | JournalEntryCreated (Result Http.Error JournalEntry)
    | ToastVisibilityToggle Toast.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreAmorFatiThoughts thoughts ->
            ( { model | journal = updateJournalContent model.journal "amor_fati" "thoughts" thoughts }, Cmd.none )

        StorePremeditatioMalorumVice vice ->
            ( { model | journal = updateJournalContent model.journal "premeditatio_malorum" "vice" vice }, Cmd.none )

        StorePremeditatioMalorumStrategy strategy ->
            ( { model | journal = updateJournalContent model.journal "premeditatio_malorum" "strategy" strategy }, Cmd.none )

        CreateMorningJournalEntry ->
            ( model, createMorningJournalEntry model.journal )

        JournalEntryCreated (Ok _) ->
            let
                cmd =
                    delay model.toastData 5000.0 Toast.ShowToast

                newToastData =
                    Toast.Model Toast.ShowToast "Entry created successfully" Toast.Info
            in
            ( { model | toastData = newToastData }, cmd )

        JournalEntryCreated (Err error) ->
            let
                _ =
                    logMessage (errorFromHttpError error)
                        Logger.LevelError

                newToastData =
                    Toast.Model Toast.ShowToast "Error occurred when creating entry" Toast.Error

                cmd =
                    delay model.toastData 5000.0 Toast.ShowToast
            in
            ( { model | toastData = newToastData }, cmd )

        ToastVisibilityToggle toggle ->
            let
                newToastData =
                    Toast.Model Toast.HideToast "" Toast.None
            in
            ( { model | toastData = newToastData }, Cmd.none )


createMorningJournalEntry : JournalEntry -> Cmd Msg
createMorningJournalEntry journal =
    Http.post
        { url = "http://localhost:8080/journal/entry/create/"
        , body = Http.jsonBody (newMorningJournalEncoder journal)
        , expect = Http.expectJson JournalEntryCreated journalEntryDecoder
        }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ newJournalEntryForm model
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
        [ buildToastHtml model.toastData
        , div
            [ class "row", id "amor-fati" ]
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
                [ textarea [ cols 100, rows 10, value thoughts.value, onInput StoreAmorFatiThoughts, style "width" "100%" ] []
                ]
            ]
        , div [ class "row", id "premeditatio-malorum" ]
            [ h2 [ class "display-2" ] [ text model.journal.content.premeditatioMalorum.title ]
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
                [ textarea [ cols 100, rows 10, placeholder "", value premeditatioMalorumStrategy.value, onInput StorePremeditatioMalorumStrategy, style "width" "100%" ] []
                ]
            ]
        , br [] []
        , div [ class "row" ]
            [ button [ type_ "button", onClick CreateMorningJournalEntry, class "btn btn-primary" ] [ text "Save Journal Entry" ]
            , br [] []
            , br [] []
            ]
        ]


buildErrorMessage : Maybe String -> Html Msg
buildErrorMessage error =
    case error of
        Nothing ->
            div [ class "error-notifier alert alert-danger hidden" ] [ text "" ]

        Just val ->
            div [ class "alert alert-danger" ] [ text val ]


buildToastHtml : Toast.Model -> Html Msg
buildToastHtml model =
    let
        showToastValue =
            case model.showToast of
                Toast.ShowToast ->
                    "show"

                Toast.HideToast ->
                    "hide"

        toastBgColor =
            case model.toastType of
                Toast.Info ->
                    "text-bg-primary"

                Toast.Warn ->
                    "text-bg-warning"

                Toast.Error ->
                    "text-bg-danger"

                Toast.None ->
                    ""
    in
    div
        [ class "toast-container"
        , class "position-fixed"
        , class "bottom-0"
        , class "end-0"
        , class "p-3"
        ]
        [ div
            [ id "liveToast"
            , class "toast"
            , class showToastValue
            , class toastBgColor
            , attribute "role" "alert"
            , attribute "aria-live" "assertive"
            , attribute "aria-atomic" "true"
            ]
            [ div
                [ class "toast-header"
                ]
                [ img
                    [ src "..."
                    , class "rounded me-2"
                    , alt "..."
                    ]
                    []
                , strong [ class "me-auto" ] [ text "Success" ]
                , small [] [ text "Just now" ]
                , button
                    [ type_ "button"
                    , class
                        "btn-close"
                    , attribute "data-bs-dismiss" "toast"
                    , attribute "aria-label" "Close"
                    ]
                    []
                ]
            , div [ class "toast-body" ]
                [ text model.toastMessage
                ]
            ]
        ]



-- INIT


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( initialModel navKey, Cmd.none )


initialModel : Nav.Key -> Model
initialModel navKey =
    let
        journal =
            emptyMorningJournal

        toast =
            Toast.Model Toast.HideToast "" Toast.None
    in
    { navKey = navKey, journal = journal, createJournalEntryError = Nothing, toastData = toast }


delay : Toast.Model -> Float -> Toast.Msg -> Cmd Msg
delay toast interval msg =
    let
        newMsg =
            case msg of
                Toast.ShowToast ->
                    ToastVisibilityToggle Toast.HideToast

                Toast.HideToast ->
                    ToastVisibilityToggle Toast.HideToast
    in
    Process.sleep interval
        |> Task.perform (\_ -> newMsg)
