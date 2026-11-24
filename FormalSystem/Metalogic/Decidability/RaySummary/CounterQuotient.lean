/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Certificate
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

/-!
# The counter quotient `K`, its parameters, the parameter conditions, and the maximum
certified subset

This module lands the `K`-indexed half of the ladder's certificate layer: the finite counter
quotient `CK` of the forced five-coordinate shape, its four parameters as OUTPUTS of the
periodicity fixpoint, the parameter-conditions predicate `ParamsOk` with its discharge lemma at
those outputs, the `K`-indexed certificate conditions with `certStabK` rebuilt per `(q, κ)`, and
`Dmax`, the maximum `certAdmK`-certified subset.

## `K` is a CARRIER COORDINATE, never an index

`CK` does NOT factor `cellAt` on its own: that is exactly the claim the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` refutes (`cell_ne`,
`exhibited_form_refuted`, `exists_form_refuted`), and nothing here states it. The set-valued
per-state datum `Dmax` is what the realization statement is a fibre equation OVER; `CK` is one
coordinate of the carrier that datum lives on. No tuple is stated as an index at any parameters
anywhere in this module, and no declaration here has the shape
`index x = index y → cellAt x = cellAt y`.

## Why the parameters are CONSTRAINED and not freely quantified

The fourteenth wired probe
`specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`
(`Probe761R`) proves that an UNCONSTRAINED universal quantification over `(Tc Tn P B : ℕ)`
makes the factorization lemma and the fibre equation FALSE: at `Tc = Tn = P = B = 0` the quotient
`CK 0 0 0 0` is a subsingleton (`ck_zero_subsingleton`, by `decide`; inhabited by `ckZero`), so
the class map identifies every counter pair whatever it is, and both statements then assert the
ladder cell is constant in `(c, n)` — which `cell_succ_ne` refutes for every `c` and `n` at fixed
next deadline, on the four-state tag object, non-vacuity witnessed on both sides
(`separating_pair_nonvacuous`) and using no property of the certified subset. `ParamsOk` below is
the repair: the two factorization-side statements carry it as a hypothesis. The probe stays wired
and unchanged — it is the compiled reason the hypothesis exists, and a reader who removes it
re-breaks both statements. `not_paramsOk_allZero` is the companion fact that the predicate is
load-bearing: it FAILS at the tuple the refutation turns on, on that probe's own object.

## The parameter sources (K1)-(K4)

* **(K1)** `P`: a common multiple of the cycle lengths of the certificate graph restricted to
  saturated classes (`paramsOkK1`). The modulus convention is `LadderModel.lean`'s: both residue
  coordinates are taken modulo `P + 1`, so (K1) is a divisibility condition into `P + 1` and
  never into `P`. The set-level periodicity form is `prodPreN_eventually_periodic` of the wired
  probe `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean`, ported below
  as `prodPre_periodic`, and the period it yields is the third divisor (K1) requires. The
  object-side divisor is the necessary condition `LadderModel.lean`'s own modulus paragraph
  records: `reach_period_refuted`'s hypothesis is a DIVISIBILITY one, so the modulus must be a
  multiple of the period of every letter-definable sub-object, and this is also the conjunct the
  all-zero exclusion turns on (the refutation probe's object has a pending cycle of length `2`,
  which does not divide `0 + 1`).
* **(K2)** `T_c`: at least the cascade bound — the largest region countdown a rigid (all-exact)
  past can force, exponential in the number of pinned regions by `iter_doubling`
  (`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`) — and at least the semantic
  periodicity threshold (`satThreshold`, the fixpoint's own threshold), and at least the
  DEPTH-STRATIFIED MARGIN `b · (P + 1) · (D + 1)` for `b` the type-pigeonhole budget and `D` the
  `⊡`-nesting depth of the closure. `T_c` may NOT come from the formula alone:
  `short_idle_threshold_refuted` is the compiled refutation of that. The margin conjunct is the
  one place (K2) reads `P`: it buys the room a spaced type pigeonhole needs at spacing `P + 1`
  (`budget_mul_spacing_le_Tc`, exactly `exists_typeBlock_of_spacing`'s single room hypothesis at
  that spacing), one such room per `⊡`-depth level (`margin_room_at_depth`). It is a
  STRENGTHENING of the conditions, discharged at `Tcof`'s own new `max` arm by `paramsOk_params`
  and paid for at `paramsOk_inflate`, which now takes the inflated room as a hypothesis rather
  than deriving it; `paramsOk_inflate_raise` keeps the inflation capability unconditional by
  raising `T_c` and `T_n` with `P`.
* **(K3)** Ordering: `T_n + 1 ≥ T_c + 2ℓ₀` for `ℓ₀` the longest shortest path between saturated
  classes, and `T_c ≥ 2 T_short + T_idle + 2`.
* **(K4)** `B`: at least `2 d_back + 1` for the formula's backward exactness depth `dBack`, at
  least `2 d_fwd + 1` for its forward exactness depth `dFwd`, and at least `2` (gate 1,
  `gate1_cell_ne`). The forward conjunct is forced by the wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`: the cell reads
  the next-deadline register forward through the next region's pin, and a `U`-only formula of
  bounded `X`-depth pins that register below any gap clip that `dBack` alone would admit, so the
  gap clip must dominate what a closure formula can pin forward as well as backward.

Each of the four parameter outputs `Tcof`, `Tnof`, `Pof`, `Bof` is a function of `step`, `pend`,
`lab` and `phi` — never an exhibited constant of the object or of the letters, which mechanisms
(4), (5) and (6) of the presentation-decision record each refuted — and `paramsOk_params` proves
the predicate AT those outputs, so the hypothesis the two factorization-side statements carry is
dischargeable and they are not vacuous.

Where a source quantity is taken as an OVER-ESTIMATE dominating the quantity it names (`ell0`,
`tShort`, `tIdle`, `cascadeBound`), the conjunct it enters is a LOWER bound on a parameter, so
the over-estimate strengthens the condition and never weakens it; each such definition says so
in its own docstring.

## What this module does NOT hold

* **No ladder consequence.** Nothing here relates `CK`, `kappa`, `relK`, `certAdmK` or `Dmax` to
  `Rlad`, `RladAdm`, `ladderModel`, `tpOf` or `cellAt`. In particular the counter-lift lemma —
  that the class map is faithful to the counter step relation — is NOT proved here and is not
  assumed: `RK` below is an image relation with a decidable bounded-representative definition,
  and no theorem says every counter step is an `RK` edge. That is obligations (2) and (3) of the
  gated counter-lift lemma, whose gate table is the licence and the limit
  (`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`:
  SEPARATION at gates 1, 2 and 9's n-side half, COLLISION at both decision gates,
  `no_positionwise_lift` refuting the positionwise statement shape for EVERY finite quotient).
* **`Dmax` is the maximum in the ⊆-upper-bound sense**, and that is what is proved:
  `dmax_maximal` says every `certAdmK`-certified set lies inside `Dmax`. Four of the six
  conditions — the two local ones and the two discharge ones — are preserved by the union and
  therefore hold OF `Dmax` (`dmax_certLocK`, `dmax_certBiInfK`, `dmax_certFwdK`,
  `dmax_certBwdK`). The remaining two, `certStabK` and `certBoxK`, are EQUALITIES between a
  letter's bit and a fibre of the candidate set, so they are not preserved by enlarging it, and
  no theorem here claims `Dmax` itself satisfies them. That `Dmax` is itself certified is Finding
  3 of the presentation-decision record — the realizable set is certified GIVEN constancy of
  `cellAt` on `K`-classes — and it is not discharged in this module. The acceptance clause is
  never dropped from `certAdmK`: it is stated and it is the part whose union-stability is open.
* **No decision procedure and no bound.** Nothing here decides generalized-Büchi nonemptiness
  (Route A stays closed). Every quantity named is a COUNT: `modulusOf` is a least common
  multiple of cycle lengths times a period, `cascadeBound` is the `iter_doubling` recurrence
  iterated over a count of pinned regions, and the enumeration `Dmax` ranges over is a count of
  candidates. No upper bound, no complexity claim, and no device-discrimination claim is made.
* The `K`-free `certStab`, `certAdm` and the rest of `Certificate.lean` are untouched; the
  `K`-indexed conditions below are separate objects over a different carrier and carry their own
  names. `AnchorLayer.lean`, `Realize.lean`, `Trace.lean`, `ladderFrame` and `presented_modelOf`
  are untouched and nothing here re-proves them.

## Implementation note on the `K`-indexed conditions

`Certificate.lean`'s six promoted conditions are typed at the `K`-free carrier `ProdState Q φ`
and over a `Finset`; the carrier this module's statements are pinned at is
`Q × ClType φ × CK Tc Tn P B` and the pinned argument is a `Set`. The six conditions are
therefore RESTATED here field for field at that carrier, with the same content and with
`certStabK` rebuilt per `(q, κ)` (F2(a), `cell_ne`: the `K`-free fibre over `q` is the wrong
granularity for the ladder, because `stab_mem_tpOf_iff` is per cell). The two discharge
conditions are written in the existential guarded-path form, which is the promoted
`euLfp` form's own unfolding — `eu_mem_lfp_iff_exists_path` is the landed equivalence between
them, and that lemma's right-hand side is the shape reproduced below.
-/

-- The file crosses the package-wide `longFile` limit (`lakefile.toml`, 1500).  The module is NOT
-- split: the counter quotient, the four parameter sources `(K1)`-`(K4)` and their four outputs
-- are one definition layer, and every parameter condition is read against `kappa`'s own five
-- coordinates in this file.  The baseline is raised in place, one chunk at a time, and the linter
-- checks it stays tight.
set_option linter.style.longFile 1600

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-! ## The counter quotient of the forced five-coordinate shape

Each coordinate is forced by a compiled mechanism, as Finding 2 of the presentation-decision
record records: the two clipped coordinates by the gates that read a countdown or a next
deadline below a threshold, the two residue coordinates by the gates that read one modulo a
period, and the gap coordinate by gate 1 (`gate1_cell_ne`), which reads `n - c` and needs
`2 ≤ B`. -/

/-- **The counter quotient.** The five coordinates are `min c T_c`, `c` modulo `P + 1`,
`min n T_n`, `n` modulo `P + 1`, and the gap `n - c` clipped to `[-B, B]` and shifted into
`[0, 2B]`. Written out, because the shape is part of the contract. This is a CARRIER
COORDINATE: `CK` does not factor `cellAt` on its own — that claim is refuted
(`ladder-cell-refutation.lean`) — and the object that does the factoring in the fibre equation
is the set-valued datum `Dmax`. -/
abbrev CK (Tc Tn P B : ℕ) : Type :=
  Fin (Tc + 1) × Fin (P + 1) × Fin (Tn + 1) × Fin (P + 1) × Fin (2 * B + 1)

/-- The gap coordinate's value: `n - c` clipped to `[-B, B]`, shifted by `B` into `[0, 2B]`. -/
def clipIdx (B c n : ℕ) : ℕ :=
  if c ≤ n then B + min (n - c) B else B - min (c - n) B

theorem clipIdx_lt (B c n : ℕ) : clipIdx B c n < 2 * B + 1 := by
  unfold clipIdx; split <;> omega

/-- **The class map.** The counter pair's class in the quotient. The residue coordinates are
taken modulo `P + 1`, which is `LadderModel.lean`'s modulus convention — `P` is a modulus minus
one, so (K1) below is a divisibility condition into `P + 1`. -/
def kappa (Tc Tn P B : ℕ) : ℕ × ℕ → CK Tc Tn P B := fun x =>
  (⟨min x.1 Tc, by omega⟩,
   ⟨x.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
   ⟨min x.2 Tn, by omega⟩,
   ⟨x.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
   ⟨clipIdx B x.1 x.2, clipIdx_lt B x.1 x.2⟩)

/-! ## The class-level step relation `R_K`

`R_K` is the IMAGE of `Count`/`Drift` on classes, taken over a finite set of counter
representatives so that it is decidable by construction. NOTHING below says the image is
faithful — that every counter step of a ladder history is an `R_K` edge at the two classes — and
nothing assumes it: that is the gated counter-lift lemma's own content (obligations (2) and (3)),
and `no_positionwise_lift` has already refuted the positionwise statement shape for every finite
quotient. -/

instance decidableCount (px py : Bool) (c n c' : ℕ) : Decidable (Count px py c n c') := by
  unfold Count; infer_instance

instance decidableDrift (n n' : ℕ) : Decidable (Drift n n') := by
  unfold Drift; infer_instance

