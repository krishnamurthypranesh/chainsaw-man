module Common.Journal exposing (JournalId, MorningJournal, emptyMorningJournal, morningJournalDecoder, morningJournalsListDecoder, newMorningJournalEncoder, updateJournalContent)

import Common.JournalField exposing (JournalField)
import Common.JournalSection exposing (JournalSection, journalSectionDecoder, journalSectionEncoder, setFieldValue)
import Dict exposing (Dict, fromList)
import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Url.Parser exposing (Parser, custom)


type alias MorningJournal =
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


contentDecoder : Decoder Content
contentDecoder =
    Decode.succeed Content
        |> required "amor_fati" journalSectionDecoder
        |> required "premeditatio_malorum" journalSectionDecoder


morningJournalDecoder : Decoder MorningJournal
morningJournalDecoder =
    Decode.succeed MorningJournal
        |> required "_id" idDecoder
        |> required "created_at" Decode.int
        |> required "content" contentDecoder


morningJournalsListDecoder : Decoder (List MorningJournal)
morningJournalsListDecoder =
    list morningJournalDecoder



-- ENCODERS


contentEncoder : Content -> Encode.Value
contentEncoder c =
    Encode.object
        [ ( "amor_fati", journalSectionEncoder c.amorFati )
        , ( "premeditatio_malorum", journalSectionEncoder c.premeditatioMalorum )
        ]


newMorningJournalEncoder : MorningJournal -> Encode.Value
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


emptyMorningJournal : MorningJournal
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
    MorningJournal journalId createdAt content


updateJournalContent : MorningJournal -> String -> String -> String -> MorningJournal
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
