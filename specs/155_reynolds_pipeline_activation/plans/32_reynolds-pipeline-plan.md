# Implementation Plan: Reynolds Pipeline Activation (v32 revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phase 3 partial (Fin type mismatch in grid dispatch, 3+N goals remaining)
- **Effort**: 12-24 hours remaining (Phases 1-4 complete, Phase 3 blocked, Phase 9 reduced to verification)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED), Task 168 (COMPLETED), Task 174 (COMPLETED), Task 198 (COMPLETED)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md, reports/32_post-dependency-assessment.md
- **Artifacts**: plans/32_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline. Phases 1-4 are complete, closing 9 sorry sites and establishing the key infrastructure: K-(negD) bridge (Phase 2), d-compatible forward game with `h_d_compat_left` (Phase 3 breakthrough), and position-tracking `ghr93_rank_down_proj` (Phase 4).

Seven live sorry sites remain on the critical path across 5 files: CaseAnalysis.lean (3 — lines 1569, 1657, 2628), Theorem6.lean (1), StaviCompleteness.lean (1), GoodStructures.lean (1), ChronicleToCountermodel.lean (1+3 sub-proofs). Phase 3 has 2 live sorry sites (S8 at line 1569, S9 at line 1657) blocked by the sel-vs-p_n ordering gap — the ordering `(a_init k < extendPoint p_n ↔ resp_tau k < e_n)` cannot be derived from available hypotheses. S10 (line 1710) is confirmed dead code inside a block comment. Phase 9 (Completeness.lean wiring) is resolved by task 198 and reduced to a verification step.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Eleven research reports and a blocker study were integrated into this plan:

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
| **32_post-dependency-assessment** | **File split complete (task 174), Phase 9 sorries resolved (task 198), Fin blocker unchanged** | **This revision**: Updated file paths, Phase 9 reduced to verification, effort recalibrated downward |

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