/-- The counter representatives the image is taken over: a COUNT of candidate pairs, bounded by
the parameters themselves, not a bound on anything.

**Why the range is `Tc + Tn + 3*P + 2*B + 5` and not `Tc + Tn + P + B + 2`.** The narrower bound
is REFUTED, and the refutation is compiled rather than argued: the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean` freezes the narrower
bound as its own local `Probe761W.repsCntPre`, derives `Probe761W.RKPre` over it, and exhibits
three `decide`-checked tuples at which an actual `Count`/`Drift` step has NO representative pair
inside that range — `Probe761W.witnessA_not_RKPre`, `Probe761W.witnessB_not_RKPre` and
`Probe761W.witnessC_not_RKPre`, with `Probe761W.witnessA_RK`, `Probe761W.witnessB_RK` and
`Probe761W.witnessC_RK` the positive counterparts at the widened definition below. The failure
runs in two independent directions:

* the **saturated-gap** direction, which needs no residue at all: at `P = 0` the gap coordinate
  `clipIdx B c n` saturates at `±B`, and a representative that keeps the gap saturated on BOTH
  the pre-step and the post-step pair must sit at least `B + 2` above the reduced next deadline,
  which the narrower range's single `+ B` cannot pay for (`Probe761W.witnessC_not_RKPre`, named
  as the `P = 0` half in its own docstring);
* the **residue-coupling** direction: the two counters must be moved by a COMMON multiple of
  `P + 1` whenever the gap is exact, so the reduced pair's first coordinate is pinned to the
  residue class of `c` and may need a further `P + 1` of room above whichever threshold the
  construction clears (`Probe761W.witnessA_not_RKPre`, whose least admissible first coordinate
  is `9`, exactly one above the narrower bound's own value `Tc + Tn + P + B + 2 = 9`).

The widened figure is what `rk_of_count_drift`'s construction below actually discharges: `3*P`
pays for the three independent residue roundings (the `n`-side shift, the gap-saturated `a`-side
rounding, and the `a - 1` reading of it), `2*B` for the gap window read on both the pre-step and
the post-step pair, and the `+5` for the margins the `Count` arms consume. Widening does not
change what kind of object this is: it is still a COUNT of candidate pairs. -/
def repsCnt (Tc Tn P B : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (Tc + Tn + 3 * P + 2 * B + 5)) ×ˢ (Finset.range (Tc + Tn + 3 * P + 2 * B + 5))

/-- The inner half of `R_K`: the representatives `y` one step on from a fixed `x`. Split from
`RKb` because the two bounded existentials nested in one term exceed instance resolution's
depth; the two halves together are the one bounded existential `rk_iff` states. -/
def rkStepB (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) (x : ℕ × ℕ) : Bool :=
  decide (∃ y ∈ repsCnt Tc Tn P B, Count px py x.1 x.2 y.1 ∧ Drift x.2 y.2 ∧
    kappa Tc Tn P B x = k ∧ kappa Tc Tn P B y = k')

/-- `R_K` as a `Bool`: a bounded existential over the representatives, hence decidable by
construction. -/
def RKb (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) : Bool :=
  decide (∃ x ∈ repsCnt Tc Tn P B, rkStepB Tc Tn P B px py k k' x = true)

/-- **`R_K`**, the image of `Count`/`Drift` on classes. -/
def RK (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) : Prop :=
  RKb Tc Tn P B px py k k' = true

instance decidableRK (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) :
    Decidable (RK Tc Tn P B px py k k') :=
  inferInstanceAs (Decidable (RKb Tc Tn P B px py k k' = true))

theorem rkStepB_iff (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) (x : ℕ × ℕ) :
    rkStepB Tc Tn P B px py k k' x = true ↔
      ∃ y ∈ repsCnt Tc Tn P B, Count px py x.1 x.2 y.1 ∧ Drift x.2 y.2 ∧
        kappa Tc Tn P B x = k ∧ kappa Tc Tn P B y = k' := by
  unfold rkStepB
  rw [decide_eq_true_eq]

theorem rk_iff (Tc Tn P B : ℕ) (px py : Bool) (k k' : CK Tc Tn P B) :
    RK Tc Tn P B px py k k' ↔
      ∃ x ∈ repsCnt Tc Tn P B, ∃ y ∈ repsCnt Tc Tn P B,
        Count px py x.1 x.2 y.1 ∧ Drift x.2 y.2 ∧
          kappa Tc Tn P B x = k ∧ kappa Tc Tn P B y = k' := by
  unfold RK RKb
  rw [decide_eq_true_eq]
  constructor
  · rintro ⟨x, hx, h⟩
    exact ⟨x, hx, (rkStepB_iff Tc Tn P B px py k k' x).mp h⟩
  · rintro ⟨x, hx, h⟩
    exact ⟨x, hx, (rkStepB_iff Tc Tn P B px py k k' x).mpr h⟩

/-! ### The bounded-representative lemma

`rk_of_count_drift` is the one fact `RK`'s definition does not give for free: every actual
`Count`/`Drift` step at arbitrary counters IS an `RK` edge at the two classes. It is proved by
exhibiting a representative pair inside `repsCnt`, in the three stages the helpers below carry —
one common downward shift on the next-deadline side, one residue-respecting choice on the
current-deadline side by gap regime, and the post-step coordinate read off the `Count` arm. This
is NOT the counter-lift lemma and does not become it: nothing here relates `kappa`, `relK` or
`RK` to `Rlad`, `RladAdm`, `ladderModel`, `tpOf` or `cellAt`, and the positionwise statement
shape stays refuted (`no_positionwise_lift`). -/

/-- A class equality read off its five coordinates — the CONSTRUCTOR direction, the converse of
`LadderAgree.lean`'s `kappa_eq_components`, which is the destructor. It is stated here rather
than cited from there because that module imports this one. -/
theorem kappa_eq_of_components (Tc Tn P B c n c' n' : ℕ)
    (h1 : min c Tc = min c' Tc) (h2 : c % (P + 1) = c' % (P + 1))
    (h3 : min n Tn = min n' Tn) (h4 : n % (P + 1) = n' % (P + 1))
    (h5 : clipIdx B c n = clipIdx B c' n') :
    kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') := by
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq]
  exact ⟨h1, h2, h3, h4, h5⟩

/-- **A COMMON downward shift leaves the gap coordinate alone.** The gap reads a difference, so
shifting both counters by the same amount — exactly, without truncation — moves neither the
order nor the distance. This is the mechanism the exact-gap regime of `rk_of_count_drift` runs
on, and the reason the two counters may NOT be reduced independently. -/
theorem clipIdx_sub_sub (B c n m : ℕ) (hc : m ≤ c) (hn : m ≤ n) :
    clipIdx B (c - m) (n - m) = clipIdx B c n := by
  unfold clipIdx; split <;> split <;> omega

/-- The gap coordinate saturated upward: at a next deadline at least `B` above the countdown,
the gap reads `2 * B` whatever the two values are. -/
theorem clipIdx_of_add_le (B c n : ℕ) (h : c + B ≤ n) : clipIdx B c n = 2 * B := by
  unfold clipIdx; split <;> omega

/-- The gap coordinate saturated downward: at a countdown at least `B` above the next deadline,
the gap reads `0` whatever the two values are. -/
theorem clipIdx_of_le_sub (B c n : ℕ) (h : n + B ≤ c) : clipIdx B c n = 0 := by
  unfold clipIdx; split <;> omega

/-- Subtracting a multiple of the modulus leaves the residue coordinate alone. -/
theorem mod_sub_cancel (c k P : ℕ) (hdvd : (P + 1) ∣ k) (h : k ≤ c) :
    (c - k) % (P + 1) = c % (P + 1) :=
  (Nat.modEq_iff_dvd' (by omega : c - k ≤ c)).mpr (by rwa [Nat.sub_sub_self h])

/-- Rounding a summand to its residue leaves the sum's residue alone — the fact the
gap-saturated regime's residue-respecting choice of representative turns on. -/
theorem add_mod_mod_cancel (t x P : ℕ) :
    (t + x % (P + 1)) % (P + 1) = (t + x) % (P + 1) := by
  simp [Nat.add_mod]

/-- Membership in `repsCnt`, read off the two range bounds. -/
theorem mem_repsCnt (Tc Tn P B u v : ℕ) (hu : u < Tc + Tn + 3 * P + 2 * B + 5)
    (hv : v < Tc + Tn + 3 * P + 2 * B + 5) : (u, v) ∈ repsCnt Tc Tn P B := by
  unfold repsCnt
  exact Finset.mem_product.mpr ⟨Finset.mem_range.mpr hu, Finset.mem_range.mpr hv⟩

/-- **Stage one of the construction: the `n`-side common downward shift.** For a drifting pair
of next deadlines, one multiple `k` of the modulus brings BOTH members down to within `P + 1` of
the threshold `Θ` while keeping them at or above it — or leaves them alone when they already lie
below it. The shift is COMMON to the two members, so the drift survives it. -/
theorem exists_nShift (Θ P n n' : ℕ) (hd : Drift n n') :
    ∃ k : ℕ, (P + 1) ∣ k ∧ k ≤ n ∧ k ≤ n' ∧
      (k = 0 ∨ (Θ ≤ n - k ∧ Θ ≤ n' - k)) ∧
      n - k ≤ Θ + (P + 1) ∧ n' - k ≤ Θ + (P + 1) := by
  unfold Drift at hd
  by_cases hm : min n n' ≤ Θ
  · exact ⟨0, dvd_zero _, by omega, by omega, Or.inl rfl, by omega, by omega⟩
  · refine ⟨(P + 1) * ((min n n' - Θ) / (P + 1)), dvd_mul_right _ _, ?_, ?_, ?_, ?_, ?_⟩ <;>
    · have hdm := Nat.div_add_mod (min n n' - Θ) (P + 1)
      have hmd : (min n n' - Θ) % (P + 1) < P + 1 := Nat.mod_lt _ (Nat.succ_pos P)
      omega

/-- **Stage two of the construction: the `a`-side choice, by gap regime.** Given the `n`-side
shift `k` of `exists_nShift` at the threshold `Tc + Tn + B + (P + 1)`, a bounded first
coordinate `a` carries `c`'s class at the shifted next deadline — and, when `c` is positive,
carries `c - 1`'s class at the shifted drifted next deadline too, which is what the
pending-to-pending `Count` arm reads. Three regimes, and they are what the widened bound pays
for:

* `n + B + 2 ≤ c` — the gap is saturated DOWNWARD with margin, on the pre-step and the post-step
  pair alike, so `a` is free of the difference and is taken as the least member of `c`'s residue
  class at or above `max (Tc + 1) ((n - k) + B + 2)`. This is the regime that drives the bound;
* `c + B ≤ n` — the gap is saturated UPWARD, so `a` is the least member of `c`'s residue class at
  or above `Tc + 1` (or `c` itself when `c ≤ Tc`, where the clipped coordinate is an exact
  reading and admits no other representative);
* otherwise the gap is EXACT and the difference is pinned, so the only admissible choice is the
  same common shift the `n`-side took: `a = c - k`.

The `Tc + 1` floor rather than `Tc` is forced by the post-step reading: the pending-to-pending
arm sets the post-step first coordinate to `a - 1`, which must still sit at or above `Tc` for the
clipped countdown coordinate to agree. -/
theorem exists_aRep (Tc Tn P B c n n' k : ℕ)
    (hd : Drift n n') (hdvd : (P + 1) ∣ k)
    (hkn : k ≤ n) (hkn' : k ≤ n')
    (hbig : k = 0 ∨ (Tc + Tn + B + (P + 1) ≤ n - k ∧ Tc + Tn + B + (P + 1) ≤ n' - k))
    (hle : n - k ≤ Tc + Tn + B + 2 * (P + 1)) :
    ∃ a : ℕ, a < Tc + Tn + 3 * P + 2 * B + 5 ∧
      min a Tc = min c Tc ∧ a % (P + 1) = c % (P + 1) ∧
      clipIdx B a (n - k) = clipIdx B c n ∧
      (c = 0 → a = 0) ∧
      (1 ≤ c → 1 ≤ a ∧ min (a - 1) Tc = min (c - 1) Tc ∧
        (a - 1) % (P + 1) = (c - 1) % (P + 1) ∧
        clipIdx B (a - 1) (n' - k) = clipIdx B (c - 1) n') := by
  unfold Drift at hd
  rcases lt_or_ge (n + B + 1) c with halpha | hnotalpha
  · by_cases hcT : c ≤ max (Tc + 1) ((n - k) + B + 2)
    · refine ⟨c, by omega, rfl, rfl, ?_, fun h => h, fun _ => ⟨by omega, rfl, rfl, ?_⟩⟩
      · rw [clipIdx_of_le_sub B c (n - k) (by omega), clipIdx_of_le_sub B c n (by omega)]
      · rw [clipIdx_of_le_sub B (c - 1) (n' - k) (by omega),
            clipIdx_of_le_sub B (c - 1) n' (by omega)]
    · have hT1 : Tc + 1 ≤ max (Tc + 1) ((n - k) + B + 2) := le_max_left _ _
      have hT2 : (n - k) + B + 2 ≤ max (Tc + 1) ((n - k) + B + 2) := le_max_right _ _
      have hr : (c - max (Tc + 1) ((n - k) + B + 2)) % (P + 1) < P + 1 :=
        Nat.mod_lt _ (Nat.succ_pos P)
      have hrle : (c - max (Tc + 1) ((n - k) + B + 2)) % (P + 1)
          ≤ c - max (Tc + 1) ((n - k) + B + 2) := Nat.mod_le _ _
      refine ⟨max (Tc + 1) ((n - k) + B + 2)
          + (c - max (Tc + 1) ((n - k) + B + 2)) % (P + 1),
        by omega, by omega, ?_, ?_, fun h => by omega, fun _ => ⟨by omega, by omega, ?_, ?_⟩⟩
      · rw [add_mod_mod_cancel]; congr 1; omega
      · rw [clipIdx_of_le_sub B _ (n - k) (by omega), clipIdx_of_le_sub B c n (by omega)]
      · rw [show max (Tc + 1) ((n - k) + B + 2)
              + (c - max (Tc + 1) ((n - k) + B + 2)) % (P + 1) - 1
            = (max (Tc + 1) ((n - k) + B + 2) - 1)
              + (c - max (Tc + 1) ((n - k) + B + 2)) % (P + 1) from by omega,
          add_mod_mod_cancel]
        congr 1; omega
      · rw [clipIdx_of_le_sub B _ (n' - k) (by omega),
            clipIdx_of_le_sub B (c - 1) n' (by omega)]
  · rcases le_or_gt (c + B) n with hbeta | hgamma
    · by_cases hcT : c ≤ Tc
      · refine ⟨c, by omega, rfl, rfl, ?_, fun h => h, fun _ => ⟨by omega, rfl, rfl, ?_⟩⟩
        · rw [clipIdx_of_add_le B c (n - k) (by omega), clipIdx_of_add_le B c n (by omega)]
        · rw [clipIdx_of_add_le B (c - 1) (n' - k) (by omega),
              clipIdx_of_add_le B (c - 1) n' (by omega)]
      · have hr : (c - (Tc + 1)) % (P + 1) < P + 1 := Nat.mod_lt _ (Nat.succ_pos P)
        have hrle : (c - (Tc + 1)) % (P + 1) ≤ c - (Tc + 1) := Nat.mod_le _ _
        refine ⟨(Tc + 1) + (c - (Tc + 1)) % (P + 1),
          by omega, by omega, ?_, ?_, fun h => by omega, fun _ => ⟨by omega, by omega, ?_, ?_⟩⟩
        · rw [add_mod_mod_cancel]; congr 1; omega
        · rw [clipIdx_of_add_le B _ (n - k) (by omega), clipIdx_of_add_le B c n (by omega)]
        · rw [show (Tc + 1) + (c - (Tc + 1)) % (P + 1) - 1
              = Tc + (c - (Tc + 1)) % (P + 1) from by omega, add_mod_mod_cancel]
          congr 1; omega
        · rw [clipIdx_of_add_le B _ (n' - k) (by omega),
              clipIdx_of_add_le B (c - 1) n' (by omega)]
    · have hkc : k ≤ c := by omega
      refine ⟨c - k, by omega, by omega, mod_sub_cancel c k P hdvd hkc,
        clipIdx_sub_sub B c n k hkc hkn, fun h => by omega,
        fun _ => ⟨by omega, by omega, ?_, ?_⟩⟩
      · rw [show c - k - 1 = (c - 1) - k from by omega]
        exact mod_sub_cancel (c - 1) k P hdvd (by omega)
      · rw [show c - k - 1 = (c - 1) - k from by omega]
        exact clipIdx_sub_sub B (c - 1) n' k (by omega) hkn'

set_option maxHeartbeats 400000 in
-- The proof runs the four `Count` arms over `exists_aRep`'s three gap regimes, and every arm
-- closes five coordinate equations by `omega` against a context carrying the shift's own
-- disjunction; the default budget runs out partway through the second arm.
/-- **THE BOUNDED-REPRESENTATIVE LEMMA.** Every actual `Count`/`Drift` step at arbitrary
counters is an `RK` edge at the two classes. The two stages above supply the representative pair,
and the third stage is the `Count` arm itself: a non-pending successor sets the post-step
countdown to `0` (and the pre-step one too, when the predecessor was pending), a
pending-to-pending step sets it to `a - 1`, and a pending successor of an idle position hands it
the reduced next deadline.

**`ParamsOk` is NOT a hypothesis here, and must not be added.** It cannot close any gap this
statement has, because it does not bound `P` from above: `(K1)` (`paramsOkK1`) is a DIVISIBILITY
condition into `P + 1`; `(K3)` (`paramsOkK3`) does not mention `P` at all; and `(K2)`
(`paramsOkK2`) mentions `P` only through its margin conjunct
`b · (P + 1) · (D + 1) ≤ Tc`, which is a lower bound on `Tc` AT a given `P` and so bounds `P`
from above only once `Tc` is itself held fixed — which this statement, quantifying `Tc` freely,
does not do. So `ParamsOk` constrains `P` from below only here — while the refutation of the
narrower
`repsCnt` bound runs in the direction of LARGER `P` (and, at `Probe761W.witnessC_not_RKPre`,
at `P = 0`, where `ParamsOk`'s own `not_paramsOk_allZero` already fails for an unrelated reason).
Adding a parameter, size or regime hypothesis would weaken the statement without buying anything;
the construction above needs none. -/
theorem rk_of_count_drift (Tc Tn P B : ℕ) (px py : Bool) (c n c' n' : ℕ)
    (hc : Count px py c n c') (hd : Drift n n') :
    RK Tc Tn P B px py (kappa Tc Tn P B (c, n)) (kappa Tc Tn P B (c', n')) := by
  rw [rk_iff]
  obtain ⟨k, hdvd, hkn, hkn', hbig, hlen, hlen'⟩ :=
    exists_nShift (Tc + Tn + B + (P + 1)) P n n' hd
  have hdU : n' = n ∨ n' = n + 1 ∨ n' + 1 = n := hd
  have hbTn : min (n - k) Tn = min n Tn := by omega
  have hb'Tn : min (n' - k) Tn = min n' Tn := by omega
  have hbTc : min (n - k) Tc = min n Tc := by omega
  obtain ⟨a, ha_lt, ha_min, ha_mod, ha_clip, ha_zero, ha_pred⟩ :=
    exists_aRep Tc Tn P B c n n' k hd hdvd hkn hkn' hbig (by omega)
  have hbmod : (n - k) % (P + 1) = n % (P + 1) := mod_sub_cancel n k P hdvd hkn
  have hb'mod : (n' - k) % (P + 1) = n' % (P + 1) := mod_sub_cancel n' k P hdvd hkn'
  have hbclip : clipIdx B (n - k) (n' - k) = clipIdx B n n' :=
    clipIdx_sub_sub B n n' k hkn hkn'
  have hbB : clipIdx B 0 (n' - k) = clipIdx B 0 n' := by
    rcases hbig with h | h
    · rw [h]; simp
    · rw [clipIdx_of_add_le B 0 (n' - k) (by omega), clipIdx_of_add_le B 0 n' (by omega)]
  have hbkappa : kappa Tc Tn P B (n - k, n' - k) = kappa Tc Tn P B (n, n') :=
    kappa_eq_of_components _ _ _ _ _ _ _ _ hbTc hbmod hb'Tn hb'mod hbclip
  have hakappa : kappa Tc Tn P B (a, n - k) = kappa Tc Tn P B (c, n) :=
    kappa_eq_of_components _ _ _ _ _ _ _ _ ha_min ha_mod hbTn hbmod ha_clip
  have hbltM : n - k < Tc + Tn + 3 * P + 2 * B + 5 := by omega
  have hb'ltM : n' - k < Tc + Tn + 3 * P + 2 * B + 5 := by omega
  have hdrift : Drift (n - k) (n' - k) := by unfold Drift; omega
  cases py with
  | false =>
    have hc0 : c' = 0 ∧ (px = true → c = 0) := by simpa [Count] using hc
    refine ⟨(a, n - k), mem_repsCnt _ _ _ _ _ _ ha_lt hbltM,
      (0, n' - k), mem_repsCnt _ _ _ _ _ _ (by omega) hb'ltM, ?_, hdrift, hakappa, ?_⟩
    · simp only [Count, Bool.false_eq_true, if_false]
      exact ⟨trivial, fun hpx => ha_zero (hc0.2 hpx)⟩
    · rw [hc0.1]
      exact kappa_eq_of_components _ _ _ _ _ _ _ _ rfl rfl hb'Tn hb'mod hbB
  | true =>
    cases px with
    | true =>
      have hcc : c' + 1 = c := by simpa [Count] using hc
      obtain ⟨ha1, hamin1, hamod1, haclip1⟩ := ha_pred (by omega)
      refine ⟨(a, n - k), mem_repsCnt _ _ _ _ _ _ ha_lt hbltM,
        (a - 1, n' - k), mem_repsCnt _ _ _ _ _ _ (by omega) hb'ltM, ?_, hdrift, hakappa, ?_⟩
      · simp only [Count, if_true]; omega
      · rw [show c' = c - 1 from by omega]
        exact kappa_eq_of_components _ _ _ _ _ _ _ _ hamin1 hamod1 hb'Tn hb'mod haclip1
    | false =>
      have hcc : c' = n := by simpa [Count] using hc
      refine ⟨(a, n - k), mem_repsCnt _ _ _ _ _ _ ha_lt hbltM,
        (n - k, n' - k), mem_repsCnt _ _ _ _ _ _ hbltM hb'ltM, ?_, hdrift, hakappa, ?_⟩
      · simp only [Count, if_true, Bool.false_eq_true, if_false]
      · rw [hcc]; exact hbkappa

/-! ## Saturated classes and the cycle lengths (K1) quantifies -/

/-- A class is **saturated** when it carries an infinite forward certificate walk: it is not a
dead end of the certificate graph. The relation is the IDLE-EXTENDED `cohIdle`, which is Finding
1's relation of record: `coh` and `cohBi` demand `pend` at both endpoints, and no forward `Rlad`
ray is pending forever (`exists_idle_of_rlad_ray`, `no_rlad_ray_of_pending_forever`), so the
certified chains of record are region-interior and composition across idle runs is what the
soundness and completeness obligations buy. -/
def SatCl {Q : Type} (step : Q → Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (x : ProdState Q φ) : Prop :=
  ∃ f : ℕ → ProdState Q φ, f 0 = x ∧ ∀ i, cohIdle step lab φ (f i) (f (i + 1)) = true

/-- **The cycle lengths of the certificate graph restricted to saturated classes** — the set
(K1) quantifies. The length is at most the class count, which is the simple-cycle restriction: a
closed walk longer than that repeats a class. The walk is pending throughout, which is the
region-interior restriction Finding 1 records, and every class on it is saturated. -/
def prodCycleLens {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : Set ℕ :=
  {l | 0 < l ∧ l ≤ Fintype.card (ProdState Q φ) ∧
    ∃ f : ℕ → ProdState Q φ,
      (∀ i, cohIdle step lab φ (f i) (f (i + 1)) = true) ∧
      (∀ i, pend (f i).1 = true) ∧
      (∀ i, SatCl step lab φ (f i)) ∧
      f l = f 0}

/-- **The cycle lengths of the OBJECT's own pending graph.** `LadderModel.lean`'s modulus
paragraph records this as a NECESSARY condition on any index's parameters, and a divisibility one
rather than a magnitude one: `reach_period_refuted`'s hypothesis is `¬ 3 ∣ (P + 1)`, so a large
modulus is refuted all the same. The walk is pending throughout, because a region's forced walk
is. -/
def objCycleLens {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool) : Set ℕ :=
  {l | 0 < l ∧ l ≤ Fintype.card Q ∧
    ∃ f : ℕ → Q, (∀ i, step (f i) (f (i + 1)) = true) ∧ (∀ i, pend (f i) = true) ∧ f l = f 0}

/-- **SERIALITY FORCES A PENDING SUCCESSOR.** Under `fwd` — forward seriality of `RladAdm`, which
every admissible ladder object carries — a pending object state has a `step`-successor that is
again pending. The argument is `Count`'s own idle clause: at the pending state `(q, 1, 0)` the
forward witness `y` satisfies `Count (pend q) (pend y.1) 1 0 y.2.1`, and if `y.1` were idle that
clause reads `y.2.1 = 0 ∧ (pend q = true → 1 = 0)`, whose second conjunct is false.

**The consequence this records is negative**, and it is the reason the refutation side of the
forward-slack question is closed: no admissible object has a bound on its pending-region lengths.
From a single pending state, seriality produces an infinite pending walk, so the regions it
generates can be made arbitrarily long, and a counterexample object whose region lengths are
bounded — which is what a refutation of `ForwardSlackWitnessed` by construction would need — does
not exist. `objCycleLens_nonempty_of_pend` below turns the same walk into a positive cycle length
by pigeonhole, which is the (K1) consequence. -/
theorem pend_succ_of_fwd {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (q : Q) (hq : pend q = true) :
    ∃ q', step q q' = true ∧ pend q' = true := by
  have hadm : (1 : ℕ) ∈ Adm pend q := by
    intro h; rw [hq] at h; exact absurd h (by simp)
  obtain ⟨y, hy⟩ := fwd 0 ⟨(q, 1, 0), hadm⟩
  obtain ⟨hstep, -, -, hcount⟩ := hy
  refine ⟨y.1.1, hstep, ?_⟩
  by_contra hne
  rw [Bool.not_eq_true] at hne
  simp only [Count, hne, Bool.false_eq_true, if_false] at hcount
  exact absurd (hcount.2 hq) (by omega)

/-- **EVERY SERIAL OBJECT WITH A PENDING STATE HAS A PENDING CYCLE**, of length at most
`Fintype.card Q`. Iterating `pend_succ_of_fwd`'s choice on the pending subtype gives an infinite
pending walk; pigeonholing its first `Fintype.card Q + 1` values gives a repetition `f a = f b`
with `a < b ≤ Fintype.card Q`, and re-basing the walk at `a` turns that repetition into a cycle
based at index `0`, which is what `objCycleLens` asks for.

So (K1)'s object-side divisibility clause is never vacuous on a serial object with a pending
state: `objCycleLens step pend` is inhabited, hence `P + 1` is constrained from below by a genuine
divisor. The same fact is the obstruction on the refutation side — see `pend_succ_of_fwd`. -/
theorem objCycleLens_nonempty_of_pend {Q : Type} [Fintype Q] (step : Q → Q → Bool)
    (pend : Q → Bool) (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (q : Q) (hq : pend q = true) :
    ∃ l : ℕ, l ∈ objCycleLens step pend := by
  classical
  -- The pending-successor choice function, on the subtype of pending object states.
  let nxt : {x : Q // pend x = true} → {x : Q // pend x = true} := fun x =>
    ⟨(pend_succ_of_fwd step pend fwd x.1 x.2).choose,
      (pend_succ_of_fwd step pend fwd x.1 x.2).choose_spec.2⟩
  have hnxt : ∀ x : {x : Q // pend x = true}, step x.1 (nxt x).1 = true := fun x =>
    (pend_succ_of_fwd step pend fwd x.1 x.2).choose_spec.1
  let f : ℕ → Q := fun i => (nxt^[i] ⟨q, hq⟩).1
  have hfstep : ∀ i, step (f i) (f (i + 1)) = true := by
    intro i
    have hit : nxt^[i + 1] ⟨q, hq⟩ = nxt (nxt^[i] ⟨q, hq⟩) := Function.iterate_succ_apply' _ _ _
    simp only [f, hit]
    exact hnxt _
  have hfpend : ∀ i, pend (f i) = true := fun i => (nxt^[i] ⟨q, hq⟩).2
  -- Pigeonhole the first `Fintype.card Q + 1` values of the walk.
  have hlt : (Finset.univ : Finset Q).card < (Finset.range (Fintype.card Q + 1)).card := by
    simp
  obtain ⟨i, hi, j, hj, hij, hfe⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hlt
      (fun x _ => Finset.mem_univ (f x))
  obtain ⟨a, b, hab, hbc, hfab⟩ : ∃ a b : ℕ, a < b ∧ b ≤ Fintype.card Q ∧ f a = f b := by
    have hi' : i < Fintype.card Q + 1 := Finset.mem_range.mp hi
    have hj' : j < Fintype.card Q + 1 := Finset.mem_range.mp hj
    rcases lt_or_gt_of_ne hij with h | h
    · exact ⟨i, j, h, by omega, hfe⟩
    · exact ⟨j, i, h, by omega, hfe.symm⟩
  -- Re-base the walk at index `a`, turning the repetition into a cycle based at `0`.
  have hstep' : ∀ k : ℕ, step (f (k + a)) (f (k + 1 + a)) = true := by
    intro k
    rw [show k + 1 + a = k + a + 1 by omega]
    exact hfstep (k + a)
  have hcyc' : f (b - a + a) = f (0 + a) := by
    rw [show b - a + a = b by omega, Nat.zero_add]
    exact hfab.symm
  exact ⟨b - a, by omega, by omega, fun k => f (k + a), hstep',
    fun k => hfpend (k + a), hcyc'⟩

/-! ## The periodicity fixpoint, ported from the wired probe

`iterate_eventually_periodic`, `prodPreStep` and the set-level periodicity statement are ported
from `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean`, which remains the
oracle and keeps its own copies unchanged. The threshold and the period below are the fixpoint's
own OUTPUTS, read off that statement by choice; they are not exhibited constants. -/

/-- **Iteration of an endofunction of a finite type is eventually periodic**, with a threshold
and a genuinely positive period. Ported verbatim. -/
theorem iterate_eventually_periodic {A : Type} [Finite A] (f : A → A) (a : A) :
    ∃ T P : ℕ, 1 ≤ P ∧ ∀ k, T ≤ k → f^[k + P] a = f^[k] a := by
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] a)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨i, j - i, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = i + m := ⟨k - i, by omega⟩
    have hkey : i + m + (j - i) = m + j := by omega
    rw [hkey, Function.iterate_add_apply, ← hfe, ← Function.iterate_add_apply]
    congr 1
    omega
  · refine ⟨j, i - j, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = j + m := ⟨k - j, by omega⟩
    have hkey : j + m + (i - j) = m + i := by omega
    rw [hkey, Function.iterate_add_apply, hfe, ← Function.iterate_add_apply]
    congr 1
    omega

open Classical in
/-- One step of BACKWARD (countdown) reachability in the certificate graph: the classes from
which some member of `S` is reachable in one step. This is the operator the countdown iterates.
Ported from the wired probe; classical in the filter's predicate, hence noncomputable. -/
noncomputable def prodPreStep {Q : Type} [Fintype Q] {φ : PlusFormula}
    (rel : ProdState Q φ → ProdState Q φ → Bool) (S : Finset (ProdState Q φ)) :
    Finset (ProdState Q φ) :=
  Finset.univ.filter (fun x => ∃ y ∈ S, rel x y = true)

/-- **The set-level periodicity form** `prodPreN_eventually_periodic`, at the idle-extended
relation and the full class set. -/
theorem prodPre_periodic {Q : Type} [Fintype Q] (step : Q → Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) :
    ∃ T P : ℕ, 1 ≤ P ∧ ∀ k, T ≤ k →
      (prodPreStep (cohIdle step lab φ))^[k + P] Finset.univ
        = (prodPreStep (cohIdle step lab φ))^[k] Finset.univ :=
  iterate_eventually_periodic _ _

/-- **(K2)'s semantic periodicity threshold**, the fixpoint's own threshold output. -/
noncomputable def satThreshold {Q : Type} [Fintype Q] (step : Q → Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : ℕ :=
  (prodPre_periodic step lab φ).choose

/-- **(K1)'s third divisor**, the fixpoint's own period output. -/
noncomputable def satPeriod {Q : Type} [Fintype Q] (step : Q → Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : ℕ :=
  (prodPre_periodic step lab φ).choose_spec.choose

theorem satPeriod_pos {Q : Type} [Fintype Q] (step : Q → Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) : 1 ≤ satPeriod step lab φ :=
  (prodPre_periodic step lab φ).choose_spec.choose_spec.1

/-! ## The remaining parameter sources -/

/-- **The formula's backward exactness depth** `d_back` of (K4): the nesting depth of the
backward strict-since operator. A syntactic function of the formula. -/
def dBack : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp α β => max (dBack α) (dBack β)
  | .box α => dBack α
  | .untl α β => max (dBack α) (dBack β)
  | .snce α β => max (dBack α) (dBack β) + 1
  | .stab α => dBack α

/-- **The formula's forward exactness depth** `d_fwd` of (K4): the nesting depth of the forward
strict-until operator, the mirror of `dBack`. A syntactic function of the formula. The wired
probe `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` is what
forces (K4) to read it: its separating formula `chiD` has `dBack chiD = 0` and `dFwd chiD = 4`,
and the cell at a ladder state reads the next-deadline register forward by exactly the amount
such a formula pins. -/
def dFwd : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp α β => max (dFwd α) (dFwd β)
  | .box α => dFwd α
  | .untl α β => max (dFwd α) (dFwd β) + 1
  | .snce α β => max (dFwd α) (dFwd β)
  | .stab α => dFwd α

/-! ### The two exactness depths against the subformula closure

`(K4)` reads the two exactness depths and `(K3)` reads the closure's cardinality through
`tShort`, so a consumer that needs a threshold to dominate `dBack + dFwd` needs the two scales
compared. They are, and the comparison is pure syntax: `dBack` counts `snce`-rooted closure
members, `dFwd` counts `untl`-rooted ones, and no member is both. -/

/-- A structural size on `PlusFormula`, used only to rule out a formula's own membership in a
proper subformula's closure. `sizeOf` would serve, but its `atom` arm reads `Atom`'s own size and
the arithmetic below is cleaner with a function whose arms are written here. -/
def plusFsize : PlusFormula → ℕ
  | .atom _ => 1
  | .bot => 1
  | .imp α β => plusFsize α + plusFsize β + 1
  | .box α => plusFsize α + 1
  | .untl α β => plusFsize α + plusFsize β + 1
  | .snce α β => plusFsize α + plusFsize β + 1
  | .stab α => plusFsize α + 1

/-- **Size is monotone along `subformulas`.** The step `FormalSystem/PlusLanguage/Subformulas.lean`
does not carry: it has `self_mem_subformulas`, the eight constructor-membership lemmas and
`subformulas_trans`, but no size or no-self-containment lemma. -/
theorem plusFsize_le_of_mem_subformulas {ψ φ : PlusFormula}
    (h : ψ ∈ PlusFormula.subformulas φ) : plusFsize ψ ≤ plusFsize φ := by
  induction φ with
  | atom p => simp only [PlusFormula.subformulas, List.mem_singleton] at h; subst h; omega
  | bot => simp only [PlusFormula.subformulas, List.mem_singleton] at h; subst h; omega
  | box α ihα | stab α ihα =>
    simp only [PlusFormula.subformulas, List.mem_cons] at h
    rcases h with h | h
    · subst h; omega
    · have := ihα h; simp only [plusFsize]; omega
  | imp α β ihα ihβ =>
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · subst h; omega
    · have := ihα h; simp only [plusFsize]; omega
    · have := ihβ h; simp only [plusFsize]; omega
  | untl α β ihα ihβ | snce α β ihα ihβ =>
    -- `subformulas` lists the SECOND component first in the `untl`/`snce` arms.
    simp only [PlusFormula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · subst h; omega
    · have := ihβ h; simp only [plusFsize]; omega
    · have := ihα h; simp only [plusFsize]; omega

/-- A closure is monotone along the subformula relation, read off `subformulas_trans`. -/
theorem closure_subset_of_mem_subformulas {ψ φ : PlusFormula}
    (h : ψ ∈ PlusFormula.subformulas φ) :
    plusSubformulaClosure ψ ⊆ plusSubformulaClosure φ := fun χ hχ => by
  simp only [plusSubformulaClosure, List.mem_toFinset] at hχ ⊢
  exact PlusFormula.subformulas_trans hχ h

/-- A strictly larger formula is in no proper subformula's closure. -/
theorem not_mem_closure_of_plusFsize_lt {φ α : PlusFormula}
    (h : plusFsize α < plusFsize φ) : φ ∉ plusSubformulaClosure α := fun hmem => by
  simp only [plusSubformulaClosure, List.mem_toFinset] at hmem
  exact absurd (plusFsize_le_of_mem_subformulas hmem) (by omega)

/-- `snce`-rootedness, as a decidable `Bool`: the shape `dBack` counts. -/
def isSnceRoot : PlusFormula → Bool
  | .snce _ _ => true
  | _ => false

/-- `untl`-rootedness, as a decidable `Bool`: the shape `dFwd` counts. -/
def isUntlRoot : PlusFormula → Bool
  | .untl _ _ => true
  | _ => false

/-- The root count is monotone along the subformula relation, for any root predicate. -/
theorem card_rootFilter_mono (p : PlusFormula → Bool) {α φ : PlusFormula}
    (h : α ∈ PlusFormula.subformulas φ) :
    ((plusSubformulaClosure α).filter (fun ψ => p ψ = true)).card ≤
      ((plusSubformulaClosure φ).filter (fun ψ => p ψ = true)).card :=
  Finset.card_le_card
    (Finset.filter_subset_filter (fun ψ => p ψ = true) (closure_subset_of_mem_subformulas h))

/-- **THE `+ 1` STEP, ONCE, FOR BOTH DEPTHS.** When the root itself carries the counted shape and
lies in neither component's closure, both components' root counts embed in the root's with the
root erased, so the larger of them plus one still fits. -/
theorem card_rootFilter_succ (p : PlusFormula → Bool) {α β φ : PlusFormula} (a b : ℕ)
    (hroot : p φ = true)
    (hα : α ∈ PlusFormula.subformulas φ) (hβ : β ∈ PlusFormula.subformulas φ)
    (hnα : φ ∉ plusSubformulaClosure α) (hnβ : φ ∉ plusSubformulaClosure β)
    (ha : a ≤ ((plusSubformulaClosure α).filter (fun ψ => p ψ = true)).card)
    (hb : b ≤ ((plusSubformulaClosure β).filter (fun ψ => p ψ = true)).card) :
    max a b + 1 ≤ ((plusSubformulaClosure φ).filter (fun ψ => p ψ = true)).card := by
  set S := (plusSubformulaClosure φ).filter (fun ψ => p ψ = true) with hS
  have hmem : φ ∈ S := Finset.mem_filter.mpr ⟨self_mem_plusSubformulaClosure φ, hroot⟩
  have emb : ∀ {γ : PlusFormula}, γ ∈ PlusFormula.subformulas φ →
      φ ∉ plusSubformulaClosure γ →
      ((plusSubformulaClosure γ).filter (fun ψ => p ψ = true)) ⊆ S.erase φ := by
    intro γ hγ hnγ χ hχ
    obtain ⟨hχ1, hχ2⟩ := Finset.mem_filter.mp hχ
    refine Finset.mem_erase.mpr ⟨fun heq => hnγ (heq ▸ hχ1), ?_⟩
    exact Finset.mem_filter.mpr ⟨closure_subset_of_mem_subformulas hγ hχ1, hχ2⟩
  have cα := Finset.card_le_card (emb hα hnα)
  have cβ := Finset.card_le_card (emb hβ hnβ)
  rw [Finset.card_erase_of_mem hmem] at cα cβ
  have hpos : 1 ≤ S.card := Finset.card_pos.mpr ⟨_, hmem⟩
  omega

/-- **The backward exactness depth is bounded by the `snce`-rooted closure members.** -/
theorem dBack_le_card_snceRoot (φ : PlusFormula) :
    dBack φ ≤ ((plusSubformulaClosure φ).filter (fun ψ => isSnceRoot ψ = true)).card := by
  induction φ with
  | atom p => simp [dBack]
  | bot => simp [dBack]
  | box α ihα =>
    have := card_rootFilter_mono isSnceRoot (PlusFormula.box_inner_mem_subformulas α)
    simp only [dBack]; omega
  | stab α ihα =>
    have := card_rootFilter_mono isSnceRoot (PlusFormula.stab_inner_mem_subformulas α)
    simp only [dBack]; omega
  | imp α β ihα ihβ =>
    have ha := card_rootFilter_mono isSnceRoot (PlusFormula.imp_left_mem_subformulas α β)
    have hb := card_rootFilter_mono isSnceRoot (PlusFormula.imp_right_mem_subformulas α β)
    simp only [dBack]; omega
  | untl α β ihα ihβ =>
    have ha := card_rootFilter_mono isSnceRoot (PlusFormula.untl_right_mem_subformulas β α)
    have hb := card_rootFilter_mono isSnceRoot (PlusFormula.untl_left_mem_subformulas β α)
    simp only [dBack]; omega
  | snce α β ihα ihβ =>
    simp only [dBack]
    exact card_rootFilter_succ isSnceRoot _ _ (by simp [isSnceRoot])
      (PlusFormula.snce_right_mem_subformulas β α) (PlusFormula.snce_left_mem_subformulas β α)
      (not_mem_closure_of_plusFsize_lt (by simp only [plusFsize]; omega))
      (not_mem_closure_of_plusFsize_lt (by simp only [plusFsize]; omega)) ihα ihβ

/-- **The forward exactness depth is bounded by the `untl`-rooted closure members.** The mirror of
`dBack_le_card_snceRoot`, with the `+ 1` step at `untl` instead of `snce`. -/
theorem dFwd_le_card_untlRoot (φ : PlusFormula) :
    dFwd φ ≤ ((plusSubformulaClosure φ).filter (fun ψ => isUntlRoot ψ = true)).card := by
  induction φ with
  | atom p => simp [dFwd]
  | bot => simp [dFwd]
  | box α ihα =>
    have := card_rootFilter_mono isUntlRoot (PlusFormula.box_inner_mem_subformulas α)
    simp only [dFwd]; omega
  | stab α ihα =>
    have := card_rootFilter_mono isUntlRoot (PlusFormula.stab_inner_mem_subformulas α)
    simp only [dFwd]; omega
  | imp α β ihα ihβ =>
    have ha := card_rootFilter_mono isUntlRoot (PlusFormula.imp_left_mem_subformulas α β)
    have hb := card_rootFilter_mono isUntlRoot (PlusFormula.imp_right_mem_subformulas α β)
    simp only [dFwd]; omega
  | snce α β ihα ihβ =>
    have ha := card_rootFilter_mono isUntlRoot (PlusFormula.snce_right_mem_subformulas β α)
    have hb := card_rootFilter_mono isUntlRoot (PlusFormula.snce_left_mem_subformulas β α)
    simp only [dFwd]; omega
  | untl α β ihα ihβ =>
    simp only [dFwd]
    exact card_rootFilter_succ isUntlRoot _ _ (by simp [isUntlRoot])
      (PlusFormula.untl_right_mem_subformulas β α) (PlusFormula.untl_left_mem_subformulas β α)
      (not_mem_closure_of_plusFsize_lt (by simp only [plusFsize]; omega))
      (not_mem_closure_of_plusFsize_lt (by simp only [plusFsize]; omega)) ihα ihβ

/-- **THE TWO EXACTNESS DEPTHS SUM TO AT MOST THE CLOSURE'S CARDINALITY.** `(K4)`'s two depths and
`(K3)`'s `tShort` are read on the same scale by this one inequality: `dBack` counts `snce`-rooted
closure members, `dFwd` counts `untl`-rooted ones, and no closure member is both, so the two
counts sit in disjoint parts of the closure. -/
theorem dBack_add_dFwd_le_closure_card (φ : PlusFormula) :
    dBack φ + dFwd φ ≤ (plusSubformulaClosure φ).card := by
  classical
  have h1 := dBack_le_card_snceRoot φ
  have h2 := dFwd_le_card_untlRoot φ
  have hsub : (plusSubformulaClosure φ).filter (fun ψ => isUntlRoot ψ = true) ⊆
      (plusSubformulaClosure φ).filter (fun ψ => ¬ (isSnceRoot ψ = true)) := by
    intro χ hχ
    obtain ⟨hχ1, hχ2⟩ := Finset.mem_filter.mp hχ
    refine Finset.mem_filter.mpr ⟨hχ1, ?_⟩
    cases χ <;> simp_all [isSnceRoot, isUntlRoot]
  have hc := Finset.card_le_card hsub
  have hsplit :
      ((plusSubformulaClosure φ).filter (fun ψ => isSnceRoot ψ = true)).card +
        ((plusSubformulaClosure φ).filter (fun ψ => ¬ (isSnceRoot ψ = true))).card =
          (plusSubformulaClosure φ).card :=
    Finset.card_filter_add_card_filter_not (fun ψ => isSnceRoot ψ = true)
  omega

/-- **(K3)'s idle-run slack** `T_idle`: an idle run that revisits an idle object state repeats,
so the slack is counted by the number of idle object states. An OVER-ESTIMATE of the quantity it
names; (K3) is a lower bound on `T_c`, so the over-estimate strengthens the condition. -/
def tIdle {Q : Type} [Fintype Q] (pend : Q → Bool) : ℕ :=
  (Finset.univ.filter (fun q : Q => pend q = false)).card + 1

/-- `(K3)`'s idle-run slack is at least one: it is a cardinality plus one. -/
theorem one_le_tIdle {Q : Type} [Fintype Q] (pend : Q → Bool) : 1 ≤ tIdle pend := by
  simp [tIdle]

/-- **(K3)'s short-region threshold** `T_short`: counted by the classes a short region can
traverse. An OVER-ESTIMATE, entering a lower bound on `T_c`. -/
def tShort (Q : Type) [Fintype Q] (φ : PlusFormula) : ℕ := Fintype.card (ProdState Q φ)

/-- **(K3)'s `ℓ₀`**, the longest shortest path between saturated classes: dominated by the class
count, since a shortest path in a graph with that many vertices visits no vertex twice. An
OVER-ESTIMATE, entering a lower bound on `T_n`. -/
def ell0 (Q : Type) [Fintype Q] (φ : PlusFormula) : ℕ := Fintype.card (ProdState Q φ)

/-- **(K2)'s cascade bound**: the `iter_doubling` recurrence `a (k + 1) ≤ 2 * a k + J + 1`
(`counter-lift-gates.lean`) iterated over the at most `Fintype.card (ProdState Q φ)` distinct
pinned regions a rigid (all-exact) past can carry before repeating a class, at idle-run slack
`J := tIdle pend`. EXPONENTIAL in the number of pinned regions and not linear, which is what
`short_idle_threshold_refuted` says the threshold must be: a threshold read off the formula alone
is refuted. A COUNT, exhibited to record that shape; no upper bound is claimed, for this or for
anything it feeds. -/
def cascadeBound {Q : Type} [Fintype Q] (pend : Q → Bool) (φ : PlusFormula) : ℕ :=
  2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2)

/-! ## The four parameters as OUTPUTS -/

open Classical in
/-- The cycle lengths of (K1), collected as a `Finset` — the certificate graph's on saturated
classes, and the object's own. Classical in the two membership predicates, hence
noncomputable. -/
noncomputable def cycleLensF {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : Finset ℕ :=
  ((Finset.range (Fintype.card (ProdState Q φ) + 1)).filter
      (fun l => l ∈ prodCycleLens step pend lab φ)) ∪
    ((Finset.range (Fintype.card Q + 1)).filter (fun l => l ∈ objCycleLens step pend))

theorem zero_not_mem_cycleLensF {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : (0 : ℕ) ∉ cycleLensF step pend lab φ := by
  classical
  simp only [cycleLensF, Finset.mem_union, Finset.mem_filter, Finset.mem_range, not_or]
  refine ⟨fun h => ?_, fun h => ?_⟩
  · exact absurd h.2.1 (by omega)
  · exact absurd h.2.1 (by omega)

theorem mem_cycleLensF_of_prod {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {l : ℕ} (h : l ∈ prodCycleLens step pend lab φ) :
    l ∈ cycleLensF step pend lab φ := by
  classical
  have hle : l ≤ Fintype.card (ProdState Q φ) := h.2.1
  simp only [cycleLensF, Finset.mem_union, Finset.mem_filter, Finset.mem_range]
  exact Or.inl ⟨by omega, h⟩

theorem mem_cycleLensF_of_obj {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {l : ℕ} (h : l ∈ objCycleLens step pend) :
    l ∈ cycleLensF step pend lab φ := by
  classical
  have hle : l ≤ Fintype.card Q := h.2.1
  simp only [cycleLensF, Finset.mem_union, Finset.mem_filter, Finset.mem_range]
  exact Or.inr ⟨by omega, h⟩

/-- **The modulus of (K1)**: the least common multiple of the cycle lengths, times the
periodicity fixpoint's own period. A common multiple of every divisor (K1) requires, and a
COUNT — a least common multiple of cycle lengths and a period, not a bound. -/
noncomputable def modulusOf {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : ℕ :=
  (cycleLensF step pend lab φ).lcm id * satPeriod step lab φ

theorem modulusOf_pos {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : 0 < modulusOf step pend lab φ := by
  have hl : (cycleLensF step pend lab φ).lcm id ≠ 0 := by
    rw [Ne, Finset.lcm_eq_zero_iff]
    simpa using zero_not_mem_cycleLensF step pend lab φ
  have hp : 1 ≤ satPeriod step lab φ := satPeriod_pos step lab φ
  have : 0 < (cycleLensF step pend lab φ).lcm id := Nat.pos_of_ne_zero hl
  exact Nat.mul_pos this hp

/-- **(K1)'s parameter output `P`.** The modulus minus one, because both residue coordinates of
`kappa` are taken modulo `P + 1` (`LadderModel.lean`'s modulus convention). Source: (K1), via
the cycle lengths of the certificate graph on saturated classes and the set-level periodicity
form `prodPre_periodic`. -/
noncomputable def Pof {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : ℕ :=
  modulusOf step pend lab φ - 1

theorem Pof.succ {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) :
    Pof step pend lab φ + 1 = modulusOf step pend lab φ := by
  have h := modulusOf_pos step pend lab φ
  unfold Pof
  omega

/-! ## The `⊡`-nesting depth

The measure the `(K2)` margin conjunct is stratified by. It is purely syntactic — a recursion on
`PlusFormula` reading nothing of `step`, `pend`, `lab` or any parameter — and it is defined HERE
rather than beside the pinned-letter layer of `LadderAgree.lean` that consumes its arithmetic
facts, because `LadderAgree.lean` imports this module while `(K2)` and `Tcof` both read
`(plusSubformulaClosure φ).sup stabDepth`. -/

/-- **The `⊡`-nesting depth of a formula**: `0` on the atomic arms and on `□` (whose clause is
path-independent), the `max` across the three binary arms, and one more than its argument's on
`⊡`.

`stabDepth` is `0` on `□ψ` whatever `ψ` is, and that is deliberate: the `box` clause of
`PlusTruthAt` carries no state constraint and no history argument on its right-hand side
(`box_mem_tpOf_transfer`), so a `□` letter's bit is the same proposition at both compared points
and the depth of its argument is irrelevant to transport. -/
def stabDepth : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (stabDepth a) (stabDepth b)
  | .box _ => 0
  | .untl a b => max (stabDepth a) (stabDepth b)
  | .snce a b => max (stabDepth a) (stabDepth b)
  | .stab a => stabDepth a + 1

/-! ## The four parameter outputs, continued -/

/-- **(K2)'s and (K3)'s parameter output `T_c`.** The largest of the cascade bound (K2), the
semantic periodicity threshold (K2), (K3)'s `2 T_short + T_idle + 2`, and (K2)'s DEPTH-STRATIFIED
MARGIN read at `Pof`. Source: (K2) via `cascadeBound` (`iter_doubling`), `satThreshold`
(`prodPre_periodic`) and the margin, and (K3)'s ordering.

**The margin arm reads `Pof`, and there is no circularity**: `Pof` is
`modulusOf step pend lab φ - 1`, and `modulusOf` is the lcm of the certificate graph's cycle
lengths times the periodicity fixpoint's period. Neither reads `Tc`, `Tcof` or `Tnof`. The
dependency runs `Pof → Tcof → Tnof` in one direction only. -/
noncomputable def Tcof {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : ℕ :=
  max (max (cascadeBound pend φ)
      (max (satThreshold step lab φ) (2 * tShort Q φ + tIdle pend + 2)))
    (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (Pof step pend lab φ + 1) *
      ((plusSubformulaClosure φ).sup stabDepth + 1))

/-- **(K3)'s parameter output `T_n`.** `T_c` plus twice `ℓ₀`, which satisfies (K3)'s ordering
`T_n + 1 ≥ T_c + 2ℓ₀`. Source: (K3). -/
noncomputable def Tnof {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : ℕ :=
  Tcof step pend lab φ + 2 * ell0 Q φ

-- `linter.unusedVariables`, scoped to this declaration. `Bof` does not read `step`, `pend` or
-- `lab`: (K4) is the one parameter source that quantifies the FORMULA alone -- the two
-- exactness depths `dBack` and `dFwd`, and gate 1's `2 ≤ B`. The three binders are kept because
-- the four parameter outputs are pinned at ONE signature, and dropping a binder from one of them
-- changes
-- that signature. A deletion trial of the suppression reports three `unused variable` warnings,
-- one per binder (`[apply] _step`, `_pend`, `_lab`); a deletion trial of the binders instead
-- leaves `paramsOk_params` unable to elaborate against the signature it is pinned at. The
-- matching `unusedArguments` env_linter finding is exempted in `scripts/nolints.json` for the
-- same reason, as `coh_iff`'s ported binders are.
set_option linter.unusedVariables false in
/-- **(K4)'s parameter output `B`.** The largest of `2 d_back + 1`, `2 d_fwd + 2` and `2`.
Source: (K4) — the formula's backward exactness depth `dBack`, its forward exactness depth `dFwd`
(the wired probe `ladder-cell-obligation-refutation.lean`: the gap clip must dominate what a
closure formula can pin forward through the next region's pin), and gate 1 (`gate1_cell_ne`),
which reads the gap `n - c` and needs `2 ≤ B`.

**The forward arm is `+ 2`, not `+ 1`, and the asymmetry is forced rather than conservative.**
`LadderStepFrag.lean`'s module docstring, point 2, derives the derived relation's own gap clip
`G⁻ = 2 b + 2` as the solution of the one-step closure conditions `Zrel_succ`/`Zrel_pred` — the
backward arm closes at `2 a` and the forward one at `2 b + 2`. So the asymmetry lives on the
`Zrel` side and `(K4)` is the side that was short of it: at `+ 1` the clip `Bof` outputs does not
dominate `Zrel`'s own forward demand and no `ParamsOk` consumer can discharge it. The probe's
separating family scales with `B` through an `X`-chain of depth `B + 2`, whose `dFwd` is `B + 3`,
so this output still exceeds every `B` that family can defeat.

The signature carries `step`, `pend` and `lab` because the four parameter outputs are pinned at
one signature; (K4) is the one source that quantifies the formula alone, and that is the content
of this definition rather than an omission. -/
noncomputable def Bof {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) : ℕ :=
  max (2 * dBack φ + 1) (max (2 * dFwd φ + 2) 2)

/-! ## The parameter conditions (K1)-(K4) -/

/-- **(K1)**: `P + 1` is a common multiple of the cycle lengths of the certificate graph
restricted to saturated classes, of the object's own pending cycle lengths, and of the
periodicity fixpoint's period. Compiled anchors: `prodPreN_eventually_periodic` (the set-level
periodicity form, ported as `prodPre_periodic`) and `reach_period_refuted` (the divisibility
necessity on the object side). Divisibility into `P + 1` and never into `P`, by the modulus
convention. -/
def paramsOkK1 {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (P : ℕ) : Prop :=
  (∀ l ∈ prodCycleLens step pend lab φ, l ∣ (P + 1)) ∧
    (∀ l ∈ objCycleLens step pend, l ∣ (P + 1)) ∧
    satPeriod step lab φ ∣ (P + 1)

/-- **(K2)**: `T_c` is at least the cascade bound, at least the semantic periodicity threshold,
and at least the DEPTH-STRATIFIED MARGIN. Compiled anchors: `iter_doubling` (the recurrence the
cascade bound iterates) and `short_idle_threshold_refuted` (why `T_c` may not come from the
formula alone).

**The third conjunct is the margin, and it is why this predicate takes `P`.** With
`b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` the type-pigeonhole budget
(`budget_le_cascadeBound`, `card_prodState`) and `D := (plusSubformulaClosure φ).sup stabDepth`
the `⊡`-nesting depth of the closure, it asks

  `b * (P + 1) * (D + 1) ≤ Tc`.

**What it buys.** `b * (P + 1)` is exactly the room `exists_typeBlock_of_spacing`'s single
`hroom` hypothesis consumes at spacing `s := P + 1` — the spacing at which every block the
pigeonhole returns has length a multiple of `P + 1`, so that a pump through it is a
`kappa`-residue-preserving shift rather than an arbitrary one. The factor `D + 1` buys ONE SUCH
ROOM PER `⊡`-DEPTH LEVEL, which is what a depth-stratified induction spends: the level-`d`
invariant carries a threshold `Tc_d` with `Tc_d + b * (P + 1) ≤ Tc` still available above it
(`margin_room_at_depth`), so the step may pump once more without leaving the margin.
`budget_mul_spacing_le_Tc` and `margin_room_at_depth` are the two consumable forms.

**What it costs.** `paramsOk_inflate`'s unconditional form: inflating the modulus from `P + 1` to
`j * (P + 1)` multiplies this conjunct's requirement by `j`, which
`paramsOk_modulus_unbounded_at_fixed_Tc` (round-15 probe) says is NOT a consequence of (K1)-(K4)
at a fixed `Tc`. So the inflation lemma takes the inflated room as an explicit hypothesis, and
`paramsOk_inflate_raise` is the unconditional sibling that pays for it by raising `Tc` and `Tn`
with `P`.

The condition is SATISFIABLE: `paramsOk_params` discharges it at the periodicity fixpoint's own
parameters, through `Tcof`'s new `max` arm, and `exists_paramsOk_with_margin` (round-15 probe,
compiled) is the generic statement that a margin is available at every size. -/
def paramsOkK2 {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc P : ℕ) : Prop :=
  cascadeBound pend φ ≤ Tc ∧ satThreshold step lab φ ≤ Tc ∧
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1) *
      ((plusSubformulaClosure φ).sup stabDepth + 1) ≤ Tc

/-- **(K3)**: the ordering. `T_n + 1 ≥ T_c + 2ℓ₀` for `ℓ₀` the longest shortest path between
saturated classes, and `T_c ≥ 2 T_short + T_idle + 2`. Compiled anchor: `gate9_sep_cell_ne`, the
n-side separation that makes the two thresholds independent. -/
def paramsOkK3 (Q : Type) [Fintype Q] (pend : Q → Bool) (φ : PlusFormula) (Tc Tn : ℕ) : Prop :=
  Tc + 2 * ell0 Q φ ≤ Tn + 1 ∧ 2 * tShort Q φ + tIdle pend + 2 ≤ Tc

/-- **(K4)**: `B` is at least `2 d_back + 1`, at least `2 d_fwd + 2`, and at least `2`. Compiled
anchors: `gate1_cell_ne`, which reads the gap at distance two, and the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`, which refutes
the depth-`0` cell obligation at a gap clip bounded by `dBack` alone — the cell reads the register
forward through the next region's pin, so the clip must dominate the forward depth too.

