# Research Report: Task #881 (Version 11)

**Task**: Construct modally saturated BMCS to eliminate fully_saturated_bmcs_exists axiom
**Date**: 2026-02-17
**Focus**: Review recent implementation attempts and remaining work after task 887

## Summary

Recent implementation sessions completed Phase 1 infrastructure (`seedToConstantMCS`) but Phase 2 is blocked by a circular import dependency. Task 887 will resolve this by creating `FinalConstruction.lean`. However, a deeper issue remains: witness families from modal saturation need temporal coherence (forward_F, backward_P), which constant families only provide if their underlying MCS is temporally saturated. Task 881's plan should be revised to depend on task 887 and address the temporal coherence challenge for witness families.

## Findings

### 1. Phase 1 Completion Status

**Completed (Session: sess_1771304171_a2d968)**:
- `seedFormulasAtZero`: Extract formulas from seed at position (0, 0)
- `seedFormulasAtZero_consistent`: Consistency of extracted formulas
- `buildSeed_seedFormulasAtZero_consistent`: Consistency of buildSeed at (0, 0)
- `phi_in_seedFormulasAtZero`: Main formula preserved in seed
- `seedToConstantMCS`: Build MCS from seed via Lindenbaum
- `seedToConstantMCS_is_mcs`: Result is maximal consistent
- `seedToConstantMCS_extends_seed`: Seed formulas preserved
- `seedToConstantMCS_contains_phi`: Main formula preserved

**Remaining technical debt**:
- 1 sorry in `buildSeed_hasPosition_zero` (line 5993) - auxiliary lemma about seed structure
- Status: Phase 1 functionally complete; auxiliary sorry is non-blocking

### 2. Circular Import Blocker (Phase 2)

**The Problem**:
- `fully_saturated_bmcs_exists_int` is defined in `TemporalCoherentConstruction.lean` (line 822)
- The proof requires `constructSaturatedBMCS` from `SaturatedConstruction.lean`
- BUT `SaturatedConstruction.lean` imports `TemporalCoherentConstruction.lean` (line 5)
- This creates an impossible circular dependency

**Task 887 Resolution**:
Task 887 will create `FinalConstruction.lean` that imports both files, resolving the circular dependency by placing the wiring code in a file that sits above both in the import hierarchy.

### 3. Deeper Challenge: Witness Family Temporal Coherence

**Critical Issue Discovered**:
Even after the circular import is resolved, there's a deeper architectural challenge:

```
BMCS.temporally_coherent requires ALL families (including witness families)
to satisfy forward_F and backward_P properties.

Witness families are built via:
1. constantWitnessFamily (SaturatedConstruction.lean:989)
2. Uses set_lindenbaum to extend {psi} union BoxContent to MCS
3. Regular Lindenbaum does NOT guarantee temporal saturation

For constant families, temporal coherence reduces to:
- TemporalForwardSaturated: F phi in M implies phi in M
- TemporalBackwardSaturated: P phi in M implies phi in M

Regular Lindenbaum MCS does NOT satisfy these properties.
```

**Why This Matters**:
The current `exists_fullySaturated_extension` (SaturatedConstruction.lean:873) is sorry-free for MODAL saturation but the BMCS it produces via `FamilyCollection.toBMCS` does NOT have `temporally_coherent` proven. The comment at line 1352 explicitly states: "The proof uses a sorry for the temporal coherence".

### 4. Sorry Status in exists_fullySaturated_extension

Reading SaturatedConstruction.lean carefully reveals:

**What IS sorry-free**:
- Modal saturation via Zorn's lemma (lines 873-1128) - PROVEN
- `isFullySaturated` property - PROVEN
- `modal_forward` and `modal_backward` in the resulting BMCS - PROVEN

**What is NOT sorry-free**:
- The file does NOT claim to prove `temporally_coherent` for the saturated BMCS
- Line 1367 has a `sorry` for temporal coherence in `fully_saturated_bmcs_exists_constructive`

### 5. The Gap Between Modal and Temporal Saturation

The key insight from the codebase:

| Property | Source | Status |
|----------|--------|--------|
| Modal saturation (`is_modally_saturated`) | `FamilyCollection.isFullySaturated` | Sorry-free |
| Context preservation | `seedToConstantMCS_contains_phi` | Sorry-free |
| Temporal coherence of eval_family | RecursiveSeed + constant families | Needs work |
| Temporal coherence of witness families | Regular Lindenbaum | NOT proven |

