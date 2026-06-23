# Phase 1 Handoff: Sorry Scope Narrowing

## Immediate Next Action
Revise plan v26 Phase 2 to implement the three-step resolution path for nf_exist_to_temporal_aux.

## Current State
- Phase 1 completed: FOToVEA.lean restructured
- Sorry narrowed from fo_to_temporal_correct (all MonadicFormula sig 1) to nf_exist_to_temporal_aux (depth-(k+1) arity-2 NF existentials)
- Build passes (1701 jobs)
- 4 sorry total in Kamp directory (1 critical path, 3 non-critical)

## Key Decisions
1. Deleted fo_to_temporal entirely (was placeholder with Formula.bot for quantifier cases)
2. Replaced with nf_exist_to_temporal_aux using Classical.choose
3. The sorry now has a clear decomposition into atom layer (sorry-free) + quantifier layer (sorry at depth > 0)
4. Previous handoff's model-independence claim was incorrect for the NF-direct approach

## Sorry Inventory
1. FOToVEA.lean:118 -- nf_exist_to_temporal_aux (CRITICAL PATH)
2. EndpointNegation.lean:160 -- non-critical
3. EANegation.lean:1084 -- non-critical
4. EANegation.lean:1235 -- non-critical

## Architecture Understanding (for next dispatch)

The arity tower problem is now well-characterized:
- Part B at depth k+1 needs temporal formula for ∃ x, nf_eval_nf M (k+1) 2 [x,t] sub_nf
- This involves quantifier conditions: ∃ y, nf_eval_nf M k 3 [y,x,t] snf3 (arity-3 at depth k)
- At depth 0: VecEADecomp handles arity 3 (897 lines, sorry-free)
- At depth k > 0: quantifier conditions involve arity 4 at depth k-1, etc.
- Full descent: (k+1,2) -> (k,3) -> (k-1,4) -> ... -> (0,k+3)
- Resolution: generalize depth-0 zone decomposition to arbitrary arity

Three-step resolution:
1. Wire existing VecEADecomp zones into temporal formula (~200 lines)
2. Generalize depth-0 zone decomposition to arbitrary arity (~500-800 lines)
3. Implement lexicographic (k,n) descent (~300 lines)
