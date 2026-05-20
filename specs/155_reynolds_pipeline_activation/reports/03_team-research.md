# Research Report: Task #155 — Reynolds Pipeline Activation (Round 3)

**Task**: 155 — reynolds_pipeline_activation
**Date**: 2026-05-20
**Mode**: Team Research (4 teammates)
**Session**: sess_1779292320_2adf4b

---

## Summary

Four teammates independently verified the sorry chain, assessed the reported blockers, inventoried sorry-free infrastructure, and evaluated strategic direction. The findings converge on a clear picture: there are exactly TWO independent sorry channels blocking `bx_completeness`, the Phase 1 "box modality mismatch" blocker is real but solvable (not fundamental), `chronicle_is_good` is already sorry-free (the sorry lives in `extract_chronicle_as_prior`), and the Reynolds Lemma 16 path is the only viable route since `succ_cofinal` is mathematically unprovable from existing axioms.

---

## Key Findings

### 1. Two Independent Sorry Channels (Verified by All Teammates)

**Channel A — IsSuccArchimedean (deep structural sorry)**:
```
bx_completeness
  → countermodel_discrete (Transfer.lean:344)
    → orderIsoIntOfLinearSuccPredArch [needs IsSuccArchimedean instance]
    → extract_chronicle_as_prior (ChronicleExtraction.lean:153)
      → limitDomSubtype_isSuccArchimedean
        → succ_cofinal (ChronicleToCountermodel.lean:1563) [SORRY — leaf]
```

**Channel B — Transfer.lean explicit sorries (4 sites)**:

| File | Line | Name | Difficulty |
|------|------|------|-----------|
| Transfer.lean | 332 | `Nonempty sig.preds` | TRIVIAL (~20 lines) |
| Transfer.lean | 186 | `chronicle_temporal_truth` | MEDIUM (~100-150 lines) |
| Transfer.lean | 276/286 | `z_interval_countermodel` (valuation bug + bridge) | MEDIUM-HIGH (~150-200 lines) |
| Transfer.lean | 371 | inline `h_chronicle_truth` | TRIVIAL (follows from line 186) |

Both channels must be closed. Channel B is independent of Channel A.

### 2. `chronicle_is_good` Is Already Sorry-Free

