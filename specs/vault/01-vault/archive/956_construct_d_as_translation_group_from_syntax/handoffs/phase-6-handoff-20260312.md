# Phase 6 Handoff: Strict Density Iteration

**Date**: 2026-03-12
**Session**: sess_1773360785_3e3e40f5
**Status**: Phase 6a PARTIAL, Phases 6b-6d NOT STARTED

## Immediate Next Action

Implement `fuel_suffices` theorem proving sufficient fuel exists for strict density iteration, using `Nat.strongRecOn` on `subformulaClosure(anchor).card`.

## Current State

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
**Line**: 1830 (after `strictDensityFuelBound` definition)
**Goal**: Add `fuel_suffices` theorem that proves iteration always terminates

**Sorry Count**:
- DensityFrameCondition.lean: 13 sorries (lines 486, 490, 492, 585, 589, 591, 641, 646, 653, 865, 923, 1668, 1753)
- CantorApplication.lean: 3 sorries (lines 210, 269, 316)

## Key Decisions Made

1. **Fuel-based iteration**: Using explicit Nat recursion rather than well-founded recursion
2. **Termination measure**: `subformulaClosure(anchor).card` where anchor is the original distinguishing formula
3. **Phase 6a structure**: Basic `strictDensityIterWithFuel` function defined but returns `none` in escape cases

## What NOT to Try

1. **Direct proof without iteration**: All sorry cases genuinely require iteration
2. **Using `non_reflexive_target_has_strict_intermediate` before definition**: It's defined later in file and also has sorries
3. **Circular density argument**: Cannot use density of quotient to prove density

## Critical Context

### Mathematical Structure

The 13 sorries share a pattern: constructed witness W is equivalent to M or M' (same quotient class), requiring escape and iteration.

**Sorry Case Analysis**:
- **Lines 486, 490, 492, 585, 589, 591, 641, 646, 653** (9 sorries): Case B1 - W ~ M' (M' reflexive)
- **Lines 865, 923** (2 sorries): Case A - V ~ M (M reflexive, M' doesn't see V)
- **Lines 1668, 1753** (2 sorries): non_refl_target - W ~ M in deeper iteration

### Key Observation from Goal State at Line 486

```lean
-- We have:
h_W_mcs : SetMaximalConsistent W
h_R_MW : CanonicalR M W
h_not_WM : neg CanonicalR W M  -- W is strict from M side
h_WM' : CanonicalR W M'
h_M'_W_back : CanonicalR M' W  -- But M' sees W back!
-- Goal: find W' with both neg CanonicalR W' M AND neg CanonicalR M' W'
```

The issue: W is strict from M but not from M'. Need iteration to find witness strict from BOTH sides.

### Termination Argument

Each iteration either:
1. Returns strict witness (success)
2. Uses a formula from `subformulaClosure(delta)` as escape formula

Since the closure is finite, iteration terminates after at most `card + 1` steps.

The escape mechanism: when W ~ M' (mutual accessibility), apply density to (M, W). The new distinguishing formula is a subformula of the original delta.

## References

- **Plan**: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-023.md`
- **Research**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-045.md`
- **SubformulaClosure**: `Theories/Bimodal/Syntax/SubformulaClosure.lean`
- **MCP Tools Guide**: `.claude/context/project/lean4/tools/mcp-tools-guide.md`

## Infrastructure Available

```lean
-- Already defined in SubformulaClosure.lean:
def subformulaClosure (phi : Formula) : Finset Formula
def subformulaClosureCard (phi : Formula) : Nat
theorem closure_all_future : G(psi) in closure(phi) -> psi in closure(phi)

-- Already defined in DensityFrameCondition.lean:
structure StrictDensityWitness (M M' : Set Formula)
def checkStrictness : checks if witness is strict
def strictDensityFuelBound (anchor : Formula) : Nat
noncomputable def strictDensityIterWithFuel : fuel-based iteration (escape cases return none)
```

## Next Steps

1. **Phase 6b**: Implement `fuel_suffices` using `Nat.strongRecOn`:
   - Prove that when non-strict witness is found, the escape formula is in `subformulaClosure(delta)`
   - Show the new problem has strictly smaller measure
   - Apply strong induction

2. **Phase 6c**: Compose `density_frame_condition_strict_complete` from iteration + sufficiency

3. **Phase 6d**: Replace each of the 13 sorries with calls to the new theorem

## Build Status

```bash
lake build  # Passes with warnings and 16 sorry declarations
```
