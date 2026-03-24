# Implementation Plan: Task #48 - Prove succ_chain_fam bounded F-iteration depth (v13)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: None (all infrastructure exists)
- **Research Inputs**: reports/25_team-research.md
- **Artifacts**: plans/13_weaken-bounded-witness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses the two sorries in `SuccChainFMCS.lean` at lines 2360 and 3012. After 12 failed plan versions, team research (report #25) identified that the core blocker is that `closureWithNeg` is NOT closed under negation. When `FF(psi) in closureWithNeg \ subformulaClosure`, negation completeness cannot apply because `neg(FF(psi)) not in deferralClosure`.

The recommended approach (Combined B+D from research) weakens the theorem by adding an explicit hypothesis `h_all_in_dc : forall i <= d, iter_F i psi in deferralClosure phi`. This hypothesis is providable by callers because `restricted_forward_chain_F_bounded` gives a bound `d` where all intermediate F-iterations are in deferralClosure by definition.

### Research Integration

**Report 25 Key Findings**:
1. `closureWithNeg` has only ONE-LAYER negation - `g.neg` is included for `g in subformulaClosure`, but `neg(g.neg) = g.neg.neg` is NOT included
2. The boundary case IS reachable: when `phi = GG(neg(F(p)))`, `FF(p) in closureWithNeg \ subformulaClosure`, so `neg(FF(p)) not in deferralClosure`
3. 12 prior plans failed at the same core issue: negation completeness requires BOTH formula and its negation in deferralClosure
4. Working unrestricted `bounded_witness` (CanonicalTaskRelation.lean:651-680) uses full MCS negation completeness - no closure restriction

**Why This Approach Works**:
- Adding `h_all_in_dc` hypothesis guarantees all intermediate `iter_F i psi` are in `deferralClosure`
- For `FF(psi)` where `i+2 <= d`, `FF(psi) = iter_F (i+2) psi in deferralClosure` by hypothesis
- When `FF(psi) in deferralClosure`, negation completeness applies, and the existing proof structure works
- Callers use `restricted_forward_chain_F_bounded` which explicitly finds the boundary `d` - for all `i < d`, `iter_F i psi` is in deferralClosure by construction

## Goals & Non-Goals

**Goals**:
- Remove the two sorries in `SuccChainFMCS.lean` (lines 2360, 3012)
- Modify `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` to accept `h_all_in_dc` hypothesis
- Verify all callers can provide the new hypothesis
- Ensure `lake build` passes with no errors

**Non-Goals**:
- Do not attempt to prove the theorem without the hypothesis (proven impossible by 12 prior failures)
- Do not refactor the overall chain construction (out of scope)
- Do not modify the deferralClosure definition (would cascade everywhere)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Callers cannot provide hypothesis | High | Low | Analyze caller chain first (Phase 1) |
| Additional sorries appear downstream | Medium | Medium | Trace all usages in Phase 1 |
| `restricted_bounded_witness` needs changes | Medium | Medium | It already uses the theorems - changes propagate |
| Modal duality proof still needed | Medium | Low | Research shows `FF(psi) in dc => neg(FF) derivable` via proof system |

## Implementation Phases

### Phase 1: Caller Analysis and Hypothesis Design [COMPLETED]

**Goal**: Verify that callers can provide `h_all_in_dc` hypothesis and design the exact signature change.

**Tasks**:
- [ ] Trace call chain: `restricted_bounded_witness` <- `restricted_forward_chain_iter_F_witness` <- `restricted_forward_chain_F_coherence`
- [ ] Verify `restricted_forward_chain_F_bounded` provides bound `d` such that `iter_F d psi in chain` and `iter_F (d+1) psi not in chain`
- [ ] Confirm: for all `i <= d`, `iter_F i psi in deferralClosure` (by definition of the bound)
- [ ] Design the hypothesis: `h_iter_in_dc : forall i, i <= d -> iter_F i psi in deferralClosure phi`
- [ ] Document any edge cases at `d = 0` or `d = 1`

**Timing**: 30-45 minutes

**Files to examine**:
- `SuccChainFMCS.lean:2267-2275` - `restricted_forward_chain_F_bounded`
- `SuccChainFMCS.lean:3967-4031` - `restricted_bounded_witness`
- `SuccChainFMCS.lean:4056-4134` - `restricted_forward_chain_iter_F_witness`

**Verification**:
- Written analysis showing hypothesis flow from caller to callee
- No blocking edge cases identified

---

### Phase 2: Modify restricted_single_step_forcing [PARTIAL]

**Goal**: Add hypothesis and complete the proof for the `FF(psi) in deferralClosure` case.

**Tasks**:
- [ ] Add hypothesis `h_iter_in_dc` to `restricted_single_step_forcing` signature
- [ ] Use `h_iter_in_dc 2 (by omega)` to get `FF(psi) in deferralClosure`
- [ ] Apply DRM negation completeness: `FF(psi) in u or neg(FF(psi)) in u`
- [ ] Since `FF(psi) not in u` (given), we have `neg(FF(psi)) in u`
- [ ] Prove `neg(FF(psi)) -> GG(neg(psi))` using existing `neg_FF_implies_GG_neg_in_mcs` or proof-system derivation
- [ ] Complete the proof: `GG(neg(psi)) in u -> G(neg(psi)) in v -> F(psi) not in v -> psi in v`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 2324-2360)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` compiles
- Sorry at line 2360 is removed

---

### Phase 3: Modify restricted_succ_propagates_F_not [NOT STARTED]

**Goal**: Add hypothesis and complete the proof for the `FF(psi) in deferralClosure` case.

**Tasks**:
- [ ] Add hypothesis `h_iter_in_dc` to `restricted_succ_propagates_F_not` signature
- [ ] Mirror the proof structure from Phase 2 for the negation case
- [ ] Handle the boundary case at line 3026 (when `F(psi) in dc` but `FF(psi) not in dc`)
  - With `h_iter_in_dc`, this case becomes impossible: if `F(psi) = iter_F 1 psi in dc` by hypothesis for `i=1`, and `FF(psi) = iter_F 2 psi` should also be in dc for `i=2 <= d`
  - If `d < 2`, then `FF(psi)` never enters the chain anyway (boundary exceeded)

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 2990-3030)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` compiles
- Sorries at lines 3012 and 3026 are removed

