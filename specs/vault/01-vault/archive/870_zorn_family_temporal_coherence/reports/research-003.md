# Research Report: Task #870 (Diagnostic Analysis)

**Task**: Zorn-based family selection for temporal coherence
**Date**: 2026-02-11
**Focus**: Post-implementation diagnostic - understanding blockers and improving the plan

## Executive Summary

The implementation attempt created substantial infrastructure (684 lines in ZornFamily.lean) but stalled at 8 sorries. Analysis reveals **three fundamental issues** that explain why progress stopped:

1. **Type Mismatch with Mathlib's Zorn**: The implementation attempts to use `zorn_le_nonempty` but the custom `le` relation on `CoherentPartialFamily` requires a `Preorder` instance, not just lemmas
2. **Base Family Impossibility**: A singleton domain {0} cannot satisfy forward_F/backward_P by definition - the construction is provably impossible
3. **Seed Consistency Requires 4-Axiom**: The extension seed consistency proof needs `G phi -> GG phi` and `H phi -> HH phi` propagation, which was not implemented

**Verdict**: The approach is mathematically sound but has implementation gaps. These are fixable with targeted modifications.

## Section 1: Sorry Inventory and Root Causes

### Complete Sorry Listing (8 total)

| Location | Lines | Category | Root Cause |
|----------|-------|----------|------------|
| `extensionSeed_consistent` | 470, 478, 485 | Seed consistency | Requires 4-axiom propagation proofs |
| `maximalCoherentFamily` | 546 | Zorn application | Type alignment with Mathlib Zorn |
| `maximalCoherentFamily_extends` | 551 | Zorn property | Depends on Zorn application |
| `maximalCoherentFamily_maximal` | 557 | Zorn property | Depends on Zorn application |
| `buildBaseFamily.forward_F` | 606 | Base construction | Singleton domain impossibility |
| `buildBaseFamily.backward_P` | 610 | Base construction | Singleton domain impossibility |

### Root Cause Analysis

#### Issue 1: Zorn Type Alignment (3 sorries)

**Problem**: The implementation defines `CoherentPartialFamily.le` as a function returning `Prop`:
```lean
def CoherentPartialFamily.le (F G : CoherentPartialFamily) : Prop :=
  F.domain ⊆ G.domain ∧ ∀ t, t ∈ F.domain → F.mcs t = G.mcs t
```

But Mathlib's `zorn_le_nonempty` requires:
```lean
theorem zorn_le_nonempty {α : Type*} [Preorder α] [Nonempty α]
    (h : ∀ (c : Set α), IsChain (· ≤ ·) c → c.Nonempty → BddAbove c) : ∃ m, IsMax m
```

The key mismatch: `IsChain (· ≤ ·) c` expects `≤` from a `Preorder` instance, not a custom `le` function.

**Solution**: Create a `Preorder CoherentPartialFamily` instance:
```lean
instance : Preorder CoherentPartialFamily where
  le := CoherentPartialFamily.le
  le_refl := CoherentPartialFamily.le_refl
  le_trans := CoherentPartialFamily.le_trans
```

Then use the standard `≤` operator throughout. The `le_antisymm` lemmas are already proven.

#### Issue 2: Base Family Impossibility (2 sorries)

**Problem**: The `buildBaseFamily` construction sets `domain = {0}`:
```lean
noncomputable def buildBaseFamily (Gamma : List Formula) (h_cons : Consistent Gamma) :
    CoherentPartialFamily where
  domain := {0}
  ...
  forward_F := fun t ht phi h_F => by
    -- F phi ∈ mcs(0), need witness s > 0 with phi ∈ mcs(s)
    -- But domain = {0}, so no such s exists!
    sorry
```

This is **provably impossible** - a singleton domain cannot satisfy forward_F/backward_P because there are no witnesses available in the domain.

