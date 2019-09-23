{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE AllowAmbiguousTypes #-}

-- | Ord properties
--
-- You will need @TypeApplications@ to use these.
module Test.Validity.Ord
    ( ordSpecOnGen
    , ordSpecOnValid
    , ordSpecOnInvalid
    , ordSpec
    , ordSpecOnArbitrary
    ) where

import Data.Data

import Data.GenValidity

import Test.Hspec
import Test.QuickCheck

import Test.Validity.Functions
import Test.Validity.Relations
import Test.Validity.Utils

{-# ANN module "HLint: ignore Use <=" #-}

{-# ANN module "HLint: ignore Use >=" #-}

{-# ANN module "HLint: ignore Use <" #-}

{-# ANN module "HLint: ignore Use >" #-}

leTypeStr ::
       forall a. Typeable a
    => String
leTypeStr = binRelStr @a "<="

geTypeStr ::
       forall a. Typeable a
    => String
geTypeStr = binRelStr @a ">="

ltTypeStr ::
       forall a. Typeable a
    => String
ltTypeStr = binRelStr @a "<"

gtTypeStr ::
       forall a. Typeable a
    => String
gtTypeStr = binRelStr @a ">"

-- | Standard test spec for properties of Ord instances for valid values
--
-- Example usage:
--
-- > ordSpecOnValid @Double
ordSpecOnValid ::
       forall a. (Show a, Ord a, Typeable a, GenValid a)
    => Spec
ordSpecOnValid = ordSpecOnGen @a genValid "valid" shrinkValid

-- | Standard test spec for properties of Ord instances for invalid values
--
-- Example usage:
--
-- > ordSpecOnInvalid @Double
ordSpecOnInvalid ::
       forall a. (Show a, Ord a, Typeable a, GenInvalid a)
    => Spec
ordSpecOnInvalid = ordSpecOnGen @a genInvalid "invalid" shrinkInvalid

-- | Standard test spec for properties of Ord instances for unchecked values
--
-- Example usage:
--
-- > ordSpec @Int
ordSpec ::
       forall a. (Show a, Ord a, Typeable a, GenUnchecked a)
    => Spec
ordSpec = ordSpecOnGen @a genUnchecked "unchecked" shrinkUnchecked

-- | Standard test spec for properties of Ord instances for arbitrary values
--
-- Example usage:
--
-- > ordSpecOnArbitrary @Int
ordSpecOnArbitrary ::
       forall a. (Show a, Ord a, Typeable a, Arbitrary a)
    => Spec
ordSpecOnArbitrary = ordSpecOnGen @a arbitrary "arbitrary" shrink

-- | Standard test spec for properties of Ord instances for values generated by a given generator (and name for that generator).
--
-- Example usage:
--
-- > ordSpecOnGen ((* 2) <$> genValid @Int) "even"
ordSpecOnGen ::
       forall a. (Show a, Eq a, Ord a, Typeable a)
    => Gen a
    -> String
    -> (a -> [a])
    -> Spec
ordSpecOnGen gen genname s =
    parallel $ do
        let name = nameOf @a
            funlestr = leTypeStr @a
            fungestr = geTypeStr @a
            funltstr = ltTypeStr @a
            fungtstr = gtTypeStr @a
            minmaxtstr = genDescr @(a->a->a)
            itProp s_ = it $ unwords
                [ s_
                  , "\"" ++ genname
                  , name ++ "\"" ++ "'s"
                ]
            cmple = (<=) @a
            cmpge = (>=) @a
            cmplt = (<) @a
            cmpgt = (>) @a
            gen2 = (,) <$> gen <*> gen
            gen3 = (,,) <$> gen <*> gen <*> gen
            s2 = shrinkT2 s
        describe ("Ord " ++ name) $ do
            describe funlestr $ do
                itProp "is reflexive for" $
                    reflexivityOnGen cmple gen s
                itProp "is antisymmetric for" $
                    antisymmetryOnGens cmple gen2 s
                itProp "is transitive for" $
                    transitivityOnGens cmple gen3 s
                itProp "is equivalent to (\\a b -> compare a b /= GT) for" $
                    equivalentOnGens2 cmple (\a b -> compare a b /= GT) gen2 s2
            describe fungestr $ do
                itProp "is reflexive for" $
                    reflexivityOnGen cmpge gen s
                itProp "is antisymmetric for" $
                    antisymmetryOnGens cmpge gen2 s
                itProp "is transitive for" $
                    transitivityOnGens cmpge gen3 s
                itProp "is equivalent to (\\a b -> compare a b /= LT) for" $
                    equivalentOnGens2 cmpge (\a b -> compare a b /= LT) gen2 s2
            describe funltstr $ do
                itProp "is antireflexive for" $
                    antireflexivityOnGen cmplt gen s
                itProp "is transitive for" $
                    transitivityOnGens cmplt gen3 s
                itProp "is equivalent to (\\a b -> compare a b == LT) for" $
                    equivalentOnGens2 cmplt (\a b -> compare a b == LT) gen2 s2
            describe fungtstr $ do
                itProp "is antireflexive for" $
                    antireflexivityOnGen cmpgt gen s
                itProp "is transitive for" $
                    transitivityOnGens cmpgt gen3 s
                itProp "is equivalent to (\\a b -> compare a b == GT) for" $
                    equivalentOnGens2 cmpgt (\a b -> compare a b == GT) gen2 s2
            describe (minmaxtstr "min") $ do
                itProp "is equivalent to (\\a b -> if a <= b then a else b) for" $
                    equivalentOnGens2 min (\a b -> if a <= b then a else b) gen2 s2
            describe (minmaxtstr "max") $ do
                itProp "is equivalent to (\\a b -> if a >= b then a else b) for" $
                    equivalentOnGens2 max (\a b -> if a >= b then a else b) gen2 s2