**The forward conjunct is `2 d_fwd + 2`, and the asymmetry with the backward one is FORCED.**
`LadderStepFrag.lean`'s module docstring, point 2, derives the derived relation's gap clip from
the one-step closure conditions `Zrel_succ`/`Zrel_pred`: the backward arm closes at `2 a`, the
forward arm at `2 b + 2`. A `(K4)` whose forward conjunct reads `2 d_fwd + 1` is therefore ONE
SHORT of what `Zrel` demands, and a `ParamsOk` consumer cannot discharge
`cellAt_const_of_kappa_eq_stepFrag`'s `hBb` from it. The frozen record of that shorter conjunct is
`paramsOkK4Pre` below. -/
def paramsOkK4 (φ : PlusFormula) (B : ℕ) : Prop :=
  2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 2 ≤ B ∧ 2 ≤ B

/-- **THE PARAMETER CONDITIONS**, the conjunction of the four sources (K1)-(K4). This is NOT a
predicate on four naturals: (K1) quantifies the certificate graph's cycle lengths on saturated
classes and the periodicity fixpoint's period, (K2) the cascade bound and the periodicity
threshold, and (K4) the formula's two exactness depths — none of which a numeric-only
predicate can express. Only (K3)'s ordering is partly numeric. All four conjuncts are present: a
predicate missing one is the same contract gap one level down. -/
def ParamsOk {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  paramsOkK1 step pend lab φ P ∧ paramsOkK2 step pend lab φ Tc P ∧
    paramsOkK3 Q pend φ Tc Tn ∧ paramsOkK4 φ B

/-- **THE DISCHARGE LEMMA.** The parameter conditions hold at the four parameters the periodicity
fixpoint defines, so the hypothesis the factorization lemma and the fibre equation carry is
DISCHARGEABLE and neither statement is vacuous: a hypothesis no one can discharge is
indistinguishable from an unproved statement for every downstream consumer. -/
theorem paramsOk_params {Q : Type} [Fintype Q] [Nonempty Q] (step : Q → Q → Bool)
    (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula) :
    ParamsOk step pend lab φ (Tcof step pend lab φ) (Tnof step pend lab φ)
      (Pof step pend lab φ) (Bof step pend lab φ) := by
  classical
  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_⟩, ?_, ?_, ?_⟩
  · intro l hl
    rw [Pof.succ, modulusOf]
    exact Dvd.dvd.mul_right (Finset.dvd_lcm (mem_cycleLensF_of_prod step pend lab φ hl)) _
  · intro l hl
    rw [Pof.succ, modulusOf]
    exact Dvd.dvd.mul_right (Finset.dvd_lcm (mem_cycleLensF_of_obj step pend lab φ hl)) _
  · rw [Pof.succ, modulusOf]
    exact Dvd.dvd.mul_left dvd_rfl _
  -- (K2), the cascade bound: `Tcof`'s inner `max`, left arm.
  · exact le_trans (le_max_left _ _) (le_max_left _ _)
  -- (K2), the periodicity threshold: inner `max`, right arm, left.
  · exact le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) (le_max_left _ _)
  -- (K2), THE MARGIN: `Tcof`'s new outer arm, at `Pof` itself.
  · exact le_max_right _ _
  -- (K3)'s ordering, which tracks `Tcof` through `Tnof` whatever `Tcof` is.
  · unfold Tnof; omega
  -- (K3)'s `2 T_short + T_idle + 2`: inner `max`, right arm, right.
  · exact le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) (le_max_left _ _)
  · exact le_max_left _ _
  · exact le_trans (le_max_left _ _) (le_max_right _ _)
  · exact le_trans (le_max_right _ _) (le_max_right _ _)

