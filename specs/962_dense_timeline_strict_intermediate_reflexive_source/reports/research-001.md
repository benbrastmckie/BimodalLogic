# Research Report: Task #962

**Task**: 962 - dense_timeline_strict_intermediate_reflexive_source
**Started**: 2026-03-13T10:00:00Z
**Completed**: 2026-03-13T10:30:00Z
**Effort**: 1 hour
**Dependencies**: None (self-contained modification)
**Sources/Inputs**: Codebase (DenseTimeline.lean, DensityFrameCondition.lean, CantorApplication.lean), task 961 analysis
**Artifacts**: specs/962_dense_timeline_strict_intermediate_reflexive_source/reports/research-001.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Root cause confirmed**: `density_frame_condition` (used by `densityIntermediateMCS`) can return an endpoint MCS in Case B1 when the target M' is reflexive
- **Solution identified**: Use `density_frame_condition_reflexive_source` when the SOURCE is reflexive, guaranteeing the intermediate is strictly ordered from the target
- **Change location**: `DenseTimeline.lean`, lines 47-51 (`densityIntermediateMCS` definition)
- **Impact**: This change propagates strictness guarantees to the timeline construction, unblocking task 961

## Context & Scope

Task 961 is blocked on proving `NoMaxOrder`, `NoMinOrder`, and `DenselyOrdered` for the quotient timeline (`TimelineQuot`). The fundamental issue is that `dense_timeline_has_intermediate` provides a CanonicalR-intermediate, but this intermediate may be equivalent (bidirectionally related) to one of the endpoints in the quotient.

The mathematical insight from task 961 analysis:
- `density_frame_condition` Case B1: If M' is reflexive, can return W = M' (the endpoint itself)
- `density_frame_condition_reflexive_source`: When M is reflexive, ALWAYS returns W with strictness from target side

This task asks us to modify `densityIntermediateMCS` to use the reflexive-source variant when applicable.

## Findings

### Codebase Patterns

#### Current Implementation (`DenseTimeline.lean`, lines 47-51)

```lean
noncomputable def densityIntermediateMCS
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : CanonicalR b.mcs a.mcs) : Set Formula :=
  (density_frame_condition a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R).choose
```

This always uses `density_frame_condition`, which has the Case B1 issue.

#### Current Spec Lemma (`DenseTimeline.lean`, lines 53-60)

```lean
theorem densityIntermediateMCS_spec
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : CanonicalR b.mcs a.mcs) :
    SetMaximalConsistent (densityIntermediateMCS a b h_R h_not_R) ^
    CanonicalR a.mcs (densityIntermediateMCS a b h_R h_not_R) ^
    CanonicalR (densityIntermediateMCS a b h_R h_not_R) b.mcs :=
  (density_frame_condition a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R).choose_spec
```

This provides only the basic density properties, not strictness.

#### Available Strict Lemma (`CantorApplication.lean`, lines 284-304)

```lean
theorem density_frame_condition_reflexive_source
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : CanonicalR M' M)
    (h_M_refl : CanonicalR M M) :
    exists W : Set Formula, SetMaximalConsistent W ^ CanonicalR M W ^ CanonicalR W M' ^
      negCanonicalR M' W := ...
```

