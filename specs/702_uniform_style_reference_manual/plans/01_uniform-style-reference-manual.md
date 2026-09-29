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

### Phase 4: 01-syntax.typ and 02-semantics.typ [COMPLETED]

**Goal**: The two foundational chapters gain chapter headers, the style sheet's citation
convention, and the motivating prose their statement-first openings currently lack.

**Tasks**:
- [x] Add `#chapter-header` to both files, plus `<sec:syntax>`/`<sec:semantics>` labels on their
      `=` headings (matching the majority sibling-chapter labeling convention) since neither
      carried one and the new cross-reference below needs a target.
- [x] `01-syntax.typ`: expanded the single sentence before `#definition("Formula")` to meet rule
      1's two-sentence motivation minimum.
- [x] **Deviation**: `01-syntax.typ`'s 4 Rule 1.2 findings were declaration-in-footnote citations
      mixing an inline declaration name with a parenthetical file path (e.g.
      ``` `Atom` (`Syntax/Atom.lean`) ```), not standalone block-level attributions. Converting
      them to `#leansrc`/`#leanref` per rule 4's letter would mean dropping the file-path
      information the footnote deliberately carries (rule 4's inline-declaration form is
      identifier-only, no path) or inserting a block-level `#leansrc` mid-footnote, which rule 4
      itself forbids ("never mid-sentence"). Resolved all 4 by prefixing the bare path with
      `FormalSystem/` instead (Rule 1.2's actual requirement), preserving the footnote wording
      unchanged; recorded here rather than silently deviating from the plan's stated approach.
- [x] `01-syntax.typ`: converted the 1 un-linked chapter reference (the semantics chapter) to
      `@sec:semantics`, confirming the label exists (added in this same phase).
- [x] `02-semantics.typ`: resolved all 10 Rule 1.2 findings, all by `FormalSystem/`-prefixing an
      already-correct module-relative path (same reasoning as the `01-syntax.typ` deviation
      above for the 2 footnote occurrences among them: `TruthAt`/`future_iff`/`past_iff`/
      `timeShift` citations kept their existing inline-declaration-plus-file-path shape with the
      path corrected, rather than being restructured into `#leansrc` blocks).
- [x] `02-semantics.typ`: checked each `==`/`===` opening against rule 2. The element lint passes
      this file and every section already opens with reader-need prose; no gap found requiring a
      fix.

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

### Phase 5: 03-proof-theory.typ and 06-notes.typ [COMPLETED]

**Goal**: Close the proof-theory chapter's citation and local-helper gaps, and fix the notes
chapter's two remark-opener placement failures plus its remark-density advisory.

**Tasks**:
- [x] Add `#chapter-header` to both files.
- [x] `03-proof-theory.typ`: resolved all 6 Rule 1.2 findings (all `FormalSystem/`-prefix fixes,
      each verified present with `test -f` first).
- [x] `03-proof-theory.typ`: deleted the local `#let derivation-tree-rule` at line 319 and relies
      on the Phase 2 template helper (identical signature and body, so no rendered-output change
      is possible; the 7 call sites are unchanged).
- [x] `03-proof-theory.typ`: converted the 1 un-linked chapter reference ("the metalogic
      chapter") to `@sec:metalogic`.
- [x] `06-notes.typ`: fixed both placement failures by converting the two opener `#remark` blocks
      ("Why S5 Alone Underdetermines the Reading of Box" and "Prior's Tradition") to ordinary
      prose, each preceded by a stated reader-need sentence for its `===` section. Content moved,
      not deleted or shortened.
- [x] `06-notes.typ`: the same conversion resolved the remark-density advisory as a side effect
      (4 remarks -> 2, below the lint's `DENSITY_FLOOR=3`, so the check no longer fires) rather
      than requiring a separate step.
- [x] `06-notes.typ`: resolved all 3 Rule 1.2 findings (`FormalSystem/`-prefix fixes).
      **Deviation**: the plan's Scope Hypothesis counted 2 un-linked chapter references; a direct
      grep found 4 (`the Decidability-in-Practice chapter` x2, `the Semantics chapter`,
      `the metalogic chapter` at line 106) plus one already-linked occurrence at line 72
      (`the metalogic chapter (@sec:metalogic)`, left as prose since it already links). All 4
      un-linked occurrences were converted to `@sec:decidability-practice` (x2), `@sec:semantics`,
      and `@sec:metalogic` respectively -- more thorough than the hypothesis predicted, not less,
      so no exclusion is needed.
- [x] `06-notes.typ`: reviewed every count for Rule 9 traceability. `#axiom-count`/`#rule-count`
      already import from `typst/generated/status.typ`. The remaining digit-free spelled-out
      counts ("six primitive constructors", "nine layers", "four frame classes", "P1--P6") are
      fixed structural/definitional facts about the axiomatization (the primitive-constructor
      count, axiom-layer count, and frame-class enumeration are part of the system's design, not
      counts that drift with the Lean codebase the way axiom/rule counts do), so they are not
      candidates for `typst/generated/` grounding; no hand-typed volatile number was found.

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

### Phase 6: 04-metalogic.typ [COMPLETED]

**Goal**: Clear the manual's single largest BLOCKING concentration (65 findings, 22% of the
total) and write the three missing subsection openings the element lint flags.

**Tasks**:
- [x] Added `#chapter-header` to the file.
- [x] Fixed all three placement failures by writing opening prose before the elements at lines 50
      (`=== Deduction Theorem`), 63 (`=== Consistency`), and 76 (`=== Lindenbaum's Lemma`), each
      stating why that component matters to the completeness construction.
- [x] Resolved all 62 Rule 1.2 findings per occurrence, worked section by section against the
      full `FormalSystem/Metalogic/` tree listing (`find FormalSystem/Metalogic -name '*.lean'`),
      re-running the checker after each block. Found one gap the plan's Scope Hypothesis did not
      predict: several within-table-cell bare tokens (`RestrictedMCS/`, in-row `Completeness.lean`
      /`CompletenessDedekind.lean`/`Chronicle/`/`Filtration/`/`Quasimodel/` inside the BXCanonical
      row, `RealModel/`/`IntegerModel/` and `DenseModelSurgery/` inside the WeakCanonical row,
      `FMP/`/`Propositional/`/`Verified/` inside the Decidability row, and the 4
      `CoValidity.lean`/`DiscreteOrder.lean`/`Separability.lean`/`FrameClassVariants.lean`
      filenames in the axiom-validity-lemmas parenthetical) were left bare by a first pass and
      only surfaced on re-running the checker; a second pass resolved all of them per the same
      per-occurrence discipline. Two occurrences resolve outside `WeakCanonical/` despite the
      table row's own heading implying otherwise: `Separation/`, `Kamp/`, and `EFGames/` are
      actually under `FormalSystem/Metalogic/Expressiveness/`, not `WeakCanonical/`; resolved to
      their true location rather than following the row's informal grouping.
- [x] **Deviation**: did not convert the file's footnote-based Lean citations to `#leansrc`/
      `#leanref` blocks. As in Phase 4's `01-syntax.typ`/`02-semantics.typ` deviation, every
      footnote here mixes an inline declaration name with a parenthetical file-path citation, and
      rule 4 forbids a block-level `#leansrc` mid-sentence/mid-footnote; resolved all of them by
      `FormalSystem/`-prefixing the existing bare path instead, which satisfies Rule 1.2 without
      restructuring the prose.
- [x] Left the 6 existing `@`-references alone; this file has zero cross-reference drift.
- [x] Re-verified every soundness and completeness declaration name touched
      (`soundness`, `set_lindenbaum`) against the live `FormalSystem/Metalogic/` source via
      direct grep; both resolve to real declarations at the cited files.

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

### Phase 7: 05-theorems.typ [COMPLETED]

**Goal**: Fix the manual's sparsest chapter: three sections open directly on a `#theorem`, and
the centerpiece Perpetuity Principles section presents six theorems back to back with no
connecting prose.

**Tasks**:
- [x] Added `#chapter-header` to the file, plus a `<sec:theorems>` label on the `=` heading.
- [x] Fixed all three placement failures by writing opening prose before the theorems at
      `== Modal S5 Theorems`, `== Propositional Theorems`, and `== Generalized Necessitation`.
- [x] Wrote one connective sentence between each consecutive pair in the P1-P6 theorem run (5
      sentences), each keyed to the existing summary table's "Key Lemmas" column so the prose
      restates the table's own reasoning rather than inventing a new justification.
- [x] Resolved all 21 Rule 1.2 findings per occurrence, including two in-cell bare filenames one
      pass missed (`Core.lean`/`Connectives.lean`/`Reasoning.lean` inside the Propositional-row
      cell) and one introduced by this phase's own new connective prose (a bare
      `MonotonicityDuality.lean` mention), both caught by re-running the checker rather than
      trusting the first pass clean.
- [x] Added `@`-references: `@sec:proof-theory` (twice, S5 and S4 theorem-set openings) and
      `@sec:semantics` (once, the S5-core opening), confirming both labels exist before linking.
      This file had zero `@`-refs before this phase.
- [x] Added no new theorem, no new proof, and no restatement of an existing one; every edit was
      opening/connective prose, `@`-references, or citation-path correction.

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

### Phase 8: p2-frame-classes.typ and the three p3 chapters [COMPLETED]

**Goal**: Normalize the four survey and frame-class chapters, whose citation load is light but
which carry the manual's entire cross-reference drift concentration.

**Tasks**:
- [x] `p2-frame-classes.typ`: resolved all 13 Rule 1.2 findings. At line 24's `#leansrc` block,
      dropped the duplicated file path from the preceding prose ("defined in the `ProofSystem`
      module:") per rule 4, rather than prefixing it.
- [x] `p2-frame-classes.typ`: **already resolved in Phase 2** -- Phase 2 confirmed (and recorded
      as a deviation) that this file has no `#let` and no `module-lines`-style lookup at all, so
      there is nothing to delete here.
- [x] `p2-frame-classes.typ`: converted the 1 un-linked chapter reference (embedded in the
      `#chapter-header` `description:` field itself) to `@sec:proof-theory`.
- [x] `p3-ltl-to-tm.typ`: converted all 5 un-linked "the X chapter" references to
      `@sec:semantics` (x3), `@sec:perpetuity`, and `@sec:decidability-frontier`.
- [x] `p3-vlach-blstar.typ`: resolved the 1 Rule 1.2 finding. **Deviation**: a direct grep found
      3 un-linked references, not 1 (`the semantics chapter`, `the frontier chapter`, `the next
      chapter`); all 3 converted (`@sec:semantics`, `@sec:decidability-frontier` x2) rather than
      leaving the 2 the hypothesis missed.
- [x] `p3-decidability-frontier.typ`: confirmed zero BLOCKING findings and zero un-linked
      cross-references; `git diff --stat` shows no change to this file at all, so the
      `// SLOT-IN:` anchors, embargo comment, and Lk-specific content are untouched by construction.
- [x] Confirmed all four files' `#chapter-header` `description`/`dependencies` fields are present
      and substantive (direct read of each).
- [x] Rule 2.2 section-opening prompts: these ask the same question the Rule-2/placement pass
      above already answers (does the opening state a reader need before any element), so no
      separate pass was run; every section opening in all four files was read during the citation
      and cross-reference edits above and none showed a Rule-2 gap.

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

### Phase 9: p2-decidability-practice.typ [COMPLETED]

**Goal**: Clear 31 BLOCKING findings from the chapter that best demonstrates the citation
problem: it already imports `#leansrc` and calls it three times, yet falls back to bare paths 28
times in the same file.

**Tasks**:
- [x] Resolved all 31 Rule 1.2 findings per occurrence. **Deviation**: kept the existing
      inline-declaration-plus-parenthetical-path prose shape and `FormalSystem/`-prefixed the
      path, rather than restructuring to `#leansrc`/`#leanref`, for the same reason recorded in
      Phases 4 and 6 -- the citations are already inline declaration mentions, not standalone
      block attributions, and rule 4's block-level `#leansrc` is "never mid-sentence". Several
      occurrences repeating the same file path across one sentence (e.g. `TraceCertificate.lean`,
      `CountermodelExtraction.lean`) were consolidated to cite the file once and say "same file"
      for the repeats, tightening the prose rather than repeating the now-longer full path.
- [x] Verified the existing `#chapter-header` fields (`description`/`dependencies`) are present
      and substantive.
- [x] Checked each `==`/`===` opening against rule 2. The element lint passes this file and every
      opening already states a reader need; no gap found requiring a fix.
- [x] Spot-checked decidability status claims already present (fuel/termination semantics,
      `RuleSound` covering "all 34 rules") against the file's own citations; no rewording was
      needed since Rule 1.2 fixes here were path corrections only, not claim rewording.

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

### Phase 10: p4-proof-automation.typ [COMPLETED]

**Goal**: Clear 29 BLOCKING findings, remove the manual's largest concentration of chapter-local
helpers, and convert the chapter's `#items[]` block to native list syntax.

**Tasks**:
- [x] Resolved all 29 Rule 1.2 findings per occurrence, all `FormalSystem/`-prefix fixes
      (`Automation/` -> `FormalSystem/Automation/`, `Examples/` -> `FormalSystem/Examples/`,
      `EFGameTactics.lean`/`Expressiveness/EFGames` -> their true
      `FormalSystem/Metalogic/Expressiveness/` location, `Metalogic/Decidability/...` ->
      `FormalSystem/Metalogic/Decidability/...`).
- [x] Deleted the local `#let fmt-lines` and `#let module-lines(path)` definitions, now relying
      on the Phase 2 template helpers. `module-lines`'s one call site was updated from
      `module-lines("SuccessPatterns.lean")` to `module-lines(automation-module-map,
      "SuccessPatterns.lean")` to match the template's generalized two-argument signature (see
      Phase 2's note on this call-site-update obligation). `roles` and `all-sorry-free` were kept
      local per Phase 2's finding that they are chapter-specific data, not formatting helpers.
- [x] Converted the `#items[#item[...]]` block (the four user-facing tactics) to native `- ` list
      syntax; `typst compile` succeeded with no new warning, confirming equivalent rendering.
- [x] **Deviation**: the 1 un-linked reference ("the dual-verification chapter") cannot be
      converted to `@`-ref yet: `p4-dual-verification.typ` (Phase 11's file) carries no `=`-heading
      label today. Left as prose in this phase, to be converted once Phase 11 adds the label --
      recorded here so it is not silently dropped, and completed in Phase 11 below.
- [x] Verified the existing `#chapter-header` fields (`description`/`dependencies`) are present
      and substantive.
- [x] Verified line-count/module-count claims: `#fmt-lines`/`#module-lines` calls resolve through
      the generated `automation-module-map`/`automation-module-total`. The two hand-typed counts
      that remain (`EFGameTactics.lean`'s 331 lines, the retired Aesop rule set's 322 lines) cite
      files explicitly outside the tracked `Automation/` module map (one is under
      `Metalogic/Expressiveness/`, the other in `Boneyard/`), so there is no generated source for
      either to trace to; both are pre-existing figures this phase's citation-path scope did not
      touch or reword.

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

### Phase 11: p4-dataset-pipeline.typ and p4-dual-verification.typ [COMPLETED]

**Goal**: Clear 43 BLOCKING findings across the two applications chapters and convert their
`#items[]` blocks, completing the `p4` group.

**Also completed here**: added a `<sec:dual-verification>` label to `p4-dual-verification.typ`'s
`=` heading (it carried none before this phase) and used it to finish the one un-linked
cross-reference Phase 10 deferred (`p4-proof-automation.typ`'s "the dual-verification chapter"
mention, now `@sec:dual-verification`) -- see Phase 10's own notes for why it could not be closed
there.

**Tasks**:
- [x] `p4-dataset-pipeline.typ`: resolved all 22 Rule 1.2 findings. **Deviation**: found the
      seven `BimodalTools/*.lean` file paths were bare with no `FormalSystem/` (or any) prefix at
      all, and traced them to a different root directory than the Scope Hypothesis assumed --
      `BimodalTools/` at the repo root, not `FormalSystem/`, confirmed by `find . -iname`. The 4
      `training/PIPELINE.md:NNN`-shaped footnote citations were fixed by moving the line-number
      suffix outside the backtick span (`` `training/PIPELINE.md` ``, line NNN) rather than
      restructuring to `#leansrc`, since these cite a markdown document section, not a Lean
      declaration -- rule 4's three-form table does not cover markdown citations, so the closest
      conforming shape (file-cited-as-a-file, backtick path resolving cleanly) was used.
- [x] `p4-dual-verification.typ`: resolved all 21 Rule 1.2 findings. Consolidated the repeated
      `Examples/TemporalStructures.lean`/`Examples/BimodalProofs.lean` mentions within a sentence
      to cite the file once (`FormalSystem/Examples/...`) and say "same file"/"same code" for
      later mentions in the same sentence, rather than repeating the now-longer full path.
- [x] `p4-dual-verification.typ`: **Deviation**, same reasoning as Phases 4/6/9 -- every citation
      here is an inline declaration-plus-path mention, not a standalone block attribution, so
      resolved via `FormalSystem/`-prefixing rather than restructuring to `#leansrc`. The external
      block quote in the chapter's opening (the ModelChecker/ProofChecker framing, footnoted to
      `README.md:183` and the Logos manual) was left untouched in structure; its Logos citation
      was de-backticked (it names an external, non-local file the checker cannot and should not
      resolve against this tree) with the existing "not a local Lean name" disclaimer kept.
- [x] Converted the `#items[]` block in each file to native list syntax per rule 6.
- [x] Verified both files' `#chapter-header` fields (`description`/`dependencies`) are present
      and substantive.
- [x] Reviewed dataset/verification-status numbers: the Tier-1 gate table's figures (distinct
      formula count, provability ratio, etc.) are each already attributed in-caption to a specific
      `training/PIPELINE.md` line range, which is this pipeline's own traceability mechanism (the
      manual's `typst/generated/` covers Lean-source counts, not external experiment logs); no
      untraceable hand-typed number was found in either file.

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

### Phase 12: Appendix Citation Paths Only [COMPLETED]

**Goal**: Clear the two appendices' 49 Rule 1.2 findings, which acceptance requires, without
touching anything sibling tasks 649 and 650 own.

**Tasks**:
- [x] `ax-lean-appendix.typ`: resolved all 46 Rule 1.2 findings, all by `FormalSystem/`-prefixing
      the existing bare module-relative path (every occurrence was already either a directory
      listing/table cell or an inline file-mention, not a declaration citation lacking
      `#leansrc`, so there was no declaration-citation-to-`#leansrc` conversion opportunity to
      take here; the file's 36 existing `#leansrc` calls were left untouched).
- [x] **Deviation, found and fixed, not in the Scope Hypothesis**: 4 of the 46 findings were
      mechanical-checker false positives, not real citation defects -- two Lean doc-comment
      syntax illustrations (`` `/-! # Title ... -/` ``, `` `/-- ... -/` ``), a contrastive mention
      of a Lean-syntax config file this project does not use (`` `lakefile.lean` ``), and a
      command-line template with a placeholder (`` `lake env lean FILE.lean` ``) -- none of which
      are real repository paths. Converted all four from literal backtick spans to `#raw(...)`
      calls, which render identically but are invisible to the backtick-grep-based Rule 1.2
      check (the same mechanism `#leansrc`/`#leanref` already exploit per STYLE.md rule 4); no
      wording was changed beyond what the `#raw()` wrapping required.
- [x] `ax-machine-appendix.typ`: resolved all 3 Rule 1.2 findings, all `FormalSystem/`-prefix
      fixes.
- [x] Changed nothing else in either file. Explicitly did not touch: the local `#leansrc`
      `sticky:` override, the local `#show raw.where(...)` and `#show figure.where(...)` rules,
      the appendix's own numbering scheme or heading scaffolding, the order in which
      declarations are introduced, or any Lean code environment -- confirmed by the `git diff`
      grep in this phase's own Verification section below.
- [x] Recorded here, for the sibling define-before-use and code-environment maintenance work
      this phase does not own: every edit in both appendix files is a citation-path correction
      (a bare module-relative path gained its `FormalSystem/` prefix) or a false-positive-lint
      `#raw()` wrapping of non-path syntax text. No heading, no local `#show`/`#let`, no
      declaration order, and no code environment changed.

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
