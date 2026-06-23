# Phase 2 Handoff: Segment-Type Decomposition Blocked

**Date**: 2026-06-23
**Session**: sess_1782241589_d5a9bc
**Phase**: 2 (Fix Segment-Type Decomposition)
**Status**: BLOCKED

## Immediate Next Action

Reconsider Phase 3 dependency on Phase 2. The three sorry in Phase 2 are NOT on the critical path. Phase 3 (model-independent Prop 4.2 + Prop 4.3) should be reformulated to bypass model-independent Lemma 5.1.

## Current State

- Phase 2 blocked: all three sorry are unfixable with current BracketFormula/VVecEA2 infrastructure
- No code changes made (analysis-only dispatch)
- Build status: clean (no modifications)
- Sorry count: unchanged (3 in EndpointNegation.lean + EANegation.lean, all non-critical-path)

## Key Decisions

### The Structural Obstruction (Confirmed)

The model-independent biconditional `v.holds <-> not vea.holds` for VecEA2 (n+1) requires a FIXED VVecEA2 `v` such that:
- Forward: v.holds -> not bracket.holds (for ALL models)
- Backward: not bracket.holds -> v.holds (for ALL models)

The backward direction constructs v using case analysis (which case applies depends on the model). The forward direction must show that EACH case's VVecEA2 disjunct, when it holds, implies the bracket fails for ALL possible witness configurations.

The obstruction: for any disjunct D that describes "there exists r in (z_0, z_1) with [conditions] and IH_negation on (r, z_1)", the forward argument must show the bracket fails for ALL witnesses x_0 in (z_0, z_1). The IH gives bracket.tail fails at (r, z_1), but bracket.tail might SUCCEED at (x_0, z_1) for x_0 > r.

### Segment-Type vs Point-Type

The plan proposed replacing point-type decomposition (splitting on first occurrence of pointTypes[0]) with segment-type decomposition (splitting on first failure of segmentTypes[0]). Analysis shows segment-type decomposition has the EXACT SAME forward-direction obstruction, just with different roles:
- Point-type: "exists r with alpha_0(r)" doesn't prevent bracket with x_0 > r
- Segment-type: "exists y with seg0.neg(y)" doesn't prevent bracket with x_0 < y

### Why Rabinovich's Proof Works (But Our Formalization Doesn't)

Rabinovich proves Lemma 5.1 at the FOMLO level, where universal quantification (`forall x_0, ...`) is available. The V-EA formula in his proof uses FOMLO quantifiers to express "for all possible witness positions." Our BracketFormula/VBracketFormula/VVecEA2 types only have existential structure (exists witnesses). The V-bracket formulas cannot express the required universal quantification needed for the forward direction.

### Critical Path Assessment

All three sorry files contain explicit documentation that they do NOT block completeness:
- `neg_vecEA2_is_vvecEA2` (EndpointNegation.lean:160): "This sorry is NOT on the critical path"
- `neg_bracket_is_vbracket` (EANegation.lean:1084): "Does NOT block completeness"
- `neg_partialBracketExist_is_vbracket` (EANegation.lean:1235): "Does NOT block the completeness proof"

No other file in the codebase references these three theorems.

## Recommended Path Forward

### Option A: Non-constructive Prop 4.2 (Recommended)

Build model-independent Prop 4.2 using a non-constructive argument:
1. Use the sorry-free model-dependent `neg_2var_vec_ea` (EANegationClosure.lean)
2. VVecEA2 is a countable type (lists of sigma types over BracketFormula)
3. For each model M, there exists v_M : VVecEA2 with v_M.holds iff not phi.holds
4. Since VVecEA2 types are built from the FIXED bracket types (not model data), the v_M actually only depends on which case applies (A, B1, B2, or B2+beta0)
5. The DISJUNCTION of all case formulas is model-independent
6. Use Classical.choice or decidability to select which disjuncts are relevant

This avoids the biconditional issue: instead of one VVecEA2 that is bicondionally equivalent, use a (potentially larger) VVecEA2 where each disjunct handles one case, and prove only that the disjunction covers all models.

### Option B: Bypass VecEA2 Level

Build Prop 4.3 directly at the MonadicFormula level using:
1. FOMLO negation is standard (just negate the formula)
2. Show every FOMLO formula is equivalent to a V-EA
3. The negation case: not(V-EA) is V-EA because FOMLO is closed under negation and V-EA = FOMLO over Dedekind complete chains

This is circular if Prop 4.3 IS the statement, but the NF infrastructure might provide a non-circular route.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| EndpointNegation.lean | 160 | neg_vecEA2_is_vvecEA2 succ case | Model-independent bracket negation | Forward-direction obstruction: universal over witness positions | Not on critical path; skip or Option A |
| EANegation.lean | 1084 | neg_bracket_is_vbracket beta_0 case | Same as above at BracketFormula level | Same structural obstruction | Not on critical path; skip |
| EANegation.lean | 1235 | neg_partialBracketExist_is_vbracket backward n+1 | F-chain contrapositive | orderedPointsExist -> partialBracketExist fails | Not on critical path; skip |

## References

- Rabinovich 2014 Lemma 5.1 (pp. 7-11): proved at FOMLO level with universal quantifiers
- EANegationClosure.lean: sorry-free model-dependent versions of Lemma 5.1, Cor 5.4, Prop 4.2
- EndpointNegation.lean:129-159: detailed analysis of VecEA2-level obstruction
- EANegation.lean:1047-1069: detailed analysis of BracketFormula-level obstruction
