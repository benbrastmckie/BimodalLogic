# Phase 4: X-Content Propagation and Until/Since Persistence — Results

**Status**: PARTIAL
**Date**: 2026-04-03

## Sorries Closed (2)

### 1. `until_witness_seed_consistent` (WitnessSeed.lean)
- **Previous state**: Sorry at line 469, proof stalled at Step 4 with wrong axiom shape
- **Root cause**: Code built `G((phi AND bot) -> G(bot))` for the OLD non-strict `until_induction` shape. Under strict semantics, `until_induction(phi, psi, bot)` requires `G((phi AND X(bot)) -> bot)` where `X(bot) = bot U bot`.
- **Fix**: Replaced Steps 1-4 with:
  1. Derive `(phi AND X(bot)) -> bot` from `X_bot_absurd` via conjunction elimination
  2. G-necessitate to get `G((phi AND X(bot)) -> bot)` as a theorem
  3. Form conjunction `G(neg psi) AND G((phi AND X(bot)) -> bot)` in M
  4. Apply `until_induction(phi, psi, bot)` to get `(phi U psi) -> X(bot)` in M
  5. Chain with `X_bot_absurd` to get `bot in M`, contradicting MCS
- **Verification**: `lean_verify` shows no `sorryAx`

### 2. `since_witness_seed_consistent` (WitnessSeed.lean)
- **Previous state**: Sorry at line 577, symmetric to the Until case
- **Fix**: Symmetric using `since_induction(phi, psi, bot)`, `Y_bot_absurd`, and `past_necessitation`
- **Verification**: `lean_verify` shows no `sorryAx`

## Structural Blocker Discovered

### Until Persistence Under Strict Semantics

The core DovetailedChain sorries (`forward_dovetailed_until_persists`, `backward_dovetailed_since_persists`, `DovetailedFMCS_forward_F`, `DovetailedFMCS_backward_P`, and the propagation lemmas) are blocked by a **fundamental structural limitation** of the forward_step construction.

**Problem**: Under non-strict semantics, `until_unfold` gave `psi OR (phi AND G(phi U psi))`, where `G(phi U psi)` propagates through `g_content`. Under strict semantics, `until_unfold` gives `X(psi OR (phi AND (phi U psi)))`, producing an X-formula (not a G-formula). The X-content does NOT propagate through g_content.

**Why X-content is not G-liftable**: For `alpha in x_content(M)` (i.e. `X(alpha) in M`):
- `X(alpha) -> F(alpha)` by `next_implies_some_future`, so `F(alpha) in M`
- But `G(alpha) in M` does NOT follow -- X says "next step", G says "all future steps"
- The G-lift consistency argument for `temporal_theory_witness_with_g_exists` requires ALL seed elements to be G-liftable
- F-formulas are not G-liftable either (`F(phi) -> G(F(phi))` is not valid)

**Consequence**: The forward_step construction preserves `g_content(M) subset W` but does NOT preserve Until formulas, X-content, or F-content. The `forward_dovetailed_until_persists` theorem (Until persistence from chain(n) to chain(n+1)) cannot be proven with the current chain construction.

**Impact on `DovetailedFMCS_forward_F`**: The standard argument is: `F(psi) in chain(t)` gives `(top U psi) in chain(t)` by F_until_equiv; Until persists through the chain until fair scheduling resolves it. Without Until persistence, this argument fails.

### `until_persists_through_succ` (SuccRelation.lean)

Also blocked. Under strict semantics, the `psi in v` subcase of the f_step propagation fails because `psi -> (phi U psi)` is NOT valid (no strictly future witness). Updated the theorem with additional `h_mcs_v` hypothesis and detailed docstring explaining the blocker.

## Possible Resolutions (for future work)

1. **Enrich the forward_step seed**: Add Until/X content to the seed and find a new consistency argument (not G-lift based). Requires a fundamentally new proof technique.

2. **Restructure the chain construction**: Build a chain that explicitly tracks and resolves Until obligations at each step, not just F-obligations.

3. **Use a different completeness argument**: The boxClassFamilies approach (UltrafilterChain) may provide forward_F at the family level without needing same-chain Until persistence.

4. **Semantic/algebraic bypass**: Use the truth lemma (Phase 5) in conjunction with model-theoretic arguments to prove forward_F without syntactic Until persistence.

## Files Modified
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — 2 sorries closed (until/since seed consistency)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — Updated `until_persists_through_succ` with blocker documentation

## Build Status
- `lake build` passes (940 jobs, 0 errors)
- WitnessSeed.lean: 0 sorries (was 2)
- DovetailedChain.lean: 6 sorries remain (structural blocker)
- SuccRelation.lean: 1 sorry remains (structural blocker)
