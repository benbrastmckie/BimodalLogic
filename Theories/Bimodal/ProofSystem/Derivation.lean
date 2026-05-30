import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context
import Bimodal.ProofSystem.Axioms

/-!
# Derivation - Proof System for TM Logic

This module defines derivation trees for bimodal logic TM,
representing syntactic provability from a context of assumptions.

## Main Definitions

- `DerivationTree fc Γ φ`: Derivation tree parameterized by frame class `fc`,
  context `Γ`, and conclusion `φ`
- `DerivationTree.height`: Computable height function for derivation trees
- `DerivationTree.lift`: Coercion from `DerivationTree fc₁` to `DerivationTree fc₂`
  when `fc₁ ≤ fc₂`
- Notation `Γ ⊢ φ` for derivability from context `Γ` at `FrameClass.Base`
- Notation `Γ ⊢[fc] φ` for derivability from context `Γ` at explicit frame class `fc`

## Frame Class Parameterization

`DerivationTree` is parameterized by a `FrameClass` to enforce frame-class validity
as a structural invariant:

- The `axiom` constructor requires `h.minFrameClass ≤ fc`, ensuring only axioms
  compatible with frame class `fc` can appear in the derivation.
- `DerivationTree.lift` provides monotonicity: if `fc₁ ≤ fc₂`, any derivation at
  `fc₁` can be coerced to `fc₂`. This reflects the semantic fact that validity on
  a larger class of frames implies validity on a subclass.
- The notation `⊢ φ` defaults to `FrameClass.Base`, preserving ergonomics for the
  most common case. Use `⊢[fc] φ` to specify a different frame class.

## Inference Rules

The derivation tree includes 7 inference rules:

1. **axiom**: Axiom schema instance, gated by `ax.minFrameClass ≤ fc`
2. **assumption**: Formulas in context are derivable
3. **modus_ponens**: If `Γ ⊢[fc] φ → ψ` and `Γ ⊢[fc] φ` then `Γ ⊢[fc] ψ`
4. **necessitation**: If `⊢[fc] φ` then `⊢[fc] □φ`
5. **temporal_necessitation**: If `⊢[fc] φ` then `⊢[fc] Gφ`
6. **temporal_duality**: If `⊢[fc] φ` then `⊢[fc] swap_temporal φ`
7. **weakening**: If `Γ ⊢[fc] φ` and `Γ ⊆ Δ` then `Δ ⊢[fc] φ`

## Implementation Notes

- `DerivationTree` is a `Type` (not a `Prop`), enabling pattern matching and computable functions
- Height function is computable via pattern matching (not axiomatized)
- Height properties are proven as theorems (not axioms)
- Necessitation rules only apply to theorems (empty context)
- Temporal duality only applies to theorems (empty context)
- Weakening allows adding unused assumptions
- K distribution is handled by axioms (`modal_k_dist`, `temp_k_dist`)

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - Proof system specification
* [Axioms.lean](./Axioms.lean) - Axiom schemata definitions
-/

namespace Bimodal.ProofSystem

open Bimodal.Syntax

/--
Derivation tree for bimodal logic TM, parameterized by frame class.

`DerivationTree fc Γ φ` represents a derivation tree showing that formula `φ` is
derivable from the context of assumptions `Γ` using only axioms compatible with
frame class `fc` (i.e., axioms whose `minFrameClass` is at most `fc`).

The `fc` parameter makes frame-class validity a structural invariant: a
`DerivationTree .Dense Γ φ` can use base axioms and the density axiom, but
cannot use discrete-only axioms (prior_UZ, prior_SZ, z1). This replaces
the previous ad-hoc predicates `isDenseCompatible` and `isDiscreteCompatible`.

The `lift` function provides monotonicity: `fc₁ ≤ fc₂` implies any derivation
at `fc₁` can be coerced to `fc₂`.

