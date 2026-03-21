# Research Report: Risk Analysis and Boneyard Candidates for Bundle/ Restructuring

**Task**: #903 - Restructure completeness proof for Bimodal task semantics
**Date**: 2026-02-19
**Focus**: Sorry/axiom inventory, Boneyard candidates, essential components, restructuring risks
**Scope**: `Theories/Bimodal/Metalogic/Bundle/` (27 files, ~26,540 lines)

## Summary

The Bundle/ directory contains a completeness proof that is structurally sound at the top level (Completeness.lean is sorry-free, TruthLemma.lean is sorry-free) but rests on a foundation with 5 axioms and approximately 50+ sorries spread across construction infrastructure. The critical path through Completeness.lean depends on only 8-10 files. The remaining 17+ files are experimental/alternative approaches that are orphaned (never imported by the critical path) and are strong Boneyard candidates. The core architectural issue is the simultaneous achievement of modal saturation and temporal coherence -- multiple approaches have been tried and all have sorry debt.

## Sorry/Axiom Inventory

### Per-File Sorry Counts (actual `sorry` tokens, including comments)

| File | Sorries | Axioms | Lines | Status |
|------|---------|--------|-------|--------|
| **RecursiveSeed/Builder.lean** | 12 | 0 | 6,031 | Experimental, orphan chain |
| **RecursiveSeed/Closure.lean** | 4 | 0 | 3,549 | Experimental, orphan chain |
| **RecursiveSeed/Consistency.lean** | 6 | 0 | 718 | Experimental, orphan chain |
| **RecursiveSeed/Core.lean** | 0 | 0 | 758 | Experimental, orphan chain |
| **RecursiveSeed/Worklist.lean** | 1 | 0 | 876 | Experimental, orphan chain |
| TemporalCoherentConstruction.lean | 12 | 2 | 938 | **CRITICAL PATH** |
| UnifiedChain.lean | 9 | 0 | 429 | Orphan, experimental |
| TemporalChain.lean | 14 | 0 | 555 | Orphan, experimental |
| TemporalLindenbaum.lean | 9 | 0 | 1,147 | Orphan, experimental |
| WeakCoherentBundle.lean | 7 | 1 | 1,134 | Orphan, experimental |
| DovetailingChain.lean | 9 | 0 | 666 | Used by critical path (via TemporalCoherentConstruction) |
| SeedBMCS.lean | 6 | 0 | 246 | Orphan, experimental |
| SeedCompletion.lean | 5 | 0 | 374 | Orphan chain (SeedBMCS) |
| FinalConstruction.lean | 6 | 0 | 578 | Orphan, experimental |
| CoherentConstruction.lean | 6 | 1 | 1,625 | Used by critical path |
| PreCoherentBundle.lean | 4 | 0 | 441 | Orphan, **MATHEMATICALLY BLOCKED** |
| ZornFamily.lean | 11 | 0 | 1,907 | Orphan, experimental |
| Construction.lean | 0 | 1 | 429 | **CRITICAL PATH** (FALSE axiom) |
| SaturatedConstruction.lean | 0 | 0 | 1,414 | Used by FinalConstruction (orphan) |
| ModalSaturation.lean | 0 | 0 | 604 | **CRITICAL PATH**, sorry-free |
| BMCS.lean | 0 | 0 | 263 | **CRITICAL PATH**, sorry-free |
| BMCSTruth.lean | 0 | 0 | 478 | **CRITICAL PATH**, sorry-free |
| TruthLemma.lean | 4 | 0 | 651 | **CRITICAL PATH** (4 EvalBMCS sorries, main lemma sorry-free) |
| Completeness.lean | 0 | 0 | 476 | **CRITICAL PATH**, sorry-free |
| IndexedMCSFamily.lean | 0 | 0 | 213 | **CRITICAL PATH**, sorry-free |
| TemporalContent.lean | 0 | 0 | 28 | Support, sorry-free |
| RecursiveSeed.lean | 0 | 0 | 12 | Module re-export |

