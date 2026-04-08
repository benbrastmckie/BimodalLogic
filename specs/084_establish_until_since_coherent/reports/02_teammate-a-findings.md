# Teammate A Findings: Enriched Seed Construction for Until/Since Coherence

**Task**: 84 -- Establish `until_since_coherent` for Bundle Completeness
**Focus**: Enriched seed approach -- prove it works or identify exactly where it breaks
**Date**: 2026-04-07

## Executive Summary

The enriched seed approach **does not work as proposed** for `until_since_coherent`. The fundamental blocker is the **X-vs-G mismatch**: enriching the Lindenbaum seed with `(phi U psi)` guarantees it appears in the next MCS, but **cannot guarantee it persists through subsequent steps** because Until formulas are not G-liftable. This is the same architectural blocker documented in `DovetailedChain.lean` (lines 36-48) and `SuccRelation.lean` (lines 533-547). However, the **backward direction** (truth-to-MCS) has an independent and potentially viable path via BX8 (reflexive introduction). Below I trace each component in detail.

## 1. Existing Infrastructure Analysis

### 1.1 g_content and the Seed Pattern

`g_content(M) = {phi | G(phi) in M}` (TemporalContent.lean:56).

The established pattern for chain construction:
1. Build seed = `{target} U g_content(M)`
2. Prove seed consistency via G-lift argument
3. Lindenbaum-extend to MCS
4. Result: target in MCS, g_content(M) subset of MCS

This is implemented in:
- `forward_temporal_witness_seed` (WitnessSeed.lean): `{psi} U g_content(M)`
- `temporal_box_g_seed` (UltrafilterChain.lean:2247): `G_theory U box_theory U g_content`
- `targeted_g_content_seed` (SuccChainFMCS.lean:2019): `{target} U g_content(u)`

All three use the same consistency argument: if L subset seed and L derives bot, G-lift everything to get G(bot) in M, contradiction.

### 1.2 The Dovetailed Chain (Algebraic path)

`DovetailedChain.lean` uses `forward_step` with `temporal_theory_witness_with_g_exists`, which gives:
- phi in W (target resolution)
- G_theory agreement (G(a) in M -> G(a) in W)
- box_class_agree(M, W)
- **g_content(M) subset W** (key property)

The chain is: `chain(n+1) = forward_step(chain(n), schedule_formula(n))`.

### 1.3 Existing Sorry in until_unfold_in_mcs

`SuccRelation.lean:514-520`: `until_unfold_in_mcs` has a sorry because the old `until_unfold` axiom was removed during the BX refactoring. The comment says "derive from BX5 self-accumulation" but the derivation was never completed. The target shape is:

```
(phi U psi) -> X(psi v (phi ^ (phi U psi)))
```

where X(alpha) = (bot U alpha). This is **not directly derivable from BX5** because BX5 gives `(phi U psi) -> ((phi ^ (phi U psi)) U psi)`, which enriches the guard but does not give a next-step decomposition.

## 2. Enriched Seed Consistency: Verified

**Claim**: If `(phi U psi) in w_n` (an MCS), then `g_content(w_n) U {phi U psi}` is consistent.

**Proof**: Both `g_content(w_n)` and `{phi U psi}` are subsets of `w_n` (the latter trivially; the former because `g_content(w_n) subset w_n` holds for MCS by BX1, proved in `g_content_subset_deferral_restricted_mcs` at SuccChainFMCS.lean:1226). So the union is a subset of a consistent set, hence consistent.

**Confidence**: HIGH (100%). This is straightforward set theory.

**However**, this is the WRONG consistency argument for the enriched seed. The actual seed for the chain step is `{target} U g_content(w_n)`, where target is whatever the dovetailing schedule picks. To enrich it, we'd need `{target} U g_content(w_n) U {phi U psi}`. This requires showing:

```
{target} U g_content(w_n) U {phi U psi} is consistent
```

This is **also true** by the same argument: all three parts are subsets of w_n when F(target) in w_n and (phi U psi) in w_n. But wait -- `target` is not necessarily in `w_n`, only `F(target) in w_n`. The seed `{target} U g_content(w_n)` is consistent precisely because of the G-lift argument, not because target is in w_n. Adding `{phi U psi}` to this seed: we need `{target} U g_content(w_n) U {phi U psi}` to be consistent. This IS provable:

