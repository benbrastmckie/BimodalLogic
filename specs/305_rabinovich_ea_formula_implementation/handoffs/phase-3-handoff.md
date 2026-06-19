# Phase 3 Handoff: Corollary 5.4 -- Partial Bracket Negation

## Immediate Next Action
Implement Phase 4 (Lemma 5.1 -- full bracket negation closure by induction on n).

## Current State
- Phase 3 completed with 4 sorry-free theorems + 1 sorry (biconditional)
- Build passes: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegation` clean
- 2 sorries total: `splitAt_combine` (Phase 1, VecEAFormula.lean:487) + `neg_partialBracketExist_is_vbracket` (EANegation.lean:764)

## Key Decisions

### F-Chain Design
- `BracketFormula.fChainFrom` uses well-founded recursion on `n - i.val` (distance from right end)
- Base case: `F_n = alpha_n AND (beta_{n+1} Until top)` -- encodes last segment via Until
- Step case: `F_i = alpha_i AND (beta_{i+1} Until F_{i+1})` -- chains segment types via Until
- First segment `beta_0` is NOT absorbed into the F-chain; handled separately as prefix condition

### Bounded vs. Unbounded Until
- The F-chain uses temporal Until which is UNBOUNDED (witnesses can escape the interval)
- Forward direction proved: bracket(z_0, z) implies orderedPointsExist 1 F_0 z_0 z
- Reverse direction NOT proved: orderedPointsExist 1 F_0 z_0 z_1 does NOT imply exists z, bracket(z_0, z) on general structures (Until witnesses may go past z_1)
- On Prior structures, the reverse MAY hold via HasAttainedINF, but requires careful argument
- Full biconditional deferred to Phase 4 or later dispatch

### Phase 4 Independence
- Phase 4 (Lemma 5.1) may NOT actually need Corollary 5.4 -- the three-case decomposition of bracket negation uses induction on n with splitAt, not partial brackets
- Corollary 5.4 may be needed for Phase 6 (rewire) or for alternative proof paths
- The `neg_partialBracketExist_sufficient` theorem provides the useful one-directional version

## Sorry Inventory
1. `VecEAFormula.lean:487` -- `theorem BracketFormula.splitAt_combine` (Phase 1 deferred)
2. `EANegation.lean:764` -- `theorem neg_partialBracketExist_is_vbracket` (biconditional, needs Lemma 5.1)

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- added F-chain definitions and proofs (~250 lines)
- `specs/305_rabinovich_ea_formula_implementation/plans/01_ea-formula-plan.md` -- Phase 3 marked [COMPLETED]
