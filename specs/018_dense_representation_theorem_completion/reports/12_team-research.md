# Research Report: CanonicalTask vs CanonicalR — ExistsTask Perspective

**Task**: 18 - dense_representation_theorem_completion
**Date**: 2026-03-21
**Mode**: Team Research (3 teammates)
**Session**: sess_1774119590_f7e705
**Focus**: Identify the upstream mistake of CanonicalR over-reliance, refactoring to ExistsTask naming, and correct TaskFrame-based closure design

## Summary

The user's observation is mathematically precise and confirmed by all three teammates. The closure of the staged timeline under F/P-witnesses converges to all of CanonicalMCS **because CanonicalR is the existential shadow of CanonicalTask, losing all duration information**. The correct fix is to make CanonicalTask (three-place task relation) primary and treat CanonicalR as a derived convenience renamed to `ExistsTask`.

Key findings:
1. **The duration-coarse parametric_canonical_task_rel collapses ALL positive durations to the same relation** — the duration parameter d is semantically vacuous beyond its sign (Teammate A)
2. **1,737 occurrences of CanonicalR across 59 files** — substantial refactoring scope but clear pattern; CanonicalRecovery.lean already documents the two-level architecture (Teammate B)
3. **CanonicalTask-based closure preserves distance information and converges to a proper subset** — the fix for the closure blowup is to use the metric-aware three-place relation, not the binary existential shadow (Teammate C)
4. **DenseTask IS the correct dense analogue of CanonicalTask** — deterministic via Cantor isomorphism, already implemented in DenseTaskRelation.lean (All teammates)

## Key Findings

### 1. CanonicalR = ExistsTask: The Existential Shadow (High Confidence)

All teammates confirmed:
```
CanonicalR(u, v)  ≡  ∃ d > 0, task_rel(u, d, v)  ≡  ExistsTask(u, v)
```

| Property | CanonicalTask (Three-Place) | CanonicalR/ExistsTask (Two-Place) |
|----------|----------------------------|----------------------------------|
| Duration info | Preserved (specific d ∈ D) | Lost (sign only) |
| Closure behavior | Constrained by metric | Blows up to all MCSes |
| Witnesses | At specific distance | "Somewhere" in future |
| Determinism | Bounded by formula depth | Unbounded |

### 2. Duration-Coarse Parametric Relation is the Root Problem (High Confidence)

Teammate A identified that `parametric_canonical_task_rel` (ParametricCanonical.lean:85) maps ALL positive durations to the same CanonicalR:

```lean
def parametric_canonical_task_rel (M : WorldState) (d : D) (N : WorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val      -- ALL positive d → same relation
  else if d < 0 then CanonicalR N.val M.val  -- ALL negative d → same relation
  else M = N
```

This is **maximally non-deterministic** — the duration parameter is semantically vacuous beyond its sign. Report 19 correctly identified this as a design problem.

### 3. CanonicalR Refactoring Scope (High Confidence)

Teammate B's audit found:
- **59 files** reference CanonicalR
- **1,737 total occurrences**
- **~35 active files** (rest are Boneyard)
- **CanonicalRecovery.lean already documents** the intended Layer 1 (CanonicalTask) / Layer 2 (CanonicalR) architecture

Three options ranked by effort:
| Option | Description | Effort |
|--------|-------------|--------|
| A | Full rename CanonicalR → ExistsTask | 4-8 hours |
| B | Add `abbrev ExistsTask := CanonicalR` + docs | 1-2 hours |
| C | Documentation-only updates | 30 min |

### 4. CanonicalMCS as Domain Has World/Time Conflation (High Confidence)

Teammate C identified a fundamental problem with the "use CanonicalMCS as domain" approach from report-08:

> CanonicalMCS is both the world type AND the time type. The TaskFrame structure separates these: `WorldState` and `D` are different types. Using CanonicalMCS for both creates a degenerate structure.

TaskFrame requires:
- `WorldState : Type` — the semantic state
- `D : Type` — the duration domain (ordered abelian group)
- `task_rel : WorldState → D → WorldState → Prop`

Using CanonicalMCS for D means durations ARE world states, which breaks the separation.

### 5. DenseTask Is the Correct Dense CanonicalTask (High Confidence)

All teammates confirmed DenseTask (DenseTaskRelation.lean) is the correct dense analogue:

| Property | CanonicalTask (Discrete) | DenseTask (Dense) |
|----------|-------------------------|-------------------|
| Duration Type | ℤ | ℚ (via TimelineQuot) |
| Determinism | Non-deterministic | Deterministic (unique target) |
| Building Block | Succ chains | Group addition via Cantor iso |
| TaskFrame Instance | `CanonicalTaskTaskFrame` | `DenseTaskFrame` |

### 6. Correct Architecture: TimelineQuot + DenseTask (High Confidence)

With DenseTask as primary:

```
Layer 1: TimelineQuot ≃o ℚ (time domain with group structure)
Layer 2: DenseTask(t, q, s) := t + q = s (deterministic task relation)
Layer 3: FMCS over TimelineQuot (mcs assignment to timepoints)
Layer 4: BFMCS via closedFlags (modal saturation)
Layer 5: ExistsTask(u, v) := ∃ q > 0, DenseTask(u, q, v) (derived convenience)
```

**The m > 2k gap is at Layer 3** (FMCS temporal coherence), not at Layers 1-2 (task structure).

