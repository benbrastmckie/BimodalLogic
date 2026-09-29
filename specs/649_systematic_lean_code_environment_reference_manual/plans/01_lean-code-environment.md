# Implementation Plan: One Lean-Code Environment for the Reference Manual

- **Task**: 649 - Systematic Lean code environment for the Bimodal Reference Manual
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: None outstanding (tasks 647 and 648 are both archived/completed; their
  output is already live in `typst/` and is the baseline this plan measures)
- **Research Inputs**: `specs/649_systematic_lean_code_environment_reference_manual/reports/01_lean-code-environment.md`
- **Artifacts**: plans/01_lean-code-environment.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Promote the file-local code-presentation rules that `typst/chapters/ax-lean-appendix.typ`
already proves work into one book-wide environment defined in `typst/template.typ`, with two
declared kinds (source excerpt, carrying a module-qualified label bound inseparably to its
code; didactic example, carrying no label), a language parameter covering the JSON and Python
listings, geometry stated once in absolute units, and a stated column budget every block fits
without wrapping. Migrate every call site in the manual to it, delete the file-local copies,
keep `leansrc` exported unchanged so `typst/FormalFoundations.typ` compiles untouched, add a
mechanical Check 4 to `scripts/typst-sync-check.sh`, and document the environment and its
fidelity policy in `typst/README.md`. Definition of done is the dispatch's acceptance bar:
both documents compile with zero errors, sync-check and element lint pass, the new check
passes and is demonstrated to fail on a planted violation of each kind, no bare fenced block
survives outside the environment, and rendered pages show no wrapped code line and no label
orphaned from its code.

### Research Integration

The report's measured findings drive this plan rather than the dispatch's approximations:

- **The `ax-lean-appendix.typ` file-local rules are the prototype to generalize, not
  redesign.** The report confirmed by rendering page 94 that 8pt raw text, `breakable: false`
  blocks with explicit 11pt spacing, and a `sticky: true` `leansrc` shadow visibly produce the
  banding the dispatch asks for. Phase 3 promotes exactly this behavior.
- **The nested-width tax is a real constraint, not a formality.** `thmbox` applies a `1em`
  left inset whenever `fill: none`, which every environment style in `template.typ` sets, so
  code inside `#example`/`#definition`/`#remark`/`#theorem` renders at roughly 332pt, not the
  full 343pt. The appendix's 71-column budget was tuned at 343pt and, by the report's
  arithmetic, already exceeds 332pt. Phase 2 re-derives the budget at the narrow width by
  rendering, not by estimating.
- **Syntax highlighting is already live and already inconsistent.** Typst auto-highlights the
  JSON and Python listings because they carry a `lang` tag; the thirty-odd Lean blocks render
  black because they carry none. The report established this as an accident, not a decision.
  Phase 2 makes it a decision against that real baseline.
- **The enforcement check belongs in `scripts/typst-sync-check.sh`, not the element lint.**
  The report found the element lint lives under `.claude/`, which is gitignored and
  regenerated from a source store outside this repository; editing it would be silently wiped
  and would violate the source-store/deploy boundary rule. `scripts/typst-sync-check.sh` is
  git-tracked and already contains, in Check 1, the exact Lean-source resolution machinery the
  new declaration-resolution requirement needs.
- **`FormalFoundations.typ` needs no migration at all.** Its roughly forty-five `#leansrc`
  calls are attribution-only; not one is followed by a code block. Keeping the existing
  `leansrc(module, name)` signature exported is the entire compatibility obligation.
- **`leanref` has zero call sites but is a documented cross-project convention.** The report
  recommends narrow adoption over deletion. Phase 2 decides and Phase 7 documents.

**Correction to the research inventory, measured during planning.** The report states 30
`#leansrc` calls in `ax-lean-appendix.typ`, each followed by a block, and implies the file's
block count equals its label count. A fence-pair scan of the live file finds **44 code blocks
and 31 `#leansrc` calls**, so **13 blocks in that file carry no label and are didactic**, not
excerpts. The manual's true totals are **50 blocks across six files, 34 of them
`#leansrc`-paired excerpts and 16 unlabeled didactic**. This roughly doubles the appendix's
migration surface versus the report's figure and is why Phases 4 and 5 split that file's
migration by kind. Every phase asserting one of these numbers carries a Scope Hypothesis line
requiring re-measurement before the edits begin.

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so no roadmap consultation was
performed as a planning input. `specs/ROADMAP.md` does exist and describes the `typst/`
monograph with `scripts/typst-sync-check.sh` as its mechanical claim-verification surface,
which is consistent with this plan's choice to extend that script rather than the deployed
element lint. No roadmap phases are added, because the roadmap flag is not set.

## Goals & Non-Goals

**Goals**:

- One environment exported from `typst/template.typ`, with two declared kinds distinguished at
  the call site, covering every code listing in the manual.