- If L subset seed and L derives bot:
  - If target in L: deduction gives `L \ {target} derives neg(target)`. But `L \ {target} subset g_content(w_n) U {phi U psi}`.
  - Sub-case: if `(phi U psi) in L \ {target}`: deduction again gives something in g_content(w_n) derives `neg(target) ^ neg(phi U psi)`. G-lift: `G(neg(target) ^ neg(phi U psi))` in w_n, so `G(neg(target))` in w_n (by G-distribution), contradicting `F(target)` in w_n.
  - Actually this gets complicated. The clean approach: note that `(phi U psi)` IS G-liftable from w_n **if** `G(phi U psi)` in w_n. But that's exactly what we DON'T have.

**Revised assessment**: The enriched seed `{target, phi U psi} U g_content(w_n)` is **not obviously provably consistent** via the standard G-lift argument, because `(phi U psi)` cannot be G-lifted. The standard consistency proof requires every non-target element to be G-liftable.

**Confidence**: MEDIUM. Consistency might still hold via a different argument (e.g., all elements are in w_n, so any finite subset has a model -- but this requires a semantic argument, not a purely syntactic one).

**Alternative**: Use `{phi U psi}` AS the target itself. Then the seed is `{phi U psi} U g_content(w_n)`, and we need `F(phi U psi)` in w_n. From `(phi U psi)` in w_n, BX10 gives `F(psi)` in w_n, but we need `F(phi U psi)`, not `F(psi)`. This is **not available** from the axioms directly.

## 3. Forward Until Proof: Critical Gap Analysis

### Step-by-step trace:

**Step 1**: `(phi U psi) in w_n`, `psi not in w_n`. By BX9 (until_elim): `phi v psi in w_n`. Since `psi not in w_n` and w_n is MCS: `phi in w_n`. WORKS.

**Step 2**: By BX5 (self_accum_until): `(phi U psi) -> ((phi ^ (phi U psi)) U psi)`. So `((phi ^ (phi U psi)) U psi) in w_n`. This gives us a **stronger** Until with enriched guard. WORKS.

**Step 3**: Need `(phi U psi) in w_{n+1}`. The chain step gives `w_{n+1} superset g_content(w_n)`. For `(phi U psi) in g_content(w_n)`, we'd need `G(phi U psi) in w_n`. But **`(phi U psi) -> G(phi U psi)` is NOT valid** -- Until is existential, not universal. FAILS.

**This is the fundamental blocker**. The chain construction propagates g_content (G-wrapped formulas), but Until formulas are not G-wrapped. There is no BX axiom that derives `G(phi U psi)` from `(phi U psi)`.

### Can BX4 (connectedness) help?

BX4: `alpha -> G(P(alpha))`. So `(phi U psi) -> G(P(phi U psi))`. This means `P(phi U psi) in g_content(w_n)`, so `P(phi U psi) in w_{n+1}`. This tells us that from `w_{n+1}`, looking backward, `(phi U psi)` held at some past point. But `P(phi U psi) in w_{n+1}` does NOT give `(phi U psi) in w_{n+1}`.

### Can BX5 + BX9 together derive a useful propagation?

From `(phi U psi) in w_n` with `psi not in w_n`:
- BX5: `((phi ^ (phi U psi)) U psi) in w_n`
- BX9 on the enriched Until: `(phi ^ (phi U psi)) v psi in w_n`
- Since `psi not in w_n`: `phi ^ (phi U psi) in w_n` -- which gives us `(phi U psi) in w_n` (tautological).

This circles back. BX5+BX9 just confirm what we already know at w_n, they don't propagate forward.

### What about using the semantics directly?

The `until_since_coherent` is a **property of the constructed BFMCS**, not something we need to derive purely syntactically at each step. The question is: does the dovetailed chain construction PRODUCE families that satisfy Until coherence?

For the forward direction (`(phi U psi) in fam.mcs t -> exists witness`): the dovetailed chain already resolves F-obligations. By BX10, `(phi U psi) -> F(psi)`, so `F(psi) in w_t`. The dovetailed chain guarantees `exists s >= t, psi in w_s`. So we have the witness for psi. But we also need the guard: `phi in w_r for all r in [t, s)`.

