module Handler.WikiPage where

import Import

getWikiPageR :: Handler Html
getWikiPageR = do
    pages <- runDB $ selectList [] [Asc WikiPageTitle]
    defaultLayout $ do
        setTitle "Wiki Page"
        $(widgetFile "wikiindex")
