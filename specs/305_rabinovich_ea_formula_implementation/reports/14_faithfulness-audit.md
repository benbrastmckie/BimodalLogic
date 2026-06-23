# Faithfulness Audit: Task 305 vs Rabinovich 2014

**Task**: 305 — Rabinovich EA-formula implementation
**Date**: 2026-06-23
**Mode**: H2/H3/H4/H5 hard-mode research

## Summary

The current implementation has **diverged** from Rabinovich's proof architecture. The sole critical-path sorry (`nf_exist_to_temporal_aux`, FOToVEA.lean:118) is part of an NF-depth mutual induction approach that replaces Rabinovich's structural formula induction (Prop 4.3). This replacement introduced the "arity tower" problem — a problem that does not exist in Rabinovich's proof.

## Rabinovich's Proof Architecture (Ground Truth)

From Rabinovich 2014, the proof uses exactly two induction principles and zero cross-model transfer:

**Induction 1: On witness count n** (Lemma 5.3, Lemma 5.1). Negating a bracket formula with n+1 witnesses reduces to formulas with at most n witnesses.

**Induction 2: Structural induction on FO formulas** (Prop 4.3). Cases: atomic (trivially EA), disjunction (closure), negation (Prop 4.2), existential (Lemma 3.4). No depth parameter consumed.

Complete chain:
```
Def 3.1 -> Lemma 3.2 -> Lemma 3.4 -> Prop 3.5
                                        |
Lemma 5.3 -> Cor 5.4 -> Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Thm 4.4
```

**No NF depths, no cross-model transfer, no arity climbing, no mutual induction on (CharPart, ExistPart).**

## H3 Reference Grounding Table

| Rabinovich Reference | Lean Declaration | Status | Faithful? | Gap Description |
|---------------------|-----------------|--------|-----------|-----------------|
| Def 3.1 (EA formula) | VecEAFormula, BracketFormula, VecEA2 | sorry-free | YES | |
| Def 3.3 (V-EA formula) | VBracketFormula, VVecEA2 | sorry-free | YES | |
| Lemma 3.2.1 (conj closure) | BracketFormula.conj_to_bracket_exists | sorry-free | YES | |
| Lemma 3.2.2 (arity reduction) | NOT IMPLEMENTED standalone | missing | -- | Implicit in VecEADecomp depth-0 only |
| Lemma 3.4 (V-EA closure) | VVecEA2.conj_holds_vvecEA2 + disj | sorry-free | YES | |
| Prop 3.5 (V-EA 1-var -> TL) | ExistsForallSpec.translate_correct | sorry-free, verified | YES | |
| Notation 5.2 | BracketFormula.holds | sorry-free | YES | |
| INF formula (eq 5.2) | inf_bracket_formula, prior_hasAttainedINF | sorry-free | ADAPTED | HasAttainedINF instead of K+ |
| Lemma 5.3 (all-betas-True) | neg_orderedPointsExist_is_vbracket | sorry-free, verified | YES | |
| Cor 5.4 forward | neg_partialBracketExist_sufficient | sorry-free | YES | |
| Cor 5.4 backward | neg_partialBracketExist_is_vbracket:1235 | SORRY | DIVERGED | F-chain unboundedness |
| Lemma 5.1 model-dep | neg_interval_formula | sorry-free, verified | ADAPTED | Forward-only, model-dependent |
| Lemma 5.1 model-indep | neg_bracket_is_vbracket:1084 | SORRY | DIVERGED | beta_0(r0) case blocked |
| Lemma 5.1 VecEA2-level | neg_vecEA2_is_vvecEA2:160 | SORRY | DIVERGED | Wrong decomposition strategy |
| A_i^-/A_i^+ decomposition | leftPart, rightPart, splitAt_combine | sorry-free | YES | |
| Prop 4.2 model-dep | neg_2var_vec_ea | sorry-free, verified | ADAPTED | Model-dependent |
| Prop 4.2 model-indep | NOT IMPLEMENTED | missing | -- | Needs model-indep Lemma 5.1 |
| Prop 4.3 (FO -> V-EA) | NOT IMPLEMENTED via Rabinovich | missing | -- | Replaced by NF-depth induction |
| Thm 4.4 (Kamp's theorem) | kamp_prior_expressive_completeness | sorryAx | DIVERGED | NF-depth instead of Rabinovich chain |

## Key Finding: Arity Tower is Not in Rabinovich

The arity tower (depth k+1 arity 2 -> depth k arity 3 -> ... -> depth 0 arity k+3) is a direct consequence of replacing Rabinovich's structural formula induction with NF-depth induction. Rabinovich avoids it entirely through Lemma 3.2(2), which reduces every EA formula to at most 2 free variables.

## Three Coexisting Strategies

1. **Strategy A (Rabinovich-faithful, EANegation.lean)**: Blocked at beta_0(r0) — wrong decomposition strategy (point-type vs segment-type). UNUSED by critical path.
2. **Strategy B (Model-dependent, EANegationClosure.lean)**: Sorry-free. Suffices for Prior. USED by model-dep chain.
3. **Strategy C (NF-depth, NfExistTL.lean + FOToVEA.lean)**: One sorry at arity tower. USED by critical path.

## Recommendation: Path B (Faithful Rabinovich Restoration)

Fix EndpointNegation.lean:160 via Rabinovich's segment-type decomposition, then build:
1. Model-independent Lemma 5.1 (~300-400 lines)
2. Model-independent Prop 4.2 (~100-150 lines)
3. Prop 4.3 via structural formula induction (~200-300 lines)
4. Wire into KampPrior.lean (~100 lines)

Estimated ~700-1050 lines. Eliminates arity tower entirely.
