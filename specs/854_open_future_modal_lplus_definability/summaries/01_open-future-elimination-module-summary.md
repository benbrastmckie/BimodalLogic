# Implementation Summary: Task #854

- **Task**: 854 - Land the positive open-future elimination result as a library module
- **Status**: [COMPLETED]
- **Started**: 2026-11-04T00:00:00Z
- **Completed**: 2026-11-04T01:30:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_open-future-elimination-module.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The settled research verdict — the open-future modal `▷` and the open-past modal `◁` are
L⁺-definable at `.ZTime` and `.RTime`, by Gabbay separation plus the elimination of a disjunction
under the modal — now lives in the library rather than in a disposable task directory. The
machine-checked half of that verdict was transcribed from the task's probe into a new module,
`FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`, as public documented library
code, and recorded on the four ledger surfaces a new module owes. The result is landed
**conditional on `SeparationOver`**, an explicit named hypothesis standing for cited literature
this tree does not formalize; every pinned row states that conditional, and the unconditional
verdict appears only as cited docstring prose.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` — new module, 413 lines, 28
  declarations, every one documented. Defines the determinedness predicates `PastDet` / `FutDet`
  (semantic, not syntactic) with the bridges `pastDet_of_isPurePast` / `futDet_of_isPureFuture`;
  the L⁺-level readings `OfutP` / `OpastP` with their `OpenTruthAt` bridges and their
  conjunction/`⊤` lemmas; the eliminations `ofutP_or_iff` (`▷(α ∨ β) ↔ α ∨ ⊡β`) and
  `opastP_or_iff` (`◁(α ∨ β) ↔ ⊡α ∨ β`); the separated-CNF constructors `sepForm`, `ofutElim`,
  `opastElim`, `SepClauses` and the CNF eliminations `ofutP_sepForm_iff` / `opastP_sepForm_iff`;
  the named hypothesis `SeparationOver`; the translation `tr` with `openTruthAt_iff_tr`,
  `openValidOnFrames_iff_tr`, `openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr`; and the two
  split-free ends `ofutP_of_pastDet` / `ofutP_of_futDet`.
- `FormalSystem/Metalogic/Expressiveness.lean` — the module's import line, an Architecture entry
  and a Main Exports paragraph stating the conditionality explicitly.
- `FormalSystem.lean` — regenerated library root (one import line per `.lean` file; C33).
- `FormalSystem/Metalogic/Expressiveness/README.md` — module-table row with its measured line
  count, a re-derived content-count sentence, a Key Results bullet naming the shared vocabulary
  this module owns, an Architecture-tree entry, and a refreshed `Last verified` date.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — generated inventory
  blocks, rewritten by `--emit-inventory`, never hand-edited.
- `docs/theorem-index.md` — six rows in the `### Expressiveness` table plus a lead paragraph.
- `scripts/check-module-invariants.sh` — eight matched C14 baseline pairs appended to both
  heredocs in the same relative position, plus a comment block recording what they do not assert.
- `typst/generated/status.typ` — regenerated file/line counts (`typst-sync-check.sh --fix`).

## Decisions

- **`PastDet`/`FutDet` stay semantic.** A syntactic version on `IsPurePast`/`IsPureFuture` would
  not serve the `.RTime` instantiation at all, because the Dedekind-complete separated forms are
  future-determined without being syntactically pure. The module docstring records the reason.
- **The `[F.IsRegular]` binder was dropped from `ofutP_of_pastDet`.** Its proof uses only
  `agreeUpTo_equivalence` and `PastDet`, so the binder was an unused argument and a gated C16
  candidate. Removing an unused hypothesis strengthens the theorem; every other regularity binder
  (the four elimination lemmas, `openTruthAt_iff_tr`, `ofutP_of_futDet`) is retained, because each
  routes through `paste`.
- **Two `show` tactics became `change`.** `linter.style.show` flags a `show` that changes the
  goal; the standalone probe never surfaced it. The tactic is goal-equivalent, so the proof is
  unchanged, and the module now builds at zero warnings.
- **The unconditional verdict is docstring prose only.** No pinned row, generated cell or README
  bullet asserts that the restricted modals are L⁺-definable full stop; each states its
  hypothesis, and every surface records that `SeparationOver` is unformalized here and false over
  `ℚ`.

## Plan Deviations

- **Phase 1, aggregator-import step** altered: two changed paths beyond the plan's six. A new
  `.lean` file under `FormalSystem/` forces regeneration of the generated library root
  `FormalSystem.lean` (check C33 asserts it is byte-for-byte the `mk_all --lib FormalSystem`
  output) and of `typst/generated/status.typ`'s file and line counts (enforced by the pre-commit
  `typst-sync-check.sh` gate, which refused the Phase 1 commit until the counts were refreshed).
  Both were produced by their own generators, not hand-edited, and both are additive mechanical
  consequences of landing a module rather than substitutions of plan approach.
  `typst/generated/status.typ` was already inside the task's declared `file_scope`;
  `FormalSystem.lean` was not, so its commit was scoped without `--task`.
