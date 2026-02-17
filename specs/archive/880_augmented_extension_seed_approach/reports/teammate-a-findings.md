# Research Findings: Augmented Extension Seed Approach

**Task**: 880 - Investigate augmented extension seed approach for pure past/future cases
**Date**: 2026-02-12
**Focus**: Definition and consistency proof for augmented seed; alternative approaches

## Key Findings

### 1. The Fundamental Problem (Confirmed and Deepened)

The core problem identified in research-006 is confirmed: the `multi_witness_seed_consistent_future/past` lemmas are mathematically FALSE. The counterexample is clear:

- MCS M contains F(p) and F(neg(p)) (both are consistent in temporal logic)
- The seed `{p, neg(p)} union GContent(M)` is inconsistent because `{p, neg(p)}` derives bottom directly
- This means the current `extensionSeed` definition produces inconsistent sets in the pure past case

**New finding**: Universal `forward_F` (added in Phase 2) does NOT fix this problem. Research-005 Section 3 claimed it would, but the reasoning at line 69 is flawed:

> "all F-obligation formulas are in mcs(s_max) by universal forward_F"

This is wrong because `forward_F` says `F(phi) in mcs(s) implies phi in mcs(t)` for `t > s` in the domain. For F-obligations at `s_max` (the maximum past domain time), there IS NO `t > s_max` in the domain (that is exactly why we are adding a new time). So `forward_F` cannot propagate obligations from `s_max` to any existing MCS.

The obligations from times `s < s_max` DO propagate to `mcs(s_max)` via `forward_F`, but the obligations originating at `s_max` itself remain problematic.

### 2. Universal forward_F Is Unachievable in General

**Critical new discovery**: Universal `forward_F` in `GHCoherentPartialFamily` is **incompatible with domain extension** for many families.

**Proof by counterexample**:
- Base family: domain = {0}, mcs(0) = M where F(p) in M and F(neg(p)) in M
- This M exists because F(p) = neg(G(neg(p))) and F(neg(p)) = neg(G(p)) can both be in an MCS (they are not contradictory -- they mean "p holds at some future time" and "neg(p) holds at some future time", which is consistent for branching time, or different times in linear time)
- Try to extend to domain = {0, 1}
- forward_F requires: F(p) in mcs(0) implies p in mcs(1), AND F(neg(p)) in mcs(0) implies neg(p) in mcs(1)
- But p and neg(p) in mcs(1) contradicts mcs(1) being an MCS (which must be consistent)

**Consequence**: Zorn's lemma gives a maximal family, but the maximal family may have domain = {0} because extension is impossible. The proof of `maximal_implies_total` is inherently blocked for families with conflicting existential obligations.

**This means the entire "strengthened family" approach from research-005 has a deeper flaw than previously recognized.** The structure with universal forward_F cannot support the Zorn-based totality argument.

### 3. Analysis of the Augmented Seed Approach

Research-005 Section 5 proposed augmenting the seed with negative GH constraints to control which formulas the Lindenbaum extension can introduce. Specifically:

