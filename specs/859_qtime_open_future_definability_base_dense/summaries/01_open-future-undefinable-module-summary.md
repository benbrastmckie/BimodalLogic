# Implementation Summary: Task #859

- **Task**: 859 - Land the open-future NON-definability result as a library module
- **Status**: [COMPLETED]
- **Started**: 2026-11-04T23:45:00Z
- **Completed**: 2026-11-05T00:10:00Z
- **Effort**: ~0.5 hours
- **Dependencies**: `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` (the companion elimination module, landed; owns `PastDet`, `FutDet`, `OfutP`, `OpastP`, `ofutP_iff`)
- **Artifacts**: plans/01_open-future-undefinable-module.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The open-future non-definability result moved out of a disposable task directory and into the
library as `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean`, beside its two direct
analogues `StabUndefinable.lean` and `DeterminismUndefinable.lean`. The 419-line research probe
was re-expressed as 515 lines of namespaced, fully documented library code against the companion
module's imported determinedness vocabulary, and the result was recorded on five surfaces: the
`Independence` aggregator, that directory's README, `docs/theorem-index.md`, the C14 axiom
baseline, and the generated inventory and count blocks. All five phases completed; all five
landed prose surfaces state the result in its conditional form.

## What Changed

- `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` — **new module**, 515 lines,
  33 declarations, every one documented, sorry-free, no `axiom` declaration, no vacuous body.
  - `ofut_pastDet`, `opast_futDet` — `▷ψ` depends only on the past and `◁ψ` only on the future,
    for **every** `OpenFormula` `ψ` (not an embedded `ofPlus φ`): the constraint that confines any
    separator for `▷` to the past side.
  - `namespace MarkerGadget` (21 declarations) — `dataAtom`, `markerAtom`, `holds`, `holds_iff`
    (`@[simp]`, kept), the five gadget formulas `theta`/`nu`/`runAt`/`delta`/`probe`, `MarkedAt`,
    `theta_iff`, `theta_eq_iff` (the point of evaluation is a definable singleton), `nu_iff_le`
    (the closed past is a definable region), `PRun`, `run_iff` (backward-run membership definable
    without naming the run's lower endpoint), `DeltaProp`, `delta_iff`, `deltaProp_pastDet`,
    `dofut_probe_iff` and `ofut_neg_probe_iff` (`▷` computes `DeltaProp` exactly), and
    `deltaProp_of_no_p_between` (the non-vacuity witness).
  - `OfutPlusDefinable` — the **truth**-level L⁺-definability notion, with its docstring recording
    that the companion module's `openTruthAt_iff_tr` is the positive instance of exactly this
    notion and that nothing here refutes a validity-level-only translation.
  - `ofut_not_plusDefinable_of_deltaProp_inexpressible` — the conditional reduction theorem, whose
    docstring names `hmarkers` as an enough-worlds condition *stated* rather than compiled and
    `hinexpr` as the paper step of record, not formalized in this tree.
  - `section WitnessFrame` (8 declarations) — `MarkerColour`, `cRel` and its four `colourClock`
    inputs, `colourFibre`, and the `colourFibre_isRegular` instance, with the *Limit* obstruction
    fact in its docstring.
- `FormalSystem/Metalogic/Independence.lean` — the import line; `Thirteen` → `Fourteen` in the
  count sentence; the fourteenth numbered result; one `## Contents` bullet.
- `FormalSystem.lean` — regenerated with C33's own render algorithm (720 → 721 import lines).
- `scripts/check-module-invariants.sh` — eleven measured lines appended to `C14BASE` and eleven
  matching `#print axioms` lines to `C14LEAN`, both immediately after their own
  `...Expressiveness.ofutP_of_futDet` line, plus a comment block recording what they do **not**
  assert.
- `docs/theorem-index.md` — two rows in `### Characterization and definability` after the
  `stabNotDefinable` row, both conditional, plus a lead note above the table.
- `FormalSystem/Metalogic/Independence/README.md` — the fourteenth numbered result, seven Key
  Results bullets, the extended `Imports from` bullet, both `Last verified` dates, the generated
  `## Modules` row and its hand-written description cell. The `BehSeparatedness.lean` paragraph
  was corrected: it had asserted that file is "not a *fourteenth* numbered result" and that "the
  *thirteen* above" are underivability results, both of which go stale when a fourteenth lands.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — generated inventory
  blocks only, rewritten by `--emit-inventory`.
- `typst/generated/status.typ` — regenerated counts (721 files / 378,570 lines).

## Decisions

- `ofut_neg_probe_iff` routes through the companion module's `ofutP_iff` rather than re-proving
  the `openTruthAt_ofPlus` unfolding inline — the plan's preferred form, which closed on the first
  attempt, so the recorded fallback (keep the probe's proof verbatim) was never needed.
- The `MarkerGadget` nested namespace and the `pAtom`/`mAtom` → `dataAtom`/`markerAtom` and
  `Colour` → `MarkerColour` renames were applied as the plan specified; C23's three naming
  assertions all PASS and `grep` confirmed no prior occupant of any of those names under
  `FormalSystem/`.
- A `## Contents` bullet was added to the aggregator docstring beyond the plan's two named
  docstring edits: that list carried 28 bullets against 29 imports before this task, so omitting
  one would have widened an existing gap.
- The generated `## Modules` row's trailing description cell was filled in by hand. That column is
  documented in the invariants script as hand-written and preserved verbatim across regeneration;
  the generator only seeds a new file's cell with a TODO placeholder, and every sibling row in the
  table carries real prose.

## Plan Deviations

- **Phase 4's `scripts/typst-sync-check.sh --fix` step** altered: it ran in **Phase 1**, not
  Phase 4. The `typst-sync-check` pre-commit gate refused Phase 1's commit (reporting a partial
  commit, V8) because the new module changed `formalsystem-line-count` the moment it landed, so
  the regeneration had to precede the first commit. Annotated inline on the plan item.
- **Phase 4's `--emit-inventory` step** altered: it rewrote **four** markdown files, not the two
  the plan's file list named. `FormalSystem/README.md` carries the `../FormalSystem.lean` line
  count and the repository-root `README.md` carries the live file/line/comment totals, both
  generated inventory blocks that any new module under `FormalSystem/` changes. All four diffs are
  attributable solely to this module, and INV had flagged all four as stale. Annotated inline.
- Two Scope Hypothesis miscounts, recorded in `issues.jsonl` and costing nothing because the
  load-bearing checks were re-derived by running the commands: Phase 1 predicted 31 declarations
  (33 landed, matching the plan's own transcription lists), and Phase 3 said the
  `### Characterization and definability` table carried 17 rows (it carries 21; the real check,
  C15's row total rising by exactly two, passed at 325 → 327).

## Verification

- Build: **Success**. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  unscoped, exit 0, 2,897 jobs, 0 errors, 0 warnings. All three evidence tiers green: the guard's
  own exit code, the success line with a zero `error:` count over both streams, and an
  `.olean`-newer-than-source check on `OpenFutureUndefinable`, `Independence` and
  `FormalSystem`.
- Sorry count: **0** (C3: structural sorry inventory ZERO across `FormalSystem/`; `grep` on the
  new module returns nothing).
- Vacuous count: **0**.
- Axiom count: **0** new `axiom` declarations. All eleven pinned declarations re-measured against
  the built library and matching the Phase 2 baseline exactly, with **zero `sorryAx`**:
  `[propext]` for `ofut_pastDet`, `opast_futDet` and `MarkerGadget.deltaProp_pastDet`;
  `[propext, Classical.choice, Quot.sound]` for `theta_eq_iff`, `nu_iff_le`, `run_iff`,
  `delta_iff`, `dofut_probe_iff`, `ofut_neg_probe_iff`,
  `ofut_not_plusDefinable_of_deltaProp_inexpressible` and `colourFibre_isRegular`. The nine the
  research round had measured agree exactly; the two new measurements
  (`deltaProp_pastDet`, `colourFibre_isRegular`) had nothing to compare against. **No
  divergence.**
- Tests: **N/A** — no test suite covers these surfaces. **Scoped verification tier, with the
  batch-stage full gate deferred**: this dispatch is one `implement` phase inside a multi-task
  /orchestrate batch, and the plan's final phase declares `**Verification Tier**: full`. Neither
  `run-all.sh --only` nor `verify-deploy.sh --only-gate` covers any file this task modified —
  those suites test the agent harness under `.claude/**` and this task touched zero such path, and
  this repository carries no `agent-system/` source store. The scoped set that does cover these
  files is the repository Lean/ledger gate set, run in full below. The complete gate set runs once
  for the whole batch at the end of the invocation; it is **deferred here, not forgiven**.
- `bash scripts/check-module-invariants.sh`: INV, C2, C3, C4, C5, C9, C9D, C12, C13, **both C14
  halves**, **both C15 assertions** (327 theorem-index rows, exactly two more than before), C20,
  C21, **all three C23 assertions**, C24 and C33 all PASS. C17's gated count unchanged at
  905/15,870 — the new module contributed zero dead declarations. The script's nonzero exit is a
  single **pre-existing** C16 `unusedArguments` finding on
  `mem_cellAt_of_shift_of_hasForwardSlack` in
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`, last touched by an unrelated
  earlier commit; the C16 finding block is byte-identical to the pre-task reading. **No new
  simpNF finding on `holds_iff`**, so the attribute/docstring swap the plan recorded as a
  contingency was not triggered and the `@[simp]` stays.
- `bash scripts/check-metalogic-cycles.sh`: **exit 0** on all three assertions — exactly one
  directory-level cycle in `FormalSystem/Metalogic/`, the upward import set still exactly the
  recorded 8 lines, and no syntax module importing a semantics module. The allowlist file was
  **not edited** (`git status` shows it unmodified). The new `Independence` → `Expressiveness`
  edge is unreciprocated and the `Metalogic` → `Semantics.Frames.TranslationProduct` edge is
  downward, so neither is an upward edge.
- `bash scripts/check-copyright-headers.sh`: exit 0 — 721 conforming, 0 nonconforming.
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: exit 0 (a second run would
  change no byte).
- `bash scripts/typst-sync-check.sh`: exit 0, all four checks green.
- `bash scripts/readme-lint.sh FormalSystem`: exit 0 (RESULT: PASS).
- `bash .claude/scripts/validate-artifact.sh <plan> plan`: PASS, 0 warnings.
- Files verified: **Yes**. `git diff --name-only` over this task's four commits shows exactly the
  eight intended paths plus the two extra generated READMEs, and **nothing** under
  `FormalSystem/Metalogic/Expressiveness/`, nothing in `scripts/check-metalogic-cycles.sh`, and
  nothing under `specs/evidence/`. No foreign hunk appeared in any shared path: sibling task 559's
  only commit on this tree landed before this task's first.
- **Overclaim read-through: passes.** Every landed prose surface — the module docstring, the
  aggregator's numbered entry and `## Contents` bullet, the README's numbered entry, Key Results
  bullets and inventory description, the two theorem-index rows and their lead note, and the
  invariants-script comment block — states the result conditionally, names `hinexpr` as
  unformalized wherever the verdict appears, describes `hmarkers` as stated rather than compiled,
  makes no completeness or decidability claim for L^▷ or L⁺, and claims no refutation of a
  validity-level-only translation. No pinned row or generated cell states the unconditional
  `.Base`/`.Dense` verdict as machine-checked.
- The two fourteen-result enumerations agree: `Independence.lean`'s docstring and
  `Independence/README.md` both run 1–14 in the same order, and both count sentences read
  `Fourteen`.
- No landed file cites a `specs/` path or a task number: C9 and C9D both PASS, and no added line
  in any diff contains either.

## Impacts

- The research round's durable content now lives in the library rather than in a task directory,
  which was the point of the task: the report and probe under
  `specs/859_qtime_open_future_definability_base_dense/` are safely disposable, and the verdict
  survives `/todo` archival.
- `Independence/` carries its fourteenth result, and the open-modal neighbourhood of the C14
  baseline now has both halves — the elimination layer's eight lines and this module's eleven.
- This is the library's **first** `Metalogic` → `OpenLanguage` reach (transitively, through the
  companion elimination module). The cycles check confirms it is legal, and the recorded 8-line
  upward-import allowlist needed no change.
- `ofut_not_plusDefinable_of_deltaProp_inexpressible` is stated at an arbitrary `F : TaskFrame`
  with no `[F.IsRegular]` binder, so it is reusable at any frame satisfying the two hypotheses,
  not only at the witness frame.

## Follow-ups

- **Formalizing `hinexpr`** (report F5/R3) remains out of scope and open. It is a multi-phase task
  comparable to formalizing Gabbay's eight eliminations; the prior-cycle decision on record
  accepted the paper step, and the current task description reaffirms it. Until it is discharged,
  the unconditional `.Base`/`.Dense` verdict is cited prose, not machine-checked, on every surface
  this task touched.
- **The `colourClock` history bridge lemma** (report R4) would turn `hmarkers` from a hypothesis
  into an applied lemma at `colourFibre D`, shrinking this module's assumption surface. It is the
  related, non-blocking task and nothing here depends on it or blocks it.
- No bridge is proved between `OfutPlusDefinable` and the companion module's
  `openTruthAt_iff_tr`; the relationship is a docstring cross-reference only, as planned.
- The pre-existing C16 `unusedArguments` finding in `RaySummary/LadderChain.lean` is still open
  and belongs to whoever owns that module.

## References

- `specs/859_qtime_open_future_definability_base_dense/plans/01_open-future-undefinable-module.md`
  — the five-phase plan, with its `## Lean Challenge Statements` signature block.
- `specs/859_qtime_open_future_definability_base_dense/reports/01_qtime-open-future-definability.md`
  — the research report carrying F1–F6, D1–D7 and the `hinexpr` collapse argument.
- `specs/859_qtime_open_future_definability_base_dense/probes/01_ofut-marker-gadget-and-nondefinability.lean`
  — the 419-line compiled-live probe this module transcribes.
- `specs/859_qtime_open_future_definability_base_dense/handoffs/` — the five per-phase handoffs.
- `specs/859_qtime_open_future_definability_base_dense/issues.jsonl` — four recorded entries: one
  win (first-attempt green transcription) and three issues (the typst gate collision, and two
  Scope Hypothesis miscounts).
