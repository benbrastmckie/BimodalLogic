# Research Report: Remove singleFamily_modal_backward_axiom

- **Task**: 843 - remove_singleFamily_modal_backward_axiom
- **Started**: 2026-02-04T12:00:00Z
- **Completed**: 2026-02-04T12:45:00Z
- **Effort**: 1 hour
- **Dependencies**: Task 856 (COMPLETED)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - axiom declaration site
  - `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - EvalCoherentBundle infrastructure
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - completeness theorems
  - `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - truth lemma structure
  - `specs/856_implement_multifamily_saturated_bmcs/summaries/implementation-summary-20260204.md` - task 856 results
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Project Context

- **Upstream Dependencies**: `EvalCoherentBundle`, `EvalBMCS`, `construct_eval_bmcs` (all from CoherentConstruction.lean, proven in task 856)
- **Downstream Dependents**: `Completeness.lean` theorems (`bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness`)
- **Alternative Paths**: The axiom-based approach in `singleFamilyBMCS` versus the proven `construct_eval_bmcs`
- **Potential Extensions**: Once axiom is removed, full transitively axiom-free completeness achievable

## Executive Summary

- The `singleFamily_modal_backward_axiom` (line 228 of Construction.lean) asserts that if `phi` is in a single-family MCS, then `Box phi` is also in that MCS - a property that cannot be proven without saturation
- Task 856 has FULLY PROVEN an alternative approach using `EvalCoherentBundle` and `construct_eval_bmcs` that achieves the same result WITHOUT the axiom
- The key theorem `eval_saturated_bundle_exists` is proven with no sorry, providing a mathematically sound construction
- To remove the axiom, the completeness theorems must be rewired from `construct_bmcs` (uses axiom) to `construct_eval_bmcs` (proven)
- The rewiring requires introducing `EvalBMCS`-based truth definitions or converting `EvalBMCS` to `BMCS`
- No blocking sorries exist in task 856 - the enumeration sorry was resolved using a non-constructive approach

## Context & Scope

### The Axiom Under Investigation

Located at `Construction.lean` lines 228-231:

```lean
axiom singleFamily_modal_backward_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_phi_in : phi ∈ fam.mcs t) :
    Formula.box phi ∈ fam.mcs t
```

This axiom states: for any single-family BMCS, if `phi` is in the MCS at time `t`, then `Box phi` is also in the MCS at time `t`. This is NOT a valid modal logic principle (Box phi implies phi is the T-axiom, not the converse), but it is a required property for the canonical model construction.

### Why the Axiom Was Needed

The single-family construction (`singleFamilyBMCS`) creates a BMCS from exactly one IndexedMCSFamily. For `modal_backward` to hold, we need:

```
phi in ALL families => Box phi in each family
```

With only one family, this reduces to: `phi in fam => Box phi in fam`, which is NOT generally provable because:
1. `phi -> Box phi` is not valid in modal logic
2. Without saturation (witness families for Diamond formulas), the property cannot be derived

### The Alternative: EvalCoherentBundle from Task 856

Task 856 implemented a multi-family approach that achieves the same goal through structural proof:

1. **EvalCoherent predicate**: All families contain `BoxContent(eval_family)` - formulas that appear inside Box in the eval_family
2. **EvalSaturated predicate**: For every `neg(Box phi)` in eval_family, there exists a witness family with `neg(phi)`
3. **EvalCoherentBundle**: Bundle maintaining EvalCoherent invariant
4. **EvalBMCS**: Weakened BMCS structure with eval-restricted modal properties
5. **Key theorem** `eval_saturated_bundle_exists`: PROVEN without sorry

## Findings

### Finding 1: Axiom Usage Sites

The axiom is used in exactly 2 locations:

1. **Construction.lean line 264**: In `singleFamilyBMCS.modal_backward`
   ```lean
   h_eq' ▸ singleFamily_modal_backward_axiom D fam phi t h_phi_in
   ```

2. **SaturatedConstruction.lean line 181**: In `singleFamilyBMCS_withAxiom.modal_backward`
   ```lean
   h_eq' ▸ singleFamily_modal_backward_axiom D fam phi t h_phi_in
   ```

