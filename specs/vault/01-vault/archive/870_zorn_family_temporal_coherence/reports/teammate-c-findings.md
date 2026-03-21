# Teammate C: ExtendFamily Alternative Approaches

**Task**: 870 - Zorn-based family selection for temporal coherence
**File**: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
**Date**: 2026-02-11
**Analyst**: lean-research-agent (teammate-c)

## The Core Problem

### Problem Statement

The `extendFamily` function has two sorries at lines 1311 and 1342 that represent a fundamental challenge in the Zorn construction:

**Line 1311 (forward_G from new time t)**:
```
Goal: phi ∈ F.mcs s'
Given:
- s = t (the newly added time)
- s' > t is an OLD time (s' ∈ F.domain)
- G phi ∈ mcs_t (the new MCS at time t)
```

**Line 1342 (backward_H from new time t)**:
```
Goal: phi ∈ F.mcs s'
Given:
- s = t (the newly added time)
- s' < t is an OLD time (s' ∈ F.domain)
- H phi ∈ mcs_t
```

### Why This Is Hard

The crux of the problem is **provenance tracking through Lindenbaum extension**:

1. `mcs_t` is created by `set_lindenbaum (extensionSeed F t) h_seed_cons`
2. Lindenbaum adds formulas to make the set maximal consistent
3. If `G phi ∈ mcs_t`, it could have come from:
   - **Case A**: The seed (we can trace this!)
   - **Case B**: Lindenbaum's maximality construction (we cannot easily trace this)

For Case B, we have no a priori reason why `phi` should be in `F.mcs s'` for an old time `s' > t`. The Lindenbaum process adds formulas based on consistency alone, not based on respecting temporal coherence with the EXISTING family structure.

### The Structural Issue

The extension seed includes:
- `GContent` from past times (phi if G phi in some past MCS)
- `HContent` from future times (phi if H phi in some future MCS)
- `FObligations` (phi if F phi in some past MCS - needs witness at t)
- `PObligations` (phi if P phi in some future MCS - needs witness at t)

But the seed does NOT include:
- Formulas that would make `G phi ∈ mcs_t` imply `phi ∈ F.mcs s'` for future s'
- The seed is designed for propagation INTO t, not FROM t to existing times

## Alternative Approach 1: Constrained Lindenbaum Extension

### Description

Instead of using standard `set_lindenbaum`, create a specialized extension that respects temporal constraints:

```lean
def temporalConstrainedLindenbaum (seed : Set Formula) (F : GHCoherentPartialFamily) (t : Int)
    (h_seed_cons : SetConsistent seed) :
    ∃ M, seed ⊆ M ∧ SetMaximalConsistent M ∧
        (∀ phi, Formula.all_future phi ∈ M → ∀ s' > t, s' ∈ F.domain → phi ∈ F.mcs s') ∧
        (∀ phi, Formula.all_past phi ∈ M → ∀ s' < t, s' ∈ F.domain → phi ∈ F.mcs s')
```

### Feasibility Analysis

**Challenges**:
- This requires modifying the Lindenbaum construction itself
- The enumeration process would need to check each formula against ALL existing MCS in F
- This is NOT how Lindenbaum works - it's purely based on local consistency

**Assessment**: **Low feasibility**. This would require a fundamentally different Lindenbaum lemma that is not standard in the literature and would be substantial new mathematics to prove.

## Alternative Approach 2: Bi-Directional Seed Enrichment

### Description

Enrich the seed to include not just what must be IN `mcs_t`, but also what must be ABSENT from `mcs_t` to preserve coherence:

```lean
def enrichedExtensionSeed (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  extensionSeed F t ∪
  -- Add: For each s' > t in domain, for each phi with phi ∉ F.mcs s', add ¬(G phi)
  { (Formula.all_future phi).neg | s' ∈ F.domain ∧ t < s' ∧ phi ∉ F.mcs s' }
```

The idea: If phi is NOT in F.mcs s' for some future s', then G phi cannot be in mcs_t (by contrapositive of forward_G).

### Feasibility Analysis

**Challenges**:
- Requires quantifying over all formulas NOT in various MCS
- This is a potentially infinite set of constraints
- Seed consistency becomes extremely difficult to prove

