# Implementation Plan: Complete the seedRun terminus restatement family

- **Task**: 465 - Complete the terminus restatement family at the repaired residuals
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: 462, 463, 464 — all three settled (463 and 433 archived; 464's phases committed, its `_gap` family landed complete at 6/6)
- **Research Inputs**: `specs/465_complete_terminus_restatement_family/reports/01_complete-terminus-restatement-family.md`
- **Artifacts**: plans/01_complete-seedrun-terminus-family.md (this file), summaries/01_complete-seedrun-terminus-family-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The task's recorded scope — fourteen `_lengthBudget`/`signedUniverse` siblings of the `_run`
termini — is void: all nine `_run` termini were retired as vacuous when `PostBlockingSettlesRun`
was refuted, so no family root remains for any of the fourteen to apply. Re-deriving the matrix
from the tree as it stands (run during planning, reproduced in Phase 1 as a hard gate) finds the
five landed families complete, not half-populated. The live gap is one level over: the
post-blocking **seed** narrowing has exactly one member repo-wide,
`buildTableauAt_isSome_of_budget_fixed_seedRun`, whose own docstring calls itself "the
representative restatement, not the family".

This plan therefore lands the seedRun family instead, per the settled rescope decision: seven new
termini — `_fixed_seedRun` S2-S4 and a whole new `_gap_seedRun` line S1-S4 — in one new submodule
`MintBound/SeedRunTermini.lean`, plus the record correction that stops a future reader re-attempting
the fourteen. Work is purely additive in Lean: one new file, one aggregator import line, and
docstring/prose amendments in three landed modules that touch no statement and no proof term.

Definition of done: full `lake build` green; zero `sorry`; `#print axioms` on each of the seven new
theorems reporting nothing beyond `propext, Classical.choice, Quot.sound`; no landed declaration's
statement or proof altered; `Fuel.lean`, `Saturation.lean` and `Tableau.lean` byte-identical; and
the C12 record and C9 register truthful about what the fourteen are and what the seven do and do
not establish.

### Research Integration

Six findings from `reports/01_complete-terminus-restatement-family.md` drive the structure below.
Each was re-grounded against the tree during planning, not carried on trust:

1. **The fourteen are moot, and the dispatch's own stop-condition fires for all of them at once.**
   `grep -rn "theorem buildTableauAt_isSome" FormalSystem/` returns 33 declarations and not one
   `_run` terminus; the retirement record at `MintBound/PostBlocking.lean:735-790` names all nine
   removed names. There is no root to apply, so none of the fourteen is "a one-line application".
2. **The six-slot convention, re-derived.** S1 `_of_budget{_SUF}`, S2 `_at_seed{_SUF}`, S3
   `_of_lengthBudget{_SUF}`, S4 `_at_seed_lengthBudget{_SUF}`, S5/S6 the `signedUniverse` forms
   (which drop the `_at` suffix). Confirmed against the `_fixed` family at
   `MintBound/SigmaFixed.lean:812,829,847,862,883,902` and the `_gap` family at
   `MintBound/FiveComponent.lean:671,689,708,724,743,765`.
3. **`_fixed_seedRun` is a singleton.** Confirmed: `MintBound/PostBlocking.lean:1273` is its only
   member; nothing else in `FormalSystem/` carries the suffix.
4. **The import graph forces a new submodule.** `PostBlocking.lean` imports `SigmaFixed`;
   `FiveComponent.lean` imports `MintPaysAssembly`. They are parallel branches of the DAG, so
   `FiveComponent` cannot see `buildTableauAt_isSome_of_settlesSeedRun` and `PostBlocking` cannot
   see `expandBranchWithFuel_isSome_of_budget_gap`. A new module importing both is the only
   additive join. Confirmed by `grep -n "^import" MintBound/*.lean`.
5. **The `_gap` route carries no refuted hypothesis.** `expandBranchWithFuel_isSome_of_budget_gap`
   (`MintBound/FiveComponent.lean:651`) takes no `hmint` — `mintPaysForTimeGap_of_any`
   (`MintBound/MintPaysAssembly.lean:875`) supplies the residual internally with no frame-class
   hypothesis. So the `_gap_seedRun` S1-S4 members below carry `UniverseClosedAt`,
   `DifficultyBounded`/`StepLengthBounded`, `ArmSettlement` and `PostBlockingSettlesSeedRun` and
   nothing this file refutes outright.
6. **The `hpb` fuel expression is the one real authoring hazard.** The seedRun root's `hpb` is
   indexed by the *conclusion's* fuel expression, so each S2-S4 member's `hpb` must be transcribed
   at the instantiated figure (`derivedTmaxAt`/`derivedTmaxGap` for the seed forms,
   `difficultyCeiling U L` for `D` in the length-budget forms) rather than copied from the root.
   A mistyped figure yields a type-correct, provable, quietly wrong theorem.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap phases are included.

### Settled Rescope Decision

Recorded in `specs/465_complete_terminus_restatement_family/.decisions.json` and treated as settled
here: rescope to the seedRun family — correct the record, complete `_fixed_seedRun` S2-S4, add the
`_gap_seedRun` line S1-S4 in a new submodule, and leave S5/S6 out as `hlab`-vacuous. The plan below
implements exactly that scope and nothing beyond it.

## Goals & Non-Goals

**Goals**:

The committed identifier set. Exact signatures are fixed in the Lean Challenge Statements
section below.

- `buildTableauAt_isSome_at_seed_fixed_seedRun`
- `buildTableauAt_isSome_of_lengthBudget_fixed_seedRun`
- `buildTableauAt_isSome_at_seed_lengthBudget_fixed_seedRun`
- `buildTableauAt_isSome_of_budget_gap_seedRun`
- `buildTableauAt_isSome_at_seed_gap_seedRun`
- `buildTableauAt_isSome_of_lengthBudget_gap_seedRun`
- `buildTableauAt_isSome_at_seed_lengthBudget_gap_seedRun`

**Non-Goals**:

- **The fourteen recorded exclusions.** They are reported as moot and recorded as do-not-re-attempt,
  not attempted. Their family roots are gone; completing them would mean restating a refuted
  hypothesis, which is precisely the defect the retirement record exists to prevent.
- **Reviving any retired `_run` terminus**, or landing any new member at the unrestricted
  post-blocking residual or at its run-form narrowing. Both are refuted.
- **S5/S6 for either seedRun line.** The four `signedUniverse` forms are mechanically trivial but
  each carries the label-closure hypothesis, which is refuted at every nonempty label set, so each
  would be vacuous at exactly the universes it is aimed at. Uniformity does not outweigh adding four
  more headline-shaped statements with false antecedents. Excluded by the settled decision.
- **Proving the seed narrowing.** It is carried as a hypothesis throughout. The register already
  names one structurally independent, unprobed refutation route against it; no new member may be
  described as a discharge.
- **Repairing the systemic vacuity of the 28 landed termini.** Every one carries the unrestricted
  post-blocking residual, which is refuted at every frame class. That is a predicate-level question
  and belongs in its own task.
- **Any edit to `Fuel.lean`, `Saturation.lean` or `Tableau.lean`**, and any edit to the five complete
  families, which need nothing.
- **Any in-place change to a landed statement or proof term.** Phase 4's amendments are confined to
  docstring and module-prose text.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `hpb` fuel expression drifts from the conclusion's, yielding a type-correct but quietly wrong theorem | H | M | Phase 2/3 authoring rule: copy the sibling's *conclusion* fuel expression verbatim into `hpb`, never the root's. Phase 5 gate re-reads each landed signature with `lean_hover_info` (or `lean_declaration_file`) and checks `hpb`'s fuel argument against the conclusion's character for character. |
| Repeating the retirement: landing a family at a merely-unrefuted hypothesis is what produced the nine vacuous `_run` termini | H | M | Keep the set to the seven decided members. Every new member's docstring names its residual's exact status, cites the register entry carrying the unprobed refutation route, and does not describe the member as a discharge. Phase 3 and 4 both carry this as a checklist item that fails the phase if absent. |
| A future refutation of the seed narrowing retires the seven too | M | M | Cost is bounded and measured at ~zero for the nine-member precedent (reverse-dependency scan found no dependents; the decision procedure reaches no constant of this file). Holding all seven in one dedicated submodule makes a future retirement a single-file deletion plus one aggregator import line. |
| The new submodule is created but never built because the aggregator import is missing | M | L | The import line lands in the same phase as the file (Phase 2), in dependency position after `FiveComponent`, and Phase 2's own verification builds `FormalSystem.Metalogic.Decidability` — which reaches the new module only through that import. |
| Record amendment drifts into record-versioning language, or cites task numbers, in a deliverable file | M | M | Phase 4 states amendments as present-tense do-not-re-attempt facts citing declaration names and refuting witnesses — the idiom the C12 record and C9 register already use. No task numbers, no "previously"/"no longer"/"formerly" framing. Phase 4 verification greps the diff for both classes. |
| Concurrency: a sibling task edits a `FormalSystem/` path mid-flight | M | L | The declared concurrent sibling's `file_scope` names only `scripts/`, `specs/evidence/` and `specs/literature-index.json` — no `FormalSystem/` path. Phase 1 records `git log -1` per target file; Phase 5 re-checks it. Re-read each target immediately before editing; stage explicit file lists only; never run the reverting form of the snapshot script. |
| Phase 4's docstring edit to a landed declaration is read as "altering a previously-landed declaration" | L | M | Scope is one stale sentence in the representative's doc comment (its "deliberately deferred rather than forgotten" clause, made false by this work) plus module-level prose. No binder, statement or proof term is touched. Phase 4 verification shows the diff hunks all land inside comment regions. |
| Full `lake build` is slow and the dispatch stalls on it | L | M | Run it detached through the repository's guarded entry point with a hard timeout and poll the log per the bounded-build-waiter pattern; never an unbounded watch. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phases 2 and 3
write the same new file, and Phase 4's record text cites the names Phases 2 and 3 land.

### Phase 1: Re-derive the matrix and record the baseline [COMPLETED]

**Goal**: Discharge the dispatch's explicit instruction to re-derive the missing-member list from
the tree as it then stands, and record the baseline this task's additive-only and frozen-file
contracts are checked against in Phase 5.

**Tasks**:
- [x] Re-run the family sweep: `grep -rn "theorem buildTableauAt_isSome" FormalSystem/`. Record the
      declaration count and the per-family slot table.
- [x] Confirm no `_run` terminus exists and the retirement record is intact
      (`grep -rn "_run" FormalSystem/.../MintBound/PostBlocking.lean` for the record's name list).
- [x] Confirm the seedRun suffix is still a singleton: `grep -rn "seedRun" FormalSystem/`.
- [x] Confirm the import DAG constraint still holds: `grep -n "^import" MintBound/*.lean` shows
      `PostBlocking` off `SigmaFixed` and `FiveComponent` off `MintPaysAssembly`, with no edge
      between the two branches.
- [x] Record `md5sum` of `Fuel.lean`, `Saturation.lean`, `Tableau.lean` as the frozen-file baseline.
- [x] Record `git log -1 --oneline` for each target file (`MintBound.lean`, `MintBound/PostBlocking.lean`,
      `MintBound/Register.lean`, `MintBound/README.md`) and `git status --porcelain` for the
      `FormalSystem/` subtree.
- [x] GATE: if the sweep finds a `_run` family root restored, or a seedRun member beyond the one
      representative, or a new family root, STOP and re-scope in the handoff rather than proceeding
      against a stale matrix.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: this phase asserts, carried from
`reports/01_complete-terminus-restatement-family.md` and re-derived at plan-authoring time, that the
tree holds **33** `buildTableauAt_isSome` declarations, **zero** `_run` termini, and **exactly one**
`_fixed_seedRun` member at `MintBound/PostBlocking.lean:1273`, with five families complete. Confirm
by re-running the four greps above; a differing count re-scopes the task through this phase's GATE
rather than being worked around.

**Tier Justification**: the phase makes no edit at all — its covering check is the `prose` row's
diff read-through over an empty diff, discharged by `git status --porcelain` showing no
`FormalSystem/` modification at the phase's close.

**Files to modify**:
- None (read-only probes and baseline recording).

**Verification**:
- The four greps produce the recorded matrix, or the GATE fires.
- `git status --porcelain` over `FormalSystem/` is empty at phase close.

---

### Phase 2: New submodule and the `_fixed_seedRun` family, S2-S4 [COMPLETED]

**Goal**: Create `MintBound/SeedRunTermini.lean`, wire it into the aggregator, and land the three
`_fixed_seedRun` members that complete that line — each a one-line application of the landed root at
`MintBound/PostBlocking.lean:1273`.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/SeedRunTermini.lean`
      with the repository's standard copyright header, `import ...MintBound.PostBlocking` and
      `import ...MintBound.FiveComponent` (the two parallel DAG branches this module joins), and
      `namespace FormalSystem.Metalogic.Decidability` with the same `open` lines its two imports use.
- [x] Write the module docstring: the section is the seedRun terminus family; it states that the
      family's root S1 for the `_fixed` line lives in the post-blocking module and is reproduced
      here only by reference; it names the residual's exact status (not refuted, not proved) and
      cites the register entry carrying the unprobed refutation route; and it states plainly that
      no member here is a discharge of anything.
- [x] Land `buildTableauAt_isSome_at_seed_fixed_seedRun` (S2), transcribing `hpb` at
      `mintAwareFuelAt U.card (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card) (10 * U.card) D β`
      and threading `harm` through, with the body
      `buildTableauAt_isSome_of_budget_fixed_seedRun phi _ hβ hUcl hD hmint harm hpb hseed (Nat.le_refl _) (derivedTmaxAt_spec (seedBranch phi) U) (Nat.le_refl _)`.
- [x] Land `buildTableauAt_isSome_of_lengthBudget_fixed_seedRun` (S3), `hpb` at the
      `difficultyCeiling U L` figure, body applying the root through
      `difficultyBounded_of_stepLengthBounded_at hL hUcl`.
- [x] Land `buildTableauAt_isSome_at_seed_lengthBudget_fixed_seedRun` (S4), body applying S2 through
      the same `StepLengthBounded` trade.
- [x] Add `import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.SeedRunTermini`
      to `MintBound.lean`'s import list, in dependency position after the `FiveComponent` line.
- [x] Re-read `MintBound.lean` immediately before editing it (concurrency discipline), and stage
      only the two explicit paths.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts the file list `{MintBound/SeedRunTermini.lean (new),
MintBound.lean (one import line)}` and three new declarations. Confirm at implementation time with
`git status --short` naming exactly those two paths and `grep -c "^theorem buildTableauAt_isSome"`
on the new file returning 3 at phase close.

**Tier Justification**: the phase adds an import edge to the aggregator, whose single direct
dependent is `FormalSystem/Metalogic/Decidability.lean` — covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability`,
which reaches both the new module and the aggregator and which no single-module `local` build would.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/SeedRunTermini.lean` - new file: module docstring plus the three `_fixed_seedRun` members S2-S4
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - one new import line after the `FiveComponent` import

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability`
  exits 0 with no error and no new warning.
- `grep -n "sorry" MintBound/SeedRunTermini.lean` returns no proof placeholder.
- Each of the three new signatures' `hpb` fuel argument is read back (`lean_hover_info` or
  `lean_declaration_file`) and matches its own conclusion's fuel expression character for character.
- `git diff -- MintBound.lean` shows exactly one added line and no other change.

---

### Phase 3: The `_gap_seedRun` line, S1-S4 [COMPLETED]

**Goal**: Land the whole new `_gap_seedRun` line in the same submodule — the first termini in the
file whose S3/S4 forms carry no outright-refuted hypothesis, because the `_gap` engine lemma
discharges the minting residual internally at every frame class.

**Tasks**:
- [x] Land `buildTableauAt_isSome_of_budget_gap_seedRun` (S1) with **no** `hmint` binder, the
      enlarged floor `10 * U.card + U.card * U.card`, the `mintAwareFuelGap` figure, and the
      three-line body: `refine buildTableauAt_isSome_of_settlesSeedRun hpb ?_` then
      `exact expandBranchWithFuel_isSome_of_budget_gap hβ hUcl hD harm (seedBranch phi) TimeOrdering.empty EventualityTracker.empty {} maxBranches 0 hseed (runInvariant_initial _) hmb hT (by omega)`.
- [x] Land `buildTableauAt_isSome_at_seed_gap_seedRun` (S2) off S1 via
      `derivedTmaxGap_spec (seedBranch phi) U`, `hpb` transcribed at the `derivedTmaxGap` figure.
- [x] Land `buildTableauAt_isSome_of_lengthBudget_gap_seedRun` (S3) off S1 via
      `difficultyBounded_of_stepLengthBounded_at hL hUcl`, `hpb` at the `difficultyCeiling U L`
      figure.
- [x] Land `buildTableauAt_isSome_at_seed_lengthBudget_gap_seedRun` (S4) off S2 via the same trade.
- [x] Give each member a docstring stating which figures it reads off, that the minting residual is
      discharged rather than carried, and — for every member — that the seed narrowing is a carried
      hypothesis that is not proved. No member is described as making any terminus non-vacuous.
- [x] STOP-CONDITION check: if any of the four is not a one-line (S2-S4) or three-line (S1)
      application of a landed theorem — i.e. the recipe does not actually apply — stop on that
      member, record why in the handoff and the summary, and do not force it. A member needing real
      mathematics belongs in its own task.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts four new declarations in one already-existing file, taking
the module to seven. Confirm with `grep -c "^theorem buildTableauAt_isSome" MintBound/SeedRunTermini.lean`
returning 7 at phase close and `git status --short` naming that path alone.

**Tier Justification**: every edit is confined to the module Phase 2 created, whose only importer is
the aggregator already built in Phase 2, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.SeedRunTermini`
covers the edit's blast radius.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/SeedRunTermini.lean` - append the four `_gap_seedRun` members S1-S4 with their docstrings

**Verification**:
- The single-module build above exits 0, no error, no new warning.
- `grep -n "sorry" MintBound/SeedRunTermini.lean` returns no proof placeholder.
- Each of the four `hpb` fuel arguments matches its own conclusion's fuel expression.
- No member's docstring claims a discharge of the post-blocking residual or of any terminus's
  vacuity; each names the seed narrowing as carried-and-unproved.

---

### Phase 4: Correct the record [COMPLETED]

**Goal**: Make the deferral record truthful, so no future reader goes looking for the fourteen or
reads the representative's docstring as naming still-outstanding work. Docstring and module-prose
text only — no statement, binder or proof term is touched.

**Tasks**:
- [x] Amend the C12 retirement record in `MintBound/PostBlocking.lean` with one short paragraph:
      the `_lengthBudget`/`signedUniverse` siblings of the nine retired names are **not available**,
      because the roots they would apply are gone and restating them would carry a refuted
      hypothesis. State it as a present-tense do-not-re-attempt fact, in the idiom the record
      already uses — cite declaration names and refuting witnesses, never a task number and never a
      draft-history framing.
- [x] Amend the representative's doc comment at `MintBound/PostBlocking.lean:1273` so its deferral
      clause reads truthfully against the landed family: the `_fixed_seedRun` line is complete
      S1-S4 (S2-S4 in the seedRun-termini module), a parallel `_gap_seedRun` line S1-S4 is landed
      there too, and the `signedUniverse` forms are deliberately absent because the label-closure
      hypothesis they carry is refuted at every nonempty label set. Touch no binder and no proof
      term.
- [x] Add a short cross-reference paragraph to the C9 register entry recording the run-form verdict
      (`MintBound/Register.lean`, the entry at or near `:876`): the seedRun family is landed at
      S1-S4 for both lines, the narrowing remains carried-and-unproved with the unprobed refutation
      route still open, and the `signedUniverse` slots are absent by decision. Do not add a new
      register entry — the register holds statements that are *not* available, and these are.
- [x] Correct the register's own stale entry count where it is asserted: `MintBound/Register.lean`'s
      module docstring, `MintBound.lean`'s module-prose line describing the register, and
      `MintBound/README.md`'s register sentence. Re-derive the true count from the entry headings
      rather than trusting any recorded figure.
- [x] Correct `MintBound/README.md`'s module table: the stale `Register.lean` line-count figure, and
      add a row for `SeedRunTermini.lean` with its own line and declaration counts, in the table's
      existing shape. Also extend the README's import-graph prose to name the new module as the
      join of the two parallel branches.
- [x] Re-read each of the four files immediately before editing it; stage explicit paths only.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts the four-file list below, and asserts that the register
holds **26** entries against three places that say "twenty-five" and a README line-count of 923
against an actual 1001 — figures carried from
`reports/01_complete-terminus-restatement-family.md`'s incidental finding. Confirm by counting the
register's numbered entry headings and running `wc -l` on `Register.lean` at implementation time;
write the derived figures, not these.

**Tier Justification**: the edits are docstring and markdown text across three Lean modules whose
join is the aggregator, so the covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability`
(the aggregator's one direct dependent) plus the `prose` row's diff read-through confirming every
Lean hunk lands inside a comment region — a `local` single-module build would cover only one of the
three.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/PostBlocking.lean` - C12 record paragraph; the representative's deferral clause
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` - cross-reference paragraph on the run-form verdict entry; corrected entry count in the module docstring
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - corrected register-count prose
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` - corrected register count and line-count figure; new module row; import-graph prose

**Verification**:
- The aggregator build above exits 0 with no new error or warning.
- `git diff -- '*.lean'` for this phase shows every hunk inside a `/-!`, `/--` or `--` comment
  region; no binder, statement or proof term appears in the diff.
- The diff contains no task-number citation (`grep -nE '\btask [0-9]+' ` over the phase's diff is
  empty) and no record-versioning phrasing ("no longer", "previously", "formerly", "supersedes",
  "used to").
- The register's asserted entry count matches the counted number of numbered entry headings in all
  three places that assert it.

---

### Phase 5: Final gate, axiom audit and summary [NOT STARTED]

**Goal**: Run the complete gate set, confirm the additive-only and frozen-file contracts held, and
hand off with the rescope and the stop-condition verdict stated plainly rather than as a shortfall.

**Tasks**:
- [ ] Full `lake build`, detached through the guarded entry point with a hard timeout
      (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`), polled per the
      bounded-build-waiter pattern — writer liveness via `kill -0` on the captured PID, one waiter
      per log, never an unbounded watch. Zero errors; no new warnings.
- [ ] `#print axioms` on each of the seven new theorems; each reports nothing beyond
      `propext, Classical.choice, Quot.sound`.
- [ ] `grep -rn "sorry" ` over the diff's Lean files: zero proof placeholders (a `sorry` occurring
      inside prose is not one, and must be distinguished explicitly rather than counted).
- [ ] Re-`md5sum` `Fuel.lean`, `Saturation.lean`, `Tableau.lean` against the Phase 1 baseline; all
      three byte-identical. A drift that is demonstrably another task's is recorded, not glossed.
- [ ] `git diff --stat` confirms the changed-file set is exactly the five paths this plan declares
      (one new module, the aggregator, the post-blocking module, the register, the README) plus
      `specs/**`; `git diff` confirms no landed declaration's statement or proof term changed.
- [ ] Re-check `git log -1` per target file against the Phase 1 record; if a sibling landed
      mid-flight in `FormalSystem/`, stop and report it rather than rebasing silently.
- [ ] Re-run the family sweep and record the final matrix: both seedRun lines at S1-S4, the
      `signedUniverse` slots absent by decision.
- [ ] Write the summary. It states as first-class deliverables: that the recorded fourteen are moot
      and why (the stop-condition fired for all fourteen at once, for one shared reason), what the
      seven new members do establish, and — explicitly — that none of them makes any terminus
      non-vacuous, because the co-hypotheses the register refutes are untouched.
- [ ] Record the issue-log entries for this task's deviations and wins as they arose, and attest
      explicitly in the handoff if there is genuinely nothing to record.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that the task lands **seven** new theorems across a
changed-file set of exactly **five** Lean/markdown paths (plus `specs/**`). Confirm by counting the
Goals identifier set against `#print axioms` invocations actually run, and by `git diff --stat`
over the task's commits; a differing set is reported in the summary rather than reconciled silently.

**Files to modify**:
- None (verification and summary only).

**Verification**:
- Full `lake build` green, exit 0.
- Seven axiom audits clean; zero `sorry`.
- Three frozen-file md5s unchanged from the Phase 1 baseline.
- Changed-file set matches the declared five Lean/markdown paths exactly.
- The summary names the rescope and the mootness verdict and does not present either as a failure.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.ProofSystem

/-! The `_fixed_seedRun` line, S2-S4: the landed root
`buildTableauAt_isSome_of_budget_fixed_seedRun` instantiated at the three remaining call sites.
`hpb` is indexed by each statement's own conclusion fuel expression, and `harm` is threaded
explicitly because the seed narrowing does not supply `ArmSettlement`. -/

theorem buildTableauAt_isSome_at_seed_fixed_seedRun
    {fc : FrameClass} {U : Finset SignedFormula} {D β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hD : DifficultyBounded fc U D)
    (hmint : MintPaysForTimeFixed fc U
      (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelAt U.card
        (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
        (10 * U.card) D β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) D β)
        fc
        (β * mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) D β)
      ).isSome = true := sorry