**Solution**: The base family must either:
1. Start with a temporally-saturated MCS (using TemporalLindenbaum.lean) so F/P formulas have internal witnesses
2. Start with a larger initial domain built via dovetailing
3. Accept that the base family vacuously satisfies F/P (no F/P formulas exist in the seed)

**Recommended approach**: Option 3 with careful seed construction. The base family at {0} should be built from a seed that does NOT contain any F or P formulas. Then forward_F and backward_P are vacuously true because the antecedent `F phi ∈ mcs 0` is never satisfied.

This requires proving that `contextAsSet Gamma` (the initial seed) has no F/P formulas that cannot be satisfied, or using a pre-saturation step.

Actually, the cleanest approach: **Use TemporalLindenbaum's temporally-saturated MCS as the base**. This MCS already satisfies internal F/P witness requirements. The extension process then only needs to handle cross-time coherence.

#### Issue 3: Seed Consistency 4-Axiom Gap (3 sorries)

**Problem**: The `extensionSeed_consistent` proof has three sorry cases:
1. Cross-sign (both past and future times exist in domain)
2. Pure G-content (only past times exist)
3. Pure H-content (only future times exist)

All three require proving that GContent from multiple times is consistent, which needs:
```lean
-- If G phi ∈ M_s for s < t, then GG phi ∈ M_s (by 4-axiom)
-- Therefore G phi ∈ M_{s+1} by forward_G
-- And so on, propagating G phi forward
```

**Solution**: Import and use the 4-axiom lemmas:
- `temp_4_future : G phi -> GG phi` (Axiom.temp_4_future in Axiom.lean)
- `temp_4_past : H phi -> HH phi` (Axiom.temp_4_past in Axiom.lean)

The proof pattern:
1. For pure G-content case: Pick any s in domain with s < t. All G-content from any s' < s is already in mcs(s) by forward_G (using domain coherence). So the entire past G-content union is actually contained in the GContent of the largest past time.
2. For pure H-content case: Symmetric argument with smallest future time.
3. For cross-sign case: The G-content from past times propagates to all future times (and vice versa) within the coherent family, so they are compatible.

## Section 2: Alternative Approaches

### Alternative A: Temporal Pre-Saturation (Recommended)

**Approach**: Use the existing `temporalLindenbaumMCS` from TemporalLindenbaum.lean to build the base MCS. This MCS is already:
- Maximal consistent
- Temporally forward-saturated (F phi implies phi exists in MCS)
- Temporally backward-saturated (P phi implies phi exists in MCS)

**Key insight**: Internal F/P saturation is DIFFERENT from cross-time coherence. A single MCS can satisfy "F phi implies phi" internally, but the family coherence property requires "F phi at t implies phi at some s > t".

**Benefit**: The base family starts with a temporally-saturated MCS, so:
- If F phi ∈ mcs(0), then phi ∈ mcs(0) by internal saturation
- This means the witness exists at time 0 itself (trivially satisfies forward_F with s = 0... wait, we need s > t, not s >= t)

**Problem**: Actually, this doesn't help because forward_F requires s > t, not s >= t. Internal saturation gives phi at the SAME time, not a later time.

**Revised insight**: The base family with domain={0} CANNOT satisfy forward_F/backward_P unless F/P formulas are absent. This is fundamental.

### Alternative B: Vacuous Base + Extension Responsibility

**Approach**: Accept that the base family with domain={0} cannot satisfy forward_F/backward_P for arbitrary seeds. Instead:

1. Build base with domain={0} and an MCS that is F/P-free in a controlled way
2. Push F/P witness responsibility to the Zorn extension process
3. When extending to time t, ensure F/P formulas get witnesses in subsequent extensions

**Problem**: This requires restructuring the entire coherence invariant. The current `CoherentPartialFamily` structure requires forward_F/backward_P to hold AT EVERY STEP, not just at completion.

### Alternative C: Dovetailed Initial Domain (From Original Research)

