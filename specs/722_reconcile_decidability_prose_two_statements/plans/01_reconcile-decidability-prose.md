# Implementation Plan: Task #722

- **Task**: 722 - Reconcile the programme-level decidability prose with the two-statement distinction (tableau biconditional open; Decidable (ValidZTime phi) proved)
- **Status**: [IMPLEMENTING]
- **Effort**: 4.75 hours
- **Dependencies**: None (must not share an `/orchestrate` cycle with tasks 177 or 543 — colliding `README.md`/documentation `file_scope`)
- **Research Inputs**: `specs/722_reconcile_decidability_prose_two_statements/reports/01_reconcile-decidability-prose.md`
- **Artifacts**: plans/01_reconcile-decidability-prose.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Eight programme-level prose surfaces describe only the tableau decidability spine and therefore
state or imply that no decidability theorem in this tree is machine-checked. That has been false
since 2026-09-28, when `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`
landed. This plan re-verifies every cited declaration first, then makes each surface state the
two-statement distinction exactly once in its own register — statement (i) the OPEN tableau
biconditional, statement (ii) the PROVED `Decidable (ValidZTime φ)` with all four of its
qualifiers carried — and closes with an acceptance sweep. Done means: every listed surface
carries the distinction; no surface asserts that no decidability theorem is machine-checked; no
surface says "TM is decidable" unqualified; no complexity claim was added; and no Lean proof was
touched (the single Lean file in scope changes its module docstring only).

### Research Integration

The research report re-verified every claim the dispatch asserted and added two findings this
plan depends on:

- `lean_verify` on `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` returned
  `axioms ["propext","Classical.choice","Quot.sound"]`, `trust: "standard"`, no warnings, no
  non-standard axioms. It is a `def` (not an `instance`) at
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:147`, transported
  by `decidable_of_iff` through `validZTime_iff_noCertifiedCandidate` (same file, line 113).
- `FormalSystem.Semantics.validZTime_iff_validInt` (`FormalSystem/Semantics/IntTransfer.lean:338`)
  is a proved Lean identification of validity over every discrete duration carrier with validity
  over `ℤ` alone. This is the formal content of the typst paper's `Log(Discrete)` at the `#BL`
  register, and it is what licenses the typst correction to say *the Discrete factor is known
  decidable* rather than the weaker "a same-named Lean predicate is decidable".
- Confirmed absent repo-wide: any Lean `def`/`theorem` named `Log`, and any declaration of the
  shape `Log(all task frames) = Log(Discrete) ∩ Log(Dense)`. The "target, not a theorem" sentence
  is therefore safe to write.
- `docs/theorem-index.md`'s `### Decidability` section already carries the correct rows and is a
  **citation target, not a surface to edit**.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` already states the landed result
  correctly, is not one of the eight surfaces, and is left untouched (it is a cross-reference
  target).
- The colliding conditional `decidableValidZTime` / `decidableValidZTimeFamily` in
  `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` (lines 100, 126) take an `fmp`
  hypothesis refuted by `Probe476.fmp_false`. They must never be cited as a live decidability
  theorem.

The report's own per-surface recommendations (its `## Recommendations` items 1–8) are the
substance of Phases 2–6 below; its item 9 (re-verify before implementing) is Phase 1 and its
item 10 (post-edit literal-string sweep) is Phase 7.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was not supplied as a `roadmap_path` in this dispatch, so no roadmap-review or
roadmap-update phase is planned and this plan writes nothing to `ROADMAP.md`. Read-only
consultation confirms this work is `## Phase 8: The Decidability Record (High Priority)`'s first
item (the surfaces must state that the tableau biconditional is OPEN at all four frame classes
while `Decidable (ValidZTime φ)` is PROVED, and must never write "TM is decidable" unqualified),
and that `ROADMAP.md` lines 221–227 already describe the distinction correctly — a useful model
for the register each surface should adopt.

## Goals & Non-Goals

**Goals**:
- Re-verify, in this round, every declaration name and every quoted stale phrase before any edit.
- Make each of the eight named surfaces state the two-statement distinction once, in its own
  register, with all four qualifiers on statement (ii) and a pointer to
  `docs/theorem-index.md`'s Decidability section.
- Replace the three confirmed-false-or-stale pieces of text: `BiLasso/README.md`'s "no
  decidability theorem is machine-checked at present", `typst/FormalFoundations.typ`'s "No
  decidability theorem is machine-checked." plus its "neither factor logic is known decidable"
  remark, and ADR-007's stale exact row-count claim.
- Keep ADR-007's governing rule ("no surface may say decidability is fully proven") intact and add
  to it the sentence that the Z-time witness-family result is the one decidability theorem proved.
- Leave every independently accurate statement-(i) bullet undisturbed.

