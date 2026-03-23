# Implementation Plan: Task #988

- **Task**: 988 - dense_algebraic_completeness
- **Version**: 8 (revised from v7 based on research 08_bridge-elimination-analysis.md)
- **Status**: [NOT STARTED]
- **Effort**: 19 hours (reduced from 22h)
- **Dependencies**: Task 982 (completed)
- **Research Inputs**: specs/988_dense_algebraic_completeness/reports/08_bridge-elimination-analysis.md
- **Artifacts**: plans/08_dovetailed-timelinequot.md (this file)
- **Type**: lean4
- **Lean Intent**: true

## Overview

Research revealed that the bridge lemma proposed in v7 **already exists** in `TimelineQuotCanonical.lean`. The real blocker is the `forward_F`/`backward_P` properties for TimelineQuotFMCS, which the DenseTimeline construction cannot satisfy for late-added points.

**Key Insight**: Instead of trying to fix TimelineQuot/DenseTimeline, we create `DovetailedTimelineQuot` - an antisymmetrization of the dovetailed timeline that directly leverages the sorry-free `dovetailedTimeline_has_future/past` from DovetailedCoverage.lean.

### Why This Approach is Cleaner

| Aspect | Plan v7 | Plan v8 (this) |
|--------|---------|----------------|
| Bridge needed? | Yes (Phase 1) | No - already exists |
| Primary domain | TimelineQuot (DenseTimeline) | DovetailedTimelineQuot (DovetailedBuild) |
| forward_F/backward_P | Requires new proof | Direct from DovetailedCoverage |
| Estimated effort | 22h | 19h |
| Architectural purity | Uses two constructions | Uses one construction end-to-end |

## Goals & Non-Goals

**Goals**:
- Create `DovetailedTimelineQuot` with Cantor isomorphism to Q
- Build FMCS with forward_F/backward_P from existing DovetailedCoverage lemmas
- Prove truth lemma over DovetailedTimelineQuot
- Achieve `dense_completeness` theorem with no sorries
- Clean `lake build Bimodal` with no new axioms

**Non-Goals**:
- Fixing TimelineQuot/ClosureSaturation sorries (bypassed entirely)
- Building new bridge lemmas (already exist)
- BFMCS-based transport approach

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DovetailedPoint order properties different from StagedPoint | Medium | Low | Both use CanonicalR alignment; same structure |
| Cantor prerequisites harder for DovetailedTimelineQuot | Low | Low | Same proof pattern as TimelineQuot |
| Truth lemma requires adapting parametric infrastructure | Medium | Medium | ParametricTruthLemma is template-ready |
| Instance unification with AddCommGroup | Medium | Medium | Existing CantorApplication shows pattern |

## Implementation Phases

### Phase 1: DovetailedTimelineQuot Definition [PARTIAL]

**Goal**: Define `DovetailedTimelineQuot` as antisymmetrization of dovetailed timeline

**Tasks**:
- [ ] Define `DovetailedTimelineElem` as subtype of DovetailedPoint in timeline union
- [ ] Define `DovetailedTimelineQuot` as `Antisymmetrization DovetailedTimelineElem (· ≤ ·)`
- [ ] Prove `LinearOrder DovetailedTimelineQuot` (from antisymmetrization)
- [ ] Prove `Countable DovetailedTimelineQuot` (from countable dovetailed timeline)
- [ ] Prove `Nonempty DovetailedTimelineQuot` (root point exists)

**Timing**: 3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Key Definition**:
```lean
/-- Elements of the dovetailed timeline -/
def DovetailedTimelineElem (root_mcs) (root_mcs_proof) :=
  { p : DovetailedPoint // p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof }

/-- DovetailedTimelineQuot: antisymmetrization for proper linear order -/
def DovetailedTimelineQuot (root_mcs) (root_mcs_proof) :=
  Antisymmetrization (DovetailedTimelineElem root_mcs root_mcs_proof) (· ≤ ·)
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot`
- All definitions compile with no sorry
- `#check instLinearOrderDovetailedTimelineQuot` succeeds

