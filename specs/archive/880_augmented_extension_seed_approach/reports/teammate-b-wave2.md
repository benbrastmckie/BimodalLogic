# Concrete Implementation Path for Sorry-Free ZornFamily.lean

**Task**: 880 - Wave 2, Teammate B
**Date**: 2026-02-12
**Focus**: Define exact implementation steps for eliminating all 12 sorry sites

## Sorry Site Inventory

| # | Line | Location | Category | Difficulty |
|---|------|----------|----------|------------|
| S1 | 844 | `multi_witness_seed_consistent_future` (hard case) | FALSE LEMMA | N/A (delete) |
| S2 | 874 | `multi_witness_seed_consistent_past` (hard case) | FALSE LEMMA | N/A (delete) |
| S3 | 888 | `extensionSeed_consistent` cross-sign case | Seed Consistency | HIGH |
| S4 | 1120 | `extensionSeed_consistent` pure past, FObligations mixed | Seed Consistency | VERY HIGH |
| S5 | 1260 | `extensionSeed_consistent` pure future, PObligations mixed | Seed Consistency | VERY HIGH |
| S6 | 1764 | `extendFamilyAtUpperBoundary` forward_F old-to-new | Extension F/P | MEDIUM |
| S7 | 1786 | `extendFamilyAtUpperBoundary` backward_P new-to-old | Extension F/P | HIGH |
| S8 | 1928 | `extendFamilyAtLowerBoundary` forward_F new-to-old | Extension F/P | HIGH |
| S9 | 1968 | `extendFamilyAtLowerBoundary` backward_P old-to-new | Extension F/P | MEDIUM |
| S10 | 2091 | `non_total_has_boundary` internal gap case | Topology | MEDIUM |
| S11 | 2161 | `maximal_implies_total` h_G_from_new | Propagation | MEDIUM-HIGH |
| S12 | 2168 | `maximal_implies_total` h_H_from_new | Propagation | MEDIUM-HIGH |

## Cross-Sign Case Proof Strategy (S3: line 888) -- DETAILED

### The Goal

When domain has times both above and below `t`, show `extensionSeed F t` is consistent.

The seed is: `(Union_{s<t} GContent(mcs(s))) U (Union_{s>t} HContent(mcs(s))) U FObligations U PObligations`

### Available Infrastructure

1. `GContent_propagates_forward`: GContent(mcs(s1)) subset of GContent(mcs(s2)) for s1 < s2
2. `HContent_propagates_backward`: HContent(mcs(s2)) subset of HContent(mcs(s1)) for s1 < s2
3. `forward_F`: F phi in mcs(s) and s < t and both in domain => phi in mcs(t)
4. `backward_P`: P phi in mcs(s) and t < s and both in domain => phi in mcs(t)
5. `forward_G`: G phi in mcs(s) and s < t' => phi in mcs(t')
6. `backward_H`: H phi in mcs(s) and t' < s => phi in mcs(t')
7. `temporal_witness_seed_consistent`: {psi} U GContent(M) is consistent when F(psi) in M
8. `temporal_witness_seed_consistent_past`: {psi} U HContent(M) is consistent when P(psi) in M

### Key Insight: Everything Collects Into a Single MCS

Let `s_max` be the maximum domain time < t and `s_min` be the minimum domain time > t.
Both exist by hypothesis (cross-sign case).

**Claim**: Every formula in `extensionSeed F t` is in `F.mcs(s_min)`.

**Proof sketch for each component**:

1. **GContent from past times**: For any s in domain with s < t:
   - GContent(mcs(s)) subset of GContent(mcs(s_max)) by `GContent_propagates_forward` (s <= s_max, both in domain)
   - GContent(mcs(s_max)) subset of GContent(mcs(s_min))?? NO -- s_max < t < s_min, but s_max < s_min and both in domain, so YES by `GContent_propagates_forward`
   - G phi in mcs(s_min) implies phi in mcs(s_min) by T-axiom (`set_mcs_implication_property` with temp_t_future)
   - So phi in mcs(s_min)

2. **HContent from future times**: For any s in domain with s > t:
   - HContent(mcs(s)) subset of HContent(mcs(s_min)) by `HContent_propagates_backward` (s_min <= s, both in domain)
   - H phi in mcs(s_min) implies phi in mcs(s_min) by T-axiom for past (`temp_t_past`)
   - So phi in mcs(s_min)

3. **FObligations**: For phi in FObligations, there exists s in domain with s < t and F(phi) in mcs(s).
   - Since s < s_min and both in domain, by `forward_F`: phi in mcs(s_min)

