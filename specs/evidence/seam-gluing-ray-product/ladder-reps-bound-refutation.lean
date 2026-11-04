/-
`repsCnt`'S NARROWER BOUND IS REFUTED: at `Tc + Tn + P + B + 2` the bounded-representative set is
TOO SMALL for the bounded-representative lemma, and the failure runs in two independent
directions. Three `decide`-checked tuples carry an actual `Count`/`Drift` step for which NO
representative pair lies inside the narrower range; each is paired with its POSITIVE counterpart
at the library's widened `RK`, discharged by `rk_of_count_drift` rather than by `decide`.

Why the bound is FROZEN inside this probe. `repsCnt` now ranges over
`Tc + Tn + 3*P + 2*B + 5`, at which `RK` is TRUE at all three tuples (the positive counterparts
below). A refutation stated against the library's own `RK` would therefore not compile, and the
compiled reason the bound was widened would be lost. So the narrower bound is re-declared here as
`repsCntPre`, with `rkStepBPre`, `RKbPre` and `RKPre` over it — verbatim the library's own text
with the one range argument as it stood. Precedent: the frozen `ParamsOkPre` of
`ladder-cell-obligation-refutation.lean`, and `AtomPreservingCountMove` kept as a `def` so its
refutation is a theorem about a named object. Nothing here is imported by any library module.

The two directions.

* SATURATED GAP, and it needs no residue at all. `witnessC_not_RKPre` is the `P = 0` half: at
  `P = 0` every residue coordinate is trivial, so the only obstruction left is the gap. The gap
  coordinate `clipIdx B c n` saturates at `±B`, and a representative that keeps it saturated on
  the pre-step AND the post-step pair must sit at least `B + 2` above the reduced next deadline,
  because the next deadline may drift by one between them. The narrower range's single `+ B`
  cannot pay for that: at `(Tc, Tn, P, B) = (0, 0, 0, 3)` the step `Count false false 5 2 0` with
  `Drift 2 3` needs a first coordinate at least `3` above a next deadline that must itself reach
  `3` after the drift, and the range stops at `4`.
* RESIDUE COUPLING. When the gap is EXACT the difference `n - c` is pinned, so the two counters
  must be moved by a COMMON multiple of `P + 1`; the reduced pair's first coordinate is then
  pinned to `c`'s residue class and may need a further `P + 1` of room above whichever threshold
  the construction clears. `witnessA_not_RKPre` is the worked case: at
  `(Tc, Tn, P, B) = (1, 2, 2, 2)` the step `Count false false 9 5 0` with `Drift 5 4` admits
  `(6, 2)` as a pre-step representative, but `Drift 2 b'` then forces `b' ≤ 3` while the
  post-step class demands `b' ≡ 1 (mod 3)` and `b' ≥ 2` — unsatisfiable. The least admissible
  first coordinate is `9`, exactly the narrower bound's own value `Tc + Tn + P + B + 2 = 9`, so
  it falls one place outside `Finset.range 9`. `witnessB_not_RKPre` is the same mechanism at a
  larger modulus.

`decide` over this predicate is `M^4`-shaped in the range bound `M`: `RKbPre` is a bounded
existential over `M^2` pairs whose body is another bounded existential over `M^2` pairs. That is
why the heartbeat ceiling, not taste, is the practical limit on how large a tuple any probe may
name here — at tuple B the narrower bound is `19` and the `decide` is already `19^4`-shaped,
while the widened bound there is `34` and a `decide` would be `34^4`-shaped and infeasible. The
positive counterparts are therefore proved by ONE application of `rk_of_count_drift` each, never
by `decide`. This is also the first use site of that lemma.

No bound is claimed, upper or lower: every quantity named is a COUNT of candidate pairs. Nothing
here relates `kappa`, `relK` or `RK` to `Rlad`, `RladAdm`, `ladderModel`, `tpOf` or `cellAt`, so
nothing here is the counter-lift lemma or any part of it.

The forty-eighth wired probe, compiled by `scripts/check-evidence-probes.sh`.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761W

/-! ### The narrower bound, frozen

Verbatim the library's `repsCnt`, `rkStepB`, `RKb` and `RK` with the one range argument as it
stood before the widening. The split of `rkStepBPre` out of `RKbPre` is the library's own, and
for the library's own reason: the two bounded existentials nested in one term exceed instance
resolution's depth. -/

/-- The narrower representative set: `Tc + Tn + P + B + 2` in both factors. -/
def repsCntPre (Tc Tn P B : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (Tc + Tn + P + B + 2)) ×ˢ (Finset.range (Tc + Tn + P + B + 2))