/-! ### The PRE-REPAIR `(K4)`, frozen

`(K4)`'s forward conjunct was `2 * dFwd φ + 1 ≤ B` and is now `2 * dFwd φ + 2 ≤ B`
(`paramsOkK4` above): at `+ 1` the clip `Bof` outputs is one short of the derived relation's own
forward demand `2 b + 2`, so no `ParamsOk` consumer could discharge it.  The repair makes two
landed refutation records FALSE rather than merely unproved — their written clip is the least
clip the SHORTER conjunct admitted, and the repaired conjunct rejects it
(`not_paramsOkK4_thetaC_clip`, `LadderRealize.lean`) — so the shorter conjunct is frozen here and
those records are restated against the frozen copy.

The precedent is this tree's own: when `dFwd` was first added to `(K4)`, the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` froze the
then-current conjunct as `Probe836A.paramsOkK4Pre`/`ParamsOkPre` and recorded the rejection as
`Probe836A.not_paramsOkK4_two`.  These three declarations are the library-level analogue. -/

/-- **`(K4)` AS IT READ BEFORE THE FORWARD REPAIR**, frozen as a record and not as a condition any
construction should be stated against.  Its forward conjunct is `2 * dFwd φ + 1 ≤ B`, one short of
`Zrel`'s own `2 b + 2`.  Strictly weaker than `paramsOkK4`. -/
def paramsOkK4Pre (φ : PlusFormula) (B : ℕ) : Prop :=
  2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B

