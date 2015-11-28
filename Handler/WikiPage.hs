module Handler.WikiPage where

import Import
import qualified Data.Map as M
import qualified Data.List as L
import Util.Web
import Util.Wiki

getWikiPageIndexR :: Handler Html
getWikiPageIndexR = do
    mi <- maybeAuth
    pages <- runDB $ selectList [] [Asc WikiPageTitle]
    defaultLayout $ do
        setTitle' "Wikiページ一覧"
        $(widgetFile "wikiindex")

postWikiPageIndexR :: Handler Html
postWikiPageIndexR = do
    ((result, _), _) <- runFormPost formEmpty
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
        setTitle' "新しいWikiページ"
        $(widgetFile "wikinew")

getWikiPageR :: WikiPageId -> Handler Html
getWikiPageR pageId = do
    page <- runDB $ get404 pageId
    tokens <- processWikiContent $ unTextarea $ wikiPageContent page
    defaultLayout $ do
        setTitle' $ toHtml $ wikiPageTitle page
        $(widgetFile "wikipage")

processWikiContent :: Text -> Handler WikiContent
processWikiContent text = do
    wikiTokens <- return $ toWikiTokens text
    titleKeys <- collectKeys $ extractPageTitle wikiTokens
    return $ L.map (conv titleKeys) wikiTokens
  where
     collectKeys :: [WikiToken] -> Handler (M.Map Text (Key WikiPage))
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
    (formWidget, _) <- generateFormPost $ formWithPage page
    defaultLayout $ do
        setTitle' "Wikiページの編集"
        $(widgetFile "wikiedit")

postWikiPageR :: WikiPageId -> Handler Html
postWikiPageR pageId = do
    ((result, _), _) <- runFormPost formEmpty
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

type WikiPageInput = (Text, Textarea)

formEmpty :: Html -> MForm Handler (FormResult WikiPageInput, Widget)
formEmpty = formPrimary Nothing Nothing

formWithTitle :: Maybe Text -> Html -> MForm Handler (FormResult WikiPageInput, Widget)
formWithTitle mt = formPrimary mt Nothing

formWithPage :: WikiPage -> Html -> MForm Handler (FormResult WikiPageInput, Widget)
formWithPage page = formPrimary (Just $ wikiPageTitle page) (Just $ wikiPageContent page)

formPrimary :: Maybe Text -> Maybe Textarea -> Html -> MForm Handler (FormResult WikiPageInput, Widget)
formPrimary mt mc extra = do
    (titleValueResult  , titleView)   <- mreq textField (addClass "" "form-control") mt
    (contentValueResult, contentView) <- mreq textareaField (addClass "" "form-control") mc
    let result = (,)
            <$> titleValueResult
            <*> contentValueResult
        widget = $(widgetFile "wiki-form")
    return (result, widget)

