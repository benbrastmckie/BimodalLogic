# Implementation Plan: Reynolds Pipeline Activation (v35 revised, Phase 6C decomposed)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phases 1-4, 3A, 6A complete; Phase 6B superseded; Phase 6C decomposed into 6C-1 through 6C-5 to address nf_2var_existence_characterizable blocker; Phase 3B has 2 goals deferred; Phase 3C depends on Phase 6C
- **Effort**: 16-32 hours remaining (Phase 6C-1 ~1h, Phase 6C-2 ~1-2h, Phase 6C-3 ~2-3h, Phase 6C-4 ~4-8h, Phase 6C-5 ~1h, Phase 3C ~3-6h, Phase 3B residual ~1-2h, Phase 5 residual ~2-4h, Phases 7-9 ~5-9h)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED), Task 168 (COMPLETED), Task 174 (COMPLETED), Task 198 (COMPLETED), Task 199 (PARTIAL -- closed 4/6 Case B grid goals, 2 blocked on b_resp vs p_n proof gap)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md, reports/32_post-dependency-assessment.md, reports/33_lit-sel-pn-ordering.md, reports/33_infra-sel-pn-fix.md, reports/33_tactic-sel-pn-grid.md, reports/34_lemma10-strategy-restrict.md, reports/35_gap-detection-literature.md, reports/38_proposition7-composition.md, reports/41_phase3c-d-as-minimum.md, reports/42_path-a-dependency-analysis.md, reports/42_path-b-direct-formula.md, reports/42_path-c-single-game.md, reports/36_nested-formula-research.md, reports/37_literature-blocker-insight.md, reports/43_backward-direction-bridge.md, **Task 199**: specs/199_grid_order_tactic/reports/01_grid-order-tactic.md, specs/199_grid_order_tactic/reports/02_blocker-analysis.md
- **Artifacts**: plans/35_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline. Phases 1-4 are complete, closing 9 sorry sites and establishing key infrastructure: K-(negD) bridge (Phase 2), d-compatible forward game with `h_d_compat_left` (Phase 3 breakthrough), and position-tracking `ghr93_rank_down_proj` (Phase 4). Phase 5 interval bounds are closed (degenerate boundary + non-degenerate sub-interval forward game contradiction).

**Critical reordering (v35 revised)**: Three-path research (reports 42a/42b/42c) conclusively determined:
- **Path A viable**: No circular dependency exists. EFGames/ has zero imports from Expressiveness/. The dependency goes the OTHER direction (Expressiveness/Claim1 imports EFGames/StaviCompleteness). Phase 6 can be implemented entirely within EFGames/ without touching any Expressiveness/ sorry.
- **Path B killed**: Direct formula construction without nf_characterizable_by_stavi is impossible -- building interval type formulas as StaviFormulas IS the expressive completeness theorem.
- **Path C killed**: Single-game architecture infeasible due to 1-round budget deficit (need 4+3n+1 forward rounds, only have 4+3n).

Therefore: **Phase 6 must be implemented FIRST** (Proposition 7 + EFGames-internal case analysis + nf_characterizable_by_stavi closure). Then Phase 3C uses the resulting formula materialization to construct U(B,A) and close sel_pn_ord + b_resp vs p_n. This follows GHR93 exactly -- the inductive step at depth k+1 uses depth-k IH formulas (available by standard induction), resolving the apparent circularity.

**Phase 6C decomposition (v35 revised, Phase 6C decomposed)**: Reports 36, 37, and 43 identified the root cause of the Phase 6C blocker and two viable resolution approaches:
- **Root cause**: `nf_exist_sf` uses `sf_top` (trivially True) as the Until/Since guard. This makes the forward direction trivial but the backward direction unprovable for k>=1: knowing the 1-var depth-k type of x alone does not determine the 2-var depth-k NF of (x,t) because the 2-var NF includes quantifier information about 3-variable NFs.
- **Approach A (Interval Guard, PRIMARY)**: Replace `sf_top` with a formula constraining intermediate-point 1-var types, built from IH `char_k`. ~300-500 lines. The interval guard + endpoint types determine the 2-var NF for k=0 and k=1. For k>=2, points z outside the interval (t,x) are unconstrained by the Until guard, but the depth-k 1-var types of x and t encode existential information about outside points via their quantifier parts. The bridge argument is non-trivial but feasible.
- **Approach C (Nested Temporal Formula, FALLBACK)**: Directly encode the full multi-variable NF condition as nested Until/Since formulas, recursing on depth k with increasing variable count. ~600-800 lines. Zero risk, self-contained, both directions by structural recursion. No bridge theorem needed.
- Phase 6C is now decomposed into 5 sub-phases: 6C-1 (k=0 base case), 6C-2 (redefine formula with interval guard), 6C-3 (re-prove forward direction), 6C-4 (prove backward direction with bridge), 6C-5 (wire up and verify).

User directive: follow mathematically correct GHR93 approach head on, no workarounds.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Twenty research reports, a blocker study, two task 199 reports, and three path-analysis reports were integrated into this plan:

| Report | Key Finding | Impact on Plan |
|--------|-------------|----------------|
| 28_team-research (5 teammates) | Formula C circularity narrower than claimed; case-split viable | Drives Approach C selection |
| 29_literature-alignment | Approach A non-circular but blocked; Approach C pragmatic | Confirms case-split path |
| 30_critical-path-wiring | EFGames sorries ORPHANED from bx_completeness | Removed Track A |
| 30_forward-inventory | 14 sorry sites on GHR93 critical path | Phase effort estimates |
| 35_phase1-blocker-prior-art | Full pipeline 40-60 hours remaining | Effort calibration |
| 40_literature-crossref | 28 total sorries mapped to GHR93 steps | Sorry-to-phase mapping |
| 30_mechanical-strategy | K-(negD) adaptation for multi-round games | Phase 1 strategy |
| 30_session-audit | 2,978 net new lines; build passes | Stable baseline |
| 29_d-consistency-architecture | d_consistency with d=a_bwd(n) UNPROVABLE | Historical context |
| 30_blocker-study-prior-art | 12 remaining sorries; d-compat breakthrough; parameter approach for S12 | Phase 3 residual scoping, Phase 5 approach change, effort recalibration |
| 32_post-dependency-assessment | File split complete (task 174), Phase 9 sorries resolved (task 198), Fin blocker unchanged | v32 revision: Updated file paths, Phase 9 reduced to verification |
| 33_lit-sel-pn-ordering | GHR93 sel-vs-p_n is trivially True<->True from strict ordering; formalization diverges by using separate forward game for e_n | v33 revision: Confirms structural approach needed |
| 33_infra-sel-pn-fix | Fan configuration (d below both a_init(k) and p_n) makes pivot chain impossible; Approaches A-D fail; Approach E (unified game) recommended | v33 revision: Phase 3A restructure design |
| 33_tactic-sel-pn-grid | Only 2 live sorry sites; anonymous hypothesis problem from split_ifs; structured proof with named hypotheses is the solution | v33 revision: Phase 3B tactic overhaul design |
| 34_lemma10-strategy-restrict | Lemma 10 alone does NOT solve blocker; ALL game-based approaches fail; pragmatic fix: sel_pn_ord sorry'd field (~80 lines); proper fix: Lemma 10 + relabeling + d-as-minimum (~300-500 lines) | v34 revision: Phase 3A replaced with sorry'd field; Phase 3C added for deferred sorry closure |
| 35_gap-detection-literature | GHR93 (pp. 116-119) constrains gap location NOT by restricting gap detection, but by deriving interval bounds from the gap's defining formula D via forward game transfer | Phase 5 S11: correct approach for interval bound sub-sorries |
| **38_proposition7-composition** | **Phase 6 requires GHR93 Proposition 7 (composition lemma) -- 250-390 lines in new Composition.lean. Full path: Prop 7 -> Close CaseAnalysis sorries -> Close nf_characterizable_by_stavi. Partition/merge infrastructure and cross-interval order transfer are missing.** | **v35 revision: Phase 6 restructured into 6A/6B/6C** |
| **41_phase3c-d-as-minimum** | **d is already inf(S_C). Sorting (Lemma 10) resolves N-side only. M-side resp_tau(k) < e_n blocked by fan problem. Only fix: replace e_n construction with U(B,A) transfer (~260-520 lines). Also fixes b_resp vs p_n. Changing d's definition would break Claim 1 infrastructure.** | **v35 revision: Phase 3C completely rewritten around U(B,A) transfer** |
| **42_path-a-dependency-analysis** | **No circular dependency: EFGames/ has zero imports from Expressiveness/. Dependency goes OTHER direction. nf_characterizable_by_stavi's sorryAx comes ONLY from its own sorry at line 1567, NOT from sel_pn_ord. Phase 6 can be implemented independently. Case analysis for Phase 6 must be formalized WITHIN EFGames (cannot reuse Expressiveness/CaseAnalysis due to circular import).** | **v35 reorder: Phase 6 moves BEFORE Phase 3C** |
| **42_path-b-direct-formula** | **Direct formula construction IS nf_characterizable_by_stavi. No shortcut. IH at depth k gives depth-k 1-variable formulas; depth-(k+1) case needs 2-variable NFs decomposed via game argument. U(B,A) at depth r+2 exceeds tau's rank-r preservation -- may need tau at r+4 via h_r1_univ. Estimated 540-830 lines for correct approach within nf_characterizable induction.** | **v35 reorder: Phase 6C effort recalibrated; rank adjustment noted** |
| **42_path-c-single-game** | **Single-game architecture INFEASIBLE. 1-round budget deficit (need 4+3n+1, have 4+3n). All 6 variants (2A-2F) fail. Round budget not negotiable (dictated by GHR93 theorem statement). Path D (h_r1_univ sub-interval games) noted as potential cheaper alternative.** | **v35 reorder: Path C abandoned; confirms Phase 6-first approach** |
| **36_nested-formula-research** | **Deep analysis of three approaches for closing nf_2var_existence_characterizable. Approach A (interval guard) works for k=0,1 but has outside-interval subtlety at k>=2. Approach C (nested temporal formula, ~600-800 lines) is self-contained and zero-risk. Bridge theorem from games to NFs is the missing piece for Approach A.** | **v35 Phase 6C decomposition: Approach A primary, Approach C fallback** |
| **37_literature-blocker-insight** | **GHR93 Section 8 and Ch 12.8 fully describe the construction. The guard formula is X_{(t,u)} constraining interval types. Report 43's analysis confirmed correct. Two paths: (a) strengthen nf_exist_sf with interval guards ~200-300 lines, (b) classical existence via game-theoretic expressive completeness ~100-200 lines. No new infrastructure theorems needed.** | **v35 Phase 6C decomposition: confirms interval guard viability** |
| **43_backward-direction-bridge** | **Identified root cause: sf_top guard in nf_exist_sf is too weak for backward direction. GHR93 uses interval guard constraining ALL intermediate point types. Fix: replace sf_top with guard built from IH char_k. Existing infrastructure (nf_eval_unique, nf_characteristic_satisfies) suffices. Estimated ~270 lines total.** | **v35 Phase 6C decomposition: drives sub-phase structure** |
| Task 199: 01_grid-order-tactic | Case A grid dispatch already sorry-free; Case B has 6 goals: 3 impossible-direction, 1 fixable hab_eq rewrite, 2 genuine proof gap (b_resp vs p_n fan ordering) | Phase 3B updated |
| Task 199: 02_blocker-analysis | b_resp vs p_n unprovable from current hypotheses: Case B has fan geometry. Three fix options documented. | Phase 3B blocker: deferred to Phase 3C |

