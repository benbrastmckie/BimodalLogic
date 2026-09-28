# Implementation Plan: Task #686

- **Task**: 686 - modelchecker_contract_handoffs
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/686_modelchecker_contract_handoffs/reports/01_modelchecker-contract-handoffs.md
- **Artifacts**: plans/01_modelchecker-contract-handoffs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Discharge the consuming repository's (`~/Projects/ModelChecker`) half of the certificate and
translation contracts this repository has landed. Research established that only two of the six
described items are actually open: the `\top` defect in `Sentence.update_types` (item 6) and the
translation conformance channel (item 5), with 6 a hard prerequisite for 5. Items 1, 2 and 4 are
already implemented and wired in ModelChecker and need a verification pass only; item 3's audit is
complete with a negative result. Done means: the `\top` branch keys off derived shape rather than
the original operator name, a new test module asserts ModelChecker's own translation of every
fixture row against `Tests/fixtures/sentence-translation-fixtures.jsonl` on parsed JSON, and the
existing `\top` workaround in the box test corpus is removed because the defect it routed around
is gone.

**All source edits in this plan land in `~/Projects/ModelChecker`, a separate git repository.**
Nothing in `FormalSystem/`, `BimodalTools/`, or `Tests/` in this repository is modified; the only
file this plan writes inside BimodalLogic is the implementation summary artifact.

### Research Integration

Findings carried directly into the phase structure:

- **Items 1/2/4 are already landed** (`_lean_check.py`'s `assert_echo_matches_sent`, called at
  three sites in `test_certificate_lean_agreement.py`; `canonical_wire_bytes`'s
  `ensure_ascii=False`; `.get("acceptance", "decided")` in two modules). Phase 1 verifies rather
  than reimplements them.
- **Item 3 has no target**: zero `.lean` files in ModelChecker, zero hits across every other
  checkout under `~/Projects/`. Recorded as a completed negative-result audit; no phase.
- **Item 6 is located precisely** at `code/src/model_checker/syntactic/sentence.py`'s
  `store_types`, whose extremal branch tests `self.name in {'\\top', '\\bot'}` — the *original*
  operator name — instead of the shape of `derived_type`.
- **Item 6 gates item 5**: fixture row 13 is `{"surface": "\\top", ...}`, so the fixture loop
  cannot pass on all 26 rows while the defect is open.
- **Comparison must be on parsed JSON, never bytes** — both repositories' READMEs say so
  independently, and the fixture confirms why: Lean prints `untl` with `event` before `guard`,
  ModelChecker's `to_json` emits the same two keys in the other order.

Verified beyond the research report during planning (each is load-bearing for a phase below):

- `TopOperator.derived_definition` returns `[NegationOperator, [BotOperator]]`, a **two**-element
  derived type (the report said three). The fix is unaffected: any `len(derived_type) > 1` shape
  belongs in the complex branch.
- In `theory_lib/logos/subtheories/extensional/operators.py`, `\top` and `\bot` are both
  **primitive** `syntactic.Operator`s, so their `derived_type` is genuinely one element. A
  shape-keyed check therefore preserves logos behavior exactly and changes only bimodal's defined
  `\top`. This bounds the blast radius of an edit to a core shared module.
- All 18 fixture sentence tags have a 1:1 ModelChecker operator counterpart (17 named operators
  plus the atom case), so no fixture row is unmappable.
- `resolve_bimodal_logic_path()` in `_lean_check.py` is already a public export and needs no
  subprocess, so the fixture-only assertion can resolve the checkout without paying for the
  `lake exe check_certificate` probe that `SKIP_REASON` performs.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap flag is set, so no roadmap phases
are included. (`specs/ROADMAP.md` exists in this repository but was not consulted and must not be
modified by this task.)

## Goals & Non-Goals

**Goals**:
- Fix the `\top` defect in `Sentence.update_types` so the extremal branch dispatches on the
  derived shape rather than the original operator name.
- Remove the `\top` exclusion from `test_formula.py`'s `_BOX_TEST_CORPUS`, proving the fix from
  the site that documented the defect.
- Add a translation conformance test asserting, for all 26 fixture rows, that ModelChecker's
  `update_types` + `translate` + `to_json` equals the fixture's `formula` field as parsed JSON.
- Add an optional, skippable differential leg against `lake exe translate_sentence`.
- Verify items 1, 2 and 4 still hold against the live `check_certificate` binary, and record
  item 3's negative result.

