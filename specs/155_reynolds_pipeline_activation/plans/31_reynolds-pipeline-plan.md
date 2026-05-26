# Implementation Plan: Reynolds Pipeline Activation (v31 revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] — paused for file splitting (tasks 168, 174)
- **Effort**: 15-30 hours remaining (Phases 1-4 complete, Phase 3 partially closed)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md
- **Artifacts**: plans/31_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline. Phases 1-4 are complete, closing 9 sorry sites and establishing the key infrastructure: K-(negD) bridge (Phase 2), d-compatible forward game with `h_d_compat_left` (Phase 3 breakthrough), and position-tracking `ghr93_rank_down_proj` (Phase 4).

Twelve sorry sites remain on the critical path across 5 files: ExpressivenessGeneral (5), EFGames (1), IntegerModel (1), ChronicleToCountermodel (1), Completeness (4). Phase 3 has 3 residual sorry sites (lines 8521, 8609, 8662) that are mechanical Lean engineering -- all mathematical data is in scope via `hord_cd_en_pn`, `hc_le_en`, `hd_le_pn`.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Ten research reports and a blocker study were integrated into this plan:

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
| 30_blocker-study-prior-art | 12 remaining sorries; d-compat breakthrough; parameter approach for S12 | **This revision**: Phase 3 residual scoping, Phase 5 approach change, effort recalibration |

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

**v31 paused (2026-05-25)**: Phase 3 partially closed (3 of 6 Case A goals closed, Case B not attempted). Task paused for file splitting: ExpressivenessGeneral.lean is ~10k lines, causing 3-5 minute compile cycles that bottleneck implementation. Tasks 168 (parameterize DerivationTree) → 174 (split oversized files, including ExpressivenessGeneral.lean) will run before resuming Phases 3-remainder through 9. See handoffs/phase-3-handoff-impl.md for exact blocker details.

## Goals & Non-Goals

**Goals**:
- Close all 12 remaining critical-path sorry sites
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

**Key settled questions**:
- Infimum redefinition IS necessary (reports 29, 35). Do not revisit.
- Track A (OrderIso bypass) is NOT FEASIBLE. Do not revisit.
- Approach A (Fintype enumeration) is BLOCKED by infinite atoms. Do not revisit.
- D-compatible forward game is the correct approach for cross-boundary orderings. Do not regress to h_fwd_n1 or h_fwd_n1_d.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3 Case A goals 1 and 3 have `extendPoint` wrapping issues | L | M | Check exact goal types; use `convert` or explicit `extendPoint` coercion |
| Phase 3 Case B sigma extraction harder than expected | M | L | Pattern exists in Case A (lines 8342-8344); copy and adapt |
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

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

---

### Phase 2: Pigeonhole + K-(negD) Bridge (S1/S2 Claim 1 Resolution) [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Closed S1 and S2 (the Claim 1 sorry cluster) using K-(negD) bridge. S1 (boundary case): K-(negD_M) pigeonhole argument (+200 lines). S2 (gap case): gap_point_agreement + K-(negD_M) (+131 lines). Also closed S1 sub-sorry (gap density) and S2 sub-sorry (gap-gap case) via complement_no_min witnesses. Key finding: K-(negD) bridge is necessary scaffolding (unavoidable before S13, replaceable after). Also closed S4 (multi-round K-(negD)) and S7-right (right-direction K-(negD)) in subsequent sessions.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

---

### Phase 3: Case II Cross-Boundary Ordering (S8/S9/S10) [PARTIAL]
- **Started**: 2026-05-24T22:00:00Z
- **D-compat breakthrough**: 2026-05-25T04:30:00Z
- **Paused**: 2026-05-25 (for file splitting via tasks 168, 174)

**Goal**: Close the remaining sorry sites in `ghr93_case_II`. All mathematical data is in scope; remaining work is Lean pattern matching and sigma extraction.

**What Was Accomplished**:
- [x] Added `h_d_compat_left` field to `SplitPointProps` (line 2457) exposing d-compatible (1+3n+1)-round forward strategy
- [x] Populated field in `obtain_split_point_props` (line 3399) from existing `d_consistency_left`
- [x] Restructured `ghr93_case_II` (lines 8226-8318) to use d-compat game
- [x] Derived `hord_cd_en_pn : (c < e_n <-> d < p_n)` — the cross-boundary ordering (line 8265)
- [x] Derived `hc_le_en : c <= e_n` and `hd_le_pn : d <= p_n` (line 8335)
- [x] Added cross-boundary pivot branches using `pivot_chain_order'`/`pivot_chain_order_rev'`
- [x] Fixed hord_cd_en_pn orientation bug: correct usage needs `⟨hord_cd_en_pn.1.symm, hord_cd_en_pn.2.symm⟩` (iff direction was reversed)
- [x] Closed 3 of 6 Case A fallthrough goals: b_resp-vs-x (impossible pair), b_resp-vs-p_n (cross-boundary pivot), y-vs-sel-reverse (bound+equality), p_n-vs-b_resp (reverse pivot)

