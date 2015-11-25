module Util.Web (
    lookupQueryStringParameterValue
    , addClass
)where

import Import
import qualified Data.Text as T

lookupQueryStringParameterValue :: MonadHandler m => Text -> m (Maybe Text)
lookupQueryStringParameterValue parameterName = getRequest
    >>= return . lookup parameterName . reqGetParams

addClass :: FieldSettings site -> Text -> FieldSettings site
addClass fs value = fs { fsAttrs = newAttrs }
    where newAttrs = addClass' value (fsAttrs fs)

addClass' :: Text -> [(Text, Text)] -> [(Text, Text)]
addClass' klass []                    = [("class", klass)]
addClass' klass (("class", old):rest) = ("class", T.concat [old, " ", klass]) : rest
addClass' klass (other         :rest) = other : addClass' klass rest

