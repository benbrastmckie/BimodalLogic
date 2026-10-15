# Phase 2 handoff — `thm:nomic-uniform` and the cut remark's side lemma

- **Next action**: Phase 3 — `FormalSystem/NomicLanguage/` component (Formula.lean, aggregator,
  README, `LANGUAGE_FILE_LAYERS` rows, `mk_all`). Files already written on disk but unbuilt:
  `FormalSystem/NomicLanguage/Formula.lean`, `FormalSystem/NomicLanguage.lean`,
  `FormalSystem/NomicLanguage/README.md`, plus Phase 4's `NomicTruth.lean` and Phase 5's
  `NomicTenseFree.lean` (written ahead, not yet compiled).
- **State**: `FormalSystem/Semantics/Nomic/Uniformity.lean` compiles green, zero sorry.
  `lake-build-guard.sh build -- build FormalSystem.Semantics.Nomic` exit 0.
  `lean_verify` confirms `transAt_of_pointUniform` at `[propext]` and `uniform_of_transAt` at
  `[propext, Classical.choice, Quot.sound]`. `readme-lint.sh FormalSystem` exit 0.
- **Decisions**: conditions (1)-(3) are stated at a single time, with all three worlds restricted
  to `H_F`, the existential reading; (4) quantifies only over occupied states, which is what makes
  `_of_pointUniform` choice-free.
- **Deviations**: none.
- **Known transient**: C12 is red from the Phase 1 record rows naming files Phases 3-7 create;
  self-resolving at Phase 7.
