# Implementation Plan: Delete Unsound Backward Sorries and Restructure Truth Lemma (v5)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: specs/102_implement_quotient_filtration_close_sorries/reports/06_backward-sorry-research.md
- **Artifacts**: plans/06_backward-sorry-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the last 2 Frame.lean sorries (`bx_until_backward` and `bx_since_backward`) by deleting these unsound functions and replacing them with a chain-level backward induction that operates at the truth lemma level. Round 6 research established with 95% confidence that the current signatures are semantically unsound: `phi in w` plus `psi in v` with `bx_le w v` does not entail `phi U psi in w` because phi may fail at intermediate points. The working approach from DeterministicFMCS.lean's `backward_until_chain` uses `until_intro: X(psi or (phi and (phi U psi))) -> (phi U psi)` with backward induction along a chain with the X-content property (`phi in chain(n+1) iff X(phi) in chain(n)`). This plan adapts that approach by constructing a finite chain between w and v using iterated `bx_forward_witness`, where each step has an X-content relationship with its successor via a Lindenbaum extension of `{X(alpha)} union g_content(w_i)`. Definition of done: both Frame.lean backward sorries closed (by deletion + replacement), all callers updated, `lake build` clean, no new axioms.

### Research Integration

Key findings from `06_backward-sorry-research.md`:
- Current `bx_until_backward` and `bx_since_backward` are **semantically unsound** (95% confidence)
- Root cause: `phi in w` is weaker than `forall u in [w,v), phi in u` (the interval guard)
- All 5 proof strategies evaluated (BX9 direct, contradiction, enriched seed, BX4+BX12 bridge, MCS negation) are insufficient
- Recommended path: bypass Frame.lean entirely; restructure truth lemma to use chain-level backward induction
- Working reference implementation exists in `DeterministicFMCS.lean:340-396`

### Prior Plan Reference

Prior plan: `plans/05_signature-weakening-plan.md` (v4, 16h estimated, [PARTIAL]).
- **Effort calibration**: v4 estimated 5h per phase; Phases 1-3 completed (chain construction, forward sorries, caller updates). The backward direction was explicitly flagged as risky and time-boxed at 3h. This plan focuses solely on the backward problem.
- **Validated approaches**: Forward eventuality resolution (BX9 + BX10 + bx_forward_witness) is solid. The chain type UntilChain/SinceChain was NOT needed -- forward direction used simpler witness extraction. CanonicalChain.lean lemmas (psi_imp_until_mcs, absorb_until_mcs, etc.) are useful infrastructure.
- **Risk realized**: v4 predicted that backward direction might resist proof. Research confirmed this: the signatures are unprovable, not just hard.
- **Delegation chain intact**: All delegation bridges (CanonicalChain -> Realization -> LocusControl) are thin wrappers with matching signatures. Changes to Frame.lean propagate to callers straightforwardly.

### Roadmap Alignment

This plan advances the following ROAD_MAP.md items:
- **Until/Since eventuality + backward**: Closes the remaining 2 of 4 Frame.lean sorries (lines 656, 694)
- **Active-path sorry reduction**: Reduces active-path Frame.lean sorries from 2 to 0 (Completeness.lean sorry at line 154 remains, out of scope)

## Goals & Non-Goals

**Goals**:
- Delete `bx_until_backward` and `bx_since_backward` from Frame.lean (unsound signatures)
- Build a chain-level backward induction that works with `bx_le` ordering by constructing a finite chain with X-content properties between two BXPoints
- Replace the truth lemma's backward strict case (`until_backward_strict_mcs`, `since_backward_strict_mcs`) with chain-based proofs
- Update all delegation bridges (CanonicalChain, Realization, LocusControl) to remove dead backward references
- `lake build` passes with zero new sorries and zero new axioms