4. **PObligations**: For phi in PObligations, there exists s in domain with t < s and P(phi) in mcs(s).
   - Since s_min <= s (s_min is min of future domain times) and both in domain, by `backward_P`: phi in mcs(s_min)
   - WAIT: backward_P requires s_min < s (strict). If s = s_min, then P(phi) in mcs(s_min) and we need phi in mcs(s_min), but backward_P gives phi in mcs(t') for t' < s. We need the WITNESS for P to be at s_min itself... but t < s_min so we'd need t' such that t' < s_min.
   - Actually re-reading: backward_P says: P(phi) in mcs(s), s in domain, t in domain, t < s => phi in mcs(t). So if P(phi) in mcs(s_min) and we want phi in mcs(s_min), that doesn't directly work (need t < s_min, but phi would go to mcs(t), not mcs(s_min)).

   **CORRECTION**: The PObligations say phi should be in mcs(t) (the new time). We need to show the seed is CONSISTENT, not that everything is in a single MCS. Let me re-examine.

### Revised Strategy: Collect Into mcs(s_min) and mcs(s_max)

Actually, the goal is to show `SetConsistent(extensionSeed F t)`, meaning no finite subset L of the seed derives bottom.

Given a finite L subset of extensionSeed:
- Partition L into: L_G (from GContent), L_H (from HContent), L_F (from FObligations), L_P (from PObligations)

**Strategy A: Show L subset of mcs(s_min)**:

For GContent elements from time s < t:
- G(phi) in mcs(s), s < s_min, both in domain => by forward_G: G(phi) in mcs(s_min)
- So phi in GContent(mcs(s_min)), hence by T-axiom: phi in mcs(s_min)

For HContent elements from time s > t:
- H(phi) in mcs(s), s >= s_min, both in domain
- If s = s_min: phi in HContent(mcs(s_min)), hence by T-axiom: phi in mcs(s_min)
- If s > s_min: by backward_H with s_min < s, phi in mcs(s_min)... Wait, backward_H says H(phi) in mcs(s) and s_min < s and both in domain => phi in mcs(s_min). YES.

For FObligations: phi where F(phi) in mcs(s) for some s < t:
- s in domain, s_min in domain, s < t < s_min so s < s_min
- By forward_F: phi in mcs(s_min). YES.

For PObligations: phi where P(phi) in mcs(s) for some s > t:
- s in domain, s >= s_min
- If s = s_min: P(phi) in mcs(s_min). We want phi in mcs(s_min).
  - Need some t' < s_min in domain. We have s_max < t < s_min and s_max in domain.
  - By backward_P: P(phi) in mcs(s_min), s_max in domain, s_max < s_min => phi in mcs(s_max).
  - But we want phi in mcs(s_min), not mcs(s_max)!

**This is the problem.** P(phi) in mcs(s_min) gives us phi somewhere in the past, but we want phi in the seed at time t. The seed INCLUDES phi directly (as a PObligations element). The question is whether it's consistent with the rest.

### Revised Strategy B: Mixed Collection

The real issue is: can we show all seed elements lie in a SINGLE MCS? If they do, the seed is clearly consistent (subset of a consistent set).

- GContent, HContent, FObligations elements all land in mcs(s_min) as shown above.
- PObligations elements: phi where P(phi) in mcs(s) for s > t. We showed that if s > s_min, then by backward_P applied with s_min: phi in mcs(s_min). If s = s_min, by backward_P with s_max: phi in mcs(s_max).

WAIT. Let me re-read forward_F and backward_P. The structure says:

```
forward_F : forall s t, s in domain -> t in domain -> s < t ->
    forall phi, F(phi) in mcs(s) -> phi in mcs(t)
```

This says F(phi) in mcs(s) and t in domain with s < t => phi in mcs(t). So forward_F propagates phi to ALL future domain times.

```
backward_P : forall s t, s in domain -> t in domain -> t < s ->
    forall phi, P(phi) in mcs(s) -> phi in mcs(t)
```

This says P(phi) in mcs(s) and t in domain with t < s => phi in mcs(t). So backward_P propagates phi to ALL past domain times.

**KEY**: These are UNIVERSAL propagation properties. forward_F says: if F(phi) in mcs(s), then phi in mcs(t) for ALL t > s in domain. backward_P says: if P(phi) in mcs(s), then phi in mcs(t) for ALL t < s in domain.

But wait -- we need phi at the NEW time t, which is NOT in the domain. The seed collects things that should be at t, but t is not yet in domain.

However, for PObligations: P(phi) in mcs(s) for s > t. If there exists any domain time t' between t and s (i.e., t < t' < s), then by backward_P: phi in mcs(t'). But s_min is the minimum future domain time, so t < s_min <= s. If s > s_min, then backward_P gives phi in mcs(s_min). If s = s_min, then backward_P doesn't directly apply (no domain time between t and s_min).

BUT: backward_P with s = s_min gives phi in mcs(s_max) where s_max < s_min. So phi IS in some MCS.

Actually, forward_F is universal: if F(phi) in mcs(s_max) for s_max in domain, then phi in mcs(s_min) since s_max < s_min and both in domain. So if F(phi) in mcs(s_max)... but do we know F(phi) in mcs(s_max)?

**We DON'T necessarily know F(phi) in mcs(s_max).** We only know P(phi) in mcs(s_min). Different operator.

### CORRECTED Strategy: Everything in mcs(s_min) after all

Let's be very precise:

For PObligations: phi where P(phi) in mcs(s) for some s in domain with t < s.
- s >= s_min (since s_min is minimum future domain time)
- s_min in domain
- If s > s_min: backward_P gives phi in mcs(s_min) (s_min < s, both in domain). DONE.
- If s = s_min: backward_P gives phi in mcs(t') for any t' < s_min in domain. So phi in mcs(s_max). But we wanted phi in mcs(s_min).
  - HOWEVER: do we know phi in mcs(s_min)?
  - P(phi) in mcs(s_min). By temporal logic: P(phi) = neg(H(neg(phi))). So H(neg(phi)) not in mcs(s_min).
  - By `set_mcs_negation_complete`: either phi in mcs(s_min) or neg(phi) in mcs(s_min).
  - If neg(phi) in mcs(s_min): Then for s_max < s_min, by backward_H... no, backward_H requires H(neg(phi)) in mcs(s_min), which we said is NOT in mcs(s_min).

  This doesn't immediately help. Let's try another angle.

  - We know phi in mcs(s_max) (from backward_P applied to P(phi) in mcs(s_min) and s_max in domain, s_max < s_min).
  - mcs(s_max) is consistent. phi is in it.
  - But we wanted to show everything in the seed is in mcs(s_min). phi might NOT be in mcs(s_min).

**CRITICAL REALIZATION**: The "collect into one MCS" strategy does NOT work for PObligations at s_min because backward_P pushes phi to past domain times, not to the reference MCS s_min itself.

### Strategy C: Two-MCS Approach

All GContent, HContent, and FObligations elements are in mcs(s_min).
All PObligations elements where the source s > s_min are also in mcs(s_min) (by backward_P).
PObligations elements where the source s = s_min: phi is in mcs(s_max) (by backward_P).

But phi in mcs(s_max) and the rest in mcs(s_min) doesn't immediately give consistency.

HOWEVER: All elements from mcs(s_max) are also propagated to s_min if they are GContent-like.

Actually, let me re-examine: if phi in mcs(s_max), does this mean phi in mcs(s_min)?
Not necessarily! mcs(s_max) and mcs(s_min) are different MCSs. They agree on GContent/HContent propagation but can differ on propositional content.

### Strategy D: Direct Consistency Proof

Instead of collecting into one MCS, prove consistency directly.

Given L subset of extensionSeed F t, suppose L derives bottom.

Partition: L = L_rest U L_P_smin where L_P_smin are PObligations from source s_min.

All elements of L_rest are in mcs(s_min) (as established above).
Each element of L_P_smin: phi_i where P(phi_i) in mcs(s_min), and phi_i in mcs(s_max).

If L_P_smin is empty, then L subset mcs(s_min), contradicting consistency of mcs(s_min).

If L_P_smin is nonempty: we have `L_rest, phi_1, ..., phi_k derives bottom` where L_rest subset mcs(s_min) and each P(phi_i) in mcs(s_min).

By the deduction theorem iteratively: `L_rest derives phi_1 -> phi_2 -> ... -> phi_k -> bot`.
Since L_rest subset mcs(s_min) and mcs(s_min) is closed under derivation:
`(phi_1 -> phi_2 -> ... -> phi_k -> bot) in mcs(s_min)`.

This means `neg(phi_1) or neg(phi_2) or ... or neg(phi_k)` is derivable from mcs(s_min).
More precisely: `phi_1 -> (phi_2 -> ... -> bot)` in mcs(s_min).

By MCS negation completeness: either phi_1 in mcs(s_min) or neg(phi_1) in mcs(s_min).

Case 1: phi_1 in mcs(s_min). Then we can remove phi_1 from L_P_smin (it's in mcs(s_min)), reducing the problem.

Case 2: neg(phi_1) in mcs(s_min). We have P(phi_1) in mcs(s_min). And neg(phi_1) in mcs(s_min). Is this contradictory?
- P(phi_1) = neg(H(neg(phi_1)))
- So neg(H(neg(phi_1))) in mcs(s_min) AND neg(phi_1) in mcs(s_min).
- The first tells us H(neg(phi_1)) NOT in mcs(s_min).
- But neg(phi_1) in mcs(s_min) doesn't force H(neg(phi_1)) in mcs(s_min).
- So no contradiction yet.

This is getting complex. Let me think about this differently.

### Strategy E: The CORRECT Approach -- Uniform forward_F/backward_P

The key observation about the structure is that `forward_F` is UNIVERSAL: F(phi) in mcs(s), s < t, both in domain => phi in mcs(t). This means:

For PObligations element phi with P(phi) in mcs(s) for s > t:
- We need phi in the seed. Check.
- We need the seed to be consistent.

For the PObligations from s = s_min: P(phi) in mcs(s_min).
- backward_P gives: phi in mcs(t') for ALL t' < s_min in domain.
- In particular, phi in mcs(s_max).
- But ALSO: if s_max has s_max' < s_max in domain, then forward_G propagation tells us nothing about phi.

**Actually the cleanest approach**: Instead of trying to collect everything into one MCS, observe:

Every formula in the seed is in **at least one** MCS in the family. For each phi in seed:
- If from GContent(mcs(s)): then G(phi) in mcs(s), so phi in mcs(s) by T-axiom.
- If from HContent(mcs(s)): then H(phi) in mcs(s), so phi in mcs(s) by T-axiom.
- If from FObligations with source s: F(phi) in mcs(s), phi in mcs(s_min) by forward_F.
- If from PObligations with source s: P(phi) in mcs(s), phi in mcs(s_max) by backward_P (take s_max < s).

But "everything in at least one MCS" doesn't prove consistency of the union.

### Strategy F: THE FUNDAMENTAL INSIGHT -- forward_F IS the key

Re-reading the structure more carefully:

```
forward_F : forall s t, s in domain -> t in domain -> s < t ->
    forall phi, F(phi) in mcs(s) -> phi in mcs(t)
```

This says: for ALL t > s in domain, phi in mcs(t). So if F(phi) in mcs(s) for s < s_min, then phi in mcs(s_min). YES.

Similarly:
```
backward_P : forall s t, s in domain -> t in domain -> t < s ->
    forall phi, P(phi) in mcs(s) -> phi in mcs(t)
```

For ALL t < s in domain, phi in mcs(t). So P(phi) in mcs(s) for s > s_max => phi in mcs(s_max). If s = s_min > s_max, then phi in mcs(s_max).

Now, the seed elements:

1. GContent: phi from GContent(mcs(s)), s < t. G(phi) in mcs(s). Forward_G: G(phi) in mcs(s_min). T-axiom: phi in mcs(s_min). **phi in mcs(s_min).**

2. HContent: phi from HContent(mcs(s)), s > t. H(phi) in mcs(s). Backward_H: H(phi) in mcs(s_max). T-axiom: phi in mcs(s_max). Now does phi in mcs(s_min)?
   - H(phi) in mcs(s_min)? Only if s_min <= s and backward_H propagates.
   - HContent_propagates_backward: HContent(mcs(s)) subset HContent(mcs(s_min)) since s_min < s => NO WAIT.
   - HContent_propagates_backward says: for s1 < s2, HContent(mcs(s2)) subset HContent(mcs(s1)). So HContent propagates to SMALLER times.
   - So HContent(mcs(s)) subset HContent(mcs(s_min)) if s_min < s. YES. And for s = s_min, trivially.
   - So H(phi) in mcs(s_min). T-axiom: phi in mcs(s_min). **phi in mcs(s_min).**

3. FObligations: phi where F(phi) in mcs(s), s < t, s in domain.
   - s < t < s_min, so s < s_min.
   - forward_F: phi in mcs(s_min). **phi in mcs(s_min).**

4. PObligations: phi where P(phi) in mcs(s), s > t, s in domain.
   - s >= s_min.
   - backward_P: phi in mcs(t') for all t' < s in domain.
   - In particular, with t' = s_max (s_max < t < s = s_min, so s_max < s). phi in mcs(s_max).
   - But does phi in mcs(s_min)?
   - backward_P with t' = s_min works only if s_min < s (strict). If s > s_min, then phi in mcs(s_min). YES for s > s_min.
   - If s = s_min: backward_P gives phi in mcs(s_max) but NOT in mcs(s_min) directly.

**THE REMAINING PROBLEM**: PObligations from source s_min. P(phi) in mcs(s_min). We want phi in mcs(s_min).

Can we show phi in mcs(s_min)?
- By negation completeness: either phi in mcs(s_min) or neg(phi) in mcs(s_min).
- If phi in mcs(s_min): done.
- If neg(phi) in mcs(s_min): P(phi) in mcs(s_min) means neg(H(neg(phi))) in mcs(s_min). So H(neg(phi)) NOT in mcs(s_min). But neg(phi) in mcs(s_min) doesn't force H(neg(phi)) in mcs(s_min), so no immediate contradiction.

HOWEVER: neg(phi) in mcs(s_min). By forward_G... no, neg(phi) is propositional, not G-modal. We can't propagate it forward.

**WAIT** -- backward_P at s_min gives phi in mcs(s_max). Combined with the fact that all GContent/HContent/FObligations are in mcs(s_min), not mcs(s_max), we can't directly merge.

### RESOLUTION: The cross-sign case IS harder than previously thought

The claim in research-001 that "the cross-sign case IS solvable with existing infrastructure" was **over-optimistic** for PObligations from the minimum future source time.

However, there is a saving grace: the number of problematic PObligations elements in any finite L is bounded. We can use the deduction theorem argument:

Given L subset seed with L derives bot.
Let L' = {phi in L | phi from PObligations at s_min and phi not in mcs(s_min)}.
Let L'' = L \ L'.
L'' subset mcs(s_min).

If L' empty: L subset mcs(s_min), contradiction with consistency.

If L' = {phi_1, ..., phi_k}: By iterated deduction theorem:
mcs(s_min) derives phi_1 -> (phi_2 -> ... -> (phi_k -> bot)...)

Since mcs(s_min) is closed under derivation:
(phi_1 -> (phi_2 -> ... -> bot)) in mcs(s_min)

By modus ponens or negation:
neg(phi_1 & phi_2 & ... & phi_k) is derivable from mcs(s_min).

Now, each phi_i: P(phi_i) in mcs(s_min). By backward_P, phi_i in mcs(s_max).
Also neg(phi_i) not in mcs(s_min) (otherwise by MCS, phi_i in mcs(s_min) would follow... wait, that's wrong. We just assumed phi_i NOT in mcs(s_min), so by negation completeness, neg(phi_i) IS in mcs(s_min)).

So: neg(phi_1) in mcs(s_min), AND phi_1 in mcs(s_max).

This means: neg(phi_1) in mcs(s_min). Since G(neg(phi_1)) in mcs(s_min)?? NO, neg(phi_1) doesn't imply G(neg(phi_1)).

**Alternative**: By forward_G: G(neg(phi_1)) might not be in any MCS.

This approach is getting stuck. The fundamental issue is:

**The forward_F/backward_P fields in GHCoherentPartialFamily are TOO STRONG.**

They assert that F(phi) in mcs(s) implies phi in ALL future mcs(t). This is a universal property for an existential operator. Research-001 already identified this: "Universal forward_F is INCOMPATIBLE with domain extension."

## The Fundamental Problem: forward_F/backward_P Are Unsatisfiable

### Why the current structure is broken

The current `GHCoherentPartialFamily` has:
```
forward_F : forall s t, s in domain -> t in domain -> s < t ->
    forall phi, F(phi) in mcs(s) -> phi in mcs(t)
```

This says: if F(phi) in mcs(s), then phi in mcs(t) for ALL t > s in domain.

**Counterexample**: MCS M at time 0 contains both F(p) and F(neg(p)).
- forward_F requires: p in mcs(1) AND neg(p) in mcs(1).
- But mcs(1) is consistent, contradiction.

This counterexample shows that NO family with {0, 1} subset of domain can have forward_F when mcs(0) contains both F(p) and F(neg p). Yet such an mcs(0) is perfectly valid in temporal logic.

**Consequence**: The Zorn construction cannot produce a total family with forward_F, because extension from domain {0} to {0, 1} is impossible in general.

### What Zorn actually gives

Zorn gives a MAXIMAL family. If extension is impossible (as above), the maximal family might just be domain = {0}. The current proof strategy (maximal => total) fails because:
1. `maximal_implies_total` assumes we can always extend at boundary times
2. But `extensionSeed_consistent` (which is needed for extension) can fail when forward_F/backward_P obligations are contradictory
3. So maximality does NOT imply totality with the current structure

## Recommended Approach: Remove forward_F/backward_P from the Structure

### The correct architecture

**Phase 0: Structure simplification**

Remove `forward_F` and `backward_P` from `GHCoherentPartialFamily`. Return to the original G/H-only coherence. The structure becomes:

```lean
structure GHCoherentPartialFamily where
  domain : Set Int
  mcs : Int -> Set Formula
  domain_nonempty : domain.Nonempty
  is_mcs : forall t, t in domain -> SetMaximalConsistent (mcs t)
  forward_G : forall t t', t in domain -> t' in domain -> t < t' ->
    forall phi, G(phi) in mcs(t) -> phi in mcs(t')
  backward_H : forall t t', t' in domain -> t in domain -> t' < t ->
    forall phi, H(phi) in mcs(t) -> phi in mcs(t')
  -- NO forward_F or backward_P
```

**Why this works**: G/H coherence IS preservable through Zorn chains and domain extension. The 4-axiom ensures G(phi) -> GG(phi), so G-content propagates transitively. F/P coherence is recovered as a DERIVED property for total families.

**Phase 1: Prove extensionSeed_consistent with G/H-only seed**

The extension seed simplifies to:
```
extensionSeed F t = (Union_{s<t} GContent(mcs(s))) U (Union_{s>t} HContent(mcs(s)))
```

No FObligations or PObligations in the seed.

**Cross-sign consistency proof**: For L subset seed:
- All GContent elements propagate to GContent(mcs(s_max)) via GContent_propagates_forward
- All HContent elements propagate to HContent(mcs(s_min)) via HContent_propagates_backward
- GContent(mcs(s_max)) subset mcs(s_max) (by T-axiom)
- HContent(mcs(s_min)) subset mcs(s_min) (by T-axiom)
- We need: GContent(mcs(s_max)) U HContent(mcs(s_min)) is consistent.

For this last step: GContent propagates forward from s_max to s_min (since s_max < s_min). So GContent(mcs(s_max)) subset GContent(mcs(s_min)) subset mcs(s_min) by T-axiom. And HContent(mcs(s_min)) subset mcs(s_min) by T-axiom. So the entire seed is subset of mcs(s_min), which is consistent. DONE.

**Pure past case**: Seed = Union GContent(mcs(s)). All propagate to GContent(mcs(s_max)). L subset mcs(s_max) by T-axiom. Consistent.

**Pure future case**: Seed = Union HContent(mcs(s)). All propagate to HContent(mcs(s_min)). L subset mcs(s_min) by T-axiom. Consistent.

**This eliminates S3, S4, S5 (lines 888, 1120, 1260).**

**Phase 2: Prove maximal_implies_total with G/H-only extension**

The boundary extension now only needs forward_G/backward_H properties. The hypotheses `h_G_to_new`, `h_H_to_new` follow from seed inclusion (as currently implemented). The hypotheses `h_G_from_new` and `h_H_from_new` require showing that G/H content of mcs_t (Lindenbaum extension of seed) propagates to existing MCSs.

**h_G_from_new at lower boundary**: t < s for all s in domain. G(phi) in mcs_t. Need phi in mcs(s).
- mcs_t is a Lindenbaum extension of the seed (which is Union HContent(mcs(s'))).
- G(phi) in mcs_t means it was either in the seed or added by Lindenbaum.
- If from seed: G(phi) in HContent(mcs(s')), meaning H(G(phi)) in mcs(s'). By mix axiom or interaction: we need to show phi in mcs(s). This requires temporal interaction axioms (like G(phi) -> HG(phi) or similar).

**THIS IS STILL HARD.** The new-to-old propagation requires that Lindenbaum doesn't add arbitrary G/H content.

### Alternative: GH-Controlled Lindenbaum

Instead of standard Lindenbaum, use a controlled extension that rejects G(phi)/H(phi) unless forced:

```
controlled_lindenbaum(seed, F, t):
  Enumerate all formulas phi_1, phi_2, ...
  S_0 = seed
  For each phi_i:
    If S_i U {phi_i} is consistent:
      If phi_i = G(psi) and psi not in mcs(s) for all s > t in domain:
        Skip (reject G(psi) to maintain forward compatibility)
        Add neg(G(psi)) = F(neg(psi)) instead (if consistent)
      Elif phi_i = H(psi) and psi not in mcs(s) for all s < t in domain:
        Skip (reject H(psi) to maintain backward compatibility)
        Add neg(H(psi)) = P(neg(psi)) instead (if consistent)
      Else:
        S_{i+1} = S_i U {phi_i}
    Else:
      S_{i+1} = S_i
  Return Union S_i
```

**Is neg(G(psi)) always addable when G(psi) is rejected?**

If G(psi) is consistent with S but we reject it: is neg(G(psi)) = F(neg(psi)) consistent with S?
By MCS construction: either G(psi) or neg(G(psi)) will be in the final MCS. If we skip G(psi), eventually neg(G(psi)) comes up and (if consistent) gets added. If neg(G(psi)) is also inconsistent with S, then S derives both G(psi) and neg(G(psi)), making S inconsistent -- contradiction.

So yes, this works: for any formula, either it or its negation is added. The question is whether we can arrange the ordering to ensure G-formulas that conflict with existing MCSs are rejected.

**Problem**: This requires decidability of "psi in mcs(s) for all s > t in domain." Since the domain is a set of integers and mcs is a function, this might not be decidable in Lean.

**Resolution**: Use Classical.choice. The controlled Lindenbaum is noncomputable anyway.

## Implementation Sequence (Numbered Steps)

### Step 0: Delete false lemmas
- Delete `multi_witness_seed_consistent_future` (line 806-844)
- Delete `multi_witness_seed_consistent_past` (line 849-874)
- **Eliminates**: S1, S2
- **Risk**: Low (these are unused/false)
- **Effort**: 30 minutes

### Step 1: Remove forward_F/backward_P from GHCoherentPartialFamily
- Remove fields from structure (lines 117-128)
- Remove from `chainUpperBound` (lines 390-451)
- Remove from `buildBaseFamily` (lines 1563-1572)
- Remove from `extendFamilyAtUpperBoundary` (lines 1742-1803)
- Remove from `extendFamilyAtLowerBoundary` (lines 1915-1976)
- Remove from `extendFamilyAtBoundary` dispatcher
- **Eliminates**: S6, S7, S8, S9 (lines 1764, 1786, 1928, 1968)
- **Risk**: Medium (large refactor, many downstream changes)
- **Effort**: 4-6 hours

### Step 2: Remove FObligations/PObligations from extensionSeed
- Simplify `extensionSeed` (line 512) to just GContent U HContent
- Remove `FObligations` and `PObligations` definitions (lines 491-499)
- Remove associated lemmas
- **Eliminates**: Simplifies S3, S4, S5
- **Risk**: Low (simplification)
- **Effort**: 1-2 hours

### Step 3: Prove extensionSeed_consistent (all three cases)
- Cross-sign: Everything collects into mcs(s_min) via GContent forward propagation
- Pure past: Everything in mcs(s_max) via GContent forward propagation
- Pure future: Everything in mcs(s_min) via HContent backward propagation
- **Eliminates**: S3, S4, S5 (lines 888, 1120, 1260)
- **Risk**: Low-Medium (strategy is clear, implementation may need care)
- **Effort**: 3-5 hours

### Step 4: Handle non_total_has_boundary internal gap case
- The internal gap (domain elements both above and below t but t not in domain) does not require being a boundary time.
- With the simplified seed (no F/P obligations), extension at ANY gap time works.
- **New approach**: Generalize extension beyond boundary times. For non-boundary times, we need forward_G from new to old AND backward_H from new to old, which are NOT vacuous.
- **OR**: Prove that any non-total domain has a boundary time (simpler):
  - Domain is nonempty, so it has elements.
  - Domain is not all of Int, so some integer is missing.
  - Take any missing integer t.
  - If all domain elements < t: upper boundary.
  - If all domain elements > t: lower boundary.
  - Otherwise: there exist a < t < b with a, b in domain. But then either min(domain) - 1 or max(domain) + 1 is a boundary... BUT domain might be unbounded!

  **CRITICAL**: A domain can be unbounded yet not all of Int. Example: all even integers. Then for t = 1: there's 0 < 1 < 2. For t = -1: there's -2 < -1 < 0. No boundary exists!

  **This means non_total_has_boundary is FALSE for non-boundary-having domains.** We need general extension, not just boundary extension.

- **Resolution**: Replace the `isBoundaryTime` concept with general extension for ANY missing time. This requires showing the "from new to old" G/H propagation.
- **Eliminates**: S10 (line 2091)
- **Risk**: HIGH (requires new proof infrastructure)
- **Effort**: 6-10 hours

### Step 5: Prove G/H from-new-to-old propagation
- When extending at time t (not necessarily boundary), need:
  - G(phi) in mcs_t => phi in mcs(s) for s > t in domain
  - H(phi) in mcs_t => phi in mcs(s) for s < t in domain
- **Strategy**: Use controlled Lindenbaum to ensure mcs_t doesn't contain G/H formulas that conflict with existing MCSs.
  - When building mcs_t from seed, reject G(psi) if psi not in all future domain MCSs.
  - By temporal logic: if G(psi) is rejected, F(neg(psi)) = neg(G(psi)) gets added instead.
  - The resulting MCS satisfies: G(psi) in mcs_t implies psi in mcs(s) for all s > t in domain.
- **Alternatively**: Use standard Lindenbaum and prove the property after the fact:
  - mcs_t is an MCS extending the seed.
  - The seed includes GContent from all past domain times.
  - G(phi) in mcs_t: either from seed or from Lindenbaum.
  - If from seed (G(phi) in GContent(mcs(s)) for some s < t): GG(phi) in mcs(s) by 4-axiom. So G(phi) propagates via forward_G to all future domain times s'. Then phi in mcs(s') by T-axiom... wait, we need phi in mcs(s'), not G(phi) in mcs(s').
  - G(phi) in mcs(s') gives phi in mcs(s') by T-axiom. YES.
  - If G(phi) added by Lindenbaum (not in seed): Then G(phi) is "new" content. Does it propagate?
  - **KEY INSIGHT**: Lindenbaum can add G(phi) where phi is NOT in existing future MCSs. This is the problem.

- **The controlled Lindenbaum approach is needed.**
- **Eliminates**: S11, S12 (lines 2161, 2168)
- **Risk**: VERY HIGH (novel proof technique, no existing infrastructure)
- **Effort**: 10-15 hours

### Step 6: Alternative to Step 4+5 -- General Extension via Controlled Lindenbaum
- Combine Steps 4 and 5: Prove that for ANY missing time t, we can extend the family.
- Use controlled Lindenbaum that respects existing MCSs in both temporal directions.
- This is the most complex step but solves both problems at once.
- **Eliminates**: S10, S11, S12
- **Risk**: VERY HIGH
- **Effort**: 12-18 hours

## Dependency Graph

```
Step 0 (delete false lemmas)
  |
  | (independent of Steps 1-6)
  v
[DONE]

Step 1 (remove forward_F/backward_P from structure)
  |
  +---> Step 2 (simplify extensionSeed)
  |       |
  |       +---> Step 3 (prove extensionSeed_consistent)
  |
  +---> Step 4+5 or Step 6 (general extension + G/H propagation)
          |
          v
        [ALL SORRIES ELIMINATED]
```

Steps 0 and 1 can begin independently.
Step 2 depends on Step 1.
Step 3 depends on Step 2.
Steps 4+5 (or alternative Step 6) depend on Step 1.
Steps 4+5/6 and Step 3 are independent of each other.

## Effort/Risk Assessment Table

| Step | Description | Effort | Risk | Sorries Eliminated | Cumulative |
|------|-------------|--------|------|-------------------|------------|
| 0 | Delete false lemmas | 0.5h | Low | S1, S2 | 2/12 |
| 1 | Remove forward_F/backward_P from structure | 4-6h | Medium | S6, S7, S8, S9 | 6/12 |
| 2 | Simplify extensionSeed | 1-2h | Low | (prepares S3-S5) | 6/12 |
| 3 | Prove extensionSeed_consistent | 3-5h | Low-Medium | S3, S4, S5 | 9/12 |
| 4 | Handle general (non-boundary) extension | 6-10h | High | S10 | 10/12 |
| 5 | G/H from-new-to-old via controlled Lindenbaum | 10-15h | Very High | S11, S12 | 12/12 |
| **TOTAL** | | **25-38h** | | **12/12** | |

**Alternative path (Steps 4+5 combined as Step 6)**:

| Step 6 | General extension with controlled Lindenbaum | 12-18h | Very High | S10, S11, S12 | 12/12 |
| **TOTAL (alt)** | | **21-31h** | | **12/12** | |

## Confidence Level

| Aspect | Confidence | Rationale |
|--------|------------|-----------|
| Steps 0-3 will work | HIGH (90%) | Clear mathematical strategy, well-understood infrastructure |
| Step 4 (general extension exists) | MEDIUM (65%) | non_total_has_boundary is FALSE as stated; need restructuring |
| Step 5/6 (controlled Lindenbaum) | LOW-MEDIUM (45%) | Novel technique, no existing infrastructure, may have subtle bugs |
| Overall sorry elimination | MEDIUM (55%) | Steps 0-3 are solid; Steps 4-6 carry significant risk |

## Alternative Paths If Steps 4-6 Fail

### Path A: Weaken to Boundary-Only Extension
- Accept that non_total_has_boundary needs a weaker domain condition (e.g., domain must be an interval or must have boundary points).
- This would mean Zorn gives a maximal family among those with interval domains.
- Risk: may not give domain = Set.univ.

### Path B: Pivot to DovetailingChain
- DovetailingChain.lean has 4 sorry sites but they are for cross-sign propagation, which Step 3 shows is solvable.
- If the Zorn approach hits a wall on general extension, redirect effort to DovetailingChain.
- The cross-sign infrastructure developed in Steps 1-3 transfers.

### Path C: Hybrid Approach
- Use Zorn for G/H-coherent family with interval domain (easier to prove totality).
- Use DovetailingChain ideas for F/P witness placement post-Zorn.
- Most complex but potentially most robust.

## Key Technical Questions Requiring Resolution

1. **Is non_total_has_boundary provable?** No -- counterexample: domain = even integers. Need restructuring.

2. **Can controlled Lindenbaum be formalized in Lean?** Yes in principle (noncomputable), but requires significant new infrastructure (enumeration of formulas, decidability of "psi in all future MCSs" via classical logic).

3. **Does removing forward_F/backward_P break anything downstream?** Need to check all consumers of `GHCoherentPartialFamily` -- particularly `total_family_FObligations_satisfied` and `total_family_PObligations_satisfied` which rely on these fields. Those lemmas would need to be reproven from F/P recovery for total families.

4. **Is the G/H-only seed truly sufficient for totality?** The seed consistency is easy without F/P obligations. But the extension construction must still ensure that the resulting total family satisfies F/P, which means the Lindenbaum extension must "accidentally" include the right F/P content. This is exactly what controlled Lindenbaum addresses.
