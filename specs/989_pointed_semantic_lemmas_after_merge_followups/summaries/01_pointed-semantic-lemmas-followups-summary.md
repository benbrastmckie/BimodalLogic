# Implementation Summary: Task #989

- **Task**: 989 - Pointed semantic lemmas: after-merge follow-ups
- **Status**: [COMPLETED]
- **Started**: 2026-11-25T01:25:00Z
- **Completed**: 2026-11-25T02:35:00Z
- **Effort**: ~1.2 hours
- **Dependencies**: None
- **Artifacts**: plans/01_pointed-semantic-lemmas-followups.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The three after-merge follow-ups from the posted review of the pointed semantic lemmas
contribution all landed: a positive universal-existential reading beside `release_iff`/
`trigger_iff`, titled module docstrings plus one `assert_not_exists` spelling across the generic
`FormalSystem/Semantics/` modules, and two primitive-tense persistence lemmas that reach L⁻ plus
L⋆ versions of the time-shift and state-local transport factories. Ten new declarations landed
across four library modules, each carrying at least one test row, and every one of them is
stated over the clause classes so it is proved once for every language.

## What Changed

- `FormalSystem/Semantics/TemporalIntervals.lean` — `release_iff_forall` and `trigger_iff_forall`,
  the direct universal-existential readings of the strict release and trigger clauses, each proved
  from the existing negated-clause lemma by `rw` + `constructor` + `by_contra`/`push Not`; plus a
  titled module docstring and the directory-form lock.
- `FormalSystem/Semantics/TemporalRules.lean` — a new `TensePersistence` section with
  `allFuture_persist_of_tense` and `allPast_persist_of_tense`, stated over
  `AllFutureClause`/`AllPastClause` alone so they reach L⁻, which has `TenseClauses` and no
  `untl`; both are explicit terms, no tactic block; plus a titled docstring and the lock.
