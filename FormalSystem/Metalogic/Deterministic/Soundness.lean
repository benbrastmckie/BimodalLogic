/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Deterministic.System
import FormalSystem.Metalogic.Deterministic.Validity
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness

/-!
# Soundness of TM⁺ + *Determined*

`DetDerivable fc [] φ ⟹ PlusValidDeterminedIn fc φ`: the extended system is sound over the
frames of `fc` that **validate every instance of the *Determined* schema** — a class strictly
containing the deterministic frames (`Metalogic/Deterministic/Validity.lean`,
`determinedValid_not_deterministic`).

Stating soundness at the larger class is not a stylistic choice: it is the half of the
coincidence corollary the manuscript needs. Soundness over the *Determined*-valid frames plus
completeness over the *deterministic* frames is exactly what forces the two logics to coincide
(`Metalogic/Deterministic/Completeness.lean`), even though *Determined* defines neither class
(`deterministic_not_plusDefinable`).

## Method

The same companion recursion TM and TM⁺ soundness use
(`Metalogic/Conservativity/Plus/PlusSoundness.lean`, `plus_derivable_valid_and_swap_validIn`):
carry both `PlusValidDeterminedIn fc φ` and `PlusValidDeterminedIn fc φ.swapTemporal`, so the
`temporal_duality` case exchanges the two components. TD is discharged **semantically**, never by
mapping derivations to mirrored derivations — the axiom set is not mirror-closed.

The two axiom arms:

- `ofPlus` — TM⁺'s own validity and swap-validity, transported down the frame predicate by
  `PlusValidIn.toDetermined`. Nothing about `⊡` is re-proved.
- `determined` — direct from the `DeterminedValid F` component of the frame predicate. Its
  temporal dual is again a *Determined* instance, because `swapTemporal` fixes `⊡`
  (`PlusFormula.swapTemporal`, `stab φ ↦ stab φ.swapTemporal`), so the swap arm needs no
  separate argument.

## Main Results

- `det_derivable_valid_and_swap_validDeterminedIn` — the companion recursion
- `detSoundness` — `DetDerivable fc [] φ → PlusValidDeterminedIn fc φ`
- `detSoundnessDet` — its specialization to the deterministic frames
- `detSoundnessIn` — the context form
- `det_not_derivable_nil_bot` — consistency of the extended system at `.Base`

## References

* `FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean` — the recursion mirrored here
* `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — `determined_of_deterministic`

## Tags

soundness · determinism · plus-language · app:deterministic
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open FormalSystem.Metalogic.Conservativity

/-! ## The axiom arms -/

/-- Every extended-system axiom instance is valid over the *Determined*-valid frames of any class
above its minimum. -/
theorem detAxiom_validDeterminedIn {φ : PlusFormula} {fc : FrameClass} (ax : DetAxiom φ)
    (h : ax.minFrameClass ≤ fc) : PlusValidDeterminedIn fc φ := by
  cases ax with
  | ofPlus hp => exact PlusValidIn.toDetermined (plusAxiom_validIn hp h)
  | determined ψ =>
    refine PlusValidDeterminedIn.of_forall_total ?_
    intro F _ hDV M τ hτ t
    exact hDV ψ M ⟨τ, hτ⟩ t

/-- The temporal dual of every extended-system axiom instance is likewise valid over the
*Determined*-valid frames. The `determined` arm needs no separate argument: `swapTemporal` fixes
`⊡`, so the dual of `φ → ⊡φ` is `φ' → ⊡φ'` at `φ' = φ.swapTemporal`. -/
theorem detAxiom_swap_validDeterminedIn {φ : PlusFormula} {fc : FrameClass} (ax : DetAxiom φ)
    (h : ax.minFrameClass ≤ fc) : PlusValidDeterminedIn fc φ.swapTemporal := by
  cases ax with
  | ofPlus hp => exact PlusValidIn.toDetermined (plusAxiom_swap_validIn hp h)
  | determined ψ =>
    refine PlusValidDeterminedIn.of_forall_total ?_
    intro F _ hDV M τ hτ t
    exact hDV ψ.swapTemporal M ⟨τ, hτ⟩ t

/-! ## The companion recursion -/

