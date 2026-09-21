# Implementation Summary: Task #643

- **Task**: 643 - Citation gates: bibkeys, links and line anchors
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T15:21:37Z
- **Completed**: 2026-09-21T19:10:00Z
- **Effort**: ~4 hours
- **Dependencies**: None
- **Artifacts**: plans/01_citation-gates-bibkeys-links.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Three citation gates were added to `scripts/check-module-invariants.sh`: C31 (every bibkey in a
`## References` block resolves in `references.bib`), C32 (every relative markdown link in a
`.lean` comment resolves relative to the citing file) and a third, declaration-span assertion
inside C20 (a citation that names a declaration must land inside it). The third assertion's
first run found the defect the task hypothesised at a scale nobody had measured: **327 named
citations already pointed at the wrong declaration**, invisible to C20 tier 1 throughout. 315 of
them were re-pointed by name in this task; 10 remain on a recorded, shrink-only baseline.

## What Changed

- `scripts/check-module-invariants.sh` — new `ENFORCE_C31`, `ENFORCE_C32`, `ENFORCE_C20_DECL`
  flags (all default 1); new C31 and C32 blocks (after C30, before C9-DOCS), each with an inline
  fixture self-test and exit-2 anti-silence guards; C20 gains the declaration-span assertion, a
  pinned regression case, the recorded-baseline comparison, and `TODO` lines for the recorded
  mismatches and the name-less residual; header check list and companion-file list updated.
- `scripts/lib/lean_citations.py` — created. The single reading of "named citation",
  "declaration span" and "name chain", with fixtures including the double-shift shape. Imported
  by C20 and by the re-anchor tool so the gate and its repair cannot disagree.
- `scripts/lib/lean_debug_artifacts.py` — new `comments_only` view of the existing masker scan
  (C32 reads comment text through it); self-test extended.
- `scripts/reanchor-lean-citations.py` — `--selftest` grows from 2 probes to 5 (3: doubled Δ
  pass, `--recompute`, second `--recompute` is `0 across 0`; 4: the content-edited-line blind
  spot, asserted as a documented limitation; 5: doubled Δ pass over a +40 edit is detected and
  repaired by `--by-name`, second run `0 across 0`); new idempotent `--by-name` mode;
  `recompute` split into a counting core and a printing wrapper.
- `scripts/c20-declaration-baseline.txt` — created with 327 keys, pruned to 10.
- 69 `.lean` files under `FormalSystem/` — citation numbers only (315 re-pointed by `--by-name`,
  1 collapsed continuation and 1 false positive fixed by hand, 9 name-less citations into
  `Syntax/Formula.lean` / `Kamp/KPlusFaithful.lean` given names). Every edit is
  line-count-neutral (`git diff --numstat`: equal insertions and deletions in all 69 files).
- `docs/development/MODULE_INVARIANTS.md` — C20, C31, C32 rows; a companion-file section for the
  baseline; the three deliberate negative tests recorded under "Adding a Check".
- `docs/development/REFERENCE_NORMAL_FORM.md` — §2 "C31 gates this" pointer and the
  name-before-anchor rule; §4 rewritten to distinguish the Δ pass (not idempotent) from
  `--recompute` and `--by-name` (both idempotent, both asserted by `--selftest`); six §5
  baseline rows.

## Decisions

- **C31 and C32 ship enforced from the outset.** The tree was clean on both (215 block
  citations over 22 keys, 0 dangling; 8 path-shaped links, 0 broken).
- **C32's path-shaped filter is load-bearing.** Measured: 82 link-shaped matches, 71 of them
  inline mathematics, 3 external, 8 real. All three counts print in the `PASS` line so filter
  drift is visible.
- **The C20 declaration-span assertion ships enforced against a recorded baseline**, not
  report-only, on the `scripts/nolints.json` precedent. Baseline keys carry no line number, so
  a legitimate re-anchoring pass does not invalidate them.
- **Only a name standing immediately before a citation can FAIL it;** a name elsewhere in the
  sentence can only PASS it. Names declared nowhere in the target file (constructors, fields,
  binders) are UNVERIFIABLE, never failed, never guessed.
