# Implementation Summary: Task #465

- **Task**: 465 - Complete the terminus restatement family at the repaired residuals
- **Status**: [COMPLETED]
- **Started**: 2026-10-17T03:59:38Z
- **Completed**: 2026-10-17T04:14:07Z
- **Effort**: ~0.25 hours wall clock (plan estimated 5.5 hours; the recipe applied without exploration)
- **Dependencies**: 462, 463, 464 — all three settled before this dispatch
- **Artifacts**: plans/01_complete-seedrun-terminus-family.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task's recorded scope — fourteen `_lengthBudget`/`signedUniverse` siblings of the `_run`
termini — is **moot**, and the dispatch's own stop-condition fires for all fourteen at once for a
single shared reason: the family roots they would apply no longer exist in the tree. Per the
settled rescope decision this dispatch instead completed the **seedRun** family one level over:
seven new termini in a new submodule, plus the record corrections that stop a future reader
re-attempting the fourteen.

Both seedRun lines are now complete at S1-S4. The `_fixed_seedRun` line went from a self-described
"representative restatement, not the family" singleton to all four slots; the `_gap_seedRun` line
is entirely new. Every one of the seven is a kernel proof with no `sorry` and no axiom beyond
`propext`, `Classical.choice`, `Quot.sound`.

## What Changed

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/SeedRunTermini.lean` —
  **created** (258 lines, 7 theorems). The only module importing both `PostBlocking.lean` (which
  carries the seed narrowing, its bridge, and the `_fixed_seedRun` root) and `FiveComponent.lean`
  (which carries `expandBranchWithFuel_isSome_of_budget_gap`); those two are parallel branches of
  the import DAG and neither can see the other, so a new join module was the only additive route.
  - `_fixed_seedRun` S2-S4: `buildTableauAt_isSome_at_seed_fixed_seedRun`,
    `buildTableauAt_isSome_of_lengthBudget_fixed_seedRun`,
    `buildTableauAt_isSome_at_seed_lengthBudget_fixed_seedRun`.
  - `_gap_seedRun` S1-S4: `buildTableauAt_isSome_of_budget_gap_seedRun`,
    `buildTableauAt_isSome_at_seed_gap_seedRun`,
    `buildTableauAt_isSome_of_lengthBudget_gap_seedRun`,
    `buildTableauAt_isSome_at_seed_lengthBudget_gap_seedRun`. No `hmint` binder anywhere on this
    line: `mintPaysForTimeGap_of_any` supplies the minting residual internally at every frame
    class, at the price of the enlarged floor `10 * U.card + U.card * U.card` and the
    `mintAwareFuelGap` figure.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — one new import line
  in dependency position after `FiveComponent`; register-count prose corrected to twenty-six.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/PostBlocking.lean` —
  comment-only. A C12 record paragraph stating that the `_lengthBudget`/`signedUniverse` siblings
  of the nine retired names are **not available and not outstanding work**, with the refuting
  witnesses named per name; and the representative's deferral clause rewritten to point at the
  landed family instead of claiming deferred work.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` —
  comment-only. A cross-reference on entry 25 recording where the seedRun family stands, stated as
  a note on availability rather than a new entry; module-docstring count corrected to twenty-six.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` — module count
  eighteen -> twenty-one and nineteen -> twenty live; `Register.lean` row's line figure 923 ->
  1014; a new `SeedRunTermini.lean` row; the import-graph block and its "three joins" prose
  extended to name the new fourth join.
- `FormalSystem.lean` and `typst/generated/status.typ` — mechanical consequences of adding a
  module, forced by the pre-commit gate. See **Plan Deviations**.

## Decisions

- **The fourteen are reported moot, not attempted.** `grep -rn "theorem buildTableauAt_isSome"`
  returns no `_run` terminus; the retirement record names all nine removed roots. Nothing is a
  "one-line application" when the thing it would apply is gone, and landing one would mean
  restating `PostBlockingSettlesRun` (refuted at every positive figure) or the unrestricted
  `PostBlockingSettles` (refuted at all four frame classes). The dispatch's own stop-condition
  governs: record why, do not force it.
- **`hpb` transcribed from each statement's own conclusion, never the root's.** Unlike
  `PostBlockingSettles`, `PostBlockingSettlesSeedRun` is indexed by a fuel figure, so it does not
  thread unchanged down a family; a figure copied from the root yields a type-correct, provable,
  quietly wrong theorem. Each member's `hpb` was written at its own instantiated figure, and the
  result was checked mechanically (balanced-paren extraction of both occurrences, whitespace-
  normalized comparison): 7/7 identical. Whitespace-normalized rather than literally byte-identical
  is the right equivalence here, because the two occurrences line-wrap differently in source.
