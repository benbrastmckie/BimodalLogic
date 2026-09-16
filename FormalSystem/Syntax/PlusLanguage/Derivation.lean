/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.PlusLanguage.Axioms
import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Derivable

/-!
# `PlusDerivationTree` — TM⁺'s proof system, and backward conservativity over TM

A constructor-for-constructor mirror of `FormalSystem.ProofSystem.DerivationTree` over
`PlusFormula`, with `PlusAxiom` in the `axiom` rule. The mirror is deliberate: it is what makes
the embedding `PlusDerivationTree.ofTM` a seven-case structural recursion with one case per
rule, and what lets the soundness companion recursion
(`Metalogic/Conservativity/Plus/PlusSoundness.lean`) transcribe TM's arm for arm.

## Inference rules (7, matching TM exactly)

1. `axiom` — a `PlusAxiom` instance, gated by `ax.minFrameClass ≤ fc`
2. `assumption`
3. `modus_ponens`
4. `necessitation` — `⊢ φ ⟹ ⊢ □φ`, empty context only
5. `temporal_necessitation` — `⊢ φ ⟹ ⊢ Gφ`, empty context only
6. `temporal_duality` — `⊢ φ ⟹ ⊢ swapTemporal φ`, empty context only
7. `weakening`

**There is no `⊡`-necessitation rule.** `⊢ φ ⟹ ⊢ ⊡φ` is derivable — `necessitation` gives
`⊢ □φ`, then `box_stab` (`□φ → ⊡φ`) and modus ponens — and is provided as
`stabNecessitation` below. Adding it as an eighth constructor would break the exact seven-rule
mirror that `ofTM` and the soundness recursion rely on.

## Backward conservativity

`PlusAxiom.ofTM` sends every TM axiom instance to its re-declared TM⁺ twin at the embedded
parameters; each of its 45 arms is `rfl`-shaped because the derived operators of
`PlusLanguage/Formula.lean` carry `Formula`'s right-hand sides verbatim, and
`minFrameClass_ofTM` records that the frame class is preserved. `PlusDerivationTree.ofTM`
then lifts derivations, and `plusDerivable_of_derivable` is the `Prop`-level statement:

```
TM ⊢[fc] φ  ⟹  TM⁺ ⊢[fc] ofFormula φ,   at every frame class and every context.
```

Unlike the base-language bridge (`Metalogic/Conservativity/Backward.lean`), no axiom-discharge
table is needed: the embedding is constructor-to-constructor, so the `axiom` case is one line.
The **forward** direction — `TM⁺ ⊢ ofFormula φ ⟹ TM ⊢ φ` — is proved semantically in
`Metalogic/Conservativity/Plus/Forward.lean` from TM⁺ soundness and the TM completeness
engines; it needs no TM⁺ completeness.

## Notation

`Γ ⊢⁺[fc] φ` and `⊢⁺[fc] φ`, distinct from TM's `⊢[fc]` and TM's `⊢⁻[fc]`.

## References

* `FormalSystem/ProofSystem/Derivation.lean` — the TM counterpart being mirrored
* `FormalSystem/MinusLanguage/Derivation.lean` — the base-language mirror, the same shape
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass Axiom DerivationTree)

