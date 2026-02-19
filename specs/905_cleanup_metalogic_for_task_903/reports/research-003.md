# Research Report: Task #905 (Round 3)

**Task**: Clean up the metalogic by moving anything not needed into Boneyard/ before implementing task 903's completeness proof restructuring
**Date**: 2026-02-19
**Focus**: Should RecursiveSeed files (task 864) be archived to Boneyard before attempting task 903?
**Session**: sess_1771526632_dd02cf

## Summary

The RecursiveSeed files (12,564 lines across 8 files) are completely independent from the task 903 critical path. No critical path file imports from RecursiveSeed, SeedCompletion, or SeedBMCS. The dependency is one-directional: RecursiveSeed imports FROM critical path files (Core/MaximalConsistent, DovetailingChain, IndexedMCSFamily, etc.), never the reverse. Moving RecursiveSeed to Boneyard would have zero effect on the task 903 implementation -- but it would also provide minimal benefit since these files are already effectively invisible to the build (Closure.lean has 77 compilation errors that prevent the barrel file from compiling, and nothing in the main import graph reaches them).

## Findings

### 1. Import Dependency Analysis: RecursiveSeed vs. Task 903 Critical Path

**Question**: Do any critical path files for task 903 import from RecursiveSeed?

**Answer**: NO. Zero critical path files import from any RecursiveSeed file.

The complete import lists for all critical path files were verified:

| Critical Path File | Imports RecursiveSeed? | Imports SeedCompletion? | Imports SeedBMCS? |
|---|---|---|---|
| Completeness.lean | No | No | No |
| TruthLemma.lean | No | No | No |
| TemporalCoherentConstruction.lean | No | No | No |
| CoherentConstruction.lean | No | No | No |
| Construction.lean | No | No | No |
| DovetailingChain.lean | No | No | No |
| ModalSaturation.lean | No | No | No |
| BMCS.lean | No | No | No |
| BMCSTruth.lean | No | No | No |
| IndexedMCSFamily.lean | No | No | No |
| TemporalContent.lean | No | No | No |
| Metalogic.lean (aggregator) | No | No | No |

The only files that import RecursiveSeed are within the RecursiveSeed chain itself:

```
RecursiveSeed/Core.lean      <- imports Core/MaximalConsistent, Core/MCSProperties (FROM critical path)
RecursiveSeed/Builder.lean   <- imports RecursiveSeed/Core
RecursiveSeed/Worklist.lean  <- imports RecursiveSeed/Builder
RecursiveSeed/Consistency.lean <- imports RecursiveSeed/Worklist
RecursiveSeed/Closure.lean   <- imports RecursiveSeed/Worklist, Mathlib.Data.Multiset.DershowitzManna
RecursiveSeed.lean (barrel)  <- imports all 5 RecursiveSeed submodules
SeedCompletion.lean          <- imports RecursiveSeed (barrel), IndexedMCSFamily, TemporalContent, DovetailingChain, Soundness
SeedBMCS.lean                <- imports SeedCompletion, BMCS
```

**Key finding**: The dependency is strictly ONE-DIRECTIONAL. RecursiveSeed depends on critical path files, but no critical path file depends on RecursiveSeed.

### 2. Build Graph Status

The RecursiveSeed files are NOT in the main build graph:

- **Metalogic.lean** (the aggregator imported by Bimodal.lean) does NOT import RecursiveSeed, SeedCompletion, or SeedBMCS
- **Bimodal.lean** imports Metalogic.lean, which reaches Completeness.lean as its deepest Bundle/ import
- RecursiveSeed files exist under `Theories/Bimodal/` so Lake discovers them, but since they are not transitively imported, they are only compiled independently
- **Closure.lean has 77 compilation errors** and fails to build. This prevents the barrel file (RecursiveSeed.lean) from compiling, which in turn prevents SeedCompletion.lean and SeedBMCS.lean from compiling.

Build artifact verification:
- RecursiveSeed/Core.olean: EXISTS
- RecursiveSeed/Builder.olean: EXISTS
- RecursiveSeed/Worklist.olean: EXISTS
- RecursiveSeed/Consistency.olean: EXISTS
- RecursiveSeed/Closure.olean: MISSING (compilation fails)
- RecursiveSeed.olean (barrel): MISSING (depends on Closure)
- SeedCompletion.olean: MISSING (depends on barrel)
- SeedBMCS.olean: MISSING (depends on SeedCompletion)

**The RecursiveSeed chain is already broken in the build.** Files Core, Builder, Worklist, and Consistency compile independently but the chain as a whole does not produce a working barrel file.

### 3. Effect of Moving RecursiveSeed to Boneyard

**Would it break the build?** NO. Since no file in the main import graph imports from RecursiveSeed, SeedCompletion, or SeedBMCS, moving them to Boneyard would not cause any compilation issues.

**Would it affect task 903?** NO. Task 903 creates a new Representation.lean that imports from Completeness.lean, TruthLemma.lean, and TemporalCoherentConstruction.lean -- none of which have any connection to RecursiveSeed.

**Would it provide benefit?**

