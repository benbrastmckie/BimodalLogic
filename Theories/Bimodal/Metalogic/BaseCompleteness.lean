import Bimodal.Metalogic.Bundle.CanonicalConstruction
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Semantics.Validity
import Bimodal.ProofSystem.Derivation

/-!
# Base Completeness - Completeness for Base TM Logic

This module provides the completeness interface for the base temporal logic TM
(using only base axioms, without density or discreteness extensions).

## Main Results

- `canonical_truth_lemma_int`: Truth lemma for Int-indexed canonical model
- `shifted_truth_lemma_int`: Shifted truth lemma for shift-closed Omega
- `base_completeness_infrastructure`: Documents available infrastructure

## Relationship to Dense and Discrete Completeness

The base logic uses the 18 base axioms (see `Axiom.isBase`), which are valid
on ALL linear orders. This means:

- **Base ⊂ Dense**: All base-valid formulas are dense-valid
- **Base ⊂ Discrete**: All base-valid formulas are discrete-valid

Completeness for base logic implies:
```
valid φ → ⊢_base φ   (base completeness)
```

Dense completeness adds the density axiom DN:
```
valid_dense φ → ⊢_dense φ   (dense completeness)
```

Discrete completeness adds discreteness and seriality axioms:
```
valid_discrete φ → ⊢_discrete φ   (discrete completeness)
```

## Infrastructure Status

The canonical construction uses `D = Int`, providing:

1. **Truth Lemma** (`canonical_truth_lemma`): MCS membership ↔ semantic truth
2. **Shifted Truth Lemma** (`shifted_truth_lemma`): For shift-closed Omega
3. **Temporal Coherent FMCS** (`temporal_coherent_family_exists_CanonicalMCS`)

### Domain Consideration

The base completeness theorem quantifies over ALL linear ordered abelian groups D.
The canonical construction uses `D = Int`, which is a specific instance. The gap
between the Int-specific proof and the polymorphic statement is the same domain
mismatch documented in `DenseCompleteness.lean`.

**Key Insight**: The standard completeness-via-consistency approach constructs
a SINGLE satisfying model (Int-indexed). This is sufficient for completeness
because we only need to show that unprovable formulas are NOT valid (i.e.,
there EXISTS a model falsifying them). The Int model provides this witness.

## References

- Task 977: Current organization task
- `Bundle/CanonicalConstruction.lean`: Truth lemma infrastructure
- `DenseCompleteness.lean`: Dense completeness (parallel structure)
-/

namespace Bimodal.Metalogic.BaseCompleteness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.Canonical

/-!
## Base Completeness Statement

The base completeness theorem states that validity over all linear orders
implies provability using the base axiom set (18 axioms, no density/discreteness).

### Formal Statement

```
theorem completeness_base (φ : Formula) :
    valid φ → Nonempty (⊢ φ)
```

### Proof Sketch (Contrapositive)

1. Assume φ is not derivable in the base proof system
2. Then [φ.neg] is consistent (otherwise φ would be derivable)
3. By Lindenbaum: extend [φ.neg] to MCS S₀
4. By temporal_coherent_family_exists: build FMCS over CanonicalMCS
5. Build canonical TaskFrame over Int with CanonicalTaskFrame
6. By shifted_truth_lemma: φ.neg true at evaluation point
7. Contradiction: valid φ but φ false at (Int-indexed) model

### Connection to Standard Validity

The shifted truth lemma establishes truth correspondence for a specific
Int-indexed model with ShiftClosed Omega. Since `valid` quantifies over
ALL temporal types D, we need to show that this Int model is sufficient.

**Key Point**: Completeness requires only that unprovable formulas have
a COUNTERMODEL. The Int canonical model provides such a countermodel.
We don't need the countermodel to be in every D -- just ONE D suffices.
-/

/--
Re-export: The canonical truth lemma for Int-based BFMCS.

This establishes the fundamental connection between MCS membership
and semantic truth in the Int-indexed canonical model.
-/
theorem base_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (φ : Formula) :
    φ ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t φ :=
  canonical_truth_lemma B h_tc fam hfam t φ

/--
Re-export: The shifted truth lemma for shift-closed Omega.

This extends the canonical truth lemma to work with ShiftClosedCanonicalOmega,
which satisfies the ShiftClosed condition required by `valid`.
-/
theorem base_shifted_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (φ : Formula) (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t φ :=
  shifted_truth_lemma B h_tc φ fam hfam t

/--
The shift-closed canonical Omega satisfies the ShiftClosed condition.
-/
theorem base_omega_shift_closed (B : BFMCS Int) :
    ShiftClosed (ShiftClosedCanonicalOmega B) :=
  shiftClosedCanonicalOmega_is_shift_closed B

/-!
## Completeness Hierarchy

The three completeness theorems form a hierarchy:

1. **Base Completeness**: `valid φ → ⊢ φ` (18 base axioms)
2. **Dense Completeness**: `valid_dense φ → ⊢_dense φ` (base + density)
3. **Discrete Completeness**: `valid_discrete φ → ⊢_discrete φ` (base + discreteness + seriality)

The relationship between validity predicates:
- `valid φ` implies `valid_dense φ` (by Validity.valid_implies_valid_dense)
- `valid φ` implies `valid_discrete φ` (by Validity.valid_implies_valid_discrete)

And between proof systems:
- `⊢ φ` (base) is a subset of `⊢_dense φ` (base axioms are dense-compatible)
- `⊢ φ` (base) is a subset of `⊢_discrete φ` (base axioms are discrete-compatible)

This means:
- A formula valid on ALL frames is provable with base axioms alone
- A formula valid only on dense frames needs the density axiom
- A formula valid only on discrete frames needs discreteness axioms
-/

/--
Documentation theorem: base completeness uses only base-compatible axioms.

All axioms used in the base proof system satisfy `isBase`.
-/
theorem base_axioms_are_base {φ : Formula} (h : Axiom φ) (hb : h.isBase) :
    h.isDenseCompatible ∧ h.isDiscreteCompatible :=
  h.isBase_implies_both_compatible hb

end Bimodal.Metalogic.BaseCompleteness
