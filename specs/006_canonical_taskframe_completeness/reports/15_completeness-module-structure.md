# Completeness Module Structure Analysis

**Task**: 1006
**Focus**: How DenseCompleteness.lean and DiscreteCompleteness.lean share ParametricCanonicalTaskFrame D
**Date**: 2026-03-20

## Executive Summary

The polymorphic `ParametricCanonicalTaskFrame D` infrastructure is **complete and sorry-free**. Both dense (D = Rat) and discrete (D = Int) completeness share this infrastructure via:

1. `ParametricCanonical.lean` - D-parametric TaskFrame (COMPLETE)
2. `ParametricHistory.lean` - FMCS to WorldHistory conversion (COMPLETE)
3. `ParametricTruthLemma.lean` - Truth lemma for D-parametric model (COMPLETE)
4. `DenseInstantiation.lean` / `DiscreteInstantiation.lean` - Specializations (COMPLETE)

The blocking sorries are in **domain construction** (not the parametric framework) and **BFMCS wiring**.

---

## 1. Current Infrastructure Inventory

### 1.1 ParametricCanonicalTaskFrame D (COMPLETE)

**File**: `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`

**Type Signature**:
```lean
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState  -- MCS-based, D-independent
  task_rel := parametric_canonical_task_rel    -- Uses CanonicalR
```

**Status**: COMPLETE (no sorries)
- `parametric_task_rel_nullity_identity` - proved
- `parametric_task_rel_forward_comp` - proved
- `parametric_task_rel_converse` - proved

### 1.2 DurationTransfer.lean (COMPLETE)

**File**: `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`

| Definition | Status | Description |
|------------|--------|-------------|
| `ratOrderIso T` | COMPLETE | `T ≃o Rat` for Countable + DenselyOrdered + NoMin/MaxOrder |
| `ratAddCommGroup T` | COMPLETE | AddCommGroup from Cantor isomorphism |
| `ratIsOrderedAddMonoid T` | COMPLETE | Order-compatible monoid |
| `intOrderIso T` | COMPLETE | `T ≃o Int` for SuccOrder + PredOrder + IsSuccArchimedean |
| `intAddCommGroup T` | COMPLETE | AddCommGroup from integer isomorphism |
| `intIsOrderedAddMonoid T` | COMPLETE | Order-compatible monoid |

**Status**: No sorries. The deprecated `canonicalTaskFrame` has W=D error but is not used.

### 1.3 Dense Domain Instances (TimelineQuot)

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

| Instance | Status | Proof Method |
|----------|--------|--------------|
| `DenselyOrdered TimelineQuot` | COMPLETE | `dense_timeline_has_intermediate` + `canonicalR_irreflexive` axiom |
| `Countable TimelineQuot` | COMPLETE | `Quotient.countable` |
| `NoMaxOrder TimelineQuot` | COMPLETE | `canonicalR_strict` |
| `NoMinOrder TimelineQuot` | COMPLETE | `canonicalR_strict` |
| `Nonempty TimelineQuot` | COMPLETE | `dense_timeline_nonempty` |
| `LinearOrder TimelineQuot` | COMPLETE | `Antisymmetrization` |

**Cantor Isomorphism**: `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` - COMPLETE

### 1.4 Discrete Domain Instances (DiscreteTimelineQuot)

**File**: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

| Instance | Status | Notes |
|----------|--------|-------|
| `SuccOrder DiscreteTimelineQuot` | COMPLETE | Uses `LinearLocallyFiniteOrder.succFn` |
| `PredOrder DiscreteTimelineQuot` | COMPLETE | Uses `discretePredFn` (LUB of Iio) |
| `IsSuccArchimedean DiscreteTimelineQuot` | COMPLETE | Via `LocallyFiniteOrder` instance |
| `NoMaxOrder DiscreteTimelineQuot` | COMPLETE | `canonicalR_strict` |
| `NoMinOrder DiscreteTimelineQuot` | COMPLETE | `canonicalR_strict` |
| `LocallyFiniteOrder DiscreteTimelineQuot` | **AXIOM** | `discrete_Icc_finite_axiom` |

**Technical Debt**: One axiom (`discrete_Icc_finite_axiom`) for interval finiteness.

---

## 2. Instance Gap Analysis

### 2.1 Dense Case: What's Missing?

**For full dense completeness wiring**:

| Required | Status | Gap Description |
|----------|--------|-----------------|
| `TimelineQuot ≃o Rat` | COMPLETE | `cantor_iso` provides this |
| `FMCS TimelineQuot` | PARTIAL | Need `timelineQuotFMCS` wiring |
| `BFMCS TimelineQuot` | PARTIAL | Need modal saturation over TimelineQuot |
| `construct_saturated_bfmcs_rat` | MISSING | Function to build BFMCS containing given MCS |
| `valid_dense φ → truth in canonical` | MISSING | Bridge from validity to canonical model |