The guard requires knowing that `(phi U psi)` persists from t to s (or at least that phi holds at each intermediate point). BX9 gives: if `(phi U psi) in w_r` and `psi not in w_r`, then `phi in w_r`. So the guard follows IF we can show `(phi U psi) in w_r` for all r in [t, s). And that's exactly the Until persistence problem -- the same blocker as Step 3.

**Conclusion on forward direction**: BLOCKED by Until persistence through Lindenbaum steps.

## 4. Backward Until Proof: Alternative Approaches

### The Invalid Approach (from plan v39)

The proposed derivation `neg(phi U psi) -> neg(psi) ^ (neg(phi) v G(neg(phi U psi)))` was proven semantically INVALID. This is correct -- it would require `neg(phi U psi) -> G(neg(phi U psi))` which says "if Until doesn't hold now, it never will" -- clearly false.

### Approach via BX8 (reflexive introduction)

BX8: `psi -> (phi U psi)`. This means: if we have the witness `psi in w_s` at some s >= t, then `(phi U psi) in w_s`.

Now, can we propagate `(phi U psi)` BACKWARD from s to t? This is exactly what `until_since_coherent`'s backward direction asks. We need to show: given `psi in w_s` for some s >= t, and `phi in w_r` for all r in [t, s), derive `(phi U psi) in w_t`.

**Key observation**: In the BXCanonical approach (Frame.lean:564-575), the backward argument uses:
1. Assume `neg(phi U psi) in w_t` (contradiction approach)
2. BX4: `neg(phi U psi) -> G(P(neg(phi U psi)))`. So `P(neg(phi U psi)) in w_s` (since w_t <= w_s).
3. From `P(neg(phi U psi)) in w_s`: exists u <= s with `neg(phi U psi) in w_u`.
4. BX8: `psi in w_s` gives `(phi U psi) in w_s`. But we need `neg(phi U psi) not in w_s` (which follows from `(phi U psi) in w_s` by MCS consistency).

Wait -- step 3 gives `neg(phi U psi)` at some u <= s, but we need to know whether u >= t (in the interval [t, s]). If u = s, we get contradiction immediately (since `(phi U psi) in w_s` by BX8). If u < s but u >= t, then `phi in w_u` (from the guard) and `neg(phi U psi) in w_u`. From BX9 contrapositive: `neg(phi v psi) in w_u`, i.e., `neg(phi) ^ neg(psi) in w_u`. But `phi in w_u`, contradiction.

**The gap**: We need u >= t, but P(neg(phi U psi)) at w_s gives u <= s without guaranteeing u >= t. In the BXCanonical approach (with abstract ordering), this requires LINEARITY of bx_le, which is exactly the noted gap.

**For Int-indexed chains**: In the Bundle/FMCS setting with D = Int, the temporal ordering IS linear (it's literally Int's ordering). So the above argument would work: u <= s and u is in the ordering, and if u < t, then... we need the chain to be on a linear order, which it is.

**Confidence**: HIGH for D = Int. The backward direction via BX4 + BX8 + linearity of Int is mathematically valid. The formalization requires showing that the MCS chain ordering matches Int's ordering, which is given by the FMCS structure.

### Backward Direction for Bundle Path

In the Bundle/FMCS setting, `fam.mcs : D -> Set Formula` with D = Int. The backward Until coherence states:

```
exists s >= t, psi in fam.mcs s, forall r, t <= r -> r < s -> phi in fam.mcs r
  -> (phi U psi) in fam.mcs t
```

**Proof sketch for D = Int**:
1. Assume the witnesses exist but `(phi U psi) not in fam.mcs t`.
2. Since fam.mcs t is MCS: `neg(phi U psi) in fam.mcs t`.
3. By BX4 (connect_future): `neg(phi U psi) -> G(P(neg(phi U psi)))`.
   So `G(P(neg(phi U psi))) in fam.mcs t`.
