# Implementation Plan: Clear the C34b residual and enforce ENFORCE_C34B

- **Task**: 668 - Clear the 8-row C34b residual in the hypothesis-honesty gate, then flip
  `ENFORCE_C34B=1` so the trigger half of invariant C34 is enforced alongside C34a
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: None (direct follow-up to the completed hypothesis-honesty-lint work, which
  landed C34 with C34a enforced and C34b soft)
- **Research Inputs**:
  `specs/668_clear_c34b_residual_enforce_c34b/reports/01_clear-c34b-residual-enforce.md`
- **Reports Integrated**: `reports/01_clear-c34b-residual-enforce.md`
- **Artifacts**: plans/01_clear-c34b-residual-enforce.md (this file),
  summaries/01_clear-c34b-residual-enforce-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Invariant C34 in `scripts/check-module-invariants.sh` gates hypothesis honesty over the bundling
`FrameOver.IsRegular` class. Its structural half (C34a) is enforced; its trigger half (C34b) ships
soft at `ENFORCE_C34B=0` because eight binder-carrying declarations whose docstrings read as
constraint claims carry no marker, and each of them needs more than a marker line — a marker
omitting a constraint its own binder supplies fails C34a unless the declaration delegates to a
binder-free twin. This plan clears those eight rows, then flips the flag. Done means the C34b hit
list is zero as measured by the gate's own census, `ENFORCE_C34B=1` is committed, both halves of
C34 are enforced, `lake build` is green and sorry-free with `axiom_count` unchanged at 14, and the
`MODULE_INVARIANTS.md` C34 row plus `REFERENCE_NORMAL_FORM.md` section 3 record the final
discharge vocabulary.

### Research Integration

The report settles the task description's first question — route (a) eight restatements versus
route (b) a projection-shaped discharge rule — and it settles it by necessity rather than by cost.
Five findings shape this plan's structure:

- **A second discharge rule is required, not merely cheaper.** Two of the eight rows,
  `FrameOver.saturation` and `TaskFrame.saturation`, are **field re-exports**: their whole proof
  term is `h.saturation` / `F.toFibre.saturation`. Route (a) cannot reach them *even in principle*,
  because `delegates()` requires the twin to mention no bundling class anywhere in its span, and
  any restatement of "the class supplies this field" must name `IsRegular`. So the route question
  is not a cost comparison.
- **Route (a) costs three new declarations, not eight restatements.** The task description's
  premise that "none has a binder-free declaration to delegate to" is wrong for two rows:
  `FrameOver.reflection` already has `FrameOver.reflection_of_limit` and `FrameOver.nullity`
  already has `TaskFrame.nullity_of_serial_limit`, both binder-free, both already named in the
  docstrings of the rows that need them, both needing only a marker line. A third row,
  `constant_of_countable_range`, reuses the twin another row introduces.
- **The second rule ships in its narrowest form, and the broad one is declined with a number
  attached.** The report measured the broad "names exactly the class fields its marker lists" rule
  at 41 of 212 binder-carrying declarations auto-dischargeable; the narrow re-export rule at 8. On
  the 11 declarations where the existing delegation rule and the projection rule both apply today
  they agree 11/11, so the widening is consistent — but it is a widening, and the narrow form is
  available at no extra Lean cost. The broad form is recorded as considered-and-deferred with both
  measurements.