- **S5/S6 left out as `hlab`-vacuous**, per the settled decision. Each would carry
  `UnorderedSuccessorLabelClosed`, refuted at every nonempty finite label set by
  `unorderedSuccessorLabelClosed_nonempty_false`. Recorded as absent *by decision* in the new
  module's header, in the representative's docstring, and on the register entry — so the absence
  reads as a reason rather than a gap.
- **Every new docstring names the carried residual's exact status.** `PostBlockingSettlesSeedRun`
  is neither refuted nor proved, and register entry 25's second, structurally independent
  refutation route against it is unprobed. No member is described as a discharge of anything.
- **The README's `*Last verified*` stamp was left alone.** Measurement found 19 of its 20
  pre-existing module-table line figures stale (drift from +3 to -56 lines). This dispatch
  re-derived only the register's figures, so refreshing the stamp would assert a whole-table
  verification that did not happen. Recorded as a follow-up instead.

## Plan Deviations

- **Phase 2 altered**: the changed-file set grew from the plan's declared five Lean/markdown paths
  to seven. Creating a new `.lean` file requires an import line in the library root
  `FormalSystem.lean` (which `lake exe mk_all --lib FormalSystem` generates and which the
  pre-commit `typst-sync-check.sh` Check 2 gate enforces: 707 import lines vs 708 files), and
  requires `typst/generated/status.typ`'s `formalsystem_file_count`/`formalsystem_line_count` to be
  regenerated. The plan's Phase 2 anticipated neither. Both were added, and `status.typ` was
  regenerated at every phase boundary that moved a line count.
- **Phase 4 altered**: the `Register.lean` line figure written into the README is **1014**, not the
  plan's Scope-Hypothesis figure of 1001. 1001 was the pre-edit measurement; this phase's own
  cross-reference paragraph added 13 lines, so the post-edit figure is what the README now carries.
  The register's entry count was re-derived from the numbered headings as the plan directed: 26,
  matching the hypothesis.
- **Phase 5 altered**: the dispatch's Batch Gate Deferral names
  `agent-system/extensions/core/scripts/tests/run-all.sh` and `verify-deploy.sh` as the scoped
  narrowing to run in place of the complete gate set. Neither path exists in this repository — no
  `agent-system/` source store is present — and this task touched zero agent-system files, so no
  such suite would cover it. The scoped verification actually covering this phase's files is the
  full guarded `lake build` plus `scripts/typst-sync-check.sh` and `scripts/readme-lint.sh`, all of
  which were run. The batch-level complete gate set remains deferred to the batch stage, not
  forgiven.
- **No STOP-CONDITION fired.** All seven members compiled on the first attempt with no tactic
  beyond the plan's prescribed body. None needed real mathematics.

## Verification

- Build: **Success**. Full guarded `lake build` (`lake-build-guard.sh build --timeout 1800 -- build`,
  detached), exit 0, 2875/2875 jobs, zero `error:` lines, zero `warning:` lines. Phase-scoped
  builds of `…MintBound.SeedRunTermini` and `FormalSystem.Metalogic.Decidability` also exit 0.
- Sorry count: **0**. `lean-sorry-census.sh` over the resolved source roots reports
  `sorry_count: 0`. One `sorry` *string* occurs in a changed file — `Register.lean:888`, the prose
  "no `sorry`, and no axiom beyond …", inside a doc comment, pre-existing and not in this task's
  diff. Distinguished explicitly rather than counted.
- Vacuous count: **0 introduced**. The syntactic vacuity grep returns one tree-wide hit,
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal … := trivial`),
  pre-existing and absent from this task's diff. No `def X := True`-shaped placeholder was written.
- Axiom count: **unchanged at 14** (`grep -rn "^axiom "` over the resolved roots, identical at the
  pre-task baseline `ee38cc225` and at HEAD). No `axiom` line appears in this task's diff.
- Axiom audit: `#print axioms` on each of the seven new theorems reports exactly
  `[propext, Classical.choice, Quot.sound]` — nothing beyond the permitted set.
