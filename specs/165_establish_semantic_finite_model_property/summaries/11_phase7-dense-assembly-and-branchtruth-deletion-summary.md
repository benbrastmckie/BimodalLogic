# Phase 7, eleventh dispatch — 7.1e closed, 7.1d started

**Status**: PARTIAL (phase 7 of 8). Sorry count over `Verified/`: **0**, compiler cross-check MATCH.

## What was done

Three green commits, each verified by `git show --stat` for **content**, not merely for exit
status — the recorded hazard from the previous dispatch, where a commit reported success while
capturing 6 lines of an intended ~200-line diff.

| # | Commit | Sub-phase | Lines |
|---|--------|-----------|-------|
| 1 | `3e7ffac` | 7.1d assembly | +109 |
| 2 | `ffd86ef` | 7.1e (complete) | +26 / −73 |
| 3 | `eff027e` | 7.1d counting bridge | +86 |

### 7.1d — the assembly (new module `Verified/Bridge/DenseTruth.lean`)

`branchTruthAt_of_temporal`: the whole six-case induction with the `untl`/`snce` cases abstracted
into hypotheses and the other four discharged, unchanged, from `IntTruth.lean`. Compiled on the
first attempt. This is the machine-checked form of a claim three prior banners had only asserted
in prose — that `atom`, `bot`, `imp` and `box` are generic in the carrier and the placement, and
so serve `ℚ`/`ℝ` verbatim. It also bounds the residual exactly: the difference between the
discrete and dense milestones is **two hypotheses**.

Unplanned finding from the binder list: `branchOrderValid` and `temporalWitnessCheck` do not
appear in it at all, because no non-temporal case consumes either.

### 7.1e — complete: `branchTruth` deleted, not demoted

The plan said "demote or delete". The retirement note in `CountermodelExtraction.lean` had
defended keeping the evaluator as "an executable debugging aid, useful for `#eval`-inspecting
what a branch claims". **Measured rather than believed**: `branchTruth` is `Prop`-valued with no
`Decidable` instance, so `Decidable (branchTruth cm w t f)` fails to synthesise and `#eval` was
never available on it. With that gone the definition was on no proof path, could not be run, and
its sole consumer `signedTruthInModel` was referenced nowhere in the project — so "demote" had
nothing left to demote to.

The module docstring was also stale in a way worth fixing: it still advertised the long-retired
`branchTruthLemma` as a "Key correctness theorem" under a "Semantic Correctness Guarantee"
heading. Replaced with a pointer to where the truth lemma actually lives.

### 7.1d — the rank/cut-index bridge

A finding that **shrinks** 7.1d, obtained by reading the lemma rather than assuming its shape:
`regionLabel_untlNeg` and `regionLabel_snceNeg` are stated for an **arbitrary** region index
`j ≤ n`, not just the rays. The `ℤ` development only ever called them at `j = n`. So an interior
gap needs no new region-label content, and the dense negative `untl` case's "`s` non-placed" leaf
covers interior gaps and the upper ray **at once**, where `ℤ` split them.

What that leaf does need is the side condition `branchRank b ord t < j`, and supplying it is the
one genuinely new counting argument, since `branchRank` is a `List.filter` length in the *branch*
order while `cutIndex` is a `Finset.card` in the *carrier* order:

- `length_filter_finRange` — list/`Finset` count transfer over `Fin n`.
- `branchRank_eq_card` — moves the count off the list onto the index type via
  `List.map_getElem_finRange`. Needs no injectivity: the two are in *definitional* bijection.
- `branchRank_lt_cutIndex` — `f i < s → branchRank b ord (timeAt b i) < cutIndex (regionCode f s)`
  from `OrderFaithful` alone. Strictness comes from the single element separating the counts: `i`
  is below `s` so is counted on the right, and `strictBefore` is irreflexive on a gated branch so
  does not count `i` on the left.

## Verification

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1116 jobs |
| `lake build` (full) | green, **1939 jobs**, zero errors |
| `lake env lean` on `DenseTruth.lean` | green |
| sorry census over `Verified/` `--cross-check` | 0 / 0 / 0, MATCH |
| vacuous definitions | 0 |
| `^axiom` | 0 |

Both previously-red out-of-territory modules (`CounterexampleElimination.lean`,
`BadIntervals.lean`) are **now green**, so nothing is being masked.

## What 7.1d still owes

All four temporal halves at a dense carrier. The negative halves now have their reaching lemma
and their side condition; the positive pair is harder, because `Stepped`'s witness must be
replaced by density and Correction 12's residual leaf has to be re-examined where a region is
inhabited.

**The obligation to resolve before writing any proof**: whether the negative case's "`r`
non-placed" leaf needs a new gate row. At `ℤ`, `r` on the lower ray was covered by row 5
(`untlNegRayLow`), whose reach is *every* known time but whose scope is `j = 0` only. At `ℚ`/`ℝ`,
`r` can sit in an interior region `j`, and `regionLabel b ord w j` is an arbitrary known time
whose rank bears no relation to `j` — `regionLabel` picks the first eligible candidate, not the
order-minimal one — so neither row 5 nor `untlNeg_spread` reaches. The natural generalisation is
row 5 with `0` replaced by an arbitrary `j`, which would subsume it. **Measure it on the corpus
before stating it**, in the exact form to be adopted and beside the row it strengthens.
