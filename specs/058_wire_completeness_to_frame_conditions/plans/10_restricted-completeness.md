# Implementation Plan: Task #58 - Restricted Completeness (v10)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (sorry-free infrastructure exists)
- **Research Inputs**: reports/50_team-research.md
- **Artifacts**: plans/10_restricted-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements completeness via the **restricted completeness path** identified by team research (report 50). The key findings that shape this approach:

1. **Option 3 (algebraic bypass) is NOT viable** - proves `(forall MCS M, phi in M) -> prov phi`, not `valid_over Int phi -> prov phi`
2. **Option 1 (family-level temporal coherence) is BLOCKED for arbitrary MCS** - `f_nesting_is_bounded` is mathematically FALSE (counterexample: {F^n(p) | n in N})
3. **Restricted completeness via RestrictedMCS IS viable** - F-nesting within `closureWithNeg(phi)` IS bounded by `iter_F_not_mem_closureWithNeg`

The approach: For any unprovable formula phi, build a countermodel restricted to `closureWithNeg(phi)` where F-nesting is bounded, family-level temporal coherence is achievable, and the bidirectional truth lemma can be proven.

### Research Integration

Key findings from report 50 integrated:
- Truth lemma IS inherently bidirectional (imp case uses `.mpr` at ParametricTruthLemma.lean:208)
- `G(phi) -> Box(G(phi))` is NOT derivable - blocks bundle-to-family upgrade
- `iter_F_not_mem_closureWithNeg` proves F-nesting bounded within closure (SORRY-FREE)
- `restricted_mcs_F_bounded` provides the key lemma for bounded F-nesting in RestrictedMCS (SORRY-FREE)
- Fair-scheduling chain is a HIGH complexity fallback; restricted completeness is simpler

## Goals & Non-Goals

**Goals**:
- Eliminate the 3 target sorries: `dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int`
- Prove restricted family-level temporal coherence using bounded F-nesting
- Prove restricted bidirectional truth lemma
- Wire restricted completeness to `valid_over Int` via lifting argument

**Non-Goals**:
- Proving family-level temporal coherence for arbitrary MCS (mathematically impossible)
- Proving `f_nesting_is_bounded` for arbitrary MCS (counterexample exists)
- Implementing fair-scheduling chain (higher complexity, deferred)
- Bypassing the truth lemma via algebraic path (proves wrong theorem)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted-to-full lifting fails | H | L | Countermodel over restricted closure IS a valid TaskModel; lifting should follow |
| Restricted temporal coherence harder than expected | M | M | Existing `restricted_mcs_F_bounded` provides key lemma; SuccChain pattern applies |
| Box-class preservation in restricted context | M | L | Use `closureWithNeg_closed_under_subformulas`; Box subformulas stay in closure |
| Hidden dependency in truth lemma wiring | M | L | Trace `h_tc` requirements carefully through parametric lemma |

## Implementation Phases

### Phase 1: Restricted Family-Level Temporal Coherence [NOT STARTED]

**Goal**: Prove `RestrictedTemporallyCoherentFamily` for families built from RestrictedMCS.

**Mathematical Content**:
The key insight is that within `closureWithNeg(phi)`:
- F-nesting IS bounded: `restricted_mcs_F_bounded` proves that for any `F(psi) in M`, there exists `d >= 1` such that `iter_F d psi in M` and `iter_F (d+1) psi notin M`
- This bounds the SuccChain construction: each F-obligation resolves within finite steps
- The SuccChain approach that failed for arbitrary MCS (unbounded F-nesting) SUCCEEDS for RestrictedMCS

**Definitions needed**:
```lean
structure RestrictedTemporallyCoherentFamily (phi : Formula) where
  fam : FMCS Int
  restricted : forall t, ClosureRestricted phi (fam.mcs t)
  forward_F : forall psi t, Formula.some_future psi in fam.mcs t ->
              exists s > t, psi in fam.mcs s
  backward_P : forall psi t, Formula.some_past psi in fam.mcs t ->
               exists s < t, psi in fam.mcs s
```

**Tasks**:
- [ ] Define `RestrictedTemporallyCoherentFamily phi` structure
- [ ] Prove `restricted_succ_chain_forward_F`: SuccChain from RestrictedMCS resolves F-obligations within closure
- [ ] Prove `restricted_succ_chain_backward_P`: Symmetric argument for P-obligations
- [ ] Prove `build_restricted_tc_family`: Construct `RestrictedTemporallyCoherentFamily` from RestrictedMCS seed

