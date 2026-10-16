# Implementation Plan: Task #808

- **Task**: 808 - Fix the C16 env_linter failure: unused `[Finite F.WorldState]` on `FrameOver.mem_HF_iff_no_forbidden`
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/808_c16_unused_finite_instance_shiftfinitetype/reports/01_c16-unused-finite-instance.md
- **Artifacts**: plans/01_drop-unused-finite-binder.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity), no-record-versioning-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`scripts/check-module-invariants.sh` exits 1 on exactly one group, C16, because
`lake exe runLinter FormalSystem` reports one unused argument — `[Finite F.WorldState]`, argument 3 of
`FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden` — beyond the baseline in
`scripts/nolints.json`. The fix is a one-binder deletion in
`FormalSystem/Semantics/ShiftFiniteType.lean` plus the docstring paragraph that describes why the
binder is there, followed by the repository's full gate set. Definition of done:
`scripts/check-module-invariants.sh` exits 0, a full `lake build` exits 0, and the C3 structural
sorry inventory stays at zero.

### Research Integration

- **The finding is exactly one argument, and `[F.IsRegular]` is not flagged** — so the `rw
  [F.mem_HF_iff_adjacent_int f]` step consumes `IsRegular` and only the finiteness binder is dead.
  No second regression hides behind this one (`-- Found 1 error in 16736 declarations`).
- **There are no call sites, so the dispatch's "load-bearing binder" escape hatch does not fire.**
  `lean_references` on the declaration returned `total: 1` (the declaration itself); a
  repository-wide grep found 11 textual hits and zero term-level applications; the only
  non-prose hit is `#print axioms` at
  `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean:178`, a command that names a
  declaration without applying it and supplies no instance arguments.
- **A compiled probe already showed the existing four-line proof script closes the binder-free
  statement unchanged**, with axiom profile `[propext, Classical.choice, Quot.sound]` — identical
  to the profile pinned by the `#guard_msgs` block at
  `EffectivePeriodicExtensionAxiomTest.lean:173-178`. There is no proof-engineering step in this
  task and the pinned guard block needs no edit.
- **The edit resolves an internal inconsistency rather than trading one off.** The module docstring
  at lines 38-43 states that the two-theorem split exists so that "the identification holds at
  *any* carrier, finite or not, and only the finite-type claim needs `[Finite W]`"; carrying a
  vestigial `[Finite W]` on the identification is exactly the conflation that split prevents.
- **The research names one authoring trap, carried into Phase 2 as its own verification criterion**:
  `FormalSystem/**` is a deliverable path, so the rewritten docstring paragraph falls under
  `no-record-versioning-in-deliverables.md` and must not say the binder was "previously" carried,
  is "no longer" carried, or was "removed".

### Prior Plan Reference

No prior plan. This is the task's first planning round.

### Roadmap Alignment

Not consulted: this dispatch carries no `roadmap_path` and this plan modifies no roadmap.
`specs/ROADMAP.md`'s stanza describing this gate as red becomes stale once the gate is green; that
is a `specs/**` file handled by the orchestrator's roadmap regeneration, outside this plan's scope.

## Goals & Non-Goals

**Goals** (identifier set equals the single `theorem` declaration in `## Lean Challenge Statements`):
- `mem_HF_iff_no_forbidden` — restated at the weaker hypothesis set (no `[Finite F.WorldState]`),
  in namespace `FormalSystem.Semantics.FrameOver`, same proof body

Also in scope, carrying no new identifier:
- The declaration's docstring paragraph at `ShiftFiniteType.lean:159-160`, restated to describe the
  module's current design
- `scripts/check-module-invariants.sh` exit 0, full `lake build` exit 0, C3 sorry inventory still 0

**Non-Goals**:
- `lake exe runLinter --update` — explicitly forbidden by the dispatch; it would grandfather this
  regression into the baseline wholesale
- A `scripts/nolints.json` entry on the happy path (Phase 4 is the only route that touches it, and
  only if the call-site evidence is overturned at build time)
