/-!
# ARCHIVED: Int-Indexed Representation Theorem

**Archived**: 2026-03-14
**Reason**: Hardcodes `D = Int` through `construct_saturated_bfmcs_int`, violating the
pure-syntax constraint that D must emerge from temporal axioms.
**Location**: `Boneyard/IntRepresentation/Representation.lean`

## What Was Here

- `standard_representation`: `ContextConsistent [φ] → satisfiable Int [φ]`
- `standard_weak_completeness`: `valid φ → Nonempty (⊢ φ)`
- `standard_strong_completeness`: `semantic_consequence Γ φ → ContextDerivable Γ φ`

All three theorems inherited a sorry from `construct_saturated_bfmcs_int` and imported
`Int` as the duration domain D. The pure-syntax pipeline (Task 960) constructs D from
MCSs via order characterization theorems, making this file's approach obsolete.

## Replacement

The D-from-syntax pipeline in `Domain/CanonicalDomain.lean` provides:
- `denseCanonicalTaskFrame`: TaskFrame with D derived from syntax via ℚ characterization
- `discreteCanonicalTaskFrame`: TaskFrame with D derived from syntax via ℤ characterization
- `baseTaskFrame`: TaskFrame ℤ (direct, for the base case without density/discreteness axioms)

Standard completeness theorems will be rebuilt on top of the D-from-syntax construction
once the `CanonicalRIrreflexive` axiom is resolved (see `Canonical/CanonicalIrreflexivityAxiom.lean`).

## References

- Task 960: Duration Group Construction from Pure Syntax
- `Boneyard/IntRepresentation/Representation.lean`: Archived original
- `Domain/CanonicalDomain.lean`: Replacement pipeline
- `Canonical/CanonicalIrreflexivityAxiom.lean`: Irreflexivity axiom
-/
