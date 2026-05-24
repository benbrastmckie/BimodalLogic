# Implementation Plan: Reynolds Pipeline Activation (v28)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 20-30 hours (Track A: 8-14h, Track B: 12-16h)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**: reports/28_team-research.md (5-teammate synthesis), reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md
- **Artifacts**: plans/28_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan has two tracks. Track A (priority 1) achieves sorry-free `bx_completeness` via the OrderIso bypass strategy, wiring `countermodel_discrete_enriched` through `countermodel_discrete` using `chronicle_is_good`'s sorry-free OrderIso to bypass `succ_cofinal`. Track B (priority 2) completes the GHR93 expressive completeness pipeline as a standalone mathematical contribution, resolving 14 critical-path sorry sites through a staged attack: rank fix, atom type verification, formula C resolution, mechanical sorry closure, and the keystone NF characterization. The two tracks are independent after Phase A1's feasibility verification, and Track B phases can be executed in parallel with Track A.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback).

### Research Integration

Nine research reports and a 5-teammate team research synthesis were integrated into this plan:

| Report | Key Finding | Impact on Plan |
|--------|-------------|----------------|
| 28_team-research (5 teammates) | Formula C circularity is narrower than claimed; rank off-by-one confirmed; atom type may block Approach A; case-split targets outdated; position-tracking sorries need separate fix; same root cause rediscovered 5+ times | Drives the two-track structure and the ordered phase sequencing in Track B |
| 29_literature-alignment | Approach A (direct StaviFormula enumeration) is non-circular; Approach B (NormalForm mediated) IS circular; Approach C (case-split) is pragmatic fix | Determines the decision gate at Phase B2 |
| 30_critical-path-wiring | EFGames sorry sites are ORPHANED from bx_completeness; OrderIso bypass needs ~310-510 lines | Drives Track A strategy |
| 30_forward-inventory | 14 sorry sites on GHR93 critical path; mechanical strategy for S3, S5 | Drives Track B phasing and effort estimates |
| 35_phase1-blocker-prior-art | Full GHR93 pipeline estimated at 40-60 hours remaining | Motivates two-track approach (bypass first, then pipeline) |
| 40_literature-crossref | 28 total sorries mapped to GHR93 paper steps; Claim 1 cluster = 7 sorries | Confirms sorry-to-phase mapping |
| 30_mechanical-strategy | K^-(negD) adaptation strategy for multi-round games | Informs Phase B4 (mechanical sorry closure) |
| 30_session-audit | 2,978 net new lines; 21 new theorems; build passes | Confirms stable codebase baseline |
| 29_d-consistency-architecture | d_consistency with d=a_bwd(n) is UNPROVABLE; infimum needed | Historical context for Track B approach |

### Prior Plan Reference

The prior plan (v27) recommended the OrderIso bypass strategy with 6 phases (12-18 hours). Key lessons:

- **Validated approach**: The OrderIso bypass from `chronicle_is_good` is confirmed sorry-free and architecturally sound. Track A preserves this strategy with tighter phase boundaries.
- **Effort calibration**: v27 estimated 12-18 hours for Track A. The new research (28_team-research) does not change this estimate but provides higher confidence in feasibility.
- **Missing scope**: v27 treated the 14 GHR93 sorry sites as "deferred future work" in a single documentation phase. The new research provides enough detail for a concrete phased attack (Track B), which this plan adds.
- **Risk awareness**: v27 identified OrderIso type mismatch as the primary risk. The new research confirms this is mitigable but adds a new risk: the atom type cardinality question that determines Approach A vs C for formula C resolution.

### Roadmap Alignment

This plan advances the following roadmap items:
- "Reynolds pipeline activation" -- Track A directly achieves this
- "sorry-free discrete completeness" -- Track A achieves sorry-free `bx_completeness`
- The GHR93 expressive completeness formalization (Track B) would be the first machine-verified proof of Stavi expressive completeness for general linear orders

## Goals & Non-Goals

