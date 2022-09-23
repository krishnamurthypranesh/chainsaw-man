module Common.JournalTheme exposing
    ( JournalTheme
    , ThemeValue(..)
    , emptyJournalTheme
    , journalThemeDecoder
    , journalThemeEncoder
    , journalThemeListDecoder
    , themeValueDecoder
    , themeValueEncoder
    , themeValueFromString
    , themeValueToString
    )

import Common.JournalThemeData exposing (JournalThemeData, emptyJournalThemeData, journalThemeDataDecoder, journalThemeDataEncoder)
import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias JournalTheme =
    { theme : ThemeValue
    , name : String
    , oneLineDesc : String
    , detailedDesc : String
    , accentColor : String
    , data : JournalThemeData
    }


type ThemeValue
    = AmorFati
    | PremeditatioMalorum
    | None


themeValueDecoder : Decoder ThemeValue
themeValueDecoder =
    Decode.string |> Decode.andThen themeValueFromString


themeValueFromString : String -> Decoder ThemeValue
themeValueFromString theme =
    let
        _ =
            Debug.log "THEME" theme
    in
    case String.toUpper theme of
        "AMOR_FATI" ->
            Decode.succeed AmorFati

        "PREMEDITATIO_MALORUM" ->
            Decode.succeed PremeditatioMalorum

        "" ->
            Decode.succeed None

        _ ->
            let
                _ =
                    Debug.log "ERROR CASE" theme
            in
            Decode.fail ("invalid journal theme: " ++ theme)


themeValueToString : ThemeValue -> String
themeValueToString theme =
    case theme of
        AmorFati ->
            "AMOR_FATI"

        PremeditatioMalorum ->
            "PREMEDITATIO_MALORUM"

        None ->
            ""


journalThemeDecoder : Decoder JournalTheme
journalThemeDecoder =
    Decode.succeed JournalTheme
        |> optional "theme" themeValueDecoder None
        |> required "name" Decode.string
        |> required "short_description" Decode.string
        |> required "detailed_description" Decode.string
        |> required "accent_color" Decode.string
        |> required "data" journalThemeDataDecoder


journalThemeListDecoder : Decoder (List JournalTheme)
journalThemeListDecoder =
    list journalThemeDecoder



-- ENCODERS


themeValueEncoder : ThemeValue -> Encode.Value
themeValueEncoder theme =
    Encode.string (themeValueToString theme)


journalThemeEncoder : JournalTheme -> Encode.Value
journalThemeEncoder theme =
    Encode.object
        [ ( "theme", themeValueEncoder theme.theme )
        , ( "name", Encode.string theme.name )
        , ( "oneLineDesc", Encode.string theme.oneLineDesc )
        , ( "detailedDesc", Encode.string theme.detailedDesc )
        , ( "accentColor", Encode.string theme.accentColor )
        , ( "data", journalThemeDataEncoder theme.data )
        ]


emptyJournalTheme : JournalTheme
emptyJournalTheme =
    JournalTheme None "" "" "" "" emptyJournalThemeData
