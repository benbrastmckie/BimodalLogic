import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Bundle.CanonicalIrreflexivity

/-!
# DEPRECATED: Canonical Accessibility Relation Irreflexivity

## Status: AXIOM-BASED, DEPRECATED (Task 29)

**WARNING**: Under reflexive semantics (G/H quantify over s ≥ t / s ≤ t), the
canonical accessibility relation is REFLEXIVE, not irreflexive.

- `canonicalR_reflexive` is PROVEN via T-axiom (see Bundle/CanonicalIrreflexivity.lean)
- `canonicalR_irreflexive` is an AXIOM that contradicts reflexivity

These theorems are preserved temporarily to avoid breaking ~40 downstream call sites.
They introduce an INCONSISTENCY into the system.

## Task 29 Resolution: Per-Construction Strictness

Instead of universal irreflexivity, call sites should prove strictness from the
specific construction:

1. Given a witness W constructed from M
2. Prove `¬CanonicalR W M` from the formula that distinguishes W from M
3. This typically follows from: φ ∈ g_content(W), φ ∉ M

See `fresh_Gp_seed_consistent` in Bundle/CanonicalIrreflexivity.lean for the
building block when a fresh atom is provided by the specific construction.

## Historical Context

This file previously claimed irreflexivity was a "proven theorem" via the Gabbay
IRR rule with T-axiom. However:
- The IRR rule is UNSOUND under reflexive semantics
- The T-axiom PROVES reflexivity (G(φ) → φ means g_content(M) ⊆ M)
- Universal fresh atom existence is NOT provable (pathological MCS can cover all atoms)

## TODO (Task 29 Phase 5+)

- Phase 5B/5C: Refactor all call sites to use per-construction strictness
- Phase 6: Delete `canonicalR_irreflexive_axiom`
- Phase 7: Remove this file or convert to per-construction strictness module
-/

namespace Bimodal.Metalogic.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/--
**DEPRECATED**: Under reflexive semantics, CanonicalR is REFLEXIVE, not irreflexive.
This theorem is axiom-based and contradicts `canonicalR_reflexive`.

Use per-construction strictness instead: prove ¬CanonicalR W M from the specific
formula that distinguishes the witness from the source.
-/
@[deprecated "Use per-construction strictness instead of universal irreflexivity"]
theorem canonicalR_irreflexive :
  ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M :=
  Bimodal.Metalogic.Bundle.canonicalR_irreflexive

/--
**DEPRECATED**: Based on the false `canonicalR_irreflexive` axiom.

Under reflexive semantics, antisymmetry FAILS for CanonicalR.
Mutual accessibility (M R N ∧ N R M) is possible without M = N.
-/
@[deprecated "Antisymmetry fails under reflexive semantics"]
theorem canonicalR_antisymmetric_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) (h_NM : CanonicalR N M) : False :=
  canonicalR_irreflexive M hM (canonicalR_transitive M N M hM h_MN h_NM)

/--
**DEPRECATED**: Based on the false `canonicalR_irreflexive` axiom.

Use per-construction strictness: prove ¬CanonicalR N M from the specific
formula witness that distinguishes N from M.
-/
@[deprecated "Use per-construction strictness"]
theorem canonicalR_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) : ¬CanonicalR N M :=
  fun h_NM => canonicalR_antisymmetric_strict M N hM hN h_MN h_NM

end Bimodal.Metalogic.Canonical
