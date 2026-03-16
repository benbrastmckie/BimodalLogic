# Teammate A Findings: Sorry/Axiom Audit

**Task**: 929 - Prepare metalogic for publication
**Run**: 001
**Date**: 2026-03-15
**Focus**: Sorry/axiom audit and publication path analysis

---

## Executive Summary

The publication path (StagedConstruction + essential Bundle files) is **sorry-free** and depends only on standard Lean axioms (propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler). All active sorries are in files marked for archival (deprecated) or in alternative/discrete construction paths not on the publication path.

**Key findings**:
- **0 sorries** on publication path (StagedConstruction + essential Bundle)
- **0 custom axioms** in active codebase (all removed/archived)
- **13 sorries** total in active non-Boneyard Metalogic (all in deprecated or non-publication files)
- Key theorems (`cantor_iso`, `bmcs_truth_lemma`, `canonicalR_irreflexive`) verified clean

---

## Sorry Audit

### Publication Path (StagedConstruction)

| File | Lines | Sorries | Status |
|------|-------|---------|--------|
| CantorApplication.lean | 245 | 0 | Clean |
| DenseTimeline.lean | 582 | 0 | Clean |
| Completeness.lean | 189 | 0 | Clean |
| StagedExecution.lean | 976 | 0 | Clean |
| CantorPrereqs.lean | 18064 | 0 | Clean |
| DensityFrameCondition.lean | 728 | 0 | Clean |
| DFromCantor.lean | 435 | 0 | Clean |
| SeparationLemma.lean | 327 | 0 | Clean |
| StagedTimeline.lean | 415 | 0 | Clean |
| WitnessSeedWrapper.lean | 427 | 0 | Clean |

**StagedConstruction Total: 0 sorries**

### Essential Bundle (Publication Path)

| File | Lines | Sorries | Status |
|------|-------|---------|--------|
| BFMCS.lean | 269 | 0 | Clean |
| BFMCSTruth.lean | 290 | 0 | Clean |
| CanonicalFrame.lean | 223 | 0 | Clean |
| CanonicalConstruction.lean | 797 | 0 | Clean |
| CanonicalIrreflexivity.lean | 1267 | 0 | Clean |
| TruthLemma.lean | 488 | 0 | Clean |
| ChainFMCS.lean | 729 | 0 | Clean |

**Essential Bundle Total: 0 sorries**

### Non-Publication Path (Active Sorries)

| File | Line | Category | Context | Remediation |
|------|------|----------|---------|-------------|
| ConstructiveFragment.lean | 579 | Construction placeholder | NoMaxOrder.exists_gt | Archive (non-publication path) |
| ConstructiveFragment.lean | 584 | Construction placeholder | NoMinOrder.exists_lt | Archive (non-publication path) |
| DiscreteTimeline.lean | 179 | Frame condition | SuccOrder.le_succ | Archive (discrete-only) |
| DiscreteTimeline.lean | 187 | Frame condition | SuccOrder.max_of_succ_le | Archive (discrete-only) |
| DiscreteTimeline.lean | 200 | Frame condition | SuccOrder.succ_le_of_lt (coverness) | Archive (discrete-only) |
| DiscreteTimeline.lean | 212 | Frame condition | PredOrder.pred_le | Archive (discrete-only) |
| DiscreteTimeline.lean | 213 | Frame condition | PredOrder.min_of_le_pred | Archive (discrete-only) |
| DiscreteTimeline.lean | 218 | Frame condition | PredOrder.le_pred_of_lt | Archive (discrete-only) |
| DiscreteTimeline.lean | 231 | Frame condition | IsSuccArchimedean | Archive (discrete-only) |
| TemporalCoherentConstruction.lean | 422 | Deprecated construction | temporal_coherent_family_exists_Int | Archive (deprecated) |
| TemporalCoherentConstruction.lean | 516 | Deprecated construction | fully_saturated_bfmcs_exists_int | Archive (deprecated) |
| DovetailingChain.lean | 1893 | Deprecated construction | forward_F witness | Archive (deprecated) |
| DovetailingChain.lean | 1905 | Deprecated construction | backward_P witness | Archive (deprecated) |