**Proposed augmentation**: For each phi where phi NOT in F.mcs(s') for some future s' in domain, include neg(F(phi)) = G(neg(phi)) in the seed.

**Why this fails**:

1. **G(neg(phi)) not derivable from existing MCSs**: phi not in F.mcs(s') means neg(phi) in F.mcs(s'), but this does NOT mean G(neg(phi)) in F.mcs(s'). The 4-axiom gives G(phi) implies G(G(phi)), not neg(phi) implies G(neg(phi)).

2. **Even if we could add these constraints**: The augmented seed would contain G(neg(phi)) for every phi NOT in some future MCS. But the augmented seed must also be consistent. Adding G(neg(phi)) alongside F-obligations that INCLUDE phi (from some other source time) creates a direct contradiction: phi and G(neg(phi)) are not inconsistent (phi now does not contradict "always in the future neg(phi)"), but phi and neg(phi) WOULD conflict if both F(phi) and F(neg(phi)) obligations are present.

3. **The augmented seed doesn't address the root cause**: The inconsistency arises from conflicting F-obligations ({p, neg(p)} in the seed), not from the Lindenbaum extension adding unwanted formulas. Augmenting the seed with negative constraints adds MORE formulas to an already inconsistent set.

**Conclusion**: The augmented seed with negative GH constraints is NOT a viable approach for the pure past/future cases.

### 4. The Augmented Seed Works for Cross-Sign Case

As noted in research-006, the cross-sign case (both past and future domain times exist) IS solvable with the current approach. The argument:

- Take s_max = max past source time, s_min = min future source time
- s_max < t < s_min, both in domain
- GContent from past propagates forward to s_min via forward_G + 4-axiom
- F-obligations from past propagate to s_min via forward_F (s_max < s_min both in domain)
- HContent from future is already at s_min
- P-obligations from future propagate to s_min via backward_P
- Everything collects into mcs(s_min), which is consistent

This works because the F-obligations propagate to an EXISTING domain time (s_min), not to the new time being added.

### 5. Why One-at-a-Time Extension Fails with Zorn

One might think: "extend one time at a time, satisfying one F-obligation per extension." But this still fails because:

- After extending to domain {0, 1}, forward_F requires ALL F-obligations from mcs(0) satisfied at mcs(1)
- With universal forward_F, you cannot extend even once

With existential forward_F (exists t' > t with phi in mcs(t')), you could add one witness per extension. But:
- Existential forward_F is NOT preserved by chain upper bounds in general
- The Zorn machinery breaks down

### 6. The Real Solution: Drop Universal forward_F/backward_P

**Recommendation**: Remove `forward_F` and `backward_P` from the `GHCoherentPartialFamily` structure entirely. Return to the original formulation with only `forward_G` and `backward_H`.

**Rationale**: Universal forward_F is mathematically impossible to maintain during domain extension. It was added to solve the seed consistency problem, but it actually makes the problem worse by preventing any extension at all for many families.

**For F/P satisfaction in the total family**: Instead of encoding it as a structural invariant, prove it as a consequence of totality + construction:
- When domain = Set.univ, for any F(phi) in mcs(t), we need some t' > t with phi in mcs(t')
- This does NOT require phi in ALL mcs(t'), just SOME mcs(t')
- The existence of witnesses is a property of the CONSTRUCTION, not the structure

### 7. Alternative Approaches

#### Approach A: Dovetailing within Zorn (Recommended)

The key insight from the dovetailing chain construction is: F-obligations are satisfied **one at a time** at **different** future times. We can integrate this into the Zorn framework:

1. Use `GHCoherentPartialFamily` with only forward_G and backward_H (no F/P)
2. Define the seed for extending at time t as: GContent(union) union HContent(union) only -- NO F/P obligations
3. This seed IS consistent (proven in the pure GContent and pure HContent cases already)
4. Extend to MCS via standard Lindenbaum
5. Prove the extended family satisfies forward_G and backward_H
6. After obtaining a TOTAL family via Zorn, prove F/P as derived properties

**The key challenge with this approach**: How to prove F/P for the total family? With only G/H coherence, we need:
- F(phi) in mcs(t) implies exists t' > t with phi in mcs(t')
- Proof attempt: F(phi) = neg(G(neg(phi))) in mcs(t). Since G(neg(phi)) not in mcs(t), there must exist some t' > t where neg(phi) not in mcs(t'). This doesn't follow from G/H coherence alone -- forward_G says G(psi) in mcs(t) implies psi in mcs(t') for all t' > t, but the NEGATION of G (which is F) doesn't give us information about specific future times.

**This is precisely the model-existence gap**: G/H coherence guarantees universal propagation but says nothing about existential witnesses. The F/P satisfaction for total G/H-coherent families is essentially the completeness theorem claim itself -- it's what we're trying to prove!

#### Approach B: Modified Seed with Selective Obligations (Potentially Viable)

Instead of including ALL F-obligations in the seed, include only a **consistent subset**:

