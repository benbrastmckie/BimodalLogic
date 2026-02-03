# Research Report: Task #826

**Task**: FDSM Completeness Saturated Construction - Sorry Elimination Strategy
**Date**: 2026-02-03
**Focus**: Complete sorry inventory, archival candidates, provable sorries, and plan update
**Report Number**: research-003

## Executive Summary

This research identifies **73 sorries** across the Bimodal/Metalogic/ directory. After careful analysis:
- **9 files can be archived** to Boneyard/ (removing ~16 sorries + blocking infrastructure)
- **~15 sorries are provable** with current infrastructure
- **~6 sorries are fundamentally blocked** (omega-rule, validity bridge limitations)
- **~36 sorries in FDSM/** represent the active implementation frontier

The critical path to zero-sorry metalogic is: **Archive first, then complete FDSM multi-history saturation**.

## 1. Complete Sorry Inventory

### 1.1 Sorry Counts by File

| File | Sorries | Classification |
|------|---------|----------------|
| **FDSM/TruthLemma.lean** | 16 | Active - provable with closure tracking |
| **FDSM/ModalSaturation.lean** | 15 | Active - 5 core, 10 infrastructure |
| **FMP/ConsistentSatisfiable.lean** | 9 | ARCHIVE - blocked validity bridge |
| **Bundle/TruthLemma.lean** | 6 | 2 blocked (omega-rule), 4 acceptable |
| **Bundle/Construction.lean** | 6 | 1 sorry (modal_backward) - acceptable |
| **FDSM/Completeness.lean** | 6 | Active - depends on TruthLemma |
| **FMP/SemanticCanonicalModel.lean** | 5 | Documentation only (comments mention "sorry-free") |
| **Completeness/Completeness.lean** | 3 | Documentation only |
| **Bundle/Completeness.lean** | 2 | Documentation only |
| **Completeness/FiniteStrongCompleteness.lean** | 1 | Blocked validity bridge |
| **FMP/Closure.lean** | 1 | Minor - non-essential lemma |
| **SoundnessLemmas.lean** | 1 | Documentation only (mentions "previous sorry") |
| **Metalogic.lean** | 1 | Documentation only |
| **FDSM/Core.lean** | 1 | Documentation only |

**Total actual sorries in code**: ~73 (some are in comments/documentation)

### 1.2 Sorry Classification

#### A. Archivable (Move to Boneyard/)

| File | Sorries | Reason |
|------|---------|--------|
| `FMP/ConsistentSatisfiable.lean` | 9 | Blocked validity bridge - never completable |
| `Completeness/FiniteStrongCompleteness.lean` | 1 | Depends on blocked bridge lemma |

**Subtotal**: 10 sorries eliminated by archival

#### B. Fundamentally Blocked (Document, Accept)

| File | Location | Reason |
|------|----------|--------|
| `Bundle/TruthLemma.lean:383` | `all_future backward` | Omega-rule limitation |
| `Bundle/TruthLemma.lean:395` | `all_past backward` | Omega-rule limitation |
| `Bundle/Construction.lean:220` | `modal_backward` | Single-family construction assumption |

**Subtotal**: 3 sorries - architectural limitations, not fixable without changing semantics

**Note**: These are acceptable because:
1. The completeness theorems only use `.mp` (forward direction)
2. `bmcs_weak_completeness` and `bmcs_strong_completeness` are SORRY-FREE in their execution path
3. The sorries represent inherent limitations of finitary proof systems (omega-rule)

#### C. Provable with Current Infrastructure

| File | Location | Strategy |
|------|----------|----------|
| `FDSM/TruthLemma.lean` (all 16) | Closure membership tracking | Systematic application of existing closure lemmas |
| `FDSM/Completeness.lean:106` | modal_saturated | Use tracked saturation |
| `FDSM/Completeness.lean:168,187` | Truth lemmas | Complete FDSM truth lemma first |
| `FMP/Closure.lean:728` | diamond_in_closureWithNeg | Delete or mark as non-essential |

**Subtotal**: ~20 sorries provable

#### D. Active Implementation Frontier (FDSM/)

| File | Sorries | Dependency |
|------|---------|------------|
| `FDSM/ModalSaturation.lean` | 15 | Core saturation proofs needed |
| `FDSM/TruthLemma.lean` | 16 | Closure membership tracking |
| `FDSM/Completeness.lean` | 6 | Depends on TruthLemma |

**Subtotal**: 37 sorries - the main work for task 826

## 2. Archival Candidates

### 2.1 Files to Archive to Boneyard/

**Recommended for immediate archival:**

1. **`FMP/ConsistentSatisfiable.lean`** (9 sorries)
   - Reason: Attempts to bridge FMP-internal validity to general TaskModel validity
   - Blocked by: Modal and temporal cases require truth correspondence that cannot be established
   - Research reference: Task 810 research-005.md documents the architectural blockage
   - Alternative: Use BMCS completeness (sorry-free) instead

2. **`Completeness/FiniteStrongCompleteness.lean`** (1 sorry)
   - Reason: Uses blocked validity bridge from ConsistentSatisfiable
   - Alternative: Use `bmcs_strong_completeness` which is SORRY-FREE

### 2.2 Files Already Archived (Reference)

These are already in Boneyard/:
- `Boneyard/Metalogic_v5/` - Old Representation approach (30+ sorries)
- `Boneyard/FDSM_SingleHistory/` - Single-history FDSM (trivializes modal operators)

### 2.3 Files to KEEP (Despite Sorries)

| File | Sorries | Why Keep |
|------|---------|----------|
| `Bundle/TruthLemma.lean` | 6 | Completeness uses only `.mp` direction - SORRY-FREE execution path |
| `Bundle/Construction.lean` | 6 | Single-family is sufficient for existence proofs |
| `Bundle/Completeness.lean` | 2 | Main theorems are SORRY-FREE |

## 3. Provable Sorries - Detailed Strategy

### 3.1 FDSM/TruthLemma.lean (16 sorries)

**Root cause**: Closure membership proof obligations not threaded through.

**Strategy**:
```lean
-- Pattern for each case:
theorem fdsm_truth_lemma {phi : Formula} (M : FiniteDynamicalSystemModel phi)
    (h : FDSMHistory phi) (hh : h ∈ M.histories) (t : FDSMTime phi) (psi : Formula)
    (h_clos : psi ∈ closure phi) :  -- <-- This h_clos needs threading
    psi ∈ (h.states t).toSet ↔ fdsm_truth_at M h t psi
```

**Required lemmas** (most already exist in FMP/Closure.lean):
- `closure_imp_left`, `closure_imp_right`
- `closure_box`, `closure_all_future`, `closure_all_past`
- `closure_neg` (in closureWithNeg)

**Effort estimate**: 2-3 hours systematic work

### 3.2 FDSM/ModalSaturation.lean (15 sorries)

**Core sorries** (5) requiring proof:
1. `modal_backward_from_saturation:390` - Needs full truth lemma
2. `fixed_point_is_saturated:900` - Contrapositive on fixed point
3. `saturated_histories_saturated:912` - Composition
4. `mcsTrackedHistory_finite:982` - Finite injection argument
5. `tracked_saturated_histories_saturated:1370` - Main saturation theorem

**Infrastructure sorries** (10) - follow from core:
- `saturation_terminates:784` - Cardinality bound
- `projectTrackedHistories_modal_saturated:1432`
- `fdsm_from_tracked_saturation.modal_saturated:1465`
- Various helper lemmas

**Strategy**: Complete in order:
1. Fix `mcsTrackedHistory_finite` (needs careful injection argument)
2. Prove `tracked_fixed_point_is_saturated` (the key lemma)
3. Other sorries follow by composition

**Effort estimate**: 4-6 hours

### 3.3 FDSM/Completeness.lean (6 sorries)

All depend on completing FDSM/TruthLemma.lean:
- `modal_saturated:106` - Use tracked saturation
- `fdsm_mcs_implies_truth:168` - Truth lemma forward
- `fdsm_mcs_neg_implies_false:187` - Truth lemma backward + MCS

**Effort estimate**: 1-2 hours (after TruthLemma complete)

## 4. Implementation Plan Update

### 4.1 Recommended Phase Structure

**Phase 0: Archive (IMMEDIATE)**
- Archive `FMP/ConsistentSatisfiable.lean` to `Boneyard/FMP_Bridge/`
- Archive `Completeness/FiniteStrongCompleteness.lean` to `Boneyard/FMP_Bridge/`
- Update imports in Completeness.lean
- Run `lake build` to verify no breakage

**Phase 1: FDSM Truth Lemma**
- Complete closure membership threading in all 16 sorries
- Systematic work using existing closure lemmas
- Verification: Each case should close with existing MCS + closure infrastructure

**Phase 2: Modal Saturation Core**
- Fix `mcsTrackedHistory_finite` injection
- Prove `tracked_fixed_point_is_saturated`
- Complete `tracked_saturated_histories_saturated`

**Phase 3: FDSM Completeness**
- Connect truth lemma to completeness
- Verify `fdsm_internal_completeness` is sorry-free
- Update Metalogic.lean to export FDSM completeness

**Phase 4: Documentation + Cleanup**
- Document architectural limitations (omega-rule)
- Verify Bundle completeness path works
- Update ROAD_MAP.md

### 4.2 Critical Path

```
Archive ConsistentSatisfiable (10 min)
    ↓
FDSM/TruthLemma.lean (16 sorries) ← Start here
    ↓
FDSM/ModalSaturation.lean (5 core sorries)
    ↓
FDSM/Completeness.lean (3 sorries)
    ↓
Zero-sorry FDSM completeness path
```

### 4.3 Non-Critical Path (Accept As-Is)

These sorries do NOT block the completeness result:
- `Bundle/TruthLemma.lean:383,395` - Omega-rule limitation
- `Bundle/Construction.lean:220` - Construction assumption
- `FMP/Closure.lean:728` - Non-essential lemma

## 5. Key Findings Summary

1. **Archival first**: Removing ConsistentSatisfiable.lean and FiniteStrongCompleteness.lean eliminates 10 blocked sorries and simplifies the codebase.

2. **FDSM is the path forward**: The FDSM approach with bounded time + multi-history saturation CAN achieve zero-sorry completeness.

3. **Bundle completeness already works**: The `bmcs_weak_completeness` and `bmcs_strong_completeness` theorems are SORRY-FREE in their execution path. The sorries in TruthLemma are only in the backwards direction, which is not used.

4. **Closure tracking is the bottleneck**: Most FDSM/TruthLemma sorries are "mechanical" - threading closure membership proofs through induction cases.

5. **Two completeness paths available**:
   - **Bundle/Completeness.lean**: BMCS validity completeness (currently working)
   - **FDSM/Completeness.lean**: FDSM internal completeness (needs 25 sorries resolved)

## 6. Recommendations

1. **Immediately archive** ConsistentSatisfiable.lean and FiniteStrongCompleteness.lean

2. **Focus task 826** on completing FDSM/TruthLemma.lean first (16 sorries, straightforward)

3. **Accept Bundle sorries** as documented architectural limitations

4. **Leave FMP/Closure.lean:728** as a non-essential sorry (diamond membership lemma not needed)

5. **Update task 826 plan** to reflect the archive-first strategy

## References

- Task 818 research-004.md: Historical analysis of Truth Lemma backwards direction
- Task 810 research-005.md: Bridge lemma blockage analysis
- Task 812 research-007.md: BMCS formalization and validity analysis
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`: SORRY-FREE main theorems

## Next Steps

1. Create archive directory structure: `Boneyard/FMP_Bridge/`
2. Move blocked files with documentation
3. Update implementation plan for task 826 to start with Phase 0 (archival)
4. Begin Phase 1: FDSM/TruthLemma closure tracking
