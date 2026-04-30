# Phase 2 Results: Fix SoundnessLemmas.lean Build Errors

## Outcome

Build errors resolved by **removing the unsound A7a axiom** rather than fixing match arms.

## Critical Finding: A7a is Unsound Under Open-Guard Semantics

The `linear_until_a7a` and `linear_since_a7a` axiom constructors (Burgess's A7a) are **not semantically valid** under the codebase's strict/open-guard Until semantics (`t < r < s`).

### Counterexample (proven in Lean)

With `phi = chi = True`, `psi` true only at `s1`, `theta` true only at `s2` where `s1 != s2`:
- LHS `(phi U psi) AND (chi U theta)` holds (witnesses at s1 and s2)
- All three RHS disjuncts require event `(psi AND theta)` at the witness
- No point has both `psi` and `theta` simultaneously
- Therefore the implication is false -- A7a is invalid

### Root Cause

A7a has **fixed event** `(psi AND theta)` across all three disjuncts. This requires both Until events to co-occur at the witness point. Under strict/open guards (`t < r < s`), the guard of one Until does NOT include its event at the witness -- so when `s1 != s2`, neither witness has both events.

BX7 avoids this because it has **fixed guard** `(phi AND chi)` (both guards apply throughout the overlapping region) and **varying events** (each disjunct's event uses components available at the chosen witness).

A7a may be valid under Burgess's closed-guard semantics (`t <= r <= s`) where the guard region includes the witness, but it is not valid under the strict semantics used in this codebase.

### All existing A7a proofs were also wrong

The `linear_until_a7a_valid` and `linear_since_a7a_valid` theorems in Soundness.lean contained the same type mismatch errors as SoundnessLemmas.lean -- they were never actually type-checked because SoundnessLemmas.lean (imported by Soundness.lean) failed first, preventing Soundness.lean from being elaborated.

## Changes Made

### Files Modified

1. **`Theories/Bimodal/ProofSystem/Axioms.lean`**
   - Removed `linear_until_a7a` and `linear_since_a7a` constructors from `Axiom` inductive
   - Added explanatory comment documenting the unsoundness and countermodel

2. **`Theories/Bimodal/ProofSystem/Substitution.lean`**
   - Removed `linear_until_a7a` and `linear_since_a7a` match arms from `axiom_closed_subst`

3. **`Theories/Bimodal/Metalogic/Soundness.lean`**
   - Removed `linear_until_a7a_valid` and `linear_since_a7a_valid` theorems (~80 lines)
   - Removed 8 match arms referencing these theorems across 4 functions

4. **`Theories/Bimodal/Metalogic/SoundnessLemmas.lean`**
   - Removed 8 broken A7a match arm blocks across 4 functions (~400 lines total)

### Lines Changed

- ~500 lines removed (broken/unsound A7a code)
- ~15 lines added (explanatory comments)

## Impact on Downstream Phases

**Phase 5 (Lemma 2.7 with A7a) needs revision.** The plan says A7a is used in Burgess's Lemma 2.7 proof for the three-way disjunction with fixed event. Since A7a is not available as a primitive axiom, Phase 5 will need to either:

1. **Derive A7a's conclusion from BX7** -- Apply BX7 to get the standard three-way split with fixed guard, then use additional reasoning to transform into the fixed-event form needed
2. **Find an alternative proof path** for Lemma 2.7 that doesn't require A7a
3. **Work within the derivation system** -- A7a may be derivable as a theorem even though it's not semantically valid as a standalone axiom (since derivability uses the proof system, not direct semantic evaluation)

This does NOT affect Phase 2's completion -- the build now succeeds.

## Verification

- `lake build` succeeds (Build completed successfully, 1097 jobs)
- No sorry sites in SoundnessLemmas.lean or Soundness.lean
- No new axiom declarations introduced
- No regressions in other files
