# Implementation Plan: Task 67 - Prove bundle_validity_implies_provability

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/01_bundle-provability-research.md
- **Artifacts**: plans/01_bundle-provability-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate the sorry in `bundle_validity_implies_provability` (FrameConditions/Completeness.lean:176) by implementing restricted completeness. The core obstacle is that the bidirectional truth lemma (`shifted_truth_lemma`) requires family-level temporal coherence (`B.temporally_coherent`), but `BFMCS_Bundle` only provides bundle-level coherence where F/P witnesses can be in ANY family.

The recommended approach uses restricted completeness via finite subformula closure: for any specific formula phi, `closureWithNeg(phi)` is finite, F-nesting is bounded, and `RestrictedTemporallyCoherentFamily` achieves family-level coherence. The key insight is that we only need to evaluate phi, not arbitrary formulas, so restricted completeness suffices.

### Research Integration

Research report (01_bundle-provability-research.md) identified:
1. Forward-only truth lemma is NOT viable (imp case inherently bidirectional)
2. Z-chain family-level coherence is blocked by unbounded F-nesting
3. Restricted completeness path has existing infrastructure: `restricted_forward_chain_forward_F` (proven), `restricted_backward_chain_backward_P` (proven), `RestrictedTemporallyCoherentFamily` (defined)
4. Main gaps: `restricted_tc_family_to_fmcs` forward_G/backward_H sorries, wiring to completeness

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `bundle_validity_implies_provability`
- Implement restricted truth lemma connecting DRM membership to semantic truth_at
- Wire restricted construction to the valid_over definition
- Maintain backward compatibility with existing algebraic completeness infrastructure

