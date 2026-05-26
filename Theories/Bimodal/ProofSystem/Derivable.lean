import Aesop
import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Context

/-!
# Derivable - Prop-Valued Derivability Wrapper

This module provides a Prop-valued wrapper `Derivable` around the Type-valued
`DerivationTree`, enabling classical reasoning and automation (`simp`, `aesop`)
for derivability goals.

## Main Definitions

- `Derivable fc G p`: Prop-valued derivability parameterized by frame class `fc`
- `Derivable.ofTree`: Coercion from `DerivationTree` to `Derivable`
- Constructor-mirroring lemmas: `ax`, `assume`, `mp`, `nec`, `temp_nec`, `temp_dual`, `weaken`
- `Derivable.lift`: Frame class monotonicity for Prop-valued derivability
- Notation `G |-! p` (defaults to `.Base`) and `G |-![fc] p` for explicit frame class

## Design Rationale

`DerivationTree` is a `Type`, which enables pattern matching and computable functions
(height). However, `Type`-valued goals cannot be targeted by `simp` or `aesop`.
The `Derivable` wrapper erases the tree structure via `Nonempty`, producing a `Prop`
that integrates with Lean's automation infrastructure.

Both interfaces coexist: use `DerivationTree` when you need the proof tree
(e.g., metalogic, deduction theorem), and `Derivable` when you only need
to assert derivability (e.g., consistency arguments, quick lemma applications).

## Frame Class Parameterization

`Derivable` mirrors the frame class parameterization of `DerivationTree`:
- `Derivable fc G p` holds iff there exists a `DerivationTree fc G p`
- `Derivable.lift` provides monotonicity: `fc₁ ≤ fc₂` implies `Derivable fc₁ G p → Derivable fc₂ G p`
- The notation `G |-! p` defaults to `FrameClass.Base`; use `G |-![fc] p` for other frame classes

## Relationship to Consistent

`Consistent fc G` is defined as `¬Nonempty (DerivationTree fc G Formula.bot)`,
which is definitionally equal to `¬Derivable fc G Formula.bot`. The bridge
lemma `consistent_iff_not_derivable_bot` witnesses this as `Iff.rfl`.

## References

* [Derivation.lean](./Derivation.lean) - Type-valued derivation trees
* [MaximalConsistent.lean](../Metalogic/Core/MaximalConsistent.lean) - Consistency definition
-/

namespace Bimodal.ProofSystem

open Bimodal.Syntax

/--
Prop-valued derivability: `Derivable fc G p` holds iff there exists a derivation tree
for `p` from context `G` at frame class `fc`.

This is the Prop-valued wrapper around `DerivationTree`, defined as
`Nonempty (DerivationTree fc G p)`. Use this when you only need to assert derivability
without inspecting the proof tree.
-/
def Derivable (fc : FrameClass) (G : Context) (p : Formula) : Prop :=
  Nonempty (DerivationTree fc G p)

/-! ## Notation -/

/--
Notation `G |-![fc] p` for Prop-valued derivability from context `G` at frame class `fc`.
-/
notation:50 G " |-![" fc "] " p => Derivable fc G p

/--
Notation `|-![fc] p` for Prop-valued derivability from empty context at frame class `fc`.
-/
notation:50 "|-![" fc "] " p => Derivable fc [] p

/--
Notation `G |-! p` for Prop-valued derivability from context `G` at `FrameClass.Base`.
-/
notation:50 G " |-! " p => Derivable FrameClass.Base G p

/--
Notation `|-! p` for Prop-valued derivability from empty context at `FrameClass.Base`.
-/
notation:50 "|-! " p => Derivable FrameClass.Base [] p

/-! ## Coercion from DerivationTree -/

/--
Any derivation tree witnesses Prop-valued derivability.
-/
theorem Derivable.ofTree {fc : FrameClass} {G : Context} {p : Formula}
    (d : DerivationTree fc G p) : Derivable fc G p :=
  Nonempty.intro d

/-! ## Lift (Frame Class Monotonicity) -/

/--
Lift Prop-valued derivability from `fc₁` to `fc₂` when `fc₁ ≤ fc₂`.

Wraps `DerivationTree.lift`.
-/
theorem Derivable.lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂)
    {G : Context} {p : Formula} (h : Derivable fc₁ G p) : Derivable fc₂ G p := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (d.lift h_le)

/-! ## Constructor-Mirroring Lemmas -/

