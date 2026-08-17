# Phase 4 and 5 handoff — statements S1 and S2

- **State**: `lake build` full-tree green after Phase 4 wiring; `CoNotPriorU` green after Phase 5.
  Zero sorries in `FormalSystem/Metalogic/Independence/`.
- **Phase 4 landed**: `co_not_derives_prior_U_gap` (S1), the aggregator
  `FormalSystem/Metalogic/Independence.lean`, and one import line in `FormalSystem/Metalogic.lean`.
  Scope hypothesis confirmed: one aggregator plus one import line, no lakefile change
  (`lakefile.lean` has `roots := #[FormalSystem]` and enumerates no modules).
- **Phase 5 landed**: `cneg`/`cneg_cneg`, `onArc_neg`, `states_congr`, `clockRel_neg`,
  `reflect_respects`, `reflect`, `reflect_isTotal`, `truthAt_mirror` (the mirror lemma),
  `truthAt_swapTemporal`, `CoDerivation`, `coDerivation_sound`, and
  `co_not_derives_prior_U_gap_schema` (S2).
- **Scope hypothesis (Phase 5) confirmed**: `DerivationTree` has seven constructors — `axiom`,
  `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`,
  `weakening`. `CoDerivation` mirrors all five that the empty-context schema form admits, plus a
  `co` constructor; `assumption` and `weakening` are the two context rules deliberately omitted.
  `temporal_duality` was **not** dropped. No deviation.
- **Axiom check**: `lean_verify` on both S1 and S2 reports exactly
  `propext`, `Classical.choice`, `Quot.sound` — no `sorryAx`.
- **Gotcha**: the mirror lemma is stated *relationally* over a pair of histories tied by
  `σ(-x) = cneg (τ x)`, not through `reflect` alone. That is what makes the `□` case work in both
  directions without proving `reflect` involutive as an equality of structures.
- **Next action**: Phase 6 — correct the Layer 9 prose in `Axioms.lean` and the module docstring
  plus `co_derived` docstring in `DedekindDerived.lean`.
