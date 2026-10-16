/- NINETEENTH PROBE -- header written in Phase 4.2 -/
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe806N

/-! ## The pinned definitional body, ported from the sixteenth probe

Ported from `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`.  Probes
do not import probes, so everything used below is restated here.  Only the index and object
layers are ported: no frame, no history, no model layer, no `cellAt`. -/

/-- **The candidate, at JOINTLY DERIVED parameters.**  The body is the fifteenth probe's
`ladderIndexRes` byte-for-byte; what changes is only where `(T, P, B)` come from, which is the
whole content of the parameter-origin rule.  Renamed so that what is gated below is the index at
rule-derived parameters and not the index at object-exhibited ones. -/
def ladderIndexJnt (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-! ## The two-state object layer, ported from the sixteenth probe -/

/-- Object states `(pending?, tag)` of the two-state fixture. -/
abbrev Qp : Type := Bool × Bool

def pendP : Qp → Bool := fun q => q.1

/-- While pending the tag flips on every pending step and is COPIED onto the idle state that ends
the region; an idle state steps to any state carrying the tag, so a second region may start. -/
def stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (y.2 == x.2)

/-- A pending admissible ladder state with countdown `c` and next deadline `n`. -/
def st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

/-- An idle admissible ladder state; `Adm` forces its countdown to `0`. -/
def idl (tg : Bool) (n : ℕ) : LadderState Qp pendP :=
  ⟨((false, tg), 0, n), fun _ => rfl⟩

/-! ## Gates 1 and 2, ported and re-run

The two ported gate theorems carry their original hypotheses unchanged (`2 ≤ B` for gate 1,
`1 ≤ P` for gate 2).  What they establish is that the refuted tuple's n-side coordinates are not
blind to the two separations the first two gates ask about -- which is the COMPILED half of the
hand-off this probe tests, and is re-established here by port rather than inherited by citation. -/

/-- **GATE 1 PASSES, for `2 ≤ B`.**  On mechanism (1)'s own pair -- counters `(B, B+1)` against
`(B, B+2)`, where both counters saturate every threshold -- the gap coordinate gives `B+1`
against `B+2`, which the clip keeps apart as soon as `2 ≤ B`. -/
theorem gate1_gap_separates (T P B : ℕ) (hB : 2 ≤ B) :
    ladderIndexJnt T P B (st false B (B + 1)) ≠ ladderIndexJnt T P B (st false B (B + 2)) := by
  intro h
  have h6 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.2.2.2.val) h
  simp only [ladderIndexJnt, st] at h6
  omega

/-- Two consecutive naturals cannot be congruent modulo `P + 1` once `1 ≤ P`. -/
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

/-- **GATE 2 PASSES, for `1 ≤ P`** -- which `RuleParams.mod_ge_two` supplies.  On mechanism (2)'s
own pair -- counters `(2B, 4B+2)` against `(2B+1, 4B+2)`, with EQUAL next deadlines, both
countdowns saturating the threshold coordinate and both gaps saturating the clip -- the
separating coordinate is the countdown residue. -/
theorem gate2_residue_separates (T P B : ℕ) (hP : 1 ≤ P) :
    ladderIndexJnt T P B (st false (2 * B) (4 * B + 2))
      ≠ ladderIndexJnt T P B (st false (2 * B + 1) (4 * B + 2)) := by
  intro h
  have h3 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.1.val) h
  simp only [ladderIndexJnt, st] at h3
  exact consec_mod_ne P B hP h3

/-! ## Gate 9: the n-side coordinates are BLIND to the n-side modulus shift

The pair below shifts the NEXT DEADLINE by the modulus itself, holding the countdown fixed, and
sits beyond the threshold on the `n` coordinate and beyond the clip on the gap coordinate.  Every
coordinate of the whole six-coordinate index then agrees, at every `(T, P, B)` and every
countdown.  Non-vacuity first: the two states are DISTINCT, which is this probe's characteristic
failure mode if it fails. -/

/-- The first member of the collided pair: countdown `c`, next deadline `T + c + B`. -/
def xN (T B c : ℕ) : LadderState Qp pendP := st false c (T + c + B)

/-- The second member: the same countdown, next deadline shifted by the modulus `P + 1`. -/
def yN (T P B c : ℕ) : LadderState Qp pendP := st false c (T + c + B + (P + 1))

/-- **NON-VACUITY.**  The collided pair is a pair of DISTINCT ladder states.  A collision between
equal states would say nothing at all, exactly as a vacuous coherence relation would say nothing
in the eighteenth probe. -/
theorem nside_pair_ne (T P B c : ℕ) : xN T B c ≠ yN T P B c := by
  intro h
  have h2 := congrArg (fun z : LadderState Qp pendP => z.1.2.2) h
  simp only [xN, yN, st] at h2
  omega

/-- **GATE 9'S COLLISION HALF.**  The refuted tuple's n-side coordinates are BLIND to the shift
`n ↦ n + (P + 1)`: at every `(T, P, B)` and every countdown `c`, the whole index agrees on the
pair.  The threshold coordinate agrees because `T ≤ T + c + B`; the residue coordinate agrees
because the shift is by the modulus itself; the clipped gap agrees because `T + 2B` and
`T + 2B + (P + 1)` both saturate `2B`.

So passing gates 1 and 2 does NOT make this shape adequate as the datum the next-deadline side
needs.

GATE 9'S REFUTING HALF IS NOT ATTEMPTED HERE, and gate 9 is therefore OPEN -- neither passed nor
refuted.  That half would be a formula on the coprime-cycle object giving `xN` and `yN` different
cells, which needs the sixteenth probe's whole model layer (`F5`, `M6`, `hist_path5`, `cellAt`); a
probe may not import a probe, and that layer is not restated here. -/
theorem nside_collides (T P B c : ℕ) :
    ladderIndexJnt T P B (xN T B c) = ladderIndexJnt T P B (yN T P B c) := by
  simp only [ladderIndexJnt, xN, yN, st, Prod.mk.injEq, Fin.mk.injEq, true_and]
  and_intros <;> first | omega | simp [Nat.add_mod_right]

end Probe806N

/-! ## Axiom check -/

#print axioms Probe806N.gate1_gap_separates
#print axioms Probe806N.gate2_residue_separates
#print axioms Probe806N.nside_pair_ne
#print axioms Probe806N.nside_collides
