# Implementation Plan: Reynolds Pipeline Activation (v35 revised, reordered)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phases 1-4, 3A, 5 (interval bounds) complete; Phase 3B has 2 goals deferred; Phase 6 reordered FIRST per three-path research; Phase 3C depends on Phase 6
- **Effort**: 18-36 hours remaining (Phase 6A ~4-6h, Phase 6B ~4-8h, Phase 6C ~6-10h, Phase 3C ~3-6h, Phase 3B residual ~1-2h, Phase 5 residual ~2-4h, Phases 7-9 ~5-9h)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED), Task 168 (COMPLETED), Task 174 (COMPLETED), Task 198 (COMPLETED), Task 199 (PARTIAL -- closed 4/6 Case B grid goals, 2 blocked on b_resp vs p_n proof gap)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md, reports/32_post-dependency-assessment.md, reports/33_lit-sel-pn-ordering.md, reports/33_infra-sel-pn-fix.md, reports/33_tactic-sel-pn-grid.md, reports/34_lemma10-strategy-restrict.md, reports/35_gap-detection-literature.md, reports/38_proposition7-composition.md, reports/41_phase3c-d-as-minimum.md, reports/42_path-a-dependency-analysis.md, reports/42_path-b-direct-formula.md, reports/42_path-c-single-game.md, **Task 199**: specs/199_grid_order_tactic/reports/01_grid-order-tactic.md, specs/199_grid_order_tactic/reports/02_blocker-analysis.md
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

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 6B case analysis within EFGames larger than estimated (>600 lines) | H | M | The mathematical content is identical to Expressiveness/CaseAnalysis.lean but must be self-contained within EFGames. Start with the simplest case (Case I) as proof of concept. Factor shared pattern into helper lemmas. |
| nf_characterizable_by_stavi inductive step requires more than composition + case analysis | H | H | The full chain (report 38 Section 6) requires building temporal formulas for 2-variable NFs, which involves extensive case analysis. Start with Phase 6A (composition) as self-contained deliverable. |
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
| 3 | 6A | -- (no dependency on incomplete phases; all EFGames infrastructure is sorry-free except line 1567) |
| 4 | 6B | 6A |
| 5 | 6C | 6B |
| 6 | 3C | 6C (formula materialization from nf_characterizable_by_stavi) |
| 7 | 3B, 5 | 3C (3B's 2 blocked goals resolved by 3C; 5's winning condition assembly needs sel_pn_ord from 3C) |
| 8 | 7 | 6C (no_gaps_discrete needs nf_characterizable_by_stavi) |
| 9 | 8 | 7 |
| 10 | 9 | 8 |

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

### Phase 6B: EFGames-Internal Case Analysis for nf_characterizable_by_stavi [IN PROGRESS]

**Goal**: Implement the four-case analysis (Cases I-IV of GHR93 Section 8) entirely within the EFGames module, using the composition lemma from Phase 6A. This case analysis is required by nf_characterizable_by_stavi and CANNOT reuse Expressiveness/CaseAnalysis.lean (would create circular import).

**Why self-contained within EFGames** (from report 42a Section 4):
- Importing CaseAnalysis.lean into StaviCompleteness.lean would create a circular dependency: CaseAnalysis -> Claim1 -> StaviCompleteness would become CaseAnalysis -> Claim1 -> StaviCompleteness -> CaseAnalysis.
- The case analysis is the same mathematical content but must be formalized in a separate location within the EFGames module.
- This is a code quality concern (duplication) but not a correctness concern. Refactoring into a shared module can be done later.

**What the case analysis proves**: Given an (n+1)-round forward game and an n-round backward IH, construct an (n+1)-round backward strategy by case-splitting on the last selection's position relative to a split point:
- **Case I**: Last selection is between boundary and split point -- use composition (Phase 6A) to merge sub-interval strategies.
- **Case II**: Last selection is the split point itself (degenerate) -- trivial from sub-strategies.
- **Cases III/IV**: Last selection is beyond the split point -- use gap detection formulas (Lemma 9, already proved in GapDetection.lean) to handle gap cases.

**Tasks**:
- [ ] **Implement Case I** using ghr93_strategy_compose from Phase 6A. Apply composition with split point = last selection. The IH provides backward strategies on sub-intervals. (~100-200 lines)
- [ ] **Implement Case II** (degenerate). Split point coincides with selection -- use sub-interval strategy directly. (~30-50 lines)
- [ ] **Implement Cases III/IV** using gap detection formulas from GapDetection.lean. (~100-200 lines)
- [ ] **Assemble the four cases** into a unified backward strategy constructor that takes the forward game and produces the backward game. (~70-150 lines)
- [ ] **Run `lake build`** to confirm no regressions

**Timing**: 4-8 hours

**Depends on**: 6A

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- or a new file `EFGames/CaseAnalysisInternal.lean` if StaviCompleteness is too large (~300-600 lines)

**Verification**:
- Case analysis assembles into a complete backward strategy constructor
- No sorry sites introduced (all cases handled)
- `lake build` passes

---

### Phase 6C: Close nf_characterizable_by_stavi Sorry (S13) [IN PROGRESS]

