# Compiled promotion blocks

Each file here was run verbatim through `lean_run_code` against the live library during the
research round and compiled with **zero errors** and axioms exactly
`[propext, Classical.choice, Quot.sound]`.

They are transplant sources, not modules: they re-open the library's own namespaces and carry no
`Paper:` docstring lines. The implementation must add those (C15 requires a `Paper:` line at every
declaration that gets a `docs/theorem-index.md` row) and must keep the tree warning-free, since
C28's budget is zero.

| File | Deliverable | Target |
|---|---|---|
| `GapA_TwoOrigins.lean` | Deliverable 1 — the two-origin cone-topology side | `FormalSystem/Semantics/StateTopology/Counterexamples.lean`, `TwoOrigins` namespace |
| `GapB_Hedgehog.lean` | Deliverable 2 — the named hedgehog inequality | same file, `Hedgehog` namespace |
| `FrameLevelAdditions.lean` | Recommendations 3 and 4 | `FormalSystem/Semantics/StateTopology.lean`, `FrameOver` and `TaskFrame` sections |
