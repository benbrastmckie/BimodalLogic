# Implementation Plan: Task #93

- **Task**: 93 - Complete BXCanonical embedding (seriality + Nontrivial fix)
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: reports/51_team-research.md
- **Artifacts**: plans/51_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This revised plan (v51) addresses the remaining sorry sites in Soundness.lean and SoundnessLemmas.lean by adding `[Nontrivial D]` to the `valid` and `semantic_consequence` definitions, then closing the serial axiom proofs with `exists_gt`/`exists_lt`. It also fixes OracleStep.lean build failures caused by references to deleted axiom constructors. Definition of done: all 6 serial sorry sites closed, OracleStep.lean compiles, `lake build` passes with no new sorries.

### Research Integration

- Report 51 (team research, 4 teammates): Unanimous conclusion that `[Nontrivial D]` is the correct fix. In `LinearOrderedAddCommGroup D`, `Nontrivial D` implies `NoMaxOrder D` and `NoMinOrder D` (Mathlib). The proofs then close trivially with `exists_gt`/`exists_lt`. Cascade analysis identified 6 total sorry sites closeable from this single structural change: 2 in Soundness.lean + 4 in SoundnessLemmas.lean.
- OracleStep.lean references deleted `Axiom.temp_t_future`/`Axiom.temp_t_past` constructors causing build failures.
- Serial axioms BX1/BX1' must NOT be removed (used in g_content_set_consistent for completeness).

### Prior Plan Reference

Plan v50 (5 phases, 10 hours) addressed a different scope: guard convention switch, BX8 removal, BX2 reformulation. Phases 1-5 all marked [COMPLETED] in that plan. Key lessons: (1) The seriality sorry sites were noted but not the primary focus; (2) Adding typeclass constraints to validity definitions is mechanical but cascading; (3) OracleStep.lean was identified as having build failures from removed constructors.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `[Nontrivial D]` to `valid` and `semantic_consequence` definitions in Validity.lean
- Close `serial_future_axiom_valid` and `serial_past_axiom_valid` in Soundness.lean
- Close 4 serial sorry sites in SoundnessLemmas.lean (lines 529-536, 1022-1029, 1424-1431, 1655-1659)
- Update `dd_countermodel` return type to include `Nontrivial D`
- Fix OracleStep.lean build failures from references to deleted axiom constructors
- Achieve `lake build` clean with no new sorries introduced

**Non-Goals**:
- Closing g_content_subset_self / chain construction sorries (hard open problem, orthogonal)
- Removing BX1/BX1' seriality axioms (needed for completeness)
- Adding `G(phi)->phi` axiom (would require reflexive semantics switch)
- Dense completeness (task 68)
- until_backward_refl_mcs (genuinely unprovable under irreflexive Until)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Adding Nontrivial cascades to many theorem signatures | M | M (40%) | Research identified exact cascade: valid, semantic_consequence, dd_countermodel, soundness. All mechanical. |
| exists_gt/exists_lt require specific import or instance | L | L (20%) | These are standard Mathlib lemmas available in LinearOrderedAddCommGroup context. Verify with lean_hover_info. |
| OracleStep.lean may have deeper issues beyond deleted constructors | M | L (25%) | If file is on dead Quasimodel path, replace sorry sites rather than full repair. Minimum goal: compilation. |
| SoundnessLemmas.lean sorry sites may have different structure than expected | M | L (20%) | Team research identified exact line numbers. Verify goal state with lean_goal before attempting proof. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |

Phases 2 and 3 are independent of each other (both depend on Phase 1 for the updated definitions).

---

### Phase 1: Add [Nontrivial D] to Validity Definitions [NOT STARTED]

**Goal**: Add the `[Nontrivial D]` typeclass constraint to `valid`, `semantic_consequence`, and `dd_countermodel` in Validity.lean. Update all downstream signatures that reference these definitions.

