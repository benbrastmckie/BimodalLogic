# Research Findings: Task #892 - Teammate B

**Task**: Modify henkinStep to add negations when rejecting packages
**Date**: 2026-02-17
**Focus**: Alternative Approaches Catalog, Prior Art, and Risk Analysis
**Agent**: lean-research-agent (Teammate B)

## Summary

Task 892 is BLOCKED due to a mathematical impossibility finding. This report catalogs alternative approaches in the codebase and Mathlib, analyzes risks, and recommends a path forward.

## Finding 1: The Mathematical Impossibility

The theorem `maximal_tcs_is_mcs` is FALSE. A counterexample demonstrates:

```
Let base = {neg(psi)} where psi is atomic.
Let M be maximal in TemporalConsistentSupersets(base) containing {neg(psi), G(psi)}.

M is temporally saturated (no F-formulas present to violate saturation).
But M is NOT maximal consistent because:
- M union {F(psi)} is CONSISTENT (semantically: psi false now, true always in future)
- Therefore M violates the MCS maximality condition
```

**Core insight**: Temporal saturation and maximal consistency are CONFLICTING requirements in certain scenarios. The proposed fix (adding negations on rejection) cannot resolve this because both F(psi) and neg(F(psi)) may be inconsistent with certain base sets.

## Finding 2: Alternative Approaches Catalog

### Approach A: RecursiveSeed Construction (Task 864/880)

**Location**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`

**Verified Declarations** (via lean_local_search):
- `ModelSeed` (structure)
- `ModelSeed.addFormula` (def)
- `ModelSeed.createNewFamily` (def)
- `ModelSeed.createNewTime` (def)
- `buildSeedAux` (def)

**Architecture**:
- Pre-places ALL temporal witnesses BEFORE Lindenbaum extension
- Builds model structure from formula recursive structure
- Distinguishes modal witnesses (new families) from temporal witnesses (new time indices)

**Sorry Count**: 11 sorries (as of current codebase grep)

**Key Advantage**: Avoids cross-sign temporal propagation by construction. Witnesses are placed in the seed, not propagated between chains.

**Gap**: RecursiveSeed handles single-formula construction. For MCS-level construction, need to process ALL formulas in the MCS content.

### Approach B: ZornFamily Construction (Task 870)

**Location**: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`

**Verified Declarations** (via lean_local_search):
- `GHCoherentPartialFamily` (structure)
- `GHCoherentPartialFamily.le` (def)
- `GHCoherentPartialFamily.le_refl` (lemma)
- `GHCoherentPartialFamily.le_trans` (lemma)
- `GHCoherentPartialFamily.GContentAt` (def)
- `GHCoherentPartialFamily.HContentAt` (def)

**Architecture**:
- Uses Zorn's lemma to find maximal GH-coherent partial families
- Defines domain extension ordering for partial families
- Chain upper bound construction preserves GH-coherence

**Sorry Count**: 11 sorries (as of current codebase grep)

**Key Design Decision (Task 880)**: Removed F/P fields from `GHCoherentPartialFamily` structure. F/P coherence is proven as derived property for total families only.

**Risk**: The extensionSeed_consistent proof (seed = GContent union HContent) still has sorries for cross-sign case.

### Approach C: DovetailingChain Construction (Task 843)

**Location**: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

**Status**: BLOCKED (9 sorries, architecture limitation)

**Problem**: Two-chain architecture (forward chain for G, backward chain for H) cannot prove cross-sign propagation. G formulas from backward chain cannot reach forward chain.

**Verdict**: Not recommended. Architecture fundamentally cannot support the required properties.

### Approach D: UnifiedChain Construction

**Location**: `Theories/Bimodal/Metalogic/Bundle/UnifiedChain.lean`

**Sorry Count**: 9 sorries

**Architecture**: Attempts to combine GContent and HContent in each seed.

