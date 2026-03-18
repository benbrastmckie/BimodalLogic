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
Every MCS contains `F(¬⊥)` (derived from seriality axiom `G(¬⊥) → F(¬⊥)`).

Under strict semantics (Task 991), the seriality axiom is `Gφ → Fφ`. For `φ = ¬⊥`:
- `G(¬⊥)` is vacuously true (⊥ is never true, so ¬⊥ is always true)
- Hence `F(¬⊥)` follows by seriality

Alternatively, this follows from the fact that every MCS must contain F(¬⊥)
by maximality and the non-emptiness of the temporal domain (NoMaxOrder).
-/
theorem SetMaximalConsistent.contains_seriality_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_future (Formula.neg Formula.bot) ∈ M := by
  -- G(¬⊥) is true since ¬⊥ is a tautology (derivable from ex_falso contrapositive)
  have h_neg_bot_deriv : [] ⊢ Formula.neg Formula.bot := by
    -- ¬⊥ = ⊥ → ⊥, which follows from identity
    exact DerivationTree.axiom [] _ (Axiom.prop_s Formula.bot Formula.bot)
  -- Actually we need to derive G(¬⊥) first, then apply seriality
  -- For now, use the fact that this is provable in the system
  sorry

/--
Every MCS contains `P(¬⊥)` (derived from seriality axiom `H(¬⊥) → P(¬⊥)`).

Under strict semantics (Task 991), the seriality axiom is `Hφ → Pφ`. For `φ = ¬⊥`:
- `H(¬⊥)` is vacuously true (⊥ is never true, so ¬⊥ is always true)
- Hence `P(¬⊥)` follows by seriality
-/
theorem SetMaximalConsistent.contains_seriality_past (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_past (Formula.neg Formula.bot) ∈ M := by
  -- Similar to contains_seriality_future
  sorry

/--
Every MCS has a strict canonical future successor.

From `F(¬⊥) ∈ M` and `canonical_forward_F`, there exists MCS W with
`CanonicalR M W` and `¬⊥ ∈ W`.
-/
theorem SetMaximalConsistent.has_canonical_successor (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W := by
  have h_F := SetMaximalConsistent.contains_seriality_future M h_mcs
  obtain ⟨W, h_W_mcs, h_R, _⟩ := canonical_forward_F M h_mcs _ h_F
  exact ⟨W, h_W_mcs, h_R⟩

/--
Every MCS has a strict canonical past predecessor.

From `P(¬⊥) ∈ M` and `canonical_backward_P`, there exists MCS W with
`CanonicalR_past M W` and `¬⊥ ∈ W`.
-/
theorem SetMaximalConsistent.has_canonical_predecessor (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR_past M W := by
  have h_P := SetMaximalConsistent.contains_seriality_past M h_mcs
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

Under strict semantics (Task 991), the density axiom is `GGφ → Gφ` (Sahlqvist form).
The existential form `Fφ → FFφ` is derivable from it:
- `Fφ → FFφ` is the contrapositive of `GG(¬φ) → G(¬φ)` (density applied to ¬φ)
- Actually we need the dual density for the some_future direction

The proof uses:
1. `F(φ) ∈ M` implies `F(F(φ)) ∈ M` by the dual density
2. `F(F(φ)) ∈ M` means there exists W with `CanonicalR M W` and `F(φ) ∈ W`
-/
theorem density_of_canonicalR (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧
      Formula.some_future φ ∈ W := by
  -- The density axiom is now GGψ → Gψ, not Fφ → FFφ.
  -- Fφ → FFφ is equivalent to ¬GG¬φ → ¬G¬φ, which is the contrapositive of GGψ → Gψ for ψ = ¬φ.
  -- But the proof direction requires Fφ → FFφ, not GGψ → Gψ.
  -- Under dense orders, Fφ → FFφ remains valid (just not as an axiom).
  -- TODO (Task 991): Derive Fφ → FFφ from GGψ → Gψ
  sorry

end Bimodal.Metalogic.Canonical
