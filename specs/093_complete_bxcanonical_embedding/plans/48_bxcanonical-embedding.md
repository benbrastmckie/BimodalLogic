# Implementation Plan: Irreflexive Semantics with A2 Guard Convention

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 92 (truth lemma sorry-free) -- satisfied
- **Research Inputs**: reports/48_team-research.md, reports/44_team-research.md
- **Artifacts**: plans/48_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the irreflexive semantics switch with A2 guard convention (strict witness, half-open guard) across the BX proof system. The switch changes four inequality constraints from reflexive (<=) to strict (<) in Truth.lean, removes 4 axioms (BX1, BX1', BX8, BX8'), adds 2 seriality axioms, and propagates these changes through soundness, canonical frame, canonical model, chain construction, and sorry closure. The key architectural insight is that under irreflexive semantics, resolved defects no longer re-enter via phi -> F(phi), causing active_defects to naturally shrink -- this is the mechanism that unblocks the 5 remaining sorry sites. Definition of done: all 5 sorry sites in RootScopedChain.lean closed with `lake build` passing and `#print axioms` clean.

### Research Integration

- **Report 48** (team, 4 teammates): Established A2 guard convention (strict witness s > t, half-open guard [t, s)) as the recommended approach. Confirmed BX9 validity under A2 (resolving teammate conflict). Discovered that `defect_step_early` uses `phi_in_mcs_imp_F_phi_early` (derived from phi -> F(phi)), which is INVALID under irreflexive semantics -- but this is a simplification, not a blocker. Produced complete axiom disposition table and file-by-file impact analysis (800-1200 LOC). Identified that Quasimodel has BX1/BX8 dependencies but is NOT on the critical completeness path.

- **Report 44** (team, 4 teammates): Three-path strategy (C, A, B) for closing sorries under reflexive semantics. All three paths hit the irreducible core: defect-count monotonicity across Lindenbaum extension, caused by phi -> F(phi) regeneration. This confirms the irreflexive switch as the correct strategic pivot.

### Prior Plan Reference

**Plan v44** (7 phases, 12 hours, PARTIAL): Attempted three paths (C: pigeonhole, A: oracle chains, B: quasimodel BFMCS) under reflexive semantics. Phase 1 (ROAD_MAP.md update) and evaluation phases completed. Paths C and A were blocked by the irreducible defect oscillation problem: resolving phi creates F(phi) which re-enters as a new defect. Key lessons: (1) defect oscillation via phi -> F(phi) is the fundamental obstruction under reflexive semantics; (2) the enriched seed approach is definitively dead; (3) `preserving_fwd_step` infrastructure with `defect_step_choice_early` is validated and sorry-free -- it correctly preserves F-obligations and resolves at least one defect per step. The irreflexive switch eliminates the oscillation by making phi -> F(phi) invalid.

### Roadmap Alignment

- **Task 93** (ROAD_MAP.md): Close remaining active-path sorries in RootScopedChain.lean -- this plan addresses all 5
- **Task 95**: `#print axioms` audit depends on task 93
- ROAD_MAP.md will need updating with the irreflexive semantics switch strategy and revised axiom table

## Goals & Non-Goals

**Goals**:
- Switch Truth.lean to irreflexive semantics with A2 guard convention (4 inequality flips)
- Remove axioms BX1, BX1', BX8, BX8' and add serial_future, serial_past
- Update soundness proofs for the new axiom set
- Repair canonical frame (Frame.lean) without bx_le_refl
- Repair canonical model (CanonicalModel.lean) enriched seed consistency
- Redesign defect_step_early to not use phi -> F(phi)
- Build backward chain infrastructure (preserving_bwd_step)
- Close all 5 sorry sites in RootScopedChain.lean
- Update ROAD_MAP.md with the irreflexive strategy

