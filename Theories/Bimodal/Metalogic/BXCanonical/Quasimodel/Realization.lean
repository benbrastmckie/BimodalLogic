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

- `until_eventuality_resolution`: Until eventuality resolution (partial — 2 sorries)
- `until_backward`: Until backward direction (partial — 1 sorry)
- `since_eventuality_resolution`: Since eventuality resolution (partial — 2 sorries)
- `since_backward`: Since backward direction (partial — 1 sorry)

## Mathematical Analysis

All 6 remaining sorries share the same root cause: the canonical ordering `bx_le`
(defined as `g_content ⊆`) is a preorder but NOT a total order, and the guard
proofs require propagating non-G formulas across `bx_le`.

### Root cause: bx_le non-totality

`bx_le w v` means `g_content(w) ⊆ v.formulas`, i.e., `∀ φ, G(φ) ∈ w → φ ∈ v`.
This is reflexive (BX1) and transitive (temp_4), but NOT total:
two MCSs w, v can have G(p) ∈ w, p ∉ v AND G(q) ∈ v, q ∉ w simultaneously
(where p, q are distinct atoms). BX11 (temporal linearity) constrains
F-witnesses to be ordered but does not force g_content inclusion to be total.

### Why the guard proofs fail

For `until_eventuality_resolution`, the guard requires: for any u with
`bx_le w u` and `bx_lt u v`, show `φ ∈ u`. The proof obtains a backward
witness u' ≤ u with `(φ U ψ) ∈ u'` and `φ ∈ u'` (from BX9). But
`φ ∈ u'` does not lift to `φ ∈ u` because `bx_le u' u` only propagates
G-content, not arbitrary formulas.

For `until_backward`, the contradiction approach obtains u with `bx_le u v`
and `¬(φ U ψ) ∈ u`, but needs `bx_le w u` to apply the guard. The enriched
seed `{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)` IS consistent (proved below)
and yields u with both `bx_le w u` and `bx_le u v`, but the final contradiction
still requires Until-monotonicity or case analysis on `bx_le v u`.

### What would close these sorries

One of:
1. **Until-induction axiom**: `(ψ ∨ (φ ∧ X(θ)) → θ) → (φ U ψ → θ)`.
   This was removed from BX during the refactoring (BX5-BX7 were added instead).
2. **Until goal-weakening**: `(φ U (φ ∧ ψ)) → (φ U ψ)`.
   This appears NOT derivable from BX1-BX12.
3. **Restructured canonical model**: Define `bx_le` differently (e.g., using
   Until-witness ordering) so that totality is guaranteed.
4. **Quasimodel filtration**: Work in a finite quotient model where the ordering
   IS total by construction, then lift back to the canonical model.

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

/-! ## Until Eventuality Resolution

The main theorem for the forward Until direction. Given φ U ψ ∈ w with ψ ∉ w,
we construct v ≥ w with ψ ∈ v and φ on the strict interval [w, v).

The proof proceeds in two stages:
1. Get a raw witness v with bx_le w v and ψ ∈ v (from bx_forward_witness + BX10)
2. Prove the guard property using BX axioms

Stage 2 has a gap: for u in the strict interval, we can derive P(φ U ψ) ∈ u
(from BX4 + bx_G_forward), giving a backward witness u' with φ U ψ ∈ u' and
φ ∈ u' (BX9). But φ ∈ u' does not lift to φ ∈ u because bx_le u' u only
propagates G-content, not arbitrary formulas. -/

