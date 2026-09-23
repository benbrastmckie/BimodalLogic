/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.ConvexConsequence.AxiomSurvival
import FormalSystem.Metalogic.ConvexConsequence.FrameClassSurvival

/-!
# SurvivalTable - The Axiom-Survival Table as One Theorem

The row theorems of `AxiomSurvival.lean` and `FrameClassSurvival.lean`, assembled over the 29
constructors of `Axiom`.

- `Axiom.failsC3` names the four constructors that fail under C3: `serial_future`,
  `discrete_symm_fwd`, `discrete_propagate_fwd` and `discrete_box_necessity`.
- `c3_survival_table`: every other constructor is C3-valid on its minimum frame class.
- `c3_failure_table`: each of the four is refuted under C3 on the integer-time frame `NF`.

Both proofs are by cases over the constructors with **no wildcard case**, so a constructor added
to `Axiom` breaks this file until its C3 verdict is supplied.

The count of failures is four here and six in the prose summary of the table because two of the
six failing formulas, `serial_past` and `discrete_symm_bwd`, are not constructors: TM derives
them by time reflection. Their refutations are `refute_C3_serial_past` and
`refute_C3_discrete_symm_bwd`.

All four failures are existence assertions about the temporal order. Nothing here identifies the
surviving 25 with the axioms of a known system; the table is a list of verdicts, not a
completeness claim.

## Tags

convex-history · consequence-relation · axiom-survival
-/

namespace FormalSystem.ProofSystem

open FormalSystem.Syntax

/-- Whether an axiom of TM **fails** under the convex-index consequence relation C3. The four
failing constructors are named explicitly; `c3_survival_table` and `c3_failure_table` are what
make this a verdict rather than a label. -/
def Axiom.failsC3 {φ : Formula} : Axiom φ → Bool
  | serial_future => true
  | discrete_symm_fwd => true
  | discrete_propagate_fwd => true
  | discrete_box_necessity => true
  | _ => false

end FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.ConvexConsequence

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/-- **The survival half of the table**: every axiom of TM not flagged by `Axiom.failsC3` is
C3-valid on every frame of its minimum frame class. One case per constructor, each closed by its
row theorem. -/
theorem c3_survival_table {φ : Formula} (a : Axiom φ) (h : a.failsC3 = false) :
    ValidC3In a.minFrameClass φ := by
  cases a with
  | prop_k φ ψ χ => exact fun _ _ => c3_prop_k φ ψ χ
  | prop_s φ ψ => exact fun _ _ => c3_prop_s φ ψ
  | ex_falso φ => exact fun _ _ => c3_ex_falso φ
  | peirce φ ψ => exact fun _ _ => c3_peirce φ ψ
  | modal_t φ => exact fun _ _ => c3_modal_t φ
  | modal_5_collapse φ => exact fun _ _ => c3_modal_5_collapse φ
  | modal_k_dist φ ψ => exact fun _ _ => c3_modal_k_dist φ ψ
  | serial_future => exact absurd h (by decide)
  | left_mono_until_G φ χ ψ => exact fun _ _ => c3_left_mono_until_G φ χ ψ
  | right_mono_until φ ψ χ => exact fun _ _ => c3_right_mono_until φ ψ χ
  | connect_future φ => exact fun _ _ => c3_connect_future φ
  | enrichment_until φ ψ p => exact fun _ _ => c3_enrichment_until φ ψ p
  | self_accum_until φ ψ => exact fun _ _ => c3_self_accum_until φ ψ
  | absorb_until φ ψ => exact fun _ _ => c3_absorb_until φ ψ
  | linear_until φ ψ χ θ => exact fun _ _ => c3_linear_until φ ψ χ θ
  | until_F φ ψ => exact fun _ _ => c3_until_F φ ψ
  | temp_linearity φ ψ => exact fun _ _ => c3_temp_linearity φ ψ
  | F_until_equiv φ => exact fun _ _ => c3_F_until_equiv φ
  | modal_future φ => exact fun _ _ => c3_modal_future φ
  | discrete_symm_fwd => exact absurd h (by decide)
  | discrete_propagate_fwd => exact absurd h (by decide)
  | discrete_propagate_bwd => exact fun _ _ => c3_discrete_propagate_bwd
  | discrete_box_necessity => exact absurd h (by decide)
  | prior_UZ φ => exact fun _ hF => c3_prior_UZ hF.2 φ
  | z1 φ => exact fun _ hF => c3_z1 hF.2 φ
  | density φ => exact fun _ hF => c3_density hF.2 φ
  | dense_indicator => exact fun _ hF => c3_dense_indicator hF.2
  | prior_U_gap φ => exact fun _ hF => c3_prior_U_gap hF.2.2 φ
  | sep φ => exact fun _ hF => c3_sep hF.2 φ

/-- **The failure half of the table**: every axiom of TM flagged by `Axiom.failsC3` is refuted
under C3 on the integer-time frame `NF`. -/
theorem c3_failure_table {φ : Formula} (a : Axiom φ) (h : a.failsC3 = true) :
    ¬ ValidC3 NF φ := by
  cases a with
  | prop_k _ _ _ => exact absurd h Bool.false_ne_true
  | prop_s _ _ => exact absurd h Bool.false_ne_true
  | ex_falso _ => exact absurd h Bool.false_ne_true
  | peirce _ _ => exact absurd h Bool.false_ne_true
  | modal_t _ => exact absurd h Bool.false_ne_true
  | modal_5_collapse _ => exact absurd h Bool.false_ne_true
  | modal_k_dist _ _ => exact absurd h Bool.false_ne_true
  | serial_future => exact refute_C3_serial_future
  | left_mono_until_G _ _ _ => exact absurd h Bool.false_ne_true
  | right_mono_until _ _ _ => exact absurd h Bool.false_ne_true
  | connect_future _ => exact absurd h Bool.false_ne_true
  | enrichment_until _ _ _ => exact absurd h Bool.false_ne_true
  | self_accum_until _ _ => exact absurd h Bool.false_ne_true
  | absorb_until _ _ => exact absurd h Bool.false_ne_true
  | linear_until _ _ _ _ => exact absurd h Bool.false_ne_true
  | until_F _ _ => exact absurd h Bool.false_ne_true
  | temp_linearity _ _ => exact absurd h Bool.false_ne_true
  | F_until_equiv _ => exact absurd h Bool.false_ne_true
  | modal_future _ => exact absurd h Bool.false_ne_true
  | discrete_symm_fwd => exact refute_C3_discrete_symm_fwd
  | discrete_propagate_fwd => exact refute_C3_discrete_propagate_fwd
  | discrete_propagate_bwd => exact absurd h Bool.false_ne_true
  | discrete_box_necessity => exact refute_C3_discrete_box_necessity
  | prior_UZ _ => exact absurd h Bool.false_ne_true
  | z1 _ => exact absurd h Bool.false_ne_true
  | density _ => exact absurd h Bool.false_ne_true
  | dense_indicator => exact absurd h Bool.false_ne_true
  | prior_U_gap _ => exact absurd h Bool.false_ne_true
  | sep _ => exact absurd h Bool.false_ne_true

end FormalSystem.Metalogic.ConvexConsequence
