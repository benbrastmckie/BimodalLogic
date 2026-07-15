# Implementation Summary: Revise BimodalReference.typ to Present All and Only the Bimodal Logic

- **Task**: 371 - Completely revise the Bimodal Reference typst document to present all and only the bimodal logic
- **Status**: [COMPLETED]
- **Started**: 2026-07-15T08:20:00Z
- **Completed**: 2026-07-15T08:36:00Z
- **Effort**: ~1.5 hours (all 5 phases)
- **Dependencies**: None
- **Artifacts**: plans/01_two-part-bimodal-reference.md, reports/01_cut-parts-iii-iv-bimodal-only.md

## Overview

Cut Part III (Counterfactual Logic) and Part IV (Constitutive Logic) from
`Theories/Bimodal/typst/BimodalReference.typ` entirely, leaving a focused two-part
reference (Part I: The Bimodal System, Part II: Applications). Beyond mechanical
deletion of 886 lines across two chapters, the abstract, title-page Sources block,
and `00-introduction.typ`'s roadmap/reading-guide were genuinely rewritten so the
book reads as a self-contained bimodal-logic reference. Bibliography, notation
comments, sync tooling, and repo docs were brought into agreement with the new
two-part scope. All 5 plan phases executed in dependency order (1, 2, 3, 4, 5),
each verified green (typst compile exit 0) before commit.

## What Changed

- `BimodalReference.typ`: two-part header comment; Sources block trimmed to 2 items
  (possible-worlds paper + Lean repo); abstract's Part III/IV sentence removed;
  Part III and Part IV divider blocks + `#include`s deleted.
- Deleted `chapters/p5-counterfactual.typ` (504 lines), `chapters/p5-constitutive.typ`
  (382 lines), `notation/constitutive-notation.typ` (67 lines).
- `chapters/00-introduction.typ`: opening paragraph, figure caption, `== Outline`
  (four parts -> two), and `== How to Read This Book` (dropped the
  philosophical-extensions bullet) genuinely restructured, not just trimmed.
- `bibliography.bib`: removed the 12-entry removed-only block plus the two now-orphaned
  keys `brastmckie2025counterfactualworlds` / `brastmckie2021identity`.
- `notation/bimodal-notation.typ`: removed stale constitutive-notation/Logos-triangle
  comments; deleted the dead `store(i)`/`recall(i)` functions.
- `sync-check-whitelist.txt`: removed the `constitutive-notation.typ` entry and (drive-by)
  the now-dead `counterfactual_worlds.tex` entry.
- `README.md`: four-part -> two-part framing throughout; task-317 Follow-Up row marked
  superseded (audit trail preserved, not deleted).
- `SYNC-MAP.md`: appended a dated task-371 note; historical tables left untouched.
- Drive-by fixes: `p3-vlach-blstar.typ:27` reworded ("counterfactual" -> "hypothetical");
  `p2-decidability-practice.typ:64` corrected a pre-existing "Part IV's dataset pipeline"
  misnumbering to "Part II's" (dataset pipeline has always been under Part II).

## Decisions

- Both bibliography-orphan-key deletion and `store`/`recall` dead-code deletion (the
  two decision points the research report surfaced) were resolved toward strict
  "all and only" per the task's explicit scope, matching the plan's resolution.
- Figure-caption clause (`00-introduction.typ:91`) was rewritten to drop the
  counterfactual reference entirely rather than reword-to-out-of-scope, since the
  reword option would have left the word "counterfactual" in place, conflicting with
  this task's strict global grep mandate.
- `p3-vlach-blstar.typ:27`'s incidental "counterfactual" usage (flagged optional by the
  plan) was reworded for the same reason.

## Impacts

- Compiled `BimodalReference.pdf` now contains only Parts I and II; no "PART III"/
  "PART IV" text anywhere in the rendered output.
- `grep -rniI "counterfactual|constitutive" Theories/Bimodal/typst/` returns only the
  dated SYNC-MAP note (this task's own append, plus its untouched historical text) and
  the plan-mandated README audit-trail strikethrough row — no stray structural,
  roadmap, divider, include, or bibliography hits.
- `bash scripts/typst-sync-check.sh` (repo root): Check 3 passes; Checks 1 and 2 **fail
  on pre-existing, out-of-scope violations** unrelated to this task —
  `` `rabinovich_translate` `` unresolved in `p3-vlach-blstar.typ` and three
  `WeakCanonical/` sorry-count mismatches. Verified via `git stash` that both failures
  are byte-identical on the tree from *before* any of this task's edits; they trace to
  concurrent, committed, in-progress Lean formalization work under
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` from tasks 368/370 (confirmed via
  `git log` on those files), which is outside task 371's file scope
  (`Theories/Bimodal/typst/`) and its explicit non-goal ("Any Lean source changes").
  This is **not a regression** introduced by this task, but it means the literal
  "sync-check PASSes" verification bullet is not fully green — flagged here for
  visibility rather than silently declared done.

## Follow-ups

- The pre-existing `rabinovich_translate` backtick violation and the `WeakCanonical/`
  sorry-count drift are unrelated to this task and should be tracked/fixed by tasks
  368/370 (the owners of the in-progress `Metalogic/WeakCanonical/Kamp/` Lean work),
  e.g. via `bash scripts/typst-status-counts.sh` regeneration once that work settles.
- `chapters/README.md` and `notation/README.md` are pre-existing stale docs (predate the
  four-part structure entirely) flagged by the research report as a drive-by opportunity;
  left untouched as genuinely out of this task's scope (not mentioned by the plan).

## References

- specs/371_revise_bimodal_reference_bimodal_only/plans/01_two-part-bimodal-reference.md
- specs/371_revise_bimodal_reference_bimodal_only/reports/01_cut-parts-iii-iv-bimodal-only.md
- specs/371_revise_bimodal_reference_bimodal_only/handoffs/phase-1-handoff-20260715T082803Z.md
- specs/371_revise_bimodal_reference_bimodal_only/handoffs/phase-2-handoff-20260715T082900Z.md
- specs/371_revise_bimodal_reference_bimodal_only/handoffs/phase-3-handoff-20260715T083200Z.md
- specs/371_revise_bimodal_reference_bimodal_only/handoffs/phase-4-handoff-20260715T083500Z.md
- specs/371_revise_bimodal_reference_bimodal_only/handoffs/phase-5-handoff-20260715T084500Z.md

## Plan Deviations

- Abstract Part II sentence lightly reworded (not left verbatim) for a cleaner
  two-paragraph close.
- Figure caption (`00-introduction.typ:91`) rewritten to drop the counterfactual
  reference entirely, rather than reworded to "out of scope" as first attempted, to
  satisfy the strict global grep.
- `p3-vlach-blstar.typ:27` reworded (plan left this as optional/implementer's judgment).
- `p2-decidability-practice.typ:64` fixed a pre-existing "Part IV" misnumbering, outside
  the plan's file list, required by the mandated PART III/IV grep check.
- `sync-check-whitelist.txt`: also removed the now-dead `counterfactual_worlds.tex`
  entry and its header category bullet (drive-by, not in the plan's explicit line list).
- `typst-sync-check.sh` does not exit 0 overall — Checks 1/2 fail on pre-existing,
  out-of-scope Lean-side issues unrelated to this task (documented above and in the
  Phase 5 handoff). All other mandated verification criteria pass.