- Geometry (font size, absolute spacing above and below, unbreakability, optional opt-out)
  stated once in the template, beside a written-down column budget.
- Every code block in the manual fits that budget with no wrapped line, re-broken at
  whitespace only, with no token altered.
- A mechanical check that fails on a bare fenced block outside the environment, on an
  over-budget line, and on a source-excerpt call whose declaration does not resolve in live
  non-Boneyard Lean source.
- The environment, its two kinds, the column budget, and the excerpt-fidelity policy
  documented in `typst/README.md`.
- `typst/FormalFoundations.typ` compiles unchanged.

**Non-Goals**:

- No change to the wording of any prose sentence, and no change to any code token.
- No change to `ax-lean-appendix.typ`'s `A.n` section-numbering rules or its list and figure
  spacing rules; those stay file-local.
- No wholesale conversion of the manual's inline backtick spans to `#leanref`; Check 1 must
  keep resolving every one of them.
- No investigation or repair of the green `thmbox` example-box coloring the report noticed;
  that is outside code-block presentation.
- No edits under `.claude/**`, which is a disposable deploy artifact.
- No task numbers and no `specs/` paths in any deliverable file.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The chosen column budget fits at full text width but wraps inside a `thmbox` environment (the ~332pt nested case) | H | H | Phase 2 derives the budget by rendering the narrowest real case (`p4-dual-verification.typ`'s nested example), not the widest; Phase 9 re-renders it as acceptance |
| Wrapping label and code in one outer block fights the label's own internal spacing and regresses the appendix's proven appearance | M | M | Phase 3 tries the single-outer-block form first and falls back to the prototype's `sticky: true` plus `breakable: false` pairing, which is already known to render correctly |
| Re-breaking long lines silently alters a token, breaking Check 1 or the excerpt-fidelity policy | H | M | Re-break at whitespace only; Phase 9 diffs every changed block's concatenated non-whitespace characters against its pre-migration form |
| Migrating 44 blocks in one file by hand introduces an unpaired label or a dropped fence | M | M | Phases 4 and 5 split that file by kind and re-run the fence-pair scan after each; Phase 6's new check catches survivors mechanically |
| Editing the deployed element lint under `.claude/` instead of the tracked script | H | L | Explicitly forbidden in Non-Goals and in Phase 6's tasks; the check goes in `scripts/typst-sync-check.sh` |
| Changing `leansrc`'s signature breaks `FormalFoundations.typ` | H | L | Signature is frozen; Phase 3 keeps it as a thin wrapper and Phase 9 compiles that document as a gate |
| A sibling task commits into the shared working tree mid-phase | M | M | Re-read each file immediately before editing; stage only this task's own hunks with an explicit file list, never a directory or glob |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 6 | 3 |
| 5 | 5 | 4 |
| 6 | 7 | 5, 6 |
| 7 | 8 | 3, 7 |
| 8 | 9 | 7, 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Re-measure the baseline and capture before-renders [COMPLETED]

**Goal**: Establish the exact, current inventory and the rendered visual baseline that every
later phase is judged against, so that the report's undercount cannot propagate.

**Tasks**:

- [ ] Compile both documents from a clean tree and record that both are at zero errors:
      `typst compile --root .. BimodalReference.typ` and
      `typst compile --root .. FormalFoundations.typ`, run from `typst/`.
- [ ] Run a fence-pair scan over `typst/chapters/*.typ` and `typst/FormalFoundations.typ`
      recording, per file: block count, `#leansrc` call count, how many blocks are immediately
      preceded by a `#leansrc` call, and the widest line inside any block.
- [ ] Record the resulting per-file table as the migration worklist, and note explicitly which
      blocks in `ax-lean-appendix.typ` are unlabeled.
- [ ] Render every page carrying a code block to PNG with `pdftoppm`, keeping one page per
      affected chapter as the named before-image for the summary.
- [ ] Record the current `#leanref` call-site count across `typst/` (expected zero) and the
      two definition sites.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This plan asserts 50 code blocks across six chapter files, 34 of them
`#leansrc`-paired and 16 unlabeled, with `ax-lean-appendix.typ` holding 44 blocks against 31
labels. Confirm by running the fence-pair scan above before any edit; if the counts differ,
update the worklist and the affected phases' task lists before proceeding rather than editing
against the stale figure.

**Files to modify**:

- none planned - this phase is measurement and rendering only; scratch renders go to the
  session scratchpad, never into the repository

**Verification**:

- Both compiles report zero errors.
- The scan output names a block count, a label count, and a widest-line figure for each of the
  six code-bearing chapter files.
- One before-render PNG exists per affected chapter.

**Measured Results**: Both documents compiled at zero errors. Fence-pair scan confirms the
plan's Scope Hypothesis exactly: 50 code blocks across six chapter files (44 in the Lean
appendix, 1 in the machine appendix, 2 in the decidability-practice chapter, 1 in the
frame-classes chapter, 1 in the dataset-pipeline chapter, 1 in the dual-verification chapter),
34 `#leansrc`-paired (31 in the appendix + 2 + 1 = 34) and 16 unlabeled didactic (13 in the
appendix + 1 machine appendix + 1 dataset-pipeline + 1 dual-verification). Widest lines: 71
(appendix, machine appendix), 78 (decidability-practice signature, dataset-pipeline JSON), 26
(frame-classes), 88 (dual-verification, nested inside `#example`). `#leanref` has zero call
sites across `typst/` and two definition sites (`template.typ:130`,
`notation/shared-notation.typ:60`); the latter is not imported by either document. Six
before-render PNGs captured to the session scratchpad (not committed).

