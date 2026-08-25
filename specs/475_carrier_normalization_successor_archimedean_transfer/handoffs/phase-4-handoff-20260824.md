# Phase 4 handoff — truthAt_map

**Next action**: Phase 5 — append `ValidInt` and `validDiscrete_iff_validInt` (prototype lines
278-290), then wire `FormalSystem/Semantics.lean` (one import + one Submodules bullet) and run
the full `lake build` plus `scripts/check-module-invariants.sh`.

**State**: `truthAt_map` landed in `IntTransfer.lean` with all six `Formula` cases — `atom`,
`bot`, `imp`, `box`, `untl`, `snce` — matching the constructor list at
`FormalSystem/Syntax/Formula.lean:78-106` exactly. Statement generalizes over both histories and
the time, as the plan requires. The `box` trap avoided: bare term `fun s => hρ' (e s)`, no
`simpa`. `lake build FormalSystem.Semantics.IntTransfer` green; `#print axioms
FormalSystem.Semantics.truthAt_map` = `[propext, Classical.choice, Quot.sound]`. No sorry, no
axiom.

**Deviations**: none.
