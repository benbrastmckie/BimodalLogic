# Task 1009: Audit of "D = CanonicalMCS" Notation

**Date**: 2026-03-20
**Focus**: User feedback on categorical error in "D = CanonicalMCS" notation

## Executive Summary

The notation "D = CanonicalMCS" creates a fundamental category error by suggesting CanonicalMCS could serve as the temporal domain `D` in `TaskFrame D`. This is impossible because:

- `D` in `TaskFrame D` requires `[AddCommGroup D]`, `[LinearOrder D]`, `[IsOrderedAddMonoid D]`
- `CanonicalMCS` has only `[Preorder CanonicalMCS]` (non-linear, non-total)

These are **categorically different constructions**: durations/time vs world states.

## The Categorical Distinction

| Concept | Type | Role | Typeclasses |
|---------|------|------|-------------|
| `TaskFrame D` parameter | Duration/time | Temporal domain | AddCommGroup, LinearOrder, IsOrderedAddMonoid |
| `FMCS D` parameter | Index type | Family indexing domain | Preorder only |
| `CanonicalMCS` | World states | All maximal consistent sets | Preorder (from CanonicalR reflexive closure) |

**Key insight**: In `FMCS CanonicalMCS`, the parameter `D` is the *indexing type* for the family of MCSes. When `D = CanonicalMCS`, each index *is* a world state, and `mcs(w) = w.world` (the MCS at index w is w's own underlying set).

This is fundamentally different from `TaskFrame D` where `D` is the duration type with algebraic structure for time arithmetic.

## Correct Model: SeparatedTaskFrame.lean

The file `Theories/Bimodal/Metalogic/Algebraic/SeparatedTaskFrame.lean` (lines 6-24) demonstrates the correct architectural separation:

```lean
-- Separated TaskFrame: D = TimelineQuot, W = CanonicalMCS

-- Key Insight (Task 982, research-009)
-- The dense completeness blocker arose from conflating two architecturally distinct components:
-- - D (Duration/Time Domain): Needs LinearOrder + DenselyOrdered (TimelineQuot provides this)
-- - W (World States): Space of all MCSs (ParametricCanonicalWorldState provides this)
```

**Correct notation**: `D = TimelineQuot, W = CanonicalMCS`

## Instances of "D = CanonicalMCS" Found

### Category A: Lean Source Files (Active Code)

#### A.1 CanonicalFMCS.lean (Line 286)
**Path**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean:286`
**Text**: `This eliminates the temporal_coherent_family_exists sorry for D = CanonicalMCS.`
**Problem**: Suggests CanonicalMCS plays TaskFrame's temporal domain role.
**Fix**: "...for the FMCS indexed by CanonicalMCS (world-state indexing)."

#### A.2 Completeness.lean (Line 116)
**Path**: `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean:116`
**Text**: `1. The BFMCS uses D = CanonicalMCS (the all-MCS domain)`
**Problem**: "D = CanonicalMCS" implies temporal domain role.
**Fix**: "1. The BFMCS is indexed by CanonicalMCS (the all-MCS world-state space)"

#### A.3 Completeness.lean (Line 119)
**Path**: `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean:119`
**Text**: `The existing canonical_truth_lemma in CanonicalConstruction.lean uses D = Int,`
**Context**: This correctly uses D = Int for temporal domain. The issue is the contrast with line 116 where "D = CanonicalMCS" uses the same variable name for a categorically different concept.

### Category B: ROAD_MAP.md

#### B.1 Line 182
**Text**: `the BFMCS uses D = CanonicalMCS while the TaskFrame semantics uses D = TimelineQuot.`
**Problem**: Using same variable `D` for both conflates FMCS indexing type with TaskFrame temporal domain.
**Fix**: "the BFMCS is indexed by CanonicalMCS (world states) while the TaskFrame uses temporal domain D = TimelineQuot"

#### B.2 Line 209
**Text**: `The BFMCS infrastructure uses D = CanonicalMCS (the all-MCS domain), while the TaskFrame/semantics uses D = TimelineQuot (the Cantor domain).`
**Problem**: Same conflation.
**Fix**: "The BFMCS infrastructure is indexed by CanonicalMCS (world-state space), while TaskFrame uses temporal domain D = TimelineQuot (dense linear order)"

#### B.3 Line 1258
**Text**: `CanonicalFMCS.lean # D=CanonicalMCS families (SORRY-FREE)`
**Problem**: "D=CanonicalMCS" in comment.
**Fix**: "CanonicalFMCS.lean # CanonicalMCS-indexed families (SORRY-FREE)"

### Category C: Implementation Plans

#### C.1 02_completeness-plan.md (Line 45)
**Path**: `specs/1008_genuine_truth_at_completeness/plans/02_completeness-plan.md:45`
**Text**: `Work with FMCS D where D = CanonicalMCS, avoid embedding`
**Problem**: "FMCS D where D = CanonicalMCS" conflates indexing parameter with TaskFrame's D.
**Fix**: "Work with FMCS indexed by CanonicalMCS, avoid embedding"

#### C.2 02_completeness-plan.md (Line 53)
**Text**: `Prove base completeness using D = CanonicalMCS with existing sorry-free infrastructure.`
**Fix**: "Prove base completeness using FMCS indexed by CanonicalMCS..."

#### C.3 03_revised-completeness-plan.md (Line 69)
**Text**: `- Using D = CanonicalMCS (incorrect — CanonicalMCS lacks AddCommGroup/LinearOrder)`
**Note**: This line CORRECTLY identifies that "D = CanonicalMCS" is incorrect for TaskFrame's D. However, the phrasing could be clearer: it's not just incorrect, it's a category error.
**Status**: Actually documents the issue correctly. Keep as-is or strengthen.

### Category D: Archived Research Reports

Found in 80+ files including:
- `specs/archive/986_bfmcs_construction_for_int/reports/07_teammate-b-findings.md` (lines 40, 42)
- `specs/archive/986_bfmcs_construction_for_int/plans/implementation-002.md` (lines 32, 161)
- `specs/archive/924_prove_fully_saturated_bmcs_exists_modal_temporal/reports/research-003.md` (line 214)
- `specs/state.json` (line 81 - in artifact summary)

**Recommendation**: Archived reports are historical artifacts. Do not retroactively update, but ensure new documentation uses correct terminology.

### Category E: state.json Artifact Summaries

#### E.1 Line 81
**Text**: `"summary": "6-phase revised plan: corrects D=CanonicalMCS confusion..."`
**Context**: This summary CORRECTLY identifies "D=CanonicalMCS confusion" as something to correct.
**Status**: Acceptable as-is; the summary describes fixing the confusion.

## Why This Notation is Wrong

### The Overloaded Variable Name Problem

Both `FMCS D` and `TaskFrame D` use `D` as their type parameter, but with completely different requirements:

```lean
-- FMCS D requires only:
variable [Preorder D]

-- TaskFrame D requires:
variable [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

When writing `D = CanonicalMCS`, readers naturally assume `D` refers to the same concept in both contexts. This creates the illusion that CanonicalMCS could be a temporal domain.

### CanonicalMCS Structure

```lean
noncomputable instance : Preorder CanonicalMCS where
  le a b := a = b ∨ CanonicalR a.world b.world
  -- Reflexive: Or.inl rfl
  -- Transitive: via CanonicalR transitivity
  -- NOT antisymmetric, NOT total, NOT linear
```

CanonicalMCS has:
- Preorder (reflexive + transitive)
- NOT LinearOrder (no totality: some MCSes are incomparable)
- NOT AddCommGroup (no group operation on MCSes)
- NOT IsOrderedAddMonoid (cannot do duration arithmetic)

### TaskFrame D Requirements

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] where
  WorldState : Type*
  task_rel : WorldState → D → WorldState → Prop
  -- Duration arithmetic: task_rel w d₁ u ∧ task_rel u d₂ v → task_rel w (d₁ + d₂) v
```

TaskFrame uses `D` for duration arithmetic:
- `d₁ + d₂` (adding durations)
- `d - e` (duration differences)
- `0 : D` (zero duration)
- `d ≤ e` (comparing durations)

None of these operations make sense for CanonicalMCS (world states cannot be added or compared linearly).

## Recommended Corrections

### High Priority (Active Code)

| Location | Current | Corrected |
|----------|---------|-----------|
| CanonicalFMCS.lean:286 | "for D = CanonicalMCS" | "for FMCS indexed by CanonicalMCS" |
| Completeness.lean:116 | "D = CanonicalMCS (the all-MCS domain)" | "indexed by CanonicalMCS (world-state space)" |
| ROAD_MAP.md:182 | "D = CanonicalMCS" | "indexed by CanonicalMCS" |
| ROAD_MAP.md:209 | "D = CanonicalMCS" | "indexed by CanonicalMCS" |
| ROAD_MAP.md:1258 | "D=CanonicalMCS" | "CanonicalMCS-indexed" |

### Medium Priority (Plans)

| Location | Current | Corrected |
|----------|---------|-----------|
| 02_completeness-plan.md:45 | "FMCS D where D = CanonicalMCS" | "FMCS indexed by CanonicalMCS" |
| 02_completeness-plan.md:53 | "using D = CanonicalMCS" | "using CanonicalMCS-indexed FMCS" |

### Low Priority (Archives)

Do not retroactively update archived research reports. The historical record shows the evolution of understanding.

## Correct Patterns to Use

### Pattern 1: Explicit Role Distinction
```
D = TimelineQuot (temporal domain), W = CanonicalMCS (world-state space)
```

### Pattern 2: Indexing Language for FMCS
```
FMCS indexed by CanonicalMCS
CanonicalMCS-indexed family
family over CanonicalMCS
```

### Pattern 3: Clarifying Comments
```lean
-- Note: In `FMCS CanonicalMCS`, the type parameter is the indexing type (world states),
-- NOT the temporal domain D of TaskFrame (which requires AddCommGroup/LinearOrder).
```

### Pattern 4: Variable Name Differentiation
When discussing both FMCS and TaskFrame parameters:
- Use `I` or `Idx` for FMCS indexing type: `FMCS I where I := CanonicalMCS`
- Reserve `D` for TaskFrame temporal domain: `TaskFrame D where D := TimelineQuot`

## Files Already Using Correct Patterns

The following files demonstrate the correct architectural separation:

1. **SeparatedTaskFrame.lean**: `D = TimelineQuot, W = CanonicalMCS` (line 6)
2. **ClosureSaturation.lean**: "TimelineQuot provides the time domain; CanonicalMCS provides modal structure" (line 754)
3. **AlgebraicBaseCompleteness.lean**: "CanonicalMCS does NOT have AddCommGroup, so we cannot directly use it as D" (line 41)
4. **Several archived reports**: Use `W = CanonicalMCS` or `WorldState := CanonicalMCS` correctly

## Conclusion

The phrase "D = CanonicalMCS" is categorically wrong because:

1. **Different typeclasses**: CanonicalMCS has Preorder; TaskFrame's D needs AddCommGroup + LinearOrder
2. **Different semantic roles**: CanonicalMCS = world states; TaskFrame's D = durations/time
3. **Misleading variable reuse**: Using `D` for both FMCS indexing and TaskFrame temporal domain conflates distinct concepts

The correct terminology is:
- `FMCS indexed by CanonicalMCS` (or `CanonicalMCS-indexed family`)
- `TaskFrame D` with `D = TimelineQuot` (or `D = Int`, `D = Rat`)
- `W = CanonicalMCS` when explicitly separating world states from durations
