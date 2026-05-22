# Phase 1 Blocker: Deep Analysis of GHR93 Claim 1 and Resolution Strategy

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Session**: sess_1779463127_2d6169
**Focus**: Resolve conflicting analyses of Phase 1 d-consistency blocker by deep reading of GHR93 Section 8

---

## 1. GHR93 Section 8 Deep Read: Theorem 6 and Claim 1

### 1.1 The Statement (*)_n

GHR93 Theorem 6 proves (*)_n for all n < omega:

> **(*)_n**: For all r < omega, if x < y in M_r, x' < y' in N_r, and Duplicator has a winning strategy for G_{1+3n; r+4n}(M,xy; N,x'y'), then Duplicator has a winning strategy for G_{n;r}(N,x'y'; M,xy).

Key observations about this statement:

1. **r is universally quantified**: The hypothesis "for all r" means that at the point of proof, the inductive step has access to strategies at ALL ranks, not just one fixed rank.

2. **Forward game rank is r+4n, not r**: The forward game uses rank r+4n, which is strictly greater than r for any n >= 1. This is critical -- it means the forward game provides formula agreement at rank r+4n, which includes rank r+1 formulas needed for Claim 1.

3. **Backward game rank is r**: The conclusion is at rank r, meaning Duplicator must preserve rank-r formulas in the backward game.

### 1.2 The Inductive Step Setup

When proving (*)_{n+1}, the proof fixes r and assumes:
- Duplicator wins G_{4+3n; r+4(n+1)}(M,xy; N,x'y') (the forward hypothesis)
- (*)_n holds for all r' (the IH, universally quantified over ranks)

