/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Star.StarAxiomValidity
import FormalSystem.Syntax.StarLanguage

/-!
# Soundness of TM⋆ at every frame class

`TM⋆ ⊢⋆[fc] φ ⟹ StarValidIn fc φ`, for every `fc`, by the same companion recursion TM⁺ and TM
soundness use (`Conservativity/Plus/PlusSoundness.lean`,
`plus_derivable_valid_and_swap_validIn`): the recursion carries **both** `StarValidIn fc φ` and
`StarValidIn fc φ.swapTemporal`, so that the `temporal_duality` case exchanges the two
components. The `axiom` case feeds in the two dispatch lemmas of
`Conservativity/Star/StarAxiomValidity.lean`; everything else is the clause structure of
`StarTruthAt`.

## Why the three empty-context rules are sound over register-containing formulas

`StarValidIn` quantifies the stored-time vector **universally**, exactly as it quantifies the
time and the possible world (`Semantics/StarValidity.lean`): once `v⃗` is part of the point of
evaluation, `def:frame-validity`'s "true at every model, possible world and time" reads "…and
every stored-time vector". Both register clauses map a point to a point — `↑ⁱ` changes the
vector, `↓ⁱ` changes the time, neither escapes the frame — so `necessitation`,
`temporal_necessitation` and `temporal_duality` all preserve validity at a register-containing
formula just as they do at a register-free one.

**No argument here uses uniform substitution**, and none is available: TM⁺ is already not
substitution-closed (`PlusAxiom.atom_stab`), and TD is discharged semantically through
`starAxiom_swap_validIn_min` rather than by mapping derivations to mirrored derivations, which
would require an axiom set that is mirror-closed as a *set of instances*.

## Main Results

- `star_derivable_valid_and_swap_validIn` — the companion recursion
- `star_soundness_validIn` — `StarDerivable fc [] φ → StarValidIn fc φ`
- `star_soundness_valid` / `_dense` / `_ztime` / `_rtime` — the four rows
- `star_not_derivable_nil_bot` — consistency of TM⋆ at `.Base`

## References

* `FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean` — the theorems mirrored arm for
  arm
* `FormalSystem/Semantics/StarValidity.lean` — the binder-shape adapters this recursion runs on
  (`StarValidIn.of_forall_total` / `.apply_total`), stated there beside `StarValidIn` itself and
  beside the `StarValidOnFrames` forms they instantiate
* JPL paper `possible_worlds.tex` — `def:frame-validity`, `def:BLstar-semantics`

## Tags

soundness · star-language · store-recall · temporal-duality
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## The companion recursion -/

