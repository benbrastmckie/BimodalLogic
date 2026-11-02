# Research Report: Task #828

**Task**: 828 - Metalogic upward-edge allowlist count drift (CI red on `main`)
**Started**: 2026-11-02T22:00:00Z
**Completed**: 2026-11-02T22:24:00Z
**Effort**: small (4 files, mechanical count/list edits, no `.lean` changes)
**Dependencies**: None
**Sources/Inputs**: Codebase (`scripts/check-metalogic-cycles.sh`, `scripts/measure-refactor-partitions.py`, `docs/ARCHITECTURE.md`, `ORGANISATION.md`, `.github/workflows/ci.yml`), `git log`/`git show` history, direct execution of `scripts/check-metalogic-cycles.sh` and `scripts/check-module-invariants.sh --no-build`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Re-ran `bash scripts/check-metalogic-cycles.sh` directly: it exits 1 today, with exactly the
  `SURPLUS FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.LinearityDerived`
  line the task description names. All of the task description's filing-time claims about the
  *current* state are confirmed except one: the provenance claim is off by one commit (see
  Decisions).
- `python3 scripts/measure-refactor-partitions.py upward-edges` confirms 8 upward lines, all
  `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.*`, alphabetically:
  `Combinators`, `DedekindDerived`, `DeductionTheorem`, `DiscreteUnfolding`,
  `GeneralizedNecessitation`, `LinearityDerived`, `Propositional.Core`, `TemporalDerived`.
- The fix is purely textual/data (no `.lean` file in scope): add one entry to the
  `ALLOWLIST` frozenset in `scripts/check-metalogic-cycles.sh`, and change every "seven"/"7"
  count tied to that allowlist in the same file, in `scripts/measure-refactor-partitions.py`'s
  module docstring and comments, in `docs/ARCHITECTURE.md`, and in `ORGANISATION.md` — eleven
  textual occurrences total across the four in-scope files, enumerated below with exact current
  line numbers.
- `bash scripts/check-module-invariants.sh --no-build` exits 0 today (`ALL CHECKS PASSED`),
  independent of this drift — confirms the acceptance criterion's second half is already true
  and unaffected by the fix (no file in `FILE SCOPE` participates in any of those checks'
  subject matter).
- Two more live "seven"/"7-line allowlist" mentions exist **outside** the dispatch's declared
  `FILE SCOPE` and outside the literal `ACCEPTANCE` wording (which names only
  `docs/ARCHITECTURE.md` and `ORGANISATION.md`): `scripts/README.md:18` and two spots in
  `docs/development/PUBLICATION_REFACTOR.md` (a completed-phase program record). Flagged as a
  residual-scope note, not a blocker — see Context Extension Recommendations.

## Context & Scope

