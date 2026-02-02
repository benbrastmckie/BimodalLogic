# Implementation Plan: BMCS Universe Polymorphism Resolution

- **Task**: 815 - BMCS Universe Polymorphism Resolution
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/815_bmcs_universe_polymorphism_resolution/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Resolve 2 universe polymorphism sorries in BMCS completeness by changing `Type*` to `Type` in the `bmcs_valid` and `bmcs_consequence` definitions. The research identified this as a purely technical issue - the polymorphism is mathematically unnecessary for completeness, and Int provides all required type class instances.

### Research Integration

Research report: specs/815_bmcs_universe_polymorphism_resolution/reports/research-001.md

Key findings integrated into plan:
- Solution A (universe-monomorphic definitions) is recommended as minimal and clean
- `Type*` elaborates to `Type u` which cannot unify with `Type 0` (Int)
- Int has all required instances verified (AddCommGroup, LinearOrder, IsOrderedAddMonoid)
- Two test files exist that can be deleted after implementation

## Goals & Non-Goals

**Goals**:
- Change `bmcs_valid` definition in BMCSTruth.lean from `Type*` to `Type`
- Change `bmcs_consequence` definition in Completeness.lean from `Type*` to `Type`
- Replace sorries with direct proofs in Completeness.lean
- Verify clean build with no remaining sorries in these lemmas
- Clean up test files created during research

**Non-Goals**:
- Changing other universe-polymorphic definitions not related to completeness
- Modifying the completeness theorem statements themselves
- Adding new API surface area

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breaks due to universe constraints elsewhere | Medium | Low | Research verified Int instances exist; rollback if needed |
| Proof still doesn't compile after Type* change | High | Very Low | Research tested this approach in UniverseTest.lean |
| Other code depends on polymorphic version | Medium | Low | API is backward compatible for Int usage |

## Implementation Phases

### Phase 1: Modify bmcs_valid Definition [NOT STARTED]

**Goal**: Change bmcs_valid to use universe-monomorphic Type

**Tasks**:
- [ ] Edit BMCSTruth.lean line 109: change `(D : Type*)` to `(D : Type)`
- [ ] Run lake build to verify no new errors introduced
- [ ] Use lean_goal to check proof state at Completeness.lean:158

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` - line 109 definition change

**Verification**:
- Lake build succeeds
- No new errors introduced
- Proof state at sorry shows Int unification now possible

---

### Phase 2: Modify bmcs_consequence Definition [NOT STARTED]

**Goal**: Change bmcs_consequence to use universe-monomorphic Type

**Tasks**:
- [ ] Edit Completeness.lean line 268: change `(D : Type*)` to `(D : Type)`
- [ ] Run lake build to verify no new errors
- [ ] Use lean_goal to check proof state at Completeness.lean:292

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - line 268 definition change

**Verification**:
- Lake build succeeds
- Both sorries now have compatible universes
- No other code broken by change

---

### Phase 3: Prove the Instantiation Lemmas [NOT STARTED]

**Goal**: Replace sorries with direct proofs

**Tasks**:
- [ ] At Completeness.lean:158-160, replace sorry with `exact h Int B fam hfam t`
- [ ] At Completeness.lean:290-292, replace sorry with `exact h Int B fam hfam t h_sat`
- [ ] Run lake build to verify proofs are accepted
- [ ] Use lean_goal to confirm no remaining goals

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - lines 158-160 and 290-292 proof completion

**Verification**:
- Both lemmas compile without sorry
- Lake build shows 2 fewer sorries in repository
- All dependent theorems still compile

---

### Phase 4: Cleanup and Verification [NOT STARTED]

**Goal**: Remove test files and verify final build

**Tasks**:
- [ ] Delete Theories/Bimodal/Metalogic/Bundle/UniverseTest.lean
- [ ] Delete Theories/Bimodal/Metalogic/Bundle/UniverseTest2.lean
- [ ] Run lake build to ensure clean build
- [ ] Grep for remaining sorries in Completeness.lean to verify these 2 are resolved

**Timing**: 15 minutes

**Files to modify**:
- Delete: `Theories/Bimodal/Metalogic/Bundle/UniverseTest.lean`
- Delete: `Theories/Bimodal/Metalogic/Bundle/UniverseTest2.lean`

**Verification**:
- Test files removed
- Lake build succeeds with no errors
- Sorry count decreased by 2
- bmcs_weak_completeness and bmcs_strong_completeness still compile

## Testing & Validation

- [ ] Lake build succeeds with no errors
- [ ] No sorries remain at Completeness.lean:158 and Completeness.lean:292
- [ ] Completeness theorems (bmcs_weak_completeness, bmcs_strong_completeness) still compile
- [ ] Test files UniverseTest.lean and UniverseTest2.lean deleted
- [ ] Repository sorry count decreased by 2

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- Deleted: `Theories/Bimodal/Metalogic/Bundle/UniverseTest.lean`
- Deleted: `Theories/Bimodal/Metalogic/Bundle/UniverseTest2.lean`
- Created: `specs/815_bmcs_universe_polymorphism_resolution/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the Type change breaks other code:
1. Revert BMCSTruth.lean line 109 to `Type*`
2. Revert Completeness.lean line 268 to `Type*`
3. Restore sorries at lines 160 and 292
4. Mark task as [BLOCKED] and investigate alternative solutions

This is unlikely based on research verification, but provides clear rollback path if needed.