### Revision History

**v28 original**: Two-track plan (Track A: OrderIso bypass, Track B: GHR93 pipeline).

**v28 revised**: Single-track (GHR93 only). Track A removed. Phases renumbered 1-9.

**v31 revised**: Post-implementation update incorporating blocker study findings. Changes:
- Phases 1-4 marked [COMPLETED] with implementation summaries
- Phase 3 revised: d-compat approach replaces U(B,A) transfer; 3 residual sorry sites scoped with exact goals and patterns
- Phase 5 revised: S12 uses parameter approach (pass IH game) instead of full Lemma 10
- Phase 9 updated: 4 Completeness.lean sorry sites identified (lines 226, 256, 281, 290)
- Effort estimates recalibrated from blocker study
- Superseded Approaches expanded to 8 entries from blocker study Appendix B

**v31 paused (2026-05-25)**: Phase 3 partially closed (3 of 6 Case A goals closed, Case B not attempted). Task paused for file splitting.

**v32 revised (2026-05-26)**: Post-dependency-task update incorporating results from tasks 168, 174, 195, 198. Changes:
- All file paths updated from `ExpressivenessGeneral.lean` to split successors under `Expressiveness/`, `EFGames/`, `IntegerModel/`
- Phase 9 reduced from 4 sorry closures to verification-only (task 198 eliminated all Completeness.lean sorry sites)
- Phase 3 effort estimate reduced (compile cycles now under 1 minute vs 3-5 minutes)
- Total effort recalibrated from 15-30 hours to 12-24 hours
- Sorry count reduced from 12 to 8 critical-path sites (4 resolved by task 198)
- Added `succ_cofinal` sub-proof sorry sites (lines 1285, 1441, 1508) to Phase 8 inventory

**v32 updated (2026-05-26)**: Phase 3 [BLOCKED] after implementation attempt exhausted 5 approaches for sel-vs-p_n ordering.

**v33 revised (2026-05-26)**: Post-research revision incorporating three targeted reports (literature, infrastructure, tactic). Changes:
- Phase 3 split into 3A (unified game restructure) and 3B (tactic overhaul) based on root cause analysis
- Approach E (unified forward game) adopted as the structural fix
- Structured focused proofs with named hypotheses replace `same_order_type_grid <;> first | ... | sorry` pattern
- Superseded Approaches expanded to 14 entries (5 new from infrastructure report)
- Effort recalibrated upward slightly (2-4h -> 4-6h for Phase 3) due to restructure scope

