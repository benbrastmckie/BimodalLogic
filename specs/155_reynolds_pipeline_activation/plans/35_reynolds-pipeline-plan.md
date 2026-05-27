# Implementation Plan: Reynolds Pipeline Activation (v35 revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phases 1-4, 3A complete; Phase 3B blocked on 2 goals (fan problem); Phase 5 interval bounds closed, winning condition assembly deferred; Phase 3C rewritten around U(B,A) transfer; Phase 6 restructured into 6A/6B/6C
- **Effort**: 18-36 hours remaining (Phase 3C ~6-12h, Phase 5 residual ~2-4h, Phase 6A ~4-6h, Phase 6B ~4-8h, Phase 6C ~6-10h, Phases 7-9 ~5-9h)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED), Task 168 (COMPLETED), Task 174 (COMPLETED), Task 198 (COMPLETED), Task 199 (PARTIAL -- closed 4/6 Case B grid goals, 2 blocked on b_resp vs p_n proof gap)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md, reports/32_post-dependency-assessment.md, reports/33_lit-sel-pn-ordering.md, reports/33_infra-sel-pn-fix.md, reports/33_tactic-sel-pn-grid.md, reports/34_lemma10-strategy-restrict.md, reports/35_gap-detection-literature.md, reports/38_proposition7-composition.md, reports/41_phase3c-d-as-minimum.md, **Task 199**: specs/199_grid_order_tactic/reports/01_grid-order-tactic.md, specs/199_grid_order_tactic/reports/02_blocker-analysis.md
- **Artifacts**: plans/35_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline. Phases 1-4 are complete, closing 9 sorry sites and establishing key infrastructure: K-(negD) bridge (Phase 2), d-compatible forward game with `h_d_compat_left` (Phase 3 breakthrough), and position-tracking `ghr93_rank_down_proj` (Phase 4).

Two root blockers have been identified (reports 38 and 41):

1. **Phase 3C fan problem**: The current e_n construction via d-compatible forward game creates a "fan" geometry where d is below both resp_tau(k) and e_n, but no chain exists between them. Sorting (Lemma 10) resolves the N-side of sel_pn_ord (a_init(k) < p_n) but NOT the M-side (resp_tau(k) < e_n). The only clean fix is replacing the e_n construction with GHR93's U(B,A) transfer, which constructs e_n as a formula witness above resp_tau(n-1), creating the chain resp_tau(k) <= resp_tau(n-1) < e_n. This also resolves the b_resp vs p_n sorry (same fan problem). Estimated 260-520 lines.

2. **Phase 6 requires Proposition 7**: The nf_characterizable_by_stavi sorry at StaviCompleteness.lean:1567 is blocked by a missing composition lemma (GHR93 Proposition 7). This lemma composes Duplicator winning strategies on sub-intervals into a strategy on the full interval. Without it, there is no way to bridge the 1-variable IH to the 2-variable quantifier step. Phase 6 is restructured into 6A (composition lemma), 6B (CaseAnalysis sorries using composition), 6C (nf_characterizable_by_stavi closure).

User directive: follow mathematically correct GHR93 approach head on, no workarounds.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Seventeen research reports, a blocker study, and two task 199 reports were integrated into this plan:

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
- **Phase 3C COMPLETELY REWRITTEN**: v34 described Phase 3C as "Lemma 10 + relabeling + d-as-minimum restructure (~300-500 lines)". Report 41 conclusively proves this is insufficient: sorting fixes N-side only, M-side (resp_tau(k) < e_n) remains blocked by the fan problem. d is already inf(S_C) and must NOT be changed (would break Claim 1). The real fix is replacing the e_n construction with GHR93's U(B,A) transfer (~260-520 lines), which also resolves b_resp vs p_n (same fan problem).
- **Phase 3B b_resp vs p_n goals absorbed into Phase 3C**: The 2 blocked Case B goals share the same fan problem root cause as sel_pn_ord. U(B,A) transfer in Phase 3C resolves both.
- **Phase 5 updated**: Interval bound sub-sorries at lines ~3328 and ~3639 are now CLOSED. Phase 5 reduced to winning condition assembly (line ~4100, ~200 lines).
- **Phase 6 RESTRUCTURED into 6A/6B/6C**: Report 38 identifies GHR93 Proposition 7 (composition lemma) as the root blocker for Phase 6. New sub-phases: 6A implements composition in Composition.lean (250-390 lines), 6B closes CaseAnalysis sorries using composition (300-600 lines), 6C closes nf_characterizable_by_stavi (550-780 lines).
- **Non-Goals updated**: "Implementing full Lemma 10 + relabeling" removed (superseded by U(B,A) approach). "Restructuring e_n construction" removed from Non-Goals (now the primary approach).
- Research Inputs expanded with reports 38 and 41.
- Effort recalibrated upward for Phase 3C (6-12h vs 6-10h) and Phase 6 (14-24h total for 6A+6B+6C).