**Non-Goals**:
- Repairing Quasimodel BX1/BX8 dependencies (not on critical path)
- Repairing Bundle BX1 sites (not on critical path)
- Dense completeness (task 68, independent)
- Building full IRR infrastructure (fallback only, deferred unless needed)
- Fixing OracleStep.lean sorries (archived to Boneyard)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| bx_le_refl removal cascades widely through Frame.lean | H | M (40%) | A2 preserves transitivity (BX4/temp_4 still valid). Replace reflexivity with seriality-based arguments. Frame.lean is 673 lines -- audit all bx_le_refl call sites. |
| Enriched seed consistency proofs use BX1 in CanonicalModel.lean | H | M (50%) | These proofs need G(bot) -> bot which follows from seriality + consistency, not BX1. Redesign to use serial_future. |
| defect_step_early redesign harder than expected | H | L (30%) | The redesign is a simplification: remove F-preservation for resolved defects. The existing `defect_step_choice_early_spec` infrastructure is sorry-free and validated. |
| Sorry #1 (fwd_chain_forward_F) still blocked after redesign | H | M (35%) | Under irreflexive semantics, active_defects strictly decreases because resolved defects cannot re-enter. If finite induction fails, IRR infrastructure is the fallback (~150 LOC). |
| Step transfer for sorries #4-5 requires semantic chain argument, not general axiom | M | L (25%) | Report 48 confirmed phi AND F(phi U psi) -> phi U psi is NOT a valid axiom under A2. The step transfer is a chain-level property: given specific witness structure at chain position r+1 and phi at r, the same witness works at r. This is concrete engineering, not a gap. |
| TimeShift proofs (~200 LOC) require extensive mechanical updates | M | L (20%) | These are pure <=->< substitutions. Tedious but deterministic. |
| Quasimodel and Bundle code breaks (non-critical) | L | H (80%) | Explicitly deferred to non-goals. These modules are not imported by the completeness path. Mark with sorry and address in a follow-up task. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are fully sequential: each builds on the prior phase's semantic and axiomatic changes.

---

### Phase 1: Semantic and Axiom Layer Switch [NOT STARTED]

**Goal**: Change Truth.lean to irreflexive semantics with A2 guard convention, update the axiom set (remove 4, add 2), and update soundness proofs. After this phase, `lake build` should pass with new sorries only in files that depend on removed axioms.

**Tasks**:
- [ ] Truth.lean: Change `all_future` from `t <= s` to `t < s`
- [ ] Truth.lean: Change `all_past` from `s <= t` to `s < t`
- [ ] Truth.lean: Change `untl` witness from `t <= s` to `t < s` (guard `t <= r` stays as-is per A2)
- [ ] Truth.lean: Change `snce` witness from `s <= t` to `s < t` (guard stays as-is per A2)
- [ ] Update all TimeShift lemmas in Truth.lean that depend on the old inequality direction (~200 LOC of mechanical <= to < changes)
- [ ] Axiom.lean: Remove `temp_t_future` (BX1), `temp_t_past` (BX1'), `refl_intro_until` (BX8), `refl_intro_since` (BX8')
- [ ] Axiom.lean: Add `serial_future : Axiom` with statement `top -> F(top)` and `serial_past : Axiom` with statement `top -> P(top)`
- [ ] Soundness.lean: Remove validity proofs for BX1, BX1', BX8, BX8'
- [ ] Soundness.lean: Add validity proofs for serial_future (for any t, exists s > t -- uses properties of the ordered domain) and serial_past (symmetric)
- [ ] Fix any other Soundness.lean proofs that break due to inequality direction changes
- [ ] TemporalDerived.lean: Delete or sorry `density_derivable`, `past_density_derivable`, and other BX1-dependent derived theorems (~8 theorems, ~40 LOC)
- [ ] Run `lake build` and catalog all new errors (expected: Frame.lean, CanonicalModel.lean, RootScopedChain.lean, possibly Quasimodel/)

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- 4 inequality flips + ~200 LOC TimeShift updates
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- remove 4 axioms, add 2
- `Theories/Bimodal/Metalogic/Soundness.lean` -- remove 4 proofs, add 2
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- delete BX1-dependent theorems

**Verification**:
- Truth.lean compiles with strict inequality semantics
- Axiom.lean has 35 axioms (37 - 4 + 2)
- Soundness.lean compiles with seriality proofs
- `lake build` error catalog shows expected breakage in downstream files only

---

### Phase 2: Canonical Frame and Model Repair [NOT STARTED]

**Goal**: Repair Frame.lean and CanonicalModel.lean to work without BX1/BX1'. The canonical temporal ordering `bx_le` loses reflexivity but retains transitivity. Enriched seed consistency proofs must be redesigned to use seriality instead of BX1.

