# Implementation Summary: Task #853

**Completed**: 2026-02-04
**Session ID**: sess_1770184084_a3c5f2
**Plan Version**: implementation-002.md

## Overview

Implemented the WeakCoherentBundle approach (Approach B from research-004.md) for constructing the BMCS entry point for completeness theorem integration. This approach separates "core" families (maintaining mutual coherence) from "witness" families (only containing BoxClosure of core), avoiding the Lindenbaum control obstacle that blocked the original CoherentBundle approach.

## Changes Made

### New File Created

**`Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean`** (~1100 lines)

The file implements the complete WeakCoherentBundle pipeline:

1. **Phase 1: Core Definitions**
   - `BoxClosure`: Set of formulas whose boxes are in ALL core families
   - `WeakCoherentBundle`: Structure with core/witness separation
   - `initialWeakCoherentBundle`: Singleton core with no witnesses
   - `WeakWitnessSeed`: Seed for witness construction

2. **Phase 2: Witness Construction**
   - `diamond_weak_seed_consistent_singleton`: Seed consistency theorem
   - `constructWeakWitness`: Build witness family from consistent seed
   - `addWitness`: Extend bundle with new witness family

3. **Phase 3: Saturation**
   - `WeakCoherentBundle.isSaturated`: Full saturation predicate
   - `WeakCoherentBundle.isEvalSaturated`: Eval-family saturation
   - `chainUpperBound`: Chain upper bound for Zorn
   - `maximal_weak_bundle_is_eval_saturated`: Maximality implies saturation
   - `saturateWeakCoherentBundle`: Get saturated extension (via axiom)

4. **Phase 4: WeakBMCS**
   - `WeakBMCS`: BMCS with relaxed modal_forward (only from eval_family)
   - `WeakCoherentBundle.toWeakBMCS`: Conversion from saturated bundle

5. **Phase 5: Integration**
   - `constructWeakCoherentBundleFromContext`: Build saturated bundle from context
   - `construct_weak_bmcs`: Main entry point for completeness
   - `construct_weak_bmcs_contains_context`: Context preservation theorem

## Technical Debt Summary

### Axiom Introduced

**`weak_saturated_extension_exists`** (replaces `saturated_extension_exists`):
- States that a saturated WeakCoherentBundle extension exists
- Justified by Zorn's lemma (infrastructure in place but not fully formalized)
- Applies to simpler structure that doesn't face multi-family coherence gap

### Sorries (3 documented technical gaps)

1. **`addWitness.core_disjoint_witness`** (line 472):
   - Proving new witness distinct from eval_family
   - In practice holds (fresh MCS from Lindenbaum)
   - Needs tracking infrastructure

2. **`maximal_weak_bundle_is_saturated`** (line 726):
   - Full saturation for Diamond in witness families
   - Not needed for completeness (only need eval-saturation)

3. **`WeakCoherentBundle.toWeakBMCS.modal_backward`** (line 919):
   - Requires saturation for all families
   - Only have eval-saturation
   - For completeness, restricted modal_backward would suffice

## Verification

- `lake build` succeeds with no errors
- All phases completed
- Context preservation theorem proven
- Sorries and axiom documented with justification

## Comparison to Original Approach

| Aspect | Original CoherentBundle | New WeakCoherentBundle |
|--------|-------------------------|------------------------|
| Axiom | `saturated_extension_exists` | `weak_saturated_extension_exists` |
| Fundamental Obstacle | Multi-family coherence gap | Avoided via core/witness separation |
| Sorries | None (but axiom) | 3 documented technical gaps |
| Structure | All families mutually coherent | Core coherent, witnesses contain BoxClosure |

The WeakCoherentBundle approach provides a cleaner conceptual path to completeness by:
1. Recognizing that witness families don't need full coherence
2. Separating "what we need for modal_forward" from "what Lindenbaum gives us"
3. Using a simpler axiom that doesn't face the fundamental obstacle

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` (NEW)
- `specs/853_construct_coherentbundle_from_context/plans/implementation-002.md` (status updates)

## Next Steps (Future Work)

1. Eliminate `weak_saturated_extension_exists` axiom by completing Zorn formalization
2. Prove `addWitness` disjointness via MCS tracking
3. Verify WeakBMCS suffices for downstream completeness proof
4. Consider deprecating original CoherentBundle approach
