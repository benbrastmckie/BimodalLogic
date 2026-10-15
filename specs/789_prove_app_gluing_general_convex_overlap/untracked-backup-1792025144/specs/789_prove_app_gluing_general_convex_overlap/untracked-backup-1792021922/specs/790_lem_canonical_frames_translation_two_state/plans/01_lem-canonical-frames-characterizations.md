# Implementation Plan: Task #790

- **Task**: 790 - Prove lem:canonical-frames, the four claims about the paper's two canonical countermodel frames
- **Status**: [NOT STARTED]
- **Effort**: 7.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/790_lem_canonical_frames_translation_two_state/reports/01_lem-canonical-frames-characterizations.md
- **Artifacts**: plans/01_lem-canonical-frames-characterizations.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The paper's lemma about its two canonical countermodel frames makes four claims — (a) the
translation frame over a duration group is a Deterministic task frame; (b) its possible worlds
are exactly the translations; (c) the two-state permissive frame is a task frame just in case the
duration order is Discrete; (d) when it is, it is not Deterministic and every assignment from
durations to its two states is a possible world. All four are landed as 23 declarations appended
to the existing module `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, in namespace
`FormalSystem.Semantics`, with no new module and no change to either frame's definition. The
research round machine-checked every proof in standalone probe files under `lake env lean`, so
this is a transcription, docstring, and gate-work plan rather than a discovery plan. Done means:
the 23 declarations compile green in the library with no `sorry` and no new axiom; the two paper
anchors they cite are recorded in the definitions-of-record file so the anchor-integrity
invariant stays satisfied across every commit boundary; the module's own documentation surface
names the new characterizations; and the repository's gate set is no worse than the baseline
re-derived at the start of the final phase.

### Research Integration

- **Every Lean step is a transcription of an already-compiled declaration.** The research
  report's Appendix carries all 23 declarations verbatim, each compiled with `lake env lean`
  against the live `.olean` cache with no error, no `sorry`, and no linter output. The phase task
  lists below map one-to-one onto that Appendix in its stated order.
- **Decision adopted (report Decisions, "Placement").** Home is the existing
  `Correspondence/DurationFrames.lean`, not `Frames/Standard.lean` (whose documented invariant is
  that its import list is `TaskFrame` and nothing else, which excludes both the determinism
  predicate and the discreteness dichotomy) and not a new `Frames/Canonical.lean` (which would
  have to import `Correspondence/DurationFrames` for the reference histories, inverting the
  directory layering). Adding no new module is also what keeps the new-module invariants (library-
  root reachability, generated-root byte-currency) out of scope.
- **Decision adopted (report Decisions, "(a) is generalised, not transferred").** The dispatch's
  open question — generalise or transfer from the real-number instance — is answered:
  generalise. The real instance proves determinism of a shift-set frame, a different frame object
  from the translation frame, so a transfer would first need a frame isomorphism that does not
  exist in the tree. Generalising is one citation of the functional-fibre lemma.
- **Decision adopted (report Decisions, "(c) is stated at the bare relation").** The permissive
  frame cannot be formed without the successor-order and no-maximum data that discreteness
  supplies, so a frame-level "is a task frame iff Discrete" is not well formed. Claim (c) is
  stated about the bare relation and tied back to the frame by the relation-equality lemma; that
  tie-back is what makes the biconditional a statement about the frame rather than a lookalike.
- **Decision adopted (report Codebase Patterns, "the instance-transparency barrier").** A frame
  built by the reflective-regular constructor has a world-state type that unifies with the
  duration carrier at default transparency but does not synthesize instances through it, so any
  `+` with a state operand fails to elaborate and a type ascription does not repair it (both
  measured). Every statement that needs arithmetic on states goes through a view definition
  instead, following the house precedent of the bare-path view in `Semantics/IntNormalForm.lean`.
  This is a hard constraint on how the statements are written, not a stylistic preference.
- **Decision adopted (report Decisions, "No theorem-index rows").** No row is added to
  `docs/theorem-index.md`: that index's axioms column is generated from the pinned axiom
  baselines, so a row would oblige adding an axiom baseline for a frame-characterization lemma,
  which the dispatch does not ask for.
- **Decision adopted (report Decisions, "the KNOWN-ANCHORS route").** The two anchors are
  recorded as unpinned known anchors rather than pinned manifest rows, because the docstrings
  cite them as pointers and quote no text, and because the record currently carries a pending
  drift wave that a new pin would entangle with.
- **Decision adopted (report Decisions, "the paper's PORT comment is not cleared").** The paper
  file is read-only input from a repository this one cannot see. The marker is the gap's
  identifier; clearing it is a paper-side edit for the author, recorded as a follow-up in the
  implementation summary.
- **Where this plan goes beyond the research report.** Three mechanical obligations were
  re-derived at plan time and are not in the report: the repository's generated inventory block
  carries whole-tree line totals that this task's line growth drifts; the gate set is already red
  on entry from causes outside this task; and a concurrently dispatched sibling has work staged
  in the shared git index right now. All three are planned for explicitly below.

### Prior Plan Reference

No prior plan. This is the task's first planning round.

### Roadmap Alignment

No roadmap path was provided in this dispatch's delegation context, so no roadmap was consulted
and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Claim (a): `translationFrame_deterministic`
- Claim (b): `translationStates`, `translationSigma`, `translationSigma_states`,
  `translationHist_states`, `translationSigma_zero`, `translationStates_eq`,
  `translation_eq_sigma`, `translationHistEquiv`, `translation_histSet_eq`,
  `translation_exists_unique`
- Claim (c): `permRel`, `permRel_iff`, `permissiveFrame_taskRel_eq`, `permRel_reflection`,
  `permRel_limit_of_isLeast`, `permRel_not_limit_of_dense`, `isDiscrete_iff_exists_isLeast_pos`,
  `permRel_limit_iff_isDiscrete`, `permRel_constraints_iff_isDiscrete`
- Claim (d): `permissiveFrame_not_deterministic`, `permissiveStates`, `permissiveHistEquiv`
- Those 23 identifiers are the set pinned under the Lean Challenge Statements section below,
  exactly, no more and no fewer
- Record the two paper anchors the new docstrings cite as unpinned known anchors in the
  definitions-of-record file, so anchor integrity holds at every commit boundary
- Name the new characterizations on the module's own documentation surface: the module header's
  main-results list, a paragraph explaining that this module now carries the canonical-frame
  characterizations as well as the correspondence witnesses, and the component README row
- Correct the one misleading sentence in the real-instance module's header that reads as though
  the world-set characterization cannot be stated on the translation route at all

**Non-Goals**:
- Any change to either canonical frame's definition, or to the reference histories, models and
  realisation lemmas already in the module. The two frames are consumed by the two duration-level
  correspondence biconditionals and by the independence modules; the dispatch forbids touching
  them
- A new module anywhere under FormalSystem/, and therefore the library-root regeneration,
  aggregator edit and generated-root currency work a new module would require
- A docs/theorem-index.md row or an axiom baseline pin for any new declaration (see the adopted
  decision above). This also keeps scripts/check-module-invariants.sh — a file a concurrently
  dispatched sibling declares — out of this task's territory entirely
- Promoting either new anchor to a pinned manifest row, and absorbing the pre-existing
  26-anchor paper-definition drift wave the definitions checker already reports
- The paper-side edit: clearing the PORT marker under the lemma and closing its proof with a
  Lean-proof citation. A different repository; recorded as an author follow-up
- A frame isomorphism between the translation frame and the real instance's shift-set frame, and
  any rewrite of the real instance's own proofs on top of the new general results
- Repairing gate failures this task did not cause, in files a concurrently dispatched sibling
  declares as its own territory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A concurrently dispatched sibling has work **staged in the shared git index right now** (measured at plan time: modifications staged across Semantics/Presheaf/ and Semantics/PartialHistory.lean, plus an untracked new module), so any bare `git commit` from this task would sweep that work into this task's commit | H | H | Every commit in every phase goes through `bash .claude/scripts/git-commit-scoped.sh --message <msg> --session <session_id> --task 790 -- <explicit file list>`, never a bare `git commit` and never a directory or glob add. That script path-scopes the commit and serialises it through the commit mutex, which is exactly this hazard's remedy |
| The repository gate set is **already red on entry** from causes outside this task (measured at plan time: unreachable-module, generated-root, citation-manifest, stale-inventory and one anchor-resolution failure, all moving between consecutive runs as the sibling writes), so "the gate exits 0" is not an achievable closure criterion | H | H | Phase 7 re-derives the baseline as its first act, with exit status and the explicit failing-check list captured before any of this task's own regeneration. Closure requires that the failing-check set after is a **subset** of the set before, and that the checks this task's edits can affect each pass individually and by name |
| Whole-tree generated count files (the root README inventory block, the typst status counts) drift from this task's line growth, but regenerating them bakes a concurrent sibling's in-flight lines into this task's commit — and both files are in that sibling's declared territory | M | H | Phase 7 runs the regeneration **last**, re-reads each file immediately before editing, stages each alone by explicit path, and records in the issue log that the regenerated whole-tree counts include sibling-attributable lines. If a sibling has *uncommitted* Lean changes at that moment, the regeneration is deferred and recorded rather than committed — stated as an explicit decision gate in the phase |
| The instance-transparency barrier: any `+` with a world-state operand fails to synthesize, and a type ascription does not repair it (both measured in the research round) | H if hit | H without the mitigation | Every arithmetic statement goes through the view definitions `translationStates` / `permissiveStates`. Ascriptions are forbidden by this plan, not merely discouraged. Phase 2 lands the views before any statement that needs them |
| Binder-form adaptation: the research probes were compiled under a module-level `variable {D : TemporalOrder}`, but the target module deliberately has no `variable` line and binds the duration group explicitly in every signature | M | H | Each transcribed declaration that relied on the variable gets an explicit `{D : TemporalOrder}` binder, matching the Challenge Statements block below, which is written in the target module's own style rather than the probe's. Confirm per declaration that the elaborated signature matches the Challenge block before committing the sub-step |
| The anchor-integrity invariant fails the moment a citing docstring lands without its record row | M | M | Phase 1 lands the two record rows **before** any Lean edit, as its own phase and its own commit, so the tree is never in the failing state across a commit boundary. Phase 2 depends on Phase 1 for exactly this reason |
| The definitions-of-record file is shared territory (a sibling task's just-completed implementation names it) | L | L | Measured at plan time: that sibling's implementation is committed at HEAD and the file is clean in the working tree, so the collision the research round rated `costly` has largely resolved. Re-read the file immediately before editing anyway, and stage it alone |
| A sibling's concurrent `lake` invocation loses this task's build, or a failure in a file outside this task's scope is read as this task's regression | H | H | Every build routes through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <target>`, detached, with the guard's exit captured un-piped. Before attributing any failure, check `git log` and `git status`; report a foreign commit or modification rather than reconciling it |
| The dead-declaration census lists the new declarations, which have no in-tree consumer | L | H | That census is reporting-only with no enforcement flag. The Phase 6 README row and module-header mentions keep the keystone names visible. Expect rows to inspect, not a failure |
| The right-inverse proof of the assignment-to-history equivalence rests on the reference history's state function being `rfl` | L | L | If a future change makes it non-`rfl`, that proof breaks loudly at build time rather than silently. Recorded so a reader does not mistake the `rfl` for fragile cleverness; no mitigation needed |
| A `@[simp]` attribute on one of the three state lemmas interacts badly with the module's existing simp set | L | L | The three were compiled with their attributes in the research probes. If the linter or a downstream module reports a simp finding, drop the attribute on the offending lemma and record it — the attributes are convenience, not load-bearing |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
Phases 2 through 6 all append to or edit the same single file, so parallel waves would contend
inside one file for no gain, and Phase 1 must precede every citing docstring.

