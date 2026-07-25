# Implementation Plan: Relicense to Apache-2.0 and Add Copyright Headers

- **Task**: 292 - add_copyright_headers_to_all_source_files
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/292_add_copyright_headers_to_all_source_files/reports/01_apache-copyright-headers-baseline.md
- **Artifacts**: plans/01_relicense-apache-add-headers.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Relicense the project from GPL-3.0 to Apache-2.0 (user-authorized, sole copyright holder), then
add the cslib/Mathlib-conforming Apache copyright header to the 279 live `.lean` files under
`Theories/`, skipping the 151 `#exit`-guarded Boneyard files. The relicensing lands first and in
its own commit so that the line *"Released under Apache 2.0 license as described in the file
LICENSE."* is true at the moment it is written into any file. Verification is a purpose-written
text checker (`scripts/check-copyright-headers.sh`), not Mathlib's `linter.style.header`, which is
a proven false negative in this repo. Definition of done: checker reports `conforming: 279,
nonconforming: 0, duplicate: 0, missing: 0` over the live set, `git diff --stat` shows exactly 279
files changed with exactly 8 deletions, and `lake build` still exits 0 at 0 errors with exactly 12
`declaration uses 'sorry'` warnings.

### Research Integration

The research report is adopted in full. Its findings that shape this plan:

- **Header format** (report §3) — `/- -/` block, individual holder `Benjamin Brast-McKie`,
  per-file git creation year. Proven against Mathlib's `copyrightHeaderChecks` (took the checker
  from 4 errors to silent). The task description's `--` line-comment format, collective
  "The Bimodal Logic Contributors" holder, and year 2024 are all wrong and are not used.
- **Verification** (report §1, §6) — `linter.style.header` cannot see this repo
  (`isInLibraryRoot` resolves `<root>.lean` against the CWD, but `srcDir := "Theories"` puts the
  root at `Theories/Bimodal.lean`). A `./Bimodal.lean` symlink is **not** a fix: the linter then
  fires only on `Bimodal.Bimodal`, because `isInLibraryRoot` checks *direct* imports only. Do not
  retry the symlink. Do not cite linter silence as evidence of anything.
- **Duplicate predicate** (report §6) — count `^Copyright (c) ` across the **whole file** before
  validating the leading block. A checker that validates only the leading `/- -/` block silently
  passes a double-headered file. The committed checker already does this (lines 44-50).
- **Scope** (report §2b, §7) — 279 live files get headers; 151 Boneyard files are skipped.
  `Automation/` (35 files) is included: it is live compiled code backing 12 `lean_exe` targets and
  is imported by `Bimodal.Bimodal`.
- **Placement** (report §4) — header precedes `import`; build-tested on both the ordinary
  `import`-first shape and the awkward leading-`/-!`-docstring shape. The 10 docstring-first files
  need no special handling.
- **Blocker** (report §5) — resolved by explicit user authorization to relicense to Apache-2.0.
  Recorded here as a binding decision, not an open question.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:

- Replace the repo-root `LICENSE` (currently GNU GPL v3, 19 lines) with the standard full
  Apache-2.0 license text, retaining the `Copyright (c) 2025 Benjamin Brast-McKie` attribution.
- Update `README.md:223` ("This project is licensed under GPL-3.0.") and every other
  this-repo license assertion found by a discovery sweep.
- Add the verified header block to the 279 live `.lean` files under `Theories/`, with the per-file
  git creation year (31 files -> 2025, 248 -> 2026).
- Hand-repair the 2 files carrying a stale non-conforming header, by deletion-then-write, never
  by prepend.
- Keep `lake build` at 0 errors and exactly 12 `declaration uses 'sorry'` warnings.
- Leave a re-runnable, Boneyard-aware verification gate usable in CI.

**DECLARED SCOPE EXTENSION (user-authorized)**: the task's `file_scope` is `Theories/Bimodal/`,
but `LICENSE` and `README.md` are at the repo root. Editing them is a deliberate, explicitly
user-authorized extension of scope — it is the precondition for the header text being true, and
headers must never land first. `Theories/Bimodal.lean` (the library root module, one level above
`Theories/Bimodal/`) is likewise included; the research report's 279-file live set counts it.

**Non-Goals**:

