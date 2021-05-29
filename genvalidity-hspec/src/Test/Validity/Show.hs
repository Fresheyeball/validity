{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

-- | 'Show' and 'Read' properties
module Test.Validity.Show
  ( showReadSpecOnValid,
    showReadSpec,
    showReadSpecOnArbitrary,
    showReadSpecOnGen,
    showReadRoundTripOnValid,
    showReadRoundTrip,
    showReadRoundTripOnArbitrary,
    showReadRoundTripOnGen,
  )
where

import Data.Data
import Data.GenValidity
import Test.Hspec
import Test.QuickCheck
import Test.Validity.Utils
import Text.Read

-- | Standard test spec for properties of Show and Read instances for valid values
--
-- Example usage:
--
-- > showReadSpecOnValid @Double
showReadSpecOnValid ::
  forall a.
  (Show a, Eq a, Read a, Typeable a, GenValid a) =>
  Spec
showReadSpecOnValid = showReadSpecOnGen @a genValid "valid" shrinkValid

-- | Standard test spec for properties of Show and Read instances for unchecked values
--
-- Example usage:
--
-- > showReadSpec @Int
showReadSpec ::
  forall a.
  (Show a, Eq a, Read a, Typeable a, GenUnchecked a) =>
  Spec
showReadSpec = showReadSpecOnGen @a genUnchecked "unchecked" shrinkUnchecked

-- | Standard test spec for properties of Show and Read instances for arbitrary values
--
-- Example usage:
--
-- > showReadSpecOnArbitrary @Double
showReadSpecOnArbitrary ::
  forall a.
  (Show a, Eq a, Read a, Typeable a, Arbitrary a) =>
  Spec
showReadSpecOnArbitrary = showReadSpecOnGen @a arbitrary "arbitrary" shrink

-- | Standard test spec for properties of Show and Read instances for values generated by a custom generator
--
-- Example usage:
--
-- > showReadSpecOnGen ((* 2) <$> genValid @Int) "even" (const [])
showReadSpecOnGen ::
  forall a.
  (Show a, Eq a, Read a, Typeable a) =>
  Gen a ->
  String ->
  (a -> [a]) ->
  Spec
showReadSpecOnGen gen n s =
  describe (unwords ["Show", nameOf @a, "and Read", nameOf @a]) $
    it (unwords ["are implemented such that read . show == id for", n, "values"]) $
      showReadRoundTripOnGen gen s

-- |
--
-- prop> showReadRoundTripOnValid @Rational
showReadRoundTripOnValid ::
  forall a.
  (Show a, Eq a, Read a, GenValid a) =>
  Property
showReadRoundTripOnValid =
  showReadRoundTripOnGen (genValid :: Gen a) shrinkValid

-- |
--
-- prop> showReadRoundTrip @Int
showReadRoundTrip ::
  forall a.
  (Show a, Eq a, Read a, GenUnchecked a) =>
  Property
showReadRoundTrip =
  showReadRoundTripOnGen (genUnchecked :: Gen a) shrinkUnchecked

-- |
--
-- prop> showReadRoundTripOnArbitrary @Double
showReadRoundTripOnArbitrary ::
  forall a.
  (Show a, Eq a, Read a, Arbitrary a) =>
  Property
showReadRoundTripOnArbitrary =
  showReadRoundTripOnGen (arbitrary :: Gen a) shrink

-- |
--
-- prop> showReadRoundTripOnGen (abs <$> genUnchecked :: Gen Int) (const [])
showReadRoundTripOnGen ::
  (Show a, Eq a, Read a) => Gen a -> (a -> [a]) -> Property
showReadRoundTripOnGen gen s =
  forAllShrink gen s $ \v -> readMaybe (show v) `shouldBe` Just v
