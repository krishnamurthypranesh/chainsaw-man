module Common.JournalTheme exposing (..)

import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias JournalTheme =
    { theme : ThemeValue
    , name : String
    , oneLineDesc : String
    , detailedDesc : String
    , accentColor : String
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
    case String.toLower theme of
        "amor fati" ->
            Decode.succeed AmorFati

        "premeditatio malorum" ->
            Decode.succeed PremeditatioMalorum

        "" ->
            Decode.succeed None

        _ ->
            Decode.fail ("invalid journal theme: " ++ theme)


themeValueToString : ThemeValue -> String
themeValueToString theme =
    case theme of
        AmorFati ->
            "AmorFati"

        PremeditatioMalorum ->
            "PremeditatioMalorum"

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


journalThemeListDecoder : Decoder (List JournalTheme)
journalThemeListDecoder =
    list journalThemeDecoder
