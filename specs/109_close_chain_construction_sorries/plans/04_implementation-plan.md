# Implementation Plan: Close Chain Construction Sorries (v4)

- **Task**: 109 - Close chain construction sorries
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: Task 93 (irreflexive semantics switch, completed)
- **Research Inputs**: specs/109_close_chain_construction_sorries/reports/04_team-research.md
- **Artifacts**: plans/04_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 5 remaining sorry sites in `RootScopedChain.lean` (lines 1134, 1161, 1168, 1176, 1183) that block sorry-free `bx_completeness`. Plan v3 was blocked because the active defect finite descent argument (Path A) has a gap: active defects can fluctuate rather than monotonically decrease. This plan (v4) pursues Path D (quasimodel run-composition) as the primary strategy, per user direction: first close the oracle gap in Realization.lean by rearchitecting to use `g_content_sigma` instead of `g_content` (avoiding BX1), then build a run-composition layer connecting Hintikka chains to the BFMCS structure, then close the 5 sorry sites bottom-up. Path A' (corrected active defects + state-space termination argument) is held as backup if Path D stalls at Phase 1. Definition of done: `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`.

### Research Integration

Team research report (04_team-research.md, 4 teammates) established:
- Approaches A (G(neg w) seed enrichment), B (round-robin), and C (BX11 transitivity) are definitively dead
- `active_defects` definition is wrong for any termination argument (missing `chi not in M` condition) -- universal prerequisite
- Path A' (corrected active defects + finite descent) has a gap: active defects can fluctuate, not monotonically decrease; needs sophisticated measure (55% confidence)
- Path D (quasimodel run-composition) is structurally sounder but needs BX1 gap resolution in Realization.lean and new run-composition infrastructure (60% confidence)
- Teammate C identified: replace `g_content(w)` with `g_content_sigma(w, Sigma)` in oracle construction to avoid BX1 dependency
- All 4 teammates agree the `active_defects` fix is required regardless of path

### Prior Plan Reference

Prior plan (03_implementation-plan.md, v3) estimated 14 hours total. Phases 0-2 of the earlier plan (v2) completed within estimates. Phase 1 of v3 (active defect finite descent) was marked BLOCKED because the argument has a gap: resolved defects can re-enter `active_defects_corrected` when they leave M at the next step. The regeneration bound problem identified in v3 Risk #1 materialized. Key calibration lesson: Lindenbaum opacity makes all "simple counting" arguments on the chain unreliable; the quasimodel path avoids this by working at the Hintikka level where defect_count is already sorry-free.

### Roadmap Alignment

- Advances ROADMAP item: "Task 109: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence)"
- Clears the `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc` dependency chain
- Prerequisite for Task 95: `#print axioms` audit on `bx_completeness`
- Directly advances the Representation Theorem goal

## Goals & Non-Goals

