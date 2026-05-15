# Implementation Plan: Complete table_correctness Temporal Operator Cases

- **Task**: 148 - table_correctness_temporal_cases
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: Task 147 (lift_eval_insertenv_lemmas -- COMPLETED), Task 145 (MonadicFO split -- COMPLETED)
- **Research Inputs**: reports/01_scope-analysis.md, reports/02_proof-development.md
- **Artifacts**: plans/02_proof-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 6 remaining sorry positions in Table.lean (2 helper lemmas + 4 temporal operator cases of `table_correctness`) and update Transfer.lean pipeline documentation. All 6 proof scripts have been fully validated via `lean_multi_attempt` in the research phase, so implementation is primarily mechanical insertion. After completion, `table_correctness` will be sorry-free, unblocking step 5 of the Reynolds pipeline.

### Research Integration

Two research reports were produced:
- **01_scope-analysis.md**: Identified the 6 sorry positions, proof strategies, and dependency chain from MonadicFO.lean through helper lemmas to temporal cases.
- **02_proof-development.md**: Developed and validated complete proof scripts for all 6 sorry positions. Each script was tested via `lean_multi_attempt` returning empty goals with zero diagnostics. Also confirmed that the `chronicle_is_good` atomMap signature in Transfer.lean is correct (no mismatch).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the Reynolds pipeline discrete completeness branch:
- Closes step 5 ("Transfer truth via table_correctness") from PARTIAL to READY
- Reduces the sorry count on the critical path to `bx_completeness`
- Unblocks future work on Transfer.lean pipeline activation (steps 3 and 6 remain as blockers)

## Goals & Non-Goals

**Goals**:
- Prove `cons_eq_insertEnv_one` and `cons3_eq_insertEnv` helper lemmas (removing 2 sorries)
- Close all 4 temporal cases of `table_correctness`: all_future, all_past, untl, snce (removing 4 sorries)
- Update Table.lean module docstring to reflect sorry-free status
- Update Transfer.lean pipeline status table and description paragraph
- Achieve clean `lake build` with zero new sorries in Table.lean

**Non-Goals**:
- Proving other sorry positions in Transfer.lean (steps 3 and 6 are separate tasks)
- Modifying any code outside Table.lean and Transfer.lean
- Changing the `chronicle_is_good` signature (confirmed correct by research)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Validated proof scripts fail when inserted into actual file | H | Very Low | All 6 scripts validated via lean_multi_attempt with empty goals; fall back to lean_goal + manual tactic adjustment |
| Fin.cons/insertEnv simp lemma conflicts | M | Very Low | Proofs use explicit Fin.cases decomposition, not fragile simp chains |
| Lake build reveals transitive issues | M | Very Low | MonadicFO.lean lift_eval is fully proved (task 147 completed); run full build to catch any regression |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Prove Helper Lemmas and Temporal Cases [NOT STARTED]

**Goal**: Replace all 6 sorry positions in Table.lean with validated proofs and update the module docstring.

**Tasks**:
- [ ] Replace `sorry` at line 227 with proof for `cons_eq_insertEnv_one`: `funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]`
- [ ] Replace `sorry` at line 241 with proof for `cons3_eq_insertEnv`: `funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv]); refine Fin.cases ?_ ?_ j <;> simp`
- [ ] Replace `sorry` at line 292 with proof for `all_future` case (Iff.intro + push_neg + lift1_eval + ih)
- [ ] Replace `sorry` at line 295 with proof for `all_past` case (symmetric to all_future)
- [ ] Replace `sorry` at line 298 with proof for `untl` case (Iff.intro + push_neg + lift1_eval + lift1_lift1_eval + ih)
- [ ] Replace `sorry` at line 301 with proof for `snce` case (symmetric to untl)
- [ ] Update Table.lean module docstring (lines 19-20) to reflect sorry-free status
- [ ] Run `lean_verify` on `table_correctness` to confirm no `sorryAx` in axiom set

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` - Replace 6 sorries with validated proofs, update docstring

**Verification**:
- All 6 sorry positions replaced with proofs
- `lean_verify` on `Bimodal.Metalogic.WeakCanonical.table_correctness` returns no `sorryAx`

---

### Phase 2: Transfer.lean Cleanup and Full Build Verification [NOT STARTED]

**Goal**: Update Transfer.lean pipeline documentation to reflect table_correctness completion and verify the full project builds cleanly.

**Tasks**:
- [ ] Update Transfer.lean pipeline status table line 106: change step 5 from `PARTIAL (temporal cases need lift_eval)` to `READY (fully proved, no sorry)`
- [ ] Update Transfer.lean description paragraph (lines 110-111): change to `table_correctness is fully proved (all 8 cases, no sorry).`
- [ ] Update Transfer.lean step 5 comment (line 138): change `PARTIAL: temporal cases need lift_eval` to `READY`
- [ ] Run `lake build` to verify clean compilation with zero errors
- [ ] Verify no new sorries introduced (grep for sorry in Table.lean)

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Update pipeline status comments only (no code changes)

**Verification**:
- `lake build` completes with zero errors
- `grep -n "sorry" Table.lean` returns no matches (excluding comments if any)
- Pipeline status table shows step 5 as READY

## Testing & Validation

- [ ] `lean_verify` on `Bimodal.Metalogic.WeakCanonical.table_correctness` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No sorry remains in Table.lean proof terms (grep verification)
- [ ] Transfer.lean pipeline status correctly reflects step 5 as READY

## Artifacts & Outputs

- `specs/148_table_correctness_temporal_cases/plans/02_proof-plan.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (6 sorries removed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (status comments updated)

## Rollback/Contingency

All changes are additive (replacing sorry with proofs) or documentation-only (Transfer.lean comments). If any proof fails to type-check after insertion, revert the individual sorry replacement and investigate with `lean_goal` at the sorry position to compare actual vs expected goal state. Git revert of the commit restores the pre-implementation state cleanly.
