# Implementation Summary: Task #911

- **Task**: 911 - Idle-cycle sharpening of the idle-gap lengthening route
- **Status**: [COMPLETED]
- **Started**: 2026-11-10T17:40:00Z
- **Completed**: 2026-11-10T18:36:00Z
- **Effort**: ~1 hour
- **Dependencies**: 909 (completed)
- **Artifacts**: plans/01_idle-cycle-sharpening.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The idle-gap lengthening schema is refuted outright, and this task lands the sharpening the
refutation's own docstring named as open: the premise under which the lengthening IS available,
stated explicitly as a run-local hypothesis, together with a determination of what it buys and
what it does not. All seven plan phases are complete. The three pump-layer sections landed in
`LadderPump.lean`; the register-anchored assembly, the sharpened schema with its theorem, and the
freed-increment form with its compiled refutation landed in the new leaf module `LadderIdle.lean`.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` — three new sections, a
  `longFile` baseline (`set_option linter.style.longFile 2000`), and two docstring paragraphs.
  1485 -> 1931 lines.
  - `IdleCycle`: `idleCycleLens` (the idle mirror of `objCycleLens`),
    `no_consecutive_idle_of_no_idle_step` (the refutation's generic mechanism, promoted out of
    the prototype), `idleCycleLens_of_idle_segment`, `exists_idleCycle_of_card_le_run`, and
    `idle_run_lt_tIdle_of_no_idleCycle` (the NECESSITY direction: without an idle cycle every
    idle run is shorter than `tIdle pend`).
  - `IdleSplice`: `idleSpliceCnt` with `idleSpliceCnt_of_lt`/`_of_ge`, the three local readings
    of `Count` (`idleSpliceCnt_idle`, `idleSpliceCnt_pend_pend`, `idleSpliceCnt_pend_idle`),
    the pin classification `idleSplice_pull`, the free pin clause `idleSplice_pins`, and the
    unanchored lift `exists_idleSpliced_ladderPath`.
  - `IdlePigeonhole`: `idleBudget` and `exists_idleTypeBlock_of_budget_le_run`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` — created, 860 lines.
  `exists_iterIdleSpliced_ladderPath` (the register-anchored `d`-fold idle pump);
  `IdleGapLengtheningOfIdleRunRepeat` and `idleGapLengtheningOfIdleRunRepeat_holds` (the
  sharpened schema and its theorem); `IdleGapLengtheningAllIncrements`, the witness namespace
  `IdleIncrementWitness` (the three-state object with five admitted edges, its two seriality
  proofs, the stab-free atomic closure, the period-5 witnessing walk and its lift, the parameter
  tuple with `paramsOkI`/`two_le_TcI`, and the parity lemma `idleRun_even`) and
  `idleGapLengtheningAllIncrements_refuted`; plus a `## What this buys` determination section in
  the module docstring and two closing `#print axioms` lines.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — the new import and its `## Modules`
  bullet.
- `FormalSystem.lean` — regenerated library root (`lake exe mk_all --lib FormalSystem`).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/README.md`, `README.md` — regenerated inventory blocks (the whole ancestor chain
  `--emit-inventory` rewrites).
- `scripts/debug-artifact-allowlist.txt` — one reasoned entry for `LadderIdle.lean`'s two
  `#print axioms` lines (gate C27's own sanctioned remedy).
- `typst/generated/status.typ` — regenerated count figures.

## Decisions

- **Binders are written out per declaration rather than taken from a `variable` block.** Lean 4
  includes a section instance binder whenever a variable its type mentions is used, so a
  `variable [Fintype Q]` would have added `[Fintype Q]` to `no_consecutive_idle_of_no_idle_step`,
  whose Challenge-pinned signature carries no such instance.
- **`idleSplice_pins` carries no endpoint-repeat hypothesis.** The pin classification needs only
  the block's idleness, so the landed lemma has strictly fewer hypotheses than planned. The pin
  clause is therefore FREE for an idle block, where the pending splice carries it as a genuine
  side condition.
- **The iterate's induction carries one clause more than its statement exposes** — the realized
  type at `a + k`, which is what forms the next step's own `hty`. Dropped at the end via a
  `suffices`, mirroring `exists_iterSpliced_ladderPath_of_pend_past`'s exposure discipline.
- **Three `set_option linter.unusedFintypeInType false in` / `linter.unusedVariables false in`
  scopings**, each with its reason in a comment above it: the signatures are pinned by the plan's
  Challenge block and the unread binder is the instance shape the whole idle layer carries.
- **Four of the sharpened schema's own internal hypotheses are not consumed by its proof** — the
  pending-forever past, `nxtAt g z + 2 ≤ cntAt g z`, `0 < I` and `0 < d`. They are kept because
  the schema is stated clause-for-clause against the refuted original; the theorem's docstring
  records that the construction is available more widely than the schema asks.

## Plan Deviations

- **Phase 1** altered: section opened as planned, but binders written per declaration instead of
  via a `variable` block (see Decisions; the Challenge signatures are the binding contract).
- **Phase 2** altered: one unplanned helper `idleSplice_pull` factors out the pin classification
  all three cases of `idleSplice_pins` read; and `idleSplice_pins` carries no endpoint-repeat
  hypothesis, so it is strictly stronger than planned.