---

### Phase 2: Decide geometry, highlighting, separation, and inline policy by rendered comparison [COMPLETED]

**Goal**: Settle the four open design questions the research deliberately left open, each
against a rendered comparison rather than an estimate, and write the decisions down where the
implementer of Phase 3 will read them.

**Tasks**:

- [ ] Build a scratch probe document that reproduces the two hardest real cases: the widest
      plain block and the widest block nested inside `#example`, which is where the `thmbox`
      left inset narrows the available width.
- [ ] Sweep candidate font sizes and column budgets on the probe, rendering each, and pick the
      pair for which the nested case does not wrap. Record the chosen size, the chosen column
      count, and the measured width the count occupies at that size.
- [ ] Decide highlighting against the real baseline the research established, which is JSON
      and Python currently colored and Lean currently black. Render the candidate uniform
      treatment and the current state side by side, and record which is adopted and why.
- [ ] Render a left-indent variant and a thin-left-rule variant of the same block against the
      plain variant, and record which separation treatment is adopted.
- [ ] Decide whether `#leanref` is adopted narrowly or removed, recording the stated purpose if
      adopted. Adoption must not require converting any existing inline backtick span.
- [ ] Decide whether the atomicity mechanism is a single outer unbreakable block wrapping label
      and code, or the prototype's `sticky` label plus unbreakable code pairing, and record the
      fallback condition.
- [ ] Write all six decisions into a short decision block that Phase 3 transcribes into the
      template comment and Phase 8 transcribes into `typst/README.md`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research estimates that 71 columns at 8pt occupies roughly 341pt,
which would already exceed the roughly 332pt available inside a `thmbox` environment, and
suggests roughly 69 columns as the boundary. Treat both numbers as unconfirmed: confirm the
adopted budget by rendering the nested probe at the candidate size and checking for a wrap,
not by re-deriving the arithmetic.

**Files to modify**:

- none planned - probe documents are scratch and are not committed; the output of this phase
  is the recorded decision block consumed by Phases 3 and 8

**Verification**:

- A rendered nested-case probe at the adopted font size and column budget shows no wrapped
  line at the budget width and a wrap at one column beyond it.
- A before-and-after render pair exists for the highlighting decision and for the separation
  decision.
- All six decisions are written down, each with the render that justifies it named.

**Decision Block (from rendered probes, scratch, not committed)**:

1. **Geometry**: measured via `#layout` that the plain top-level content width is 343.28pt and
   the nested width inside `#example`/`#definition` is 321.28pt (narrower than the report's
   332pt estimate). A rendering sweep of the actual `raw()` default font found its per-glyph
   width inconsistent (a repeated-`M` calibration predicted 70+ nested columns, but real
   Lean-token content measurably wrapped as early as 66-67 columns), so the environment sets an
   **explicit font, `"DejaVu Sans Mono"`**, confirmed by a glyph-coverage render to cover every
   non-ASCII symbol appearing inside a code block across the manual (`¬ ↑ → ↔ ∀ ∃ ∈ ∧ ≤ ⊆ ⊢ ⊨ □
   △ ▽ ◇ ⟨ ⟩ ₁ ₂ Γ Δ σ τ φ ψ`) with no missing-glyph fallback. At 8pt with this font, a
   boundary sweep against real appendix content (the `Derivable` signature) found **66 columns
   fit the nested width and 67 wraps**; the adopted **column budget is 65**, applied as one
   number book-wide (not a tiered plain/nested pair), because it is derived from the binding
   nested case and every plain top-level block has strictly more headroom at the same budget.
   Font size stays 8pt, matching the appendix prototype's already-legible precedent.
2. **Spacing**: 11pt above and below, absolute (not em), unchanged from the prototype -- em
   inside the raw show rule resolves to the 8pt code size, not the 11pt body size.
3. **Breakability**: unbreakable by default; an explicit `breakable: true` parameter opts out
   for a listing too long to fit one page.
