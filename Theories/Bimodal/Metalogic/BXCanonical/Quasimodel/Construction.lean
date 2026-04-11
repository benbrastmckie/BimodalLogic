import Bimodal.Metalogic.BXCanonical.Quasimodel.HintikkaPoint
import Mathlib.Data.List.Chain

/-!
# Quasimodel Construction with Defect-Discharge

Constructs the Burgess-Xu one-step quasimodel: a finite sequence of Hintikka points
with the defect-discharge property for Until/Since formulas.

## Main Definitions

- `hintikka_step`: The one-step relation between Hintikka points
- `UntilDefect`: A defect in a Hintikka point (Until formula present but goal absent)
- `defect_count`: Number of Until-defects in a Hintikka point
- `QuasimodelChain`: A sequence of Hintikka points with defect discharge

## Main Results

- `quasimodel_chain_exists`: Given an Until defect, a discharging chain exists
- `quasimodel_chain_guard`: The guard formula holds at all intermediate points
- `quasimodel_chain_witness`: The goal formula holds at the endpoint

## References

- Burgess 1984: Defect-discharge construction for Until
- Reynolds 1996: Formal treatment of quasimodel chains
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical

/-! ## One-Step Relation -/

/-- The Burgess-Xu one-step relation between Hintikka points.
    h1 → h2 captures:
    - G-propagation: G(χ) ∈ h1 → χ ∈ h2
    - H-backward: H(χ) ∈ h2 → χ ∈ h1
    - Until defect propagation: if φ U ψ ∈ h1 and ψ ∉ h1, then
      φ ∈ h1 and φ U ψ ∈ h2 -/
def hintikka_step {Sigma : Finset Formula} (h1 h2 : HintikkaPoint Sigma) : Prop :=
  -- G-propagation
  (∀ χ : Formula, Formula.all_future χ ∈ h1.formulas → χ ∈ h2.formulas) ∧
  -- H-backward
  (∀ χ : Formula, Formula.all_past χ ∈ h2.formulas → χ ∈ h1.formulas) ∧
  -- Until defect propagation
  (∀ φ ψ : Formula, Formula.untl φ ψ ∈ h1.formulas → ψ ∉ h1.formulas →
    φ ∈ h1.formulas ∧ Formula.untl φ ψ ∈ h2.formulas)

/-! ## Until Defect -/

/-- An Until-defect at a Hintikka point: φ U ψ is in the point but ψ is not.
    This means the Until formula has not been discharged at this point. -/
def UntilDefect {Sigma : Finset Formula} (h : HintikkaPoint Sigma) (φ ψ : Formula) : Prop :=
  Formula.untl φ ψ ∈ h.formulas ∧ ψ ∉ h.formulas

/-- Since-defect: mirror of Until-defect for Since formulas. -/
def SinceDefect {Sigma : Finset Formula} (h : HintikkaPoint Sigma) (φ ψ : Formula) : Prop :=
  Formula.snce φ ψ ∈ h.formulas ∧ ψ ∉ h.formulas

/-! ## Defect Count

The termination measure for the quasimodel construction.
We count the number of Until-formulas in Sigma that are "defective" at a point
(present in the point but their goal absent). Since Sigma is finite and each
step either discharges a defect or the chain has reached its goal, the chain
must terminate in at most |Sigma| steps. -/

open Classical in
/-- Count the number of Until-defects at a Hintikka point relative to Sigma. -/
noncomputable def defect_count {Sigma : Finset Formula} (h : HintikkaPoint Sigma) : Nat :=
  (Sigma.filter (fun f => match f with
    | Formula.untl _φ ψ => f ∈ h.formulas ∧ ψ ∉ h.formulas
    | _ => False)).card

/-! ## Quasimodel Chain

The quasimodel chain is a finite sequence of Hintikka points h0, h1, ..., hk where:
- Each consecutive pair satisfies hintikka_step
- The guard φ holds at h0, h1, ..., h(k-1)
- The goal ψ holds at hk
- The chain terminates because defects decrease (bounded by |Sigma|)

Instead of constructing this directly (which would require complex well-founded
recursion in Lean), we prove the existence theorem using the BXPoint infrastructure:
we construct the chain at the MCS level and project down to Hintikka points.

The key insight is that the quasimodel chain existence follows from the
BX axioms applied at the MCS level, then projected to Sigma-signatures. -/

-- A quasimodel chain for an Until formula φ U ψ starting at w.
-- This is a list of BXPoints w = v0, v1, ..., vk such that:
-- - bx_le vi v(i+1) for each i
-- - φ ∈ vi.formulas for each i < k
-- - ψ ∈ vk.formulas
-- - For all u with bx_le w u and bx_le u vk and ¬bx_le vk u, φ ∈ u.formulas
--
-- Rather than constructing this explicitly, we prove the existence of
-- the witness vk directly using the BX axiom infrastructure.

-- The quasimodel construction ultimately serves to prove the four sorry targets
-- in Frame.lean. The key mathematical content is in Realization.lean (Phase 4)
-- and LocusControl.lean (Phase 5), which lift the abstract chain to BXPoints.
--
-- For the construction phase, we establish the key intermediate lemmas that
-- the BX axioms give us at the MCS level.

/-- Key lemma: BX9 applied at MCS level.
    If φ U ψ ∈ w.formulas, then φ ∈ w.formulas ∨ ψ ∈ w.formulas. -/
