# Phase 3 handoff — the Prior-U refutation in the arc model

- **State**: `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` builds green, zero sorries.
- **Landed**: `arcRadius` (= `√2/4`) with `arcRadius_pos`, `arcRadius_lt_half`,
  `quarter_lt_arcRadius`, `arcRadius_irrational`, `rat_ne_arcRadius`; `OnArc`, `clockModel`,
  `ArcTime`, `clock_atom_truth`, `arcTime_of_abs_lt`, `not_arcTime_of_mem_gap`,
  `not_arcTime_half`; local connective lemmas `truth_top`, `truth_and_iff`, `truth_or_iff`;
  `priorUGapFormula` + `priorUGapFormula_isAxiom`; the three membership facts
  (`untl_top_atom_true`, `someFuture_neg_atom_true`, `priorUGap_consequent_false`) and the
  refutation `priorUGapFormula_false`.
- **Confirmed scope hypothesis**: `Axiom.prior_U_gap`'s formula was transcribed verbatim and the
  transcription is checked by `priorUGapFormula_isAxiom : Axiom (priorUGapFormula φ)` elaborating
  at `Axiom.prior_U_gap φ`. Three membership facts sufficed, as the plan asserted. No deviation.
- **Gotchas for successors**: `le_or_lt` and `Irrational.div_nat` do not exist in this Mathlib —
  use `le_or_gt` and `Irrational.div_natCast`. `exact_mod_cast` will not bridge a bare real
  numeral against a rational hypothesis; write the bound as `((q : ℚ) : ℝ)` and `push_cast`.
  `Formula.and` / `Formula.or` / `Formula.top` have no truth characterizations in
  `Semantics/Truth.lean`; the three needed are proved locally in this file.
- **Next action**: Phase 4 — statement S1 plus the aggregator and the `Metalogic.lean` import.
