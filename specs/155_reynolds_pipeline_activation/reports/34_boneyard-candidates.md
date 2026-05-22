# Boneyard Candidates: Orphaned Infrastructure in WeakCanonical

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Identify sorry'd code NOT on the critical path to sorry-free bx_completeness

---

## 1. Critical Path Summary

**CORRECTION (report 32)**: The omega-chain construction CAN produce gaps (Z+Z models). `succ_cofinal` cannot be closed from construction internals alone — it requires the full Reynolds gap elimination (Lemmas 6-14). The GHR93 infrastructure in EFGames/ExpressivenessGeneral IS the Reynolds pipeline and IS on the critical path.

The sorry chain to `bx_completeness`:
```
completeness_discrete → countermodel_discrete → dd_countermodel_chronicle_discrete
  → succ_cofinal (ROOT SORRY)
    ← needs Reynolds Theorem 14 (gap elimination)
      ← needs Reynolds Theorem 5 (US complete over Prior, Phase 5)
        ← needs stavi_expressive_completeness (Corollary 5, Phase 4)
          ← needs Cases III/IV (Phase 3) + Assembly chain (Phase 4)
            ← needs Lemma 9 (Phase 2, COMPLETE) + d-consistency (Phase 1)
```

**WeakCanonical IS on the critical path** via the Reynolds pipeline: Phases 1 → 3 → 4 → 5 → 6A → 6B → succ_cofinal → bx_completeness.

---

## 2. Confirmed Orphaned Theorems (grep evidence)

### EFGames.lean (2 sorry sites — ON CRITICAL PATH via Reynolds pipeline)

| Theorem | Line | Reynolds Role | Critical Path? |
|---------|------|---------------|----------------|
| `stavi_expressive_completeness` | 8983 | Corollary 5 → Phase 5 (Reynolds Thm 5) → Phase 6 (gap elimination) | **YES** — not yet wired but NEEDED |
| `ghr93_decomposition_implies_game` | 7680 | Lemma 11 backward → Assembly chain → Corollary 5 | **YES** |

**Note**: These are not yet called from the completeness proof because the Reynolds pipeline (Phases 5-6B) hasn't been built yet. Once Phases 5-6B are implemented, these theorems will be wired into the `succ_cofinal` proof via Reynolds Theorem 14.

### ExpressivenessGeneral.lean (8 sorry sites — ON CRITICAL PATH via Reynolds pipeline)

| Theorem | Line | Reynolds Role | Critical Path? |
|---------|------|---------------|----------------|
| `d_consistency_left` | 1170 | Phase 1 → enables Theorem 6 | **YES** |
| `d_consistency_right` | 1249 | Phase 1 | **YES** |
| `h_pt_xc` degenerate | 1564 | Phase 3 | **YES** |
| `h_pt_cy` degenerate | 1581 | Phase 3 | **YES** |
| c-gap-case | 1685 | Phase 3 | **YES** |
| Case II | 2851 | Phase 1 | **YES** |
| Cases III/IV | 3627 | Phase 3 → Theorem 6 → Corollary 5 | **YES** |
| rank-varying | 3838 | Phase 4 → Corollary 5 | **YES** |

**Note**: `ghr93_forward_to_backward` has zero callers NOW because the Reynolds pipeline (Phases 5-6B) hasn't been built. Once built, the chain flows: Theorem 6 → Corollary 5 → Reynolds Thm 5 → gap elimination → succ_cofinal → bx_completeness.

### IntegerModel.lean (3 sorry sites — ALL orphaned)

| Theorem | Line | Used By | Critical Path? |
|---------|------|---------|----------------|
| `no_gaps_discrete` | 859 | `one_class` | NO — `one_class` has 0 callers in BXCanonical/ |
| `cofinal_decomposition_k_equiv` | 1135 | `very_good_implies_good` | NO — `very_good_implies_good` has 0 callers |
| `ordered_sum_of_good_bounded_is_good` | 1194 | `very_good_implies_good` | NO |

### TruthLemma.lean (6 sorry sites — ALL orphaned)

All sorry sites are marked "non-critical-path" in comments. The WeakCanonical TruthLemma is NOT used by the BXCanonical truth lemma (which is a separate file at `BXCanonical/TruthLemma.lean`).

### OrderedSum.lean (1 sorry site — orphaned)

`doets_lemma_1_5` (line 56) — bypassed in discrete case by `one_class`, which is itself orphaned.