**Non-Goals**:
- No Lean proof, `def`, `theorem`, `instance`, or `import` is changed anywhere. The one Lean file
  in scope (`FormalSystem/Metalogic/Decidability.lean`) changes its module docstring comment text
  only.
- `FormalSystem/Metalogic/Decidability/Correctness.lean` is not edited at all, and its "Retired as
  vacuous" section is not re-narrated on any surface that does not already cite it.
- `docs/theorem-index.md` is not edited (already correct; it is the citation target).
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` is not edited (already correct).
- No complexity claim is landed anywhere, in any register.
- No ninth surface is invented; the eight named in the dispatch are the whole scope, except that
  Phase 7's sweep may surface a genuinely stale ninth instance, which is reported rather than
  silently expanded into.
- No mechanical doc-lint for this staleness class is built (the report's Context Extension
  Recommendation is noted for a future `meta` task, not executed here).

## The Verified Claim Kit

Phases 2–6 draw every factual sentence from this kit and add nothing to it. Phase 1 re-confirms
each line before any phase consumes it. This exists so eight surfaces cannot drift into eight
slightly different statements of the same fact.

**Statement (i) — OPEN, at all four frame classes.** The tableau biconditional
`isValid φ fc = true ↔ ⊨ φ`, and the `Decidable (⊨ φ)` instances that would follow from it, are
open. What is proved is the sound direction only: `sound_of_isValid`
(`FormalSystem/Metalogic/Decidability/Correctness.lean:107`) and its user-facing wrapper
`isValid_sound` (same file, line 118). The earlier `validity_decidable` and
`validity_has_decision_procedure` forms were retired **as vacuous** — they were vacuous instances
of `Classical.em`, not decidability results — and that reason is recorded in the same file's
"Retired as vacuous" section (lines 192–224). Any surface restating this reports the vacuity
reason, not a paraphrase such as "a decidability claim was removed".

**Statement (ii) — PROVED.** `Decidable (ValidZTime φ)` is machine-checked, as
`FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`
(`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:147`), by the
presentation-free witness-family certificate route, via `decidable_of_iff` through
`validZTime_iff_noCertifiedCandidate`. Its four qualifiers, every one of which must appear at
least once per surface:

1. `FrameClass.ZTime` only — it says nothing about the other three frame classes.
2. `φ : FormalSystem.Syntax.Formula`, which has **no stability operator** (`⊡` lives only in
   `PlusLanguage.Formula`), so it says nothing about TM⁺.
3. Premises are **empty** (`[]`).
4. The `Decidable` produced **computes** — it carries no `Classical.dec` in its data — but that is
   not choice-freedom and none is claimed; the declaration's axioms are
   `[propext, Classical.choice, Quot.sound]`. Cite
   `WitnessFamily/Compression/Assembly.lean`'s own "Axioms" section (lines 81–83) rather than
   rewording it.

It is a `def`, not a global `instance`, deliberately (a global instance would change instance
resolution repository-wide).

**Do not cite.** The conditional `decidableValidZTime` / `decidableValidZTimeFamily` in
`FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`, whose `fmp` hypothesis is refuted for
every candidate list by `Probe476.fmp_false`.

**Citation target.** `docs/theorem-index.md`'s `### Decidability` section — point at the section,
never re-enumerate or re-count its rows.

**Forbidden anywhere.** "TM is decidable" unqualified; any complexity claim; any assertion that
no decidability theorem is machine-checked; "decidability is fully proven".

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An additive edit accidentally weakens or drops an accurate statement-(i) bullet | H | M | Every edit in Phases 2–6 is additive except the three confirmed load-bearing rewrites, each named explicitly in its phase; Phase 7 re-reads every statement-(i) bullet against the Verified Claim Kit |
| The task that exists to correct unverified claims introduces a new one | H | M | Phase 1 re-verifies every declaration name, axiom set, and quoted phrase in this round and blocks all later phases; no phase may cite a name Phase 1 did not confirm |
| Eight surfaces drift into eight slightly different statements of the same fact | M | H | The Verified Claim Kit above is the single source for every factual sentence; phases quote from it rather than re-deriving |
| The typst edit imports a complexity claim from `Compression/Assembly.lean`'s docstring (which discusses complexity at length) | H | M | Phase 6 explicitly excludes that framing; Phase 7 greps the typst diff for complexity vocabulary (`NP`, `PSPACE`, `EXPTIME`, `complexity`, `exponential`, `polynomial`) |
| A line-number anchor from the research report has drifted | M | M | Every phase anchors on quoted content, re-located by `grep -n` at phase start; line numbers in this plan are provisional locators only. Already observed: the BiLasso sentence now spans lines 11–13 (report said 10–12) and the typst sentence sits at 774 with the remark at 776–782 |
| The `Decidability.lean` docstring edit breaks the `/-! -/` block and so the module's elaboration | M | L | Phase 5 declares the `local` tier and builds that single module before closing |
| A sibling task (177, 543, 726, 728) edits a shared surface concurrently | M | M | Re-read each file immediately before editing; stage only this task's own hunks with an explicit file list, never a directory or glob `git add`; stop and report any foreign commit or modification |
| The repository's pre-existing deploy staleness (`core filetypes formal lean typst`, flagged in the dispatch) is misread as a regression from this task | M | M | Phase 1 captures a baseline of the full gate set before any edit; Phase 7 compares against that baseline and must not hand-patch anything under `.claude/**` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6 | 1 |
| 3 | 7 | 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel. Phases 2–6 touch disjoint file sets, so the
wave is genuinely parallel; a sequential pass in numeric order is equally valid and is the
expected default for a single implementation agent.

