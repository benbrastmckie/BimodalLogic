# Implementation Plan: Task #58 - Deferral-Restricted Task Construction (v9)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [PARTIAL]
- **Effort**: 12 hours
- **Dependencies**: None (sorry-free infrastructure exists)
- **Research Inputs**: reports/21_team-research.md
- **Artifacts**: plans/09_deferral-restricted-task.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements completeness via the **deferral-restricted task construction** path. The key insight from research report 21: the "sub-case (b)" obstruction (`F(phi)` and `G(neg phi)` in same MCS) is **vacuously harmless** because these formulas are derivably contradictory. The real obstruction is **unbounded F-nesting**, which is resolved by restricting to `deferralClosure(phi)`.

The approach uses algebraic x-value computation (not FMP machinery per se) — specifically, the algebraic fact that formulas have finite subformula closures, which bounds F-nesting. All necessary infrastructure is already sorry-free.

### Research Integration

Key findings from report 21 integrated:
- `bounded_witness` theorem provides x-value resolution (sorry-free)
- `f_nesting_is_bounded_restricted` ensures bounded F-nesting for RestrictedMCS (sorry-free)
- `restricted_forward_chain_forward_F` provides family-level F coherence (sorry-free)
- `parametric_shifted_truth_lemma` works given temporal coherence (sorry-free given h_tc)
- Missing theorem: `deferralClosure_closed_under_box_class`

## Goals & Non-Goals

**Goals**:
- Eliminate the 3 target sorries: `dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int`
- Use deferral-restricted construction (algebraic x-value computation)
- Leverage existing sorry-free infrastructure
- Prove the missing `deferralClosure_closed_under_box_class` theorem

