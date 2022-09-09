module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Page.ListJournalsEntries as ListJournals
import Page.NewJournalEntry as NewMorningJournal
import Route exposing (Route)
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
    | NewMorningJournalPage NewMorningJournal.Model



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
                            NewMorningJournal.init model.navKey
                    in
                    ( NewMorningJournalPage pageModel, Cmd.map NewMorningJournalMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



-- UPDATE


type Msg
    = ListJournalsMsg ListJournals.Msg
    | NewMorningJournalMsg NewMorningJournal.Msg
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

        ( NewMorningJournalMsg subMsg, NewMorningJournalPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewMorningJournal.update subMsg pageModel
            in
            ( { model | page = NewMorningJournalPage updatedPageModel }
            , Cmd.map NewMorningJournalMsg updatedCmd
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
    , body = [ currentView model ]
    }


currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        ListJournalsPage pageModel ->
            ListJournals.view pageModel
                |> Html.map ListJournalsMsg

        NewMorningJournalPage pageModel ->
            NewMorningJournal.view pageModel
                |> Html.map NewMorningJournalMsg


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]
