# Implementation Summary: Task #867

- **Task**: 867 - Formalize Gabbay separation over discrete time for `PlusFormula`, discharging `SeparationOver TaskFrame.IsZTime` and making the open-future translation executable
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-05T00:00:00Z
- **Completed**: 2026-11-05T01:30:00Z
- **Effort**: one implement dispatch
- **Dependencies**: None blocking
- **Artifacts**: plans/01_gabbay-separation-ztime-plusformula.md, reports/01_gabbay-separation-ztime-plusformula.md, prototype/cases-5-8-probe.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-6 and 14-15 of the fifteen-phase plan landed, sorry-free and gate-green: a new
`FormalSystem/Metalogic/Expressiveness/SeparationZ/` subtree carrying the auxiliary until/since
syntax over abstract leaves, the one seam to `PlusFormula`, GHR Lemmas 10.2.1 and 10.2.2 in
full, and GHR Lemma 10.2.3's four cases in which the eliminated `until` occurs in exactly one of
the two arguments of the `since`. Phase 5's decision gate measured **1 of 4** against a
criterion of 4 of 4, which triggered the plan's primary contingency branch: Phases 7-13 closed
`[COMPLETED WITH EXCLUSIONS]`.

**The task's headline deliverable was not reached.** `SeparationOver TaskFrame.IsZTime` is not
discharged, `separationOver_ztime` does not exist, and no `tr` row in `OpenFutureElimination.lean`
changed. Nothing in the tree reads as if it had.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Syntax.lean` — new. `USForm`
  (leaf/bot/imp/untl/snce, guard-first), `usTruth` over `ℤ`, the eleven derived connectives and
  their clause lemmas, the time reflection `swap` with `swap_involutive` and `usTruth_swap`, and
  `maxLeaf`/`freshLeaf` with `usTruth_congr` and `usTruth_congr_of_update`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/LeafAbstraction.lean` — new. `leaves`
  (nodup, doubly pure), `leafVal`, `abstrWith`/`abstr`, `toPlus`, the roundtrip `toPlus_abstr`,
  `IsUOnly`/`IsSOnly` with their closure and `swap` lemmas, `isPureFuture_toPlus` /
  `isPurePast_toPlus`, the truth transfer `usTruth_toPlus_iff` at `t : ℤ`, and the carrier
  bridge `pointwise_ztime_of_pointwise_int`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Distributivity.lean` — new. The duality
  combinator `usTruth_swap_congr` and GHR 10.2.1's four Boolean distributivities, the two `snce`
  cases derived through the combinator. Linearity only, confirmed mechanically.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NegationEquiv.lean` — new.
  `exists_least_above` (the `ℤ` least-witness device, on `Int.exists_least_of_bdd`) and GHR
  10.2.2's four negation equivalences, printed and variant forms, past sides by duality.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Eliminations.lean` — new.
  `usTruth_snce_congr`/`usTruth_untl_congr`, the `IsSeparated` predicate with its closure
  lemmas, the `G`-under-`S` elimination `usTruth_snce_allFuture`, `case1Rhs`…`case4Rhs`,
  `usTruth_case1`…`usTruth_case4`, and `isSeparated_case1Rhs`…`isSeparated_case4Rhs`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` — new. Module table, an explicit
  "the hypothesis is NOT discharged" status section, and a `## Not landed` section.
- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean` — new. The pinned
  Case 5 candidate, its derivation, and six compiled probe theorems over three `ℤ` models.
- `FormalSystem/Metalogic/Expressiveness.lean` — the five new modules added to the import list,
  plus an architecture entry and a corrected `## Main Exports` paragraph.
- `FormalSystem/Metalogic/Expressiveness/README.md` — a `SeparationZ/` row, live contents
  re-derived to 149 modules across 5 subdirectories, refreshed `Last verified`.
- `docs/theorem-index.md` — a 20-row sub-band for the landed `ℤ` validities, and a factual
  correction to the Expressiveness band preamble. No row's conditionality weakened.