- **One measured precondition.** `example` blocks bleed into the preceding declaration's span
  (`example` is in neither `lean_citations.DECL` nor C34's `TOPLEVEL` truncation), which puts
  `F.serial` from two trailing `example` lines inside `FrameOver.saturation`'s scanned body and
  would make either new rule fail on it. Adding `example` (and `omit`, for robustness) to
  `TOPLEVEL` was measured verdict-neutral on today's tree and must land before the rule.
- **The most tempting wrong answer is named and declined.** Marking the two re-exports
  `Compositionality, Seriality, Limit, Saturation` is a two-line change needing no gate work at
  all, because an all-four marker omits nothing and is C34a-exempt. It is rejected: the marker's
  defined meaning is that the listed constraints are the whole of what the elaborated term
  reaches, `h.saturation` reaches one field, so an all-four marker there is a false statement that
  destroys exactly the audit value the form exists for.

### Prior Plan Reference

No prior plan exists for this task. The completed hypothesis-honesty-lint work's plan
(`specs/663_hypothesis_honesty_lint_isregular_overbinding/plans/01_hypothesis-honesty-lint-isregular.md`)
is the immediate predecessor and supplies three calibrations carried into this plan rather than
copied from it: its restatement-plus-corollary pattern is the established remedy this plan reuses
verbatim; its measured experience that the binder census drifts under the work itself (four
successive re-measurements) is why Phase 1 here re-measures and no later phase quotes a figure as
an acceptance value; and its Phase 6 experience — that the gate's `_FIXTURES` list is the
component that catches a matcher mistake before the tree does — is why the new discharge rule's
must-fail fixtures are acceptance criteria here rather than optional hardening.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no `specs/ROADMAP.md` was consulted.

## Goals & Non-Goals

**Goals**:

- **Clear the C34b residual to zero by the gate's own census**, so `ENFORCE_C34B=1` can be
  committed with both halves of C34 enforced and the anti-silence property of the marker
  convention complete — an opt-in marker with only a structural half is bypassable by simply not
  marking a declaration.
- **Widen the discharge vocabulary by exactly one narrow rule**: a *field re-export* rule, under
  which a declaration whose entire proof term is a single field projection off its own bound
  frame/instance, and whose marker names exactly that one field's constraint, discharges C34a. A
  re-export of a field is not a claim about consumption. Measured surface: 8 declarations
  tree-wide.
- **Restate six rows at the hypotheses their proofs actually consume**, three of them against
  binder-free twins that already exist and three against new ones, keeping every original
  declaration as a one-line corollary whose signature line is byte-identical so no call site
  moves.
- **Add must-fail fixtures, not only must-pass ones, for the new rule**, so the rule's narrowness
  is pinned by the gate's own regression suite rather than by prose.
- **Correct the documentation rather than only extend it.** `REFERENCE_NORMAL_FORM.md` section 3's
  C34a bullet currently omits the delegation escape that eighteen declarations already rely on;
  the C34 row in `MODULE_INVARIANTS.md` still says C34b ships soft and still tells a reader to
  flip the flag.
- Declarations pinned by `## Lean Challenge Statements`:
  `FrameOver.nullity_identity_of_serial_limit`,
  `FrameOver.static_of_uniformDwell_of_compositional_serial_limit`,
  `FrameOver.levels_closed_of_limit`.

**Non-Goals**:

- **Blanket unbundling.** `[F.IsRegular]` remains the correct ambient hypothesis for ordinary
  soundness, validity and transfer theorems. The 194 binder-carrying, unmarked declarations the
  predecessor work deliberately left alone are not touched.
- **Changing `IsRegular`'s fields.** The class keeps `comp`, `serial`, `limit`, `saturation`
  exactly as they are; this is what makes the two re-exports irreducible.
- **The broad projection rule.** Declined in this task with its measurement recorded (41 of 212
  versus 8), plus the blind spot that distinguishes it: transitive consumption through a called
  declaration carrying its own `[F.IsRegular]` binder is invisible to a projection scan.
- **Changing the six genuine *Saturation* consumers already marked.** Each consumes all four
  fields and is correct as it stands; they must be marked, never changed.
- **Rewording a docstring to duck the trigger.** The two re-export rows are trigger false
  positives in substance — their sentences are about what the Step Lemma consumes, not about their
  own consumption — but the sanctioned remedy is still the marker line, and the marker is honest
  and informative there.
- **The other six field re-exports** (`FrameOver.comp`/`serial`/`limit` and their `TaskFrame`
  counterparts). Marking them would exercise the new rule across its whole surface, but none
  triggers C34b, none is required by DONE, and each is a declaration the hard constraints tell
  this task to leave alone. Recorded as a follow-up.
- **`check-paper-definitions.sh` and `typst-sync-check.sh` Check 2.** Both exit 1 on the base
  commit, both were verified pre-existing in a detached worktree, and both belong to separate
  work. They are neither absorbed here nor to be read as regressions from this task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The census figures drift under the work itself, as they did four times across the predecessor task (225/43 → 258/47 → 259 → 261/47) | M | H | Phase 1 re-measures from the gate's own ungated census reporter and records what today's tree says. No later phase quotes a figure from this plan, the research report or the task description as an acceptance value; every acceptance is a freshly measured census number |
| The new rule silently admits cases it was not meant to — a genuine widening of the gate's discharge vocabulary | H | M | Narrow re-export form (surface 8, not 41); exact one-field marker match, so the rule fails closed under any incidental `.comp`/`.limit` elsewhere in the body; five must-fail fixtures in Phase 2 including a body that applies a further lemma rather than being the bare projection. Residual and documented rather than fixed: transitive consumption through a binder-carrying callee is invisible to any code-scanning rule, the existing delegation rule included |
| `example`/`omit` span bleed defeats the new rule in a way that reads as the rule being wrong | M | M | Phase 1 makes the `TOPLEVEL` truncation its own first step with an explicit verdict-neutrality check (census figures and both C34a/C34b verdicts byte-identical before and after) before any marker or rule lands |
| A restatement changes an implicit-argument order or a signature line and silently moves call sites | H | L | Corollary-with-unchanged-signature rule. Each original keeps its exact binder list and implicit-argument order, its body becoming a one-line application. Checked mechanically per row against the base blob (`git show <base>:<file> \| sed -n '<line>p'` against the working-tree line), not by eye — Phases 5, 6 and 7 have body rewrites, which is where drift would hide |
| A proof-term change in `Semantics/` perturbs the flagship axiom baselines that C2 gates, which `--no-build` cannot clear | H | L | Restating a hypothesis cannot introduce an axiom, so the expected delta is nil — but Phase 8 measures it with a full `lake build` plus the full gate rather than assuming. Run detached under `context/patterns/bounded-build-waiter.md` |
| `delegates()` matches on a bare last component, so a future same-named declaration could collide | L | L | `nullity_of_serial_limit` and `reflection_of_limit` are unique in the tree today, and the marker-identity requirement means a future same-named declaration with a different list simply fails to discharge (fail-closed). No mitigation needed; recorded so it is not mistaken for a bug later |
| The two marker additions on `nullity_of_serial_limit` and `reflection_of_limit` are read in diff review as unbundling work on the 194 | L | M | Both are binder-free declarations, so neither is one of the 194 and neither is an unbundling. Phase 4 states this in its commit message |
| The flag flip lands while the list is non-empty, turning CI red | H | L | `ENFORCE_C34B=1` is the last change in the last phase, after a measured zero. Phases 3-7 each close on a re-measured residual count |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 6, 7 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 8 | 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel. Wave 2's three phases are territory-disjoint:
Phase 2 owns `scripts/check-module-invariants.sh`, Phase 6 owns
`FormalSystem/Semantics/Correspondence/Rigidity.lean`, Phase 7 owns
`FormalSystem/Semantics/Correspondence/RigidityReal.lean`. Phases 3, 4 and 5 are strictly
sequential only because all three own the same file,
`FormalSystem/Semantics/TaskFrame.lean` — they are logically independent of one another.

---

### Phase 1: Re-measure, and truncate the declaration scan at `example`/`omit` [COMPLETED]

**Goal**: Replace every inherited figure with a freshly measured one, and close the span-bleed
precondition that would otherwise make the new discharge rule fail on the very rows it exists for
— with the truncation's verdict-neutrality measured, not assumed.

**Tasks**:
- [ ] Record the task base commit SHA (`git rev-parse HEAD`) in the progress file. Every
      signature-identity check in later phases diffs against this blob.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and record: exit code, the `INFO
      C34 census:` lines verbatim, the `PASS C34a` line, and the `TODO C34b` block with its hit
      list. This is the baseline; do not reconcile it against the research report or this plan.
- [ ] Re-run the C34 block alone with `ENFORCE_C34B=1` and confirm it exits 1 with the residual as
      the only gated failure. If it exits 0, the residual is already clear and Phases 3-7 must be
      re-scoped before proceeding — report rather than improvise.
- [ ] Confirm each of the eight rows still exists, still carries a bracketed binder, and still
      carries no marker: `static_iff_uniformDwell` in
      `FormalSystem/Semantics/Correspondence/Rigidity.lean`; `levels_closed` and
      `constant_of_countable_range` in `FormalSystem/Semantics/Correspondence/RigidityReal.lean`;
      `FrameOver.saturation`, `nullity`, `nullity_identity`, `FrameOver.reflection` and
      `TaskFrame.saturation` in `FormalSystem/Semantics/TaskFrame.lean`. Record the line number of
      each keyword line as measured, not as quoted.
- [ ] Confirm the two binder-free twins that later phases delegate to still exist and still
      mention no bundling class in their spans: `TaskFrame.nullity_of_serial_limit` and
      `FrameOver.reflection_of_limit` in `TaskFrame.lean`.
- [ ] Confirm `class IsRegular`'s four fields are still `comp`, `serial`, `limit`, `saturation`.
      If any field has changed, STOP and report: the marker vocabulary and the new rule's
      field-to-constraint table are both derived from this list.
- [ ] Add `example` and `omit` to the C34 `TOPLEVEL` regex in
      `scripts/check-module-invariants.sh`, and extend the comment above it to say why (an
      `example` block is in neither `lean_citations.DECL` nor this truncation, so it falls inside
      the preceding declaration's span and pollutes that declaration's scanned body; `omit … in`
      is the same shape one keyword further out).
- [ ] Verify the truncation is verdict-neutral: re-run the gate and confirm every census figure
      and both verdicts are byte-identical to the baseline recorded above. A changed figure is not
      a pass — stop and diagnose which declaration moved and why.
- [ ] Add a fixture to `_FIXTURES` pinning the truncation: a binder-free marked declaration
      followed by an `example` carrying a bracketed `[F.IsRegular]` binder, expected to yield no
      C34a violation and no C34b hit (without the truncation the `example`'s binder is attributed
      to the declaration above it).
- [ ] Commit.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This plan inherits the figures "8 C34b rows, 212 binder-carrying
declarations in 46 files, 29 markers, 194 unmarked" from the research report, and the eight row
names and their file assignments from the task description. All are hypotheses. Confirm by running
the gate's own ungated census reporter and its `ENFORCE_C34B=1` hit list, and record what today's
tree says; if the residual is not the eight named rows, re-scope Phases 3-7 against the measured
list before writing any Lean.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C34's `TOPLEVEL` regex plus its explanatory comment; one
  new `_FIXTURES` entry

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with every census figure and both
  C34 verdicts identical before and after the truncation
- The C34 fixture self-test passes with the new fixture, and fails if the truncation is reverted
  while the fixture is kept
- `git diff --stat` names only `scripts/check-module-invariants.sh`

---

### Phase 2: Land the field re-export discharge rule, with must-fail fixtures [COMPLETED]

**Goal**: Give C34a a second, narrow discharge — a declaration whose whole proof term is one field
projection off its own bound frame, marked with exactly that field's constraint — and pin its
narrowness in the gate's own regression suite before any declaration relies on it.

**Tasks**:
- [ ] Add an explicit field-to-constraint table beside `BUNDLERS`, keyed the same way (one row
      today: `IsRegular` → `{comp: Compositionality, serial: Seriality, limit: Limit, saturation:
      Saturation}`). Derive the mapping from this table, never by positional index into the
      vocabulary tuple, so a vocabulary reorder cannot silently remap a field.
- [ ] Extend `classify()` to compute, per declaration, a `reexport` value: the single constraint
      name when the declaration's binder names a bundling class, the binder's subject is
      recoverable from `\[\s*(?:(\w+)\s*:\s*)?(\w+)\.IsRegular\s*\]`, and the body's `:=` tail is
      a single term of shape `<subject-or-instance-name>(\.<ident>)*\.<field>` for exactly one
      field of that class; `None` otherwise. Append it to the row tuple rather than inserting it,
      so every existing positional unpack (`r[0]`, `r[1]`, `r[3]`) stays valid, and update each
      tuple-unpacking signature (`delegates`, `build_index`, `c34a_violation`, `c34b_trigger`).
- [ ] Add `reexports(row)`: true when `reexport` is not `None` and the marker is exactly the
      frozenset of that one constraint. Wire it into `c34a_violation` as a second discharge
      alongside `delegates`, and extend that function's docstring to name both.
- [ ] Extend the `PASS C34a` line to report the two discharges separately (how many binder-carrying
      markers discharge by delegation and how many by re-export), so the rule's live surface is
      visible in the gate's own output rather than only in a document.
- [ ] Add must-pass fixtures: a re-export whose marker names exactly the projected field; the same
      through a projection chain (`F.toFibre.saturation`).
- [x] Add must-fail fixtures — these are acceptance criteria, not hardening: a re-export whose
      marker names a *different* field; a body projecting two fields with a marker naming one; a
      body projecting one field with marker `None`; a re-export whose body applies a further lemma
      to the projection rather than being the bare projection (this is the fixture that keeps the
      rule narrow); a re-export whose marker is absent entirely.
- [ ] Re-run the gate and confirm the census figures and both verdicts are unchanged from Phase
      1's post-truncation baseline: no declaration is marked yet, so the new rule must have zero
      live effect at this point. A changed verdict here means the rule fires on something it was
      not meant to.
- [ ] Measure and record the rule's tree-wide surface (how many declarations would be
      auto-dischargeable if marked). Record it in the progress file for Phase 8's documentation
      step; do not treat the report's figure of 8 as the answer.
