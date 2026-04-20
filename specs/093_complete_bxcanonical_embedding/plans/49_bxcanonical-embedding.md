# Implementation Plan: Task #93 (v49) - BXCanonical Sorry Closure

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (task 92 satisfied)
- **Research Inputs**: reports/49_team-research.md
- **Artifacts**: plans/49_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses the critical soundness gap discovered by team research: Truth.lean implements an **open guard (t, s)** for Until/Since (the guard is `t < r /\ r < s`), but BX9 (until_elim: `phi U psi -> phi \/ psi`) requires the guard to include `t` to guarantee `phi(t)`. The fix is to change the guard to half-open `[t, s)` (i.e., `t <= r /\ r < s`), which validates BX9 and restores soundness. After the soundness fix, the plan addresses sorry closure through two paths: (1) complete Soundness.lean proofs that are now engineering debt, and (2) close the RootScopedChain.lean sorry sites using constrained Lindenbaum or quasimodel fallback. Definition of done: all sorry sites on the active completeness path closed, `lake build` clean.

### Research Integration

- **Report 49** (team, 4 teammates): Identified critical soundness break -- Truth.lean uses open guard (t, s) making BX9 unsound. Confirmed constrained Lindenbaum is NOT universally applicable (fails when G(phi) in M). Recommended priority: (1) fix guard convention, (2) attempt constrained Lindenbaum, (3) fallback to quasimodel semantic rewrite (~500-800 LOC). All teammates agree phi_imp_F_phi sorry sites are correct (phi -> F(phi) is NOT derivable under irreflexive semantics and should be DELETED, not closed).

### Prior Plan Reference

Plan v48 (5 phases, 14 hours): Phases 1 (semantic switch) and 2 (frame/model repair) completed successfully. Phase 3 (chain redesign) was PARTIAL -- defect_step_early redesign started but phi_imp_F_phi dependencies remain. Phase 4 (sorry closure) was BLOCKED by Lindenbaum non-determinism. Key lessons: (1) the irreflexive switch itself is correct and validated; (2) phi_imp_F_phi is correctly identified as invalid under irreflexive semantics; (3) the active_defects finite descent argument needs constrained Lindenbaum or alternative; (4) ROAD_MAP.md was already updated in Phase 5.

### Roadmap Alignment

- **Task 93**: Close remaining active-path sorries in RootScopedChain.lean
- **Task 95**: `#print axioms` audit depends on task 93 completion
- ROAD_MAP.md already updated (v48 Phase 5 completed), may need minor correction for guard fix

## Goals & Non-Goals

**Goals**:
- Fix Until/Since guard convention from open (t, s) to half-open [t, s) in Truth.lean
- Complete all sorry'd soundness proofs in Soundness.lean (serial, temporal interaction, until_step, until_elim)
- Remove phi_imp_F_phi and phi_imp_P_phi (invalid under irreflexive semantics) and refactor callers
- Close the 5 core sorry sites in RootScopedChain.lean (fwd_chain_forward_F, restricted_tc x2, restricted_buc, restricted_fuc)
- Achieve `lake build` with zero sorries on active completeness path

**Non-Goals**:
- Repairing Quasimodel BX1/BX8 dependencies (not on critical path)
- Bundle module sorry sites (not on critical path)
- g_content_subset_self (genuinely false under irreflexive semantics -- correct to sorry)
- Dense completeness (task 68, independent)
- Reverting the irreflexive switch (confirmed correct by research)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard fix cascades through TimeShift lemmas requiring extensive mechanical updates | M | H (70%) | TimeShift lemmas mostly use `t < r` (witness) not guard direction. Audit systematically. Changes are mechanical. |
| serial_future/serial_past proofs require NoMaxOrder/NoMinOrder typeclass | M | M (50%) | The canonical model uses Int which has both. Add typeclass constraint to soundness theorem or specialize to Int. |
| until_step_valid requires density or successor structure after guard fix | H | M (40%) | Under half-open guard [t, s): phi /\ F(phi U psi) -> phi U psi. Need witness s' > t with (phi U psi)(s'), then build new witness. May require DenseOrder or discrete step. |
| Constrained Lindenbaum fails (G(phi) in M for resolved defect phi) | H | M (45%) | If constrained Lindenbaum blocked, fall back to quasimodel bridge (~500-800 LOC). Research gives 75% confidence on quasimodel approach. |
| Removing phi_imp_F_phi breaks downstream callers in unexpected ways | M | M (40%) | Audit all callers before removal. The key callers are defect_step_early (already identified) and phi_in_mcs_imp_F_phi (wrapper). Replace with constrained construction. |
| fwd_chain_forward_F requires finite induction argument that's hard to formalize | H | M (35%) | Under irreflexive semantics, active_defects strictly decreases. Formalize as Finset.card decrease on each resolution step. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are sequential: each depends on the semantic/axiom changes of the prior phase.

