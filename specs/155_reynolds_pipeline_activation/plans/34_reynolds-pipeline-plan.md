# Implementation Plan: Reynolds Pipeline Activation (v34 revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phase 3A superseded (unified game infeasible), replaced with sel_pn_ord sorry'd field approach
- **Effort**: 12-22 hours remaining (Phases 1-4 complete, Phase 3A-new ~1h, Phase 3B ~2-4h, Phases 5-9 pending)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED), Task 168 (COMPLETED), Task 174 (COMPLETED), Task 198 (COMPLETED)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md, reports/32_post-dependency-assessment.md, reports/33_lit-sel-pn-ordering.md, reports/33_infra-sel-pn-fix.md, reports/33_tactic-sel-pn-grid.md, reports/34_lemma10-strategy-restrict.md
- **Artifacts**: plans/34_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline. Phases 1-4 are complete, closing 9 sorry sites and establishing key infrastructure: K-(negD) bridge (Phase 2), d-compatible forward game with `h_d_compat_left` (Phase 3 breakthrough), and position-tracking `ghr93_rank_down_proj` (Phase 4).

Phase 3A (unified game restructure) has been **superseded** after exhaustive analysis proved ALL game-based approaches infeasible for the sel-vs-p_n ordering. Report 34 (Lemma 10 feasibility) confirmed that the fundamental gap is structural: any game play produces NEW N-side responses that are NOT `a_init(k)`, and the order-isomorphism between old and new responses does NOT extend to ordering relative to `p_n`. This supersedes 6 specific failed approaches documented in the Phase 3A BLOCKER section of the v33 plan.

The revised approach uses the **pragmatic fix from report 34**: add `sel_pn_ord` as a sorry'd field in `SplitPointProps` (~30 lines), propagate it to the sorry sites (~50 lines), then close the 2 sorry sites via structured focused proofs in Phase 3B. The sorry in `obtain_split_point_props` becomes a deferred obligation tracked in Phase 3C, requiring Lemma 10 + relabeling + d-as-minimum restructuring (~300-500 lines) to close properly.

Seven live sorry sites remain on the critical path across 5 files: CaseAnalysis.lean (3), Theorem6.lean (1), StaviCompleteness.lean (1), GoodStructures.lean (1), ChronicleToCountermodel.lean (1+3 sub-proofs). Phase 9 (Completeness.lean wiring) is resolved by task 198 and reduced to a verification step.

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

**Key settled questions**:
- Infimum redefinition IS necessary (reports 29, 35). Do not revisit.
- Track A (OrderIso bypass) is NOT FEASIBLE. Do not revisit.
- Approach A (Fintype enumeration) is BLOCKED by infinite atoms. Do not revisit.
- D-compatible forward game is the correct approach for cross-boundary orderings. Do not regress to h_fwd_n1 or h_fwd_n1_d.
- Sel-vs-p_n ordering CANNOT be derived from ANY combination of separate game plays. Every game produces new responses; order-isomorphism does not extend past shared bounds. This is settled by report 34's exhaustive analysis.
- The `same_order_type_grid <;> first | ... | sorry` pattern is structurally inadequate for goals requiring named hypotheses. Structured focused proofs with bullet notation are the correct replacement.
- The sel_pn_ord property IS mathematically true (follows from GHR93 once d is defined as minimum of selections). The pragmatic sorry'd field approach is justified.

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

### Phase 3B: Structured Proof Tactic Overhaul (S8/S9 Closure) [IN PROGRESS]

**Goal**: Replace the `same_order_type_grid <;> first | ... | sorry` pattern in both Case A and Case B with structured focused proofs using named hypotheses, closing S8 and S9. Use the `sel_pn_ord` field from Phase 3A for the sel-vs-p_n goals.

**Root cause (from tactic report)**:
- The `same_order_type_grid` macro expands to `intro i j; simp only [game_tuple]; split_ifs` which produces inaccessible hypothesis names (`h_dagger`, `h_dagger1`).
- The subsequent `first | tac1 | ... | sorry` chain cannot reference these hypotheses by name, causing Fin index rewrites to fail.
- Goal count: Case A has ~25 goals (3 fall through), Case B has ~25 goals (~8 fall through).
- The Case I proof (lines 478-650) provides a complete working template using `split_ifs with` named hypotheses.

**Strategy**: Replace the grid macro with inline `intro i j; simp only [game_tuple]; split_ifs with <names>`, then handle each goal with bullet notation. For sel-vs-p_n goals specifically, use `props.sel_pn_ord` from Phase 3A.

**Tasks**:

- [ ] **Case A (S8 at line ~1594)**: Replace the `same_order_type_grid <;> first | ... | sorry` block with structured proof:
  ```lean
  -- Replace:
  --   same_order_type_grid <;>
  --     first | order_refl | ... | sorry
  -- With:
  intro i j; simp only [game_tuple]; split_ifs with hi hj
  -- For each goal, use bullet notation:
  -- x vs x: . exact ⟨Iff.rfl, Iff.rfl⟩
  -- x vs sel(k): . exact ⟨hord_sig_x_sel k, ...⟩  (or tau equivalent)
  -- x vs p_n: . exact ⟨hord_fwd_x_en.1.symm, hord_fwd_x_en.2.symm⟩
  -- sel(i) vs sel(j): . exact tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩
  -- sel(i) vs p_n (THE KEY CASE):
  --   . -- Use sel_pn_ord from Phase 3A
  --     exact props.sel_pn_ord ⟨i.val - 1, hin⟩
  --     -- (with appropriate Fin index conversion)
  -- y' vs sel: . exact ⟨(tau_sel_y ⟨_, hin⟩).1.symm, ...⟩
  ```
  Estimated: ~200 lines replacing ~170 lines of `first | ... | sorry` chain.

