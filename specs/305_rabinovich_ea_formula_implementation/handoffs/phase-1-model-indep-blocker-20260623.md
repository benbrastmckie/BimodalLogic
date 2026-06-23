# Phase 1 Handoff: Model-Independent Biconditional Blocker

## Immediate Next Action
Revise plan v21 to bypass the model-independent biconditional (`neg_bracket_is_vbracket` S1, `neg_partialBracketExist_is_vbracket` S2) and instead prove `prior_2var_transfer_until/since` directly using the model-dependent negation closure (EANegationClosure.lean, already sorry-free).

## Current State
- Phase 1 BLOCKED
- Zero phases completed
- Zero sorries resolved
- Build passes (no regressions)

## Key Findings

### Finding 1: S1 and S2 are Unused Downstream
`neg_bracket_is_vbracket` and `neg_partialBracketExist_is_vbracket` are declared in EANegation.lean but referenced nowhere else in the codebase. They are mathematical infrastructure theorems with no downstream consumers.

### Finding 2: Actual Downstream Blockers are Independent
The real blockers for completeness are `prior_2var_transfer_until/since` in PriorComposition.lean (used at KampBypass.lean:646,713). These transfer 2-var NF agreement between models using 1-var agreement at each variable. This is fundamentally about NF decomposition and temporal characteristic formulas, NOT about model-independent V-bracket negation closure.

### Finding 3: Model-Independent Biconditional is Fundamentally Harder
The model-independent theorem `exists v, forall M, v.holds M ↔ neg bf.holds M` requires a FIXED finite V-bracket that works for ALL models. In the beta_0(r0) case:

- `neg bf.holds(z0, z1)` decomposes as `neg rp.holds(r0, z1) AND neg bf.holds(r0, z1)`
- The second conjunct is the SAME theorem on a smaller interval
- The V-bracket would need self-referential disjuncts (prepend of itself)
- This creates an infinite structure that cannot be finitely represented

The model-DEPENDENT version (`neg_interval_formula`, sorry-free in EANegationClosure.lean) avoids this by taking `neg bf.holds` as INPUT and constructing the V-bracket for THAT specific model, allowing the recursive chain to terminate naturally.

### Finding 4: EndpointBracketFormula Does Not Resolve the Issue
Placing alpha_0 at the endpoint (as in Rabinovich's notation) eliminates the universal over alpha_0 points, but:
- The inner bracket negation still requires `neg_bracket_is_vbracket` at the SAME size
- The F-chain approach for Cor 5.4 has a genuine backward-direction failure: Until witnesses can escape the interval
- Verified via counterexample on integers: orderedPointsExist(fChain) does NOT imply partialBracketExist on discrete orders

## Recommended Revised Strategy

### Option A: Direct Prior Transfer (Recommended)
Prove `prior_2var_transfer_until/since` by decomposing `nf_eval_nf M (K+2) 2 env sub_nf` into:
1. Atom part: already handled by `nonconstenv_atom_agree_until/since` (sorry-free)
2. Quantifier part: for each existential condition `exists w, chi(x,t,w)`:
   - Zone 1-2 (w <= t or w = t): transfer via h_t at depth K+2
   - Zone 3 (t < w < x for Until): express chi as temporal formula A via `char_correct` at depth <= K+1, transfer A via `h_t`
   - Zone 4-5 (w >= x or w = x): transfer via h_x at depth K+2

Key infrastructure: `char_correct` at depth <= K+1 gives temporal formula equivalence. Combined with 1-var agreement at depth K+2 and `nf_eval_nf` structure at depth K+1 arity 1 (which is the quantifier body), this should close the gap.

### Option B: Well-Founded Induction (Alternative)
If the model-independent biconditional is still desired for mathematical completeness, it may require:
- Well-founded induction on the interval using Dedekind completeness
- Or a topological argument about the set of alpha_0 points
This is significantly harder and not needed for the downstream completeness result.

## Sorry Inventory
No changes from previous state:
- EANegation.lean:1047 (`neg_bracket_is_vbracket` backward, beta_0(r0) case)
- EANegation.lean:1172 (`neg_partialBracketExist_is_vbracket` backward)
- PriorComposition.lean:131 (`prior_2var_transfer_until`)
- PriorComposition.lean:162 (`prior_2var_transfer_since`)

## References
- Report 20: `specs/305_rabinovich_ea_formula_implementation/reports/20_eanegation-sorry-analysis.md`
- Plan v21: `specs/305_rabinovich_ea_formula_implementation/plans/21_eanegation-sorry-fix.md`
- EANegationClosure.lean: Model-dependent negation closure (sorry-free)
- KampBypass.lean:646,713: Downstream uses of prior_2var_transfer
