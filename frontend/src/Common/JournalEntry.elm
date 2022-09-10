module Common.JournalEntry exposing
    ( JournalEntry
    , JournalId
    , ListJournalEntriesInput
    , emptyMorningJournal
    , idParser
    , idToString
    , journalEntriesListDecoder
    , journalEntryDecoder
    , listJournalEntriesInputEncoder
    , newMorningJournalEncoder
    , updateJournalContent
    )

import Common.JournalField exposing (JournalField)
import Common.JournalSection exposing (JournalSection, journalSectionDecoder, journalSectionEncoder, setFieldValue)
import Dict exposing (Dict, fromList)
import Html exposing (a)
import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Url.Parser exposing (Parser, custom)


type alias JournalEntry =
    { id : JournalId
    , createdAt : Int
    , content : Content
    }


type JournalId
    = JournalId String


type alias Content =
    { amorFati : JournalSection
    , premeditatioMalorum : JournalSection
    }



-- DECODERS


idDecoder : Decoder JournalId
idDecoder =
    Decode.map JournalId Decode.string


idParser : Parser (JournalId -> a) a
idParser =
    custom "JOURANLID" <|
        \journalId -> Just (JournalId journalId)


idToString : JournalId -> String
idToString jId =
    case jId of
        JournalId id ->
            id


contentDecoder : Decoder Content
contentDecoder =
    Decode.succeed Content
        |> required "amor_fati" journalSectionDecoder
        |> required "premeditatio_malorum" journalSectionDecoder


journalEntryDecoder : Decoder JournalEntry
journalEntryDecoder =
    Decode.succeed JournalEntry
        |> required "_id" idDecoder
        |> required "created_at" Decode.int
        |> required "content" contentDecoder


journalEntriesListDecoder : Decoder (List JournalEntry)
journalEntriesListDecoder =
    list journalEntryDecoder



-- ENCODERS


contentEncoder : Content -> Encode.Value
contentEncoder c =
    Encode.object
        [ ( "amor_fati", journalSectionEncoder c.amorFati )
        , ( "premeditatio_malorum", journalSectionEncoder c.premeditatioMalorum )
        ]


newMorningJournalEncoder : JournalEntry -> Encode.Value
newMorningJournalEncoder journal =
    Encode.object
        [ ( "content"
          , Encode.object
                [ ( "amor_fati", journalSectionEncoder journal.content.amorFati )
                , ( "premeditatio_malorum", journalSectionEncoder journal.content.premeditatioMalorum )
                ]
          )
        ]



-- CONSTRUCTORS


emptyMorningJournal : JournalEntry
emptyMorningJournal =
    let
        content =
            { amorFati =
                JournalSection
                    "Amor Fati"
                    (Dict.fromList [ ( "thank_you", JournalField "thank_you" "" ), ( "thoughts", JournalField "thoughts" "" ) ])
            , premeditatioMalorum =
                JournalSection
                    "Premeditatio Malorum"
                    (Dict.fromList [ ( "vice", JournalField "vice" "" ), ( "strategy", JournalField "strategy" "" ) ])
            }

        journalId =
            JournalId ""

        createdAt =
            0
    in
    JournalEntry journalId createdAt content


updateJournalContent : JournalEntry -> String -> String -> String -> JournalEntry
updateJournalContent journal sectionName fieldName fieldValue =
    let
        oldContent =
            journal.content
    in
    case sectionName of
        "amor_fati" ->
            { journal | content = { oldContent | amorFati = setFieldValue journal.content.amorFati fieldName fieldValue } }

        "premeditatio_malorum" ->
            { journal | content = { oldContent | premeditatioMalorum = setFieldValue journal.content.premeditatioMalorum fieldName fieldValue } }

        _ ->
            journal



-- INPUTS


type alias ListJournalEntriesInput =
    { createdAfter : Int
    , createdBefore : Int
    , journalType : String
    }


listJournalEntriesInputEncoder : ListJournalEntriesInput -> Encode.Value
listJournalEntriesInputEncoder input =
    Encode.object
        [ ( "created_after", Encode.int input.createdAfter )
        , ( "created_before", Encode.int input.createdBefore )
        , ( "journal_type", Encode.string input.journalType )
        ]
