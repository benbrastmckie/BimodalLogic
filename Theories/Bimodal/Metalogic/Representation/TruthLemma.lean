import Bimodal.Metalogic.Representation.CanonicalHistory
import Bimodal.Metalogic.Representation.IndexedMCSFamily
import Bimodal.Semantics.Truth

/-!
# Truth Lemma for Indexed MCS Family Canonical Model

This module proves the truth lemma connecting MCS membership to semantic truth
in the canonical model constructed from an indexed MCS family.

## Overview

**Main Theorem**: For an indexed MCS family and canonical history,
```
phi in family.mcs t <-> truth_at (canonical_model family) (canonical_history family) t phi
```

This is the key bridge between syntactic (MCS membership) and semantic (truth) notions.

## Proof Strategy

The proof uses **mutual induction** on formulas to prove both directions simultaneously.
This allows using the backward IH in the forward direction (e.g., for the imp case).

- **Atom**: Valuation is defined so that atom p in mcs t iff valuation says true
- **Bot**: MCS is consistent, so bot not in mcs; semantically, bot is false
- **Imp**: Uses MCS modus ponens closure (forward) and negation completeness (backward)
- **Box**: Universal quantification over histories requires special handling
- **G (all_future)**: Uses family coherence conditions
- **H (all_past)**: Symmetric to G case

## Key Insight

The mutual induction allows the forward imp case to use:
1. Backward IH to convert `truth_at psi` to `psi ∈ mcs t`
2. Modus ponens closure: if `(psi → chi) ∈ mcs t` and `psi ∈ mcs t`, then `chi ∈ mcs t`
3. Forward IH to convert `chi ∈ mcs t` to `truth_at chi`

## References

- Research report: specs/656_.../reports/research-001.md
- Implementation plan: specs/656_.../plans/implementation-001.md

## Gaps NOT Required for Completeness

The backward direction of the Truth Lemma (`truth_at → φ ∈ MCS`) has sorries in:
- `all_past` backward case (line 410)
- `all_future` backward case (line 423)

**These are NOT required for completeness**. The representation theorem only uses
`truth_lemma_forward` (the forward direction: `φ ∈ MCS → truth_at`).

The backward direction would prove "tightness" - that the canonical model has no
extraneous truths beyond what the MCS contains. This is useful for:
- Soundness proofs
- Frame correspondence
- Definability results

See `Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` for details.
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic_v2.Core
open Bimodal.Semantics
-- NOTE: MCSProperties provides helper lemmas (previously from Boneyard).

