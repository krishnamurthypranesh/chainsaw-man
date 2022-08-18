module Common.JournalSection exposing (..)

import Common.JournalField exposing (JournalField, journalFieldDecoder, journalFieldEncoder)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias JournalSection =
    { title : String
    , fields : Dict String JournalField
    }


journalSectionDecoder : Decoder JournalSection
journalSectionDecoder =
    Decode.succeed JournalSection
        |> required "title" Decode.string
        |> required "fields" (Decode.dict journalFieldDecoder)


journalSectionEncoder : JournalSection -> Encode.Value
journalSectionEncoder section =
    Encode.object
        [ ( "title", Encode.string section.title )
        , ( "fields"
          , Encode.dict identity journalFieldEncoder section.fields
          )
        ]


setFieldValue : JournalSection -> String -> String -> JournalSection
setFieldValue js fieldName fieldValue =
    let
        updatedField =
            case Dict.get fieldName js.fields of
                Nothing ->
                    JournalField "" ""

                Just field ->
                    { field | value = fieldValue }

        fieldsUpdated =
            Dict.update fieldName (Maybe.map (\_ -> updatedField)) js.fields

        newJS =
            { js | fields = fieldsUpdated }
    in
    newJS


getField : JournalSection -> String -> JournalField
getField js fieldName =
    let
        field =
            case Dict.get fieldName js.fields of
                Nothing ->
                    JournalField "" ""

                Just jf ->
                    jf
    in
    field
