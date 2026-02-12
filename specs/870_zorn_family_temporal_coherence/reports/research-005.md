# Research Report: Task #870 (Sorry Elimination Analysis)

**Task**: 870 - Zorn-based family selection for temporal coherence
**Date**: 2026-02-12
**Focus**: Identify the best path to a sorry-free proof
**Session**: sess_1770916498_37a95c

## Summary

After detailed analysis of all 9 sorry sites in ZornFamily.lean (2303 lines), I identify three distinct sorry clusters and propose **one unified resolution strategy**: strengthen `GHCoherentPartialFamily` by adding universal-style `forward_F` and `backward_P` fields. This eliminates ALL remaining sorries through a cascade of simplifications, most critically making seed consistency provable by collecting finite subsets into a single reference MCS. The `non_total_has_boundary` lemma must also be restructured since it is false for domains with internal gaps.

## Findings

### 1. Sorry Dependency Graph

The 9 sorry sites form three dependency clusters:

**Cluster 1: Multi-witness seed consistency (root cause)**
- Line 770: `multi_witness_seed_consistent_future` (hard case with F-obligations from L)
- Line 800: `multi_witness_seed_consistent_past` (symmetric)
- Line 814: `extensionSeed_consistent` (cross-sign case: both past and future domain elements)
- Line 1046: `extensionSeed_consistent` (pure past, F-obligations from different source times)
- Line 1186: `extensionSeed_consistent` (pure future, P-obligations from different source times)

**Cluster 2: Domain totality**
- Line 1999: `non_total_has_boundary` (gap case: domain elements on both sides of t)

**Cluster 3: F/P recovery and propagation**
- Line 2069: `maximal_implies_total` h_G_from_new (forward_G from new time to old domain)
- Line 2076: `maximal_implies_total` h_H_from_new (backward_H from new time to old domain)
- Line 2170: `total_family_FObligations_satisfied` (F phi in mcs(s), need phi in mcs(t) for t > s)
- Line 2186: `total_family_PObligations_satisfied` (symmetric for P)

**Dead code sorries** (do not contribute to the final theorem):
- Line 1598: `extendFamily` forward_G (in unused general extension function)
- Line 1629: `extendFamily` backward_H (in unused general extension function)

The general `extendFamily` (lines 1561-1646) and its associated `extendFamily_strictly_extends` lemma are never called from `maximal_implies_total` or any other proof in the dependency chain of the main theorem. The proof uses `extendFamilyAtBoundary` instead. These two sorries can be eliminated by deleting the dead code.

### 2. Root Cause Analysis

**Cluster 1 (seed consistency)**: The multi-witness problem arises because the extension seed collects formulas from MULTIPLE source MCSs. GContent from time s1 and FObligations from time s2 end up in the same seed, but without a single reference MCS containing all of them, consistency cannot be directly argued. The previous proof sketch assumed G distributes over disjunction (it does not -- identified in research-004).

**Cluster 2 (gap case)**: The lemma `non_total_has_boundary` claims every non-total domain has a boundary time. This is FALSE. Counterexample: domain = Z \ {0}. All integers except 0 are in the domain, with elements both above and below every candidate boundary time.

**Cluster 3 (F/P recovery)**: When domain = Set.univ, maximality is vacuous (any extension must agree on all of Z). F/P satisfaction is a construction invariant: the seed at time t includes FObligations, so the MCS built from it should contain the obligated formulas. But Zorn's lemma hides the construction trace, giving only the existence of a maximal element.

### 3. The Strengthened Family Strategy

**Proposed change**: Add two new fields to `GHCoherentPartialFamily`:

```
forward_F : forall s t, s in domain -> t in domain -> s < t ->
    forall phi, Formula.some_future phi in mcs s -> phi in mcs t
backward_P : forall s t, s in domain -> t in domain -> t < s ->
    forall phi, Formula.some_past phi in mcs s -> phi in mcs t
```

These are **universal** versions of F/P (like G/H), stating that F phi at s implies phi at ALL future domain times, not just some. For partial families, this is achievable:

**Base family** (domain = {0}): Vacuously true -- no pairs s < t in {0}.

**Chain upper bound**: Preserves forward_F. Given F phi in mcs(s) at time s in the union, some chain element F_i contains s. Given t in the union, some F_j contains t. Since F_i and F_j are comparable (chain), either F_i <= F_j or F_j <= F_i. In both cases, s and t end up in the larger family, which satisfies forward_F, so phi in mcs(t). The MCS values agree across the chain by the partial order definition.

**Why this solves Cluster 1 (seed consistency)**: For any finite list L from the extension seed, each element comes from GContent(mcs(s_i)), HContent(mcs(s_j)), FObligations with source s_k, or PObligations with source s_l, where all source times are in the domain. Given finitely many source times:

