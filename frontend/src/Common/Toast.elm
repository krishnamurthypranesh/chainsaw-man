module Common.Toast exposing (..)

import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, id, src, style, type_)


type alias Model =
    { showToast : Msg
    , toastMessage : String
    , toastType : ToastType
    }


type Msg
    = ShowToast
    | HideToast


type ToastType
    = Info
    | Warn
    | Error
    | None