- [ ] Commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The rule's surface is hypothesized at 8 declarations tree-wide (the four
`FrameOver` field re-exports and the four `TaskFrame` ones), against 41 for the broad projection
rule this task declines. Confirm both by measuring them from the current tree in this phase and
record the measured pair; Phase 8 writes the measured numbers into
`REFERENCE_NORMAL_FORM.md`, not these.

**Files to modify**:
- `scripts/check-module-invariants.sh` - field-to-constraint table, `classify()`'s `reexport`
  computation, `reexports()`, `c34a_violation`'s second discharge, the `PASS C34a` reporting line,
  seven new `_FIXTURES` entries *(deviation: altered — eight new entries, not seven; a sixth
  must-fail case pins the projection-chain field check that no other fixture reached)*

**Verification**:
- The C34 fixture self-test passes, and each must-fail fixture genuinely fails when the rule is
  present (confirm by temporarily inverting one expectation and seeing the self-test report it)
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with the census and both verdicts
  unchanged from Phase 1's close
- `ENFORCE_C34B=1` on the C34 block still reports the same residual count as Phase 1 measured
- `git diff --stat` names only `scripts/check-module-invariants.sh`

---

### Phase 3: Mark the two field re-exports [NOT STARTED]

**Goal**: Clear the two rows that route (a) cannot reach in principle, by marking them honestly at
the one field each projects and letting the new re-export rule discharge C34a.

