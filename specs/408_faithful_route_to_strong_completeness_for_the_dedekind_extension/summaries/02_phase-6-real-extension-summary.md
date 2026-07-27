# Phase 6 Summary: The FMCS real extension by rational selection

- **Task**: 408 — faithful route to consequence completeness for the Dedekind extension
- **Plan**: `plans/02_strong-completeness-dedekind-v2.md`, Phase 6
- **Status**: [COMPLETED], sorry-free
- **Date**: 2026-07-27

## What landed

`FormalSystem/Metalogic/Bundle/RealExtension.lean` (new, 227 lines, 9 declarations):

| Declaration | Role |
|---|---|
| `realLimitMCS` | the extension: `m q` at selected points, `limitMCSBelow m (x + δ)` elsewhere |
| `realLimitMCS_of_rat` | the selection lemma — definitional agreement at rationals |
| `realLimitMCS_of_not_rat` | the non-selection unfolding |
| `realLimitMCS_is_mcs` | maximality, by case split |
| `realLimitMCS_forward_G` | forward `G` coherence, four-case split |
| `realLimitMCS_backward_H` | backward `H` coherence, mirrored four-case split |
| `FMCS.toRealShift` | the shifted `FMCS (fc := fc) ℝ` |
| `FMCS.toReal` | the `δ = 0` instance |
| `FMCS.toReal_at_rat` | "extends rather than replaces" |

`FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` (extended, 4 new declarations): the
`limitMCSBelow`-source variants `limitMCSBelow_forward_G_rat_target` (G2),
`limitMCSBelow_forward_G_limit` (G4), `limitMCSBelow_backward_H_rat_target` (H2),
`limitMCSBelow_backward_H_limit` (H4).

`FormalSystem/Metalogic/Bundle.lean`: import line and contents entry for `RealExtension`.

## Verification

- `lake build`: green, 1895 jobs.
- Live sorries outside `Boneyard/`: exactly `WeakCanonical/Transfer.lean:1242` — unchanged from
  Phase 5, zero introduced.
- All thirteen new declarations: axioms exactly `[propext, Classical.choice, Quot.sound]`.
- No vacuous definitions, no new `axiom` declarations.

## Deviations from the plan

Three, all recorded inline in the plan's Phase 6 task list and expanded in its PHASE 6 OUTCOME
block. The first is load-bearing; the other two are mechanical.

1. **Unselected points take `limitMCSBelow`, not `limitSetBelow`** (and `is_mcs` is discharged by
   `limitMCSBelow_is_mcs`, not by the plan's named `limitSetBelow_is_mcs`). Forced, not
   preferred: `limitSetBelow` is consistent but not negation-complete, so no
   `limitSetBelow_is_mcs` exists or can exist — that gap is exactly why Phase 4 built the
   ultrafilter limit. This was the correction Phase 5's OUTCOME block relocated to this phase,
   and it arrived exactly where predicted.

2. **G2/G4/H2/H4 consume the four new `limitMCSBelow`-source variants** rather than the
   `limitSetBelow`-source lemmas the plan names. Direct consequence of (1): an unselected source
   now supplies an ultrafilter membership. The conclusion side needed no variants —
   `limitSetBelow_subset_limitMCSBelow` lifts G1 and H1 in one step at the point of use.

3. **The offset transport is `by linarith`, not `add_lt_add_right hxy δ`.** In this Mathlib
   `add_lt_add_right` resolves to the left-addition form `δ + x < δ + y`, a real type mismatch
   against the needed `x + δ < y + δ`. Caught by the build; fixed forward.

## Notes carried forward

- Phase 5's transposition recipe was exact and needed no correction: each variant is one
  `limitMCSBelow_cofinal_below` call at the predicted threshold (`s - 1` for G2 and G4,
  `(p:ℝ)` for H2, `t` for H4) composed with the family's coherence field, and the `max`-based
  bounds of the H-side proofs vanished as predicted.
- H1's Phase 5 widening to `t ≤ (q:ℝ)` cost nothing: `le_of_lt` supplies it, as that phase's
  deviation note said it would.
- `FMCS.toRealShift` is already shift-parameterised, so Phase 6.1 can form
  `{fam.toRealShift δ | fam ∈ B.families, δ : ℝ}` with no further `FMCS`-layer construction.
- `limitSetAbove` and its duals remain standing but unused on this route; confirmed again.

## Commits

- `e57a1549b` — `task 408 phase 6.1: limitMCSBelow-source coherence variants (G2, G4, H2, H4)`
- `a9fcbc450` — `task 408 phase 6: the FMCS real extension by rational selection`

**Message collision, for the reader's benefit.** The first commit's `phase 6.1` is the
`task {N} phase {P}.{O}` *sub-step* convention (objective 1 within phase 6), not the plan's
**Phase 6.1**, which is a distinct, still-unstarted phase about the `BFMCS` real bundle. The
plan phase numbering and the commit sub-step numbering collide only here; no work on the plan's
Phase 6.1 was done or begun.
