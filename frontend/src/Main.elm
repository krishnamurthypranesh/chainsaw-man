module Main exposing (main)

import Browser
import Page.ListJournals as ListJournals


main : Program () ListJournals.Model ListJournals.Msg
main =
    Browser.element
        { init = ListJournals.init
        , view = ListJournals.view
        , update = ListJournals.update
        , subscriptions = \_ -> Sub.none
        }