/-- **THE PARAMETER CONDITIONS AS THEY READ BEFORE THE FORWARD REPAIR**: `ParamsOk` verbatim with
`paramsOkK4Pre` as its fourth conjunct.  A FROZEN RECORD, carried so that the two landed
refutations whose written clip the repaired `(K4)` rejects can be restated honestly rather than
deleted or weakened in content. -/
def ParamsOkPre {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  paramsOkK1 step pend lab φ P ∧ paramsOkK2 step pend lab φ Tc P ∧
    paramsOkK3 Q pend φ Tc Tn ∧ paramsOkK4Pre φ B

/-- **THE FROZEN CONDITIONS ARE DISCHARGEABLE AT THE FIXPOINT'S OWN FOUR PRE-REPAIR OUTPUTS.**
The first three are `paramsOk_params`'s own — none of `(K1)`, `(K2)` or `(K3)` reads `B` — and the
fourth is the pre-repair `Bof` body `max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)`, which is the
value the two restated refutations' written clips are read at. -/
theorem paramsOkPre_params {Q : Type} [Fintype Q] [Nonempty Q] (step : Q → Q → Bool)
    (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula) :
    ParamsOkPre step pend lab φ (Tcof step pend lab φ) (Tnof step pend lab φ)
      (Pof step pend lab φ) (max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)) :=
  ⟨(paramsOk_params step pend lab φ).1, (paramsOk_params step pend lab φ).2.1,
    (paramsOk_params step pend lab φ).2.2.1,
    le_max_left _ _, le_trans (le_max_left _ _) (le_max_right _ _),
    le_trans (le_max_right _ _) (le_max_right _ _)⟩

