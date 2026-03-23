# Research Report: Option A - Reformulate Completeness

**Task**: 46 - Prove Forward Chain P-Step
**Researcher**: Teammate A (math-research-agent)
**Focus**: Reformulating the completeness proof to avoid requiring forward chain p-step
**Date**: 2026-03-23

## Key Findings

### 1. The Dependency Chain

The sorry at `SuccChainFMCS.lean:350` blocks the completeness proof through this chain:

```
succ_chain_backward_P (line 1020)
    └─> succ_chain_canonicalTask_backward_MCS_P_from (line 1030)
            └─> succ_chain_fam_p_step (line 992)
                    └─> [SORRY at line 350 for forward chains n >= 0]
```

### 2. What P-Step Actually Does

The p-step property `p_content(successor) ⊆ u ∪ p_content(u)` is used by `CanonicalTask_backward_MCS_P` to establish:

- **`single_step_forcing_past`** (SuccRelation.lean:354): Given P(phi) in v, PP(phi) not in v, Succ u v, and p-step, proves phi in u
- **`backward_witness`** (CanonicalTaskRelation.lean:935): Generalizes single_step to n steps, proving phi membership at chain start

The p-step is needed because:
1. P(phi) in v means phi is in p_content(v)
2. p-step gives: phi in u OR phi in p_content(u) (i.e., P(phi) in u)
3. Combined with PP(phi) not in v propagating to P(phi) not in u, we eliminate the second case

### 3. Alternative Approach: CanonicalMCS Pattern

The `CanonicalFMCS.lean` module achieves `backward_P` WITHOUT p-step using a completely different approach:

```lean
-- CanonicalFMCS.lean:271-282
theorem canonicalMCS_backward_P (w : CanonicalMCS) (phi : Formula)
    (h_P : Formula.some_past phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, s ≤ w ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R_past, h_phi_W⟩ := canonical_backward_P w.world w.is_mcs phi h_P
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  have h_R : ExistsTask W w.world :=
    h_content_subset_implies_g_content_reverse w.world W w.is_mcs h_W_mcs h_R_past
  exact ⟨s, CanonicalMCS.le_of_canonicalR s w h_R, h_phi_W⟩
```

**Key insight**: `canonical_backward_P` constructs a witness MCS by extending `{psi} ∪ h_content(M)` via Lindenbaum. The witness is ANY MCS with the right h_content relationship, not necessarily a structurally-related predecessor.

### 4. Why This Works for CanonicalMCS but Not SuccChain

| Aspect | CanonicalMCS | SuccChainFMCS |
|--------|--------------|---------------|
| Domain | ALL MCSes | Integer-indexed chain |
| Witness origin | Any MCS via Lindenbaum | Must be in the chain |
| P-coherence | Trivial (witness exists by construction) | Requires p-step to locate witness |
| Ordering | Canonical relations (g_content/h_content) | Discrete integer indices |

SuccChainFMCS uses integers as indices, so when `P(phi)` is in `mcs(n)`, the witness must be at some `mcs(m)` with `m < n`. The proof must LOCATE this witness within the chain structure, which requires p-step to propagate the membership backward through the chain.

### 5. Reformulation Possibility Assessment

**Can we reformulate CanonicalTask_backward_MCS_P to only use backward chain p-step?**

**Answer: No, not directly.** The issue is that `succ_chain_backward_P` is called for ANY position `n` in the chain, including forward positions (n > 0). When `n > 0`:
- The witness might be at any `m < n`, including `m < 0` (backward chain territory)
- The chain traversal from `n` to `m` may cross from forward chain (where p-step is unproven) into backward chain (where p-step is proven)
- Even a single forward chain step in the traversal requires forward chain p-step

**However**, there IS a potential reformulation path:

### 6. Potential Reformulation: Transfer Pattern

The `FMCSTransfer.lean` module shows a pattern that DOES work:

```lean
-- FMCSTransfer.lean:305-312
theorem transfer_backward_P (T : FMCSTransfer D) (d : D) (phi : Formula)
    (h_P : Formula.some_past phi ∈ T.source.mcs d) :
    ∃ s : D, s ≤ d ∧ phi ∈ T.source.mcs s := by
  have h_P' := T.preserve_membership d _ h_P
  let W := T.retract d
  obtain ⟨s_can, h_le, h_phi⟩ := canonical_backward_P (T.retract d).world ...
  ...
```

The transfer approach:
1. Defines a retraction from any domain D to CanonicalMCS
2. Uses the sorry-free `canonical_backward_P` on CanonicalMCS
3. Transfers the result back to domain D

**This could work for SuccChainFMCS** if we:
1. Define an embedding from `Int` (SuccChainFMCS domain) to `CanonicalMCS`
2. Use `canonical_backward_P` for the witness
3. Map the witness back to an integer index

## Recommended Approach

**Option A is VIABLE with the following reformulation:**

Instead of proving p-step for forward chains structurally, use the **canonical model transfer pattern**:

1. **Define SuccChainToCanonical embedding**: Map `succ_chain_fam M0 n` to its underlying MCS in CanonicalMCS
2. **Use canonical_backward_P**: This is sorry-free and gives a witness MCS W with phi in W
3. **Find the integer index**: The witness W must be in the succ_chain_fam image (since succ_chain_fam covers all integers). Find the index m where `succ_chain_fam M0 m = W`
4. **Prove m < n**: From the h_content relationship

**Mathematical Trade-offs:**
- **Pro**: Eliminates need for forward chain p-step entirely
- **Pro**: Reuses existing sorry-free infrastructure
- **Con**: Requires proving the succ_chain_fam is surjective onto the relevant MCSes
- **Con**: Finding the index m requires a non-constructive choice or decidability assumptions

## Evidence/Examples

The key evidence that this reformulation is possible:

1. `canonical_backward_P` (CanonicalFrame.lean:170) is **sorry-free**
2. `canonicalMCS_backward_P` (CanonicalFMCS.lean:271) is **sorry-free**
3. `transfer_backward_P` (FMCSTransfer.lean:305) demonstrates the transfer pattern works
4. The backward chain p-step (`backward_chain_p_step` at SuccChainFMCS.lean:264) **works** because predecessor construction guarantees it

## Mathematical Trade-offs

| Approach | Pros | Cons |
|----------|------|------|
| Prove forward p-step (Option B) | Direct, matches existing structure | Requires new infrastructure for successor construction |
| Reformulate via transfer (Option A) | Uses existing sorry-free proofs | Requires surjectivity proof, non-constructive index finding |
| Weaken completeness (not recommended) | Simplest | Loses mathematical strength |

## Confidence Level

**Medium-High**

The reformulation is mathematically sound. The main uncertainty is implementation complexity:
- The transfer pattern exists and works (evidence: FMCSTransfer.lean)
- The witness existence is sorry-free (evidence: canonical_backward_P)
- The challenge is the "find integer index" step which requires either:
  - Proving succ_chain_fam bijectivity onto some canonical subset
  - Or showing the witness is constructively identifiable

## Summary

Option A (reformulation) IS viable. The recommended approach is to use the canonical model transfer pattern rather than trying to avoid p-step within the existing chain-based proof structure. This leverages the sorry-free `canonical_backward_P` and transfers results back to the integer-indexed domain.

The key insight: **Don't try to prove P-coherence structurally for forward chains. Instead, transfer to CanonicalMCS (where it's trivial), then transfer back.**