- **Phase 4** altered: `check-metalogic-cycles.sh` Assertion B did NOT fire, so the conditional
  allowlist extension the phase provided for was not made and the script is untouched.
- **Phase 6** altered: the `Fintype QI` instance is hand-written
  (`⟨{pnd, idl0, idl1}, fun x => by cases x <;> decide⟩`) because `deriving Fintype` does not
  elaborate on this toolchain; and the planned position-by-position object chain in the
  refutation was replaced by the general parity lemma `idleRun_even`, which the plan's own task
  list names and which closes the refutation in one line.
- **Phase 7** altered: `scripts/debug-artifact-allowlist.txt` is edited, which the phase's file
  list did not anticipate. Gate C27 of `check-module-invariants.sh` rejects a live `#print` in
  library code unless the file carries a reasoned allowlist entry, and the plan's own task list
  calls for the `#print axioms` lines; the entry is that gate's sanctioned remedy.

## Verification

- **Build**: Success. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (full project) exits 0 with 0 errors and 0 warnings over 2973 jobs. `.olean` newer than source
  for both touched modules. CI builds with `--wfail`, so the zero-warning count is the gate.
- **Sorry count**: 0 (`lean-sorry-census.sh` over the four resolved source roots).
- **Vacuous count**: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`. Pre-existing, in
  an untouched file, and not a placeholder: the goal genuinely reduces to `True` for the
  integer-time history, so `trivial` is the real proof.
- **Axiom count**: 14 textual `^axiom ` matches, identical to the count at the pre-task commit
  `9425429d9`. Every match is the word "axiom" opening a docstring line; no `axiom` declaration
  was introduced.
- **Named declarations**: all fourteen of the plan's `## Lean Challenge Statements` are present
  under their pinned signatures (`lean-plan-compliance-check.sh`: `COMPLIANCE_CHECK: passed`),
  and `lean_verify` reports the standard axiom profile (`propext`, `Classical.choice`,
  `Quot.sound`; `no_consecutive_idle_of_no_idle_step` needs only `propext`) with no `sorryAx`.
- **Gate set** (the CI gate set in `.github/workflows/ci.yml`, run locally):
  - PASS: `lake exe mk_all --lib FormalSystem --check`;
    `check-module-invariants.sh --no-build` (ALL CHECKS PASSED);
    `check-module-invariants.sh --emit-inventory --check`;
    `check-copyright-headers.sh --strict` (0 findings); `readme-lint.sh`;
    `check-metalogic-cycles.sh` (all three assertions, Assertion B unchanged);
    `typst-sync-check.sh` (all 4 checks); `check-evidence-probes.sh` (52 wired probes compile).
  - PRE-EXISTING, outside this task's file scope, named explicitly:
    `lake exe lint-style` reports 4 findings, all in
    `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` (lines 383, 390, 413,
    420; "space before a semicolon"), a file this task never touched, last written by commit
    `31e1ddbc7`. `check-paper-definitions.sh` reports 9 drifted definitions between
    `docs/reference/paper-definitions-of-record.md` and a LaTeX source living outside this
    repository; nothing in this task's scope is involved.
  - Batch deferral: the dispatch declared the agent-system batch gate set
    (`.claude/scripts/tests/run-all.sh`, `verify-deploy.sh`) deferred to the batch stage. This
    task modified no path under `.claude/**`, so those suites have no scoped narrowing to run
    here; the repository's own CI gate set above was run in full instead rather than deferred.
- **Tests**: N/A (no test-library change; `check-evidence-probes.sh` covers the probe corpus).
- **Files verified**: Yes.

## Impacts

- The idle mirror of the pump layer is now library content rather than prototype content, and
  `no_consecutive_idle_of_no_idle_step` is available to any consumer that needs the generic
  "an idle run of length two needs an idle-to-idle edge" fact.
- `idleSplice_pins` records that the pin condition the pending splice carries as a side condition
  is FREE for an idle block — the clause the FAIL verdict predicted would merely loosen.
- `exists_idleTypeBlock_of_budget_le_run` makes the `(objAt, tpOf)` pigeonhole available over idle
  runs, which is what discharges the decision gate's untouched sub-question (ii).
- Nothing imports `LadderIdle.lean`, and nothing in it is a cell-level claim. The
  `ForwardSlackWitnessed` hypothesis of `cellAt_subset_of_shift_of_pend_past_rev` is not removed
  and the reserved unrestricted cell obligation stays reserved.

## Follow-ups

- The sharpened schema's four unconsumed internal hypotheses mean a strictly stronger schema is
  available (no pending-forever past, no gap condition, `I` and `d` free to be zero). Stating it
  was out of scope here, since the Challenge block pins the schema clause-for-clause against the
  refuted original.
- `deriving Fintype` does not elaborate on this toolchain for a plain enumeration inductive
  (recorded in `issues.jsonl`); a future object witness in this tree should expect to write the
  instance out.
- The two gate findings above are pre-existing and belong to other territory; they are named here
  so a later reader does not attribute them to this change.

## References

- `specs/911_idle_cycle_sharpening_idle_gap_lengthening/plans/01_idle-cycle-sharpening.md`
- `specs/911_idle_cycle_sharpening_idle_gap_lengthening/handoffs/` (one per phase, 1-6)
- `specs/911_idle_cycle_sharpening_idle_gap_lengthening/issues.jsonl`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` (module docstring's
  `## What this buys` section carries the three determinations)
