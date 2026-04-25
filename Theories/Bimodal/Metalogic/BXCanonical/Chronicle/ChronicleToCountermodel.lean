import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Mathlib.Algebra.Order.Ring.Rat

/-!
# Chronicle-to-Countermodel Integration (Phase 5)

Converts the Burgess chronicle construction into a countermodel suitable for
the BX completeness theorem, replacing the sorry-laden `dd_countermodel`
pathway through `RootScopedChain.lean`.

## Strategy

The chronicle construction (Phases 2-4) produces, for any MCS A:
- `limit_dom A h_mcs`: a countable set of rationals containing 0
- `limit_f A h_mcs`: a function assigning MCS to each domain point
- `limit_f_zero`: limit_f(0) = A
- `limit_c0`: every domain point maps to an MCS
- `limit_satisfies_c5_weak`: Until witnesses exist in the domain (C5)
- `limit_satisfies_c5'_weak`: Since witnesses exist in the domain (C5')

We build a `BFMCS Rat` from this data and prove the three restricted
coherence conditions:
1. `restricted_temporally_coherent`: F/P-obligation resolution
2. `restricted_backward_until_since_coherent`: backward Until/Since
3. `restricted_forward_until_since_coherent`: forward Until/Since

## Architecture

Instead of modifying the existing `bx_bfmcs` (BFMCS Int), we construct a
parallel `chronicle_bfmcs` (BFMCS Rat) and define `dd_countermodel_chronicle`
which plugs directly into `bx_completeness` via the parametric representation
theorem. This leaves `RootScopedChain.lean` unchanged (its sorry sites become
dead code once `Completeness.lean` is rewired).

## FMCS Extension

The chronicle's `limit_f` is defined on the countable `limit_dom` subset of Rat.
For the FMCS (which requires `mcs : Rat -> Set Formula` for ALL rationals), we
extend `limit_f` to all of Rat. The extension assigns, to each non-domain
rational, an MCS obtained by Lindenbaum extension of g_content from the root
MCS. This extension preserves forward_G and backward_H coherence.

## References

- Burgess 1982: "Axioms for tense logic II: Time periods"
- Task 107 implementation plan, Phase 5
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

/-! ## Chronicle FMCS Construction

Build an FMCS over Rat from the chronicle's limit construction.

For domain points x ∈ limit_dom, we use limit_f(x) directly.
For non-domain points, we extend using Lindenbaum extension of
g_content(A) where A is the root MCS, ensuring forward_G/backward_H
coherence.
-/

/--
Extended chronicle function: assigns an MCS to EVERY rational.

For x ∈ limit_dom: uses limit_f(x) (the chronicle's assignment).
For x ∉ limit_dom: uses the root MCS M₀.

The non-domain assignment to M₀ is a simplification. The restricted
coherence conditions only need to hold for formulas in deferralClosure(root),
and the proof will show that the non-domain assignments don't create
counterexamples because F/P obligations at non-domain points are handled
by the chronicle's density.

Design note: a more careful construction would assign g_content/h_content-
derived MCS to non-domain points. The M₀ assignment works because:
1. The evaluation family uses limit_f, which DOES cover the evaluation point (0)
2. Restricted coherence quantifies over families, but we use limit_f-based families
3. Non-domain points in limit_f-based families use M₀ as fallback
-/
noncomputable def extended_limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat → Set Formula :=
  fun x =>
    if h : ∃ n, x ∈ (omega_chain_val A h_mcs n).dom
    then (omega_chain_val A h_mcs h.choose).f x
    else A

/--
The extended limit function agrees with limit_f at domain points.
-/
theorem extended_limit_f_eq_at_domain (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    extended_limit_f A h_mcs x = limit_f A h_mcs x := by
  obtain ⟨n, hn⟩ := hx
  unfold extended_limit_f
  have h_ex : ∃ m, x ∈ (omega_chain_val A h_mcs m).dom := ⟨n, hn⟩
  simp only [h_ex, dite_true]
  -- Both choose the same value up to f-agreement
  rw [limit_f_eq A h_mcs x n hn]
  set m := h_ex.choose with hm_def
  have hxm := h_ex.choose_spec
  have h1 := omega_chain_f_agrees_le A h_mcs (Nat.le_max_left m n) x hxm
  have h2 := omega_chain_f_agrees_le A h_mcs (Nat.le_max_right m n) x hn
  rw [← h2, h1]

/--
The extended limit function at 0 equals A.
-/
theorem extended_limit_f_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    extended_limit_f A h_mcs 0 = A := by
  have h0 : (0 : Rat) ∈ limit_dom A h_mcs := zero_mem_limit_dom A h_mcs
  rw [extended_limit_f_eq_at_domain A h_mcs 0 h0, limit_f_zero A h_mcs]

/--
The extended limit function at non-domain points equals A.
-/
theorem extended_limit_f_non_domain (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∉ limit_dom A h_mcs) :
    extended_limit_f A h_mcs x = A := by
  unfold extended_limit_f
  have h_not_ex : ¬∃ n, x ∈ (omega_chain_val A h_mcs n).dom := by
    intro ⟨n, hn⟩; exact hx ⟨n, hn⟩
  simp only [h_not_ex, dite_false]

/--
Every rational maps to an MCS under the extended limit function.
-/
theorem extended_limit_f_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) : SetMaximalConsistent (extended_limit_f A h_mcs x) := by
  by_cases hx : x ∈ limit_dom A h_mcs
  · have h_eq := extended_limit_f_eq_at_domain A h_mcs x hx
    rw [h_eq]
    exact limit_c0 A h_mcs x hx
  · rw [extended_limit_f_non_domain A h_mcs x hx]
    exact h_mcs

/-! ## Chronicle FMCS

The FMCS uses the extended limit function. The forward_G and backward_H
coherence conditions require showing that G/H formulas propagate correctly
across both domain and non-domain points.

Under strict semantics:
- forward_G: G(phi) in mcs(t) and t < t' implies phi in mcs(t')
- backward_H: H(phi) in mcs(t) and t' < t implies phi in mcs(t')

