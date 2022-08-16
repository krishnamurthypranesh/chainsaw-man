module Common.MorningJournal exposing (MorningJournal, MorningJournalId, emptyMorningJournal, morningJournalDecoder, morningJournalsListDecoder, newMorningJournalEncoder, updateJournalContent)

import Common.JournalField exposing (JournalField)
import Common.JournalSection exposing (JournalSection, journalSectionDecoder, journalSectionEncoder, setFieldValue)
import Dict exposing (Dict, fromList)
import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias MorningJournal =
    { id : MorningJournalId
    , createdAt : Int
    , content : Content
    }


type MorningJournalId
    = MorningJournalId String


type alias Content =
    { amorFati : JournalSection
    , premeditatioMalorum : JournalSection
    , sympatheia : JournalSection
    }



-- DECODERS


idDecoder : Decoder MorningJournalId
idDecoder =
    Decode.map MorningJournalId Decode.string


contentDecoder : Decoder Content
contentDecoder =
    Decode.succeed Content
        |> required "amor_fati" journalSectionDecoder
        |> required "premeditatio_malorum" journalSectionDecoder
        |> required "sympatheia" journalSectionDecoder


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
                , ( "sympatheia", journalSectionEncoder journal.content.sympatheia )
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
                    ""
                    (Dict.fromList [ ( "thank_you", JournalField "thank_you" "" ), ( "thoughts", JournalField "thoughts" "" ) ])
            , premeditatioMalorum =
                JournalSection
                    ""
                    (Dict.fromList [ ( "vice", JournalField "vice" "" ), ( "strategy", JournalField "strategy" "" ) ])
            , sympatheia =
                JournalSection
                    ""
                    (Dict.fromList [ ( "person", JournalField "person" "" ), ( "relationship", JournalField "relationship" "" ), ( "strategy", JournalField "strategy" "" ), ( "self_growth", JournalField "self_growth" "" ) ])
            }

        journalId =
            MorningJournalId ""

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

        "sympatheia" ->
            { journal | content = { oldContent | sympatheia = setFieldValue journal.content.sympatheia fieldName fieldValue } }

        _ ->
            journal
