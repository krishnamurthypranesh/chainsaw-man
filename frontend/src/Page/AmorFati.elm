module Page.AmorFati exposing (AmorFati, amorFatiDecoder, amorFatiEncoder, updateThankYou, updateThoughts)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias AmorFati =
    { thankYou : String
    , thoughts : String
    }


amorFatiDecoder : Decoder AmorFati
amorFatiDecoder =
    Decode.succeed AmorFati
        |> required "thank_you" Decode.string
        |> required "thoughts" Decode.string


amorFatiEncoder : AmorFati -> Encode.Value
amorFatiEncoder amorFati =
    Encode.object
        [ ( "thank_you", Encode.string amorFati.thankYou )
        , ( "thoughts", Encode.string amorFati.thoughts )
        ]


updateThankYou : AmorFati -> String -> AmorFati
updateThankYou model newVal =
    { model | thankYou = newVal }


updateThoughts : AmorFati -> String -> AmorFati
updateThoughts model newVal =
    { model | thoughts = newVal }
