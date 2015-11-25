module Hoge where

import Import
import Yesod.Form.Bootstrap3 (withSmallInput)

type WikiPageInput = (Text, Textarea)

formPrimary :: Maybe Text -> Maybe Textarea -> MForm Handler (FormResult WikiPageInput, Widget)
formPrimary mt mc = do
    (titleValueResult  , titleView)   <- mreq textField (withSmallInput "タイトル") mt
    (contentValueResult, contentView) <- mreq textareaField (withSmallInput "ソース") mc
    let result = (,)
            <$> titleValueResult
            <*> contentValueResult
        widget = $(widgetFile "wiki-form")
    return (result, widget)

