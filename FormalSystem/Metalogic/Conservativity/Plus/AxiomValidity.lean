/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Plus.Atomization
import FormalSystem.Semantics.PlusPasting
import FormalSystem.Semantics.PlusStateLocal
import FormalSystem.Syntax.PlusLanguage.Axioms

/-!
# Validity and swap-validity of every TM⁺ axiom schema

The two dispatch lemmas of TM⁺ soundness, one arm per `PlusAxiom` constructor and no wildcard
arm — so that a constructor added to `PlusAxiom` fails the build here until its arm is supplied:

- `plusAxiom_validIn_min` — every schema is valid at its own `minFrameClass`;
- `plusAxiom_swap_validIn_min` — every schema's temporal dual is valid at its own
  `minFrameClass`.

The second is what makes the `temporal_duality` rule sound **semantically**
(`Conservativity/Plus/PlusSoundness.lean`, the companion recursion): no proof-theoretic
mirror argument is used, since the TM axiom set is not mirror-closed.

## How the arms close

- **The 45 TM arms** are discharged by atomization (`Conservativity/Plus/Atomization.lean`):
  each is `plusValidIn_of_tm` (resp. `plusValidIn_swap_of_tm`) applied to the landed L
  schema at the atomized parameters, under one fixed encoding. No schema is re-proved over
  `PlusTruthAt`.
- **The six S5/bridge `⊡` arms** are the definitional validities of `Semantics/PlusTruth.lean`
  (`of_stab`, `stab_four`, `stab_five`, `stab_of_box`; K is the universal-quantifier shape of the
  `stab` clause) together with `stab_of_stateLocal` (`Semantics/PlusStateLocal.lean`), which
  discharges AS at the atom instance `stateLocal_atom p` of the state-locality fragment. Their temporal duals are the same schemata
  at swapped parameters, because `swapTemporal` fixes `stab`.
- **The two pasting arms** are the PS/US validities of `Semantics/PlusPasting.lean`; their
  temporal duals are the past mirrors `paste'_plusValid` and `snce_paste_plusValid`, with the
  purity side conditions exchanged by `IsPureFuture.swapTemporal` / `IsPurePast.swapTemporal`.

## References

* `FormalSystem/Metalogic/Soundness.lean` — `axiom_validIn_min`, `axiom_swap_validIn_min`, the
  L lemmas being transferred, and the dispatch shape being mirrored
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-- One fixed encoding, chosen once for every TM arm below. -/
noncomputable def theEncoding : Encoding := Classical.choice Encoding.nonempty

/-- Atomization under the fixed encoding. -/
noncomputable abbrev A (φ : PlusFormula) : Formula := atomize theEncoding φ

/-- Atomization under the conjugated fixed encoding (for the swap arms). -/
noncomputable abbrev A' (φ : PlusFormula) : Formula := atomize theEncoding.swap φ

/-! ## Validity -/

