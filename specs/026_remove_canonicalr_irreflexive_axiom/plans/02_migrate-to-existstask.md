# Implementation Plan: Migrate Codebase to ExistsTask (v2)

- **Task**: 26 - remove_canonicalr_irreflexive_axiom
- **Status**: [NOT STARTED]
- **Effort**: 8 hours (reduced from 12 - architecture work already done)
- **Dependencies**: None
- **Research Inputs**: specs/026_remove_canonicalr_irreflexive_axiom/reports/18_team-research.md
- **Artifacts**: plans/02_migrate-to-existstask.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a **revised plan** after the CanonicalR → ExistsTask rename was partially completed.

### What Changed (User Action)

The user renamed `CanonicalR` to `ExistsTask` as the primary definition:
- `ExistsTask` is now the PRIMARY definition in CanonicalFrame.lean:68
- `CanonicalR` is now a backwards-compatibility `abbrev` alias
- `ExistsTask_past` is primary, `CanonicalR_past` is alias
- 7 files updated to use `ExistsTask` directly
- 67 files still use `CanonicalR` (via alias)
- 22 files still use `CanonicalR_past` (via alias)

### Remaining Work

1. **Derive irreflexivity theorem** for CanonicalTask (Phase 1 from v1 - not yet done)
2. **Migrate remaining files** from alias to primary name
3. **Prove backward sorry** (optional, high effort)
4. **Make irreflexivity derivable** (blocked by backward sorry)

### Dropped/Completed from v1

- ~~Phase 2 (Documentation)~~ - COMPLETED (docstrings added)
- ~~Phase 3 (Create ExistsTask alias)~~ - COMPLETED (inverted: ExistsTask is primary)
- ~~Phase 6 (parametric_canonical_task_rel)~~ - Deferred, not critical path

## Goals & Non-Goals

**Goals**:
- Derive canonicalTask_irreflexive from existing axiom
- Migrate all CanonicalR usages to ExistsTask
- Migrate all CanonicalR_past usages to ExistsTask_past
- Deprecate alias names with clear warnings
- Prove backward sorry if feasible

**Non-Goals**:
- Remove the irreflexivity axiom entirely (confirmed needed)
- Change mathematical content
- Modify CanonicalTask definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mass rename causes merge conflicts | M | L | Single PR, coordinate timing |
| Backward sorry proof is hard | H | H | Optional phase; main refactoring works without it |
| Deprecation warnings excessive | L | M | Phase migration, address in batches |

## Implementation Phases

### Phase 1: Derive canonicalTask_irreflexive [COMPLETED]

**Goal**: Add derived irreflexivity theorem for CanonicalTask.

**Tasks**:
- [ ] Add theorem in CanonicalIrreflexivity.lean:
  ```lean
  /-- CanonicalTask irreflexivity for positive durations.
      If n > 0, then ¬CanonicalTask M n M for any MCS M.

      Proof: CanonicalTask M n M with n > 0 implies ExistsTask M M
      (via canonicalTask_pos_implies_canonicalR), contradicting
      the irreflexivity axiom under strict semantics. -/
  theorem canonicalTask_irreflexive (M : Set Formula) (n : Int)
      (h_mcs : SetMaximalConsistent M) (h_pos : 0 < n) :
      ¬CanonicalTask M n M := fun h_task =>
    canonicalR_irreflexive_axiom M h_mcs (canonicalTask_pos_implies_canonicalR h_task)
  ```
- [ ] Add symmetric version for negative n using converse theorem
- [ ] Verify with `lake build`

**Note**: This theorem only applies under STRICT semantics. Under reflexive semantics (Task 29), ExistsTask is reflexive, not irreflexive.

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- Build succeeds with no new sorries
- Theorem correctly uses the axiom

---

### Phase 2: Add Deprecation Warnings [COMPLETED]

**Goal**: Mark CanonicalR and CanonicalR_past as deprecated.

**Tasks**:
- [ ] Add deprecation to CanonicalR alias in CanonicalFrame.lean:
  ```lean
  @[deprecated ExistsTask (since := "2026-03-23")]
  abbrev CanonicalR := ExistsTask
  ```
- [ ] Add deprecation to CanonicalR_past alias:
  ```lean
  @[deprecated ExistsTask_past (since := "2026-03-23")]
  abbrev CanonicalR_past := ExistsTask_past
  ```
- [ ] Build and note deprecation warning count

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

**Verification**:
- Build succeeds
- Deprecation warnings appear for alias usages

---

### Phase 3: Migrate Core Metalogic Files [COMPLETED]

**Goal**: Update core files to use ExistsTask/ExistsTask_past directly.

