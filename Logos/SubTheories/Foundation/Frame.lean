import Mathlib.Order.CompleteLattice
import Mathlib.Order.Lattice

/-!
# Constitutive Frame - Mereological State Space

This module defines the Constitutive Frame, the foundational semantic structure
for Logos based on exact truthmaker semantics.

## Paper Specification Reference

**Constitutive Frame (RECURSIVE_SEMANTICS.md)**:
A *constitutive frame* is a structure **F** = ⟨S, ⊑⟩ where:
- S is a nonempty set of states
- ⊑ is a partial order on S making ⟨S, ⊑⟩ a complete lattice

The lattice structure provides:
- **Null state** (□): Bottom element (fusion of empty set)
- **Full state** (■): Top element (fusion of all states)
- **Fusion** (s.t): Least upper bound of s and t

## Main Definitions

- `ConstitutiveFrame`: Structure with state space as complete lattice
- `null`: Bottom element of the lattice (□)
- `full`: Top element of the lattice (■)
- `fusion`: Least upper bound operation (s ⊔ t)
- `parthood`: Partial order relation (s ⊑ t ↔ s ⊔ t = t)

## Implementation Notes

This implementation uses Mathlib's `CompleteLattice` typeclass to provide
the required lattice structure. The frame is non-modal: possibility and
compatibility require the task relation introduced in the Explanatory Extension.
-/

namespace Logos.SubTheories.Foundation

/--
Constitutive Frame for exact truthmaker semantics.

A constitutive frame consists of a state space with complete lattice structure.
The lattice provides the mereological operations needed for bilateral
proposition semantics.

**Paper Alignment**: Matches RECURSIVE_SEMANTICS.md definition exactly.
-/
structure ConstitutiveFrame where
  /-- Type of states in the state space -/
  State : Type*
  /-- Complete lattice structure on states -/
  [lattice : CompleteLattice State]

attribute [instance] ConstitutiveFrame.lattice

namespace ConstitutiveFrame

variable (F : ConstitutiveFrame)

/--
Null state (□): Bottom element of the lattice.

The null state is the fusion of the empty set, representing "no information"
or "the empty state". In verification semantics, it is the verifier for
propositional identity when verifier/falsifier sets match.
-/
def null : F.State := ⊥

/--
Full state (■): Top element of the lattice.

The full state is the fusion of all states, representing "complete information"
or "the maximal state". In verification semantics, it is the only falsifier
for verum (⊤).
-/
def full : F.State := ⊤

/--
Fusion operation (s.t): Least upper bound of two states.

Fusion combines two states into their minimal common extension.
This operation is used in conjunction/disjunction verification clauses.
-/
def fusion (s t : F.State) : F.State := s ⊔ t

/--
Parthood relation (s ⊑ t): s is a part of t.

In a lattice, parthood is equivalent to: s ⊔ t = t
This captures mereological containment: s is contained in t.
-/
def parthood (s t : F.State) : Prop := s ≤ t

/--
Notation: s ⊑ t for parthood
-/
scoped infixl:50 " ⊑ " => parthood

/--
Notation: s ⊔ᶠ t for fusion (to distinguish from general lattice ⊔)
-/
scoped infixl:65 " ⊔ᶠ " => fusion

section BasicLemmas

variable {F : ConstitutiveFrame}

/--
Null is the identity for fusion (left).
-/
@[simp]
theorem null_fusion_left (s : F.State) : F.fusion F.null s = s := by
  simp [fusion, null]

/--
Null is the identity for fusion (right).
-/
@[simp]
theorem null_fusion_right (s : F.State) : F.fusion s F.null = s := by
  simp [fusion, null]

/--
Full absorbs fusion (left).
-/
@[simp]
theorem full_fusion_left (s : F.State) : F.fusion F.full s = F.full := by
  simp [fusion, full]

/--
Full absorbs fusion (right).
-/
@[simp]
theorem full_fusion_right (s : F.State) : F.fusion s F.full = F.full := by
  simp [fusion, full]

/--
Fusion is commutative.
-/
theorem fusion_comm (s t : F.State) : F.fusion s t = F.fusion t s := by
  simp [fusion, sup_comm]

/--
Fusion is associative.
-/
theorem fusion_assoc (s t u : F.State) :
    F.fusion (F.fusion s t) u = F.fusion s (F.fusion t u) := by
  simp [fusion, sup_assoc]

/--
Fusion is idempotent.
-/
@[simp]
theorem fusion_self (s : F.State) : F.fusion s s = s := by
  simp [fusion]

/--
Null is a part of every state.
-/
theorem null_parthood (s : F.State) : F.parthood F.null s := by
  simp [parthood, null]

/--
Every state is a part of full.
-/
theorem parthood_full (s : F.State) : F.parthood s F.full := by
  simp [parthood, full]

/--
Parthood is reflexive.
-/
theorem parthood_refl (s : F.State) : F.parthood s s := by
  simp [parthood]

/--
Parthood is transitive.
-/
theorem parthood_trans {s t u : F.State} :
    F.parthood s t → F.parthood t u → F.parthood s u := by
  simp [parthood]
  exact le_trans

/--
Parthood is antisymmetric.
-/
theorem parthood_antisymm {s t : F.State} :
    F.parthood s t → F.parthood t s → s = t := by
  simp [parthood]
  exact le_antisymm

/--
Parthood characterization: s ⊑ t iff s ⊔ t = t
-/
theorem parthood_iff_fusion {s t : F.State} :
    F.parthood s t ↔ F.fusion s t = t := by
  simp [parthood, fusion, sup_eq_right]

/--
Fusion gives the least upper bound with respect to parthood.
-/
theorem parthood_fusion_left (s t : F.State) : F.parthood s (F.fusion s t) := by
  simp [parthood, fusion]

theorem parthood_fusion_right (s t : F.State) : F.parthood t (F.fusion s t) := by
  simp [parthood, fusion]

/--
Fusion is the least element containing both parts.
-/
theorem fusion_least {s t u : F.State} :
    F.parthood s u → F.parthood t u → F.parthood (F.fusion s t) u := by
  simp only [parthood, fusion]
  exact sup_le

end BasicLemmas

end ConstitutiveFrame

end Logos.SubTheories.Foundation
