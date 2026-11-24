# Implementation Summary: Task #972

- **Task**: 972 - Theorem library: tableau pipeline
- **Status**: [COMPLETED]
- **Started**: 2026-11-24T07:00:00Z
- **Completed**: 2026-11-24T11:05:00Z
- **Effort**: ~4 hours (Phases 4-8; Phases 1-3 landed in a prior dispatch)
- **Dependencies**: `theorem_library_layout_and_registry` (landed), `proof_mode_axiom_audit_and_cost_baseline` (landed)
- **Artifacts**: plans/02_tableau-pipeline-into-library.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The five stages of `records/theorem-library.md` — enumerate, decide, extract, certify, admit —
now run end to end as one command, and the theorem library has its first machine-generated
entries. This dispatch closed Phases 4 through 8: the Lean-source emitter, the five
reserved-stage diagnostics emitters, the stage driver with its executable target and named entry
point, the run at the user's ruled bound with admission, and the documentation revision.

At the ruled bound over a two-atom pool the pipeline decided 3,955 formulas and admitted **six**
non-subsumed schemata, wrote 2,981 certified refutations in the form the countermodels record
will read, and registered 2,895 non-admitted outcomes as 48 aggregate conjecture cells.
`lake build BimodalLib` is green with all three build-time assertions passing, including the
prefix-scoped non-redundancy invariant, which caught four defective entries on its first real
run.

## What Changed

- `BimodalTools/LeanSourceEmit.lean` — new (430 lines). `atomSource`, `formulaSource`,
  `contextSource`, `schemaSource`, `schemaFormula`, `schemaFormulaSource`,
  `axiomConstructorName` and `axiomSource` (20 arms each), `derivationSource` (7 arms),
  `commentSafe`, `closer`, `wrapSource`, `entrySource`. Five `example`-level coverage assertions
  pin the 20 arms against `allAxiomNames`.
- `BimodalTools/PipelineDiagnostics.lean` — new (556 lines). `EnumerateRecord`, `DecideRecord`,
  `ExtractRecord`, `CertifyRecord`, `AdmitRecord`, each with `toJsonFields`/`toJson`/`keys`; the
  closed vocabularies `Verdict` (four names), `Grade`, `Disposition`; `datasetStatementId`;
  `gatesValue`; `readCommitOption`/`readZeroTimingsOption`; `zTimeWellFormed` and
  `dispositionWellFormed`.
- `BimodalTools/TheoremPipeline.lean` — new (790 lines). The stage driver: `enumerateStage`,
  `decideOne`, `axiomNamesOf`, `rebuildOpenBranch`, `certifyStage`, `certifyByCertificate`,
  `strictlySubsumedBy`, the two-pass `admitStage`, `runStages`, `finish`, `run`, `runAll`,
  `ruledBound`, `modulePreamble`, `moduleSource`.
- `BimodalTools/TheoremLibraryPipelineMain.lean` — new (272 lines). The CLI; the root name is
  forced by `C25N`.
- `scripts/theorem-library-pipeline.sh` — new (352 lines). The one named entry point.
- `specs/evidence/theorem-library-pipeline/registry-statements.lean` — new. The registry-statement
  snapshot ADMIT filters against.
- `BimodalLib/Theorems/Enumerated/Base.lean` — new, **generated** (2,053 lines). Six admitted
  entries with their `register_theorem` lines.
- `BimodalLib/Conjectures/Enumerated.lean` — new (640 lines). The 48 aggregate conjecture cells.
- `BimodalLib/Theorems/Complete.lean` — wires `assert_no_subsumed_entries
  BimodalLib.Theorems.Enumerated`, with a comment at the site naming the scope and why.
- `BimodalLib.lean`, `BimodalTools.lean`, `Tests/BimodalToolsTest.lean` — the new imports.
- `Tests/BimodalToolsTest/LeanSourceEmitTest.lean`,
  `Tests/BimodalToolsTest/PipelineDiagnosticsTest.lean` — new, 40+ `#guard`s between them.
- `lakefile.toml` — the `theorem_library_pipeline` exe block; the header comment now records the
  `BimodalTools → BimodalLib` edge.
- `docs/reference/bimodal-lib.md`, `docs/reference/diagnostics.md`,
  `docs/reference/API_REFERENCE.md`, `records/theorem-library.md`, `scripts/README.md` — the
  documentation revision.
