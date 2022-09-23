module Common.JournalThemeData exposing
    ( JournalThemeData
    , emptyJournalThemeData
    , journalThemeDataDecoder
    , journalThemeDataEncoder
    )

import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


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


journalThemeDataEncoder : JournalThemeData -> Encode.Value
journalThemeDataEncoder data =
    Encode.object
        [ ( "quote", Encode.string data.quote )
        , ( "idea_nudge", Encode.string data.ideaNudge )
        , ( "thought_nudge", Encode.string data.thoughtNudge )
        ]


emptyJournalThemeData : JournalThemeData
emptyJournalThemeData =
    JournalThemeData "" "" ""
