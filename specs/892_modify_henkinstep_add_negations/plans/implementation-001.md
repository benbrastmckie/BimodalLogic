# Implementation Plan: Task #892

- **Task**: 892 - Modify henkinStep to add negations when rejecting packages
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/892_modify_henkinstep_add_negations/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The current `henkinStep` function in `TemporalLindenbaum.lean` only adds temporal packages when consistent, but does NOT add the negation when rejecting. This leaves "gaps" where neither `phi` nor `neg(phi)` is in the resulting Henkin limit, preventing it from being a Maximal Consistent Set (MCS). The fix modifies `henkinStep` to add `neg(phi)` when `temporalPackage(phi)` would be inconsistent, ensuring negation completeness. This unblocks task 888 Phase 3 by making `maximal_tcs_is_mcs` provable.

### Research Integration

The research report (research-001.md) confirms:
1. Current henkinStep at line 323 returns S unchanged when rejecting packages
2. The fix requires adding `S ∪ {neg phi}` in the rejection case
3. A key supporting lemma `neg_consistent_when_pkg_inconsistent` must be proven first
4. The saturation proofs should remain valid since negations are not temporal witness formulas

## Goals & Non-Goals

**Goals**:
- Modify `henkinStep` to add `neg(phi)` when rejecting packages
- Prove `neg_consistent_when_pkg_inconsistent` supporting lemma
- Update `henkinStep_consistent` to handle the negation case
- Verify downstream saturation proofs still compile
- Remove sorries from `maximal_tcs_is_mcs` at lines 649 and 656

**Non-Goals**:
- Redesigning the overall Henkin construction approach
- Modifying the temporal package definition
- Adding new axioms (zero-axiom target)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `neg_consistent_when_pkg_inconsistent` proof is complex | H | M | Use deduction theorem pattern from standard Lindenbaum proofs |
| Saturation proofs break due to negation additions | H | L | Negations are not temporal witness formulas; verify explicitly |
| Chain consistency proof requires restructuring | M | M | Build on existing consistency transfer patterns |
| Type mismatch between set operations | L | M | Use proper Formula.neg syntax |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `maximal_tcs_is_mcs` at lines 649 and 656 (forward and backward saturation gaps)

### Expected Resolution
- Phase 4 resolves both sorries by proving that when phi = F(psi), either psi is already in M, or neg(F(psi)) is in M (from modified Henkin construction), making insert phi M temporally saturated or inconsistent

### New Sorries
- None expected. The modification directly addresses the root cause.

### Remaining Debt
After this implementation:
- 0 sorries expected in `maximal_tcs_is_mcs`
- Downstream theorems will no longer inherit sorry status
- Task 888 Phase 3 becomes unblocked

## Implementation Phases

### Phase 1: Prove neg_consistent_when_pkg_inconsistent [NOT STARTED]

- **Dependencies:** None
- **Goal:** Establish the key lemma that if S is consistent and S ∪ temporalPackage(phi) is inconsistent, then S ∪ {neg phi} is consistent

**Tasks**:
- [ ] Locate or import the deduction theorem for SetConsistent
- [ ] Prove lemma: if `SetConsistent S` and `not SetConsistent (S ∪ temporalPackage phi)`, then `SetConsistent (S ∪ {neg phi})`
- [ ] Add lemma before henkinStep definition (around line 320)
- [ ] Verify lemma compiles without errors

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Add lemma around line 320

**Verification**:
- Lemma compiles without sorry
- `lake build` passes

---

### Phase 2: Modify henkinStep and henkinStep_consistent [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update henkinStep to add negation when rejecting packages, and update henkinStep_consistent proof

**Tasks**:
- [ ] Modify `henkinStep` definition at line 323 to use `S ∪ {Formula.neg φ}` in else branch
- [ ] Update `henkinStep_consistent` proof (lines 370-375) to handle new negation case
- [ ] Use `neg_consistent_when_pkg_inconsistent` lemma in the negation case proof
- [ ] Verify both definitions compile

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Lines 323-324 (definition) and 370-375 (proof)

**Verification**:
- Modified `henkinStep` compiles
- `henkinStep_consistent` compiles without sorry
- `henkinChain_consistent` still compiles

---

### Phase 3: Verify saturation proofs [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Confirm downstream saturation proofs still compile after henkinStep modification

**Tasks**:
- [ ] Check `henkinLimit_forward_saturated` (lines 420-464) compiles
- [ ] Check `henkinLimit_backward_saturated` (lines 469-500) compiles
- [ ] Fix any breakage in saturation proofs (expected: none, since negations are not temporal witnesses)
- [ ] Run full `lake build` to verify no cascading errors

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Only if fixes needed

**Verification**:
- All saturation lemmas compile without sorry
- No new errors in file

---

### Phase 4: Update maximal_tcs_is_mcs proof [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Remove sorries from maximal_tcs_is_mcs by leveraging negation completeness from modified Henkin construction

**Tasks**:
- [ ] Add helper lemma: `henkinLimit_negation_complete` stating phi or neg(phi) is in limit
- [ ] Modify forward saturation case (line 649): use that if phi = F(psi) and phi not in M, then neg(phi) is in M, making insert phi M inconsistent
- [ ] Apply same pattern for backward case (line 656)
- [ ] Remove both sorries
- [ ] Verify proof compiles

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Lines 625-666

**Verification**:
- `maximal_tcs_is_mcs` compiles without sorry
- `temporalLindenbaumMCS` (main theorem) still compiles

---

### Phase 5: Final verification and cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Ensure clean build and verify task 888 Phase 3 is unblocked

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Verify sorry count decreased by 2 in TemporalLindenbaum.lean
- [ ] Check no new axioms were introduced
- [ ] Verify task 888 Phase 3 dependencies are satisfied

**Timing**: 0.5 hours

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds with no errors
- `grep -c sorry Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` shows reduction
- `grep -c axiom Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` shows 0

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] No new sorries introduced
- [ ] No new axioms introduced
- [ ] `maximal_tcs_is_mcs` compiles without sorry
- [ ] `temporalLindenbaumMCS` compiles without sorry
- [ ] Task 888 Phase 3 is unblocked

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
- New lemmas: `neg_consistent_when_pkg_inconsistent`, `henkinLimit_negation_complete`
- Modified lemmas: `henkinStep`, `henkinStep_consistent`
- Completed proof: `maximal_tcs_is_mcs`

## Rollback/Contingency

If implementation fails:
1. Revert henkinStep to original form (returns S unchanged on rejection)
2. Keep sorries in maximal_tcs_is_mcs
3. Document blocking issues in research report
4. Consider alternative approach: post-processing Henkin limit with standard set_lindenbaum (may lose temporal saturation)
