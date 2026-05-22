# D-Consistency Blocker: Root Cause Analysis and Resolution Strategy

**Task**: 155 (reynolds_pipeline_activation)  
**Date**: 2026-05-21  
**Focus**: Phase 1 blocker — interior case of `d_consistency_left` (line 1157) and `d_consistency_right` (line 1235)

---

## 1. Root Cause: Rank Mismatch Between Formalization and GHR93

### What GHR93 Says (Section 8, Claim 1, p.116)

> **Claim 1.** Consider a play of the game G_{m;r'}(M,xy; N,x'y') **for arbitrary r' > r**, m ≥ 1 in which Duplicator uses a winning strategy. Let Spoiler begin by choosing c plus m-1 other points, and let Duplicator's response to c be d (plus m-1 other points). Then d = d-bar.

> **Proof.** The rank r+1 formula C' = ¬C ∨ K⁻¬C satisfies M_r |= C'(c). Hence also N_r |= C'(d), so d ≤ d-bar. If d < d-bar then Spoiler can choose d' ∈ (d-bar, y') with N |= ¬C(d'). Duplicator has no winning response, contradiction. Hence d = d-bar.

**Key detail**: The proof uses a rank-(r+1) formula C', which is available because the game is at rank r' > r. The universal quantification "for arbitrary r' > r" comes from GHR93's hypothesis (**), which is quantified over ALL ranks.

### What Our Code Does

```lean
-- ExpressivenessGeneral.lean, line 1095
h_fwd : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y'
```

The forward strategy is at rank r (same as the carrier). The `ghr93_winning_condition` includes formula agreement at rank r only:

```lean
-- EFGames.lean, line 3393
∀ (i : Fin (n + 3)) (A : StaviFormula), stavi_depth A ≤ r → ...
```

### The Fundamental Gap

GHR93 freely shifts between ranks because M_r ⊆ M_{r'} (set inclusion). Our Lean code uses `ExtendedCarrier M atomMap r`, a **type** that depends on r. There is no embedding between different ranks. The game at rank r provides formula agreement only at rank r, which is **insufficient** for Claim 1's proof (which needs rank r+1).

**This is why all three approaches tried by the implementation agent failed**: they all attempted to prove d = t at rank r, where the formula information is too coarse to distinguish points with the same rank-r type.

---

## 2. Why the Gap Case Works But the Point Case Doesn't

### Gap Case (d is a gap): PROVABLE at rank r

Two r-definable gaps with identical rank-r Stavi formula truth values have identical cuts. In `ExtendedCarrier`, gaps are `Sum.inr g` where `g : Gap`, and a gap's identity IS its cut. So formula agreement at rank r forces `d = t` when both are gaps.

### Point Case (d is a point): UNPROVABLE at rank r

Two carrier points `p_d, p_t` can have identical rank-r types yet be distinct (e.g., in a dense order without definable structure, all interior points are indistinguishable at any finite rank). The Round 2 mechanism provides ordering information relative to specific carrier points in the game tuple, but this doesn't determine the identity of a point when there are multiple rank-r-equivalent points in the interval.

GHR93 resolves this by using rank r' > r, where higher-rank formulas can distinguish more points. Specifically, the rank-(r+1) formula C' = ¬C ∨ K⁻¬C pins the response to the infimum d-bar uniquely.

---

## 3. Analysis of hd_eq_an Usage

`hd_eq_an : d = a_bwd ⟨n, by omega⟩` is used 31 times in ExpressivenessGeneral.lean. The uses fall into three categories:

| Category | Lines | Pattern | Effect of d → hd_le_an |
|----------|-------|---------|------------------------|
| Contradiction (n=0) | 1825 | `props.hd_eq_an ▸ le_refl _` to get `d ≤ a_bwd(0)` | Works with `hd_le_an` directly |
| R-membership | 1836 | `not_lt.mpr (props.hd_eq_an ▸ le_refl _)` to put a_bwd(n) in R | Works with `hd_le_an` |
| Game tuple rewriting | 2949, 2973, 3055, 3078, ...(25 sites) | `rw [← hd_eq_an]` to replace `a_bwd(n)` with `d` in game tuples | **BREAKS** — cannot substitute without equality |

The 25 game-tuple rewriting sites are all in Case II, where `a_bwd(n)` appears at position n of the N-side game tuple and must match d/c at position n of the M-side game tuple. These require genuine equality, not just ≤.

---

## 4. GHR93 vs. Code Architecture in Case II

### GHR93 Case II (p.117)

- d-bar < α_n (strictly — all α_i lie in **(d-bar, y')**, open interval)
- Uses τ (backward strategy on [d-bar, y'] vs [c, y]) for α_0, ..., α_{n-1}
- Constructs e_n **fresh** using the formula U(B, A) and the backward strategy's formula transfer
- The response at position n is e_n (a freshly constructed point), NOT c
- d-bar ≠ α_n in general

### Our Code Case II (line 2835)

- d = a_bwd(n) (equality, not strict inequality)
- Uses τ for positions 0, ..., n-1
- Puts c at position n: `a'_resp(n) = c`
- Then rewrites `a_bwd(n)` to `d` via hd_eq_an to make game tuples match

**The code conflates d with a_bwd(n)**, which is architecturally different from GHR93 where d-bar is the infimum and α_n is strictly above it. This conflation made d_consistency seem necessary (to prove the forward strategy responds with a_bwd(n) at position n), when GHR93's approach doesn't need it.

---

## 5. Recommended Resolution: Infimum Redefinition + Case II Restructuring

### Overview

Redefine d as the infimum of continuation_set (matching GHR93) and restructure Case II to construct e_n fresh (matching GHR93), eliminating the need for d_consistency and hd_eq_an.

### Step-by-step Plan

**Step 1: Redefine d in obtain_split_point_props (60-100 lines)**

Replace:
```lean
let d := a_bwd ⟨n, by omega⟩
have hd_eq_an : d = a_bwd ⟨n, by omega⟩ := rfl
```

With: d = infimum of `continuation_set x' y' (a_bwd ⟨n, by omega⟩)`. Use existing infrastructure:
- `continuation_set_nonempty` (line 162)
- `continuation_set_upward_closed` (line 174)
- `infimum_gap` / point infimum case (line 377)
- `infimum_gap_r_definable` (line 904)

Prove: `hd_le_an : d ≤ a_bwd ⟨n, by omega⟩` (infimum ≤ member, since `a_n_in_continuation_set` puts a_bwd(n) in the set).

**Step 2: Change SplitPointProps (10 lines)**

```lean
-- Replace:
hd_eq_an : d = a_bwd ⟨n, by omega⟩
-- With:
hd_le_an : d ≤ a_bwd ⟨n, by omega⟩
```

**Step 3: Fix Case I (10-20 lines)**

Case I uses hd_eq_an at 2 sites (lines 1825, 1836) for contradiction and R-membership. Both work directly with hd_le_an (need ≤, not =).

**Step 4: Eliminate d_consistency_left/right (remove ~160 lines)**

Strategy restriction no longer needs d_consistency. Instead, use a new argument:

The infimum d has the property that for any carrier point p ∈ (d, y') ∩ N, `cont_holds` holds at p. When we play the forward strategy with all picks ≤ c, the Round 2 transfer argument shows: each carrier point above the response t maps to a carrier point above c in M, where `cont_holds` holds. By formula agreement at Round 2, `cont_holds` transfers back to N. This proves t is in the continuation set, hence t ≥ d. Combined with same_order_type (all responses ≤ t), the restricted responses are all ≥ d (after boundary adjustments).

For the strategy restriction to produce responses in [x', d]: use the above argument to show responses are ≥ x' (from [x', y'] containment) and ≤ d. The ≤ d bound comes from: all M-side picks ≤ c, same_order_type gives all N-side picks ≤ t, and if t ≤ d then done. Show t ≤ d via: c is the M-side infimum, so c is characterized by a rank-r defining formula D. By formula agreement, t satisfies the same D-conditions, placing t at or below d.

**Estimate**: ~80-120 lines for new strategy_restrict proof.

**Step 5: Restructure Case II (150-250 lines)**

Following GHR93 Case II exactly:
1. All a_bwd(i) > d (strictly, since d ≤ a_bwd(i) from hd_le_an and d < a_bwd(i) because d is the infimum and a_bwd(i) is in the continuation set's interior)
2. Use τ for a_bwd(0), ..., a_bwd(n-1) → get resp_tau(0), ..., resp_tau(n-1) in (c, b)
3. Construct e_n fresh: from U(B, A)(resp_tau(n-1)) in M (transferred from N via τ), find z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z)
4. The merged response is (resp_tau(0), ..., resp_tau(n-1), e_n)
5. Winning condition: same_order_type from τ + e_n satisfies B (same rank-r type as a_bwd(n))

**Key change**: Position n of the response is e_n (NOT c), and the N-side position n is a_bwd(n) (NOT d). The hd_eq_an rewrites are eliminated entirely.

**Step 6: Fix M-side degenerate sorries (already Phase 3)**

Lines 1547, 1564 become straightforward once SplitPointProps uses hd_le_an: the degenerate case x = c with c a gap is handled by making h_pt_xc conditional (x < c → ∃ p, inClosedInterval x c (extendPoint p)).

### Effort Estimate

| Component | Lines Changed | Difficulty |
|-----------|--------------|------------|
| Redefine d as infimum | 60-100 | Medium (infrastructure exists) |
| SplitPointProps change | 10 | Trivial |
| Case I fixes | 10-20 | Easy |
| New strategy_restrict | 80-120 | Medium-Hard |
| Case II restructure | 150-250 | Hard |
| Remove d_consistency | -160 | Deletion |
| **Total net** | **~150-340 new** | **Medium-Hard** |

---

## 6. Alternative: Rank Embedding (Higher Effort, More Correct)

If the infimum approach encounters obstacles (particularly in strategy_restrict):

1. Define `rank_embed : r ≤ r' → ExtendedCarrier M atomMap r ↪o ExtendedCarrier M atomMap r'` (~150 lines)
2. Prove preservation: ordering, formula truth at rank r, gap/point status (~100 lines)
3. Modify `ghr93_forward_to_backward` to take `∀ r', r ≤ r' → ghr93_duplicator_wins M N atomMap (1+3*n) r' (embed x) (embed y) (embed x') (embed y')` (~50 lines)
4. Prove Claim 1 at rank r+1 using C' formula (~80 lines)
5. Claim 2 follows from Claim 1 + Lemma 10 (~60 lines)

**Total**: ~440 lines new infrastructure. This exactly matches GHR93 and avoids all the issues above, but is significantly more work.

---

## 7. Summary

| Finding | Detail |
|---------|--------|
| Root cause | GHR93 Claim 1 uses rank r' > r; our code uses rank r only |
| Why gap case works | Gaps are uniquely determined by rank-r formula truth (cut uniqueness) |
| Why point case fails | Two carrier points can share rank-r type without being equal |
| d_consistency_left | Likely UNPROVABLE at rank r for the interior point case |
| hd_eq_an | Used 31 times; 25 sites in Case II require equality (not just ≤) |
| Code vs GHR93 | Case II conflates d with a_bwd(n); GHR93 keeps them separate |
| **Recommendation** | Redefine d as infimum + restructure Case II (~150-340 lines) |
| **Fallback** | Rank embedding infrastructure (~440 lines) |
