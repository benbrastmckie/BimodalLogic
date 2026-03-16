# Research Report: Task #977 — Plan Revision Analysis

**Task**: 977 - Organize TM base logic with extensions
**Date**: 2026-03-16
**Session**: sess_1773687174_6e1b51
**Focus**: Assess plan improvements based on task 973 completion and research-004 findings

---

## Executive Summary

Two significant developments affect the task 977 implementation plan:

1. **Task 973 is now COMPLETED**: `NoMaxOrder`/`NoMinOrder` on `ConstructiveQuotient` are proven. This unblocks Phase 4 (dense completeness wiring).

2. **DurationTransfer.lean has pre-existing errors** (discovered in 974 research-004): 7 API-level errors block DiscreteTimeline.lean compilation. Research-004 recommends bundling the fix with task 977 rather than creating a separate task.

**Recommended plan changes**:
- Remove task 973 dependency from Phase 4 — **no longer blocking**
- Add a new Phase 0 (or Phase 3.5): Fix DurationTransfer.lean API errors
- Update Phase 6 dependency: blocked by DurationTransfer fix, not task 974

---

## Part I: Task 973 Completion Impact

### What Was Completed

Task 973 created `CanonicalSerialFrameInstance.lean` with:
- `instance : NoMaxOrder ConstructiveQuotient`
- `instance : NoMinOrder ConstructiveQuotient`

These were the 2 sorries at lines 580 and 585 in `ConstructiveFragment.lean`.

### Impact on 977 Plan

**Phase 4 (Dense Completeness Wiring)** had dependency:
> "Dependencies: Phase 2 (soundness verified), Task 973 (blocking)"

With task 973 complete, Phase 4 is now **unblocked**. The dense completeness theorem can proceed as soon as Phase 2 is done.

**Required change**: Remove task 973 from Phase 4 dependencies.

---

## Part II: DurationTransfer.lean Errors

### Error Summary (from research-004)

7 errors in `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`:

| Line | Issue |
|------|-------|
| 75, 126, 161 | `IsOrderedAddMonoid` type argument wrong (uses `Add` instead of `AddCommMonoid`) |
| 128 | `IsOrderedAddMonoid Int` instance not synthesizable |
| 144 | `Countable Rat` instance not found |
| 187 | Universe level mismatch |

### Why This Matters for 977

DiscreteTimeline.lean imports DurationTransfer.lean (line 1). As long as DurationTransfer has errors:
- DiscreteTimeline.lean won't compile
- Phase 6 (Discrete Completeness Framework) cannot proceed
- Full pipeline verification impossible

### Recommended Fix Location

Research-004 analyzed three options and recommended **Option A**: Bundle the DurationTransfer fix with task 977.

Rationale:
- DurationTransfer.lean is part of the domain construction pipeline
- Task 977's scope includes "organizing metalogic" and "filling gaps"
- Creating a separate micro-task adds overhead
- The fix is ~1-2 hours of API-level work

---

## Part III: Revised Plan Structure

### Current Plan (implementation-001.md)

| Phase | Description | Dependencies | Status |
|-------|-------------|--------------|--------|
| 1 | Documentation audit | None | OK |
| 2 | Derivation soundness | None | OK |
| 3 | FrameClass enumeration | Phase 1 | OK |
| 4 | Dense completeness wiring | Phase 2, **Task 973** | Task 973 done → OK |
| 5 | Base completeness statement | Phase 4 | OK |
| 6 | Discrete completeness framework | Phase 5, Task 974 | **Task 974 blocked by DT** |
| 7 | Logic variants summary | Phase 6 | OK |

### Proposed Revision

**Option A: Add Phase 0 (Pre-work)**

| Phase | Description | Dependencies |
|-------|-------------|--------------|
| **0** | **Fix DurationTransfer.lean API errors** | **None** |
| 1 | Documentation audit | None |
| 2 | Derivation soundness | None |
| 3 | FrameClass enumeration | Phase 1 |
| 4 | Dense completeness wiring | Phase 2 |
| 5 | Base completeness statement | Phase 4 |
| 6 | Discrete completeness framework | Phase 5, **Phase 0** |
| 7 | Logic variants summary | Phase 6 |

**Option B: Insert as Phase 3.5**

Add DurationTransfer fix between FrameClass (Phase 3) and Dense completeness (Phase 4), since it's domain infrastructure work.

**Recommendation**: Option A (Phase 0). The fix is truly independent of the other phases and should be done first to unblock the full pipeline.

### Dependency Graph After Revision

```
Phase 0 (DT fix) ───────────────────────────────┐
    |                                           │
Phase 1 (docs) ─→ Phase 3 (FrameClass)          │
    |                                           │
Phase 2 (soundness) ─→ Phase 4 (dense) ─→ Phase 5 (base) ─→ Phase 6 (discrete) ─→ Phase 7 (summary)
                                                             │
                                                             └── requires Phase 0
```

---

## Part IV: Additional Technical Debt Noted

Research-004 identified a deeper issue that does NOT block 977 but should be documented:

### DN Dependency in Discrete Construction

The `discrete_staged_has_future` proof in CantorPrereqs.lean uses `iterated_future_in_mcs`, which invokes the DN (density) axiom. This contradicts the intended "DN-free discrete construction."

**Impact**: This is technical debt but does NOT block proofs from compiling. It should be:
1. Documented in Phase 7's summary
2. Flagged for task 978's typeclass architecture work

---

## Part V: Updated Sequencing Recommendation

With the changes above, the optimal execution order is:

```
977 Phase 0  (DT fix, 1-2h) ─┐
                              │
977 Phase 1  (docs, 1-2h)    │
977 Phase 2  (soundness, 1-2h)
977 Phase 3  (FrameClass, 1.5h)
                              │
977 Phase 4  (dense, 3-4h) ──┤── Task 973 done, no longer blocking
977 Phase 5  (base, 2-3h)    │
                              │
974 Phases 6-8 (resume, ~2h) ◄┘ unblocked by Phase 0
                              │
977 Phase 6  (discrete, 2-3h) ◄── requires Phase 0 + depends on 974 sorries being resolved
977 Phase 7  (summary, 2h)
                              │
978 (typeclass refactor) ◄────── after 977 complete
```

**Key insight**: Phases 1-5 of 977 can proceed in parallel with or before fixing DurationTransfer, since they don't touch DiscreteTimeline. But Phase 0 should be done early to enable task 974 to resume.

---

## Recommendations

### Plan File Updates Required

1. **Phase 4**: Remove "Task 973 (blocking)" from dependencies
2. **Add Phase 0**: "Fix DurationTransfer.lean API errors"
   - Tasks: Fix IsOrderedAddMonoid instantiation, add missing imports, fix universe annotations
   - Timing: 1-2 hours
   - Verification: `lake build Bimodal.Metalogic.Domain.DurationTransfer` passes
3. **Phase 6**: Update dependency to "Phase 5, Phase 0" (not "Task 974")
4. **Phase 7**: Add documentation of DN dependency technical debt

### Use `/revise` Command

Run `/revise 977` to update the implementation plan with these changes.

---

## Artifacts

- **This report**: `specs/977_organize_tm_base_logic_with_extensions/reports/research-002.md`
- **Referenced**:
  - `specs/974_prove_discrete_timeline_succorder_predorder/reports/research-004.md`
  - `specs/973_prove_constructivefragment_nomaxorder_nominorder/summaries/implementation-summary-20260316.md` (completion evidence)
  - `specs/977_organize_tm_base_logic_with_extensions/plans/implementation-001.md` (current plan)
