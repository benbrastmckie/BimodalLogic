# Implementation Plan: Reynolds Pipeline Activation (v28 revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IMPLEMENTING]
- **Effort**: 16-24 hours
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**: reports/28_team-research.md (5-teammate synthesis), reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md
- **Artifacts**: plans/28_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline, closing `succ_cofinal` through gap elimination. The prior two-track strategy (Track A: OrderIso bypass, Track B: GHR93 pipeline) has been collapsed to a single track after Track A was proven infeasible: every path from the Burgess chronicle to a countermodel on Int goes through `IsSuccArchimedean` for `LimitDomSubtype`, which is exactly the sorry in `succ_cofinal`. Separately, Phase B2's atom type verification confirmed that `StaviFormula` uses infinite `Formula` atoms, blocking Approach A (direct enumeration) for formula C resolution. The plan proceeds entirely via Approach C (case-split) and the remaining GHR93 pipeline machinery.

Nine phases close the 14 critical-path sorry sites in a dependency-ordered sequence, culminating in proving `succ_cofinal` via `nf_characterizable_by_stavi` + `no_gaps_discrete` (the gap elimination argument).

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes. `succ_cofinal` is proved via GHR93 gap elimination, making the entire discrete completeness pipeline sorry-free.

### Research Integration

Nine research reports and a 5-teammate team research synthesis were integrated into this plan:

| Report | Key Finding | Impact on Plan |
|--------|-------------|----------------|
| 28_team-research (5 teammates) | Formula C circularity is narrower than claimed; rank off-by-one confirmed; atom type may block Approach A; case-split targets outdated; position-tracking sorries need separate fix; same root cause rediscovered 5+ times | Drives phase sequencing and Approach C selection |
| 29_literature-alignment | Approach A (direct StaviFormula enumeration) is non-circular; Approach B (NormalForm mediated) IS circular; Approach C (case-split) is pragmatic fix | Confirms Approach C as viable path |
| 30_critical-path-wiring | EFGames sorry sites are ORPHANED from bx_completeness; OrderIso bypass needs ~310-510 lines | Informed (now-abandoned) Track A |
| 30_forward-inventory | 14 sorry sites on GHR93 critical path; mechanical strategy for S3, S5 | Drives phase effort estimates |
| 35_phase1-blocker-prior-art | Full GHR93 pipeline estimated at 40-60 hours remaining | Calibrates effort expectations |
| 40_literature-crossref | 28 total sorries mapped to GHR93 paper steps; Claim 1 cluster = 7 sorries | Confirms sorry-to-phase mapping |
| 30_mechanical-strategy | K^-(negD) adaptation strategy for multi-round games | Informs Phase 1 (mechanical sorry closure) |
| 30_session-audit | 2,978 net new lines; 21 new theorems; build passes | Confirms stable codebase baseline |
| 29_d-consistency-architecture | d_consistency with d=a_bwd(n) is UNPROVABLE; infimum needed | Historical context for case-split approach |

### Revision History

**v28 original**: Two-track plan (Track A: OrderIso bypass, Track B: GHR93 pipeline). Track A and Track B were independent after Wave 1.

**v28 revised (this version)**: Single-track plan (GHR93 pipeline only). Changes:
- Track A (OrderIso bypass) removed -- proven infeasible during Phase A1 implementation
- Phases B1, B2 completed -- h_fwd_r1 rank fix done, atom type verified as infinite
- Approach A (Fintype enumeration) ruled out -- StaviFormula uses infinite Formula atoms
- Approach C (case-split) confirmed as sole viable formula C resolution path
- Phases renumbered sequentially 1-9 (was A1-A5, B1-B9)
- Phase 8 added: closing `succ_cofinal` via gap elimination (the payoff connecting GHR93 to bx_completeness)

## Goals & Non-Goals

