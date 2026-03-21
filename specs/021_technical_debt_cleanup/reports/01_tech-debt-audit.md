# Technical Debt Audit Report: Tasks 9-20

**Date**: 2026-03-21
**Scope**: All code produced by tasks 9-20 (metalogic refactoring track)
**Method**: Parallel 4-agent systematic audit of source files, summaries, and cross-cutting patterns

---

## Executive Summary

Tasks 9-20 implement a two-track metalogic refactoring: discrete completeness via Succ-chains (tasks 9-15) and dense completeness via DenseTask/Cantor (tasks 16-18). The code is **high quality overall** with clean architecture, but carries accumulated technical debt from rapid iteration — bridge files, unused helpers, exploratory code left behind, and compatibility layers that should be evaluated for removal.

**Overall Health**: 96 sorry statements project-wide (5 blocking task 18, 22 in Boneyard, rest in supporting/example code). 3 documented axioms (all justified). Zero build errors.

### Task Completion Status

| Task | Status | Debt Level |
|------|--------|------------|
| 9 | COMPLETED | None |
| 10 | COMPLETED | None |
| 11 | COMPLETED | Minor (2 redundant lemmas) |
| 12 | COMPLETED | Acceptable (3 justified axioms) |
| 13 | COMPLETED | Minor (1 low-impact sorry, 4 intentional compat wrappers) |
| 14 | COMPLETED | Moderate (2 dovetailing axioms for F/P witnesses) |
| 15 | COMPLETED | Significant (bridge file, structural sorries, deprecated code) |
| 16 | COMPLETED | None |
| 17 | COMPLETED | Minor (5 unused helper functions) |
| 18 | RESEARCHING | N/A (incomplete — 5 active sorries in partial work) |
| 19 | NOT STARTED | N/A (deprecation task — will reduce debt) |
| 20 | NOT STARTED | N/A (audit task — will assess parametric infrastructure) |

---

## Debt Category 1: Dead Code and Unused Abstractions

### 1.1 Redundant lemmas in CanonicalTaskRelation.lean (Task 11)

| Item | Location | Action |
|------|----------|--------|
| `iter_F_succ_eq` | CanonicalTaskRelation.lean:439 | Delete (duplicate of `iter_F_succ` at line 77) |
| `CanonicalTask_neg_succ_nat` | CanonicalTaskRelation.lean:183-187 | Delete (redundant with `CanonicalTask_negSucc`) |
| Unused `CanonicalTask_forward_MCS` accessors | CanonicalTaskRelation.lean:457-479 | Delete 3 of 4 (`start_mcs`, `end_mcs`, `to_forward` — only `step_inv` is used) |

### 1.2 Unused helpers in TimelineQuotBFMCS.lean (Task 17)

| Item | Location | Action |
|------|----------|--------|
| `witnessFMCS_forward_G_helper` | TimelineQuotBFMCS.lean:173-179 | Delete (exploratory, never called) |
| `witnessFMCS_backward_H_helper` | TimelineQuotBFMCS.lean:187-197 | Delete (exploratory, never called) |
| `buildTimelineQuotWitnessSeed` | TimelineQuotBFMCS.lean:113-134 | Delete (exploratory build function, never called) |
| `buildTimelineQuotWitnessSeed_preserves_boxcontent` | TimelineQuotBFMCS.lean:143-158 | Delete (supporting lemma for unused function) |
| `closedFlags_forward_F_witness` | TimelineQuotBFMCS.lean:418-424 | Delete (weaker wrapper, never called) |
| `closedFlags_backward_P_witness` | TimelineQuotBFMCS.lean:431-437 | Delete (weaker wrapper, never called) |
| Unused parameter in `closedFlags_mcs_in_canonical` | TimelineQuotBFMCS.lean:275 | Simplify (remove unused `h` parameter) |

### 1.3 Deprecated constructions in AlgebraicBaseCompleteness.lean (Task 15)

| Item | Location | Action |
|------|----------|--------|
| `singleFamilyBFMCS` | AlgebraicBaseCompleteness.lean:110 | Delete (blocked by impossible modal_backward — proven dead end) |
| `construct_bfmcs_from_mcs` | AlgebraicBaseCompleteness.lean:134 | Delete (superseded by v3 approach) |

### 1.4 Boneyard files from Task 15

| Item | Location | Status |
|------|----------|--------|
| `SuccChainBFMCS.lean` | Boneyard/Metalogic/Bundle/ | Already in Boneyard — singleton BFMCS proven impossible |
| `IntFMCSTransfer.lean` | Boneyard/Metalogic/Bundle/ | Already in Boneyard — depends on broken singleton approach |

**Assessment**: Boneyard isolation is correct. No action needed.

---

## Debt Category 2: Bridge and Compatibility Layers

### 2.1 ClosedFlagIntBFMCS.lean (Task 15) — MAJOR BRIDGE

**File**: `Theories/Bimodal/Metalogic/Bundle/ClosedFlagIntBFMCS.lean` (363+ lines, NEW/untracked)

This file bridges MCS-level modal saturation to Int-indexed BFMCS. It was created as structural scaffolding to restore `discrete_representation_unconditional`.

