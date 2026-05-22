import Aesop
import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Context

/-!
# Derivable - Prop-Valued Derivability Wrapper

This module provides a Prop-valued wrapper `Derivable` around the Type-valued
`DerivationTree`, enabling classical reasoning and automation (`simp`, `aesop`)
for derivability goals.

## Main Definitions

- `Derivable`: `def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)`
- `Derivable.ofTree`: Coercion from `DerivationTree` to `Derivable`
- Constructor-mirroring lemmas: `ax`, `assume`, `mp`, `nec`, `temp_nec`, `temp_dual`, `weaken`
- Notation `G |-! p` and `|-! p` for Prop-valued derivability

## Design Rationale

`DerivationTree` is a `Type`, which enables pattern matching and computable functions
(height, frame compatibility predicates). However, `Type`-valued goals cannot be targeted
by `simp` or `aesop`. The `Derivable` wrapper erases the tree structure via `Nonempty`,
producing a `Prop` that integrates with Lean's automation infrastructure.

Both interfaces coexist: use `DerivationTree` when you need the proof tree
(e.g., metalogic, deduction theorem), and `Derivable` when you only need
to assert derivability (e.g., consistency arguments, quick lemma applications).

## Relationship to Consistent

`Consistent G` is defined as `¬Nonempty (DerivationTree G Formula.bot)`,
which is definitionally equal to `¬Derivable G Formula.bot`. The bridge
lemma `consistent_iff_not_derivable_bot` witnesses this as `Iff.rfl`.

## References

* [Derivation.lean](./Derivation.lean) - Type-valued derivation trees
* [MaximalConsistent.lean](../Metalogic/Core/MaximalConsistent.lean) - Consistency definition
-/

namespace Bimodal.ProofSystem

open Bimodal.Syntax

/--
Prop-valued derivability: `Derivable G p` holds iff there exists a derivation tree
for `p` from context `G`.

This is the Prop-valued wrapper around `DerivationTree`, defined as
`Nonempty (DerivationTree G p)`. Use this when you only need to assert derivability
without inspecting the proof tree.
-/
def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)

/-! ## Notation -/

/--
Notation `G |-! p` for Prop-valued derivability from context `G`.
-/
notation:50 G " |-! " p => Derivable G p

/--
Notation `|-! p` for Prop-valued derivability from empty context (Prop-valued theorem).
-/
notation:50 "|-! " p => Derivable [] p

/-! ## Coercion from DerivationTree -/

/--
Any derivation tree witnesses Prop-valued derivability.
-/
theorem Derivable.ofTree {G : Context} {p : Formula}
    (d : DerivationTree G p) : Derivable G p :=
  Nonempty.intro d

/-! ## Constructor-Mirroring Lemmas -/

/--
Axiom rule: Any axiom schema instance is derivable (Prop-valued).
-/
@[aesop safe apply, simp]
theorem Derivable.ax (G : Context) (p : Formula) (h : Axiom p) : Derivable G p :=
  Nonempty.intro (DerivationTree.axiom G p h)

/--
Assumption rule: Formulas in context are derivable (Prop-valued).
-/
@[aesop safe apply, simp]
theorem Derivable.assume (G : Context) (p : Formula) (h : p ∈ G) : Derivable G p :=
  Nonempty.intro (DerivationTree.assumption G p h)

/--
Modus ponens: If `G |-! p → q` and `G |-! p` then `G |-! q` (Prop-valued).
-/
@[aesop unsafe 50% apply]
theorem Derivable.mp (G : Context) (p q : Formula)
    (h1 : Derivable G (p.imp q)) (h2 : Derivable G p) : Derivable G q := by
  obtain ⟨d1⟩ := h1; obtain ⟨d2⟩ := h2
  exact Nonempty.intro (DerivationTree.modus_ponens G p q d1 d2)

/--
Weakening: If `G |-! p` and `G ⊆ D` then `D |-! p` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.weaken {G D : Context} {p : Formula}
    (h : Derivable G p) (hsub : G ⊆ D) : Derivable D p := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.weakening G D p d hsub)

/--
Modal necessitation: If `|-! p` then `|-! □p` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.nec {p : Formula}
    (h : Derivable [] p) : Derivable [] (Formula.box p) := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.necessitation p d)

/--
Temporal necessitation: If `|-! p` then `|-! Gp` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.temp_nec {p : Formula}
    (h : Derivable [] p) : Derivable [] (Formula.all_future p) := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.temporal_necessitation p d)

/--
Temporal duality: If `|-! p` then `|-! swap_temporal p` (Prop-valued).
-/
@[aesop safe apply]
theorem Derivable.temp_dual {p : Formula}
    (h : Derivable [] p) : Derivable [] p.swap_temporal := by
  obtain ⟨d⟩ := h
  exact Nonempty.intro (DerivationTree.temporal_duality p d)

/-! ## Aesop and Simp Test Examples -/

/--
Test: Aesop can derive from assumptions using `Derivable.assume`.
-/
example (p q : Formula) : Derivable [p.imp q, p] p := by
  aesop

/--
Test: Axiom application via explicit term.
-/
example (p : Atom) : Derivable [] ((Formula.box (Formula.atom p)).imp (Formula.atom p)) := by
  exact Derivable.ax _ _ (Axiom.modal_t _)

/--
Test: Modus ponens chain -- derive `q` from `p → q` and `p` in context.
-/
example (p q : Formula) : Derivable [p.imp q, p] q := by
  apply Derivable.mp _ p
  · exact Derivable.assume _ _ (by simp)
  · exact Derivable.assume _ _ (by simp)

/--
Test: Weakening preserves derivability.
-/
example (p q r : Formula) (h : Derivable [p] q) : Derivable [p, r] q :=
  Derivable.weaken h (by intro x hx; simp_all)

/-! ## Consistent Bridge

`Consistent G` (defined in `Bimodal.Metalogic.Core.MaximalConsistent`) is
`¬Nonempty (DerivationTree G Formula.bot)`, which is definitionally equal
to `¬Derivable G Formula.bot`. The bridge lemma cannot live here due to
import ordering (MaximalConsistent imports ProofSystem), so any file that
imports both modules can use `Iff.rfl`:

```
theorem consistent_iff_not_derivable_bot (G : Context) :
    Consistent G ↔ ¬Derivable G Formula.bot := Iff.rfl
```
-/

end Bimodal.ProofSystem
