module Util.Hoge where

import Prelude
import Text.Parsec
import Text.Parsec.String

plainText :: Parser String
plainText = many1 $ noneOf "["

title :: Parser String
title = do
    _ <- string "[["
    t <- many1 $ noneOf "]"
    _ <- string "]]"
    return t

wikiToken :: Parser String
wikiToken = title <|> plainText

wikiTokens :: Parser [String]
wikiTokens = many1 $ wikiToken
