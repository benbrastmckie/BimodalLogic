# Handoff: GeneralExistPartOrdered is FALSE -- Fundamental Redesign Required

## Immediate Next Action
STOP attempting to prove `generalExistPartOrdered_zero` or `_succ`. The statement
`GeneralExistPartOrdered atomMap 0` is FALSE. A new research dispatch is needed to
find the correct formulation for the third mutual induction conjunct.

## Critical Finding: Counterexample

**Statement (FALSE)**: For all r >= 1 and all env_nfs, env_atoms, ssn, there exists
a formula A such that for ALL Prior structures M and environments e satisfying the
preconditions (individual 1-var NFs match env_nfs, atoms match env_atoms):
`temporal_truth M atomMap (e 0) A <-> exists y, nf_eval_nf M 0 (r+1) [y, e] ssn`

**Counterexample**: Take sig with 1 predicate, M = Z (integers), r = 2.
- All points on Z have the SAME depth-1 1-var NF (constant predicate, Z-homogeneous)
- env_atoms = "e(0) < e(1)" (qualitative order only)
- ssn = "e(0) < y < e(1) with pred true" (between-zone existential)
- env = [0, 2]: preconditions satisfied, existential TRUE (y=1 exists between 0 and 2)
- env = [0, 1]: SAME preconditions satisfied, existential FALSE (no integer between 0 and 1)
- temporal_truth Z atomMap 0 A is a FIXED value for any formula A (evaluated at 0 on Z)
- So A cannot satisfy the biconditional for both env choices

**Why it's false**: The formula A is evaluated at e(0) using only temporal operators
(Until/Since/atoms). On Z with constant predicates, all temporal formulas evaluated
at 0 have the same truth value regardless of what other env elements exist. But the
between-zone existential depends on the GAP between env elements, which varies.

**Confirmed by**: Independent fork verified all three checks: (1) Z satisfies Prior-UZ/SZ,
(2) all points on Z have the same depth-1 1-var NF, (3) temporal_truth is independent
of env.

## Impact on KampBypass

`existPart_succ_n1_bypass` takes `ih_general_exist : GeneralExistPartOrdered atomMap k`
as a PARAMETER. The theorem is sorry-free (verified: no sorryAx). But if the parameter
is false, the theorem is vacuously true from a false hypothesis.

`kamp_mutual_induction` instantiates `ih_general_exist` with `generalExistPartOrdered`,
which depends on `generalExistPartOrdered_zero` (sorry) and `generalExistPartOrdered_succ`
(sorry). Since the base case is FALSE, the entire GeneralExistPartOrdered chain is unsound.

## Root Cause Analysis

The fundamental issue: the statement asks for a CLOSED temporal formula at e(0) that
characterizes an existential involving ALL env elements. The formula can only "see"
the structure from e(0) using temporal navigation. It cannot access the positions of
other env elements.

On structures where all points have the same predicates and neighborhoods (like Z with
constant predicates), the formula has NO way to distinguish between different env
configurations. But the existential truth depends on the gap structure.

Adding `env_atoms` (pairwise orders) as a precondition was the right idea (without it,
the statement is also false -- the earlier GeneralExistPartIndiv counterexample). But
env_atoms only provides QUALITATIVE order information (less/greater/equal), not
QUANTITATIVE gap information. On Z, the gap is what matters for between-zone existentials.

## What DOESN'T Work

1. **Classical top/bot**: FALSE for between-zones (Z counterexample)
2. **Zone decomposition with char_0**: char_0 only detects predicates, can't detect gaps
3. **Reduction to generalExistPart_from_classical**: requires full r-var NF, not available
4. **Disjunction over compatible full NFs**: each disjunct uses top/bot, loses information
5. **Strengthening with depth-k 1-var NFs**: on Z with constant predicates, all depths give
   the same 1-var NF
6. **Pairwise 2-var NFs from 1-var NFs**: can't reconstruct multi-var NFs from individual ones

## What MIGHT Work (Research Needed)

### Option A: Gap Induction (Rabinovich-style)
Use the "no gaps" property of Prior structures to do induction on the gap between env
elements. For gap = 1 (adjacent): no between-zone existentials. For gap = n+1: use the
predecessor of x to split into two subproblems. This avoids the single-formula problem
by building a PROOF TREE that adapts to the structure.

**Pro**: Matches the literature (Rabinovich Prop 3.5 zone decomposition)
**Con**: Requires significant restructuring; gap induction is well-founded only on
specific structures; the general case needs careful handling.

### Option B: Enhanced Enriched Formula
Instead of encoding quantifier conditions via GeneralExistPartOrdered, encode the FULL
2-var NF directly into the Until formula. The Until formula becomes:
`(full_2var_char(sub_nf)) U top`
where full_2var_char characterizes the complete depth-(k'+2) 2-var NF of [x, t].

**Pro**: Clean theoretical approach; full NF determines everything
**Con**: Need temporal formulas for 2-var NFs, which is essentially the same problem

### Option C: Eliminate the Quantifier Gap
Restructure the KampBypass proof to avoid needing the quantifier transfer separately.
Instead of extracting x from Until and then proving the quantifier conditions, use a
SINGLE proof step that establishes the full 2-var NF eval directly.

**Pro**: Avoids the problematic GeneralExistPartOrdered entirely
**Con**: May require major KampBypass restructuring

### Option D: Use nf_eval_monotone for 2-var Transfer
From depth-(k'+2) 1-var NF agreement, get depth-(k'+1) 2-var existentials near each
point. Then show these determine the full depth-(k'+1) 2-var NF via monotonicity arguments.

**Pro**: Uses existing infrastructure
**Con**: The Z counterexample shows this doesn't work for depth 0; may work for depth >= 1

### Option E: Direct Full 2-var NF Construction
Instead of the third mutual induction conjunct, add a FOURTH conjunct that directly
provides the full 2-var NF characterization: "for all env with matching 1-var NFs,
the full 2-var NF is determined". This is essentially ExistPart(k) at n=2 but with
weaker preconditions.

**Pro**: Cleaner formulation
**Con**: Still faces the same fundamental issue (single evaluation point can't see gaps)

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| GeneralExistPart.lean | 174 | generalExistPartOrdered_zero | IMPOSSIBLE (statement is FALSE) |
| GeneralExistPart.lean | 207 | generalExistPartOrdered_succ | IMPOSSIBLE (depends on false base) |

## Recommendation

1. Mark GeneralExistPartOrdered as FALSE in the codebase (add a comment)
2. Launch a research dispatch to evaluate Options A-E above
3. The research should focus on: what mechanism does Rabinovich's proof ACTUALLY use
   to handle multi-variable existentials in the discrete case? The answer likely involves
   the composition of temporal formulas using zone decomposition with gap induction.
4. After research: create a new plan (v9) with the corrected approach
5. The KampBypass will likely need restructuring for k >= 1

## Files Modified
- specs/303_k_gt_0_depth_induction/plans/08_generalexistpart-redesign-plan.md (Phases 1, 2 marked BLOCKED)

## Build Status
Project builds cleanly (the sorry remains in place, nothing new broken).
