# Teammate A Findings: UnifiedChain Analysis

**Date**: 2026-02-13
**Focus**: Analyze `UnifiedChain.lean` as an alternative to DovetailingChain
**Session**: sess_881_teammate_a_v5

## Key Findings

1. **UnifiedChain IS a structural improvement** - It combines GContent and HContent in each seed, theoretically enabling cross-sign propagation
2. **However, it has 7 sorries** (compared to DovetailingChain's 4) - The additional sorries arise from the combined seed consistency proof
3. **The critical blocker has shifted** - From "cross-sign propagation impossible" to "combined seed consistency unproven"
4. **UnifiedChain could work** - The architecture is sound, but requires proving that GContent + HContent from different MCSs remains consistent

## UnifiedChain Architecture

### Core Insight (Lines 18-29)
```
UnifiedChain differs from DovetailingChain's two-chain architecture:
- DovetailingChain: Forward chain with GContent seeds, backward chain with HContent seeds
- UnifiedChain: Single chain where each step seeds from BOTH directions
```

### Unified Seed Definition (Lines 74-96)
```lean
def unifiedGContentPart (constructed : Nat -> Option (Set Formula)) (n : Nat) : Set Formula :=
  let t := dovetailIndex n
  { phi | exists m, m < n and dovetailIndex m < t and phi in GContent ((constructed m).getD {}) }

def unifiedHContentPart (constructed : Nat -> Option (Set Formula)) (n : Nat) : Set Formula :=
  let t := dovetailIndex n
  { phi | exists m, m < n and dovetailIndex m > t and phi in HContent ((constructed m).getD {}) }

def unifiedSeed (constructed : Nat -> Option (Set Formula)) (n : Nat) : Set Formula :=
  unifiedGContentPart constructed n U unifiedHContentPart constructed n
```

At construction step n (building M_t where t = dovetailIndex(n)):
- **GContent part**: phi from all prior steps m where dovetailIndex(m) < t (past times)
- **HContent part**: phi from all prior steps m where dovetailIndex(m) > t (future times)

This is exactly what's needed for cross-sign propagation:
- G phi at negative time enters positive time via GContent part
- H phi at positive time enters negative time via HContent part

### How It Differs from DovetailingChain

| Aspect | DovetailingChain | UnifiedChain |
|--------|------------------|--------------|
| Seed for time t | GContent(M_{t-1}) if t >= 0, HContent(M_{t+1}) if t < 0 | GContent(all past) U HContent(all future) |
| Cross-sign | NOT supported (separate chains) | Supported by construction |
| Sorries | 4 | 7 |
| Complexity | Lower | Higher |

## Cross-Sign Propagation Support

### Yes, UnifiedChain Supports It (Architecturally)

The documentation explicitly addresses this (lines 40-45):
```
This approach resolves:
- D1 (forward_G when t < 0): G from negative time enters positive time via combined seed
- D2 (backward_H when t >= 0): H from positive time enters negative time via combined seed
- D3, D4 (F/P witnesses): Same dovetailing enumeration approach
```

### The Proof Challenge

The key theorem `unifiedChain_forward_G` (lines 301-310):
```lean
theorem unifiedChain_forward_G (base : Set Formula) (h_base_cons : SetConsistent base)
    (t t' : Int) (h_lt : t < t') (phi : Formula)
    (h_G : Formula.all_future phi in unifiedChainSet base h_base_cons t) :
    phi in unifiedChainSet base h_base_cons t' := by
  have h_mcs := unifiedChainSet_is_mcs base h_base_cons t'
  sorry
```

Goal at line 310:
```
phi in unifiedChainSet base h_base_cons t'
```

Given:
- `h_G : phi.all_future in unifiedChainSet base h_base_cons t`
- `h_lt : t < t'`

The proof would proceed:
1. If `dovetailRank t < dovetailRank t'`: G phi propagates via unified seed
2. Show G phi in GContent part of seed for t' (since t < t')
3. Show seed extends to MCS, preserving G phi
4. Apply T-axiom: G phi -> phi

