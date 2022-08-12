module Main exposing (..)

-- import Html.Attributes exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { thankYou : String
    , thankYouStatus : ThankYouStatus
    , amorFati : String
    , amorFatiStatus : AmorFatiStatus
    , premeditatioMalorumVice : String
    , premeditatioMalorumStrategy : String
    , premeditatioMalorumStatus : PremeditatioMalorumStatus
    , sympatheiaPerson : String
    , sympatheiaRelationship : String
    , sympatheiaStrategy : String
    , sympatheiaGrowth : String
    , sympatheiaStatus : SympatheiaStatus
    , mementoMoriLoss : String
    , mementoMoriDescription : String
    , mementoMoriStatus : MementoMoriStatus
    }


init : Model
init =
    Model "" EmptyThankYou "" EmptyAmorFati "" "" EmptyPremeditatioMalorum "" "" "" "" EmptySympatheia "" "" EmptyMementoMori



-- UPDATE


type Msg
    = ChangeThankYou String
    | ChangeAmorFati String
    | ChangePremeditatioMalorumVice String
    | ChangePremeditatioMalorumStrategy String
    | ChangeSympatheiaPerson String
    | ChangeSympatheiaRelationship String
    | ChangeSympatheiaStrategy String
    | ChangeSympatheiaGrowth String
    | ChangeMementoMoriLoss String
    | ChangeMementoMoriDescription String


type ThankYouStatus
    = EmptyThankYou
    | InvalidThankYou
    | ValidThankYou


type AmorFatiStatus
    = EmptyAmorFati
    | AmorFatiDescriptionIncomplete
    | AmorFatiDescriptionComplete


type PremeditatioMalorumStatus
    = EmptyPremeditatioMalorum
    | PremeditatioMalorumViceIncomplete
    | PremeditatioMalorumStrategyIncomplete
    | PremeditatioMalorumComplete


type SympatheiaStatus
    = EmptySympatheia
    | SympatheiaPersonIncomplete
    | SympatheiaRelationshipIncomplete
    | SympatheiaStrategyIncomplete
    | SympatheiaGrwothIncomplete
    | SympatheiaComplete


type MementoMoriStatus
    = EmptyMementoMori
    | MementoMoriLossIncomplete
    | MementoMoriDescriptionIncomplete
    | MementoMoriComplete


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeThankYou ty ->
            validate { model | thankYou = ty }

        ChangeAmorFati af ->
            validate { model | amorFati = af }

        ChangePremeditatioMalorumVice pmv ->
            validate { model | premeditatioMalorumVice = pmv }

        ChangePremeditatioMalorumStrategy pms ->
            validate { model | premeditatioMalorumStrategy = pms }

        ChangeSympatheiaPerson sp ->
            validate { model | sympatheiaPerson = sp }

        ChangeSympatheiaRelationship sr ->
            validate { model | sympatheiaRelationship = sr }

        ChangeSympatheiaStrategy ss ->
            validate { model | sympatheiaStrategy = ss }

        ChangeSympatheiaGrowth sg ->
            validate { model | sympatheiaGrowth = sg }

        ChangeMementoMoriLoss mml ->
            validate { model | mementoMoriLoss = mml }

        ChangeMementoMoriDescription mmd ->
            validate { model | mementoMoriDescription = mmd }


validate model =
    let
        thankYouStatus =
            if model.thankYou == "" then
                EmptyThankYou

            else if String.toLower model.thankYou /= "thank you" then
                InvalidThankYou

            else
                ValidThankYou

        amorFatiStatus =
            if model.amorFati == "" then
                EmptyAmorFati

            else if String.length model.amorFati < 100 then
                AmorFatiDescriptionIncomplete

            else
                AmorFatiDescriptionComplete

        premeditatoMalorumStatus =
            if model.premeditatioMalorumVice == "" && model.premeditatioMalorumStrategy == "" then
                EmptyPremeditatioMalorum

            else if String.length model.premeditatioMalorumVice < 10 then
                PremeditatioMalorumViceIncomplete

            else if String.length model.premeditatioMalorumStrategy < 50 then
                PremeditatioMalorumStrategyIncomplete

            else
                PremeditatioMalorumComplete

        sympatheiaStatus =
            if model.sympatheiaPerson == "" && model.sympatheiaRelationship == "" && model.sympatheiaStrategy == "" then
                EmptySympatheia

            else if String.length model.sympatheiaPerson < 2 then
                SympatheiaPersonIncomplete

            else if String.length model.sympatheiaRelationship == 0 then
                SympatheiaRelationshipIncomplete

            else if String.length model.sympatheiaStrategy < 50 then
                SympatheiaStrategyIncomplete

            else if String.length model.sympatheiaGrowth < 50 then
                SympatheiaGrwothIncomplete

            else
                SympatheiaComplete

        mementoMoriStatus =
            if model.mementoMoriLoss == "" && model.mementoMoriDescription == "" then
                EmptyMementoMori

            else if String.length model.mementoMoriLoss < 10 then
                MementoMoriLossIncomplete

            else if String.length model.mementoMoriDescription < 50 then
                MementoMoriDescriptionIncomplete

            else
                MementoMoriComplete
    in
    { model
        | thankYouStatus = thankYouStatus
        , amorFatiStatus = amorFatiStatus
        , premeditatioMalorumStatus = premeditatoMalorumStatus
        , sympatheiaStatus = sympatheiaStatus
        , mementoMoriStatus = mementoMoriStatus
    }



