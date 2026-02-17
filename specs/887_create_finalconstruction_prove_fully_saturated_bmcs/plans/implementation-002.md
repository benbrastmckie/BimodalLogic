# Implementation Plan: Task #887 (Version 2)

- **Task**: 887 - Create FinalConstruction.lean and prove fully_saturated_bmcs_exists_int
- **Status**: [PLANNED]
- **Effort**: 8-12 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/887_create_finalconstruction_prove_fully_saturated_bmcs/reports/research-001.md
  - specs/881_modally_saturated_bmcs_construction/reports/research-010.md (Options A and D)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL**: No technical debt is tolerable. This plan must produce a sorry-free and axiom-free proof of `fully_saturated_bmcs_exists_int`, or document a clear blocker requiring further research.

This plan combines:
1. **Option D architecture** (from research-010.md): Use `FamilyCollection` + `exists_fullySaturated_extension`
2. **Option B primary approach**: Prove `lindenbaum_preserves_temporal_saturation`
3. **Option A fallback**: Modify witness construction to include GContent/HContent
4. **Option C fallback**: Restructure truth lemma (if mathematically valid)

### Research Integration

From research-010.md (task 881):
- **Option A**: Modify `createNewFamily` to propagate BoxContent (can extend to GContent/HContent)
  - Pros: Clean fix at source, matches semantics
  - Cons: Must update 15+ theorems, 8-12 hours effort
  - Confidence: HIGH

- **Option D**: Use `FamilyCollection` + `exists_fullySaturated_extension`
  - `exists_fullySaturated_extension` is SORRY-FREE
  - Handles box_coherence as collection invariant
  - Remaining challenge: witness families need temporal coherence

From research-001.md (task 887):
- **Option B**: Prove regular Lindenbaum preserves temporal saturation
  - `constant_family_temporally_saturated_is_coherent` is already proven
  - Gap: witness families built with regular Lindenbaum, not temporal Lindenbaum

## Goals & Non-Goals

**Goals**:
- Create FinalConstruction.lean with SORRY-FREE `fully_saturated_bmcs_exists_int`
- ZERO new sorries in the entire construction path
- ZERO new axioms
- If primary approach fails, pursue fallbacks until sorry-free proof achieved
- If ALL approaches fail, document mathematical blocker (not accept debt)

**Non-Goals**:
- Accepting any sorries as "tolerable technical debt"
- Fixing unrelated sorries in other files (unless required for this proof)

## Approach Decision Tree

```
Start: fully_saturated_bmcs_exists_int
  |
  +-- Architecture: Option D (FamilyCollection + exists_fullySaturated_extension)
  |   Already sorry-free for modal saturation
  |
  +-- Challenge: Temporal coherence of witness families
      |
      +-- Approach 1 (Primary): Option B
      |   Prove lindenbaum_preserves_temporal_saturation
      |   |
      |   +-- If SUCCESS → Done
      |   +-- If FAIL → Try Approach 2
      |
      +-- Approach 2 (Fallback 1): Option A Extended
      |   Modify witness construction to include GContent/HContent in seed
      |   |
      |   +-- If SUCCESS → Done
      |   +-- If FAIL → Try Approach 3
      |
      +-- Approach 3 (Fallback 2): Option C
      |   Analyze if truth lemma only requires eval_family temporal coherence
      |   |
      |   +-- If VALID and SUCCESS → Done
      |   +-- If INVALID or FAIL → Document blocker
      |
      +-- No Success: Document mathematical blocker
          Create detailed report explaining:
          - Why each approach failed
          - What theorem/property would unblock
          - Research direction for future work
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Option B proof complex | H | M | Proceed to Option A fallback immediately |
| Option A requires many theorem updates | H | M | Systematic approach with helper lemmas |
| Option C mathematically invalid | H | M | Analyze truth lemma structure first |
| All options fail | H | L | Document as mathematical gap requiring new research |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:842) - TARGET
- 1 sorry in `fully_saturated_bmcs_exists_constructive` (SaturatedConstruction.lean:1367) - RELATED

### Expected Resolution
- Either Option B, A, or C will eliminate the target sorry
- If none succeed, we document WHY (not accept debt)

### New Sorries
- **NONE PERMITTED**. If any approach introduces a sorry, we try the next approach.

### Remaining Debt
After this implementation:
- 0 sorries in FinalConstruction.lean (mandatory)
- 0 new sorries anywhere (mandatory)

## Axiom Characterization

### Pre-existing Axioms
- `fully_saturated_bmcs_exists` in TemporalCoherentConstruction.lean (polymorphic version)

### Expected Resolution
- Phase 4 provides proven theorem for D = Int, eliminating need for axiom in Int case

### New Axioms
- **NONE PERMITTED**. If proof complexity requires gap, we try alternative approach.

## Implementation Phases

### Phase 1: FinalConstruction Setup + Option B Attempt [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create FinalConstruction.lean and attempt Option B (lindenbaum preserves temporal saturation)

**Tasks**:
- [ ] Create FinalConstruction.lean with imports from SaturatedConstruction and TemporalCoherentConstruction
- [ ] Define `TemporalForwardSaturated` for sets: `∀ φ, F(φ) ∈ S → φ ∈ S`
- [ ] Define `TemporalBackwardSaturated` for sets: `∀ φ, P(φ) ∈ S → φ ∈ S`
- [ ] Attempt `lindenbaum_step_preserves_forward_sat`: adding a consistent formula preserves forward saturation
- [ ] Attempt `lindenbaum_step_preserves_backward_sat`: adding a consistent formula preserves backward saturation
- [ ] Attempt `lindenbaum_preserves_temporal_saturation`: full Lindenbaum chain preserves temporal saturation

**Decision Point**:
- If all three lemmas proven WITHOUT sorry → Proceed to Phase 2 with Option B
- If any lemma cannot be proven → Proceed to Phase 2 with Option A

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - create new file

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.FinalConstruction` succeeds
- Document which lemmas succeeded/failed

