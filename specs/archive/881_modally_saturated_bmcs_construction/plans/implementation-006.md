# Implementation Plan: Task #881 (Version 6)

- **Task**: 881 - Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours (after task 887 completes)
- **Dependencies**: Task 887 (creates FinalConstruction.lean to resolve circular import)
- **Research Inputs**: research-011.md (circular import analysis, Option C recommendation)
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan depends on task 887 completing first. Task 887 will create `FinalConstruction.lean` to resolve the circular import between `SaturatedConstruction.lean` and `TemporalCoherentConstruction.lean`. Once that is in place, this plan wires the existing `seedToConstantMCS` infrastructure to the saturation machinery and investigates whether the truth lemma can be satisfied without requiring temporal coherence for witness families.

**Core Strategy**: After task 887 completes:
1. Wire `seedToConstantMCS` to `FinalConstruction.lean`
2. Analyze truth lemma to verify Option C viability (only eval_family needs temporal coherence)
3. Implement `fully_saturated_bmcs_exists_int` proof using the wired infrastructure
4. If Option C fails, document as tolerable technical debt for now

### Research Integration

Reports integrated:
- research-011.md (v11): Post-implementation review after v5 partial completion
  - Phase 1 complete: `seedToConstantMCS` infrastructure working (1 auxiliary sorry)
  - Circular import resolved by task 887: `FinalConstruction.lean` will import both files
  - Deeper issue: Witness families need temporal coherence, but regular Lindenbaum doesn't provide it
  - Option C recommended: Restructure truth lemma to only require eval_family temporal coherence

Key findings from implementation-005.md progress:
- `seedFormulasAtZero`, `seedToConstantMCS`, and related lemmas are complete
- `buildSeed_hasPosition_zero` has 1 auxiliary sorry (non-blocking)
- Architecture decision: Changed to constant MCS approach with `constantIndexedMCSFamily` wrapper

## Goals & Non-Goals

**Goals**:
- Wait for task 887 to complete (blocking dependency)
- Wire `seedToConstantMCS` output to `FinalConstruction.lean` infrastructure
- Analyze truth lemma temporal requirements (verify Option C is viable)
- If Option C viable: Implement `fully_saturated_bmcs_exists_int` proof
- If Option C fails: Document as tolerable technical debt with clear justification

**Non-Goals**:
- Implementing task 887 (separate task, independent implementation)
- Fixing `buildSeedForList_propagates_box` (UNPROVABLE, not needed)
- Proving witness families are temporally coherent (unlikely achievable with current infrastructure)
- Fixing DovetailingChain.lean sorries (separate architecture, not used)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 887 delayed | High | Low | Task 887 is straightforward file creation; can proceed with other tasks |
| Option C not viable (truth lemma requires witness temporal coherence) | High | Medium | Fall back to Option D: document as tolerable technical debt |
| Wiring to FinalConstruction.lean more complex than expected | Medium | Low | FinalConstruction.lean is designed specifically to resolve this issue |
| Constant family temporal coherence harder than expected | Medium | Medium | T-axioms in S5 should handle this automatically |

## Sorry Characterization

### Pre-existing Sorries (Non-blocking)
- `buildSeed_hasPosition_zero` (RecursiveSeed.lean ~line 5993) - auxiliary lemma, non-blocking
- `buildSeedForList_*` sorries (3 total) - deprecated architecture, not on critical path

### Target Sorry
- `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:842)

### Expected Resolution
- Phase 3 eliminates the target sorry if Option C is viable
- Phase 4 documents as tolerable technical debt if Option C fails

### New Sorries
- None expected if Option C succeeds
- None introduced regardless (tolerable debt is documented, not new sorry)

## Axiom Characterization

### Pre-existing Axioms
- `fully_saturated_bmcs_exists` (TemporalCoherentConstruction.lean) - deprecated

### Expected Resolution
- Phase 3 enables deprecation of the axiom if Option C succeeds
- Phase 4 documents axiom as tolerable if Option C fails

### New Axioms
- None. NEVER introduce new axioms.

## Implementation Phases

### Phase 0: Wait for Task 887 [NOT STARTED]

- **Dependencies**: None
- **Goal**: Task 887 creates FinalConstruction.lean, resolving the circular import

**Tasks**:
- [ ] Task 887 completed (creates FinalConstruction.lean)
- [ ] FinalConstruction.lean imports both SaturatedConstruction.lean and TemporalCoherentConstruction.lean
- [ ] Verify `lake build` succeeds with new file structure

**Timing**: Dependent on task 887 (estimated 2-3 hours for task 887)

**Verification**:
- [ ] FinalConstruction.lean exists and compiles
- [ ] No circular import errors

---

### Phase 1: Wire seedToConstantMCS to FinalConstruction.lean [NOT STARTED]

- **Dependencies**: Phase 0
- **Goal**: Connect existing `seedToConstantMCS` infrastructure to saturation machinery via FinalConstruction.lean

**Analysis**:
Phase 1 of implementation-005 built `seedToConstantMCS` which produces an MCS from a ModelSeed. This MCS can be wrapped in `constantIndexedMCSFamily` (from Construction.lean) to get an IndexedMCSFamily. We need to wire this to `initialFamilyCollection` and `exists_fullySaturated_extension` via FinalConstruction.lean.

**Key Design**:
```lean
-- In FinalConstruction.lean
/-- Build a saturated FamilyCollection from a single formula using RecursiveSeed. -/
noncomputable def saturatedCollectionFromSeed (phi : Formula)
    (h_cons : SetConsistent {phi}) : FamilyCollection Int :=
  let seed := buildSeed phi
  let mcs := seedToConstantMCS seed (buildSeed_seedFormulasAtZero_consistent phi h_cons)
  let eval_fam := constantIndexedMCSFamily mcs (seedToConstantMCS_is_mcs seed _)
  let C := initialFamilyCollection phi eval_fam
  exists_fullySaturated_extension C ...
```

**Tasks**:
- [ ] Add import of RecursiveSeed.lean to FinalConstruction.lean
- [ ] Define `saturatedCollectionFromSeed` bridging seed to FamilyCollection
- [ ] Prove seed formula (phi) preserved in eval_family after saturation
- [ ] Prove modal saturation from `isFullySaturated`

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` (created by task 887)

**Verification**:
- [ ] `lake build` succeeds
- [ ] `saturatedCollectionFromSeed` compiles without sorry
- [ ] phi ∈ eval_family.mcs 0 proven

---

### Phase 2: Analyze Truth Lemma Temporal Requirements [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Verify Option C is viable by analyzing where temporal coherence is actually used

**Analysis**:
Research-011 identified that the truth lemma only evaluates at eval_family positions. Modal witness families are used for Box backward reasoning via `modal_backward`, which is proven via saturation alone (not temporal coherence). If this analysis is correct, we can construct a BMCS that only requires eval_family temporal coherence.

**Tasks**:
- [ ] Trace truth lemma's use of `temporally_coherent` property
- [ ] Identify which families are queried for `forward_F` and `backward_P`
- [ ] Verify modal_backward only uses modal saturation (not temporal coherence of witnesses)
- [ ] Document findings: Does truth lemma work with only eval_family temporal coherence?

**Decision Point**:
- If YES (Option C viable): Proceed to Phase 3
- If NO (Option C not viable): Proceed to Phase 4

**Timing**: 1-2 hours

**Files to analyze**:
- `Theories/Bimodal/Metalogic/TruthLemma.lean` - Find `temporally_coherent` usage
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - Find property definitions

**Verification**:
- [ ] Analysis documented in handoff or progress notes
- [ ] Clear decision: Option C viable or not

---

### Phase 3: Implement fully_saturated_bmcs_exists_int Proof [NOT STARTED]

- **Dependencies**: Phase 2 (Option C must be viable)
- **Goal**: Replace sorry in `fully_saturated_bmcs_exists_int` with working proof

**Analysis**:
If Option C is viable, we can prove `fully_saturated_bmcs_exists_int` by:
1. Using `saturatedCollectionFromSeed` to build saturated FamilyCollection
2. Converting to BMCS via `FamilyCollection.toBMCS`
3. Proving eval_family temporal coherence (from constantIndexedMCSFamily + T-axioms)
4. Proving modal saturation (from isFullySaturated)

