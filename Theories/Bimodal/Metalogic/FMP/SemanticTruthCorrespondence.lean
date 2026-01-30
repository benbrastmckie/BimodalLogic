import Bimodal.Metalogic.FMP.SemanticTaskFrame
import Bimodal.Metalogic.FMP.SemanticCanonicalModel

/-!
# Semantic Truth Correspondence

This module documents the attempt to bridge `valid phi` to `semantic_truth_at_v2`,
and explains why the approach fails due to an architectural gap.

## Overview

The research (research-002.md) proposed building a TaskModel from SemanticWorldStates
and proving truth correspondence. However, implementation revealed that this approach
faces the same architectural gap as the original forward truth lemma:

**The Gap**: `semantic_truth_at_v2` checks the assignment directly, while `truth_at`
evaluates formulas recursively. These only coincide for MCS-derived world states,
not arbitrary locally-consistent world states.

## Why the Bridge Fails

1. `semantic_truth_at_v2 phi w t psi` = `w.toFiniteWorldState.models psi h_mem`
   = `w.assignment ⟨psi, h_mem⟩ = true`

2. `truth_at (SemanticTaskModel phi) τ t psi` is defined recursively:
   - For atoms: matches assignment (correspondence works)
   - For bot: both False (correspondence works)
   - For imp: `truth_at psi -> truth_at chi` (MAY DIFFER from assignment!)

