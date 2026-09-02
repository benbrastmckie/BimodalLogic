# Bundle Completeness for TM Bimodal Logic

This directory implements the **Bundle of Maximal Consistent Sets (BFMCS)** approach for
proving completeness of TM bimodal logic. This is a Henkin-style completeness proof that
resolves the modal completeness obstruction present in traditional canonical model approaches.

## Reflexive G/H Semantics

Under reflexive semantics, G and H quantify over `s >= t` and `s <= t` respectively
(including the current time). The canonical accessibility relation is a **reflexive
transitive preorder**.

### Reflexive Semantics Without Added Axioms

- All BFMCS completeness infrastructure is `SORRY-FREE (sorryAx-free; axioms: exactly propext,
  Classical.choice, Quot.sound)` — never "axiom-free", which would misdescribe the three
  Lean-level axioms every result here depends on
- The whole directory is proven without adding any frame axiom
- `canonicalR_reflexive` proven via T-axiom (reflexive preorder)
- Per-construction strictness pattern for local irreflexivity proofs
- Removed inconsistent `existsTask_irreflexive_axiom`

## Key Insight

Completeness is an **existential** statement:

> If Gamma is consistent, then there EXISTS a model satisfying Gamma.

The BFMCS approach constructs exactly ONE such satisfying model by:
1. Bundling together related maximal consistent sets (MCSes)
2. Restricting box quantification to families within the bundle
3. Using modal coherence conditions to ensure the truth lemma is provable

**This is NOT a weakening of completeness.** It is analogous to:
- Henkin semantics for higher-order logic
- Standard practice in mathematical logic

The completeness theorem states that derivability and BFMCS-validity coincide. Combined with
soundness (derivability implies standard-validity), we get a full characterization.

## Architecture

```
Bundle/
  FMCSDef.lean               # FMCS type definition
  BFMCS.lean                 # Bundle structure with modal coherence
  LimitMCS.lean              # Limit set of a Rat-indexed family at a real point
  LimitMCSCoherence.lean     # forward_G/backward_H across the rational/limit case matrix
  RealExtension.lean         # Rat-to-R extension of a family by rational selection
  RealExtensionBundle.lean   # The real bundle over a rational bundle
  TemporalCoherence.lean     # Temporal coherence conditions
  TemporalContent.lean       # Temporal content tracking (g/h/f/p/u/s content)
  WitnessSeed.lean           # Witness seed infrastructure
  README.md                  # This file
```

The canonical-frame half of this directory -- `CanonicalFrame.lean`,
`CanonicalTaskRelation.lean`, `SuccRelation.lean`, `Construction.lean`,
`UntilSinceCoherence.lean` and `ModalSaturation.lean` -- was retired to
[`Boneyard/BundleDeadHalf/`](../../Boneyard/BundleDeadHalf/README.md), whose README records what
each was and why it died. Nothing in the live tree imported them once the `Core -> Bundle`
directory import cycle was broken. Their pure-syntax and derivation-tree content did not go with
them: the iterated-`F`/`P` machinery is now
`Syntax/SubformulaClosure/IteratedTemporal.lean`, and the object-level modal theorems are
`Theorems/ModalDerived.lean`.

## Main Theorems

| Theorem | Type | Status | File |
|---------|------|--------|------|
| `BFMCS.reflexivity` / `BFMCS.transitivity` | S5 modal coherence of the bundle | **SORRY-FREE** | BFMCS.lean |
| `temporal_backward_G` / `temporal_backward_H` | Backward temporal coherence for the truth lemma | **SORRY-FREE** | TemporalCoherence.lean |
| `BFMCS.toRealBundle_restricted_temporally_coherent` | Transport of restricted coherence to the real bundle | **SORRY-FREE** | RealExtensionBundle.lean |

### Sorry Status

**Active sorries in `Bundle/`**: **0**, without qualification. The structural sorry inventory is
zero across all of `FormalSystem/` (`Boneyard/` excluded); check C3 of
`scripts/check-module-invariants.sh` asserts this directory-wide and unconditionally.

**Key Achievement**: The BFMCS construction provides a complete, verified path from
consistent formula to satisfying model.

## Why BFMCS Works

### The Box Case Problem

Traditional completeness proofs fail at the box case because:

```
Standard semantics: Box phi true iff phi true at ALL accessible worlds
MCS membership:     Can only witness phi at bundled/constructed families
```

The quantification over "all worlds" cannot be matched by MCS membership.

### The BFMCS Solution

BFMCS restricts box quantification to bundled families:

```lean
def bmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
  | Formula.box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi
  ...
```

With modal coherence conditions:
- `modal_forward`: Box phi in MCS implies phi in ALL bundled families
- `modal_backward`: phi in ALL bundled families implies Box phi in MCS

The truth lemma box case becomes:

```
Forward: Box phi in fam.mcs t
  -> by modal_forward: phi in fam'.mcs t for all fam' in B.families
  -> by IH: bmcs_truth_at B fam' t phi for all fam' in B.families
  -> bmcs_truth_at B fam t (Box phi)

Backward: bmcs_truth_at B fam t (Box phi)
  = forall fam' in B.families, bmcs_truth_at B fam' t phi
  -> by IH: phi in fam'.mcs t for all fam' in B.families
  -> by modal_backward: Box phi in fam.mcs t
```

Both directions are provable!

## Relationship to Standard Semantics

BFMCS completeness + standard soundness gives the full picture:

```
Derivability <-> BFMCS-validity -> Standard-validity

               |-- BFMCS completeness --|   |-- soundness --|
```

- **BFMCS completeness**: `deriv phi <-> bmcs_valid phi` (this module)
- **Standard soundness**: `deriv phi -> standard_valid phi` (Metalogic/Soundness.lean)

Any derivable formula is valid in all models (standard or BFMCS).

## Usage

### Import for Completeness Results

```lean
import FormalSystem.Metalogic.Bundle.RealExtensionBundle
import FormalSystem.Metalogic.Bundle.TemporalCoherence

-- Main infrastructure for BFMCS completeness
```

### Import for BFMCS Infrastructure

```lean
import FormalSystem.Metalogic.Bundle.BFMCS
import FormalSystem.Metalogic.Bundle.FMCSDef
import FormalSystem.Metalogic.Bundle.WitnessSeed

-- For working with BFMCS structures directly
```

## References

- Archived the previous 30-sorry Representation development to `Boneyard/Metalogic_v5/`

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Core README](../Core/README.md) - MCS foundations (dependency)
- [Decidability README](../Decidability/README.md) - Decision procedure
- [Algebraic README](../Algebraic/README.md) - Alternative algebraic approach

## Future Work

1. **Consolidate the derived object-level theorems**: `Theorems/ModalDerived.lean` now holds
   the DNE, S5-introspection and `connect_past` helpers this directory used to declare inline
2. **Multi-family saturation**: Generalize singleFamilyBFMCS to full multi-family construction
3. **Compactness via BFMCS**: Potentially restore infinitary strong completeness using BFMCS

---

*Last updated: 2026-09-02 (retirement of the canonical-frame half to `Boneyard/BundleDeadHalf/`)*
