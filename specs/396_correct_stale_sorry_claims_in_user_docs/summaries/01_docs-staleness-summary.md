# Implementation Summary: Task #396

**Completed**: 2026-07-26
**Duration**: ~1.5 hours

## Overview

Corrected every claim in `Theories/Bimodal/docs/` (across the ten files named in `DECISION.md`)
that misrepresented the proof status of the Lean sources, per the research report's per-hit table
and the plan's canonical status vocabulary (CS-1 through CS-8). STALE status claims were rewritten
to verified facts; SCHEMATIC pedagogical `sorry` blocks that reuse real theorem names were left
byte-identical and given a prose disclaimer. No `.lean` file was modified.

## What Changed

- `Theories/Bimodal/docs/user-guide/architecture.md` — inserted a status-note callout after the
  six-stub perpetuity code block (byte-identical code, disclaimer only); rewrote the stale
  "Partial metalogic: Soundness (5/8 axioms proven)" bullet to the current complete-metalogic
  statement (CS-2/CS-3).
- `Theories/Bimodal/docs/project-info/implementation-status.md` — `Completeness.lean` row and
  prose block rewritten to CS-3 (dropped the `Tasks 132-135, 257` citation); perpetuity table P6
  row and section header changed to Complete/100%; `Layer 3: Theorems` header changed to Complete
  (all subsections now read complete); `ModalS4.lean` row changed to ✅; `ProofSearch.lean` row
  replaced with the two real module paths (`Automation/ProofSearch/Core.lean`,
  `.../Strategies.lean`), both ✅, and the stale build-error bullet removed; Examples section and
  table replaced per CS-5 (`BimodalProofs.lean`, `TemporalStructures.lean`, both 0 sorries);
  Overall Statistics sorry count corrected to 12 with the CS-1 per-file breakdown.
- `Theories/Bimodal/docs/project-info/known-limitations.md` — Limitation 1 retitled and rewritten
  to name the real completeness theorems and residual `sorryAx` scope (dropped the phantom
  `provable_iff_valid` name and the `Tasks 132-135, 257` citation); Limitations 2-5 retitled
  `(Resolved)` with bodies replaced per CS-6/CS-5/CS-8/CS-7 respectively, heading numbers 1-5
  preserved, no renumbering; "What Works Well" perpetuity line extended to P1-P6 with the
  Aesop-integration caveat.
- `Theories/Bimodal/docs/project-info/README.md` — Completeness and Known Sorries metric lines
  corrected per CS-3/CS-1.
- `Theories/Bimodal/docs/project-info/tactic-registry.md` — `TMLogic` rule-set row and the
  `perpetuity_1`-`perpetuity_6` Safe Rules line rewritten to separate proof status (proven) from
  Aesop-integration status (not registered), per CS-4. Deliberately did not touch the `tm_auto`
  row or the "Registered Rules" name-accuracy issue (Non-Goals).
- `Theories/Bimodal/docs/project-info/test-coverage.md` — inserted a "Superseded" banner under the
  Version line pointing to `known-limitations.md`/`implementation-status.md`; zero numeric edits
  (verified insertion-only diff).
- `Theories/Bimodal/docs/user-guide/troubleshooting.md` — ProofSearch entry retitled
  "(historical)" and rewritten to CS-6, dropping the `Task 260` citation.
- `Theories/Bimodal/docs/user-guide/examples.md` — Completeness scaffolding claim rewritten to
  CS-3 (dropped `Task 257` citation); the phantom `Bimodal/Examples/ModalProofs.lean` /
  `TemporalProofs.lean` source-file bullets replaced with the two real files.
- `Theories/Bimodal/docs/user-guide/tutorial.md` — inserted a status-note callout after the
  perpetuity example, before `### Extension Layers`; all named theorem blocks
  (`soundness`, `weak_completeness`, `strong_completeness`, `perpetuity_1`, `perpetuity_2`)
  verified byte-identical.
- `Theories/Bimodal/docs/user-guide/tactic-development.md` — inserted a status-note callout before
  the "Custom Rule Sets" example; the `declare_aesop_rule_sets [TMLogic]` code and the
  `perpetuity_1`/`perpetuity_2` stubs verified byte-identical.

## Decisions

