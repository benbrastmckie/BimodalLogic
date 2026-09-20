# Implementation Summary: Task #631

- **Task**: 631 - Deliverable hygiene excluding specs
- **Status**: [COMPLETED]
- **Started**: 2026-09-20T00:00:00Z
- **Completed**: 2026-09-20T03:45:00Z
- **Effort**: ~4 hours (across two dispatches; the first died mid-Phase-1 to an API transport error)
- **Dependencies**: None
- **Artifacts**: plans/01_deliverable-hygiene.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Brought the tracked tree down to a publishable deliverable across all 8 plan phases: untracked
four agent-system configuration files and `docs/research/`/`docs/training/`, deleted four one-off
scripts (documenting every survivor in a new `scripts/README.md`), retired the frozen `latex/`
edition and its tracked PDF, moved `CONTRIBUTING.md` to the repository root, removed every
personal absolute path from `docs/` and `typst/`, and normalised stale `Logos`/`ProofChecker`/
`lakefile.lean` naming across ~20 files. Nothing under `specs/` was untracked; `specs/` grew by
exactly 6 files (this task's own progress-tracking artifacts). Both acceptance gates
(`scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`) are green, and
`grep -rn 'home/benjamin' docs typst` returns nothing.

## What Changed

- `.gitignore` — added root-anchored entries for `/CLAUDE.md`, `/.claude-extensions.json`,
  `/.syncprotect`, `/research/`, `/training/`
- `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, `.gitattributes` — untracked (first
  three retained on disk; the empty `.gitattributes` deleted outright)
- `scripts/migrate_schema_v2.py`, `scripts/swap_untl_snce.py`, `scripts/standardize_metadata.py`,
  `scripts/add-copyright-headers.sh` — deleted
- `scripts/README.md` — new file naming every surviving top-level script, `lib/` helper module,
  and non-script data file
- `docs/reference/paper-definitions-of-record.md` — reworded the `swap_untl_snce.py` retention
  promise; genericised the JPL-paper checkout path to `~/Philosophy/Papers/...`
- `latex/**` (18 tracked files including `BimodalReference.pdf`), `docs/development/LATEX_STANDARDS.md`
  — deleted; `README.md`, `FormalSystem/README.md`, `docs/development/README.md`, `docs/README.md`,
  `typst/README.md`, `typst/SYNC-MAP.md`, `ORGANISATION.md`, `docs/development/CONTRIBUTING.md`
  (pre-move) — repointed away from the retired edition
- `docs/development/CONTRIBUTING.md` → `CONTRIBUTING.md` (moved to repository root); 6 internal
  links rewritten; 14 citer sites across `README.md`, `docs/README.md`,
  `docs/development/{README,VERSIONING,QUALITY_METRICS,DIRECTORY_README_STANDARD}.md`,
  `docs/installation/BASIC_INSTALLATION.md`, `docs/user-guide/{MCP_INTEGRATION,architecture,tutorial}.md`
  repointed
- `docs/research/**` (15 files), `docs/training/**` (4 files) — untracked and **relocated** to
  repository-root `research/`/`training/` (see Deviations); ~36 inbound reference sites repaired,
  concentrated in an extensive `docs/README.md` navigation index the original research pass did
  not fully enumerate
- `docs/development/DOC_QUALITY_CHECKLIST.md` — dropped 3 literal `cd /home/benjamin/...` example
  lines
- `docs/development/PUBLICATION_REFACTOR.md` — reworded 4 self-quoting acceptance-grep lines into
  prose so the literal acceptance command can return empty
- `scripts/check-paper-definitions.sh` — added tilde-expansion for the `PAPER_PATH`/
  `PAPER_REPO_ROOT` record sentinels (needed once those sentinels became `~`-relative)
- `docs/user-guide/{examples,tactic-development,tutorial}.md`, `docs/development/LEAN_STYLE_GUIDE.md`
  — rewrote stale `import Logos.*` / `open Logos.*` Lean-package usage to `FormalSystem.*`
- `docs/user-guide/{troubleshooting,quickstart}.md`, `docs/installation/BASIC_INSTALLATION.md`,
  `docs/user-guide/architecture.md` — normalised loose literal-name `ProofChecker`/`Logos`
  self-references (directory/clone/API-ownership claims) to the repository name or generic phrasing
- `docs/development/{NONCOMPUTABLE_GUIDE,DOC_QUALITY_CHECKLIST}.md`, `docs/project-info/tactic-registry.md`,
  `docs/development/PROPERTY_TESTING_GUIDE.md` — same class of self-referential `Logos` fix
- `docs/user-guide/architecture.md`, `docs/development/LEAN_STYLE_GUIDE.md`,
  `docs/development/NAMING_CONVENTION_DEVIATION.md` — absorbed task-610 scope: 4 stale
  `lakefile.lean` mentions rewritten to `lakefile.toml`

## Decisions

- **`docs/research/`/`docs/training/` relocated to repo root, not left in place.** The plan called
  for untracking them in place under `docs/`, but `check-module-invariants.sh`'s C13 check walks
  the `docs/` filesystem tree independent of git tracking and separately marks a resolved link's
  target as broken via `git check-ignore`. Left in place, every *internal* self-link between the
  newly-ignored sibling files (not just the 6 external inbound sites research found) became a
  reported break — 58 broken links on a live run, not 6. Moving both directories to root-level
  `research/`/`training/` (still gitignored, still on disk, still `git add -f`-reversible) removes
  them from C13's scan scope entirely while preserving the plan's untrack-not-delete intent.
- **`FormalSystem.Theorems.<YourModule>` placeholder, not `FormalSystem.Theorems.MyModule`.**
  Renaming the doc's illustrative `Logos.Core.Theorems.MyModule` example to a real-looking
  `FormalSystem.*` dotted path tripped C5 (unresolved module path), since `MyModule` doesn't
  exist. Angle-bracket placeholder notation keeps the illustration while staying outside C5's
  identifier regex.
- **`typst/chapters/p4-dataset-pipeline.typ`'s ~10 footnote citations to `docs/training/PIPELINE.md`
  left untouched.** Added to the tree after the research report was written; they are provenance
  citations to a file that still exists locally, are outside this phase's declared file-to-modify
  scope, and are not scanned by any of the three stated acceptance gates.
- **Post-Phase-7 `lakefile.lean` re-grep hits in `lake-manifest.json`, `typst/chapters/ax-lean-appendix.typ`,
  and `FormalSystem/Boneyard/**` left untouched.** The manifest entry names a third-party
  dependency's own config file (never hand-edited); the typst chapter is generic prose contrasting
  Lake's two config formats, not a claim this repo uses `lakefile.lean`; and Boneyard is archived,
  non-live content explicitly out of scope per this plan's own Non-Goals.
- **`docs/user-guide/troubleshooting.md:53`/`quickstart.md:8` misuse class extended to
  `BASIC_INSTALLATION.md`'s "Clone ProofChecker" heading**, since it directly precedes a
  `git clone .../BimodalLogic.git` command — the same directory/clone-identity confusion the plan
  named those two sites to fix.

## Plan Deviations

- **Phase 4, `docs/research/`/`docs/training/` disposition**: altered from "untrack in place" to
  "untrack and relocate to repository root" — see Decisions above. Both directories remain on
  local disk and are `git add -f`-reversible; only their physical path changed.
- **Phase 7, C5 regression**: the `lake build Logos.Core.Theorems.MyModule` example was rewritten
  to an angle-bracket placeholder rather than a bare `FormalSystem.*` path, to avoid a spurious C5
  failure — see Decisions above.
- No other deviations; all remaining plan tasks were completed as specified.

## Verification

- Build: N/A (no Lean source change; `lake build` not required by this task)
- Tests: N/A
- `bash scripts/check-module-invariants.sh` — `ALL CHECKS PASSED` (final run)
- `bash scripts/readme-lint.sh` — `RESULT: PASS`, `Broken file references: 0` (final run)
- `grep -rn 'home/benjamin' docs typst` — empty
- `git ls-files | grep -E '^(CLAUDE\.md|\.claude-extensions\.json|\.syncprotect|\.gitattributes)$'` — empty
- `git ls-files latex/ docs/research docs/training` — empty
- `ls CONTRIBUTING.md scripts/README.md` — both succeed
- Tracked file count: 1301 before this task's first commit → 1262 after (net −39). Fully
  reconciled: 47 deletions (18 `latex/` + 1 `LATEX_STANDARDS.md` + 15 `docs/research/` +
  4 `docs/training/` + 4 dotfiles (`CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`,
  `.gitattributes`) + 4 one-off scripts + 1 `docs/development/CONTRIBUTING.md` old path) offset
  by 8 additions (`scripts/README.md`, `CONTRIBUTING.md` new path, and 6 progress-tracking JSON
  files this dispatch itself created under `specs/631_.../progress/`). `specs/` grew from 218 to
  224 tracked files (exactly those 6 progress files) — no `specs/` path was untracked or deleted.
- Files verified: Yes

## Impacts

- The tracked tree is materially closer to publication-ready: no personal absolute paths, no
  frozen/duplicate LaTeX edition, no internal research/training notes, and a documented `scripts/`
  directory.
- `docs/research/` and `docs/training/` now live at the repository root (`research/`, `training/`)
  rather than under `docs/`; any tooling or documentation written after this task that expects the
  old `docs/`-nested path should use the new root-level path instead (both are gitignored and
  local-only either way).
- `scripts/check-paper-definitions.sh` now expects its record sentinels in `~`-relative form and
  performs the tilde expansion itself; a future record file must follow that convention or supply
  an already-absolute path (both are supported).

## Follow-ups

- Task 637's own dotfile-untrack step (`CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`) will
  find these three already untracked, per this task's research report's documented duplication
  note; no action needed there, just not a surprise.
- `typst/chapters/p4-dataset-pipeline.typ`'s footnote citations to `docs/training/PIPELINE.md`
  still cite the old `docs/`-nested path (now `training/PIPELINE.md`); left untouched as
  out-of-scope for this task (see Decisions), but a future typst-maintenance pass could update
  them for path accuracy.
- Observed but not investigated (outside this task's scope, pre-existing/foreign, not produced by
  this dispatch): `specs/559_nondeterministic_canonical_model_tm_star_completeness/.return-meta.json`
  shows as a deleted, unstaged file, and `specs/events.jsonl` shows as modified, unstaged, in the
  working tree throughout this dispatch. Neither was touched by this task's work; flagging per the
  observation-duty contract.

## References

- Plan: `specs/631_deliverable_hygiene_excluding_specs/plans/01_deliverable-hygiene.md`
- Research: `specs/631_deliverable_hygiene_excluding_specs/reports/01_deliverable-hygiene-research.md`
- Governing programme document: `docs/development/PUBLICATION_REFACTOR.md` (Phase 1 / Follow-up B)