## Goals & Non-Goals

**Goals**:
- Close all remaining critical-path sorry sites
- Prove `succ_cofinal` via gap elimination using `nf_characterizable_by_stavi` + `no_gaps_discrete`
- Achieve sorry-free `bx_completeness`
- Replace e_n construction with GHR93-faithful U(B,A) transfer (resolves sel_pn_ord and b_resp vs p_n)
- Implement GHR93 Proposition 7 (composition lemma) to unblock Phase 6

**Non-Goals**:
- Closing TruthLemma.lean sorry sites (non-critical-path)
- Closing OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- Archiving BXCanonical dead-code sorries
- Building rank_lift infrastructure
- OrderIso bypass (Track A) -- proven infeasible
- Approach A (Fintype enumeration for StaviFormula) -- blocked by infinite atoms
- Changing d from inf(S_C) to min(selections) -- would break Claim 1 infrastructure (report 41 Section 7)

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

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| U(B,A) formula materialization harder than estimated (>520 lines) | H | M | Report 41 Section 9.2 provides detailed line estimates. Start with formula materialization infrastructure, test with simple formulas before full X_t construction. If blocked, research alternative temporal formula encoding. |
| b_resp vs p_n NOT fully resolved by U(B,A) transfer | H | L | Report 41 Section 8 confirms b_resp vs p_n shares the same fan root cause. U(B,A) creates chain on M-side that should resolve both. If not, the b_resp ordering through the new tau responses should provide a direct path. |
| Proposition 7 composition proof more complex than estimated | H | M | Existing strategy_restrict_left/right provide the CONVERSE decomposition. The composition direction is harder but well-structured. Round monotonicity + padding approach (report 38 Section 5) avoids explicit counting. |
| nf_characterizable_by_stavi inductive step requires more than composition | H | H | The full chain (report 38 Section 6) requires building temporal formulas for 2-variable NFs, which involves extensive case analysis. Start with Phase 6A (composition) as self-contained deliverable. |
| S11 winning condition assembly has unexpected mathematical gap | M | M | Interval bounds are now closed. Remaining work follows Case II pattern closely. |
| Build regression after structural changes to e_n construction | M | M | Run `lake build` after every component. Commit working states. |
| Sorting infrastructure (Tuple.sort) not available in current Mathlib | L | L | Report 41 Section 6 confirms Tuple.sort exists in Mathlib.Data.Fin.Tuple.Sort. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- (COMPLETED) |
| 2 | 3A | 2 (COMPLETED) |
| 3 | 3C | 3A (Phase 3C replaces e_n construction; resolves sel_pn_ord + b_resp vs p_n) |
| 4 | 3B, 5 | 3C (3B's 2 blocked goals resolved by 3C; 5's winning condition assembly needs sel_pn_ord from 3C) |
| 5 | 6A | 5 |
| 6 | 6B | 6A |
| 7 | 6C | 6B |
| 8 | 7 | 6C |
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

**Timing**: Remaining work (2 goals + cleanup) depends on Phase 3C completion.

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
| b_resp vs p_n | DEFERRED to Phase 3C (U(B,A) transfer resolves fan problem) | Blocked |
| x vs p_n | `...hord_fwd_x_en...` | Working |
| diagonal | `...Iff.rfl...` | Working |

**Verification**:
- S8 (Case A grid dispatch): sorry-free *(confirmed)*
- S9 (Case B grid dispatch): 2 goals remaining, deferred to Phase 3C
- `lake build` passes with sorry fallback in place for 2 goals

---

### Phase 3C: U(B,A) Transfer -- Replace e_n Construction [NOT STARTED]

**Goal**: Replace the current e_n construction (d-compatible forward game) with GHR93's U(B,A) transfer. This creates e_n as a formula witness above resp_tau(n-1), producing the chain geometry resp_tau(k) <= resp_tau(n-1) < e_n that resolves both sel_pn_ord and b_resp vs p_n.