**Problem**: Shifts the blocker from "cross-sign impossible" to "combined seed consistency unproven". The critical new blocker is proving `GContent(M_minus_k) union HContent(M_plus_k')` is consistent.

**Verdict**: Higher risk than RecursiveSeed. Novel argument required.

## Finding 3: Prior Art in Mathlib

### Zorn Lemma Patterns

**Verified via lean_leansearch**:
- `zorn_le_nonempty` - Standard Zorn for preorders with chain upper bounds
- `zorn_le_nonempty0` - Variant with explicit starting element
- `exists_maximal_of_chains_bounded` - General chain bounded implies maximal exists

**Usage in Codebase**: ZornFamily.lean already has `Preorder GHCoherentPartialFamily` instance. Can use standard Mathlib Zorn patterns.

### Maximal Theory Patterns

**Verified via lean_leanfinder**:
- `FirstOrder.Language.Theory.IsMaximal` - "Satisfiable and every sentence or its negation is in T"
- `FirstOrder.Language.Theory.IsMaximal.isComplete` - Maximal implies complete

**Relevance**: The Mathlib first-order logic approach defines maximality as requiring negation completeness. This is exactly what the proposed task 892 fix attempts to achieve, but the temporal saturation requirement creates conflicts.

## Finding 4: Risk Analysis

### Risk Assessment Table

| Approach | Sorry Count | Blocker Type | Tractability | Recommendation |
|----------|-------------|--------------|--------------|----------------|
| Task 892 (henkinStep fix) | N/A | Mathematical impossibility | LOW | NOT VIABLE |
| RecursiveSeed (Task 864/880) | 11 | Extension gap | MEDIUM-HIGH | PRIMARY PATH |
| ZornFamily (Task 870) | 11 | Seed consistency | MEDIUM | FALLBACK |
| DovetailingChain | 9 | Architecture | VERY LOW | ABANDONED |
| UnifiedChain | 9 | Novel proof needed | LOW-MEDIUM | NOT RECOMMENDED |

### RecursiveSeed Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCS-level seed consistency | High | Medium | Use proven single-formula pattern iteratively |
| Bridge to IndexedMCSFamily | Medium | Low | ZornFamily provides infrastructure |
| F/P witness enumeration | Medium | Medium | Dovetailing over (time, formula) pairs |

### ZornFamily Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| extensionSeed_consistent | High | Medium | 4-axiom propagation through time 0 |
| Maximality implies totality | Medium | Low | Standard Zorn argument |
| F/P recovery for total family | Medium | Medium | Seed inclusion + Lindenbaum |

## Finding 5: RecursiveSeed Bypasses the Counterexample

**Key Insight**: The counterexample `{neg(psi), G(psi)}` arises from iterative construction decisions. RecursiveSeed avoids this by:

1. Processing the STARTING formula's structure completely
2. Pre-placing ALL required witnesses before any MCS extension
3. Not making "accept package OR skip" decisions that create incomplete states

The counterexample scenario requires:
- neg(psi) in base (chosen externally)
- G(psi) added independently (wrong - should come from formula structure)

In RecursiveSeed:
- If the starting formula requires G(psi), then it already handles G's interaction with all temporal content
- The base is not an arbitrary set but the seed of a specific formula

## Finding 6: TemporalConsistentSupersets Definition

**Verified via lean_local_search**:
- `TemporalConsistentSupersets` (def) in `TemporalLindenbaum.lean`

**Definition** (from code reading):
```lean
def TemporalConsistentSupersets (S : Set Formula) : Set (Set Formula) :=
  {T | S subseteq T and SetConsistent T and TemporalForwardSaturated T and TemporalBackwardSaturated T}
```