- Fixing the `srcDir`/`isInLibraryRoot` mismatch so `linter.style.header` works. That needs
  `Theories/Bimodal.lean` flattened into a 279-line import list plus a CWD root file — an
  architectural change (report §1). Retrying the symlink is explicitly forbidden.
- Headering the 151 Boneyard files. Inert (`#exit` in 151/151, 0 `.olean`s built, 0 external
  imports); +755 lines of churn that would bury the meaningful diff.
- `Tests/BimodalTest/` (42 `.lean` files, 3 of which say "Released under the project's standard
  license."). Out of `file_scope`; cslib exempts its own test library from the header linter
  (`CslibTests` sets `weak.linter.style.header = false`). Note those 3 assertions do not become
  *false* under relicensing — "the project's standard license" resolves to whatever `LICENSE`
  says. Recommend a trivial follow-up task; do not extend scope here.
- Correcting the stale Lean version in the top-level `CLAUDE.md` (says v4.27.0-rc1;
  `lean-toolchain` says v4.33.0-rc1). Out of scope; do not edit.
- Relicensing the reference manual `Theories/Bimodal/typst/BimodalReference.typ` (see Phase 1,
  discovery item 3, for the recorded decision).
- Adding module docstrings, or any other Mathlib style-linter compliance work.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Naive prepend onto one of the 2 stale-header files produces a doubled header | H | M | Phase 3 repairs those 2 by hand *before* any batch write; the batch script's safety predicate additionally refuses any file containing `^Copyright (c) ` anywhere; the checker's `duplicate` bucket catches it |
| Skip predicate only excludes the top-level `Theories/Bimodal/Boneyard/`, wrongly headering the 62 files in the nested `Metalogic/WeakCanonical/Kamp/Boneyard/` | M | M | Two independent predicates, both required: path match `*/Boneyard/*` (catches both trees) **and** absence of `^#exit`. Verified: 151/151 Boneyard files carry `#exit`; 0 files with `#exit` exist outside the two trees |
| `--strict` gate can never pass, because the checker walks all of `Theories` including the 151 intentionally-skipped Boneyard files | M | H | Phase 2 adds a repeatable `--exclude PATTERN` flag to the checker so `--strict --exclude '*/Boneyard/*' Theories` is a genuine exit-0 gate |
| Bulk write to 277 files goes wrong and is hard to unpick | H | L | `--dry-run` (writes nothing, verified by empty `git diff -- Theories/`) precedes every batch; batches are applied per subtree tier with a `lake build` and a commit after each |
| Header insertion breaks a parse (e.g. lands between an attribute and a declaration) | H | L | Header is only ever prepended at line 1, above all `import` lines — never inserted mid-file. Report §4 build-tested both file shapes. `lake build` after every tier |
| Silent regression in the sorry count or a new warning hides in a 279-file diff | M | L | Every tier's verification asserts 0 errors and exactly 12 `sorry` warnings in the 4 known files, not merely "build succeeded" |
| Per-file year lookup (`git log --diff-filter=A --follow`) returns empty for an untracked file, yielding a malformed year | M | L | Verified 0 untracked `.lean` files under `Theories/`. Script still defaults to 2026 on empty and the dry-run manifest is asserted to have 279 rows all matching `^20[0-9]{2}$` |
| Relicensing leaves an inconsistent license story (some file still asserts GPL) | H | M | Phase 1 opens with a repo-wide discovery sweep rather than assuming `README.md:223` is the only site, and closes with a grep asserting zero remaining GPL assertions |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
phases 4-6 touch disjoint file sets and would be territory-safe in parallel, but each ends in a
`lake build`, and concurrent `lake build` invocations contend on the same `.lake` lock. Serialize
them.

---

### Phase 1: Relicense to Apache-2.0 [COMPLETED]

**Discovery sweep result (recorded verbatim, run 2026-07-25)**

The plan's sweep command has a filter bug: `grep -v -E '^\./(\.lake|\.git|specs|\.claude)/'`
requires a literal `./` prefix, but `grep -rn ... .` emits paths without it, so the `specs/`
exclusion never fired. Re-running with `grep -vE '(^|\./)(\.lake|\.git|specs|\.claude)/'` gives
the intended result. Both forms were run; the inventory below is the union.

Sites found, outside the excluded trees:

1. `README.md:223` — "This project is licensed under GPL-3.0." **Edited** -> Apache-2.0, plus the
   reference-manual carve-out sentence.
2. `Theories/Bimodal/typst/BimodalReference.typ:10` and `:111` — `Copyright (c) 2026 Benjamin
   Brast-McKie. All rights reserved.` **Left unchanged** per the plan's recorded decision; the
   carve-out is now stated explicitly in the README License section.
3. `LICENSE` — not matched by the sweep (extensionless, so outside every `--include`), but a known
   site. **Replaced** with the full standard Apache-2.0 text.

Sites found inside excluded trees (leaked through by the filter bug), all no-action:

4. `specs/literature/README.md:170` — false positive: the *journal name* "Logic J. IGPL" contains
   the substring `GPL`. Not a license assertion at all.
5. `specs/state.json`, `specs/TODO.md`, `specs/179_*/reports/02_mathlib-submission.md`,
   `specs/292_*/reports/01_*.md`, `specs/292_*/plans/01_*.md` — task-management artifacts
   describing the relicensing problem. Out of scope by the sweep's own intent.

Sites the plan anticipated that did **not** reproduce:

- `docs/research/*.md` third-party license table (plan item 4): `docs/` contains **zero** license
  mentions of any kind. No action, nothing to confirm.
- `Tests/BimodalTest/{TraceExporterE2ETest,TraceCertificateTest,TraceExportTest}.lean:3` (plan
  item 5): not matched, because "Released under the project's standard license." contains none of
  the sweep's four patterns. Verified present by direct grep; **no action**, recorded as a
  follow-up candidate.

No site beyond the plan's five known ones was found. `LICENSE` is now the pristine 201-line
standard Apache-2.0 text (byte-identical to the copy shipped by `batteries`, `aesop`, `Qq`,
`plausible`, `importGraph`, `proofwidgets`, and `LeanSearchClient` — 7 independent identical
copies, used in preference to Mathlib's, which alters the appendix placeholder brackets from
`[]` to `{}`) plus a trailing `   Copyright (c) 2025 Benjamin Brast-McKie` attribution line.
203 lines total.

- **Goal:** The repo's license story is Apache-2.0 and internally consistent, *before* any header
  asserts it. Separately reviewable and separately revertable — this phase is a standalone commit
  touching zero `.lean` files.
- **Tasks:**
  - [x] Run the discovery sweep for every this-repo license assertion. Do not assume
        `README.md:223` is the only one:
        ```bash
        grep -rn -iE 'GPL|GNU General Public|licensed under|All rights reserved' \
          --include='*.md' --include='*.typ' --include='*.tex' --include='*.toml' \
          --include='*.json' --include='*.nix' --include='*.yml' --include='*.lean' . \
          | grep -v -E '^\./(\.lake|\.git|specs|\.claude)/'
        ```
        Record the resulting inventory verbatim in the phase notes. Known sites, from the
        pre-plan sweep — treat as a floor, not a ceiling:
        1. `LICENSE` — GNU GPL v3, 19 lines, `Copyright (c) 2025 Benjamin Brast-McKie`.
        2. `README.md:221-223` — `## License` section asserting GPL-3.0.
        3. `Theories/Bimodal/typst/BimodalReference.typ:10` and `:111` — `Copyright (c) 2026
           Benjamin Brast-McKie. All rights reserved.` with no "Released under" line, i.e. an
           all-rights-reserved assertion on the reference *manual*. An archived documentation
           task deliberately chose all-rights-reserved for this manual and recorded that no
           open license was introduced. **Decision: leave the `.typ` notices unchanged** — it is
           a document, not library source, and reversing a deliberate user decision is out of
           scope. Instead make the carve-out explicit in the README License section (next task
           item) so the story is consistent rather than silently contradictory.
        4. `docs/research/*.md` and `specs/literature/README.md` — these describe *third-party*
           projects' licenses (a table of competitor licenses, an Apache-2.0 tool). Not this
           repo's license. **No action**; confirm each hit is third-party before dismissing it.
        5. `Tests/BimodalTest/{TraceExporterE2ETest,TraceCertificateTest,TraceExportTest}.lean:3`
           — "Released under the project's standard license." Not falsified by relicensing and
           out of `file_scope`. **No action**; record as a follow-up candidate.
  - [x] Replace `LICENSE` with the standard full Apache License 2.0 text (the complete
        ~201-line text, not a summary or a URL), retaining the copyright attribution
        `Copyright (c) 2025 Benjamin Brast-McKie` and the standard appendix boilerplate.
  - [x] Update the `README.md` License section to state Apache-2.0, and add one sentence naming
        the reference-manual carve-out from discovery item 3.
  - [x] Apply any further edits the discovery sweep turned up beyond the five known sites. *(deviation: no-op — the sweep found no site beyond the five; see phase notes)*
- **Timing:** 45 minutes
- **Depends on:** none
- **Files to modify:**
  - `LICENSE` — full replacement: GPL-3.0 text -> Apache-2.0 text
  - `README.md` — License section (currently line 223)
  - any additional site the sweep finds
- **Verification:**
  - `grep -rn -iE 'GPL|GNU General Public' --include='*.md' --include='*.typ' . | grep -v -E '^\./(\.lake|\.git|specs|\.claude)/'` returns **zero** hits describing *this* repo's license.
  - `head -3 LICENSE` shows the Apache License header; `grep -c 'Benjamin Brast-McKie' LICENSE` is >= 1; `wc -l LICENSE` is in the 170-210 range (the full text, not a stub).
  - `grep -n -i 'apache' README.md` shows the updated License section.
  - `git diff --stat` shows **zero** `.lean` files changed.
  - Commit this phase alone: `task 292 phase 1: relicense GPL-3.0 to Apache-2.0`.

---

### Phase 2: Header tooling and dry run (no `.lean` writes) [COMPLETED]

**Dry-run result** — every expected number matched on the first run: `targets: 277`,
`skipped boneyard: 151`, `skipped safety: 2` (exactly `Automation/TraceExporter.lean` and
`Metalogic/Decidability/TraceExport.lean`), `manifest rows: 279`, year split `31 2025 / 248 2026`,
`malformed years: 0`. `git diff` and `git status --porcelain` over `Theories/` both empty
afterwards, and zero stray `*.hdr.*` temp files. Checker with the new flag: `total: 279,
conforming: 0, nonconforming: 2, duplicate: 0, missing: 277`.

Note on the two skip predicates: `skipped #exit: 0` is expected, not a failure. The path check
runs first, and the `#exit` set is a strict subset of the Boneyard set (verified independently:
151 files carry `^#exit`, all 151 inside the two Boneyard trees, 0 outside). The `#exit` predicate
is a redundant second guard, which is the point.

- **Goal:** A reviewed, dry-run-verified batch script and a Boneyard-aware verification gate
  exist. Zero bytes written to any `.lean` file in this phase.
- **Tasks:**
  - [x] Add a repeatable `--exclude PATTERN` flag to `scripts/check-copyright-headers.sh`
        (threaded into the `find` at line 78 as `! -path PATTERN`), so
        `--strict --exclude '*/Boneyard/*' Theories` becomes a gate that can actually exit 0.
        Preserve the existing whole-file duplicate predicate at lines 44-50 unchanged — that
        predicate is the reason the checker cannot be fooled by a doubled header.
  - [x] Write `scripts/add-copyright-headers.sh` with:
    - Target selection: `find Theories -name '*.lean' -type f`, minus **both** skip predicates —
      path matching `*/Boneyard/*` **and** files containing `^#exit`. An optional positional
      subtree argument restricts the run to one tier.
    - Per-file year from `git log --diff-filter=A --follow --format='%ad' --date=format:'%Y'
      -- "$f" | tail -1`, defaulting to `2026` when empty. Written to a reviewable manifest
      (`path<TAB>year`) before any file is touched.
    - Two-part safety predicate, both required to prepend: no `copyright` (case-insensitive) in
      the first 10 lines **and** no `^Copyright (c) ` anywhere in the file. Any file failing
      either check is reported and skipped, never written.
    - The emitted block, exactly (followed by one blank line, then the file's original line 1):
      ```
      /-
      Copyright (c) YYYY Benjamin Brast-McKie. All rights reserved.
      Released under Apache 2.0 license as described in the file LICENSE.
      Authors: Benjamin Brast-McKie
      -/
      ```
      Prepend at line 1 only, above all `import` lines. Never insert mid-file.
    - `--dry-run`: prints the target list, the skip list with reasons, the year manifest summary,
      and one sample before/after diff. Writes nothing.
  - [x] Run `bash scripts/add-copyright-headers.sh --dry-run Theories` and review the output
        against the expected inventory.
- **Timing:** 55 minutes
- **Depends on:** 1
- **Files to modify:**
  - `scripts/check-copyright-headers.sh` — add `--exclude PATTERN`
  - `scripts/add-copyright-headers.sh` — new
- **Verification:**
  - Dry run reports **279** in-scope live files, **151** skipped as Boneyard, **2** flagged as
    already carrying a copyright line (must be exactly `Theories/Bimodal/Automation/TraceExporter.lean`
    and `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean`), and **277** eligible to prepend.
  - Year manifest has 279 rows, every year matching `^20[0-9]{2}$`, and splits **31** rows at 2025
    / **248** at 2026.
  - `git diff --stat -- Theories/` is **empty** and `git status --porcelain -- Theories/` is empty
    — proof the dry run wrote nothing.
  - `bash scripts/check-copyright-headers.sh --exclude '*/Boneyard/*' Theories` reports
    `total: 279` (confirming the new flag selects exactly the live set) with
    `nonconforming: 2, missing: 277, conforming: 0, duplicate: 0`.
  - Commit: `task 292 phase 2: add header tooling and Boneyard-aware checker exclusion`.

---

### Phase 3: Hand-repair the 2 stale-header files [NOT STARTED]

- **Goal:** The only two files that cannot be safely prepended are corrected by
  deletion-then-write, removing the double-header risk from every later batch.
- **Tasks:**
  - [ ] In `Theories/Bimodal/Automation/TraceExporter.lean`, delete the existing 4-line stale
        block (`/-` / `Copyright (c) 2026 BimodalLogic contributors.` / `Released under the
        project's standard license.` / `-/`) and write the correct block in its place, using that
        file's git creation year.
  - [ ] Same for `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean`.
  - [ ] Do **not** prepend. Do not script this — 2 files.
- **Timing:** 20 minutes
- **Depends on:** 2
- **Files to modify:**
  - `Theories/Bimodal/Automation/TraceExporter.lean` — replace stale header block
  - `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` — replace stale header block
- **Verification:**
  - `grep -c '^Copyright (c) '` is exactly **1** in each of the 2 files.
  - `grep -c 'project.s standard license' ` is **0** in each.
  - Checker over the live set: `conforming: 2, nonconforming: 0, duplicate: 0, missing: 277`.
  - `git diff --numstat -- Theories/` shows exactly 2 files, with **8** total deletions (4 per
    file) — any deletion outside these 2 files is a bug.
  - `lake build Bimodal.Automation.TraceExporter Bimodal.Metalogic.Decidability.TraceExport`
    exits 0.
  - Commit: `task 292 phase 3: repair 2 stale copyright headers`.

---

### Phase 4: Batch tier 1 — small subtrees (45 files) [NOT STARTED]

- **Goal:** The 45 small-subtree live files carry conforming headers, with a full `lake build`
  checkpoint before committing to the two large tiers.
- **Tasks:**
  - [ ] Dry-run the script scoped to each of: `Theories/Bimodal/Syntax` (8),
        `Theories/Bimodal/Theorems` (13), `Theories/Bimodal/Semantics` (5),
        `Theories/Bimodal/ProofSystem` (4), `Theories/Bimodal/FrameConditions` (4),
        `Theories/Bimodal/Examples` (2), the 8 `Theories/Bimodal/*.lean` root aggregators, and
        `Theories/Bimodal.lean` (1). Confirm 45 targets total.
  - [ ] Apply the batch.
- **Timing:** 35 minutes
- **Depends on:** 3
- **Files to modify:** 45 `.lean` files across `Syntax/`, `Theorems/`, `Semantics/`,
  `ProofSystem/`, `FrameConditions/`, `Examples/`, the `Theories/Bimodal/*.lean` aggregators, and
  `Theories/Bimodal.lean` — header prepended at line 1
- **Verification:**
  - Checker over the live set: `conforming: 47, nonconforming: 0, duplicate: 0, missing: 232`.
  - `git diff --numstat -- Theories/` cumulative: 47 files, deletions still exactly **8**.
  - Full `lake build`: exit 0, 0 errors, exactly **12** `declaration uses 'sorry'` warnings.
  - Commit: `task 292 phase 4: add Apache headers to small subtrees (45 files)`.

---

### Phase 5: Batch tier 2 — Automation (34 files) [NOT STARTED]

- **Goal:** `Automation/` is headered. Included deliberately: live compiled code, backs 12
  `lean_exe` targets, imported by `Bimodal.Bimodal`.
- **Tasks:**
  - [ ] Dry-run scoped to `Theories/Bimodal/Automation` — expect **34** targets (35 files minus
        `TraceExporter.lean`, already conforming from Phase 3) and 0 safety-predicate flags.
  - [ ] Apply the batch.
- **Timing:** 30 minutes
- **Depends on:** 4
- **Files to modify:** 34 `.lean` files under `Theories/Bimodal/Automation/`
- **Verification:**
  - Checker over the live set: `conforming: 81, nonconforming: 0, duplicate: 0, missing: 198`.
  - `git diff --numstat -- Theories/` cumulative: 81 files, deletions still exactly **8**.
  - Full `lake build`: exit 0, 0 errors, exactly **12** `sorry` warnings. Build targets are
    `Bimodal.*`, never `Theories.Bimodal.*`.
  - Commit: `task 292 phase 5: add Apache headers to Automation (34 files)`.

---

### Phase 6: Batch tier 3 — Metalogic (198 files) [NOT STARTED]

- **Goal:** The remaining 198 live `Metalogic/` files are headered. Largest tier, but a single
  script-driven mechanical pass.
- **Tasks:**
  - [ ] Dry-run scoped to `Theories/Bimodal/Metalogic` — expect **198** targets (199 live minus
        `Decidability/TraceExport.lean`, already conforming from Phase 3), **62** skipped as
        nested `Kamp/Boneyard/`, and 0 safety-predicate flags. The 62-file nested Boneyard skip
        is the single most important number to confirm in this phase's dry run.
  - [ ] Apply the batch.
  - [ ] If the run stalls, re-split by top-level `Metalogic/` subdirectory rather than retrying
        the whole tier — the script already accepts a subtree argument.
- **Timing:** 50 minutes
- **Depends on:** 5
- **Files to modify:** 198 `.lean` files under `Theories/Bimodal/Metalogic/`, excluding
  `Metalogic/WeakCanonical/Kamp/Boneyard/`
- **Verification:**
  - Checker over the live set: `conforming: 279, nonconforming: 0, duplicate: 0, missing: 0`.
  - Zero Boneyard file was touched:
    `git diff --name-only -- Theories/ | grep -c Boneyard` is **0**.
  - `git diff --numstat -- Theories/` cumulative: 279 files, deletions still exactly **8**.
  - Full `lake build`: exit 0, 0 errors, exactly **12** `sorry` warnings.
  - Commit: `task 292 phase 6: add Apache headers to Metalogic (198 files)`.

---

### Phase 7: Final verification and summary [NOT STARTED]

- **Goal:** Every acceptance criterion is checked in one place, from a clean re-run, and written
  up. No criterion is assumed to still hold from an earlier phase.
- **Tasks:**
  - [ ] Run the full verification battery below from scratch.
  - [ ] Write `specs/292_add_copyright_headers_to_all_source_files/summaries/01_relicense-apache-add-headers-summary.md`,
        recording: the relicensing decision and its authorization, the corrected header format
        (and the three ways the task description was wrong), the 279/151 split, the two
        hand-repaired files, and an explicit statement that `linter.style.header` silence is
        **not** evidence of correctness in this repo.
- **Timing:** 45 minutes
- **Depends on:** 6
- **Files to modify:**
  - `specs/292_add_copyright_headers_to_all_source_files/summaries/01_relicense-apache-add-headers-summary.md` — new
- **Verification:**
  - `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' Theories` exits
    **0** with `conforming: 279, nonconforming: 0, duplicate: 0, missing: 0, total: 279`.
  - Unexcluded run confirms the skip is intentional and complete:
    `bash scripts/check-copyright-headers.sh Theories` reports
    `conforming: 279, missing: 151, nonconforming: 0, duplicate: 0, total: 430`, and
    `missing.txt` contains **only** Boneyard paths
    (`grep -vc Boneyard "$OUTDIR/missing.txt"` is 0).
  - Every touched file has exactly one copyright line:
    `git diff --name-only -- Theories/ | xargs -I{} sh -c 'printf "%s %s\n" "$(grep -c "^Copyright (c) " {})" {}' | grep -vc '^1 '` is **0**.
  - `git diff --stat` against the pre-Phase-3 commit shows exactly **279** `.lean` files changed,
    with deletions exactly **8**.
  - Year distribution: `grep -h '^Copyright (c) ' <live files> | awk '{print $3}' | sort | uniq -c`
    yields **31** at 2025 and **248** at 2026.
  - `LICENSE` is Apache-2.0 and no this-repo GPL assertion survives anywhere.
  - `lake build` exits 0 with 0 errors and exactly 12 `declaration uses 'sorry'` warnings, located
    in `Metalogic/Bundle/SuccRelation.lean` (7), `Metalogic/Bundle/SuccExistence.lean` (3),
    `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (1), and
    `Metalogic/WeakCanonical/Transfer.lean` (1).
  - Commit: `task 292: complete implementation`.

---

## Testing & Validation

- [ ] `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' Theories` exits 0
      with `conforming: 279, nonconforming: 0, duplicate: 0, missing: 0`.
- [ ] `bash scripts/check-copyright-headers.sh Theories` (unexcluded) reports `missing: 151`, and
      every path in the `missing` bucket is a Boneyard path.
- [ ] Exactly one `^Copyright (c) ` line per touched file — 0 files violate this.
- [ ] `git diff --stat` shows exactly 279 `.lean` files changed; deletions exactly 8, all from the
      2 hand-repaired files.
- [ ] `git diff --name-only -- Theories/ | grep -c Boneyard` is 0.
- [ ] Year split is 31/2025 and 248/2026.
- [ ] `lake build` exits 0: 0 errors, exactly 12 `declaration uses 'sorry'` warnings in the 4
      named `Metalogic/` files. (Baseline was 1877 jobs; a job-count change alone is not a
      failure, an error or a 13th sorry warning is.)
- [ ] `LICENSE` is the full Apache-2.0 text with the copyright attribution retained; `README.md`
      License section says Apache-2.0; no surviving this-repo GPL assertion.
- [ ] Toolchain unchanged at v4.33.0-rc1; `CLAUDE.md` untouched.
- [ ] **Not a test**: `linter.style.header` silence. It is silent whether the headers are right,
      wrong, or absent. Never cite it.

## Artifacts & Outputs

- `specs/292_add_copyright_headers_to_all_source_files/plans/01_relicense-apache-add-headers.md` (this file)
- `specs/292_add_copyright_headers_to_all_source_files/summaries/01_relicense-apache-add-headers-summary.md`
- `LICENSE` — Apache-2.0 replacement
- `README.md` — License section updated
- `scripts/add-copyright-headers.sh` — new batch tool with `--dry-run`
- `scripts/check-copyright-headers.sh` — `--exclude PATTERN` added
- 279 `.lean` files under `Theories/` with conforming Apache headers

## Rollback/Contingency

Each phase is its own commit, so rollback is per-phase `git revert` in reverse order. The
relicensing (Phase 1) is deliberately isolated in a commit touching zero `.lean` files, so it can
be reverted independently of the headers — and, critically, the headers can be reverted *without*
reverting the relicensing, which is the safe ordering (a tree with Apache `LICENSE` and no headers
is consistent; a tree with headers and a GPL `LICENSE` is not).

If a batch write corrupts files mid-phase, the header block is a pure line-1 prepend, so
`git checkout HEAD -- <paths>` restores the affected files exactly — but per the repo's
"No Destructive Git on Uncommitted Work" rule, run `bash .claude/scripts/git-snapshot.sh` first,
since that is a pathspec-discard form on a dirty tree.

If `lake build` regresses after a tier, do not proceed to the next tier: identify the offending
file from the build error, inspect its first 10 lines, and fix forward. A header-only change
cannot legitimately break elaboration, so a build failure means the write landed somewhere other
than line 1.
