# Phase 0 Handoff: Bounded Quantifier Relativization

**Task**: 202 -- Reynolds k-equivalence bypass
**Session**: sess_1780162885_5a6fd2
**Date**: 2026-05-30
**Plan**: plans/17_reynolds-model-surgery-v16.md
**Phase**: 0 (Bounded Quantifier Relativization Infrastructure)
**Status**: PARTIAL (Tasks 0.1-0.4 completed, Tasks 0.5-0.6 deferred)

## Completed Work

### MonadicFO.lean additions (~90 lines, all sorry-free)

1. **Syntactic sugar** (Tasks 0.1-0.2):
   - `MonadicFormula.imp`, `MonadicFormula.or`, `MonadicFormula.leq`
   - `MonadicFormula.true_`, `MonadicFormula.false_`
   - `eval_imp`, `eval_or`, `eval_leq`, `eval_true`, `eval_false` simp lemmas

2. **Relativize definition** (Task 0.3):
   - `relativize : MonadicFormula sig n -> MonadicFormula sig (n + 2)`
   - Maps all quantifiers to bounded versions (lo <= var 0 <= hi)
   - Variables 0..n-1 unchanged, variable n = lo, variable n+1 = hi
   - `relativize_sentence` specializes to sentences (n=0)

3. **Relativize correctness** (Task 0.4):
   - `relativize_env` constructs evaluation environment from subinterval env
   - `relativize_env_cons` commutation lemma (key for quantifier induction)
   - `relativize_correct` proved by structural induction (sorry-free)
   - `relativize_sentence_correct` derived for sentences

### Key Technical Decisions

- Used general `relativize` for arbitrary n (not just n=0), because the correctness proof requires structural induction that goes through higher n
- Used `Fin.castSucc.castSucc` for atom/lt index embedding (keeps values, changes bound)
- Guard for `all`: `MonadicFormula.imp (and (leq lo x) (leq x hi)) body`
- Guard for `ex`: `and (and (leq lo x) (leq x hi)) body`
- Used `Fin.cases` in commutation lemma to avoid De Bruijn arithmetic

## What Remains

### Phase 0 Tasks 0.5-0.6 (deferred)

- `nf_to_sentence`: Encode NormalForm evaluation as a MonadicSentence
  - Needed to connect NormalForm world with MonadicFormula world
  - Can be defined in GoodStructuresModelSurgery.lean as part of Phase 1
  
- `good_sentence_relativized`: Express `good sig k (M.subinterval lo hi)` as MonadicFormula sig 2
  - Combines nf_to_sentence with relativize_sentence
  - Essentially: disjunction over good k-types of relativized NF-checking sentences

### Phase 1: Gap Formula R Construction

**Next action**: Define `contemp_equiv_formula` and `right_gap_class_formula` using the relativization infrastructure.

The construction path:
1. For each NormalForm nf at depth k with 0 free vars, construct `nf_sentence nf : MonadicSentence sig` that checks whether nf is satisfied
2. `good_check : MonadicFormula sig 2` = disjunction over Z-interval k-types of `relativize_sentence (nf_sentence nf)`
3. `very_good_check : MonadicFormula sig 2` = `all a, all b, (lo <= a && a <= b && b <= hi) -> good_check(a, b)` (uses double relativization)
4. `contemp_equiv_formula : MonadicFormula sig 2` = `very_good_check` with lo = min(var0, var1), hi = max(var0, var1)
5. `right_gap_class_formula : MonadicFormula sig 1` = existential + universal using contemp_equiv_formula

**Warning**: Steps 3-4 require expressing min/max in the formula language, which adds complexity.

### Phases 2-4: Model Surgery

Phases 2-4 (R-interval analysis, model surgery, contradiction) are ~500 lines and have not been started. These are the mathematical core of Reynolds Theorem 14.

## Build Status

- `lake build` passes with 0 errors
- No new sorry sites introduced
- GoodStructuresModelSurgery.lean unchanged (2 sorry sites at lines 702, 728)
