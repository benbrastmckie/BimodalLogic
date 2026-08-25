# Phase 3 handoff — task 425

**Next action**: Phase 4 — append report §3 Layer 4 (`archWitness_finitely_satisfiable`,
`archWitness_not_satisfiable`, `discrete_consequence_not_compact`) plus the Axiom Audit docstring
section to `FormalSystem/Metalogic/DiscreteNonCompactness.lean`.

**State**: Layers 2 and 3 appended verbatim from report §3. `archWitness`, `nextDepth` (guard-first
`untl` pattern), `witIdx`, `nextDepth_next_iterate`, `witIdx_neg_next_iterate`, `zHistory`,
`zModel`, `zHistory_total`, `zTruth_atom`, `succ_iterate_zero_int` all present. Both numeral
elaboration fixes applied exactly as recorded (ascribe the `ite` body to `Nat`; annotate the
`valuation` lambda binder). Docstrings added on `archWitness`, `nextDepth`, `witIdx` (including
the `Formula.complexity` non-usability note) and a section note on why `TaskFrame.natFrame` is
the right frame.

**Verification**: `lake build FormalSystem.Metalogic.DiscreteNonCompactness` green, zero warnings
attributed to the file, zero `sorry`. `nextDepth_next_iterate` compiling is itself the
argument-order spot-check — its `succ` case would not close if `nextDepth`'s `untl` pattern were
event-first.

**Note**: concurrent agents (tasks 472, 475) are editing other `FormalSystem/` files in the same
working tree; one transient `.olean`-missing build failure was observed and cleared on retry.
Staging is kept strictly scoped to this task's files.

**Deviations**: none.
