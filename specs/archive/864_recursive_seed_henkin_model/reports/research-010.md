# Research Report: Task #864 (Evaluation)

**Task**: Recursive seed construction for Henkin model completeness
**Date**: 2026-02-19
**Focus**: Evaluate what from task 864 is worth preserving versus archiving, given task 903's restructured approach

## Summary

Task 864 built a worklist-based recursive seed construction algorithm to produce a BMCS from a consistent formula. Task 903 takes a fundamentally different approach: it constructs the canonical model directly from a constant-family BMCS, with a single sorry-backed existence theorem. The two approaches are largely **orthogonal in implementation but share the same mathematical goal**. Task 864's RecursiveSeed chain was intended to supply the concrete BMCS construction that task 903 now abstracts behind `constant_family_bmcs_exists_int`. Task 864's code is the candidate for eventually discharging that sorry -- but in its current state, it has significant unresolved issues (103 build errors in Closure.lean, 34 sorries across the chain, broken barrel file). The recommendation is to archive most files to Boneyard while preserving Core.lean, the parts of Builder.lean that compile, and the Worklist.lean algorithm.

## Findings

### 1. Task 864 File Inventory

The following files were created or modified by task 864:

| File | Lines | Compiles? | Sorries | Status |
|------|-------|-----------|---------|--------|
| `RecursiveSeed/Core.lean` | 758 | Yes | 0 | Clean |
| `RecursiveSeed/Builder.lean` | 6,031 | Yes (with sorry warnings) | 6 | Mostly proven |
| `RecursiveSeed/Worklist.lean` | 876 | Yes (with sorry warning) | 1 | Mostly proven |
| `RecursiveSeed/Consistency.lean` | 718 | Yes | 6 | Partial proofs |
| `RecursiveSeed/Closure.lean` | 3,549 | **No (103 errors)** | 4 | Broken |
| `RecursiveSeed.lean` (barrel) | 12 | **No** (depends on Closure) | 0 | Broken by Closure |
| `SeedCompletion.lean` | 374 | **No** (depends on barrel) | 5 | Blocked |
| `SeedBMCS.lean` | 246 | **No** (depends on barrel) | 6 | Blocked |

**Totals**: 12,564 lines across the split files, plus 620 lines in SeedCompletion and SeedBMCS. 28+ sorries. 103 build errors in Closure.lean cascading to block the barrel file and all downstream consumers.

### 2. Task 903's Approach

Task 903 (plan v002) takes a fundamentally different architecture:

- Creates a single new file `Theories/Bimodal/Metalogic/Representation.lean`
- Defines `canonicalFrame`, `canonicalModel`, `canonicalHistory` from a constant-family BMCS
- Proves a truth lemma relating MCS membership to standard `truth_at`
- Derives `standard_representation`, `standard_weak_completeness`, `standard_strong_completeness`
- **Does NOT use RecursiveSeed at all** -- it abstracts the BMCS construction behind `constant_family_bmcs_exists_int` (a sorry-backed theorem)
- Explicitly lists "Addressing RecursiveSeed chain (deferred pending task 864)" as a non-goal

Representation.lean already exists and compiles with 3 sorry-backed theorems (the BMCS existence + box/temporal cases of the truth lemma, which are the remaining phases 3-5).

### 3. Relationship Between Task 864 and Task 903

The relationship is as follows:

- **Task 903** establishes the completeness path: "given a constant-family BMCS with the right properties, here is completeness."
- **Task 864** was building the concrete construction: "here is how to produce such a BMCS from a consistent formula."

Task 864's RecursiveSeed chain was intended to eventually provide the proof for `constant_family_bmcs_exists_int` (or a variant of it). However:

1. Task 864's approach constructs a **non-constant** BMCS (families have different MCS at different times)
2. Task 903 requires a **constant-family** BMCS (fam.mcs t = fam.mcs 0 for all t)
3. Task 864's SeedBMCS.lean would need a different construction to produce constant families
4. The worklist algorithm itself is sound, but its proof infrastructure is incomplete

### 4. Analysis of Each Component

#### Core.lean (758 lines, 0 sorries) -- KEEP

Contains fundamental definitions used throughout the chain:
- `FormulaClass` inductive type and `classifyFormula` function
- `SeedEntry`, `SeedEntryType`, `ModelSeed` structures
- `ModelSeed` operations: `findEntry`, `getFormulas`, `addFormula`, `addToAllFamilies`, `addToAllFutureTimes`, `addToAllPastTimes`, `createNewFamily`, `createNewTime`
- `freshFutureTime`/`freshPastTime` with proven properties
- Classification inversion theorems (all proven)
- `SeedConsistent`, `SeedWellFormed`, `ModalClosed`, `GClosed`, `HClosed`, `SeedClosed` definitions
- `singleton_consistent_iff` theorem (proven)

This file is entirely sorry-free, compiles cleanly, and provides reusable data structures and definitions. It is the foundation that any future seed-based construction would build on.