**Tasks**:
- [ ] Add `Constraints consumed: Saturation` to `FrameOver.saturation`'s doc block in
      `FormalSystem/Semantics/TaskFrame.lean`, leaving every existing sentence intact — the
      docstring's *Saturation* prose is about what the Step Lemma consumes, and it stays.
- [ ] Add `Constraints consumed: Saturation` to `TaskFrame.saturation`'s doc block in the same
      file, likewise leaving its existing sentence intact.
- [ ] Confirm both rows now discharge C34a **by re-export**, not by delegation: the extended
      `PASS C34a` line from Phase 2 must attribute exactly two more discharges to the re-export
      rule.
- [ ] Do NOT mark the other six field re-exports (`FrameOver.comp`/`serial`/`limit`,
      `TaskFrame.comp`/`serial`/`limit`). None triggers C34b; they are out of scope by the hard
      constraints and recorded as a follow-up in Phase 8.
- [ ] Re-measure the C34b residual and record it. Commit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the residual drops by exactly two (hypothesized 8 → 6).
Confirm from the gate's own hit list at phase close, not by subtraction from a quoted figure; if
the drop is larger or smaller, the marker is discharging through a path this plan did not
intend and must be diagnosed before Phase 4.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - two `Constraints consumed: Saturation` lines, in the
  existing doc blocks of `FrameOver.saturation` and `TaskFrame.saturation`

**Verification**:
- `lake build FormalSystem.Semantics.TaskFrame` succeeds with zero new warnings (docstring-only
  edits, but a malformed `/--` block is a compile error)
- `bash scripts/check-module-invariants.sh --no-build` exits 0; `PASS C34a` reports two
  re-export discharges; the C34b hit list is two rows shorter and no longer names either
  `saturation`
- `git diff` on `TaskFrame.lean` touches only doc-block lines — no keyword line, no proof term

---

### Phase 4: Mark the two rows whose binder-free twins already exist [NOT STARTED]

**Goal**: Clear `FrameOver.nullity` and `FrameOver.reflection` at zero Lean cost, by marking them
and the twins they already name so the existing delegation rule discharges C34a.

**Tasks**:
- [ ] Add `Constraints consumed: Seriality, Limit` to `TaskFrame.nullity_of_serial_limit`'s doc
      block. It is binder-free, so marking it can trigger neither C34a nor C34b.
- [ ] Add `Constraints consumed: Seriality, Limit` to `FrameOver.nullity`'s doc block. Its body
      already names `TaskFrame.nullity_of_serial_limit`, so delegation discharges C34a with no
      body change.
