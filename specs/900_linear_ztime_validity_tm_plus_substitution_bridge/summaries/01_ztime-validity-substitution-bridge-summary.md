# Implementation Summary: Task #900

- **Task**: 900 - Linear ZTime validity to TM-plus substitution bridge
- **Status**: [COMPLETED]
- **Started**: 2026-11-11T19:25:54-08:00
- **Completed**: 2026-11-11T21:13:17-08:00
- **Effort**: ~1h50m across 4 phases
- **Dependencies**: None
- **Artifacts**: plans/01_ztime-validity-substitution-bridge.md, reports/01_ztime-validity-tm-plus-substitution-bridge.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean`, a new five-declaration Metalogic
module carrying the two-step bridge from linear validity to TM⁺ theoremhood: a `ZTime`-valid L
formula yields `PlusDerivable FrameClass.ZTime []` at every substitution instance, via
`completeness_ztime` followed by `PlusDerivationTree.ofTMSubst`, plus the box-free corollary
routed through a Z-word semantics. `isBoxFree` was relocated from `Separation/SemanticBridge.lean`
into `Separation/Defs.lean` so the bridge can reach it without pulling the separation stack. All
four phases are `[COMPLETED]`; the module is sorry-free and the repository's gate battery is green
on every touched file.

## What Changed

- `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` — new module. `wordOf` (the bi-infinite
  Z-word read off a task model and a world history over `ℤ`);
  `truthAt_iff_intTruth_of_boxFree` (box-free task-frame truth is a datum of that Z-word alone,
  by induction on `φ`, the `box` arm discharged by contradiction with `isBoxFree`);
  `validZTime_of_boxFree_intTruth`; `plusDerivable_substPlus_of_validZTime` (the bridge);
  `plusDerivable_substPlus_of_boxFree_intTruth` (the corollary).
- `FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean` — now declares `isBoxFree`.
- `FormalSystem/Metalogic/Expressiveness/Separation/SemanticBridge.lean` — no longer declares it.
- `FormalSystem/PlusLanguage/Subformulas.lean` — one corrected prose cross-reference.
- `FormalSystem.lean`, `FormalSystem/Metalogic.lean` — regenerated root import plus one
  convenience re-export.
- `scripts/check-module-invariants.sh` — C14 matched axiom-baseline pairs for the five new
  declarations.
- `docs/theorem-index.md` — five new per-theorem ledger rows.
- `README.md`, `FormalSystem/Metalogic/README.md`, `typst/generated/status.typ` — regenerated
  inventory and line-count surfaces.

### Phase 4 in particular: the C16 `unusedArguments` cascade

Phase 4's closing battery surfaced one red finding inside this task's own touched set — a C16
`env_linter` `unusedArguments` error on an `[F.IsRegular]` instance binder that no body consumed.
Clearing it required amending two signatures pinned verbatim under the plan's
`## Lean Challenge Statements` block, which `rules/plan-compliance.md`'s Statement Fidelity routes
to user escalation rather than silent substitution. Both amendments were made only under the
user's own recorded authorization, and in each case the pinned block and the landed declaration
were edited together in one change so the recorded statement never diverged from the source:

1. `wordOf` — its binder was never consumed (the body reads only `M.valuation` and `τ.state`, and
   `FrameOver.toTaskFrame` needs no regularity instance).
2. `truthAt_iff_intTruth_of_boxFree` — dropping `wordOf`'s binder relocated the finding here,
   because this theorem's binder was load-bearing *only as a conduit* supplying `wordOf`'s
   instance argument at the single call site `wordOf M τ`; its own induction never touches
   regularity.

The cascade terminated at the second declaration, as predicted from evidence gathered before the
edit: the next consumer, `validZTime_of_boxFree_intTruth`, binds its regularity instance
tactic-locally (`rw [validZTime_iff_validInt]; intro F _ M τ t`), exposing no declaration-level
instance argument the linter can reach; line 102 was the module's only `IsRegular` occurrence; and
the theorem has zero references outside its own file. Both amendments are strictly generalizing —
no name, axiom profile, C14 pin or ledger row moved, and the load-bearing `isBoxFree` hypothesis
is untouched.

