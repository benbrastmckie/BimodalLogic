# Implementation Plan: Task #892 (Version 002)

- **Task**: 892 - Modify henkinStep to add negations when rejecting packages
- **Status**: [PARTIAL]
- **Effort**: 3 hours (reduced from 4 - simpler approach)
- **Dependencies**: None
- **Research Inputs**:
  - specs/892_modify_henkinstep_add_negations/reports/research-001.md
  - specs/892_modify_henkinstep_add_negations/reports/research-002.md (CRITICAL - invalidates v001 blocker)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL REVISION**: The v001 plan was marked BLOCKED based on a counterexample claiming `{neg(psi), G(psi)}` is consistent. Team research (research-002.md) proved this counterexample is **INVALID** due to the `temp_t_future` axiom (`G(psi) -> psi`). With reflexive semantics, `G(psi)` implies `psi`, which contradicts `neg(psi)`.

This plan proceeds with the original goal: modify `henkinStep` to add negations when rejecting packages, making `maximal_tcs_is_mcs` provable.

### Key Insight from Team Research

The T-axiom (`temp_t_future`: `G(phi) -> phi`) provides the critical link:
1. If `G(neg(psi)) ∈ M`, then by T-axiom, `neg(psi) ∈ M`
2. This means `psi ∉ M` (by consistency)
3. When considering `F(psi)` membership: if `F(psi) ∉ M` but `insert F(psi) M` is consistent, we need temporal saturation
4. If `neg(psi) ∈ M`, then `insert (F(psi)) M` violates temporal saturation (F(psi) present without psi)
5. This creates the contradiction needed for the MCS maximality argument

### What Changed from v001

| Aspect | v001 | v002 |
|--------|------|------|
| Status | BLOCKED | UNBLOCKED |
| Counterexample | Assumed valid | **INVALID** - T-axiom proof |
| Phase 1 | Prove neg_consistent_when_pkg_inconsistent (blocked) | Same goal, now unblocked |
| Phase 4 | Proof strategy unclear | Clear strategy using T-axiom |
| Confidence | Low (0%) | High (85%) |

## Goals & Non-Goals

**Goals**:
- Modify `henkinStep` to add `neg(phi)` when rejecting packages
- Prove `neg_consistent_when_pkg_inconsistent` supporting lemma
- Update `henkinStep_consistent` to handle the negation case
- Remove sorries from `maximal_tcs_is_mcs` at lines 649 and 656
- Use T-axiom reasoning in the maximality proof

**Non-Goals**:
- Redesigning the overall Henkin construction approach
- Adding new axioms (zero-axiom target)
- Using RecursiveSeed alternative (fallback only if this fails)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `neg_consistent_when_pkg_inconsistent` proof complex | H | M | Use deduction theorem; counterexample invalidation gives confidence |
| T-axiom reasoning doesn't close maximality gaps | M | L | Fallback to RecursiveSeed (task 864/880) |
| Other blocking scenarios exist (not just counterexample) | M | L | Research-002 cataloged alternatives |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `maximal_tcs_is_mcs` at lines 649 and 656

### Expected Resolution
- Phase 3 resolves both sorries using T-axiom reasoning:
  - For `phi = F(psi)`: if `F(psi) ∉ M`, show `insert F(psi) M` is either inconsistent OR not temporally saturated
  - T-axiom chain: `G(neg(psi)) ∈ M` → `neg(psi) ∈ M` → `psi ∉ M` → `insert F(psi) M` not saturated

### Remaining Debt
After this implementation:
- 0 sorries expected in `maximal_tcs_is_mcs`
- Task 888 Phase 3 becomes unblocked
- Cascading unblock potential: 888 → 881

## Implementation Phases

### Phase 1: Modify henkinStep with negation fallback [COMPLETED]

- **Dependencies:** None
- **Goal:** Update henkinStep to add `neg(phi)` when package is inconsistent, and prove supporting lemma

**Tasks**:
- [x] Modify `henkinStep` definition to add negation fallback (with additional else for consistency preservation)
- [x] Update `henkinStep_consistent` proof to handle nested if-then-else
- [x] Update `henkinChain_mono` proof for new branch structure
- [x] Verify compilation

**Note**: The `neg_consistent_when_pkg_inconsistent` lemma was NOT added because it's not provable in general. Instead, henkinStep now has three branches: add package, add negation (if consistent), or keep S unchanged.

**Progress:**

**Session: 2026-02-17, sess_1771376322_b2285b**
- Added: Modified `henkinStep` with three-branch structure
- Fixed: `henkinStep_consistent` for nested if
- Fixed: `henkinChain_mono` for new branch