**Current Blocking Issue**: The staged construction builds `FMCS CanonicalMCS` (where `CanonicalMCS` is *all* MCSs), but dense completeness needs `FMCS TimelineQuot` or `FMCS Rat`. The transfer is incomplete.

### 2.2 Discrete Case: What's Missing?

**For full discrete completeness wiring**:

| Required | Status | Gap Description |
|----------|--------|-----------------|
| `DiscreteTimelineQuot ≃o Int` | COMPLETE | Via `intOrderIso` |
| `FMCS Int` | PARTIAL | `CanonicalConstruction.lean` has Int-based truth lemma |
| `BFMCS Int` | PARTIAL | Exists but sorries in temporal coherence |
| `construct_saturated_bfmcs_int` | **SORRY** | In `IntBFMCS.lean` lines 1175, 1177, 1199, 1213 |
| `valid_discrete φ → truth in canonical` | MISSING | Bridge from validity to canonical model |

---

## 3. Sorry Inventory (Critical Path)

### 3.1 Axioms (Documented Technical Debt)

| Location | Description | Impact |
|----------|-------------|--------|
| `DiscreteTimeline.lean:316` | `discrete_Icc_finite_axiom` | LocallyFiniteOrder for discrete case |
| `CanonicalIrreflexivityAxiom.lean` | `canonicalR_irreflexive` | NoMax/NoMin/DenselyOrdered proofs |

### 3.2 Critical Path Sorries (Block Completeness)

| File:Line | Sorry | Criticality |
|-----------|-------|-------------|
| `IntBFMCS.lean:1175` | `construct_saturated_bfmcs_int.forward_F` | HIGH |
| `IntBFMCS.lean:1177` | `construct_saturated_bfmcs_int.backward_P` | HIGH |
| `IntBFMCS.lean:1199` | `construct_saturated_bfmcs_int` | HIGH |
| `IntBFMCS.lean:1213` | `construct_saturated_bfmcs_int` | HIGH |
| `AlgebraicBaseCompleteness.lean:110` | BFMCS construction | HIGH |
| `AlgebraicBaseCompleteness.lean:137` | BFMCS construction | HIGH |
| `IntFMCSTransfer.lean:134` | Modal coherence transfer | HIGH |

### 3.3 Secondary Sorries (Not Blocking Main Path)

| File:Line | Sorry | Criticality |
|-----------|-------|-------------|
| `TimelineQuotCompleteness.lean:127` | `timelineQuot_not_valid_of_neg_consistent` | MEDIUM |
| `ClosureSaturation.lean:659,664,679,724` | Dovetailing coverage | MEDIUM |
| `CantorPrereqs.lean:111` | Temporal modal derivation | LOW |
| `CanonicalTimeline.lean:183` | Timeline helper | LOW |
| `Soundness.lean:566,570,573,576,596,599,681` | Various axiom soundness | MEDIUM |
| `SoundnessLemmas.lean:959` | `axiom_swap_valid` | LOW |

---

## 4. Proposed File Structure

### 4.1 Current Structure (As-Is)

```
Metalogic/
├── Algebraic/
│   ├── ParametricCanonical.lean      # D-parametric TaskFrame (COMPLETE)
│   ├── ParametricHistory.lean        # FMCS → WorldHistory (COMPLETE)
│   ├── ParametricTruthLemma.lean     # Truth lemma (COMPLETE)
│   ├── ParametricRepresentation.lean # Conditional representation (COMPLETE)
│   ├── DenseInstantiation.lean       # D = Rat (COMPLETE)
│   └── DiscreteInstantiation.lean    # D = Int (COMPLETE)
├── Domain/
│   ├── DurationTransfer.lean         # Group transfer (COMPLETE)
│   ├── DiscreteTimeline.lean         # DiscreteTimelineQuot (1 AXIOM)
│   └── CanonicalDomain.lean          # Domain construction
├── StagedConstruction/
│   ├── CantorApplication.lean        # TimelineQuot ≃o Rat (COMPLETE)
│   ├── TimelineQuotCanonical.lean    # TimelineQuot linking (PARTIAL)
│   └── ...
├── DenseCompleteness.lean            # Interface module (DOCUMENTATION)
└── DiscreteCompleteness.lean         # Interface module (DOCUMENTATION)
```

### 4.2 Proposed Changes for Full Wiring

**No new files needed**. The changes required are:

