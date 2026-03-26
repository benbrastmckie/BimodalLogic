# Research Report: Task #58 (Wave 60 - Comprehensive Review)

**Task**: Wire completeness to FrameConditions
**Date**: 2026-03-26
**Mode**: Team Research (2 teammates)
**Session**: sess_1774566166_fb7902

## Executive Summary

After 60 research waves and a spawned subtask (65), we now have clarity on what paths are blocked and what remains viable:

**Dead Ends (5 definitively blocked)**:
1. Omega-enumeration for arbitrary MCS (F-nesting unbounded)
2. Bundle-level coherence substituting for family-level (mathematically impossible)
3. Forward-only truth lemma (imp case requires backward IH)
4. Algebraic bypass of truth lemma (proves different theorem)
5. Extended witness with GH-intersection (H-theory not G-liftable)

**Critical Discovery**: The "omega-enumeration construction" (`omegaClassFamilies_temporally_coherent`) **does not exist**. It appears only in deprecation strings but was never implemented.

**Viable Path**: Fix 3 sorries in `RestrictedTruthLemma.lean` (G/H propagation in DRM chains), then build TaskModel from `RestrictedTemporallyCoherentFamily` which already provides family-level coherence.

## Synthesis: What We Know Now

### The Core Mathematical Obstacle

The `shifted_truth_lemma` (CanonicalConstruction.lean:648) requires **family-level** temporal coherence:
```lean
F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s  -- SAME family
```

But `construct_bfmcs_bundle` (sorry-free) only provides **bundle-level** coherence:
```lean
F(phi) in fam.mcs t -> exists fam' in bundle, exists s > t, phi in fam'.mcs s  -- ANY family
```

The backward G case in `temporal_backward_G` (TemporalCoherence.lean:165-178) requires **same-family** witnesses for the contradiction:
1. Assume G(phi) not in fam.mcs t
2. MCS maximality: F(neg(phi)) in fam.mcs t
3. Family-level forward_F: neg(phi) in **fam.mcs s** (same family)
4. Hypothesis: phi in fam.mcs s (same family, same time)
5. Contradiction: both phi and neg(phi) in fam.mcs s

With bundle-level coherence, step 3 gives neg(phi) in **fam'.mcs s'** (different family), breaking the contradiction.

### Why Bundle-to-Family Upgrade is Impossible

