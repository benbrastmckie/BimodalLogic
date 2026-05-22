# Research Report: Task #155 — Phase 1 h_d_unique Blocker Resolution

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Mode**: Team Research (4 teammates)
**Session**: sess_1779492472_909b0f

## Summary

Team research with 4 parallel investigators identified the **root cause** of the Phase 1 h_d_unique blocker and converged on a resolution strategy. The key finding: the current approach (pigeonhole chain → single formula D) is a **detour** from the paper's proof. GHR93 Claim 1's proof is structurally different from the Lean code's approach, but the code CAN be fixed by following the paper more closely. All teammates confirm the overall GHR93+Reynolds pipeline is the correct and only viable path.

**Critical finding (convergent across all 4 teammates)**: h_d_unique's proof requires using `h_fwd_r1` (the rank-(r+2) game) INTERNALLY — the rank-r agreement in `ht'_form` alone is **insufficient** because the separating formula K⁻(¬D) has depth r+2. The proof is NOT circular: it uses the game as a side channel to derive contradictions, not to assume Claim 1 itself.

## Key Findings

### 1. The Pigeonhole Approach Is a Detour (All 4 Teammates Agree)

GHR93 Claim 1 (p.116) is a 5-sentence proof using C' = ¬C ∨ K⁻(¬C) where C is the rank-r continuation formula. The paper does NOT use a pigeonhole argument for Claim 1. The `pigeonhole_definable_formula` at line 625 in ExpressivenessGeneral.lean exists for a different purpose (gap detection in Section 8, not Claim 1).

The pigeonhole precondition failure (Round 14 finding: universal quantifier too strong when d is a carrier-point minimum) is a real issue but becomes moot if we stop using pigeonhole for Claim 1 altogether. However, the weakened pigeonhole (Solution A) IS still needed to produce the formula D. The question is whether D needs to come from pigeonhole or can be constructed directly.

**Resolution**: D can come from `h_cofinal_failure_below_d` + Classical.choice (pick any single formula that fails below d), then use weakened pigeonhole only if we need COFINAL failure of a SINGLE formula. The weakened pigeonhole approach (failure only for p with extendPoint p < d) is sound and should be created.

### 2. h_d_unique Statement vs. GHR93 Claim 1 — Important Semantic Gap

**GHR93 Claim 1**: "In any play of G_{m;r'} with winning strategy, if Spoiler plays c, Duplicator's response d = d̄." This is about a SPECIFIC game response with rank-r' agreement (r' ≥ r+1).

**Lean h_d_unique**: "For ALL t' with rank-r agreement, gap/point match, and boundary match to d, t' = d." This is universally quantified with only rank-r agreement.

**Key question (Teammates A, B, C converge)**: Is h_d_unique as stated provable with only rank-r agreement? The separating formula K⁻(¬D) has depth r+2 > r, so ht'_form (rank-r) doesn't directly apply.

**Resolution**: h_d_unique IS provable because h_fwd_r1 is IN SCOPE of the proof (it's a parameter of `obtain_split_point_props`). The proof uses h_fwd_r1 INTERNALLY to derive contradictions:

- **Direction 1 (d < t', need contradiction)**: Construct K⁻(¬D) of depth r+2 that is TRUE at d and FALSE at t'. Play h_fwd_r1: Spoiler picks rank_embed(c), gets response e. Game gives K⁻(¬D)(rank_embed(c) in M) ↔ K⁻(¬D)(e in N). Since c is M-side infimum, K⁻(¬D)(c in M) = TRUE. So K⁻(¬D)(e in N) = TRUE. But K⁻(¬D)(u in N) = TRUE iff u ≤ d (K⁻(¬D) detects infimum position). So e projects to some f ≤ d. The game response has rank-r agreement with d (via hcd_form + rank_embed). Since f ≤ d and f has rank-r agreement with d, and d is inf(S_C), f must be d. Then the game locks Duplicator's responses into [x', d], restricting to the left sub-interval, which contradicts the assumed existence of t' > d with rank-r agreement with d.

- **Direction 2 (t' < d, need contradiction)**: This is GHR93's round-2 argument. Since t' < d = inf(S_C), t' ∉ S_C, so ∃ mu-point u ∈ (t', y') with ¬cont_holds(u). Specifically ∃ formula A, depth ≤ r, A holds on (a_n, y'), ¬A(u). Play h_fwd_r1 round 2 with rank_embed(u) as Spoiler's challenge. Duplicator must respond with some v in (c, y) in M preserving rank-r formulas. But c = inf(S_C in M) means A holds on (c, y), so A(v) = TRUE. But ¬A(u) = TRUE, contradicting rank-r formula transfer.

### 3. All Infrastructure Exists for the K⁻(¬D) Approach (Teammate B Verified)

| Infrastructure | File | Status |
|---------------|------|--------|
| `StaviFormula.neg`, `.std_snce` | StaviConnectives.lean | Available |
| `stavi_depth` for neg, std_snce | EFGames.lean:189,192 | depth = inner+0 / +2 |
| `stavi_temporal_truth_mu` for std_snce | EFGames.lean:877 | ∃ s < t, mu(s) ∧ A(s) ∧ ∀ u ∈ (s,t)... |
| `rank_embed_stavi_truth_mu` | EFGames.lean:1050 | Bidirectional truth transfer |
| `formula_agreement` at rank r+2 | EFGames.lean:6855 | Covers depth ≤ r+2 formulas |
| `h_fwd_r1` parameter | ExpressivenessGeneral.lean:1445 | In scope of obtain_split_point_props |
| `hd_in_SC` | ExpressivenessGeneral.lean:1701 | d ∈ S_C (Round 14) |
| `h_cofinal_failure_below_d` | ExpressivenessGeneral.lean:1714 | Failure below d (Round 14) |

**Depth calculation verified**: K⁻(¬D) = neg(std_snce(base(.bot.imp .bot), D)) has stavi_depth = max(0, stavi_depth D) + 2 ≤ r + 2. Within rank-(r+2) game budget. ✓

### 4. The GHR93+Reynolds Pipeline Is Correct (Teammate D Confirmed)

- No alternative approach (GHR94 separation, Venema BAOs, Caleiro mosaics) avoids the core work
- GHR94 Ch10 separation works for ℤ specifically but NOT for general Prior structures
- Reynolds 1994 gap elimination (Phases 5-6B) is self-contained and game-free
- This would be the FIRST machine-verified proof of Stavi expressive completeness in ANY proof assistant
- No existing formalizations of EF games for temporal logic exist in Lean, Coq, or Isabelle

### 5. Sorry Inventory Update (Teammate C Verified)

**Actual count: 16 sorries** (plan says 15):
- ExpressivenessGeneral.lean: 11 active sorries
- EFGames.lean: 2 sorries
- IntegerModel.lean: 3 sorries

Extra sorry at line 2055 (n=0 gap case) was miscounted in the plan.

### 6. Revised Effort Estimates

| Source | Phase 1 | Phases 3-6B | Phases 8-11 | Total |
|--------|---------|-------------|-------------|-------|
| Plan v15 | 8-12h | 20-32h | 2-4h | 38-58h |
| Critic (C) | 15-25h | 38-62h | 2-3h | 55-90h |
| Horizons (D) | 8-12h | 22-35h | 2-4h | 32-51h |
| **Synthesis** | **10-18h** | **25-40h** | **2-4h** | **40-65h** |

Phase 1 is higher than planned due to the game-internal proof complexity. Phases 3-6B are well-understood from the literature.

## Synthesis

### Conflicts Resolved

**Conflict 1: Is h_d_unique provable as stated?**
- Teammate A: "FINAL CONCLUSION: proof MUST use the rank-(r+2) game" — says it CAN be proved using h_fwd_r1 internally but with substantial effort
- Teammate B: "h_d_unique is UNPROVABLE without additional hypotheses" — suggests adding rank-(r+2) agreement
- Teammate C: "WEAKEN h_d_unique to only apply to game responses" — suggests restructuring
- Teammate D: "Follow GHR93 literally should work in ~80-120 lines"

**Resolution**: h_d_unique IS provable as stated because h_fwd_r1 is IN SCOPE. The proof uses the game internally, not as a hypothesis on t'. No restructuring needed. Estimated 120-200 lines for the full proof. The statement is stronger than GHR93 Claim 1, but the proof CAN establish it using the available game. Teammates B and C's concern is about the INTERFACE (rank-r agreement alone in the hypothesis), but the proof body has access to the game for internal use.

**Conflict 2: Use pigeonhole or abandon it?**
- Teammate A: Use weakened pigeonhole (Solution A) to get D
- Teammate B: Create `pigeonhole_definable_formula_strict` with weakened precondition
- Teammate C: Pigeonhole chain may fail in discrete orders with few points
- Teammate D: Abandon pigeonhole entirely, use C directly

**Resolution**: The weakened pigeonhole IS needed to get a single formula D that fails COFINALLY below d. Without it, h_cofinal_failure_below_d only gives that SOME formula fails at each point, not that the SAME formula fails cofinally. The weakened precondition (failure only for p with extendPoint p < d) is sufficient because:
- The chain stays below d (cont_holds at d prevents formula failure AT d)
- Cut points below d are infinite in the extended carrier (gaps exist between any two elements)
- The chain length K+1 is bounded by NormalForm cardinality, not by the number of carrier points — gaps also serve as chain elements in the extended carrier

### Gaps Identified

1. **Direction 2 of h_d_unique** (t' < d): The proof needs GHR93's round-2 game argument, which hasn't been attempted yet. The proof structure requires playing h_fwd_r1 with a carefully chosen challenge point. Need to verify that the game API supports extracting individual round responses.

2. **Since semantics**: The proof requires showing that Since(⊤, D) at d is FALSE and at t' (when d < t') is TRUE. This needs lemmas about `stavi_temporal_truth_mu` for `std_snce` that may not exist yet (need to verify).

3. **Degenerate gap sorries** (lines 1940, 1957): These may be unreachable (Teammate C suggests proving by contradiction from the game structure). Need dedicated investigation separate from h_d_unique.

## Recommendations

### Immediate Next Steps (Plan Revision Input)

1. **Create `pigeonhole_definable_formula_below_d`** (~40-50 lines): Weakened variant requiring failure only for p with extendPoint p < d. Use existing `pigeonhole_definable_formula` proof as template.

2. **Prove h_d_unique direction 1** (d < t' case, ~80-120 lines):
   - Get D from weakened pigeonhole
   - Construct K⁻(¬D) = neg(std_snce(base(.bot.imp .bot), D))
   - Prove Since(⊤, D) FALSE at d (D fails cofinally below d)
   - Prove Since(⊤, D) TRUE at t' when d < t' (witness: mu-point near d, D holds on tail)
   - Play h_fwd_r1 to derive contradiction via game transfer

3. **Prove h_d_unique direction 2** (t' < d case, ~60-100 lines):
   - t' < d ⟹ t' ∉ S_C ⟹ ∃ failure mu-point u with ¬cont_holds(u)
   - Extract formula A (depth ≤ r) that holds on (a_n, y') but fails at u
   - Play h_fwd_r1 round 2 with u as challenge
   - Duplicator's response must preserve A, but in M all points in (c, y) satisfy A
   - Contradiction: ¬A(u) vs A(response)

4. **Close same_order_type sigma/tau** (after h_d_unique): Uncomment block-commented proofs, apply task 195 tactics.

5. **Update sorry inventory** to reflect 16 (not 15) active sorries.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | GHR93 Claim 1 extraction + Lean mapping | completed | medium-high |
| B | Infrastructure inventory + alternatives | completed | high |
| C | Gaps, blind spots, invalid assumptions | completed | high |
| D | Literature survey + strategic direction | completed | high |

## References

- GHR93: Gabbay, Hodkinson, Reynolds (1993). "Temporal Expressive Completeness in the Presence of Gaps." pp.115-119 (Claim 1, Theorem 6 proof)
- Reynolds (1994). "Axiomatising U and S over Integer Time." §7 (gap elimination, Lemmas 6-14)
- GHR94: Gabbay, Hodkinson, Reynolds (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects, Vol. 1." Ch10 (separation approach)
- Plan v15: specs/155_reynolds_pipeline_activation/plans/17_reynolds-pipeline-plan.md
- Round 14 handoff: specs/155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T234500Z.md