-- View


view : Model -> Html Msg
view model =
    form []
        [ label []
            [ div [ id "say-thankyou" ]
                [ h2 [] [ text "First off..." ]
                , div [] [ text "You've woken up today! Many people will not have the privilege to do so today. So, say thank you for waking up today!" ]
                , br [] []
                , input [ placeholder "Say thank you", value model.thankYou, onInput ChangeThankYou ] []
                ]
            , thankYouError model.thankYouStatus
            ]
        , label []
            [ div [ id "amor-fati" ]
                [ h2 [] [ text "Amor Fati" ]
                , div [] [ text "Your fate is to go through life each day. What happens is dictated by it and you can only react to what happens. So, you might as well love your fate" ]
                , br [] []
                , input [ placeholder "Amor Fati", value model.amorFati, onInput ChangeAmorFati ] []
                ]
            , thankYouError model.thankYouStatus
            ]
        , label []
            [ div [ id "premeditatio-malorum" ]
                [ h2 [] [ text "Premeditatio Malorum" ]
                , div [] [ text "Unexpectdness adds weight to disaster. Whatever that disaster might be to you, think about it, see it happen to you in your minds eye and then think of what you can do handle it when it does happen to you" ]
                , br [] []
                , input [ placeholder "What's a vice you think you might encounter today?", value model.premeditatioMalorumVice, onInput ChangePremeditatioMalorumVice ] []
                , br [] []
                , input [ placeholder "How will you handle this vice?", value model.premeditatioMalorumStrategy, onInput ChangePremeditatioMalorumStrategy ] []
                ]
            ]
        , label []
            [ div [ id "premeditatio-malorum" ]
                [ h2 [] [ text "Premeditatio Malorum" ]
                , div [] [ text "Unexpectdness adds weight to disaster. Whatever that disaster might be to you, think about it, see it happen to you in your minds eye and then think of what you can do handle it when it does happen to you" ]
                , br [] []
                , input [ placeholder "What's a vice you think you might encounter today?", value model.premeditatioMalorumVice, onInput ChangePremeditatioMalorumVice ] []
                , br [] []
                , input [ placeholder "How will you handle this vice?", value model.premeditatioMalorumStrategy, onInput ChangePremeditatioMalorumStrategy ] []
                ]
            ]
        , label []
            [ div [ id "sympatheia" ]
                [ h2 [] [ text "Sympatheia" ]
                , div [] [ text "Revere nature, and look after each other. Life is short—the fruit of this life is a good character and acts for the common good." ]
                , br [] []
                , input [ placeholder "Sympatheia", value model.sympatheiaPerson, onInput ChangeSympatheiaPerson ] []
                , br [] []
                , input [ placeholder "Sympatheia", value model.sympatheiaRelationship, onInput ChangeSympatheiaRelationship ] []
                , br [] []
                , input [ placeholder "How will you help this person today?", value model.sympatheiaStrategy, onInput ChangeSympatheiaStrategy ] []
                , br [] []
                , input [ placeholder "How will you help this person today?", value model.sympatheiaStrategy, onInput ChangeSympatheiaGrowth ] []
                ]
            ]
        , label []
            [ div [ id "memento-mori" ]
                [ h2 [] [ text "Memento Mori" ]
                , div [] [ text "One and everyone you love are going to die one day. It sucks, but this is life. But, its not as morbid as you probably made it out to be. Instead of looking at death as a shackle, look at it as a liberator and with this clarity think about what's important to you and how you will go through today" ]
                , br [] []
                , input [ placeholder "What's one loss you think you might have today?", value model.mementoMoriLoss, onInput ChangeMementoMoriLoss ] []
                , br [] []
                , input [ placeholder "What do you feel about that loss?", value model.mementoMoriDescription, onInput ChangeMementoMoriDescription ] []
                ]
            ]
        , button [ type_ "submit" ] [ text "Save Journal Entry" ]
        ]


thankYouError status =
    case status of
        EmptyThankYou ->
            div [] []

        InvalidThankYou ->
            div [ class "error" ]
                [ text "That doesn't look right... Can you type a proper thank you in English?" ]

        ValidThankYou ->
            div [] []
