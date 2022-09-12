module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, id, style, type_)
import Page.ListJournalsEntries as ListJournals
import Page.NewJournalEntry as NewJournalEntry
import Page.ViewJournalEntry as ViewJournalEntry
import Route exposing (Route(..))
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    , modal : Maybe Modal
    }


type Page
    = NotFoundPage
    | ListJournalsPage ListJournals.Model
    | NewJournalEntryPage NewJournalEntry.Model
    | ViewJournalEntryPage ViewJournalEntry.Model


type Modal
    = NewJournalEntryModal NewJournalEntry.Modal
    | ListJouranlsModal ListJournals.Modal
    | ViewJournalEntryModal ViewJournalEntry.Modal



-- add option for home page
-- INIT


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url, page = NotFoundPage, navKey = navKey, modal = Nothing }
    in
    initCurrentPage ( model, Cmd.none )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.ListJournalEntries ->
                    let
                        ( pageModel, pageCmds ) =
                            ListJournals.init
                    in
                    ( ListJournalsPage pageModel, Cmd.map ListJournalsMsg pageCmds )

                Route.NewJournalEntry ->
                    let
                        ( pageModel, pageCmds ) =
                            NewJournalEntry.init model.navKey
                    in
                    ( NewJournalEntryPage pageModel, Cmd.map NewJournalEntryMsg pageCmds )

                Route.ViewJournalEntry journalId ->
                    let
                        ( pageModel, pageCmds ) =
                            ViewJournalEntry.init journalId model.navKey
                    in
                    ( ViewJournalEntryPage pageModel, Cmd.map ViewJournalEntryMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



-- UPDATE


type Msg
    = ListJournalsMsg ListJournals.Msg
    | NewJournalEntryMsg NewJournalEntry.Msg
    | ViewJournalEntryMsg ViewJournalEntry.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ListJournalsMsg subMsg, ListJournalsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd, _ ) =
                    ListJournals.update subMsg pageModel
            in
            ( { model | page = ListJournalsPage updatedPageModel }
            , Cmd.map ListJournalsMsg updatedCmd
            )

        ( NewJournalEntryMsg subMsg, NewJournalEntryPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd, modalMsg ) =
                    NewJournalEntry.update subMsg pageModel
            in
            ( { model | page = NewJournalEntryPage updatedPageModel }
            , Cmd.map NewJournalEntryMsg updatedCmd
            )

        ( ViewJournalEntryMsg subMsg, ViewJournalEntryPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd, _ ) =
                    ViewJournalEntry.update subMsg pageModel
            in
            ( { model | page = ViewJournalEntryPage updatedPageModel }
            , Cmd.map ViewJournalEntryMsg updatedCmd
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Pained Porch"
    , body =
        [ currentNavBar model
        , currentModal model
        , currentView model
        ]
    }



-- add the common html code here


currentNavBar : Model -> Html Msg
currentNavBar model =
    case model.page of
        NotFoundPage ->
            notFoundView

        ListJournalsPage pageModel ->
            ListJournals.buildNavBar pageModel
                |> Html.map ListJournalsMsg

        NewJournalEntryPage pageModel ->
            NewJournalEntry.buildNavBar pageModel
                |> Html.map NewJournalEntryMsg

        ViewJournalEntryPage pageModel ->
            ViewJournalEntry.buildNavBar pageModel
                |> Html.map ViewJournalEntryMsg


currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        ListJournalsPage pageModel ->
            ListJournals.view pageModel
                |> Html.map ListJournalsMsg

        NewJournalEntryPage pageModel ->
            NewJournalEntry.view pageModel
                |> Html.map NewJournalEntryMsg

        ViewJournalEntryPage pageModel ->
            ViewJournalEntry.view pageModel
                |> Html.map ViewJournalEntryMsg


currentModal : Model -> Html Msg
currentModal model =
    case model.page of
        NotFoundPage ->
            Debug.todo "branch 'NotFoundPage' not implemented"

        NewJournalEntryPage pageModel ->
            NewJournalEntry.viewModal pageModel
                |> Html.map NewJournalEntryMsg

        ListJournalsPage pageModel ->
            ListJournals.viewModal pageModel
                |> Html.map ListJournalsMsg

        ViewJournalEntryPage pageModel ->
            ViewJournalEntry.viewModal pageModel
                |> Html.map ViewJournalEntryMsg


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]