- [ ] Add `Constraints consumed: Limit` to `FrameOver.reflection_of_limit`'s doc block. Also
      binder-free.
- [ ] Add `Constraints consumed: Limit` to `FrameOver.reflection`'s doc block. Its body is already
      `F.reflection_of_limit F.limit w d u`, so delegation discharges C34a with no body change.
- [ ] Confirm both new discharges are attributed to *delegation*, not re-export: neither body is a
      bare field projection, so the re-export count must not move in this phase.
- [ ] Note in the commit message that `nullity_of_serial_limit` and `reflection_of_limit` are
      binder-free declarations, so neither is one of the 194 binder-carrying declarations this task
      must not touch and neither marker is an unbundling.
- [ ] Re-measure the C34b residual and record it. Commit.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts four marker lines and a residual drop of exactly two
(hypothesized 6 → 4), with the re-export discharge count unchanged. Confirm all three from the
gate's own output at phase close.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - four `Constraints consumed:` lines, in the existing
  doc blocks of `TaskFrame.nullity_of_serial_limit`, `FrameOver.nullity`,
  `FrameOver.reflection_of_limit` and `FrameOver.reflection`

**Verification**:
- `lake build FormalSystem.Semantics.TaskFrame` succeeds with zero new warnings
- `bash scripts/check-module-invariants.sh --no-build` exits 0; the C34b hit list no longer names
  `nullity` or `FrameOver.reflection`; the re-export discharge count is unchanged from Phase 3
- `git diff` on `TaskFrame.lean` touches only doc-block lines

---

### Phase 5: Restate `nullity_identity` at *Seriality* and *Limit* [NOT STARTED]

**Goal**: Add the first of three new binder-free twins and demote `FrameOver.nullity_identity` to
a one-line corollary of it, with its signature line byte-identical.

**Tasks**:
- [ ] Add `FrameOver.nullity_identity_of_serial_limit` immediately above
      `FrameOver.nullity_identity` in `FormalSystem/Semantics/TaskFrame.lean`, taking
      `(hser : TaskFrame.Serial F.TaskRel)` and `(hlim : TaskFrame.Limit F.TaskRel)` explicitly,
      at the statement pinned in `## Lean Challenge Statements`. Its proof is the existing body
      with each projection substituted: `F.eq_of_taskRel_zero` becomes
      `F.eq_of_taskRel_zero_of_limit hlim`, and `F.nullity` becomes
      `TaskFrame.nullity_of_serial_limit hser hlim`.
- [ ] Give it a doc block in the established shape — what it is, which hypotheses it consumes and
      why, a sentence naming the corollary below it — ending with
      `Constraints consumed: Seriality, Limit`.
- [ ] Rewrite `FrameOver.nullity_identity`'s body to the one-line application
      `F.nullity_identity_of_serial_limit F.serial F.limit`, leaving its keyword line, binder
      list and implicit-argument order untouched. Add
      `Constraints consumed: Seriality, Limit` to its doc block and a sentence recording that the
      explicit-hypothesis form above is the general one.
- [ ] Check the signature line mechanically against the base blob:
      `git show <base>:FormalSystem/Semantics/TaskFrame.lean | sed -n '<line>p'` must equal the
      working-tree line byte for byte.
- [ ] Re-measure the C34b residual and record it. Commit.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts one new declaration, one body rewrite, one residual row
cleared (hypothesized 4 → 3), and that `nullity_identity`'s proof reaches exactly *Seriality* and
*Limit*. Confirm the constraint set by reading the elaborated proof at implementation time (the
substituted body must typecheck with no further projection off `F`), and the residual from the
gate's hit list.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - new `FrameOver.nullity_identity_of_serial_limit` with
  its doc block; `FrameOver.nullity_identity` demoted to a one-line corollary with a marker

**Verification**:
- Full `lake build` exits 0, sorry-free, with zero new warnings
- `bash scripts/check-module-invariants.sh --no-build` exits 0; the C34b hit list no longer names
  `nullity_identity`; `PASS C34a` gains one delegation discharge
- `nullity_identity`'s signature line is byte-identical to the base blob
- `git diff --stat` names only `FormalSystem/Semantics/TaskFrame.lean`

---

### Phase 6: Restate `static_of_uniformDwell` and clear `static_iff_uniformDwell` [NOT STARTED]

**Goal**: Add the binder-free rigidity twin and route `static_iff_uniformDwell` through it, so the
row that carries the task's only real proof work discharges by delegation.

**Tasks**:
- [ ] Add `FrameOver.static_of_uniformDwell_of_compositional_serial_limit` immediately above
      `FrameOver.static_of_uniformDwell` in
      `FormalSystem/Semantics/Correspondence/Rigidity.lean`, at the statement pinned in
      `## Lean Challenge Statements`, taking `hcomp`, `hser` and `hlim` explicitly. Its proof is
      the existing body with three substitutions: `F.interpolates` becomes
      `TaskFrame.interpolates_of_comp hcomp`, each `F.serial` becomes `hser`, and each
      `F.reflection` becomes `F.reflection_of_limit hlim`. This is the same substitution set
      `PartialHistory.nonempty_seg_of_compositional_limit` already makes in
      `FormalSystem/Semantics/Extension/Constraint.lean`, the reference instance of the pattern.
- [ ] Give it a doc block in the established shape ending with
      `Constraints consumed: Compositionality, Seriality, Limit`.
