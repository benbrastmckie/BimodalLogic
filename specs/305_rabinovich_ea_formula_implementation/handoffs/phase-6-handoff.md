# Phase 6 Handoff — Task 305 (BLOCKED)

## Immediate Next Action

Research dispatch to design the zone-3 gap-placement proof for `nvar_transfer_from_1var_agree` (PriorComposition.lean:459). The sub-problem: given w₂ in N from `cross_extend_bwd_1var` with matching depth-(K+1) 1-var type and w₂ > t', prove that a witness exists in (t', x') with the same type, using `semantic_prior_UZ` and the structural constraints from h_x.

## Current State

- **Phases 1-5**: COMPLETED (all sorry-free)
- **Phase 6**: BLOCKED — zone-3 gap-placement proof required
- **Build**: Clean (EANegationClosure.lean builds sorry-free)
- **Critical path sorries**: 6 (all in PriorComposition.lean, all from same sub-problem)
- **Non-critical sorries**: 3 (EANegation.lean x2, NfCharFormula.lean x1)

## Analysis Summary

Three approaches were investigated in this dispatch:

### Approach 1: Rewire KampBypass to VecEA2 (Plan's stated approach)
- Requires building VecEA2 from depth-(k'+2) 2-var NF
- The bracket segments would encode quantifier conditions
- At depth 0 this exists (nf_vecEA2_future in NfToVecEA.lean) but at higher depths it requires a major new construction mapping the NF's quantifier tree into BracketFormula structure
- Estimated: ~400 lines new infrastructure

### Approach 2: Fill sorry in nvar_transfer_from_1var_agree directly
- The general theorem (depth d, arbitrary arity r) requires zone-based analysis
- Zones 1,2,4,5 (outer zones) are tractable using cross_extend_bwd_1var
- Zone 3 (between-zone: t < w < x) is the blocker
- The IH at depth d gives full r-var agreement from 1-var agreements + order
- But establishing the ORDER of the witness relative to ALL env' components requires Prior-UZ squeeze

### Approach 3: Use exist_transfer_from_full_agree indirectly
- From depth-(K+1) 2-var agreement, get depth-K 3-var existential transfer (via quantifier part)
- But the goal is depth-(K+1) 3-var (not depth-K): one depth level short
- Cannot bridge the gap without the full transfer theorem

### Common Sub-Problem (All Three Reduce Here)
Given:
- `w₂ > t'` (from 2-var agreement ordering at [w,t]/[w₂,t'])
- `w₁ < x'` (from 2-var agreement ordering at [w,x]/[w₁,x'])
- w₂ and w₁ have same depth-(K+1) 1-var type (both match w)

Need: a single element w' with t' < w' < x' and matching 1-var type.

Solution sketch:
1. `char_fn (K+1) nf_w` is a temporal formula characterizing w's type (available from char_correct)
2. w₁ satisfies this formula and w₁ < x', so w₁ is in the interval (t'?, x')
3. If w₁ > t': use w₁ directly (it's in (t', x'))
4. If w₁ ≤ t': use semantic_prior_UZ on N with char_fn at t' in interval (t', something). Need to show existence in (t', x').
5. From hw₂: w₂ > t' and w₂ has matching type. If w₂ < x': use w₂.
6. The hard case: w₂ > x' AND w₁ < t'. Requires showing this is impossible via structural constraints.

## Key Decisions

1. Phase 6 is BLOCKED (not partial) because no code changes were made
2. The three approaches are theoretically equivalent — choosing one doesn't help without solving the core sub-problem
3. The most direct path forward is filling `nvar_transfer_from_1var_agree` (Approach 2) since it fixes ALL six sorries simultaneously

## Sorry Inventory

See `.orchestrator-handoff.json` for full inventory.

## References

- Plan: `specs/305_rabinovich_ea_formula_implementation/plans/06_vecEA2-negation-plan.md`
- Key files: `PriorComposition.lean` (sorries), `KampBypass.lean` (consumer), `EANegationClosure.lean` (Phase 4-5 output)
- Literature: Rabinovich 2014, Section 5 (interval splitting) — the gap-placement proof corresponds to the paper's claim that "on Dedekind complete chains, matching types + matching order implies matching quantifier conditions"
