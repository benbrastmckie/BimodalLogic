import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Order.SuccPred.LinearLocallyFinite
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Topology.Instances.NNReal.Lemmas
import Mathlib.Data.Rat.Cast.Order

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
def top_formula : Formula := Formula.bot.imp Formula.bot

/-- `U(⊤, ⊥)` — "next top", true iff there is an immediate successor. -/
def next_top : Formula := Formula.untl top_formula Formula.bot

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

/-! ## Box Stability on the Limit Domain

Box formulas are stable across all limit domain points: `Box φ ∈ limit_f(x) ↔ Box φ ∈ A`.
This is the chronicle analog of `box_stable_in_int_chain` from CanonicalModel.lean.

The proof uses S5 axioms:
- Forward: `temp_future` (□φ → G(□φ)) for x > 0, `modal_4` + `box_to_past` for x < 0
- Backward: contrapositive via `neg_box_to_box_neg_box` (S5 negative introspection)
-/

/--
Box stability on `limit_f`: for any `x ∈ limit_dom`, `Box φ ∈ limit_f(x) ↔ Box φ ∈ A`.
Since `limit_f(0) = A`, this says box formulas are uniform across the limit domain.
-/
theorem box_stable_in_limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    Formula.box φ ∈ limit_f A h_mcs x ↔ Formula.box φ ∈ A := by
  constructor
  · -- Backward: Box φ ∈ limit_f(x) → Box φ ∈ A
    intro h_box_x
    by_contra h_not_box_A
    -- ¬(Box φ) ∈ A
    have h_neg_box_A : (Formula.box φ).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box φ) with h | h
      · exact absurd h h_not_box_A
      · exact h
    -- Box(¬(Box φ)) ∈ A by S5 negative introspection
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ A :=
      SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs (neg_box_to_box_neg_box φ)) h_neg_box_A
    -- Propagate Box(¬(Box φ)) to limit_f(x)
    have h_box_neg_x : (Formula.box φ).neg ∈ limit_f A h_mcs x := by
      rcases lt_trichotomy 0 x with h_pos | rfl | h_neg
      · -- x > 0: use G propagation
        have h_G := SetMaximalConsistent.implication_property h_mcs
          (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box φ).neg)))
          h_box_neg
        rw [← limit_f_zero A h_mcs] at h_G
        have h_G' := limit_forward_G A h_mcs 0 x (zero_mem_limit_dom A h_mcs) hx h_pos
          (Formula.box (Formula.box φ).neg) h_G
        exact SetMaximalConsistent.implication_property (limit_c0 A h_mcs x hx)
          (theorem_in_mcs (limit_c0 A h_mcs x hx)
            (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg))) h_G'
      · -- x = 0: limit_f(0) = A
        rw [limit_f_zero]; exact h_neg_box_A
      · -- x < 0: use H propagation
        have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ A :=
          SetMaximalConsistent.implication_property h_mcs
            (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h_mcs
          (theorem_in_mcs h_mcs (box_to_past (Formula.box (Formula.box φ).neg))) h_box_box_neg
        rw [← limit_f_zero A h_mcs] at h_H
        have h_H' := limit_backward_H A h_mcs 0 x (zero_mem_limit_dom A h_mcs) hx h_neg
          (Formula.box (Formula.box φ).neg) h_H
        exact SetMaximalConsistent.implication_property (limit_c0 A h_mcs x hx)
          (theorem_in_mcs (limit_c0 A h_mcs x hx)
            (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg))) h_H'
    -- Contradiction: Box φ and ¬(Box φ) both in limit_f(x)
    exact set_consistent_not_both (limit_c0 A h_mcs x hx).1 (Formula.box φ) h_box_x h_box_neg_x
  · -- Forward: Box φ ∈ A → Box φ ∈ limit_f(x)
    intro h_box_A
    rcases lt_trichotomy 0 x with h_pos | rfl | h_neg
    · -- x > 0: use G propagation (temp_future: □φ → G(□φ))
      have h_G := SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.temp_future φ))) h_box_A
      rw [← limit_f_zero A h_mcs] at h_G
      exact limit_forward_G A h_mcs 0 x (zero_mem_limit_dom A h_mcs) hx h_pos
        (Formula.box φ) h_G
    · -- x = 0: limit_f(0) = A
      rw [limit_f_zero]; exact h_box_A
    · -- x < 0: use H propagation (modal_4: □φ → □□φ, box_to_past: □(□φ) → H(□φ))
      have h_box_box : Formula.box (Formula.box φ) ∈ A :=
        SetMaximalConsistent.implication_property h_mcs
          (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_A
      have h_H := SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs (box_to_past (Formula.box φ))) h_box_box
      rw [← limit_f_zero A h_mcs] at h_H
      exact limit_backward_H A h_mcs 0 x (zero_mem_limit_dom A h_mcs) hx h_neg
        (Formula.box φ) h_H

/--
Box stability on `cantor_f_dense`: `Box φ ∈ cantor_f_dense(q) ↔ Box φ ∈ A`.
Transport of `box_stable_in_limit_f` through the Cantor isomorphism.
-/
theorem box_stable_in_cantor_f_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_dense : ∀ x ∈ limit_dom A h_mcs, next_top.neg ∈ limit_f A h_mcs x)
    (φ : Formula) (q : Rat) :
    Formula.box φ ∈ cantor_f_dense A h_mcs h_dense q ↔ Formula.box φ ∈ A := by
  unfold cantor_f_dense
  exact box_stable_in_limit_f A h_mcs φ
    ((cantor_iso_dense A h_mcs h_dense).symm q).val
    ((cantor_iso_dense A h_mcs h_dense).symm q).property

/-! ## Dense BFMCS Construction

Build `cantor_bfmcs_dense : BFMCS Rat` from rooted chronicle families.

The key insight: the BFMCS requires families rooted at DIFFERENT box-equivalent
MCS's for `modal_backward`. Each family uses a SEPARATE chronicle (for the
box-equivalent MCS N), and `rooted_cantor_fmcs_dense N h_N h_dense_N s` shifts
N's chronicle so that `N` appears at time `s`.

The density hypothesis `h_box_dense : Formula.box next_top.neg ∈ A` (i.e.,
`□(F'T) ∈ A`) is STRONGER than `F'T ∈ A`. It is necessary because:
- Box-equivalence transfers `□(F'T)` to any N
- From `□(F'T) ∈ N`, we derive `F'T ∈ N` (via modal_t)
- Then N's chronicle is also dense, enabling its Cantor isomorphism

The case split in Phase 4 should use `□(F'T)` vs `¬□(F'T)` (not `F'T` vs `U(T,⊥)`).
By S5, if `F'T ∈ A` but `□(F'T) ∉ A`, then `¬□(F'T) ∈ A` and `□(¬□(F'T)) ∈ A`,
meaning some box-accessible world is discrete. This mixed case falls under the
non-dense branch (with sorry, like the discrete case).
-/