1. Start with GContent(mcs(s_max)) as base seed
2. For each F-obligation phi (where F(phi) in mcs(s) for some s), attempt to add phi:
   - If {phi} union current_seed is consistent, add it
   - Otherwise, skip it (it will be handled at a later time)
3. This gives a consistent augmented seed

**The challenge**: This requires **decidable consistency checking** or a well-defined process for selecting which obligations to include. In constructive logic, this might require compactness arguments.

**Formalization**: Define a "compatible F-obligation subset" as a maximal consistent subset of FObligations that is also consistent with GContent(mcs(s_max)). Existence follows from compactness (or can be constructed via a Lindenbaum-like enumeration).

**Then**: The remaining obligations (those skipped) must be handled at OTHER times. This requires adding multiple times to satisfy all obligations -- essentially a mini dovetailing construction.

#### Approach C: Henkin-Style Witness Placement (Most Promising)

Instead of using Zorn to find a maximal partial family and then proving it total, use a **constructive Henkin-style approach** that builds the total family directly:

1. Start with mcs(0) from Lindenbaum extension of Gamma
2. Build mcs(1) from {psi_1} union GContent(mcs(0)) where F(psi_1) in mcs(0) is the first F-obligation
3. Build mcs(2) from {psi_2} union GContent(mcs(1)) where F(psi_2) is the next obligation
4. Continue, dovetailing between forward and backward obligations
5. Each step uses `temporal_witness_seed_consistent` (the PROVEN single-witness version)

This is essentially the DovetailingChain approach. The advantage: each step only adds ONE witness to GContent, which is proven consistent. The disadvantage: the dovetailing enumeration is complex and has its own 4 sorry sites in the current codebase.

**Key insight**: `temporal_witness_seed_consistent` (proven!) handles exactly the single-witness case. The multi-witness case fails. So the construction MUST proceed one witness at a time.

#### Approach D: Weakened Structure with Existential F/P (Hybrid)

Replace universal forward_F/backward_P with existential versions:

```
forward_F_existential : forall s, s in domain ->
    forall phi, F(phi) in mcs(s) ->
    exists t, t in domain, s < t, phi in mcs(t)
backward_P_existential : forall s, s in domain ->
    forall phi, P(phi) in mcs(s) ->
    exists t, t in domain, t < s, phi in mcs(t)
```

**Advantages**:
- Base family ({0}): vacuously true (no s in domain has F/P obligations with witnesses needed)
  Wait -- F(phi) in mcs(0), we need exists t > 0 in domain with phi in mcs(t). But domain = {0} has no t > 0! So this is NOT vacuously true. It's FALSE for the base family.

**This means existential F/P is also impossible for the base family.** We're back to the same problem: singleton domains cannot satisfy F/P. This was the original motivation for removing F/P from the structure (research-003).

## Recommended Approach for Augmented Seed Definition

**The augmented seed approach is NOT viable for the pure past/future cases.** The problem is not about what additional constraints to add to the seed; the problem is that conflicting F-obligations create an inherently inconsistent seed.

The recommended path forward is one of:

### Primary Recommendation: Approach C (Henkin-Style / Dovetailing)

Abandon the Zorn approach for F/P satisfaction. Instead:
1. Use Zorn to get a total G/H-coherent family (this part works)
2. Post-process the total family using a separate construction to ensure F/P
3. OR use a direct Henkin/dovetailing construction from the start

The `temporal_witness_seed_consistent` lemma (proven!) provides the foundation. Each step adds ONE witness for ONE obligation. The multi-witness case is never needed.

### Secondary Recommendation: Bifurcate the Approach

1. **Cross-sign case**: Provable with current infrastructure (seed collects into mcs(s_min))
2. **Pure past/future cases**: Acknowledge these require a fundamentally different construction
3. Implement the cross-sign case now; defer pure cases to a dovetailing-based solution

## Evidence

