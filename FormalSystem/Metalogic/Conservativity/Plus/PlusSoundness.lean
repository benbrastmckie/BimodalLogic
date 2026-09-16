/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Plus.AxiomValidity
import FormalSystem.Syntax.PlusLanguage

/-!
# Soundness of TM⁺ at every frame class

`TM⁺ ⊢[fc] φ ⟹ PlusValidIn fc φ`, for every `fc`, by the same companion recursion the L
soundness theorem uses (`Metalogic/Soundness.lean`, `derivable_valid_and_swap_validIn`):
the recursion carries **both** `PlusValidIn fc φ` and `PlusValidIn fc φ.swapTemporal`, so that
the `temporal_duality` case simply exchanges the two components. The `axiom` case feeds in the
two dispatch lemmas of `Conservativity/Plus/AxiomValidity.lean`; everything else is the clause
structure of `PlusTruthAt`.

**TD is discharged semantically, never proof-theoretically.** Mapping derivations to mirrored
derivations would require the axiom set to be mirror-closed, which TM's is not (BX lists the
future halves and obtains the past halves by TD); the companion recursion needs only
per-schema swap-validity, which `plusAxiom_swap_validIn_min` supplies for every constructor.

## Main Results

- `plus_derivable_valid_and_swap_validIn` — the companion recursion
- `plus_soundness_validIn` — `PlusDerivable fc [] φ → PlusValidIn fc φ`
- `plus_soundness_in` — the context form, by induction on the derivation
- `plus_soundness_base/dense/discrete/dedekind`, `plus_soundness_valid` — the per-class rows

## References

* `FormalSystem/Metalogic/Soundness.lean` — `derivable_valid_and_swap_validIn`, `soundness_in`,
  the theorems mirrored arm for arm

## Tags

