# Implementation Summary: Task #93 BXCanonical Embedding (Plan v50)

## Status: Partial (Phases 1-5 completed, 2 pre-existing sorries remain)

## Changes Made

### Phase 1: Switch Guard Convention (Truth.lean)
- **Until guard**: Changed from open `(t, s)` to half-open `[t, s)` -- `t <= r -> r < s`
- **Since guard**: Changed from open `(s, t)` to half-open `(s, t]` -- `s < r -> r <= t`
- Fixed TimeShift proofs in Truth.lean for both Until and Since cases
- Fixed TemporalCoherence.lean (BFMCS coherence conditions) to match new guard

### Phase 2: Drop BX8/BX8', Reformulate BX2/BX2'
- **Removed**: `Axiom.until_step` and `Axiom.since_step` constructors from Axioms.lean
- **Reformulated BX2**: `G(phi->chi) -> (phi U psi -> chi U psi)` became `(phi->chi) AND G(phi->chi) -> (phi U psi -> chi U psi)` (conjunction needed to cover current point under half-open guard)
- **Reformulated BX2'**: Same pattern with H replacing G
- Updated `left_mono_until_valid` / `left_mono_since_valid` proofs in Soundness.lean
- Updated `left_mono_until_mcs` / `left_mono_since_mcs` in CanonicalChain.lean (now take extra `h_imp` argument)
- Removed `psi_imp_until_mcs` / `psi_imp_since_mcs` (used BX8 conceptually, now invalid)
- Removed all `until_step`/`since_step` match arms from soundness pattern matches

### Phase 3: Close Soundness Proofs
- **BX9/BX9' (until_elim/since_elim)**: Closed -- trivially provable under half-open guard (guard includes current point)
- **BX2/BX2' (left_mono_until/since)**: Closed -- conjunction hypothesis covers both current point and strict future/past
- **Temporal interaction (discreteness_forward)**: Closed -- uses `Order.succ t` with NoMaxOrder from Nontrivial
- **BX1/BX1' (serial_future/past)**: Remain sorry'd -- NOT universally valid without Nontrivial (a 1-element group has no strict future). These require adding `[Nontrivial D]` to `valid` definition (cascading change deferred)

### Phase 4: Audit BX2 Call Sites
- No external callers of `left_mono_until_mcs`/`left_mono_since_mcs` exist -- signatures updated, no downstream fixes needed

### Phase 5: Chain Construction Assessment
- ~30+ sorry sites remain in BXCanonical/ (RootScopedChain, CanonicalModel, Realization, OracleStep, Construction, Frame, TruthLemma, SigmaOrdering)
- These are orthogonal to the guard/axiom changes and remain the hard open problem (completeness chain construction)
- No new sorry sites introduced by this implementation

## Files Modified
- `Theories/Bimodal/Semantics/Truth.lean` -- guard convention change + TimeShift fixes
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- BX8 removal, BX2 reformulation
- `Theories/Bimodal/Metalogic/Soundness.lean` -- close 5 sorry sites, remove 2 theorems
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- update MCS lemmas
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- guard in coherence conditions

## Remaining Sorries in Modified Files
- `serial_future_axiom_valid` (Soundness.lean:209) -- needs Nontrivial in valid definition
- `serial_past_axiom_valid` (Soundness.lean:218) -- needs Nontrivial in valid definition

## Build Status
`lake build` passes (950 jobs, no errors).

## Key Design Decisions
1. **Half-open guard asymmetry**: Until uses [t,s) and Since uses (s,t]. This ensures BX9/BX9' are both valid (guard includes current evaluation point).
2. **BX2 conjunction**: The extra `(phi->chi)` hypothesis is needed because G/H cover only strict future/past, leaving the current point uncovered. The MCS proof uses negation completeness to derive the conjunction membership.
3. **BX1 deferral**: Adding Nontrivial to `valid` cascades through `semantic_consequence`, `valid_iff_empty_consequence`, etc. Deferred to a focused task.