---

### Phase 1: Record the two paper anchors [NOT STARTED]

**Goal**: Put the two anchors the new docstrings will cite on the record, as unpinned known
anchors, before any citing docstring exists — so the anchor-integrity invariant is satisfied at
every commit boundary rather than repaired after the fact.

**Tasks**:
- [ ] Re-read `docs/reference/paper-definitions-of-record.md` immediately before editing, and
      confirm with `git status --short -- docs/reference/paper-definitions-of-record.md` that no
      concurrent writer has it modified
- [ ] Inside the fenced block delimited by the known-anchors begin and end comments, add
      `def:canonical-frames|LIVE-UNPINNED|<note>` in alphabetical position among the unpinned
      rows — after the `def:BL-language` row and before the `def:task-topology` row
- [ ] Add `lem:canonical-frames|LIVE-UNPINNED|<note>` immediately before the
      `lem:deterministic-singleton` row
- [ ] Write each note in the style of its neighbours: what the anchor labels, that this tree
      cites it as a pointer and quotes no text, and which module carries the formalization
      (`FormalSystem/Semantics/Correspondence/DurationFrames.lean`). The note for the lemma
      anchor also records which of its four claims are formalized — all four. Use durable
      anchors only: no task-number references anywhere in this file
- [ ] Confirm the anchor-resolution half of the invariant passes, then commit this file alone via
      the scoped-commit script

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase touches exactly one file and adds exactly
two lines, both inside the known-anchors fenced block, with no other hunk anywhere. Confirm at
implementation time with `git diff --stat`, which must name one file at `2 insertions(+)` and
`0 deletions(-)`.

