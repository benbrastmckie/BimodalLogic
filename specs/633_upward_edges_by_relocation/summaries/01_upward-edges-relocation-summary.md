# Implementation Summary: Task #633

- **Task**: 633 - Remove the upward edges by relocation
- **Status**: [COMPLETED]
- **Started**: 2026-09-20T22:05:00Z
- **Completed**: 2026-09-21T01:10:00Z
- **Effort**: ~3 hours
- **Dependencies**: 630, 632 (both landed at `b1ab4bf3a`)
- **Artifacts**: plans/01_upward-edges-relocation.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`FormalSystem/`'s import graph carried 70 upward lines at HEAD, 15 of them running into
`Automation/`. This task deleted them by relocation, not by renumbering: a new layer-0
`FormalSystem/Tactic/` directory absorbed the five attribute declarations that eleven of those
lines existed to reach, and `Init.lean` imports it so every module inherits them transitively.
Three further modules moved to the directories their dependencies and namespaces already implied.
The measured layer order was then corrected in `scripts/measure-refactor-partitions.py`, turned
into a mechanical equality assertion in `scripts/check-metalogic-cycles.sh`, and written into
`ORGANISATION.md` and `docs/ARCHITECTURE.md`.

All six phases landed as six commits, each against a green build-inclusive harness. This task
proved nothing: it moved and deleted text.

## What Changed

**New, layer 0**

- `FormalSystem/Tactic/Attr.lean` — the five attribute/simp-set declarations (`truth_norm`,
  `reflect_time_norm`, `formula_unfold`, `formula_fold`, `@[tmLemma]`) merged from three
  `Automation/` modules. Imports `Lean` only; `FormalSystem/Init.lean` imports it.
- `FormalSystem/Tactic.lean` — sibling aggregator, importing `Init` and `Tactic.Attr` (R-6, R-9).
- `FormalSystem/Tactic/README.md` — states the attributes-only constraint (R-7).

**Moved**

- `Automation/Tactics/Meta.lean` → `Tactic/Meta.lean`
- `Automation/Tactics/PropDecide.lean` → `Metalogic/Decidability/Propositional/Tactic.lean`
- `Metalogic/Core/DeductionTheorem.lean` → `Theorems/DeductionTheorem.lean` (namespace kept)
- `Metalogic/Decidability/FMP/Periodicity.lean` → `Semantics/Periodicity.lean` (contents unchanged)

**Deleted**

- `Automation/{TruthNormAttr, NormalizationAttr, LemmaDB}.lean`, and the 13 import lines that
  named them (11 of the 13 upward), across 13 files.

**Scripts**

- `scripts/measure-refactor-partitions.py` — `LAYERS` rewritten to the measured order
  (`{Syntax, ProofSystem, ForMathlib, Init, Tactic}` 0 → `Semantics` 1 → `Theorems` 2 →
  `{Metalogic, Automation}` 3 → `Examples` 4); the `into_automation` and
  `theorems_to_metalogic`/`metalogic_to_theorems` comments rewritten for the flipped asymmetry;
  the measurement narrative refreshed.
- `scripts/check-metalogic-cycles.sh` — a **second, independent** assertion added behind the same
  exit code: the library-wide upward set equals a recorded 7-line allowlist, failing on surplus
  **and** shortfall. It loads `LAYERS` by path so there is one copy of that table in the
  repository, and reads the graph through `scripts/lib/import_graph.py` rather than the script's
  own regex. The existing cycle assertion is intact and unchanged.
- `scripts/CheckInitImportsMain.lean` — third exception (`FormalSystem.Tactic.Attr`, the cycle);
  "eleven" → eight.
- `scripts/typst-module-map.sh` — header narrates the two out-of-glob tactic modules.

**Documentation**

- `ORGANISATION.md` — layer table rewritten to the measured order, `Tactic/` added to the layer-0
  inventory, and the `Decidability → {ProofSearch, Normalization}` edge stated in prose as a
  legitimate intra-layer edge rather than left implicit by a missing row.
- `docs/ARCHITECTURE.md` — diagram, both upward-edge sections and four independently stale claims
  (R-12): `Semantics → ProofSystem` described as upward though the diagram put ProofSystem below;
  `DataExport.lean`/`TraceExporterMain.lean`/`TableauProofStepsMain.lean` listed as `Automation/`
  modules though all three are `BimodalTools/` now; a top-level `PlusLanguage/`; `Automation/`
  described as holding "the ML dataset pipeline".
- `docs/development/PUBLICATION_REFACTOR.md` — the `SuccessPatterns` strike recorded (not
  deleted), the Phase 4 counts refreshed, Phase 4 marked landed, the residual `AxiomDischarge`
  lines named as Phase 5's, and a namespace-map row added for `Tactics/Meta.lean`.
