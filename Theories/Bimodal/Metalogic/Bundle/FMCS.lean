import Bimodal.Metalogic.Bundle.BFMCS

/-!
# FMCS: Family of Maximal Consistent Sets

This module provides the `FMCS` type alias for `BFMCS`, clarifying the
intended semantics of the structure.

## Terminology (Task 925)

- **FMCS**: A SINGLE time-indexed family of MCS (`mcs : D -> Set Formula`)
- **BMCS**: A BUNDLE (set) of FMCS families with modal coherence

The name "BFMCS" (Bundled Family of MCS) is confusing because "Bundled"
refers to the Lean4 pattern of bundling data with proofs, not to collecting
multiple families. The alias `FMCS` clarifies that this is a single family.

New code should prefer `FMCS` over `BFMCS` where practical.

## References

- Task 925: Rename BFMCS -> FMCS for clarity
-/

namespace Bimodal.Metalogic.Bundle

/--
Type alias: FMCS is the preferred name for the single-family structure.

`FMCS D` = `BFMCS D` = a time-indexed family of maximal consistent sets
with temporal coherence (forward_G, backward_H).

New code should use `FMCS` to clarify this is a SINGLE family, not a bundle.
The name `BMCS` is reserved for the bundle (set of families).
-/
abbrev FMCS := BFMCS

end Bimodal.Metalogic.Bundle