**Remaining Tasks (to resume after tasks 168 → 174)**:

- [ ] **Case A sorry (line ~8556)**: 3 goals remain, ALL blocked by inaccessible Fin variables (`i✝`, `j✝`) introduced by `same_order_type_grid` macro:
  - Goal A `(y' < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ y < resp_tau ⟨↑j✝ - 1, ⋯⟩)` — y vs sel(k<n)
  - Goal B `(a_bwd ⟨↑i✝ - 1, ⋯⟩ < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ resp_tau ⟨↑i✝ - 1, ⋯⟩ < e_n)` — sel vs p_n (j-1=n)
  - Goal C `(extendPoint p_n < a_bwd ⟨↑j✝ - 1, ⋯⟩ ↔ e_n < resp_tau ⟨↑j✝ - 1, ⋯⟩)` — p_n vs sel(k<n)
  - **Root cause**: `same_order_type_grid` macro creates inaccessible Fin variables that can't be referenced inside `first | ...` branches. `rw`/`convert` can't target the correct `a_bwd` term.
  - **Recommended fix**: Refactor dispatch to use explicit `intro i j` before `same_order_type_grid`, or add helper lemma `a_bwd_p_n_eq : ∀ i, ¬(↑i - 1 < n) → a_bwd ⟨↑i - 1, _⟩ = extendPoint p_n` and use `simp only [a_bwd_p_n_eq]`.
  - **Approaches tried and failed**: `rename_i`, `rw [hab_eq _ (by omega)]` (rewrites wrong term), `simp only [hab_rewr]` (no progress), `convert ... using 2` (omega can't infer Fin value from inaccessible vars).
  - See handoffs/phase-3-handoff-impl.md for full details.

- [ ] **Case B sorry (line ~8644)**: Not attempted. Needs sigma extraction for `(x' < d ↔ x < c)` + cross-boundary pivots identical to Case A. Steps:
  1. Add sigma instantiation (pattern from Case A lines ~8342-8344)
  2. Extract `(x' < d ↔ x < c)` via sigma with `fun _ => d` selection
  3. Add cross-boundary pivot branches (copy from Case A)
  4. Will face same inaccessible Fin variable issue as Case A — fix Case A first

- [ ] **Case B dead code sorry (line ~8697)**: Inside `/- ... -/` block comment. No live goals — confirmed not a real sorry site.

- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours remaining (after file splitting reduces compile cycles)

**Depends on**: 2 (COMPLETED). **Resume after**: tasks 168, 174 (file splitting)

**Note on file splitting**: ExpressivenessGeneral.lean is ~10k lines with 3-5 minute compile cycles. Tasks 168 (parameterize DerivationTree) → 174 (split oversized files) will split this file into focused modules before Phase 3 resumes, dramatically reducing iteration time for Phases 3-remainder through 9.

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (or its split successors after task 174)

**Key positions in file** (line numbers approximate — may shift after task 174 split):
- SplitPointProps: line ~2404 (h_d_compat_left at line ~2457)
- ghr93_case_II: line ~8162
- D-compatible forward game: lines ~8226-8318
- Cross-boundary ordering (hord_cd_en_pn): line ~8265
- hc_le_en derivation: line ~8335
- Case A sorry: line ~8556
- Case B sorry: line ~8644
- Case B dead code: line ~8697

**Verification**:
- Sorry sites at Case A and Case B lines are closed
- `lake build` passes
- Sorry count in ExpressivenessGeneral.lean (or successors) reduced from 5 to 2

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Added `ghr93_rank_down_proj` lemma (233 lines) for position-tracking variant of rank_down. S6 closed directly using rank_down_proj. S7 right-case expanded (~160 lines) with h_cont_transfer_mr and h_mr_resp_ge_d fully proved. S7-right K-(negD) sorry subsequently closed via shared approach from Phase 2.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

---

### Phase 5: Cases III/IV + Strategy Restriction (S11, S12) [NOT STARTED]

**Goal**: Close S11 (Cases III/IV gap detection, line 9580) and S12 (strategy restriction for rank-varying forward-to-backward, line 9942).

**Tasks**:

- [ ] **Close S11 (line 9580, `ghr93_cases_III_IV`)**: Full theorem body sorry. Construct backward game response when a_n is a gap.
  1. Case-split on whether a_bwd(n) is left-defined or right-defined (or both)
  2. Use `left_formula_gap_detection` / `right_formula_gap_detection` (proved sorry-free in EFGames.lean) to find a matching gap in M
  3. Use `gap_detection_unique` to show the matching gap has correct properties
  4. Construct response sequence: tau (for init positions) + matching gap (for position n)
  5. Assemble winning condition from tau + gap detection properties
  - Estimated: 150-300 lines (substantial new proof using existing infrastructure)

- [ ] **Close S12 (line 9942, `ghr93_forward_to_backward_rank_varying`)**: Sub-interval strategy restriction.
  - **Approach**: Parameter approach -- modify `ghr93_forward_to_backward_rank_varying` to take the IH game (`h_r1_univ`) as a parameter from the main induction, rather than deriving it internally. The IH already provides games on all sub-intervals via universal quantification.
  - Do NOT implement full Lemma 10 strategy restriction theorem -- the parameter approach is simpler and sufficient.
  - Estimated: 100-200 lines (signature change + threading IH through)

- [ ] Run `lake build` to confirm no regressions

**Timing**: 5-9 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- S11 at line 9580, S12 at line 9942

**Verification**:
- Sorry sites at lines 9580 and 9942 are closed
- `lake build` passes
- Sorry count in ExpressivenessGeneral.lean reduced from 2 to 0

---

### Phase 6: Keystone Sorry -- NF Characterization (S13) [NOT STARTED]

**Goal**: Close the keystone sorry at EFGames.lean:10086 -- the inductive step of `nf_characterizable_by_stavi`. Every NormalForm at depth k+1 must be characterizable by a StaviFormula.

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
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- NF characterization inductive step (~200-400 lines)

**Verification**:
- Sorry site S13 (EFGames.lean:10086) is closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `lake build` passes

---

### Phase 7: Reynolds Theorem 5 -- no_gaps_discrete (S14) [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in IntegerModel.lean:863) -- Reynolds Theorem 5 showing the integer model has no gaps.

**Tasks**:
- [ ] Read the current state of `no_gaps_discrete` in IntegerModel.lean
- [ ] Implement the gap elimination argument: since every NF is characterizable by a StaviFormula (Phase 6), and StaviFormulas are determined by their truth at integer points, gaps in the integer model would require a type not characterizable by any StaviFormula -- contradiction
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- no_gaps_discrete at line 863 (~100-200 lines)

**Verification**:
- Sorry site S14 is closed
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Close succ_cofinal via Gap Elimination [NOT STARTED]

**Goal**: Prove `succ_cofinal` (ChronicleToCountermodel.lean:1885) -- the root sorry blocking `bx_completeness`.

**Tasks**:
- [ ] Read the current state of `succ_cofinal` and `limitDomSubtype_isSuccArchimedean`
- [ ] Wire `no_gaps_discrete` + `nf_characterizable_by_stavi` to prove `IsSuccArchimedean` for `LimitDomSubtype`
- [ ] Argument: if there existed a point x in `LimitDomSubtype` with no successor, the interval (x, ...) would contain a gap. But `no_gaps_discrete` (via the chronicle's OrderIso) shows no such gap exists. Therefore every point has a successor.
- [ ] Close `succ_cofinal` -- makes `succ_embed_surjective`, `cantor_bfmcs_discrete_restricted_tc`, and `cantor_bfmcs_discrete_restricted_fuc` all sorry-free
- [ ] Verify `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal at line 1885 (~100-300 lines)

**Verification**:
- `succ_cofinal` sorry is closed
- `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- `#print axioms countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 9: Final Wiring + Verification [NOT STARTED]

**Goal**: Wire `countermodel_discrete_enriched` to `countermodel_discrete` and verify `bx_completeness` is sorry-free.

**Tasks**:
- [ ] Close sorry at Completeness.lean:226 -- wire `countermodel_discrete_enriched` to `countermodel_discrete`, specializing D = Int
- [ ] Close sorry at Completeness.lean:256 -- type adaptation
- [ ] Close sorry at Completeness.lean:281 -- type adaptation
- [ ] Close sorry at Completeness.lean:290 -- type adaptation
- [ ] Run `#print axioms countermodel_discrete_enriched` and confirm no `sorryAx`
- [ ] Run `#print axioms bx_completeness` (or `completeness_discrete`)
- [ ] Confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Verify no `sorryAx` appears anywhere in the output
- [ ] Run `lake build` -- confirm zero errors
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback

**Timing**: 1-2 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- 4 sorry sites at lines 226, 256, 281, 290 (~30-80 lines)

**Verification**:
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes with zero errors
- Definition of done is met

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] All 12 remaining critical-path sorry sites closed
- [ ] `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `succ_cofinal` sorry is closed (root sorry for bx_completeness)
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No `sorryAx` in the axiom output for `bx_completeness`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- Phase 3 residual closures + Phase 5 (S11, S12)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- NF characterization inductive step (Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- no_gaps_discrete (Phase 7)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal (Phase 8)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- final wiring (Phase 9)
- `specs/155_reynolds_pipeline_activation/plans/31_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**If Phase 3 residual sorry closure is blocked**:
1. Factor out `same_order_type` assembly into a reusable helper that takes component game data (tau orderings, sigma extraction, forward game orderings, cross-boundary pivots) and produces the composed winning condition. This eliminates per-case engineering overhead.
2. If `extendPoint` wrapping is the issue, add explicit coercion lemmas for `extendPoint` vs raw carrier types.

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
