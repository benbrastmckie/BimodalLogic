# Phase 3 handoff — model/history transport and Aligned

**Next action**: Phase 4 — append `truthAt_map` (prototype lines 200-271), the induction on
`Formula` generalizing over both histories and the time.

**State**: `IntTransfer.lean` now carries `TaskModel.map`, `WorldHistory.map`, `structure
Aligned`, `aligned_map`, `isTotal_map`, `WorldHistory.comap`, `aligned_comap` — 7 declarations as
planned. `lake build FormalSystem.Semantics.IntTransfer` green. `grep HEq` returns nothing (the
forbidden `Equiv` route was not taken). No sorry, no axiom.

**Key decisions**: `Aligned` used as specified; `aligned_comap`'s transport discharged by the
tree's existing `WorldHistory.states_eq_of_time_eq`, no new transport lemma written.

**Deviations**: none. (Field docstrings added to `Aligned.dom`/`Aligned.st` beyond the
prototype — Lean's structure-field doc convention; no semantic change.)