- `BimodalLib/INDEX.md` (regenerated, 65 new rows), four README listings and stamps,
  `typst/generated/status.typ`.

### The measured run

```bash
bash scripts/theorem-library-pipeline.sh --all-fragments --atoms 2 \
  --frame-class Base --frame-class Dense --frame-class ZTime --frame-class RTime \
  --deadline-s 2400 --timeout-ms 15000
```

| Figure | Value |
|---|---|
| Enumerated after canonicalization and the `profileF` filter | Boolean 14, ModalBoolean 133, TemporalBoolean 3,384, ModalTemporalBoolean 1,688 |
| Decided | 3,955 — exhaustive for the first three fragments, 424 of 1,688 for ModalTemporalBoolean |
| Verdicts | valid 13, invalid 3,523, `fuelExhausted` 371, `extractionFailed` 48 |
| Admitted | **6** |
| Subsumed | 7 (4 by hand-curated rows, 3 by sibling generated entries) |
| Conjectures | 2,895 |
| Refutations | 2,981, all `gated_tableau`: Base 1,047, Dense 967, RTime 967, **ZTime 0** |
| Stage records | 24,927 across all five stages |

The figures reproduced identically across four successive invocations. The six admitted schemata
are `A → (B → A)`, `□⊥ → A`, `□A → A`, `□(□⊥ → A)`, `□(□A → A)` and `A → □(□(A → ⊥) → ⊥)`.

## Decisions

- **The emitted module wraps at 98 columns, and emitted names are camelCase.**
  `linter.style.longLine` is enforced at 100 characters package-wide (measured: zero lines over
  100 anywhere under `BimodalTools/` or `BimodalLib/`, then confirmed from a live build warning),
  and `C26` plus the `env_linter` ceiling rule out an underscore in a `def` name.
- **In-module assertions are `example`, not `#guard`.** `lean_lib BimodalTools` carries no
  `linter.hashCommand` opt-out; only the three test libraries do, and CI builds `--wfail`.
- **Key order is read off `toJsonFields`, not the rendered object.** `Json.mkObj` stores fields in
  a search tree, so a rendered record is alphabetical.
- **`ZTime` skips gate evaluation structurally.** The frame-class dispatch selects the certificate
  route there, so the skip is a branch and not a removable optimization.
- **ADMIT is two passes, against the registry and against the survivors.** Both were needed; see
  Plan Deviations.
- **The generated entry's closer is `simp only [..., reduceIte] at h` + `exact h`**, not `simpa`,
  which routes an arity-2 entry through `Classical.choice`.
- **The generated module pins its own `set_option linter.style.longFile`**, after the module
  docstring, which the style linter requires to come first after the imports.

## Plan Deviations

- **Phase 4** altered: the coverage assertion is five `example`s rather than `#guard`s
  (`hashCommand` is on for `BimodalTools`); `entrySource` additionally wraps every emitted line
  and uses camelCase names; `--emit-inventory` was also run for two generated README blocks.
- **Phase 5** altered: each record exposes `toJsonFields`/`toJson`/`keys` because `Json.mkObj`
  renders alphabetically, so key order is only observable before rendering; six golden records
  rather than five, the extra one pinning the `ZTime` certify shape.
- **Phase 6** altered: the generated module's docstring carries a reconstructed, path-free
  invocation, because a path beginning with a slash and a hyphen opens a nesting Lean block
  comment inside it; `writeJsonl` renamed to `writeJsonObjects` for `C23`; a `--certificates`
  flag was added, without which the `decidableCertifies` call the plan names is unreachable.
- **Phase 7** altered: run as one `--all-fragments` invocation, since the task asks for one
  command over four fragments and admitting per fragment would let a later fragment register an
  instance of an earlier one's entry; and a `--registry-statements` input was added, because the
  ADMISSION rule's "an entry already present" includes the hand-curated rows. **Phase 7 is
  `[COMPLETED WITH EXCLUSIONS]`** — see its `#### Reasoned Exclusions` for the truncated
  ModalTemporalBoolean tail, the `(dual := …)` declarations with no referent, and the absent
  `ZTime` certificate grade.
- **Phase 7** skipped: `(dual := …)` for polarity pairs. All six admitted schemata are Boolean or
  ModalBoolean; both named pairs are temporal and neither survived admission.

## Verification