**The Challenge**:
To prove `fully_saturated_bmcs_exists_int` sorry-free, we need ALL three properties:
1. Context preservation (done)
2. Modal saturation (done via exists_fullySaturated_extension)
3. Temporal coherence for ALL families including witnesses (BLOCKED)

### 6. Resolution Options Analysis

**Option A: Use temporalLindenbaumMCS for witnesses** (8-12 hours)
- Requires fixing 5 sorries in TemporalLindenbaum.lean
- Task 882 attempted this but is BLOCKED (fundamental gaps)
- Verdict: Not viable with current infrastructure

**Option B: Prove constant witness families inherit temporal coherence** (4-6 hours)
- If BoxContent comes from temporally saturated families, show witness inherits
- Requires: Box phi in M where M is TemporalForwardSaturated implies F phi derivable
- This is plausible for S5 with temporal axioms but not yet proven
- Verdict: Promising but requires new proof infrastructure

**Option C: Restructure truth lemma to only require eval_family temporal coherence** (6-8 hours)
- The truth lemma only evaluates at eval_family positions
- Modal witness families are only used for Box backward reasoning
- If modal_backward can be proven without witness temporal coherence, this works
- Verdict: Worth investigating - may be simplest path

**Option D: Accept sorry in fully_saturated_bmcs_exists_int as tolerated technical debt**
- Document the gap explicitly
- Focus on other completeness infrastructure
- Verdict: Acceptable for development but blocks publication readiness

## Recommendations

### 1. Add Task 887 as Dependency

Task 881's plan should be revised to add task 887 as a blocking dependency. Task 887 will:
- Create FinalConstruction.lean
- Resolve the circular import
- Enable Phase 2 wiring

### 2. Revise Plan After Task 887

Once task 887 completes, revise the plan to focus on Option C (restructure truth lemma) as the primary approach:

**Rationale**:
- The truth lemma backward direction for G/H uses `forward_G`/`backward_H` properties
- These are automatically satisfied by constant families via T-axioms
- The witness families are used for modal_backward (Box phi backward direction)
- modal_backward does NOT require temporal coherence of witnesses

**Concrete Path**:
1. Verify that `BMCS.temporally_coherent` in the truth lemma only queries eval_family
2. If witness families' temporal properties aren't queried, weaken the BMCS definition
3. Create a `BMCSWithTemporalEvalFamily` variant that only requires eval_family coherence
4. Wire `constructSaturatedBMCS` to produce this weaker structure

### 3. Document Technical Debt

The current implementation has:
- 1 sorry in RecursiveSeed.lean (`buildSeed_hasPosition_zero`)
- 1 sorry in TemporalCoherentConstruction.lean (`fully_saturated_bmcs_exists_int`)
- 1 sorry in SaturatedConstruction.lean (`fully_saturated_bmcs_exists_constructive` at line 1367)

These represent genuine mathematical gaps that block publication readiness but are tolerated during development.

## Achievability Assessment

**After task 887 completes, is the remaining work achievable?**

**YES, with caveats**:

1. **Modal saturation**: Fully achieved (exists_fullySaturated_extension is sorry-free)
2. **Context preservation**: Fully achieved (seedToConstantMCS infrastructure)
3. **Temporal coherence**: Requires architectural decision

The key decision is whether to:
- (A) Prove witness families are temporally coherent (hard, may be unprovable)
- (B) Weaken the BMCS requirement to only need eval_family temporal coherence (likely correct)
- (C) Accept the sorry as documented technical debt (acceptable for now)

Option B is likely correct because the truth lemma's temporal reasoning only applies to the eval_family. Modal reasoning uses modal_backward which is proven via saturation alone.

## Next Steps

1. Wait for task 887 to complete (creates FinalConstruction.lean)
2. Revise task 881 plan (v6) with:
   - Task 887 as dependency
   - Option C as primary approach (restructure truth lemma requirements)
   - Fallback: Option D (document as tolerated technical debt)
3. Implement the revised plan after task 887

## References

- Implementation plan: `specs/881_modally_saturated_bmcs_construction/plans/implementation-005.md`
- SaturatedConstruction.lean: `exists_fullySaturated_extension` (lines 873-1128)
- TemporalCoherentConstruction.lean: `fully_saturated_bmcs_exists_int` (line 822)
- RecursiveSeed.lean: `seedToConstantMCS` infrastructure (lines 5944-6127)
- Task 887: FinalConstruction.lean creation (circular import resolution)
- Task 882: TemporalLindenbaum.lean sorries (BLOCKED - fundamental gaps)
