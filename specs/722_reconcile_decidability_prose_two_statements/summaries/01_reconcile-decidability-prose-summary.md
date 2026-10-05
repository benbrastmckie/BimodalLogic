# Implementation Summary: Task #722

- **Task**: 722 - Reconcile the programme-level decidability prose with the two-statement distinction (tableau biconditional open; Decidable (ValidZTime phi) proved)
- **Status**: [COMPLETED]
- **Started**: 2026-10-05T09:15:00Z
- **Completed**: 2026-10-05T11:10:00Z
- **Effort**: ~2 hours
- **Dependencies**: None (ran in a cycle disjoint from tasks 177 and 543, per the plan's scheduling constraint)
- **Artifacts**: plans/01_reconcile-decidability-prose.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Eight programme-level prose surfaces described only the tableau decidability spine (open at all
four frame classes) and so stated or implied that no decidability theorem in this tree is
machine-checked. That has been false since 2026-09-28, when
`FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` landed. All seven plan
phases are complete: Phase 1 re-verified every cited declaration, axiom set, absence, and stale
phrase before any edit; Phases 2-6 made each of the eight surfaces state the two-statement
distinction once, in its own register, with all four qualifiers on the proved result; Phase 7's
acceptance sweep confirms the full gate set is unchanged from the Phase 1 baseline and surfaced
one out-of-scope finding (below).

## What Changed

- `README.md` — one new paragraph in `### Decidability`, stating both halves of the distinction, citing `Compression.decidableValidZTime` with all four qualifiers and a `docs/theorem-index.md` pointer. Existing Landed/Open/Partial bullets and the TM⁺ open-problems bullet left untouched.
- `FormalSystem/README.md` — one new paragraph after the existing "Decidability is not 'fully proven'" paragraph, same content; Layer-2 table row left untouched.
- `FormalSystem/Metalogic/Decidability/README.md` — one new Overview bullet after the existing three, cross-referencing `WitnessFamily/README.md` and `docs/theorem-index.md`.
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — replaced the false "no decidability theorem is machine-checked at present" clause with the corrected statement (naming the presentation-free witness-family route, not this directory's own refuted `fmp`-conditional assembly), and re-tensed the "remaining route to decidability" sentence to past tense (the route succeeded). The `Probe476.fmp_false` refutation paragraphs and "this directory does not decide the logic" framing are unchanged.
- `docs/architecture/ADR-007-Decidability-One-Directional.md` — added a "**Landed, separately.**" Decision bullet; extended (not replaced) the governing rule "no surface may say decidability is fully proven" with the one-proven-theorem sentence; replaced the stale exact-row-count claim in the Consequences bullet, and — a deviation beyond the plan's explicit task list, recorded below — the Related section's matching stale "the two landed rows" link text, with a section pointer in both places.
- `docs/project-info/known-limitations.md` — added a scoping note to Limitation 6 immediately after its "is open." sentence, stating the limitation is scoped to the `isValid` biconditional only and does not narrow given the separately proved `ValidZTime` result. Title, table, `extractionFailed` caveat, and "sound direction only" sentence unchanged.
- `FormalSystem/Metalogic/Decidability.lean` — one new bullet in the module docstring's "This directory's decision procedure" list, noting the second decidability theorem lives outside this file's own import graph. Comment text only; no `import`/`def`/`theorem`/`instance` line touched (confirmed by diff). `lake build FormalSystem.Metalogic.Decidability` passes.
- `typst/FormalFoundations.typ` — replaced "No decidability theorem is machine-checked." with a sentence stating the `$#BL$`-level Z-time result is machine-checked, explicitly leaving TM⁻'s own (still-open) decidability exactly as stated by the theorem box above it; rewrote the `#remark` reduction block so the Discrete factor is stated decidable (citing `decidableValidZTime` and the `validZTime_iff_validInt` carrier-normalization bridge), the Dense factor remains open, and the reduction identity itself remains a target with no Lean declaration. No complexity vocabulary introduced. `typst compile --root .. FormalFoundations.typ` succeeds.
- `typst/generated/status.typ` — regenerated via `scripts/typst-sync-check.sh --fix` after Phase 5's docstring edit shifted `FormalSystem`'s line count; required by the project's own pre-commit gate, not a task-scope change.

## Decisions

- Phase 4 corrected a second, plan-unnamed instance of ADR-007's stale exact-row-count framing (the Related section's "the two landed rows" link text) because it is the identical defect, in the same already-in-scope file, as the Consequences bullet the plan named explicitly.
- The typst correction states the new result at the paper's `$#BL$` register, which — per the dispatch's own instruction — already satisfies the "no stability operator" qualifier without a separate caveat, since this paper never defines a stability operator. The edit is explicit that this does not resolve or narrow the TM⁻-family decidability question the surrounding `== Decidability` section states is open.
- The typst edit's first draft tripped one new ADVISORY (non-blocking) `chapter-quality-check.sh` paragraph-length finding; split into two paragraphs so the gate's output is byte-identical to the Phase 1 baseline.

## Plan Deviations

- **Task 4.3 (ADR-007 Consequences row-count replacement)** altered: additionally fixed the Related section's matching stale link text (line 64 pre-edit), not named in the plan's task list but the same defect in the same file. See `progress/phase-4-progress.json`.
- No other deviations. All seven phases executed in full per the plan's task sequence.

## Verification

- Build: Success (`lake build`, whole library, 2819 jobs; also scoped `lake build FormalSystem.Metalogic.Decidability` after Phase 5).
- Typst: Success (`cd typst && typst compile --root .. FormalFoundations.typ`).
- Tests: N/A (no Lean proof, test, or executable code was changed — only prose and one module docstring).
- Files verified: Yes, all eight surfaces plus `typst/generated/status.typ` confirmed present and correct by diff read-through and targeted grep.

### Eight-Surface Acceptance Table

Every surface contains the fully-qualified declaration name, all four qualifiers
(`FrameClass.ZTime`-only; no-stability-operator — explicit or via the `$#BL$` register in the
typst file; empty premises; computing-but-not-choice-free), and a `docs/theorem-index.md`
pointer, exactly once as a coherent statement of the distinction:

| Surface | Decl name | 4 qualifiers | Index pointer | Stated once |
|---|---|---|---|---|
| `README.md` | yes | yes | yes | yes |
| `FormalSystem/README.md` | yes | yes | yes | yes |
| `FormalSystem/Metalogic/Decidability/README.md` | yes | yes | yes | yes |
| `FormalSystem/Metalogic/Decidability/BiLasso/README.md` | yes | yes | yes | yes |
| `docs/architecture/ADR-007-Decidability-One-Directional.md` | yes | yes | yes | yes |
| `docs/project-info/known-limitations.md` | yes | yes | yes | yes |
| `FormalSystem/Metalogic/Decidability.lean` (docstring) | yes | yes | yes | yes |
| `typst/FormalFoundations.typ` | yes | yes (no-stability satisfied by `$#BL$` register) | yes | yes |

### Repo-wide Sweeps (Phase 7)

- `"no decidability theorem is machine-checked"` and `"neither factor logic is known decidable"`: zero hits outside `specs/**`, line-wrap tolerant.
- Unqualified `"TM is decidable"` and near-variants outside `specs/**`: zero hits in the eight surfaces or elsewhere, **except one finding** — see Follow-ups.
- Complexity vocabulary (`complexity`, `NP`, `PSPACE`, `EXPTIME`, `exponential`, `polynomial`) across this task's whole diff: zero hits.
- `git diff --name-only` against the base commit (`89262d2bb`): every one of this task's own five content-bearing commits touches only its phase's named surfaces plus this task's own `specs/722_.../` artifacts (verified per-commit via `git show --name-only`); `docs/theorem-index.md`, `WitnessFamily/README.md`, and `Correctness.lean` are absent from all of them. (The branch-wide diff also shows concurrently-dispatched sibling tasks 726/728 touching their own declared territory on the same shared working tree — expected, not this task's change.)
- `.lean` diff restricted to this task: only `FormalSystem/Metalogic/Decidability.lean`, and only inside its `/-! -/` docstring block.