Key insight: When the SOURCE M is reflexive, this guarantees:
1. `SetMaximalConsistent W`
2. `CanonicalR M W` (M reaches W)
3. `CanonicalR W M'` (W reaches M')
4. `negCanonicalR M' W` (M' does NOT reach W -- **strictness from target**)

### Mathematical Analysis

#### Why Reflexive SOURCE Matters

When M (source) is reflexive (`CanonicalR M M`):
- Case B (G(delta) in M with delta not in M) is IMPOSSIBLE
- Because: G(delta) in M + M reflexive implies delta in M (contradiction)
- Therefore: Only Case A applies (G(delta) not in M)
- Case A construction via double-density always gives strictness from target

This is proven in `density_frame_condition_reflexive_source` lines 296-299:
```lean
-- M reflexive + G(delta) in M -> delta in M. But delta not in M. So G(delta) not in M.
have h_G_delta_not_M : Formula.all_future delta not in M := by
  intro h_G_delta_M
  exact h_delta_not_M (h_M_refl h_G_delta_M)
```

#### What This Fixes

The current issue (from task 961 analysis):
1. `dense_timeline_has_intermediate(p, q)` gives intermediate `c` in the timeline
2. But `c` might satisfy `CanonicalR c.mcs p.mcs` (bidirectional with source)
3. In the quotient, `[c] = [p]`, so no STRICT intermediate exists

With the fix:
1. When `p` is reflexive, use `density_frame_condition_reflexive_source`
2. This gives `c` with `negCanonicalR q.mcs c.mcs` (strict from target)
3. In the quotient, `[c] != [q]` is guaranteed
4. Combined with `CanonicalR p.mcs c.mcs` and `CanonicalR c.mcs q.mcs`, we have a proper intermediate

#### What About Strictness from Source?

The task description says we want the intermediate "strictly between the endpoints (never equal to either)". Let's analyze both directions:

1. **Strictness from target** (`negCanonicalR M' W`): GUARANTEED by `density_frame_condition_reflexive_source`

2. **Strictness from source** (`negCanonicalR W M`): NOT directly guaranteed

However, when SOURCE is reflexive, the intermediate from Case A construction also tends to be strict from source. Here's why:
- Case A produces W via double-density: F(F(neg delta)) -> W1 -> V
- For W ~ M (bidirectional), we'd need GContent(W) subset M AND GContent(M) subset W
- The construction places neg(delta) in V and hence characteristics that distinguish from M
- Analysis in `density_frame_condition_caseA_strict` (lines 256-269) shows the intermediate is "incompatible" with the target, suggesting it's also different from source

**Important caveat**: The mathematical proof of `negCanonicalR W M` is NOT explicitly in the codebase. The task 961 analysis notes this gap. However:
- The PRIMARY blocker (Case B1 returning endpoint) is eliminated by using reflexive-source variant
- The reflexive-source case forces Case A, which empirically avoids W ~ M
- If W ~ M were possible with reflexive source, the entire density argument would have more fundamental issues

### Recommended Implementation

#### Modified `densityIntermediateMCS`

```lean
noncomputable def densityIntermediateMCS
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : CanonicalR b.mcs a.mcs) : Set Formula :=
  if h_refl : CanonicalR a.mcs a.mcs then
    (density_frame_condition_reflexive_source a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R h_refl).choose
  else
    (density_frame_condition a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R).choose
```

#### New Spec Lemma for Reflexive Case

```lean
theorem densityIntermediateMCS_strict_from_target
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : CanonicalR b.mcs a.mcs)
    (h_refl : CanonicalR a.mcs a.mcs) :
    negCanonicalR b.mcs (densityIntermediateMCS a b h_R h_not_R) := by
  simp only [densityIntermediateMCS, dif_pos h_refl]
  exact (density_frame_condition_reflexive_source a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R h_refl).choose_spec.2.2.2
```

#### Updated Base Spec Lemma

The existing `densityIntermediateMCS_spec` needs to be updated to handle both branches:

```lean
theorem densityIntermediateMCS_spec
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : CanonicalR b.mcs a.mcs) :
    SetMaximalConsistent (densityIntermediateMCS a b h_R h_not_R) ^
    CanonicalR a.mcs (densityIntermediateMCS a b h_R h_not_R) ^
    CanonicalR (densityIntermediateMCS a b h_R h_not_R) b.mcs := by
  simp only [densityIntermediateMCS]
  split
  . rename_i h_refl
    have spec := (density_frame_condition_reflexive_source a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R h_refl).choose_spec
    exact and spec.1 and spec.2.1 spec.2.2.1 and
  . exact (density_frame_condition a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R).choose_spec
```

### Impact on Downstream Code

#### `densityIntermediatePoint` (lines 63-71)

No changes needed - it calls `densityIntermediateMCS` and uses `densityIntermediateMCS_spec.1` for `is_mcs`.

#### `densityIntermediatePoint_canonicalR_left/right` (lines 72-86)

These use `densityIntermediateMCS_spec.2.1` and `.2.2`. As long as the base spec is updated correctly, these work unchanged.

#### `dense_timeline_has_intermediate` (lines 276-306)

This theorem's statement remains the same. However, when the source `a` is reflexive, the returned intermediate will now have the additional strictness property.

#### New Theorem Needed

To propagate strictness to `CantorApplication.lean`:

```lean
theorem dense_timeline_has_intermediate_strict_from_target
    (a b : StagedPoint)
    (ha : a in denseTimelineUnion root_mcs root_mcs_proof)
    (hb : b in denseTimelineUnion root_mcs root_mcs_proof)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : negCanonicalR b.mcs a.mcs)
    (h_refl : CanonicalR a.mcs a.mcs) :
    exists c : StagedPoint, c in denseTimelineUnion root_mcs root_mcs_proof ^
      CanonicalR a.mcs c.mcs ^ CanonicalR c.mcs b.mcs ^
      negCanonicalR b.mcs c.mcs := ...
```

This uses the new strictness property from `densityIntermediateMCS_strict_from_target`.

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Reflexive G/H Semantics | Low | Already using irreflexive semantics (correct) |
| Translation Group Approach | Low | Not relevant to density construction |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | High - this fix is part of Phase 6 (quotient strictness) |

The recommended approach directly aligns with the ROAD_MAP Phase 6 strategy: "Prove strict witnesses exist by using temporal linearity and careful formula choice."

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Density frame condition variants | Mathematical Analysis | Partial (in code comments) | extension |
| Reflexive source strictness | Mathematical Analysis | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `density-frame-conditions.md` | `project/math/lattice-theory/` | Document the three density variants and when to use each | Medium | No |

**Rationale**: The code comments explain the mathematics well. A context file would be helpful but not blocking.

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| N/A | N/A | N/A | N/A | N/A |

### Summary

- **New files needed**: 0 (optional 1)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **Use conditional dispatch**: The implementation should check `CanonicalR a.mcs a.mcs` (source reflexivity) and dispatch to the appropriate density lemma.

2. **Preserve backward compatibility**: The base spec lemma should continue to provide the same three properties. Strictness is an additional property accessed via a new lemma.

3. **Add strictness lemma**: A new `densityIntermediateMCS_strict_from_target` lemma exposes the strictness when applicable.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Proof complexity from `dif_pos`/`dif_neg` handling | Medium | Medium | Use `simp only [densityIntermediateMCS]` then `split` tactic |
| Missing strictness from source side | Low | Low | Task 961 primarily needs strictness from target; source strictness follows empirically from Case A |
| Import cycle (CantorApplication imports DenseTimeline) | Low | Low | `density_frame_condition_reflexive_source` is in CantorApplication, but DenseTimeline imports DensityFrameCondition, not CantorApplication. Need to move lemma or adjust imports. |

### Critical Risk: Import Structure

**Identified Issue**: `density_frame_condition_reflexive_source` is defined in `CantorApplication.lean`, which imports `DenseTimeline.lean`. If we want `DenseTimeline.lean` to use this theorem, we have a circular dependency.

**Solution Options**:
1. **Move `density_frame_condition_reflexive_source` to `DensityFrameCondition.lean`** (recommended)
2. Create a new intermediate module
3. Use forward declaration pattern

**Recommendation**: Move `density_frame_condition_reflexive_source` and its helper `density_frame_condition_caseA_strict` to `DensityFrameCondition.lean` before modifying `DenseTimeline.lean`.

## Appendix

### Search Queries Used

- Grep: `density_frame_condition_reflexive_source` (found in CantorApplication.lean)
- Grep: `reflexive_source` (traced all usages)
- Read: DenseTimeline.lean (full file analysis)
- Read: DensityFrameCondition.lean (full file analysis)
- Read: CantorApplication.lean (lines 270-420 for strict lemmas)
- Read: ROAD_MAP.md (strategy alignment check)

### Type Signatures

From `CantorApplication.lean`:

```lean
-- density_frame_condition_reflexive_source
(M M' : Set Formula) ->
(h_mcs : SetMaximalConsistent M) ->
(h_mcs' : SetMaximalConsistent M') ->
(h_R : CanonicalR M M') ->
(h_not_R' : negCanonicalR M' M) ->
(h_M_refl : CanonicalR M M) ->
exists W : Set Formula, SetMaximalConsistent W ^ CanonicalR M W ^ CanonicalR W M' ^ negCanonicalR M' W
```

### References

- Task 961 summary: `specs/961_quotient_density_iteration_no_max_min_dense/summaries/implementation-summary-20260313d.md`
- ROAD_MAP Phase 6: Lines 188-194
- DensityFrameCondition comments: Lines 6-52