### Axiom Summary (5 total, 4 on/near critical path)

| Axiom | File | Status | On Critical Path? |
|-------|------|--------|-------------------|
| `singleFamily_modal_backward_axiom` | Construction.lean | **FALSE** (counterexample proven) | Yes (deprecated but still present) |
| `fully_saturated_bmcs_exists` | TemporalCoherentConstruction.lean | Deprecated, mathematically correct | Yes (deprecated, replaced by Int version) |
| `fully_saturated_bmcs_exists_int` | TemporalCoherentConstruction.lean | **Sorry-backed THEOREM** (not axiom) | Yes (the actual dependency) |
| `saturated_extension_exists` | CoherentConstruction.lean | Mathematically correct | Indirectly (via TemporalCoherentConstruction) |
| `weak_saturated_extension_exists` | WeakCoherentBundle.lean | Mathematically correct | No (orphan file) |

**Correction**: `fully_saturated_bmcs_exists_int` is declared as `theorem` not `axiom`, but it has a `sorry` body, so it functions as an axiom in practice.

### Effective Axiom Chain for Completeness

```
Completeness.lean (sorry-free)
  -> TruthLemma.lean: bmcs_truth_lemma (sorry-free, requires B.temporally_coherent)
  -> TemporalCoherentConstruction.lean:
       construct_saturated_bmcs_int (uses fully_saturated_bmcs_exists_int)
       fully_saturated_bmcs_exists_int (sorry-backed theorem, THE MAIN GAP)
  -> Construction.lean:
       singleFamily_modal_backward_axiom (FALSE, deprecated but still compiled)
```

The completeness chain actually routes through `construct_saturated_bmcs_int`, which uses the sorry-backed `fully_saturated_bmcs_exists_int`. The FALSE axiom `singleFamily_modal_backward_axiom` is compiled but not used by the current completeness chain (it is used by `singleFamilyBMCS` which is no longer on the path from `construct_saturated_bmcs_int`).

## Boneyard Candidates

### Tier 1: Immediate Boneyard (Orphan files, no dependents, alternative approaches that failed)

These files are not imported by any file on the critical path. They represent failed experiments or superseded approaches.

| File | Lines | Sorries | Reason for Deprecation |
|------|-------|---------|----------------------|
| **PreCoherentBundle.lean** | 441 | 4 | Self-documented as **MATHEMATICALLY BLOCKED**. The approach is fundamentally impossible. |
| **TemporalChain.lean** | 555 | 14 | Superseded by DovetailingChain.lean. Same approach, less developed. |
| **WeakCoherentBundle.lean** | 1,134 | 7+1ax | Experimental, never integrated. Weak coherence approach abandoned. |
| **UnifiedChain.lean** | 429 | 9 | Alternative to DovetailingChain. All key lemmas have sorry. Not used. |
| **ZornFamily.lean** | 1,907 | 11 | Zorn-based family construction. Orphan, experimental. |
| **TemporalLindenbaum.lean** | 1,147 | 9 | Henkin-style temporal Lindenbaum. Orphan, needed for FinalConstruction path (also orphan). |
| **FinalConstruction.lean** | 578 | 6 | Attempted to prove `fully_saturated_bmcs_exists_int` constructively. All key theorems have sorry. Orphan. |

**Total Tier 1**: 6,191 lines, 60+ sorries, 1 axiom

### Tier 2: Likely Boneyard (Part of orphan chains, superseded infrastructure)