- An in-source `@[nolint unusedArguments]` attribute — C26 gates those behind
  `scripts/nolint-attribute-allowlist.txt` at a "PERMANENT DOCUMENTED EXEMPTION" bar this case
  cannot clear, and that file is outside the dispatch's permitted scope
- Touching the proof body, the `#guard_msgs` axiom-profile guard blocks, `finite_forbiddenBlocks`,
  `instDecidableForbidden`, or `ShiftFiniteTypeDictionary.lean`
- Adding `[DecidableRel F.step]` — the declaration's own docstring records that this is deliberately
  not done, and it is irrelevant to C16
- `docs/theorem-index.md`, `docs/reference/paper-definitions-of-record.md`, and
  `FormalSystem/Semantics/README.md` — each was read during research and asserts nothing about this
  theorem's finiteness binder, so none goes stale
- `specs/ROADMAP.md` and any other `specs/**` file

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A downstream `simp`/`aesop`/`exact?` call picked this lemma up by unification and breaks — invisible to a name grep | H | L | Phase 1 builds the one direct importer; Phase 3's full `lake build` plus `lake build BimodalTest` is the catch, which is why it is a deliverable and not optional; Phase 4 is the in-plan contingency so the fallback is not a plan deviation |
| The docstring rewrite trips `no-record-versioning-in-deliverables.md` — the natural replacement sentence ("`[Finite W]` is no longer carried here") is exactly the forbidden form | M | M | Phase 2 carries a drafted candidate paragraph written in the permitted form, and a verification criterion that greps the changed hunk for the forbidden vocabulary before the commit |
| The implementer "improves" the statement while editing it (re-adds a hypothesis, specialises, adds `[DecidableRel F.step]`) | H | L | `## Lean Challenge Statements` pins the exact target signature; `plan-compliance.md`'s Statement Fidelity makes that signature part of the contract |
| A foreground `lake build` livelocks at the Bash tool's 10-minute cap and banks no `.olean` | M | M | Every build in this plan is detached via `Bash(run_in_background: true)` and routed through `lake-build-guard.sh` per `context/project/lean4/operations/long-builds.md`; `--timeout` there is the lock-wait bound, not a build bound |
| A competing unguarded `lake` process causes an unexplained failure that looks like a regression from this edit | M | L | Per `rules/lean4.md`, check for a competing `lake` before attributing any build failure to the binder deletion |
| Docstring reflow shifts line numbers and breaks a line-anchored citation | L | L | Checked during research: `grep -rn "ShiftFiniteType\.lean:[0-9]"` outside `specs/` returns nothing; the only `:149` citations live in the `specs/**` exemption zone |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase's
input is the previous phase's green state.

### Phase 1: Drop the Unused Instance Binder [COMPLETED]

**Goal**: `mem_HF_iff_no_forbidden` is stated without `[Finite F.WorldState]`, the module and its one
direct importer elaborate, and `lake exe runLinter FormalSystem` reports zero errors.

**Tasks**:
- [x] Re-confirm the finding is still exactly one argument before editing anything:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- exe runLinter FormalSystem`,
      detached. Expect exit 1 and the single
      `mem_HF_iff_no_forbidden 1 unused argument: argument 3: [Finite F.WorldState]` line. If a
      second finding has appeared since research, record it and stop at this phase rather than
      widening scope.
- [x] Re-confirm there is still no call site: `mcp__lean-lsp__lean_references` at the declaration's
      name position in `FormalSystem/Semantics/ShiftFiniteType.lean` (expect `total: 1`), plus
      `grep -rn "mem_HF_iff_no_forbidden" --include=*.lean .` (expect prose plus the one
      `#print axioms` command, no term-level application).
- [x] Edit the `theorem mem_HF_iff_no_forbidden` signature line: delete `[Finite F.WorldState]`,
      leaving `theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular]`. The
      `(f : ℤ → F.WorldState)` line and the four-line proof body are untouched. The resulting
      signature must match `## Lean Challenge Statements` below character for character.
- [x] Scoped build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- build FormalSystem.Semantics.ShiftFiniteType`,
      detached. Expect exit 0.
- [x] Direct-dependent build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- build FormalSystem.Semantics.ShiftFiniteTypeDictionary`,
      detached. Expect exit 0. This is the one module that imports the edited one.
