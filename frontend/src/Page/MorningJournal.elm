module Page.MorningJournal exposing (MorningJournal, MorningJournalId, morningJournalDecoder, morningJournalsListDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)


type alias MorningJournal =
    { id : MorningJournalId
    , createdAt : Int
    , amorFati : AmorFati
    }


type alias AmorFati =
    { thankYou : String
    , thoughts : String
    }


type MorningJournalId
    = MorningJournalId String


idDecoder : Decoder MorningJournalId
idDecoder =
    Decode.map MorningJournalId string


amorFatiDecoder : Decoder AmorFati
amorFatiDecoder =
    Decode.succeed AmorFati
        |> required "thankYou" Decode.string
        |> required "thoughts" Decode.string


morningJournalDecoder : Decoder MorningJournal
morningJournalDecoder =
    Decode.succeed MorningJournal
        |> required "id" idDecoder
        |> required "created_at" int
        |> required "amorFati" amorFatiDecoder


morningJournalsListDecoder : Decoder (List MorningJournal)
morningJournalsListDecoder =
    list morningJournalDecoder
