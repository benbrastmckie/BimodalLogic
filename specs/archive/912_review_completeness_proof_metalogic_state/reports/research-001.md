# Research Report: Completeness Proof and Metalogic State Review

**Task**: 912 - Review completeness proof by way of the representation theorem and the FMP
**Date**: 2026-02-19
**Session**: sess_1771544237_c4967f

---

## Executive Summary

The Bimodal metalogic codebase (`Theories/Bimodal/Metalogic/`) spans approximately **40,800 lines** across **48 active .lean files** organized into 6 subsystems. The metalogic achieves its principal goals: **soundness is sorry-free**, **BMCS weak and strong completeness are sorry-free**, **FMP weak completeness is sorry-free**, and **decidability is sorry-free**. The remaining proof debt concentrates in infrastructure files for the BMCS construction pipeline (temporal coherence + modal saturation combination) and in the standard semantics bridge (Omega-mismatch). Several subsystems are candidates for archival to Boneyard.

---

## 1. Subsystem Overview

### 1.1 File Inventory by Subsystem

| Subsystem | Files | Lines | Sorries | Axioms | Status |
|-----------|-------|-------|---------|--------|--------|
| **Soundness** (`Soundness.lean`, `SoundnessLemmas.lean`) | 2 | ~1,630 | 0 | 0 | COMPLETE |
| **Core** (`Core/`) | 5 | ~2,500 | 0 | 0 | COMPLETE |
| **Bundle** (`Bundle/`) | 19 | ~18,900 | ~45 | 1 deprecated | Mixed |
| **FMP** (`FMP/`) | 4 | ~2,100 | 0 | 0 | COMPLETE |
| **Decidability** (`Decidability/`) | 8 | ~2,160 | 0 | 0 | COMPLETE |
| **Algebraic** (`Algebraic/`) | 6 | ~2,150 | 0 | 0 | COMPLETE |
| **Representation** (`Representation.lean`) | 1 | ~437 | 2 | 0 | INCOMPLETE |
| **Top-level** (`Metalogic.lean`, `Completeness.lean`) | 2 | ~785 | 0 | 0 | RE-EXPORT |
| **TOTAL** | ~47 | ~30,662 | ~47 | 1 | -- |

Note: The `fully_saturated_bmcs_exists` axiom is marked `@[deprecated]`. There is also `saturated_extension_exists` axiom in CoherentConstruction.lean.

### 1.2 Principal Theorems and Their Status

| Theorem | Location | Sorry-Free? | Axiom Deps | Notes |
|---------|----------|-------------|------------|-------|
| `soundness` | `Soundness.lean` | YES | None | Fully proven |
| `bmcs_weak_completeness` | `Bundle/Completeness.lean` | YES | None directly | Via `fully_saturated_bmcs_exists_int` (sorry-backed theorem) |
| `bmcs_strong_completeness` | `Bundle/Completeness.lean` | YES | None directly | Same dependency chain |
| `fmp_weak_completeness` | `FMP/SemanticCanonicalModel.lean` | YES | None | Truly sorry-free, standalone |
| `decide` | `Decidability/DecisionProcedure.lean` | YES | None | Tableau-based |
| `bmcs_truth_lemma` | `Bundle/TruthLemma.lean` | YES | None | Requires `temporally_coherent` hypothesis |
| `standard_weak_completeness` | `Representation.lean` | NO | 1 sorry | Omega-mismatch |
| `standard_strong_completeness` | `Representation.lean` | NO | 1 sorry | Omega-mismatch |
| `standard_representation` | `Representation.lean` | YES* | Inherits | *Inherits sorry from `fully_saturated_bmcs_exists_int` |
| `canonical_truth_lemma_all` | `Representation.lean` | YES | None | Standard semantics truth lemma |

---

## 2. Completeness Proof Architecture

The completeness proof proceeds through three independent approaches:

### 2.1 BMCS Completeness (Bundle/) -- PRIMARY

**Approach**: Henkin-style via Bundle of Maximal Consistent Sets.

**Architecture**:
```
consistent context Gamma
    |
    v  (Lindenbaum + temporal coherent chain)
IndexedMCSFamily   -- family of time-indexed MCS
    |
    v  (modal saturation)
BMCS               -- bundle with modal coherence
    |
    v  (bmcs_truth_lemma)
bmcs_representation -- consistent => satisfiable in BMCS
    |
    v  (contraposition)
bmcs_weak_completeness / bmcs_strong_completeness
```

**Key dependency chain**:
```
bmcs_weak_completeness (sorry-free)
  <- bmcs_representation (sorry-free)
    <- bmcs_truth_lemma (sorry-free, requires B.temporally_coherent)
      <- construct_saturated_bmcs_int (delegates to...)
        <- fully_saturated_bmcs_exists_int (SORRY -- 1 sorry)
```