**Why it's sorry'd**: The proof requires showing that the unified seed at step `dovetailRank t'` contains G phi from time t. This depends on:
- `dovetailRank t < dovetailRank t'` (NOT always true! e.g., t=1, t'=2: rank 1 < rank 3, OK)
- But also need the intermediate lemma that G phi propagates through all intervening steps

## Sorry Analysis

### Complete Sorry Inventory (7 sorries)

| Line | Location | Goal | Nature |
|------|----------|------|--------|
| 174 | `SetConsistent_empty` | `Consistent []` | Empty context consistency (soundness needed) |
| 227 | `unifiedChainAux` seed consistency | `False` from `L proves bot` where L in seed | **CRITICAL**: Combined seed consistency |
| 278 | `unifiedChainMCS_extends_seed` | `phi in Classical.choose ...` | Seed extension property |
| 298 | `unifiedChain_G_in_seed` | `G phi in seed or G phi in M_{t'}` | G propagation to seed |
| 310 | `unifiedChain_forward_G` | `phi in unifiedChainSet t'` | Main forward_G theorem |
| 330 | `unifiedChain_H_in_seed` | `H phi in seed or H phi in M_{t'}` | H propagation to seed |
| 340 | `unifiedChain_backward_H` | `phi in unifiedChainSet t'` | Main backward_H theorem |
| 356 | `unifiedChain_forward_F` | `exists s, t < s and phi in M_s` | F witness construction |
| 363 | `unifiedChain_backward_P` | `exists s < t, phi in M_s` | P witness construction |

### Comparison with DovetailingChain (4 sorries)

| DovetailingChain Sorry | UnifiedChain Equivalent | Status |
|------------------------|------------------------|--------|
| Line 606: forward_G cross-sign | Line 310: forward_G | Architecturally solvable |
| Line 617: backward_H cross-sign | Line 340: backward_H | Architecturally solvable |
| Line 633: forward_F | Line 356: forward_F | Same (witness enumeration needed) |
| Line 640: backward_P | Line 363: backward_P | Same (witness enumeration needed) |
| N/A | Line 227: seed consistency | **NEW blocker** |
| N/A | Line 174, 278, 298, 330 | Supporting lemmas |

### The Critical New Blocker: Line 227

Goal:
```
base : Set Formula
h_base_cons : SetConsistent base
n : Nat
constructed : Nat -> Option (Set Formula) := fun m => if hm : m <= n then some (unifiedChainAux ...) else none
seed : Set Formula := unifiedSeed constructed (n + 1)
L : List Formula
hL_sub : forall phi in L, phi in seed
d : L proves bot
----- goal -----
False
```

This says: **Prove the unified seed is consistent**.

Why this is hard:
- L contains formulas from BOTH GContent (from past MCSs) and HContent (from future MCSs)
- These MCSs are built at different construction steps
- There's no direct relationship between them that guarantees consistency
- The T-axiom tells us GContent(M) subset M and HContent(M) subset M
- But GContent(M1) U HContent(M2) may not be consistent if M1, M2 are unrelated MCSs

The documentation acknowledges this challenge (lines 122-134):
```
**CRITICAL THEOREM**: This is the make-or-break proof for the unified chain approach.

**Strategy**: The T-axiom reduces G phi and H phi to phi. If M_s and M_t both
extend a common base (M_0), their G/H contents share compatibility through that base.
```

## Recommendation

### UnifiedChain is Worth Pursuing, But Not a Silver Bullet

**Pros**:
1. Architecturally correct for cross-sign propagation
2. Uses the same dovetailing index/rank infrastructure as DovetailingChain
3. Directly addresses the D1/D2 blockers identified in prior research

**Cons**:
1. More sorries (7 vs 4) - the combined seed consistency is a new challenge
2. The key insight about "common base M_0" needs to be formalized
3. F/P witness construction is still unsolved (same as DovetailingChain)

### Path Forward Options

**Option A: Fix UnifiedChain Seed Consistency (Recommended if cross-sign is the priority)**

The combined seed consistency proof requires showing that:
- All formulas in the seed ultimately trace back to the base context
- By T-axiom, GContent(M) subset M and HContent(M) subset M
- Since all MCSs extend the base, their G/H contents are compatible

Key lemma needed:
```lean
lemma unified_seed_derives_from_base (constructed) (n) :
    unifiedSeed constructed (n+1) subset
      { phi | exists derivation of phi from base }
```

**Option B: Stick with DovetailingChain + Add Cross-Sign Infrastructure**

Instead of unifying the seed, add explicit cross-sign propagation lemmas to DovetailingChain:
1. Prove G phi at t < 0 reaches M_0 via backward chain
2. Prove G phi at M_0 enters forward chain via GContent
3. Compose for cross-sign forward_G

This avoids the combined seed consistency problem but requires new infrastructure.

**Option C: Use RecursiveSeed Architecture**

RecursiveSeed.lean (84k tokens, large) takes a different approach:
- Places ALL witnesses (temporal and modal) in the seed BEFORE Lindenbaum
- Avoids the chain construction entirely
- May avoid both cross-sign AND consistency issues

### For Task 881 Specifically

The implementation plan v3 is marked BLOCKED on DovetailingChain's cross-sign sorries. UnifiedChain offers a potential resolution, but shifts the blocker to seed consistency.

**My recommendation**: Investigate whether the seed consistency proof is tractable. The key question is:

> Does the shared base (M_0) provide enough structure to prove GContent(M_{-k}) U HContent(M_{k'}) is consistent?

If yes: UnifiedChain unblocks task 881
If no: Need to pursue Option B (DovetailingChain cross-sign lemmas) or Option C (RecursiveSeed)

## Confidence Level

**Medium**

- High confidence in the architectural analysis (UnifiedChain does support cross-sign)
- Medium confidence in tractability assessment (seed consistency is the unknown)
- The proof at line 227 requires a novel argument about G/H content compatibility across different MCSs
- Without attempting the proof, cannot be certain whether it's fundamentally blocked or just technically challenging
