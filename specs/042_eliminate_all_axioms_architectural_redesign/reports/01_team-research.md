# Research Report: Task #42

**Task**: Investigate and eliminate ALL custom axioms — architectural redesign permitted
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Focus**: Comprehensive metalogic audit — axiom elimination, ExistsTask vs CanonicalTask confusion, W=D conflation, sorry inventory, open task triage

## Summary

The metalogic codebase has **9 custom axioms** (7 production, 2 StagedConstruction), **1 sorry on the critical completeness path**, and significant architectural confusion between ExistsTask (a binary G-accessibility relation) and CanonicalTask (the correct integer-indexed task relation). One axiom (`existsTask_irreflexive_axiom`) is **logically inconsistent** with a proven theorem in the same file. The W=D conflation exists in `DurationTransfer.lean` but is not on the primary completeness path. Of 18 active tasks, 7 should be abandoned, several deferred. Task 40's plan must be overridden (it proposes adding a 10th axiom). The path to sorry-free, axiom-free completeness is achievable with focused work on 5 axiom groups, most of which can be parallelized.

## Critical Discoveries

### 1. Inconsistent Axiom

`existsTask_irreflexive_axiom` (CanonicalIrreflexivity.lean:279) asserts `¬ExistsTask M M` for all MCS M. This **directly contradicts** the proven `existsTask_reflexive` in the same file under reflexive semantics. The file documents this openly. The axiom is used only by non-primary paths (DiscreteTimeline, CantorApplication, DovetailedTimelineQuot) and should be **deleted immediately**.

### 2. ExistsTask vs CanonicalTask Confusion

- **ExistsTask** = `g_content M ⊆ M'` = binary G-accessibility (the old CanonicalR). NOT a task relation.
- **CanonicalTask** = integer-indexed Succ-chain reachability = the correct `task_rel` for TaskFrame semantics.

The `CanonicalTaskFrame` in `CanonicalConstruction.lean` **incorrectly** uses ExistsTask (g_content inclusion) as `task_rel` for `d > 0`, conflating "any G-accessible successor" with "exactly d Succ steps." The correct frame (`CanonicalTaskTaskFrame` in `SuccChainTaskFrame.lean`) exists and is used by the active SuccChain completeness path.

**Recommendation**: Rename ExistsTask back to `CanonicalR` or `GAccessibility` to eliminate semantic confusion.

### 3. W=D Conflation

Explicitly documented in `CanonicalConstruction.lean:70-74`. The `DurationTransfer.canonicalTaskFrame` treats the timeline quotient T as both WorldState and Duration types. This is NOT on the primary completeness path but exists in production code. The primary path correctly keeps WorldState = MCS and D = Int.

### 4. Only 1 Sorry on Completeness Path

`succ_chain_fam_p_step` (SuccChainFMCS.lean:350) — the forward chain case (n >= 0). All other sorries (7 total in production) are on non-primary paths.

### 5. Task 40 Plan Must Be Overridden