**Tasks**:
- [ ] Frame.lean: Delete `bx_le_refl` (the proof that `g_content w subset w`, which requires BX1)
- [ ] Frame.lean: Audit all 673 lines for other BX1 dependencies -- `g_content_set_consistent` uses BX1 to derive contradiction from G(bot) in MCS; redesign to use serial_future (if G(bot) in w, then for all s > t: bot at s, but serial_future gives exists s > t, contradiction)
- [ ] Frame.lean: Verify `bx_le_trans` still holds (uses BX4/temp_4, both kept)
- [ ] CanonicalModel.lean: Fix enriched seed consistency proofs that use BX1 (~7 sites per report 48)
- [ ] CanonicalModel.lean: Redesign any proof that assumes `phi in w -> phi in g_content w` (reflexivity direction)
- [ ] Fix `fwd_chain_g_content_trans` base case if it depends on bx_le_refl
- [ ] Run `lake build` to verify Frame.lean and CanonicalModel.lean compile
- [ ] Catalog remaining errors (should be limited to RootScopedChain.lean and non-critical modules)

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- delete bx_le_refl, redesign g_content_set_consistent (~80 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- fix enriched seed consistency (~60 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- possible BX1 dependencies

**Verification**:
- Frame.lean compiles without bx_le_refl
- CanonicalModel.lean compiles with seriality-based consistency proofs
- `lake build` errors reduced to RootScopedChain.lean and non-critical modules

---

### Phase 3: Chain Construction Redesign [NOT STARTED]

**Goal**: Redesign `defect_step_early` and the chain construction in RootScopedChain.lean to not use phi -> F(phi). Build backward chain infrastructure. After this phase, the chain construction compiles (possibly with the 5 sorries still open but no additional sorry sites).

**Tasks**:
- [ ] RootScopedChain.lean: Locate `defect_step_early` (line ~524) and `phi_in_mcs_imp_F_phi_early` usage
- [ ] Redesign `defect_step_early` to NOT preserve F for resolved defects -- only preserve F-obligations for UNRESOLVED defects via the enriched seed
- [ ] Verify that under the redesigned chain, `active_defects` count strictly decreases when a defect is resolved (key property: resolved phi enters MCS, but F(phi) does NOT automatically re-enter because phi -> F(phi) is invalid)
- [ ] Fix all other BX1/BX1' usage sites in RootScopedChain.lean (~10 sites per report 48)
- [ ] Build `preserving_bwd_step` -- symmetric to `preserving_fwd_step`, using BX11' (past linearity) instead of BX11
- [ ] Build backward chain analogues: `bwd_chain_of_sigma` or equivalent using `preserving_bwd_step`
- [ ] Prove `bwd_chain_backward_P` (symmetric to `fwd_chain_F_persistent` but for P-obligations)
- [ ] Run `lake build` and verify no new sorry sites beyond the original 5

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- redesign defect_step_early (~200 LOC), build backward chain (~100-150 LOC)

**Verification**:
- `defect_step_early` compiles without `phi_in_mcs_imp_F_phi_early`
- `active_defects` count decrease property stated and proved (or at least compiles with the property as a hypothesis)
- Backward chain infrastructure compiles
- No new sorry sites beyond the original 5

---

### Phase 4: Close Sorry Sites [NOT STARTED]

**Goal**: Close all 5 sorry sites in RootScopedChain.lean using the redesigned chain construction and backward chain infrastructure.

**Tasks**:
- [ ] **Sorry #1** `fwd_chain_forward_F` (line 1111): Prove via finite defect induction. Under irreflexive semantics, active_defects strictly decreases at each resolution step (no phi -> F(phi) re-entry). After at most |sigma_list| steps, all defects including phi are resolved, giving phi in chain(m) for some m > n. If finite induction fails, evaluate IRR fallback.
- [ ] **Sorry #2** `restricted_tc` backward chain F-case (line 1138): Use `fwd_chain_forward_F` (now proved) to show F-resolution on the backward chain. The backward chain's F-obligations are resolved by the forward direction.
- [ ] **Sorry #3** `restricted_tc` P-direction (line 1145): Use `preserving_bwd_step` and `bwd_chain_backward_P` to show P-resolution. Symmetric to the forward case using BX11'.
- [ ] **Sorry #4** `restricted_buc` (line 1153): Prove backward Until/Since coherence. Requires restricted_tc as prerequisite. For Until step transfer under A2: given phi U psi at chain position r+1 (with concrete witness s > r+1), and the chain satisfies guard and witness propagation, show phi U psi at position r. This is a chain-level semantic argument using the specific witness structure, not a general axiom.
- [ ] **Sorry #5** `restricted_fuc` (line 1160): Prove forward Until/Since coherence. Requires restricted_tc. Use BX10 (until_F) for F-witness extraction and BX9 (until_elim, preserved under A2) for guard propagation.
- [ ] Run `lake build` -- should succeed with zero sorries on the active path
- [ ] Run `lean_verify` on `dd_countermodel` and `bx_completeness` to confirm no sorry dependency

**Timing**: 3.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close 5 sorry sites (~200 LOC of new proofs)

**Verification**:
- All 5 sorry sites closed (no `sorry` in RootScopedChain.lean)
- `lake build` succeeds
- `lean_verify dd_countermodel` shows no sorry dependency
- `lean_verify bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

---

### Phase 5: ROAD_MAP.md Update and Non-Critical Cleanup [NOT STARTED]

**Goal**: Update ROAD_MAP.md with the irreflexive semantics strategy, updated axiom table, and resolved sorry inventory. Clean up non-critical breakage with sorry markers for follow-up tasks.

**Tasks**:
- [ ] ROAD_MAP.md: Update "Overview" section to describe irreflexive A2 semantics
- [ ] ROAD_MAP.md: Update BX Axiom System table (remove BX1/BX1'/BX8/BX8', add serial_future/serial_past)
- [ ] ROAD_MAP.md: Update "Reflexive Truth Semantics" section to "Irreflexive Truth Semantics" with new inequality directions
- [ ] ROAD_MAP.md: Update sorry inventory to show 0 active-path sorries
- [ ] ROAD_MAP.md: Add dead ends for the reflexive approach (paths C, A attempted under plan v44)
- [ ] ROAD_MAP.md: Update X/Y operator status (now meaningful under strict semantics: X(phi) = bot U phi means "phi at strict future", not identity)
- [ ] ROAD_MAP.md: Note that Quasimodel has BX1/BX8 dependencies needing repair (non-critical, follow-up task)
- [ ] TemporalDerived.lean: Clean up any remaining sorry markers from Phase 1 deletions
- [ ] Add sorry markers to Quasimodel/ files that broke (F_of_mem, refl_intro_until_mcs) with comments noting they are not on critical path
- [ ] Add sorry markers to Bundle/ BX1 sites with similar comments

**Timing**: 2.5 hours

**Depends on**: 4

**Files to modify**:
- `specs/ROAD_MAP.md` -- comprehensive update reflecting irreflexive semantics
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- sorry markers
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- sorry markers
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` -- sorry markers (if not already archived)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- sorry markers
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- sorry markers

**Verification**:
- `lake build` succeeds (all non-critical breakage has sorry markers)
- ROAD_MAP.md accurately reflects the new semantic regime
- Sorry inventory: 0 on active completeness path, N on non-critical modules (documented)

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase (with expected breakage in later-phase files)
- [ ] After Phase 4: zero sorries on the active completeness path (RootScopedChain.lean)
- [ ] After Phase 4: `lean_verify dd_countermodel` -- no sorry dependency
- [ ] After Phase 4: `lean_verify bx_completeness` -- only propext, Classical.choice, Quot.sound
- [ ] After Phase 5: `lake build` succeeds globally (non-critical modules have explicit sorry markers)
- [ ] BX9 (until_elim) and BX9' (since_elim) remain valid under the new semantics (A2 guard includes current point)
- [ ] serial_future and serial_past are sound on the frame class (linear temporal orders on integers/rationals/reals)

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/48_bxcanonical-embedding.md` -- this plan
- `specs/ROAD_MAP.md` -- updated with irreflexive semantics strategy
- `Theories/Bimodal/Semantics/Truth.lean` -- irreflexive A2 semantics
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- updated axiom set (35 axioms)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- updated soundness proofs
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- sorry-free coherence proofs

## Rollback/Contingency

1. **Phase 1 rollback**: `git checkout -- Theories/Bimodal/Semantics/Truth.lean Theories/Bimodal/ProofSystem/Axioms.lean Theories/Bimodal/Metalogic/Soundness.lean Theories/Bimodal/Theorems/TemporalDerived.lean` restores reflexive semantics.

2. **Phase 2 rollback**: Revert Frame.lean and CanonicalModel.lean. These changes are localized.

3. **Phase 3 rollback**: Revert RootScopedChain.lean. The chain redesign is the most structurally invasive change; if it proves unworkable, the entire file can be reverted.

4. **Phase 4 contingency (sorry #1 fails)**: If finite defect induction does not close sorry #1, build IRR infrastructure as fallback. This adds ~150 LOC: an IRR constructor to ExtDerivationTree, IRR soundness proof (for any world w, set p := {w}, H_strict(neg p) holds at w), and temporal induction argument. Estimated additional effort: 2-3 hours.

5. **Complete rollback**: All phases can be reverted by checking out the branch at the pre-implementation commit. The plan preserves the existing reflexive codebase until each phase is verified.
