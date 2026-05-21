# Research Report: Task 155 — Reynolds Pipeline Phase 4C Status and Strategy

**Task**: 155 — reynolds_pipeline_activation
**Date**: 2026-05-20
**Mode**: Team Research (5 teammates: Primary, Alternatives, Critic, Horizons, Literature)
**Session**: sess_1779344336_02052f

## Summary

Phase 4C of the GHR93 game-theoretic proof is approximately 60% complete. Cases I and II of Theorem 6 are sorry-free (~1720 lines). 13 sorries remain in EFGames.lean (4) and ExpressivenessGeneral.lean (9), with 4 additional critical-path sorries elsewhere (Transfer.lean, IntegerModel.lean). The single biggest blocker is Lemma 9 (gap detection correctness), which blocks Cases III/IV and the entire assembly chain. All 5 teammates converge on a key insight: a `flatten_stavi_correct_mu` bridge lemma (~50-100 lines) is the critical prerequisite that unlocks Lemma 9's hard cases. The d-consistency sorries (lines 297, 307) require architectural restructuring — they are likely unprovable as currently stated.

## Key Findings

### 1. Sorry Inventory: 13 in Phase 4C, 17 on Full Critical Path

All teammates verified the 13-sorry count in EFGames.lean + ExpressivenessGeneral.lean. The Critic (C) identified 4 additional critical-path sorries outside Phase 4C:

| File | Sorries | Phase | Status |
|------|---------|-------|--------|
| EFGames.lean | 4 | 4C | Active |
| ExpressivenessGeneral.lean | 9 | 4C | Active |
| Transfer.lean (line 574) | 1 | 10 | BLOCKED |
| IntegerModel.lean (lines 859, 1135, 1194) | 3 | 7-8 | NOT STARTED |

### 2. Phase 10 Was Reverted — Handoff Is Inaccurate

**Conflict detected**: The Phase 10 handoff marks Tasks 10.3-10.5 as [x] complete. Git history shows commit `4ac2184e` (15 min after Phase 10 commit) **reverted the entire implementation** with message "revert Phase 10 (invalid approach), mark BLOCKED." Transfer.lean:574 still has `sorry`. The plan correctly marks Phase 10 as [BLOCKED], but the handoff checkboxes and "zero sorries" claim are wrong.

**Resolution**: Phase 10 remains BLOCKED. The `zIntervalTaskFrame` uses `WorldState = Unit`, making position-dependent atom truth impossible. This blocker is independent of Phases 4C-9 and requires architectural resolution.

### 3. D-Consistency Sorries Are Likely Unprovable As Stated

**Conflict detected**: Teammate A says "derivable from winning condition structure." Teammates B, C, and E say "structurally unprovable for non-deterministic strategies." The Critic provided the strongest evidence: the sorries assert that for ANY play with `c` at the boundary, the strategy MUST respond with exactly `d`. Since strategies are existential (non-deterministic), this is false in general. GHR93 resolves this by defining `d` as an infimum over all responses.

**Resolution (consensus)**: Restructure `obtain_split_point_props` using Teammate B's Alternative A — define `d` from the strategy's canonical response to a specific play, making the consistency condition `rfl` by construction. This eliminates 2 sorries at the cost of ~30 lines of restructuring + adjustment to `hd_eq_an` (becomes `d ≤ a_bwd(n)` inequality instead of equality).

### 4. The `flatten_stavi_correct_mu` Bridge Lemma Is the Key Prerequisite

All 5 teammates independently identified this as the critical missing piece:

```lean
theorem flatten_stavi_correct_mu (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat) (m : M.carrier) (A : StaviFormula) :
    temporal_truth_mu M atomMap r (extendPoint m) (flatten_stavi A) ↔
    stavi_temporal_truth_mu M atomMap r (extendPoint m) A
```

At actual points `extendPoint m`, mu-relativization restricts temporal operators to act only over actual points, which is exactly what `stavi_temporal_truth_mu` does. The proof is by structural induction on A (~50-100 lines). This lemma unblocks the S/S' cases of Lemma 9 — the paper's "Clear" dismissal conceals this requirement.

### 5. Sub-Interval Point Witnesses: Provable via Gap Structure

The 4 gap-case sorries (lines 336, 345, 351, 356) are provable using the `Gap` structure's `no_sup` property:
- `g.val.cut` is nonempty and has no supremum in the cut
- Therefore for any `q ∈ g.cut`, there exists `p ∈ g.cut` with `p > q`
- When `x' = extendPoint q` and `d = Sum.inr g`, we have `q ∈ g.cut`, giving witness `extendPoint p ∈ [x', d]`

Difficulty estimates varied (A: 10-15 lines each, B: 30-50 lines, C: 60-100 lines). Realistic estimate: **20-40 lines each**, requiring care with the `x' ≤ extendPoint p` bound when `x'` is itself a gap.

### 6. Implementation Is Faithful to GHR93 Literature

