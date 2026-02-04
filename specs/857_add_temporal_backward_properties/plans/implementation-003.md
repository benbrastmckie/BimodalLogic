# Implementation Plan: Task #857 - Zero-Axiom Temporal Backward Properties (v003)

**Task**: 857 - Add temporal_backward_G and temporal_backward_H properties to IndexedMCSFamily
**Version**: 003
**Created**: 2026-02-04
**Language**: lean
**Status**: [NOT STARTED]
**Effort**: 8-12 hours
**Dependencies**: Task 856 (completed), Task 862 (research complete)
**Session**: sess_1770238918_014a7d

## Research Input: Key Insights from research-007.md

This plan is derived from the mathematical completion path identified in research-007.md, which integrates insights from Task 862's feasibility analysis.

### Critical Finding: Modified Lindenbaum is Required

Research-007 definitively established:
1. **Separation strategies do NOT help** - The backward direction on subformulas is structurally unavoidable
2. **Temporal saturation is NOT automatic** - An MCS can consistently contain F(psi) and neg(psi) simultaneously
3. **The correct approach**: Modified Lindenbaum (`temporalLindenbaumMCS`) with witness insertion during enumeration

### Current Sorry Locations

| File | Lines | Issue |
|------|-------|-------|
| TemporalCoherentConstruction.lean | 724, 727 | Forward/backward saturation in bundle construction |
| TemporalCoherentConstruction.lean | 739, 741 | Bundle forward/backward saturation properties |
| TruthLemma.lean | 403 | temporal_backward_G (G all_future backward) |
| TruthLemma.lean | 419 | temporal_backward_H (H all_past backward) |
| TruthLemma.lean | 593, 600, 612, 624 | Additional temporal backward cases |

**Total**: ~10 sorries all requiring temporal saturation

### Why v002 Was Blocked

The v002 plan attempted to use the EvalCoherentBundle pattern directly, but hit a fundamental barrier:
- Modal saturation adds **new families** (worlds) as witnesses
- Temporal saturation requires witnesses **within the same MCS**
- Standard Lindenbaum does NOT preserve temporal saturation

## Overview: The temporalLindenbaumMCS Approach

The solution is a modified Lindenbaum construction that adds temporal witnesses during enumeration:

```
temporalLindenbaumMCS(Gamma, h_cons):
  M := contextAsSet Gamma
  for phi in enumFormulas:
    if consistent(M union {phi}):
      M := M union {phi}
      -- Temporal witness step
      if phi = F(psi) for some psi:
        if consistent(M union {psi}):
          M := M union {psi}
      if phi = P(psi) for some psi:
        if consistent(M union {psi}):
          M := M union {psi}
  return M
```

The result is temporally saturated by construction.

## Goals & Non-Goals

**Goals**:
- Implement `temporalLindenbaumMCS` function
- Prove it produces temporally saturated MCS
- Eliminate all sorries related to temporal backward properties
- Achieve zero new axioms

**Non-Goals**:
- Modifying the standard Lindenbaum construction (keep separate)
- Optimizing for efficiency
- Unifying modal and temporal saturation

## Phase Structure

### Phase 1: Core Lindenbaum Extension [NOT STARTED]

**Goal**: Create `temporalLindenbaumMCS` that produces temporally saturated MCS.

**Effort**: 4-6 hours

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (new file)

**Deliverables**:

1. **Define temporal witness extraction**:
   ```lean
   def extractTemporalWitness (phi : Formula) : Option Formula :=
     match phi with
     | Formula.neg (Formula.unaryOp UnaryOp.always psi) => some psi  -- F(psi) = neg(G(neg psi))
     | Formula.neg (Formula.unaryOp UnaryOp.hist psi) => some psi    -- P(psi) = neg(H(neg psi))
     | _ => none
   ```

2. **Define temporal Lindenbaum step**:
   ```lean
   def temporalLindenbaumStep (M : Set Formula) (phi : Formula)
       (h_consistent : SetConsistent M) : Set Formula :=
     if h : SetConsistent (M ∪ {phi}) then
       let M' := M ∪ {phi}
       match extractTemporalWitness phi with
       | some psi => if SetConsistent (M' ∪ {psi}) then M' ∪ {psi} else M'
       | none => M'
     else M
   ```

3. **Define full construction** (via Hilbert-style enumeration):
   ```lean
   noncomputable def temporalLindenbaumMCS (Gamma : Context)
       (h_cons : ContextConsistent Gamma) :
       { M : Set Formula // SetMaximalConsistent M ∧ TemporallySaturated M ∧
         contextAsSet Gamma ⊆ M }
   ```

4. **Prove key preservation lemmas**:
   - `temporalLindenbaumStep_preserves_consistency`
   - `temporalLindenbaumStep_monotone`
   - `temporalLindenbaumStep_adds_witness`