**Tier Justification**: `local` because the edit is confined to one hand-maintained markdown
record with no compile surface, and the specific covering check is
`bash scripts/check-module-invariants.sh --no-build`, whose anchor-integrity check is the one
assertion this edit exists to satisfy, read together with the diff read-through the tier table
prescribes.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - two unpinned known-anchor rows added in alphabetical position inside the known-anchors fenced block

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` runs and its anchor-integrity check
  reports both of its assertions passing; the invariant's own exit status is read directly, not
  inferred from a diff of its stdout against a baseline
- `grep -n 'canonical-frames' docs/reference/paper-definitions-of-record.md` reports exactly the
  two new rows
- `git diff --stat` names one file, two insertions
- The commit is made with `bash .claude/scripts/git-commit-scoped.sh --message 'task 790: record
  the canonical-frame anchors' --session <session_id> --task 790 --
  docs/reference/paper-definitions-of-record.md` and nothing else

---

### Phase 2: Claim (a) and the translation-frame view layer [NOT STARTED]

**Goal**: Land the determinism of the translation frame, and the view-and-translation layer every
statement of claim (b) is written through, in a new section of the existing module.

**Tasks**:
- [ ] Open a new `/-! ## The canonical frames' characterizations -/` section at the end of
      `FormalSystem/Semantics/Correspondence/DurationFrames.lean`, before the closing
      `end FormalSystem.Semantics`, with a short section note stating that what follows is the
      paper lemma's four claims and citing both anchors by name
- [ ] `translationFrame_deterministic`: the determinism predicate for the translation frame, by
      the functional-fibre lemma at the addition function, with the relation bridge supplied
      pointwise. Docstring cites the lemma anchor, records that this generalises the real
      instance's own determinism result to every temporal order, and records the measured trap:
      the raw singleton-fibre fact in `Frames/Standard.lean` does **not** apply directly, because
      its fibre argument is the bare relation and the two do not unify at the transparency the
      fibre motive's elaboration uses
- [ ] `translationStates`: the view definition taking a world history of the translation frame to
      a function on the duration carrier, as `τ.state`. Docstring states why it exists — the
      world-state type does not synthesize arithmetic instances, so a statement about state
      arithmetic is written through this view and never through a type ascription (both measured)
      — and cites the bare-path view in `Semantics/IntNormalForm.lean` as the house precedent
- [ ] `translationSigma`: the translation by a duration, defined as the reference history's time
      shift by that duration. Docstring records that defining it this way, rather than building a
      fresh total history, is what keeps the non-elaborating `+` out of the definition entirely
- [ ] `translationSigma_states` and `translationHist_states`: the two `@[simp]` state readings,
      each by `rfl`
- [ ] `translationSigma_zero`: the translation by zero is the reference history, by state
      extensionality through the view
- [ ] `translationStates_eq`: the pointwise law that a translation-frame history's state at a time
      is its state at zero plus that time, from the relation bridge at the history's own
      task-respecting field
