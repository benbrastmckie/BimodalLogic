# Implementation Plan: De Bruijn Substitution Lemmas

- **Task**: 147 - lift_eval_insertenv_lemmas
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None (all definitions already in place from task 140)
- **Research Inputs**: specs/147_lift_eval_insertenv_lemmas/reports/02_debruijn-research.md, specs/147_lift_eval_insertenv_lemmas/reports/01_scope-analysis.md
- **Artifacts**: plans/01_debruijn-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the 4 sorry markers in `NEquivalence.lean` (lines 292-317) with validated proofs for the De Bruijn substitution lemmas: `insertEnv_zero_eq_cons`, `insertEnv_succ_cons`, `insertEnv_finLift`, and `lift_eval`. All 4 proofs have been fully developed and validated via `lean_multi_attempt` during research. Once proved, `weaken_eval` (line 327-332) becomes sorry-free automatically since its body already references `insertEnv_zero_eq_cons` and `lift_eval`.

### Research Integration

Two research reports inform this plan:
- **02_debruijn-research.md**: Complete validated proof scripts for all 4 lemmas, tested via `lean_multi_attempt`. Includes detailed Mathlib dependency analysis (`Fin.cons_zero`, `Fin.cons_succ`, `Fin.succ_inj`, `Fin.val_succ`, `Fin.ext_iff`) and technical notes on dependent type issues with `Fin.cons`.
- **01_scope-analysis.md**: Scope analysis confirming these lemmas were left sorry by task 140, identifying the dependency graph and downstream impact.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the Reynolds pipeline (discrete completeness branch). The ROADMAP identifies 5 sorries across tasks 139 and 140 as critical path items. While these 4 sorries are in NEquivalence.lean (task 140's infrastructure), resolving them unblocks `weaken_eval` and the downstream `lift1_eval`/`lift1_lift1_eval` in Table.lean, which are prerequisites for the temporal cases of `table_correctness`.

## Goals & Non-Goals

**Goals**:
- Prove all 4 De Bruijn substitution lemmas (`insertEnv_zero_eq_cons`, `insertEnv_succ_cons`, `insertEnv_finLift`, `lift_eval`)
- Make `weaken_eval` sorry-free (automatic once the 4 lemmas are proved)
- Verify via `lake build` that no new sorries or errors are introduced

**Non-Goals**:
- Proving the remaining sorries in NEquivalence.lean (lines 453, 488, 491, 537 -- belong to task 139)
- Proving `lift1_eval` or `lift1_lift1_eval` in Table.lean (downstream of this task)
- Proving `table_correctness` temporal cases (task 148 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Validated proof scripts do not compile in full file context | M | L | Proofs tested via lean_multi_attempt in research; use lean_goal to debug any position-sensitive issues |
| Fin.cons dependent type motive issues block rw/simp | M | L | Research identified convert @Fin.cons_succ workaround; follow validated proof exactly |
| insertEnv_succ_cons split_ifs produces unexpected branches | L | L | Research documented all 9 branches with resolution strategies |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Prove the Three Helper Lemmas [COMPLETED]

**Goal**: Replace sorry in `insertEnv_zero_eq_cons`, `insertEnv_succ_cons`, and `insertEnv_finLift` with validated proofs.

**Tasks**:
- [x] Replace sorry at line 294 with `insertEnv_zero_eq_cons` proof: `funext i; cases i using Fin.cases` with simp on insertEnv/Fin.cons_zero/Fin.cons_succ
- [x] Replace sorry at line 304 with `insertEnv_succ_cons` proof: `funext i; cases i using Fin.cases` with dif_pos for zero case, simp + split_ifs + contradiction handling for succ case, convert @Fin.cons_succ for final branch
- [x] Replace sorry at line 310 with `insertEnv_finLift` proof: `simp only [finLift]; by_cases hlt : i.val < c.val` with dif_pos/dif_neg resolution *(deviation: altered -- added `congr 1; omega` to close final congruence goal not covered by validated proof script)*
- [x] Verify each lemma with `lean_goal` after insertion to confirm no remaining goals

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Replace sorry at lines 294, 304, 310

**Verification**:
- `lean_goal` shows no goals at end of each proof
- No diagnostic errors in NEquivalence.lean for these lemma definitions

---

### Phase 2: Prove lift_eval and Validate [COMPLETED]

**Goal**: Replace sorry in `lift_eval` with the structural induction proof and verify the entire file builds clean.

**Tasks**:
- [x] Replace sorry at line 317 with `lift_eval` proof: structural induction on alpha with atom/lt using insertEnv_finLift, not/and using IH, all/ex using insertEnv_succ_cons + simp_rw
- [x] Verify `lean_goal` shows no goals at end of `lift_eval`
- [x] Verify `weaken_eval` (line 327-332) no longer has sorry transitively
- [x] Run `lake build` to confirm NEquivalence.lean compiles without errors
- [x] Verify sorry count in NEquivalence.lean decreased by exactly 4 (from 8 to 4)

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Replace sorry at line 317

**Verification**:
- `lake build` succeeds (or only pre-existing errors remain)
- `grep -c sorry NEquivalence.lean` shows reduction from 8 to 4
- `weaken_eval` compiles without sorry

## Testing & Validation

- [ ] All 4 sorry markers at lines 294, 304, 310, 317 replaced with complete proofs
- [ ] `lean_goal` confirms no remaining goals at end of each proof
- [ ] `weaken_eval` type-checks without sorry (automatic since it references insertEnv_zero_eq_cons + lift_eval)
- [ ] `lake build` completes without new errors in NEquivalence.lean
- [ ] Sorry count in NEquivalence.lean drops from 8 to 4 (remaining 4 belong to task 139)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Updated with 4 proved lemmas
- `specs/147_lift_eval_insertenv_lemmas/plans/01_debruijn-plan.md` - This plan
- `specs/147_lift_eval_insertenv_lemmas/summaries/01_debruijn-summary.md` - Execution summary (created during implementation)

## Rollback/Contingency

All changes are in a single file (`NEquivalence.lean`). If any proof fails to compile in context despite research validation, restore the sorry markers and escalate. The file is under git version control; `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` reverts all changes.
