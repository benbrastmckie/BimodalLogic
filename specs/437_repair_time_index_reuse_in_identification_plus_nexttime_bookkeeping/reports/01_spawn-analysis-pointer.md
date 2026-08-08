# Research Pointer: Spawn Analysis

This task was spawned from task 436 (`fourth_termination_measure_component`) to attack the
missing fourth termination-measure component from the identification-plus-maxTime side rather
than the measure side.

**Primary research artifact**:
`specs/436_fourth_termination_measure_component/reports/02_spawn-analysis.md`

That report contains the root-cause analysis (what `Branch.identifyTime` /
`Branch.nextTime` do to `maxTime` that breaks every measure-side candidate), the check
against all 17 entries of the do-not-re-attempt register in `MintBound.lean` section C9,
and the rationale for this task's refute-first shape.

**Supporting context from the parent task**:

- `specs/436_fourth_termination_measure_component/reports/01_fourth-measure-component.md` —
  the original fourth-measure-component research.
- `specs/436_fourth_termination_measure_component/plans/01_self-guard-potential.md` — the
  predecessor plan whose refute-first gate shape this task is asked to mirror.
- `specs/436_fourth_termination_measure_component/summaries/01_self-guard-potential-summary.md` —
  the machine-checked negative result (`selfGuardPotential` refuted; register entry 17 landed).

**Ground truth in source**:
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` section C9
(the 17-entry register) must be read in full before any route is attempted.