---

### Phase 1: Fix Guard Convention and Soundness [NOT STARTED]

**Goal**: Change Until/Since guard from open (t, s) to half-open [t, s) in Truth.lean, then complete all sorry'd soundness proofs. After this phase, Soundness.lean is sorry-free.

**Tasks**:
- [ ] Truth.lean line 128: Change `t < r → r < s` to `t ≤ r → r < s` (Until guard includes current point)
- [ ] Truth.lean line 130: Change `s < r → r < t` to `s < r → r ≤ t` (Since guard includes current point)
- [ ] Fix all TimeShift lemmas that reference the guard direction (audit lines 321-575)
- [ ] Soundness.lean: Complete `serial_future_axiom_valid` (line 200) -- use `NoMaxOrder` typeclass or specialize
- [ ] Soundness.lean: Complete `serial_past_axiom_valid` (line 213) -- use `NoMinOrder` typeclass
- [ ] Soundness.lean: Complete the temporal interaction proof at line 448 (F(phi /\ H(phi)) under half-open guard)
- [ ] Soundness.lean: Complete `until_step_valid` (line 743) -- under half-open guard, phi /\ F(phi U psi) -> phi U psi
- [ ] Soundness.lean: Complete `since_step_valid` (line 751) -- mirror of until_step
- [ ] Soundness.lean: Complete `until_elim_valid` (line 761) -- under half-open [t, s): guard includes t, so phi(t) holds
- [ ] Soundness.lean: Complete `since_elim_valid` (line 771) -- mirror of until_elim
- [ ] Run `lake build` and verify Soundness.lean compiles sorry-free
- [ ] Catalog any new breakage from the guard change in downstream files

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- 2 guard flips + TimeShift repairs (~100 LOC)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- complete 7 sorry'd proofs (~150 LOC)

**Verification**:
- Truth.lean compiles with half-open guard `t ≤ r → r < s` for Until
- Soundness.lean has zero `sorry` keywords
- `lake build` passes (downstream breakage cataloged but not blocking)

---

### Phase 2: Remove phi_imp_F_phi Infrastructure and Redesign Chain [NOT STARTED]

**Goal**: Delete the invalid `phi_imp_F_phi` and `phi_imp_P_phi` definitions and all callers. Redesign `defect_step_early` to work without them. The chain construction should compile (with the 5 core sorry sites still open).

**Tasks**:
- [ ] Delete `phi_imp_F_phi_early` (line 471-473) and `phi_in_mcs_imp_F_phi_early` (line 476-479)
- [ ] Delete `phi_imp_F_phi` (line 990-992) and `phi_in_mcs_imp_F_phi` (line 995-998)
- [ ] Delete `phi_imp_P_phi` (line 1519-1521) and `phi_in_mcs_imp_P_phi` (line 1523-1527)
- [ ] Audit all callers of the deleted definitions (grep for `phi_in_mcs_imp_F_phi` and `phi_in_mcs_imp_P_phi`)
- [ ] Redesign `defect_step_early`: Instead of preserving F(phi) for ALL formulas in the seed, only preserve F-obligations for UNRESOLVED defects. The key property: when phi is resolved into the next MCS, F(phi) does NOT need to be in that MCS.
- [ ] Verify `active_defects` type/definition allows proving strict decrease after defect resolution
- [ ] Build `preserving_bwd_step` infrastructure (symmetric to `preserving_fwd_step`) if not already present
- [ ] Run `lake build` -- verify no new sorry sites beyond the identified 5 core sites

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- delete 6 defs/theorems, redesign defect_step_early (~200 LOC changes)

**Verification**:
- No occurrences of `phi_imp_F_phi` or `phi_imp_P_phi` in file
- `defect_step_early` compiles without using phi -> F(phi) derivation
- `lake build` passes with exactly the 5 core sorry sites remaining
- No new sorry sites introduced

---

### Phase 3: Close fwd_chain_forward_F and restricted_tc [NOT STARTED]

**Goal**: Close the first 3 sorry sites: `fwd_chain_forward_F` (line 1093), and both cases of `restricted_tc` (lines 1120, 1127). These are the temporal coherence foundations that the Until/Since coherence proofs depend on.

