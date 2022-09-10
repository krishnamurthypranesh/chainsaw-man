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
    }


type Page
    = NotFoundPage
    | ListJournalsPage ListJournals.Model
    | NewJournalEntryPage NewJournalEntry.Model
    | ViewJournalEntryPage ViewJournalEntry.Model



-- add option for home page
-- INIT


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url, page = NotFoundPage, navKey = navKey }
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
                ( updatedPageModel, updatedCmd ) =
                    ListJournals.update subMsg pageModel
            in
            ( { model | page = ListJournalsPage updatedPageModel }
            , Cmd.map ListJournalsMsg updatedCmd
            )

        ( NewJournalEntryMsg subMsg, NewJournalEntryPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewJournalEntry.update subMsg pageModel
            in
            ( { model | page = NewJournalEntryPage updatedPageModel }
            , Cmd.map NewJournalEntryMsg updatedCmd
            )

        ( ViewJournalEntryMsg subMsg, ViewJournalEntryPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
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
    { title = "Everyday Stoic Journal"
    , body = [ getNavBar, currentView model ]
    }



-- add the common html code here


getNavBar : Html Msg
getNavBar =
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


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]