- [x] Linter:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- exe runLinter FormalSystem`,
      detached. Expect exit 0 and `-- Found 0 errors`. *(deviation: altered — the green run prints `-- Linting passed for FormalSystem.` rather than a `-- Found 0 errors` line; equivalent zero-error verdict)*
- [x] Commit the green sub-step per `rules/git-workflow.md`'s Commit-Per-Green-Substep Mandate,
      staging only `FormalSystem/Semantics/ShiftFiniteType.lean` through
      `.claude/scripts/git-commit-scoped.sh`.

**Timing**: 1 hour (dominated by three detached guarded runs, two of which are near-no-ops once the
first has warmed the cache)

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: Two figures are carried from
`reports/01_c16-unused-finite-instance.md` rather than re-derived at plan-authoring time: (a)
`lean_references` returns `total: 1`, i.e. this declaration has exactly zero call sites, and (b)
`FormalSystem.Semantics.ShiftFiniteTypeDictionary` is the complete set of direct importers of the
edited module. Both are confirmed at implementation time by this phase's first two tasks ((a)
directly, (b) by the direct-dependent build plus Phase 3's full build, which is what would surface
any importer this enumeration missed).

**Tier Justification**: `lake-build-guard.sh build --timeout 900 -- build
FormalSystem.Semantics.ShiftFiniteType` plus the same invocation for
`FormalSystem.Semantics.ShiftFiniteTypeDictionary` (the edited module's one enumerated direct
importer) plus `-- exe runLinter FormalSystem` exiting 0 is the covering check for a
public-signature change whose only consumer-side surface is Lean elaboration; the transitive
remainder and the test library are Phase 3's business.

**Files to modify**:
- `FormalSystem/Semantics/ShiftFiniteType.lean` - delete `[Finite F.WorldState]` from the
  `mem_HF_iff_no_forbidden` signature; nothing else in this phase

**Verification**:
- The signature line reads `theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular]`
  and matches `## Lean Challenge Statements` exactly.
- `git diff -- FormalSystem/Semantics/ShiftFiniteType.lean` shows exactly one changed line.
- All three guarded invocations above exited 0 (read the guard's own `result` subcommand or the
  captured `GUARD_EXIT`, never a pipe exit code), with `-- Found 0 errors` in the linter output.
- `lean_references` reported `total: 1` and the grep found no term-level application before the edit
  was made.

---

### Phase 2: Restate the Docstring Paragraph [IN PROGRESS]

**Goal**: The declaration's docstring describes the module's current design — the identification is
stated at any carrier, and the finite-carrier hypothesis sits on `finite_forbiddenBlocks` — without
any record-versioning language, and the module still elaborates.