---

### Phase 1: Re-verify the Citation Set and Capture the Gate Baseline [COMPLETED]

**Goal**: Confirm, in this round, every declaration name, axiom set, absence, and quoted stale
phrase the later phases rely on — and capture a pre-edit gate baseline so pre-existing failures
are not later attributed to this task. No file is edited in this phase.

**Tasks**:
- [x] Re-verify `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` by
  `mcp__lean-lsp__lean_verify` (fully-qualified name). Expect axioms
  `[propext, Classical.choice, Quot.sound]`, `trust: standard`, no non-standard axioms. If
  lean-lsp is degraded or unreachable, fall back to a compiled probe
  (`#check` + `#print axioms` under `import FormalSystem`) and announce the evidence tier.
- [x] Confirm the declaration is a `def` (not an `instance`) and sits inside `namespace
  Compression` in `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`;
  confirm `validZTime_iff_noCertifiedCandidate` is present and `sorry`-free.
- [x] Confirm `sound_of_isValid` and `isValid_sound` are present in
  `FormalSystem/Metalogic/Decidability/Correctness.lean`, and re-read its "Retired as vacuous"
  section to confirm the vacuity reason (vacuous instances of `Classical.em`) before any surface
  restates it.
- [x] Confirm `FormalSystem.Semantics.validZTime_iff_validInt` is present in
  `FormalSystem/Semantics/IntTransfer.lean` and `sorry`-free (load-bearing for Phase 6 only).
- [x] Re-confirm the absence of any Lean `Log` declaration and of any declaration stating
  `Log(all task frames) = Log(Discrete) ∩ Log(Dense)`:
  `grep -rnE '(def|theorem|lemma|abbrev) +Log\b' FormalSystem/` and a shape grep for the identity.
  Record `index: consulted` (or the degraded tier) for any `lean_local_search` used.
- [x] Confirm `docs/theorem-index.md`'s `### Decidability` section still carries the
  `Compression.decidableValidZTime` row, so the pointer every surface gains is live.
- [x] Re-locate each stale phrase by content, recording its current line number:
  `grep -n` for `sound direction only` (expect `FormalSystem/README.md`,
  `docs/project-info/known-limitations.md`), `machine-checked` in
  `FormalSystem/Metalogic/Decidability/BiLasso/README.md` and `typst/FormalFoundations.typ`, and
  `neither factor logic is known decidable` in `typst/FormalFoundations.typ`.
- [x] Capture the pre-edit gate baseline into the task directory (not into the repo tree):
  `lake build` result, `typst compile typst/FormalFoundations.typ` result,
  `bash .claude/scripts/check-task-references.sh` result, and
  `bash .claude/scripts/verify-deploy.sh` result. Record each as pass/fail with the failing items
  named. The dispatch already flags `core filetypes formal lean typst` as stale in the deployed
  `.claude/` tree; a `verify-deploy.sh` failure traceable to that staleness is pre-existing and
  out of scope — do **not** hand-patch anything under `.claude/**`.
- [x] Write the confirmed kit (names, axioms, current line anchors, baseline results) to
  `specs/722_reconcile_decidability_prose_two_statements/.verified-claims.md` for Phases 2–7 to
  read. If any expectation fails to re-verify, STOP: do not edit a surface, and report the
  divergence — the plan's factual basis has moved. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts that exactly eight surfaces need correction and that
