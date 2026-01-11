import Logos.Foundation.Frame

/-!
# Basic Mereological Lemmas for Constitutive Frames

This module provides additional lemmas about the mereological structure
of constitutive frames, building on the core definitions in Frame.lean.

## Main Results

- Lattice-theoretic properties of fusion and parthood
- Characterizations of mereological relations
- Properties needed for verification/falsification semantics
-/

namespace Logos.Foundation

namespace ConstitutiveFrame

variable {F : ConstitutiveFrame}

section DistributiveLaws

/--
States have finite fusion (binary case).
-/
theorem fusion_exists (s t : F.State) : ∃ u, u = F.fusion s t := ⟨_, rfl⟩

/--
Arbitrary fusion exists (supremum of any set of states).
-/
noncomputable def sSup (S : Set F.State) : F.State := sSup S

/--
Arbitrary meet exists (infimum of any set of states).
-/
noncomputable def sInf (S : Set F.State) : F.State := sInf S

/--
Fusion distributes over arbitrary supremum.
-/
theorem fusion_sSup_left (s : F.State) (S : Set F.State) :
    F.fusion s (sSup S) = ⨆ t ∈ S, F.fusion s t := by
  simp only [fusion, sSup]
  exact sup_iSup₂_eq_left

/--
Fusion distributes over arbitrary supremum (right).
-/
theorem fusion_sSup_right (S : Set F.State) (t : F.State) :
    F.fusion (sSup S) t = ⨆ s ∈ S, F.fusion s t := by
  simp only [fusion, sSup]
  exact sup_iSup₂_eq_right

end DistributiveLaws

section MereologicalProperties

/--
Overlap: Two states overlap if they have a common part other than null.
-/
def overlaps (s t : F.State) : Prop :=
  ∃ u : F.State, u ≠ F.null ∧ F.parthood u s ∧ F.parthood u t

/--
Disjoint: Two states are disjoint if their only common part is null.
-/
def disjoint (s t : F.State) : Prop :=
  ∀ u : F.State, F.parthood u s → F.parthood u t → u = F.null

/--
Proper parthood: s is a proper part of t if s ⊑ t and s ≠ t.
-/
def proper_parthood (s t : F.State) : Prop :=
  F.parthood s t ∧ s ≠ t

/--
Disjoint states don't overlap.
-/
theorem disjoint_not_overlaps {s t : F.State} :
    F.disjoint s t → ¬F.overlaps s t := by
  intro h_disj h_overlap
  obtain ⟨u, h_ne, h_s, h_t⟩ := h_overlap
  exact h_ne (h_disj u h_s h_t)

/--
Null is disjoint from itself (vacuously, only null is part of null).
-/
theorem null_disjoint_self : F.disjoint F.null F.null := by
  intro u hu _
  exact le_antisymm hu (F.null_parthood u)

end MereologicalProperties

section FrameInstances

/--
The trivial constitutive frame with a single state (Unit).
This is the simplest possible frame.
-/
def trivial : ConstitutiveFrame where
  State := Unit

/--
The two-element frame (Bool with false < true).
Useful for classical propositional logic.
-/
def twoElement : ConstitutiveFrame where
  State := Bool

/--
Power set frame over any type. States are sets, parthood is subset.
The canonical example of a complete lattice.
-/
def powerSet (α : Type*) : ConstitutiveFrame where
  State := Set α

end FrameInstances

end ConstitutiveFrame

end Logos.Foundation
