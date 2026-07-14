# Phase 10 negFix recursion core — SETTLED DESIGN (persist across dispatches)

Two dispatches were terminated by external API errors (session-limit, then timeout) AFTER
settling this design but BEFORE editing. Design is fixed; do NOT re-derive. Build incrementally,
commit each green sub-step, land at the first green Case boundary if time-constrained.

## Disjunct-list shape (Rabinovich chunk_0017), decomposing ¬bracket on (z0,z1) at the
## attained first-neg-β0 pin z* (first point where leading β0 fails):

- **Case 1** (n=1 base): via `negFixOne_iff` (10a, commit a928ccf3f).
- **Case 2** (no pin attained on the sub-interval): ANCHORED Cor 5.4 mirrors
  `negBoundedRightFixAnchored`/`negBoundedLeftFixAnchored` (10b-i, commit 054818233),
  consumer shape `¬∃ z ∈ (z0,z1), α(z) ∧ bf.holds`.
- **Case 3** (pin attained — A_i/B_i split): A_i = failure inside the β0-prefix region before
  the pin; B_i = prefix good up to pin, then recursive `negFix` of the tail on the suffix;
  glued by `concatPin` (10b-ii unit 1, commit 37e24dce2) + `conjFull` (Phase 7).
- **Boundary (d)/(e)**: degenerate pins at interval endpoints.

## Assembly: `negFix_iff` biconditional via constructor/rcases + classical case-split on pin
attainment (Classical.byCases + well-ordering for "first" pin), rewriting with `negFixOne_iff`,
`negBounded*FixAnchored_iff`, `concatPin_holds_iff`, `conjFull_holds_iff`.

## Constraints: EANegationFix.lean only (+ plan status edit). G6: no KampPrior/ExteriorPinnedConverse*.
Axioms exactly [propext, Classical.choice, Quot.sound]. Sorry-free or documented skeleton.
Suggested incremental landing seams: (1) the "first pin" well-ordering lemma; (2) Case-3 A_i/B_i
builders; (3) negFix recursion def; (4) negFix_iff. Commit after each.