**Assessment**: **Medium-low feasibility**. The approach is mathematically sound but operationally impractical due to infinite constraint sets.

## Alternative Approach 3: Weaken forward_G/backward_H Requirements

### Description

Modify the coherence conditions to only require propagation where it can be guaranteed:

```lean
-- Old: forward_G : ∀ t t', t ∈ domain → t' ∈ domain → t < t' →
--        ∀ phi, G phi ∈ mcs t → phi ∈ mcs t'

-- New: forward_G restricted to "inherited" G formulas
forward_G : ∀ t t', t ∈ domain → t' ∈ domain → t < t' →
    ∀ phi, G phi ∈ mcs t →
    -- Only require propagation if G phi came from the extension seed chain
    (∃ s ≤ t, s ∈ domain ∧ G phi ∈ extensionSeed_at_s) →
    phi ∈ mcs t'
```

### Feasibility Analysis

**Challenges**:
- Changes the meaning of GH-coherence
- May break downstream proofs that rely on full forward_G
- Requires tracking "provenance" of formulas in MCS (computationally expensive)

**Assessment**: **Medium feasibility** but significant proof restructuring required. This weakens the invariant, which may not be acceptable for the final theorem.

## Alternative Approach 4: Domain-Restricted Extension (Recommended)

### Description

Instead of adding an arbitrary new time t to an arbitrary family F, restrict extensions to maintain an invariant that makes forward_G/backward_H provable:

**Key Insight**: The problem only occurs when `t` is inserted BETWEEN existing domain elements. If we always extend at the "boundary" (adding the next integer outside the current domain), the problematic cases don't arise.

```lean
-- Only extend at boundary times
def canExtendAt (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧
  (∀ s ∈ F.domain, s < t) ∨ (∀ s ∈ F.domain, t < s)
```

For boundary extension:
- If t > all domain elements: No s' > t exists in domain, so forward_G from t is vacuously true
- If t < all domain elements: No s' < t exists in domain, so backward_H from t is vacuously true

### Feasibility Analysis

**Advantages**:
- Eliminates the problematic cases entirely
- Extension becomes much simpler
- Preserves full forward_G/backward_H semantics

**Challenges**:
- Requires restructuring Zorn argument to build domain in a specific order
- Need to prove maximality still implies totality with this restriction
- The current `maximal_implies_total` proof tries to add arbitrary missing t

**Assessment**: **High feasibility** with significant restructuring of the maximality argument.

### Implementation Sketch

1. Redefine `CoherentExtensions` to only include families that extend at boundaries
2. Show chains have upper bounds (unchanged - chain unions work fine)
3. Show maximality implies totality:
   - Current approach: "If t is missing, add it" - this fails because of boundary requirement
   - New approach: Build domain incrementally as {..., -2, -1, 0, 1, 2, ...}
   - Use well-ordering on Int gaps: If domain misses t, there's a boundary gap adjacent to the domain that can be filled first

## Alternative Approach 5: Two-Phase Construction

### Description

Split the construction into two phases:

**Phase A**: Build a "skeleton" family with finitely many times using dovetailing (already works for cross-sign within the finite domain).

**Phase B**: Use Zorn to extend the skeleton, but with the insight that ALL extensions add times OUTSIDE the skeleton's domain.

```lean
-- Phase A: Build {-N, ..., 0, ..., N} using DovetailingChain
let skeleton := buildDovetailingChainFamily_truncated Gamma h_cons N

-- Phase B: Extend skeleton using Zorn with boundary-only extensions
let maximal := zornBoundaryExtension skeleton
```

### Feasibility Analysis

**Advantages**:
- Leverages existing DovetailingChain infrastructure
- Phase B extensions are always at boundaries (no cross-sign issues)
- Combines best of both approaches

**Challenges**:
- DovetailingChain has its own sorries for cross-sign propagation
- Need to prove the truncated family is coherent
- Interface between phases requires careful design

**Assessment**: **Medium-high feasibility**. This is essentially the same as Approach 4 but with a specific implementation strategy.

## Alternative Approach 6: Accept Sorry as Axiomatic (Not Recommended)

### Description

Document the sorries as axiomatic assumptions and move forward. The key insight is that these sorries are about a specific construction detail, not about the mathematical truth of the theorem.