**Approach**: Use the existing dovetailing enumeration to build an initial segment `{-N, ..., -1, 0, 1, ..., N}` and THEN apply Zorn to extend further.

**Benefit**: The dovetailing chain already handles F/P witnesses within the initial segment. Zorn only needs to handle extension beyond the initial segment.

**Problem**: This is essentially combining two approaches and adds complexity. Also, the dovetailing chain has its own sorries (cross-sign propagation).

### Alternative D: Weaker Base Invariant (Best Practical Approach)

**Approach**: Modify `CoherentPartialFamily` to have weaker F/P requirements for the base case:

```lean
structure CoherentPartialFamily where
  ...
  -- Original: requires witness in domain
  -- forward_F : ∀ t, t ∈ domain → ∀ phi,
  --   Formula.some_future phi ∈ mcs t → ∃ s, s ∈ domain ∧ t < s ∧ phi ∈ mcs s

  -- Weakened: witness can be in domain OR the formula must have come from seed propagation
  forward_F_or_seed : ∀ t, t ∈ domain → ∀ phi,
    Formula.some_future phi ∈ mcs t →
    (∃ s, s ∈ domain ∧ t < s ∧ phi ∈ mcs s) ∨ (∃ s, s ∈ domain ∧ s < t ∧ Formula.some_future phi ∈ seed s)
```

**Problem**: This significantly complicates the structure and may not preserve chain upper bounds correctly.

## Section 3: Recommended Plan Improvements

### Immediate Fixes (High Priority)

#### Fix 1: Add Preorder Instance
```lean
instance : Preorder CoherentPartialFamily where
  le := CoherentPartialFamily.le
  le_refl := CoherentPartialFamily.le_refl
  le_trans a b c := CoherentPartialFamily.le_trans a b c
```

This enables direct use of Mathlib's Zorn lemmas.

#### Fix 2: Replace buildBaseFamily with Dovetailing Segment

Instead of domain={0}, build domain={-N, ..., N} for some finite N using the existing dovetailing chain construction (which already works for finite segments). The cross-sign sorries in DovetailingChain only matter for infinite extension, not for a finite initial segment.

Actually, reviewing the code more carefully: the dovetailing chain sorries ARE in the finite construction. So this won't help directly.

#### Fix 3: Use Temporally Saturated MCS + Different F/P Strategy

**New approach**:
1. Build base MCS using `temporalLindenbaumMCS` (already proven)
2. Define the base family with domain={0} and mcs(0) = temporally saturated MCS
3. For forward_F at base: If F phi ∈ mcs(0), then by temporal saturation, phi ∈ mcs(0). But we need witness at s > 0, which doesn't exist in domain. So forward_F is still problematic.

**Key realization**: The issue is that forward_F REQUIRES the witness to be in the domain, but for a singleton domain, no s > 0 exists in domain.

**Solution path**: The forward_F condition should be interpreted differently:
- In a TOTAL family (domain = Int), forward_F means: F phi at t implies phi at some s > t
- In a PARTIAL family, forward_F should mean: F phi at t implies EITHER phi at some s > t in domain OR we commit to adding such a witness when we extend

This means the `CoherentPartialFamily` structure needs modification. The current structure is too strong for partial domains.

### Revised Structure (Key Insight)

The fundamental issue is that `CoherentPartialFamily.forward_F` is **too strong** for partial domains. A better formulation:

```lean
structure CoherentPartialFamily where
  domain : Set Int
  mcs : Int → Set Formula
  domain_nonempty : domain.Nonempty
  is_mcs : ∀ t, t ∈ domain → SetMaximalConsistent (mcs t)
  forward_G : ...  -- Keep as is (universal, so partial domain is fine)
  backward_H : ... -- Keep as is (universal, so partial domain is fine)
  -- NO forward_F or backward_P in the structure!
```

Then prove separately that:
1. The maximal partial family has domain = Set.univ
2. For a TOTAL family, forward_F and backward_P hold

