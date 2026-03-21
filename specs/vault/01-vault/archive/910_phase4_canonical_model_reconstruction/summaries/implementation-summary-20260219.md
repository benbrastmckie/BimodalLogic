# Implementation Summary: Task #910

**Completed**: 2026-02-19
**Duration**: ~1 hour
**Session**: sess_1771543349_9bd3bd

## Changes Made

Reconstructed `Theories/Bimodal/Metalogic/Representation.lean` to implement Choice B from
the parent task 906: non-constant families with time-indexed truth lemma (`fam.mcs t` at
time `t`). This eliminates the Box forward case sorry and removes all constant-family
infrastructure.

### Phase 1: Remove Constant-Family Infrastructure
- Deleted `IsConstantFamilyBMCS` definition
- Deleted `constant_family_bmcs_exists_int` sorry-backed theorem
- Deleted `getConstantBMCS` and all 4 accessor theorems
- Updated module docstring to reflect new approach
- **38 lines of dead code removed**

### Phase 2: Generalize Canonical Definitions
- Changed `CanonicalWorldState` from `{ S // exists fam in B.families, S = fam.mcs 0 }` to `{ S // SetMaximalConsistent S }`
- Updated `mkCanonicalWorldState` to accept time parameter `t` (was hardcoded to `fam.mcs 0`)
- Updated `canonicalHistory` to use time-varying states: `states t _ = mkCanonicalWorldState B fam t`
- Updated `canonicalHistory_states_val` to show `.val = fam.mcs t` (proof remains `rfl`)

### Phase 3: Define canonicalOmega
- Defined `canonicalOmega B` as the set of canonical histories
- Proved `canonicalHistory_mem_canonicalOmega` membership helper (proof: `rfl`)
- Added documentation noting canonicalOmega is NOT shift-closed by design

### Phase 4: Rewrite Truth Lemma
- Removed `h_const : IsConstantFamilyBMCS B` parameter from `canonical_truth_lemma_all`
- Changed LHS from `fam.mcs 0` to `fam.mcs t` (time-indexed)
- Added `canonicalOmega B` as Omega parameter in all `truth_at` calls
- **Fixed Box forward case** (was sorry): sigma in canonicalOmega extracts to canonical
  history, enabling direct IH application
- Rewrote `all_future` forward case with case split (s = t via T-axiom, s > t via forward_G)
- Rewrote `all_future` backward case using temporal coherence at time `t` (not 0)
- Rewrote `all_past` cases symmetrically
- Updated `canonical_truth_lemma` wrapper

### Phase 5: Update Completeness Theorems
- Replaced `getConstantBMCS` with `construct_saturated_bmcs_int` in representation theorems
- Updated `satisfiable` witnesses to include `canonicalOmega B` and membership proof
- Documented Omega-mismatch in `standard_weak_completeness` and `standard_strong_completeness`
- Added sorry for Omega-mismatch (requires Validity.lean coordination)

### Phase 6: Final Verification
- `lake build` succeeds for entire project (1000 jobs, 0 errors)
- `canonical_truth_lemma_all` verified sorry-free via `#print axioms`
- No regressions in downstream modules

## Files Modified

- `Theories/Bimodal/Metalogic/Representation.lean` - Complete reconstruction

## Sorry Analysis

### Sorries Eliminated
1. `constant_family_bmcs_exists_int` (was line 94-95) - **ELIMINATED** (entire definition removed)
2. Box forward case of `canonical_truth_lemma_all` (was line 229) - **FIXED** (canonicalOmega restricts quantification)

### Sorries Remaining (in this file)
1. `standard_weak_completeness` - Omega-mismatch (valid uses Set.univ, satisfiable uses canonicalOmega)
2. `standard_strong_completeness` - Same Omega-mismatch

### Sorries Inherited (from upstream)
- `fully_saturated_bmcs_exists_int` in TemporalCoherentConstruction.lean (used by standard_representation)

### Net Effect
- Removed 1 sorry (constant_family_bmcs_exists_int)
- Fixed 1 sorry (Box forward case)
- Added 2 sorries (Omega-mismatch in weak/strong completeness) - these replace the previous
  cascading dependency on the constant-family sorry
- The truth lemma itself is now completely sorry-free

## Verification

- `#print axioms canonical_truth_lemma_all`: No `sorryAx` dependency
- `lake build`: 1000 jobs, 0 errors, build completed successfully
- No references to removed definitions (`IsConstantFamilyBMCS`, `getConstantBMCS`, etc.) in codebase

## Notes

The Omega-mismatch between `valid` (Set.univ) and `satisfiable` (canonicalOmega) requires
a follow-up task to coordinate changes in Validity.lean. Options:
1. Change `valid` to quantify over Omega (requires updating soundness proofs)
2. Prove truth monotonicity (fails for imp due to contravariance)
3. Change `satisfiable` to use Set.univ (loses Omega tracking)

See research-001.md for detailed analysis of the Omega-mismatch resolution strategy.
