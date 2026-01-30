/-!
# UNDER DEVELOPMENT - Infinitary Strong Completeness

**Archived**: 2026-01-30 (Task 772)
**Original Location**: `Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
**Sorry Count**: 0 (this file is sorry-free, but depends entirely on sorried modules)
**Reason**: Depends on UniversalCanonicalModel.lean which uses sorried truth_lemma and construct_coherent_family

## Why This File Was Archived

This file proves strong completeness for TM bimodal logic with potentially infinite premise
sets. While the file itself contains no sorries, it depends on:

1. **construct_coherent_family** (CoherentConstruction.lean): 8 sorries for cross-origin coherence
2. **truth_lemma** (TruthLemma.lean): 4 sorries for box/temporal backward directions
3. **canonical_model**, **canonical_history_family** (UniversalCanonicalModel.lean): Uses the above

The theorem `infinitary_strong_completeness` at line 218 proves:
```
set_semantic_consequence Gamma phi →
∃ (Delta : Finset Formula), ↑Delta ⊆ Gamma ∧ ContextDerivable Delta.toList phi
```

This requires building a canonical model where all of `Gamma ∪ {phi.neg}` is true,
which uses the sorried representation theorem infrastructure.

## Key Theorems (Archived)

- `no_finite_witness_implies_union_consistent`: Helper lemma
- `infinitary_strong_completeness`: Main theorem for infinite premise sets
- `infinitary_strong_completeness_finset`: Finite set specialization (fully proven)

## Working Alternative

For completeness results without infinitary premises, use:
1. `weak_completeness` from `Completeness/WeakCompleteness.lean` (refactored to be sorry-free)
2. `semantic_weak_completeness` from `FMP/SemanticCanonicalModel.lean` (sorry-free)

The semantic approach works because:
- It only needs to show phi is FALSE at ONE specific world state
- It uses the contrapositive: unprovable → countermodel
- It avoids the universal quantification issues with Box semantics

## References

- Task 750: Truth bridge analysis confirming architectural limitations
- Task 769: Deprecation of sorried code with DEPRECATED markers
- Task 772: Restoration to UnderDevelopment/

---
ORIGINAL FILE BELOW
---
-/

import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness
import Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem.UniversalCanonicalModel
import Mathlib.Data.Finset.Basic

/-!
# Infinitary Strong Completeness for TM Bimodal Logic

This module proves strong completeness for TM bimodal logic with
potentially infinite premise sets (contexts represented as `Set Formula`).

## Overview

The key result is that if a Set-based context Gamma semantically implies phi,
then there exists a finite subset Delta ⊆ Gamma such that Delta ⊢ phi.

This bridges the gap between:
- Finite-premise strong completeness (List-based contexts)
- True compactness (infinite premise sets)

## Main Results

- `set_semantic_consequence`: Semantic consequence for Set-based contexts
- `set_satisfiable`: Satisfiability for Set-based contexts
- `no_finite_witness_implies_union_consistent`: If no finite subset derives phi,
  then Gamma ∪ {¬phi} is SetConsistent
- `infinitary_strong_completeness`: Every Set-based semantic consequence
  has a finite derivation witness (PROVEN)

## Proof Strategy

The proof uses contraposition:
1. Assume no finite Delta ⊆ Gamma derives phi
2. Show Gamma ∪ {¬phi} is SetConsistent (via `no_finite_witness_implies_union_consistent`)
3. Extend Gamma ∪ {¬phi} to an MCS via Lindenbaum's lemma
4. Prove G⊥ ∉ MCS and H⊥ ∉ MCS using temporal T axioms (temp_t_future, temp_t_past)
5. Build canonical model from the MCS using `construct_coherent_family`
6. Use truth lemma: all of Gamma ∪ {¬phi} is true at the canonical model
7. This contradicts Gamma |= phi (semantic consequence)

For finite sets, the theorem follows directly from finite_strong_completeness.

## References

- Finite strong completeness: `Bimodal.Metalogic.Completeness.FiniteStrongCompleteness`
- Representation theorem: `Bimodal.Metalogic.Representation.UniversalCanonicalModel`
- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Representation

/-!
## Set-Based Semantic Notions

These definitions extend the finite (List-based) notions to arbitrary sets.
-/

/--
Set-based semantic consequence: phi is a consequence of (possibly infinite) set Gamma.

This quantifies over all temporal types D and all models.
-/
def set_semantic_consequence (Gamma : Set Formula) (phi : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    (∀ psi ∈ Gamma, truth_at M tau t psi) → truth_at M tau t phi

/--
Set-based satisfiability: a set Gamma is satisfiable if there exists a model
where all formulas in Gamma are true at some point.
-/
def set_satisfiable (Gamma : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    ∀ psi ∈ Gamma, truth_at M tau t psi

/--
Set-based consistency: a set is consistent if no finite subset derives ⊥.
-/
def set_consistent (Gamma : Set Formula) : Prop :=
  ∀ (Delta : Finset Formula), ↑Delta ⊆ Gamma → Consistent Delta.toList

/-!
## Bridge Lemmas

These lemmas connect Set-based and List-based notions.
-/

/--
List-based semantic consequence implies Set-based semantic consequence
when the list is viewed as a set.
-/
lemma list_to_set_semantic_consequence (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi →
    set_semantic_consequence (Gamma.toFinset : Set Formula) phi := by
  intro h_list D _ _ _ F M tau t h_set
  apply h_list D F M tau t
  intro psi h_psi
  apply h_set psi
  simp [h_psi]

/--
Monotonicity of semantic consequence: If Delta ⊆ Gamma and Gamma |= phi, then Delta |= phi
only if all formulas in Gamma \ Delta are also satisfied.

**Note**: This is NOT generally true. Semantic consequence is ANTI-monotonic in premises:
If Delta ⊆ Gamma, then Gamma |= phi implies Delta |= phi is FALSE in general.
(More premises = stronger assumption = more consequences.)

What IS true: If Delta ⊇ Gamma (more premises), then Gamma |= phi implies Delta |= phi.

The correct direction is: set_semantic_consequence Delta phi → set_semantic_consequence Gamma phi
when Delta ⊆ Gamma (fewer premises means consequence still holds for more premises).
-/
lemma semantic_consequence_weaken (Gamma Delta : Set Formula) (phi : Formula)
    (h_sub : Delta ⊆ Gamma) :
    set_semantic_consequence Delta phi → set_semantic_consequence Gamma phi := by
  intro h_delta D _ _ _ F M tau t h_gamma
  apply h_delta D F M tau t
  intro psi h_psi
  exact h_gamma psi (h_sub h_psi)

/--
If Gamma is a finite set (as Finset), set_semantic_consequence equals semantic_consequence.
-/
lemma finset_set_semantic_consequence_iff (Gamma : Finset Formula) (phi : Formula) :
    set_semantic_consequence ↑Gamma phi ↔ semantic_consequence Gamma.toList phi := by
  constructor
  · intro h_set D _ _ _ F M tau t h_list
    apply h_set D F M tau t
    intro psi h_psi
    apply h_list psi
    exact Finset.mem_toList.mpr h_psi
  · intro h_list D _ _ _ F M tau t h_set
    apply h_list D F M tau t
    intro psi h_psi
    apply h_set psi
    exact Finset.mem_toList.mp h_psi

/-!
## Infinitary Strong Completeness

The main theorem: Set-based semantic consequence implies existence of a
finite derivation witness.
-/

/--
Helper lemma: If no finite subset Delta ⊆ Gamma derives phi, then Gamma ∪ {¬phi} is SetConsistent.

The key insight is that if Delta ⊆ Gamma derives phi (Delta ⊢ phi), then Delta ∪ {¬phi} derives ⊥.
Therefore, if no finite Delta ⊆ Gamma derives phi, then any finite subset of Gamma ∪ {¬phi}
is consistent.
-/
lemma no_finite_witness_implies_union_consistent (Gamma : Set Formula) (phi : Formula) :
    (¬∃ (Delta : Finset Formula), ↑Delta ⊆ Gamma ∧ ContextDerivable Delta.toList phi) →
    SetConsistent (Gamma ∪ {phi.neg}) := by
  intro h_no_witness
  intro L hL
  intro ⟨d_bot⟩
  -- L is a List with all elements in Gamma ∪ {¬phi}
  -- Let L' = L.filter (· ≠ phi.neg), which is ⊆ Gamma
  -- If phi.neg ∈ L, then L is essentially L' ∪ {phi.neg}
  -- From L ⊢ ⊥, by deduction theorem on phi.neg, we get L' ⊢ ¬¬phi = phi.neg.neg
  -- By double negation elimination, L' ⊢ phi
  -- This contradicts h_no_witness since L'.toFinset ⊆ Gamma

  -- Extract the Gamma part of L (filter out ¬phi)
  let L' := L.filter (· ≠ phi.neg)
  -- L ⊆ (phi.neg) :: L' (each element is either phi.neg or in L')
  have h_L_subset : L ⊆ phi.neg :: L' := by
    intro ψ hψ
    by_cases hψ_eq : ψ = phi.neg
    · simp [hψ_eq]
    · simp; right; exact List.mem_filter.mpr ⟨hψ, by simpa⟩
  -- L' ⊆ Gamma (since L ⊆ Gamma ∪ {phi.neg} and we filtered out phi.neg)
  have h_L'_sub_Gamma : ∀ ψ ∈ L', ψ ∈ Gamma := by
    intro ψ hψ
    have hψ_filter := List.mem_filter.mp hψ
    have hψ_in_L := hψ_filter.1
    have hψ_ne : ψ ≠ phi.neg := by simpa using hψ_filter.2
    have hψ_in_union := hL ψ hψ_in_L
    -- hψ_in_union : ψ ∈ Gamma ∪ {phi.neg}
    simp only [Set.mem_union, Set.mem_singleton_iff] at hψ_in_union
    cases hψ_in_union with
    | inl h => exact h
    | inr h => exact absurd h hψ_ne
  -- Weaken derivation to (phi.neg :: L')
  have d_bot' : DerivationTree (phi.neg :: L') Formula.bot :=
    DerivationTree.weakening L (phi.neg :: L') Formula.bot d_bot h_L_subset
  -- By deduction theorem: L' ⊢ phi.neg.neg
  have d_neg_neg : DerivationTree L' phi.neg.neg :=
    deduction_theorem L' phi.neg Formula.bot d_bot'
  -- By double negation elimination: L' ⊢ phi
  have dne : ⊢ phi.neg.neg.imp phi := Bimodal.Theorems.Propositional.double_negation phi
  have d_phi : DerivationTree L' phi :=
    DerivationTree.modus_ponens L' phi.neg.neg phi
      (DerivationTree.weakening [] L' (phi.neg.neg.imp phi) dne (by simp)) d_neg_neg
  -- This contradicts h_no_witness: L'.toFinset ⊆ Gamma and L'.toFinset.toList ⊢ phi
  apply h_no_witness
  use L'.toFinset
  constructor
  · intro ψ hψ
    simp at hψ
    exact h_L'_sub_Gamma ψ hψ
  · -- Need to show L'.toFinset.toList ⊢ phi from L' ⊢ phi
    -- Weaken from L' to L'.toFinset.toList (they may have different ordering/duplicates)
    constructor
    apply DerivationTree.weakening L' (L'.toFinset.toList) phi d_phi
    intro ψ hψ
    simp
    exact hψ

theorem infinitary_strong_completeness (Gamma : Set Formula) (phi : Formula) :
    set_semantic_consequence Gamma phi →
    ∃ (Delta : Finset Formula), ↑Delta ⊆ Gamma ∧ ContextDerivable Delta.toList phi := by
  intro h_set_entails
  -- Proof by contrapositive:
  -- Suppose no finite Delta ⊆ Gamma derives phi
  -- Then Gamma ∪ {¬phi} is set_consistent (by helper lemma)
  -- So some model satisfies all of Gamma ∪ {¬phi}
  -- In particular, Gamma is satisfied but phi is false
  -- This contradicts Gamma |= phi

  by_contra h_no_witness
  -- Get SetConsistent (Gamma ∪ {phi.neg})
  have h_union_cons : SetConsistent (Gamma ∪ {phi.neg}) :=
    no_finite_witness_implies_union_consistent Gamma phi h_no_witness
  -- Use representation theorem: set_consistent {phi.neg} implies satisfiable
  -- But we need the whole Gamma ∪ {phi.neg} to be satisfiable
  -- Actually we need to show this gives a model satisfying all of Gamma ∪ {phi.neg}

  -- Key: Since Gamma ∪ {phi.neg} is set_consistent, we can extend any finite subset to MCS
  -- Pick {phi.neg} ⊆ Gamma ∪ {phi.neg}
  have h_neg_cons : SetConsistent {phi.neg} := by
    intro L hL
    apply h_union_cons L
    intro ψ hψ
    right
    exact hL ψ hψ

  -- Use representation theorem to get a model satisfying phi.neg
  obtain ⟨family, t, h_neg_in, h_neg_true⟩ :=
    representation_theorem phi.neg h_neg_cons

  -- h_neg_true : truth_at ... t phi.neg
  -- This means phi is false at this model/point
  -- To get contradiction, all of Gamma must be true here

  -- The representation theorem gives us phi.neg in family.mcs t
  -- And the truth lemma gives us truth_at ... t phi.neg

  -- Now apply h_set_entails: If all of Gamma is true at (model, t), then phi is true
  -- But phi.neg is true, so phi is false
  -- Requirement: all of Gamma is true here

  -- The problem: the MCS at t extends {phi.neg}, not necessarily Gamma ∪ {phi.neg}
  -- We need a stronger version of the representation theorem that can handle
  -- set_consistent sets, not just singletons

  -- Alternative approach: If Gamma ∪ {phi.neg} is set_consistent, then
  -- there exists an MCS extending Gamma ∪ {phi.neg} (by Lindenbaum's lemma for sets)
  -- Then use the canonical model at that MCS

  -- Let's use set_lindenbaum to extend Gamma ∪ {phi.neg}
  -- But wait - set_lindenbaum requires a formula/singleton, not an arbitrary set
  -- Actually, looking at the signature, set_lindenbaum takes any set

  -- Get MCS extending Gamma ∪ {phi.neg}
  obtain ⟨Γ_mcs, h_extends, h_is_mcs⟩ := set_lindenbaum (Gamma ∪ {phi.neg}) h_union_cons

  -- h_extends : Gamma ∪ {phi.neg} ⊆ Γ_mcs
  -- h_is_mcs : SetMaximalConsistent Γ_mcs

  -- Now we need to construct a model from Γ_mcs
  -- The canonical model construction uses IndexedMCSFamily, which builds families
  -- indexed by ℤ with temporal coherence

  -- For our purposes, we can use a simpler argument:
  -- The key insight is that in the canonical model construction,
  -- if phi.neg ∈ Γ_mcs (which follows from h_extends), then phi is false at that world

  -- Actually, let's think about this differently
  -- The representation theorem proves: SetConsistent {phi.neg} → exists model where phi.neg is true
  -- But we need: set_consistent (Gamma ∪ {phi.neg}) → exists model where Gamma ∪ {phi.neg} is true

  -- This is a STRONGER statement and requires a generalization of the representation theorem

  -- Looking at this more carefully:
  -- The representation theorem (line 71 of UniversalCanonicalModel.lean) says:
  -- "SetConsistent {phi} → ∃ family, t, phi ∈ family.mcs t ∧ truth_at ... t phi"

  -- We need: "SetConsistent S → ∃ model, ∀ psi ∈ S, truth_at ... psi"
  -- This is exactly what the representation theorem gives when S is a singleton

  -- For arbitrary S, the approach is:
  -- 1. Extend S to MCS Γ using set_lindenbaum
  -- 2. Build canonical model at Γ
  -- 3. Truth lemma: psi ∈ Γ ↔ truth_at ... psi
  -- 4. Since S ⊆ Γ, all of S is true

  -- The issue is that the current representation_theorem constructs a family
  -- with specific temporal coherence properties (G⊥ ∉ Γ, H⊥ ∉ Γ conditions)
  -- For infinitary completeness, we don't need the full temporal structure
  -- We just need a single point where the formulas are true

  -- Let me check if we can use a simpler model - actually the algebraic approach!
  -- AlgSatisfiable connects to MCS via ultrafilters

  -- Actually, the cleanest approach for this proof is:
  -- 1. Show Gamma ∪ {phi.neg} is set_consistent
  -- 2. By Lindenbaum, extend to MCS Γ
  -- 3. phi.neg ∈ Γ (since phi.neg ∈ Gamma ∪ {phi.neg} ⊆ Γ)
  -- 4. By MCS negation completeness, phi ∉ Γ
  -- 5. For any psi ∈ Gamma: psi ∈ Gamma ∪ {phi.neg} ⊆ Γ
  -- 6. Now we need a model where Γ is satisfied
  -- 7. The canonical model does this, but needs the G⊥/H⊥ conditions

  -- For now, let's use the representation theorem with a slight modification
  -- We'll need to show that if Gamma ⊆ Γ_mcs and phi.neg ∈ Γ_mcs, then
  -- there's a model satisfying all of Gamma ∪ {phi.neg}

  -- The key observation is that the canonical model construction,
  -- when it succeeds (i.e., when G⊥ ∉ Γ and H⊥ ∉ Γ), gives us a model
  -- where ALL formulas in the MCS are true (by truth lemma)

  -- For formulas that don't involve temporal operators, we can use
  -- a simpler construction. But for full generality, we need the
  -- indexed family approach.

  -- Let's try a different tactic: show that if the representation theorem
  -- works for {phi.neg}, it essentially gives us what we need
  -- because the MCS it produces extends {phi.neg} and the canonical model
  -- satisfies everything in the MCS

  -- Actually, looking at representation_theorem more carefully:
  -- It produces family.mcs t which is an MCS containing phi.neg
  -- And truth_at ... t psi ↔ psi ∈ family.mcs t (by truth lemma)
  -- So for any psi ∈ Gamma, if psi ∈ family.mcs t, then truth_at ... t psi

  -- The question is: does Gamma ⊆ family.mcs t?
  -- Not necessarily! The representation theorem only guarantees phi.neg ∈ family.mcs t

  -- We need to use set_consistent (Gamma ∪ {phi.neg}) more directly
  -- The idea: extend Gamma ∪ {phi.neg} to an MCS, then use that MCS

  -- Let's try the representation theorem for the formula phi.neg
  -- but with the stronger hypothesis that Gamma ∪ {phi.neg} is set_consistent

  -- Actually, looking at representation_theorem line 76:
  -- "obtain ⟨Gamma, h_extends, h_mcs⟩ := set_lindenbaum {phi} h_cons"
  -- This extends {phi} to an MCS

  -- If we call set_lindenbaum with Gamma ∪ {phi.neg} instead of {phi.neg},
  -- we get an MCS extending Gamma ∪ {phi.neg}

  -- But then we still need to build the canonical model from that MCS
  -- From Γ_mcs extending Gamma ∪ {phi.neg}:
  have h_gamma_in_mcs : Gamma ⊆ Γ_mcs := fun ψ hψ => h_extends (Set.mem_union_left _ hψ)
  have h_neg_in_mcs : phi.neg ∈ Γ_mcs := h_extends (Set.mem_union_right _ (Set.mem_singleton _))

  -- Build the canonical model from Γ_mcs
  -- Prove G⊥ ∉ Γ_mcs and H⊥ ∉ Γ_mcs using temporal T axioms
  have h_no_G_bot : Formula.all_future Formula.bot ∉ Γ_mcs := by
    -- If G⊥ ∈ Γ_mcs, then by temp_t_future (Gφ → φ), we get ⊥ ∈ Γ_mcs
    -- But Γ_mcs is consistent, so ⊥ ∉ Γ_mcs
    intro h_G_bot_in
    -- We have G⊥ ∈ Γ_mcs and the axiom ⊢ G⊥ → ⊥
    have h_axiom : ⊢ (Formula.all_future Formula.bot).imp Formula.bot :=
      DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future Formula.bot)
    -- By modus ponens in the MCS, ⊥ ∈ Γ_mcs
    -- Use maximal_consistent_closed: if φ ∈ Γ and ⊢ φ → ψ, then ψ ∈ Γ
    have h_bot_in : Formula.bot ∈ Γ_mcs := by
      by_contra h_not
      -- If ⊥ ∉ Γ_mcs, by maximality, insert ⊥ Γ_mcs is inconsistent
      have h_incons : ¬SetConsistent (insert Formula.bot Γ_mcs) := h_is_mcs.2 Formula.bot h_not
      -- But [G⊥] ⊢ ⊥ by applying the axiom
      -- And G⊥ ∈ Γ_mcs, so we can derive ⊥ from Γ_mcs
      -- This means Γ_mcs is inconsistent
      apply h_is_mcs.1 [Formula.all_future Formula.bot]
      · intro ψ hψ; simp at hψ; rw [hψ]; exact h_G_bot_in
      · constructor
        have h_ax' : DerivationTree [Formula.all_future Formula.bot]
            ((Formula.all_future Formula.bot).imp Formula.bot) :=
          DerivationTree.weakening [] _ _ h_axiom (by simp)
        have h_assm : DerivationTree [Formula.all_future Formula.bot]
            (Formula.all_future Formula.bot) :=
          DerivationTree.assumption _ _ (by simp)
        exact DerivationTree.modus_ponens _ _ _ h_ax' h_assm
    -- But ⊥ ∈ Γ_mcs contradicts consistency (MCS cannot contain ⊥)
    apply h_is_mcs.1 [Formula.bot]
    · intro ψ hψ; simp at hψ; rw [hψ]; exact h_bot_in
    · constructor
      exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)

  have h_no_H_bot : Formula.all_past Formula.bot ∉ Γ_mcs := by
    -- Similar argument using temp_t_past: Hφ → φ
    intro h_H_bot_in
    have h_axiom : ⊢ (Formula.all_past Formula.bot).imp Formula.bot :=
      DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past Formula.bot)
    have h_bot_in : Formula.bot ∈ Γ_mcs := by
      by_contra h_not
      have h_incons : ¬SetConsistent (insert Formula.bot Γ_mcs) := h_is_mcs.2 Formula.bot h_not
      apply h_is_mcs.1 [Formula.all_past Formula.bot]
      · intro ψ hψ; simp at hψ; rw [hψ]; exact h_H_bot_in
      · constructor
        have h_ax' : DerivationTree [Formula.all_past Formula.bot]
            ((Formula.all_past Formula.bot).imp Formula.bot) :=
          DerivationTree.weakening [] _ _ h_axiom (by simp)
        have h_assm : DerivationTree [Formula.all_past Formula.bot]
            (Formula.all_past Formula.bot) :=
          DerivationTree.assumption _ _ (by simp)
        exact DerivationTree.modus_ponens _ _ _ h_ax' h_assm
    apply h_is_mcs.1 [Formula.bot]
    · intro ψ hψ; simp at hψ; rw [hψ]; exact h_bot_in
    · constructor
      exact DerivationTree.assumption [Formula.bot] Formula.bot (by simp)

  -- Construct the coherent family with Γ_mcs at origin
  let coherent := construct_coherent_family Γ_mcs h_is_mcs h_no_G_bot h_no_H_bot
  let family := coherent.toIndexedMCSFamily
  let model := canonical_model ℤ family
  let history := canonical_history_family ℤ family

  -- By truth lemma: for any ψ ∈ Γ_mcs, truth_at model history 0 ψ
  -- Since phi.neg ∈ Γ_mcs:
  have h_neg_true : truth_at model history 0 phi.neg := by
    have h_truth_lemma := truth_lemma ℤ family 0 phi.neg
    apply h_truth_lemma.mp
    -- Need: phi.neg ∈ family.mcs 0
    -- family.mcs 0 = Γ_mcs (by origin preservation)
    have h_origin := construct_coherent_family_origin
      Γ_mcs h_is_mcs h_no_G_bot h_no_H_bot phi.neg h_neg_in_mcs
    exact h_origin

  -- For any ψ ∈ Gamma: ψ ∈ Γ_mcs, so truth_at model history 0 ψ
  have h_gamma_true : ∀ ψ ∈ Gamma, truth_at model history 0 ψ := by
    intro ψ hψ
    have h_in_mcs : ψ ∈ Γ_mcs := h_gamma_in_mcs hψ
    have h_truth_lemma := truth_lemma ℤ family 0 ψ
    apply h_truth_lemma.mp
    have h_origin := construct_coherent_family_origin
      Γ_mcs h_is_mcs h_no_G_bot h_no_H_bot ψ h_in_mcs
    exact h_origin

  -- Now apply h_set_entails: since all of Gamma is true at (model, 0), phi must be true
  have h_phi_true : truth_at model history 0 phi :=
    h_set_entails ℤ (UniversalCanonicalFrame ℤ) model history 0 h_gamma_true

  -- But h_neg_true says phi.neg is true at (model, 0)
  -- phi.neg = phi → ⊥, so truth_at phi.neg means: truth_at phi → truth_at ⊥
  simp only [Formula.neg, truth_at] at h_neg_true
  exact h_neg_true h_phi_true

/--
Special case: For finite sets (Finset), infinitary strong completeness reduces to
finite strong completeness. This case is fully proven.
-/
theorem infinitary_strong_completeness_finset (Gamma : Finset Formula) (phi : Formula) :
    set_semantic_consequence ↑Gamma phi → ContextDerivable Gamma.toList phi := by
  intro h_set_entails
  have h_list_entails : semantic_consequence Gamma.toList phi := by
    intro D _ _ _ F M tau t h_list
    apply h_set_entails D F M tau t
    intro psi h_psi
    apply h_list psi
    exact Finset.mem_toList.mpr h_psi
  exact finite_strong_completeness Gamma.toList phi h_list_entails

/--
Corollary: For finite sets with explicit witness.
-/
theorem infinitary_strong_completeness_finset' (Gamma : Finset Formula) (phi : Formula) :
    set_semantic_consequence ↑Gamma phi →
    ∃ (Delta : Finset Formula), ↑Delta ⊆ (↑Gamma : Set Formula) ∧ ContextDerivable Delta.toList phi := by
  intro h_set_entails
  use Gamma
  constructor
  · rfl
  · exact infinitary_strong_completeness_finset Gamma phi h_set_entails

end Bimodal.Metalogic.Completeness
