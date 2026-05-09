import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Order.SuccPred.LinearLocallyFinite

/-!
# Chronicle-to-Countermodel Integration

Converts the Burgess chronicle construction into a countermodel suitable for
the BX completeness theorem, via a case split on density vs discreteness.

## Strategy

The chronicle construction produces, for any MCS A:
- `limit_dom A h_mcs`: a countable set of rationals containing 0
- `limit_f A h_mcs`: a function assigning MCS to each domain point
- `limit_f_zero`: limit_f(0) = A
- `limit_c0`: every domain point maps to an MCS
- `limit_forward_G`/`limit_backward_H`: G/H propagation on domain
- `limit_satisfies_c5_strong`/`limit_satisfies_c5'_strong`: Until/Since (C5)
- `limit_satisfies_c4`/`limit_satisfies_c4'`: Counterexample elimination (C4)

### Dense case (D = Rat via Cantor iso)

When `F'T = neg(U(T,bot))` is in all domain MCS's, the limit domain is dense,
so `LimitDomSubtype ≃o Rat` via Cantor's theorem. The FMCS on Rat transports
forward_G/backward_H through the isomorphism.

### Discrete case (D = Int via Z-iso)

When `U(T,bot)` is in all domain MCS's, the limit domain is discrete with
SuccOrder/PredOrder. The Z-isomorphism `LimitDomSubtype ≃o Int` via Mathlib's
`orderIsoIntOfLinearSuccPredArch` additionally requires `IsSuccArchimedean`,
which has one remaining sorry (the well-founded termination argument for the
succ chain reaching any target element).

## References

- Burgess 1982: "Axioms for tense logic II: Time periods"
- Task 117 plan: specs/117_.../plans/04_case-split-completeness.md
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
open Bimodal.Semantics
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Perpetuity
open Bimodal.Metalogic.BXCanonical
open Classical

/-! ## Limit Domain Properties

The subtype `{q : Rat // q ∈ limit_dom A h_mcs}` inherits `LinearOrder` from `Rat`.
We prove the typeclass prerequisites `Countable`, `NoMinOrder`, `NoMaxOrder`, `Nonempty`.
-/

