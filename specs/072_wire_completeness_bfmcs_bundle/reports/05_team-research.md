# Research Report: Task #72 (Follow-up)

**Task**: Wire completeness through fully coherent BFMCS construction
**Date**: 2026-03-31
**Mode**: Team Research (2 teammates)
**Focus**: Z_chain_forward_F via Dovetailed Construction - Feasibility and Bidirectionality

## Executive Summary

Two research teammates investigated whether completing `Z_chain_forward_F` via the dovetailed construction requires building a chain that is simultaneously forward_F and backward_P. **The answer is nuanced**: while bidirectionality IS required for same-family (BFMCS) coherence, the dovetailed approach has an **unfixable sorry** ("F vanishes" case), making the Z_chain path a dead end. The sorry-free path uses bundle-level coherence (`BFMCS_Bundle`), which requires adapting the truth lemma but avoids all F/P cross-boundary problems.

## Key Findings

### Finding 1: The Cross-Boundary Problem Is Real and Unfixable in Z_chain

**Confidence**: High (both teammates agree)

The original `Z_chain` splices two independent half-chains:
- t >= 0: `omega_chain_forward` (resolves F_top only, NOT arbitrary F(phi))
- t < 0: `omega_chain_backward` (resolves P_top only, NOT arbitrary P(phi))

**Problem**: When F(phi) appears at time t = -5, the witness s > -5 could require crossing into the positive half-chain. But the two halves share only the seed M0 - they carry no mutual obligation information.

**Evidence**:
- `Z_chain_forward_F` sorry (UC:5350-5352): "The Z_chain uses omega_chain_forward which doesn't have F-resolution guarantee"
- `CoherentZChain_forward_F` t<0 case (UC:8099-8103): sorry with note "may need to cross to forward chain"

### Finding 2: The "F(phi) Vanishes" Sorry Is Unfixable in Dovetailed Approach

**Confidence**: High (explicitly documented in code)

Even the dovetailed variant `omega_chain_true_dovetailed_forward` has an unfixable sorry at UC:8352:

> GAP: The current construction via Lindenbaum doesn't prevent G(neg phi) from entering even when F(phi) = neg(G(neg phi)) was present at an earlier step.

**Root cause**: The Lindenbaum extension can add G(neg phi) to a witness even when F(phi) was present. Since F(phi) = neg(G(neg phi)), this makes F(phi) false in the extended MCS. The seed preserves G-theory (forward) or H-theory (backward), but NOT unresolved F-obligations.

**Implication**: No amount of scheduling/dovetailing fixes this within the current architecture.

### Finding 3: Bidirectional Seed Approach Is BLOCKED

**Confidence**: High (explicitly documented)

The "bidirectional temporal box seed" approach (UC:3699-3900) would solve the vanishing problem by preserving both G-theory AND H-theory in the seed. But it has a sorry at UC:3887:

```lean
-- H_theory: H(a) -> G(H(a))
-- BLOCKED: NOT derivable in TM logic
```

`H(a) -> G(H(a))` is not an axiom of TM. Adding it would change the logic. Task 70's finding that "H_theory elements are not G-liftable" confirms this blocker.

### Finding 4: CoherentZChain Has 4 Unfixable Cross-Direction Sorries

**Confidence**: High

`CoherentZChain` (UC:7948) correctly combines F-preserving forward + P-preserving backward, but has:

| Sorry | Lines | Issue |
|-------|-------|-------|
| `CoherentZChain_forward_F` t<0 | UC:8099-8103 | F(phi) at negative time needs forward witness |
| `CoherentZChain_backward_P` t>=0 | UC:8115-8119 | P(phi) at positive time needs backward witness |
| `CoherentZChain_to_FMCS.forward_G` mixed | UC:8027,8030 | G propagation across boundary |
| `CoherentZChain_to_FMCS.backward_H` mixed | UC:8042,8044 | H propagation across boundary |

**Root cause**: Forward chain preserves G but not H; backward chain preserves H but not G. Cross-direction coherence requires preserving BOTH, which this architecture cannot support.

### Finding 5: BFMCS_Bundle Is Completely Sorry-Free

**Confidence**: High (verified in code)

| Component | File:Line | Status |
|-----------|-----------|--------|
| `resolving_witness` | UC:5971 | Sorry-free |
| `boxClassFamilies_bundle_forward_F` | UC:5518-5556 | Sorry-free |
| `boxClassFamilies_bundle_backward_P` | UC:5563-5600 | Sorry-free |
| `construct_bfmcs_bundle` | UC:5728-5739 | Sorry-free |
| `mcs_neg_gives_countermodel` | UC:5806-5814 | Sorry-free |

The bundle approach allows F-witnesses in ANY family of the bundle, not just the same family. This matches standard Kripke completeness proofs.

### Finding 6: Truth Lemma Bidirectionality Does NOT Require F+P Together

**Confidence**: Medium-High

The Imp case in the truth lemma uses backward inductive hypothesis for sub-formulas, but this is standard structural induction. It does NOT create coupling between F-witnesses and P-witnesses.

**Conclusion**: Truth lemma bidirectionality is about induction structure, not chain construction.

