# Phase 1 Rank Embedding: Infrastructure Assessment

## Finding: Tasks 1.1-1.2 Already Complete

All rank embedding infrastructure needed for Phase 1 Claim 1 already exists in EFGames.lean and is sorry-free.

### Existing Infrastructure (all verified: propext, Classical.choice, Quot.sound only)

| Theorem | Line | Purpose |
|---------|------|---------|
| `r_definable_gap_mono` | 600 | Gap r-definability monotone in rank |
| `rank_embed_gap` | 610 | Embed r-definable gap into r'-definable |
| `rank_embed` | 619 | Full `ExtendedCarrier M atomMap r → ExtendedCarrier M atomMap r'` |
| `rank_embed_point` | 626 | `rank_embed h (extendPoint x) = extendPoint x` |
| `rank_embed_gap_eq` | 634 | `rank_embed h (Sum.inr g) = Sum.inr (rank_embed_gap h g)` |
| `rank_embed_gap_cut` | 653 | `(rank_embed_gap h g).val.cut = g.val.cut` |
| `rank_embed_le` | 662 | `rank_embed h a ≤ rank_embed h b ↔ a ≤ b` |
| `rank_embed_lt` | 690 | `rank_embed h a < rank_embed h b ↔ a < b` |
| `rank_embed_isPoint` | 642 | `IsPoint (rank_embed h e) ↔ IsPoint e` |
| `rank_embed_interp` | 987 | Predicate interpretation preserved |
| `rank_embed_mu_holds` | 962 | mu-point status preserved |
| `rank_embed_temporal_truth_mu` | 999 | Formula truth preserved (~40 line proof) |
| `rank_embed_stavi_truth_mu` | 1050 | StaviFormula truth preserved (~220 line proof) |
| `rank_embed_inClosedInterval` | 4037 | Closed interval membership preserved |

### Also Exists: ghr93_forward_to_backward_rank_varying (line 3775, sorry'd)

`ghr93_forward_to_backward_rank_varying` already uses `rank_embed` in its signature:
```lean
(h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 4 * n)
       (rank_embed (by omega) x) (rank_embed (by omega) y)
       (rank_embed (by omega) x') (rank_embed (by omega) y'))
```

This is sorry'd (Phase 4 dependency) and handles the rank-varying case for the assembly chain. The d-consistency Claim 1 needs a DIFFERENT variant: strategy at rank r+1 (not r+4n) for the specific d_consistency proof.

## What Remains (Tasks 1.3-1.6)

All remaining work is in **ExpressivenessGeneral.lean**:

### Task 1.3: Add universal rank hypothesis to ghr93_forward_to_backward

**Option A (minimal)**: Add a second hypothesis:
```lean
(h_r1 : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 1)
    (rank_embed (Nat.le_succ r) x) (rank_embed (Nat.le_succ r) y)
    (rank_embed (Nat.le_succ r) x') (rank_embed (Nat.le_succ r) y'))
```

**Option B (GHR93-faithful)**: Replace h with universal quantification:
```lean
(h : ∀ r', r ≤ r' → ghr93_duplicator_wins M N atomMap (1 + 3 * n) r'
    (rank_embed h x) (rank_embed h y) (rank_embed h x') (rank_embed h y'))
```

Option A is simpler (only Claim 1 needs rank r+1; nothing else uses rank > r in the inductive step). The caller provides h_r1 from the formula-agreement hypothesis.

### Task 1.4: Prove Claim 1 at rank r+1

Use h_r1 to play the forward game at rank r+1. The rank-(r+1) formula C' = ¬C ∨ K⁻¬C has stavi_depth ≤ r+1, so formula agreement at rank r+1 transfers C'(t) ↔ C'(d). Since C'(d) holds and C'(t) holds, derive t ≤ d. If t < d, Spoiler can exploit the gap, contradiction. Hence t = d.

### Task 1.5: Close d_consistency_left/right interior

Apply Claim 1 to the forward strategy's response.

### Task 1.6: Verify

`lean_verify d_consistency_left` shows no sorryAx.

## Recommendation

Tasks 1.1-1.2 require NO new code. Proceed directly to Task 1.3 in ExpressivenessGeneral.lean.
