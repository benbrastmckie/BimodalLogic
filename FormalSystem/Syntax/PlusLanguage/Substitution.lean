/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.PlusLanguage.Derivation

/-!
# `substPlus` — carrying TM theorem *schemata* into TM⁺ at arbitrary L⁺ arguments

The embedding `PlusDerivationTree.ofTM` (`PlusLanguage/Derivation.lean`) transfers a TM
derivation of `φ` to a TM⁺ derivation of `ofFormula φ`, and therefore only ever produces
`⊡`-free conclusions. That is the wrong shape for the derived reasoning TM⁺ actually needs: a
propositional theorem of TM, say `⊢ (φ ↔ ψ) → ((φ → χ) ↔ (ψ → χ))`, is wanted **at `PlusFormula`
arguments containing `⊡`**, and no amount of `ofTM` supplies it.

This module supplies it. `substPlus σ` interprets an L formula in L⁺ by replacing each atom `p`
with `σ p : PlusFormula`, structurally; `ofFormula` is the special case `σ = PlusFormula.atom`
(`substPlus_atom`). The transfer `plusDerivable_substPlus` then reads:

```
TM ⊢[fc] φ   ⟹   TM⁺ ⊢[fc] substPlus σ φ,   for every σ, frame class and context.
```

Instantiating a TM theorem at distinct atoms and then substituting is therefore a general
mechanism for importing **every** TM schema at arbitrary L⁺ arguments — which is exactly the
lever the deterministic collapse (`Metalogic/Deterministic/Collapse.lean`) needs, and the one
missing piece for reasoning inside TM⁺ without rebuilding a `Theorems/` layer over
`PlusFormula`.

## Main Definitions

- `substPlus : (Atom → PlusFormula) → Formula → PlusFormula`
- `substCtxPlus` — the context-level form

## Main Results

- `substPlus_atom` — `substPlus PlusFormula.atom = ofFormula`
- `substPlus_swapTemporal` — the swap interaction, at the *shifted* substitution
  `swapTemporal ∘ σ`; this is what makes the `temporal_duality` case of the transfer close
- `PlusAxiom.ofTMSubst` — every TM axiom instance is a TM⁺ axiom instance under `substPlus σ`
- `PlusDerivationTree.ofTMSubst`, `plusDerivable_substPlus` — the transfer

## Why the substitution must vary along the recursion

`temporal_duality` concludes `⊢ φ.swapTemporal` from `⊢ φ`. Under `substPlus σ` the target is
`substPlus σ φ.swapTemporal`, which is **not** `(substPlus σ φ).swapTemporal` — the two differ
exactly at the atoms, where the first leaves `σ p` alone and the second reverses it. The
identity that does hold is `substPlus_swapTemporal`, which repairs the mismatch by running the
recursive call at `fun p => (σ p).swapTemporal` instead. So the recursion is over derivations
*and* substitutions jointly, and `σ` is an explicit argument rather than a section variable.

## Uniform substitution is a syntactic transfer, not a semantic principle

Nothing here says that a valid schema stays valid under substitution — that is **false** in this
setting (`Metalogic/Independence/DeterminismUndefinable.lean`: `p → ⊡p` is `F°`-valid while
`Fp → ⊡Fp` is refutable). What is proved is the purely proof-theoretic statement that
*derivability* is closed under substitution, which follows from the axioms being schemata. No
proof in this development argues from validity by substitution, and none may.

## Module Invariant

Nothing under `FormalSystem/PlusLanguage/` imports anything from `FormalSystem/Semantics/`;
this module keeps that invariant.

## References

* `FormalSystem/PlusLanguage/Derivation.lean` — `PlusAxiom.ofTM`, the `σ = atom` special case
* `FormalSystem/ProofSystem/Axioms.lean` — the 45 TM schemata whose arms are mirrored here

## Tags

substitution · plus-language · proof-system · conservativity
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass Axiom DerivationTree)

/-! ## The substitution -/