**Tasks**:
- [ ] **fwd_chain_forward_F**: Prove via finite defect induction. Key argument: under irreflexive semantics with redesigned defect_step_early, resolving a defect phi means phi enters the MCS but F(phi) does NOT re-enter (because phi -> F(phi) is not derivable). Therefore active_defects.card strictly decreases. After at most |sigma_list| steps, phi must be resolved. Formalize using `Nat.lt_wfRel` or `Finset.card` well-founded descent.
- [ ] **restricted_tc backward F-case** (line 1120): When t - s < 0 (backward chain region), F(phi) in fam.mcs(t) needs resolution. Strategy: the backward chain was built from the same root MCS. Show that F(phi) in the backward chain's MCS implies there exists a forward position where phi holds (use the root MCS as bridge -- it contains all forward obligations).
- [ ] **restricted_tc P-direction** (line 1127): Symmetric to forward direction using backward chain. P(phi) in fam.mcs(t) with t in forward region needs past witness. Use `preserving_bwd_step` infrastructure.
- [ ] Run `lake build` to verify these 3 sorry sites are closed

**Timing**: 3.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close 3 sorry sites (~200 LOC of proofs)

**Verification**:
- `fwd_chain_forward_F` has no `sorry`
- `dd_bfmcs_restricted_tc` has no `sorry`
- `lake build` passes with only `restricted_buc` and `restricted_fuc` sorry sites remaining

---

### Phase 4: Close restricted_buc and restricted_fuc [NOT STARTED]

**Goal**: Close the final 2 sorry sites (Until/Since coherence). These depend on `restricted_tc` (proved in Phase 3) and the Until/Since propagation axioms BX9, BX10, BX12.

**Tasks**:
- [ ] **restricted_buc** (line 1135): Backward Until/Since coherence. For `phi U psi` at position r+1 in the chain with witness s > r+1: under half-open guard [r+1, s), phi holds on [r+1, s). Need to show `phi U psi` at position r. Strategy: if r+1 is strictly between r and s, then s > r and psi(s), and guard [r, s) includes r (half-open) so need phi(r). Use BX9 (until_elim, now sound): (phi U psi) -> phi \/ psi at r+1 gives phi(r+1). Combined with chain structure, construct witness for Until at r.
- [ ] **restricted_fuc** (line 1142): Forward Until/Since coherence. For `phi U psi` needing resolution: use BX10 (until_F: phi U psi -> F(psi)) to extract eventuality, then use `restricted_tc` (now proved) to find the witness position where psi holds. Verify that the guard condition propagates correctly under the half-open convention.
- [ ] Run `lake build` -- should succeed with zero sorries on active path
- [ ] Run `lean_verify` on `bx_completeness` to confirm no sorry dependency

**Timing**: 2.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close 2 sorry sites (~150 LOC)

**Verification**:
- Zero `sorry` keywords in RootScopedChain.lean (excluding g_content_subset_self and h_content_subset_self which are correctly sorry'd)
- `lake build` succeeds
- `lean_verify bx_completeness` shows only propext, Classical.choice, Quot.sound
- `lean_verify dd_countermodel` shows no sorry dependency

---

## Testing & Validation

- [ ] After Phase 1: Soundness.lean is sorry-free, `lake build` passes
- [ ] After Phase 2: phi_imp_F_phi fully removed, `lake build` passes with 5 core sorries only
- [ ] After Phase 3: restricted_tc sorry-free, `lake build` passes with 2 sorries
- [ ] After Phase 4: zero active-path sorries, `lean_verify bx_completeness` clean
- [ ] BX9 (until_elim) validated by completed Soundness proof under half-open guard
- [ ] Guard convention consistent: Until guard is [t, s), Since guard is (s, t]

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/49_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Semantics/Truth.lean` -- half-open guard convention
- `Theories/Bimodal/Metalogic/Soundness.lean` -- sorry-free soundness proofs
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- sorry-free coherence proofs

## Rollback/Contingency

1. **Phase 1 rollback**: `git checkout -- Theories/Bimodal/Semantics/Truth.lean Theories/Bimodal/Metalogic/Soundness.lean` restores open guard. Low risk -- this phase is primarily fixing a bug.

2. **Phase 2 rollback**: Revert RootScopedChain.lean to restore phi_imp_F_phi. If the redesigned defect_step_early proves unworkable, can restore the sorry'd version.

3. **Phase 3 contingency (fwd_chain_forward_F fails)**: If finite descent formalization is too complex, consider: (a) adding an explicit well-founded recursion on `sigma_list.length - active_defects.card`, or (b) building an IRR (irreflexive reasoning) meta-tactic that automates the induction. Estimated fallback: +3 hours.

4. **Phase 4 contingency (Until coherence fails)**: If BX9/BX10-based Until propagation does not compose cleanly with the chain structure, fall back to the quasimodel semantic rewrite. This replaces Phases 3-4 entirely with a quasimodel-to-Int embedding (~500-800 LOC, estimated +6 hours). Research gives 75% confidence on this approach.

5. **Complete rollback**: The branch `irr_until` contains all changes. Can reset to pre-Phase-1 commit at any time.
