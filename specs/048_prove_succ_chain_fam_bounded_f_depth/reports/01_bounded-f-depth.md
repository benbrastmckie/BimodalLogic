# Research Report: Prove succ_chain_fam Bounded F-Depth

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Status**: Research Complete
**Session**: sess_1774286992_e47cca

## Executive Summary

The current sorry lemmas `f_nesting_is_bounded` and `p_nesting_is_bounded` claim F/P-iteration boundedness for **arbitrary** MCS, but this claim is mathematically unsound. Task 47 proved boundedness only for RestrictedMCS (MCS bounded by a finite closure). The correct approach is to **refactor the proof to use the completeness-specific context**, where the MCS can be constrained to a closure.

## Problem Analysis

### The Sorry Lemmas

Located in `SuccChainFMCS.lean`:

1. **`f_nesting_is_bounded`** (lines 706-750):
   ```lean
   theorem f_nesting_is_bounded (M : Set Formula) (h_mcs : SetMaximalConsistent M)
       (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
       ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M
   ```

2. **`p_nesting_is_bounded`** (lines 927-935):
   ```lean
   theorem p_nesting_is_bounded (M : Set Formula) (h_mcs : SetMaximalConsistent M)
       (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
       ∃ n, n ≥ 2 ∧ iter_P n phi ∉ M
   ```

### Why These Claims Are Problematic

**Key Insight**: For an arbitrary MCS M over the full formula language, the claim is FALSE. An MCS can consistently contain F(phi), FF(phi), FFF(phi), ... for all n without violating consistency.

**Mathematical Reasoning**:
- F^n(phi) for distinct n are distinct formulas (by `iter_F_injective`)
- Having all F^n(phi) in M does not derive a contradiction
- The set {F^n(phi) : n in Nat} is consistent (no two elements are negations of each other)
- Lindenbaum can extend this to an MCS containing all F-iterations

**What Task 47 Actually Proved**:
- `restricted_mcs_F_bounded`: For RestrictedMCS (MCS bounded by closureWithNeg), boundedness holds
- `iter_F_not_mem_closureWithNeg`: iter_F eventually leaves any finite closure
- The bound is `closure_F_bound phi = max_F_depth_in_closure phi + 1`

The key difference: RestrictedMCS can only contain formulas from a **finite** set (closureWithNeg), so iter_F must eventually leave the MCS.

### Usage Context

The lemmas are used in `succ_chain_forward_F` and `succ_chain_backward_P` to prove FMCS coherence:
- If F(phi) in mcs(n), then exists m > n with phi in mcs(m)
- The proof finds the F-nesting boundary and applies `bounded_witness`

The completeness theorem (`SuccChainCompleteness.lean`) uses succ_chain_fam where:
- M0 is built from Lindenbaum on {neg(target_formula)}
- M0 is NOT a RestrictedMCS
- The chain extends infinitely in both directions

## Mathematically Correct Approaches

### Approach A: Restrict to Formula Closure (Recommended)

**Key Insight**: In the completeness proof, we only need coherence for formulas in the closure of the target formula.

**Proof Strategy**:
1. Change `f_nesting_boundary` to take a reference formula psi
2. The MCS M is assumed to be restricted to closureWithNeg(psi)
3. Use Task 47's `restricted_mcs_F_bounded` directly
4. Update the completeness proof to track that we only need coherence within the closure

**Concrete Changes**:
```lean
-- New version restricted to closure
theorem f_nesting_is_bounded_in_closure
    (psi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS psi M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M := by
  -- From Task 47: restricted_mcs_F_bounded gives d >= 1 with iter_F d phi in M and iter_F (d+1) phi not in M
  -- Take n = d + 1 >= 2
  obtain ⟨d, h_d_ge, _, h_not⟩ := restricted_mcs_F_bounded psi M h_mcs h_F
  exact ⟨d + 1, by omega, h_not⟩
```

**Required Refactoring**:
1. Update `forward_chain` to build RestrictedMCS (requires passing target formula)
2. Update `backward_chain` similarly
3. Update `succ_chain_fam` to carry the closure restriction
4. Update completeness proof to instantiate with the target formula's closure

**Effort**: 6-8 hours (moderate refactoring)

### Approach B: Frame-Based Argument (Alternative)

**Key Insight**: The succ_chain_fam models a discrete linear frame. In frame semantics, F(phi) at world w is satisfied iff exists world w' > w with phi at w'.

**Proof Strategy**:
1. Formalize that succ_chain_fam satisfies discrete frame conditions
2. Show that in a discrete frame, F-chains have bounded satisfaction depth
3. Connect frame satisfaction to MCS membership

**Challenge**: This requires formalizing frame semantics and connecting syntactic MCS to semantic truth, which is circular (the truth lemma depends on F-coherence).