- [ ] **Case B (S9 at line ~1866)**: Same structured proof approach. The dead-code block (lines 1924-2021) provides a near-complete template. Adapt to current context:
  - Replace `hord_fwd` references with extracted `fwd_*` hypotheses
  - Replace `hd_le_an` with `h_no_split` or equivalent
  - Add sel-vs-p_n cases using `props.sel_pn_ord` from Phase 3A
  Estimated: ~200 lines.

- [ ] **Remove dead code block**: Once Case B structured proof is complete, remove the commented-out reference code at lines ~1924-2021. It has served its purpose as a template.

- [ ] **Verify maxErrors is no longer an issue**: The structured proof eliminates the `first | ...` chain, so the error multiplication problem vanishes. Remove any `set_option maxErrors` workarounds if present.

- [ ] Run `lake build` to confirm both sorry sites are closed

**Timing**: 2-4 hours

**Depends on**: 3A

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S8 at line ~1594, S9 at line ~1866

**Key tactic patterns** (from the tactic report survey):

| Goal Pattern | Tactic | Source |
|------|--------|--------|
| sel(i) vs sel(j) | `tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩` | tau game |
| sel(i) vs p_n | `props.sel_pn_ord ⟨i-1, hin⟩` | SplitPointProps field (Phase 3A) |
| p_n vs sel(j) | `(props.sel_pn_ord ⟨j-1, hjn⟩).swap` or symmetric | SplitPointProps field (Phase 3A) |
| y' vs sel | `⟨(tau_sel_y ⟨_, hin⟩).1.symm, ...⟩` | tau game |
| b_resp vs p_n | `pivot_chain_order'` through d/c | interval bounds |
| x vs p_n | `⟨hord_fwd_x_en.1.symm, ...⟩` | forward game |
| diagonal | `⟨Iff.rfl, Iff.rfl⟩` | reflexivity |

**Critical Fin rewrite pattern** (for p_n cases where j-1 = n):
```lean
rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
  by congr 1; exact Fin.ext (by omega), hab_n]
```
This converts `a_bwd ⟨j-1, bound_proof⟩` to `extendPoint p_n` when `not (j-1 < n)` implies `j-1 = n`.

**Verification**:
- Sorry sites S8 (line ~1594) and S9 (line ~1866) are closed
- `lake build` passes
- Sorry count in CaseAnalysis.lean reduced from 3 live to 1 (S11 at line ~2619 remains for Phase 5)
- The ONLY remaining sorry from Phases 3A+3B is in `obtain_split_point_props` (the sel_pn_ord field)

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Added `ghr93_rank_down_proj` lemma (233 lines) for position-tracking variant of rank_down. S6 closed directly using rank_down_proj. S7 right-case expanded (~160 lines) with h_cont_transfer_mr and h_mr_resp_ge_d fully proved. S7-right K-(negD) sorry subsequently closed via shared approach from Phase 2.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now `Expressiveness/SplitPoint.lean`)

---

### Phase 5: Cases III/IV + Strategy Restriction (S11, S12) [NOT STARTED]

**Goal**: Close S11 (Cases III/IV gap detection, CaseAnalysis.lean:2619) and S12 (strategy restriction for rank-varying forward-to-backward, Theorem6.lean:307).

**Tasks**:

- [ ] **Close S11 (CaseAnalysis.lean:2619, `ghr93_cases_III_IV`)**: Full theorem body sorry. Construct backward game response when a_n is a gap.
  1. Case-split on whether a_bwd(n) is left-defined or right-defined (or both)
  2. Use `left_formula_gap_detection` / `right_formula_gap_detection` (proved sorry-free in `EFGames/GapDetection.lean`) to find a matching gap in M
  3. Use `gap_detection_unique` to show the matching gap has correct properties
  4. Construct response sequence: tau (for init positions) + matching gap (for position n)
  5. Assemble winning condition from tau + gap detection properties
  - Estimated: 150-300 lines (substantial new proof using existing infrastructure)

- [ ] **Close S12 (Theorem6.lean:307, `ghr93_forward_to_backward_rank_varying`)**: Sub-interval strategy restriction.
  - **Approach**: Parameter approach -- modify `ghr93_forward_to_backward_rank_varying` to take the IH game (`h_r1_univ`) as a parameter from the main induction, rather than deriving it internally. The IH already provides games on all sub-intervals via universal quantification.
  - Do NOT implement full Lemma 10 strategy restriction theorem -- the parameter approach is simpler and sufficient.
  - Estimated: 100-200 lines (signature change + threading IH through)

- [ ] Run `lake build` to confirm no regressions

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
