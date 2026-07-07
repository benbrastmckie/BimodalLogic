# Phase 1 Handoff: Template and Bibliography Port

**Status**: COMPLETED
**Files touched**: `Theories/Bimodal/typst/template.typ`, `Theories/Bimodal/typst/bibliography.bib` (new), `Theories/Bimodal/typst/notation/bimodal-notation.typ`, `Theories/Bimodal/typst/BimodalReference.typ`

## What was done

- Ported `proposition`, `corollary`, `example`, `notation-env`, `leansrc`/`leanref`,
  `chapter-header`, `items`/`item`, `principles`/`principle`/`pr()`, and fletcher
  `extension-node` helpers from the Logos manual template into `template.typ`, leaving
  `thmbox-show`/`definition`/`theorem`/`lemma`/`axiom`/`remark`/`proof` untouched.
- Added the new `sync-banner(class, source:, note:)` helper (classes: `"check"`,
  `"sorries"`, `"paper"`, `"outlook"`) for the Phase 3 per-chapter banners.
- Added heading `supplement: "Chapter"` + `ref` show rule to `BimodalReference.typ`,
  and wired `#bibliography("bibliography.bib", style: "ieee")` into the back matter.
- Created `typst/bibliography.bib` with 10 seeded entries (2 primary Brast-McKie papers
  fully cited; 8 training-knowledge entries marked `note = {verify before print}`). No
  Lk entry (embargo).
- Documented the 3 notation-collision resolutions as comments in
  `notation/bimodal-notation.typ` (no code changes needed — already aligned).

## Deviation from plan

- `principle()`'s list-item bullet (`- *#number* ...`) and `pr()`'s use of `ref(label(...))`
  as ported verbatim from the Logos template do not compile under typst 0.14.2: labels
  attached inside a markdown list item are not referenceable ("cannot reference item" /
  "cannot reference sequence"). Fixed by (a) replacing the markdown list marker with a
  manually drawn `sym.bullet`, and (b) implementing `pr()` with `link(label(...))` instead
  of `ref(label(...))` (generic label link, since the target is inline content, not a
  headed/figure/equation element). Confirmed working via a scratch compile. This is a
  necessary fix, not a scope deviation — the ported functions are otherwise identical.

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 (font-substitution
warnings only, pre-existing). All new template helpers exercised in an isolated scratch
compile (`_scratch_test.typ`, removed after verification) with `#show: thmbox-show` applied.
