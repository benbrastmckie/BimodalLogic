# Research Report: Task #905 (Round 2)

**Task**: Clean up the metalogic by moving anything not needed into Boneyard/ before implementing task 903's completeness proof restructuring
**Date**: 2026-02-19
**Focus**: Should task 864 (RecursiveSeed Henkin Model) be completed before cleanup (905) and task 903 implementation?
**Session**: sess_1771525489_574af7

## Summary

Task 864 is too large and too risky to complete before proceeding with tasks 905 and 903. The two tasks are architecturally independent -- task 903 builds on the existing BMCS completeness chain and introduces its own sorry-backed axiom (`constant_family_bmcs_exists_int`), while task 864 works toward constructively proving a different axiom (`fully_saturated_bmcs_exists_int`) via the RecursiveSeed pipeline. Completing task 864 first would delay meaningful progress by 10-24 hours with significant risk of further architectural pivots, while providing no benefit to task 903. The recommended ordering is: cleanup (905), then implement task 903, then return to task 864 later.

## 1. Size and Effort Assessment for Task 864

### Current State

Task 864 is on its **8th implementation plan** (v008) after 30+ implementation sessions, 9 research reports, and 2 major architectural pivots. The current state:

| Metric | Value |
|--------|-------|
| Plan versions | 8 (v001 through v008) |
| Research reports | 9 |
| Implementation sessions | 30+ |
| Total lines (RecursiveSeed pipeline) | 12,552 (5 files + SeedCompletion + SeedBMCS) |
| Current build status | BROKEN (77+ compilation errors in Closure.lean) |
| Sorries remaining | 22 across pipeline |
| Files in main build graph | 0 of 8 |

### Remaining Work (Per v008 Plan)

The v008 plan identifies 5 phases, all NOT STARTED:

| Phase | Description | Estimated Hours | Risk |
|-------|-------------|-----------------|------|
| 1 | Fix 77 build errors in Closure.lean | 4 hours | Medium (API breakage may cascade) |
| 2 | Build graph integration | 1 hour | Low |
| 3 | Consistency proofs (6 sorries) | 3 hours | Medium-High (post-condition approach untested) |
| 4 | SeedCompletion + SeedBMCS (10 sorries) | 3 hours | High (architectural gap at line 372) |
| 5 | Final verification | 1 hour | Low |

**Official estimate**: 12 hours. **Realistic estimate**: 15-26 hours (per research-008 analysis).

### Critical Risk Factors

1. **The file does not compile.** 77 build errors must be fixed before any proof work can begin. This has been a recurring pattern -- each session discovers new API breakage.

2. **Dershowitz-Manna termination is unsolved.** The worklist algorithm's termination proof requires multiset ordering formalization, which has been identified as a blocker in 3+ sessions without resolution.

3. **Post-condition consistency is unvalidated.** The v008 plan proposes deriving consistency from closure using `insert_consistent_of_derivable_parent`, but this approach has never been tested. The old loop-invariant approach worked for the original architecture but not the worklist architecture.

4. **SeedCompletion has an architectural gap.** `buildFamilyFromSeed_contains_seed` at t!=0 (line 372) reflects a fundamental design issue where seed formulas at non-zero times are not incorporated into the dovetailing chain.

5. **Approach churn risk.** The task has undergone 6 architectural approaches (v1 through v6). Another pivot is possible if the post-condition approach or the Closure.lean fixes prove intractable.

## 2. Dependency Analysis: Task 903 vs. Task 864

### Direct Dependencies: NONE

Task 903's implementation plan explicitly states:

> **Dependencies**: None (task 864 work on RecursiveSeed is independent)

And under Non-Goals:

> Addressing RecursiveSeed chain (deferred pending task 864)

Task 903 builds on:
- The existing BMCS completeness chain (Completeness.lean, TruthLemma.lean, TemporalCoherentConstruction.lean)
- The existing semantic definitions in Semantics/ (TaskFrame, TaskModel, WorldHistory, truth_at, satisfiable)
- A NEW sorry-backed axiom: `constant_family_bmcs_exists_int`