exactly three pieces of text are false-or-stale rewrites (BiLasso README's "no decidability
theorem is machine-checked at present", typst's "No decidability theorem is machine-checked." plus
its "neither factor logic is known decidable" remark, and ADR-007's exact row-count claim), with
the remaining edits additive. Confirm by the repo-wide literal-string grep in this phase's task
list: if it returns a surface outside the eight, report it rather than silently expanding scope;
if it returns fewer than the three expected rewrites, re-read the file before concluding the
defect is gone.

**Files to modify**:
- `specs/722_reconcile_decidability_prose_two_statements/.verified-claims.md` - new scratch record
  of the re-verified kit and the gate baseline (task-directory artifact, not a repo surface)

**Verification**:
- `.verified-claims.md` exists and records, for each of the five declarations above, the probe used
  and its result, plus the evidence tier if lean-lsp was degraded.
- The two confirmed-absent items are recorded as absent with the exact grep that established it.
- Current line anchors for all five stale phrases are recorded.
- The four baseline gate results are recorded as pass/fail with failing items named.
- No file outside the task directory was modified (`git status --short` shows no repo-surface
  change from this phase).

---

### Phase 2: Repository and Library Entry Points [COMPLETED]

**Goal**: `README.md` and `FormalSystem/README.md` each state the two-statement distinction once,
additively, without disturbing their accurate statement-(i) material or their terse per-layer
table wording.

**Tasks**:
- [x] Re-read `README.md`'s `### Decidability` section immediately before editing (sibling tasks
  may have touched it).
- [x] In `README.md`, insert one new paragraph directly after the section's intro sentence (the
  one ending in the ADR-007 pointer) and before the `- **Landed.**` bullet, stating both halves of
  the distinction from the Verified Claim Kit, with all four qualifiers on statement (ii), citing
  `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` by fully-qualified name
  and pointing at `docs/theorem-index.md`'s Decidability section.
- [x] Leave `README.md`'s existing Landed/Open/Partial bullets unchanged — they describe statement
  (i) correctly and in detail.
- [x] Leave `README.md`'s "Open problems for TM⁺" bullet unchanged: it concerns `PlusFormula`
  (the `⊡`-bearing language), about which statement (ii) says nothing. Confirm by re-reading it
  that it does not need a qualifier.
- [x] Re-read `FormalSystem/README.md`'s Layer-2 table row and the "Decidability is not 'fully
  proven'..." paragraph immediately before editing.
- [x] Leave `FormalSystem/README.md`'s Layer-2 table cell (`decidability **sound direction
  only**`) unchanged — it is accurate about the tableau route it summarizes, and a one-line-per-
  layer table is not where qualifiers belong.
- [x] In `FormalSystem/README.md`, add one new paragraph directly after the existing
  "Decidability is not 'fully proven'..." paragraph, stating statement (ii) with all four
  qualifiers and the `docs/theorem-index.md` pointer.
- [x] Confirm neither new paragraph says "TM is decidable" unqualified, implies decidability is
  fully proven, or lands a complexity claim.
- [x] Stage and commit only these two files, by explicit file list.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `README.md` - one new paragraph in `### Decidability`, after the ADR-007 pointer sentence,
  before the Landed bullet
- `FormalSystem/README.md` - one new paragraph after the "Decidability is not 'fully proven'"
  paragraph; Layer-2 table row untouched

**Verification**:
- Diff read-through confirms every changed hunk is prose; nothing outside a markdown text region
  changed.
- Each file now contains `Compression.decidableValidZTime` (or its fully-qualified form), all four
  qualifiers, and a `docs/theorem-index.md` pointer, each at least once.
- `grep -c` confirms the distinction is stated once per file, not duplicated.
- The pre-existing statement-(i) bullets are byte-identical to their pre-edit text (verify by
  `git diff` showing only additions in those regions).
- Neither file contains an unqualified "TM is decidable" or any complexity vocabulary.

---

### Phase 3: Decidability Directory READMEs [COMPLETED]

**Goal**: `FormalSystem/Metalogic/Decidability/README.md` gains the missing statement-(ii)
overview bullet, and `FormalSystem/Metalogic/Decidability/BiLasso/README.md`'s outright false
sentence is replaced and its future-tense "remaining route" framing is corrected to past tense.

**Tasks**:
- [x] Re-read both files immediately before editing.
- [x] In `FormalSystem/Metalogic/Decidability/README.md`, add one new Overview bullet after the
  existing three, stating statement (ii) with all four qualifiers, cross-referencing
  `[WitnessFamily README](WitnessFamily/README.md)` (already correct, left unedited) and
  `docs/theorem-index.md`'s Decidability section.
- [x] Leave that file's three existing Overview bullets and its module table row for
  `WitnessFamily/` unchanged.
- [x] In `BiLasso/README.md`, replace the sentence "Its commented-out text is consistent with this
  tree: no decidability theorem is machine-checked at present." (currently spanning lines 11–13;
  re-locate by content) with text stating plainly that a decidability theorem **is** now
  machine-checked — by the presentation-free witness-family route, not by this directory's own
  `fmp`-conditional assembly — carrying statement (ii)'s qualifiers and pointing at
  `WitnessFamily/Compression/Assembly.lean` and `docs/theorem-index.md`.
- [x] Preserve the surrounding accurate framing in the same paragraph: that the paper's
  `cor:tm-decidability` is commented out and is cited as an unpublished remark, and that **this
  directory does not decide the logic**. Only the stale clause changes.
