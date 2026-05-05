import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Data.Rat.Encodable

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

We construct `cantor_bfmcs` (BFMCS Rat) using a Cantor isomorphism to embed
the limit domain into all of Rat, and define `dd_countermodel_chronicle` which
plugs directly into `bx_completeness` via the parametric representation theorem.
The legacy `chronicle_bfmcs` pathway (using extended_limit_f) has been deleted
as dead code (task 107).

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

/-! ## Limit Domain Subtype and Typeclass Instances

The subtype `{q : Rat // q ∈ limit_dom A h_mcs}` inherits `LinearOrder` from `Rat`.
We prove the five typeclass prerequisites for `Order.iso_of_countable_dense`:
`Countable`, `DenselyOrdered`, `NoMinOrder`, `NoMaxOrder`, `Nonempty`.
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
`LimitDomSubtype` is densely ordered: from the sorry-free `limit_dom_dense`.
-/
instance limitDomSubtype_denselyOrdered (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    DenselyOrdered (LimitDomSubtype A h_mcs) where
  dense := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ hab
    obtain ⟨z, hz, haz, hzb⟩ := limit_dom_dense A h_mcs a b ha hb hab
    exact ⟨⟨z, hz⟩, haz, hzb⟩

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

/-! ## Cantor Isomorphism

By `Order.iso_of_countable_dense`, the subtype `LimitDomSubtype` (which is
Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty) is order-isomorphic
to `Rat`. We extract a concrete `OrderIso` via `Classical.choice`.

This iso makes EVERY rational a domain point: `cantor_f(q) = limit_f(iso.symm(q).val)`.
The non-domain extension problem disappears entirely.
-/

/--
The Cantor order isomorphism: `LimitDomSubtype ≃o Rat`.
Exists by `Order.iso_of_countable_dense` since both types are countable,
densely ordered, unbounded linear orders.
-/
noncomputable def cantor_iso (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    LimitDomSubtype A h_mcs ≃o Rat :=
  Classical.choice (Order.iso_of_countable_dense (LimitDomSubtype A h_mcs) Rat)

/--
The Cantor-based MCS assignment: every rational maps to an MCS via the
inverse of the Cantor isomorphism composed with `limit_f`.

`cantor_f(q) = limit_f(cantor_iso.symm(q).val)`

Since `cantor_iso.symm(q)` is a subtype element of `limit_dom`, its `.val`
is always in `limit_dom`, so `limit_f` is well-defined at that point.
-/
noncomputable def cantor_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    Rat → Set Formula :=
  fun q => limit_f A h_mcs ((cantor_iso A h_mcs).symm q).val

/--
The Cantor zero point: the rational corresponding to 0 in the limit domain.
-/
noncomputable def cantor_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    : Rat :=
  (cantor_iso A h_mcs) ⟨0, zero_mem_limit_dom A h_mcs⟩

/--
`cantor_f` at `cantor_zero` equals A (the root MCS).
-/
theorem cantor_f_at_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    cantor_f A h_mcs (cantor_zero A h_mcs) = A := by
  unfold cantor_f cantor_zero
  simp [OrderIso.symm_apply_apply]
  exact limit_f_zero A h_mcs

/--
Every rational maps to an MCS under `cantor_f`.
-/
theorem cantor_f_is_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (q : Rat) : SetMaximalConsistent (cantor_f A h_mcs q) := by
  unfold cantor_f
  exact limit_c0 A h_mcs _ ((cantor_iso A h_mcs).symm q).property

/--
The Cantor-based FMCS: an FMCS over Rat where every rational is a domain point.

- `forward_G`: `G(phi) in cantor_f(t)` and `t < t'` implies `phi in cantor_f(t')`.
  Since `cantor_iso.symm` is strictly monotone, `t < t'` gives
  `cantor_iso.symm(t) < cantor_iso.symm(t')`, and both are in `limit_dom`.
  Then `limit_forward_G` applies directly.

- `backward_H`: symmetric argument using `limit_backward_H`.
-/
noncomputable def cantor_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    FMCS Rat where
  mcs := cantor_f A h_mcs
  is_mcs := cantor_f_is_mcs A h_mcs
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt_dom := (cantor_iso A h_mcs).symm.strictMono h_lt
    exact limit_forward_G A h_mcs
      ((cantor_iso A h_mcs).symm t).val
      ((cantor_iso A h_mcs).symm t').val
      ((cantor_iso A h_mcs).symm t).property
      ((cantor_iso A h_mcs).symm t').property
      h_lt_dom φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt_dom := (cantor_iso A h_mcs).symm.strictMono h_lt
    exact limit_backward_H A h_mcs
      ((cantor_iso A h_mcs).symm t).val
      ((cantor_iso A h_mcs).symm t').val
      ((cantor_iso A h_mcs).symm t).property
      ((cantor_iso A h_mcs).symm t').property
      h_lt_dom φ h_H

/-! ## Shifted Cantor FMCS

The shifted version places the root MCS at an arbitrary time offset s,
using `cantor_zero` to compute where 0 maps in the Cantor isomorphism.
-/

/--
Shifted cantor FMCS: places the root MCS at time offset s.
The time translation uses `cantor_zero` to find where the chronicle's
origin (0 in limit_dom) maps in the Cantor domain.
-/
noncomputable def shifted_cantor_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (s : Rat) : FMCS Rat where
  mcs t := (cantor_fmcs A h_mcs).mcs (t - s)
  is_mcs t := (cantor_fmcs A h_mcs).is_mcs (t - s)
  forward_G t t' φ h_lt h_G := (cantor_fmcs A h_mcs).forward_G (t - s) (t' - s) φ
    (by exact sub_lt_sub_right h_lt s) h_G
  backward_H t t' φ h_lt h_H := (cantor_fmcs A h_mcs).backward_H (t - s) (t' - s) φ
    (by exact sub_lt_sub_right h_lt s) h_H

/--
The shifted cantor FMCS at offset s has mcs(s) = cantor_f(0).
Since cantor_f(0) = limit_f(cantor_iso.symm(0).val), which is NOT necessarily A
(the root MCS lives at cantor_zero, not 0).

For the root to be at time s, we shift by `s - cantor_zero` so that
`mcs(s) = cantor_f(s - (s - cantor_zero)) = cantor_f(cantor_zero) = A`.
-/
theorem shifted_cantor_fmcs_at_root (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (s : Rat) :
    (shifted_cantor_fmcs A h_mcs (s - cantor_zero A h_mcs)).mcs s = A := by
  simp [shifted_cantor_fmcs, sub_sub_cancel]
  exact cantor_f_at_zero A h_mcs

/--
Convenience: shifted_cantor_fmcs with the correct offset to place root at s.
This is `shifted_cantor_fmcs A h_mcs (s - cantor_zero A h_mcs)`.
-/
noncomputable def rooted_cantor_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (s : Rat) : FMCS Rat :=
  shifted_cantor_fmcs A h_mcs (s - cantor_zero A h_mcs)

/--
The rooted cantor FMCS at s has mcs(s) = A.
-/
theorem rooted_cantor_fmcs_at_s (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (s : Rat) : (rooted_cantor_fmcs A h_mcs s).mcs s = A :=
  shifted_cantor_fmcs_at_root A h_mcs s

/-! ## Box Stability (Cantor-based)

Box formulas are stable along the cantor FMCS: Box φ ∈ cantor_fmcs(t) iff Box φ ∈ A.
This is sorry-free because cantor_fmcs.forward_G and backward_H are sorry-free.
-/

/--
Box stability for rooted_cantor_fmcs: Box φ ∈ rooted_cantor_fmcs(t) ↔ Box φ ∈ A.
-/
theorem box_stable_in_rooted_cantor_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (s t : Rat) :
    Formula.box φ ∈ (rooted_cantor_fmcs A h_mcs s).mcs t ↔
    Formula.box φ ∈ A := by
  -- rooted_cantor_fmcs.mcs t = cantor_fmcs.mcs (t - (s - cantor_zero))
  -- cantor_fmcs.mcs q = cantor_f q = limit_f(iso.symm(q).val) for all q
  -- At cantor_zero: cantor_f(cantor_zero) = A
  have h_at_root : (cantor_fmcs A h_mcs).mcs (cantor_zero A h_mcs) = A :=
    cantor_f_at_zero A h_mcs
  have box_to_A : ∀ q, Formula.box φ ∈ (cantor_fmcs A h_mcs).mcs q → Formula.box φ ∈ A := by
    intro q h_box
    have h_mcs_q := (cantor_fmcs A h_mcs).is_mcs q
    have h_bb := SetMaximalConsistent.implication_property h_mcs_q
      (theorem_in_mcs h_mcs_q (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box
    rcases lt_trichotomy q (cantor_zero A h_mcs) with hq | rfl | hq
    · have h_G := SetMaximalConsistent.implication_property h_mcs_q
        (theorem_in_mcs h_mcs_q (Bimodal.Theorems.Perpetuity.box_to_future (Formula.box φ))) h_bb
      have := (cantor_fmcs A h_mcs).forward_G q (cantor_zero A h_mcs) (Formula.box φ) hq h_G
      rwa [h_at_root] at this
    · rwa [h_at_root] at h_box
    · have h_H := SetMaximalConsistent.implication_property h_mcs_q
        (theorem_in_mcs h_mcs_q (Bimodal.Theorems.Perpetuity.box_to_past (Formula.box φ))) h_bb
      have := (cantor_fmcs A h_mcs).backward_H q (cantor_zero A h_mcs) (Formula.box φ) hq h_H
      rwa [h_at_root] at this
  have box_from_A : ∀ q, Formula.box φ ∈ A → Formula.box φ ∈ (cantor_fmcs A h_mcs).mcs q := by
    intro q h_box_A
    have h_box_cz : Formula.box φ ∈ (cantor_fmcs A h_mcs).mcs (cantor_zero A h_mcs) := by
      rw [h_at_root]; exact h_box_A
    have h_mcs_cz := (cantor_fmcs A h_mcs).is_mcs (cantor_zero A h_mcs)
    have h_bb := SetMaximalConsistent.implication_property h_mcs_cz
      (theorem_in_mcs h_mcs_cz (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_cz
    rcases lt_trichotomy q (cantor_zero A h_mcs) with hq | rfl | hq
    · have h_H := SetMaximalConsistent.implication_property h_mcs_cz
        (theorem_in_mcs h_mcs_cz (Bimodal.Theorems.Perpetuity.box_to_past (Formula.box φ))) h_bb
      exact (cantor_fmcs A h_mcs).backward_H (cantor_zero A h_mcs) q (Formula.box φ) hq h_H
    · exact h_box_cz
    · have h_G := SetMaximalConsistent.implication_property h_mcs_cz
        (theorem_in_mcs h_mcs_cz (Bimodal.Theorems.Perpetuity.box_to_future (Formula.box φ))) h_bb
      exact (cantor_fmcs A h_mcs).forward_G (cantor_zero A h_mcs) q (Formula.box φ) hq h_G
  exact ⟨box_to_A _, box_from_A _⟩

/-! ## Cantor-Based BFMCS Construction

Build a BFMCS Rat using rooted_cantor_fmcs families,
one for each box-equivalent MCS. This is sorry-free for forward_G/backward_H.
-/

/--
The cantor-based BFMCS: a bundle of rooted cantor FMCS families,
one for each box-equivalent MCS.
-/
noncomputable def cantor_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    :
    BFMCS Rat where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Rat),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = rooted_cantor_fmcs N h_N s }
  nonempty := ⟨rooted_cantor_fmcs M₀ h₀ 0, M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_M0 : Formula.box φ ∈ M₀ :=
      (h_eqN φ).mpr ((box_stable_in_rooted_cantor_fmcs N h_N φ s t).mp h_box)
    have h_box_t' : Formula.box φ ∈ (rooted_cantor_fmcs N' h_N' s').mcs t :=
      (box_stable_in_rooted_cantor_fmcs N' h_N' φ s' t).mpr ((h_eqN' φ).mp h_box_M0)
    exact SetMaximalConsistent.implication_property
      ((rooted_cantor_fmcs N' h_N' s').is_mcs t)
      (theorem_in_mcs ((rooted_cantor_fmcs N' h_N' s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_M0 : Formula.box φ ∈ M₀ from
      (box_stable_in_rooted_cantor_fmcs N h_N φ s t).mpr ((h_eqN φ).mp h_box_M0)
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ M₀ :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h₀
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨M₀, h₀⟩ (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : rooted_cantor_fmcs v.formulas v.is_mcs t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Rat),
          (∀ ψ, Formula.box ψ ∈ M₀ ↔ Formula.box ψ ∈ N) ∧
          fam = rooted_cantor_fmcs N h_N s } :=
      ⟨v.formulas, v.is_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v_t := h_all (rooted_cantor_fmcs v.formulas v.is_mcs t) h_fam_v_mem
    rw [rooted_cantor_fmcs_at_s] at h_phi_v_t
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v_t h_neg_phi_v
  eval_family := rooted_cantor_fmcs M₀ h₀ 0
  eval_family_mem := ⟨M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩

/-! ## Cantor-Based Restricted Coherence Conditions

These are the three conditions needed by the parametric representation
theorem, using cantor_bfmcs (sorry-free FMCS/BFMCS) instead of chronicle_bfmcs.
The temporal and Until/Since coherence still have sorry sites pending
the chronicle C5/C5' transfer through the Cantor isomorphism.
-/

/--
Restricted temporal coherence for the cantor BFMCS.

F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s) and symmetric for P.
The Cantor isomorphism makes all rationals domain points, so
limit_F_resolution/limit_P_resolution apply directly after transferring
through cantor_iso.symm.
-/
theorem cantor_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula)
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ (extendedDeferralClosure root).toList) :
    (cantor_bfmcs M₀ h₀).restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward F-resolution: F(φ) ∈ mcs(t) → ∃ s' > t, φ ∈ mcs(s')
    intro t φ _h_dc h_F
    -- h_F definitionally unfolds to F(φ) ∈ limit_f(cantor_iso.symm(t - offset).val)
    -- where offset = s - cantor_zero. Since cantor_iso.symm(q) is always in limit_dom,
    -- limit_F_resolution gives a witness y > iso.symm(q) with φ ∈ limit_f(y).
    -- Transfer back: cantor_iso(⟨y, hy⟩) + offset > t in the shifted FMCS.
    have h_F' : φ.some_future ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (t - (s - cantor_zero N h_N))).val := h_F
    have h_dom := ((cantor_iso N h_N).symm (t - (s - cantor_zero N h_N))).property
    obtain ⟨y, hy_dom, hy_gt, hy_phi⟩ := limit_F_resolution N h_N _ h_dom φ h_F'
    set offset := s - cantor_zero N h_N
    refine ⟨(cantor_iso N h_N) ⟨y, hy_dom⟩ + offset, ?_, ?_⟩
    · have h_lt : (cantor_iso N h_N).symm (t - offset) < ⟨y, hy_dom⟩ := hy_gt
      have := (cantor_iso N h_N).strictMono h_lt
      simp [OrderIso.apply_symm_apply] at this; linarith
    · show φ ∈ limit_f N h_N ((cantor_iso N h_N).symm
        ((cantor_iso N h_N) ⟨y, hy_dom⟩ + offset - (s - cantor_zero N h_N))).val
      have : (cantor_iso N h_N) ⟨y, hy_dom⟩ + offset - (s - cantor_zero N h_N) =
          (cantor_iso N h_N) ⟨y, hy_dom⟩ := by simp [offset]
      rw [this, OrderIso.symm_apply_apply]
      exact hy_phi
  · -- Backward P-resolution: mirror of forward case
    intro t φ _h_dc h_P
    have h_P' : φ.some_past ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (t - (s - cantor_zero N h_N))).val := h_P
    have h_dom := ((cantor_iso N h_N).symm (t - (s - cantor_zero N h_N))).property
    obtain ⟨y, hy_dom, hy_lt, hy_phi⟩ := limit_P_resolution N h_N _ h_dom φ h_P'
    set offset := s - cantor_zero N h_N
    refine ⟨(cantor_iso N h_N) ⟨y, hy_dom⟩ + offset, ?_, ?_⟩
    · have h_lt' : ⟨y, hy_dom⟩ < (cantor_iso N h_N).symm (t - offset) := hy_lt
      have := (cantor_iso N h_N).strictMono h_lt'
      simp [OrderIso.apply_symm_apply] at this; linarith
    · show φ ∈ limit_f N h_N ((cantor_iso N h_N).symm
        ((cantor_iso N h_N) ⟨y, hy_dom⟩ + offset - (s - cantor_zero N h_N))).val
      have : (cantor_iso N h_N) ⟨y, hy_dom⟩ + offset - (s - cantor_zero N h_N) =
          (cantor_iso N h_N) ⟨y, hy_dom⟩ := by simp [offset]
      rw [this, OrderIso.symm_apply_apply]
      exact hy_phi

/--
Restricted backward Until/Since coherence for the cantor BFMCS.

The backward direction: given the semantic Until/Since witness pattern
(endpoint + guard at intermediate points), derive syntactic Until/Since
membership. Proved by contradiction using C4/C4': if ¬U ∈ f(t), then
C4 finds an intermediate point where the guard fails, contradicting the
hypothesis.
-/
theorem cantor_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula) :
    (cantor_bfmcs M₀ h₀).restricted_backward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
  constructor
  · -- Backward Until: witness pattern → U(φ,ψ) ∈ mcs(t)
    -- By contradiction: if ¬U(φ,ψ) ∈ f(t) and ψ ∈ f(s_wit) with t < s_wit,
    -- then C4 gives z with t < z < s_wit and φ.neg ∈ f(z). But the guard
    -- says φ ∈ f(z) (since t < z < s_wit under open guard), contradiction.
    intro t φ ψ _h_sub ⟨s_wit, h_lt, h_ψ, h_guard⟩
    by_contra h_not
    set offset := s - cantor_zero N h_N
    have h_mcs_t := (rooted_cantor_fmcs N h_N s).is_mcs t
    have h_neg : (φ.untl ψ).neg ∈ (rooted_cantor_fmcs N h_N s).mcs t := by
      rcases SetMaximalConsistent.negation_complete h_mcs_t (φ.untl ψ) with h | h
      · exact absurd h h_not
      · exact h
    -- Transfer to limit_f coordinates
    have h_neg' : (φ.untl ψ).neg ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (t - offset)).val := h_neg
    have h_psi' : ψ ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (s_wit - offset)).val := h_ψ
    have h_dom_t := ((cantor_iso N h_N).symm (t - offset)).property
    have h_dom_s := ((cantor_iso N h_N).symm (s_wit - offset)).property
    have h_lt' : ((cantor_iso N h_N).symm (t - offset)).val <
        ((cantor_iso N h_N).symm (s_wit - offset)).val :=
      (cantor_iso N h_N).symm.strictMono (show t - offset < s_wit - offset by linarith)
    -- C4 gives guard violation
    obtain ⟨z, hz_dom, hz_gt, hz_lt, hz_neg⟩ :=
      limit_satisfies_c4 N h_N _ _ h_dom_t h_dom_s h_lt' φ ψ h_neg' h_psi'
    -- Transfer z back to rational coordinates
    set z_rat := (cantor_iso N h_N) ⟨z, hz_dom⟩ + offset
    have hz_rat_gt : t < z_rat := by
      have : (cantor_iso N h_N).symm (t - offset) < ⟨z, hz_dom⟩ := hz_gt
      have := (cantor_iso N h_N).strictMono this
      simp [OrderIso.apply_symm_apply] at this; linarith
    have hz_rat_lt : z_rat < s_wit := by
      have : ⟨z, hz_dom⟩ < (cantor_iso N h_N).symm (s_wit - offset) := hz_lt
      have := (cantor_iso N h_N).strictMono this
      simp [OrderIso.apply_symm_apply] at this; linarith
    -- Guard gives φ ∈ f(z_rat): open guard uses strict t < z_rat and z_rat < s_wit
    have h_phi_z := h_guard z_rat hz_rat_gt hz_rat_lt
    have h_phi_z' : φ ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (z_rat - offset)).val := h_phi_z
    have h_eq : ((cantor_iso N h_N).symm (z_rat - offset)).val = z := by
      simp [z_rat, add_sub_cancel_right, OrderIso.symm_apply_apply]
    rw [h_eq] at h_phi_z'
    exact set_consistent_not_both (limit_c0 N h_N z hz_dom).1 φ h_phi_z' hz_neg
  · -- Backward Since: witness pattern → S(φ,ψ) ∈ mcs(t)
    -- Mirror of Until case, using C4' instead of C4.
    intro t φ ψ _h_sub ⟨s_wit, h_lt, h_ψ, h_guard⟩
    by_contra h_not
    set offset := s - cantor_zero N h_N
    have h_mcs_t := (rooted_cantor_fmcs N h_N s).is_mcs t
    have h_neg : (φ.snce ψ).neg ∈ (rooted_cantor_fmcs N h_N s).mcs t := by
      rcases SetMaximalConsistent.negation_complete h_mcs_t (φ.snce ψ) with h | h
      · exact absurd h h_not
      · exact h
    -- Transfer to limit_f coordinates
    have h_neg' : (φ.snce ψ).neg ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (t - offset)).val := h_neg
    have h_psi' : ψ ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (s_wit - offset)).val := h_ψ
    have h_dom_t := ((cantor_iso N h_N).symm (t - offset)).property
    have h_dom_s := ((cantor_iso N h_N).symm (s_wit - offset)).property
    have h_lt' : ((cantor_iso N h_N).symm (s_wit - offset)).val <
        ((cantor_iso N h_N).symm (t - offset)).val :=
      (cantor_iso N h_N).symm.strictMono (show s_wit - offset < t - offset by linarith)
    -- C4' gives guard violation
    obtain ⟨z, hz_dom, hz_gt, hz_lt, hz_neg⟩ :=
      limit_satisfies_c4' N h_N _ _ h_dom_t h_dom_s h_lt' φ ψ h_neg' h_psi'
    -- Transfer z back to rational coordinates
    set z_rat := (cantor_iso N h_N) ⟨z, hz_dom⟩ + offset
    have hz_rat_gt : s_wit < z_rat := by
      have : (cantor_iso N h_N).symm (s_wit - offset) < ⟨z, hz_dom⟩ := hz_gt
      have := (cantor_iso N h_N).strictMono this
      simp [OrderIso.apply_symm_apply] at this; linarith
    have hz_rat_lt : z_rat < t := by
      have : ⟨z, hz_dom⟩ < (cantor_iso N h_N).symm (t - offset) := hz_lt
      have := (cantor_iso N h_N).strictMono this
      simp [OrderIso.apply_symm_apply] at this; linarith
    -- Guard gives φ ∈ f(z_rat): open guard uses strict s_wit < z_rat and z_rat < t
    have h_phi_z := h_guard z_rat hz_rat_gt hz_rat_lt
    have h_phi_z' : φ ∈ limit_f N h_N
        ((cantor_iso N h_N).symm (z_rat - offset)).val := h_phi_z
    have h_eq : ((cantor_iso N h_N).symm (z_rat - offset)).val = z := by
      simp [z_rat, add_sub_cancel_right, OrderIso.symm_apply_apply]
    rw [h_eq] at h_phi_z'
    exact set_consistent_not_both (limit_c0 N h_N z hz_dom).1 φ h_phi_z' hz_neg

/--
Restricted forward Until/Since coherence for the cantor BFMCS.

The forward direction: U(φ,ψ) ∈ f(t) → ∃ s > t, ψ ∈ f(s) ∧ ∀ r ∈ [t,s), φ ∈ f(r).

**Blocker**: Requires `limit_satisfies_c5_full` (C5 with guard), which in turn
requires either:
(a) The real interval function g (replacing the placeholder `limit_g`) with C3
    three-way property: g(x,z) ⊆ f(y) for x < y < z. Then C5 elimination
    guarantees ξ ∈ f(z) at intermediate z via g(x,y) ⊆ f(z).
(b) Strengthening `EliminationResult.c5_forward_witness` to include guard info
    (the guard IS checked in `eliminate_potential_counterexample` at line 728
    but discarded from the result type).

**Note**: The endpoint witness (∃ y > t, ψ ∈ f(y)) is available via
`limit_satisfies_c5_weak`. Only the guard at intermediate points is missing.
The backward direction (BUC) was proved using C4's contrapositive.
-/
theorem cantor_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (root : Formula) :
    (cantor_bfmcs M₀ h₀).restricted_forward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
  constructor
  · -- Forward Until: U(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ guard
    -- BLOCKER: Requires full C5 with guard (limit_satisfies_c5_full).
    -- C5_weak gives the endpoint ψ ∈ f(y), but the guard φ ∈ f(r) for
    -- intermediate r requires the real interval function g with C3.
    intro t φ ψ _h_sub h_until
    sorry
  · -- Forward Since: S(φ,ψ) ∈ mcs(t) → ∃ s < t, ψ ∈ mcs(s) ∧ guard
    -- BLOCKER: Mirror of forward Until, requires full C5' with guard.
    intro t φ ψ _h_sub h_since
    sorry

/-! ## Chronicle-Based Countermodel

The main integration theorem: constructs a countermodel from any MCS
containing ¬φ, using the Cantor-based chronicle construction.

This uses `cantor_bfmcs` (sorry-free FMCS/BFMCS). The forward_G/backward_H
coherence is sorry-free via the Cantor isomorphism. The remaining sorry
sites are in `cantor_bfmcs_restricted_fuc` (forward Until/Since coherence),
which requires the guard at intermediate points via C3 + limit_g.
-/

/--
Chronicle-based countermodel construction.

Given an MCS M containing ¬φ, build a countermodel over Rat where φ is false.
The remaining sorry sites (2) are in `cantor_bfmcs_restricted_fuc`:
- Forward Until guard at intermediate points (requires C3 + limit_g)
- Forward Since guard at intermediate points (mirror)
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
    ShiftClosedParametricCanonicalOmega (cantor_bfmcs M h_mcs),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (rooted_cantor_fmcs M h_mcs 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨rooted_cantor_fmcs M h_mcs 0,
       ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (rooted_cantor_fmcs M h_mcs 0).mcs 0 := by
    rw [rooted_cantor_fmcs_at_s]; exact h_neg_in
  exact fully_restricted_parametric_representation_from_neg_membership
    (cantor_bfmcs M h_mcs) φ
    (cantor_bfmcs_restricted_tc M h_mcs φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (cantor_bfmcs_restricted_buc M h_mcs φ)
    (cantor_bfmcs_restricted_fuc M h_mcs φ)
    φ (self_mem_subformulaClosure φ)
    (rooted_cantor_fmcs M h_mcs 0) ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

end Bimodal.Metalogic.BXCanonical.Chronicle