**v32 updated (2026-05-26)**: Post-implementation update after Phase 3 implementation attempt. Changes:
- Phase 3 marked [BLOCKED]: sel-vs-p_n ordering gap discovered — 5 approaches exhausted
- S10 (CaseAnalysis.lean:1710) confirmed dead code inside block comment — removed from critical path
- Live sorry count corrected from 8 to 7 critical-path sites (+ 3 sub-proofs in Phase 8)
- Added sel-vs-p_n ordering gap to Superseded Approaches (#9)
- Updated Phase 3 subtask checklist with verified status of all items

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
- Restructuring e_n construction to U(B,A) transfer -- d-compat approach is the accepted workaround

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
| 9 | **Deriving sel-vs-p_n ordering from existing games** | Phase 3 impl v2 (2026-05-26) | 5 approaches tried: (a) pivot_chain_order through d/c — fork geometry, not chain; (b) extract from hord_big — gives a'_big positions, not a_init; (c) instantiate tau with e_n_pt — gives b_en ≠ p_n; (d) prove b_en = p_n from ordering equivalences — impossible when both strictly between d and y'; (e) fork ordering from common bounds — mathematically impossible on general linear orders (counterexample: d=0, b_en=1, p_n=2, y'=3). The ordering `(a_init k < extendPoint p_n ↔ resp_tau k < e_n)` requires new infrastructure, not extraction from existing games. |

**Key settled questions**:
- Infimum redefinition IS necessary (reports 29, 35). Do not revisit.
- Track A (OrderIso bypass) is NOT FEASIBLE. Do not revisit.
- Approach A (Fintype enumeration) is BLOCKED by infinite atoms. Do not revisit.
- D-compatible forward game is the correct approach for cross-boundary orderings. Do not regress to h_fwd_n1 or h_fwd_n1_d.
- Sel-vs-p_n ordering CANNOT be derived from existing games. Requires new infrastructure (sel_pn_ord field, modified game construction, or proof restructuring). Do not re-attempt the 5 exhausted approaches.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3 Case A goals blocked by `extendPoint` wrapping | L | M | Check exact goal types; use `convert` or explicit `extendPoint` coercion |
| Phase 3 Case B sigma extraction harder than expected | M | L | Pattern exists in Case A (CaseAnalysis.lean ~1418); copy and adapt |
| S11 gap detection assembly has unexpected mathematical gap | H | M | left/right_formula_gap_detection proved sorry-free; risk is in assembly only |
| S12 parameter approach requires deep IH structure changes | M | M | IH already universally quantifies over intervals; should be straightforward |
| S13 inductive step requires infrastructure beyond Phases 3-5 | H | H | Defer to Phase 6; all prior phases provide infrastructure. If blocked, document what remains. |
| Same diagnosis rediscovered without follow-through | M | M | Superseded Approaches section prevents backtracking; each phase has concrete deliverables |
| Build regression after wiring changes | M | L | Run `lake build` after every phase; commit working states |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- (COMPLETED) |
| 2 | 3 | 2 (COMPLETED; residual sorry closure in progress) |
| 3 | 5 | 3, 4 |
| 4 | 6 | 5 |
| 5 | 7 | 6 |
| 6 | 8 | 6, 7 |
| 7 | 9 | 8 |

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

### Phase 3: Case II Cross-Boundary Ordering (S8/S9/S10) [BLOCKED]
- **Started**: 2026-05-24T22:00:00Z
- **D-compat breakthrough**: 2026-05-25T04:30:00Z
- **Paused**: 2026-05-25 (for file splitting via tasks 168, 174)
- **Resumed**: 2026-05-26 (file splitting complete)
- **Major progress**: 2026-05-26 (Case B sigma instantiation, degenerate case fix, most grid goals closed)

**Status**: Most grid goals closed in both Case A and Case B. 3 goals remain in Case A and a similar count in Case B, all blocked by a Fin (n+1) vs Fin n type mismatch in the `same_order_type_grid` dispatch. The sel-vs-p_n ordering IS mathematically derivable (proved at lines 1512-1516 via `pivot_chain_order'`), but the grid dispatch generates goals with `a_bwd ⟨k, proof_lt_n_plus_1⟩` (Fin (n+1)) while the proof lemmas produce results about `a_init ⟨k, proof_lt_n⟩` (Fin n). Multiple tactic approaches have been tried (`change`, `convert ... using N`, `rw [hab_eq]`, pre-derived helpers with `exact`); none bridge this Fin size gap within the `first | ...` dispatch context.

**Approaches tried for Fin mismatch**:
1. `change` tactic — fails because `a_bwd` (Fin (n+1)) doesn't match `a_init` (Fin n)
2. `convert ... using 3 <;> (congr 1; exact Fin.ext (by omega))` — closes some but not all goals
3. `rw [hab_eq _ (by omega) (by omega)]` — rewrites wrong occurrence or doesn't fire
4. Pre-derived helpers with raw `(k : ℕ) (hk : k < n)` parameters — `exact` still can't unify
5. `rw [show (⟨k, _⟩ : Fin (n+1)) = ⟨k, by omega⟩ from Fin.ext rfl, hab_eq]` — can't reference inaccessible `i✝`/`j✝`

**Recommended resolution**: Refactor the `same_order_type_grid` macro itself to bind `i j` explicitly (making them accessible by name), or replace the macro entirely with an explicit `intro i j; simp only [game_tuple]; split_ifs` that gives named hypotheses.

**Goal**: Close the remaining sorry sites in `ghr93_case_II`.

**What Was Accomplished**:
- [x] Added `h_d_compat_left` field to `SplitPointProps` (SplitPoint.lean ~2457)
- [x] Populated field in `obtain_split_point_props` from existing `d_consistency_left`
- [x] Restructured `ghr93_case_II` to use d-compat game
- [x] Derived `hord_cd_en_pn`, `hc_le_en`, `hd_le_pn`
- [x] Added cross-boundary pivot branches using `pivot_chain_order'`/`pivot_chain_order_rev'`
- [x] Fixed hord_cd_en_pn orientation bug
- [x] Closed most Case A grid goals (only 3 of ~20+ remain as sorry fallback)
- [x] **Case B sigma instantiation**: Instantiated `props.sigma` with dummy selections to derive `sig_x_d : (x' < d ↔ x < c)` (was the previous blocker)
- [x] **Case B degenerate case**: Fixed `exact ⟨Iff.rfl, Iff.rfl⟩` → impossibility proof for `(x' < x' ↔ x < x)` after subst
- [x] **Case B full grid dispatch**: Added comprehensive pivot chain dispatch covering ~30 ordering alternatives
- [x] S10 confirmed dead code (inside block comment)

**Remaining Tasks**:

- [ ] **S8 Case A sorry (CaseAnalysis.lean:1594)**: 3 goals remain in `first | ... | sorry` fallback:
  - Goal 1: `(y' < a_bwd ⟨↑j✝-1,⋯⟩ ↔ y < resp_tau ⟨↑j✝-1,⋯⟩)` — y vs sel, Fin mismatch
  - Goal 2: `(a_bwd ⟨↑i✝-1,⋯⟩ < a_bwd ⟨↑j✝-1,⋯⟩ ↔ resp_tau ⟨↑i✝-1,⋯⟩ < e_n)` — sel vs p_n, Fin mismatch
  - Goal 3: `(extendPoint p_n < a_bwd ⟨↑j✝-1,⋯⟩ ↔ e_n < resp_tau ⟨↑j✝-1,⋯⟩)` — p_n vs sel, Fin mismatch
  - All are mathematically provable (lines 1512-1516 prove the ordering when Fin types match). Blocked by inaccessible Fin variables from `same_order_type_grid` macro.

- [ ] **S9 Case B sorry (CaseAnalysis.lean:1866)**: Similar Fin-mismatch goals remain after comprehensive grid dispatch. Sigma instantiation and most orderings are in place.

- [x] **S10 (CaseAnalysis.lean:~1917)**: CONFIRMED dead code inside `/- ... -/` block comment. Not a live sorry site.

- [x] Build verified: `lake build` passes cleanly (1667 jobs, 0 errors) with sorry fallbacks

**Timing**: 2-4 hours (requires new infrastructure — sel_pn_ord field or modified game construction)

**Depends on**: 2 (COMPLETED) + new infrastructure for sel_pn_ord

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S8 at line 1569, S9 at line 1657
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- possibly add `sel_pn_ord` field to `SplitPointProps` and populate in `obtain_split_point_props`

**Key positions in CaseAnalysis.lean**:
- S8 Case A sorry: line 1569 (2 blocked goals)
- S9 Case B sorry: line 1657 (full sorry, blocked)
- S10 dead code: line 1710 (inside block comment, not live)
- S11 (Phase 5): line 2628

**Verification**:
- Sorry sites S8 (line 1569) and S9 (line 1657) are closed
- `lake build` passes
- Sorry count in CaseAnalysis.lean reduced from 3 live to 1 (S11 at line 2628 remains for Phase 5)

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

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S11 at line 2619
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- S12 at line 307

**Verification**:
- Sorry sites at CaseAnalysis.lean:2619 and Theorem6.lean:307 are closed
- `lake build` passes
- Sorry count in Expressiveness/ reduced to 0

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

**Goal**: Verify `bx_completeness` is sorry-free after Phases 3-8. No sorry closures needed -- task 198 resolved all Completeness.lean sorry sites (`completeness_dense` and `completeness_discrete` are now sorry-free).

**Tasks**:
- [ ] Run `#print axioms completeness_dense` and confirm no `sorryAx`
- [ ] Run `#print axioms completeness_discrete` and confirm no `sorryAx`
- [ ] Run `#print axioms bx_completeness` (or `completeness`)
- [ ] Confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Verify no `sorryAx` appears anywhere in the output
- [ ] Run `lake build` -- confirm zero errors
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback

**Timing**: 0.5-1 hour (verification only, no code changes expected)

**Depends on**: 8

**Files to modify**:
- None expected. If `sorryAx` persists, investigate and close any remaining sorry sites.
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- only if unexpected sorries found

**Verification**:
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes with zero errors
- Definition of done is met

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] All 7 remaining critical-path sorry sites closed (+ 3 sub-proofs)
- [ ] `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `succ_cofinal` sorry is closed (root sorry for bx_completeness)
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No `sorryAx` in the axiom output for `bx_completeness`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Phase 3 residual closures (S8, S9, S10) + Phase 5 S11
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- Phase 5 S12
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step (Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete (Phase 7)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal + sub-proofs (Phase 8)
- `specs/155_reynolds_pipeline_activation/plans/32_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**Phase 3 is currently blocked** (sel-vs-p_n ordering gap). Resolution options:
1. **Add `sel_pn_ord` field to `SplitPointProps`**: Provide `∀ k : Fin n, (a_init k < extendPoint p_n ↔ resp_tau k < e_n) ∧ (a_init k = extendPoint p_n ↔ resp_tau k = e_n)` directly. Populate during `obtain_split_point_props` using a modified game construction that includes both tau positions and p_n/e_n.
2. **Modify `hwin_tau` to return (n+1)-round game**: Include p_n/e_n as the (n+1)-th position in the tau game, providing all pairwise orderings including sel-vs-p_n.
3. **Restructure proof to use single comprehensive game**: Instead of assembling from separate sub-games (tau, sigma, big), construct one game that covers all positions simultaneously.
4. **Factor out `same_order_type` assembly into helper**: Takes component game data and produces composed winning condition (addresses the Fin variable accessibility issue independently of sel_pn_ord).

**If Phase 5 S12 (parameter approach) is blocked**:
1. Fall back to implementing full Lemma 10 strategy restriction as a separate theorem
2. This is more work (~300-400 lines) but provides reusable infrastructure

**If Phase 6 (NF characterization, S13) is blocked**:
1. Highest-risk phase. If the inductive step requires infrastructure beyond Phases 3-5, document what is missing
2. S1-S12 closures remain valuable as standalone GHR93 formalization progress
3. A dedicated research round on the 2-variable NF characterization may be needed

**If Phase 8 (succ_cofinal via gap elimination) is blocked**:
1. Document the precise gap
2. Recommend Task 129 (Henkin canonical model approach) as alternative path to sorry-free `bx_completeness`
3. All S1-S14 closures remain valuable

**General rollback**: All changes committed after each phase. Git history enables rollback to any phase boundary.