**Goal**: Close the keystone sorry at StaviCompleteness.lean:1567 -- the inductive step of `nf_characterizable_by_stavi`. Every NormalForm at depth k+1 must be characterizable by a StaviFormula.

**Why this phase exists** (from report 38 Section 6, refined by report 42b):
- The inductive step requires building StaviFormulas for depth-(k+1) 1-variable NFs.
- The quantifier part requires temporal formulas (U, S, U', S') to capture 2-variable NF satisfaction.
- The correctness of these formulas requires the full game-theoretic machinery including composition (Phase 6A) and the completed case analysis (Phase 6B).

**GHR93 resolution of the "circularity"** (from report 42b Section 5):
- The induction on k is STANDARD: the k+1 case uses depth-k IH formulas (available by IH).
- The k+1 case invokes the game argument (Theorem 6 / Phase 6B's case analysis) with rank = k.
- The game argument uses X_t (point type) and X_{(a,b)} (interval type) at rank k, which are constructed from the depth-k IH.
- The game argument produces the backward strategy, which is used to construct the depth-(k+1) characteristic formula.
- This is NOT circular: we use depth-k formulas (available) to prove depth-(k+1) characterization.

**Integration chain**:
1. Composition lemma (6A) enables composing sub-interval strategies.
2. Case analysis (6B) provides the game-theoretic argument for all four GHR93 cases.
3. For depth-(k+1) NFs: the atom part uses `nf_base_sf` (already proved). The quantifier part needs temporal connectives (U/S/U'/S') applied to guards built from depth-k IH formulas.
4. Correctness uses Lemma 11 (game <-> decomposition, already proved in Decomposition.lean).

**Tasks**:
- [ ] **Build point type formula X_t at rank k** using k-case IH: for each `nf : NormalForm sig k 1`, the IH gives a characteristic StaviFormula. X_t = the IH formula for the NF of t. (~80-120 lines)
- [ ] **Build interval type formula X_{(a,b)} at rank k** using k-case IH: disjunction of X_v for all distinct point types v occurring in (a,b). Uses NormalForm finiteness. (~60-100 lines)
- [ ] **Build NF existence formula for depth-k 2-variable sub_nfs**: For each 2-variable depth-k sub_nf, construct a temporal formula (U/S/U'/S' with guards for intermediate types) using the 1-variable depth-k IH formulas. (~100-150 lines)
- [ ] **Prove correctness (forward direction)**: If `exists x, nf_eval_nf M k 2 (Fin.cons x ...) sub_nf`, show the temporal formula holds. Uses game infrastructure from Phase 6B. (~150-200 lines)
- [ ] **Prove correctness (backward direction)**: If temporal formula holds, show the existential is satisfied. Uses composition lemma (Phase 6A) to reconstruct NF satisfaction from temporal semantics. (~150-200 lines)
- [ ] **Assemble full StaviFormula** for depth-(k+1) NF: conjunction of atom part + quantifier part (~50-80 lines)
- [ ] **Prove full correctness** of the assembled formula (~100-150 lines)
- [ ] **Run `lake build`** to confirm no regressions

**Timing**: 6-10 hours (highest-risk phase)

**Depends on**: 6B

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step at line 1567 (~540-830 lines)

**Verification**:
- Sorry site S13 (StaviCompleteness.lean:1567) is closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `lake build` passes

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
- [ ] Phase 6A: `#print axioms ghr93_strategy_compose` shows no `sorryAx`
- [ ] Phase 6B: Case analysis assembles complete backward strategy, no sorry
- [ ] Phase 6C: `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
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
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step + EFGames-internal case analysis (Phases 6B, 6C)
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
1. Highest-risk phase. If the temporal formula builder for 2-variable NFs is more complex than estimated, break into sub-phases: (i) Until direction, (ii) Since direction, (iii) equality/gap cases.
2. The rank adjustment (tau at r+4 via h_r1_univ) may require additional infrastructure. If blocked, research whether U(B,A) can be encoded at depth <= r.
3. A dedicated research round on the 2-variable NF characterization may be needed.
4. S1-S12 closures remain valuable as standalone GHR93 formalization progress.

**Phase 3C (U(B,A) transfer) contingency**:
1. With Phase 6C complete, formula materialization is available. The main risk is the rank adjustment for tau (depth r+2 formula vs rank-r preservation).
2. If rank adjustment proves difficult, investigate whether U(B,A) can use a weaker formula (e.g., a K-operator formula at rank r) instead of full interval type at rank r+2.
3. If the entire U(B,A) approach is still blocked after Phase 6C, maintain the sorry'd `have sel_pn_ord` from Phase 3A and track the sorry as permanent mathematical debt. All downstream phases (5, 7-9) proceed with the sorry in place.

**Phase 8 (succ_cofinal via gap elimination) contingency**:
1. Document the precise gap.
2. Recommend Task 129 (Henkin canonical model approach) as alternative path to sorry-free `bx_completeness`.
3. All S1-S14 closures remain valuable.

**General rollback**: All changes committed after each phase. Git history enables rollback to any phase boundary.