theorem until_elim_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ w.formulas) :
    φ ∈ w.formulas ∨ ψ ∈ w.formulas := by
  -- BX9: (φ U ψ) → (φ ∨ ψ), where ∨ is ¬φ → ψ
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
  have h_or : Formula.or φ ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h
  -- or is ¬φ → ψ. If φ ∈ w, done. If φ ∉ w, then ¬φ ∈ w, so ψ ∈ w.
  rcases SetMaximalConsistent.negation_complete w.is_mcs φ with h_phi | h_neg_phi
  · left; exact h_phi
  · right
    exact SetMaximalConsistent.implication_property w.is_mcs h_or h_neg_phi

/-- Key lemma: BX5 self-accumulation at MCS level.
    If φ U ψ ∈ w.formulas, then (φ ∧ (φ U ψ)) U ψ ∈ w.formulas. -/
theorem self_accum_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ w.formulas) :
    Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.self_accum_until φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- Key lemma: BX10 at MCS level.
    If φ U ψ ∈ w.formulas, then F(ψ) ∈ w.formulas. -/
theorem until_F_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ w.formulas) :
    Formula.some_future ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.until_F φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- Key lemma: BX4 connectedness at MCS level.
    If φ ∈ w.formulas, then G(P(φ)) ∈ w.formulas. -/
theorem connect_future_mcs {w : BXPoint} {φ : Formula}
    (h : φ ∈ w.formulas) :
    Formula.all_future (Formula.some_past φ) ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.connect_future φ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- Key lemma: BX8 reflexive introduction at MCS level.
    If ψ ∈ w.formulas, then φ U ψ ∈ w.formulas. -/
theorem refl_intro_until_mcs {w : BXPoint} {φ ψ : Formula}
    (h : ψ ∈ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.refl_intro_until φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## Since-direction MCS lemmas -/

/-- BX9' at MCS level. -/
theorem since_elim_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.snce φ ψ ∈ w.formulas) :
    φ ∈ w.formulas ∨ ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.since_elim φ ψ)
  have h_or : Formula.or φ ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h
  rcases SetMaximalConsistent.negation_complete w.is_mcs φ with h_phi | h_neg_phi
  · left; exact h_phi
  · right
    exact SetMaximalConsistent.implication_property w.is_mcs h_or h_neg_phi

/-- BX5' at MCS level. -/
theorem self_accum_since_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.snce φ ψ ∈ w.formulas) :
    Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.self_accum_since φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX10' at MCS level. -/
theorem since_P_mcs {w : BXPoint} {φ ψ : Formula}
    (h : Formula.snce φ ψ ∈ w.formulas) :
    Formula.some_past ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.since_P φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX4' at MCS level. -/
theorem connect_past_mcs {w : BXPoint} {φ : Formula}
    (h : φ ∈ w.formulas) :
    Formula.all_past (Formula.some_future φ) ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.connect_past φ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-- BX8' at MCS level. -/
