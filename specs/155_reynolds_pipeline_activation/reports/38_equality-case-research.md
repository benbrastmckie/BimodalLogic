# Phase 3C-UBA Equality Case: Research Report

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: GHR93 selection distinctness requirements, equality case resolution, depth-agreement gap

---

## 1. GHR93 Requires Strictly Increasing Selections

From `reports/22_claim1-case2-literature.md` line 19:
> "Spoiler (in the backward game) chooses n+1 points x' < alpha_0 < ... < alpha_n < y' in N_r."

This is **strictly increasing** — all selections are distinct and ordered. GHR93 never considers duplicate selections. The `a_0 < a_1 < ... < a_n` convention is standard in Ehrenfeucht-Fraïssé games and is used consistently throughout GHR93 Section 8.

From `reports/08_ghr93-game-theory.md` line 310:
> "Suppose Spoiler chooses n+1 points x' < a_0 < ... < a_n < y'"

## 2. Lean Game Definition Allows Non-Injective Selections

`CustomGame.lean:285-303`:
```lean
def ghr93_duplicator_wins ... : Prop :=
  ∀ (a : Fin n → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a i)) →
    ∃ (a' : Fin n → ExtendedCarrier N atomMap r), ...
```

No `Function.Injective a` or `StrictMono a` constraint. Spoiler may pick duplicates.

## 3. Mathlib Infrastructure

### Tuple.sort
- `Tuple.sort a_bwd` returns `Equiv.Perm (Fin n)` (already used at CaseAnalysis.lean:4387)
- `Tuple.monotone_sort a_bwd : Monotone (a_bwd ∘ σ)` (already used at line 4391)
- `Equiv.Perm` is a bijection, hence injective: if `a_bwd` is injective, `a_bwd ∘ σ` is injective

### StrictMono from Monotone + Injective
```
Monotone.strictMono_of_injective : Monotone f → Function.Injective f → StrictMono f
```
Available from `Mathlib.Order.Monotone.Defs`. If `a_sorted` is both monotone and injective, it is strictly monotone, giving `a_init(k) < p_n` for all k < n.

### ghr93_winning_condition_perm
`CustomGame.lean:1591` — preserves winning condition under permutation. Already wired up.

## 4. Equality Case Analysis

When `a_init(k) = extendPoint p_n` (Spoiler picked duplicates):
- `sel_pn_ord` biconditional: `False ↔ True` when resp_tau(k) < e_n. BREAKS.
- Resolution: **modify the response function** — when `a_init(k) = p_n`, respond with `e_n` instead of `resp_tau(k)`.
- After modification: `a_init(k) = p_n` and `a'_resp(k) = e_n`, so `sel_pn_ord` becomes `False ↔ False` and `True ↔ True`. Holds.
- Winning condition: `e_n` has rank-r agreement with `p_n` (from forward game), same gap/point status.

## 5. The Depth-Agreement Gap (Fundamental Tension)

### GHR93's Approach
GHR93 uses B = X_{alpha_n} — the **full rank-r type formula** (conjunction of ALL depth-r temporal formulas true at alpha_n). Properties:
- `stavi_depth(B) = r`
- U(B, sf_top) has rank r+1
- tau in GHR93 is at rank r+4, so r+1 ≤ r+4: transfer works
- Witness z satisfying B has **full rank-r agreement** with alpha_n

### Lean Code's Situation
- `char_k` characterizes NormalForm at depth k_nf with `stavi_depth(char_k nf) + 2 ≤ r`
- U(char_k nf, sf_top) has depth ≤ r: transfers through tau at rank r ✓
- BUT witness z only has **k_nf-depth agreement** with p_n (NOT rank-r)
- Winning condition REQUIRES rank-r agreement → k_nf-depth is insufficient

### Why the Full Rank-r Type Formula Cannot Be Used
`nf_characterizable_by_stavi` builds formulas with depth ~2k:
- `stavi_depth(char_0 nf) ~ 1`
- `stavi_depth(char_k nf) ~ 2k + 1` (each level adds ~2 via std_untl)

