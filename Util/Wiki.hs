module Util.Wiki where

import Prelude
import qualified Data.List as L
import Data.Text
import Text.Parsec
import Text.Parsec.Text

data WikiToken = PlainText { plainTextText :: Text }
               | PageTitle { pageTitleText :: Text }
                 deriving (Eq, Show)

toWikiTokens :: Text -> [WikiToken]
toWikiTokens content = case parse wikiTokensParser "Wiki content parser" content of
    Right value -> value
    Left  _     -> [PlainText content]

isPageTitle :: WikiToken -> Bool
isPageTitle (PlainText _) = False
isPageTitle (PageTitle _) = True

extractPageTitle :: [WikiToken] -> [WikiToken]
extractPageTitle = L.filter isPageTitle

plainTextParser :: Parser WikiToken
plainTextParser = do
    text <- many1 $ noneOf "["
    return $ PlainText $ pack text

pageTitleParser :: Parser WikiToken
pageTitleParser = do
    _    <- string "[["
    text <- many1 $ noneOf "]"
    _    <- string "]]"
    return $ PageTitle $ pack text

wikiTokenParser :: Parser WikiToken
wikiTokenParser = pageTitleParser <|> plainTextParser

wikiTokensParser :: Parser [WikiToken]
wikiTokensParser = many1 $ wikiTokenParser