4. **Highlighting**: adopted uniform **black-only, no syntax highlighting**, via `theme: none`
   on every `raw()` call the environment makes, for every language. Before/after render:
   before, JSON keys/strings render in blue/green while the Lean `def decide (phi : Formula) :
   DecisionResult phi` line renders plain black in the same visual unit; after, both render
   identically in black. This resolves the research's "accident, not a decision" finding in
   favor of the template's stated austere, black-only, no-fills aesthetic.
5. **Separation**: **left indent (1em)**, not a left rule. A rendered three-way comparison
   (plain / left-indent / thin-left-rule) found the left rule visually competes with thmbox's
   own colored left bar already marking `#example`/`#definition`/etc., which is confusing when
   a code block sits inside one of those environments (a rule inside a rule); plain alone
   under-distinguishes the block from surrounding prose. Left indent reads as a distinct
   typographic unit without adding a second bar convention.
6. **Language parameter**: one environment, not a sibling. `lang` is accepted for optional
   semantic tagging only (documentation value; e.g. a future tool that reads it) and has no
   visible rendering effect, since highlighting is globally disabled. JSON and Python share the
   Lean environment rather than a separate one.
7. **Atomicity mechanism**: a **single outer `#block(breakable: false)`** wraps the label (when
   present) and the code as one unit, simpler than the prototype's separate `sticky: true`
   label plus `breakable: false` code pairing. **Fallback**: if Phase 3's real-document
   integration finds the single-block form mis-renders (e.g. the label's own internal spacing
   fights the outer block's), fall back to the prototype's proven sticky-plus-unbreakable
   pairing instead.
8. **`#leanref`**: **adopted**, narrowly. Stated purpose: renders an inline Lean identifier in
   the environment's own font (`DejaVu Sans Mono`) for visual consistency with block excerpts,
   marking a name as a deliberate cross-reference to a live declaration rather than an ordinary
   inline code span. No existing inline backtick span is converted; Check 1 keeps resolving all
   of them unchanged.

---

### Phase 3: Define the environment in the template [COMPLETED]

**Goal**: Add one code environment to `typst/template.typ` implementing the Phase 2 decisions,
keeping `leansrc` exported with its current signature so `FormalFoundations.typ` is untouched.

**Tasks**:

- [ ] Re-read `typst/template.typ` immediately before editing, in case a sibling task has
      changed it.
- [ ] Define the environment taking an optional source argument of module and declaration name.
      Present selects the source-excerpt kind, which renders the module-qualified label and the
      code as one unit that cannot split across a page break, with the label visibly closer to
      its code than the code is to the surrounding prose. Absent selects the didactic kind,
      visibly the same family with no label.
- [ ] Give the environment a language parameter so the JSON and Python listings share it rather
      than needing a sibling environment, applying the Phase 2 highlighting decision uniformly.
- [ ] Give it an explicit unbreakability opt-out parameter for a listing too long to fit a page.
- [ ] Set the font size, the absolute spacing above and below, and the separation treatment
      from Phase 2. Spacing must be in absolute units, because `em` inside a raw show rule
      resolves to the code size rather than the body size.
- [ ] Write the column budget, the reason spacing is absolute, and the excerpt-fidelity policy
      (verbatim up to whitespace, docstrings omitted) into the comment directly above the
      definition.
- [ ] Keep `leansrc(module, name)` exported with its current two-argument signature, as a thin
      wrapper over the new environment's label rendering.
- [ ] Apply the Phase 2 decision on `leanref`: either give its definition a stated purpose in a
      comment, or remove it from `template.typ`. If removed, check whether the duplicate
      definition in `typst/notation/shared-notation.typ` is reachable from either document
      before touching it.
- [ ] Confirm both documents still compile before committing.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes `typst/template.typ` is the only definition site that
must change, and that every chapter reaches the new environment through its existing
`#import "../template.typ": *`. Confirm by grepping the chapter files for their import lines
before editing; a chapter importing a named subset rather than a glob needs its import list
extended.

**Files to modify**:

- `typst/template.typ` - add the code environment, its geometry, its documented column budget
  and fidelity policy; rewire `leansrc` as a thin wrapper; apply the `leanref` decision
- `typst/notation/shared-notation.typ` - only if the `leanref` decision requires it and the
  definition is confirmed reachable

**Verification**:

- `typst compile --root .. BimodalReference.typ` and
  `typst compile --root .. FormalFoundations.typ` both report zero errors.
- `FormalFoundations.typ` is byte-identical to its pre-phase state.
- A scratch call site of each kind renders with the Phase 2 geometry.

**Budget correction found during implementation**: Phase 2's rendered sweep measured the
nested-width cutoff (66 fits / 67 wraps) without the `lean-code-indent` 1em left inset that
Phase 3's separation decision also applies. Re-measured with the actual `lean-code()` block
(inset included), real appendix content cuts at **64 fits / 65 wraps**; the adopted
`lean-code-column-budget` is **63** (one column of margin below the confirmed boundary),
correcting the Phase 2 decision block's provisional 65. `lean-code-size` (8pt),
`lean-code-font` ("DejaVu Sans Mono"), `lean-code-space` (11pt), `lean-code-indent` (1em) and
`lean-code-label-gap` (3pt, the internal label-to-code gap, smaller than the 11pt block-to-prose
gap on both sides) are unchanged from Phase 2. `typst/template.typ` now exports `lean-code`
(the environment), `lean-code-label-raw` (shared internal helper), `leansrc` (thin wrapper,
signature unchanged), `leanref` (adopted, rendered in `lean-code-font`), and the five geometry
constants above. A scratch smoke test confirmed both kinds, `leanref`, standalone `leansrc`
followed by a bare (unmigrated) raw block (proving `leansrc` alone does not leak styling into
unrelated content, which `FormalFoundations.typ`'s ~67 attribution-only calls depend on), a
`lean-code` nested inside `#example` with a `json`-fenced body (black, no highlighting), and
`breakable: true` all render correctly. `typst/FormalFoundations.typ` is byte-identical to its
pre-phase state (`git diff` empty).

---

### Phase 4: Migrate the labeled excerpt blocks in the Lean appendix [COMPLETED]

**Goal**: Convert every `#leansrc`-paired block in `typst/chapters/ax-lean-appendix.typ` to the
environment's source-excerpt kind, re-breaking any over-budget line, and delete the file-local
raw and `leansrc` rules the template now supplies.

**Tasks**:

- [ ] Re-read the file immediately before editing.
- [ ] Convert each `#leansrc` call and its following fenced block into a single source-excerpt
      call carrying the same module and declaration name and the same code characters.
- [ ] Re-break any line exceeding the adopted budget at whitespace only, using one consistent
      layout for a declaration: name and parameters, then hypotheses, then conclusion. Never
      alter a token.
- [ ] Delete the file-local `show raw.where(block: true)` text-size rule, the file-local raw
      block spacing and unbreakability rule, and the file-local shadowed `leansrc`, once the
      template supplies all three.
- [ ] Leave the file's `A.n` heading-numbering rule and its list and figure spacing rules
      untouched.
- [ ] Re-run the fence-pair scan on this file and confirm the labeled-block count reached zero
      remaining unmigrated.
- [ ] Compile and render the appendix pages, comparing against the Phase 1 before-images.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts 31 labeled excerpt blocks in this file, and that its
widest block line is currently 71 columns and may therefore already exceed a budget below 71.
Confirm both against the Phase 1 scan output before editing; the number of lines actually
needing a re-break depends entirely on the budget Phase 2 adopted and must be recounted, not
assumed to be zero.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - migrate the labeled excerpt blocks; delete the three
  file-local code-presentation rules

**Verification**:

- No `#leansrc` call in this file is followed by a bare fenced block.
- The three named file-local rules are gone and the heading-numbering and list/figure rules
  remain.
- `typst compile --root .. BimodalReference.typ` reports zero errors.
- Rendered appendix pages show every label banded to its code and no wrapped line.

**Measured results**: all 31 `#leansrc`-paired blocks converted to
`#lean-code(source: (module, name))[...]`, mechanically (script-driven wrap, verified 0 bad
wraps by a fence-pair audit). 13 lines exceeded the 63-column budget after wrapping; each was
re-broken at whitespace, following name-and-parameters/hypotheses/conclusion where the content
was a declaration signature, and a plain whitespace split for a proof-body expression or a
comment. A token-fidelity diff (concatenated non-whitespace characters, before vs. after, all 44
blocks) found exactly one non-whitespace insertion: a repeated `--` comment marker needed to keep
a wrapped continuation line a valid Lean line comment (`-- Recall: ... = ...` split across two
comment lines) -- not a code token. The three file-local rules (8pt raw-block size, spacing plus
unbreakability, and the shadowed `leansrc`) are deleted; the file's `A.n` heading-numbering rule
and its list/figure spacing rules are untouched. `typst compile --root .. BimodalReference.typ`
is zero errors; page 94 (`Derivable`) rendered and compared against the Phase 1 before-image:
same tight label-to-code banding, left-indented, no wrapped line, same gap to the following
paragraph.

---

### Phase 5: Migrate the unlabeled didactic blocks in the Lean appendix [COMPLETED]

**Goal**: Convert the appendix's remaining unlabeled blocks, which the research inventory
missed entirely, to the environment's didactic kind.

**Tasks**:

- [ ] Re-read the file immediately before editing.
- [ ] Convert each remaining bare fenced block in the file to a didactic-kind call.
- [ ] Re-break any over-budget line at whitespace only, altering no token.
- [ ] Confirm no bare fenced block survives anywhere in the file.
- [ ] Compile and re-render the affected pages.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts 13 unlabeled blocks remain in this file after Phase 4.
Confirm by re-running the fence-pair scan on the post-Phase-4 file; this figure is a planning
measurement of the current tree and will shift if Phase 4's conversions differ from plan.

**Files to modify**:

- `typst/chapters/ax-lean-appendix.typ` - migrate the unlabeled didactic blocks

**Verification**:

- A scan for bare fenced blocks in this file returns nothing.
- `typst compile --root .. BimodalReference.typ` reports zero errors.
- Didactic blocks render in the same family as excerpt blocks, without a label.

**Deviation from plan**: Phase 4's mechanical wrap (a script converting every fence pair in the
file, not just `#leansrc`-paired ones) migrated all 44 blocks -- both the 31 labeled and the 13
unlabeled -- in the same pass, since the same bottom-up transform handled both cases uniformly
(labeled: wrap in `#lean-code(source: (...))[...]`; unlabeled: wrap in `#lean-code[...]`) with no
extra risk from doing both at once. Phase 5's own verification is run here as confirmation
rather than as new migration work: a fence-pair scan finds 13 `#lean-code[` (no `source:`)
blocks and 0 bare fenced blocks remaining anywhere in the file; `typst compile --root ..
BimodalReference.typ` is zero errors (shared with Phase 4's compile); page 96 (the `boxPImpP`
term-mode block, unlabeled) rendered and inspected -- same indented, unbreakable, black family as
the labeled blocks, no label line, no wrapped code line.

---

### Phase 6: Migrate the remaining chapters, including the non-Lean listings [COMPLETED]

**Goal**: Convert the code blocks in the four other code-bearing chapters, exercising the
nested-environment case and the language parameter.

**Tasks**:

- [ ] Re-read each file immediately before editing.
- [ ] Convert the two labeled blocks in `typst/chapters/p2-decidability-practice.typ`,
      re-breaking the over-budget declaration signature at whitespace only.
- [ ] Convert the one labeled block in `typst/chapters/p2-frame-classes.typ`.
- [ ] Convert the didactic block nested inside `#example` in
      `typst/chapters/p4-dual-verification.typ`, which is the widest block in the manual and
      the one rendered in the narrowest box, and confirm it fits the nested budget.
- [ ] Convert the JSON listing in `typst/chapters/p4-dataset-pipeline.typ` through the language
      parameter.
- [ ] Convert the Python listing in `typst/chapters/ax-machine-appendix.typ` through the
      language parameter.
- [ ] Compile and render each affected page, comparing against the Phase 1 before-images.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts five blocks across four files, with current widest
lines of 78, 26, 88, 78 and 71 columns respectively. Confirm against the Phase 1 scan before
editing; the 88-column nested case is the binding constraint and must be re-measured in its
rendered box rather than from its source line length.

**Files to modify**:

- `typst/chapters/p2-decidability-practice.typ` - migrate two labeled excerpt blocks, re-break
  the over-budget signature
- `typst/chapters/p2-frame-classes.typ` - migrate one labeled excerpt block
- `typst/chapters/p4-dual-verification.typ` - migrate the didactic block nested in `#example`
- `typst/chapters/p4-dataset-pipeline.typ` - migrate the JSON listing via the language
  parameter
- `typst/chapters/ax-machine-appendix.typ` - migrate the Python listing via the language
  parameter

**Verification**:

- A scan for bare fenced blocks across these four files returns nothing.
- `typst compile --root .. BimodalReference.typ` reports zero errors.
- The nested example page renders with no wrapped line.

**Measured results**: all five files migrated. `p2-decidability-practice.typ`'s two labeled
blocks (`FilteredWorld`, `decide`); the `decide` signature (78 columns) re-broken across three
lines (parameters, then `tableauFuel`, then the frame-class hypothesis and conclusion).
`p2-frame-classes.typ`'s one labeled block (26 columns, no re-break needed).
`p4-dual-verification.typ`'s didactic block nested in `#example`, the manual's widest (86
columns before re-break) and narrowest real rendering box (321.28pt): both `modal_search`
lines re-broken at `:=`/`.box.imp` whitespace boundaries; rendered page 87 confirmed no wrap and
no regression from the Phase 1 before-image. `p4-dataset-pipeline.typ`'s JSON listing migrated
through the same `lean-code[...]` call (language carried by the fence's own ` ```json ` tag, no
separate parameter needed); two over-budget lines (`formula_ast`, `proof_trace`) re-broken at a
JSON comma boundary, which is always a safe re-break since JSON's grammar is whitespace-
insensitive outside string literals. `ax-machine-appendix.typ`'s Python listing migrated the
same way; its one over-budget line re-broken inside the list comprehension's enclosing brackets,
valid Python line-continuation with no token altered. A whole-chapters bare-fence scan (all of
`typst/chapters/*.typ`) finds zero fenced blocks outside `lean-code(...)`/`lean-code[`. Both
`typst compile --root .. BimodalReference.typ` and `... FormalFoundations.typ` are zero errors;
`FormalFoundations.typ` remains byte-identical (`git diff` empty).

---

### Phase 7: Add the mechanical check [COMPLETED]

**Goal**: Extend `scripts/typst-sync-check.sh` with a Check 4 that fails on each of the three
violation kinds the dispatch names, and demonstrate each failure on a planted violation.

**Tasks**:

- [ ] Re-read the script immediately before editing and follow the structure its three existing
      checks already use: a named run function, a report variable echoed to stderr, and a
      `FAIL=1` on violation, with the summary line updated to name four checks.
- [ ] Implement the bare-fenced-block scan over `typst/chapters/*.typ`, reporting each
      offending file and line.
- [ ] Implement the column-budget scan, failing on any line inside a code environment that
      exceeds the adopted budget, and report the file, line and measured width.
- [ ] Implement the declaration-resolution scan for source-excerpt calls, reusing Check 1's
      existing resolution approach against the live Lean source roots with `Boneyard` excluded
      and the existing whitelist honored.
- [ ] Keep the check build-free so it does not require a built library, matching the
      constraints the existing fast checks already observe.
- [ ] Update the script's header comment and its usage text to describe four checks.
- [ ] Plant one violation of each kind in turn, in a scratch copy or reverted immediately,
      confirm the check fails and names it, then restore and confirm the check passes.
- [ ] Do not edit the element lint under `.claude/`, which is gitignored and regenerated from a
      source store outside this repository.

**Timing**: 2 hours

**Depends on**: 5, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes Check 1's resolution machinery can be reused for
module-qualified declaration resolution with only a small variant, and that the script's
existing flag dispatch accommodates a fourth check without restructuring. Confirm by reading
the script's Check 1 body and its flag-handling block before writing new code.

**Files to modify**:

- `scripts/typst-sync-check.sh` - add Check 4 with its three scans, update the header comment
  and the summary line

**Verification**:

- `bash scripts/typst-sync-check.sh` exits zero and its summary names four green checks.
- Each of the three planted violations produces a non-zero exit and a report naming the file
  and line.
- The existing checks' behavior is unchanged on a clean tree.

**Measured results**: Check 4 added to `scripts/typst-sync-check.sh` as `run_check4_codeblocks`,
wired into full-mode after Check 3 and into the summary line (now "all 4 checks green"), reusing
Check 1's `grep_lean`/whitelist machinery for declaration resolution. All three violation kinds
were planted, one at a time, in `typst/chapters/p2-frame-classes.typ` and reverted immediately
after each (`git diff` confirmed empty between plants): a bare fenced block, a 80-column line,
and an unresolvable `PlantedViolationNoSuchDeclarationXyzzy` name -- each produced exactly one
`CHECK4_VIOLATIONS=1` failure naming the file, line, and reason; after each revert Check 4 (and
the whole script, modulo the pre-existing Check 2 drift below) returned to its clean state. On
the real, unmodified tree, Check 4 reports `CHECK4_VIOLATIONS=0` across every file under
`typst/chapters/`. The check is build-free (grep and Python file reads only, no `lake` or `typst
compile` invocation) and the element lint under `.claude/` was not touched, per the Non-Goals.

**Unrelated, pre-existing Check 2 drift observed (not fixed, out of scope)**: while running the
full script, `formalsystem-line-count` (Check 2, comparing committed `generated/status.typ`
against a live regeneration from `FormalSystem/`) failed and its live value changed across two
consecutive runs. `git log` confirms this tracks a concurrent sibling task's ongoing commits to
`FormalSystem/Metalogic/Decidability/` in this shared working tree, not any edit made by this
task -- `FormalSystem/` is outside this plan's file scope and untouched by it (`git status`
clean there throughout). Reported to the orchestrating session per the territory/concurrency
protocol; left unfixed here since regenerating `generated/status.typ` is a Lean-source-count
concern orthogonal to code-block presentation and outside this task's Non-Goals-bounded scope.

