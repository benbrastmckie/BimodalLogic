# Boneyard Candidates: Orphaned Infrastructure in WeakCanonical

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Identify sorry'd code NOT on the critical path to sorry-free bx_completeness

---

## 1. Critical Path Summary

The sorry chain to `bx_completeness` (`completeness_discrete`) goes through:
```
completeness_discrete → countermodel_discrete_enriched → countermodel_discrete
  → dd_countermodel_chronicle_discrete → succ_cofinal (ROOT SORRY)
```

**Nothing in WeakCanonical/ is on the critical path.** The `countermodel_discrete` in Transfer.lean delegates directly to `dd_countermodel_chronicle_discrete` in ChronicleToCountermodel.lean. The WeakCanonical infrastructure (EFGames, ExpressivenessGeneral, IntegerModel, etc.) is imported by WeakCanonical.lean but none of its sorry'd theorems propagate into `bx_completeness`.

---

## 2. Confirmed Orphaned Theorems (grep evidence)

### EFGames.lean (2 sorry sites — BOTH orphaned)

| Theorem | Line | References Outside Definition | Status |
|---------|------|-------------------------------|--------|
| `stavi_expressive_completeness` | 8983 | **0** (only self-definition) | ORPHANED |
| `ghr93_decomposition_implies_game` | 7680 | 1 (self-call at 7708) | ORPHANED (used only by itself recursively) |

**Evidence**: `grep -rn "stavi_expressive_completeness" Theories/Bimodal/` returns only the definition line. `grep -rn "ghr93_decomposition_implies_game"` returns the definition + one recursive self-call.

### ExpressivenessGeneral.lean (8 sorry sites — ALL orphaned for bx_completeness)

| Theorem | Line | Used By | Critical Path? |
|---------|------|---------|----------------|
| `d_consistency_left` | 1170 | `obtain_split_point_props` | NO — `ghr93_forward_to_backward` has 0 callers |
| `d_consistency_right` | 1249 | `obtain_split_point_props` | NO |
| `h_pt_xc` degenerate | 1564 | `obtain_split_point_props` | NO |
| `h_pt_cy` degenerate | 1581 | `obtain_split_point_props` | NO |
| c-gap-case | 1685 | `obtain_split_point_props` | NO |
| Case II | 2851 | `ghr93_case_II` | NO |
| Cases III/IV | 3627 | `ghr93_inductive_step` | NO |
| rank-varying | 3838 | standalone | NO |

**Evidence**: `ghr93_forward_to_backward` has **zero callers** outside its own file (confirmed by grep). The entire GHR93 Theorem 6 chain (d_consistency → split points → Cases I-IV → forward_to_backward → rank_varying) is standalone formalization work not wired into the completeness proof.

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

### Tier 2: Valuable standalone formalization (keep but mark as non-critical)

| File/Component | Lines | Reason to Keep |
|----------------|-------|---------------|
| EFGames.lean: `stavi_expressive_completeness` | ~100 | GHR93 Corollary 5 — important theorem even if not wired in |
| EFGames.lean: `ghr93_decomposition_implies_game` | ~30 | GHR93 Lemma 11 backward |
| EFGames.lean: `left_formula_gap_detection` + `right_formula_gap_detection` | ~5000 | GHR93 Lemma 9 — FULLY PROVED, major achievement |
| ExpressivenessGeneral.lean: entire GHR93 Theorem 6 chain | ~3800 | GHR93 Section 8 formalization |
| **Subtotal** | **~8930** | Keep — valuable formalization |

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

## 6. Summary

| Category | Sorry Sites | Lines | Action |
|----------|-------------|-------|--------|
| Critical path (ChronicleToCountermodel) | 4 | ~400 | CLOSE (succ_cofinal) |
| Orphaned (Tier 1: archive) | 10 | ~430 | Archive to Boneyard |
| Standalone formalization (Tier 2: keep) | 10 | ~8930 | Keep, mark non-critical |
| Sorry-free infrastructure | 0 | ~6000 | Preserve |

**The single most impactful action**: close `succ_cofinal` Step 9 (~200-500 lines in ChronicleToCountermodel.lean). This makes bx_completeness sorry-free without touching any WeakCanonical sorry sites.
