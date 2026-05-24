# Implementation Plan: Reynolds Pipeline Activation (v27)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 12-18 hours (OrderIso bypass path); 50-70 hours (full GHR93 pipeline, deferred)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**: reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/29_literature-alignment.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md
- **Artifacts**: plans/27_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan replaces the chronicle fallback in Transfer.lean with a sorry-free countermodel construction using the OrderIso bypass strategy (report 30, critical-path-wiring). The key insight from report 30 is that the EFGames/ExpressivenessGeneral sorry sites are ORPHANED from the actual bx_completeness critical path. The sole root sorry is `succ_cofinal` in ChronicleToCountermodel.lean, which propagates through `succ_embed_surjective` to the TC/FUC coherence conditions. The OrderIso from `chronicle_is_good` (sorry-free) provides a direct bijection between Z and the chronicle domain, bypassing `succ_embed` entirely. This achieves the definition of done (no sorryAx in `bx_completeness`, lake build passes) without requiring the full GHR93 game-theoretic pipeline.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback).

### Research Integration

Eight research reports were integrated into this plan:

| Report | Key Finding | Impact on Plan |
|--------|-------------|----------------|
| 30_critical-path-wiring | EFGames sorry sites are ORPHANED; OrderIso bypass needs ~310-510 lines | Drives the bypass strategy (Phases 1-4) |
| 30_forward-inventory | 22 sorries across 5 files; 14 on critical path of FULL pipeline | Confirms bypass avoids 14 critical-path sorries |
| 35_phase1-blocker-prior-art | Full GHR93 pipeline estimated at 40-60 hours remaining | Motivates bypass over full pipeline |
| 29_literature-alignment | Formula C vs predicate cont_holds divergence is root cause of Claim 1 sorries | Relevant only for full pipeline (Phase 6) |
| 40_literature-crossref | 28 total sorries; Claim 1 cluster (7 sorries) is critical divergence | Maps which sorries the bypass avoids |
| 30_session-audit | 2,978 net new lines; 21 new theorems; build passes | Confirms stable codebase for bypass work |
| 29_d-consistency-architecture | d_consistency with d=a_bwd(n) is UNPROVABLE; infimum needed | Relevant only for full pipeline |
| 30_mechanical-strategy | K^-(negD) adaptation strategy for multi-round games | Relevant only for full pipeline |

### Prior Plan Reference

The prior plan (v25) structured work around the full GHR93 pipeline with 11 phases (Phases 1-11). Key lessons:

- **Effort calibration**: Phase 1 (Claim 1) and Phase 3 (Cases III/IV) were repeatedly blocked by the formula materialization circularity (reports 38, 39). The 40-60 hour estimate was validated by report 35.
- **Validated approaches**: Phase 2 (Lemma 9) and Phase 10 (Transfer.lean wiring) were completed. The OrderIso from `chronicle_is_good` is confirmed sorry-free.
- **Risks encountered**: The `h_d_unique` false universal claim wasted significant effort. The cont_holds predicate-vs-formula divergence is the single most significant architectural issue.
- **Completed work**: 12 sorry sites closed (including rank_down, gap infimum cases, decomposition_implies_game). Build passes with 1649 jobs.

The prior plan's Phase 10 (Transfer.lean wiring) is complete but the full pipeline (Phases 1, 3, 4, 5, 6A, 6B, 8, 11) requires 40-60 more hours. This revised plan takes the bypass path instead.

### Roadmap Alignment

- Advances "Reynolds pipeline activation" and "sorry-free discrete completeness" roadmap items
- Achieves sorry-free `bx_completeness` without closing all GHR93 sorry sites
- The full GHR93 pipeline (Phases 5-6) can be pursued as future work for mathematical completeness

## Goals & Non-Goals

**Goals**:
- Achieve sorry-free `bx_completeness` via OrderIso bypass of `succ_cofinal`
- Replace chronicle fallback in `countermodel_discrete` with OrderIso-based construction
- Prove TC/FUC coherence conditions using OrderIso from `chronicle_is_good` instead of `succ_embed`
- Wire `countermodel_discrete_enriched` to `countermodel_discrete` (closing Completeness.lean:227 sorry)
- Verify `#print axioms bx_completeness` shows no `sorryAx`

