# Task 360 — Spawn Research Pointer

This task was spawned from task 358 (parent) when its Phase 3 hit a machine-grounded blocker:
the four exterior `hbr*` obligations are **semantically false as stated** (counterexample on
`P2M=(ℤ,<), P={0,10,20}`), because the 354→356→357→358 outward threading dropped the truth
antecedents their interior siblings kept.

**Grounding / full analysis** (read this first):
`specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/03_pinned-converse-adjudication.md`
(sections 2.3–2.4, 3.3, 6 — Rabinovich 2014 Cor 5.4(1)⇐/5.4(2), the `kvE_{fut,past}Pinned_of_end`
signature, and the C3/C8 machine probes).

**Mandate**: Make the four exterior obligations true-as-stated by carrying the igPtW-site and
`kvE_*End`-endpoint antecedents through the interface chain — preferably eliminating `hbr*Real`
by re-proving `kvE_extNeg{Fut,Past}_complete` from the destructor's currently-discarded
`hgap`/`hocc` facts via a new pinned fiber-realization converse. Keep every current consumer
green. Zero-debt: no sorries, no vacuous defs; escalate on any un-closable sub-piece.

**Note**: task 349 v8 Phase 6 inherits the same false-binder wall and should consume this task's
restated interface.
