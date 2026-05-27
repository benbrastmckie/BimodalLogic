# Phase 6A Handoff: GHR93 Proposition 7 Composition Lemma

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 6A
**Date**: 2026-05-27
**Session**: sess_1748393400_orch155
**Status**: PARTIAL -- scaffold compiles, core proof body sorry'd

## Current State

File: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` (169 lines)

### What Compiles

1. **Main theorem `ghr93_strategy_compose`**: Full structure (padding, Round 1, merge, Round 2 case-split, dispatch to `compose_wc` / `compose_wc_right`)
2. **`pivot_flip` lemma**: Derives `c < e ↔ d < e'` from `e < c ↔ e' < d` and `e = c ↔ e' = d`
3. **Type signature of `compose_wc`**: Takes both sub-strategies' winning conditions, produces merged winning condition
4. **Type signature of `compose_wc_right`**: Symmetric case for b from right strategy

### What Remains (3 sorry sites)

#### Sorry 1: `compose_wc` body (line 133)
- **Goal**: `ghr93_winning_condition n (game_tuple x y a b) (game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b')`
- **Available**: `hcond_L` (left winning condition), `hcond_R` (right winning condition), `hL_eq`, `hR_eq`, all interval bounds
- **Proof strategy**: For each component:
  - **same_order_type**: Per-pair case analysis on index ownership (LEFT or RIGHT). Both-LEFT uses hord_L, both-RIGHT uses hord_R, cross uses pivot_chain_order through c/d.
  - **gap_point_agreement**: Per-index dispatch to left or right sub-strategy
  - **formula_agreement**: Per-index dispatch to left or right sub-strategy
- **Key ownership classification**:
  - LEFT-owned: {0, left sel k (a(k) ≤ c), n+1} (since b ≤ c)
  - RIGHT-owned: {right sel k (a(k) > c), n+2}
- **For same-side pairs**: merged M-value = sub-game M-value, so sub-game's same_order_type applies directly
- **For cross pairs**: LEFT value ≤ c on M-side, RIGHT value ≥ c on M-side. Use left strategy at (i, n+2) to get (value < c ↔ value' < d), right strategy at (0, j) to get (c < value ↔ d < value'). Then pivot_chain_order.
- **Estimated effort**: 80-120 lines

#### Sorry 2: `compose_wc_right` body (line 163)
- Symmetric to `compose_wc` with LEFT/RIGHT ownership swapped:
  - LEFT-owned: {0, left sel k}
  - RIGHT-owned: {right sel k, n+1 (since c ≤ b), n+2}
- Can be implemented by copying compose_wc with appropriate modifications
- **Estimated effort**: 80-120 lines (or factor out common logic)

#### Sorry 3: Degenerate case (lines 90, 105)
- When [d, y'] or [x', d] has no points
- Need to show d = y' (both gaps), then all selections are on one side
- **Key argument**: If d = y' (gap), right strategy maps everything to {d}. If c < y, there exist M-points in (c, y], but their responses collapse to d. The right strategy's existence (h_right) implies all responses are d, so there's effectively no right-side differentiation. The proof reduces to showing the left strategy handles everything.
- **Estimated effort**: 40-60 lines per case

### Architecture Decisions

1. **Padding approach**: a_L(k) = a(k) when left, c when right. a_R(k) = c when left, a(k) when right. Key insight: merged M-selection = original a (since `if a(k) ≤ c then a(k) else a(k) = a(k)`).

2. **Point witness for other side**: Need both sub-strategies' winning conditions. When b' is on one side, find a point witness for the other side. Degenerate case when no witness exists.

3. **Pivot argument for cross-interval order**: Uses `pivot_chain_order` (already in CustomGame.lean) with c/d as pivot. This is the mathematically correct approach from GHR93.

4. **`where` clause pattern**: Helper lemmas defined as `where` clauses of the main theorem to avoid stack overflow from `where` blocks with too many implicit parameters.

### Detailed Proof Strategy for `compose_wc`

**Key insight**: merged M-side selection = original `a` (since `a_L(k) = a(k)` when left, `a_R(k) = a(k)` when right). The merged game tuple M-side is literally `game_tuple x y a b`, identical to the original.

**Index ownership classification** (b ≤ c case):
- LEFT-owned: {0 (x), left sel k where a(k) ≤ c, n+1 (b)}
- RIGHT-owned: {right sel k where a(k) > c, n+2 (y)}

**Property at each ownership**:
- LEFT-owned i: `game_tuple x y a b i = game_tuple x c a_L b i` (M-side match)
                  N-merged at i = `game_tuple x' d a'_L b' i` (N-side match)
- RIGHT-owned i: `game_tuple x y a b i = game_tuple c y a_R b_R i` (M-side match)
                   N-merged at i = `game_tuple d y' a'_R b'_R i` (N-side match)

**same_order_type proof (per pair):**
- Both LEFT: `rw [hM_left, hN_left]; exact hord_L i j`
- Both RIGHT: `rw [hM_right, hN_right]; exact hord_R i j`
- LEFT i, RIGHT j: `pivot_chain_order` with:
  - `hap`: LEFT_M(i) ≤ c (from interval bounds)
  - `hpb`: c ≤ RIGHT_M(j) (from interval bounds)
  - `ha'q`: LEFT_N(i) ≤ d, `hqb'`: d ≤ RIGHT_N(j)
  - `hlt_l, heq_l`: from `hord_L` at `(i, n+2)` (left game boundary = c/d)
  - `hlt_r, heq_r`: from `hord_R` at `(0, j)` (right game boundary = c/d)
- RIGHT i, LEFT j: reverse pivot (use `pivot_chain_order_rev`)

**gap_point_agreement**: dispatch per-index to left or right sub-strategy
**formula_agreement**: dispatch per-index to left or right sub-strategy

**omega fix**: When classifying indices, use `have hk : i.val - 1 < n := by omega` after establishing `1 ≤ i.val` and `i.val ≤ n` from the classification. Pass this explicitly when constructing `⟨i.val - 1, hk⟩ : Fin n`.

**b' ≤ d issue**: In the LEFT-RIGHT pivot, need `tN(n+1) ≤ d` i.e. `extendPoint b' ≤ d`. This comes from the `hb'd` hypothesis in the main theorem's left case. Need to pass this as an additional parameter to `compose_wc` or derive it internally.

### Next Steps (Priority Order)

1. Implement `compose_wc` body using the above strategy (~120-150 lines)
2. Copy to `compose_wc_right` (symmetric, swap LEFT/RIGHT ownership for n+1)
3. Handle degenerate case (no point in sub-interval)
4. Verify with `lake build`
5. Run `lean_verify` on `ghr93_strategy_compose`

### Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` (NEW, 169 lines)
- `specs/155_reynolds_pipeline_activation/plans/35_reynolds-pipeline-plan.md` (Phase 6A: [IN PROGRESS])