### Feasibility Analysis

**Why this is not recommended**:
- Per proof-debt-policy.md, sorries are technical debt requiring documentation
- These sorries block transitive sorry-freedom of dependent theorems
- The mathematical claim (temporal coherent families exist) should be provable structurally

**Assessment**: **High feasibility** (trivial to implement) but **not acceptable** per project standards.

## Recommended Direction

### Primary Recommendation: Approach 4 (Domain-Restricted Extension)

**Rationale**:
1. Mathematically cleanest solution - no weakening of invariants
2. The sorries disappear because the problematic cases don't occur
3. Requires restructuring but not new mathematical lemmas
4. Aligns with the insight that Zorn builds "outward" from the base

### Implementation Strategy

1. **Modify extension to be boundary-only**:
   - Add predicate `isBoundaryTime F t`
   - Modify `extendFamily` to require boundary condition
   - The forward_G and backward_H fields become trivial (vacuous for boundary extensions)

2. **Restructure maximality argument**:
   - Current: "If t missing, add t" - FAILS because t might not be boundary
   - New: "If t missing, there exists a boundary time between domain and t that can be added first"
   - Prove by well-ordering: gaps in Int have boundary points

3. **Prove boundary extension preserves coherence**:
   - Forward_G from new t: vacuous (no s' > t in domain by boundary assumption)
   - Backward_H from new t: vacuous (no s' < t in domain by boundary assumption)
   - Forward_G to new t: covered by h_forward_G hypothesis (already proven)
   - Backward_H to new t: covered by h_backward_H hypothesis (already proven)

### Alternative if Primary Fails: Approach 5 (Two-Phase Construction)

If boundary-only extension proves difficult, fall back to:
1. Use existing DovetailingChain to build initial segment
2. Apply Zorn only for extension beyond the initial segment
3. Accept that DovetailingChain sorries remain but are localized

## Required Changes

### For Approach 4 (Recommended)

1. **Add boundary predicate** (~20 lines):
```lean
def isBoundaryTime (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ((∀ s ∈ F.domain, s < t) ∨ (∀ s ∈ F.domain, t < s))
```

2. **Modify extendFamily signature** (~5 lines changed):
```lean
def extendFamily (F : GHCoherentPartialFamily) (t : Int)
    (ht : t ∉ F.domain) (h_boundary : isBoundaryTime F t) ...
```

3. **Simplify forward_G and backward_H proofs** (~50 lines removed):
   - The problematic cases (s = t, s' ∈ F.domain, t < s' or s' < t) become impossible
   - Proof becomes: `exact absurd hs'_old (h_boundary.2.elim (fun h => ...) (fun h => ...))`

4. **Restructure maximal_implies_total** (~100 lines rewritten):
   - Change from "add any missing t" to "add boundary time adjacent to gap"
   - Requires new lemma: every non-total domain has a boundary time

5. **Update chainUpperBound if needed** (~20 lines):
   - Verify chain unions of boundary-extended families are still boundary-extendable

### Estimated Effort

| Change | Lines | Difficulty |
|--------|-------|------------|
| Add boundary predicate | 20 | Easy |
| Modify extendFamily | 50 | Medium |
| Simplify forward_G/backward_H | -50 (deletion) | Easy |
| Restructure maximal_implies_total | 100 | Hard |
| Verification and testing | 50 | Medium |
| **Total** | ~170 net new lines | Medium-hard |

## Conclusion

The core problem is that standard Lindenbaum extension doesn't preserve temporal coherence "backward" to existing times. The recommended solution is to restructure the Zorn construction to only extend at boundary times, eliminating the problematic cases entirely. This is a structural change requiring ~170 lines of new/modified code, primarily in the maximality-implies-totality argument.

## References

- ZornFamily.lean lines 1294-1360 (extendFamily definition)
- Goal state at line 1311: `phi ∈ F.mcs s'` given `G phi ∈ mcs_t`, `s' > t`, `s' ∈ F.domain`
- research-003.md Section 3: Original insight about F/P impossibility for singleton domains
- proof-debt-policy.md: Sorries are technical debt, not acceptable architectural features
- Mathlib `zorn_le_nonempty₀`: Zorn lemma used in current construction