---

## 3. Sorry-Free Files (PRESERVE — no changes needed)

12 of 18 WeakCanonical files are already sorry-free:
- ChronicleExtraction.lean, ExpressiveCompleteness.lean, FrameProperties.lean
- MonadicFO.lean, NEquivalence.lean, NormalForm.lean
- ReflexiveCanonical.lean, Separation.lean, StaviConnectives.lean
- Table.lean, Transfer.lean, WeakCanonical.lean

---

## 4. Recommended Archival

### Tier 1: Can archive immediately (orphaned, sorry'd, not on any path)

| File/Component | Lines | Reason |
|----------------|-------|--------|
| IntegerModel.lean: `very_good_implies_good` + helpers (`cofinal_decomposition_k_equiv`, `ordered_sum_of_good_bounded_is_good`) | ~180 | Never used, `cofinal_decomposition_k_equiv` is incorrectly stated |
| IntegerModel.lean: `no_gaps_discrete` + `one_class` | ~100 | `one_class` has 0 callers, `no_gaps_discrete` is sorry'd |
| OrderedSum.lean: `doets_lemma_1_5` | ~20 | Bypassed by `one_class` which is itself unused |
| TruthLemma.lean: all 6 sorry'd theorems | ~130 | All marked "non-critical-path", not used by BXCanonical |
| **Subtotal** | **~430** | |

### Tier 2: Reynolds pipeline (CRITICAL PATH — must complete for sorry-free bx_completeness)

| File/Component | Lines | Role in Pipeline |
|----------------|-------|-----------------|
| EFGames.lean: `left_formula_gap_detection` + `right_formula_gap_detection` | ~5000 | GHR93 Lemma 9 — FULLY PROVED |
| EFGames.lean: `stavi_expressive_completeness` | ~100 | GHR93 Corollary 5 → Reynolds Thm 5 → gap elimination |
| EFGames.lean: `ghr93_decomposition_implies_game` | ~30 | Lemma 11 backward → Assembly chain |
| ExpressivenessGeneral.lean: GHR93 Theorem 6 chain | ~3800 | Phases 1, 3, 4 → Corollary 5 |
| **Subtotal** | **~8930** | **CRITICAL — Reynolds pipeline infrastructure** |

### Tier 3: Infrastructure used by Tier 2 (keep if Tier 2 kept)

| File/Component | Lines | Depends On |
|----------------|-------|-----------|
| IntegerModel.lean: `chronicle_is_good`, `contemp_equiv_is_equiv` | ~400 | Used by Transfer.lean (on critical path) — KEEP |
| StaviConnectives.lean | ~800 | Used by EFGames.lean — KEEP |
| NormalForm.lean, Table.lean | ~1500 | Used by EFGames.lean — KEEP |

---

## 5. Build Impact

Archiving Tier 1 (~430 lines) would:
- Remove 10 sorry sites from the WeakCanonical directory
- Reduce `lake build` time marginally (these are small theorems with sorry bodies)
- Simplify the sorry inventory
- NOT affect bx_completeness (none are on the critical path)

The WeakCanonical directory would go from 20 sorry sites to 10 (the ExpressivenessGeneral + EFGames standalone formalization).

---

## 6. Summary (CORRECTED per report 32)

| Category | Sorry Sites | Lines | Action |
|----------|-------------|-------|--------|
| Reynolds pipeline (WeakCanonical + ChronicleToCountermodel) | 14 | ~9330 | CLOSE — full Reynolds pipeline (Phases 1-6B) |
| Genuinely orphaned (Tier 1: archive) | 10 | ~430 | Archive to Boneyard |
| Sorry-free infrastructure | 0 | ~6000 | Preserve |

**The full Reynolds pipeline is necessary.** The omega-chain construction CAN produce gaps (report 32). `succ_cofinal` requires Reynolds Theorem 14 (gap elimination), which requires the full GHR93 → Reynolds chain (Phases 1-6B). Closing succ_cofinal from construction internals alone is NOT possible.

**Remaining critical path**: Phase 1 (d-consistency, ~400-600 lines) → Phase 3 (Cases III/IV, ~240-360 lines) → Phase 4 (Assembly + Corollary 5) → Phase 5 (Reynolds Thm 5, ~100 lines) → Phases 6A-6B (gap elimination, ~1000-1500 lines) → succ_cofinal → bx_completeness.