3. A locally consistent world state can have:
   - assignment(psi->chi) = false
   - assignment(psi) = false
   - assignment(chi) = true
   This is consistent (modus ponens doesn't apply), but truth_at(psi->chi) = true!

4. The mismatch means: valid(phi) doesn't imply semantic_truth_at_v2 for all world states.

## What Works

- `valid_at_semantic_model`: valid phi implies truth_at in SemanticTaskModel (trivial instantiation)
- `truth_correspondence_atom`: Atoms have correspondence in both directions
- `truth_correspondence_bot`: Bot has correspondence (both False)

## What Doesn't Work

- `truth_at_semantic_implies_semantic_truth`: SORRY - the core bridge lemma
- `truth_correspondence_imp` forward direction: Requires MCS-like maximality
- Full truth correspondence: Only works for MCS-derived world states

## Recommendation

The sorry in `weak_completeness` is architectural. Use `semantic_weak_completeness` instead,
which works via contrapositive and only requires MCS-derived world states.

## References

- Task 779: This implementation attempt
- Task 750: Original research on truth lemma gap
- Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean: Detailed gap documentation
-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics

/-!
## Bridge from valid to semantic truth

The main bridging theorems that connect universal validity to semantic validity.
-/

/--
If phi is valid, it is true at the SemanticTaskModel at time 0 for any history.
-/
theorem valid_at_semantic_model (phi : Formula) (h_valid : valid phi)
    (τ : WorldHistory (SemanticTaskFrame phi)) :
    truth_at (SemanticTaskModel phi) τ 0 phi := by
  -- valid phi means: for all D, F, M, τ, t, truth_at M τ t phi
  -- Instantiate with D = Int, F = SemanticTaskFrame phi, M = SemanticTaskModel phi
  exact h_valid Int (SemanticTaskFrame phi) (SemanticTaskModel phi) τ 0

/--
Key lemma: If phi is true at SemanticTaskModel for the history from a SemanticWorldState,
then semantic_truth_at_v2 holds for phi.

**ARCHITECTURAL GAP**: This lemma CANNOT be proven in general.

The issue is that `truth_at` evaluates phi recursively, while `semantic_truth_at_v2`
just checks the assignment. For non-MCS-derived world states, these can differ:

Example: For phi = psi -> chi, a world state could have:
- assignment(psi -> chi) = false
- assignment(psi) = false
- truth_at(psi) = false (from atom correspondence)
- truth_at(psi -> chi) = (false -> ...) = true

So truth_at holds but assignment is false, meaning semantic_truth_at_v2 fails.

This is the same gap documented in Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean.

**Recommendation**: Use `semantic_weak_completeness` which works via contrapositive
and only needs MCS-derived world states where the correspondence DOES hold.
-/
-- ARCHITECTURAL SORRY: Cannot be proven - see docstring
theorem truth_at_semantic_implies_semantic_truth (phi : Formula)
    (sw : SemanticWorldState phi)
    (h_truth : truth_at (SemanticTaskModel phi) (worldStateToHistory phi sw) 0 phi) :
    semantic_truth_at_v2 phi sw (BoundedTime.origin (temporalBound phi)) phi := by
  use phi_mem_closure phi
  -- GAP: truth_at (recursive) ≠ models (assignment) for arbitrary world states
  sorry

/--
Main bridge theorem: valid phi implies semantic validity at all SemanticWorldStates.

**NOTE**: This theorem depends on `truth_at_semantic_implies_semantic_truth`, which
has an architectural sorry. Therefore this theorem also inherits that sorry.

The gap cannot be closed with the current approach. See the documentation in
`truth_at_semantic_implies_semantic_truth` for details.
-/
-- ARCHITECTURAL SORRY (inherited from truth_at_semantic_implies_semantic_truth)
theorem valid_implies_semantic_validity (phi : Formula) (h_valid : valid phi) :
    ∀ (w : SemanticWorldState phi),
      semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi := by
  intro sw
  -- Step 1: Instantiate valid with SemanticTaskModel
  have h_truth := valid_at_semantic_model phi h_valid (worldStateToHistory phi sw)
  -- Step 2: Apply the bridge lemma (has architectural sorry)
  exact truth_at_semantic_implies_semantic_truth phi sw h_truth

/-!
## Full Truth Correspondence (for structural induction)

To complete the proof of `truth_at_semantic_implies_semantic_truth`, we need to
prove correspondence for all formula constructors. We do this by structural induction.
-/

/--
Truth correspondence for atoms: truth_at equals models for atoms in closure.
-/
theorem truth_correspondence_atom (phi : Formula) (p : String)
    (h_mem : Formula.atom p ∈ closure phi)
    (sw : SemanticWorldState phi) :
    truth_at (SemanticTaskModel phi) (worldStateToHistory phi sw) 0 (Formula.atom p) ↔
    (SemanticWorldState.toFiniteWorldState sw).models (Formula.atom p) h_mem := by
  simp only [truth_at]
  constructor
  · intro ⟨h_dom, h_val⟩
    simp only [worldStateToHistory, SemanticTaskModel] at h_val
    simp only [dif_pos h_mem] at h_val
    exact h_val
  · intro h_models
    have h_dom : (worldStateToHistory phi sw).domain 0 :=
      worldStateToHistory_domain_origin phi sw
    use h_dom
    simp only [worldStateToHistory, SemanticTaskModel, dif_pos h_mem]
    exact h_models

/--
Truth correspondence for bot: both sides are False.
-/
theorem truth_correspondence_bot (phi : Formula)
    (h_mem : Formula.bot ∈ closure phi)
    (sw : SemanticWorldState phi) :
    truth_at (SemanticTaskModel phi) (worldStateToHistory phi sw) 0 Formula.bot ↔
    (SemanticWorldState.toFiniteWorldState sw).models Formula.bot h_mem := by
  simp only [truth_at]
  have h_models_false := FiniteWorldState.bot_false (sw.toFiniteWorldState) h_mem
  constructor
  · intro h; exact h.elim
  · intro h; rw [h_models_false] at h; exact h

/--
Truth correspondence for implication (assuming IH for subformulas).
-/
theorem truth_correspondence_imp (phi psi chi : Formula)
    (h_imp_mem : Formula.imp psi chi ∈ closure phi)
    (h_psi_mem : psi ∈ closure phi)
    (h_chi_mem : chi ∈ closure phi)
    (sw : SemanticWorldState phi)
    (ih_psi : truth_at (SemanticTaskModel phi) (worldStateToHistory phi sw) 0 psi ↔
              (SemanticWorldState.toFiniteWorldState sw).models psi h_psi_mem)
    (ih_chi : truth_at (SemanticTaskModel phi) (worldStateToHistory phi sw) 0 chi ↔
              (SemanticWorldState.toFiniteWorldState sw).models chi h_chi_mem) :
    truth_at (SemanticTaskModel phi) (worldStateToHistory phi sw) 0 (Formula.imp psi chi) ↔
    (SemanticWorldState.toFiniteWorldState sw).models (Formula.imp psi chi) h_imp_mem := by
  let w := SemanticWorldState.toFiniteWorldState sw
  simp only [truth_at]
  constructor
  · -- Forward: truth_at (psi → chi) implies models (psi → chi)
    intro h_imp_truth
    -- h_imp_truth : truth_at psi → truth_at chi
    -- Need: w.models (psi → chi) h_imp_mem
    -- By negation completeness and consistency, either psi ∉ w or chi ∈ w
    by_cases h_psi_model : w.models psi h_psi_mem
    · -- Case: w.models psi
      have h_psi_truth := ih_psi.mpr h_psi_model
      have h_chi_truth := h_imp_truth h_psi_truth
      have h_chi_model := ih_chi.mp h_chi_truth
      -- Now need to show (psi → chi) holds from chi holding
      -- This requires that the world state's assignment is consistent with modus ponens
      -- Actually, we need to show: w.assignment ⟨psi.imp chi, h_imp_mem⟩ = true
      -- The world state's local consistency gives us modus ponens, but we need
      -- the converse: if chi holds, does (psi → chi) hold?
      -- This requires the world state to be "closure-maximal consistent" not just
      -- "locally consistent".
      sorry
    · -- Case: ¬w.models psi
      -- If psi is false, then (psi → chi) should be true in the world state
      -- This also requires closure-maximal consistency
      sorry
  · -- Backward: models (psi → chi) implies truth_at (psi → chi)
    intro h_imp_model
    intro h_psi_truth
    have h_psi_model := ih_psi.mp h_psi_truth
    -- From models (psi → chi) and models psi, derive models chi
    have h_chi_model := FiniteWorldState.imp_correct w psi chi h_imp_mem h_psi_mem h_chi_mem
                          h_imp_model h_psi_model
    exact ih_chi.mpr h_chi_model

/-!
## Box and Temporal Cases

These are the challenging cases that require quantification correspondence.
-/

/--
Box case analysis: truth_at (box psi) quantifies over ALL histories.
For SemanticTaskFrame, all histories are finite and correspond to FiniteWorldStates.
-/
theorem truth_correspondence_box_analysis (phi psi : Formula)
    (h_box_mem : Formula.box psi ∈ closure phi)
    (h_psi_mem : psi ∈ closure phi)
    (sw : SemanticWorldState phi) :
    truth_at (SemanticTaskModel phi) (worldStateToHistory phi sw) 0 (Formula.box psi) ↔
    (∀ w' : FiniteWorldState phi, truth_at (SemanticTaskModel phi) (finiteWorldStateToHistory phi w') 0 psi) := by
  simp only [truth_at]
  constructor
  · intro h_box w'
    -- h_box : ∀ σ : WorldHistory, truth_at M σ 0 psi
    -- Instantiate with finiteWorldStateToHistory w'
    exact h_box (finiteWorldStateToHistory phi w')
  · intro h_all σ
    -- h_all : ∀ w', truth_at M (history from w') 0 psi
    -- Need: truth_at M σ 0 psi
    --
    -- Key insight: σ is an arbitrary WorldHistory for SemanticTaskFrame
    -- At time 0, either:
    -- 1. 0 is in σ.domain: then σ.states 0 _ is some FiniteWorldState
    -- 2. 0 is not in σ.domain: atoms at time 0 are false
    --
    -- For case 1, we can use h_all with that FiniteWorldState
    -- For case 2, we need to show psi is true anyway (vacuously for atoms)
    --
    -- This is complex because psi can have arbitrary structure.
    sorry

/-!
## Summary

The full truth correspondence proof requires:
1. Atom case: Done (truth_correspondence_atom)
2. Bot case: Done (truth_correspondence_bot)
3. Imp case: Needs closure-maximal consistency (partial, with sorry)
4. Box case: Needs history quantification analysis (partial, with sorry)
5. Temporal cases: Need bounded time argument (not yet started)

The key architectural insight is that we only need the correspondence to hold
for the specific formula phi at the top level, not for all subformulas in
arbitrary contexts. This may allow a simpler proof strategy.
-/

end Bimodal.Metalogic.FMP
