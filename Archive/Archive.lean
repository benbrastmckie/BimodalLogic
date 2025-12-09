-- Re-export archive modules
import Archive.ModalProofs
import Archive.ModalProofStrategies
import Archive.TemporalProofs
import Archive.TemporalProofStrategies
import Archive.BimodalProofs
import Archive.BimodalProofStrategies
import Archive.TemporalStructures

/-!
# ProofChecker Archive

This directory contains pedagogical examples, famous proofs, and historical
examples demonstrating the ProofChecker library's capabilities.

## Overview

The Archive follows the mathlib4 pattern of providing well-documented examples
that illustrate key concepts and theorems in the bimodal logic TM. These examples
are intended for:
- **Learning**: Understanding how to use ProofChecker effectively
- **Reference**: Showing idiomatic proof patterns
- **Demonstration**: Illustrating the power of the proof system

## Examples Categories

### Modal Logic Examples
- **ModalProofs.lean**: S5 modal logic theorems and proof patterns
  - Axiom K (modal distribution)
  - Axiom T (reflexivity)
  - Axiom 4 (transitivity)
  - Axiom B (symmetry)
- **ModalProofStrategies.lean**: Pedagogical examples for S5 modal proof construction
  - Necessity chains (iterating M4)
  - Possibility proofs (working with `◇φ = ¬□¬φ`)
  - Modal modus ponens patterns
  - S5 characteristic theorems

### Temporal Logic Examples
- **TemporalProofs.lean**: Linear temporal logic theorems
  - Past and future operators
  - Temporal duality principles
  - Temporal axioms (TA, TL)
- **TemporalProofStrategies.lean**: Pedagogical examples for temporal proof construction
  - Future iteration chains (T4 axiom)
  - Temporal duality transformations (past ↔ future)
  - Connectedness reasoning (TA axiom)
  - Always/eventually proofs

### Bimodal Examples
- **BimodalProofs.lean**: Combined modal-temporal reasoning
  - Perpetuity principles (P1-P6)
  - Modal-temporal interactions
  - Task semantics applications
- **BimodalProofStrategies.lean**: Pedagogical examples for bimodal proof construction
  - Perpetuity principle applications (P1-P6 usage patterns)
  - Modal-temporal axiom strategies (MF and TF)
  - Helper lemma construction (imp_trans, combine_imp_conj)
  - Complex multi-step proof assembly

### Temporal Structures Examples
- **TemporalStructures.lean**: Polymorphic temporal type examples
  - Integer time frames (discrete temporal logic)
  - Rational time frames (dense temporal reasoning)
  - Real time frames (continuous time modeling)
  - Demonstrates polymorphic `TaskFrame T` and `WorldHistory F`

## Usage

Import specific examples:
```lean
import Archive.ModalProofs
import Archive.ModalProofStrategies
import Archive.TemporalProofs
import Archive.TemporalProofStrategies
import Archive.BimodalProofs
import Archive.BimodalProofStrategies
```

Or import the entire archive:
```lean
import Archive
```
-/

namespace Archive

def version : String := "0.1.0"

end Archive