**Non-Goals**:
- Closing the 11 ExpressivenessGeneral.lean sorry sites (GHR93 game-theoretic pipeline)
- Closing the 1 EFGames.lean sorry site (`nf_characterizable_by_stavi`)
- Closing the TruthLemma.lean sorry sites (non-critical-path)
- Closing the OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- Closing `no_gaps_discrete` in IntegerModel.lean (not on bypass critical path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OrderIso type mismatch between chronicle domain and TaskFrame Int | H | M | Report 30 confirms `chronicle_is_good` gives OrderIso to Z; verify type compatibility before heavy coding |
| TC coherence proof via OrderIso more complex than estimated | M | M | Start with TC (simpler direction); if blocked, analyze the specific obligation types |
| FUC coherence proof requires forward Until witnesses not available via OrderIso | H | L | The OrderIso is surjective by construction; forward witnesses in Z map directly to chronicle domain |
| `countermodel_discrete_enriched` type signature incompatible with `countermodel_discrete` | M | M | Read both signatures first; adapt existential instantiation as needed |
| Build regression after wiring changes | M | L | Run `lake build` after each phase; commit working states |
| Remaining sorry sites in non-bypassed files cause unexpected sorryAx propagation | H | L | Use `#print axioms` after Phase 3 to verify clean axiom set before final wiring |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are fully sequential because each builds on the previous phase's output.

---

### Phase 1: Analyze Critical Path and Verify Bypass Feasibility [NOT STARTED]

**Goal**: Confirm that the OrderIso bypass is viable by tracing the exact sorryAx propagation chain and verifying type compatibility between `chronicle_is_good`, `countermodel_discrete`, and `countermodel_discrete_enriched`.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` and trace every `sorryAx` to its source file and line
- [ ] Run `#print axioms chronicle_is_good` and confirm zero `sorryAx`
- [ ] Read `chronicle_is_good` signature and return type (OrderIso to what?)
- [ ] Read `countermodel_discrete` in Transfer.lean — identify its type signature, what it returns, and where it delegates to `dd_countermodel_chronicle_discrete`
- [ ] Read `countermodel_discrete_enriched` in Completeness.lean:227 — identify its type signature and what existential it must produce
- [ ] Read `dd_countermodel_chronicle_discrete` in ChronicleToCountermodel.lean — identify which sub-lemmas carry `sorryAx` (expected: `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`)
- [ ] Read `succ_embed_surjective` and `succ_cofinal` — confirm these are the root sorry sites
- [ ] Document type compatibility findings: can `chronicle_is_good`'s OrderIso produce a `TaskFrame Int` that matches what `countermodel_discrete` needs?
- [ ] Identify the exact coherence obligations (TC, BUC, FUC) that currently use `succ_embed_surjective` and would need OrderIso-based alternatives

**Timing**: 1-2 hours

**Depends on**: none

**Files to modify**:
- None (analysis only)

**Verification**:
- Written notes on type compatibility and coherence obligation signatures
- Clear yes/no on bypass feasibility
- If no: document the specific type mismatch and abort plan (fall back to full pipeline)

---

### Phase 2: OrderIso-Based Coherence Proofs [NOT STARTED]

**Goal**: Prove TC and FUC coherence conditions using the OrderIso from `chronicle_is_good` instead of `succ_embed_surjective`, eliminating `succ_cofinal` from the dependency chain.

**Tasks**:
- [ ] Create a new section or file (e.g., `OrderIsoCherence.lean` or inline in Transfer.lean) for the OrderIso-based coherence proofs
- [ ] Extract the OrderIso from `chronicle_is_good` — this gives a bijection between Z (or a Z-like structure) and the chronicle's limit domain
- [ ] Prove TC (temporal coherence) for the OrderIso-based construction: for each MCS in the chronicle family, the forward/backward temporal content is preserved through the OrderIso mapping
- [ ] Prove BUC (backward Until coherence) — this should follow from the existing sorry-free `cantor_bfmcs_discrete_restricted_buc` since BUC does not use `succ_embed_surjective`
- [ ] Prove FUC (forward Until coherence) for the OrderIso-based construction: Until witnesses in Z map through the OrderIso to chronicle domain witnesses
- [ ] Verify that the OrderIso-based TC/FUC proofs do NOT reference `succ_embed`, `succ_embed_surjective`, or `succ_cofinal`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 4-6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/Transfer.lean` or new file — OrderIso coherence proofs (~200-300 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — may need to extract helper lemmas

**Verification**:
- `#print axioms` on the new TC/FUC lemmas shows no `sorryAx`
- `lake build` passes

---

### Phase 3: Replace Chronicle Fallback in countermodel_discrete [NOT STARTED]

**Goal**: Replace the `dd_countermodel_chronicle_discrete` delegation in `countermodel_discrete` with the OrderIso-based construction, eliminating `succ_cofinal` from the `bx_completeness` critical path.

**Tasks**:
- [ ] Modify `countermodel_discrete` in Transfer.lean to use the OrderIso-based construction instead of delegating to `dd_countermodel_chronicle_discrete`
- [ ] The new construction should: (1) use the chronicle's MCS family (sorry-free), (2) use `chronicle_is_good` to get the OrderIso, (3) build a `TaskFrame Int` via the OrderIso, (4) use the OrderIso-based TC/FUC from Phase 2
- [ ] Verify that `fully_restricted_parametric_completeness_from_neg_membership` (sorry-free) still works with the new construction
- [ ] Verify that `cantor_bfmcs_discrete` (sorry-free) still works
- [ ] Run `#print axioms countermodel_discrete` and confirm no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/Transfer.lean` — replace delegation (~100-200 lines)

**Verification**:
- `#print axioms countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 4: Wire countermodel_discrete_enriched [NOT STARTED]

**Goal**: Close the sorry at Completeness.lean:227 by wiring `countermodel_discrete_enriched` to `countermodel_discrete`.

**Tasks**:
- [ ] Read the type signature of `countermodel_discrete_enriched` — it should return `exists (F : TaskFrame Int), ...` (enriched version)
- [ ] Read the type signature of `countermodel_discrete` — it returns `exists (D : Type), ...` (generic version)
- [ ] Replace the `sorry` at line 227 with a call to `countermodel_discrete`, specializing D = Int from the existential
- [ ] Handle any type adaptation between the enriched and generic existential forms
- [ ] Run `#print axioms countermodel_discrete_enriched` and confirm no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 1-2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — wire enriched to discrete (~10-30 lines)

**Verification**:
- `#print axioms countermodel_discrete_enriched` shows no `sorryAx`
- `lake build` passes

---

### Phase 5: Verify bx_completeness Axiom Cleanliness [NOT STARTED]

**Goal**: Confirm that `bx_completeness` (aka `completeness_discrete`) has no `sorryAx` and that the definition of done is met.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` (or `completeness_discrete`, whichever is the canonical name)
- [ ] Confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Verify no `sorryAx` appears anywhere in the output
- [ ] Run `lake build` — confirm zero errors
- [ ] Search for any `axiom` declarations in `Theories/Bimodal/Metalogic/WeakCanonical/` — confirm none exist (or only standard ones)
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback

**Timing**: 0.5-1 hour

**Depends on**: 4

**Files to modify**:
- None (verification only)

**Verification**:
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes with zero errors
- No `axiom` declarations in WeakCanonical/
- Definition of done is met

---

### Phase 6: Full GHR93 Pipeline (Deferred — Future Work) [NOT STARTED]

**Goal**: Document the remaining GHR93 work as future tasks, not blocking the current definition of done. This phase is NOT required for sorry-free `bx_completeness` but would close all 14 critical-path sorry sites for mathematical completeness.

**Tasks**:
- [ ] Document remaining sorry inventory (14 critical-path sorries in ExpressivenessGeneral.lean, EFGames.lean, IntegerModel.lean)
- [ ] Categorize by attack order (from report 30_forward-inventory):
  - Tier 1 (closable now): S3, S5, S8 — mechanical index adaptations
  - Tier 2 (closable with effort): S1, S6, S7, S9, S10 — careful construction
  - Tier 3 (need new infrastructure): S2, S4 — formula materialization (report 29_literature-alignment Approach A)
  - Tier 4 (need new theorems): S11, S12, S13, S14 — Lemma 9, Lemma 10, full GHR93, Theorem 5
- [ ] Create task(s) for the full GHR93 pipeline work if desired
- [ ] Update plan status to reflect bypass completion

**Timing**: 0.5-1 hour

**Depends on**: 5

**Files to modify**:
- This plan file (status update)

**Verification**:
- Clear documentation of remaining work
- Decision on whether to pursue full pipeline as a separate task

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No `sorryAx` in the axiom output
- [ ] No `axiom` declarations in `Theories/Bimodal/Metalogic/WeakCanonical/`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)
- [ ] OrderIso-based coherence proofs are individually sorry-free (`#print axioms` on each)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/Transfer.lean` — OrderIso-based countermodel construction replacing chronicle fallback
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — `countermodel_discrete_enriched` wired to `countermodel_discrete`
- Possibly a new file for OrderIso coherence lemmas (depending on Phase 2 design decisions)
- `specs/155_reynolds_pipeline_activation/plans/27_reynolds-pipeline-plan.md` — this plan

## Rollback/Contingency

If the OrderIso bypass proves infeasible (Phase 1 identifies a type mismatch that cannot be bridged):

1. **Preserve all bypass work** in a separate branch or commented section
2. **Fall back to the full GHR93 pipeline** per the prior plan (v25), starting with Phase 1 (infimum construction + Claim 1)
3. **Estimated fallback effort**: 40-60 hours (report 35)
4. **Key risk in fallback**: The formula materialization circularity (reports 38, 39) blocks 7 of the 14 critical-path sorries. Report 29 (literature-alignment) identifies Approach A (direct StaviFormula enumeration, ~200-300 lines) as the mathematically correct fix.

The bypass approach is lower risk because it avoids the formula materialization circularity entirely — it does not need any of the GHR93 game-theoretic machinery for the critical path.
