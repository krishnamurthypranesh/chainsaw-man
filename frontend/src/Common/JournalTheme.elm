module Common.JournalTheme exposing (..)


type alias Model =
    { theme : JournalTheme
    , name : String
    , oneLineDesc : String
    , detailedDesc : String
    , accentColor : String
    }


type JournalTheme
    = AmorFati
    | PremeditatioMalorum
    | None


journalThemeToString : JournalTheme -> String
journalThemeToString theme =
    case theme of
        AmorFati ->
            "AmorFati"

        PremeditatioMalorum ->
            "PremeditatioMalorum"

        None ->
            ""