- [ ] `translation_eq_sigma`: every translation-frame history is the translation by its own state
      at zero
- [ ] Bind the duration group explicitly in each signature, as `(D : TemporalOrder)` or
      `{D : TemporalOrder}` per the Challenge Statements block below; do **not** introduce a
      module-level `variable` line, which the target module deliberately does not have
- [ ] Commit each verified-green sub-step separately via the scoped-commit script, naming only
      this one file

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase touches exactly one file and adds exactly
eight declarations — one for claim (a) and seven for the view-and-translation layer — counted
from the research report's Appendix and re-counted at plan time against that Appendix's
declaration list. Confirm at implementation time with
`git diff --stat -- FormalSystem/Semantics/Correspondence/DurationFrames.lean` naming one file,
and by `grep -c '^theorem \|^def \|^@\[simp\] theorem ' ` over the appended section reporting
eight.

**Tier Justification**: `local` because every declaration is a strictly additive, new name inside
one module with no change to any existing signature, so the specific covering check is the
guarded scoped build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - new characterizations section opened; claim (a) plus the two view definitions, the translation definition, the two state lemmas, the zero lemma, the pointwise law and the translation identity

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
  exits 0, detached, with the guard's exit captured un-piped
- The build output carries no linter finding and no `sorry` warning for the appended section;
  `grep -c 'sorry' ` over the appended lines reports zero
- `#print axioms` on `translationFrame_deterministic` and `translation_eq_sigma` reports no
  choice axiom
- Each elaborated signature matches the corresponding declaration in the Lean Challenge
  Statements section below, binder for binder
- `git status --short` names only this file among this task's files; any foreign modification is
  reported rather than reconciled

---

### Phase 3: Claim (b)'s three user-facing forms [NOT STARTED]

**Goal**: State the paper's own claim — that the possible worlds of the translation frame are
exactly the translations — in the three forms a consumer would want: an equivalence, a set
equation, and a uniqueness statement.

**Tasks**:
- [ ] `translationHistEquiv`: the equivalence between the translation frame's world histories and
      the duration carrier, with the forward map taking a history to its state at zero, the
      inverse taking a duration to its translation, the left inverse from Phase 2's translation
      identity, and the right inverse by the zero law. Record in the docstring that the right
      inverse needs a `show` to beta-reduce before rewriting (measured)
- [ ] `translation_histSet_eq`: the paper's set equation, as the range of the translation map
      being the whole world-history set. Docstring quotes nothing from the paper and cites the
      lemma anchor by name, stating that this is the Lean reading of the paper's own displayed
      equation for the frame's history set
- [ ] `translation_exists_unique`: every history is the translation by a unique duration
- [ ] Add a short docstring note on the equivalence recording that it is the form that makes the
      possible-world count of the translation frame exactly the duration count, which is what the
      paper's countermodel arguments use
- [ ] Commit each verified-green sub-step separately via the scoped-commit script

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase adds exactly three declarations to the
same single file, counted from the research report's Appendix. Confirm at implementation time by
`git diff --stat` naming one file and by the three names resolving under
`grep -n 'translationHistEquiv\|translation_histSet_eq\|translation_exists_unique'`.

**Tier Justification**: `local` because the three declarations are additive names inside the one
module Phase 2 already extended, changing no existing signature, so the specific covering check
is the guarded scoped build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - the equivalence, the set equation and the uniqueness statement appended to the characterizations section

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
  exits 0, detached
- No linter finding and no `sorry` in the appended lines
- Each elaborated signature matches the Challenge Statements block, binder for binder
- `git status --short` names only this file among this task's files

---

### Phase 4: Claim (c), both halves, at the bare relation [NOT STARTED]

**Goal**: Prove that the permissive relation on the two-state carrier satisfies the task-frame
constraints exactly when the duration order is Discrete — the Limit constraint holding under a
least positive duration and failing under density — and tie the relation-level statement back to
the frame.

**Tasks**:
- [ ] `permRel` and `permRel_iff`: the bare permissive relation on the two-state carrier and its
      definitional bridge. Docstring states why claim (c) is stated here rather than at the
      frame: the frame cannot be formed without the successor-order and no-maximum data that
      discreteness itself supplies, so a frame-level biconditional is not well formed
- [ ] `permissiveFrame_taskRel_eq`: the permissive frame's own task relation **is** this relation,
      by the reflective-regular constructor's relation equation. Docstring records that without
      this lemma the biconditionals below would be statements about a lookalike relation rather
      than about the frame
- [ ] `permRel_reflection`: reflection holds unconditionally, recorded so the reader sees which of
      the frame constraints is not at issue in the biconditional
- [ ] `permRel_limit_of_isLeast`: Limit holds given a least positive duration
- [ ] `permRel_not_limit_of_dense`: Limit fails over a densely ordered carrier, with the two-state
      witness. Docstring records that this machine-checks the sentence the permissive-Limit lemma's
      own docstring in `Semantics/TaskFrame.lean`'s neighbourhood already asserts in prose
- [ ] `isDiscrete_iff_exists_isLeast_pos`: discreteness is equivalent to the existence of a least
      positive duration, each direction one line — the forward direction instantiating the
      nontrivial-positive-duration lemma at zero, the reverse by the successor-is-least lemma in
      `Semantics/DurationClassification.lean`. Docstring records that the frame-property module's
      own discreteness docstring flags this equivalence as something that should be a proof step
      rather than a definitional assumption, and that this is that proof step
- [ ] `permRel_limit_iff_isDiscrete`: Limit for the permissive relation is equivalent to
      discreteness, via the density dichotomy