The task is a CI-red fix: `scripts/check-metalogic-cycles.sh` asserts that the library's
upward-import set (library modules importing a module in a higher architectural layer) equals
a hand-recorded allowlist. A ninth commit on `main` added an eighth upward import line without
updating the allowlist or the three places that narrate the count in prose ("seven lines"). The
task description already names the fix shape (add the allowlist entry; update the docs) and
gives filing-time evidence for the claims; this research phase's job is to **re-verify every
cited fact independently** (the dispatch's own "STANDING INSTRUCTION — RE-VERIFY BEFORE CITING")
and to locate every exact edit site a plan will need, not to make the edits (no `.lean`, `.py`,
`.sh`, or `.md` file was modified during this research pass).

Scope is bounded to the four files the dispatch's `FILE SCOPE` names:
`scripts/measure-refactor-partitions.py`, `scripts/check-metalogic-cycles.sh`,
`docs/ARCHITECTURE.md`, `ORGANISATION.md`. No `FormalSystem/*.lean` file needs to change — the
eighth edge is accepted as a legitimate member of the already-documented class (`AxiomDischarge`
consuming derived `Theorems/*` schemata), not a layering violation to fix by relocation.

## Findings

### Codebase Patterns

**The failure, reproduced directly** (2026-11-02, this session):

```
SURPLUS  FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.LinearityDerived
FAIL  upward import set is not the recorded allowlist (1 surplus, 0 shortfall)
```

`check-metalogic-cycles.sh` exits 1. Its other two assertions (A: exactly one Metalogic
directory-level cycle; C: no language-directory syntax module imports a semantics module) both
still PASS — this is purely assertion B's allowlist equality failing.

**The measured upward set** (`python3 scripts/measure-refactor-partitions.py upward-edges`,
re-run this session): 8 import lines total, all `FormalSystem.MinusLanguage.AxiomDischarge ->
FormalSystem.Theorems.*`:

| # | Target | Already in `ALLOWLIST`? |
|---|--------|--------------------------|
| 1 | `Combinators` | yes |
| 2 | `DedekindDerived` | yes |
| 3 | `DeductionTheorem` | yes |
| 4 | `DiscreteUnfolding` | yes |
| 5 | `GeneralizedNecessitation` | yes |
| 6 | **`LinearityDerived`** | **no — the surplus** |
| 7 | `Propositional.Core` | yes |
| 8 | `TemporalDerived` | yes |

The import is at `FormalSystem/MinusLanguage/AxiomDischarge.lean:16`
(`import FormalSystem.Theorems.LinearityDerived`), used three times in that file: `:277`
(`LinearityDerived.tempLinearityLegacyAt`), `:320`/`:324` (`LinearityDerived.density`).

**Why it is a legitimate eighth member of the class, not a layering violation**: the file is
layer 0 by `LANGUAGE_FILE_LAYERS` (its pre-merge origin was `Syntax/MinusLanguage/`), and
`Theorems/*` is layer 2 by `LAYERS`. Every one of the 8 edges is `AxiomDischarge` discharging an
L⁻ axiom through a derived L theorem — the same documented pattern the existing 7 already
record (see `scripts/check-metalogic-cycles.sh:55-61`, `ORGANISATION.md:51-56`). No content
judgement changes; the fix is additive to the allowlist, not a reclassification.

### Exact Edit Sites (re-verified this session, current line numbers)

**1. `scripts/check-metalogic-cycles.sh`** — one data change, three prose counts:
- Lines 191-199: the `ALLOWLIST` frozenset itself (the data source of truth). Current members,
  in order: `Combinators`, `DedekindDerived`, `DeductionTheorem`, `DiscreteUnfolding`,
  `GeneralizedNecessitation`, `Propositional.Core`, `TemporalDerived` (alphabetical). Needs
  `"LinearityDerived"` inserted between `"GeneralizedNecessitation"` and `"Propositional.Core"`
  to keep alphabetical order.
- Line 55: `#   THE ALLOWLIST HOLDS 7 LINES, all ...` → 8.
- Line 56: `#   a `Theorems` module (layer 2). ... The same 7 lines were recorded` → 8.
- Line 186: `# The recorded allowlist: 7 lines, all from ...` → 8.

**2. `scripts/measure-refactor-partitions.py`** — module-docstring and comment prose only; the
`LAYERS` and `LANGUAGE_FILE_LAYERS` data tables themselves need **no** change (AxiomDischarge is
already layer 0, Theorems already layer 2 — the table already classifies the edge correctly; only
the allowlist equality check lives elsewhere, in `check-metalogic-cycles.sh`):
- Line 49: `upward-edges  7 import lines in total, one class, MinusLanguage ->` → 8.
- Line 51: `importing 7 Theorems modules (layer 2).` → 8.
- Line 57: `that the upward set EQUALS its recorded 7-line` → 8-line.
- Line 175: `whose 7 imports of Theorems are the whole measured upward set` → 8.
- Line 179: `The 7 lines are recorded, not excused.` → 8.

**3. `docs/ARCHITECTURE.md`**:
- Line 58 (heading): `### The upward set: seven lines, all from one file` → eight lines.
- Line 60: `The library has **seven** measured upward import lines ...` → eight; and the
  parenthetical list of theorem names 2 lines later (`Combinators`, `DedekindDerived`,
  `DeductionTheorem`, `DiscreteUnfolding`, `GeneralizedNecessitation`, `Propositional.Core`,
  `TemporalDerived`) needs `LinearityDerived` inserted in alphabetical position (between
  `GeneralizedNecessitation` and `Propositional.Core`).
- Line 67: `These are the same seven lines the file carried as ...` → eight.
- Line 71: `... and the seven lines are back under their new path.` → eight.
- Line 186: `including the one count on this page (the seven` → eight.
- Line 191 (bash comment inside the fenced verification block): `# upward set is exactly the 7
  recorded lines, AND` → 8.

**4. `ORGANISATION.md`**:
- Line 51: `**The measured upward set is 7 import lines**` → 8.
- Line 52: `All 7 run from` → All 8.
- Line 219 (bash comment inside the fenced verification block): `# the recorded 7 AxiomDischarge
  lines (fails on a surplus AND on a shortfall)` → 8.

That is 11 textual count/list occurrences across the four in-scope files, plus the one data
change to the `ALLOWLIST` frozenset — twelve edits in total, all mechanical.

### Verification of Acceptance Criteria (current state, before any fix)

- `bash scripts/check-metalogic-cycles.sh` — **exits 1** today (confirmed above); will exit 0
  once the allowlist gains the `LinearityDerived` entry (the prose-count edits do not affect the
  exit code — they are pure documentation drift that would otherwise persist even after the gate
  goes green).
- `bash scripts/check-module-invariants.sh --no-build` — **exits 0** today, `ALL CHECKS PASSED`.
  Counted PASS lines: **46**, not 47 as the task description states. This is not a discrepancy to
  fix: the run includes `INFO C36b skipped (--no-build)` — C36b is a lake-build-dependent check
  that is skipped (not a FAIL) under `--no-build` and would be a 47th PASS line under a full
  build. The substantive claim ("still exits 0") holds either way and is orthogonal to this
  task's four in-scope files (none of C1-C37 reads `check-metalogic-cycles.sh`,
  `measure-refactor-partitions.py`, `docs/ARCHITECTURE.md`, or `ORGANISATION.md`).
