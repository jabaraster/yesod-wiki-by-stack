module Util.Web where

import Import


lookupQueryStringParameterValue :: MonadHandler m => Text -> m (Maybe Text)
lookupQueryStringParameterValue parameterName = getRequest
    >>= return . lookup parameterName . reqGetParams
