# Phase 4 Handoff: Gap Elimination (Reynolds Theorem 14)

**Date**: 2026-05-20 (second attempt)
**Session**: sess_1748015693_phase4_cont
**Status**: BLOCKED (no change from prior handoff)

## What Was Done This Session

Deep analysis of the mathematical obstacle blocking `no_gaps_discrete`. Three alternative proof strategies evaluated. None are immediately viable without substantial new formalization.

## Current State

- **`no_gaps_discrete`** (IntegerModel.lean:837): Correct signature (no IsSuccArchimedean). Body is `sorry`. Blocked on Reynolds Theorem 5.
- **`one_class`** (IntegerModel.lean:900): Correctly wired to use `no_gaps_discrete` + `no_boundary_at_successor` + `contemp_equiv_is_equiv`. Inherits `sorryAx` from `no_gaps_discrete`.
- **`contemp_equiv_is_equiv`**: Sorry-free, no IsSuccArchimedean.
- **`no_boundary_at_successor`**: Sorry-free.
- **`chronicle_is_good`** (IntegerModel.lean:1245): Still uses `orderIsoIntOfLinearSuccPredArch` -- Phase 6 work.
- **Build**: Passes (1644 jobs).

## Why It's Blocked: Detailed Analysis

### The Core Problem

`no_gaps_discrete` needs to prove: in a discrete Prior structure, ~M-class boundaries cannot fall at gaps (only at successor pairs). The Reynolds proof constructs a temporal formula R that holds exactly where "the class ends at a gap on the right" and derives a contradiction via Prior-UZ.

Constructing R requires **US expressive completeness over Prior structures** (Reynolds Theorem 5): every monadic FO formula with one free variable has an equivalent temporal formula in any Prior structure.

### Why Existing Infrastructure Falls Short

1. **`US_expressively_complete_over_Z`**: Works for `IntStructureFromSig` (carrier = Z). Cannot be applied to arbitrary discrete Prior structures M whose carrier is NOT Z.

2. **`table_correctness`**: Converts temporal -> FO (works on any OrderedMonadicStructure). We need FO -> temporal (the reverse), which IS expressive completeness.

3. **`K_plus_bot_on_Z`**: Proves K+(q) = false on Z. The analogous fact for discrete orders with SuccOrder is true (proof: U(top, not q) holds with witness succ(t), empty guard) but is not formalized.

### Three Paths Forward (from updated BLOCKER)

**Path A (Reynolds faithful)**: Formalize Stavi connectives, Theorem 4 ({U,S,U',S'} over all linear), Theorem 5 ({U,S} over Prior). ~300-500 new lines. Stavi connectives not in codebase.

**Path B (Transfer)**: Transfer Z-expressiveness to Prior structures via embedding. Each ~M class in a discrete Prior structure is "locally Z-like." ~100-200 lines but mathematically non-trivial.

**Path C (Direct)**: Prove no_gaps_discrete by a direct argument on k-types + Prior-UZ, avoiding expressive completeness. Use the fact that k-type differences generate distinguishing temporal formulas. ~150-300 lines, requires connecting k-type machinery to temporal formula existence.

### Recommended Next Action

**Path C** (Direct gap elimination) is most promising because:
- It avoids building Stavi connective infrastructure (Path A)
- It doesn't require a delicate embedding argument (Path B)
- It leverages existing k-type and table_correctness machinery
- The key insight: if k-types differ across a gap, there IS a NormalForm that evaluates differently. The NormalForm's quantifier structure can be "unwound" into a temporal formula via the table correspondence (table_correctness gives the bridge from temporal to FO, and constructing the temporal formula from the NF amounts to inverting the table for the specific NF in question).

Concretely, Path C requires:
1. A lemma: "if nf_eval_nf differs at two points, there exists a temporal formula phi such that temporal_truth differs at those points" (inverting table_correctness for specific NFs)
2. A lemma: "in a gap scenario, Prior-UZ applied to such phi yields contradiction" (the argument from the analysis: F(phi) holds, but U(phi, neg phi) cannot be witnessed because the gap side has no minimum)

## Key Decisions

- `no_gaps_discrete` signature is FINAL (no IsSuccArchimedean, takes atomMap + h_prior_UZ + h_prior_SZ)
- `one_class` wiring is FINAL (calls no_gaps_discrete + no_boundary_at_successor)
- The sorry in no_gaps_discrete is the ONLY blocker for one_class

## Files Modified

None this session (analysis only; plan BLOCKER updated).

## Resume Point

Next agent should:
1. Read this handoff
2. Read the updated BLOCKER in `specs/155_reynolds_pipeline_activation/plans/03_reynolds-pipeline-plan.md` (Phase 4 section)
3. Choose Path A, B, or C
4. Implement the chosen path to close `no_gaps_discrete`
5. Verify `lean_verify one_class` shows no sorryAx