/-- The inner half of `R_K` over the frozen set. -/
def rkStepBPre (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) (x : ℕ × ℕ) : Bool :=
  decide (∃ y ∈ repsCntPre Tc Tn P B, Count px py x.1 x.2 y.1 ∧ Drift x.2 y.2 ∧
    kappa Tc Tn P B x = k ∧ kappa Tc Tn P B y = k')

/-- `R_K` as a `Bool` over the frozen set. -/
def RKbPre (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) : Bool :=
  decide (∃ x ∈ repsCntPre Tc Tn P B, rkStepBPre Tc Tn P B px py k k' x = true)

/-- `R_K` over the frozen set. -/
def RKPre (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) : Prop :=
  RKbPre Tc Tn P B px py k k' = true

instance decidableRKPre (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) :
    Decidable (RKPre Tc Tn P B px py k k') :=
  inferInstanceAs (Decidable (RKbPre Tc Tn P B px py k k' = true))

theorem repsCntPre_range (Tc Tn P B : ℕ) :
    repsCntPre Tc Tn P B
      = (Finset.range (Tc + Tn + P + B + 2)) ×ˢ (Finset.range (Tc + Tn + P + B + 2)) := rfl

/-! ### Witness A — the residue-coupling direction, worked

`(Tc, Tn, P, B) = (1, 2, 2, 2)`, so the narrower bound is `1 + 2 + 2 + 2 + 2 = 9` and the frozen
range is `{0, …, 8}`. The step is `Count false false 9 5 0` with `Drift 5 4`: an idle successor,
so the post-step countdown is `0`, and the next deadline drifts down by one.

The pre-step class `kappa 1 2 2 2 (9, 5)` asks for a first coordinate at or above `Tc = 1` and
congruent to `0 (mod 3)`, a second at or above `Tn = 2` and congruent to `2 (mod 3)`, and a gap
saturated DOWNWARD (`clipIdx 2 9 5 = 0`, so first ≥ second + 2). Inside `{0, …, 8}` the only
such pair is `(6, 2)`. But then `Drift 2 b'` confines the post-step second coordinate to
`{1, 2, 3}`, while the post-step class `kappa 1 2 2 2 (0, 4)` demands it be at or above `2` and
congruent to `1 (mod 3)` — and `4`, the least such value, is outside that window. The least
first coordinate that admits a post-step partner is `9`, which is exactly the narrower bound and
so exactly one place outside `Finset.range 9`. -/

set_option maxRecDepth 100000 in
theorem witnessA_count : Count false false 9 5 0 := by decide

theorem witnessA_drift : Drift 5 4 := by decide

set_option maxRecDepth 100000 in
theorem witnessA_not_RKPre :
    ¬ RKPre 1 2 2 2 false false (kappa 1 2 2 2 (9, 5)) (kappa 1 2 2 2 (0, 4)) := by decide

/-- The positive counterpart at the library's WIDENED `RK`, by one application of
`rk_of_count_drift`. At `(1, 2, 2, 2)` the widened bound is `1 + 2 + 6 + 4 + 5 = 18`. -/
theorem witnessA_RK :
    RK 1 2 2 2 false false (kappa 1 2 2 2 (9, 5)) (kappa 1 2 2 2 (0, 4)) :=
  rk_of_count_drift 1 2 2 2 false false 9 5 0 4 witnessA_count witnessA_drift

/-! ### Witness B — the same mechanism at a larger modulus

`(Tc, Tn, P, B) = (4, 6, 5, 2)`, narrower bound `4 + 6 + 5 + 2 + 2 = 19`. The step is
`Count true true 20 11 19` with `Drift 11 12`: a pending-to-pending step, so the countdown falls
by exactly one, and the next deadline drifts up by one.

Inside `{0, …, 18}` the pre-step class admits only `(14, 11)`. The pending-to-pending arm then
FORCES the post-step first coordinate to `13`, whose class demands a second coordinate congruent
to `0 (mod 6)` and at most `11` (to keep the gap saturated downward), while `Drift 11 b'`
confines it to `{10, 11, 12}` — and `12` is the only multiple of `6` there. Unsatisfiable. At the
widened bound `4 + 6 + 15 + 4 + 5 = 34` the pair `(20, 11)`, `(19, 12)` is admissible, which is
why the positive counterpart is one lemma application and not a `decide`: `34^4` is infeasible
where `19^4` is merely expensive. -/

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 4000000 in
theorem witnessB_count : Count true true 20 11 19 := by decide

theorem witnessB_drift : Drift 11 12 := by decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 4000000 in
theorem witnessB_not_RKPre :
    ¬ RKPre 4 6 5 2 true true (kappa 4 6 5 2 (20, 11)) (kappa 4 6 5 2 (19, 12)) := by decide

/-- The positive counterpart at the library's WIDENED `RK`, by one application of
`rk_of_count_drift`. -/
theorem witnessB_RK :
    RK 4 6 5 2 true true (kappa 4 6 5 2 (20, 11)) (kappa 4 6 5 2 (19, 12)) :=
  rk_of_count_drift 4 6 5 2 true true 20 11 19 12 witnessB_count witnessB_drift

/-! ### Witness C — THE `P = 0` HALF: the saturated-gap direction, with no residue at all

`(Tc, Tn, P, B) = (0, 0, 0, 3)`, narrower bound `0 + 0 + 0 + 3 + 2 = 5`, frozen range
`{0, …, 4}`. **At `P = 0` the modulus is `P + 1 = 1`, so BOTH residue coordinates are trivial and
both clipped coordinates are pinned at `0`** — every one of `kappa`'s five coordinates except the
gap is constant. This witness therefore locates the defect in the gap window alone, and a reader
cannot conclude from the other two witnesses that the narrower bound failed only on residues.

The step is `Count false false 5 2 0` with `Drift 2 3`. The pre-step class needs the gap
saturated downward (`clipIdx 3 5 2 = 0`, so first ≥ second + 3) and the post-step class needs it
saturated UPWARD at a first coordinate pinned to `0` (`clipIdx 3 0 3 = 6`, so second ≥ 3). Inside
`{0, …, 4}` the pre-step pairs are `(3, 0)`, `(4, 0)` and `(4, 1)`, and `Drift b b'` from
`b ∈ {0, 1}` cannot reach `3`. The window the two saturations together demand is `B + 2` wide —
`B` for the gap and `2` more for the drift between the pre-step and post-step readings — and the
narrower bound pays only `B`. -/

set_option maxRecDepth 400000 in
theorem witnessC_count : Count false false 5 2 0 := by decide

theorem witnessC_drift : Drift 2 3 := by decide

set_option maxRecDepth 400000 in
theorem witnessC_not_RKPre :
    ¬ RKPre 0 0 0 3 false false (kappa 0 0 0 3 (5, 2)) (kappa 0 0 0 3 (0, 3)) := by decide

/-- The positive counterpart at the library's WIDENED `RK`, by one application of
`rk_of_count_drift`. At `(0, 0, 0, 3)` the widened bound is `0 + 0 + 0 + 6 + 5 = 11`. -/
theorem witnessC_RK :
    RK 0 0 0 3 false false (kappa 0 0 0 3 (5, 2)) (kappa 0 0 0 3 (0, 3)) :=
  rk_of_count_drift 0 0 0 3 false false 5 2 0 3 witnessC_count witnessC_drift

/-! ### Non-vacuity on both sides, per tuple

Each tuple carries BOTH its refutation at the frozen bound AND its positive statement at the
widened library definition, so neither side is vacuous and the widening is neither more nor less
than what the refutation asks for. -/

theorem both_sides_A :
    ¬ RKPre 1 2 2 2 false false (kappa 1 2 2 2 (9, 5)) (kappa 1 2 2 2 (0, 4)) ∧
      RK 1 2 2 2 false false (kappa 1 2 2 2 (9, 5)) (kappa 1 2 2 2 (0, 4)) :=
  ⟨witnessA_not_RKPre, witnessA_RK⟩

theorem both_sides_B :
    ¬ RKPre 4 6 5 2 true true (kappa 4 6 5 2 (20, 11)) (kappa 4 6 5 2 (19, 12)) ∧
      RK 4 6 5 2 true true (kappa 4 6 5 2 (20, 11)) (kappa 4 6 5 2 (19, 12)) :=
  ⟨witnessB_not_RKPre, witnessB_RK⟩

theorem both_sides_C :
    ¬ RKPre 0 0 0 3 false false (kappa 0 0 0 3 (5, 2)) (kappa 0 0 0 3 (0, 3)) ∧
      RK 0 0 0 3 false false (kappa 0 0 0 3 (5, 2)) (kappa 0 0 0 3 (0, 3)) :=
  ⟨witnessC_not_RKPre, witnessC_RK⟩

end Probe761W