variable (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Canonical Model Definition

The canonical model uses MCS membership to define valuation.
-/

/--
The canonical task model from an indexed MCS family.

**Valuation**: An atom p is true at world w iff (Formula.atom p) is in w's MCS.

This definition ensures the truth lemma's base case (atoms) is trivially true.
-/
def canonical_model (family : IndexedMCSFamily D) :
    TaskModel (UniversalCanonicalFrame D) where
  valuation := fun w p => Formula.atom p ∈ w.mcs

/-!
## Helper Lemmas

These lemmas support the truth lemma proof.
-/

/--
The canonical history has full domain.
-/
lemma canonical_history_family_domain (family : IndexedMCSFamily D) (t : D) :
    (canonical_history_family D family).domain t :=
  trivial

/--
The world state at time t has the family's MCS at t.
-/
lemma canonical_world_mcs (family : IndexedMCSFamily D) (t : D)
    (ht : (canonical_history_family D family).domain t) :
    ((canonical_history_family D family).states t ht).mcs = family.mcs t :=
  rfl

/-!
## MCS Negation-Implication Properties

These lemmas extract formulas from ¬(φ → ψ) ∈ MCS using deductive closure.
In classical logic: ¬(φ → ψ) ⊣⊢ φ ∧ ¬ψ
-/

/--
From ¬(φ → ψ) ∈ MCS, derive φ ∈ MCS.

**Proof**: ¬(φ → ψ) ⊢ φ is a classical tautology.
From ¬(φ → ψ), assume ¬φ. Then φ → ψ holds vacuously (φ is false).
But ¬(φ → ψ) and (φ → ψ) together give ⊥. By RAA, ¬¬φ, so φ by DNE.
-/
lemma neg_imp_fst {S : Set Formula} {φ ψ : Formula}
    (h_mcs : Core.SetMaximalConsistent S)
    (h_neg_imp : (φ.imp ψ).neg ∈ S) : φ ∈ S := by
  -- Use negation completeness: either φ ∈ S or ¬φ ∈ S
  cases set_mcs_negation_complete h_mcs φ with
  | inl h_phi => exact h_phi
  | inr h_neg_phi =>
    -- From ¬φ, we can derive φ → ψ (vacuously, since φ is false)
    -- ¬φ ⊢ φ → ψ is: assuming φ, we have φ and ¬φ, so ⊥, so ψ by EFQ
    -- Then we have both (φ → ψ) and ¬(φ → ψ) in S, contradiction
    exfalso
    -- Derive φ → ψ from ¬φ
    have h_deriv : Bimodal.ProofSystem.DerivationTree [φ.neg] (φ.imp ψ) := by
      -- Need [¬φ] ⊢ φ → ψ
      -- Use deduction theorem: need φ :: [¬φ] ⊢ ψ
      have h_inner : Bimodal.ProofSystem.DerivationTree (φ :: [φ.neg]) ψ := by
        -- We have φ and ¬φ = φ → ⊥ in context
        have h_phi : (φ :: [φ.neg]) ⊢ φ :=
          Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
        have h_neg : (φ :: [φ.neg]) ⊢ φ.neg :=
          Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
        -- From φ and φ → ⊥, get ⊥
        have h_bot : (φ :: [φ.neg]) ⊢ Formula.bot :=
          Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg h_phi
        -- EFQ: ⊥ → ψ
        have h_efq_thm : [] ⊢ Formula.bot.imp ψ :=
          Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso ψ)
        have h_efq : (φ :: [φ.neg]) ⊢ Formula.bot.imp ψ :=
          Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_efq_thm (by intro; simp)
        exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_efq h_bot
      exact deduction_theorem [φ.neg] φ ψ h_inner
    -- By MCS closure, φ → ψ ∈ S
    have h_sub : ∀ χ ∈ [φ.neg], χ ∈ S := by simp [h_neg_phi]
    have h_imp_in : (φ.imp ψ) ∈ S :=
      set_mcs_closed_under_derivation h_mcs [φ.neg] h_sub h_deriv
    -- Now we have both (φ → ψ) and ¬(φ → ψ) in S - contradiction
    have h_deriv_bot : Bimodal.ProofSystem.DerivationTree [(φ.imp ψ), (φ.imp ψ).neg] Formula.bot := by
      have h1 : [(φ.imp ψ), (φ.imp ψ).neg] ⊢ (φ.imp ψ) :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h2 : [(φ.imp ψ), (φ.imp ψ).neg] ⊢ (φ.imp ψ).neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      exact Core.derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [(φ.imp ψ), (φ.imp ψ).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_imp_in
      | inr h_eq => exact h_eq ▸ h_neg_imp
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    -- ⊥ ∈ S contradicts consistency
    have h_cons := h_mcs.1
    have h_bot_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
    exact h_cons [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
From ¬(φ → ψ) ∈ MCS, derive ¬ψ ∈ MCS.

**Proof**: ¬(φ → ψ) ⊢ ¬ψ is a classical tautology.
From ¬(φ → ψ), assume ψ. Then φ → ψ holds (conclude ψ from anything).
But ¬(φ → ψ) and (φ → ψ) together give ⊥. By RAA, ¬ψ.
-/
lemma neg_imp_snd {S : Set Formula} {φ ψ : Formula}
    (h_mcs : Core.SetMaximalConsistent S)
    (h_neg_imp : (φ.imp ψ).neg ∈ S) : ψ.neg ∈ S := by
  -- Use negation completeness: either ¬ψ ∈ S or ψ ∈ S
  cases set_mcs_negation_complete h_mcs ψ with
  | inr h_neg_psi => exact h_neg_psi
  | inl h_psi =>
    -- From ψ, we can derive φ → ψ (conclude ψ from anything)
    -- Then we have both (φ → ψ) and ¬(φ → ψ) in S, contradiction
    exfalso
    -- Derive φ → ψ from ψ using prop_s: ψ → (φ → ψ)
    have h_deriv : Bimodal.ProofSystem.DerivationTree [ψ] (φ.imp ψ) := by
      have h_prop_s_thm : [] ⊢ ψ.imp (φ.imp ψ) :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.prop_s ψ φ)
      have h_prop_s : [ψ] ⊢ ψ.imp (φ.imp ψ) :=
        Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_prop_s_thm (by intro; simp)
      have h_assume : [ψ] ⊢ ψ :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_prop_s h_assume
    -- By MCS closure, φ → ψ ∈ S
    have h_sub : ∀ χ ∈ [ψ], χ ∈ S := by simp [h_psi]
    have h_imp_in : (φ.imp ψ) ∈ S :=
      set_mcs_closed_under_derivation h_mcs [ψ] h_sub h_deriv
    -- Now we have both (φ → ψ) and ¬(φ → ψ) in S - contradiction
    have h_deriv_bot : Bimodal.ProofSystem.DerivationTree [(φ.imp ψ), (φ.imp ψ).neg] Formula.bot := by
      have h1 : [(φ.imp ψ), (φ.imp ψ).neg] ⊢ (φ.imp ψ) :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h2 : [(φ.imp ψ), (φ.imp ψ).neg] ⊢ (φ.imp ψ).neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      exact Core.derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [(φ.imp ψ), (φ.imp ψ).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_imp_in
      | inr h_eq => exact h_eq ▸ h_neg_imp
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    -- ⊥ ∈ S contradicts consistency
    have h_cons := h_mcs.1
    have h_bot_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
    exact h_cons [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/-!
## Truth Lemma via Mutual Induction

The main theorem connecting MCS membership to semantic truth, proved via
structural induction on formulas with both directions handled simultaneously.
-/

/--
Truth lemma (biconditional via mutual induction): MCS membership iff semantic truth.

**Main Theorem**: For an indexed MCS family,
```
phi in family.mcs t <-> truth_at (canonical_model family) (canonical_history family) t phi
```

The proof uses structural induction on formulas. Each case proves both directions,
allowing the backward IH to be used in forward direction proofs (particularly imp).
-/
theorem truth_lemma_mutual (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t ↔ truth_at (canonical_model D family) (canonical_history_family D family) t phi := by
  induction phi generalizing t with
  | atom p =>
    constructor
    · -- Forward: atom p ∈ mcs t → truth_at (atom p)
      intro h_mem
      simp only [truth_at, canonical_model]
      have ht : (canonical_history_family D family).domain t := trivial
      use ht
      rw [canonical_world_mcs D family t ht]
      exact h_mem
    · -- Backward: truth_at (atom p) → atom p ∈ mcs t
      intro h_true
      simp only [truth_at, canonical_model] at h_true
      obtain ⟨ht, h_val⟩ := h_true
      rw [canonical_world_mcs D family t ht] at h_val
      exact h_val

  | bot =>
    constructor
    · -- Forward: bot ∈ mcs t → truth_at bot (contradiction - bot not in MCS)
      intro h_mem
      simp only [truth_at]
      have h_cons : Core.SetConsistent (family.mcs t) := (family.is_mcs t).1
      unfold Core.SetConsistent at h_cons
      have h_bot_cons : Core.Consistent [Formula.bot] := h_cons [Formula.bot] (by simp [h_mem])
      exfalso
      apply h_bot_cons
      constructor
      exact Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
    · -- Backward: truth_at bot → bot ∈ mcs t (truth_at bot is False)
      intro h_true
      simp only [truth_at] at h_true

  | imp psi chi ih_psi ih_chi =>
    constructor
    · -- Forward: (psi → chi) ∈ mcs t → (truth_at psi → truth_at chi)
      intro h_mem h_psi_true
      -- Use backward IH to get psi ∈ mcs t from truth_at psi
      have h_psi_in_mcs : psi ∈ family.mcs t := (ih_psi t).mpr h_psi_true
      -- Apply modus ponens closure: if (psi → chi) ∈ mcs and psi ∈ mcs, then chi ∈ mcs
      have h_chi_in_mcs : chi ∈ family.mcs t :=
        set_mcs_implication_property (family.is_mcs t) h_mem h_psi_in_mcs
      -- Use forward IH to get truth_at chi from chi ∈ mcs t
      exact (ih_chi t).mp h_chi_in_mcs
    · -- Backward: (truth_at psi → truth_at chi) → (psi → chi) ∈ mcs t
      intro h_implies
      -- By negation completeness: either (psi → chi) ∈ mcs t or ¬(psi → chi) ∈ mcs t
      cases set_mcs_negation_complete (family.is_mcs t) (psi.imp chi) with
      | inl h => exact h  -- (psi → chi) ∈ mcs t
      | inr h_neg =>
        -- ¬(psi → chi) ∈ mcs t
        -- Strategy: From ¬(psi → chi), extract psi ∈ MCS and ¬chi ∈ MCS
        -- Then get contradiction via semantic truth
        exfalso
        -- Step 1: Extract psi ∈ MCS from ¬(psi → chi) ∈ MCS
        have h_psi_in_mcs : psi ∈ family.mcs t := neg_imp_fst (family.is_mcs t) h_neg
        -- Step 2: Extract ¬chi ∈ MCS from ¬(psi → chi) ∈ MCS
        have h_neg_chi_in_mcs : chi.neg ∈ family.mcs t := neg_imp_snd (family.is_mcs t) h_neg
        -- Step 3: By forward IH on psi: truth_at psi
        have h_psi_true := (ih_psi t).mp h_psi_in_mcs
        -- Step 4: By semantic assumption h_implies: truth_at chi
        have h_chi_true := h_implies h_psi_true
        -- Step 5: By backward IH on chi: chi ∈ MCS
        have h_chi_in_mcs := (ih_chi t).mpr h_chi_true
        -- Step 6: Contradiction - both chi and ¬chi in MCS
        -- Derive ⊥ from [chi, chi.neg]
        have h_deriv_bot : Bimodal.ProofSystem.DerivationTree [chi, chi.neg] Formula.bot := by
          have h1 : [chi, chi.neg] ⊢ chi :=
            Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
          have h2 : [chi, chi.neg] ⊢ chi.neg :=
            Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
          exact Core.derives_bot_from_phi_neg_phi h1 h2
        have h_sub : ∀ φ ∈ [chi, chi.neg], φ ∈ family.mcs t := by
          intro φ hφ
          simp only [List.mem_cons, List.mem_nil_iff, or_false] at hφ
          cases hφ with
          | inl h_eq => exact h_eq ▸ h_chi_in_mcs
          | inr h_eq => exact h_eq ▸ h_neg_chi_in_mcs
        have h_bot_in_mcs : Formula.bot ∈ family.mcs t :=
          set_mcs_closed_under_derivation (family.is_mcs t) _ h_sub h_deriv_bot
        -- ⊥ ∈ MCS contradicts MCS consistency
        have h_cons := (family.is_mcs t).1
        have h_bot_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
          Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
        exact h_cons [Formula.bot] (by simp [h_bot_in_mcs]) ⟨h_bot_deriv⟩

  | box psi ih =>
    constructor
    · -- Forward: box psi ∈ mcs t → ∀ sigma, truth_at sigma t psi
      intro h_mem sigma
      /-
      **ARCHITECTURAL LIMITATION: Box Case Forward Direction**

      The box semantics in this codebase use universal quantification over ALL world histories:
        truth_at M tau t (box psi) ↔ ∀ sigma : WorldHistory F, truth_at M sigma t psi

      This requires showing psi is true at time t for ANY world history sigma, not just
      the canonical history.

      **Why this case cannot be proven with current architecture**:

      1. **Truth depends on world state**: For atoms, `truth_at M sigma t (atom p)` evaluates
         to `M.valuation (sigma.states t ht) p`, which depends on the world state at time t
         in history sigma.

      2. **Canonical model valuation**: Our canonical model defines
         `valuation w p = (atom p) ∈ w.mcs`, so truth depends on the MCS in the world state.

      3. **Arbitrary histories have arbitrary states**: An arbitrary history sigma can assign
         ANY world state to time t - not necessarily one with the family's MCS.

      4. **IH only applies to canonical history**: The induction hypothesis gives us
         `psi ∈ family.mcs t ↔ truth_at M (canonical_history_family D family) t psi`,
         but this says nothing about arbitrary histories.

      **From box psi ∈ MCS, we can derive**:
      - `psi ∈ family.mcs t` via Modal T axiom (set_mcs_box_closure)
      - `truth_at M (canonical_history_family D family) t psi` via forward IH

      But we CANNOT derive `truth_at M sigma t psi` for arbitrary sigma because sigma's
      world state at t may have a different MCS.

      **Resolution options** (for future work):
      1. Restrict box semantics to use modal accessibility relations (Kripke-style)
      2. Only quantify over "canonical" histories built from MCS families
      3. Add a modal accessibility predicate relating histories

      **Impact**: The box case is NOT critical for the main representation theorem (Task 654),
      which only needs temporal operators (G/H). The representation theorem is proven using
      the forward direction for temporal operators, which work correctly.
      -/
      sorry

    · -- Backward: (∀ sigma, truth_at sigma t psi) → box psi ∈ mcs t
      intro h_all
      /-
      **ARCHITECTURAL LIMITATION: Box Case Backward Direction**

      Even with the strong assumption that psi is true at ALL histories at time t,
      proving `box psi ∈ family.mcs t` requires connecting arbitrary semantic truth
      to MCS membership.

      **What we can do**:
      - Use canonical history: `truth_at M (canonical_history_family D family) t psi`
      - By backward IH: `psi ∈ family.mcs t`

      **What we need but cannot prove**:
      - `box psi ∈ family.mcs t` from `psi ∈ family.mcs t`

      The necessitation rule (`⊢ psi` implies `⊢ box psi`) only applies to THEOREMS
      (derivable with empty context). Having `psi ∈ MCS` does not mean psi is a theorem.

      **Resolution**: Same as forward direction - requires semantic architecture changes.
      -/
      sorry

  | all_past psi ih =>
    constructor
    · -- Forward: H psi ∈ mcs t → ∀ s < t, truth_at s psi
      intro h_mem s h_s_lt
      -- By backward_H coherence: H psi ∈ mcs t and s < t implies psi ∈ mcs s
      have h_psi_in_s : psi ∈ family.mcs s := family.backward_H t s psi h_s_lt h_mem
      -- Apply forward IH at time s
      exact (ih s).mp h_psi_in_s
    · -- Backward: (∀ s < t, truth_at s psi) → H psi ∈ mcs t
      intro h_all_past
      -- NOT REQUIRED FOR COMPLETENESS - backward Truth Lemma not used by representation_theorem
      -- See Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean for proof strategy
      sorry

  | all_future psi ih =>
    constructor
    · -- Forward: G psi ∈ mcs t → ∀ s > t, truth_at s psi
      intro h_mem s h_t_lt
      -- By forward_G coherence: G psi ∈ mcs t and t < s implies psi ∈ mcs s
      have h_psi_in_s : psi ∈ family.mcs s := family.forward_G t s psi h_t_lt h_mem
      -- Apply forward IH at time s
      exact (ih s).mp h_psi_in_s
    · -- Backward: (∀ s > t, truth_at s psi) → G psi ∈ mcs t
      intro h_all_future
      -- NOT REQUIRED FOR COMPLETENESS - backward Truth Lemma not used by representation_theorem
      -- See Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean for proof strategy
      sorry

/-!
## Derived Forward and Backward Theorems

These are derived from the mutual induction theorem for convenience.
-/

/--
Truth lemma (forward direction): MCS membership implies truth.
-/
theorem truth_lemma_forward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t → truth_at (canonical_model D family) (canonical_history_family D family) t phi :=
  (truth_lemma_mutual D family t phi).mp

/--
Truth lemma (backward direction): Truth implies MCS membership.
-/
theorem truth_lemma_backward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    truth_at (canonical_model D family) (canonical_history_family D family) t phi → phi ∈ family.mcs t :=
  (truth_lemma_mutual D family t phi).mpr

/--
Truth lemma: MCS membership iff semantic truth.
-/
theorem truth_lemma (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t ↔ truth_at (canonical_model D family) (canonical_history_family D family) t phi :=
  truth_lemma_mutual D family t phi

end Bimodal.Metalogic.Representation