Teammate E's literature alignment analysis found:
- **Faithful**: Gap definitions (Def 8.3), mu-relativization (Def 8.4), game definition (Def 8.7), Theorem 6 case structure
- **Beneficial improvements**: Set-based type formulas (avoids finiteness argument), semantic decomposition_agreement (avoids syntactic FO construction)
- **Necessary adaptations**: Uniform rank in Theorem 6, flatten_stavi encoding for S/S' cases, d=a_bwd(n) instead of infimum
- **Critical naming collision**: "Reynolds Lemma 9" (gap elimination, Section 7) and "GHR93 Lemma 9" (gap detection, Section 8) are completely different theorems

### 7. Propositions 6-7 Are Entirely Unimplemented

Zero lines of code exist for Propositions 6, 7, or the Corollary 5 assembly. `stavi_expressive_completeness` is a single `sorry`. These represent 350-520 lines of from-scratch proofs. Proposition 7 requires the rank-varying Theorem 6 (also sorry'd at line 2571).

### 8. Lemma 11 Backward May Be Deferrable

Teammate B raised: if Proposition 7 uses only the forward direction of Lemma 11 (already proved), the backward sorry (line 2423) could be deferred. This needs verification against GHR93's Proposition 7 structure. **Potential saving: 1 sorry, ~80-120 lines**.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Basis |
|----------|-----------|-------|
| D-consistency provability | Unprovable as stated; restructure d definition | Critic + Alternatives evidence (strategies are non-deterministic) |
| Point witness difficulty | 20-40 lines each, gap no_sup argument | Synthesis of A (10-15) and C (60-100) estimates |
| Full sorry count | 13 Phase 4C + 4 elsewhere = 17 critical path | Critic's cross-file analysis |
| Phase 10 status | REVERTED, not completed | Git history verification |

### Recommended Implementation Order

**Wave 1 — Infrastructure (can start immediately, ~200-280 lines)**:
1. Restructure d-consistency in `obtain_split_point_props` (lines 297, 307) — define d from strategy response → 2 sorries eliminated
2. Close sub-interval point witnesses (lines 336, 345, 351, 356) via gap no_sup → 4 sorries eliminated
3. Develop `flatten_stavi_correct_mu` bridge lemma → prerequisite for Lemma 9

**Wave 2 — Lemma 9 (the bottleneck, ~200-350 lines)**:
4. Prove Lemma 9 left (`left_formula_gap_detection`, line 1423) — easy cases first (atom, bot, box, neg, conj: ~70 lines), then hard S/S' cases using bridge lemma (~130-200 lines)
5. Prove Lemma 9 right (line 1442) — symmetric, ~50 lines after left

**Wave 3 — Theorem 6 Completion (~280-400 lines)**:
6. Close c-gap-case in obtain_split_point_props (line 446) — uses Lemma 9, ~50-80 lines
7. Prove Cases III + IV (line 2350) — uses Lemma 9 + d-restructured infrastructure, ~230-350 lines

**Wave 4 — Assembly (~380-570 lines)**:
8. Close rank-varying Theorem 6 (line 2571) — transport via rank_embed, ~30-80 lines
9. Prove Proposition 6 (new) — formula agreement → games, ~100-150 lines
10. Prove Proposition 7 (new) — composition using Theorem 6 + Lemma 11, ~150-250 lines
11. Prove Corollary 5 / close stavi_expressive_completeness (line 2495) — ~80-120 lines

**Parallel track**: Lemma 11 backward (line 2423, ~80-120 lines) can proceed concurrently with any wave. Verify first whether Proposition 7 actually needs it.

### Effort Estimate

| Wave | Sorries Closed | Lines | Hours |
|------|---------------|-------|-------|
| Wave 1 (infrastructure) | 6 + new lemma | 200-280 | 4-6 |
| Wave 2 (Lemma 9) | 2 | 200-350 | 6-10 |
| Wave 3 (Theorem 6) | 2 | 280-400 | 6-10 |
| Wave 4 (assembly) | 2 + new proofs | 380-570 | 8-14 |
| Lemma 11 bwd (parallel) | 1 | 80-120 | 2-3 |
| **Phase 4C total** | **13** | **1140-1720** | **26-43** |

Full pipeline to sorry-free `bx_completeness`: 45-65 hours (including Phases 5'-11).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary | completed | high | Detailed sorry map with dependency ordering and mu-elimination insight |
| B | Alternatives | completed | high | D-consistency restructuring proposal, flatten_stavi_correct_mu specification |
| C | Critic | completed | high | Phase 10 revert discovery, full 17-sorry count, d-consistency unprovability |
| D | Horizons | completed | high | Infrastructure reuse value, parallelization of Phase 7, stable architecture assessment |
| E | Literature | completed | high | GHR93 alignment verification, S/S' encoding analysis, Reynolds naming collision |

## References

- GHR93 (Gabbay, Hodkinson, Reynolds 1993): Chapter 9, Section 8 — Theorem 6, Props 5-7, Corollary 5
- Reynolds 1994: Section 7, Lemmas 6-13, Theorem 14 (gap elimination)
- Literature markdown: `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Prior reports: 08_ghr93-game-theory.md, 09_lean-infrastructure-inventory.md
- Handoffs: phase-4C1, phase-4C2, phase-4C2-sorry-closing, phase-strategy-restrict
