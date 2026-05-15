# Implementation Plan: Task #139 (Revised) -- Cleanup and Close-Out

- **Task**: 139 - Build FO satisfaction infrastructure for monadic structures
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: Task 129 (completed), Plan 01 phases 1,2,4,5 (completed)
- **Research Inputs**: specs/139_fo_satisfaction_monadic_structures/reports/03_teammate-a-necessity.md, specs/139_fo_satisfaction_monadic_structures/reports/03_teammate-b-solutions.md, specs/139_fo_satisfaction_monadic_structures/reports/03_teammate-c-cleanup.md
- **Artifacts**: plans/02_cleanup-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This revised plan covers the remaining work for Task 139 after phases 1, 2, 4, and 5 completed successfully. Phase 3 (proving `ktype_finite` and `finite_types`) was blocked because `ktype_finite` is mathematically impossible as stated -- the domain `{s : MonadicFormula sig 0 // s.quantifier_depth <= k}` is syntactically infinite due to unbounded not/and nesting. Round 2 research (8 agents) confirmed that `ktype_finite` is dead code (never consumed anywhere), that the entire Reynolds pipeline is bypassed by the chronicle fallback, and that the correct finiteness result (Doets Lemma 1.1 via finite normal forms) should be a separate task (143+). This plan performs cleanup of dead/misleading code, adds TODO documentation for deferred items, fixes a 1-line sorry on the bx_completeness critical path, and verifies the build.

### Research Integration

Key findings from three round-2 research reports integrated into this plan:

- **teammate-a (necessity analysis)**: `ktype_finite` is dead code and mathematically impossible. `finite_types` and `sum_preservation` in `KEquivalenceFramework` are never consumed -- the entire Reynolds pipeline is bypassed by the chronicle fallback in Transfer.lean. The sorry in `dd_countermodel_chronicle_discrete` propagates from the algebraic module (tasks 141/142), not from the Reynolds pipeline.
- **teammate-b (solution analysis)**: Verified 5 approaches in Lean. Recommended Approach 1 (redefine KType with finite normal form domain based on Doets n-characteristics). This is 6-9 hours of work and belongs in a separate task (143+), not in this cleanup.
- **teammate-c (cleanup audit)**: File-by-file audit identified: `ktype_finite` (dead), unused `VecNotation` import, orphaned `OrderedSum` def, orphaned `ZIntervalStructure.carrierSet` and `ZStructure.toZInterval`, misleading `finite_structures_k_equiv_to_Z_interval` (vacuous reflexivity proof), and `Formula.complexity` naming collision risk in Table.lean.

### Prior Plan Reference

Plan 01 (`01_fo-satisfaction-plan.md`) had 5 phases. Phases 1, 2, 4, 5 completed successfully, delivering: `MonadicFormula sig n` with De Bruijn variables, sorry-free `eval`, sorry-free `k_type_of`, sorry-free `k_equiv_monotone`, `table` signature updated to `MonadicFormula sig 1`, and all downstream files (IntegerModel, OrderedSum, Table, Transfer) compiling. Phase 3 was correctly identified as the highest-risk phase -- the rollback contingency in Plan 01 anticipated this exact failure mode ("If Fintype proof is intractable, fall back to sorry with documentation"). Effort calibration: cleanup work is much lighter than the original 2-hour Phase 3 estimate since we are deleting rather than proving.

### Roadmap Alignment

This plan advances the following ROADMAP.md items:
- Cleans up 3 NEquivalence.lean sorries listed in the sorry summary: `ktype_finite` (deleted as impossible/dead), `finite_types` and `sum_preservation` (documented with TODO referencing future Doets Lemma 1.1 task)
- Fixes the `existsTask_transitive` sorry in Bundle/CanonicalFrame.lean, which is consumed by `canonicalR_transitive` in ParametricCanonical.lean on the bx_completeness critical path
- Critical path: Task 129 (COMPLETED) -> **139 (this task)** -> 140 -> 141 -> 142 -> sorry-free `bx_completeness`

## Goals & Non-Goals