---

### Phase 2: Cantor Prerequisites & Isomorphism [COMPLETED]

**Goal**: Prove Cantor prerequisites and establish isomorphism to Q

**Tasks**:
- [ ] Prove `NoMaxOrder DovetailedTimelineQuot` using `dovetailedTimeline_has_future`
- [ ] Prove `NoMinOrder DovetailedTimelineQuot` using `dovetailedTimeline_has_past`
- [ ] Prove `DenselyOrdered DovetailedTimelineQuot` using density from dovetailed construction
- [ ] Apply `Order.iso_of_countable_dense` to get `DovetailedTimelineQuot ≃o Q`
- [ ] Transfer `AddCommGroup` from Q via isomorphism
- [ ] Transfer `IsOrderedAddMonoid` from Q via isomorphism
- [ ] Define `DenseTemporalFrame DovetailedTimelineQuot` instance

**Timing**: 2 hours

**Files to modify**:
- Extend: `DovetailedTimelineQuot.lean`

**Key Theorem**:
```lean
/-- Cantor isomorphism: DovetailedTimelineQuot ≃o Q -/
theorem dovetailedTimelineQuot_iso_rat :
    Nonempty (DovetailedTimelineQuot root_mcs root_mcs_proof ≃o Rat) :=
  Order.iso_of_countable_dense
    (DovetailedTimelineQuot root_mcs root_mcs_proof) Rat
```

**Verification**:
- `lean_verify` on `dovetailedTimelineQuot_iso_rat`
- `#check instAddCommGroupDovetailedTimelineQuot` succeeds
- `#check instDenselyOrderedDovetailedTimelineQuot` succeeds

---

### Phase 3: DovetailedFMCS Construction [COMPLETED]

**Goal**: Build FMCS over DovetailedTimelineQuot with temporal coherence

**Tasks**:
- [ ] Define MCS extraction: `dovetailedTimelineQuotMCS t := (ofAntisymmetrization t).val.mcs`
- [ ] Define `dovetailedFMCS : FMCS (DovetailedTimelineQuot root_mcs root_mcs_proof)`
- [ ] Prove `forward_F` directly from `dovetailedTimeline_has_future`
- [ ] Prove `backward_P` directly from `dovetailedTimeline_has_past`
- [ ] Prove `forward_G` using MCS properties
- [ ] Prove `backward_H` using MCS properties
- [ ] Wrap as `TemporalCoherentFamily`

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean`

**Key Construction**:
```lean
/-- FMCS over DovetailedTimelineQuot with temporal coherence -/
def dovetailedFMCS (root_mcs) (root_mcs_proof) : TemporalCoherentFamily D where
  mcs t := dovetailedTimelineQuotMCS root_mcs root_mcs_proof t
  is_mcs t := (ofAntisymmetrization (· ≤ ·) t).val.is_mcs
  forward_F t φ h_F := by
    -- Use dovetailedTimeline_has_future + quotient properties
    ...
  backward_P t φ h_P := by
    -- Use dovetailedTimeline_has_past + quotient properties
    ...
```

**Verification**:
- `lean_verify` on `dovetailedFMCS.forward_F` and `dovetailedFMCS.backward_P`
- All lemmas have no `sorry`
- `lake build` succeeds

---

### Phase 4: Truth Lemma over DovetailedTimelineQuot [BLOCKED]

**Goal**: Prove truth lemma: φ ∈ mcs t ↔ truth_at M Omega τ t φ

**Tasks**:
- [ ] Define TaskFrame over DovetailedTimelineQuot using ParametricCanonicalTaskFrame pattern
- [ ] Define TaskModel with MCS valuation
- [ ] Define Omega set using ShiftClosedParametricCanonicalOmega as template
- [ ] Define history mapping from dovetailedFMCS
- [ ] Prove forward direction: φ ∈ mcs t → truth_at (induction on formula)
- [ ] Prove backward direction: truth_at → φ ∈ mcs t
  - Temporal cases use `temporal_backward_G`, `temporal_backward_H` from TemporalCoherence.lean
  - Modal case requires handling (singleton FMCS approach or direct MCS reasoning)

**Timing**: 6 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTruthLemma.lean`

