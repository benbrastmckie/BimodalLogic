# Implementation Summary: Relicense to Apache-2.0 and Add Copyright Headers

- **Task**: 292 - add_copyright_headers_to_all_source_files
- **Plan**: `specs/292_add_copyright_headers_to_all_source_files/plans/01_relicense-apache-add-headers.md`
- **Status**: all 7 phases COMPLETED
- **Type**: lean4
- **Session**: sess_1784999032_8d6f8f_292

## What Was Done

Seven phases, seven commits, each ending on a green build:

| Phase | Commit | Result |
|-------|--------|--------|
| 1 Relicense | `7ac2f1dd5` | `LICENSE` GPL-3.0 -> Apache-2.0; README License section; zero `.lean` files |
| 2 Tooling | `7e0a69373` | `--exclude` added to the checker; `add-copyright-headers.sh` written; dry run verified |
| 3 Hand-repair | `7f80a4eee` | 2 stale headers replaced by deletion-then-write |
| 4 Tier 1 | `bef96367b` | 45 small-subtree files |
| 5 Tier 2 | `695234930` | 34 `Automation/` files |
| 6 Tier 3 | `4f10a53fa` | 198 `Metalogic/` files |
| 7 Verification | (this commit) | full battery re-run from scratch; summary written |

## The Relicensing, and Why It Had to Come First

The header text asserts *"Released under Apache 2.0 license as described in the file LICENSE."*
Before Phase 1 that statement was **false**: `LICENSE` was a 19-line GNU GPL v3 notice and
`README.md:223` said "This project is licensed under GPL-3.0." Writing the header into 279 files
under a GPL `LICENSE` would have made a false license assertion in each one. The relicensing was
explicitly authorized by the user as sole copyright holder, and it lands in its own commit touching
zero `.lean` files — so it is separately reviewable, and the headers can be reverted without
reverting the relicense. That ordering is the safe one: Apache `LICENSE` with no headers is
consistent; headers over a GPL `LICENSE` is not.

`LICENSE` is now the complete, unmodified 201-line standard Apache License 2.0 text plus a trailing
`   Copyright (c) 2025 Benjamin Brast-McKie` attribution line (203 lines total). The text was not
reproduced from memory: it was copied from the Apache-2.0 file shipped **byte-identically** by seven
independent lake dependencies (`batteries`, `aesop`, `Qq`, `plausible`, `importGraph`,
`proofwidgets`, `LeanSearchClient`), and the copy was verified identical over all 201 lines after
installation. Mathlib's copy was deliberately **not** used: it alters the appendix placeholder
brackets from `[]` to `{}`.

## The Header Format — Three Ways the Task Description Was Wrong

The task description specified a header that would fail Mathlib's `copyrightHeaderChecks`. The
verified form actually used is:

```
/-
Copyright (c) YYYY Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/
```

| Task description said | Correct value | Why |
|-----------------------|---------------|-----|
| `--` line comments | `/- -/` block | The `--` variant was tested against Mathlib's checker and rejected |
| "The Bimodal Logic Contributors" | `Benjamin Brast-McKie` | Holder is the individual, per the research report |
| `2024` | per-file git creation year | 2024 predates the repo's first commit |

Year distribution over the 279 live files: **31** at 2025, **248** at 2026.

## Scope: 279 Live, 151 Archived

There are **two** Boneyard directories, not one:

