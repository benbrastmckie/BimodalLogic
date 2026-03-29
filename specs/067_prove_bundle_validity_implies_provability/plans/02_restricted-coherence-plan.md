# Implementation Plan: Task 67 - Restricted Coherence Path

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None (builds on existing sorry-free infrastructure)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/07_team-research.md
- **Artifacts**: plans/02_restricted-coherence-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the **restricted coherence path** identified by team research as the mathematically correct solution to complete `bundle_validity_implies_provability`. The core insight is that the truth lemma only invokes `forward_F`/`backward_P` on formulas in `deferralClosure(target)`, and family-level coherence is already proven for these formulas via `restricted_forward_chain_forward_F` and `restricted_backward_chain_backward_P` in SuccChainFMCS.lean.

The key semantic observation: **same-family = same-history** in task semantics. Each FMCS family generates exactly one canonical history, and G/H operators quantify within that history. This means restricted family-level coherence (for deferral-closure formulas) is sufficient.

### Research Integration

Team research (07_team-research.md) identified:
1. Same-family witness requirement IS same-history witness requirement
2. `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2921) is SORRY-FREE
3. `restricted_backward_chain_backward_P` (SuccChainFMCS.lean:4262) is SORRY-FREE
4. Full family-level coherence is mathematically impossible (unbounded F-nesting)
5. Restricted coherence suffices because truth lemma only uses deferral-closure formulas
6. Estimated 350-550 lines of new code

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `bundle_validity_implies_provability` (FrameConditions/Completeness.lean:176)
- Transfer restricted coherence from SuccChainFMCS to BFMCS_Bundle families
- Implement restricted semantic truth lemma scoped by target formula
- Wire restricted construction to `valid_over Int` definition

**Non-Goals**:
- Full completeness over arbitrary F-nesting (provably impossible)
- Dense completeness (requires separate Rat canonical model)
- Refactoring existing BFMCS infrastructure (already sorry-free)
- Proving full `TemporallyCoherent` for BFMCS_Bundle (not needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Shift preservation of restricted coherence has subtle edge cases | Medium | Medium | Verify shift algebra using existing `succ_chain_fam_shift` lemmas |
| Restricted truth lemma G/H backward cases require careful closure tracking | Medium | Medium | Use `closureWithNeg_subset_deferralClosure` to verify closure membership |
| TaskModel construction from restricted chain has type mismatches | Low | Medium | Build thin adapter using `parametric_to_history` pattern |
| Termination sorries in auxiliary code block compilation | Low | Low | Those are in deprecated paths; main restricted chain is sorry-free |

## Implementation Phases

### Phase 1: Restricted Coherence Transfer [PARTIAL]

**Goal**: Prove that BFMCS_Bundle families inherit restricted coherence from SuccChainFMCS

**Tasks**:
- [ ] Define `RestrictedTemporalCoherence` predicate for a family over `deferralClosure(phi)`
- [ ] Prove `bfmcs_bundle_restricted_forward_F`: for any family in `construct_bfmcs_bundle`, F-witnesses in deferral closure have same-family witnesses
- [ ] Prove `bfmcs_bundle_restricted_backward_P`: symmetric for P-witnesses
- [ ] Handle shift preservation: `boxClassFamilies` uses shifted chains, need `shift_preserves_restricted_coherence`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - Add coherence transfer theorems

**Key dependencies**:
- `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2921)
- `restricted_backward_chain_backward_P` (SuccChainFMCS.lean:4262)
- `construct_bfmcs_bundle` (ModalSaturation.lean)
- `boxClassFamilies` (ModalSaturation.lean)