**Timing**: 3.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Add restricted family structure
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add restricted SuccChain construction

**Verification**:
- `lake build`
- `#print axioms build_restricted_tc_family` shows no `sorryAx`

---

### Phase 2: Restricted Bidirectional Truth Lemma [NOT STARTED]

**Goal**: Prove bidirectional truth lemma for RestrictedTemporallyCoherentFamily.

**Mathematical Content**:
The parametric truth lemma (`parametric_shifted_truth_lemma`) requires hypothesis `h_tc : B.temporally_coherent` which provides:
- `forward_F`: F(psi) in fam.mcs t -> exists s > t with psi in fam.mcs s (SAME family)
- `backward_P`: P(psi) in fam.mcs t -> exists s < t with psi in fam.mcs s (SAME family)

For RestrictedMCS, this works because:
1. F-nesting is bounded within closure (Phase 1)
2. SuccChain resolves F-obligations within closure bounds
3. The witnesses remain in the SAME family (not just same bundle)

The imp backward case (line 208) uses `.mpr` on IH - this is OK because restricted families have same-family F-witnesses.

**Tasks**:
- [ ] Define `restricted_parametric_truth_lemma` using `RestrictedTemporallyCoherentFamily`
- [ ] Prove forward direction: `phi in fam.mcs t -> truth_at phi`
- [ ] Prove backward direction: `truth_at phi -> phi in fam.mcs t`
- [ ] Verify imp case: Show `.mpr` IH usage works with restricted family witnesses

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Add restricted version
- Or create `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

**Verification**:
- `lake build`
- `#print axioms restricted_parametric_truth_lemma` shows no `sorryAx`

---

### Phase 3: Lifting Restricted Completeness to Full Completeness [NOT STARTED]

**Goal**: Show that restricted completeness implies completeness over Int.

**Mathematical Content**:
The key argument:
1. If phi is not provable, then neg(phi) is consistent
2. Extend neg(phi) to RestrictedMCS M within `closureWithNeg(phi)` (existing: `restricted_mcs_from_formula`)
3. Build RestrictedTemporallyCoherentFamily from M (Phase 1)
4. neg(phi) in eval_family.mcs(0) (by construction, phi is in closureWithNeg(phi))
5. By restricted truth lemma (Phase 2): neg(phi) is true at the model
6. The restricted model IS a valid TaskModel over Int:
   - Temporal domain: Int (unchanged)
   - States: restricted MCS's are still MCS's (just smaller)
   - Task structure: preserved
7. Therefore phi is false at a valid TaskModel over Int
8. Contrapositive: valid_over Int phi -> prov phi

**Lifting verification**:
The restricted canonical model is a valid TaskModel because:
- `RestrictedMCS phi M` is an MCS (just with domain restriction)
- The temporal structure (Int) is preserved
- F/P semantics are unchanged (witnesses exist in same family)

**Tasks**:
- [ ] Prove `restricted_canonical_is_task_model`: RestrictedTemporallyCoherentFamily induces valid TaskModel
- [ ] Prove `restricted_countermodel`: If neg(phi) consistent, there exists TaskModel over Int where phi is false
- [ ] Prove `restricted_completeness_implies_full`: restricted_countermodel + contrapositive

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - Add lifting lemmas
- Or create `Theories/Bimodal/Metalogic/Algebraic/RestrictedCompleteness.lean`

**Verification**:
- `lake build`
- `#print axioms restricted_completeness_implies_full` shows no `sorryAx`

---

### Phase 4: Eliminate Target Sorries [NOT STARTED]

**Goal**: Wire restricted completeness to eliminate the 3 target sorries in FrameConditions/Completeness.lean.

**Mathematical Content**:
The target sorries are:
1. `bundle_validity_implies_provability` (line 186-214): Core completeness lemma
2. `dense_completeness_fc` (line 115-120): Dense frames completeness
3. `discrete_completeness_fc` (line 158-163): Discrete frames completeness

The wiring:
- `bundle_validity_implies_provability`: Replace with `restricted_completeness_implies_full` from Phase 3
- `dense_completeness_fc`: Any formula valid over ALL dense frames is valid over Int; reduce to `completeness_over_Int`
- `discrete_completeness_fc`: Any formula valid over ALL discrete frames is valid over Int; reduce to `completeness_over_Int`

