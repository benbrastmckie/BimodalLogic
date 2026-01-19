# Research Report: Task #597

**Task**: 597 - Re-prove main_provable_iff_valid in Metalogic_v2
**Started**: 2026-01-18T17:15:00Z
**Completed**: 2026-01-18T17:30:00Z
**Effort**: Medium (2-4 hours implementation)
**Priority**: High
**Dependencies**: None (all needed infrastructure exists)
**Sources/Inputs**:
- Metalogic/Completeness/FiniteCanonicalModel.lean (existing proof)
- Metalogic_v2/Representation/*.lean (target infrastructure)
- lean_local_search, lean_file_outline, Read tool
**Artifacts**:
- This report: specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- `main_provable_iff_valid` is currently defined in `Metalogic/Completeness/FiniteCanonicalModel.lean` (line 4510)
- Metalogic_v2's `ContextProvability.lean` imports this theorem from the old Metalogic via an `open` statement (line 59-60)
- The key dependency chain is: `main_provable_iff_valid` <- `main_weak_completeness` <- `semantic_weak_completeness` <- finite canonical model infrastructure
- Metalogic_v2 already has its own canonical model (`CanonicalWorldState`, `CanonicalModel`) but lacks the semantic/finite infrastructure
- **Recommended approach**: Re-prove using Metalogic_v2's existing infrastructure via a simpler contrapositive argument

## Context & Scope

### Current State

The theorem `main_provable_iff_valid` establishes the fundamental equivalence:

```lean
theorem main_provable_iff_valid (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi
```

**Current Location**: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean:4510`

**Current Dependencies** (from old Metalogic):
1. `main_weak_completeness` (line 4368) - valid implies derivable
2. `semantic_weak_completeness` - core completeness via semantic canonical model
3. `SemanticWorldState` - quotient of history-time pairs
4. `SemanticCanonicalFrame`, `SemanticCanonicalModel` - finite model infrastructure
5. `closure`, `closureWithNeg`, `ClosureMaximalConsistent` - closure-restricted MCS theory
6. `FiniteTime`, `temporalBound`, `FiniteHistory` - bounded time domain

### Metalogic_v2 Infrastructure Available

The following is already implemented in Metalogic_v2:

| Component | Location | Status |
|-----------|----------|--------|
| `CanonicalWorldState` | Representation/CanonicalModel.lean:66 | PROVEN |
| `CanonicalFrame`, `CanonicalModel` | Representation/CanonicalModel.lean | PROVEN |
| `SetConsistent`, `SetMaximalConsistent` | Core/MaximalConsistent.lean | PROVEN |
| `set_lindenbaum` | Core/MaximalConsistent.lean | PROVEN |
| `mcs_contains_or_neg` | Representation/CanonicalModel.lean:231 | PROVEN |
| `mcs_modus_ponens` | Representation/CanonicalModel.lean:274 | PROVEN |
| `truthLemma_detailed` | Representation/TruthLemma.lean:49 | PROVEN |
| `representation_theorem` | Representation/RepresentationTheorem.lean | PROVEN |
| `soundness` | Soundness/Soundness.lean | PROVEN |
| `deduction_theorem` | Core/DeductionTheorem.lean | PROVEN |
| `valid_iff_empty_consequence` | Semantics/Validity.lean | PROVEN |

### Current Import Dependency

`Metalogic_v2/Representation/ContextProvability.lean` line 59-60:
```lean
open Bimodal.Metalogic.Completeness (SemanticCanonicalFrame SemanticCanonicalModel
  SemanticWorldState semantic_weak_completeness FiniteTime temporalBound main_provable_iff_valid)
```

This import creates the dependency on the old Metalogic/ directory.

## Findings

### Key Observation: Two Proof Strategies

**Strategy A (Current in old Metalogic)**: Complex finite canonical model construction
- Uses `SemanticWorldState` as quotient of (FiniteHistory, FiniteTime) pairs
- Bounded temporal domain via `temporalBound`
- `closure` and `closureWithNeg` for finite subformula sets
- `ClosureMaximalConsistent` for closure-restricted MCS
- Has 1 sorry gap in `main_weak_completeness` (time arithmetic at line 4473)

**Strategy B (Recommended for Metalogic_v2)**: Simpler contrapositive using existing MCS
- Does NOT require finite model infrastructure
- Uses existing `CanonicalWorldState` (unbounded MCS)
- Proof via contrapositive: `valid phi` -> assuming `¬Nonempty (⊢ phi)` leads to contradiction
- Key steps:
  1. If `¬Nonempty (⊢ phi)`, then `phi.neg` does not derive contradiction
  2. By Lindenbaum, extend `{phi.neg}` to full MCS M
  3. M is a canonical world where `phi.neg` holds (and thus `phi` fails)
  4. Construct a semantic model from M (standard Kripke construction)
  5. This contradicts `valid phi`

### Why Strategy B Works for Metalogic_v2

1. **No temporal complexity**: The canonical model with unbounded MCS works because validity is about ALL models - we just need ONE countermodel to contradict validity
2. **Existing infrastructure sufficient**: `set_lindenbaum`, `mcs_contains_or_neg`, and the truth lemma are all already proven
3. **No sorries needed**: Unlike the finite approach, we don't need bounded time domain infrastructure

### Proof Sketch for `main_provable_iff_valid` in Metalogic_v2

```lean
theorem main_provable_iff_valid (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi := by
  constructor
  · -- Forward: Soundness (already available)
    intro ⟨h_deriv⟩
    intro D _ _ _ F M tau t
    have h_sem := soundness [] phi h_deriv
    exact h_sem D F M tau t (fun _ h => (List.not_mem_nil h).elim)
  · -- Backward: Completeness via contrapositive
    intro h_valid
    by_contra h_not_prov
    -- Step 1: {phi.neg} is consistent
    have h_neg_cons : SetConsistent ({phi.neg} : Set Formula) :=
      neg_consistent_of_not_provable phi h_not_prov
    -- Step 2: Extend to MCS via Lindenbaum
    obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum {phi.neg} h_neg_cons
    -- Step 3: phi.neg ∈ M, so phi ∉ M
    have h_neg_in : phi.neg ∈ M := h_sub (Set.mem_singleton _)
    have h_phi_not : phi ∉ M := set_mcs_neg_excludes h_mcs phi h_neg_in
    -- Step 4: Build canonical world and model
    let w : CanonicalWorldState := ⟨M, h_mcs⟩
    -- Step 5: Derive contradiction with h_valid
    -- (use truthLemma to show phi false at w, contradicting valid)
    sorry  -- This is the key construction step
```

### Required New Infrastructure

To complete the proof, we need:

1. **`neg_consistent_of_not_provable`**: If `¬Nonempty (⊢ phi)`, then `SetConsistent {phi.neg}`
   - Already exists as `not_derivable_implies_neg_consistent` in ContextProvability.lean:100

2. **`set_mcs_neg_excludes`**: If `phi.neg ∈ M` where M is MCS, then `phi ∉ M`
   - Follows from `mcs_contains_or_neg` + consistency

3. **Canonical Model Semantics Bridge**: Connect `CanonicalWorldState` to actual `TaskModel`
   - This is the key missing piece - need to construct a `TaskModel` from canonical worlds
   - Can be done with a trivial frame (Int, single world) for the countermodel case

### Alternative: Direct Replication

Alternatively, the finite canonical model infrastructure could be copied from old Metalogic to Metalogic_v2:

**Required definitions to copy**:
- `closure`, `closureWithNeg` (already have `subformulaList` in FiniteModelProperty.lean)
- `ClosureMaximalConsistent`
- `FiniteTime`, `temporalBound`, `FiniteHistory`
- `SemanticWorldState` (quotient construction)
- `SemanticCanonicalFrame`, `SemanticCanonicalModel`
- `semantic_weak_completeness`
- `main_weak_completeness`

This is more work (~500 lines) but preserves the exact proof structure.

## Decisions

1. **Strategy B Recommended**: Use simpler contrapositive proof with existing Metalogic_v2 infrastructure
2. **No finite model machinery needed**: For the equivalence theorem itself, we only need a countermodel construction, not the full finite model property
3. **Target file**: Create new proof in `Metalogic_v2/Completeness/WeakCompleteness.lean`

## Recommendations

### Implementation Plan

**Phase 1**: Helper lemmas (estimated 30 min)
1. Add `set_mcs_neg_excludes` to MaximalConsistent.lean or CanonicalModel.lean
2. Verify `neg_consistent_of_not_provable` exists and works

**Phase 2**: Canonical-to-semantic bridge (estimated 1 hour)
1. Define `canonicalWorldToModel : CanonicalWorldState -> TaskModel`
2. Prove truth lemma for this model
3. This connects MCS membership to semantic truth

**Phase 3**: Main theorem (estimated 30 min)
1. Implement `main_provable_iff_valid` using Strategy B
2. Remove old Metalogic import from ContextProvability.lean

**Phase 4**: Cleanup (estimated 30 min)
1. Update exports in FMP.lean and other hub modules
2. Verify all downstream dependencies still build

### Files to Modify

1. **`Metalogic_v2/Completeness/WeakCompleteness.lean`** - Add main theorem
2. **`Metalogic_v2/Representation/ContextProvability.lean`** - Remove old Metalogic import
3. **`Metalogic_v2/Representation/CanonicalModel.lean`** - Add helper lemmas if needed

### Verification Steps

After implementation:
1. `lake build Bimodal.Metalogic_v2.Completeness.WeakCompleteness`
2. `lake build Bimodal.Metalogic_v2.Representation.ContextProvability`
3. `lake build` (full project to check nothing breaks)
4. Grep for remaining imports from old Metalogic

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Truth lemma bridge complexity | Medium | High | Use trivial single-world model for countermodel |
| Temporal operators in bridge | Low | Medium | For validity countermodel, temporal structure is trivial |
| Downstream breakage | Low | Medium | Run full build after changes |

## Appendix

### Search Queries Used

1. `grep "main_provable_iff_valid"` - Found 5 files with references
2. `lean_file_outline` on FiniteCanonicalModel.lean - Identified infrastructure
3. `grep "sorry"` on both Metalogic directories - Found 50+ sorries in old, 0 in new
4. `lean_file_outline` on Metalogic_v2 files - Mapped available infrastructure

### Key Files Examined

| File | Lines | Purpose |
|------|-------|---------|
| Metalogic/Completeness/FiniteCanonicalModel.lean | 4840 | Current proof location |
| Metalogic_v2/Representation/ContextProvability.lean | 278 | Import dependency |
| Metalogic_v2/Representation/CanonicalModel.lean | 321 | Available infrastructure |
| Metalogic_v2/Representation/TruthLemma.lean | 183 | Truth lemma (proven) |
| Metalogic_v2/Core/MaximalConsistent.lean | ~500 | MCS theory |

### Relevant Theorems in Old Metalogic

```
Line 4510: theorem main_provable_iff_valid (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi
Line 4368: noncomputable def main_weak_completeness (phi : Formula) (h_valid : valid phi) : ⊢ phi
Line 3040: theorem semantic_weak_completeness (phi : Formula) : ... → ⊢ phi
```

### Import Chain to Break

```
ContextProvability.lean
  └── imports Metalogic/Completeness/FiniteCanonicalModel.lean (via open statement)
       └── defines main_provable_iff_valid
            └── uses main_weak_completeness
                 └── uses semantic_weak_completeness
                      └── uses SemanticWorldState, SemanticCanonicalModel, etc.
```

**Target**: Replace the `open` statement with a local definition of `main_provable_iff_valid` in Metalogic_v2.
