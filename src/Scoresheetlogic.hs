{-# Language NoImplicitPrelude #-}

module Scoresheetlogic where

import Import
import qualified Prelude as P
import qualified Data.List as L
import Ageclass

getTotalLifter :: Lifter -> Maybe Double
getTotalLifter lifter = getHighestLift (lifterAttemptDL1Weight lifter) (lifterAttemptDL1Success lifter)
                             (lifterAttemptDL2Weight lifter) (lifterAttemptDL2Success lifter)
                             (lifterAttemptDL3Weight lifter) (lifterAttemptDL3Success lifter)
    where
        getHighestLift a1 s1 a2 s2 a3 s3 = L.minimumBy (P.flip P.compare)
                                          [getLiftWeight a1 s1,getLiftWeight a2 s2, getLiftWeight a3 s3]

        getLiftWeight :: Maybe Double -> Maybe Bool -> Maybe Double
        getLiftWeight (Just x) (Just True) = Just x
        getLiftWeight _ _ = Nothing

nextAttemptNr :: Lifter -> Maybe Int
nextAttemptNr l
            | lifterAttemptDL1Success l == Nothing   = Just 1
            | lifterAttemptDL2Success l == Nothing   = Just 2
            | lifterAttemptDL3Success l == Nothing   = Just 3
            | otherwise = Nothing

nextWeight:: Lifter -> Maybe Int -> Maybe Double
nextWeight l att
            | att == Just 1    = lifterAttemptDL1Weight l
            | att == Just 2    = lifterAttemptDL2Weight l
            | att == Just 3    = lifterAttemptDL3Weight l
            | otherwise        = Nothing

cmpLifterGroupAndTotal :: Int -> Lifter -> Lifter -> Ordering
cmpLifterGroupAndTotal g l1 l2 | (lifterGroup l1 == g) && (lifterGroup l2 /= g)
                                     = LT
                               | (lifterGroup l2 == g) && (lifterGroup l1 /= g)
                                     = GT
                               | lifterGroup l1 /= lifterGroup l2
                                     = compare (lifterGroup l1) (lifterGroup l2) --keiner in der prio gruppe
                               | getTotalLifter l1 /= getTotalLifter l2 -- l1 und l2 selbe Gruppe ab hier
                                     = flip compare (getTotalLifter l1) (getTotalLifter l2)
                               | otherwise --selbe Gruppe und Total identisch -> BW
                                     = compare (lifterWeight l1) (lifterWeight l2)

cmpLifterOrder :: Lifter -> Lifter -> Ordering
cmpLifterOrder l1 l2
             | nextAttemptNr l1 /= nextAttemptNr l2
                   = compareMaybe (nextAttemptNr l1) (nextAttemptNr l2)
             | nextWeight l1 (nextAttemptNr l1) /= nextWeight l2 (nextAttemptNr l2)
                   = compareMaybe (nextWeight l1 $ nextAttemptNr l1)
                                                            (nextWeight l2 $ nextAttemptNr l2)
             | lifterWeight l1 /= lifterWeight l2
                   = compare (lifterWeight l1) (lifterWeight l2)
             | otherwise
                   = EQ
    where
        compareMaybe :: (Ord a) => Maybe a -> Maybe a -> Ordering -- Nothing also kein Gewicht angegeben oder alle Versuche gemacht -> ans ende sortieren
        compareMaybe Nothing Nothing   = EQ
        compareMaybe (Just _) Nothing  = LT
        compareMaybe Nothing (Just _)  = GT
        compareMaybe (Just x) (Just y) = compare x y

compareLifterClass :: (Ageclass,String) -> Lifter -> Lifter -> Ordering
compareLifterClass c l1 l2 | (c == getClass l1) && (c /= getClass l2)
                                 = LT
                           | (getClass l2 == c) && (getClass l1 /= c)
                                 = GT
                           | getClass l1 /= getClass l2
                                 = compare (getClass l1) (getClass l2)
                           | getTotalLifter l1 /= getTotalLifter l2
                                 = compare (getTotalLifter l1) (getTotalLifter l2)
                           | otherwise
                                 = compare (lifterWeight l1) (lifterWeight l2)

getClass :: Lifter -> (Ageclass, String)
getClass l = (lifterAgeclass l, lifterWeightclass l)