/--
Axiom rule: Any axiom schema instance is derivable (Prop-valued),
provided the axiom's minimum frame class is compatible with `fc`.
-/
@[aesop safe apply, simp]
theorem Derivable.ax {fc : FrameClass} (G : Context) (p : Formula)
    (h : Axiom p) (h_fc : h.minFrameClass ≤ fc) : Derivable fc G p :=
  Nonempty.intro (DerivationTree.axiom G p h h_fc)

/--
Assumption rule: Formulas in context are derivable (Prop-valued).
-/
@[aesop safe apply, simp]
theorem Derivable.assume {fc : FrameClass} (G : Context) (p : Formula)
    (h : p ∈ G) : Derivable fc G p :=
  Nonempty.intro (DerivationTree.assumption G p h)

/--
Modus ponens: If `G |-![fc] p → q` and `G |-![fc] p` then `G |-![fc] q` (Prop-valued).
-/
@[aesop unsafe 50% apply]
theorem Derivable.mp {fc : FrameClass} (G : Context) (p q : Formula)
    (h1 : Derivable fc G (p.imp q)) (h2 : Derivable fc G p) : Derivable fc G q := by
  obtain ⟨d1⟩ := h1; obtain ⟨d2⟩ := h2
  exact Nonempty.intro (DerivationTree.modus_ponens G p q d1 d2)

/--
Weakening: If `G |-![fc] p` and `G ⊆ D` then `D |-![fc] p` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.weaken {fc : FrameClass} {G D : Context} {p : Formula}
    (h : Derivable fc G p) (hsub : G ⊆ D) : Derivable fc D p := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.weakening G D p d hsub)

/--
Modal necessitation: If `|-![fc] p` then `|-![fc] □p` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.nec {fc : FrameClass} {p : Formula}
    (h : Derivable fc [] p) : Derivable fc [] (Formula.box p) := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.necessitation p d)

/--
Temporal necessitation: If `|-![fc] p` then `|-![fc] Gp` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.temp_nec {fc : FrameClass} {p : Formula}
    (h : Derivable fc [] p) : Derivable fc [] (Formula.all_future p) := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.temporal_necessitation p d)

/--
Temporal duality: If `|-![fc] p` then `|-![fc] swap_temporal p` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.temp_dual {fc : FrameClass} {p : Formula}
    (h : Derivable fc [] p) : Derivable fc [] p.swap_temporal := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.temporal_duality p d)

/-! ## Aesop and Simp Test Examples -/

/--
Test: Aesop can derive from assumptions using `Derivable.assume`.
-/
example (p q : Formula) : Derivable .Base [p.imp q, p] p := by
  aesop

/--
Test: Axiom application via explicit term.
-/
example (p : Atom) : Derivable .Base [] ((Formula.box (Formula.atom p)).imp (Formula.atom p)) := by
  exact Derivable.ax _ _ (Axiom.modal_t _) trivial

/--
Test: Modus ponens chain -- derive `q` from `p → q` and `p` in context.
-/
example (p q : Formula) : Derivable .Base [p.imp q, p] q := by
  apply Derivable.mp _ p
  · exact Derivable.assume _ _ (by simp)
  · exact Derivable.assume _ _ (by simp)

/--
Test: Weakening preserves derivability.
-/
example (p q r : Formula) (h : Derivable .Base [p] q) : Derivable .Base [p, r] q :=
  Derivable.weaken h (by intro x hx; simp_all)

/--
Test: Derivable.lift can lift base derivability to dense.
-/
example (p : Atom) (h : Derivable .Base [] ((Formula.box (Formula.atom p)).imp (Formula.atom p))) :
    Derivable .Dense [] ((Formula.box (Formula.atom p)).imp (Formula.atom p)) :=
  Derivable.lift (fc₁ := .Base) trivial h

/-! ## Consistent Bridge

`Consistent fc G` (defined in `Bimodal.Metalogic.Core.MaximalConsistent`) is
`¬Nonempty (DerivationTree fc G Formula.bot)`, which is definitionally equal
to `¬Derivable fc G Formula.bot`. The bridge lemma cannot live here due to
import ordering (MaximalConsistent imports ProofSystem), so any file that
imports both modules can use `Iff.rfl`:

```
theorem consistent_iff_not_derivable_bot (fc : FrameClass) (G : Context) :
    Consistent fc G ↔ ¬Derivable fc G Formula.bot := Iff.rfl
```
-/

end Bimodal.ProofSystem
