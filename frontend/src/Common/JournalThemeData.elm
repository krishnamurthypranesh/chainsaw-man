module Common.JournalThemeData exposing (..)

import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (optional, required)


type alias JournalThemeData =
    { quote : String
    , ideaNudge : String
    , thoughtNudge : String
    }


journalThemeDataDecoder : Decoder JournalThemeData
journalThemeDataDecoder =
    Decode.succeed JournalThemeData
        |> required "quote" Decode.string
        |> required "idea_nudge" Decode.string
        |> required "thought_nudge" Decode.string


emptyJournalThemeData : JournalThemeData
emptyJournalThemeData =
    JournalThemeData "" "" ""
