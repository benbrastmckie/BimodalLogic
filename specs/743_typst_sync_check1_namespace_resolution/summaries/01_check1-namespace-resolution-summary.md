# Implementation Summary: Task #743

- **Task**: 743 - Teach typst-sync-check.sh Check 1 to resolve namespaced Lean declarations
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T09:23:22Z
- **Completed**: 2026-11-13T09:37:00Z
- **Effort**: ~1.5 hours across four single-phase dispatches
- **Dependencies**: None
- **Artifacts**: plans/01_check1-namespace-resolution.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Check 1 of `scripts/typst-sync-check.sh` now resolves a fully-qualified Lean declaration name
structurally, against a build-free index of `namespace`/`end` nesting, instead of depending on
the dotted string happening to appear verbatim in some `.lean` file. The gate exits 0 with all
four checks green, the mechanism's limits are stated where a citation author will look, and no
whitelist entry was added.

## Verdict

**Option (a) taken.** Check 1 learned comment-aware namespace resolution, added additively: the
dotted-name branch is a disjunction of the whitelist, the literal scan, and the new index
lookup, so the change only ever adds a resolution path and narrows nothing.

**Option (b) rejected.** Ruling that the manual may cite only module-path-plus-leaf would have
made the one surviving fully-qualified leaf citation non-conforming, and would have left the
mechanism gap intact for any future author who reaches for the fully-qualified form.

**Option (c) rejected.** Keeping the literal grep leaves a correct citation's validation
dependent on whether an unrelated docstring happens to mention it. That is the condition that
made this a recurring finding, and the Phase 2 negative control measures it directly.

**The "fourth" route rejected** (adding the dotted cross-reference to `IntTransfer.lean`'s
module docstring). It formalizes the coincidence rather than fixing it, is Option (c) under
another name, and would have forced a `typst/generated/status.typ` regeneration over a
stylistically inconsistent docstring entry.

**No whitelist entry was added, so nothing is suppressed.** `typst/sync-check-whitelist.txt`
contains zero occurrences of `FormalSystem.Semantics.validZTime_iff_validInt`.

### Regression guard

The live citation that now depends on the resolver is
`FormalSystem.Semantics.validZTime_iff_validInt` at `typst/FormalFoundations.typ:807`. Its
dotted form occurs in no `.lean` file under `FormalSystem/` or `BimodalTools/` (0 literal
hits, re-measured in this dispatch) and it is not whitelisted, so it resolves only through the
namespace index. If the resolver regresses, Check 1 reports this citation as a violation.

## What Changed

- `scripts/typst-sync-check.sh` — Check 1 gains a comment-aware namespace-stack declaration
  index and an additive index lookup in its dotted-name branch; header bullet and a limits
  comment above that branch.
- `typst/FormalFoundations.typ` — one citation restored to fully-qualified form (line 807).
- `typst/sync-check-whitelist.txt` — header paragraph: namespace resolution exists; an entry
  for a valid declaration suppresses a resolution gap and does not certify the name.
- `typst/SYNC-MAP.md` — enforcement rule 2 names the sanctioned citation styles.
- `specs/743_typst_sync_check1_namespace_resolution/summaries/01_check1-namespace-resolution-summary.md`
  — Created (this file).

## Decisions

- Resolution is text-only: comments, docstrings and string-literal contents are stripped before
  scanning so keyword-shaped prose cannot register as a declaration. No `lake`, no `.olean`.
- `section` and `mutual` are tracked on the scope stack for `end` pairing only and contribute
  nothing to the namespace prefix.
- Only names sharing a source line with a declaration keyword are indexed. Lean-generated names
  (constructors, structure fields, `.mk`, `.rec`) and macro-produced declarations are not; the
  limits comment in the script says so.

## Plan Deviations

- **Task 1.3** altered: the comment stripper also blanks string-literal contents so a `--` or
  `/-` inside a string cannot open a comment.
- **Task 1.4** altered: `section`/`mutual` are tracked for `end` pairing; namespace paths are
  indexed alongside declarations.
- **Task 2 verification** altered: `typst/FormalFoundations.typ` is a standalone document not
  included by `BimodalReference.typ`, so it was compiled directly as well; both exit 0.
