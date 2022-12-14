module Page.NewJournalEntry exposing (Modal(..), Model, Msg, OutMsg(..), buildNavBar, init, update, view, viewModal)

import Browser.Navigation as Nav
import Common.JournalEntry exposing (JournalEntry, emptyJournalEntry, journalEntryDecoder, journalEntryEncoder, updateJournalIdea, updateJournalThought)
import Common.JournalTheme as JournalTheme
import Common.Toast as Toast
import Error exposing (errorFromHttpError)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import List exposing (drop)
import Logger exposing (logMessage)
import Process
import RemoteData exposing (WebData)
import Task



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , journal : JournalEntry
    , createJournalEntryError : Maybe String
    , toastData : Toast.Model
    , selectedJournalTheme : Maybe JournalTheme.JournalTheme
    , journalThemesList : WebData (List JournalTheme.JournalTheme)
    , journalingStarted : Bool
    , isModalOpen : Bool
    }


type alias ModalOptions =
    { hideValue : String
    , ariaAttributeName : String
    , styleDisplayValue : String
    , roleAttributeName : String
    , roleAttributeValue : String
    , dropdownText : String
    }



-- UPDATE


type
    Msg
    -- storing journal content
    = StoreJournalIdea String
    | StoreJournalThought String
      -- fetching and choosing journal themes
    | FetchJournalThemes
    | JournalThemesReceived (WebData (List JournalTheme.JournalTheme))
    | JournalThemeSelected JournalTheme.ThemeValue
    | StartJournaling
    | CloseThemeSelectModal
      -- saving journal entry
    | CreateMorningJournalEntry
    | JournalEntryCreated (Result Http.Error JournalEntry)
    | ToastVisibilityToggle Toast.Msg


type OutMsg
    = OpenModal Modal
    | CloseModal Modal


type Modal
    = ThemeSelectModal


update : Msg -> Model -> ( Model, Cmd Msg, Modal -> OutMsg )
update msg model =
    case msg of
        StoreJournalIdea idea ->
            ( { model | journal = updateJournalIdea model.journal idea }, Cmd.none, CloseModal )

        StoreJournalThought thoughts ->
            ( { model | journal = updateJournalThought model.journal thoughts }, Cmd.none, CloseModal )

        FetchJournalThemes ->
            ( { model | journalThemesList = RemoteData.Loading, isModalOpen = True }, fetchJournalThemes, OpenModal )

        JournalThemesReceived themes ->
            ( { model | journalThemesList = themes }, Cmd.none, OpenModal )

        CreateMorningJournalEntry ->
            ( model, createMorningJournalEntry model.journal, CloseModal )

        JournalEntryCreated (Ok _) ->
            let
                cmd =
                    delay model.toastData 5000.0 Toast.ShowToast

                newToastData =
                    Toast.Model Toast.ShowToast "Entry created successfully" Toast.Info
            in
            ( { model | toastData = newToastData }, cmd, CloseModal )

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
            ( { model | toastData = newToastData }, cmd, CloseModal )

        JournalThemeSelected theme ->
            let
                themesList =
                    case model.journalThemesList of
                        RemoteData.Success ts ->
                            ts

                        _ ->
                            []

                isSelectedTheme t =
                    if JournalTheme.themeValueToString theme == JournalTheme.themeValueToString t.theme then
                        True

                    else
                        False

                selectedTheme =
                    List.filter isSelectedTheme themesList
                        |> List.head

                themeData =
                    case selectedTheme of
                        Just v ->
                            v

                        Nothing ->
                            JournalTheme.emptyJournalTheme

                oldJournal =
                    model.journal

                oldContent =
                    oldJournal.content

                newContent =
                    { oldContent
                        | quote = themeData.data.quote
                        , idea_nudge = themeData.data.ideaNudge
                        , thought_nudge = themeData.data.thoughtNudge
                    }

                newJournal =
                    { oldJournal | theme = themeData, content = newContent }
            in
            ( { model | selectedJournalTheme = selectedTheme, journal = newJournal }, Cmd.none, OpenModal )

        CloseThemeSelectModal ->
            ( { model | selectedJournalTheme = Nothing, isModalOpen = False }, Cmd.none, CloseModal )

        StartJournaling ->
            ( { model | journalingStarted = True, isModalOpen = False }, Cmd.none, CloseModal )

        -- TODO: Invalidate this case. All toasts should be handled in the main module
        ToastVisibilityToggle toggle ->
            let
                newToastData =
                    Toast.Model Toast.HideToast "" Toast.None
            in
            ( { model | toastData = newToastData }, Cmd.none, CloseModal )


createMorningJournalEntry : JournalEntry -> Cmd Msg
createMorningJournalEntry journal =
    Http.post
        { url = "http://localhost:8080/v1/journals"
        , body = Http.jsonBody (journalEntryEncoder journal)
        , expect = Http.expectJson JournalEntryCreated journalEntryDecoder
        }


