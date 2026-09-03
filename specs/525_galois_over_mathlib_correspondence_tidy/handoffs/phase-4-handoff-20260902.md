# Phase 4 handoff — task 525

**Status**: Phase 4 [COMPLETED]. Full `lake build` green (2521 jobs).

## Done
- `validOn_co_iff_isComplete`, `validOn_df_iff_isDiscrete`, `validOn_dn_iff_denselyOrdered`
  (⇒) branches rewritten over the Phase-3 realisation lemmas. 207 -> 165 lines (52/46/67).
- `private def corrAtom` deleted; its section comment rewritten to state the shared five-step
  shape. Atom idiom is `Atom.mkBase "p"` throughout, including `FwdRec.lean:88,97`.
- `grep -rn corrAtom FormalSystem/` and `grep -rn 'Atom.mk "p" none' FormalSystem/Semantics/Correspondence/`
  both return nothing.

## Parallelism evidence
All three (⇒) branches carry the same marker comments in the same order: "The realising data",
"Realisation", (antecedent), "Instantiate the schema at the witness frame, then read the
consequent back".

## Next action
Phase 2 (retarget `Indicator.lean` to `galoisClosed_of_indicator_iff`), then Phase 5
(delete `arch_of_lub`, three docstring repairs — run the `git status --short` territory check
first, task 524 is live in `Metalogic/`), then Phase 6 (READMEs + baselines).