**Goals**:
- Close all 14 GHR93 critical-path sorry sites (S1-S14)
- Prove `succ_cofinal` via gap elimination using `nf_characterizable_by_stavi` + `no_gaps_discrete`
- Achieve sorry-free `bx_completeness` by closing `succ_cofinal` (the root sorry blocking TC/FUC coherence)
- Achieve sorry-free `nf_characterizable_by_stavi` and `no_gaps_discrete`

**Non-Goals**:
- Closing TruthLemma.lean sorry sites (non-critical-path, parametric truth lemma handles via BFMCS coherence)
- Closing OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- Archiving BXCanonical dead-code sorries (separate cleanup task)
- Building rank_lift infrastructure (case-split approach is preferred for S1/S2)
- OrderIso bypass (Track A) -- proven infeasible
- Approach A (Fintype enumeration for StaviFormula) -- blocked by infinite atoms

## Superseded Approaches

The following approaches have been tried and ruled out across 10+ sessions and 100+ artifacts. Do NOT re-attempt these.

| Approach | Where Tried | Why It Failed |
|----------|-------------|---------------|
| **Track A: OrderIso bypass** | Phase A1 (this plan, v28 original) | `chronicle_is_good` requires `ChronicleAsPriorModel` whose constructor `extract_chronicle_as_prior` fills `domain_succ_archimedean := limitDomSubtype_isSuccArchimedean` which uses `succ_cofinal`. Every path from Burgess chronicle to countermodel on Int goes through `IsSuccArchimedean`. `valid_discrete` itself quantifies over `IsSuccArchimedean D` domains. No bypass exists. |
| **Approach A: Fintype StaviFormula enumeration** | Phase B2 (this plan) | `StaviFormula` is monomorphic with `Formula` atoms (infinite type, `Countable + Infinite`). `Fintype { A : StaviFormula // stavi_depth A <= r }` is NOT constructible. `NormalForm (muSig sig)` IS Fintype but inversion back to StaviFormula is circular (= Approach B). |
| Rank embedding alone (without infimum) | `phase-1-handoff-b.md` | Rank-r and rank-(r+1) games give unrelated responses; no theorem bridges them |
| d = a_bwd(n) with rank-(r+1) | Several sessions | d_consistency literally false when d is not d-bar |
| h_d_unique (uniqueness from rank-r type) | Lines 2755-2859 | MATHEMATICALLY FALSE: K^-(negD) has depth r+2, two points can share rank-r type but differ at r+2 |
| Gap equivalence lemma | report 37 | FALSE in general: adjacent point and gap disagree on atoms. Report 37 proved this is a dead end |
| Strict pigeonhole without case split | Lines 2792, 2806 | Infimum yields non-strict bound; strict pigeonhole requires failures strictly below infimum |
| NormalForm -> StaviFormula inversion (Approach B) | reports 38-39 | CIRCULAR: converting NF back to StaviFormula IS the expressive completeness theorem being proved |
| Predicate-level argument at rank r (without game) | report 29 lean-infra | Tail condition of S_C membership quantifies over intervals above the point; same type does not imply same tail |