Since `DerivationTree` is a `Type` (not a `Prop`), we can pattern match on it
to produce data. This enables computable functions like `height` and supports
well-founded recursion in metalogical proofs.
-/
inductive DerivationTree (fc : FrameClass) : Context → Formula → Type where
  /--
  Axiom rule: Axiom schema instances are derivable from any context,
  provided the axiom's minimum frame class is compatible with `fc`.

  If `Axiom φ` holds and `h.minFrameClass ≤ fc`, then `Γ ⊢[fc] φ`.
  -/
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ fc)
      : DerivationTree fc Γ φ

  /--
  Assumption rule: Formulas in the context are derivable.

  If `φ ∈ Γ`, then `Γ ⊢[fc] φ`.
  -/
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree fc Γ φ

  /--
  Modus ponens: Implication elimination.

  If `Γ ⊢[fc] φ → ψ` and `Γ ⊢[fc] φ`, then `Γ ⊢[fc] ψ`.
  -/
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree fc Γ (φ.imp ψ))
      (d2 : DerivationTree fc Γ φ) : DerivationTree fc Γ ψ

  /--
  Necessitation rule: From theorems, derive necessary theorems.

  If `⊢[fc] φ` (derivable from empty context), then `⊢[fc] □φ`.

  This is the standard necessitation rule of modal logic. It only applies
  to theorems (proofs from no assumptions), not to derivations from contexts.

  This rule expresses: if φ is a theorem (provable without assumptions),
  then it is necessarily true (□φ is also a theorem).

  **Note**: The generalized rule `Γ ⊢ φ` ⟹ `□Γ ⊢ □φ` is derivable from
  this rule plus K distribution (`modal_k_dist`) and the deduction theorem.
  See `Bimodal.Theorems.GeneralizedNecessitation` for the derivation.
  -/
  | necessitation (φ : Formula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.box φ)

  /--
  Temporal necessitation rule: From theorems, derive future-necessary theorems.

  If `⊢[fc] φ` (derivable from empty context), then `⊢[fc] Gφ`.

  This is the temporal analog of modal necessitation. It only applies
  to theorems (proofs from no assumptions), not to derivations from contexts.

  This rule expresses: if φ is a theorem (provable without assumptions),
  then it will always be true (Gφ is also a theorem).

  **Note**: The generalized rule `Γ ⊢ φ` ⟹ `GΓ ⊢ Gφ` is derivable from
  this rule plus temporal K distribution (`temp_k_dist`) and the deduction theorem.
  See `Bimodal.Theorems.GeneralizedNecessitation` for the derivation.
  -/
  | temporal_necessitation (φ : Formula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.all_future φ)

  /--
  Temporal duality rule: Swapping past and future in theorems.

  If `⊢[fc] φ` (derivable from empty context), then `⊢[fc] swap_temporal φ`.

  This rule only applies to theorems (proofs from no assumptions).
  -/
  | temporal_duality (φ : Formula)
      (d : DerivationTree fc [] φ) : DerivationTree fc [] φ.swap_temporal

  /--
  Weakening rule: Adding unused assumptions.

  If `Γ ⊢[fc] φ` and `Γ ⊆ Δ`, then `Δ ⊢[fc] φ`.

  This allows adding extra assumptions that don't affect the derivation.
  -/
  | weakening (Γ Δ : Context) (φ : Formula)
      (d : DerivationTree fc Γ φ)
      (h : Γ ⊆ Δ) : DerivationTree fc Δ φ
  deriving Repr

namespace DerivationTree

/-! ## Lift (Frame Class Monotonicity)

If `fc₁ ≤ fc₂`, any derivation at `fc₁` can be coerced to `fc₂`.
This reflects the semantic monotonicity: if every axiom in the derivation
is valid on `fc₁`-frames, and `fc₁`-frames are a superclass of `fc₂`-frames,
then the derivation is also valid on `fc₂`-frames.

Concretely: `Base ≤ Dense` and `Base ≤ Discrete`, so any base derivation
can be lifted to either dense or discrete. Dense and Discrete derivations
cannot be lifted to each other (the frame classes are incomparable).
-/

/--
Lift a derivation tree from frame class `fc₁` to `fc₂` when `fc₁ ≤ fc₂`.

This is structural recursion on the derivation tree: the only interesting case
is the `axiom` constructor, where we compose `h_fc : ax.minFrameClass ≤ fc₁`
with `h_le : fc₁ ≤ fc₂` to get `ax.minFrameClass ≤ fc₂` via transitivity.
-/
def lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {Γ : Context} {φ : Formula} : DerivationTree fc₁ Γ φ → DerivationTree fc₂ Γ φ
  | .axiom Γ φ h h_fc => .axiom Γ φ h (le_trans h_fc h_le)
  | .assumption Γ φ h => .assumption Γ φ h
  | .modus_ponens Γ φ ψ d1 d2 => .modus_ponens Γ φ ψ (d1.lift h_le) (d2.lift h_le)
  | .necessitation φ d => .necessitation φ (d.lift h_le)
  | .temporal_necessitation φ d => .temporal_necessitation φ (d.lift h_le)
  | .temporal_duality φ d => .temporal_duality φ (d.lift h_le)
  | .weakening Γ Δ φ d h => .weakening Γ Δ φ (d.lift h_le) h

/-! ## Derivation Height Measure -/

/--
Computable height function via pattern matching.

The height is defined as the maximum depth of the derivation tree:
- Base cases (axiom, assumption): height 0
- Unary rules (necessitation, temporal_necessitation, temporal_duality, weakening):
  height of subderivation + 1
- Binary rules (modus_ponens): max of both subderivations + 1

This measure is used for well-founded recursion in the deduction theorem proof.

## Implementation Notes

Since `DerivationTree` is a `Type` (not a `Prop`), we can pattern match on it
to produce data. The height function is computable and can be evaluated.

## Usage