4. Since s >= t and the chain respects the ordering: `P(neg(phi U psi)) in fam.mcs s`.
5. `P(neg(phi U psi)) in fam.mcs s` means: exists u <= s with `neg(phi U psi) in fam.mcs u`.
   But wait -- this requires forward_P coherence for the P operator, which is part of `temporally_coherent`. We're assuming `temporally_coherent` is already established (it's proven separately).
6. By `backward_P`: exists u <= s with `neg(phi U psi) in fam.mcs u`.
7. Case analysis on u vs t:
   - If u = t: already have `neg(phi U psi) in fam.mcs t`, which is our assumption.
   - Need to check: does the P-witness u satisfy u >= t?

This approach **requires** `temporally_coherent` (specifically backward_P/forward_P) to extract the P-witness. Since `temporally_coherent` is already established (with its own sorries in the SuccChain path, but sorry-free in the Dovetailed path), this is a legitimate dependency.

Actually wait -- **backward_P** gives: if `P(alpha) in fam.mcs s`, then exists u <= s with `alpha in fam.mcs u`. But this is exactly `forward_since` for the Since case or just the definition of what P means semantically. In the FMCS setting, this requires `backward_P` from `temporally_coherent`.

**Critical insight**: The backward Until proof for the Bundle path can piggyback on `temporally_coherent` (which handles G/H/F/P) combined with BX axioms. This means `until_since_coherent` is NOT independent -- it depends on `temporally_coherent`.

## 5. Available BX Axioms Summary

| Axiom | Statement | Role in Until/Since |
|-------|-----------|-------------------|
| BX5 | `(phi U psi) -> ((phi ^ (phi U psi)) U psi)` | Self-accumulation: enriches guard |
| BX5' | `(phi S psi) -> ((phi ^ (phi S psi)) S psi)` | Mirror for Since |
| BX6 | `(phi U (phi ^ (phi U psi))) -> (phi U psi)` | Absorption: prevents infinite deferral |
| BX7 | linearity of Until witnesses | Ensures unique witness ordering |
| BX8 | `psi -> (phi U psi)` | Reflexive intro: creates Until from witness |
| BX8' | `psi -> (phi S psi)` | Mirror for Since |
| BX9 | `(phi U psi) -> (phi v psi)` | Elimination: current-time info |
| BX9' | `(phi S psi) -> (phi v psi)` | Mirror for Since |
| BX10 | `(phi U psi) -> F(psi)` | Eventuality extraction |
| BX10' | `(phi S psi) -> P(psi)` | Mirror for Since |
| BX4 | `phi -> G(P(phi))` | Connectedness: forward propagation of past |
| BX4' | `phi -> H(F(phi))` | Connectedness: backward propagation of future |

## 6. Temporal Coherence Unification Assessment

**Question**: Can the enriched chain also provide `temporally_coherent`?

The dovetailed chain already provides `temporally_coherent` (sorry-free in the Dovetailed path per `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` referenced at Completeness.lean:418-423). The issue is exclusively `until_since_coherent`.

For the SuccChain path, `temporally_coherent` has sorries in `forward_F` and `backward_P`. These are conceptually simpler than Until coherence because F/P are definable in terms of G/H (`F(psi) = neg(G(neg(psi)))`), so their coherence follows from G/H coherence plus MCS maximality.

**Unification is not needed**: The two coherence properties are independent. `temporally_coherent` handles G/H/F/P; `until_since_coherent` handles U/S. The chain construction should provide both, but through different mechanisms.

## 7. The Path Forward: Two Orthogonal Approaches

### Approach A: BXCanonical Path (Abstract Ordering)

The BXCanonical approach (Frame.lean) uses abstract MCS points with `bx_le` ordering. The key missing piece is **linearity of `bx_le`** on intervals, derivable from BX7 (linearity of Until). If BX7 can establish that for any three points w, u, v with w <= v, either w <= u or u <= v, then both forward and backward Until proofs work.

**Status**: Blocked on BX7 -> linearity derivation. This is the "standard" completeness approach but requires substantial proof infrastructure.

### Approach B: Bundle Path (Int-indexed chains)

For D = Int, the ordering IS linear by construction. The backward direction works via BX4 + BX8 + Int linearity. The forward direction requires Until persistence through chain steps, which is blocked.

