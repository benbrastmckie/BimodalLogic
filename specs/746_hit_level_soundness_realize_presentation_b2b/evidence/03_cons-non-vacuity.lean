import FormalSystem.Metalogic.Decidability.RaySummary.Present

/-! # Crux probe C: non-vacuity of the `Cons P` untl conditions

Instantiates probe B's `UCoh` / `ULive` / `deferGraph` at `sig := ⟨Fin 4⟩`, where the four
letters are `u = 0` (the `untl` claim), `g = 1` (the guard), `e = 2` (the event) and
`now = 3`. Every condition is decided by `#guard`, so nothing here is argued.
-/

namespace Probe746C

open FormalSystem.Metalogic.WeakCanonical

abbrev Q3 := Fin 3

/-- `0` and `2` carry the event; `1` is the `now` state and lacks it. -/
def lab3 : Q3 → Fin 4 → Bool
  | 0 => fun p => p != 3
  | 1 => fun p => p == 0 || p == 1 || p == 3
  | 2 => fun p => p != 3

/-- `0 → 0`, `0 → 1`, `1 → 2`, `2 → 2`: the `now` state `1` lies on no cycle. -/
def step3 : Q3 → Q3 → Bool
  | 0, 0 => true
  | 0, 1 => true
  | 1, 2 => true
  | 2, 2 => true
  | _, _ => false

/-! **One-step coherence** (`UCoh`), decided over all nine state pairs. -/
#guard decide (∀ q q' : Q3, step3 q q' = true →
  (lab3 q 0 = true ↔ (lab3 q' 2 = true ∨ (lab3 q' 1 = true ∧ lab3 q' 0 = true))))

/-- The deferral graph, verbatim as probe B defines it. -/
def defer3 (x y : Q3) : Bool := lab3 x 0 && !(lab3 x 2) && step3 x y

/-! **No-deferral liveness** (`ULive`) holds: no state begins an infinite
claim-without-event chain. -/
#guard !(live defer3 0) && !(live defer3 1) && !(live defer3 2)

/-! Bi-seriality of `step3`, both senses — what `ofSlicedStep` consumes. -/
#guard decide (∀ q : Q3, ∃ q' : Q3, step3 q q' = true)
#guard decide (∀ q : Q3, ∃ q' : Q3, step3 q' q = true)

/-! The `now` state is visited at most once by any run: no `step3`-path of positive length up
to the carrier's size returns to `1`, so no run reads `now` twice. -/
#guard decide (∀ a b c : Q3,
  ¬ (step3 1 a = true ∧ a = 1) ∧
  ¬ (step3 1 a = true ∧ step3 a b = true ∧ b = 1) ∧
  ¬ (step3 1 a = true ∧ step3 a b = true ∧ step3 b c = true ∧ c = 1))

/-! And the conditions are not vacuous for the opposite reason either: the deferral graph has
an edge, so `ULive` is a real constraint satisfied, not an empty one. -/
#guard defer3 1 2

/-- The same presentation with the `0 → 0` self-loop made event-free **fails** `ULive` — the
`Probe735` shape. Here state `0`'s label is changed to lack the event. -/
def labBad : Q3 → Fin 4 → Bool
  | 0 => fun p => p == 0 || p == 1
  | 1 => fun p => p == 0 || p == 1 || p == 3
  | 2 => fun p => p != 3

def deferBad (x y : Q3) : Bool := labBad x 0 && !(labBad x 2) && step3 x y

/-! `ULive` fails on the bad labelling: state `0`'s self-loop defers forever. -/
#guard live deferBad 0

end Probe746C
