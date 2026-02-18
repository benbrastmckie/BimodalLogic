# Research Report: Task #864

**Task**: Recursive seed construction for Henkin model completeness
**Date**: 2026-02-17
**Focus**: Does RecursiveSeed place all relevant formulas at time 0, making cross-sign moot?
**Session**: sess_1771384724_cb46b9

## Summary

The hypothesis that RecursiveSeed places ALL formulas at time 0 is **FALSE** - temporal witnesses (`neg(G psi)`, `neg(H psi)`) create entries at non-zero times via `freshFutureTime`/`freshPastTime`. However, the analysis reveals a more nuanced picture: RecursiveSeed DOES propagate certain formulas TO time 0, but the chain construction architecture cannot leverage this fact.

## Findings

### 1. RecursiveSeed Formula Placement Analysis

**Initial Seed:**
- `ModelSeed.initial phi` creates exactly one entry at (family 0, time 0)
- This is the only time 0 entry initially

**Formula Processing in `buildSeedAux`:**

| Formula Type | Placement | Creates New Times? |
|--------------|-----------|-------------------|
| `atom`, `bot`, generic `imp` | Current position only | No |
| `Box psi` | Current position + all families at current time | No |
| `G psi` | Current position + all EXISTING future times | No |
| `H psi` | Current position + all EXISTING past times | No |
| `neg(Box psi)` | Current position + NEW FAMILY at current time | New family, same time |
| `neg(G psi)` | Current position + `freshFutureTime` | **YES** - creates time > current |
| `neg(H psi)` | Current position + `freshPastTime` | **YES** - creates time < current |

**Key finding:** Only `neg(G psi)` and `neg(H psi)` create non-zero times. These are the existential temporal operators (F = neg(G neg), P = neg(H neg)).

### 2. What Does Get Propagated to Time 0?

When `G phi` is processed at time t < 0:
1. `G phi` and `phi` are added to time t
2. `addToAllFutureTimes` adds `phi` to ALL existing times > t
3. Since time 0 always exists (from initial seed), `phi` IS added to time 0

**Theorem confirmed by code (lines 566-573 of RecursiveSeed.lean):**
```lean
| Formula.all_future psi, famIdx, timeIdx, seed =>
    let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
    let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi
    buildSeedAux psi famIdx timeIdx seed4
```

So: **If `G phi` appears at time t < 0 in the seed, then `phi` is also at time 0 in the seed.**

### 3. Why This Doesn't Resolve the Sorries

The 5 remaining sorries stem from the chain construction architecture, not from seed formula placement.

**The Problem:**

`buildFamilyFromSeed` uses `dovetailChainSet`:
- Forward chain: step n+1 extends `GContent(step n)`
- Backward chain: step n+1 extends `HContent(step n)`

