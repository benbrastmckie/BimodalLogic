# Phase 2 handoff — task 425

**Next action**: Phase 3 — append report §3 Layers 2 and 3 (`archWitness`, `nextDepth`,
`witIdx`, their two index lemmas, and the ℤ layer `zHistory`/`zModel`/`zHistory_total`/
`zTruth_atom`/`succ_iterate_zero_int`) to `FormalSystem/Metalogic/DiscreteNonCompactness.lean`.

**State**: `FormalSystem/Metalogic/DiscreteNonCompactness.lean` created with the standard
copyright header, `import FormalSystem.Metalogic.StrongCompleteness`, module docstring (witness
in prose + the promotion note for the two truth lemmas), namespace `FormalSystem.Metalogic`,
the shared `variable` block, and `truthAt_next_iff` / `truthAt_next_iterate` transcribed verbatim
from report §3 Layer 1. Neither is `@[simp]`. Registered in `FormalSystem/Metalogic.lean`.

**Verification**: `lake build FormalSystem.Metalogic.DiscreteNonCompactness` green with zero
warnings from the new file; `lake build FormalSystem.Metalogic` green (2431 jobs).
`#print axioms` on both lemmas: `[propext, Classical.choice, Quot.sound]`.

**Deviations**: none.
