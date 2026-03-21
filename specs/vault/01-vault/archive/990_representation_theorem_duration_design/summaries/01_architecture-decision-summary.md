# Architecture Decision Summary: Task #990

**Completed**: 2026-03-17
**Duration**: ~2 hours
**Type**: Documentation-only (no code changes)

## Decision: D-Parametric as Primary Representation Path

### Summary

The duration type D in TM representation theorems is **PARAMETRIC**. D is not constructed
from syntax for the base logic; only with density (DN) or discreteness (DF) axioms
can a specific D be derived from the canonical timeline.

### Research Basis

Task 990 research (Teammate A + Teammate B synthesis) established:

| Question | Verdict |
|----------|---------|
| D-from-syntax feasible for base logic? | **Not feasible** (no characterization theorem) |
| D-parametric correct for base logic? | **Yes** (matches Montanari & de Rijke 1995) |
| Current `ParametricRepresentation.lean`? | **Keep as primary path** |
| D-from-syntax (`DFromCantor.lean`) role? | **Keep as auxiliary** |

### Key Files

| File | Role | Description |
|------|------|-------------|
| `Algebraic/ParametricRepresentation.lean` | **PRIMARY** | D-parametric representation theorem |
| `StagedConstruction/DFromCantor.lean` | Auxiliary | D-from-syntax for dense extension only |
| `BaseCompleteness.lean` | Instantiation | D = Int for base logic |

### Domain Selection by Extension

| Extension | D | Constraint | Characterization | Notes |
|-----------|---|------------|------------------|-------|
| Base | Int (any LOAG) | `AddCommGroup + LinearOrder + IsOrderedAddMonoid` | None (no theorem) | D must be provided externally |
| Dense | Rat (or TimelineQuot) | `+ DenselyOrdered` | Cantor's theorem | D CAN emerge from syntax |
| Discrete | Int (or Z-like) | `+ SuccOrder` | Z-characterization | D-parametric preferred |

### The Key Insight

The base TM axioms provide insufficient order-theoretic structure to identify the
canonical timeline with a known group. Without density axioms (which force the
canonical timeline to be a countable dense linear order without endpoints), there
is no characterization theorem to apply.

**Consequence**: For base completeness, we MUST provide D externally (e.g., D = Int).
This is not a limitation of the formalization; it reflects mathematical reality.

## Impact on Downstream Tasks

### Task 987: Algebraic Base Completeness

**Approach**: Use `parametric_algebraic_representation_conditional` with D = Int

**Wire**: The `temporal_coherent_family_exists_CanonicalMCS` construction provides
the temporally coherent BFMCS needed by the conditional representation theorem.

**Files to modify**:
- Create instantiation module `AlgebraicBaseCompleteness.lean`
- Wire `construct_bfmcs` function for D = Int

### Task 988: Dense Algebraic Completeness

**Approach**: Use D-parametric with `[DenselyOrdered D]`; optionally instantiate via DFromCantor

**Options**:
1. **Preferred**: Instantiate with D = Rat, add `[DenselyOrdered Rat]` instance
2. **Alternative**: Instantiate with D = TimelineQuot using Cantor isomorphism evidence

**Files to modify**:
- Create instantiation module `AlgebraicDenseCompleteness.lean`
- Wire `construct_bfmcs` function with DenselyOrdered constraint

### Task 989: Discrete Algebraic Completeness

**Approach**: Use D-parametric with `[SuccOrder D]`

**Wire**: Similar to base completeness, but with SuccOrder constraint on D = Int

**Files to modify**:
- Create instantiation module `AlgebraicDiscreteCompleteness.lean`
- Wire `construct_bfmcs` function with SuccOrder constraint

### Task 982: Dense Completeness Wiring

**Clarification**: The domain mismatch (CanonicalMCS vs TimelineQuot) is a **wiring problem**
within the D-parametric framework, not an architectural problem.

**Resolution**: Use D-parametric approach with D = Rat or D = TimelineQuot

## Files Modified by This Task

### ROAD_MAP.md

1. **Strategy "D Construction from Canonical Timeline"**: Changed status from ACTIVE to CONCLUDED,
   added research outcome explaining D-parametric as primary path
2. **New Decision "D-Parametric as Primary Representation Path"**: Added architectural decision
   documenting the research findings and domain selection per extension
3. **Ambition "Syntactically-Derived Duration Domain"**: Downgraded priority, updated success
   criteria to reflect partial achievement (dense only), revised description

### Lean Files (Documentation Only)

1. **`ParametricRepresentation.lean`**: Added "Architectural Role" section explaining:
   - Why parametric approach is necessary for base logic
   - Relationship to DFromCantor.lean
   - Domain selection table for completeness proofs

2. **`DFromCantor.lean`**: Added "Architectural Role" section explaining:
   - Auxiliary status for dense completeness only
   - When to use this module
   - Relationship to base completeness (not applicable)

3. **`BaseCompleteness.lean`**: Added "Relationship to D-Parametric Architecture" section:
   - Why D = Int for base logic
   - Domain selection table
   - References to abstract representation theorem

## Verification

- `lake build` succeeds for all modified Lean files
- No new sorries introduced (documentation changes only)
- Cross-references between modules are accurate
- ROAD_MAP.md updates are consistent with research findings

## Notes

The "D must emerge from syntax" constraint from earlier architectural decisions is
**relaxed for base logic** by this task. This is not a retreat from rigor; it reflects
the mathematical reality that base TM axioms do not determine the structure of D.

For dense TM logic, D CAN emerge from syntax (via Cantor's theorem on the canonical
timeline). The `DFromCantor.lean` module provides this result as an auxiliary theorem,
but the preferred approach remains D-parametric for uniformity.
