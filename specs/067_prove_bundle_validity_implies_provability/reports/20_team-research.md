# Research Report: Task #67 — Blocker Analysis for bundle_validity_implies_provability

**Task**: 67 — prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Mode**: Team Research (2 teammates)
**Session**: sess_1774772143_d8f232

## Summary

Two research agents investigated the remaining blocker from complementary perspectives: semantic/model-theoretic (Teammate A) and algebraic/structural (Teammate B). A critical factual conflict was resolved: the deferralClosure extension from Phases 1-2 already includes F_top via `serialityFormulas` — the actual blocker is the **fuel exhaustion sorry** in `restricted_bounded_witness_fueled` and the **family-level temporal coherence gap**.

## Key Findings

### 1. The True Root Cause: Bundle-Level vs Family-Level Coherence

Both teammates independently confirmed the fundamental structural gap:

- **Bundle-level coherence** (sorry-free): For F(psi) in fam.mcs(t), there exists some fam' in the bundle and s > t with psi ∈ fam'.mcs(s). Proved in `construct_bfmcs_bundle` (UltrafilterChain.lean:2853).

- **Family-level coherence** (blocked): For F(psi) in fam.mcs(t), there exists s > t with psi ∈ fam.mcs(s) — witness in the SAME chain/family. Required by the truth lemma (ParametricTruthLemma.lean) because G/H backward cases need same-chain witnesses.

The truth lemma is inherently bidirectional: the `imp` forward case invokes backward IH, and G/H backward cases require `forward_F`/`backward_P` at family level.

### 2. The Omega Chain Only Resolves F_top

The `omega_chain_forward_with_inv` construction (UltrafilterChain.lean:2027-2045) resolves exactly ONE F-obligation at each step: F_top (i.e., F(neg bot)). If F(phi) for arbitrary phi is in Z_chain(t), the construction provides no guarantee that phi will appear at any future position in the same chain.

This is a **design limitation**, not a bug. The construction advances by seriality witnesses only.

### 3. Corrected Blocker Identification

**Previous reports (09, 10) incorrectly identified**: F_top ∉ deferralClosure(phi) as the blocker.

**Current state** (after Phases 1-2 of Plan 05): F_top IS in deferralClosure for all phi:
```lean
-- SubformulaClosure.lean:695
def deferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas

-- SubformulaClosure.lean:744
theorem F_top_mem_deferralClosure (phi : Formula) : F_top ∈ deferralClosure phi
```

**Actual blocker**: The sorry in `restricted_bounded_witness_fueled` (SuccChainFMCS.lean:~2797) in the fuel=0 branch. This function uses fuel for Lean termination checking, and the fuel=0 branch has a sorry because proving it unreachable requires a termination argument showing B*B+1 fuel always suffices.

### 4. Standard Textbook Approaches

**Flat canonical model** (Blackburn, de Rijke, Venema): Uses an Existence Lemma where witnesses can be ANY MCS — not constrained to a chain. This works for Kripke semantics but NOT for bundle semantics where G/H quantify along a single history.

**Henkin-style fair scheduling** (Segerberg 1970 "bulldozing"): Enumerates ALL F-obligations in a priority queue, resolving the highest-priority pending obligation at each step. Fair scheduling guarantees every obligation is eventually resolved. This is the mathematically correct approach for linear temporal logic with bundle semantics.

## Synthesis

### Conflict Resolved

| Point | Teammate A (Semantic) | Teammate B (Algebraic) | Resolution |
|-------|----------------------|----------------------|------------|
| F_top in deferralClosure? | Claims NO for general phi | Correctly shows YES (serialityFormulas) | **Teammate B correct**: Phases 1-2 already fixed this |
| Root cause | Z-chain design mismatch | Fuel exhaustion sorry | **Both partially right**: Design mismatch is the deep cause; fuel exhaustion is the proximate sorry |
| Recommended approach | Extend deferralClosure (already done) | Prove fuel=0 unreachable | **Both contribute**: Extension is done; fuel proof is the next step |