---

### Phase 8: Document the environment [COMPLETED]

**Goal**: Record the environment, its two kinds, the column budget, the fidelity policy and the
new check where a future author will find them.

**Tasks**:

- [ ] Add a section to `typst/README.md` describing the environment, when to use the
      source-excerpt kind and when the didactic kind, the language parameter, the
      unbreakability opt-out, the adopted column budget and font size, and the excerpt-fidelity
      policy: verbatim up to whitespace, docstrings omitted.
- [ ] Update the README's scripts section, which currently describes the drift detector as two
      checks, to describe the checks it actually runs including the new one.
- [ ] Record the `#leanref` decision from Phase 2 in `typst/STYLE.md`'s existing citation-forms
      rule, whether that is a stated narrow purpose or removal.
- [ ] Use no task numbers and no `specs/` paths in any of this text.

**Timing**: 45 minutes

**Depends on**: 3, 7

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:

- `typst/README.md` - document the environment, the two kinds, the budget, the fidelity policy,
  and correct the drift-detector check count
- `typst/STYLE.md` - record the `#leanref` decision in the existing citation-forms rule

**Verification**:

- The README names the environment, both kinds, the column budget, the font size and the
  fidelity policy.
- A scan of both files finds no task number and no `specs/` path.

**Measured results**: `typst/README.md` gained a "Code Environment" section (both kinds, the
font/geometry/budget/fidelity policy, and the `leansrc`/`leanref` compatibility note) and its
Scripts section now describes all four sync-check checks accurately (it previously said "2
checks", already stale before this task against the 3 checks the script already ran -- fixed as
part of this same edit). `typst/STYLE.md`'s existing Lean-citations table row for inline
identifiers now records `#leanref`'s stated purpose (matching `lean-code()`'s font) inline. Both
documents still compile at zero errors; a scan of both files finds no task-number reference and
no `specs/` path.

