# Forward Inventory: Complete Sorry Map (Task 155)

Date: 2026-05-24

## Summary

**Total sorry sites across WeakCanonical/**: 22 (across 5 files)

| File | Sorries | Critical Path? |
|------|---------|----------------|
| ExpressivenessGeneral.lean | 11 | YES (GHR93 Thm 6) |
| EFGames.lean | 1 | YES (expressive completeness) |
| IntegerModel.lean | 1 | YES (one_class theorem) |
| TruthLemma.lean | 6 | NO (documented non-critical) |
| OrderedSum.lean | 1 | NO (dense case only) |

## File 1: ExpressivenessGeneral.lean (11 sorries)

### S1. Line 3901 -- `obtain_split_point_props` (Claim 1, K^-(~D_M) edge case)

- **Enclosing theorem**: `obtain_split_point_props`
- **Goal**: `False` (contradiction needed)
- **Context**: Case where `r2_resp = rank_embed y'` forcing `c_inf = y`, boundary edge within the carrier-point sub-case of r2_resp < rank_embed(d)
- **Blocker**: Needs boundary lemma or formula materialization for the `c_inf = y` edge
- **Effort**: Moderate -- self-contained edge case with rich context

### S2. Line 3935 -- `obtain_split_point_props` (Claim 1, gap edge case)

- **Enclosing theorem**: `obtain_split_point_props`
- **Goal**: `False` (contradiction needed)
- **Context**: Case where `r2_resp` is a gap at rank r+2, within the r2_resp < rank_embed(d) case. Comment says "formula materialization is circular" (report 39)
- **Blocker**: BLOCKED by formula materialization circularity. Cannot materialize continuation predicate as a formula
- **Effort**: Substantial -- fundamental architectural question

### S3. Line 4412 -- `obtain_split_point_props` (multi-round cont_transfer)

- **Enclosing theorem**: `obtain_split_point_props`
- **Goal**: `cont_holds (a_bwd n) y' (extendPoint p)` -- derive continuation from multi-round game winning condition
- **Context**: Step 3 of multi-round Claim 1 -- adaptation of h_cont_transfer for multi-round game indices
- **Blocker**: Mechanical adaptation of h_cont_transfer (lines 3240-3330) with index arithmetic
- **Effort**: Moderate (~90 lines of index arithmetic, structurally identical to existing proof)

### S4. Line 4424 -- `obtain_split_point_props` (multi-round K^-(~D_M))

- **Enclosing theorem**: `obtain_split_point_props`
- **Goal**: `mr_resp <= rank_embed d` -- multi-round analogue of h_r2_resp_le_d
- **Context**: Step 4 mirrors the proof of h_r2_resp_le_d but with multi-round game indices (position 2+3n instead of 1)
- **Blocker**: Same structure as h_r2_resp_le_d (lines 3335-3937), needs index adaptation. Also inherits S1/S2 blockers
- **Effort**: Substantial (mirrors ~600 lines with adapted indices, inherits gap/boundary blockers)

### S5. Line 4468 -- `obtain_split_point_props` (multi-round gap case)

- **Enclosing theorem**: `obtain_split_point_props`
- **Goal**: `False` -- mr_resp is a gap, need contradiction
- **Context**: Gap sub-case of Step 5 (mr_resp >= rank_embed(d)). Mirror of h_r2_resp_ge_d gap case (lines 3994-4250)
- **Blocker**: Mechanical adaptation of the gap case with multi-round indices
- **Effort**: Moderate

### S6-S7. Lines 4483, 4508 -- `obtain_split_point_props` (position constraint)

- **Enclosing theorem**: `obtain_split_point_props`
- **Goal**: `a'_full ⟨0, ...⟩ = d` (line 4483 left), `a'_full ⟨0, ...⟩ = d` (line 4508 right)
- **Context**: Interior case left/right -- rank_down gives bounds+winning but loses the position constraint that the projected response equals d at the designated position
- **Blocker**: Requires inlining rank_down's projection construction (~200 lines per direction)
- **Effort**: Substantial -- not blocked conceptually but labor-intensive

### S8. Line 5945 -- `ghr93_case_II` (cross-boundary order goals)

- **Enclosing theorem**: `ghr93_case_II` (Case II: all selections in [d,y'], a_n is a point)
- **Goal**: Multiple sub-goals about cross-boundary ordering (e.g. `b_resp < x' <-> b_sp < x`, `y' < a_bwd[j] <-> y < resp_tau[j]`, etc.)
- **Context**: same_order_type proof for the composed (n+1)-round game tuple combining sigma + tau strategies
- **Blocker**: Needs `c <= e_n` or similar bound from h_d_unique (Claim 1) or restructured forward game
- **Effort**: Moderate -- the individual order goals are formula-level pivoting through known iff hypotheses

### S9-S10. Lines 6045, 6098 -- `ghr93_case_II` (tau same_order_type)

- **Enclosing theorem**: `ghr93_case_II`
- **Goal (6045)**: `same_order_type (n+1) (game_tuple x' y' a_bwd b_resp) (game_tuple x y (...) b_sp)` -- full same_order_type for tau sub-case
- **Goal (6098)**: Same same_order_type but for the remaining split_ifs goals. Note: line 6098 is marked `sorry` inside a dead code comment block (between `/-` and `-/` delimiters), but the `sorry` at line 6098 is actually live code outside the comment
- **Blocker**: Needs `(x' < d <-> x < c)` which requires instantiating the sigma strategy (pivot_chain_order argument)
- **Effort**: Moderate-to-substantial -- requires connecting sigma and tau ordering data

### S11. Line 7028 -- `ghr93_cases_III_IV` (gap cases)

- **Enclosing theorem**: `ghr93_cases_III_IV`
- **Goal**: Full backward game response when a_n is a gap -- `exists a'_resp, bounds /\ winning_condition`
- **Blocker**: Requires Lemma 9 (gap detection correctness) from EFGames.lean, which is also sorry'd (see EFGames S12)
- **Effort**: Massive -- entire gap-case proof structure needs implementation

### S12. Line 7390 -- `ghr93_forward_to_backward_rank_varying` (sub-interval strategy)

- **Enclosing theorem**: `ghr93_forward_to_backward_rank_varying`
- **Goal**: `ghr93_duplicator_wins M N atomMap (1 + 3*(n+1)) (r+2) (rank_embed x1) ... (rank_embed y1')` -- derive game on arbitrary sub-intervals from game on original interval
- **Blocker**: Requires GHR93 Lemma 10 (strategy restriction to sub-intervals) -- not yet formalized
- **Effort**: Massive -- needs full Lemma 10 implementation

## File 2: EFGames.lean (1 sorry)

### S13. Line 10086 -- `nf_characterizable_by_stavi` (inductive step)

- **Enclosing theorem**: `nf_characterizable_by_stavi`
- **Goal**: `exists A : StaviFormula, forall M t, stavi_temporal_truth M atomMap t A <-> nf_eval_nf M (k+1) 1 (fun _ => t) nf`
- **Context**: Inductive step of "every 1-variable normal form at depth k+1 is characterizable by a Stavi formula"
- **Blocker**: This IS the central theorem of GHR93 Section 8. Requires the full game-theoretic argument: EF games (Thm 6), composition (Prop 7), four cases (atoms, Until, Since, Stavi gaps), gap detection (Lemma 9)
- **Effort**: Massive -- this is the keystone sorry, equivalent to the full GHR93 proof

## File 3: IntegerModel.lean (1 sorry)

### S14. Line 863 -- `no_gaps_discrete` (Reynolds Theorem 14)

- **Enclosing theorem**: `no_gaps_discrete`
- **Goal**: `exists c, contemp_equiv sig k M a c /\ ~contemp_equiv sig k M a (Order.succ c)` -- find a class boundary
- **Blocker**: Requires Reynolds Theorem 5 (US expressive completeness over Prior structures), which is not yet formalized
- **Effort**: Massive -- requires formalizing a separate theorem (Theorem 5) first

## File 4: TruthLemma.lean (6 sorries, ALL non-critical-path)

### S15. Line 431 -- `until_forward_mcs` (intermediate guard)

- **Goal**: `forall z, tempR_fwd x z -> tempR_fwd z y -> psi2 in z`
- **Blocker**: Needs chain construction / self-accumulation infrastructure from BXCanonical not ported to ReflCanDomain
- **Status**: DOCUMENTED NON-CRITICAL. Parametric truth lemma handles U/S via BFMCS coherence.
- **Effort**: Moderate

### S16. Line 448 -- `until_backward_mcs`

- **Goal**: `not (exists y, tempR_fwd x y /\ phi in y /\ forall z intermediate, psi in z)`
- **Status**: DOCUMENTED NON-CRITICAL
- **Effort**: Moderate

### S17. Line 483 -- `since_forward_mcs` (intermediate guard)

- **Goal**: `forall z, tempR_bwd z y -> tempR_bwd z x -> psi2 in z`
- **Status**: DOCUMENTED NON-CRITICAL. Mirror of until_forward_mcs.
- **Effort**: Moderate

### S18. Line 497 -- `since_backward_mcs`

- **Goal**: `not (exists y, tempR_bwd y x /\ phi in y /\ forall z intermediate, psi in z)`
- **Status**: DOCUMENTED NON-CRITICAL
- **Effort**: Moderate

### S19. Line 540 -- `truth_lemma_refl` (until backward in main truth lemma)

- **Goal**: `phi.untl psi in x` from semantic until condition
- **Status**: DOCUMENTED NON-CRITICAL. Depends on until_backward_mcs variant.
- **Effort**: Moderate

### S20. Line 556 -- `truth_lemma_refl` (since backward in main truth lemma)

- **Goal**: `phi.snce psi in x` from semantic since condition
- **Status**: DOCUMENTED NON-CRITICAL. Depends on since_backward_mcs variant.
- **Effort**: Moderate

## File 5: OrderedSum.lean (1 sorry, non-critical)

### S21. Line 56 -- `doets_lemma_1_5` (type-matching k-equivalence)

- **Goal**: `k_equiv sig k (orderedSum sig I m) (orderedSum sig J m')`
- **Status**: NOT on discrete completeness critical path. Required only for dense case (future work). Bypassed by one_class argument in discrete case.
- **Effort**: Substantial

## Blocker Categories

### Category A: Independently Closable (mechanical adaptations)

| ID | Lines | Effort | Description |
|----|-------|--------|-------------|
| S3 | 4412 | Moderate | Multi-round cont_transfer index adaptation |
| S5 | 4468 | Moderate | Multi-round gap case index adaptation |
| S8 | 5945 | Moderate | Cross-boundary order goals (pivoting) |

### Category B: Gated on Other Sorries

| ID | Lines | Gated On | Description |
|----|-------|----------|-------------|
| S4 | 4424 | S1, S2 | Multi-round K^-(~D_M), inherits boundary/gap blockers |
| S11 | 7028 | S13 (EFGames) | Gap cases need Lemma 9 |
| S13 | 10086 | S12, S11 | Keystone: needs full game infrastructure |
| S14 | 863 | (external) | Needs Reynolds Theorem 5 |

### Category C: Require New Infrastructure

| ID | Lines | Infrastructure | Description |
|----|-------|----------------|-------------|
| S2 | 3935 | Formula materialization | Gap case + continuation predicate circularity |
| S6-S7 | 4483, 4508 | Inline rank_down projection | Position constraint tracking |
| S9-S10 | 6045, 6098 | Sigma strategy instantiation | (x' < d <-> x < c) pivoting |
| S12 | 7390 | Lemma 10 (strategy restriction) | Sub-interval strategy derivation |

### Category D: Non-Critical-Path (do not block completeness)

| ID | Lines | File |
|----|-------|------|
| S15-S20 | 431-556 | TruthLemma.lean |
| S21 | 56 | OrderedSum.lean |

## Critical Path Analysis

### The Completeness Chain

```
bx_completeness
  -> countermodel_discrete (Transfer.lean, sorry-free)
    -> dd_countermodel_chronicle_discrete (Chronicle path, has succ_cofinal sorry)
```

The current `countermodel_discrete` delegates to the chronicle construction, which has its own `succ_cofinal` sorry. The Reynolds pipeline was intended to replace this delegation. The Reynolds pipeline path would be:

```
countermodel_discrete (Reynolds path, not yet wired)
  -> chronicle_is_good (IntegerModel.lean)
    -> one_class (IntegerModel.lean)
      -> no_gaps_discrete [S14, SORRY]
  -> truth_transfer
    -> stavi_expressive_completeness (EFGames.lean)
      -> nf_characterizable_by_stavi [S13, SORRY]
        -> ghr93_forward_to_backward_rank_varying
          -> h_r1_univ [S12, SORRY]
        -> ghr93_inductive_step
          -> ghr93_case_II [S8-S10, SORRY]
          -> ghr93_cases_III_IV [S11, SORRY]
        -> obtain_split_point_props [S1-S7, SORRY]
```

### Minimal Critical Set for Reynolds Pipeline

To achieve sorry-free Reynolds pipeline `countermodel_discrete`:

1. **S14** (no_gaps_discrete) -- requires Reynolds Theorem 5
2. **S13** (nf_characterizable_by_stavi) -- the keystone, requires:
   - **S12** (strategy restriction / Lemma 10)
   - **S11** (gap cases / Lemma 9)
   - **S1-S10** (Claim 1 + Case II in ghr93_inductive_step)

All 14 critical-path sorries (S1-S14) must be closed.

### Sorries NOT on Critical Path

**S15-S20** (TruthLemma.lean): Documented non-critical. The parametric truth lemma handles Until/Since via BFMCS coherence, so these do not block completeness.

**S21** (OrderedSum.lean): Dense-case only. Discrete completeness bypasses this via one_class.

### Difficulty Tiers

| Tier | Sorries | Description |
|------|---------|-------------|
| Tier 1 (closable now) | S3, S5, S8 | Mechanical index adaptations, ~100-200 lines each |
| Tier 2 (closable with effort) | S1, S6, S7, S9, S10 | Need careful construction but no new infrastructure |
| Tier 3 (need new lemmas) | S2, S4 | Blocked by formula materialization circularity |
| Tier 4 (need new theorems) | S11, S12, S13, S14 | Require Lemma 9, Lemma 10, full GHR93 induction, Theorem 5 |

### Recommended Attack Order

1. Close S3 (multi-round cont_transfer) -- mechanical, unblocks confidence
2. Close S5 (multi-round gap case) -- mechanical
3. Close S8 (cross-boundary ordering) -- moderate, unblocks Case II
4. Close S1 (boundary edge) -- self-contained
5. Close S9, S10 (sigma pivoting) -- unblocks full Case II
6. Close S6, S7 (rank_down inlining) -- unblocks interior case
7. Formalize Lemma 10 for S12 -- major milestone
8. Formalize Lemma 9 for S11 -- enables gap cases
9. Close S13 (keystone) -- requires all above
10. Formalize Theorem 5 for S14 -- independent of GHR93, can be parallelized

**S2** (gap + formula materialization) is the hardest blocker. Report 39 confirms this is circular in the current approach. Resolution may require restructuring how `cont_holds` is defined (predicate vs formula).
