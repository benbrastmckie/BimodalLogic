# Phase 3 Handoff: Sorry Site Closure (v3)

## Session
- **Session ID**: sess_1779640471_03278b
- **Date**: 2026-05-26
- **Agent**: lean-implementation-agent

## Status: PARTIAL (in progress, not blocked)

### Summary

The Phase 3 sorry sites are NOT mathematically blocked -- the ordering IS derivable via existing `pivot_chain_order_rev'` / `pivot_chain_order'` infrastructure. The sole blocker is a Fin subtype proof mismatch between `Fin (n+1)` and `Fin n` representations in the `same_order_type_grid` dispatch.

### Key Discovery

**`change` tactic resolves the Fin mismatch**. Verified via `lean_multi_attempt`:

```lean
change (y' < a_init ⟨_, ‹_›⟩ ↔ y < resp_tau ⟨_, ‹_›⟩) ∧
       (y' = a_init ⟨_, ‹_›⟩ ↔ y = resp_tau ⟨_, ‹_›⟩)
```

This succeeds on Goal 1 (y' vs sel), confirming `a_bwd ⟨k, proof_n_plus_1⟩` is definitionally equal to `a_init ⟨k, proof_n⟩`.

### What Was Accomplished

1. **Sorry Site #1 (Case A, line 1569)**: The `change`-based approach closes Goal 1 (y' vs sel) and Goal 3 (p_n vs sel) successfully. Goal 2 (sel(i=p_n) vs sel(j)) needs `change` on the i-side plus `hab_eq` rewrite on the j-side. The correct argument order for `pivot_chain_order_rev'` needs verification.

2. **Sorry Site #2 (Case B, line 1679)**: Full `same_order_type_grid` dispatch written with:
   - Sigma instantiation for `sig_x_d : (x' < d ↔ x < c)` via `props.sigma`
   - Degenerate case handling via `props.h_pt_xc`
   - All tau ordering extractions (`tau_d_b`, `tau_d_y'`, `tau_b_y'`, `tau_d_sel`, `tau_sel_b`, `tau_sel_y`, `tau_sel_sel`, `tau_b_sel`)
   - Grid dispatch matching Case A pattern
   - Same `change`-based Fin normalization for remainder goals

3. **Sorry Site #3 (line 1710)**: Confirmed dead code. Not live.

### Remaining Issue: pivot_chain_order argument direction

For Goals 2 and 3, `pivot_chain_order_rev'` expects:
```
(hpa : p ≤ a) (hbp : b ≤ p) (hqa' : q ≤ a') (hb'q : b' ≤ q)
(hord_l : (p < a ↔ q < a') ∧ ...) (hord_r : (b < p ↔ b' < q) ∧ ...)
→ (a < b ↔ a' < b')
```

For Goal 3 (`extendPoint p_n < a_init k ↔ e_n < resp_tau k`):
- `a = extendPoint p_n`, `b = a_init k` -- need `a < b`
- With pivot `p = d`, `q = c`: `p ≤ a` = `d ≤ p_n` (hd_le_pn), `b ≤ p` = `a_init k ≤ d` -- BUT we have `d ≤ a_init k`!

This means the fork geometry (d ≤ both p_n and a_init k) doesn't directly fit `pivot_chain_order_rev'`. The working instances at lines 1464-1473 use different pivots (e.g., `h_no_split` + `le_trans` to create the right bound).

**Recommended approach for successor**: Use `pivot_chain_order` (the non-prime version) which takes 4 separate iff components and may handle the argument direction differently, or derive a custom ordering lemma `sel_pn_ord_iff` from `hord_cd_en_pn` and `tau_d_sel` by manual iff construction (split into cases on `d < a_init k`, `d = a_init k`, `d < p_n`, `d = p_n` using the iff hypotheses).

### Immediate Next Action

1. For Goal 2 (Case A sel-vs-p_n): After `change`, manually construct the iff `(a_init k < extendPoint p_n ↔ resp_tau k < e_n)` from `tau_d_sel k` and `hord_cd_en_pn` by splitting on whether `d < a_init k` or `d = a_init k`, then using the cd ordering to transfer.

2. For Goal 3 (Case A p_n-vs-sel): Same approach with reversed direction.

3. Copy solution to Case B.

### Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Sorry sites #1 and #2 (partial, build fails)

### Current Sorry Count

```
Line 413: pre-existing (not on critical path)
Line 1679: Case B sorry (our target, replaced with partial proof)
Line 1732: dead code inside block comment
Line 2650: Phase 5 S11 (not our target)
```

Original sorry at line 1569 (Case A) has been replaced with `change`-based proof that partially works but has argument direction issues.
