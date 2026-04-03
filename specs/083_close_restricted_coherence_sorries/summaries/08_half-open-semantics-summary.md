# Implementation Summary: Task #83 (v7) — Half-Open Interval Semantics

## Completed Phases

### Phase 1: Half-Open Semantic Change [COMPLETED]
Changed Until/Since semantics from closed to half-open interval:
- Until guard: `r <= s` changed to `r < s` (phi holds on [t, s) not [t, s])
- Since guard: `s <= r` changed to `s < r` (phi holds on (s, t] not [s, t])
Fixed `truth_shift_invariance` proofs for new inequality types.
Marked `until_connectedness`/`since_connectedness` as sorry (unsound under half-open).

### Phase 2: Fix Downstream Soundness [COMPLETED]
Filled `until_intro` and `since_intro` soundness proofs (both copies):
- Case 1: psi(t) gives witness s=t with vacuous guard [t,t) or (t,t]
- Case 2: G(phi U psi)(t) / H(phi S psi)(t) gives result by reflexivity of G/H

### Phase 3: Forward Until Truth Lemma [COMPLETED]
Proved: phi U psi in mcs(t) implies semantic Until at t.
- Derived F(psi) in mcs(t) from phi U psi via U-Induction with chi=bot
- Obtained witness s via forward_F
- Found minimal witness using Nat.strongRecOn
- Showed phi in mcs(r) for guard [t, s') via G(phi U psi) + until_unfold

## Blocked Phases

### Phase 4: Backward Until Truth Lemma [PARTIAL]
The backward direction (semantic Until implies phi U psi in mcs(t)) remains sorry.
Root cause: getting G(phi U psi) in mcs(t) requires phi U psi at ALL j >= t,
but for j > s (past the witness), no semantic Until holds.
See handoff document for detailed analysis of approaches tried.

### Phases 5-7 [NOT STARTED]
Blocked on Phase 4 completion.

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Semantics/Truth.lean` | Half-open semantic definition + shift invariance fixes |
| `Theories/Bimodal/Metalogic/Soundness.lean` | until_intro/since_intro proofs; connectedness marked unsound |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` | Forward Until proof; backward sorry |

## Build Status

`lake build` passes with 35 sorry warnings. The Until/Since forward directions are proved;
backward directions + Since remain sorry. No new axioms introduced.

## Artifacts

- Plan: `specs/083_close_restricted_coherence_sorries/plans/08_half-open-semantics.md`
- Handoff: `specs/083_close_restricted_coherence_sorries/handoffs/08_backward-until-handoff.md`
- Summary: this file