The height measure is primarily used in `Bimodal.Metalogic.DeductionTheorem`
for proving termination of the deduction theorem via well-founded recursion.
-/
def height {fc : FrameClass} {Γ : Context} {φ : Formula} : DerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

/-! ## Height Properties -/

/--
Weakening increases height by exactly 1.
-/
theorem weakening_height_succ {fc : FrameClass} {Γ' Δ : Context} {φ : Formula}
    (d : DerivationTree fc Γ' φ) (h : Γ' ⊆ Δ) :
    (weakening Γ' Δ φ d h).height = d.height + 1 := by
  simp [height]
  omega

/--
Subderivations in weakening have strictly smaller height.

This is the key lemma for proving termination of well-founded recursion
in the deduction theorem.
-/
theorem subderiv_height_lt {fc : FrameClass} {Γ' Δ : Context} {φ : Formula}
    (d : DerivationTree fc Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (weakening Γ' Δ φ d h).height := by
  simp [height]

/--
Modus ponens height is strictly greater than the left subderivation.
-/
theorem mp_height_gt_left {fc : FrameClass} {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree fc Γ (φ.imp ψ)) (d2 : DerivationTree fc Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/--
Modus ponens height is strictly greater than the right subderivation.
-/
theorem mp_height_gt_right {fc : FrameClass} {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree fc Γ (φ.imp ψ)) (d2 : DerivationTree fc Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/--
Necessitation increases height by exactly 1.
-/
theorem necessitation_height_succ {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) :
    (necessitation φ d).height = d.height + 1 := by
  simp [height]
  omega

/--
Temporal necessitation increases height by exactly 1.
-/
theorem temporal_necessitation_height_succ {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) :
    (temporal_necessitation φ d).height = d.height + 1 := by
  simp [height]
  omega

/--
Temporal duality increases height by exactly 1.
-/
theorem temporal_duality_height_succ {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) :
    (temporal_duality φ d).height = d.height + 1 := by
  simp [height]
  omega

end DerivationTree

/-! ## Notation

- `Γ ⊢[fc] φ` — derivability from context `Γ` at explicit frame class `fc`
- `⊢[fc] φ` — theorem at explicit frame class `fc`
- `Γ ⊢ φ` — derivability from context `Γ` at `FrameClass.Base` (default)
- `⊢ φ` — theorem at `FrameClass.Base` (default)

The default to `.Base` preserves backwards compatibility: most derivation
constructions use only base axioms.
-/

/--
Notation `Γ ⊢[fc] φ` for derivability from context `Γ` at frame class `fc`.
-/
notation:50 Γ " ⊢[" fc "] " φ => DerivationTree fc Γ φ

/--
Notation `⊢[fc] φ` for derivability from empty context at frame class `fc`.
-/
notation:50 "⊢[" fc "] " φ => DerivationTree fc [] φ

/--
Notation `Γ ⊢ φ` for derivability from context `Γ` at `FrameClass.Base`.
-/
notation:50 Γ " ⊢ " φ => DerivationTree FrameClass.Base Γ φ

/--
Notation `⊢ φ` for derivability from empty context at `FrameClass.Base`.
-/
notation:50 "⊢ " φ => DerivationTree FrameClass.Base [] φ

/-!
## Example Derivations

Demonstrating basic usage of the proof system.
-/

/--
Example: Modal T axiom is a theorem.

`⊢ □p → p` for any propositional variable p.
-/
example (p : Atom) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) :=
  .axiom _ _ (Axiom.modal_t _) trivial

/--
Example: Modus ponens from assumptions.

If we assume both `p → q` and `p`, we can derive `q`.
-/
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)
  · exact .assumption _ _ (by simp)
  · exact .assumption _ _ (by simp)

/--
Example: Modal 4 axiom is a theorem.

`⊢ □φ → □□φ` for any formula φ.
-/
example (φ : Formula) : ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) :=
  .axiom _ _ (Axiom.modal_4 _) trivial

/--
Example: Weakening allows adding assumptions.

If we can derive `□p → p` from empty context,
we can also derive it with extra assumptions.
-/
example (p : Atom) (ψ : Formula) : [ψ] ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) :=
  .weakening [] [ψ] _ (.axiom _ _ (Axiom.modal_t _) trivial) (by intro _ h; exact absurd h (List.not_mem_nil))

/--
Example: Density axiom is derivable at `.Dense` frame class.
-/
example (φ : Formula) : ⊢[FrameClass.Dense] φ.all_future.all_future.imp φ.all_future :=
  .axiom _ _ (Axiom.density _) trivial

/--
Example: Lifting a base derivation to dense frame class.
-/
example (p : Atom) : ⊢[FrameClass.Dense] (Formula.box (Formula.atom p)).imp (Formula.atom p) :=
  DerivationTree.lift (fc₁ := .Base) trivial (.axiom _ _ (Axiom.modal_t _) trivial)

end Bimodal.ProofSystem