#### Builder.lean (6,031 lines, 6 sorries) -- ARCHIVE (preserve selectively)

Contains two implementations:
1. **buildSeedAux** (lines 1-85): The original recursive builder. Clean, compiles, proven termination.
2. **Extensive proof infrastructure** (lines 85-6031): Monotonicity lemmas, membership preservation through addFormula, seed consistency lemmas, buildSeed properties.

The 6 sorries are in:
- `buildSeedAux_preserves_mem_general` (monotonicity through recursive calls)
- `addFormula_seed_preserves_consistent` (consistency preservation)
- Various membership/containment lemmas

This file has significant proven content but also significant proof debt. The core `buildSeedAux` function and basic definitions are useful. The extensive proof machinery (5000+ lines) is specific to the non-constant-family approach and has diminishing returns.

#### Worklist.lean (876 lines, 1 sorry) -- KEEP

Contains the worklist algorithm implementation:
- `WorkItem` structure with decidable equality, BEq, Hashable instances
- `WorklistState` structure
- `processWorkItem` with all 10 formula classification cases
- `processWorklistAux` with fuel-based termination
- `processWorklist` wrapper
- `buildSeedComplete` entry point
- `buildSeedComplete_computes` (proven via `native_decide`)

The single sorry is in `processWorklistAux`'s termination argument (fuel exhaustion case). The algorithm itself is sound and this file represents the key algorithmic contribution of task 864.

#### Consistency.lean (718 lines, 6 sorries) -- ARCHIVE

Contains:
- `WorklistInvariant` definition
- `box_inner_consistent`, `all_future_inner_consistent`, `all_past_inner_consistent` (proven)
- `processWorkItem_preserves_consistent` (6 sorries in modal/temporal cases)

The proven subformula consistency lemmas (box_inner_consistent, etc.) are independently useful, but they are simple consequences of the T-axiom and could be re-derived. The processWorkItem consistency proof is the main unfinished work.

#### Closure.lean (3,549 lines, 4 sorries) -- ARCHIVE

This file has **103 build errors** and does not compile. It contains:
- `WorklistClosureInvariant` definition
- `empty_worklist_closure` (proven)
- `initial_seed_getFormulas_unique` (proven)
- `initial_closure_invariant` (proven)
- Various helper lemmas (some proven, many broken)
- `processWorkItem_preserves_closure` (main sorry)

The fundamental issue identified in the latest handoff: "boxPositive box-closure sub-case cannot prove 'closed' branch when foldl creates new positions that lack theta." This is a genuine mathematical obstacle in the proof strategy, not just a compilation issue.

#### SeedCompletion.lean (374 lines, 5 sorries) -- ARCHIVE

Extends seed entries to full MCS via Lindenbaum, builds `IndexedMCSFamily` instances. Blocked from compiling by the broken barrel file. The 5 sorries are in:
- `modal_witness_includes_boxcontent` (needs ModalClosed)
- `forward_G` cross-sign case (needs GClosed)
- `backward_H` cross-sign case (needs HClosed)
- `buildFamilyFromSeed_cross_sign_seed` (needs GClosed/HClosed)
- `buildFamilyFromSeed_contains_seed` (t!=0 case)

All blocked on the closure properties that Closure.lean was supposed to provide.

#### SeedBMCS.lean (246 lines, 6 sorries) -- ARCHIVE

Constructs BMCS from seed. Blocked from compiling. The 2 key sorries are `modal_forward` and `modal_backward` in the BMCS construction, which depend on the entire upstream chain.

### 5. What Task 903 Needs That Task 864 Could Provide

Task 903's sole proof debt is `constant_family_bmcs_exists_int`: given a consistent context, produce a constant-family BMCS with temporal coherence and modal saturation. Task 864's approach does NOT directly produce this:

- Task 864 builds non-constant families (different MCS at different times via temporal witness creation)
- A constant-family version would need a different seed construction: for each MCS, create a constant family with that MCS at all times
- The worklist algorithm (adding witnesses at specific times) is fundamentally incompatible with constant families

**Conclusion**: Task 864's RecursiveSeed chain cannot directly discharge task 903's sorry. A future task to eliminate `constant_family_bmcs_exists_int` would need a different construction approach (e.g., iterate over all MCS, create constant families, prove the bundle has the required properties).

## Recommendations

### Files to KEEP

1. **`RecursiveSeed/Core.lean`** (758 lines)
   - Justification: Sorry-free, compiles cleanly, provides reusable data structures (`ModelSeed`, `SeedEntry`, `FormulaClass`, `classifyFormula`) and definitions (`SeedConsistent`, `ModalClosed`, `GClosed`, `HClosed`, `SeedClosed`) that could serve any future seed-based construction.
   - No refactoring needed.

