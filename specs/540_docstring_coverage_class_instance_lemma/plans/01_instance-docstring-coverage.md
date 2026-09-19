# Implementation Plan: Task #540

- **Task**: 540 - Docstring coverage for class, instance, and lemma declarations
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/540_docstring_coverage_class_instance_lemma/reports/01_docstring-coverage-gaps.md
- **Artifacts**: plans/01_instance-docstring-coverage.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true (documentation-only; no statement or proof changes)

## Overview

Research re-measured C19 on the current tree and found that the task description's numbers are stale.
- **class** is already at 21/21 = 100%.
- **lemma** has 0 declarations. C23 forbids live `lemma`, so this criterion is met vacuously and cannot regress.
- **instance** is the only category below the floor, at 59/79 = 74.7%.
- The refined aggregate is 93.78%, above the 92.34% no-regression bound.

The remaining work has two parts:
1. **Make the acceptance criterion observable.** C19 currently prints only aggregate lines. The fix adds per-keyword INFO lines, which is reporting only; the counting rule stays unchanged.
2. **Write real docstrings for all 20 undocumented instances** across 8 files. These follow the three-register convention: what the declaration is, in present tense, plus a caller trap where one exists.

### Research Integration

- The per-keyword table, the list of 20 undocumented instances, the draft docstrings, and C19's placement rule all come from the research report. That rule credits a `/--` comment only if its closing `-/` is on one of the 3 lines above the declaration line.
- The phase split follows the report's suggested phases.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided for this dispatch.

## Goals & Non-Goals

**Goals**:
- C19 prints a per-keyword refined coverage line, at least for class, instance and lemma. Each of the three reads at least 90%, or n/a for zero declarations.
- All 20 undocumented instances get register-(a) docstrings, bringing instance coverage to 79/79.
- The refined aggregate does not regress. The expected value is 10178/10832 = 93.96%.
- C19's stale header-comment figures are refreshed.

**Non-Goals**:
- Any change to C19's counting rule: the declaration regex, the comment stripper, the doc-end window, `/-!` section credit, or the floor. Also no promotion of C19 to enforcing.
- The theorem category (91.0%, 629 undocumented). It is above the floor and not named in the task.
- Making any instance `private`. Instance resolution consumes all 20.
- Any proof or statement change.
- Editing LEAN_STYLE_GUIDE.md. The research's context-extension note is left for a separate task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The per-keyword edit perturbs C19's per-declaration verdicts or aggregate | H | L | Capture both C19 aggregate lines before the edit and diff them after. They must be byte-identical. |
| A docstring is not credited: outside the 3-line window, blocked by the plain comment at the `instPredOrder` site, or one docstring shared by the adjacent one-liners in LimitMCS.lean | M | M | Give each instance its own docstring directly above it. Move the existing plain `/- -/` rationale above the new `/--`. Confirm with the new per-keyword line. |
| New undocumented instances appear between research and implementation | L | L | Re-derive the undocumented list at implementation time using the instrumented C19 heredoc or the new per-keyword output. Do not trust the report's line numbers. |
| Draft docstring wording is inaccurate (the `atomKindDecEq` body was not fully read) | M | M | Read each instance body before committing its docstring, and reword the drafts freely. |
| A malformed `/--` breaks elaboration | M | L | Build each touched module in-phase. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can run in parallel. Phases 1-3 touch disjoint files: the script, the Decidability files, and the remaining Lean files.

### Phase 1: C19 per-keyword reporting and header refresh [COMPLETED]