The proof defines:
- **A**: The interval-type formula X_{(alpha_{n-1}, alpha_n)}, of rank r
- **C(u)**: "A holds at all mu-points in (u, y')" -- captures the continuation condition. C has rank r.
- **c**: inf{t in [x,y] : M |= C(u) for all u in (t,y)} -- the M-side infimum
- **d-bar** (written d in GHR93): inf{t in [x',y'] : N |= C(u) for all u in (t,y')} -- the N-side infimum

If c is not a point, it is a gap definable on the right by C, hence c is in M_r. Similarly for d-bar.

### 1.3 Claim 1: Exact Formulation and Proof

> **Claim 1** (p.116): Consider a play of the game G_{m;r'}(M,xy; N,x'y') for arbitrary r' > r, m >= 1 in which Duplicator uses a winning strategy. Let Spoiler begin by choosing c plus m-1 other points, and let Duplicator's response to c be d (plus m-1 other points). Then d = d-bar.

**Proof of Claim 1**:

1. Since the strategy is winning, any rank-r' formula satisfied by one of Spoiler's choices must also be satisfied by Duplicator's corresponding choice.

2. Define C' = not-C OR K^{-}(not-C), which has rank r+1.

3. M_r |= C'(c) holds. (Because c is the infimum of the continuation set: either C fails immediately above c, or C fails cofinally below c in the cut. In either case, C' captures this via the backward "eventually" operator K^{-}.)

4. Since r' > r, we have r' >= r+1, so rank-(r+1) formulas are included in the winning condition. Hence N_r |= C'(d).

5. C'(d) implies d <= d-bar. (If d were strictly above d-bar, C would hold throughout (d-bar, y') including at d, making C' false at d.)

6. If d < d-bar, Spoiler can choose d' in (d-bar, y') with N |= not-C(d'). Duplicator has no winning response in M (since all points above c in M satisfy C). Contradiction.

7. Therefore d = d-bar.

**Critical insight**: The proof needs exactly ONE game at SOME r' > r. It does not need the strategy at ALL r'. The forward hypothesis provides a strategy at rank r+4(n+1) > r. Since r+4(n+1) >= r+1, the rank-(r+1) formula C' is available. Claim 1 can be proved using this single strategy.

### 1.4 Whether the Infimum Definition is Essential

**Yes, d-bar as infimum is essential, not just convenient.**

Claim 1 proves that ANY winning response to c must equal d-bar (the infimum). This means:
- With d = d-bar: the forward strategy's response at position n IS d by Claim 1. d_consistency becomes trivial.
- With d = a_bwd(n) (Spoiler's arbitrary pick): d_consistency asks "does the response at position n equal a_bwd(n)?" This is FALSE in general, because Claim 1 forces the response to equal d-bar, not a_bwd(n).

The infimum is not a convenience -- it is the UNIQUE element that can appear at position n in a winning response.

### 1.5 Whether Case II Constructs e_n Fresh

**Yes, GHR93 Case II (p.117-118) constructs e_n as a fresh point, NOT as d-bar or c.**

The Case II flow:
1. All alpha_i are in (d-bar, y'). alpha_n is a point (not a gap).
2. Define B = X_{alpha_n}, b = sup{t in (x,y) : M |= B(t)}, b' similarly.
3. Show b' > alpha_n (GHR93 p.117).
4. Apply Claim 2 (derived from Claim 1) to get backward strategies on sub-intervals.
5. Use tau (backward strategy on [d-bar, y'] vs [c, y]) for alpha_0, ..., alpha_{n-1}. Get responses resp_tau(0), ..., resp_tau(n-1) in (c, b).
6. From N |= U(B, A)(alpha_{n-1}), transfer via tau to M |= U(B, A)(resp_tau(n-1)). Find z > resp_tau(n-1) with M |= B(z) and A on (resp_tau(n-1), z).
7. Set e_n = z. e_n satisfies B, hence has the same rank-r type as alpha_n.

e_n is a genuinely NEW point found via U(B,A) transfer. It is NOT c, NOT d-bar. The merged response is (resp_tau(0), ..., resp_tau(n-1), e_n).

### 1.6 Rank Arithmetic Summary

| Case | Key formula | Rank | Available from |
|------|------------|------|----------------|
| Claim 1 | C' = not-C or K^{-}(not-C) | r+1 | Forward game at rank r+4(n+1) |
| Claim 2 | Strategy restriction via Claim 1 | -- | Claim 1 + Lemma 10 |
| Case I | No new formulas beyond rank r | r | sigma, tau |
| Case II | U(B, A) | r+1 | tau preserves rank r+4 formulas |
| Case III | left(B, D) | r+2 | tau preserves rank r+4 formulas |
| Case IV | A /\ not-D /\ U(right(B,D), A) | r+3 | tau preserves rank r+4 formulas |

Cases II-IV use formulas of rank up to r+3. The forward hypothesis at rank r+4n (with n >= 1, so r+4) provides sufficient formula agreement.

---

## 2. Assessment of the Three Conflicting Analyses

### 2.1 Report 27: Infimum Redefinition + Case II Restructure

**Verdict: CORRECT on the diagnosis, partially correct on the solution.**

Report 27 correctly identifies:
- GHR93 Claim 1 uses rank r+1; our code uses rank r only
- Gap case works at rank r (cut uniqueness); point case fails (rank-r type doesn't pin identity)
- Case II conflates d with a_bwd(n); GHR93 keeps them separate
- Infimum redefinition eliminates d_consistency (with d = d-bar, Claim 1 gives the proof)

Report 27 underestimates the Case II restructure effort and doesn't clearly state that rank embedding is also needed for Claim 1.

### 2.2 Handoff-b: Rank Embedding Only

**Verdict: INCORRECT on the key claim.**

Handoff-b claims:
- "Infimum redefinition does NOT close d_consistency" -- **WRONG**
- "With d = a_bwd(n), rank embedding + Claim 1 gives t = d" -- **WRONG**
- "Case II UNCHANGED" -- **WRONG**

The error is at Step 4 of handoff-b's plan: "Prove Claim 1 at rank r+1: t = d." But Claim 1 proves t = d-bar (the infimum), not t = a_bwd(n). If d is defined as a_bwd(n) and a_bwd(n) != d-bar, then Claim 1 gives t = d-bar != d, making d_consistency FALSE.

Handoff-b's advice to "keep d = a_bwd(n)" is architecturally incorrect. It was confused by thinking that d_consistency asks for "response = d" and that Claim 1 proves "response = d", but Claim 1 proves "response = d-bar" (the infimum, not the arbitrary Spoiler pick).

### 2.3 Report 29: Both Infimum AND Rank Embedding

**Verdict: CORRECT. This is the definitive analysis.**

Report 29 correctly identifies:
- d_consistency with d = a_bwd(n) is UNPROVABLE (d may != d-bar)
- d_consistency with d = d-bar IS PROVABLE via Claim 1
- Infimum redefinition is NOT wasted effort (it's necessary)
- Rank embedding alone does NOT suffice (also need infimum)
- Case II must be restructured (~300-500 lines)

The correct path IS: infimum redefinition + rank embedding (BOTH), as report 29 concludes.

### Definitive Recommendation

**Report 29 is correct. The plan should follow report 29's strategy:**

1. Redefine d as the actual infimum of continuation_set (not x', not a_bwd(n))
2. Prove Claim 1 using rank embedding (already done: h_fwd_r1 exists)
3. Restructure Case II to construct e_n fresh (matching GHR93)
4. d_consistency becomes a trivial corollary of Claim 1

---

## 3. Current Code State: What Exists vs What's Needed

### 3.1 What Already Exists (Sorry-Free)

| Infrastructure | File | Status |
|---------------|------|--------|
| `rank_embed` (order embedding r -> r') | EFGames.lean:619 | Sorry-free |
| `rank_embed_le`, `rank_embed_lt` (order preservation) | EFGames.lean:662, 690 | Sorry-free |
| `rank_embed_isPoint`, `rank_embed_gap_cut` | EFGames.lean:642, 653 | Sorry-free |
| `rank_embed_temporal_truth_mu` | EFGames.lean:999 | Sorry-free |
| `rank_embed_stavi_truth_mu` | EFGames.lean:1050 | Sorry-free |
| `rank_embed_inClosedInterval` | EFGames.lean:6661 | Sorry-free |
| `continuation_set`, `continuation_set_nonempty` | ExpressivenessGeneral.lean:142, 162 | Sorry-free |
| `continuation_set_upward_closed` | ExpressivenessGeneral.lean:174 | Sorry-free |
| `a_n_in_continuation_set` | ExpressivenessGeneral.lean:192 | Sorry-free |
| `inf_carrier_cut`, `inf_carrier_cut_downward_closed` | ExpressivenessGeneral.lean:153, 208 | Sorry-free |
| `infimum_gap` (Gap construction from cut) | ExpressivenessGeneral.lean:377 | Sorry-free |
| `infimum_gap_r_definable` | ExpressivenessGeneral.lean:904 | Sorry-free |
| `cont_holds_above_gap`, `cont_fails_below_gap` | ExpressivenessGeneral.lean:424, 468 | Sorry-free |
| `nf_determines_stavi_truth` | ExpressivenessGeneral.lean:523 | Sorry-free |
| `ghr93_strategy_restrict_left/right` | EFGames.lean:7105, 7334 | Sorry-free (takes d_consistency as arg) |
| `ghr93_duplicator_wins_round_mono` (Lemma 10) | EFGames.lean:6935 | Sorry-free |
| `ghr93_duplicator_wins_degenerate_gap` | EFGames.lean:6821 | Sorry-free |
| `flatten_stavi_correct` (Reynolds Theorem 5, discrete) | StaviConnectives.lean:492 | Sorry-free |
| `SplitPointProps` with `hd_le_an` | ExpressivenessGeneral.lean:1282 | Structure defined |
| `h_fwd_r1` parameter propagation | ExpressivenessGeneral.lean:1096 | Done |

### 3.2 Current Architectural Flaw

At `obtain_split_point_props` (line 1381-1391), the code currently does:

```lean
obtain <d, hd_interval, hd_glb, hd_le_an_proof> := by
  refine <x', ..., fun s hs => hs.1.1, (ha_bwd ...).1>
```

This sets **d = x'**, not the actual infimum of continuation_set. The comment at line 1386-1389 explicitly acknowledges: "Use x' as a lower bound of S_C. This is a valid lower bound (not necessarily the GLB). The proper infimum construction (point/gap case split) would give the GHR93 d-bar."

This is a placeholder. With d = x', the hd_glb property is weak (x' <= all of S_C is trivially true since S_C is contained in [x', y']). The d_consistency obligation becomes: "the forward strategy's response at position n equals x'." This is generally false (the response would be somewhere in [x', y'], not necessarily x' itself).

### 3.3 What Needs to Change (Phase 1 Resolution)

**Step 1: Construct the actual infimum d-bar (~100-150 lines)**

Replace the x'-placeholder with a proper case split:
- If S_C has a point minimum p (i.e., extendPoint p is in S_C and is the GLB), set d = extendPoint p
- Otherwise, use `infimum_gap` to construct the gap d from inf_carrier_cut(S_C). Use `infimum_gap_r_definable` to show d is in M_r.

All the building blocks exist and are sorry-free. The construction requires assembling the preconditions of `infimum_gap`:
- S_C nonempty: `continuation_set_nonempty`
- Carrier-point lower bound: x' provides this (if x' is a point; if x' is a gap, need h_pt to get a point below)
- Upper bound above some element: use a_n ∈ S_C and h_pt to find a point above a_n
- Not a point GLB: this is the case split condition

**Step 2: Prove Claim 1 (~80-120 lines)**

With d = d-bar (actual infimum):
1. Construct C' = not-C or K^{-}(not-C) of rank r+1
2. Show M_r |= C'(c) using the infimum definition and `cont_fails_below_gap`/`cont_holds_above_gap`
3. Use h_fwd_r1 (rank r+1 forward strategy, already parameterized) to play the game
4. By the winning condition at rank r+1, C'(t) holds at the response t
5. Derive t <= d-bar from C'(t)
6. Derive t >= d-bar by contradiction (if t < d-bar, Spoiler exploits the gap)
7. Conclude t = d-bar = d

**Step 3: Close d_consistency_left/right interior (~20-40 lines)**

With d = d-bar and Claim 1 proved, d_consistency becomes: "the response at position n equals d-bar." This is Claim 1 applied to the forward strategy. The boundary cases are already proved; only the interior case needs Claim 1.

**Step 4: Restructure Case II (~300-500 lines)**

This is the largest change. The current Case II (line 2844) constructs e_n via sorry. The restructured version must:
1. Use tau for positions 0..n-1 (already done: line 2873)
2. Transfer U(B, A)(alpha_{n-1}) from N to M via tau (rank r+1 formula, but tau preserves rank r+4 formulas from Claim 2)
3. Find z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z)
4. Set e_n = z
5. Prove winning condition for the merged response

The existing skeleton at lines 2880-2890 has the right structure but sorry's the e_n construction.

**Step 5: Fix the IH sorry at line 3836 (~40-60 lines)**

The sorry at line 3836 provides h_fwd_r1 for sub-intervals when applying the IH. With d = d-bar, the sub-interval strategy restriction at rank r+1 works the same way as at rank r: the r+1 forward strategy on [x,y] restricts to [x,c] and [c,y] via `strategy_restrict_left/right`, just using d_consistency at rank r+1 (which is Claim 1 at rank r+2, still available from the forward hypothesis at rank r+4(n+1)).

However, this creates a dependency chain: strategy restriction at rank r' needs d_consistency at rank r', which needs Claim 1 at rank r'+1. With the forward strategy at rank r+4(n+1), we can handle r' up to r+4(n+1)-1. Since we only need r' = r+1, this is fine (r+1 < r+4 <= r+4(n+1) for n >= 0).

### 3.4 Sorry Inventory After Phase 1 (Projected)

| Sorry site | Phase | Status after Phase 1 |
|-----------|-------|---------------------|
| 1170: d_consistency_left interior | 1 | CLOSED (Claim 1) |
| 1249: d_consistency_right interior | 1 | CLOSED (Claim 1) |
| 1564: h_pt_xc degenerate gap | 3 | UNCHANGED |
| 1581: h_pt_cy degenerate gap | 3 | UNCHANGED |
| 1678: c-construction n=0 gap case | 3 | UNCHANGED |
| 2890: Case II e_n construction | 3 | Should be CLOSED as part of Case II restructure |
| 3666: cases_III_IV | 3 | UNCHANGED |
| 3836: IH h_r1 sorry | 1 | CLOSED (sub-interval r+1 restriction) |
| 3877: rank_varying | 4 | UNCHANGED |
| 7688: decomposition_implies_game | 4 | UNCHANGED |
| 8990: stavi_expressive_completeness | 4 | UNCHANGED |

Phase 1 should close 4 sorry sites (lines 1170, 1249, 2890, 3836), plus introduce the actual infimum construction.

---

## 4. Overall Pipeline Health Assessment

### 4.1 Phase 2 (Lemma 9): COMPLETE

Phase 2 is marked complete. No sorry sites remain in the Lemma 9 infrastructure per the plan, though the sorry inventory at lines 2701 (EFGames.lean comment) suggests some helper theorems may still be sorry'd. The plan's sorry inventory (Section "Full Sorry Inventory") lists Phase 2 sites as completed or deleted.

However, the plan v12's Phase 2 tasks 2.7, 2.8, 2.9b, 2.10, 2.11 are marked with `[ ]` (not done). There may be a discrepancy between the plan status markers and the actual code. Let me verify: the plan says "Phase 2: COMPLETE" at the top but has unchecked subtasks. This suggests Phase 2 was declared complete based on the main sorry sites being closed, while some subtasks may have been resolved differently than planned.

**Assessment**: Phase 2 appears substantially complete but should be verified with `lean_verify left_formula_gap_detection` and `lean_verify right_formula_gap_detection`.

### 4.2 Phase 3 (Cases III/IV + Degenerate): Partially Started

- c-gap-case (n>=1): DONE (plan line 60)
- h_pt_xc, h_pt_cy degenerate: sorry'd (lines 1564, 1581)
- c-construction n=0 gap: sorry'd (line 1678)
- cases_III_IV: sorry'd (line 3666)

**Assessment**: Cases III/IV are the main remaining work in Phase 3. They require Lemma 9 (gap detection), which should be available from Phase 2. The degenerate cases (h_pt_xc, h_pt_cy) are relatively straightforward -- they need the SplitPointProps conditional form restructure. The n=0 gap case is more subtle (it requires showing that for n=0, d must be a point in the forward game, or constructing c differently).

**Feasibility**: HIGH. The GHR93 Cases III/IV proofs are explicit (pp.117-119). The left(B,D) and right(B,D) constructions are already defined in EFGames.lean. The main work is assembling the sub-interval strategy arguments and applying Lemma 9.

**Estimated effort**: 6-10 hours (matches plan estimate).

### 4.3 Phase 4 (Assembly Chain): Not Started

- rank_varying (line 3877): sorry'd
- decomposition_implies_game (line 7688): sorry'd
- stavi_expressive_completeness (line 8990): sorry'd

**Assessment**: Phase 4 requires all of Phases 1-3. The rank-varying theorem should follow from the uniform-rank version via rank embedding. Lemma 11 backward (decomposition_implies_game) is a standard game-theory argument. Propositions 6-7 and Corollary 5 require careful formula-enumeration arguments.

**Feasibility**: MEDIUM-HIGH. Props 6 and 7 are substantial new code. Prop 7 involves decomposition formula counting with growth functions f, g. Corollary 5 is a composition of Props 5-7.

**Estimated effort**: 8-14 hours (matches plan estimate).

### 4.4 Phase 5 (Reynolds Theorem 5): Not Started

`flatten_stavi_correct` is already sorry-free. Phase 5 composes this with `stavi_expressive_completeness` (Phase 4).

**Feasibility**: HIGH. Mainly wiring, estimated at 2-3 hours.

### 4.5 Phases 6A-6B (Gap Elimination): Not Started

Entirely new code: GapElimination.lean. Reynolds Lemmas 6-14.

**Feasibility**: MEDIUM. Lemma 12 (model surgery) has 14 sub-cases. The argument is explicit in the literature but requires careful formalization.

**Estimated effort**: 12-16 hours total (matches plan's 6-8 + 6-8).

### 4.6 Phases 7-9 (Off Critical Path): DEPRIORITIZED

Report 28 confirmed these are orphaned. `chronicle_is_good` is sorry-free via direct OrderIso. The `very_good_implies_good` chain is unused.

### 4.7 Phase 10 (Transfer.lean): COMPLETE

### 4.8 Total Remaining Effort Estimate

| Phase | Hours | Status |
|-------|-------|--------|
| Phase 1: d-consistency | 8-12 | BLOCKED (this report resolves the strategy) |
| Phase 3: Cases III/IV + degenerate | 6-10 | Depends on Phase 1 |
| Phase 4: Assembly chain | 8-14 | Depends on Phase 3 |
| Phase 5: Reynolds Theorem 5 | 2-3 | Depends on Phase 4 |
| Phase 6A: Gap elimination lemmas 6-11 | 6-8 | Depends on Phase 5 |
| Phase 6B: Lemma 12 surgery + Theorem 14 | 6-8 | Depends on Phase 6A |
| Phase 8: Wire no_gaps_discrete | 1-2 | Depends on Phase 6B |
| Phase 11: Final wiring | 1-2 | Depends on all |
| **Total** | **38-59** | |

The plan's 60-90 hour estimate appears slightly conservative given that Phase 2 and Phase 10 are already complete. A revised estimate of **40-60 hours** for remaining work seems more accurate.

---

## 5. Detailed Phase 1 Implementation Path

### 5.1 The Infimum Construction (Priority 1)

Replace `obtain_split_point_props` lines 1381-1391 with:

```
-- Case split: does S_C have a carrier-point minimum?
by_cases h_pt_min : exists p : N.carrier,
    (extendPoint p) in S_C and
    forall q : N.carrier, (extendPoint q) in S_C -> p <= q
```

**Point-minimum case**: Set d = extendPoint p. hd_glb follows from p being the minimum. hd_le_an follows from a_bwd(n) being in S_C.

**Gap case**: Use `infimum_gap` with:
- h_ne: `continuation_set_nonempty`
- h_pt_below: from h_pt (existence of a point in [x', y'])
- h_above: from a_n_in_continuation_set + finding a point above a_n
- h_not_point_glb: from the negation of h_pt_min

Then use `infimum_gap_r_definable` to show the gap is in ExtendedCarrier N atomMap r.

### 5.2 The Claim 1 Proof (Priority 2)

New theorem in ExpressivenessGeneral.lean:

```lean
private theorem ghr93_claim_1
    (h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n + 1) (r + 1) ...)
    (hd_is_infimum : d = infimum of continuation_set)
    (hc_is_infimum : c = infimum of M-side continuation_set)
    : [forward strategy response at position n] = d
```

The proof uses:
1. C' = not-C or K^{-}(not-C) construction (stavi_depth r+1)
2. M_r |= C'(c) from the infimum properties
3. rank r+1 formula agreement from h_fwd_r1
4. N_r |= C'(d) transfer
5. d <= d-bar from C'(d)
6. Contradiction if d < d-bar

### 5.3 Sub-interval R+1 Strategy (Priority 3)

The sorry at line 3836 (providing h_fwd_r1 for sub-intervals) should be resolved by:
1. The r+1 forward strategy on [x,y] restricts to sub-intervals via strategy_restrict
2. d_consistency at rank r+1 follows from Claim 1 applied at one rank higher
3. The forward hypothesis provides rank r+4(n+1) >= r+2, so rank r+2 formulas are available for Claim 1 at rank r+1

### 5.4 Case II Restructure (Priority 4)

Follow GHR93 exactly:
1. tau response for positions 0..n-1 (line 2873, already exists)
2. Transfer U(B, A)(alpha_{n-1}) via tau -- needs rank r+4 formula preservation (available from Claim 2 style argument using the forward strategy)
3. Find z via U(B, A) witnesses in M
4. Verify rank-r formula agreement between e_n and alpha_n (both satisfy B = X_{alpha_n})

---

## 6. Key Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Infimum construction: h_not_point_glb proof complex | LOW | MEDIUM | `infimum_gap` preconditions are well-understood; use Classical.em on point-min |
| Claim 1: C' formula encoding in StaviFormula | LOW | MEDIUM | C is already a Prop-level predicate; C' can use stavi_temporal_truth_mu directly |
| Case II: U(B,A) transfer through tau preserves rank r+4 formulas | MEDIUM | HIGH | Claim 2 gives sub-interval strategies at rank r+4(n+1); tau preserves rank r+4 by construction |
| Sub-interval r+1 restriction: d_consistency at rank r+1 needs Claim 1 at r+2 | LOW | MEDIUM | Forward hypothesis at rank r+4(n+1) >= r+2 for all n >= 0 |
| The existing `d = x'` placeholder causes downstream breakage | LOW | LOW | The downstream code only uses hd_glb (lower-bound property), which becomes strictly stronger with the actual infimum |

---

## 7. Summary

| Finding | Detail |
|---------|--------|
| Report 29 is correct | Both infimum redefinition AND rank embedding are needed |
| Handoff-b is incorrect | "Keep d = a_bwd(n)" is wrong; d_consistency is literally false for d != d-bar |
| Report 27 is partially correct | Correct diagnosis, underestimates Case II restructure |
| Current code flaw | d = x' (placeholder), not the actual infimum |
| Rank embedding | Already sorry-free (EFGames.lean:610-700, 962-1090) |
| Infimum infrastructure | Already sorry-free (ExpressivenessGeneral.lean:109-930) |
| h_fwd_r1 parameter | Already propagated (ExpressivenessGeneral.lean:1096) |
| GHR93 hypothesis (**) | Universally quantified over ALL r; allows Claim 1 at any r' > r |
| Case II e_n | Must be constructed fresh (NOT c, NOT d-bar) via U(B,A) transfer |
| Overall estimate | 40-60 hours remaining (from current state to sorry-free bx_completeness) |
| Critical path bottleneck | Phase 1 (d-consistency) must be unblocked first |

### Recommended Next Step

Unblock Phase 1 by implementing the actual infimum construction at `obtain_split_point_props` (lines 1381-1391). All infrastructure exists and is sorry-free. The construction is a case split on whether S_C has a point minimum, using `infimum_gap` + `infimum_gap_r_definable` for the gap case. After this, Claim 1 and d_consistency follow, and the remainder of the critical path is unblocked.