**Key settled questions**:
- Infimum redefinition IS necessary (reports 29, 35 definitively refuted handoff-b's claim). Do not revisit this.
- Track A (OrderIso bypass) is NOT FEASIBLE without first proving `succ_cofinal`. Do not revisit this.
- Approach A (Fintype enumeration) is BLOCKED by infinite atoms. Do not revisit this.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case-split targets from reports 38/39 are outdated against current sorry sites | M | H | Phase 2 re-maps case-split to CURRENT sorry locations (3901, 3935, 4412, 4424, 4468) before implementation |
| S8 requires `c <= e_n` bound not currently in scope in `ghr93_case_II` | M | H | Phase 3 extends `SplitPointProps` to export this bound or derives it from tau game ordering |
| Position-tracking sorries (4483/4508) harder than estimated | M | M | Phase 4 attempts `rank_embed_project_eq` (~50-100 lines); if blocked, inline rank_down projection (~200 lines) |
| NF characterization inductive step (S13) requires major new game-theoretic argument | H | H | Defer to Phase 6; all prior phases provide infrastructure. If blocked, document what remains. |
| `succ_cofinal` proof via gap elimination requires additional lemmas beyond S13+S14 | H | M | Phase 8 has contingency: if gap elimination is blocked, document the gap and recommend Task 129 Henkin approach |
| Same diagnosis rediscovered without follow-through (historical pattern) | M | M | This plan includes explicit verification gates; each phase has concrete line-count deliverables; use Superseded Approaches section to prevent backtracking |
| Build regression after wiring changes | M | L | Run `lake build` after every phase; commit working states |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 6, 7 |
| 8 | 9 | 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Mechanical Sorry Closure S3 + S5 [COMPLETED]

**Goal**: Close the two independently closable mechanical sorry sites that are pure index arithmetic adaptations of existing proofs. These have no dependency on formula C resolution or any other sorry site.

**Tasks**:
- [x] Close S3 (line 4412, `h_cont_transfer_mr`): mechanical copy of `h_cont_transfer` (lines 3240-3330) with multi-round indices `(2+3n, 3+3n, 4+3n)` instead of `(1, 2, 3)` (~90 lines) *(completed: fixed 9 omega failures + type mismatch by using simp [game_tuple, show k=n_sel+j] pattern)*
- [x] Close S5 (line 4468, `h_mr_resp_ge_d` gap case): mirror of existing gap proof at lines 3994-4250 with adapted indices (~255 lines) *(completed: used ha'_mr_in bound instead of game-tuple order agreement)*
- [x] Run `lake build` after each closure to confirm no regressions *(completed: lean_diagnostic_messages confirmed clean)*
- [x] Verify no new sorry sites introduced *(completed: only pre-existing sorries remain)*

**Timing**: 2-3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- ~345 lines across 2 sorry sites

**Verification**:
- Sorry sites S3, S5 (lines 4412, 4468) are closed
- `lake build` passes
- Sorry count reduced by 2

---

### Phase 2: Pigeonhole + K⁻(¬D) Bridge (Unified S1/S2/S4/S7-right Resolution) [IN PROGRESS]
- **Started**: 2026-05-24T17:30:00Z
- **Revised**: 2026-05-24T20:00:00Z — Definitive resolution found (report 29_cont-holds-refactoring.md)
- **Progress**: S1 FULLY CLOSED (d20541402 + ea12c7fbb). S2 FULLY CLOSED (7929e11f7 + 18d6a8b20). Phase 2 COMPLETE — all Claim 1 sorries resolved. S4/S7-right remain (mechanical K⁻ copies, ~600 lines each or factor into shared lemma).
- **Completed**: 2026-05-24T22:00:00Z

**Goal**: Build 3 bridge lemmas connecting existing pigeonhole output D to the K⁻ transfer argument. This closes S1, S2, S4, and S7-right UNIFORMLY — no point/gap case split needed.

**Definitive Research Finding** (report 29_cont-holds-refactoring.md):
- Full cont_holds → formula refactoring is **CIRCULAR** (requires nf_characterizable_by_stavi = sorry S13)
- **Non-circular resolution**: Use the pigeonhole's output D (single StaviFormula, depth ≤ r, fails cofinally below infimum) in the K⁻ argument directly
- K⁻(¬D) works uniformly for carrier points AND gaps — no case split needed
- This follows GHR93's proof structure exactly (same K⁻ argument, different formula selection)

**New Infrastructure** (~120 lines):
- [ ] `K_minus_from_cofinal_failure` (~40 lines): D fails cofinally below t among mu-points → K⁻(¬D)(t) holds at rank r+2
- [ ] `K_minus_transfer` (~30 lines): Transfer K⁻(¬D) through game agreement at rank r+2 (direct from h_fwd_r1)
- [ ] `K_minus_implies_le_infimum` (~50 lines): K⁻(¬D) at response + D holds above d → response ≤ rank_embed(d)

**Sorry Site Rewrites** (~200 lines replacing existing dead code):
- [ ] S1 (boundary): Apply K⁻(¬D) argument — contradiction with h_not_le
- [ ] S2 (gap): Same K⁻(¬D) argument — works for gaps because K⁻ semantics are defined for all elements
- [ ] S4 (multi-round): Same pattern with multi-round indices
- [ ] S7-right: Same pattern applied in right sub-case

**Code Removal** (~250 lines):
- [ ] Remove Case A/Case B split at sorry sites (K⁻ approach is uniform)
- [ ] Remove boundary-specific and gap-specific workaround code

**Net change**: ~+320 lines new, ~-250 lines removed = ~+70 lines net. Closes 4 sorry sites.

**Timing**: 2-3 hours

**Depends on**: 1

**GHR93 Alignment**: Uses GHR93's identical K⁻ argument structure. Difference: GHR93 uses C (full interval-type formula, circular to construct); we use D (single separating formula from pigeonhole, non-circular). Same proof pattern, different formula selection. Both valid.

---

### Phase 3: Restructure Case II e_n Construction (S8/S9/S10) [BLOCKED]
- **Blocked**: 2026-05-24T20:00:00Z — Same architectural divergence as Phase 2 (report phase3-s8-handoff.md)

**Goal**: Restructure `ghr93_case_II` to construct `e_n` via U(B,A) transfer per GHR93, not from forward game response.

**Root Cause Finding** (handoffs/phase3-s8-handoff.md):
- GHR93 constructs `e_n` via U(B,A) formula transfer (guaranteeing `c < e_n` by construction since `e_n > resp_tau(n-1) ≥ c`)
- The formalization gets `e_n` from the forward game response — provides NO ordering guarantee relative to `c`
- S8/S9/S10 share the SAME architectural divergence as S1/S2 — formalization doesn't follow GHR93 faithfully

**Resolution Path** (after Phase 2 K⁻ bridge):
- Once Phase 2 closes Claim 1 direction, the forward-to-backward strategy is established
- Case II can then use the backward strategy (tau) to transfer U(B,A) from N to M
- This gives `e_n` by the Until witness in M, guaranteeing `c < e_n` and `B(e_n)` simultaneously
- S8/S9/S10 then close from the construction (ordering is built into e_n's definition)

**Tasks**:
- [ ] After Phase 2: restructure e_n construction to use tau-transferred U(B,A) witness per GHR93 p.117-118
- [ ] Derive `c < e_n` from Until witness properties (e_n > resp_tau(n-1) ≥ c)
- [ ] Close S8 cross-boundary ordering from restructured e_n
- [ ] Close S9/S10 same_order_type from restructured e_n + sigma/tau composition

**Timing**: 3-4 hours (substantial restructure)

**Depends on**: 2 (K⁻ bridge enables backward strategy needed for U(B,A) transfer)

**GHR93 Alignment**: This phase eliminates the second major architectural divergence. GHR93 Case II explicitly constructs e_n as a U(B,A) witness; the formalization must do the same.

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]
- **Completed**: 2026-05-24T18:30:00Z
- **Method**: New lemma `ghr93_rank_down_proj` (233 lines) — position-tracking variant. S6 closed directly. S7 expanded with 1 new sorry (same K⁻ blocker type as S1/S2). Net -1 sorry.

**Goal**: Close the position-tracking sorry sites at lines 4483 and 4508, which are structurally different from the formula C cluster. After `rank_down` projects from rank r+2 to rank r, position-level tracking (`a'_rd(position) = d`) is lost.

**Tasks**:
- [ ] Analyze what `rank_down` provides about position assignments vs what the sorry needs
- [ ] Attempt `rank_embed_project_eq` lemma: rank_embed maps d at rank r to an element at rank r+2; when the response at rank r+2 equals rank_embed(d), the rank-r projection is d (~50-100 lines)
- [ ] If `rank_embed_project_eq` is insufficient, inline `rank_down`'s projection to track position assignments explicitly (~200 lines, fallback)
- [ ] Close S6 (line 4483) and S7 (line 4508) using the position-tracking lemma
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1-2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- position-tracking fix (~50-200 lines)

**Verification**:
- Sorry sites S6, S7 (lines 4483, 4508) are closed
- `lake build` passes

---

### Phase 5: Cases III/IV + Lemma 10 (S11, S12) [NOT STARTED]

**Goal**: Close the Cases III/IV gap-detection sorry (S11) and the Lemma 10 strategy-restriction sorry (S12).

**Tasks**:
- [ ] Close S11 (line 7028, Cases III-IV gap case): the `left_formula` and `right_formula` infrastructure exists sorry-free; implement the proof body using Lemma 9 correctness (~100-150 lines)
- [ ] Close S12 (line 7390, Lemma 10 strategy restriction): sub-interval strategy restriction for `ghr93_forward_to_backward_rank_varying` (~150-200 lines)
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-3 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- Cases III/IV + Lemma 10 (~250-350 lines)

**Verification**:
- Sorry sites S11, S12 (lines 7028, 7390) are closed
- `lake build` passes

---

### Phase 6: Keystone Sorry -- NF Characterization (S13) [NOT STARTED]

**Goal**: Close the keystone sorry at EFGames.lean:10086 -- the inductive step of `nf_characterizable_by_stavi`. This is the central theorem of the GHR93 formalization: every NormalForm at depth k+1 is characterizable by a StaviFormula.

**Tasks**:
- [ ] Read the current structure of `nf_characterizable_by_stavi` and identify exactly what the inductive step requires
- [ ] The base case (k=0) is proved via `nf_base_sf` (sorry-free)
- [ ] The inductive step for k+1 NFs requires handling 2-variable NFs (`NormalForm sig k 2`) -- characterizing the joint type of a pair (x, t) using Until/Since connectives
- [ ] Implement the inductive step using the game-theoretic argument from GHR93 Theorem 6/Proposition 7, which relies on the four-case analysis proved in Phases 2-5
- [ ] This requires all previous S1-S12 closed, as the inductive step invokes the four-case analysis
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours (may require additional research if blocked)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- NF characterization inductive step (~200-400 lines)

**Verification**:
- Sorry site S13 (EFGames.lean:10086) is closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `lake build` passes

---

### Phase 7: Reynolds Theorem 5 -- no_gaps_discrete (S14) [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in IntegerModel.lean) -- Reynolds Theorem 5 showing that the integer model has no gaps. This uses `nf_characterizable_by_stavi` to show every NF is a StaviFormula, then argues that every type realized in the integer model is a principal type (no gaps possible).

**Tasks**:
- [ ] Read the current state of `no_gaps_discrete` in IntegerModel.lean
- [ ] Implement the proof using the gap elimination argument for Prior structures (Reynolds 1992): since every NF is characterizable by a StaviFormula (Phase 6), and StaviFormulas are determined by their truth at integer points, gaps in the integer model would require a type not characterizable by any StaviFormula -- contradiction
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1-2 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- no_gaps_discrete (~100-200 lines)

**Verification**:
- Sorry site S14 is closed
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Close succ_cofinal via Gap Elimination [NOT STARTED]

**Goal**: Prove `succ_cofinal` (ChronicleToCountermodel.lean:1885) -- the root sorry blocking `bx_completeness`. With `nf_characterizable_by_stavi` (Phase 6) and `no_gaps_discrete` (Phase 7) in hand, the gap elimination argument shows `LimitDomSubtype` satisfies `IsSuccArchimedean`: every point has a successor, because otherwise there would be a gap in the type space, contradicting `no_gaps_discrete`.

**Tasks**:
- [ ] Read the current state of `succ_cofinal` and `limitDomSubtype_isSuccArchimedean` in ChronicleToCountermodel.lean
- [ ] Wire `no_gaps_discrete` + `nf_characterizable_by_stavi` to prove `IsSuccArchimedean` for `LimitDomSubtype`
- [ ] The argument: if there existed a point x in `LimitDomSubtype` with no successor, the interval (x, ...) would contain a gap. But `no_gaps_discrete` on the integer model (via the chronicle's OrderIso) shows no such gap exists. Therefore every point has a successor.
- [ ] Close `succ_cofinal` -- this makes `succ_embed_surjective`, `cantor_bfmcs_discrete_restricted_tc`, and `cantor_bfmcs_discrete_restricted_fuc` all sorry-free
- [ ] Verify `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal proof (~100-300 lines)

**Verification**:
- `succ_cofinal` sorry is closed
- `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- `#print axioms countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 9: Final Wiring + Verification [NOT STARTED]

**Goal**: Wire `countermodel_discrete_enriched` to `countermodel_discrete` (closing the sorry at Completeness.lean:227) and verify that `bx_completeness` is entirely sorry-free.

**Tasks**:
- [ ] Read the type signatures of both `countermodel_discrete_enriched` and `countermodel_discrete`
- [ ] Replace the `sorry` at Completeness.lean:227 with a call to `countermodel_discrete`, specializing D = Int from the existential
- [ ] Handle any type adaptation between the enriched and generic existential forms
- [ ] Run `#print axioms countermodel_discrete_enriched` and confirm no `sorryAx`
- [ ] Run `#print axioms bx_completeness` (or `completeness_discrete`)
- [ ] Confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Verify no `sorryAx` appears anywhere in the output
- [ ] Run `lake build` -- confirm zero errors
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback
- [ ] Search for any `axiom` declarations in `Theories/Bimodal/Metalogic/WeakCanonical/` -- confirm none exist

**Timing**: 1-2 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- wire enriched to discrete (~10-30 lines)

**Verification**:
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes with zero errors
- Definition of done is met

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] All 14 GHR93 critical-path sorry sites closed: S1-S14
- [ ] `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `succ_cofinal` sorry is closed (root sorry for bx_completeness)
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] No `sorryAx` in the axiom output for `bx_completeness`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- formula C resolution + mechanical sorry closure + position tracking + Case II ordering + Cases III/IV (Phases 1-5)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- NF characterization inductive step (Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- no_gaps_discrete (Phase 7)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal proof (Phase 8)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- countermodel_discrete_enriched wired to countermodel_discrete (Phase 9)
- `specs/155_reynolds_pipeline_activation/plans/28_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**If Phase 2 (formula C case-split) is blocked**:
1. Re-examine whether a hybrid approach using `NormalForm (muSig sig)` (which IS Fintype) can partially substitute for formula C without circular NF->StaviFormula inversion
2. Alternatively, investigate whether the case-split can be decomposed differently (e.g., splitting on individual formula truth rather than `cont_holds` at infimum)
3. Document exactly which sub-goals remain open for future sessions

**If Phase 6 (NF characterization, S13) is blocked**:
1. This is the highest-risk phase. If the inductive step requires infrastructure beyond what Phases 1-5 provide, document what is missing
2. S13 blocking does not prevent closing S1-S12 (valuable partial progress)
3. A dedicated research round on the 2-variable NF characterization may be needed

**If Phase 8 (succ_cofinal via gap elimination) is blocked**:
1. The gap elimination argument may require additional intermediate lemmas connecting `no_gaps_discrete` (on the integer model) to `IsSuccArchimedean` (on `LimitDomSubtype`)
2. If blocked, document the precise gap and recommend Task 129 (Henkin canonical model approach) as an alternative path to sorry-free `bx_completeness`
3. All S1-S14 closures remain valuable as standalone GHR93 formalization progress

**General rollback**: All changes are committed after each phase. Git history enables rollback to any phase boundary.
