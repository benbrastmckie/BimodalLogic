# Implementation Plan: Close BXCanonical Chain Construction Sorries

- **Task**: 109 - Close chain construction sorries
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task 93 (irreflexive semantics switch, completed)
- **Research Inputs**: specs/109_close_chain_construction_sorries/reports/02_team-research.md
- **Artifacts**: plans/02_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 7 critical-path sorry sites (plus 4 dead-code deletions) blocking sorry-free `bx_completeness` in the BXCanonical module. The sorries are artifacts of the irreflexive semantics switch (task 93): the FMCS definition uses `<=` but irreflexive G/H requires strict `<`, forward/backward chains lack symmetric defect-discharge, and Until/Since coherence is unproved. The plan proceeds in 7 phases: axiom audit, dead code cleanup, FMCS strict ordering fix, F-resolution keystone, backward P-preservation, Until/Since coherence, and final verification. Definition of done: `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`.

### Research Integration

- Team research report (02_team-research.md) confirmed 7 of 11 sorries are on the critical path; #1-#4 are dead code
- FMCS ordering mismatch (`<=` vs `<`) identified independently by teammates A and C as root cause of #5/#6
- Deterministic round-robin priority recommended for F-resolution (#7)
- Backward chain lacks P-preservation infrastructure (teammates A, C)
- FMCSDef.lean doc comments (lines 51-52, 88-92) already describe strict ordering but code uses `<=` (lines 110, 117)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Advances ROADMAP item: "Task 109: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence)"
- Prerequisite for Task 95: `#print axioms` audit on `bx_completeness`
- Directly advances the Representation Theorem goal

## Goals & Non-Goals

**Goals**:
- Eliminate all sorry sites on the `bx_completeness -> dd_countermodel` critical path
- Fix FMCS definition to use strict ordering matching irreflexive semantics
- Build symmetric backward chain defect-discharge infrastructure
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}`
- Update ROADMAP.md sorry inventory and status after each phase
- Archive dead code to Boneyard/ and clean up misleading comments

**Non-Goals**:
- Closing non-critical-path sorries (Frame.lean `bx_le_refl`, TruthLemma `*_backward_refl_mcs`, Quasimodel/*, Filtration/*)
- Dense completeness (task 68, independent)
- FMP truth preservation (task 82, independent)
- Changing the BX axiom system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FMCS strict ordering change cascades to RestrictedParametricTruthLemma | H | M | Truth lemma G-case already evaluates strict `<`; change should align |
| Deterministic round-robin requires `preserving_fwd_step` refactor | M | H | Existing `target_stays_direct_in_fold` provides the core mechanism |
| Backward P-preservation is substantial new code | M | M | Follow forward chain patterns symmetrically |
| Until guard persistence through chain is non-trivial | H | M | BX5 (self-accumulation) + BX9 (until_elim) provide the axiom basis |
| `#print axioms` reveals additional transitive sorry dependencies | H | M | Phase 0 audit catches this before implementation begins |
| `g_content_subset_implies_h_content_reverse` duality breaks under strict ordering | M | L | The duality should still hold with strict ordering on both sides |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1, 2 | 0 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3, 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Axiom Audit [NOT STARTED]

**Goal**: Establish the true sorry dependency tree for `bx_completeness` before any code changes.

**Tasks**:
- [ ] Add `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness` at the end of `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Completeness` and capture the axiom list
- [ ] If sorries beyond the 7 identified appear, document them and assess scope impact
- [ ] Add `#print axioms` checks for key intermediate definitions: `dd_countermodel`, `fwd_chain_forward_F`
- [ ] Document the full sorry dependency tree in a comment block at the end of Completeness.lean
- [ ] Clean up misleading comments in CanonicalModel.lean (lines 50-52, 95-97, 115-116, 161-163, 202-204, 209-211) that reference "Phase 2 redesign" or "backward compatibility"

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Add `#print axioms`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Clean up stale comments

**Verification**:
- `lake build` succeeds
- `#print axioms` output captured and documented

---

### Phase 1: Dead Code Cleanup [NOT STARTED]

