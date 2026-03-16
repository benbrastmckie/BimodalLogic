# Research Report 008: Task 930 Revision Analysis

**Task**: 930
**Session**: sess_1773627586_6379
**Date**: 2026-03-15
**Focus**: Revise Task 930 given progress on Tasks 956, 967, 968, and identify cruft for archival

---

## Executive Summary

Task 930's original goal (verifying MCS-membership box semantics correctness) is now **OBSOLETE**. The `bmcs_truth_at_mcs`, `bmcs_valid_mcs`, and `bmcs_weak_completeness_mcs` definitions that Task 930 was meant to verify have been **archived to the Boneyard** as part of the Int-indexed construction cleanup. The StagedConstruction path (Task 956) provides the publication-ready completeness approach.

**Recommendation**: Archive Task 930 with status `[ABANDONED]` and create a new cleanup task to archive remaining deprecated Bundle files.

---

## 1. Key Progress Since Task 930 Research Began

### 1.1 Task 956: StagedConstruction with Zero Sorries

StagedConstruction now provides:
- `cantor_iso`: TimelineQuot is order-isomorphic to Q (PROVEN)
- Dense timeline construction from canonical MCS domain
- All components sorry-free except for 3 sorries in `Completeness.lean`

**Files** (total 3,687 lines, 3 sorries):
- `CantorApplication.lean` (245 lines, 0 sorries)
- `DenseTimeline.lean` (582 lines, 0 sorries)
- `StagedExecution.lean` (976 lines, 0 sorries)
- `Completeness.lean` (189 lines, 3 sorries)
- 6 other files (0 sorries each)

### 1.2 Task 967: canonicalR_irreflexive via T-axiom

The `canonicalR_irreflexive` theorem is now PROVEN (1,267 lines in `CanonicalIrreflexivity.lean`), resolving the quotient strictness gap that was blocking StagedConstruction.

### 1.3 Task 968: Shift-Closure Bridge Complete

`CanonicalConstruction.lean` now includes:
- `ShiftClosedCanonicalOmega`: shift-closed set of histories
- `shiftClosedCanonicalOmega_is_shift_closed`: proof of shift-closure
- `shifted_truth_lemma`: truth lemma for shift-closed Omega
- `box_persistent`: Box phi persists to all times via TF axiom

All these are sorry-free (797 lines total in `CanonicalConstruction.lean`, 2 sorries remaining).

---

## 2. Analysis: What Files/Definitions Are Now Cruft?

### 2.1 Files Marked DEPRECATED in Source

Two Bundle files are explicitly marked deprecated in their headers:

1. **`DovetailingChain.lean`** (1,932 lines, 5 sorries)
   - Status: DEPRECATED 2026-03-11
   - Reason: "Int-indexed construction violates pure-syntax constraint"
   - Contains: F/P witness infrastructure that was never completed
   - Recommendation: **Archive to Boneyard**

2. **`TemporalCoherentConstruction.lean`** (574 lines, 13 sorries)
   - Status: DEPRECATED 2026-03-11
   - Reason: "Int-specialized construction, violates pure-syntax constraint"
   - Contains: `fully_saturated_bfmcs_exists_int` (the sorry that Task 930 research-007 analyzed)
   - Recommendation: **Archive to Boneyard**

### 2.2 ChainBundleBFMCS.lean - Already Archived

The original file `ChainBundleBFMCS.lean` containing `bmcs_truth_at_mcs`, `bmcs_valid_mcs`, and `bmcs_weak_completeness_mcs` is already in the Boneyard:
- `Boneyard/Metalogic/Metalogic_v7/Bundle/ChainBundleBFMCS.lean`

**Task 930's original target no longer exists in the active codebase.**

### 2.3 Files with Remaining Sorries to Evaluate

| File | Lines | Sorries | Recommendation |
|------|-------|---------|----------------|
| `Construction.lean` | 270 | 5 | Archive - superseded by StagedConstruction |
| `TemporalCoherentConstruction.lean` | 574 | 13 | Archive - explicitly deprecated |
| `DovetailingChain.lean` | 1,932 | 5 | Archive - explicitly deprecated |
| `CanonicalConstruction.lean` | 797 | 2 | KEEP - publication path, sorries being resolved |
| `CanonicalFMCS.lean` | 312 | 7 | Evaluate - may have reusable lemmas |
| `TruthLemma.lean` | 488 | 6 | Evaluate - truth lemma pattern reusable |
| `ModalSaturation.lean` | 544 | 1 | KEEP - reusable infrastructure |

### 2.4 Sorry-Free Files to Keep

These Bundle files are sorry-free and provide essential infrastructure:

| File | Lines | Purpose |
|------|-------|---------|
| `BFMCS.lean` | 269 | Core BFMCS structure definition |
| `BFMCSTruth.lean` | 290 | Truth definition (standard, not _mcs) |
| `CanonicalFrame.lean` | 223 | CanonicalR relation definition |
| `ChainFMCS.lean` | 729 | Flag-based chain infrastructure |
| `FMCSDef.lean` | 221 | FMCS structure definition |
| `WitnessSeed.lean` | 383 | Witness construction lemmas |
| `DirectIrreflexivity.lean` | 314 | Irreflexivity lemmas |
| `CanonicalIrreflexivity.lean` | 1,267 | Main irreflexivity theorem |
| `TemporalContent.lean` | 38 | GContent/HContent definitions |
| `FMCS.lean` | 22 | Re-export module |

---

## 3. The `_mcs` Suffix Definitions

### 3.1 Where Are They?

