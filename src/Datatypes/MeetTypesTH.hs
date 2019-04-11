{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoImplicitPrelude #-} {-# LANGUAGE RecordWildCards #-}

module MeetTypesTH where

import ClassyPrelude.Yesod
import Language.Haskell.TH
import Settings
import Yesod.Default.Config2
import Data.Text as T

type Weight = Double
data Attempt = Unset | Todo Weight | Success Weight | Fail Weight | Skip deriving (Show, Read, Eq)
data LiftModifier = MTodo | MGood | MFail | MSkip deriving Eq
data Discipline = Discipline { att1 :: Attempt, att2 :: Attempt, att3 :: Attempt} deriving (Show, Read, Eq)

attemptFail :: Attempt -> Bool
attemptFail (Fail _) = True
attemptFail _        = True

attemptToModifier :: Attempt -> LiftModifier
attemptToModifier Unset       = MTodo
attemptToModifier (Todo _)    = MTodo
attemptToModifier (Success _) = MGood
attemptToModifier (Fail _)    = MFail
attemptToModifier Skip        = MSkip

attemptWeight :: Attempt -> Maybe Double
attemptWeight (Todo w)    = Just w
attemptWeight (Success w) = Just w
attemptWeight (Fail w)    = Just w
attemptWeight _           = Nothing

attemptPending :: Attempt -> Bool
attemptPending Unset     = True
attemptPending (Todo _ ) = True
attemptPending _         = False

readMeetSettings :: FilePath -> IO MeetSettings
readMeetSettings fp = loadYamlSettings [fp] [] useEnv

meetSettingsFile :: FilePath
meetSettingsFile = "config/meetSettings.yml"

meetSettings :: IO MeetSettings
meetSettings = readMeetSettings meetSettingsFile

instance ToJSON Attempt where
  toJSON = toJSON . show

instance ToJSON Discipline where
  toJSON Discipline {..} = object [ "att1" .= toJSON att1, "att2" .= toJSON att2, "att3" .= toJSON att3]

attemptsAsList :: Discipline -> [Attempt]
attemptsAsList Discipline {..} = [att1,att2,att3]

emptyAttempt :: Attempt
emptyAttempt = Unset

emptyDiscipline :: Discipline
emptyDiscipline = Discipline emptyAttempt emptyAttempt emptyAttempt

readDisciplines :: IO [Text]
readDisciplines = meetTypeStr <$> meetSettings

resultsTypeTH :: Q [Dec]
resultsTypeTH = do
    disc <- liftIO readDisciplines
    (pure . pure) $ DataD [] typeName [] Nothing [constr disc] []

    where
      typeName = mkName "Results"
      constr disc = RecC typeName [(mkName ("_disc" ++ T.unpack name), defBang, attType) | name<-disc]
      defBang = Bang NoSourceUnpackedness NoSourceStrictness
      attType = ConT ''Discipline