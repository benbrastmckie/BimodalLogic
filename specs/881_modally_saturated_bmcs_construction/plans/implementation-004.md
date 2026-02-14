# Implementation Plan: Task #881 (Version 4)

- **Task**: 881 - Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours
- **Dependencies**: None (builds on sorry-free RecursiveSeed from task 880)
- **Research Inputs**: research-009.md (team research v5: RecursiveSeed extension path)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the RecursiveSeed extension approach identified in research-009.md (team research v5). The key insight is that RecursiveSeed avoids the cross-sign problem by pre-placing ALL temporal witnesses BEFORE Lindenbaum extension. Rather than fixing blockers in DovetailingChain (which has fundamental architecture limitations), we extend the sorry-free RecursiveSeed infrastructure from task 880 to support modal saturation.

**Core Strategy**: Scale RecursiveSeed from single-formula processing to MCS-level construction. RecursiveSeed handles temporal coherence for one formula; we extend it to process ALL formulas in an MCS and produce IndexedMCSFamily structures with proper box_coherence.

### Research Integration

Reports integrated:
- research-009.md (v5): Team research confirming RecursiveSeed as recommended path
  - RecursiveSeed: 0 sorries, avoids cross-sign by design
  - DovetailingChain: BLOCKED (4 sorries, fundamental architecture limitation)
  - UnifiedChain: 7 sorries, shifts blocker but not solved

Key findings:
- RecursiveSeed pre-places witnesses before Lindenbaum, avoiding cross-sign derivation
- Gap to bridge: single-formula ModelSeed to multi-formula IndexedMCSFamily
- Need: witness families for ALL neg(Box phi), not just one formula

## Goals & Non-Goals

**Goals**:
- Extend RecursiveSeed to process entire MCS content (all formulas, not just one)
- Create infrastructure to build IndexedMCSFamily from extended ModelSeed
- Implement modal saturation by creating witness families for each Diamond formula
- Build saturation closure (process Diamond formulas in witness families)
- Eliminate the `fully_saturated_bmcs_exists_int` sorry
- Achieve zero new axioms and zero new sorries on critical path

**Non-Goals**:
- Fixing DovetailingChain.lean sorries (fundamental architecture limitation)
- Fixing UnifiedChain.lean sorries (alternative approach, not used)
- Generic D support beyond Int (Int is sufficient for completeness)
- Restructuring ModalSaturation.lean definition (already correct)
- Changing constantWitnessFamily semantics (we extend, not replace)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-formula seed consistency harder than single-formula | High | Medium | Leverage existing `diamond_box_interaction` lemma and `SeedConsistent` proofs |
| F/P witness enumeration complexity | High | Medium | Use dovetailing (Nat.unpair) over (time, formula) pairs as in plan v3 |
| Box_coherence across non-constant families | Medium | Medium | Include BoxContent in each witness seed, proven by S5 axiom 5 |
| Saturation closure may not terminate | Medium | Low | Use Zorn's lemma pattern from SaturatedConstruction.lean |
| IndexedMCSFamily bridge more complex than expected | Medium | Medium | Keep bridge simple: apply Lindenbaum per (family, time), compose |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:842) - main target
- 4 sorries in DovetailingChain.lean (BLOCKED, not addressed by this plan)
- 7 sorries in UnifiedChain.lean (alternative approach, not used)
- 1 sorry in `temporal_coherent_family_exists` generic D (not on critical path)

### Expected Resolution
- Phase 4 eliminates `fully_saturated_bmcs_exists_int` sorry by wiring RecursiveSeed to modal saturation

### New Sorries
- None expected. RecursiveSeed infrastructure is already sorry-free (task 880).

### Remaining Debt
After this implementation:
- 0 sorries on critical path (`fully_saturated_bmcs_exists_int` becomes sorry-free)
- 4 sorries in DovetailingChain.lean remain (dead architecture)
- 7 sorries in UnifiedChain.lean remain (unused alternative)
- `temporal_coherent_family_exists` generic D sorry remains (not on critical path)

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in TemporalCoherentConstruction.lean: `fully_saturated_bmcs_exists` (deprecated)
- 1 axiom in Construction.lean: `singleFamily_modal_backward_axiom` (separate issue)

### Expected Resolution
- Phase 4 eliminates `fully_saturated_bmcs_exists_int` sorry, enabling deprecated axiom removal
- No axioms used in this construction

### New Axioms
- None. NEVER introduce new axioms. All gaps resolved through structural proofs.

### Remaining Debt
After this implementation:
- 0 axioms for fully saturated BMCS construction (Int case)
- `singleFamily_modal_backward_axiom` remains (separate single-family path)

