# Implementation Plan: Close Chain Construction Sorries (v3)

- **Task**: 109 - Close chain construction sorries
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 93 (irreflexive semantics switch, completed)
- **Research Inputs**: specs/109_close_chain_construction_sorries/reports/03_team-research.md
- **Artifacts**: plans/03_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 5 remaining sorry sites in `RootScopedChain.lean` (lines 1079, 1106, 1113, 1121, 1128) that block sorry-free `bx_completeness`. The prior plan (v2) completed phases 0-2 (axiom audit, dead code cleanup, FMCS strict ordering) but phases 3-6 were blocked by the BX11 perpetual deferral obstacle. This plan replaces those blocked phases with a new strategy: **active defect finite descent** (Path A), leveraging the irreflexive semantics insight that resolved defects exit the active set because `chi -> F(chi)` is not derivable. Path B (quasimodel run-composition) serves as fallback. Definition of done: `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`.

### Research Integration

- Team research report (03_team-research.md, 4 teammates) confirmed two viable paths and resolved the BX11 "perpetual deferral" disagreement as a formalization gap, not fundamental
- Teammate C identified `bx11_earlier_total` + `target_stays_direct_in_fold` as 80% of required infrastructure (sorry-free)
- Teammate D confirmed: under irreflexive semantics, `chi in M'` does NOT imply `F(chi) in M'`, so resolved defects exit the active set
- Teammate B identified quasimodel run-composition (Path B) with enriched oracle seed fix as fallback
- All teammates confirmed step transfer (sorry #4) is hardest; quasimodel approach avoids it

### Prior Plan Reference

Prior plan (02_implementation-plan.md) provided effort calibration: phases 0-2 completed successfully within estimates. Phases 3-6 were blocked because the round-robin targeting approach cannot control BX11 case 3 deferral. The new plan avoids round-robin entirely, using BX11 ordering-based finite descent instead. Key lesson: the BX11 fold is nondeterministic but the ordering infrastructure (`bx11_earlier_total`) provides a deterministic handle.

### Roadmap Alignment

- Advances ROADMAP item: "Task 109: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence)"
- Prerequisite for Task 95: `#print axioms` audit on `bx_completeness`
- Directly advances the Representation Theorem goal
- Clears the `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc` dependency chain

## Goals & Non-Goals

**Goals**:
- Close all 5 sorry sites in RootScopedChain.lean on the `bx_completeness` critical path
- Build active defect finite descent proof for `fwd_chain_forward_F` (sorry #1)
- Build symmetric backward P-resolution infrastructure
- Close Until/Since coherence sorries (#4, #5)
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}`
- Archive remaining dead code from irreflexive transition, update ROADMAP.md

**Non-Goals**:
- Closing non-critical-path sorries (Frame.lean `bx_le_refl`, TruthLemma backward_refl_mcs, etc.)
- Quasimodel/Filtration sorry sites (separate tasks)
- Changing the BX axiom system
- Dense completeness (task 68) or FMP truth preservation (task 82)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Active defect regeneration bound fails (new F-defects from Lindenbaum outpace resolutions) | H | M | Fallback to Path B (quasimodel run-composition); sigma_list finiteness provides hard bound |
| Step transfer (sorry #4) has no BX derivation | H | H | Phase 4 uses quasimodel-based backward Until coherence to avoid step transfer entirely |
| Backward P-resolution requires substantial new infrastructure | M | M | Follow forward chain patterns symmetrically; `temp_linearity_past` provides the BX11' fold |
| `target_stays_direct_in_fold` argument does not compose across multiple steps | M | L | The proof only needs one-step guarantees; compose via well-founded induction on active defect count |
| Path A counting argument is subtle and hard to formalize in Lean 4 | M | M | Use Finset.card-based well-founded induction on sigma_list membership; infrastructure is standard |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3, 4 | 2 |
| 5 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Dead Code Archival and ROADMAP Update [PARTIAL]

**Goal**: Archive remaining dead code from the irreflexive transition (false lemmas that are sorry'd because they require `chi -> F(chi)` or reflexive ordering). Update ROADMAP.md sorry inventory.

**Tasks**:
- [ ] Identify remaining dead-code sorries in BXCanonical module: `bx_le_refl` in Frame.lean, any stale comment references
- [ ] Archive identified dead code to `Boneyard/` (do NOT delete sorry sites that are on the critical path)
- [ ] Clean up any misleading comments referencing "BX1", "reflexive", or "Phase 2 redesign" that no longer apply
- [ ] Update `specs/ROADMAP.md`: refresh sorry inventory tables with accurate counts, note phases 0-2 of prior plan completed, note this plan (v3) replacing phases 3-6
- [ ] Verify `lake build` succeeds after cleanup

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - Archive `bx_le_refl` if confirmed dead
- `Boneyard/` - Destination for archived dead code
- `specs/ROADMAP.md` - Update sorry inventory and plan status

**Verification**:
- `lake build` succeeds
- No sorry sites removed from the critical path
- ROADMAP.md sorry counts match `grep -r sorry Theories/Bimodal/Metalogic/BXCanonical/ | wc -l`

---

### Phase 1: Active Defect Finite Descent for fwd_chain_forward_F [BLOCKED]

**Goal**: Close sorry #1 (`fwd_chain_forward_F`, line 1079) by proving that F-defects are eventually resolved via a finite descent argument on the active defect set.

**Tasks**:
- [ ] Define `active_defects(M, sigma_list) = {chi in sigma_list | F(chi) in M AND chi not_in M}` as a `Finset Formula` (since sigma_list is a finite list)
- [ ] Prove that at each preserving step, at least one active defect is resolved: the `bx11_earlier_total` ordering picks an earliest defect, and `target_stays_direct_in_fold` guarantees it enters M'
- [ ] Prove that resolved defects exit the active set: if `chi in M'` then `chi not_in active_defects(M', sigma_list)` (immediate from definition)
- [ ] Prove the key irreflexive insight: new F-defects from Lindenbaum are bounded by `sigma_list`. At each step, `|active_defects(M')| < |active_defects(M)|` because at least one exits and new entries are bounded by sigma_list membership
- [ ] If strict decrease fails (new defects can re-enter for formulas not currently active): use an amortized argument -- each formula in sigma_list can be resolved at most once because once chi in M', by g_content propagation G(chi) need not hold, but chi's F-obligation is discharged. Track total resolutions across all steps; at most |sigma_list| resolutions needed
- [ ] Build the well-founded induction: `fwd_chain_forward_F` by strong induction on `|active_defects|` or by tracking total resolutions bounded by `|sigma_list|`
- [ ] Replace the sorry at line 1079 with the completed proof

**Timing**: 4 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Add active defect infrastructure, close `fwd_chain_forward_F`

**Verification**:
- `fwd_chain_forward_F` has no sorry
- `lake build` succeeds
- `#print axioms fwd_chain_forward_F` shows no sorry

---

### Phase 2: Backward P-Resolution Infrastructure [NOT STARTED]

**Goal**: Build symmetric backward chain infrastructure and close sorry #2 (line 1106, F in backward region) and sorry #3 (line 1113, backward P-resolution).

**Tasks**:
- [ ] Build `preserving_bwd_step` symmetric to `preserving_fwd_step`: uses `temp_linearity_past` (BX11') fold for P-defect resolution, preserves h_content chain
- [ ] Define backward active defects: `{chi in sigma_list | P(chi) in M AND chi not_in M}`
- [ ] Prove `bx11_earlier_total` analog for P-defects using `temp_linearity_past_mcs`
- [ ] Build `target_stays_direct_in_fold` analog for backward direction
- [ ] Prove `bwd_chain_backward_P`: symmetric finite descent argument for P-formulas
- [ ] Close sorry #3 (line 1113): P(phi) in chain(t) gives phi at some earlier time using backward chain P-resolution
- [ ] Close sorry #2 (line 1106): F(phi) in backward chain region. Strategy: show F(phi) propagates to the origin (boundary between forward/backward chains) via h_content reverse, then use forward chain `fwd_chain_forward_F` from Phase 1

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Add backward chain infrastructure, close sorries #2 and #3

**Verification**:
- `dd_bfmcs_restricted_tc` has no sorry in any branch
- `lake build` succeeds
- `#print axioms dd_bfmcs_restricted_tc` shows no sorry

---

### Phase 3: Forward Until/Since Coherence [NOT STARTED]

**Goal**: Close sorry #5 (`dd_bfmcs_restricted_fuc`, line 1128) -- forward Until coherence.

**Tasks**:
- [ ] Prove forward Until coherence: if `(phi U psi) in chain(t)`, then `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)`
- [ ] Step 1: By BX10 (`until_F`), `F(psi) in chain(t)`. By Phase 1's `fwd_chain_forward_F`, exists `s > t` with `psi in chain(s)`
- [ ] Step 2: Choose minimal such s (well-ordering on Nat, Nat.find or similar)
- [ ] Step 3: Guard persistence proof. For r in (t, s):
  - By BX9 (`until_elim`): `(phi U psi) in chain(r)` implies `phi in chain(r)` (since `psi not_in chain(r)` by minimality of s, and MCS negation-completeness)
  - Remaining task: show `(phi U psi) in chain(r)` for r in (t, s)
  - Use BX5 (`self_accum_until`) + forward induction: `(phi U psi) in chain(t)` propagates forward as long as the witness psi has not appeared
  - Key mechanism: the chain preserves Until formulas via the defect-discharge structure (Until formulas are F-defects via BX10, so they persist through the preserving chain)
- [ ] Build helper `until_persists_before_witness`: if `phi U psi in chain(t)` and `psi not_in chain(r)` for t < r < s, then `phi U psi in chain(r)` (induction using one-step defect preservation)
- [ ] Replace the sorry at line 1128

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close `dd_bfmcs_restricted_fuc`

**Verification**:
- `dd_bfmcs_restricted_fuc` has no sorry
- `lake build` succeeds

---

### Phase 4: Backward Until/Since Coherence [NOT STARTED]

**Goal**: Close sorry #4 (`dd_bfmcs_restricted_buc`, line 1121) -- backward Until/Since coherence. This is the hardest sorry; the plan avoids step transfer.

**Tasks**:
- [ ] Analyze the exact goal of `restricted_backward_until_since_coherent`: given witness `s > t` with `psi in chain(s)` and guard `phi on (t,s)`, prove `(phi U psi) in chain(t)`
- [ ] Strategy A (MCS maximality): suppose `neg(phi U psi) in chain(t)`. Derive contradiction:
  - `neg(phi U psi)` + `psi in chain(s)` with guard phi on (t,s) should contradict via BX axioms
  - Use `backward_until_from_step` (already sorry-free) if it applies, or build the contradiction from BX7 (linear_until) + BX9 + BX5
- [ ] Strategy B (if Strategy A needs step transfer): Use quasimodel-based approach:
  - Leverage sorry-free `hintikka_chain_exists` from `Quasimodel/Construction.lean`
  - Build a local finite Hintikka chain that provides the Until witness
  - Connect Hintikka chain membership to the canonical chain via MCS structure
- [ ] Strategy C (Since coherence): Apply symmetric argument using BX5'/BX9'/BX10' for Since formulas
- [ ] Replace the sorry at line 1121

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close `dd_bfmcs_restricted_buc`
- Possibly `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` - Helper lemmas if needed

**Verification**:
- `dd_bfmcs_restricted_buc` has no sorry
- `lake build` succeeds

---

### Phase 5: Final Verification and Axiom Check [NOT STARTED]

**Goal**: Verify `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`. Update ROADMAP.md with final state.

**Tasks**:
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness`
- [ ] Verify output is exactly `{propext, Classical.choice, Quot.sound}`
- [ ] If unexpected axioms appear, trace and resolve them
- [ ] Update the axiom documentation in Completeness.lean
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update `specs/ROADMAP.md`:
  - Update sorry inventory to show 0 critical-path sorries
  - Update task 109 completion status
  - Update "Recommended Priority Order" section

**Timing**: 1 hour

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Verify and document axioms
- `specs/ROADMAP.md` - Final status update

**Verification**:
- `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}`
- `lake build` succeeds with no sorry on the critical path
- ROADMAP.md accurately reflects the new state

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `#print axioms bx_completeness` shows no sorry after Phase 5
- [ ] `#print axioms dd_countermodel` shows no sorry after Phase 4
- [ ] Grep for `sorry` in `RootScopedChain.lean` returns 0 hits after Phase 4
- [ ] Each phase's sorry count decreases monotonically: 5 -> 5 -> 3 -> 2 -> 1 -> 0

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/03_implementation-plan.md` (this file)
- Modified source files: RootScopedChain.lean (primary), possibly UntilSinceCoherence.lean, Completeness.lean
- Updated `specs/ROADMAP.md` (after phases 0 and 5)
- Archived dead code in `Boneyard/` (Phase 0)

## Rollback/Contingency

- Each phase is independently committable; rollback to previous phase's commit if a phase fails
- **Phase 1 fallback**: If the active defect finite descent argument cannot be closed (regeneration bound fails), switch to Path B (quasimodel run-composition). This requires closing the oracle defect-monotonicity sorry in `HintikkaStepOracle` with the enriched seed fix (adding `neg(phi U psi)` for non-defect Until formulas), then building a run-composition layer. Estimated additional effort: 4-6 hours
- **Phase 4 fallback**: If backward Until coherence cannot be proved via MCS maximality (needs step transfer), use quasimodel-based backward coherence via sorry-free `hintikka_chain_exists`. This replaces the direct BX derivation with a model-theoretic argument
- If any phase stalls beyond 1.5x estimated time, create a handoff document and mark [PARTIAL] for next session
