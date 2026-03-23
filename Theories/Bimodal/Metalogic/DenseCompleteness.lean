import Bimodal.Metalogic.Bundle.CanonicalConstruction
import Bimodal.Metalogic.Bundle.BFMCS
-- REMOVED (Task 41): import Bimodal.Metalogic.Bundle.CanonicalFMCS
-- CanonicalFMCS uses D=CanonicalMCS confused pattern; deleted
import Bimodal.Semantics.Validity

/-!
# Dense Completeness - Completeness for Dense Temporal Logic

This module provides the completeness interface for the dense temporal fragment
of bimodal logic TM: if a formula is valid over dense temporal orders, then it
is provable using base axioms plus the density axiom DN.

## Main Results

- `canonical_truth_lemma_int`: Truth lemma for Int-based canonical construction
- `shifted_truth_lemma_int`: Shifted truth lemma for shift-closed Omega

## Current Status: SuccChain Architecture

Dense completeness is being rebuilt using the SuccChain architecture.
The StagedConstruction approach has been archived to Boneyard (task 43).

See `Bimodal.Metalogic.SuccChain/` for the current approach.

## Infrastructure Status

The following infrastructure components are proven sorry-free:

1. **Truth Lemma** (`Bundle/CanonicalConstruction.lean`):
   MCS membership ↔ semantic truth at canonical model

2. **Temporal Coherent FMCS** (`Bundle/CanonicalFMCS.lean`):
   Any consistent context extends to a temporally coherent family

3. **Shifted Truth Lemma** (`Bundle/CanonicalConstruction.lean`):
   Truth lemma extends to shift-closed Omega

## Domain Mismatch (Tasks 977, 1006 Analysis)

The full wiring of the dense completeness theorem requires connecting:

- **CanonicalMCS indexing**: Used by BFMCS for proof-theoretic trivial F/P witnesses
- **Domain D**: A domain with DenselyOrdered for dense completeness
- **ParametricCanonicalTaskFrame D**: Requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

The gap is that the truth lemma is proven for `D = Int` (or CanonicalMCS), while
the `valid_dense` definition quantifies over all `D` with `DenselyOrdered D`.

### SuccChain Resolution

The SuccChain architecture addresses this gap by:
1. Building timelines on dedicated domain type D (not conflating with MCSs)
2. Using successor chain construction for density properties
3. Properly separating algebraic structure from semantic interpretation

## References

- Task 43: Archive StagedConstruction to Boneyard
- Task 956: Duration Group Construction from Pure Syntax
- Task 977: Current organization task
- `SuccChain/`: Successor chain completeness (active development)
- `Bundle/CanonicalConstruction.lean`: Truth lemma infrastructure
-/

namespace Bimodal.Metalogic.DenseCompleteness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.Canonical

/-!
## Dense Completeness Statement

The dense completeness theorem states that validity over dense temporal orders
implies provability using the dense axiom set (base + DN).

### Formal Statement

```
theorem completeness_dense (φ : Formula) :
    valid_dense φ → Nonempty (⊢_dense φ)
```

where `⊢_dense φ` means derivable using base axioms plus the density axiom DN.

### Proof Sketch (Contrapositive)

1. Assume φ is not derivable in the dense proof system
2. Then [φ.neg] is consistent (otherwise φ would be derivable)
3. By Lindenbaum: extend [φ.neg] to MCS S₀
4. By SuccChain construction: build FMCS over domain D
5. By SuccChain density: D is DenselyOrdered
6. By truth lemma: φ.neg true at evaluation point in canonical model
7. Contradiction: valid_dense φ but φ false at some point in a dense model

### Current Status

The SuccChain architecture is being developed to complete this proof.
See `Bimodal.Metalogic.SuccChain/` for current progress.
-/

/-!
## Int-Based Completeness Infrastructure

The existing canonical construction uses `D = Int`, which is NOT densely ordered.
However, the infrastructure demonstrates the proof technique works. For dense
completeness, we need the SuccChain construction which builds a dense domain.
-/

/--
Re-export: The canonical truth lemma for Int-based BFMCS.

This is the proven truth lemma infrastructure that demonstrates the technique.
The SuccChain architecture extends this to dense domains.
-/
theorem canonical_truth_lemma_int
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (φ : Formula) :
    φ ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t φ :=
  canonical_truth_lemma B h_tc fam hfam t φ

/--
Re-export: The shifted truth lemma extends to shift-closed Omega.

This is the version needed for connecting to standard validity (which requires
ShiftClosed Omega). The shift-closure pattern is proven for Int.
-/
theorem shifted_truth_lemma_int
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (φ : Formula) (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t φ :=
  shifted_truth_lemma B h_tc φ fam hfam t

/-!
## Future Work: Full Dense Completeness via SuccChain

The SuccChain architecture is being developed to complete dense completeness:

### SuccChain Construction

Build the timeline construction directly over a dense domain:
- Define successor chain construction on dedicated domain D
- Prove D has DenselyOrdered, NoMaxOrder, NoMinOrder
- Build FMCS over D with appropriate temporal coherence
- Prove truth lemma for the SuccChain construction

### Key Property: W/D Separation

The SuccChain approach correctly separates:
- W = MCSs (worlds for modal semantics)
- D = Timeline domain (ordered points for temporal semantics)

This avoids the conflation that blocked the StagedConstruction approach.

### References

- `Bimodal.Metalogic.SuccChain/` - Active development
- Task 43 research report - Analysis of StagedConstruction blockers
-/

end Bimodal.Metalogic.DenseCompleteness
