# Research: Copyright/License Notice for BimodalReference.pdf and its Typst Source

**Task 372** | Session: sess_1784105920_065150 | Date: 2026-07-15

## 1. Source and output file paths

| Role | Path | Git-tracked? |
|------|------|--------------|
| Main Typst source | `Theories/Bimodal/typst/BimodalReference.typ` | Yes |
| Shared template (theorem envs, `part-divider`) | `Theories/Bimodal/typst/template.typ` | Yes |
| Chapter includes | `Theories/Bimodal/typst/chapters/*.typ` (14 files) | Yes |
| Notation includes | `Theories/Bimodal/typst/notation/{shared,bimodal}-notation.typ` | Yes |
| Generated counts | `Theories/Bimodal/typst/generated/status.typ` | Yes (generated, do not hand-edit) |
| Bibliography | `Theories/Bimodal/typst/bibliography.bib` | Yes |
| **Published PDF (the one named in the task)** | `Theories/Bimodal/BimodalReference.pdf` | **Yes** |
| Local build output | `Theories/Bimodal/typst/build/BimodalReference.pdf` | No — gitignored (`build/` in root `.gitignore`) |
| Stray local copy | `Theories/Bimodal/typst/BimodalReference.pdf` | No — gitignored (`Theories/Bimodal/typst/.gitignore:3` has `*.pdf`); has a different checksum than the published copy, i.e. stale |

Only `Theories/Bimodal/typst/BimodalReference.typ` (+ its `template.typ`/`chapters/`/`notation/` includes) and `Theories/Bimodal/BimodalReference.pdf` are version-controlled. The plan should treat `BimodalReference.typ` as the canonical place for a source-level notice and `BimodalReference.pdf` as the artifact that must be regenerated to carry a matching visible notice.

## 2. Current state of any copyright/license notice — ABSENT

- `grep -rn -i "copyright\|license\|SPDX\|©\|all rights reserved"` across every `.typ` file in `Theories/Bimodal/typst/` (main doc, template, all 14 chapters) returned **zero matches**. No copyright/license text exists anywhere in the Typst source tree.
- The only header in the main source is a plain descriptive comment block, `Theories/Bimodal/typst/BimodalReference.typ:1-8`:
  ```typst
  // ============================================================================
  // BimodalReference.typ
  // Bimodal TM Logic: A Reference Manual
  //
  // This document provides the formal specification of the Bimodal TM logic,
  // a bimodal logic combining S5 metaphysical modality with linear temporal
  // operators, as implemented in the Bimodal/ directory.
  // ============================================================================
  ```
  No copyright/license line follows it.
- The title page (`Theories/Bimodal/typst/BimodalReference.typ:89-120`) contains title, subtitle, author name, author website link, publication date (`datetime.today()`), and a numbered "Sources:" list — but no copyright line, no license statement, no "All rights reserved" text.
- The back matter (`chapters/06-notes.typ`) and the References section have no colophon page.
- Repo-wide `grep` for copyright markers in all `.typ` files (outside stale `.claude/worktrees/` copies) also returned nothing. There is no existing convention elsewhere in the Typst tree to mirror.
- Lean source files in `Theories/Bimodal/` also carry no per-file copyright header (checked `Theories/Bimodal/Syntax/Formula.lean`-equivalent — starts directly with `import` statements and a `/-! # ... -/` doc comment, no copyright block). So there is no project-wide per-file header convention to copy either; a notice for this document would be a new addition rather than an extension of an existing pattern.
- The companion LaTeX mirror `Theories/Bimodal/latex/BimodalReference.tex` (stale, per `typst/README.md:114-120`) was also checked and has no copyright/license text.

**Conclusion: both the `.typ` source and the compiled `.pdf` are currently silent on copyright/license.**

## 3. Project's existing license situation

- **Repo root `LICENSE`** (full text, 20 lines): GNU General Public License v3.0, with the line:
  ```
  Copyright (c) 2025 Benjamin Brast-McKie
  ```
  (`LICENSE:4`). Note the year is 2025 even though the repo's current work is dated 2026 — this is the project-wide license file, not document-specific, and is out of scope to change here, but the discrepancy is worth flagging to the user.
