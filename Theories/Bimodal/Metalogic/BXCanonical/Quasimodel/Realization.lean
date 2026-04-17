import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction
import Bimodal.Syntax.BigConj
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Propositional

/-!
# Realization Lifting Lemma

Proves that abstract Hintikka chains can be lifted to concrete BXPoint chains
in the canonical model, preserving the temporal ordering `bx_le`.

## Main Definitions

- `until_forward_seed`: The enriched Lindenbaum seed for Until eventuality resolution
- `since_backward_seed`: The enriched Lindenbaum seed for Since eventuality resolution

## Main Results

- `until_eventuality_resolution`: Until eventuality resolution (delegates to Frame.lean)
- `since_eventuality_resolution`: Since eventuality resolution (delegates to Frame.lean)

## Mathematical Analysis

The Until/Since functions in this module now delegate to Frame.lean's canonical
versions (identical signatures). The sorry root cause analysis has been moved
to `CanonicalChain.lean`.

The key insight: the guard property in these signatures is mathematically
correct but appears unprovable from BX1-BX12 due to non-totality of the
`bx_le` preorder. See `CanonicalChain.lean` for the full analysis and
recommended resolution path (chain-based completeness).

## References

- Verbrugge 2007: "Completeness by Construction" (realization technique)
- Burgess 1984: One-step defect discharge
- Reynolds 2003: Until axiomatization and completeness
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical

/-! ## Helper: F(ψ) from ψ ∈ w

Any formula in an MCS has its F (some_future) also in the MCS.
Proof: if G(¬ψ) ∈ w, then ¬ψ ∈ w (BX1), contradicting ψ ∈ w.
So G(¬ψ) ∉ w, hence F(ψ) = ¬G(¬ψ) ∈ w. -/

theorem F_of_mem {w : BXPoint} {ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.some_future ψ ∈ w.formulas := by
  -- F(ψ) = ¬G(¬ψ). Show G(¬ψ) ∉ w.
  by_contra h_not_F
  -- ¬F(ψ) ∈ w means G(¬ψ) ∈ w (F = ¬G¬, so ¬F = ¬¬G¬ = G¬ in classical)
  have h_F_def : Formula.some_future ψ = Formula.neg (Formula.all_future (Formula.neg ψ)) := rfl
  rw [h_F_def] at h_not_F
  have h_G_neg : Formula.all_future (Formula.neg ψ) ∈ w.formulas := by
    rcases SetMaximalConsistent.negation_complete w.is_mcs (Formula.all_future (Formula.neg ψ)) with h_pos | h_neg
    · exact h_pos
    · exact absurd h_neg h_not_F
  -- G(¬ψ) ∈ w → ¬ψ ∈ w (BX1)
  have h_ax : DerivationTree [] ((Formula.all_future (Formula.neg ψ)).imp (Formula.neg ψ)) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future (Formula.neg ψ))
  have h_neg : Formula.neg ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_G_neg
  exact set_consistent_not_both w.is_mcs.1 ψ h h_neg

