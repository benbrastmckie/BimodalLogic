# Implementation Summary: Lean 4 Appendix for BimodalReference.typ

- **Task**: 620 - Lean 4 appendix for BimodalReference.typ
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T05:37:19Z
- **Completed**: 2026-09-18T05:57:14Z
- **Effort**: ~7.5 hours (estimate matched)
- **Dependencies**: None
- **Artifacts**: plans/01_lean-appendix-plan.md, reports/01_lean-appendix-research.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Added `typst/chapters/ax-lean-appendix.typ`, a from-basics Lean 4 primer covering the nine
required topics (what Lean is; `Type` vs. `Prop` and dependent types; propositions-as-types and
proof terms; inductive types via `Formula`/`DerivationTree`; structures and classes; tactic vs.
term proofs; Mathlib conventions; lake and project layout; reading `FormalSystem/` source),
wired into the book's back matter before the machine appendix and cross-referenced from the
introduction. All six plan phases completed.

## What Changed

- New: `typst/chapters/ax-lean-appendix.typ` (240 lines, 9 sections, `<lean-appendix>` label).
- New: `specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean`, the
  verification record every didactic snippet and `#leansrc` excerpt was checked against via
  `lake env lean` (zero errors, zero `sorry`).
- Edited: `typst/BimodalReference.typ` (one `#include` line, before `ax-machine-appendix.typ`).
- Edited: `typst/chapters/00-introduction.typ` (Outline back-matter sentence; "How to Read This
  Book" closing pointer).
- Edited: `typst/chapters/README.md` (one new table row).
- Edited: `typst/sync-check-whitelist.txt` (new category comments and entries for Check 1 spans
  the new appendix introduces).
- Edited: `typst/SYNC-MAP.md` (new dated "2026-09-17 Addition — Lean 4 Appendix" section).

## Decisions

- Used `FormalSystem.Semantics.TaskModel` (one field, `valuation : F.WorldState → Atom → Prop`)
  rather than `TaskFrame` for the structures-and-classes `#leansrc` example — `TaskFrame` is a
  two-field fibration whose actual content lives in a nested `FrameOver`, too indirect to
  excerpt legibly in a section the plan asked to keep small.
- `apply_axiom`'s tactic example uses the tactic's verified zero-argument behavior (`apply
  DerivationTree.axiom; refine ?_`, leaving `h`/`h_fc` open) plus explicit closing tactics,
  rather than the stale `apply_axiom MT φ` argument-passing spelling in
  `docs/reference/tactic-reference.md`, which does not elaborate against the live macro.
- 8 `#leansrc` excerpts, each re-diffed byte-exact against current source after the prose was
  written (docstrings elided for length; constructor/field/signature lines exact):
  `Derivable`, `Formula`, `Formula.always`/`Formula.sometimes`, `DerivationTree`, `Atom`,
  `TaskModel`, `soundness`, `FormalSystem.Metalogic.BXCanonical.completeness`.
- Seed docs (`tutorial.md`, `quickstart.md`) used for narrative framing only, never quoted;
  `LEAN_STYLE_GUIDE.md`'s naming rules cited directly except its stale `Logos.*` namespace
  example, replaced with the live `FormalSystem.*` tree; `tactic-reference.md` cited directly
  apart from the `apply_axiom` argument-spelling discrepancy above.

## Plan Deviations

- Phase 4 structures example: `TaskModel` instead of `TaskFrame` (see Decisions above; the
  plan's own "(e.g. `TaskFrame`)" phrasing flagged this as illustrative, not fixed).
- Phase 6 verification: `scripts/typst-sync-check.sh` Check 2b (automation module-map
  freshness) fails, but for a reason unrelated to this task — `ProofSearch/Core.lean`,
  `ProofSearch/Strategies.lean`, `SuccessPatterns.lean`, and `Tactics/Search.lean` had already
  drifted against the committed `generated/automation-module-map.typ` before this task's
  session began (confirmed via `git status`/`git diff`: no working-tree changes to those files
  here). Regenerating that map is outside this task's file scope and was not attempted. Check 1
  (the check this task's new content actually exercises) and Check 3 both pass cleanly.

## Impacts

- Readers new to Lean now have a single, self-contained entry point (`@lean-appendix`) from any
  cited Lean identifier in the book back to a from-basics explanation and, from there, to the
  live source.
- One real discrepancy surfaced and corrected in the appendix's own text: `apply_axiom`'s
  documented argument-passing usage does not match its current implementation. The seed doc
  itself (`docs/reference/tactic-reference.md`) was left unedited, per this task's stated
  non-goal of not fixing out-of-date `docs/user-guide/*.md`/`docs/reference/*.md` content.
- No Lean library source or test files were modified; the scratch verification file lives
  outside `FormalSystem/` and `Tests/` and does not participate in `lake build`.

## Follow-ups

- Consider a follow-up task to correct `docs/reference/tactic-reference.md`'s `apply_axiom`
  argument-spelling examples and `docs/user-guide/tutorial.md` / `quickstart.md`'s broader
  drift (out of scope here, per this task's Non-Goals).
- Whoever owns `typst/generated/automation-module-map.typ` should run
  `bash scripts/typst-module-map.sh` to clear the pre-existing, unrelated Check 2b drift noted
  above.

## References

- Plan: `specs/620_lean_appendix_bimodal_reference/plans/01_lean-appendix-plan.md`
- Research: `specs/620_lean_appendix_bimodal_reference/reports/01_lean-appendix-research.md`
- Verification record: `specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean`
- SYNC-MAP entry: `typst/SYNC-MAP.md` ("2026-09-17 Addition — Lean 4 Appendix")
- Handoff: `specs/620_lean_appendix_bimodal_reference/handoffs/phase-6-handoff-20260918T055714Z.md`
