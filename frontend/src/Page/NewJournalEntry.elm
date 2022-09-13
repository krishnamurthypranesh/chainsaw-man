module Page.NewJournalEntry exposing (Modal(..), Model, Msg, OutMsg(..), buildNavBar, init, update, view, viewModal)

import Browser.Navigation as Nav
import Common.JournalEntry exposing (JournalEntry, emptyMorningJournal, journalEntryDecoder, newMorningJournalEncoder, updateJournalContent)
import Common.JournalSection as JournalSection
import Common.JournalTheme as JournalTheme
import Common.Toast as Toast
import Error exposing (errorFromHttpError)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
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
    , selectedJournalTheme : JournalTheme.JournalTheme
    , journalThemesList : WebData (List JournalTheme.JournalTheme)
    , journalingStarted : Bool
    }


type alias ModalOptions =
    { hideValue : String
    , ariaAttributeName : String
    , styleDisplayValue : String
    , roleAttributeName : String
    , roleAttributeValue : String
    }



-- UPDATE


type
    Msg
    -- storing journal content
    = StoreAmorFatiThoughts String
    | StorePremeditatioMalorumVice String
    | StorePremeditatioMalorumStrategy String
      -- fetching and choosing journal themes
    | FetchJournalThemes
    | JournalThemesReceived (WebData (List JournalTheme.JournalTheme))
    | JournalThemeSelected JournalTheme.ThemeValue
    | StartJournaling
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
        StoreAmorFatiThoughts thoughts ->
            ( { model | journal = updateJournalContent model.journal "amor_fati" "thoughts" thoughts }, Cmd.none, CloseModal )

        StorePremeditatioMalorumVice vice ->
            ( { model | journal = updateJournalContent model.journal "premeditatio_malorum" "vice" vice }, Cmd.none, CloseModal )

        StorePremeditatioMalorumStrategy strategy ->
            ( { model | journal = updateJournalContent model.journal "premeditatio_malorum" "strategy" strategy }, Cmd.none, CloseModal )

        FetchJournalThemes ->
            ( { model | journalThemesList = RemoteData.Loading }, fetchJournalThemes, OpenModal )

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

                _ =
                    Debug.log "themes list" themesList

                isSelectedTheme t =
                    if JournalTheme.themeValueToString theme == JournalTheme.themeValueToString t.theme then
                        True

                    else
                        False

                maybeSelectedTheme =
                    List.filter isSelectedTheme themesList
                        |> List.head

                _ =
                    Debug.log "maybe selected theme" maybeSelectedTheme

                selectedTheme =
                    case maybeSelectedTheme of
                        Just t ->
                            t

                        Nothing ->
                            JournalTheme.JournalTheme JournalTheme.None "" "" "" ""

                _ =
                    Debug.log "selected theme" selectedTheme
            in
            ( { model | selectedJournalTheme = selectedTheme }, Cmd.none, OpenModal )

        StartJournaling ->
            ( { model | journalingStarted = True }, Cmd.none, CloseModal )

        ToastVisibilityToggle toggle ->
            let
                newToastData =
                    Toast.Model Toast.HideToast "" Toast.None
            in
            ( { model | toastData = newToastData }, Cmd.none, CloseModal )


createMorningJournalEntry : JournalEntry -> Cmd Msg
createMorningJournalEntry journal =
    Http.post
        { url = "http://localhost:8080/journal/entry/create/"
        , body = Http.jsonBody (newMorningJournalEncoder journal)
        , expect = Http.expectJson JournalEntryCreated journalEntryDecoder
        }


fetchJournalThemes : Cmd Msg
fetchJournalThemes =
    Http.get
        { url = "http://localhost:8080/journals/themes/"
        , expect =
            JournalTheme.journalThemeListDecoder
                |> Http.expectJson (RemoteData.fromResult >> JournalThemesReceived)
        }



-- VIEW


view : Model -> Html Msg
view model =
    let
        formHtml =
            case model.selectedJournalTheme.theme of
                _ ->
                    div [] []
    in
    div [ class "container" ]
        [ formHtml
        ]


newJournalEntryForm : Model -> Html Msg
newJournalEntryForm model =
    let
        thoughts =
            JournalSection.getField model.journal.content.amorFati "thoughts"

        -- premeditatio malorum
        vice =
            JournalSection.getField model.journal.content.premeditatioMalorum "vice"

        premeditatioMalorumStrategy =
            JournalSection.getField model.journal.content.premeditatioMalorum "strategy"
    in
    div
        []
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


buildDropDownOptionsFromJournalThemeList : List JournalTheme.JournalTheme -> List (Html Msg)
buildDropDownOptionsFromJournalThemeList themes =
    List.map buildOptionFromJournalTheme themes


