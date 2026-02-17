# Research Findings: Alternative Approaches to the Augmented Seed Problem

**Task**: 880 - Investigate augmented extension seed approach
**Role**: Teammate B - Alternative approaches and prior art
**Date**: 2026-02-12

## Key Findings on Alternatives

### 1. Precise Diagnosis of the Core Problem

The false lemma `multi_witness_seed_consistent_future` fails because the extension seed conflates **existential** obligations: F(p) and F(neg p) can coexist in an MCS M (meaning "p at some future time" and "neg p at some other future time"), but the seed demands BOTH p AND neg p in the same MCS, which is inconsistent.

The problem manifests in exactly two cases:

- **Pure past case** (upper boundary): domain has times only below t. FObligations from s_max (the maximum domain time) demand all phi where F(phi) in mcs(s_max) be placed in the seed. These phi values need not be mutually consistent.
- **Pure future case** (lower boundary): symmetric with PObligations from s_min.

The **cross-sign case** (domain times both above and below t) is SOLVABLE because F-obligations from past source s_max propagate via forward_F to future domain time s_min, and everything collects into the existing consistent MCS at s_min.

### 2. Can the Augmented Seed Approach Unify All Three Cases?

**No.** The augmented seed approach (adding negative GH constraints like neg(G psi) to prevent unwanted G/H formulas in the Lindenbaum extension) addresses the wrong problem. The issue is not about controlling what Lindenbaum adds -- the seed ITSELF is inconsistent before Lindenbaum even runs.

Specifically:
- Cross-sign case: works WITHOUT augmentation (collect into s_min MCS)
- Pure past case: seed contains {phi : F(phi) in mcs(s_max)} union GContent(mcs(s_max)). The GContent part is fine (consistent by `GContent_consistent`). The F-obligations can include contradictory formulas. No amount of "augmenting" the seed fixes an internally inconsistent F-obligations set.
- Pure future case: symmetric

**There is no single seed definition that handles all three cases** with the current architecture. The fundamental issue is that multiple F-obligations at the same source time can be mutually contradictory.

### 3. Viable Alternative Approaches

#### Approach A: One-at-a-Time Witness Placement (RECOMMENDED)

**Idea**: Instead of demanding all F-obligations in a single seed, place witnesses ONE AT A TIME. This leverages the proven `temporal_witness_seed_consistent` theorem:

> If F(psi) in M, then {psi} union GContent(M) is consistent.

**Construction sketch for pure past case (upper boundary extension at t)**:
1. Start with seed_0 = GContent(mcs(s_max)) (consistent by `GContent_consistent`)
2. Enumerate F-obligations: phi_1, phi_2, ... where F(phi_i) in mcs(s) for some s < t in domain
3. For each phi_i, prove {phi_i} union seed_i is consistent, then extend to seed_{i+1} via Lindenbaum step
4. Final seed is an MCS extending all seeds

The key insight is that `temporal_witness_seed_consistent` proves {psi} union GContent(M) consistent for a SINGLE psi. We can iterate this: after extending to include phi_1, the resulting set S_1 is an MCS. If F(phi_2) in S_1, then {phi_2} union GContent(S_1) is consistent. But F(phi_2) may NOT be in S_1 -- it was in mcs(s), not necessarily in S_1.

**Problem with iteration**: F(phi_2) in mcs(s) does not imply F(phi_2) in S_1, because S_1 is a new MCS unrelated to mcs(s). The iteration approach requires forwarding F(phi_2) from mcs(s) to S_1, which requires forward_F, which requires s < t and t in domain -- but t is the time we are extending to (not yet in domain).

**Refinement**: Use a CHAIN construction (not Zorn) where at step n, the MCS at time t is built incrementally. At step n:
- Build seed(t, n) = {phi_n} union GContent(mcs_t(n-1)) where mcs_t(n-1) is the previous iteration's MCS at t
- Extend seed(t, n) to an MCS mcs_t(n) via Lindenbaum
- Verify forward_F is maintained at each step

This is essentially what the **DovetailingChain** approach does, but applied locally rather than globally.

**Estimated complexity**: Medium-high (requires chain-level reasoning within the Zorn framework)
**Sorry risk**: Medium (depends on maintaining invariants through iteration)

#### Approach B: GH-Controlled Lindenbaum (from research-005 Section 8)

**Idea**: Replace standard Lindenbaum extension with a **selective** Lindenbaum that rejects G(psi) unless psi is in ALL relevant domain MCSs, and rejects H(psi) unless psi is in ALL relevant past domain MCSs.

