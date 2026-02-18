# Implementation Plan: Task #892 (Version 002)

- **Task**: 892 - Modify henkinStep to add negations when rejecting packages
- **Status**: [NOT STARTED]
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

### Phase 1: Modify henkinStep with negation fallback [NOT STARTED]

- **Dependencies:** None
- **Goal:** Update henkinStep to add `neg(phi)` when package is inconsistent, and prove supporting lemma

**Tasks**:
- [ ] Add `neg_consistent_when_pkg_inconsistent` lemma (around line 320):
  ```lean
  lemma neg_consistent_when_pkg_inconsistent (S : Set Formula) (phi : Formula)
      (hS : SetConsistent S)
      (h_pkg : ¬SetConsistent (S ∪ temporalPackage phi)) :
      SetConsistent (S ∪ {Formula.neg phi})
  ```
- [ ] Modify `henkinStep` definition at line 323:
  ```lean
  noncomputable def henkinStep (S : Set Formula) (phi : Formula) : Set Formula :=
    if SetConsistent (S ∪ temporalPackage phi) then
      S ∪ temporalPackage phi
    else
      S ∪ {Formula.neg phi}  -- NEW: add negation when rejecting
  ```
- [ ] Update `henkinStep_consistent` proof to handle new negation case
- [ ] Verify compilation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Lines 320-375

**Verification**:
- `henkinStep` compiles without error
- `henkinStep_consistent` compiles without sorry
- `lake build` passes for this file

---

### Phase 2: Verify saturation proofs [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Confirm downstream saturation proofs compile after henkinStep modification

**Tasks**:
- [ ] Check `henkinLimit_forward_saturated` compiles
- [ ] Check `henkinLimit_backward_saturated` compiles
- [ ] Fix any breakage (expected: none - negations don't affect temporal witness logic)
- [ ] Verify `henkinChain_consistent` still works

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Only if fixes needed

**Verification**:
- All saturation lemmas compile
- No new errors

---

### Phase 3: Prove maximal_tcs_is_mcs using T-axiom reasoning [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Remove sorries at lines 649 and 656 using the T-axiom insight

**Key Proof Strategy** (from research-002.md):

For `phi = F(psi)` case (line 649):
1. Case split: either `neg(F(psi)) ∈ M` or `neg(F(psi)) ∉ M`
2. If `neg(F(psi)) = G(neg(psi)) ∈ M`:
   - By T-axiom: `neg(psi) ∈ M`
   - If we try to add `F(psi)`, temporal saturation requires `psi ∈ insert F(psi) M`
   - But `psi ∉ M` (else both psi and neg(psi) in M → inconsistent)
   - And `psi ≠ F(psi)`, so `psi ∉ insert F(psi) M`
   - Therefore `insert F(psi) M ∉ TCS` (not temporally saturated)
   - This contradicts assumption that `insert phi M ∈ TCS`
3. If `neg(F(psi)) ∉ M`:
   - Modified henkinStep ensures either formula or its negation is in limit
   - Since `F(psi) ∉ M`, we must have `neg(F(psi)) ∈ M` → contradiction

Symmetric argument for backward case (line 656).

**Tasks**:
- [ ] Add helper lemma: `henkinLimit_negation_complete` - every enumerated formula or its negation is in limit
- [ ] Prove forward case (line 649) using strategy above
- [ ] Prove backward case (line 656) using symmetric argument
- [ ] Remove both sorries

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Lines 625-666

**Verification**:
- `maximal_tcs_is_mcs` compiles without sorry
- `temporalLindenbaumMCS` compiles

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