- `scripts/check-module-invariants.sh` — 19 matched C14 pairs in both heredocs.
- `Boneyard/Kamp/KampWeakCanonical/Separation/README.md` — the `replace_box_with_top` caveat.
- `FormalSystem.lean`, `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md`,
  `FormalSystem/Metalogic/README.md` — regenerated, never hand-adjusted.

## Decisions

- **Phase 5's gate was run as a real measurement, not a formality.** A Case 5 candidate was
  derived from the semantics — split on the pure-future `U(A,B)@t`, rewrite `U(A,B)@r` for
  `r < t` as the re-anchored `¬bad*(r)` (resp. `¬bad*(r) ∧ ¬C(r)`), then re-anchor the
  guard-failure condition at its own rightmost witness — and probed on three concrete `ℤ`
  models. It survives all three, including the model that refutes GHR's printed formula.
- **The duality was packaged once**, as `usTruth_swap_congr`. Every past-side statement in GHR
  10.2.1 and 10.2.2 is then one `simpa` line. This paid for itself immediately and is the idiom
  every later phase would have reused.
- **GHR 10.2.2's variant form (guard `B ∧ ¬A`) is proved first**, because that is what the
  least-`¬B` witness actually delivers; the printed form follows by weakening the guard.
- **`IsSeparated` landed in Phase 6's module** rather than Phase 8's, because Phase 6's own
  verification criterion requires each case's separatedness to be discharged and Phase 8 is
  excluded. Its definition is verbatim the one Phase 8's task list specifies.
- **Nothing was weakened to make a gate pass.** No `sorry`, no vacuous definition, no
  `noncomputable` keyword added anywhere, no conditionality removed from any documentation
  surface, no C14 profile hand-typed.

## Plan Deviations

- **Phase 5** closed `[COMPLETED WITH EXCLUSIONS]`: its deliverable was four candidates and it
  produced one. Cases 6-8 recorded in its `#### Reasoned Exclusions`.
- **Phases 7-13** closed `[COMPLETED WITH EXCLUSIONS]` under the plan's primary contingency
  branch, each with a `#### Reasoned Exclusions` table citing Phase 5's measurement.
- **Phase 8**'s `IsSyntacticallySeparated` item altered: landed early as `IsSeparated` in
  Phase 6's `Eliminations.lean`.
- **Phase 14** closed `[COMPLETED WITH EXCLUSIONS]`: the `OpenFutureElimination.lean` docstring
  amendment and the restatement of the three `.ZTime` rows are **skipped**, exactly as the
  contingency branch requires; the C14 pairs cover the 19 landed declarations rather than the
  seven contract declarations.
- **Phase 14's doc-sync counts arrived earlier than planned.** The pre-commit
  `typst-sync-check.sh --counts-only` gate fires on every module-adding commit, so
  `typst/generated/status.typ` was regenerated and staged at each module-adding phase instead of
  once in Phase 14. Recorded in `issues.jsonl`.
- **Phase 15** discharged against the dispatch's **scoped** verification tier per its Batch Gate
  Deferral directive; see `## Verification`.

## Verification

- Build: **Success**. Guarded unscoped `lake build` green (2913 jobs, 0 errors), with the
  `.olean` of every module this task touched newer than its source. Guarded scoped builds green
  for the aggregator (`FormalSystem.Metalogic.Expressiveness`, 1649 jobs) and for the test
  library (`BimodalTest`, 2977 jobs, 0 errors).
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots; C3 independently
  reports the structural inventory is ZERO tree-wide).
- Vacuous count: **0** over the new subtree and the prototype.
- Axiom count: **0 new**. Every profile measured by `#print axioms` against the built tree in
  this same run, none exceeding the pre-task ceiling `[propext, Classical.choice, Quot.sound]`:
  `[propext, Quot.sound]` for `usTruth_swap` and `usTruth_congr_of_update`, `[propext]` for
  `usTruth_toPlus_iff`, the ceiling for the other 16 pinned declarations, and axiom-free for
  `isPureFuture_toPlus`, `isPurePast_toPlus` and the four `isSeparated_caseNRhs`.