---

### Phase 2: Witness Family Temporal Coherence [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Implement witness family temporal coherence using best available approach

**Branch A (if Option B succeeded in Phase 1)**:
- [ ] Apply `lindenbaum_preserves_temporal_saturation` to witness construction
- [ ] Prove witness seed `{ψ} ∪ BoxContent(M)` extended by Lindenbaum produces temporally saturated MCS
- [ ] Apply `constant_family_temporally_saturated_is_coherent`

**Branch B (if Option B failed - use Option A)**:
- [ ] Modify witness seed to include GContent(M) and HContent(M): `{ψ} ∪ BoxContent(M) ∪ GContent(M) ∪ HContent(M)`
- [ ] Prove this extended seed is consistent (uses G/H axiom properties)
- [ ] Prove Lindenbaum extension preserves GContent/HContent membership
- [ ] Derive temporal saturation from G/H content preservation

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean`

**Verification**:
- `witness_family_temporal_coherence` compiles WITHOUT sorry
- All helper lemmas compile WITHOUT sorry

---

### Phase 3: Option C Analysis (if Phase 2 fails) [NOT STARTED]

- **Dependencies:** Phase 2 (only if both Option B and A failed)
- **Goal:** Determine if truth lemma actually requires all families to be temporally coherent

**Analysis Tasks**:
- [ ] Read TruthLemma.lean and trace temporal operator handling
- [ ] Identify where `forward_F` and `backward_P` are used in truth lemma
- [ ] Check if these are only used for eval_family or all families
- [ ] If only eval_family: restructure BMCS.temporally_coherent to only require eval_family

**If Option C is valid**:
- [ ] Modify BMCS.temporally_coherent definition (or add weaker predicate)
- [ ] Update truth lemma to use weaker predicate
- [ ] Verify completeness theorems still work

**Timing**: 2-3 hours (only if needed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` (potentially)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (potentially)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (potentially)

**Verification**:
- All modified theorems compile WITHOUT sorry
- Completeness.lean still compiles

---

### Phase 4: Combined Construction and Proof [NOT STARTED]

- **Dependencies:** Phase 2 (or Phase 3 if needed)
- **Goal:** Prove `fully_saturated_bmcs_exists_int` sorry-free

**Tasks**:
- [ ] Wire FinalConstruction to use Option D architecture (FamilyCollection + exists_fullySaturated_extension)
- [ ] Apply witness temporal coherence from Phase 2 (or Phase 3)
- [ ] Prove all witness families in saturated BMCS are temporally coherent
- [ ] Prove `BMCS.temporally_coherent` for constructed BMCS
- [ ] Complete `fully_saturated_bmcs_exists_int` proof WITHOUT sorry

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean`

**Verification**:
- `fully_saturated_bmcs_exists_int` has NO sorry
- `lake build` succeeds
- `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns 0

---

### Phase 5: Integration and Final Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Integrate FinalConstruction.lean and verify sorry-free completion

**Tasks**:
- [ ] Add FinalConstruction.lean to Bimodal.lean imports
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify: `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns nothing
- [ ] Verify: `grep "axiom " Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns nothing
- [ ] Update documentation in related files

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal.lean` - add import
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - update documentation
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - update documentation

**Verification**:
- `lake build` succeeds
- No new sorries in any file
- No new axioms in any file

---

### Phase 6: Blocker Documentation (only if ALL approaches fail) [NOT STARTED]

- **Dependencies:** Phase 3 failed
- **Goal:** Document mathematical blocker requiring future research

**Tasks** (only if needed):
- [ ] Create detailed report explaining why each approach failed
- [ ] Identify specific theorem/property that would unblock
- [ ] Propose research direction
- [ ] Do NOT introduce any sorries or axioms

**This phase should NOT be reached** - one of Options B, A, or C should succeed.

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.FinalConstruction` succeeds
- [ ] `fully_saturated_bmcs_exists_int` has NO sorry
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns 0
- [ ] `grep "axiom " Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns nothing
- [ ] `lake build` succeeds (full project)
- [ ] Completeness.lean theorems still work

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - new file with sorry-free proof
- `specs/887_create_finalconstruction_prove_fully_saturated_bmcs/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

**NO TECHNICAL DEBT FALLBACK**. If implementation encounters blockers:

1. Try next approach in decision tree (B → A → C)
2. If all approaches fail, create detailed mathematical gap report
3. Revert any partial changes that introduced sorries
4. The existing sorry-backed theorem remains (we don't make it worse)
5. Create new research task to investigate the mathematical gap

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 001 | 2026-02-17 | Initial plan with Option B primary approach |
| 002 | 2026-02-17 | No technical debt fallback, added Options A and C from research-010.md |