soundness · plus-language · stability-modal · atomization
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-- **The companion recursion.** A TM⁺ theorem at `fc` is `PlusValidIn fc`, and so is its
temporal dual. Mirror of `derivable_valid_and_swap_validIn`, arm for arm; well-founded on the
derivation's height because the `weakening` case re-targets to the empty context without a
structural descent. -/
theorem plus_derivable_valid_and_swap_validIn {fc : FrameClass} {φ : PlusFormula}
    (d : PlusDerivationTree fc [] φ) : PlusValidIn fc φ ∧ PlusValidIn fc φ.swapTemporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨plusAxiom_validIn h_ax h_fc, plusAxiom_swap_validIn h_ax h_fc⟩
  | .assumption _ _ h_mem =>
    exact absurd h_mem List.not_mem_nil
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := plus_derivable_valid_and_swap_validIn d1
    have h2 := plus_derivable_valid_and_swap_validIn d2
    constructor
    · refine PlusValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      exact (h1.1.apply_total F hF M τ hτ t) (h2.1.apply_total F hF M τ hτ t)
    · refine PlusValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      exact (h1.2.apply_total F hF M τ hτ t) (h2.2.apply_total F hF M τ hτ t)
  | .necessitation psi' d' =>
    have h := plus_derivable_valid_and_swap_validIn d'
    constructor
    · refine PlusValidIn.of_forall_total ?_
      intro F hF M τ _ t σ hσ
      exact h.1.apply_total F hF M σ hσ t
    · refine PlusValidIn.of_forall_total ?_
      intro F hF M τ _ t σ hσ
      exact h.2.apply_total F hF M σ hσ t
  | .temporal_necessitation psi' d' =>
    have h := plus_derivable_valid_and_swap_validIn d'
    constructor
    · refine PlusValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      rw [PlusTruth.allFuture_iff]
      intro s _
      exact h.1.apply_total F hF M τ hτ s
    · refine PlusValidIn.of_forall_total ?_
      intro F hF M τ hτ t
      rw [swap_temporal_all_future, PlusTruth.allPast_iff]
      intro s _
      exact h.2.apply_total F hF M τ hτ s
  | .temporal_duality psi' d' =>
    have h := plus_derivable_valid_and_swap_validIn d'
    refine ⟨h.2, ?_⟩
    rw [swap_temporal_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_term := PlusDerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact plus_derivable_valid_and_swap_validIn (d'.ofWeakeningNil h_sub)
termination_by d.height
decreasing_by
  all_goals first
    | exact PlusDerivationTree.mp_height_gt_left _ _
    | exact PlusDerivationTree.mp_height_gt_right _ _
    | omega
    | simp only [PlusDerivationTree.height]; omega

/-- **Soundness of TM⁺ at `fc`**, empty-context validity form.

Paper: — (formalization-native; L⁺ is the ⊡-only fragment of the paper's `\BL^\star`, for which the paper supplies no logic)
-/
theorem plus_soundness_validIn {fc : FrameClass} {φ : PlusFormula}
    (h : PlusDerivable fc [] φ) : PlusValidIn fc φ :=
  h.elim fun d => (plus_derivable_valid_and_swap_validIn d).1

/-- **Soundness of TM⁺ at `fc`**, context form: a derivation of `φ` from `Γ` makes `φ` true at
every model over a frame satisfying `fc`, every total history and every time at which all of `Γ`
is true. Mirror of `soundness_in`; the `temporal_duality` case defers to the companion
recursion. -/
theorem plus_soundness_in {fc : FrameClass} (Γ : PlusContext) (φ : PlusFormula)
    (d : PlusDerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : ConvexHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, PlusTruthAt M τ t ψ) :
    PlusTruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    exact (plusAxiom_validIn h_ax h_fc).apply_total F hF M τ h_mem t
  | assumption Γ' φ' h_in => exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    exact (ih1 τ h_mem t h_ctx) (ih2 τ h_mem t h_ctx)
  | necessitation φ' _ ih =>
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    rw [PlusTruth.allFuture_iff]
    intro s _
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' _ih =>
    exact ((plus_derivable_valid_and_swap_validIn d').2).apply_total F hF M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## The four rows -/

/-- Soundness of TM⁺ at `.Base`: a TM⁺ theorem is `PlusValid`. -/
theorem plus_soundness_valid {φ : PlusFormula} (h : PlusDerivable FrameClass.Base [] φ) :
    PlusValid φ :=
  plus_soundness_validIn h

/-- Soundness of TM⁺ at `.Base` (context form). -/
theorem plus_soundness_base (Γ : PlusContext) (φ : PlusFormula)
    (d : PlusDerivationTree FrameClass.Base Γ φ) (F : TaskFrame) (M : TaskModel F)
    (τ : ConvexHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, PlusTruthAt M τ t ψ) : PlusTruthAt M τ t φ :=
  plus_soundness_in Γ φ d F trivial M τ h_mem t h_ctx

/-- Soundness of TM⁺ at `.Dense`. -/
theorem plus_soundness_dense {φ : PlusFormula} (h : PlusDerivable FrameClass.Dense [] φ) :
    PlusValidDense φ :=
  plus_soundness_validIn h

/-- Soundness of TM⁺ at `.ZTime`. -/
theorem plus_soundness_ztime {φ : PlusFormula}
    (h : PlusDerivable FrameClass.ZTime [] φ) : PlusValidZTime φ :=
  plus_soundness_validIn h

/-- Soundness of TM⁺ at `.RTime`. -/
theorem plus_soundness_rtime {φ : PlusFormula}
    (h : PlusDerivable FrameClass.RTime [] φ) : PlusValidRTime φ :=
  plus_soundness_validIn h

/-! ## Acceptance checks -/

/-- The derived `⊡`-necessitation rule is sound: its conclusion is valid whenever its premise
is derivable. -/
example {fc : FrameClass} {φ : PlusFormula} (d : ⊢⁺[fc] φ) :
    PlusValidIn fc (PlusFormula.stab φ) :=
  plus_soundness_validIn ⟨stabNecessitation d⟩

/-- **TM⁺ is consistent at `.Base`**: `⊥` is not a theorem. (Consistency at the wider classes is
not a corollary, since derivability lifts upward; each would need its own witness frame.) Witness: the trivial frame over `ℤ` with the all-false valuation, mirroring
`minus_not_derivable_nil_bot_ztime`. -/
theorem plus_not_derivable_nil_bot :
    ¬ PlusDerivable FrameClass.Base [] PlusFormula.bot := by
  intro h
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (FrameOver.trivialFrame (D := ℤ))
  exact (plus_soundness_validIn h).apply_total (FrameOver.trivialFrame (D := ℤ)) trivial
    TaskModel.allFalse τ.val τ.property 0

end FormalSystem.Metalogic.Conservativity