- `scripts/check-module-invariants.sh`: every group PASS **except C16**, which reports one
  `unusedArguments` finding on
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136`. That file was last
  modified 2026-11-03, two days before this task's first commit, and is in no part of this
  task's file set — a **pre-existing** failure, reported rather than baselined. C3, C4, C5, C8,
  C9, C14 (both assertions), C15 (both assertions), C33 and the generated-inventory check are
  green.
- `scripts/check-metalogic-cycles.sh`: all three assertions PASS. No `SeparationZ` module
  imports any `FormalSystem.Metalogic.<other-subdirectory>` module, and the allowlist is
  unchanged.
- `scripts/readme-lint.sh FormalSystem`: PASS. `scripts/check-copyright-headers.sh --strict`:
  0 nonconforming. `scripts/typst-sync-check.sh --counts-only`: MISMATCH_COUNT=0.
- No added declaration carries `noncomputable`.
- **Full gate set deferred to the batch stage.** Per this dispatch's Batch Gate Deferral
  directive, Phase 15 was discharged against a scoped tier. No gate of
  `.claude/scripts/verify-deploy.sh` and no suite of `.claude/scripts/tests/run-all.sh` maps to
  this task's touched paths — that script compares the deployed `.claude/` tree against the
  source store and references neither `check-module-invariants.sh`, `readme-lint.sh`,
  `docs/theorem-index.md` nor `lake build` — so the repository's own Lean and documentation gate
  set was run in full instead, as listed above. `verify-deploy.sh`'s complete battery is
  deferred to the batch stage, never forgiven; the dispatch's own deploy-freshness context
  additionally records the deployed tree as stale for the `core` and `literature` extensions,
  which is independent of this task.
- Tests: Passed (`BimodalTest` builds clean).
- Files verified: Yes.

## Impacts

- Five new modules are reachable from `FormalSystem.Metalogic.Expressiveness` and from the
  generated root. GHR 10.2.1, GHR 10.2.2 and GHR 10.2.3's four single-sign cases are now
  available as unconditional `ℤ` validities over the auxiliary syntax, with a proved seam
  (`usTruth_toPlus_iff`, `toPlus_abstr`, `pointwise_ztime_of_pointwise_int`) carrying statements
  between that syntax and `PlusFormula` on a `ℤ`-carrier frame.
- Nothing downstream changed behaviour. `OpenFutureElimination.lean` is byte-unchanged;
  `FormalSystem/Metalogic/Independence/` was not touched; the metalogic-cycles allowlist is
  unchanged; every `.RTime`, `.Dense` and `.Base` statement reads exactly as before.
- A successor dispatch inherits a pinned, probed Case 5 candidate and a recorded derivation, so
  Case 5 can be attempted without re-deriving anything.

## Follow-ups

- **A user decision is wanted before more work on this route.** The task description itself asks
  for the GHR route to be weighed against the MSO/Rabin decidability route, which reaches a
  decidability answer for the open language at `.ZTime` with no translation at all. The GHR
  route now has a precisely located obstruction at GHR 10.2.3's Cases 6-8, so that comparison is
  live rather than hypothetical.
- Prove Case 5 in the library from the pinned candidate. It is mathematically unblocked and
  would be a correct formalization of a case the source gets wrong, but it does not by itself
  reach 10.2.4, which consumes all eight cases.
- Cases 6-8 need either a published correct form over the integer flow or a measure-carrying
  device bounding the re-anchoring chain. Over `ℤ` each re-anchoring step crosses one `¬B` point
  and the window below the evaluation point is finite, so a bounded chain exists for every fixed
  model; what is missing is a single finite formula serving every model.
- The pre-existing C16 finding on `LadderChain.lean` belongs to whoever owns that file.

## References

- `specs/867_formalize_gabbay_separation_ztime/plans/01_gabbay-separation-ztime-plusformula.md`
- `specs/867_formalize_gabbay_separation_ztime/reports/01_gabbay-separation-ztime-plusformula.md`
- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`
- `specs/867_formalize_gabbay_separation_ztime/handoffs/` — per-phase handoffs 1-6 and 14
- GHR vol. 1, Chapter 10 §10.2, Lemmas 10.2.1-10.2.8 and Theorem 10.2.9