- `FormalSystem/Semantics/RankProgress.lean` — titled module docstring and the directory-form lock.
- `FormalSystem/Semantics/PointTransport.lean` — two L⋆ imports; lock respelled and extended;
  `SameStateNowEnv` and `ShiftedEnv` (env-aware strengthenings of `SameStateNow` and `Shifted`)
  with their `.intro` lemmas, added beside the existing relations rather than replacing them; a
  new `Star` section with `star_iffTransport_timeShift` and `star_iffTransport_stateLocal`;
  docstring `## Main Results`, `## References`, `## Tags` and a paragraph recording why this
  module's lock cannot take the directory form.
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` — a `MinusTruth` import, `MinusLanguage`
  added to the opens, and five new rows (release at L, release at L⋆ via the spelled-out
  encoding, trigger at L, and the two L⁻ persistence rows).
- `Tests/BimodalTest/Semantics/PointTransportTest.lean` — `StarLanguage` added to the opens and
  one row per L⋆ factory, which also give the two relations and both `.intro` lemmas their
  dead-declaration-scan references.
- `typst/generated/status.typ`, `README.md` — regenerated in every phase that moved a Lean line
  count, so no phase's own verification ran against a stale tree.

## Decisions

- The `Axiom`-rooted directory lock form was confirmed as the directory norm before adopting it:
  a census of all 20 locks under `FormalSystem/Semantics/**` found 11 using the exact two-name
  `Axiom DerivationTree` spelling and 5 more using a four-name form that extends it, so 16 of 20
  share that prefix.
- `PointTransport.lean` keeps a `DerivationTree`-rooted lock, with the measured import chain
  recorded in its own docstring where the next reader will be standing. Naming `Axiom` there is a
  compile error, not a tightening, because the module's closure already carries it.
- The env-aware relations were added rather than substituted, leaving `SameStateNow`, `Shifted`
  and both their `.intro` lemmas byte-identical, so the existing L⁺ factories and their test rows
  are untouched.
- Deliberately out of scope, as the plan set: named `release`/`trigger`/`weakUntil` operators at
  the signature layer, the `next_iff_covBy` promotion, any `docs/theorem-index.md` row, and an L⋆
  reversal factory (there is no `starTruthAt_rev` to wrap).

## Plan Deviations

- None (implementation followed plan). Every one of the ten pinned declarations compiled at its
  plan-pinned signature, every proof took the plan's stated skeleton, and both plan contingency
  branches (a generic module unable to take the directory lock; a `check-metalogic-cycles.sh`
  allowlist surplus) went unused because neither condition arose.

## Verification

- Build: Success — full guarded `lake build`, exit 0, 3027 jobs, zero `error:` and zero
  `warning:` lines, and the `.olean` of all six touched modules newer than its source.
- Sorry count: 0
- Vacuous count: 0 attributable (two pattern matches exist, both byte-identical to their pre-task
  text; `AnyPoint := True` is the correct semantics of "any two points", not a placeholder)
- Axiom count: 14, identical to the pre-task baseline
- Tests: Passed — seven new test rows compile, spanning L, L⁻, L⁺ (unchanged rows) and L⋆
- Files verified: Yes
- Axiom profiles: all six new theorems measured via `lean_verify`; every profile matches the
  plan's prediction and none exceeds it. `allFuture_persist_of_tense`,
  `allPast_persist_of_tense` and `star_iffTransport_stateLocal` are `[propext]`; the other three
  are `[propext, Classical.choice, Quot.sound]`.
- Green gates: `scripts/typst-sync-check.sh` (full), `check-module-invariants.sh
  --emit-inventory --check`, `scripts/check-metalogic-cycles.sh` (all three assertions).
- Red findings, all proven pre-existing and naming no file this task touched: `C14` axiom-set
  divergence (one baseline entry targets a declaration renamed to `..._clip_pre` before this task
  began), `C16` roots-baseline ceiling (six entries in `BimodalLibTest`,
  `BimodalTest.Automation` and `BimodalTools.*`), and 16 agent-system shell suites under
  `verify-touched.sh`. Full detail, with the per-finding pre-existence proof, is in the plan's
  Phase 5 `#### Verification Notes`.
- The complete agent-system gate set is deferred to the once-per-invocation batch gate stage at
  the orchestration close and was not independently run here.

## Impacts

- A refutation script can now consume release and trigger in the form that names a witness rather
  than denying one, at every language instantiating the clause classes.
- L⁻ gains tense persistence for the first time: the existing `untl`-derived `allFuture_persist`
  cannot reach a language whose tenses are primitive, and the new siblings can — at a strictly
  cleaner axiom profile than the lemmas they sit beside.
- L⋆ gains the two transport certificates it was missing, and the env-aware relations they are
  indexed by are reusable by any future language whose evaluation environment carries information
  rather than being `PUnit`.
- The four contributed modules now carry the same docstring shape and lock spelling as the rest of
  their directory, so a reader moving between them meets one convention.

## Follow-ups

- The `C14` baseline entry in `scripts/check-module-invariants.sh` still targets
  `exists_kappa_collision_cellAt_ne_at_K4_clip` where the tree declares
  `exists_kappa_collision_cellAt_ne_at_K4_clip_pre`. Repairing that one-line baseline staleness
  belongs to whoever owns the ladder naming, not to this record.
- The `C16` roots-baseline ceiling has six entries with no baseline row at all
  (`BimodalLibTest.DiagnosticsTest`, `BimodalTest.Automation.ProofModeTemporalTest`, four
  `BimodalTools.*`), which suggests the roots baseline was never populated for those modules.
- No L⋆ reversal factory exists because there is no `starTruthAt_rev` to wrap; it becomes
  available the moment that transfer result lands.

## References

- `specs/989_pointed_semantic_lemmas_after_merge_followups/plans/01_pointed-semantic-lemmas-followups.md`
- `specs/989_pointed_semantic_lemmas_after_merge_followups/reports/01_pointed-semantic-lemmas-followups.md`
- `specs/989_pointed_semantic_lemmas_after_merge_followups/handoffs/` — the five per-phase handoffs
- `FormalSystem/Semantics/StateLocalTransfer.lean` — the module-docstring shape the three generic
  modules were brought into