/-- **`ParamsOk` IS CLOSED UNDER INFLATING THE MODULUS, GIVEN THE INFLATED ROOM.** `P` may be
replaced by `j * (P + 1) - 1` for any `j > 0`, so the modulus `P + 1` may be inflated to any
positive multiple of itself and the parameter conditions survive — PROVIDED the inflated margin
still fits under `Tc`, which is the explicit hypothesis `hroom`.

**Why the room hypothesis is explicit and not derivable.** (K1) is a DIVISIBILITY condition INTO
`P + 1`, so every divisor of `P + 1` divides `j * (P + 1)` as well: that conjunct inflation
cannot break. (K3) and (K4) never mention `P`. But `(K2)`'s margin conjunct does, LINEARLY, so
inflating the modulus by `j` multiplies its requirement by `j` — and
`paramsOk_modulus_unbounded_at_fixed_Tc` (round-15 probe) says exactly that no bound on `j` at a
fixed `Tc` follows from (K1)-(K4). The requirement is therefore taken as a hypothesis, which the
caller discharges by choosing `j` small enough against the margin it already has, or avoids
altogether by raising `Tc` with `P` through `paramsOk_inflate_raise`.

**What this does and does not buy.** It means a construction is free to choose the modulus as
large as the margin allows without weakening the parameter hypothesis. It does NOT make
`HasForwardSlack` available at the inflated amount: `LadderChain.lean`'s
`hasForwardSlack_amount_le` caps the regime's amount at `n + cntAt g z + I`, so an unboundedly
inflated modulus is exactly what the regime refuses.