- Take s_max = maximum among all "past" source times (those < t)
- Take s_min = minimum among all "future" source times (those > t)
- If only past sources: all GContent propagates forward to s_max; all F-obligation formulas are in mcs(s_max) by universal forward_F; entire L subset of mcs(s_max) which is consistent.
- If only future sources: symmetric with s_min and backward_P.
- If both past and future sources: collect past elements into mcs(s_max) and future elements into mcs(s_min). Since s_max < t < s_min, by forward_G, GContent elements from s_max are also in mcs(s_min). By forward_F, F-obligation elements from s_max are in mcs(s_min). So all elements end up in mcs(s_min), which is consistent.

**Why this solves Cluster 3 (F/P recovery)**: With domain = Set.univ, universal forward_F directly gives: F phi in mcs(s), t > s implies phi in mcs(t). This IS `total_family_FObligations_satisfied`.

**Why this helps with Cluster 2**: `non_total_has_boundary` must be dropped. Instead, `maximal_implies_total` proceeds: given t not in domain, build extension seed, prove it consistent (using the strengthened family per above), extend to MCS, construct extended family. The extended family must also satisfy forward_F and backward_P. This is verified by: for the new time t, F phi in mcs_t implies phi in mcs(s') for s' > t in old domain. This follows because the seed includes FObligations: phi is already in the seed, hence in mcs_t. Wait -- that's circular: we're trying to prove forward_F for the extended family including t, using the fact that phi is in the seed.

### 4. Resolving the Extension Forward_F Problem

For the extended family (domain union {t}), forward_F requires:
- Old-to-old: inherited from F's forward_F
- Old-to-new: F phi in mcs(s) for s < t implies phi in mcs_t. Since phi is in FObligations(F, t), hence in the seed, hence in mcs_t. **Provable.**
- New-to-old: F phi in mcs_t for some s' > t in domain implies phi in F.mcs(s'). **Not directly provable** from the seed structure -- mcs_t can contain F phi not present in any old MCS.
- New-to-new: vacuous (only one new time t)