**Effort**: 8-12 hours (significant new infrastructure)

### Approach C: Deferral Chain Analysis (Complex)

**Key Insight**: The succ_chain_fam MCS are built via specific deferral seeds. Perhaps the deferral mechanism bounds F-depth.

**Proof Strategy**:
1. Track what formulas enter the chain via deferral
2. Show that iter_F n phi can only be in forward_chain M0 k if it was in M0 or deferred
3. Prove that the deferral mechanism doesn't create unbounded F-chains

**Challenge**: Deferral can propagate F-obligations indefinitely: F(phi) at M_n can become F(phi) at M_(n+1), which can become F(phi) at M_(n+2), etc. This doesn't bound F-depth.

**Analysis**: This approach is unlikely to succeed because:
- The starting MCS M0 can contain arbitrarily deep F-iterations
- Deferral preserves (doesn't increase) F-depth, but doesn't bound it

**Effort**: Would likely fail after 4-6 hours of investigation

## Recommended Solution: Approach A

### Rationale

1. **Mathematically Sound**: Task 47 already proved boundedness for RestrictedMCS
2. **Minimal Invasiveness**: Only requires threading closure info through the construction
3. **Clear Path**: The completeness proof naturally has a target formula to use for closure
4. **Reuses Existing Work**: Directly uses `restricted_mcs_F_bounded` and `restricted_mcs_iter_F_bound`

### Implementation Plan

**Phase 1: Define Restricted Succ-Chain (2-3 hours)**
- Create `RestrictedSerialMCS` that carries the closure formula
- Define `restricted_forward_chain` building RestrictedMCS
- Define `restricted_backward_chain` building RestrictedMCS
- Prove chain MCS are restricted to the closure

**Phase 2: Adapt F/P Boundedness (1-2 hours)**
- Replace `f_nesting_is_bounded` with `f_nesting_is_bounded_in_closure`
- Replace `p_nesting_is_bounded` with `p_nesting_is_bounded_in_closure`
- Update `f_nesting_boundary` and `p_nesting_boundary` to use restricted versions
- Remove the sorries

**Phase 3: Update FMCS Construction (2-3 hours)**
- Define `RestrictedSuccChainFMCS` carrying closure
- Prove F/P coherence for the restricted family
- Prove restricted family satisfies FMCS conditions

**Phase 4: Update Completeness (1-2 hours)**
- Modify `succ_chain_completeness` to use restricted construction
- Pass target formula's closure through the proof
- Verify all lemmas still compose correctly

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Restricted chains harder to build | Medium | Medium | May need to use restricted Lindenbaum |
| Closure formula propagation complex | Low | Low | Clear typing will enforce correctness |
| Completeness proof breaks | Low | High | Careful refactoring with continuous verification |

## Alternative: Mark Task BLOCKED

If refactoring is deemed too invasive, the task could be marked BLOCKED with the following note:

> The current formulation of `f_nesting_is_bounded` is mathematically unsound for arbitrary MCS. The claim only holds for RestrictedMCS (proved in Task 47). Resolving this requires either:
> 1. Refactoring succ_chain_fam to use RestrictedMCS (recommended)
> 2. Finding a different proof of F-coherence that doesn't use F-boundedness
>
> The completeness theorem remains semantically justified because the canonical model satisfies the frame conditions that ensure F-coherence.

## Files Involved

**Primary Files**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Contains the sorries
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Task 47's infrastructure
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Deferral seed construction

**Secondary Files** (may need updates):
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` - Truth lemma
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Completeness proof

## Task 47 Infrastructure Available

From `RestrictedMCS.lean`:
- `RestrictedMCS phi M` - MCS restricted to closureWithNeg(phi)
- `restricted_mcs_F_bounded` - F-depth bounded in RestrictedMCS
- `restricted_mcs_iter_F_bound` - Explicit bound for F-iterations
- `restricted_lindenbaum` - Build RestrictedMCS from consistent seed

From `CanonicalTaskRelation.lean`:
- `closure_F_bound phi` - The concrete bound value
- `iter_F_not_mem_closureWithNeg` - iter_F leaves closure at bound
- `iter_F_f_nesting_depth` - f_nesting_depth of iter_F

## Conclusion

The mathematically correct solution is **Approach A**: refactor the succ_chain_fam construction to use RestrictedMCS with the target formula's closure. This approach:

1. Is mathematically sound (proven in Task 47)
2. Reuses existing infrastructure
3. Has a clear implementation path
4. Maintains the structure of the completeness proof

The estimated effort is 6-8 hours for full implementation.

**Decision Required**: Should we proceed with the refactoring (Approach A), or mark the task BLOCKED pending a larger architectural decision about how to handle the completeness proof?
