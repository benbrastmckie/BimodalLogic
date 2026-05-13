# Implementation Summary: Task 115 - Remove A4a (Partial)

**Task**: 115 - Remove A4a (separation_until/separation_since) for axiom minimality
**Session**: sess_1778697140_6bec1c
**Status**: Partial (Phase 1 of 4 completed)

## Completed Work

### Phase 1: Xu Lemma 2.3 (Guard Strengthening via left_mono_until_G)

Added two theorems to `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`:

**`xu_lemma_2_3_since_top`** (lines ~698-765):
- Statement: If `BurgessR3Maximal A B C`, then `snce(alpha, top) in B` for all `alpha in A`
- Proof technique: Contradiction via `BurgessR3Maximal_extension_fails`. Guard strengthening uses BX4 (connect_future) + BX12' (P_since_equiv) + temporal K distribution to derive `G(snce(alpha, top)) in A`, then `left_mono_until_G` strengthens the Until guard from `beta` to `beta AND snce(alpha, top)`. The Since condition follows from `burgessR_implies_burgessRSince`.

**`xu_lemma_2_3_until_top`** (lines ~770-830):
- Statement: If `BurgessR3Maximal A B C`, then `untl(gamma, top) in B` for all `gamma in C`
- Proof technique: Dual argument using BX4' (connect_past) + BX12 (F_until_equiv) + past K distribution for `H(untl(gamma, top)) in C`, then `left_mono_since_H` for guard strengthening. Until condition via `burgessRSince_implies_burgessR`.

Both theorems compile cleanly with no sorries. Build passes (1633 jobs).

## Remaining Work

### Phase 2: Xu Lemma 2.4 and Usage Site Rewriting (BLOCKED)

Phase 2 is blocked on a structural mismatch: the existing `lemma_2_6_splitting` output requires `B subset B'` (where R(A, B', D)), but the Xu Lemma 2.4 approach only guarantees `B union {neg-beta} subset D`. Getting `r(A, B, D)` (needed for Zorn to produce B' with B subset B') requires `snce(alpha, beta) in D` for all alpha in A and beta in B, which is not guaranteed by the Xu seed `{neg-beta} union B*`.

See handoff document for four possible resolution paths.

### Phase 3: Remove Axiom Constructors (depends on Phase 2)
### Phase 4: Final Verification (depends on Phase 3)

## Build Verification

- `lake build`: PASS (1633 jobs, no new errors)
- Sorry count in modified file: 0 (2 grep hits are in comments)
- New axioms: 0
- Existing axiom constructors: unchanged (separation_until/separation_since still present)

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`: Added ~130 lines for Xu Lemma 2.3 theorems

## Key Insight

The Xu 1988 approach (Lemmas 2.3/2.4) can replace Burgess's A4a axiom for the chronicle splitting construction, but the existing codebase's `lemma_2_6_splitting` output type is STRONGER than what Xu 2.4 naturally provides. A plan revision is needed to resolve the `B subset B'` structural requirement before Phase 2 can proceed.