fetchJournalThemes : Cmd Msg
fetchJournalThemes =
    Http.get
        { url = "http://localhost:8080/v1/themes"
        , expect =
            JournalTheme.journalThemeListDecoder
                |> Http.expectJson (RemoteData.fromResult >> JournalThemesReceived)
        }



-- VIEW


view : Model -> Html Msg
view model =
    let
        ( formHtml, classList ) =
            case model.selectedJournalTheme of
                Nothing ->
                    ( div [] [], [] )

                Just theme ->
                    let
                        cL =
                            [ class "container" ]

                        updatedCL =
                            if model.isModalOpen then
                                style "filter" "blur(2px)" :: cL

                            else
                                cL

                        _ =
                            Debug.log "CLASS LIST" updatedCL
                    in
                    ( newJournalEntryForm model, updatedCL )
    in
    div classList
        [ formHtml
        ]


newJournalEntryForm : Model -> Html Msg
newJournalEntryForm model =
    let
        selectedTheme =
            case model.selectedJournalTheme of
                Just v ->
                    v

                Nothing ->
                    JournalTheme.emptyJournalTheme
    in
    div
        []
        [ buildToastHtml model.toastData
        , div [ class "row", id "journal-content-section" ]
            [ h2 [ class "display-2" ] [ text selectedTheme.name ]
            , p [ class "lead" ] [ text selectedTheme.data.quote ]
            , label [ class "form-label" ]
                [ text selectedTheme.data.ideaNudge ]
            , div
                [ class "input-group mb-3" ]
                [ input [ placeholder "", value model.journal.content.idea, onInput StoreJournalIdea ] []
                ]
            , br [] []
            , label [ class "form-label" ]
                [ text selectedTheme.data.thoughtNudge ]
            , div [ class "input-group mb-3" ]
                [ textarea [ cols 100, rows 10, placeholder "", value model.journal.content.thought, onInput StoreJournalThought, style "width" "100%" ] []
                ]
            ]
        , br [] []
        , div [ class "row" ]
            [ button [ type_ "button", onClick CreateMorningJournalEntry, class "btn btn-primary" ] [ text "Save Journal Entry" ]
            , br [] []
            , br [] []
            ]
        ]


buildDropDownOptionsFromJournalThemeList : List JournalTheme.JournalTheme -> List (Html Msg)
buildDropDownOptionsFromJournalThemeList themes =
    List.map buildOptionFromJournalTheme themes


buildOptionFromJournalTheme : JournalTheme.JournalTheme -> Html Msg
buildOptionFromJournalTheme theme =
    li
        []
        [ a [ class "dropdown-item", href "#", style "color" theme.accentColor, onClick (JournalThemeSelected theme.theme) ]
            [ text (theme.name ++ " - " ++ theme.shortDescription)
            ]
        ]


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


viewModalHeader : Html Msg
viewModalHeader =
    div [ class "modal-header" ]
        [ h5 [ class "modal-title", class "text-center", id "themeSelectModalLabel" ] [ text "Choose Theme" ]

        -- add an onlick CloseModal event here
        , button [ type_ "button", class "btn-close", attribute "data-bs-dismiss" "modal", attribute "aria-label" "Close", onClick CloseThemeSelectModal ] []
        ]


viewModalBody : Model -> Html Msg
viewModalBody model =
    let
        selectedTheme =
            case model.selectedJournalTheme of
                Just theme ->
                    theme

                Nothing ->
                    JournalTheme.emptyJournalTheme

        options =
            getModalOpts selectedTheme

        dropdownOptions =
            buildDropDownOptionsFromJournalThemeList

        modalBodyContent =
            case model.journalThemesList of
                RemoteData.NotAsked ->
                    div [] []

                RemoteData.Loading ->
                    div [ class "row gy-4" ]
                        [ div [ class "col text-center" ]
                            [ div [ class "spinner-border", class "text-secondary" ]
                                [ span [ class "visually-hidden" ] [ text "Loading..." ]
                                ]
                            ]
                        ]

                RemoteData.Success themes ->
                    div [ class "row gy-4" ]
                        [ div [ class "dropdown" ]
                            [ button
                                [ class "btn"
                                , class "dropdown-toggle"
                                , type_ "button"
                                , attribute "data-bs-toggle" "dropdown"
                                , attribute "aria-expanded" "false"
                                , style "border" "1px solid black"
                                ]
                                [ text options.dropdownText
                                ]
                            , ul [ class "dropdown-menu" ] (buildDropDownOptionsFromJournalThemeList themes)
                            , p
                                [ style "margin-top" "1rem"
                                , style "margin-bottom" "2px"
                                ]
                                [ text selectedTheme.detailedDescription ]
                            ]
                        ]

                RemoteData.Failure _ ->
                    h3 [] [ text "Failed to fetch themes" ]
    in
    div [ class "modal-body" ] [ modalBodyContent ]