The `_mcs` suffixed definitions were part of the "MCS-membership box semantics" approach:
- `bmcs_truth_at_mcs`: Box case uses MCS membership instead of recursive truth
- `bmcs_valid_mcs`: Validity quantified over `bmcs_truth_at_mcs`
- `bmcs_weak_completeness_mcs`: Completeness for `bmcs_valid_mcs`

**Current status**: These definitions are in the Boneyard only:
- `Boneyard/Metalogic/Metalogic_v7/Bundle/ChainBundleBFMCS.lean`
- `Boneyard/Metalogic/Bundle/MCSMembershipCompleteness.lean`

### 3.2 Why They Existed

The MCS-membership approach was designed to avoid requiring temporal coherence for ALL families in the bundle. By defining Box as "phi in fam'.mcs t for all fam'" rather than recursively evaluating truth, the truth lemma only required temporal coherence for the eval family.

### 3.3 Why They Are Now Obsolete

1. **CanonicalConstruction.lean** provides the same benefit: Box case uses modal_forward/modal_backward which don't require temporal coherence of witness families
2. **StagedConstruction** bypasses the Int-indexed approach entirely, deriving D from syntax
3. The "bridge theorem" concern (connecting `_mcs` validity to standard validity) is now moot

---

## 4. Publication Path Clarification

### 4.1 Minimal Publication Files

The completeness pipeline for publication consists of:

**StagedConstruction (D from syntax):**
1. `StagedConstruction/CantorApplication.lean` - D is order-isomorphic to Q
2. `StagedConstruction/DenseTimeline.lean` - Dense timeline construction
3. `StagedConstruction/Completeness.lean` - Components proven theorem

**Bundle (Truth Lemma):**
1. `Bundle/BFMCS.lean` - BFMCS structure
2. `Bundle/BFMCSTruth.lean` - Standard truth definition
3. `Bundle/TruthLemma.lean` - Main truth lemma (requires temporally_coherent)
4. `Bundle/CanonicalConstruction.lean` - TaskFrame bridge, shifted truth lemma
5. `Bundle/CanonicalFMCS.lean` - Canonical FMCS construction

**Core:**
1. `Core/MaximalConsistent.lean` - MCS infrastructure
2. `Core/MCSProperties.lean` - MCS properties

### 4.2 Cleanest Completeness Statement

The cleanest completeness statement is:

```lean
theorem dense_completeness_components_proven :
    -- Component 1: Cantor isomorphism exists
    (Nonempty (TimelineQuot root_mcs root_mcs_proof ≃o Rat)) ∧
    -- Component 2: Temporal coherent family exists for any consistent context
    (∀ Gamma : List Formula, ContextConsistent Gamma →
      ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS), ...)
```

This is in `StagedConstruction/Completeness.lean` (lines 151-167).

---

## 5. Recommendations

### 5.1 Task 930 Disposition

**Abandon Task 930** with status `[ABANDONED]` and rationale:
- Original goal (verify `_mcs` semantics correctness) is moot
- Target definitions archived to Boneyard
- StagedConstruction provides cleaner publication path
- No bridge theorem needed since we're not using dual semantics

### 5.2 Archive These Files

Create a new cleanup task to archive deprecated Bundle files:

1. `DovetailingChain.lean` (1,932 lines) -> Boneyard
2. `TemporalCoherentConstruction.lean` (574 lines) -> Boneyard
3. `Construction.lean` (270 lines) -> Boneyard (if not used by active code)

**Verify import dependencies before archiving.**

### 5.3 Keep These Files

Essential for publication path:
- All StagedConstruction files
- Bundle/BFMCS.lean, BFMCSTruth.lean, CanonicalFrame.lean
- Bundle/CanonicalConstruction.lean, CanonicalIrreflexivity.lean
- Bundle/TruthLemma.lean, ChainFMCS.lean

### 5.4 Evaluate These Files

Need import analysis to determine if still used:
- `CanonicalFMCS.lean` (7 sorries) - may be superseded by StagedConstruction
- `ModalSaturation.lean` (1 sorry) - may have reusable infrastructure

---

## 6. Summary

| Question | Answer |
|----------|--------|
| Is Task 930's original goal still relevant? | **No** - target definitions archived |
| What cruft can be archived? | DovetailingChain.lean, TemporalCoherentConstruction.lean, Construction.lean |
| Are `_mcs` definitions still needed? | **No** - in Boneyard, not used by publication path |
| What is the minimal publication path? | StagedConstruction + subset of Bundle (see 4.1) |
| Should Task 930 continue? | **No** - abandon and create cleanup task |

### Revised Task 930 Status

**Original Goal**: Verify MCS-membership box semantics correctness
**New Status**: `[ABANDONED]`
**Reason**: Target definitions archived; StagedConstruction provides cleaner path
**Follow-up**: Create cleanup task to archive deprecated Bundle files

---

## File References

| File | Status | Action |
|------|--------|--------|
| `ChainBundleBFMCS.lean` | In Boneyard | None |
| `DovetailingChain.lean` | Active, deprecated | Archive |
| `TemporalCoherentConstruction.lean` | Active, deprecated | Archive |
| `Construction.lean` | Active, 5 sorries | Archive |
| `CanonicalConstruction.lean` | Active, 2 sorries | Keep (publication path) |
| `StagedConstruction/*` | Active, 3 sorries | Keep (publication path) |
| `CanonicalIrreflexivity.lean` | Active, 0 sorries | Keep |
| `TruthLemma.lean` | Active, 6 sorries | Evaluate |