**Why this is the correct fix** (from reports 34, 41):
- d is already inf(S_C) -- correct per GHR93. Do NOT change d's definition.
- The fan problem is fundamental to the e_n construction method, not to d's definition or sorting (report 41 Sections 3-4).
- Sorting (Lemma 10) resolves the N-side (a_init(k) < p_n via strict monotonicity) but NOT the M-side (resp_tau(k) < e_n). Report 41 Sections 3.6-4.4 prove every M-side variation hits the fan wall.
- GHR93's original construction avoids the fan problem entirely by constructing e_n via U(B,A) formula transfer: e_n is a witness for a temporal formula that holds above resp_tau(n-1), so e_n > resp_tau(n-1) by construction.

**GHR93 Construction (pp. 115-116)**:
1. In Case II, tau applied to a_init(0),...,a_init(n-1) produces resp_tau(0),...,resp_tau(n-1).
2. Define B = rank-r type of (resp_tau(n-1), y) in M.
3. Define A = rank-r type of (a_init(n-1), y') in N -- equivalently, B transferred via tau.
4. U(B,A) is a StaviFormula expressing "there exists a point above me with type A, where all intermediate points have type B."
5. Since a_init(n-1) < p_n = a_bwd(n) and all points in (a_init(n-1), p_n) have type B (by continuity), U(B,A) holds at a_init(n-1) in N.
6. By tau's formula agreement at rank r+1 (or by forward game transfer), U(B,A) holds at resp_tau(n-1) in M.
7. The witness for U(B,A) at resp_tau(n-1) in M is e_n. By definition of U, e_n > resp_tau(n-1).
8. Since resp_tau is order-preserving (from tau): resp_tau(k) <= resp_tau(n-1) < e_n for all k <= n-1.
9. The chain provides: a_init(k) < p_n <-> resp_tau(k) < e_n = True <-> True.

**Strategy (Three Components)**:

1. **Sorting selections (Lemma 10)** (~60-80 lines):
   - Implement `ghr93_winning_condition_perm` in CustomGame.lean: winning condition preserved under permutation of both selection arrays by the same permutation (report 41 Section 5).
   - Sort a_bwd via `Tuple.sort` (Mathlib.Data.Fin.Tuple.Sort) to get monotone selections.
   - WLOG distinct: same_order_type's `=` component forces a'_i = a'_j when a_i = a_j, so duplicates can be collapsed.
   - Result: strictly increasing a_sorted(0) < ... < a_sorted(n), with a_init(k) < p_n for all k < n (N-side solved).

2. **Formula materialization -- U(B,A) as StaviFormula** (~100-200 lines):
   - Define the interval type formula X_t for a given rank-r type as a StaviFormula.
   - Construct U(B, A) where B is the continuation type (rank-r type of resp_tau(n-1)) and A is the target type.
   - Prove that U(B,A) holds at a_init(n-1) in N (from the backward game structure).
   - Key infrastructure: `stavi_temporal_truth_mu` already exists for evaluating StaviFormulas. Need to construct the formula from a type witness.

3. **e_n via U(B,A) witness extraction** (~100-240 lines):
   - Transfer U(B,A) truth from N to M via tau's formula agreement (or forward game).
   - Extract e_n as the existential witness: the point in M above resp_tau(n-1) that satisfies type A.
   - Prove e_n > resp_tau(n-1) (from the Until semantics).
   - Chain: resp_tau(k) <= resp_tau(n-1) < e_n gives M-side.
   - Combined with N-side (from sorting): sel_pn_ord biconditional = True <-> True.
   - Prove b_resp vs p_n: b_resp comes from tau, so it has a position in the sorted chain. The chain through resp_tau provides the needed ordering relative to e_n. On the N-side, b_resp is in [d, y'] and the sorted selections give b_resp's position relative to p_n.

**Tasks**:
- [ ] **Implement ghr93_winning_condition_perm** in CustomGame.lean (~60-80 lines). Proof strategy: unfold winning condition, show permuting both tuples by the same sigma preserves same_order_type, gap_point_agreement, and formula_agreement at corresponding indices.
- [ ] **Implement selection sorting** in ghr93_case_II (CaseAnalysis.lean). Sort a_bwd via Tuple.sort, show monotone. Handle WLOG distinct (collapse duplicates or show injective from game properties).
- [ ] **Construct interval type formula** as StaviFormula. Define a function that takes a rank-r type witness and produces a StaviFormula characterizing that type.
- [ ] **Construct U(B,A)** where B = continuation type, A = target type. Prove U(B,A) holds at a_init(n-1) in N.
- [ ] **Transfer U(B,A) truth from N to M** via tau formula agreement at sufficient rank.
- [ ] **Extract e_n as U(B,A) witness** in M. Prove e_n > resp_tau(n-1).
- [ ] **Close sel_pn_ord sorry** (both Case A line ~1435 and Case B line ~1804): replace `intro k; sorry` with the chain argument resp_tau(k) <= resp_tau(n-1) < e_n combined with a_init(k) < p_n.
- [ ] **Close b_resp vs p_n sorry** (Case B line ~2015): derive ordering from the U(B,A) chain infrastructure.
- [ ] **Close pn_sel_ord sorry** (reverse direction): follows from the same chain.
- [ ] **Run `lake build`** to confirm no regressions.
- [ ] **Verify sorry count reduction** in CaseAnalysis.lean.

**Timing**: 6-12 hours (major structural work)

**Depends on**: 3A (COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` -- ghr93_winning_condition_perm (~60-80 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- sorting in ghr93_case_II, sel_pn_ord closure, b_resp vs p_n closure (~200-440 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- formula materialization infrastructure if needed

**Verification**:
- sel_pn_ord sorry at Case A and Case B both closed
- b_resp vs p_n sorry at Case B closed
- `lake build` passes with zero errors
- Sorry count in CaseAnalysis.lean reduced (only Cases III-IV sorry at line ~4100 remains)

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
  - [ ] **Assemble winning condition** (line ~4100): S11.3, ~200 lines following Case II pattern *(deviation: deferred -- needs sel_pn_ord from Phase 3C for the grid dispatch)*
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
- Sorry count in Expressiveness/ reduced to Phase 6 dependencies only

---

### Phase 6A: GHR93 Proposition 7 -- Strategy Composition Lemma [NOT STARTED]

**Goal**: Implement `ghr93_strategy_compose` -- the composition lemma that combines Duplicator winning strategies on sub-intervals [x,c] and [c,y] into a winning strategy on the full interval [x,y]. This is the missing infrastructure that unblocks the nf_characterizable_by_stavi inductive step.

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
- [ ] **Define partition_selections** -- classify selections by position relative to split point c (~30-40 lines)
- [ ] **Define merge_responses** -- recombine sub-interval responses into full response (~30-40 lines)
- [ ] **Prove cross-interval order transfer** -- left responses <= d <= right responses implies correct order (~40-60 lines)
- [ ] **Prove ghr93_strategy_compose** -- main theorem combining all components (~150-250 lines)
- [ ] **Run `lake build`** to confirm no regressions

**Timing**: 4-6 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` (NEW FILE) -- composition lemma + auxiliary definitions (~250-390 lines)

**Verification**:
- `ghr93_strategy_compose` type-checks with no sorry
- `#print axioms ghr93_strategy_compose` shows no `sorryAx`
- `lake build` passes

---

### Phase 6B: Close CaseAnalysis.lean Sorries Using Composition [NOT STARTED]

**Goal**: Use the composition lemma from Phase 6A to close remaining CaseAnalysis.lean sorries in the main induction (Cases I through the final assembly).

**Why needed** (from report 38 Section 6):
- Case I of the GHR93 induction decomposes the forward game via strategy_restrict into sub-intervals, applies the IH to each, then COMPOSES the sub-interval backward strategies back into a full-interval backward strategy.
- The composition step is precisely ghr93_strategy_compose from Phase 6A.

**Tasks**:
- [ ] **Close Case I composition sorry**: Apply ghr93_strategy_compose to compose sub-interval strategies after IH application (~100-200 lines)
- [ ] **Close remaining Cases II-IV assembly sorries**: Integrate composition with the winning condition proofs from Phase 5 (~100-200 lines)
- [ ] **Complete ghr93_inductive_step** so all cases (I through IV) contribute to the final backward strategy (~100-200 lines)
- [ ] **Run `lake build`** to confirm no regressions

**Timing**: 4-8 hours

**Depends on**: 6A

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Case I composition, Cases II-IV assembly (~300-600 lines)

**Verification**:
- All sorry sites in ghr93_inductive_step closed
- `lake build` passes

---

### Phase 6C: Close nf_characterizable_by_stavi Sorry (S13) [NOT STARTED]

**Goal**: Close the keystone sorry at StaviCompleteness.lean:1567 -- the inductive step of `nf_characterizable_by_stavi`. Every NormalForm at depth k+1 must be characterizable by a StaviFormula.

**Why this phase exists** (from report 38 Section 6):
- The inductive step requires building StaviFormulas for depth-(k+1) 1-variable NFs.
- The quantifier part requires temporal formulas (U, S, U', S') to capture 2-variable NF satisfaction.
- The correctness of these formulas requires the full game-theoretic machinery including composition (Phase 6A) and the completed main induction (Phase 6B).

**Integration chain** (from report 38 Section 6):
1. Composition lemma (6A) enables proving n-equivalence => Duplicator wins EF game.
2. Completed main induction (6B) provides the game-theoretic argument for all cases.
3. Build StaviFormula for depth-(k+1) NFs using temporal connectives + IH at depth k.
4. Prove correctness using Lemma 11 (game <-> decomposition, already proved in Decomposition.lean).

**Tasks**:
- [ ] **Build NF existence formula for k >= 1 sub_nfs**: For each 2-variable depth-k sub_nf, construct a temporal formula (U/S/U'/S' with guards for intermediate types) (~100-150 lines)
- [ ] **Prove correctness (forward direction)**: If `exists x, nf_eval_nf M k 2 (Fin.cons x ...)  sub_nf`, show the temporal formula holds. Uses game infrastructure. (~150-200 lines)
- [ ] **Prove correctness (backward direction)**: If temporal formula holds, show the existential is satisfied. Uses composition lemma to reconstruct NF satisfaction from temporal semantics. (~150-200 lines)
- [ ] **Assemble full StaviFormula** for depth-(k+1) NF: conjunction of atom part + quantifier part (~50-80 lines)
- [ ] **Prove full correctness** of the assembled formula (~100-150 lines)
- [ ] **Run `lake build`** to confirm no regressions

**Timing**: 6-10 hours (highest-risk phase)

**Depends on**: 6B

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step at line 1567 (~550-780 lines)

**Verification**:
- Sorry site S13 (StaviCompleteness.lean:1567) is closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `lake build` passes

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
- [ ] Phase 3C: sel_pn_ord sorry at Case A and Case B both closed via U(B,A) chain
- [ ] Phase 3C: b_resp vs p_n sorry at Case B closed via U(B,A) chain
- [ ] Phase 3B (completion): structured focused proofs replace `first | ... | sorry` pattern in both Case A and Case B
- [ ] Phase 5: S11 winning condition assembly closed
- [ ] Phase 6A: `#print axioms ghr93_strategy_compose` shows no `sorryAx`
- [ ] Phase 6C: `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] Phase 7: `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] Phase 8: `succ_cofinal` sorry is closed
- [ ] Phase 9: `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` -- ghr93_winning_condition_perm (Phase 3C)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` -- ghr93_strategy_compose (Phase 6A, NEW FILE)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- formula materialization infrastructure (Phase 3C)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Phase 3B completion, Phase 3C sel_pn_ord + b_resp closure, Phase 5 S11
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- Phase 5 S12 (already complete)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step (Phase 6C)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete (Phase 7)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal + sub-proofs (Phase 8)
- `specs/155_reynolds_pipeline_activation/plans/35_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**Phase 3C (U(B,A) transfer) contingency**:
1. Formula materialization is the highest-risk component. If constructing X_t as a StaviFormula proves infeasible, investigate whether a weaker formula (e.g., a K-operator formula at appropriate rank) suffices to construct e_n above resp_tau(n-1).
2. If the entire U(B,A) approach is blocked, maintain the sorry'd `have sel_pn_ord` from Phase 3A and track the sorry as permanent mathematical debt. All downstream phases (5-9) proceed with the sorry in place.
3. The sel_pn_ord and b_resp vs p_n sorries do NOT block any phase other than final axiom-free verification (Phase 9). The pipeline is functional with these sorries.

**Phase 6A (Proposition 7 composition) contingency**:
1. The composition lemma is self-contained and well-structured. If cross-interval order proof is harder than expected, factor into sub-lemmas (left-left, left-right, right-right, boundary cases).
2. The padding approach (report 38 Section 5 Alternative) avoids explicit n_L/n_R counting. Use this if the partition approach is too complex.
3. If CustomGame.lean is too large, create Composition.lean as recommended.

**Phase 6B-6C (CaseAnalysis sorries + nf_characterizable_by_stavi) contingency**:
1. Highest-risk phases. If the temporal formula builder for 2-variable NFs is more complex than estimated, break into sub-phases: (i) Until direction, (ii) Since direction, (iii) equality/gap cases.
2. S1-S12 closures remain valuable as standalone GHR93 formalization progress.
3. A dedicated research round on the 2-variable NF characterization may be needed.

**Phase 8 (succ_cofinal via gap elimination) contingency**:
1. Document the precise gap.
2. Recommend Task 129 (Henkin canonical model approach) as alternative path to sorry-free `bx_completeness`.
3. All S1-S14 closures remain valuable.

**General rollback**: All changes committed after each phase. Git history enables rollback to any phase boundary.