noncomputable def until_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas := by
  -- Stage 1: Get raw witness
  have h_F : Formula.some_future ψ ∈ w.formulas := until_F_mcs h_until
  obtain ⟨v, h_wv, h_ψv⟩ := bx_forward_witness w ψ h_F
  -- Stage 2: Guard property
  have h_phi_w : φ ∈ w.formulas := by
    rcases until_elim_mcs h_until with h | h
    · exact h
    · exact absurd h h_not_psi
  have h_accum : Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ ∈ w.formulas :=
    self_accum_mcs h_until
  have h_connect : Formula.all_future (Formula.some_past (Formula.untl φ ψ)) ∈ w.formulas :=
    connect_future_mcs h_until
  refine ⟨v, h_wv, h_ψv, fun u h_wu h_uv => ?_⟩
  -- P(φ U ψ) ∈ u (from G(P(φ U ψ)) ∈ w and bx_le w u)
  have h_P_until_u : Formula.some_past (Formula.untl φ ψ) ∈ u.formulas :=
    bx_G_forward h_wu h_connect
  -- ∃ u' ≤ u with φ U ψ ∈ u'
  obtain ⟨u', h_u'u, h_until_u'⟩ := bx_backward_witness u (Formula.untl φ ψ) h_P_until_u
  rcases until_elim_mcs h_until_u' with h_phi_u' | h_psi_u'
  · -- φ ∈ u': need to lift to φ ∈ u via bx_le u' u
    -- GAP: bx_le u' u only propagates G-content.
    -- φ ∈ u' does NOT imply G(φ) ∈ u', so φ ∈ u is not derivable.
    -- Closing this requires Until-monotonicity or bx_le totality.
    sorry
  · -- ψ ∈ u': similarly need φ ∈ u
    -- Even though ψ ∈ u' and bx_le u' u, we can't derive φ ∈ u.
    -- Having ψ at a backward point doesn't help with the guard at u.
    sorry

/-! ## Until Backward Direction

Given bx_le w v, ψ ∈ v, guard φ on [w,v), and ψ ∉ w, derive φ U ψ ∈ w.

The proof uses contradiction: assume ¬(φ U ψ) ∈ w, then constructs a
witness u using the enriched seed {¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v).
This seed is provably consistent (enriched_seed_consistent_until above),
giving u with bx_le w u AND bx_le u v AND ¬(φ U ψ) ∈ u.

The remaining gap: showing bx_le v u is false (so the guard applies)
or deriving a contradiction from φ ∈ u and ¬(φ U ψ) ∈ u. -/

noncomputable def until_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas := by
  by_contra h_not_until
  have h_neg_until : (Formula.untl φ ψ).neg ∈ w.formulas := by
    rcases SetMaximalConsistent.negation_complete w.is_mcs (Formula.untl φ ψ) with h | h
    · exact absurd h h_not_until
    · exact h
  -- Enriched seed is consistent
  have h_seed_cons := enriched_seed_consistent_until w v φ ψ h_neg_until h_wv h_ψv
  -- Extend to MCS
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
  -- Construct BXPoint u from M
  let u : BXPoint := ⟨M, hM_mcs⟩
  -- ¬(φ U ψ) ∈ u
  have h_neg_until_u : (Formula.untl φ ψ).neg ∈ u.formulas :=
    hM_sup (Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_singleton _)))
  -- bx_le w u: g_content(w) ⊆ u
  have h_wu : bx_le w u := by
    intro χ hχ
    exact hM_sup (Set.mem_union_left _ (Set.mem_union_right _ hχ))
  -- bx_le u v: from h_content(v) ⊆ u, via h_content_subset_implies_g_content_reverse
  have h_hv_sub : h_content v.formulas ⊆ u.formulas := by
    intro χ hχ
    exact hM_sup (Set.mem_union_right _ hχ)
  have h_uv : bx_le u v :=
    h_content_subset_implies_g_content_reverse v.formulas M v.is_mcs hM_mcs h_hv_sub
  -- Now we have bx_le w u and bx_le u v.
  -- The guard applies if ¬bx_le v u.
  -- GAP: We cannot currently show ¬bx_le v u or derive a contradiction directly.
  -- If ¬bx_le v u: guard gives φ ∈ u, but φ ∈ u ∧ ¬(φ U ψ) ∈ u is consistent
  -- (φ can hold while φ U ψ fails if ψ never arrives).
  -- We have F(ψ) ∈ u (from F_from_above + bx_le u v + ψ ∈ v... wait, we need
  -- bx_le from u to something with ψ. We have bx_le u v and ψ ∈ v.)
  -- F(ψ) ∈ w from F_from_above h_wv h_ψv. But does F(ψ) ∈ u?
  -- From BX4 on F(ψ) ∈ w: G(P(F(ψ))) ∈ w. bx_le w u: P(F(ψ)) ∈ u.
  -- P(F(ψ)) ∈ u gives a backward F(ψ)-witness, not F(ψ) at u directly.
  -- Alternatively: from bx_le u v and ψ ∈ v, by F_from_above: F(ψ) ∈ u? No,
  -- F_from_above needs bx_le u v and gives F(ψ) ∈ u? Let me check.
  -- bx_le u v and ψ ∈ v: BX4' on ψ: H(F(ψ)) ∈ v. bx_H_forward with bx_le u v: F(ψ) ∈ u. Yes!
  -- So F(ψ) ∈ u. Then BX12: ⊤ U ψ ∈ u. BX7 analysis shows case 3 gives
  -- φ U (φ ∧ (φ U ψ)) which via BX6 gives φ U ψ, contradicting ¬(φ U ψ) ∈ u.
  -- But the BX7 disjunction is not guaranteed to land on case 3.
  sorry