**Sorries in this file**:
| Line | Sorry | Nature |
|------|-------|--------|
| 135 | `closedFlagFMCS_modal_backward` | Family coverage requirement |
| 187 | `ClosedFlagBFMCS_Int.modal_forward` | Cross-family transfer |
| 267 | `rootClosedFlagFMCS_Int.mcs_in_closed` (t != 0) | Chain staying in closed set |
| 275-276 | Inherited F/P dovetailing gaps | From SuccChainFMCS axioms |

**Assessment**: This bridge was necessary to unblock task 15, but contains 5 structural sorries. Evaluate whether this bridge can be simplified or replaced once tasks 18-20 complete.

### 2.2 CanonicalRecovery.lean (Task 13) — INTENTIONAL COMPAT LAYER

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` (247 lines)

4 backward-compatibility wrappers re-exporting old API from new definitions:
- `canonical_forward_G_from_succ`
- `canonical_forward_G_from_task`
- `canonical_forward_F_with_canonicalR`
- `successor_from_seriality`

Plus 1 sorry at line 160 (`canonicalR_implies_canonicalTask_forward` — backward direction, genuinely harder).

**Assessment**: Evaluate whether downstream code has migrated to new API. If so, remove wrappers. The sorry is documented as low-impact (forward direction proven and sufficient for completeness).

### 2.3 DurationTransfer.lean deprecated wrappers (Task 16 dependency)

**File**: `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`

| Item | Location | Action |
|------|----------|--------|
| `canonicalTaskFrame` | DurationTransfer.lean:189-227 | Already marked `@[deprecated]` — W=D conflation |
| `discreteTaskFrame` | DurationTransfer.lean:242-246 | Mark deprecated (builds on deprecated `canonicalTaskFrame`) |
| `denseTaskFrame` | DurationTransfer.lean:255-259 | Mark deprecated (builds on deprecated `canonicalTaskFrame`) |

### 2.4 Soundness bridge sorries

**File**: `Theories/Bimodal/Metalogic/Soundness.lean` — 5 sorries in axiom routing (axiom_valid_dense, axiom_valid_discrete proofs)

**Assessment**: These are outside the task 9-20 scope but interact with the infrastructure. Note for future cleanup.

---

## Debt Category 3: Axioms and Dovetailing Gaps

### 3.1 Axioms introduced by tasks 9-15

| Axiom | File | Task | Justification |
|-------|------|------|---------------|
| `successor_deferral_seed_consistent_axiom` | SuccExistence.lean:266 | 12 | Semantic: Lindenbaum + frame properties |
| `predecessor_deferral_seed_consistent_axiom` | SuccExistence.lean:311 | 12 | Semantic: symmetric to successor |
| `predecessor_f_step_axiom` | SuccExistence.lean:516 | 12 | Semantic: frame condition justified |
| `F_top_propagates` | SuccChainFMCS.lean:150 | 14 | Semantic: frame condition |
| `P_top_propagates` | SuccChainFMCS.lean:206 | 14 | Semantic: frame condition |
| `succ_chain_forward_F_axiom` | SuccChainFMCS.lean:417 | 14 | **DOVETAILING GAP** — F witness existence |
| `succ_chain_backward_P_axiom` | SuccChainFMCS.lean:427 | 14 | **DOVETAILING GAP** — P witness existence |

### 3.2 Pre-existing axioms (documented in state.json)

| Axiom | File | Status |
|-------|------|--------|
| `canonicalR_irreflexive_axiom` | CanonicalIrreflexivity.lean:1212 | Justified per task 991 |
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean:316 | Documented debt from task 979 (will be removed by task 19) |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean:284 | Justified per task 991 |

### 3.3 Dovetailing gap assessment

The `succ_chain_forward_F_axiom` and `succ_chain_backward_P_axiom` (task 14) represent a genuine infrastructure gap: Int-indexed chains may lack F/P witnesses that exist in CanonicalMCS. These are **not logical gaps** but require a full dovetailing chain construction to eliminate. This is the most significant technical debt from the task 9-15 track.

---

## Debt Category 4: Sorry Inventory (Tasks 9-20 Scope)

### 4.1 Sorry-free files (Tasks 9-12, 16-17)

| File | Task | Lines | Sorries | Axioms |
|------|------|-------|---------|--------|
| TemporalContent.lean | 9 | 175 | 0 | 0 |
| SuccRelation.lean | 10 | 271 | 0 | 0 |
| CanonicalTaskRelation.lean | 11 | 571 | 0 | 0 |
| SuccExistence.lean | 12 | 554 | 0 | 3 (justified) |
| DenseTaskRelation.lean | 16 | 236 | 0 | 0 |
| TimelineQuotBFMCS.lean | 17 | 513 | 0 | 0 |

### 4.2 Files with sorries (Tasks 13-15, 18)

| File | Task | Sorries | Nature |
|------|------|---------|--------|
| CanonicalRecovery.lean | 13 | 1 | Backward direction (low impact) |
| SuccChainFMCS.lean | 14 | 0 | But 2 dovetailing axioms |
| ClosedFlagIntBFMCS.lean | 15 | 5 | Bridge infrastructure |
| AlgebraicBaseCompleteness.lean | 15 | 2 | Deprecated (dead code) |
| TimelineQuotCompleteness.lean | 18 | 1 | Blocking dense completion |
| ClosureSaturation.lean | 18 | 4 | Blocking dense completion |

### 4.3 Project-wide sorry distribution (context)

| Category | Count | Notes |
|----------|-------|-------|
| Boneyard | 22 | Off main path, non-blocking |
| Examples | ~10 | Educational, non-blocking |
| Task 18 active | 5 | Blocking dense completeness |
| Task 15 bridge | 5 | ClosedFlagIntBFMCS structural |
| Infrastructure | ~12 | CanonicalEmbedding, CanonicalQuot, IntBFMCS, MultiFamilyBFMCS |
| FMP/Decidability | 2 | Auxiliary feature |
| Other | ~40 | Various supporting code |
| **Total** | **~96** | |
| **Publication path** | **0** | Per state.json |

---

## Debt Category 5: Files Awaiting Deprecation (Task 19 Scope)

Task 19 is explicitly designed to deprecate the old discrete pipeline. Files to address:

| File | References | Action |
|------|------------|--------|
| `DiscreteTimeline.lean` | 127+ | Mark deprecated, migrate imports |
| `DiscreteTimelineElem` type | ~116 | Evaluate usage, migrate |
| `DiscreteTimelineQuot` type | ~116 | Evaluate usage, migrate |
| `orderIsoIntOfLinearSuccPredArch` pathway | Unknown | Superseded by CanonicalTask |
| `DiscreteSuccSeed.lean` | — | Contains axioms superseded by task 12 |

**Active imports of DiscreteTimeline.lean**:
- `Algebraic/IntBFMCS.lean`
- `Bundle/SuccChainFMCS.lean`
- `StagedConstruction/DiscreteSuccSeed.lean`
- 5+ additional files in staged construction

---

## Debt Category 6: Parametric Infrastructure Assessment (Task 20 Scope)

The parametric infrastructure (4 files, 1191 LOC total) is **sorry-free and well-designed**:

| File | Lines | Sorries |
|------|-------|---------|
| ParametricCanonical.lean | 245 | 0 |
| ParametricHistory.lean | 181 | 0 |
| ParametricRepresentation.lean | 303 | 0 |
| ParametricTruthLemma.lean | 462 | 0 |

**No redundancy** with task-specific infrastructure — parametric is the base layer, task-specific (CanonicalTask/DenseTask) provides instantiations. The question for task 20 is whether to refactor `parametric_canonical_task_rel` to accept a generic `task_rel` parameter, enabling both CanonicalTask and DenseTask as direct instantiations.

---

## Cleanup Action Plan

### Phase 1: Dead Code Removal (estimated 1 hour)
1. Delete redundant lemmas in CanonicalTaskRelation.lean (3 items)
2. Delete unused helpers in TimelineQuotBFMCS.lean (6 items + 1 parameter simplification)
3. Delete deprecated dead-end code in AlgebraicBaseCompleteness.lean (2 items)

### Phase 2: Deprecation Marking (estimated 30 min)
1. Mark `discreteTaskFrame` and `denseTaskFrame` as deprecated in DurationTransfer.lean
2. Evaluate CanonicalRecovery.lean compat wrappers for removal

### Phase 3: Bridge Assessment (estimated 1-2 hours)
1. Evaluate ClosedFlagIntBFMCS.lean — can it be simplified?
2. Assess whether CanonicalRecovery.lean wrappers are still used downstream
3. Document dovetailing gap resolution path

### Phase 4: Deferred (after tasks 18-20 complete)
1. Task 19 will handle DiscreteTimeline.lean deprecation
2. Task 20 will handle parametric infrastructure refactoring decision
3. Task 18 completion will resolve 5 active sorries
4. Dovetailing axiom elimination requires separate infrastructure work

---

## Incomplete Tasks: Future Findings Placeholder

The following tasks are **not yet completed** and may introduce additional technical debt or resolve existing debt upon completion:

### Task 18: Dense Representation Theorem Completion
- **Status**: RESEARCHING
- **Current debt**: 5 active sorries in ClosureSaturation.lean and TimelineQuotCompleteness.lean
- **Expected outcome**: Will wire dense completeness theorem, potentially resolving some infrastructure sorries
- **Risk**: May introduce additional bridge code similar to task 15's ClosedFlagIntBFMCS

### Task 19: Deprecate Old Discrete Pipeline
- **Status**: NOT STARTED (ready — task 15 dependency met)
- **Expected outcome**: Will REMOVE debt by deprecating DiscreteTimeline.lean and related files
- **Expected reduction**: ~127 references to old pipeline migrated or removed

### Task 20: Audit Parametric Canonical Infrastructure
- **Status**: NOT STARTED (partially ready — task 18 needed)
- **Expected outcome**: Design decision on parametric refactoring
- **Risk**: May identify additional refactoring needs in 4-file parametric module

**Action**: Re-run this audit after tasks 18-20 complete to capture final state.