- "no count anywhere in `docs/ARCHITECTURE.md` or `ORGANISATION.md` still says seven upward
  lines" — verified via `grep -n "seven\|7 line\|7 recorded\|upward"` against both files (see
  Exact Edit Sites above); no other "seven"/count-bearing line exists in either file beyond the
  ones enumerated.

### CI Gate Mechanics (re-verified against `.github/workflows/ci.yml`)

- The `check-metalogic-cycles.sh` step: `id: metalogic-cycles` at line 175,
  `continue-on-error: true` at line 176 (task description cited "174-181"; off by one line on the
  `id:` line, same step).
- The aggregating "Report results" step starts at line 298 (`expected=9` at line 313); it reads
  `steps.metalogic-cycles.outcome` at **line 341** (exact match to the task description's
  citation) via the `report "check-metalogic-cycles.sh" "${{ steps.metalogic-cycles.outcome }}"`
  line.
- The job-failing `exit 1` for `$failed -gt 0` is at line 350, and the `$seen -ne $expected`
  guard's `exit 1` is at line 271/279 depending on which guard (task description cited
  "352-356"; the two relevant `exit 1` lines in this gate are 350 and 355 in the current tree —
  within one or two lines of the cited range, same mechanism).
- Mechanism confirmed exactly as described: every check step uses `continue-on-error: true`
  (collect-then-fail-once pattern, explained in the workflow's own comment at lines 283-296), so
  a per-step failure is easy to miss without the aggregating gate — which does correctly turn
  this `FAIL` into a job failure via the `outcome` (not `conclusion`) field.

## Decisions

- **The eighth edge is accepted as a legitimate member of the existing allowlist class** (same
  file, same documented pattern: `AxiomDischarge` axiom-discharge proofs reaching for derived
  `Theorems/*` schemata) rather than treated as a layering violation requiring relocation. This
  matches the task description's own framing and this research pass found no fact that would
  overturn it — the import and all three of its usages are substantively identical in kind to
  the other seven (discharging an L⁻ axiom via a derived L-logic theorem).
- **Provenance correction**: the task description attributes the edge's arrival to commit
  `ba6c0f5dd` ("task 788 phase 6: repoint Conservativity, Plus/C bridges, Independence pins,
  tests and tooling to the derived schemata"). Re-verification via `git log --follow -p` on
  `FormalSystem/MinusLanguage/AxiomDischarge.lean` and `git show` on both commits shows the
  `import FormalSystem.Theorems.LinearityDerived` line, and its first *usage* (`TL` rewired to
  `Theorems.LinearityDerived.tempLinearityLegacy`), were actually introduced 11 minutes earlier
  in commit **`078e6109fe377845050644eaf5e25df424c62ab0`** ("task 788 phase 5: repoint core,
  engines and automation to the derived schemata; move the dependent mirrors", 2026-10-14
  11:13:25 -0700). Commit `ba6c0f5dd` (11:24:13, same day) is a sibling phase of the same task
  788 batch that added a *second* usage of the already-imported module (rewiring `DN` to
  `LinearityDerived.density`) — it did not add the import line itself, since `git show ba6c0f5dd
  -- FormalSystem/MinusLanguage/AxiomDischarge.lean` shows no diff hunk touching the import
  block (unchanged context only). This means the drift has existed since 2026-10-14, roughly
  three weeks, not since whatever the exact `ba6c0f5dd` timestamp would imply — consistent with
  the task description's own "WHY THIS IS NOT A SOFT WARNING" explanation of why a
  `continue-on-error`-gated failure is easy to miss for an extended period. This correction does
  not change the deliverable, the acceptance criteria, or the file scope; it only corrects which
  of two sibling commits (both "task 788", phases 5 and 6, 11 minutes apart) is cited as origin,
  should a plan or summary want to cite it.
- No `.lean` file needs editing; the fix is confined to the four `FILE SCOPE` files via additive
  allowlist entry plus synchronized prose-count corrections.

## Recommendations

1. In `scripts/check-metalogic-cycles.sh`, add `"LinearityDerived"` to the `ALLOWLIST` frozenset
   (lines 191-199) in alphabetical position, and change the two "7"/"seven" counts in the header
   comment (lines 55-56) and the inline comment (line 186) to 8.
2. In `scripts/measure-refactor-partitions.py`, update the five prose-count occurrences at lines
   49, 51, 57, 175, 179 from 7 to 8. Do not touch `LAYERS` or `LANGUAGE_FILE_LAYERS` — both
   already classify `AxiomDischarge` (layer 0) and `Theorems` (layer 2) correctly; the drift is
   entirely in prose counts and in the separate `ALLOWLIST` data structure in the other script.
3. In `docs/ARCHITECTURE.md`, update the heading and three count mentions at lines 58, 60, 67,
   71, 186, and the bash-comment count at line 191, and insert `LinearityDerived` into the
   alphabetical theorem-name list that follows line 60.
4. In `ORGANISATION.md`, update the two count mentions at lines 51-52 and the bash-comment count
   at line 219.
5. Make the allowlist edit and all documentation-count edits in the same change (per the task
   description's own instruction) — a plan that splits them across phases risks landing one half
   and leaving the gate red (if the allowlist edit lands alone, the gate goes green but the docs
   still say seven; if the docs land alone without the allowlist edit, the gate is still red).
   A single implementation phase covering all four files, verified at the end by re-running
   `bash scripts/check-metalogic-cycles.sh` (expect exit 0) and the four-file grep for stray
   "seven"/"7 line" mentions (expect none), is sufficient — no phased plan is needed given the
   small, mechanical, and non-dependent nature of the edits.
6. Re-run `bash scripts/check-module-invariants.sh --no-build` once after the edits purely as a
   regression check (expected: unchanged, still green) — not because these files participate in
   any of its checks, but because it is named in the task's own `ACCEPTANCE` line.

## Risks & Mitigations

- **Risk**: inserting the new allowlist entry out of alphabetical order, or in the wrong case
  (`Propositional.Core` has a dot; `LinearityDerived` does not), silently passes the Python
  `frozenset` (set membership does not care about order) but breaks readability/diff-review
  expectations set by the existing convention. **Mitigation**: insert at the position given
  above (between `GeneralizedNecessitation` and `Propositional.Core`); this is cosmetic, not
  functionally required, since a `frozenset` literal's insertion order never affects program
  behavior — note this explicitly for the implementer so they are not surprised the gate would
  pass either way.
- **Risk**: a prose-count edit is missed in one of the four files, leaving a stray "seven"
  claim that the ACCEPTANCE criterion explicitly checks for. **Mitigation**: the Exact Edit
  Sites section above was produced by exhaustive `grep -n` against both files for every
  "seven"/"7 line"/"7 recorded"/"upward" token; a post-edit re-grep with the same patterns
  against both files (expect zero hits mentioning "seven" or an unqualified "7" in the upward-set
  context) is cheap confirmation.
- **Risk**: over-reaching into `scripts/README.md` or `docs/development/PUBLICATION_REFACTOR.md`
  (see Context Extension Recommendations) under the belief that "no count anywhere" in the
  `ACCEPTANCE` line means repo-wide. **Mitigation**: the `ACCEPTANCE` line's wording is scoped to
  "`docs/ARCHITECTURE.md` or `ORGANISATION.md`" specifically, matching `FILE SCOPE`'s four-file
  list; the two residual mentions are out of scope for this task and should be left alone unless
  a future task (or this task's own planner, by explicit judgment call) chooses to widen scope.

## Context Extension Recommendations

- **Topic**: residual "seven-line allowlist" mentions outside this task's `FILE SCOPE`.
- **Gap**: `scripts/README.md:18` (a live per-script reference-table row describing
  `check-metalogic-cycles.sh`'s current behavior) and `docs/development/PUBLICATION_REFACTOR.md`
  (two mentions, at the point in its Phase-5 "Status: LANDED" narrative and its Phase-5 bullet
  list, describing the allowlist as it stood when that historical program-record text was
  written — correctly 7 lines at that time, before the 2026-10-14 `078e6109fe`/`ba6c0f5dd`
  commits) both still say "7". Neither is in this task's `FILE SCOPE` or named by its
  `ACCEPTANCE` line, so neither was touched or needs touching by this task.
- **Recommendation**: no action needed for `PUBLICATION_REFACTOR.md` — it is a dated program
  record of a now-completed phase and its count was accurate when written, not a live invariant
  statement; updating it would be exactly the kind of after-the-fact historical rewrite this
  repository's conventions elsewhere caution against for record-type documents. `scripts/README.md:18`
  is a live description (not a historical record) and will itself drift again the next time the
  allowlist count changes; if a future task wants to eliminate this entire class of
  "count-stated-in-prose-in-N-places" drift, the durable fix is to make `scripts/README.md`'s
  row (and any future doc mention) report the count via `len(ALLOWLIST)`-style generation or a
  single cited source of truth, rather than a third hand-typed number — but that is a
  structural follow-up, independent of and larger than this task's narrow count-correction scope.

## Appendix

Search queries / commands used (all read-only, no file modified):
- `bash scripts/check-metalogic-cycles.sh` (direct re-run; confirmed FAIL/SURPLUS)
- `python3 scripts/measure-refactor-partitions.py upward-edges` (confirmed 8 edges)
- `sed -n` / `grep -n` across `scripts/check-metalogic-cycles.sh`,
  `scripts/measure-refactor-partitions.py`, `docs/ARCHITECTURE.md`, `ORGANISATION.md` for every
  "seven"/"7 line"/"upward"/"LinearityDerived" occurrence
- `bash scripts/check-module-invariants.sh --no-build` (confirmed `ALL CHECKS PASSED`, 46 PASS
  lines + 1 skipped-under-`--no-build` INFO line)
- `git log -1 --format="%H %s" ba6c0f5dd`; `git show ba6c0f5dd -- FormalSystem/MinusLanguage/AxiomDischarge.lean`
- `git log --follow -p -- FormalSystem/MinusLanguage/AxiomDischarge.lean` (located the actual
  origin commit `078e6109fe`)
- `git show 078e6109fe -- FormalSystem/MinusLanguage/AxiomDischarge.lean`
- `grep -n` across `.github/workflows/ci.yml` for the `metalogic-cycles` step id, the aggregating
  "Report results" step, and its `outcome`-reading/`exit 1` lines
- `grep -rn "seven.*upward\|upward.*seven\|7.*upward\|7-line allowlist\|recorded 7\|seven lines"`
  repo-wide (excluding `specs/`) to locate residual out-of-scope mentions
