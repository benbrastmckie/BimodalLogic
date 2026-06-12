# Phase 2 Handoff: Closure Properties (Lemma 3.4)

## Status: PARTIAL

## What Was Done

Created `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` (~220 lines) with:

### Sorry-Free Components
- `TemporalPred.eval_at_conj`: conjunction semantics helper
- `TemporalPred.eval_at_top`: top predicate semantics
- `BracketFormula.conj_to_bracket_exists` base cases: (0,0), (0,n+1), (n+1,0) -- conjunction of bracket formulas when one has 0 witnesses
- `VBracketFormula.conj_holds_vbracket`: V-bracket conjunction closure (Lemma 3.4, modulo `conj_to_bracket_exists`)
- `VVecEA2.conj_holds_vvecEA2`: V-VecEA2 conjunction closure (modulo `conj_to_bracket_exists`)
- `BracketFormula.existsBounded_right` 0-witness case: bounded existential with 0 witnesses
- `VBracketFormula.existsBounded_right`: V-bracket existential closure (modulo `existsBounded_right`)

### Sorry Sites (3 total)
1. **`bracket_segType_at_y`** (line 77): Helper lemma asserting that the segment type holds at a point identified by `witnessCountBelow`. Requires case analysis on where y falls among witnesses. Used only by the general case.
2. **`conj_to_bracket_exists` general case (n1+1, n2+1)** (line 135): The Finset.sort-based merged construction is described in comments. The challenge is Lean's index arithmetic for Fin/List operations on sorted lists. The mathematical argument is sound (Rabinovich Lemma 3.2.1).
3. **`existsBounded_right` n+1 case** (line 214): Inserting z as the (n+1)-th witness after w_0,...,w_n. The construction (w' function, point types, segment types) is described. The issue is proving all 6 IntervalPattern.holds conditions with the piecewise-defined w'.

## Blockers

The sorry sites are all **index arithmetic** issues:
- The mathematical content is correct -- the constructions are well-defined
- The difficulty is Lean's handling of `split_ifs` with `Fin` values, `dite`-reduction through nested if-then-else in segment types, and `Finset.sort`/`List.get` interaction
- Each sorry site is estimated at ~30-50 lines of tactic proof to close

## Immediate Next Action

To fill the sorries:
1. For `existsBounded_right` n+1 case: Use `show` to make the goal explicit with the concrete segment/point type after `dite`-reduction, then prove each of the 6 conditions with explicit `split_ifs` + `simp` matching.
2. For `conj_to_bracket_exists` general case: Either (a) fill the Finset.sort construction with explicit `List.pairwise_iff_get` and `witnessCountBelow` lemmas, or (b) use an induction-on-n2 approach that absorbs witnesses one at a time.

## Key Decisions
- Used `Finset.sort (. <= .)` with `Finset.sortedLT_sort` for the merged witness construction
- Defined `witnessCountBelow` to identify which source segment covers a point in the merged arrangement
- Used `TemporalPred.conj` for segment type conjunction, with `eval_at_conj` as the key semantic bridge

## Session
sess_1781193902_83bc5c
