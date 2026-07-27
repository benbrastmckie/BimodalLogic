/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.TemporalCoherence
import FormalSystem.Metalogic.Bundle.SuccRelation
import FormalSystem.Theorems.TemporalDerived

/-!
# Until/Since Coherence: Backward Direction (archived)

This module previously provided backward Until and backward Since lemmas for
FMCS families over Int, intended for the truth lemma's Until/Since cases:
given a witness pattern (ψ at some s ≥ t, φ on guard [t, s)), derive
(φ U ψ) ∈ fam.mcs t.

## Archival

The entire declaration body — two 3-link chains rooted at sorried reflexive
base cases —

- `backward_until_reflexive` → `backward_until_from_step` → `backward_until_coherent`
- `backward_since_reflexive` → `backward_since_from_step` → `backward_since_coherent`

has been moved verbatim to `Boneyard/SorriedDeclExcisions/UntilSinceCoherence.lean`.
The reflexive base cases became unprovable when reflexive Until/Since
introduction was invalidated under open guard (t,s) semantics, and no live code
consumed any of the six declarations. The truth-lemma pipeline instead reaches
backward Until/Since coherence via the restricted BFMCS route (see
`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`'s
`RestrictedBackwardUntilSinceCoherent` structure field, a distinct
identifier).

This file intentionally retains its import block (preserving transitive imports
for its importer) and declares nothing.

## References

- TemporalCoherence.lean: `BFMCS.UntilSinceCoherent` definition
- Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean: `or_until_in_mcs`, `or_since_in_mcs`
  (archived from SuccRelation.lean; unsound under open-guard semantics)
- Theorems/TemporalDerived.lean: `psi_imp_until`, `psi_imp_since`
- Boneyard/SorriedDeclExcisions/UntilSinceCoherence.lean: archived declarations
-/