/--
Derivation tree for TM⁺, parameterized by frame class. `Type`-valued, like its TM counterpart,
so that the soundness recursion can match on it and `height` is computable.
-/
inductive PlusDerivationTree (fc : FrameClass) : PlusContext → PlusFormula → Type where
  /-- Axiom rule, gated by `h.minFrameClass ≤ fc`. -/
  | axiom (Γ : PlusContext) (φ : PlusFormula) (h : PlusAxiom φ) (h_fc : h.minFrameClass ≤ fc)
      : PlusDerivationTree fc Γ φ
  /-- Assumption rule: formulas in the context are derivable. -/
  | assumption (Γ : PlusContext) (φ : PlusFormula) (h : φ ∈ Γ) : PlusDerivationTree fc Γ φ
  /-- Modus ponens. -/
  | modus_ponens (Γ : PlusContext) (φ ψ : PlusFormula)
      (d1 : PlusDerivationTree fc Γ (φ.imp ψ))
      (d2 : PlusDerivationTree fc Γ φ) : PlusDerivationTree fc Γ ψ
  /-- Necessitation: from `⊢ φ`, conclude `⊢ □φ`. Theorems only. -/
  | necessitation (φ : PlusFormula)
      (d : PlusDerivationTree fc [] φ) : PlusDerivationTree fc [] (PlusFormula.box φ)
  /-- Temporal necessitation: from `⊢ φ`, conclude `⊢ Gφ`. Theorems only. -/
  | temporal_necessitation (φ : PlusFormula)
      (d : PlusDerivationTree fc [] φ) : PlusDerivationTree fc [] (PlusFormula.allFuture φ)
  /-- Temporal duality: from `⊢ φ`, conclude `⊢ swapTemporal φ`. Theorems only. -/
  | temporal_duality (φ : PlusFormula)
      (d : PlusDerivationTree fc [] φ) : PlusDerivationTree fc [] φ.swapTemporal
  /-- Weakening: from `Γ ⊢ φ` and `Γ ⊆ Δ`, conclude `Δ ⊢ φ`. -/
  | weakening (Γ Δ : PlusContext) (φ : PlusFormula)
      (d : PlusDerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : PlusDerivationTree fc Δ φ

namespace PlusDerivationTree

/-- Lift a derivation from `fc₁` to `fc₂` when `fc₁ ≤ fc₂`. Mirrors
`ProofSystem.DerivationTree.lift`. -/
def lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {Γ : PlusContext} {φ : PlusFormula} : PlusDerivationTree fc₁ Γ φ → PlusDerivationTree fc₂ Γ φ
  | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
  | .assumption Γ φ h => .assumption Γ φ h
  | .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
  | .necessitation φ d => .necessitation φ (d.lift h_le)
  | .temporal_necessitation φ d => .temporal_necessitation φ (d.lift h_le)
  | .temporal_duality φ d => .temporal_duality φ (d.lift h_le)
  | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h

/-- Height of a derivation, mirroring `ProofSystem.DerivationTree.height`. -/
def height {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula} :
    PlusDerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

/-- Re-target a derivation whose context is a subset of the empty context. Mirror of
`ProofSystem.DerivationTree.ofWeakeningNil`. -/
def ofWeakeningNil {fc : FrameClass} {Γ' : PlusContext} {φ : PlusFormula}
    (d : PlusDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : PlusContext)) :
    PlusDerivationTree fc [] φ :=
  (List.eq_nil_of_subset_nil h_sub) ▸ d

/-- `ofWeakeningNil` preserves height exactly. -/
@[simp] theorem height_ofWeakeningNil {fc : FrameClass} {Γ' : PlusContext} {φ : PlusFormula}
    (d : PlusDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : PlusContext)) :
    (d.ofWeakeningNil h_sub).height = d.height := by
  have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
  subst h_eq
  rfl

/-- Transporting to the empty context is strictly cheaper than the `weakening` node. -/
theorem height_ofWeakeningNil_lt {fc : FrameClass} {Γ' : PlusContext} {φ : PlusFormula}
    (d : PlusDerivationTree fc Γ' φ) (h_sub : Γ' ⊆ ([] : PlusContext)) :
    (d.ofWeakeningNil h_sub).height <
      (PlusDerivationTree.weakening Γ' ([] : PlusContext) φ d h_sub).height := by
  simp only [PlusDerivationTree.height_ofWeakeningNil, PlusDerivationTree.height]
  omega

/-- Modus ponens height is strictly greater than the left subderivation. -/
theorem mp_height_gt_left {fc : FrameClass} {Γ : PlusContext} {φ ψ : PlusFormula}
    (d1 : PlusDerivationTree fc Γ (φ.imp ψ)) (d2 : PlusDerivationTree fc Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/-- Modus ponens height is strictly greater than the right subderivation. -/
theorem mp_height_gt_right {fc : FrameClass} {Γ : PlusContext} {φ ψ : PlusFormula}
    (d1 : PlusDerivationTree fc Γ (φ.imp ψ)) (d2 : PlusDerivationTree fc Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

end PlusDerivationTree

/-- Prop-valued derivability in TM⁺, mirroring `ProofSystem.Derivable`. -/
def PlusDerivable (fc : FrameClass) (Γ : PlusContext) (φ : PlusFormula) : Prop :=
  Nonempty (PlusDerivationTree fc Γ φ)

/-- Derivability in TM⁺ from context `Γ` at frame class `fc`. -/
notation:50 Γ " ⊢⁺[" fc "] " φ => PlusDerivationTree fc Γ φ

/-- Theoremhood in TM⁺ at frame class `fc`. -/
notation:50 "⊢⁺[" fc "] " φ => PlusDerivationTree fc [] φ

/-- `PlusDerivable` is monotone in the frame class. -/
theorem PlusDerivable.mono {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {Γ : PlusContext}
    {φ : PlusFormula} (hd : PlusDerivable fc₁ Γ φ) : PlusDerivable fc₂ Γ φ :=
  hd.elim fun d => ⟨d.lift h⟩

/-! ## The derived `⊡`-necessitation rule -/

/-- **`⊡`-necessitation is derived**: `⊢ φ ⟹ ⊢ ⊡φ`, by `necessitation` to `⊢ □φ` and then
`box_stab` (`□φ → ⊡φ`). This is why `PlusDerivationTree` carries no `⊡` rule of its own. -/
def stabNecessitation {fc : FrameClass} {φ : PlusFormula}
    (d : ⊢⁺[fc] φ) : ⊢⁺[fc] PlusFormula.stab φ :=
  .modus_ponens [] _ _
    (.axiom [] _ (PlusAxiom.box_stab φ) (FrameClass.base_le fc))
    (.necessitation φ d)

/-! ## Backward conservativity: TM derivations embed into TM⁺ -/

/--
Every TM axiom instance is a TM⁺ axiom instance under the embedding. Each arm is
`rfl`-shaped: `ofFormula` commutes definitionally with every derived operator, so the embedded
schema instance **is** the re-declared constructor at the embedded parameters. Any drift between
`Axiom` and `PlusAxiom` fails to typecheck here.
-/
def PlusAxiom.ofTM : {φ : Formula} → Axiom φ → PlusAxiom (ofFormula φ)
  | _, .prop_k φ ψ χ => .prop_k (ofFormula φ) (ofFormula ψ) (ofFormula χ)
  | _, .prop_s φ ψ => .prop_s (ofFormula φ) (ofFormula ψ)
  | _, .ex_falso φ => .ex_falso (ofFormula φ)
  | _, .peirce φ ψ => .peirce (ofFormula φ) (ofFormula ψ)
  | _, .modal_t φ => .modal_t (ofFormula φ)
  | _, .modal_4 φ => .modal_4 (ofFormula φ)
  | _, .modal_b φ => .modal_b (ofFormula φ)
  | _, .modal_5_collapse φ => .modal_5_collapse (ofFormula φ)
  | _, .modal_k_dist φ ψ => .modal_k_dist (ofFormula φ) (ofFormula ψ)
  | _, .serial_future => .serial_future
  | _, .serial_past => .serial_past
  | _, .left_mono_until_G φ χ ψ => .left_mono_until_G (ofFormula φ) (ofFormula χ) (ofFormula ψ)
  | _, .left_mono_since_H φ χ ψ => .left_mono_since_H (ofFormula φ) (ofFormula χ) (ofFormula ψ)
  | _, .right_mono_until φ ψ χ => .right_mono_until (ofFormula φ) (ofFormula ψ) (ofFormula χ)
  | _, .right_mono_since φ ψ χ => .right_mono_since (ofFormula φ) (ofFormula ψ) (ofFormula χ)
  | _, .connect_future φ => .connect_future (ofFormula φ)
  | _, .connect_past φ => .connect_past (ofFormula φ)
  | _, .enrichment_until φ ψ p => .enrichment_until (ofFormula φ) (ofFormula ψ) (ofFormula p)
  | _, .enrichment_since φ ψ p => .enrichment_since (ofFormula φ) (ofFormula ψ) (ofFormula p)
  | _, .self_accum_until φ ψ => .self_accum_until (ofFormula φ) (ofFormula ψ)
  | _, .self_accum_since φ ψ => .self_accum_since (ofFormula φ) (ofFormula ψ)
  | _, .absorb_until φ ψ => .absorb_until (ofFormula φ) (ofFormula ψ)
  | _, .absorb_since φ ψ => .absorb_since (ofFormula φ) (ofFormula ψ)
  | _, .linear_until φ ψ χ θ =>
      .linear_until (ofFormula φ) (ofFormula ψ) (ofFormula χ) (ofFormula θ)
  | _, .linear_since φ ψ χ θ =>
      .linear_since (ofFormula φ) (ofFormula ψ) (ofFormula χ) (ofFormula θ)
  | _, .until_F φ ψ => .until_F (ofFormula φ) (ofFormula ψ)
  | _, .since_P φ ψ => .since_P (ofFormula φ) (ofFormula ψ)
  | _, .temp_linearity φ ψ => .temp_linearity (ofFormula φ) (ofFormula ψ)
  | _, .temp_linearity_past φ ψ => .temp_linearity_past (ofFormula φ) (ofFormula ψ)
  | _, .F_until_equiv φ => .F_until_equiv (ofFormula φ)
  | _, .P_since_equiv φ => .P_since_equiv (ofFormula φ)
  | _, .modal_future φ => .modal_future (ofFormula φ)
  | _, .discrete_symm_fwd => .discrete_symm_fwd
  | _, .discrete_symm_bwd => .discrete_symm_bwd
  | _, .discrete_propagate_fwd => .discrete_propagate_fwd
  | _, .discrete_propagate_bwd => .discrete_propagate_bwd
  | _, .discrete_box_necessity => .discrete_box_necessity
  | _, .prior_UZ φ => .prior_UZ (ofFormula φ)
  | _, .prior_SZ φ => .prior_SZ (ofFormula φ)
  | _, .z1 φ => .z1 (ofFormula φ)
  | _, .density φ => .density (ofFormula φ)
  | _, .dense_indicator => .dense_indicator
  | _, .prior_U_gap φ => .prior_U_gap (ofFormula φ)
  | _, .prior_S_gap φ => .prior_S_gap (ofFormula φ)
  | _, .sep φ => .sep (ofFormula φ)

/-- The embedding preserves the minimum frame class. -/
theorem PlusAxiom.minFrameClass_ofTM {φ : Formula} (ax : Axiom φ) :
    (PlusAxiom.ofTM ax).minFrameClass = ax.minFrameClass := by
  cases ax <;> rfl

/--
**The backward conservativity bridge.** Every TM derivation becomes a TM⁺ derivation of its
embedding, at the same frame class and over the embedded context. Seven cases, one per rule; the
`axiom` case is `PlusAxiom.ofTM`, the `temporal_duality` case transports along
`ofFormula_swapTemporal`, and the rest are structural.
-/
def PlusDerivationTree.ofTM {fc : FrameClass} {Γ : Context} {φ : Formula} :
    DerivationTree fc Γ φ → PlusDerivationTree fc (ofCtx Γ) (ofFormula φ)
  | .axiom _ _ h h_fc =>
      .axiom _ _ (PlusAxiom.ofTM h) (by rw [PlusAxiom.minFrameClass_ofTM]; exact h_fc)
  | .assumption _ _ h => .assumption _ _ (mem_ofCtx h)
  | .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (ofFormula φ) (ofFormula ψ) (ofTM d1) (ofTM d2)
  | .necessitation φ d => .necessitation (ofFormula φ) (ofTM d)
  | .temporal_necessitation φ d => .temporal_necessitation (ofFormula φ) (ofTM d)
  | .temporal_duality φ d =>
      (ofFormula_swapTemporal φ).symm ▸
        PlusDerivationTree.temporal_duality (ofFormula φ) (ofTM d)
  | .weakening _ _ _ d h =>
      .weakening _ _ _ (ofTM d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/-- **Backward conservativity, `Prop`-level**: `TM ⊢[fc] φ ⟹ TM⁺ ⊢[fc] ofFormula φ`, at every
frame class and context. -/
theorem plusDerivable_of_derivable {fc : FrameClass} {Γ : Context} {φ : Formula}
    (h : ProofSystem.Derivable fc Γ φ) : PlusDerivable fc (ofCtx Γ) (ofFormula φ) :=
  h.elim fun d => ⟨PlusDerivationTree.ofTM d⟩

/-! ### The four rows at the empty context -/

/-- Backward conservativity at `.Base`. -/
theorem plus_backward_base {φ : Formula} (h : ProofSystem.Derivable FrameClass.Base [] φ) :
    PlusDerivable FrameClass.Base [] (ofFormula φ) :=
  plusDerivable_of_derivable h

/-- Backward conservativity at `.Dense`. -/
theorem plus_backward_dense {φ : Formula} (h : ProofSystem.Derivable FrameClass.Dense [] φ) :
    PlusDerivable FrameClass.Dense [] (ofFormula φ) :=
  plusDerivable_of_derivable h

/-- Backward conservativity at `.ZTime`. -/
theorem plus_backward_ztime {φ : Formula}
    (h : ProofSystem.Derivable FrameClass.ZTime [] φ) :
    PlusDerivable FrameClass.ZTime [] (ofFormula φ) :=
  plusDerivable_of_derivable h

/-- Backward conservativity at `.RTime`. -/
theorem plus_backward_rtime {φ : Formula}
    (h : ProofSystem.Derivable FrameClass.RTime [] φ) :
    PlusDerivable FrameClass.RTime [] (ofFormula φ) :=
  plusDerivable_of_derivable h

/-! ### Smoke tests -/

/-- MF at a `⊡`-formula is an axiom instance of TM⁺ — the instance `ofTM` alone could not
supply. -/
example (p : Atom) :
    ⊢⁺[FrameClass.Base] (PlusFormula.box (PlusFormula.stab (PlusFormula.atom p))).imp
      (PlusFormula.box (PlusFormula.allFuture (PlusFormula.stab (PlusFormula.atom p)))) :=
  .axiom [] _ (PlusAxiom.modal_future _) (FrameClass.base_le _)

/-- The `⊡` T-axiom is a theorem at every class. -/
example (fc : FrameClass) (φ : PlusFormula) : ⊢⁺[fc] (PlusFormula.stab φ).imp φ :=
  .axiom [] _ (PlusAxiom.stab_t φ) (FrameClass.base_le fc)

end FormalSystem.PlusLanguage