## Decisions

- **Host module.** A fresh Metalogic-root file rather than appending to `ZTimeProvability.lean`
  (tightly scoped to decidability, pulls a closure the bridge does not need) or
  `AuxiliaryAtoms.lean` (903 lines of soundness machinery).
- **Completeness engine.** `completeness_ztime` from `Metalogic.StrongCompleteness`, as the task
  description names, rather than the more primitive `BXCanonical.derivable_of_validZTime`. Both
  were measured accepted by the gate, so description fidelity decided.
- **Linear semantics.** Reuse the existing `IntStructure`/`IntTruth` pair rather than defining a
  fresh Z-word semantics. The cost is a dependency on `IntTruth`'s degenerate `box` arm, which is
  exactly why the `isBoxFree` hypothesis is load-bearing and may never be weakened or defaulted.
- **`isBoxFree` relocated, not duplicated** — two names for one syntactic predicate would invite
  drift.
- **No `@[nolint unusedArguments]` suppression for the C16 finding.** An in-source `nolint` plus a
  `scripts/nolint-attribute-allowlist.txt` entry is inadmissible under that allowlist's own
  ADMISSION BAR precisely because the declarations *can* conform — and they now do.
- **The §§7–15 roadmap ruling does not bar this task.** None of the five declarations is any of
  the six components that ruling keeps as paper proofs, and none mentions a Reynolds object in its
  statement; the module docstring disclaims being a formalization of any part of that span.

## Plan Deviations

- **Phase 4** altered: an unlisted task item was added and recorded — clearing the C16
  `env_linter` `FAIL` by the cycle-11 authorized amendment of `truthAt_iff_intTruth_of_boxFree`.
  This was the escalation-driven repair the cycle-10 and cycle-11 user decisions authorized, not a
  re-derivation of the plan's decomposition.
- **Phase 4** altered: the `verify-deploy.sh` item was discharged under this dispatch's batch-gate
  deferral rather than by an independent full run. Every `verify-deploy.sh` gate is scoped to
  `.claude/**`, `agent-system/**`, hook registration, state-writer boundary or shellcheck — none
  reaches a `FormalSystem/**.lean` path or a `specs/**` plan file, so no `--only-gate N` narrowing
  covers this phase's touched files at all, and the UNMAPPABLE CRITERION route applied: every
  other named repository-specific check was run directly and in full. The complete set runs once
  for the whole batch and is attributed back by `modified_files`. Deferred, never forgiven.
- Phases 1-3 followed the plan without deviation.

## Verification

- Build: Success — full guarded `lake build`, guard `exit_status=0`,
  `Build completed successfully (2975 jobs)`, 0 `error:`, 0 `warning`, 0 `uses 'sorry'`. The
  `.olean` for `ZTimeSubstitutionBridge.lean` (21:05:35) is newer than its source (21:04:52), so
  the amended module genuinely re-elaborated.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved roots reports `sorry_count: 0` with an
  empty inventory; `grep -c sorry` on the bridge module is 0)
- Vacuous count: 0 in this task's touched set. One repo-wide single-line match persists —
  `FormalSystem/Examples/TemporalStructures.lean:495`, a genuinely `trivial`-closable goal — down
  from 2 at the pre-task commit `47cf2e1eb`; it did not increase and is outside this task's scope.
- Axiom count: 14, unchanged from the pre-task commit baseline of 14. Not increased.
- `check-module-invariants.sh`: PASS, exit 0, zero `FAIL` lines. C6 (unreachable/isolation), C14
  (every pinned declaration matches its axiom baseline, re-run after the amendment), C15 (93
  paper anchors, 460 theorem-index rows), C16 (`env_linter` batch has no un-nolisted finding;
  `dupNamespace` zero), C26 (zero snake_case names, 16 allowlisted `nolint` pairs), INV (every
  generated inventory block current) all green. `--emit-inventory --check` exits 0.