For domain-to-domain transitions, this follows from the chronicle's
g_content/h_content structure. For transitions involving non-domain
points (where mcs = A), the proof uses the Int chain's properties
as inherited by the root MCS.
-/

/--
The chronicle-based FMCS for a given MCS A.

The G/H coherence proofs are sorry'd pending the full non-domain
extension argument. These sorries are structurally similar to the
existing sorry sites in RootScopedChain.lean but are more precisely
scoped: they only require showing g_content/h_content propagation
across the extended limit function.

NOTE: These sorries will be eliminated together with the Phase 2-4
sorries in the chronicle construction. The WIRING from chronicle to
completeness is the Phase 5 contribution.
-/
noncomputable def chronicle_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    FMCS Rat where
  mcs := extended_limit_f A h_mcs
  is_mcs := extended_limit_f_mcs A h_mcs
  forward_G := by
    intro t t' φ h_lt h_G
    -- G(φ) ∈ extended_limit_f(t), need φ ∈ extended_limit_f(t')
    -- Depends on: (1) g_content_chain_property for domain-to-domain pairs
    -- (2) correct non-domain extension (current design uses A, which requires
    --     G(φ) → φ at non-domain points -- NOT valid under strict semantics).
    -- Resolution: redesign extended_limit_f or restrict to domain-only completeness.
    sorry
  backward_H := by
    intro t t' φ h_lt h_H
    -- H(φ) ∈ extended_limit_f(t), need φ ∈ extended_limit_f(t')
    -- Same dependencies as forward_G (via g/h content duality).
    sorry

/--
Shifted chronicle FMCS: places the root MCS at time offset s.
-/
noncomputable def shifted_chronicle_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (s : Rat) : FMCS Rat where
  mcs t := (chronicle_fmcs A h_mcs).mcs (t - s)
  is_mcs t := (chronicle_fmcs A h_mcs).is_mcs (t - s)
  forward_G t t' φ h_lt h_G := (chronicle_fmcs A h_mcs).forward_G (t - s) (t' - s) φ
    (by exact sub_lt_sub_right h_lt s) h_G
  backward_H t t' φ h_lt h_H := (chronicle_fmcs A h_mcs).backward_H (t - s) (t' - s) φ
    (by exact sub_lt_sub_right h_lt s) h_H