All 4 teammates independently verified via `lean_verify`: `chronicle_is_good` returns only `propext`, `Classical.choice`, `Quot.sound` — **no `sorryAx`**. The sorry propagates through `extract_chronicle_as_prior` (which fills the `domain_succ_archimedean` field with the sorry'd `limitDomSubtype_isSuccArchimedean`), not through `chronicle_is_good` itself.

**Implication**: The v3 plan's framing of Phase 2 as making `chronicle_is_good` sorry-free is incorrect — it's already sorry-free. Phase 2 is needed to make `very_good_implies_good` sorry-free, which enables an ALTERNATIVE proof of `chronicle_is_good` that avoids requiring `IsSuccArchimedean` from `extract_chronicle_as_prior`.

### 3. The Phase 1 Box Modality Mismatch Is Real But Solvable

All teammates confirmed the structural mismatch:
- `temporal_truth M atomMap t (.box φ)` = `M.interp (atomMap (.box φ)) t` — **predicate lookup**
- `truth_at M Omega τ t (Formula.box φ)` = `∀ σ ∈ Omega, truth_at M Omega σ t φ` — **universal quantification over histories**

The v3 plan's claim that the box case is "trivial (single S5 class)" is **wrong** (Teammate C). It conflates accessibility of worlds with the match between predicate lookup and universal quantification.

**Resolution approaches identified**:
- **Teammate A**: Add an explicit hypothesis `h_box_correct : ∀ ψ s, Z.interp (atomMap_fwd (.box ψ)) s.val ↔ temporal_truth Z atomMap_fwd s ψ` to `z_interval_countermodel`. This hypothesis IS satisfiable by the specific Z-interval from `chronicle_is_good`.
- **Teammate B**: With WorldState = ℤ and `states t _ = t`, all histories return state `t` at time `t`, making `truth_at` independent of history choice. The box case then requires proving `Z.interp (atomMap_fwd (.box ψ)) t` equals `∀ t', temporal_truth Z atomMap_fwd ⟨t', _⟩ ψ` — which follows from the chronicle's S5 properties.
- **Teammate D**: Prove only the countermodel direction (`temporal_truth → ¬truth_at`) to halve the proof obligation. Also consider singleton `Omega = {zIntervalHistory}`.

**Synthesis recommendation**: Use WorldState = ℤ with `states t _ = t`. With this construction, all histories in `Omega = Set.univ` give identical atom truth at any position (since `valuation z a = Z.interp (atomMap_fwd (.atom a)) z` depends only on position `z`, not history). The box universal quantification collapses: `∀ σ ∈ Set.univ, truth_at TM Set.univ σ t ψ = truth_at TM Set.univ τ t ψ` for any τ (by induction on ψ, since atom truth is history-independent). Then box truth = ψ truth at position t. The Z-interval's `.box ψ` predicate must match ψ truth — provable from the chronicle's MCS box-closure property (if `□ψ ∈ fmcs t` then `ψ ∈ fmcs t'` for all `t'`; and in the chronicle's single S5 class, `□ψ ∈ fmcs t ↔ ψ ∈ fmcs t'` for all `t, t'`). An `h_box_correct` hypothesis makes this explicit and is satisfied by the chronicle's Z-interval witness.

### 4. Phase 2 (IntegerModel Sorries) Is Conditionally Needed

**Critic's key insight**: Phase 2 is only needed if the Reynolds Lemma 16 bypass is adopted. Since `chronicle_is_good` is already sorry-free, Phase 2 work (`cofinal_decomposition_k_equiv`, `ordered_sum_of_good_bounded_is_good`) is ONLY valuable if Phase 3 succeeds and we rewrite `chronicle_is_good` to use `very_good_implies_good` instead of `orderIsoIntOfLinearSuccPredArch`.

However, since `succ_cofinal` is mathematically unprovable (Teammate D: the Z+Z gap scenario is consistent with all axioms under strict semantics), the Reynolds Lemma 16 bypass IS the only viable path. Phase 2 IS needed — just not independently.

**On the EF-game claim**: Teammate A argues `cofinal_decomposition_k_equiv` does NOT require a full EF framework — normal-form evaluation preservation (~80-120 lines) suffices using existing `nf_eval_nf` infrastructure. This should be significantly less work than the 200+ lines originally estimated.

### 5. Phase Execution Order Should Change

All teammates recommend starting with Phase 4 (chronicle truth lemma):

| Priority | Phase | Rationale |
|----------|-------|-----------|
| 1st | Phase 4: `chronicle_temporal_truth` | Independent, medium difficulty, highest-value bridge lemma |
| 2nd | Nonempty sig.preds (from Phase 1) | Trivial, instant win |
| 3rd | Phase 1: `z_interval_countermodel` fix | Requires architectural refactor (WorldState = ℤ) + box case |
| 4th | Phase 3: Gap elimination (Reynolds Thm 14) | Longest phase, 6+ hours |
| 5th | Phase 2: IntegerModel sorries | Only needed after Phase 3 commits to Lemma 16 path |
| 6th | Phase 5: Rewrite chronicle_is_good | Low risk given Phases 2-4 |
| 7th | Phase 6: Final verification | Verification only |

### 6. Complete Sorry-Free Infrastructure Inventory (Verified)

All verified via `lean_verify` — no `sorryAx`:

| Theorem | File | Status |
|---------|------|--------|
| `chronicle_is_good` | IntegerModel.lean | SORRY-FREE |
| `one_class` | IntegerModel.lean | SORRY-FREE |
| `no_gaps_discrete` | IntegerModel.lean | SORRY-FREE |
| `no_boundary_at_successor` | IntegerModel.lean | SORRY-FREE |
| `finite_structures_good` | IntegerModel.lean | SORRY-FREE |
| `contemp_equiv_is_equiv` | IntegerModel.lean | SORRY-FREE |
| `good_of_split_at_succ` | IntegerModel.lean | SORRY-FREE |
| `truth_transfer` | Transfer.lean | SORRY-FREE |
| `k_equiv_preserves_sentence` | Transfer.lean | SORRY-FREE |
| `table_correctness` | Table.lean | SORRY-FREE |
| `doets_lemma_1_1` | NormalForm.lean | SORRY-FREE |
| `doets_lemma_1_4` | OrderedSum.lean | SORRY-FREE |
| `separation_theorem_int` | SeparationThm.lean | SORRY-FREE (zero axioms!) |
| `countermodel_dense` | ChronicleToCountermodel.lean | SORRY-FREE |
| `dd_countermodel_chronicle_mixed_sorry` | ChronicleToCountermodel.lean | SORRY-FREE |

Verified SORRY-PRESENT:

| Theorem | File | Sorry Source |
|---------|------|-------------|
| `succ_cofinal` | ChronicleToCountermodel.lean:1563 | Leaf sorry |
| `extract_chronicle_as_prior` | ChronicleExtraction.lean:144 | via succ_cofinal |
| `chronicle_temporal_truth` | Transfer.lean:186 | Leaf sorry |
| `z_interval_countermodel` | Transfer.lean:258 | Leaf sorry + architecture bug |
| `countermodel_discrete` | Transfer.lean:312 | Aggregates all above |
| `very_good_implies_good` | IntegerModel.lean:1154 | via 2 helper lemmas |
| `cofinal_decomposition_k_equiv` | IntegerModel.lean:1079 | Leaf sorry |
| `ordered_sum_of_good_bounded_is_good` | IntegerModel.lean:1138 | Leaf sorry |
| `bx_completeness` | Completeness.lean | via countermodel_discrete |

### 7. Untracked Sorry and Potential Cascade

**OrderedSum.lean:56**: Teammate D flagged a sorry in this file that was not in the plan's inventory. Teammate C verified `doets_lemma_1_5` has a sorry here. Needs critical-path verification — if it feeds into `very_good_implies_good`, it's an additional blocker for the Lemma 16 path.

**NEquivalence.lean IsSuccArchimedean instance** (line ~1215): Teammate D flagged that removing `domain_succ_archimedean` from `ChronicleAsPriorModel` may break this instance. Must be checked before Phase 5.

### 8. Time Estimates

| Phase | Plan | Revised (Consensus) |
|-------|------|---------------------|
| Phase 1 (Transfer bridges) | 2h | 4-8h (box case is hard) |
| Phase 2 (IntegerModel sorries) | 4h | 4-6h (NF approach, not EF) |
| Phase 3 (Gap elimination) | 6h | 10-15h (Reynolds Thm 14 is 6 pages) |
| Phase 4 (Chronicle truth lemma) | 3h | 3-6h (standard but careful) |
| Phase 5 (Rewrite chronicle_is_good) | 2h | 2h |
| Phase 6 (Verification) | 1h | 1h |
| **Total** | **18h** | **24-38h** |

---

## Synthesis

### Conflicts Resolved

1. **WorldState = Unit vs. ℤ**: Teammates A, B recommend ℤ; Teammate C says neither fixes box. **Resolution**: WorldState = ℤ IS correct for atoms (fixes the valuation bug) and makes the box case tractable (all histories agree on truth at any position). The box case still requires an explicit `h_box_correct` hypothesis or proof that the chronicle's Z-interval satisfies box correspondence. The mismatch is real but solvable with careful engineering.

2. **Is Phase 2 needed?**: Teammates C notes it's conditional; Teammate D says it IS needed since succ_cofinal is unprovable. **Resolution**: Phase 2 IS needed for the final architecture, but should not be started until Phase 3 commits to the Lemma 16 path.

3. **EF-game necessity**: Teammate A says no (NF preservation suffices, ~80-120 lines). **Resolution**: Attempt NF preservation approach first; fall back to more elaborate argument if needed.

### Gaps Identified

1. **OrderedSum.lean:56 sorry**: Not in the plan inventory. Critical-path status unknown.
2. **NEquivalence.lean cascade**: Removing `domain_succ_archimedean` may break an IsSuccArchimedean instance in NEquivalence.lean.
3. **Box case proof strategy**: No teammate provided a complete, concrete proof sketch. The `h_box_correct` approach (Teammate A) is the cleanest but adds a hypothesis that must be discharged at the call site.
4. **Until/Since cases in chronicle_temporal_truth**: All teammates note these require the chronicle's resolution lemmas, but none provided concrete Lean proof strategies for extracting these from `ChronicleAsPriorModel` fields.

### Recommendations

**The implementation path should be**:

1. **Pre-flight**: Verify `OrderedSum.lean:56` critical-path status and `NEquivalence.lean` cascade risk.

2. **Wave 1 (independent)**:
   - Close `Nonempty sig.preds` (trivial, ~20 lines)
   - Prove `chronicle_temporal_truth` (medium, ~100-150 lines, standard induction)

3. **Wave 2 (depends on Wave 1 diagnosis)**:
   - Fix `z_interval_countermodel`: WorldState = ℤ refactor + add `h_box_correct` hypothesis + prove inductive bridge
   - OR: restructure `countermodel_discrete` to avoid `z_interval_countermodel` if the box case proves intractable

4. **Wave 3 (Reynolds Lemma 16 path)**:
   - Phase 3: Gap elimination (Reynolds Theorem 14, Lemmas 6-13) — rewrite `no_gaps_discrete` without `IsSuccArchimedean`
   - Phase 2: Close `cofinal_decomposition_k_equiv` (NF preservation) and `ordered_sum_of_good_bounded_is_good` (shift-and-glue)

5. **Wave 4 (assembly)**:
   - Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good`
   - Remove `domain_succ_archimedean` from `ChronicleAsPriorModel`
   - Wire into `countermodel_discrete`
   - Final verification: `#print axioms bx_completeness` shows no `sorryAx`

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary/Pipeline | completed | high | Sorry chain map, box case analysis, two-path assessment |
| B | Infrastructure | completed | high | Complete sorry-free inventory, Reynolds step mapping |
| C | Critic | completed | high | chronicle_is_good sorry-free finding, plan dependency critique |
| D | Horizons | completed | high | Strategic analysis, OrderedSum.lean flag, time estimate revision |

---

## References

- Reynolds 1994: "Axiomatising first-order temporal logic: Until and Since over linear time" (literature/Reynolds_1994_*.md)
- Previous research: reports/01_team-research.md, reports/02_team-research.md, reports/03_post-157-status.md
- Handoffs: handoffs/phase-0-handoff-20260520.md through phase-5-handoff-20260516.md
- Lean verification: All sorry-free claims verified via `lean_verify` MCP tool