---

### Phase 9: Acceptance pass and after-renders [NOT STARTED]

**Goal**: Run the dispatch's full acceptance bar and produce the before-and-after render set
the summary requires.

**Tasks**:

- [ ] Compile both documents with `typst compile --root ..` and confirm zero errors for each.
- [ ] Run `bash scripts/typst-sync-check.sh` and confirm PASS across all four checks.
- [ ] Run the element lint over the affected files and confirm PASS, without editing it.
- [ ] Confirm a scan finds no bare fenced block anywhere in `typst/chapters/`.
- [ ] Render every page containing a code block to PNG and inspect each: no wrapped code line,
      no source label separated from its code, no code block touching the paragraph after it,
      and a consistent appearance across chapters.
- [ ] Diff each migrated block's concatenated non-whitespace characters against its
      pre-migration form, confirming no token was altered by a re-break.
- [ ] Confirm `typst/FormalFoundations.typ` is unchanged from its pre-task state.
- [ ] Assemble one before-and-after render pair per affected chapter for the summary.

**Timing**: 1.5 hours

**Depends on**: 7, 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:

- none planned - this phase is verification and rendering; any defect it finds is fixed in the
  owning phase's files and re-verified here

**Verification**:

- Both compiles report zero errors.
- The drift detector and the element lint both report PASS.
- The bare-fence scan returns nothing.
- Every code-bearing page has an inspected after-render, and one before-and-after pair per
  affected chapter is collected.
