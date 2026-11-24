/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation

/-!
# `substF` — uniform substitution inside L, as data

`FormalSystem/PlusLanguage/Substitution.lean` carries a TM derivation into TM⁺ under a
substitution `Atom → PlusFormula`. This module is its mirror one language down: the
substitution stays inside L, so `substF σ : Formula → Formula` and the transfer takes a TM
derivation to a TM derivation.

The L-level form is what a *theorem library* needs. A library row is schematic by construction —
`TheoremEntry.proof` has the shape `∀ fc, frameClass ≤ fc → ∀ v, DerivationTree fc [] (stmt v)`
— while a tableau extracts a derivation of one **concrete** formula, with concrete atoms. The
bridge between the two is exactly `DerivationTree.substNil`: instantiate the schema's variables
at the concrete atoms, derive, then push the derivation back along the substitution that sends
those atoms to the schema's variables.

The L⁺ route cannot serve here. `plusDerivable_substPlus_nil` lands in
`PlusDerivable = Nonempty (PlusDerivationTree …)`, a `Prop`, while `TheoremEntry.proof` is
`Type`-valued and the registry compiles the row. So the transfer has to be data, not a
propositional existence claim, which is why `DerivationTree.subst` is a `def` returning a tree
rather than a `theorem` returning `Derivable`.

## Main Definitions

- `substF : (Atom → Formula) → Formula → Formula`
- `substCtxF` — the context-level form

## Main Results

- `substF_atom` — `substF Formula.atom` is the identity
- `substF_reflectTime` — the reflection interaction, at the *shifted* substitution
  `reflectTime ∘ σ`; this is what makes the `time_reflection` case of the transfer close
- `Axiom.ofSubst` — every TM axiom instance is a TM axiom instance under `substF σ`
- `Axiom.minFrameClass_ofSubst` — substitution preserves the minimum frame class
- `DerivationTree.subst`, `DerivationTree.substNil` — the transfer, and its empty-context form

## Why the substitution must vary along the recursion

`time_reflection` concludes `⊢ φ.reflectTime` from `⊢ φ`. Under `substF σ` the target is
`substF σ φ.reflectTime`, which is **not** `(substF σ φ).reflectTime` — the two differ exactly at
the atoms, where the first leaves `σ p` alone and the second reverses it. They therefore diverge
whenever `σ` sends an atom to a formula carrying a temporal operator. The identity that does hold
is `substF_reflectTime`, which repairs the mismatch by running the recursive call at
`fun p => (σ p).reflectTime`. So the recursion is over derivations *and* substitutions jointly,
and `σ` is an explicit argument rather than a section variable.

This is also why a source-level rename of a derivation's atoms to schema variables is **not** an
alternative to this module: at a `time_reflection` node the renamed tree's computed conclusion is
`reflectTime (substF σ φ)` while the generalized statement is `substF σ (reflectTime φ)`, and a
rename has nothing to transport along.

## Uniform substitution is a syntactic transfer, not a semantic principle

Nothing here says a valid schema stays valid under substitution. What is proved is the purely
proof-theoretic statement that *derivability* is closed under substitution, which follows from
the axioms being schemata. TM is closed under uniform substitution in this sense; TM⁺ is not,
because `atom_stab` holds for atoms and state-local formulas only. A consumer that generalizes an
extracted derivation may therefore do so over `Formula`, and only over `Formula`.

## References

* `FormalSystem/PlusLanguage/Substitution.lean` — the L⁺ mirror, arm for arm
* `FormalSystem/ProofSystem/Axioms.lean` — the 20 TM schemata whose arms are mirrored here
* `FormalSystem/ProofSystem/Derivation.lean` — the seven rules the transfer recurses over

## Tags

substitution · proof-system · theorem-library · schema
-/

namespace FormalSystem.ProofSystem

open FormalSystem.Syntax

/-! ## The substitution -/