**Non-Goals**:
- Closing the Completeness.lean sorry (line 154, canonical model embedding) -- separate concern
- Modifying the forward direction (already working)
- Constructing a bi-infinite deterministic chain -- only need a finite chain from w to v
- Modifying the BX axiom system (no new axioms)
- Changing the reflexive/half-open-guard semantics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| X-content chain construction between arbitrary BXPoints fails: the Lindenbaum extension `{X(alpha)} union g_content(w_i)` may not produce a BXPoint with the right X-content relationship | H | M | Fallback: use `enriched_seed_consistent_until` to build a specific enriched intermediate MCS that contains both `g_content(w)` and `h_content(v)`, giving us a BXPoint that is "between" w and v in the bx_le ordering. Alternative: prove the result by contradiction using MCS negation completeness. |
| The `until_intro` rule requires `X(psi or (phi and (phi U psi))) in w`, but X-content in non-deterministic setting doesn't give us `phi in chain(n+1) iff X(phi) in chain(n)` | H | M | The key adaptation: instead of relying on a chain X-content property, prove `bx_until_backward` directly by contradiction. If `neg(phi U psi) in w`, then by BX5 (self-accumulation) and BX10 (eventuality extraction), derive properties that contradict the hypotheses when combined with `enriched_seed_consistent_until`. |
| Deleting backward functions breaks callers in unexpected ways | M | L | Callers are fully mapped: TruthLemma.lean (lines 298-302, 333-337), CanonicalChain.lean (lines 165-171, 182-188), Realization.lean (lines 439-445, 456-462), LocusControl.lean (lines 42-48, 59-65). All are thin wrappers. |
| Chain-based induction termination is difficult in Lean 4 | M | L | Use bounded `Nat.rec` iteration with explicit fuel (distance between w and v in terms of defect count or subformula closure size), avoiding well-founded recursion. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Prove Backward Until/Since via Contradiction at Frame Level [NOT STARTED]

**Goal**: Replace the sorry bodies of `bx_until_backward` and `bx_since_backward` with actual proofs, changing the signatures if necessary.

The core proof strategy uses contradiction with MCS negation completeness:

**Strategy A (Contradiction via enriched seed)**:
1. Assume `neg(phi U psi) in w` (by negation completeness, since we want to show `phi U psi in w`)
2. We have: `phi in w`, `psi in v`, `bx_le w v`, `psi not in w`
3. From `enriched_seed_consistent_until w v phi psi h_neg h_wv h_psiv`: the seed `{neg(phi U psi)} union g_content(w) union h_content(v)` is consistent
4. Extend to MCS `u` via Lindenbaum. Then: `neg(phi U psi) in u`, `bx_le w u`, `bx_le u v`
5. From `neg(phi U psi) in u` and BX9 contrapositive: either `neg phi in u` or `neg psi in u`... but wait, BX9 says `(phi U psi) -> (phi or psi)`, contrapositive is `(neg phi and neg psi) -> neg(phi U psi)`, which goes the wrong way.

**Strategy B (Direct construction -- change signature)**:
Change `bx_until_backward` to take a stronger hypothesis that is actually provable:
```lean
noncomputable def bx_until_backward
    (w : BXPoint) (phi psi : Formula)
    (h_phi_U_psi_or : phi.untl psi ∈ w.formulas ∨
      (psi ∈ w.formulas) ∨
      (phi ∈ w.formulas ∧ ∃ v, bx_le w v ∧ phi.untl psi ∈ v.formulas)) :
    phi.untl psi ∈ w.formulas
```
The third disjunct provides the Until formula at a future point, which can be used with `until_intro`.

**Strategy C (Delete and replace with truth-lemma-level proof)**:
Delete `bx_until_backward` entirely. Move the backward proof into TruthLemma.lean where we have access to the full world history structure. In the truth lemma, the backward direction already has:
- `psi` holds at some point `v` along the chain
- `phi` holds at `w`
- The chain has deterministic successor structure
This is exactly the setup needed for the `backward_until_chain` induction from DeterministicFMCS.lean.

**Recommended approach**: Strategy C. The round 6 research was explicit that the Frame.lean level lacks the structure needed. The truth lemma level has access to chain successor structure.

**Tasks**:
- [ ] Analyze TruthLemma.lean to determine exactly what hypotheses are available in the backward direction of `until_iff_mcs` / `since_iff_mcs` (currently delegated through `until_backward_strict_mcs`)
- [ ] Determine whether the truth lemma backward direction needs the full DeterministicFMCS chain infrastructure or can use a simpler construction
- [ ] If Strategy C: delete `bx_until_backward` and `bx_since_backward` from Frame.lean
- [ ] If Strategy C: implement the backward proof directly in TruthLemma.lean using chain-based induction (adapting `backward_until_chain` from DeterministicFMCS.lean lines 340-396)
- [ ] The chain-based proof needs: (a) X-content transfer: `alpha in chain(n+1) iff X(alpha) in chain(n)`, (b) chain MCS property, (c) induction on distance between w and v
- [ ] If direct chain adaptation is too complex: try a one-step proof using `bx_forward_witness` to get an immediate successor of w, then use `until_intro` with `enriched_seed_consistent_until` to derive the Until formula
- [ ] Mirror for Since direction
- [ ] Verify `lake build` passes (callers may break, expected)