### Approaches Ranked by Elegance and Correctness

#### Approach 1: Prove Fuel=0 Unreachable (Most Direct)

Show that with fuel = B*B+1 where B = closure_F_bound(phi), the fuel=0 branch of `restricted_bounded_witness_fueled` is never reached.

**Required argument**: Each recursive call either:
- Decreases F-nesting depth (resolved case), or
- Advances position while maintaining depth bound (deferred case)

Total calls bounded by B^2. Lexicographic measure on (B - current_depth, fuel) is well-founded.

**Pros**: Minimal code changes, works within existing infrastructure
**Cons**: Requires careful termination reasoning

#### Approach 2: Restructure with Well-Founded Recursion (Most Elegant)

Replace the fuel-based recursion with well-founded recursion using a proper measure:

```lean
-- Instead of fuel parameter:
def restricted_bounded_witness (phi chi : Formula)
    (h_F : F chi ∈ deferralClosure phi)
    (start : DeferralRestrictedSerialMCS phi)
    (h_F_in : F chi ∈ start.world) :
    { k : Nat // chi ∈ (restricted_chain start k).world } :=
  -- Use WellFoundedRelation on (f_nesting_depth chi, steps)
  ...
```

**Pros**: No fuel parameter, no unreachability proof needed
**Cons**: Significant refactoring of SuccChainFMCS.lean

#### Approach 3: Proper Dovetailing / Fair Scheduling (Most Mathematically Correct)

Replace `omega_chain_forward` to enumerate and resolve ALL F-obligations round-robin, not just F_top.

**Implementation**: Use `Nat.pair`/`Nat.unpair` for enumeration, maintain resolved-obligation set.

**Pros**: Follows textbook approach exactly, provides full family-level coherence
**Cons**: Major refactoring of UltrafilterChain.lean, high complexity

#### Approach 4: Zorn's Lemma (Non-Constructive)

Use Zorn's lemma on the poset of partial temporally-coherent FMCS to obtain a maximal element.

**Pros**: Conceptually clean
**Cons**: Non-constructive, harder to formalize, novel approach without textbook precedent

### Gaps Identified

1. **No analysis of the exact recursion structure** of `restricted_bounded_witness_fueled` — needed to determine if Approach 1 is tractable
2. **No investigation of whether the `restricted_forward_chain_forward_F` (sorry-free) already provides the needed witness** — this theorem exists and is sorry-free, suggesting the infrastructure may already be in place
3. **Unclear whether `bfmcs_from_mcs_temporally_coherent` can be proved using existing sorry-free lemmas** after the deferralClosure extension

### Recommendations

**Immediate next step**: Investigate `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:~2887). Teammate B noted it is sorry-free and already proves F-obligation resolution within the restricted chain. If this theorem provides what `bfmcs_from_mcs_temporally_coherent` needs, the sorry can be eliminated without new construction.

**If that fails**: Pursue Approach 1 (prove fuel=0 unreachable) or Approach 2 (well-founded recursion). Approach 2 is more elegant but higher effort.

**Do not pursue**: Approach 3 (dovetailing) unless Approaches 1-2 both fail — the restricted chain infrastructure is already largely in place.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A (mathematician) | Semantic/model-theoretic | completed | HIGH | Textbook comparison, bundle vs flat canonical models |
| B (algebraist) | Algebraic/structural | completed | HIGH | Corrected F_top status, identified fuel=0 as actual sorry |

## References

- Blackburn, de Rijke, Venema "Modal Logic" Ch. 4 — Existence Lemma for flat canonical models
- Goldblatt "Logics of Time and Computation" — Temporal completeness
- Segerberg 1970 "bulldozing" technique — Fair scheduling for temporal obligations
- Team research reports 09, 10 — Prior analysis (note: F_top blocker now resolved)