**Non-Goals**:
- Re-implementing items 1, 2 or 4. They are landed; touching them is out of scope.
- Searching further for an out-of-repo Lean consumer of `CheckResult.countermodel` (item 3).
- Un-routing `examples.py`'s `\neg \bot` hand-expansions. Research flagged this as optional
  cleanup; Phase 3 makes an explicit decision to leave it, recorded rather than silently skipped.
- Any inverse (formula-to-sentence) pass. `tr_not_injective` makes the channel forward-only.
- Any change under `FormalSystem/`, `BimodalTools/`, or `Tests/` in this repository.
- Any change to ModelChecker's own `specs/**` task-management files.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An implementer re-does items 1/2/4 at face value from the task description | M | M | Phase 1 is verification-only and explicitly forbids source edits to those three sites; the research report carries file:line and commit evidence checkable in under a minute |
| The `store_types` fix changes behavior in a non-bimodal theory | H | L | Planning confirmed logos' `\top`/`\bot` are primitive (one-element derived type) so the shape-keyed branch is behavior-identical there; Phase 2 runs the full test suite (tier `full`) rather than the bimodal subset to catch anything this reasoning missed |
| ModelChecker's working tree is dirty with concurrent, unrelated in-flight work (tasks 205/206 plan edits, `specs/TODO.md`, `specs/state.json`, `specs/events.jsonl`) | H | H | Stage only this plan's own named files, never a directory or glob pathspec; never `git add -A`; re-read each target immediately before editing; never run any destructive git command in that repository |
| Commit messages in ModelChecker using `task 686:` would falsely claim a ModelChecker task number (its own numbering is at 209) | M | H | Use a descriptive, non-task-numbered prefix in that repository (see Assumptions below) |
| The live `translate_sentence` differential leg costs 26 subprocess invocations per run | M | M | The fixture-only assertion is the primary, always-run leg; Phase 5's differential leg probes once and compares a single representative batch, mirroring `_lean_check.py`'s probe-once idiom rather than a per-row loop |
| The fixture read is skipped silently when the BimodalLogic checkout is absent, hiding a real disagreement | M | M | Phase 4 uses a distinct, named skip reason for checkout absence only, and asserts the row count (26) so a truncated or partially-read fixture fails loudly instead of passing vacuously |

### Assumptions (stated, not blocking)

- **Commit convention in the consuming repository**: ModelChecker uses `task {N}: {action}` with
  its own independent numbering. This plan's commits land there with a descriptive prefix that
  does not claim one of its task numbers — `bimodal-contract: {action}` — with the BimodalLogic
  task reference in the commit body. If the user prefers a ModelChecker-side task be opened for
  this work instead, that is a cheap change of convention only; it does not alter any phase.
- **Fixture source of truth**: the new test reads the fixture from the resolved BimodalLogic
  checkout rather than from a copy mirrored into ModelChecker. One source of truth cannot drift,
  and drift is exactly what this channel exists to detect; the cost is that the assertion skips
  (loudly named) when no checkout is present.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 4 |
| 5 | 6 | 3, 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Verify the already-landed items and establish a green baseline [NOT STARTED]

**Goal**: Confirm items 1, 2 and 4 still hold against the live `lake exe check_certificate`
binary, and establish that ModelChecker's test suite is green *before* any edit, so a later
failure is attributable.

**Tasks**:
- [ ] Confirm `~/Projects/ModelChecker` is on `master` and note the exact starting commit, so
      every later change is attributable and revertible.
- [ ] Run `cd ~/Projects/ModelChecker && PYTHONPATH=code/src python -m pytest code/src/model_checker/theory_lib/bimodal/tests/integration/test_certificate_lean_agreement.py -v`
      and confirm it **runs** (does not skip). A clean skip here means the checkout or `lake` is
      unavailable, which must be resolved or explicitly recorded before proceeding — a skip is
      not a pass.
- [ ] Confirm the echo comparison (item 1) is actually exercised: `assert_echo_matches_sent` is
      reached on the `countermodel` path and both `error`-path negative checks pass.
- [ ] Confirm `PROTOCOL_FAILURE` is `None` (`TestErrorPaths`) — a binary that answers wrongly must
      fail loudly, not skip.
- [ ] Confirm item 2 by reading `certificate.py`'s `canonical_wire_bytes` and verifying
      `ensure_ascii=False` is present on the single serializing `json.dumps`.