Task 864 builds on:
- The RecursiveSeed/ pipeline (Core, Builder, Worklist, Closure, Consistency)
- SeedCompletion.lean and SeedBMCS.lean
- Goal: constructively prove `fully_saturated_bmcs_exists_int`

### Import Graph Isolation

The two tasks operate on completely separate parts of the import graph:

```
Task 903 chain:                    Task 864 chain:
  Semantics/ definitions             RecursiveSeed/Core
        |                             RecursiveSeed/Builder
        v                             RecursiveSeed/Worklist
  BMCS -> BMCSTruth                  RecursiveSeed/Closure
        |                             RecursiveSeed/Consistency
        v                                    |
  ModalSaturation                    SeedCompletion
        |                                    |
        v                             SeedBMCS (orphan)
  Construction
        |
        v
  CoherentConstruction -> TemporalCoherentConstruction
        |                        |
        v                        v
  TruthLemma         temporal_backward_G/H
        |
        v
  Completeness
        |
        v
  [NEW: Representation.lean]  <-- Task 903
```

The only shared element is that both ultimately target BMCS existence axioms, but they target DIFFERENT axioms:
- Task 903 introduces `constant_family_bmcs_exists_int` (constant-family BMCS for standard semantics)
- Task 864 works toward proving `fully_saturated_bmcs_exists_int` (general BMCS for Henkin semantics)

### Would Completing 864 Help 903?

**No, for two reasons:**

1. **Different axioms.** Task 903's `constant_family_bmcs_exists_int` requires a CONSTANT-FAMILY BMCS (where `fam.mcs t = fam.mcs 0` for all t). Task 864's RecursiveSeed construction produces families where the MCS may vary over time. Even if task 864 succeeds, it would not directly prove task 903's axiom.

2. **Different proof architecture.** Task 903 builds a canonical TaskFrame with restricted WorldState (bundle MCS only), trivial task_rel, and constant histories. This is a direct construction that bypasses the Henkin-style model entirely. Task 864's Henkin-style construction with seed witnesses, worklist processing, and dovetailing chains is an orthogonal approach.

**However**, in the long term, completing task 864 would eliminate `fully_saturated_bmcs_exists_int`, which is a dependency of the existing BMCS completeness chain. Task 903 introduces a NEW sorry on top of this. So the total axiom debt after task 903 would be:
- `fully_saturated_bmcs_exists_int` (existing, in BMCS chain)
- `constant_family_bmcs_exists_int` (new, in standard chain)

Completing task 864 would reduce this to just the constant-family axiom. But this is independent of task 903's implementation.

## 3. Relationship Analysis

### How RecursiveSeed Relates to Completeness Proof Restructuring

The RecursiveSeed approach (task 864) and the standard completeness restructuring (task 903) represent two different strategies for the same ultimate goal: a sorry-free completeness theorem for bimodal temporal logic.

| Aspect | Task 864 (RecursiveSeed) | Task 903 (Standard Restructuring) |
|--------|--------------------------|-----------------------------------|
| **Goal** | Constructively prove BMCS existence | Express completeness in standard semantics |
| **Approach** | Bottom-up: build seed, extend to MCS, form BMCS | Top-down: given BMCS, construct canonical semantic objects |
| **Addresses** | `fully_saturated_bmcs_exists_int` sorry | Bridge from BMCS to standard `satisfiable`/`valid` |
| **Proof debt** | Eliminates 1 axiom | Introduces 1 axiom, removes 1 FALSE axiom |
| **Lines of code** | 12,552 (existing) | ~500-800 (estimated new file) |
| **Risk** | High (30+ sessions, 2 pivots) | Low-Medium (mathematical analysis complete) |

They are **complementary but independent**:
- Task 903 restructures the *top* of the proof (how completeness is stated and what semantic objects it uses)
- Task 864 attacks the *bottom* of the proof (how the BMCS is constructively built)

### Could They Interfere?