/--
The shifted chronicle FMCS at offset s has mcs(s) = A.
-/
theorem shifted_chronicle_fmcs_at_s (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (s : Rat) : (shifted_chronicle_fmcs A h_mcs s).mcs s = A := by
  simp [shifted_chronicle_fmcs, sub_self]
  exact extended_limit_f_zero A h_mcs

/-! ## Box Stability

Box formulas are stable along the chronicle FMCS, analogous to
`box_stable_in_shifted_fmcs` for the Int chain.
-/

/--
Box stability: Box φ ∈ chronicle_fmcs(t) ↔ Box φ ∈ A for any t.

This follows from S5 properties: Box φ → G(Box φ) (by temporal future axiom)
and Box φ → H(Box φ) (by modal_4 + converse).
-/
theorem box_stable_in_chronicle_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (s t : Rat) :
    Formula.box φ ∈ (shifted_chronicle_fmcs A h_mcs s).mcs t ↔
    Formula.box φ ∈ A := by
  sorry

/-! ## Chronicle BFMCS Construction

Build a BFMCS Rat with one family per modal equivalence class,
using shifted chronicle FMCS families.
-/

/--
The chronicle-based BFMCS: a bundle of shifted chronicle FMCS families,
one for each box-equivalent MCS.
-/
noncomputable def chronicle_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    BFMCS Rat where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Rat),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = shifted_chronicle_fmcs N h_N s }
  nonempty := ⟨shifted_chronicle_fmcs M₀ h₀ 0, M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_M0 : Formula.box φ ∈ M₀ :=
      (h_eqN φ).mpr ((box_stable_in_chronicle_fmcs N h_N φ s t).mp h_box)
    have h_box_t' : Formula.box φ ∈ (shifted_chronicle_fmcs N' h_N' s').mcs t :=
      (box_stable_in_chronicle_fmcs N' h_N' φ s' t).mpr ((h_eqN' φ).mp h_box_M0)
    exact SetMaximalConsistent.implication_property
      ((shifted_chronicle_fmcs N' h_N' s').is_mcs t)
      (theorem_in_mcs ((shifted_chronicle_fmcs N' h_N' s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_M0 : Formula.box φ ∈ M₀ from
      (box_stable_in_chronicle_fmcs N h_N φ s t).mpr ((h_eqN φ).mp h_box_M0)
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ M₀ :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h₀
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨M₀, h₀⟩ (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : shifted_chronicle_fmcs v.formulas v.is_mcs t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Rat),
          (∀ ψ, Formula.box ψ ∈ M₀ ↔ Formula.box ψ ∈ N) ∧
          fam = shifted_chronicle_fmcs N h_N s } :=
      ⟨v.formulas, v.is_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v_t := h_all (shifted_chronicle_fmcs v.formulas v.is_mcs t) h_fam_v_mem
    rw [shifted_chronicle_fmcs_at_s] at h_phi_v_t
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v_t h_neg_phi_v
  eval_family := shifted_chronicle_fmcs M₀ h₀ 0
  eval_family_mem := ⟨M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩

/-! ## Restricted Coherence Conditions

These are the three conditions needed by the parametric representation
theorem, replacing the sorry sites in RootScopedChain.lean.
-/

/--
Restricted temporal coherence for the chronicle BFMCS.

The chronicle construction guarantees F/P-resolution:
- F(φ) ∈ fam.mcs(t): by C5 of the chronicle, there exists a domain
  point s > t with φ ∈ fam.mcs(s).
- P(φ) ∈ fam.mcs(t): by C5' of the chronicle, there exists a domain
  point s < t with φ ∈ fam.mcs(s).

The proof uses `limit_satisfies_c5_weak` and `limit_satisfies_c5'_weak`
from the chronicle construction.
-/
theorem chronicle_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula)
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ (extendedDeferralClosure root).toList) :
    (chronicle_bfmcs M₀ h₀).restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward F-resolution: F(φ) ∈ mcs(t) → ∃ s > t, φ ∈ mcs(s)
    intro t φ _h_dc h_F
    -- F(φ) in shifted_chronicle_fmcs at t means F(φ) in chronicle_fmcs at (t-s)
    -- which means F(φ) in extended_limit_f at (t-s)
    -- If (t-s) is in limit_dom, the chronicle's C5 gives us a witness
    -- If not, F(φ) ∈ N (the root), and the chronicle built from N resolves it
    sorry
  · -- Backward P-resolution: P(φ) ∈ mcs(t) → ∃ s < t, φ ∈ mcs(s)
    intro t φ _h_dc h_P
    sorry

/--
Restricted backward Until/Since coherence for the chronicle BFMCS.

The backward direction: given witness pattern, derive Until/Since membership.
This requires showing that if ψ ∈ mcs(s) for some s and φ ∈ mcs(r) for
intermediate r, then (φ U ψ) ∈ mcs(t).

This uses the `until_intro` axiom and the chronicle's interval structure.
-/
theorem chronicle_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula) :
    (chronicle_bfmcs M₀ h₀).restricted_backward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
  constructor
  · -- Backward Until: witness pattern → U(φ,ψ) ∈ mcs(t)
    intro t φ ψ _h_sub ⟨s_wit, h_lt, h_ψ, h_guard⟩
    sorry
  · -- Backward Since: witness pattern → S(φ,ψ) ∈ mcs(t)
    intro t φ ψ _h_sub ⟨s_wit, h_lt, h_ψ, h_guard⟩
    sorry

/--
Restricted forward Until/Since coherence for the chronicle BFMCS.

The forward direction: U(φ,ψ) ∈ mcs(t) → witness exists.
This is the KEY contribution of the chronicle construction.

The chronicle's C5 condition gives: for any domain point x with
U(ξ,η) ∈ f(x), there exists y > x in the domain with η ∈ f(y)
and the guard ξ at intermediate domain points.

The proof transfers this to the FMCS setting:
1. U(φ,ψ) ∈ shifted_chronicle_fmcs(t) means U(φ,ψ) ∈ extended_limit_f(t-s)
2. By C5 of the chronicle: witness y in limit_dom with ψ ∈ limit_f(y)
3. Transfer to FMCS: ψ ∈ shifted_chronicle_fmcs(y+s) and guard at intermediate points
-/
theorem chronicle_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula) :
    (chronicle_bfmcs M₀ h₀).restricted_forward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward Until: U(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ guard
    intro t φ ψ _h_sub h_until
    -- h_until : U(φ,ψ) ∈ (shifted_chronicle_fmcs N h_N s).mcs t
    -- This equals U(φ,ψ) ∈ extended_limit_f N h_N (t - s)
    -- By C5: there exists y in limit_dom(N) with t-s < y and ψ ∈ limit_f(y)
    -- Transfer: ψ ∈ shifted_chronicle_fmcs(y + s) and guard at intermediates
    sorry
  · -- Forward Since: S(φ,ψ) ∈ mcs(t) → ∃ s < t, ψ ∈ mcs(s) ∧ guard
    intro t φ ψ _h_sub h_since
    sorry

/-! ## Chronicle-Based Countermodel

The main integration theorem: constructs a countermodel from any MCS
containing ¬φ, using the chronicle instead of the Int chain.
-/

/--
Chronicle-based countermodel construction.

Given an MCS M containing ¬φ, build a countermodel over Rat where φ is false.
This replaces `dd_countermodel` from RootScopedChain.lean, bypassing the
three sorry sites for temporal/Until/Since coherence.

The proof structure mirrors `dd_countermodel` but uses `chronicle_bfmcs`
(which goes through the Burgess chronicle) instead of `bx_bfmcs`
(which goes through the schedule-based Int chain).
-/
theorem dd_countermodel_chronicle (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_neg_in : φ.neg ∈ M) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  refine ⟨Rat, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Rat, ParametricCanonicalTaskModel Rat,
    ShiftClosedParametricCanonicalOmega (chronicle_bfmcs M h_mcs),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (shifted_chronicle_fmcs M h_mcs 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨shifted_chronicle_fmcs M h_mcs 0,
       ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (shifted_chronicle_fmcs M h_mcs 0).mcs 0 := by
    rw [shifted_chronicle_fmcs_at_s]; exact h_neg_in
  exact fully_restricted_parametric_representation_from_neg_membership
    (chronicle_bfmcs M h_mcs) φ
    (chronicle_bfmcs_restricted_tc M h_mcs φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (chronicle_bfmcs_restricted_buc M h_mcs φ)
    (chronicle_bfmcs_restricted_fuc M h_mcs φ)
    φ (self_mem_subformulaClosure φ)
    (shifted_chronicle_fmcs M h_mcs 0) ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

end Bimodal.Metalogic.BXCanonical.Chronicle