Benefits:
- Removes 12,564 lines from active Metalogic/Bundle/ directory (reduces clutter)
- Removes 34 sorries from active sorry count
- Eliminates partial compilation noise (Core, Builder, Worklist, Consistency still compile as standalone files, consuming build time)
- Makes it clearer which files are on the active critical path

Drawbacks:
- Makes task 864 resumption slightly harder (would need to move files back or work in Boneyard)
- Task 864 is not officially abandoned -- it is deferred
- Moving 8 files (5 in RecursiveSeed/ + barrel + SeedCompletion + SeedBMCS) adds scope to task 905

Neutral:
- No effect on build correctness or speed of critical path compilation
- TemporalCoherentConstruction.lean has RecursiveSeed references in COMMENTS only (documentation describing the task 864 approach) -- these are not imports and would not break

### 4. Assessment: Move or Defer?

**The prior research reports recommended DEFERRING the RecursiveSeed move** because task 864 was considered active. The key considerations:

1. **Task 864 status**: 8 plan versions, 30+ sessions, 2 pivots, build broken (77 errors in Closure.lean). Research-002 recommended doing 905 -> 903 -> 864, meaning task 864 would not be attempted until AFTER task 903 is complete.

2. **Independence from task 903**: CONFIRMED. Zero import dependencies in either direction between RecursiveSeed and the task 903 critical path.

3. **Build impact**: ZERO. The RecursiveSeed files are already broken (Closure.lean) and nothing imports them.

4. **Practical impact of moving vs. not moving**:
   - **Not moving**: RecursiveSeed files sit in Bundle/ as dead weight. Core/Builder/Worklist/Consistency still compile wastefully. No functional difference for task 903.
   - **Moving**: Cleaner directory. When task 864 is resumed, files would need to be moved back or worked on in Boneyard. This adds friction to task 864 resumption.

### 5. TemporalCoherentConstruction.lean Comment References

TemporalCoherentConstruction.lean (a critical path file) mentions RecursiveSeed in documentation comments at lines 580-626. These are purely informational (not imports or code references):

- Line 580: "Proof Strategy (Task 864 - RecursiveSeed approach)"
- Line 581: "This theorem uses the RecursiveSeed construction..."
- Line 590: "pending full RecursiveSeed integration"
- Line 593: "RecursiveSeed eliminates 2 cross-sign sorries..."
- Lines 611-626: Documentation of the RecursiveSeed approach for Int specialization

Moving RecursiveSeed to Boneyard would NOT affect these comments. They would remain as historical documentation of the task 864 approach.

## Recommendations

### Primary Recommendation: Do NOT move RecursiveSeed to Boneyard as part of task 905

**Rationale**:

1. **Zero benefit for task 903**: The RecursiveSeed files have no effect whatsoever on the task 903 implementation. Moving them provides no functional advantage.

2. **Unnecessary scope expansion**: Task 905's current plan is well-scoped at 8 files (7,605 lines). Adding RecursiveSeed would increase scope to 16 files (20,169 lines) with no corresponding benefit.

3. **Task 864 is deferred, not abandoned**: Research-002 explicitly recommends returning to task 864 after 903. Moving files to Boneyard adds friction to that future work.

4. **The files are already broken**: Closure.lean's 77 errors mean the chain does not produce a working barrel file. They are effectively inert.

5. **The current plan is correct**: The 8 orphan files identified in research-001 are genuine dead-end nodes with zero importers. RecursiveSeed files, while disconnected from the critical path, represent an ongoing (deferred) development effort.

### Alternative Recommendation: Move RecursiveSeed to Boneyard IF task 864 is formally abandoned

If the user decides to abandon task 864 entirely, then moving RecursiveSeed to Boneyard becomes worthwhile. This would:
- Remove 12,564 lines and 34 sorries from active codebase
- Eliminate wasteful compilation of Core/Builder/Worklist/Consistency
- Signal that the RecursiveSeed approach is no longer active

### Summary Answer to Research Question

**"Should the RecursiveSeed files be archived to Boneyard BEFORE attempting task 903?"**

**No.** They have zero import dependencies with the task 903 critical path, zero effect on the build for task 903, and represent deferred (not abandoned) work. Moving them would add unnecessary scope to task 905 and create friction for the eventual task 864 resumption, while providing no benefit whatsoever for task 903.

## References

- Task 905 research-001: `specs/905_cleanup_metalogic_for_task_903/reports/research-001.md`
- Task 905 research-002: `specs/905_cleanup_metalogic_for_task_903/reports/research-002.md`
- Task 905 plan: `specs/905_cleanup_metalogic_for_task_903/plans/implementation-001.md`
- Task 903 plan: `specs/903_restructure_completeness_proof_bimodal_semantics/plans/implementation-001.md`
- Metalogic aggregator: `Theories/Bimodal/Metalogic/Metalogic.lean`
- RecursiveSeed barrel: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
- SeedCompletion: `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- SeedBMCS: `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`

## Next Steps

1. Proceed with task 905 implementation as currently planned (8 orphan files + FALSE axiom removal)
2. Do NOT add RecursiveSeed to the scope
3. After task 905 + 903 are complete, reassess task 864 and decide whether to resume or abandon
4. If abandoned, create a separate cleanup task to move RecursiveSeed to Boneyard
