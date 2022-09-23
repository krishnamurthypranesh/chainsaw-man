module Common.JournalEntry exposing
    ( JournalEntry
    , JournalId
    , ListJournalEntriesInput
    , emptyMorningJournal
    , idParser
    , idToString
    , journalEntriesListDecoder
    , journalEntryDecoder
    , journalEntryEncoder
    , listJournalEntriesInputEncoder
    , updateJournalIdea
    , updateJournalThought
    )

import Common.JournalTheme exposing (JournalTheme, ThemeValue(..), emptyJournalTheme, journalThemeDecoder, journalThemeEncoder, themeValueDecoder, themeValueEncoder)
import Json.Decode as Decode exposing (Decoder, list)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Url.Parser exposing (Parser, custom)


type alias JournalEntry =
    { id : JournalId
    , theme : ThemeValue
    , content : JournalContent
    , createdAt : Int
    , updatedAt : Int
    }


type JournalId
    = JournalId String


type alias JournalContent =
    { quote : String
    , idea_nudge : String
    , thought_nudge : String
    , idea : String
    , thought : String
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


journalEntryDecoder : Decoder JournalEntry
journalEntryDecoder =
    Decode.succeed JournalEntry
        |> required "_id" idDecoder
        |> required "theme" themeValueDecoder
        |> required "content" journalContentDecoder
        |> required "created_at" Decode.int
        |> optional "updated_at" Decode.int 0


journalEntriesListDecoder : Decoder (List JournalEntry)
journalEntriesListDecoder =
    list journalEntryDecoder


journalContentDecoder : Decoder JournalContent
journalContentDecoder =
    Decode.succeed JournalContent
        |> required "quote" Decode.string
        |> required "idea_nudge" Decode.string
        |> required "thought_nudge" Decode.string
        |> required "idea" Decode.string
        |> required "thought" Decode.string



-- ENCODERS


journalEntryEncoder : JournalEntry -> Encode.Value
journalEntryEncoder journal =
    Encode.object
        [ ( "theme", themeValueEncoder journal.theme )
        , ( "content", journalContentEncoder journal.content )
        ]


journalContentEncoder : JournalContent -> Encode.Value
journalContentEncoder content =
    Encode.object
        [ ( "quote", Encode.string content.quote )
        , ( "idea_nudge", Encode.string content.idea_nudge )
        , ( "idea", Encode.string content.idea )
        , ( "thought_nudge", Encode.string content.thought_nudge )
        , ( "thought", Encode.string content.thought )
        ]



-- CONSTRUCTORS


emptyMorningJournal : JournalEntry
emptyMorningJournal =
    let
        journalId =
            JournalId ""
    in
    JournalEntry journalId None (JournalContent "" "" "" "" "") 0 0


updateJournalIdea : JournalEntry -> String -> JournalEntry
updateJournalIdea entry idea =
    let
        oldContent =
            entry.content

        newContent =
            { oldContent | idea = idea }
    in
    { entry | content = newContent }


updateJournalThought : JournalEntry -> String -> JournalEntry
updateJournalThought entry thought =
    let
        oldContent =
            entry.content

        newContent =
            { oldContent | thought = thought }
    in
    { entry | content = newContent }



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