### 7. Eager Processing Resolves the FMCS Gap (Medium Confidence)

Teammate C and the dovetailed construction approach: modify the staged construction to process ALL F-obligations when a point is added, rather than one per stage. This eliminates the m > 2k gap at its source:

- DovetailedBuild.lean already implements this approach
- DovetailedCoverageReach.lean needs completion (density recursion termination)
- Estimated 4-6 hours to complete

### 8. derive_F_to_FF Derivation Chain (High Confidence)

All teammates confirm the 8-10 step derivation:
1. Density axiom: `G(G(¬ψ)) → G(¬ψ)`
2. DNE + temporal nec + K-dist: `G(¬¬G(¬ψ)) → G(G(¬ψ))`
3. Chain + contrapose: `F(ψ) → F(F(ψ))`

Estimated 1-2 hours. Blocks `density_F_to_FF` which is needed regardless of approach.

## Synthesis

### Conflict 1: CanonicalMCS vs TimelineQuot as Domain

**Teammate A**: Use CanonicalMCS, generalize TaskFrame to drop AddCommGroup.
**Teammate C**: CanonicalMCS conflates world and time — TaskFrame requires separation.

**Resolution**: Teammate C is correct. The TaskFrame architecture explicitly separates WorldState from D (duration domain). Using CanonicalMCS for both breaks this separation. The correct architecture keeps:
- **D = TimelineQuot** (time domain with ℚ group structure)
- **WorldState = CanonicalMCS** (or the MCSes assigned to timepoints)
- **task_rel = DenseTask** (deterministic via Cantor isomorphism)

### Conflict 2: Closure Operator vs Eager Processing

**Teammate A**: CanonicalTask-based closure would be geometrically constrained.
**Teammate C**: The gap is FMCS saturation, not closure on MCSes — eager processing is the fix.

**Resolution**: Both are partially correct. The insight that closure under CanonicalR blows up because ExistsTask forgets duration is correct (A). But the practical fix is NOT to build a new closure operator — it's to ensure the staged construction satisfies FMCS temporal coherence from the start (C). Eager processing (dovetailed construction) achieves this.

### Conflict 3: Refactoring Scope

**Teammate B**: Option B (alias) is most practical.
**User's intent**: Full rename to ExistsTask for clarity.

**Resolution**: Start with Option B (alias + documentation) as an immediate step, then gradually migrate to ExistsTask in new code. The full rename (Option A, 4-8 hours) should be a separate task, not part of task 18.

### Gaps Identified

1. **DovetailedCoverageReach.lean completion**: The dovetailed construction exists but has sorry gaps in density recursion termination. Must be completed for eager processing.
2. **CanonicalR ↔ ExistsTask equivalence proof**: `canonicalR_implies_canonicalTask_forward` is still sorry in CanonicalRecovery.lean. Need this for formal equivalence.
3. **parametric_canonical_task_rel replacement**: If DenseTask replaces the duration-coarse relation, how does the parametric truth lemma change?
4. **Comments/docstrings**: ~49 files need comment updates to reference ExistsTask derivation.

## Recommendations

### For Task 18 (Dense Representation Theorem):

**Phase 0: derive_F_to_FF** (1-2h)
- Mechanical derivation chain in CantorPrereqs.lean
- Unblocks everything else

**Phase 1: ExistsTask Alias** (1h)
- Add `abbrev ExistsTask := CanonicalR` in CanonicalFrame.lean
- Update CanonicalR docstring to note derivation from CanonicalTask
- Update key comments in CanonicalFMCS.lean, ParametricCanonical.lean

**Phase 2: Complete Dovetailed Coverage** (4-6h)
- Fix DovetailedCoverageReach.lean density recursion termination
- This ensures every (point, formula) pair is eventually processed
- Eliminates the m > 2k gap by construction

**Phase 3: Wire Forward_F/Backward_P** (2-3h)
- Use dovetailed coverage to prove temporal coherence
- Archive the ClosureSaturation.lean exploration code (300+ lines of dead comments)
- Complete BFMCS construction

**Phase 4: Wire Dense Completeness** (1-2h)
- Complete `timelineQuot_not_valid_of_neg_consistent`
- Instantiate parametric truth lemma
- Wire `dense_completeness_theorem`

### For Separate Future Task (CanonicalR → ExistsTask Full Rename):

- Create a new task for the full mechanical rename (4-8h)
- Rename CanonicalR → ExistsTask in all 59 files
- Rename CanonicalR_past → ExistsTask_past
- Update all comments to clarify the derivation hierarchy

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Math: CanonicalTask vs CanonicalR | completed | high | Duration-coarse relation is semantically vacuous; DenseTask resolves this |
| B | Lean: Refactoring audit | completed | high | 1,737 occurrences, 59 files; alias approach most practical |
| C | Logic: TaskFrame-based closure | completed | high | World/time conflation blocks CanonicalMCS approach; eager processing is correct fix |

## Individual Reports

- [12_teammate-a-findings.md](12_teammate-a-findings.md) — Math analysis: duration-coarse collapse, DenseTask as primary, metric-constrained closure
- [12_teammate-b-findings.md](12_teammate-b-findings.md) — Codebase audit: 1,737 CanonicalR occurrences, refactoring options, DenseTask relationship
- [12_teammate-c-findings.md](12_teammate-c-findings.md) — Logic analysis: world/time conflation, eager processing, correct infrastructure design
