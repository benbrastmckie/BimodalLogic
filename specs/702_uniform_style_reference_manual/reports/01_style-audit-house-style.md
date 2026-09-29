# Research Report: Uniform Style Audit for the Typst Reference Manual

- **Task**: 702 - Improve the formatting and content of the Typst reference manual so every chapter follows one uniform style
- **Started**: 2026-09-28T00:00:00Z
- **Completed**: 2026-09-28T00:00:00Z
- **Effort**: ~2 hours (audit + mechanical checks)
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/context/project/typst/standards/typst-style-guide.md`
  - `.claude/context/project/typst/standards/document-structure.md`
  - `.claude/context/project/typst/standards/semantic-element-usage.md`
  - `.claude/context/project/typst/standards/chapter-quality.md`
  - `.claude/context/project/typst/standards/textbook-standards.md`
  - `.claude/context/project/typst/standards/notation-conventions.md`
  - `typst/template.typ`, `typst/README.md`, `typst/chapters/README.md`, `typst/SYNC-MAP.md` (headers)
  - All 17 files under `typst/chapters/*.typ`
  - `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/*.typ`
  - `bash .claude/scripts/chapter-quality-check.sh --verbose typst/chapters/*.typ`
  - `typst compile --root .. BimodalReference.typ` (baseline compile check)
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- The manual currently compiles cleanly (0 warnings, 105 pages) but fails both mechanical
  gates: `typst-element-lint.sh` reports **8 BLOCKING placement failures** in three chapters,
  and `chapter-quality-check.sh` reports **296 BLOCKING findings**, of which **288 (97%) are a
  single root cause**: Lean file paths cited in backticks omit the `FormalSystem/` prefix
  (e.g. `` `Syntax/Formula.lean` `` instead of `` `FormalSystem/Syntax/Formula.lean` ``), so the
  checker's live-tree resolution fails even though the paths are correct once read as
  module-namespace-relative. This single citation-convention decision is the highest-leverage
  fix in the whole task.
- The manual has two generations of chapters with visibly different conventions: the
  original `00`-`06` numbered chapters (written first) and the later `p2-`/`p3-`/`p4-` chapters
  (Part I/II content interleaved with the numbered chapters in actual reading order per
  `typst/README.md`, despite the filename prefixes suggesting separate "parts 2-4"). The later
  chapters uniformly adopt a `#chapter-header(description:, dependencies:)` opening block and
  the `#leansrc(module, name)` citation macro; the earlier chapters use neither, relying on bare
  chapter titles and raw-backtick-plus-footnote Lean citations instead.
- Chapter-opening rhythm is inconsistent independent of the `#chapter-header` question: three
  files (`04-metalogic.typ`, `05-theorems.typ`, `06-notes.typ`) have subsections that open
  directly with `#theorem`/`#definition`/`#lemma`/`#remark` and no prose, violating the Universal
  Placement Rule (`semantic-element-usage.md`). `05-theorems.typ` is the most extreme case: three
  of its four `==` sections open directly on a semantic element, and its centerpiece section
  presents six consecutive `#theorem` blocks with zero prose between them.
- Cross-reference phrasing is inconsistent: most chapters use Typst's native `@sec:`/`@ch:` label
  system as `document-structure.md` requires, but seven files also use un-linked prose like "the
  semantics chapter" or "the theorems chapter" instead; `p3-ltl-to-tm.typ` does this five times.
- A handful of chapters carry local `#let` helper definitions
  (`03-proof-theory.typ`, `p4-proof-automation.typ` ×4) that duplicate formatting logic better
  centralized in `template.typ`, a minor violation of `document-structure.md`'s "no configuration
  in chapters" guideline. The two appendices' local overrides are out of scope (owned by the
  sibling Lean-appendix tasks named in the dispatch) and are noted but not analyzed further.
- List syntax is inconsistent in a way with no clear mechanical winner: 14 of 17 files use native
  Typst bullet lists (`- item`) as `typst-style-guide.md`'s Standard List Requirement mandates;
  the three newest `p4-` chapters instead use the custom `#items[#item[...]]` wrapper defined in
  `template.typ`. Both are internally consistent with *something*; this is the one axis genuinely
  requiring the PLAN phase's judgment rather than a rule I can resolve from research.

## Context & Scope

Task 702 asks RESEARCH to audit every chapter of `typst/BimodalReference.typ` (compiled from
`typst/chapters/00-introduction.typ` through the two back-matter appendices) against the typst
extension's six style standards and the two mechanical backstops, then to define a single house
style the whole manual will follow. Content changes are in scope only as editorial uniformity
(openings, transitions, motivation density, terminology, cross-references) — no new theorems,
proofs, or chapters. The Lean appendix's own define-before-use audit and code-environment
convention are owned by sibling tasks; this report defers to them and does not re-litigate
`ax-lean-appendix.typ`'s internal content, though it does record the appendix's placement in the
mechanical-lint results for completeness.

Actual book order (per `typst/README.md`, not filename order) is:
`00-introduction` -> `01-syntax` -> `02-semantics` -> `03-proof-theory` -> `p2-frame-classes` ->
`04-metalogic` -> `p2-decidability-practice` -> `05-theorems` -> `p3-ltl-to-tm` ->
`p3-vlach-blstar` -> `p3-decidability-frontier` -> `p4-proof-automation` ->
`p4-dataset-pipeline` -> `p4-dual-verification` -> `06-notes` -> `ax-lean-appendix` ->
`ax-machine-appendix`. The `p2`/`p3`/`p4` filename prefixes are a historical chapter-numbering
artifact, not a real Part III/IV structure; Parts III/IV were cut (`typst/README.md`'s
Follow-Up Work table). The style sheet below treats the manual as one continuous sequence, not as
four "parts" with different rules.

## Findings

### Mechanical baseline (current state, before any fix)

- **Compile**: `typst compile --root .. BimodalReference.typ` succeeds cleanly, 0 warnings,
  105 pages (the dispatch's "128 pages" figure is stale; verify against a fresh compile before
  citing a page count in any artifact).
- **`typst-element-lint.sh --verbose`**: 8 BLOCKING placement failures, 1 ADVISORY density
  warning, across 3 of 17 files.
- **`chapter-quality-check.sh --verbose`**: 296 BLOCKING findings total. 288 are Rule 1.2
  (unresolved backticked path); the remaining 8 are the same placement failures the element-lint
  already reports. Zero Rule 1.3 (bib key), 1.5 (malformed `CONFIRM`), or 3.2 (heading depth)
  BLOCKING findings anywhere — those three mechanical rules are already clean manual-wide.

Per-file mechanical score (from `chapter-quality-check.sh`'s `SCORE` line; `JUDGED` counts are
structured reviewer prompts for the PLAN/IMPLEMENT phases, not resolved here):

| File | MECHANICAL | BLOCKING | ADVISORY | JUDGED prompts |
|---|---|---|---|---|
| `00-introduction.typ` | 2/6 | 16 | 12 | 12 |
| `01-syntax.typ` | 4/6 | 4 | 2 | 10 |
| `02-semantics.typ` | 2/6 | 10 | 13 | 13 |
| `03-proof-theory.typ` | 3/6 | 6 | 6 | 22 |
| `04-metalogic.typ` | 3/6 | 65 | 4 | 20 |
| `05-theorems.typ` | 3/6 | 24 | 2 | 14 |
| `06-notes.typ` | 2/6 | 5 | 10 | 19 |
| `ax-lean-appendix.typ` | 2/6 | 46 | 27 | 35 |
| `ax-machine-appendix.typ` | 5/6 | 3 | 0 | 8 |
| `p2-decidability-practice.typ` | 3/6 | 31 | 8 | 15 |
| `p2-frame-classes.typ` | 2/6 | 13 | 7 | 13 |
| `p3-decidability-frontier.typ` | 5/6 | 0 | 1 | 14 |
| `p3-ltl-to-tm.typ` | 3/6 | 0 | 6 | 15 |
| `p3-vlach-blstar.typ` | 2/6 | 1 | 5 | 14 |
| `p4-dataset-pipeline.typ` | 3/6 | 22 | 3 | 16 |
| `p4-dual-verification.typ` | 4/6 | 21 | 1 | 12 |
| `p4-proof-automation.typ` | 3/6 | 29 | 6 | 17 |

`p3-decidability-frontier.typ` and `p3-ltl-to-tm.typ` are the only two files with zero BLOCKING
findings today, because neither cites a single Lean path in backticks (both are prior-art/survey
chapters with no direct Lean declarations to cite).

### Root cause 1 — Lean path-citation convention (288 of 296 BLOCKING findings)

Every affected file writes a Lean source path relative to `FormalSystem/` without the prefix,
e.g. `` `Syntax/Formula.lean` ``, `` `ProofSystem/Axioms.lean` ``, `` `Metalogic/Soundness.lean` ``,
`` `Automation/` ``. These paths are real — `FormalSystem/Syntax/Formula.lean` etc. all
exist — but `chapter-quality-check.sh`'s Rule 1.2 resolves a backticked path against the repo
root and the chapter's own directory only (`.claude/scripts/chapter-quality-check.sh:411`,
`check_backtick_paths`), neither of which is `FormalSystem/`. Worst offenders:
`p4-dual-verification.typ` (`Examples/TemporalStructures.lean` ×11, `Examples/BimodalProofs.lean`
×7), `ax-lean-appendix.typ`, `p2-decidability-practice.typ`, `p4-proof-automation.typ`,
`p2-frame-classes.typ`, `p4-dataset-pipeline.typ`. This is not a content defect — the names are
correct — it is a citation-format defect, and it is uniform enough across the manual that fixing
the convention once (see Decisions below) resolves the overwhelming majority of the mechanical
gate in one uniform edit per chapter.

A second, smaller pattern exists alongside the bare-path one: the `#leansrc(module, name)` macro
(defined in `template.typ`, taking a dotted module path and declaration name, e.g.
`#leansrc("FormalSystem.ProofSystem", "FrameClass")`) is already used by 8 of 17 files but is
**never** used by the original `00`-`06` chapters, which instead cite Lean names exclusively via
raw backticks plus prose or `#footnote[...]`. `#leansrc` calls do not trigger Rule 1.2 at all
(they are not backtick-delimited path tokens), so a chapter that used it consistently would have
had zero Rule 1.2 findings for its declaration citations without any path-prefix fix at all.

| File | `#leansrc(...)` calls | Bare-backtick `.lean` mentions | Footnote count |
|---|---|---|---|
| `00-introduction.typ` | 0 | 1 | 0 |
| `01-syntax.typ` | 0 | 4 | 4 |
| `02-semantics.typ` | 0 | 10 | 10 |
| `03-proof-theory.typ` | 0 | 6 | 0 |
| `04-metalogic.typ` | 0 | 25 | 10 |
| `05-theorems.typ` | 0 | 15 | 0 |
| `06-notes.typ` | 0 | 2 | 1 |
| `ax-lean-appendix.typ` | 36 | 6 | 0 |
| `p2-decidability-practice.typ` | 3 | 28 | 1 |
| `p2-frame-classes.typ` | 2 | 13 | 0 |
| `p3-decidability-frontier.typ` | 1 | 0 | 0 |
| `p3-ltl-to-tm.typ` | 1 | 0 | 0 |
| `p3-vlach-blstar.typ` | 1 | 0 | 1 |
| `p4-dataset-pipeline.typ` | 1 | 19 | 4 |
| `p4-dual-verification.typ` | 1 | 20 | 7 |
| `p4-proof-automation.typ` | 1 | 23 | 0 |

`p2-decidability-practice.typ` and `p4-proof-automation.typ` demonstrate that even chapters that
already use `#leansrc` for the "headline" theorem still fall back to bare-backtick paths
everywhere else in the same chapter (`p2-decidability-practice.typ` alone accounts for 28 bare
mentions against only 3 `#leansrc` calls) — the macro is not being used as the default citation
form even where it is already imported and known.

### Root cause 2 — element-placement violations (8 BLOCKING, all in 3 files)

| File | Line | Violating element | Heading with no intervening prose |
|---|---|---|---|
| `04-metalogic.typ` | 50 | `#theorem` | `=== Deduction Theorem` (line 48) |
| `04-metalogic.typ` | 63 | `#definition` | `=== Consistency` (line 61) |
| `04-metalogic.typ` | 76 | `#lemma` | `=== Lindenbaum's Lemma` (line 74) |
| `05-theorems.typ` | 71 | `#theorem` | `== Modal S5 Theorems` (line 69) |
| `05-theorems.typ` | 129 | `#theorem` | `== Propositional Theorems` (line 127) |
| `05-theorems.typ` | 175 | `#theorem` | `== Generalized Necessitation` (line 173) |
| `06-notes.typ` | 111 | `#remark` | `=== S5-Hood Does Not Single Out Metaphysical Necessity` (line 109) |
| `06-notes.typ` | 120 | `#remark` | `=== Historical Context` (line 118) |

`05-theorems.typ` also carries the manual's only ADVISORY remark-density warning from the element
lint is *absent* here (it has 1 remark vs. 31 theorem-family elements — clean on density, unlike
`06-notes.typ`, which trips the "more remarks than theorems" advisory at 4 remarks vs. 1
theorem-family element). `05-theorems.typ`'s deeper problem is prose density, not remark misuse:
its "Perpetuity Principles" section opens with one paragraph and then presents six `#theorem`
blocks (P1-P6) back to back with zero connecting prose between any of them — compliant with the
letter of the Universal Placement Rule (the section itself opens with prose) but the sparsest
discussion rhythm in the manual by a wide margin, and in tension with `semantic-element-usage.md`'s
Theorem entry ("A chapter that is mostly theorems with no connective prose has skipped the
exposition that makes the results legible").

### Opening-pattern and structural audit, per chapter

Legend: **CH** = uses `#chapter-header(description:, dependencies:)`; **Open** = first body
content after the `=` heading (prose vs. none before the first `==`); **Discussion style** =
motivation-first / statement-first / mixed, judged from a direct read of each file's openings and
representative sections (not a mechanical count).

| File | CH? | Chapter-level opening | Discussion style |
|---|---|---|---|
| `00-introduction.typ` | No | 5 dense narrative paragraphs before first `==` | Motivation-first, essay-like; 0 theorem-family elements |
| `01-syntax.typ` | No | None — title falls straight into `== Formulas` | Statement-first; one sentence before `#definition("Formula")`, thin on the 2-sentence motivation minimum |
| `02-semantics.typ` | No | None — straight into `== Task Frames` | Mixed; short intro paragraphs before each definition, tables used heavily |
| `03-proof-theory.typ` | No | 1 paragraph of chapter-level framing before first `==` | Motivation-first at chapter level; subsections lean on tables rather than prose |
| `04-metalogic.typ` | No | 1 paragraph of chapter-level framing before first `==` | Mixed — chapter-level motivation present, but 3 of its `===` subsections skip subsection-level motivation entirely (Root cause 2) |
| `05-theorems.typ` | No | None — straight into `== Perpetuity Principles` | Statement-first; least prose-dense chapter in the manual |
| `06-notes.typ` | No | None — straight into `== System Overview` | Mixed; back-matter/status register, 2 subsections skip motivation (Root cause 2), remark-heavy |
| `ax-lean-appendix.typ` | N/A (custom appendix heading, out of scope) | Primer-style, own numbering scheme | Expository primer; out of scope for content per dispatch |
| `ax-machine-appendix.typ` | N/A (custom appendix heading, out of scope) | 3 paragraphs before first generated table | Motivation-first, short |
| `p2-decidability-practice.typ` | Yes | `#chapter-header` then `== Decidability` with 3 paragraphs before first element | Motivation-first |
| `p2-frame-classes.typ` | Yes | `#chapter-header` then prose + table + cetz diagram | Motivation-first |
| `p3-decidability-frontier.typ` | Yes | `#chapter-header` then prose survey, 0 theorem-family elements | Pure narrative/survey |
| `p3-ltl-to-tm.typ` | Yes | `#chapter-header` then comparative-essay prose, 0 theorem-family elements | Narrative/comparative; heaviest un-linked "X chapter" prose cross-referencing (5 instances) |
| `p3-vlach-blstar.typ` | Yes | `#chapter-header` then historical-motivation prose (Kamp/Vlach) before `#definition` | Motivation-first |
| `p4-dataset-pipeline.typ` | Yes | `#chapter-header` then practitioner-framing prose | Motivation-first |
| `p4-dual-verification.typ` | Yes | `#chapter-header` then an external block quote + footnote, then `#items[...]` list | Motivation-first |
| `p4-proof-automation.typ` | Yes | `#chapter-header` then local `#let` helpers before `== Tactics` prose | Motivation-first |

The `#chapter-header` split is exact and total: every one of the 8 `p2`/`p3`/`p4` chapters uses
it; none of the 7 numbered `00`-`06` chapters do. This is a chronological convention shift, not a
deliberate content-type distinction — the `#chapter-header`'s `description`/`dependencies` fields
apply equally well to `01-syntax.typ` or `05-theorems.typ` as to any `p2`-`p4` chapter, and the
field content it renders (what the chapter covers, what it assumes) is exactly the
`textbook-standards.md` Chapter Structure requirement ("Prerequisites stated explicitly", "Chapter
outline") that the `00`-`06` chapters currently satisfy only informally, if at all, in ad hoc
prose.

### Cross-reference phrasing

| File | `@sec:`/`@ch:`/`@thm:` link count | Un-linked "the X chapter" / "see Chapter N" prose |
|---|---|---|
| `00-introduction.typ` | 21 | 0 |
| `01-syntax.typ` | 0 | 1 |
| `02-semantics.typ` | 7 | 0 |
| `03-proof-theory.typ` | 8 | 1 |
| `04-metalogic.typ` | 6 | 0 |
| `05-theorems.typ` | 0 | 0 |
| `06-notes.typ` | 6 | 2 |
| `ax-lean-appendix.typ` | 29 | 2 |
| `p2-frame-classes.typ` | 7 | 1 |
| `p3-ltl-to-tm.typ` | 6 | 5 |
| `p3-vlach-blstar.typ` | 4 | 1 |
| `p4-proof-automation.typ` | 4 | 1 |

`document-structure.md`'s Cross-Chapter References section already mandates the label/`@`-ref
pattern; the un-linked instances above are drift from an already-stated standard, not a competing
convention needing a fresh decision.

### Local `#let` leakage into chapter files

`document-structure.md`'s Chapter Guidelines state "No configuration: No `#set` or `#show` rules
in chapters" and "Single import: Only `#import "../template.typ": *`". No chapter violates the
letter of that (no bare `#set`/`#show` outside the two appendices, which are out of scope), but
four non-appendix files define local `#let` helpers that duplicate formatting logic that
arguably belongs in `template.typ` instead:

- `03-proof-theory.typ:319` — `derivation-tree-rule(name)` (raw-text formatting helper).
- `p4-proof-automation.typ:17,28,115,130` — `fmt-lines(n)` (thousands-separator formatter),
  `module-lines(path)` (generated-table lookup helper), `roles`, `all-sorry-free`.

These are formatting-only helpers with no chapter-specific content, and centralizing them in
`template.typ` (available to every chapter, not redefined per file) is a pure editorial-uniformity
move with no content change — in scope for this task's PLAN phase. `p2-frame-classes.typ` also
defines a `module-lines`-style lookup inline (not counted above; verify at PLAN time whether it
duplicates the `p4-proof-automation.typ` helper or is genuinely distinct).

`ax-lean-appendix.typ`'s local `#leansrc` override (shadowing the template's own `leansrc` with a
`sticky: true` page-break-avoidance variant) and its local `#show raw.where(...)`/`#show
figure.where(...)` rules are intentionally scoped to that appendix's own typographic needs and are
self-documented; per the dispatch's out-of-scope list (tasks 649/650 own this appendix's
conventions) this report records the finding but does not recommend changing it.

### List-syntax split (no mechanical winner)

`typst-style-guide.md`'s Standard List Requirement says "All bullet lists MUST use standard Typst
list syntax (`- Item`)." 14 of 17 files already comply. The three newest chapters instead use the
`#items[#item[...]]`/`#item[...]` wrapper defined in `template.typ`
(`p4-dataset-pipeline.typ` ×1, `p4-dual-verification.typ` ×1, `p4-proof-automation.typ` ×1):

| File | `#items[` blocks | Native `- ` bullets |
|---|---|---|
| `00-introduction.typ` | 0 | 13 |
| `03-proof-theory.typ` | 0 | 12 |
| `04-metalogic.typ` | 0 | 16 |
| `06-notes.typ` | 0 | 7 |
| `ax-lean-appendix.typ` | 0 | 60 |
| `p4-dataset-pipeline.typ` | 1 | 3 |
| `p4-dual-verification.typ` | 1 | 0 |
| `p4-proof-automation.typ` | 1 | 0 |

Neither checker script flags this axis (`typst-element-lint.sh` and `chapter-quality-check.sh`
have no rule for list-macro choice), and both directions are internally consistent with something
real: the documented standard prefers native lists and native lists are already the majority
practice, but `#items[]` provides bullet/enum spacing control (`spacing: 0.65em`,
`marker: [--]`) that plain `- ` lists inherit only from whatever the main document's global `#set
list` establishes. This is the one style-sheet axis this report leaves as an open decision for
the PLAN phase rather than resolving outright (see Decisions below).

### Confirmed-clean, no change needed

- **Table conventions**: every sampled chapter uses `#figure(table(columns:, stroke: none,
  table.hline(), table.header(...), ...), caption: none)` uniformly, matching
  `typst-style-guide.md`'s Standard Table Format exactly. No divergence found.
- **`CONFIRM` marker syntax**: Rule 1.5 (well-formed `CONFIRM:` payload) produced zero BLOCKING
  findings manual-wide — the convention is already used correctly everywhere it appears.
- **Heading depth**: Rule 3.2 (no heading past `===`) produced zero BLOCKING findings
  manual-wide.
- **Bibliography keys**: Rule 1.3 produced zero BLOCKING findings manual-wide (not evaluated by
  the checker where no single `.bib` resolves per its own KNOWN LIMITATIONS note, but no `@key`
  mismatch was otherwise flagged).
- **Notation symbols**: no chapter defines a local math-mode `#let` shorthand outside
  `notation/bimodal-notation.typ`; every sampled symbol traces to the shared/project notation
  files as `notation-conventions.md` requires. The `srcref`/`coderef` commands that
  `notation-conventions.md` documents are, however, **unused everywhere** in the manual — every
  chapter that cites Lean uses `#leansrc`/`#leanref`/raw backticks instead (see Root cause 1). This
  is a documentation-vs-practice gap in `notation-conventions.md` itself, not a chapter defect;
  recommended fix is updating that context file, not the chapters (see Recommendations).

## Decisions

The house style below is assembled from the existing standards, not invented; each item cites the
standard it restates or the finding it resolves. It is proposed for the PLAN phase to encode as
the manual's single reference, not applied by this research dispatch.

1. **Chapter opening template (uniform across all `00`-`06` and `p2`/`p3`/`p4` chapters)**:
   `= Title <sec:id>` heading, immediately followed by `#chapter-header(description: [...],
   dependencies: [...])`, then the first `==` section opening with motivating prose (>= 2
   sentences per `textbook-standards.md`'s Motivation Requirements) before any semantic element.
   Extends the already-majority (8/17) `#chapter-header` convention to the 7 `00`-`06` chapters
   that currently lack it; the two appendices keep their own out-of-scope heading scaffolding.
2. **Section/subsection-opening rhythm**: every `==`/`===` heading is followed by prose stating
   the reader need before any `#definition`/`#theorem`/`#lemma`/`#example`/`#remark` — this is
   `semantic-element-usage.md`'s Universal Placement Rule, already BLOCKING-enforced; it resolves
   the 8 element-lint failures in `04-metalogic.typ`, `05-theorems.typ`, `06-notes.typ` directly.
3. **Element order within a section**: motivation prose -> `#definition` -> optional grounding
   `#example` -> prose stating why the result matters -> `#theorem`/`#lemma` -> `#proof` (closed
   with `#qed`, immediately after) -> sparing `#remark` only after a landed result, never as an
   opener. Restates `semantic-element-usage.md`'s per-element placement entries verbatim; directly
   targets `05-theorems.typ`'s six-theorems-with-no-prose run for a prose pass, not new proofs.
4. **Lean-declaration citation convention (resolves 288/296 BLOCKING findings)**: use
   `#leansrc(module, name)` (already defined in `template.typ`) for the first citation of a
   declaration in a section, and bare backticked identifier-only mentions (no path,
   e.g. `` `Formula` ``) for every subsequent mention in the same section. Never cite a bare
   repo-relative Lean file path in backticks or a footnote (the
   `` `Syntax/Formula.lean` ``-shaped pattern) — if a file path must be cited at all (for example
   in a comment about module structure, not a declaration citation), it must be the full
   `` `FormalSystem/Syntax/Formula.lean` `` path so it resolves under Rule 1.2. This closes the
   root cause identified above and standardizes on the macro the newer chapters already
   introduced, rather than inventing a third convention.
5. **Cross-reference phrasing**: always use the native `@sec:`/`@ch:`/`@thm:` label/ref system
   (`document-structure.md`'s existing mandate); never prose like "the semantics chapter" with no
   link. Closes the 7-file, 12-instance drift found above, concentrated in `p3-ltl-to-tm.typ`.
6. **Chapter-local `#let` helpers**: promote pure-formatting helpers
   (`derivation-tree-rule`, `fmt-lines`, `module-lines`) from `03-proof-theory.typ` and
   `p4-proof-automation.typ` into `template.typ` so no non-appendix chapter carries a local `#let`;
   restates `document-structure.md`'s "no configuration in chapters" guideline. Out of scope for
   the two appendices per the dispatch.
7. **Lists**: PLAN phase must pick one of native `- `/`+ ` lists (matches the documented standard
   and 14/17 existing files) or the `#items[]`/`#item[]` wrapper (matches 3 newest files' spacing
   control) uniformly, and apply it manual-wide. This report does not resolve which; both are
   defensible and neither checker enforces either. Recommendation, not a decision: prefer native
   lists, since it is both the documented standard and the majority existing practice, and
   deprecate `#items[]` in `template.typ` with a comment rather than deleting it outright (other
   documents may still reference it).
8. **`06-notes.typ` remark density**: resolve the "4 remarks vs. 1 theorem" ADVISORY finding by
   moving the two currently-opener remarks' content into ordinary prose, or into the chapter's
   existing `== Design Notes` section (already present, already the right kind of home per
   `semantic-element-usage.md`'s "Where Tracking Content Belongs"), rather than deleting content.
9. **`notation-conventions.md` documentation gap**: update that context file to note `#leansrc`/
   `#leanref` (defined in `template.typ`) as the manual's actual Lean-citation commands, and mark
   `srcref`/`coderef` as either superseded or reserved for a future document — they are currently
   dead documentation describing commands no chapter calls. This is a `.claude/context/` edit
   under the source-store/deploy boundary rule, not a `typst/` chapter edit.

## Recommendations

1. Write the style sheet from the Decisions section above into `typst/STYLE.md` (new file,
   referenced from `typst/README.md`), grounded in the six standards cited throughout this report
   — this satisfies the dispatch's acceptance criterion that the style sheet is committed
   alongside the chapters for future reference.
2. Size PLAN phases per chapter or per natural pair (e.g. `p2-frame-classes.typ` +
   `p2-decidability-practice.typ`, or `p3-ltl-to-tm.typ` + `p3-vlach-blstar.typ` +
   `p3-decidability-frontier.typ`, which already share `#chapter-header` conventions and low
   BLOCKING counts), each phase ending with a clean `typst compile` and both lints run, per the
   dispatch's explicit phase-sizing requirement. Order phases by BLOCKING-count leverage first:
   `04-metalogic.typ` (65), `ax-lean-appendix.typ` (46, but content-restricted — coordinate,
   do not duplicate, sibling tasks 649/650), `p2-decidability-practice.typ` (31),
   `p4-proof-automation.typ` (29), `05-theorems.typ` (24) account for the bulk of the mechanical
   gate.
3. Apply the `#chapter-header` extension (Decision 1) and the Lean-citation convention
   (Decision 4) together per chapter, since both touch the same opening/citation surface and a
   single pass through a chapter can fix both at once.
4. For `05-theorems.typ` specifically, budget prose-writing time, not just citation-format fixes:
   its P1-P6 theorem run needs at minimum one connective sentence between theorems (why each
   follows from or relates to the last) to meet the Theorem entry's "sparse relative to prose"
   expectation, beyond what is needed merely to clear the BLOCKING lint gate.
5. Before writing any hand-typed count, version, or Lean status claim into a rewritten opening or
   transition, verify it against `typst/generated/status.typ` (already the mechanism 8 of the
   chapters use via `#axiom-count`/`#rule-count`/etc. imports) or `SYNC-MAP.md`, per the dispatch's
   explicit instruction and Rule 1.4 of `chapter-quality.md`.
6. Re-run both lints and a full compile after each phase; do not batch multiple chapters into one
   uncompiled phase, since the dispatch and `chapter-quality.md`'s scoring convention both expect
   per-file, not per-task, verification.

## Risks & Mitigations

- **Risk**: uniform-style edits could silently change a claim's meaning (e.g. rewording "the
  soundness theorem holds for all four frame classes" while touching its citation). **Mitigation**:
  treat every edit as citation/format-only; any sentence whose truth value could change requires
  re-verifying against `FormalSystem/` source or `SYNC-MAP.md`, not just reformatting.
- **Risk**: extending `#chapter-header` to `00-06` chapters touches the manual's opening pages,
  which are also where `p3-decidability-frontier.typ`'s embargo note lives (do not touch that
  file's `// SLOT-IN:` anchors or embargo comment — out of scope, and explicitly protected by that
  file's own header). **Mitigation**: PLAN phase for that file should scope strictly to
  style-sheet conformance of the surrounding prose, never the embargoed content.
- **Risk**: the 288 path-prefix fixes are individually mechanical but numerous (up to 28 in one
  file); a bulk find/replace risks over-matching paths that are already correct or that cite a
  file outside `FormalSystem/` (e.g. `training/PIPELINE.md`, `references.bib`,
  `scripts/typst-status-counts.sh`, all of which resolve correctly today from repo root and must
  not be re-prefixed). **Mitigation**: fix per-occurrence, re-running the lint after each
  chapter's pass rather than trusting a single repo-wide substitution.

## Appendix

- Full mechanical lint output: `typst-element-lint.sh --verbose` and
  `chapter-quality-check.sh --verbose` were run against all 17 files under `typst/chapters/`
  during this research session; the summarized tables above are derived directly from that output
  (not re-included verbatim here per report-format.md's Appendix guidance against duplicating
  Findings content).
- `typst/generated/status.typ` stamp at audit time: commit `2fb0c5327`, date `2026-09-28`,
  `axiom-count = 29`, `rule-count = 7`.
- Baseline compile: `typst compile --root .. BimodalReference.typ` from `typst/`, 0 warnings,
  105 pages (verify freshly before citing in the plan or summary, since chapter edits will change
  page count).
