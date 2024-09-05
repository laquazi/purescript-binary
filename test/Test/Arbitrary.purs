module Test.Arbitrary where

import Prelude

import Data.Array as A
import Data.Binary (Bit(..), Bits(..), _0, _1)
import Data.Binary.BaseN (Radix(..))
import Data.Binary.SignedInt (SignedInt)
import Data.Binary.SignedInt as SI
import Data.Binary.UnsignedInt (UnsignedInt)
import Data.Binary.UnsignedInt as UI
import Data.Int (toNumber)
import Data.List (List(..), (:))
import Data.Newtype (class Newtype, unwrap)
import Data.NonEmpty (NonEmpty(NonEmpty), (:|))
import Data.Tuple (Tuple(..))
import Data.Typelevel.Num (D31, D32, d31, d32)
import Test.QuickCheck (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (Gen, chooseInt, elements, frequency, sized, suchThat, vectorOf)
import Data.Array.NonEmpty (fromNonEmpty)

newtype ArbInt4 = ArbInt4 Int
instance arbitraryInt4 :: Arbitrary ArbInt4 where
  arbitrary = ArbInt4 <$> chooseInt (negate 128) 127

newtype ArbInt = ArbInt Int
derive instance newtypeArbInt :: Newtype ArbInt _
derive newtype instance eqArbInt :: Eq ArbInt
instance arbitraryInt :: Arbitrary ArbInt where
  arbitrary = ArbInt <$> (frequency $ fromNonEmpty $ gens) where
    gens = Tuple 0.05 (pure 0) :| [ Tuple 0.05 (pure 1),
                                    Tuple 0.05 (pure (negate 1)),
                                    Tuple 0.05 (pure top),
                                    Tuple 0.05 (pure bottom),
                                    Tuple 0.75 arbitrary ]

newtype ArbNonNegativeInt = ArbNonNegativeInt Int
instance arbitraryNonNegativeInt :: Arbitrary ArbNonNegativeInt where
  arbitrary = ArbNonNegativeInt <$> (frequency $ fromNonEmpty gens) where
    gens = Tuple 0.05 (pure top)
        :| [ Tuple 0.05 (pure one),
             Tuple 0.90 (suchThat arbitrary (_ >= 0)) ]


newtype ArbUnsignedInt31 = ArbUnsignedInt31 (UnsignedInt D31)
derive instance newtypeArbUnsignedInt31 :: Newtype ArbUnsignedInt31 _
instance arbitraryUnsignedInt31 :: Arbitrary ArbUnsignedInt31 where
  arbitrary = ArbUnsignedInt31 <$> do
    ArbNonNegativeInt a <- arbitrary
    pure (UI.fromInt d31 a)

newtype ArbSignedInt32 = ArbSignedInt32 (SignedInt D32)
derive newtype instance showArbSignedInt32 :: Show ArbSignedInt32
derive instance newtypeArbSignedInt32 :: Newtype ArbSignedInt32 _
instance arbitrarySignedInt32 :: Arbitrary ArbSignedInt32 where
  arbitrary = ArbSignedInt32 <$> do
    ArbInt i <- arbitrary
    pure (SI.fromInt d32 i)

newtype NonOverflowingMultiplicands = NonOverflowingMultiplicands (Tuple Int Int)
instance arbitraryNonOverflowingMultiplicands :: Arbitrary NonOverflowingMultiplicands where
  arbitrary = NonOverflowingMultiplicands <$> (flip suchThat nonOverflowing) do
    (ArbNonNegativeInt a) <- arbitrary
    (ArbNonNegativeInt b) <- arbitrary
    pure (Tuple a b)
    where nonOverflowing (Tuple a b) = (toNumber a) * (toNumber b) <= toNumber (top :: Int)

newtype ArbBit = ArbBit Bit
derive instance newtypeArbBit :: Newtype ArbBit _
derive newtype instance eqArbBit :: Eq ArbBit
derive newtype instance showArbBit :: Show ArbBit
instance arbitraryBit :: Arbitrary ArbBit where
  arbitrary = ArbBit <<< Bit <$> arbitrary

newtype ArbBits = ArbBits Bits
derive newtype instance eqArbBits :: Eq ArbBits
derive newtype instance showArbBits :: Show ArbBits
instance arbitraryBits :: Arbitrary ArbBits where
  arbitrary =
    ArbBits <$> Bits <$> arbBits where
      arbBits = sized \s -> vectorOf s arbBit
      arbBit = unwrap <$> (arbitrary :: Gen ArbBit)

newtype ArbBits32 = ArbBits32 Bits
instance arbitraryBits32 :: Arbitrary ArbBits32 where
  arbitrary = ArbBits32 <$> Bits <$> (frequency $ fromNonEmpty gens) where
    gens = Tuple 0.05 (vectorOf 32 (pure _0))
        :| [ Tuple 0.05 (vectorOf 32 (pure _1))
            , Tuple 0.05 (flip A.snoc _1 <$> vectorOf 31 (pure _0))
            , Tuple 0.05 (flip A.snoc _0 <$> vectorOf 31 (pure _1))
            , Tuple 0.05 (A.cons _1 <$> vectorOf 31 (pure _0))
            , Tuple 0.05 (A.cons _0 <$> vectorOf 31 (pure _1))
            , Tuple 0.70 (vectorOf 32 arbBit) ]
    arbBit = unwrap <$> (arbitrary :: Gen ArbBit)

data ArbSemiringOp a = ArbSemiringOp String (a -> a -> a)
instance showArbitrarySemiringOp :: Show (ArbSemiringOp a)
  where show (ArbSemiringOp s _) = s
instance arbitrarySemiringOp :: Semiring a => Arbitrary (ArbSemiringOp a) where
  arbitrary = elements (NonEmpty opAdd [ opMul ] # fromNonEmpty) where
    opAdd = ArbSemiringOp "+" add
    opMul = ArbSemiringOp "*" mul

newtype ArbHexChar = ArbHexChar Char
derive instance newtypeArbHexChar :: Newtype ArbHexChar _
derive newtype instance eqArbHexChar :: Eq ArbHexChar
derive newtype instance showArbHexChar :: Show ArbHexChar
instance arbitraryArbHexChar :: Arbitrary ArbHexChar where
  arbitrary =
    let chrs = ['a', 'b', 'c', 'd', 'e', 'f',
                '1', '2', '3', '4', '5', '6', '7', '8', '9']
    in elements $ fromNonEmpty $ ArbHexChar <$> '0' :| chrs

newtype ArbOctChar = ArbOctChar Char
derive instance newtypeArbOctChar :: Newtype ArbOctChar _
derive newtype instance eqArbOctChar :: Eq ArbOctChar
derive newtype instance showArbOctChar :: Show ArbOctChar
instance arbitraryArbOctChar :: Arbitrary ArbOctChar where
  arbitrary = elements $ fromNonEmpty $ ArbOctChar <$> '0' :| ['1', '2', '3', '4', '5', '6', '7']

newtype ArbRadix = ArbRadix Radix
instance arbitraryRadix :: Arbitrary ArbRadix where
  arbitrary = elements $ fromNonEmpty $ ArbRadix <$> Bin :| [Oct, Dec, Hex]