- [ ] `permRel_constraints_iff_isDiscrete`: the four task-frame constraints conjoined are
      equivalent to discreteness. Docstring states explicitly that this conjunction — not the
      Limit constraint alone — is the honest Lean reading of the paper's "is a task frame just in
      case", and that the other three constraints hold unconditionally
- [ ] Commit each verified-green sub-step separately via the scoped-commit script

**Timing**: 1.75 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase adds exactly nine declarations to the same
single file, counted from the research report's Appendix, and that none of them needs a new import
— every lemma they cite is already in the module's import closure through
`Frames/Standard.lean` and `DurationClassification`. Confirm at implementation time by
`git diff --stat` naming one file, and by the build succeeding with the module's import block
untouched (`git diff` showing no hunk above the characterizations section).

**Tier Justification**: `local` because all nine declarations are additive names inside the one
module, with no new import and no change to any existing signature, so the specific covering check
is the guarded scoped build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - claim (c): the bare relation, its definitional bridge, the frame tie-back, the unconditional reflection record, the two Limit halves, the discreteness equivalence, and the two headline biconditionals

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
  exits 0, detached
- No linter finding and no `sorry` in the appended lines
- `git diff` shows no hunk in the module's import block
- Each elaborated signature matches the Challenge Statements block, binder for binder
- `git status --short` names only this file among this task's files

---

### Phase 5: Claim (d), non-determinism and the assignment equivalence [NOT STARTED]

**Goal**: Prove that the two-state frame, where it is a task frame, is not Deterministic, and that
its possible worlds are exactly the assignments from durations to its two states.

**Tasks**:
- [ ] `permissiveFrame_not_deterministic`: the frame fails determinism, by exhibiting both states
      in one fibre over a positive duration — the two fibre memberships supplied by the frame's
      own relation bridge. Docstring cites the lemma anchor and records that the positive duration
      comes from the nontriviality of the duration group, so the refutation needs no extra
      hypothesis
- [ ] `permissiveStates`: the view definition taking a world history of the permissive frame to an
      assignment, for the same measured reason the translation view exists
- [ ] `permissiveHistEquiv`: the equivalence between assignments and world histories, forward by
      the module's existing reference history for an arbitrary assignment, inverse by the view,
      left inverse by `rfl` and right inverse by state extensionality. Docstring records that the
      left inverse's `rfl` depends on the reference history's state function being definitionally
      the assignment, and that a future change breaking that would break this proof loudly rather
      than silently
- [ ] Record in the docstring that this equivalence is the half of claim (d) the module already
      had in substance — the reference history for an arbitrary assignment — now stated as the
      bijection the paper asserts
- [ ] Commit each verified-green sub-step separately via the scoped-commit script

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase adds exactly three declarations to the
same single file, counted from the research report's Appendix. Confirm at implementation time with
`git diff --stat` naming one file and the three names resolving by grep.

**Tier Justification**: `local` because the three declarations are additive names inside the one
module with no change to any existing signature, so the specific covering check is the guarded
scoped build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - claim (d): the non-determinism refutation, the permissive view, and the assignment-to-history equivalence

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
  exits 0, detached
- No linter finding and no `sorry` in the appended lines
- `#print axioms` on `permissiveFrame_not_deterministic` reports no choice axiom
- Each elaborated signature matches the Challenge Statements block, binder for binder
- `git status --short` names only this file among this task's files

---

### Phase 6: Documentation surface [NOT STARTED]

**Goal**: Make the new characterizations findable from the module header and the component README,
and correct the one sentence elsewhere in the tree that now reads as misleading.

**Tasks**:
- [ ] Extend the module header's main-results list in
      `FormalSystem/Semantics/Correspondence/DurationFrames.lean` with the new keystone names:
      the determinism result, the world-history equivalence and set equation, the two headline
      permissive biconditionals, the non-determinism refutation and the assignment equivalence
- [ ] Add a paragraph to the same module header explaining that this module now carries the
      canonical-frame characterizations as well as the correspondence witnesses, citing both paper
      anchors by name and quoting neither; state in one sentence why claim (c) is stated at the
      bare relation and what the tie-back lemma does
- [ ] Add the lemma anchor to the module header's tags line, in the style of the existing tags
- [ ] Update the `DurationFrames.lean` row in `FormalSystem/Semantics/Correspondence/README.md`:
      extend the description to name the four claims and the keystone declarations, and refresh
      the row's line-count cell and the file's last-verified date. Re-derive the line count with
      `wc -l` rather than estimating it — the cell is hand-maintained in this README (it carries
      no machine-owned generated block), and it was already stale before this task
- [ ] Amend the one-sentence claim in
      `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean`'s module header that the
      world-set characterization "is exactly the statement that fails to elaborate" on the
      translation route: add one sentence naming the view definition and the general result that
      now proves the analogue, and keep that module's own justification for the shift-set route
      intact — it does not depend on the amended sentence
- [ ] Commit the module-header-and-README hunks and the independence-module hunk as separate
      sub-steps via the scoped-commit script

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase touches exactly three files, that every
hunk lies inside a module docstring or a README table row, and that no declaration, signature or
proof is changed anywhere. Confirm at implementation time with `git diff --stat` naming exactly
those three paths, and by reading the diff for any hunk outside a comment or markdown region.