## Implementation Phases

### Phase 1: Multi-Formula Seed Builder [NOT STARTED]

- **Dependencies:** None
- **Goal:** Extend RecursiveSeed to process ALL formulas in a seed set (evaluation MCS content)

**Analysis**:
Currently `buildSeed` processes a single formula. For modal saturation, we need to process all formulas in the evaluation MCS and pre-place witnesses for ALL neg(Box phi) formulas.

**Key Design**:
```lean
/-- Build seed for an entire set of formulas (MCS content). -/
def buildMultiFormulaSeed (formulas : Set Formula) (h_finite : formulas.Finite) : ModelSeed :=
  h_finite.toFinset.fold ModelSeed.union ModelSeed.empty
    (fun phi => buildSeed phi)

/-- Alternatively, fold over formulas in sequence. -/
def buildSeedForList (formulas : List Formula) : ModelSeed :=
  formulas.foldl (fun seed phi =>
    buildSeedAux phi 0 0 seed) (ModelSeed.empty)
```

**Tasks**:
- [ ] Define `buildSeedForMCS`: Takes MCS content and builds combined ModelSeed
- [ ] Prove `buildSeedForMCS_consistent`: Combined seed preserves consistency
- [ ] Prove `buildSeedForMCS_contains_all`: Each input formula appears at (0, 0)
- [ ] Prove `buildSeedForMCS_preserves_boxcontent`: Box phi propagation preserved
- [ ] Test with example MCS content

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add multi-formula builders

**Verification**:
- `lake build` succeeds
- `buildSeedForMCS_consistent` compiles without sorry
- Combined seed contains all input formulas at initial position

---

### Phase 2: Seed to IndexedMCSFamily Bridge [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Convert ModelSeed to IndexedMCSFamily via Lindenbaum extension at each position

**Analysis**:
ModelSeed provides sets of formulas at (family, time) positions. To get IndexedMCSFamily, we apply Lindenbaum's lemma at each position to extend these sets to MCS.

**Key Design**:
```lean
/-- Convert a model seed to an IndexedMCSFamily by applying Lindenbaum at each position. -/
noncomputable def seedToIndexedFamily (seed : ModelSeed)
    (h_cons : SeedConsistent seed) : IndexedMCSFamily Int :=
  { mcs := fun t => extendToMCS (seed.getFormulas 0 t) (h_cons 0 t)
    is_mcs := fun t => extendToMCS_is_mcs _ _
    forward_G := ... -- From seed structure
    backward_H := ... -- From seed structure
  }
```

**Tasks**:
- [ ] Define `seedToIndexedFamily`: ModelSeed -> IndexedMCSFamily Int
- [ ] Prove `seedToIndexedFamily_preserves_formulas`: Seed formulas preserved
- [ ] Prove `seedToIndexedFamily_forward_G`: G phi propagation from seed carries to family
- [ ] Prove `seedToIndexedFamily_backward_H`: H phi propagation from seed carries to family
- [ ] Prove `seedToIndexedFamily_forward_F`: F phi witness from seed exists in family
- [ ] Prove `seedToIndexedFamily_backward_P`: P phi witness from seed exists in family

**Key Insight**:
RecursiveSeed pre-places ALL witnesses. The G/H properties follow from Lindenbaum preserving the seed formulas (which include propagated G/H content). The F/P properties follow from the witness times being in the seed.

**Timing**: 3-4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/SeedToFamily.lean`

**Files to modify**:
- `Theories/Bimodal.lean` - Add import

**Verification**:
- `lake build` succeeds
- `seedToIndexedFamily` compiles with temporal coherence proofs
- Forward/backward G/H/F/P all proven from seed structure

---

### Phase 3: Modal Witness Family Builder [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Build witness families for Diamond formulas using RecursiveSeed approach

**Analysis**:
For each Diamond psi = neg(Box(neg psi)) in the evaluation MCS, we need a witness family where psi holds. The key is to include BoxContent from existing families in the witness seed.

**Key Design**:
```lean
/-- Build a witness family for Diamond psi, including BoxContent for box_coherence. -/
noncomputable def buildModalWitnessFamily
    (psi : Formula)
    (BoxContent : Set Formula)
    (h_cons : SetConsistent ({psi} ∪ BoxContent)) : IndexedMCSFamily Int :=
  let seed := buildSeed psi  -- Start with psi
  let seedWithBox := seed.addBoxContent BoxContent  -- Add BoxContent at all positions
  seedToIndexedFamily seedWithBox (by ... prove consistency ...)
