-- TODO: completely implement this module


module Logger exposing (..)

import Helpers exposing (dateTimeFromTs)


type LogLevel
    = LevelDebug
    | LevelError
    | LevelWarn



-- logs a message in the following format: [level] [timestamp] [message]


logMessage : String -> LogLevel -> Maybe String
logMessage msg level =
    let
        levelValue =
            case level of
                LevelDebug ->
                    "[DEBUG] -- "

                LevelError ->
                    "[ERROR] -- "

                LevelWarn ->
                    "[WARN] -- "

        _ =
            Debug.log levelValue msg
    in
    Nothing