**Key Theorem**:
```lean
/-- Truth lemma for DovetailedTimelineQuot -/
theorem dovetailed_truth_lemma
    (fam : dovetailedFMCS root_mcs root_mcs_proof)
    (t : DovetailedTimelineQuot root_mcs root_mcs_proof)
    (φ : Formula) :
    φ ∈ fam.mcs t ↔ truth_at DovetailedCanonicalTaskModel Omega (parametric_to_history fam) t φ
```

**Verification**:
- `lean_verify` on `dovetailed_truth_lemma`
- All lemmas have no `sorry`
- Both directions proven

---

### Phase 5: Dense Completeness Theorem [NOT STARTED]

**Goal**: Prove final dense completeness theorem

**Tasks**:
- [ ] Prove `dovetailedTimelineQuot_not_valid_of_neg_consistent`:
  - If [φ.neg] consistent, then φ NOT valid over DovetailedTimelineQuot
  - Uses truth lemma: φ.neg ∈ root MCS → truth_at ... φ.neg → ¬truth_at ... φ
- [ ] Prove `dovetailed_dense_completeness` (main theorem):
  - `∀ D [dense constraints], valid_over D φ → provable φ`
  - Contrapositive using DovetailedTimelineQuot as witness
- [ ] Wire to export module (if needed)
- [ ] Verify full `lake build Bimodal` succeeds
- [ ] Count sorries - should decrease

**Timing**: 4 hours

**Files to modify/create**:
- Create: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedDenseCompleteness.lean`
- Or modify: `DovetailedCompleteness.lean` to use new infrastructure

**Key Theorem**:
```lean
/-- Dense completeness via DovetailedTimelineQuot -/
theorem dovetailed_dense_completeness {φ : Formula} :
    (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
       [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
       [DenseTemporalFrame D], valid_over D φ) →
    Nonempty ([] ⊢ φ)
```

**Verification**:
- `lake build Bimodal` succeeds
- `grep -rn sorry Theories/Bimodal/Metalogic/StagedConstruction/Dovetailed*.lean` shows 0
- No new axioms introduced

## Testing & Validation

- [ ] Each phase builds independently
- [ ] `lake build Bimodal` succeeds after all phases
- [ ] `dovetailed_dense_completeness` has no sorry
- [ ] Sorry count in `Theories/Bimodal/Metalogic/StagedConstruction/` decreases
- [ ] No new axioms introduced
- [ ] Instance unification works correctly

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` (Phases 1-2)
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean` (Phase 3)
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTruthLemma.lean` (Phase 4)
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedDenseCompleteness.lean` (Phase 5)
- `specs/988_dense_algebraic_completeness/summaries/04_completion-summary.md`

## Rollback/Contingency

If the DovetailedTimelineQuot approach proves intractable:

**Fallback**: Return to v7 approach (TimelineQuot bridge)
- The bridge lemmas already exist in TimelineQuotCanonical.lean
- Use them to connect DovetailedCoverage to TimelineQuot
- More complex but uses existing TimelineQuot infrastructure

**Revert Changes**:
- New files can simply be deleted
- No modifications to existing working code
- Clean rollback via git

## Comparison with Previous Plans

| Aspect | Plan v7 | Plan v8 (this) |
|--------|---------|----------------|
| Bridge building | Phase 1 (4h) | Eliminated - already exists |
| Primary domain | TimelineQuot | DovetailedTimelineQuot |
| Uses DovetailedCoverage | Indirectly via bridge | Directly |
| forward_F/backward_P source | Need new proofs | From DovetailedCoverage |
| Total effort | 22h | 19h |
| New files | 4 | 4 |
| Existing file modifications | 1 | 0 |
| Architectural cleanliness | Connects two constructions | Single construction path |