- **Tasks 4.2 and 4.3** altered: the complete gate set (`verify-deploy.sh`, unnarrowed
  `tests/run-all.sh`) was **not** run in this dispatch. The dispatch carried a Batch Gate
  Deferral directive: the full set runs once for the whole batch at the end of the invocation.
  This dispatch discharged Phase 4 against the scoped tier recorded under Verification below.
  No redeploy was run and nothing under `.claude/**` was edited.

## Verification

All results below were observed in the Phase 4 dispatch unless marked otherwise.

`bash scripts/typst-sync-check.sh` — exit 0, output verbatim:

```
== Check 1: backtick name resolution ==
TOTAL_VIOLATIONS=0
TOTAL_CANDIDATES=893
== Check 2: count freshness (generated/status.typ vs live regeneration) ==
MISMATCH_COUNT=0
All fields in generated/status.typ match a live regeneration.
== Check 2b: module map freshness (generated/automation-module-map.typ vs live regeneration) ==
MODULE_MAP_MISMATCHES=0
generated/automation-module-map.typ matches a live regeneration.
== Check 3: machine appendix freshness (generated/machine-appendix.*) ==
MA_COUNT_MISMATCHES=0
machine-appendix.typ matches a re-render from the committed JSONL.
== Check 4: code environment discipline (typst/chapters/*.typ) ==
CHECK4_VIOLATIONS=0
Every code block is wrapped in lean-code(), within budget, and every source-excerpt name resolves.
typst-sync-check.sh: PASS (all 4 checks green)
```

- CLI contract: `--counts-only` exit 0; `--help` exit 0; unrecognized flag exit 2.
- Positive control: the line-807 citation resolves with 0 literal `.lean` hits and no
  whitelist entry.
- Negative control: **not re-run here** (it requires a temporary edit to a `.lean` file on a
  shared working tree). Measured in the Phase 2 dispatch: with the dotted name swapped out of
  `FormalSystem/Metalogic/Decidability.lean:181`, the full dotted string had zero literal hits
  and the gate still exited 0 with Check 1 at 0 violations; probe reverted.
- `git diff --exit-code -- FormalSystem/Metalogic/Decidability.lean` exit 0 (no probe residue).
- Build-free: every `lake`/`.olean` match in the script is a comment asserting their absence
  or the text of an error hint; `bash -n` clean.
- `bash .claude/scripts/check-task-references.sh` exit 0, 0 occurrences.
- `bash .claude/scripts/check-record-versioning.sh` exit 1 on 6 BLOCKING findings, all in
  `Boneyard/` and `FormalSystem/Metalogic/Expressiveness/Kamp/` Lean files this task does not
  touch; none in any file this task modified.
- Scoped shell suites: `run-all.sh --only test-check-record-versioning.sh,test-check-task-references.sh`
  — 2 passed, 0 failed.
- `git status --short`: modifications confined to this task's `specs/` directory, plus three
  entries present before every dispatch of this task and not its own (`specs/events.jsonl`,
  untracked `.pid`, untracked `specs/evidence/history-morphism-saturation-audit/`).

**Scoped-tier discharge.** No shell suite under `.claude/scripts/tests/` and no
`verify-deploy.sh` gate exercises `scripts/typst-sync-check.sh` or the `typst/` files, so the
phase's own named criterion was run directly as the scoped discharge. The full gate set is
deferred to the batch-level stage, not waived.

- Build: N/A (no Lean source changed)
- Tests: Passed (scoped tier; full battery deferred to batch stage)
- Files verified: Yes

## Impacts

- A fully-qualified citation of a declaration written with an explicit declaration keyword
  inside `namespace` blocks now validates on its own merits.
- Check 1's violation set and candidate count are unchanged for every pre-existing citation.

## Follow-ups

- Check 4 carries its own copy of the literal-grep helper (`grep_lean`,
  `scripts/typst-sync-check.sh:430`, independent of Check 1's at line 630). It does not share
  the namespace defect today only because Check 4 never assembles a dotted string. Out of this
  task's scope; worth a follow-up if Check 4 ever resolves qualified names.
- The 6 BLOCKING record-versioning findings in Lean files are unrelated to this task.

## References

- specs/743_typst_sync_check1_namespace_resolution/plans/01_check1-namespace-resolution.md
- specs/743_typst_sync_check1_namespace_resolution/reports/01_namespace-resolution-feasibility.md
- specs/743_typst_sync_check1_namespace_resolution/handoffs/phase-2-handoff-20261113T092722Z.md