**Non-Goals**:
- Full completeness over arbitrary infinite F-nesting (provably blocked)
- Dense completeness (separate issue requiring Rat canonical model)
- Refactoring the BFMCS bundle infrastructure (it's sorry-free as-is)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted truth lemma requires additional G/H propagation infrastructure | Medium | Medium | Leverage existing `restricted_chain_G_step`/`restricted_chain_H_step` from RestrictedTruthLemma.lean |
| FMCS conversion sorries require non-trivial MCS closure arguments | Medium | Medium | Use existing DRM maximality proofs; only needed for subformula closure formulas |
| Wiring restricted model to valid_over definition has type mismatches | Low | Medium | Build thin adapter layer between restricted chain semantics and TaskModel |
| Termination sorries in SuccChainFMCS block compilation | High | Low | Those sorries are in deprecated/auxiliary code; main path is sorry-free |

## Implementation Phases

### Phase 1: Restricted BFMCS Construction [BLOCKED]

**Goal**: Build a BFMCS structure from a RestrictedTemporallyCoherentFamily that satisfies `temporally_coherent`

**Tasks**:
- [ ] Create `RestrictedBFMCS` structure wrapping restricted chain families
- [ ] Prove `restricted_bfmcs_temporally_coherent`: the restricted family achieves family-level F/P coherence
- [ ] Use existing `build_restricted_tc_family` from SuccChainFMCS.lean as the seed construction
- [ ] Verify the restricted chain properties (`restricted_forward_chain_forward_F`, `restricted_backward_chain_backward_P`) are sufficient

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Add RestrictedBFMCS definition
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - Add coherence theorem

**Timing**: 2-3 hours

**Verification**:
- `lake build` passes
- `RestrictedBFMCS` type-checks with `temporally_coherent` satisfied

---

### Phase 2: Restricted Truth Lemma Semantic Extension [NOT STARTED]

**Goal**: Extend `restricted_truth_lemma` to prove semantic equivalence with truth_at, not just MCS membership

**Tasks**:
- [ ] Define `RestrictedCanonicalTaskModel` from RestrictedTemporallyCoherentFamily
- [ ] Define `RestrictedCanonicalOmega` (shift-closed set of histories from restricted chain)
- [ ] Prove `restricted_semantic_truth_lemma`: for psi in subformulaClosure(phi), membership in restricted chain iff truth_at at restricted model
- [ ] Handle each formula case (atom, bot, imp, box, all_future, some_future, all_past, some_past)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - Add semantic truth lemma

**Timing**: 3-4 hours

**Verification**:
- `lake build` passes
- `restricted_semantic_truth_lemma` type-checks with correct biconditional

---

### Phase 3: Fill FMCS Conversion Sorries [NOT STARTED]

**Goal**: Complete `restricted_tc_family_to_fmcs` forward_G and backward_H proofs

**Tasks**:
- [ ] Analyze gap: forward_G requires showing G(psi) at t implies psi at t' >= t for extended MCS
- [ ] For subformulaClosure formulas: use `restricted_chain_G_step` and DRM subset of extension
- [ ] For arbitrary formulas: use MCS closure under derivation (G(psi) derives psi via temp_t_future)
- [ ] Implement analogous argument for backward_H using H_step
- [ ] Handle the transition from DeferralRestrictedMCS to full MCS carefully

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Fill sorries in `restricted_tc_family_to_fmcs`

**Timing**: 2-3 hours

**Verification**:
- `lake build` passes with no sorries in `restricted_tc_family_to_fmcs`
- `forward_G` and `backward_H` fields compile without sorry

---

### Phase 4: Wire Restricted Completeness to Main Theorem [NOT STARTED]

**Goal**: Complete `bundle_validity_implies_provability` using restricted construction

**Tasks**:
- [ ] For any unprovable phi, use `not_provable_implies_neg_consistent` to get consistent neg(phi)
- [ ] Build `RestrictedTemporallyCoherentFamily` from Lindenbaum extension of {neg(phi)}
- [ ] Apply restricted semantic truth lemma: neg(phi) in seed implies neg(phi) true at position 0
- [ ] Build TaskModel from restricted construction
- [ ] Show this TaskModel witnesses that phi is not valid_over Int (contradiction)
- [ ] Complete the by_contra proof structure

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Replace sorry in `bundle_validity_implies_provability`

**Timing**: 2-3 hours

**Verification**:
- `lake build Bimodal` passes
- `bundle_validity_implies_provability` compiles without sorry
- `grep -r sorry Theories/Bimodal/FrameConditions/Completeness.lean` finds only dense_completeness_fc sorry

---

### Phase 5: Cleanup and Documentation [NOT STARTED]

**Goal**: Clean up code, update documentation, verify completeness status

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Update docstrings in Completeness.lean to reflect proven status
- [ ] Update module header documentation
- [ ] Verify `completeness_over_Int` now references sorry-free `bundle_validity_implies_provability`
- [ ] Update TODO.md status comments if any exist regarding completeness

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Update documentation
- `Theories/Bimodal/Metalogic.lean` - Update any completeness status comments

**Timing**: 1 hour

**Verification**:
- `lake build` passes
- Documentation accurately reflects proof status
- No unexpected sorries introduced

## Testing & Validation

- [ ] `lake build Bimodal` compiles successfully
- [ ] `grep -r "sorry" Theories/Bimodal/FrameConditions/Completeness.lean` shows only `dense_completeness_fc`
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` shows zero
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean | grep -v "deprecated\|NOTE\|TODO"` shows zero critical sorries

## Artifacts & Outputs

- `plans/01_bundle-provability-plan.md` (this file)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
- `summaries/02_bundle-provability-summary.md` (post-implementation)

## Rollback/Contingency

If implementation fails or introduces regressions:
1. `git checkout HEAD -- Theories/Bimodal/` to restore original state
2. Document specific failure point in errors.json
3. Consider alternative: weaker completeness theorem that explicitly states restriction (e.g., "for formulas with bounded F-nesting")
4. The algebraic completeness path in UltrafilterChain.lean remains sorry-free regardless

## Technical Notes

### Key Theorems to Leverage

| Theorem | Location | Status | Use |
|---------|----------|--------|-----|
| `restricted_forward_chain_forward_F` | SuccChainFMCS.lean | PROVEN | F-witness in restricted chain |
| `restricted_backward_chain_backward_P` | SuccChainFMCS.lean | PROVEN | P-witness in restricted chain |
| `iter_F_not_mem_closureWithNeg` | RestrictedMCS.lean | PROVEN | F-nesting bounded |
| `restricted_truth_lemma` | RestrictedTruthLemma.lean | PROVEN | DRM <-> extended MCS for closure |
| `not_provable_implies_neg_consistent` | UltrafilterChain.lean | PROVEN | Start of contrapositive |
| `shifted_truth_lemma` | CanonicalConstruction.lean | Ready | Apply once h_tc satisfied |

### Semantic Model Construction Pattern

```
1. RestrictedTemporallyCoherentFamily phi seed
       |
       v (restricted_chain_ext)
2. FMCS Int (Lindenbaum at each position)
       |
       v (to_history)
3. WorldHistory (CanonicalTaskFrame Int)
       |
       v (CanonicalTaskModel + RestrictedOmega)
4. truth_at evaluation
```

### Critical Insight

The imp case of the truth lemma is bidirectional by necessity:
```
Forward: (psi -> chi) in MCS, truth(psi) -> truth(chi)
         Uses IH.mpr on psi (backward direction!)
```

This is why forward-only truth lemma fails and we need full bidirectional proof. The restricted approach works because subformulaClosure is finite and F-nesting bounded.