- [x] Update the sentence currently at line 34 ("So the remaining route to decidability is the
  presentation-free witness family (`../WitnessFamily/README.md`), not a finite presentation.")
  from future/pending tense to past tense — the route succeeded — keeping its contrast with the
  finite-presentation route, which is why this directory does not carry the result.
- [x] Leave the `Probe476.fmp_false` refutation paragraphs unchanged: they are accurate and
  unrelated to this correction.
- [x] Confirm no new text cites `BiLasso/Assembly.lean`'s conditional `decidableValidZTime` as a
  live decidability theorem.
- [x] Stage and commit only these two files, by explicit file list.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/README.md` - one new Overview bullet after the existing
  three
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - the false "no decidability theorem is
  machine-checked at present" clause replaced; the "remaining route" sentence re-tensed

**Verification**:
- `grep -n "no decidability theorem is machine-checked" FormalSystem/Metalogic/Decidability/BiLasso/README.md`
  returns nothing, including across a line wrap (check with
  `tr '\n' ' ' < file | grep -o "no decidability theorem is machine-checked"`).
- Both files contain `Compression.decidableValidZTime`, all four qualifiers, and a
  `docs/theorem-index.md` pointer.
- `BiLasso/README.md` still contains "This directory does not decide the logic" and its
  `Probe476.fmp_false` paragraphs unchanged (`git diff` shows no deletions there).
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` is unmodified.
- Diff read-through confirms markdown prose only.

---

### Phase 4: docs/ Surfaces — ADR-007 and Known Limitations [COMPLETED]

**Goal**: ADR-007 keeps its governing rule and gains the statement-(ii) bullet plus a de-staled
Consequences sentence; `known-limitations.md`'s Limitation 6 gains a scoping note that does not
narrow its correctly-open scope.

**Tasks**:
- [x] Re-read both files immediately before editing.
- [x] In `docs/architecture/ADR-007-Decidability-One-Directional.md`, add a new
  "**Landed, separately.**" bullet to the Decision section after the existing Open bullet, stating
  statement (ii) with all four qualifiers and noting it is the one decidability theorem proved in
  this tree to date, unrelated to the `isValid` biconditional above.
- [x] Keep the ADR's rule "no surface may say decidability is fully proven" verbatim, and add to
  it the sentence that the Z-time witness-family result is the one decidability theorem that **is**
  proven. The rule stays correct; it is extended, not weakened or replaced.
- [x] Replace the Consequences bullet's stale exact row claim ("`docs/theorem-index.md` carries the
  two landed decidability rows (`Decidability.decide`, `Decidability.sound_of_isValid`)...") with a
  pointer at `docs/theorem-index.md`'s Decidability section, preserving its still-true logical
  claim that no row exists for the open biconditional direction. Do **not** substitute a new exact
  count or row list — that is what went stale. *(deviation: altered — Phase 1 found a second,
  unnamed instance of the same stale exact-count framing in this same file, the Related section's
  link text "the two landed rows" (line 64); corrected both rather than leaving one stale
  instance beside the fixed one, since this is the same defect in the same already-in-scope
  file, not scope expansion)*
- [x] Leave the ADR's status/date header and its existing Landed/Open/Partial bullets for the
  tableau route unchanged.
- [x] In `docs/project-info/known-limitations.md`, add a short scoping note immediately after
  Limitation 6's "is open." sentence — not a new numbered limitation — stating that this
  limitation is scoped to the `isValid` biconditional only, that `Decidable (ValidZTime φ)` is
  separately proved with its four qualifiers, and that this does **not** narrow Limitation 6's
  scope. Point at `docs/theorem-index.md`.
- [x] Leave Limitation 6's title, table, `extractionFailed` caveat, and Impact/Workaround/
  Resolution subsections unchanged, and leave its "sound direction only" sentence intact — it is
  accurate about the tableau statement it describes.
- [x] Confirm neither edit says "decidability is fully proven", "TM is decidable" unqualified, or
  lands a complexity claim.
- [x] Stage and commit only these two files, by explicit file list.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `docs/architecture/ADR-007-Decidability-One-Directional.md` - new "Landed, separately." Decision
  bullet; governing rule extended with the one-proven-theorem sentence; Consequences row-count
  claim replaced by a section pointer
- `docs/project-info/known-limitations.md` - scoping note added to Limitation 6 after its "is
  open." sentence

**Verification**:
- ADR-007 still contains its rule that no surface may say decidability is fully proven, now
  followed by the Z-time sentence.
- ADR-007 contains no exact decidability row count or enumerated row-name list; it points at
  `docs/theorem-index.md`'s Decidability section instead.
- Both files contain `Compression.decidableValidZTime`, all four qualifiers, and a
  `docs/theorem-index.md` pointer.
- Limitation 6's title and its "sound direction only" sentence are unchanged (`git diff` shows
  additions only in that region).
