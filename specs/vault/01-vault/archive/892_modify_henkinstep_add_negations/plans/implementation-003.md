# Implementation Plan: Task #892 (Version 003)

- **Task**: 892 - Modify henkinStep to add negations when rejecting packages
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours (reduced scope - strengthened hypothesis approach)
- **Dependencies**: None
- **Research Inputs**:
  - specs/892_modify_henkinstep_add_negations/reports/research-001.md
  - specs/892_modify_henkinstep_add_negations/reports/research-002.md
  - specs/892_modify_henkinstep_add_negations/summaries/implementation-summary-20260217.md (CRITICAL - obstruction analysis)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL REVISION v003**: The v002 implementation discovered that `maximal_tcs_is_mcs` is **mathematically FALSE** as stated. A set can be maximal in TCS without being an MCS when φ=F(ψ) and ψ∉M.

This plan pivots to **Option 2: Strengthen Hypotheses** - revise the theorem statement to require "witness closure" of the base set, making the theorem provably TRUE.

### Key Discovery from v002 Sessions

The obstruction:
```
When φ = F(ψ) and ψ ∉ M:
1. insert F(ψ) M might be consistent (no contradiction)
2. insert F(ψ) M fails temporal saturation (F(ψ) without ψ)
3. So insert F(ψ) M ∉ TCS but IS consistent
4. M is maximal in TCS but NOT an MCS
```

### Why Strengthened Hypothesis Works

If we require the **base set** to have "witness closure" - meaning:
- For every F(ψ) ∈ base closure, ψ ∈ base
- For every P(ψ) ∈ base closure, ψ ∈ base

Then the obstruction cannot occur:
1. If φ ∉ M, by maximality in TCS, either insert φ M is inconsistent OR not temporally saturated
2. If not temporally saturated: there exists F(ψ) or P(ψ) without its witness
3. But M ⊇ base and base has witness closure
4. So any new saturation violation must come from φ itself
5. If φ = F(ψ), the violation is that ψ ∉ insert φ M, meaning ψ ∉ M and ψ ≠ φ
6. With witness closure: if F(ψ) reachable from base, then ψ ∈ base ⊆ M
7. So ψ ∈ M, contradiction

### What Changed from v002

| Aspect | v002 | v003 |
|--------|------|------|
| Status | BLOCKED | UNBLOCKED - strengthened hypothesis |
| Theorem | `maximal_tcs_is_mcs` as-is (FALSE) | `maximal_tcs_is_mcs_closed` with witness closure (TRUE) |
| Phase 3 | Blocked by math obstruction | Prove with hypothesis |
| Risk | 0% (impossible) | High (90%) |

## Goals & Non-Goals

**Goals**:
- Keep henkinStep changes from v002 Phases 1-2 (PRESERVED)
- Create strengthened theorem `maximal_tcs_is_mcs_closed` with witness closure hypothesis
- Prove the strengthened theorem
- Verify downstream consumers can satisfy the new hypothesis

**Non-Goals**:
- Proving the original `maximal_tcs_is_mcs` (mathematically false)
- Using RecursiveSeed (parallel path in tasks 864/880)
- Adding new axioms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Downstream consumers can't satisfy witness closure | H | M | Check temporalLindenbaumMCS usage |
| Witness closure too strong for practical use | M | M | Consider weaker sufficient conditions |
| Proof still complex with hypothesis | L | L | v002 proved all cases except ψ ∉ M |

## Preserved Work from v002

### Phase 1: COMPLETED (v002)
- henkinStep modified with three-branch structure
- henkinStep_consistent updated
- henkinChain_mono updated

### Phase 2: COMPLETED (v002)
- Using temporalPackage(neg φ) for saturation
- henkinLimit_forward_saturated proven
- henkinLimit_backward_saturated proven

## Implementation Phases

### Phase 1: Define witness closure predicate [COMPLETED]

- **Dependencies:** None
- **Goal:** Create `WitnessClosedSet` predicate