/-! ## Since Eventuality Resolution -/

noncomputable def since_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas := by
  -- Mirror of Until using BX5', BX9', BX10', BX4', bx_backward_witness
  have h_P : Formula.some_past ψ ∈ w.formulas := since_P_mcs h_since
  obtain ⟨v, h_vw, h_ψv⟩ := bx_backward_witness w ψ h_P
  have h_phi_w : φ ∈ w.formulas := by
    rcases since_elim_mcs h_since with h | h
    · exact h
    · exact absurd h h_not_psi
  have _h_accum := self_accum_since_mcs h_since
  have h_connect := connect_past_mcs h_since
  refine ⟨v, h_vw, h_ψv, fun u h_vu h_uw => ?_⟩
  -- F(φ S ψ) ∈ u (from H(F(φ S ψ)) ∈ w and bx_le u w)
  have h_F_since_u : Formula.some_future (Formula.snce φ ψ) ∈ u.formulas :=
    bx_H_forward h_uw h_connect
  obtain ⟨u', h_uu', h_since_u'⟩ := bx_forward_witness u (Formula.snce φ ψ) h_F_since_u
  rcases since_elim_mcs h_since_u' with h_phi_u' | h_psi_u'
  · -- φ ∈ u': same guard-lifting gap as Until
    sorry
  · -- ψ ∈ u': same gap
    sorry

noncomputable def since_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le v u ∧ ¬bx_le u v → bx_le u w → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas := by
  by_contra h_not_since
  have h_neg_since : (Formula.snce φ ψ).neg ∈ w.formulas := by
    rcases SetMaximalConsistent.negation_complete w.is_mcs (Formula.snce φ ψ) with h | h
    · exact absurd h h_not_since
    · exact h
  -- Enriched seed for Since direction
  have h_seed_cons := enriched_seed_consistent_since w v φ ψ h_neg_since h_vw h_ψv
  obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum _ h_seed_cons
  let u : BXPoint := ⟨M, hM_mcs⟩
  have h_neg_since_u : (Formula.snce φ ψ).neg ∈ u.formulas :=
    hM_sup (Set.mem_union_left _ (Set.mem_union_left _ (Set.mem_singleton _)))
  -- bx_le u w: from h_content(w) ⊆ u, via h_content_subset_implies_g_content_reverse
  have h_hw_sub : h_content w.formulas ⊆ u.formulas := by
    intro χ hχ
    exact hM_sup (Set.mem_union_left _ (Set.mem_union_right _ hχ))
  have h_uw : bx_le u w :=
    h_content_subset_implies_g_content_reverse w.formulas M w.is_mcs hM_mcs h_hw_sub
  -- bx_le v u: from g_content(v) ⊆ u
  have h_vu : bx_le v u := by
    intro χ hχ
    exact hM_sup (Set.mem_union_right _ hχ)
  -- Same gap as until_backward: need ¬bx_le u v or alternative contradiction path
  sorry

end Bimodal.Metalogic.BXCanonical.Quasimodel