| File | Lines | Sorries | Reason |
|------|-------|---------|--------|
| **SeedBMCS.lean** | 246 | 6 | Wrapper for SeedCompletion -> RecursiveSeed chain. modal_forward/backward both sorry. |
| **SeedCompletion.lean** | 374 | 5 | Bridge between RecursiveSeed and DovetailingChain. Cross-sign handling has sorry. |
| **RecursiveSeed/Builder.lean** | 6,031 | 12 | Massive file (largest in Bundle/). Complex builder with many sorries. |
| **RecursiveSeed/Closure.lean** | 3,549 | 4 | Closure properties for RecursiveSeed. Active development but not on critical path. |
| **RecursiveSeed/Consistency.lean** | 718 | 6 | Consistency proofs. Key cases (boxPositive, futurePositive, pastPositive) have sorry. |
| **RecursiveSeed/Worklist.lean** | 876 | 1 | Worklist processing. One sorry. |
| **RecursiveSeed/Core.lean** | 758 | 0 | Core data structures. Sorry-free but unused by critical path. |
| **RecursiveSeed.lean** | 12 | 0 | Module re-export file. |

**Total Tier 2**: 12,564 lines, 34 sorries

### Why RecursiveSeed is a Boneyard Candidate

The RecursiveSeed subdirectory is **the largest code investment** in Bundle/ (11,932 lines across 5 files) but it is entirely disconnected from the critical completeness path:

1. **RecursiveSeed** is imported by **SeedCompletion**, which is imported by **SeedBMCS**
2. **SeedBMCS** is an orphan -- nothing imports it
3. The `buildFamilyFromSeed` function in SeedCompletion falls back to `dovetailChainSet` anyway
4. Cross-sign handling in SeedCompletion has the same sorry as DovetailingChain
5. Builder.lean at 6,031 lines is nearly 1/4 of the entire Bundle/ directory

The RecursiveSeed approach was task 864's attempt to solve the cross-sign problem by pre-placing temporal witnesses in the seed. However:
- It still delegates to DovetailingChain for the actual chain construction
- The cross-sign sorries in SeedCompletion match those in DovetailingChain
- It introduces massive complexity (11,932 lines) without resolving the core gap

## Essential Components (Must Keep)

### Critical Path Files (8 files, ~4,697 lines)

These files form the complete dependency chain for the completeness theorem:

| File | Lines | Status | Role |
|------|-------|--------|------|
| IndexedMCSFamily.lean | 213 | Sorry-free | Core data structure |
| TemporalContent.lean | 28 | Sorry-free | GContent/HContent definitions |
| BMCS.lean | 263 | Sorry-free | BMCS structure + modal coherence |
| BMCSTruth.lean | 478 | Sorry-free | Truth evaluation definition |
| ModalSaturation.lean | 604 | Sorry-free | Saturation predicate + saturated_modal_backward |
| TruthLemma.lean | 651 | Sorry-free (main), 4 sorries (EvalBMCS legacy) | THE key theorem |
| Construction.lean | 429 | 1 FALSE axiom (deprecated) | BMCS from consistent context |
| TemporalCoherentConstruction.lean | 938 | 2 axioms (1 deprecated) + 1 sorry | Temporal + modal construction |
| Completeness.lean | 476 | Sorry-free | Main completeness theorems |

### Near-Critical Files (2 files)

| File | Lines | Status | Role |
|------|-------|--------|------|
| CoherentConstruction.lean | 1,625 | 1 axiom, 6 sorries | Box witness seed consistency (imported by TemporalCoherentConstruction) |
| DovetailingChain.lean | 666 | 4 sorries | Temporal coherent family construction (imported by TemporalCoherentConstruction) |

### Possibly Useful Infrastructure (1 file)

| File | Lines | Status | Role |
|------|-------|--------|------|
| SaturatedConstruction.lean | 1,414 | Sorry-free | Full modal saturation via Zorn. Not on current critical path but valuable for eliminating axioms. |

## Restructuring Risks

### Risk 1: Removing the FALSE Axiom (Construction.lean)

**Risk**: LOW. `singleFamily_modal_backward_axiom` is documented as FALSE and deprecated. The current completeness chain uses `construct_saturated_bmcs_int` which goes through `fully_saturated_bmcs_exists_int`, not through `singleFamilyBMCS`.