buildOptionFromJournalTheme : JournalTheme.JournalTheme -> Html Msg
buildOptionFromJournalTheme theme =
    li
        []
        [ a [ class "dropdown-item", href "#", style "color" theme.accentColor, onClick (JournalThemeSelected theme.theme) ]
            [ text (theme.name ++ " - " ++ theme.oneLineDesc)
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
        , button [ type_ "button", class "btn-close", attribute "data-bs-dismiss" "modal", attribute "aria-label" "Close" ] []
        ]


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
        [ button [ type_ "button", class "btn", class "btn-primary", attribute "data-bs-dismiss" "modal" ] [ text "Surprise Me!" ]
        , button finalAttrList [ text "Start Journaling" ]
        ]


getModalOpts : JournalTheme.JournalTheme -> ModalOptions
getModalOpts theme =
    let
        options =
            ModalOptions "" "" "" "" ""

        hideValue =
            "show"

        ariaAttributeName =
            "aria-modal"

        styleDisplayValue =
            "block"

        ( roleAttributeName, roleAttributeValue ) =
            ( "role", "dialog" )
    in
    { options
        | hideValue = hideValue
        , ariaAttributeName = ariaAttributeName
        , styleDisplayValue = styleDisplayValue
        , roleAttributeName = roleAttributeName
        , roleAttributeValue = roleAttributeValue
    }


viewModal : Model -> Html Msg
viewModal model =
    case model.journalThemesList of
        RemoteData.NotAsked ->
            let
                options =
                    getModalOpts model.selectedJournalTheme
            in
            div
                [ class "modal fade"
                , class options.hideValue
                , class "modal-lg"
                , style "display" options.styleDisplayValue
                , id "themeSelectModal"
                , attribute "tabindex" "-1"
                , attribute "aria-labelledby" "themeSelectModalLabel"
                , attribute options.ariaAttributeName "true"
                , attribute options.roleAttributeName options.roleAttributeValue
                ]
                [ div [ class "modal-dialog" ]
                    [ div [ class "modal-content" ]
                        [ viewModalHeader
                        , div [ class "modal-body" ]
                            [ div [ class "row gy-4" ]
                                [ div [ class "dropdown" ]
                                    [ button
                                        [ class "btn"
                                        , class "dropdown-toggle"
                                        , type_ "button"
                                        , attribute "data-bs-toggle" "dropdown"
                                        , attribute "aria-expanded" "false"
                                        , style "color" "#FF0000;"
                                        , style "border" "1px solid black"
                                        ]
                                        [ text "Choose your journal's theme"
                                        ]
                                    , p
                                        [ style "margin-bottom" "2px"
                                        ]
                                        [ text model.selectedJournalTheme.detailedDesc ]
                                    ]
                                ]
                            , viewModalFooter model.selectedJournalTheme
                            ]
                        ]
                    ]
                ]

        RemoteData.Loading ->
            let
                options =
                    getModalOpts model.selectedJournalTheme
            in
            div
                [ class "modal fade"
                , class options.hideValue
                , class "modal-lg"
                , style "display" options.styleDisplayValue
                , id "themeSelectModal"
                , attribute "tabindex" "-1"
                , attribute "aria-labelledby" "themeSelectModalLabel"
                , attribute options.ariaAttributeName "true"
                , attribute options.roleAttributeName options.roleAttributeValue
                ]
                [ div [ class "modal-dialog" ]
                    [ div [ class "modal-content" ]
                        [ viewModalHeader
                        , div [ class "modal-body" ]
                            [ div [ class "row gy-4" ]
                                [ div [ class "col text-center" ]
                                    [ div [ class "spinner-border", class "text-secondary" ]
                                        [ span [ class "visually-hidden" ] [ text "Loading..." ]
                                        ]
                                    ]
                                ]
                            , viewModalFooter model.selectedJournalTheme
                            ]
                        ]
                    ]
                ]

        RemoteData.Success themes ->
            let
                options =
                    getModalOpts model.selectedJournalTheme

                dropdownOptions =
                    buildDropDownOptionsFromJournalThemeList themes
            in
            div
                [ class "modal fade"
                , class options.hideValue
                , class "modal-lg"
                , style "display" options.styleDisplayValue
                , id "themeSelectModal"
                , attribute "tabindex" "-1"
                , attribute "aria-labelledby" "themeSelectModalLabel"
                , attribute options.ariaAttributeName "true"
                , attribute options.roleAttributeName options.roleAttributeValue
                ]
                [ div [ class "modal-dialog" ]
                    [ div [ class "modal-content" ]
                        [ viewModalHeader
                        , div [ class "modal-body" ]
                            [ div [ class "row gy-4" ]
                                [ div [ class "dropdown" ]
                                    [ button
                                        [ class "btn"
                                        , class "dropdown-toggle"
                                        , type_ "button"
                                        , attribute "data-bs-toggle" "dropdown"
                                        , attribute "aria-expanded" "false"
                                        , style "color" "#FF0000;"
                                        , style "border" "1px solid black"
                                        ]
                                        [ text "Choose your journal's theme"
                                        ]
                                    , ul [ class "dropdown-menu" ] dropdownOptions
                                    , p
                                        [ style "margin-top" "1rem"
                                        , style "margin-bottom" "2px"
                                        ]
                                        [ text model.selectedJournalTheme.detailedDesc ]
                                    ]
                                ]
                            , viewModalFooter model.selectedJournalTheme
                            ]
                        ]
                    ]
                ]

        RemoteData.Failure _ ->
            h3 [] [ text "Failed to fetch themes" ]


buildNavBar : Model -> Html Msg
buildNavBar model =
    let
        ( styleFilter, styleFilterValue ) =
            if model.journalingStarted then
                ( "", "" )

            else
                ( "filter", "blur(2px)" )

        ( colorAttr, navBarTextColor ) =
            case model.selectedJournalTheme.theme of
                JournalTheme.None ->
                    ( class "bg-light", "black" )

                _ ->
                    ( style "background-color" model.selectedJournalTheme.accentColor, "white" )
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
            emptyMorningJournal

        toast =
            Toast.Model Toast.HideToast "" Toast.None

        themeData =
            JournalTheme.JournalTheme JournalTheme.None "" "" "" ""
    in
    { navKey = navKey, journal = journal, createJournalEntryError = Nothing, toastData = toast, selectedJournalTheme = themeData, journalThemesList = RemoteData.Loading, journalingStarted = False }
