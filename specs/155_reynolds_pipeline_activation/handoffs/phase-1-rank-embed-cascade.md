# Phase 1 Rank Embedding: Cascade Analysis

## Finding: Rank r+1 Strategy Must Come from Outside

The rank r+1 strategy needed for Claim 1 cannot be derived from the rank-r strategy.
`ghr93_forward_to_backward` must receive strategies at ALL ranks r' ≥ r, matching GHR93's
universally-quantified hypothesis (**).

## Minimum Cascading Change

### Level 1: d_consistency_left/right (lines 1080, 1165)
Add parameter:
```lean
(h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n + 1) (r + 1)
    (rank_embed (Nat.le_succ r) x) ... (rank_embed (Nat.le_succ r) y'))
```
Used ONLY in the interior case (line 1157, 1235) for Claim 1.

### Level 2: obtain_split_point_props (line 1333)
Add parameter, derive h_fwd_r1 from (4+3n)-round r+1 strategy via round_mono.
Pass to d_consistency_left/right at line 1429/1432.

### Level 3: ghr93_inductive_step (line 3607)
Add parameter:
```lean
(h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 1)
    (rank_embed (Nat.le_succ r) x) ... (rank_embed (Nat.le_succ r) y'))
```
Pass to obtain_split_point_props.

### Level 4: ghr93_forward_to_backward (line 3658)
Change signature to universally quantify over rank:
```lean
(h : ∀ r', r ≤ r' → ghr93_duplicator_wins M N atomMap (1 + 3 * n) r'
    (rank_embed ‹r ≤ r'› x) (rank_embed ‹r ≤ r'› y)
    (rank_embed ‹r ≤ r'› x') (rank_embed ‹r ≤ r'› y'))
```
The induction on n works: IH gives the same universal statement at n.
Specialize at r for existing uses, at r+1 for Claim 1.

### Level 5: External callers
`ghr93_forward_to_backward` is self-contained (called from its own succ case only).
`stavi_expressive_completeness` (EFGames.lean:6666) is sorry'd and doesn't call it.
So the cascading STOPS at level 4.

## Key Insight: rank_embed at r ≤ r is NOT identity

`rank_embed (le_refl r) : ExtendedCarrier M atomMap r → ExtendedCarrier M atomMap r`
is NOT definitionally `id`. Points map to points (good), but gaps map to
`⟨g.val, r_definable_gap_mono (le_refl r) g.property⟩` which is propositionally but
not definitionally equal to `g`.

This means existing code that uses `h_fwd` directly at rank r would need adjustment:
`h (r) (le_refl r) a_pad ha_pad` gives responses at rank r but with `rank_embed` wrapping.
We'd need `rank_embed_inClosedInterval` etc. to unwrap.

## Alternative: Add h_r1 as Extra Parameter (Not Universal)

Instead of universal quantification, add a SINGLE extra parameter at rank r+1 at each level.
The self-referential induction still works because the succ case receives (4+3n) rounds at rank r,
and the IH is at (1+3n) rounds at rank r. We need (n+1) rounds at rank r+1 for Claim 1.

From the (4+3n)-round strategy at rank r, we can't derive rank r+1.
From the (4+3*(n+1))-round strategy at rank r (which equals (7+3n) rounds), we can derive...
no, round_mono doesn't change rank.

**Conclusion**: The extra parameter at rank r+1 must be threaded through as an additional
hypothesis. The succ case of ghr93_forward_to_backward must receive it from OUTSIDE.
Since ghr93_forward_to_backward is only called from its own succ case (via ih_gen),
the IH provides the universal version at n, and we need the (n+1) version for h_r1.

This requires the universal quantification approach (Level 4 change).

## Effort Estimate

| Component | Lines Changed | Risk |
|-----------|--------------|------|
| d_consistency_left/right | +20 (add param, use in sorry case) | Low |
| obtain_split_point_props | +15 (add param, pass through) | Low |
| ghr93_inductive_step | +10 (add param, pass through) | Low |
| ghr93_forward_to_backward | +30 (universal quantification + rank_embed) | Medium |
| rank_embed unwrapping | +50-100 (existing code needs wrapping/unwrapping) | High |
| Claim 1 proof | +80-100 | Hard |
| **Total** | **~200-275** | **Medium-Hard** |

## Recommendation

Defer Phase 1 until Phases 2-4 are closed. The cascading change is manageable (~200-275 lines)
but requires careful handling of rank_embed wrapping. Focus on the critical GHR93 core first.
