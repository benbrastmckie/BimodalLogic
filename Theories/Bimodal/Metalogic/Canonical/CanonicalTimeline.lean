import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# Canonical Timeline for D-from-Syntax Construction

This module defines the canonical timeline T and proves its order-theoretic properties,
which are prerequisites for the Cantor isomorphism (T ≅ Q) and the D-from-syntax
construction.

## Overview

The canonical timeline is the bidirectional closure of a root MCS M₀ under the canonical
temporal relations CanonicalR (future) and CanonicalR_past (past). Every MCS in the
timeline is reachable from M₀ by a finite chain of forward/backward temporal steps.

## Properties to Prove

For Cantor's theorem, we need:
1. **Linear order**: The timeline is linearly ordered (from temp_linearity axiom)
2. **Countable**: The timeline is countable (from formula countability)
3. **No endpoints**: NoMaxOrder and NoMinOrder (from seriality axioms)
4. **Dense**: DenselyOrdered (from density axiom DN)

## References

- Task 956 plan v011: Phase 2 (Canonical Timeline Properties)
- Goldblatt 1992, Logics of Time and Computation (canonical model for tense logics)
- Order.iso_of_countable_dense (Mathlib): Cantor's theorem for countable dense linear orders
-/

namespace Bimodal.Metalogic.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.ProofSystem

/-!
## Canonical Timeline Definition

The canonical timeline is the set of all MCS bidirectionally reachable from a root MCS M₀.
Bidirectional reachability uses the transitive closure of CanonicalR ∪ CanonicalR_past.
-/

/--
Bidirectional canonical relation: either future or past canonical relation.
`BidirectionalR M M'` holds if either `CanonicalR M M'` or `CanonicalR_past M M'`.
-/
def BidirectionalR (M M' : Set Formula) : Prop :=
  CanonicalR M M' ∨ CanonicalR_past M M'

/--
The canonical timeline rooted at M₀: all MCS reachable from M₀ by
chains of forward/backward temporal steps, plus M₀ itself.

This is defined as a type (subtype of Set Formula) to enable
instances on it.
-/
def CanonicalTimeline (M₀ : Set Formula) : Type :=
  { M : Set Formula // SetMaximalConsistent M ∧
    (M = M₀ ∨ Relation.TransGen BidirectionalR M₀ M) }

/--
The root MCS is in its own timeline.
-/
def CanonicalTimeline.root (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) :
    CanonicalTimeline M₀ :=
  ⟨M₀, h_mcs, Or.inl rfl⟩

/-!
## NoMaxOrder from Seriality Axiom F(¬⊥)

The seriality axiom `F(¬⊥)` (there exists a strict future time) forces every MCS
to have a future temporal witness. This gives NoMaxOrder on the canonical timeline.
-/

/--
Every MCS contains `F(¬⊥)` (the seriality future axiom is a theorem).
-/
theorem mcs_contains_seriality_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_future (Formula.neg Formula.bot) ∈ M :=
  theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.seriality_future)

/--
Every MCS contains `P(¬⊥)` (the seriality past axiom is a theorem).
-/
theorem mcs_contains_seriality_past (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_past (Formula.neg Formula.bot) ∈ M :=
  theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.seriality_past)

/--
Every MCS has a strict canonical future successor.

From `F(¬⊥) ∈ M` and `canonical_forward_F`, there exists MCS W with
`CanonicalR M W` and `¬⊥ ∈ W`.
-/
theorem mcs_has_canonical_successor (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W := by
  have h_F := mcs_contains_seriality_future M h_mcs
  obtain ⟨W, h_W_mcs, h_R, _⟩ := canonical_forward_F M h_mcs _ h_F
  exact ⟨W, h_W_mcs, h_R⟩

/--
Every MCS has a strict canonical past predecessor.

From `P(¬⊥) ∈ M` and `canonical_backward_P`, there exists MCS W with
`CanonicalR_past M W` and `¬⊥ ∈ W`.
-/
theorem mcs_has_canonical_predecessor (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR_past M W := by
  have h_P := mcs_contains_seriality_past M h_mcs
  obtain ⟨W, h_W_mcs, h_R_past, _⟩ := canonical_backward_P M h_mcs _ h_P
  exact ⟨W, h_W_mcs, h_R_past⟩

/-!
## Density from Density Axiom DN

The density axiom `Fφ → FFφ` forces the canonical timeline to be densely ordered:
between any two related MCS, there exists an intermediate one.
-/

/--
Density of CanonicalR: if `F(φ) ∈ M` and `M` is MCS, then there exists an
intermediate MCS W with `CanonicalR M W` and `F(φ) ∈ W`.

This follows from the density axiom `Fφ → FFφ`:
1. `F(φ) ∈ M` implies `F(F(φ)) ∈ M` by the density axiom
2. `F(F(φ)) ∈ M` means there exists W with `CanonicalR M W` and `F(φ) ∈ W`
-/
theorem density_of_canonicalR (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧
      Formula.some_future φ ∈ W := by
  -- Step 1: Apply density axiom: Fφ → FFφ
  have h_density : (Formula.some_future φ).imp (Formula.some_future (Formula.some_future φ)) ∈ M :=
    theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.density φ))
  have h_FF : Formula.some_future (Formula.some_future φ) ∈ M :=
    set_mcs_implication_property h_mcs h_density h_F
  -- Step 2: F(Fφ) ∈ M means ∃ W with CanonicalR M W and Fφ ∈ W
  obtain ⟨W, h_W_mcs, h_R, h_Fφ_W⟩ := canonical_forward_F M h_mcs _ h_FF
  exact ⟨W, h_W_mcs, h_R, h_Fφ_W⟩

end Bimodal.Metalogic.Canonical
