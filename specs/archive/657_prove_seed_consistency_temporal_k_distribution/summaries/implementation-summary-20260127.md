# Implementation Summary: Task #657

**Completed**: 2026-01-27
**Duration**: ~2 hours
**Status**: PARTIAL (future case complete, past case blocked on infrastructure)

## Overview

Resolved the blocking issue in seed consistency proofs for the indexed MCS family construction.
The original approach attempted to derive `bot` from `G bot` syntactically, which is impossible
in TM logic (irreflexive temporal operators, no temporal T axiom).

## Key Insight

**The Problem**: TM logic has irreflexive temporal operators where `G phi` means "phi holds at all
STRICTLY future times". The formula `G bot` is satisfiable at bounded temporal endpoints (vacuously
true when no future times exist), so `G bot` doesn't derive `bot`.

**The Resolution**: Instead of attempting a semantic bridge (which had circularity issues with
completeness proof), we added explicit hypotheses requiring `G bot not in Gamma` and `H bot not in Gamma`.
These hypotheses make explicit that the indexed family construction is for UNBOUNDED temporal models.
MCS containing `G bot` or `H bot` are only satisfiable at bounded endpoints and require a different
construction approach.

## Changes Made

### 1. Added Semantic Helper Lemma
- `G_bot_forbids_future`: Pure semantic fact that if `G bot` is true at time 0, no time t > 0 can exist

### 2. Modified Proof Signatures
Updated function signatures to include unbounded-model hypotheses:
- `future_seed_consistent`: Added `h_no_G_bot : Formula.all_future Formula.bot not in Gamma`
- `past_seed_consistent`: Added `h_no_H_bot : Formula.all_past Formula.bot not in Gamma`
- `time_seed_consistent`: Added both hypotheses
- `mcs_at_time`: Added both hypotheses
- `mcs_at_time_contains_seed`: Added both hypotheses
- `mcs_at_time_is_mcs`: Added both hypotheses
- `construct_indexed_family`: Added both hypotheses
- `construct_indexed_family_origin`: Added both hypotheses
- `construct_indexed_family_origin_extends`: Added both hypotheses

### 3. Completed Proofs
- `future_seed_consistent`: Now complete (no sorry) - contradiction with `h_no_G_bot` after deriving `G bot in Gamma`

## Files Modified

- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
  - Added import for `Bimodal.Semantics.Truth`
  - Added `G_bot_forbids_future` lemma
  - Added documentation explaining unbounded model requirement
  - Modified 9 function/lemma signatures to include new hypotheses
  - Completed `future_seed_consistent` proof

## Verification

- Full `lake build` succeeds (977 jobs)
- No errors in modified file
- Downstream files (`TruthLemma.lean`, `CanonicalHistory.lean`, etc.) build successfully

## Remaining Work

### Sorries in IndexedMCSFamily.lean

1. **`past_seed_consistent`** (line 425): Requires `generalized_past_k` theorem
   - Infrastructure needed: `H L |- H phi` from `L |- phi`
   - Derivable from `generalized_temporal_k` via temporal duality, but needs context-level transformation

2. **`construct_indexed_family` coherence proofs** (lines 537+): Four sorries for forward/backward G/H coherence
   - These are separate proof obligations, not blocked by this task

### Recommended Follow-up Tasks

1. **Implement `generalized_past_k`**: Add to `GeneralizedNecessitation.lean`, mirroring structure of `generalized_temporal_k`
2. **Bounded endpoint construction**: Separate construction for MCS containing `G bot` or `H bot`
3. **Coherence proofs**: Complete forward_G, backward_H, forward_H, backward_G

## Design Decision Rationale

**Why hypotheses instead of semantic bridge?**

The original plan (Approach A - Semantic Bridge) attempted to derive a contradiction by showing that
`G bot in Gamma` is incompatible with the canonical model construction's domain requirements. However,
this approach had circularity issues: we can't use properties of the canonical model to prove a lemma
that's required to build that model.

Adding explicit hypotheses makes the unbounded-model assumption clear and avoids circularity. The
completeness theorem for TM logic over unbounded time structures will use these hypotheses to ensure
the MCS being satisfied doesn't contain `G bot` or `H bot`. For MCS that DO contain these formulas,
a different (bounded endpoint) construction is appropriate.

This is consistent with the general principle that completeness proofs often have distinct cases
for different frame properties (unbounded vs bounded, etc.).

## Notes

- The change affects the interface of several key functions but maintains logical correctness
- All downstream callers will need to provide the new hypotheses when using these functions
- The TruthLemma and related completeness infrastructure compiles without errors after these changes