**Goal**: Make per-keyword refined coverage observable in C19 output without changing any per-declaration verdict.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and save C19's two aggregate lines, unrefined and refined, as the baseline.
- [x] In C19's Python heredoc (around `scripts/check-module-invariants.sh:3028-3175`), keep a per-keyword tally of refined documented/total alongside the existing counters. The tally is keyed on the keyword the existing declaration regex already captures. Do not touch `decl_lines`, `doc_ends`, `section_end_lines`, or the `active` scope walk.
- [x] After the two existing aggregate lines, print one INFO line per keyword, at least for class, instance and lemma, and preferably for all keywords, in a stable order. Example: `INFO  C19  per-keyword (refined): instance 79/79 = 100.00%`. A zero-total keyword prints `n/a (0 declarations; C23 forbids lemma)` and never divides by zero.
- [x] Keep the change reporting-only: no `FAILURES` increment and no `ENFORCE_` flag.
- [x] Refresh C19's header comment. Replace the stale figures (10427 total, 89.37%/92.32%, and class 16.3% / instance 57.6% / lemma 55.6%) with a pointer to the new per-keyword output, or with current values labeled with their measurement date. Leave the counting-rule description untouched.
- [x] Re-run the check and diff the two aggregate lines against the baseline. They must be identical. *(deviation: altered — a concurrent task added a file mid-phase, so the full-script baseline drifted; identity was instead verified by running the HEAD and edited C19 heredocs on the same tree snapshot: aggregate lines byte-identical, 10202/10876)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Only the C19 block and its header comment in `scripts/check-module-invariants.sh` change. Confirm with `git diff --stat` that this is the only file touched and that the diff hunks lie in the C19 region.

**Files to modify**:
- `scripts/check-module-invariants.sh` - per-keyword INFO lines in the C19 heredoc and a refreshed header comment

**Verification**:
- The C19 aggregate lines are byte-identical before and after.
- Per-keyword lines print. Expected pre-docstring values: class 21/21, instance 59/79, lemma n/a.
- C23 still PASSes, and the script exits with the same status as the baseline.

---

### Phase 2: Decidability instance docstrings [COMPLETED]

**Goal**: Document the 8 undocumented decidability instances (research items 3-10).