- Frozen files byte-identical to the Phase 1 baseline: `Fuel.lean`
  `1ab95759fec57ad8654dc93cc3335e70`, `Decidability/Saturation.lean`
  `51c40766e0150182f2124c642b8bbf2e`, `Decidability/Tableau.lean`
  `8f332a33f6d1960b62ca51ee055148c4`. All three unchanged.
- Additive-only: every hunk in the three landed Lean modules lands inside a `/-!` or `/--` comment
  region. Reviewed both added and removed lines of the diff — no binder, statement or proof term
  appears. No previously-landed declaration was altered.
- No task-number citation and no record-versioning phrasing in any non-`specs/**` file touched
  (`grep -nEi '\btasks? [0-9]+'` and the `no longer|previously|formerly|supersed|used to` family,
  both empty over the diff). No emoji.
- `scripts/readme-lint.sh FormalSystem`: RESULT **PASS**, 0 broken file references.
- `scripts/typst-sync-check.sh --fix`: **PASS** on status.typ, module map and machine appendix.
- Concurrency: `git log -1` on all four Phase 1 target files names this task's own commits — no
  sibling landed in `FormalSystem/` mid-flight.
- Final family sweep: `buildTableauAt_isSome` declarations 33 -> **40** (+7). Both seedRun lines
  complete at S1-S4 (8 members, one of which — `_of_budget_fixed_seedRun` — was already landed);
  `signedUniverse` slots absent by decision.
- Tests: N/A (no test suite covers these statements; they are headline-shaped termini with no
  executable content).
- Files verified: Yes.

## Impacts

- A caller reaching for the seed-fuel or length-budget form of a seedRun terminus now finds it
  landed rather than having to re-derive it, and the half-populated family that was a trap for a
  future reader is closed on both lines.
- **None of the seven makes any terminus non-vacuous, and none should be cited as if it did.**
  Every member carries `PostBlockingSettlesSeedRun` as a hypothesis — neither refuted nor proved,
  with an unprobed refutation route against it on record — and every member still carries
  co-hypotheses that register entries 9, 11 and 26 refute at the frame classes they are aimed at.
  The `_gap_seedRun` line's dropping of `hmint` moves exactly one residual from condition to
  theorem and changes nothing about the satisfiability of the statements consuming it.
- The record now says plainly that the fourteen are unavailable rather than outstanding, in three
  places a reader would arrive from: the C12 retirement record, the representative's own docstring,
  and register entry 25.
- A future refutation of the seed narrowing retires all seven at once. The cost is bounded by
  design: they sit in one dedicated submodule, so retirement is a single-file deletion plus two
  import lines.

## Follow-ups

- `MintBound/README.md`'s module table carries stale line figures on 19 of its 20 pre-existing
  rows (measured: Invariants 1029 vs 1021, OrderingTimes 1024 vs 1016, MintPotential 1846 vs 1828,
  Measure 1252 vs 1258, ClosureResidual 1164 vs 1161, TimeCensus 710 vs 696, TimeReuse 785 vs 773,
  MonotoneIssuance 506 vs 505, OrientedGate 1000 vs 997, FourComponent 770 vs 768, SigmaFixed 982
  vs 971, LabelHeadroom 431 vs 428, PostBlocking 1315 vs 1348, UntlSnceFree 715 vs 699,
  GapPotential 656 vs 621, MintPaysAssembly 897 vs 892, FiveComponent 791 vs 790; Terminus and
  BoxFree are correct). The declaration-count column was not measured and may drift too. Refreshing
  the whole table and its `*Last verified*` stamp is a self-contained job.
- `readme-lint.sh` reports 15 `STALE DATE` READMEs across `FormalSystem/` (reported, not gated),
  pre-existing and unrelated to this change.
- The seed narrowing's second refutation route remains unprobed. Register entry 25 names the
  cheapest probe: for engine exits `ob`, does `blockedTimes satBr satOrd fc (armTracker satBr)`
  ever lose a time that `blockedTimes ob oOrd fc (armTracker ob)` held? If it does, all seven
  members land in the retirement record alongside the nine.

## References

- `specs/465_complete_terminus_restatement_family/plans/01_complete-seedrun-terminus-family.md`
- `specs/465_complete_terminus_restatement_family/reports/01_complete-terminus-restatement-family.md`
- `specs/465_complete_terminus_restatement_family/.decisions.json` (the settled rescope)
- `specs/465_complete_terminus_restatement_family/handoffs/` (per-phase handoffs 2-4)
- `specs/465_complete_terminus_restatement_family/issues.jsonl` (two issues, one win)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` entry 25
