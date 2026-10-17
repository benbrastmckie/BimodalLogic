# Implementation Summary: Task #709

- **Task**: 709 - ctl_like_fragment_finite_model_property (F4, finite width implies eventually periodic, as route R1's summary step)
- **Status**: [COMPLETED]
- **Started**: 2026-10-17T22:38:51Z
- **Completed**: 2026-10-17T22:49:32Z
- **Effort**: 0.5 hours
- **Dependencies**: 703, 710, 719 (all archived completed)
- **Artifacts**: plans/01_f4-reasoned-exclusion-record.md, reports/01_f4-summary-step-disposition.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task closes as the reasoned exclusion its own description pre-authorises, with the trigger
corrected: route R1 selected the Ramsey colour (probe E3, re-audited "UNCHANGED, verdict (i),
KEEP candidate (d)") and then landed its summary step over the time axis with no width
hypothesis (`exists_periodic_subfamily`, `exists_hitPresented`), so the finite-width form of F4
has no consumer, and its premise is refuted inside the target fragment by
`not_finite_width_fmp`. The one library edit is prose: the closing paragraph of
`PlusSlicedCertificate/Limits/README.md` now points at the landed theorems and says exactly which
transfer is not formalized. No `.lean` file was created or modified; no width bound is committed;
the refuted headline was not attempted.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` — closing
  paragraph of "What is refuted, and what is not" replaced with the plan's fixed text (lead
  sentence "argued, not proved" kept; old sentence "not formalized anywhere in this tree"
  removed; pointers to `exists_periodic_subfamily`, `exists_hitPresented`,
  `Fixture.not_tailStable_cert` added); `Last verified` line updated to 2026-10-17. Commit
  `7aba3abda`. Exactly two hunks; `git diff --stat -- '*.lean'` empty.
- `specs/709_ctl_like_fragment_finite_model_property/plans/01_f4-reasoned-exclusion-record.md` —
  Phase 1 heading advanced to `[COMPLETED WITH EXCLUSIONS]`; checklist items ticked and
  annotated with the observations below.
- No theorem, lemma, definition, or axiom was added anywhere.

### Kernel re-checks observed in this dispatch

All via `lean_verify` with `scan_source: true` (lean-lsp reachable; the first batch of calls
failed on argument validation because the tool requires `file_path` plus `theorem_name`, and
was retried with both). Each returned
`{"axioms":["propext","Classical.choice","Quot.sound"],"trust":"standard","non_standard_axioms":[],"warnings":[]}`:

| Declaration | File:line |
|---|---|
| `FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily` | `RaySummary/Periodic.lean:1562` |
| `FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented` | `RaySummary/HitComplete.lean:590` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` | `Limits/NoFiniteWidth.lean:1280` |
| `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture.not_tailStable_cert` | `FixtureStable.lean:357` |
| `...NoFiniteWidth.not_sliced_complete` (row 3 companion) | `Limits/NoFiniteWidth.lean:1257` |
| `...NoFiniteWidth.no_finite_width_sat` (row 3 companion) | `Limits/NoFiniteWidth.lean:1200` |

Other observations the exclusion rows rest on: E3 header, `device-selection-probe.lean:114`
"The selection is UNCHANGED — verdict (i), KEEP candidate (d)"; `RaySummary/README.md:99` and
`:517` "No finite-fibre or finite-width assumption"; grep of `FormalSystem/` for a safety /
bounded-step `⊡` fragment predicate (`bounded-step|boundedStep|BoundedStep|safetyFragment|
SafetyFragment|StabSafety`, case-insensitive) returns count `0`; `PlusFormula.BoxStabFree`
(`PlusLanguage/Subformulas.lean:291`) is the only nearby predicate and excludes every `□` and
`⊡`, so it is a different, smaller fragment.

### README diff hunk (commit `7aba3abda`)

```diff
diff --git a/FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md b/FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md
index e0c617d35..a6272c60b 100644
--- a/FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md
+++ b/FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md
@@ -75,9 +75,20 @@ and no carrier bound of any kind is proved; the defect on each axis is that the
 has no countermodel of that shape at all, not that known bounds are too small.
 
 **The semantic characterisation is argued, not proved.** The class is complete exactly on
-targets with a finite-width countermodel: necessity is this directory's shape, sufficiency —
-every finite-width model has an eventually periodic, hence tail-stable-presentable, finite-width
-model — is a Ramsey-for-pairs-style periodicity argument not formalized anywhere in this tree.
+targets with a finite-width countermodel: necessity is this directory's shape; sufficiency —
+every finite-width model has an eventually periodic finite-width model of the same width,
+presentable as a tail-stable certificate — is not a theorem of this tree, and nothing in this
+tree consumes it. The Ramsey-for-pairs periodicity argument it rests on *is* formalized, but over
+colourings of the time axis rather than over finite-width sliced structures:
+`exists_periodic_subfamily` (`FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean`)
+replaces each tail of a colouring of `ℤ` by one Ramsey-monochromatic period, with bounds that
+count pairs of profiles and no width hypothesis at all, and `exists_hitPresented`
+(`RaySummary/HitComplete.lean`) presents the result finitely. What is not formalized is the
+transfer of that periodicity back to a sliced structure of the same width, and the step from an
+eventually periodic model to a tail-stable certificate, which `Fixture.not_tailStable_cert`
+(`../FixtureStable.lean`) shows re-presentation does not supply in general. A width-level
+statement, should a consumer for one ever appear, is a corollary of `exists_periodic_subfamily`
+over the label colouring of a sliced structure's run, not a new Ramsey argument.
 
 ## Modules
 
@@ -125,4 +136,4 @@ depends on no axioms at all.
 
 ---
 
-*Last verified: 2026-10-10*
+*Last verified: 2026-10-17*
```

## Decisions

- Closed as `[COMPLETED WITH EXCLUSIONS]`, not `[COMPLETED]` and not `[PARTIAL]`/`[BLOCKED]`:
  all five admission conditions of `status-markers.md` hold (a decision, three enumerated
  items, each with a reason and kernel-checked evidence, nothing left for a future dispatch).
- The README amendment keeps the "argued, not proved" lead sentence and claims only what is
  landed: the periodicity argument over time-axis colourings, not a width-level statement.
- `specs/ROADMAP.md` was not edited; its Stage 0 ruling is reserved to the user (text below).
- The prior cycle's Option A answer was adopted autonomously, not by a user ruling; everything
  here is reversible (a prose edit and a record).

#### Reasoned Exclusions (verbatim from the plan)

| Item | Reason | Evidence |
|------|--------|----------|
| F4, finite-width form: "every finite-width sliced structure satisfying a target has an eventually periodic, hence tail-stable-presentable, model of the same width" (the task's outcome-(i) statement and its 40-80 h route) | R1 selected the Ramsey colour, not an acceptance condition, and then landed its summary step over the time axis with no width hypothesis; the finite-width form is consumed by no live route (R1 carries no width; the sliced class's decidability route is closed as a refutation record; R2 is `[HOLD]` and a consumer of R1); its premise is refuted for the fragment at large; and its "hence tail-stable-presentable" clause needs a bridge that re-presentation does not supply | E3 verdict and re-audit in the header of `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` ("KEEP candidate (d)"); `FormalSystem.Metalogic.WeakCanonical.exists_periodic_subfamily` (`RaySummary/Periodic.lean:1562`) and `FormalSystem.Metalogic.Decidability.RaySummary.exists_hitPresented` (`RaySummary/HitComplete.lean:590`), each `[propext, Classical.choice, Quot.sound]`; `RaySummary/README.md` "No finite-fibre or finite-width assumption"; `...PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` (`Limits/NoFiniteWidth.lean`); `...PlusSlicedCertificate.Fixture.not_tailStable_cert` (`FixtureStable.lean:357`) |
| Fallback fragment restriction: `⊡` limited to safety and bounded-step operators (`⊡G`, `⊡X^k`), with a finite-width statement for that sub-fragment | This was the alternative *under outcome (ii)* (R1 selects an acceptance condition), which did not occur; under the actual outcome it has no consumer either, and no in-tree fragment predicate exists for it (`PlusFormula.BoxStabFree`, `PlusLanguage/Subformulas.lean`, is a different and smaller fragment) | Report F-5 and F-6; `specs/ROADMAP.md` Stage 1 "proceeds on R1 alone; there is no fallback"; grep of `FormalSystem/` for a safety / bounded-step `⊡` fragment predicate returns none (re-run at implement time: count `0`) |
| The filed headline: the finite model property for the CTL-like fragment against the time-sliced certificate class | Refuted as a theorem, inside the fragment, by the witness `Φ := (A' ∧ C') ∧ D`; the task's HARD CONSTRAINTS say it must not be attempted and that the obstruction theorem discharges the "record the obstruction" constraint | `...PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`, `not_sliced_complete`, `no_finite_width_sat` (`Limits/NoFiniteWidth.lean`), each `[propext, Classical.choice, Quot.sound]`, sorry-free (`Limits/README.md` "This subtree is sorry-free") |

## Plan Deviations

- **Phase 1, item "set the phase heading to `[COMPLETED WITH EXCLUSIONS]` and the plan-level
  Status to `[COMPLETED]`"** altered: the phase heading was set as planned, but the plan-level
  `- **Status**:` field was left untouched because it is owned by `update-plan-status.sh`
  (invoked from `update-task-status.sh` postflight), not by the implementation agent; postflight
  stamps it.
- No other deviation; every other item ran as written.

## Verification

- Build: Success — `lake-build-guard.sh build --timeout 1800 -- build`, foreground under
  `timeout 590`, `GUARD_EXIT=0`, "Build completed successfully (2875 jobs)", `grep -c 'error:'`
  = 0 over the captured log; no `.lean` module touched, so the per-module olean check is vacuous
  (expected no-op build).
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved roots `FormalSystem`,
  `Tests/BimodalTest`, `BimodalTools`, `Tests/BimodalToolsTest`)
- Vacuous count: 0 (no `.lean` changed)
- Axiom count: 14 (`grep -rn "^axiom "` over the resolved roots), unchanged — no `.lean` changed
- Tests: N/A (no Lean changed; full build covers `Tests/`)
- README greps: old sentence `0`; `exists_periodic_subfamily` `2`; "argued, not proved" `1`;
  `no longer|previously|formerly|used to|supersedes` `0`; `git diff` hunks `2`.
- `check-task-references.sh --quiet`: PASS, 0 occurrences outside `specs/`.
- `scripts/check-module-invariants.sh`: ALL CHECKS PASSED (exit 0; no pre-existing drift).
- `verify-deploy.sh`: PASS, 15 checks, 0 failures.
- `validate-artifact.sh` on this summary: PASS, 0 warnings (run before the phase-closing commit).
- Files verified: Yes
- Issue log: one `win` (clean first-pass kernel re-checks and Scope Hypothesis) and one minor
  `issue` (`lean_verify` argument shape differs from the agent doc) recorded during the phase;
  nothing else arose.

## Impacts

- `Limits/README.md` now tells a reader where the periodicity argument lives
  (`RaySummary/Periodic.lean`) and precisely which transfer is unformalized and unconsumed, so
  the "argued, not proved" characterisation is honest without a misleading "nowhere in this
  tree".
- Route R1 and the decidability programme are unaffected: nothing consumed the finite-width F4
  form, and nothing new is exported.
- `specs/ROADMAP.md` still lists 709 under "Not batched, and why" pending the user's Stage 0
  tick.

## Proposed ROADMAP text (user-applied)

Two lines for `specs/ROADMAP.md`, to be applied by the user when ticking the Stage 0 ruling:

1. Replace the bullet "Re-rule on **709**'s value before dispatching it. ..." with:
   `- [x] **709** closed 2026-10-17 as a reasoned exclusion: R1 selected the Ramsey colour (E3)
   and landed the summary step over the time axis with no width hypothesis
   (`exists_periodic_subfamily`, `exists_hitPresented`), so the finite-width F4 form has no
   consumer; record in specs/709_ctl_like_fragment_finite_model_property/summaries/01_f4-reasoned-exclusion-record-summary.md`
2. In "Not batched, and why", change "**127, 128 and 709** await Stage 0 rulings" to
   "**127 and 128** await Stage 0 rulings" once the ruling is ticked.

## Follow-ups

- None for this task. If the user reverses the Stage 0 ruling, file a new research-first task
  against a named consumer, with the statement shaped as a corollary of
  `exists_periodic_subfamily` over the label colouring of a sliced structure's run.
- Optional `/meta` item (agent-system source store, outside this repository): note in the lean
  implementation agent that `lean_verify` takes `file_path` and `theorem_name`.

## References

- specs/709_ctl_like_fragment_finite_model_property/plans/01_f4-reasoned-exclusion-record.md
- specs/709_ctl_like_fragment_finite_model_property/reports/01_f4-summary-step-disposition.md
- specs/709_ctl_like_fragment_finite_model_property/.decisions.json (cycle-1 Option A answer)
- specs/evidence/seam-gluing-ray-product/device-selection-probe.lean (E3)
- FormalSystem/Metalogic/Decidability/RaySummary/Periodic.lean, HitComplete.lean, README.md
- FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth.lean, README.md
- FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean
- specs/ROADMAP.md (Stage 0 "Re-rule on 709", "Not batched, and why")
