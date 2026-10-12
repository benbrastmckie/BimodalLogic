/-
PROTOTYPE TEST (not a wired probe): the RE-SCOPED cell-index candidate and the two CHEAP
falsification gates it must survive before any sufficiency proof is attempted.

## What the three-coordinate candidate was

The filed candidate was the gap-carrying three-coordinate index
  `(q, min c B, min n B, clip (n - c) [-B, B])`
with the claim that `ladderIndex B x = ladderIndex B y` forces `cellAt M phi (t,x) z` and
`cellAt M phi (t,y) z` to agree.

## Why it is refuted

`Count true true` forces the countdown to run down to `0` exactly -- there is no early
discharge -- so the first idle state of a pending region sits at distance exactly `c + 1`.  The
object's `step` relation is independent of the counters, so it may alternate a tag on every
pending step and copy that tag onto the idle state that ends the region.  An atom reading the
tag, under `p U (r AND a)`, therefore reads `c mod 2` at unbounded distance.  The sibling
prototype `parity-index-refutation.lean` machine-checks this: `cell_succ_ne` separates `(q,c,n)`
from `(q,c+1,n)` for EVERY `c` and `n` with `n` held FIXED, `index_collide` puts the pair
`((true,false), 2B, 4B+2)` and `((true,false), 2B+1, 4B+2)` at one index at every `B`, and
`ladderIndex_not_factoring` concludes.  The witnessing pair carries EQUAL next-deadlines and two
gaps that BOTH saturate the clip, so the gap coordinate is not what fails -- the countdown
coordinate is.

The gap mechanism recorded by the earlier refutation (`ladder-cell-refutation.lean`) is real and
is NOT displaced: it killed a SMALL gap at LARGE counters, which is why the gap coordinate is
retained here rather than dropped.

## What this file tests

Two CHEAP separations of the re-scoped six-coordinate candidate
  `(q, min c T, c % (P+1), min n T, n % (P+1), clip (n - c) [-B, B])`
against the two mechanisms already known to kill clipped-coordinate candidates:

  (1) `gate_gap_separates` -- the gap pair that killed the two-coordinate index;
  (2) `gate_parity_separates` -- the parity pair that kills the three-coordinate index.

**These are gates, never a sufficiency claim.**  A gate probing one coordinate certifies one
coordinate: the earlier one-part gate (`gate_separates` in the sibling prototype) passed on the
gap coordinate and the candidate it certified was refuted at the countdown coordinate anyway.
Nothing in this file states, or partially states, a factorization lemma, and the positive
factorization lemma for this or any index remains OPEN and unclaimed.

## Parameter origins, kept separate

`T` and `P` are OBJECT-derived: `reach-eventual-periodicity.lean` exhibits them as the threshold
and period of the `step`-reachability datum the region end exposes.  `B` is FORMULA-derived (the
X-nesting depth of `phi`, or `|cl phi|`), and is never tied to either -- the earlier gate's lower
half (`gate_collides_below_two`) is the same constraint read as a lower bound on `B`.  The three
parameters appear independently in every signature below and no theorem's hypotheses couple them.

The two residue coordinates use modulus `P + 1` so that `Fin (P + 1)` is inhabited with no side
hypothesis; `gate_parity_separates` is stated at a SYMBOLIC modulus rather than a literal, since
fixing it would weaken the statement.