**Tasks**:
- [ ] Replace the paragraph at `ShiftFiniteType.lean:159-160` ("The identification itself holds at
      *any* carrier; `[Finite W]` is carried here only so the statement reads as the specification
      does, and it is the finiteness theorem above that uses it."). Drafted candidate, usable
      verbatim or adapted — it states the current design outright and uses none of the forbidden
      vocabulary:

      > The identification is stated at any carrier: nothing in it needs `W` finite. The
      > finite-carrier hypothesis sits on `finite_forbiddenBlocks` above, which is where the
      > specification's "when `W` is finite" clause is discharged — read the two together for the
      > full specification sentence.

- [ ] Re-read the module docstring at lines 38-43 ("Folding the second into the first would hide
      which hypothesis buys which half...") and confirm it now reads consistently with the
      signature. Expect no edit; if one is needed, keep it to the same restatement discipline.
- [ ] Re-read the `## *Saturation* needs no separate work here` section at lines 65-69, whose
      sentence is "the finite-carrier hypothesis **below** buys the finite-type half and nothing
      else has to be re-discharged for it". Confirm "below" now points unambiguously at
      `finite_forbiddenBlocks` (the module's only finiteness-hypothesis-bearing declaration).
      Research's instruction is to verify rather than assume: either leave it as is, or name
      `finite_forbiddenBlocks` explicitly. Record which was done.
- [ ] Grep the changed hunk for the vocabulary `no-record-versioning-in-deliverables.md` forbids —
      `no longer`, `previously`, `formerly`, `used to`, `removed`, `withdrawn`, `carried forward` —
      and confirm zero hits inside the diff.
- [ ] Scoped build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- build FormalSystem.Semantics.ShiftFiniteType`,
      detached. Expect exit 0. A docstring edit invalidates the module's `.olean`, so this is a real
      re-elaboration, not a no-op.
- [ ] Commit the green sub-step, staging only
      `FormalSystem/Semantics/ShiftFiniteType.lean`.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: `git diff -- FormalSystem/Semantics/ShiftFiniteType.lean` read through
hunk by hunk confirms every change lies inside a `/-- ... -/` or `/-! ... -/` doc comment, and
`lake-build-guard.sh build --timeout 900 -- build FormalSystem.Semantics.ShiftFiniteType` exiting 0
is the specific check that catches an edit escaping the comment boundary — the only compile surface
a doc-comment edit in this module has.

**Files to modify**:
- `FormalSystem/Semantics/ShiftFiniteType.lean` - restate the declaration docstring paragraph at
  lines 159-160; verify (and only if genuinely needed, adjust) the module-docstring passages at
  lines 38-43 and 65-69

**Verification**:
- `git diff -- FormalSystem/Semantics/ShiftFiniteType.lean` shows changes confined to doc-comment
  regions; no `theorem`, `def`, or `instance` line is touched by this phase.
- Zero hits for the forbidden record-versioning vocabulary inside the diff.
- The replacement paragraph names `finite_forbiddenBlocks` as the declaration that carries the
  finiteness hypothesis.
- `lake-build-guard.sh ... -- build FormalSystem.Semantics.ShiftFiniteType` exited 0.

---

### Phase 3: Full Gate Set [NOT STARTED]

**Goal**: The repository's complete gate set is green: full `lake build`, test-library build, zero
linter errors, `scripts/check-module-invariants.sh` exit 0, C3 sorry inventory at zero.

**Tasks**:
- [ ] Check for a competing unguarded `lake` process before starting, per `rules/lean4.md`, so any
      failure below can be attributed correctly.
- [ ] Full library build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached. Expect
      exit 0. This is the check that catches a `simp`/`aesop`/`exact?` call site a name grep cannot
      see.
- [ ] Test-library build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`,
      detached. Expect exit 0; the pinned `#print axioms` / `#guard_msgs` blocks at
      `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean:173-178` live here and
      must stay green with no edit.
- [ ] Linter, final run:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- exe runLinter FormalSystem`,
      detached. Expect exit 0 and `-- Found 0 errors`.
- [ ] The repository's aggregate invariant gate: `bash scripts/check-module-invariants.sh`,
      detached (it runs `lake` itself, so it is subject to the same cap). Expect exit 0 with no
      `FAIL` group — in particular `C16` PASS, both `C1 lake build` groups PASS, `C3` reporting a
      zero structural sorry inventory, and `C26` unaffected (no in-source `@[nolint]` attribute was
      added).
- [ ] Confirm `scripts/nolints.json` is byte-identical to its committed state
      (`git diff -- scripts/nolints.json` empty) — the happy path adds no baseline entry.
- [ ] Confirm `git status --short` shows no modified file outside this plan's `Files to modify` sets.
- [ ] Commit the phase.

**Timing**: 1.25 hours (wall-clock dominated by the full build; a `Semantics`-layer leaf edit
rebuilds far less than a syntax- or proof-system-layer edit, but the invariant gate re-runs `lake`
on its own)

**Depends on**: 2

**Verification Tier**: full

**Tier Justification**: `bash scripts/check-module-invariants.sh` exiting 0 — the aggregate gate
that itself runs both `C1 lake build` groups, the `C3` structural sorry inventory, and `C16`'s
`lake exe runLinter FormalSystem` — together with the standalone full `lake build` and
`lake build BimodalTest` is the complete gate set for this repository's Lean surface, and no
cheaper tier covers the cross-cutting surface a public signature change exposes: elaboration-level
breakage anywhere in the library or the pinned axiom-profile guard blocks in the test library.
`.claude/scripts/verify-deploy.sh` is deliberately not named here: it gates the `.claude/` deploy
tree against its source store, and this plan touches no source-store path (every file it modifies
is under `FormalSystem/`).

**Files to modify**:
- None planned - this phase is verification only; any edit it provokes is a Phase 1 or Phase 2
  repair, re-verified under that phase's criteria

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, with no `FAIL` line in its output.
- Full `lake build` exits 0 (guard `result`/`GUARD_EXIT`, not a pipe status).
- `lake build BimodalTest` exits 0 with no `#guard_msgs` mismatch.
- `lake exe runLinter FormalSystem` exits 0, `-- Found 0 errors`.
- `git diff -- scripts/nolints.json` is empty.

---

### Phase 4: CONDITIONAL — Baseline Entry If the Binder Proves Load-Bearing [NOT STARTED]

**Goal**: Only if Phase 1 or Phase 3 produces a build failure traceable to the binder deletion —
i.e. the research's three negative call-site probes are overturned by a real unification-dependent
call site — restore the binder and record the exemption in `scripts/nolints.json`, stating why.

**Decision gate**: Phase 1's direct-dependent build and linter run, and Phase 3's full `lake build`
and `lake build BimodalTest`. **If all four were green, this phase is not taken**: close it
`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose `Evidence` column cites
those green runs, per `plan-format.md`'s "Decision gates and contingency branches". Do not leave it
`[NOT STARTED]`.

This phase exists so that the dispatch's own fallback ("If the binder turns out to be load-bearing
at a call site, record that and add the nolints entry instead, stating why") is an in-plan branch
rather than a plan deviation — `rules/plan-compliance.md` requires a would-be deviation on a
`.lean` file to be escalated as `[BLOCKED]`, not silently annotated.

**Tasks** (taken only if the gate fails):
- [ ] Record the failing call site precisely: file, line, the elaboration error, and why the
      instance binder is required there for unification. This record is the justification the
      dispatch asks for; without it the baseline entry is not admissible.
- [ ] Restore `[Finite F.WorldState]` on the `mem_HF_iff_no_forbidden` signature, exactly as it
      stands at this plan's authoring.
- [ ] Add one entry to `scripts/nolints.json`, hand-edited in the existing
      `["unusedArguments", "<fully-qualified-decl>"]` shape, for
      `FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden`, keeping the file's existing
      formatting and ordering convention. **Do not** run `lake exe runLinter --update` — the
      dispatch forbids it and it would rewrite the whole baseline.
- [ ] Restate the docstring paragraph again so it names the call site that needs the binder,
      replacing Phase 2's text. Same `no-record-versioning-in-deliverables.md` discipline applies.
- [ ] Re-run the complete gate set from Phase 3 (full `lake build`, `lake build BimodalTest`,
      `lake exe runLinter FormalSystem`, `bash scripts/check-module-invariants.sh`), all detached
      and guarded. Expect exit 0 throughout; `runLinter` now passes because the baseline covers the
      declaration.
- [ ] Commit, staging only `FormalSystem/Semantics/ShiftFiniteType.lean` and
      `scripts/nolints.json`.

**Timing**: 0 hours on the expected (not-taken) path; 1.25 hours if the gate fails

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/ShiftFiniteType.lean` - restore the instance binder and restate the
  docstring paragraph (only on the taken branch)
- `scripts/nolints.json` - one new `["unusedArguments", ...]` entry (only on the taken branch)

**Verification**:
- Not taken: a `#### Reasoned Exclusions` record is present in this phase, citing Phase 1's and
  Phase 3's green runs, and the heading reads `[COMPLETED WITH EXCLUSIONS]`.
- Taken: `bash scripts/check-module-invariants.sh` exits 0, full `lake build` exits 0,
  `lake build BimodalTest` exits 0, `lake exe runLinter FormalSystem` exits 0, and
  `git diff -- scripts/nolints.json` shows exactly one added entry naming
  `FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden`.

## Lean Challenge Statements

One `theorem` declaration, carrying a `sorry` body: the exact target signature of the edit. The
supporting `def Forbidden` is declared here (not counted as a Goal) because the real `Forbidden`
lives in the module being edited; this block therefore imports that module's own prerequisite,
`FormalSystem.Semantics.IntNormalFormEffective`, rather than `ShiftFiniteType` itself, so it
type-checks standalone without colliding with the declaration it pins. The block was compiled at
plan-authoring time via `lean_run_code`: exit 0, one `declaration uses 'sorry'` warning, no errors.
`Forbidden`'s body is reproduced verbatim from `ShiftFiniteType.lean:119` and is not part of the
contract; the `theorem` signature is.

```lean
import FormalSystem.Semantics.IntNormalFormEffective

namespace FormalSystem.Semantics

namespace FrameOver

def Forbidden (F : FrameOver intOrder) (w u : F.WorldState) : Prop := ¬ F.step w u

theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular]
    (f : ℤ → F.WorldState) :
    (∃ τ : WorldHistory F, τ.path = f) ↔ ∀ n : ℤ, ¬ Forbidden F (f n) (f (n + 1)) := sorry

end FrameOver

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- exe runLinter FormalSystem`
      exits 0 with `-- Found 0 errors` (C16's own command).
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` exits 0,
      with the `#guard_msgs` axiom-profile block at
      `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean:173-178` unedited and
      green.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 — no `FAIL` group, `C16` PASS, both
      `C1 lake build` groups PASS, `C3` structural sorry inventory zero.
- [ ] The committed `mem_HF_iff_no_forbidden` signature matches `## Lean Challenge Statements`
      character for character (`plan-compliance.md` Statement Fidelity).
- [ ] No `no longer` / `previously` / `formerly` / `used to` / `removed` / `withdrawn` /
      `carried forward` vocabulary anywhere in the docstring diff.
- [ ] On the expected path, `git diff -- scripts/nolints.json` is empty and no
      `@[nolint unusedArguments]` attribute was added anywhere.
- [ ] Every build above was run detached (`Bash(run_in_background: true)`) through
      `lake-build-guard.sh`, and each verdict was read from the guard's `result` subcommand or a
      captured exit status, never from a pipe exit code.

## Artifacts & Outputs

- `FormalSystem/Semantics/ShiftFiniteType.lean` — `mem_HF_iff_no_forbidden` stated without
  `[Finite F.WorldState]`, with a docstring paragraph describing the module's current design
- `specs/808_c16_unused_finite_instance_shiftfinitetype/plans/01_drop-unused-finite-binder.md` —
  this plan, with per-phase status markers updated as phases close
- `specs/808_c16_unused_finite_instance_shiftfinitetype/summaries/01_*-summary.md` — the
  implementation summary, recording the gate's before/after exit codes
- `scripts/nolints.json` — unchanged on the expected path; one added entry only if Phase 4 is taken

## Rollback/Contingency

The substantive change is one line plus one docstring paragraph in one file, each committed as its
own green sub-step, so recovery is ordinary fix-forward: re-apply or revert the single hunk with an
ordinary `git` edit and re-run the affected phase's verification.

- **Build failure after the binder deletion**: fix forward into Phase 4's branch (restore the binder,
  add the hand-edited baseline entry, state why). Do not discard uncommitted work to reach a green
  build — see `context/contracts/recovery.md`'s ladder and `rules/error-handling.md`'s
  write-gating constraint.
- **If a rollback of the working tree genuinely becomes necessary**, take the snapshot first per
  `context/contracts/recovery.md`'s rollback rung (which names the invocation shape, including its
  out-of-scope override flag), then run the destructive command; `guard-destructive-git.sh` blocks
  it otherwise.
- **A `[BLOCKED]` escalation is the correct terminus** if a failing call site cannot be made green
  by either branch — per `rules/plan-compliance.md`, a would-be deviation on a `.lean` file is
  raised, not annotated.
- **Nothing in this plan requires reverting another task's work**: the file's last change
  (`250a74ae0`, 2026-10-15) is untouched apart from the one signature line and the docstring
  paragraph.
