import Bimodal.Metalogic.BXCanonical.Quasimodel.HintikkaPoint

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

/-! ### Phase 3 remaining work

`hintikka_chain_exists` (constructing a `QuasimodelChain` that reaches the
witness by well-founded recursion on `defect_count`) is blocked on the
`defect_mono` discharge from Phase 5 and the step-construction machinery
from Phase 4. It is therefore deferred to a follow-up session along with
Phases 4-5, where all three strands compose to the realization proof.

The scaffolding in this file — `untilDefectSet`, `defect_count_eq_card`,
`hintikka_step_target_decrease`, and `QuasimodelChain` — is the Phase 3
deliverable: it provides the termination measure, the strict-decrease
lemma (under the monotonicity hypothesis), and the structural type that
the recursion will populate. -/

end Bimodal.Metalogic.BXCanonical.Quasimodel
