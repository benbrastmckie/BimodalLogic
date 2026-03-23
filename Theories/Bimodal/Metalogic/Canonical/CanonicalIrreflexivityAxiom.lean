import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Bundle.CanonicalIrreflexivity

/-!
# Canonical Accessibility Relation: Irreflexivity for Order-Theoretic Enhancements

## Status: ORDER-THEORETIC ENHANCEMENT (Task 29 v8)

### Two-Layer Architecture

This module provides `canonicalR_irreflexive` and `canonicalR_strict` for use by
ORDER-THEORETIC ENHANCEMENTS (Layer 2). Basic completeness (Layer 1) does NOT
use these theorems.

**Layer 1 (Basic Completeness)**: Does NOT import this file.
- Uses reflexive preorder structure (canonicalR_reflexive)
- Completeness proofs are axiom-free

**Layer 2 (Order-Theoretic Enhancements)**: Imports this file.
- CantorApplication.lean (TimelineQuot ≃o ℚ)
- DovetailedTimelineQuot.lean, DiscreteTimeline.lean
- NoMaxOrder, NoMinOrder, DenselyOrdered instances

### Semantic Warning

Under reflexive semantics (G/H quantify over s ≥ t / s ≤ t), the canonical
accessibility relation is REFLEXIVE via T-axiom. The theorems in this file
CONTRADICT reflexivity and introduce an inconsistency.

This inconsistency is ISOLATED to order-theoretic enhancements and does NOT
affect basic completeness.

### Usage

These theorems are used by:
1. NoMaxOrder/NoMinOrder instances (strictness in quotient)
2. DenselyOrdered instances (strict intermediates)
3. Cantor isomorphism prerequisites
-/

namespace Bimodal.Metalogic.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/--
**DEPRECATED**: Under reflexive semantics, ExistsTask is REFLEXIVE, not irreflexive.
This theorem is axiom-based and contradicts `canonicalR_reflexive`.

Use per-construction strictness instead: prove ¬ExistsTask W M from the specific
formula that distinguishes the witness from the source.
-/
@[deprecated "Use per-construction strictness instead of universal irreflexivity"]
theorem canonicalR_irreflexive :
  ∀ (M : Set Formula), SetMaximalConsistent M → ¬ExistsTask M M :=
  Bimodal.Metalogic.Bundle.canonicalR_irreflexive

/--
**DEPRECATED**: Based on the false `canonicalR_irreflexive` axiom.

Under reflexive semantics, antisymmetry FAILS for ExistsTask.
Mutual accessibility (M R N ∧ N R M) is possible without M = N.
-/
@[deprecated "Antisymmetry fails under reflexive semantics"]
theorem canonicalR_antisymmetric_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : ExistsTask M N) (h_NM : ExistsTask N M) : False :=
  canonicalR_irreflexive M hM (canonicalR_transitive M N M hM h_MN h_NM)

/--
**DEPRECATED**: Based on the false `canonicalR_irreflexive` axiom.

Use per-construction strictness: prove ¬ExistsTask N M from the specific
formula witness that distinguishes N from M.
-/
@[deprecated "Use per-construction strictness"]
theorem canonicalR_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : ExistsTask M N) : ¬ExistsTask N M :=
  fun h_NM => canonicalR_antisymmetric_strict M N hM hN h_MN h_NM

end Bimodal.Metalogic.Canonical
