# Teammate A: Systematic Implementation Analysis

**Task**: 870 - Zorn-based family selection for temporal coherence
**Date**: 2026-02-12
**Session**: sess_1770947549_cdaca1
**Analyst**: lean-research-agent (teammate-a)

## Summary

Task 870 has undergone four major implementation revisions (v001-v004), each discovering fundamental mathematical obstacles that invalidated the previous approach. The core insight across all failures is that **Zorn's lemma provides existence without construction trace**, making it impossible to track F/P witness placement. The viable path forward is limited to the cross-sign case (both past and future domain times exist), while pure boundary extensions have been proven mathematically impossible for certain families.

## Implementation Timeline

### v001: Original Zorn Approach

**Strategy**: Define `CoherentPartialFamily` with all four temporal properties (forward_G, backward_H, forward_F, backward_P) as structural fields. Apply Zorn's lemma to find a maximal coherent partial family, prove maximality implies totality (domain = Set.univ).

**Failure Mode**:
- **Root cause**: Base family impossibility (lines ~606, 610)
- **Problem**: A singleton domain {0} cannot satisfy forward_F or backward_P because there are no witnesses s > 0 or s < 0 in the domain
- **Discovery**: The structural fields forward_F/backward_P are impossible for finite partial domains

**Lesson**: Existential witness requirements (F/P) cannot be satisfied by partial families with bounded domains. The seed at any extension time needs witnesses that don't yet exist.

**Surviving Infrastructure**:
- Basic `GHCoherentPartialFamily` structure concept
- Partial order definition (`F.le G` = domain inclusion + MCS agreement)
- Chain upper bound construction pattern

---

### v002: Remove F/P from Structure

**Strategy**: Remove forward_F and backward_P from the structure entirely. Only require G/H coherence for partial families. F/P becomes a derived property for total (domain = Set.univ) families after Zorn gives maximality.

**Key insight**: G/H are **universal** properties (hold for all pairs in domain), which work for partial families. F/P are **existential** properties that only make sense once the domain is complete.

**Failure Mode**:
- **Root cause**: Extension seed consistency (lines ~512-526 in original)
- **Problem**: The extension seed combines formulas from multiple source MCSs, but consistency cannot be proven without a single reference MCS containing all elements
- **Technical sorries**: Cross-sign case, pure past case, pure future case

**Lesson**: Removing F/P from structure simplifies base family (vacuous G/H for singleton domain), but the seed consistency problem emerges as the new blocker. The key issue: how to prove `GContent from past + HContent from future + FObligations + PObligations` is consistent?

**Surviving Infrastructure**:
- `GHCoherentPartialFamily` structure (G/H only)
- `instance : Preorder GHCoherentPartialFamily` for Mathlib Zorn integration
- `buildBaseFamily` with vacuous G/H coherence
- `chainUpperBound` construction (fully proven)
- `zorn_maximal_exists` theorem

---

### v003: Boundary-Only Domain Extension

**Strategy**: Instead of extending at arbitrary times, only extend at **boundary times** (t greater than ALL or less than ALL domain elements). At boundary times, problematic forward_G/backward_H cases become vacuously true.

