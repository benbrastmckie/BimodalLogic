# Implementation Plan: Task #56

- **Task**: 56 - clean_up_succchain_fmcs_dead_code
- **Status**: [NOT STARTED]
- **Effort**: 1.5-2 hours
- **Dependencies**: None
- **Research Inputs**: specs/056_clean_up_succchain_fmcs_dead_code/reports/01_dead-code-inventory.md
- **Artifacts**: plans/01_dead-code-removal.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Remove approximately 2034 lines of dead code from two Lean 4 files: SuccChainFMCS.lean (~1859 lines) and RestrictedMCS.lean (~175 lines). The dead code consists of mathematically FALSE theorems, deprecated nesting bounds, and failed proof attempts (restricted_succ_propagates_F_not variants with 9 sorries). Deletion follows dependency order to maintain compilability after each phase.

### Research Integration

- Research report identified 14 specific items with exact line numbers
- Established dependency chains showing safe deletion order
- Confirmed no external usages via grep verification
- Identified items to KEEP: restricted versions that work correctly

## Goals & Non-Goals

**Goals**:
- Remove all 14 identified dead code items
- Reduce SuccChainFMCS.lean by ~1859 lines (from 4542 to ~2683)
- Reduce RestrictedMCS.lean by ~175 lines (from 1603 to ~1428)
- Maintain passing `lake build` after each phase
- Update summary section at end of SuccChainFMCS.lean

**Non-Goals**:
- Reimplementing restricted_forward_chain_forward_F (separate task)
- Modifying any non-dead code
- Changing any restricted variants that work correctly

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependencies break build | M | L | lake build verification after each phase |
| Line numbers shifted from report | L | M | Use identifier names for search, not hardcoded lines |
| Accidentally delete working code | H | L | Match exact function names from research inventory |

## Implementation Phases

### Phase 1: Remove FALSE restricted variants [COMPLETED]

**Goal**: Delete restricted_succ_propagates_F_not variants that are proven FALSE

**Tasks**:
- [ ] Delete `restricted_succ_propagates_F_not'` (lines ~3213-4076, ~863 lines)
- [ ] Delete `restricted_single_step_forcing'` (lines ~4089-4112, ~23 lines)
- [ ] Delete `restricted_succ_propagates_F_not` (lines ~3151-3191, ~40 lines)
- [ ] Run `lake build` to verify compilation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - delete 3 theorems

**Verification**:
- `lake build` completes without errors
- grep confirms no remaining references to deleted theorems

---

### Phase 2: Remove single_step_forcing and bounded_witness [COMPLETED]

**Goal**: Delete dependent dead code that relied on Phase 1 items

**Tasks**:
- [ ] Delete `restricted_bounded_witness` (lines ~4128-4192, ~64 lines)
- [ ] Delete `restricted_single_step_forcing` (lines ~2392-3141, ~749 lines)
- [ ] Run `lake build` to verify compilation

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - delete 2 theorems

**Verification**:
- `lake build` completes without errors
- Large line count reduction visible (~813 lines)

---

### Phase 3: Remove deprecated nesting bounds and dependents [COMPLETED]

**Goal**: Delete mathematically FALSE nesting bounds and their dependent theorems

**Tasks**:
- [ ] Delete `SuccChainTemporalCoherent` (lines ~1225-1228, ~4 lines)
- [ ] Delete `succ_chain_backward_P` (lines ~1137-1169, ~32 lines)
- [ ] Delete `succ_chain_forward_F` (lines ~850-886, ~36 lines)
- [ ] Delete `succ_chain_forward_F_neg` (lines ~794-826, ~32 lines)
- [ ] Delete `p_nesting_boundary` (lines ~1022-1026, ~4 lines)
- [ ] Delete `p_nesting_is_bounded` (lines ~1005-1009, ~4 lines)
- [ ] Delete `f_nesting_boundary` (lines ~782-786, ~4 lines)
- [ ] Delete `f_nesting_is_bounded` (lines ~753-757, ~4 lines)
- [ ] Run `lake build` to verify compilation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - delete 8 theorems

**Verification**:
- `lake build` completes without errors
- Deprecated annotations no longer present for deleted items

---

### Phase 4: RestrictedMCS cleanup and summary update [COMPLETED]

**Goal**: Clean RestrictedMCS.lean and update SuccChainFMCS.lean summary

**Tasks**:
- [ ] Delete `p_step_blocking_for_deferral_restricted` from RestrictedMCS.lean (lines ~945-1120, ~175 lines)
- [ ] Run `lake build` to verify compilation
- [ ] Update summary section at end of SuccChainFMCS.lean (lines ~4486-4540) to reflect removed code
- [ ] Final `lake build` verification

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - delete 1 theorem
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - update summary section

**Verification**:
- `lake build` completes without errors
- Summary section accurately reflects remaining code
- Total lines removed approximately matches estimate (~2034)

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No grep hits for deleted theorem names
- [ ] Line count diff shows approximately 2000 lines removed
- [ ] UltrafilterChain.lean still compiles (had comment references to SuccChainTemporalCoherent)

## Artifacts & Outputs

- plans/01_dead-code-removal.md (this plan)
- summaries/01_dead-code-removal-summary.md (on completion)

## Rollback/Contingency

Git provides full rollback capability:
- Each phase should be committed separately
- If any phase breaks build, `git checkout -- <file>` restores previous state
- Full rollback: `git reset --hard HEAD~N` (where N = number of phase commits)
