# Research Report: Task #401

**Task**: 401 - align_typst_manual_license_with_apache
**Started**: 2026-07-25
**Completed**: 2026-07-26
**Effort**: small (research + edit-specification only; execution belongs to the implementation phase)
**Dependencies**: None
**Sources/Inputs**: Codebase (Theories/Bimodal/typst/, Theories/Bimodal/latex/, README.md, LICENSE), git log, git ls-files, pdftotext, specs/401_align_typst_manual_license_with_apache/DECISION.md, specs/archive/372_copyright_bimodalreference_pdf_typst/ (prior implementation precedent for this exact PDF)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Authorized decision: option (a), Apache-2.0.** The copyright holder authorized option (a) —
  bring the typst reference manual under Apache-2.0, for a single uniform license story — per
  `specs/401_align_typst_manual_license_with_apache/DECISION.md`. Options (b) (strengthen the
  carve-out in-source) and (c) (CC-BY-4.0) were declined. The full a/b/c analysis is retained
  below as the record of how the decision was reached; the sections after it are the concrete
  edit specification for the implementation phase.
- The carve-out being retired was itself deliberately added by a prior task (archived task 372,
  "copyright_bimodalreference_pdf_typst") — its summary documents the exact original edit and
  PDF-rebuild procedure, reused below for the reverse edit.
- Two notice sites in `BimodalReference.typ` need updating, and they are **not** the same kind of
  text: `:10-11` is a source-only `//` comment (invisible in the compiled output, read only by
  someone opening the `.typ` file in the repo); `:111` is inside a `#text(...)[...]` block that
  renders as visible prose on the compiled title page — read by anyone who opens the PDF,
  including outside the repo (the same document lists a URL on the author's personal website as
  one of its own "Sources", so the PDF is known to circulate independently of this repository).
  The source comment can safely say "as described in the file LICENSE" (a reader of the source
  is in the repo); the rendered notice must be self-contained, since a PDF reader may have no
  access to the repository at all. Exact replacement text for both is given below.
- `README.md`'s carve-out sentence documents an exception that no longer exists once this lands
  and must be removed (verbatim quote and replacement given below).
- `Theories/Bimodal/BimodalReference.pdf` reproduces the old notice verbatim and needs
  regenerating; the exact command and toolchain availability are confirmed below.
- The previously-flagged `latex/` gap (the same document rendered without any notice, implicitly
  Apache-2.0 by default) is now moot in the way that matters: option (a) collapses the divergence
  by construction, since both renditions end up Apache-2.0. A non-required consistency
  improvement (an explicit notice in `latex/` for the benefit of a reader of that file alone) is
  included below as a recommendation, not a licensing change.
- The `Tests/BimodalTest/` non-standard notice finding (3 files) is confirmed **out of scope for
  this task's edit spec** — it is owned by another task in this batch, which will replace that
  notice with the proper Apache header. Not included in the edits below; noted so nobody
  double-edits it.

## Context & Scope

Task 401 asked for a decision among three options for resolving the sole remaining
all-rights-reserved carve-out in an otherwise Apache-2.0 repository
(`Theories/Bimodal/typst/BimodalReference.typ`), followed by execution of whichever option was
authorized. The copyright holder has authorized option (a) via
`specs/401_align_typst_manual_license_with_apache/DECISION.md`. This report retains the full
options analysis that led to the decision, then gives the exact, ready-to-execute edit
specification for the implementation phase: precise replacement text for both notice sites, the
README edit, the PDF regeneration step, the latex/ recommendation, and a final contradiction
sweep.

## Findings

### 1. The carve-out notice itself (verbatim)

`Theories/Bimodal/typst/BimodalReference.typ:10-11`:
```
// Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
// Bimodal TM Logic: A Reference Manual.
```

`Theories/Bimodal/typst/BimodalReference.typ:111` (rendered title-page text, inside the `#page(...)` block):
```
#text(size: 9pt)[© 2026 Benjamin Brast-McKie. All rights reserved.]
```

