# Blocker Analysis: Task 199 Grid Order Tactic

## Summary

3 goals remain at the sorry on line 1985 of CaseAnalysis.lean. Goal 3 (sel vs p_n) is fixable with a targeted rewrite. Goals 1-2 (b_resp vs p_n) represent a genuine proof gap requiring structural changes.

## Goal Analysis

### Goal 1: b_resp < p_n ↔ b_sp < e_n

**Hypotheses (key)**:
- `h✝⁴ : ↑i✝ = n + 1 + 1` (i indexes b_resp slot)
- `h✝ : ¬↑j✝ - 1 < n` (j indexes p_n slot, after hab_eq rewrite)

**Goal**:
```
⊢ (extendPoint b_resp < extendPoint p_n ↔ extendPoint b_sp < e_n) ∧
    (extendPoint b_resp = extendPoint p_n ↔ extendPoint b_sp = e_n)
```

**Status**: UNPROVABLE from current hypotheses.

**Root cause**: `pivot_chain_order'` requires a linear chain `a ≤ p ≤ b`, but we have a fan: `d ≤ b_resp` AND `d ≤ p_n` with d at the bottom. In Case A, `b_resp ∈ [x', d]` so `b_resp ≤ d ≤ p_n` forms a valid chain. In Case B, `b_resp ∈ [d, y']` so both b_resp and p_n are above d.

**Why pivot_chain_order' fails**: Error message confirms:
```
Application type mismatch: The argument tau_d_b
has type (d < b_resp ↔ c < b_sp)
but is expected to have type (b_resp < d ↔ b_sp < c)
```
Lean infers `a := b_resp, p := d, b := p_n` from `hb_resp_in.1 : d ≤ b_resp`, which reverses the chain direction.

**Fan order counterexample**: d=0, a=1, b=2, c=0, a'=2, b'=1. All hypotheses hold but conclusion fails (1<2 but 2>1).

### Goal 2: p_n < b_resp ↔ e_n < b_sp

Same as Goal 1 with sides swapped. Same root cause.

### Goal 3: sel(i) vs p_n (unrewritten a_bwd)

**Hypotheses (key)**:
- `h✝¹ : ↑i✝ - 1 < n` (i indexes a sel position)
- `h✝ : ¬↑j✝ - 1 < n` (j indexes p_n position)

**Goal** (after game_tuple expansion but hab_eq rewrite FAILED):
```
⊢ (a_bwd ⟨↑i✝ - 1, ⋯⟩ < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ resp_tau ⟨↑i✝ - 1, ⋯⟩ < e_n) ∧
    (a_bwd ⟨↑i✝ - 1, ⋯⟩ = a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ resp_tau ⟨↑i✝ - 1, ⋯⟩ = e_n)
```

**Status**: FIXABLE.

**Root cause**: The `try rw [hab_eq _ _ (by assumption)]` on lines 1810-1811 targets the FIRST `a_bwd` occurrence (the i-side). Since `i-1 < n`, `hab_eq` requires `¬(i-1 < n)` which is false, so the rewrite silently fails. The SECOND `a_bwd` (j-side, where `¬(j-1 < n)`) never gets rewritten because `rw` always matches left-to-right.

**Fix**: Use `conv` to target the second `a_bwd` occurrence before applying `sel_pn_ord`:
```lean
| (conv in a_bwd ⟨↑j✝ - 1, _⟩ => rw [hab_eq _ _ (by assumption)]
   convert sel_pn_ord ⟨_, ‹_›⟩ using 3
   <;> (congr 1; exact Fin.ext (by omega)))
```
Or more robustly, rewrite the j-side via `show`:
```lean
| (rw [show (a_bwd ⟨↑j✝ - 1, _⟩ : ExtendedCarrier N atomMap r) = extendPoint p_n
       from hab_eq (↑j✝ - 1) _ ‹¬↑j✝ - 1 < n›]
   convert sel_pn_ord ⟨_, ‹_›⟩ using 3
   <;> (congr 1; exact Fin.ext (by omega)))
```

## Structural Analysis

### Why Case A Works but Case B Doesn't

| Property | Case A | Case B |
|----------|--------|--------|
| b_resp interval | [x', d] | [d, y'] |
| Chain for pivot | b_resp ≤ d ≤ p_n ✓ | d ≤ b_resp, d ≤ p_n (fan) ✗ |
| pivot_chain_order' | Valid chain | Invalid fan |

### Available Ordering Hypotheses

- `tau_d_b : (d < b_resp ↔ c < b_sp)` — from tau game
- `hord_cd_en_pn : (c < e_n ↔ d < p_n)` — from big game cross-boundary
- `hd_le_pn : d ≤ p_n` and `hb_resp_in.1 : d ≤ b_resp` — fan from d
- NO hypothesis connecting b_resp and p_n directly

### Why No Existing Hypothesis Connects b_resp and p_n

- `b_resp` comes from `hwin_tau` (tau game response to `b_sp` challenge)
- `p_n` comes from `a_bwd ⟨n, _⟩` (the backward chain's last element)
- `e_n` comes from `hwin_big` (big game response to `p_n` challenge)
- `b_sp` is the original M-side challenge point
- The tau game encodes orderings within {d, sel, b_resp, y'} vs {c, resp_tau, b_sp, y}
- The big game encodes orderings within {x, a_pad_big, e_n, y} vs {x', a'_big, p_n, y'}
- Neither game contains BOTH b_resp and p_n

## Proposed Solutions for Goals 1-2

### Option A: Additional Big Game Challenge (Recommended)

After obtaining `b_resp` from the tau game, challenge `hwin_big` again with `b_resp`:
```lean
obtain ⟨b_M, hb_M_in, hcond_bresp⟩ := hwin_big b_resp ⟨hb_resp_in.1, ...⟩
```
This gives `same_order_type` for the big game with `b_resp` as b-point on N side and `b_M` on M side. From this, we can extract `b_resp vs p_n ↔ b_M vs e_n` (since p_n is b-point in the `hord_big` game, and we can relate via indices).

However, we'd then need `b_M = b_sp` or at least `b_M vs e_n ↔ b_sp vs e_n`, which requires further work.

### Option B: Restructured Padding

Modify `a_pad_big` to encode `b_sp` at one of the padding positions (currently all padding maps to `c`). Then the big game's `same_order_type` would directly relate `b_sp` vs `e_n` to the corresponding N-side position vs `p_n`. This would require changing the padding construction upstream.

### Option C: Double-Challenge Construction

Use TWO big game challenges:
1. Challenge with `p_n` → get `e_n_pt` (already done)
2. Challenge with `b_resp` → get some `b_M`
Then use the big game's ordering between `b_resp` and `p_n` (indices in N-side game tuple) to derive the ordering between `b_M` and `e_n_pt`.

### Option D: Use same_order_type_of_between (if available)

If there exists a lemma that derives ordering from interval containment and game structure, that might close the gap without restructuring.

## Recommendation

1. **Fix Goal 3 immediately** — it's a simple `conv` rewrite fix
2. **Goals 1-2 require proof-level restructuring** — this is beyond tactic-level fixes and needs changes to the Case B construction to introduce an additional game challenge or restructured padding
3. **This should be escalated** as a blocked task requiring mathematical insight into the proof strategy