No. Task 903 creates a new file (`Representation.lean`) that imports from `Completeness.lean` at the top of the existing chain. Task 864 works on `RecursiveSeed/` files that are entirely disconnected from this chain. The only theoretical interaction is if task 864 modifies `SeedBMCS.lean` in a way that adds an import to `Completeness.lean`, but this is not in any current plan.

## 4. Recommendation

### Recommended Ordering: Option B -- Cleanup (905), then Task 903, then Task 864

**Reasoning:**

1. **Task 903 is well-scoped and low-risk.** It has a detailed plan (10 hours estimated), complete mathematical analysis (two research reports), and clear implementation path. It creates a single new file and moves orphan files to Boneyard.

2. **Task 864 is high-risk and high-effort.** 15-26 hours estimated, with 5 identified blockers including a file that does not compile, an unsolved termination proof, and an untested proof architecture. It has already consumed 30+ sessions with 2 major pivots.

3. **Task 905 (cleanup) directly enables task 903.** Moving orphan files to Boneyard clears the workspace and reduces build time. The cleanup is explicitly listed as task 903's Phase 5, but doing it first (as a separate task) makes the task 903 implementation cleaner.

4. **Task 864 provides no benefit to task 903.** The two tasks are architecturally independent with different axioms, different files, and different proof strategies.

5. **Completing task 903 first provides strategic value.** Having standard completeness theorems (even with a sorry-backed axiom) is a milestone that demonstrates the proof architecture works. This gives confidence that the overall approach is sound before investing further in task 864's constructive proof.

### Why NOT Option A (Complete 864 First)

- **Delay**: 15-26 hours of work on task 864 before any progress on the stated goal (task 903)
- **Risk**: High probability of further blockers or architectural pivots
- **No benefit**: Task 903 does not depend on task 864
- **Opportunity cost**: Task 903 is actionable NOW with well-understood scope

### Why NOT Option C (Partial 864)

One might consider doing just Phase 1 of task 864 (fix 77 build errors, 4 hours) to get the RecursiveSeed files compiling again, then proceeding with 905 and 903. This is **reasonable but not recommended** because:
- The 4-hour estimate may be optimistic (previous sessions have underestimated build fix time)
- Getting the files to compile does not advance any proofs
- The files are not in the main build graph anyway, so they will silently break again
- Better to defer ALL task 864 work until after 903 is complete, then assess whether the RecursiveSeed approach is still the right path

### Summary: Recommended Execution Order

1. **Task 905 (cleanup)**: Move 8 orphan files to Boneyard, remove FALSE axiom (2-3 hours)
2. **Task 903 (standard completeness)**: Create Representation.lean, prove truth lemma, derive standard theorems (10 hours)
3. **Task 864 (RecursiveSeed)**: Return with fresh perspective, possibly reassess approach (15-26 hours)

Total for 905+903: ~12-13 hours
Total for 864 first + 905 + 903: ~27-39 hours (with significant risk)

## References

- Task 864 plan v008: `specs/864_recursive_seed_henkin_model/plans/implementation-008.md`
- Task 864 meta-analysis: `specs/864_recursive_seed_henkin_model/reports/research-008.md`
- Task 864 Closure.lean error analysis: `specs/864_recursive_seed_henkin_model/reports/research-009.md`
- Task 903 plan: `specs/903_restructure_completeness_proof_bimodal_semantics/plans/implementation-001.md`
- Task 903 research-002: `specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-002.md`
- Task 905 research-001: `specs/905_cleanup_metalogic_for_task_903/reports/research-001.md`
- RecursiveSeed files: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed/` (5 files, 11,932 lines)
- SeedCompletion: `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` (374 lines)
- SeedBMCS: `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean` (246 lines)
- BMCS existence axiom: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (line 822)

## Next Steps

1. Proceed with `/plan 905` to create the cleanup implementation plan
2. After cleanup, proceed with `/implement 903`
3. After 903 is complete, reassess task 864 with fresh perspective and consider whether the RecursiveSeed approach is still optimal or if a simpler constructive proof of `constant_family_bmcs_exists_int` might be more tractable