**Non-Publication Path Total: 13 sorries**

---

## Axiom Audit

### Custom Axiom Declarations

| File | Line | Declaration | Category | Remediation |
|------|------|-------------|----------|-------------|
| (none) | - | - | - | - |

**Result**: No custom axiom declarations found in active codebase (excluding Boneyard).

All previous axioms have been:
1. **Removed**: `canonicalR_irreflexive_axiom` replaced with theorem proof (Task 967)
2. **Archived**: `temporal_coherent_family_exists` axiom moved to Boneyard
3. **Archived**: `fully_saturated_bfmcs_exists` axiom moved to Boneyard

---

## Publication Path Status

### StagedConstruction
- **Sorries**: 0
- **Custom Axioms**: 0
- **Status**: Publication-ready

### Essential Bundle
- **Sorries**: 0
- **Custom Axioms**: 0
- **Status**: Publication-ready

### Overall Publication Path
- **Total Sorries**: 0
- **Total Custom Axioms**: 0
- **Status**: Publication-ready

---

## Key Theorem Axiom Dependencies

Verified via `#print axioms`:

### cantor_iso
```
propext
Classical.choice
Lean.ofReduceBool
Lean.trustCompiler
Quot.sound
```

### dense_completeness_components_proven
```
propext
Classical.choice
Lean.ofReduceBool
Lean.trustCompiler
Quot.sound
```

### bmcs_truth_lemma
```
propext
Classical.choice
Lean.ofReduceBool
Lean.trustCompiler
Quot.sound
```

### canonicalR_irreflexive
```
propext
Classical.choice
Lean.ofReduceBool
Lean.trustCompiler
Quot.sound
```

**Analysis**: All key theorems depend only on standard Lean/Mathlib axioms:
- `propext`: Propositional extensionality (standard)
- `Classical.choice`: Classical choice (expected for non-constructive math)
- `Quot.sound`: Quotient soundness (standard)
- `Lean.ofReduceBool`, `Lean.trustCompiler`: Lean compiler axioms (standard)

No custom project axioms pollute the dependency chain.

---

## Recommendations

### Immediate Actions

1. **Archive deprecated files** (priority: high)
   - `DovetailingChain.lean` (1932 lines, 2 sorries) -> Boneyard
   - `TemporalCoherentConstruction.lean` (574 lines, 2 sorries) -> Boneyard
   - Both files explicitly marked DEPRECATED in headers

2. **Archive alternative construction files** (priority: medium)
   - `Construction.lean` (270 lines) -> Boneyard (if no active imports)
   - `ConstructiveFragment.lean` sorries -> Document as non-publication path

3. **Document discrete timeline status** (priority: low)
   - `DiscreteTimeline.lean` sorries are for discrete tense logic (DF axiom)
   - Not required for dense completeness publication
   - Mark as separate research track

### Publication Readiness

The publication path is verified clean:
1. StagedConstruction provides D-from-syntax completeness
2. Essential Bundle provides truth lemma infrastructure
3. CanonicalIrreflexivity provides the critical T-axiom proof
4. No sorries, no custom axioms

### Disclosure for Publication

For a paper, disclose standard axioms used:
- Classical logic (Classical.choice)
- Propositional extensionality (propext)
- Quotient soundness (Quot.sound)

These are standard for non-constructive mathematics and expected by reviewers.

---

## Confidence Level

**High**

- Systematic grep-based search for `sorry` and `axiom` declarations
- Verified all matches are either in comments or on non-publication path
- `#print axioms` confirms key theorems have only standard dependencies
- Cross-referenced with research-008.md context on archival decisions

---

## Files Referenced

### Publication Path (Keep)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/*.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`

### Archive Candidates
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Construction.lean`

### Non-Publication Path (Retain for Future Work)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`
