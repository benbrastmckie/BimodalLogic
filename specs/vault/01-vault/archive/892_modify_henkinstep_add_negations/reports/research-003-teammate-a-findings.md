# Teammate A Findings: RecursiveSeed Analysis

## Summary

RecursiveSeed (task 864) is the most mature alternative to task 892's blocked approach. Its core theorem `seedConsistent` is sorry-free, but the full pipeline from seed to BMCS (Phases 4-6) remains unimplemented. The approach successfully avoids the TCS/MCS tension that makes `maximal_tcs_is_mcs` unprovable. However, completing RecursiveSeed to sorry-free completeness requires significant additional work across 3 files (SeedCompletion, SeedBMCS, and connecting to Completeness.lean).

## Key Findings

### RecursiveSeed Status

- **File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (~6100+ lines)
- **Sorry count in RecursiveSeed.lean**: 4 actual sorries
  - Line 5709: `buildSeedForList'_consistent` (foldl preserves consistency)
  - Line 5734: `buildSeedForList_consistent` (mutual consistency from list)
  - Line 5923: `buildSeedForList_propagates_box` (box propagation through foldl)
  - Line 6005: `buildSeed_hasPosition_zero` (seed has position (0,0))
- **Core theorem `seedConsistent`**: SORRY-FREE (verified via `lean_local_search`)
- **Axiom-free**: Yes -- RecursiveSeed.lean introduces no axioms
- **Phases completed**: Phases 1-2 done, Phase 3 partially done (4 infrastructure sorries remain), Phases 4-6 not started
- **Implementation sessions**: 29 sessions completed

**Important distinction**: The 4 remaining sorries are in **infrastructure lemmas** (buildSeedForList, hasPosition), NOT in the core `seedConsistent` theorem. The central mathematical result -- that `buildSeed phi` produces a consistent seed when `phi` is consistent -- is fully proven.

### Downstream Pipeline Status

The RecursiveSeed feeds into a pipeline that is NOT yet connected to the completeness theorem:

```
RecursiveSeed.lean (4 sorries)
  -> SeedCompletion.lean (10 sorries) -- extends seed entries to MCS via Lindenbaum
    -> SeedBMCS.lean (5 sorries) -- assembles families into BMCS
      -> [NOT CONNECTED to Completeness.lean]
```

Current completeness chain uses:
```
Construction.lean (1 axiom: singleFamily_modal_backward_axiom)
  + TemporalCoherentConstruction.lean (1 axiom: fully_saturated_bmcs_exists, 1 sorry)
    -> Completeness.lean (sorry-free given axioms)
```

### TCS/MCS Tension Avoidance

RecursiveSeed **completely bypasses** the obstruction that blocks task 892:

1. **Task 892's problem**: `maximal_tcs_is_mcs` is mathematically FALSE because a set can be maximal among temporally-saturated consistent sets without being a maximal consistent set (when F(psi) is consistent to add but breaks saturation).

2. **RecursiveSeed's solution**: ALL temporal witnesses are pre-placed in the seed BEFORE any Lindenbaum extension. The construction works by:
   - Classifying formulas by main operator (Box, G, H, neg-Box, neg-G, neg-H, etc.)
   - Recursively building seed entries that specify formulas at (family, time) pairs
   - Modal witnesses (neg-Box) create NEW families
   - Temporal witnesses (neg-G, neg-H) create NEW times in the SAME family
   - Universal operators (Box, G, H) propagate formulas to all existing families/times

3. **Why this works**: Cross-sign temporal coherence for formulas in the starting formula is handled BY CONSTRUCTION -- G phi at time t means phi was added to ALL future seed times during seed building. The TCS/MCS gap never arises because witnesses are placed before maximalization, not derived from maximality.

4. **Remaining challenge**: Lindenbaum-added formulas (formulas added during MCS extension that were NOT in the original seed) still need temporal witness handling. This is the cross-sign propagation problem documented in DovetailingChain.lean (lines 606, 617).

### Comparison with Alternatives

| Approach | Status | Sorries (Pipeline) | Axioms | Key Challenge |
|----------|--------|---------------------|--------|---------------|
| **RecursiveSeed (864)** | IMPLEMENTING | 4 (self) + 15 (downstream) | 0 | Phases 4-6 unimplemented |
| **DovetailingChain (843)** | PARTIAL | 4 (cross-sign + F/P witness) | 0 | Cross-sign temporal coherence proven FALSE for Lindenbaum-added formulas |
| **ZornFamily (870)** | IMPLEMENTING | 5 | 0 | extensionSeed_consistent blocking multiple proofs |
| **TemporalLindenbaum (892)** | BLOCKED | 6 | 0 | `maximal_tcs_is_mcs` is mathematically FALSE |
| **Current pipeline** | COMPLETE | 0 (modulo axioms) | 2 | `singleFamily_modal_backward_axiom` + `fully_saturated_bmcs_exists` |

**RecursiveSeed vs DovetailingChain**: RecursiveSeed handles cross-sign temporal coherence for seed formulas by construction, while DovetailingChain has 2 unsolvable sorries for cross-sign cases (forward_G when t<0, backward_H when t>=0). For Lindenbaum-added formulas, BOTH approaches face the same challenge. RecursiveSeed is strictly better because it solves half the problem.

**RecursiveSeed vs ZornFamily**: ZornFamily (task 870) uses Zorn's lemma to select a maximal family satisfying coherence properties. It has 5 sorries concentrated around `extensionSeed_consistent`. ZornFamily could potentially complement RecursiveSeed by handling the Lindenbaum-added formula coherence via Zorn selection, but this integration is unexplored.

## Recommendations

### Path to Sorry-Free Completeness via RecursiveSeed