**Goal**: Delete 4 dead-code sorries (#1-#4) from CanonicalModel.lean and archive to Boneyard/. Update ROADMAP.md.

**Tasks**:
- [ ] Create `Boneyard/DeadCanonicalModel/` directory
- [ ] Move `enriched_seed_consistent` (line 54-56), `fwd_succ_f_carry` (lines 98-101), `enriched_past_seed_consistent` (lines 113-117), `bwd_pred_p_carry` (lines 164-167) to Boneyard file
- [ ] Also move `f_carry` definition (lines 44-45), `f_carry_subset` (line 47-48), `p_carry` (lines 106-107), `p_carry_subset` (lines 109-110) if they have no other callers on the active path
- [ ] Verify `lake build` succeeds after removal
- [ ] Remove the "Dead Code Removed" comment block at the bottom of CanonicalModel.lean (lines 459-472) -- this is already documenting removed code; update if needed
- [ ] Update `specs/ROADMAP.md`: reduce sorry count in the sorry inventory tables, note Phase 1 completion

**Timing**: 0.5 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Remove dead code
- `Boneyard/DeadCanonicalModel/EnrichedSeedLegacy.lean` - Archive dead code
- `specs/ROADMAP.md` - Update sorry inventory

**Verification**:
- `lake build` succeeds with no new errors
- Grep for `enriched_seed_consistent`, `fwd_succ_f_carry`, `enriched_past_seed_consistent`, `bwd_pred_p_carry` returns only Boneyard hits
- Sorry count in `CanonicalModel.lean` reduced from 6 to 2

---

### Phase 2: FMCS Strict Ordering [NOT STARTED]

**Goal**: Change `FMCS.forward_G` and `FMCS.backward_H` from `<=` to `<` (strict), eliminating the need for `g_content_subset_self` (#5) and `h_content_subset_self` (#6). Update ROADMAP.md.

**Tasks**:
- [ ] In `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`:
  - Change `forward_G : forall t t' phi, t ≤ t' -> ...` to `forward_G : forall t t' phi, t < t' -> ...` (line 110)
  - Change `backward_H : forall t t' phi, t' ≤ t -> ...` to `backward_H : forall t t' phi, t' < t -> ...` (line 117)
  - Update doc comments (lines 104-109, 113-116) to remove "reflexive semantics" references
- [ ] In `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean`:
  - Update `int_chain_forward_G` signature: change `h_le : t ≤ t'` to `h_lt : t < t'` (line 336)
  - Update `int_chain_backward_H` signature: change `h_le : t' ≤ t` to `h_lt : t' < t` (line 353)
  - Update `int_chain_g_content` to use strict `<` (line 284)
  - Update `int_chain_h_content` to use strict `<` (line 342)
  - Update `fwd_chain_g_content_trans` to use strict `m < n` instead of `m ≤ n` (line 224), eliminating the `m = n` base case that requires `g_content_subset_self`
  - Update `bwd_chain_h_content_trans` symmetrically (line 246)
  - Delete `g_content_subset_self` (lines 205-207) and `h_content_subset_self` (lines 211-213)
  - Update `bx_fmcs` construction (line 360) and `shifted_bx_fmcs` (line 377) to use strict ordering
- [ ] In `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`:
  - Update `sigma_fwd_g_content_trans` to use strict `m < n` (around line 620)
  - Update `sigma_bwd_h_content_trans` symmetrically (around line 650)
  - Update `dd_chain_g_content`, `dd_chain_h_content`, `dd_chain_forward_G`, `dd_chain_backward_H` to use strict ordering
  - Update `dd_fmcs` and `shifted_dd_fmcs` constructions
- [ ] In `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean`:
  - Update the G-case and H-case of the truth lemma to use strict ordering from FMCS
  - Verify the truth lemma proof still works (G evaluates as "for all t' > t", which matches strict `<`)
- [ ] In `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean`:
  - Update any references to `forward_G`/`backward_H` with non-strict ordering
- [ ] Run `lake build` and fix all type errors from the `<=` to `<` cascade
- [ ] Update `specs/ROADMAP.md`: note FMCS strict ordering fix, update sorry counts

**Timing**: 2 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - Change FMCS definition
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Update chain lemmas, delete #5/#6
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Update sigma chain lemmas
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` - Update truth lemma
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` - Update coherence references
- `specs/ROADMAP.md` - Update sorry inventory

**Verification**:
- `lake build` succeeds
- `g_content_subset_self` and `h_content_subset_self` no longer exist in active code
- `#print axioms dd_countermodel` shows fewer sorry dependencies
- Sorry count in CanonicalModel.lean reduced to 0

---

### Phase 3: F-Resolution Keystone [NOT STARTED]

**Goal**: Close `fwd_chain_forward_F` (#7) by modifying the chain construction for deterministic priority resolution. Update ROADMAP.md.

**Tasks**:
- [ ] Modify `preserving_fwd_step` in RootScopedChain.lean to accept a `target_index : Nat` parameter that determines which formula gets priority resolution via `target_stays_direct_in_fold`
- [ ] Build `targeted_preserving_fwd_step` that:
  - Computes the round-robin target as `sigma_list[n % sigma_list.length]`
  - When the target has an active F-obligation (`F(target) in chain(n)`), uses `target_stays_direct_in_fold` to guarantee `target in chain(n+1)`
  - When the target has no F-obligation, uses regular `fwd_succ` step
  - Preserves all other F-obligations via the existing `preserving_fwd_step_defect_preserved` mechanism
- [ ] Build `targeted_fwd_chain_of_sigma` using the targeted step
- [ ] Prove F-obligation persistence for `|sigma_list|` steps: if `F(phi) in chain(n)` and phi is not resolved at any of steps `n, n+1, ..., n + |sigma_list| - 1`, then `F(phi) in chain(n + |sigma_list|)` (induction on steps using `preserving_fwd_step_defect_preserved`)
- [ ] Prove `fwd_chain_forward_F`: given `F(phi) in chain(n)` and `phi in sigma_list`:
  - phi has some index `k` in sigma_list
  - At step `m = n + (k - n % |sigma_list|) mod |sigma_list|` (or within |sigma_list| steps), phi is the round-robin target
  - F(phi) persists to step m (by F-obligation persistence)
  - At step m, `target_stays_direct_in_fold` guarantees `phi in chain(m+1)`
  - Take witness `m + 1 > n`
- [ ] Update `dd_bfmcs_restricted_tc` forward positive case (line 1078-1087) to use the new chain
- [ ] Update `specs/ROADMAP.md`: note F-resolution keystone closed, update sorry count

**Timing**: 3 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - New targeted chain construction, close `fwd_chain_forward_F`
- `specs/ROADMAP.md` - Update sorry inventory

**Verification**:
- `fwd_chain_forward_F` has no sorry
- `lake build` succeeds
- `dd_bfmcs_restricted_tc` forward positive case (line 1082) works with new chain

---

### Phase 4: Backward P-Preservation [NOT STARTED]

**Goal**: Build `preserving_bwd_step` symmetric to the forward chain, close `restricted_tc` backward cases (#8, #9). Update ROADMAP.md.

**Tasks**:
- [ ] Build `preserving_bwd_step` in RootScopedChain.lean:
  - Mirrors `preserving_fwd_step` but for P-formulas using `h_content` instead of `g_content`
  - Tracks active P-defects: `{chi in sigma_list | P(chi) in chain(n)}`
  - Uses BX11' (`temp_linearity_past`) fold for priority P-resolution
  - Proves P-obligation persistence: `P(chi) in chain(n) -> chi in chain(n+1) OR P(chi) in chain(n+1)`
- [ ] Build `targeted_preserving_bwd_step` with round-robin priority (symmetric to forward)
- [ ] Build `targeted_bwd_chain_of_sigma` using the targeted backward step
- [ ] Prove `bwd_chain_backward_P`: given `P(phi) in bwd_chain(n)` and `phi in sigma_list`, prove `exists m > n, phi in bwd_chain(m)` (using the same round-robin pigeonhole argument as Phase 3)
- [ ] Close sorry #8 (`dd_bfmcs_restricted_tc` forward, t-s < 0 case, line 1092):
  - F(phi) in backward chain region needs resolution
  - Propagate F(phi) to the origin via g_content chain: `G(F(phi))` if available, or use the backward-to-forward boundary
  - If `G(F(phi)) in chain(t)`, then by temp_4, `G(G(F(phi))) in chain(t)`, so `G(F(phi))` propagates to origin and forward
  - Alternative: show F(phi) in bwd_chain gives F(phi) at origin via h_content reverse propagation, then use forward chain F-resolution
- [ ] Close sorry #9 (`dd_bfmcs_restricted_tc` backward direction, line 1099):
  - P(phi) in chain(t) needs phi at some t' < t
  - Symmetric to F-resolution but using backward chain
  - For t-s >= 0 (forward region): propagate P to origin, then backward chain resolves
  - For t-s < 0 (backward region): directly use `bwd_chain_backward_P`
- [ ] Update `specs/ROADMAP.md`: note backward infrastructure complete, update sorry count

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - New backward chain infrastructure, close #8 and #9
- `specs/ROADMAP.md` - Update sorry inventory

**Verification**:
- `dd_bfmcs_restricted_tc` has no sorry in any branch
- `lake build` succeeds
- `#print axioms dd_bfmcs_restricted_tc` shows no sorry

---

### Phase 5: Until/Since Coherence [NOT STARTED]

**Goal**: Close `restricted_buc` (#10) and `restricted_fuc` (#11). Update ROADMAP.md.

**Tasks**:
- [ ] Close sorry #10 (`dd_bfmcs_restricted_buc`, line 1107) -- backward Until coherence:
  - Goal: if `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)`, then `(phi U psi) in chain(t)`
  - Proof by MCS maximality: suppose `neg(phi U psi) in chain(t)`
  - Use BX axioms to derive contradiction from the existence of the witness
  - Key axioms: BX9 (until_elim) contrapositive, BX2 (left_mono_until), BX7 (linear_until)
  - The argument: if `neg(phi U psi) in chain(t)` and `psi in chain(s)` with guard phi on `(t,s)`, derive `neg(phi U psi) in chain(r)` for all r in [t,s) using g_content propagation of `G(neg(phi U psi))` (if available) or step-by-step analysis using backward_until_from_step (sorry-free, exists)
- [ ] Close sorry #11 (`dd_bfmcs_restricted_fuc`, line 1114) -- forward Until coherence:
  - Goal: if `(phi U psi) in chain(t)`, then `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)`
  - Step 1: By BX10, `F(psi) in chain(t)`. By Phase 3's `fwd_chain_forward_F`, exists `s > t` with `psi in chain(s)`
  - Step 2: Choose minimal such s (well-ordering on Nat)
  - Step 3: Guard persistence -- show `phi in chain(r)` for all `r in (t,s)`:
    - By BX5 (self_accum_until): `(phi U psi) -> ((phi AND (phi U psi)) U psi)`. So `(phi AND (phi U psi)) U psi in chain(t)`
    - By BX9 (until_elim): `(phi U psi) -> phi OR psi`. So `phi in chain(t)` (since if `psi in chain(t)`, take s = t+1; but under strict ordering we need s > t which is handled)
    - For intermediate r in (t, s): need `phi U psi in chain(r)` to extract phi via BX9
    - Key difficulty: `phi U psi` does not propagate through g_content
    - Strategy: use `restricted_buc` (#10, just proved) as the backward direction. If `phi in chain(r)` for all `r in (t, s)` and `psi in chain(s)`, then `phi U psi in chain(r)` for all r by backward coherence. This is circular -- we need to prove the guard BEFORE invoking backward coherence
    - Alternative strategy: use the defect-discharge chain. BX5 gives `(phi AND (phi U psi)) U psi in chain(t)`. At each step t+1, t+2, ..., s-1, the Until formula persists as long as psi hasn't appeared. Since s is the FIRST time psi appears, for r < s, `psi not_in chain(r)`. By BX9, if `(phi U psi) in chain(r)`, then `phi OR psi in chain(r)`, so `phi in chain(r)` (since `psi not_in chain(r)` and MCS are negation-complete). The missing link is showing `(phi U psi) in chain(r)` for r in (t, s)
    - Use induction on r: for r = t, given. For r = t+1: if `(phi U psi) in chain(t)`, then by BX5, the enriched Until persists. By the chain construction, at step t+1 the defect-discharge resolves F-obligations, and the Until formula may or may not persist. But we need a separate argument here
    - Consider: `F_until_equiv` (BX12): `F(phi) -> T U phi`. So `F(psi) in chain(t)` gives `T U psi in chain(t)`. This is weaker than `phi U psi` but still guarantees a witness
    - The correct approach may be: use the semantics directly. The restricted parametric truth lemma connects MCS membership to semantic truth. If `phi U psi in chain(t)` (MCS membership), then by the truth lemma, `phi U psi` is semantically true at t. Semantic Until gives the witness. But this is circular (truth lemma requires coherence)
    - **Recommended approach**: Build the forward Until coherence proof by combining F-resolution with the Until-specific BX axioms. The proof should track the Until formula through the chain using BX5 enrichment and show that the guard holds at each step until psi appears
- [ ] Build helper lemmas as needed:
  - `until_persists_before_witness`: if `phi U psi in chain(t)` and `psi not_in chain(r)` for all r in (t, s), then `phi U psi in chain(r)` for r in (t, s)
  - This may require `backward_until_from_step` (already sorry-free) or a new chain property
- [ ] Update `specs/ROADMAP.md`: note Until/Since coherence complete, update sorry count to reflect all critical-path sorries closed

**Timing**: 2 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close #10 and #11
- `specs/ROADMAP.md` - Update sorry inventory

**Verification**:
- `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` have no sorry
- `lake build` succeeds
- `#print axioms dd_countermodel` shows no sorry

---

### Phase 6: Final Verification [NOT STARTED]

**Goal**: Verify `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`. Update ROADMAP.md with final state.

**Tasks**:
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness`
- [ ] Verify output is exactly `{propext, Classical.choice, Quot.sound}` (no sorry, no additional axioms)
- [ ] If unexpected axioms appear, trace and resolve them
- [ ] Update the comment block in Completeness.lean with the verified axiom list
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update `specs/ROADMAP.md`:
  - Update sorry inventory to show 0 critical-path sorries
  - Update task 109 status to completed
  - Update task 95 status (if appropriate -- may already be satisfied by this verification)
  - Update the "Recommended Priority Order" section

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Final axiom verification
- `specs/ROADMAP.md` - Final status update

**Verification**:
- `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}`
- `lake build` succeeds with no sorry on the critical path
- ROADMAP.md accurately reflects the new state

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `#print axioms bx_completeness` shows no sorry after Phase 6
- [ ] `#print axioms dd_countermodel` shows no sorry after Phase 5
- [ ] Grep for `sorry` in CanonicalModel.lean returns 0 hits after Phase 2
- [ ] Grep for `sorry` in critical-path definitions (`fwd_chain_forward_F`, `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`) returns 0 hits after Phase 5

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/02_implementation-plan.md` (this file)
- `Boneyard/DeadCanonicalModel/EnrichedSeedLegacy.lean` (archived dead code)
- Modified source files: FMCSDef.lean, CanonicalModel.lean, RootScopedChain.lean, RestrictedParametricTruthLemma.lean, Completeness.lean
- Updated `specs/ROADMAP.md` (after each phase)

## Rollback/Contingency

- Each phase is independently committable; rollback to the previous phase's commit if a phase fails
- The FMCS strict ordering change (Phase 2) is the riskiest cascade; if it breaks too many things, the alternative is to keep `<=` but prove the `m = n` base case differently (e.g., by proving callers never request the reflexive case)
- If the round-robin approach for Phase 3 proves unworkable, fall back to Solution B (BX11-ordered resolution using `bx11_earlier` total ordering)
- If backward P-preservation (Phase 4) is too complex, consider a simpler argument: for the cross-boundary F/P cases, prove that F/P formulas at the boundary point (origin) are resolved by the respective forward/backward chains
- If Until guard persistence (Phase 5, #11) cannot be proved with BX axioms alone, consider adding a helper that uses the existing quasimodel infrastructure (sorry-free) to provide Until witnesses