**Tasks**:
- [x] Define `WitnessClosedSet (S : Set Formula)` predicate
- [x] Prove basic properties: `witnessClosedSet_empty`, `witnessClosedSet_implies_forward_saturated`, `witnessClosedSet_implies_backward_saturated`
- [x] Verify base sets in actual usage are witness-closed: `witnessClosedSet_temporalClosure`

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`

**Progress:**

**Session: 2026-02-17, sess_1771378714_714c1e**
- Added: `WitnessClosedSet` - predicate for witness closure
- Added: `witnessClosedSet_empty` - empty set is witness-closed
- Added: `witnessClosedSet_implies_forward_saturated` - implies forward saturation
- Added: `witnessClosedSet_implies_backward_saturated` - implies backward saturation
- Added: `witnessClosedSet_temporalClosure` - temporal closure is witness-closed

---

### Phase 2: Create strengthened theorem [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** State and prove `maximal_tcs_is_mcs_closed`

**Tasks**:
- [x] State theorem with WitnessClosedSet hypothesis (DONE)
- [x] Add helper lemmas: `witnessClosedSet_temporalPackage`, `witnessClosedSet_union`, `henkinStep_witnessClosedSet`, `henkinChain_witnessClosedSet`, `henkinLimit_witnessClosedSet` (DONE)
- [ ] Prove using existing v002 case structure plus hypothesis (BLOCKED)
- [ ] Key case: when φ = F(ψ) and ψ ∉ M (BLOCKED - same obstruction as v002)

**Timing**: 1 hour (actual: exceeded)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`

**Progress:**

**Session: 2026-02-17, sess_1771378714_714c1e**
- Added: `maximal_tcs_is_mcs_closed` statement with WitnessClosedSet hypothesis
- Added: `witnessClosedSet_temporalPackage` - temporalPackage is witness-closed
- Added: `witnessClosedSet_union` - union preserves witness closure
- Added: `henkinStep_witnessClosedSet` - henkinStep preserves witness closure
- Added: `henkinChain_witnessClosedSet` - chain preserves witness closure
- Added: `henkinLimit_witnessClosedSet` - henkinLimit preserves witness closure
- Discovered: WitnessClosedSet is equivalent to TemporalForwardSaturated ∧ TemporalBackwardSaturated
- Discovered: The witness closure on base does NOT help for arbitrary formulas φ not reachable from base
- Sorries: 4 -> 6 (2 new sorries in maximal_tcs_is_mcs_closed attempting same proof)
- Result: BLOCKED - same mathematical obstruction as v002

**Mathematical Analysis**:
The obstruction is the same as v002: when φ = F(ψ), φ ∉ M, neg(φ) ∉ M, and insert φ M is consistent:
1. We cannot show insert φ M ∈ TCS (fails forward saturation unless ψ ∈ M)
2. We cannot show insert φ M is inconsistent ({F(ψ), neg(ψ)} is semantically consistent)
3. The witness closure on base only helps for formulas reachable from base
4. For MCS, we need to handle ALL formulas, including those not reachable from base

The theorem `maximal_tcs_is_mcs` (and `maximal_tcs_is_mcs_closed`) appears to be mathematically FALSE as stated. A set can be maximal in TCS without being MCS.

---

### Phase 3: Update temporalLindenbaumMCS [BLOCKED]

- **Dependencies:** Phase 2
- **Goal:** Update main theorem to use strengthened lemma

**Tasks**:
- [ ] Analyze temporalLindenbaumMCS to understand base set construction
- [ ] Verify base set satisfies WitnessClosedSet (or can be made to)
- [ ] Update to use `maximal_tcs_is_mcs_closed`
- [ ] Remove sorries from maximal_tcs_is_mcs (mark as deprecated or delete)

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`

**Verification**:
- `temporalLindenbaumMCS` compiles without sorry
- `lake build` succeeds

---

### Phase 4: Final verification [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Clean build verification and parent task update

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Count sorries in TemporalLindenbaum.lean
- [ ] Check no new axioms introduced
- [ ] Update task 888 status if this unblocks it

**Timing**: 0.5 hours

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] Net sorry reduction (4 current → 0 target)
- [ ] No new axioms introduced
- [ ] `maximal_tcs_is_mcs_closed` compiles without sorry
- [ ] `temporalLindenbaumMCS` compiles without sorry

## Artifacts & Outputs

- New predicate: `WitnessClosedSet`
- New theorem: `maximal_tcs_is_mcs_closed`
- Updated: `temporalLindenbaumMCS`
- Deprecated/removed: `maximal_tcs_is_mcs` sorries

## Rollback/Contingency

If witness closure hypothesis too strong for downstream:
1. Consider RecursiveSeed path (tasks 864/880) as alternative
2. Consider weaker sufficient conditions (e.g., base is already an MCS)
3. Document obstruction and mark task as "resolved with limitation"

## Change History

| Version | Date | Change |
|---------|------|--------|
| 001 | 2026-02-17 | Initial plan - BLOCKED by counterexample |
| 002 | 2026-02-18 | UNBLOCKED by T-axiom → RE-BLOCKED by math obstruction |
| 003 | 2026-02-18 | Pivot to strengthened hypothesis approach |