### Full Gate Set vs. Phase 1 Baseline

| Gate | Phase 1 baseline | Phase 7 final | Delta |
|---|---|---|---|
| `lake build` (whole library) | PASS (2819 jobs) | PASS (2819 jobs) | none |
| `typst compile --root .. FormalFoundations.typ` | PASS | PASS | none |
| `check-task-references.sh` | FAIL (198 pre-existing, none in the 8 surfaces) | FAIL (198 pre-existing, none in the 8 surfaces) | none |
| `verify-deploy.sh` | PASS (14 checks, 0 failures; 1 pre-existing WARN) | PASS (14 checks, 0 failures; same WARN) | none |
| `typst-element-lint.sh --verbose` | FAIL (14 placement findings) | FAIL (14 placement findings, identical content, lines shifted) | none |
| `chapter-quality-check.sh --verbose` | FAIL (BLOCKING 61 / ADVISORY 40 / JUDGED 30) | FAIL (BLOCKING 61 / ADVISORY 40 / JUDGED 30, identical content) | none |

## Impacts

- Every programme-level entry point a reader is likely to consult (both top-level READMEs, the
  Decidability directory and BiLasso subdirectory READMEs, ADR-007, known-limitations.md, the
  aggregator module's own docstring, and the paper itself) now correctly states that one
  decidability theorem — `Decidable (ValidZTime φ)`, narrowly scoped — is machine-checked,
  without weakening ADR-007's governing rule against overclaiming full decidability.
- No Lean proof, build artifact, or state file was touched beyond one docstring comment and the
  mechanically-required `typst/generated/status.typ` regeneration.

## Follow-ups

- **Ninth surface found, out of scope, not fixed**: `FormalSystem/Examples/Walkthrough.lean:173`
  states "TM is decidable, and the library ships the procedure that decides it: a tableau search
  wrapped in `isValid φ fc : Bool`..." — unqualified, the same defect class this task corrects,
  but not one of the eight surfaces named in the dispatch. Per the plan's Non-Goals ("Phase 7's
  sweep may surface a genuinely stale ninth instance, which is reported rather than silently
  expanded into"), this was not edited. Recommend a small follow-up task to correct this one file.
- The task description's own Context Extension Recommendation (a mechanical doc-lint for this
  staleness class) was explicitly out of scope for this task and is noted for a future `meta`
  task, not executed here.

## References

- Plan: `specs/722_reconcile_decidability_prose_two_statements/plans/01_reconcile-decidability-prose.md`
- Research report: `specs/722_reconcile_decidability_prose_two_statements/reports/01_reconcile-decidability-prose.md`
- Phase 1 verified-claims record: `specs/722_reconcile_decidability_prose_two_statements/.verified-claims.md`
- Progress files: `specs/722_reconcile_decidability_prose_two_statements/progress/phase-{1..7}-progress.json`
- Handoffs: `specs/722_reconcile_decidability_prose_two_statements/handoffs/`
- `docs/theorem-index.md`'s Decidability section (citation target for all eight surfaces)