- Diff read-through confirms markdown prose only.

---

### Phase 5: Decidability.lean Module Docstring [NOT STARTED]

**Goal**: The central `Decidability` aggregator docstring — what hover and `#check` show for the
whole directory — notes that a second, unrelated decidability theorem is proved outside this
file's own import graph. Comment text only; no import, `def`, or `theorem` changes.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Decidability.lean`'s module docstring and its import list
  immediately before editing.
- [ ] Add one new bullet to the "This directory's decision procedure" docstring list, placed after
  the existing "completeness direction ... open" bullet and before the "Proof extraction: Partial"
  bullet, stating statement (ii) with all four qualifiers, noting explicitly that the declaration
  lives outside this file's own import graph (this module imports `PlusWitnessFamily`, `BiLasso`,
  and `PlusSlicedCertificate`, not `WitnessFamily`), and pointing at
  `docs/theorem-index.md`'s Decidability section.
- [ ] Change nothing but comment text: confirm by `git diff` that no `import`, `def`, `theorem`,
  `instance`, `namespace`, or `open` line is touched, and that the edit stays inside the
  `/-! ... -/` block.
- [ ] Build the single module and confirm it still elaborates clean:
  `lake build FormalSystem.Metalogic.Decidability`.
- [ ] Stage and commit only this file.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability.lean` - one new bullet in the module docstring's "This
  directory's decision procedure" list; docstring comment text only

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability` succeeds with no new errors or warnings
  relative to Phase 1's baseline.
- `git diff -- FormalSystem/Metalogic/Decidability.lean` shows changes confined to the `/-! -/`
  docstring block; no `import`/`def`/`theorem`/`instance` line appears in the diff.
- The new bullet contains `Compression.decidableValidZTime`, all four qualifiers, the
  outside-the-import-graph note, and a `docs/theorem-index.md` pointer.
- Known blind spot for this tier, left to Phase 7: whole-library elaboration and the repository's
  other gates.

---

### Phase 6: typst/FormalFoundations.typ [NOT STARTED]

**Goal**: The paper's `== Decidability` section stops asserting that no decidability theorem is
machine-checked, and its reduction remark is corrected — the Discrete factor is known decidable,
the Dense factor is not, and the reduction identity itself remains a target with no Lean
declaration. No complexity claim enters either edit.

**Tasks**:
- [ ] Re-read lines ~750–790 of `typst/FormalFoundations.typ` immediately before editing and
  re-locate both target sentences by content.
- [ ] Replace "No decidability theorem is machine-checked." (currently line 774) with a sentence
  stating that a decidability theorem **is** machine-checked for the ℤ-time discrete case, by the
  witness-family certificate route, in this paper's own register (`#BL`, which carries no
  stability operator — so that qualifier is satisfied by the register rather than needing to be
  stated as a caveat here), with the `FrameClass.ZTime`-only, empty-premises, and
  computing-but-not-choice-free qualifiers carried and
  `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` named.
- [ ] Preserve the preceding sentences unchanged: the `ZZ`-discreteness failure argument, its
  footnote about class-specific carriers, and "a tableau procedure whose *soundness* is
  machine-checked".
- [ ] Rewrite the `#remark[...]` block (currently lines 776–782) so that: the reduction strategy
  and both identities stay as they are; "neither factor logic is known decidable" becomes — the
  Discrete factor **is** known decidable, citing `Compression.decidableValidZTime` and the
  `validZTime_iff_validInt` bridge (`FormalSystem/Semantics/IntTransfer.lean`) that identifies
  `Log(Discrete)` with `ValidZTime`; the Dense factor remains open; and the identity
  `Log(all task frames) = Log(Discrete) ∩ Log(Dense)` itself remains a **target, not a theorem** —
  no Lean declaration states it (confirmed absent in Phase 1) — so the reduction still supplies no
  decision procedure by itself even with one factor settled.
- [ ] Land no complexity claim: do not import `Compression/Assembly.lean`'s complexity framing
  into this prose in any form.
- [ ] Leave the secondary mention near lines 1064–1067 alone. It was checked and is not in
  violation (`fmp_completeness` still exists; it does not imply that no decidability theorem is
  machine-checked), and the primary `== Decidability` section is this file's "once".
- [ ] Add a pointer to `docs/theorem-index.md`'s Decidability rows in the register this paper uses
  for repository cross-references (match the file's existing convention for such pointers rather
  than inventing one).
- [ ] Compile: `typst compile typst/FormalFoundations.typ` must succeed.
- [ ] Run `bash .claude/scripts/typst-element-lint.sh --verbose typst/FormalFoundations.typ` and
  `bash .claude/scripts/chapter-quality-check.sh --verbose typst/FormalFoundations.typ`. Placement
  findings and BLOCKING findings must be resolved; item-count, density, and ADVISORY findings are
  advisory-only. Compare against Phase 1's baseline so pre-existing findings are not attributed
  here.
