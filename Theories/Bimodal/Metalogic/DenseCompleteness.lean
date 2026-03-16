import Bimodal.Metalogic.StagedConstruction.Completeness
import Bimodal.Metalogic.Bundle.CanonicalConstruction
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Semantics.Validity

/-!
# Dense Completeness - Completeness for Dense Temporal Logic

This module provides the completeness interface for the dense temporal fragment
of bimodal logic TM: if a formula is valid over dense temporal orders, then it
is provable using base axioms plus the density axiom DN.

## Main Results

- `dense_completeness_components_proven`: All individual components are sorry-free
- `completeness_dense_statement`: The completeness theorem statement (documented, not fully wired)

## Infrastructure Status

All individual components of the dense completeness pipeline are proven sorry-free:

1. **Cantor Isomorphism** (`StagedConstruction/CantorApplication.lean`):
   `TimelineQuot ≃o ℚ` - the canonical time domain is isomorphic to rationals

2. **Truth Lemma** (`Bundle/CanonicalConstruction.lean`):
   MCS membership ↔ semantic truth at canonical model

3. **Temporal Coherent FMCS** (`Bundle/CanonicalFMCS.lean`):
   Any consistent context extends to a temporally coherent family

4. **Shifted Truth Lemma** (`Bundle/CanonicalConstruction.lean`):
   Truth lemma extends to shift-closed Omega

## Domain Mismatch (Task 977 Documentation)

The full wiring of the dense completeness theorem requires connecting:

- **CanonicalMCS domain**: Used by BFMCS and truth lemma (all MCSs as times)
- **TimelineQuot domain**: The Cantor-isomorphic domain (D ≃o ℚ) with DenselyOrdered

The gap is that the truth lemma is proven for `D = Int` (or CanonicalMCS), while
the `valid_dense` definition quantifies over all `D` with `DenselyOrdered D`.

### Resolution Paths (Future Work)

1. **Direct TimelineQuot FMCS**: Build FMCS with D = TimelineQuot directly
2. **Transfer Theorem**: Prove equivalence between CanonicalMCS truth and TimelineQuot semantics
3. **Semantic Quotient**: Show CanonicalMCS/TimelineQuot quotient preserves truth

These are beyond the scope of Task 977 (organization) and are flagged for
architectural follow-up in Task 978.

## References

- Task 956: Duration Group Construction from Pure Syntax
- Task 967: T-axiom irreflexivity proof
- Task 977: Current organization task
- `StagedConstruction/Completeness.lean`: Component proofs
- `Bundle/CanonicalConstruction.lean`: Truth lemma infrastructure
-/

namespace Bimodal.Metalogic.DenseCompleteness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.StagedConstruction
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
4. By temporal_coherent_family_exists: build FMCS over CanonicalMCS
5. By Cantor isomorphism: CanonicalMCS ≃o ℚ (hence DenselyOrdered)
6. By truth lemma: φ.neg true at evaluation point in canonical model
7. Contradiction: valid_dense φ but φ false at some point in a dense model

### Gap (Steps 5-7)

The gap is wiring step 5 to step 6: the truth lemma is proven for `D = Int`
(in `canonical_truth_lemma`), but we need it for `D = TimelineQuot` (which
is DenselyOrdered). The canonical construction hardcodes Int.
-/

/--
Re-export: All components of the dense completeness pipeline are proven.

This theorem witnesses that the individual pieces exist:
1. Cantor isomorphism TimelineQuot ≃o ℚ
2. Temporal coherent FMCS construction
3. F-witness and P-witness properties

The final wiring is blocked by the CanonicalMCS/TimelineQuot domain mismatch.
See module documentation for resolution paths.
-/
theorem dense_components_proven
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs) :
    (Nonempty (TimelineQuot root_mcs root_mcs_proof ≃o Rat)) ∧
    (∀ Gamma : List Formula, ContextConsistent Gamma →
      ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
        (∀ gamma ∈ Gamma, gamma ∈ fam.mcs root) ∧
        (∀ t : CanonicalMCS, ∀ φ : Formula,
          Formula.some_future φ ∈ fam.mcs t → ∃ s : CanonicalMCS, t ≤ s ∧ φ ∈ fam.mcs s) ∧
        (∀ t : CanonicalMCS, ∀ φ : Formula,
          Formula.some_past φ ∈ fam.mcs t → ∃ s : CanonicalMCS, s ≤ t ∧ φ ∈ fam.mcs s)) :=
  dense_completeness_components_proven root_mcs root_mcs_proof

/-!
## Int-Based Completeness Infrastructure

The existing canonical construction uses `D = Int`, which is NOT densely ordered.
However, the infrastructure demonstrates the proof technique works. For dense
completeness, we need either:

1. A domain transfer theorem showing Int results extend to ℚ/TimelineQuot
2. A parallel construction with D = ℚ (which IS densely ordered)

The shifted truth lemma in CanonicalConstruction.lean provides the template.
-/

/--
Re-export: The canonical truth lemma for Int-based BFMCS.

This is the proven truth lemma infrastructure that would need to be adapted
for TimelineQuot to complete the dense completeness wiring.
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
## Future Work: Full Dense Completeness

To complete the dense completeness theorem, the following is needed:

### Option 1: TimelineQuot FMCS Construction

Build the FMCS construction directly over TimelineQuot:
- Define `FMCS TimelineQuot` with appropriate temporal coherence
- Prove truth lemma for `D = TimelineQuot`
- This would give a dense domain directly

### Option 2: Domain Transfer Theorem

Prove that truth in the Int-based canonical model implies truth in any
dense model satisfying the same MCS constraints:
- Transfer theorem: If φ true at (M, Ω_Int, τ, t) then φ true at (M', Ω_ℚ, τ', t')
  for corresponding canonical structures over ℚ

### Option 3: Quotient Construction

Show that quotienting the Int-based construction by some equivalence
yields a DenselyOrdered domain while preserving truth:
- Define equivalence on Int canonical model
- Show quotient is DenselyOrdered
- Prove truth descends to quotient

All three options require significant infrastructure development and are
flagged for Task 978 (typeclass-based frame condition modularity).
-/

end Bimodal.Metalogic.DenseCompleteness