- `Theories/Bimodal/Boneyard/` — 89 files
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` — 62 files

A skip predicate keyed on the top-level path alone would have wrongly headered the 62 nested files.
Both scripts therefore apply two independent predicates: path matching `*/Boneyard/*` **and**
absence of a line-initial `#exit`. Verified: all 151 archived files carry `#exit`, and **zero**
files with `#exit` exist outside the two trees, so either predicate alone would suffice and the
pair is a genuine cross-check. Confirmed at apply time that all 62 Metalogic skip-list entries lay
under `Kamp/Boneyard/`.

`Automation/` (35 files) is in scope — live compiled code behind 12 `lean_exe` targets.

## The Two Hand-Repaired Files

`Theories/Bimodal/Automation/TraceExporter.lean` and
`Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` both carried a stale
`Copyright (c) 2026 BimodalLogic contributors. / Released under the project's standard license.`
block. Prepending to them would have produced a double header. They were repaired by hand in
Phase 3, **before** any batch write, and the batch script's safety predicate independently refuses
any file containing a line-initial `Copyright (c) ` — which is why both files appear as expected
safety skips in the Phase 5 and Phase 6 dry runs.

## Verification: `linter.style.header` Silence Is Not Evidence

**Mathlib's `linter.style.header` is a false negative in this repo and its silence proves nothing
— not that headers are right, not that they are present.** Its gate `isInLibraryRoot` resolves
`<root>.lean` against the CWD, but the lakefile sets `srcDir := "Theories"`, putting the library
root at `Theories/Bimodal.lean`; `./Bimodal.lean` does not exist, so the linter no-ops on every
file. A `./Bimodal.lean` symlink is **not** a fix and must not be retried: `isInLibraryRoot` checks
*direct* imports only, so the linter would then fire on `Bimodal.Bimodal` alone.

Verification is instead `scripts/check-copyright-headers.sh`, whose duplicate predicate counts
`^Copyright (c) ` across the **whole file** before validating the leading block — a checker that
validated only the leading block would silently pass a double-headered file.

Final battery, all passing:

- `check-copyright-headers.sh --strict --exclude '*/Boneyard/*' Theories` exits **0**:
  `conforming: 279, nonconforming: 0, duplicate: 0, missing: 0, total: 279`.
- Unexcluded run: `conforming: 279, missing: 151, total: 430`, and `missing.txt` contains
  **only** Boneyard paths (0 non-Boneyard entries).
- Exactly one `^Copyright (c) ` line in every one of the 279 touched files — 0 violations.
- Diff vs. the pre-Phase-3 commit: **279** files changed, all `.lean`, 1668 insertions,
  **4** deletions. Zero Boneyard files in the diff. Zero stray `*.hdr.*` temp files.
- `lake build` exits **0**: 0 errors, 1877 jobs, exactly **12** ``declaration uses `sorry` ``
  warnings in `Bundle/SuccRelation.lean` (7), `Bundle/SuccExistence.lean` (3),
  `BXCanonical/Chronicle/ChronicleToCountermodel.lean` (1), `WeakCanonical/Transfer.lean` (1).
- No axiom introduced and no vacuous definition introduced: the 2 `^axiom ` grep hits are prose
  inside Boneyard comments and the 1 `:= trivial` hit is a pre-existing genuine one-liner
  (`int_domain_universal`), all three byte-identical to the pre-task baseline `48b72b230` modulo
  the +6 line shift.
- Toolchain unchanged at `v4.33.0-rc1`; `CLAUDE.md` and `lean-toolchain` untouched.

An additional, independent check that the write was a pure line-1 prepend: all 12 sorry warnings
stayed in the same 4 files with every line number shifted by exactly **+6**, the header block's
height (5 lines plus one blank). A write landing anywhere but line 1 could not produce a uniform
shift.

## Plan Deviations

1. **Phase 3 deletion count: 4, not 8.** The plan predicted "8 total deletions (4 per file)" for
   the hand-repairs. Measured: **4** (2 per file). Both the stale and the replacement block open
   with `/-` and close with `-/`, so git's minimal diff keeps those as context and counts only the
   2 changed middle lines; `git diff --numstat` reports `3 2` per file. The plan's figure is
   arithmetically wrong. The invariant it stood for — no deletion outside those 2 files — holds,
   and Phases 4-7 were verified against the corrected value.
2. **Phases 5 and 6 safety flags: 1, not 0.** The plan expected 0 safety-predicate flags in each.
   Each run flagged exactly 1 — the Phase-3-repaired file in that subtree. This is correct: the
   predicate refuses any file with a copyright line, conforming or not. A count of 0 would have
   meant the double-header guard was blind to the repaired file.
3. **Sorry-warning grep string corrected.** Lean emits ``declaration uses `sorry` `` with
   **backticks**; the plan and task description both write straight quotes. Grepping the
   straight-quoted form returns **zero** matches against a log containing all 12 warnings — the
   plan's literal verification string is itself a false-negative trap. All phases were verified
   with the backtick form.
4. **Cumulative diff measured against `7e0a69373`** (the Phase 2 commit), not a bare `git diff`.
   Because each phase commits, a bare `git diff` shows only the current phase's files; the plan's
   "cumulative" criteria are only meaningful against the pre-Phase-3 commit.
5. **Discovery sweep filter was broken as written.** The plan's
   `grep -v -E '^\./(\.lake|\.git|specs|\.claude)/'` never matches, because `grep -rn ... .` emits
   paths without a `./` prefix, so `specs/` hits leaked into the inventory. Re-run with
   `grep -vE '(^|\./)(...)/'`. Both forms were run and the union recorded in the plan's Phase 1
   notes.
6. **Two anticipated discovery sites did not exist.** `docs/research/*.md` third-party license
   table (plan item 4): `docs/` contains **zero** license mentions of any kind. And the plan's own
   sweep patterns cannot match the `Tests/*.lean` "Released under the project's standard license."
   lines (plan item 5) — those were confirmed present by direct grep instead. No action on either,
   per plan.
7. **Phase 6 re-split contingency not exercised** — the single-pass 198-file run did not stall.

No site beyond the plan's five known ones was found by the sweep.

## Deliberate Non-Actions (per plan)

- `Theories/Bimodal/typst/BimodalReference.typ:10,111` keep their
  `Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.` notices — a deliberate prior
  decision for the reference *manual*. The carve-out is now stated explicitly in the README License
  section rather than left as a silent contradiction.
- `Tests/BimodalTest/{TraceExporterE2ETest,TraceCertificateTest,TraceExportTest}.lean:3` keep
  "Released under the project's standard license." Not falsified by relicensing ("the project's
  standard license" resolves to whatever `LICENSE` says) and out of `file_scope`. **Recorded as a
  follow-up candidate**, not edited.
- The 151 Boneyard files stay unheadered.
- `CLAUDE.md`'s stale Lean version (says v4.27.0-rc1; `lean-toolchain` says v4.33.0-rc1) not
  corrected — out of scope.
- No declaration renamed, no `def` converted to `theorem`.

## Files Changed

- `LICENSE` — full Apache-2.0 replacement (203 lines)
- `README.md` — License section + reference-manual carve-out sentence
- `scripts/check-copyright-headers.sh` — repeatable `--exclude PATTERN`
- `scripts/add-copyright-headers.sh` — new
- 279 `.lean` files under `Theories/` — conforming header prepended at line 1

## Re-runnable CI Gate

```bash
bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' Theories
```

Exits 0 today. Add a file without a header and it exits 1.