**Tasks**:
- [ ] Validity.lean: Add `[Nontrivial D]` parameter to `valid` definition
- [ ] Validity.lean: Add `[Nontrivial D]` parameter to `semantic_consequence` definition
- [ ] Validity.lean: Update `dd_countermodel` return type to include `Nontrivial D` in its existential
- [ ] Soundness.lean: Update `soundness` theorem signature to include `[Nontrivial D]`
- [ ] Run `lake build` and fix all cascading type errors from the added constraint
- [ ] Verify no existing sorry-free proofs break (all use Int/Rat/Real which are nontrivial)

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Validity.lean` -- Add Nontrivial constraint to 3 definitions
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Update soundness signature
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- Update any helper signatures
- Any file referencing `valid` or `semantic_consequence` -- cascading signature updates

**Verification**:
- `lake build` passes (existing sorries still present but no new errors)
- `grep -r "Nontrivial" Theories/Bimodal/Metalogic/Validity.lean` shows the constraint

---

### Phase 2: Close Serial Axiom Sorry Sites [NOT STARTED]

**Goal**: Close all 6 serial axiom sorry sites using `exists_gt`/`exists_lt` now that `Nontrivial D` provides `NoMaxOrder D` and `NoMinOrder D`.

**Tasks**:
- [ ] Soundness.lean: Close `serial_future_axiom_valid` using `exists_gt` (NoMaxOrder gives strict successor)
- [ ] Soundness.lean: Close `serial_past_axiom_valid` using `exists_lt` (NoMinOrder gives strict predecessor)
- [ ] SoundnessLemmas.lean line 529-536: Close serial sorry site (likely future direction)
- [ ] SoundnessLemmas.lean line 1022-1029: Close serial sorry site
- [ ] SoundnessLemmas.lean line 1424-1431: Close serial sorry site
- [ ] SoundnessLemmas.lean line 1655-1659: Close serial sorry site (likely past direction)
- [ ] Verify with `lean_goal` that each proof state matches expected structure before attempting closure
- [ ] Run `lake build` and confirm zero sorry sites in serial axiom proofs

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Close 2 sorry sites (~10 LOC each)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- Close 4 sorry sites (~10 LOC each)

**Verification**:
- No `sorry` in `serial_future_axiom_valid` or `serial_past_axiom_valid`
- No `sorry` at the 4 identified SoundnessLemmas.lean locations
- `lake build` passes

---

### Phase 3: Fix OracleStep.lean Build Failures [NOT STARTED]

**Goal**: Fix compilation errors in OracleStep.lean caused by references to deleted `Axiom.temp_t_future` and `Axiom.temp_t_past` constructors.

**Tasks**:
- [ ] Read OracleStep.lean lines 76 and 141 to understand the context of the references
- [ ] Determine if OracleStep.lean is on the active proof path or the dead Quasimodel path
- [ ] If active path: Replace references with appropriate current axiom constructors or proof terms
- [ ] If dead path: Replace with `sorry` and add comment noting these are on deprecated path
- [ ] Run `lake build` and confirm OracleStep.lean compiles without errors

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/OracleStep.lean` -- Fix 2 constructor references

**Verification**:
- OracleStep.lean compiles without `Unknown constant` errors
- `lake build` passes
- No new sorry sites on active proof paths

---

## Testing & Validation

- [ ] After Phase 1: `lake build` passes with Nontrivial constraint added
- [ ] After Phase 2: Zero sorry sites in serial axiom proofs across Soundness.lean and SoundnessLemmas.lean
- [ ] After Phase 3: OracleStep.lean compiles without errors
- [ ] Full: `lake build` succeeds with no new sorry sites beyond pre-existing chain construction sorries

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/51_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/Validity.lean` -- updated with Nontrivial constraint
- `Theories/Bimodal/Metalogic/Soundness.lean` -- serial sorry sites closed
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- 4 serial sorry sites closed
- `Theories/Bimodal/Metalogic/BXCanonical/OracleStep.lean` -- build failures fixed

## Rollback/Contingency

1. **Phase 1 rollback**: `git checkout -- Theories/Bimodal/Metalogic/Validity.lean` plus any cascading files. The Nontrivial addition is additive and should not break existing proofs, but if it does, revert is straightforward.

2. **Phase 2 contingency**: If `exists_gt`/`exists_lt` are not directly applicable (wrong goal shape), use `lean_state_search` to find the correct closing lemma. The mathematical argument is sound -- only the Lean API surface may differ.

3. **Phase 3 contingency**: If OracleStep.lean has deeper issues beyond the two deleted constructors, replace the entire file content with sorry-stubbed versions of its exports. This file is likely on the deprecated Quasimodel path.

4. **Complete rollback**: All changes are on `irr_until` branch. Can reset to pre-implementation commit at any time.
