# Phase 11.36 handoff (plan v24) — the (K4) dead-conjunct deletion trial

- **State**: Phase 11.36 [COMPLETED]. Outcome (a): library and BimodalTest build exit 0 with (K4)'s two depth conjuncts deleted. One wired probe declaration fails under the deletion (`Probe836A.not_paramsOkK4_two`), a statement about the predicate, not a consumer. Trial reverted; `CounterQuotient.lean` / `LadderWindow.lean` identical to HEAD; restoration build exit 0.
- **Record**: `records/round-24-k4-deletion-trial.md`.
- **Deviation**: the producer `paramsOk_params` was trimmed for the trial as well as the positional projection.
- **Immediate next action**: Phase 11.37 (promote the step system) or Phase 11.33 (time-boxed gate); Phase 11.35 is still gated on 11.33.
- **For Phase 11.35**: the repaired two-conjunct (K4) moves `LadderWindow.lean:1835` to `hp.2.2.2.2`; `Bof` must grow (`Probe836A.Bof_chiD = 9 < 10`); follow `not_paramsOkK4_two`, `Bof_chiD`, `kappa_D_dissolves` in `ladder-cell-obligation-refutation.lean`.