**Tier Justification**: `local` because Lean module headers are real syntax with an elaboration
surface rather than inert prose — a malformed comment breaks the build — so the covering checks
are the two guarded scoped builds
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
and the same form for `FormalSystem.Metalogic.Independence.RealTranslationFrame`, read together
with the diff read-through and `bash scripts/readme-lint.sh`.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` - module header: main-results list extended, a canonical-frames paragraph added, tags line extended
- `FormalSystem/Semantics/Correspondence/README.md` - the module's Contents row: description extended, line-count cell re-derived, last-verified date refreshed
- `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean` - one sentence added to the module header correcting the reading of its symptom paragraph

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
  exits 0, detached
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.RealTranslationFrame`
  exits 0, detached
- `bash scripts/readme-lint.sh` runs and its exit status is read directly; any finding on the
  touched README is this task's to fix, any finding elsewhere is pre-existing and recorded, not
  absorbed
- `bash scripts/check-module-invariants.sh --no-build` reports its docstring-coverage check at or
  above its floor, and its anchor-integrity check passing on the new citations
- `git diff` read through: every hunk lies inside a module docstring or a markdown table row

---

### Phase 7: Entry baseline, full gate set, and the generated counts [NOT STARTED]

**Goal**: Close the task against the complete repository gate set, honestly — by re-deriving the
entry baseline first, because the gate set is already red from causes outside this task and is
moving under concurrent sibling writes — and regenerate the whole-tree count files this task's
line growth drifts, without absorbing a sibling's drift.

**Tasks**:
- [ ] **Re-derive the entry baseline first, before any regeneration.** Run
      `bash scripts/check-module-invariants.sh` (build-enabled) and capture its exit status and
      the full list of failing checks by name; run `bash scripts/typst-sync-check.sh --counts-only`
      and capture its mismatch list; run `bash scripts/readme-lint.sh` and
      `bash scripts/check-copyright-headers.sh --strict FormalSystem` and capture both exit
      statuses. Record the baseline in the issue log as a `kind: issue`,
      `class: pre-existing gate state`, severity `none`
- [ ] Run the full unscoped build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached, with the
      guard's exit captured un-piped. It must exit 0. A failure in a file outside this task's
      scope is checked against `git log` and `git status` before attribution and reported rather
      than reconciled
- [ ] Confirm the no-new-`sorry` constraint directly:
      `grep -rn 'sorry' FormalSystem/Semantics/Correspondence/DurationFrames.lean` reports
      nothing, and the invariants script's zero-structural-`sorry` check passes
- [ ] **Decision gate on the whole-tree generated counts.** Re-read the root `README.md` and
      `typst/generated/status.typ` and run `git status --short` for both. Both are in a
      concurrently dispatched sibling's declared territory, and both carry whole-tree counts:
      - If no sibling has uncommitted or staged Lean changes at that moment: run
        `bash scripts/check-module-invariants.sh --emit-inventory` and
        `bash scripts/typst-sync-check.sh --fix`, then stage and commit `README.md` and
        `typst/generated/status.typ` **each alone by explicit path** via the scoped-commit script.
        Record in the issue log that the committed counts are whole-tree values that absorb a
        pre-existing drift as well as this task's line growth, with the before and after numbers
      - If a sibling does have uncommitted or staged Lean changes: **defer both regenerations**,
        commit neither file, and record the deferral in the issue log and in the implementation
        summary, naming the drift magnitude this task contributes. A generated whole-tree count is
        a function of the tree, not of this task, and baking a sibling's in-flight lines into this
        task's commit is worse than leaving a machine-owned file stale for one cycle
      - Either way, never hand-edit a generated block or a generated count field
- [ ] If `bash scripts/check-module-invariants.sh --emit-inventory` also rewrites a generated
      block in a file this task does not own (measured at plan time: one such file in a sibling's
      declared territory), do **not** stage or commit that file. Leave it, record it in the issue
      log, and name it in the summary as a pre-existing staleness belonging to another task's
      territory
- [ ] Run the complete gate set and record each exit status individually:
      `bash scripts/check-module-invariants.sh`, `bash scripts/typst-sync-check.sh`,
      `bash scripts/readme-lint.sh`,
      `bash scripts/check-copyright-headers.sh --strict FormalSystem`, and
      `bash .claude/scripts/verify-deploy.sh`
- [ ] Record the paper-side follow-up for the author in the implementation summary: clear the PORT
      marker under the lemma in the paper source and close its proof with a Lean-proof citation
      naming `FormalSystem.Semantics.Correspondence.DurationFrames`'s new declarations, one per
      claim. That is an edit in a different repository and is deliberately not performed here
- [ ] Record the context-extension recommendation the research round surfaced, in the summary: a
      note on the frame-carrier transparency barrier and the view repair belongs in the Lean
      context directory, as its own follow-up rather than a drive-by write under a deployed tree
- [ ] Write the implementation summary to
      `specs/790_lem_canonical_frames_translation_two_state/summaries/01_lem-canonical-frames-characterizations-summary.md`

**Timing**: 1.25 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this task's own Lean edit grows
`FormalSystem/Semantics/Correspondence/DurationFrames.lean` from 435 lines (re-derived at plan
time with `wc -l`) to roughly 620 lines — the upper figure carried from the research report's
placement decision and not independently re-derived — and that this growth is the only reason
either whole-tree count file drifts on this task's account. Confirm at implementation time with
`wc -l` on the file and by `git diff` on each generated file showing only count fields changed;
any non-count hunk in a generated file is a sibling's work, not this task's, and is the trigger
for the deferral branch above.