The plan proposes adding `successor_p_step_axiom` (axiom #10). The research concluded "pure theorem approach is not achievable" but this was based on the **current seed design**, not fundamental impossibility. Restructuring the successor seed to include `pastDeferralDisjunctions` (symmetric to the predecessor seed) would make the proof achievable.

## Axiom Inventory (Verified)

### On Completeness Path (5 axioms)

| # | Axiom | File:Line | Property | Elimination Path |
|---|-------|-----------|----------|------------------|
| 1 | `successor_deferral_seed_consistent_axiom` | SuccExistence.lean:266 | Successor seed is consistent | Prove via deduction theorem: g_content consistency + derivability of deferral disjunctions |
| 2 | `predecessor_deferral_seed_consistent_axiom` | SuccExistence.lean:311 | Predecessor seed is consistent | Symmetric to #1 |
| 3 | `predecessor_f_step_axiom` | SuccExistence.lean:516 | f_content(predecessor) ⊆ u ∪ f_content(u) | Redesign predecessor seed to satisfy F-step, or derive from temporal duality |
| 4 | `f_nesting_boundary` | SuccChainFMCS.lean:615 | F-nesting terminates in MCS | Prove by induction on formula complexity / Fischer-Ladner closure finiteness |
| 5 | `p_nesting_boundary` | SuccChainFMCS.lean:727 | P-nesting terminates in MCS | Symmetric to #4 |

### Not on Completeness Path (4 axioms)

| # | Axiom | File:Line | Property | Elimination Path |
|---|-------|-----------|----------|------------------|
| 6 | `existsTask_irreflexive_axiom` | CanonicalIrreflexivity.lean:279 | ¬ExistsTask M M | **DELETE** — logically inconsistent with proven `existsTask_reflexive` |
| 7 | `discrete_Icc_finite_axiom` | DiscreteTimeline.lean:319 | Intervals in DiscreteTimelineQuot are finite | Superseded by SuccChain path; may be provable via Mathlib or archivable |
| 8 | `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean:300 | Discrete successor seed consistent | StagedConstruction path — archive to Boneyard |
| 9 | `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean:430 | No MCS between M and successor | StagedConstruction path — archive to Boneyard |

## Sorry Inventory (Production)

| Location | Description | On Completeness Path? |
|----------|-------------|----------------------|
| SuccChainFMCS.lean:350 | `succ_chain_fam_p_step` forward case | **YES** |
| SuccChainTruth.lean:254 | Box backward case | No |
| DirectMultiFamilyBFMCS.lean:308,311,421 | Cross-family modal coherence | No |
| CanonicalTimeline.lean:183 | `density_of_canonicalR` | No |
| Soundness.lean:572,576,579,582,602 | Frame-restricted soundness | No |

## Open Task Triage

### Abandon (7 tasks)

| Task | Reason |
|------|--------|
| 988 | Dense algebraic completeness — superseded, D=CanonicalMCS anti-pattern |
| 989 | Discrete algebraic completeness — superseded by succ-chain (task 997) |
| 22 | Direct multi-family bundle — research concludes cross-family modal_forward "fundamentally impossible" |
| 24 | Discrete axiom removal — depends on task 22 (abandoned) |
| 38 | Box backward truth lemma — architecturally impossible with current model, not used in completeness |
| 993 | Stability operator — nice-to-have, not critical path |
| 999 | Derive F->FF — theoretical interest, not blocking |

### Subsume into Task 42

| Task | Axiom(s) Targeted |
|------|-------------------|
| 34 | successor/predecessor_deferral_seed_consistent, predecessor_f_step (axioms 1-3) |
| 36 | f_nesting_boundary (axiom 4) |
| 37 | p_nesting_boundary (axiom 5) |
| 40 | Forward chain p_step sorry + plan revision (no new axiom) |
| 26 | existsTask_irreflexive_axiom (axiom 6, inconsistent — just delete) |

### Defer

| Task | Reason |
|------|--------|
| 41 | D=CanonicalMCS elimination — separate concern, plan after axiom cleanup |
| 39 | Preorder semantics study — theoretical, not blocking |
| 18 | Dense representation theorem — stuck, not critical path |
| 19, 20, 21 | Refactoring/tech debt — depends on blocked tasks |
| 6, 8 | Publication-quality completeness — high investment, after axiom-free base |
| 992, 953, 949, 619 | Backlog — not critical path |
| 998 | FMP redesign — separate concern |

## Execution Plan (Critical Path)

### Phase 1: Parallel (independent groups, can start simultaneously)

| Group | Work | Axioms Eliminated |
|-------|------|-------------------|
| A | Prove seed consistency (task 34 work) | #1, #2 |
| B | Prove f_nesting_boundary via Fischer-Ladner (task 36 work) | #4 |
| C | Restructure successor seed + prove p_step (task 40 revised) | (unblocks sorry) |
| D | Delete inconsistent existsTask_irreflexive_axiom (task 26 work) | #6 |
| E | Archive StagedConstruction + DiscreteTimeline to Boneyard | #7, #8, #9 |

### Phase 2: Sequential (depends on Phase 1)

| Work | Depends On | Axioms Eliminated |
|------|-----------|-------------------|
| Prove p_nesting_boundary (task 37 work) | Group B | #5 |
| Prove predecessor_f_step (task 34 work, may need seed redesign) | Group A | #3 |
| Fill succ_chain_fam_p_step sorry (task 35 Phase 4) | Group C | (eliminates sorry) |

### Phase 3: Verification

- `lean_verify` on completeness theorems — confirm zero custom axioms
- `lake build` — confirm zero errors
- Update TODO.md axiom_count to 0

## Synthesis

### Conflicts Resolved

1. **existsTask_irreflexive_axiom on critical path?** — Teammate B placed it on critical path via task 26; Teammate A correctly identified it is NOT on the completeness path (used only by DiscreteTimeline, CantorApplication, DovetailedTimelineQuot). **Resolution**: Not blocking completeness, but must be deleted since logically inconsistent. Task 26 is still needed but is low-priority cleanup, not critical path.

### Gaps Identified

1. **Seed consistency proof feasibility**: Both teammates suggest the deduction theorem approach but neither verified it works at the code level. This needs hands-on proof exploration.

2. **Fischer-Ladner closure for nesting boundaries**: Standard technique in modal logic, but needs verification that the proof system has the required formal infrastructure (formula complexity, subformula property).

3. **Successor seed restructuring for p_step**: The key question — can the successor seed be extended with `pastDeferralDisjunctions` while maintaining consistency? This requires investigation: would the combined seed `g_content(u) ∪ deferralDisjunctions(u) ∪ pastDeferralDisjunctions(u)` be consistent?

### Recommendations

1. **Immediate**: Delete `existsTask_irreflexive_axiom` and fix its 3 call sites
2. **Immediate**: Archive StagedConstruction/ and DiscreteTimeline paths to Boneyard (eliminates axioms 7-9)
3. **High priority**: Prove seed consistency axioms (axioms 1-2) via deduction theorem
4. **High priority**: Prove nesting boundaries (axioms 4-5) via Fischer-Ladner closure
5. **Medium priority**: Restructure successor seed for p_step (unblocks the only completeness sorry)
6. **Medium priority**: Prove or restructure predecessor f_step (axiom 3)
7. **Override**: Revise task 40 plan to NOT add axiom
8. **Abandon**: Tasks 988, 989, 22, 24, 38, 993, 999

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Axiom/architecture audit: axiom inventory, ExistsTask vs CanonicalTask, W=D conflation, sorry analysis | completed | high |
| B | Task review: open task triage, critical path definition, dependency graph, task 40 conflict | completed | high |

## References

| Location | Relevance |
|----------|-----------|
| SuccExistence.lean:266,311,516 | 3 seed/step axioms on completeness path |
| SuccChainFMCS.lean:350 | Only sorry on completeness path |
| SuccChainFMCS.lean:615,727 | 2 nesting boundary axioms |
| CanonicalIrreflexivity.lean:279 | Inconsistent axiom (contradicts existsTask_reflexive) |
| CanonicalFrame.lean:68 | ExistsTask definition (= g_content inclusion) |
| CanonicalTaskRelation.lean:167 | CanonicalTask definition (correct task_rel) |
| CanonicalConstruction.lean:70-74 | W=D conflation documentation |
| SuccChainTaskFrame.lean | Correct CanonicalTaskTaskFrame |
| DiscreteTimeline.lean:319 | discrete_Icc_finite_axiom (superseded path) |
| DiscreteSuccSeed.lean:300,430 | 2 StagedConstruction axioms |
