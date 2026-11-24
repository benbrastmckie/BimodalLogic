# Implementation Summary: Task #972

- **Task**: 972 - Theorem library: tableau pipeline
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-23T21:39:30Z
- **Completed**: (not complete — 3 of 8 phases landed)
- **Effort**: ~3 hours of a 14.5-hour plan
- **Dependencies**: `theorem_library_layout_and_registry` (landed), `proof_mode_axiom_audit_and_cost_baseline` (landed)
- **Artifacts**: plans/01_tableau-pipeline-into-library.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-3 of the eight-phase plan are complete and committed: the gate baseline and the two
figures the research report left unmeasured, the L-level uniform substitution as data, and the
subsumption matcher with its tests and build-time command. Phases 4-8 — the Lean-source emitter,
the five reserved-stage diagnostics emitters, the driver executable, the end-to-end run at the
ruled bound, and the docs/record revision — are not started.

Two findings from this dispatch change what later phases should do, and one of them needs a
user ruling before Phase 7 can be executed as written.

## What Changed

- `FormalSystem/ProofSystem/Substitution.lean` — **new.** The five-declaration L-level mirror of
  `substPlus`/`PlusDerivationTree.ofTMSubst`: `substF`, `substCtxF`, `substF_atom`,
  `substF_reflectTime`, `Axiom.ofSubst` (20 arms), `Axiom.minFrameClass_ofSubst`,
  `DerivationTree.subst` (7 arms) and `DerivationTree.substNil`. Compiled clean on the first
  build with no warnings. `#print axioms DerivationTree.substNil` reports
  `[propext, Quot.sound]` — no `sorryAx`, no `Classical.choice` — which is what
  `register_theorem` accepts.
- `BimodalLib/Subsumption.lean` — **new.** `matchSubst?` (one structural pass, failing on
  disagreement when a schema atom recurs), `isSubstInstance`, `assignmentOf`, `rowStatement?`,
  `subsumedBy?`, and the command `assert_no_subsumed_entries [P]`.
- `Tests/BimodalLibTest/SubsumptionTest.lean` — **new.** 30 cases across the four classes the
  plan names (positive, negative asserted `false`, repeated-variable agreement, reflexive), plus
  witness-level checks that substituting the returned assignment reproduces the target, an
  asymmetry pair, and a positive control against two live registry statements.
- `specs/972_theorem_library_tableau_pipeline/probes/baseline.md` — **new.** The full gate
  baseline, the four carried figures re-confirmed, the enumeration yield, the four-way DECIDE
  split, the eight-gate pass rate per (fragment, frame class), and the cost figures with their
  contamination stated.
- `specs/972_theorem_library_tableau_pipeline/probes/gate-yield-probe.lean` — **new.** The
  sampled enumerate/decide/gate probe.
- `FormalSystem.lean`, `FormalSystem/ProofSystem/README.md`, `FormalSystem/README.md`,
  `README.md`, `BimodalLib.lean`, `BimodalLib/README.md`, `Tests/BimodalLibTest.lean`,
  `typst/generated/status.typ` — regenerated or extended for the two new modules.

## Decisions

- **The matcher treats every atom of the schema as a substitution target, not only `schemaVar`
  atoms.** That is `substF`'s own semantics, and a matcher privileging schema variables would
  disagree with `substF` and so with `TheoremEntry.profile_eq`. One test assertion was written
  on the opposite assumption and was corrected, not the matcher.
- **`BimodalLib/Subsumption.lean` imports `FormalSystem.ProofSystem.Substitution`.** Its witness
  exists to feed `substF`, so the dependency is real and is declared rather than left implicit.
- **`assert_no_subsumed_entries` takes `assert_registry_complete`'s optional prefix argument**,
  scoping the candidate side. See Plan Deviations.
- **A gate figure's counts and its timings were separated.** Counts reproduced exactly across two
  runs; timings did not and are labelled contended throughout.

## Plan Deviations

- **Phase 1 closed `[COMPLETED WITH EXCLUSIONS]`**, with a `#### Reasoned Exclusions` table in
  the plan. Three items excluded: the `ModalBoolean` gate rows at `Dense`/`ZTime`/`RTime`, the
  `TemporalBoolean` and `ModalTemporalBoolean` figures entirely, and an uncontended timing
  figure. Gate evaluation at `Dense` on a modal fragment is the dominant cost of the pipeline:
  the first run did not finish those four rows in nine minutes and reached 2.8 GB RSS at 100%
  CPU with `earlyoom` on this machine configured to prefer killing `lean`. No excluded row
  blocks a later phase.