Both notices confirmed present verbatim. Neither contains a "Released under ..." clause of any
kind — unlike every standard `.lean` file header in the repo, which pairs "Copyright ... All
rights reserved." with a second line "Released under Apache 2.0 license as described in the file
LICENSE."

### 2. README License section (verbatim, README.md:221-226)

```markdown
## License

This project is licensed under Apache-2.0. See [LICENSE](LICENSE) for details.

The reference manual source `Theories/Bimodal/typst/BimodalReference.typ` is the one carve-out: it
carries an all-rights-reserved notice and is not covered by the Apache-2.0 grant.
```

Accurate and matches the actual file state (pre-decision). No inconsistency between README and
the .typ notices themselves.

### 3. `Theories/Bimodal/latex/` — confirmed clean of all-rights-reserved notices, but a gap (now moot under option (a))

No file under `Theories/Bimodal/latex/` (including `BimodalReference.tex`, `BimodalDemo.tex`, all
`subfiles/*.tex`, and `assets/*.sty`) contains any copyright or license notice — confirmed via
repo-wide grep for `copyright|all rights reserved|released under|licensed under`, zero hits in
`latex/`.

`Theories/Bimodal/latex/README.md` describes typst as "[an] Alternative Typst version" of the
same reference manual, and the LaTeX source is a real, overlapping rendition of the same
document — same title ("Bimodal TM Logic: A Reference Manual"), same author, 6 subfile chapters
(`00-Introduction` through `06-Notes`, ~1,549 lines) covering the same early material as the
first 6-7 `#include`s in the typst version's chapter list (which has grown to ~15 chapters,
~3,090 lines; `Theories/Bimodal/typst/README.md`'s "Relationship to LaTeX Version" section states
the LaTeX mirror has been stale/superseded since 2026-07-06, typst is authoritative).

Because `latex/` carried no notice of its own, and the README's carve-out sentence names only the
`.typ` file, the LaTeX rendition fell under the blanket "This project is licensed under
Apache-2.0" statement by default — so the same material was simultaneously available under two
different license postures depending on format. **Under option (a) this divergence is resolved by
construction**: once the `.typ` carve-out is retired, both renditions are Apache-2.0, one
explicitly (typst, once edited) and one by default (latex, unchanged). See the Recommendation in
the edit specification below for a non-required consistency improvement.

### 4. Generated output carrying the same notice

`Theories/Bimodal/BimodalReference.pdf` (1.68 MB, git-tracked, last touched 2026-07-15 in a
"Restore BimodalReference PDF + typst/latex sources" commit) is the compiled output of the typst
source. Extracted via `pdftotext`:
```
Bimodal Reference Manual
A Logic for Tense and Modality
Benjamin Brast-McKie
...
© 2026 Benjamin Brast-McKie. All rights reserved.
```
Confirmed: the PDF reproduces the identical all-rights-reserved notice, consistent with its
source. It is a build artifact that must be regenerated once the .typ notice text changes; see
the edit specification below for the exact command and toolchain confirmation. No other PDF in
the repo carries this notice — the only other PDF found, `docs/papers/possible_worlds.pdf`, is
the third-party journal paper referenced as a bibliography source, not project-generated output,
out of scope.

### 5. Sweep for contradicting license assertions (pre-decision baseline)

Repo-wide grep for `copyright|all rights reserved|released under|licensed under` (excluding
`docs/research/` and `specs/literature/`, confirmed non-issues describing third-party projects)
found:

- **279 live `.lean` files under `Theories/`**: uniform "Copyright (c) 2026 [or 2025]
  Benjamin Brast-McKie. All rights reserved. / Released under Apache 2.0 license as described in
  the file LICENSE." (year varies 2025/2026 by file creation date — not a contradiction).
