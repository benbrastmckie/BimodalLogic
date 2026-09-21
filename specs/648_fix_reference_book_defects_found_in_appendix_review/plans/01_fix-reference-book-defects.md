# Implementation Plan: Fix Reference-Book Defects Found in Appendix Review

- **Task**: 648 - Fix the defects found in `typst/BimodalReference.typ` and its surroundings during the accuracy-and-formatting review of `typst/chapters/ax-lean-appendix.typ`
- **Status**: [IMPLEMENTING]
- **Effort**: 8.5 hours
- **Dependencies**: Task 647 (extend the Lean appendix) — landed, final commit `a171dc67e`
- **Research Inputs**: `reports/01_fix-reference-book-defects.md`
- **Artifacts**: plans/01_fix-reference-book-defects.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Nine numbered defect items, all outside `typst/chapters/ax-lean-appendix.typ`'s content, spanning
the shared Typst template and show-rules, five chapter files, three Lean docstring files, the
sync-check whitelist and `typst/SYNC-MAP.md`. Research re-verified every item against live source:
eight reproduce, one sub-claim (a bare `@machine-appendix` reference) does not exist and is closed
as not-reproducing, and one additional, unflagged blocker was found — `scripts/typst-sync-check.sh`
currently FAILS with 5 Check-1 violations, which must be cleared before this task's own acceptance
criterion can be met. Definition of done is the dispatch's ACCEPTANCE block: a clean `typst
compile`, zero compile warnings, `typst-sync-check.sh` PASS, a green `lake build --wfail`,
rendered-page inspection of every touched chapter, and an item-by-item disposition summary.

### Research Integration

- The sync-check failure is live and re-confirmed at plan time (5 Check-1 violations, all from
  currently-uncommitted `// TODO:` comments inside the off-limits appendix). Whitelist additions
  in `typst/sync-check-whitelist.txt` are the sanctioned in-scope remedy, and Phase 1 exists
  solely to clear this first so every later phase's verification is meaningful.
- Item 3's true figures are machine-counted, not taken from the dispatch text: 29 `Axiom`
  constructors, 27 entries in `tryAxiomMatch`'s `axiomCtors`, omitted set exactly
  `{prior_U_gap, sep}`. The dispatch's third name `prior_S_gap` does not exist as an `Axiom`
  constructor; the real `DerivedAxioms.priorSGap` is a derived theorem reached by
  `tryGatedDerivedMatch`, not by `tryAxiomMatch`. `Commands.lean`'s `modal_search` docstring is
  already correct and is the template the other two sites are corrected to.
- Item 5's claim is false in all three places: both `Axiom` and `DerivationTree` are `Type`-valued.
  The correct explanation of why the search is hand-written in `TacticM` already exists in
  `Boneyard/RetiredTactics/README.md` and is the grounding source for the replacement text.
- Item 6 is elaboration-verified: `apply_axiom` and `modal_t` have byte-identical macro bodies and
  both leave `h` and `h_fc` open. The chapter's `modal_t` item is already correct and must be left
  alone; only its `apply_axiom` item and both Lean docstrings (including their broken worked
  examples and a stale "Supported Axioms" list naming non-constructors) need correction.
- Item 7 must not be aligned by copying the appendix's directory tour verbatim: that tour itself
  mis-attributes the dataset pipeline to `Automation/`/`Examples/`, contradicting the same file's
  own correct statement that `BimodalTools` is a separate library. Align coverage, state the
  correct attribution independently.
- Item 1's `@machine-appendix` half is closed as not-reproducing; the underlying rule bug is real
  and is still fixed. Plan-time re-check further narrows the blast radius: the only stale
  appendix-title link text is in `p4-dataset-pipeline.typ` (freely editable). The link inside the
  Lean appendix reads "the machine-readable appendix" with no title, so **no edit to
  `ax-lean-appendix.typ` beyond its own title/numbering block is required by item 1.**

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so no roadmap consultation was performed
and no roadmap phases are included. (`specs/ROADMAP.md` exists and tracks the Typst monograph, but
this round was not dispatched with the roadmap flag.)