- `check-metalogic-cycles.sh`: PASS, exit 0 — all three assertions.
- `typst-sync-check.sh`: PASS, exit 0, all 4 checks green; Check 2 `MISMATCH_COUNT=0`.
- `check-copyright-headers.sh`: PASS, exit 0 — 756 conforming, 0 nonconforming/duplicate/missing.
- Axiom profiles (`lean_verify`, fully qualified): `plusDerivable_substPlus_of_validZTime` and
  `plusDerivable_substPlus_of_boxFree_intTruth` each `[propext, Classical.choice, Quot.sound]`;
  `wordOf` and `truthAt_iff_intTruth_of_boxFree` each `[propext]`. All `trust: standard`, no
  non-standard axiom, no `sorryAx`.
- Statement fidelity: all five declared signatures match `## Lean Challenge Statements`
  character-for-character modulo whitespace, against the block as amended under the user's own
  authorization. No hypothesis added, no quantifier specialised, no same-named weaker restatement.
- Tests: N/A (no test-suite changes; the gate battery above is this repository's verification
  surface for Lean changes)
- Files verified: Yes

### Out-of-scope findings (none repaired, all pre-existing)

`check-module-invariants.sh` reports `TODO C20` (10 recorded declaration-span mismatches on
`scripts/c20-declaration-baseline.txt`; 144 of 1029 `file.lean:NNN` citations carrying no
declaration name), `INFO C20` (39 citations naming a constructor/field/binder), and `TODO C16`
(230 `env_linter` findings across 15 of 18 non-`FormalSystem` lakefile roots, `ENFORCE_C16_ROOTS=0`,
not exit-code-affecting). None names a file in this task's touched set, and all are soft/`TODO`
classes that do not affect the exit code.

## Impacts

- `plusDerivable_substPlus_of_validZTime` is the generic import route by which a linear-validity
  argument over bi-infinite Z-words becomes a TM⁺ theorem at arbitrary L⁺ arguments. Downstream
  work needing automaton-correctness or fair-scheduling facts as linear validities with
  stab-headed formulas and fresh atoms as sentence letters can now consume them in TM⁺ through
  this bridge rather than re-deriving a transfer each time.
- `isBoxFree` now lives in `Separation/Defs.lean`, so a consumer needing only the syntactic
  predicate no longer imports `SemanticBridge.lean` and its semantic closure.
- `FormalSystem/Metalogic.lean` re-exports the module, so `import FormalSystem.Metalogic` reaches
  all five declarations.
- Two previously pinned Challenge signatures are now strictly more general (one fewer instance
  binder each). Every call site supplies instance arguments implicitly, so no consumer needed
  adjustment, but any future statement quoting those signatures should quote the amended form.

## Follow-ups

- The `box` arm of `IntTruth` remains `True`, which is why `isBoxFree` is load-bearing on the
  corollary. A future task wanting the bridge for formulas with modal content needs a genuine
  modal clause in the linear semantics, not a weakening of this hypothesis.
- `BXCanonical.derivable_of_validZTime` would shrink the bridge's import closure slightly
  relative to `completeness_ztime`. Recorded as a deliberate deferral: it is a different
  declaration from the one the task description names, so description fidelity decided here, and a
  future task may revisit it on import-weight grounds.
- The repo-wide `TODO C20` and non-`FormalSystem`-root `TODO C16` backlogs are untouched and
  remain available as their own cleanup work.
- `verify-deploy.sh` runs once at the end of this `/orchestrate` batch invocation; its result is
  attributed back to this task by `modified_files`.

## References

- `specs/900_linear_ztime_validity_tm_plus_substitution_bridge/plans/01_ztime-validity-substitution-bridge.md`
  — the plan, including the per-phase measured verification tables, the `## Lean Challenge
  Statements` block with both recorded amendments, and the C16 resolution record.
- `specs/900_linear_ztime_validity_tm_plus_substitution_bridge/reports/01_ztime-validity-tm-plus-substitution-bridge.md`
  — the research report.
- `specs/900_linear_ztime_validity_tm_plus_substitution_bridge/handoffs/` — per-phase handoffs,
  including the Phase 4 handoff recording the C16 cascade diagnosis.
- `docs/theorem-index.md` — the per-theorem ledger rows for the five declarations.
- `FormalSystem/Metalogic/ZTimeSubstitutionBridge.lean` — the module docstring, which disclaims
  being a formalization of any part of the §§7–15 span and names the load-bearing hypothesis.