- The token-fidelity diff is empty for every migrated block.

---

## Testing & Validation

- [ ] `typst compile --root .. BimodalReference.typ` exits zero with no errors.
- [ ] `typst compile --root .. FormalFoundations.typ` exits zero with no errors, from a file
      that is byte-identical to its pre-task state.
- [ ] `bash scripts/typst-sync-check.sh` reports PASS across all four checks.
- [ ] The new check fails, with a report naming the offending file and line, on a planted bare
      fenced block, a planted over-budget line, and a planted unresolvable declaration.
- [ ] The element lint reports PASS on every modified `typst/` file.
- [ ] A scan of `typst/chapters/` finds no bare fenced block outside the environment.
- [ ] Rendered pages show no wrapped code line, no orphaned source label, and no code block
      running into the following paragraph.
- [ ] Concatenated non-whitespace characters of every migrated block match the pre-migration
      form exactly.

## Artifacts & Outputs

- `typst/template.typ` carrying the code environment, its geometry, its documented column
  budget and fidelity policy, and the compatibility-preserving `leansrc` wrapper.
- Six migrated chapter files: `ax-lean-appendix.typ`, `p2-decidability-practice.typ`,
  `p2-frame-classes.typ`, `p4-dual-verification.typ`, `p4-dataset-pipeline.typ`,
  `ax-machine-appendix.typ`.
- `scripts/typst-sync-check.sh` carrying Check 4.
- `typst/README.md` and `typst/STYLE.md` documentation updates.
- Before-and-after render pairs, one page per affected chapter, referenced in the
  implementation summary.

## Rollback/Contingency

Work proceeds as per-phase commits scoped to an explicit file list, never a directory or glob
pathspec, because sibling tasks share this working tree. Reverting any single phase is a
targeted revert of that phase's commit.

If a phase must be abandoned mid-edit with uncommitted changes present, take a durable,
non-reverting checkpoint before doing anything destructive, using
`bash .claude/scripts/git-snapshot.sh 649 --no-revert`. Only a genuine whole-tree rollback uses
the reverting default form, and only per the rollback rung in
`.claude/context/contracts/recovery.md`, including its out-of-scope override flag; never emit
the default form as a routine start-of-phase precaution.

The lowest-risk partial state is Phases 1 through 3 committed with no migration: the template
gains an unused environment, both documents still compile, and the manual renders exactly as
today. If the column budget proves unworkable at the nested width, the documented fallback is
to accept two budgets, one for plain and one for nested context, both written down beside the
definition, rather than shrinking the font below legibility.