**Phase 1 (Immediate, 2-3 sessions)**: Resolve the 4 RecursiveSeed.lean infrastructure sorries
- `buildSeedForList'_consistent`: Generalize `buildSeedAux_preserves_seedConsistent` to work with pre-populated seeds
- `buildSeedForList_consistent`: Follows from above + mutual consistency hypothesis
- `buildSeedForList_propagates_box`: Trace box processing through foldl iterations
- `buildSeed_hasPosition_zero`: Prove buildSeedAux monotonicity (never removes positions)

**Phase 2 (Medium, 3-4 sessions)**: Complete SeedCompletion.lean (10 sorries)
- Extend seed entries to full MCS via Lindenbaum's lemma
- Build IndexedMCSFamily for each family index
- Prove consistency preservation through extension

**Phase 3 (Medium, 3-4 sessions)**: Complete SeedBMCS.lean (5 sorries)
- Assemble families into BMCS structure
- Prove modal coherence (forward/backward)
- Prove temporal coherence for seed-placed formulas

**Phase 4 (Hard, 4-6 sessions)**: Connect to Completeness.lean
- Either replace `fully_saturated_bmcs_exists` axiom with RecursiveSeed-based construction
- Or create alternative completeness pathway using SeedBMCS directly
- Handle cross-sign temporal coherence for Lindenbaum-added formulas (the hardest unsolved problem)

**Phase 5 (Hard, unknown)**: Cross-sign temporal coherence for Lindenbaum-added formulas
- This is the fundamental remaining challenge shared by ALL approaches
- Options: (a) Prove it via seed structure properties, (b) Use ZornFamily selection, (c) Accept as sorry with documentation, (d) Prove it is unnecessary for the specific formulas Lindenbaum adds

**Total estimated effort**: 12-17+ sessions to reach sorry-free completeness, with Phase 5 being the critical unknown.

### Recommended Strategy

1. **Continue RecursiveSeed (task 864)** as the primary path -- it has the most momentum and the best theoretical foundation
2. **Do NOT invest further in task 892** -- `maximal_tcs_is_mcs` is confirmed mathematically false
3. **Consider task 870 (ZornFamily)** as complementary -- it may help with Phase 5's Lindenbaum-added formula challenge
4. **Accept the 2 axioms in the current pipeline** as temporary until RecursiveSeed pipeline is complete -- they provide a working completeness proof now

## Evidence

### Lemma Names Verified via lean_local_search

| Lemma | File | Status |
|-------|------|--------|
| `seedConsistent` | RecursiveSeed.lean | Exists (theorem, sorry-free) |
| `buildSeed` | RecursiveSeed.lean | Exists (def) |
| `buildSeedAux` | RecursiveSeed.lean | Exists (def) |
| `buildSeed_hasPosition_zero` | RecursiveSeed.lean | Exists (theorem, has sorry) |
| `buildSeed_contains_formula` | RecursiveSeed.lean | Exists (theorem) |
| `dovetailChainSet_is_mcs` | DovetailingChain.lean | Exists (lemma) |
| `dovetailChainSet_forward_G_nonneg` | DovetailingChain.lean | Exists (lemma) |
| `maximal_tcs_is_mcs` | TemporalLindenbaum.lean | Exists (lemma, mathematically false) |
| `temporal_coherent_family_exists` | TemporalCoherentConstruction.lean | Exists (theorem, has sorry) |
| `temporal_coherent_family_exists_zorn` | ZornFamily.lean | Exists (theorem) |
| `fully_saturated_bmcs_exists` | TemporalCoherentConstruction.lean | Exists (**axiom**) |
| `fully_saturated_bmcs_exists_int` | TemporalCoherentConstruction.lean | Exists (theorem) |

### Sorry Counts by File (Bundle directory)

| File | Sorry Count | Notes |
|------|-------------|-------|
| RecursiveSeed.lean | 4 | Infrastructure, core theorem sorry-free |
| SeedCompletion.lean | 10 | Phases 4-6 work |
| SeedBMCS.lean | 5 | Phases 4-6 work |
| DovetailingChain.lean | 4 | Cross-sign + F/P witnesses |
| TemporalCoherentConstruction.lean | 2 | Generic D + combined construction |
| TruthLemma.lean | 4 | eval_bmcs_truth_lemma cases |
| FinalConstruction.lean | 3 | Combined construction |
| ZornFamily.lean | 5 | extensionSeed blocking |
| SaturatedConstruction.lean | 12 | Multiple construction approaches |
| Other files | ~127 | Various supporting proofs |
| **Total Bundle/** | **~176** | Across 19 files |

### Axiom Inventory (Bundle directory)

| Axiom | File | Purpose |
|-------|------|---------|
| `singleFamily_modal_backward_axiom` | Construction.lean | Modal backward coherence |
| `fully_saturated_bmcs_exists` | TemporalCoherentConstruction.lean | Fully saturated BMCS existence |
| `saturated_extension_exists` | CoherentConstruction.lean | Saturated extension existence |
| `weak_saturated_extension_exists` | WeakCoherentBundle.lean | Weak saturated extension |

## Confidence Level

**Medium-High** for the analysis that RecursiveSeed is the best path forward.

**Reasoning**:
- HIGH confidence that task 892's approach is blocked (mathematical impossibility confirmed across 4 sessions)
- HIGH confidence that RecursiveSeed's core construction is sound (seedConsistent proven sorry-free)
- MEDIUM confidence on timeline estimates (Phases 4-6 are complex and untested)
- LOW confidence that the cross-sign Lindenbaum-added formula challenge (Phase 5) can be fully resolved -- this is the same fundamental challenge that blocks ALL approaches, and RecursiveSeed only solves it for seed formulas, not for formulas added during Lindenbaum extension