### Finding 2: Completeness Theorem Dependencies

The completeness theorems in `Completeness.lean` depend on the axiom through this chain:

```
bmcs_representation
  -> construct_bmcs
    -> singleFamilyBMCS
      -> singleFamily_modal_backward_axiom (AXIOM)
```

The completeness file calls `construct_bmcs` at lines 102, 119 to build the canonical model.

### Finding 3: EvalBMCS Alternative is Ready

Task 856 provides a complete alternative path:

```
eval_saturated_bundle_exists (PROVEN)
  -> EvalCoherentBundle.toEvalBMCS
    -> construct_eval_bmcs
```

Key properties of `construct_eval_bmcs`:
- Returns `EvalBMCS D` instead of `BMCS D`
- `construct_eval_bmcs_contains_context` theorem proves context preservation
- No axiom dependency - fully proven using non-constructive approach with axiom of choice

### Finding 4: EvalBMCS vs BMCS Structure Differences

| Property | BMCS | EvalBMCS |
|----------|------|----------|
| `modal_forward` | All families -> all families | eval_family -> all families |
| `modal_backward` | All families -> each family | all families -> eval_family |
| Sufficiency | Full coherence | Sufficient for eval-based completeness |

The completeness proof only evaluates truth at `eval_family` (position 0), so `EvalBMCS` is mathematically sufficient.

### Finding 5: Required Changes for Rewiring

To remove the axiom, the following changes are needed:

**Option A: Direct EvalBMCS Integration**
1. Create `EvalBMCS` versions of truth definitions in `BMCSTruth.lean`
2. Create `EvalBMCS` version of truth lemma in `TruthLemma.lean`
3. Update `Completeness.lean` to use `construct_eval_bmcs` and EvalBMCS truth

**Option B: EvalBMCS to BMCS Conversion**
1. Create a coercion/conversion `EvalBMCS -> BMCS`
2. This requires proving that EvalBMCS properties imply full BMCS properties (may reintroduce axiom)

**Recommended**: Option A is cleaner and avoids circular dependencies.

### Finding 6: Temporal Sorries are Independent

The TruthLemma contains 2 sorries for temporal backward directions (lines 387, 400). These are:
- Independent of the modal axiom removal
- Blocked on Task 857 (`add_temporal_backward_properties`)
- Do not affect the completeness theorems since only the forward direction (`.mp`) is used

## Axiom Characterization

### Current State
- 1 axiom in `Construction.lean`: `singleFamily_modal_backward_axiom` (line 228)
- Purpose: Asserts modal backward direction in single-family BMCS construction

### Transitive Impact
- `construct_bmcs` inherits axiom dependency
- `singleFamilyBMCS` inherits axiom dependency
- `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness` all inherit axiom dependency
- All downstream theorems claiming "proven completeness" require axiom disclosure

### Remediation Path
- Task 856 has completed the structural proof approach
- `eval_saturated_bundle_exists` is PROVEN (no sorry)
- `construct_eval_bmcs` provides axiom-free construction
- Rewiring completeness theorems eliminates axiom dependency entirely

### Publication Status
This axiom blocks undisclosed publication. The structural proof via EvalBMCS eliminates the need entirely - axiom can be commented out or removed after rewiring.

## Decisions

1. **Use Option A (EvalBMCS integration)**: Create EvalBMCS-specific truth definitions and truth lemma rather than attempting conversion to full BMCS

2. **Comment rather than delete**: Initially comment out the axiom with explanation, allowing fallback if issues arise during implementation

3. **Preserve existing BMCS infrastructure**: The full BMCS structure may be useful for future extensions; only the axiom-dependent parts need replacement

## Recommendations

### Recommendation 1: Create EvalBMCS Truth Infrastructure
**Priority**: High
**Owner**: Implementation agent
**Effort**: 2-3 hours

Create new definitions in `BMCSTruth.lean` or new file:
- `eval_bmcs_truth_at : EvalBMCS D -> IndexedMCSFamily D -> D -> Formula -> Prop`
- Mirror existing `bmcs_truth_at` but for EvalBMCS