**Goals**:
- Delete `ktype_finite` (impossible, dead code) from NEquivalence.lean
- Add clear TODO documentation on `finite_types` and `sum_preservation` referencing the Doets Lemma 1.1 task scope
- Remove unused `Mathlib.Data.Fin.VecNotation` import
- Delete orphaned definitions: `OrderedSum` in NEquivalence.lean, `ZIntervalStructure.carrierSet` and `ZStructure.toZInterval` in IntegerModel.lean
- Archive `finite_structures_k_equiv_to_Z_interval` and `finite_structures_k_equiv_for_all_k` to Boneyard (misleading vacuous proofs)
- Rename `Formula.complexity` to `Formula.operator_depth` in Table.lean to avoid shadowing
- Fix `existsTask_transitive` sorry in Bundle/CanonicalFrame.lean (1-line: `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`)
- Verify `lake build` succeeds
- Document what was achieved and what is deferred

**Non-Goals**:
- Prove `ktype_finite` (impossible as stated; requires KType redefinition via Doets normal forms -- separate task 143+)
- Prove `finite_types` or `sum_preservation` (requires Doets Lemma 1.1 and EF-game formalization respectively)
- Activate the Reynolds pipeline in Transfer.lean (requires truth transfer -- Task 140)
- Clean up ChronicleExtraction.lean dead code (identified by audit but out of Task 139 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting `OrderedSum` breaks downstream code | M | L | Grep confirms zero callers; `doets_lemma_1_4` inlines the sigma-type directly |
| `Formula.complexity` rename breaks downstream | M | L | Only used within Table.lean; grep for all references before renaming |
| `existsTask_transitive` fix does not compile | L | L | The exact pattern `DerivationTree.axiom [] _ (Axiom.temp_4 phi)` is used at LinearityDerivedFacts.lean:78; verify with `lean_goal` before committing |
| Boneyard move of OrderedSum.lean items leaves the file too empty | L | M | Keep `doets_lemma_1_4` and `doets_lemma_1_5` which are genuine future proof targets; the file retains meaningful content |
| Removing `VecNotation` import causes build failure | L | L | `Fin.cons` is from `Mathlib.Data.Fin.Basic` not `VecNotation`; verify with `lake build` on the single module first |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Cleanup Dead and Misleading Code [COMPLETED]

**Goal**: Delete dead code (`ktype_finite`, orphaned definitions, misleading proofs) and fix naming issues. Add TODO documentation for deferred items.

**Tasks**:
- [x] **Task 1.1**: Delete `ktype_finite` definition from NEquivalence.lean *(completed in prior session)*
- [x] **Task 1.2**: Remove `import Mathlib.Data.Fin.VecNotation` from NEquivalence.lean *(completed in prior session)*
- [x] **Task 1.3**: Delete `def OrderedSum` from NEquivalence.lean *(completed in prior session)*
- [x] **Task 1.4**: Update TODO comments on `finite_types` and `sum_preservation` to reference Doets Lemma 1.1 scope *(completed in prior session)*
- [x] **Task 1.5**: Delete `ZIntervalStructure.carrierSet` from IntegerModel.lean *(completed in prior session)*
- [x] **Task 1.6**: Delete `ZStructure.toZInterval` from IntegerModel.lean *(completed in prior session)*
- [x] **Task 1.7**: Move vacuous proofs from OrderedSum.lean to Boneyard/VacuousKEquiv.lean *(completed in prior session)*
- [x] **Task 1.8**: Rename `Formula.complexity` to `operator_depth` in Table.lean *(completed in prior session; dot-notation fix applied this session)*
- [x] **Task 1.9**: Update `doets_lemma_1_5` docstring *(completed in prior session)*
- [x] **Task 1.10**: Verify `lake build` on WeakCanonical module *(completed — all modules build successfully)*
- [x] **Task 1.11**: Fix ReflexiveCanonical.lean build error *(deviation: added — removed ill-typed `exact` on line 205 that blocked downstream builds)*

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- delete `ktype_finite`, `OrderedSum`, remove `VecNotation` import, update TODO comments
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- delete `carrierSet`, `toZInterval`
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- archive/delete vacuous proofs, update docstring
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` -- rename `Formula.complexity` to `Formula.operator_depth`

**Verification**:
- `ktype_finite` no longer appears in NEquivalence.lean
- `Formula.operator_depth` compiles in Table.lean and `table_depth_bound` references it
- `lake build` succeeds on all modified modules
- Grep confirms no remaining references to deleted definitions

---

### Phase 2: Critical Path Fix -- existsTask_transitive [COMPLETED]

**Goal**: Fix the `existsTask_transitive` sorry in Bundle/CanonicalFrame.lean. This sorry blocks `canonicalR_transitive` which is consumed by `ParametricCanonical.lean` on the bx_completeness critical path.

**Tasks**:
- [x] **Task 2.1**: Replace sorry with `Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_4 phi)` *(deviation: altered — used fully qualified names since Bimodal.ProofSystem is not opened in this file)*
- [x] **Task 2.2**: Verify with `lean_goal` that the proof term has the correct type *(verified: goals_after is empty, no sorry in axiom list)*
- [x] **Task 2.3**: Run `lake build Bimodal.Metalogic.Bundle.CanonicalFrame` *(completed — builds successfully)*
- [x] **Task 2.4**: Run `lake build Bimodal.Metalogic.Algebraic.ParametricCanonical` *(completed — builds successfully)*

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` -- replace sorry at line 259