/-- **The companion recursion.** An extended-system theorem at `fc` is valid over the
*Determined*-valid frames of `fc`, and so is its temporal dual. Mirror of
`plus_derivable_valid_and_swap_validIn`, arm for arm; well-founded on the derivation's height
because the `weakening` case re-targets to the empty context without a structural descent. -/
theorem det_derivable_valid_and_swap_validDeterminedIn {fc : FrameClass} {φ : PlusFormula}
    (d : DetDerivationTree fc [] φ) :
    PlusValidDeterminedIn fc φ ∧ PlusValidDeterminedIn fc φ.swapTemporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨detAxiom_validDeterminedIn h_ax h_fc, detAxiom_swap_validDeterminedIn h_ax h_fc⟩
  | .assumption _ _ h_mem =>
    exact absurd h_mem List.not_mem_nil
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := det_derivable_valid_and_swap_validDeterminedIn d1
    have h2 := det_derivable_valid_and_swap_validDeterminedIn d2
    constructor
    · refine PlusValidDeterminedIn.of_forall_total ?_
      intro F hF hDV M τ hτ t
      exact (h1.1.apply_total F hF hDV M τ hτ t) (h2.1.apply_total F hF hDV M τ hτ t)
    · refine PlusValidDeterminedIn.of_forall_total ?_
      intro F hF hDV M τ hτ t
      exact (h1.2.apply_total F hF hDV M τ hτ t) (h2.2.apply_total F hF hDV M τ hτ t)
  | .necessitation psi' d' =>
    have h := det_derivable_valid_and_swap_validDeterminedIn d'
    constructor
    · refine PlusValidDeterminedIn.of_forall_total ?_
      intro F hF hDV M τ _ t σ hσ
      exact h.1.apply_total F hF hDV M σ hσ t
    · refine PlusValidDeterminedIn.of_forall_total ?_
      intro F hF hDV M τ _ t σ hσ
      exact h.2.apply_total F hF hDV M σ hσ t
  | .temporal_necessitation psi' d' =>
    have h := det_derivable_valid_and_swap_validDeterminedIn d'
    constructor
    · refine PlusValidDeterminedIn.of_forall_total ?_
      intro F hF hDV M τ hτ t
      rw [PlusTruth.allFuture_iff]
      intro s _
      exact h.1.apply_total F hF hDV M τ hτ s
    · refine PlusValidDeterminedIn.of_forall_total ?_
      intro F hF hDV M τ hτ t
      rw [swap_temporal_all_future, PlusTruth.allPast_iff]
      intro s _
      exact h.2.apply_total F hF hDV M τ hτ s
  | .temporal_duality psi' d' =>
    have h := det_derivable_valid_and_swap_validDeterminedIn d'
    refine ⟨h.2, ?_⟩
    rw [swap_temporal_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_term := DetDerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact det_derivable_valid_and_swap_validDeterminedIn (d'.ofWeakeningNil h_sub)
termination_by d.height
decreasing_by
  all_goals first
    | exact DetDerivationTree.mp_height_gt_left _ _
    | exact DetDerivationTree.mp_height_gt_right _ _
    | omega
    | simp only [DetDerivationTree.height]; omega

/-! ## Soundness -/

/--
**Soundness of TM⁺ + *Determined***: a theorem of the extended system at `fc` is valid over every
frame of `fc` that validates every instance of *Determined*.

Note the class: it is strictly larger than the deterministic frames
(`determinedValid_not_deterministic`), and this is the stronger statement.

Paper: `app:deterministic`
-/
theorem detSoundness {fc : FrameClass} {φ : PlusFormula} (h : DetDerivable fc [] φ) :
    PlusValidDeterminedIn fc φ :=
  h.elim fun d => (det_derivable_valid_and_swap_validDeterminedIn d).1

/-- Soundness specialized to the deterministic frames, via the inclusion
`deterministic_determinedValid`. This is the direction the completeness theorem pairs with. -/
theorem detSoundnessDet {fc : FrameClass} {φ : PlusFormula} (h : DetDerivable fc [] φ) :
    PlusValidDetIn fc φ :=
  PlusValidDetIn.of_determined (detSoundness h)

/-- Soundness, context form: a derivation of `φ` from `Γ` makes `φ` true at every point of every
model over a *Determined*-valid frame of `fc` at which all of `Γ` is true. -/
theorem detSoundnessIn {fc : FrameClass} (Γ : PlusContext) (φ : PlusFormula)
    (d : DetDerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (hDV : DeterminedValid F) (M : TaskModel F)
    (τ : ConvexHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, PlusTruthAt M τ t ψ) :
    PlusTruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    exact (detAxiom_validDeterminedIn h_ax h_fc).apply_total F hF hDV M τ h_mem t
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
    exact ((det_derivable_valid_and_swap_validDeterminedIn d').2).apply_total F hF hDV M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## Consistency -/

/--
**TM⁺ + *Determined* is consistent at `.Base`**: `⊥` is not a theorem.

Witness: the translation flow `F¹` (`Metalogic/Independence/RealTranslationFrame.lean`), which is
deterministic and hence *Determined*-valid. (Consistency at the wider classes is not a corollary,
since derivability lifts upward; each would need its own witness frame.)
-/
theorem det_not_derivable_nil_bot :
    ¬ DetDerivable FrameClass.Base [] PlusFormula.bot := by
  intro h
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms Independence.F1
  exact (detSoundness h).apply_total Independence.F1 trivial
    (deterministic_determinedValid Independence.f1_deterministic)
    TaskModel.allFalse τ.val τ.property 0

end FormalSystem.Metalogic.Deterministic