For k = r: `stavi_depth(char_r nf) ~ 2r + 1`.
Then U(char_r, sf_top) ~ 2r + 3.
Transfer requires: 2r + 3 ≤ r + 2 (for tau_r2). Impossible for r ≥ 1.

### Available Game Ranks
| Game | Rank | Source |
|------|------|--------|
| tau | r | SplitPointProps.tau |
| tau_r2 | r+2 | h_ih_r2 + h_r1_univ (CaseAnalysis.lean:1459) |
| forward | r | SplitPointProps.h_fwd_n1 |
| forward_r2 | r+2 | h_fwd_r1 |

None support transfer of depth-2r formulas.

### GHR93 vs Lean Rank Comparison
| | GHR93 | Lean |
|---|---|---|
| Forward game | rank r+4(n+1) | rank r |
| tau | rank r+4 | rank r |
| B = X_{alpha_n} depth | r | k_nf (~r/4 or less) |
| U(B,A) depth | r+1 | ≤ r (with char_k) |

GHR93's higher forward game rank (r+4(n+1)) provides the slack for the full rank-r type formula.

## 6. Resolution Paths

### Path A: Degenerate Elimination + Modified Response (RECOMMENDED)

Handle the equality case separately, then for the strict case use the forward game for e_n:

1. **Case split** on each k: `a_init(k) < p_n` or `a_init(k) = p_n`
2. **Equality case** (a_init(k) = p_n): respond with e_n. Winning condition holds trivially.
3. **Strict case** (a_init(k) < p_n): still need `resp_tau(k) < e_n`.

For the strict case, we need an ADDITIONAL argument. Options:
- (a) Prove it from U(char_k, sf_top) transfer: get witness z > resp_tau(k), then show e_n ≥ z
- (b) Show that k_nf-depth agreement + interval containment implies rank-r agreement (bridging via completeness theorem)
- (c) Construct e_n from U(char_k, sf_top) AND separately establish rank-r agreement via a sub-game

### Path B: Increase Game Ranks to Match GHR93

Restructure the induction to use rank r+4(n+1) for the forward game and rank r+4 for tau:
- Would allow full rank-r type formula B = X_{alpha_n}
- Requires changing `game_depth` function and propagating through the entire proof
- Very large scope (~1000+ lines of changes)
- Most faithful to GHR93

### Path C: Strategy Composition (Phase 6E)

Implement Proposition 12.8.18 to compose sub-interval strategies:
- Avoids sel_pn_ord entirely
- Mathematically cleanest
- ~500 additional lines
- Decouples tau responses from e_n ordering

### Path D: k_nf-to-r Agreement Bridge

Show that if z satisfies `char_k(nf_pn)` (same k_nf-type as p_n) and z is in interval [c,y], then z and p_n agree on ALL rank-r Stavi formulas. This would follow from:
- `nf_characterizable_by_stavi` at depth k_nf gives a StaviFormula
- The completeness theorem at depth k_nf says same-k_nf-type implies Duplicator wins a game
- The game's winning condition includes rank-r formula agreement
- But the game between z (in M) and p_n (in N) needs matching endpoints

This is speculative and needs careful verification.

## 7. Risk Assessment

| Path | Faithfulness to GHR93 | Scope | Risk |
|------|----------------------|-------|------|
| A (degenerate elim) | Medium | 200-400 lines | Medium: strict case needs bridging argument |
| B (increase ranks) | Highest | 1000+ lines | High: cascading changes |
| C (composition) | Medium | 500 lines | Low: well-understood mathematics |
| D (k_nf-to-r bridge) | Medium | 100-200 lines | High: speculative, may not work |

## 8. Concrete Implementation Recommendation

**Immediate action**: Implement the modified response function for the equality case (20-40 lines). This is correct and unblocked regardless of which path is chosen for the strict case.

**For the strict case**: Path C (composition) is the safest. Path D (bridge) is worth investigating first as it's lower scope. Path B is the most faithful but highest risk.

The key insight: GHR93's proof works because its game ranks are much higher than the Lean code's. The Lean code's tighter rank bounds create a fundamental depth-agreement gap that requires either (a) increasing ranks, (b) finding a bridge argument, or (c) restructuring to avoid the problematic lemma.