**Construction**:
1. Define "GH-compatible with F at t": S is GH-compatible if for all phi, G(phi) in S implies phi in F.mcs(s') for all s' > t in domain, and similarly for H.
2. The extension seed IS GH-compatible (by forward_G / backward_H of the family).
3. Selective Lindenbaum: when considering phi to add, if phi = G(psi), check that psi is in all relevant MCSs.
4. Prove: the result is still an MCS (for any rejected G(psi), its negation F(neg psi) can be added).

**What this solves**: The new-to-old propagation problem (lines 1786, 1928, 2161, 2168). If we control what G/H formulas enter mcs_t, then forward_G and backward_H from the new time to old times are guaranteed.

**What this does NOT solve**: Seed consistency for pure past/future cases. The seed inconsistency occurs BEFORE Lindenbaum runs.

**Estimated complexity**: High (requires building new Lindenbaum variant with correctness proof)
**Sorry risk**: Medium-low for what it does solve; does not address the seed inconsistency

#### Approach C: Modified Seed Definition (Drop Multi-Witness Requirement)

**Idea**: Modify the extension seed to NOT include all F-obligations simultaneously. Instead:
- Include only SINGLE-witness F-obligations (one phi per source MCS, chosen carefully)
- Or include F-obligations only from ONE source time, not all

**Variant C1**: extensionSeed' = GContent union HContent union {phi_s : for each s < t in domain, choose ONE phi_s where F(phi_s) in mcs(s)}

This is consistent: each {phi_s} union GContent(mcs(s)) is consistent (by `temporal_witness_seed_consistent`). But multiple phi_s from different source times still collect, and GContent from different times propagates to the maximum. So we need: {phi_s1, ..., phi_sk} union GContent(mcs(s_max)) consistent, where each phi_si came from a different source time. By forward_F, each phi_si is in mcs(s_max), so the whole set is a subset of mcs(s_max), hence consistent.

Wait -- this actually WORKS! If forward_F gives phi_si in mcs(s_max) for each i, then the entire collection {phi_s1, ..., phi_sk} is a subset of mcs(s_max), which is consistent.

**The flaw**: This only gives us ONE witness per source time. The construction needs ALL F-obligations satisfied, not just one per source time. After extending to mcs(t), we need: for EVERY phi with F(phi) in mcs(s) and s < t, phi in mcs(t). With only one witness per source, most F-obligations are unsatisfied.

**Variant C2**: Don't include F-obligations in the seed at all. Instead, rely on forward_F being a STRUCTURAL INVARIANT: if forward_F holds in the partial family (universally), then at the boundary, FObligations are unnecessary in the seed because forward_F already ensures phi is in all future domain times.

But at boundary time t: F(phi) in mcs(s) for s < t. We need phi in mcs(t). forward_F requires t in domain, but t is NOT yet in domain. So forward_F does not help.

**Variant C3**: Drop FObligations/PObligations from the seed entirely. Accept that the extension may not satisfy forward_F/backward_P between old and new times. Instead, prove forward_F/backward_P for total families separately.

This changes the theorem structure: instead of proving forward_F at each extension step, prove it only after the family is total (domain = Set.univ). With domain = Set.univ and forward_F holding for all old pairs, we just need forward_F between old and new times. But this is exactly the problem -- we need phi in the new MCS, and the new MCS was built without the F-obligation.

**Estimated complexity**: Low to implement, but does NOT solve the problem
**Sorry risk**: High (shifts sorry to different location without eliminating it)

#### Approach D: Pair-Extension Strategy (Add Two Times Simultaneously)

**Idea**: Instead of adding one time at a time, add TWO times (t and t+1) simultaneously. The F-obligations from s_max go to mcs(t+1), and GContent from mcs(s_max) goes to mcs(t). Then mcs(t) has GContent but no conflicting F-obligations, and mcs(t+1) gets ONE F-obligation at a time.

**Construction for upper boundary**:
1. Build seed(t) = GContent(mcs(s_max)) -- no F-obligations (consistent!)
2. Extend seed(t) to mcs(t) via standard Lindenbaum
3. Build seed(t+1) = {phi_1} union GContent(mcs(t)) where F(phi_1) in some old MCS
4. Extend to mcs(t+1)
5. Continue adding t+2, t+3, etc., each getting one more F-obligation witness

**What this avoids**: Multi-witness inconsistency, since each new time gets ONE witness
**What this requires**: Restructuring the entire Zorn argument to handle multi-time extension, or switching to an explicit chain construction

**Estimated complexity**: Very high (fundamental architecture change)
**Sorry risk**: Low in principle, but very high in practice due to massive refactoring

#### Approach E: Weakened Forward_F (Existential Instead of Universal)

**Idea**: Change forward_F in `GHCoherentPartialFamily` from universal to existential:
```
forward_F : forall s, s in domain -> forall phi,
    F(phi) in mcs(s) -> exists t, t in domain, s < t, phi in mcs(t)
```

This is the standard existence lemma from modal logic: F(phi) in MCS implies there EXISTS a witness time. No universal propagation.

**Impact on seed consistency**: The seed no longer includes all F-obligations. Instead, each F-obligation was already satisfied by some existing domain time. At the extension time t, the seed is just GContent union HContent -- no F/P obligations needed.

**Impact on chain upper bound**: Must prove that existential witnesses are preserved under chain union. If F(phi) in mcs(s) had witness t0 in F_i.domain, then t0 is in the union domain (since F_i.domain subset union domain), and the MCS at t0 is the same (chain agreement). So the witness is preserved. This works!

**Impact on the Zorn argument**: The key simplification is that the extension seed no longer needs F/P obligations. The seed is just GContent union HContent (universal content propagation), which is provably consistent using the existing `GContent_consistent` / `HContent_consistent` lemmas plus propagation.

**Impact on the final theorem**: For a TOTAL family (domain = Set.univ), existential forward_F says: F(phi) in mcs(t) implies exists s > t, phi in mcs(s). This is EXACTLY what the final theorem `temporal_coherent_family_exists_zorn` needs. Universal forward_F is stronger than needed.

**What about forward_F for the EXTENDED family?** With the weakened field:
- Old-to-old: inherited from F
- Old-to-new: F(phi) in mcs(s) for s < t. The witness may be some old domain time s' > s. If s' exists, done. If no witness exists yet, we need to add one at t. But we don't include it in the seed...

THIS IS THE GAP: if the base family has an F-obligation without a witness (because no domain time > s exists), the extension to t SHOULD create that witness. With the weakened approach, we would need to either:
(a) Prove that existential forward_F implies all witnesses already exist in the domain, or
(b) Add the obligation to the seed for the specific unsatisfied F-obligations

Actually, with existential forward_F as a field, ANY F-obligation in the partial family must ALREADY have a witness in the domain. This means the base family can only contain F(phi) if there exists a witness in the domain. For a singleton domain {0}, F(phi) in mcs(0) would require a witness, but no time > 0 exists in the domain. So the base family MCS cannot contain any F(phi)... but any MCS in temporal logic typically contains F-formulas.

**Fatal flaw**: Existential forward_F cannot hold for singleton domains because there are no witnesses. The base case fails.

**Possible fix**: Allow the base family to be a finite "seed family" that already has enough times for all witnesses in mcs(0). But this is a RecursiveSeed-style approach, requiring a complex base construction.

**Estimated complexity**: Medium (architecture change is moderate)
**Sorry risk**: Medium (base case requires careful handling)

#### Approach F: Modified Zorn Target (Weaker Extension Predicate)

**Idea**: Apply Zorn to a WEAKER predicate. Instead of requiring forward_F/backward_P as structural invariants, only require GH-coherence. Then prove forward_F/backward_P for the maximal (total) family.

This is essentially the ORIGINAL v002 design before Phase 2 added forward_F/backward_P. The reason Phase 2 added them was to solve the seed consistency problem. Without them, the seed consistency problem remains: the extension seed includes F/P obligations from multiple source times, leading to the same contradiction.

But the original design recognized that F/P obligations DON'T need to be in the seed if we can prove them as DERIVED properties of total families. The issue is: how does mcs(t) contain phi when F(phi) in mcs(t-1)? In a total family built by Zorn, mcs(t) exists but may not contain phi.

The resolution requires that the construction process ENSURES phi in mcs(t). This is where GH-controlled Lindenbaum enters: if we control the Lindenbaum extension to respect the existing family structure, we can ensure the right formulas end up in each MCS.

**Estimated complexity**: Returns to the pre-Phase-2 state plus controlled Lindenbaum
**Sorry risk**: High (this is the original approach that was abandoned)

### 4. Approach Comparison

| Approach | Seed Consistency | New-to-Old | Base Case | Complexity | Sorry Risk |
|----------|-----------------|------------|-----------|------------|------------|
| A: One-at-a-Time Witness | Solved (single-witness proven) | Requires separate argument | Straightforward | Medium-High | Medium |
| B: GH-Controlled Lindenbaum | NOT solved | Solved | Straightforward | High | Medium-Low |
| C: Modified Seed (no F-obligations) | Solved (trivially) | NOT solved | Straightforward | Low | High (shifts problem) |
| D: Pair-Extension | Solved | Solved | Needs rethinking | Very High | Low in theory |
| E: Weakened Forward_F | Solved | Solved | FAILS for singleton | Medium | Medium |
| F: Weaker Zorn Target | NOT solved | NOT solved | Straightforward | Medium | High |
| **A+B Combined** | **Solved** | **Solved** | **Straightforward** | **High** | **Medium** |

### 5. Literature Context

The standard approach in temporal logic completeness proofs (see Goldblatt, "Logics of Time and Computation"; Blackburn, de Rijke, Venema, "Modal Logic") uses the **Existence Lemma**: for each diamond formula F(phi) in MCS w, there exists an MCS v accessible from w containing phi. The standard proof constructs v by showing {phi} union {chi : G(chi) in w} is consistent, then extending to MCS. This is EXACTLY `temporal_witness_seed_consistent`.

The key difference in the Zorn family approach is that we need a SINGLE MCS at time t that simultaneously witnesses ALL F-obligations from ALL past source times. The standard literature avoids this by:

1. **Building the canonical model with ALL MCSs** as worlds, then defining the accessibility relation. Each F(phi) in w gets its OWN witness world v_{w,phi}. Different witnesses can be at different worlds (times).

2. **Explicit step-by-step construction** (as in the DovetailingChain approach) where each F-obligation is handled one at a time during chain building.

The Zorn approach is non-standard because it tries to build the model incrementally while maintaining invariants. The multi-witness problem is an artifact of this specific construction strategy.

### 6. Analysis of Existing Codebase Infrastructure

**Proven and available**:
- `temporal_witness_seed_consistent` (single F-witness + GContent consistent) -- **Verified via lean_local_search**
- `temporal_witness_seed_consistent_past` (symmetric for P) -- **Verified**
- `GContent_propagates_forward` (4-axiom propagation) -- **Verified**
- `HContent_propagates_backward` (4-axiom propagation) -- **Verified**
- `GContent_consistent` (GContent of MCS is consistent) -- **Verified**
- `HContent_consistent` (HContent of MCS is consistent) -- **Verified**
- `extendFamilyAtUpperBoundary` / `extendFamilyAtLowerBoundary` (extension construction) -- **Present in ZornFamily.lean**
- `CoherentExtensions_chain_has_ub` (chain upper bound for Zorn) -- **Verified**
- `zorn_le_nonempty_0` (Mathlib Zorn) -- **Available via import**

**Sorry sites in ZornFamily.lean** (12 total):
- Lines 844, 874: FALSE lemmas (multi_witness) -- must be deleted or reformulated
- Line 888: Cross-sign seed consistency -- SOLVABLE with existing infrastructure
- Lines 1120, 1260: Pure past/future seed consistency -- BLOCKED (core problem)
- Lines 1764, 1968: Old-to-new forward_F/backward_P -- SOLVABLE via seed inclusion
- Lines 1786, 1928: New-to-old backward_P/forward_F -- REQUIRES controlled Lindenbaum
- Line 2091: Gap case for domain totality -- REQUIRES restructuring
- Lines 2161, 2168: New-to-old G/H from maximal -- REQUIRES controlled Lindenbaum

## Recommended Direction

### Primary Recommendation: Approach A+B (One-at-a-Time + GH-Controlled Lindenbaum)

The most viable path combines two approaches:

**Step 1: GH-Controlled Lindenbaum (Approach B)**
- Define GH-compatibility predicate for sets relative to a partial family and time
- Build modified Lindenbaum that preserves GH-compatibility
- This solves 4 sorry sites (new-to-old propagation: 1786, 1928, 2161, 2168)

**Step 2: Modified Seed (eliminate multi-witness requirement)**
- Delete the false lemmas `multi_witness_seed_consistent_future/past`
- Remove FObligations and PObligations from the extension seed definition entirely
- The seed becomes: GContent(past sources) union HContent(future sources) only
- This is PROVABLY consistent using `GContent_consistent` + propagation
- This solves 3 sorry sites (seed consistency: 888, 1120, 1260)

**Step 3: F/P satisfaction via total family argument**
- For a total family (domain = Set.univ), forward_F follows from the structure:
  F(phi) in mcs(t) implies neg(G(neg(phi))) in mcs(t), so G(neg(phi)) not in mcs(t).
  Need phi in mcs(t+1). Since GH-controlled Lindenbaum ensures forward_G/backward_H,
  and mcs(t+1) is GH-compatible, we need a separate argument that phi ends up in mcs(t+1).
- The key: mcs(t+1) was built from a seed containing GContent(mcs(t)). By `temporal_witness_seed_consistent`, {phi} union GContent(mcs(t)) is consistent. But phi may not be in the seed...

**Important realization**: Even with Step 2, the F/P satisfaction for total families requires that the MCS at t+1 contains the witness phi. Without including phi in the seed, there is no guarantee phi ends up in mcs(t+1).

### Revised Primary Recommendation: Approach D simplified (Extend-Then-Witness)

After deeper analysis, the cleanest approach may be:

1. **Keep the Zorn framework** for building GH-coherent partial families (seed = GContent + HContent only, no F/P obligations)
2. **Prove maximal implies total** using the simplified seed (which IS consistent)
3. **After obtaining a total GH-coherent family, prove F/P as a POST-HOC property**:
   - For total family: F(phi) in mcs(t). Need to show phi in mcs(t+1).
   - The MCS at t+1 was built during the Zorn process. Can we control what it contains?
   - NO -- Zorn gives a non-constructive maximal element. We cannot argue about the construction.

This leads back to the fundamental tension: Zorn gives existence without construction trace, but F/P satisfaction requires construction-level control.

### Final Recommendation: Investigate Hybrid Zorn + Post-Processing

The most promising unexplored direction:

1. Use Zorn to build a total GH-coherent family (without F/P)
2. Post-process the total family to fix F/P violations:
   - For each t and each phi where F(phi) in mcs(t) but phi not in mcs(t+1):
     Replace mcs(t+1) with a NEW MCS extending {phi} union GContent(mcs(t)) union HContent(mcs(t+2))
   - Prove the replacement preserves GH-coherence
   - Iterate until no F/P violations remain (convergence argument needed)

This is speculative and may have its own convergence issues, but separates the GH construction (which works) from the F/P satisfaction (which is the hard part).

## Evidence

| Lemma | Status | Location |
|-------|--------|----------|
| `temporal_witness_seed_consistent` | Proven (no sorry) | TemporalCoherentConstruction.lean |
| `temporal_witness_seed_consistent_past` | Proven (no sorry) | TemporalLindenbaum.lean |
| `GContent_propagates_forward` | Proven (no sorry) | ZornFamily.lean |
| `HContent_propagates_backward` | Proven (no sorry) | ZornFamily.lean |
| `GContent_consistent` | Proven (no sorry) | ZornFamily.lean |
| `HContent_consistent` | Proven (no sorry) | ZornFamily.lean |
| `multi_witness_seed_consistent_future` | FALSE (sorry, cannot be proven) | ZornFamily.lean line 806 |
| `multi_witness_seed_consistent_past` | FALSE (sorry, cannot be proven) | ZornFamily.lean line 849 |
| `extensionSeed_consistent` | Sorry (3 cases: cross-sign solvable, pure cases blocked) | ZornFamily.lean line 876 |
| `CoherentExtensions_chain_has_ub` | Proven | ZornFamily.lean |
| `zorn_le_nonempty_0` | Mathlib (proven) | Mathlib.Order.Zorn |

All lemma existence verified via `lean_local_search` MCP tool.

## Confidence Level

**Medium-Low** on any single approach resolving all sorry sites.

The fundamental tension between Zorn's non-constructive maximality and the constructive nature of F/P witness placement appears to be a deep structural issue with the Zorn family approach. Each alternative either:
- Shifts the sorry to a different location (Approaches C, F)
- Requires complex new infrastructure (Approaches A, B, D)
- Has its own soundness issues (Approach E)

The combination A+B has the best theoretical coverage but the highest implementation cost.

## Remaining Open Questions

1. **Can GH-controlled Lindenbaum be proven to yield an MCS?** The selective rejection of G(psi) when psi not in all future MCSs needs a proof that neg(G(psi)) = F(neg(psi)) can always be safely added. This requires F(neg(psi)) to be consistent with the current set.

2. **Is post-processing a total GH-family to fix F/P violations convergent?** Replacing one MCS to fix an F-violation might break GH-coherence or create new F-violations at adjacent times.

3. **Would abandoning Zorn entirely in favor of explicit construction (refined DovetailingChain) be simpler?** The DovetailingChain has 4 sorry sites for cross-sign propagation, but these are different in nature from the seed inconsistency problem and might be more tractable.

4. **Is there a formulation of forward_F that is weak enough for the base case but strong enough for the final theorem?** Something between universal ("phi in ALL future domain times") and existential ("phi in SOME future domain time").

5. **Can the RecursiveSeed approach (which pre-places all witnesses before Lindenbaum) be completed?** It currently has sorry sites in RecursiveSeed.lean but they appear to be about API compatibility rather than fundamental mathematical gaps.