- **200 `.lean` files under `Theories/Bimodal/Boneyard/`** (archived/dead-code directories):
  carry no header at all. Matches the task description's own framing ("all 279 *live* .lean
  files under Theories/ carry the Apache header") — Boneyard files are non-live/archived, not a
  contradiction.
- **3 `.lean` files under `Tests/BimodalTest/`** (`TraceCertificateTest.lean`,
  `TraceExportTest.lean`, `TraceExporterE2ETest.lean`): non-standard notice — "Copyright (c) 2026
  BimodalLogic contributors." / "Released under the project's standard license." — instead of
  the repo's standard header. **Confirmed owned by another task in this same batch, which will
  replace this notice with the proper Apache header. Not included in this task's edit spec — do
  not double-edit.**
- **README.md and LICENSE**: consistent with each other and with the `.typ` carve-out as
  documented (pre-decision state).
- **No file anywhere asserts GPL-3.0** or any license other than Apache-2.0 (repo-wide) and the
  (pre-decision) documented all-rights-reserved carve-out.

## Options Analysis (record of how the decision was reached)

### Option (a): Apply Apache-2.0 to the manual too (uniform license story) — AUTHORIZED, ADOPTED

**Concrete changes**: replace both `BimodalReference.typ` notice sites with Apache-2.0 wording,
remove the README carve-out sentence, regenerate the PDF. No change needed to `latex/` (already
implicitly Apache-2.0; the Finding 3 gap resolves itself since there is no longer any carve-out to
be undermined).

**Gives up**: the reserved-rights position on original scholarly/expository prose in the manual
(as distinct from the Lean source, already Apache-2.0). Anyone could redistribute, modify, or
republish the manual text under Apache-2.0 terms (attribution + NOTICE preservation only, no
share-alike, no non-commercial restriction).

**Interaction with code license**: cleanest option — one license, one file, zero exceptions to
explain or maintain. Also the only option that fully closes Finding 3's gap without further
action.

### Option (b): Keep the carve-out, make it explicit in the .typ source itself — DECLINED

