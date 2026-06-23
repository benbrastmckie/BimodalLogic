# Phase 1 Handoff: VecEA2-Level Lemma 5.1

**Task**: 305 (rabinovich_ea_formula_implementation)
**Session**: sess_1782213664_11fe36
**Phase**: 1 (partial)
**Status**: Base case sorry-free, succ case has genuine obstruction

## Immediate Next Action

Revise the implementation plan to use the model-dependent chain from EANegationClosure.lean
for Phases 2-4, bypassing the model-independent EndpointNegation.lean for the critical path.

## Current State

- Phase 0: COMPLETED (11 bypass files archived to Boneyard/)
- Phase 1: PARTIAL
  - EndpointNegation.lean exists with `neg_vecEA2_is_vvecEA2`
  - Base case (n=0): sorry-free, 3 disjuncts via de Morgan (~125 lines)
  - Succ case (n+1): sorry with detailed obstruction analysis
  - `lake build` passes (990 jobs, 1 sorry warning)
- Phases 2-5: NOT STARTED

## Key Finding: Model-Independent Biconditional Obstruction

The succ case of `neg_vecEA2_is_vvecEA2` requires constructing a FIXED VVecEA2 (before
knowing the model) such that v.holds <-> not vea.holds on ALL models with HasAttainedINF.

**The obstruction**: The BracketFormula (n+1) has n+1 INTERIOR witnesses x0,...,xn that are
existentially quantified. The negation requires blocking ALL possible witness configurations.
Having not-tail.holds at one point r0 does NOT block configurations starting from a different
first witness x0 > r0 (because the tail might succeed on a shorter interval (x0,z1) even
when it fails on the longer interval (r0,z1)).

This is the SAME obstruction as the BracketFormula-level sorry at EANegation.lean:1084
(the beta_0(r_0) case). The VecEA2 wrapper places endpointLeft at the fixed endpoint z0,
which avoids beta_0(r_0) for the ENDPOINT predicate. But the bracket's interior witnesses
remain existentially quantified, preserving the obstruction for the bracket negation's
forward direction.

**Resolution**: The model-DEPENDENT versions in EANegationClosure.lean are ALL sorry-free:
- `neg_interval_formula`: Lemma 5.1 forward (model-dependent)
- `neg_bounded_exists`: Cor 5.4 forward (model-dependent)  
- `neg_vecEA2`: Prop 4.2 single conjunct (model-dependent)
- `neg_2var_vec_ea`: Prop 4.2 full (model-dependent)

The downstream chain (KampPrior.lean) operates on SPECIFIC Prior structures, so
model-dependent negation closure is sufficient.

## Key Decisions

1. **EndpointNegation.lean succ sorry is NOT on the critical path**: The downstream
   KampPrior.lean sorry at line 136 only needs model-dependent negation closure.
2. **Plan revision needed**: Phases 2-4 should import from EANegationClosure.lean
   (model-dependent, sorry-free) instead of EndpointNegation.lean.
3. **EANegation.lean sorries (1084, 1235) are permanent**: These are genuine impossibilities
   at the BracketFormula level (documented). Not on critical path.

## Sorry Inventory

| # | File | Line | Status | Critical Path |
|---|------|------|--------|---------------|
| 1 | KampPrior.lean | 136 | Placeholder | YES |
| 2 | EndpointNegation.lean | 160 | Genuine obstruction | NO |
| 3 | EANegation.lean | 1084 | Permanent (impossible) | NO |
| 4 | EANegation.lean | 1235 | Permanent (impossible) | NO |

## Revised Strategy for Next Dispatch

1. **Revise plan** (or acknowledge deviation): Phases 2-4 use EANegationClosure.lean
2. **Phase 2 (ModelIndepNegation.lean)**: May be unnecessary if the chain goes through
   model-dependent versions. Or: implement as model-dependent wrapper using neg_2var_vec_ea.
3. **Phase 3 (FOToVEA.lean)**: Structural induction on FO formulas using IH + model-dependent
   negation closure from EANegationClosure.lean.
4. **Phase 4 (KampPrior.lean)**: Fill nf_characterizable_temporal_prior succ case using
   FOToVEA + RabinovichTranslation (translate_correct is sorry-free).

## References

- EndpointNegation.lean: obstruction analysis in succ case comment
- EANegationClosure.lean: sorry-free model-dependent chain (lines 237-566)
- EANegation.lean:1047-1084: impossibility analysis
- Plan: specs/305_rabinovich_ea_formula_implementation/plans/24_faithful-restructure.md