- [ ] Rewrite `FrameOver.static_of_uniformDwell`'s body to the one-line application
      `F.static_of_uniformDwell_of_compositional_serial_limit F.comp F.serial F.limit h`, leaving
      its keyword line, instance binders and implicit-argument order untouched, and add
      `Constraints consumed: Compositionality, Seriality, Limit` to its doc block.
- [ ] Rewrite `FrameOver.static_iff_uniformDwell`'s proof term so it names the binder-free twin
      directly rather than the demoted corollary — the corollary mentions `IsRegular` in its span
      and so cannot be delegated to. Add
      `Constraints consumed: Compositionality, Seriality, Limit` to its doc block, keeping its
      existing sharpness prose. Its signature line is unchanged.
- [ ] Leave `uniformDwell_of_static` alone: it carries no binder and consumes nothing.
- [ ] Check both rewritten signature lines mechanically against the base blob.
- [ ] Re-measure the C34b residual and record it. Commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts one new declaration, two body rewrites, one residual row
cleared (`static_iff_uniformDwell`), and that the twin's honest constraint set is exactly
*Compositionality*, *Seriality*, *Limit*. Confirm the constraint set by the substituted body
typechecking with no remaining projection off `F`, and the residual from the gate's hit list. Note
that the C34b row is `static_iff_uniformDwell`, not `static_of_uniformDwell` — verify which
declaration the gate names before editing.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` - new
  `FrameOver.static_of_uniformDwell_of_compositional_serial_limit` with its doc block;
  `static_of_uniformDwell` demoted to a one-line corollary with a marker;
  `static_iff_uniformDwell` re-routed through the twin with a marker

**Verification**:
- Full `lake build` exits 0, sorry-free, with zero new warnings
- `bash scripts/check-module-invariants.sh --no-build` exits 0; the C34b hit list no longer names
  `static_iff_uniformDwell`
- Both `static_of_uniformDwell` and `static_iff_uniformDwell` have signature lines byte-identical
  to the base blob
- `git diff --stat` names only `FormalSystem/Semantics/Correspondence/Rigidity.lean`

---

### Phase 7: Restate `levels_closed` at *Limit* and route `constant_of_countable_range` [NOT STARTED]

**Goal**: Clear the two `RigidityReal.lean` rows with a single new twin, the second of them reusing
the first's.

**Tasks**:
- [ ] Add `FrameOver.levels_closed_of_limit` immediately above `FrameOver.levels_closed` in
      `FormalSystem/Semantics/Correspondence/RigidityReal.lean`, at the statement pinned in
      `## Lean Challenge Statements`, taking `(hlim : TaskFrame.Limit F.TaskRel)` explicitly. Its
      proof is the existing body with `F.limit` replaced by `hlim`.
- [ ] Give it a doc block in the established shape ending with `Constraints consumed: Limit`.
- [ ] Rewrite `FrameOver.levels_closed`'s body to the one-line application
      `F.levels_closed_of_limit F.limit τ a`, leaving its keyword line and argument order
      untouched, and add `Constraints consumed: Limit` to its doc block.
- [ ] Rewrite `FrameOver.constant_of_countable_range`'s body to route through the twin
      (`levels_closed_of_limit F F.limit τ` in place of `levels_closed F τ`) and add
      `Constraints consumed: Limit` to its doc block, keeping its existing prose about closed
      level sets and Sierpiński. Its signature line is unchanged.
- [ ] Leave `exists_history_of_taskRel` and `static_of_countable` alone: neither is in the
      residual, and `static_of_countable` is one of the six genuine *Saturation* consumers already
      correctly marked with all four constraints.
