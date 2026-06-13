# Micro-Task 2 Handoff: Depth-0 2-var Existential TL-Definability

## Session
- ID: sess_1781389120_27fede
- Date: 2026-06-13
- Agent: lean-implementation-hard-agent

## What Was Accomplished

### NfToVecEA.lean (410 -> 634 lines)

1. **bracketBuildLeft**: Since-direction bracket-to-temporal translation (symmetric to bracketBuildRight in VecEATranslation.lean). Formula construction at all n, correctness sorry-free at n=0.

2. **VecEA2.translateRight_correct_zero**: Sorry-free proof that VecEA2.translateRight correctly captures holdsRight semantics at n=0 (trivial bracket).

3. **nf_2var_exist_depth0_tl** (sorry-free): Main result. Proves that at depth 0, `exists x, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf` is equivalent to a temporal formula, by case-splitting on order booleans:
   - (true, true): Formula.bot (both orders impossible)
   - (true, false): VecEA2.translateLeft for Until direction
   - (false, true): VecEA2.translateRight for Since direction  
   - (false, false): Formula.and of nfPred formulas for equality case

### NfCharFormula.lean

4. **nf_2var_exist_formula_prior k=0 filled**: Added import of NfToVecEA and filled the k=0 case using nf_2var_exist_depth0_tl. The k+1 case remains sorry.

## Sorry Inventory

| File | Line | Statement | Why Deferred |
|------|------|-----------|-------------|
| NfCharFormula.lean | 583 | nf_2var_exist_formula_prior (k+1) | Requires Feferman-Vaught composition for non-interval 3-var zones |
| NfToVecEA.lean | 472 | bracketBuildLeft_correct (n+1 fwd) | Needs bracket_append_witness |
| NfToVecEA.lean | 475 | bracketBuildLeft_correct (n+1 bwd) | Needs bracket_extract_last_witness |

## Key Insight

The k+1 case of nf_2var_exist_formula_prior has the SAME blocker as nf_exist_formula_nested_backward (NegationClosure.lean:1712): the backward direction requires showing that non-interval 3-var existentials (y > x, y = x, y = t, y < t) are determined by the depth-(k+1) 1-var NFs. This is the Feferman-Vaught composition theorem for linear orders.

## Immediate Next Action

Either:
(A) Prove the composition lemma in NfComposition.lean
(B) Find an alternative backward direction proof that avoids composition
(C) Accept the sorry and focus on other tasks

## Build Status
- NfToVecEA.lean: builds, 2 sorries (leaf, n+1 bracket manipulation)
- NfCharFormula.lean: builds, 1 sorry (k+1 case)
- Full project: builds (pre-existing errors in CanonicalTaskRelation.lean)
