# Phase 2 Blocked Handoff - Task 273

## Status
Phases 2-3 are BLOCKED. Phase 1 (SemanticBridge) was completed in a previous session.

## What Was Done This Session

1. **Deep analysis of the blocker**: The sorry in `stavi_expressive_completeness` enters through `nf_2var_from_interval_data` (the "bridge lemma") at StaviCompleteness.lean lines 2353 and 2435. These require a 4-variable existential transfer that reduces to the n-variable Fraisse game argument. Four distinct approaches were analyzed:
   - Direct Kamp translation by structural induction on MonadicFormula
   - Classical NF characterization using Doets + separation theorem
   - Fixing the bridge lemma via strong induction on depth with generalized zone matching
   - Z-specific bridge lemma using ordered interval type sequences

2. **Infrastructure created**: `KampTranslation.lean` with sorry-free helpers:
   - `formula_conjList` / `formula_disjList` with correctness theorems
   - `atom_literal` for predicate-to-temporal-formula translation
   - `nf_depth0_char_formula` characterizing depth-0 NFs as temporal formulas

3. **Blocker documented**: Detailed in plan file Phase 2 heading.

## Root Cause of the Block

The sorry at StaviCompleteness.lean:2353 needs:
```
(exists w, nf_eval_nf M j' 4 (w::u::x::t) sub_nf) <->
(exists w', nf_eval_nf M' j' 4 (w'::u'::x'::t') sub_nf)
```

This is a 4-variable existential transfer at depth j' < k. The proof requires zone matching for 3 reference points with **interval splitting**: choosing u' to split interval types consistently between the two structures. The existing `zone_match_witness` only handles 2 reference points without interval splitting.

The fundamental issue: `interval_nf_types` is a `Finset` (set, not sequence). Zone matching finds u' with the right NF type but doesn't guarantee the sub-interval types split the same way. On a general linear order, types in (x',t') may be interleaved differently than in (x,t) even though the type SETS match.

## Three Identified Approaches

### Approach A: Generalized n-variable Bridge Lemma (Recommended)
- Prove `nf_2var_from_interval_data` by strong induction on depth k
- At each level, generalize zone matching to include interval splitting
- The interval splitting lemma: given matching interval type sets and a splitting point u, find u' that splits (x',t') with the same sub-interval type sets
- Estimated effort: 400-600 lines
- Key file: `StaviCompleteness.lean` (fill sorry at lines 2353, 2435)

### Approach B: Z-Specific Bridge Lemma
- Strengthen `interval_nf_types` to track ordered sequences for Z-structures
- On Z, intervals are finite ordered sequences, so interval splitting is straightforward
- Prove bridge lemma for Z, then transfer to Prior structures via SemanticBridge
- Estimated effort: 300-500 lines
- Creates a new file, doesn't modify StaviCompleteness.lean

### Approach C: Direct Kamp Translation (Most Ambitious)
- Build the quantifier elimination procedure following GHR94 Chapter 10.3
- Avoids NFs entirely; works directly with formula induction + separation theorem
- Estimated effort: 1000+ lines
- Cleanest mathematically but largest implementation

## Key Files

- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Separation/KampTranslation.lean` - Infrastructure (sorry-free)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean` - Phase 1 bridge (sorry-free)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` - Sorry sites at lines 2353, 2435
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` - Consumer of stavi_expressive_completeness

## Immediate Next Action

Choose Approach A or B and implement the interval splitting / zone matching generalization. Approach A is recommended because it fixes the sorry in the existing codebase without adding new files or changing the proof architecture.

## Verification Status
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation` - PASSES
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.SemanticBridge` - PASSES  
- Full `lake build` - FAILS (pre-existing error in CanonicalTaskRelation.lean heartbeat timeout, unrelated)