- **Phase 4, inventory regeneration** altered: `--emit-inventory` rewrote three files
  (`FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md`), not the one the
  plan anticipated. All three are in the declared `file_scope`.
- **Phase 5, verification tier** altered: the declared `full` tier was discharged against a
  scoped tier under the dispatch's batch-gate deferral, recorded in the phase's own verification
  notes. The named harness narrowing invocations were inapplicable — this repository carries no
  `agent-system/` source store and every modified file is project-domain — so the scoped tier
  actually run was the repository Lean/ledger gate set in full.

## Verification

- Build: **Success** — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (unscoped, guarded, detached with the bounded single-call waiter), guard exit 0, 2896 jobs, 0
  errors, 0 warnings; `.olean` newer than source for both touched modules.
- Sorry count: **0** (C3 PASS: structural sorry inventory ZERO across `FormalSystem/`).
- Vacuous count: **0** (no `:= True` / `:= Unit` / `:= trivial` body in the new module).
- Axiom count: **0 new axioms** (no `axiom` declaration in the new module).
- Axiom profiles, measured twice and identical both times, matching the report's F2 reading with
  no divergence and no `sorryAx`: `[propext, Classical.choice, Quot.sound]` for `ofutP_or_iff`,
  `opastP_or_iff`, `ofutP_sepForm_iff`, `opastP_sepForm_iff`, `openTruthAt_iff_tr`,
  `openValidIn_ztime_iff_tr` and `openValidIn_rtime_iff_tr`; `[propext, Quot.sound]` for
  `ofutP_of_futDet`.
- `scripts/check-module-invariants.sh`, asserted per-check: INV, C2, C3, C4, C5, C9, C9D, C12,
  C13, both C14 halves, both C15 assertions (325 theorem-index rows, exactly six more than the
  pre-task 319), C21, C24 and C33 all **PASS**. The script exits 1 solely on the single
  pre-existing C16 `unusedArguments` finding
  (`mem_cellAt_of_shift_of_hasForwardSlack`); the finding list is byte-identical to the pre-task
  baseline, so this task introduced no new finding.
- `scripts/check-metalogic-cycles.sh`: **exit 0**, upward import set unchanged at exactly the
  recorded 8 lines, allowlist file untouched — the new import is the expected downward edge.
- `scripts/check-copyright-headers.sh`: 720 conforming, 0 nonconforming.
- `scripts/readme-lint.sh FormalSystem`: **RESULT PASS**, exit 0.
- `scripts/check-module-invariants.sh --emit-inventory --check`: **exit 0** (idempotent).
- `.claude/scripts/validate-artifact.sh <plan> plan`: PASS, 0 warnings.
- Overclaim read-through: passed on all surfaces. No landed file cites a `specs/` path or a task
  number (C9 and C9D both PASS at zero), nothing under `FormalSystem/Metalogic/Independence/`
  changed, and `scripts/check-metalogic-cycles.sh` is untouched.
- Files verified: Yes.

## Impacts

- `PastDet`, `FutDet`, `OfutP` and `OpastP` are now public, documented and resolvable as
  `FormalSystem.Metalogic.Expressiveness.*`. The companion non-definability work imports this
  shared vocabulary from here instead of redefining it, which is the dependency edge that made
  this task come first.
- The elimination machinery and the two validity transfers are pinned by C14 on every invariants
  run, so their axiom profiles are asserted rather than claimed in prose.
- The research report and probe under this task directory are now safely disposable: their
  durable content lives in the module, its docstring and the ledger.

## Follow-ups

- The `Expressiveness/` README's hand-written per-subdirectory file and line figures were already
  stale before this task (EFGames listed 8 files against 11 live, Kamp 116 against 115), which is
  why the content-count sentence read 141 against a live 144. The sentence was re-derived rather
  than incremented, and the table's staleness is now stated in the README beside it; refreshing
  the individual cells is a separate concern and was left out of scope.
- Discharging `SeparationOver` by formalizing Gabbay separation (GHR Lemmas 10.2.1-10.2.8) is the
  route that would convert every conditional row here into an unconditional one. It is a separate,
  sizeable piece of work and is promised nowhere.

## References

- `specs/854_open_future_modal_lplus_definability/plans/01_open-future-elimination-module.md`
- `specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md`
- `specs/854_open_future_modal_lplus_definability/probes/01_ofut-elimination-and-translation.lean`
- `specs/854_open_future_modal_lplus_definability/handoffs/phase-5-handoff-20261104T000000Z.md`
