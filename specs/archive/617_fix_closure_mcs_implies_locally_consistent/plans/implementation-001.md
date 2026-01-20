# Implementation Plan: Task #617

- **Task**: 617 - Fix closure_mcs_implies_locally_consistent
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/617_fix_closure_mcs_implies_locally_consistent/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove temporal reflexivity conditions (H phi -> phi, G phi -> phi) from the `IsLocallyConsistent` definition since they are architecturally unsound for TM logic's strict temporal semantics. The TM logic uses strict inequalities (s < t, t < s) for temporal operators, making these axioms invalid. After removing these conditions, the `closure_mcs_implies_locally_consistent` theorem becomes provable using standard MCS properties.

### Research Integration

Key findings from research-001.md:
- `IsLocallyConsistent` conditions 4-5 (temporal reflexivity) are never used by downstream code
- TM logic's strict temporal semantics (`Semantics/Truth.lean:109-110`) invalidates these axioms
- The semantic approach via `SemanticCanonicalModel` already bypasses this issue entirely
- Same sorry exists in old `FiniteCanonicalModel.lean:1302` - this is a long-standing known issue

## Goals & Non-Goals

**Goals**:
- Remove temporal reflexivity conditions from `IsLocallyConsistent` definition
- Prove `closure_mcs_implies_locally_consistent` without sorry
- Add documentation explaining why temporal reflexivity is not included
- Verify no downstream breakage

**Non-Goals**:
- Changing TM logic's temporal semantics to reflexive
- Fixing the same sorry in old Metalogic (`FiniteCanonicalModel.lean`)
- Removing the `worldStateFromClosureMCS` machinery entirely

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Downstream code depends on temporal reflexivity | High | Low | Research confirms no usage; verify with `lake build` |
| Proof of conditions 1-3 is more complex than expected | Medium | Low | MCS properties are well-established; use lean_goal extensively |

## Implementation Phases

### Phase 1: Modify IsLocallyConsistent Definition [COMPLETED]

**Goal**: Remove temporal reflexivity conditions 4 and 5 from the definition

**Tasks**:
- [ ] Read current `IsLocallyConsistent` definition at `FiniteWorldState.lean:114-142`
- [ ] Remove condition 4 (temporal past reflexivity: `all_past(psi) -> psi`)
- [ ] Remove condition 5 (temporal future reflexivity: `all_future(psi) -> psi`)
- [ ] Update the docstring to explain why temporal reflexivity is NOT included
- [ ] Reference `Semantics/Truth.lean:109-110` in the documentation

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` - Remove conditions 4-5 from `IsLocallyConsistent`

**Verification**:
- Run `lake build` to check for immediate type errors
- Verify the definition now has only 3 conditions

---

### Phase 2: Prove closure_mcs_implies_locally_consistent [COMPLETED]

**Goal**: Replace the sorry with an actual proof

**Tasks**:
- [ ] Examine the theorem at `FiniteWorldState.lean:338-343`
- [ ] Prove condition 1 (bot is false): Use MCS set consistency property
- [ ] Prove condition 2 (implications respected): Use MCS modus ponens closure property
- [ ] Prove condition 3 (modal T axiom): Use TM axiom T and MCS provability inclusion
- [ ] Use `lean_goal` extensively to navigate proof state
- [ ] Remove the sorry statement

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` - Implement proof at lines 340-343

**Verification**:
- `lean_diagnostic_messages` shows no errors on the theorem
- `lean_goal` shows "no goals" at end of proof

---

### Phase 3: Verification and Cleanup [COMPLETED]

**Goal**: Ensure all downstream code still compiles and update documentation

**Tasks**:
- [ ] Run `lake build` to verify full project compiles
- [ ] Check `SemanticCanonicalModel.lean` still works (uses `worldStateFromClosureMCS`)
- [ ] Check `FiniteModelProperty.lean` still works (uses `worldStateFromClosureMCS`)
- [ ] Verify no new errors in `lean_diagnostic_messages` for affected files
- [ ] Update README.md if it tracks sorry count

**Timing**: 25 minutes

**Files to modify**:
- None expected (verification only)
- Potentially `README.md` if sorry count is documented

**Verification**:
- `lake build` succeeds with no errors
- All files that import `FiniteWorldState` compile successfully

---

## Testing & Validation

- [ ] `lake build` completes successfully
- [ ] `lean_diagnostic_messages` on `FiniteWorldState.lean` shows no errors
- [ ] `lean_diagnostic_messages` on `SemanticCanonicalModel.lean` shows no new errors
- [ ] `lean_diagnostic_messages` on `FiniteModelProperty.lean` shows no new errors
- [ ] The sorry at line 343 is replaced with a complete proof

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean`
- `specs/617_fix_closure_mcs_implies_locally_consistent/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
1. Revert changes to `FiniteWorldState.lean` using `git checkout`
2. Document specific failure reason in error log
3. Consider Option 4 (document as architectural limitation) from research as fallback
