# Implementation Plan: Task #857 - Zero-Axiom Temporal Backward Properties (Revised)

- **Task**: 857 - Add temporal_backward_G and temporal_backward_H properties to IndexedMCSFamily
- **Version**: 002
- **Status**: [IMPLEMENTING]
- **Effort**: 12-18 hours (revised down from 40-55)
- **Dependencies**: Task 856 (EvalCoherent pattern reference)
- **Research Inputs**:
  - specs/857_add_temporal_backward_properties/reports/research-004.md
  - specs/857_add_temporal_backward_properties/reports/research-005.md (key insights)
- **Existing Work**:
  - TemporalCoherentConstruction.lean (infrastructure from v001)
  - implementation-summary-20260204.md (partial completion report)
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan builds on the partial implementation from v001 and incorporates insights from research-005. The key finding is that the **EvalCoherentBundle pattern from Task 856** can be directly adapted for temporal operators.

### What Changed from v001

1. **Recognized that Phase 5 was blocked** - the integration requires temporal saturation, not just infrastructure
2. **Identified the correct solution** - temporal saturation following the EvalCoherentBundle pattern
3. **Reduced scope** - only 3 phases needed (not 6), building on completed infrastructure
4. **Clearer technical path** - witness construction for F/P formulas mirrors Diamond witness construction

### Key Insight from Research-005

The sorries at TruthLemma.lean lines 402/418 require:
- `forward_F`: F(phi) in mcs(t) -> exists s > t, phi in mcs(s)
- `backward_P`: P(phi) in mcs(t) -> exists s < t, phi in mcs(s)

For a constant family, this is impossible without constructing **time-varying witness families**. The solution is to adapt Task 856's approach: instead of adding witness **worlds** for Diamond formulas, we add witness **times** for F/P formulas.

## Goals & Non-Goals

**Goals**:
- Eliminate sorries at TruthLemma.lean lines 402 and 418
- Achieve zero axioms and zero sorries
- Provide publication-quality temporal truth lemma

**Non-Goals**:
- Unifying modal and temporal saturation (future work)
- Optimizing the saturation construction for efficiency

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-witness seed consistency proof fails | High | Medium | Follow exact pattern from EvalCoherentBundle |
| Time domain requires special handling | Medium | Low | Use Integer for discrete time (already in place) |
| Integration with existing truth lemma | Medium | Medium | Create wrapper function if needed |

## Sorry Characterization

### Pre-existing Sorries (Target)
- Line 402: `all_future` backward - `temporal_backward_G`
- Line 418: `all_past` backward - `temporal_backward_H`

### Expected Resolution
- Phase 2 proves temporal saturation exists
- Phase 3 updates TruthLemma to use saturated family, eliminating both sorries

### New Sorries
- None permitted. All proofs must be complete.

## Axiom Characterization

### Pre-existing Axioms
- None in scope (temporal backward is currently a sorry, not an axiom)

### New Axioms
- NEVER. Zero-axiom requirement is absolute.

## Implementation Phases

### Phase 1: Temporal Saturation Structures [NOT STARTED]

**Goal**: Define temporal saturation predicates mirroring EvalCoherent/EvalSaturated.

**Tasks**:
- [ ] Review EvalCoherent/EvalSaturated in CoherentConstruction.lean for pattern
- [ ] Define `TemporalEvalCoherent` predicate:
  ```lean
  def TemporalEvalCoherent (base : IndexedMCSFamily) (fam : IndexedMCSFamily) :=
    forall t phi, G phi in base.mcs t -> phi in fam.mcs s (for all s >= t)
  ```
- [ ] Define `TemporalEvalSaturated` predicate:
  ```lean
  def TemporalEvalSaturated (fam : IndexedMCSFamily) :=
    forall t phi, F phi in fam.mcs t -> exists s > t, phi in fam.mcs s
  ```
- [ ] Define `TemporalEvalSaturatedBundle` combining coherent + saturated families
- [ ] Prove basic properties (coherent families form collection, saturation implies forward_F)

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - add structures

**Verification**:
- `lake build` passes
- New definitions compile without sorry

---

### Phase 2: Temporal Saturation Construction [NOT STARTED]

**Goal**: Prove that temporally saturated families exist for any consistent context.

**Tasks**:
- [ ] Prove `temporal_witness_seed_consistent`:
  If F(phi) in base.mcs(t), then {phi} union GContent(base) is consistent
  (Follow pattern from `diamond_boxcontent_consistent_constant`)
- [ ] Construct witness MCS at future time via Lindenbaum extension
- [ ] Prove `temporal_eval_saturated_bundle_exists`:
  For any consistent context, construct a TemporalEvalSaturatedBundle
  (Follow pattern from `eval_saturated_bundle_exists`)
- [ ] Define `construct_temporal_eval_bmcs`: Entry point for completeness

**Key Pattern from Task 856**:
```lean
-- In CoherentConstruction.lean, the proof of eval_saturated_bundle_exists:
-- 1. Start with base (constant family from consistent context)
-- 2. For each Diamond formula, construct witness MCS
-- 3. Collect witnesses into saturated bundle
-- 4. Prove coherence preserved

-- For temporal, adapt:
-- 1. Start with base (constant family)
-- 2. For each F formula at time t, construct witness at time s > t
-- 3. Result is time-varying family with forward_F property
```

**Timing**: 6-8 hours (critical path)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

**Verification**:
- `lake build` passes
- `construct_temporal_eval_bmcs` compiles without sorry

---

### Phase 3: Integration and Sorry Elimination [NOT STARTED]

**Goal**: Update TruthLemma to use temporally saturated family, eliminating sorries.

**Tasks**:
- [ ] Update `bmcs_truth_lemma` to take `TemporalEvalSaturatedBundle` parameter
  OR create variant `temporal_bmcs_truth_lemma` that does
- [ ] Replace sorry at line 402 with proof using `forward_F` from saturation
- [ ] Replace sorry at line 418 with proof using `backward_P` from saturation
- [ ] Update `completeness_theorem` to use new construction if needed
- [ ] Verify entire module builds without sorry or axiom
- [ ] Run comprehensive grep checks

**Timing**: 3-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - eliminate sorries
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - update if needed

**Verification**:
- `lake build` passes
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` returns empty
- `grep "^axiom" Theories/Bimodal/Metalogic/Bundle/*.lean` shows no new axioms

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` returns empty
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` returns empty
- [ ] `grep "^axiom" Theories/Bimodal/Metalogic/Bundle/*.lean` shows only pre-existing axioms
- [ ] Manual review: completeness theorem transitively sorry-free and axiom-free

## Artifacts & Outputs

- `specs/857_add_temporal_backward_properties/plans/implementation-002.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (extended)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (sorries removed)
- `specs/857_add_temporal_backward_properties/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If temporal saturation construction proves intractable:
1. Document the gap formally
2. Consider Option B from research-005: one-directional truth lemma
3. The forward direction is already proven and sufficient for completeness
4. Preserve infrastructure for future remediation

## Comparison to v001

| Aspect | v001 | v002 |
|--------|------|------|
| Total phases | 6 | 3 |
| Estimated hours | 40-55 | 12-18 |
| Key insight | Time-varying MCS | Temporal saturation via EvalCoherent pattern |
| Blocking issue | Unknown path to integration | Clear: follow Task 856 pattern |
| Phase 1-4 status | 1,4,6 complete | Infrastructure preserved, build on it |