**Goals**:
- Fix `active_defects` definition to include `chi not in M` condition (prerequisite)
- Close the 4 BX1-dependent sorry sites in Realization.lean by rearchitecting oracle to use `g_content_sigma`
- Build run-composition layer connecting sorry-free `hintikka_chain_exists` to BFMCS chain structure
- Close all 5 sorry sites in RootScopedChain.lean on the `bx_completeness` critical path
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}`

**Non-Goals**:
- Closing non-critical-path sorries (Frame.lean `bx_le_refl`, TruthLemma backward_refl_mcs, SigmaOrdering reflexivity, etc.)
- Quasimodel sorry sites not on the critical path (Construction.lean `refl_intro_until/since_mcs`)
- Changing the BX axiom system
- Dense completeness (task 68) or FMP truth preservation (task 82)
- Closing sorry #4 (backward Until/Since coherence) if it requires infrastructure beyond what Path D provides

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| g_content_sigma oracle rearchitecture introduces new sorry sites | H | M | Incremental approach: modify one sorry at a time in Realization.lean, verify `lake build` after each |
| Run-composition layer requires more infrastructure than estimated | M | M | The Hintikka chain is sorry-free; focus on a thin bridge layer, not a full rewrite |
| Backward chain (sorries #2, #3) needs symmetric bwd_step infrastructure that does not exist | M | H | Follow forward chain patterns symmetrically; `temp_linearity_past` provides the BX11' fold |
| Path D stalls at oracle gap (Realization.lean changes too invasive) | H | L | BACKUP: pivot to Path A' with corrected active_defects + state-space/amortized termination argument |
| Sorry #4 (backward Until/Since) remains intractable | M | M | Defer to follow-up task; Path D run structure provides the best handle on this sorry |
| `hintikka_chain_exists` oracle instantiation blocked by `defect_mono` hypothesis | H | M | The g_content_sigma fix should close defect_mono; if not, the enriched seed consistency fix is the fallback |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |
| 5 | 4, 5 | 3 |
| 6 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Fix active_defects Definition [NOT STARTED]

**Goal**: Correct the `active_defects` definition to include the `chi not in M` condition, which is a universal prerequisite identified by all 4 research teammates.

**Tasks**:
- [ ] Modify `active_defects` at RootScopedChain.lean line ~470 from `sigma_list.filter (fun chi => decide (Formula.some_future chi in M))` to `sigma_list.filter (fun chi => decide (Formula.some_future chi in M and chi not_in M))`
- [ ] Update `active_defects_subset` to reflect new definition
- [ ] Update `active_defects_F_mem` to return conjunction (F(chi) in M AND chi not_in M)
- [ ] Update `mem_active_defects` to require both conditions
- [ ] Update `singleton_defect_resolved` and any callers of active_defects lemmas
- [ ] Verify `lake build` succeeds (existing sorry sites should be unaffected since active_defects is only used in the sorry'd `fwd_chain_forward_F`)
- [ ] Use `lean_goal` to verify proof states at affected lemmas

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Fix active_defects and dependent lemmas

**Verification**:
- `lake build` succeeds
- `lean_goal` confirms updated types at active_defects lemmas
- No new sorry sites introduced

---

### Phase 1: Close Oracle Gap in Realization.lean [NOT STARTED]

**Goal**: Rearchitect the oracle construction in Realization.lean to use `g_content_sigma` instead of `g_content`, eliminating the 4 BX1-dependent sorry sites (lines 67, 73, 197, 249). This is the critical enabler for Path D.

**Tasks**:
- [ ] Close `F_of_mem` sorry (line 67): This lemma claims `psi in w.formulas implies F(psi) in w.formulas`, which requires BX1 under the current proof strategy. Under irreflexive semantics, this is NOT true in general. Determine if this lemma is actually needed on the critical path, or if callers can be rerouted to use `F_from_above` (which IS sorry-free) or a Sigma-restricted variant
- [ ] Close `P_of_mem` sorry (line 73): Dual of F_of_mem. Same analysis as above
- [ ] Close `enriched_seed_consistent_until` sorry (line 197): The sorry is in the branch `alpha in g_content(w) implies alpha in w.formulas`. Replace the g_content inclusion with g_content_sigma inclusion: for `G(alpha) in Sigma`, the Hintikka point structure ensures alpha propagates WITHOUT BX1. Modify the seed construction to use `g_content_sigma(w, Sigma)` instead of `g_content(w.formulas)`
- [ ] Close `enriched_seed_consistent_since` sorry (line 249): Dual -- replace `h_content(w)` inclusion with `h_content_sigma(w, Sigma)` variant. Define `h_content_sigma` if it does not exist
- [ ] Verify that all callers of the modified functions still type-check
- [ ] Run `lake build` and fix any cascading issues
- [ ] Use `lean_verify` on key theorems to confirm no sorry leaks

**Timing**: 4 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` - Close 4 sorry sites, rearchitect seed construction
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` - If oracle interface changes propagate

**Verification**:
- `F_of_mem`, `P_of_mem`, `enriched_seed_consistent_until`, `enriched_seed_consistent_since` have no sorry
- `lake build` succeeds
- `lean_verify` on `enriched_seed_consistent_until` shows no sorry axiom

---

### Phase 2: Build Run-Composition Layer [NOT STARTED]

**Goal**: Connect the sorry-free `hintikka_chain_exists` infrastructure to the BFMCS chain structure. Build a bridge that converts Hintikka chain witnesses into chain-index witnesses for `fwd_chain_forward_F`.

**Tasks**:
- [ ] Define `hintikka_run_to_chain_witness`: given F(phi) in chain(n), use BX12 (`F(phi) -> top U phi`) to convert to an Until defect, then invoke `hintikka_chain_exists` to produce a finite Hintikka chain discharging the defect
- [ ] Define `realize_hintikka_run`: lift the Hintikka chain back to BXPoint level using the (now sorry-free) Realization infrastructure from Phase 1
- [ ] Build `chain_index_from_hintikka_run`: map the realized BXPoint chain to chain indices via g_content ordering compatibility. The key property: each BXPoint in the realized chain is bx_le-comparable to the corresponding chain point
- [ ] Prove `hintikka_run_witness_in_chain`: the endpoint of the realized run has phi in its formulas, and this endpoint corresponds to some chain index m > n
- [ ] Handle the composition gap: the realized BXPoint chain may not literally be a sub-chain of dd_chain. Build the bridging argument that chain membership at the Hintikka level implies membership at the FMCS level (via MCS maximality and g_content propagation)
- [ ] Use `lean_goal` at each intermediate step to track proof state

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Add run-composition bridge definitions and lemmas
- Possibly new file `Theories/Bimodal/Metalogic/BXCanonical/RunComposition.lean` if the bridge is substantial enough to warrant separation

**Verification**:
- `hintikka_run_to_chain_witness` compiles without sorry
- `lake build` succeeds
- `lean_goal` confirms the bridge produces the right witness type

---

### Phase 3: Close Sorry #1 (fwd_chain_forward_F) [NOT STARTED]

**Goal**: Close the keystone sorry at RootScopedChain.lean line ~1134 using the run-composition layer from Phase 2.

**Tasks**:
- [ ] Replace the `sorry` in `fwd_chain_forward_F` with the run-composition proof: given F(phi) in chain(n), invoke `hintikka_run_to_chain_witness` to get a Hintikka chain, realize it, and extract the witness m > n with phi in chain(m)
- [ ] Handle the edge case where phi is already in chain(n+1) (resolved at the very next step -- short-circuit via `fwd_chain_defect_one_step`)
- [ ] Verify the proof compiles and `lake build` succeeds
- [ ] Use `lean_verify` on `fwd_chain_forward_F` to confirm no sorry axiom
- [ ] Check downstream: `dd_bfmcs_restricted_tc` forward case should now close (it delegates to `fwd_chain_forward_F`)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close `fwd_chain_forward_F`

**Verification**:
- `fwd_chain_forward_F` has no sorry
- `#print axioms fwd_chain_forward_F` shows no sorry
- `lake build` succeeds