**Tasks**:
- [ ] Replace sorry in `bundle_validity_implies_provability` with `restricted_completeness_implies_full`
- [ ] Prove `dense_implies_int`: valid over all dense frames -> valid over Int
- [ ] Wire `dense_completeness_fc` via `dense_implies_int + completeness_over_Int`
- [ ] Prove `discrete_implies_int`: valid over all discrete frames -> valid over Int
- [ ] Wire `discrete_completeness_fc` via `discrete_implies_int + completeness_over_Int`
- [ ] Final verification: `#print axioms` on all three theorems

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness`
- `#print axioms dense_completeness_fc` shows no `sorryAx`
- `#print axioms discrete_completeness_fc` shows no `sorryAx`
- `#print axioms completeness_over_Int` shows no `sorryAx`

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each new theorem verified with `#print axioms` (no sorryAx)
- [ ] Final verification: all 3 target sorries eliminated
- [ ] Regression test: existing sorry-free theorems remain sorry-free

## Artifacts & Outputs

- `plans/10_restricted-completeness.md` (this file)
- Modified/created Lean files:
  - `RestrictedMCS.lean` - RestrictedTemporallyCoherentFamily
  - `SuccChainFMCS.lean` - Restricted SuccChain construction
  - `ParametricTruthLemma.lean` or `RestrictedTruthLemma.lean` - Restricted truth lemma
  - `ParametricRepresentation.lean` or `RestrictedCompleteness.lean` - Lifting lemmas
  - `FrameConditions/Completeness.lean` - Sorry elimination
- `summaries/11_restricted-completeness-summary.md` (after completion)

## Rollback/Contingency

If Phase 1 (restricted temporal coherence) proves harder than expected:
1. Verify `restricted_mcs_F_bounded` provides the exact property needed
2. Check if SuccChain can be directly parameterized by closure bounds
3. Document specific obstruction for future investigation

If Phase 2 (restricted truth lemma) has hidden dependencies:
1. Trace the exact `h_tc` usage in parametric truth lemma
2. Identify what properties of `RestrictedTemporallyCoherentFamily` are insufficient
3. Consider stronger restricted family structure if needed

If Phase 3 (lifting) fails:
1. Verify that restricted canonical model satisfies TaskModel axioms
2. Check if semantic `valid_over` requires full MCS (not restricted)
3. Document whether restricted completeness is a weaker but still valuable result

## Mathematical Summary

**The Restricted Completeness Framework**:
```
1. phi not provable -> neg(phi) consistent
2. Extend to RestrictedMCS M within closureWithNeg(phi) [EXISTING: restricted_mcs_from_formula]
3. F-nesting bounded: restricted_mcs_F_bounded [EXISTING, SORRY-FREE]
4. Build RestrictedTemporallyCoherentFamily:
   - SuccChain from M with bounded iterations
   - forward_F/backward_P provable (F-nesting finite!)
5. Restricted bidirectional truth lemma:
   - Forward: phi in fam.mcs t -> truth_at phi
   - Backward: truth_at phi -> phi in fam.mcs t (including imp case!)
6. neg(phi) in eval_family.mcs(0) -> neg(phi) true at model
7. Restricted canonical model IS valid TaskModel over Int
8. phi false at valid TaskModel over Int
9. Contrapositive: valid_over Int phi -> prov phi
```

**Why This Works When Bundle Approach Failed**:
- Bundle approach: F-witnesses can be in ANY family (bundle-level coherence)
- Problem: Truth lemma imp backward needs SAME-family witnesses
- Bundle-to-family upgrade needs `G(phi) -> Box(G(phi))` which is NOT derivable
- Restricted approach: F-witnesses are in SAME family because:
  - F-nesting is bounded within closureWithNeg
  - SuccChain terminates within family
  - No cross-family transfer needed

**Key Existing Infrastructure** (all SORRY-FREE):
- `restricted_mcs_from_formula`: Build RestrictedMCS from consistent formula
- `restricted_mcs_F_bounded`: F-nesting bounded in RestrictedMCS
- `iter_F_not_mem_closureWithNeg`: F-iterations leave closure at bounded depth
- `not_provable_implies_neg_consistent`: Contrapositive setup
- `parametric_shifted_truth_lemma`: Truth lemma (given h_tc)

**What This Plan Adds**:
- `RestrictedTemporallyCoherentFamily`: Family structure with bounded F-nesting
- `build_restricted_tc_family`: Constructor from RestrictedMCS
- `restricted_parametric_truth_lemma`: Bidirectional truth lemma for restricted families
- `restricted_completeness_implies_full`: Lifting to valid_over Int