**Action**: Remove the axiom and `singleFamilyBMCS`. Keep `construct_bmcs` infrastructure as it provides Lindenbaum extension utilities used elsewhere.

**Impact**: No effect on completeness chain. May break `TemporalChain.lean` and other orphans (which we are Boneyarding).

### Risk 2: Boneyarding RecursiveSeed

**Risk**: MEDIUM. RecursiveSeed/Closure.lean shows active recent development (task 864). Moving it to Boneyard may conflict with in-progress work.

**Mitigation**: Check if task 864 is still active. If so, defer RecursiveSeed Boneyarding until task 864 concludes. If task 864 is blocked/stalled, Boneyard is appropriate.

**Note from git log**: The most recent commits reference "task 864: iteration 2 progress (lines 1-1209 compile)". This suggests active development on RecursiveSeed/Closure.lean. **Defer Boneyarding RecursiveSeed until task 864 status is resolved.**

### Risk 3: Removing Orphan Files While They Have Unresolved Ideas

**Risk**: LOW. The Boneyard already contains 5 versions of Metalogic (v1-v5). The pattern is well-established. Boneyard preserves code for reference.

**Mitigation**: Add README.md to Boneyard with explanation of each deprecated approach.

### Risk 4: Breaking Build

**Risk**: LOW-MEDIUM. Orphan files still compile and are part of `lake build`. Moving them to Boneyard removes them from the build, which should REDUCE build times.

**Mitigation**: Verify build passes after each move. Remove imports from moved files' dependencies.

### Risk 5: Losing Useful Infrastructure in Boneyarded Files

**Risk**: MEDIUM. Some orphan files contain proven lemmas that could be useful:
- `SaturatedConstruction.lean`: Sorry-free modal saturation via Zorn. Currently orphan but valuable.
- `CoherentConstruction.lean`: Box witness seed consistency (on critical path).
- `TemporalCoherentConstruction.lean` temporal duality infrastructure (on critical path).

**Mitigation**: Only Boneyard files that are truly orphaned AND whose content is superseded. Keep SaturatedConstruction.lean as it is sorry-free and could be integrated.

### Risk 6: The Core Gap Cannot Be Closed

**Risk**: This is the fundamental issue. The main gap is `fully_saturated_bmcs_exists_int` -- proving that a BMCS can be simultaneously modally saturated AND temporally coherent. Multiple approaches have tried and failed:

1. **DovetailingChain** (4 sorries): Cross-sign temporal propagation blocked
2. **UnifiedChain** (9 sorries): Combined seed consistency unproven
3. **RecursiveSeed** (23+ sorries): Pre-placed witnesses, but falls back to DovetailingChain
4. **FinalConstruction** (6 sorries): Tried combining DovetailingChain + SaturatedConstruction, sorry for temporal coherence of witness families
5. **TemporalLindenbaum** (9 sorries): Henkin limit temporal saturation unproven

**Assessment**: The gap is real and non-trivial. It is NOT a "just fill in the proof" situation. The fundamental obstacle is that Lindenbaum extension does NOT preserve temporal saturation (as FinalConstruction.lean documents). A new approach is needed, potentially:
- Temporal-aware Lindenbaum (modify the enumeration to include F/P witnesses)
- Restructured truth lemma that only requires temporal coherence for eval_family
- A different model construction entirely (e.g., filtration/finite model approach)

## Architectural Assessment

### What is Working Correctly

1. **BMCS structure definition** (BMCS.lean): Clean, well-designed
2. **Truth evaluation** (BMCSTruth.lean): Correct Henkin-style semantics
3. **Truth lemma** (TruthLemma.lean): Fully proven for temporally coherent BMCS
4. **Completeness theorems** (Completeness.lean): Correctly structured, sorry-free
5. **Modal saturation** (ModalSaturation.lean, SaturatedConstruction.lean): Sorry-free