/-- Interpret an L formula in L by replacing each atom `p` with `σ p`. Structural on the six
`Formula` constructors; the identity is the case `σ = Formula.atom`. -/
def substF (σ : Atom → Formula) : Formula → Formula
  | .atom p => σ p
  | .bot => .bot
  | .imp φ ψ => .imp (substF σ φ) (substF σ ψ)
  | .box φ => .box (substF σ φ)
  | .untl ψ φ => .untl (substF σ ψ) (substF σ φ)
  | .snce ψ φ => .snce (substF σ ψ) (substF σ φ)

/-- The context-level form. Definitionally `List.map (substF σ)`. -/
abbrev substCtxF (σ : Atom → Formula) (Γ : Context) : Context :=
  List.map (substF σ) Γ

/-- `substF` at the identity substitution is the identity. -/
theorem substF_atom (φ : Formula) : substF Formula.atom φ = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [substF, ih1, ih2]
  | box _ ih => simp only [substF, ih]
  | untl _ _ ih1 ih2 => simp only [substF, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [substF, ih1, ih2]

/-! ### Push-through pins

Every derived operator of L is notation for a right-hand side built from the six primitives, so
`substF σ` commutes with each of them definitionally. These pins are what makes every arm of
`Axiom.ofSubst` below `rfl`-shaped. -/

example (σ : Atom → Formula) : substF σ Formula.top = Formula.top := rfl
example (σ : Atom → Formula) (φ : Formula) : substF σ φ.neg = (substF σ φ).neg := rfl
example (σ : Atom → Formula) (φ ψ : Formula) :
    substF σ (φ.and ψ) = (substF σ φ).and (substF σ ψ) := rfl
example (σ : Atom → Formula) (φ : Formula) :
    substF σ (Formula.allFuture φ) = Formula.allFuture (substF σ φ) := rfl
example (σ : Atom → Formula) (φ : Formula) :
    substF σ φ.diamond = (substF σ φ).diamond := rfl

/-! ## The reflection interaction -/

/--
**Substitution and time reflection commute after shifting the substitution.**

`substF σ` and `reflectTime` do not commute on the nose: at an atom the left side yields `σ p`
and the right side `(σ p).reflectTime`. Running the substitution at
`fun p => (σ p).reflectTime` repairs it, the atom case closing by `reflect_time_involution`.
-/
theorem substF_reflectTime (σ : Atom → Formula) (φ : Formula) :
    substF σ φ.reflectTime = (substF (fun p => (σ p).reflectTime) φ).reflectTime := by
  induction φ with
  | atom p => exact (Formula.reflect_time_involution (σ p)).symm
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [Formula.reflectTime, substF, ih1, ih2]
  | box _ ih => simp only [Formula.reflectTime, substF, ih]
  | untl _ _ ih1 ih2 => simp only [Formula.reflectTime, substF, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [Formula.reflectTime, substF, ih1, ih2]

/-! ## The axiom transfer -/

/--
Every TM axiom instance is a TM axiom instance under `substF σ`. Each arm is `rfl`-shaped: the
schema's statement is built from its parameters by the operator vocabulary, and `substF σ` pushes
through every one of those operators definitionally. A constructor added to `Axiom` fails to
typecheck here rather than being silently dropped.
-/
def Axiom.ofSubst (σ : Atom → Formula) : {φ : Formula} → Axiom φ → Axiom (substF σ φ)
  | _, .prop_k φ ψ χ => .prop_k (substF σ φ) (substF σ ψ) (substF σ χ)
  | _, .prop_s φ ψ => .prop_s (substF σ φ) (substF σ ψ)
  | _, .ex_falso φ => .ex_falso (substF σ φ)
  | _, .peirce φ ψ => .peirce (substF σ φ) (substF σ ψ)
  | _, .modal_t φ => .modal_t (substF σ φ)
  | _, .modal_5_collapse φ => .modal_5_collapse (substF σ φ)
  | _, .modal_k_dist φ ψ => .modal_k_dist (substF σ φ) (substF σ ψ)
  | _, .serial_future => .serial_future
  | _, .left_mono_until_G φ χ ψ =>
      .left_mono_until_G (substF σ φ) (substF σ χ) (substF σ ψ)
  | _, .right_mono_until φ ψ χ => .right_mono_until (substF σ φ) (substF σ ψ) (substF σ χ)
  | _, .enrichment_until φ ψ p => .enrichment_until (substF σ φ) (substF σ ψ) (substF σ p)
  | _, .self_accum_until φ ψ => .self_accum_until (substF σ φ) (substF σ ψ)
  | _, .absorb_until φ ψ => .absorb_until (substF σ φ) (substF σ ψ)
  | _, .linear_until φ ψ χ θ =>
      .linear_until (substF σ φ) (substF σ ψ) (substF σ χ) (substF σ θ)
  | _, .modal_future φ => .modal_future (substF σ φ)
  | _, .discrete_box_necessity => .discrete_box_necessity
  | _, .prior_UZ φ => .prior_UZ (substF σ φ)
  | _, .dense_indicator => .dense_indicator
  | _, .prior_U_gap φ => .prior_U_gap (substF σ φ)
  | _, .sep φ => .sep (substF σ φ)

/-- Substitution preserves the minimum frame class: the routing depends on the constructor
alone. -/
theorem Axiom.minFrameClass_ofSubst (σ : Atom → Formula) {φ : Formula} (ax : Axiom φ) :
    (Axiom.ofSubst σ ax).minFrameClass = ax.minFrameClass := by
  cases ax <;> rfl

/-! ## The derivation transfer -/

/--
**The substitution transfer.** Every TM derivation becomes a TM derivation of the substituted
conclusion over the substituted context, at the same frame class.

Seven cases, one per rule. The `axiom` case is `Axiom.ofSubst`; the `time_reflection` case
recurses at the *shifted* substitution `fun p => (σ p).reflectTime` and transports along
`substF_reflectTime`; the rest are structural. The three empty-context rules need no coercion
because `substCtxF σ [] = []` reduces.
-/
def DerivationTree.subst {fc : FrameClass} (σ : Atom → Formula) :
    {Γ : Context} → {φ : Formula} → DerivationTree fc Γ φ →
      DerivationTree fc (substCtxF σ Γ) (substF σ φ)
  | _, _, .axiom _ _ h h_fc =>
      .axiom _ _ (Axiom.ofSubst σ h) (by rw [Axiom.minFrameClass_ofSubst]; exact h_fc)
  | _, _, .assumption _ _ h => .assumption _ _ (List.mem_map_of_mem h)
  | _, _, .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (substF σ φ) (substF σ ψ) (subst σ d1) (subst σ d2)
  | _, _, .necessitation φ d => .necessitation (substF σ φ) (subst σ d)
  | _, _, .temporal_necessitation φ d => .temporal_necessitation (substF σ φ) (subst σ d)
  | _, _, .time_reflection φ d =>
      (substF_reflectTime σ φ).symm ▸
        DerivationTree.time_reflection (substF (fun p => (σ p).reflectTime) φ)
          (subst (fun p => (σ p).reflectTime) d)
  | _, _, .weakening _ _ _ d h =>
      .weakening _ _ _ (subst σ d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/--
The transfer at the empty context: the shape the theorem library's ADMIT stage uses. A derivation
of one concrete formula becomes a derivation of its image under `σ`, so instantiating a schema at
concrete atoms and pushing the resulting derivation back along `σ` yields the schematic
derivation a registry row's `proof` field requires.
-/
def DerivationTree.substNil {fc : FrameClass} {φ : Formula} (σ : Atom → Formula)
    (d : DerivationTree fc [] φ) : DerivationTree fc [] (substF σ φ) :=
  DerivationTree.subst σ d

end FormalSystem.ProofSystem