theorem refl_intro_since_mcs {w : BXPoint} {φ ψ : Formula}
    (h : ψ ∈ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas := by
  have h_ax := DerivationTree.axiom [] _ (Axiom.refl_intro_since φ ψ)
  exact SetMaximalConsistent.implication_property w.is_mcs
    (theorem_in_mcs w.is_mcs h_ax) h

/-! ## Until-Defect Set and Strict-Decrease Infrastructure

The refined `QuasimodelChain` construction tracks a "target defect"
`(φ, ψ)` (an Until-formula whose right-hand side is absent at the initial
point of the chain). Phase 3 of task 98 plan v3 introduces the scaffolding
required for well-founded recursion on `defect_count`:

- `untilDefectSet`: the set of Until-defects at a Hintikka point (as a `Finset`)
- `defect_count_eq_card`: the count equals the cardinality of the defect set
- `hintikka_step_defect_mono`: under a monotonicity hypothesis, defects do
  not grow along a `hintikka_step`
- `hintikka_step_target_decrease`: if the target defect is discharged (its
  witness `ψ` enters the next point), the defect count strictly decreases

The monotonicity hypothesis (`defect_mono`) is required because the abstract
`hintikka_step` relation does not force `h2.formulas ⊆ h1.formulas`; without
the hypothesis, unrelated Until-formulas could enter `h2` and cancel the
target discharge. The hypothesis is discharged at the realization-lifting
level in Phase 5, where the lifted `v_{i+1}` is constructed from a seed
that includes `h_i.formulas` and thus carries forward all defects that
were not explicitly discharged. -/

open Classical in
/-- The set of Until-defects at a Hintikka point, as a `Finset`. -/
noncomputable def untilDefectSet {Sigma : Finset Formula} (h : HintikkaPoint Sigma) :
    Finset Formula :=
  Sigma.filter (fun f => match f with
    | Formula.untl _φ ψ => f ∈ h.formulas ∧ ψ ∉ h.formulas
    | _ => False)

open Classical in
theorem defect_count_eq_card {Sigma : Finset Formula} (h : HintikkaPoint Sigma) :
    defect_count h = (untilDefectSet h).card := by
  rfl

open Classical in
theorem mem_untilDefectSet_iff {Sigma : Finset Formula} {h : HintikkaPoint Sigma}
    {f : Formula} :
    f ∈ untilDefectSet h ↔
      f ∈ Sigma ∧ (∃ φ ψ, f = Formula.untl φ ψ ∧ f ∈ h.formulas ∧ ψ ∉ h.formulas) := by
  unfold untilDefectSet
  rw [Finset.mem_filter]
  constructor
  · rintro ⟨hSigma, hmatch⟩
    refine ⟨hSigma, ?_⟩
    cases f with
    | untl φ ψ =>
      simp only at hmatch
      exact ⟨φ, ψ, rfl, hmatch.1, hmatch.2⟩
    | _ => simp only at hmatch
  · rintro ⟨hSigma, φ, ψ, rfl, h_in, h_out⟩
    refine ⟨hSigma, ?_⟩
    simp only
    exact ⟨h_in, h_out⟩

open Classical in
/-- If the target Until-defect `φ U ψ` is dischargeable at `h1` (i.e. `ψ ∉ h1`
    and `ψ ∈ h2`), and `h2`'s Until-defect set is contained in `h1`'s, then
    the defect set strictly shrinks across the step.

    The "monotonic defect" hypothesis `defect_mono` is the essential
    assumption: it captures the intuition that `h2` does not introduce new
    Until-defects beyond those carried over from `h1`. In the realization
    lifting (Phase 5) this holds by construction of the chain. -/
theorem hintikka_step_target_decrease
    {Sigma : Finset Formula} {h1 h2 : HintikkaPoint Sigma}
    {φ ψ : Formula}
    (h_target_in : Formula.untl φ ψ ∈ h1.formulas)
    (h_target_sigma : Formula.untl φ ψ ∈ Sigma)
    (h_not : ψ ∉ h1.formulas)
    (h_witness : ψ ∈ h2.formulas)
    (defect_mono : untilDefectSet h2 ⊆ untilDefectSet h1) :
    defect_count h2 < defect_count h1 := by
  -- The target Until `φ U ψ` is a defect at h1 but not at h2 (witness reached).
  have h_in_h1 : Formula.untl φ ψ ∈ untilDefectSet h1 := by
    rw [mem_untilDefectSet_iff]
    exact ⟨h_target_sigma, φ, ψ, rfl, h_target_in, h_not⟩
  have h_not_in_h2 : Formula.untl φ ψ ∉ untilDefectSet h2 := by
    rw [mem_untilDefectSet_iff]
    rintro ⟨_, φ', ψ', heq, _, h_out⟩
    -- From heq : Formula.untl φ ψ = Formula.untl φ' ψ', deduce ψ = ψ'
    have : ψ = ψ' := by injection heq
    exact h_out (this ▸ h_witness)
  -- The defect set strictly shrinks: h2 ⊆ h1 and the target is in h1 \ h2.
  rw [defect_count_eq_card, defect_count_eq_card]
  exact Finset.card_lt_card (by
    refine ⟨defect_mono, ?_⟩
    intro h_eq
    exact h_not_in_h2 (h_eq h_in_h1))

open Classical in
/-- Symmetric definition for Since: the set of Since-defects. -/
noncomputable def sinceDefectSet {Sigma : Finset Formula} (h : HintikkaPoint Sigma) :
    Finset Formula :=
  Sigma.filter (fun f => match f with
    | Formula.snce _φ ψ => f ∈ h.formulas ∧ ψ ∉ h.formulas
    | _ => False)

open Classical in
noncomputable def since_defect_count {Sigma : Finset Formula} (h : HintikkaPoint Sigma) : Nat :=
  (sinceDefectSet h).card

open Classical in
theorem mem_sinceDefectSet_iff {Sigma : Finset Formula} {h : HintikkaPoint Sigma}
    {f : Formula} :
    f ∈ sinceDefectSet h ↔
      f ∈ Sigma ∧ (∃ φ ψ, f = Formula.snce φ ψ ∧ f ∈ h.formulas ∧ ψ ∉ h.formulas) := by
  unfold sinceDefectSet
  rw [Finset.mem_filter]
  constructor
  · rintro ⟨hSigma, hmatch⟩
    refine ⟨hSigma, ?_⟩
    cases f with
    | snce φ ψ =>
      simp only at hmatch
      exact ⟨φ, ψ, rfl, hmatch.1, hmatch.2⟩
    | _ => simp only at hmatch
  · rintro ⟨hSigma, φ, ψ, rfl, h_in, h_out⟩
    refine ⟨hSigma, ?_⟩
    simp only
    exact ⟨h_in, h_out⟩

open Classical in
/-- Since-dual of `hintikka_step_target_decrease`. -/
theorem hintikka_step_target_decrease_since
    {Sigma : Finset Formula} {h1 h2 : HintikkaPoint Sigma}
    {φ ψ : Formula}
    (h_target_in : Formula.snce φ ψ ∈ h1.formulas)
    (h_target_sigma : Formula.snce φ ψ ∈ Sigma)
    (h_not : ψ ∉ h1.formulas)
    (h_witness : ψ ∈ h2.formulas)
    (defect_mono : sinceDefectSet h2 ⊆ sinceDefectSet h1) :
    since_defect_count h2 < since_defect_count h1 := by
  have h_in_h1 : Formula.snce φ ψ ∈ sinceDefectSet h1 := by
    rw [mem_sinceDefectSet_iff]
    exact ⟨h_target_sigma, φ, ψ, rfl, h_target_in, h_not⟩
  have h_not_in_h2 : Formula.snce φ ψ ∉ sinceDefectSet h2 := by
    rw [mem_sinceDefectSet_iff]
    rintro ⟨_, φ', ψ', heq, _, h_out⟩
    have : ψ = ψ' := by injection heq
    exact h_out (this ▸ h_witness)
  unfold since_defect_count
  exact Finset.card_lt_card (by
    refine ⟨defect_mono, ?_⟩
    intro h_eq
    exact h_not_in_h2 (h_eq h_in_h1))

/-! ## Refined QuasimodelChain Type

A `QuasimodelChain` tracks a finite list of Hintikka points with consecutive
`hintikka_step` relations, together with a **target defect** `(φ, ψ)`: an
Until-formula present at the chain's head whose witness `ψ` we aim to
eventually reach at the chain's last point.

The target-defect annotation is essential for the well-founded recursion
used in `hintikka_chain_exists` (Phase 3 remaining work): each chain-step
either discharges the target (reaches `ψ`) or carries the target forward
with a strictly-smaller defect count (under the `defect_mono` hypothesis
from Phase 5). -/

/-- A quasimodel chain with a fixed target Until-defect `(target_lhs U target_rhs)`.

    The chain is a `List (HintikkaPoint Sigma)` of length ≥ 1 with:
    - `head` carrying the target defect: `(target_lhs U target_rhs) ∈ head.formulas`
    - consecutive pairs satisfying `hintikka_step`
    - a proof `target_present` that `target_rhs` is in the head or the target
      Until is present (bookkeeping for induction)

    This type is the Phase 3 scaffolding; Phase 3's remaining task
    (`hintikka_chain_exists`) will construct values of this type via
    well-founded recursion on `defect_count`. -/
structure QuasimodelChain (Sigma : Finset Formula) (target_lhs target_rhs : Formula) where
  /-- The list of Hintikka points forming the chain (always nonempty). -/
  points : List (HintikkaPoint Sigma)
  /-- The chain is nonempty. -/
  nonempty : points ≠ []
  /-- The target Until-formula is present at the head. -/
  target_at_head : Formula.untl target_lhs target_rhs ∈ (points.head nonempty).formulas
  /-- Consecutive pairs satisfy `hintikka_step`. -/
  step_chain : ∀ i : Fin (points.length - 1),
    hintikka_step (points.get ⟨i.val, by omega⟩) (points.get ⟨i.val + 1, by omega⟩)

/-- The last Hintikka point in a quasimodel chain. -/
noncomputable def QuasimodelChain.last {Sigma : Finset Formula} {φ ψ : Formula}
    (c : QuasimodelChain Sigma φ ψ) : HintikkaPoint Sigma :=
  c.points.getLast c.nonempty

/-- The chain has reached its witness when the target's right-hand side
    appears at the last point. -/
def QuasimodelChain.witnessReached {Sigma : Finset Formula} {φ ψ : Formula}
    (c : QuasimodelChain Sigma φ ψ) : Prop :=
  ψ ∈ c.last.formulas

/-- The chain's length as a natural number. -/
def QuasimodelChain.length {Sigma : Finset Formula} {φ ψ : Formula}
    (c : QuasimodelChain Sigma φ ψ) : Nat :=
  c.points.length

theorem QuasimodelChain.length_pos {Sigma : Finset Formula} {φ ψ : Formula}
    (c : QuasimodelChain Sigma φ ψ) : 0 < c.length := by
  unfold QuasimodelChain.length
  exact List.length_pos_iff.mpr c.nonempty

/-- The singleton quasimodel chain: a one-point chain trivially satisfies
    `step_chain` (empty quantification) and exposes the target formula
    directly. -/
noncomputable def QuasimodelChain.singleton {Sigma : Finset Formula} {φ ψ : Formula}
    (h : HintikkaPoint Sigma) (h_target : Formula.untl φ ψ ∈ h.formulas) :
    QuasimodelChain Sigma φ ψ where
  points := [h]
  nonempty := by simp
  target_at_head := by simpa using h_target
  step_chain := by
    intro i
    exact absurd i.isLt (by simp)

/-! ### `hintikka_chain_exists` via step-oracle

The abstract existence theorem: given a step oracle that, at every
Hintikka point carrying the target defect but missing the witness,
produces a next point either reaching the witness or strictly
decreasing the defect count, we can build a list of Hintikka points
starting at `h0` with consecutive `hintikka_step` relations and
`ψ` present at the last point.

This lemma is purely combinatorial: it takes the oracle as a parameter
and performs the well-founded recursion on `defect_count`. The Phase 5
realization lifting discharges the oracle by constructing steps via
Lindenbaum extension on the Phase 4 seed-consistent seed.

We use a `HintikkaRawChain` predicate on `List (HintikkaPoint Sigma)`
rather than extending `QuasimodelChain.target_at_head` all the way
through, because the oracle only guarantees the target defect at
non-terminal points. The head carries the target; interior points
carry the target (because they did not yet reach `ψ`); the last
point carries `ψ` but need not carry the target. -/

/-- A Hintikka point bundled with a concrete `BXPoint` witness whose formula
    set is a superset of the point's formulas. This is the "BXPoint-backed"
    strengthening of a `HintikkaPoint`: it lets us discharge any
    `SetConsistent` obligation on subsets of `h.formulas` via the MCS
    consistency of `w`.

    Introduced for task 99 (Phase 4 blocker of task 98): threading a
    `BXPoint` witness through `HintikkaStepOracle` and `hintikka_chain_exists`
    collapses the chain-step seed-consistency obligation to a one-line
    subset witness, mirroring the `h_neg_in = false` branch of
    `enriched_seed_consistent_until` in `Realization.lean:271-276`. -/
structure WitnessedHintikka (Sigma : Finset Formula) where
  /-- The underlying Hintikka point. -/
  point : HintikkaPoint Sigma
  /-- A concrete `BXPoint` witness backing `point`. -/
  witness : BXPoint
  /-- Every formula of `point` is a formula of the backing `witness`. -/
  point_subset_witness : ∀ f ∈ point.formulas, f ∈ witness.formulas

/-- The step-oracle signature: at any Hintikka point carrying the target
    Until-defect and missing the witness, one can step to a next point
    either reaching the witness or strictly decreasing the defect count
    while preserving the target defect.

    The stepped point is additionally equipped with a concrete `BXPoint`
    backing witness (task 99: BXPoint-backed strengthening). This is what
    allows downstream users (parent task 98 Phase 4) to discharge
    `SetConsistent` obligations on subsets of the stepped point's
    formulas via MCS consistency of the witness. -/
def HintikkaStepOracle {Sigma : Finset Formula} (φ ψ : Formula) : Prop :=
  ∀ h : HintikkaPoint Sigma,
    Formula.untl φ ψ ∈ h.formulas → ψ ∉ h.formulas →
    ∃ wh' : WitnessedHintikka Sigma, hintikka_step h wh'.point ∧
      (ψ ∈ wh'.point.formulas ∨
        (Formula.untl φ ψ ∈ wh'.point.formulas ∧
          defect_count wh'.point < defect_count h))

/-- A raw Hintikka chain: a nonempty list of Hintikka points with each
    consecutive pair related by `hintikka_step`.

    Phrased via Mathlib's `List.IsChain` to get cons/append/last lemmas
    for free. -/
structure HintikkaRawChain (Sigma : Finset Formula) where
  points : List (HintikkaPoint Sigma)
  nonempty : points ≠ []
  is_chain : points.IsChain hintikka_step

/-- The last point of a raw chain. -/
noncomputable def HintikkaRawChain.last {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) : HintikkaPoint Sigma :=
  c.points.getLast c.nonempty

/-- The head of a raw chain. -/
noncomputable def HintikkaRawChain.head {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) : HintikkaPoint Sigma :=
  c.points.head c.nonempty

/-- Singleton raw chain. -/
noncomputable def HintikkaRawChain.singleton {Sigma : Finset Formula}
    (h : HintikkaPoint Sigma) : HintikkaRawChain Sigma where
  points := [h]
  nonempty := by simp
  is_chain := by simp

@[simp] theorem HintikkaRawChain.singleton_points {Sigma : Finset Formula}
    (h : HintikkaPoint Sigma) :
    (HintikkaRawChain.singleton h).points = [h] := rfl

@[simp] theorem HintikkaRawChain.singleton_last {Sigma : Finset Formula}
    (h : HintikkaPoint Sigma) :
    (HintikkaRawChain.singleton h).last = h := by
  unfold HintikkaRawChain.last
  simp [HintikkaRawChain.singleton_points]

@[simp] theorem HintikkaRawChain.singleton_head {Sigma : Finset Formula}
    (h : HintikkaPoint Sigma) :
    (HintikkaRawChain.singleton h).head = h := by
  unfold HintikkaRawChain.head
  simp [HintikkaRawChain.singleton_points]

/-- Prepend a Hintikka point to a raw chain, provided the new head
    steps to the old head. -/
noncomputable def HintikkaRawChain.cons {Sigma : Finset Formula}
    (h0 : HintikkaPoint Sigma) (c : HintikkaRawChain Sigma)
    (h_step : hintikka_step h0 c.head) :
    HintikkaRawChain Sigma where
  points := h0 :: c.points
  nonempty := by simp
  is_chain := by
    -- Use List.IsChain.cons: given IsChain r l and ∀ y ∈ l.head?, r x y, get IsChain r (x :: l)
    apply List.IsChain.cons c.is_chain
    intro y hy
    -- hy : y ∈ c.points.head?, need hintikka_step h0 y
    -- c.points is nonempty, so c.points.head? = some c.head = some (c.points.head c.nonempty)
    have h_eq : c.points.head? = some (c.points.head c.nonempty) :=
      List.head?_eq_some_head c.nonempty
    rw [h_eq] at hy
    simp at hy
    -- hy : c.points.head c.nonempty = y
    show hintikka_step h0 y
    have : c.head = y := by
      unfold HintikkaRawChain.head
      exact hy
    rw [← this]
    exact h_step

@[simp] theorem HintikkaRawChain.cons_points {Sigma : Finset Formula}
    (h0 : HintikkaPoint Sigma) (c : HintikkaRawChain Sigma)
    (h_step : hintikka_step h0 c.head) :
    (HintikkaRawChain.cons h0 c h_step).points = h0 :: c.points := rfl

@[simp] theorem HintikkaRawChain.cons_head {Sigma : Finset Formula}
    (h0 : HintikkaPoint Sigma) (c : HintikkaRawChain Sigma)
    (h_step : hintikka_step h0 c.head) :
    (HintikkaRawChain.cons h0 c h_step).head = h0 := by
  unfold HintikkaRawChain.head
  simp [HintikkaRawChain.cons_points]

theorem HintikkaRawChain.cons_last {Sigma : Finset Formula}
    (h0 : HintikkaPoint Sigma) (c : HintikkaRawChain Sigma)
    (h_step : hintikka_step h0 c.head) :
    (HintikkaRawChain.cons h0 c h_step).last = c.last := by
  unfold HintikkaRawChain.last
  simp [HintikkaRawChain.cons_points, List.getLast_cons c.nonempty]

/-- Every point in a raw Hintikka chain is backed by a concrete `BXPoint`
    whose formula set is a superset of the point's formulas.

    Introduced for task 99: this predicate is what allows
    `chain_step_seed_consistent` to discharge the Phase 4 seed-consistency
    obligation via the MCS consistency of the backing witness. -/
def ChainWitnessed {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) : Prop :=
  ∀ h ∈ c.points, ∃ w : BXPoint, ∀ f ∈ h.formulas, f ∈ w.formulas

/-- **Phase 3 main theorem**: `hintikka_chain_exists`.

    Given a step oracle and a starting Hintikka point `h0` carrying the
    target Until-defect (plus a concrete `BXPoint` witness `w0` backing
    `h0`), there exists a raw Hintikka chain starting at `h0`, ending at
    a point where `ψ` is present, and with every point backed by a
    concrete `BXPoint` witness (`ChainWitnessed`).

    The claim is propositional (an `∃`-statement) because the `HintikkaStepOracle`
    itself is propositional; the chain data is extracted by the caller via
    `Classical.choose` if they need a `noncomputable` term. -/
theorem hintikka_chain_exists
    {Sigma : Finset Formula} {φ ψ : Formula}
    (oracle : HintikkaStepOracle (Sigma := Sigma) φ ψ)
    (h0 : HintikkaPoint Sigma) (w0 : BXPoint)
    (h0_sub : ∀ f ∈ h0.formulas, f ∈ w0.formulas)
    (h_target : Formula.untl φ ψ ∈ h0.formulas) :
    ∃ c : HintikkaRawChain Sigma,
      c.head = h0 ∧ ψ ∈ c.last.formulas ∧ ChainWitnessed c := by
  -- Strong induction on `defect_count h0`.
  -- We generalise over `h0` and its backing witness so the inductive
  -- hypothesis applies at the successor (witnessed) Hintikka point.
  suffices h : ∀ n h0 (w0 : BXPoint),
      (∀ f ∈ h0.formulas, f ∈ w0.formulas) →
      defect_count h0 = n →
      Formula.untl φ ψ ∈ h0.formulas →
      ∃ c : HintikkaRawChain Sigma,
        c.head = h0 ∧ ψ ∈ c.last.formulas ∧ ChainWitnessed c by
    exact h (defect_count h0) h0 w0 h0_sub rfl h_target
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro h0 w0 h0_sub h_n h_target
    by_cases h_psi : ψ ∈ h0.formulas
    · -- Already at witness: singleton chain
      refine ⟨HintikkaRawChain.singleton h0, ?_, ?_, ?_⟩
      · simp
      · simpa using h_psi
      · -- ChainWitnessed: only point is h0, backed by w0
        intro h hh
        simp [HintikkaRawChain.singleton_points] at hh
        exact ⟨w0, by subst hh; exact h0_sub⟩
    · -- Not yet at witness: invoke oracle, get witnessed successor
      obtain ⟨wh', h_step, h_cases⟩ := oracle h0 h_target h_psi
      rcases h_cases with h_psi' | ⟨h_target', h_dec⟩
      · -- Oracle reached witness in one step: two-point chain [h0, wh'.point]
        refine ⟨HintikkaRawChain.cons h0
          (HintikkaRawChain.singleton wh'.point) ?_, ?_, ?_, ?_⟩
        · -- hintikka_step h0 (singleton wh'.point).head
          simpa [HintikkaRawChain.singleton_head] using h_step
        · -- head = h0
          simp
        · -- ψ ∈ last.formulas
          rw [HintikkaRawChain.cons_last]
          simpa using h_psi'
        · -- ChainWitnessed
          intro h hh
          simp [HintikkaRawChain.cons_points,
            HintikkaRawChain.singleton_points] at hh
          rcases hh with rfl | rfl
          · exact ⟨w0, h0_sub⟩
          · exact ⟨wh'.witness, wh'.point_subset_witness⟩
      · -- Oracle stepped to strictly smaller defect: recurse via ih
        have h_dec' : defect_count wh'.point < n := h_n ▸ h_dec
        obtain ⟨c', hc'_head, hc'_witness, hc'_witd⟩ :=
          ih (defect_count wh'.point) h_dec' wh'.point wh'.witness
            wh'.point_subset_witness rfl h_target'
        refine ⟨HintikkaRawChain.cons h0 c' (by rw [hc'_head]; exact h_step),
          ?_, ?_, ?_⟩
        · simp
        · rw [HintikkaRawChain.cons_last]; exact hc'_witness
        · -- ChainWitnessed: h0 backed by w0; rest covered by hc'_witd
          intro h hh
          simp [HintikkaRawChain.cons_points] at hh
          rcases hh with rfl | h_in
          · exact ⟨w0, h0_sub⟩
          · exact hc'_witd h h_in

/-- **Task 99 seed-consistency lemma**: any subset of a chain point's
    formulas is `SetConsistent`, provided the chain is witnessed.

    This is the lemma that unblocks parent task 98 Phase 4
    (`enriched_seed_consistent_until`-style reductions against a chain
    point). It mirrors the `h_neg_in = false` branch of
    `enriched_seed_consistent_until` in `Realization.lean:271-276`:

        have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := ...
        exact w.is_mcs.1 L h_L_in_w ⟨d⟩

    The one-line proof is possible because `ChainWitnessed` gives us a
    concrete `BXPoint` backing each point of the chain, so the obligation
    `SetConsistent S` for any `S ⊆ h.formulas` collapses to the MCS
    consistency of the witness. -/
theorem chain_step_seed_consistent
    {Sigma : Finset Formula}
    {c : HintikkaRawChain Sigma} (h_wit : ChainWitnessed c)
    {h : HintikkaPoint Sigma} (h_mem : h ∈ c.points)
    (S : Set Formula) (h_sub : S ⊆ (h.formulas : Set Formula)) :
    SetConsistent S := by
  -- Extract the BXPoint witness backing `h`
  obtain ⟨w, hw⟩ := h_wit h h_mem
  -- Close: any list from S has all elements in w.formulas, so
  -- `w.is_mcs.1` discharges the `Consistent L` obligation.
  intro L hL ⟨d⟩
  have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := by
    intro α hα
    exact hw α (h_sub (hL α hα))
  exact w.is_mcs.1 L h_L_in_w ⟨d⟩

/-- **Since dual** of `HintikkaStepOracle`: the oracle goes backwards
    (producing `h'` that steps to `h`) and the strict-decrease is on
    `since_defect_count`.

    Task 98 Phase 4b strengthens the Since oracle to return a
    `WitnessedHintikka` (the same BXPoint-backing strengthening task 99
    applied to the Until oracle) so that the Since dual of
    `chain_step_seed_consistent` can be proved by the same one-line
    MCS-subset route. -/
def HintikkaStepOracleSince {Sigma : Finset Formula} (φ ψ : Formula) : Prop :=
  ∀ h : HintikkaPoint Sigma,
    Formula.snce φ ψ ∈ h.formulas → ψ ∉ h.formulas →
    ∃ wh' : WitnessedHintikka Sigma, hintikka_step wh'.point h ∧
      (ψ ∈ wh'.point.formulas ∨
        (Formula.snce φ ψ ∈ wh'.point.formulas ∧
          since_defect_count wh'.point < since_defect_count h))

/-- Append a single Hintikka point to a raw chain, provided the old
    last point steps to the new point. Used by `hintikka_chain_exists_since`
    to extend chains on the right (toward the present). -/
noncomputable def HintikkaRawChain.snoc {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) (h0 : HintikkaPoint Sigma)
    (h_step : hintikka_step c.last h0) :
    HintikkaRawChain Sigma where
  points := c.points ++ [h0]
  nonempty := by
    intro h_eq
    exact c.nonempty (List.append_eq_nil_iff.mp h_eq).1
  is_chain := by
    apply List.IsChain.append c.is_chain (by simp)
    intro x hx y hy
    -- hx : x ∈ c.points.getLast?, hy : y ∈ [h0].head?
    -- Therefore x = c.last and y = h0, and h_step gives hintikka_step x y.
    have h_last : c.points.getLast? = some (c.points.getLast c.nonempty) :=
      List.getLast?_eq_some_getLast c.nonempty
    rw [h_last] at hx
    simp at hx
    have h_head : ([h0] : List (HintikkaPoint Sigma)).head? = some h0 := by simp
    rw [h_head] at hy
    simp at hy
    show hintikka_step x y
    rw [← hx, ← hy]
    -- Need hintikka_step (c.points.getLast c.nonempty) h0, i.e. hintikka_step c.last h0
    exact h_step

@[simp] theorem HintikkaRawChain.snoc_points {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) (h0 : HintikkaPoint Sigma)
    (h_step : hintikka_step c.last h0) :
    (c.snoc h0 h_step).points = c.points ++ [h0] := rfl

theorem HintikkaRawChain.snoc_last {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) (h0 : HintikkaPoint Sigma)
    (h_step : hintikka_step c.last h0) :
    (c.snoc h0 h_step).last = h0 := by
  unfold HintikkaRawChain.last
  simp [HintikkaRawChain.snoc_points]

theorem HintikkaRawChain.snoc_head {Sigma : Finset Formula}
    (c : HintikkaRawChain Sigma) (h0 : HintikkaPoint Sigma)
    (h_step : hintikka_step c.last h0) :
    (c.snoc h0 h_step).head = c.head := by
  unfold HintikkaRawChain.head
  simp [c.nonempty]

/-- **Phase 4b main theorem**: `hintikka_chain_exists_since`.

    Since dual of `hintikka_chain_exists`. Given a Since step-oracle and
    a terminal Hintikka point `h0` carrying the target Since-defect
    (plus a concrete `BXPoint` witness `w0` backing `h0`), there exists a
    raw Hintikka chain ending at `h0`, whose head contains `ψ`, with
    every point backed by a concrete `BXPoint` witness (`ChainWitnessed`).

    Mirrors `hintikka_chain_exists` with the chain extended on the right
    (via `HintikkaRawChain.snoc`) rather than on the left: at each
    recursion step, the oracle produces a predecessor `wh'.point` of the
    current `h0`, and we recursively build a chain ending at
    `wh'.point`, then snoc `h0` onto that chain. -/
theorem hintikka_chain_exists_since
    {Sigma : Finset Formula} {φ ψ : Formula}
    (oracle : HintikkaStepOracleSince (Sigma := Sigma) φ ψ)
    (h0 : HintikkaPoint Sigma) (w0 : BXPoint)
    (h0_sub : ∀ f ∈ h0.formulas, f ∈ w0.formulas)
    (h_target : Formula.snce φ ψ ∈ h0.formulas) :
    ∃ c : HintikkaRawChain Sigma,
      c.last = h0 ∧ ψ ∈ c.head.formulas ∧ ChainWitnessed c := by
  -- Strong induction on `since_defect_count h0`, generalised over `h0` and `w0`.
  suffices h : ∀ n h0 (w0 : BXPoint),
      (∀ f ∈ h0.formulas, f ∈ w0.formulas) →
      since_defect_count h0 = n →
      Formula.snce φ ψ ∈ h0.formulas →
      ∃ c : HintikkaRawChain Sigma,
        c.last = h0 ∧ ψ ∈ c.head.formulas ∧ ChainWitnessed c by
    exact h (since_defect_count h0) h0 w0 h0_sub rfl h_target
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro h0 w0 h0_sub h_n h_target
    by_cases h_psi : ψ ∈ h0.formulas
    · -- Already at witness: singleton chain.
      refine ⟨HintikkaRawChain.singleton h0, ?_, ?_, ?_⟩
      · simp
      · simpa using h_psi
      · intro h hh
        simp [HintikkaRawChain.singleton_points] at hh
        exact ⟨w0, by subst hh; exact h0_sub⟩
    · -- Not yet at witness: invoke oracle to get a predecessor `wh'.point`.
      obtain ⟨wh', h_step, h_cases⟩ := oracle h0 h_target h_psi
      rcases h_cases with h_psi' | ⟨h_target', h_dec⟩
      · -- Predecessor already contains ψ: chain [wh'.point, h0] via singleton.snoc.
        have h_sing_last : (HintikkaRawChain.singleton wh'.point).last = wh'.point := by simp
        refine ⟨(HintikkaRawChain.singleton wh'.point).snoc h0
          (by rw [h_sing_last]; exact h_step), ?_, ?_, ?_⟩
        · rw [HintikkaRawChain.snoc_last]
        · rw [HintikkaRawChain.snoc_head]; simpa using h_psi'
        · intro h hh
          simp [HintikkaRawChain.snoc_points,
            HintikkaRawChain.singleton_points] at hh
          rcases hh with rfl | rfl
          · exact ⟨wh'.witness, wh'.point_subset_witness⟩
          · exact ⟨w0, h0_sub⟩
      · -- Oracle stepped to strictly smaller defect: recurse on wh'.point.
        have h_dec' : since_defect_count wh'.point < n := h_n ▸ h_dec
        obtain ⟨c', hc'_last, hc'_head, hc'_witd⟩ :=
          ih (since_defect_count wh'.point) h_dec' wh'.point wh'.witness
            wh'.point_subset_witness rfl h_target'
        refine ⟨c'.snoc h0 (by rw [hc'_last]; exact h_step), ?_, ?_, ?_⟩
        · rw [HintikkaRawChain.snoc_last]
        · rw [HintikkaRawChain.snoc_head]; exact hc'_head
        · intro h hh
          simp [HintikkaRawChain.snoc_points] at hh
          rcases hh with h_in | rfl
          · exact hc'_witd h h_in
          · exact ⟨w0, h0_sub⟩

/-- **Phase 4b seed-consistency lemma**: Since dual of
    `chain_step_seed_consistent`. `ChainWitnessed` is chain-direction
    agnostic so the Until-side proof applies verbatim. -/
theorem chain_step_seed_consistent_since
    {Sigma : Finset Formula}
    {c : HintikkaRawChain Sigma} (h_wit : ChainWitnessed c)
    {h : HintikkaPoint Sigma} (h_mem : h ∈ c.points)
    (S : Set Formula) (h_sub : S ⊆ (h.formulas : Set Formula)) :
    SetConsistent S :=
  chain_step_seed_consistent (c := c) h_wit h_mem S h_sub

/-- Guard lemma: at any interior point of the raw chain built by
    `hintikka_chain_exists`, the guard `φ ∈ h_i.formulas` holds
    whenever the target Until is still present and the witness is
    still absent. This follows directly from the `hintikka_step`
    G-clause for Until propagation. -/
theorem hintikka_chain_guard_step {Sigma : Finset Formula} {φ ψ : Formula}
    {h1 h2 : HintikkaPoint Sigma}
    (h_step : hintikka_step h1 h2)
    (h_target : Formula.untl φ ψ ∈ h1.formulas)
    (h_not : ψ ∉ h1.formulas) :
    φ ∈ h1.formulas := by
  exact (h_step.2.2 φ ψ h_target h_not).1

/-! ### Task 98 Phase 3 adapter: `quasimodel_chain_exists`

Thin re-export of `hintikka_chain_exists` in the shape Phase 4 / Phase 5
of task 98 will consume: the witnessed raw chain together with its
`ChainWitnessed` predicate returned as **separate** components, so that
downstream `realize_chain_step` proofs can destructure the witness
predicate explicitly without having to re-derive it.

**Starting `BXPoint` witness source**: at every Phase 5 call site, the
initial witness `w0 : BXPoint` is the MCS starting point supplied by
Frame.lean's Until/Since context (the point at which the eventuality
resolution obligation is raised). Concretely, for
`bx_until_eventuality_resolution` (Frame.lean:653) the starting point
is the MCS `w` at which `φ U ψ ∈ w.formulas` is witnessed, and
`h0.formulas = sigma_signature w Sigma` by construction, so the subset
hypothesis `h0_sub` reduces to `sigma_signature_mem_witness` under
`EnrichedClosure`. The Phase 4a proof discharges this subset obligation
in its own file without modifying anything here.

Consumes (reference only, zero churn):
- `hintikka_chain_exists` : the Phase 3 main theorem proved above.
- `ChainWitnessed`        : the Phase 3 MCS-witness predicate.
- `chain_step_seed_consistent` : the task-99 landed seed-consistency lemma.

This adapter does not introduce any new axioms or sorries; it is a
propositional re-export that names the `ChainWitnessed` component at
the top level of the existential for downstream ergonomics. -/
theorem quasimodel_chain_exists
    {Sigma : Finset Formula} {φ ψ : Formula}
    (oracle : HintikkaStepOracle (Sigma := Sigma) φ ψ)
    (h0 : HintikkaPoint Sigma) (w0 : BXPoint)
    (h0_sub : ∀ f ∈ h0.formulas, f ∈ w0.formulas)
    (h_target : Formula.untl φ ψ ∈ h0.formulas) :
    ∃ c : HintikkaRawChain Sigma,
      c.head = h0 ∧ ψ ∈ c.last.formulas ∧ ChainWitnessed c :=
  hintikka_chain_exists oracle h0 w0 h0_sub h_target

end Bimodal.Metalogic.BXCanonical.Quasimodel
