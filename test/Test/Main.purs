module Test.Main where

--import Effect.AVar (AVAR)
--import Effect.Console (CONSOLE)
--import Effect.Random (RANDOM)
import Data.Binary.Bits.Spec as Bits
import Data.Binary.UnsignedInt.Spec as UnsignedInt
import Data.Binary.SignedInt.Spec as SignedInt
import Prelude hiding (add)
--import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (runTest)
import Effect (Effect)

--main :: ∀ e. Effect ( console     :: CONSOLE
--                 , testOutput  :: TESTOUTPUT
--                 , avar        :: AVAR
--                 , random      :: RANDOM
--                 | e
--                 ) Unit
main :: Effect Unit
main = runTest do
  Bits.spec
  UnsignedInt.spec
  SignedInt.spec