- [ ] Confirm item 4 by reading both `.get("acceptance", "decided")` sites
      (`test_certificate_lean_agreement.py`, `test_semantics_core.py`).
- [ ] Record item 3's negative result (no `.lean` files in ModelChecker; no importer of
      `BimodalTools.CertificateImport`/`CanonicalWire` anywhere under `~/Projects/`) in the
      progress record. No audit re-run is needed.
- [ ] Run the bimodal theory's full test suite once to capture the pre-edit baseline, and record
      any pre-existing failures so they are not later misread as regressions.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

Rationale: this phase makes no source edit, so it has no blast radius of its own. Its purpose is
to establish the baseline that Phase 2's `full` tier is measured against.

**Files to modify**: none (verification only)

**Verification**:
- `test_certificate_lean_agreement.py` runs and passes, with no skip.
- `ensure_ascii=False` confirmed present at the single wire-serialization site.
- Both `"acceptance"` default sites confirmed present.
- The pre-edit baseline (pass/fail counts, any pre-existing failures) is recorded.

---

### Phase 2: Fix the `\top` defect in `Sentence.update_types` [NOT STARTED]

**Goal**: Make `store_types`'s extremal-operator branch dispatch on the shape of `derived_type`
rather than on `self.name`, so a defined nullary operator whose expansion is complex falls through
to the complex branch it actually belongs in.

**Tasks**:
- [ ] Re-read `code/src/model_checker/syntactic/sentence.py`'s `store_types` immediately before
      editing (the tree is shared with concurrent work).
- [ ] Replace the `if self.name in {'\\top', '\\bot'}:` test with a shape-keyed test on
      `derived_type` (the natural form is `len(derived_type) == 1`, placed after the existing
      sentence-letter check so a one-element `Const` still takes the letter branch first).
- [ ] Update the branch's comment to say what the branch now means — a nullary/extremal *derived*
      shape — rather than naming `\top`/`\bot` by surface spelling.
- [ ] Confirm the resulting `ValueError` fallthrough at the end of `store_types` is still
      reachable only for genuinely invalid shapes, not made dead or newly reachable by the change.
- [ ] Add a focused unit test asserting `\top` now type-updates correctly: a `\top` sentence has a
      non-`None` `operator` **and** non-`None` `arguments`, and
      `to_json(translate(_sentence("\\top")))` equals
      `{"tag": "imp", "left": {"tag": "bot"}, "right": {"tag": "bot"}}`.
- [ ] Add a companion assertion that `\bot` is unchanged: its `arguments` remain `None` and it
      still translates to `{"tag": "bot"}`.
- [ ] Add an assertion that a *nested* `\top` (e.g. `\Box \top`, `(\top \wedge p)`) also
      type-updates and translates correctly, not just a bare one.
- [ ] Run the full ModelChecker test suite and compare against Phase 1's recorded baseline — in
      particular the logos, exclusion and imposition theory suites, which share this code path.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: full

Rationale: `syntactic/sentence.py` is a core module shared by every theory, and this edit changes
runtime dispatch behavior with no signature change — precisely the case the tie-break rule assigns
to `full`.

**Scope Hypothesis**: planning determined that only bimodal's `\top` changes behavior, because
logos' `\top`/`\bot` are primitive `syntactic.Operator`s whose `derived_type` is genuinely one
element, and exclusion/imposition define no extremal operator at all. **Confirm at implementation
time** by running every theory's test suite, not only bimodal's, and comparing against Phase 1's
baseline. If any non-bimodal test changes behavior, the hypothesis is wrong and the branch
condition needs revisiting before proceeding.

**Files to modify**:
- `code/src/model_checker/syntactic/sentence.py` — the `store_types` extremal-operator branch and
  its comment.