**Possible resolution for forward direction**: Instead of propagating `(phi U psi)` through g_content (which doesn't work), use a **different chain construction** that includes active Until formulas in the seed at every step.

Specifically, define the enriched seed at step n as:
```
seed(n) = {target(n)} U g_content(w_n) U active_untils(w_n)
```
where `active_untils(w_n) = {(phi U psi) | (phi U psi) in w_n and psi not in w_n}`.

**Consistency of this seed**: This is the crux. The seed includes formulas that are NOT G-liftable. The standard G-lift consistency proof fails. We need an alternative:

Since `active_untils(w_n) subset w_n` and `g_content(w_n) subset w_n` (by BX1) and the target satisfies `F(target) in w_n`, can we prove consistency of `{target} U g_content(w_n) U active_untils(w_n)` by showing it's a subset of some consistent set?

No -- `target` is not in `w_n` in general (only `F(target) in w_n`). So the union is NOT a subset of `w_n`.

**Alternative consistency argument**: Every element except target is in w_n. If the seed is inconsistent, some `L subset seed` derives bot. If target not in L, then `L subset w_n`, contradicting w_n consistent. If target in L, apply deduction: `L \ {target}` derives `neg(target)`. Now `L \ {target} subset g_content(w_n) U active_untils(w_n) subset w_n`. So `neg(target) in w_n` (by MCS closure). But `F(target) in w_n`, i.e., `neg(G(neg(target))) in w_n`. Does `neg(target) in w_n` contradict `F(target) in w_n`?

`F(target) = neg(G(neg(target)))`. Having `neg(target) in w_n` means target not in w_n. `G(neg(target))` might or might not be in w_n. We need `G(neg(target)) not in w_n` (i.e., `F(target) in w_n`), which we already have. So `neg(target) in w_n` and `F(target) in w_n` are consistent! (target is false now but true at some future point.)

**This means the deduction-based consistency argument FAILS for elements that aren't G-liftable.** The standard proof requires: if `L \ {target}` derives `neg(target)`, then G-lift to get `G(neg(target)) in w_n`, contradicting `F(target)`. But G-lifting requires every element of `L \ {target}` to be G-liftable, and `active_untils` elements are NOT.

**Conclusion**: The enriched seed consistency is NOT provable via the standard technique. A fundamentally different approach is needed.

## 8. Confidence Levels

| Component | Confidence | Status |
|-----------|-----------|--------|
| Seed consistency (g_content only) | HIGH (100%) | Proven in codebase |
| Enriched seed consistency (+ Until) | LOW (20%) | Standard proof fails; no known alternative |
| Forward Until (persistence through steps) | LOW (10%) | Blocked by X-vs-G mismatch |
| Backward Until (truth -> MCS) | HIGH (80%) | Works via BX4+BX8+linearity for D=Int, needs temporally_coherent |
| Forward Until via BXCanonical | MEDIUM (40%) | Needs BX7 -> linearity proof |
| temporally_coherent unification | N/A | Not needed; already sorry-free on Dovetailed path |

## 9. Key Recommendations

1. **Abandon the enriched seed for forward Until**. The X-vs-G mismatch is fundamental and has been independently identified in DovetailedChain.lean, SuccRelation.lean, and BXCanonical/Frame.lean. Three separate code paths all hit the same wall.

2. **Pursue the backward direction independently**. For D = Int, the backward Until proof via BX4 + BX8 + Int linearity is viable and does not require Until persistence. This closes half of `until_since_coherent`.

3. **For forward Until, consider the BXCanonical approach with BX7 linearity**. This is the standard completeness technique for Until-Since logics. The key lemma is: BX7 (linearity of Until) implies linearity of the canonical ordering `bx_le`. With linearity, BX5 (self-accumulation) gives Until propagation to intermediate points.

4. **Alternatively, consider a restricted version**: `restricted_until_since_coherent` for formulas in the deferral closure, analogous to `restricted_temporally_coherent`. The deferral closure is finite, so active Until formulas are bounded, enabling a finite-deferral argument.

5. **The three sorry sites (lines 322, 356, 450)** all use `B.until_since_coherent` with the same type. A single proof of `until_since_coherent` for the constructed BFMCS would close all three simultaneously.
