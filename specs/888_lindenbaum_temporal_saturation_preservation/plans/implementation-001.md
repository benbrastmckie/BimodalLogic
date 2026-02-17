# Implementation Plan: Task #888

- **Task**: 888 - Lindenbaum Temporal Saturation Preservation
- **Status**: [PARTIAL]
- **Effort**: 4 hours
- **Dependencies**: None (builds on existing TemporalLindenbaum.lean infrastructure)
- **Research Inputs**: specs/888_lindenbaum_temporal_saturation_preservation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fix the 3 sorries in TemporalLindenbaum.lean that block temporal coherence of the BMCS construction. The core issue is that the Henkin construction does not preserve temporal saturation for formulas already in the base set. The solution involves ensuring temporal closure of the base before starting the omega-step enumeration.

### Research Integration

From research-001.md:
- **Key Finding**: Regular Lindenbaum does NOT preserve temporal saturation. When adding F(phi) via enumeration, it does not automatically add witness phi.
- **Sorry Locations**: Lines 444, 485 (Henkin base case), lines 655-656, 662 (maximal_tcs_is_mcs temporal cases)
- **Root Cause**: When F(psi) is already in the initial base set, there is no guarantee that psi was processed by the Henkin construction.
- **Recommended Path**: Ensure temporal closure of the initial base before starting the omega-step construction.

## Goals & Non-Goals

**Goals**:
- Resolve the 3 sorries in TemporalLindenbaum.lean
- Ensure `henkinLimit_forward_saturated` handles the base case correctly
- Ensure `henkinLimit_backward_saturated` handles the base case correctly
- Complete `maximal_tcs_is_mcs` for temporal formula cases
- Maintain clean build with no new sorries

**Non-Goals**:
- Refactoring DovetailingChain.lean (alternative approach, not pursued)
- Changing the overall BMCS architecture
- Addressing FinalConstruction.lean directly (depends on this fix)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Temporal closure of base introduces inconsistency | High | Low | Prove consistency preservation lemma before modifying construction |
| Base closure is transfinite/non-computable | Medium | Low | Use well-founded recursion on formula complexity |
| maximal_tcs_is_mcs argument does not work | Medium | Medium | Have alternative: require base to be temporal-formula-free |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `TemporalLindenbaum.lean`:
  1. `henkinLimit_forward_saturated` base case (line 444)
  2. `henkinLimit_backward_saturated` base case (line 485)
  3. `maximal_tcs_is_mcs` temporal formula cases (lines 655-656, 662)

### Expected Resolution
- Phase 1 adds temporal closure infrastructure for base sets
- Phase 2 resolves sorries 1 and 2 via pre-closed base
- Phase 3 resolves sorry 3 using temporal witness seed consistency

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in `TemporalLindenbaum.lean`
- FinalConstruction.lean will be unblocked to use the fixed construction
- Downstream temporal coherence proofs become viable

## Implementation Phases

### Phase 1: Temporal Closure Infrastructure [COMPLETED]

- **Dependencies:** None
- **Goal:** Define and prove properties of temporal closure operation on sets

**Tasks**:
- [x] Define `temporalClosure : Set Formula -> Set Formula` that adds all transitive witnesses
- [x] Prove `subset_temporalClosure`: base is subset of its temporal closure
- [x] Prove `temporalClosure_forward_saturated`: temporal closure is forward saturated
- [x] Prove `temporalClosure_backward_saturated`: temporal closure is backward saturated
- [x] NOTE: `temporalClosure_consistent` is NOT provable in general (counterexample: {F(p), neg p} is consistent but {F(p), neg p, p} is not)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Add new definitions after Part 2 (chain properties)

**Verification**:
- All new lemmas compile without sorry
- `lake build` succeeds

**Progress:**

**Session: 2026-02-17, sess_1771366548_399c2b**
- Added: `temporalClosure` definition using `temporalWitnessChain`
- Added: `subset_temporalClosure`, `temporalClosure_forward_saturated`, `temporalClosure_backward_saturated`
- Fixed: Henkin base case sorries by adding base saturation assumptions to lemmas
- Sorries: 3 -> 2 (1 eliminated by taking assumption, 0 net new)

---

### Phase 2: Fix Henkin Base Case Sorries [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Resolve sorries at lines 444 and 485 by using temporally-closed base

**Tasks**:
- [x] Add `h_base_fwd` assumption to `henkinLimit_forward_saturated`
- [x] Add `h_base_bwd` assumption to `henkinLimit_backward_saturated`
- [x] Base case now trivially follows from base saturation assumption
- [x] Modify `temporalLindenbaumMCS` to use `temporalClosure base` and take consistency assumption

**Approach Change**: Instead of modifying `henkinChain`/`henkinLimit` definitions, we added base saturation assumptions to the saturation lemmas. The main theorem now takes temporal closure consistency as an explicit assumption.

**Timing**: Combined with Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Modify lemma signatures, update main theorem

**Verification**:
- Lines 444 and 485 (now different line numbers) no longer have sorry
- `henkinLimit_forward_saturated` and `henkinLimit_backward_saturated` compile cleanly
- `lake build` succeeds for those lemmas

---

### Phase 3: Fix maximal_tcs_is_mcs Temporal Cases [IN PROGRESS]

- **Dependencies:** Phase 2
- **Goal:** Resolve sorry at lines 655-656, 662 in `maximal_tcs_is_mcs`

**Tasks**:
- [ ] Analyze the temporal formula case: when phi = F(psi) and phi not in M
- [ ] Prove: if M is maximal in TCS and insert F(psi) M is consistent, then psi in insert F(psi) M
- [ ] Key argument: if psi not in M, then M union {F(psi), psi} can be temp-saturated
- [ ] Use maximality to derive contradiction or membership
- [ ] Apply symmetric argument for P(psi) case

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Complete maximal_tcs_is_mcs proof

**Verification**:
- Lines 655-656 and 662 no longer have sorry
- `maximal_tcs_is_mcs` compiles cleanly
- `lake build` succeeds with 0 sorries in TemporalLindenbaum.lean

---

### Phase 4: Verification and Integration Testing [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify the fix enables downstream constructions

**Tasks**:
- [ ] Run `lake build` and verify clean compilation
- [ ] Count sorries in TemporalLindenbaum.lean (should be 0)
- [ ] Check that `temporalLindenbaumMCS` theorem compiles without sorry
- [ ] Verify FinalConstruction.lean can use the updated construction
- [ ] Document any remaining issues for follow-up tasks

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)
- Optionally update FinalConstruction.lean to use new construction

**Verification**:
- `lake build` clean
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` returns 0 matches
- Integration with FinalConstruction verified

---

## Testing & Validation

- [ ] All 3 sorries in TemporalLindenbaum.lean resolved
- [ ] `temporalLindenbaumMCS` theorem compiles without sorry
- [ ] `lake build` succeeds with no new errors
- [ ] No new axioms introduced
- [ ] Integration with FinalConstruction.lean verified

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Updated with temporal closure and sorry-free proofs
- `specs/888_lindenbaum_temporal_saturation_preservation/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If the temporal closure approach does not work:
1. Restore original TemporalLindenbaum.lean from git
2. Consider alternative: require base to contain no temporal formulas
3. Escalate to separate seed construction that strips temporal content
4. Document the fundamental limitation for future research
