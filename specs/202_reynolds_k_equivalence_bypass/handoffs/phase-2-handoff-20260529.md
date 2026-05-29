# Phase 2 Handoff: Restricted TC/BUC on Z — BLOCKED

## Current State
- Phase 1 COMPLETED: `henkin_bfmcs` (fc-parametric BFMCS on Int) built and verified sorry-free in `CanonicalModel.lean`
- Phase 2 BLOCKED: Restricted temporal coherence cannot be proved for the schedule-based chain

## Blocker Summary
The schedule-based chain (`int_chain_fc`, built via `fwd_succ_fc` / `bwd_pred_fc` using g_content + Lindenbaum) cannot guarantee F-resolution because:
1. `F(phi)` is NOT a G-formula, so it does NOT propagate through g_content
2. The Lindenbaum extension at each step is non-deterministic and can introduce `G(neg phi)`, permanently killing any future resolution of `F(phi)`
3. The plan's claim that `temp_future_derived` provides `F(phi) -> G(F(phi))` is incorrect: `temp_future_derived` gives `Box(phi) -> G(Box(phi))`, and `F(phi) -> G(F(phi))` is semantically invalid under strict temporal ordering

This is the SAME fundamental obstacle that killed plans v2, v3, and the original RootScopedChain.lean (archived to Boneyard).

## Key Decision
The plan v4 approach (direct completeness on Z via schedule-based chain) shares the same core limitation as all prior approaches. The ONLY working mechanism for F-resolution in this codebase is the chronicle's limit construction (counterexample elimination), which requires `succ_embed_surjective` to map witnesses back to integers.

## What Works
- `henkin_bfmcs` in CanonicalModel.lean: fc-parametric BFMCS on Int, sorry-free, all modal coherence properties (modal_forward, modal_backward, eval_family_mem) proved
- The BFMCS families use `shifted_bx_fmcs_fc` which has correct G/H propagation and box stability

## What Doesn't Work
- Restricted TC for the schedule-based chain (F-resolution blocked)
- Restricted FUC (Until forward direction, same root cause)
- Restricted BUC cannot be proved purely axiomatically for the Henkin chain either (needs chronicle's C4 property)

## Viable Next Steps
1. **Reflexive completeness + conservative extension (task 129)**: Under reflexive semantics, g_content(M) ⊆ M, so F-persistence follows trivially. Transfer to irreflexive via conservative extension.
2. **Modified chain with explicit F-resolution**: Build a chain that includes witnesses for all F-formulas in deferralClosure(root) at each step. Requires proving consistency of g_content(M) ∪ {phi | F(phi) in M, phi in deferralClosure(root)}.
3. **Abandon the schedule-based approach entirely**: Use the chronicle's `cantor_bfmcs_discrete` with its sorry-free BUC and prove TC/FUC via a different argument that doesn't need surjectivity.
