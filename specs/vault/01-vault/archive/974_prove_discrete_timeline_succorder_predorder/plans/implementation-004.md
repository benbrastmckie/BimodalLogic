# Implementation Plan: Task #974 (v4 - Structural Error Fix)

- **Task**: 974 - prove_discrete_timeline_succorder_predorder
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours (revised: +0.5h for Phase 6.5)
- **Dependencies**: Task 977 Phase 0 (DurationTransfer fix) [COMPLETED]
- **Research Inputs**:
  - research-001.md (initial analysis, WellFounded.min approach)
  - research-002.md (staged construction finiteness, DF vacuity discovery)
  - research-003.md (team research - Option B discrete staged construction)
  - research-004.md (DurationTransfer blocker analysis)
  - research-005.md (current standing post-DT fix, structural errors identified)
- **Artifacts**: plans/implementation-004.md (this file, supersedes implementation-003.md)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan is a revision of v3 following research-005.md findings. The DurationTransfer.lean blocker was resolved by task 977 Phase 0, but **7 new structural errors** were discovered in DiscreteTimeline.lean:

```
error: Function expected at DiscreteTimelineQuot but this term has type Type
```

**Root cause**: Type definitions use Lean's `variable` binding which auto-binds parameters as implicit, but instance declarations try to apply these types with explicit arguments.

**Key changes from v3**:
1. **Phase 6.5 added**: Fix structural type/function mismatch errors (30 min)
2. **Phase 5 note**: DN dependency remains (technical debt, documented in task 977)
3. **Phase 6 unblocked**: DurationTransfer fix confirmed working

### Prior Plan Status

- **v1 (implementation-001.md)**: Phases 1-3 completed (reduced sorries from 7 to 3)
- **v2 (implementation-002.md)**: Phase 4 BLOCKED on architectural issue (buildStagedTimeline uses DN)
- **v3 (implementation-003.md)**: Phases 4-5 completed, Phase 6 blocked by DurationTransfer
- **v4 (this plan)**: Phase 6.5 added to fix structural errors before proceeding

## Goals & Non-Goals

**Goals**:
- Fix 7 structural type errors in DiscreteTimeline.lean (Phase 6.5)
- Complete Phase 6 (update NoMax/NoMin proofs)
- Prove local finiteness (Phase 7)
- Resolve 3 remaining sorries (lines 193, 251, 296)
- Maintain zero-debt completion (no new sorries or axioms)

**Non-Goals**:
- Eliminating DN dependency in Phase 5 proofs (documented technical debt)
- Modifying task 977's architecture work
- Changing the discrete staged construction approach

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Structural error fix causes cascading changes | Medium | Low | Minimal fix: just remove explicit args from instances |
| TaskFrame identifier error has deeper cause | Medium | Low | Check imports, may need namespace qualification |
| Local finiteness proof requires complex Finset arithmetic | Medium | Medium | Use existing Mathlib patterns |

## Sorry Characterization

### Pre-existing Sorries (3 remaining)
- Line ~193: `discrete_timeline_lt_succFn` - `a < succFn a` (key discreteness for succ)
- Line ~251: `discrete_timeline_predFn_lt` - `predFn a < a` (key discreteness for pred)
- Line ~296: `IsSuccArchimedean.exists_succ_iterate_of_le` - finite reachability

### Resolution Path
- **Phase 6.5**: Fix structural errors (7 type/function mismatches)
- **Phase 6**: Update NoMax/NoMin proofs (now unblocked)
- **Phase 7**: Prove local finiteness -> 3 sorries
- **Phase 8**: Final verification

### New Sorries
- None. NEVER introduce new sorries.

---

## Implementation Phases

### Phases 1-5: [COMPLETED]

| Phase | Status | Summary |
|-------|--------|---------|
| 1-3 | [COMPLETED] | v1: Restructured SuccOrder/PredOrder, sorries 7->3 |
| 4 | [COMPLETED] | v3: Defined discreteStagedBuild in StagedExecution.lean |
| 5 | [COMPLETED] | v3: Added discrete_staged_has_future/past (uses DN - tech debt) |

**Note on Phase 5**: The `discrete_staged_has_future` proof uses `iterated_future_in_mcs` which invokes DN. This is documented technical debt in task 977's LogicVariants.lean. The proofs work but are not truly DN-free as originally intended.

---

### Phase 6.5: Fix Structural Type Errors [COMPLETED]

- **Dependencies:** Task 977 Phase 0 (DurationTransfer fix) [COMPLETED]
- **Goal:** Fix 7 structural errors so DiscreteTimeline.lean compiles (with sorries)

**Error Analysis** (from research-005.md):

The `variable` binding creates types with implicit parameters:
```lean
variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

def DiscreteTimelineQuot : Type :=  -- Compiles as DiscreteTimelineQuot : Type
  Antisymmetrization (DiscreteTimelineElem root_mcs root_mcs_proof) (· <= ·)
```

But instances try to pass explicit arguments:
```lean
instance : PredOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
--                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                    Error: Function expected, but Type given
```