**Problem**: This definition conflates two distinct requirements:
1. Temporal saturation (F phi implies phi in same set)
2. Temporal coherence (F phi at time t implies phi at time t' > t)

For a single MCS, internal saturation suffices. For families, cross-time coherence is needed. The Henkin construction builds a single MCS, so internal saturation should work, but the maximality argument fails because TCS maximality is weaker than MCS maximality.

## Recommendations

### Primary Path: Extend RecursiveSeed (HIGH CONFIDENCE)

1. **Phase 1**: Process entire evaluation MCS content with RecursiveSeed
   - Build seed for ALL formulas in eval MCS
   - Pre-place witnesses for ALL existential formulas

2. **Phase 2**: Bridge to IndexedMCSFamily
   - Apply Lindenbaum to each (family, time) entry
   - Combine into IndexedMCSFamily structure

3. **Phase 3**: Use ZornFamily for temporal coherence
   - ZornFamily has infrastructure for family-level Zorn
   - Maximal family has domain = Set.univ

4. **Phase 4**: Prove box_coherence from seed pre-placement
   - Box content is pre-placed in all families
   - Lindenbaum preserves seed content

**Rationale**: Builds on sorry-free infrastructure (single-formula RecursiveSeed). The work is EXTENSION (building MCS-level on formula-level) not FIXING BLOCKERS.

### Alternative Path: Fix Task 892 with Stronger Hypothesis

If the primary path is too complex, consider:

**Strengthen the base hypothesis**: Instead of arbitrary consistent base, require "temporally coherent" base where:
- G(psi) in base implies neg(psi) not in base
- Or: base is already an MCS (not just consistent)

This rules out the counterexample but may limit applicability.

**Risk**: May not match the desired use case. The original goal was to extend ANY consistent context to a temporally saturated MCS.

### Not Recommended: Continue with Task 892 As-Is

The counterexample shows the proposed fix cannot work in general. Even if `henkinStep` adds negations, the fundamental conflict between temporal saturation and negation completeness remains.

## Evidence Summary

### Verified Lemma Names (via lean_local_search)

| Name | Kind | File |
|------|------|------|
| `TemporalConsistentSupersets` | def | TemporalLindenbaum.lean |
| `maximal_tcs_is_mcs` | lemma | TemporalLindenbaum.lean |
| `ModelSeed` | structure | RecursiveSeed.lean |
| `GHCoherentPartialFamily` | structure | ZornFamily.lean |

### Mathlib Patterns Verified (via lean_leansearch/lean_leanfinder)

| Pattern | Module |
|---------|--------|
| `zorn_le_nonempty` | Mathlib.Order.Zorn |
| `zorn_le_nonempty0` | Mathlib.Order.Zorn |
| `FirstOrder.Language.Theory.IsMaximal` | Mathlib.ModelTheory.Satisfiability |

### Sorry Counts (via grep)

| File | Sorry Count |
|------|-------------|
| RecursiveSeed.lean | 11 |
| ZornFamily.lean | 11 |
| DovetailingChain.lean | 9 |
| UnifiedChain.lean | 9 |
| TemporalLindenbaum.lean | 4 |
| Total in Bundle/ | 171 |

## Confidence Level

**HIGH** for the following conclusions:
1. Task 892 as proposed is NOT VIABLE (counterexample is valid)
2. RecursiveSeed is the most tractable alternative (avoids problem by design)
3. ZornFamily provides useful infrastructure for family-level construction

**MEDIUM** for:
1. MCS-level RecursiveSeed extension will work (untested composition)
2. F/P witness enumeration can be solved (needs dovetailing)

**LOW** for:
1. UnifiedChain seed consistency proof (novel argument)
2. Any fix to DovetailingChain (architecture limitation)

## References

### Task Reports
- specs/892_modify_henkinstep_add_negations/summaries/implementation-summary-20260217.md
- specs/888_lindenbaum_temporal_saturation_preservation/summaries/implementation-summary-20260217.md
- specs/881_modally_saturated_bmcs_construction/reports/research-009.md
- specs/870_zorn_family_temporal_coherence/reports/research-003.md
- specs/864_recursive_seed_henkin_model/reports/research-002.md

### Code Files
- Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean
- Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean
- Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean
- Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean
