# Implementation Plan: Natural Inclusion Refactor (Remove Cantor Iso)

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: 107 (completed)
- **Research Inputs**: reports/01_team-research.md, reports/02_team-research.md, reports/03_team-research.md
- **Artifacts**: plans/03_natural-inclusion-refactor.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/lean4.md
- **Type**: lean4

## Overview

The sole remaining sorry in the completeness proof sits at CE:3570 inside the `.density` branch. The dependency chain: sorry (SetConsistent g) --> limit_dom_dense --> DenselyOrdered LimitDomSubtype --> cantor_iso --> dd_countermodel_chronicle. Removing `.density` from the counterexample enum makes this sorry dead code. The Cantor isomorphism (bijection X ~= Q, requiring DenselyOrdered) is replaced by the natural inclusion X subset Q (injection, requiring nothing). An extension function `extended_f : Rat -> Set Formula` maps every rational to an MCS: domain rationals use limit_f directly; non-domain rationals use a Lindenbaum extension of the g_content from the enclosing interval. D = Rat as before; parametric infrastructure unchanged. Density-related code is archived to Boneyard/DenseChronicle/ for future dense variant reuse.

### Research Integration

Integrates findings from 3 rounds (12 teammates):
- Round 1: Identified sorry dependency chain, confirmed sorry is genuinely unprovable (Zorn on CUD not SDC)
- Round 2: Confirmed AddCommGroup D is load-bearing for MF/TF soundness; truth_at uses zero group ops; keep D=Rat
- Round 3: Confirmed C4a can create accumulation points (X may be mixed discrete/dense); natural inclusion handles all cases; density case cleanly separable

## Goals and Non-Goals

### Goals
- Eliminate the sorry at CE:3570 by removing the `.density` counterexample kind
- Replace Cantor isomorphism with natural inclusion X subset Q plus Lindenbaum extension
- Archive density-related code to Boneyard/DenseChronicle/ for future reuse
- Maintain D = Rat with existing parametric infrastructure completely unchanged
- Produce a sorry-free dd_countermodel_chronicle (and hence sorry-free bx_completeness)

### Non-Goals
- Proving X is discrete or embedding X into Z (X may be mixed; natural inclusion avoids this)
- Creating a new truth definition (bfmcs_truth_at) or dual semantics layer
- Modifying Completeness.lean theorem statements (signature unchanged)
- Changing TaskFrame, truth_at, valid, or parametric representation infrastructure

## Risks and Mitigations

- **Risk**: Extension coherence (forward_G, backward_H) for non-domain rationals may be difficult to prove.
  **Mitigation**: G(phi) in g_content of enclosing interval means G(phi) is in all enclosing domain MCSs. By limit_forward_G, phi propagates forward through domain points. The Lindenbaum extension inherits this. Proof mirrors limit_forward_G with one domain/non-domain case split.

- **Risk**: Forward Until/Since guard at non-domain rationals -- guard quantifies over ALL rationals.
  **Mitigation**: For non-domain r between domain t and witness s, psi is in limit_g(t,s) (from C5a). By C3 monotonicity, psi is in limit_g(a,b) for any sub-interval enclosing r. So psi is in g_content of r's enclosing interval, hence in extended_f(r).

- **Risk**: g_content consistency for Lindenbaum step.
  **Mitigation**: For adjacent domain pairs (no intermediate points), g_content = Set.univ (inconsistent), but no non-domain rational falls between adjacent domain points that are truly adjacent in Q -- there ARE rationals between them, and the guard is over D = Rat, not over X. So we always need the Lindenbaum extension. For non-adjacent domain pairs (intermediate domain points exist), g_content is a subset of an MCS, hence consistent.

- **Risk**: Large archival could introduce errors.
  **Mitigation**: Archive files are reference-only (not built). Phase 1 (archival) is isolated from functional changes.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Archive Density Code to Boneyard [COMPLETED]

**Goal**: Move all density-related code to Boneyard/DenseChronicle/ without changing active code.

**Tasks**:
- [x] Create directory Theories/Bimodal/Boneyard/DenseChronicle/
- [x] Create DenseCounterexampleElimination.lean containing:
  - eliminate_density_counterexample helper (CE:520-561)
  - .density branch of eliminate_potential_counterexample (CE:3535-3783)
  - Copy of PotentialCounterexampleKind with .density and EliminationResult with density_witness
  - Header: "Archived from base logic; restore for dense variant (F'T axiom)"
- [x] Create DenseLimitDomain.lean containing:
  - limit_dom_dense (ChronicleConstruction:746-776)
  - limitDomSubtype_denselyOrdered instance (ChronicleToCountermodel:96-106)
  - LimitAdjacent, no_adjacent_in_dense (ChronicleConstruction:975-987)
- [x] Create CantorIsoCountermodel.lean containing:
  - cantor_iso through dd_countermodel_chronicle (ChronicleToCountermodel:174-709)
  - Old imports (Mathlib.Order.CountableDenseLinearOrder, Mathlib.Data.Rat.Encodable)
- [x] Add non-building header comment to each archived file

**Timing**: 1 hour
**Depends on**: none

### Phase 2: Remove Density from CounterexampleElimination.lean [COMPLETED]

**Goal**: Remove .density variant, density_witness field, boilerplate discharges, and density branch.

**Tasks**:
- [x] Remove `| density` from PotentialCounterexampleKind (CE:575)
- [x] Remove density_witness field from EliminationResult (CE:638-640)
- [x] Remove ~13 boilerplate `density_witness := fun h => ...` lines from C4/C5 branches (18 removed)
- [x] Remove eliminate_density_counterexample helper (CE:520-561)
- [x] Remove entire `.density =>` branch (CE:3535-3783, containing the sorry)
- [x] Run `lake build ...CounterexampleElimination` to verify (build succeeds)
- [x] Fix exhaustiveness errors from enum change (none: match is exhaustive without density)

**Timing**: 1.5 hours
**Depends on**: none

### Phase 3: Remove Density Infrastructure from ChronicleConstruction.lean [COMPLETED]

**Goal**: Remove limit_dom_dense and related definitions.

**Tasks**:
- [x] Remove limit_dom_dense theorem (CC:746-776)
- [x] Remove LimitAdjacent definition (CC:975-976)
- [x] Remove no_adjacent_in_dense theorem (CC:982-987)
- [x] Remove "Limit Domain Density" section header (CC:724-734)
- [x] Clean up limit C2' section comments (CC:961-991)
- [x] Run `lake build ...ChronicleConstruction` to verify

**Timing**: 0.5 hours
**Depends on**: 1, 2

### Phase 4: Replace Cantor Iso with Natural Inclusion in ChronicleToCountermodel.lean [BLOCKED]

**Goal**: Replace Cantor iso pathway (~540 lines) with natural inclusion via extended_f (~350 new lines).

**Tasks**:

*Imports and header*:
- [x] Remove import Mathlib.Order.CountableDenseLinearOrder
- [x] Remove import Mathlib.Data.Rat.Encodable
- [x] Update module docstring

*Remove old code (lines 96-668)*:
- [x] Remove limitDomSubtype_denselyOrdered (96-106)
- [x] Remove cantor_iso, cantor_f, cantor_zero, cantor_f_at_zero, cantor_f_is_mcs (174-230)
- [x] Remove cantor_fmcs, shifted_cantor_fmcs, rooted_cantor_fmcs (231-320)
- [x] Remove box_stable_in_rooted_cantor_fmcs (321-368)
- [x] Remove cantor_bfmcs (369-420)
- [x] Remove cantor_bfmcs_restricted_tc/buc/fuc (421-668)

*Define extended_f (~80 lines)*:
- [ ] Define interval_g_content for non-domain rationals
- [ ] Prove interval_g_content_cud (closed under derivation)
- [ ] Prove interval_g_content_consistent for non-adjacent enclosing pairs
- [ ] Define extended_f using limit_f on domain, Lindenbaum extension off domain
- [ ] Prove extended_f_is_mcs, extended_f_at_zero, extended_f_agrees_on_dom

*Build inclusion_fmcs (~40 lines)*:
- [ ] Define inclusion_fmcs with forward_G/backward_H via domain/non-domain case analysis
- [ ] Define shifted_inclusion_fmcs, rooted_inclusion_fmcs
- [ ] Prove rooted_inclusion_fmcs_at_s

*Prove box stability and build inclusion_bfmcs (~90 lines)*:
- [ ] Prove box_stable_in_rooted_inclusion_fmcs
- [ ] Define inclusion_bfmcs with modal_forward/modal_backward

*Prove restricted coherence (~140 lines)*:
- [ ] Prove inclusion_bfmcs_restricted_tc (F/P resolution via limit_F/P_resolution)
- [ ] Prove inclusion_bfmcs_restricted_buc (backward Until/Since via C4 at domain points)
- [ ] Prove inclusion_bfmcs_restricted_fuc (forward Until/Since via C5 + C3 guard transfer)

*Rewrite dd_countermodel_chronicle (~20 lines)*:
- [ ] Replace cantor_bfmcs with inclusion_bfmcs
- [ ] Replace rooted_cantor_fmcs with rooted_inclusion_fmcs
- [ ] Replace coherence proof references
- [ ] Keep D = Rat in existential

- [ ] Run `lake build ...ChronicleToCountermodel` to verify

**Timing**: 5.5 hours
**Depends on**: 3

### Phase 5: Verify and Update Documentation [NOT STARTED]

**Goal**: Verify sorry-free compilation, update comments, run axiom audit.

**Tasks**:
- [ ] Run `lake build` (full project)
- [ ] Verify `#print axioms bx_completeness` shows no sorryAx
- [ ] Update Completeness.lean axiom audit comments
- [ ] Update dd_countermodel_chronicle docstring
- [ ] Run `lake build` again after comment updates
- [ ] Verify with lean_verify MCP tool on bx_completeness

**Timing**: 1.5 hours
**Depends on**: 4

## Testing and Validation

- [ ] `lake build ...CounterexampleElimination` after Phase 2
- [ ] `lake build ...ChronicleConstruction` after Phase 3
- [ ] `lake build ...ChronicleToCountermodel` after Phase 4
- [ ] `lake build` (full) after Phase 5
- [ ] `#print axioms bx_completeness` must show NO sorryAx
- [ ] `lean_verify` on bx_completeness
- [ ] Verify Boneyard files exist but are NOT imported by active modules

## Artifacts and Outputs

- plans/03_natural-inclusion-refactor.md (this plan)
- Theories/Bimodal/Boneyard/DenseChronicle/ (3 archived files)
- Modified: CounterexampleElimination.lean (~280 lines removed)
- Modified: ChronicleConstruction.lean (~45 lines removed)
- Modified: ChronicleToCountermodel.lean (~540 lines replaced with ~350 new lines)
- Modified: Completeness.lean (comment updates only)

## Rollback/Contingency

- Git commits at each phase boundary. Rollback any phase via git revert.
- Phase 1 (archival) creates new files only -- zero risk.
- Phases 2-3 (density removal) are mechanical removals with build verification.
- Phase 4 (core replacement) is highest risk. Fallbacks:
  - **Fallback A**: Use sorry temporarily for specific coherence lemmas, creating focused follow-up tasks (still eliminates CE:3570 sorry and its dependency chain).
  - **Fallback B**: Use root MCS (A) as default for non-domain rationals instead of g_content Lindenbaum. Simpler but requires proving forward_G/backward_H for root MCS fallback.
- Archived code in Boneyard/DenseChronicle/ preserves entire density pathway for restoration.