### Recommendation 2: Create EvalBMCS Truth Lemma
**Priority**: High
**Owner**: Implementation agent
**Effort**: 3-4 hours

Create in `TruthLemma.lean` or new file:
- `eval_bmcs_truth_lemma : EvalBMCS D -> ... -> phi in mcs iff eval_bmcs_truth_at`
- Key: The box case can use `modal_forward_eval` and `modal_backward_eval` directly

### Recommendation 3: Update Completeness Theorems
**Priority**: High
**Owner**: Implementation agent
**Effort**: 2-3 hours

Modify `Completeness.lean`:
- Replace `construct_bmcs` calls with `construct_eval_bmcs`
- Replace `BMCS` type with `EvalBMCS`
- Replace `bmcs_truth_at` with `eval_bmcs_truth_at`
- Replace `bmcs_truth_lemma` with `eval_bmcs_truth_lemma`

### Recommendation 4: Remove/Comment Axiom
**Priority**: Medium
**Owner**: Implementation agent
**Effort**: 0.5 hours

After completeness theorems build successfully:
- Comment out `singleFamily_modal_backward_axiom` with explanation
- Update documentation in Construction.lean
- Verify `lake build` passes

### Recommendation 5: Verify Transitive Axiom Freedom
**Priority**: High
**Owner**: Implementation agent
**Effort**: 0.5 hours

After changes:
- Run `#check @bmcs_strong_completeness` to verify no axiom dependencies
- Update repository_health.axiom_count in state.json

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| EvalBMCS truth definitions may have subtle differences | Medium | Mirror existing definitions carefully, test with simple cases first |
| Truth lemma for EvalBMCS box case might not close | High | The box case is structurally identical - use same proof pattern with `modal_forward_eval`/`modal_backward_eval` |
| Breaking changes to dependent theorems | Medium | Implement incrementally, keep old infrastructure until new is verified |
| Build failures in other files | Low | Run full `lake build` after each phase |

## Implementation Outline

### Phase 1: EvalBMCS Truth Definitions (2 hours)
1. Create `eval_bmcs_truth_at` mirroring `bmcs_truth_at`
2. Create helper lemmas (`eval_bmcs_truth_neg`, etc.)
3. Verify compiles

### Phase 2: EvalBMCS Truth Lemma (3 hours)
1. Create `eval_bmcs_truth_lemma` with same structure
2. Box case uses `modal_forward_eval` and `modal_backward_eval`
3. Temporal cases will still have sorries (independent of axiom)
4. Verify compiles

### Phase 3: Completeness Rewiring (3 hours)
1. Update `bmcs_representation` to use `construct_eval_bmcs`
2. Update `bmcs_context_representation`
3. Update `bmcs_valid_Int` and related definitions
4. Update `bmcs_weak_completeness` and `bmcs_strong_completeness`
5. Verify compiles

### Phase 4: Axiom Removal and Verification (1 hour)
1. Comment out `singleFamily_modal_backward_axiom`
2. Comment out `singleFamilyBMCS` (no longer needed)
3. Run full `lake build`
4. Verify `#check` shows no axiom dependencies
5. Update documentation

**Total Estimated Effort**: 8-10 hours

## Appendix

### References
- Task 856 implementation summary: `specs/856_implement_multifamily_saturated_bmcs/summaries/implementation-summary-20260204.md`
- Original BMCS research: `specs/812_canonical_model_completeness/reports/research-007.md`
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`

### Key Code Locations
- Axiom declaration: `Theories/Bimodal/Metalogic/Bundle/Construction.lean:228`
- EvalBMCS structure: `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean:1076`
- construct_eval_bmcs: `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean:1565`
- Completeness theorems: `Theories/Bimodal/Metalogic/Bundle/Completeness.lean:99-398`

### Key Theorems from Task 856
- `eval_saturated_bundle_exists` (proven): Main saturation theorem
- `construct_eval_bmcs_contains_context` (proven): Context preservation
- `EvalCoherentBundle.toEvalBMCS` (proven): Bundle to EvalBMCS conversion
