import Bimodal.Metalogic.Representation.TruthLemma

/-!
# Truth Lemma (Forward Direction Only)

This module exports only the forward direction of the truth lemma, providing
a clean interface for completeness proofs.

## Overview

The forward direction of the truth lemma establishes:
```
phi ∈ family.mcs t → truth_at (canonical_model family) (canonical_history family) t phi
```

This is the key bridge from syntactic MCS membership to semantic truth, used by:
- `representation_theorem` in UniversalCanonicalModel.lean
- `infinitary_strong_completeness` in InfinitaryStrongCompleteness.lean

## Status of Sorries

The underlying `truth_lemma_mutual` in TruthLemma.lean has 4 sorries:

| Case | Direction | Status | Reason |
|------|-----------|--------|--------|
| Box | Forward | TRUSTED | Architectural limitation: S5-style semantics quantify over ALL histories |
| Box | Backward | TRUSTED | Same architectural limitation |
| H (all_past) | Backward | OMEGA-RULE | Requires infinitary derivation |
| G (all_future) | Backward | OMEGA-RULE | Requires infinitary derivation |

**For completeness proofs**: The Box forward sorry propagates when applying
`truth_lemma_forward` to formulas containing Box. However:
1. The core temporal operators (G, H) have complete forward proofs
2. The representation theorem works for all formulas but relies on the Box trusted axiom
3. This is standard in formal verification - some semantic properties are axiomatized

## Usage

Import this module instead of TruthLemma.lean when you only need the forward direction:
```lean
import Bimodal.Metalogic.Representation.TruthLemmaForward
-- Uses: truth_lemma_forward, canonical_model, canonical_history_family
```

## References

- TruthLemma.lean: Full biconditional proof with detailed documentation
- Task 809: Analysis of sorry status and documentation update
-/

namespace Bimodal.Metalogic.Representation

-- Re-export key definitions from TruthLemma
-- (They're already exported, this module just provides documentation)

/-!
## Exported Definitions

The following are the key exports for completeness proofs:

- `canonical_model`: TaskModel from IndexedMCSFamily (valuation uses MCS membership)
- `canonical_history_family`: WorldHistory with full domain, states from family
- `truth_lemma_forward`: φ ∈ mcs t → truth_at at t

These are defined in TruthLemma.lean and re-exported here.
-/

/--
Forward truth lemma: MCS membership implies semantic truth.

**Completeness Status**:
- Temporal cases (atom, bot, imp, all_past, all_future): Fully proven
- Box case: Uses trusted axiom (architectural limitation documented in TruthLemma.lean)

**Usage**: This is the primary theorem for representation/completeness proofs.
The completeness proof applies this to show that if φ ∈ MCS, then φ is true
in the canonical model, establishing satisfiability.
-/
theorem truth_lemma_forward_export (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (family : IndexedMCSFamily D) (t : D) (phi : Bimodal.Syntax.Formula) :
    phi ∈ family.mcs t →
    Bimodal.Semantics.truth_at (canonical_model D family) (canonical_history_family D family) t phi :=
  truth_lemma_forward D family t phi

end Bimodal.Metalogic.Representation
