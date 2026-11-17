# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem (the READ-OFF / CONSTRUCTION pair)
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-17T02:15:00Z
- **Completed**: 2026-11-17T03:40:00Z
- **Effort**: ~1.5h (one dispatch; Phase 21 is NOT COSTABLE by its own ruling and this round is not a cost figure for it)
- **Dependencies**: None open
- **Artifacts**: plans/34_readoff-construction-pair-restatement.md, records/round-34-readoff-construction-pair.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 21 was re-entered to discharge decision 29's obligation: ATTACK the construction half's
truth lemma at its landed serial-vs-liftable tension, attacking one of the two landed key-level
relations rather than designing a third. The round attacked BOTH, at a single explicit
`certAdmK`-certified fixture, and **both are refuted by compilation**: the uniform relation
`conStepStrong` is not serial under `certAdmK`, and the weak relation `conStep`'s edges do not
compose inside the certified set — already at length TWO. The truth lemma itself is neither
proved nor refuted; what is now closed is both of its candidate routes.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — new append-only section
  `## The two landed key-level relations, ATTACKED — and both refuted` (namespace `ConAttack`
  plus two top-level schema refutations). Landed: the certified fixture `attR` with
  `att_certAdmK` (all six conditions, the `⊡`/`□` acceptance clauses present and vacuously
  discharged, never dropped); `conStepStrong_not_serial` and the schema
  `conStepStrong_serial_refuted`; `no_lift_sK1_sK0_sK2` and the schema
  `conStep_two_step_lift_refuted`; the supporting edge/non-edge, fibre and closure lemmas.
  In-source `longFile` baseline raised in place 2700 → 3100; no module split, no landed
  declaration edited or re-proved.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — five `#print axioms` pins
  (`att_certAdmK`, `conStepStrong_not_serial`, `no_lift_sK1_sK0_sK2` and both schemas); baseline
  raised in place 4000 → 4100.
- `docs/theorem-index.md` — the construction bullet's "where the remaining content sits" sentence
  replaced: both relations now carry compiled refutations, with the common cause named.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `typst/generated/status.typ` —
  regenerated inventory/line-count blocks.
- `specs/761_ladder_realization_theorem/records/round-34-readoff-construction-pair.md` — §21-§25:
  which phase ran and why, the fixture and its separating mechanism, the two verdicts, the
  non-establishment list, and the carried-figure check.
- `specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md` —
  Phase 21's open task annotated, a second `#### Recorded Outcome` block and a structured
  `**BLOCKER**` entry added; marker stays `[PARTIAL]`.

## Decisions

- **Attack both relations, not one.** Decision 29 required attacking one. The fixture designed
  for `conStepStrong` turned out to refute `conStep`'s liftability as well, at no extra cost, so
  both were landed. Nothing was weakened to achieve this and no third relation was designed.
- **Degenerate parameters (`Tc = Tn = P = B = 0`) are deliberate, not a shortcut.** The
  construction half takes `certAdmK` as an explicit hypothesis and consumes no parameter
  condition, so a refutation at any parameter tuple refutes the quantified statement; choosing
  the tuple where `CK` is a subsingleton makes the obstruction visibly structural (an object
  coordinate) rather than an artefact of the clip.
- **The fixture lives in the library module, not in `specs/evidence/`.** Phase 21's "Files to
  modify" names `LadderRealize.lean` and the module already carries a concrete fixture
  (`K4ClipWitness`, `exists_paramsOk_real_not_certAdmK`); keeping the refutations beside the
  objects they refute puts them under `lake build` rather than under a separate probe gate.
- **Phase 21 stays `[PARTIAL]`, not `[BLOCKED]`.** This plan's own ruling at Phase 11.44 records
  that `[BLOCKED]` is re-selected by every resume scan; `[PARTIAL]` is the plan's settled marker
  for an open phase owing a `/revise`. The blocker itself is written out in the phase body.

## Plan Deviations

- **Phase 21, task "Build the frame from `relK`, its valuation, and the truth lemma"** altered
  (second annotation on the same item): the truth lemma is still not landed. What this round
  changed is that both of its candidate routes are now closed by compilation rather than open.
  Annotated inline on the checklist item.
- The dispatch's Phase Mission named **Phase 11.44**; that heading's `RE-ENTRY NOTICE` is a rule
  redirecting to the first open phase at or after 11.48, which is 12.2 `[BLOCKED]`, and decisions
  27 and 29 route past 12.2 to Phase 21 by name. Phase 21 was run; recorded in record §21.

## Verification

- Build: Success — `lake build` (full project) exit 0, zero `error:` lines, 2976 jobs;
  `lake build BimodalTest` exit 0, 3044 jobs. Both `.olean`s newer than their sources.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots, exit 0)
- Vacuous count: 0 introduced — the single repo-wide grep hit
  (`FormalSystem/Examples/TemporalStructures.lean:495`) is pre-existing and genuine
- Axiom count: unchanged — `git diff 9d891d118 -- FormalSystem Tests | grep -c '^+axiom '` = 0;
  every landed declaration reports `[propext, Classical.choice, Quot.sound]`
- Gates: `check-module-invariants.sh` PASS, `readme-lint.sh` PASS, `typst-sync-check.sh` PASS,
  `check-evidence-probes.sh` PASS
- Phase-close re-checks: `grep -rnE '(theorem|lemma|def|abbrev) +(cellAt_const_of_kappa_eq|ladderRealized)\b' FormalSystem/ Tests/`
  → no hits; `grep -rnE '(theorem|lemma) +dmax_(certStabK|certBoxK|certAdmK)\b' FormalSystem/`
  → no hits (the reason the construction is stated at an arbitrary `R`)
- All-φ check: neither landed schema carries a `BoxStabFree` binder; the fixture's closure simply
  has no `⊡`/`□` letter, and conditions (5) and (6) are discharged rather than dropped
- Files verified: Yes

## Impacts

- The construction half's open content is now a ROUTE question with both predecessors closed by
  compilation, not an unexplored gap. Any future attempt must supply a step relation that is both
  serial under `certAdmK` and liftable into `R`; the two obvious candidates are provably not it.
- `conStep_two_step_lift_refuted`'s length-two failure retires, before anyone writes it, the
  repair of restricting the lifting demand to finite windows.
- The fixture `ConAttack.attR` is the tree's first positive `certAdmK` witness under `lake build`
  (the only prior one, `real_subset_Dmax_stepFrag`, is parametric and lives in an evidence probe;
  the library's only other `certAdmK` statement is a refutation). It is reusable for any further
  attack on the construction direction.

## Follow-ups

- **A `/revise` is owed** and is surfaced as a `user_decision` on this dispatch's return metadata:
  this plan carries no phase for designing a third step relation, and decision 29 forbade
  designing one inside this round.
- Guardrail (b) is still not met: the constructed model's slice `ConKey` is finite. Recorded as a
  finding of the construction, untouched by this round and not treated as discharged.
- The READ-OFF half (Phase 20) is still unstarted and still has no landed route to its
  conclusion; Phase 12.2 remains `[BLOCKED]`.

## References

- `specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md` — Phase 21
- `specs/761_ladder_realization_theorem/records/round-34-readoff-construction-pair.md` — §13-§20 (dispatch 86), §21-§25 (this dispatch)
- `specs/761_ladder_realization_theorem/reports/31_gkwz-ptl-s5-quasimodels.md` — the literature shape the construction transfers from, BY SHAPE only
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — the landed objects
- `docs/theorem-index.md` — the construction-direction bullet