/-- The limit domain as a subtype of the rationals. -/
abbrev LimitDomSubtype (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :=
  {q : Rat // q ∈ limit_dom A h_mcs}

/--
`LimitDomSubtype` is countable: `limit_dom` is a countable union of finite sets
(each `omega_chain_val(n).dom` is a `Finset Rat`).
-/
instance limitDomSubtype_countable (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    Countable (LimitDomSubtype A h_mcs) :=
  Subtype.countable

/--
Helper: for any x in `limit_dom`, there exists y > x in `limit_dom`.

Proof: The seriality axiom `serial_future` gives `F(top)` in every MCS.
Since `limit_c0` assigns an MCS to x, we have `F(top) ∈ limit_f(x)`.
Then `limit_F_resolution` produces y > x in `limit_dom`.
-/
theorem limit_dom_no_max (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    ∃ y ∈ limit_dom A h_mcs, x < y := by
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_top : (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    theorem_in_mcs h_mcs_x (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_F_top : Formula.some_future (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x (DerivationTree.axiom [] _ Axiom.serial_future)) h_top
  obtain ⟨y, hy, hxy, _⟩ := limit_F_resolution A h_mcs x hx _ h_F_top
  exact ⟨y, hy, hxy⟩

/--
Helper: for any x in `limit_dom`, there exists y < x in `limit_dom`.

Proof: The seriality axiom `serial_past` gives `P(top)` in every MCS.
Since `limit_c0` assigns an MCS to x, we have `P(top) ∈ limit_f(x)`.
Then `limit_P_resolution` produces y < x in `limit_dom`.
-/
theorem limit_dom_no_min (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    ∃ y ∈ limit_dom A h_mcs, y < x := by
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_top : (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    theorem_in_mcs h_mcs_x (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_P_top : Formula.some_past (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x (DerivationTree.axiom [] _ Axiom.serial_past)) h_top
  obtain ⟨y, hy, hyx, _⟩ := limit_P_resolution A h_mcs x hx _ h_P_top
  exact ⟨y, hy, hyx⟩

/--
`LimitDomSubtype` has no maximum element: from seriality + `limit_F_resolution`.
-/
instance limitDomSubtype_noMaxOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    NoMaxOrder (LimitDomSubtype A h_mcs) where
  exists_gt := by
    intro ⟨a, ha⟩
    obtain ⟨y, hy, hay⟩ := limit_dom_no_max A h_mcs a ha
    exact ⟨⟨y, hy⟩, hay⟩

/--
`LimitDomSubtype` has no minimum element: from seriality + `limit_P_resolution`.
-/
instance limitDomSubtype_noMinOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    NoMinOrder (LimitDomSubtype A h_mcs) where
  exists_lt := by
    intro ⟨a, ha⟩
    obtain ⟨y, hy, hya⟩ := limit_dom_no_min A h_mcs a ha
    exact ⟨⟨y, hy⟩, hya⟩

/--
`LimitDomSubtype` is nonempty: from `zero_mem_limit_dom`.
-/
instance limitDomSubtype_nonempty (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    Nonempty (LimitDomSubtype A h_mcs) :=
  ⟨⟨0, zero_mem_limit_dom A h_mcs⟩⟩

/-! ## Dense Case: Density from F'T and Cantor Isomorphism

When `F'T` (= `neg(U(T,bot))`) is present in all domain MCS's, we can prove
`DenselyOrdered (LimitDomSubtype A h_mcs)` via `limit_satisfies_c4`.

With density established, the Cantor isomorphism (`Order.iso_of_countable_dense`)
bijects LimitDomSubtype onto Rat, and we define `cantor_fmcs_dense : FMCS Rat`
by transporting the chronicle coherence properties through the isomorphism.

All definitions in this section take the density hypothesis `h_dense` as a
parameter, making density conditional rather than unconditional.
-/

/-- Top formula: `⊥ → ⊥` (a tautology). -/
private def top_formula : Formula := Formula.bot.imp Formula.bot

/-- `U(⊤, ⊥)` — "next top", true iff there is an immediate successor. -/
private def next_top : Formula := Formula.untl top_formula Formula.bot

/--
Density of `limit_dom` from the hypothesis that `F'⊤ = neg(U(⊤,⊥))` is in
every domain MCS.

Given `x < y` in `limit_dom`, we invoke `limit_satisfies_c4` with `η = ⊤`
(top_formula) and `ξ = ⊥`. The hypotheses are:
- `(Formula.untl top_formula Formula.bot).neg ∈ limit_f(x)` — this is exactly
  `F'⊤ ∈ limit_f(x)`, provided by `h_dense`.
- `top_formula ∈ limit_f(y)` — `⊤` is in every MCS.

The conclusion gives `z ∈ limit_dom` with `x < z < y` (and `⊥.neg ∈ limit_f(z)`,
which is trivially true).
-/
theorem limit_dom_dense_from_F'T (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hxy : x < y) :
    ∃ z ∈ limit_dom A h_mcs, x < z ∧ z < y := by
  have h_neg_until : (Formula.untl top_formula Formula.bot).neg ∈ limit_f A h_mcs x :=
    h_dense x hx
  have h_mcs_y := limit_c0 A h_mcs y hy
  have h_event : top_formula ∈ limit_f A h_mcs y :=
    theorem_in_mcs h_mcs_y (identity Formula.bot)
  obtain ⟨z, hz, hxz, hzy, _⟩ :=
    limit_satisfies_c4 A h_mcs x y hx hy hxy Formula.bot top_formula h_neg_until h_event
  exact ⟨z, hz, hxz, hzy⟩

/--
`DenselyOrdered` instance for `LimitDomSubtype`, conditional on F'T being
in every domain MCS. Wraps `limit_dom_dense_from_F'T`.
-/
def limitDomSubtype_denselyOrdered_from_F'T (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x) :
    DenselyOrdered (LimitDomSubtype A h_mcs) where
  dense := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ hab
    obtain ⟨z, hz, haz, hzb⟩ := limit_dom_dense_from_F'T A h_mcs h_dense a b ha hb hab
    exact ⟨⟨z, hz⟩, haz, hzb⟩

/--
Cantor isomorphism: `LimitDomSubtype A h_mcs ≃o Rat`, conditional on density.

Requires `DenselyOrdered`, `Countable`, `NoMinOrder`, `NoMaxOrder`, `Nonempty`
— all available (the first from `h_dense`, the rest unconditionally).
-/
noncomputable def cantor_iso_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x) :
    LimitDomSubtype A h_mcs ≃o Rat :=
  letI := limitDomSubtype_denselyOrdered_from_F'T A h_mcs h_dense
  Classical.choice (Order.iso_of_countable_dense (LimitDomSubtype A h_mcs) Rat)

/-- MCS assignment via the Cantor isomorphism (dense case). -/
noncomputable def cantor_f_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x) :
    Rat → Set Formula :=
  fun q => limit_f A h_mcs ((cantor_iso_dense A h_mcs h_dense).symm q).val

/-- The rational corresponding to the origin `0 ∈ limit_dom` (dense case). -/
noncomputable def cantor_zero_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x) :
    Rat :=
  (cantor_iso_dense A h_mcs h_dense) ⟨0, zero_mem_limit_dom A h_mcs⟩

/-- `cantor_f_dense` at `cantor_zero_dense` equals A (the root MCS). -/
theorem cantor_f_dense_at_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x) :
    cantor_f_dense A h_mcs h_dense (cantor_zero_dense A h_mcs h_dense) = A := by
  unfold cantor_f_dense cantor_zero_dense
  simp [OrderIso.symm_apply_apply]
  exact limit_f_zero A h_mcs

/-- Every rational maps to an MCS via `cantor_f_dense`. -/
theorem cantor_f_dense_is_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x)
    (q : Rat) : SetMaximalConsistent (cantor_f_dense A h_mcs h_dense q) := by
  unfold cantor_f_dense
  exact limit_c0 A h_mcs _ ((cantor_iso_dense A h_mcs h_dense).symm q).property

/--
FMCS on Rat (dense case): the chronicle coherence properties `limit_forward_G`
and `limit_backward_H` are transported through `cantor_iso_dense.symm`, which
is strictly monotone (as an OrderIso symm).
-/
noncomputable def cantor_fmcs_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs,
      next_top.neg ∈ limit_f A h_mcs x) :
    FMCS Rat where
  mcs := cantor_f_dense A h_mcs h_dense
  is_mcs := cantor_f_dense_is_mcs A h_mcs h_dense
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt_dom := (cantor_iso_dense A h_mcs h_dense).symm.strictMono h_lt
    exact limit_forward_G A h_mcs
      ((cantor_iso_dense A h_mcs h_dense).symm t).val
      ((cantor_iso_dense A h_mcs h_dense).symm t').val
      ((cantor_iso_dense A h_mcs h_dense).symm t).property
      ((cantor_iso_dense A h_mcs h_dense).symm t').property
      h_lt_dom φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt_dom := (cantor_iso_dense A h_mcs h_dense).symm.strictMono h_lt
    exact limit_backward_H A h_mcs
      ((cantor_iso_dense A h_mcs h_dense).symm t).val
      ((cantor_iso_dense A h_mcs h_dense).symm t').val
      ((cantor_iso_dense A h_mcs h_dense).symm t).property
      ((cantor_iso_dense A h_mcs h_dense).symm t').property
      h_lt_dom φ h_H

/-! ## Discrete Case: Z-Isomorphism from U(⊤,⊥)

When `U(⊤,⊥)` (= `next_top`) is present in all domain MCS's, the limit domain
is discrete: every point has an immediate successor and predecessor (the C5
witness has an empty guard since ⊥ is never in any MCS). With `SuccOrder`,
`PredOrder`, and `IsSuccArchimedean` established, Mathlib's
`orderIsoIntOfLinearSuccPredArch` gives `LimitDomSubtype ≃o ℤ`, and we define
`discrete_fmcs : FMCS Int` by transporting the chronicle coherence.

All definitions take the discrete hypothesis `h_discrete` as a parameter.
-/

/--
Successor witness in the discrete case: given `U(⊤,⊥) ∈ limit_f(x)`, there
exists `y ∈ limit_dom` that is the immediate successor of `x` — i.e., `x < y`
and there are no domain points between `x` and `y`.
-/
theorem limit_dom_has_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (h_next : next_top ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧
      ∀ w ∈ limit_dom A h_mcs, x < w → w < y → False := by
  obtain ⟨y, hy, hxy, _, h_guard⟩ :=
    limit_satisfies_c5_strong A h_mcs x hx Formula.bot top_formula h_next
  refine ⟨y, hy, hxy, fun w hw hxw hwy => ?_⟩
  have h_bot := h_guard w hw hxw hwy
  exact bot_not_in_mcs (limit_c0 A h_mcs w hw) h_bot

/--
Predecessor witness in the discrete case: given `S(⊤,⊥) ∈ limit_f(x)`, there
exists `y ∈ limit_dom` that is the immediate predecessor of `x`.
-/
theorem limit_dom_has_pred (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (h_since : Formula.snce top_formula Formula.bot ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, y < x ∧
      ∀ w ∈ limit_dom A h_mcs, y < w → w < x → False := by
  obtain ⟨y, hy, hyx, _, h_guard⟩ :=
    limit_satisfies_c5'_strong A h_mcs x hx Formula.bot top_formula h_since
  refine ⟨y, hy, hyx, fun w hw hyw hwx => ?_⟩
  have h_bot := h_guard w hw hyw hwx
  exact bot_not_in_mcs (limit_c0 A h_mcs w hw) h_bot

/--
From `U(⊤,⊥) ∈ limit_f(x)`, derive `S(⊤,⊥) ∈ limit_f(x)` using the
`discrete_symm_fwd` axiom (which is a BX theorem, hence in every MCS).
-/
theorem next_top_gives_since (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (h_next : next_top ∈ limit_f A h_mcs x) :
    Formula.snce top_formula Formula.bot ∈ limit_f A h_mcs x := by
  have h_mcs_x := limit_c0 A h_mcs x hx
  exact SetMaximalConsistent.implication_property h_mcs_x
    (theorem_in_mcs h_mcs_x (DerivationTree.axiom [] _ Axiom.discrete_symm_fwd))
    h_next

/--
Noncomputable successor function on `LimitDomSubtype` in the discrete case.
Uses `Classical.choose` to extract the immediate successor witness from C5.
-/
noncomputable def limitDomSubtype_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    LimitDomSubtype A h_mcs → LimitDomSubtype A h_mcs :=
  fun ⟨x, hx⟩ =>
    ⟨(limit_dom_has_succ A h_mcs x hx (h_discrete x hx)).choose,
     (limit_dom_has_succ A h_mcs x hx (h_discrete x hx)).choose_spec.1⟩

/--
The successor function satisfies `succ a ≤ b ↔ a < b` — this is the key
property for `SuccOrder.ofSuccLeIff`.
-/
theorem limitDomSubtype_succ_le_iff (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) :
    limitDomSubtype_succ A h_mcs h_discrete a ≤ b ↔ a < b := by
  constructor
  · -- succ a ≤ b → a < b
    intro h_succ_le
    have h_lt_succ : a.val < (limitDomSubtype_succ A h_mcs h_discrete a).val := by
      unfold limitDomSubtype_succ
      exact (limit_dom_has_succ A h_mcs a.val a.property (h_discrete a.val a.property)).choose_spec.2.1
    exact lt_of_lt_of_le h_lt_succ h_succ_le
  · -- a < b → succ a ≤ b
    intro h_lt
    -- succ a is the C5 witness y > a with no domain points between a and y
    unfold limitDomSubtype_succ
    set witness := (limit_dom_has_succ A h_mcs a.val a.property (h_discrete a.val a.property))
    set y := witness.choose with hy_def
    have hy_mem := witness.choose_spec.1
    have hay := witness.choose_spec.2.1
    have h_no_between := witness.choose_spec.2.2
    -- Need: y ≤ b.val
    by_contra h_not_le
    push_neg at h_not_le
    -- y > b.val, so a < b < y, and b is in domain — contradiction
    exact h_no_between b.val b.property h_lt h_not_le

/--
`SuccOrder` instance for `LimitDomSubtype` in the discrete case.
-/
noncomputable def limitDomSubtype_succOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    SuccOrder (LimitDomSubtype A h_mcs) :=
  SuccOrder.ofSuccLeIff
    (limitDomSubtype_succ A h_mcs h_discrete)
    (limitDomSubtype_succ_le_iff A h_mcs h_discrete _ _)

/--
Noncomputable predecessor function on `LimitDomSubtype` in the discrete case.
Uses `Classical.choose` to extract the immediate predecessor witness from C5'.
-/
noncomputable def limitDomSubtype_pred (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    LimitDomSubtype A h_mcs → LimitDomSubtype A h_mcs :=
  fun ⟨x, hx⟩ =>
    have h_since := next_top_gives_since A h_mcs x hx (h_discrete x hx)
    ⟨(limit_dom_has_pred A h_mcs x hx h_since).choose,
     (limit_dom_has_pred A h_mcs x hx h_since).choose_spec.1⟩

/--
The predecessor function satisfies `a ≤ pred b ↔ a < b` — key property
for `PredOrder.ofLePredIff`.
-/
theorem limitDomSubtype_le_pred_iff (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) :
    a ≤ limitDomSubtype_pred A h_mcs h_discrete b ↔ a < b := by
  constructor
  · -- a ≤ pred b → a < b
    intro h_le_pred
    have h_pred_lt : (limitDomSubtype_pred A h_mcs h_discrete b).val < b.val := by
      unfold limitDomSubtype_pred
      exact (limit_dom_has_pred A h_mcs b.val b.property
        (next_top_gives_since A h_mcs b.val b.property (h_discrete b.val b.property))).choose_spec.2.1
    exact lt_of_le_of_lt h_le_pred h_pred_lt
  · -- a < b → a ≤ pred b
    intro h_lt
    unfold limitDomSubtype_pred
    set witness := (limit_dom_has_pred A h_mcs b.val b.property
      (next_top_gives_since A h_mcs b.val b.property (h_discrete b.val b.property)))
    set y := witness.choose with hy_def
    have hy_mem := witness.choose_spec.1
    have hyb := witness.choose_spec.2.1
    have h_no_between := witness.choose_spec.2.2
    -- Need: a.val ≤ y
    by_contra h_not_le
    push_neg at h_not_le
    -- a > y, so y < a < b, and a is in domain — contradiction
    exact h_no_between a.val a.property h_not_le h_lt

/--
`PredOrder` instance for `LimitDomSubtype` in the discrete case.
-/
noncomputable def limitDomSubtype_predOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    PredOrder (LimitDomSubtype A h_mcs) :=
  PredOrder.ofLePredIff
    (limitDomSubtype_pred A h_mcs h_discrete)
    (limitDomSubtype_le_pred_iff A h_mcs h_discrete _ _)

/--
`succ(pred(b)) = b` in the discrete case: the successor of the predecessor
is the identity. This follows because `pred(b) < b` and `succ(pred(b))` is
the least domain point > `pred(b)`. Since there are no domain points between
`pred(b)` and `b` (by the predecessor property), `succ(pred(b)) = b`.
-/
theorem limitDomSubtype_succ_pred (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (b : LimitDomSubtype A h_mcs) :
    limitDomSubtype_succ A h_mcs h_discrete
      (limitDomSubtype_pred A h_mcs h_discrete b) = b := by
  set pb := limitDomSubtype_pred A h_mcs h_discrete b
  set spb := limitDomSubtype_succ A h_mcs h_discrete pb
  apply le_antisymm
  · -- succ(pred(b)) ≤ b: from SuccOrder property and pred(b) < b
    rw [show spb ≤ b ↔ pb < b from limitDomSubtype_succ_le_iff A h_mcs h_discrete pb b]
    -- pred(b) < b follows from the le_pred_iff: a ≤ pred(b) ↔ a < b
    -- Taking a = pred(b): pred(b) ≤ pred(b) ↔ pred(b) < b, so pred(b) < b
    exact (limitDomSubtype_le_pred_iff A h_mcs h_discrete pb b).mp le_rfl
  · -- b ≤ succ(pred(b)): by contradiction.
    -- If spb < b, then pred(b) < spb < b, contradicting the predecessor property.
    by_contra h_not_le
    push_neg at h_not_le
    -- spb < b, so pred(b) < spb (since spb > pred(b) by succ property)
    -- and spb < b. We also need spb ≤ pred(b) from the pred property.
    -- Actually: from a ≤ pred(b) ↔ a < b, with a = spb: spb ≤ pred(b) ↔ spb < b
    have h_spb_le_pb : spb ≤ pb :=
      (limitDomSubtype_le_pred_iff A h_mcs h_discrete spb b).mpr h_not_le
    -- But also pb < spb (pred < succ(pred))
    have h_pb_lt_spb : pb < spb :=
      (limitDomSubtype_succ_le_iff A h_mcs h_discrete pb spb).mp le_rfl
    exact lt_irrefl spb (lt_of_le_of_lt h_spb_le_pb h_pb_lt_spb)

/--
Helper: `a ≤ pred(b)` when `a < b`. Follows from `limitDomSubtype_le_pred_iff`.
-/
theorem limitDomSubtype_le_pred_of_lt (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) (h : a < b) :
    a ≤ limitDomSubtype_pred A h_mcs h_discrete b :=
  (limitDomSubtype_le_pred_iff A h_mcs h_discrete a b).mpr h

/--
Helper: `pred(b) < b` for any `b`. Follows from `limitDomSubtype_le_pred_iff`.
-/
theorem limitDomSubtype_pred_lt (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (b : LimitDomSubtype A h_mcs) :
    limitDomSubtype_pred A h_mcs h_discrete b < b :=
  (limitDomSubtype_le_pred_iff A h_mcs h_discrete
    (limitDomSubtype_pred A h_mcs h_discrete b) b).mp le_rfl

/--
`IsSuccArchimedean` instance for `LimitDomSubtype` in the discrete case.

For `a ≤ b`, we show there exists `n` with `succ^[n] a = b`. The proof strategy:
if `a < b`, then `a ≤ pred(b)` and `pred(b) < b`. By the `succ_pred` identity,
`succ(pred(b)) = b`. By induction, `succ^[k](a) = pred(b)` for some `k`,
giving `succ^[k+1](a) = b`.

The well-founded measure is the cardinality of `dom_N`-points in `[a, b']`,
which decreases when replacing `b'` with `pred(b')`. The key obstacle is that
`pred(b')` might not be in `dom_N`, requiring either a larger `N` or a
different WF argument at each recursive step.

**Status**: sorry — requires deeper omega chain analysis to establish the WF
termination argument. See `.handoff-phase4.md` for detailed discussion.
-/
noncomputable def limitDomSubtype_isSuccArchimedean (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs) _ (limitDomSubtype_succOrder A h_mcs h_discrete) := by
  letI := limitDomSubtype_succOrder A h_mcs h_discrete
  constructor
  intro a b hab
  -- Strategy: descend from b using pred, show each pred step is a dom_N element.
  -- Get stages where a and b first appear
  obtain ⟨na, hna⟩ := a.property
  obtain ⟨nb, hnb⟩ := b.property
  set N := max na nb
  have ha_N : a.val ∈ (omega_chain_val A h_mcs N).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_left na nb) hna
  have hb_N : b.val ∈ (omega_chain_val A h_mcs N).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_right na nb) hnb
  -- Strategy: strong induction on dom_N ∩ (a, b'].card with b' ∈ dom_N.
  -- At each step pred(b') < b', succ(pred(b')) = b', a ≤ pred(b').
  -- The count dom_N ∩ (a, pred(b')] = dom_N ∩ (a, b'] - 1
  -- because b'.val is in dom_N and in (pred(b'), b'] exclusively,
  -- and no dom_N elements in (pred(b').val, b'.val) (no limit_dom there).
  --
  -- Difficulty: the IH requires pred(b') ∈ dom_N, but pred(b') might
  -- not be in dom_N. When pred(b') ∈ dom_N, the proof works directly.
  -- When pred(b') ∉ dom_N, we need the "gap lemma": for consecutive
  -- dom_N elements q < r, ∃ n, Order.succ^[n] ⟨q,_⟩ = ⟨r,_⟩.
  --
  -- The gap lemma requires showing that the succ chain from q reaches r.
  -- This is equivalent to showing limit_dom ∩ [q, r) is finite in the
  -- discrete case, which follows from the guard conditions of the C5
  -- resolution: each succ step seals an interval, and pred(r) must be
  -- some succ^[k](q) (since every limit_dom element in [q, r) is of this
  -- form). See .handoff-succ-arch-2.md for detailed analysis.
  --
  -- Status: sorry — the gap lemma proof requires additional infrastructure
  -- to formalize the finiteness of limit_dom ∩ [q, r) for consecutive
  -- dom_N elements. The mathematical argument is clear but the
  -- well-founded termination measure is non-trivial to formalize.
  sorry

/-! ### Z-Isomorphism and FMCS on Int -/

/--
Z-isomorphism: `LimitDomSubtype A h_mcs ≃o ℤ`, conditional on discreteness.

Uses Mathlib's `orderIsoIntOfLinearSuccPredArch`, which requires `LinearOrder`,
`SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`, and
`Nonempty` — all available from the preceding constructions.
-/
noncomputable def discrete_iso (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    LimitDomSubtype A h_mcs ≃o ℤ :=
  letI := limitDomSubtype_succOrder A h_mcs h_discrete
  letI := limitDomSubtype_predOrder A h_mcs h_discrete
  letI := limitDomSubtype_isSuccArchimedean A h_mcs h_discrete
  orderIsoIntOfLinearSuccPredArch

/-- MCS assignment via the Z-isomorphism (discrete case). -/
noncomputable def discrete_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    ℤ → Set Formula :=
  fun n => limit_f A h_mcs ((discrete_iso A h_mcs h_discrete).symm n).val

/-- The integer corresponding to the origin `0 ∈ limit_dom` (discrete case). -/
noncomputable def discrete_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    ℤ :=
  (discrete_iso A h_mcs h_discrete) ⟨0, zero_mem_limit_dom A h_mcs⟩

/-- `discrete_f` at `discrete_zero` equals A (the root MCS). -/
theorem discrete_f_at_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    discrete_f A h_mcs h_discrete (discrete_zero A h_mcs h_discrete) = A := by
  unfold discrete_f discrete_zero
  simp [OrderIso.symm_apply_apply]
  exact limit_f_zero A h_mcs

/-- Every integer maps to an MCS via `discrete_f`. -/
theorem discrete_f_is_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (n : ℤ) : SetMaximalConsistent (discrete_f A h_mcs h_discrete n) := by
  unfold discrete_f
  exact limit_c0 A h_mcs _ ((discrete_iso A h_mcs h_discrete).symm n).property

/--
FMCS on ℤ (discrete case): the chronicle coherence properties `limit_forward_G`
and `limit_backward_H` are transported through `discrete_iso.symm`, which is
strictly monotone (as an OrderIso symm).
-/
noncomputable def discrete_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    FMCS ℤ where
  mcs := discrete_f A h_mcs h_discrete
  is_mcs := discrete_f_is_mcs A h_mcs h_discrete
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt_dom := (discrete_iso A h_mcs h_discrete).symm.strictMono h_lt
    exact limit_forward_G A h_mcs
      ((discrete_iso A h_mcs h_discrete).symm t).val
      ((discrete_iso A h_mcs h_discrete).symm t').val
      ((discrete_iso A h_mcs h_discrete).symm t).property
      ((discrete_iso A h_mcs h_discrete).symm t').property
      h_lt_dom φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt_dom := (discrete_iso A h_mcs h_discrete).symm.strictMono h_lt
    exact limit_backward_H A h_mcs
      ((discrete_iso A h_mcs h_discrete).symm t).val
      ((discrete_iso A h_mcs h_discrete).symm t').val
      ((discrete_iso A h_mcs h_discrete).symm t).property
      ((discrete_iso A h_mcs h_discrete).symm t').property
      h_lt_dom φ h_H

end Bimodal.Metalogic.BXCanonical.Chronicle
