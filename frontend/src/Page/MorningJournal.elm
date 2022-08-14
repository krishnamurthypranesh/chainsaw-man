module Page.MorningJournal exposing (MorningJournal, MorningJournalId, emptyMorningJournal, morningJournalDecoder, morningJournalsListDecoder, newMorningJournalEncoder, setAmorFati)

import Json.Decode as Decode exposing (Decoder, dict, field, int, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value, int, object, string)
import Page.AmorFati as AmorFati exposing (..)


type alias MorningJournal =
    { id : MorningJournalId
    , createdAt : Int
    , content : JournalContent
    }


type alias JournalContent =
    { amorFati : AmorFati.AmorFati
    }


type MorningJournalId
    = MorningJournalId String



-- DECODERS


idDecoder : Decoder MorningJournalId
idDecoder =
    Decode.map MorningJournalId Decode.string


contentDecoder : Decoder JournalContent
contentDecoder =
    Decode.succeed JournalContent
        |> required "amor_fati" AmorFati.amorFatiDecoder



-- ENCODERS


morningJournalDecoder : Decoder MorningJournal
morningJournalDecoder =
    Decode.succeed MorningJournal
        |> required "_id" idDecoder
        |> required "created_at" Decode.int
        |> required "content" contentDecoder


morningJournalsListDecoder : Decoder (List MorningJournal)
morningJournalsListDecoder =
    list morningJournalDecoder


newMorningJournalEncoder : MorningJournal -> Encode.Value
newMorningJournalEncoder journal =
    Encode.object
        [ ( "content"
          , Encode.object
                [ ( "amor_fati", amorFatiEncoder journal.content.amorFati )
                ]
          )
        ]



-- CONSTRUCTORS


emptyMorningJournal : MorningJournal
emptyMorningJournal =
    let
        amorFati =
            AmorFati "" ""

        content =
            JournalContent amorFati

        journalId =
            MorningJournalId ""

        createdAt =
            0
    in
    MorningJournal journalId createdAt content


setAmorFati : JournalContent -> AmorFati -> JournalContent
setAmorFati content amorFati =
    { content | amorFati = amorFati }