/--
From `□(F'T) ∈ N`, derive the density hypothesis for N's chronicle.
The proof: `□(F'T) → G(□(F'T))` (temp_future), then at each domain point
`□(F'T) → F'T` (modal_t). Similarly for past via `box_to_past`.
-/
theorem box_dense_gives_density (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_dense : Formula.box next_top.neg ∈ N) :
    ∀ x ∈ limit_dom N h_N, next_top.neg ∈ limit_f N h_N x := by
  intro x hx
  -- F'T ∈ N (from □(F'T) by modal_t)
  have h_ft_N : next_top.neg ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (DerivationTree.axiom [] _ (Axiom.modal_t next_top.neg)))
      h_box_dense
  -- G(□(F'T)) ∈ N (from □(F'T) by temp_future)
  have h_G_box : Formula.all_future (Formula.box next_top.neg) ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (DerivationTree.axiom [] _ (Axiom.temp_future next_top.neg)))
      h_box_dense
  -- H(□(F'T)) ∈ N (from □(F'T) → □□(F'T) → H(□(F'T)))
  have h_box_box : Formula.box (Formula.box next_top.neg) ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (DerivationTree.axiom [] _ (Axiom.modal_4 next_top.neg)))
      h_box_dense
  have h_H_box : Formula.all_past (Formula.box next_top.neg) ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (box_to_past (Formula.box next_top.neg))) h_box_box
  -- Now propagate to x ∈ limit_dom
  rcases lt_trichotomy 0 x with h_pos | rfl | h_neg
  · -- x > 0: G(□(F'T)) ∈ limit_f(0) = N, propagate via limit_forward_G
    rw [← limit_f_zero N h_N] at h_G_box
    have h_box_x := limit_forward_G N h_N 0 x (zero_mem_limit_dom N h_N) hx h_pos
      (Formula.box next_top.neg) h_G_box
    exact SetMaximalConsistent.implication_property (limit_c0 N h_N x hx)
      (theorem_in_mcs (limit_c0 N h_N x hx)
        (DerivationTree.axiom [] _ (Axiom.modal_t next_top.neg))) h_box_x
  · -- x = 0: limit_f(0) = N
    rw [limit_f_zero]; exact h_ft_N
  · -- x < 0: H(□(F'T)) ∈ limit_f(0) = N, propagate via limit_backward_H
    rw [← limit_f_zero N h_N] at h_H_box
    have h_box_x := limit_backward_H N h_N 0 x (zero_mem_limit_dom N h_N) hx h_neg
      (Formula.box next_top.neg) h_H_box
    exact SetMaximalConsistent.implication_property (limit_c0 N h_N x hx)
      (theorem_in_mcs (limit_c0 N h_N x hx)
        (DerivationTree.axiom [] _ (Axiom.modal_t next_top.neg))) h_box_x

/--
Shifted FMCS on Rat: `mcs t := cantor_f_dense(t + offset)`.
Helper for `rooted_cantor_fmcs_dense`.
-/
noncomputable def shifted_cantor_fmcs_dense' (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_dense_N : ∀ x ∈ limit_dom N h_N, next_top.neg ∈ limit_f N h_N x)
    (offset : Rat) : FMCS Rat where
  mcs t := cantor_f_dense N h_N h_dense_N (t + offset)
  is_mcs t := cantor_f_dense_is_mcs N h_N h_dense_N (t + offset)
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt' : t + offset < t' + offset := by linarith
    exact (cantor_fmcs_dense N h_N h_dense_N).forward_G (t + offset) (t' + offset) φ h_lt' h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt' : t' + offset < t + offset := by linarith
    exact (cantor_fmcs_dense N h_N h_dense_N).backward_H (t + offset) (t' + offset) φ h_lt' h_H

/--
Rooted FMCS on Rat (dense case): builds a chronicle for MCS N (with `□(F'T) ∈ N`
ensuring density), applies the Cantor isomorphism, and shifts to place N at time `s`.
-/
noncomputable def rooted_cantor_fmcs_dense (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_dense_N : Formula.box next_top.neg ∈ N) (s : Rat) : FMCS Rat :=
  let h_dense_N := box_dense_gives_density N h_N h_box_dense_N
  let cz := cantor_zero_dense N h_N h_dense_N
  -- Offset = cz - s, so mcs(s) = cantor_f_dense(s + (cz - s)) = cantor_f_dense(cz) = N
  shifted_cantor_fmcs_dense' N h_N h_dense_N (cz - s)

/--
The rooted FMCS at `s` has `mcs s = N` (the root MCS).
This works because the shift places `cantor_zero_dense` at `s`, and
`cantor_f_dense` at `cantor_zero_dense` equals N.
-/
theorem rooted_cantor_fmcs_dense_at_s (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_dense_N : Formula.box next_top.neg ∈ N) (s : Rat) :
    (rooted_cantor_fmcs_dense N h_N h_box_dense_N s).mcs s = N := by
  -- mcs s = cantor_f_dense(s + (cz - s)) = cantor_f_dense(cz) = N
  simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense']
  have h_eq : s + (cantor_zero_dense N h_N (box_dense_gives_density N h_N h_box_dense_N) - s) =
    cantor_zero_dense N h_N (box_dense_gives_density N h_N h_box_dense_N) := by ring
  rw [h_eq]
  exact cantor_f_dense_at_zero N h_N (box_dense_gives_density N h_N h_box_dense_N)

/--
Box stability for `rooted_cantor_fmcs_dense`:
`Box φ ∈ (rooted_cantor_fmcs_dense N h_N h_box s).mcs t ↔ Box φ ∈ N`.
-/
theorem box_stable_in_rooted_cantor_fmcs_dense (N : Set Formula)
    (h_N : SetMaximalConsistent N) (h_box_dense_N : Formula.box next_top.neg ∈ N)
    (φ : Formula) (s t : Rat) :
    Formula.box φ ∈ (rooted_cantor_fmcs_dense N h_N h_box_dense_N s).mcs t ↔
      Formula.box φ ∈ N := by
  simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense']
  exact box_stable_in_cantor_f_dense N h_N (box_dense_gives_density N h_N h_box_dense_N)
    φ (t + (cantor_zero_dense N h_N (box_dense_gives_density N h_N h_box_dense_N) - s))

/--
Bundle of FMCS families on Rat (dense case).

Requires `□(F'T) ∈ A` (box density), which is STRONGER than `F'T ∈ A`.
Each family is a `rooted_cantor_fmcs_dense N h_N h_box_N s` where N is
box-equivalent to A (hence `□(F'T) ∈ N` by box-equiv). Each N gets its
own chronicle, which is dense by `box_dense_gives_density`.

The modal forward/backward proofs mirror `bx_bfmcs` from RootScopedChain.lean:
- Forward: Box φ ∈ fam → Box φ ∈ A (box stability) → Box φ ∈ fam' → φ ∈ fam' (modal_t)
- Backward: contrapositive via bx_modal_witness — if ¬Box φ ∈ A, get v with ¬φ,
  v box-equiv to A, so rooted_cantor_fmcs_dense v.formulas has mcs(t) = v.formulas,
  giving φ ∈ v.formulas (from h_all) and ¬φ ∈ v.formulas (from witness), contradiction.
-/
noncomputable def cantor_bfmcs_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_dense : Formula.box next_top.neg ∈ A) :
    BFMCS Rat where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_N : Formula.box next_top.neg ∈ N) (s : Rat),
    (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
    fam = rooted_cantor_fmcs_dense N h_N h_box_N s }
  nonempty := ⟨rooted_cantor_fmcs_dense A h_mcs h_box_dense 0,
    A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', h_box_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_in_N : Formula.box φ ∈ N :=
      (box_stable_in_rooted_cantor_fmcs_dense N h_N h_box_N φ s t).mp h_box
    have h_box_A : Formula.box φ ∈ A := (h_eqN φ).mpr h_box_in_N
    have h_box_in_N' : Formula.box φ ∈ N' := (h_eqN' φ).mp h_box_A
    have h_box_t' : Formula.box φ ∈ (rooted_cantor_fmcs_dense N' h_N' h_box_N' s').mcs t :=
      (box_stable_in_rooted_cantor_fmcs_dense N' h_N' h_box_N' φ s' t).mpr h_box_in_N'
    exact SetMaximalConsistent.implication_property
      ((rooted_cantor_fmcs_dense N' h_N' h_box_N' s').is_mcs t)
      (theorem_in_mcs ((rooted_cantor_fmcs_dense N' h_N' h_box_N' s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
    -- Suffices: Box φ ∈ N (by box stability)
    suffices h_box_in_N : Formula.box φ ∈ N from
      (box_stable_in_rooted_cantor_fmcs_dense N h_N h_box_N φ s t).mpr h_box_in_N
    -- Suffices: Box φ ∈ A (by box-equiv)
    suffices h_box_A : Formula.box φ ∈ A from (h_eqN φ).mp h_box_A
    -- Contrapositive: suppose Box φ ∉ A
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    -- ◇(¬φ) ∈ A
    have h_diamond_neg : (Formula.neg φ).diamond ∈ A :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h_mcs
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    -- Modal witness: v box-equivalent to A with ¬φ ∈ v
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨A, h_mcs⟩ (Formula.neg φ) h_diamond_neg
    -- v is box-equivalent to A, so □(F'T) ∈ v
    have h_box_dense_v : Formula.box next_top.neg ∈ v.formulas :=
      (h_equiv next_top.neg).mp h_box_dense
    -- rooted_cantor_fmcs_dense v t is in families
    have h_fam_v_mem : rooted_cantor_fmcs_dense v.formulas v.is_mcs h_box_dense_v t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N)
          (h_box_N : Formula.box next_top.neg ∈ N) (s : Rat),
          (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
          fam = rooted_cantor_fmcs_dense N h_N h_box_N s } :=
      ⟨v.formulas, v.is_mcs, h_box_dense_v, t, fun ψ => h_equiv ψ, rfl⟩
    -- h_all gives φ ∈ rooted(v, t).mcs t = v.formulas
    have h_phi_v := h_all (rooted_cantor_fmcs_dense v.formulas v.is_mcs h_box_dense_v t) h_fam_v_mem
    rw [rooted_cantor_fmcs_dense_at_s] at h_phi_v
    -- Contradiction: φ and ¬φ both in v.formulas
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v h_neg_phi_v
  eval_family := rooted_cantor_fmcs_dense A h_mcs h_box_dense 0
  eval_family_mem := ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩

/-! ## Dense Restricted Coherence

Restricted temporal and Until/Since coherence for `cantor_bfmcs_dense`.
These are the three conditions needed by the parametric representation theorem.
-/

/--
Restricted temporal coherence for `cantor_bfmcs_dense`.
F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s) and symmetric for P.
Each family is a `rooted_cantor_fmcs_dense N h_N h_box_N s`, which internally
uses `cantor_f_dense N h_N h_dense_N`. The Cantor isomorphism makes all rationals
domain points, so `limit_F_resolution`/`limit_P_resolution` apply directly after
transfer through `cantor_iso_dense.symm`.
-/
theorem cantor_bfmcs_dense_restricted_tc (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_dense : Formula.box next_top.neg ∈ A)
    (root : Formula)
    (_ : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ (extendedDeferralClosure root).toList) :
    (cantor_bfmcs_dense A h_mcs h_box_dense).restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_dense_N := box_dense_gives_density N h_N h_box_N
  set iso := cantor_iso_dense N h_N h_dense_N
  set offset := cantor_zero_dense N h_N h_dense_N - s
  constructor
  · -- Forward F direction: F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)
    intro t φ _ h_F
    simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense'] at h_F ⊢
    have h_mem := (iso.symm (t + offset)).property
    have h_F' : φ.some_future ∈ limit_f N h_N (iso.symm (t + offset)).val := h_F
    obtain ⟨y, hy, hlt, hφy⟩ := limit_F_resolution N h_N (iso.symm (t + offset)).val h_mem φ h_F'
    refine ⟨iso ⟨y, hy⟩ - offset, ?_, ?_⟩
    · have h1 : iso (iso.symm (t + offset)) < iso ⟨y, hy⟩ := iso.strictMono hlt
      simp [OrderIso.apply_symm_apply] at h1
      linarith
    · show φ ∈ cantor_f_dense N h_N h_dense_N (iso ⟨y, hy⟩ - offset + offset)
      have h_eq : iso ⟨y, hy⟩ - offset + offset = iso ⟨y, hy⟩ := by ring
      rw [h_eq]
      show φ ∈ limit_f N h_N (iso.symm (iso ⟨y, hy⟩)).val
      simp [OrderIso.symm_apply_apply]
      exact hφy
  · -- Backward P direction: P(φ) ∈ fam.mcs(t) → ∃ s < t, φ ∈ fam.mcs(s)
    intro t φ _ h_P
    simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense'] at h_P ⊢
    have h_mem := (iso.symm (t + offset)).property
    have h_P' : φ.some_past ∈ limit_f N h_N (iso.symm (t + offset)).val := h_P
    obtain ⟨y, hy, hlt, hφy⟩ := limit_P_resolution N h_N (iso.symm (t + offset)).val h_mem φ h_P'
    refine ⟨iso ⟨y, hy⟩ - offset, ?_, ?_⟩
    · have h1 : iso ⟨y, hy⟩ < iso (iso.symm (t + offset)) := iso.strictMono hlt
      simp [OrderIso.apply_symm_apply] at h1
      linarith
    · show φ ∈ cantor_f_dense N h_N h_dense_N (iso ⟨y, hy⟩ - offset + offset)
      have h_eq : iso ⟨y, hy⟩ - offset + offset = iso ⟨y, hy⟩ := by ring
      rw [h_eq]
      show φ ∈ limit_f N h_N (iso.symm (iso ⟨y, hy⟩)).val
      simp [OrderIso.symm_apply_apply]
      exact hφy

/--
Restricted backward Until/Since coherence for `cantor_bfmcs_dense`.
The backward direction uses C4/C4' (limit_satisfies_c4/c4') to prove
that if ¬U(φ,ψ) ∈ f(t) and the Until witness pattern holds, we get
a contradiction via an intermediate point where the guard fails.
-/
theorem cantor_bfmcs_dense_restricted_buc (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_dense : Formula.box next_top.neg ∈ A) (root : Formula) :
    (cantor_bfmcs_dense A h_mcs h_box_dense).restricted_backward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_dense_N := box_dense_gives_density N h_N h_box_N
  set iso := cantor_iso_dense N h_N h_dense_N
  set offset := cantor_zero_dense N h_N h_dense_N - s
  constructor
  · -- Until backward: contrapositive via C4
    intro t φ ψ _ ⟨u, htu, hφu, h_guard⟩
    by_contra h_not_until
    simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense'] at h_not_until hφu h_guard
    have h_neg_until : (Formula.untl φ ψ).neg ∈ cantor_f_dense N h_N h_dense_N (t + offset) := by
      rcases SetMaximalConsistent.negation_complete (cantor_f_dense_is_mcs N h_N h_dense_N (t + offset))
        (Formula.untl φ ψ) with h | h
      · exact absurd h h_not_until
      · exact h
    set xt := iso.symm (t + offset); set xu := iso.symm (u + offset)
    obtain ⟨z, hz, hxtz, hzxu, hψneg⟩ := limit_satisfies_c4 N h_N
      xt.val xu.val xt.property xu.property
      (iso.symm.strictMono (show t + offset < u + offset by linarith))
      ψ φ h_neg_until hφu
    have htr : t < iso ⟨z, hz⟩ - offset := by
      have h1 : iso (iso.symm (t + offset)) < iso ⟨z, hz⟩ :=
        iso.strictMono (show iso.symm (t + offset) < ⟨z, hz⟩ from hxtz)
      rw [OrderIso.apply_symm_apply] at h1; linarith
    have hru : iso ⟨z, hz⟩ - offset < u := by
      have h1 : iso ⟨z, hz⟩ < iso (iso.symm (u + offset)) :=
        iso.strictMono (show ⟨z, hz⟩ < iso.symm (u + offset) from hzxu)
      rw [OrderIso.apply_symm_apply] at h1; linarith
    have hψneg' : ψ.neg ∈ cantor_f_dense N h_N h_dense_N (iso ⟨z, hz⟩) := by
      show ψ.neg ∈ limit_f N h_N (iso.symm (iso ⟨z, hz⟩)).val
      simp [OrderIso.symm_apply_apply]; exact hψneg
    rw [show (iso ⟨z, hz⟩ : ℚ) = iso ⟨z, hz⟩ - offset + offset by ring] at hψneg'
    exact set_consistent_not_both (cantor_f_dense_is_mcs N h_N h_dense_N _).1 ψ
      (h_guard _ htr hru) hψneg'
  · -- Since backward: contrapositive via C4'
    intro t φ ψ _ ⟨u, hut, hφu, h_guard⟩
    by_contra h_not_since
    simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense'] at h_not_since hφu h_guard
    have h_neg_since : (Formula.snce φ ψ).neg ∈ cantor_f_dense N h_N h_dense_N (t + offset) := by
      rcases SetMaximalConsistent.negation_complete (cantor_f_dense_is_mcs N h_N h_dense_N (t + offset))
        (Formula.snce φ ψ) with h | h
      · exact absurd h h_not_since
      · exact h
    set xt := iso.symm (t + offset); set xu := iso.symm (u + offset)
    obtain ⟨z, hz, huxz, hzxt, hψneg⟩ := limit_satisfies_c4' N h_N
      xt.val xu.val xt.property xu.property
      (iso.symm.strictMono (show u + offset < t + offset by linarith))
      ψ φ h_neg_since hφu
    have huz : u < iso ⟨z, hz⟩ - offset := by
      have h1 : iso (iso.symm (u + offset)) < iso ⟨z, hz⟩ :=
        iso.strictMono (show iso.symm (u + offset) < ⟨z, hz⟩ from huxz)
      rw [OrderIso.apply_symm_apply] at h1; linarith
    have hzt : iso ⟨z, hz⟩ - offset < t := by
      have h1 : iso ⟨z, hz⟩ < iso (iso.symm (t + offset)) :=
        iso.strictMono (show ⟨z, hz⟩ < iso.symm (t + offset) from hzxt)
      rw [OrderIso.apply_symm_apply] at h1; linarith
    have hψneg' : ψ.neg ∈ cantor_f_dense N h_N h_dense_N (iso ⟨z, hz⟩) := by
      show ψ.neg ∈ limit_f N h_N (iso.symm (iso ⟨z, hz⟩)).val
      simp [OrderIso.symm_apply_apply]; exact hψneg
    rw [show (iso ⟨z, hz⟩ : ℚ) = iso ⟨z, hz⟩ - offset + offset by ring] at hψneg'
    exact set_consistent_not_both (cantor_f_dense_is_mcs N h_N h_dense_N _).1 ψ
      (h_guard _ huz hzt) hψneg'

/--
Restricted forward Until/Since coherence for `cantor_bfmcs_dense`.
The forward direction uses `limit_satisfies_c5_strong`/`limit_satisfies_c5'_strong`
to find the Until/Since witness, and the guard follows from the Cantor iso
making all rationals domain points (so the guard covers D = Rat).
-/
theorem cantor_bfmcs_dense_restricted_fuc (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_dense : Formula.box next_top.neg ∈ A) (root : Formula) :
    (cantor_bfmcs_dense A h_mcs h_box_dense).restricted_forward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_dense_N := box_dense_gives_density N h_N h_box_N
  set iso := cantor_iso_dense N h_N h_dense_N
  set offset := cantor_zero_dense N h_N h_dense_N - s
  constructor
  · -- Until forward: untl(φ,ψ) ∈ fam.mcs t → ∃ u > t, φ ∈ fam.mcs u ∧ guard
    intro t φ ψ _ h_until
    simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense'] at h_until ⊢
    set xt := iso.symm (t + offset)
    obtain ⟨y, hy, hxty, hφy, h_guard⟩ := limit_satisfies_c5_strong N h_N
      xt.val xt.property ψ φ h_until
    refine ⟨iso ⟨y, hy⟩ - offset, ?_, ?_, ?_⟩
    · have h1 : iso (iso.symm (t + offset)) < iso ⟨y, hy⟩ :=
        iso.strictMono (show iso.symm (t + offset) < ⟨y, hy⟩ from hxty)
      rw [OrderIso.apply_symm_apply] at h1; linarith
    · show φ ∈ cantor_f_dense N h_N h_dense_N (iso ⟨y, hy⟩ - offset + offset)
      rw [show iso ⟨y, hy⟩ - offset + offset = iso ⟨y, hy⟩ from by ring]
      show φ ∈ limit_f N h_N (iso.symm (iso ⟨y, hy⟩)).val
      simp [OrderIso.symm_apply_apply]; exact hφy
    · -- Guard: all rationals between t and the witness have ψ in their MCS.
      -- Every rational maps through iso.symm to a limit_dom point, and the
      -- C5 guard covers all limit_dom points in the interval.
      intro r htr hru
      have h_lt1 : xt < iso.symm (r + offset) :=
        iso.symm.strictMono (show t + offset < r + offset by linarith)
      have h_lt2 : iso.symm (r + offset) < (⟨y, hy⟩ : LimitDomSubtype N h_N) := by
        rw [show (⟨y, hy⟩ : LimitDomSubtype N h_N) = iso.symm (iso ⟨y, hy⟩) from
          (OrderIso.symm_apply_apply iso ⟨y, hy⟩).symm]
        exact iso.symm.strictMono (show r + offset < iso ⟨y, hy⟩ by linarith)
      exact h_guard (iso.symm (r + offset)).val (iso.symm (r + offset)).property h_lt1 h_lt2
  · -- Since forward: snce(φ,ψ) ∈ fam.mcs t → ∃ u < t, φ ∈ fam.mcs u ∧ guard
    intro t φ ψ _ h_since
    simp only [rooted_cantor_fmcs_dense, shifted_cantor_fmcs_dense'] at h_since ⊢
    set xt := iso.symm (t + offset)
    obtain ⟨y, hy, hyxt, hφy, h_guard⟩ := limit_satisfies_c5'_strong N h_N
      xt.val xt.property ψ φ h_since
    refine ⟨iso ⟨y, hy⟩ - offset, ?_, ?_, ?_⟩
    · have h1 : iso ⟨y, hy⟩ < iso (iso.symm (t + offset)) :=
        iso.strictMono (show (⟨y, hy⟩ : LimitDomSubtype N h_N) < iso.symm (t + offset) from hyxt)
      rw [OrderIso.apply_symm_apply] at h1; linarith
    · show φ ∈ cantor_f_dense N h_N h_dense_N (iso ⟨y, hy⟩ - offset + offset)
      rw [show iso ⟨y, hy⟩ - offset + offset = iso ⟨y, hy⟩ from by ring]
      show φ ∈ limit_f N h_N (iso.symm (iso ⟨y, hy⟩)).val
      simp [OrderIso.symm_apply_apply]; exact hφy
    · -- Guard: all rationals between the witness and t have ψ in their MCS.
      intro r hyr hrt
      have h_lt1 : (⟨y, hy⟩ : LimitDomSubtype N h_N) < iso.symm (r + offset) := by
        rw [show (⟨y, hy⟩ : LimitDomSubtype N h_N) = iso.symm (iso ⟨y, hy⟩) from
          (OrderIso.symm_apply_apply iso ⟨y, hy⟩).symm]
        exact iso.symm.strictMono (show iso ⟨y, hy⟩ < r + offset by linarith)
      have h_lt2 : iso.symm (r + offset) < xt :=
        iso.symm.strictMono (show r + offset < t + offset by linarith)
      exact h_guard (iso.symm (r + offset)).val (iso.symm (r + offset)).property h_lt1 h_lt2

/-! ## Dense Countermodel

The main integration theorem for the dense case: constructs a countermodel
from any MCS containing ¬φ and □(F'T), using the Cantor-based chronicle
construction.
-/

/--
Dense countermodel: given MCS A with `¬φ ∈ A` and `□(F'T) ∈ A`,
build a countermodel on `Rat` where `φ` is false.

Uses `cantor_bfmcs_dense` (sorry-free BFMCS) with the three restricted
coherence conditions. The eval family is `rooted_cantor_fmcs_dense A h_mcs h_box_dense 0`
which has `mcs 0 = A`, so `¬φ ∈ eval_family.mcs 0`.
-/
theorem dd_countermodel_chronicle_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_dense : Formula.box next_top.neg ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  refine ⟨Rat, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Rat, ParametricCanonicalTaskModel Rat,
    ShiftClosedParametricCanonicalOmega (cantor_bfmcs_dense A h_mcs h_box_dense),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (rooted_cantor_fmcs_dense A h_mcs h_box_dense 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨rooted_cantor_fmcs_dense A h_mcs h_box_dense 0,
       ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (rooted_cantor_fmcs_dense A h_mcs h_box_dense 0).mcs 0 := by
    rw [rooted_cantor_fmcs_dense_at_s]; exact h_neg_in
  exact fully_restricted_parametric_representation_from_neg_membership
    (cantor_bfmcs_dense A h_mcs h_box_dense) φ
    (cantor_bfmcs_dense_restricted_tc A h_mcs h_box_dense φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (cantor_bfmcs_dense_restricted_buc A h_mcs h_box_dense φ)
    (cantor_bfmcs_dense_restricted_fuc A h_mcs h_box_dense φ)
    φ (self_mem_subformulaClosure φ)
    (rooted_cantor_fmcs_dense A h_mcs h_box_dense 0)
    ⟨A, h_mcs, h_box_dense, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/--
Sorry-backed discrete countermodel stub. Used in the non-dense branch of
bx_completeness. Requires constructing a BFMCS on ℤ (analogous to
`cantor_bfmcs_dense` for the dense case on ℚ), using `discrete_fmcs`
and `discrete_iso` to transport the chronicle coherence properties
through the Z-isomorphism. Prior-UZ axioms and IsSuccArchimedean
infrastructure are now in place; the remaining work is the BFMCS
construction and parametric representation on ℤ.
-/
theorem dd_countermodel_chronicle_nondense_sorry (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_not_box_dense : (Formula.box next_top.neg).neg ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  sorry

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
When `limitDomSubtype_succOrder` is registered via `letI`, `Order.succ` is
definitionally equal to `limitDomSubtype_succ`. This is because `SuccOrder.ofSuccLeIff`
stores the provided function directly as `succ`.
-/
theorem order_succ_eq_limitDomSubtype_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (x : LimitDomSubtype A h_mcs) :
    @Order.succ _ _ (limitDomSubtype_succOrder A h_mcs h_discrete) x =
      limitDomSubtype_succ A h_mcs h_discrete x := rfl

/--
When `limitDomSubtype_predOrder` is registered via `letI`, `Order.pred` is
definitionally equal to `limitDomSubtype_pred`. This is because `PredOrder.ofLePredIff`
stores the provided function directly as `pred`.
-/
theorem order_pred_eq_limitDomSubtype_pred (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (x : LimitDomSubtype A h_mcs) :
    @Order.pred _ _ (limitDomSubtype_predOrder A h_mcs h_discrete) x =
      limitDomSubtype_pred A h_mcs h_discrete x := rfl

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
`pred(succ(a)) = a` in the discrete case: the predecessor of the successor
is the identity. Mirror of `limitDomSubtype_succ_pred`. Follows because
`a < succ(a)` and `pred(succ(a))` is the greatest domain point < `succ(a)`.
Since there are no domain points between `a` and `succ(a)` (by the successor
property), `pred(succ(a)) = a`.
-/
theorem limitDomSubtype_pred_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a : LimitDomSubtype A h_mcs) :
    limitDomSubtype_pred A h_mcs h_discrete
      (limitDomSubtype_succ A h_mcs h_discrete a) = a := by
  set sa := limitDomSubtype_succ A h_mcs h_discrete a
  set psa := limitDomSubtype_pred A h_mcs h_discrete sa
  apply le_antisymm
  · -- pred(succ(a)) ≤ a: by contradiction.
    -- If a < psa, then a < psa < succ(a), contradicting the successor property.
    by_contra h_not_le
    push_neg at h_not_le
    -- a < psa, so succ(a) ≤ psa (from succ_le_iff: succ(a) ≤ b ↔ a < b)
    have h_sa_le_psa : sa ≤ psa :=
      (limitDomSubtype_succ_le_iff A h_mcs h_discrete a psa).mpr h_not_le
    -- But also psa < sa (pred(succ(a)) < succ(a))
    have h_psa_lt_sa : psa < sa :=
      (limitDomSubtype_le_pred_iff A h_mcs h_discrete psa sa).mp le_rfl
    exact lt_irrefl sa (lt_of_le_of_lt h_sa_le_psa h_psa_lt_sa)
  · -- a ≤ pred(succ(a)): from PredOrder property and a < succ(a)
    rw [show a ≤ psa ↔ a < sa from limitDomSubtype_le_pred_iff A h_mcs h_discrete a sa]
    -- a < succ(a) follows from the succ_le_iff: succ(a) ≤ b ↔ a < b
    -- Taking b = succ(a): succ(a) ≤ succ(a) ↔ a < succ(a), so a < succ(a)
    exact (limitDomSubtype_succ_le_iff A h_mcs h_discrete a sa).mp le_rfl

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
Succ-orbit convexity: if `a ≤ b ≤ succ^[n] a`, then `b = succ^[k] a` for some `k ≤ n`.
This follows from the fact that between consecutive succ-iterates there are no domain
points, so `b` must coincide with one of them.
-/
private theorem succ_orbit_convex (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) (n : ℕ)
    (h_le : a ≤ b)
    (h_ub : b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[n] a) :
    ∃ k ≤ n, (limitDomSubtype_succ A h_mcs h_discrete)^[k] a = b := by
  set s := limitDomSubtype_succ A h_mcs h_discrete
  induction n with
  | zero =>
    simp only [Function.iterate_zero, id_eq] at h_ub
    exact ⟨0, le_rfl, le_antisymm h_le h_ub⟩
  | succ n ih =>
    rcases le_or_gt b (s^[n] a) with h_le_n | h_gt_n
    · obtain ⟨k, hkn, hk⟩ := ih h_le_n
      exact ⟨k, Nat.le_succ_of_le hkn, hk⟩
    · have h_succ_le : s (s^[n] a) ≤ b :=
        (limitDomSubtype_succ_le_iff A h_mcs h_discrete (s^[n] a) b).mpr h_gt_n
      have h_iter_succ : s^[n + 1] a = s (s^[n] a) :=
        Function.iterate_succ_apply' s n a
      rw [h_iter_succ] at h_ub
      exact ⟨n + 1, le_rfl, by rw [h_iter_succ]; exact (le_antisymm h_ub h_succ_le).symm⟩

/-! ## IsSuccArchimedean for LimitDomSubtype

In the discrete case, `LimitDomSubtype` satisfies `IsSuccArchimedean`: for any
`a ≤ b`, iterating `succ` from `a` eventually reaches `b`.

### Proof strategy: stage induction

Rather than reasoning about convergence in ℝ, we induct on the omega-chain stage N.
At stage N, dom(N) is a finite set of rationals. The statement is: for any two
limit_dom points a ≤ b that are both in dom(N), succ^[k](a) = b for some k, where
succ is the full limit_dom successor.

- **Base (N=0)**: dom(0) = {0}, so a = b, k = 0.
- **Step (N→N+1)**: At most one new point z enters. Case split:
  - Both a, b ∈ dom(N): apply IH.
  - a = z (new), b ∈ dom(N): z is between dom(N) points w, w_next (adjacent).
    IH gives succ^[m](w) = w_next. Orbit convexity factors through z.
  - a ∈ dom(N), b = z (new): IH gives succ^[k](a) = w_next ≥ z.
    Orbit convexity gives j with succ^[j](a) = z.
  - Both new: a = b by dom_new_unique.
-/

/--
Stage induction: for any N and any a, b in dom(N) with a ≤ b, there exists k
such that `succ^[k](a) = b` in the full limit_dom ordering.
-/
private theorem succ_reaches_dom_N (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (N : ℕ) (a b : LimitDomSubtype A h_mcs)
    (ha : a.val ∈ (omega_chain_val A h_mcs N).dom)
    (hb : b.val ∈ (omega_chain_val A h_mcs N).dom)
    (hab : a ≤ b) :
    ∃ k, (limitDomSubtype_succ A h_mcs h_discrete)^[k] a = b := by
  induction N generalizing a b with
  | zero =>
    -- dom(0) = {0}, so a.val = 0 and b.val = 0, hence a = b
    simp only [omega_chain_val, omega_chain, singleton_chronicle, singleton_dom,
      Finset.mem_singleton] at ha hb
    have : a = b := Subtype.ext (by rw [ha, hb])
    exact ⟨0, this⟩
  | succ N ih =>
    -- Case split: are a, b in dom(N) or is one the new point?
    by_cases ha_old : a.val ∈ (omega_chain_val A h_mcs N).dom
    · by_cases hb_old : b.val ∈ (omega_chain_val A h_mcs N).dom
      · -- Case 1: both in dom(N). Apply IH.
        exact ih a b ha_old hb_old hab
      · -- Case 3: a ∈ dom(N), b = new point at stage N+1.
        -- b is between dom(N) points w ≤ w_next, or beyond max/below min.
        -- Since a ≤ b and a ∈ dom(N), we need b ≥ a.
        -- b ∉ dom(N), but b ∈ dom(N+1). b is the unique new point.
        -- Find the adjacent dom(N) pair (w, w_next) that brackets b.
        -- If b > max(dom(N)): IH gives succ^[k](a) = max(dom(N)).
        --   Then we need succ reaches from max to b. This is the hard boundary case.
        -- If b < min(dom(N)): impossible since a ∈ dom(N) and a ≤ b.
        -- If b is between w and w_next (adjacent in dom(N)):
        --   IH gives succ^[k](a) = w_next. Since a ≤ b < w_next,
        --   orbit convexity gives j with succ^[j](a) = b.
        -- Use omega_chain_dom_mono to get a in dom(N+1)
        have ha_new : a.val ∈ (omega_chain_val A h_mcs (N + 1)).dom :=
          omega_chain_dom_mono A h_mcs N ha_old
        -- We know b ∈ dom(N+1) \ dom(N). Check if b is between two dom(N) points.
        have h_dom_ne : (omega_chain_val A h_mcs N).dom.Nonempty :=
          ⟨a.val, ha_old⟩
        -- b.val is in dom(N+1) but not in dom(N).
        -- Check: is b.val > max(dom(N))?
        set max_N := (omega_chain_val A h_mcs N).dom.max' h_dom_ne with max_N_def
        by_cases hb_above_max : max_N < b.val
        · -- Boundary case: b above max(dom(N)).
          -- IH gives succ^[k](a) = ⟨max_N, ...⟩.
          have h_max_mem : max_N ∈ (omega_chain_val A h_mcs N).dom :=
            Finset.max'_mem _ h_dom_ne
          have h_max_limit : max_N ∈ limit_dom A h_mcs := ⟨N, h_max_mem⟩
          have h_a_le_max : a ≤ ⟨max_N, h_max_limit⟩ := by
            show a.val ≤ max_N
            exact Finset.le_max' _ a.val ha_old
          obtain ⟨k₁, hk₁⟩ := ih a ⟨max_N, h_max_limit⟩ ha_old h_max_mem h_a_le_max
          -- Now need: ∃ k₂, succ^[k₂](⟨max_N,...⟩) = b.
          -- succ(⟨max_N,...⟩) is the next limit_dom point after max_N.
          -- By succ_le_iff, since max_N < b.val, succ(max_N_sub) ≤ b.
          -- If succ(max_N_sub) = b: done with k₁ + 1.
          -- If succ(max_N_sub) < b: succ(max_N_sub) is a limit_dom point
          --   in (max_N, b.val). It's in dom(M) for some M.
          --   It's NOT in dom(N) (since max_N is the maximum).
          --   By dom_new_unique, it must be b (since b is the unique new
          --   dom(N+1)\dom(N) point, and succ(max_N_sub) ∈ limit_dom means
          --   it's in some dom(M)... but we can't assume it's in dom(N+1)).
          -- Actually, we know succ(max_N_sub) ≤ b. And a ≤ b with a ≤ max_N_sub.
          -- We have succ^[k₁](a) = max_N_sub. Need succ^[k₁ + k₂](a) = b for some k₂.
          -- It suffices to show b ≤ succ^[k₂](max_N_sub) for some k₂, then use orbit convexity.
          -- Actually, let's use succ_orbit_convex directly:
          -- We need ∃ m, b ≤ succ^[m](a). Then orbit convexity gives j with succ^[j](a) = b.
          -- succ^[k₁](a) = max_N_sub. succ^[k₁+1](a) = succ(max_N_sub).
          -- succ(max_N_sub) ≤ b ↔ max_N_sub < b ↔ max_N < b.val. ✓
          -- Need: is b ≤ succ(max_N_sub)?
          -- succ(max_N_sub) is some limit_dom point > max_N.
          -- b is also > max_N and b ∈ limit_dom.
          -- Is succ(max_N_sub) ≤ b or > b?
          -- succ(max_N_sub) ≤ b OR b < succ(max_N_sub).
          -- If b < succ(max_N_sub): b is a limit_dom point between max_N and succ(max_N_sub).
          --   But limit_dom_has_succ says no limit_dom between max_N and succ(max_N).
          --   So b can't be between them. Contradiction.
          -- Therefore succ(max_N_sub) ≤ b. But also succ(max_N_sub) ≥ b (by... not necessarily).
          -- Actually: succ(max_N_sub) > max_N. And b > max_N. No limit_dom between max_N
          --   and succ(max_N_sub). b ∈ limit_dom with b > max_N. So b ≥ succ(max_N_sub).
          -- And succ(max_N_sub) ≤ b (from succ_le_iff: max_N < b means succ ≤ b).
          -- These give succ(max_N_sub) ≤ b and b ≥ succ(max_N_sub). Both say the same thing!
          -- But we also need b ≤ succ(max_N_sub) to use orbit convexity.
          -- Hmm, we only know succ(max_N_sub) ≤ b. To get b ≤ succ(max_N_sub) (equality):
          -- succ(max_N_sub) is the nearest limit_dom > max_N. b is limit_dom > max_N.
          -- So succ(max_N_sub) ≤ b. If succ(max_N_sub) < b: then succ(max_N_sub) is between
          --   max_N and b. succ(max_N_sub) ∈ limit_dom, succ(max_N_sub) ∉ dom(N) (since > max_N).
          --   succ(max_N_sub) ∈ dom(M) for some M. If M ≤ N+1: succ(max_N_sub) ∈ dom(N+1).
          --   Since succ(max_N_sub) ∉ dom(N) and b ∉ dom(N), and both ∈ dom(N+1)\dom(N):
          --   omega_chain_dom_new_unique gives succ(max_N_sub) = b. Contradicts < b.
          --   If M > N+1: succ(max_N_sub) ∉ dom(N+1). But we don't know this.
          -- We need a different argument. Let's try: b is in dom(N+1), and succ(max_N_sub)
          --   is the nearest limit_dom point after max_N. If b ∈ dom(N+1) with b > max_N,
          --   and max_N ∈ dom(N+1), then succ(max_N_sub) ≤ b (by succ_le_iff). And if
          --   succ(max_N_sub) = b: done. If succ(max_N_sub) < b: then between max_N and b
          --   in limit_dom there is succ(max_N_sub). No limit_dom between max_N and
          --   succ(max_N_sub). But succ(max_N_sub) < b ∈ limit_dom. So limit_dom has a point
          --   succ(max_N_sub) ∈ (max_N, b). This point is > max_N so ∉ dom(N).
          --   It's in limit_dom, so ∈ dom(M) for some M.
          --   We can't directly conclude succ(max_N_sub) ∈ dom(N+1).
          -- Let me try orbit convexity differently.
          -- succ^[k₁+1](a) = succ(max_N_sub) ≤ b.
          -- If succ(max_N_sub) = b: ⟨k₁+1, rfl⟩ works.
          -- If succ(max_N_sub) < b: apply orbit convexity is wrong direction.
          -- We need succ^[m](a) ≥ b for orbit convexity.
          -- This approach doesn't directly give us b ≤ succ^[m](a).
          -- Let me use the direct argument with limit_dom_has_succ.
          -- succ(max_N_sub) is the next limit_dom after max_N. No limit_dom between.
          -- b > max_N and b ∈ limit_dom. So b ≥ succ(max_N_sub).
          -- But succ(max_N_sub) ≤ b. If strict: contradiction with "no limit_dom between
          --   max_N and succ(max_N_sub)"? No, b is not between max_N and succ(max_N_sub)
          --   if b ≥ succ(max_N_sub).
          -- Hmm. We just know succ(max_N_sub) ≤ b. We need ≥ too.
          -- Let's try: no limit_dom between max_N and succ(max_N_sub).
          --   b > max_N, b ∈ limit_dom. So b ≥ succ(max_N_sub).
          -- succ(max_N_sub) ≤ b from succ_le_iff.
          -- So b ≥ succ(max_N_sub) and succ(max_N_sub) ≤ b. Both say b ≥ succ(max_N_sub).
          -- We need b = succ(max_N_sub) or to continue iterating.
          -- Actually, succ(max_N_sub) ≤ b gives us b ≤ succ^[k₁+1](a) → b via:
          -- Wait, succ^[k₁+1](a) = succ(max_N_sub). And succ(max_N_sub) ≤ b.
          -- We need b ≤ succ^[m](a) for SOME m, not succ^[k₁+1](a) ≤ b.
          -- The issue is: succ keeps going past b potentially. If succ(max_N_sub) ≤ b,
          --   that means max_N_sub < b (which we know). It doesn't help.
          -- I think for this boundary case we need a separate argument.
          -- Key: b > max_N. b ∈ limit_dom. No limit_dom in (max_N, succ(max_N_sub)).
          -- b ∈ limit_dom ∩ (max_N, ∞). So b ≥ succ(max_N_sub).
          -- succ^[k₁+1](a) = succ(max_N_sub) ≤ b.
          -- If succ(max_N_sub) = b: k = k₁ + 1 works.
          -- If succ(max_N_sub) < b: continue iterating. But this is the original problem!
          -- Unless we can show succ(max_N_sub) = b using dom_new_unique.
          -- succ(max_N_sub) is limit_dom point > max_N. It's ∉ dom(N) (since > max_N).
          -- b ∉ dom(N). Both in limit_dom. If BOTH in dom(N+1):
          --   omega_chain_dom_new_unique gives succ(max_N_sub).val = b.val. Done!
          -- Is succ(max_N_sub) in dom(N+1)?
          -- Not necessarily! succ(max_N_sub) might enter at a later stage.
          -- So this approach has a gap for the boundary case.
          -- Let me just use sorry for now and handle this case separately.
          sorry
        · -- b.val ≤ max_N. So b is at or below max(dom(N)).
          -- Since b ∉ dom(N), b ∈ dom(N+1) \ dom(N).
          -- b.val ≤ max_N. There exists some dom(N) point ≥ b.val (namely max_N).
          -- Also, a ∈ dom(N) and a ≤ b.
          -- b is between some adjacent dom(N) pair or below min(dom(N)).
          -- Check: is b.val < min(dom(N))? Impossible since a ≤ b and a ∈ dom(N).
          set min_N := (omega_chain_val A h_mcs N).dom.min' h_dom_ne with min_N_def
          have h_a_ge_min : min_N ≤ a.val := Finset.min'_le _ a.val ha_old
          have h_b_ge_min : min_N ≤ b.val := le_trans h_a_ge_min hab
          -- b.val ∈ [min_N, max_N] and b.val ∉ dom(N).
          -- Find adjacent pair (w, w_next) in dom(N) with w < b.val < w_next.
          -- Since b.val ≤ max_N and b.val ≥ min_N and b.val ∉ dom(N):
          -- First find some dom(N) point ≤ b.val:
          push_neg at hb_above_max  -- hb_above_max : b.val ≤ max_N
          -- We have min_N ≤ b.val ≤ max_N and b.val ∉ dom(N)
          -- Find w = max of {d ∈ dom(N) | d ≤ b.val}
          haveI : DecidablePred (fun d => d ≤ b.val) := fun d => inferInstance
          set L_set := (omega_chain_val A h_mcs N).dom.filter (· ≤ b.val) with L_set_def
          have hL_ne : L_set.Nonempty := by
            refine ⟨a.val, Finset.mem_filter.mpr ⟨ha_old, hab⟩⟩
          set R_set := (omega_chain_val A h_mcs N).dom.filter (b.val < ·) with R_set_def
          -- max_N ≥ b.val. If max_N = b.val: b.val ∈ dom(N), contradiction.
          -- So max_N > b.val (since b ∉ dom(N) and max_N ≥ b.val).
          have h_max_gt_b : max_N > b.val := by
            rcases lt_or_eq_of_le hb_above_max with h | h
            · exact h
            · exact absurd (h ▸ Finset.max'_mem _ h_dom_ne) hb_old
          have hR_ne : R_set.Nonempty := by
            refine ⟨max_N, Finset.mem_filter.mpr ⟨Finset.max'_mem _ h_dom_ne, h_max_gt_b⟩⟩
          set w := L_set.max' hL_ne with w_def
          set w_next := R_set.min' hR_ne with w_next_def
          have hw_mem : w ∈ (omega_chain_val A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).1
          have hw_le_b : w ≤ b.val :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).2
          have hwn_mem : w_next ∈ (omega_chain_val A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).1
          have hb_lt_wn : b.val < w_next :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).2
          have hw_lt_b : w < b.val := by
            rcases lt_or_eq_of_le hw_le_b with h | h
            · exact h
            · exact absurd (h ▸ hw_mem) hb_old
          have hw_lt_wn : w < w_next := lt_trans hw_lt_b hb_lt_wn
          -- w and w_next are in limit_dom
          have hw_limit : w ∈ limit_dom A h_mcs := ⟨N, hw_mem⟩
          have hwn_limit : w_next ∈ limit_dom A h_mcs := ⟨N, hwn_mem⟩
          -- IH: succ^[k](a_sub) = w_next_sub
          have h_a_le_wn : a ≤ (⟨w_next, hwn_limit⟩ : LimitDomSubtype A h_mcs) :=
            show a.val ≤ w_next from le_of_lt (lt_of_le_of_lt hab hb_lt_wn)
          obtain ⟨k₁, hk₁⟩ := ih a ⟨w_next, hwn_limit⟩ ha_old hwn_mem h_a_le_wn
          -- Now: succ^[k₁](a) = ⟨w_next, hwn_limit⟩
          -- We have a ≤ b < w_next and succ^[k₁](a) = w_next_sub ≥ b.
          -- By orbit convexity: ∃ j ≤ k₁, succ^[j](a) = b.
          have hb_le_iter : b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[k₁] a := by
            rw [hk₁]; exact le_of_lt hb_lt_wn
          exact (succ_orbit_convex A h_mcs h_discrete a b k₁ hab hb_le_iter).imp
            fun j ⟨_, hj⟩ => hj
    · by_cases hb_old : b.val ∈ (omega_chain_val A h_mcs N).dom
      · -- Case 2: a = new point at stage N+1, b ∈ dom(N).
        -- a ∉ dom(N), a ∈ dom(N+1). b ∈ dom(N).
        -- a is between dom(N) points or at boundary.
        -- Since a ≤ b and b ∈ dom(N):
        --   If a < min(dom(N)): a is below all dom(N) points. Need succ^[k](a) = b.
        --     This is the hard boundary case (below-min).
        --   If a is between w and w_next (adjacent in dom(N)):
        --     IH gives succ^[m](w_next_sub) = b_sub.
        --     Need succ^[j](a_sub) = w_next_sub. Then chain.
        --     By orbit convexity on the IH path from w to w_next:
        --     succ^[m'](w_sub) = w_next_sub. a between w and w_next.
        --     But a = new point, and we need succ from a to w_next.
        --     Key: succ(a) is next limit_dom after a. No limit_dom between a and succ(a).
        --     w_next > a (since a < w_next). w_next ∈ limit_dom. So succ(a) ≤ w_next.
        --     If succ(a) < w_next: succ(a) ∈ limit_dom ∩ (a, w_next). succ(a) ∉ dom(N)
        --       (between w and w_next, adjacent in dom(N)). So succ(a) is a later-stage point.
        --     Actually: between a and succ(a), no limit_dom. w_next > a, w_next ∈ limit_dom.
        --     So w_next ≥ succ(a). I.e., succ(a) ≤ w_next.
        --     Similarly, between w and a: w < a. w ∈ limit_dom. succ(w) ≤ a (since w < a
        --       and succ_le_iff). Also succ(w) is limit_dom, succ(w) > w.
        --     If succ(w) = a: then iterate: succ(a) is next. succ(a) ≤ w_next.
        --       succ^[2](w) = succ(a) ≤ w_next. IH gives succ^[m](w) = w_next.
        --       Orbit convexity: a between w and w_next, so a = succ^[j](w) for some j.
        --       Then succ^[m-j](a) = w_next. Then IH from w_next to b.
        --     But this uses IH with w ∈ dom(N), which is fine!
        -- For now, let me handle the "between" case and sorry the boundary.
        have h_dom_ne : (omega_chain_val A h_mcs N).dom.Nonempty := ⟨b.val, hb_old⟩
        set min_N := (omega_chain_val A h_mcs N).dom.min' h_dom_ne
        set max_N := (omega_chain_val A h_mcs N).dom.max' h_dom_ne
        -- a.val < min_N or a.val is between two dom(N) points
        -- Since a ≤ b and b ∈ dom(N), a.val ≤ b.val ≤ max_N.
        have h_a_le_max : a.val ≤ max_N :=
          le_trans hab (Finset.le_max' _ b.val hb_old)
        by_cases h_a_ge_min : min_N ≤ a.val
        · -- a.val ≥ min_N. So a.val ∈ [min_N, max_N] and a.val ∉ dom(N).
          -- Find adjacent pair bracketing a.
          haveI : DecidablePred (fun d => d ≤ a.val) := fun d => inferInstance
          set L_set := (omega_chain_val A h_mcs N).dom.filter (· ≤ a.val)
          set R_set := (omega_chain_val A h_mcs N).dom.filter (a.val < ·)
          have hL_ne : L_set.Nonempty := by
            refine ⟨min_N, Finset.mem_filter.mpr ⟨Finset.min'_mem _ h_dom_ne, h_a_ge_min⟩⟩
          -- Need a dom(N) point > a.val. Since a ≤ b and b ∈ dom(N):
          -- If a.val = b.val: a = b (same subtype element), and a ∈ dom(N) since b ∈ dom(N).
          -- But a ∉ dom(N). So a.val ≠ b.val. So a.val < b.val.
          have h_a_lt_b : a.val < b.val := by
            rcases lt_or_eq_of_le (hab : a.val ≤ b.val) with h | h
            · exact h
            · exact absurd (show a.val ∈ _ from h ▸ hb_old) ha_old
          have hR_ne : R_set.Nonempty :=
            ⟨b.val, Finset.mem_filter.mpr ⟨hb_old, h_a_lt_b⟩⟩
          set w := L_set.max' hL_ne
          set w_next := R_set.min' hR_ne
          have hw_mem : w ∈ (omega_chain_val A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).1
          have hw_le_a : w ≤ a.val :=
            (Finset.mem_filter.mp (Finset.max'_mem L_set hL_ne)).2
          have hwn_mem : w_next ∈ (omega_chain_val A h_mcs N).dom :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).1
          have ha_lt_wn : a.val < w_next :=
            (Finset.mem_filter.mp (Finset.min'_mem R_set hR_ne)).2
          have hw_lt_a : w < a.val := by
            rcases lt_or_eq_of_le hw_le_a with h | h
            · exact h
            · exact absurd (h ▸ hw_mem) ha_old
          -- w, w_next, b ∈ dom(N). w < a < w_next ≤ b.
          have hw_limit : w ∈ limit_dom A h_mcs := ⟨N, hw_mem⟩
          have hwn_limit : w_next ∈ limit_dom A h_mcs := ⟨N, hwn_mem⟩
          -- IH: succ^[m](w_sub) = b_sub (both in dom(N), w ≤ b since w < a ≤ b)
          have hw_le_b : (⟨w, hw_limit⟩ : LimitDomSubtype A h_mcs) ≤ b := by
            show w ≤ b.val; exact le_trans (le_of_lt hw_lt_a) hab
          obtain ⟨m, hm⟩ := ih ⟨w, hw_limit⟩ b hw_mem hb_old hw_le_b
          -- succ^[m](w_sub) = b. Since w < a ≤ b = succ^[m](w_sub):
          --   a is between w_sub and succ^[m](w_sub).
          --   By orbit convexity: ∃ j ≤ m, succ^[j](w_sub) = a.
          have ha_in_range : a ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[m] ⟨w, hw_limit⟩ := by
            rw [hm]; exact hab
          have hw_le_a' : (⟨w, hw_limit⟩ : LimitDomSubtype A h_mcs) ≤ a := by
            show w ≤ a.val; exact le_of_lt hw_lt_a
          obtain ⟨j, hj_le, hj_eq⟩ := succ_orbit_convex A h_mcs h_discrete
            ⟨w, hw_limit⟩ a m hw_le_a' ha_in_range
          -- succ^[j](w_sub) = a. So succ^[m-j](a) = succ^[m](w_sub) = b.
          -- Actually, succ^[m](w_sub) = b and succ^[j](w_sub) = a.
          -- succ^[m-j](succ^[j](w_sub)) = succ^[m](w_sub) = b.
          -- So succ^[m-j](a) = b.
          refine ⟨m - j, ?_⟩
          have : (limitDomSubtype_succ A h_mcs h_discrete)^[m - j]
              ((limitDomSubtype_succ A h_mcs h_discrete)^[j] ⟨w, hw_limit⟩) =
              (limitDomSubtype_succ A h_mcs h_discrete)^[m] ⟨w, hw_limit⟩ := by
            rw [← Function.iterate_add_apply]
            congr 1; omega
          rw [hj_eq] at this; rw [this, hm]
        · -- a.val < min_N. Boundary case: a below min(dom(N)).
          -- This is the hard boundary case (below-min).
          sorry
      · -- Case 4: both new at stage N+1.
        -- omega_chain_dom_new_unique gives a.val = b.val, hence a = b.
        have ha_new : a.val ∈ (omega_chain_val A h_mcs (N + 1)).dom := ha
        have hb_new : b.val ∈ (omega_chain_val A h_mcs (N + 1)).dom := hb
        have := omega_chain_dom_new_unique A h_mcs N a.val b.val ha_new ha_old hb_new hb_old
        exact ⟨0, Subtype.ext this⟩

/--
Every limit_dom point in `[a.val, L)` for a limit_dom point `a` is a succ-iterate
of `a`, where `L` is any upper bound such that all succ-iterates are below `L`.

Key step: if `z ∈ limit_dom` with `a.val ≤ z.val` and `z.val < succ^[n](a).val` for
no `n`, then `z.val ≥ succ^[n](a).val` for all `n`, contradicting `z.val < L`.
If `succ^[n₀](a) > z` for some `n₀`: take minimum; then `z` is between consecutive
succ-iterates, contradicting the immediate-successor property.
-/
private theorem limit_dom_points_are_succ_iterates
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a z : LimitDomSubtype A h_mcs) (h_az : a ≤ z)
    (h_all_below : ∀ n, (limitDomSubtype_succ A h_mcs h_discrete)^[n] a ≤ z) :
    ∃ m, (limitDomSubtype_succ A h_mcs h_discrete)^[m] a = z := by
  set s := limitDomSubtype_succ A h_mcs h_discrete
  -- For each n, either s^[n](a) = z, or s^[n](a) < z or s^[n](a) > z.
  -- But h_all_below says s^[n](a) ≤ z. So s^[n](a) ≤ z.
  -- If s^[n](a) = z for some n: done.
  by_contra h_never
  push_neg at h_never
  -- h_never : ∀ m, s^[m] a ≠ z
  -- Combined with h_all_below: s^[m](a) < z for all m.
  have h_strict : ∀ m, s^[m] a < z := by
    intro m; exact lt_of_le_of_ne (h_all_below m) (h_never m)
  -- Since s^[m](a) < z for all m: s^[m](a) ≤ pred(z) for all m.
  have h_le_pred : ∀ m, s^[m] a ≤ limitDomSubtype_pred A h_mcs h_discrete z :=
    fun m => (limitDomSubtype_le_pred_iff A h_mcs h_discrete _ z).mpr (h_strict m)
  -- Now: s^[m](a) ≤ pred(z). And pred(z) < z.
  -- s^[m](a) ≠ pred(z) for all m (otherwise s^[m+1](a) = succ(pred(z)) = z by succ_pred).
  have h_ne_pred : ∀ m, s^[m] a ≠ limitDomSubtype_pred A h_mcs h_discrete z := by
    intro m h_eq
    have : s^[m + 1] a = z := by
      rw [Function.iterate_succ', Function.comp_apply, h_eq]
      exact limitDomSubtype_succ_pred A h_mcs h_discrete z
    exact h_never (m + 1) this
  -- So s^[m](a) < pred(z) for all m.
  have h_strict_pred : ∀ m, s^[m] a < limitDomSubtype_pred A h_mcs h_discrete z :=
    fun m => lt_of_le_of_ne (h_le_pred m) (h_ne_pred m)
  -- But now: s^[m](a) < pred(z) for all m. pred(z) < z. So all succ iterates are ≤ pred(z).
  -- Apply the same argument to pred(z): s^[m](a) ≤ pred(pred(z)) for all m, etc.
  -- This gives an infinite descent on z, pred(z), pred^2(z), ...
  -- But we also know s(a) > a (succ is strictly increasing). So s^[m](a) is strictly increasing.
  -- And s^[m](a) < pred(z) for all m. The sequence s^[m](a).val is strictly increasing
  -- in ℚ, bounded by pred(z).val.
  -- Casting to ℝ and using convergence, the limit is L ≤ pred(z).val < z.val.
  -- The first limit_dom point ≥ L (in ℝ) has a predecessor which is a succ-iterate.
  -- This gives a succ-iterate equal to a value ≥ L, contradicting all being < pred(z).
  -- For now we defer to succ_reaches_dom_N for this step.
  -- Actually, let's derive the contradiction directly:
  -- pred(z) is limit_dom. All succ iterates of a are strictly below pred(z).
  -- Apply THIS LEMMA recursively to (a, pred(z)): all succ iterates ≤ pred(z),
  -- and all are ≠ pred(z), so all < pred(z), so all ≤ pred(pred(z)), etc.
  -- This is infinite descent on z → pred(z) → pred^2(z) → ...
  -- But z can decrease indefinitely (NoMinOrder), so we need another argument.
  -- Use the real analysis approach instead.
  sorry

/--
Succ-iterates are cofinal: for any `a < b` in `LimitDomSubtype`, there exists `n`
such that `succ^[n](a) ≥ b`. Combined with `succ_orbit_convex`, this gives
`IsSuccArchimedean`.

### Proof strategy

By contradiction: assume `succ^[n](a) < b` for all `n`. The key steps:

1. All succ-iterates of `a` are below `pred(b)` (by `le_pred_iff` + succ_pred cancellation).
2. The real-valued sequence `(succ^[n](a).val : ℝ)` is strictly increasing and bounded,
   so it converges to some `L ≤ b.val` in `ℝ`.
3. The first `limit_dom` point `z` at or above `L` satisfies `pred(z)` is a succ-iterate
   (since all limit_dom below `L` are succ-iterates), so `z = succ(pred(z)) = succ^[m+1](a)`.
   Hence `z.val ≤ L` (as a succ-iterate), giving `z.val = L`, so `L ∈ ℚ ∩ limit_dom`.
4. Since `pred(z).val < z.val = L` and `succ^[n](a).val → L`, for large `n`:
   `succ^[n](a).val > pred(z).val`, placing a limit_dom point between `pred(z)` and `z`.
   This contradicts the immediate-predecessor property.
-/
private theorem succ_cofinal (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) (hab : a < b) :
    ∃ n, b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[n] a := by
  set s := limitDomSubtype_succ A h_mcs h_discrete
  by_contra h_not_cofinal
  push_neg at h_not_cofinal
  -- h_not_cofinal: ∀ n, s^[n](a) < b
  -- Step 1: s^[n](a) ≤ pred(b) for all n
  set pb := limitDomSubtype_pred A h_mcs h_discrete b
  have h_le_pb : ∀ n, s^[n] a ≤ pb :=
    fun n => (limitDomSubtype_le_pred_iff A h_mcs h_discrete _ b).mpr (h_not_cofinal n)
  -- Step 2: Define the real-valued sequence and show it converges
  set f : ℕ → ℝ := fun n => (s^[n] a).val
  have s_lt : ∀ x : LimitDomSubtype A h_mcs, x < s x :=
    fun x => (limitDomSubtype_succ_le_iff A h_mcs h_discrete x (s x)).mp le_rfl
  have f_mono : Monotone f := by
    intro m n hmn
    simp only [f]
    apply Rat.cast_le.mpr
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hmn
    clear hmn; induction k with
    | zero => simp
    | succ k ih =>
      have h_step : (s^[m + k] a).val < (s (s^[m + k] a)).val := s_lt _
      have h_eq : (s (s^[m + k] a)).val = (s^[m + (k + 1)] a).val := by
        congr 1; rw [show m + (k + 1) = (m + k) + 1 from by omega,
          Function.iterate_succ', Function.comp_apply]
      exact le_of_lt (lt_of_le_of_lt ih (h_eq ▸ h_step))
  have f_bdd : BddAbove (Set.range f) := by
    refine ⟨(b.val : ℝ), ?_⟩
    rintro _ ⟨n, rfl⟩
    exact Rat.cast_le.mpr (le_of_lt (h_not_cofinal n))
  -- The sequence converges to some limit
  obtain ⟨L, hL_tendsto⟩ := Real.tendsto_of_bddAbove_monotone f_bdd f_mono
  -- L is an upper bound for all f(n)
  have hL_ub : ∀ n, f n ≤ L := by
    intro n
    exact le_of_tendsto_of_tendsto tendsto_const_nhds hL_tendsto
      (Filter.eventually_atTop.mpr ⟨n, fun m hm => f_mono hm⟩)
  -- L ≤ b.val (since all f(n) < b.val and L is the limit)
  have hL_le_b : L ≤ (b.val : ℝ) := by
    exact le_of_tendsto_of_tendsto hL_tendsto tendsto_const_nhds
      (Filter.Eventually.of_forall fun n => Rat.cast_le.mpr (le_of_lt (h_not_cofinal n)))
  -- Step 3: L > pred(b).val (the key step)
  -- We prove this by showing the first limit_dom point ≥ L has its predecessor
  -- as a succ-iterate, forcing L to be in limit_dom.
  -- First, show that pred(b).val < b.val in ℝ
  have h_pb_lt_b : (pb.val : ℝ) < (b.val : ℝ) := by
    exact Rat.cast_lt.mpr (limitDomSubtype_pred_lt A h_mcs h_discrete b)
  -- Now: if L > pred(b).val, get contradiction directly
  -- if L ≤ pred(b).val, get contradiction via the "first limit_dom ≥ L" argument
  -- For the full formal proof, we combine both into one argument.
  -- The "first limit_dom point ≥ L" is b (since L ≤ b.val).
  -- pred(b) < b. pred(b).val < b.val ≤ L? Or pred(b).val ≥ L?
  -- Case split:
  by_cases h_case : L > (pb.val : ℝ)
  · -- L > pred(b).val. Since f(n) → L and pred(b).val < L:
    -- eventually f(n) > pred(b).val.
    have := Filter.Tendsto.eventually_const_lt h_case hL_tendsto
    rw [Filter.eventually_atTop] at this
    obtain ⟨n₀, hn₀⟩ := this
    specialize hn₀ n₀ le_rfl
    -- f(n₀) > pred(b).val, i.e., s^[n₀](a).val > pred(b).val
    have h_gt_pb : pb < s^[n₀] a := by
      show pb.val < (s^[n₀] a).val
      exact Rat.cast_lt.mp hn₀
    -- But s^[n₀](a) ≤ pb from h_le_pb. Contradiction!
    exact absurd (h_le_pb n₀) (not_le.mpr h_gt_pb)
  · -- L ≤ pred(b).val. The sequence is bounded by pred(b).val.
    push_neg at h_case
    -- h_case: L ≤ pred(b).val
    -- All f(n) ≤ L ≤ pred(b).val < b.val. s^[n](a) ≤ pred(b).
    -- s^[n](a) ≠ pred(b) (otherwise s^[n+1](a) = succ(pred(b)) = b).
    have h_ne_pb : ∀ n, s^[n] a ≠ pb := by
      intro n h_eq
      have : s^[n + 1] a = b := by
        rw [Function.iterate_succ', Function.comp_apply, h_eq]
        exact limitDomSubtype_succ_pred A h_mcs h_discrete b
      exact absurd this (ne_of_lt (h_not_cofinal (n + 1)))
    -- So s^[n](a) < pred(b) for all n. Apply the SAME argument with pred(b) instead of b.
    -- This creates infinite descent: b → pred(b) → pred²(b) → ...
    -- At each step, succ^[n](a) < pred^[m](b) for all n. And pred^[m](b) is strictly decreasing.
    -- The sequence pred^[m](b).val (cast to ℝ) is strictly decreasing and bounded below.
    -- Its infimum R ≥ L. If R = L: the "gap" between the succ-chain and pred-chain
    -- closes in ℝ, allowing us to catch pred^[m](b) between consecutive succ-iterates.
    --
    -- Full argument: by induction/descent, showing the gap is eventually 0.
    -- The detailed formalization uses the "first limit_dom ≥ L" argument from the docstring.
    -- For now, we use the following cleaner argument:
    --
    -- Since all limit_dom points in [a.val, L) are succ-iterates of a (proved by
    -- contradiction: any such point is either a succ-iterate or between consecutive
    -- ones, which is impossible), and since b is limit_dom with b.val ≥ L:
    -- pred(b) is either a succ-iterate or ≥ L. But pred(b).val ≥ L (from h_case).
    -- So pred(b) is limit_dom with pred(b).val ≥ L. pred(b) is NOT a succ-iterate
    -- (since all succ-iterates are < pred(b)). So pred(b).val ≥ L.
    --
    -- Now consider pred(pred(b)). pred(pred(b)) < pred(b). Is pred(pred(b)).val ≥ L?
    -- If yes: continue descent. If no: pred(pred(b)).val < L. Then:
    -- pred(pred(b)) is a limit_dom point with pred(pred(b)).val < L.
    -- So pred(pred(b)) is a succ-iterate: pred(pred(b)) = s^[m](a).
    -- Then pred(b) = succ(pred(pred(b))) = s^[m+1](a).
    -- But s^[m+1](a) < pred(b) (from h_ne_pb and h_le_pb). Contradiction!
    --
    -- If pred^[k](b).val ≥ L for ALL k: the sequence pred^[k](b).val is strictly
    -- decreasing and bounded below by L. It converges to some R ≥ L in ℝ.
    -- The argument with the "first limit_dom point ≥ L" shows L is limit_dom.
    -- Then pred(L_sub).val < L. For large n: s^[n](a).val > pred(L_sub).val.
    -- s^[n](a) is between pred(L_sub) and L_sub. Contradiction.
    --
    -- TODO: complete the formal proof of this case
    sorry

/--
`IsSuccArchimedean` instance for `LimitDomSubtype` in the discrete case.

The proof uses `succ_cofinal` (every target is eventually reached or exceeded)
combined with `succ_orbit_convex` (iterates pass through all intermediate points)
to show that succ-iterates from `a` reach `b` exactly.
-/
noncomputable def limitDomSubtype_isSuccArchimedean
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs)
      inferInstance
      (limitDomSubtype_succOrder A h_mcs h_discrete) :=
  @IsSuccArchimedean.mk _ _ (limitDomSubtype_succOrder A h_mcs h_discrete) <| by
    intro a b hab
    change ∃ n, (limitDomSubtype_succ A h_mcs h_discrete)^[n] a = b
    set s := limitDomSubtype_succ A h_mcs h_discrete
    rcases eq_or_lt_of_le hab with rfl | hab_lt
    · exact ⟨0, rfl⟩
    · -- a < b. By succ_cofinal: ∃ n, b ≤ s^[n](a).
      obtain ⟨n, hn⟩ := succ_cofinal A h_mcs h_discrete a b hab_lt
      -- By succ_orbit_convex: ∃ j ≤ n, s^[j](a) = b.
      exact (succ_orbit_convex A h_mcs h_discrete a b n (le_of_lt hab_lt) hn).imp
        fun j ⟨_, hj⟩ => hj

/-! ## Collapse-Based Discrete Pipeline

When U(T,bot) is present in all domain MCS's, the limit domain has an immediate
successor for each point. `IsSuccArchimedean` (above) asserts that finitely many
succ steps reach any larger element. `succ_embed_surjective` follows from
`IsSuccArchimedean` via `succ_orbit_convex`.

The collapse equivalence below (succ-reachability) is used in auxiliary proofs.
Once `limitDomSubtype_isSuccArchimedean` is fully proved (currently has a sorry for
the orbit cofinality argument), the entire discrete pipeline becomes sorry-free.
-/

/--
Succ-reachability relation: `a` and `b` are collapse-equivalent iff one is
reachable from the other by finitely many applications of `limitDomSubtype_succ`.
Each equivalence class is one succ-orbit (omega-chain).
-/
def collapse_equiv (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) : Prop :=
  ∃ n : ℕ, (limitDomSubtype_succ A h_mcs h_discrete)^[n] a = b ∨
            (limitDomSubtype_succ A h_mcs h_discrete)^[n] b = a

/--
Succ-reachability is reflexive: `succ^[0] a = a`.
-/
theorem collapse_equiv_refl (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a : LimitDomSubtype A h_mcs) :
    collapse_equiv A h_mcs h_discrete a a :=
  ⟨0, Or.inl rfl⟩

/--
Succ-reachability is symmetric: by swapping the disjunction.
-/
theorem collapse_equiv_symm (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs)
    (h : collapse_equiv A h_mcs h_discrete a b) :
    collapse_equiv A h_mcs h_discrete b a := by
  obtain ⟨n, h_or⟩ := h
  exact ⟨n, h_or.symm⟩

/--
The succ function is strictly monotone: `a < limitDomSubtype_succ a`.
-/
private theorem limitDomSubtype_succ_lt (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a : LimitDomSubtype A h_mcs) :
    a < limitDomSubtype_succ A h_mcs h_discrete a :=
  (limitDomSubtype_succ_le_iff A h_mcs h_discrete a
    (limitDomSubtype_succ A h_mcs h_discrete a)).mp le_rfl

/--
Succ iterates are strictly increasing: `succ^[n] a < succ^[n+1] a`.
-/
private theorem limitDomSubtype_succ_iter_lt (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a : LimitDomSubtype A h_mcs) (n : ℕ) :
    (limitDomSubtype_succ A h_mcs h_discrete)^[n] a <
      (limitDomSubtype_succ A h_mcs h_discrete)^[n + 1] a := by
  rw [Function.iterate_succ', Function.comp_apply]
  exact limitDomSubtype_succ_lt A h_mcs h_discrete _

/--
Succ iterates are monotone: `n ≤ m → succ^[n] a ≤ succ^[m] a`.
-/
private theorem limitDomSubtype_succ_iter_mono (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a : LimitDomSubtype A h_mcs) {n m : ℕ} (h : n ≤ m) :
    (limitDomSubtype_succ A h_mcs h_discrete)^[n] a ≤
      (limitDomSubtype_succ A h_mcs h_discrete)^[m] a := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  clear h
  induction k with
  | zero => simp
  | succ k ih =>
    rw [show n + (k + 1) = n + k + 1 from by omega]
    exact le_of_lt (lt_of_le_of_lt ih
      (limitDomSubtype_succ_iter_lt A h_mcs h_discrete a _))

/--
Succ iterates are strictly monotone: `n < m → succ^[n] a < succ^[m] a`.
-/
private theorem limitDomSubtype_succ_iter_strictMono (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a : LimitDomSubtype A h_mcs) {n m : ℕ} (h : n < m) :
    (limitDomSubtype_succ A h_mcs h_discrete)^[n] a <
      (limitDomSubtype_succ A h_mcs h_discrete)^[m] a := by
  exact lt_of_lt_of_le
    (limitDomSubtype_succ_iter_lt A h_mcs h_discrete a n)
    (limitDomSubtype_succ_iter_mono A h_mcs h_discrete a (by omega))

/--
Succ iterates are injective: `succ^[n] a = succ^[m] a → n = m`.
-/
private theorem limitDomSubtype_succ_iter_injective (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a : LimitDomSubtype A h_mcs) {n m : ℕ}
    (h : (limitDomSubtype_succ A h_mcs h_discrete)^[n] a =
         (limitDomSubtype_succ A h_mcs h_discrete)^[m] a) :
    n = m := by
  rcases lt_trichotomy n m with h_lt | rfl | h_gt
  · exact absurd h (ne_of_lt (limitDomSubtype_succ_iter_strictMono A h_mcs h_discrete a h_lt))
  · rfl
  · exact absurd h.symm (ne_of_lt (limitDomSubtype_succ_iter_strictMono A h_mcs h_discrete a h_gt))

/--
Succ-reachability is transitive. The key argument uses injectivity of succ
iterates to reduce the composite reachability to a single direction.

If `succ^[n] a = b` and `succ^[m] b = c`, then `succ^[n+m] a = c`.
If `succ^[n] a = b` and `succ^[m] c = b`, then either `a` reaches `c` or
`c` reaches `a` (by comparing n and m, using injectivity).
-/
theorem collapse_equiv_trans (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b c : LimitDomSubtype A h_mcs)
    (hab : collapse_equiv A h_mcs h_discrete a b)
    (hbc : collapse_equiv A h_mcs h_discrete b c) :
    collapse_equiv A h_mcs h_discrete a c := by
  obtain ⟨n, hn⟩ := hab
  obtain ⟨m, hm⟩ := hbc
  -- Abbreviate the succ function
  set s := limitDomSubtype_succ A h_mcs h_discrete with hs_def
  -- Succ is injective
  have h_s_inj : Function.Injective s := by
    intro x y hxy
    by_contra h_ne
    rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
    · have h1 : s x ≤ y := (limitDomSubtype_succ_le_iff A h_mcs h_discrete x y).mpr h_lt
      have h2 : y < s y := limitDomSubtype_succ_lt A h_mcs h_discrete y
      have h3 : s x < s y := lt_of_le_of_lt h1 h2
      exact absurd hxy (ne_of_lt h3)
    · have h1 : s y ≤ x := (limitDomSubtype_succ_le_iff A h_mcs h_discrete y x).mpr h_gt
      have h2 : x < s x := limitDomSubtype_succ_lt A h_mcs h_discrete x
      have h3 : s y < s x := lt_of_le_of_lt h1 h2
      exact absurd hxy.symm (ne_of_lt h3)
  -- Helper: iteration composition
  have iter_add : ∀ (p q : ℕ) (x : LimitDomSubtype A h_mcs),
      s^[p + q] x = s^[p] (s^[q] x) := fun p q x =>
    Function.iterate_add_apply s p q x
  -- Helper: subtraction cancellation with iteration
  have iter_sub_left (p q : ℕ) (x y : LimitDomSubtype A h_mcs) (h : q ≤ p)
      (h_eq : s^[p] x = s^[q] y) : s^[p - q] x = y := by
    have h1 : s^[q] (s^[p - q] x) = s^[q] y := by
      rw [← iter_add]
      have : q + (p - q) = p := by omega
      rw [this]; exact h_eq
    exact (h_s_inj.iterate q) h1
  rcases hn with hn_ab | hn_ba <;> rcases hm with hm_bc | hm_cb
  · -- s^[n] a = b, s^[m] b = c => s^[m+n] a = c
    exact ⟨m + n, Or.inl (show s^[m + n] a = c by rw [iter_add, hn_ab, hm_bc])⟩
  · -- s^[n] a = b, s^[m] c = b => s^[n] a = s^[m] c
    have h_eq : s^[n] a = s^[m] c := by rw [hn_ab, hm_cb]
    rcases le_or_lt m n with h | h
    · exact ⟨n - m, Or.inl (iter_sub_left n m a c h h_eq)⟩
    · exact ⟨m - n, Or.inr (iter_sub_left m n c a h.le h_eq.symm)⟩
  · -- s^[n] b = a, s^[m] b = c
    -- s^[n] b = a and s^[m] b = c. Both are iterates from b.
    rcases le_or_lt n m with h | h
    · -- n ≤ m: s^[m] b = s^[n + (m-n)] b = s^[n](s^[m-n] b), and s^[n] b = a
      -- So s^[m-n] a = ... wait, we need to be careful with directions.
      -- s^[n](s^[m-n] b) = s^[m] b = c, and s^[n] b = a
      -- By injectivity: we want to relate a and c. Actually:
      -- s^[m-n](s^[n] b) = s^[m] b = c, so s^[m-n] a = c
      have h_eq : m - n + n = m := by omega
      have : s^[m - n] (s^[n] b) = c := by
        rw [← iter_add, h_eq]; exact hm_bc
      exact ⟨m - n, Or.inl (by rwa [hn_ba] at this)⟩
    · -- n > m: similarly s^[n-m] c = a
      have h_eq : n - m + m = n := by omega
      have : s^[n - m] (s^[m] b) = a := by
        rw [← iter_add, h_eq]; exact hn_ba
      exact ⟨n - m, Or.inr (by rwa [hm_bc] at this)⟩
  · -- s^[n] b = a, s^[m] c = b => s^[m+n] c = a
    refine ⟨m + n, Or.inr ?_⟩
    show s^[m + n] c = a
    have : s^[n + m] c = a := by rw [iter_add, hm_cb, hn_ba]
    rwa [show n + m = m + n from by omega] at this

/--
The succ-reachability relation as a `Setoid`.
-/
noncomputable def collapse_setoid (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    Setoid (LimitDomSubtype A h_mcs) where
  r := collapse_equiv A h_mcs h_discrete
  iseqv := {
    refl := collapse_equiv_refl A h_mcs h_discrete
    symm := collapse_equiv_symm A h_mcs h_discrete _ _
    trans := collapse_equiv_trans A h_mcs h_discrete _ _ _
  }

/--
The quotient type of `LimitDomSubtype` under succ-reachability.
Each element represents one succ-orbit (omega-chain or singleton).
-/
noncomputable def CollapseClass (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :=
  Quotient (collapse_setoid A h_mcs h_discrete)

/--
Helper: the succ function maps equivalent elements to equivalent elements.
If `succ^[n] a = b`, then `succ^[n+1] a = succ(b)`, so `a ~ succ(b)` via `n+1`.
Similarly for the other direction.
-/
private theorem collapse_equiv_succ_congr (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs)
    (h : collapse_equiv A h_mcs h_discrete a b) :
    collapse_equiv A h_mcs h_discrete
      (limitDomSubtype_succ A h_mcs h_discrete a)
      (limitDomSubtype_succ A h_mcs h_discrete b) := by
  obtain ⟨n, hn⟩ := h
  set s := limitDomSubtype_succ A h_mcs h_discrete
  rcases hn with hn_ab | hn_ba
  · -- succ^[n] a = b, so succ^[n](succ a) = succ(succ^[n] a) = succ b
    refine ⟨n, Or.inl ?_⟩
    show s^[n] (s a) = s b
    rw [(Function.Commute.iterate_self s n).eq a, hn_ab]
  · -- succ^[n] b = a, so succ^[n](succ b) = succ(succ^[n] b) = succ a
    refine ⟨n, Or.inr ?_⟩
    show s^[n] (s b) = s a
    rw [(Function.Commute.iterate_self s n).eq b, hn_ba]

/--
Orbit convexity: if `a ≤ b ≤ succ^[n] a`, then `b` is in the orbit of `a`.
Specifically, `b = succ^[k] a` for some `k ≤ n`.

Proof by strong induction on `n`. Base case `n = 0`: `a ≤ b ≤ a` forces `b = a`.
Step: if `a ≤ b ≤ succ^[n+1] a`, either `b ≤ succ^[n] a` (use IH) or
`succ^[n] a < b ≤ succ(succ^[n] a)`. In the latter case,
`succ(succ^[n] a) ≤ b` (from `succ_le_iff` and `succ^[n] a < b`), so
`b = succ^[n+1] a`.
-/
private theorem collapse_orbit_convex (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) (n : ℕ)
    (h_le : a ≤ b)
    (h_ub : b ≤ (limitDomSubtype_succ A h_mcs h_discrete)^[n] a) :
    ∃ k ≤ n, (limitDomSubtype_succ A h_mcs h_discrete)^[k] a = b := by
  set s := limitDomSubtype_succ A h_mcs h_discrete
  induction n with
  | zero =>
    simp only [Function.iterate_zero, id_eq] at h_ub
    exact ⟨0, le_rfl, le_antisymm h_le h_ub⟩
  | succ n ih =>
    rcases le_or_lt b (s^[n] a) with h_le_n | h_gt_n
    · obtain ⟨k, hkn, hk⟩ := ih h_le_n
      exact ⟨k, Nat.le_succ_of_le hkn, hk⟩
    · -- succ^[n] a < b ≤ succ^[n+1] a
      -- succ(succ^[n] a) ≤ b (from succ_le_iff and succ^[n] a < b)
      have h_succ_le : s (s^[n] a) ≤ b :=
        (limitDomSubtype_succ_le_iff A h_mcs h_discrete (s^[n] a) b).mpr h_gt_n
      -- Also b ≤ succ^[n+1] a = s(succ^[n] a)
      have h_iter_succ : s^[n + 1] a = s (s^[n] a) :=
        Function.iterate_succ_apply' s n a
      rw [h_iter_succ] at h_ub
      exact ⟨n + 1, le_rfl, by rw [h_iter_succ]; exact (le_antisymm h_ub h_succ_le).symm⟩

/--
If `a < b` and `a ≁ b`, then every succ-iterate of `a` is strictly less than `b`.
This follows from orbit convexity: if `succ^[n] a ≥ b`, then `b` would be in
the orbit of `a` (since `a ≤ b ≤ succ^[n] a`), contradicting `a ≁ b`.
-/
private theorem collapse_orbit_bounded (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs)
    (h_lt : a < b) (h_ne : ¬ collapse_equiv A h_mcs h_discrete a b)
    (n : ℕ) :
    (limitDomSubtype_succ A h_mcs h_discrete)^[n] a < b := by
  by_contra h_not_lt
  push_neg at h_not_lt
  obtain ⟨k, _, hk⟩ := collapse_orbit_convex A h_mcs h_discrete a b n h_lt.le h_not_lt
  exact h_ne ⟨k, Or.inl hk⟩

/--
If `a ≁ b`, then for the canonical representatives: if `succ^[p] x = a`,
all iterates of x are also not equivalent to b. Contrapositively: if any
iterate of x were equivalent to b, then x ~ b, hence a ~ b.
-/
private theorem collapse_not_equiv_of_orbit (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs)
    (h_ne : ¬ collapse_equiv A h_mcs h_discrete a b)
    (n : ℕ) :
    ¬ collapse_equiv A h_mcs h_discrete
      ((limitDomSubtype_succ A h_mcs h_discrete)^[n] a) b := by
  intro ⟨m, hm⟩
  exact h_ne (collapse_equiv_trans A h_mcs h_discrete a
    ((limitDomSubtype_succ A h_mcs h_discrete)^[n] a) b
    ⟨n, Or.inl rfl⟩ ⟨m, hm⟩)

/--
The collapse equivalence classes are totally separated:
if `a ≁ b` and `a < b`, then `a' < b'` for any `a' ~ a` and `b' ~ b`.
-/
private theorem collapse_class_sep (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) (a' b' : LimitDomSubtype A h_mcs)
    (ha : collapse_equiv A h_mcs h_discrete a a')
    (hb : collapse_equiv A h_mcs h_discrete b b')
    (h_ne : ¬ collapse_equiv A h_mcs h_discrete a b)
    (h_lt : a < b) : a' < b' := by
  set s := limitDomSubtype_succ A h_mcs h_discrete
  -- Step 1: a' < b (all elements of [a] are < b)
  have ha'_lt_b : a' < b := by
    obtain ⟨p, hp⟩ := ha
    rcases hp with hp_eq | hp_eq
    · -- s^[p] a = a', so a' is a succ-iterate of a. Show all iterates < b.
      exact hp_eq ▸ collapse_orbit_bounded A h_mcs h_discrete a b h_lt h_ne p
    · -- s^[p] a' = a, so a' ≤ s^[p] a' = a < b
      calc a' ≤ s^[p] a' :=
            limitDomSubtype_succ_iter_mono A h_mcs h_discrete a' (Nat.zero_le p)
        _ = a := hp_eq
        _ < b := h_lt
  -- Step 2: a' < b' using ha'_lt_b and the separation argument
  -- If b' ≤ a', then b' < a' (since a' ≁ b'). Then b is a succ-iterate of b'
  -- (or b' is a succ-iterate of b). If succ^q b = b', then b ≤ b' < a' -- but a' < b, contradiction.
  -- If succ^q b' = b, then by collapse_orbit_bounded (b' < a', b' ≁ a'),
  -- succ^q b' < a', so b < a'. But a' < b, contradiction.
  have h_ne' : ¬ collapse_equiv A h_mcs h_discrete a' b' := by
    intro h
    exact h_ne (collapse_equiv_trans A h_mcs h_discrete a a' b
      ha (collapse_equiv_trans A h_mcs h_discrete a' b' b h
        (collapse_equiv_symm A h_mcs h_discrete b b' hb)))
  by_contra h_not_lt'
  push_neg at h_not_lt'
  have h_b'_ne_a' : b' ≠ a' := fun h_eq => h_ne' (h_eq ▸ collapse_equiv_refl _ _ _ _)
  have h_b'_lt_a' : b' < a' := lt_of_le_of_ne h_not_lt' h_b'_ne_a'
  obtain ⟨q, hq⟩ := hb
  rcases hq with hq_bb' | hq_b'b
  · -- s^[q] b = b'. So b ≤ b' (succ iterates are monotone).
    have h_b_le_b' : b ≤ b' := hq_bb' ▸
      limitDomSubtype_succ_iter_mono A h_mcs h_discrete b (Nat.zero_le q)
    exact absurd ha'_lt_b (not_lt.mpr (le_trans h_b_le_b' h_not_lt'))
  · -- s^[q] b' = b. b' < a' and b' ≁ a'.
    have h_ne_b'a' : ¬ collapse_equiv A h_mcs h_discrete b' a' :=
      fun h => h_ne' (collapse_equiv_symm A h_mcs h_discrete b' a' h)
    have h_iter_lt : s^[q] b' < a' :=
      collapse_orbit_bounded A h_mcs h_discrete b' a' h_b'_lt_a' h_ne_b'a' q
    have h_b_lt_a' : b < a' := hq_b'b ▸ h_iter_lt
    exact absurd ha'_lt_b (not_lt.mpr h_b_lt_a'.le)

/--
Auxiliary: strict order on `CollapseClass` representatives is transitive.
If `a < b`, `a ≁ b`, `b < c`, and `b ≁ c`, then `a < c` and `a ≁ c`.
-/
private theorem collapse_lt_trans (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    {a b c : LimitDomSubtype A h_mcs}
    (hab : a < b) (hnab : ¬ collapse_equiv A h_mcs h_discrete a b)
    (hbc : b < c) (_hnbc : ¬ collapse_equiv A h_mcs h_discrete b c) :
    a < c ∧ ¬ collapse_equiv A h_mcs h_discrete a c := by
  refine ⟨lt_trans hab hbc, fun hac => ?_⟩
  -- a ~ c. By sep: since a ≁ b and a < b, for a' ~ a, b' ~ b, a' < b'.
  -- In particular, taking a' = c (since c ~ a), b' = b: c < b. But b < c. Contradiction.
  have : c < b := collapse_class_sep A h_mcs h_discrete a b c b
    hac (collapse_equiv_refl A h_mcs h_discrete b) hnab hab
  exact absurd (lt_trans hbc this) (lt_irrefl b)

/--
`LinearOrder` instance on `CollapseClass`. The quotient of a linear order
by a convex equivalence relation is linearly ordered.

The strict order `[a] < [b]` is defined as `a < b ∧ a ≁ b` (well-defined by
`collapse_class_sep`). The `≤` relation is `= ∨ <`, and totality follows
from the trichotomy on the underlying `LimitDomSubtype`.
-/
noncomputable instance collapseClass_linearOrder (A : Set Formula)
    (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    LinearOrder (CollapseClass A h_mcs h_discrete) := by
  letI setoid := collapse_setoid A h_mcs h_discrete
  -- The strict order: [a] < [b] iff a < b and a ≁ b (well-defined by collapse_class_sep)
  let lt_fn : CollapseClass A h_mcs h_discrete → CollapseClass A h_mcs h_discrete → Prop :=
    @Quotient.lift₂ _ _ Prop setoid setoid
      (fun a b => a < b ∧ ¬ collapse_equiv A h_mcs h_discrete a b)
      (by
        intro a₁ b₁ a₂ b₂ ha hb; ext; constructor
        · rintro ⟨h_lt, h_ne⟩
          exact ⟨collapse_class_sep A h_mcs h_discrete a₁ b₁ a₂ b₂ ha hb h_ne h_lt,
                 fun h => h_ne (collapse_equiv_trans A h_mcs h_discrete a₁ a₂ b₁
                   ha (collapse_equiv_trans A h_mcs h_discrete a₂ b₂ b₁ h
                     (collapse_equiv_symm A h_mcs h_discrete b₁ b₂ hb)))⟩
        · rintro ⟨h_lt, h_ne⟩
          exact ⟨collapse_class_sep A h_mcs h_discrete a₂ b₂ a₁ b₁
                   (collapse_equiv_symm A h_mcs h_discrete a₁ a₂ ha)
                   (collapse_equiv_symm A h_mcs h_discrete b₁ b₂ hb) h_ne h_lt,
                 fun h => h_ne (collapse_equiv_trans A h_mcs h_discrete a₂ a₁ b₂
                   (collapse_equiv_symm A h_mcs h_discrete a₁ a₂ ha)
                   (collapse_equiv_trans A h_mcs h_discrete a₁ b₁ b₂ h hb))⟩)
  -- Trichotomy on the quotient
  have h_tri : ∀ (a b : CollapseClass A h_mcs h_discrete),
      lt_fn a b ∨ a = b ∨ lt_fn b a :=
    Quotient.ind₂ (fun a b => by
      rcases lt_trichotomy a b with h | h | h
      · rcases Classical.em (collapse_equiv A h_mcs h_discrete a b) with hab | hab
        · exact Or.inr (Or.inl (Quotient.sound hab))
        · exact Or.inl ⟨h, hab⟩
      · exact Or.inr (Or.inl (by subst h; rfl))
      · rcases Classical.em (collapse_equiv A h_mcs h_discrete b a) with hba | hba
        · exact Or.inr (Or.inl (Quotient.sound hba).symm)
        · exact Or.inr (Or.inr ⟨h, hba⟩))
  -- Irreflexivity
  have h_irrefl : ∀ (a : CollapseClass A h_mcs h_discrete), ¬ lt_fn a a :=
    Quotient.ind (fun a ⟨h, _⟩ => lt_irrefl a h)
  -- Transitivity
  have h_trans : ∀ (a b c : CollapseClass A h_mcs h_discrete),
      lt_fn a b → lt_fn b c → lt_fn a c := by
    intro a b c
    exact Quotient.inductionOn₃ a b c (fun _ _ _ hab hbc =>
      collapse_lt_trans A h_mcs h_discrete hab.1 hab.2 hbc.1 hbc.2)
  -- Build Preorder → PartialOrder → LinearOrder
  letI : LT (CollapseClass A h_mcs h_discrete) := ⟨lt_fn⟩
  letI : LE (CollapseClass A h_mcs h_discrete) := ⟨fun a b => a = b ∨ lt_fn a b⟩
  letI : Preorder (CollapseClass A h_mcs h_discrete) :=
  { le_refl := fun _ => Or.inl rfl
    le_trans := by
      intro a b c hab hbc
      rcases hab with rfl | hab; exact hbc
      rcases hbc with rfl | hbc; exact Or.inr hab
      exact Or.inr (h_trans a b c hab hbc)
    lt_iff_le_not_ge := by
      intro a b; constructor
      · intro hab
        refine ⟨Or.inr hab, ?_⟩
        intro hba
        rcases hba with rfl | hba
        · exact h_irrefl _ hab
        · exact h_irrefl _ (h_trans _ _ _ hab hba)
      · intro ⟨hab, hba⟩
        rcases hab with rfl | hab
        · exact absurd (Or.inl rfl) hba
        · exact hab }
  letI : PartialOrder (CollapseClass A h_mcs h_discrete) :=
  { le_antisymm := by
      intro a b hab hba
      rcases hab with rfl | hab; rfl
      rcases hba with rfl | hba; rfl
      exact absurd (h_trans a b a hab hba) (h_irrefl a) }
  exact
  { le_total := by
      intro a b
      rcases h_tri a b with h | h | h
      · exact Or.inl (Or.inr h)
      · exact Or.inl (Or.inl h)
      · exact Or.inr (Or.inr h)
    toDecidableLE := fun a b => Classical.dec (a ≤ b) }

/-! ### Direct Embedding: ℤ ↪ LimitDomSubtype

Rather than proving the full quotient order infrastructure on `CollapseClass`
(which requires establishing that succ-orbits are bounded — a property deep in
the omega-chain construction), we take a simpler approach: embed ℤ directly into
`LimitDomSubtype` using `NoMaxOrder` / `NoMinOrder` to pick witnesses.

The key observation: `forward_G` / `backward_H` hold for ANY ordered pair of
domain points (`limit_forward_G` / `limit_backward_H`), regardless of equivalence
class. So we only need a strictly increasing map `ℤ → LimitDomSubtype`, which
the existing `NoMaxOrder` / `NoMinOrder` instances provide via iterated choice.

The collapse equivalence infrastructure (above) is preserved for potential future
use in proving finer structural properties (e.g., Until/Since coherence on ℤ
for task 122).
-/

/--
Forward embedding: a strictly increasing sequence of `LimitDomSubtype` elements
starting from `⟨0, zero_mem⟩` and going upward. Defined by iterated choice using
`NoMaxOrder`.
-/
noncomputable def embed_forward (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    ℕ → LimitDomSubtype A h_mcs
  | 0 => ⟨0, zero_mem_limit_dom A h_mcs⟩
  | n + 1 => (exists_gt (embed_forward A h_mcs n)).choose

private theorem embed_forward_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    embed_forward A h_mcs 0 = ⟨0, zero_mem_limit_dom A h_mcs⟩ := rfl

private theorem embed_forward_lt_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : ℕ) : embed_forward A h_mcs n < embed_forward A h_mcs (n + 1) :=
  (exists_gt (embed_forward A h_mcs n)).choose_spec

private theorem embed_forward_strictMono (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    StrictMono (embed_forward A h_mcs) :=
  strictMono_nat_of_lt_succ (embed_forward_lt_succ A h_mcs)

/--
Backward embedding: a strictly decreasing sequence starting from `⟨0, zero_mem⟩`
and going downward. Defined by iterated choice using `NoMinOrder`.
-/
noncomputable def embed_backward (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    ℕ → LimitDomSubtype A h_mcs
  | 0 => ⟨0, zero_mem_limit_dom A h_mcs⟩
  | n + 1 => (exists_lt (embed_backward A h_mcs n)).choose

private theorem embed_backward_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    embed_backward A h_mcs 0 = ⟨0, zero_mem_limit_dom A h_mcs⟩ := rfl

private theorem embed_backward_succ_lt (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : ℕ) : embed_backward A h_mcs (n + 1) < embed_backward A h_mcs n :=
  (exists_lt (embed_backward A h_mcs n)).choose_spec

private theorem embed_backward_strictAnti (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    StrictAnti (embed_backward A h_mcs) := by
  intro m n hmn
  induction hmn with
  | refl => exact embed_backward_succ_lt A h_mcs m
  | step h ih => exact lt_trans (embed_backward_succ_lt A h_mcs _) ih

/--
Combined embedding `ℤ → LimitDomSubtype`:
- Non-negative integers use `embed_forward`
- Negative integers use `embed_backward` (on the absolute value)
-/
noncomputable def discrete_embed (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    ℤ → LimitDomSubtype A h_mcs :=
  fun n =>
    if 0 ≤ n then
      embed_forward A h_mcs n.toNat
    else
      embed_backward A h_mcs ((-n).toNat)

private theorem discrete_embed_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    discrete_embed A h_mcs 0 = ⟨0, zero_mem_limit_dom A h_mcs⟩ := by
  simp [discrete_embed, embed_forward]

/--
Helper: `embed_backward` at positive indices is strictly below `⟨0, zero_mem⟩`.
-/
private theorem embed_backward_pos_lt_zero (A : Set Formula)
    (h_mcs : SetMaximalConsistent A) (n : ℕ) (hn : 0 < n) :
    embed_backward A h_mcs n < ⟨0, zero_mem_limit_dom A h_mcs⟩ := by
  have := embed_backward_strictAnti A h_mcs hn
  rwa [embed_backward_zero] at this

/--
The combined embedding is strictly increasing.
-/
private theorem discrete_embed_strictMono (A : Set Formula)
    (h_mcs : SetMaximalConsistent A) :
    StrictMono (discrete_embed A h_mcs) := by
  intro a b hab
  simp only [discrete_embed]
  by_cases ha : 0 ≤ a <;> by_cases hb : 0 ≤ b
  · -- Both non-negative: use embed_forward_strictMono
    simp only [ha, hb, ite_true]
    exact embed_forward_strictMono A h_mcs (by omega)
  · -- a ≥ 0, b < 0: impossible since a < b
    omega
  · -- a < 0, b ≥ 0: backward(|a|) < 0 ≤ forward(|b|)
    simp only [ha, hb, ite_true, ite_false]
    push_neg at ha
    have h_back_lt : embed_backward A h_mcs ((-a).toNat) <
        ⟨(0 : Rat), zero_mem_limit_dom A h_mcs⟩ :=
      embed_backward_pos_lt_zero A h_mcs _ (by omega)
    have h_fwd_ge : ⟨(0 : Rat), zero_mem_limit_dom A h_mcs⟩ ≤
        embed_forward A h_mcs b.toNat := by
      rw [← embed_forward_zero]
      exact embed_forward_strictMono A h_mcs |>.monotone (by omega)
    exact lt_of_lt_of_le h_back_lt h_fwd_ge
  · -- Both negative: use embed_backward_strictAnti
    simp only [ha, hb, ite_false]
    push_neg at ha hb
    exact embed_backward_strictAnti A h_mcs (by omega)

/--
MCS assignment via the direct embedding (discrete case). For each integer `n`,
evaluate `limit_f` at the embedded domain point.
-/
noncomputable def discrete_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (_h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    ℤ → Set Formula :=
  fun n => limit_f A h_mcs (discrete_embed A h_mcs n).val

/-- The origin integer in the discrete case is simply `0 : ℤ`. -/
noncomputable def discrete_zero (_A : Set Formula) (_h_mcs : SetMaximalConsistent _A)
    (_h_discrete : ∀ x ∈ limit_dom _A _h_mcs, next_top ∈ limit_f _A _h_mcs x) :
    ℤ := 0

/-- `discrete_f` at `discrete_zero` equals A (the root MCS). -/
theorem discrete_f_at_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    discrete_f A h_mcs h_discrete (discrete_zero A h_mcs h_discrete) = A := by
  simp only [discrete_f, discrete_zero, discrete_embed_zero]
  exact limit_f_zero A h_mcs

/-- Every integer maps to an MCS via `discrete_f`. -/
theorem discrete_f_is_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (n : ℤ) : SetMaximalConsistent (discrete_f A h_mcs h_discrete n) := by
  exact limit_c0 A h_mcs _ (discrete_embed A h_mcs n).property

/--
FMCS on ℤ (discrete case): chronicle coherence properties transported through
the direct embedding from `LimitDomSubtype` to ℤ.

`forward_G` follows from `limit_forward_G` since the embedding is strictly
increasing: `t < t'` implies `embed(t) < embed(t')`, so `G(φ) ∈ f(embed(t))`
and `embed(t) < embed(t')` give `φ ∈ f(embed(t'))`.

`backward_H` follows similarly from `limit_backward_H`.
-/
noncomputable def discrete_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    FMCS ℤ where
  mcs := discrete_f A h_mcs h_discrete
  is_mcs := discrete_f_is_mcs A h_mcs h_discrete
  forward_G := by
    intro t t' φ h_lt h_G
    have h_embed_lt := discrete_embed_strictMono A h_mcs h_lt
    exact limit_forward_G A h_mcs
      (discrete_embed A h_mcs t).val (discrete_embed A h_mcs t').val
      (discrete_embed A h_mcs t).property (discrete_embed A h_mcs t').property
      h_embed_lt φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_embed_lt := discrete_embed_strictMono A h_mcs h_lt
    exact limit_backward_H A h_mcs
      (discrete_embed A h_mcs t).val (discrete_embed A h_mcs t').val
      (discrete_embed A h_mcs t).property (discrete_embed A h_mcs t').property
      h_embed_lt φ h_H

/-! ## Discrete Case: Succ-Based Embedding and BFMCS on Z

When `□(U(⊤,⊥)) ∈ A` (box discreteness), every box-equivalent MCS N has
`U(⊤,⊥)` in all its chronicle domain points. This enables a succ-based
embedding `ℤ → LimitDomSubtype` that follows the deterministic successor
structure, and a BFMCS construction on ℤ mirroring the dense case.

The key property: when `U(⊤,⊥)` holds everywhere, between consecutive
embedded points (i.e., between `succ_embed(n)` and `succ_embed(n+1)`)
there are no limit domain points (the "no-gap" property). This makes
coherence proofs work: witnesses from `limit_F_resolution`, `limit_satisfies_c5_strong`,
etc. must land on embedded points.
-/

/--
From `□(U(⊤,⊥)) ∈ N`, derive that `U(⊤,⊥) ∈ limit_f(x)` for all `x ∈ limit_dom N`.
Mirror of `box_dense_gives_density`.

Proof: `□(U(⊤,⊥)) → G(□(U(⊤,⊥)))` via `temp_future`, then at each domain point
`□(U(⊤,⊥)) → U(⊤,⊥)` via `modal_t`. Past direction via `modal_4` + `box_to_past`.
-/
theorem box_discrete_gives_discreteness (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_discrete : Formula.box next_top ∈ N) :
    ∀ x ∈ limit_dom N h_N, next_top ∈ limit_f N h_N x := by
  intro x hx
  -- U(T,bot) ∈ N (from □(U(T,bot)) by modal_t)
  have h_nt_N : next_top ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (DerivationTree.axiom [] _ (Axiom.modal_t next_top)))
      h_box_discrete
  -- G(□(U(T,bot))) ∈ N (from □(U(T,bot)) by temp_future)
  have h_G_box : Formula.all_future (Formula.box next_top) ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (DerivationTree.axiom [] _ (Axiom.temp_future next_top)))
      h_box_discrete
  -- H(□(U(T,bot))) ∈ N (from □(U(T,bot)) → □□(U(T,bot)) → H(□(U(T,bot))))
  have h_box_box : Formula.box (Formula.box next_top) ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (DerivationTree.axiom [] _ (Axiom.modal_4 next_top)))
      h_box_discrete
  have h_H_box : Formula.all_past (Formula.box next_top) ∈ N :=
    SetMaximalConsistent.implication_property h_N
      (theorem_in_mcs h_N (box_to_past (Formula.box next_top))) h_box_box
  -- Now propagate to x ∈ limit_dom
  rcases lt_trichotomy 0 x with h_pos | rfl | h_neg
  · -- x > 0: G(□(U(T,bot))) ∈ limit_f(0) = N, propagate via limit_forward_G
    rw [← limit_f_zero N h_N] at h_G_box
    have h_box_x := limit_forward_G N h_N 0 x (zero_mem_limit_dom N h_N) hx h_pos
      (Formula.box next_top) h_G_box
    exact SetMaximalConsistent.implication_property (limit_c0 N h_N x hx)
      (theorem_in_mcs (limit_c0 N h_N x hx)
        (DerivationTree.axiom [] _ (Axiom.modal_t next_top))) h_box_x
  · -- x = 0: limit_f(0) = N
    rw [limit_f_zero]; exact h_nt_N
  · -- x < 0: H(□(U(T,bot))) ∈ limit_f(0) = N, propagate via limit_backward_H
    rw [← limit_f_zero N h_N] at h_H_box
    have h_box_x := limit_backward_H N h_N 0 x (zero_mem_limit_dom N h_N) hx h_neg
      (Formula.box next_top) h_H_box
    exact SetMaximalConsistent.implication_property (limit_c0 N h_N x hx)
      (theorem_in_mcs (limit_c0 N h_N x hx)
        (DerivationTree.axiom [] _ (Axiom.modal_t next_top))) h_box_x

/--
Succ-based embedding `ℤ → LimitDomSubtype` for the discrete case.
Maps 0 to ⟨0, zero_mem⟩, positive n to succ^n(root), negative n to pred^|n|(root).
This follows the deterministic successor structure when `U(⊤,⊥)` holds everywhere.
-/
noncomputable def succ_embed (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    ℤ → LimitDomSubtype A h_mcs :=
  fun n =>
    if h : 0 ≤ n then
      (limitDomSubtype_succ A h_mcs h_discrete)^[n.toNat] ⟨0, zero_mem_limit_dom A h_mcs⟩
    else
      (limitDomSubtype_pred A h_mcs h_discrete)^[(-n).toNat] ⟨0, zero_mem_limit_dom A h_mcs⟩

theorem succ_embed_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    succ_embed A h_mcs h_discrete 0 = ⟨0, zero_mem_limit_dom A h_mcs⟩ := by
  simp [succ_embed]

theorem succ_embed_succ (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (n : ℤ) (hn : 0 ≤ n) :
    succ_embed A h_mcs h_discrete (n + 1) =
      limitDomSubtype_succ A h_mcs h_discrete (succ_embed A h_mcs h_discrete n) := by
  simp only [succ_embed]
  have h1 : 0 ≤ n + 1 := by omega
  simp only [h1, hn, dite_true]
  rw [show (n + 1).toNat = n.toNat + 1 from by omega]
  rw [Function.iterate_succ', Function.comp_apply]

theorem succ_embed_pred (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (n : ℤ) (hn : n ≤ 0) :
    succ_embed A h_mcs h_discrete (n - 1) =
      limitDomSubtype_pred A h_mcs h_discrete (succ_embed A h_mcs h_discrete n) := by
  set s := limitDomSubtype_succ A h_mcs h_discrete
  set p := limitDomSubtype_pred A h_mcs h_discrete
  set root : LimitDomSubtype A h_mcs := ⟨0, zero_mem_limit_dom A h_mcs⟩
  -- LHS: succ_embed(n-1). Since n ≤ 0, n-1 < 0, so succ_embed(n-1) = pred^[|n-1|](root)
  have h_n_sub_1_neg : ¬(0 ≤ n - 1) := by omega
  -- RHS: pred(succ_embed(n)).
  show (if _ : 0 ≤ n - 1 then _ else p^[(-(n-1)).toNat] root) =
    p (if _ : 0 ≤ n then _ else _)
  simp only [h_n_sub_1_neg, dite_false]
  by_cases hn0 : n = 0
  · subst hn0
    simp only [le_refl, dite_true]
    show p^[(1 : ℕ)] root = p (s^[(0 : ℕ)] root)
    simp [Function.iterate_zero, Function.iterate_one]
  · have h_neg : ¬(0 ≤ n) := by omega
    simp only [h_neg, dite_false]
    rw [show (-(n - 1)).toNat = (-n).toNat + 1 from by omega]
    rw [Function.iterate_succ', Function.comp_apply]

/--
The succ-based embedding is strictly monotone.
-/
private theorem succ_embed_step (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (n : ℤ) : succ_embed A h_mcs h_discrete n <
      succ_embed A h_mcs h_discrete (n + 1) := by
  by_cases hn : 0 ≤ n
  · rw [succ_embed_succ A h_mcs h_discrete n hn]
    exact limitDomSubtype_succ_lt A h_mcs h_discrete _
  · push_neg at hn
    have hn1 : n + 1 ≤ 0 := by omega
    have h_eq : n = (n + 1) - 1 := by ring
    rw [h_eq, succ_embed_pred A h_mcs h_discrete (n + 1) hn1]
    have h_eq2 : (n + 1) - 1 + 1 = n + 1 := by ring
    rw [h_eq2]
    exact limitDomSubtype_pred_lt A h_mcs h_discrete _

theorem succ_embed_strictMono (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    StrictMono (succ_embed A h_mcs h_discrete) := by
  intro a b hab
  have h_step := succ_embed_step A h_mcs h_discrete
  -- Induction on the gap b - a
  obtain ⟨k, hk⟩ : ∃ k : ℕ, b = a + (↑k + 1) := ⟨(b - a - 1).toNat, by omega⟩
  subst hk
  induction k with
  | zero =>
    simp only [Nat.cast_zero, zero_add]
    exact h_step a
  | succ k ih =>
    calc succ_embed A h_mcs h_discrete a
      < succ_embed A h_mcs h_discrete (a + (↑k + 1)) := ih (by omega)
      _ < succ_embed A h_mcs h_discrete (a + (↑k + 1) + 1) := h_step _
      _ = succ_embed A h_mcs h_discrete (a + (↑(k + 1) + 1)) := by
            congr 1; omega

/--
No-gap property: between `succ_embed(n)` and `succ_embed(n+1)`, there are no
limit domain points. This is the KEY property of the discrete case.

When `U(⊤,⊥)` holds everywhere, `limitDomSubtype_succ` gives an IMMEDIATE successor
(no intermediate domain points). Since `succ_embed(n+1) = succ(succ_embed(n))` for
non-negative n (and symmetrically via pred for negative), the gap-free property follows.
-/
theorem succ_embed_no_gap (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (n : ℤ) (w : LimitDomSubtype A h_mcs)
    (h1 : succ_embed A h_mcs h_discrete n < w)
    (h2 : w < succ_embed A h_mcs h_discrete (n + 1)) : False := by
  by_cases hn : 0 ≤ n
  · -- n ≥ 0: succ_embed(n+1) = succ(succ_embed(n))
    rw [succ_embed_succ A h_mcs h_discrete n hn] at h2
    -- succ(succ_embed(n)) is the immediate successor: no points between
    -- succ_embed(n) and succ(succ_embed(n)). From succ_le_iff:
    -- succ(x) ≤ y ↔ x < y. Taking y = w: succ(succ_embed(n)) ≤ w ↔ succ_embed(n) < w.
    -- Since succ_embed(n) < w, we get succ(succ_embed(n)) ≤ w.
    -- But w < succ(succ_embed(n)). Contradiction.
    have h3 : limitDomSubtype_succ A h_mcs h_discrete (succ_embed A h_mcs h_discrete n) ≤ w :=
      (limitDomSubtype_succ_le_iff A h_mcs h_discrete _ w).mpr h1
    exact absurd h2 (not_lt.mpr h3)
  · -- n < 0: succ_embed(n) = pred(succ_embed(n+1))
    push_neg at hn
    have hn1 : n + 1 ≤ 0 := by omega
    rw [show n = (n + 1) - 1 from by ring,
        succ_embed_pred A h_mcs h_discrete (n + 1) hn1] at h1
    -- pred(succ_embed(n+1)) is the immediate predecessor: no points between
    -- pred(x) and x. From le_pred_iff: a ≤ pred(b) ↔ a < b.
    -- w < succ_embed(n+1), so w ≤ pred(succ_embed(n+1)).
    -- But pred(succ_embed(n+1)) < w. Contradiction.
    have h3 : w ≤ limitDomSubtype_pred A h_mcs h_discrete (succ_embed A h_mcs h_discrete (n + 1)) :=
      (limitDomSubtype_le_pred_iff A h_mcs h_discrete w _).mpr h2
    exact absurd h1 (not_lt.mpr h3)

/--
Squeeze lemma: any domain point between `succ_embed(a)` and `succ_embed(b)`
(inclusive on both ends) is itself an embedded point `succ_embed(k)` for some `a ≤ k ≤ b`.

This is the key lemma that makes coherence proofs work without full surjectivity.
The proof is by induction on `b - a`: the no-gap property eliminates domain points
between consecutive embedded points, squeezing w to the next embedded point.
-/
theorem succ_embed_squeeze (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : ℤ) (hab : a ≤ b)
    (w : LimitDomSubtype A h_mcs)
    (hw_lo : succ_embed A h_mcs h_discrete a ≤ w)
    (hw_hi : w ≤ succ_embed A h_mcs h_discrete b) :
    ∃ k : ℤ, a ≤ k ∧ k ≤ b ∧ succ_embed A h_mcs h_discrete k = w := by
  -- Induction on the gap b - a as a natural number
  suffices h : ∀ (d : ℕ) (a' b' : ℤ), b' - a' = ↑d → a' ≤ b' →
      ∀ (w' : LimitDomSubtype A h_mcs),
      succ_embed A h_mcs h_discrete a' ≤ w' →
      w' ≤ succ_embed A h_mcs h_discrete b' →
      ∃ k : ℤ, a' ≤ k ∧ k ≤ b' ∧ succ_embed A h_mcs h_discrete k = w' by
    exact h (b - a).toNat a b (by omega) hab w hw_lo hw_hi
  intro d
  induction d with
  | zero =>
    intro a' b' hd hab' w' hw_lo' hw_hi'
    have h_eq : a' = b' := by omega
    subst h_eq
    exact ⟨a', le_rfl, le_rfl, (le_antisymm hw_hi' hw_lo').symm⟩
  | succ d ih =>
    intro a' b' hd hab' w' hw_lo' hw_hi'
    rcases eq_or_lt_of_le hw_lo' with hw_eq | hw_gt
    · exact ⟨a', le_rfl, hab', hw_eq⟩
    · -- succ_embed(a') < w'. By no-gap, succ_embed(a'+1) ≤ w'.
      have h_a1_le : succ_embed A h_mcs h_discrete (a' + 1) ≤ w' := by
        by_contra h_not_le
        push_neg at h_not_le
        exact succ_embed_no_gap A h_mcs h_discrete a' w' hw_gt h_not_le
      exact (ih (a' + 1) b' (by omega) (by omega) w' h_a1_le hw_hi').imp
        fun k ⟨hk1, hk2, hk3⟩ => ⟨by omega, hk2, hk3⟩

/--
Strict version of squeeze: any domain point STRICTLY between `succ_embed(a)` and
`succ_embed(b)` is an embedded point `succ_embed(k)` for some `a < k < b`.
-/
theorem succ_embed_squeeze_strict (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (a b : ℤ) (hab : a < b)
    (w : LimitDomSubtype A h_mcs)
    (hw_lo : succ_embed A h_mcs h_discrete a < w)
    (hw_hi : w < succ_embed A h_mcs h_discrete b) :
    ∃ k : ℤ, a < k ∧ k < b ∧ succ_embed A h_mcs h_discrete k = w := by
  -- succ_embed(a) < w, so by no-gap, succ_embed(a+1) ≤ w
  have h_a1_le : succ_embed A h_mcs h_discrete (a + 1) ≤ w := by
    by_contra h_not_le
    push_neg at h_not_le
    exact succ_embed_no_gap A h_mcs h_discrete a w hw_lo h_not_le
  -- w < succ_embed(b), so w ≤ succ_embed(b-1) by no-gap
  have h_b1_ge : w ≤ succ_embed A h_mcs h_discrete (b - 1) := by
    by_contra h_not_le
    push_neg at h_not_le
    have hstep := succ_embed_step A h_mcs h_discrete (b - 1)
    rw [show b - 1 + 1 = b from by omega] at hstep
    exact succ_embed_no_gap A h_mcs h_discrete (b - 1) w h_not_le
      (by rwa [show b - 1 + 1 = b from by omega])
  -- Now a+1 ≤ b-1 follows from h_a1_le and h_b1_ge
  have hab' : a + 1 ≤ b - 1 := by
    by_contra h_not
    push_neg at h_not
    -- a + 1 > b - 1, so b ≤ a + 1. Combined with a < b: b = a + 1.
    -- Then a + 1 ≤ w ≤ embed(b-1) = embed(a), contradicting embed(a) < w.
    have hba : b = a + 1 := by omega
    subst hba
    rw [show a + 1 - 1 = a from by omega] at h_b1_ge
    exact absurd (lt_of_lt_of_le hw_lo h_b1_ge) (lt_irrefl _)
  obtain ⟨k, hk_lo, hk_hi, hk_eq⟩ := succ_embed_squeeze A h_mcs h_discrete
    (a + 1) (b - 1) hab' w h_a1_le h_b1_ge
  exact ⟨k, by omega, by omega, hk_eq⟩

/--
Surjectivity of `succ_embed`: every point in `LimitDomSubtype` is an embedded point.

Uses `IsSuccArchimedean` for `LimitDomSubtype`: given any `w`, we split on
`root ≤ w` vs `w < root` and apply `exists_succ_iterate_of_le` to get `n` with
`Order.succ^[n] root = w` (or `Order.succ^[n] w = root` for the negative case).
Since `Order.succ = limitDomSubtype_succ` (definitional equality from
`SuccOrder.ofSuccLeIff`), this gives `succ_embed n = w` via the correspondence
between `succ^[n](root)` and `succ_embed(n)`.
-/
theorem succ_embed_surjective (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (w : LimitDomSubtype A h_mcs) :
    ∃ n : ℤ, succ_embed A h_mcs h_discrete n = w := by
  letI succOrd := limitDomSubtype_succOrder A h_mcs h_discrete
  letI predOrd := limitDomSubtype_predOrder A h_mcs h_discrete
  letI := limitDomSubtype_isSuccArchimedean A h_mcs h_discrete
  set root : LimitDomSubtype A h_mcs := ⟨0, zero_mem_limit_dom A h_mcs⟩
  set s := limitDomSubtype_succ A h_mcs h_discrete
  set p := limitDomSubtype_pred A h_mcs h_discrete
  -- Helper: succ_embed(n) = s^[n](root) for n ≥ 0
  have h_succ_embed_nat : ∀ (n : ℕ),
      succ_embed A h_mcs h_discrete (↑n) = s^[n] root := by
    intro n; unfold succ_embed; simp [Int.toNat_natCast]; rfl
  -- Helper: succ_embed(-n) = p^[n](root) for n ≥ 0
  have h_succ_embed_neg : ∀ (n : ℕ),
      succ_embed A h_mcs h_discrete (-(↑n)) = p^[n] root := by
    intro n
    unfold succ_embed
    cases n with
    | zero => simp; rfl
    | succ n =>
      simp only [Nat.cast_succ, show ¬(0 ≤ -(↑(n + 1) : ℤ)) from by omega, dite_false]
      congr 1
  -- Case split: root ≤ w or w < root
  rcases le_or_gt root w with h_le | h_gt
  · -- Case root ≤ w: use IsSuccArchimedean to get n with succ^[n](root) = w
    obtain ⟨n, hn⟩ := exists_succ_iterate_of_le h_le
    -- Order.succ^[n] root = w, and Order.succ = s (definitional)
    exact ⟨↑n, by rw [h_succ_embed_nat]; exact hn⟩
  · -- Case w < root: use IsSuccArchimedean on w ≤ root to get n with succ^[n](w) = root
    obtain ⟨n, hn⟩ := exists_succ_iterate_of_le h_gt.le
    -- succ^[n](w) = root, so w = pred^[n](root) = succ_embed(-n)
    -- We need to show: w = pred^[n](root)
    -- Proof: succ^[n](w) = root. Apply pred^[n] to both sides.
    -- pred^[n](succ^[n](w)) = w (by pred_succ cancellation iterated)
    -- pred^[n](root) = succ_embed(-n)
    have h_w_eq : w = p^[n] root := by
      -- pred^[n](succ^[n](w)) = w, and succ^[n](w) = root, so w = pred^[n](root)
      suffices h_cancel : ∀ (m : ℕ) (x : LimitDomSubtype A h_mcs),
          (limitDomSubtype_pred A h_mcs h_discrete)^[m]
            ((limitDomSubtype_succ A h_mcs h_discrete)^[m] x) = x by
        rw [← hn]; exact (h_cancel n w).symm
      intro m x
      induction m with
      | zero => rfl
      | succ m ih =>
        -- pred^[m+1](succ^[m+1](x)) = pred^[m+1](succ(succ^[m](x)))
        -- = pred(pred^[m](succ(succ^[m](x))))
        -- We want: pred^[m](succ(succ^[m](x))) = succ^[m](x)... not quite
        -- Better: use pred_succ cancellation first, then IH
        -- pred^[m+1](succ^[m+1](x))
        -- = pred^[m](pred(succ(succ^[m](x))))  [unfold outer pred]
        -- = pred^[m](succ^[m](x))  [by pred_succ]
        -- = x  [by IH]
        conv_lhs =>
          rw [Function.iterate_succ_apply'
            (limitDomSubtype_succ A h_mcs h_discrete) m x]
        -- Now the succ part is: succ(succ^[m](x))
        -- And pred^[m+1] of that
        rw [show (limitDomSubtype_pred A h_mcs h_discrete)^[m + 1] =
          (limitDomSubtype_pred A h_mcs h_discrete)^[m] ∘
            (limitDomSubtype_pred A h_mcs h_discrete) from
            (Function.iterate_succ (limitDomSubtype_pred A h_mcs h_discrete) m).symm]
        simp only [Function.comp_apply]
        rw [limitDomSubtype_pred_succ A h_mcs h_discrete
          ((limitDomSubtype_succ A h_mcs h_discrete)^[m] x)]
        exact ih
    exact ⟨-(↑n), by rw [h_succ_embed_neg]; exact h_w_eq.symm⟩

/--
MCS assignment via the succ-based embedding.
-/
noncomputable def succ_discrete_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    ℤ → Set Formula :=
  fun n => limit_f A h_mcs (succ_embed A h_mcs h_discrete n).val

/-- Every integer maps to an MCS via `succ_discrete_f`. -/
theorem succ_discrete_f_is_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (n : ℤ) : SetMaximalConsistent (succ_discrete_f A h_mcs h_discrete n) :=
  limit_c0 A h_mcs _ (succ_embed A h_mcs h_discrete n).property

/-- `succ_discrete_f` at 0 equals A. -/
theorem succ_discrete_f_at_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    succ_discrete_f A h_mcs h_discrete 0 = A := by
  simp only [succ_discrete_f, succ_embed_zero]
  exact limit_f_zero A h_mcs

/-- Box stability for `succ_discrete_f`. -/
theorem box_stable_in_succ_discrete_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (φ : Formula) (n : ℤ) :
    Formula.box φ ∈ succ_discrete_f A h_mcs h_discrete n ↔ Formula.box φ ∈ A := by
  exact box_stable_in_limit_f A h_mcs φ _ (succ_embed A h_mcs h_discrete n).property

/--
FMCS on ℤ via the succ-based embedding. Uses `limit_forward_G` and
`limit_backward_H` through the strictly monotone embedding.
-/
noncomputable def succ_discrete_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    FMCS ℤ where
  mcs := succ_discrete_f A h_mcs h_discrete
  is_mcs := succ_discrete_f_is_mcs A h_mcs h_discrete
  forward_G := by
    intro t t' φ h_lt h_G
    have h_embed_lt := succ_embed_strictMono A h_mcs h_discrete h_lt
    exact limit_forward_G A h_mcs
      (succ_embed A h_mcs h_discrete t).val (succ_embed A h_mcs h_discrete t').val
      (succ_embed A h_mcs h_discrete t).property (succ_embed A h_mcs h_discrete t').property
      h_embed_lt φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_embed_lt := succ_embed_strictMono A h_mcs h_discrete h_lt
    exact limit_backward_H A h_mcs
      (succ_embed A h_mcs h_discrete t).val (succ_embed A h_mcs h_discrete t').val
      (succ_embed A h_mcs h_discrete t).property (succ_embed A h_mcs h_discrete t').property
      h_embed_lt φ h_H

/--
Shifted FMCS on ℤ: `mcs t := succ_discrete_f(t + offset)`.
-/
noncomputable def shifted_succ_discrete_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)
    (offset : ℤ) : FMCS ℤ where
  mcs t := succ_discrete_f A h_mcs h_discrete (t + offset)
  is_mcs t := succ_discrete_f_is_mcs A h_mcs h_discrete (t + offset)
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt' : t + offset < t' + offset := by omega
    exact (succ_discrete_fmcs A h_mcs h_discrete).forward_G (t + offset) (t' + offset) φ h_lt' h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt' : t' + offset < t + offset := by omega
    exact (succ_discrete_fmcs A h_mcs h_discrete).backward_H (t + offset) (t' + offset) φ h_lt' h_H

/--
Rooted FMCS on ℤ (discrete case): builds a chronicle for MCS N (with `□(U(⊤,⊥)) ∈ N`
ensuring discreteness), applies the succ embedding, and shifts to place N at time `s`.
-/
noncomputable def rooted_succ_discrete_fmcs (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_discrete_N : Formula.box next_top ∈ N) (s : ℤ) : FMCS ℤ :=
  let h_discrete_N := box_discrete_gives_discreteness N h_N h_box_discrete_N
  -- Offset = -s, so mcs(s) = succ_discrete_f(s + (-s)) = succ_discrete_f(0) = N
  shifted_succ_discrete_fmcs N h_N h_discrete_N (-s)

/--
The rooted FMCS at `s` has `mcs s = N`.
-/
theorem rooted_succ_discrete_fmcs_at_s (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_discrete_N : Formula.box next_top ∈ N) (s : ℤ) :
    (rooted_succ_discrete_fmcs N h_N h_box_discrete_N s).mcs s = N := by
  simp only [rooted_succ_discrete_fmcs, shifted_succ_discrete_fmcs]
  rw [show s + -s = 0 from by omega]
  exact succ_discrete_f_at_zero N h_N (box_discrete_gives_discreteness N h_N h_box_discrete_N)

/--
Box stability for `rooted_succ_discrete_fmcs`:
`Box φ ∈ (rooted_succ_discrete_fmcs N h_N h_box s).mcs t ↔ Box φ ∈ N`.
-/
theorem box_stable_in_rooted_succ_discrete_fmcs (N : Set Formula)
    (h_N : SetMaximalConsistent N) (h_box_discrete_N : Formula.box next_top ∈ N)
    (φ : Formula) (s t : ℤ) :
    Formula.box φ ∈ (rooted_succ_discrete_fmcs N h_N h_box_discrete_N s).mcs t ↔
      Formula.box φ ∈ N := by
  simp only [rooted_succ_discrete_fmcs, shifted_succ_discrete_fmcs]
  exact box_stable_in_succ_discrete_f N h_N
    (box_discrete_gives_discreteness N h_N h_box_discrete_N) φ (t + -s)

/--
Bundle of FMCS families on ℤ (discrete case).

Requires `□(U(⊤,⊥)) ∈ A` (box discreteness). Each family is a
`rooted_succ_discrete_fmcs N h_N h_box_N s` where N is box-equivalent to A
(hence `□(U(⊤,⊥)) ∈ N` by box-equiv). Each N gets its own chronicle, which
is discrete by `box_discrete_gives_discreteness`.
-/
noncomputable def cantor_bfmcs_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    BFMCS ℤ where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N)
    (h_box_N : Formula.box next_top ∈ N) (s : ℤ),
    (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
    fam = rooted_succ_discrete_fmcs N h_N h_box_N s }
  nonempty := ⟨rooted_succ_discrete_fmcs A h_mcs h_box_discrete 0,
    A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', h_box_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_in_N : Formula.box φ ∈ N :=
      (box_stable_in_rooted_succ_discrete_fmcs N h_N h_box_N φ s t).mp h_box
    have h_box_A : Formula.box φ ∈ A := (h_eqN φ).mpr h_box_in_N
    have h_box_in_N' : Formula.box φ ∈ N' := (h_eqN' φ).mp h_box_A
    have h_box_t' : Formula.box φ ∈ (rooted_succ_discrete_fmcs N' h_N' h_box_N' s').mcs t :=
      (box_stable_in_rooted_succ_discrete_fmcs N' h_N' h_box_N' φ s' t).mpr h_box_in_N'
    exact SetMaximalConsistent.implication_property
      ((rooted_succ_discrete_fmcs N' h_N' h_box_N' s').is_mcs t)
      (theorem_in_mcs ((rooted_succ_discrete_fmcs N' h_N' h_box_N' s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_in_N : Formula.box φ ∈ N from
      (box_stable_in_rooted_succ_discrete_fmcs N h_N h_box_N φ s t).mpr h_box_in_N
    suffices h_box_A : Formula.box φ ∈ A from (h_eqN φ).mp h_box_A
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ A :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h_mcs
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨A, h_mcs⟩ (Formula.neg φ) h_diamond_neg
    have h_box_discrete_v : Formula.box next_top ∈ v.formulas :=
      (h_equiv next_top).mp h_box_discrete
    have h_fam_v_mem : rooted_succ_discrete_fmcs v.formulas v.is_mcs h_box_discrete_v t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N)
          (h_box_N : Formula.box next_top ∈ N) (s : ℤ),
          (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
          fam = rooted_succ_discrete_fmcs N h_N h_box_N s } :=
      ⟨v.formulas, v.is_mcs, h_box_discrete_v, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v := h_all (rooted_succ_discrete_fmcs v.formulas v.is_mcs h_box_discrete_v t)
      h_fam_v_mem
    rw [rooted_succ_discrete_fmcs_at_s] at h_phi_v
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v h_neg_phi_v
  eval_family := rooted_succ_discrete_fmcs A h_mcs h_box_discrete 0
  eval_family_mem := ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩

/-! ## Discrete Restricted Coherence

Restricted temporal and Until/Since coherence for `cantor_bfmcs_discrete`.
These are the three conditions needed by the parametric representation theorem.

The key technique: for backward coherence (BUC), the squeeze lemma maps C4
counterexample witnesses back to integers. For forward coherence (TC, FUC),
the step decomposition via BX5 self-accumulation advances the Until formula
one step at a time using the no-gap property.
-/

/--
Restricted backward Until/Since coherence for `cantor_bfmcs_discrete`.
Uses `limit_satisfies_c4`/`c4'` (counterexample elimination) combined with
the squeeze lemma to map C4 witnesses back to integers.
-/
theorem cantor_bfmcs_discrete_restricted_buc (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_discrete : Formula.box next_top ∈ A) (root : Formula) :
    (cantor_bfmcs_discrete A h_mcs h_box_discrete).restricted_backward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_discrete_N := box_discrete_gives_discreteness N h_N h_box_N
  set offset := (-s : ℤ)
  -- Helper to unfold the fam.mcs definition
  have h_mcs_eq : ∀ t : ℤ, (rooted_succ_discrete_fmcs N h_N h_box_N s).mcs t =
      limit_f N h_N (succ_embed N h_N h_discrete_N (t + offset)).val := by
    intro t; rfl
  constructor
  · -- Until backward: contrapositive via C4
    intro t φ ψ _ ⟨u, htu, hφu, h_guard⟩
    by_contra h_not_until
    rw [h_mcs_eq] at h_not_until hφu
    have h_neg_until : (Formula.untl φ ψ).neg ∈
        limit_f N h_N (succ_embed N h_N h_discrete_N (t + offset)).val := by
      rcases SetMaximalConsistent.negation_complete
        (limit_c0 N h_N _ (succ_embed N h_N h_discrete_N (t + offset)).property)
        (Formula.untl φ ψ) with h | h
      · exact absurd h h_not_until
      · exact h
    obtain ⟨z, hz, htz, hzu, hψneg⟩ := limit_satisfies_c4 N h_N
      (succ_embed N h_N h_discrete_N (t + offset)).val
      (succ_embed N h_N h_discrete_N (u + offset)).val
      (succ_embed N h_N h_discrete_N (t + offset)).property
      (succ_embed N h_N h_discrete_N (u + offset)).property
      (succ_embed_strictMono N h_N h_discrete_N (show t + offset < u + offset by omega))
      ψ φ h_neg_until hφu
    obtain ⟨k, hk_lo, hk_hi, hk_eq⟩ := succ_embed_squeeze_strict N h_N h_discrete_N
      (t + offset) (u + offset) (by omega)
      ⟨z, hz⟩ htz hzu
    have hψneg' : ψ.neg ∈ limit_f N h_N (succ_embed N h_N h_discrete_N k).val := by
      have := congrArg Subtype.val hk_eq; simp at this; rwa [this]
    have hψ_guard := h_guard (k - offset) (by omega) (by omega)
    rw [h_mcs_eq, show k - offset + offset = k from by omega] at hψ_guard
    exact set_consistent_not_both (limit_c0 N h_N _ (succ_embed N h_N h_discrete_N k).property).1
      ψ hψ_guard hψneg'
  · -- Since backward: contrapositive via C4'
    intro t φ ψ _ ⟨u, hut, hφu, h_guard⟩
    by_contra h_not_since
    rw [h_mcs_eq] at h_not_since hφu
    have h_neg_since : (Formula.snce φ ψ).neg ∈
        limit_f N h_N (succ_embed N h_N h_discrete_N (t + offset)).val := by
      rcases SetMaximalConsistent.negation_complete
        (limit_c0 N h_N _ (succ_embed N h_N h_discrete_N (t + offset)).property)
        (Formula.snce φ ψ) with h | h
      · exact absurd h h_not_since
      · exact h
    obtain ⟨z, hz, huz, hzt, hψneg⟩ := limit_satisfies_c4' N h_N
      (succ_embed N h_N h_discrete_N (t + offset)).val
      (succ_embed N h_N h_discrete_N (u + offset)).val
      (succ_embed N h_N h_discrete_N (t + offset)).property
      (succ_embed N h_N h_discrete_N (u + offset)).property
      (succ_embed_strictMono N h_N h_discrete_N (show u + offset < t + offset by omega))
      ψ φ h_neg_since hφu
    obtain ⟨k, hk_lo, hk_hi, hk_eq⟩ := succ_embed_squeeze_strict N h_N h_discrete_N
      (u + offset) (t + offset) (by omega)
      ⟨z, hz⟩ huz hzt
    have hψneg' : ψ.neg ∈ limit_f N h_N (succ_embed N h_N h_discrete_N k).val := by
      have := congrArg Subtype.val hk_eq; simp at this; rwa [this]
    have hψ_guard := h_guard (k - offset) (by omega) (by omega)
    rw [h_mcs_eq, show k - offset + offset = k from by omega] at hψ_guard
    exact set_consistent_not_both (limit_c0 N h_N _ (succ_embed N h_N h_discrete_N k).property).1
      ψ hψ_guard hψneg'

/--
Restricted temporal coherence for `cantor_bfmcs_discrete`.
F(phi) ∈ fam.mcs(t) → ∃ s > t, phi ∈ fam.mcs(s) and symmetric for P.

Uses `succ_embed_surjective` to map `limit_F_resolution` / `limit_P_resolution`
witnesses back to integers. The surjectivity lemma guarantees that every domain
point corresponds to an embedded integer, enabling the same proof pattern as
the dense case (which uses the Cantor isomorphism for the same purpose).
-/
theorem cantor_bfmcs_discrete_restricted_tc (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_discrete : Formula.box next_top ∈ A)
    (root : Formula)
    (_ : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ (extendedDeferralClosure root).toList) :
    (cantor_bfmcs_discrete A h_mcs h_box_discrete).restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_discrete_N := box_discrete_gives_discreteness N h_N h_box_N
  set offset := (-s : ℤ)
  have h_mcs_eq : ∀ t : ℤ, (rooted_succ_discrete_fmcs N h_N h_box_N s).mcs t =
      limit_f N h_N (succ_embed N h_N h_discrete_N (t + offset)).val := by
    intro t; rfl
  constructor
  · -- Forward F direction: F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)
    intro t φ _ h_F
    rw [h_mcs_eq] at h_F
    obtain ⟨y, hy, hlt, hφy⟩ := limit_F_resolution N h_N
      (succ_embed N h_N h_discrete_N (t + offset)).val
      (succ_embed N h_N h_discrete_N (t + offset)).property φ h_F
    obtain ⟨m, hm⟩ := succ_embed_surjective N h_N h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_⟩
    · have h_lt' : succ_embed N h_N h_discrete_N (t + offset) <
          succ_embed N h_N h_discrete_N m := hm ▸ hlt
      have := succ_embed_strictMono N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f N h_N (succ_embed N h_N h_discrete_N m).val
      rw [show (succ_embed N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy
  · -- Backward P direction: P(φ) ∈ fam.mcs(t) → ∃ s < t, φ ∈ fam.mcs(s)
    intro t φ _ h_P
    rw [h_mcs_eq] at h_P
    obtain ⟨y, hy, hlt, hφy⟩ := limit_P_resolution N h_N
      (succ_embed N h_N h_discrete_N (t + offset)).val
      (succ_embed N h_N h_discrete_N (t + offset)).property φ h_P
    obtain ⟨m, hm⟩ := succ_embed_surjective N h_N h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_⟩
    · have h_lt' : succ_embed N h_N h_discrete_N m <
          succ_embed N h_N h_discrete_N (t + offset) := hm ▸ hlt
      have := succ_embed_strictMono N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f N h_N (succ_embed N h_N h_discrete_N m).val
      rw [show (succ_embed N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy

/--
Restricted forward Until/Since coherence for `cantor_bfmcs_discrete`.
U(phi,psi) ∈ fam.mcs(t) → ∃ s > t, phi ∈ fam.mcs(s) ∧ guard(t,s).

Uses `succ_embed_surjective` to map `limit_satisfies_c5_strong` / `c5'_strong`
witnesses back to integers. The guard transfers via `succ_embed_squeeze_strict`:
any integer between t and s maps to a domain point between the source and witness,
which is covered by the C5 guard.
-/
theorem cantor_bfmcs_discrete_restricted_fuc (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_discrete : Formula.box next_top ∈ A) (root : Formula) :
    (cantor_bfmcs_discrete A h_mcs h_box_discrete).restricted_forward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_discrete_N := box_discrete_gives_discreteness N h_N h_box_N
  set offset := (-s : ℤ)
  have h_mcs_eq : ∀ t : ℤ, (rooted_succ_discrete_fmcs N h_N h_box_N s).mcs t =
      limit_f N h_N (succ_embed N h_N h_discrete_N (t + offset)).val := by
    intro t; rfl
  constructor
  · -- Until forward: untl(φ,ψ) ∈ fam.mcs t → ∃ u > t, φ ∈ fam.mcs u ∧ guard
    intro t φ ψ _ h_until
    rw [h_mcs_eq] at h_until
    obtain ⟨y, hy, hxty, hφy, h_guard⟩ := limit_satisfies_c5_strong N h_N
      (succ_embed N h_N h_discrete_N (t + offset)).val
      (succ_embed N h_N h_discrete_N (t + offset)).property ψ φ h_until
    obtain ⟨m, hm⟩ := succ_embed_surjective N h_N h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_, ?_⟩
    · have h_lt' : succ_embed N h_N h_discrete_N (t + offset) <
          succ_embed N h_N h_discrete_N m := hm ▸ hxty
      have := succ_embed_strictMono N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f N h_N (succ_embed N h_N h_discrete_N m).val
      rw [show (succ_embed N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy
    · -- Guard: all integers r between t and (m - offset) have ψ in their MCS.
      intro r htr hru
      rw [h_mcs_eq]
      -- r + offset is between t + offset and m, so succ_embed(r + offset) is
      -- between succ_embed(t + offset) and succ_embed(m) = ⟨y, hy⟩.
      have h_lt1 : succ_embed N h_N h_discrete_N (t + offset) <
          succ_embed N h_N h_discrete_N (r + offset) :=
        succ_embed_strictMono N h_N h_discrete_N (show t + offset < r + offset by omega)
      have h_lt2 : succ_embed N h_N h_discrete_N (r + offset) <
          succ_embed N h_N h_discrete_N m :=
        succ_embed_strictMono N h_N h_discrete_N (show r + offset < m by omega)
      have h_lt2' : (succ_embed N h_N h_discrete_N (r + offset)) < ⟨y, hy⟩ := by
        rw [← hm]; exact h_lt2
      exact h_guard (succ_embed N h_N h_discrete_N (r + offset)).val
        (succ_embed N h_N h_discrete_N (r + offset)).property h_lt1 h_lt2'
  · -- Since forward: snce(φ,ψ) ∈ fam.mcs t → ∃ u < t, φ ∈ fam.mcs u ∧ guard
    intro t φ ψ _ h_since
    rw [h_mcs_eq] at h_since
    obtain ⟨y, hy, hyxt, hφy, h_guard⟩ := limit_satisfies_c5'_strong N h_N
      (succ_embed N h_N h_discrete_N (t + offset)).val
      (succ_embed N h_N h_discrete_N (t + offset)).property ψ φ h_since
    obtain ⟨m, hm⟩ := succ_embed_surjective N h_N h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_, ?_⟩
    · have h_lt' : succ_embed N h_N h_discrete_N m <
          succ_embed N h_N h_discrete_N (t + offset) := hm ▸ hyxt
      have := succ_embed_strictMono N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f N h_N (succ_embed N h_N h_discrete_N m).val
      rw [show (succ_embed N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy
    · -- Guard: all integers r between (m - offset) and t have ψ in their MCS.
      intro r hyr hrt
      rw [h_mcs_eq]
      have h_lt1 : (⟨y, hy⟩ : LimitDomSubtype N h_N) <
          succ_embed N h_N h_discrete_N (r + offset) := by
        rw [← hm]
        exact succ_embed_strictMono N h_N h_discrete_N (show m < r + offset by omega)
      have h_lt2 : succ_embed N h_N h_discrete_N (r + offset) <
          succ_embed N h_N h_discrete_N (t + offset) :=
        succ_embed_strictMono N h_N h_discrete_N (show r + offset < t + offset by omega)
      exact h_guard (succ_embed N h_N h_discrete_N (r + offset)).val
        (succ_embed N h_N h_discrete_N (r + offset)).property h_lt1 h_lt2

/-! ## Discrete Countermodel

The main integration theorem for the discrete case: constructs a countermodel
from any MCS containing neg(phi) and box(U(T,bot)), using the succ-based
chronicle construction.
-/

/--
Discrete countermodel: given MCS A with `neg(phi) in A` and `box(U(T,bot)) in A`,
build a countermodel on `Int` where `phi` is false.

Uses `cantor_bfmcs_discrete` (sorry-free BFMCS) with the three restricted
coherence conditions (BUC, TC, FUC), all proved via `succ_embed_surjective`
and `succ_embed_squeeze`/`succ_embed_squeeze_strict`. The eval family is
`rooted_succ_discrete_fmcs A h_mcs h_box_discrete 0` which has `mcs 0 = A`,
so `neg(phi) in eval_family.mcs 0`.
-/
theorem dd_countermodel_chronicle_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  refine ⟨Int, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Int, ParametricCanonicalTaskModel Int,
    ShiftClosedParametricCanonicalOmega (cantor_bfmcs_discrete A h_mcs h_box_discrete),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (rooted_succ_discrete_fmcs A h_mcs h_box_discrete 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨rooted_succ_discrete_fmcs A h_mcs h_box_discrete 0,
       ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (rooted_succ_discrete_fmcs A h_mcs h_box_discrete 0).mcs 0 := by
    rw [rooted_succ_discrete_fmcs_at_s]; exact h_neg_in
  exact fully_restricted_parametric_representation_from_neg_membership
    (cantor_bfmcs_discrete A h_mcs h_box_discrete) φ
    (cantor_bfmcs_discrete_restricted_tc A h_mcs h_box_discrete φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (cantor_bfmcs_discrete_restricted_buc A h_mcs h_box_discrete φ)
    (cantor_bfmcs_discrete_restricted_fuc A h_mcs h_box_discrete φ)
    φ (self_mem_subformulaClosure φ)
    (rooted_succ_discrete_fmcs A h_mcs h_box_discrete 0)
    ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/--
Mixed-case countermodel stub: the residual sorry for the case where neither
`□(F'T)` nor `□(U(⊤,⊥))` is in A.

This case represents a "mixed modal class" where some box-accessible worlds
are dense (F'T) and others are discrete (U(T,bot)). Different families in
the BFMCS would need different domain types (Q for dense, Z for discrete),
which cannot coexist in a single BFMCS with a fixed domain type D.

Resolving this case likely requires novel techniques: ultraproducts,
enriched frames, or new BX theorems. See task 122 research report
`01_discrete-bfmcs-research.md` Section 4 for detailed analysis.
-/
theorem dd_countermodel_chronicle_mixed_sorry (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_not_box_dense : (Formula.box next_top.neg).neg ∈ A)
    (h_not_box_discrete : (Formula.box next_top).neg ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  sorry

end Bimodal.Metalogic.BXCanonical.Chronicle
