# Phase 4 Handoff: Lemma 5.1 (Full Negation Closure)

## Immediate Next Action

Prove `BracketFormula.splitAt_combine` sorry-free, then design the correct induction strategy for `neg_bracket_is_vbracket` (Lemma 5.1).

## Current State

- Phase 4 partially complete: base case proved, inductive step has sorry
- Build status: PASSES with 3 expected sorries
- Sorry count: 3 (splitAt_combine, neg_bracket_is_vbracket step, neg_partialBracketExist_is_vbracket)

## What Was Accomplished

1. **Proved `neg_bracket_zero_is_vbracket`** (sorry-free): Base case for Lemma 5.1. For BracketFormula 0 (0 witnesses, 1 segment type beta_0), the negation is equivalent to a V-bracket with a single 1-witness disjunct (point type = beta_0.neg, segment types = top).

2. **Added `neg_bracket_is_vbracket` statement**: Full Lemma 5.1 theorem, induction on n. Base case delegates to `neg_bracket_zero_is_vbracket`. Inductive step has sorry.

3. **Attempted `splitAt_combine` proof**: Multiple approaches tried (4+ iterations). All failed on Fin index arithmetic with dite conditions. The subagent's attempt also had errors (Fin.val_lt_val.mp doesn't exist, omega failures on computed Fin indices, type mismatches in `convert`).

## Key Design Insight (CRITICAL for next dispatch)

The "peel off first witness" approach for the inductive step of Lemma 5.1 **DOES NOT WORK** with our bracket convention. Here's why:

Our `BracketFormula n` has n interior witnesses with NO endpoint conditions. The paper's bracket `[A_0, B_1, ..., B_n, A_n](z_0, z_1)` has A_0 at the endpoint z_0 itself.

When we find the first occurrence r0 of alpha_0 (the first point type) via HasAttainedINF, we know:
- alpha_0(r0) holds
- alpha_0 does NOT hold in (z0, r0)
- rightPart ⟨0⟩ has n witnesses

But to reconstruct bf.holds via splitAt_combine, we need:
- alpha_0(r0) -- HAVE
- leftPart ⟨0⟩.holds z0 r0 -- this is "beta_0 on (z0, r0)" -- DON'T HAVE
- rightPart ⟨0⟩.holds r0 z1 -- need to show or deny

The issue: knowing alpha_0 doesn't occur in (z0, r0) tells us NOTHING about beta_0 (segmentTypes 0) on (z0, r0). The coupling between point and segment conditions means the Lemma 5.3 approach doesn't generalize.

## Recommended Approach for Next Dispatch

### For splitAt_combine

The proof has 4 cases (left 0/positive, right 0/positive). Each case constructs a combined witness function. The key difficulties:

1. **holds_eq_zero/holds_eq_succ on hypotheses**: When `i.val` is a variable (not syntactically 0 or k+1), IntervalPattern.holds won't reduce. Use `holds_eq_zero (h := ...)` / `holds_eq_succ (h := ...)` to convert.

2. **Fin index arithmetic**: The combined witness function uses dite (decidable if-then-else). After `simp [condition]`, the Fin indices get nested coercions. Use `convert ... using 2` with `simp [Fin.ext_iff]; omega` to match indices.

3. **match reduction in hypotheses**: After `simp [..., IntervalPattern.holds] at hleft'`, the hypothesis contains `match i.val, pat with | 0, pat => ... | n.succ, pat => ...`. This match does NOT reduce when `i.val` is a variable. Use `holds_eq_zero`/`holds_eq_succ` BEFORE unfolding, or case-split on `i.val` first.

### For Lemma 5.1 inductive step

The correct approach decomposes by **segment type failure**, not point type failure:

1. **Case A (point type failure)**: Not all alpha_i can be placed. Equivalent to `not orderedPointsExist (n+1) bf.pointTypes z0 z1`. By Lemma 5.3, this is V-bracket.

2. **Case B (orderedPointsExist but bracket fails)**: There exist witnesses satisfying all alpha_i, but some segment type fails. For each possible segment failure index j, find the first failure point of beta_j in the relevant sub-interval using HasAttainedINF. Split the interval there. Apply IH to the sub-brackets.

The V-bracket formula must cover ALL failure modes. The construction uses VBracketFormula.disj to combine:
- V-bracket for Case A (from Lemma 5.3)
- V-brackets for each Case B sub-case (from IH via splitAt + Lemma 5.3)

Note: Case B is complex because the "relevant sub-interval" for beta_j depends on the witness positions, which vary. A cleaner approach might use the **F-chain reduction** from Corollary 5.4: convert bracket to orderedPointsExist with F-chain predicates, then apply Lemma 5.3. But this requires proving the reverse direction of bracket_implies_fChainPred on Prior structures.

## Sorry Inventory

1. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean:487` -- `theorem BracketFormula.splitAt_combine` (deferred from Phase 1, needed for Phase 4)
2. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean:859` -- `theorem neg_bracket_is_vbracket` inductive step (Lemma 5.1 core, new)
3. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean:872` -- `theorem neg_partialBracketExist_is_vbracket` (pre-existing, depends on Lemma 5.1)

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- Added neg_bracket_zero_is_vbracket (sorry-free), neg_bracket_is_vbracket (sorry at step)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- splitAt_combine still sorry (cleaned up broken attempts)
- `specs/305_rabinovich_ea_formula_implementation/plans/01_ea-formula-plan.md` -- Phase 4 marked IN PROGRESS, tasks updated