**Verification**:
- `existsTask_transitive` compiles without sorry
- `#check @existsTask_transitive` shows no `sorryAx` dependency
- `canonicalR_transitive` (the alias) also compiles clean
- `lake build` on CanonicalFrame and ParametricCanonical succeeds

---

### Phase 3: Final Verification and Documentation [COMPLETED]

**Goal**: Full project build verification, document what was achieved and what is deferred.

**Tasks**:
- [x] **Task 3.1**: Run `lake build` on the full project *(completed — 1644 jobs, zero errors)*
- [x] **Task 3.2**: Grep for remaining sorry in WeakCanonical *(completed — all sorries documented with TODO/task references)*
- [x] **Task 3.3**: Verify existsTask_transitive fix *(completed — lean_verify shows no sorryAx, CanonicalFrame.lean has zero sorries)*
- [x] **Task 3.4**: Update plan status markers *(completed — all three phases marked [COMPLETED])*

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `specs/139_fo_satisfaction_monadic_structures/plans/02_cleanup-plan.md` -- update phase statuses

**Verification**:
- `lake build` succeeds with zero errors on the full project
- Sorry count in WeakCanonical directory is documented and each sorry has a TODO referencing its owning task
- Plan file has all phases marked `[COMPLETED]`

---

## Testing & Validation

- [ ] `lake build` succeeds on the full project after all phases
- [ ] `ktype_finite` is deleted from NEquivalence.lean (not just sorry'd -- removed entirely)
- [ ] `finite_types` and `sum_preservation` have updated TODO comments referencing Doets Lemma 1.1 task
- [ ] `existsTask_transitive` in CanonicalFrame.lean is sorry-free
- [ ] `Formula.operator_depth` compiles in Table.lean (no shadowing of `Bimodal.Syntax.Formula.complexity`)
- [ ] No references to deleted definitions (`OrderedSum`, `ZIntervalStructure.carrierSet`, `ZStructure.toZInterval`, `finite_structures_k_equiv_to_Z_interval`) remain outside Boneyard
- [ ] Grep for `sorry` in modified files shows only documented/owned sorries

## Artifacts & Outputs

- `specs/139_fo_satisfaction_monadic_structures/plans/02_cleanup-plan.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (cleanup: delete dead code, update TODOs)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` (delete orphaned definitions)
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (archive vacuous proofs, update docstring)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (rename `complexity` to `operator_depth`)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (fix `existsTask_transitive` sorry)

## Rollback/Contingency

All changes are deletions, renames, and a 1-line fix. If any deletion causes unexpected breakage:
1. Restore the deleted definition from git: `git checkout -- <file>`
2. Re-run `lake build` to confirm restoration
3. Investigate the unexpected dependency before retrying

If the `existsTask_transitive` fix does not compile:
1. Check with `lean_goal` at the sorry position to confirm the expected goal type
2. Verify `Axiom.temp_4` produces the right formula shape
3. Check `DerivationTree.axiom` constructor signature with `lean_hover_info`

Git rollback: changes span `Theories/Bimodal/Metalogic/WeakCanonical/` and `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`. A `git stash` reverts everything.
