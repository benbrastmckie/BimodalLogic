# Implementation Plan: Task #600

- **Task**: 600 - Rename dense extension to QTime (investigate first)
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/600_rename_dense_extension_qtime/reports/01_dense-vs-qtime-naming.md
- **Artifacts**: plans/01_dense-naming-rationale.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Research settled the investigation half of this task: the rename is rejected. `FrameClass.ZTime`
and `FrameClass.RTime` carry carrier names because their semantic classes are categorical (exactly
ℤ-time and ℝ-time), while `Sat .Dense` = `DenselyOrdered F.Duration` is non-categorical (ℚ, ℝ,
ℚ ×ₗ ℚ, ...), cannot be narrowed to ℚ without breaking `Dense ≤ RTime` / `FrameClass.Sat.anti`,
and matches the paper's TM_d / BX_d vocabulary ("the dense task frames"). The work is therefore
the task's "otherwise" branch: record the rationale in the relevant docstrings, verify the build
and lints, and close without renaming. Definition of done: one canonical rationale paragraph on
the `FrameClass` docstring, short reciprocal pointers at `TaskFrame.IsDense` (and optionally the
`FrameClassValidity.lean` table notes and `docs/theorem-index.md` TM_d row), `lake build` green,
no identifier changed.

### Research Integration

Integrated report 01 in full: verdict (keep `Dense`), the four-point rationale (categoricity,
partial-order constraint, logic-equals-Th(ℚ-time) as a theorem not a definition, paper
vocabulary d/z/r), the recommended canonical site (`FrameClass` docstring in
`FormalSystem/ProofSystem/Axioms.lean`) plus reciprocal pointers, the precision caveat for the
Th(dense) = Th(ℚ-time) claim, and the coordination notes for the paper-vocabulary and
citation-disambiguation tasks. The optional machine-checked corollary
(`validDense_iff_validOverRat`) is explicitly not recommended and is a non-goal here.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- Add a "Why this class is named Dense and not QTime" paragraph to the FrameClass docstring in FormalSystem/ProofSystem/Axioms.lean (single canonical site for the argument).
- Add a short reciprocal pointer on the IsDense docstring in FormalSystem/Semantics/FrameProperty.lean, mirroring the existing IsRTime naming section.
- Optionally add one sentence to the FrameClassValidity.lean interpretation notes and the docs/theorem-index.md TM_d row ("The tree says Dense, not QTime"), parallel to the existing RTime row note.
- Keep lake build green and the task-reference lint clean.

**Non-Goals**:
- Renaming any identifier, constructor, file, or module (the rename is rejected on evidence).
- Adding a new theorem (e.g. a Th(dense) = Th(ℚ-time) corollary) -- cite existing declarations instead.
- Touching order-density identifiers (EpsilonDense, GoodDense, DenseModelSurgery, PriorExpressivenessDense, ...).
- Any proof, sorry, or axiom change.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Overstating "Th(dense) = Th(ℚ-time)" in prose | M | M | State it precisely: theorems of `Derivable .Dense []` coincide with validity over dense frames (soundness, `soundness_dense`) and the completeness engine `derivable_of_validDense` closes via `countermodel_dense_enriched`, whose countermodel lives over `Rat`. Confirm each cited name with `lean_local_search` before writing it. |
| Docstring insertion shifts `Axioms.lean:NNN` line citations elsewhere | L | H | Cite declaration names, not line numbers, in new prose; the in-flight basename/line-citation task re-measures at its own time. |
| Duplicating the argument at several sites (drift) | L | M | Full argument only on `FrameClass`; other sites get one-to-two-sentence pointers naming `FrameClass`'s docstring. |
| Task-number reference slipping into a docstring | M | L | No "task N" text in deliverables; run `check-task-references.sh` on changed files. |
| Docstring edit accidentally breaks a `/-- ... -/` block (unterminated comment, stray backtick in code) | M | L | Build the touched modules; diff read-through confirms every hunk is inside a comment. |
| Collision with in-flight paper-vocabulary reconciliation work | L | L | Keeping `Dense` matches the paper's TM_d, so no conflict; mention in the summary so that work does not re-raise the question. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Record naming rationale in docstrings [NOT STARTED]

**Goal**: Write the canonical "why Dense, not QTime" rationale and its reciprocal pointers.

