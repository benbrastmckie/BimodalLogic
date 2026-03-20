# Implementation Plan: Task #1006 (v6)

- **Task**: 1006 - canonical_taskframe_completeness
- **Version**: 06 (Cantor Transfer Approach)
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None (v5 rigidity blocker bypassed)
- **Research Inputs**:
  - `13_rigidity-counterexample-analysis.md` - Proves D = Aut+(T) approach unsound; recommends Cantor transfer
  - `14_d-polymorphism-dense-discrete.md` - Documents existing D-polymorphic infrastructure
  - `15_completeness-module-structure.md` - Identifies blocking sorries in BFMCS wiring
- **Artifacts**: `plans/06_cantor-transfer-plan.md` (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

**Why v6**: The v5 torsor approach is mathematically unsound. Report 13 proves that rigidity (if f : T ≃o T fixes a point, then f = id) is FALSE via the elementary counterexample x → 2x on ℚ. The entire D = Aut+(T) construction must be abandoned.

**New Approach**: Use Cantor's theorem (T ≃o ℚ for countable DLOs) to set D = ℚ directly. All algebraic structure (AddCommGroup, LinearOrder, IsOrderedAddMonoid, AddTorsor) comes from Mathlib for free. The polymorphic `ParametricCanonicalTaskFrame D` infrastructure already exists and is sorry-free.

**Key Insight**: Report 15 shows the blocking sorries are NOT in the parametric framework (which is complete) but in the **BFMCS construction and wiring**. This plan focuses on filling those specific gaps.

### Research Integration

From `13_rigidity-counterexample-analysis.md`:
- Rigidity fails: x → 2x fixes 0 but ≠ id
- D = Aut+(T) approach is unsound as stated
- Cantor transfer (D = ℚ) bypasses the problem entirely
- Estimated new code: 70-100 lines (vs 430-530 for torsor approach)

From `14_d-polymorphism-dense-discrete.md`:
- `ParametricCanonicalTaskFrame D` already exists and is D-polymorphic
- `DenseInstantiation.lean` provides `DenseCanonicalTaskFrame : TaskFrame Rat`
- `DurationTransfer.lean` provides `ratOrderIso`, `ratAddCommGroup`, `ratIsOrderedAddMonoid`
- No new "DurationDomain" typeclass needed

From `15_completeness-module-structure.md`:
- ParametricCanonical.lean: COMPLETE (no sorries)
- ParametricHistory.lean: COMPLETE (no sorries)
- ParametricTruthLemma.lean: COMPLETE (no sorries)
- **Critical sorries**: IntBFMCS.lean lines 1175, 1177, 1199, 1213 (BFMCS construction)

## Goals & Non-Goals

**Goals**:
- Wire existing Cantor isomorphism infrastructure to completeness theorem
- Fill BFMCS construction sorries (F/P witness coherence)
- Produce `dense_completeness : valid_dense φ → Nonempty (DerivationTree_dense [] φ)`
- Archive unsound TranslationGroup.lean code to Boneyard

**Non-Goals**:
- Proving discrete completeness (task 989 scope with D = ℤ)
- Building new D = Aut+(T) infrastructure (proven unsound)
- Proving AddTorsor D T (not required for completeness per report 14)
- Creating unified "DurationDomain" typeclass (mutually exclusive constraints)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BFMCS F/P witness sorries harder than expected | H | M | Existing FlagBFMCS infrastructure provides alternative path |
| Cantor isomorphism API gaps | M | L | `Order.iso_of_countable_dense` verified to exist in Mathlib |
| TimelineQuot missing instances | M | L | CantorApplication.lean already provides required instances |
| FMCS → WorldHistory wiring gaps | M | M | ParametricHistory.lean is complete; may need adapter |

## Implementation Phases

### Phase 1: Archive Unsound Code [NOT STARTED]

**Goal**: Move mathematically unsound D = Aut+(T) code to Boneyard.

**Rationale**: TranslationGroup.lean and related files define D as `Additive (T ≃o T)`, which cannot act freely on T. This code path is a dead end.

**Tasks**:
- [ ] Move `Theories/Bimodal/Boneyard/Task956_IntRat/TranslationGroup.lean` to deep archive (or mark DEPRECATED)
- [ ] Add deprecation comment to `TranslationGroup` explaining rigidity counterexample
- [ ] Verify no active completeness code imports TranslationGroup

**Files to modify**:
- `Theories/Bimodal/Boneyard/Task956_IntRat/TranslationGroup.lean` - Add deprecation header
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Remove TranslationGroup imports if any

**Verification**:
- `lake build` passes with deprecation comments
- No non-Boneyard files import TranslationGroup

**Estimated effort**: 30 minutes

---

### Phase 2: Verify Cantor Infrastructure [NOT STARTED]

**Goal**: Confirm all pieces exist to construct `TimelineQuot ≃o Rat`.

**Existing Infrastructure** (from report 15):

| Component | Location | Status |
|-----------|----------|--------|
| `TimelineQuot` (antisymmetrization) | `StagedConstruction/` | Working |
| `Countable TimelineQuot` | `CantorApplication.lean` | COMPLETE |
| `DenselyOrdered TimelineQuot` | `CantorApplication.lean` | COMPLETE |
| `NoMaxOrder TimelineQuot` | `CantorApplication.lean` | COMPLETE |
| `NoMinOrder TimelineQuot` | `CantorApplication.lean` | COMPLETE |
| `Nonempty TimelineQuot` | `CantorApplication.lean` | COMPLETE |
| `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` | `CantorApplication.lean` | COMPLETE |

**Tasks**:
- [ ] Read `CantorApplication.lean` and verify `cantor_iso` construction
- [ ] Verify `ratOrderIso T` pattern in `DurationTransfer.lean`
- [ ] Confirm no sorries in Cantor isomorphism chain
- [ ] Document any missing links between TimelineQuot and DurationTransfer

**Files to read**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`

**Verification**:
- All Cantor infrastructure compiles without sorries
- Clear path from TimelineQuot → Rat → ParametricCanonicalTaskFrame Rat

**Estimated effort**: 1 hour

---

### Phase 3: BFMCS Construction - Identify Gaps [NOT STARTED]

**Goal**: Understand exactly what the blocking sorries require.

**Critical Sorries** (from report 15):

| Location | Sorry | Description |
|----------|-------|-------------|
| IntBFMCS.lean:1175 | `forward_F` | F φ ∈ mcs t → ∃ s > t, φ ∈ mcs s |
| IntBFMCS.lean:1177 | `backward_P` | P φ ∈ mcs t → ∃ s < t, φ ∈ mcs s |
| IntBFMCS.lean:1199 | construction | BFMCS bundle assembly |
| IntBFMCS.lean:1213 | construction | BFMCS bundle assembly |

**Tasks**:
- [ ] Read IntBFMCS.lean sorries in context (±30 lines)
- [ ] Identify what theorems would close each sorry
- [ ] Check if FlagBFMCS infrastructure provides alternative
- [ ] Document required lemmas for Phase 4

**Files to read**:
- `Theories/Bimodal/Metalogic/Construction/IntBFMCS.lean` (lines 1145-1240)
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS*.lean` (alternative path)

**Verification**:
- Clear specification of what each sorry requires
- Decision: fill IntBFMCS sorries OR pivot to FlagBFMCS

**Estimated effort**: 1.5 hours

---

### Phase 4: Fill BFMCS Construction Sorries [NOT STARTED]

**Goal**: Prove F/P witness coherence for temporal model construction.

**Mathematical Requirement**:
- **forward_F**: If `F φ ∈ mcs(t)`, then there exists `s > t` in the timeline with `φ ∈ mcs(s)`
- **backward_P**: If `P φ ∈ mcs(t)`, then there exists `s < t` in the timeline with `φ ∈ mcs(s)`

**Approach Options**:

**Option A: Direct proof** (if witnesses exist in staged construction):
- Use dovetailed construction's density/seriality properties
- Show witnesses are reachable and in-timeline

**Option B: FlagBFMCS alternative** (if IntBFMCS path blocked):
- FlagBFMCS already has respects_task proven
- May have fewer sorries to fill
- Check FlagBFMCSRatBundle.lean status

**Tasks**:
- [ ] Attempt Option A: Fill IntBFMCS forward_F/backward_P
- [ ] If blocked: Evaluate Option B (FlagBFMCS path)
- [ ] Prove remaining construction sorries
- [ ] Verify `construct_saturated_bfmcs_rat` compiles

**Files to modify**:
- `Theories/Bimodal/Metalogic/Construction/IntBFMCS.lean` OR
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean`

**Verification**:
- All BFMCS construction sorries closed
- `lake build` passes

**Estimated effort**: 4-6 hours (largest phase)

---

### Phase 5: Wire Completeness Theorem [NOT STARTED]

**Goal**: Connect BFMCS construction to final completeness statement.

**Pipeline**:
```
valid_dense φ
  → ¬ provable φ (contrapositive)
  → ¬φ consistent
  → ∃ MCS containing ¬φ (Lindenbaum)
  → ∃ BFMCS containing MCS (Phase 4)
  → ParametricCanonicalTaskFrame Rat construction
  → ParametricHistory (FMCS → WorldHistory)
  → ParametricTruthLemma (MCS ↔ truth)
  → WorldHistory where ¬φ holds
  → ¬ valid_dense φ (contradiction)
```

**Existing Components**:
- `ParametricCanonicalTaskFrame Rat` - COMPLETE (DenseInstantiation.lean)
- `parametric_to_history` - COMPLETE (ParametricHistory.lean)
- `parametric_shifted_truth_lemma` - COMPLETE (ParametricTruthLemma.lean)

**Tasks**:
- [ ] Wire BFMCS construction output to ParametricCanonicalTaskFrame
- [ ] Verify WorldHistory construction from FMCS
- [ ] State and prove `dense_completeness` theorem
- [ ] Add to module exports

**Files to modify**:
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` (main theorem)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (exports)

**Verification**:
- `dense_completeness` compiles without sorry
- Full `lake build` passes
- Theorem statement matches spec: `valid_dense φ → Nonempty (DerivationTree_dense [] φ)`

**Estimated effort**: 2-3 hours

---

### Phase 6: Cleanup and Documentation [NOT STARTED]

**Goal**: Update documentation and remove dead code paths.

**Tasks**:
- [ ] Update DenseCompleteness.lean header documentation
- [ ] Remove or mark deprecated alternative approaches
- [ ] Add completion summary to implementation summary artifact
- [ ] Verify no non-axiom sorries in completeness chain

**Files to modify**:
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Documentation
- `specs/1006_canonical_taskframe_completeness/summaries/02_execution-summary.md` - Create

**Verification**:
- All changes documented
- No regression in build
- Clear upgrade path for discrete completeness (task 989)

**Estimated effort**: 1 hour

---

## Testing & Validation

- [ ] Phase 1: No TranslationGroup imports outside Boneyard
- [ ] Phase 2: Cantor infrastructure verified sorry-free
- [ ] Phase 3: Gap analysis complete, clear path identified
- [ ] Phase 4: BFMCS construction sorries closed
- [ ] Phase 5: `dense_completeness` theorem proven without sorry
- [ ] Phase 6: Full `lake build` passes with no regression
- [ ] Final: `#check dense_completeness` shows clean type signature

## Artifacts & Outputs

### Modified Files
- `Theories/Bimodal/Boneyard/Task956_IntRat/TranslationGroup.lean` - DEPRECATED header
- `Theories/Bimodal/Metalogic/Construction/IntBFMCS.lean` - Filled sorries
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Main theorem

### New Files
- `specs/1006_canonical_taskframe_completeness/summaries/02_execution-summary.md`

### Estimated New/Modified Code
| Component | Lines | Type |
|-----------|-------|------|
| Deprecation comments | 10 | Comment |
| BFMCS witness proofs | 50-100 | Proof |
| Completeness wiring | 30-50 | Proof |
| Documentation | 20 | Comment |

**Total**: ~100-180 lines of new proofs (much less than v5's 430-530)

## Rollback/Contingency

If Cantor transfer encounters unexpected blockers:

1. **BFMCS witnesses blocked**: Pivot to FlagBFMCS alternative path (report 15 section 3.3)
2. **Cantor infrastructure gap**: Use `sorry`-bridged version, document as axiom
3. **Full approach blocked**: Fall back to direct `satisfies_at`-based completeness (not recommended, defeats task purpose)

All changes are modular; no existing working code is modified destructively.

## Dependencies on Existing Infrastructure

| Component | Location | Status | Usage |
|-----------|----------|--------|-------|
| `TimelineQuot` | StagedConstruction/ | Working | Canonical timeline |
| `cantor_iso` | CantorApplication.lean | COMPLETE | T ≃o ℚ |
| `ratAddCommGroup` | DurationTransfer.lean | COMPLETE | AddCommGroup on ℚ |
| `ParametricCanonicalTaskFrame` | ParametricCanonical.lean | COMPLETE | D-polymorphic TaskFrame |
| `parametric_to_history` | ParametricHistory.lean | COMPLETE | FMCS → WorldHistory |
| `parametric_shifted_truth_lemma` | ParametricTruthLemma.lean | COMPLETE | Truth lemma |

## Comparison with v5

| Aspect | v5 (Torsor) | v6 (Cantor Transfer) |
|--------|-------------|---------------------|
| D definition | Aut+(T) | ℚ (via Mathlib) |
| Rigidity required | Yes (FALSE) | No |
| Holder's theorem | Required | Not needed |
| AddTorsor construction | Manual (~100 lines) | Mathlib provides |
| New code estimate | 430-530 lines | 100-180 lines |
| Mathematical soundness | **UNSOUND** | Sound |
| Blocking phase | Phase 1 (rigidity) | Phase 4 (BFMCS) |

## Success Criteria

1. TranslationGroup.lean archived/deprecated
2. Cantor infrastructure verified complete
3. BFMCS construction sorries filled
4. `dense_completeness` theorem proven without sorry
5. Full `lake build` succeeds
6. No non-axiom sorries in completeness chain
7. Clear path to discrete completeness (task 989) documented