/-- Interpret an L formula in L⁺ by replacing each atom `p` with `σ p`. Structural on the six
`Formula` constructors; `ofFormula` is the case `σ = PlusFormula.atom`. -/
def substPlus (σ : Atom → PlusFormula) : Formula → PlusFormula
  | .atom p => σ p
  | .bot => .bot
  | .imp φ ψ => .imp (substPlus σ φ) (substPlus σ ψ)
  | .box φ => .box (substPlus σ φ)
  | .untl ψ φ => .untl (substPlus σ ψ) (substPlus σ φ)
  | .snce ψ φ => .snce (substPlus σ ψ) (substPlus σ φ)

/-- The context-level form. Definitionally `List.map (substPlus σ)`. -/
abbrev substCtxPlus (σ : Atom → PlusFormula) (Γ : Context) : PlusContext :=
  List.map (substPlus σ) Γ

/-- `ofFormula` is `substPlus` at the identity substitution. -/
theorem substPlus_atom (φ : Formula) : substPlus PlusFormula.atom φ = ofFormula φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [substPlus, ofFormula, ih1, ih2]
  | box _ ih => simp only [substPlus, ofFormula, ih]
  | untl _ _ ih1 ih2 => simp only [substPlus, ofFormula, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [substPlus, ofFormula, ih1, ih2]

/-! ### Push-through pins

Every derived L⁺ operator carries `Formula`'s right-hand side verbatim, so `substPlus σ`
commutes with each of them definitionally. These pins are what makes every arm of
`PlusAxiom.ofTMSubst` below `rfl`-shaped. -/

example (σ : Atom → PlusFormula) : substPlus σ Formula.top = PlusFormula.top := rfl
example (σ : Atom → PlusFormula) (φ : Formula) :
    substPlus σ φ.neg = (substPlus σ φ).neg := rfl
example (σ : Atom → PlusFormula) (φ ψ : Formula) :
    substPlus σ (φ.and ψ) = (substPlus σ φ).and (substPlus σ ψ) := rfl
example (σ : Atom → PlusFormula) (φ : Formula) :
    substPlus σ (Formula.allFuture φ) = PlusFormula.allFuture (substPlus σ φ) := rfl
example (σ : Atom → PlusFormula) (φ : Formula) :
    substPlus σ (Formula.kPlus φ) = PlusFormula.kPlus (substPlus σ φ) := rfl

/-! ## The swap interaction -/

/--
**Substitution and temporal duality commute after shifting the substitution.**

`substPlus σ` and `swapTemporal` do not commute on the nose: at an atom the left side yields
`σ p` and the right side `(σ p).swapTemporal`. Running the substitution at
`fun p => (σ p).swapTemporal` repairs it, the atom case closing by `swap_temporal_involution`.
-/
theorem substPlus_swapTemporal (σ : Atom → PlusFormula) (φ : Formula) :
    substPlus σ φ.swapTemporal
      = (substPlus (fun p => (σ p).swapTemporal) φ).swapTemporal := by
  induction φ with
  | atom p => exact (PlusFormula.swap_temporal_involution (σ p)).symm
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp only [Formula.swapTemporal, substPlus, PlusFormula.swapTemporal, ih1, ih2]
  | box _ ih => simp only [Formula.swapTemporal, substPlus, PlusFormula.swapTemporal, ih]
  | untl _ _ ih1 ih2 =>
    simp only [Formula.swapTemporal, substPlus, PlusFormula.swapTemporal, ih1, ih2]
  | snce _ _ ih1 ih2 =>
    simp only [Formula.swapTemporal, substPlus, PlusFormula.swapTemporal, ih1, ih2]

/-! ## The axiom transfer -/

/--
Every TM axiom instance is a TM⁺ axiom instance under `substPlus σ`. Each arm is `rfl`-shaped for
the same reason `PlusAxiom.ofTM`'s is: the schema's statement is built from its parameters by the
shared operator vocabulary, and `substPlus σ` pushes through every one of those operators
definitionally. Any drift between `Axiom` and `PlusAxiom` fails to typecheck here.
-/
def PlusAxiom.ofTMSubst (σ : Atom → PlusFormula) : {φ : Formula} → Axiom φ →
    PlusAxiom (substPlus σ φ)
  | _, .prop_k φ ψ χ => .prop_k (substPlus σ φ) (substPlus σ ψ) (substPlus σ χ)
  | _, .prop_s φ ψ => .prop_s (substPlus σ φ) (substPlus σ ψ)
  | _, .ex_falso φ => .ex_falso (substPlus σ φ)
  | _, .peirce φ ψ => .peirce (substPlus σ φ) (substPlus σ ψ)
  | _, .modal_t φ => .modal_t (substPlus σ φ)
  | _, .modal_4 φ => .modal_4 (substPlus σ φ)
  | _, .modal_b φ => .modal_b (substPlus σ φ)
  | _, .modal_5_collapse φ => .modal_5_collapse (substPlus σ φ)
  | _, .modal_k_dist φ ψ => .modal_k_dist (substPlus σ φ) (substPlus σ ψ)
  | _, .serial_future => .serial_future
  | _, .serial_past => .serial_past
  | _, .left_mono_until_G φ χ ψ =>
      .left_mono_until_G (substPlus σ φ) (substPlus σ χ) (substPlus σ ψ)
  | _, .left_mono_since_H φ χ ψ =>
      .left_mono_since_H (substPlus σ φ) (substPlus σ χ) (substPlus σ ψ)
  | _, .right_mono_until φ ψ χ =>
      .right_mono_until (substPlus σ φ) (substPlus σ ψ) (substPlus σ χ)
  | _, .right_mono_since φ ψ χ =>
      .right_mono_since (substPlus σ φ) (substPlus σ ψ) (substPlus σ χ)
  | _, .connect_future φ => .connect_future (substPlus σ φ)
  | _, .connect_past φ => .connect_past (substPlus σ φ)
  | _, .enrichment_until φ ψ p =>
      .enrichment_until (substPlus σ φ) (substPlus σ ψ) (substPlus σ p)
  | _, .enrichment_since φ ψ p =>
      .enrichment_since (substPlus σ φ) (substPlus σ ψ) (substPlus σ p)
  | _, .self_accum_until φ ψ => .self_accum_until (substPlus σ φ) (substPlus σ ψ)
  | _, .self_accum_since φ ψ => .self_accum_since (substPlus σ φ) (substPlus σ ψ)
  | _, .absorb_until φ ψ => .absorb_until (substPlus σ φ) (substPlus σ ψ)
  | _, .absorb_since φ ψ => .absorb_since (substPlus σ φ) (substPlus σ ψ)
  | _, .linear_until φ ψ χ θ =>
      .linear_until (substPlus σ φ) (substPlus σ ψ) (substPlus σ χ) (substPlus σ θ)
  | _, .linear_since φ ψ χ θ =>
      .linear_since (substPlus σ φ) (substPlus σ ψ) (substPlus σ χ) (substPlus σ θ)
  | _, .until_F φ ψ => .until_F (substPlus σ φ) (substPlus σ ψ)
  | _, .since_P φ ψ => .since_P (substPlus σ φ) (substPlus σ ψ)
  | _, .temp_linearity φ ψ => .temp_linearity (substPlus σ φ) (substPlus σ ψ)
  | _, .temp_linearity_past φ ψ => .temp_linearity_past (substPlus σ φ) (substPlus σ ψ)
  | _, .F_until_equiv φ => .F_until_equiv (substPlus σ φ)
  | _, .P_since_equiv φ => .P_since_equiv (substPlus σ φ)
  | _, .modal_future φ => .modal_future (substPlus σ φ)
  | _, .discrete_symm_fwd => .discrete_symm_fwd
  | _, .discrete_symm_bwd => .discrete_symm_bwd
  | _, .discrete_propagate_fwd => .discrete_propagate_fwd
  | _, .discrete_propagate_bwd => .discrete_propagate_bwd
  | _, .discrete_box_necessity => .discrete_box_necessity
  | _, .prior_UZ φ => .prior_UZ (substPlus σ φ)
  | _, .prior_SZ φ => .prior_SZ (substPlus σ φ)
  | _, .z1 φ => .z1 (substPlus σ φ)
  | _, .density φ => .density (substPlus σ φ)
  | _, .dense_indicator => .dense_indicator
  | _, .prior_U_gap φ => .prior_U_gap (substPlus σ φ)
  | _, .prior_S_gap φ => .prior_S_gap (substPlus σ φ)
  | _, .sep φ => .sep (substPlus σ φ)

/-- Substitution preserves the minimum frame class: the routing depends on the constructor
alone. -/
theorem PlusAxiom.minFrameClass_ofTMSubst (σ : Atom → PlusFormula) {φ : Formula} (ax : Axiom φ) :
    (PlusAxiom.ofTMSubst σ ax).minFrameClass = ax.minFrameClass := by
  cases ax <;> rfl

/-! ## The derivation transfer -/

/--
**The substitution transfer.** Every TM derivation becomes a TM⁺ derivation of the substituted
conclusion over the substituted context, at the same frame class.

Seven cases, one per rule. The `axiom` case is `PlusAxiom.ofTMSubst`; the `temporal_duality` case
recurses at the *shifted* substitution `fun p => (σ p).swapTemporal` and transports along
`substPlus_swapTemporal`; the rest are structural. `ofTM` is the special case `σ =
PlusFormula.atom` (`substPlus_atom`).
-/
def PlusDerivationTree.ofTMSubst {fc : FrameClass} (σ : Atom → PlusFormula) :
    {Γ : Context} → {φ : Formula} → DerivationTree fc Γ φ →
      PlusDerivationTree fc (substCtxPlus σ Γ) (substPlus σ φ)
  | _, _, .axiom _ _ h h_fc =>
      .axiom _ _ (PlusAxiom.ofTMSubst σ h)
        (by rw [PlusAxiom.minFrameClass_ofTMSubst]; exact h_fc)
  | _, _, .assumption _ _ h => .assumption _ _ (List.mem_map_of_mem h)
  | _, _, .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (substPlus σ φ) (substPlus σ ψ) (ofTMSubst σ d1) (ofTMSubst σ d2)
  | _, _, .necessitation φ d => .necessitation (substPlus σ φ) (ofTMSubst σ d)
  | _, _, .temporal_necessitation φ d => .temporal_necessitation (substPlus σ φ) (ofTMSubst σ d)
  | _, _, .temporal_duality φ d =>
      (substPlus_swapTemporal σ φ).symm ▸
        PlusDerivationTree.temporal_duality (substPlus (fun p => (σ p).swapTemporal) φ)
          (ofTMSubst (fun p => (σ p).swapTemporal) d)
  | _, _, .weakening _ _ _ d h =>
      .weakening _ _ _ (ofTMSubst σ d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/-- **The substitution transfer, `Prop`-level.** -/
theorem plusDerivable_substPlus {fc : FrameClass} {Γ : Context} {φ : Formula}
    (σ : Atom → PlusFormula) (h : ProofSystem.Derivable fc Γ φ) :
    PlusDerivable fc (substCtxPlus σ Γ) (substPlus σ φ) :=
  h.elim fun d => ⟨PlusDerivationTree.ofTMSubst σ d⟩

/-- The transfer at the empty context, the shape every consumer uses: a TM **theorem** becomes a
TM⁺ theorem at arbitrary L⁺ arguments. -/
theorem plusDerivable_substPlus_nil {fc : FrameClass} {φ : Formula} (σ : Atom → PlusFormula)
    (h : ProofSystem.Derivable fc [] φ) : PlusDerivable fc [] (substPlus σ φ) :=
  plusDerivable_substPlus σ h

end FormalSystem.PlusLanguage