2. **`RecursiveSeed/Worklist.lean`** (876 lines)
   - Justification: Contains the worklist algorithm implementation that represents the main algorithmic contribution. Compiles. The `buildSeedComplete_computes` test theorem confirms the algorithm produces correct output for concrete inputs.
   - The single sorry (fuel exhaustion) is a minor issue.

### Files to ARCHIVE to Boneyard/

3. **`RecursiveSeed/Builder.lean`** (6,031 lines) -> `Boneyard/Bundle/RecursiveSeed/Builder.lean`
   - Justification: The `buildSeedAux` function is superseded by the worklist approach. The 5000+ lines of proof infrastructure are specific to the non-constant-family approach. Contains 6 sorries. The core buildSeedAux function (first 85 lines) could be preserved in Core.lean or Worklist.lean if needed, but the worklist approach is strictly more capable.

4. **`RecursiveSeed/Consistency.lean`** (718 lines) -> `Boneyard/Bundle/RecursiveSeed/Consistency.lean`
   - Justification: Contains 6 sorries, all in processWorkItem consistency proofs. The proven subformula consistency lemmas (box_inner_consistent etc.) are simple and could be re-derived when needed. Not on task 903's critical path.

5. **`RecursiveSeed/Closure.lean`** (3,549 lines) -> `Boneyard/Bundle/RecursiveSeed/Closure.lean`
   - Justification: Does not compile (103 errors). Has a fundamental proof strategy issue identified in the handoffs. Not salvageable without significant restructuring. The proven helper lemmas (`empty_worklist_closure`, `initial_closure_invariant`) are simple and can be re-derived.

6. **`SeedCompletion.lean`** (374 lines) -> `Boneyard/Bundle/SeedCompletion.lean`
   - Justification: Blocked from compiling. All 5 sorries depend on closure properties from the broken Closure.lean. Would need complete rewrite for constant-family approach.

7. **`SeedBMCS.lean`** (246 lines) -> `Boneyard/Bundle/SeedBMCS.lean`
   - Justification: Blocked from compiling. Constructs non-constant BMCS, incompatible with task 903's constant-family requirement.

8. **`RecursiveSeed.lean.backup-v004`** -> Delete (obsolete backup)
   - Justification: Backup of an older version of the monolithic file, no longer useful.

### Required Refactoring Before Archival

1. **Fix the barrel file**: After archiving, update `RecursiveSeed.lean` to only import Core and Worklist:
   ```lean
   import Bimodal.Metalogic.Bundle.RecursiveSeed.Core
   import Bimodal.Metalogic.Bundle.RecursiveSeed.Worklist
   ```

2. **Move `buildSeedAux`**: The original recursive builder in Builder.lean (lines 1-85) should be copied to Core.lean or a new small file before archiving Builder.lean, since Worklist.lean imports Builder.lean (it uses `buildSeedAux` for the non-worklist path).

3. **Verify imports**: After archival, run `lake build` to ensure no remaining files depend on archived modules.

### Summary Table

| File | Lines | Action | Reason |
|------|-------|--------|--------|
| Core.lean | 758 | **KEEP** | Sorry-free, reusable definitions |
| Worklist.lean | 876 | **KEEP** | Main algorithmic contribution |
| Builder.lean | 6,031 | **ARCHIVE** | Superseded by worklist, heavy proof debt |
| Consistency.lean | 718 | **ARCHIVE** | Not on task 903 critical path, partial proofs |
| Closure.lean | 3,549 | **ARCHIVE** | Broken (103 errors), fundamental strategy issue |
| SeedCompletion.lean | 374 | **ARCHIVE** | Blocked, depends on broken upstream |
| SeedBMCS.lean | 246 | **ARCHIVE** | Incompatible with constant-family approach |
| RecursiveSeed.lean.backup-v004 | - | **DELETE** | Obsolete backup |
| RecursiveSeed.lean (barrel) | 12 | **UPDATE** | Remove archived imports |

**Net effect**: Keep 1,634 lines (Core + Worklist), archive 10,918 lines, update barrel file.

## Next Steps

1. Create a new task (or subtask of 903/864) to perform the archival
2. After archival, fix the barrel file and verify clean build
3. Task 903 continues with its Representation.lean approach independently
4. Eventually, a separate task should address `constant_family_bmcs_exists_int` -- this will likely need a new construction approach distinct from the RecursiveSeed worklist

## References

- Task 903 plan: `specs/903_restructure_completeness_proof_bimodal_semantics/plans/implementation-002.md`
- Task 903 research: `specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-002.md`
- Task 864 latest implementation summary: `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-20260217.md`
- Task 864 latest plan: `specs/864_recursive_seed_henkin_model/plans/implementation-008.md`
- Task 864 latest handoff: `specs/864_recursive_seed_henkin_model/handoffs/phase-1-handoff-20260219-iter3.md`
- Lean source: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/` (5 files)
- Lean source: `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`, `SeedBMCS.lean`
- Lean source: `Theories/Bimodal/Metalogic/Representation.lean` (task 903's file)
