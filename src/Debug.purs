module Debug where

import Prelude (class Show)
import Effect.Class.Console (logShow)
import Effect.Unsafe (unsafePerformEffect)

dbg :: ∀ a s . Show s => s -> a -> a
dbg s a = let _ = unsafePerformEffect (logShow s) in a

dbgs :: ∀ s . Show s => s -> s
dbgs s = let _ = unsafePerformEffect (logShow s) in s
