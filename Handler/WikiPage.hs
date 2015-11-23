module Handler.WikiPage where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3, withSmallInput)

getWikiPageIndexR :: Handler Html
getWikiPageIndexR = do
    pages <- runDB $ selectList [] [Asc WikiPageTitle]
    defaultLayout $ do
        setTitle "Wikiページ一覧"
        $(widgetFile "wikiindex")

postWikiPageIndexR :: Handler Html
postWikiPageIndexR = do
    ((result, _), _) <- runFormPost form
    let mNewPage = case result of
            FormSuccess res -> Just res
            _               -> Nothing
    case mNewPage of
        Just newPage -> do
             _ <- runDB $ insert $ WikiPage (fst newPage) (snd newPage)
             redirect WikiPageIndexR
        Nothing      -> redirect WikiPageIndexR

getWikiPageNewR :: Handler Html
getWikiPageNewR = do
    (formWidget, _) <- generateFormPost form
    defaultLayout $ do
        setTitle "新しいWikiページ"
        $(widgetFile "wikinew")

getWikiPageR :: WikiPageId -> Handler Html
getWikiPageR pageId = do
    page <- runDB $ get404 pageId
    (formWidget, _) <- generateFormPost $ form' page
    defaultLayout $ do
        setTitle "Wikiページの編集"
        $(widgetFile "wikiedit")

postWikiPageR :: WikiPageId -> Handler Html
postWikiPageR pageId = do
    ((result, _), _) <- runFormPost form
    let mNewPage = case result of
            FormSuccess res -> Just res
            _               -> Nothing
    case mNewPage of
        Just newPage -> do
             _ <- runDB $ update pageId [WikiPageTitle =. (fst newPage), WikiPageContent =. (snd newPage)]
             redirect WikiPageIndexR
        Nothing      -> redirect WikiPageIndexR

getWikiIndexApiR :: Handler Value
getWikiIndexApiR = do
    pages <- runDB $ selectList [] [Asc WikiPageTitle]
    return $ object ["pages" .= pages]

form :: Form (Text, Textarea)
form = renderBootstrap3 BootstrapBasicForm $ (,)
    <$> areq textField (withSmallInput "タイトル") Nothing
    <*> areq textareaField (withSmallInput "ソース") Nothing

form' :: WikiPage -> Form (Text, Textarea)
form' page = renderBootstrap3 BootstrapBasicForm $ (,)
    <$> areq textField (withSmallInput "タイトル") (Just (wikiPageTitle page))
    <*> areq textareaField (withSmallInput "ソース") (Just (wikiPageContent page))
