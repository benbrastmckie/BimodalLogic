# Implementation Plan: Reynolds Pipeline Activation (v34 revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phase 3A superseded (unified game infeasible), replaced with sel_pn_ord sorry'd field approach
- **Effort**: 12-22 hours remaining (Phases 1-4 complete, Phase 3A-new ~1h, Phase 3B ~2-4h, Phases 5-9 pending)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED), Task 168 (COMPLETED), Task 174 (COMPLETED), Task 198 (COMPLETED), Task 199 (PARTIAL — closed 4/6 Case B grid goals, 2 blocked on b_resp vs p_n proof gap)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md, reports/32_post-dependency-assessment.md, reports/33_lit-sel-pn-ordering.md, reports/33_infra-sel-pn-fix.md, reports/33_tactic-sel-pn-grid.md, reports/34_lemma10-strategy-restrict.md, **Task 199**: specs/199_grid_order_tactic/reports/01_grid-order-tactic.md (grid dispatch inventory), specs/199_grid_order_tactic/reports/02_blocker-analysis.md (b_resp vs p_n proof gap analysis)
- **Artifacts**: plans/34_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline. Phases 1-4 are complete, closing 9 sorry sites and establishing key infrastructure: K-(negD) bridge (Phase 2), d-compatible forward game with `h_d_compat_left` (Phase 3 breakthrough), and position-tracking `ghr93_rank_down_proj` (Phase 4).

Phase 3A (unified game restructure) has been **superseded** after exhaustive analysis proved ALL game-based approaches infeasible for the sel-vs-p_n ordering. Report 34 (Lemma 10 feasibility) confirmed that the fundamental gap is structural: any game play produces NEW N-side responses that are NOT `a_init(k)`, and the order-isomorphism between old and new responses does NOT extend to ordering relative to `p_n`. This supersedes 6 specific failed approaches documented in the Phase 3A BLOCKER section of the v33 plan.

The revised approach uses the **pragmatic fix from report 34**: add `sel_pn_ord` as a sorry'd field in `SplitPointProps` (~30 lines), propagate it to the sorry sites (~50 lines), then close the 2 sorry sites via structured focused proofs in Phase 3B. The sorry in `obtain_split_point_props` becomes a deferred obligation tracked in Phase 3C, requiring Lemma 10 + relabeling + d-as-minimum restructuring (~300-500 lines) to close properly.