viewModalFooter : JournalTheme.JournalTheme -> Html Msg
viewModalFooter theme =
    let
        baseAttrList =
            [ type_ "button"
            , class "btn"
            , onClick StartJournaling
            ]

        buttonColor =
            case theme.theme of
                JournalTheme.None ->
                    "ghostwhite"

                _ ->
                    theme.accentColor

        withButtonColor =
            style "background-color" buttonColor :: baseAttrList

        withButtonTextStyle =
            case theme.theme of
                JournalTheme.None ->
                    style "color" "black" :: withButtonColor

                _ ->
                    style "color" "white" :: withButtonColor

        finalAttrList =
            case theme.theme of
                JournalTheme.None ->
                    attribute "disabled" "" :: withButtonTextStyle

                _ ->
                    withButtonTextStyle
    in
    div [ class "modal-footer", style "justify-content" "space-between" ]
        [ button [ type_ "button", class "btn", class "btn-light", attribute "data-bs-dismiss" "modal" ] [ text "Surprise Me!" ]
        , button finalAttrList [ text "Start Journaling" ]
        ]


getModalOpts : JournalTheme.JournalTheme -> ModalOptions
getModalOpts theme =
    let
        options =
            ModalOptions "" "" "" "" "" ""

        hideValue =
            "show"

        ariaAttributeName =
            "aria-modal"

        styleDisplayValue =
            "block"

        ( roleAttributeName, roleAttributeValue ) =
            ( "role", "dialog" )

        dropdownText =
            case theme.theme of
                JournalTheme.None ->
                    "Choose your journal's theme"

                _ ->
                    theme.name ++ " - " ++ theme.shortDescription
    in
    { options
        | hideValue = hideValue
        , ariaAttributeName = ariaAttributeName
        , styleDisplayValue = styleDisplayValue
        , roleAttributeName = roleAttributeName
        , roleAttributeValue = roleAttributeValue
        , dropdownText = dropdownText
    }


viewModal : Model -> Html Msg
viewModal model =
    let
        selectedTheme =
            case model.selectedJournalTheme of
                Just theme ->
                    theme

                Nothing ->
                    JournalTheme.emptyJournalTheme
    in
    div
        [ class "modal fade"
        , class "show"
        , class "modal-lg"
        , style "display" "block"
        , id "themeSelectModal"
        , attribute "tabindex" "-1"
        , attribute "aria-labelledby" "themeSelectModalLabel"
        , attribute "aria-modal" "true"
        , attribute "role" "dialog"
        ]
        [ div [ class "modal-dialog" ]
            [ div [ class "modal-content" ]
                [ viewModalHeader
                , viewModalBody model
                , viewModalFooter selectedTheme
                ]
            ]
        ]


buildNavBar : Model -> Html Msg
buildNavBar model =
    let
        -- TODO: Fix bug in navbar display when closing modal before theme list data is loaded
        -- Closing the modal before the theme list data is loaded results in the modal popping up again once the data has been fetched
        -- This is bad Ux. It's annoying. Fix this later
        -- I have to maintain the following information: 1. Has the modal already been opened once before?
        -- I think I'll pick this up later
        selectedTheme =
            model.journal.theme

        ( styleFilter, styleFilterValue ) =
            if model.isModalOpen then
                ( "filter", "blur(2px)" )

            else
                ( "", "" )

        ( colorAttr, navBarTextColor ) =
            case selectedTheme.theme of
                JournalTheme.None ->
                    ( class "bg-light", "black" )

                _ ->
                    ( style "background-color" selectedTheme.accentColor, "white" )
    in
    nav
        [ class "navbar navbar-expand-lg sticky-top"
        , colorAttr
        , style styleFilter styleFilterValue
        ]
        [ div [ class "container-fluid" ]
            [ a
                [ href "/"
                , class "navbar-brand"
                , style "color" navBarTextColor
                ]
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
                        [ a
                            [ class "nav-link"
                            , attribute "aria-current" "page"
                            , href "/"
                            , style "color" navBarTextColor
                            ]
                            [ text "Home" ]
                        ]
                    , li [ class "nav-item" ]
                        [ a
                            [ class "nav-link"
                            , href "/journals/new"
                            , class "active"
                            , style "color" navBarTextColor
                            ]
                            [ text "New Journal Entry" ]
                        ]
                    , li [ class "nav-item" ]
                        [ a
                            [ class "nav-link"
                            , href "/journals/entries"
                            , style "color" navBarTextColor
                            ]
                            [ text "List Journal Entries" ]
                        ]
                    ]
                ]
            ]
        ]


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



-- INIT


init : Nav.Key -> ( Model, Cmd Msg, Modal -> OutMsg )
init navKey =
    ( initialModel navKey, fetchJournalThemes, OpenModal )


initialModel : Nav.Key -> Model
initialModel navKey =
    let
        journal =
            emptyJournalEntry

        toast =
            Toast.Model Toast.HideToast "" Toast.None

        themeData =
            Nothing
    in
    { navKey = navKey, journal = journal, createJournalEntryError = Nothing, toastData = toast, selectedJournalTheme = themeData, journalThemesList = RemoteData.Loading, journalingStarted = False, isModalOpen = True }