---

### Phase 2: Verify saturation proofs [PARTIAL]

- **Dependencies:** Phase 1
- **Goal:** Confirm downstream saturation proofs compile after henkinStep modification

**Tasks**:
- [x] Check `henkinLimit_forward_saturated` compiles - COMPILES WITH SORRY
- [x] Check `henkinLimit_backward_saturated` compiles - COMPILES WITH SORRY
- [ ] Fix breakage - **UNEXPECTED**: negations DO affect temporal witness logic!

**ISSUE DISCOVERED**: When `neg(φ) = F(ψ)` (i.e., φ = G(neg(ψ))), adding neg(φ) adds a temporal formula without its witness ψ. This breaks forward/backward saturation.

New sorries introduced:
- Line 494: `henkinLimit_forward_saturated` - F(ψ) = neg(φ) case
- Line 542: `henkinLimit_backward_saturated` - P(ψ) = neg(φ) case

**Progress:**

**Session: 2026-02-17, sess_1771376322_b2285b**
- Attempted: Proving saturation for negation addition case
- Result: Blocked - negation can introduce temporal formulas without witnesses
- Sorries: 2 new sorries added (lines 494, 542)
- [ ] Verify `henkinChain_consistent` still works

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Only if fixes needed

**Verification**:
- All saturation lemmas compile
- No new errors

---

### Phase 3: Prove maximal_tcs_is_mcs using T-axiom reasoning [PARTIAL]

- **Dependencies:** Phase 2
- **Goal:** Remove sorries at lines 649 and 656 using the T-axiom insight

**Implementation Approach** (revised from plan):

Restructured proof to use case split on `neg(φ) ∈ M`:
- **Case 1 (neg(φ) ∈ M)**: COMPLETED - Direct contradiction via `set_consistent_not_both`
- **Case 2 (neg(φ) ∉ M)**: PARTIAL - Need to show temporal saturation of insert φ M

**Key Progress**:
- [x] Implemented case split on `neg(φ) ∈ M`
- [x] Proved Case 1 using `set_consistent_not_both`
- [x] Proved structural impossibility cases (ψ = F(ψ) and ψ = P(ψ)) using complexity argument
- [ ] Case 2 forward: ψ ∉ M and ψ ≠ φ case (line 709 sorry)
- [ ] Case 2 backward: symmetric case (line 727 sorry)

**ISSUE**: The plan's strategy assumed `henkinLimit_negation_complete` would give us neg(φ) ∈ M whenever φ ∉ M. But:
1. Phase 2 showed henkinLimit may NOT be temporally saturated after modification
2. Without temporal saturation, we can't start Zorn from henkinLimit
3. Without Zorn from henkinLimit, M may not have negation completeness

**Progress:**

**Session: 2026-02-17, sess_1771376322_b2285b**
- Added: Case split proof structure for maximal_tcs_is_mcs
- Completed: Case 1 (neg(φ) ∈ M) via set_consistent_not_both
- Completed: Structural impossibility proofs using complexity
- Sorries: 2 remaining (lines 709, 727) for Case 2 saturation proofs

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`

**Verification**:
- File compiles with 4 total sorries
- Original sorries at lines 649/656 replaced with new structure

---

### Phase 4: Final verification and parent task unblock [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Clean build verification and unblock task 888

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Verify sorry count decreased in TemporalLindenbaum.lean
- [ ] Check no new axioms introduced
- [ ] Verify task 888 Phase 3 dependencies now satisfied
- [ ] Update task 888 status if fully unblocked

**Timing**: 0.5 hours (reduced from v001 - less verification needed)

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds
- `grep -c sorry TemporalLindenbaum.lean` shows reduction
- Task 888 Phase 3 can proceed

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
- Modified definition: `henkinStep`
- Modified proof: `henkinStep_consistent`
- Completed proof: `maximal_tcs_is_mcs`

## Rollback/Contingency

If T-axiom approach fails despite counterexample invalidation:
1. Document the new blocking issue
2. Escalate to RecursiveSeed path (task 864/880)
3. RecursiveSeed pre-places witnesses, avoiding TCS/MCS tension entirely
4. ZornFamily (task 870) provides family-level infrastructure as fallback

## Change History

| Version | Date | Change |
|---------|------|--------|
| 001 | 2026-02-17 | Initial plan - BLOCKED by counterexample |
| 002 | 2026-02-18 | **UNBLOCKED** - Team research proved counterexample INVALID (T-axiom) |
