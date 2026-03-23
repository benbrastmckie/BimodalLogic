# Phase 0 Enumeration Report: canonicalR_irreflexive Call Sites

**Date**: 2026-03-22
**Task**: 29 - switch_to_reflexive_gh_semantics
**Phase**: 0 - Enumeration and Pattern Catalog

## Executive Summary

This report enumerates all call sites of `canonicalR_irreflexive` and categorizes them by replacement strategy for the switch to reflexive semantics.

**Key Findings**:
- 35 actual code call sites (excludes Boneyard, which has 12 legacy sites)
- 6 distinct usage patterns identified
- Primary replacement: `canonicalR_antisymmetric` + distinctness guards
- The existing `canonicalR_strict` helper will become the main workhorse

## Call Site Inventory

### Active Codebase Sites (Non-Boneyard)

| File | Line | Usage Pattern | Replacement Strategy |
|------|------|---------------|---------------------|
| **FMCSTransfer.lean** |||
| L224 | `canonicalR_irreflexive b.world b.is_mcs h` | Pattern A: Self-cycle after eq | Antisymmetry |
| L229 | `canonicalR_irreflexive a.world a.is_mcs h_aa` | Pattern B: Transitivity cycle | Antisymmetry |
| **SaturatedChain.lean** |||
| L370 | `canonicalR_irreflexive W h_W_mcs h_R` | Pattern A: Self-cycle after eq | Antisymmetry |
| L373 | `canonicalR_irreflexive M.world M.is_mcs h_MM` | Pattern B: Transitivity cycle | Antisymmetry |
| L401 | `canonicalR_irreflexive M.world M.is_mcs h_R` | Pattern A | Antisymmetry |
| L404 | `canonicalR_irreflexive W h_W_mcs h_WW` | Pattern B | Antisymmetry |
| L446 | `canonicalR_irreflexive M.world M.is_mcs h_MW` | Pattern A | Antisymmetry |
| L449 | `canonicalR_irreflexive M.world M.is_mcs h_MM` | Pattern B | Antisymmetry |
| L459 | `canonicalR_irreflexive W_set h_W_mcs h_WN` | Pattern A | Antisymmetry |
| L462 | `canonicalR_irreflexive N.world N.is_mcs h_NN` | Pattern B | Antisymmetry |
| **DovetailedTimelineQuot.lean** |||
| L403 | `absurd h_trans (canonicalR_irreflexive p.1.mcs p.1.is_mcs)` | Pattern B | Antisymmetry |
| L1382 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern A | Antisymmetry |
| L1385 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern B | Antisymmetry |
| L1427 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern A | Antisymmetry |
| L1430 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern B | Antisymmetry |
| L1512 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern A | Antisymmetry |
| L1515 | `canonicalR_irreflexive w.mcs w.is_mcs h_R_self` | Pattern B | Antisymmetry |
| L1553 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern A | Antisymmetry |
| L1556 | `canonicalR_irreflexive w.mcs w.is_mcs h_R_self` | Pattern B | Antisymmetry |
| **ClosureSaturation.lean** |||
| L391 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern A | Antisymmetry |
| L395 | `canonicalR_irreflexive p.1.mcs p.1.is_mcs h_R_self` | Pattern B | Antisymmetry |
| **TimelineQuotCanonical.lean** |||
| L96 | `absurd h_trans (canonicalR_irreflexive p.1.mcs p.1.is_mcs)` | Pattern B | Antisymmetry |
| **IncrementalTimeline.lean** |||
| L156 | `absurd h_trans (canonicalR_irreflexive p.1.mcs p.1.is_mcs)` | Pattern B | Antisymmetry |
| **CanonicalSerialFrameInstance.lean** |||
| L77 | `canonicalR_irreflexive w.val w.is_mcs h_R'` | Pattern A | Antisymmetry |
| L123 | `canonicalR_irreflexive N h_N_mcs h_R'` | Pattern A | Antisymmetry |

### Total Active Sites: 25 (non-Boneyard)

## Usage Pattern Analysis

### Pattern A: Self-cycle contradiction via equality substitution
```lean
-- Original: when h_eq : W.world = M.world, and h_R : CanonicalR W.world M.world
rw [h_eq] at h_R
exact canonicalR_irreflexive M.world M.is_mcs h_R
```
**Replacement**:
```lean
-- Under reflexive semantics, CanonicalR M M is TRUE (T-axiom: g_content M ⊆ M)
-- Must use antisymmetry with a distinctness witness
-- If we have both CanonicalR M N and CanonicalR N M:
exact congrArg CanonicalMCS.world (canonicalR_antisymmetric h_R h_R'.symm) ▸ h_ne rfl
```

### Pattern B: Transitivity cycle contradiction
```lean
-- Original: when we have CanonicalR M N and CanonicalR N M
have h_trans := canonicalR_transitive M N M h_mcs h_R h_R'
exact canonicalR_irreflexive M h_mcs h_trans
```
**Replacement**:
```lean
-- Use antisymmetry directly
have h_eq := canonicalR_antisymmetric h_R h_R'
-- Then derive contradiction from the equality and some distinctness fact
```

## Axiom Assessment Table