**Timing**: 2-3 hours

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.RestrictedTruthLemma` passes
- `bfmcs_bundle_restricted_forward_F` type-checks without sorry

---

### Phase 2: Restricted Semantic Truth Lemma [NOT STARTED]

**Goal**: Prove truth lemma for restricted chain, scoped by target formula

**Tasks**:
- [ ] Fill sorries in `restricted_chain_G_propagates` (RestrictedTruthLemma.lean:106) using DRM properties
- [ ] Fill sorries in `restricted_chain_H_step` (RestrictedTruthLemma.lean:135) using Succ h_content
- [ ] Define `RestrictedCanonicalTaskModel` using restricted chain Lindenbaum extensions
- [ ] Prove `restricted_semantic_truth_lemma`:
  ```lean
  theorem restricted_semantic_truth_lemma
      (B : BFMCS_Bundle) (phi_target : Formula)
      (h_rtc : RestrictedTemporalCoherence B (deferralClosure phi_target))
      (psi : Formula) (h_sub : psi in subformulaClosure phi_target)
      (fam : FMCS Int) (hfam : fam in B.families) (t : Int) :
      psi in fam.mcs t <-> truth_at (...) (parametric_to_history fam) t psi
  ```
- [ ] Handle each formula case:
  - atom/bot: direct from valuation definition
  - imp: bidirectional using both IH directions (key insight from research)
  - box: by modal coherence (already satisfied by BFMCS)
  - all_future (G): forward by `forward_G`; backward by contrapositive using `h_rtc` for same-family F-witness
  - all_past (H): symmetric using `backward_P`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - Fill sorries, add semantic lemma

**Key insight**: The backward G case is:
```
G(psi) not in fam.mcs(t)
=> F(neg(psi)) in fam.mcs(t)           [MCS negation + temporal duality]
=> neg(psi) in fam.mcs(s) for s > t    [restricted_forward_F - SAME FAMILY]
=> psi true at s by backward IH        [IH.mp on psi]
=> contradiction with neg(psi) in fam.mcs(s)
```

**Timing**: 3-4 hours

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.RestrictedTruthLemma` passes
- No sorries in `restricted_chain_G_propagates`, `restricted_chain_H_step`
- `restricted_semantic_truth_lemma` type-checks

---

### Phase 3: Completeness Wiring [NOT STARTED]

**Goal**: Complete `bundle_validity_implies_provability` using restricted construction

**Tasks**:
- [ ] Use existing `not_provable_implies_neg_consistent` (UltrafilterChain.lean, sorry-free)
- [ ] Build `BFMCS_Bundle` from Lindenbaum extension of `{neg(phi)}` via `construct_bfmcs_bundle`
- [ ] Establish `RestrictedTemporalCoherence` for the bundle using Phase 1 results
- [ ] Apply `restricted_semantic_truth_lemma` with `phi_target = phi`
- [ ] Show: `neg(phi) in eval_family.mcs(0)` => `neg(phi)` true at (eval_history, 0)
- [ ] Build TaskModel from restricted construction for valid_over
- [ ] Derive contradiction: `valid_over` says `phi` true everywhere, but `neg(phi)` is true
- [ ] Complete the by_contra proof

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Replace sorry in `bundle_validity_implies_provability`

**Proof structure**:
```lean
theorem bundle_validity_implies_provability (phi : Formula)
    (h_valid : valid_over Int phi) : Nonempty ([] deriv phi) := by
  by_contra h_not_prov
  have h_cons := not_provable_implies_neg_consistent phi h_not_prov  -- sorry-free
  obtain (M, hM, h_neg) := lindenbaum_mcs {neg(phi)} h_cons          -- sorry-free
  let B := construct_bfmcs_bundle M hM                                -- sorry-free
  have h_rtc : RestrictedTemporalCoherence B (deferralClosure phi) :=
    bfmcs_bundle_restricted_coherence B phi                           -- Phase 1
  have h_truth := restricted_semantic_truth_lemma B phi h_rtc         -- Phase 2
  -- neg(phi) true at (eval_family, 0) by h_truth and h_neg
  -- phi true at (eval_family, 0) by h_valid
  -- Contradiction: phi and neg(phi) cannot both be true
  sorry  -- Wire validity to TaskModel
```

