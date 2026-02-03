# Implementation Plan: Task #837

- **Task**: 837 - Resolve ProofSearch Blockers in Example Files
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None (Task 260 already completed 2026-01-12)
- **Research Inputs**: specs/837_resolve_proofsearch_blockers/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Task 260 (ProofSearch) was completed on 2026-01-12, but three example files still contain stale comments claiming "Task 260 is BLOCKED". This task updates the example files to remove stale comments and add working automation examples using the available `modal_search`, `temporal_search`, and `propositional_search` tactics from `Bimodal.Automation`.

### Research Integration

The research report confirmed:
- Task 260 completed 2026-01-12 with proof term construction capability
- Working tactics available: `modal_search`, `temporal_search`, `propositional_search`, `tm_auto`
- The commented-out `Bimodal.Automation.ProofSearch` import can simply be replaced with `Bimodal.Automation`
- EXERCISE sections should be preserved (pedagogical purpose)

## Goals & Non-Goals

**Goals**:
- Remove all stale "Task 260 is BLOCKED" comments from the three example files
- Add `import Bimodal.Automation` to each file
- Add working automation examples demonstrating the tactics
- Verify all files compile without errors

**Non-Goals**:
- Filling in the EXERCISE `sorry` placeholders (they serve pedagogical purposes)
- Comprehensive automation documentation (already exists in Automation.lean)
- Modifying ProofSearch internals

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tactic fails on example formulas | M | L | Test with `modal_search (depth := 10)` if default depth insufficient |
| Import conflicts | L | L | `Bimodal.Automation` already imports necessary dependencies |
| Build breaks | M | L | Incremental changes with `lake build` after each file |

## Sorry Characterization

### Pre-existing Sorries
- TemporalProofs.lean: 2 EXERCISE sorries at lines 180, 194 (intentional)
- ModalProofs.lean: 5 EXERCISE sorries at lines 168, 183, 196, 249, 256 (intentional)
- BimodalProofs.lean: 0 sorries (all examples complete)

### Expected Resolution
- No sorry resolution planned - EXERCISE sorries are intentional pedagogical placeholders

### New Sorries
- None expected. All new automation examples should compile with the working tactics.

### Remaining Debt
- 7 EXERCISE sorries remain after implementation (intentional, not technical debt)

## Implementation Phases

### Phase 1: Update TemporalProofs.lean [COMPLETED]

**Goal**: Remove stale comments and add working temporal automation examples

**Tasks**:
- [ ] Replace line 4 `-- import Bimodal.Automation.ProofSearch` with `import Bimodal.Automation`
- [ ] Replace line 70 `-- open Bimodal.Automation (ProofSearch)` with `open Bimodal.Automation`
- [ ] Replace lines 313-326 (stale Automated Temporal Search section) with working examples using `temporal_search` and `modal_search`
- [ ] Run `lake build Bimodal.Examples.TemporalProofs` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Examples/TemporalProofs.lean` - Remove stale comments, add automation import and examples

**Verification**:
- File compiles without errors
- New examples use `temporal_search` tactic successfully

---

### Phase 2: Update ModalProofs.lean [COMPLETED]

**Goal**: Remove stale comments and add working modal automation examples

**Tasks**:
- [ ] Replace line 5 `-- import Bimodal.Automation.ProofSearch` with `import Bimodal.Automation`
- [ ] Replace line 60 `-- open Bimodal.Automation (ProofSearch)` with `open Bimodal.Automation`
- [ ] Replace lines 291-305 (stale Automated Proof Search section) with working examples using `modal_search` and `propositional_search`
- [ ] Run `lake build Bimodal.Examples.ModalProofs` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Examples/ModalProofs.lean` - Remove stale comments, add automation import and examples

**Verification**:
- File compiles without errors
- New examples use `modal_search` tactic successfully

---

### Phase 3: Update BimodalProofs.lean [COMPLETED]

**Goal**: Remove stale comments and add working bimodal automation examples

**Tasks**:
- [ ] Replace line 3 `-- import Bimodal.Automation.ProofSearch` with `import Bimodal.Automation`
- [ ] Replace line 43 `-- open Bimodal.Automation (ProofSearch)` with `open Bimodal.Automation`
- [ ] Replace lines 203-213 (stale Perpetuity Automation Examples section) with working examples demonstrating perpetuity principles found automatically
- [ ] Run `lake build Bimodal.Examples.BimodalProofs` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Examples/BimodalProofs.lean` - Remove stale comments, add automation import and examples

**Verification**:
- File compiles without errors
- New examples use `modal_search` tactic successfully

---

### Phase 4: Full Build Verification [COMPLETED]

**Goal**: Verify entire project builds successfully with all changes

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Verify no new errors introduced
- [ ] Verify example files appear in project correctly
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- `specs/837_resolve_proofsearch_blockers/summaries/implementation-summary-20260203.md` - Create summary

**Verification**:
- Full project builds successfully
- All three example files compile
- Summary documents changes made

## Testing & Validation

- [ ] `lake build Bimodal.Examples.TemporalProofs` succeeds
- [ ] `lake build Bimodal.Examples.ModalProofs` succeeds
- [ ] `lake build Bimodal.Examples.BimodalProofs` succeeds
- [ ] `lake build` (full project) succeeds
- [ ] New automation examples compile without error
- [ ] EXERCISE sorries preserved (not accidentally filled in)

## Artifacts & Outputs

- `Theories/Bimodal/Examples/TemporalProofs.lean` - Updated with automation
- `Theories/Bimodal/Examples/ModalProofs.lean` - Updated with automation
- `Theories/Bimodal/Examples/BimodalProofs.lean` - Updated with automation
- `specs/837_resolve_proofsearch_blockers/plans/implementation-001.md` - This plan
- `specs/837_resolve_proofsearch_blockers/summaries/implementation-summary-20260203.md` - Final summary

## Rollback/Contingency

If automation tactics fail on specific formulas:
1. Try increasing search depth: `modal_search (depth := 10)`
2. Try alternative tactic: `temporal_search` vs `modal_search`
3. If still failing, add comment explaining tactic limitation and keep as `sorry` with TODO

If build breaks:
1. Revert to previous version via git
2. Apply changes incrementally to isolate issue
3. Consult `Bimodal.Automation.lean` documentation for correct usage