**Key insight**: G does NOT distribute over disjunction (critical discovery that invalidated v002's multi-witness approach):
```
G(rain or snow) can be true (at all future times, it rains or snows)
But G(rain) and G(snow) can both be false (neither always happens)
```

**Failure Mode**:
- **Phase 1 (Boundary Infrastructure)**: COMPLETED - added `isUpperBoundary`, `isLowerBoundary`, `isBoundaryTime` predicates
- **Phase 2 (Maximal Implies Totality)**: PARTIAL - `non_total_has_boundary` is FALSE for domains with internal gaps (line ~1607/2091)
- **Phase 3 (Seed Consistency)**: PARTIAL - cross-sign case SOLVABLE, but pure past/future cases BLOCKED
- **Phase 4 (F/P Recovery)**: PARTIAL - 2 sorries isolated to `total_family_FObligations_satisfied` and `total_family_PObligations_satisfied`

**Lesson**: Boundary-only extension eliminates 2 sorries (forward_G/backward_H from new time are vacuous at boundaries), but creates a new problem: domains with internal gaps have no boundary times. Also, F/P recovery requires construction trace that Zorn hides.

**Surviving Infrastructure**:
- `extendFamilyAtUpperBoundary` and `extendFamilyAtLowerBoundary` (both proven for G/H coherence)
- `extendFamilyAtBoundary` dispatcher
- `boundarySeed` definition (one-directional content)
- Cross-sign seed consistency argument (documented, SOLVABLE)

---

### v004: Strengthened Family (Universal forward_F)

**Strategy**: Add universal forward_F and backward_P back to the structure, but with a different semantics:
```lean
forward_F : forall s t, s in domain -> t in domain -> s < t ->
    forall phi, Formula.some_future phi in mcs s -> phi in mcs t
```
This says F phi at s implies phi at ALL future domain times t, not just some. This enables the "collect-into-one-MCS" argument for seed consistency.

**Failure Mode** (discovered in Phase 4, documented in research-006):
- **Root cause**: `multi_witness_seed_consistent_future` is mathematically FALSE (line 844)
- **Counterexample**: Let M be an MCS containing both `F(p)` and `F(neg p)` (consistent in temporal logic because witnesses can be different times). Then Psis = [p, neg p] and the seed `{p, neg p} union GContent(M)` is INCONSISTENT because {p, neg p} derives bottom directly.

**Task 880 Discovery**: Universal forward_F is **incompatible with domain extension**
- **Proof**: Base family domain = {0} with `F(p) in mcs(0)` and `F(neg p) in mcs(0)`
- Attempt to extend to domain = {0, 1}
- Universal forward_F requires: `p in mcs(1)` AND `neg p in mcs(1)`
- This contradicts mcs(1) being maximal consistent

**Lesson**: The strengthened family strategy creates a Catch-22: universal forward_F enables seed consistency argument but prevents domain extension. No partial family with conflicting F-obligations can ever be extended.

**Surviving Infrastructure**:
- Dead code deleted (extendFamily, extendFamily_strictly_extends)
- Cross-sign case remains viable
- Architectural documentation of why maximality is vacuous for total families

---

## Common Failure Pattern

All four approaches share a fundamental problem: **Zorn's lemma provides existence without construction trace**.

The F/P witness problem requires knowing:
1. WHICH formulas F phi are in WHICH MCSs
2. WHERE to place the witness phi
3. HOW to ensure consistency when multiple F-obligations conflict

Zorn gives us a maximal element non-constructively. We cannot trace:
- How each MCS was built
- Which seed was used at each extension step
- Whether F-obligations were properly witnessed

The single-witness case works (`temporal_witness_seed_consistent`):
- If `F(psi) in M`, then `{psi} union GContent(M)` is consistent
- Proof: Assume inconsistent -> GContent(M) derives neg(psi) -> F(psi) inconsistent with M -> contradiction

The multi-witness case fails:
- `{p} union GContent(M)` consistent (by single-witness)
- `{neg p} union GContent(M)` consistent (by single-witness)
- But `{p, neg p} union GContent(M)` INCONSISTENT (p and neg p directly contradict)

---

## Salvageable Components

The following lemmas/infrastructure remain mathematically valid and reusable:

### Fully Proven (No Sorry Dependencies)

1. **GHCoherentPartialFamily structure** - G/H-only coherence works for partial domains
2. **Preorder instance** - Correct for Mathlib Zorn integration
3. **chainUpperBound** - Chain union preserves G/H coherence
4. **coherent_chain_has_upper_bound** - Zorn condition satisfied
5. **zorn_maximal_exists** - Maximal GH-coherent family exists
6. **buildBaseFamily** - Singleton domain with vacuous G/H
7. **GContent_consistent**, **HContent_consistent** - Content extractors preserve consistency
8. **GContent_propagates_forward**, **HContent_propagates_backward** - 4-axiom propagation

### Viable for Cross-Sign Case Only

1. **extensionSeed_consistent (cross-sign case)** - When both past and future domain times exist:
   - All past elements collect into mcs(s_max)
   - All future elements collect into mcs(s_min)
   - Since s_max < t < s_min, propagation connects them
   - Everything ends up in mcs(s_min), which is consistent

2. **Boundary extension infrastructure** - Works when boundary times exist

### Invalid / Must Be Deleted

1. **multi_witness_seed_consistent_future** - Mathematically FALSE
2. **multi_witness_seed_consistent_past** - Mathematically FALSE
3. **non_total_has_boundary (gap case)** - FALSE for domains like Z \ {0}
4. **Universal forward_F/backward_P fields** - Incompatible with extension

---

## Constraints Discovered

Any viable solution to the temporal coherent family existence problem must satisfy ALL of these constraints:

### Hard Constraints (Proven Necessary)

1. **No universal F/P propagation**: Cannot require that F phi at s implies phi at ALL future times. This prevents extension.

2. **Single-witness only**: Can only place ONE F-witness at a time. Multi-witness placement leads to inconsistent seeds.

3. **Cross-sign requires both directions**: When extending at time t with domain times on both sides, consistency comes from collecting into an existing MCS. This REQUIRES both past and future domain times.

4. **Domains may have unfillable gaps**: Not every partial family can be extended. Families with conflicting F-obligations at boundaries cannot grow.

5. **Zorn hides construction trace**: The maximal element gives no information about HOW it was built or whether F/P obligations were witnessed.

### Soft Constraints (Design Choices)

6. **G/H coherence works universally**: Can require G/H propagation for all domain pairs.

7. **Boundary extension simplifies G/H**: At boundary times, one direction of G/H propagation is vacuous.

8. **4-axiom enables content propagation**: G phi -> GG phi allows collecting GContent across times.

---

## Confidence Level

**Medium-High**: The analysis is based on:
- Complete reading of all 4 implementation plans
- All 3 implementation summaries
- Research reports 001-007
- Current ZornFamily.lean source code (sorry locations verified)
- Task 880 team research findings on universal forward_F incompatibility

The counterexamples proving false lemmas are concrete and verifiable. The architectural analysis of why Zorn hides construction trace is well-established in the research reports.

**Remaining uncertainty**: Whether DovetailingChain approach can succeed where Zorn fails (different sorry pattern, explicit construction).

---

## References

- Implementation plans: `specs/870_zorn_family_temporal_coherence/plans/implementation-{001-004}.md`
- Implementation summaries: `specs/870_zorn_family_temporal_coherence/summaries/*.md`
- Research reports: `specs/870_zorn_family_temporal_coherence/reports/research-{001-007}.md`
- Source code: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` (~2300 lines, 5 sorries currently)
- Task 880: `specs/880_augmented_extension_seed_approach/` (team research on universal forward_F)