---

### Phase 4: Close Sorries #2, #3 (Backward Chain) [NOT STARTED]

**Goal**: Close sorry #2 (line ~1161, F in backward region) and sorry #3 (line ~1168, backward P-resolution) in `dd_bfmcs_restricted_tc`.

**Tasks**:
- [ ] Build `preserving_bwd_step` symmetric to `preserving_fwd_step`: uses `temp_linearity_past` (BX11') fold for P-defect resolution, preserves h_content chain
- [ ] Define backward active defects: `{chi in sigma_list | P(chi) in M AND chi not_in M}`
- [ ] Build symmetric run-composition for backward direction using `hintikka_chain_exists_since` (already sorry-free in Construction.lean)
- [ ] Close sorry #3 (line ~1168): P(phi) in chain(t) gives phi at some earlier time using backward chain P-resolution via the symmetric run-composition
- [ ] Close sorry #2 (line ~1161): F(phi) in backward chain region. Strategy: show F(phi) propagates to the origin (boundary between forward/backward chains) via h_content reverse, then use forward chain `fwd_chain_forward_F` from Phase 3
- [ ] Use `lean_goal` to verify proof states throughout

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Add backward chain infrastructure, close sorries #2 and #3

**Verification**:
- Both sorry branches in `dd_bfmcs_restricted_tc` are closed
- `lake build` succeeds
- `lean_verify` on `dd_bfmcs_restricted_tc` shows no sorry

---

### Phase 5: Close Sorry #5 (Forward Until/Since) [NOT STARTED]

**Goal**: Close sorry #5 (`dd_bfmcs_restricted_fuc`, line ~1183) -- forward Until/Since coherence.

**Tasks**:
- [ ] Prove forward Until coherence: if `(phi U psi) in chain(t)`, then `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)`
- [ ] Step 1: By BX10 (`until_F`), `F(psi) in chain(t)`. By Phase 3's `fwd_chain_forward_F`, exists `s > t` with `psi in chain(s)`
- [ ] Step 2: Choose minimal such s (Nat.find or well-ordering on Nat)
- [ ] Step 3: Guard persistence proof. For r in (t, s), show `phi in chain(r)`:
  - By BX9 (`until_elim`): if `(phi U psi) in chain(r)` and `psi not_in chain(r)`, then `phi in chain(r)`
  - Show `(phi U psi) in chain(r)` for r in (t, s) via BX5 (`self_accum_until`) + forward induction
- [ ] Build helper `until_persists_before_witness`: induction using one-step Until formula preservation through the chain
- [ ] Close Since coherence symmetrically using BX5', BX9', BX10' and backward chain infrastructure
- [ ] Replace the sorry at line ~1183

**Timing**: 2.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close `dd_bfmcs_restricted_fuc`

**Verification**:
- `dd_bfmcs_restricted_fuc` has no sorry
- `lake build` succeeds

---

### Phase 6: Final Verification and Axiom Check [NOT STARTED]

**Goal**: Verify `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`. Attempt sorry #4 (backward Until/Since) if time permits.

**Tasks**:
- [ ] Run `lean_verify` on `bx_completeness` -- check if sorry #4 (`dd_bfmcs_restricted_buc`) is on the critical path
- [ ] If sorry #4 blocks `bx_completeness`: attempt closure using Path D's run structure -- the Hintikka chain provides Until witnesses directly, avoiding the step transfer problem
- [ ] If sorry #4 is not closeable within 2 hours: document the remaining gap and create a follow-up task
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness`
- [ ] Verify output is exactly `{propext, Classical.choice, Quot.sound}` (or document what remains)
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update sorry counts in comments if applicable

**Timing**: 1.5 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Possibly close `dd_bfmcs_restricted_buc`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Verify axioms

**Verification**:
- `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}` (target)
- `lake build` succeeds with no sorry on the critical path
- All phase outcomes documented

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on each closed sorry confirms no sorry axiom leaks
- [ ] `#print axioms bx_completeness` checked at Phase 6
- [ ] Grep for `sorry` in `RootScopedChain.lean` decreases monotonically across phases
- [ ] Realization.lean sorry count drops from 4 to 0 after Phase 1

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/04_implementation-plan.md` (this file)
- Modified source files: RootScopedChain.lean (primary), Realization.lean, possibly Construction.lean, possibly new RunComposition.lean
- Potentially new follow-up task for sorry #4 if not closed

## Rollback/Contingency

- Each phase is independently committable; rollback to previous phase's commit if a phase fails
- **Phase 1 fallback (BACKUP PATH A')**: If the oracle gap in Realization.lean cannot be closed (g_content_sigma rearchitecture too invasive or introduces new blockers), pivot to Path A': use corrected active_defects (Phase 0) + state-space termination argument. The function `n -> (S_n, M_n intersection S_n)` has finite range (at most `3^|sigma_list|` states), so the chain must cycle; a cycle with phi always outside M contradicts BX axioms. Estimated additional effort: 4-6 hours
- **Phase 2 fallback**: If run-composition bridge is too complex, try a direct argument: use the Hintikka chain to establish existence of a BXPoint with phi, then use MCS maximality to place it on the chain
- **Phase 6 fallback**: If sorry #4 remains, mark task [PARTIAL] with 4 of 5 sorries closed and create a follow-up task specifically for backward Until/Since coherence
- If any phase stalls beyond 1.5x estimated time, create a handoff document and mark [PARTIAL] for next session