**Non-Goals**:
- Proving completeness for arbitrary MCS (unbounded F-nesting is genuine obstruction)
- Implementing FMP-style model finitization (not needed for this path)
- Restructuring the bundle-level approach (keep existing bundle infrastructure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `deferralClosure_closed_under_box_class` harder than expected | H | M | Phase 1 focuses on this theorem; fallback to partial progress |
| Box-class extension may not preserve deferral restriction | H | L | Use subformula closure properties; closure is closed under subformulas |
| Wiring to completeness has hidden dependencies | M | L | Careful tracing of h_tc requirements through parametric lemma |
| Truth lemma imp case still blocks | H | L | Already addressed by restricted_forward_chain_forward_F ensuring same-family witnesses |

## Implementation Phases

### Phase 1: Prove `deferralClosure_closed_under_box_class` [PARTIAL]

**Goal**: Prove that if M0 is restricted to `deferralClosure(phi)`, and W has `box_class_agree M0 W`, then W is also restricted to `deferralClosure(phi)`.

**Mathematical Content**:
- `box_class_agree M W` means `forall psi, Box psi in M <-> Box psi in W`
- `DeferralRestrictedMCS phi M` means M is an MCS over `deferralClosure(phi)`
- Need to show: if M satisfies deferral restriction and W agrees on box content, then W satisfies deferral restriction
- Key insight: Box-class agreement preserves the subformula closure property because:
  1. Box formulas in M come from `closureWithNeg(phi)` (by restriction)
  2. W agrees on exactly these Box formulas
  3. The closure is closed under subformulas, so W's Box content stays within bounds

**Tasks**:
- [ ] Add lemma `closureWithNeg_closed_under_box` showing Box(psi) in closure implies psi in closure
- [ ] Add lemma `deferralClosure_closed_under_box` for deferralClosure
- [ ] Prove `deferralClosure_closed_under_box_class` using above lemmas
- [ ] Add to `SubformulaClosure.lean` or create new file `DeferralClosureProperties.lean`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - closure properties
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - box_class theorem

**Verification**:
- `lake build Bimodal.Syntax.SubformulaClosure`
- `#print axioms deferralClosure_closed_under_box_class`

---

### Phase 2: Build Deferral-Restricted BFMCS Construction [BLOCKED]

**Goal**: Create a construction `construct_deferral_restricted_bfmcs` that builds a BFMCS from a deferral-restricted MCS with bounded F-nesting.

**Mathematical Content**:
The construction follows this path:
1. Start with `phi` not provable
2. `neg(phi)` is consistent
3. Extend `neg(phi)` to `DeferralRestrictedSerialMCS phi M0` over `deferralClosure(phi)`
4. Build `restricted_forward_chain phi M0` (existing infrastructure)
5. Each step preserves deferral restriction (uses `deferralClosure_closed_under_box_class`)
6. F-nesting is bounded by `f_nesting_is_bounded_restricted`
7. Package as BFMCS with temporal coherence

**Tasks**:
- [ ] Define `DeferralRestrictedBFMCS` structure extending BFMCS with restriction property
- [ ] Prove `restricted_forward_chain_deferral_preserved`: chain elements stay in deferralClosure
- [ ] Prove `construct_deferral_restricted_bfmcs`: build BFMCS from deferral-restricted seed
- [ ] Prove `deferral_restricted_bfmcs_temporally_coherent`: uses `restricted_forward_chain_forward_F`

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - add restricted BFMCS construction
- Or create new file `Theories/Bimodal/Metalogic/Bundle/DeferralRestrictedBFMCS.lean`

**Verification**:
- `lake build`
- `#print axioms construct_deferral_restricted_bfmcs`
- `#print axioms deferral_restricted_bfmcs_temporally_coherent`

---

### Phase 3: Wire to Parametric Truth Lemma [BLOCKED]

**Goal**: Connect the deferral-restricted BFMCS to `parametric_shifted_truth_lemma`.

**Mathematical Content**:
The key theorem `parametric_shifted_truth_lemma` requires `h_tc : B.temporally_coherent`. We have:
- `deferral_restricted_bfmcs_temporally_coherent` (from Phase 2)
- This gives the hypothesis needed for the truth lemma

The completeness argument then proceeds:
1. phi not provable -> neg(phi) consistent
2. Build deferral-restricted BFMCS from neg(phi)
3. neg(phi) in eval_family.mcs(0)
4. By truth lemma: neg(phi) true at parametric model
5. Therefore phi false at parametric model (countermodel exists)
6. Contrapositive: valid over Int implies provable

**Tasks**:
- [ ] Prove `deferral_restricted_completeness_lemma`: builds countermodel for non-provable formulas
- [ ] Prove `deferral_restricted_neg_in_mcs`: neg(phi) in the evaluation MCS
- [ ] Prove `deferral_restricted_countermodel`: phi false at the constructed model
- [ ] Wire to `not_provable_implies_neg_consistent` (existing)

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - add deferral-restricted version
- Or `Theories/Bimodal/Metalogic/Bundle/DeferralRestrictedBFMCS.lean`

**Verification**:
- `lake build`
- `#print axioms deferral_restricted_completeness_lemma`

---

### Phase 4: Eliminate Target Sorries [BLOCKED]

**Goal**: Use the deferral-restricted completeness to eliminate the 3 target sorries.

**Mathematical Content**:
The target sorries are in `FrameConditions/Completeness.lean`:
1. `dense_completeness_fc` (line 116-120)
2. `discrete_completeness_fc` (line 158-163)
3. `bundle_validity_implies_provability` (which `completeness_over_Int` calls)

The proof structure:
- `completeness_over_Int`: If phi valid over Int, then provable
  - Contrapositive: If not provable, exists countermodel over Int
  - Use `deferral_restricted_completeness_lemma`

- `dense_completeness_fc`: If phi valid over all dense frames, then provable
  - Int is dense (or embeds densely)
  - Reduce to `completeness_over_Int`

- `discrete_completeness_fc`: If phi valid over all discrete frames, then provable
  - Int is discrete
  - Reduce to `completeness_over_Int`

**Tasks**:
- [ ] Prove `bundle_validity_implies_provability` using deferral-restricted construction
- [ ] Verify `completeness_over_Int` follows (it already calls `bundle_validity_implies_provability`)
- [ ] Prove `dense_completeness_fc` via reduction to Int
- [ ] Prove `discrete_completeness_fc` via reduction to Int
- [ ] Run `#print axioms` on all three theorems

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness`
- `#print axioms dense_completeness_fc`
- `#print axioms discrete_completeness_fc`
- `#print axioms completeness_over_Int`
- All should show no `sorry` axiom

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each new theorem verified with `#print axioms` (no sorry)
- [ ] Final verification: `#print axioms dense_completeness_fc`, `#print axioms discrete_completeness_fc`, `#print axioms completeness_over_Int` all clean
- [ ] Documentation updated to reflect sorry elimination

## Artifacts & Outputs

- `plans/09_deferral-restricted-task.md` (this file)
- Modified/created Lean files:
  - `SubformulaClosure.lean` - deferral closure properties
  - `DeferralRestrictedBFMCS.lean` (or additions to `SuccChainFMCS.lean`)
  - `ParametricRepresentation.lean` - deferral-restricted completeness
  - `FrameConditions/Completeness.lean` - sorry elimination
- `summaries/10_deferral-restricted-summary.md` (after completion)

## Rollback/Contingency

If Phase 1 (`deferralClosure_closed_under_box_class`) proves harder than expected:
1. Document the specific mathematical obstruction
2. Consider whether a weaker property suffices
3. Investigate alternative approaches (e.g., direct box-content restriction in chain construction)

If temporal coherence wiring fails:
1. Verify `restricted_forward_chain_forward_F` actually provides the needed property
2. Check if additional lemmas needed to convert to `TemporalCoherentFamily` interface
3. Document the gap precisely for future investigation

## Mathematical Summary

**The Algebraic X-Value Framework**:
```
1. phi not provable -> neg(phi) consistent
2. Extend to DeferralRestrictedMCS M0 over deferralClosure(phi)
3. For any F(psi) in M0:
   - F-nesting is bounded (f_nesting_is_bounded_restricted)
   - x = max n such that F^n(psi) in M0 (the x-value)
   - bounded_witness: psi in chain(x) at CanonicalTask(M0, x, chain(x))
4. Build SuccChainFMCS with CanonicalTask-connected worlds
5. restricted_forward_chain_forward_F: F-witnesses exist in same family
6. Apply parametric_shifted_truth_lemma (sorry-free given coherence)
7. Completeness: phi not true at model -> phi not valid
```

**Key Insight**: Using `deferralClosure(phi)` is NOT invoking FMP machinery. It uses the algebraic fact that formulas have finite subformula closures, which bounds F-nesting. This is a property of syntax, not model theory.
