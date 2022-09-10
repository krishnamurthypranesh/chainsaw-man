module Error exposing (errorFromHttpError)

import Http exposing (Error(..))


errorFromHttpError : Http.Error -> String
errorFromHttpError err =
    case err of
        Http.Timeout ->
            "The request timed out!"

        Http.BadBody _ ->
            "The response body could not be parsed!"

        Http.NetworkError ->
            "There was an error when trying fetch data from the server"

        Http.BadStatus _ ->
            "The server sent an SOS and the team is looking into it right now"

        Http.BadUrl _ ->
            "An invalid url was used to make the request"