- **Phase 3's `assert_no_subsumed_entries` landed with an optional prefix argument** rather than
  as the unscoped command alone. Annotated inline on the plan's own checklist item. The unscoped
  form — the literal plan reading — is implemented and works; it reports **26 of the 190** live
  registry rows as substitution instances of another row. **A ruling is needed before Phase 7
  wires it.** See Follow-ups.
- **Phase 3's `BimodalLib/README.md` stamp bump was a no-op.** The stamp already read
  `2026-11-23`, the commit date. The module listing was extended with the `Subsumption.lean`
  row, which `INV` requires because that table is hand-maintained.
- **The plan's per-phase file lists omit the test library roots.** `Tests/BimodalLibTest.lean`
  had to be edited for the new test to be in the build at all, and because `file_scope` is
  harvested from the plan, `git-commit-scoped.sh` dropped it as out-of-scope and committed
  Phase 3 with the test orphaned in `HEAD`. Both roots were added to task 972's `file_scope`
  via `state-write.sh` and the root was committed separately. Phases 4 and 5 add
  `Tests/BimodalToolsTest/*.lean` and would have hit the same gap; the root is now in scope.

## Verification

- Build: **Success.** `lake build FormalSystem.ProofSystem.Substitution`,
  `lake build BimodalLib.Subsumption`, `lake build BimodalLib` and `lake build BimodalLibTest`
  each exit 0 with **zero** warnings (CI builds `--wfail`, so a warning is a failure). All
  through `lake-build-guard.sh`.
- Sorry count: **0** (`lean-sorry-census.sh` over all 12 resolved source roots).
- Vacuous count: **2**, both pre-existing and outside this task —
  `FormalSystem/Examples/TemporalStructures.lean:495` and
  `FormalSystem/Semantics/PointTransport.lean:163`, last touched by other work. **0** in any
  file this task added.
- Axiom count: **14**, unchanged. `git diff fb36574fa^..HEAD -- '*.lean'` adds **zero** `axiom`
  lines.
- `#print axioms`: `substF` and `Axiom.ofSubst` depend on no axioms; `substF_atom`,
  `substF_reflectTime` and `Axiom.minFrameClass_ofSubst` on `[propext]`;
  `DerivationTree.subst` and `DerivationTree.substNil` on `[propext, Quot.sound]`. No `sorryAx`,
  no `Classical.choice` anywhere.
- `lake exe mk_all --lib FormalSystem --check`: exit 0.
- `scripts/typst-sync-check.sh --counts-only`: exit 0, `MISMATCH_COUNT=0`.
- `scripts/library-index.sh --no-build --check`: exit 0, `INDEX.md` current — correct, since
  `Subsumption.lean` registers no row.
- `scripts/check-module-invariants.sh --no-build`: exit 1, **byte-identical to the Phase 1
  baseline** — `C12` and `C20` fail, both pre-existing and outside this task's file scope.
  `INV`, `B3`, `C26` and `C33` all PASS.
- `scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib`: exit 1 with the **same four**
  new stale dates as the baseline, all under proof-mode or other trees this plan may not edit.
  No grandfathered stamp (`BimodalTools/README.md`, `FormalSystem/README.md`,
  `FormalSystem/ProofSystem/README.md`) was modified.
- Tests: **Passed.** Every `#guard` and `example` in `SubsumptionTest.lean` elaborates, negative
  cases asserted `false` rather than merely absent.
- Files verified: Yes.

### Scoped verification discharge (batch gate deferral)

Per this dispatch's Batch Gate Deferral directive, the complete gate set was **deferred to the
batch stage, not independently run**. The scoped discharge was
`bash .claude/scripts/verify-touched.sh`, which derived 17 touched paths, resolved them and ran
the narrowed battery. It exits 1 on nine failing suites, every one of them under
`.claude/scripts/tests/` — `test-force-phases.sh`, `test-gate-cache-equivalence.sh` (EXPECTED),
`test-gate-out-repair-reporting.sh`, `test-lint-dead-command-recommendations.sh`,
`test-loop-guard-budget-override.sh`, `test-orchestrate-build-dispatch.sh`,
`test-postflight-deploy-gate.sh`, `test-redeploy-checkpoint-promotion.sh`,
`test-roadmap-generation.sh`, plus `test-deploy-baseline-lib.sh` in the fallback set.