`G(phi) -> Box(G(phi))` is **not derivable** in bimodal TM (countermodel exists with two families where one satisfies G(p) but the other doesn't). This means knowing phi holds in all future states of one family does NOT guarantee it holds in all states of all families.

### Why Forward-Only Truth Lemma is Blocked

The `imp` forward case (CanonicalConstruction.lean:677) uses `.mpr` (backward IH) for the antecedent:
```lean
have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true  -- BACKWARD IH!
```

To show "(psi -> chi) in MCS implies (truth psi -> truth chi)", when given "truth psi", the proof must convert back to "psi in MCS" to apply MCS implication. This is fundamental to the MCS-based strategy and cannot be avoided.

Additionally, the completeness bridge itself requires backward truth lemma: instantiating `valid_over Int phi` gives "phi is true," but we need "phi in MCS" - that's the backward direction.

### The State of the Codebase

| Component | Status | File:Lines |
|-----------|--------|------------|
| `construct_bfmcs_bundle` | **SORRY-FREE** | UltrafilterChain.lean:2853-2877 |
| `bundle_completeness_contradiction` | **SORRY-FREE** | UltrafilterChain.lean:2931 |
| `shifted_truth_lemma` | **SORRY-FREE** (requires family-level coherence) | CanonicalConstruction.lean:648 |
| `omegaClassFamilies_temporally_coherent` | **DOES NOT EXIST** | Only in deprecation strings |
| Z_chain construction | **5 SORRIES** | UltrafilterChain.lean:2347-2494 |
| `RestrictedTemporallyCoherentFamily` | **FAMILY-LEVEL COHERENT** | SuccChainFMCS.lean:4191-4202 |
| `restricted_truth_lemma` | **3 SORRIES** (G/H propagation) | RestrictedTruthLemma.lean:106,115,135 |
| Target sorries | **3 SORRIES** | Completeness.lean:115,158,186 |

## Recommended Path Forward

### Fix RestrictedTruthLemma.lean (4-6 hours total)

The `RestrictedTemporallyCoherentFamily` already provides family-level coherence for formulas in `subformulaClosure(phi)`. The gap is 3 sorries in `RestrictedTruthLemma.lean`:

| Sorry | Line | Description | Difficulty |
|-------|------|-------------|------------|
| G_step | 106 | G(psi) propagation through DRM steps | Complex |
| G_from_chain | 115 | G(psi) from chain membership | Medium |
| H_from_chain | 135 | H(psi) from chain membership | Medium (symmetric) |

**Why these are fixable**: DRMs are closed under derivation within `deferralClosure`. G(psi) in DRM means "if psi were in the deferred set, it would propagate." The induction requires careful bookkeeping but the math is sound.

### Implementation Steps

1. **Fix RestrictedTruthLemma.lean sorries** (1-2 hours)
   - G_step: Induction on DRM chain, showing G(psi) implies psi at all future positions
   - G/H_from_chain: Connect chain membership to truth via DRM closure properties

2. **Build TaskModel from RestrictedTemporallyCoherentFamily** (1-2 hours)
   - Define `RestrictedTaskFrame`, `RestrictedTaskModel`, `RestrictedOmega`
   - Prove shift-closure for single-family Omega (trivial - single history plus shifts)

3. **Wire to Completeness.lean sorries** (1-2 hours)
   - For any unprovable phi: extend neg(phi) to restricted MCS, build restricted model
   - By restricted_truth_lemma: neg(phi) true at (eval_family, 0)
   - Therefore phi not valid (countermodel exists)
   - Contrapositive: valid -> provable

### Why This Path Will Work

- Within `closureWithNeg(phi)`, F-nesting **IS bounded** (`iter_F_not_mem_closureWithNeg`)
- The restricted construction resolves F/P obligations within a single chain
- Family-level coherence is **guaranteed** by the restricted construction
- The full `shifted_truth_lemma` applies because we have family-level coherence

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Confirmed In |
|----------|-------------|--------------|
| Omega-enumeration for arbitrary MCS | F-nesting unbounded (counterexample: {F^n(p)}) | Reports 40, 50 |
| Bundle-level as truth lemma input | Backward G/H require same-family witnesses | Reports 45, 65-wave3 |
| Forward-only truth lemma | `imp` forward uses backward IH | Reports 50, 65-wave3 |
| Algebraic bypass | Proves different theorem (syntactic vs semantic) | Reports 45, 50 |
| GH-intersection witness | H-theory not G-liftable | Reports 11-16 |

## Teammate Contributions

| Teammate | Focus | Key Finding |
|----------|-------|-------------|
| A | History survey | 9 approaches tried, 5 dead ends, restricted path remaining |
| B | Omega-enumeration status | `omegaClassFamilies` doesn't exist, RestrictedTruthLemma.lean has the real gaps |

## Next Steps

1. **Revise task 65 plan** to focus on RestrictedTruthLemma.lean sorries (not omega-enumeration)
2. **Or create new task** specifically for fixing the 3 RestrictedTruthLemma.lean sorries
3. **After fixing sorries**: Task 66 (Wire Restricted Completeness) becomes unblocked

## References

| Claim | File | Lines |
|-------|------|-------|
| shifted_truth_lemma requires family-level | CanonicalConstruction.lean | 648-652 |
| imp forward uses backward IH | CanonicalConstruction.lean | 677 |
| G backward requires same-family | TemporalCoherence.lean | 165-178 |
| omegaClassFamilies only in deprecation strings | UltrafilterChain.lean | 1811, 1815, 1821 |
| RestrictedTemporallyCoherentFamily | SuccChainFMCS.lean | 4191-4202 |
| RestrictedTruthLemma sorries | RestrictedTruthLemma.lean | 106, 115, 135 |
| Target completeness sorries | Completeness.lean | 115, 158, 186 |
