module Handler.WikiPage where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3, withSmallInput)

getWikiPageR :: Handler Html
getWikiPageR = do
    (formWidget, _) <- generateFormPost form
    pages <- runDB $ selectList [] [Asc WikiPageTitle]
    defaultLayout $ do
        setTitle "Wiki Page"
        $(widgetFile "wikiindex")

postWikiPageR :: Handler Html
postWikiPageR = do
    ((result, _), _) <- runFormPost form
    let mNewPage = case result of
            FormSuccess res -> Just res
            _               -> Nothing
    case mNewPage of
        Just newPage -> do
             _ <- runDB $ insert $ WikiPage (fst newPage) (snd newPage)
             redirect WikiPageR
        Nothing      -> redirect WikiPageR

getWikiIndexApiR :: Handler Value
getWikiIndexApiR = do
    pages <- runDB $ selectList [] [Asc WikiPageTitle]
    return $ object ["pages" .= pages]

form :: Form (Text, Textarea)
form = renderBootstrap3 BootstrapBasicForm $ (,)
    <$> areq textField (withSmallInput "タイトル") Nothing
    <*> areq textareaField (withSmallInput "ソース") Nothing