## Goals & Non-Goals

**Goals**:
- Clear the live `typst-sync-check.sh` Check-1 failure by whitelist, so the acceptance gate is
  reachable.
- Fix the `#show ref` rule so no reference renders a run-together heading counter, and give both
  appendices a consistent, real appendix identity that references and the table of contents pick
  up.
- Bring `typst/SYNC-MAP.md` and `typst/sync-check-whitelist.txt` in line with the appendix's actual
  stated policy, and remove the ephemeral task-directory path from a shipped deliverable.
- Make the three axiom-count statements agree on machine-verified figures and the true two-element
  omitted set, sourcing the total from the generated value rather than a typed numeral.
- Correct the `DecisionResult`, `Axiom`-is-`Type`-valued, and `apply_axiom` descriptions in both
  the chapters and the Lean docstrings.
- Complete the introduction's project-structure list and correct its `BimodalTools` attribution.
- Make `#item` wrap with a hanging indent and make the build warning-free.

**Non-Goals**:
- Code-block presentation (wrapping, spacing, sticky source labels) — owned by the follow-on
  code-environment task, which also edits `template.typ` and `p2-decidability-practice.typ` and
  must land after this one.
- Any Lean statement or proof change. Every Lean edit here is confined to `/--`/`/-!` doc comments.
- Editing `typst/chapters/ax-lean-appendix.typ` beyond its own title heading and the adjacent
  appendix-local numbering block (item 1's mandated change). Its content, including its internal
  self-contradiction about `BimodalTools`, belongs to whatever task next owns that file.
- Building a generator for `tryAxiomMatch`'s own list length (the "27"); it stays a typed numeral,
  recorded as a residual manual-maintenance risk.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The appendix `// TODO:` diff that causes the Check-1 failure is uncommitted and may change, be reverted, or grow before implementation starts | M | M | Phase 1 re-runs `git status`/`git diff` on that file and the sync check before touching the whitelist; if the violations are gone, skip the addition and record it as not-reproducing rather than whitelisting spans that no longer exist |
| Giving level-1 appendix headings a real numbering steps the shared heading counter to its accumulated chapter value (16, 17), rendering "Appendix P", not "Appendix A", unless the level-1 counter is also reset per appendix | H | H | Phase 2 treats the counter reset as a required part of the change, verifies the rendered letters in the PDF and the TOC, and carries a documented fallback (literal "Appendix A:"/"Appendix B:" title text with `numbering: none` plus a title-rendering `#show ref` branch) if the counter mechanics regress the existing `A.n` section numbering |
| The rewritten document-wide `#show ref` rule regresses ordinary chapter references, which must keep rendering "Chapter N" | H | L | The rule reads `el.supplement`/`el.numbering` dynamically instead of branching on file or level, so chapters are unaffected by construction; Phase 2 verifies by grepping the full `pdftotext` output for every chapter reference, not just the two appendix ones |
| Lean docstring edits change `FormalSystem/` line counts, which `typst-sync-check.sh` Check 2 polices against `typst/generated/status.typ` | M | H | Phase 3 ends by re-running `scripts/typst-status-counts.sh` and committing the regenerated `typst/generated/status.typ` in the same phase; the final gate re-confirms Check 2 |
| A corrected Lean docstring crosses out of the comment into a declaration | H | L | `prose`-class edits only, verified by reading the staged diff hunk-by-hunk plus a green `lake build --wfail` before the phase closes |
| No installed font is a metric match for the missing "New Computer Modern Sans" | L | M | Phase 7 enumerates `typst fonts`, picks an available family (Noto Sans unless a closer match exists), confirms zero warnings, and records the choice in the summary so it is easy to revisit |
| New prose introduces a backtick span that fails Check 1 | M | M | Every prose-editing phase re-runs `typst-sync-check.sh` before closing, not only the final gate |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4, 5, 7 | 1, 3 |
| 3 | 6 | 2 |
| 4 | 8 | 2, 4, 5, 6, 7 |
| 5 | 9 | 1, 2, 3, 4, 5, 6, 7, 8 |

Phases within the same wave can execute in parallel. Wave 2's Phase 4 additionally requires
Phase 3; Phases 2, 5 and 7 require only Phase 1.

### Phase 1: Re-verify baseline and clear the sync-check blocker [COMPLETED]

**Goal**: Establish the live baseline for every item and make `scripts/typst-sync-check.sh` PASS,
so later phases' verification runs are meaningful; complete item 2's whitelist half.

**Tasks**:
- [x] Record the baseline: `git status --porcelain` and `git diff -- typst/chapters/ax-lean-appendix.typ`,
      `bash scripts/typst-sync-check.sh`, and `typst compile --root .. BimodalReference.typ` from
      `typst/` (capture the warning text verbatim). *(completed: compile clean with the two
      expected thmbox font warnings; ax-lean-appendix.typ diff confirmed static (mtime predates
      this dispatch), not live foreign work)*
- [x] Produce a `pdftotext -layout` render and record the baseline match count for
      `grep -E "Chapter 1[0-9]{3,}"` (currently 2). *(completed: confirmed 2, both "Chapter 1534"
      in 00-introduction.typ)*
- [x] If the 5 Check-1 violations still reproduce, add a new category to
      `typst/sync-check-whitelist.txt` covering exactly those spans, following the existing
      "Lean appendix: generic Lean tooling illustrations" category's comment style: illustrative
      Lean syntax appearing in editorial comments, not declaration citations. If they no longer
      reproduce, add nothing and record the closure. *(completed: the diff had grown since
      research/plan time — 9 Check-1 violations reproduced, not 5, all from the same class of
      uncommitted `// TODO:` review comments; whitelisted all 9 current spans under a new
      category, per the plan's own risk mitigation for exactly this growth scenario)*
- [x] Item 2 (whitelist half): remove the `specs/`-path citation from the "Lean appendix:
      appendix-local didactic identifiers" category comment, reusing the phrasing SYNC-MAP.md's
      most recent entry already models (a session scratch artifact, deliberately not named by
      path) rather than inventing new wording. *(completed)*
- [x] Re-confirm `leanprover/lean4` has zero occurrences in `typst/chapters/`, then prune that one
      whitelist entry. Leave every other entry in the category in place — all were confirmed still
      in use. *(completed: confirmed zero occurrences in typst/chapters/, pruned)*
- [x] Re-run `bash scripts/typst-sync-check.sh` and confirm PASS (Checks 1, 2, 2b, 3 all clean).
      *(completed: PASS, 0 violations, 827 candidates)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 5 Check-1 violations from 2 uncommitted TODO comments; exactly 1 prunable
whitelist entry (`leanprover/lean4`); every other entry in that category still used. Confirm by
re-running the sync check and by `grep -rn` for each candidate span across `typst/chapters/`
before pruning — never prune on the report's word alone.

**Files to modify**:
- `typst/sync-check-whitelist.txt` — new illustrative-syntax category; task-path citation removed;
  one unused entry pruned.

**Verification**:
- `bash scripts/typst-sync-check.sh` exits PASS.
- `grep -rn "specs/" typst/sync-check-whitelist.txt` returns nothing.

---

### Phase 2: Appendix numbering and the reference show-rule [COMPLETED]

**Goal**: Item 1. No reference renders a run-together heading counter; both appendices carry a
consistent "Appendix A"/"Appendix B" identity in prose references and the table of contents.

**Tasks**:
- [x] Rewrite the `#show ref` rule in `typst/BimodalReference.typ` to read the heading's own
      `el.supplement` and `el.numbering` instead of hardcoding `"Chapter"` and `numbering("1", …)`,
      with an explicit `el.numbering == none` branch that falls back to the default rendering
      rather than printing the raw counter. *(completed: renders `link(it.target)[#el.body]` for
      the none case, and `#el.supplement~#numbering(el.numbering, ..counter(heading).at(...))`
      otherwise)*
- [x] Give the Lean appendix's title heading a real appendix identity: supplement `Appendix`,
      letter numbering, and the level-1 counter reset needed for it to render `A` rather than the
      accumulated chapter count. Confine the edit to the title heading and the adjacent
      appendix-local numbering block already present in that file; change nothing else there.
      *(completed: `counter(heading).update(0)` + a `#show heading.where(level:1): set
      heading(supplement: "Appendix")` override + letter-numbering function)*
- [x] Apply the same treatment to `typst/chapters/ax-machine-appendix.typ`'s title heading so it
      renders `B`, and give its three unnumbered level-2 headings `B.n` numbering using the same
      file-local pattern the Lean appendix established. *(completed: no explicit counter reset
      needed there -- the auto-increment from the Lean appendix's letter A carries it to B)*
- [x] Confirm the Lean appendix's existing `A.n` section numbering still renders `A.1 …` unchanged
      after the counter reset. *(completed: A.1 through A.14 render correctly in the TOC)*
- [x] Update the one stale appendix-title link text in `typst/chapters/p4-dataset-pipeline.typ` to
      match the new machine-appendix title. Leave the Lean appendix's own `#link` to the machine
      appendix alone — its text names no title. *(completed)*
- [x] Recompile, re-render with `pdftotext -layout`, and check the table-of-contents entries for
      both appendices. *(completed: TOC shows "A Reading the Lean Formalization" and "B The
      Machine-Readable Axiomatization" with A.1-A.14 / B.1-B.3 subsections)*
- [ ] If the letter numbering cannot be made to render cleanly without regressing the `A.n`
      sections or the TOC, fall back to literal `Appendix A: …` / `Appendix B: …` title text with
      `numbering: none` and a `#show ref` branch that renders an unnumbered level-1 heading by its
      title; record which route was taken and why. *(not needed: the letter-numbering route
      rendered cleanly, verified first in an isolated scratch reproduction before editing the real
      files -- see phase-2-progress.json's approaches_tried)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: 2 broken references, both `@lean-appendix` in `00-introduction.typ`; exactly
1 stale appendix-title link text repo-wide. Confirm at implementation time by
`grep -rn "@lean-appendix\|@machine-appendix\|link(<.*-appendix>)" typst/` before editing and by
the post-change `pdftotext` grep.

**Files to modify**:
- `typst/BimodalReference.typ` — the `#show ref` rule.
- `typst/chapters/ax-lean-appendix.typ` — title heading and adjacent numbering block only.
- `typst/chapters/ax-machine-appendix.typ` — title heading, level-2 numbering.
- `typst/chapters/p4-dataset-pipeline.typ` — appendix-title link text.

**Verification**:
- `pdftotext` output has zero matches for `Chapter 1` followed by three or more digits.
- Both `@lean-appendix` references read as an appendix reference, and every ordinary chapter
  reference still reads "Chapter N" — verified by grepping all "Chapter " occurrences in the
  render, not just the two former offenders.
- TOC shows both appendices with their letters.
- `bash scripts/typst-sync-check.sh` still PASSes.

---

### Phase 3: Lean docstring corrections [COMPLETED]

**Goal**: Items 3, 5 and 6 on the Lean side. Three docstrings state machine-verified figures and
the real reason the search runs in `TacticM`, and describe what the tactic macros actually do.

**Tasks**:
- [x] Re-count from live source before editing: constructors of the `Axiom` inductive in
      `FormalSystem/ProofSystem/Axioms.lean`, and entries of `axiomCtors` in
      `FormalSystem/Automation/Tactics/Search.lean`. Confirm the omitted set by set difference.
      *(completed: 29 constructors, 27 axiomCtors entries, omitted set {prior_U_gap, sep} --
      matches the plan's stated figures exactly)*
- [x] `Search.lean` search docstring: replace the stale "42 of the tree's 45" with the same
      "27 of the 29" framing `Commands.lean`'s `modal_search` docstring already uses, naming only
      the two Layer-9 Reynolds Dedekind axioms. *(completed)*
- [x] `Search.lean` module docstring: remove the false `Axiom`-is-`Prop`-valued claim. State the
      single true fact — `DerivationTree` is `Type`-valued, so Aesop-style proof reconstruction
      (which targets `Prop`-valued goals) does not apply, which is why the search is hand-written
      at the meta level — grounding the wording in the existing explanation in
      `Boneyard/RetiredTactics/README.md` rather than inventing a new rationale. *(completed; also
      corrected the same claim in tryAxiomMatch's own doc comment in the same file, and in
      FormalSystem/Automation/Tactics/README.md's auto-regenerated module inventory description,
      both of which repeat the identical misconception)*
- [x] `Commands.lean`: correct the "Axiom Prop vs Type issue" phrase in the `modal_search`
      docstring the same way. Leave its already-correct "27 of the 29" sentence untouched.
      *(completed)*
- [x] `FormalSystem/Automation/Tactics/UserTactics.lean`: rewrite the `apply_axiom` docstring to
      describe the real behavior — apply the generic axiom constructor, leave the `h` and `h_fc`
      side goals open for the caller — and delete the stale "Supported Axioms" list, whose names
      are not current `Axiom` constructors. *(completed)*
- [x] Rewrite `modal_t`'s docstring the same way, since its body is byte-identical to
      `apply_axiom`'s, and replace its broken worked example. *(completed)*
- [x] Verify the replacement example by elaborating it with `lake env lean` in a scratch file
      outside `FormalSystem/` and `Tests/`; do not commit the scratch file. Confirm both the
      previously-broken example fails and the replacement elaborates cleanly. *(completed: both
      original examples confirmed broken, both replacements confirmed clean, scratch files never
      committed)*
- [x] Confirm the diff touches only doc comments: read every hunk, and confirm no declaration,
      statement or proof line changed. *(completed)*
- [x] `lake build --wfail` green. *(completed: 707 jobs, zero warnings, scoped to the three
      touched modules)*
- [x] Re-run `scripts/typst-status-counts.sh` and commit the regenerated `typst/generated/status.typ`
      — these docstring edits move `FormalSystem/` line counts, which `typst-sync-check.sh` Check 2
      polices. *(completed; also regenerated automation-module-map.typ for Check 2b, which these
      same edits moved)*
- [x] Re-run `bash scripts/typst-sync-check.sh` and confirm Check 2 is clean again. *(completed:
      full PASS on all checks)*

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 29 axiom constructors, 27 `axiomCtors` entries, omitted set exactly
`{prior_U_gap, sep}`; three Lean files touched. Confirm by re-counting from source at
implementation time, not by trusting these figures.

**Files to modify**:
- `FormalSystem/Automation/Tactics/Search.lean` — module docstring and search docstring.
- `FormalSystem/Automation/Tactics/Commands.lean` — `modal_search` docstring phrase.
- `FormalSystem/Automation/Tactics/UserTactics.lean` — `apply_axiom` and `modal_t` docstrings.
- `typst/generated/status.typ` — regenerated line counts.

**Verification**:
- `lake build --wfail` exits 0.
- `git diff` on the three Lean files shows changes inside doc-comment blocks only.
- The replacement docstring example elaborates cleanly under `lake env lean`.
- `bash scripts/typst-sync-check.sh` Check 2 reports zero mismatches.

---

### Phase 4: Proof-automation chapter accuracy [NOT STARTED]

**Goal**: Items 3, 5 and 6 on the chapter side. The automation chapter agrees with the corrected
docstrings and with live source.

**Tasks**:
- [ ] Add the generated-status import to `typst/chapters/p4-proof-automation.typ` and use the
      generated axiom count in place of the typed totals, per the dispatch's "prefer the generated
      axiom-count" instruction. Keep `tryAxiomMatch`'s own list length as a typed numeral and note
      in the summary that it has no generator.
- [ ] Correct the coverage claim to the machine-verified figures, naming exactly the two omitted
      axioms. Remove the nonexistent third name.
- [ ] Correct both occurrences of the `Axiom`-is-`Prop`-valued claim (prose and module-map table)
      to the same true statement Phase 3 wrote into the docstrings.
- [ ] Correct the `apply_axiom` item: it does not unify with a schema or infer formula parameters;
      it applies the constructor and leaves the side goals open.
- [ ] Leave the chapter's `modal_t` item exactly as it stands — it is already correct.
- [ ] Recompile and inspect the rendered Tactics and module-map pages.

**Timing**: 1 hour

**Depends on**: 1, 3

**Verification Tier**: local

**Scope Hypothesis**: two `Prop`-valued occurrences in this file, one coverage claim, one
`apply_axiom` item. Confirm by `grep -n "Prop-valued\|axiom schemata\|apply_axiom"` over the file
before editing.

**Files to modify**:
- `typst/chapters/p4-proof-automation.typ`

**Verification**:
- `grep -n "Prop-valued\|prior_S_gap\|45 axiom" typst/chapters/p4-proof-automation.typ` returns
  nothing.
- The chapter's figures match the corrected docstrings word for word on the omitted set.
- `typst compile` clean; `bash scripts/typst-sync-check.sh` PASS.

---

### Phase 5: Decidability-in-practice chapter [NOT STARTED]

**Goal**: Item 4. `DecisionResult` is described with its four real constructors, and the chapter's
other decision-procedure claims are re-checked against source.

**Tasks**:
- [ ] Replace the three-way `valid`/`invalid`/`timeout` description in
      `typst/chapters/p2-decidability-practice.typ` with the four real constructors, saying what
      distinguishes the two non-verdict outcomes: fuel exhaustion means genuinely undecided;
      extraction failure means every tableau branch closed and the formula is valid but the proof
      term was not recoverable.
- [ ] Fix the later sentence that attributes an exhausted budget to a `timeout` outcome.
- [ ] Leave the chapter's separate, correct citation of the certificate-outcome type — which does
      have a `timeout` constructor — untouched.
- [ ] Re-check the chapter's descriptions of the decision entry point, the validity and
      satisfiability predicates, and the proof/countermodel accessors against
      `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`; research found these correct,
      so confirm and record rather than edit unless a discrepancy appears.
- [ ] Recompile and inspect the rendered pages.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: two prose sites asserting a `timeout` outcome for the decision result; the
other four described declarations already correct. Confirm by `grep -n "timeout"` over the chapter
and by reading the live declarations.

**Files to modify**:
- `typst/chapters/p2-decidability-practice.typ`

**Verification**:
- Every surviving `timeout` occurrence in the chapter refers to the certificate-outcome type, not
  the decision result.
- All four constructor names appear and match source spelling exactly.
- `typst compile` clean; `bash scripts/typst-sync-check.sh` PASS (the constructor names are
  backticked spans and must resolve under Check 1).

---

### Phase 6: Introduction structure list and machine-appendix metavariables [NOT STARTED]

**Goal**: Items 7 and 8. The introduction's project-structure list covers the real tree and
attributes the tooling correctly; the machine appendix's illustrative table follows the book's own
guard/event letter convention.

**Tasks**:
- [ ] Extend the project-structure list in `typst/chapters/00-introduction.typ` to cover the
      directories and top-level module it omits, matching the Lean appendix's directory tour for
      coverage and staying in the introduction's brief register.
- [ ] Correct the tooling attribution: the dataset, ML and benchmark modules live in the separate
      tools library declared in `lakefile.toml`, not under the automation or examples directories.
      Do **not** copy the appendix's directory-tour sentence, which makes the same mistake; use the
      appendix's own correct statement elsewhere in that file as the model.
- [ ] In `typst/chapters/ax-machine-appendix.typ`, swap the two placeholder letters in the
      JSON-shape table so the guard is the book's guard letter and the event is the book's event
      letter, matching the syntax chapter's stated convention.
- [ ] Leave the explanatory paragraph below the table and the `CONFIRM(lean)` comment unchanged —
      both are accurate as they stand.
- [ ] Recompile and inspect the rendered introduction and machine-appendix pages.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: seven directory entries plus one top-level module missing from the
introduction list; two table rows to swap. Confirm the directory set against a live `ls` of the
library root rather than against the report's list.

**Files to modify**:
- `typst/chapters/00-introduction.typ`
- `typst/chapters/ax-machine-appendix.typ`

**Verification**:
- Every directory present in the library root appears in the introduction list or is deliberately
  and explicitly excluded.
- The introduction no longer attributes the dataset pipeline to the automation or examples
  directories.
- `typst compile` clean; `bash scripts/typst-sync-check.sh` PASS.

---

### Phase 7: Template hygiene [NOT STARTED]

**Goal**: Item 9(a) and 9(b). Wrapped item lines hang correctly, and the build emits zero warnings.

**Tasks**:
- [ ] Give the item environment in `typst/template.typ` a hanging indent — either by adding the
      indent and hanging-indent treatment directly, or (simpler) by routing it through a native
      list item so it inherits the surrounding environment's list styling. No call-site changes
      should be needed.
- [ ] Enumerate available fonts with `typst fonts`, choose an available sans family, and set it on
      the theorem-box title and sans font parameters in every environment style dictionary in
      `template.typ`, including the directly re-exported proof environment which currently has no
      `.with(…)` at all.
- [ ] Recompile and confirm the compile emits zero warnings.
- [ ] Render and inspect a page containing wrapped item text (the Tactics subsection of the
      automation chapter is the known case) and confirm the hanging indent; spot-check the other
      item call sites across the chapters for regressions.
- [ ] Record the chosen font family in the implementation summary.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: 12 item call sites across the chapters, all fixed by the definition change
with no call-site edits; 2 font warnings from 2 thmbox parameters. Confirm the call-site count by
`grep -rn "#item\[" typst/chapters/` and the warning count from the compile output before and
after.

**Files to modify**:
- `typst/template.typ`

**Verification**:
- `typst compile --root .. BimodalReference.typ` produces zero errors and zero warnings.
- Wrapped item lines are indented to the body, not to the margin, in the rendered PDF.

---

### Phase 8: Bring the sync records in line [NOT STARTED]

**Goal**: Item 2's narrative half. `typst/SYNC-MAP.md` describes the appendix as it now stands and
records this round's changes.

**Tasks**:
- [ ] Read the two most recent dated entries in `typst/SYNC-MAP.md` before writing, to confirm what
      the existing supersession note already covers and avoid restating it.
- [ ] Fold a short addition into the existing most-recent entry covering the appendix's section
      numbering mechanism, which is currently undocumented there; do not open a new dated entry for
      already-landed work.
- [ ] Add one new dated entry for this round's changes: the reference show-rule and appendix
      lettering, the corrected axiom-count/`Type`-valued/tactic-behavior statements in the chapters
      and docstrings, the decision-result correction, the introduction's structure list, the
      machine-appendix letter swap, and the template and whitelist changes.
- [ ] Confirm no task number and no `specs/` path appears anywhere in the additions, and that every
      backticked span in the new text resolves under Check 1.

**Timing**: 0.5 hours

**Depends on**: 2, 4, 5, 6, 7

**Verification Tier**: prose

**Files to modify**:
- `typst/SYNC-MAP.md`

**Verification**:
- `bash scripts/typst-sync-check.sh` PASS with the new prose in place.
- `grep -n "specs/\|task [0-9]" typst/SYNC-MAP.md` shows no new occurrence introduced by this
  round.

---

### Phase 9: Full acceptance gate and disposition summary [NOT STARTED]

**Goal**: Every acceptance criterion in the dispatch is demonstrated, with each of the nine items
recorded as fixed, closed as not reproducing, or deferred with a reason.

**Tasks**:
- [ ] `typst compile --root .. BimodalReference.typ` — zero errors, zero warnings.
- [ ] `bash scripts/typst-sync-check.sh` — PASS on all checks.
- [ ] `lake build --wfail` — green.
- [ ] `pdftotext -layout` render; confirm zero matches for `Chapter 1` followed by three or more
      digits, and read every reference to either appendix.
- [ ] Inspect the rendered pages of every chapter touched: introduction, decidability in practice,
      proof automation, dataset pipeline, and both appendices.
- [ ] Write the implementation summary with the item-by-item disposition, including the
      not-reproducing closure for the bare machine-appendix reference sub-claim, the route taken
      for the appendix lettering, the chosen sans font family, and the residual manual-maintenance
      risk of the ungenerated `tryAxiomMatch` list length.
- [ ] Confirm no deliverable outside `specs/` carries a task number or a `specs/` path.

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4, 5, 6, 7, 8

**Verification Tier**: full

**Files to modify**:
- `specs/648_fix_reference_book_defects_found_in_appendix_review/summaries/01_fix-reference-book-defects-summary.md`

**Verification**:
- All four mechanical gates green, output recorded verbatim in the summary.
- Nine items each accounted for with a disposition.

## Testing & Validation

- [ ] `typst compile --root .. BimodalReference.typ` from `typst/`: zero errors and zero warnings.
- [ ] `bash scripts/typst-sync-check.sh`: PASS (Checks 1, 2, 2b, 3).
- [ ] `lake build --wfail`: exit 0.
- [ ] `pdftotext -layout` of the compiled PDF: zero matches for `Chapter 1` followed by three or
      more digits; every appendix reference reads correctly; every chapter reference still reads
      "Chapter N".
- [ ] Rendered-page inspection of all six touched chapter/appendix files.
- [ ] Lean diff confined to doc comments — no statement or proof line changed.
- [ ] No task number and no `specs/` path in any file outside `specs/`.

## Artifacts & Outputs

- `specs/648_fix_reference_book_defects_found_in_appendix_review/plans/01_fix-reference-book-defects.md`
  (this file)
- `specs/648_fix_reference_book_defects_found_in_appendix_review/summaries/01_fix-reference-book-defects-summary.md`
- Modified: `typst/BimodalReference.typ`, `typst/template.typ`, `typst/SYNC-MAP.md`,
  `typst/sync-check-whitelist.txt`, `typst/generated/status.typ`, and the chapter files
  `00-introduction.typ`, `p2-decidability-practice.typ`, `p4-proof-automation.typ`,
  `p4-dataset-pipeline.typ`, `ax-machine-appendix.typ`, plus the title/numbering block of
  `ax-lean-appendix.typ`
- Modified: `FormalSystem/Automation/Tactics/{Search,Commands,UserTactics}.lean` (doc comments only)

## Rollback/Contingency

- Each phase commits on its own green verification, so the unit of rollback is one phase's commit
  and the working tree never carries more than one phase's unverified work.
- Before the two phases with document-wide render effects (Phase 2's show-rule rewrite and
  Phase 7's template change), take a durable, non-reverting checkpoint with
  `bash .claude/scripts/git-snapshot.sh 648 --no-revert`. This is a checkpoint, not a rollback:
  it does not touch the working tree.
- If a genuine rollback of uncommitted work becomes necessary, follow the rollback rung in
  `.claude/context/contracts/recovery.md` for the exact snapshot-then-revert invocation shape,
  including its out-of-scope override flag.
- Item-level contingency: Phases 2 and 7 both carry documented fallbacks (title-literal appendix
  naming; a different sans family). If Phase 2's fallback also fails to produce clean references,
  the minimum acceptable outcome is the `el.numbering == none` guard alone, which clears the
  acceptance grep without any appendix renaming — record it as a partial disposition for item 1
  rather than leaving the rule unfixed.
