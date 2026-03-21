# Implementation Plan: Task #658 (Revised v4)

- **Task**: 658 - Prove indexed family coherence conditions
- **Version**: 004 (Option B2 Integration via Task 681)
- **Status**: [PLANNED]
- **Effort**: 2-3 hours (post-Task 681 completion)
- **Priority**: High
- **Dependencies**: Task 681 (prerequisite)
- **Research Inputs**:
  - specs/658_prove_indexed_family_coherence_conditions/reports/research-004.md (B1 vs B2 analysis)
  - specs/681_redesign_construct_indexed_family_coherent_approach/plans/implementation-003.md (B2 implementation)
- **Artifacts**: plans/implementation-004.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Executive Summary

**Strategy Change**: This plan adopts **Option B2 (Relational Coherent Construction)** as recommended by research-004.md. Instead of attempting to prove coherence for the existing independent-seed construction (proven impossible in v3), this plan integrates Task 681's `CoherentIndexedFamily` approach where coherence is **definitional**.

### Key Insight from Research-004.md

The current `construct_indexed_family` creates MCS at each time point **independently** via Lindenbaum's lemma, which makes arbitrary choices. Two independent extensions can add conflicting formulas, making coherence impossible to prove after construction.

**Solution**: Use Task 681's `CoherentIndexedFamily` where:
1. The `coherent_at` relation directly encodes all four coherence conditions
2. MCS are constructed via `forward_seed`/`backward_seed` which **guarantee** coherence by construction
3. Extraction to `IndexedMCSFamily` is trivial (one-liner per condition)

### Relationship to Task 681

