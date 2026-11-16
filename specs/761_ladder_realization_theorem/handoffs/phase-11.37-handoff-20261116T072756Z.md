# Phase 11.37 handoff (plan v24) — the step system promoted

- **State**: Phase 11.37 [COMPLETED]. `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` (727 lines, imports `LadderRealize` alone) carries `Zrel`, `Zrel.succ`, `Zrel.pred`, `exists_linked_path`, `truth_iff_of_lnk`, `cellAt_eq_of_Zrel` and supports. Full build, BimodalTest, 64/64 probes, module invariants, README lint, typst sync all green.
- **NAMES**: the library's naming gate forced `Zrel_succ` -> `Zrel.succ`, `Zrel_pred` -> `Zrel.pred` (and `Zrel.refl/.symm/.mono`, `Lnk.symm/.mono/.zero/.succ/.pred`). Phases 11.38-11.40 and any Goals-block grep must use the dotted names in the library; the probe keeps the underscored ones.
- **Not promoted**: `Zrel_of_kappa_eq` (the kappa bridge) and all `*_stepFrag` corollaries remain in the probe. Phase 11.38 may need the bridge in the library; it was outside this phase's list.
- **Owed, unchanged**: thresholds `2 * (dBack + dFwd) <= Tc, Tn` are hypotheses, discharged nowhere.
- **Immediate next action**: Phase 11.38 (jump clauses' statement layer) or Phase 11.33 (time-boxed gate, which unblocks 11.34/11.35).