- Two task-number citations directly inside content this task was already rewriting
  (`known-limitations.md` Limitation 1's Resolution line, `troubleshooting.md`'s `Task 260` link,
  `examples.md`'s `Task 257` mention) were replaced with durable anchors rather than left in place,
  per `.claude/rules/no-task-references-in-deliverables.md`. This is an in-line application of the
  same reasoning the plan's ruling table already used for `implementation-status.md`'s
  "Tasks 132-135, 257" line; no file was opened solely for this purpose.
- Layer 3's header in `implementation-status.md` was changed to `✅ Complete` (the plan left this
  as implementer discretion, conditional on all subsections reading complete after the other
  edits — which they did: Perpetuity, Modal S4/S5, and Propositional all read Complete).
- `architecture.md`'s adjacent "Complete proof system: TM with 8 axioms, 7 rules" bullet was left
  unchanged, per the plan's explicit discretion clause — it's an axiom/rule enumeration claim, not
  a sorry/proof-status claim, so the 21-schema evidence doesn't plainly govern it.

## Plan Deviations

- None (implementation followed plan for all six content phases and the verification phase).

## Newly Discovered Residue (not fixed, flagged per Phase 7 instruction)

- `examples.md` lines 41, 164, 479-480 reference `Archive/ModalProofs.lean` and
  `Archive/TemporalProofs.lean` — files that do not exist anywhere in the repo. These were not in
  the research report's per-hit table (the report's sweep grep pattern doesn't match these lines)
  and, on inspection, belong to the same fictional `Logos/`-namespace project layout documented in
  `architecture.md`'s directory-tree diagram (lines ~966-990: `LogosTest/`, `Archive/`,
  `Counterexamples/`, none of which exist in the real repo). `DECISION.md` explicitly defers the
  `Logos/Core/Automation/...` namespace issue to a separate follow-up task; this residue is part
  of that same family and was left untouched rather than folded in, consistent with the Non-Goal.
  Recommend the follow-up task's scope note include this directory-tree/Archive-file cluster
  alongside the already-flagged `Logos.*` import lines.
- `tactic-registry.md:24,134` (`tm_auto` 🚧 Partial row and "In Progress: 1 (5.3%)" statistic) and
  `reference/tactic-reference.md:11-12` (`modal_search`/`temporal_search` Partial) are unchanged,
  per the plan's explicit Non-Goal ("Rewriting the rest of `tactic-registry.md`'s 'Registered
  Rules' list... Reconciling `reference/tactic-reference.md` against `tactic-registry.md`").
- `test-coverage.md`'s numeric Sorry Audit table (lines ~20, 111-132, including the stale
  `CompletenessTest.lean (3)` row) is deliberately unchanged — banner-only treatment per the
  plan's ruling, since `scripts/coverage-analysis.sh` does not exist in this repository.

## Verification

- Build: N/A (documentation-only; no `.lean` file touched)
- Tests: N/A
- `git status --porcelain -- '*.lean'`: empty (confirmed)
- `git diff --stat` (this task's commits): confined to the 10 files named in `DECISION.md`'s
  in-scope list, under `Theories/Bimodal/docs/`
- Phantom-identifier greps: `provable_iff_valid`, `5/8`, and `~30`-as-sorry-count all return zero
  hits in scope. `ModalProofs\.lean`/`TemporalProofs\.lean`/`CompletenessTest` residual hits are
  all either (a) the deferred Logos/Archive family, (b) `known-limitations.md`'s own text stating
  the files don't exist, or (c) `test-coverage.md`'s deliberately-preserved numeric table — none
  assert a live falsehood.
- Sorry count (12) and CS-1 breakdown stated consistently in `implementation-status.md` and
  `README.md`; no other in-scope file states a conflicting count.
- Six `perpetuity_*` stubs in `architecture.md`, and the named schematic theorems in `tutorial.md`
  and `tactic-development.md`, verified byte-identical before/after.
- `Logos` occurrence counts in `examples.md` (8) and `tactic-registry.md` (15) unchanged.

## Notes

Follow-up items surfaced (not created by this task, per plan's Artifacts & Outputs section):
the `Logos/` namespace reconciliation (now including the `Archive/ModalProofs.lean` /
`Archive/TemporalProofs.lean` / directory-tree residue found above); `tactic-registry.md`'s
"Registered Rules" name-accuracy issue (`modal_t_valid`/`modal_4_derivable`/`modal_b_derivable`
vs. the real `axiom_modal_t`/`modal_t_forward`/... names); the `tactic-reference.md` vs.
`tactic-registry.md` inconsistency; the perpetuity formula strings in
`implementation-status.md`'s table that don't match the real theorem statements.