theorem buildTableauAt_isSome_of_lengthBudget_fixed_seedRun
    {fc : FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax L β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeFixed fc U Tmax) (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β
      ≤ maxBranches) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card Tmax mintBudget (difficultyCeiling U L) β) fc
        maxBranches).isSome = true := sorry

theorem buildTableauAt_isSome_at_seed_lengthBudget_fixed_seedRun
    {fc : FrameClass} {U : Finset SignedFormula} {L β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hL : StepLengthBounded fc U L)
    (hmint : MintPaysForTimeFixed fc U
      (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card))
    (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelAt U.card
        (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
        (10 * U.card) (difficultyCeiling U L) β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) (difficultyCeiling U L) β)
        fc
        (β * mintAwareFuelAt U.card
          (derivedTmaxAt ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card) (difficultyCeiling U L) β)
      ).isSome = true := sorry

/-! The `_gap_seedRun` line, S1-S4: the five-component route at the seed narrowing. No `hmint`
binder anywhere — the minting residual is supplied internally by the `_gap` engine lemma at every
frame class. The mint-budget floor is the enlarged `10 * U.card + U.card * U.card`. -/

theorem buildTableauAt_isSome_of_budget_gap_seedRun
    {fc : FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax D β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc (mintAwareFuelGap U.card Tmax mintBudget D β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card + U.card * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelGap U.card Tmax mintBudget D β ≤ maxBranches) :
    (buildTableauAt phi (mintAwareFuelGap U.card Tmax mintBudget D β) fc
        maxBranches).isSome = true := sorry

theorem buildTableauAt_isSome_at_seed_gap_seedRun
    {fc : FrameClass} {U : Finset SignedFormula} {D β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hD : DifficultyBounded fc U D) (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelGap U.card
        (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card) U.card)
        (10 * U.card + U.card * U.card) D β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelGap U.card
          (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card + U.card * U.card) D β)
        fc
        (β * mintAwareFuelGap U.card
          (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card + U.card * U.card) D β)
      ).isSome = true := sorry