**Key Design**:
```lean
theorem fully_saturated_bmcs_exists_int (Gamma : List Formula)
    (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧
      B.temporally_coherent ∧
      is_modally_saturated B := by
  -- Use conjunction of Gamma as single formula
  let phi := conjunction Gamma
  have h_phi_cons : SetConsistent {phi} := conjunction_consistent h_cons
  -- Build saturated collection
  let C := saturatedCollectionFromSeed phi h_phi_cons
  let B := C.toBMCS ...
  -- Verify properties
  exact ⟨B, gamma_in_eval, eval_temporal_coherent, modal_saturated⟩
```

**Tasks**:
- [ ] Replace `fully_saturated_bmcs_exists_int` sorry with proof
- [ ] Prove Gamma formulas preserved (via conjunction and subset)
- [ ] Prove temporal coherence for eval_family (constant family + T-axioms)
- [ ] Prove modal saturation from isFullySaturated
- [ ] Update `construct_saturated_bmcs` if needed
- [ ] Verify completeness theorems still compile

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Replace sorry
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - Add supporting theorems

**Verification**:
- [ ] `lake build` succeeds
- [ ] `fully_saturated_bmcs_exists_int` compiles without sorry
- [ ] Completeness.lean theorems compile
- [ ] TruthLemma.lean continues to compile

---

### Phase 4: Document Technical Debt (if Option C fails) [NOT STARTED]

- **Dependencies**: Phase 2 (Option C must NOT be viable)
- **Goal**: Document the sorry as tolerable technical debt with clear justification

**Analysis**:
If Option C is not viable (truth lemma genuinely requires witness family temporal coherence), then the sorry represents a genuine mathematical gap. We document this clearly and focus on other work. This is acceptable for development but blocks publication readiness.

**Tasks**:
- [ ] Document findings in task summary: why Option C failed
- [ ] Add clear comment at `fully_saturated_bmcs_exists_int` explaining the gap
- [ ] Identify what would be needed to resolve (e.g., temporal Lindenbaum for witnesses)
- [ ] Update roadmap with "temporal coherence gap" as known limitation

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Add documentation comment
- Summary file documenting the technical debt

**Verification**:
- [ ] Documentation clearly explains the gap
- [ ] Path forward identified (even if not immediately achievable)

---

## Testing & Validation

- [ ] After Phase 0: Task 887 complete, FinalConstruction.lean exists
- [ ] After Phase 1: `saturatedCollectionFromSeed` compiles, phi preserved
- [ ] After Phase 2: Clear decision on Option C viability documented
- [ ] After Phase 3 (if taken): `fully_saturated_bmcs_exists_int` sorry-free
- [ ] After Phase 4 (if taken): Technical debt clearly documented
- [ ] Completeness.lean theorems remain valid throughout
- [ ] TruthLemma.lean continues to compile throughout

## Artifacts & Outputs

- `plans/implementation-006.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- `FinalConstruction.lean` (created by task 887, modified in Phase 1)
- Possibly: `handoffs/phase-2-analysis-YYYYMMDD.md` (Option C viability analysis)

## Rollback/Contingency

If implementation fails after Phase 1:
1. Git revert changes to FinalConstruction.lean
2. Document findings for future work
3. Task remains in PARTIAL state

If Phase 3 fails unexpectedly:
1. Switch to Phase 4 (document as technical debt)
2. No code rollback needed

If time budget exceeded:
1. Mark current phase [PARTIAL] with clear resume point
2. Commit partial progress
3. Document remaining work in handoff

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 001 | 2026-02-13 | Initial two-tier plan |
| 002 | 2026-02-13 | Unified Zorn approach |
| 003 | 2026-02-14 | Focus on existing 3 sorries via S5 BoxContent invariance |
| 004 | 2026-02-14 | RecursiveSeed extension for multi-formula seed building |
| 005 | 2026-02-16 | Option D: FamilyCollection architecture (abandons buildSeedForList) |
| 006 | 2026-02-16 | Dependency on task 887; Option C (truth lemma restructure) with fallback |