**Verification**:
- New file compiles without sorry
- `lake build` passes

---

### Phase 2: Saturation Properties [NOT STARTED]

**Goal**: Prove the Lindenbaum result is temporally saturated.

**Effort**: 2-4 hours

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (continue)

**Deliverables**:

1. **Prove forward saturation**:
   ```lean
   theorem temporalLindenbaumMCS_forward_saturated (Gamma : Context)
       (h_cons : ContextConsistent Gamma) :
       TemporalForwardSaturated (temporalLindenbaumMCS Gamma h_cons).val := by
     -- By construction: when F(psi) is added, psi is also added (if consistent)
     -- Need to show: psi is always consistent when F(psi) is added
     -- Uses temporal_witness_seed_consistent from research-007
     sorry
   ```

2. **Prove backward saturation**:
   ```lean
   theorem temporalLindenbaumMCS_backward_saturated (Gamma : Context)
       (h_cons : ContextConsistent Gamma) :
       TemporalBackwardSaturated (temporalLindenbaumMCS Gamma h_cons).val := by
     -- Symmetric argument for P(psi)
     sorry
   ```

3. **Key lemma** (from research-007):
   ```lean
   theorem temporal_step_witness_consistent (M : Set Formula)
       (phi psi : Formula) (h_mcs : SetMaximalConsistent M)
       (h_F : extractTemporalWitness phi = some psi)
       (h_phi_in : phi ∈ M) :
       SetConsistent (M ∪ {psi}) := by
     -- Uses temporal_witness_seed_consistent
     -- Key: {psi} ∪ GContent(M) is consistent (proven in Phase 2 of v002)
     -- And M ⊇ GContent(M) when M is the limit of Lindenbaum construction
     sorry
   ```

**Verification**:
- All saturation properties proven without sorry
- `lake build` passes

---

### Phase 3: Integration and Sorry Elimination [NOT STARTED]

**Goal**: Update bundle construction and truth lemma to use temporally saturated MCS.

**Effort**: 2-4 hours

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`

**Deliverables**:

1. **Update `temporal_eval_saturated_bundle_exists`**:
   Replace the sorry-laden construction with one using `temporalLindenbaumMCS`.

2. **Eliminate TruthLemma sorries**:
   - Line 403: Use `forward_F` from saturation
   - Line 419: Use `backward_P` from saturation
   - Lines 593, 600, 612, 624: Same approach

3. **Verify completeness chain**:
   Ensure completeness theorem remains transitively sorry-free.

**Verification**:
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` returns only comments
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` returns only comments
- `lake build` passes cleanly

---

## Risk Analysis

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness consistency proof fails | High | Medium | Reuse existing `temporal_witness_seed_consistent` |
| Enumeration order matters | Medium | Low | Process by formula complexity (standard approach) |
| Multi-witness conflict | Medium | Medium | Process formulas one-at-a-time (inherent in enumeration) |
| Performance issues | Low | Medium | Accept non-computable definitions |

## Comparison with Previous Versions

| Aspect | v001 | v002 | v003 |
|--------|------|------|------|
| Phases | 6 | 3 | 3 |
| Core insight | Time-varying MCS | EvalCoherent pattern | Modified Lindenbaum |
| Blocking issue | No clear integration path | Modal pattern doesn't transfer | - |
| Key deliverable | Infrastructure | Saturation structures | temporalLindenbaumMCS |
| Research basis | research-004 | research-005 | research-007 |

## What Changed from v002

1. **Recognized modal pattern limitation** - EvalCoherentBundle creates new families; temporal needs same-MCS witnesses
2. **Identified correct solution** - Modified Lindenbaum from research-007
3. **New file structure** - Dedicated TemporalLindenbaum.lean rather than extending TemporalCoherentConstruction
4. **Clearer dependency** - Uses existing `temporal_witness_seed_consistent` as foundation

## Success Criteria

- [ ] `temporalLindenbaumMCS` implemented and compiles
- [ ] `TemporalForwardSaturated` proven for result
- [ ] `TemporalBackwardSaturated` proven for result
- [ ] TruthLemma temporal backward sorries eliminated
- [ ] TemporalCoherentConstruction bundle sorries eliminated
- [ ] `lake build` passes with no new sorries
- [ ] Completeness theorem remains transitively sorry-free

## Rollback Strategy

If Phase 1 or 2 encounter insurmountable barriers:
1. The existing infrastructure from v002 remains functional
2. Completeness is already sorry-free (uses forward direction only)
3. Document temporal backward as Category 1 technical debt per proof-debt-policy.md

## References

- research-007.md: Mathematical completion path analysis
- research-005.md: EvalCoherent pattern analysis
- Task 862: Separation feasibility study (confirms backward is unavoidable)
- TemporalCoherentConstruction.lean: Existing infrastructure
- CoherentConstruction.lean: Modal saturation pattern (reference only)