**Tasks:**
- [ ] Fix lines 245, 259, 286, 312, 334, 377: Remove explicit args from type applications
  - Change `DiscreteTimelineQuot root_mcs root_mcs_proof` to `DiscreteTimelineQuot`
  - Variables are in scope, Lean will resolve them implicitly
- [ ] Fix line 373: Unknown identifier `TaskFrame`
  - Add missing import or use fully qualified name `Domain.TaskFrame`
- [ ] Verify file compiles with `lake build Bimodal.Metalogic.Domain.DiscreteTimeline`
- [ ] Confirm only 3 sorries remain (the original 3)

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Domain.DiscreteTimeline` succeeds with only 3 sorry warnings
- No "Function expected" errors

**Progress:**

**Session: 2026-03-16, sess_1773690238_j8k3m**
- Fixed: Reordered `DiscreteTimelineQuot` definition to after `Preorder` instance (fixes IsPreorder dependency)
- Fixed: Moved `NoMaxOrder` and `NoMinOrder` instances before `discrete_timeline_lt_succFn` (fixes forward reference)
- Added: `open Bimodal.Semantics` for `TaskFrame` accessibility
- Fixed: `le_pred_of_lt` field to use lambda wrapper for proper argument passing
- Sorries: 25 errors -> 0 errors, 3 sorries remain (lines 248, 306, 351)

---

### Phase 6: Update NoMax/NoMin proofs [COMPLETED]

- **Dependencies:** Phase 6.5
- **Goal:** Wire up discrete construction proofs

**Tasks:**
- [ ] Verify `NoMaxOrder` instance compiles using discrete_staged_has_future
- [ ] Verify `NoMinOrder` instance compiles using discrete_staged_has_past
- [ ] Check all infrastructure compiles (DiscreteTimelineElem, DiscreteTimelineR, etc.)
- [ ] Verify with `lean_goal` that NoMax/NoMin have no sorries

**Timing:** 30 minutes (reduced from 1h since structure already in place)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - verify/update proofs

**Verification:**
- `NoMaxOrder` and `NoMinOrder` instances compile without sorries
- `lake build` passes for DiscreteTimeline

---

### Phase 7: Prove local finiteness and resolve 3 sorries [BLOCKED]

- **Dependencies:** Phase 6
- **Goal:** Prove intervals are finite, derive discreteness, resolve remaining sorries

**Part A: Prove local finiteness**

- [ ] Prove `discrete_staged_finitely_between`:
  ```lean
  theorem discrete_staged_finitely_between
      (a b : DiscreteTimelineQuot)
      (hab : a < b) : Set.Finite {x | a < x /\ x < b}
  ```
- [ ] Define `LocallyFiniteOrder` instance using finiteness
- [ ] Verify with `lean_goal`

**Part B: Resolve 3 sorries**

- [ ] Prove `discrete_timeline_lt_succFn` (line ~193):
  - Finite nonempty Ioi sets have minimum
  - succFn a = min(Ioi a), hence a < succFn a
- [ ] Prove `discrete_timeline_predFn_lt` (line ~251) symmetrically
- [ ] Derive `IsSuccArchimedean` from `LocallyFiniteOrder`:
  ```lean
  instance : IsSuccArchimedean DiscreteTimelineQuot :=
    LinearLocallyFiniteOrder.instIsSuccArchimedean
  ```
- [ ] Verify all 3 sorries resolved

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification:**
- `grep -rn "\bsorry\b" DiscreteTimeline.lean` returns empty
- `LocallyFiniteOrder` and `IsSuccArchimedean` instances compile

---

### Phase 8: Final verification and cleanup [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Verify zero-debt completion

**Tasks:**
- [ ] Run `lake build` for full project verification
- [ ] Verify no new sorries in modified files
- [ ] Verify no new axioms
- [ ] Check `discreteCanonicalTaskFrame` compiles
- [ ] Update plan status markers to [COMPLETED]
- [ ] Create implementation summary

**Timing:** 30 minutes

**Verification:**
- Zero sorries in DiscreteTimeline.lean
- `lake build` passes completely

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Downstream Verification
- [ ] `discreteCanonicalTaskFrame` compiles without sorries
- [ ] No regressions in dependent files

## Artifacts & Outputs

- `specs/974_prove_discrete_timeline_succorder_predorder/plans/implementation-004.md` (this file)
- `specs/974_prove_discrete_timeline_succorder_predorder/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

## Rollback/Contingency

1. **Phase 6.5 fails**: Try Option B (explicit function definitions) or Option C (@ syntax)
2. **Phase 7 fails**: If >4h total, consider temporary axiom for finite intervals
3. **General rollback**: Preserve phase-by-phase commits

## Supersession Note

This plan (v4) supersedes implementation-003.md. Key changes:
- **Phase 6.5 added**: Fix 7 structural type errors (research-005 findings)
- **Phase timings adjusted**: Reduced Phase 6 estimate since structure exists
- **DN dependency documented**: Phase 5 proofs use DN (technical debt, not blocking)
- **Dependency confirmed**: Task 977 Phase 0 completed, DurationTransfer fixed