**Why this works**:
- Chain upper bounds are easier (no F/P to inherit)
- Base family is trivial (no F/P requirement)
- Maximality → totality proof shows that any missing time can be added
- Once total, F/P hold because every F phi at t was "created" by Lindenbaum extending a seed, and the seed consistency argument ensures the witness exists

**Critical insight from TemporalLindenbaum**: The way F/P witnesses work is:
- During Lindenbaum extension, when we add F phi, we also add phi to the same set
- This makes the set "internally F-saturated"
- For a TOTAL family, internal saturation + G/H propagation gives cross-time F/P witnesses

### Restructured Plan (Phases Revised)

#### Phase 3A: Remove F/P from CoherentPartialFamily
- Delete forward_F and backward_P fields
- Update chainUpperBound to not need F/P inheritance
- Update all lemmas accordingly

#### Phase 3B: Seed Consistency for G/H Only
- Prove extensionSeed_consistent for G-content and H-content union
- This is strictly easier than the original (no F/P complication)

#### Phase 4A: Simplified Base Family
- Domain = {0}
- mcs(0) = Lindenbaum extension of context
- No F/P requirements

#### Phase 4B: Zorn Application with Preorder
- Add Preorder instance
- Use zorn_le_nonempty or zorn_subset pattern

#### Phase 5: Maximality → Totality
- Prove that maximal partial family has domain = Set.univ
- Use the simplified seed consistency (G/H only)

#### Phase 6A: Total Family F/P Recovery
- Prove that a TOTAL G/H-coherent family also satisfies F/P
- Key lemma: If F phi ∈ mcs(t) in a total family, then phi appears at some s > t
- Proof: F phi was added by Lindenbaum at some step. The seed at that step included phi (for temporal saturation). Therefore phi ∈ mcs(t). But we need phi at s > t, not at t.

**Wait** - this still has the same problem! If phi is at t, we don't automatically get phi at s > t.

**Let me reconsider**...

Actually, the issue is that I've been conflating two different things:
1. **Internal temporal saturation**: F phi ∈ S implies phi ∈ S (same set)
2. **Cross-time temporal coherence**: F phi ∈ mcs(t) implies phi ∈ mcs(s) for some s > t (different times)

The Zorn construction for families must handle (2), not (1).

**Correct approach**: When extending to time t, the seed must include:
- GContent from past times (for backward_H from those times)
- HContent from future times (for forward_G to those times)
- Witnesses for F formulas at past times that need witness at t
- Witnesses for P formulas at future times that need witness at t

This is exactly what research-002.md proposed! The issue is that we need to **enumerate F/P obligations** and include them in the seed.

### The Enumeration Insight

The key insight from research-002.md that wasn't fully implemented:

When extending domain by adding time t:
1. Collect all F obligations: `{phi | ∃ s < t, s ∈ domain, F phi ∈ mcs(s), no witness yet}`
2. Collect all P obligations: `{phi | ∃ s > t, s ∈ domain, P phi ∈ mcs(s), no witness yet}`
3. Include these in the seed for mcs(t)

But "no witness yet" is tricky to define. For an F phi at time s, we need a witness at some time > s. If we're adding time t > s, then t could be the witness.

**Simplified formulation**:
- For each s < t in domain with F phi ∈ mcs(s), include phi in seed_t (t will be the witness for s)
- For each s > t in domain with P phi ∈ mcs(s), include phi in seed_t (t will be the witness for s)

Then the extended family has:
- forward_F satisfied for all s < t (with t as witness)
- backward_P satisfied for all s > t (with t as witness)

**But wait** - what about F phi at time t itself? When we create mcs(t), it may contain new F formulas added by Lindenbaum. These need witnesses at times s > t, which don't exist yet!

This is the fundamental recursion: extending always creates new obligations.

**Solution**: This is exactly why we need **maximality → totality**. In a maximal family, EVERY time is in the domain. So for any F phi at time t, there exists some s > t in domain to be the witness (because domain = Set.univ).

