module Model where

import ClassyPrelude.Yesod
import Database.Persist.Quasi
import Yesod.Auth.HashDB (HashDBUser(..))

-- You can define all of your database entities in the entities file.
-- You can find more information on persistent and how to declare entities
-- at:
-- http://www.yesodweb.com/book/persistent/
share [mkPersist sqlSettings, mkMigrate "migrateAll"]
    $(persistFileWith lowerCaseSettings "config/models")

instance ToJSON (Entity WikiPage) where
    toJSON (Entity pid p) = object
      [ "id"      .= (String $ toPathPiece pid)
      , "title"   .= wikiPageTitle p
      , "content" .= wikiPageContent p
      ]

instance HashDBUser User where
    userPasswordHash = Just . userPassword
    userPasswordSalt = Just . userSalt
    setSaltAndPasswordHash s h p = p { userSalt = s
                                     , userPassword = h
                                     }