- [ ] Stage and commit only this file (plus no build output).

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `typst/FormalFoundations.typ` - the "No decidability theorem is machine-checked." sentence
  replaced; the `#remark` reduction block rewritten; lines ~1064–1067 untouched

**Verification**:
- `typst compile typst/FormalFoundations.typ` succeeds.
- `tr '\n' ' ' < typst/FormalFoundations.typ | grep -o "No decidability theorem is machine-checked"`
  returns nothing, and likewise for "neither factor logic is known decidable".
- The file contains `Compression.decidableValidZTime`, the `validZTime_iff_validInt` citation, the
  `FrameClass.ZTime`/empty-premises/computing-not-choice-free qualifiers, and a
  `docs/theorem-index.md` pointer.
- The remark states the Discrete factor is decidable, the Dense factor is open, and the identity
  is a target with no Lean declaration.
- `grep -niE "complexity|NP-|PSPACE|EXPTIME|exponential time|polynomial time"` over this phase's
  diff returns nothing.
- `typst-element-lint.sh` and `chapter-quality-check.sh` show no new placement or BLOCKING
  findings relative to Phase 1's baseline.
- Known blind spot for this tier, left to Phase 7: cross-surface consistency and the full gate
  set.

---

### Phase 7: Acceptance Sweep and Full Gate [NOT STARTED]

**Goal**: Mechanically confirm every acceptance criterion across all eight surfaces, confirm no
out-of-scope file changed, and run the complete gate set.

**Tasks**:
- [ ] Repo-wide literal-string sweep, excluding `specs/**` (where the task description legitimately
  quotes the stale phrasing as the problem statement and must **not** be "fixed"), and tolerant of
  line wraps: for each of `.md`, `.typ`, `.lean`, run the search over whitespace-normalized text
  for "no decidability theorem is machine-checked" and "neither factor logic is known decidable".
  Both must return nothing outside `specs/**`. If a ninth surface appears, report it rather than
  silently expanding scope.