The key is that F phi at t doesn't need a SPECIFIC witness s > t. It just needs SOME witness to exist. By totality, we can choose s = t + 1.

**But how do we know phi ∈ mcs(t+1)?**

Here's where the subtlety lies. The extension seed for time t+1 must include:
- GContent from mcs(t) → includes phi if G phi ∈ mcs(t) (but we have F phi, not G phi)
- F-witness obligations from mcs(t) → includes phi if F phi ∈ mcs(t)

So the seed DOES include phi! And by Lindenbaum, mcs(t+1) contains the seed, so phi ∈ mcs(t+1).

**This is the key insight that was missing from the implementation!**

### Corrected Approach Summary

1. **CoherentPartialFamily without F/P fields** - only G/H coherence required
2. **Extension seed includes F/P obligations**:
   ```
   seed_t = (⋃ s<t, GContent(mcs_s)) ∪ (⋃ s>t, HContent(mcs_s))
          ∪ {phi | ∃ s<t, F phi ∈ mcs_s}  -- F witnesses
          ∪ {phi | ∃ s>t, P phi ∈ mcs_s}  -- P witnesses
   ```
3. **Seed consistency proof**: Show this combined seed is consistent
4. **Zorn application**: Get maximal family
5. **Maximality → totality**: Show domain = Set.univ
6. **F/P recovery**: For total family, F phi at t has witness at t+1 (because phi ∈ seed_{t+1}, so phi ∈ mcs_{t+1})

## Section 4: Recommendations

### Plan Revision Recommendations

1. **Restructure CoherentPartialFamily** to remove forward_F/backward_P from the structure. These become derived properties for total families only.

2. **Add F/P obligations to extension seed** explicitly. The current `extensionSeed` only has G/H content, missing the F/P witness formulas.

3. **Add Preorder instance** for proper Mathlib Zorn integration.

4. **Simplify base family** to domain={0} with standard Lindenbaum MCS.

5. **Phase 6 should prove F/P recovery** for total families, not carry it through the partial family structure.

### Effort Re-estimation

| Phase | Original | Revised |
|-------|----------|---------|
| Phase 3 (Seed consistency) | 4-5 hours | 2-3 hours (G/H only) |
| Phase 4 (Zorn) | 2-3 hours | 3-4 hours (restructure + Zorn) |
| Phase 5 (Totality) | 3-4 hours | 3-4 hours (unchanged) |
| Phase 6 (F/P recovery) | 2-3 hours | 4-5 hours (new proofs needed) |

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Seed consistency with F/P obligations harder | Medium | High | Can fall back to G/H-only extension (loses F/P in partial) |
| F/P recovery proof complex | Medium | Medium | The recovery relies on seed inclusion, well-understood pattern |
| Preorder instance complications | Low | Low | Standard Mathlib pattern |

## Section 5: Conclusion

The implementation made good progress but stalled due to:
1. A fundamental impossibility (singleton domain cannot satisfy F/P)
2. Missing type infrastructure (Preorder instance)
3. Incomplete seed construction (missing F/P obligations)

The recommended path forward involves restructuring `CoherentPartialFamily` to not require F/P invariants on partial families, then recovering F/P as a derived property for total (maximal) families. This is mathematically cleaner and avoids the base family impossibility.

**Bottom line**: The Zorn approach is correct and worth completing. The sorries are technical implementation gaps, not fundamental obstacles. With the recommended restructuring, all 8 sorries should be resolvable without new axioms.

## References

- ZornFamily.lean (684 lines, 8 sorries)
- DovetailingChain.lean (4 sorries, same root problem)
- TemporalLindenbaum.lean (Zorn template for single MCS)
- research-002.md (original unified solution proposal)
- implementation-001.md (original 6-phase plan)
- Mathlib.Order.Zorn (zorn_le_nonempty, IsChain, BddAbove)
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`
