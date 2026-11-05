/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity
import FormalSystem.OpenLanguage

/-!
# Soundness of the L^▷ proof system at every frame class

`⊢^▷[fc] φ ⟹ OpenValidIn fc φ`, for every `fc`, by the same companion recursion TM, TM⁺ and TM⋆
soundness use (`Conservativity/Plus/PlusSoundness.lean`'s
`plus_derivable_valid_and_reflect_time_validIn`,
`Conservativity/Star/StarSoundness.lean`'s `star_derivable_valid_and_reflect_time_validIn`): the
recursion carries **both** `OpenValidIn fc φ` and `OpenValidIn fc φ.reflectTime`, so that the
`time_reflection` case exchanges the two components. The `axiom` case feeds in the two dispatch
lemmas of `Conservativity/Open/OpenAxiomValidity.lean`; everything else is the clause structure of
`OpenTruthAt`.

## Soundness is all this file claims

**No completeness is claimed here, for L^▷, at any frame class, in any form.** Nothing below is
evidence for a completeness statement, and nothing below weakens the canonical-bundle obstruction
that blocks completeness one language down: `FormalSystem/Metalogic/Independence/` keeps
`plus_incomplete_base` exactly as proved, the Burgess-style limit-closure principle stays a
non-theorem, and an LC_n-style schema is still required in L^▷ exactly as it is in L⁺. The
restricted modals `▷` and `◁` supply no closure principle, so they do not touch that obstruction
in either direction.

## Why the three empty-context rules are sound over `▷`/`◁`-containing formulas

`OpenValidIn` quantifies the world history and the time universally, exactly as `PlusValidIn`
does. Both new clauses map a point to a point — `▷φ` and `◁φ` quantify over histories in
`|τ⟩_t` and `⟨τ|_t`, both subsets of `H_F`, at the **same** time — so neither escapes the frame,
and `necessitation`, `temporal_necessitation` and `time_reflection` all preserve validity at a
`▷`/`◁`-containing formula just as they do at a `▷`/`◁`-free one.

The `time_reflection` rule is the one that forces the recursion to be simultaneous rather than
plain: its premise is a theorem and its conclusion is that theorem's time reflection, so the
`φ.reflectTime` component must already be available at every node. That component is what
`openAxiom_reflect_time_validIn_min` exists to supply at the leaves.

## Termination

Well-founded on the derivation's **height**, not structurally: the `weakening` case re-targets
to the empty context through `OpenDerivationTree.ofWeakeningNil` rather than descending
structurally, and `height_ofWeakeningNil_lt` is what makes that step decreasing.

## Main Results

- `open_derivable_valid_and_reflect_time_validIn` — the companion recursion, seven cases, no
  wildcard
- `open_soundness_validIn` — soundness at `fc`, empty-context form
- `open_soundness_in` — soundness at `fc`, context form
- `open_soundness_valid`, `open_soundness_dense`, `open_soundness_ztime`, `open_soundness_rtime`
  — the four class rows
- `open_not_derivable_nil_bot` — the non-triviality row: `⊥` is not an L^▷ theorem at `.Base`

## References

* `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean` — the recursion this one
  transcribes, rule for rule
* `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` — the two dispatch lemmas
  the `axiom` case consumes
* `FormalSystem/OpenLanguage/OpenDerivation.lean` — `OpenDerivationTree`, its seven rules, and
  the height lemmas this recursion's termination argument uses

## Tags

open-language · soundness · proof-system · time-reflection
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## One `reflectTime` push-through lemma

`OpenLanguage/Formula.lean` names five `reflect_time_*` push-through lemmas (`somePast`,
`someFuture`, `dofut`, `dopast`, `dstab`) and not this one, which the `temporal_necessitation`
case's reflection component needs. It holds by `rfl`, like all of them: `allFuture φ` is
`¬F¬φ` and `reflectTime` exchanges `F` with `P`. It is declared here rather than beside
`OpenFormula` so that `OpenLanguage/Formula.lean` and its module invariants stay untouched. -/

/-- `reflectTime` sends `Gφ` to `Hφ.reflectTime`. -/
theorem openReflectTime_allFuture (φ : OpenFormula) :
    (OpenFormula.allFuture φ).reflectTime = OpenFormula.allPast φ.reflectTime := rfl

/-! ## The companion recursion -/

/-- **The companion recursion.** An L^▷ theorem at `fc` is `OpenValidIn fc`, and so is its
temporal dual. Mirror of `star_derivable_valid_and_reflect_time_validIn`, arm for arm; well-founded
on the derivation's height because the `weakening` case re-targets to the empty context without a
structural descent.

Seven cases, one per `OpenDerivationTree` rule, and **no wildcard**: a rule added to
`OpenDerivationTree` without a case here is a build error. -/
theorem open_derivable_valid_and_reflect_time_validIn {fc : FrameClass} {φ : OpenFormula}
    (d : OpenDerivationTree fc [] φ) :
    OpenValidIn fc φ ∧ OpenValidIn fc φ.reflectTime := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨openAxiom_validIn h_ax h_fc, openAxiom_reflect_time_validIn h_ax h_fc⟩
  | .assumption _ _ h_mem =>
    exact absurd h_mem List.not_mem_nil
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := open_derivable_valid_and_reflect_time_validIn d1
    have h2 := open_derivable_valid_and_reflect_time_validIn d2
    constructor
    · intro F hF M τ x
      exact (h1.1 F hF M τ x) (h2.1 F hF M τ x)
    · intro F hF M τ x
      exact (h1.2 F hF M τ x) (h2.2 F hF M τ x)
  | .necessitation psi' d' =>
    have h := open_derivable_valid_and_reflect_time_validIn d'
    constructor
    · intro F hF M τ x σ
      exact h.1 F hF M σ x
    · intro F hF M τ x σ
      exact h.2 F hF M σ x
  | .temporal_necessitation psi' d' =>
    have h := open_derivable_valid_and_reflect_time_validIn d'
    constructor
    · intro F hF M τ x
      rw [openTruth_allFuture_iff]
      intro s _
      exact h.1 F hF M τ s
    · intro F hF M τ x
      rw [openReflectTime_allFuture, openTruth_allPast_iff]
      intro s _
      exact h.2 F hF M τ s
  | .time_reflection psi' d' =>
    have h := open_derivable_valid_and_reflect_time_validIn d'
    refine ⟨h.2, ?_⟩
    rw [OpenFormula.reflect_time_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_term := OpenDerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact open_derivable_valid_and_reflect_time_validIn (d'.ofWeakeningNil h_sub)
termination_by d.height
decreasing_by
  all_goals first
    | exact OpenDerivationTree.mp_height_gt_left _ _
    | exact OpenDerivationTree.mp_height_gt_right _ _
    | omega
    | simp only [OpenDerivationTree.height]; omega

/-! ## Soundness -/

/-- **Soundness of the L^▷ proof system at `fc`**, empty-context validity form.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and supplies no
proof system over them) -/
theorem open_soundness_validIn {fc : FrameClass} {φ : OpenFormula}
    (h : OpenDerivable fc [] φ) : OpenValidIn fc φ :=
  h.elim fun d => (open_derivable_valid_and_reflect_time_validIn d).1

/-- **Soundness of the L^▷ proof system at `fc`**, context form: a derivation of `φ` from `Γ`
makes `φ` true at every model over a frame satisfying `fc`, every world history and every time at
which all of `Γ` is true. Mirror of `plus_soundness_in`; the `time_reflection` case defers to the
companion recursion, since its premise is a theorem rather than a consequence of `Γ`. -/
theorem open_soundness_in {fc : FrameClass} (Γ : OpenContext) (φ : OpenFormula)
    (d : OpenDerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, OpenTruthAt M τ t ψ) :
    OpenTruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    exact openAxiom_validIn h_ax h_fc F hF M τ t
  | assumption Γ' φ' h_in => exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    exact (ih1 τ t h_ctx) (ih2 τ t h_ctx)
  | necessitation φ' _ ih =>
    intro σ
    exact ih σ t (by simp)
  | temporal_necessitation φ' _ ih =>
    rw [openTruth_allFuture_iff]
    intro s _
    exact ih τ s (by simp)
  | time_reflection φ' d' _ih =>
    exact (open_derivable_valid_and_reflect_time_validIn d').2 F hF M τ t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## The four rows -/

/-- Soundness at `.Base`: an L^▷ theorem is `OpenValid`. -/
theorem open_soundness_valid {φ : OpenFormula} (h : OpenDerivable FrameClass.Base [] φ) :
    OpenValid φ :=
  open_soundness_validIn h

/-- Soundness at `.Dense`. -/
theorem open_soundness_dense {φ : OpenFormula} (h : OpenDerivable FrameClass.Dense [] φ) :
    OpenValidIn FrameClass.Dense φ :=
  open_soundness_validIn h

/-- Soundness at `.ZTime`. -/
theorem open_soundness_ztime {φ : OpenFormula} (h : OpenDerivable FrameClass.ZTime [] φ) :
    OpenValidIn FrameClass.ZTime φ :=
  open_soundness_validIn h

/-- Soundness at `.RTime`. -/
theorem open_soundness_rtime {φ : OpenFormula} (h : OpenDerivable FrameClass.RTime [] φ) :
    OpenValidIn FrameClass.RTime φ :=
  open_soundness_validIn h

/-! ## Consistency -/

/-- **The L^▷ proof system is consistent at `.Base`**: `⊥` is not a theorem. (Consistency at the
wider classes is not a corollary, since derivability lifts upward; each would need its own witness
frame.) Witness: the trivial frame over `ℤ` with the all-false valuation, mirroring the TM⁺ and
TM⋆ rows. -/
theorem open_not_derivable_nil_bot :
    ¬ OpenDerivable FrameClass.Base [] OpenFormula.bot := by
  intro h
  obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (FrameOver.trivialFrame (D := ℤ))
  exact (open_soundness_valid h).apply (FrameOver.trivialFrame (D := ℤ))
    TaskModel.allFalse τ 0

/-! ### Acceptance checks -/

/-- Soundness reaches a restricted-modal schema: `▷φ → φ` is an L^▷ theorem, hence valid. -/
example (φ : OpenFormula) :
    OpenValid ((OpenFormula.ofut φ).imp φ) :=
  open_soundness_valid ⟨.axiom [] _ (OpenAxiom.ofut_t φ) le_rfl⟩

/-- And it reaches a formula obtained by `time_reflection` from one: the reflection of `▷`-T is
`◁`-T at the reflected parameter. -/
example (φ : OpenFormula) :
    OpenValid (((OpenFormula.ofut φ).imp φ).reflectTime) :=
  open_soundness_valid ⟨.time_reflection _ (.axiom [] _ (OpenAxiom.ofut_t φ) le_rfl)⟩

/-- Soundness reaches a class-restricted schema at its own class: density at `.Dense`. -/
example (φ : OpenFormula) :
    OpenValidIn FrameClass.Dense (φ.allFuture.allFuture.imp φ.allFuture) :=
  open_soundness_dense ⟨.axiom [] _ (OpenAxiom.density φ) le_rfl⟩

end FormalSystem.Metalogic.Conservativity