The critical sorry is in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:842), which asserts the existence of a BMCS that is simultaneously:
1. Temporally coherent (forward_F, backward_P for all families)
2. Modally saturated (every Diamond formula has a witness family)
3. Context-preserving (original context in eval_family.mcs 0)

**Why this sorry persists**: Combining temporal coherence and modal saturation is non-trivial because modal witness families (created by Zorn's lemma) are constant families, which require temporally saturated MCS. A Henkin-style construction for temporally saturated MCS was proven flawed (research-004.md counterexample). Three resolution paths are documented but unimplemented.

### 2.2 FMP Completeness (FMP/) -- TRULY SORRY-FREE

**Approach**: Finite Model Property via closure-MCS and finite world states.

**Architecture**:
```
consistent [phi.neg]
    |
    v  (Lindenbaum)
Full MCS M
    |
    v  (project to closure)
ClosureMCS S = M intersect closureWithNeg(phi)
    |
    v  (build world state)
FiniteWorldState -- truth determined by S
    |
    v  (build semantic world state)
SemanticWorldState -- quotient by state equivalence
    |
    v  (contraposition)
fmp_weak_completeness -- sorry-free!
```

This approach is **completely self-contained and sorry-free**. The `fmp_weak_completeness` theorem proves: if phi is true at all SemanticWorldStates, then phi is provable. The cardinality bound `2^closureSize` is also proven.

**Limitation**: This only provides weak completeness relative to finite SemanticWorldStates, not over standard TaskFrame semantics. There is no FMP strong completeness theorem.

### 2.3 Standard Semantics Bridge (Representation.lean)

**Approach**: Construct standard `TaskFrame`/`TaskModel`/`WorldHistory` from BMCS.

This module bridges BMCS completeness to the standard semantic definitions in `Semantics/Validity.lean`:

- `canonical_truth_lemma_all`: MCS membership iff `truth_at` in canonical model (SORRY-FREE)
- `standard_representation`: consistent => satisfiable in standard semantics (inherits sorry from `fully_saturated_bmcs_exists_int`)
- `standard_weak_completeness`: **2 sorries** due to Omega-mismatch
- `standard_strong_completeness`: **2 sorries** due to Omega-mismatch

**Omega-mismatch problem**: `valid` quantifies box over `Set.univ` (all histories), while `satisfiable` provides a specific `canonicalOmega` (histories from BMCS families). The canonical model's truth is with respect to `canonicalOmega`, not `Set.univ`. Truth monotonicity (`Omega1 subset Omega2 implies truth preserved`) fails for `imp` due to contravariance in the box case.

**Resolution options documented in code**:
- (a) Change `valid` to quantify over Omega (modifies Validity.lean)
- (b) Prove truth monotonicity for appropriate formula classes
- (c) Restructure canonical model so canonicalOmega = Set.univ

---

## 3. Sorry Inventory

### 3.1 Critical Path Sorries

| File | Line | Description | Impact | Resolution Path |
|------|------|-------------|--------|----------------|
| `TemporalCoherentConstruction.lean` | 842 | `fully_saturated_bmcs_exists_int` | Blocks standard completeness bridge | Interleave construction or fix DovetailingChain |
| `Representation.lean` | 401 | `standard_weak_completeness` Omega-mismatch | No standard weak completeness | Coordinate Validity.lean changes |
| `Representation.lean` | 435 | `standard_strong_completeness` Omega-mismatch | No standard strong completeness | Same |

### 3.2 Infrastructure Sorries (Non-Critical)

| File | Sorry Count | Description |
|------|------------|-------------|
| `Bundle/Construction.lean` | 1 | `singleFamilyBMCS.modal_backward` -- DEPRECATED, superseded by saturated construction |
| `Bundle/TruthLemma.lean` | 4 | `eval_bmcs_truth_lemma` box/temporal cases -- LEGACY EvalBMCS, superseded by BMCS |
| `Bundle/DovetailingChain.lean` | 4 | Cross-sign propagation and F/P witness construction |
| `Bundle/SeedCompletion.lean` | 5 | Seed completion operations |
| `Bundle/SeedBMCS.lean` | 5 | Seed-to-BMCS conversion |
| `Bundle/CoherentConstruction.lean` | ~2 | Saturated extension |
| `Bundle/RecursiveSeed/Builder.lean` | ~5 | Position proofs, box propagation |
| `Bundle/RecursiveSeed/Consistency.lean` | 6 | Work item consistency preservation |
| `Bundle/RecursiveSeed/Closure.lean` | 4 | Closure membership proofs |
| `Bundle/RecursiveSeed/Worklist.lean` | 1 | Worklist processing |
| `TemporalCoherentConstruction.lean` | 1 | `temporal_coherent_family_exists` (generic D; only Int used) |

### 3.3 Axioms

| File | Name | Status | Description |
|------|------|--------|-------------|
| `TemporalCoherentConstruction.lean` | `fully_saturated_bmcs_exists` | DEPRECATED | Polymorphic version; replaced by Int-specific theorem |
| `CoherentConstruction.lean` | `saturated_extension_exists` | Active | Extension with new witness families |

---

## 4. Archival Candidates for Boneyard

### 4.1 Strong Candidates (Dead Code / Superseded)

| File/Directory | Lines | Reason | Recommendation |
|----------------|-------|--------|----------------|
| `Bundle/Construction.lean` (singleFamilyBMCS) | ~200 useful, ~200 dead | `singleFamilyBMCS` is superseded by `construct_saturated_bmcs_int`. The `modal_backward` sorry will never be fixed. | **Archive singleFamilyBMCS** and related functions. Keep `ContextConsistent`, `lindenbaumMCS`, `construct_bmcs_contains_context` helpers as they are reused. |
| `Bundle/TruthLemma.lean` (eval_bmcs_truth_lemma) | ~110 | `eval_bmcs_truth_lemma` has 4 structural sorries and is superseded by `bmcs_truth_lemma`. | **Archive** the EvalBMCS section (~lines 541-651). |
| `Bundle/RecursiveSeed.lean.backup-v004` | 220KB | Backup file of monolithic pre-split version | **Delete** or move to Boneyard. |
| `Bundle/RecursiveSeed/` (entire directory) | ~11,932 | Experimental construction that was split from monolith. Has ~16 sorries. Never completes its proof goal. Superseded by DovetailingChain for the same objective. | **Archive to Boneyard**. The RecursiveSeed approach pre-places witnesses but has not achieved its goal of proving `temporal_coherent_family_exists_Int` sorry-free. |
| `Bundle/SeedCompletion.lean` | 374 | Ties RecursiveSeed to family construction. 5 sorries. | **Archive with RecursiveSeed** |
| `Bundle/SeedBMCS.lean` | 246 | Converts seed to BMCS. 5 sorries. | **Archive with RecursiveSeed** |

### 4.2 Moderate Candidates

| File/Directory | Lines | Reason | Recommendation |
|----------------|-------|--------|----------------|
| `Bundle/DovetailingChain.lean` | 666 | 4 sorries. Still the active approach for `temporal_coherent_family_exists_Int`. | **Keep** but document as work-in-progress. The 4 sorries (forward_F, backward_P, 2 cross-sign) represent the active frontier. |
| `Bundle/TemporalContent.lean` | 28 | Tiny helper; defines GContent/HContent. | **Keep** (small, used). |

### 4.3 Not Candidates (Active and Valuable)

All files in Core/, FMP/, Decidability/, Algebraic/, Soundness, SoundnessLemmas, and the non-deprecated parts of Bundle/ are active and should be retained.

---

## 5. Refactoring Recommendations

### 5.1 High Priority: Archive RecursiveSeed + SeedCompletion + SeedBMCS

**Impact**: Remove ~12,550 lines and ~26 sorries from the active codebase.

The RecursiveSeed approach was an experimental construction that attempted to pre-place temporal witnesses during seed building to avoid cross-sign propagation issues. It was split from a monolithic 220KB file into 5 submodules but never achieved its proof goal. The DovetailingChain approach (666 lines, 4 sorries) is strictly simpler and closer to completion for the same objective.

**Action**: Move `Bundle/RecursiveSeed/`, `Bundle/SeedCompletion.lean`, `Bundle/SeedBMCS.lean`, and `Bundle/RecursiveSeed.lean.backup-v004` to `Boneyard/Bundle/`.

### 5.2 High Priority: Clean up Construction.lean

**Impact**: Remove 1 sorry (singleFamilyBMCS.modal_backward) and clarify the construction path.

`Construction.lean` contains both the DEPRECATED `singleFamilyBMCS` (with its sorry for modal_backward) and useful helpers (`ContextConsistent`, `lindenbaumMCS`, etc.). The deprecated parts should be archived.

**Action**: Extract the deprecated `singleFamilyBMCS` and `construct_bmcs` to Boneyard. Rename the file or restructure to only contain the active helpers.

### 5.3 High Priority: Clean up TruthLemma.lean EvalBMCS section

**Impact**: Remove 4 sorries from the active codebase.

Lines 541-651 of TruthLemma.lean contain the `eval_bmcs_truth_lemma` which is a legacy version with structural limitations. It is completely superseded by `bmcs_truth_lemma` (which is sorry-free).

**Action**: Archive the EvalBMCS section to Boneyard.

### 5.4 Medium Priority: Resolve Omega-mismatch in Representation.lean

**Impact**: Would complete the standard semantics bridge (2 sorries).

The Omega-mismatch is a genuine semantic design issue. The cleanest resolution is likely option (a): modify `valid` and `semantic_consequence` in `Validity.lean` to quantify over Omega (the set of admissible histories) rather than using `Set.univ`. This aligns with the BMCS semantics where box quantifies over bundle families, not all possible histories.

**Action**: Create a follow-up task to coordinate changes across `Semantics/Validity.lean`, `Soundness.lean`, and `Representation.lean`.

### 5.5 Medium Priority: Complete DovetailingChain

**Impact**: Would eliminate the critical sorry in `fully_saturated_bmcs_exists_int`.

The DovetailingChain approach has 4 sorries:
1. Cross-sign propagation (2 sorries): When building MCS at time n+1 from GContent(M_n), formulas with the wrong temporal sign need special handling.
2. forward_F witness construction: Need to show that dovetailing enumeration eventually witnesses every F-formula.
3. backward_P witness construction: Same for P-formulas.

**Action**: Create focused tasks for each of the 4 sorry categories.

### 5.6 Low Priority: Namespace Reorganization

The `Bimodal.Metalogic.Bundle` namespace is overloaded with 19 files. Consider:
- Moving temporal coherence infrastructure to `Bimodal.Metalogic.TemporalCoherence/`
- Moving modal saturation to `Bimodal.Metalogic.ModalSaturation/`
- Keeping only the core BMCS definitions and completeness theorems in `Bundle/`

### 5.7 Low Priority: Import Cleanup

Several files import modules they don't directly use. A systematic import cleanup would reduce build times and make dependencies clearer. Low priority as it doesn't affect correctness.

---

## 6. Summary of Proof Debt

### What is Finished

1. **Soundness**: Complete, sorry-free, no axioms.
2. **BMCS Truth Lemma**: Complete for all 6 formula cases, sorry-free (given temporally coherent BMCS).
3. **BMCS Weak and Strong Completeness**: Sorry-free in themselves (sorry is upstream in BMCS construction).
4. **FMP Weak Completeness**: Complete, sorry-free, standalone. This is the canonical completeness result.
5. **Decidability**: Complete, sorry-free. Tableau-based decision procedure.
6. **Algebraic Representation**: Complete, sorry-free. Alternative algebraic approach.
7. **Standard Truth Lemma**: `canonical_truth_lemma_all` is sorry-free.
8. **Core MCS Theory**: Lindenbaum's lemma, deduction theorem, MCS properties -- all sorry-free.

### What Remains

1. **Critical**: `fully_saturated_bmcs_exists_int` (1 sorry) -- combining temporal coherence + modal saturation.
2. **Important**: Omega-mismatch in `standard_weak_completeness` and `standard_strong_completeness` (2 sorries) -- requires coordinated Validity.lean changes.
3. **Infrastructure**: ~26 sorries in RecursiveSeed (candidate for archival, not resolution).
4. **Infrastructure**: 4 sorries in DovetailingChain (active frontier).
5. **Legacy**: 5 sorries in deprecated constructions (archival candidates).

### Recommended Next Steps (Priority Order)

1. **Archive** RecursiveSeed + SeedCompletion + SeedBMCS + backup to Boneyard (~12,550 lines, ~26 sorries removed from active count)
2. **Archive** EvalBMCS section of TruthLemma.lean and deprecated parts of Construction.lean (~310 lines, 5 sorries removed)
3. **Create task** to resolve Omega-mismatch in Representation.lean
4. **Create task** to complete DovetailingChain's 4 remaining sorries
5. **Consider** whether resolving `fully_saturated_bmcs_exists_int` is worthwhile given that `fmp_weak_completeness` already provides a sorry-free completeness result

---

## 7. Architectural Assessment

The metalogic has evolved through multiple iterations (v1 through v5 in Boneyard, plus the current active version). The current architecture is sound but carries historical weight. The key insight is that **two independent completeness proofs exist**:

1. **FMP approach** (sorry-free, standalone, finite models)
2. **BMCS approach** (sorry-free modulo 1 upstream sorry, Henkin-style, infinite models)

For publication purposes, the FMP completeness is sufficient and is the canonical result. The BMCS approach provides stronger results (strong completeness, context representation) but depends on the `fully_saturated_bmcs_exists_int` sorry.

The standard semantics bridge (`Representation.lean`) is blocked by the Omega-mismatch, which is a genuine design issue requiring coordinated changes to the validity definitions. This is not a proof difficulty but a definition alignment task.

The codebase would benefit significantly from the archival of ~12,550 lines of experimental/superseded code, which would reduce the sorry count from ~47 to ~15 in the active metalogic.