- **A repair target is offered only when the name chain and the anchor group are the same
  length.** Found the hard way: a two-anchor group behind a one-name chain was collapsed onto one
  line by the first `--by-name` run and fixed by hand; the rule and a fixture now prevent it.

## Plan Deviations

- **Task 2.4** altered: comment text comes from a new `comments_only` view in
  `scripts/lib/lean_debug_artifacts.py` (one extra file) rather than a scanner re-derived inside
  the C32 block.
- **Task 4.7** altered: the tree was NOT clean on the assertion's first run (327 mismatches), so
  the plan's contingency was report-only with the flag at 0. It ships enforced against a
  recorded baseline instead, so a new mismatch fails today. The span definition was not widened.
- **Non-goal re-opened**: the plan excluded a name-alignment mode from the re-anchor tool unless
  implementation surfaced a failure of content alignment. It did: 327 citations were already
  stale at `HEAD`, which no revision-relative pass can repair. `--by-name` was added.
- **Task 5.3** altered: scope widened from the three named files to every named mismatch in the
  tree. The three named files held only 3 mismatches and 11 name-less citations, and the plan's
  `FormalSystem/Theorems/DerivedAxioms.lean` is not a citation target at all (the tree cites
  `FormalSystem/ProofSystem/DerivedAxioms.lean`).
- **Task 6.3 / 6.5**: `MODULE_INVARIANTS.md` had no existing C20 row and has no header check
  list, so a C20 row was added rather than extended, and only the harness header was updated.

## Verification

- Build: Success — `lake build` 2651 jobs green after the docstring edits; build-inclusive
  `bash scripts/check-module-invariants.sh` exit 0, `ALL CHECKS PASSED` (C1, C2, C6, C16, C24,
  C25 included); `--emit-inventory --check` reports zero byte changes
- Tests: `bash scripts/check-module-invariants.sh --no-build` exit 0 after every phase;
  `python3 scripts/reanchor-lean-citations.py --selftest` exit 0, five probes green
- Negative tests (FAIL line **and** non-zero exit, then PASS and exit 0 after revert):
  C31 `thomason1984` → `thomason1985`; C32 `Commands.lean` → a stale `Logos/...` path; C20
  declaration span `KPlusFaithful.lean:393` → `:300` beside a chain-named declaration
- `--recompute` twice: second run `recomputed 0 citation line(s) across 0 citer file(s)`
- C20 tier 1: 1028 resolvable / 0 unverifiable, unchanged
- `readme-lint.sh` 21 broken references; `typst-sync-check.sh` 9 Check-1 violations, 0 on
  Checks 2/2b/3 — all unchanged
- Files verified: Yes

## Impacts

- A double-shifted or otherwise wrong-declaration citation now fails the gate when it names its
  declaration and the shift exceeds that declaration's span.
- Anyone adding a `[key]` to a `## References` block, or a relative markdown link to a Lean
  docstring, gets a gate failure instead of a silent dangling pointer.
- 69 Lean files had docstring-only edits, so the next `lake build` recompiles them and their
  dependents once.

## Follow-ups

- **Residual, recorded**: 155 of 1028 `file.lean:NNN` citations carry no declaration name (was
  164); 40 more are unverifiable. Per file for the named targets: `Syntax/Formula.lean` 2 of 29
  (both of the form `` `Formula.kPlus P` ``, which is not a bare identifier),
  `Kamp/KPlusFaithful.lean` 0 of 81, `ProofSystem/DerivedAxioms.lean` 0 of 2 (1 unverifiable).
- **10 baseline keys** need a reader: two names before one anchor, or a name fragment such as
  `_correct`. `--by-name` reports them `SKIPPED`.
- **Known limit**: a citation whose only name is elsewhere in its sentence can never FAIL (the
  pinned `PriorExpressivenessDense.lean` case is one). A rise in the printed name-less residual
  is the only signal; gating that count is a possible follow-up.
- The 11 advisory unused `references.bib` entries are listed by C31 at every gate.

## References

- specs/643_citation_gates_bibkeys_links_and_line_anchors/plans/01_citation-gates-bibkeys-links.md
- specs/643_citation_gates_bibkeys_links_and_line_anchors/reports/01_citation-gates-bibkeys-links.md
- docs/development/MODULE_INVARIANTS.md
- docs/development/REFERENCE_NORMAL_FORM.md