---

### Phase 4: Propagate Hypothesis to restricted_bounded_witness [NOT STARTED]

**Goal**: Update `restricted_bounded_witness` to accept and propagate the hypothesis.

**Tasks**:
- [ ] Add `h_iter_in_dc` hypothesis to `restricted_bounded_witness` signature
- [ ] Pass the hypothesis to `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` calls
- [ ] Handle the inductive case: when recursing with `d-1`, the hypothesis still holds for `i <= d-1`
- [ ] Verify the base case `d = 0` or `d = 1` works correctly

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 3967-4031)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` compiles
- `restricted_bounded_witness` uses no sorries

---

### Phase 5: Update Caller Chain [NOT STARTED]

**Goal**: Ensure all callers of `restricted_bounded_witness` provide the new hypothesis.

**Tasks**:
- [ ] Update `restricted_forward_chain_iter_F_witness` to construct and pass `h_iter_in_dc`
  - This theorem calls `restricted_forward_chain_F_bounded` which provides the bound `d`
  - Construct the hypothesis: for `i <= d`, `iter_F i psi in deferralClosure` because:
    - `iter_F i psi in chain` for `i <= d` (by definition of F_bounded)
    - `chain subseteq deferralClosure` (by DRM property)
- [ ] Trace any other callers and update them
- [ ] Run full `lake build` to verify no regressions

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 4056-4134 and any other callers)

**Verification**:
- `lake build` passes with no errors
- All sorries in `SuccChainFMCS.lean` are resolved (or documented as unrelated)

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` passes
- [ ] `lake build` for full project passes
- [ ] `grep -n "sorry" SuccChainFMCS.lean` shows no sorries at lines 2360, 3012, 3026
- [ ] No new diagnostic errors introduced

## Artifacts & Outputs

- `plans/13_weaken-bounded-witness.md` (this plan)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` with sorries removed
- `summaries/14_weaken-bounded-witness-summary.md` (execution summary)

## Rollback/Contingency

**If hypothesis approach fails**:
1. Revert changes with `git checkout -- Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
2. Consider Fallback A (Filtration) from research - major refactor, 8-12 hours
3. Document specific blocker that caused failure for future reference

**If caller cannot provide hypothesis**:
1. Analyze what information the caller HAS
2. Potentially weaken the theorem statement further
3. Consider adding the hypothesis to the original theorem signature if caller chain can be modified

## Historical Context

This is plan version 13. Previous approaches and why they failed:
- v1-v3: Direct MCS boundedness (theorem FALSE for arbitrary MCS)
- v4: Restricted p_step_blocking (boundary case fails)
- v5: Fuel-based recursion (invariant cannot be maintained)
- v6: bounded_witness pattern (2 sorries for boundary)
- v7-v10: boundary_resolution_set variants (derivability blocker)
- v11: Lindenbaum Succ lifting (FATAL - Classical.choose independence)
- v12: DRM negation completeness (closureWithNeg not closed)

The key insight from v12's failure: we cannot get negation completeness for `FF(psi)` when it's outside deferralClosure. The solution is to add a hypothesis guaranteeing all relevant iterations ARE in deferralClosure.
