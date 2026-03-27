# Research Report: bundle_validity_implies_provability

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-27
**Session**: sess_1774654413_fd3188
**Status**: Research completed

## Executive Summary

The sorry at `bundle_validity_implies_provability` (Completeness.lean:176) represents the final "model-theoretic glue" needed to connect:
- The algebraic completeness infrastructure (sorry-free) which proves `not_provable -> MCS with neg(phi)`
- The semantic validity definition `valid_over Int phi` which quantifies over TaskModels

**Key Finding**: The obstacle is NOT the algebraic proof but the **bidirectional truth lemma**. The existing `shifted_truth_lemma` requires `h_tc : B.temporally_coherent` (family-level F/P witnesses), while `BFMCS_Bundle` only provides bundle-level coherence (witnesses can be in ANY family).

**Recommended Approach**: Restricted completeness via finite subformula closure, where F-nesting IS bounded and family-level coherence is achievable.

## Problem Statement

### Target Theorem
```lean
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ)
```

### The Gap

The proof uses contrapositive:
1. Assume `phi` not provable
2. `neg(phi)` is consistent (by `not_provable_implies_neg_consistent`)
3. Build `BFMCS_Bundle` from Lindenbaum extension of `{neg(phi)}`
4. `neg(phi)` is in `eval_family.mcs 0` (by construction)
5. **GAP**: Need to show this bundle forms a valid countermodel for `valid_over Int phi`
6. Contradiction: `h_valid` says `phi` true everywhere, but we have `neg(phi)` true

Step 5 requires connecting `BFMCS_Bundle` to `TaskModel` semantics, which requires the truth lemma.

## Analysis of Existing Infrastructure

### What's Sorry-Free (Algebraic Completeness Path)

| Component | Location | Status |
|-----------|----------|--------|
| `construct_bfmcs_bundle` | UltrafilterChain.lean:2853 | PROVEN |
| `boxClassFamilies_bundle_temporally_coherent` | UltrafilterChain.lean:2731 | PROVEN |
| `not_provable_implies_neg_consistent` | UltrafilterChain.lean:2950 | PROVEN |
| `bundle_completeness_contradiction` | UltrafilterChain.lean:2931 | PROVEN |
| `mcs_neg_gives_countermodel` | UltrafilterChain.lean:2915 | PROVEN |

### What Requires Sorry (Model Connection)

| Component | Location | Issue |
|-----------|----------|-------|
| `shifted_truth_lemma` | CanonicalConstruction.lean:650 | Requires `h_tc : B.temporally_coherent` |
| `restricted_tc_family_to_fmcs` | CanonicalConstruction.lean:834 | forward_G/backward_H have sorries |
| `build_restricted_tc_family` | SuccChainFMCS.lean:4643 | Uses restricted chain with sorries |

### The Core Obstruction

The `shifted_truth_lemma` signature:
```lean
theorem shifted_truth_lemma (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t φ
```

The `temporally_coherent` predicate requires:
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t, ∀ φ, F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s) ∧  -- SAME family
    (∀ t, ∀ φ, P(φ) ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s)   -- SAME family
```

But `BFMCS_Bundle` only provides `BundleTemporallyCoherent`:
```lean
def BundleTemporallyCoherent (families : Set (FMCS Int)) : Prop :=
  ∀ fam ∈ families, bundle_forward_F families fam ∧ bundle_backward_P families fam
```
where `bundle_forward_F` allows witnesses in ANY family of the bundle.

### Why This Matters

The truth lemma proof for the G (all_future) backward direction:
```lean
| all_future ψ ih =>
    ...
    · -- Backward: (∀ s ≥ t, truth_at τ s ψ) → G(ψ) ∈ fam.mcs t
      intro h_all
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam  -- REQUIRES h_tc
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F  -- Must be SAME family
        backward_P := h_backward_P
      }
      ...
      exact temporal_backward_G tcf t ψ h_all_mcs  -- Uses family-level coherence
```

The `temporal_backward_G` proof uses contraposition:
1. Assume `G(ψ)` not in `fam.mcs t`
2. Then `neg(G(ψ)) = F(neg(ψ))` in `fam.mcs t` (by MCS maximality)
3. By `forward_F`: `neg(ψ)` in `fam.mcs s` for some `s > t` (SAME family!)
4. Contradiction with hypothesis that `ψ` true at all `s ≥ t`

If `forward_F` allows witnesses in a DIFFERENT family, step 3 doesn't give a contradiction.

## Approach Analysis

### Approach (a): Forward-Only Truth Lemma

**Hypothesis**: For completeness, we only need the forward direction of the truth lemma.

**Analysis from Team Research (50_team-research.md)**:

The imp case inherently requires bidirectionality:
```lean
| imp ψ χ ih_ψ ih_χ =>
    ...
    · -- Forward: (ψ → χ) ∈ MCS → (truth ψ → truth χ)
      intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true  -- ← USES .mpr (backward IH)
      exact (ih_χ fam hfam t).mp (mcs_closure h_imp h_ψ_mem)