## Synthesis

### The User's Concern Is Valid But Moot

**Question**: Does completing Z_chain_forward_F via dovetailed construction require building a chain that is both forward_F and backward_P simultaneously?

**Answer**: **Yes, but it's moot.** The dovetailed approach has an unfixable "F vanishes" sorry regardless of bidirectionality. The cross-boundary problem requires bidirectional coordination, but even WITH such coordination, the Lindenbaum gap prevents completion.

### Why the Dovetailed Z_chain Is a Dead End

```
Z_chain sorries
  └─ Need F-preserving chain
       └─ omega_chain_F_preserving_forward (forward direction OK)
            └─ omega_true_dovetailed_forward_F_resolution
                 └─ UNFIXABLE SORRY: "F vanishes" case
  └─ Need P-preserving chain
       └─ omega_chain_P_preserving_backward (backward direction OK)
  └─ Need cross-direction coherence
       └─ CoherentZChain has 4 sorries
            └─ Requires bidirectional seed
                 └─ BLOCKED: H(a) → G(H(a)) not derivable
```

### The Sorry-Free Path Exists

```
COMPLETENESS
  └─ BundleTruthLemma [NEEDS WRITING: ~150-300 lines]
       └─ construct_bfmcs_bundle [SORRY-FREE]
            └─ boxClassFamilies_bundle_forward_F [SORRY-FREE]
            └─ boxClassFamilies_bundle_backward_P [SORRY-FREE]
```

## Recommendation

### Primary: Adapt Truth Lemma for BFMCS_Bundle

**Why this is the right path**:
1. All infrastructure is sorry-free
2. No new axioms needed
3. Mathematically justified (bundle-level coherence suffices for completeness)
4. Matches standard modal logic completeness proofs (Segerberg, Goldblatt)
5. Cross-boundary problem DISAPPEARS: F(phi) at t<0 gets witness in DIFFERENT family

**Implementation**:
1. Create `BundleTruthLemma.lean` (or adapt `ParametricTruthLemma`)
2. G/H cases use `bundle_forward_F` and `bundle_backward_P` (any-family witness)
3. Connect `construct_bfmcs_bundle` to `ParametricRepresentation`
4. Estimated: 150-300 lines of new code

### Secondary: Abandon Z_chain_forward_F Entirely

Mark `Z_chain_forward_F` and `Z_chain_backward_P` as deprecated with:
```lean
-- DEPRECATED: Unfixable sorries. Use BFMCS_Bundle with bundle-level coherence.
-- See BundleTruthLemma for the sorry-free path.
```

Do NOT attempt to fix them - they are architectural dead ends.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical bidirectionality analysis | completed | high |
| B | Infrastructure gap analysis | completed | high |

### Conflicts Resolved

Both teammates independently reached the same conclusions:
1. Dovetailed Z_chain is unfixable (converged)
2. Bundle-level coherence is the sorry-free path (converged)
3. Truth lemma adaptation is ~150-300 lines (converged)

**No conflicts to resolve** - findings were fully complementary.

### Gaps Identified

1. **BundleTruthLemma specification**: Exact changes needed to adapt G/H cases for bundle semantics
2. **Completeness theorem wiring**: How to connect `construct_bfmcs_bundle` to `parametric_algebraic_representation_conditional`
3. **Type coercion**: `BFMCS_Bundle` vs `BFMCS D` type gap in completeness signature

## References

### Dovetailed Infrastructure (all paths blocked)

| Item | File:Line | Status |
|------|-----------|--------|
| `Z_chain_forward_F` sorry | UC:5352 | Blocked (uses wrong chain) |
| `omega_true_dovetailed_forward_F_resolution` | UC:8316-8352 | Blocked (F vanishes sorry) |
| `CoherentZChain_forward_F` t<0 | UC:8103 | Blocked (cross-boundary) |
| `bidirectional_temporal_box_seed` | UC:3887 | Blocked (H→G(H) not derivable) |

### Sorry-Free Bundle Path

| Item | File:Line | Status |
|------|-----------|--------|
| `construct_bfmcs_bundle` | UC:5728-5739 | Sorry-free |
| `boxClassFamilies_bundle_forward_F` | UC:5518-5556 | Sorry-free |
| `boxClassFamilies_bundle_backward_P` | UC:5563-5600 | Sorry-free |
| `parametric_algebraic_representation_conditional` | PR:244-265 | Sorry-free (conditional) |

**UC = `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`**
**PR = `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`**

## Summary Answer

**Does completing Z_chain_forward_F require bidirectional F+P construction?**

The question is moot because the dovetailed approach is unfixable regardless:
1. **Within-direction**: F-preserving forward chain has "F vanishes" sorry (Lindenbaum gap)
2. **Cross-direction**: CoherentZChain has 4 sorries (G/H don't cross boundary)
3. **Bidirectional seed**: BLOCKED (H(a)→G(H(a)) not derivable in TM)

**The correct path**: Use `BFMCS_Bundle` with bundle-level coherence. Write `BundleTruthLemma` (~200 lines). This is mathematically cleaner and avoids all architectural problems.
