# Implementation Plan: Task #702

- **Task**: 702 - Improve the formatting and content of the Typst reference manual so every chapter follows one uniform approach in style and in the shape of its discussion
- **Status**: [IMPLEMENTING]
- **Effort**: 18 hours
- **Dependencies**: None (coordinates with sibling tasks 649, 650, 697 — see Non-Goals)
- **Research Inputs**: `specs/702_uniform_style_reference_manual/reports/01_style-audit-house-style.md`
- **Artifacts**: plans/01_uniform-style-reference-manual.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

The manual compiles cleanly today but fails both mechanical gates: `typst-element-lint.sh`
reports 8 BLOCKING placement failures across 3 files, and `chapter-quality-check.sh` reports 296
BLOCKING findings, 288 of which are one root cause (Lean file paths cited in backticks without
the `FormalSystem/` prefix). The plan therefore has three layers: write the house style sheet
once (Phase 1), centralize the shared template surface it depends on (Phase 2), then apply the
style sheet chapter by chapter in ten independent, parallel-safe phases (Phases 3-12), closing
with a whole-manual acceptance sweep (Phase 13).

Every chapter phase does the same four things in the same order: extend or normalize the
`#chapter-header` opening, convert Lean citations to the style sheet's convention, repair
section-opening prose where an element opens a section, and convert un-linked "the X chapter"
prose to native `@`-references. Each chapter phase ends with a clean
`typst compile --root .. BimodalReference.typ` plus both lints, so no phase can leave the manual
uncompilable. Chapter phases own disjoint file sets and touch neither `template.typ` nor each
other's chapters, so Phases 3-12 form one parallel wave.

### Research Integration

The audit's five load-bearing findings drive the phase structure directly:

- **Root cause 1** (288/296 BLOCKING findings are bare Lean paths missing the `FormalSystem/`
  prefix) makes the Lean-citation convention the highest-leverage decision in the task; every
  chapter phase carries it.
- **Root cause 2** (8 element-placement failures in `04-metalogic.typ`, `05-theorems.typ`,
  `06-notes.typ`) is concentrated in three files, which is why those three get their own or
  lightly-shared phases with prose-writing budget.
- The **`#chapter-header` split is exact and total**: all 8 `p2`/`p3`/`p4` chapters use it, none
  of the 7 numbered `00`-`06` chapters do. Extending it to the numbered chapters is the single
  biggest visible uniformity win.
- Per-file BLOCKING counts set the phase ordering: `04-metalogic.typ` (65),
  `ax-lean-appendix.typ` (46), `p2-decidability-practice.typ` (31), `p4-proof-automation.typ`
  (29), `05-theorems.typ` (24) carry the bulk of the gate.
- The audit's one deliberately-unresolved axis (native lists versus the `#items[]` wrapper) is
  resolved in this plan's Decisions section below.

Three audit facts were independently re-confirmed while writing this plan: the element lint
still reports exactly 8 failures and 1 advisory; `chapter-quality-check.sh` still reports 296
BLOCKING, of which 288 are Rule 1.2 and 8 are the delegated placement failures; and the
per-file score table is unchanged.

One audit assumption was found to be too optimistic and is corrected here: **not every bare path
becomes correct by prefixing `FormalSystem/`.** `00-introduction.typ:158` cites `` `Extension/` ``,
but the real path is `FormalSystem/Semantics/Extension/`, not `FormalSystem/Extension/`. This
confirms the audit's own bulk-substitution risk and is why every phase below requires
per-occurrence resolution against the live tree.

### Prior Plan Reference

No prior plan. This is round 1 for task 702.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch, and no roadmap phases are required.

## The House Style Sheet

This is the single house style the whole manual will follow. Phase 1 transcribes it verbatim
into `typst/STYLE.md`; every later phase enforces it. Each rule cites the standard it restates
or the finding it closes — nothing here is invented.

### 1. Chapter opening

Every chapter file opens with exactly this shape:

```
= Chapter Title <sec:chapter-id>

#chapter-header(
  description: [One sentence saying what the chapter covers.],
  dependencies: [What the reader must already have read, as @sec:/@ch: references.],
)
```

