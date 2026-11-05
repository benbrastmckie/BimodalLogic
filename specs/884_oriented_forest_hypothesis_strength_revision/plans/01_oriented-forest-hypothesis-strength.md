# Implementation Plan: Task #884

- **Task**: 884 - Oriented-forest hypothesis strength revision
- **Status**: [IMPLEMENTING]
- **Effort**: 2.8 hours
- **Dependencies**: None (task 870 depends on *this* task; the edge already exists in `specs/state.json`)
- **Research Inputs**: None dispatched. Evidence of record is pre-existing:
  `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
  §1.2 (the construction, its steps 1-5, and its 2026-11-05 hypothesis-strength flag note) and
  `specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`
  finding 1, decision 7, recommendation R1, and finding 7's (H5).
- **Artifacts**: plans/01_oriented-forest-hypothesis-strength.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

This task is a *record-and-statement* repair, not a proof task: no Lean file is edited and no new
Lean lemma is proved here. It pins the oriented-forest hypothesis at the strength the ZTime
decidability argument actually consumes, verifies (rather than assumes) that the strengthening
costs nothing on the `Saturation` side, makes the load-bearing multigraph convention explicit
where the strengthened hypothesis depends on it, and then revises the owning task's record so the
lemma that eventually lands is stated at that strength.

The defect is a gloss mismatch, already measured. Report 03 §1.2 names its cover an "oriented
forest" and glosses that as *directed-path uniqueness*, but its own step 4 takes the **undirected**
tree path between `a_m` and `a'` and that path's unique sink `m` — which needs the **underlying
undirected (multi)graph to be a forest**, strictly more than directed-path uniqueness. Task 870's
record carries the weak gloss verbatim ("a frame in which directed paths between any two nodes are
unique"), so a lemma landing at that hypothesis would not discharge (H5), on which the whole L⁺
ZTime decidability theorem is conditional and which has no unconditional form.

### Research Integration

No research phase ran for this round and none is needed: the mismatch is already derived and
written down in two places, with the derivation, the consequence, and the recommended remedy all
on record (report 03 §1.2's note; report 01 finding 1's second precision note, decision 7, and
R1). This plan consumes those as inputs and performs the filing R1 explicitly left to 870's owner
or the user. One genuine open item remains for implementation rather than for research: whether
the `Saturation` side is affected, which the task description directs be *verified* rather than
assumed — Phase 2 does that by reading the compiled signatures, not by recall.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` already carries the strengthened statement in its `870` run-order annotations
(lines 142 and 191: "State it at oriented-forest strength (underlying undirected graph is a
forest), not directed-path uniqueness alone") and in its (H5) entry (line 124). That propagation
was done by task 878's dispatch. **No ROADMAP edit is in this task's scope**, and `specs/ROADMAP.md`
is deliberately absent from this task's `file_scope`. Phase 4 reads those annotations only to
confirm the revised 870 record does not contradict them.

## Goals & Non-Goals

**Goals**:
- Pin one precise statement of the oriented-forest hypothesis, over a bare task relation, at the
  strength report 03 §1.2 step 4 consumes, together with a step-by-step map of which of §1.2's
  steps 1-5 consume which strength.
- Verify from the compiled sources — not from recall — whether strengthening the hypothesis adds
  any obligation on the `Saturation` side, given that `FrameOver.IsRegular` bundles
  `TaskFrame.Saturation` and `plus_invariance_of_isZTime` therefore demands it of *both* frames.
- Make explicit, where the strengthened hypothesis rests on it, that the cover is taken as an
  orientation-keeping undirected **multigraph**, and that this is what rules out loops, parallel
  edges, and opposite-edge pairs.
- Revise task 870's own record so its stated hypothesis matches what its consumer needs.

**Non-Goals**:
- Proving the oriented-forest `Saturation` lemma, or writing any Lean. That is task 870's work and
  stays there; `FormalSystem/**` is outside this task's `file_scope` and must not be touched.
- Defining a Lean `IsOrientedForest` predicate. Phase 1 fixes the *statement*; choosing its Lean
  encoding is 870's own first design step.
- Editing `specs/878_.../reports/01_...` or `specs/ROADMAP.md`. 878's finding 7 already states
  (H5) at oriented-forest strength in words ("every doubly serial oriented forest over `ℤ`
  satisfies `TaskFrame.Saturation`"), so it needs no repair; ROADMAP is already propagated. Both
  are outside `file_scope`.
- Re-deriving §1.2's construction or §1.3's steps. §1.2's claim and construction stand; only its
  gloss is being tightened.
- Resolving gaps G1 or G2, or any other open item in §1.3. Out of scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The strengthened hypothesis turns out *not* to be discharged by §1.2's own cover construction, which would break Step A rather than merely restate it | H | L | Phase 2 checks this head-on: the universal cover of a connected undirected multigraph is a tree, and a disjoint union of trees is a forest, so the cover delivers the strong hypothesis directly. If the check fails, stop and escalate with `user_decision` rather than filing a revision that silently weakens (H5) |
| The multigraph convention is dropped downstream, letting an opposite-edge pair `u → v`, `v → u` back in — which is an undirected 2-cycle, so step 4's unique sink fails | H | M | Phase 3 states the convention and its three consequences (no loops, no parallel edges, no directed 2-cycles) at the point where the hypothesis is stated, not only in the construction prose |
| `/revise 870` is not invokable from an implementation dispatch, leaving 870's description unrevised | M | M | Phase 4 names the exact mechanical fallback skill-reviser Stage 7 itself uses for a description update (`state-write.sh` with `--regen-todo`); the fallback is equivalent, not a shortcut |
| A sibling task (871 research, 867 research — both dispatched this same cycle) edits `specs/state.json` or `specs/TODO.md` concurrently | M | M | Per the dispatch's territory note: re-read immediately before writing, use `state-write.sh` (which takes the lock) rather than hand-editing, stage only this task's own hunks, never `git add -A`/a directory pathspec |
| The revision is read as a change to §1.2's *claim* rather than to its *gloss* | M | L | The Phase 1 amendment says in its own first sentence that §1.2's claim and construction are unchanged and that only the gloss is tightened, mirroring the existing note's self-limiting phrasing |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan has no parallelism: it is a strict
chain by construction. Phase 2's verification can change the statement Phase 1 pins (that is the
point of verifying rather than assuming), Phase 3's convention text attaches to the pinned
statement, and Phase 4's record revision must quote the result of all three. Serializing is the
honest wave map here, not a missed optimization.

---

### Phase 1: Pin the restated hypothesis and its consumption map [COMPLETED]

**Goal**: One precise statement of the hypothesis, plus an explicit per-step map of which of
report 03 §1.2's steps 1-5 consume which strength, written into §1.2 as a dated, derived
resolution amendment to the note already standing there.

**Tasks**:
- [x] Re-read `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
      §1.2 (lines ~137-190) in full, including the existing 2026-11-05 hypothesis-strength flag
      note, immediately before editing. *(completed)*
- [x] State the hypothesis over a bare task relation, in the shape the existing `Saturation`
      lemmas use (`{W : Type} {R : W → D → W → Prop}`, as at `FormalSystem/Semantics/TaskFrame.lean:2194`
      and `:2235`): the **underlying undirected multigraph of `R`'s one-step edge relation is a
      forest** (acyclic). Record that this implies directed-path uniqueness — between two nodes
      there is at most one undirected path, hence at most one directed path — so the strengthened
      hypothesis subsumes the stated one and nothing already claimed is lost. *(completed)*
- [x] Record that the condition is on the underlying undirected **multigraph**, not on its
      simplification: a base pair of opposite edges `u → v`, `v → u` is a pair of parallel
      undirected edges, i.e. a 2-cycle, and a loop `u → u` is a 1-cycle. Stating acyclicity of the
      *simple* underlying graph would readmit both and break step 4. *(completed)*
- [x] Write the consumption map: steps 1-3 consume only directed-path uniqueness (step 1's
      segment-subsingleton argument, step 3's at-most-one-shared-element argument between a
      forward and a backward fibre); **step 4 consumes undirected acyclicity** — it takes the
      reduced (undirected) path between `a_m` and `a'` and that path's unique sink `m`, and needs
      `m` to be independent of `x`; step 5 is bookkeeping. *(completed)*
- [x] Append the result to §1.2 as a dated amendment immediately after the existing note,
      explicitly resolving what that note flagged. State in the amendment's own first sentence
      that §1.2's claim and construction are unchanged and only the gloss is tightened. *(completed)*
- [x] Do **not** choose a Lean encoding (`SimpleGraph.IsAcyclic` on a symmetrization, an inductive
      forest predicate, or a bespoke `Prop`); a grep confirms no oriented-forest or acyclicity
      predicate exists in `FormalSystem/**` today, and the encoding choice is 870's. Say so in one
      sentence rather than leaving the omission unexplained. *(completed: confirmed via grep, no
      occurrence of IsOrientedForest/acyclic predicate in FormalSystem/**)*

**Timing**: 0.8 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: Every touched path is the single markdown report artifact
`specs/559_.../reports/03_axiomatizability-rules-engine.md`, which has no executable surface, so
the covering check is `bash .claude/scripts/validate-artifact.sh specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md report`
plus the `prose` row's diff read-through (plan-format.md's `__FULL_SWEEP__` sub-case (a), the
`specs/**` case).

**Scope Hypothesis**: This phase is asserted to touch exactly one file and to add one amendment
block of roughly 15-25 lines with no deletion from §1.2's existing text. Confirm at
implementation time with `git diff --stat` on the single path before committing; if the edit turns
out to require changing §1.2's existing steps 1-5 prose rather than only appending to it, that is
a scope change — record it in the issue log and report it, do not absorb it silently.

**Files to modify**:
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` -
  append a dated, derived resolution amendment to §1.2's existing hypothesis-strength note,
  carrying the restated hypothesis and the per-step consumption map

**Verification**:
- The amendment states the hypothesis as acyclicity of the underlying undirected **multigraph**,
  and says so in those words.
- The amendment names step 4 explicitly as the step that consumes undirected acyclicity, and names
  at least one step that consumes only directed-path uniqueness.
- The amendment asserts that §1.2's claim and construction are unchanged.
- `validate-artifact.sh ... report` exits 0 (or its exit is a counted warning with no new finding
  attributable to this edit).
- `git diff` shows no deletion inside §1.2's steps 1-5.

---

### Phase 2: Verify the Saturation side rather than assume it [COMPLETED]

**Goal**: Establish from the compiled sources whether strengthening the hypothesis adds any
obligation on the `Saturation` side, and record the three findings that settle it.

**Tasks**:
- [x] Read the `FrameOver.IsRegular` declaration and confirm from source that it bundles
      `TaskFrame.Saturation` as a field (`FormalSystem/Semantics/FrameClassValidity.lean:146`
      names `F.saturation` as one of the four projections the class supplies; locate and read the
      class declaration itself rather than inferring from that reference). *(completed: class
      declared at FormalSystem/Semantics/TaskFrame.lean:1185, `saturation` field at :1209)*
- [x] Read `TwoWayBounded.plus_invariance_of_isZTime` at `FormalSystem/Semantics/.../HistoryMorphism.lean:589`
      and confirm its binders are `[F'.IsRegular] [F.IsRegular]` — i.e. that `Saturation` is
      demanded of the **base** frame as well as the cover. This is the fact that forced 878's
      cover-first reordering and is the reason the question is being asked at all. *(completed:
      confirmed at :590)*
- [x] Derive and record: **induced sub-digraphs inherit the strengthened hypothesis**. An induced
      subgraph of an acyclic undirected multigraph is acyclic (a cycle in the subgraph is a cycle
      in the whole), so 878's Step B — which runs the countable-model step *inside* the cover —
      still yields a frame satisfying the same hypothesis, and still needs no second cover and no
      second invariance appeal. The strengthening costs nothing here. *(completed)*
- [x] Derive and record: **the cover discharges the strengthened hypothesis directly**. The
      universal cover of a connected undirected multigraph is a tree, and a disjoint union of
      trees is a forest, so §1.2's `G̃` satisfies undirected acyclicity, not merely directed-path
      uniqueness. §1.2's construction therefore already delivers the strong hypothesis; what was
      wrong was only its gloss. This is the load-bearing positive finding of the whole task — if
      it failed, Step A would fail and the conclusion would be unavailable. *(completed; the
      expected positive result, no discrepancy found)*
- [x] Record the net verdict in one sentence: the `Saturation` side is **unaffected**; no new
      obligation appears on either frame, and (H5) as 878's finding 7 words it ("every doubly
      serial oriented forest over `ℤ` satisfies `TaskFrame.Saturation`") needs no repair.
      *(completed)*
- [x] Append these findings to the Phase 1 amendment in the same §1.2 location, labelled as
      derived and tier-marked (compiled where read off a signature, derived where argued).
      *(completed)*
- [ ] If either compiled check comes out contrary to the expectation above, stop: do not file the
      870 revision, record the discrepancy in the issue log, and set `user_decision` on
      `.return-meta.json` per `context/standards/user-decision-contract.md`. *(deviation:
      skipped — condition not triggered; both compiled checks confirmed as expected, so this
      contingency step does not apply)*

**Timing**: 0.7 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: The phase reads `FormalSystem/**` but writes only to the same single
markdown report artifact as Phase 1, so the covering check is again
`bash .claude/scripts/validate-artifact.sh specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md report`
plus the `prose` row's diff read-through, with `git status --short FormalSystem/` confirming no
Lean file was modified.

**Scope Hypothesis**: Both compiled checks are asserted to be readable from two declarations
(`FrameOver.IsRegular`, `plus_invariance_of_isZTime`) without a `lake build`. Confirm by locating
both declarations; if `IsRegular`'s field list cannot be read off the declaration (it is reached
through an `abbrev`/instance chain per `FormalSystem/Semantics/FrameClassValidity.lean:139-146`),
follow that chain to the structure that actually carries `saturation` and cite *that* file and
line, rather than citing the reference that merely mentions the projection.

**Files to modify**:
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` -
  extend the Phase 1 amendment with the Saturation-side verification and its evidence tiers

**Verification**:
- The amendment cites a file and line for `IsRegular` bundling `saturation` and for
  `plus_invariance_of_isZTime`'s two `IsRegular` binders, and each citation resolves when read.
- The amendment states the induced-sub-digraph closure and the cover-delivers-the-strong-hypothesis
  findings, each labelled `derived`.
- The amendment states the net verdict (`Saturation` side unaffected) in one unambiguous sentence.
- `git status --short FormalSystem/` is empty — no Lean file was touched.

---

### Phase 3: Carry the multigraph convention forward to the statement [COMPLETED]

**Goal**: Make the orientation-keeping-undirected-multigraph convention explicit at the point
where the hypothesis is stated, together with the three consequences that make the downstream
`Walk` predicate correct.

**Tasks**:
- [x] Confirm by re-reading that §1.2's construction already says the components are taken "as
      undirected multigraphs, orientation kept" — the convention is present in the construction
      and is being carried forward, not introduced. *(completed)*
- [x] Record the three consequences, as 878 finding 1's first precision note derives them: a base
      opposite-edge pair `u → v`, `v → u` lifts to two distinct cover edges to two distinct nodes,
      and a base loop `u → u` lifts to a ray; hence the cover is a **simple** tree — no parallel
      edges, no loops, and therefore **no directed 2-cycles**. *(completed)*
- [x] State the dependency explicitly in both directions: the convention is what makes the
      strengthened hypothesis *true* of the cover (without it, an opposite-edge pair survives as
      an undirected 2-cycle and step 4's unique sink fails), and the absence of directed 2-cycles
      is what 878 finding 4's `Walk` predicate depends on. Name both consumers. *(completed)*
- [x] Attach this to the Phase 1-2 amendment rather than editing §1.2's construction sentence, so
      the construction text stays byte-identical. *(completed; git diff confirms zero deletions
      and the construction sentence itself unedited)*

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: Same single markdown report artifact as Phases 1-2 and no executable
surface, so the covering check is
`bash .claude/scripts/validate-artifact.sh specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md report`
plus the `prose` row's diff read-through.

**Files to modify**:
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` -
  extend the amendment with the multigraph convention and its three consequences

**Verification**:
- The amendment names all three consequences (no parallel edges, no loops, no directed 2-cycles).
- It names both consumers of the convention: step 4's unique sink, and the `Walk` predicate.
- §1.2's own construction sentence is unchanged (`git diff` shows no edit to it).

---

### Phase 4: Revise task 870's record and close [NOT STARTED]

**Goal**: Task 870's stated hypothesis matches what its consumer needs; the task's own artifacts
and state are consistent; the full gate set is green.

**Tasks**:
- [ ] Re-read task 870's current `specs/state.json` entry immediately beforehand (two sibling
      research tasks, 871 and 867, are dispatched this same cycle onto this same tree).
- [ ] Revise 870's description via `/revise 870`. 870 has no plan and status `not_started`, so
      this is skill-reviser's **description-update** path, not a plan revision. The revised
      description must: (a) replace "a frame in which directed paths between any two nodes are
      unique" with the oriented-forest hypothesis as Phase 1 pinned it (the underlying undirected
      multigraph is a forest); (b) replace the sentence "State the path-uniqueness hypothesis
      explicitly rather than assuming a forest data structure" with the corresponding instruction
      at the new strength — state the undirected-acyclicity hypothesis explicitly over a bare task
      relation, still without assuming a forest *data structure*; (c) keep the rest of 870's
      description intact, including its two unblocked fronts and its independence claims; (d) note
      that the hypothesis is on the underlying undirected **multigraph**.
- [ ] If `/revise` cannot be invoked from this dispatch, use the identical mechanical path
      skill-reviser Stage 7 uses for a description update: `bash .claude/scripts/state-write.sh`
      with the `description`/`last_updated` object merge, `--session-id`, `--argjson num 870`, and
      `--regen-todo`. Record the fallback in the issue log. Never hand-edit `specs/TODO.md`.
- [ ] Confirm 870's `dependencies` still contains `884` and its `file_scope` is still
      `["FormalSystem/Semantics/TaskFrame.lean"]` — neither should need changing, and neither
      should be changed incidentally.
- [ ] Confirm the revised 870 description does not contradict `specs/ROADMAP.md`'s existing `870`
      annotations (lines ~124, ~142, ~191). Read only; do not edit ROADMAP.
- [ ] Write the completion summary to
      `specs/884_oriented_forest_hypothesis_strength_revision/summaries/01_oriented-forest-hypothesis-strength-summary.md`,
      recording the restated hypothesis, the Saturation-side verdict with its evidence tiers, the
      multigraph carry-forward, and the 870 revision.
- [ ] Commit with scoped, explicit-file-list staging only (`git add -- <paths>`), never a directory
      or glob pathspec, and review `git status --short` and `git diff --staged` first.

**Timing**: 0.8 hours

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `specs/state.json` - 870's `description` (via `state-write.sh`, under its lock), `last_updated`
- `specs/TODO.md` - regenerated, never hand-edited (`--regen-todo` / `generate-todo.sh`)
- `specs/884_oriented_forest_hypothesis_strength_revision/summaries/01_oriented-forest-hypothesis-strength-summary.md` -
  new completion summary

**Verification**:
- The complete gate set: `bash .claude/scripts/verify-deploy.sh` runs and is observed green in
  this dispatch (not trusted on sight).
- `bash .claude/scripts/validate-state.sh` exits 0.
- `bash .claude/scripts/validate-artifact.sh specs/884_oriented_forest_hypothesis_strength_revision/plans/01_oriented-forest-hypothesis-strength.md plan`
  and the same for the summary with type `summary`.
- `jq '.active_projects[] | select(.project_number==870) | .description' specs/state.json` contains
  the oriented-forest wording and no longer contains "directed paths between any two nodes are
  unique" as the *stated hypothesis*.
- `specs/TODO.md` shows 870 with the revised description and was produced by the generator.
- `git status --short` shows no unstaged change belonging to this task and nothing staged that
  belongs to a sibling task.

---

## Testing & Validation

- [ ] Report 03 §1.2's amendment states the hypothesis at undirected-multigraph-acyclicity
      strength and maps steps 1-5 to the strength each consumes.
- [ ] The `Saturation`-side verdict is backed by two resolvable file:line citations into
      `FormalSystem/**` and two labelled derivations.
- [ ] The multigraph convention and its three consequences are stated where the hypothesis is
      stated, with both consumers named.
- [ ] Task 870's `specs/state.json` description states the oriented-forest hypothesis; its
      `dependencies` and `file_scope` are unchanged.
- [ ] No file under `FormalSystem/**` is modified by this task.
- [ ] `specs/ROADMAP.md` and `specs/878_.../reports/01_...` are unmodified.
- [ ] `verify-deploy.sh` green; `validate-state.sh` exit 0; `validate-artifact.sh` clean on this
      task's plan and summary and on report 03.

## Artifacts & Outputs

- `specs/884_oriented_forest_hypothesis_strength_revision/plans/01_oriented-forest-hypothesis-strength.md` (this plan)
- `specs/884_oriented_forest_hypothesis_strength_revision/summaries/01_oriented-forest-hypothesis-strength-summary.md` (Phase 4)
- A dated, derived resolution amendment in
  `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` §1.2
- A revised `description` for task 870 in `specs/state.json`, rendered into `specs/TODO.md`

## Rollback/Contingency

Every edit is additive markdown in a `specs/**` report plus one JSON field, so rollback is a
targeted revert of the specific hunks, not a tree operation. Do **not** run `git-snapshot.sh` in
its default reverting mode at any point in this task: two sibling tasks share this working tree
this cycle, and the dispatch's territory note forbids it. If a defensive checkpoint is wanted
before Phase 4's `state.json` write, use `bash .claude/scripts/git-snapshot.sh 884 --no-revert`,
which is durable without reverting the tree.

Contingencies:
- **Phase 2's compiled checks contradict the expectation** (the cover does not deliver undirected
  acyclicity, or `IsRegular` does not bundle `saturation`): stop before Phase 4. The 870 revision
  must not be filed on an unverified premise. Record the discrepancy in the issue log, set
  `user_decision` on `.return-meta.json`, and report `partial`.
- **`/revise 870` and the `state-write.sh` fallback both fail** (lock contention from a sibling,
  or a write refusal): leave 870's record untouched, report the completed report-03 amendment as
  `partial` with the remaining step named, and do not hand-edit `specs/TODO.md` or `specs/state.json`.
- **A foreign commit, foreign uncommitted modification, or a build not started by this dispatch is
  observed**: stop and report it after confirming via `git log` that the work is not this task's,
  rather than proceeding.
