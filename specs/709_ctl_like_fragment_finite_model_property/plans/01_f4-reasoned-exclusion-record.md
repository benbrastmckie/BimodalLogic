# Implementation Plan: Task #709

- **Task**: 709 - ctl_like_fragment_finite_model_property (F4, finite width implies eventually periodic, as route R1's summary step)
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: 703, 710, 719 (all archived `completed`; nothing here waits on them)
- **Research Inputs**: specs/709_ctl_like_fragment_finite_model_property/reports/01_f4-summary-step-disposition.md
- **Artifacts**: plans/01_f4-reasoned-exclusion-record.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a record-only plan. The task's own description fixes a two-outcome contract whose
resolution belongs to route R1, not to this task, and the research round established that R1 has
resolved it: probe E3 (`specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`,
re-audited with "the selection is UNCHANGED, verdict (i), KEEP candidate (d)") selected the
time-axis Ramsey-coloured summary, and R1 then **landed that summary step** as
`FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily`
(`FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean:1562`) and
`FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented`
(`RaySummary/HitComplete.lean:590`), both kernel-checked at
`[propext, Classical.choice, Quot.sound]`. That theorem is the F4 route step for step (infinite
Ramsey for pairs on a composing colour, one period per tail, mirrored backward, assembled at the
seam), taken over `(profile, cutProfile)` colours of time-axis stretches with **no width**. The
finite-width form of F4 that this task would have proved is therefore consumed by nothing, and
its premise is in any case refuted inside the target fragment by
`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`.

The plan's single phase closes the task as the **reasoned exclusion** the task record
pre-authorises, with the trigger corrected (R1 chose the Ramsey colour and landed it in the only
form it consumes, rather than choosing an acceptance condition), and makes the one durable library
edit the research round found warranted: the closing paragraph of
`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` says the periodicity
argument is "not formalized anywhere in this tree", which is now misleading, and is amended to
point at `exists_periodic_subfamily` while keeping the characterisation honest. **No Lean is
written**, no width bound is committed, and the refuted headline is not attempted.

### Research Integration

- F-1/F-2: E3's selection and the landed theorems are the evidence for the exclusion; their
  fully qualified names and axiom lists are the Evidence column of the record below.
- F-3: the task's "two forced repairs to HWZ" are already carried in R1's form (the product fibre
  `plusStab_iff_omega`; the `(profile, cutProfile)` colour with `profile_flatten_congr`), so no
  residual mathematics is left for this task.
- F-4: the README sentence is literally true and misleading; Recommendation 3 is adopted verbatim
  as this plan's one file edit.
- F-5/F-6: no consumer of the finite-width form exists on any live route; the fallback fragment
  restriction (safety / bounded-step `⊡`) was the alternative under outcome (ii), which did not
  occur, and has no consumer either. Both are recorded as excluded, not pursued.
- Recommendation 2 is adopted: the restricted-fragment finite-width theorem (40-80 h) is not
  attempted.
- Recommendation 4 is adopted in part: the plan does **not** edit `specs/ROADMAP.md` (its Stage 0
  rulings are user-only); it records the proposed wording in the summary for the user to apply.
- One correction to the report: the re-presentation-is-not-tail-stable theorem is
  `PlusSlicedCertificate.Fixture.not_tailStable_cert` (`FixtureStable.lean:357`), not
  `Fixture.not_tailStable` (no declaration of that name exists). Recorded on the issue log; the
  plan cites the real name.

### Prior Plan Reference

No prior plan. (The three 2026-01-28 commits labelled "task 709" belong to a different,
pre-renumbering task and bear on nothing here, per the report's F-7.)

### Roadmap Alignment

`specs/ROADMAP.md` was read, not modified. It lists 709 under "Not batched, and why" as awaiting a
Stage 0 ruling ("Re-rule on **709**'s value before dispatching it"), and the prior cycle adopted
the research agent's recommended close autonomously, flagged there as "NOT a user ruling". This
plan is the reversible, record-only realisation of that adopted answer; the Stage 0 checkbox
stays with the user, and the summary supplies the two-line text for it.

## Goals & Non-Goals

**Goals**:
- Close the task with a `[COMPLETED WITH EXCLUSIONS]` phase whose `#### Reasoned Exclusions`
  record names the three excluded items (F4 finite-width form; the fallback fragment restriction;
  the refuted headline), each with reason and kernel-checked evidence, satisfying
  `status-markers.md`'s five-condition admission test.
- Amend the closing paragraph of `PlusSlicedCertificate/Limits/README.md` so it says the
  Ramsey-periodicity argument is formalized over time-axis colourings (`exists_periodic_subfamily`)
  and that only its transfer to finite-width sliced structures of the same width, together with
  the step from an eventually periodic model to a tail-stable certificate, is not, and that
  nothing consumes that transfer.
- Re-verify at implement time every declaration the record cites (axioms
  `[propext, Classical.choice, Quot.sound]`, no `sorry`), so the Evidence column rests on this
  dispatch's own observation rather than on the report's.
- Write the implementation summary carrying the record and the proposed ROADMAP wording.

**Non-Goals**:
- No `.lean` file is created or modified. No width bound is committed. The refuted headline (FMP
  for the CTL-like fragment against the sliced class) is not attempted.
- No fragment predicate for the safety / bounded-step restriction is defined (`BoxStabFree` in
  `PlusLanguage/Subformulas.lean` is a different, smaller fragment and is not touched).
- No fourth certificate class is proposed.
- `specs/ROADMAP.md` is not edited: its Stage 0 rulings are reserved to the user.
- The report's context-extension suggestion (a sentence in `status-markers.md` naming "superseded
  by a landed declaration" as an admissible exclusion reason) targets the agent-system source
  store, not this repository, and is left for a `/meta` task if the user wants it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The user reverses the Stage 0 ruling and wants the restricted-fragment finite-width theorem pursued | M | L | Everything here is reversible: the exclusion is a record and the README edit is prose. The right statement, if ever wanted, is a corollary of `exists_periodic_subfamily` over the label colouring of a sliced structure's run (report Rec. 2), to be filed research-first against a named consumer; the amended README leaves that pointer where a reader would look |
| The README amendment over-claims (reads as "F4 is proved") or under-claims (keeps "not formalized anywhere") | M | L | The replacement text is fixed in Phase 1 below; verification greps for both the new pointer and the absence of the old sentence, and the diff read-through confirms the "argued, not proved" lead sentence is kept |
| The amended paragraph trips the task-reference or record-versioning rules (the README is outside `specs/**`) | L | L | The replacement text cites declarations, files and probe paths only, never task numbers, and avoids "no longer / previously / formerly"; `check-task-references.sh --quiet` runs in the gate |
| A cited declaration's axiom list or name drifts between the research session and implementation | L | L | Phase 1's first task re-runs the kernel check on all four cited declarations before the record is finalised; a mismatch blocks the phase rather than being carried |
| An implementer reads the single phase as ordinary work and closes it `[COMPLETED]` | L | M | The phase's tasks name the closing marker explicitly and the `#### Reasoned Exclusions` record is pre-written below; `[COMPLETED]` without the record would fail the plan's own verification |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Record the F4 exclusion and amend the Limits README [COMPLETED WITH EXCLUSIONS]

**Goal**: Close the task as a reasoned exclusion on kernel-checked evidence, and correct the one
misleading sentence in the library's prose so the tree's own documentation says what is and is
not formalized. This phase closes with the marker `[COMPLETED WITH EXCLUSIONS]`, never
`[COMPLETED]`: its done-items are the README amendment and the summary; its excluded items are the
three rows of the record below.

**Tasks**:
- [x] Re-verify the four cited declarations in this dispatch (lean-lsp `lean_verify` with
  `scan_source: true`, or `#print axioms` through `lean_run_code` / a scratch file compiled
  with `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean <file>`;
  announce the evidence tier if `lean_local_search` reports `warming`/`unavailable`/`error`):
  `FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily`,
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented`,
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`,
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture.not_tailStable_cert`. Each
  must report exactly `[propext, Classical.choice, Quot.sound]` and no `sorry`. Record the
  observed output in the phase's verification notes. *(completed: all four, plus `not_sliced_complete` and `no_finite_width_sat`, checked via `lean_verify` with `scan_source: true`; each returned axioms `[propext, Classical.choice, Quot.sound]`, trust `standard`, warnings `[]`; full output in the summary)*
- [x] Confirm the Scope Hypothesis below (`grep -c 'not formalized anywhere in this tree'` on the
  README returns `1`; the sentence sits in the closing paragraph of
  `## What is refuted, and what is not`, lead sentence `**The semantic characterisation is
  argued, not proved.**`). *(completed: count `1`, README lines 77-80; `Last verified` at line 128)*
- [x] Replace that closing paragraph of
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` with the
  following text (verbatim; adjust only if a cited line number has drifted, in which case cite
  the declaration without a line number): *(completed: applied verbatim, commit `7aba3abda`; 2 hunks; no `.lean` touched)*

  > **The semantic characterisation is argued, not proved.** The class is complete exactly on
  > targets with a finite-width countermodel: necessity is this directory's shape; sufficiency —
  > every finite-width model has an eventually periodic finite-width model of the same width,
  > presentable as a tail-stable certificate — is not a theorem of this tree, and nothing in this
  > tree consumes it. The Ramsey-for-pairs periodicity argument it rests on *is* formalized, but
  > over colourings of the time axis rather than over finite-width sliced structures:
  > `exists_periodic_subfamily` (`FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean`)
  > replaces each tail of a colouring of `ℤ` by one Ramsey-monochromatic period, with bounds that
  > count pairs of profiles and no width hypothesis at all, and `exists_hitPresented`
  > (`RaySummary/HitComplete.lean`) presents the result finitely. What is not formalized is the
  > transfer of that periodicity back to a sliced structure of the same width, and the step from
  > an eventually periodic model to a tail-stable certificate, which `Fixture.not_tailStable_cert`
  > (`../FixtureStable.lean`) shows re-presentation does not supply in general. A width-level
  > statement, should a consumer for one ever appear, is a corollary of
  > `exists_periodic_subfamily` over the label colouring of a sliced structure's run, not a new
  > Ramsey argument.

- [x] Update the README's trailing `*Last verified: 2026-10-10*` line to the implementation date. *(completed: 2026-10-17)*
- [x] Confirm the three exclusion rows below against this dispatch's own observations (the
  kernel checks above; `RaySummary/README.md`'s "No finite-fibre or finite-width assumption"
  sentence; E3's header verdict in `device-selection-probe.lean`), then set the phase heading
  to `[COMPLETED WITH EXCLUSIONS]` and the plan-level Status to `[COMPLETED]`. *(deviation: altered — phase heading set to `[COMPLETED WITH EXCLUSIONS]`; the plan-level `- **Status**:` field is owned by `update-plan-status.sh` via `update-task-status.sh` postflight and was not hand-edited. Observations: fragment-predicate grep count `0`; E3 header line 114 "UNCHANGED — verdict (i), KEEP candidate (d)"; `RaySummary/README.md` lines 99 and 517)*
- [x] Write `specs/709_ctl_like_fragment_finite_model_property/summaries/01_f4-reasoned-exclusion-record-summary.md`
  per summary-format.md, carrying (a) the `#### Reasoned Exclusions` table verbatim, (b) the
  kernel-check output, (c) the README diff hunk, and (d) under a heading "Proposed ROADMAP
  text (user-applied)" the two lines for the Stage 0 checkbox: that 709 closed as a reasoned
  exclusion because R1 landed the summary step over the time axis with no width
  (`exists_periodic_subfamily`, `exists_hitPresented`), and that the "Not batched, and why" entry
  for 709 may be removed once the user ticks the ruling. *(completed)*
- [x] Issue log: record a `win` if the kernel re-checks and Scope Hypothesis confirm cleanly on
  the first pass, or an `issue` for any deviation, as it arises; attest explicitly in the
  summary if nothing further arose. *(completed: one `win` and one minor `issue` recorded, dispatch 3)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly two regions of `Limits/README.md` change: the closing paragraph of
`## What is refuted, and what is not` (the only paragraph containing the string
`not formalized anywhere in this tree`, count `1` before and `0` after) and the single
`*Last verified:*` line; `git diff -- <README>` therefore shows exactly two hunks and no `.lean`
file is touched (`git diff --stat -- '*.lean'` empty). Confirm by the greps and the diff before
closing the phase; a third hunk, or any `.lean` change, blocks the phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` - replace the closing paragraph of `## What is refuted, and what is not`; update the `*Last verified:*` line
- `specs/709_ctl_like_fragment_finite_model_property/summaries/01_f4-reasoned-exclusion-record-summary.md` - new; the implementation summary
- `specs/709_ctl_like_fragment_finite_model_property/plans/01_f4-reasoned-exclusion-record.md` - phase and plan-level status markers only

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| F4, finite-width form: "every finite-width sliced structure satisfying a target has an eventually periodic, hence tail-stable-presentable, model of the same width" (the task's outcome-(i) statement and its 40-80 h route) | R1 selected the Ramsey colour, not an acceptance condition, and then landed its summary step over the time axis with no width hypothesis; the finite-width form is consumed by no live route (R1 carries no width; the sliced class's decidability route is closed as a refutation record; R2 is `[HOLD]` and a consumer of R1); its premise is refuted for the fragment at large; and its "hence tail-stable-presentable" clause needs a bridge that re-presentation does not supply | E3 verdict and re-audit in the header of `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` ("KEEP candidate (d)"); `FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily` (`RaySummary/Periodic.lean:1562`) and `FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented` (`RaySummary/HitComplete.lean:590`), each `[propext, Classical.choice, Quot.sound]`; `RaySummary/README.md` "No finite-fibre or finite-width assumption"; `...PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` (`Limits/NoFiniteWidth.lean`); `...PlusSlicedCertificate.Fixture.not_tailStable_cert` (`FixtureStable.lean:357`) |
| Fallback fragment restriction: `⊡` limited to safety and bounded-step operators (`⊡G`, `⊡X^k`), with a finite-width statement for that sub-fragment | This was the alternative *under outcome (ii)* (R1 selects an acceptance condition), which did not occur; under the actual outcome it has no consumer either, and no in-tree fragment predicate exists for it (`PlusFormula.BoxStabFree`, `PlusLanguage/Subformulas.lean`, is a different and smaller fragment) | Report F-5 and F-6; `specs/ROADMAP.md` Stage 1 "proceeds on R1 alone; there is no fallback"; grep of `FormalSystem/` for a safety / bounded-step `⊡` fragment predicate returns none (re-run at implement time and quote the count) |
| The filed headline: the finite model property for the CTL-like fragment against the time-sliced certificate class | Refuted as a theorem, inside the fragment, by the witness `Φ := (A' ∧ C') ∧ D`; the task's HARD CONSTRAINTS say it must not be attempted and that the obstruction theorem discharges the "record the obstruction" constraint | `...PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`, `not_sliced_complete`, `no_finite_width_sat` (`Limits/NoFiniteWidth.lean`), each `[propext, Classical.choice, Quot.sound]`, sorry-free (`Limits/README.md` "This subtree is sorry-free") |

**Verification**:
- Kernel checks: all four declarations named in the first task report exactly
  `[propext, Classical.choice, Quot.sound]` and no `sorry`, observed in this dispatch and quoted
  in the verification notes.
- README content: `grep -c 'not formalized anywhere in this tree' FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md`
  returns `0`; `grep -c 'exists_periodic_subfamily' <same>` returns at least `1`;
  `grep -c 'argued, not proved' <same>` returns `1` (the lead sentence is kept);
  `grep -Eic 'no longer|previously|formerly|used to|supersedes' <same>` returns `0`.
- Diff shape: `git diff -- FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md`
  shows exactly two hunks (the paragraph and the `Last verified` line);
  `git diff --stat -- '*.lean'` is empty.
- Task-reference rule (the README is outside `specs/**`):
  `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- The complete gate set, this being the plan's final phase: full `lake build` through
  `bash .claude/scripts/lake-build-guard.sh build --timeout 600` exits 0 (expected no-op: no
  `.lean` changed); `bash scripts/check-module-invariants.sh` exits 0 (no module added; a
  pre-existing `INV` drift on untouched READMEs is recorded as a gate collision on the issue log,
  not fixed here); `bash .claude/scripts/lean-sorry-census.sh` reports 0 over the resolved
  roots; `bash .claude/scripts/verify-deploy.sh` exits 0;
  `bash .claude/scripts/validate-artifact.sh <summary path> summary` exits 0.
- Markers: the phase heading reads `[COMPLETED WITH EXCLUSIONS]`, this `#### Reasoned
  Exclusions` subsection is present with its three rows and all of `Item | Reason | Evidence`,
  and the plan-level `- **Status**:` reads `[COMPLETED]`.
- `git status --short` shows no modified file outside the `Files to modify` set plus the task
  directory's own `.return-meta.json` / `issues.jsonl` / handoff and the orchestrator-owned
  `specs/TODO.md` / `state.json` / `events.jsonl`.

---

## Testing & Validation

- [x] Four kernel checks observed in-dispatch, each `[propext, Classical.choice, Quot.sound]`, no `sorry`.
- [x] `Limits/README.md`: old sentence count `0`, `exists_periodic_subfamily` present, "argued, not proved" lead kept, no record-versioning phrasing, exactly two diff hunks.
- [x] No `.lean` file changed anywhere in the task's commits (`git diff --stat -- '*.lean'` empty across them).
- [x] `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- [x] Full `lake build` (guarded) exits 0; `scripts/check-module-invariants.sh` exits 0 or its only failure is a pre-existing drift on files this task did not touch, recorded on the issue log; `lean-sorry-census.sh` 0; `verify-deploy.sh` exits 0.
- [x] `validate-artifact.sh` on the summary exits 0; the summary carries the exclusion table, the kernel output, the README hunk and the proposed ROADMAP text.
- [x] Phase heading `[COMPLETED WITH EXCLUSIONS]` with the `#### Reasoned Exclusions` record; plan Status `[COMPLETED]`. *(deviation: altered — plan-level Status left to postflight, see Phase 1)*
- [x] Issue log carries at least one entry from this implementation (win or issue), or an explicit attestation in the summary that nothing arose.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` -- closing paragraph amended to point at `exists_periodic_subfamily` / `exists_hitPresented` and to say precisely which transfer is not formalized and that nothing consumes it; `Last verified` updated.
- `specs/709_ctl_like_fragment_finite_model_property/plans/01_f4-reasoned-exclusion-record.md` -- this plan, closed with its `#### Reasoned Exclusions` record.
- `specs/709_ctl_like_fragment_finite_model_property/summaries/01_f4-reasoned-exclusion-record-summary.md` -- the implementation summary, including the proposed Stage 0 ROADMAP wording for the user.

## Rollback/Contingency

- **Per sub-step**: the README edit and the summary are committed on their own green sub-steps
  through `.claude/scripts/git-commit-scoped.sh`; a bad edit is reverted by `git revert` of its
  own commit. No working-tree rollback is required and none is to be taken as a routine
  precaution; a genuine rollback of uncommitted work takes the snapshot first per
  `context/contracts/recovery.md`'s rollback rung, and an ordinary defensive checkpoint uses
  `git-snapshot.sh --no-revert`.
- **If a kernel re-check disagrees with the report** (a declaration missing, renamed, or
  carrying a different axiom list): do not finalise the exclusion row that cites it. Mark the
  phase `[BLOCKED]`, record exactly which declaration differed and how, and raise it -- the
  exclusion's evidence must be observed, not carried.
- **If the Scope Hypothesis is falsified** (the old sentence appears more than once, or the
  paragraph has been restructured by a concurrent edit): re-read the README, apply the
  replacement to the one paragraph that carries the characterisation, and record the deviation
  on the issue log; a third hunk is a deviation to explain, not to hide.
- **If the user reverses the Stage 0 ruling** after this closes: the task's record is unchanged
  by that reversal; a new task is filed research-first against the named consumer, with the
  statement shaped as a corollary of `exists_periodic_subfamily` (report Rec. 2). Nothing here
  needs undoing: the README amendment remains true either way.