**Goals**:
- (Track A) Achieve sorry-free `bx_completeness` via OrderIso bypass of `succ_cofinal`
- (Track A) Wire `countermodel_discrete_enriched` to `countermodel_discrete`
- (Track A) Replace chronicle fallback with OrderIso-based construction
- (Track A) Verify `#print axioms bx_completeness` shows no `sorryAx`
- (Track B) Fix h_fwd_r1 rank from r+1 to r+2 across 6 signature locations
- (Track B) Determine atom type cardinality and select formula C resolution approach
- (Track B) Close all 14 GHR93 critical-path sorry sites in ExpressivenessGeneral.lean, EFGames.lean, IntegerModel.lean
- (Track B) Achieve sorry-free `nf_characterizable_by_stavi` and `no_gaps_discrete`

**Non-Goals**:
- Closing TruthLemma.lean sorry sites (non-critical-path, parametric truth lemma handles via BFMCS coherence)
- Closing OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- Archiving BXCanonical dead-code sorries (separate cleanup task)
- Building rank_lift infrastructure (case-split approach is preferred for S1/S2)

## Superseded Approaches

The following approaches have been tried and ruled out across 10+ sessions and 100+ artifacts. Do NOT re-attempt these.

| Approach | Where Tried | Why It Failed |
|----------|-------------|---------------|
| Rank embedding alone (without infimum) | `phase-1-handoff-b.md` | Rank-r and rank-(r+1) games give unrelated responses; no theorem bridges them |
| d = a_bwd(n) with rank-(r+1) | Several sessions | d_consistency literally false when d is not d-bar |
| h_d_unique (uniqueness from rank-r type) | Lines 2755-2859 | MATHEMATICALLY FALSE: K^-(negD) has depth r+2, two points can share rank-r type but differ at r+2 |
| Gap equivalence lemma | report 37 | FALSE in general: adjacent point and gap disagree on atoms. Report 37 proved this is a dead end |
| Strict pigeonhole without case split | Lines 2792, 2806 | Infimum yields non-strict bound; strict pigeonhole requires failures strictly below infimum |
| NormalForm -> StaviFormula inversion (Approach B) | reports 38-39 | CIRCULAR: converting NF back to StaviFormula IS the expressive completeness theorem being proved |
| Predicate-level argument at rank r (without game) | report 29 lean-infra | Tail condition of S_C membership quantifies over intervals above the point; same type does not imply same tail |