**Tasks**:
- [x] Re-derive the undocumented instances in the target files. Line numbers may have drifted.
- [x] `FormalSystem/Metalogic/Decidability/BiLasso/Decide.lean`: add docstrings to `instDecidableClauseAt`, `instDecidableLocalCoherentAt`, `instDecidableUntlOblB`, `instDecidableSnceOblB`, `instDecidableEventClauseAt`, and `instDecidableFulfilAt`. The `...OblB` docstrings state the trap: decidability comes from the explicit finite witness range, and the unbounded obligations are not covered.
- [x] `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean`: add a docstring to `instDecidableIsLasso`.
- [x] `FormalSystem/Metalogic/Decidability/Verified/Bridge/BranchOrder.lean`: add a docstring to `instDecidableBranchLT`.
- [x] Read each body before finalizing its wording, starting from the research drafts. Each `/--` must end within 3 lines above its `instance` line; an attribute line in between is allowed.
- [x] Build the three modules with `lake build <Module>` through the repository's build path.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 8 undocumented instances across these 3 files. Confirm by re-running the instrumented C19 undocumented dump, or by checking that the Phase 1 per-keyword instance count rises by 8 after this phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Decide.lean` - 6 docstrings
- `FormalSystem/Metalogic/Decidability/BiLasso/Enumerate.lean` - 1 docstring
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/BranchOrder.lean` - 1 docstring

**Verification**:
- The three modules build clean, with no new warnings.
- `git diff` shows only added comment lines.

---

### Phase 3: WeakCanonical, Semantics and Bundle instance docstrings [COMPLETED]

**Goal**: Document the remaining 12 undocumented instances (research items 1-2 and 11-20).

**Tasks**:
- [x] Re-derive the undocumented instances in the target files.
- [x] `FormalSystem/Metalogic/Bundle/LimitMCS.lean`: give `limitFilterBelow_neBot` and `limitFilterAbove_neBot` a docstring each. The trap to state: the named filter does not syntactically match `limitFilter .below/.above r` for instance search.
- [x] `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean`: add docstrings to `instInStructureClassUnrestricted` and `instInStructureClassCountableDense`.
- [x] `FormalSystem/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`: add a docstring to `ZIntervalStructure.intervalCarrierLinearOrder`.
- [x] `FormalSystem/Metalogic/WeakCanonical/RealModel/GoodDense.lean`: add a docstring to `RIntervalStructure.intervalCarrierLinearOrder` that states why it is noncomputable (style guide rule).
- [x] `FormalSystem/Metalogic/WeakCanonical/NormalForm.lean`: add a docstring to `atomKindDecEq`, reading the full body first. Add docstrings to `normalFormFintype` and `normalFormDecEq`, stating the trap that the two are built jointly by induction and cannot be derived separately.
- [x] `FormalSystem/Semantics/LexCarrier.lean`: add docstrings to `instSuccOrder` and `instPredOrder`. For `instPredOrder`, move the existing plain `/- ... -/` rationale above the new `/--` so that the docstring is the nearest block.
- [x] `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean`: add a docstring to `tailFilter_neBot`.
- [x] Build the seven touched modules.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 12 undocumented instances across these 7 files. Confirm by re-running the instrumented undocumented dump, or by checking that the per-keyword instance count reaches 79/79 once Phases 2 and 3 are both done.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` - 2 docstrings
- `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean` - 2 docstrings
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` - 1 docstring
- `FormalSystem/Metalogic/WeakCanonical/RealModel/GoodDense.lean` - 1 docstring
- `FormalSystem/Metalogic/WeakCanonical/NormalForm.lean` - 3 docstrings
- `FormalSystem/Semantics/LexCarrier.lean` - 2 docstrings, plus the rationale comment moved
- `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` - 1 docstring

**Verification**:
- The seven modules build clean, with no new warnings.
- `git diff` shows only comment additions and the relocated comment.

---

### Phase 4: Final gate [COMPLETED]

**Goal**: Confirm the acceptance criteria against C19's own output and run the full gate.

**Tasks**:
- [x] Run `lake build` for the full default targets.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and record the C19 per-keyword and aggregate lines.
- [x] Confirm that class, instance and lemma each read at least 90% or n/a, that the refined aggregate is at least 92.34% (expected about 93.96%), and that C23 PASSes.
- [x] Confirm that no new `sorry` or `axiom` appears, and that the C19 counting-rule code shows no diff beyond the reporting additions.
- [x] *(deviation: altered — added step: the inserted docstrings shifted 34 live `NormalForm.lean:NNN`/`GoodDense.lean:NNN` citations (9 failed C20 tier 1); each was renumbered by its insertion offset and asserted to land on its pre-edit text; C20 now passes)*

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Files to modify**:
- None, verification only

**Verification**:
- `lake build` is green.
- The invariants script's C19 per-keyword lines meet the floor.
- The aggregate does not regress.

## Lean Challenge Statements

None. This plan commits to no theorem statements; it adds documentation only.

## Testing & Validation

- [x] C19 per-keyword refined results: class 21/21, instance at least 72/79 (target 79/79), lemma n/a (0 declarations).
- [x] The C19 refined aggregate is at least 92.34%, with an expected value of about 93.96%.
- [x] The C19 per-declaration logic is unchanged: the aggregate lines are identical before and after the Phase 1 edit.
- [x] C23 PASSes.
- [x] `lake build` is green.

## Artifacts & Outputs

- specs/540_docstring_coverage_class_instance_lemma/plans/01_instance-docstring-coverage.md
- Modified: `scripts/check-module-invariants.sh` and the 10 Lean files listed in Phases 2-3
- specs/540_docstring_coverage_class_instance_lemma/summaries/01_instance-docstring-coverage-summary.md

## Rollback/Contingency

- Every change is additive comment text or reporting-only script output, so any phase can be reverted per-file with `git revert` of its commit.
- If the Phase 1 aggregate lines differ from the baseline, revert the heredoc edit and re-apply only the tally and print additions.
