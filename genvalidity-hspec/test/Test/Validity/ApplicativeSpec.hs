{-# LANGUAGE TypeApplications #-}

module Test.Validity.ApplicativeSpec where

import Data.GenValidity
import Test.Hspec
import Test.Validity.Applicative

spec :: Spec
spec = do
  applicativeSpecOnValid @[]
  applicativeSpecOnValid @Maybe
  applicativeSpec @(Either Int)
  applicativeSpec @[]
  applicativeSpec @Maybe
  applicativeSpecOnArbitrary @[]
  applicativeSpecOnArbitrary @Maybe
  applicativeSpecOnGens
    @[]
    @Int
    (pure 4)
    "four"
    (genListOf $ pure 5)
    "list of fives"
    (pure [])
    "purely empty list"
    ((+) <$> genValid)
    "increments"
    (pure <$> ((+) <$> genValid))
    "increments in a list"
    (pure <$> ((*) <$> genValid))
    "scalings in a list"
  applicativeSpecOnGens
    @Maybe
    @String
    (pure "ABC")
    "ABC"
    (Just <$> pure "ABC")
    "Just an ABC"
    (pure Nothing)
    "purely Nothing"
    ((++) <$> genValid)
    "prepends"
    (pure <$> ((++) <$> genValid))
    "prepends in a Just"
    (pure <$> (flip (++) <$> genValid))
    "appends in a Just"