**Tasks**:
- [ ] Confirm cited declaration names exist and are spelled correctly (`FrameClass.Sat.anti` or the actual monotonicity lemma name, `soundness_dense`, `derivable_of_validDense`, `countermodel_dense_enriched`, `Semantics.complete_duration_discrete_or_dense`, `TaskFrame.isDense_of_isRTime`) via `lean_local_search` / grep.
- [ ] In `FormalSystem/ProofSystem/Axioms.lean`, add to the `FrameClass` docstring (after the "Why `RTime` sits strictly above `Dense`" paragraph) a paragraph "**Why this class is named `Dense` and not `QTime`.**" covering: (a) ZTime/RTime are carrier-named because their classes are categorical; (b) the dense class is not categorical (ℚ, ℝ, ℚ ×ₗ ℚ) and cannot be narrowed to ℚ since `Dense ≤ RTime` requires ℝ-frames in `Sat .Dense`; (c) its logic nevertheless equals ℚ-time's, because soundness holds over every dense frame and the completeness countermodel is built over `Rat` -- a theorem about the class, not its definition; (d) the name tracks the paper's TM_d / BX_d and `def:frame-properties`' Dense clause, so Dense/ZTime/RTime mirrors the paper's d/z/r subscripts; and (e) the paper itself reserves "ℚ-time" for where ℚ differs from the dense class (Kamp's theorem).
- [ ] In `FormalSystem/Semantics/FrameProperty.lean`, append a short "Why this class is not named `IsQTime`" note to `TaskFrame.IsDense`'s docstring: bare paper clause, not narrowed, so it keeps the paper's name per the module's "two narrowed classes" convention; pointer to the `FrameClass` docstring for the full argument.
- [ ] Optionally add one sentence to the `.Dense` bullet in `FormalSystem/Semantics/FrameClassValidity.lean`'s interpretation notes, and "The tree says `Dense`, not `QTime`" to the TM_d row of `docs/theorem-index.md` (parallel to the TM_r row's "The tree says `RTime`, not `Dedekind`").

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Edits are confined to 2 Lean docstrings (Axioms.lean, FrameProperty.lean) plus up to 2 optional one-sentence additions (FrameClassValidity.lean, docs/theorem-index.md). Confirm with `git diff --stat` that no other file changed and that every hunk lies inside a `/-- -/` / `/-! -/` block or markdown prose.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean` - canonical rationale paragraph in `FrameClass` docstring
- `FormalSystem/Semantics/FrameProperty.lean` - reciprocal pointer on `TaskFrame.IsDense`
- `FormalSystem/Semantics/FrameClassValidity.lean` - (optional) one-sentence pointer
- `docs/theorem-index.md` - (optional) TM_d row naming note

**Verification**:
- Diff read-through: every changed hunk is inside a comment/docstring or markdown prose.
- No identifier, signature, or proof text changed (`git diff` shows no non-comment Lean lines).

---

### Phase 2: Build and lint verification [NOT STARTED]

**Goal**: Run the full gate set to confirm docstring edits compile and pass repo lints.

**Tasks**:
- [ ] `lake build` (full; docstrings are elaborated, so an unterminated comment or broken code span would surface here). Use `lean_diagnostic_messages` on the touched files first for fast feedback.
- [ ] Run `bash .claude/scripts/check-task-references.sh` (or its per-file mode) over changed deliverables; confirm no task-number references.
- [ ] Run any repo paper-anchor / citation lint that covers docstrings (e.g. the C15 anchor check, if present in `scripts/` or the test suite) to confirm the new `def:frame-properties` / `def:BX-d` / `cor:tm-completeness` anchors resolve.
- [ ] Confirm no new `sorry` or `axiom` introduced (grep the diff).

**Timing**: 30-45 minutes (dominated by `lake build`)

**Depends on**: 1

**Verification Tier**: full

**Files to modify**:
- None (verification only; fix-ups loop back to Phase 1's files)

**Verification**:
- `lake build` exits 0 with no new warnings in touched files.
- Task-reference and anchor lints pass.

## Lean Challenge Statements (not applicable)

This plan pins no theorem statements: the outcome is docstring-only and introduces or changes no
declaration, so there is no Challenge module to snapshot. (Heading deliberately suffixed so
`lean-challenge-snapshot.sh` treats the R1 section as absent rather than malformed.)

## Testing & Validation

- [ ] `lake build` green
- [ ] `git diff` shows only comment/docstring/markdown changes; zero identifier renames
- [ ] `check-task-references.sh` clean on changed files
- [ ] Paper-anchor citations in new prose resolve (`def:frame-properties`, `def:BX-d`, `def:TMplus`, `cor:tm-completeness`)
- [ ] Every declaration name cited in new prose exists (verified via `lean_local_search`)

## Artifacts & Outputs

- specs/600_rename_dense_extension_qtime/plans/01_dense-naming-rationale.md (this plan)
- Modified: FormalSystem/ProofSystem/Axioms.lean, FormalSystem/Semantics/FrameProperty.lean (optionally FormalSystem/Semantics/FrameClassValidity.lean, docs/theorem-index.md)
- specs/600_rename_dense_extension_qtime/summaries/01_dense-naming-rationale-summary.md

## Rollback/Contingency

Changes are prose-only and committed per green sub-step; revert the offending commit with
`git revert` if a docstring edit breaks the build and cannot be fixed in place. If implementation
unexpectedly surfaces evidence that the class really is ℚ-only (contradicting the research), stop
and return a partial status recommending a revised plan rather than starting a ~430-site rename
under this plan.