**Target files** (non-Boneyard, active code):
1. `Theories/Bimodal/Metalogic/Bundle/` (8 files)
2. `Theories/Bimodal/Metalogic/Algebraic/` (5 files)
3. `Theories/Bimodal/Metalogic/StagedConstruction/` (12 files)
4. `Theories/Bimodal/Metalogic/Domain/` (1 file)
5. `Theories/Bimodal/Metalogic/Canonical/` (3 files)

**Tasks**:
- [ ] Replace `CanonicalR` → `ExistsTask` in each file
- [ ] Replace `CanonicalR_past` → `ExistsTask_past` in each file
- [ ] Run `lake build` after each batch
- [ ] Update any local variable names for clarity (e.g., `h_R` → `h_exists`)

**Timing**: 3 hours

**Files to modify**: ~29 files in Theories/Bimodal/Metalogic/

**Verification**:
- Build succeeds after each batch
- No CanonicalR/CanonicalR_past usages remain in Metalogic/

---

### Phase 4: Migrate Boneyard Files [COMPLETED]

**Goal**: Update Boneyard files for consistency.

**Target files**:
- `Theories/Bimodal/Boneyard/Task956_*/` (6 files)
- `Theories/Bimodal/Boneyard/Task994_*/` (2 files)
- `Boneyard/Metalogic/Bundle/` (7 files)

**Tasks**:
- [ ] Replace `CanonicalR` → `ExistsTask` in each file
- [ ] Replace `CanonicalR_past` → `ExistsTask_past` in each file
- [ ] Verify build

**Timing**: 1.5 hours

**Files to modify**: ~15 files in Boneyard/

**Verification**:
- Build succeeds
- Boneyard files updated for consistency

---

### Phase 5: Remove Deprecation (Optional) [COMPLETED]

**Goal**: After full migration, optionally remove deprecated aliases.

**Prerequisite**: Phases 3-4 complete with zero usages of CanonicalR/CanonicalR_past

**Tasks**:
- [ ] Grep to confirm zero usages
- [ ] Remove `abbrev CanonicalR` and `abbrev CanonicalR_past`
- [ ] Remove deprecation-related imports if any
- [ ] Final build verification

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

**Verification**:
- Build succeeds
- No CanonicalR or CanonicalR_past definitions remain

---

### Phase 6: Prove Backward Sorry (Optional, High Effort) [NOT STARTED]

**Goal**: Prove `ExistsTask M N → ∃ n >= 1, CanonicalTask M n N` in CanonicalRecovery.lean.

**Tasks**:
- [ ] Analyze current sorry location and requirements
- [ ] Study Lindenbaum witness construction
- [ ] Prove witnesses satisfy F-step condition
- [ ] Complete the backward direction proof

**Timing**: 4+ hours (exploratory)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean`

**Verification**:
- No sorries in recovery theorems

---

### Phase 7: Make Irreflexivity Derivable (Blocked by Phase 6) [NOT STARTED]

**Goal**: Once backward sorry is filled, derive irreflexivity from CanonicalTask.

**Prerequisite**: Phase 6 complete

**Tasks**:
- [ ] Add theorem deriving ExistsTask irreflexivity from canonicalTask_irreflexive
- [ ] Document both formulations as equivalent

**Timing**: 1 hour (after Phase 6)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- Dual derivation complete

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new sorries introduced
- [ ] Deprecation warnings decrease as migration progresses
- [ ] Zero CanonicalR/CanonicalR_past usages after Phase 4

## Artifacts & Outputs

- `plans/02_migrate-to-existstask.md` (this file)
- Updated Lean files:
  - `CanonicalIrreflexivity.lean` - Derived theorem
  - `CanonicalFrame.lean` - Deprecations, eventual removal
  - 40+ files - Name migration

## Rollback/Contingency

- Phases 1-4 are safe renames using existing aliases
- Phase 5 (removal) can be deferred indefinitely if external dependencies exist
- Phase 6-7 are optional and don't affect correctness

Each phase is independently committable.

## Change Summary from v1

| v1 Phase | v2 Status | Notes |
|----------|-----------|-------|
| 1. Derived irreflexivity | Phase 1 | Still needed |
| 2. Documentation | COMPLETED | User action |
| 3. ExistsTask alias | COMPLETED | Inverted: ExistsTask is primary |
| 4. Migrate key files | Phase 3-4 | Expanded to all files |
| 5. Eliminate CanonicalR_past | Phase 3-4 | Now ExistsTask_past migration |
| 6. parametric_canonical_task_rel | DEFERRED | Not critical path |
| 7. Backward sorry | Phase 6 | Still optional |
| 8. Make derivable | Phase 7 | Still blocked by Phase 6 |