### Verified Lemma Names
- `temporal_witness_seed_consistent` (proven, in TemporalCoherentConstruction.lean) - single witness consistency
- `temporal_witness_seed_consistent_past` (proven, in TemporalLindenbaum.lean) - past analog
- `GContent_consistent` (proven, in ZornFamily.lean) - GContent of MCS is consistent
- `HContent_consistent` (proven, in ZornFamily.lean) - HContent of MCS is consistent
- `GContent_propagates_forward` (proven, in ZornFamily.lean) - GContent monotone forward via 4-axiom
- `HContent_propagates_backward` (proven, in ZornFamily.lean) - HContent monotone backward via 4-axiom
- `set_mcs_all_future_all_future` (proven, in MCSProperties.lean) - G(phi) implies G(G(phi))
- `set_mcs_all_past_all_past` (proven, in MCSProperties.lean) - H(phi) implies H(H(phi))
- `generalized_temporal_k` (proven, in GeneralizedNecessitation.lean) - if Gamma derives phi, then G(Gamma) derives G(phi)
- `generalized_past_k` (proven, in GeneralizedNecessitation.lean) - past analog
- `set_mcs_closed_under_derivation` (proven, in MCSProperties.lean) - MCS closure
- `set_consistent_not_both` (proven, in MCSProperties.lean) - phi and neg(phi) cannot both be in consistent set
- `set_mcs_disjunction_elim` (proven, in Completeness.lean) - disjunction in MCS implies some disjunct in MCS
- `multi_witness_seed_consistent_future` (FALSE, sorry at line 844) - confirmed counterexample
- `multi_witness_seed_consistent_past` (FALSE, sorry at line 874) - confirmed counterexample

### Key Code Locations
- `extensionSeed` definition: ZornFamily.lean line 512
- `FObligations` definition: ZornFamily.lean line 491
- `PObligations` definition: ZornFamily.lean line 498
- `GHCoherentPartialFamily` structure: ZornFamily.lean line 96
- `forward_F` field (universal): ZornFamily.lean line 121
- `backward_P` field (universal): ZornFamily.lean line 127
- `extensionSeed_consistent` sorry (cross-sign): ZornFamily.lean line 888
- `extensionSeed_consistent` sorry (pure past): ZornFamily.lean line 1120
- `extensionSeed_consistent` sorry (pure future): ZornFamily.lean line 1260
- `extendFamilyAtUpperBoundary` forward_F sorry: ZornFamily.lean line 1764
- `extendFamilyAtUpperBoundary` backward_P sorry: ZornFamily.lean line 1786

## Confidence Level

**High confidence** in the following findings:
- The augmented seed with negative GH constraints is NOT viable
- Universal forward_F is incompatible with domain extension for conflicting F-obligations
- The cross-sign case IS solvable with current infrastructure
- `temporal_witness_seed_consistent` provides the correct granularity (one witness at a time)

**Medium confidence** in the following recommendations:
- Approach C (Henkin/dovetailing) is the right long-term path
- Removing universal forward_F from the structure would unblock progress
- The pure past/future cases are fundamentally harder than cross-sign

**Low confidence** in:
- Whether Approach B (selective obligations) can be formalized cleanly
- Exact effort required for a dovetailing construction within the current codebase

## Remaining Open Questions

1. **Can we prove F/P satisfaction for total G/H-coherent families WITHOUT a constructive argument?** This would salvage the Zorn approach entirely. The question is: does G/H coherence + totality + MCS maximality imply F/P? This seems unlikely because G/H coherence constrains universal properties while F/P are existential.

2. **Is there a way to weaken the seed while still getting forward_F for the extended family?** For example, instead of including all FObligations, include only those consistent with GContent. Would the resulting family still satisfy forward_F?

3. **Can the DovetailingChain sorries be resolved more easily than the ZornFamily ones?** The 4 sorries in DovetailingChain.lean address cross-sign propagation in an explicit chain construction. If those are easier to fix, it might be better to invest there.

4. **Is there a third construction strategy (neither Zorn nor explicit chain) that avoids both problems?** For example, a compactness-based argument or a model-theoretic construction.

5. **Can we prove `maximal_implies_total` for the WEAKER structure (G/H only)?** If maximality among G/H-coherent families implies totality, then Zorn gives us a total G/H-coherent family. The question then reduces to: does total G/H-coherent family satisfy F/P?
