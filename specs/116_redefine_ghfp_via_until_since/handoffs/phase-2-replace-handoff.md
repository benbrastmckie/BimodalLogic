# Phase 2 Handoff: Replace temp_k_dist/temp_4 Invocations, Remove Axiom Constructors

**Session**: sess_1779159757_8a4784
**Timestamp**: 2026-05-19T06:16:32Z
**Phase**: 2 (steps 2.5-2.10)
**Status**: COMPLETED

## What Was Done

### Step 2.5: Replaced all invocations

Replaced all ~45 invocations of `Axiom.temp_k_dist` and `Axiom.temp_4` with derived theorems:

- **TemporalDerived.lean**: `G_distribution` and `G_transitivity` now use `temp_k_dist_derived`/`temp_4_derived` instead of axiom constructors. `H_transitivity` updated similarly.
- **GeneralizedNecessitation.lean**: Defined `temp_k_dist_local` (private, inline derivation) to avoid circular import with TemporalDerived.lean. Used in `past_k_dist` and `generalized_temporal_k`.
- **MCSProperties.lean**: Added import of TemporalDerived. Updated `all_future_all_future` and `temp_4_past` to use derived theorems. Made `temp_4_past` noncomputable.
- **18 other non-Boneyard files**: Replaced `DerivationTree.axiom [] _ (Axiom.temp_k_dist ...)` with `Bimodal.Theorems.TemporalDerived.temp_k_dist_derived ...` (and similarly for temp_4).
- **5 Boneyard files**: Same replacement. These are dead code but were updated for consistency.
- **ProofSearch.lean**: Removed temp_k_dist and temp_4 from axiom matching (they are no longer axiom constructors).
- **AesopRules.lean**: Changed `axiom_temp_4` to use weakening from derived theorem. Added `noncomputable` to dependent function.

### Step 2.6: Removed axiom constructors

Removed `| temp_k_dist` and `| temp_4` from the `Axiom` inductive type in Axioms.lean. Updated docstrings and constructor counts (42 -> 40).

### Step 2.7: Fixed match arms

Removed `| temp_k_dist` and `| temp_4` match arms from:
- Soundness.lean (6 locations across 3 match functions)
- SoundnessLemmas.lean (4 locations across 4 match functions)
- Substitution.lean (1 location in axiom_subst)
- ConservativeExtension/Lifting.lean (2 locations, replaced with sorry since dead code)

### Steps 2.8-2.9: Build verification

`lake build` passes with 0 errors and 1647 jobs.

## Key Decisions

1. **Circular import avoidance**: GeneralizedNecessitation.lean cannot import TemporalDerived.lean (TemporalDerived imports GeneralizedNecessitation). Solved by defining a private `temp_k_dist_local` that replicates the BX3-based derivation using only dependencies already available.

2. **ConservativeExtension dead code**: The `unembedAxiom` function in Lifting.lean matches on ExtAxiom constructors (still present) and needs to produce Axiom values. Since temp_k_dist/temp_4 are no longer Axiom constructors, these arms use sorry. This file is dead code (not imported by any barrel file).

3. **Sorry count**: Net +4 sorries from ConservativeExtension/Lifting.lean (dead code). All other replacements are sorry-free.

## Immediate Next Action

Step 2.10: Commit with message `task 116 phase 2: replace temp_k_dist/temp_4 invocations, remove axiom constructors`.

Then proceed to Phase 4 (full build validation and sorry audit) or Phase 5 (test suite and final validation).

## Metrics

- Axiom constructors: 42 -> 40 (removed temp_k_dist, temp_4)
- Sorry count: 509 -> 513 (net +4, all in dead code ConservativeExtension/Lifting.lean)
- Build: 0 errors, 1647 jobs
- Files modified: 25 total