- [ ] Check both rewritten signature lines mechanically against the base blob.
- [ ] Re-measure the C34b residual and record it. Commit.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts one new declaration clearing two residual rows, and that
both rows' honest constraint set is exactly *Limit*. Confirm by the substituted bodies typechecking
with no remaining projection off `F`, and by the gate's hit list naming neither `levels_closed` nor
`constant_of_countable_range` at phase close.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean` - new
  `FrameOver.levels_closed_of_limit` with its doc block; `levels_closed` demoted to a one-line
  corollary with a marker; `constant_of_countable_range` re-routed through the twin with a marker

**Verification**:
- Full `lake build` exits 0, sorry-free, with zero new warnings
- `bash scripts/check-module-invariants.sh --no-build` exits 0; the C34b hit list names neither
  `levels_closed` nor `constant_of_countable_range`
- Both rewritten signature lines are byte-identical to the base blob
- `git diff --stat` names only `FormalSystem/Semantics/Correspondence/RigidityReal.lean`

---

### Phase 8: Flip `ENFORCE_C34B=1`, document the discharge vocabulary, close on the full gate set [NOT STARTED]

**Goal**: Make the trigger half enforced once the measured residual is zero, and leave the two
documents describing what the gate actually does rather than what it was going to do.

**Tasks**:
- [ ] Re-measure the C34b residual from the gate's own output and confirm it is **zero**. If it is
      not, stop: the flag must not be flipped against a non-empty list, and the remaining rows
      belong to whichever earlier phase owns them.
- [ ] Change `ENFORCE_C34B=${ENFORCE_C34B:-0}` to `${ENFORCE_C34B:-1}` in
      `scripts/check-module-invariants.sh` and update its trailing comment from "not yet enforced"
      to enforced.
- [ ] Remove the now-false `set ENFORCE_C34B=1 to make this exit-code-affecting once the list is
      clear` line from the C34b failure output, and change the soft `TODO C34b` label handling so
      the default path is the enforced one. Keep the flag itself so a local investigation can still
      soften the check.
- [ ] Update the `MODULE_INVARIANTS.md` C34 row: retitle `C34a (enforced) / C34b (soft)` to both
      halves enforced; replace the "C34b ships soft because…" and "Flip `ENFORCE_C34B=1` once the
      printed list is clear" sentences with what was actually done (the residual was cleared by
      six explicit-hypothesis restatements against three new and two existing binder-free twins,
      plus two field re-exports discharged by a new rule); and extend the discharge-vocabulary
      sentence to name both discharges.
- [ ] Update `REFERENCE_NORMAL_FORM.md` section 3: correct the C34a bullet, which currently says a
      marker omitting a constraint "must sit over a declaration whose code does not carry the
      bundling class at all" and omits the delegation escape that eighteen declarations already
      rely on. Replace it with an enumerated list of the discharge rules, each with its measured
      live surface: (1) a marker omitting nothing; (2) delegation to a binder-free twin carrying
      the identical list; (3) the field re-export rule. Add the broad projection rule as a
      considered-and-deferred entry with both measured numbers from Phase 2 and the blind spot
      that decided it (transitive consumption through a binder-carrying callee is invisible to a
      projection scan). Update the closing cross-reference so it no longer says the trigger half
      ships soft.
- [ ] Record the two follow-ups as prose in `REFERENCE_NORMAL_FORM.md` section 3 or the
      implementation summary, not as new tasks: the six unmarked field re-exports that would
      exercise the new rule across its whole surface, and the broad projection rule's deferred
      status.
- [ ] Run the full `lake build` detached under the bounded-build-waiter contract
      (`context/patterns/bounded-build-waiter.md`: hard timeout, writer liveness via `kill -0` on
      the captured PID, one waiter per log) and confirm zero errors, zero warnings, sorry-free.
- [ ] Confirm `axiom_count` is unchanged at 14 and the flagship axiom baselines C2 gates are
      unmoved. A restated hypothesis cannot introduce an axiom, so any delta here is a real defect,
      not an expected cost.
- [ ] Run the full `bash scripts/check-module-invariants.sh` and confirm both C34a and C34b report
      `PASS`, and that `check-paper-definitions.sh` and `typst-sync-check.sh` Check 2 still fail
      exactly as they do on the base commit — reported as pre-existing, never absorbed, never
      recorded as a regression from this task.
- [ ] Commit.

**Timing**: 1.5 hours

**Depends on**: 2, 3, 4, 5, 6, 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the residual is zero and `axiom_count` is unchanged at
14. Both are measured here, not assumed: the residual from the gate's own hit list under
`ENFORCE_C34B=1`, and the axiom count from the full build's own baseline check. The two
out-of-scope gates are asserted to fail identically to the base commit — confirm by running them
at the base commit, or by the detached-worktree evidence already recorded, rather than by
inspection.

**Files to modify**:
- `scripts/check-module-invariants.sh` - `ENFORCE_C34B` default and comment, C34b output text
- `docs/development/MODULE_INVARIANTS.md` - the C34 row: title, the soft-window sentences, the
  discharge-vocabulary sentence
- `docs/development/REFERENCE_NORMAL_FORM.md` - section 3: the enumerated discharge rules with
  measured surfaces, the deferred broad rule, the corrected cross-reference

**Verification**:
- Full `lake build` exits 0: zero errors, zero warnings, sorry-free, `axiom_count` 14
- `bash scripts/check-module-invariants.sh` reports `PASS C34a` and `PASS C34b` with
  `ENFORCE_C34B` defaulting to 1, and every pre-existing invariant retains its pre-task status
- `ENFORCE_C34B=0` still softens the check, confirming the flag was not deleted
- The final census is re-measured from the tree and reported as such; no figure from this plan or
  the research report is carried forward as an acceptance value
- `git diff --stat` against the base commit names only: `scripts/check-module-invariants.sh`,
  `FormalSystem/Semantics/TaskFrame.lean`,
  `FormalSystem/Semantics/Correspondence/Rigidity.lean`,
  `FormalSystem/Semantics/Correspondence/RigidityReal.lean`,
  `docs/development/MODULE_INVARIANTS.md`, `docs/development/REFERENCE_NORMAL_FORM.md`, and this
  task's `specs/` artifacts

---

## Lean Challenge Statements

The three new binder-free restatements this plan commits to. Each corresponding original
declaration survives unchanged as a one-line corollary and is therefore NOT pinned here — only the
new statements are. Bodies are `sorry` by the format's rule; the real proofs are the existing green
proofs with one projection substituted per explicit hypothesis.

```lean
import FormalSystem.Semantics.Correspondence.RigidityReal

namespace FormalSystem.Semantics

namespace FrameOver

open TaskFrame

/-- `FrameOver.nullity_identity` at the hypotheses its proof consumes: reflexivity at zero from
*Seriality* plus *Limit*, injectivity at zero from *Limit* alone.
Constraints consumed: Seriality, Limit -/
theorem nullity_identity_of_serial_limit {D : TemporalOrder} (F : FrameOver D)
    (hser : TaskFrame.Serial F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel) :
    ∀ w u, F.TaskRel w 0 u ↔ w = u := sorry