**Nothing in the tree applies this lemma**, which is why taking the room as a hypothesis breaks
no consumer: it is a capability record about the parameter layer, read by prose and by no proof
term. -/
theorem paramsOk_inflate {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (j : ℕ) (hj : 0 < j)
    (hroom : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (j * (P + 1)) *
      ((plusSubformulaClosure φ).sup stabDepth + 1) ≤ Tc) :
    ParamsOk step pend lab φ Tc Tn (j * (P + 1) - 1) B := by
  obtain ⟨⟨h1, h2, h3⟩, hK2, hK3, hK4⟩ := hp
  have hjP : j * (P + 1) - 1 + 1 = j * (P + 1) := by
    have : 0 < j * (P + 1) := Nat.mul_pos hj (Nat.succ_pos P)
    omega
  refine ⟨⟨?_, ?_, ?_⟩, ⟨hK2.1, hK2.2.1, ?_⟩, hK3, hK4⟩
  · intro l hl; rw [hjP]; exact (h1 l hl).mul_left j
  · intro l hl; rw [hjP]; exact (h2 l hl).mul_left j
  · rw [hjP]; exact h3.mul_left j
  · rw [hjP]; exact hroom

/-- **THE INFLATION CAPABILITY, UNCONDITIONALLY, AT A RAISED `T_c`.** The sibling of
`paramsOk_inflate` that pays the margin's price instead of assuming it away: the modulus is
inflated to `j * (P + 1)` and `Tc` and `Tn` are raised together to cover the inflated margin, so
the capability survives with no hypothesis beyond `0 < j`.

The `Tc`/`Tn` half is the generic upward monotonicity of the parameter conditions in `Tc` once
`Tn` is raised with it — `paramsOk_raise_Tc` in the round-15 probe. (K1) is untouched by a change
of `Tc`; (K2)'s three conjuncts and (K3)'s `2 T_short + T_idle + 2` are all lower bounds on `Tc`
and so survive a raise; (K3)'s ordering survives because `Tn` is raised by the same amount. -/
theorem paramsOk_inflate_raise {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (j : ℕ) (hj : 0 < j) :
    ∃ Tc' Tn' : ℕ, Tc ≤ Tc' ∧ Tn ≤ Tn' ∧
      ParamsOk step pend lab φ Tc' Tn' (j * (P + 1) - 1) B := by
  classical
  obtain ⟨⟨h1, h2, h3⟩, hK2, hK3, hK4⟩ := hp
  have hjP : j * (P + 1) - 1 + 1 = j * (P + 1) := by
    have : 0 < j * (P + 1) := Nat.mul_pos hj (Nat.succ_pos P)
    omega
  refine ⟨Tc + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (j * (P + 1)) *
      ((plusSubformulaClosure φ).sup stabDepth + 1),
    Tn + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (j * (P + 1)) *
      ((plusSubformulaClosure φ).sup stabDepth + 1),
    Nat.le_add_right _ _, Nat.le_add_right _ _, ?_⟩
  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_⟩, hK4⟩
  · intro l hl; rw [hjP]; exact (h1 l hl).mul_left j
  · intro l hl; rw [hjP]; exact (h2 l hl).mul_left j
  · rw [hjP]; exact h3.mul_left j
  · exact le_trans hK2.1 (Nat.le_add_right _ _)
  · exact le_trans hK2.2.1 (Nat.le_add_right _ _)
  · rw [hjP]; exact Nat.le_add_left _ _
  · have h := hK3.1; omega
  · exact le_trans hK3.2 (Nat.le_add_right _ _)

/-! ## The two consumable forms of the margin

`(K2)`'s margin conjunct is stated once, as a product. Its two consumers read it at two different
shapes, and both are landed here so that no caller re-derives the arithmetic. -/

/-- **THE ROOM FOR THE SPACED PIGEONHOLE AT SPACING `P + 1`.** `b · (P + 1) ≤ Tc` for `b` the
type-pigeonhole budget.

This is EXACTLY the quantity `exists_typeBlock_of_spacing`'s single `hroom` hypothesis consumes at
`s := P + 1`: that hypothesis is
`w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * s : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ)`,
so a caller sampling from `w₀ := z` inside a region of countdown at least `Tc` discharges it from
this lemma and `Int.ofNat_le` alone. Spacing `P + 1` is the spacing at which every block the
pigeonhole returns has length a multiple of `P + 1`, hence at which a pump through it shifts the
countdown by a multiple of the modulus and so preserves `kappa`'s residue coordinate.

`budget_mul_succ_le_Tc` (`LadderChain.lean`) is the OLD room bound at spacing at most `b`, from
`cascadeBound` alone; it is untouched and remains what the overshoot loop reads. This lemma is not
derivable from it: `P` is unrelated to `b`. -/
theorem budget_mul_spacing_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1) ≤ Tc := by
  have hm := hp.2.1.2.2
  calc Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1)
      ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1) *
          ((plusSubformulaClosure φ).sup stabDepth + 1) :=
        Nat.le_mul_of_pos_right _ (Nat.succ_pos _)
    _ ≤ Tc := hm

/-- **ONE ROOM PER `⊡`-DEPTH LEVEL.** At the depth-indexed threshold
`Tc_d := (D − d) · (b · (P + 1))`, there is still a whole block of room above it:
`Tc_d + b · (P + 1) ≤ Tc`. This is what a depth-stratified induction spends — the level-`d`
invariant asks the compared countdowns to exceed `Tc_d`, and the step pumps once more, costing one
block and landing at level `d + 1`'s lower threshold.

**The base `Tc_0` of the plan's `Tc_d := Tc_0 + (D − d) · b · (P + 1)` is `0` here, and that is
forced rather than chosen.** The conjunct supplies `b · (P + 1) · (D + 1)` and no more, so the
`D + 1` blocks the stratification needs consume all of it; a positive base is bought only by
raising `Tc`, which is what `paramsOk_inflate_raise` does for the modulus and what a caller
needing a non-trivial threshold at the DEEPEST level would have to do here. The two readings an
induction takes off this definition — `Tc_D = 0` and `0 ≤ Tc_d` — are then immediate.

