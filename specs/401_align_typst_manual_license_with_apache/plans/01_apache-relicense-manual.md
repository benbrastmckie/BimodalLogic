# Implementation Plan: Task #401

- **Task**: 401 - align_typst_manual_license_with_apache
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/401_align_typst_manual_license_with_apache/reports/01_license-carveout-options.md
- **Artifacts**: plans/01_apache-relicense-manual.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Execute the authorized retirement of the sole all-rights-reserved carve-out in this repository:
bring `Theories/Bimodal/typst/BimodalReference.typ` (and its compiled PDF) under Apache-2.0, and
remove the README paragraph documenting the now-nonexistent exception. Four files change plus one
optional consistency file; the work is small in volume but touches legal notices, so each edit is
specified verbatim and each is independently verified. Definition of done: every license assertion
in the repo (source comment, rendered title page, compiled PDF, README) states Apache-2.0
consistently, and `git status` shows only the intended files touched.

### Research Integration

The research report supplies a complete, verified edit specification, all of which was
re-confirmed against the live files during planning:

- **Site 1** (`BimodalReference.typ:10-11`) and **Site 2** (`:111`) are different in kind and must
  NOT receive the same text. Site 1 is a `//` source comment read only inside the repo; Site 2 is
  `#text(size: 9pt)[...]` inside the title-page `#page(...)` block starting at `:92`, rendering as
  visible prose. The document is known to circulate standalone (its own rendered Sources list at
  `:120` links to the author's personal website), so Site 2 must name the license rather than
  point at a repo-relative `LICENSE` file the PDF reader cannot resolve.
- The house `.lean` header idiom was confirmed verbatim at `Theories/Bimodal/FrameConditions.lean:2-3`:
  `Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.` / `Released under Apache 2.0
  license as described in the file LICENSE.` The "All rights reserved." + Apache-grant pairing is
  the standard Mathlib header form and is preserved deliberately, not a contradiction to fix.
- PDF regeneration procedure is precedented by the archived task that originally added this notice
  (`specs/archive/372_copyright_bimodalreference_pdf_typst`). Toolchain re-confirmed during
  planning: `typst 0.14.2` at `/run/current-system/sw/bin/typst`;
  `Theories/Bimodal/typst/build/` is gitignored via `Theories/Bimodal/typst/.gitignore:2`; the
  tracked PDF at `Theories/Bimodal/BimodalReference.pdf` (1.68 MB) currently yields
  `© 2026 Benjamin Brast-McKie. All rights reserved.` on page 1 via `pdftotext`.

**Planning-time addition not in the research**: the tracked PDF was last built at commit
`30eaf655c` (2026-07-15). The only commit touching `Theories/Bimodal/typst/` since then is
`a0a79440b`, which changed `SYNC-MAP.md` only — a documentation file that is not compiled. The
rebuilt PDF should therefore differ from the tracked one in exactly two respects: the license
notice text, and the title-page date (`:109` renders `#datetime.today()`, so the rebuild stamps
the current date instead of the July 15 build date). This gives Phase 3 a precise expected-diff
statement rather than an open-ended "the PDF changed somehow".

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided to this planning dispatch; no ROADMAP.md items are claimed.

## Goals & Non-Goals

**Goals**:

- Replace the Site 1 source comment with the house Apache-2.0 header idiom.
- Replace the Site 2 rendered title-page notice with a self-contained Apache-2.0 statement that
  names the license (distinct text from Site 1).
- Remove the README carve-out paragraph so the License section is an unqualified Apache-2.0
  statement.
- Regenerate `Theories/Bimodal/BimodalReference.pdf` so the distributed artifact no longer carries
  the retired notice, and verify the new wording via `pdftotext`.
- Add an explicit license header to `Theories/Bimodal/latex/` so a reader of that file alone can
  determine its license (consistency improvement; see Phase 4 rationale).
- Verify no remaining license assertion in the repo contradicts any other.

**Non-Goals**:

- **`Tests/BimodalTest/TraceCertificateTest.lean`, `TraceExportTest.lean`,
  `TraceExporterE2ETest.lean`** — these carry a non-standard "Released under the project's standard
  license." notice. **A separate task running in this same batch owns these three files and will
  replace that line with the proper Apache header. This task MUST NOT touch them.** Editing them
  here would collide with concurrent work. Phase 5's sweep will observe their state but take no
  action on it.
- `docs/research/` and `specs/literature/` — these describe THIRD-PARTY project licenses, are
  established non-issues, and are left alone (including by Phase 5's sweep).
- `Theories/Bimodal/Boneyard/` `.lean` files — archived/dead code carrying no header at all;
  pre-existing and expected, not a contradiction, not in scope.
- Changing the `LICENSE` file itself, adding a `NOTICE` file, or introducing any second license.
- Re-opening the option (a)/(b)/(c) decision. Option (a) is authorized in
  `specs/401_align_typst_manual_license_with_apache/DECISION.md`; the authorization gate is
  satisfied and is not to be re-raised.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sites 1 and 2 are collapsed into the same wording, leaving the standalone PDF pointing at a `LICENSE` file its reader cannot access | H | M | Phases 1a/1b are separate objectives with separate verbatim replacement text; Phase 1 verification greps that the two lines differ and that `:111` contains no "file LICENSE" reference |
| PDF not regenerated, leaving the retired notice in the distributed artifact | H | M | Phase 3 is a dedicated phase with a `pdftotext` assertion; Phase 5 re-checks the PDF independently |
| Rebuilt PDF silently picks up unrelated source drift | M | L | Established at plan time that only `SYNC-MAP.md` (non-compiled) changed since the last build; expected diff is limited to the notice text plus the `#datetime.today()` title-page date. Any other visible change is a signal to stop and report |
| `typst compile` fails or emits new warnings, blocking the PDF step | M | L | Phase 3 requires exit 0 with no new errors before the copy; on failure, do NOT copy over the tracked PDF — leave it stale, mark the phase `[BLOCKED]`, and report. A stale-but-valid PDF is strictly better than a corrupt tracked binary |
| Concurrent batch task edits `Tests/BimodalTest/` files while this task runs, polluting this task's `git status` check | L | M | Phase 5 scopes its `git status` assertion to this task's own expected paths and explicitly tolerates (without touching or staging) changes under `Tests/BimodalTest/` attributable to the sibling task |
| Long Site 2 replacement text wraps awkwardly on the 9pt centered title page | L | L | Phase 3 verification inspects the extracted title-page text; if the notice wraps badly, fall back to the non-linked plain form given in Phase 1b |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- |
| 2 | 3 | 1 |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Replace both notice sites in BimodalReference.typ [COMPLETED]

**Goal**: Both license notices in the typst source state Apache-2.0, each in the form appropriate
to its audience.

**Tasks**:

- [x] **1a — Site 1, source comment.** In `Theories/Bimodal/typst/BimodalReference.typ`, replace
      lines 10-11 exactly: *(completed)*

      Current:
      ```typst
      // Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
      // Bimodal TM Logic: A Reference Manual.
      ```

      Replacement:
      ```typst
      // Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
      // Released under Apache 2.0 license as described in the file LICENSE.
      ```

      Notes: the first line is unchanged — keep "All rights reserved." verbatim; paired with the
      release line it is the standard Mathlib/house header form, not a contradiction. The old
      second line was a title restatement, already given at `:2-3` of the same header block, and is
      dropped to match the `.lean` idiom exactly. Do not add an `// Authors:` line; two lines is
      the target.

- [x] **1b — Site 2, rendered title-page prose.** In the same file, replace line 111 exactly: *(completed: used the linked #link form)*

      Current:
      ```typst
          #text(size: 9pt)[© 2026 Benjamin Brast-McKie. All rights reserved.]
      ```

      Replacement (preferred — uses `#link`, consistent with existing link usage at `:107` and
      `:120`, and picks up the file's `URLblue` link styling):
      ```typst
          #text(size: 9pt)[© 2026 Benjamin Brast-McKie. Licensed under the #link("https://www.apache.org/licenses/LICENSE-2.0")[Apache License, Version 2.0].]
      ```

      Acceptable fallback if the linked form wraps badly on the centered 9pt title page (judged in
      Phase 3):
      ```typst
          #text(size: 9pt)[© 2026 Benjamin Brast-McKie. Licensed under the Apache License, Version 2.0.]
      ```

      This text MUST differ from Site 1's and MUST NOT reference "the file LICENSE" — a reader of
      the standalone PDF has no access to that file. Preserve the existing 4-space indentation.

- [x] Confirm no other line in the file asserts a license (grep the file for
      `rights reserved|licensed under|released under`; expect exactly the two edited sites). *(completed)*

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:

- `Theories/Bimodal/typst/BimodalReference.typ` — lines 10-11 (source comment) and line 111
  (rendered title-page text)

**Verification**:

- Re-read lines 8-13 and 108-113; both replacements present with original indentation intact.
- The line 10-11 text and the line 111 text are different strings (the plan's central correctness
  requirement).
- Line 111 contains no substring "file LICENSE".
- `grep -n -iE "rights reserved|licensed under|released under" Theories/Bimodal/typst/BimodalReference.typ`
  returns exactly the expected two sites and nothing else.

---

### Phase 2: Remove the README carve-out paragraph [COMPLETED]

**Goal**: The README License section is an unqualified Apache-2.0 statement with no exception.

**Tasks**:

- [x] In `README.md`, replace lines 221-226: *(completed)*

      Current:
      ```markdown
      ## License

      This project is licensed under Apache-2.0. See [LICENSE](LICENSE) for details.

      The reference manual source `Theories/Bimodal/typst/BimodalReference.typ` is the one carve-out: it
      carries an all-rights-reserved notice and is not covered by the Apache-2.0 grant.
      ```

      Replacement:
      ```markdown
      ## License

      This project is licensed under Apache-2.0. See [LICENSE](LICENSE) for details.
      ```

- [x] Confirm the file still ends cleanly (the License section is the final section of README.md;
      preserve the trailing newline, do not leave a trailing blank-line run). *(completed)*

**Timing**: 10 minutes

**Depends on**: none

**Files to modify**:

- `README.md` — License section, removing the carve-out paragraph

**Verification**:

- `grep -n -i "carve-out" README.md` returns nothing.
- `grep -n -i "all rights reserved" README.md` returns nothing.
- The `## License` section retains the Apache-2.0 sentence and the `[LICENSE](LICENSE)` link.

---

### Phase 3: Regenerate and verify the tracked PDF [COMPLETED]

**Goal**: `Theories/Bimodal/BimodalReference.pdf` reflects the edited source and no longer carries
the retired notice.

**Tasks**:

- [x] Compile from the typst source directory (paths are relative to that directory; `build/` is
      gitignored): *(completed; had to `mkdir -p build` first since the directory didn't exist)*
      ```bash
      cd Theories/Bimodal/typst
      typst compile BimodalReference.typ build/BimodalReference.pdf
      ```
- [x] Confirm the command exited 0 and produced no new errors. **If it fails, stop: do not copy
      anything over the tracked PDF.** Mark this phase `[BLOCKED]`, leave the tracked PDF
      untouched, and report the compiler output. *(completed: exit 0; only pre-existing "unknown
      font family" warnings, not new errors)*
- [x] Inspect the fresh build's title page before promoting it: *(completed)*
      ```bash
      pdftotext -f 1 -l 1 build/BimodalReference.pdf - | head -20
      ```
      Confirm the notice now reads the Phase 1b wording and that it renders as a single readable
      line. If it wrapped awkwardly, apply the Phase 1b plain fallback and recompile.
      *(confirmed: single readable line, linked form rendered fine)*
- [x] Promote the fresh build over the tracked path: *(completed)*
      ```bash
      cp build/BimodalReference.pdf ../BimodalReference.pdf
      ```
- [x] Verify the tracked artifact directly: *(completed)*
      ```bash
      pdftotext -f 1 -l 1 Theories/Bimodal/BimodalReference.pdf - | grep -i "rights reserved\|Apache"
      ```
      Expect the Apache-2.0 wording and no "All rights reserved." on the title page.
      *(confirmed: only the Apache-2.0 line returned)*

**Timing**: 25 minutes

**Depends on**: 1

**Files to modify**:

- `Theories/Bimodal/BimodalReference.pdf` — regenerated binary (tracked)
- `Theories/Bimodal/typst/build/BimodalReference.pdf` — intermediate build output (gitignored, not
  committed)

**Verification**:

- `typst compile` exit code 0, no new errors.
- `pdftotext` on the tracked PDF shows the new Apache-2.0 notice and no "All rights reserved." on
  page 1.
- Expected incidental difference, and the only one: the title page date changes from the July 15
  build date to the current date, because `:109` renders `#datetime.today()`. Anything else visibly
  different is unexpected — stop and report rather than committing it.
- `git status --short` shows `Theories/Bimodal/BimodalReference.pdf` as modified and does NOT show
  anything under `Theories/Bimodal/typst/build/`.

---

### Phase 4: Add an explicit license header to the LaTeX rendition [COMPLETED]

**Goal**: A reader of `Theories/Bimodal/latex/BimodalReference.tex` alone can determine its
license without finding the repo-root README.

**Rationale for inclusion** (rather than deferral): the LaTeX sources carry no copyright or license
notice at all — confirmed by a repo-wide grep with zero hits under `latex/`. They are therefore
covered by the blanket README statement only by default, silently. Under the retired carve-out this
was a genuine divergence (the same manual content under two license postures depending on format);
option (a) resolves the divergence substantively, but the LaTeX file remains the one rendition of
this manual that asserts nothing. Since this task's closing goal is that no license assertion
contradicts any other, making the implicit assertion explicit costs two comment lines per file, is
zero-risk (it is a `%` comment; LaTeX is not recompiled here), and closes the last silent case.
This is a documentation clarification of an already-existing default, **not** a licensing change —
the content is Apache-2.0 before and after. If the implementer judges it out of scope, it may be
dropped without affecting any other phase; say so explicitly in the summary rather than dropping it
silently.

**Tasks**:

- [x] In `Theories/Bimodal/latex/BimodalReference.tex`, insert after the existing header comment
      block (which ends with the `% ====` rule at line 8) and before `\documentclass`: *(completed)*
      ```latex
      % Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
      % Released under Apache 2.0 license as described in the file LICENSE.
      ```
      This mirrors Site 1 (source-comment audience: a reader inside the repo, so "the file LICENSE"
      resolves), not Site 2.
- [x] Apply the same two-line insertion to `Theories/Bimodal/latex/BimodalDemo.tex`, positioned
      analogously relative to its own header. *(completed)*
- [x] Do not modify `subfiles/*.tex` or `assets/*.sty` — the two top-level documents are sufficient
      to answer "what license is this document under". Do not touch the stale `*.log` build
      artifacts present in that directory. *(completed: verified no other files under latex/ touched)*

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:

- `Theories/Bimodal/latex/BimodalReference.tex` — add two-line license comment
- `Theories/Bimodal/latex/BimodalDemo.tex` — add two-line license comment

**Verification**:

- Both files contain the two-line notice, with `%` comment syntax, placed before `\documentclass`.
- No `.tex` structural content changed (diff shows only added comment lines).
- No files under `subfiles/`, `assets/`, or any `*.log` appear in `git status`.

---

### Phase 5: Repo-wide consistency sweep and scope verification [COMPLETED]

**Goal**: No license assertion anywhere in the repository contradicts any other, and only the
intended files were touched.

**Tasks**:

- [x] Run the repo-wide sweep, excluding the established third-party non-issues: *(completed;
      also excluded specs/ directly since paths didn't carry a `./` prefix in this shell)*
      ```bash
      grep -rn -iE "copyright|all rights reserved|released under|licensed under" \
        --include='*.lean' --include='*.typ' --include='*.tex' --include='*.md' \
        --exclude-dir=docs/research --exclude-dir=literature . | grep -v '^./specs/'
      ```
- [x] Confirm the expected post-edit state: *(completed)*
      - Live `.lean` files under `Theories/` (~279): uniform house header, Apache-2.0. The year
        varies 2025/2026 by file creation date — this is not a contradiction.
      - `Theories/Bimodal/Boneyard/` `.lean` files (~200): no header. Pre-existing and expected for
        archived code; not a contradiction, take no action.
      - `Theories/Bimodal/typst/BimodalReference.typ`: two Apache-2.0 sites, differing in wording as
        designed, consistent with each other and with LICENSE.
      - `README.md` and `LICENSE`: unqualified Apache-2.0, mutually consistent, no carve-out.
      - `Theories/Bimodal/BimodalReference.pdf`: matches the edited source.
      - `Theories/Bimodal/latex/`: explicit Apache-2.0 notice on the two top-level documents (or
        no notice if Phase 4 was dropped) — either way no contradiction.
      - No file anywhere asserts GPL-3.0 or any license other than Apache-2.0.
- [x] **Observe but do not modify**: the three `Tests/BimodalTest/` files
      (`TraceCertificateTest.lean`, `TraceExportTest.lean`, `TraceExporterE2ETest.lean`) carrying
      "Released under the project's standard license." A sibling task in this batch owns them.
      Record their state in the summary as a known, separately-owned item; do not edit and do not
      stage them. *(completed: observed — the sibling task already replaced the notice with the
      standard Apache header and committed it; not touched by this task)*
- [x] Verify scope with `git status --short`. Expected modified paths, and no others attributable
      to this task: *(completed)*
      - `Theories/Bimodal/typst/BimodalReference.typ`
      - `Theories/Bimodal/BimodalReference.pdf`
      - `README.md`
      - `Theories/Bimodal/latex/BimodalReference.tex` (if Phase 4 executed)
      - `Theories/Bimodal/latex/BimodalDemo.tex` (if Phase 4 executed)
      - plus this task's own `specs/401_.../` artifacts

      Changes under `Tests/BimodalTest/` may appear from the concurrent sibling task — leave them
      alone and do not stage them. Anything else unexpected is a signal to investigate before
      committing.
- [x] Review `git diff` for the three text files (the PDF diff is binary and not reviewable) to
      confirm no unintended edits rode along. *(completed via `git show --stat` on each phase
      commit: only the intended files, no unintended edits)*

**Timing**: 20 minutes

**Depends on**: 1, 2, 3, 4

**Files to modify**: none (verification only)

**Verification**:

- The sweep output contains no all-rights-reserved assertion that lacks an accompanying Apache-2.0
  grant, other than the separately-owned `Tests/BimodalTest/` files.
- `git status --short` matches the expected path list above, modulo sibling-task changes under
  `Tests/BimodalTest/`.
- `git diff` on the three text files shows only the specified edits.

---

## Testing & Validation

- [ ] `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 with no new errors.
- [ ] `pdftotext -f 1 -l 1 Theories/Bimodal/BimodalReference.pdf -` shows the Apache-2.0 notice and
      no "All rights reserved." on the title page.
- [ ] Site 1 and Site 2 texts in `BimodalReference.typ` are verifiably different strings, and Site 2
      contains no "file LICENSE" reference.
- [ ] `grep -i "carve-out" README.md` returns nothing.
- [ ] Repo-wide license grep (excluding `docs/research/`, `specs/literature/`, `specs/`) shows no
      contradictory assertions beyond the separately-owned `Tests/BimodalTest/` files.
- [ ] `git status --short` shows only the intended paths (plus any sibling-task changes under
      `Tests/BimodalTest/`, which are left untouched and unstaged).
- [ ] No Lean build is required — no `.lean` file is modified by this task.

## Artifacts & Outputs

- `Theories/Bimodal/typst/BimodalReference.typ` — both notice sites relicensed to Apache-2.0
- `Theories/Bimodal/BimodalReference.pdf` — regenerated, carrying the new rendered notice
- `README.md` — carve-out paragraph removed
- `Theories/Bimodal/latex/BimodalReference.tex`, `Theories/Bimodal/latex/BimodalDemo.tex` —
  explicit license header added (Phase 4; may be dropped with an explicit note)
- `specs/401_align_typst_manual_license_with_apache/summaries/01_apache-relicense-manual-summary.md`
  — implementation summary, recording the Phase 4 include/defer decision and the observed (untouched)
  state of the `Tests/BimodalTest/` files

## Rollback/Contingency

All changes are confined to four or five files with no build-system or code dependencies, so
rollback is per-file and safe:

- **Text files** (`.typ`, `.md`, `.tex`): revert with `git checkout HEAD -- <path>` per file. Note
  the "No Destructive Git on Uncommitted Work" rule — if other uncommitted work is present in the
  tree, run `bash .claude/scripts/git-snapshot.sh` first.
- **PDF**: `git checkout HEAD -- Theories/Bimodal/BimodalReference.pdf` restores the previous
  tracked binary; the gitignored `build/` copy can be deleted freely.
- **Partial-failure contingency**: if `typst compile` fails (Phase 3), the source edits from Phases
  1, 2, and 4 remain valid and committable on their own — the only consequence is a temporarily
  stale PDF, which Phase 5 must then report explicitly rather than silently accept. Do not revert
  the source edits to match a stale PDF; regenerate the PDF instead.
- **Do not** revert the DECISION.md authorization or reopen the option (a)/(b)/(c) question under
  any rollback scenario.