/-- `FrameOver.static_of_uniformDwell` at the hypotheses its proof consumes. Interpolation enters
through `TaskFrame.interpolates_of_comp`, the reflection law through
`FrameOver.reflection_of_limit`, and the positive half of `Static` through *Seriality*.
Constraints consumed: Compositionality, Seriality, Limit -/
theorem static_of_uniformDwell_of_compositional_serial_limit {D : TemporalOrder}
    [DenselyOrdered ↑D] [Archimedean ↑D] (F : FrameOver D)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (h : UniformDwell F.TaskRel) :
    Static F.TaskRel := sorry

/-- `FrameOver.levels_closed` at the hypothesis its proof consumes: *Limit* supplies, for each
pair of distinct states, a radius below which no task connects them, and `respects_task` keeps
every nearby time out of the level set.
Constraints consumed: Limit -/
theorem levels_closed_of_limit (F : FrameOver realOrder)
    (hlim : TaskFrame.Limit F.TaskRel) (τ : WorldHistory F.toTaskFrame) (a : F.WorldState) :
    IsClosed {t : ℝ | τ.state t = a} := sorry

end FrameOver

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] Full `lake build` exits 0 with zero errors, zero warnings and zero `sorry`, at every phase
      boundary from Phase 5 onward
- [ ] `axiom_count` is unchanged at 14 and the flagship axiom baselines C2 gates are unmoved
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 with BOTH C34a and C34b
      enforced at close, and every pre-existing invariant (B0-B3, C1-C33) retains its pre-task
      status
- [ ] The C34 fixture self-test passes, with each new must-pass case (a re-export whose marker
      names the projected field; the same through a projection chain) and each new must-fail case
      (wrong field; two fields marked as one; projection with marker `None`; a body applying a
      further lemma; no marker at all) behaving as specified
- [ ] The `example`/`omit` truncation is verdict-neutral: census figures and both C34 verdicts
      byte-identical before and after Phase 1's change
- [ ] Every one of the five rewritten declarations keeps a byte-identical signature line, verified
      against the base blob with `git show <base>:<file> | sed -n '<line>p'`, not by eye
- [ ] `ENFORCE_C34B=0` still softens C34b after the flip, confirming the flag was retained
- [ ] `git diff --stat` against the task base names only the six files listed in Phase 8 plus this
      task's `specs/` artifacts
- [ ] `check-paper-definitions.sh` and `typst-sync-check.sh` Check 2 fail exactly as they do on
      the base commit, reported as pre-existing and absorbed by nothing here
- [ ] The final census is re-measured from the tree at close and reported as such — no figure from
      this plan or the research report is carried forward as an acceptance value

## Artifacts & Outputs

- `scripts/check-module-invariants.sh` - `example`/`omit` span truncation; the field-to-constraint
  table; the field re-export discharge rule with its two-way `PASS C34a` reporting; eight new
  fixtures; `ENFORCE_C34B` defaulting to 1
- `FormalSystem/Semantics/TaskFrame.lean` - six marker lines (two re-exports, two rows discharged
  by delegation, two existing binder-free twins); new
  `FrameOver.nullity_identity_of_serial_limit` with `nullity_identity` demoted to a corollary
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` - new
  `FrameOver.static_of_uniformDwell_of_compositional_serial_limit`; `static_of_uniformDwell`
  demoted to a corollary; `static_iff_uniformDwell` re-routed through the twin; three marker lines
- `FormalSystem/Semantics/Correspondence/RigidityReal.lean` - new
  `FrameOver.levels_closed_of_limit`; `levels_closed` demoted to a corollary;
  `constant_of_countable_range` re-routed through the twin; three marker lines
- `docs/development/MODULE_INVARIANTS.md` - the C34 row, retitled to both halves enforced with its
  soft-window language replaced
- `docs/development/REFERENCE_NORMAL_FORM.md` - section 3's enumerated discharge rules with
  measured surfaces, and the deferred broad projection rule
- `specs/668_clear_c34b_residual_enforce_c34b/summaries/01_clear-c34b-residual-enforce-summary.md`

## Rollback/Contingency

Each phase commits per green sub-step, so the unit of rollback is a commit, not a working tree.

- **A single phase goes wrong**: `git revert` that phase's commits. Phases 3, 4, 6 and 7 are
  independent of one another at the corollary boundary — every call site sees an unchanged
  signature — so reverting one leaves the others green. Phase 8 is the only phase whose revert is
  mandatory if any earlier phase is reverted: `ENFORCE_C34B=1` against a non-empty list is red.
- **The re-export rule proves unworkable as specified**: revert Phase 2 and Phase 3 together,
  keeping Phases 1, 4, 5, 6 and 7. The residual then stands at two rows and `ENFORCE_C34B` stays
  at `0`, which is the pre-task posture with six of eight rows cleared — a smaller, honest
  increment rather than a failed task. Record the two remaining rows and why the rule did not
  work.
- **A restatement will not typecheck at the explicit hypotheses**: the fallback is NOT an all-four
  marker (see Goals & Non-Goals — that marker would be a false statement). It is to leave that row
  in the residual, keep `ENFORCE_C34B=0`, and report the row with the specific projection that
  could not be discharged.
- **A genuine whole-tree rollback of uncommitted work** (not a per-phase revert): take a snapshot
  first per `context/contracts/recovery.md`'s rollback rung, including its out-of-scope override
  flag for the deliberate whole-tree case, then run the destructive command. A defensive
  checkpoint before risky work is `git-snapshot.sh <task> --no-revert` instead — durable and
  non-reverting; never a bare default-mode call as a routine precaution.