| Aspect | Task 681 | Task 658 |
|--------|----------|----------|
| **Scope** | Create `CoherentConstruction.lean` with new infrastructure | Integrate into existing `IndexedMCSFamily.lean` |
| **Output** | `CoherentIndexedFamily` structure and construction | Working `construct_indexed_family` function |
| **Status** | Prerequisite (must complete first) | Dependent (uses 681's output) |

### Why Previous Plans Failed

| Version | Approach | Why It Failed |
|---------|----------|---------------|
| v001 | Direct proof from seeds | Seeds come from Gamma, not from adjacent MCS |
| v002 | Add T-axioms for local closure | T-axioms provide local closure but not cross-MCS propagation |
| v003 | Propagation lemmas (Option A) | Independent Lindenbaum extensions cannot be coordinated |
| **v004** | **Option B2 via Task 681** | **Coherence is definitional, not post-hoc** |

## Goals & Non-Goals

**Goals**:
- Replace current sorry-based coherence proofs with Task 681's definitional approach
- Update `construct_indexed_family` to use `CoherentIndexedFamily.toIndexedMCSFamily`
- Remove obsolete code from IndexedMCSFamily.lean
- Ensure `lake build` passes

**Non-Goals**:
- Implementing the coherent construction (that's Task 681)
- Proving seed consistency lemmas (accepted sorries match Boneyard)
- Supporting arbitrary time types D (v1 uses D = ℤ)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 681 not completed | Blocking | Medium | This task is dependent; cannot start until 681 completes |
| API mismatch | Low | Low | Task 681 plan already defines compatible interface |
| Type parameter changes | Medium | Low | Phase 1 verification step catches mismatches early |

## Implementation Phases

### Phase 1: Verify Task 681 Completion [NOT STARTED]

**Goal**: Ensure prerequisite Task 681 is complete and provides required interface.

**Precondition**: Task 681 status = [COMPLETED]

**Tasks**:
- [ ] Verify `Bimodal.Metalogic.Representation.CoherentConstruction` module exists
- [ ] Verify `CoherentIndexedFamily` structure is defined
- [ ] Verify `construct_coherent_family` function exists
- [ ] Verify `CoherentIndexedFamily.toIndexedMCSFamily` conversion exists
- [ ] Run `lake build Bimodal.Metalogic.Representation.CoherentConstruction` to confirm compilation

**Verification Commands**:
```bash
lake build Bimodal.Metalogic.Representation.CoherentConstruction
lean_file_outline Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean
```

**Expected Declarations**:
```lean
structure CoherentIndexedFamily (D : Type*) [AddCommGroup D] [LinearOrder D] where ...
def coherent_at (D : Type*) [LinearOrder D] ... : Prop
noncomputable def construct_coherent_family ... : CoherentIndexedFamily ℤ
def CoherentIndexedFamily.toIndexedMCSFamily ... : IndexedMCSFamily D
```

**Timing**: 15 minutes

---

### Phase 2: Update IndexedMCSFamily Imports [NOT STARTED]

**Goal**: Add import for CoherentConstruction module.

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Tasks**:
- [ ] Add import:
  ```lean
  import Bimodal.Metalogic.Representation.CoherentConstruction
  ```
- [ ] Verify compilation still works with new import

**Timing**: 10 minutes

---

### Phase 3: Replace construct_indexed_family [NOT STARTED]

**Goal**: Replace the current sorry-based construction with Task 681's coherent approach.

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Current Code** (approximate lines 400-600):
```lean
-- Current implementation with 4 sorries
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    IndexedMCSFamily D where
  mcs := time_indexed_mcs Gamma h_mcs h_no_G_bot h_no_H_bot
  is_mcs := ...
  forward_G := by sorry  -- BLOCKED: independent Lindenbaum
  backward_H := by sorry -- BLOCKED: independent Lindenbaum
  forward_H := by sorry  -- BLOCKED: independent Lindenbaum
  backward_G := by sorry -- BLOCKED: independent Lindenbaum
```

**Replacement Code**:
```lean
/-- Construct an IndexedMCSFamily from a root MCS.

This uses the coherent construction from CoherentConstruction.lean,
which guarantees coherence by design rather than by post-hoc proof.
The four coherence conditions are trivially extracted from the
`pairwise_coherent` field of `CoherentIndexedFamily`.

**History**:
- v001: Direct proof from seeds (failed - seeds come from Gamma only)
- v002: Added T-axioms for local closure (insufficient for cross-MCS)
- v003: Propagation lemmas / Option A (impossible with independent Lindenbaum)
- v004: Option B2 via Task 681 (coherence definitional)
-/
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
    IndexedMCSFamily ℤ :=
  (construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot).toIndexedMCSFamily
```

**Tasks**:
- [ ] Locate current `construct_indexed_family` definition
- [ ] Replace with one-liner calling `construct_coherent_family`
- [ ] Update type signature if needed (D → ℤ specialization)
- [ ] Update docstring to explain the change and history

**Timing**: 30 minutes

---

### Phase 4: Remove Obsolete Code [NOT STARTED]

**Goal**: Remove helper lemmas and seed definitions that are now redundant.

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Candidates for Removal** (verify not used elsewhere first):
- `time_seed` (replaced by CoherentConstruction's `forward_seed`/`backward_seed`)
- `time_indexed_mcs` (replaced by `construct_coherent_family.mcs`)
- `forward_G_seed_lemma` and similar (replaced by definitional coherence)
- Blocking analysis comments from v002 and v003
- `mcs_closed_temp_t_future` and `mcs_closed_temp_t_past` (moved to CoherentConstruction or no longer needed)

**Tasks**:
- [ ] Identify all obsolete definitions via `lean_hover_info` or Grep
- [ ] Check each for external references
- [ ] Remove unused definitions
- [ ] Keep any definitions that have external dependents

**Timing**: 30 minutes

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Update module docstring and remove obsolete comments.

**Tasks**:
- [ ] Update module docstring to explain coherent construction approach
- [ ] Remove blocking analysis comments from v002 and v003
- [ ] Add reference to CoherentConstruction.lean
- [ ] Document the historical progression through v001-v004
- [ ] Note the mathematical insight: coherence must be definitional, not post-hoc

**Timing**: 20 minutes

---

### Phase 6: Final Verification [NOT STARTED]

**Goal**: Ensure everything compiles and sorries are minimized.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily`
- [ ] Check `lean_diagnostic_messages` for any errors
- [ ] Verify only accepted sorries remain (in CoherentConstruction.lean, not here)
- [ ] Run `lake build` on full project to catch downstream issues

**Verification**:
```bash
lake build Bimodal.Metalogic.Representation.IndexedMCSFamily
lake build
```

**Expected Outcome**:
- No new errors
- Zero sorries in IndexedMCSFamily.lean
- Two sorries in CoherentConstruction.lean (forward_seed_consistent, backward_seed_consistent)

**Timing**: 30 minutes

---

## Testing & Validation

- [ ] Phase 1: Task 681 verified complete
- [ ] Phase 2: Import compiles
- [ ] Phase 3: New construct_indexed_family compiles
- [ ] Phase 4: No regressions from code removal
- [ ] Phase 5: Documentation accurate
- [ ] Phase 6: Full `lake build` passes

## Artifacts & Outputs

- plans/implementation-004.md (this plan)
- Modified: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- summaries/implementation-summary-YYYYMMDD.md (upon completion)

## Dependency Diagram

```
Task 681 (CoherentConstruction.lean)
    │
    ├── CoherentIndexedFamily
    ├── construct_coherent_family
    └── toIndexedMCSFamily
           │
           ▼
Task 658 (IndexedMCSFamily.lean)
    │
    └── construct_indexed_family (uses 681's output)
           │
           ▼
    IndexedMCSFamily with all conditions satisfied
```

## Previous Plan Analysis

**implementation-003.md Status**: [PARTIAL] → BLOCKED

**What Failed**:
- Phase 1: Completed (T-axiom closure lemmas: `mcs_closed_temp_t_future`, `mcs_closed_temp_t_past`)
- Phases 2-6: BLOCKED
- The "propagation lemmas" approach (Option A) is mathematically impossible
- Independent Lindenbaum extensions cannot be coordinated to satisfy coherence

**Key Mathematical Insight** (from research-004.md):
> Lindenbaum's lemma uses Choice to extend consistent sets arbitrarily. Two independent extensions `mcs(t1)` and `mcs(t2)` can add conflicting formulas. If `Gφ ∈ mcs(t1)` but `Gφ ∉ Gamma`, there's no guarantee `φ ∈ mcs(t2)`.

**What This Plan Changes**:
- Abandons Option A entirely
- Delegates coherence infrastructure to Task 681
- Focus shifts from "proving coherence" to "integrating coherent construction"
- Effort drops from 6-8 hours to 2-3 hours (most work done in 681)

## Rollback/Contingency

| Situation | Action |
|-----------|--------|
| Task 681 incomplete | Wait; this task is dependent |
| API mismatch | Coordinate with Task 681 to adjust interface |
| Type parameter issues | May need ℤ specialization; document |
| Full failure | Report in summary; fall back to Option B1 (recursive seeds) |

## Success Criteria

1. ✅ `construct_indexed_family` compiles without sorries
2. ✅ All four coherence conditions satisfied trivially via extraction
3. ✅ `lake build` passes for the full project
4. ✅ IndexedMCSFamily.lean has zero sorries (all in CoherentConstruction.lean)

## Timeline

| Phase | Effort | Cumulative |
|-------|--------|------------|
| Phase 1 | 15 min | 15 min |
| Phase 2 | 10 min | 25 min |
| Phase 3 | 30 min | 55 min |
| Phase 4 | 30 min | 85 min |
| Phase 5 | 20 min | 105 min |
| Phase 6 | 30 min | 135 min |
| **Total** | **~2.25 hours** | |

## References

- research-004.md: Detailed B1 vs B2 comparison, recommends B2
- Task 681 implementation-003.md: Option B2 infrastructure plan
- Boneyard Completeness.lean:2055-2581: canonical_task_rel pattern
- research-002.md (681): Mathematical elegance analysis proving Option A impossible
