import Bimodal.Boneyard.Metalogic_v2.Decidability.Saturation

/-!
# Proof Extraction from Closed Tableaux (Metalogic_v2)

This module extracts `DerivationTree` proof terms from closed tableaux.
When all branches of a tableau close, the original formula is valid,
and we can construct a syntactic proof.

## Main Definitions

- `extractProofFromClosure`: Extract proof from a single closure reason
- `tableauToProof`: Extract proof from a fully closed tableau

## Implementation Notes

This is a port from `Bimodal.Metalogic.Decidability.ProofExtraction` to the
Metalogic_v2 architecture with minimal changes.

The key insight is that each closure reason corresponds to a proof fragment:
- `contradiction`: Propositional contradiction gives proof via EFQ
- `botPos`: T(⊥) is impossible in valid branches
- `axiomNeg`: F(axiom) closes via the axiom's validity

The Type-based Axiom (from task 260) enables us to use `matchAxiom` to
obtain actual axiom witnesses that can be used in `DerivationTree.axiom`.

## References

* Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace Bimodal.Metalogic_v2.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation

/-!
## Proof Construction Helpers
-/

/--
Build a proof of φ from a proof of ⊥ → φ (via ex_falso).
This is used when we have a contradiction in the branch.
-/
def proofFromBot (φ : Formula) : DerivationTree [] (Formula.bot.imp φ) :=
  DerivationTree.axiom [] _ (Axiom.ex_falso φ)

/--
Build a proof of φ from an axiom witness.
-/
def proofFromAxiom (φ : Formula) (ax : Axiom φ) : DerivationTree [] φ :=
  DerivationTree.axiom [] φ ax

/-!
## Proof Extraction from Closure Reasons
-/

/--
Extract a proof fragment from a closure reason.

Each closure reason provides evidence for why F(φ) leads to contradiction,
which means φ is valid (since assuming ¬φ leads to contradiction).

- `contradiction`: We have both T(ψ) and F(ψ), which is impossible in any model
- `botPos`: T(⊥) is impossible (⊥ is false in all models)
- `axiomNeg`: F(axiom) contradicts the axiom's validity

Note: This returns a proof of the formula that caused closure, not necessarily
the original goal. The full tableau-to-proof extraction combines these.
-/
def extractFromClosureReason (reason : ClosureReason) : Option (Σ φ : Formula, DerivationTree [] φ) :=
  match reason with
  | .axiomNeg φ ax =>
      -- The axiom itself is provable
      some ⟨φ, proofFromAxiom φ ax⟩
  | .contradiction _ =>
      -- Contradiction means the branch is unsatisfiable
      -- The proof would need to trace back the specific contradiction
      -- For now, we don't extract a specific proof
      none
  | .botPos =>
      -- T(⊥) is impossible, but doesn't give us a direct proof
      none

/-!
## Direct Axiom Proof
-/

/--
Try to build a direct proof of a formula if it's an axiom instance.
Uses `matchAxiom` from ProofSearch.
-/
def tryAxiomProof (φ : Formula) : Option (DerivationTree [] φ) :=
  match matchAxiom φ with
  | some ⟨ψ, ax⟩ =>
      if h : φ = ψ then
        some (h ▸ DerivationTree.axiom [] ψ ax)
      else
        none
  | none => none

/-!
## Tableau to Proof Extraction
-/

/--
Result of proof extraction from a closed tableau.
-/
inductive ProofExtractionResult (φ : Formula) : Type where
  /-- Successfully extracted a proof. -/
  | success (proof : DerivationTree [] φ)
  /-- Could not extract proof (tableau method limitation). -/
  | incomplete (reason : String)
  deriving Repr

/--
Extract a proof from an expanded tableau that shows validity.

When the tableau is `allClosed`, the original formula is valid.
We attempt to construct a `DerivationTree` proof.

Note: Full proof extraction from tableau is complex because we need to
track the structure of tableau expansion and combine proof fragments.
This implementation provides a simplified version that works for:
1. Direct axiom matches
2. Simple propositional cases

For complex proofs, the `incomplete` result is returned with a reason.
-/
def extractProof (φ : Formula) (tableau : ExpandedTableau) : ProofExtractionResult φ :=
  match tableau with
  | .hasOpen _ _ =>
      -- Tableau shows formula is invalid, no proof exists
      .incomplete "Formula is invalid (open branch found)"
  | .allClosed closedBranches =>
      -- Formula is valid, try to extract proof
      -- First, try direct axiom proof
      match tryAxiomProof φ with
      | some proof => .success proof
      | none =>
          -- Check if any closed branch gives us a direct proof
          let axiomProofs := closedBranches.filterMap fun cb =>
            match cb.reason with
            | .axiomNeg ψ ax =>
                if h : φ = ψ then some (h ▸ DerivationTree.axiom [] ψ ax)
                else none
            | _ => none
          match axiomProofs.head? with
          | some proof => .success proof
          | none =>
              -- Full proof extraction would require tracing tableau structure
              .incomplete "Full proof extraction not yet implemented"

/-!
## Proof Search Integration
-/

/--
Try to find a proof using both tableau and proof search.

First attempts direct proof search (which is fast for axioms),
then falls back to tableau method for more complex formulas.
-/
def findProofCombined (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : Option (DerivationTree [] φ) :=
  -- First try direct proof search (fast for axioms)
  match bounded_search_with_proof [] φ searchDepth with
  | (some proof, _, _) => some proof
  | (none, _, _) =>
      -- Fall back to tableau method
      match buildTableau φ tableauFuel with
      | some (.allClosed _) =>
          -- Tableau proves validity, but we need the proof term
          -- Try axiom proof extraction
          tryAxiomProof φ
      | _ => none

/-!
## Proof Verification
-/

/--
Verify that a proof term is well-formed (type-checks).
This is automatically enforced by Lean's type system, but we provide
this function for documentation and potential runtime checks.
-/
def verifyProof (_φ : Formula) (_proof : DerivationTree [] _φ) : Bool :=
  true  -- Type system ensures well-formedness

/--
Get the height of a proof (number of inference steps).
-/
def proofHeight {φ : Formula} (proof : DerivationTree [] φ) : Nat :=
  proof.height

/-!
## Statistics
-/

/--
Statistics about proof extraction.
-/
structure ProofExtractionStats where
  /-- Was proof successfully extracted? -/
  success : Bool
  /-- Method used (axiom, tableau, search). -/
  method : String
  /-- Proof height if successful. -/
  height : Option Nat
  deriving Repr, Inhabited

end Bimodal.Metalogic_v2.Decidability