theorem buildTableauAt_isSome_of_lengthBudget_gap_seedRun
    {fc : FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax L β : Nat} (phi : Formula) (maxBranches : Nat)
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hL : StepLengthBounded fc U L)
    (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelGap U.card Tmax mintBudget (difficultyCeiling U L) β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U)
    (hmb : 10 * U.card + U.card * U.card ≤ mintBudget)
    (hT : (seedBranch phi).knownTimes.toFinset.card + mintBudget ≤ Tmax)
    (hbud : β * mintAwareFuelGap U.card Tmax mintBudget (difficultyCeiling U L) β
      ≤ maxBranches) :
    (buildTableauAt phi
        (mintAwareFuelGap U.card Tmax mintBudget (difficultyCeiling U L) β) fc
        maxBranches).isSome = true := sorry

theorem buildTableauAt_isSome_at_seed_lengthBudget_gap_seedRun
    {fc : FrameClass} {U : Finset SignedFormula} {L β : Nat}
    (phi : Formula) (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U)
    (hL : StepLengthBounded fc U L) (harm : ArmSettlement fc)
    (hpb : PostBlockingSettlesSeedRun fc
      (mintAwareFuelGap U.card
        (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card) U.card)
        (10 * U.card + U.card * U.card) (difficultyCeiling U L) β))
    (hseed : ∀ x ∈ seedBranch phi, x ∈ U) :
    (buildTableauAt phi
        (mintAwareFuelGap U.card
          (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card + U.card * U.card) (difficultyCeiling U L) β)
        fc
        (β * mintAwareFuelGap U.card
          (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card) U.card)
          (10 * U.card + U.card * U.card) (difficultyCeiling U L) β)
      ).isSome = true := sorry