| Axiom | File | Under Reflexive | Action |
|-------|------|-----------------|--------|
| `canonicalR_irreflexive_axiom` | CanonicalIrreflexivity.lean | FALSE | Phase 5: REMOVE |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean | Provable | Phase 6: PROVE |
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean | Unaffected | Document as debt |
| `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean | Possibly provable | Phase 6: ASSESS |
| `successor_deferral_seed_consistent_axiom` | SuccExistence.lean | Possibly provable | Phase 6: ASSESS |
| `predecessor_deferral_seed_consistent_axiom` | SuccExistence.lean | Possibly provable | Phase 6: ASSESS |
| `predecessor_f_step_axiom` | SuccExistence.lean | Unaffected | Document as debt |
| `succ_chain_fam_p_step` | SuccChainFMCS.lean | Unaffected | Document as debt |
| `f_nesting_boundary` | SuccChainFMCS.lean | Unaffected | Document as debt |
| `p_nesting_boundary` | SuccChainFMCS.lean | Unaffected | Document as debt |

## Key Implementation Notes

### 1. The `canonicalR_strict` helper already exists

From CanonicalIrreflexivityAxiom.lean line 89:
```lean
theorem canonicalR_strict (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h : CanonicalR M N) : ¬CanonicalR N M :=
  fun h' => canonicalR_irreflexive M hM (canonicalR_transitive M N M hM h h')
```

Under reflexive semantics, this becomes `canonicalR_antisymmetric` with conclusion `M = N` rather than contradiction. The pattern becomes:
```lean
-- New helper
theorem canonicalR_antisymmetric (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h1 : CanonicalR M N) (h2 : CanonicalR N M) : M = N := ...
```

### 2. FMCSTransfer.lean requires careful redesign

The `lt_of_canonicalR` theorem at line 214:
```lean
theorem CanonicalMCS.lt_of_canonicalR (a b : CanonicalMCS) (h : CanonicalR a.world b.world) :
    a < b
```

Under reflexive semantics, this is FALSE when `a = b` (since CanonicalR a a is now TRUE).

**Redesign options**:
1. Add hypothesis `a ≠ b`
2. Change conclusion to `a ≤ b ∧ (a ≠ b → a < b)`
3. Prove separately: `lt_of_canonicalR_ne : CanonicalR a b → a ≠ b → a < b`

Option 3 is cleanest: callers already have distinctness witnesses in most cases.

### 3. NoMaxOrder/NoMinOrder proofs need distinctness

Current pattern (e.g., in SaturatedChain.lean):
```lean
-- Get seriality witness N with CanonicalR M N
-- Need M ≠ N, then use irreflexivity to show N ≯ M
```

New pattern:
```lean
-- Get seriality witness N with CanonicalR M N
-- Use blocking formula argument: F(¬⊥) ∈ M gives witness W with ¬⊥ ∈ W
-- By naming: M uses atom p, W doesn't, so M ≠ W
-- Then use antisymmetry: if CanonicalR M N and CanonicalR N M, then M = N
-- Contradiction with M ≠ N gives ¬CanonicalR N M
```

### 4. The T-axiom enables reflexivity proof

Under reflexive semantics, `CanonicalR M M` holds because:
- `g_content(M) ⊆ M` by T-axiom: `G φ ∈ M → φ ∈ M`
- This is the definition of `CanonicalR M M`

```lean
theorem canonicalR_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR M M := by
  intro φ h_Gφ
  -- T-axiom: G φ → φ is a theorem
  -- By MCS closure, φ ∈ M
  exact SetMaximalConsistent.modus_ponens h_mcs (temp_t_future φ) h_Gφ
```

## Replacement Strategy Summary

1. **Add theorems** (Phase 5):
   - `canonicalR_reflexive` (trivial via T-axiom)
   - `canonicalR_antisymmetric` (use Gabbay infrastructure)
   - `canonicalR_ne_of_strict` (helper: CanonicalR M N ∧ ¬CanonicalR N M → M ≠ N)
   - `lt_of_canonicalR_ne` (replace `lt_of_canonicalR`)

2. **Remove axiom** (Phase 5):
   - Delete `canonicalR_irreflexive_axiom`
   - Delete `canonicalR_irreflexive` theorem

3. **Fix call sites** (Phase 5):
   - Pattern A: Use antisymmetry with distinctness from context
   - Pattern B: Use antisymmetry directly, derive equality, contradict distinctness

4. **Prove axiom** (Phase 6):
   - `discreteImmediateSuccSeed_consistent_axiom` via T-axiom and seed construction

## Files Modified Summary

| File | Sites | Complexity |
|------|-------|------------|
| FMCSTransfer.lean | 2 | High (redesign lt_of_canonicalR) |
| SaturatedChain.lean | 8 | Medium |
| DovetailedTimelineQuot.lean | 10 | Medium |
| ClosureSaturation.lean | 2 | Low |
| TimelineQuotCanonical.lean | 1 | Low |
| IncrementalTimeline.lean | 1 | Low |
| CanonicalSerialFrameInstance.lean | 2 | Low |
| CanonicalIrreflexivity.lean | (source) | High (remove axiom, add theorems) |

## Boneyard Files (Excluded from Active Work)

The Boneyard directory contains 12 legacy call sites in Task994_DovetailedQuot/DovetailedTimelineQuot.lean. These are NOT part of the active codebase and will be excluded from this refactoring. If needed, they can be updated in a separate cleanup task.
