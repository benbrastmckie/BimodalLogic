# Implementation Summary: Phase 5 — forward_G and backward_H across the case matrix

- **Task**: 408 - faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Plan**: plans/02_strong-completeness-dedekind-v2.md (v2)
- **Phase**: 5 of 9 — "forward_G and backward_H across the rational/limit case matrix"
- **Outcome**: `[COMPLETED]`, sorry-free, full `lake build` green
- **Commit**: `d66bc9da0`

## Phases executed

Phase 5 only (single-phase dispatch). Phases 1-4 were already `[COMPLETED]`.

## What landed

`FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (new, 225 lines, 7 declarations,
sorry-free), plus one import line and one docstring line in `FormalSystem/Metalogic/Bundle.lean`.

The six named lemmas of the coherence matrix, each stated about `limitSetBelow` on both sides and
each taking the rational family's coherence field as an **explicit hypothesis**, so none of them
presupposes maximality:

| Case | Lemma | Shape |
|---|---|---|
| G1 | `limitSetBelow_forward_G_rat_source` | `(q:ℝ) < t`, `allFuture φ ∈ m q → φ ∈ limitSetBelow m t` |
| G2 | `limitSetBelow_forward_G_rat_target` | `s < (p:ℝ)`, `allFuture φ ∈ limitSetBelow m s → φ ∈ m p` |
| G4 | `limitSetBelow_forward_G_limit` | `s < t`, limit to limit |
| H1 | `limitSetBelow_backward_H_rat_source` | `t ≤ (q:ℝ)`, `allPast φ ∈ m q → φ ∈ limitSetBelow m t` |
| H2 | `limitSetBelow_backward_H_rat_target` | `(p:ℝ) < s`, `allPast φ ∈ limitSetBelow m s → φ ∈ m p` |
| H4 | `limitSetBelow_backward_H_limit` | `t < s`, limit to limit |

Plus `limitSetBelow_of_rat_of_backward_H_rat_source`, which exhibits Phase 3's
`limitSetBelow_of_rat` as the `t = (q:ℝ)` instance of H1.

Cases **G3** and **H3** are documented as deliberately lemma-free in the module docstring,
including the instruction not to search for a `..._forward_G_rat_rat`.

## Plan deviations

1. **H1 stated with `t ≤ (q:ℝ)` rather than `t < (q:ℝ)`.** The plan's H1 bullet contains two
   requirements that are unsatisfiable together under the strict form: it asks for `t < (q:ℝ)`
   *and* asks that Phase 3's `limitSetBelow_of_rat` be generalized "into this lemma in place —
   it is exactly the `t = (q:ℝ)` instance". But `t = (q:ℝ)` is not an instance of `t < (q:ℝ)`,
   so no strict-form lemma generalizes it. The `≤` form satisfies both halves literally. The
   proof is unaffected (`p < t ≤ q` still gives `p < q`). Downstream cost: none — Phase 6 passes
   `le_of_lt` at case H1.
   The `forward_G` mirror (G1) admits no such widening and is stated strictly, as the plan
   specifies: at `t = (q:ℝ)` the left limit at `t` sees only rationals strictly *below* `q`,
   about which `allFuture φ ∈ m q` says nothing. The asymmetry is recorded in the module
   docstring.
2. Phase 3's `limitSetBelow_of_rat` is left **byte-identical** (it has no consumers outside its
   own module, so the plan's "re-derive it as a one-line corollary if it has other consumers"
   clause did not trigger). The corollary was added anyway, in the new module, as a check that
   the generalization really does cover it.

No other deviations. `limitSetAbove` duals were not proved, as the plan directs.

## The Phase 4 route election cost this phase nothing

Phase 4's handoff predicted that unselected-**source** cases (G2, G4, H2, H4) would route through
`limitMCSBelow_cofinal_below` instead of unfolding a `limitSetBelow` witness. That prediction
does not bite at this layer: all six lemmas are stated with `limitSetBelow` on both sides, as the
plan specifies, so an unselected-source hypothesis is a `limitSetBelow` membership and still
unfolds directly to its threshold witness. `limitMCSBelow` is not mentioned in this module.

**The correction is not discharged — it is relocated to Phase 6**, which instantiates unselected
points with `limitMCSBelow`. See the plan's PHASE 5 OUTCOME block for the checked transposition
recipe: the conclusion side is free via `limitSetBelow_subset_limitMCSBelow`, and the four
hypothesis-side variants are each one `limitMCSBelow_cofinal_below` call replacing one
`obtain ⟨z, hz, hmem⟩`, with the `max`-based bounds disappearing because that lemma takes the
threshold `z` as a parameter rather than returning it.

Those four variants were **not** written here: the plan's Phase 5 task list names exactly six
lemmas, all about `limitSetBelow`, and this dispatch's mandate was Phase 5 only.

## Final verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.Bundle.LimitMCSCoherence` | green, first attempt |
| `lake build` (full project) | green, 1895 jobs |
| Live sorries outside `Boneyard/` | 1 — `WeakCanonical/Transfer.lean:1242`, unchanged |
| Sorries introduced by this phase | 0 |
| Vacuous definitions introduced | 0 |
| New axioms | 0 |
| `#print axioms` on all 7 new declarations | `propext, Classical.choice, Quot.sound` |
| `limitSetBelow_of_rat` still sorryAx-free | yes, unchanged |

No strategic sorry was available to this phase, and none was needed.