/-- P(ψ) ∈ w when ψ ∈ w. Dual of F_of_mem. -/
theorem P_of_mem {w : BXPoint} {ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.some_past ψ ∈ w.formulas := by
  by_contra h_not_P
  have h_P_def : Formula.some_past ψ = Formula.neg (Formula.all_past (Formula.neg ψ)) := rfl
  rw [h_P_def] at h_not_P
  have h_H_neg : Formula.all_past (Formula.neg ψ) ∈ w.formulas := by
    rcases SetMaximalConsistent.negation_complete w.is_mcs (Formula.all_past (Formula.neg ψ)) with h_pos | h_neg
    · exact h_pos
    · exact absurd h_neg h_not_P
  have h_ax : DerivationTree [] ((Formula.all_past (Formula.neg ψ)).imp (Formula.neg ψ)) :=
    DerivationTree.axiom [] _ (Axiom.temp_t_past (Formula.neg ψ))
  have h_neg : Formula.neg ψ ∈ w.formulas :=
    SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_H_neg
  exact set_consistent_not_both w.is_mcs.1 ψ h h_neg

/-! ## Helper: F(ψ) from bx_le w v and ψ ∈ v

If bx_le w v and ψ ∈ v, then F(ψ) ∈ w.
Uses BX4' (connect_past: φ → H(F(φ))) and bx_H_forward. -/

theorem F_from_above {w v : BXPoint} {ψ : Formula}
    (h_le : bx_le w v) (h_mem : ψ ∈ v.formulas) :
    Formula.some_future ψ ∈ w.formulas := by
  -- ψ ∈ v → H(F(ψ)) ∈ v (BX4': connect_past)
  have h_connect := connect_past_mcs h_mem
  -- H(F(ψ)) ∈ v and bx_le w v → F(ψ) ∈ w
  exact bx_H_forward h_le h_connect

/-! ## Phase 4 Scaffolding: DerivationTree-level bigconj helpers

These lemmas turn a list of formulas into a `DerivationTree`-level
conjunction (and back). They are consumed by the chain-step seed
consistency reduction below: given a finite subset `L_h` of a Hintikka
point's formulas, we need to move between "each element of `L_h` is
derivable" and "the conjunction `bigconj L_h` is derivable".

They are colocated here (rather than in `Bimodal.Syntax.BigConj`) because
they depend on `DerivationTree` and the propositional combinator library,
whereas `BigConj.lean` is `DerivationTree`-free scaffolding for the
Fisher-Ladner `EnrichedClosure`. -/

/-- Conjunction introduction from a list of assumptions:
    the list derives its own big conjunction. -/
noncomputable def bigconj_intro : (L : List Formula) → L ⊢ bigconj L
  | [] => by
      -- bigconj [] = ¬⊥ = ⊥ → ⊥
      have h : ⊢ Formula.bot.imp Formula.bot :=
        Bimodal.Theorems.Combinators.identity Formula.bot
      show [] ⊢ Formula.bot.neg
      simpa [bigconj, Formula.neg] using h
  | [a] => by
      -- bigconj [a] = a; the list derives a by assumption.
      show [a] ⊢ a
      simpa [bigconj] using
        DerivationTree.assumption [a] a (by simp)
  | a :: b :: rest => by
      -- bigconj (a :: b :: rest) = a ∧ bigconj (b :: rest)
      have h_rec : (b :: rest) ⊢ bigconj (b :: rest) := bigconj_intro (b :: rest)
      have h_rec_w : (a :: b :: rest) ⊢ bigconj (b :: rest) :=
        DerivationTree.weakening _ _ _ h_rec (by
          intro x hx
          simp at hx
          rcases hx with rfl | hx'
          · simp
          · simp [hx'])
      have h_a : (a :: b :: rest) ⊢ a :=
        DerivationTree.assumption _ a (by simp)
      have h_pair :
          ⊢ a.imp ((bigconj (b :: rest)).imp (Formula.and a (bigconj (b :: rest)))) :=
        Bimodal.Theorems.Combinators.pairing a (bigconj (b :: rest))
      have h_pair_w :
          (a :: b :: rest) ⊢ a.imp ((bigconj (b :: rest)).imp
            (Formula.and a (bigconj (b :: rest)))) :=
        DerivationTree.weakening [] (a :: b :: rest) _ h_pair (by intro; simp)
      have h_step1 : (a :: b :: rest) ⊢
          (bigconj (b :: rest)).imp (Formula.and a (bigconj (b :: rest))) :=
        DerivationTree.modus_ponens _ _ _ h_pair_w h_a
      have h_step2 : (a :: b :: rest) ⊢ Formula.and a (bigconj (b :: rest)) :=
        DerivationTree.modus_ponens _ _ _ h_step1 h_rec_w
      show (a :: b :: rest) ⊢ bigconj (a :: b :: rest)
      simpa [bigconj] using h_step2

/-- Conjunction elimination: `[bigconj L] ⊢ φ` for every `φ ∈ L`. -/
noncomputable def bigconj_mem_iff :
    (L : List Formula) → (φ : Formula) → φ ∈ L → [bigconj L] ⊢ φ
  | [], _, h => by simp at h
  | [a], φ, h => by
      have heq : φ = a := by simpa using h
      subst heq
      show [bigconj [φ]] ⊢ φ
      simpa [bigconj] using DerivationTree.assumption [φ] φ (by simp)
  | a :: b :: rest, φ, h => by
      show [bigconj (a :: b :: rest)] ⊢ φ
      rw [show bigconj (a :: b :: rest) = Formula.and a (bigconj (b :: rest)) from rfl]
      by_cases hφa : φ = a
      · subst hφa
        exact Bimodal.Theorems.Propositional.lce φ (bigconj (b :: rest))
      · have h_in : φ ∈ b :: rest := by
          rcases List.mem_cons.mp h with rfl | h'
          · exact absurd rfl hφa
          · exact h'
        have h_rce : [Formula.and a (bigconj (b :: rest))] ⊢ bigconj (b :: rest) :=
          Bimodal.Theorems.Propositional.rce a (bigconj (b :: rest))
        have h_rec : [bigconj (b :: rest)] ⊢ φ := bigconj_mem_iff (b :: rest) φ h_in
        have h_imp : [] ⊢ (bigconj (b :: rest)).imp φ :=
          deduction_theorem [] (bigconj (b :: rest)) φ (by simpa using h_rec)
        have h_imp_w :
            [Formula.and a (bigconj (b :: rest))] ⊢ (bigconj (b :: rest)).imp φ :=
          DerivationTree.weakening [] _ _ h_imp (by intro; simp)
        exact DerivationTree.modus_ponens _ _ _ h_imp_w h_rce

/-! ## Enriched Seed Consistency

Key lemma for until_backward: the enriched seed
`{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)` is consistent
when ¬(φ U ψ) ∈ w and bx_le w v and ψ ∈ v.

The proof uses the fact that all formulas in g_content(w) ∪ h_content(v)
are also in w.formulas (by BX1 and bx_H_forward respectively). -/

theorem enriched_seed_consistent_until
    (w v : BXPoint) (φ ψ : Formula)
    (h_neg_until : (Formula.untl φ ψ).neg ∈ w.formulas)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas) :
    SetConsistent ({(Formula.untl φ ψ).neg} ∪ g_content w.formulas ∪ h_content v.formulas) := by
  intro L hL ⟨d⟩
  -- All formulas in the seed that are NOT ¬(φ U ψ) are in w.formulas
  -- - g_content(w) ⊆ w.formulas (by BX1: G(χ) → χ)
  -- - h_content(v) ⊆ w.formulas (by bx_H_forward: bx_le w v → H(χ) ∈ v → χ ∈ w)
  have h_seed_in_w : ∀ α ∈ L, α ≠ (Formula.untl φ ψ).neg → α ∈ w.formulas := by
    intro α hα h_ne
    have h_mem := hL α hα
    simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
    rcases h_mem with (rfl | h_g) | h_h
    · exact absurd rfl h_ne
    · -- α ∈ g_content(w): G(α) ∈ w → α ∈ w by BX1
      have h_Gα : Formula.all_future α ∈ w.formulas := h_g
      have h_ax : DerivationTree [] ((Formula.all_future α).imp α) :=
        DerivationTree.axiom [] _ (Axiom.temp_t_future α)
      exact SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_ax) h_Gα
    · -- α ∈ h_content(v): H(α) ∈ v → α ∈ w by bx_H_forward
      exact bx_H_forward h_wv h_h
  -- Case split on whether ¬(φ U ψ) ∈ L
  by_cases h_neg_in : (Formula.untl φ ψ).neg ∈ L
  · -- ¬(φ U ψ) ∈ L: deduction gives L' ⊢ ¬¬(φ U ψ), i.e., L' ⊢ φ U ψ
    let L' := L.filter (fun y => decide (y ≠ (Formula.untl φ ψ).neg))
    have d_reord : DerivationTree ((Formula.untl φ ψ).neg :: L') Formula.bot :=
      derivation_exchange d (fun x => (cons_filter_neq_perm h_neg_in x).symm)
    have d_negneg : DerivationTree L' (Formula.neg (Formula.untl φ ψ).neg) :=
      deduction_theorem L' (Formula.untl φ ψ).neg Formula.bot d_reord
    -- L' ⊆ w.formulas (all non-¬(φ U ψ) elements are in w)
    have h_L'_in_w : ∀ α ∈ L', α ∈ w.formulas := by
      intro α hα
      have h_and := List.mem_filter.mp hα
      have h_ne : α ≠ (Formula.untl φ ψ).neg := by simpa using h_and.2
      exact h_seed_in_w α h_and.1 h_ne
    -- By MCS closure: ¬¬(φ U ψ) ∈ w
    have h_negneg_in_w := SetMaximalConsistent.closed_under_derivation w.is_mcs L' h_L'_in_w d_negneg
    -- DNE: ¬¬(φ U ψ) → φ U ψ
    have h_dne := Bimodal.Theorems.Propositional.double_negation (Formula.untl φ ψ)
    have h_until_in_w := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_dne) h_negneg_in_w
    -- But ¬(φ U ψ) ∈ w: contradiction!
    exact set_consistent_not_both w.is_mcs.1 (Formula.untl φ ψ) h_until_in_w h_neg_until
  · -- ¬(φ U ψ) ∉ L: all of L ⊆ w.formulas
    have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := by
      intro α hα
      exact h_seed_in_w α hα (fun h_eq => h_neg_in (h_eq ▸ hα))
    -- L ⊆ w.formulas and L ⊢ ⊥ contradicts w consistent
    exact w.is_mcs.1 L h_L_in_w ⟨d⟩

/-- Dual: enriched seed for Since backward direction. -/
theorem enriched_seed_consistent_since
    (w v : BXPoint) (φ ψ : Formula)
    (h_neg_since : (Formula.snce φ ψ).neg ∈ w.formulas)
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas) :
    SetConsistent ({(Formula.snce φ ψ).neg} ∪ h_content w.formulas ∪ g_content v.formulas) := by
  intro L hL ⟨d⟩
  -- All non-¬(φ S ψ) elements of L are in w.formulas:
  -- - h_content(w) ⊆ w (by BX1': H(χ) → χ)
  -- - g_content(v) ⊆ w (by bx_G_forward: bx_le v w → G(χ) ∈ v → ... wait, we need
  --   g_content(v) ⊆ w means ∀ χ, G(χ) ∈ v → χ ∈ w. But bx_le v w means
  --   g_content(v) ⊆ w, which gives χ ∈ w directly.)
  have h_seed_in_w : ∀ α ∈ L, α ≠ (Formula.snce φ ψ).neg → α ∈ w.formulas := by
    intro α hα h_ne
    have h_mem := hL α hα
    simp only [Set.mem_union, Set.mem_singleton_iff] at h_mem
    rcases h_mem with (rfl | h_h) | h_g
    · exact absurd rfl h_ne
    · -- α ∈ h_content(w): H(α) ∈ w → α ∈ w by BX1'
      have h_Hα : Formula.all_past α ∈ w.formulas := h_h
      have h_ax : DerivationTree [] ((Formula.all_past α).imp α) :=
        DerivationTree.axiom [] _ (Axiom.temp_t_past α)
      exact SetMaximalConsistent.implication_property w.is_mcs
        (theorem_in_mcs w.is_mcs h_ax) h_Hα
    · -- α ∈ g_content(v): G(α) ∈ v. bx_le v w means g_content(v) ⊆ w.
      exact h_vw h_g
  by_cases h_neg_in : (Formula.snce φ ψ).neg ∈ L
  · let L' := L.filter (fun y => decide (y ≠ (Formula.snce φ ψ).neg))
    have d_reord : DerivationTree ((Formula.snce φ ψ).neg :: L') Formula.bot :=
      derivation_exchange d (fun x => (cons_filter_neq_perm h_neg_in x).symm)
    have d_negneg : DerivationTree L' (Formula.neg (Formula.snce φ ψ).neg) :=
      deduction_theorem L' (Formula.snce φ ψ).neg Formula.bot d_reord
    have h_L'_in_w : ∀ α ∈ L', α ∈ w.formulas := by
      intro α hα
      have h_and := List.mem_filter.mp hα
      have h_ne : α ≠ (Formula.snce φ ψ).neg := by simpa using h_and.2
      exact h_seed_in_w α h_and.1 h_ne
    have h_negneg_in_w := SetMaximalConsistent.closed_under_derivation w.is_mcs L' h_L'_in_w d_negneg
    have h_dne := Bimodal.Theorems.Propositional.double_negation (Formula.snce φ ψ)
    have h_since_in_w := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_dne) h_negneg_in_w
    exact set_consistent_not_both w.is_mcs.1 (Formula.snce φ ψ) h_since_in_w h_neg_since
  · have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := by
      intro α hα
      exact h_seed_in_w α hα (fun h_eq => h_neg_in (h_eq ▸ hα))
    exact w.is_mcs.1 L h_L_in_w ⟨d⟩

/-! ## Phase 4a: Chain-step seed consistency (enriched with g_content)

Task 98 Phase 4a (plan v4): lift task 99's `chain_step_seed_consistent`
to the enriched seed `h.formulas ∪ g_content v.formulas`, where
`h : HintikkaPoint Sigma` is a point of a witnessed Hintikka chain and
`v : BXPoint` is the prior BXPoint being extended in the `realize_chain_step`
construction.

The proof is a one-step subset-of-MCS argument: `ChainWitnessed` gives us
a `BXPoint w` backing `h` with `h.formulas ⊆ w.formulas`; the hypothesis
`h_bx_le_witness` additionally states that `bx_le v w` (i.e.
`g_content v.formulas ⊆ w.formulas`). Together, every element of the
enriched seed lies in `w.formulas`, so `w.is_mcs.1` discharges any
`SetConsistent` obligation.

This matches the `h_neg_in = false` branch of
`enriched_seed_consistent_until` above and the one-line proof of
`chain_step_seed_consistent` in `Construction.lean:676-690`; it is the
lifting lemma Phase 5's stricter seed (C.4) consumes for the
`h.formulas ∪ g_content v.formulas` chunk. -/

theorem chain_step_seed_consistent_enriched
    {Sigma : Finset Formula} {c : HintikkaRawChain Sigma}
    (h_wit : ChainWitnessed c)
    {h : HintikkaPoint Sigma} (h_mem : h ∈ c.points)
    (v : BXPoint)
    (h_bx_le_witness :
      ∀ w : BXPoint, (∀ f ∈ h.formulas, f ∈ w.formulas) → bx_le v w) :
    SetConsistent ((h.formulas : Set Formula) ∪ g_content v.formulas) := by
  -- Extract a BXPoint witness `w` backing `h` from the `ChainWitnessed` predicate.
  obtain ⟨w, hw⟩ := h_wit h h_mem
  -- The caller-supplied witness hypothesis upgrades the backing witness to `bx_le v w`.
  have h_vw : bx_le v w := h_bx_le_witness w hw
  -- Any list from the enriched seed is entirely contained in `w.formulas`.
  intro L hL ⟨d⟩
  have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := by
    intro α hα
    have h_mem_L := hL α hα
    rcases h_mem_L with h_h | h_g
    · exact hw α h_h
    · exact h_vw h_g
  exact w.is_mcs.1 L h_L_in_w ⟨d⟩

/-- Since dual of `chain_step_seed_consistent_enriched`: the enriched
    seed `h.formulas ∪ h_content v.formulas` is consistent whenever the
    chain is witnessed and the caller can upgrade the backing witness
    `w` to `bx_le w v` (equivalently `h_content v.formulas ⊆ w.formulas`
    via `h_content_subset_implies_g_content_reverse`).

    Phase 4b will consume this lemma once `HintikkaStepOracleSince` is
    strengthened to carry a `WitnessedHintikka`. The statement is already
    provable today because `ChainWitnessed` is domain-agnostic. -/
theorem chain_step_seed_consistent_enriched_since
    {Sigma : Finset Formula} {c : HintikkaRawChain Sigma}
    (h_wit : ChainWitnessed c)
    {h : HintikkaPoint Sigma} (h_mem : h ∈ c.points)
    (v : BXPoint)
    (h_h_content_witness :
      ∀ w : BXPoint, (∀ f ∈ h.formulas, f ∈ w.formulas) →
        h_content v.formulas ⊆ w.formulas) :
    SetConsistent ((h.formulas : Set Formula) ∪ h_content v.formulas) := by
  obtain ⟨w, hw⟩ := h_wit h h_mem
  have h_hv : h_content v.formulas ⊆ w.formulas := h_h_content_witness w hw
  intro L hL ⟨d⟩
  have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := by
    intro α hα
    have h_mem_L := hL α hα
    rcases h_mem_L with h_h | h_g
    · exact hw α h_h
    · exact h_hv h_g
  exact w.is_mcs.1 L h_L_in_w ⟨d⟩

/-! ## Phase 5: Chain Realization Infrastructure

Task 98 Phase 5 (plan v4): infrastructure for realizing a Hintikka chain
as a chain of BXPoints in the canonical model.

### Mathematical Analysis

The plan's "strict seed" approach (C.4) proposes a Lindenbaum seed
`h_{i+1}.formulas ∪ g_content(v_i.formulas) ∪ {¬f | f ∈ Sigma \ h_{i+1}}`
to realize each chain step. Analysis reveals a genuine obstacle:

**Obstacle**: `g_content(v_i) ⊆ w_{i+1}.formulas` (required for seed consistency
via `chain_step_seed_consistent_enriched`) fails for `G(χ) ∈ v_i` with
`G(χ) ∉ Sigma`. The `hintikka_step` only propagates G-formulas *within* Sigma,
so `χ ∈ h_{i+1}` is not guaranteed when `G(χ) ∉ Sigma`. If additionally
`χ ∈ Sigma` and `χ ∉ h_{i+1}`, the strict seed forces `¬χ ∈ v_{i+1}` while
`bx_le` forces `χ ∈ v_{i+1}`, making the seed inconsistent.

**Further obstacle**: G-formulas do NOT persist through the Hintikka chain.
For `G(χ) ∈ h_i` (with `G(χ) ∈ Sigma`), hintikka_step gives `χ ∈ h_{i+1}`,
but `G(χ) ∈ h_{i+1}` is not guaranteed: the witness `w_{i+1}` backing `h_{i+1}`
may have `¬G(χ) ∈ w_{i+1}` (meaning χ holds now but not always in the future),
which is consistent with `χ ∈ h_{i+1}`. Without G-persistence, χ may not reach
the last point of chains longer than 2.

**Consequence**: Chain realization requires either (a) G-persistence in the
Sigma-closure (not available for the enriched closure), or (b) a completely
different approach. The guard property (`φ ∈ u` for arbitrary intermediate
BXPoints `u`) additionally requires locus-control exhaustiveness (Phase 6).

### Proven Infrastructure

The lemmas below provide the *provable* building blocks:
- `hintikka_step_g_prop`: G-propagation through a single hintikka_step
- `g_content_sigma` / `g_content_sigma_sub_g_content`: Sigma-restricted g_content
-/

/-- The Sigma-restricted g_content of a BXPoint: only those `χ` where
    `G(χ) ∈ w.formulas` AND `G(χ) ∈ Sigma`. This subset of g_content is
    guaranteed to propagate through `hintikka_step` (via the G-propagation
    clause), unlike full `g_content` which may contain `G(χ) ∉ Sigma`. -/
def g_content_sigma (w : BXPoint) (Sigma : Finset Formula) : Set Formula :=
  {χ : Formula | Formula.all_future χ ∈ w.formulas ∧ Formula.all_future χ ∈ Sigma}

/-- g_content_sigma is a subset of g_content. -/
theorem g_content_sigma_sub_g_content (w : BXPoint) (Sigma : Finset Formula) :
    g_content_sigma w Sigma ⊆ g_content w.formulas := by
  intro χ hχ
  exact hχ.1

/-- G-propagation at the Hintikka level: if `hintikka_step h₁ h₂` and
    `G(χ) ∈ h₁.formulas`, then `χ ∈ h₂.formulas`. This is the first
    clause of `hintikka_step`. -/
theorem hintikka_step_g_prop
    {Sigma : Finset Formula} {h₁ h₂ : HintikkaPoint Sigma}
    (h_step : hintikka_step h₁ h₂) {χ : Formula}
    (h_Gχ : Formula.all_future χ ∈ h₁.formulas) :
    χ ∈ h₂.formulas :=
  h_step.1 χ h_Gχ

/-! ## Until Eventuality Resolution (delegates to Frame.lean) -/

noncomputable def until_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas :=
  bx_until_eventuality_resolution w φ ψ h_until h_not_psi

/-! ## Since Eventuality Resolution (delegates to Frame.lean) -/

noncomputable def since_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas :=
  bx_since_eventuality_resolution w φ ψ h_since h_not_psi

/-! ## SubformulaClosure Temporal Closure Properties

The Quasimodel `SubformulaClosure` (with G/H enrichment and negation pairing)
satisfies the key closure property needed by hintikka_step:
if `G(χ) ∈ Sigma` or `H(χ) ∈ Sigma`, then `χ ∈ Sigma`.
Similarly, if `(φ U ψ) ∈ Sigma`, then `φ, ψ ∈ Sigma`.

These are essential for the oracle construction: when we project a BXPoint
to a Sigma-signature, G-propagation and Until-propagation at the BXPoint
level must land back inside Sigma. -/

/-- `G(χ) ∈ subformulas target → χ ∈ subformulas target`. -/
private theorem subformulas_G_unwrap {target χ : Formula}
    (h : Formula.all_future χ ∈ subformulas target) :
    χ ∈ subformulas target := by
  induction target with
  | atom _ => simp [subformulas] at h
  | bot => simp [subformulas] at h
  | imp a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · exact Or.inr (Or.inl (iha ha))
    · exact Or.inr (Or.inr (ihb hb))
  | box a ih =>
    simp [subformulas] at h ⊢; exact Or.inr (ih h)
  | all_future a ih =>
    simp [subformulas] at h ⊢; rcases h with rfl | ha
    · exact Or.inr (self_mem_subformulas _)
    · exact Or.inr (ih ha)
  | all_past a ih =>
    simp [subformulas] at h ⊢; exact Or.inr (ih h)
  | untl a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · exact Or.inr (Or.inl (iha ha))
    · exact Or.inr (Or.inr (ihb hb))
  | snce a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · exact Or.inr (Or.inl (iha ha))
    · exact Or.inr (Or.inr (ihb hb))

/-- `H(χ) ∈ subformulas target → χ ∈ subformulas target`. -/
private theorem subformulas_H_unwrap {target χ : Formula}
    (h : Formula.all_past χ ∈ subformulas target) :
    χ ∈ subformulas target := by
  induction target with
  | atom _ => simp [subformulas] at h
  | bot => simp [subformulas] at h
  | imp a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · exact Or.inr (Or.inl (iha ha))
    · exact Or.inr (Or.inr (ihb hb))
  | box a ih =>
    simp [subformulas] at h ⊢; exact Or.inr (ih h)
  | all_future a ih =>
    simp [subformulas] at h ⊢; exact Or.inr (ih h)
  | all_past a ih =>
    simp [subformulas] at h ⊢; rcases h with rfl | ha
    · exact Or.inr (self_mem_subformulas _)
    · exact Or.inr (ih ha)
  | untl a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · exact Or.inr (Or.inl (iha ha))
    · exact Or.inr (Or.inr (ihb hb))
  | snce a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · exact Or.inr (Or.inl (iha ha))
    · exact Or.inr (Or.inr (ihb hb))

/-- `(φ U ψ) ∈ subformulas target → φ, ψ ∈ subformulas target`. -/
private theorem subformulas_untl_unwrap {target φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ subformulas target) :
    φ ∈ subformulas target ∧ ψ ∈ subformulas target := by
  induction target with
  | atom _ => simp [subformulas] at h
  | bot => simp [subformulas] at h
  | imp a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · obtain ⟨l, r⟩ := iha ha; exact ⟨Or.inr (Or.inl l), Or.inr (Or.inl r)⟩
    · obtain ⟨l, r⟩ := ihb hb; exact ⟨Or.inr (Or.inr l), Or.inr (Or.inr r)⟩
  | box a ih =>
    simp [subformulas] at h ⊢
    obtain ⟨l, r⟩ := ih h; exact ⟨Or.inr l, Or.inr r⟩
  | all_future a ih =>
    simp [subformulas] at h ⊢
    obtain ⟨l, r⟩ := ih h; exact ⟨Or.inr l, Or.inr r⟩
  | all_past a ih =>
    simp [subformulas] at h ⊢
    obtain ⟨l, r⟩ := ih h; exact ⟨Or.inr l, Or.inr r⟩
  | untl a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ⟨rfl, rfl⟩ | ha | hb
    · exact ⟨Or.inr (Or.inl (self_mem_subformulas φ)),
             Or.inr (Or.inr (self_mem_subformulas ψ))⟩
    · obtain ⟨l, r⟩ := iha ha; exact ⟨Or.inr (Or.inl l), Or.inr (Or.inl r)⟩
    · obtain ⟨l, r⟩ := ihb hb; exact ⟨Or.inr (Or.inr l), Or.inr (Or.inr r)⟩
  | snce a b iha ihb =>
    simp [subformulas] at h ⊢; rcases h with ha | hb
    · obtain ⟨l, r⟩ := iha ha; exact ⟨Or.inr (Or.inl l), Or.inr (Or.inl r)⟩
    · obtain ⟨l, r⟩ := ihb hb; exact ⟨Or.inr (Or.inr l), Or.inr (Or.inr r)⟩

/-- Classify membership in `ghEnrichment`. -/
private theorem ghEnrichment_mem_cases {S : Finset Formula} {f : Formula}
    (h : f ∈ ghEnrichment S) :
    f ∈ S ∨ (∃ g ∈ S, f = Formula.all_future g) ∨ (∃ g ∈ S, f = Formula.all_past g) := by
  simp only [ghEnrichment, Finset.mem_union, Finset.mem_image] at h
  rcases h with (h_sub | ⟨g, hg, rfl⟩) | ⟨g, hg, rfl⟩
  · exact Or.inl h_sub
  · exact Or.inr (Or.inl ⟨g, hg, rfl⟩)
  · exact Or.inr (Or.inr ⟨g, hg, rfl⟩)

/-- Classify membership in `SubformulaClosure`. -/
private theorem SubformulaClosure_mem_cases {target f : Formula}
    (h : f ∈ SubformulaClosure target) :
    f ∈ ghEnrichment (subformulas target) ∨
    (∃ g ∈ ghEnrichment (subformulas target), f = Formula.neg g) := by
  simp only [SubformulaClosure, Finset.mem_union, Finset.mem_image] at h
  rcases h with h_base | ⟨g, hg, rfl⟩
  · exact Or.inl h_base
  · exact Or.inr ⟨g, hg, rfl⟩

theorem SubformulaClosure_G_closed {target χ : Formula}
    (h : Formula.all_future χ ∈ SubformulaClosure target) :
    χ ∈ SubformulaClosure target := by
  rcases SubformulaClosure_mem_cases h with h_base | ⟨g, _, hg_eq⟩
  · rcases ghEnrichment_mem_cases h_base with h_sub | ⟨f, hf, hfeq⟩ | ⟨f, _, hfeq⟩
    · exact subformula_mem (subformulas_G_unwrap h_sub)
    · have : χ = f := by injection hfeq
      subst this; exact subformula_mem hf
    · cases hfeq -- G(χ) = H(f) impossible
  · simp [Formula.neg] at hg_eq -- G(χ) = neg(g) impossible

/-- If `H(χ) ∈ SubformulaClosure target`, then `χ ∈ SubformulaClosure target`. -/
theorem SubformulaClosure_H_closed {target χ : Formula}
    (h : Formula.all_past χ ∈ SubformulaClosure target) :
    χ ∈ SubformulaClosure target := by
  rcases SubformulaClosure_mem_cases h with h_base | ⟨g, _, hg_eq⟩
  · rcases ghEnrichment_mem_cases h_base with h_sub | ⟨f, _, hfeq⟩ | ⟨f, hf, hfeq⟩
    · exact subformula_mem (subformulas_H_unwrap h_sub)
    · cases hfeq -- H(χ) = G(f) impossible
    · have : χ = f := by injection hfeq
      subst this; exact subformula_mem hf
  · simp [Formula.neg] at hg_eq -- H(χ) = neg(g) impossible

/-- If `(φ U ψ) ∈ SubformulaClosure target`, then `φ, ψ ∈ SubformulaClosure target`. -/
theorem SubformulaClosure_untl_closed {target φ ψ : Formula}
    (h : Formula.untl φ ψ ∈ SubformulaClosure target) :
    φ ∈ SubformulaClosure target ∧ ψ ∈ SubformulaClosure target := by
  rcases SubformulaClosure_mem_cases h with h_base | ⟨g, _, hg_eq⟩
  · rcases ghEnrichment_mem_cases h_base with h_sub | ⟨f, _, hfeq⟩ | ⟨f, _, hfeq⟩
    · obtain ⟨l, r⟩ := subformulas_untl_unwrap h_sub
      exact ⟨subformula_mem l, subformula_mem r⟩
    · cases hfeq -- (φ U ψ) = G(f) impossible
    · cases hfeq -- (φ U ψ) = H(f) impossible
  · simp [Formula.neg] at hg_eq -- (φ U ψ) = neg(g) impossible

end Bimodal.Metalogic.BXCanonical.Quasimodel
