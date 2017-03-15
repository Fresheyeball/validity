{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Test.Validity.Relations.Antireflexivity
    ( antireflexiveOnElem
    , antireflexivityOnGen
    , antireflexivityOnValid
    , antireflexivity
    , antireflexivityOnArbitrary
    ) where

import Data.GenValidity

import Test.QuickCheck

-- |
--
-- \[
--   Antireflexive(\prec)
--   \quad\equiv\quad
--   \forall a: \neg (a \prec a)
-- \]
antireflexiveOnElem
    :: (a -> a -> Bool) -- ^ A relation
    -> a -- ^ An element
    -> Bool
antireflexiveOnElem func a = not $ func a a

antireflexivityOnGen
    :: Show a
    => (a -> a -> Bool) -> Gen a -> Property
antireflexivityOnGen func gen = forAll gen $ antireflexiveOnElem func

-- |
--
-- prop> antireflexivityOnValid ((<) :: Double -> Double -> Bool)
-- prop> antireflexivityOnValid ((/=) :: Double -> Double -> Bool)
-- prop> antireflexivityOnValid ((>) :: Double -> Double -> Bool)
antireflexivityOnValid
    :: (Show a, GenValid a)
    => (a -> a -> Bool) -> Property
antireflexivityOnValid func = antireflexivityOnGen func genValid

-- |
--
-- prop> antireflexivity ((<) :: Int -> Int -> Bool)
-- prop> antireflexivity ((/=) :: Int -> Int -> Bool)
-- prop> antireflexivity ((>) :: Int -> Int -> Bool)
antireflexivity
    :: (Show a, GenUnchecked a)
    => (a -> a -> Bool) -> Property
antireflexivity func = antireflexivityOnGen func genUnchecked

-- |
--
-- prop> antireflexivityOnArbitrary ((<) :: Int -> Int -> Bool)
-- prop> antireflexivityOnArbitrary ((/=) :: Int -> Int -> Bool)
-- prop> antireflexivityOnArbitrary ((>) :: Int -> Int -> Bool)
antireflexivityOnArbitrary
    :: (Show a, Arbitrary a)
    => (a -> a -> Bool) -> Property
antireflexivityOnArbitrary func = antireflexivityOnGen func arbitrary