/-- **Every TM⁺ schema is valid at its own minimum frame class.** One arm per constructor. -/
theorem plusAxiom_validIn_min {φ : PlusFormula} (ax : PlusAxiom φ) :
    PlusValidIn ax.minFrameClass φ := by
  cases ax with
  | prop_k a0 a1 a2 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.prop_k (A a0) (A a1) (A a2)) le_rfl
  | prop_s a0 a1 => exact plusValidIn_of_tm theEncoding _ (Axiom.prop_s (A a0) (A a1)) le_rfl
  | ex_falso a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.ex_falso (A a0)) le_rfl
  | peirce a0 a1 => exact plusValidIn_of_tm theEncoding _ (Axiom.peirce (A a0) (A a1)) le_rfl
  | modal_t a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.modal_t (A a0)) le_rfl
  | modal_4 a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.modal_4 (A a0)) le_rfl
  | modal_b a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.modal_b (A a0)) le_rfl
  | modal_5_collapse a0 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.modal_5_collapse (A a0)) le_rfl
  | modal_k_dist a0 a1 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.modal_k_dist (A a0) (A a1)) le_rfl
  | serial_future => exact plusValidIn_of_tm theEncoding _ Axiom.serial_future le_rfl
  | serial_past => exact plusValidIn_of_tm theEncoding _ Axiom.serial_past le_rfl
  | left_mono_until_G a0 a1 a2 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.left_mono_until_G (A a0) (A a1) (A a2)) le_rfl
  | left_mono_since_H a0 a1 a2 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.left_mono_since_H (A a0) (A a1) (A a2)) le_rfl
  | right_mono_until a0 a1 a2 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.right_mono_until (A a0) (A a1) (A a2)) le_rfl
  | right_mono_since a0 a1 a2 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.right_mono_since (A a0) (A a1) (A a2)) le_rfl
  | connect_future a0 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.connect_future (A a0)) le_rfl
  | connect_past a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.connect_past (A a0)) le_rfl
  | enrichment_until a0 a1 a2 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.enrichment_until (A a0) (A a1) (A a2)) le_rfl
  | enrichment_since a0 a1 a2 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.enrichment_since (A a0) (A a1) (A a2)) le_rfl
  | self_accum_until a0 a1 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.self_accum_until (A a0) (A a1)) le_rfl
  | self_accum_since a0 a1 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.self_accum_since (A a0) (A a1)) le_rfl
  | absorb_until a0 a1 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.absorb_until (A a0) (A a1)) le_rfl
  | absorb_since a0 a1 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.absorb_since (A a0) (A a1)) le_rfl
  | linear_until a0 a1 a2 a3 =>
    exact plusValidIn_of_tm theEncoding _
      (Axiom.linear_until (A a0) (A a1) (A a2) (A a3)) le_rfl
  | linear_since a0 a1 a2 a3 =>
    exact plusValidIn_of_tm theEncoding _
      (Axiom.linear_since (A a0) (A a1) (A a2) (A a3)) le_rfl
  | until_F a0 a1 => exact plusValidIn_of_tm theEncoding _ (Axiom.until_F (A a0) (A a1)) le_rfl
  | since_P a0 a1 => exact plusValidIn_of_tm theEncoding _ (Axiom.since_P (A a0) (A a1)) le_rfl
  | temp_linearity a0 a1 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.temp_linearity (A a0) (A a1)) le_rfl
  | temp_linearity_past a0 a1 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.temp_linearity_past (A a0) (A a1)) le_rfl
  | F_until_equiv a0 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.F_until_equiv (A a0)) le_rfl
  | P_since_equiv a0 =>
    exact plusValidIn_of_tm theEncoding _ (Axiom.P_since_equiv (A a0)) le_rfl
  | modal_future a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.modal_future (A a0)) le_rfl
  | discrete_symm_fwd => exact plusValidIn_of_tm theEncoding _ Axiom.discrete_symm_fwd le_rfl
  | discrete_symm_bwd => exact plusValidIn_of_tm theEncoding _ Axiom.discrete_symm_bwd le_rfl
  | discrete_propagate_fwd =>
    exact plusValidIn_of_tm theEncoding _ Axiom.discrete_propagate_fwd le_rfl
  | discrete_propagate_bwd =>
    exact plusValidIn_of_tm theEncoding _ Axiom.discrete_propagate_bwd le_rfl
  | discrete_box_necessity =>
    exact plusValidIn_of_tm theEncoding _ Axiom.discrete_box_necessity le_rfl
  | prior_UZ a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.prior_UZ (A a0)) le_rfl
  | prior_SZ a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.prior_SZ (A a0)) le_rfl
  | z1 a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.z1 (A a0)) le_rfl
  | density a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.density (A a0)) le_rfl
  | dense_indicator => exact plusValidIn_of_tm theEncoding _ Axiom.dense_indicator le_rfl
  | prior_U_gap a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.prior_U_gap (A a0)) le_rfl
  | prior_S_gap a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.prior_S_gap (A a0)) le_rfl
  | sep a0 => exact plusValidIn_of_tm theEncoding _ (Axiom.sep (A a0)) le_rfl
  | stab_k a0 a1 =>
    exact PlusValidIn.of_forall_total fun _ _ M τ _ t h1 h2 σ hσ hs => h1 σ hσ hs (h2 σ hσ hs)
  | stab_t a0 => exact PlusValidIn.of_forall_total fun _ _ M τ hτ t => of_stab M τ hτ t a0
  | stab_4 a0 => exact PlusValidIn.of_forall_total fun _ _ M τ _ t => stab_four M τ t a0
  | stab_5 a0 =>
    exact PlusValidIn.of_forall_total fun _ _ M τ hτ t h => stab_five M τ hτ t a0.neg h
  | box_stab a0 => exact PlusValidIn.of_forall_total fun _ _ M τ _ t => stab_of_box M τ t a0
  | atom_stab p =>
    exact PlusValidIn.of_forall_total fun _ _ M τ hτ t =>
      stab_of_stateLocal (stateLocal_atom p) M τ hτ t
  | paste a0 a1 h0 h1 => exact paste_plusValid h0 h1
  | untl_paste a0 a1 h0 h1 => exact untl_paste_starValid h0 h1