- `code/src/model_checker/theory_lib/bimodal/tests/unit/test_formula.py` (or a sibling unit
  module, implementer's choice) — the new `\top` type-update and translation assertions.

**Verification**:
- The new `\top` assertions pass; the `\bot` companion assertions are unchanged.
- The full test suite matches Phase 1's baseline with no new failures in any theory.
- A `\top` sentence no longer reaches `translate` with `arguments` set to `None`.

---

### Phase 3: Remove the `\top` workaround in the box test corpus [NOT STARTED]

**Goal**: Delete the exclusion that routed around the now-fixed defect, so the differential
exercise actually covers `\top` — the coverage the new agreement theorem requires.

**Tasks**:
- [ ] Re-read `code/src/model_checker/theory_lib/bimodal/tests/unit/test_formula.py` around
      `_BOX_TEST_CORPUS` immediately before editing.
- [ ] Replace `_BOX_TEST_CORPUS = [ast for ast in _GENERATED_CORPUS if ast[0] != "top"] + ...`
      with the unfiltered `_GENERATED_CORPUS + _BOX_PROPERTY_ASTS`.
- [ ] Delete the multi-line comment documenting the TopOperator bug and the reason for the
      exclusion, replacing it with a one-line note that the defect is fixed (cite
      `sentence.py`'s `store_types` by function name, not line number).
- [ ] Add `("top",)` and at least one nesting containing it (e.g. `("box", ("top",))`) to
      `_BOX_PROPERTY_ASTS`, so `\top` coverage is by construction rather than incidental to the
      seeded generator.
- [ ] Record the explicit decision to **leave** `examples.py`'s `\neg \bot` hand-expansions and
      their "avoid TopOperator bug" comments in place: they are correct as written and rewriting
      the theory's example corpus is a separate cleanup on its own merits, not a drive-by here.
      Note in the progress record that the comments are now stale prose, not live workarounds.
- [ ] Run `test_formula.py` in full.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

Rationale: a test-module-only edit with no externally visible signature change; the shared-code
risk was already discharged by Phase 2's `full` tier.

**Files to modify**:
- `code/src/model_checker/theory_lib/bimodal/tests/unit/test_formula.py` — `_BOX_TEST_CORPUS`,
  `_BOX_PROPERTY_ASTS`, and the exclusion comment.

**Verification**:
- `test_formula.py` passes in full with `\top` present in the differential corpus.
- No `ast[0] != "top"` filter remains anywhere in the module.

---

### Phase 4: Wire the translation conformance channel (fixture-only leg) [NOT STARTED]

**Goal**: Assert, for every fixture row, that ModelChecker's own operator elimination and
translation produce the same formula the Lean side's `tr` produces — compared as parsed JSON.

**Tasks**:
- [ ] Create a new test module beside the existing integration tests, e.g.
      `code/src/model_checker/theory_lib/bimodal/tests/integration/test_sentence_translation_agreement.py`.
- [ ] Resolve the fixture via `_lean_check.resolve_bimodal_logic_path()` and read
      `Tests/fixtures/sentence-translation-fixtures.jsonl`. Use a **distinct, named skip reason
      for checkout absence only** — do not reuse `SKIP_REASON`, which additionally requires `lake`
      and a `check_certificate` probe this leg does not need.
- [ ] Write a renderer from a fixture row's `sentence` AST (tags `atom`, `bot`, `neg`, `wedge`,
      `vee`, `box`, `allFut`, `allPast`, `untl`, `snce`, `cond`, `bicond`, `top`, `dia`,
      `someFut`, `somePast`, `next`, `prev`) to ModelChecker infix syntax. Drive the renderer from
      the structured `sentence` field, **not** the `surface` field, which is Polish/prefix
      notation that ModelChecker's `Syntax` does not parse.
- [ ] Map each tag to its ModelChecker operator surface name: `allFut`→`\Future`,
      `allPast`→`\Past`, `untl`→`\Until`, `snce`→`\Since`, `cond`→`\rightarrow`,
      `bicond`→`\leftrightarrow`, `dia`→`\Diamond`, `someFut`→`\future`, `somePast`→`\past`,
      `next`→`\next`, `prev`→`\prev`, and the remaining tags to their like-named operators.
- [ ] Fail loudly on any unknown tag rather than skipping the row — an unmapped tag means the
      fixture grew a constructor this channel does not cover, which is the thing to find out.
- [ ] For each row: build the sentence via the real `Syntax` pipeline (reusing `test_formula.py`'s
      `_sentence` idiom), call `translate`, call `to_json`, and assert **dict equality** against
      the row's `formula` field. Never compare serialized strings: the Lean side prints `untl`
      with `event` before `guard` and ModelChecker's `to_json` emits them the other way round.
- [ ] Assert the fixture row count is 26 and that every `kind` value
      (`primitive`, `defined`, `asymmetry`, `nesting`) is represented, so a truncated or
      partially-read fixture fails instead of passing vacuously.
- [ ] Add explicit, individually named assertions for the two operators the task description flags
      as wrong when written the obvious way: `\rightarrow p q` must equal the
      disjunction-of-a-negation shape `imp(imp(imp(p,bot),bot), q)` and **not** a bare
      `imp(p, q)`; `\future p` must equal the negated-universal shape and **not** a bare
      `untl`/`someFuture` primitive.
- [ ] Add a module docstring recording that the channel is **forward-only** — the Lean elimination
      is not injective (`tr_not_injective`), so no inverse pass is checkable — and that comparison
      is on parsed JSON by contract, not by convenience.
- [ ] Run the new module.

**Timing**: 1.75 hours

**Depends on**: 2

**Verification Tier**: local

Rationale: a single new test module; it adds no production code and changes no signature.

**Scope Hypothesis**: the fixture is asserted to have 26 rows and 18 distinct sentence tags, each
with a 1:1 ModelChecker operator counterpart. **Confirm at implementation time** by reading the
fixture rather than trusting this plan: the row-count assertion in the tasks above is the
mechanical form of that confirmation, and an unknown-tag failure is the mechanical form of the
1:1 claim's confirmation.

**Files to modify**:
- `code/src/model_checker/theory_lib/bimodal/tests/integration/test_sentence_translation_agreement.py`
  (new).

**Verification**:
- All 26 rows pass as dict equality against the fixture's `formula` field.
- The row-count and `kind`-coverage assertions pass.
- The two flagged-operator assertions pass in their non-obvious shapes.
- With `BIMODAL_LOGIC_PATH` pointed at a nonexistent directory, the module skips with the named
  checkout-absence reason rather than erroring.

---

### Phase 5: Optional live differential leg against `lake exe translate_sentence` [NOT STARTED]

**Goal**: Add a skippable check that the committed fixture still matches what the live binary
emits, so fixture staleness is detectable rather than assumed away.

**Tasks**:
- [ ] Add a probe-once helper resolving both the checkout and `lake`, mirroring `_lean_check.py`'s
      established idiom (one probe per session, `SKIP_REASON`-style named reasons for environment
      absence, loud failure for a binary that answers wrongly).
- [ ] Invoke `lake exe translate_sentence` on a small representative selection of fixture rows —
      at minimum one row per `kind`, plus the `\top` row and the two flagged-operator rows — and
      compare its parsed stdout to that row's `formula` field. Do **not** loop one subprocess per
      row over all 26.
- [ ] Keep the environment-absence vocabulary strictly separate from the protocol-disagreement
      vocabulary, exactly as `_lean_check.py` documents: a binary that answers with the wrong
      formula must fail, never skip.
- [ ] Run the module with the checkout present, and again with `BIMODAL_LOGIC_PATH` pointed at a
      nonexistent directory to confirm the skip path is clean.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `code/src/model_checker/theory_lib/bimodal/tests/integration/test_sentence_translation_agreement.py`
  (extend), or a sibling helper module if the probe logic grows large enough to warrant one.

**Verification**:
- With a working checkout and `lake`, the differential rows pass.
- With the checkout absent, the differential leg skips with a named reason while Phase 4's
  fixture-only leg is unaffected.
- A deliberately corrupted expected value makes the leg fail, not skip (sanity check that the
  assertion is live).

---

### Phase 6: Documentation, pin refresh, and final gate [NOT STARTED]

**Goal**: Leave the consuming repository's documentation truthful about what is now checked from
both ends, refresh the pinned upstream commit, and close the task.

**Tasks**:
- [ ] Update `BIMODAL_LOGIC_COMMIT` in `_lean_check.py` from `d55e2760e...` to the BimodalLogic
      commit that actually landed the translation channel (resolve it from
      `git log --oneline -- FormalSystem/SourceLanguage/ Tests/fixtures/sentence-translation-fixtures.jsonl`
      in this repository; do not copy a value from this plan). Update the surrounding comment to
      say the constant now pins both the certificate and translation contracts.
- [ ] Update the bimodal tests README (`code/src/model_checker/theory_lib/bimodal/tests/README.md`)
      to describe the new translation conformance module alongside the existing certificate
      agreement module, including its forward-only and parsed-JSON-comparison properties.
- [ ] Re-read `BimodalTools/README.md`'s source-sentence translation protocol section in this
      repository and confirm every obligation it states of the consuming side is now discharged
      by a live assertion; list any residual gap explicitly rather than leaving it implied.
- [ ] Run the full ModelChecker test suite one final time and compare against Phase 1's baseline.
- [ ] Commit in ModelChecker, staging only this plan's named files by explicit path — never a
      directory or glob pathspec, and never `git add -A`. Leave that repository's dirty
      `specs/**` files (its own in-flight tasks 205/206) untouched and unstaged.
- [ ] Write the implementation summary to
      `specs/686_modelchecker_contract_handoffs/summaries/01_modelchecker-contract-handoffs-summary.md`
      in **this** repository, recording per item: what was found already done (1, 2, 4), what had
      no target (3), and what was implemented (5, 6).

**Timing**: 0.75 hours

**Depends on**: 3, 4, 5

**Verification Tier**: full

Rationale: the phase closes the task, so it runs the complete gate set regardless of how narrow
its own edits are.

**Files to modify**:
- `code/src/model_checker/theory_lib/bimodal/tests/_lean_check.py` — `BIMODAL_LOGIC_COMMIT` and
  its comment.
- `code/src/model_checker/theory_lib/bimodal/tests/README.md` — new module description.
- `specs/686_modelchecker_contract_handoffs/summaries/01_modelchecker-contract-handoffs-summary.md`
  (new, in this repository).

**Verification**:
- Full ModelChecker test suite green, matching or improving on Phase 1's baseline.
- `git status --short` in ModelChecker shows this plan's files committed and the pre-existing
  `specs/**` modifications still unstaged and unmodified.
- The summary artifact exists and covers all six items.

---

## Testing & Validation

- [ ] `test_certificate_lean_agreement.py` runs (does not skip) and passes — items 1 and 4 live.
- [ ] `PROTOCOL_FAILURE` is `None`.
- [ ] `ensure_ascii=False` present at the single wire-serialization site — item 2.
- [ ] `\top` type-updates with both `operator` and `arguments` set; `\bot` unchanged.
- [ ] `to_json(translate(_sentence("\\top")))` equals `{"tag":"imp","left":{"tag":"bot"},"right":{"tag":"bot"}}`.
- [ ] `test_formula.py` passes with `\top` present in `_BOX_TEST_CORPUS`.
- [ ] All 26 fixture rows agree as parsed JSON; row count and `kind` coverage asserted.
- [ ] `\rightarrow` asserts the disjunction-of-negation shape; `\future` asserts the
      negated-universal shape.
- [ ] Checkout-absent skip paths are clean and named for both the fixture-only and differential legs.
- [ ] Full ModelChecker test suite green across every theory, matching Phase 1's baseline.

## Artifacts & Outputs

In `~/Projects/ModelChecker`:
- `code/src/model_checker/syntactic/sentence.py` (modified — the `store_types` branch)
- `code/src/model_checker/theory_lib/bimodal/tests/unit/test_formula.py` (modified — `\top`
  assertions, corpus exclusion removed)
- `code/src/model_checker/theory_lib/bimodal/tests/integration/test_sentence_translation_agreement.py` (new)
- `code/src/model_checker/theory_lib/bimodal/tests/_lean_check.py` (modified — pin refresh)
- `code/src/model_checker/theory_lib/bimodal/tests/README.md` (modified)

In this repository:
- `specs/686_modelchecker_contract_handoffs/summaries/01_modelchecker-contract-handoffs-summary.md` (new)

## Rollback/Contingency

All source changes live in `~/Projects/ModelChecker`, a separate git repository whose working tree
carries concurrent, unrelated in-flight work at the time of planning.

- **Do not** run `git-snapshot.sh` for this work. That script is scoped to this repository's task
  state and has no meaning in the consuming repository.
- **Do not** run any destructive git command (`git reset --hard`, `git checkout -- <path>`,
  `git clean -fd`, `git restore <path>`) in ModelChecker while its tree is dirty — doing so would
  discard another session's uncommitted `specs/**` work.
- To revert a landed phase, `git revert` that phase's specific commit in ModelChecker. Because
  each phase commits only its own explicitly named files, a revert is surgical.
- If Phase 2's full-suite run shows a regression in a non-bimodal theory, the Scope Hypothesis is
  wrong: revert Phase 2's commit and reconsider the branch condition (for example, keeping the
  original name test as a fast path for genuinely primitive extremal operators while adding the
  shape test) before proceeding to Phases 3-5, both of which depend on it.
- If the BimodalLogic checkout is unavailable in the implementation environment, Phases 1 and 5
  cannot be verified. Phases 2, 3 and 4 remain implementable; mark 1 and 5 `[BLOCKED]` with the
  named environment reason rather than reporting them passed.