### What is Going in the Wrong Direction

1. **Multiple competing construction approaches**: 5+ alternative chain/seed constructions that all fail at the same gap. This is wasted effort.
2. **RecursiveSeed complexity**: 11,932 lines of infrastructure that ultimately falls back to DovetailingChain's sorry-laden chain.
3. **FALSE axiom still present**: `singleFamily_modal_backward_axiom` is known false but not removed.
4. **Deprecated axioms not cleaned up**: Two deprecated axioms in TemporalCoherentConstruction.lean are still compiled.

### Construction Direction Assessment

**Question**: Is the construction direction correct (syntax -> model, not model -> syntax)?

**Answer**: YES. The construction direction is correct:
1. Start with consistent context (syntax)
2. Extend to MCS via Lindenbaum (syntax -> set theory)
3. Build IndexedMCSFamily from MCS (set theory -> model structure)
4. Wrap in BMCS (model structure -> semantic model)
5. Truth lemma connects MCS membership to semantic truth
6. Completeness follows by contraposition

This is the standard Henkin construction direction and it is correct.

**Question**: Are new definitions being introduced that should use existing semantics?

**Answer**: The Bundle/ approach correctly AVOIDS the existing `Bimodal.Semantics` definitions for the completeness proof. The BMCS truth evaluation is a parallel semantic framework that is more tractable for completeness. This is intentional and appropriate (Henkin semantics vs. standard semantics). The soundness bridge (standard semantics to BMCS) is handled separately.

## Recommendations

### Immediate Actions (Low Risk)

1. **Remove `singleFamily_modal_backward_axiom`** from Construction.lean. It is FALSE and deprecated. The current completeness chain does not use it.

2. **Remove `fully_saturated_bmcs_exists`** (polymorphic axiom) from TemporalCoherentConstruction.lean. It is deprecated in favor of the Int-specialized version.

3. **Boneyard Tier 1 files** (PreCoherentBundle, TemporalChain, WeakCoherentBundle, UnifiedChain, ZornFamily): These are orphans with no path to completion. Total: ~4,466 lines reclaimed from active codebase.

4. **Boneyard TemporalLindenbaum and FinalConstruction**: These attempted to close the main gap but failed. Total: ~1,725 lines.

### Deferred Actions (Pending Task 864 Resolution)

5. **Assess RecursiveSeed fate**: If task 864 is blocked/abandoned, Boneyard the entire RecursiveSeed/ chain (SeedCompletion, SeedBMCS, RecursiveSeed/). Total: ~12,564 lines.

### Strategic Recommendations

6. **Consolidate the gap**: The current code has the main gap (`fully_saturated_bmcs_exists_int`) duplicated across multiple sorry-backed approaches. After Boneyarding alternatives, the gap should be localized to exactly ONE file with clear documentation.

7. **Consider truth lemma restructuring**: The truth lemma requires `B.temporally_coherent` which demands ALL families satisfy forward_F/backward_P. If this could be weakened to only require temporal coherence for the eval_family, the modal saturation witness families would not need temporal coherence, and the gap would close.

8. **Consider the filtration approach**: The Boneyard README mentions the finite model property approach (`FiniteTime k`). If the infinite canonical model construction continues to resist proof, the FMP route may be more tractable.

## Confidence Level

**HIGH** confidence in:
- Sorry/axiom inventory (verified by grep)
- Boneyard Tier 1 candidates (all documented as orphans/failed approaches)
- Critical path identification (verified by import analysis)
- FALSE axiom identification (documented in code comments)

**MEDIUM** confidence in:
- RecursiveSeed Boneyard assessment (active task 864 complicates the picture)
- Gap difficulty assessment (multiple smart attempts have failed, but a breakthrough is possible)

**LOW** confidence in:
- Whether truth lemma restructuring is feasible (would need research)
- Whether FMP route would actually be simpler (different tradeoffs)