`connections:` is optional and used only where a Logos-architecture link is genuinely present.
The first `==` section then opens with at least two sentences of motivating prose before any
semantic element. Grounds: `textbook-standards.md` Chapter Structure ("Prerequisites stated
explicitly", "Chapter outline") and Motivation Requirements; closes the 7-file `#chapter-header`
gap. The two appendices keep their own heading scaffolding (out of scope, see Non-Goals).

### 2. Section and subsection rhythm

Every `==` and `===` heading is followed by prose stating the reader need — why the section
exists and what it lets the reader do — before any `#definition`, `#theorem`, `#lemma`,
`#example`, or `#remark`. Grounds: `semantic-element-usage.md`'s Universal Placement Rule,
already BLOCKING-enforced by both lints. Closes all 8 placement failures.

### 3. Element order within a section

Motivation prose, then `#definition`, then an optional grounding `#example`, then prose saying
why the next result matters, then `#theorem`/`#lemma`, then `#proof` closed with `#qed`
immediately after, then a sparing `#remark` only after a landed result. A `#remark` never opens
a section. Consecutive theorem blocks carry at least one connective sentence between them saying
how each relates to the last. Grounds: `semantic-element-usage.md`'s per-element placement
entries.

### 4. Lean citations

Three forms, each with one job. This is the convention that closes 288 of the 296 BLOCKING
findings.

| What is being cited | Form | Notes |
|---|---|---|
| A declaration, as a standalone attribution after a definition or theorem | `#leansrc("FormalSystem.Module.Path", "declName")` | Block-level; place on its own line after a colon-terminated sentence. Never mid-sentence. |
| A declaration mentioned inline in prose | `` `declName` `` or `#leanref("declName")` | Identifier only, no path, no `.lean`. |
| A file or directory cited as a file, not as a declaration | `` `FormalSystem/Syntax/Formula.lean` `` | Full repo-root-relative path, resolved per occurrence against the live tree. |

Never cite a bare module-relative path in backticks or a footnote (the
`` `Syntax/Formula.lean` ``-shaped pattern). When a `#leansrc` block already attributes a
declaration, the preceding prose does not repeat the file path — it names the module in words.
Grounds: `chapter-quality-check.sh` Rule 1.2 resolves a backticked path against the repo root
and the chapter's own directory only, so a module-relative path can never resolve;
`#leansrc`/`#leanref` are not backtick path tokens and never trip Rule 1.2.

### 5. Cross-references

Always the native label and reference system: `@sec:`, `@ch:`, `@thm:`. Never un-linked prose
like "the semantics chapter" or "see Chapter 3". Grounds: `document-structure.md`'s Cross-Chapter
References mandate; closes 12 drift instances across 7 files.

### 6. Lists

Native Typst list syntax (`- item`, `+ item`) everywhere. The `#items[]`/`#item[]` wrapper is
deprecated: it stays defined in `template.typ` behind a deprecation comment (other documents may
still reference it) but no chapter calls it. Grounds: `typst-style-guide.md`'s Standard List
Requirement, plus 14 of 17 files already comply. This resolves the audit's one open axis.

### 7. Tables and figures

`#figure(table(columns: ..., stroke: none, table.hline(), table.header(...), ...), caption: none)`,
unchanged. Grounds: `typst-style-guide.md`'s Standard Table Format; the audit found zero
divergence, so this rule is recorded to hold the line, not to drive edits.

### 8. No configuration or helpers in chapters

A chapter imports `../template.typ` and nothing else, and defines no local `#let`, `#set`, or
`#show`. Shared formatting helpers live in `template.typ`. Grounds: `document-structure.md`'s
Chapter Guidelines. The two appendices' scoped overrides are an out-of-scope exception.

### 9. Numbers and status claims

Every count, version, or status claim is imported from `typst/generated/status.typ` (for example
`#axiom-count`, `#rule-count`) or traced to `SYNC-MAP.md`. No hand-typed number. Grounds:
`chapter-quality.md` Rule 1.4 and the dispatch's explicit instruction.

## Goals & Non-Goals

**Goals**:

- Every chapter under `typst/chapters/` conforms to the style sheet above.
- `typst-element-lint.sh` reports zero blocking placement findings over `typst/chapters/*.typ`.
- `chapter-quality-check.sh` reports zero BLOCKING findings over `typst/chapters/*.typ`.
- `typst compile --root .. BimodalReference.typ` succeeds with no warning introduced by this task.
- The style sheet is committed as `typst/STYLE.md` and linked from `typst/README.md`.
- `notation-conventions.md` documents the manual's real Lean-citation commands.

**Non-Goals**:

- No new theorems, proofs, chapters, or sections. Content work is editorial uniformity only.
- The Lean appendix's define-before-use audit (task 650) and its Lean code-environment
  convention (task 649). Phase 12 touches `ax-lean-appendix.typ` for Rule 1.2 citation paths
  only and changes no code environment, no section order, and none of its local overrides.
- The generated status counts' staleness (task 697). Phases here read `typst/generated/` as
  ground truth and never hand-edit a count.
- `typst/FormalFoundations.typ`, a separate document.
- The `// SLOT-IN:` anchors and embargo comment in `p3-decidability-frontier.typ`.
- Resolving the 269 pending JUDGED reviewer prompts. They are reviewer prompts, not BLOCKING
  findings, and acceptance does not require them. Phase 8 answers the cheap Rule 2.2
  section-opening prompts opportunistically because the style sheet's rule 2 already covers them.

## Decisions

Two axes the research left open or flagged are resolved here, with rationale, rather than
deferred.

1. **Lists: native syntax wins.** It is both the documented standard and the practice in 14 of
   17 files, so it is the smaller edit and the defensible one. `#items[]` is deprecated in place,
   not deleted.
2. **`#chapter-header` extends to the numbered chapters.** The split is chronological drift, not
   a content-type distinction, and the fields it renders are exactly what
   `textbook-standards.md` already requires. This changes the rendered opening of 7 chapters,
   which is the intended visible effect of a uniformity task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Blind `FormalSystem/` prefixing produces a path that still does not resolve | H | H | Confirmed live: `` `Extension/` `` resolves only as `FormalSystem/Semantics/Extension/`. Every phase resolves each path per occurrence with `ls`/`test -e` before writing it. No repo-wide substitution. |
| Re-prefixing a path that already resolves from repo root | M | M | `training/PIPELINE.md`, `references.bib`, `scripts/`, `lakefile.toml`, `BimodalTools` paths resolve today. Only paths the lint actually flags get touched. |
| A reworded sentence silently changes a claim's truth value | H | M | Treat every edit as citation or format only. Any sentence whose truth could change is re-verified against `FormalSystem/` source or `SYNC-MAP.md` before the phase closes. |
| Appendix edits collide with sibling tasks 649/650 | M | M | Phase 12 is restricted to Rule 1.2 citation paths, with an explicit do-not-touch list. |
| `#leansrc` used mid-sentence breaks layout | M | M | It is block-level (`block(...raw(block: true...))`). The style sheet assigns inline mentions to `#leanref`/backticks and confirms placement in the per-phase compile. |
| Prose added for placement compliance reads as filler | M | M | Rule 2 requires a stated reader need, not word count. Rule 2.1 and 2.3 density findings are ADVISORY and never block, so padding buys nothing. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 | 1, 2 |
| 4 | 13 | 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 |

Phases within the same wave can execute in parallel. Wave 3's ten phases own disjoint chapter
files and none of them may touch `template.typ`, which Phase 2 owns.

**Standard per-phase verification** (every chapter phase in Wave 3 runs all four, from the
repository root unless noted):

```bash
cd typst && typst compile --root .. BimodalReference.typ build/BimodalReference.pdf && cd ..
bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/*.typ
bash .claude/scripts/chapter-quality-check.sh --verbose typst/chapters/<this phase's files>
grep -n '`[A-Za-z][A-Za-z0-9_/.-]*\.lean`\|`[A-Za-z][A-Za-z0-9_/-]*/`' typst/chapters/<files>
```

A chapter phase closes only when the compile is clean, the element lint reports no failure in
its own files, and `chapter-quality-check.sh` reports `BLOCKING 0` for every file the phase owns.

---

### Phase 1: Write the House Style Sheet [COMPLETED]

**Goal**: The style sheet exists as a committed reference before any chapter is edited, so every
later phase enforces one written source rather than a reconstructed intent.

**Tasks**:
- [ ] Create `typst/STYLE.md` transcribing the nine rules of "The House Style Sheet" above,
      keeping each rule's grounding citation.
- [ ] State at the top that the two appendices are governed by their own conventions, so a
      future reader does not read their overrides as drift. `typst/STYLE.md` is a deliverable
      outside `specs/**`, so cite the reason in durable terms ("owned by the Lean appendix's own
      code-environment and define-before-use conventions") and never by task number, per
      `rules/no-task-references-in-deliverables.md`.
- [ ] Add a "Style" section to `typst/README.md` pointing at `typst/STYLE.md` as the single
      reference for new chapters.
- [ ] Record the resolved list-syntax and `#chapter-header` decisions in `typst/STYLE.md` so the
      choice is discoverable, not just its outcome.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts the style sheet has exactly nine rules, matching the
plan's "The House Style Sheet" section. Confirm at implementation time that no rule was merged or
split while transcribing, and that the count in `typst/STYLE.md` matches the count the Testing &
Validation checklist verifies.

**Files to modify**:
- `typst/STYLE.md` - new file, the house style sheet
- `typst/README.md` - add a Style section linking STYLE.md

**Verification**:
- `typst/STYLE.md` exists and contains all nine numbered rules.
- `grep -n 'STYLE.md' typst/README.md` returns a hit.
- No `.typ` file changed in this phase, so the manual's compile state is untouched.

---

### Phase 2: Centralize the Shared Template Surface [COMPLETED]

**Goal**: Move the formatting helpers that chapters currently define locally into
`template.typ`, and correct the notation-standard's documentation gap, so Wave 3's chapter
phases can delete their local `#let` blocks without any of them needing to edit `template.typ`.

**Tasks**:
- [x] Add `derivation-tree-rule(name)` to `template.typ`, lifted from `03-proof-theory.typ:319`.
- [x] Add `fmt-lines(n)` and `module-lines(path)` to `template.typ`, lifted from
      `p4-proof-automation.typ`. `module-lines` was generalized to take the module-map explicitly
      (`module-lines(map, path)`) so it is reusable beyond `p4-proof-automation.typ`'s own
      `automation-module-map`; see the call-site-update note left as a template.typ comment.
- [x] **Deviation**: `p2-frame-classes.typ` has no `#let` of its own and no
      `module-lines`-style lookup at all (`grep -n '^#let\|module-lines\|\.find(row' typst/chapters/p2-frame-classes.typ`
      returned nothing) -- the plan's Scope Hypothesis on this point does not hold. There is
      nothing to compare or promote for that file; Phase 8, which owns `p2-frame-classes.typ`,
      inherits no obligation here.
- [x] Add a deprecation comment above `items`/`item` in `template.typ` naming `typst/STYLE.md`
      rule 6 and saying the definitions are retained for other documents. Do not delete them.
- [x] Additive only: left every chapter's local `#let` in place in this phase. A chapter-local
      `#let` shadows the template one, so the manual stays green between Phase 2 and Wave 3.
- [x] **Scope Hypothesis resolved**: `roles` (`p4-proof-automation.typ:115`) and
      `all-sorry-free` (`:130`) are chapter-specific data/derived values, not formatting helpers
      -- `roles` is a hand-written dictionary of per-module prose descriptions and
      `all-sorry-free` is a one-line boolean folded from the imported module map. Both stay
      local; Phase 10 (which owns this file) does not need to remove them.
- [x] Update `notation-conventions.md` in the source store to document `#leansrc` and `#leanref`
      as the manual's actual Lean-citation commands and mark `srcref`/`coderef` as superseded
      (confirmed unused anywhere under `typst/` via
      `grep -rn 'srcref\|coderef' typst/`).
      Edit target is
      `/home/benjamin/.config/nvim/agent-system/extensions/typst/context/project/typst/standards/notation-conventions.md`
      per `rules/source-store-deploy-boundary.md`, never the deployed `.claude/` copy.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: This phase assumes exactly five helpers need promoting
(`derivation-tree-rule`, `fmt-lines`, `module-lines`, and whatever `roles` and `all-sorry-free`
turn out to be in `p4-proof-automation.typ`), and that `p2-frame-classes.typ`'s lookup
duplicates `module-lines`. Confirm at implementation time with
`grep -n '^#let' typst/chapters/*.typ` and a direct read of each hit; `roles` and
`all-sorry-free` may be chapter-specific data rather than formatting helpers, in which case they
stay local and the phase says so.

**Files to modify**:
- `typst/template.typ` - add promoted helpers, deprecate `items`/`item`
- `/home/benjamin/.config/nvim/agent-system/extensions/typst/context/project/typst/standards/notation-conventions.md` - document the real citation commands

**Verification**:
- `cd typst && typst compile --root .. BimodalReference.typ build/BimodalReference.pdf` is clean
  with no new warning.
- Both lints report the same counts as the baseline (8 placement failures, 296 BLOCKING). This
  phase is additive and must not change either number.
- `grep -n 'derivation-tree-rule\|fmt-lines\|module-lines' typst/template.typ` shows all
  promoted helpers present.

---

### Phase 3: 00-introduction.typ [COMPLETED]

**Goal**: The manual's opening chapter conforms to the style sheet, including the project-
structure listing whose 16 bare directory citations are the chapter's entire BLOCKING count.

**Tasks**:
- [x] Add `#chapter-header(description:, dependencies:)` after the `= Introduction` heading.
      Dependencies for the opening chapter are "none assumed beyond basic logic"; said so rather
      than omitting the field. Also added the `<sec:introduction>` label to the `=` heading
      itself, matching the majority `<sec:...>` labeling convention on sibling chapters'
      top-level headings (not itself a BLOCKING finding, but required by STYLE.md rule 1's
      `= Chapter Title <sec:chapter-id>` shape).
- [x] Resolved all 16 Rule 1.2 findings per occurrence. 15 took a `FormalSystem/` prefix;
      `` `Extension/` `` at (pre-edit) line 158 became `FormalSystem/Semantics/Extension/`,
      verified by `test -d`. Did not touch `BimodalTools` or `lakefile.toml` mentions, which
      already resolve.
- [x] Left the 21 existing `@`-references as they are; this chapter has zero cross-reference
      drift.
- [x] Left the 6 Rule 3.3 long-paragraph and 3 Rule 2.1 density warnings alone. Both are
      ADVISORY and never block; splitting narrative paragraphs here would work against the
      chapter's deliberately essay-like register.

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 16 Rule 1.2 findings, all in the `== Project Structure` listing at lines
156-164. Confirm with
`bash .claude/scripts/chapter-quality-check.sh --verbose typst/chapters/00-introduction.typ`
before and after; the `SCORE` line must end at `BLOCKING 0`.

**Files to modify**:
- `typst/chapters/00-introduction.typ` - chapter header, 16 path citations

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for this file.
- Clean compile of `BimodalReference.typ`.
- Every path written resolves: re-run the `test -e` check on each edited path.

---

### Phase 4: 01-syntax.typ and 02-semantics.typ [NOT STARTED]

**Goal**: The two foundational chapters gain chapter headers, the style sheet's citation
convention, and the motivating prose their statement-first openings currently lack.

**Tasks**:
- [ ] Add `#chapter-header` to both files.
- [ ] `01-syntax.typ`: expand the single sentence before `#definition("Formula")` to meet rule
      1's two-sentence motivation minimum.
- [ ] `01-syntax.typ`: resolve 4 Rule 1.2 findings; convert the 4 footnote-based Lean citations
      to the style sheet's `#leansrc`/`#leanref` forms.
- [ ] `01-syntax.typ`: convert the 1 un-linked chapter reference to an `@`-reference. This file
      has zero `@`-refs today, so confirm the target label exists before linking.
- [ ] `02-semantics.typ`: resolve 10 Rule 1.2 findings and convert its 10 footnote citations.
- [ ] `02-semantics.typ`: check each `==`/`===` opening against rule 2. The element lint passes
      this file, so any gap here is a judgment call, not a lint failure; fix only where the
      opening genuinely states no reader need.

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 4 and 10 Rule 1.2 findings respectively, 14 total. Confirm per file with
`chapter-quality-check.sh --verbose`; both `SCORE` lines must end at `BLOCKING 0`.

**Files to modify**:
- `typst/chapters/01-syntax.typ` - chapter header, opening prose, 4 citations, 1 cross-reference
- `typst/chapters/02-semantics.typ` - chapter header, 10 citations, section openings

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for both files.
- `typst-element-lint.sh` still passes both files.
- Clean compile of `BimodalReference.typ`.

---

### Phase 5: 03-proof-theory.typ and 06-notes.typ [NOT STARTED]

**Goal**: Close the proof-theory chapter's citation and local-helper gaps, and fix the notes
chapter's two remark-opener placement failures plus its remark-density advisory.

**Tasks**:
- [ ] Add `#chapter-header` to both files.
- [ ] `03-proof-theory.typ`: resolve 6 Rule 1.2 findings.
- [ ] `03-proof-theory.typ`: delete the local `#let derivation-tree-rule` at line 319 and rely
      on the Phase 2 template helper. Confirm the rendered output is unchanged by comparing the
      relevant page before and after.
- [ ] `03-proof-theory.typ`: convert the 1 un-linked chapter reference to an `@`-reference.
- [ ] `06-notes.typ`: fix both placement failures at lines 111 and 120 by writing opening prose
      for `=== S5-Hood Does Not Single Out Metaphysical Necessity` and `=== Historical Context`
      before the `#remark`.
- [ ] `06-notes.typ`: resolve the remark-density advisory by moving the two opener remarks'
      content into ordinary prose or into the existing `== Design Notes` section. Move content;
      do not delete it.
- [ ] `06-notes.typ`: resolve 3 Rule 1.2 findings and convert the 2 un-linked chapter references.
- [ ] `06-notes.typ`: confirm every status claim traces to `typst/generated/status.typ` or
      `SYNC-MAP.md`. This chapter is the manual's status register and the likeliest home for a
      hand-typed number.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 6 and 5 BLOCKING findings respectively (of `06-notes.typ`'s 5, three are
Rule 1.2 and two are the delegated placement failures). Confirm per file with both lints; both
`SCORE` lines must end at `BLOCKING 0` and the element lint must report no failure and no
remark-density warning for `06-notes.typ`.

**Files to modify**:
- `typst/chapters/03-proof-theory.typ` - chapter header, 6 citations, local helper removal, 1 cross-reference
- `typst/chapters/06-notes.typ` - chapter header, 2 placement fixes, remark relocation, 3 citations, 2 cross-references

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for both files.
- `typst-element-lint.sh` reports no failure for either file and no remark-density warning for
  `06-notes.typ`.
- `grep -n '^#let' typst/chapters/03-proof-theory.typ` returns nothing.
- Clean compile of `BimodalReference.typ`.

---

### Phase 6: 04-metalogic.typ [NOT STARTED]

**Goal**: Clear the manual's single largest BLOCKING concentration (65 findings, 22% of the
total) and write the three missing subsection openings the element lint flags.

**Tasks**:
- [ ] Add `#chapter-header` to the file.
- [ ] Fix all three placement failures by writing opening prose before the elements at lines 50
      (`=== Deduction Theorem`), 63 (`=== Consistency`), and 76 (`=== Lindenbaum's Lemma`).
- [ ] Resolve 62 Rule 1.2 findings per occurrence. This is the highest-volume citation pass in
      the task; work section by section, re-running the checker after each section rather than
      once at the end.
- [ ] Convert the file's 10 footnote-based Lean citations to `#leansrc` blocks or inline
      `#leanref`, per rule 4's three-form table.
- [ ] Leave the 6 existing `@`-references alone; this file has zero cross-reference drift.
- [ ] Re-verify every soundness and completeness claim touched while editing its citation. This
      chapter states the results most likely to drift from `FormalSystem/Metalogic/`.

**Timing**: 2 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 65 BLOCKING findings: 62 Rule 1.2 plus 3 delegated placement failures.
Confirm with `chapter-quality-check.sh --verbose typst/chapters/04-metalogic.typ` before and
after; the `SCORE` line must end at `BLOCKING 0`.

**Files to modify**:
- `typst/chapters/04-metalogic.typ` - chapter header, 3 placement fixes, 62 citations, 10 footnote conversions

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for this file.
- `typst-element-lint.sh` reports no failure for this file.
- Clean compile of `BimodalReference.typ`.
- Every Lean name cited resolves in `FormalSystem/`: grep the source for each declaration name
  touched.

---

### Phase 7: 05-theorems.typ [NOT STARTED]

**Goal**: Fix the manual's sparsest chapter: three sections open directly on a `#theorem`, and
the centerpiece Perpetuity Principles section presents six theorems back to back with no
connecting prose.

**Tasks**:
- [ ] Add `#chapter-header` to the file.
- [ ] Fix all three placement failures by writing opening prose before the theorems at lines 71
      (`== Modal S5 Theorems`), 129 (`== Propositional Theorems`), and 175
      (`== Generalized Necessitation`).
- [ ] Write one connective sentence between each consecutive pair in the P1-P6 theorem run,
      saying how each relates to or follows from the last. This is rule 3's connective-prose
      requirement and goes beyond what the lint gate alone demands.
- [ ] Resolve 21 Rule 1.2 findings per occurrence.
- [ ] Add `@`-references where the chapter states a result proved elsewhere. This file has zero
      `@`-refs today, which is itself the drift; confirm each target label exists before linking.
- [ ] Add no new theorem, no new proof, and no restatement of an existing one. Prose only.

**Timing**: 2 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 24 BLOCKING findings: 21 Rule 1.2 plus 3 delegated placement failures, and
six theorem blocks in the Perpetuity Principles run needing five connective sentences. Confirm
the theorem count with `grep -c '#theorem' typst/chapters/05-theorems.typ` and the finding count
with the checker; the `SCORE` line must end at `BLOCKING 0`.

**Files to modify**:
- `typst/chapters/05-theorems.typ` - chapter header, 3 placement fixes, P1-P6 connective prose, 21 citations, cross-references

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for this file.
- `typst-element-lint.sh` reports no failure for this file.
- No two `#theorem` blocks in the P1-P6 run are adjacent with no prose between them: read the
  region directly to confirm.
- Clean compile of `BimodalReference.typ`.

---

### Phase 8: p2-frame-classes.typ and the three p3 chapters [NOT STARTED]

**Goal**: Normalize the four survey and frame-class chapters, whose citation load is light but
which carry the manual's entire cross-reference drift concentration.

**Tasks**:
- [ ] `p2-frame-classes.typ`: resolve 13 Rule 1.2 findings. Where a `#leansrc` block already
      attributes a declaration (line 24 is the pattern), drop the duplicated file path from the
      preceding prose rather than prefixing it, per rule 4.
- [ ] `p2-frame-classes.typ`: delete its inline `module-lines`-style lookup if Phase 2 promoted
      an equivalent; keep it only if Phase 2 established it is genuinely distinct.
- [ ] `p2-frame-classes.typ`: convert the 1 un-linked chapter reference.
- [ ] `p3-ltl-to-tm.typ`: convert all 5 un-linked "the X chapter" references. This file is the
      single worst offender on this axis and has zero BLOCKING findings, so cross-references are
      its whole scope.
- [ ] `p3-vlach-blstar.typ`: resolve 1 Rule 1.2 finding and convert the 1 un-linked reference.
- [ ] `p3-decidability-frontier.typ`: zero BLOCKING findings. Verify style-sheet conformance of
      the surrounding prose only. Do not touch the `// SLOT-IN:` anchors, the embargo comment, or
      any Lk-specific content.
- [ ] All four files already use `#chapter-header`; verify the `description`/`dependencies`
      fields are present and say something, rather than assuming the macro call alone suffices.
- [ ] Answer the cheap Rule 2.2 section-opening prompts for these four files while in them,
      since rule 2 already covers the same ground.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 14 BLOCKING findings total across the four files (13 + 0 + 1 + 0) and 7
un-linked cross-references. Confirm the finding counts with the checker and the cross-reference
count by reading each "chapter" mention in context; all four `SCORE` lines must end at
`BLOCKING 0`.

**Files to modify**:
- `typst/chapters/p2-frame-classes.typ` - 13 citations, local helper removal, 1 cross-reference
- `typst/chapters/p3-ltl-to-tm.typ` - 5 cross-references
- `typst/chapters/p3-vlach-blstar.typ` - 1 citation, 1 cross-reference
- `typst/chapters/p3-decidability-frontier.typ` - style conformance check only, likely no change

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for all four files.
- `grep -in 'the [a-z]* chapter\|see Chapter' typst/chapters/p2-frame-classes.typ typst/chapters/p3-*.typ`
  returns no un-linked reference.
- `git diff typst/chapters/p3-decidability-frontier.typ` shows no change to any `// SLOT-IN:`
  line or the embargo comment.
- Clean compile of `BimodalReference.typ`.

---

### Phase 9: p2-decidability-practice.typ [NOT STARTED]

**Goal**: Clear 31 BLOCKING findings from the chapter that best demonstrates the citation
problem: it already imports `#leansrc` and calls it three times, yet falls back to bare paths 28
times in the same file.

**Tasks**:
- [ ] Resolve all 31 Rule 1.2 findings per occurrence, converting declaration citations to
      `#leansrc`/`#leanref` rather than merely prefixing paths wherever the citation is a
      declaration and not a file.
- [ ] Verify the existing `#chapter-header` fields are present and substantive.
- [ ] Check each `==`/`===` opening against rule 2. The element lint passes this file, so fix
      only genuine gaps.
- [ ] Verify every decidability status claim against `typst/generated/status.typ` or
      `SYNC-MAP.md` before rewording any sentence that carries one.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 31 Rule 1.2 findings, against only 3 existing `#leansrc` calls. Confirm
with `chapter-quality-check.sh --verbose typst/chapters/p2-decidability-practice.typ`; the
`SCORE` line must end at `BLOCKING 0`.

**Files to modify**:
- `typst/chapters/p2-decidability-practice.typ` - 31 citations, section openings

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for this file.
- `typst-element-lint.sh` still passes this file.
- Clean compile of `BimodalReference.typ`.

---

### Phase 10: p4-proof-automation.typ [NOT STARTED]

**Goal**: Clear 29 BLOCKING findings, remove the manual's largest concentration of chapter-local
helpers, and convert the chapter's `#items[]` block to native list syntax.

**Tasks**:
- [ ] Resolve all 29 Rule 1.2 findings per occurrence.
- [ ] Delete the local `#let` definitions at lines 17, 28, 115, and 130 in favor of the Phase 2
      template helpers, keeping any that Phase 2 established are chapter-specific data rather
      than formatting helpers.
- [ ] Convert the `#items[#item[...]]` block to native `- ` list syntax per rule 6, and check the
      rendered spacing in the compiled PDF rather than assuming it is equivalent.
- [ ] Convert the 1 un-linked chapter reference.
- [ ] Verify the existing `#chapter-header` fields are present and substantive.
- [ ] Verify every line-count and module-count claim resolves through `module-lines` against
      `typst/generated/`, not a hand-typed number.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 29 Rule 1.2 findings, 4 local `#let` definitions, 1 `#items[` block.
Confirm the `#let` count with `grep -n '^#let' typst/chapters/p4-proof-automation.typ` and the
findings with the checker; the `SCORE` line must end at `BLOCKING 0`.

**Files to modify**:
- `typst/chapters/p4-proof-automation.typ` - 29 citations, 4 local helper removals, list conversion, 1 cross-reference

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for this file.
- `grep -n '^#let\|#items\[' typst/chapters/p4-proof-automation.typ` returns nothing, or returns
  only a definition Phase 2 established must stay local.
- Clean compile of `BimodalReference.typ`, with the converted list's spacing checked in the PDF.

---

### Phase 11: p4-dataset-pipeline.typ and p4-dual-verification.typ [NOT STARTED]

**Goal**: Clear 43 BLOCKING findings across the two applications chapters and convert their
`#items[]` blocks, completing the `p4` group.

**Tasks**:
- [ ] `p4-dataset-pipeline.typ`: resolve 22 Rule 1.2 findings and convert its 4 footnote
      citations.
- [ ] `p4-dual-verification.typ`: resolve 21 Rule 1.2 findings. Its worst pattern is
      `Examples/TemporalStructures.lean` repeated 11 times and `Examples/BimodalProofs.lean` 7
      times; resolve each per occurrence and prefer a single `#leansrc` attribution over a
      repeated inline path.
- [ ] `p4-dual-verification.typ`: convert its 7 footnote citations and keep the external block
      quote in its opening intact.
- [ ] Convert the `#items[]` block in each file to native list syntax per rule 6.
- [ ] Verify both files' `#chapter-header` fields are present and substantive.
- [ ] Verify every dataset and verification-status number against `typst/generated/` or
      `SYNC-MAP.md`.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 22 and 21 Rule 1.2 findings respectively, 43 total, plus one `#items[`
block per file. Confirm per file with the checker; both `SCORE` lines must end at `BLOCKING 0`.

**Files to modify**:
- `typst/chapters/p4-dataset-pipeline.typ` - 22 citations, 4 footnote conversions, list conversion
- `typst/chapters/p4-dual-verification.typ` - 21 citations, 7 footnote conversions, list conversion

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for both files.
- `grep -n '#items\[' typst/chapters/p4-dataset-pipeline.typ typst/chapters/p4-dual-verification.typ`
  returns nothing.
- Clean compile of `BimodalReference.typ`.

---

### Phase 12: Appendix Citation Paths Only [NOT STARTED]

**Goal**: Clear the two appendices' 49 Rule 1.2 findings, which acceptance requires, without
touching anything sibling tasks 649 and 650 own.

**Tasks**:
- [ ] `ax-lean-appendix.typ`: resolve all 46 Rule 1.2 findings. These are citation-format
      defects only. Prefer converting a declaration citation to the file's already-dominant
      `#leansrc` form (36 existing calls) over prefixing a path.
- [ ] `ax-machine-appendix.typ`: resolve all 3 Rule 1.2 findings.
- [ ] Change nothing else in either file. Explicitly do not touch: the local `#leansrc`
      `sticky:` override, the local `#show raw.where(...)` and `#show figure.where(...)` rules,
      the appendix's own numbering scheme or heading scaffolding, the order in which
      declarations are introduced (task 650's define-before-use audit), or any Lean code
      environment (task 649).
- [ ] Record in the phase notes which conventions were deliberately left alone, so tasks 649 and
      650 inherit a clear boundary rather than guessing what this task changed.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: 46 and 3 Rule 1.2 findings respectively, 49 total, and zero non-citation
changes. Confirm the findings with the checker and the restraint with
`git diff --stat typst/chapters/ax-*.typ`; both `SCORE` lines must end at `BLOCKING 0`, and the
diff must contain no `#show`, no `#let`, and no heading-line change.

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - 46 citation paths only
- `typst/chapters/ax-machine-appendix.typ` - 3 citation paths only

**Verification**:
- `chapter-quality-check.sh` reports `BLOCKING 0` for both files.
- `git diff typst/chapters/ax-lean-appendix.typ | grep -E '^[+-].*(#show|#let|^=)'` returns
  nothing.
- Clean compile of `BimodalReference.typ`.

---

### Phase 13: Whole-Manual Acceptance Sweep [NOT STARTED]

**Goal**: Confirm every acceptance criterion in one pass over the finished manual, and correct
the style sheet if implementation revealed a rule that could not be applied as written.

**Tasks**:
- [ ] Run `typst-element-lint.sh --verbose` over all of `typst/chapters/*.typ` and confirm zero
      blocking placement findings.
- [ ] Run `chapter-quality-check.sh --verbose` over all of `typst/chapters/*.typ` and confirm
      zero BLOCKING findings, down from the 296 baseline.
- [ ] Compile `BimodalReference.typ` from clean and confirm zero warnings. Compare the warning
      set against the baseline (0 warnings) so no warning introduced by this task slips through.
- [ ] Record the final page count from the fresh compile. The dispatch's "128 pages" and the
      audit's "105 pages" are both stale; do not cite either.
- [ ] Read each chapter's opening against `typst/STYLE.md` rules 1 and 2 and confirm the
      `#chapter-header` shape is genuinely uniform, not merely present.
- [ ] Confirm no non-appendix chapter defines a local `#let`:
      `grep -n '^#let' typst/chapters/*.typ` should hit only the two appendices and whatever
      Phase 2 documented as necessarily local.
- [ ] Confirm no chapter calls `#items[`: `grep -n '#items\[' typst/chapters/*.typ`.
- [ ] Confirm every Lean name cited manual-wide resolves in `FormalSystem/`.
- [ ] If any style-sheet rule proved unworkable in practice, amend `typst/STYLE.md` to match what
      was actually done and say why. The committed style sheet must describe the manual as it now
      is, not an aspiration the chapters diverge from.
- [ ] Regenerate `typst/BimodalReference.pdf` from the final source.

**Timing**: 1 hour

**Depends on**: 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

**Verification Tier**: full

**Scope Hypothesis**: Both gates reach zero from a 296-BLOCKING and 8-placement-failure baseline.
Confirm by running both lints over all 17 files in one invocation, not per file, since a
per-file pass cannot detect a cross-chapter regression.

**Files to modify**:
- `typst/STYLE.md` - amend only if a rule proved unworkable
- `typst/BimodalReference.pdf` - regenerated output

**Verification**:
- `typst-element-lint.sh --verbose typst/chapters/*.typ`: `Failures: 0`.
- `chapter-quality-check.sh --verbose typst/chapters/*.typ`: `Blocking: 0`.
- `typst compile --root .. BimodalReference.typ`: exits 0 with no warning.
- `typst/STYLE.md` and `typst/README.md` both committed and mutually linked.

---

## Testing & Validation

- [ ] `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/*.typ` reports zero
      failures (baseline: 8).
- [ ] `bash .claude/scripts/chapter-quality-check.sh --verbose typst/chapters/*.typ` reports zero
      BLOCKING findings (baseline: 296).
- [ ] `cd typst && typst compile --root .. BimodalReference.typ build/BimodalReference.pdf`
      succeeds with zero warnings (baseline: zero warnings, which must be preserved).
- [ ] Every chapter under `typst/chapters/` opens with `= Title <label>` followed by
      `#chapter-header(...)`, except the two appendices.
- [ ] `grep -n '^#let' typst/chapters/*.typ` hits only the appendices and any Phase 2-documented
      exception.
- [ ] `grep -n '#items\[' typst/chapters/*.typ` returns nothing.
- [ ] No un-linked "the X chapter" or "see Chapter N" prose remains outside the appendices.
- [ ] Every Lean declaration name cited resolves in the current `FormalSystem/` tree.
- [ ] Every count and status claim traces to `typst/generated/` or `SYNC-MAP.md`.
- [ ] `typst/STYLE.md` exists, is linked from `typst/README.md`, and describes the manual as it
      actually is.

## Artifacts & Outputs

- `typst/STYLE.md` — the house style sheet, new file, the task's durable deliverable.
- `typst/README.md` — Style section linking the style sheet.
- `typst/template.typ` — promoted formatting helpers, `items`/`item` deprecated in place.
- 17 files under `typst/chapters/` — style-sheet conformance.
- `typst/BimodalReference.pdf` — regenerated.
- `notation-conventions.md` in the typst extension's source store — `#leansrc`/`#leanref`
  documented, `srcref`/`coderef` marked superseded.
- `specs/702_uniform_style_reference_manual/summaries/01_*-summary.md` — at implementation close.

## Rollback/Contingency

Every phase is a self-contained, committed unit whose green condition is a clean compile plus
both lints, so a failed phase reverts with `git revert` of that phase's commit without disturbing
any other chapter. Chapter phases own disjoint files, so one reverted chapter phase leaves the
other nine intact.

Two contingencies are worth naming in advance. If Phase 2's helper promotion turns out to change
rendered output for `03-proof-theory.typ` or `p4-proof-automation.typ`, keep the helper local in
that chapter and record the exception in `typst/STYLE.md` rule 8 rather than forcing the
centralization. If the appendices' 49 citation findings cannot be cleared without touching a
convention that tasks 649 or 650 own, stop Phase 12, leave the appendix at its current BLOCKING
count, and report the conflict rather than pre-empting a sibling task; the manual still compiles
and the other 15 chapters still reach zero, so the task closes as partial on one enumerated
exclusion instead of failing.

If a destructive rollback of uncommitted work is ever needed, snapshot first with
`bash .claude/scripts/git-snapshot.sh 702` before any reverting command.
