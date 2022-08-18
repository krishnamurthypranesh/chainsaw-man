module Common.JournalField exposing (JournalField, journalFieldDecoder, journalFieldEncoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias JournalField =
    { field : String
    , value : String
    }


journalFieldDecoder : Decoder JournalField
journalFieldDecoder =
    Decode.succeed JournalField
        |> required "field" Decode.string
        |> required "value" Decode.string


journalFieldEncoder : JournalField -> Encode.Value
journalFieldEncoder journalField =
    Encode.object
        [ ( "field", Encode.string journalField.field )
        , ( "value", Encode.string journalField.value )
        ]


updateField : JournalField -> String -> JournalField
updateField jf newField =
    { jf | field = newField }


updateValue : JournalField -> String -> JournalField
updateValue jf newValue =
    { jf | value = newValue }