**Key settled question**: Infimum redefinition IS necessary (reports 29, 35 definitively refuted handoff-b's claim). Do not revisit this.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OrderIso type mismatch between chronicle domain and TaskFrame Int | H | M | Phase A1 verifies compatibility before heavy coding; abort to full pipeline if infeasible |
| TC/FUC coherence proofs via OrderIso more complex than estimated | M | M | Start with TC (simpler); if blocked after 4h, analyze specific obligation types and pivot |
| Atom type is infinite, blocking Approach A for formula C | M | M | Phase B2 explicitly checks this; if blocked, use Approach C (case-split) which has no Fintype requirement |
| Case-split targets from reports 38/39 are outdated against current sorry sites | M | H | Phase B3 re-maps case-split to CURRENT sorry locations (3901, 3935, 4412, 4424, 4468) before implementation |
| Position-tracking sorries (4483/4508) harder than estimated | M | M | Phase B5 attempts rank_embed_project_eq (~50-100 lines); if blocked, inline rank_down projection (~200 lines) |
| NF characterization inductive step (S13) requires major new game-theoretic argument | H | H | Defer to Phase B8; if blocked, document as future work -- Track A already achieves sorry-free completeness |
| Same diagnosis rediscovered without follow-through (historical pattern) | M | M | This plan includes explicit verification gates; each phase has concrete line-count deliverables; use Superseded Approaches section to prevent backtracking |
| Build regression after wiring changes | M | L | Run `lake build` after every phase; commit working states |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | A1, B1 | -- |
| 2 | A2, B2 | A1, B1 |
| 3 | A3, B3 | A2, B2 |
| 4 | A4, B4, B5 | A3, B3 |
| 5 | A5, B6 | A4, B4 |
| 6 | B7, B8 | B6 |
| 7 | B9 | B8 |

Phases within the same wave can execute in parallel. Track A and Track B are independent after Wave 1 (A1 confirms bypass feasibility; B1 is always required).

---

### Phase A1: Verify OrderIso Bypass Feasibility [NOT STARTED]

**Goal**: Confirm that the OrderIso bypass is viable by tracing sorryAx propagation and verifying type compatibility between `chronicle_is_good`, `countermodel_discrete`, and `countermodel_discrete_enriched`.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` and trace every `sorryAx` to its source file and line
- [ ] Run `#print axioms chronicle_is_good` and confirm zero `sorryAx`
- [ ] Read `chronicle_is_good` signature and return type (OrderIso to what?)
- [ ] Read `countermodel_discrete` in Transfer.lean -- identify type signature and delegation chain
- [ ] Read `countermodel_discrete_enriched` in Completeness.lean:227 -- identify existential form
- [ ] Read `dd_countermodel_chronicle_discrete` in ChronicleToCountermodel.lean -- identify which sub-lemmas carry `sorryAx` (expected: `cantor_bfmcs_discrete_restricted_tc`, `cantor_bfmcs_discrete_restricted_fuc`)
- [ ] Read `succ_embed_surjective` and `succ_cofinal` -- confirm these are the root sorry sites
- [ ] Document type compatibility: can `chronicle_is_good`'s OrderIso produce a `TaskFrame Int` that matches what `countermodel_discrete` needs?
- [ ] Identify exact coherence obligations (TC, BUC, FUC) that currently use `succ_embed_surjective` and would need OrderIso alternatives

**Timing**: 1-2 hours

**Depends on**: none

**Files to modify**:
- None (analysis only)

**Verification**:
- Written notes on type compatibility and coherence obligation signatures
- Clear yes/no on bypass feasibility
- If no: document the specific type mismatch; Track A is abandoned, Track B becomes sole path

---

### Phase A2: OrderIso-Based Coherence Proofs [NOT STARTED]

**Goal**: Prove TC and FUC coherence conditions using the OrderIso from `chronicle_is_good` instead of `succ_embed_surjective`, eliminating `succ_cofinal` from the dependency chain.

**Tasks**:
- [ ] Create a new section or file for OrderIso-based coherence proofs (e.g., `OrderIsoCherence.lean` or inline in Transfer.lean)
- [ ] Extract the OrderIso from `chronicle_is_good` -- this gives a bijection between Z and the chronicle's limit domain
- [ ] Prove TC (temporal coherence) for the OrderIso-based construction: forward/backward temporal content preserved through the OrderIso mapping
- [ ] Verify BUC (backward Until coherence) does NOT use `succ_embed_surjective` (expected sorry-free already via `cantor_bfmcs_discrete_restricted_buc`)
- [ ] Prove FUC (forward Until coherence) for the OrderIso-based construction: Until witnesses in Z map through the OrderIso to chronicle domain witnesses
- [ ] Verify that OrderIso-based TC/FUC proofs do NOT reference `succ_embed`, `succ_embed_surjective`, or `succ_cofinal`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 4-6 hours

**Depends on**: A1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/Transfer.lean` or new file -- OrderIso coherence proofs (~200-300 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- may need to extract helper lemmas

**Verification**:
- `#print axioms` on the new TC/FUC lemmas shows no `sorryAx`
- `lake build` passes

---

### Phase A3: Replace Chronicle Fallback in countermodel_discrete [NOT STARTED]

**Goal**: Replace the `dd_countermodel_chronicle_discrete` delegation in `countermodel_discrete` with the OrderIso-based construction, eliminating `succ_cofinal` from the `bx_completeness` critical path.

**Tasks**:
- [ ] Modify `countermodel_discrete` in Transfer.lean to use the OrderIso-based construction instead of delegating to `dd_countermodel_chronicle_discrete`
- [ ] New construction: (1) use sorry-free chronicle MCS family, (2) use `chronicle_is_good` for OrderIso, (3) build `TaskFrame Int` via OrderIso, (4) use OrderIso-based TC/FUC from Phase A2
- [ ] Verify `fully_restricted_parametric_completeness_from_neg_membership` (sorry-free) still works
- [ ] Verify `cantor_bfmcs_discrete` (sorry-free) still works
- [ ] Run `#print axioms countermodel_discrete` and confirm no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: A2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/Transfer.lean` -- replace delegation (~100-200 lines)

**Verification**:
- `#print axioms countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase A4: Wire countermodel_discrete_enriched [NOT STARTED]

**Goal**: Close the sorry at Completeness.lean:227 by wiring `countermodel_discrete_enriched` to `countermodel_discrete`.

**Tasks**:
- [ ] Read the type signatures of both `countermodel_discrete_enriched` and `countermodel_discrete`
- [ ] Replace the `sorry` at Completeness.lean:227 with a call to `countermodel_discrete`, specializing D = Int from the existential
- [ ] Handle any type adaptation between the enriched and generic existential forms
- [ ] Run `#print axioms countermodel_discrete_enriched` and confirm no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1-2 hours

**Depends on**: A3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- wire enriched to discrete (~10-30 lines)

**Verification**:
- `#print axioms countermodel_discrete_enriched` shows no `sorryAx`
- `lake build` passes

---

### Phase A5: Verify bx_completeness Axiom Cleanliness [NOT STARTED]

**Goal**: Confirm that `bx_completeness` has no `sorryAx` and that the definition of done is fully met.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` (or `completeness_discrete`)
- [ ] Confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Verify no `sorryAx` appears anywhere in the output
- [ ] Run `lake build` -- confirm zero errors
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback
- [ ] Search for any `axiom` declarations in `Theories/Bimodal/Metalogic/WeakCanonical/` -- confirm none exist

**Timing**: 0.5-1 hour

**Depends on**: A4

**Files to modify**:
- None (verification only)

**Verification**:
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes with zero errors
- Definition of done is met

---

### Phase B1: h_fwd_r1 Rank Fix (r+1 to r+2) [NOT STARTED]

**Goal**: Fix the rank off-by-one in h_fwd_r1 across 6 signature locations. This is always required regardless of which formula C approach is chosen, because `std_snce` adds +2 to stavi_depth, making C' = neg(C) or K^-(neg(C)) have depth r+2 (not r+1).

**Tasks**:
- [ ] Identify all 6 signature locations where h_fwd_r1 uses rank r+1 (expected in ExpressivenessGeneral.lean)
- [ ] Change each from r+1 to r+2 (~30 lines total)
- [ ] Verify that the forward game budget (rank r+4(n+1)) accommodates r+2 (r+2 << r+4 for n >= 0)
- [ ] Run `lake build` to confirm no regressions
- [ ] Verify no new sorry sites introduced by the rank change

**Timing**: 1-2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ExpressivenessGeneral.lean` -- 6 signature locations (~30 lines)

**Verification**:
- `lake build` passes
- All existing proofs that depend on h_fwd_r1 still compile (the wider budget accommodates the change)

---

### Phase B2: Atom Type Verification (Decision Gate) [NOT STARTED]

**Goal**: Determine whether `StaviFormula` in the relevant context uses `Fintype` atoms (enabling Approach A: direct enumeration) or infinite `Atom` (requiring Approach C: case-split). This is the critical decision gate for formula C resolution.

**Tasks**:
- [ ] Check the type parameter of `StaviFormula` where it is used in `stavi_temporal_truth_mu` -- is it parameterized by `Atom` (infinite: `Countable + Infinite`) or `muSig sig` (finite: `Fintype`)?
- [ ] If `muSig sig` (Fintype): verify that `Fintype { A : StaviFormula // stavi_depth A <= r }` is constructible
- [ ] If `Atom` (infinite): confirm that `Fintype` for bounded StaviFormulas is impossible
- [ ] Check whether `NormalForm (muSig sig) (2*r) 1` already has a `Fintype` instance (expected yes)
- [ ] Document the decision: Approach A (atoms are Fintype) or Approach C (atoms are infinite)

**Timing**: 1-2 hours

**Depends on**: B1

**Files to modify**:
- None (analysis only)

**Verification**:
- Clear written determination of atom type in the relevant context
- Clear decision on Approach A vs Approach C for Phase B3

---

### Phase B3: Formula C Resolution [NOT STARTED]

**Goal**: Resolve the formula C predicate-vs-formula gap that causes 7 of the 14 critical-path sorry sites (S1, S2, S3, S4, S5 in lines 3901, 3935, 4412, 4424, 4468). The approach depends on Phase B2's determination.

**IF Approach A (atoms are Fintype)**:

**Tasks**:
- [ ] Build `Fintype { A : StaviFormula // stavi_depth A <= r }` (~150-200 lines)
- [ ] Define `interval_type_formula : StaviFormula` as the conjunction of all depth-r StaviFormulas holding on the interval (a_n, y') (~50 lines)
- [ ] Prove `cont_holds a_n y' t <-> stavi_temporal_truth_mu N atomMap r t (interval_type_formula a_n y')` (~100 lines)
- [ ] Construct C' = neg(C) or K^-(neg(C)) as a StaviFormula of depth r+2 (~30 lines)
- [ ] Close all 7 Claim 1 sorry sites via GHR93's 5-line proof (~80 lines)
- [ ] Delete ~360 lines of pigeonhole machinery (net code reduction)
- [ ] Run `lake build` to confirm no regressions

**IF Approach C (case-split, atoms are infinite)**:

**Tasks**:
- [ ] Re-map the case-split from reports 38/39 to CURRENT sorry site locations (3901, 3935, 4412, 4424, 4468) -- the old targets (2307-2825) are outdated
- [ ] Implement case-split on `cont_holds` at infimum c_inf:
  - Case A (cont_holds FAILS at c_inf): extract witnessing formula A directly from negation (~60 lines)
  - Case B (cont_holds HOLDS at c_inf): all failures strictly below c_inf, strict pigeonhole applies cleanly (~80 lines)
- [ ] Build truth-at-gap lemma for S2 (line 3935) gap sub-case: if A holds at all approaching carrier points, it holds at the gap (~80 lines)
- [ ] Close S1 (line 3901, boundary case: r2_resp = rank_embed(y')) via dedicated boundary analysis (~30 lines)
- [ ] Close S3 (line 4412, h_cont_transfer_mr multi-round adaptation) -- this may close automatically from the case-split or need mechanical adaptation (~65 lines)
- [ ] Close S4 (line 4424, h_mr_resp_le_d multi-round) and S5 (line 4468, multi-round gap case) similarly
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2 hours (Approach A) or 2 hours (Approach C)

**Depends on**: B2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ExpressivenessGeneral.lean` -- formula C resolution (~200-400 lines depending on approach)
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/EFGames.lean` -- if Approach A needs Fintype infrastructure there

**Verification**:
- Sorry sites S1-S5 (lines 3901, 3935, 4412, 4424, 4468) are closed
- `lake build` passes
- `#print axioms` on affected lemmas shows no new `sorryAx`

---

### Phase B4: Mechanical Sorry Closure (S3, S5, S8) [NOT STARTED]

**Goal**: Close the three Tier 1 mechanical sorry sites that are independent of the formula C resolution. These are pure index arithmetic adaptations.

**Tasks**:
- [ ] Close S3 (line 4412, h_cont_transfer_mr): mechanical copy of h_cont_transfer with multi-round indices, per report 30_mechanical-strategy (~65 lines)
- [ ] Close S5 (line 4468, h_mr_resp_ge_d gap case): mirror of existing gap proof with adapted indices (~255 lines)
- [ ] Close S8 (line 5945, Case II cross-boundary ordering): sigma strategy instantiation for `x' < d <-> x < c` (~50 lines)
- [ ] Run `lake build` after each closure

**Timing**: 2 hours

**Depends on**: B3 (S3 and S5 may already be closed if Phase B3 resolves them; skip if so)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ExpressivenessGeneral.lean` -- ~370 lines across 3 sorry sites

**Verification**:
- Sorry sites S3, S5, S8 are closed
- `lake build` passes

---

### Phase B5: Position-Tracking Fix (S6, S7) [NOT STARTED]

**Goal**: Close the position-tracking sorry sites at lines 4483 and 4508, which are structurally different from the formula C cluster. After `rank_down` projects from rank r+2 to rank r, position-level tracking (`a'_rd(position) = d`) is lost.

**Tasks**:
- [ ] Analyze what `rank_down` provides about position assignments vs what the sorry needs
- [ ] Attempt `rank_embed_project_eq` lemma: rank_embed maps d at rank r to an element at rank r+2; when the response at rank r+2 equals rank_embed(d), the rank-r projection is d (~50-100 lines)
- [ ] If `rank_embed_project_eq` is insufficient, inline `rank_down`'s projection to track position assignments explicitly (~200 lines, fallback)
- [ ] Close S6 (line 4483) and S7 (line 4508) using the position-tracking lemma
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1-2 hours

**Depends on**: B3 (position-tracking context is within the Claim 1 proof structure modified by B3)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ExpressivenessGeneral.lean` -- position-tracking fix (~50-200 lines)

**Verification**:
- Sorry sites S6, S7 (lines 4483, 4508) are closed
- `lake build` passes

---

### Phase B6: Case II Ordering (S8, S9, S10) [NOT STARTED]

**Goal**: Close the three Case II ordering sorry sites that require cross-boundary ordering lemmas relating sigma and tau strategies.

**Tasks**:
- [ ] Close S8 (line 5945, if not already closed in B4): cross-boundary ordering goal `x' < d <-> x < c` from sigma strategy
- [ ] Close S9 (line 6045): same_order_type goal, extractable from `hgp_cd`/`hcd_boundary` hypotheses
- [ ] Close S10 (line 6098): related ordering goal in Case II
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1-2 hours

**Depends on**: B4 (S8 may already be closed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ExpressivenessGeneral.lean` -- Case II ordering (~100-150 lines)

**Verification**:
- Sorry sites S8, S9, S10 are closed
- `lake build` passes

---

### Phase B7: Cases III/IV + Lemma 10 (S11, S12) [NOT STARTED]

**Goal**: Close the Cases III/IV gap-detection sorry (S11) and the Lemma 10 strategy-restriction sorry (S12).

**Tasks**:
- [ ] Close S11 (line 7028, Cases III-IV gap case): the `left_formula` and `right_formula` infrastructure exists sorry-free; implement the proof body using Lemma 9 correctness (~100-150 lines)
- [ ] Close S12 (line 7390, Lemma 10 strategy restriction): sub-interval strategy restriction for `ghr93_forward_to_backward_rank_varying` (~150-200 lines)
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2 hours

**Depends on**: B6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ExpressivenessGeneral.lean` -- Cases III/IV + Lemma 10 (~250-350 lines)

**Verification**:
- Sorry sites S11, S12 are closed
- `lake build` passes

---

### Phase B8: Keystone Sorry -- NF Characterization (S13) [NOT STARTED]

**Goal**: Close the keystone sorry at EFGames.lean:10086 -- the inductive step of `nf_characterizable_by_stavi`. This is the central theorem of the GHR93 formalization: every NormalForm at depth k+1 is characterizable by a StaviFormula.

**Tasks**:
- [ ] Read the current structure of `nf_characterizable_by_stavi` and identify exactly what the inductive step requires
- [ ] The base case (k=0) is proved via `nf_base_sf` (sorry-free)
- [ ] The inductive step for k+1 NFs requires handling 2-variable NFs (`NormalForm sig k 2`) -- characterizing the joint type of a pair (x, t) using Until/Since connectives
- [ ] Implement the inductive step using the game-theoretic argument from GHR93 Theorem 6/Proposition 7
- [ ] This requires all previous phases (S1-S12 closed), as the proof uses the four-case analysis
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2 hours (may require additional research if blocked)

**Depends on**: B7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/EFGames.lean` -- NF characterization inductive step (~200-400 lines)

**Verification**:
- Sorry site S13 (EFGames.lean:10086) is closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `lake build` passes

---

### Phase B9: Reynolds Theorem 5 -- no_gaps_discrete (S14) [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in IntegerModel.lean) -- Reynolds Theorem 5 showing that the integer model has no gaps. This is the final sorry site in the GHR93 pipeline.

**Tasks**:
- [ ] Read the current state of `no_gaps_discrete` in IntegerModel.lean
- [ ] Implement the proof using the gap elimination argument for Prior structures (Reynolds 1992)
- [ ] This may use the `Fintype (BoundedStaviFormula r)` infrastructure if built in Phase B3 (Approach A)
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1-2 hours

**Depends on**: B8

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/IntegerModel.lean` -- no_gaps_discrete (~100-200 lines)

**Verification**:
- Sorry site S14 is closed
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `lake build` passes
- All 14 GHR93 critical-path sorry sites are closed

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] No `sorryAx` in the axiom output for `bx_completeness`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)
- [ ] OrderIso-based coherence proofs are individually sorry-free (`#print axioms` on each)
- [ ] (Track B) All 14 GHR93 critical-path sorry sites closed: S1-S14
- [ ] (Track B) `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] (Track B) `#print axioms no_gaps_discrete` shows no `sorryAx`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/Transfer.lean` -- OrderIso-based countermodel construction (Track A)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- `countermodel_discrete_enriched` wired to `countermodel_discrete` (Track A)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ExpressivenessGeneral.lean` -- formula C resolution + mechanical sorry closure + position tracking + Case II ordering + Cases III/IV (Track B)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/EFGames.lean` -- NF characterization inductive step (Track B)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/IntegerModel.lean` -- no_gaps_discrete (Track B)
- Possibly new file for OrderIso coherence lemmas (Track A, Phase A2 design decision)
- `specs/155_reynolds_pipeline_activation/plans/28_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**If Track A (OrderIso bypass) fails at Phase A1** (type mismatch that cannot be bridged):
1. Track B becomes the sole path to sorry-free `bx_completeness`
2. Track B phases B1-B9 must all succeed for the GHR93 pipeline to be fully sorry-free
3. Estimated effort increases to 30-40+ hours with higher uncertainty on Phases B7-B9
4. The key risk becomes Phases B7/B8 (Lemma 10 and NF characterization), which have the highest uncertainty

**If Phase B2 determines atoms are infinite** (blocking Approach A):
1. Use Approach C (case-split) in Phase B3 -- this is fully viable and non-circular
2. The case-split closes S1/S2 and contributes to S3-S5 closure
3. The `Fintype (BoundedStaviFormula r)` infrastructure becomes a separate future task
4. S13 (NF characterization) may need alternative infrastructure beyond what the case-split provides

**If Phase B8 (NF characterization) is blocked**:
1. Track A already achieves sorry-free `bx_completeness` -- the project's primary goal is met
2. S13 and dependent S14 are documented as future work
3. The GHR93 formalization remains a valuable partial contribution (S1-S12 closed, S13-S14 open)
4. A dedicated research round on the 2-variable NF characterization may be needed

**General rollback**: All changes are committed after each phase. Git history enables rollback to any phase boundary.