- **`README.md:221-223`**:
  ```
  ## License

  This project is licensed under GPL-3.0. See [LICENSE](LICENSE) for details.
  ```
  So the *codebase* (Lean source, scripts, `.claude/` tooling) is unambiguously GPL-3.0. GPL-3.0 is a software copyleft license; it is not the conventional choice for a typeset reference manual/book (prose + mathematics), where GNU FDL or a Creative Commons license is more standard. The project has not stated a license specifically for the *documentation/manual* content — GPL-3.0 as written governs "this program" (source code), and applying it verbatim to a book is legally awkward (e.g., GPL's source-availability and modification-tracking requirements are code-oriented). This is the central open decision (see §6).
- `README.md:13` links to the PDF as "outdated" (an unrelated staleness note, not a license note) — irrelevant to copyright but confirms the PDF is treated as a build artifact referenced from the README.

## 4. Confirmed author/attribution

- `Theories/Bimodal/typst/BimodalReference.typ:24-27` (`#set document(...)`):
  ```typst
  #set document(
    title: "Bimodal Reference Manual",
    author: "Benjamin Brast-McKie",
  )
  ```
- Title page (`BimodalReference.typ:102-104`) repeats the name and links to the author's site:
  ```typst
  #text(size: 12pt, style: "italic")[Benjamin Brast-McKie]
  #v(0.0cm)
  #link("https://www.benbrastmckie.com")[#raw("www.benbrastmckie.com")]
  ```
- This matches `LICENSE:4`'s "Benjamin Brast-McKie" and the git user `benbrastmckie` (`benbrastmckie@gmail.com` per `git log`).
- **Author name to use in any notice: "Benjamin Brast-McKie".**
- Note: the title page cites a forthcoming companion journal article, "The Construction of Possible Worlds" (Brast-McKie, *Journal of Philosophical Logic*, forthcoming) at `BimodalReference.typ:115`. If that article's copyright will be transferred to the journal/publisher under a standard publication agreement, a permissive license (e.g., CC BY) on *this* Typst document should be scoped carefully — this manual is a distinct Lean-formalization reference work, not the article itself, so there is no direct conflict, but the user should be aware the two works are legally separate and this document should not claim to relicense the article's content.

## 5. How to add a copyright/license notice in Typst — mechanism and conventions

Two independent places should carry the notice, since only the source-file comment is guaranteed to survive edits, while only a rendered notice reaches PDF readers who never see the `.typ` source:

**(a) Source comment header** — add 1-3 lines immediately after the existing header block at `BimodalReference.typ:1-8`, following the same `//` comment style already used throughout the file (see the block quoted in §2). Typst has no special comment-pragma convention analogous to Lean's `/-! -/` doc-comments for license headers; a plain `//` block is idiomatic and matches this file's existing formatting. Example:
```typst
// ============================================================================
// Copyright (c) 2026 Benjamin Brast-McKie. Licensed under <CHOSEN LICENSE>.
// See LICENSE (repo root) [and/or LICENSE-DOCS if a separate doc license is
// adopted] for full terms.
// ============================================================================
```
This should be placed once, in `BimodalReference.typ` (the compiled entry point); `template.typ` and the chapter/notation includes do not need their own headers since they are not standalone compilable documents and are always pulled in via `#include`/`#import` from the main file — though a one-line pointer comment in `template.typ` (`// Part of BimodalReference.typ; see that file for copyright/license.`) is a reasonable low-cost addition if the plan wants every file to be self-describing.

**(b) Visible notice in the rendered PDF** — this is the more important half for a document, since most readers see only the PDF. Two placement options, both idiomatic in Typst manuals:
  - **Title-page line**: add a small copyright/license line under the existing "Sources:" block or directly under the author/date block at `BimodalReference.typ:106-118`, e.g. immediately after the `--- #datetime.today().display(...) ---` line (`:106`):
    ```typst
    #v(0.3cm)
    #text(size: 9pt)[© 2026 Benjamin Brast-McKie. <License name/short form>.]
    ```
  - **Footer on body pages**: Typst's `#set page(footer: ...)` (not currently used in this document — the only `#set page(...)` at `BimodalReference.typ:40-44` sets `numbering`/`number-align`/`margin` but no `footer:`) can carry a running copyright line on every content page, e.g.:
    ```typst
    #set page(footer: context [
      #align(center)[#text(size: 8pt)[© 2026 Benjamin Brast-McKie -- <License short form>]]
    ])
    ```
    This is heavier-handed (appears on every page) and would need to be scoped to avoid clashing with the existing page-number footer/`number-align: center` numbering; a title-page-only notice is the lower-risk, more conventional choice for an academic reference manual and is what is recommended unless the user wants per-page enforcement.

Because the PDF is a *build artifact*, editing only `Theories/Bimodal/BimodalReference.pdf` directly would not be idiomatic or durable — any notice must originate in `BimodalReference.typ` and then the PDF must be regenerated (§7). This addresses the task's "more importantly" emphasis on the source file.

## 6. Recommended license — decision needed from the user

No single license is obviously "the" right choice; the options and trade-offs:

| Option | Fit | Notes |
|--------|-----|-------|
| **CC BY 4.0** (recommended default) | Good | Standard for academic reference material; permits reuse/redistribution/translation with attribution, which suits a public formal-methods reference manual meant to be cited and built upon. Does not require derivative works to be similarly licensed (unlike GPL/CC BY-SA), avoiding friction for readers who want to quote/adapt excerpts in papers or teaching material. |
| CC BY-SA 4.0 | Reasonable | Same as CC BY but derivatives must be shared under the same license — closer in spirit to the codebase's GPL-3.0 copyleft, if consistency with the code license is a priority. |
| Extend GPL-3.0 to the document (i.e., state the doc is covered by the same repo `LICENSE`) | Simplest, but awkward | Avoids introducing a second license into the project, but GPL-3.0 is drafted for software ("source code", "object code", modification/propagation clauses) and reads oddly applied to prose/mathematics; some legal commentators explicitly discourage GPL for non-software works (GNU itself recommends the GNU FDL or a CC license for documentation, reserving GPL for programs). Workable if the user strongly prefers a single project-wide license and does not mind the mismatch. |
| CC BY-NC-ND 4.0 | Most conservative | Prevents commercial use and derivative works; appropriate if the author wants to protect the manual (which shares content with a *forthcoming* journal article, §4) from redistribution/modification before publication norms are settled. Costs: blocks legitimate reuse (e.g., translations, course adaptations) that a CC BY license would allow. |
| "All rights reserved" (no open license, explicit copyright notice only) | Most conservative, least idiomatic for an open-source-adjacent repo | Simplest single-line notice (`© 2026 Benjamin Brast-McKie. All rights reserved.`) with no accompanying grant of rights; sits oddly next to a GPL-3.0-licensed codebase that the manual documents, since readers could use the (open) Lean source but not quote/redistribute the (closed) manual describing it. |

**Recommendation**: **CC BY 4.0** for the document specifically (distinct from the codebase's GPL-3.0), with a one-line rationale the user can override: an academic reference manual benefits from permissive reuse/citation rights, and CC BY is the de facto standard for this kind of scholarly document (arXiv, many university-hosted lecture notes/manuals use it). If the user prioritizes license-count minimalism over document/code license distinctions, "extend GPL-3.0" is the fallback; if the user wants to protect priority given the forthcoming companion journal article, CC BY-NC-ND 4.0 or "all rights reserved" (temporarily, until publication) are the conservative fallbacks.

**This choice is the one open decision that blocks writing exact notice text** — the planner/implementer should get an explicit answer from the user before finalizing wording. Below is drafted notice text parameterized by license choice so the plan can proceed once the user picks one.

### Draft notice text (parameterize `<LICENSE>` once chosen)

Source header addition (`BimodalReference.typ`, after line 8):
```typst
// Copyright (c) 2026 Benjamin Brast-McKie.
// Licensed under <LICENSE NAME> <URL>.
```

Title-page line (after `BimodalReference.typ:106`, the date line):
```typst
#text(size: 9pt)[© 2026 Benjamin Brast-McKie. Licensed under <LICENSE short form, e.g. "CC BY 4.0">.]
```

If CC BY 4.0 is chosen, `<LICENSE NAME> <URL>` = `Creative Commons Attribution 4.0 International (CC BY 4.0) — https://creativecommons.org/licenses/by/4.0/`.

## 7. Rebuilding the PDF from source

No Makefile/justfile/CI workflow exists for the Typst build (`.github/workflows/` exists but no workflow file references `typst`; `scripts/` has only `typst-status-counts.sh` and `typst-sync-check.sh`, neither of which compiles the document). The build is manual, documented in `Theories/Bimodal/typst/README.md:7-21`:

```bash
# Development (live preview)
cd Theories/Bimodal/typst
typst watch BimodalReference.typ build/BimodalReference.pdf

# Production build
cd Theories/Bimodal/typst
typst compile BimodalReference.typ build/BimodalReference.pdf
```

This produces `Theories/Bimodal/typst/build/BimodalReference.pdf` (gitignored, not the file named in the task). The git-tracked, task-named artifact `Theories/Bimodal/BimodalReference.pdf` is updated by copying the build output up one directory — confirmed by the most recent history: commit `bf1b68a56` ("task 371: refresh published BimodalReference.pdf to two-part revision") replaced only `Theories/Bimodal/BimodalReference.pdf` after a source revision, and there is no automation script for this copy step (verified via `grep` across `*.md`/`*.sh` for `cp.*BimodalReference` and `Theories/Bimodal/BimodalReference.pdf` — only a README reference to the PDF as a doc link, no copy script). The implementation plan should therefore include an explicit manual step:

```bash
cd Theories/Bimodal/typst
typst compile BimodalReference.typ build/BimodalReference.pdf
cp build/BimodalReference.pdf ../BimodalReference.pdf
```

Locally installed Typst version confirmed available in this environment: `typst 0.14.2 (b33de9de)`.

## 8. Open decisions for the user / planner

1. **License choice** (§6) — CC BY 4.0 (recommended), CC BY-SA 4.0, extend GPL-3.0, CC BY-NC-ND 4.0, or "all rights reserved". This determines the exact notice text in both the source header and the title page.
2. **Footer vs. title-page-only notice** (§5b) — recommend title-page-only (lower risk, no interaction with existing page numbering); confirm if the user wants a running footer on every page instead/also.
3. **Copyright year** — the repo `LICENSE` says "2025" (`LICENSE:4`) while the document itself is dated via `datetime.today()` (i.e., will render as "2026" for a build run today, 2026-07-15). Decide whether the document notice should hardcode a year (e.g., "2026") or a range (e.g., "2025–2026") for consistency with the root `LICENSE`; hardcoding is simpler and avoids the notice silently drifting in future rebuilds if `datetime.today()` is reused for the copyright year.
4. Whether to also touch the root `LICENSE` file's year/scope (out of scope per the task's focus on the PDF/Typst source, but flagged since the mismatch was discovered during research).