The new-to-old case is the remaining difficulty. At a **boundary time**:
- Upper boundary (t > all domain): no old s' > t, so new-to-old is vacuous.
- Lower boundary (t < all domain): need F phi in mcs_t implies phi in F.mcs(s') for all s' > t.

For a lower boundary: F phi = neg(G(neg(phi))). If F phi is in mcs_t and G(neg(phi)) is NOT in mcs_t, then neg(phi) might not propagate. But mcs_t extends a seed that includes HContent from all future domain times. phi would need to be in the HContent or derivable from the seed structure.

**This is the irreducible problem**: the Lindenbaum extension can introduce F phi for arbitrary phi, and we cannot guarantee phi propagates to future domain times.

### 5. Seed-Controlled Extension (Resolution of New-to-Old)

The solution is to control what F/P formulas can appear in mcs_t by augmenting the seed with **negative constraints**:

For each phi where phi is NOT in F.mcs(s') for some future s' in domain, include neg(some_future phi) in the seed. This ensures F phi CANNOT be in mcs_t (since both F phi and neg(F phi) cannot be in a consistent set).

Equivalently, add: for each future s' in domain, for each phi not in F.mcs(s'), the formula G(neg(phi)) (which is neg(F phi)) to the seed. This ensures the Lindenbaum extension cannot add F phi if phi is absent from any future MCS.

But this makes the seed much larger. Consistency: for a finite L from the augmented seed, the new elements are G(neg(phi_i)) where phi_i not in F.mcs(s'_i). Since F.mcs(s'_i) is an MCS, neg(phi_i) in F.mcs(s'_i), hence G(neg(phi_i)) is derivable from the 4-axiom if G(neg(phi_i)) is in F.mcs(s'_i). Wait, we need G(neg(phi_i)) in F.mcs(s'_i), but phi_i not in F.mcs(s'_i) only means neg(phi_i) in F.mcs(s'_i), not G(neg(phi_i)).

This approach doesn't easily work because we can't guarantee G(neg(phi)) is in any existing MCS.

### 6. Alternative: Modified Seed with HContent Maximization

A cleaner approach for the lower boundary: the seed at a lower boundary contains HContent from all future domain times and PObligations. After Lindenbaum extension, we need: if G phi in mcs_t, then phi in F.mcs(s') for s' > t.

**Key observation**: At a lower boundary, the seed contains HContent(mcs(s')) for all s' > t. HContent(mcs(s')) = {phi : H phi in mcs(s')}. By the 4-axiom for H, if H phi in mcs(s'), then HH phi in mcs(s'), so H phi in HContent(mcs(s')). This means H(HContent) is in the seed.

If we additionally include **GContent from future times** in the seed: for s' > t, GContent(mcs(s')) = {phi : G phi in mcs(s')}. Include these in the seed. Then if phi is in GContent(mcs(s')), G phi is in mcs(s'), so by the T-axiom phi is in mcs(s'). By forward_G from s' onward, phi is in all later domain MCSs.

But wait -- at a lower boundary, the seed definition `extensionSeed` does NOT include GContent from future times. It only includes GContent from PAST times (s < t). At a lower boundary, there are no past times, so GContent is empty.

**Proposed fix**: Modify the extension seed to additionally include GContent from future times:

```
extensionSeed_augmented F t :=
  (original extensionSeed) ∪
  (Union s in {s | s in domain, t < s}, GContent(mcs s)) ∪
  (Union s in {s | s in domain, s < t}, HContent(mcs s))
```

Wait, the original seed already includes HContent from future times. The missing piece is GContent from future times and HContent from past times.

Actually, including GContent from future times in the seed ensures: any phi where G phi is in some future MCS is already in the seed. Then mcs_t (extending the seed) contains phi. For forward_G from t to s': if G phi in mcs_t, we need phi in F.mcs(s'). If G phi was in the seed (from GContent of some future s''), then phi is in the seed, hence in mcs_t. But we also need phi in F.mcs(s'), which follows from the existing forward_G of F (G phi in mcs(s'') with s'' in domain, s' in domain, s'' < s' or s' < s'' -- depends on ordering).

Hmm, this is getting complicated. Let me consider the simplest approach.

### 7. Recommended Strategy: Strengthened Family + Boundary-Only Extension + Direct F/P

**Overall approach**:

1. **Add universal forward_F and backward_P** to `GHCoherentPartialFamily`

2. **Prove chain upper bound** preserves all four properties (straightforward as analyzed)

3. **Delete `non_total_has_boundary`** and rewrite `maximal_implies_total`:
   - Given t not in domain, determine if t is a boundary or gap
   - If boundary: use boundary extension (existing infrastructure)
   - If gap: use general extension with strengthened seed
   - In both cases, seed consistency follows from the strengthened family
   - For boundary forward_F in extended family: new-to-old is vacuous for the non-problematic direction; for the other direction, use augmented seed with GContent/HContent from both directions

4. **Augment the extension seed** at boundary times:
   - Upper boundary: include HContent from ALL domain times (not just future) -- at upper boundary, this IS all domain times since all are < t. Wait, HContent requires s > t, but there are no such s. So actually, at upper boundary, HContent is empty and GContent covers everything. The forward_F new-to-old issue doesn't arise (no old s' > t).
   - Lower boundary: include GContent from ALL domain times. At lower boundary, all domain > t. Include GContent(mcs(s')) for s' > t. Then for forward_G from t to s' > t: phi in GContent(mcs(s'')), G phi in mcs(s''), by forward_G phi in mcs(s'). And GContent is already in the seed (with the augmentation), so G phi in mcs_t implies phi in mcs_t (by T-axiom on GContent membership in the MCS).

   Wait, I'm confusing myself. Let me be precise:
   - Lower boundary seed (augmented) = HContent_from_future ∪ PObligations ∪ **GContent_from_future**
   - GContent_from_future includes phi where G phi in mcs(s') for some s' > t
   - The Lindenbaum extension mcs_t extends this seed
   - For forward_G from t: if G phi in mcs_t, need phi in F.mcs(s') for s' > t
   - G phi in mcs_t might not be in the seed. Lindenbaum can add G phi independently.
   - So we STILL can't guarantee forward_G from the new time.

   **The fundamental obstruction**: Lindenbaum extension is uncontrolled. We cannot prevent it from adding arbitrary G or H formulas.

### 8. The Real Solution: Controlled Lindenbaum Extension

Instead of standard Lindenbaum (which extends to an arbitrary MCS), use a **GH-controlled Lindenbaum** that additionally preserves a "GH-compatibility" property with the existing family.

Define: a set S is **GH-compatible with F at t** if:
- For all phi, if G phi in S and s' > t with s' in domain, then phi in F.mcs(s')
- For all phi, if H phi in S and s' < t with s' in domain, then phi in F.mcs(s')

The extension seed is GH-compatible with F at t (by construction: GContent from past propagates via forward_G, HContent from future propagates via backward_H, and FObligations/PObligations don't introduce G/H formulas directly).

**Claim**: GH-compatibility is preserved by Lindenbaum. During Lindenbaum, we process formulas one at a time. When considering whether to add phi to the current set S:
- If phi = G psi: only add if psi in F.mcs(s') for all s' > t in domain
- If phi = H psi: only add if psi in F.mcs(s') for all s' < t in domain
- Otherwise: add if consistent

This gives a **selective Lindenbaum extension**. The result is maximally consistent among GH-compatible extensions.

**Is the result still an MCS?** Yes, if we can show: for any phi NOT added, neg(phi) can be added. If phi = G psi is rejected because psi not in some F.mcs(s'), then neg(G psi) = F(neg(psi)) should be addable. Since psi not in F.mcs(s'), neg(psi) in F.mcs(s') (MCS property). So F(neg(psi)) is consistent with the existing MCS at s'. But is F(neg(psi)) consistent with the current seed?

Actually, checking: we need neg(G psi) = neg(all_future psi) in the extension. In the MCS, this means the MCS contains neg(all_future psi). Is the set S union {neg(all_future psi)} consistent? Since psi is NOT in F.mcs(s'), and S is GH-compatible meaning it doesn't force G psi (since it would require psi in F.mcs(s')), adding neg(G psi) should be safe. But this requires a formal argument.

This is complex but feasible. It's essentially a modified Lindenbaum that respects temporal constraints.

### 9. Simplest Viable Path

After this extensive analysis, the simplest viable path is:

**Phase 1: Strengthen the structure** (estimated 4-6 hours)
- Add `forward_F` and `backward_P` (universal versions) to `GHCoherentPartialFamily`
- Verify base family still works (vacuous for singleton)
- Update chain upper bound proof (should be straightforward)
- Update all downstream lemmas that construct families

**Phase 2: Prove seed consistency** (estimated 3-4 hours)
- With the strengthened family, prove `extensionSeed_consistent` using the "collect into one MCS" argument
- This eliminates ALL 5 sorry sites in Cluster 1
- Eliminate `multi_witness_seed_consistent_future/past` (no longer needed as standalone theorems, or prove them as corollaries)

**Phase 3: Controlled Lindenbaum extension** (estimated 6-8 hours)
- Define GH-compatibility predicate
- Prove GH-compatible Lindenbaum extension exists (modify TemporalLindenbaum)
- Prove the result is an MCS that satisfies forward_G/backward_H with the family
- This eliminates sorry sites in Cluster 3 (lines 2069, 2076)

**Phase 4: Restructure maximal_implies_total** (estimated 3-4 hours)
- Drop `non_total_has_boundary` (it's false for gap domains)
- Use general extension with GH-compatible Lindenbaum
- Handle boundary and gap cases uniformly
- Eliminates sorry at line 1999

**Phase 5: F/P recovery** (estimated 1-2 hours)
- With universal forward_F in the structure, F/P recovery is direct
- `total_family_FObligations_satisfied` follows from forward_F with domain = Set.univ
- Eliminates sorries at lines 2170, 2186

**Phase 6: Cleanup** (estimated 1-2 hours)
- Delete dead code (extendFamily, extendFamily_strictly_extends)
- Delete or simplify multi_witness_seed_consistent theorems
- Verify `lake build` has 0 sorry warnings in ZornFamily.lean

**Total estimated effort**: 18-26 hours across 6 phases

### Alternative Approaches (Not Recommended)

**Alternative A: Fix DovetailingChain instead**
- DovetailingChain has 4 sorries with similar cross-sign issues
- The explicit construction makes it harder, not easier, to prove cross-sign coherence
- Does not solve the F/P witness problem

**Alternative B: Accept sorries as documented technical debt**
- 9 sorries is significant; they represent real gaps in the proof
- The main theorem `temporal_coherent_family_exists_zorn` is not actually proven
- This delays the problem rather than solving it

**Alternative C: Hybrid Zorn + explicit construction**
- Use Zorn for the GH-coherent part, then an explicit pass for F/P
- Adds complexity without clear benefit over the strengthened family approach

## Recommendations

1. **Proceed with the Strengthened Family Strategy** (Phases 1-6 above)
2. **Start with Phase 1** (add forward_F/backward_P) as it validates the entire approach
3. **Phase 3 (controlled Lindenbaum) is the highest-risk phase** -- prototype first
4. **Delete dead code** (extendFamily and extendFamily_strictly_extends) immediately to reduce confusion
5. **Create a new implementation plan v004** based on this analysis

## References

- Previous research: research-001.md through research-004.md
- Key code: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` (2303 lines)
- Single-witness proof: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (temporal_witness_seed_consistent)
- Controlled Lindenbaum precedent: `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (Henkin construction with temporal saturation)
- Mathlib Zorn: `zorn_le_nonempty₀` from `Mathlib.Order.Zorn`
- DovetailingChain: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (4 sorries)

## Next Steps

1. Create plan v004 incorporating the strengthened family strategy
2. Implement Phase 1 as a proof-of-concept (can be done independently)
3. If Phase 1 succeeds, proceed with Phases 2-6
4. If the controlled Lindenbaum (Phase 3) proves too difficult, consider the "augmented seed" approach as a fallback (include negative GH constraints in the seed)