- Build: **Success**. Full `lake build` → exit 0, 3,018 jobs, zero errors. `lake build BimodalLib`
  → exit 0, zero warnings, so `assert_registry_complete`, `assert_proof_fragments_recorded` and
  `assert_no_subsumed_entries BimodalLib.Theorems.Enumerated` all pass. `lake build BimodalLibTest`,
  `lake build BimodalToolsTest`, `lake build theorem_library_pipeline` → exit 0, zero warnings.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: **2**, both pre-existing and outside this task's file scope —
  `FormalSystem/Semantics/PointTransport.lean:163` (last touched by PR #11) and
  `FormalSystem/Examples/TemporalStructures.lean:495` (last touched by task 756). **Zero
  introduced by this task.**
- Axiom count: **14 at the task's base commit and 14 at HEAD — unchanged.** No file this task
  added contains an `axiom`, a `sorry` or a `native_decide`.
- `#print axioms` on all six admitted entries: `[propext, Quot.sound]`. No `sorryAx`, no
  `Classical.choice`.
- Plan compliance spot-check: **passed**. All eight declarations named in the plan's Goals resolve
  in the resolved source roots.
- `scripts/check-module-invariants.sh --no-build` → **exit 0, zero FAILs**.
- `scripts/library-index.sh --no-build --check` → exit 0. `scripts/typst-sync-check.sh
  --counts-only` → exit 0.
- `scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib` → 4 new stale findings, all four
  under `FormalSystem/` directories this task never touches; recorded PASS on Condition 4.
- `verify-touched.sh` → 84 passed, 1 failed, 10 skipped. The failure is
  `test-deploy-baseline-lib.sh`'s deploy warm-cache control, whose subjects live under
  `.claude/**` and which no commit of this task touches; the dispatch independently reports the
  deployed tree stale for extension `core`.
- Determinism: two `--json` runs at the same bound and atom pool produced byte-identical records,
  countermodels, sidecar and summary.
- Files verified: Yes.

## Impacts

- The theorem library has machine-generated entries for the first time, and non-redundancy over
  them is a build invariant rather than a convention the pipeline merely tries to maintain.
- `FormalSystem.ProofSystem.Substitution` makes uniform substitution available as data to any
  consumer that needs to generalize a concrete derivation — the first such consumer being ADMIT.
- The five reserved diagnostics stages are now emitted, so the record schema's reservation is
  discharged and `data/theorem-library-pipeline.jsonl` exists for the Evaluation lane to read.
- `data/theorem-library-countermodels.jsonl` is written in the form
  `theorem_library_countermodels` will read, and nothing in it is registered.
- The `BimodalTools → BimodalLib` import edge is live and recorded in `lakefile.toml`.

## Follow-ups

- **CERTIFY has no time budget.** `--timeout-ms` bounds `decideOne` only; the tableau rebuilds
  that follow it are pure and untimed, and `--deadline-s` is checked at the top of each loop
  iteration, so one formula can hold the whole budget. That is what truncated
  ModalTemporalBoolean at 424 of 1,688. Give CERTIFY its own `IO.asTask` budget.
- **Records are written only after the loop**, so killing a stalled run loses every record. Flush
  incrementally.
- **`theorem_library_countermodels`** is the consumer of `data/theorem-library-countermodels.jsonl`;
  nothing in it is admitted until that record lands.
- **No producer of a `RawCertificate` from a tableau branch exists**, so the `ZTime` certificate
  route can only check supplied certificates. A branch-to-certificate bridge would make the
  `ZTime` grade reachable.
- **Three context-file extensions** the research report recommends (the
  `proof-mode-cost-baseline.sh` `SURFACE` collision note, a note fixing the pattern-aware
  complexity measure, and the MCP fallback addition) land under a source store in another
  repository and are not work for this task.
- `Stage.carriesFormulaField` remains the unexercised obligation it was: it returns `true` for
  `enumerate` and `extract`, but neither stage's reserved key list holds a formula-valued field.

## References

- specs/972_theorem_library_tableau_pipeline/plans/02_tableau-pipeline-into-library.md
- specs/972_theorem_library_tableau_pipeline/reports/01_tableau-pipeline-into-library.md
- specs/972_theorem_library_tableau_pipeline/probes/baseline.md
- specs/972_theorem_library_tableau_pipeline/summaries/01_tableau-pipeline-into-library-summary.md
- specs/972_theorem_library_tableau_pipeline/handoffs/ (phases 4-7)
- records/theorem-library.md, records/proof-mode.md (M19, LANE: library)