Seven live sorry sites remain on the critical path across 5 files: CaseAnalysis.lean (3), Theorem6.lean (1), StaviCompleteness.lean (1), GoodStructures.lean (1), ChronicleToCountermodel.lean (1+3 sub-proofs). Phase 9 (Completeness.lean wiring) is resolved by task 198 and reduced to a verification step. Task 199 reduced the Case B grid dispatch sorry from 6 unclosed goals to 2 (b_resp vs p_n ordering — a genuine proof gap requiring structural fix; see Phase 3B and specs/199_grid_order_tactic/reports/02_blocker-analysis.md).

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Fifteen research reports and a blocker study were integrated into this plan:

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
| **34_lemma10-strategy-restrict** | **Lemma 10 alone does NOT solve blocker; ALL game-based approaches fail; pragmatic fix: sel_pn_ord sorry'd field (~80 lines); proper fix: Lemma 10 + relabeling + d-as-minimum (~300-500 lines)** | **This revision**: Phase 3A replaced with sorry'd field; Phase 3C added for deferred sorry closure |
| **Task 199: 01_grid-order-tactic** | Case A grid dispatch already sorry-free; Case B has 6 goals (not 5): 3 impossible-direction, 1 fixable hab_eq rewrite, 2 genuine proof gap (b_resp vs p_n fan ordering). fan_order theorem is provably false (counterexample). | Phase 3B updated: Case A confirmed done; Case B reduced from 6→2 goals by task 199 implementation; Goal 3 (sel vs p_n) closed via rename_i + hab_eq + sel_pn_ord |
| **Task 199: 02_blocker-analysis** | b_resp vs p_n unprovable from current hypotheses: Case B has fan geometry (d≤b_resp AND d≤p_n) not chain. No game contains both b_resp and p_n. Three fix options: additional big game challenge, restructured padding, or double-challenge construction. | Phase 3B blocker: 2 remaining goals require proof-level restructuring, not tactic-level fixes |

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
- fan_order theorem added to Superseded Approaches (#17) — provably false via counterexample
- grid_order_tac macro approach added to Superseded Approaches (#18) — blocked by fan_order invalidity
- 2 remaining goals (b_resp vs p_n, p_n vs b_resp) documented as genuine proof gap with three proposed structural fixes from task 199 blocker analysis
- Research Inputs expanded with task 199 reports (01_grid-order-tactic.md, 02_blocker-analysis.md)
- Tactic patterns table expanded with working patterns discovered by task 199

**v34 revised (2026-05-26)**: Post-Lemma-10-research revision incorporating report 34 findings. Changes:
- Phase 3A (unified game restructure) **superseded** -- all game-based approaches proven infeasible (report 34 Sections 2-5)
- Phase 3A replaced with pragmatic sorry'd field approach: add `sel_pn_ord` to SplitPointProps (~30 lines) + propagate to sorry sites (~50 lines)
- Phase 3C added: deferred sorry closure via Lemma 10 + relabeling + d-as-minimum restructuring (300-500 lines)
- Superseded Approaches expanded to 16 entries (2 new from report 34)
- Effort recalibrated downward for Phase 3A (from 2-4h to ~1h), upward for Phase 3C (new, 6-10h)
- Total effort reduced for short-term path (Phase 3A-new + 3B unblocks Phases 5-9), deferred Lemma 10 effort tracked separately

## Goals & Non-Goals

**Goals**:
- Close all 7 remaining critical-path sorry sites (+ 3 sub-proofs in ChronicleToCountermodel)
- Prove `succ_cofinal` via gap elimination using `nf_characterizable_by_stavi` + `no_gaps_discrete`
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Closing TruthLemma.lean sorry sites (non-critical-path)
- Closing OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- Archiving BXCanonical dead-code sorries
- Building rank_lift infrastructure
- OrderIso bypass (Track A) -- proven infeasible
- Approach A (Fintype enumeration for StaviFormula) -- blocked by infinite atoms
- Restructuring e_n construction to U(B,A) transfer -- infeasible in current architecture (report 22, Section 5.1.1)
- Implementing full Lemma 10 + relabeling in this plan cycle (deferred to Phase 3C / separate task)

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
| 17 | **fan_order abstract order lemma (task 199 Phase 1)** | Task 199 implementation | Given fan d≤a, d≤b with order-preserving maps, derive a vs b ordering. PROVABLY FALSE: counterexample p=0, a=1, b=2, q=0, a'=2, b'=1 satisfies all hypotheses but conclusion fails. Fan geometry does not determine relative order of the upper elements. |
| 18 | **grid_order_tac macro approach (task 199 Phases 2-3)** | Task 199 plan | Build a reusable tactic macro to dispatch all grid goals. BLOCKED by fan_order invalidity (goals 1-2 unprovable). Inline strategy additions used instead for closable goals. |

**Key settled questions**:
- Infimum redefinition IS necessary (reports 29, 35). Do not revisit.
- Track A (OrderIso bypass) is NOT FEASIBLE. Do not revisit.
- Approach A (Fintype enumeration) is BLOCKED by infinite atoms. Do not revisit.
- D-compatible forward game is the correct approach for cross-boundary orderings. Do not regress to h_fwd_n1 or h_fwd_n1_d.
- Sel-vs-p_n ordering CANNOT be derived from ANY combination of separate game plays. Every game produces new responses; order-isomorphism does not extend past shared bounds. This is settled by report 34's exhaustive analysis.
- The `same_order_type_grid <;> first | ... | sorry` pattern is structurally inadequate for goals requiring named hypotheses. Structured focused proofs with bullet notation are the correct replacement.
- The sel_pn_ord property IS mathematically true (follows from GHR93 once d is defined as minimum of selections). The pragmatic sorry'd field approach is justified.
- **Fan ordering is provably false** (task 199): Given a fan d≤a, d≤b with order-preserving maps, the relative order of a vs b is NOT determined. Counterexample: p=0, a=1, b=2, q=0, a'=2, b'=1. Do NOT attempt abstract fan_order lemmas.
- **Case B b_resp vs p_n requires structural fix** (task 199 blocker analysis): Neither the tau game nor the big game contains both b_resp and p_n. An additional game challenge or padding restructure is needed. Three options documented in specs/199_grid_order_tactic/reports/02_blocker-analysis.md.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| sel_pn_ord sorry'd field introduces a dependency that is hard to close later | H | M | The property is mathematically true (report 34 Section 7). Deferred to Phase 3C with concrete implementation path (Lemma 10 + relabeling + d-as-minimum). Can also be a separate task. |
| Structured proof verbosity exceeds expectations (>300 lines per case) | M | M | Start with Case A (fewer goals); reuse exact terms from existing `first` chain where they work; factor shared tactic sequences into local `have` lemmas. |
| sel_pn_ord field type does not match the exact goal shape in CaseAnalysis.lean | M | L | Read the exact goal shapes at sorry sites before defining the field. May need `a_bwd` indexing instead of `a_init`. |
| S11 gap detection assembly has unexpected mathematical gap | H | M | left/right_formula_gap_detection proved sorry-free; risk is in assembly only |
| S12 parameter approach requires deep IH structure changes | M | M | IH already universally quantifies over intervals; should be straightforward |
| S13 inductive step requires infrastructure beyond Phases 3-5 | H | H | Defer to Phase 6; all prior phases provide infrastructure. If blocked, document what remains. |
| Build regression after wiring changes | M | L | Run `lake build` after every phase; commit working states |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- (COMPLETED) |
| 2 | 3A | 2 (COMPLETED) |
| 3 | 3B | 3A |
| 4 | 5 | 3B, 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 6, 7 |
| 8 | 9 | 8 |
| 9 | 3C | 9 (deferred, can run anytime after sorry-free bx_completeness excluding sel_pn_ord) |

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

**Goal**: Add `sel_pn_ord` as a sorry'd field in `SplitPointProps`, providing the missing ordering between tau selections and p_n. This unblocks Phase 3B without requiring the infeasible unified game restructure.

**Root cause (from research)**:
- The sel-vs-p_n ordering `(a_init(k) < extendPoint p_n <-> resp_tau(k) < e_n)` cannot be derived from any combination of separate game plays (report 34, exhaustive analysis of 16 approaches).
- In GHR93, this is trivially true because d is defined as the minimum of all selections and selections are relabeled to be increasing. The formalization's choice of d = a_bwd(n) (last index rather than minimum) creates the gap.
- The property IS mathematically true and will be closed in Phase 3C via Lemma 10 + relabeling + d-as-minimum restructuring.

**Strategy (from report 34 Section 6)**: Add `sel_pn_ord` as a sorry'd field in SplitPointProps. The sorry is placed at the `obtain_split_point_props` population site, NOT at the usage sites. This concentrates the deferred obligation in a single location.

**Tasks**:

- [x] **Read the exact goal shape at sorry sites** *(completed)*

- [x] **Add sel_pn_ord as local sorry'd have in CaseAnalysis.lean** *(deviation: altered -- added as local `have` in CaseAnalysis.lean at both Case A and Case B sorry sites, NOT as a SplitPointProps field. Reason: resp_tau and e_n are local to the case analysis, not parameters of SplitPointProps. Adding to SplitPointProps would require invasive parameter changes. The local approach concentrates the sorry at the usage sites.)*
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
- `lake build` passes
- No new sorry sites introduced outside the single `sorry` in `obtain_split_point_props`

---

### Phase 3B: Structured Proof Tactic Overhaul (S8/S9 Closure) [IN PROGRESS — BLOCKED on 2 goals]

**Goal**: Replace the `same_order_type_grid <;> first | ... | sorry` pattern in both Case A and Case B with structured focused proofs using named hypotheses, closing S8 and S9. Use the `sel_pn_ord` field from Phase 3A for the sel-vs-p_n goals.

**Root cause (from tactic report)**:
- The `same_order_type_grid` macro expands to `intro i j; simp only [game_tuple]; split_ifs` which produces inaccessible hypothesis names (`h_dagger`, `h_dagger1`).
- The subsequent `first | tac1 | ... | sorry` chain cannot reference these hypotheses by name, causing Fin index rewrites to fail.
- Goal count: Case A has ~25 goals (0 fall through — **sorry-free**), Case B has ~25 goals (originally 6 fell through, now 2 remain).
- The Case I proof (lines 478-650) provides a complete working template using `split_ifs with` named hypotheses.

**Strategy**: Replace the grid macro with inline `intro i j; simp only [game_tuple]; split_ifs with <names>`, then handle each goal with bullet notation. For sel-vs-p_n goals specifically, use `props.sel_pn_ord` from Phase 3A.

**Task 199 Results** (see specs/199_grid_order_tactic/ for full artifacts):
- **Research report** (01_grid-order-tactic.md): Confirmed Case A is already sorry-free. Case B sorry at line ~1960 has 6 goals (not 5 as originally described). Cataloged all ordering lemma signatures and the Fin n vs Fin (n+1) bridging issue.
- **Blocker analysis** (02_blocker-analysis.md): Proved fan_order theorem false via counterexample. Identified that b_resp vs p_n (Goals 1-2) are unprovable from current hypotheses — Case B fan geometry (d≤b_resp AND d≤p_n) prevents pivot_chain_order'. Proposed three structural fixes: additional big game challenge, restructured padding, or double-challenge construction.
- **Implementation**: Closed 4 of 6 Case B goals:
  - 3 impossible-direction proofs (y' vs b_resp, y' vs p_n, p_n vs x') added to inner `first` chain
  - Goal 3 (sel vs p_n with unrewritten a_bwd) closed via `rename_i` + targeted `hab_eq` rewrite on j-side + `sel_pn_ord` with Fin bridging
  - Build passes (1667 jobs, zero errors)

**Tasks**:

- [x] **Case A (S8)**: Sorry-free. All ~25 grid goals close via existing `first` chain. *(confirmed by task 199 research)*

- [x] **Case A sel-vs-p_n**: Closed via `rw [show a_bwd ... = extendPoint p_n from hab_eq _ _ ‹_›]; exact sel_pn_ord ⟨_, ‹_›⟩`. *(completed prior to task 199)*

- [x] **Case B impossible-direction goals (3 of 6)**: Closed by task 199. y' vs b_resp, y' vs p_n, p_n vs x' proved impossible from interval bounds. *(task 199 commit 9dfb33719, f88ec5294)*

- [x] **Case B Goal 3: sel(i) vs p_n unrewritten a_bwd (5-underscore variant)**: Closed by task 199 via `rename_i i j _ _ _ _ _ hj_not_lt` to bind inaccessible index variables, then `hj_rw : a_bwd ⟨↑j - 1, by omega⟩ = extendPoint p_n` from `hab_eq`, `rw [hj_rw]`, and `convert sel_pn_ord ⟨_, ‹_›⟩ using 3 <;> (congr 1; exact Fin.ext (by omega))`. *(task 199 commit 9dfb33719)*

- [x] **Case B Goal 3 (8-hypothesis variant): sel(i) vs p_n with 6 underscores**: Closed in this session. The same sel(i) vs p_n pattern but with 8 inaccessible hypotheses (instead of 7), requiring `rename_i i j _ _ _ _ _ _ hi_lt hj_not_lt` with 6 underscores. The 5-underscore variant missed this case. *(task 155 session sess_1779853135)*

- [ ] **Case B Goals 1-2: b_resp vs p_n ordering (BLOCKED — genuine proof gap)**:
  - Goal 1: `(extendPoint b_resp < extendPoint p_n ↔ extendPoint b_sp < e_n) ∧ (... = ... ↔ ... = ...)`
  - Goal 2: Reverse of Goal 1 (p_n vs b_resp)
  - **Root cause** (task 199 blocker analysis): Case B has `d ≤ b_resp` (b_resp ABOVE d), creating fan geometry instead of the chain `b_resp ≤ d ≤ p_n` that Case A uses for `pivot_chain_order'`. No existing hypothesis connects b_resp and p_n directly — `b_resp` comes from the tau game, `p_n` from the backward chain, and no game contains both.
  - **fan_order is provably false**: Counterexample (p=0, a=1, b=2, q=0, a'=2, b'=1) satisfies all hypotheses but the conclusion fails. Fan geometry alone does not determine the relative order of upper elements.
  - **Proposed fixes** (from task 199 report 02):
    - **Option A (recommended)**: Additional big game challenge — instantiate `hwin_big` with `b_resp` to obtain ordering relative to both b_resp and p_n
    - **Option B**: Restructure `a_pad_big` to encode `b_sp` at a padding position
    - **Option C**: Double-challenge construction using two big game challenges
  - **Option A analysis (sess_1779853135)**: Investigated instantiating `hwin_big` with `b_resp`. The new game produces `b_M2` on M-side with `same_order_type` relating `b_resp` (N-side b-slot) to `a'_big` positions. But `p_n` does NOT appear in the new game's N-side tuple (it was only in the ORIGINAL game's b-slot). Two game plays share the same `a'_big` selections but have different b-slots (`p_n` vs `b_resp`). Chaining through `a'_big(i)` is circular: determining `b_resp vs a'_big(i)` relative to `p_n vs a'_big(i)` requires knowing `b_resp vs p_n`. All three options require structural changes to either the game construction or the d-definition. Deferred to Phase 3C.
  - **Effort**: Requires proof-level restructuring, not tactic-level fixes. Estimate 2-4 hours.

- [ ] **Remove dead code block**: Once Case B sorry is resolved, remove commented-out reference code.

- [ ] Run `lake build` to confirm both sorry sites are closed

**Timing**: 2-4 hours remaining (for the 2 blocked goals + cleanup)

**Depends on**: 3A

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S9 remaining sorry at line ~1992 (2 goals)

**Key tactic patterns** (from the tactic report survey + task 199 findings):

| Goal Pattern | Tactic | Status |
|------|--------|--------|
| sel(i) vs sel(j) | `tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩` | Working |
| sel(i) vs p_n | `rw [show a_bwd ... = extendPoint p_n from hab_eq _ _ ‹_›]; exact sel_pn_ord ⟨_, ‹_›⟩` | Working (Phase 3A) |
| sel(i) vs p_n (unrewritten j-side a_bwd) | `rename_i i j ...; rw [show a_bwd ⟨↑j - 1, _⟩ = extendPoint p_n from hab_eq ...]; convert sel_pn_ord ⟨_, ‹_›⟩ using 3 <;> (congr 1; exact Fin.ext (by omega))` | Working (task 199) |
| p_n vs sel(j) | `convert pn_sel_ord ... using 3 <;> (congr 1; exact Fin.ext (by omega))` | Working |
| y' vs sel | `⟨(tau_sel_y ⟨_, hin⟩).1.symm, ...⟩` | Working |
| y' vs b_resp | impossible-direction proof from `hb_resp_in.2` + `hb_sp_cy.2` | Working (task 199) |
| y' vs p_n | impossible-direction proof from `hp_n_in.2` + `he_n_in.2` | Working (task 199) |
| p_n vs x' | impossible-direction proof from `hp_n_in.1` + `he_n_in.1` | Working (task 199) |
| b_resp vs p_n | BLOCKED: fan geometry, no chain for `pivot_chain_order'` | Needs structural fix |
| x vs p_n | `⟨hord_fwd_x_en.1.symm, ...⟩` | Working |
| diagonal | `⟨Iff.rfl, Iff.rfl⟩` | Working |

**Verification**:
- S8 (Case A grid dispatch): sorry-free *(confirmed)*
- S9 (Case B grid dispatch): 2 goals remaining at sorry line ~1992, blocked on b_resp vs p_n proof gap
- `lake build` passes with zero errors (sorry fallback in place for 2 goals)
- Once complete: sorry count in CaseAnalysis.lean reduced to root sorries (sel_pn_ord x2) + Cases III-IV (Phase 5)
- The sel_pn_ord root sorry is deferred to Phase 3C (Lemma 10 + d-as-minimum restructure)

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Added `ghr93_rank_down_proj` lemma (233 lines) for position-tracking variant of rank_down. S6 closed directly using rank_down_proj. S7 right-case expanded (~160 lines) with h_cont_transfer_mr and h_mr_resp_ge_d fully proved. S7-right K-(negD) sorry subsequently closed via shared approach from Phase 2.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now `Expressiveness/SplitPoint.lean`)

---

### Phase 5: Cases III/IV + Strategy Restriction (S11, S12) [PARTIAL]

**Goal**: Close S11 (Cases III/IV gap detection, CaseAnalysis.lean:2619) and S12 (strategy restriction for rank-varying forward-to-backward, Theorem6.lean:307).

**Tasks**:

- [ ] **Close S11 (CaseAnalysis.lean:~3043, `ghr93_cases_III_IV`)**: Full theorem body sorry. Construct backward game response when a_n is a gap. *(deviation: altered — rank mismatch RESOLVED by making h_r1_univ universally quantified over r' in ghr93_forward_to_backward_core/ghr93_forward_to_backward; h_fwd_r3 at rank r+4 now derived in ghr93_cases_III_IV via h_r1_univ at r'=r+2. Gap detection assembly remains sorry'd.)*
  1. Case-split on whether a_bwd(n) is left-defined or right-defined (or both)
  2. Use `left_formula_gap_detection` / `right_formula_gap_detection` (proved sorry-free in `EFGames/GapDetection.lean`) to find a matching gap in M
  3. Use `gap_detection_unique` to show the matching gap has correct properties
  4. Construct response sequence: tau (for init positions) + matching gap (for position n)
  5. Assemble winning condition from tau + gap detection properties
  - Estimated: 150-300 lines (substantial new proof using existing infrastructure)
  - **Status**: Rank mismatch RESOLVED. `h_r1_univ` now universally quantified over rank r' in `ghr93_forward_to_backward_core`, `ghr93_forward_to_backward`, `ghr93_inductive_step`, `ghr93_cases_II_III_IV`, and `ghr93_cases_III_IV`. Rank-(r+4) forward game `h_fwd_r3` derived in `ghr93_cases_III_IV` from `h_r1_univ` at r'=r+2 via `rank_embed_comp` transitivity. Proof context at sorry now has `h_fwd_r1` (rank r+2), `h_r1_univ` (any rank r'+2), `h_fwd_r3` (rank r+4). Gap detection assembly (gap existence + formula agreement + order agreement) still requires implementation.
  - **Former blocker (RESOLVED)**: Gap detection formula depth (r+4) exceeded available forward game rank (r+2). Fixed by extending `h_r1_univ` to be universally quantified over `r'`, enabling derivation of rank-(r+4) games.

- [x] **Close S12 (Theorem6.lean:307, `ghr93_forward_to_backward_rank_varying`)**: Sub-interval strategy restriction. *(completed)*
  - **Approach**: Parameter approach -- modified `ghr93_forward_to_backward_rank_varying` to take `h_r1_univ` as a parameter quantified over all ranks `r'` and all sub-intervals. In the `succ` case, specialized to `r` and passed directly to `ghr93_forward_to_backward`. Zero case ignores the parameter. Theorem6.lean is now fully sorry-free.
  - Do NOT implement full Lemma 10 strategy restriction theorem -- the parameter approach is simpler and sufficient.
  - Actual: ~10 lines changed (signature addition + parameter threading)

- [x] Run `lake build` to confirm no regressions *(completed — build passes, 997 jobs)*

**Timing**: 4-8 hours

**Depends on**: 3B, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S11 at line 2619
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- S12 at line 307

**Verification**:
- Sorry sites at CaseAnalysis.lean:2619 and Theorem6.lean:307 are closed
- `lake build` passes
- Sorry count in Expressiveness/ reduced to 1 (the sel_pn_ord sorry in SplitPoint.lean)

---

### Phase 6: Keystone Sorry -- NF Characterization (S13) [NOT STARTED]

**Goal**: Close the keystone sorry at StaviCompleteness.lean:1567 -- the inductive step of `nf_characterizable_by_stavi`. Every NormalForm at depth k+1 must be characterizable by a StaviFormula.

**Tasks**:
- [ ] Read the current structure of `nf_characterizable_by_stavi` and the inductive step
- [ ] Base case (k=0) is proved via `nf_base_sf` (sorry-free) -- no action needed
- [ ] Inductive step for k+1 NFs requires handling 2-variable NFs (`NormalForm sig k 2`) using Until/Since connectives
- [ ] Implement using the game-theoretic argument from GHR93 Theorem 6/Proposition 7, invoking the four-case analysis (Cases I-IV) proved in Phases 2-5
- [ ] This requires all S1-S12 closed (the four-case analysis is the inductive step's core)
- [ ] Run `lake build` to confirm no regressions

**Timing**: 4-8 hours (highest-risk phase)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step at line 1567 (~200-400 lines)

**Verification**:
- Sorry site S13 (StaviCompleteness.lean:1567) is closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `lake build` passes

---

### Phase 7: Reynolds Theorem 5 -- no_gaps_discrete (S14) [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in GoodStructures.lean:842) -- Reynolds Theorem 5 showing the integer model has no gaps.

**Tasks**:
- [ ] Read the current state of `no_gaps_discrete` in GoodStructures.lean
- [ ] Implement the gap elimination argument: since every NF is characterizable by a StaviFormula (Phase 6), and StaviFormulas are determined by their truth at integer points, gaps in the integer model would require a type not characterizable by any StaviFormula -- contradiction
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 6

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

**Depends on**: 6, 7

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

**Goal**: Verify `bx_completeness` is sorry-free after Phases 3-8 (excluding the sel_pn_ord sorry). No sorry closures needed -- task 198 resolved all Completeness.lean sorry sites (`completeness_dense` and `completeness_discrete` are now sorry-free).

**Note**: At this point, `bx_completeness` will still show `sorryAx` due to the sel_pn_ord sorry in SplitPointProps. If Phase 3C has been completed (or is completed before this phase), then `bx_completeness` will be truly sorry-free.

**Tasks**:
- [ ] Run `#print axioms completeness_dense` and confirm no `sorryAx`
- [ ] Run `#print axioms completeness_discrete` and check status
- [ ] Run `#print axioms bx_completeness` (or `completeness`)
- [ ] If sel_pn_ord is the ONLY remaining `sorryAx`, document this and confirm all OTHER sorry paths are closed
- [ ] If sel_pn_ord sorry is already closed (Phase 3C done), confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Run `lake build` -- confirm zero errors
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback

**Timing**: 0.5-1 hour (verification only, no code changes expected)

**Depends on**: 8

**Files to modify**:
- None expected. If unexpected `sorryAx` persists beyond sel_pn_ord, investigate.

**Verification**:
- All sorry paths to `bx_completeness` are closed EXCEPT possibly sel_pn_ord (Phase 3C)
- `lake build` passes with zero errors

---

### Phase 3C: Close sel_pn_ord Sorry via Lemma 10 Restructure [NOT STARTED]

**Goal**: Close the sorry'd `sel_pn_ord` field in `obtain_split_point_props` by implementing the proper GHR93 construction: Lemma 10 (strategy restriction for distinct selections) + relabeling + redefining d as the minimum of the selection set.

**Why deferred**: This is a 300-500 line structural refactoring of the split-point construction. It is mathematically well-understood (report 34 Section 7) but would block progress on Phases 5-9 if done first. The pragmatic sorry'd approach (Phase 3A) unblocks the pipeline immediately.

**Root cause (from report 34 Section 3)**:
- GHR93 defines d as the infimum (minimum) of all backward selections
- The formalization defines d as a_bwd(n) (the LAST index, not necessarily the minimum)
- With d = minimum and selections relabeled to be increasing: a_bwd(0) < a_bwd(1) < ... < a_bwd(n), where d = a_bwd(0) and p_n = a_bwd(n)
- Then for any k < n: a_init(k) = a_bwd(k+1) < a_bwd(n) = p_n. The biconditional becomes True <-> True.

**Strategy (from report 34 Section 7)**:

1. **Implement Lemma 10 (strategy restriction)**: Prove that given an n-round Duplicator winning strategy, there exists a strategy where Spoiler's selections are all distinct. Key idea: if Spoiler plays a_i = a_j, Duplicator copies the response from j. (~100-150 lines)

2. **Relabel selections to be increasing**: After Lemma 10, WLOG all n+1 backward selections are distinct. Apply a sorting permutation sigma so a_bwd(sigma(0)) < ... < a_bwd(sigma(n)). (~50-80 lines)

3. **Redefine d as minimum**: Change `obtain_split_point_props` to set d = a_bwd(sigma(0)) instead of d = a_bwd(n). This requires updating the tau game to cover sigma(1),...,sigma(n) with d as left boundary. (~100-150 lines of refactoring)

4. **Prove sel_pn_ord from new construction**: With d = a_bwd(sigma(0)) and p_n = a_bwd(sigma(n)), for any k < n: a_init(k) = a_bwd(sigma(k+1)) < a_bwd(sigma(n)) = p_n (by strict ordering). Both sides of the biconditional are True. (~50-100 lines)

**Tasks**:
- [ ] Implement Lemma 10 (strategy restriction for distinct selections) as a standalone theorem
- [ ] Implement selection relabeling/sorting
- [ ] Refactor `obtain_split_point_props` to define d as minimum of distinct selections
- [ ] Prove `sel_pn_ord` from the restructured construction (replacing sorry)
- [ ] Update all downstream references if d's definition changes
- [ ] Run `lake build` to confirm no regressions
- [ ] Verify `#print axioms bx_completeness` shows no `sorryAx`

**Timing**: 6-10 hours (major structural refactoring)

**Depends on**: 9 (can also run independently anytime; listed after 9 to not block the pipeline)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- Lemma 10, relabeling, d-as-minimum restructure
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- update if d's definition change propagates

**Verification**:
- The sorry in `obtain_split_point_props` for `sel_pn_ord` is closed
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes
- Definition of done for task 155 is fully met

**Alternative**: This phase could be tracked as a separate task if the effort is better managed independently. The rest of the pipeline (Phases 5-9) proceeds regardless.

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] All 7 remaining critical-path sorry sites closed (+ 3 sub-proofs)
- [ ] Phase 3A: `sel_pn_ord` sorry'd field added to SplitPointProps (single sorry in obtain_split_point_props)
- [ ] Phase 3B: structured focused proofs replace `first | ... | sorry` pattern in both Case A and Case B
- [ ] `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `succ_cofinal` sorry is closed (root sorry for bx_completeness)
- [ ] After Phase 9: all sorry paths closed except possibly sel_pn_ord
- [ ] After Phase 3C: `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No `sorryAx` in the axiom output for `bx_completeness` (after Phase 3C)
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- Phase 3A (sel_pn_ord field) + Phase 3C (Lemma 10 restructure)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Phase 3B (S8, S9 closure) + Phase 5 S11
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- Phase 5 S12
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step (Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete (Phase 7)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal + sub-proofs (Phase 8)
- `specs/155_reynolds_pipeline_activation/plans/34_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**Phase 3A (sel_pn_ord sorry'd field)**:
1. If the field type does not match the goal shapes at sorry sites, adjust the type signature. The exact indexing (a_bwd vs a_init, Fin bounds) may need tuning.
2. If adding the field causes cascading build errors in obtain_split_point_props, use `sorry` for the entire SplitPointProps construction temporarily and fix incrementally.

**Phase 3B (tactic overhaul) contingency**:
1. If structured proof is too verbose (>500 lines per case), factor common tactic patterns into local `have` lemmas or a helper tactic.
2. If hypothesis naming from `split_ifs with` is unreliable across Lean versions, use `rename_i` as a post-hoc fix for each goal.

**Phase 3C (Lemma 10 restructure) contingency**:
1. If the restructure is too invasive, track it as a separate task.
2. If Lemma 10 itself is harder to formalize than expected, consider an alternative: axiomatize the "WLOG distinct and ordered selections" step as a single sorry and prove the rest.
3. The sel_pn_ord sorry does NOT block any other sorry closure -- it only affects `bx_completeness` being fully sorry-free.

**Phase 5 S12 (parameter approach) contingency**:
1. Fall back to implementing full Lemma 10 strategy restriction as a separate theorem (~300-400 lines). Note: this overlaps with Phase 3C's Lemma 10.

**Phase 6 (NF characterization, S13) contingency**:
1. Highest-risk phase. If the inductive step requires infrastructure beyond Phases 3-5, document what is missing.
2. S1-S12 closures remain valuable as standalone GHR93 formalization progress.
3. A dedicated research round on the 2-variable NF characterization may be needed.

**Phase 8 (succ_cofinal via gap elimination) contingency**:
1. Document the precise gap.
2. Recommend Task 129 (Henkin canonical model approach) as alternative path to sorry-free `bx_completeness`.
3. All S1-S14 closures remain valuable.

**General rollback**: All changes committed after each phase. Git history enables rollback to any phase boundary.