```

## Testing & Validation

- [ ] Full `lake build` green, exit 0, zero errors, no new warnings.
- [ ] Zero `sorry` in any changed Lean file (prose occurrences distinguished, not counted).
- [ ] `#print axioms` on all seven new theorems: nothing beyond
      `propext, Classical.choice, Quot.sound`.
- [ ] Each new theorem's `hpb` fuel argument matches its own conclusion's fuel expression character
      for character.
- [ ] `Fuel.lean`, `Saturation.lean`, `Tableau.lean` byte-identical to the Phase 1 md5 baseline.
- [ ] No landed declaration's statement, binder list or proof term changed anywhere in the diff.
- [ ] Changed-file set is exactly the five declared Lean/markdown paths plus `specs/**`.
- [ ] No task-number citation and no record-versioning phrasing in any non-`specs/**` file touched.
- [ ] Re-run family sweep shows both seedRun lines complete at S1-S4 and the `signedUniverse` slots
      absent.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/SeedRunTermini.lean` — new
  module holding the seven new termini.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — one new import line
  and corrected register-count prose.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/PostBlocking.lean` — C12
  record paragraph on the unavailable siblings; corrected deferral clause on the representative.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` —
  cross-reference paragraph; corrected entry count.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` — corrected
  register figures, new module row, extended import-graph prose.