**Timing**: 2-3 hours

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness` passes
- `bundle_validity_implies_provability` compiles without sorry
- `grep sorry Theories/Bimodal/FrameConditions/Completeness.lean` shows only `dense_completeness_fc`

---

### Phase 4: Fill Remaining Sorries and Cleanup [NOT STARTED]

**Goal**: Clean up termination sorries, documentation, and verify sorry-free status

**Tasks**:
- [ ] Fill termination sorries in `restricted_backward_bounded_witness` (SuccChainFMCS.lean:4257) using well-founded measure on P-nesting
- [ ] Fill termination sorries in `restricted_bounded_witness` (SuccChainFMCS.lean:2838) using F-nesting measure
- [ ] Update module documentation in Completeness.lean to reflect proven status
- [ ] Update docstrings to remove "has sorry" comments
- [ ] Verify no regressions with full `lake build`
- [ ] Run sorry audit: `grep -r sorry Theories/Bimodal/FrameConditions/` and `grep -r sorry Theories/Bimodal/Metalogic/Algebraic/`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Fill termination sorries
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Update documentation
- `Theories/Bimodal/Metalogic.lean` - Update completeness status comments

**Timing**: 1-2 hours

**Verification**:
- `lake build` passes completely
- Sorry count in completeness-related files matches expected (only dense_completeness_fc)
- Documentation accurately reflects proof status

## Testing & Validation

- [ ] `lake build Bimodal` compiles successfully
- [ ] `grep -r "sorry" Theories/Bimodal/FrameConditions/Completeness.lean` shows only `dense_completeness_fc`
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` shows zero
- [ ] `grep "sorry" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean | wc -l` is zero (after Phase 4)
- [ ] Manual verification: `#check bundle_validity_implies_provability` shows no sorry obligations

## Artifacts & Outputs

- `plans/02_restricted-coherence-plan.md` (this file)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (termination sorries only)
- `summaries/03_restricted-coherence-summary.md` (post-implementation)

## Rollback/Contingency

If implementation fails or introduces regressions:
1. `git checkout HEAD -- Theories/Bimodal/` to restore original state
2. Document specific failure point in errors.json
3. If restricted coherence transfer fails: verify deferral closure properties via explicit test cases
4. If truth lemma fails: check if closure membership predicates need strengthening
5. The existing algebraic infrastructure in UltrafilterChain.lean remains sorry-free regardless

## Technical Notes

### Why This Path Avoids Previous Blockers

| Previous Blocker | How Restricted Path Avoids It |
|------------------|-------------------------------|
| f_nesting unbounded | Only uses bounded deferral-closure formulas |
| Independent Lindenbaum | Uses SuccChainFMCS directly (no independent extensions) |
| Cross-boundary G to H(G) | Works within single chains (no cross-boundary) |
| Forward-only lemma | Uses restricted bidirectional lemma (scoped by target) |

### Key Infrastructure Status

| Theorem | Location | Status | Use |
|---------|----------|--------|-----|
| `restricted_forward_chain_forward_F` | SuccChainFMCS.lean:2921 | SORRY-FREE | F-witness in restricted chain |
| `restricted_backward_chain_backward_P` | SuccChainFMCS.lean:4262 | SORRY-FREE | P-witness in restricted chain |
| `iter_F_not_mem_closureWithNeg` | CanonicalTaskRelation.lean:175 | SORRY-FREE | F-nesting bounded |
| `not_provable_implies_neg_consistent` | UltrafilterChain.lean | SORRY-FREE | Start of contrapositive |
| `construct_bfmcs_bundle` | ModalSaturation.lean | SORRY-FREE | Bundle construction |
| `boxClassFamilies_bundle_temporally_coherent` | ModalSaturation.lean | SORRY-FREE | Bundle-level coherence |

### Semantic Model Pattern

```
1. neg(phi) consistent
       |
       v (Lindenbaum)
2. MCS M containing neg(phi)
       |
       v (construct_bfmcs_bundle)
3. BFMCS_Bundle B with eval_family containing neg(phi)
       |
       v (restricted_semantic_truth_lemma)
4. truth_at (eval_history, 0) neg(phi) = true
       |
       v (valid_over contradiction)
5. phi is provable (by contrapositive)
```

### Critical Bidirectionality Insight

The truth lemma MUST be bidirectional because:
```
Forward imp: (psi -> chi) in MCS, truth(psi) |- truth(chi)
  Step 1: truth(psi) -> psi in MCS     [BACKWARD IH for psi]
  Step 2: (psi -> chi) in MCS, psi in MCS -> chi in MCS  [MCS modus ponens]
  Step 3: chi in MCS -> truth(chi)     [FORWARD IH for chi]
```

This is why forward-only truth lemma was blocked. The restricted approach works because subformulaClosure is finite and F-nesting is bounded within deferralClosure.
