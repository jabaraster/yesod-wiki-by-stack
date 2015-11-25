module Handler.WikiPage where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3, withSmallInput)
import qualified Data.Map as M
import qualified Data.List as L
import Util.Web
import Util.Wiki

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
    mTitle <- lookupQueryStringParameterValue "title"
    (formWidget, _) <- generateFormPost $ formWithTitle mTitle
    defaultLayout $ do
        setTitle "新しいWikiページ"
        $(widgetFile "wikinew")

getWikiPageR :: WikiPageId -> Handler Html
getWikiPageR pageId = do
    page <- runDB $ get404 pageId
    tokens <- processWikiContent $ unTextarea $ wikiPageContent page
    defaultLayout $ do
        setTitle $ toHtml $ ((wikiPageTitle page) ++ " - Wiki")
        $(widgetFile "wikipage")

processWikiContent :: Text -> Handler WikiContent
processWikiContent text = do
    wikiTokens <- return $ toWikiTokens text
    titleKeys <- collectKeys $ extractPageTitle wikiTokens
    return $ L.map (conv titleKeys) wikiTokens
  where
     collectKeys ts = do
         pages <- runDB $ selectList [WikiPageTitle <-. toPageTitles ts] []
         return $ M.fromList $ L.map (\(Entity key page) -> (wikiPageTitle page, key)) pages

     toPageTitles :: [WikiToken] -> [Text]
     toPageTitles = L.nub . L.map toPageTitle . L.filter isPageTitle

     conv :: (M.Map Text (Key WikiPage)) -> WikiToken -> Token
     conv _ (PlainText t) = Plain t
     conv m (PageTitle title) =
         case M.lookup title m of
             Just key -> Link title key
             Nothing  -> BrokenLink title

data Token = Plain Text | Link Text (Key WikiPage) | BrokenLink Text
type WikiContent = [Token]

getWikiPageEditR :: WikiPageId -> Handler Html
getWikiPageEditR pageId = do
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
             redirect $ WikiPageR pageId
        Nothing      -> redirect $ WikiPageIndexR

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

formWithTitle :: Maybe Text -> Form (Text, Textarea)
formWithTitle mt = renderBootstrap3 BootstrapBasicForm $ (,)
    <$> areq textField (withSmallInput "タイトル") mt
    <*> areq textareaField (withSmallInput "ソース") Nothing