- [ ] Sweep repo-wide for an unqualified "TM is decidable" (and near-variants such as "TM is
  decidable." / "decidability of TM is proved" / "decidability is fully proven") outside
  `specs/**`. Must return nothing.
- [ ] Sweep this task's whole diff for complexity vocabulary
  (`complexity`, `NP`, `PSPACE`, `EXPTIME`, `exponential`, `polynomial`). Must return nothing.
- [ ] For each of the eight surfaces, confirm by targeted grep that it contains (a)
  `Compression.decidableValidZTime` or its fully-qualified form, (b) all four qualifiers —
  `FrameClass.ZTime`, no-stability-operator/`Formula`, empty premises, computing-but-not-choice-
  free — and (c) a `docs/theorem-index.md` pointer. Record the eight-row result table in the
  implementation summary.
- [ ] Confirm the distinction is stated **once** per surface, not twice: read each surface's
  decidability region end to end rather than relying on a count alone.
- [ ] Confirm `docs/theorem-index.md`,
  `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`, and
  `FormalSystem/Metalogic/Decidability/Correctness.lean` are **unmodified**
  (`git diff --name-only` against the task's base commit must list exactly the eight surfaces and
  nothing else, plus `specs/**` task artifacts).
- [ ] Confirm no Lean proof changed: `git diff` restricted to `*.lean` shows only
  `FormalSystem/Metalogic/Decidability.lean`, and only inside its `/-! -/` docstring block.
- [ ] Run the complete gate set and compare every result to Phase 1's baseline:
  `lake build` (whole library), `typst compile typst/FormalFoundations.typ`,
  `bash .claude/scripts/check-task-references.sh`,
  `bash .claude/scripts/typst-element-lint.sh --verbose typst/FormalFoundations.typ`,
  `bash .claude/scripts/chapter-quality-check.sh --verbose typst/FormalFoundations.typ`, and
  `bash .claude/scripts/verify-deploy.sh`. Any failure must be either resolved or shown identical
  to the Phase 1 baseline (pre-existing). The dispatch's flagged deploy staleness is pre-existing;
  do not hand-patch anything under `.claude/**` to make a gate pass.
- [ ] Confirm `check-task-references.sh` passes: none of the eight surfaces (all outside
  `specs/**`) may cite a task number.
- [ ] Commit the sweep's evidence with the implementation summary.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4, 5, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the final diff touches exactly eight repository surfaces
plus `specs/**` artifacts, and that `lake build` and `typst compile` outcomes are unchanged from
Phase 1's baseline. Confirm by `git diff --name-only` against the task's base commit and by
diffing each gate's output against the recorded baseline; a surface outside the eight, or a gate
newly failing, is a scope or regression finding to report, not to absorb.

**Files to modify**:
- none planned — this phase verifies and commits evidence; it edits a surface only to fix a
  violation its own sweep finds, in which case the affected phase's verification is re-run

**Verification**:
- Both forbidden literal strings return nothing outside `specs/**`, line-wrap tolerant.
- No unqualified "TM is decidable" and no "decidability is fully proven" anywhere outside
  `specs/**`.
- No complexity vocabulary anywhere in this task's diff.
- The eight-row surface table shows declaration name, all four qualifiers, and the index pointer
  present for every surface.
- `git diff --name-only` lists exactly the eight surfaces plus `specs/**` artifacts;
  `docs/theorem-index.md`, `WitnessFamily/README.md`, and `Correctness.lean` are absent from it.
- The full gate set runs: `lake build`, `typst compile typst/FormalFoundations.typ`,
  `check-task-references.sh`, `typst-element-lint.sh`, `chapter-quality-check.sh`, and
  `verify-deploy.sh` — each passing, or each failure demonstrated byte-identical to the Phase 1
  baseline and so pre-existing.

---

## Testing & Validation

- [ ] Phase 1's re-verification reproduced the expected axiom set
  `[propext, Classical.choice, Quot.sound]` for
  `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`, with the evidence tier
  announced if lean-lsp was degraded.
- [ ] `lake build` succeeds for the whole library (the one Lean file touched changed comment text
  only).
- [ ] `typst compile typst/FormalFoundations.typ` succeeds.
- [ ] `bash .claude/scripts/typst-element-lint.sh --verbose typst/FormalFoundations.typ` shows no
  new placement findings.
- [ ] `bash .claude/scripts/chapter-quality-check.sh --verbose typst/FormalFoundations.typ` shows
  no new BLOCKING findings.
- [ ] `bash .claude/scripts/check-task-references.sh` passes (no task numbers in the eight
  deliverable surfaces).
- [ ] `bash .claude/scripts/verify-deploy.sh` is unchanged from the Phase 1 baseline.
- [ ] Acceptance greps: neither forbidden literal string survives outside `specs/**`; no
  unqualified "TM is decidable"; no complexity vocabulary in the diff.
- [ ] All eight surfaces carry the declaration name, all four qualifiers, and the
  `docs/theorem-index.md` pointer, once each.
- [ ] `git diff --name-only` confirms no out-of-scope file changed — in particular not
  `Correctness.lean`, `docs/theorem-index.md`, or `WitnessFamily/README.md`.

## Artifacts & Outputs

- `specs/722_reconcile_decidability_prose_two_statements/plans/01_reconcile-decidability-prose.md`
  (this plan)
- `specs/722_reconcile_decidability_prose_two_statements/.verified-claims.md` (Phase 1's
  re-verified kit and pre-edit gate baseline)
- `specs/722_reconcile_decidability_prose_two_statements/summaries/01_reconcile-decidability-prose-summary.md`
  (implementation summary, including Phase 7's eight-row acceptance table)
- Edited surfaces: `README.md`; `FormalSystem/README.md`;
  `FormalSystem/Metalogic/Decidability/README.md`;
  `FormalSystem/Metalogic/Decidability.lean` (docstring only);
  `FormalSystem/Metalogic/Decidability/BiLasso/README.md`;
  `docs/architecture/ADR-007-Decidability-One-Directional.md`;
  `docs/project-info/known-limitations.md`; `typst/FormalFoundations.typ`
- `specs/722_reconcile_decidability_prose_two_statements/.orchestrator-handoff.json` and
  `.return-meta.json`

## Rollback/Contingency

Every phase commits only its own files by explicit file list, so reverting is per-phase:
`git revert` the offending phase's commit, or `git checkout <base-sha> -- <the phase's files>` on a
clean tree. No Lean proof, build artifact, or state file is affected, so a revert restores the
prior prose exactly with no downstream consequence beyond the surfaces themselves.

If a rollback is needed while uncommitted work exists in the tree, take a durable snapshot first —
see `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation
shape, including its out-of-scope override flag for the deliberate whole-tree case. Do not emit a
bare reverting `git-snapshot.sh 722` as a routine start-of-phase precaution; for an ordinary
defensive checkpoint before a risky edit, use `bash .claude/scripts/git-snapshot.sh 722
--no-revert`, which is durable without reverting the working tree.

Contingency if Phase 1 fails to re-verify any claim: stop before editing any surface, leave the
task in `[PARTIAL]` or `[BLOCKED]` with the divergence named, and report it. The plan's entire
factual basis is Phase 1's kit; a surface must never be edited on a claim that did not re-verify
in this round — that would reproduce, in the opposite direction, exactly the defect this task
exists to correct.

Contingency if a sibling task (177, 543, 726, 728) is observed to have committed to or modified a
shared surface mid-run: stop, check `git log` to confirm the work is not this task's own, and
report rather than proceeding or dismissing it as noise.
