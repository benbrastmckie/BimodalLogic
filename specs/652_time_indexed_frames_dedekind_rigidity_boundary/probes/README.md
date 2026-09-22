# Probes — time-indexed frames and the Dedekind rigidity boundary

Two `lean_run_code` probes, both compiled green against this tree (Lean v4.33.0-rc1,
Mathlib tag `v4.33.0-rc1`). They are scratch evidence for the research report, not library
modules; the planner sites the real module.

- `01_positive_theorem.lean` — the `TimeIndexed` structure, `Hist`, `Limit`,
  `ConstantHistories`, and the positive theorem `constant_of_lub`.
  Axioms: `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- `02_rat_witness.lean` — the two-state ℚ witness switching across `√2`: all four
  time-indexed frame conditions plus `¬ Static` and `¬ ConstantHistories`.

Style note carried into the report: the `show`-that-changes-the-goal linter and the
unused-simp-argument linter both fire on the draft bodies; under `lake build --wfail` those
are failures, so the module must use `change` and drop the unused `simp_all` argument.