- `specs/465_complete_terminus_restatement_family/summaries/01_complete-seedrun-terminus-family-summary.md`
  — the summary required by Phase 5.

## Rollback/Contingency

Every Lean change is additive or comment-only, so reversion is cheap and local:

- **A single member fails to type-check as a one-line application.** The phase's own STOP-CONDITION
  applies: drop that member, record why in the handoff and summary, close the phase as
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose Evidence column
  carries the elaboration error. Do not weaken the statement to make it compile.
- **The whole `_gap_seedRun` line proves unavailable.** Keep Phase 2's `_fixed_seedRun` completion
  and Phase 4's record correction; the latter then records the `_gap_seedRun` absence as a named
  open item rather than claiming a landed line.
- **Full revert.** Delete `MintBound/SeedRunTermini.lean`, revert the one aggregator import line,
  and revert the four comment-only hunks. No landed declaration depends on anything this task adds,
  so nothing else moves.
- **If a rollback must discard uncommitted work**, take a durable checkpoint first —
  `bash .claude/scripts/git-snapshot.sh 465 --no-revert` for an ordinary defensive checkpoint, or
  the reverting invocation shape in `context/contracts/recovery.md`'s rollback rung (including its
  out-of-scope override flag) for a genuine rollback. Never the bare reverting form as a routine
  precaution, and never while a sibling task is live in this working tree.