**Files to modify**:
- `README.md` - `dir=FormalSystem` generated inventory block regenerated, never hand-edited (CONDITIONAL on the decision gate; SHARED TOUCH: re-read immediately before editing, stage alone)
- `typst/generated/status.typ` - generated whole-tree count fields regenerated, never hand-edited (CONDITIONAL on the decision gate; SHARED TOUCH: re-read immediately before editing, stage alone)
- `specs/790_lem_canonical_frames_translation_two_state/summaries/01_lem-canonical-frames-characterizations-summary.md` - the implementation summary

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project,
  unscoped) exits 0, detached, with the guard's exit captured un-piped
- `bash scripts/check-module-invariants.sh` runs with its exit status read directly, and its
  failing-check set is a **subset** of the entry baseline captured at the start of this phase. In
  addition, and by name, these checks pass individually: zero structural `sorry`, every import
  resolves, no linter finding beyond the recorded allowlist, docstring coverage at or above its
  floor, zero live `lemma`, and both anchor-integrity assertions
- `bash scripts/typst-sync-check.sh` runs with its exit status read directly; its mismatch set is
  a subset of the entry baseline's, or empty if the regeneration branch was taken
- `bash scripts/readme-lint.sh` exits 0, or its findings are a subset of the entry baseline's
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- `bash .claude/scripts/verify-deploy.sh` — the complete repository gate set this tier requires —
  runs with its exit status read directly and no new failure relative to the entry baseline
- Every command's exit status is checked directly; a diff of captured stdout against a baseline is
  not accepted as evidence for any of them
- `#print axioms` on one declaration per claim reports no choice axiom
- `git log --oneline` shows this task's commits only, with no foreign commit attributed to this
  task, and every commit made through `bash .claude/scripts/git-commit-scoped.sh`

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.Correspondence.DurationFrames

namespace FormalSystem.Semantics

open FormalSystem.Syntax

/-- (a) The translation frame is Deterministic, over every temporal order. -/
theorem translationFrame_deterministic (D : TemporalOrder) :
    (translationFrame D).toTaskFrame.Deterministic := sorry

/-- The bare state function of a translation-frame history, retyped at the duration carrier. -/
def translationStates {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) : ↑D → ↑D := sorry

/-- (b) The translation by `c`, as the reference history shifted by `c`. -/
def translationSigma (D : TemporalOrder) (c : ↑D) :
    WorldHistory (translationFrame D).toTaskFrame := sorry

theorem translationSigma_states (D : TemporalOrder) (c t : ↑D) :
    translationStates (translationSigma D c) t = t + c := sorry

theorem translationHist_states (D : TemporalOrder) (t : ↑D) :
    translationStates (translationHist D) t = t := sorry

theorem translationSigma_zero (D : TemporalOrder) :
    translationSigma D 0 = translationHist D := sorry

theorem translationStates_eq {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) (t : ↑D) :
    translationStates τ t = translationStates τ 0 + t := sorry

theorem translation_eq_sigma {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) :
    τ = translationSigma D (translationStates τ 0) := sorry

/-- (b) The world histories of the translation frame are exactly the durations. -/
def translationHistEquiv (D : TemporalOrder) :
    WorldHistory (translationFrame D).toTaskFrame ≃ ↑D := sorry

/-- (b) The paper's set equation for the translation frame's history set. -/
theorem translation_histSet_eq (D : TemporalOrder) :
    Set.range (translationSigma D)
      = (Set.univ : Set (WorldHistory (translationFrame D).toTaskFrame)) := sorry

theorem translation_exists_unique {D : TemporalOrder}
    (τ : WorldHistory (translationFrame D).toTaskFrame) :
    ∃! c : ↑D, τ = translationSigma D c := sorry

/-- (c) The permissive relation on the two-state carrier, stated at the bare relation. -/
def permRel (D : TemporalOrder) : Bool → ↑D → Bool → Prop := sorry

theorem permRel_iff (D : TemporalOrder) (w : Bool) (d : ↑D) (u : Bool) :
    permRel D w d u ↔ (d ≠ 0 ∨ w = u) := sorry