**Timing**: 5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- delete `bx_until_backward` and `bx_since_backward` (or change signatures and prove)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- implement chain-based backward proof for Until and Since
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- possibly add chain-level backward induction lemma

**Verification**:
- Frame.lean has 0 sorry (the 2 backward sorries deleted or closed)
- TruthLemma.lean backward functions compile without sorry
- `lake build` may have errors in delegation callers (expected, fixed in Phase 2)

---

### Phase 2: Update Delegation Chain (CanonicalChain, Realization, LocusControl) [NOT STARTED]

**Goal**: Update all files that reference the deleted/changed backward functions to use the new approach.

**Tasks**:
- [ ] Update `CanonicalChain.lean`:
  - Remove `delegation_until_backward` (line 165-171) and `delegation_since_backward` (line 182-188) if backing functions were deleted
  - Or update signatures if they were changed
  - Update module docstring to reflect that backward sorries are resolved
- [ ] Update `Realization.lean`:
  - Remove/update `until_backward` (lines 439-445) and `since_backward` (lines 456-462)
  - These are thin wrappers, removal is straightforward
- [ ] Update `LocusControl.lean`:
  - Remove/update `bx_until_backward'` (lines 42-48) and `bx_since_backward'` (lines 59-65)
  - Update module docstring
- [ ] Verify `lake build` passes cleanly across all modified files

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- remove backward delegation bridges, update docstring
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- remove backward delegation functions
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- remove backward primed functions

**Verification**:
- All 5 modified files compile without error
- No new sorries introduced
- `lake build` passes cleanly

---

### Phase 3: Final Validation and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that all changes are consistent, no regressions, and documentation is updated.

**Tasks**:
- [ ] Run `lake build` and verify zero errors
- [ ] Count remaining sorries in `BXCanonical/` directory:
  - Before: 2 (Frame.lean backward) + 1 (Completeness.lean) = 3 sorry proofs
  - After: 0 (Frame.lean) + 1 (Completeness.lean) = 1 sorry proof
- [ ] Verify no new `axiom` declarations across the codebase
- [ ] Verify `Filtration/SigmaOrdering.lean` and `Filtration/DefectChain.lean` still compile (they are imported by CanonicalChain.lean)
- [ ] Update CanonicalChain.lean module docstring: change "Remaining (2 of 4)" to note all 4 are resolved
- [ ] Clean up any temporary comments or debug code
- [ ] Verify the forward direction still works correctly (no regressions in `bx_until_eventuality_resolution` or `bx_since_eventuality_resolution`)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- update docstring
- Any files needing cleanup

**Verification**:
- `lake build` passes cleanly
- Net reduction of 2 sorry proofs in Frame.lean (from 2 to 0)
- No new axiom declarations
- Forward direction unchanged and working

## Testing & Validation

- [ ] `lake build` passes at the end of each phase with no regressions
- [ ] Frame.lean: 2 backward sorries eliminated (by deletion or proof)
- [ ] TruthLemma.lean: backward strict case (`until_backward_strict_mcs`, `since_backward_strict_mcs`) proved without sorry
- [ ] All delegation bridges (CanonicalChain, Realization, LocusControl) compile without sorry
- [ ] No new `sorry` anywhere in the codebase (net reduction of 2)
- [ ] No new `axiom` declarations
- [ ] DefectChain.lean and SigmaOrdering.lean still compile unchanged

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- modified (2 backward sorries removed)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- modified (backward case restructured)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- modified (delegation bridges updated, docstring updated)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- modified (backward functions removed)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- modified (backward primed functions removed)
- `specs/102_implement_quotient_filtration_close_sorries/plans/06_backward-sorry-plan.md` -- this plan

## Rollback/Contingency

**If chain-based backward induction at truth lemma level is infeasible**: Time-box at 4 hours. If the DeterministicFMCS chain approach cannot be adapted to the non-deterministic BXCanonical setting, mark the two backward sorries with detailed comments explaining the semantic unsoundness and leave them as architectural debt. This is preferable to having unsound sorry statements that silently claim provability.

**If deletion of backward functions causes cascading failures beyond the 5 known callers**: Check `lake build` output for additional references. The forward direction is independent and should not be affected.

**If the proof requires new chain infrastructure (X-content transfer lemma)**: Add it to CanonicalChain.lean as a new section. The DeterministicFMCS.lean `x_mem_chain_general` is the template; the adaptation needs to work with `bx_le`-constructed chains rather than deterministic successor chains.

**Git rollback**: Each phase is committed separately. Revert to the last successful phase commit if a later phase fails. The forward direction work from prior rounds is safe on separate commits.