Compile: `lake env lean specs/773_ladder_cell_index_factorization/prototype/residue-index-gate.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace ResidueIndexGate

/-! ## The fixture object, reused verbatim from the parity refutation

The index is generic in the object and the gates read only the counters and the object
component, so no second object is authored: these are the sibling prototype's `Qp`, `pendP`,
`stepP` and its admissible-state constructor, unchanged. -/

/-- Object states `(pending?, tag)`. -/
abbrev Qp : Type := Bool × Bool

def pendP : Qp → Bool := fun q => q.1

/-- While pending the tag flips on every pending step and is COPIED onto the idle state that
ends the region; an idle state only goes to an idle state with the same tag. -/
def stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

/-- A pending admissible ladder state with countdown `c` and next-deadline `n`. -/
def st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

/-! ## The re-scoped candidate index -/

/-- **The re-scoped candidate**: thresholds AND residues on both counters, beside the clipped
gap.  `T` and `P` are object-derived, `B` is formula-derived, and the three are independent.

The gap coordinate is offset by `B` so that it lands in `Fin (2*B + 1)`: truncated `ℕ`
subtraction implements the clip at `-B`, and `min _ (2*B)` the clip at `+B`.  A `Fintype` by
construction for every finite object. -/
def ladderIndexRes (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-! ## Gate 1: the gap pair that killed the two-coordinate index -/

/-- **The first cheap gate passes, for `2 ≤ B`.**  On the pair that the two-coordinate
refutation turns on -- counters `(B, B+1)` against `(B, B+2)`, where both counters saturate every
threshold -- the gap coordinate gives `B+1` against `B+2`, which the clip keeps apart as soon as
`2 ≤ B`.  The lower bound on `B` is exactly the earlier gate's collision half read as a
constraint: the clip must exceed the gaps the FORMULA can see, so `B` is formula-derived and
never counter-derived. -/
theorem gate_gap_separates (T P B : ℕ) (hB : 2 ≤ B) :
    ladderIndexRes T P B (st false B (B + 1)) ≠ ladderIndexRes T P B (st false B (B + 2)) := by
  intro h
  have h6 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.2.2.2.val) h
  simp only [ladderIndexRes, st] at h6
  omega

/-! ## Gate 2: the parity pair that kills the three-coordinate index -/

/-- The arithmetic the parity gate turns on, at a SYMBOLIC modulus.  Two consecutive naturals
cannot be congruent modulo `P + 1` once `1 ≤ P`: the congruence gives `(P+1 : ℤ) ∣ 1`, hence
`P + 1 ≤ 1`.  This is outside `omega`'s fragment, which handles `%` only at a literal modulus,
and fixing the modulus at `2` to dodge it would weaken `gate_parity_separates`. -/
theorem consec_mod_ne (P B : ℕ) (hP : 1 ≤ P) :
    2 * B % (P + 1) ≠ (2 * B + 1) % (P + 1) := by
  intro h
  have hm : Nat.ModEq (P + 1) (2 * B) (2 * B + 1) := h
  have hd := Nat.ModEq.dvd hm
  have h1 : ((P : ℤ) + 1) ∣ 1 := by
    have he : ((2 * B + 1 : ℕ) : ℤ) - ((2 * B : ℕ) : ℤ) = 1 := by push_cast; ring
    push_cast at hd
    push_cast at he
    rw [he] at hd
    exact_mod_cast hd
  have := Int.le_of_dvd (by norm_num) h1
  omega

/-- **The second cheap gate passes, for `1 ≤ P`.**  On the pair that REFUTES the three-coordinate
candidate -- counters `(2B, 4B+2)` against `(2B+1, 4B+2)`, with EQUAL next-deadlines, both
countdowns saturating `min _ B` at the refuted index's threshold, and both gaps saturating the
clip at `+B` -- the separating coordinate is the countdown residue `c % (P+1)`.  The gap
coordinate cannot do it (both gaps clip to the top) and the threshold coordinate cannot do it
(both countdowns saturate); the residue coordinate is what the re-scope adds. -/
theorem gate_parity_separates (T P B : ℕ) (hP : 1 ≤ P) :
    ladderIndexRes T P B (st false (2 * B) (4 * B + 2))
      ≠ ladderIndexRes T P B (st false (2 * B + 1) (4 * B + 2)) := by
  intro h
  have h3 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.1.val) h
  simp only [ladderIndexRes, st] at h3
  exact consec_mod_ne P B hP h3

end ResidueIndexGate

/-! ## Axiom check -/

#print axioms ResidueIndexGate.gate_gap_separates
#print axioms ResidueIndexGate.gate_parity_separates
