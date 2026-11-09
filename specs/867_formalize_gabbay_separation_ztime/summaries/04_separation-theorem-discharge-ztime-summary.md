# Implementation Summary: Task #867

- **Task**: 867 - Formalize Gabbay separation over discrete time for PlusFormula, discharging the SeparationOver hypothesis and making the open-future translation executable
- **Status**: [COMPLETED]
- **Started**: 2026-11-09T07:35:59Z
- **Completed**: 2026-11-09T09:00:26Z
- **Effort**: ~1.5 hours (one dispatch, Phases 24-28)
- **Dependencies**: None
- **Artifacts**: plans/04_landed-device-resize-10-2-7-10-2-8.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This dispatch closed the last five phases of the plan: GHR Lemma 10.2.8 and Theorem 10.2.9 over
the auxiliary syntax (`JunctionDepth.lean`), the CNF packaging and the discharge
`separationOver_ztime : SeparationOver TaskFrame.IsZTime` with the computable separated form
`sepZ` (`Packaging.lean`, `Discharge.lean`), the computable translation `trZ` with its
unconditional validity transfer `openValidIn_ztime_iff_trZ` (`Computable.lean`), the
documentation and theorem-index restatement with 33 measured C14 pins, and the full gate sweep.
Every one of the seven pinned `## Lean Challenge Statements` signatures is landed verbatim and
`lean-plan-compliance-check.sh` reports `passed`. The task's headline deliverable — the hypothesis
that `OpenFutureElimination.lean`'s `.ZTime` results take — is discharged in-tree; the `.RTime`
instance (GHR Theorem 10.3.20) was out of scope and remains conditional.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/JunctionDepth.lean` — Created new file
  (1164 lines, 122 declarations): the junction-depth measure `jdU`/`jdS`/`junctionDepth` as a
  mutual structural recursion, checked against GHR's worked example by `decide`
  (`junctionDepth_ghrExample = 3`); monotonicity bounds; the zero/one characterizations and the
  base case `isSeparated_of_junctionDepth_le_one` with its converse; the duality instruments
  (`junctionDepth_swap`, `isSeparated_swap`, `NoUntlUnderSnce`, `sep7Dual`); the mirror
  collection API `sTypes`/`argSTypes`/`innerSTypes`; the abstraction `mapSDeep` (the
  `swap`-conjugate of `mapU`) and `abstrSnceArgs` with `noSnceUnderUntl_mapU_abstrSnceArgs`; the
  three named decrease parts, part (c) as `junctionDepth_sep8Step_snce_le`; and
  `sep8Body`/`sep8Fuel`/`sep` with `isSeparated_sep` and `usTruth_sep_iff` (GHR 10.2.8 and
  Theorem 10.2.9). `sep` has axiom profile `{propext}`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Packaging.lean` — Created new file (329
  lines, 34 declarations): `DecidablePred IsSOnly`, `orList`, the mutual clause-list CNF
  `cnfPos`/`cnfNeg` with `cnfTruth_cnf` (every formula) and `pureLit_cnf` (separated formulas),
  `packClause`, `sepFormUS`, `package` with `usTruth_sepFormUS_package` and both purity
  conclusions.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Discharge.lean` — Created new file (151
  lines): `toPlus_sepFormUS`, and the four contract declarations `sepZ` (`{propext}`),
  `sepZ_sepClauses`, `plusTruthAt_sepZ_iff`, `separationOver_ztime`, in namespace
  `FormalSystem.Metalogic.Expressiveness`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Computable.lean` — Created new file (137
  lines): `trZ` (`{propext}`), `openTruthAt_iff_trZ`, `openValidIn_ztime_iff_trZ`.
- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` — docstrings only: the
  module docstring, `SeparationOver`, `openValidIn_ztime_iff_tr` and `exists_translation_ztime`
  now record the `.ZTime` discharge and the `.RTime` residue; no declaration changed.
- `FormalSystem/Metalogic/Expressiveness.lean` — eight imports added; docstring updated.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/{Hierarchy,UNesting}.lean` — docstrings
  only: `Paper:` lines normalized to the C15-accepted `Paper: — (…)` shape.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md`,
  `FormalSystem/Metalogic/Expressiveness/README.md` — module rows, status, key results, counts.
- `docs/theorem-index.md` — band preamble and sub-band restated, three `.ZTime` rows restated,
  37 rows added; every `.RTime` row byte-identical.
- `scripts/check-module-invariants.sh` — 33 matched C14 pairs appended to both heredocs, every
  profile pasted from `#print axioms` output measured in the same run.
- `scripts/nolint-attribute-allowlist.txt` — one reasoned permanent entry,
  `unusedArguments:sepZ_sepClauses`.
- `FormalSystem.lean`, `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md`,
  `FormalSystem/Metalogic/README.md` — regenerated.
- `specs/state.json` — task 867's `file_scope` extended by `scripts/nolint-attribute-allowlist.txt`.

## Decisions

- **The inner abstraction pass is the `swap`-conjugate of `mapU`.** The plan's sketch
  `mapS (abstrFn j L)` cannot reach a maximal `snce` beneath a nested `untl` (the landed `mapS`
  stops at `untl`), so `snce ⊥ (untl ⊥ (untl ⊥ (snce ⊥ p)))` would be left unabstracted and
  `sep7` inapplicable. `mapSDeep k φ := (mapU (fun u => (k u.swap).swap) φ.swap).swap`, used only
  through its five equations, executes the bullet's primary instruction with the landed operators
  and no new substitution operator.
