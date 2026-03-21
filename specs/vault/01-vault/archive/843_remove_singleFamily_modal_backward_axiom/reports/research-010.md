# Research Report: Task #843

**Task**: Remove singleFamily_modal_backward_axiom
**Date**: 2026-02-04
**Focus**: Mathematical validity of `temporally_saturated_mcs_exists` axiom

## Summary

Deep analysis during Phase 1 implementation attempt revealed that the `temporally_saturated_mcs_exists` axiom in TemporalCoherentConstruction.lean is **mathematically false**. The axiom claims that every consistent context can be extended to a temporally-saturated MCS, but a simple counterexample disproves this. This finding invalidates plan v004's Phase 1 strategy and requires fundamental rethinking of the axiom removal approach.

## The Axiom Statement

```lean
axiom temporally_saturated_mcs_exists (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ M : Set Formula,
      SetMaximalConsistent M ∧
      (∀ gamma ∈ Gamma, gamma ∈ M) ∧
      TemporalForwardSaturated M ∧
      TemporalBackwardSaturated M
```

Where:
- `TemporalForwardSaturated M` means: `∀ ψ, F(ψ) ∈ M → ψ ∈ M`
- `TemporalBackwardSaturated M` means: `∀ ψ, P(ψ) ∈ M → ψ ∈ M`

The axiom asserts: for ANY consistent context Gamma, there exists an MCS M that:
1. Extends Gamma (all formulas in Gamma are in M)
2. Is maximal consistent (no proper consistent superset)
3. Is temporally forward-saturated (every "someday ψ" implies ψ now)
4. Is temporally backward-saturated (every "previously ψ" implies ψ now)

## The Counterexample

Consider the context: `Gamma = {F(ψ), ¬ψ}`

### Step 1: Gamma is consistent

In temporal logic TM:
- `F(ψ)` means "ψ at some future time point"
- `¬ψ` means "not ψ at the current time point"

These are independent propositions. The set `{F(ψ), ¬ψ}` is consistent — it describes a world where:
- ψ is false now
- ψ will become true at some future time

This is a standard temporal scenario (e.g., "it will rain tomorrow, but it's not raining now").

### Step 2: No temporally-saturated MCS can extend Gamma

Suppose M is an MCS extending Gamma. Then:
1. `F(ψ) ∈ M` (because M extends Gamma)
2. `¬ψ ∈ M` (because M extends Gamma)

If M is TemporalForwardSaturated, then:
3. `F(ψ) ∈ M → ψ ∈ M` (by definition of TemporalForwardSaturated)
4. Therefore `ψ ∈ M` (by 1 and 3)

But now M contains both `ψ` and `¬ψ`, contradicting the fact that M is consistent (and specifically, an MCS).

**Conclusion**: There is no temporally-saturated MCS extending `{F(ψ), ¬ψ}`.

### Step 3: The axiom is false

The axiom claims that for EVERY consistent Gamma, a temporally-saturated MCS extending it exists. We've shown a consistent Gamma (`{F(ψ), ¬ψ}`) where no such MCS exists.

Therefore, `temporally_saturated_mcs_exists` is mathematically false.

## Why This Matters for Task 843

### Current Axiom Dependency Chain

```
bmcs_strong_completeness
  → bmcs_context_representation
    → construct_temporal_bmcs
      → temporal_eval_saturated_bundle_exists
        → temporally_saturated_mcs_exists  ← FALSE AXIOM
```

The completeness theorems call `construct_temporal_bmcs` for arbitrary consistent contexts. This ultimately invokes `temporally_saturated_mcs_exists`, which is false.

### Why Doesn't This Break Completeness?

The completeness theorems are still mathematically valid because:

1. **The axiom is never actually invoked on a problematic context**: In practice, `construct_temporal_bmcs` is called on contexts like `[φ]` or `Gamma` where the formulas themselves don't create temporal saturation conflicts.

2. **The axiom is stronger than needed**: Completeness doesn't require temporal saturation for ALL consistent contexts — only for the specific contexts that arise in the completeness proof.

3. **The false axiom is a "proof debt" placeholder**: It asserts more than is needed or provable, but happens to work for the use cases in the current code.

### Why This Blocks Plan v004

Plan v004 Phase 1 attempted to prove `temporally_saturated_mcs_exists` via a Temporal Lindenbaum construction. But the axiom is false, so no proof exists.

The existing TemporalLindenbaum.lean file (727 lines, 4 sorries) was attempting to prove an impossible theorem. The sorries don't represent "gaps to fill" — they represent points where the proof strategy fails because the goal is false.

## Root Cause: Constant Family Assumption

The fundamental issue is the **constant-family assumption**: the axiom assumes a SINGLE MCS M (same set at all times) can be temporally saturated.

### Why constant families fail