```

Even the forward direction of the imp case uses the backward direction of the subformula IH.

**Conclusion**: Forward-only truth lemma is NOT viable. The truth lemma is inherently bidirectional.

### Approach (b): Z-Chain Family-Level Coherence

**Hypothesis**: Achieve family-level temporal coherence via fair-scheduling or dovetailing.

**Obstacles** (from Team Research):

1. **f_nesting unbounded for arbitrary MCS**: An MCS can contain `{F^n(p) | n ∈ Nat}` for all n (this is finitely consistent). The F-nesting depth is unbounded.

2. **G(φ) → □G(φ) not derivable**: Even if we find an F-witness in another family, we cannot transfer it because the transfer would require `G(neg(φ)) → □G(neg(φ))`, which is not derivable in TM.

3. **Fair-scheduling complexity**: Forcing each F-obligation in turn via priority-queue dovetailing could work, but the consistency proof for forced resolutions is complex and not currently implemented.

**Conclusion**: Full Z-chain family-level coherence for arbitrary MCS is blocked by unbounded F-nesting.

### Approach (c): Restricted Completeness (RECOMMENDED)

**Key Insight**: For a SPECIFIC formula φ, the `closureWithNeg(φ)` is **finite**. Within this closure:
- F-nesting IS bounded: `iter_F_not_mem_closureWithNeg` proves `F^n(φ)` leaves closure at bounded n
- RestrictedMCS (MCS restricted to closureWithNeg) avoids the unboundedness issue
- SuccChain construction SHOULD work for RestrictedMCS

**Strategy**:
1. For any unprovable φ, `neg(φ)` is consistent
2. Extend to RestrictedMCS within `closureWithNeg(φ)`
3. Build restricted bundle with family-level temporal coherence (F-nesting bounded!)
4. Prove restricted truth lemma
5. Show restricted canonical model IS a valid TaskModel over Int
6. Derive contradiction with `valid_over Int φ`

**Current Status** (from SuccChainFMCS.lean analysis):

| Component | Status | Sorries |
|-----------|--------|---------|
| `RestrictedTemporallyCoherentFamily` | Defined | Structure ready |
| `build_restricted_tc_family` | Partially implemented | forward_F uses `restricted_forward_chain_forward_F` (no sorry) |
| `restricted_forward_chain_forward_F` | PROVEN | Uses terminating recursion |
| Backward chain | Incomplete | Needs `constrained_predecessor_restricted` (documented gap) |
| `restricted_tc_family_to_fmcs` | Has sorry | forward_G/backward_H incomplete |

**Remaining Work for Approach (c)**:
1. Complete backward chain construction for RestrictedMCS
2. Fill sorries in `restricted_tc_family_to_fmcs`
3. Prove restricted truth lemma using the restricted FMCS
4. Wire to `bundle_validity_implies_provability`

## Recommended Path Forward

### Primary Recommendation: Restricted Completeness

**Phase 1: Complete Restricted Backward Chain** (estimated 4-6 hours)
- Implement `constrained_predecessor_restricted` mirroring `constrained_successor_restricted`
- Implement `restricted_backward_chain_backward_P` mirroring `restricted_forward_chain_forward_F`

**Phase 2: Fill FMCS Conversion Sorries** (estimated 2-4 hours)
- Complete `restricted_tc_family_to_fmcs.forward_G` using restricted chain properties
- Complete `restricted_tc_family_to_fmcs.backward_H` using restricted chain properties

**Phase 3: Wire to Completeness** (estimated 2-3 hours)
- Build BFMCS from restricted FMCS with `temporally_coherent` property satisfied
- Apply `shifted_truth_lemma` with the restricted construction
- Complete `bundle_validity_implies_provability` using the restricted countermodel

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Backward chain has unforeseen complexity | Medium | High | Use forward chain as template; structure is symmetric |
| Restricted FMCS doesn't compose with BFMCS | Low | High | Restricted families are already FMCS; should work |
| Restricted completeness doesn't lift to full | Low | Medium | For ANY unprovable φ, restricted countermodel suffices |

### Confidence Assessment

- **Approach viability**: 75% (restricted completeness path is mathematically sound)
- **Implementation complexity**: Medium (symmetric to existing forward chain work)
- **Timeline**: 8-13 hours total for all three phases

## Key Theorems to Leverage

1. `iter_F_not_mem_closureWithNeg` - F^n leaves closure at bounded n
2. `restricted_forward_chain_forward_F` - Already proven F-witness existence
3. `shifted_truth_lemma` - Ready to use once h_tc is satisfied
4. `shiftClosedCanonicalOmega_is_shift_closed` - Shift closure proven

## References

- `FrameConditions/Completeness.lean:176` - Target sorry
- `UltrafilterChain.lean:2853-2877` - Bundle construction (sorry-free)
- `CanonicalConstruction.lean:650-775` - Shifted truth lemma
- `SuccChainFMCS.lean:2921-2929` - Restricted forward chain (sorry-free)
- `SuccChainFMCS.lean:4624-4670` - RestrictedTemporallyCoherentFamily
- `50_team-research.md` - Team research on Options 1 & 3 (Task #58)