- Path/module citations swept across `docs/{project-info/tactic-registry.md,
  reference/tactic-reference.md, reference/API_REFERENCE.md, development/MODULE_ORGANIZATION.md,
  development/NAMING_CONVENTION_DEVIATION.md, project-info/FEATURE_REGISTRY.md,
  project-info/implementation-status.md}` and `FormalSystem/Metalogic/Algebraic/README.md` —
  every file on the plan's list needed an edit; none was dropped as already-correct.
- `typst/chapters/p4-proof-automation.typ` — two `roles` rows removed, the line-48 prose
  re-pathed, and a paragraph added narrating the two departures (R-1);
  `typst/generated/automation-module-map.typ` regenerated (total 3577 → 3321).

## Decisions

- **Layer assignment A, as the plan mandated (R-11).** `Automation` sits *beside* `Metalogic` at
  layer 3, keeping all four acceptance source directories strictly below it. A comment in
  `measure_upward_edges` records why the acceptance source set must not be derived from `LAYERS`:
  doing so would let a renumber make a quarter of the criterion read zero without a file moving.
- **`Tactic/Attr.lean` imports `Lean` only.** `Init.lean` imports it, so the reverse edge is the
  cycle. `register_simp_attr` and `register_label_attr` are core Lean commands and need nothing
  else; the build confirms it.
- **The 13 import lines were deleted outright, not re-pointed** at `FormalSystem.Tactic.Attr`.
  Every one of those modules reaches `Init` transitively (C24 asserts it), which is the point of
  the relocation.
- **Two namespaces deliberately did not move with their files**, each recorded in the moved
  file's own module docstring: `Theorems/DeductionTheorem.lean` keeps
  `FormalSystem.Metalogic.Core` (51 fully-qualified call sites across 13 files), and
  `Tactic/Meta.lean` keeps `FormalSystem.Automation` (reached via `open` at every consumer).
- **The layer-order assertion is an equality, not a zero-check**, and was seen to fail in both
  directions before being trusted (below).

## Plan Deviations

- **Phase 2 scope hypothesis, corrected downward.** The plan named three `Automation/Tactics/*`
  consumers of `Meta.lean` (`Commands`, `Search`, `Deduction`); the measured set is two —
  `Deduction.lean` does not import it. Recorded as a finding, not forced.
- **Phase 4 namespace-audit prediction, corrected upward.** The plan predicted the `unrelated`
  bucket would settle at 23 (24 − `PropDecide` − `Periodicity` + `Theorems.DeductionTheorem`).
  The measured value is **24**: `Tactic/Meta.lean` became a new `unrelated` row, since it keeps
  `namespace FormalSystem.Automation` while its module path is now `FormalSystem.Tactic.Meta`.
  The plan did not anticipate that row because it did not anticipate `Meta.lean` needing a
  namespace decision of its own. Handled the way the plan handled the analogous
  `DeductionTheorem` row: recorded in the moved file's docstring, not renamed.
- **Phase 2's "add the relocated module to `Metalogic/Decidability/Propositional.lean`"** — no
  such aggregator exists; `Metalogic/Decidability.lean` is the aggregator covering that directory
  and already named `Propositional/{PropForm,Kalmar,Decidable}`. The import was added there,
  which is what the plan's "(or whichever aggregator covers that directory)" provided for.
- **`scripts/measure-refactor-partitions.py`'s historical narrative was not collapsed.** Phase 1
  listed it as a citation to rewrite; the "Measured on commit 220e94ea4" block is a *historical*
  statement, so it was annotated rather than re-pathed, and Phase 5 restructured it into a
  current-measurement block plus an explicitly historical paragraph. This is the R-3 shape the
  plan warned about.
- **`Boneyard/` import lines were rewritten by `move-modules.py`** (3 files, `DeductionTheorem`).
  Left as the tool wrote them: the archive is never built, and the rewrite keeps its import lines
  pointing at modules that exist.

## Verification

- Build: **Success** — `lake build` exit 0, 2655 jobs; `lake build BimodalTest` exit 0, 2707 jobs.
- `bash scripts/check-module-invariants.sh` (full, build-inclusive): **ALL CHECKS PASSED**,
  including C24 (every module reaches `Init`) and C25 (all 13 `lean_exe` roots compile — the
  check a green `lake build` does not cover, per R-4).
