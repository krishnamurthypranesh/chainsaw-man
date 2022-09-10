module Helpers exposing (..)

import Time exposing (Month, Posix, toDay, toHour, toMinute, toMonth, toSecond, toYear, utc)


stringFromMaybeString : Maybe String -> String
stringFromMaybeString maybeString =
    case maybeString of
        Nothing ->
            ""

        Just val ->
            val


dateTimeFromts : Posix -> String
dateTimeFromts ts =
    (String.padLeft 2 '0' <| String.fromInt <| Time.toDay utc ts)
        ++ " "
        ++ (String.padLeft 2 '0' <| monthStringFromMonth <| Time.toMonth utc ts)
        ++ " "
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toYear utc ts)
        ++ ", "
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toHour utc ts)
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toMinute utc ts)
        ++ ":"
        ++ (String.padLeft 2 '0' <| String.fromInt <| Time.toSecond utc ts)


monthStringFromMonth : Month -> String
monthStringFromMonth month =
    case month of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"