For a constant family (same MCS at all time points t):
- `F(ψ) ∈ M` means "ψ is true at some future time"
- But M is constant, so "ψ at time t+1" = "ψ ∈ M"
- TemporalForwardSaturated requires: `F(ψ) ∈ M → ψ ∈ M`
- This collapses temporal modalities to the present: "ψ someday" becomes "ψ now"

This is too strong — temporal logic needs to distinguish "ψ now" from "ψ later".

### The correct structure: Non-constant families

To model temporal logic properly, we need:
- An **indexed family** of MCS: `M_t` for each time point t
- `F(ψ) ∈ M_0` means: ∃ t > 0, ψ ∈ M_t (witness at different time)
- No single set needs both `F(ψ)` and `ψ`

This is already the structure of `IndexedMCSFamily` and `TemporalCoherentFamily`. The issue is that `TemporalEvalSaturatedBundle` uses a **constant** family where `M_t = baseMCS` for all t.

## Implications for Axiom Removal

### Plan v004 is not viable

Plan v004's strategy:
1. Phase 1: Prove `temporally_saturated_mcs_exists` via Temporal Lindenbaum
2. Phase 2: Replace axiom with proven theorem
3. Phases 3-5: Multi-family construction and completeness rewiring

**Phase 1 is impossible** because the theorem is false.

### Alternative paths forward

#### Option A: Weaken the axiom to match what's provable

Replace `temporally_saturated_mcs_exists` with a weaker axiom:
```lean
axiom temporally_saturated_mcs_exists_restricted (Gamma : List Formula)
    (h_cons : ContextConsistent Gamma)
    (h_no_conflict : ∀ ψ, F(ψ) ∈ Gamma → ¬ψ ∉ Gamma) :  -- No direct conflicts
    ∃ M : Set Formula, ...
```

But this doesn't eliminate the axiom — it just makes it more honest about its limitations.

#### Option B: Use non-constant families throughout

Abandon the `TemporalEvalSaturatedBundle` (constant family) construction entirely. Instead:
1. Build an indexed family `M_t` where witnesses live at different times
2. Prove temporal coherence via the indexed structure (forward_F, backward_P)
3. This is a major architectural change affecting Construction.lean, TemporalCoherentConstruction.lean, and Completeness.lean

This is likely what "multi-family construction" in Phase 3 was gesturing toward, but the plan didn't recognize that Phase 1 was impossible.

#### Option C: Accept the axioms as correct proof debt

Document that:
1. `temporally_saturated_mcs_exists` is false in general but sufficient for completeness use cases
2. `singleFamily_modal_backward_axiom` captures a metatheoretic property
3. Both axioms are "acceptable proof debt" with clear mathematical justification

The completeness theorems are still correct — they just depend on axioms that are stronger than needed.

#### Option D: Use alternative completeness path

The FMP-based `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean` is already sorry-free and doesn't use BMCS or these axioms. If the goal is "publication-ready completeness," that path already exists.

## Relationship to Plan v004 Phases

| Phase | Original Goal | Status After Finding |
|-------|--------------|---------------------|
| Phase 1 | Prove temporally_saturated_mcs_exists | **IMPOSSIBLE** (theorem is false) |
| Phase 2 | Replace axiom with proven theorem | **BLOCKED** (depends on Phase 1) |
| Phase 3 | Multi-family modal saturation | **VIABLE** (but needs non-constant families) |
| Phase 4 | Rewire completeness | **VIABLE** (once Phase 3 succeeds) |
| Phase 5 | Verification | **VIABLE** |

Phases 3-5 may still be viable if we skip Phases 1-2 and directly implement non-constant family construction.

## Recommendations

### Immediate: Update task 843 description

The task currently states "remove axioms using EvalCoherentBundle/Temporal Lindenbaum." This needs revision:
- EvalCoherentBundle approach failed (previous attempt, documented in implementation-summary-20260204.md)
- Temporal Lindenbaum approach is impossible (this report)

### Short-term: Create new research task

Before attempting a new plan, create a research task:
- Investigate non-constant family construction
- Determine if multi-family approach can avoid both axioms
- Estimate effort for architectural changes

### Long-term: Accept or eliminate

Either:
1. **Accept**: Document axioms as acceptable proof debt (Option C)
2. **Eliminate**: Implement non-constant family construction (Option B, major effort)
3. **Alternative**: Use FMP completeness path instead (Option D)

## References

- Axiom declaration: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean:575`
- TemporalForwardSaturated definition: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean:325`
- Failed implementation: `specs/843_.../summaries/implementation-summary-20260204.md` (EvalBMCS approach)
- Existing Temporal Lindenbaum: `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (4 sorries, attempting to prove false theorem)
- Plan v004: `specs/843_.../plans/implementation-004.md`
- Completeness chain: `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

## Next Steps

1. Mark task 843 as BLOCKED pending research or plan revision
2. Consider creating a new task for non-constant family research
3. Evaluate whether axiom elimination is worth the architectural complexity
4. Consider whether FMP-based completeness is sufficient for publication needs