/-- Validity of a TM⁺ schema at any class admitting it. -/
theorem plusAxiom_validIn {φ : PlusFormula} {fc : FrameClass} (ax : PlusAxiom φ)
    (h : ax.minFrameClass ≤ fc) : PlusValidIn fc φ :=
  PlusValidIn.mono h (plusAxiom_validIn_min ax)

/-! ## Swap-validity -/

/-- **Every TM⁺ schema's temporal dual is valid at its own minimum frame class.** One arm per
constructor; the semantic input to the `temporal_duality` case of soundness. -/
theorem plusAxiom_swap_validIn_min {φ : PlusFormula} (ax : PlusAxiom φ) :
    PlusValidIn ax.minFrameClass φ.swapTemporal := by
  cases ax with
  | prop_k a0 a1 a2 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.prop_k (A' a0) (A' a1) (A' a2)) le_rfl
  | prop_s a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.prop_s (A' a0) (A' a1)) le_rfl
  | ex_falso a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.ex_falso (A' a0)) le_rfl
  | peirce a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.peirce (A' a0) (A' a1)) le_rfl
  | modal_t a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.modal_t (A' a0)) le_rfl
  | modal_4 a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.modal_4 (A' a0)) le_rfl
  | modal_b a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.modal_b (A' a0)) le_rfl
  | modal_5_collapse a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.modal_5_collapse (A' a0)) le_rfl
  | modal_k_dist a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.modal_k_dist (A' a0) (A' a1)) le_rfl
  | serial_future => exact plusValidIn_swap_of_tm theEncoding _ Axiom.serial_future le_rfl
  | serial_past => exact plusValidIn_swap_of_tm theEncoding _ Axiom.serial_past le_rfl
  | left_mono_until_G a0 a1 a2 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.left_mono_until_G (A' a0) (A' a1) (A' a2)) le_rfl
  | left_mono_since_H a0 a1 a2 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.left_mono_since_H (A' a0) (A' a1) (A' a2)) le_rfl
  | right_mono_until a0 a1 a2 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.right_mono_until (A' a0) (A' a1) (A' a2)) le_rfl
  | right_mono_since a0 a1 a2 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.right_mono_since (A' a0) (A' a1) (A' a2)) le_rfl
  | connect_future a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.connect_future (A' a0)) le_rfl
  | connect_past a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.connect_past (A' a0)) le_rfl
  | enrichment_until a0 a1 a2 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.enrichment_until (A' a0) (A' a1) (A' a2)) le_rfl
  | enrichment_since a0 a1 a2 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.enrichment_since (A' a0) (A' a1) (A' a2)) le_rfl
  | self_accum_until a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.self_accum_until (A' a0) (A' a1)) le_rfl
  | self_accum_since a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.self_accum_since (A' a0) (A' a1)) le_rfl
  | absorb_until a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.absorb_until (A' a0) (A' a1)) le_rfl
  | absorb_since a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.absorb_since (A' a0) (A' a1)) le_rfl
  | linear_until a0 a1 a2 a3 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.linear_until (A' a0) (A' a1) (A' a2) (A' a3)) le_rfl
  | linear_since a0 a1 a2 a3 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.linear_since (A' a0) (A' a1) (A' a2) (A' a3)) le_rfl
  | until_F a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.until_F (A' a0) (A' a1)) le_rfl
  | since_P a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.since_P (A' a0) (A' a1)) le_rfl
  | temp_linearity a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.temp_linearity (A' a0) (A' a1)) le_rfl
  | temp_linearity_past a0 a1 =>
    exact plusValidIn_swap_of_tm theEncoding _
      (Axiom.temp_linearity_past (A' a0) (A' a1)) le_rfl
  | F_until_equiv a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.F_until_equiv (A' a0)) le_rfl
  | P_since_equiv a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.P_since_equiv (A' a0)) le_rfl
  | modal_future a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.modal_future (A' a0)) le_rfl
  | discrete_symm_fwd =>
    exact plusValidIn_swap_of_tm theEncoding _ Axiom.discrete_symm_fwd le_rfl
  | discrete_symm_bwd =>
    exact plusValidIn_swap_of_tm theEncoding _ Axiom.discrete_symm_bwd le_rfl
  | discrete_propagate_fwd =>
    exact plusValidIn_swap_of_tm theEncoding _ Axiom.discrete_propagate_fwd le_rfl
  | discrete_propagate_bwd =>
    exact plusValidIn_swap_of_tm theEncoding _ Axiom.discrete_propagate_bwd le_rfl
  | discrete_box_necessity =>
    exact plusValidIn_swap_of_tm theEncoding _ Axiom.discrete_box_necessity le_rfl
  | prior_UZ a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.prior_UZ (A' a0)) le_rfl
  | prior_SZ a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.prior_SZ (A' a0)) le_rfl
  | z1 a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.z1 (A' a0)) le_rfl
  | density a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.density (A' a0)) le_rfl
  | dense_indicator =>
    exact plusValidIn_swap_of_tm theEncoding _ Axiom.dense_indicator le_rfl
  | prior_U_gap a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.prior_U_gap (A' a0)) le_rfl
  | prior_S_gap a0 =>
    exact plusValidIn_swap_of_tm theEncoding _ (Axiom.prior_S_gap (A' a0)) le_rfl
  | sep a0 => exact plusValidIn_swap_of_tm theEncoding _ (Axiom.sep (A' a0)) le_rfl
  | stab_k a0 a1 =>
    exact PlusValidIn.of_forall_total fun _ _ M τ _ t h1 h2 σ hσ hs => h1 σ hσ hs (h2 σ hσ hs)
  | stab_t a0 =>
    exact PlusValidIn.of_forall_total fun _ _ M τ hτ t => of_stab M τ hτ t a0.swapTemporal
  | stab_4 a0 =>
    exact PlusValidIn.of_forall_total fun _ _ M τ _ t => stab_four M τ t a0.swapTemporal
  | stab_5 a0 =>
    exact PlusValidIn.of_forall_total fun _ _ M τ hτ t h =>
      stab_five M τ hτ t a0.swapTemporal.neg h
  | box_stab a0 =>
    exact PlusValidIn.of_forall_total fun _ _ M τ _ t => stab_of_box M τ t a0.swapTemporal
  | atom_stab p =>
    exact PlusValidIn.of_forall_total fun _ _ M τ hτ t =>
      stab_of_stateLocal (stateLocal_atom p) M τ hτ t
  | paste a0 a1 h0 h1 =>
    simp only [PlusFormula.swapTemporal, swap_temporal_dstab, swap_temporal_and]
    exact paste'_plusValid h0.swapTemporal h1.swapTemporal
  | untl_paste a0 a1 h0 h1 =>
    simp only [PlusFormula.swapTemporal, swap_temporal_dstab]
    exact snce_paste_plusValid h0.swapTemporal h1.swapTemporal

/-- Swap-validity of a TM⁺ schema at any class admitting it. -/
theorem plusAxiom_swap_validIn {φ : PlusFormula} {fc : FrameClass} (ax : PlusAxiom φ)
    (h : ax.minFrameClass ≤ fc) : PlusValidIn fc φ.swapTemporal :=
  PlusValidIn.mono h (plusAxiom_swap_validIn_min ax)

end FormalSystem.Metalogic.Conservativity
