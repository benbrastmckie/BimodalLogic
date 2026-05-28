# Phase S1: Deep Analysis of nf_2var_existential_transfer j>=1

## Session: sess_1748390400_s1xfer
## Date: 2026-05-28

## Current State

Two sorry sites remain in `StaviCompleteness.lean`:
- Line 2321: Forward direction (M -> M') of `nf_2var_existential_transfer` at j'+1
- Line 2393: Backward direction (M' -> M), symmetric

A third sorry at line 2751 (`nf_exist_sf_guarded_backward`) is INDEPENDENT but blocked on the bridge lemma.

## The Goal

```
⊢ nf_eval_nf M' (j' + 1) (2 + 1) (Fin.cons u' (Fin.cons x' fun x ↦ t')) chi
```

Given: `hu : nf_eval_nf M (j' + 1) (2 + 1) (Fin.cons u (Fin.cons x fun x ↦ t)) chi`
With: `hj : j' + 1 < k`

Context: Bridge hypotheses at depth k for (x,t)/(x',t'). Zone-matched u' has same depth-k 1-var NF and orderings relative to x',t'. All 3-var atoms proved (h_3var_atoms). Depth-0 case already proved.

## What Unfolding Shows

At depth j'+1 with 3 vars, nf_eval_nf decomposes into:
1. **Atoms** (3-var): PROVED via h_3var_atoms
2. **Quantifier**: For each sub : NF j' 4, need
   `(∃ w', nf_eval_nf M' j' 4 (w'::u'::x'::t') sub) ↔ (∃ w, nf_eval_nf M j' 4 (w::u::x::t) sub)`

## The Core Difficulty: 4-var Existential Transfer

To transfer `∃ w` at depth j' for 4-var extensions of (u,x,t)/(u',x',t'), we need to find w' with matching depth-j' 4-var NF at (w',u',x',t'). This requires:
- Same predicates as w: from depth-k 1-var NF agreement ✓
- Same orderings relative to x',t': from zone_match_witness ✓
- **Same ordering relative to u': NOT GUARANTEED by zone_match_witness**

## Why Simple Approaches Fail

### 1. zone_match_witness limitations
zone_match_witness uses bridge hypotheses for (x,t) only. It gives orderings relative to x' and t', but NOT relative to u'. If w and u are in the same zone relative to (x,t) (e.g., both between x and t), their relative ordering is undetermined.

### 2. 1-var NF doesn't determine pairwise ordering
Two points with the same depth-k 1-var NF can be in either order. The NF encodes WHAT types exist nearby, not WHERE specific other named points are.

### 3. 2-var transfer gives wrong witness
From u's depth-k NF: ∃ w1 with correct ordering relative to u'. From (x,t) bridge: ∃ w2 with correct orderings relative to x',t'. But w1 ≠ w2 in general. Need a SINGLE w' satisfying all orderings.

### 4. Circular dependence on bridge lemma
To get orderings from bridge hypotheses for (u,x), need the bridge lemma for that pair. But the bridge lemma for (u,x) needs interval_nf_types for (u,x)/(u',x'), which requires interval splitting, which is what we're trying to prove.

## The Mathematical Solution: Interval Splitting

The GHR93 game argument requires a STRONGER witness than zone_match provides. The witness u' must not only have the same type but must correctly SPLIT the interval types:

Given x < u < t and x' < u' < t':
- interval_nf_types M k x u = interval_nf_types M' k x' u'  
- interval_nf_types M k u t = interval_nf_types M' k u' t'

With interval splitting, we can do zone matching relative to the 3-point configuration {x',u',t'}, getting orderings relative to ALL three reference points.

## Required Implementation

### Option A: Splitting Zone Match (~200-300 lines)

1. **Prove `splitting_zone_match_witness`**: Under bridge hypotheses at depth k+1 for (x,t)/(x',t'), for any u in (x,t), there exists u' with:
   - Same depth-(k+1) 1-var NF
   - interval_nf_types at depth k match for sub-intervals
   
   This uses the depth-(k+1) NF to encode directional information about which types are above vs below u.

2. **Prove sub-interval bridge from splitting match**: The splitting match gives bridge hypotheses at depth k for all consecutive pairs in {x',u',t'}.

3. **Restructure nf_2var_existential_transfer to use splitting match**.

4. **Prove by induction on k** (not pattern match on j).

### Option B: Full EF Game Infrastructure (~400-500 lines)

1. Define game positions (finite sorted sequences with interval type invariant)
2. Prove Duplicator's response lemma (extending a position by one point)
3. Prove NF agreement from game result
4. Connect to the existing bridge lemma framework

### Option C: Mutual Induction on (k, j) (~300 lines)

1. Restructure as mutual induction: bridge lemma at depth k <-> existential transfer at j < k
2. At step k+1: use bridge at depth k (from IH) to establish bridge for sub-intervals
3. Bridge at depth k for (u,x) follows from: bridge at k for (x,t) + NF matching at depth k+1

## Recommended Approach

**Option A (Splitting Zone Match)** is most aligned with the existing code structure. The key new content:

1. Prove that for depth-k NFs with k >= 2, the directional encoding (types above vs below) combined with bridge hypotheses ensures the splitting property
2. This only works at depth k-1 (losing 1 level), but that's sufficient since j'+1 < k gives j' < k-1 after the first step

## What is Already Proved (sorry-free)

- nf_fraisse_compression (compression lemma)
- zone_match_witness (all 5 zones)
- Depth-0 existential transfer (both directions)
- interval_nf_types_depth_decrease
- above_max_depth_decrease, below_min_depth_decrease
- nf_char_depth_decrease
- All atom agreement infrastructure
- nf_2var_from_interval_data (modulo nf_2var_existential_transfer)

## File Location

`Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
- Sorry at line 2321 (forward j'+1)
- Sorry at line 2393 (backward j'+1)
- Sorry at line 2751 (independent: nf_exist_sf_guarded_backward)

## Key Observation for Successor

The depth-k 1-var NF of u encodes: for each depth-(k-1) 2-var NF σ, whether ∃ w with that NF relative to u. A depth-(k-1) 2-var NF σ encodes the ORDERING of the new point relative to u. So u's NF tells us which types exist ABOVE u and which exist BELOW u (separately).

If we use bridge hypotheses at depth k+1 (not k), then zone matching at depth k+1 gives u' with depth-(k+1) NF. The depth-(k+1) NF of u encodes depth-k 2-var info, which encodes depth-(k-1) 3-var info about (v, w, u) for w above/below u. This 3-var info includes the ordering of v relative to both w and u, which distinguishes "between x and u" from "below x."

So the splitting at depth k-1 SHOULD follow from the depth-(k+1) NF matching. The proof requires unwinding the NF layers carefully.