**v34 updated (2026-05-26)**: Post-task-199 update incorporating grid_order_tac research, implementation, and blocker analysis. Changes:
- Phase 3B updated with task 199 results: Case A confirmed sorry-free, Case B reduced from 6 to 2 remaining goals
- Task 199 closed 4 of 6 Case B goals: 3 impossible-direction proofs + Goal 3 (sel vs p_n) via rename_i + targeted hab_eq rewrite
- fan_order theorem added to Superseded Approaches (#17) -- provably false via counterexample
- grid_order_tac macro approach added to Superseded Approaches (#18) -- blocked by fan_order invalidity
- 2 remaining goals (b_resp vs p_n, p_n vs b_resp) documented as genuine proof gap with three proposed structural fixes from task 199 blocker analysis
- Research Inputs expanded with task 199 reports (01_grid-order-tactic.md, 02_blocker-analysis.md)
- Tactic patterns table expanded with working patterns discovered by task 199

**v34 revised (2026-05-26)**: Post-Lemma-10-research revision incorporating report 34 findings. Changes:
- Phase 3A (unified game restructure) superseded -- all game-based approaches proven infeasible (report 34 Sections 2-5)
- Phase 3A replaced with pragmatic sorry'd field approach: add `sel_pn_ord` to SplitPointProps (~30 lines) + propagate to sorry sites (~50 lines)
- Phase 3C added: deferred sorry closure via Lemma 10 + relabeling + d-as-minimum restructuring (300-500 lines)
- Superseded Approaches expanded to 16 entries (2 new from report 34)
- Effort recalibrated downward for Phase 3A (from 2-4h to ~1h), upward for Phase 3C (new, 6-10h)
- Total effort reduced for short-term path (Phase 3A-new + 3B unblocks Phases 5-9), deferred Lemma 10 effort tracked separately

**v35 revised (2026-05-27)**: Post-research revision incorporating reports 38 (Proposition 7 composition) and 41 (Phase 3C d-as-minimum analysis). Major structural changes:
- Phase 3C COMPLETELY REWRITTEN: v34 described Phase 3C as "Lemma 10 + relabeling + d-as-minimum restructure (~300-500 lines)". Report 41 conclusively proves this is insufficient: sorting fixes N-side only, M-side (resp_tau(k) < e_n) remains blocked by the fan problem. d is already inf(S_C) and must NOT be changed (would break Claim 1). The real fix is replacing the e_n construction with GHR93's U(B,A) transfer (~260-520 lines), which also resolves b_resp vs p_n (same fan problem).
- Phase 3B b_resp vs p_n goals absorbed into Phase 3C: The 2 blocked Case B goals share the same fan problem root cause as sel_pn_ord. U(B,A) transfer in Phase 3C resolves both.
- Phase 5 updated: Interval bound sub-sorries at lines ~3328 and ~3639 are now CLOSED. Phase 5 reduced to winning condition assembly (line ~4100, ~200 lines).
- Phase 6 RESTRUCTURED into 6A/6B/6C: Report 38 identifies GHR93 Proposition 7 (composition lemma) as the root blocker for Phase 6. New sub-phases: 6A implements composition in Composition.lean (250-390 lines), 6B closes CaseAnalysis sorries using composition (300-600 lines), 6C closes nf_characterizable_by_stavi (550-780 lines).
- Non-Goals updated: "Implementing full Lemma 10 + relabeling" removed (superseded by U(B,A) approach). "Restructuring e_n construction" removed from Non-Goals (now the primary approach).
- Research Inputs expanded with reports 38 and 41.
- Effort recalibrated upward for Phase 3C (6-12h vs 6-10h) and Phase 6 (14-24h total for 6A+6B+6C).

**v35 revised reordered (2026-05-27)**: Post-three-path-research revision incorporating reports 42a (dependency analysis), 42b (direct formula), 42c (single game). **MAJOR PHASE REORDERING**:
- **Phase 6 now executes BEFORE Phase 3C**: Report 42a proves no circular dependency (EFGames/ has zero imports from Expressiveness/). Phase 6 is entirely self-contained within EFGames/.
- **Phase 6B rewritten**: Case analysis for nf_characterizable_by_stavi must be formalized WITHIN EFGames (not reusing Expressiveness/CaseAnalysis.lean -- would create circular import). This is the same mathematical content but a separate formalization.
- **Phase 3C simplified**: Once nf_characterizable_by_stavi is closed (Phase 6C), formula materialization becomes available. Phase 3C uses it to construct U(B,A) and close sel_pn_ord + b_resp vs p_n. Estimated effort reduced from 6-12h to 3-6h.
- **Phase 5 winning condition assembly unblocked by Phase 3C** (needs sel_pn_ord for grid dispatch).
- **Path B killed**: Direct formula construction IS nf_characterizable_by_stavi. No shortcut.
- **Path C killed**: Single-game architecture infeasible (1-round budget deficit).
- **Rank adjustment noted**: U(B,A) has depth r+2, but tau preserves only depth <= r. May need tau at r+4 via h_r1_univ (report 42b Section 3.3).
- **ghr93_winning_condition_perm confirmed complete**: 95 lines, sorry-free in CustomGame.lean.
- Research Inputs expanded with reports 42a, 42b, 42c.
- Effort recalibrated: Phase 3C reduced (3-6h from 6-12h, leveraging Phase 6 output); Phase 6 unchanged (14-24h total).
- Dependency graph completely reordered (see wave table below).

**v35 revised Phase 6C decomposed (2026-05-27)**: Post-blocker-research revision incorporating reports 36 (nested formula research), 37 (literature blocker insight), and 43 (backward direction bridge). Changes:
- **Phase 6C decomposed into 5 sub-phases**: 6C-1 (k=0 base case, ~1h), 6C-2 (redefine nf_exist_sf with interval guard, ~1-2h), 6C-3 (re-prove forward direction, ~2-3h), 6C-4 (prove backward direction with bridge theorem, ~4-8h), 6C-5 (wire up and verify, ~1h).
- **Root cause confirmed**: `nf_exist_sf` uses `sf_top` as Until/Since guard. This is too weak for the backward direction at k>=1 because the 2-var NF includes quantifier information not determined by the 1-var type alone.
- **Primary approach**: Interval Guard (Approach A from reports 36/37/43). Replace `sf_top` with a conjunction over IH formulas constraining intermediate point types. GHR93 Definition 12.8.13 defines X_{(t,u)} as exactly this. ~300-500 lines total.
- **Fallback approach**: Nested Temporal Formula (Approach C from report 36 Section 7). Directly encode full multi-variable NF condition recursively. ~600-800 lines. Zero risk, self-contained. Triggered if Approach A hits the k>=2 outside-interval issue.
- **k>=2 risk documented**: For k>=2, points z outside the interval (t,x) contribute to the 2-var NF but are unconstrained by the Until guard. Report 36 Section 6 analyzes this in depth. The depth-k 1-var types of x and t encode existential information about outside points, but the bridge argument from this information to 2-var NF determination is non-trivial.
- **Phase 6C effort recalibrated**: From 12-20h (monolithic) to 9-14h (decomposed). Sub-phases enable incremental progress and clear fallback trigger points.
- **Superseded Approaches expanded**: #23 (sf_top backward at k>0), #24 ("good NF" disjunction), #25 (NF finiteness/definability -- circular), #26 (reduction to stavi_expressive_completeness -- circular).
- Research Inputs expanded with reports 36, 37, 43.

## Goals & Non-Goals

**Goals**:
- Close all remaining critical-path sorry sites
- Prove `succ_cofinal` via gap elimination using `nf_characterizable_by_stavi` + `no_gaps_discrete`
- Achieve sorry-free `bx_completeness`
- Implement GHR93 Proposition 7 (composition lemma) to unblock nf_characterizable_by_stavi
- Close nf_characterizable_by_stavi (StaviCompleteness.lean:1567) via EFGames-internal case analysis + depth-k IH formulas
- Replace e_n construction with GHR93-faithful U(B,A) transfer using formula materialization from Phase 6 (resolves sel_pn_ord and b_resp vs p_n)

**Non-Goals**:
- Closing TruthLemma.lean sorry sites (non-critical-path)
- Closing OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- Archiving BXCanonical dead-code sorries
- Building rank_lift infrastructure
- OrderIso bypass (Track A) -- proven infeasible
- Approach A (Fintype enumeration for StaviFormula) -- blocked by infinite atoms
- Changing d from inf(S_C) to min(selections) -- would break Claim 1 infrastructure (report 41 Section 7)
- Single-game restructuring of Case II -- infeasible due to 1-round budget deficit (report 42c)
- Reusing Expressiveness/CaseAnalysis.lean for Phase 6 -- would create circular import (report 42a Section 4.4)

## Superseded Approaches

The following approaches have been tried and ruled out across 15+ sessions. Do NOT re-attempt these.

| # | Approach | Where Tried | Why It Failed |
|---|----------|-------------|---------------|
| 1 | **Track A: OrderIso bypass** | Phase A1 (v28) | `chronicle_is_good` requires `ChronicleAsPriorModel` which fills `domain_succ_archimedean := limitDomSubtype_isSuccArchimedean` using `succ_cofinal`. Every path from Burgess chronicle to countermodel on Int goes through `IsSuccArchimedean`. No bypass exists. |
| 2 | **Approach A: Fintype StaviFormula enumeration** | Phase B2 (v28) | `StaviFormula` has `Formula` atoms (infinite type). `Fintype { A : StaviFormula // stavi_depth A <= r }` is not constructible. |
| 3 | **Approach B: NormalForm -> StaviFormula inversion** | reports 38-39 | CIRCULAR: converting NF back to StaviFormula IS the expressive completeness theorem being proved. |
| 4 | **h_d_unique (uniqueness from rank-r type)** | Lines 2755-2859 | MATHEMATICALLY FALSE: K-(negD) has depth r+2, two points can share rank-r type but differ at r+2. |
| 5 | **h_fwd_n1_d at (n+1) rounds** | Phase 3 sessions | game_tuple dite reduction blocked by Fin arithmetic. The (1+3n+1)-round d-compat approach avoids this entirely. |
| 6 | **d = a_bwd(n) with rank-(r+1)** | Several sessions | d_consistency literally false when d is not d-bar. |
| 7 | **Gap equivalence lemma** | report 37 | FALSE in general: adjacent points and gaps disagree on atoms. |
| 8 | **pivot_chain_order without c <= e_n** | Multiple sessions | Requires c <= e_n as input, which is exactly what needs proving. Resolved by d-compat forward game providing `hc_le_en`. |
| 9 | **Deriving sel-vs-p_n ordering from existing games** | Phase 3 impl v2 (2026-05-26) | 5 approaches tried: (a) pivot_chain_order through d/c -- fork geometry, not chain; (b) extract from hord_big -- gives a'_big positions, not a_init; (c) instantiate tau with e_n_pt -- gives b_en != p_n; (d) prove b_en = p_n from ordering equivalences -- impossible when both strictly between d and y'; (e) fork ordering from common bounds -- mathematically impossible on general linear orders (counterexample: d=0, b_en=1, p_n=2, y'=3). |
| 10 | **Extract sel_pn_ord from hord_big directly** | 33_infra-sel-pn-fix (Approach A) | a'_big(k) from the big game is NOT a_init(k); same-side-of-d does NOT imply same-side-of-p_n (counterexample in Section 2.2). |
| 11 | **Add sel_pn_ord as SplitPointProps field (provable at construction time)** | 33_infra-sel-pn-fix (Approach B) | p_n is only defined inside ghr93_case_II (from h_point hypothesis), not at SplitPointProps construction time. The mathematical gap persists at the population site. |
| 12 | **Play tau with e_n and pivot through b_tau_en** | 33_infra-sel-pn-fix (Approach D) | Fan problem persists: d <= a_init(k) and d <= b_tau_en, but no chain exists between a_init(k) and b_tau_en. Pivot_chain_order' requires a CHAIN, not a fan. |
| 13 | **Restructure big game N-side to force a'_big(k) = a_init(k)** | 33_infra-sel-pn-fix (Approach C) | d-compatible forward game has M selecting, N responding -- cannot force N-side response to equal a_init(k). Using h_fwd_n1 with resp_tau as M-side selections gives NEW N-side points, not a_init. |
| 14 | **same_order_type_grid <;> first | ... | sorry with convert/congr** | Phase 3 impl (5 variants) | Anonymous hypotheses from split_ifs prevent targeted Fin rewrites. change, convert...using, rw, pre-derived helpers, show...from all fail on inaccessible variables. |
| 15 | **Unified forward game (Approach E from v33 Phase 3A)** | Phase 3A blocker + report 34 Section 5 | ANY game play produces NEW N-side responses a'_fwd(k) that are NOT a_init(k). Order-isomorphism between a_init and a'_fwd relative to d and y' does NOT extend to ordering relative to p_n (counterexample: d=0, a_init=1, a'=2, p_n=1.5). Six sub-approaches all fail for the same reason. |
| 16 | **Two-phase tau construction (report 34 Section 5)** | report 34 | Play h_fwd_n1 with resp_tau + c selections, then point challenge with p_n. Produces b_fwd != e_n and a'_fwd(k) != a_init(k). Same fundamental wall. |
| 17 | **fan_order abstract order lemma (task 199 Phase 1)** | Task 199 implementation | Given fan d<=a, d<=b with order-preserving maps, derive a vs b ordering. PROVABLY FALSE: counterexample p=0, a=1, b=2, q=0, a'=2, b'=1 satisfies all hypotheses but conclusion fails. Fan geometry does not determine relative order of the upper elements. |
| 18 | **grid_order_tac macro approach (task 199 Phases 2-3)** | Task 199 plan | Build a reusable tactic macro to dispatch all grid goals. BLOCKED by fan_order invalidity (goals 1-2 unprovable). Inline strategy additions used instead for closable goals. |
| 19 | **Sorting + Lemma 10 alone (without U(B,A) transfer)** | Report 41 Sections 3-4 | Sorting resolves N-side (a_init(k) < p_n via strict monotonicity) but NOT M-side (resp_tau(k) < e_n). The fan problem persists on the M-side: c <= resp_tau(k) and c < e_n gives no ordering between resp_tau(k) and e_n. Every variation (chain through tau's last element, augmented selection, reconciliation via two d's) hits the same wall. |
| 20 | **Changing d from inf(S_C) to min(selections)** | Report 41 Section 4.2 | Would break the continuation set construction and all Claim 1 infrastructure. d = inf(S_C) is needed for sigma/tau sub-interval boundary properties. The issue is the e_n construction method, not d's definition. |
| 21 | **Direct formula construction without nf_characterizable_by_stavi (Path B)** | Report 42b | Building interval type formulas as StaviFormulas IS nf_characterizable_by_stavi. No shortcut exists. The finiteness of rank-r formula equivalence classes comes from NF theory; converting NF types to StaviFormulas is the expressive completeness theorem itself. Signature mismatch between sig-level IH and muSig-level bridge prevents bypass. |
| 22 | **Single-game architecture for Case II (Path C)** | Report 42c | All 6 variants (2A-2F) infeasible. Extended tau (2A): 1-round budget deficit (need 4+3n+1, have 4+3n). h_fwd_n1 direct (2B): direction mismatch (forward = M selects, need N-side). Reverse h_fwd_n1 (2C): not enough rounds for forward-to-backward. From h_d_compat_left (2D): round count not integer. Combined tau + challenge (2E): one challenge per game, direction mismatch. n+1 selections (2F): same budget as 2A. Round budget is NOT negotiable -- dictated by GHR93 theorem statement. |
| 23 | **nf_exist_sf backward with sf_top guard (k>0)** | Phase 6C implementation | The formula `U(witness_type, sf_top)` gives x with the right 1-var type but does NOT constrain the 2-var type. The sf_top guard allows any intermediate point type, so the interval profile is unconstrained. The 2-var NF at depth k>0 depends on which 3-var NFs are realizable, which sf_top cannot capture. FAILED for all k>0. |
| 24 | **"Good NF" disjunction approach** | Phase 6C implementation | Build disjunction over all depth-k 1-var NFs nf_t such that the existential P holds. Uses doets_lemma_1_1 to show NF determines formula truth. FAILS because P has quantifier depth k+1 but char_k provides only depth-k information. Two points with the same depth-k NF can disagree on the depth-(k+1) existential. |
| 25 | **NF finiteness + definability argument** | Phase 6C implementation, Report 36 Section 5.8 | Show P is a union of NF equivalence classes, hence definable. CIRCULAR because showing P is invariant under StaviFormula equivalence IS the expressive completeness theorem being proved. The "good class" predicate is classically decidable but its truth at a specific point requires depth-(k+1) information. |
| 26 | **Reduction to stavi_expressive_completeness** | Phase 6C implementation | The existential IS a monadic FO formula, so stavi_expressive_completeness gives the StaviFormula. But stavi_expressive_completeness depends on nf_characterizable_by_stavi at depth k+1, which is what we're proving. CIRCULAR. |

**Key settled questions**:
- Infimum redefinition IS necessary (reports 29, 35). Do not revisit.
- Track A (OrderIso bypass) is NOT FEASIBLE. Do not revisit.
- Approach A (Fintype enumeration) is BLOCKED by infinite atoms. Do not revisit.
- D-compatible forward game is the correct approach for cross-boundary orderings, BUT it does not provide chain geometry for sel_pn_ord or b_resp vs p_n. The fan problem is fundamental.
- Sel-vs-p_n ordering CANNOT be derived from ANY combination of separate game plays (report 34, report 41). The only resolution is U(B,A) transfer (GHR93's original construction for e_n).
- The `same_order_type_grid <;> first | ... | sorry` pattern is structurally inadequate for goals requiring named hypotheses. Structured focused proofs with bullet notation are the correct replacement.
- **Fan ordering is provably false** (task 199): Given a fan d<=a, d<=b with order-preserving maps, the relative order of a vs b is NOT determined. Do NOT attempt abstract fan_order lemmas.
- **The M-side fan problem persists even with sorting** (report 41): Sorting + Lemma 10 resolves the N-side only. The only path to full sel_pn_ord closure is replacing the e_n construction with U(B,A) transfer.
- **d must remain inf(S_C)** (report 41 Section 7): Changing d's definition breaks Claim 1 infrastructure. The fix targets the e_n construction, not d.
- **Proposition 7 (composition lemma) is required for Phase 6** (report 38): Without it, the 1-variable IH cannot be bridged to the 2-variable quantifier step in nf_characterizable_by_stavi.
- **No circular dependency between EFGames/ and Expressiveness/** (report 42a): EFGames/ has zero imports from Expressiveness/. The dependency is unidirectional: Expressiveness/Claim1 -> EFGames/StaviCompleteness. Phase 6 is entirely self-contained.
- **Formula materialization IS nf_characterizable_by_stavi** (report 42b): No shortcut exists. The k+1 case uses depth-k IH formulas (standard induction).
- **Single-game architecture is INFEASIBLE** (report 42c): 1-round budget deficit is structural and non-negotiable.
- **U(B,A) has depth r+2, tau preserves depth <= r** (report 42b Section 3): May need tau at rank r+4 via h_r1_univ for formula transfer. Investigate during Phase 3C.
- **ghr93_winning_condition_perm is complete** (95 lines, sorry-free in CustomGame.lean): Selection sorting infrastructure is ready.
- **sf_top guard is provably insufficient for backward direction** (reports 36, 37, 43): The formula U(witness_type, sf_top) gives x with the right 1-var type but does NOT determine the 2-var NF at depth k>0. A proper interval guard (constraining intermediate point types via IH formulas) is required. Do NOT attempt sf_top-based backward proofs.
- **The backward direction requires an interval guard matching GHR93 Definition 12.8.13** (report 37): The guard X_{(t,u)} constrains which 1-var types appear at intermediate points. This is the standard construction in the literature.
- **Approaches 23-26 are all circular or insufficient** (report 36 Sections 3-6): "Good NF" disjunction, NF finiteness/definability, and reduction to stavi_expressive_completeness all fail for specific identified reasons. Do NOT re-attempt these.
- **The outside-interval issue for k>=2 is real but may be resolvable** (report 36 Section 6): The depth-k 1-var type of x encodes existential information about points above x, and similarly for t. The bridge argument from this information to full 2-var NF determination is non-trivial but the mathematical content is sound. If the bridge proof is too difficult, fall back to Approach C (nested temporal formula).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 6B case analysis within EFGames larger than estimated (>600 lines) | H | M | The mathematical content is identical to Expressiveness/CaseAnalysis.lean but must be self-contained within EFGames. Start with the simplest case (Case I) as proof of concept. Factor shared pattern into helper lemmas. |
| Phase 6C-4 backward direction hits outside-interval issue at k>=2 | H | M | Report 36 Section 6 identifies that points z outside (t,x) are unconstrained by the Until guard. The depth-k 1-var types encode existential info about outside points, but the bridge argument is non-trivial. **Fallback**: Switch to Approach C (nested temporal formula, ~600-800 lines) which avoids this issue entirely by encoding the full multi-variable NF condition recursively. Trigger: if Phase 6C-4 is blocked after 6 hours of effort. |
| Bridge theorem from game infrastructure to NF equality not yet formalized | H | M | The game infrastructure (ghr93_strategy_compose, ghr93_game_iff_decomposition) operates on ExtendedCarrier/rank_type, not NormalForm/nf_eval_nf. A translation layer is needed. Use nf_eval_unique and nf_characteristic_satisfies to bridge. If the translation is too complex, Approach C avoids it. |
| U(B,A) depth exceeds tau rank (r+2 vs r preservation) | H | M | Report 42b Section 3.3 identifies the issue. h_r1_univ provides games at higher ranks. Reconstruct tau at rank r+4 using h_r1_univ + IH. Alternatively, restructure the formula encoding to stay within depth r. |
| Formula materialization from Phase 6C harder to apply in Phase 3C than expected | M | M | Phase 6C provides nf_characterizable_by_stavi at all depths. Phase 3C needs it at specific depth k. The IH interface should be clean. If integration is difficult, add a wrapper lemma that materializes the specific interval type needed. |
| S11 winning condition assembly has unexpected mathematical gap | M | M | Interval bounds are now closed. Remaining work follows Case II pattern closely. |
| Build regression after structural changes to EFGames/ | M | M | Run `lake build` after every component. Commit working states. |
| Duplicated case analysis code between EFGames/ and Expressiveness/ | L | H | This is a code quality concern, not a correctness concern. After both are complete, a shared-module refactor can be done as a separate task. Do not let this block progress. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- (COMPLETED) |
| 2 | 3A | 2 (COMPLETED) |
| 3 | 6A | -- (COMPLETED) |
| 4 | 6C-1 | -- (no dependency on incomplete phases; validates infrastructure for k=0 base case) |
| 5 | 6C-2 | 6C-1 (redefine formula using infrastructure validated in 6C-1) |
| 6 | 6C-3 | 6C-2 (re-prove forward direction for the redefined formula) |
| 7 | 6C-4 | 6C-3 (prove backward direction; depends on forward being stable) |
| 8 | 6C-5 | 6C-4 (wire up nf_2var_existence_characterizable and verify build) |
| 9 | 3C | 6C-5 (formula materialization from nf_characterizable_by_stavi) |
| 10 | 3B, 5 | 3C (3B's 2 blocked goals resolved by 3C; 5's winning condition assembly needs sel_pn_ord from 3C) |
| 11 | 7 | 6C-5 (no_gaps_discrete needs nf_characterizable_by_stavi) |
| 12 | 8 | 7 |
| 13 | 9 | 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Mechanical Sorry Closure S3 + S5 [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Closed S3 (line 4412, `h_cont_transfer_mr`) and S5 (line 4468, `h_mr_resp_ge_d` gap case). S3 used `game_tuple` simplification with `show k=n_sel+j` pattern (~90 lines). S5 mirrored existing gap proof using `ha'_mr_in` bound (~255 lines). Build passes; sorry count reduced by 2.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now split into `Expressiveness/` submodules by task 174)

---

### Phase 2: Pigeonhole + K-(negD) Bridge (S1/S2 Claim 1 Resolution) [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Closed S1 and S2 (the Claim 1 sorry cluster) using K-(negD) bridge. S1 (boundary case): K-(negD_M) pigeonhole argument (+200 lines). S2 (gap case): gap_point_agreement + K-(negD_M) (+131 lines). Also closed S1 sub-sorry (gap density) and S2 sub-sorry (gap-gap case) via complement_no_min witnesses. Key finding: K-(negD) bridge is necessary scaffolding (unavoidable before S13, replaceable after). Also closed S4 (multi-round K-(negD)) and S7-right (right-direction K-(negD)) in subsequent sessions.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now `Expressiveness/Claim1.lean` and `Expressiveness/SplitPoint.lean`)

---

### Phase 3A: Add sel_pn_ord Sorry'd Field to SplitPointProps [COMPLETED]

**Goal**: Add `sel_pn_ord` as a sorry'd local `have` in CaseAnalysis.lean, providing the missing ordering between tau selections and p_n. This unblocks Phase 3B without requiring the infeasible unified game restructure.

**Root cause (from research)**:
- The sel-vs-p_n ordering `(a_init(k) < extendPoint p_n <-> resp_tau(k) < e_n)` cannot be derived from any combination of separate game plays (report 34, exhaustive analysis of 16 approaches).
- In GHR93, this is trivially true because d is defined as the minimum of all selections and selections are relabeled to be increasing. The formalization's e_n construction via the forward game (not U(B,A) transfer) creates a fan geometry instead of a chain.
- The property IS mathematically true and will be closed in Phase 3C via U(B,A) transfer restructuring.

**Strategy (from report 34 Section 6)**: Add `sel_pn_ord` as a sorry'd local `have` in CaseAnalysis.lean at both Case A and Case B sorry sites. The sorry is placed at the usage sites as `intro k; sorry`.

**Tasks**:

- [x] **Read the exact goal shape at sorry sites** *(completed)*

- [x] **Add sel_pn_ord as local sorry'd have in CaseAnalysis.lean** *(deviation: added as local `have` in CaseAnalysis.lean at both Case A and Case B sorry sites, NOT as a SplitPointProps field. Reason: resp_tau and e_n are local to the case analysis, not parameters of SplitPointProps. The local approach concentrates the sorry at the usage sites.)*
  - Case A: `sel_pn_ord` + `pn_sel_ord` added at lines ~1418-1441
  - Case B: `sel_pn_ord` + `pn_sel_ord` added at lines ~1769-1791

- [x] **Verify build passes**: `lake build` passes with zero errors. Sorry count: 2 new sel_pn_ord sorries (Case A line 1423, Case B line 1773). Pre-existing grid fallback sorries unchanged (lines 1622, 1914).

**Timing**: ~1 hour

**Depends on**: 2 (COMPLETED)

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- local `have sel_pn_ord` + `pn_sel_ord` at Case A and Case B

**Verification**:
- `lake build` passes with zero errors
- sel_pn_ord available at both sorry sites
- No new sorry sites introduced outside the sorry'd `have` declarations

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Added `ghr93_rank_down_proj` lemma (233 lines) for position-tracking variant of rank_down. S6 closed directly using rank_down_proj. S7 right-case expanded (~160 lines) with h_cont_transfer_mr and h_mr_resp_ge_d fully proved. S7-right K-(negD) sorry subsequently closed via shared approach from Phase 2.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now `Expressiveness/SplitPoint.lean`)

---

### Phase 6A: GHR93 Proposition 7 -- Strategy Composition Lemma [COMPLETED]

**Goal**: Implement `ghr93_strategy_compose` -- the composition lemma that combines Duplicator winning strategies on sub-intervals [x,c] and [c,y] into a winning strategy on the full interval [x,y]. This is the missing infrastructure that unblocks the nf_characterizable_by_stavi inductive step.

**Why this phase executes FIRST (before Phase 3C)**:
- Report 42a proves no circular dependency: EFGames/ has zero imports from Expressiveness/.
- The composition lemma lives entirely within EFGames/ and uses only existing EFGames infrastructure (all sorry-free except line 1567).
- Phase 3C depends on Phase 6C (formula materialization), not the other way around.

**Why needed** (from report 38):
- The inductive step of nf_characterizable_by_stavi requires bridging 1-variable IH to 2-variable quantifier step.
- The composition lemma enables proving that n-equivalence implies Duplicator wins the EF game, which is the core of GHR93 Section 8.
- Existing infrastructure has strategy_restrict_left/right (the CONVERSE decomposition) but NOT composition.

**Lean Statement** (from report 38 Section 4):
```
theorem ghr93_strategy_compose
    {M N : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
    {n r : Nat} {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x <= c) (hcy : c <= y) (hx'd : x' <= d) (hdy' : d <= y')
    (hcd_type : rank-r type agreement between c and d)
    (hcd_gp : gap/point correspondence)
    (h_left : ghr93_duplicator_wins M N atomMap n r x c x' d)
    (h_right : ghr93_duplicator_wins M N atomMap n r c y d y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y'
```

**Proof Strategy** (from report 38 Section 5):
1. **Partition**: Classify Spoiler's n selections from [x,y] into LEFT (<= c) and RIGHT (> c).
2. **Pad and apply sub-strategies**: Use round monotonicity to reduce n-round sub-strategies. Pad LEFT selections to n elements, apply left strategy. Same for RIGHT.
3. **Merge responses**: Place sub-responses back into original positions.
4. **Handle Round 2**: Case-split on whether point challenge b' <= d or b' > d.
5. **Prove winning condition**: Cross-interval order is preserved because left responses <= d <= right responses. Gap/point and formula agreement inherited from sub-strategies.

**Tasks**:
- [x] **Define partition_selections** -- classify selections by position relative to split point c (~30-40 lines) *(deviation: altered -- inlined as let-bindings a_L/a_R in main theorem instead of separate definitions)*
- [x] **Define merge_responses** -- recombine sub-interval responses into full response (~30-40 lines) *(deviation: altered -- inlined as let-binding a' in main theorem)*
- [x] **Prove cross-interval order transfer** -- left responses <= d <= right responses implies correct order (~40-60 lines) *(deviation: altered -- compose_wc/compose_wc_right proved in prior session; degenerate cases closed by adding h_compat_R/h_compat_L hypotheses)*
- [x] **Prove ghr93_strategy_compose** -- main theorem combining all components (~150-250 lines) *(deviation: altered -- theorem requires two additional hypotheses h_compat_R and h_compat_L for degenerate sub-interval compatibility; see handoff for mathematical justification)*
- [x] **Run `lake build`** to confirm no regressions *(completed -- builds with zero sorry in Composition.lean)*

**Timing**: 4-6 hours

**Depends on**: none (all EFGames infrastructure is sorry-free except line 1567)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` (NEW FILE) -- composition lemma + auxiliary definitions (~250-390 lines)

**Verification**:
- `ghr93_strategy_compose` type-checks with no sorry
- `#print axioms ghr93_strategy_compose` shows no `sorryAx`
- `lake build` passes

---

### Phase 6B: EFGames-Internal Case Analysis for nf_characterizable_by_stavi [SUPERSEDED]

**Status**: SUPERSEDED by direct formula construction approach in Phase 6C.

The original plan called for reimplementing Cases I-IV within EFGames/ to avoid circular imports with Expressiveness/CaseAnalysis.lean. Instead, Phase 6C took a formula construction approach: `nf_exist_sf` builds temporal formulas directly from the depth-k IH, and `nf_characterizable_by_stavi` is proved using `nf_2var_existence_characterizable` (a Classical.choose-based existence lemma). The game-theoretic case analysis is encapsulated in `nf_2var_existence_characterizable` rather than being split into Cases I-IV.

**Why superseded**: The formula construction approach is more direct and avoids duplicating 300-600 lines of case analysis from Expressiveness/. The remaining sorry (`nf_2var_existence_characterizable` at StaviCompleteness.lean:1865) encapsulates the game argument in a single clean statement.

**No tasks remain in this phase.** All work is tracked in Phase 6C.

---

### Phase 6C: Close nf_characterizable_by_stavi Sorry (S13) [IN PROGRESS]

**Goal**: Close the keystone sorry at StaviCompleteness.lean:1567 -- the inductive step of `nf_characterizable_by_stavi`. Every NormalForm at depth k+1 must be characterizable by a StaviFormula. The single remaining sorry is at `nf_2var_existence_characterizable` (StaviCompleteness.lean:1865).

**Context and prior work**:
- `nf_exist_sf` builds temporal formulas (U/S/U'/S') for 2-variable NF existence using depth-k IH.
- `nf_characterizable_by_stavi` main theorem proved modulo `nf_2var_existence_characterizable` (Classical.choose).
- Critical bug diagnosed (report 43): original `nf_exist_sf` used `sf_top` as guard -- too weak for backward direction.
- Forward direction (`nf_exist_sf_forward`) already proved and working.
- k=0 backward direction already proved (atoms+order determine the 2-var NF).

**Root cause analysis** (reports 36, 37, 43):
The formula `U(witness_type, sf_top)` gives x with the right 1-var type but sf_top imposes no constraint on intermediate point types. For k>=1, the 2-var NF includes quantifier information (which 3-variable depth-(k-1) NFs are realizable) that is NOT determined by the 1-var type of x alone. The interval profile (which 1-var depth-k types are realized between t and x) is essential.

**Approach A (PRIMARY): Interval Guard** (reports 37, 43; GHR93 Definition 12.8.13):
Replace `sf_top` with a guard formula constraining intermediate-point 1-var types, built from IH `char_k`. The guard encodes "all points in (t,x) have 1-var types consistent with the interval profile required by sub_nf." Combined with the endpoint types and ordering, this determines the 2-var NF.

**Approach C (FALLBACK): Nested Temporal Formula** (report 36 Section 7):
If Approach A hits the k>=2 outside-interval issue (where points z outside (t,x) contribute to the 2-var NF but are unconstrained by the Until guard), fall back to directly encoding the full multi-variable NF condition as nested Until/Since formulas, recursing on depth k with increasing variable count. Zero risk, self-contained, both directions by structural recursion.

**Fallback trigger**: Switch to Approach C if Phase 6C-4 (backward direction) is blocked after 6 hours of effort on Approach A. The trigger point is clearly defined: if the bridge from interval guard + endpoint types to 2-var NF equality cannot be closed for general k, Approach C avoids the bridge entirely.

**Previously attempted approaches (all failed -- see Superseded Approaches #23-#26)**:
1. sf_top backward at k>0 (guard too weak)
2. "Good NF" disjunction (quantifier depth mismatch)
3. NF finiteness + definability (circular)
4. Reduction to stavi_expressive_completeness (circular)

**Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

This phase is decomposed into 5 sub-phases below.

---

#### Phase 6C-1: Prove k=0 Base Case Separately [COMPLETED]

**Goal**: Prove `nf_2var_existence_characterizable` for k=0 as a standalone lemma. This validates the infrastructure and provides a working base case before tackling the general case.

**Why first**: The k=0 case is straightforward (atoms+order determine the 2-var NF) and already has partial proof. Isolating it as a separate lemma:
1. Confirms the formula construction machinery works end-to-end
2. Provides a template for the general case
3. Reduces the sorry to k>=1 only

**Strategy**:
- The existing `nf_exist_sf` already handles the k=0 formula construction (same as nf_exist_sf_depth0)
- The forward direction (mpr: existence → formula truth) uses nf_exist_sf_forward
- For backward (mp: formula truth → existence): extract x from the Until/Since witness, show the 2-var depth-0 NF of (x,t) = sub_nf by checking atoms (from predicate constraints in the formula via char_k_correct + sf_disjList_iff) and order (from the temporal direction)
- AtomKind sig 2 case analysis: `.pred p 0` (use nf_x from disjunction), `.pred p 1` (use h_atoms + h_t_cons), `.order 0 1` and `.order 1 0` (from Until/Since direction)

**Tasks**:
- [x] Read current state of `nf_2var_existence_characterizable` and `nf_exist_sf_depth0` at StaviCompleteness.lean *(completed)*
- [x] Analyze backward direction feasibility for k=0 *(completed -- feasible, proof outlined)*
- [x] **Task 6C-1.3**: Implement k=0 backward direction proof (~160 lines) *(completed)*
- [x] Verify k=0 case type-checks -- sorry now only in `succ k'` case *(completed)*
- [x] Run `lake build` to confirm no regressions *(completed -- build passes)*

**Critical finding from analysis**: For k>=1, the current nf_exist_sf formula (with sf_top guard) has FALSE POSITIVES in the backward direction. The formula can be TRUE when no x has the right 2-var NF. This is because the 2-var NF at k>=1 includes a quant part that is NOT constrained by the 1-var type of x alone. A DIFFERENT formula is needed for k>=1 (see Phase 6C-2 through 6C-4).

**Timing**: ~2 hours (increased from 1h due to Lean tactic complexity)

**Depends on**: none (infrastructure is ready)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- new lemma `nf_2var_existence_characterizable_depth0` (~40-60 lines)

**Verification**:
- `nf_2var_existence_characterizable_depth0` type-checks with no sorry
- `lake build` passes

---

#### Phase 6C-2: Redefine nf_exist_sf with Interval Guard Formula [BLOCKED]

**Goal**: Replace `sf_top` in `nf_exist_sf` with a proper interval guard formula built from the IH `char_k`, following GHR93 Definition 12.8.13.

**The interval guard** (from report 43):
Instead of `U(witness_type, sf_top)`, use `U(witness_type, interval_guard)` where:
```
interval_guard = sf_disjList [char_k nf_u | nf_u in all_depth_k_1var_nfs,
                              nf_u is compatible with the interval profile of sub_nf]
```

The guard constrains intermediate points in (t,x) to have 1-var depth-k types that are consistent with the 2-var NF `sub_nf`. Specifically, for each 1-var NF `nf_u`, include `char_k nf_u` in the disjunction if `nf_u` could appear in the interval profile required by `sub_nf`.

**Design decisions**:
1. The interval guard is a DISJUNCTION of IH formulas (not conjunction): "every intermediate point has one of the allowed types"
2. The set of allowed types is determined by the quantifier part of `sub_nf`: for each 3-var depth-(k-1) NF `sub3`, the interval profile must be consistent with `sub_nf.2 sub3`
3. For k=0, the guard can remain `sf_top` (no quantifier part, atoms+order suffice) or be refined for uniformity

**Alternative guard design** (simpler, from report 37):
Use the disjunction of ALL depth-k 1-var NFs: `sf_disjList [char_k nf_u | nf_u]`. This is always true (every point has some NF type) but provides the structural hook: the backward direction can case-split on WHICH char_k holds at each intermediate point. The information is then available for the bridge argument.

**Lean changes** (~20-30 lines):
```lean
-- Current (line ~1597):
| some true =>  .std_untl witness_type sf_top
-- Revised:
| some true =>  .std_untl witness_type (interval_guard_formula char_k sub_nf)
```

Plus definition of `interval_guard_formula` (~30-50 lines).

**Tasks**:
- [ ] Define `interval_guard_formula` as disjunction/conjunction of IH formulas constraining intermediate point types
- [ ] Update `nf_exist_sf` to use `interval_guard_formula` instead of `sf_top` in all 4 cases (U, S, U', S')
- [ ] Verify the definition type-checks (may need `Fintype` instance for `NormalForm sig k 1`)
- [ ] Run `lake build` -- expect `nf_exist_sf_forward` to break (re-proved in 6C-3)

**Timing**: 1-2 hours

**Depends on**: 6C-1 (k=0 case validates infrastructure; guard formula design informed by k=0 experience)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- redefine `nf_exist_sf` (~50-80 lines changed/added)

**Verification**:
- `interval_guard_formula` type-checks
- `nf_exist_sf` definition compiles with the new guard
- Build may have sorry warnings from broken forward proof (expected, fixed in 6C-3)

---

#### Phase 6C-3: Re-prove Forward Direction [NOT STARTED]

**Goal**: Re-prove `nf_exist_sf_forward` with the strengthened interval guard formula. The forward direction must show that if a witness x exists with the right 2-var NF, then the Until/Since formula with the interval guard holds at t.

**Why this needs re-proving**: The original forward proof used `sf_top` which is trivially satisfied. With the interval guard, the forward proof must additionally show that the guard formula holds at all intermediate points in (t,x).

**Strategy** (from report 43):
Given witness x with `nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`:
1. The witness type part: `char_k nf_x` holds at x by IH correctness -- same as before
2. The guard at intermediate points: for each u in (t,x), u has some 1-var depth-k type `nf_u = nf_characteristic M k 1 (fun _ => u)`. By `nf_characteristic_satisfies`, `nf_eval_nf M k 1 (fun _ => u) nf_u`. By `char_k_correct` (IH), `stavi_temporal_truth M atomMap u (char_k nf_u)`. Since `nf_u` is in the disjunction, the guard holds at u.
3. The Until/Since semantics then gives the formula truth at t.

**Key infrastructure**:
- `nf_characteristic_satisfies` (NormalForm.lean:224): every point satisfies its canonical NF
- `char_k_correct` (IH parameter): 1-var depth-k NF characterization
- `sf_disjList_iff` / `sf_conjList_iff`: correctness of finite conjunction/disjunction

**Tasks**:
- [ ] Re-prove `nf_exist_sf_forward` with the interval guard obligations
- [ ] The guard obligation reduces to: "for all u in interval, the guard disjunction holds at u" -- which follows from char_k_correct + nf_characteristic_satisfies
- [ ] Handle all 4 cases (Until, Since, Until', Since') as in the original proof
- [ ] Verify the proof type-checks with no sorry
- [ ] Run `lake build` to confirm

**Timing**: 2-3 hours

**Depends on**: 6C-2 (needs the redefined formula)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- re-prove `nf_exist_sf_forward` (~80-120 lines)

**Verification**:
- `nf_exist_sf_forward` type-checks with no sorry
- `lake build` passes (the sorry at `nf_2var_existence_characterizable` remains but forward direction is clean)

---

#### Phase 6C-4: Prove Backward Direction with Bridge Theorem [NOT STARTED]

**Goal**: Prove `nf_exist_sf_backward` -- the critical missing piece. Given that `U(witness_type, interval_guard)` holds at t, prove `exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`.

This is the highest-risk phase and the mathematical core of the entire Phase 6C effort.

**What the Until formula provides** (after strengthening):
1. A witness x with `char_k nf_x` holding at x (so x has 1-var depth-k type nf_x by IH)
2. x > t (or x < t, from the temporal direction)
3. For all u in (t,x): the interval guard holds at u, meaning `char_k nf_u` holds for some allowed nf_u

**What must be proved**:
`nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf`

This decomposes into:
- **Atoms part**: predicates at x match sub_nf's variable-0 predicates, predicates at t match parent atoms, order between x and t matches sub_nf's order atoms. All follow from the atom compatibility filter and t-consistency.
- **Quant part** (k >= 1): for each `sub3 : NormalForm sig (k-1) 3`, whether `exists z, nf_eval_nf M (k-1) 3 (Fin.cons z (Fin.cons x (fun _ => t))) sub3` matches `sub_nf.2 sub3`.

**The bridge argument** (Approach A):
The quant part requires showing that the interval profile (which 1-var types appear in (t,x)) + the endpoint types of x and t + the ordering fully determine the 2-var NF. This is the content of GHR93's game argument:

For a given z, the 3-var depth-(k-1) NF of (z, x, t) depends on:
- z's 1-var depth-(k-1) type (contained in z's depth-k type)
- z's position relative to x and t
- By the IH at depth (k-1): all pairwise 2-var depth-(k-1) NFs

For z in (t,x): the interval guard constrains z's depth-k 1-var type, which includes depth-(k-1) info.
For z = x or z = t: known from the endpoint types.
For z > x: the depth-k 1-var NF of x encodes "exists y, nf_eval_nf M (k-1) 2 (cons y (fun _ => x)) sub2" for all sub2 -- this tells us what exists above x.
For z < t: similarly from t's depth-k type.

**The outside-interval issue** (report 36 Section 6, k>=2):
For z > x, the existence of z with a specific 1-var type is encoded in x's depth-k NF. But the INTERVAL PROFILE between x and z (what types exist in (x,z)) is NOT encoded in x's depth-k NF and is NOT constrained by our hypotheses. This means the bridge argument for z > x requires additional work.

**Resolution strategies for the outside-interval issue**:
1. **Strong induction on k**: At depth k, use the IH at ALL depths k' < k. The outside-interval existentials involve depth-(k-1) NFs, for which the bridge theorem holds by IH. The key insight: the depth-k 1-var NF of x includes the depth-(k-1) 2-var NFs of (z,x) for all z, which by IH at depth (k-1) are determined by depth-(k-1) 1-var types + ordering + interval profile. Since we have depth-k types (which embed depth-(k-1) types), and we are asking about depth-(k-1) existentials, the IH may suffice.
2. **Direct NF computation**: For each sub3, compute whether `sub_nf.2 sub3` is true by examining what z's are available in each position region. Use the formula constraints to determine this.
3. **Fallback to Approach C**: If the bridge is too complex, switch to nested temporal formula construction.

**Tasks**:
- [ ] Prove the atoms part of the backward direction (predicates + order from formula constraints)
- [ ] For k=0: the backward direction is already proved in 6C-1, wire it in
- [ ] For k>=1, attempt the bridge argument:
  - [ ] Case z in (t,x): use the interval guard to determine z's type, apply IH
  - [ ] Case z = x: use the witness type constraint
  - [ ] Case z = t: use the parent atom / t-consistency constraint
  - [ ] Case z > x: use x's depth-k NF quant part to determine existence
  - [ ] Case z < t: use t's depth-k NF quant part to determine existence
- [ ] If the z > x / z < t cases are blocked after 6 hours: **trigger Approach C fallback**
  - [ ] Define `nf_multivar_exist_sf` recursing on k with increasing variable count
  - [ ] Prove forward by structural recursion
  - [ ] Prove backward by structural recursion + `nf_eval_unique`
- [ ] Close `nf_exist_sf_backward` (or its Approach C equivalent)
- [ ] Run `lake build`

**Timing**: 4-8 hours (Approach A); add 6-10 hours if fallback to Approach C is triggered

**Depends on**: 6C-3 (forward direction must be stable before attempting backward)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- backward direction proof (~100-300 lines for Approach A, ~400-600 lines for Approach C)

**Verification**:
- `nf_exist_sf_backward` (or equivalent) type-checks with no sorry
- `lake build` passes

---

#### Phase 6C-5: Wire Up and Verify Build [NOT STARTED]

**Goal**: Close the sorry at `nf_2var_existence_characterizable` (StaviCompleteness.lean:1865) using the forward and backward direction proofs from 6C-3 and 6C-4, then verify the full build.

**Tasks**:
- [ ] Replace the sorry at line 1865 with the proof combining `nf_exist_sf_forward` and `nf_exist_sf_backward` (or their Approach C equivalents)
- [ ] Handle both quant=true (forward: existence -> formula) and quant=false (backward: formula -> existence, via contrapositive) cases
- [ ] Run `#print axioms nf_characterizable_by_stavi` and verify no `sorryAx`
- [ ] Run `#print axioms stavi_expressive_completeness` and verify no `sorryAx`
- [ ] Run `lake build` to confirm zero errors in EFGames/
- [ ] Verify sorry count in StaviCompleteness.lean is zero

**Timing**: ~1 hour

**Depends on**: 6C-4 (needs both directions proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- close sorry at line 1865 (~20-40 lines wiring)

**Verification**:
- `nf_2var_existence_characterizable` sorry closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `#print axioms stavi_expressive_completeness` shows no `sorryAx`
- `lake build` passes with zero sorry warnings in EFGames/
- All Phase 6C sub-phases complete

---

### Phase 3C: U(B,A) Transfer -- Replace e_n Construction [BLOCKED on Phase 6C]

**Goal**: Using the formula materialization now available from Phase 6C (nf_characterizable_by_stavi), replace the current e_n construction (d-compatible forward game) with GHR93's U(B,A) transfer. This creates e_n as a formula witness above resp_tau(n-1), producing the chain geometry resp_tau(k) <= resp_tau(n-1) < e_n that resolves both sel_pn_ord and b_resp vs p_n.

**Why this phase depends on Phase 6C** (from reports 42a, 42b):
- Formula materialization (constructing interval type as StaviFormula) IS nf_characterizable_by_stavi.
- Path B (direct construction) is impossible without it.
- With Phase 6C complete, we have `nf_characterizable_by_stavi` at all depths, providing the formula builder needed for U(B,A).

**Partial progress**: `ghr93_winning_condition_perm` implemented in CustomGame.lean (sorry-free, 95 lines, verified). This enables selection sorting via Tuple.sort, which resolves the N-side of sel_pn_ord (a_init(k) < p_n via strict monotonicity). The M-side (resp_tau(k) < e_n) is what U(B,A) resolves.

**Why this is the correct fix** (from reports 34, 41):
- d is already inf(S_C) -- correct per GHR93. Do NOT change d's definition.
- The fan problem is fundamental to the e_n construction method, not to d's definition or sorting.
- GHR93's original construction avoids the fan problem entirely by constructing e_n via U(B,A) formula transfer.

**GHR93 Construction (pp. 115-116)**:
1. In Case II, tau applied to a_init(0),...,a_init(n-1) produces resp_tau(0),...,resp_tau(n-1).
2. Define B = rank-r type of (resp_tau(n-1), y) in M, materialized as StaviFormula via nf_characterizable_by_stavi (Phase 6C).
3. Define A = rank-r type of (a_init(n-1), y') in N -- equivalently, B transferred via tau.
4. U(B,A) is a StaviFormula expressing "there exists a point above me with type A, where all intermediate points have type B."
5. Since a_init(n-1) < p_n = a_bwd(n) and all points in (a_init(n-1), p_n) have type B (by continuity), U(B,A) holds at a_init(n-1) in N.
6. By tau's formula agreement at rank r (or r+4 via h_r1_univ), U(B,A) holds at resp_tau(n-1) in M.
7. The witness for U(B,A) at resp_tau(n-1) in M is e_n. By definition of U, e_n > resp_tau(n-1).
8. Chain: resp_tau(k) <= resp_tau(n-1) < e_n for all k <= n-1.
9. Combined: a_init(k) < p_n <-> resp_tau(k) < e_n = True <-> True.

**Rank adjustment note** (from report 42b Section 3.3): U(B,A) has stavi_depth = max(depth B, depth A) + 2 <= r+2, but tau preserves only depth <= r. May need to reconstruct tau at rank r+4 using h_r1_univ parameter. This is available via `h_r1_univ` which provides forward games at any rank.

**Strategy (Three Components)**:

1. **Sorting selections (Lemma 10)** (~60-80 lines):
   - Sort a_bwd via `Tuple.sort` (Mathlib.Data.Fin.Tuple.Sort), using `ghr93_winning_condition_perm` (already complete, 95 lines) to preserve winning condition.
   - Result: strictly increasing a_sorted(0) < ... < a_sorted(n), with a_init(k) < p_n for all k < n (N-side solved).

2. **Formula materialization -- U(B,A) as StaviFormula** (~80-160 lines):
   - Use `nf_characterizable_by_stavi` (from Phase 6C) to build point type X_t and interval type X_{(a,b)} as StaviFormulas at rank r.
   - Construct U(B, A) where B is the continuation type (rank-r type of resp_tau(n-1)) and A is the target type.
   - Prove that U(B,A) holds at a_init(n-1) in N (from the backward game structure + continuity).

3. **e_n via U(B,A) witness extraction** (~80-180 lines):
   - Transfer U(B,A) truth from N to M via tau's formula agreement (with rank adjustment if needed via h_r1_univ).
   - Extract e_n as the existential witness: the point in M above resp_tau(n-1) that satisfies type A.
   - Prove e_n > resp_tau(n-1) (from the Until semantics).
   - Chain: resp_tau(k) <= resp_tau(n-1) < e_n gives M-side.
   - Combined with N-side (from sorting): sel_pn_ord biconditional = True <-> True.
   - Prove b_resp vs p_n: b_resp position relative to p_n follows from the chain through resp_tau.

**Tasks**:
- [x] **Implement ghr93_winning_condition_perm** in CustomGame.lean (~60-80 lines). *(completed: 95 lines, sorry-free)*
- [ ] **Implement selection sorting** in ghr93_case_II (CaseAnalysis.lean). Sort a_bwd via Tuple.sort, show monotone. (~60-80 lines)
- [ ] **Construct interval type formula** as StaviFormula using nf_characterizable_by_stavi from Phase 6C. (~40-80 lines)
- [ ] **Construct U(B,A)** where B = continuation type, A = target type. Prove U(B,A) holds at a_init(n-1) in N. (~60-100 lines)
- [ ] **Handle rank adjustment** if needed: reconstruct tau at rank r+4 via h_r1_univ for U(B,A) transfer. (~40-60 lines)
- [ ] **Transfer U(B,A) truth from N to M** via tau formula agreement at sufficient rank. (~40-60 lines)
- [ ] **Extract e_n as U(B,A) witness** in M. Prove e_n > resp_tau(n-1). (~40-60 lines)
- [ ] **Close sel_pn_ord sorry** (both Case A line ~1435 and Case B line ~1804): replace `intro k; sorry` with the chain argument. (~20-40 lines)
- [ ] **Close b_resp vs p_n sorry** (Case B line ~2015): derive ordering from the U(B,A) chain infrastructure. (~20-40 lines)
- [ ] **Close pn_sel_ord sorry** (reverse direction): follows from the same chain. (~10-20 lines)
- [ ] **Run `lake build`** to confirm no regressions
- [ ] **Verify sorry count reduction** in CaseAnalysis.lean

**Timing**: 3-6 hours (reduced from 6-12h because Phase 6C provides formula materialization)

**Depends on**: 6C (formula materialization from nf_characterizable_by_stavi), 3A (COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- sorting in ghr93_case_II, sel_pn_ord closure, b_resp vs p_n closure (~260-520 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- formula materialization infrastructure if needed

**Verification**:
- sel_pn_ord sorry at Case A and Case B both closed
- b_resp vs p_n sorry at Case B closed
- `lake build` passes with zero errors
- Sorry count in CaseAnalysis.lean reduced (only winning condition assembly at line ~4100 remains)

---

### Phase 3B: Structured Proof Tactic Overhaul (S8/S9 Closure) [IN PROGRESS -- 2 goals deferred to Phase 3C]

**Goal**: Replace the `same_order_type_grid <;> first | ... | sorry` pattern in both Case A and Case B with structured focused proofs using named hypotheses, closing S8 and S9. Use the `sel_pn_ord` field from Phase 3A for the sel-vs-p_n goals.

**Root cause (from tactic report)**:
- The `same_order_type_grid` macro expands to `intro i j; simp only [game_tuple]; split_ifs` which produces inaccessible hypothesis names.
- Goal count: Case A has ~25 goals (0 fall through -- sorry-free), Case B has ~25 goals (originally 6 fell through, now 2 remain).

**Task 199 Results** (see specs/199_grid_order_tactic/ for full artifacts):
- Case A confirmed sorry-free. Case B reduced from 6 to 2 remaining goals.
- 4 of 6 Case B goals closed: 3 impossible-direction proofs + Goal 3 (sel vs p_n) via rename_i + targeted hab_eq rewrite.

**Tasks**:

- [x] **Case A (S8)**: Sorry-free. All ~25 grid goals close via existing `first` chain. *(confirmed by task 199 research)*

- [x] **Case A sel-vs-p_n**: Closed via `rw [show a_bwd ... = extendPoint p_n from hab_eq _ _ ...]; exact sel_pn_ord ...`. *(completed prior to task 199)*

- [x] **Case B impossible-direction goals (3 of 6)**: Closed by task 199. y' vs b_resp, y' vs p_n, p_n vs x' proved impossible from interval bounds.

- [x] **Case B Goal 3: sel(i) vs p_n unrewritten a_bwd (5-underscore variant)**: Closed by task 199 via `rename_i` + `hab_eq` rewrite + `sel_pn_ord` with Fin bridging.

- [x] **Case B Goal 3 (8-hypothesis variant)**: Closed in session sess_1779853135. Same sel(i) vs p_n pattern with 6 underscores.

- [ ] **Case B Goals 1-2: b_resp vs p_n ordering (DEFERRED to Phase 3C)**:
  - Goal 1: `(extendPoint b_resp < extendPoint p_n <-> extendPoint b_sp < e_n) /\ (... = ... <-> ... = ...)`
  - Goal 2: Reverse of Goal 1 (p_n vs b_resp)
  - **Root cause** (report 41 Section 8): Same fan problem as sel_pn_ord. d <= b_resp and d <= p_n but no chain. No existing hypothesis connects b_resp and p_n directly.
  - **Resolution**: U(B,A) transfer in Phase 3C creates chain geometry on M-side that resolves this alongside sel_pn_ord. Both sorry sites share the same root cause.

- [ ] **Remove dead code block**: Once Case B sorry is resolved (after Phase 3C), remove commented-out reference code.

- [ ] Run `lake build` to confirm both sorry sites are closed (after Phase 3C)

**Timing**: 1-2 hours remaining (cleanup after Phase 3C provides the ordering proofs)

**Depends on**: 3C (for the 2 blocked goals)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S9 remaining sorry at line ~1992 (2 goals)

**Key tactic patterns** (from the tactic report survey + task 199 findings):

| Goal Pattern | Tactic | Status |
|------|--------|--------|
| sel(i) vs sel(j) | `tau_sel_sel ...` | Working |
| sel(i) vs p_n | `rw [show a_bwd ... = extendPoint p_n from hab_eq ...]; exact sel_pn_ord ...` | Working (Phase 3A) |
| sel(i) vs p_n (unrewritten j-side a_bwd) | `rename_i ...; rw [show a_bwd ... from hab_eq ...]; convert sel_pn_ord ... using 3 <;> ...` | Working (task 199) |
| p_n vs sel(j) | `convert pn_sel_ord ... using 3 <;> ...` | Working |
| y' vs sel | `...tau_sel_y...` | Working |
| y' vs b_resp | impossible-direction proof from interval bounds | Working (task 199) |
| y' vs p_n | impossible-direction proof from interval bounds | Working (task 199) |
| p_n vs x' | impossible-direction proof from interval bounds | Working (task 199) |
| b_resp vs p_n | U(B,A) chain from Phase 3C | Blocked -> resolved by Phase 3C |
| x vs p_n | `...hord_fwd_x_en...` | Working |
| diagonal | `...Iff.rfl...` | Working |

**Verification**:
- S8 (Case A grid dispatch): sorry-free *(confirmed)*
- S9 (Case B grid dispatch): 2 goals remaining, resolved by Phase 3C
- `lake build` passes with all CaseAnalysis sorry sites closed

---

### Phase 5: Cases III/IV + Strategy Restriction (S11, S12) [PARTIAL]

**Goal**: Close S11 (Cases III/IV gap detection, CaseAnalysis.lean:~3043) and S12 (strategy restriction for rank-varying forward-to-backward, Theorem6.lean:307).

**Tasks**:

- [x] **Close S12 (Theorem6.lean:307, `ghr93_forward_to_backward_rank_varying`)**: Sub-interval strategy restriction. *(completed)*
  - Parameter approach -- modified `ghr93_forward_to_backward_rank_varying` to take `h_r1_univ` as parameter. Theorem6.lean is now fully sorry-free.

- [ ] **Close S11 (CaseAnalysis.lean:~3043, `ghr93_cases_III_IV`)**: Construct backward game response when a_n is a gap.
  - [x] Case-split on whether a_bwd(n) is left-defined or right-defined *(done)*
  - [x] Use `left_formula_gap_detection` / `right_formula_gap_detection` *(done)*
  - [x] Use `gap_detection_unique` *(done)*
  - [x] Construct response sequence *(done)*
  - [x] Handle degenerate boundary cases *(done)*
  - [x] **Prove gamma_M interval bounds** (lines ~3328, ~3639) *(COMPLETED -- degenerate boundary via tau/sigma endpoint agreement + non-degenerate via sub-interval forward game contradiction)*
  - [ ] **Assemble winning condition** (line ~4100): S11.3, ~200 lines following Case II pattern *(needs sel_pn_ord from Phase 3C for the grid dispatch)*
  - **Remaining sub-sorries (1)**:
    - Line ~4100: Winning condition assembly (needs sel_pn_ord dependency from Phase 3C)

- [x] Run `lake build` to confirm no regressions *(completed -- build passes)*

**Timing**: 2-4 hours remaining (winning condition assembly after Phase 3C)

**Depends on**: 3C (for sel_pn_ord in winning condition assembly), 4 (COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S11 winning condition at line ~4100

**Verification**:
- S11 winning condition sorry closed
- `lake build` passes
- Sorry count in Expressiveness/ reduced to zero (all CaseAnalysis and Theorem6 sorries closed)

---

### Phase 7: Reynolds Theorem 5 -- no_gaps_discrete (S14) [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in GoodStructures.lean:842) -- Reynolds Theorem 5 showing the integer model has no gaps.

**Tasks**:
- [ ] Read the current state of `no_gaps_discrete` in GoodStructures.lean
- [ ] Implement the gap elimination argument: since every NF is characterizable by a StaviFormula (Phase 6C), and StaviFormulas are determined by their truth at integer points, gaps in the integer model would require a type not characterizable by any StaviFormula -- contradiction
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 6C

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete at line 842 (~100-200 lines)

**Verification**:
- Sorry site S14 is closed
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Close succ_cofinal via Gap Elimination [NOT STARTED]

**Goal**: Prove `succ_cofinal` (ChronicleToCountermodel.lean:1885) -- the root sorry blocking `bx_completeness`. Also close 3 sub-proof sorry sites at lines 1285, 1441, and 1508.

**Tasks**:
- [ ] Read the current state of `succ_cofinal` and `limitDomSubtype_isSuccArchimedean`
- [ ] Close sub-proof sorry at line 1285 (boundary case)
- [ ] Close sub-proof sorry at line 1441 (below-min case)
- [ ] Close sorry at line 1508 (`limit_dom_points_are_succ_iterates`)
- [ ] Wire `no_gaps_discrete` + `nf_characterizable_by_stavi` to prove `IsSuccArchimedean` for `LimitDomSubtype`
- [ ] Argument: if there existed a point x in `LimitDomSubtype` with no successor, the interval (x, ...) would contain a gap. But `no_gaps_discrete` (via the chronicle's OrderIso) shows no such gap exists. Therefore every point has a successor.
- [ ] Close `succ_cofinal` -- makes `succ_embed_surjective`, `cantor_bfmcs_discrete_restricted_tc`, and `cantor_bfmcs_discrete_restricted_fuc` all sorry-free
- [ ] Verify `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal at line 1885, sub-proofs at lines 1285, 1441, 1508 (~100-300 lines)

**Verification**:
- `succ_cofinal` sorry is closed
- Sub-proof sorries at lines 1285, 1441, 1508 are closed
- `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- `#print axioms countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 9: Final Verification [NOT STARTED]

**Goal**: Verify `bx_completeness` is sorry-free after all preceding phases. No sorry closures needed -- task 198 resolved all Completeness.lean sorry sites.

**Tasks**:
- [ ] Run `#print axioms completeness_dense` and confirm no `sorryAx`
- [ ] Run `#print axioms completeness_discrete` and check status
- [ ] Run `#print axioms bx_completeness` (or `completeness`)
- [ ] Confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Run `lake build` -- confirm zero errors
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback

**Timing**: 0.5-1 hour (verification only, no code changes expected)

**Depends on**: 8

**Files to modify**:
- None expected. If unexpected `sorryAx` persists, investigate.

**Verification**:
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- `lake build` passes with zero errors

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] Phase 6A: `#print axioms ghr93_strategy_compose` shows no `sorryAx` (COMPLETED)
- [ ] Phase 6C-1: `nf_2var_existence_characterizable_depth0` type-checks with no sorry
- [ ] Phase 6C-2: `interval_guard_formula` type-checks, `nf_exist_sf` compiles with new guard
- [ ] Phase 6C-3: `nf_exist_sf_forward` type-checks with no sorry after guard strengthening
- [ ] Phase 6C-4: `nf_exist_sf_backward` type-checks with no sorry (Approach A or C)
- [ ] Phase 6C-5: `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] Phase 3C: sel_pn_ord sorry at Case A and Case B both closed via U(B,A) chain
- [ ] Phase 3C: b_resp vs p_n sorry at Case B closed via U(B,A) chain
- [ ] Phase 3B (completion): structured focused proofs replace `first | ... | sorry` pattern in both Case A and Case B
- [ ] Phase 5: S11 winning condition assembly closed
- [ ] Phase 7: `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] Phase 8: `succ_cofinal` sorry is closed
- [ ] Phase 9: `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` -- ghr93_winning_condition_perm (Phase 3C prep, COMPLETED)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` -- ghr93_strategy_compose (Phase 6A, NEW FILE)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization: interval guard formula, forward+backward direction proofs, nf_2var_existence_characterizable closure (Phases 6C-1 through 6C-5)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Phase 3B completion, Phase 3C sel_pn_ord + b_resp closure, Phase 5 S11
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- Phase 5 S12 (already complete)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- formula materialization infrastructure if needed (Phase 3C)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete (Phase 7)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal + sub-proofs (Phase 8)
- `specs/155_reynolds_pipeline_activation/plans/35_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**Phase 6A (Proposition 7 composition) contingency**:
1. The composition lemma is self-contained and well-structured. If cross-interval order proof is harder than expected, factor into sub-lemmas (left-left, left-right, right-right, boundary cases).
2. The padding approach (report 38 Section 5 Alternative) avoids explicit n_L/n_R counting. Use this if the partition approach is too complex.
3. If CustomGame.lean is too large, create Composition.lean as recommended.

**Phase 6B (EFGames-internal case analysis) contingency**:
1. If the case analysis is substantially larger than estimated (>600 lines), consider a new file `EFGames/CaseAnalysisInternal.lean` to keep StaviCompleteness.lean manageable.
2. The Expressiveness/CaseAnalysis.lean can serve as a reference implementation, but code CANNOT be shared due to circular import constraint.
3. If the mathematical content is identical, the Lean proofs can follow the same structure with adapted types.

**Phase 6C (nf_characterizable_by_stavi) contingency**:
1. **Sub-phase isolation**: Each sub-phase (6C-1 through 6C-5) is independently committable. If any sub-phase is blocked, prior sub-phases remain valuable and committed.
2. **Approach A -> C fallback**: If Phase 6C-4 (backward direction) cannot close the bridge argument for z > x / z < t cases within 6 hours, switch to Approach C (nested temporal formula). Approach C adds ~400-600 lines but is mathematically guaranteed to work (both directions by structural recursion on depth k).
3. **k=0 base case as early deliverable**: Phase 6C-1 proves the k=0 case separately, providing immediate progress and validating the infrastructure. Even if the general case is blocked, k=0 is closed.
4. **Hybrid approach**: If Approach A works for k=0 and k=1 but fails at k=2+, consider a hybrid: Approach A for small k, Approach C for the general inductive step. This may be more complex to maintain but reduces risk.
5. S1-S12 closures remain valuable as standalone GHR93 formalization progress regardless of Phase 6C outcome.

**Phase 3C (U(B,A) transfer) contingency**:
1. With Phase 6C complete, formula materialization is available. The main risk is the rank adjustment for tau (depth r+2 formula vs rank-r preservation).
2. If rank adjustment proves difficult, investigate whether U(B,A) can use a weaker formula (e.g., a K-operator formula at rank r) instead of full interval type at rank r+2.
3. If the entire U(B,A) approach is still blocked after Phase 6C, maintain the sorry'd `have sel_pn_ord` from Phase 3A and track the sorry as permanent mathematical debt. All downstream phases (5, 7-9) proceed with the sorry in place.

**Phase 8 (succ_cofinal via gap elimination) contingency**:
1. Document the precise gap.
2. Recommend Task 129 (Henkin canonical model approach) as alternative path to sorry-free `bx_completeness`.
3. All S1-S14 closures remain valuable.

**General rollback**: All changes committed after each phase. Git history enables rollback to any phase boundary.