/-- (c) The tie-back: the two-state frame's own task relation is the permissive relation. -/
theorem permissiveFrame_taskRel_eq (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    (permissiveFrame D so nm).TaskRel = permRel D := sorry

theorem permRel_reflection (D : TemporalOrder) :
    ∀ w (d : ↑D) u, permRel D w d u ↔ permRel D u (-d) w := sorry

theorem permRel_limit_of_isLeast {D : TemporalOrder} {p : ↑D}
    (hp : IsLeast {x : ↑D | 0 < x} p) : TaskFrame.Limit (permRel D) := sorry

theorem permRel_not_limit_of_dense (D : TemporalOrder) (hd : DenselyOrdered ↑D) :
    ¬ TaskFrame.Limit (permRel D) := sorry

theorem isDiscrete_iff_exists_isLeast_pos (D : TemporalOrder) :
    (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y')
      ↔ ∃ p : ↑D, IsLeast {x : ↑D | 0 < x} p := sorry

theorem permRel_limit_iff_isDiscrete (D : TemporalOrder) :
    TaskFrame.Limit (permRel D)
      ↔ (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y') := sorry

/-- (c) The four task-frame constraints hold for the permissive relation iff `D` is Discrete. -/
theorem permRel_constraints_iff_isDiscrete (D : TemporalOrder) :
    (TaskFrame.Compositional (permRel D) ∧ TaskFrame.Serial (permRel D)
        ∧ TaskFrame.Limit (permRel D) ∧ TaskFrame.Saturation (permRel D))
      ↔ (∀ x : ↑D, (∃ y, x < y) → ∃ y', IsLeast {z : ↑D | x < z} y') := sorry

/-- (d) The two-state frame is not Deterministic. -/
theorem permissiveFrame_not_deterministic (D : TemporalOrder) (so : SuccOrder ↑D)
    (nm : NoMaxOrder ↑D) : ¬ (permissiveFrame D so nm).toTaskFrame.Deterministic := sorry

/-- The bare state function of a two-state-frame history, retyped as an assignment. -/
def permissiveStates (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (τ : WorldHistory (permissiveFrame D so nm).toTaskFrame) : ↑D → Bool := sorry

/-- (d) Every assignment from durations to the two states is a possible world, bijectively. -/
def permissiveHistEquiv (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) :
    (↑D → Bool) ≃ WorldHistory (permissiveFrame D so nm).toTaskFrame := sorry

end FormalSystem.Semantics
```

Three notes on this block, so the implementation does not read it as more than it is. First, the
`sorry` bodies pin statements only, exactly as this section's format requires; the proofs are in
the research report's Appendix, already compiled. Second, the attributes are deliberately omitted
here: the landed `translationSigma_states`, `translationHist_states` and `translationSigma_zero`
carry `@[simp]`, which pins no statement and so has no place in a Challenge module. Third, the
binders are written in the target module's own explicit style rather than the research probes'
module-level `variable` style — same elaborated signatures, and this is the form the
implementation should transcribe.

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Correspondence.DurationFrames`
      exits 0 after each of Phases 2, 3, 4, 5 and 6
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.RealTranslationFrame`
      exits 0 after Phase 6
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project,
      unscoped) exits 0 in Phase 7
- [ ] All 23 declarations named under Goals exist, with the signatures pinned in the Lean
      Challenge Statements section, and none carries a `sorry`
- [ ] `grep -rn 'sorry' FormalSystem/Semantics/Correspondence/DurationFrames.lean` reports nothing
- [ ] `#print axioms` on at least one declaration per claim reports no choice axiom
- [ ] Neither frame's definition in `FormalSystem/Semantics/Frames/Standard.lean` is modified:
      `git diff -- FormalSystem/Semantics/Frames/Standard.lean` is empty for the whole task
- [ ] `bash scripts/check-module-invariants.sh` runs with its exit status read directly, its
      failing-check set a subset of the Phase 7 entry baseline, and its anchor-integrity,
      structural-`sorry`, import-resolution, linter, docstring-coverage and live-`lemma` checks
      passing by name
- [ ] `bash scripts/typst-sync-check.sh` mismatch set is a subset of the entry baseline's, or
      empty if the regeneration branch was taken
- [ ] `bash scripts/readme-lint.sh` and
      `bash scripts/check-copyright-headers.sh --strict FormalSystem` exit statuses recorded
- [ ] `bash .claude/scripts/verify-deploy.sh` shows no new failure relative to the entry baseline
- [ ] Every commit was made through `bash .claude/scripts/git-commit-scoped.sh` with an explicit
      file list; `git log --oneline` attributes no foreign work to this task

## Artifacts & Outputs

- `FormalSystem/Semantics/Correspondence/DurationFrames.lean` — the 23 new declarations in a new
  characterizations section, plus the extended module header
- `docs/reference/paper-definitions-of-record.md` — two unpinned known-anchor rows
- `FormalSystem/Semantics/Correspondence/README.md` — the module's Contents row, extended and its
  line count re-derived
- `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean` — one corrected sentence in the
  module header
- `README.md` and `typst/generated/status.typ` — regenerated whole-tree counts, conditional on
  Phase 7's decision gate
- `specs/790_lem_canonical_frames_translation_two_state/summaries/01_lem-canonical-frames-characterizations-summary.md`
  — the implementation summary, carrying the Phase 7 entry baseline, the gate-set outcome, the
  deferred paper-side follow-up and the context-extension recommendation
- `specs/790_lem_canonical_frames_translation_two_state/issues.jsonl` — issue-log entries recorded
  as they arise

## Rollback/Contingency

The Lean work is strictly additive to one file, so the cheapest contingency is always to fix
forward: the whole task's Lean surface is one appended section, and any single declaration that
will not transcribe can be dropped from that section and recorded as a reasoned exclusion without
touching anything else. Nothing in this plan changes an existing signature, so no downstream
module can break.

Three contingencies, by what fails:

- **A declaration will not transcribe as written.** The research round compiled all 23, so the
  likeliest cause is the binder-form adaptation or the transparency barrier. Re-derive the
  statement through a view definition, never a type ascription (measured as non-repairable). If
  it still resists, close the phase with the declaration excluded, record the exclusion with the
  measured error as its evidence, and keep the remaining declarations — each claim's keystone
  result stands independently of the others' convenience lemmas.
- **The anchor record edit collides with a concurrent writer.** Report the foreign modification
  rather than reconciling it, and defer the Lean phases: without the record rows, a citing
  docstring makes the anchor-integrity check fail, so the ordering is a hard dependency, not a
  preference.
- **An uncommitted state must genuinely be rolled back.** Do not reach for a bare precautionary
  snapshot: take the snapshot-then-rollback route in `context/contracts/recovery.md`'s rollback
  rung, which names the exact invocation including its out-of-scope override, and only after
  confirming via `git status` that the changes to be discarded are this task's own. A
  concurrently dispatched sibling has work staged in the shared index, so a whole-tree rollback
  would destroy another task's work — scope every rollback to this task's own files by explicit
  path, or do not run it.