No `d ≤ D` side condition is needed: `D − d` is truncated subtraction, so the statement holds at
every `d` and implies the `d ≤ D` form. -/
theorem margin_room_at_depth {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (d : ℕ) :
    ((plusSubformulaClosure φ).sup stabDepth - d) *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1)) +
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1) ≤ Tc := by
  have hm := hp.2.1.2.2
  set b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1) with hb
  set D := (plusSubformulaClosure φ).sup stabDepth with hD
  have h1 : D - d + 1 ≤ D + 1 := by omega
  calc (D - d) * b + b = (D - d + 1) * b := by ring
    _ ≤ (D + 1) * b := Nat.mul_le_mul h1 (le_refl b)
    _ = b * (D + 1) := by ring
    _ ≤ Tc := hm

/-! ## The predicate is LOAD-BEARING: it fails at the refuted tuple

The object below is the refutation probe's own
(`specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean`,
`Probe761R`): four states `(pending?, tag)`, the tag flipping on every pending step and copied
onto the idle state that ends a region. Its four definitions are reproduced here so that the
exclusion is a theorem of the library about that object; the probe itself is untouched. -/

namespace AllZero

/-- The refutation probe's object states `(pending?, tag)`. -/
abbrev Qp : Type := Bool × Bool

/-- The refutation probe's pending bit. -/
def pendP : Qp → Bool := fun q => q.1

/-- The refutation probe's step relation: while pending the tag FLIPS on every pending step and
is COPIED onto the idle state that ends the region; an idle state only goes to an idle state with
the same tag. -/
def stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

/-- The refutation probe's three letters. -/
def pA : Atom := ⟨"p", none⟩

/-- The refutation probe's idle letter. -/
def rA : Atom := ⟨"r", none⟩

/-- The refutation probe's tag letter. -/
def aA : Atom := ⟨"a", none⟩

/-- The refutation probe's valuation. -/
def labP : Qp → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else if at_ = aA then q.2 else false

/-- The refutation probe's formula: `p U (r ∧ a)`, "the region ends on a tagged idle state". -/
def phiP : PlusFormula := .untl (.atom pA) ((PlusFormula.atom rA).and (.atom aA))

/-- The pending 2-cycle of that object: the tag flips on every pending step, so the two pending
states alternate. -/
def tagWalk (i : ℕ) : Qp := (true, decide (i % 2 = 1))

/-- **The object has a pending cycle of length `2`.** -/
theorem two_mem_objCycleLens : (2 : ℕ) ∈ objCycleLens stepP pendP := by
  refine ⟨by omega, by simp, tagWalk, ?_, ?_, ?_⟩
  · intro i
    simp only [tagWalk, stepP]
    rcases Nat.mod_two_eq_zero_or_one i with h0 | h1
    · have h : (i + 1) % 2 = 1 := by omega
      simp [h0, h]
    · have h : (i + 1) % 2 = 0 := by omega
      simp [h1, h]
  · intro i; simp [tagWalk, pendP]
  · simp [tagWalk]

/-- **THE EXCLUSION.** The parameter conditions FAIL at `Tc = Tn = P = B = 0`, the tuple the
fourteenth wired probe's refutation turns on, on that probe's own object: (K1) alone suffices,
because the object's pending cycle length `2` does not divide `0 + 1`. The repair is therefore
not cosmetic — the hypothesis excludes exactly the tuple that makes the two factorization-side
statements false. -/
theorem not_paramsOk_allZero : ¬ ParamsOk stepP pendP labP phiP 0 0 0 0 := by
  intro h
  have h2 : (2 : ℕ) ∣ (0 + 1) := h.1.2.1 2 two_mem_objCycleLens
  omega

end AllZero

/-! ## The `K`-indexed certificate conditions

The six conditions of `Certificate.lean`'s `certAdm`, restated at the carrier
`Q × ClType φ × CK Tc Tn P B` with `certStab` rebuilt per `(q, κ)`. The relation is the
idle-extended `cohIdle` on the object/closure components, with `R_K` on the `K` component —
Finding 1's relation of record. `pend` enters through `R_K`'s letters, which is why every
statement below takes it although `cohIdle` does not. -/

/-- **The `K`-indexed relation**: `cohIdle` on the object and closure components, `R_K` on the
counter class. -/
def relK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ)
    (x y : Q × ClType φ × CK Tc Tn P B) : Prop :=
  cohIdle step lab φ (x.1, x.2.1) (y.1, y.2.1) = true ∧
    RK Tc Tn P B (pend x.1) (pend y.1) x.2.2 y.2.2

/-- Condition (1) at the `K` carrier: local coherence at every member. -/
def certLocK {Q : Type} (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  ∀ x ∈ R, locCoh lab φ (x.1, x.2.1) = true

/-- Condition (2) at the `K` carrier: a successor AND a predecessor inside `R`. -/
def certBiInfK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  ∀ x ∈ R, (∃ y ∈ R, relK step pend lab φ Tc Tn P B x y) ∧
    (∃ y ∈ R, relK step pend lab φ Tc Tn P B y x)

/-- A guarded discharge path inside `R`: the right-hand side of the landed equivalence
`eu_mem_lfp_iff_exists_path`, at the `K` carrier and with `succR` unfolded into the relation and
the membership it conjoins. -/
def DischPathK {Q : Type} {φ : PlusFormula} {Tc Tn P B : ℕ}
    (rel : (Q × ClType φ × CK Tc Tn P B) → (Q × ClType φ × CK Tc Tn P B) → Prop)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) (x : Q × ClType φ × CK Tc Tn P B)
    (g e : PlusFormula) : Prop :=
  ∃ (m : ℕ) (f : ℕ → Q × ClType φ × CK Tc Tn P B), 0 < m ∧ f 0 = x ∧
    (∀ i < m, f i ∈ R) ∧ (∀ i < m, rel (f i) (f (i + 1)) ∧ f (i + 1) ∈ R) ∧
    e ∈ (f m).2.1.val ∧ (∀ i, 0 < i → i < m → g ∈ (f i).2.1.val)

/-- Condition (3) at the `K` carrier: EXISTENTIAL forward discharge inside `R`. -/
def certFwdK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  ∀ x ∈ R, ∀ ψ ∈ x.2.1.val, isUntl ψ = true →
    DischPathK (relK step pend lab φ Tc Tn P B) R x (argsOf ψ).1 (argsOf ψ).2

/-- Condition (4) at the `K` carrier: the past-directed mirror, along the reversed relation. -/
def certBwdK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  ∀ x ∈ R, ∀ ψ ∈ x.2.1.val, isSnce ψ = true →
    DischPathK (fun u v => relK step pend lab φ Tc Tn P B v u) R x (argsOf ψ).1 (argsOf ψ).2

/-- **Condition (5) REBUILT per `(q, κ)`.** The `⊡` letter's bit at a member is the fibre of `R`
over that member's OBJECT state AND its counter class. The `K`-free fibre over `q` alone, which
`Certificate.lean`'s `certStab` uses, is the wrong granularity for the ladder: `stab_mem_tpOf_iff`
is per cell, and `cell_ne` refutes the collapse of a per-state labelling (F2(a)). -/
def certStabK {Q : Type} (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  ∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure φ, isStab ψ = true →
    (ψ ∈ x.2.1.val ↔ ∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1.val)

/-- **Condition (6)** at the `K` carrier: the `□` letter's bit is ONE GLOBAL BIT, the fibre of
`R` over everything (`box_mem_tpOf_iff`). -/
def certBoxK {Q : Type} (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  ∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure φ, isBox ψ = true →
    (ψ ∈ x.2.1.val ↔ ∀ y ∈ R, argOf ψ ∈ y.2.1.val)

/-- **THE `K`-INDEXED CERTIFICATE.** The six conditions, with the acceptance clause — conditions
(5) and (6), the `stab` and `box` letters — never dropped. -/
def certAdmK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) (R : Set (Q × ClType φ × CK Tc Tn P B)) : Prop :=
  certLocK lab φ Tc Tn P B R ∧ certBiInfK step pend lab φ Tc Tn P B R ∧
    certFwdK step pend lab φ Tc Tn P B R ∧ certBwdK step pend lab φ Tc Tn P B R ∧
    certStabK φ Tc Tn P B R ∧ certBoxK φ Tc Tn P B R

/-! ## `Dmax`, the maximum certified subset -/

/-- **THE MAXIMUM CERTIFIED SUBSET.** The union of the `certAdmK`-certified subsets of
`Q × ClType φ × CK Tc Tn P B`: the ⊆-least upper bound of the certified family, so every
certified set lies inside it (`dmax_maximal`). The family is enumerated over
`Q × ClType φ × CK Tc Tn P B`, which is finite whenever the object is — a COUNT of candidates,
and no bound of any kind. -/
def Dmax {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) : Set (Q × ClType φ × CK Tc Tn P B) :=
  {x | ∃ R : Set (Q × ClType φ × CK Tc Tn P B),
    certAdmK step pend lab φ Tc Tn P B R ∧ x ∈ R}

theorem mem_Dmax_iff {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) (x : Q × ClType φ × CK Tc Tn P B) :
    x ∈ Dmax step pend lab φ Tc Tn P B ↔
      ∃ R : Set (Q × ClType φ × CK Tc Tn P B),
        certAdmK step pend lab φ Tc Tn P B R ∧ x ∈ R :=
  Iff.rfl

/-- **MAXIMALITY.** Every `certAdmK`-certified set lies inside `Dmax`. -/
theorem dmax_maximal {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) (R : Set (Q × ClType φ × CK Tc Tn P B))
    (hR : certAdmK step pend lab φ Tc Tn P B R) : R ⊆ Dmax step pend lab φ Tc Tn P B :=
  fun _ hx => ⟨R, hR, hx⟩

/-- Condition (1) is preserved by the union, hence holds OF `Dmax`. -/
theorem dmax_certLocK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) :
    certLocK lab φ Tc Tn P B (Dmax step pend lab φ Tc Tn P B) := by
  rintro x ⟨R, hR, hx⟩
  exact hR.1 x hx

/-- Condition (2) is preserved by the union, hence holds OF `Dmax`. -/
theorem dmax_certBiInfK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    certBiInfK step pend lab φ Tc Tn P B (Dmax step pend lab φ Tc Tn P B) := by
  rintro x ⟨R, hR, hx⟩
  obtain ⟨⟨y, hyR, hxy⟩, ⟨z, hzR, hzx⟩⟩ := hR.2.1 x hx
  exact ⟨⟨y, dmax_maximal step pend lab φ Tc Tn P B R hR hyR, hxy⟩,
    ⟨z, dmax_maximal step pend lab φ Tc Tn P B R hR hzR, hzx⟩⟩

/-- Condition (3) is preserved by the union, hence holds OF `Dmax`: a discharge path inside a
certified set is a discharge path inside the union. -/
theorem dmax_certFwdK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) :
    certFwdK step pend lab φ Tc Tn P B (Dmax step pend lab φ Tc Tn P B) := by
  rintro x ⟨R, hR, hx⟩ ψ hψ hu
  obtain ⟨m, f, hm, hf0, hfR, hfs, hfe, hfg⟩ := hR.2.2.1 x hx ψ hψ hu
  refine ⟨m, f, hm, hf0, ?_, ?_, hfe, hfg⟩
  · exact fun i hi => dmax_maximal step pend lab φ Tc Tn P B R hR (hfR i hi)
  · exact fun i hi => ⟨(hfs i hi).1,
      dmax_maximal step pend lab φ Tc Tn P B R hR (hfs i hi).2⟩

/-- Condition (4) is preserved by the union, hence holds OF `Dmax`. -/
theorem dmax_certBwdK {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (Tc Tn P B : ℕ) :
    certBwdK step pend lab φ Tc Tn P B (Dmax step pend lab φ Tc Tn P B) := by
  rintro x ⟨R, hR, hx⟩ ψ hψ hs
  obtain ⟨m, f, hm, hf0, hfR, hfs, hfe, hfg⟩ := hR.2.2.2.1 x hx ψ hψ hs
  refine ⟨m, f, hm, hf0, ?_, ?_, hfe, hfg⟩
  · exact fun i hi => dmax_maximal step pend lab φ Tc Tn P B R hR (hfR i hi)
  · exact fun i hi => ⟨(hfs i hi).1,
      dmax_maximal step pend lab φ Tc Tn P B R hR (hfs i hi).2⟩

end FormalSystem.Metalogic.Decidability.RaySummary