- **The 10.2.8 step is applied at maximal temporal nodes, not at the whole formula.** Part (c)'s
  bound is `≤ max (jdU φ) 1` and is strict against `junctionDepth φ` only where the head's kind
  forces `jdU φ < jdS φ` (or its mirror); for `jdU φ = jdS φ` it is not strict. GHR's duality
  reduction is therefore a precondition of the bound, exactly as the Phase 23 handoff's sizing
  predicted; `sep8Body` guards at each temporal node and reaches `untl` heads by conjugation.
- **Literal classification by decidable `IsSOnly`**, so leaves and `⊥` go to the past component,
  matching the plan's "`snce`-only and leaf literals in the first component".
- **The pinned `sepZ_sepClauses` signature's unused `hreg`/`hz`** are kept (a contract signature
  is not changed to spare a linter) and answered by a declaration-scoped `set_option` naming the
  linter, `@[nolint unusedArguments]`, and a reasoned permanent allowlist entry.

## Plan Deviations

- **Phase 24, abstraction bullet** altered: `mapSDeep` (the `swap`-conjugate of `mapU`) in place
  of the sketch's `mapS (abstrFn j L)`, which does not descend through nested `untl`s; the
  bullet's primary instruction is executed as written.
- **Phase 24, part (a)** altered: landed as `junctionDepth_mapU_abstrSnceArgs_le_two` with the
  strict form `_lt` exactly above depth 2; at depth 2 the drop is not strict and cannot be, and
  part (c), not (a), licenses the recursive call.
- **Phase 24, recursion bullet** altered: `sep8Body` guards at each maximal temporal node rather
  than at the whole formula, because part (c) holds only at temporal heads.
- **Phase 27, docstring bullet** altered: three declaration docstrings in
  `OpenFutureElimination.lean` amended beyond the module docstring; no declaration changed.
- **Phase 27, rows and pins** altered: the index's own legend required C14 pins for every
  row with an axiom profile (33 pairs, not only the seven contract declarations) and C15 required
  `Paper: — (…)` anchors at every row's declaration (39 lines normalized, two added).
- **Phase 28, `verify-deploy.sh`** re-deferred to the batch stage per the dispatch's Batch Gate
  Deferral directive, with the narrowing invocation recorded.

## Verification

- Build: Success — unscoped guarded `lake build`, `GUARD_EXIT=0`, "Build completed successfully
  (2966 jobs)", 0 errors, 0 warnings; `.olean`s newer than their sources
- Sorry count: 0
- Vacuous count: 0 introduced (1 pre-existing hit at `Examples/TemporalStructures.lean:495`,
  untouched)
- Axiom count: 14, unchanged from the HEAD baseline; every measured profile within
  `[propext, Classical.choice, Quot.sound]`; `sep`, `sepZ`, `trZ` are `{propext}`
- Tests: `check-module-invariants.sh` ALL CHECKS PASSED; `check-metalogic-cycles.sh` PASS ×3;
  `readme-lint.sh FormalSystem` PASS; `typst-sync-check.sh --fix` PASS;
  `lean-plan-compliance-check.sh` passed; `run-all.sh --only test-check-task-references.sh,test-check-record-versioning.sh`
  PASS 2/2; `verify-deploy.sh` re-deferred to the batch stage
- Files verified: Yes

## Impacts

- `SeparationOver TaskFrame.IsZTime` is a theorem (`separationOver_ztime`), so
  `openValidIn_ztime_iff_tr`, `exists_translation_ztime` and `decidableOpenValidZTimeOfTr` are
  instantiable with no hypothesis; the open-future modal's L⁺-definability at ℤ-time is now an
  in-tree result rather than a docstring citation.
- `trZ` is a plain `def`: the effectiveness gap of the transfer corollaries is closed at `.ZTime`
  (what remains undischarged there is L⁺ decidability itself), and the L-plus ZTime completeness
  programme's conditional automaton route has its separation precondition met.
- The `SeparationZ/` subtree carries all of GHR §10.2 over `USForm`, reusable for the
  Dedekind-complete counterpart.

## Follow-ups

- GHR Theorem 10.3.20 — `SeparationOver TaskFrame.IsRTime` — is the natural second target and
  was never in this task's scope; every `.RTime` row keeps its hypothesis.
- `check-record-versioning.sh` reports 6 BLOCKING pre-existing occurrences in `Boneyard/` and
  `Expressiveness/Kamp/` files this task never touched.
- Two source findings are recorded at the declarations: GHR's printed Case 5 formula is refuted
  over `ℤ`, and Case 8's third disjunct is not redundant.
- Scope hypotheses overshot in Phases 24 (122 vs 60-70) and 25 (39 vs 8-12) for the same
  structural reason three phases running: group lists count headline results and omit supporting
  APIs.

## References

- `specs/867_formalize_gabbay_separation_ztime/plans/04_landed-device-resize-10-2-7-10-2-8.md`
- `specs/867_formalize_gabbay_separation_ztime/handoffs/phase-24-handoff-20261109T080000Z.md`
  through `phase-28-handoff-20261109T103000Z.md`
- `specs/867_formalize_gabbay_separation_ztime/summaries/04_ghr-10-2-7-untl-nesting-summary.md`
  (Phase 23, the sizing addendum this dispatch built on)
- `specs/867_formalize_gabbay_separation_ztime/issues.jsonl` (three issues, two wins, recorded
  as they arose)