/-- **The companion recursion.** A TM⋆ theorem at `fc` is `StarValidIn fc`, and so is its
temporal dual. Mirror of `plus_derivable_valid_and_swap_validIn`, arm for arm; well-founded on
the derivation's height because the `weakening` case re-targets to the empty context without a
structural descent. -/
theorem star_derivable_valid_and_swap_validIn {fc : FrameClass} {φ : StarFormula}
    (d : StarDerivationTree fc [] φ) : StarValidIn fc φ ∧ StarValidIn fc φ.swapTemporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨starAxiom_validIn h_ax h_fc, starAxiom_swap_validIn h_ax h_fc⟩
  | .assumption _ _ h_mem =>
    exact absurd h_mem List.not_mem_nil
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := star_derivable_valid_and_swap_validIn d1
    have h2 := star_derivable_valid_and_swap_validIn d2
    constructor
    · refine StarValidIn.of_forall_total ?_
      intro F hF M τ hτ x v
      exact (StarValidIn.apply_total h1.1 F hF M τ hτ x v)
        (StarValidIn.apply_total h2.1 F hF M τ hτ x v)
    · refine StarValidIn.of_forall_total ?_
      intro F hF M τ hτ x v
      exact (StarValidIn.apply_total h1.2 F hF M τ hτ x v)
        (StarValidIn.apply_total h2.2 F hF M τ hτ x v)
  | .necessitation psi' d' =>
    have h := star_derivable_valid_and_swap_validIn d'
    constructor
    · refine StarValidIn.of_forall_total ?_
      intro F hF M τ _ x v σ hσ
      exact StarValidIn.apply_total h.1 F hF M σ hσ x v
    · refine StarValidIn.of_forall_total ?_
      intro F hF M τ _ x v σ hσ
      exact StarValidIn.apply_total h.2 F hF M σ hσ x v
  | .temporal_necessitation psi' d' =>
    have h := star_derivable_valid_and_swap_validIn d'
    constructor
    · refine StarValidIn.of_forall_total ?_
      intro F hF M τ hτ x v
      rw [StarTruth.allFuture_iff]
      intro s _
      exact StarValidIn.apply_total h.1 F hF M τ hτ s v
    · refine StarValidIn.of_forall_total ?_
      intro F hF M τ hτ x v
      rw [StarFormula.swap_temporal_all_future, StarTruth.allPast_iff]
      intro s _
      exact StarValidIn.apply_total h.2 F hF M τ hτ s v
  | .temporal_duality psi' d' =>
    have h := star_derivable_valid_and_swap_validIn d'
    refine ⟨h.2, ?_⟩
    rw [StarFormula.swap_temporal_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_term := StarDerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact star_derivable_valid_and_swap_validIn (d'.ofWeakeningNil h_sub)
termination_by d.height
decreasing_by
  all_goals first
    | exact StarDerivationTree.mp_height_gt_left _ _
    | exact StarDerivationTree.mp_height_gt_right _ _
    | omega
    | simp only [StarDerivationTree.height]; omega

/-- **Soundness of TM⋆ at `fc`**, empty-context validity form.

Paper: — (formalization-native; the manuscript supplies no proof system for `\BL^\star`)
-/
theorem star_soundness_validIn {fc : FrameClass} {φ : StarFormula}
    (h : StarDerivable fc [] φ) : StarValidIn fc φ :=
  h.elim fun d => (star_derivable_valid_and_swap_validIn d).1

/-! ## The four rows -/

/-- Soundness of TM⋆ at `.Base`: a TM⋆ theorem is `StarValid`. -/
theorem star_soundness_valid {φ : StarFormula} (h : StarDerivable FrameClass.Base [] φ) :
    StarValid φ :=
  star_soundness_validIn h

/-- Soundness of TM⋆ at `.Dense`. -/
theorem star_soundness_dense {φ : StarFormula} (h : StarDerivable FrameClass.Dense [] φ) :
    StarValidIn FrameClass.Dense φ :=
  star_soundness_validIn h

/-- Soundness of TM⋆ at `.ZTime`. -/
theorem star_soundness_ztime {φ : StarFormula} (h : StarDerivable FrameClass.ZTime [] φ) :
    StarValidIn FrameClass.ZTime φ :=
  star_soundness_validIn h

/-- Soundness of TM⋆ at `.RTime`. -/
theorem star_soundness_rtime {φ : StarFormula} (h : StarDerivable FrameClass.RTime [] φ) :
    StarValidIn FrameClass.RTime φ :=
  star_soundness_validIn h

/-! ## Consistency -/

/-- **TM⋆ is consistent at `.Base`**: `⊥` is not a theorem. (Consistency at the wider classes is
not a corollary, since derivability lifts upward; each would need its own witness frame.)
Witness: the trivial frame over `ℤ` with the all-false valuation, at the everywhere-zero register
vector, mirroring the TM⁺ row. -/
theorem star_not_derivable_nil_bot :
    ¬ StarDerivable FrameClass.Base [] StarFormula.bot := by
  intro h
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (FrameOver.trivialFrame (D := ℤ))
  exact (star_soundness_valid h).apply (FrameOver.trivialFrame (D := ℤ))
    TaskModel.allFalse τ.val τ.property 0 (fun _ => 0)

/-! ### Acceptance checks -/

/-- Soundness reaches a register schema: `↓ⁱφ → G↓ⁱφ` is a TM⋆ theorem, hence valid. -/
example (i : ℕ) (φ : StarFormula) :
    StarValid ((StarFormula.timeRecall i φ).imp (StarFormula.allFuture (.timeRecall i φ))) :=
  star_soundness_valid ⟨.axiom [] _ (StarAxiom.recall_rigid_future i φ) le_rfl⟩

/-- And it reaches a formula obtained by `temporal_duality` from one. -/
example (i : ℕ) (φ : StarFormula) :
    StarValid (((StarFormula.timeRecall i φ).imp
      (StarFormula.allFuture (.timeRecall i φ))).swapTemporal) :=
  star_soundness_valid
    ⟨.temporal_duality _ (.axiom [] _ (StarAxiom.recall_rigid_future i φ) le_rfl)⟩

end FormalSystem.Metalogic.Conservativity
