# Implementation Plan: Task #58 - Fix A1: BRS Mutual Exclusion (v14)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [PARTIAL]
- **Effort**: 6-8 hours
- **Dependencies**: None (using existing infrastructure)
- **Research Inputs**: reports/64_team-research.md
- **Previous Plan**: plans/13_seed-consistency-first.md (blocked by BRS flaw)
- **Artifacts**: plans/14_fix-a1-brs-mutual-exclusion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v13 identified `constrained_successor_seed_restricted_consistent` as the root sorry but was blocked because the `boundary_resolution_set` definition allows chi and chi.neg to coexist (documented at SuccChainFMCS.lean:1371-1409). Team research (report 64) confirms this is a genuine flaw and recommends **Fix A1**: adding a mutual exclusion condition `Formula.some_future chi.neg not in u` to the BRS definition. This plan implements Fix A1 and propagates it through to the Completeness.lean sorries.

### Research Integration

From report 64 (team research):
- **Blocker confirmed**: BRS allows chi AND chi.neg simultaneously (both F(chi) in u and F(neg chi) in u can hold)
- **Fix A1 recommended**: Add mutual exclusion condition to BRS definition
- **Option B ruled out**: Forward-only truth lemma for BFMCS_Bundle has unavoidable backward IH dependency
- **Option A only path**: Restricted construction with Fix A1 is the sole viable approach

## Goals & Non-Goals

**Goals**:
- Implement Fix A1 on `boundary_resolution_set` (add mutual exclusion)
- Propagate definition change through all dependent lemmas
- Prove `neg_not_in_boundary_resolution_set` (currently unprovable)
- Prove `constrained_successor_seed_restricted_consistent` (root sorry)
- Wire through to `dense_completeness_fc` and `bundle_validity_implies_provability`

**Non-Goals**:
- Fixing `discrete_completeness_fc` (separate blocker: `discrete_Icc_finite_axiom`)
- Pursuing Option B (ruled out by research)
- Modifying `restricted_tc_family_to_fmcs` (independent Lindenbaum gap)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix A1 breaks downstream lemmas | H | M | Careful audit of all BRS-dependent lemmas before changing definition |
| F-witness propagation fails with mutual exclusion | H | L | deferralDisjunction mechanism ensures chi or F(chi) in seed |
| Full consistency proof harder than neg-exclusion | M | M | Use proven pattern from predecessor seed (partition argument) |
| Restricted canonical model needs new infrastructure | M | L | Follow existing CanonicalTaskModel patterns |

---

## Implementation Phases

### Phase 1: Implement Fix A1 on boundary_resolution_set [COMPLETED]

**Goal**: Add mutual exclusion condition to BRS definition and update the membership lemma

**Tasks**:
- [ ] Read current `boundary_resolution_set` definition at SuccExistence.lean:284-286
- [ ] Add condition: `Formula.some_future chi.neg not in u`
- [ ] Update `mem_boundary_resolution_set_iff` at line 289-293
- [ ] Run `lake build Theories.Bimodal.Metalogic.Bundle.SuccExistence` to identify downstream breaks
- [ ] Document the fix rationale in comments (reference report 64)

**New definition**:
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.some_future chi.neg ∉ u}   -- NEW: mutual exclusion
```

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Definition compiles
- `mem_boundary_resolution_set_iff` updated and compiles

---

### Phase 2: Propagate Definition Change and Fix Dependent Lemmas [PARTIAL]

**Goal**: Update all lemmas in SuccExistence.lean and SuccChainFMCS.lean that depend on BRS membership

**Key lemmas to update**:
1. `boundary_resolution_set_subset_constrained_successor_seed_restricted` (SuccExistence.lean)
2. `mem_constrained_successor_seed_restricted_iff` (SuccExistence.lean)
3. `neg_not_in_boundary_resolution_set` (SuccChainFMCS.lean:1412) - now becomes trivial

**Tasks**:
- [ ] Run `lake build` to get complete list of errors
- [ ] Fix `boundary_resolution_set_subset_constrained_successor_seed_restricted` - may need extra assumption handling
- [ ] Fix `mem_constrained_successor_seed_restricted_iff` - add new condition
- [ ] Prove `neg_not_in_boundary_resolution_set` - now 3-line proof by contradiction
- [ ] Verify `boundary_resolution_set_subset_deferralClosure` still holds
- [ ] Run `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS`

**Expected proofs**:
For `neg_not_in_boundary_resolution_set`:
```lean
lemma neg_not_in_boundary_resolution_set (phi : Formula) (u : Set Formula)
    (chi : Formula) (h_mem : chi ∈ boundary_resolution_set phi u) :
    chi.neg ∉ boundary_resolution_set phi u := by
  intro h_neg_mem
  have := (mem_boundary_resolution_set_iff _ _ _).mp h_mem
  have := (mem_boundary_resolution_set_iff _ _ _).mp h_neg_mem
  -- h_mem has: F(chi.neg) ∉ u
  -- h_neg_mem has: F(chi.neg.neg) ∉ u, but also F(chi) ∈ u
  -- chi.neg.neg = chi, so F(chi) ∉ u contradicts F(chi) ∈ u
  simp [Formula.neg] at *
  -- Details depend on neg_neg behavior
  sorry -- Should become trivial after Fix A1