Would have expanded the `.typ` notices to state the exception explicitly (e.g. "This document is
a deliberate exception to this repository's Apache-2.0 license") without changing the actual
rights position. Gives up nothing; only adds self-documentation. Does not resolve Finding 3.
Declined by the copyright holder in favor of a uniform license story.

### Option (c): Apply a documentation-appropriate open license (e.g. CC-BY-4.0) — DECLINED

Would have introduced a second license (CC BY 4.0) for the manual specifically, requiring a new
`LICENSE-DOCS` file and two-license README language. Retains attribution requirement but gives up
exclusivity; adds the most maintenance surface of the three options and does not resolve Finding
3 by itself. Declined by the copyright holder.

### Authorization note (for the record)

The original research draft of this report argued that even option (b) — despite not changing
the underlying rights position — should be treated as requiring explicit authorization, since it
still edits a legal notice in the holder's name and the task's charter grouped all three options
together under one gate. The copyright holder has since directly authorized option (a) via
`specs/401_align_typst_manual_license_with_apache/DECISION.md`, satisfying that gate. This
report's earlier "wait for authorization" framing is resolved; no further sign-off is needed to
proceed with the edit specification below.

## Authorized Decision: Option (a), Apache-2.0 — Edit Specification

### Site 1 — source comment, `Theories/Bimodal/typst/BimodalReference.typ:10-11` (verbatim, current)

```typst
// Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
// Bimodal TM Logic: A Reference Manual.
```

This is a `//` line comment, invisible in the compiled PDF — visible only to someone reading the
`.typ` source file in the repository, i.e., a reader who by definition has access to `LICENSE`
in the same repository.

**Recommended replacement**, matching the house style used throughout the repo's `.lean` headers
(`Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.` / `Released under Apache 2.0
license as described in the file LICENSE.` — confirmed verbatim at, e.g.,
`Theories/Bimodal/FrameConditions.lean:2-3`):

```typst
// Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
// Released under Apache 2.0 license as described in the file LICENSE.
```

Notes:
- The prior second line ("Bimodal TM Logic: A Reference Manual.") is a title restatement, not a
  legal notice — dropped here to match the `.lean` house style exactly (copyright line + release
  line, no title line); it duplicates the title already given at `:2-3`. Keeping it as an
  optional third line is a harmless stylistic choice, not a legal requirement.
- An optional third `// Authors: Benjamin Brast-McKie` line (mirroring the `.lean` headers'
  typical fourth line) may be added; the two lines above are sufficient.

### Site 2 — rendered title-page content, `Theories/Bimodal/typst/BimodalReference.typ:111` (verbatim, current)

```typst
    #text(size: 9pt)[© 2026 Benjamin Brast-McKie. All rights reserved.]
```

This line is inside the `#page(...)[...]` title-page block (block starts at `:92`), so it renders
as visible 9pt text on the compiled document's title page — confirmed via `pdftotext` on the
current PDF, which extracts exactly `© 2026 Benjamin Brast-McKie. All rights reserved.` at that
position. This is prose for a human reader, not a code comment, and — per the "Sources" list
rendered a few lines later in the same block (`:120`, a link to
`https://benbrastmckie.com/wp-content/uploads/.../possible_worlds.pdf`) — this PDF is known to be
distributed on the author's personal website, i.e., read by people who may have no access to this
repository or its `LICENSE` file at all.

**Recommended replacement** (self-contained, does not depend on repo access):

```typst
    #text(size: 9pt)[© 2026 Benjamin Brast-McKie. Licensed under the Apache License, Version 2.0.]
```

If a clickable/verifiable reference is preferred, the standard Apache-2.0 canonical URL can be
appended, consistent with how the file already renders links elsewhere (e.g. `:107`'s
`#link(...)`):

```typst
    #text(size: 9pt)[© 2026 Benjamin Brast-McKie. Licensed under the #link("https://www.apache.org/licenses/LICENSE-2.0")[Apache License, Version 2.0].]
```

Either form is acceptable; the requirement is that the rendered notice name the license by name,
not merely point to a repo-relative file a standalone-PDF reader cannot resolve.

### README.md edit — `README.md:221-226` (verbatim, current)

```markdown
## License

This project is licensed under Apache-2.0. See [LICENSE](LICENSE) for details.

The reference manual source `Theories/Bimodal/typst/BimodalReference.typ` is the one carve-out: it
carries an all-rights-reserved notice and is not covered by the Apache-2.0 grant.
```

**Replacement** (carve-out paragraph removed; the statement is now unconditionally true):

```markdown
## License

This project is licensed under Apache-2.0. See [LICENSE](LICENSE) for details.
```

### PDF regeneration

`Theories/Bimodal/BimodalReference.pdf` reproduces the old notice verbatim (Finding 4) and must
be regenerated once the source edits above land. Exact procedure, precedented by the archived
task that originally added this notice (`specs/archive/372_copyright_bimodalreference_pdf_typst`):

```bash
cd Theories/Bimodal/typst
typst compile BimodalReference.typ build/BimodalReference.pdf
# build/ is gitignored/untracked; copy the fresh build over the tracked path
cp build/BimodalReference.pdf ../BimodalReference.pdf
```

**Toolchain confirmed present**: `typst` is available in this environment at
`/run/current-system/sw/bin/typst`, so this step is directly executable by the implementation
phase. It was not run in this research dispatch since research-only scope disallows edits.

Verification precedent from task 372's summary: confirm `typst compile` exits 0 with no new
errors, then `pdftotext` the rebuilt PDF's title page and confirm it now reads the new Site 2
wording instead of "All rights reserved.", and confirm `git status` shows only
`Theories/Bimodal/typst/BimodalReference.typ`, `Theories/Bimodal/BimodalReference.pdf`, and
`README.md` as touched.

### Recommendation for `latex/` (consistency improvement, not a licensing change)

Since `latex/BimodalReference.tex` and its subfiles carry no notice at all (Finding 3), a reader
of that file alone currently sees no license information whatsoever, even though the content is
(and after this edit remains) covered by the repo-wide Apache-2.0 statement by default. Adding a
short header comment mirroring Site 1 above — e.g.:

```latex
% Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
% Released under Apache 2.0 license as described in the file LICENSE.
```

to `Theories/Bimodal/latex/BimodalReference.tex` (and optionally `BimodalDemo.tex`) would let a
reader of that file alone know its license without needing to find the repo-root README. This is
recommended as a consistency/clarity improvement, not required by option (a) — the content is
already Apache-2.0 by default regardless. Leave to the implementation phase's discretion whether
to include it in this task's scope or defer.

### Final consistency check (post-edit expected state)

- **279 live `.lean` files under `Theories/`**: unaffected, no contradiction.
- **200 `Theories/Bimodal/Boneyard/` `.lean` files**: no header, pre-existing/expected, no
  contradiction.
- **`README.md` and `LICENSE`**: after the edit, README states an unqualified Apache-2.0 license
  with no remaining carve-out — consistent with `LICENSE` and the edited `.typ` source.
- **`Theories/Bimodal/typst/BimodalReference.typ`**: after Site 1/2 edits, both notice sites state
  Apache-2.0, consistent with each other, README, and `LICENSE`.
- **`Theories/Bimodal/BimodalReference.pdf`**: after regeneration, matches the edited source.
- **`Theories/Bimodal/latex/`**: no notice (or an added consistency notice per the recommendation
  above); either way, no contradiction — implicitly or explicitly Apache-2.0.
- **`Tests/BimodalTest/` (3 files)**: explicitly out of scope for this task, owned by another
  task in this batch — left untouched here, not part of this edit spec.
- No file anywhere asserts GPL-3.0 or any license other than Apache-2.0, once this edit and the
  separately-owned Tests/ fix land.

## Decisions

- Option (a) authorized and adopted per `specs/401_align_typst_manual_license_with_apache/DECISION.md`.
  Options (b) and (c) declined by the copyright holder.

## Risks & Mitigations

- **Risk**: the rendered title-page notice (Site 2) is edited to reference "the file LICENSE" the
  same way the source comment does, which would be meaningless to someone who only has the
  standalone PDF. **Mitigation**: Site 2's recommended text names the license explicitly rather
  than pointing to a repo-relative file.
- **Risk**: the PDF is not regenerated after the source edit, leaving a stale "All rights
  reserved." notice in the distributed artifact. **Mitigation**: exact, precedented regeneration
  command and verification steps given above; toolchain availability confirmed.
- **Risk**: the Tests/ notice inconsistency gets double-edited by this task as well as the other
  task that owns it. **Mitigation**: explicitly called out as out of scope and owned elsewhere;
  implementation should not touch `Tests/BimodalTest/*.lean` under task 401.

## Context Extension Recommendations

None — this is a one-off licensing edit specific to this repository's history, not a reusable
pattern worth adding to `.claude/context/`.

## Appendix

- Search queries used: `grep -rn -i "copyright|all rights reserved|released under|licensed
  under"` repo-wide excluding `docs/research/` and `specs/literature/`; `git ls-files "*.lean"`
  counts and header-presence checks scoped to `Theories/` and `Tests/`; `pdftotext` extraction of
  `BimodalReference.pdf`; `git log` provenance checks on `latex/`, `typst/`, and the PDF.
- Key files read: `Theories/Bimodal/typst/BimodalReference.typ` (lines 1-130), `README.md` (lines
  200-226), `Theories/Bimodal/typst/README.md`, `Theories/Bimodal/latex/README.md`, `LICENSE`
  (header), `Tests/BimodalTest/TraceExportTest.lean` (header),
  `specs/401_align_typst_manual_license_with_apache/DECISION.md`,
  `specs/archive/372_copyright_bimodalreference_pdf_typst/summaries/01_copyright-implementation-summary.md`.