- `lake exe checkInitImports`: exit 0, three recorded exceptions consumed.
- Sorry count: **0** (`lean-sorry-census.sh FormalSystem/`).
- Vacuous count: **0 attributable to this task**. The single grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:481` (`int_domain_universal ... := trivial`), is
  present verbatim at the pre-task commit `a5954ba91` and is a real statement about an `Int`-domain
  history, not a placeholder.
- Axiom count: **12**, unchanged from `a5954ba91`.
- Tests: **Passed** (`lake build BimodalTest`).

**Acceptance criterion — met.** `python3 scripts/measure-refactor-partitions.py upward-edges`:

| Measure | Result |
|---|---|
| Lines into `Automation/` from `Syntax`, `Semantics`, `ProofSystem`, `Theorems` | **0** |
| `theorems_files_importing_metalogic` | **empty** |
| Total upward import lines | **7**, all `Syntax/MinusLanguage/AxiomDischarge.lean → Theorems/*` |
| `namespace-audit` unrelated bucket | 24 (see Plan Deviations) |

**The new gate was seen to fail before being trusted.** Both negative tests were run by hand and
reverted:

- *Surplus*: adding `import FormalSystem.Metalogic.Soundness` to `Semantics/TemporalOrder.lean`
  produced `SURPLUS FormalSystem.Semantics.TemporalOrder -> FormalSystem.Metalogic.Soundness`
  and exit 1.
- *Shortfall*: deleting `import FormalSystem.Theorems.TemporalDerived` from
  `AxiomDischarge.lean` produced `SHORTFALL FormalSystem.Syntax.MinusLanguage.AxiomDischarge ->
  FormalSystem.Theorems.TemporalDerived` and exit 1.
- After restoring both, the script exits 0 on both assertions.

**Typst.** `typst compile BimodalReference.typ` exits 0, which exercises
`#assert(roles.len() == automation-module-map.len())` — the hard assert `typst-sync-check.sh`
does not run (R-1).

**Pre-existing red checks, at baseline — no new rows** (the declared bar, not zero):

| Check | Baseline | After |
|---|---|---|
| `readme-lint.sh` | 21 broken refs, 0 missing READMEs | 21, 0 |
| `typst-sync-check.sh` | `TOTAL_VIOLATIONS=9`, `MISMATCH_COUNT=2`, module-map 0, machine-appendix 0 | 9, 2, 0, 0 |

- Files verified: Yes.

## Impacts

- **Every module in the library now inherits the attributes and named simp sets through
  `Init.lean`.** A module tagging `@[truth_norm]` or `@[tmLemma]`, or calling
  `simp only [formula_unfold]`, needs no import for it. A future attribute declaration belongs in
  `Tactic/Attr.lean`, and nowhere else.
- **`FormalSystem/Tactic/Attr.lean` is upstream of the entire library**, so anything added to it
  is recompiled by every module. The attributes-only constraint in `Tactic/README.md` is the
  reason, not a style preference.
- **The layer order is now a gate, not prose.** Any new upward import line fails
  `check-metalogic-cycles.sh`, which is not wired into `check-module-invariants.sh` (deliberately)
  and must be run directly.
- **`ORGANISATION.md`'s table and `LAYERS` must change together.** Both files say so; the
  assertion script loads `LAYERS` rather than keeping a second copy.
- **`Theorems/DeductionTheorem.lean` is available to `Theorems/` consumers without a `Metalogic/`
  dependency**, which is what removed the last `Theorems → Metalogic` lines.

## Follow-ups

- **The 7 residual upward lines are Phase 5's, by design.** `docs/development/PUBLICATION_REFACTOR.md`
  Phase 5 (the `{Plus,Minus,Star}Language` directory merges) moves
  `Syntax/MinusLanguage/AxiomDischarge.lean` out of `Syntax/` and empties the allowlist. Because
  the assertion fails on a shortfall, that phase landing will fail this gate until the seven
  `ALLOWLIST` entries are deleted — which is the intended signal, recorded in both the script
  header and the Phase 5 acceptance bullet.
- **Two recorded namespace exceptions await a future FQN pass**:
  `Theorems.DeductionTheorem` (namespace `Metalogic.Core`) and `Tactic.Meta` (namespace
  `Automation`). Both are informational `namespace-audit` rows, never gated, and both are recorded
  in their own module docstrings so neither is rediscovered as an oversight.
- **The two pre-existing red checks are untouched and still red**: `readme-lint.sh`'s 21
  `../Boneyard/` links one `../` short, and `typst-sync-check.sh`'s `sorry-total committed=4
  live=0` plus 9 `docs/training/PIPELINE.md` line-range violations. Neither is caused by nor cured
  by this task; both were explicit non-goals.
- **C20 line-number citations are fragile to import-line edits.** Deleting the 13 import lines
  shifted five `Syntax/Formula.lean:NNN` citations and one `DerivedAxioms.lean:NNN` citation onto
  blank lines. They were corrected by decrement; the check's own advice — cite the declaration
  name instead — remains unactioned and would make them edit-proof.

## References

- `specs/633_upward_edges_by_relocation/plans/01_upward-edges-relocation.md`
- `specs/633_upward_edges_by_relocation/reports/01_upward-edges-relocation.md`
- `specs/633_upward_edges_by_relocation/handoffs/phase-1-handoff-20260920.md`
- `docs/development/PUBLICATION_REFACTOR.md` — the programme this advances (Phase 4)
- `ORGANISATION.md`, `docs/ARCHITECTURE.md` — the rewritten layer documentation
- Commits: `7e5fd0fd8` (phase 1), `9c0c9c804` (phase 3), `69e4eba15` (phase 4),
  `b13f37e8e` (phase 2), `06d25980a` (phase 5), `709e58a70` (phase 6)