```

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` on both files succeeds
- `#print axioms neg_not_in_boundary_resolution_set` shows no sorryAx

---

### Phase 3: Prove Seed Consistency [NOT STARTED]

**Goal**: Eliminate the root sorry at SuccChainFMCS.lean:1543

**Target**: `constrained_successor_seed_restricted_consistent`

**Seed composition**:
```
constrained_successor_seed_restricted phi u =
  g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u) ∪ boundary_resolution_set(phi, u)
```

**Proof Strategy** (enabled by Fix A1):
1. The non-BRS part of the seed is a subset of u, hence consistent
2. BRS elements have mutual exclusion by Fix A1: no chi and chi.neg both in BRS
3. Suppose for contradiction: L subset of seed and L derives bot
4. Partition L into L_u (elements in u) and L_brs (BRS elements not in u)
5. For each chi in L_brs: F(chi) in u, so deferralDisjunction gives chi or F(chi) in u
6. Replace BRS elements with their deferralDisjunction representations
7. This produces a subset of u that derives bot, contradicting u's consistency

**Tasks**:
- [ ] Examine goal state at SuccChainFMCS.lean:1543 with `lean_goal`
- [ ] Implement partition argument (L_u / L_brs split)
- [ ] Prove single-BRS-element base case
- [ ] Prove multi-BRS-element case via deduction theorem iteration
- [ ] Also fix `augmented_seed_consistent` (line 1480) - reduces to above via absorption
- [ ] Verify: `lake build`, `#print axioms constrained_successor_seed_restricted_consistent`

**Timing**: 2-3 hours (this is the critical phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- Both sorries eliminated
- `#print axioms` shows no sorryAx for either theorem

---

### Phase 4: Wire to Completeness.lean Sorries [NOT STARTED]

**Goal**: Eliminate `dense_completeness_fc` (line 120) and complete `bundle_validity_implies_provability` (line 214)

**Approach**: Build TaskModel directly from RestrictedTemporallyCoherentFamily (bypassing the blocked `restricted_tc_family_to_fmcs` path)

**Mathematical structure**:
1. Consistent neg(phi) extends to DeferralRestrictedMCS
2. Build RestrictedTemporallyCoherentFamily from that DRM
3. Build RestrictedCanonicalTaskModel from RTCF
4. Use restricted_truth_lemma: phi in chain iff truth_at in model
5. neg(phi) true at position 0 means phi false there
6. Contrapositive: valid_over Int phi implies provable phi

**Tasks**:
- [ ] Define `RestrictedCanonicalTaskModel` (if not already present)
- [ ] Define `RestrictedOmega` (single history + time shifts)
- [ ] Prove `restrictedOmega_shift_closed`
- [ ] Prove `restricted_completeness_truth` using `restricted_truth_lemma`
- [ ] Wire `bundle_validity_implies_provability` using restricted construction
- [ ] Wire `dense_completeness_fc` via the same path
- [ ] Final: `#print axioms` for all target theorems
- [ ] `lake build` succeeds clean

**Note**: `discrete_completeness_fc` remains sorry - separate blocker not addressed by this plan.

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (or new file `RestrictedCanonicalModel.lean`)
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `bundle_validity_implies_provability` sorry-free
- `dense_completeness_fc` sorry-free
- `#print axioms` clean for both

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each modified/new theorem verified with `#print axioms` (no sorryAx)
- [ ] `boundary_resolution_set` definition has mutual exclusion condition
- [ ] `neg_not_in_boundary_resolution_set` is sorry-free
- [ ] `constrained_successor_seed_restricted_consistent` is sorry-free
- [ ] `augmented_seed_consistent` is sorry-free
- [ ] `bundle_validity_implies_provability` is sorry-free
- [ ] `dense_completeness_fc` is sorry-free
- [ ] `discrete_completeness_fc` remains sorry (documented, separate blocker)

## Artifacts & Outputs

- plans/14_fix-a1-brs-mutual-exclusion.md (this file)
- Modified: SuccExistence.lean (BRS definition)
- Modified: SuccChainFMCS.lean (seed consistency proofs)
- Modified/New: CanonicalConstruction.lean or RestrictedCanonicalModel.lean
- Modified: Completeness.lean (target sorries eliminated)

## Rollback/Contingency

If Fix A1 proves insufficient or breaks too many downstream lemmas:
1. Revert BRS definition change
2. Document the failure mode
3. Consider Fix A2 (stronger: both chi and chi.neg excluded when conflicting)
4. Escalate for deeper mathematical analysis

Note: Option B is ruled out per research - do not pivot there.

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| Forward-only truth lemma (BFMCS_Bundle) | imp case backward IH needs G/H family-level coherence | Report 64, Teammate B |
| Option B-Prime (new bundle G/H strategy) | Requires mathematical breakthrough | Report 64 |
| Bundle-level as truth lemma input | G backward needs same-family witness | Reports 45, 50 |
| Omega-enumeration for arbitrary MCS | Doesn't exist, never implemented | Report 60 |
| Fix A3 (add chi in u to BRS) | Defeats BRS purpose - makes it vacuous | Report 64, Teammate A |
| restricted_tc_family_to_fmcs | Independent Lindenbaum extensions break Succ | Report 61 |