For `forward_G` at time t < 0 with target t' > 0:
1. `G phi` is in backward_chain (at some index for time t)
2. Need `phi` in forward_chain (at some index for time t')
3. BUT: backward chain only tracks HContent, not GContent
4. There's no proven path from backward_chain membership to forward_chain membership

**Architectural Mismatch:**
- Backward chain is optimized for `backward_H` (H phi at t => phi at t' < t)
- Forward chain is optimized for `forward_G` (G phi at t => phi at t' > t)
- Cross-sign requires BOTH chains to communicate through time 0

### 4. Analysis of the 5 Sorries

| Line | Theorem | Actual Issue |
|------|---------|--------------|
| 161 | `modal_witness_includes_boxcontent` | Unused by main path (in `seedFamilyMCS`) |
| 246 | `forward_G` (t < 0 case) | Chain direction mismatch - backward chain has no GContent tracking |
| 256 | `backward_H` (t >= 0 case) | Chain direction mismatch - forward chain has no HContent tracking |
| 328 | `buildFamilyFromSeed_cross_sign_seed` | Same as 246 - seed has phi at 0, but chain doesn't propagate |
| 372 | `buildFamilyFromSeed_contains_seed` (t != 0) | Seed formulas at non-zero times not in chain base |

### 5. Potential Resolution Paths

**Path A: Prove seed formulas propagate through chain**

If we can show:
1. `phi` in seed at time 0 => `phi` in `base`
2. `phi` in `base` => `phi` in chain(0) (already proven: `dovetailForwardChainMCS_zero_extends`)
3. `G phi` in chain(t) for t < 0 => `phi` in chain(0) (needs: connect backward to forward)

The gap is step 3. The backward chain at time t < 0 doesn't directly connect to forward chain at time 0.

**Path B: Modify chain construction**

Instead of separate forward/backward chains with disjoint content tracking:
- Use a single construction that tracks BOTH GContent and HContent at each step
- Or: Prove that the shared base at time 0 inherits from both directions

**Path C: Leverage 4-axiom for seed formulas**

If `G phi` is in the MCS at time t < 0:
- By 4-axiom: `G(G phi)` is also in MCS
- `G(G phi)` means `G phi` at all future times
- So `G phi` should be at time 0

But this requires:
1. The backward chain MCS to inherit 4-axiom closure
2. Backward-to-time-0 propagation of `G phi`
3. Forward-to-positive propagation of `phi` from `G phi` at time 0

This is essentially proving that 4-axiom gives us cross-chain communication, which requires showing that backward chain MCS and forward chain MCS are related through their shared base.

## Recommendations

### Immediate Action (Lower Effort)

**Document sorries 246 and 256 as architectural limitations** with explanation:
- The dovetailing chain architecture supports same-sign propagation only
- Cross-sign requires architectural change or alternative proof approach
- Mark as technical debt with documented resolution path

### Medium-term Action (Moderate Effort)

**Investigate Path C**: Prove that 4-axiom provides cross-chain communication:
1. Show `G phi ∈ backward_chain(t)` => `G(G phi) ∈ backward_chain(t)` (MCS + 4-axiom)
2. Show `G(G phi)` backward-propagates to time 0 base
3. Show `G phi` at time 0 forward-propagates to positive times

This avoids modifying chain construction but requires careful reasoning about MCS properties.

### Long-term Action (Higher Effort)

**Refactor to unified construction** (Path B):
- Single chain that tracks both G and H content at each step
- Bidirectional coherence built in
- Cleaner architecture but more implementation work

## References

- RecursiveSeed.lean: Lines 555-625 (buildSeedAux, buildSeed)
- SeedCompletion.lean: Lines 225-257 (buildFamilyFromSeed with sorries)
- DovetailingChain.lean: Lines 380-418 (chain definitions)
- implementation-004.md: Phase 4 analysis (session 32)

## Next Steps

1. Determine whether Path C (4-axiom approach) is mathematically viable
2. If yes: Implement proof connecting backward chain to time 0 to forward chain
3. If no: Document architectural limitation and consider Path B for future work
4. For line 372: Prove seed formulas at non-zero times reach time 0 via temporal propagation lemmas

## Appendix: Key Code References

### Seed Propagation (RecursiveSeed.lean:566-573)
```lean
| Formula.all_future psi, famIdx, timeIdx, seed =>
    let phi := Formula.all_future psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
    let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
    let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi
    buildSeedAux psi famIdx timeIdx seed4
```

### Chain Construction (DovetailingChain.lean:413-418)
```lean
noncomputable def dovetailChainSet (base : Set Formula) (h_base_cons : SetConsistent base)
    (t : Int) : Set Formula :=
  if _ : 0 ≤ t then
    (dovetailForwardChainMCS base h_base_cons t.toNat).val
  else
    (dovetailBackwardChainMCS base h_base_cons ((-t - 1).toNat)).val
```

### Cross-Sign Sorry (SeedCompletion.lean:241-246)
```lean
· -- Case: t < 0 (cross-sign or both negative)
  push_neg at h_t
  -- Cross-sign and both-negative cases require the formula to propagate
  -- through time 0, which the dovetailing chain construction doesn't support.
  sorry
```