**None is attributable to this task.** All four commits touch **zero** paths under `.claude/`
or `agent-system/`, verified per commit. The failures are consistent with the stale `core`
extension this dispatch's own deploy-freshness context announced. `verify-touched.sh` also
warned that it was given no `--task-dir`, so its eight owed paths were reported but not durably
recorded.

## Impacts

- `FormalSystem.ProofSystem.substF` and `DerivationTree.substNil` are now available to the whole
  published library. They are the hard prerequisite for a schematic registry row: they turn a
  tableau's derivation of one concrete formula into the `∀ v, DerivationTree fc [] (stmt v)`
  shape `TheoremEntry.proof` demands. Phase 4's `entrySource` and Phase 7's admission both route
  through `substNil`.
- `BimodalLib.isSubstInstance` gives the ADMIT stage its subsumption test.
- `assert_no_subsumed_entries BimodalLib.Theorems.Enumerated` is wired in the test and is
  vacuous today; it begins guarding the moment Phase 7 registers its first generated entry.

## Follow-ups

- **RULING NEEDED — the scope of registry non-redundancy.** `assert_no_subsumed_entries` with no
  prefix reports 26 of 190 live rows as substitution instances of another row. These are not
  defects: the library deliberately names laws that are instances of more general schemata.
  `Combinators.topThm : ⊤` is `Combinators.identity` at `⊥` and *its own proof term is literally
  `identity Formula.bot`*; `Propositional.em : A ∨ ¬A` unfolds to `(A → ⊥) → (A → ⊥)`, an
  instance of `A → A`. Phase 7's task "add `assert_no_subsumed_entries` to
  `BimodalLib/Theorems/Complete.lean`, so non-redundancy of the registry becomes a build
  invariant" would therefore turn the build red on 26 hand-curated entries. Three routes:
  (a) wire the **scoped** form over `BimodalLib.Theorems.Enumerated`, so non-redundancy is a
  property of machine-generated entries only — this is what the code supports today and what
  the ADMIT rule in the task description actually asks for;
  (b) wire the unscoped form and baseline the 26, in the shape
  `scripts/readme-date-baseline.txt` uses;
  (c) wire the unscoped form and drop the 26 rows. Not recommended — it would delete named laws
  the manual cites.
  Nothing is wired globally today, so the build is green either way until this is settled.
- **Phase 6 must make the atom pool an explicit, recorded parameter.** The yield is
  superexponential in pool size, and the live counts at a 2-atom pool (Boolean 14, ModalBoolean
  133) are far below the plan's Scope Hypothesis (902, 751), which came from a dataset
  tabulation at a wider pool. A yield figure without its pool is meaningless.
- **Phase 6 must default to `Base` alone for the frame-class list**, and treat `--deadline-s`
  and `--checkpoint` as requirements rather than conveniences. A `Dense` gate pass over a modal
  fragment is a plausible OOM on this machine, not merely a slow run.
- **The `ZTime` certificate route is the only route at `ZTime`.** `regionLabel` and
  `temporalWitness` come back `false` on every formula there, so `BranchGates.gated` is 0 of 11.
  Phase 6 must not treat a `ZTime` `gated = false` as a retryable surprise.
- **`extractionFailed` is a first-class outcome.** At `ModalBoolean` c5 it is 26 of 133 — as
  large as `fuelExhausted` and larger than `valid`. Decision 7's insistence on
  `DecisionResult`'s four names over `FormulaLabel`'s three is load-bearing exactly here.
- Phases 4-8 remain, in plan order. Phase 4 depends only on Phase 2, which is landed.
- The three context-file extensions the research report recommends land under a source store in
  another repository and remain follow-ups, not work for this task.

## References

- `specs/972_theorem_library_tableau_pipeline/plans/01_tableau-pipeline-into-library.md` — the plan
- `specs/972_theorem_library_tableau_pipeline/reports/01_tableau-pipeline-into-library.md` — the research report
- `specs/972_theorem_library_tableau_pipeline/probes/baseline.md` — the Phase 1 baseline and figures
- `specs/972_theorem_library_tableau_pipeline/issues.jsonl` — the issues and wins recorded as they arose
- `FormalSystem/PlusLanguage/Substitution.lean` — the L⁺ module Phase 2 mirrors arm for arm
- `BimodalLib/Registry/Complete.lean` — the elaborator shape `assert_no_subsumed_entries` mirrors
- Commits: `fb36574fa` (phase 1), `dcee738eb` (phase 2), `202e9b8ad` and `d8e8adf1f` (phase 3)