1. **Wire `timelineQuotFMCS`** in `TimelineQuotCanonical.lean`:
   - Currently has `timelineQuotMCS` extracting MCS from quotient
   - Need to wire to full FMCS structure with F/P witnesses

2. **Fill `construct_saturated_bfmcs_*` sorries**:
   - In `IntBFMCS.lean` and parallel for Rat
   - This is the main blocking work

3. **Update `DenseCompleteness.lean`**:
   - Currently documentation-only
   - Wire to `DenseInstantiation.lean` + BFMCS constructor

4. **Update `DiscreteCompleteness.lean`**:
   - Currently documentation-only
   - Wire to `DiscreteInstantiation.lean` + BFMCS constructor

---

## 5. Import Graph

### 5.1 Dense Completeness Path

```
DenseCompleteness.lean
  └─> Algebraic/DenseInstantiation.lean
        └─> Algebraic/ParametricRepresentation.lean
              ├─> Algebraic/ParametricTruthLemma.lean
              │     └─> Algebraic/ParametricHistory.lean
              │           └─> Algebraic/ParametricCanonical.lean
              │                 └─> Bundle/CanonicalFrame.lean
              └─> Bundle/BFMCS.lean
  └─> StagedConstruction/CantorApplication.lean (for TimelineQuot ≃o Rat)
  └─> Domain/DurationTransfer.lean (for ratAddCommGroup)
```

### 5.2 Discrete Completeness Path

```
DiscreteCompleteness.lean
  └─> Algebraic/DiscreteInstantiation.lean
        └─> Algebraic/ParametricRepresentation.lean (same as dense)
  └─> Domain/DiscreteTimeline.lean (for DiscreteTimelineQuot)
  └─> Domain/DurationTransfer.lean (for intAddCommGroup)
```

---

## 6. Concrete Implementation Steps

### Phase 1: Dense Completeness Wiring (Estimated: 3-4 sessions)

1. **Fill TimelineQuotCanonical FMCS** (1 session)
   - Extend `timelineQuotMCS` to full FMCS structure
   - Wire F/P witnesses from staged construction

2. **Build TimelineQuot BFMCS** (1-2 sessions)
   - Implement `construct_saturated_bfmcs_rat`
   - Wire modal saturation for TimelineQuot families

3. **Wire DenseCompleteness** (1 session)
   - Call `DenseInstantiation` with constructed BFMCS
   - Statement: `valid_dense φ → Nonempty (⊢ φ)`

### Phase 2: Discrete Completeness Wiring (Estimated: 2-3 sessions)

1. **Fill IntBFMCS sorries** (1-2 sessions)
   - `forward_F` and `backward_P` for Int families
   - `construct_saturated_bfmcs_int`

2. **Wire DiscreteCompleteness** (1 session)
   - Call `DiscreteInstantiation` with constructed BFMCS
   - Statement: `valid_discrete φ → Nonempty (⊢_discrete φ)`

### Phase 3: Documentation and Integration (Estimated: 1 session)

1. Update README.md files
2. Export main theorems from DenseCompleteness.lean / DiscreteCompleteness.lean
3. Document remaining technical debt (axioms)

---

## 7. Key Findings

### 7.1 The Parametric Infrastructure Works

`ParametricCanonicalTaskFrame D` is **complete and sorry-free**. The key properties:
- D-parametric (works for any `AddCommGroup D` with `LinearOrder` and `IsOrderedAddMonoid`)
- WorldState is D-independent (uses MCSs)
- TaskFrame axioms proved generically

### 7.2 Domain Constructions Are Complete

Both `TimelineQuot` (dense) and `DiscreteTimelineQuot` (discrete) have all required instances, with one axiom in the discrete case.

### 7.3 The Gap Is BFMCS Construction

The blocking sorries are all in constructing temporally coherent BFMCS bundles. The `construct_saturated_bfmcs_*` functions need:
- F-witness coherence: `F φ ∈ mcs t → ∃ s > t, φ ∈ mcs s`
- P-witness coherence: `P φ ∈ mcs t → ∃ s < t, φ ∈ mcs s`

### 7.4 No New Architecture Needed

The existing architecture is correct. The work is filling implementation gaps, not redesigning.

---

## 8. Recommendations

1. **Prioritize dense over discrete**: The dense case has fewer sorries (no `discrete_Icc_finite_axiom`)

2. **Use the conditional theorems**: `dense_representation_conditional` and `discrete_representation_conditional` are sorry-free; focus on filling the `construct_bfmcs` parameter

3. **Consider FlagBFMCS approach**: `FlagBFMCSRatBundle.lean` shows an alternative construction that may be easier to complete

4. **The covering lemma is optional**: The discrete case can proceed with the axiom; proving the covering lemma is a separate research task