```

**Tasks**:
- [ ] Define `ModelSeed.addBoxContent`: Add BoxContent to all existing positions
- [ ] Prove `addBoxContent_preserves_consistent`: Adding box formulas maintains consistency
- [ ] Define `buildModalWitnessFamily`: Create witness family with BoxContent
- [ ] Prove `buildModalWitnessFamily_contains_psi`: psi in witness family at time 0
- [ ] Prove `buildModalWitnessFamily_box_coherent`: BoxContent preserved across all times
- [ ] Prove `buildModalWitnessFamily_temporally_coherent`: G/H/F/P properties hold

**Key Insight**:
BoxContent consists of Box phi formulas from existing families. By S5 axiom 5 (neg(Box phi) -> Box(neg(Box phi))), if neg(Box psi) is in the evaluation MCS, adding Box formulas to the witness seed is consistent with having psi (the witness).

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SeedToFamily.lean` - Add witness builder

**Verification**:
- `lake build` succeeds
- Witness family contains psi and BoxContent
- Temporal coherence proven for witness family

---

### Phase 4: Modal Saturation via RecursiveSeed [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Implement saturation closure and eliminate the BMCS existence sorry

**Analysis**:
Saturation requires: for every Diamond psi in any family's MCS, there exists a witness family. We use Zorn's lemma (pattern from SaturatedConstruction.lean) with the witness builder from Phase 3.

**Key Design**:
```lean
/-- Saturate a family collection by adding witnesses via RecursiveSeed. -/
theorem exists_saturated_extension_recursive
    (eval_fam : IndexedMCSFamily Int)
    (h_eval_coh : TemporallyCoherent eval_fam) :
    ∃ (B : BMCS Int),
      eval_fam ∈ B.families ∧
      B.temporally_coherent ∧
      is_modally_saturated B := by
  -- Apply Zorn to family collections ordered by inclusion
  -- Use buildModalWitnessFamily to extend non-saturated collections
  ...
```

**Tasks**:
- [ ] Define `FamilyCollection`: Set of IndexedMCSFamily Int with eval_family
- [ ] Define `isSaturatedCollection`: Modal saturation predicate for collection
- [ ] Prove `witness_extends_collection`: Adding witness family preserves properties
- [ ] Apply Zorn's lemma to find maximal saturated collection
- [ ] Prove `maximal_is_saturated`: Maximal collection satisfies is_modally_saturated
- [ ] Define `exists_saturated_bmcs_recursive`: Main existence theorem
- [ ] Replace `fully_saturated_bmcs_exists_int` sorry with recursive construction
- [ ] Update `construct_saturated_bmcs_int` to use new theorem
- [ ] Verify completeness theorems still compile

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Wire recursive construction
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add recursive variant

**Verification**:
- `lake build` succeeds
- `fully_saturated_bmcs_exists_int` is sorry-free
- `grep -r "sorry" TemporalCoherentConstruction.lean | grep -v "temporal_coherent_family_exists "` returns only generic D sorry
- Completeness theorems compile

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] After Phase 1: `buildSeedForMCS_consistent` proven without sorry
- [ ] After Phase 2: `seedToIndexedFamily` produces valid IndexedMCSFamily
- [ ] After Phase 3: Witness families satisfy temporal coherence and contain witnesses
- [ ] After Phase 4: `fully_saturated_bmcs_exists_int` is sorry-free
- [ ] `grep -c "sorry" RecursiveSeed.lean` shows 0 sorries
- [ ] Completeness.lean theorems remain valid
- [ ] TruthLemma.lean continues to compile

## Artifacts & Outputs

- `plans/implementation-004.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- New Lean file:
  - `Theories/Bimodal/Metalogic/Bundle/SeedToFamily.lean`
- Modified Lean files:
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (Phase 1: multi-formula)
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (Phase 4: wire)
  - `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` (Phase 4: recursive variant)
  - `Theories/Bimodal.lean` (imports)

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation commit
2. Document blocking issues in error report
3. Consider scope restriction fallback (eval-only temporal coherence)

If multi-formula seed consistency fails:
1. Investigate whether formulas need ordering or prioritization
2. Consider processing formulas one-by-one with incremental consistency proofs
3. Fall back to subset of formulas if full MCS processing blocked

If Zorn saturation closure fails:
1. Try finite iteration bound based on formula complexity
2. Consider ordinal-indexed iteration
3. Document mathematical gap for future work

If time budget exceeded:
1. Mark phase [PARTIAL] with clear resume point
2. Commit partial progress
3. Document remaining work
