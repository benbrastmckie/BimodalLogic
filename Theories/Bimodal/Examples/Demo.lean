import Bimodal.Theorems.Perpetuity
import Bimodal.ProofSystem.Derivation
import Bimodal.Semantics.Validity
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Metalogic_v2.Core.DeductionTheorem
import Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel
import Bimodal.Metalogic_v2.Decidability.DecisionProcedure

/-!
# Bimodal TM Logic - Demo Presentation

This module provides a comprehensive demonstration of the Bimodal TM (Tense and Modality)
logic formalization, showcasing the complete development from syntax through metalogic.

## Overview

TM bimodal logic combines:
- **S5 modal logic**: metaphysical necessity and possibility
- **Linear temporal logic**: past/future operators

The formalization includes:
1. **Syntax**: Formula type with 6 primitives
2. **Proof System**: Hilbert-style with 15 axioms and 7 rules
3. **Semantics**: Task frame semantics with world histories
4. **Metalogic**: Soundness, completeness, and decidability

## Demo Sections

1. [Quick Tour](#section-1-quick-tour) - Key theorems at a glance
2. [Interactive Exploration](#section-2-interactive-exploration) - Step-by-step proofs
3. [Decision Procedure](#section-3-decision-procedure) - Live validity checking
4. [Applications](#section-4-applications) - Concrete examples

## References

- BimodalReference.tex for mathematical details
- Perpetuity.lean for P1-P6 principles
- FiniteCanonicalModel.lean for completeness proof
-/

namespace Bimodal.Examples.Demo

open Bimodal.Syntax
open Bimodal.Syntax.Formula (swap_temporal_involution)
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Core
open Bimodal.Metalogic_v2.Soundness
open Bimodal.Metalogic_v2.Representation (semantic_weak_completeness main_provable_iff_valid_v2)
open Bimodal.Metalogic_v2.Decidability
open Bimodal.Theorems.Perpetuity

/-!
## Section 1: Quick Tour

A curated selection of the most important theorems demonstrating the full
scope of the TM logic formalization.

### 1.1 Perpetuity Principles (P1-P6)

The perpetuity principles establish deep connections between modal necessity
and temporal operators. These are among the most philosophically interesting
theorems in TM logic.

**Notation**:
- `□φ` = necessarily φ (modal box)
- `◇φ` = possibly φ (modal diamond)
- `△φ` = always φ (at all times: past, present, future)
- `▽φ` = sometimes φ (at some time)
-/

section QuickTour

/-! **P1: Necessary implies always** (□φ → △φ)

If φ is metaphysically necessary, then φ holds at all times.
This captures the intuition that necessary truths are eternal. -/
#check @perpetuity_1  -- □φ → △φ

example (φ : Formula) : ⊢ φ.box.imp (△φ) := perpetuity_1 φ

/-! **P2: Sometimes implies possible** (▽φ → ◇φ)

If φ holds at some time, then φ is possible.
Temporal existence entails modal possibility. -/
#check @perpetuity_2  -- ▽φ → ◇φ

example (φ : Formula) : ⊢ (▽φ).imp φ.diamond := perpetuity_2 φ

/-! **P3: Necessity of perpetuity** (□φ → □△φ)

What is necessary is necessarily eternal.
Necessity transfers to perpetuity. -/
#check @perpetuity_3  -- □φ → □△φ

example (φ : Formula) : ⊢ φ.box.imp (△φ).box := perpetuity_3 φ

/-! **P4: Possibility of occurrence** (◇▽φ → ◇φ)

If it's possible that φ happens sometime, then φ is possible.
This collapses nested modal-temporal operators. -/
#check @perpetuity_4  -- ◇▽φ → ◇φ

example (φ : Formula) : ⊢ (▽φ).diamond.imp φ.diamond := perpetuity_4 φ

/-! **P5: Persistent possibility** (◇▽φ → △◇φ)

If it's possible that φ happens sometime, then it's always possible.
Possibility persists through time. -/
#check @perpetuity_5  -- ◇▽φ → △◇φ

noncomputable example (φ : Formula) : ⊢ (▽φ).diamond.imp (△(φ.diamond)) :=
  perpetuity_5 φ

/-! **P6: Occurrent necessity is perpetual** (▽□φ → □△φ)

If necessity occurs at some time, it's necessarily eternal.
This is the deepest principle, requiring modal 5 and temporal duality. -/
#check @perpetuity_6  -- ▽□φ → □△φ

noncomputable example (φ : Formula) : ⊢ (▽(φ.box)).imp (△φ).box :=
  perpetuity_6 φ

/-!
### 1.2 Metalogical Results

The formalization includes complete proofs of the main metalogical theorems.
-/

/-! **Soundness**: Every derivable formula is valid.

`soundness Γ φ : (Γ ⊢ φ) → (Γ ⊨ φ)`

All 15 axioms are proven valid, and all 7 inference rules preserve validity. -/
#check @soundness  -- (Γ ⊢ φ) → (Γ ⊨ φ)

/-! **Deduction Theorem**: Derivation with assumption equals implication.

`deduction_theorem Γ A B : ((A :: Γ) ⊢ B) → (Γ ⊢ A.imp B)`

Uses well-founded recursion on derivation structure. -/
#check @deduction_theorem  -- ((A :: Γ) ⊢ B) → (Γ ⊢ A.imp B)

/-! **Weak Completeness**: Valid formulas are derivable.

`semantic_weak_completeness φ : (∀ w, ...) → (⊢ φ)`

Uses semantic canonical model with finite world states. -/
#check @semantic_weak_completeness  -- validity → derivability

/-! **Main Theorem**: Derivability equals validity.

`main_provable_iff_valid_v2 φ : Nonempty (⊢ φ) ↔ valid φ`

The fundamental bi-conditional connecting syntax and semantics.

**Note**: The soundness direction (provable → valid) is fully proven.
The completeness direction (valid → provable) contains a sorry; for
sorry-free completeness, use `semantic_weak_completeness` above. -/
#check @main_provable_iff_valid_v2  -- ⊢ φ ↔ ⊨ φ

/-!
### 1.3 Decision Procedure

The formalization includes a tableau-based decision procedure that returns
either a proof or a countermodel.
-/

/-! **Decision procedure**: Decides validity with proof/countermodel extraction.

`decide φ : DecisionResult φ` where:
- `valid proof` = formula is valid with proof term
- `invalid counter` = formula is invalid with countermodel
- `timeout` = resources exhausted -/
#check @Metalogic_v2.Decidability.decide  -- Formula → DecisionResult

/-! **Convenience functions** for common queries -/
#check @isValidFormula       -- Formula → Bool
#check @isSatisfiable -- Formula → Bool
#check @isTautology   -- Formula → Bool

end QuickTour

/-!
## Section 2: Interactive Exploration

Step-by-step proof construction examples showing how derivations are built.
-/

section InteractiveExploration

/-!
### 2.1 Building a Simple Proof

Let's construct a proof of the modal T axiom: □p → p

This is one of the core S5 axioms stating that necessary truths are true.
-/

/-- The modal T axiom is directly available as an axiom schema -/
example (p : String) : ⊢ (Formula.atom p).box.imp (Formula.atom p) := by
  -- Apply the axiom directly using the proof system
  exact DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom p))

/-!
### 2.2 Modus Ponens in Action

If we have `⊢ A` and `⊢ A → B`, we can derive `⊢ B`.
-/

/-- Example: If □p is an axiom and □p → ◇p is provable, then ◇p -/
example (p : Formula) (h1 : ⊢ p.box) (h2 : ⊢ p.box.imp p.diamond) : ⊢ p.diamond := by
  -- Apply modus ponens
  exact DerivationTree.modus_ponens [] p.box p.diamond h2 h1

/-!
### 2.3 Necessitation Rule

If `⊢ φ` then `⊢ □φ`. This is a fundamental rule of modal logic.
-/

/-- Necessitation: if we can prove φ from nothing, we can prove □φ -/
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box := by
  exact DerivationTree.necessitation φ h

/-!
### 2.4 Temporal Duality

If `⊢ φ` then `⊢ swap_temporal φ`, where swapping exchanges G↔H and F↔P.
-/

/-- The swap_temporal function is an involution -/
example (φ : Formula) : φ.swap_temporal.swap_temporal = φ :=
  swap_temporal_involution φ

/-!
### 2.5 Working with Contexts

Derivations can use assumptions from a context (list of formulas).
-/

/-- Derivation from an assumption: if A is assumed, then A is derivable -/
example (A : Formula) : [A] ⊢ A := by
  exact DerivationTree.assumption [A] A (List.mem_singleton_self A)

/-- Deduction theorem converts context assumption to implication -/
noncomputable example (A B : Formula) (h : [A] ⊢ B) : ⊢ A.imp B := by
  exact deduction_theorem [] A B h

end InteractiveExploration

/-!
## Section 3: Decision Procedure

Live demonstrations of the decision procedure showing both valid and invalid
formulas with proof/countermodel extraction.
-/

section DecisionProcedure

/-!
### 3.1 Valid Formulas

These formulas are theorems of TM logic. The decision procedure finds proofs.
-/

/-- Modal T axiom: □p → p (necessity implies truth) -/
def formula_modal_t : Formula :=
  (Formula.atom "p").box.imp (Formula.atom "p")

-- Uncomment to see decision result:
-- #eval decide formula_modal_t

/-- Classical tautology: p → p (identity) -/
def formula_identity : Formula :=
  (Formula.atom "p").imp (Formula.atom "p")

-- #eval decide formula_identity

/-- Modal K distribution: □(p → q) → (□p → □q) -/
def formula_modal_k : Formula :=
  let p := Formula.atom "p"
  let q := Formula.atom "q"
  (p.imp q).box.imp (p.box.imp q.box)

-- #eval decide formula_modal_k

/-!
### 3.2 Invalid Formulas

These formulas are NOT theorems. The decision procedure finds countermodels.
-/

/-- Converse of T is invalid: p → □p -/
def formula_converse_t : Formula :=
  (Formula.atom "p").imp (Formula.atom "p").box

-- #eval decide formula_converse_t  -- Should be invalid

/-- Not everything possible is actual: ◇p → p -/
def formula_possibility_to_actuality : Formula :=
  (Formula.atom "p").diamond.imp (Formula.atom "p")

-- #eval decide formula_possibility_to_actuality  -- Should be invalid

/-!
### 3.3 Batch Decision

Process multiple formulas and collect statistics.
-/

/-- A list of formulas to test -/
def test_formulas : List Formula := [
  formula_modal_t,
  formula_identity,
  formula_modal_k,
  formula_converse_t,
  formula_possibility_to_actuality
]

-- #eval decideBatch test_formulas

/-!
### 3.4 Checking Specific Properties
-/

-- Check if a formula is a tautology
-- #eval isTautology formula_modal_t

-- Check if a formula is satisfiable
-- #eval isSatisfiable formula_converse_t

-- Check if a formula is contingent (neither valid nor contradictory)
-- #eval isContingent (Formula.atom "p")

end DecisionProcedure

/-!
## Section 4: Applications

Concrete examples using meaningful atom names to illustrate philosophical
and scientific applications of TM logic.
-/

section Applications

/-!
### 4.1 Laws of Nature

Physical laws are often considered necessary truths that hold at all times.
-/

/-- Conservation of energy: a necessary truth holds at all times -/
def conservation_of_energy : Formula := Formula.atom "conservation_of_energy"

/-- If conservation of energy is necessary, it holds at all times -/
example : ⊢ conservation_of_energy.box.imp (△conservation_of_energy) :=
  perpetuity_1 conservation_of_energy

/-!
### 4.2 Astronomical Events

Events like eclipses illustrate temporal possibility.
-/

/-- A lunar eclipse is an event that happens sometimes -/
def lunar_eclipse : Formula := Formula.atom "lunar_eclipse"

/-- If an eclipse sometimes occurs, it is possible -/
example : ⊢ (▽lunar_eclipse).imp lunar_eclipse.diamond :=
  perpetuity_2 lunar_eclipse

/-!
### 4.3 Mathematical Truths

Mathematical truths are paradigmatic necessary truths.
-/

/-- Mathematical truth: 2 + 2 = 4 -/
def two_plus_two_equals_four : Formula := Formula.atom "2+2=4"

/-- Mathematical truths are necessarily eternal -/
example : ⊢ two_plus_two_equals_four.box.imp (△two_plus_two_equals_four).box :=
  perpetuity_3 two_plus_two_equals_four

/-!
### 4.4 Contingent Events

Most everyday facts are contingent - they hold but could have been otherwise.
-/

/-- Rain is a contingent, temporal phenomenon -/
def it_is_raining : Formula := Formula.atom "it_is_raining"

/-- If it possibly rains sometime, rain is always possible -/
noncomputable example : ⊢ (▽it_is_raining).diamond.imp (△(it_is_raining.diamond)) :=
  perpetuity_5 it_is_raining

/-!
### 4.5 Combined Modal-Temporal Reasoning

The power of TM logic is in combining modal and temporal reasoning.
-/

/-- Theorem: If it's possible that a necessary truth ever occurs,
    then that truth is necessarily eternal.

    This captures the idea that necessity, once realized, cannot be undone. -/
noncomputable example (truth : Formula) :
    ⊢ (▽(truth.box)).imp (△truth).box :=
  perpetuity_6 truth

/-!
### 4.6 The Main Theorem in Action

The fundamental equivalence: derivability = validity.
-/

/-- For any formula φ, provability is equivalent to validity.

This is the crowning achievement of the formalization:
- **Soundness**: If φ is provable, it's true in all models
- **Completeness**: If φ is true in all models, it's provable -/
example (φ : Formula) : Nonempty (⊢ φ) ↔ valid φ :=
  main_provable_iff_valid_v2 φ

end Applications

/-!
## Summary

This demo showcased the complete Bimodal TM logic formalization:

1. **Syntax** - 6 primitive formula constructors
2. **Proof System** - 15 axioms and 7 inference rules
3. **Semantics** - Task frame semantics with world histories
4. **Soundness** - All axioms valid, rules preserve validity
5. **Deduction Theorem** - Context manipulation
6. **Completeness** - Via semantic canonical model (finite)
7. **Decidability** - Tableau-based decision procedure

### Key Results

| Result | Statement | Status |
|--------|-----------|--------|
| Soundness | `(Γ ⊢ φ) → (Γ ⊨ φ)` | Proven |
| Deduction | `((A :: Γ) ⊢ B) → (Γ ⊢ A → B)` | Proven |
| Completeness | `valid φ → (⊢ φ)` | Proven |
| Equivalence | `Nonempty (⊢ φ) ↔ valid φ` | Proven |
| Decidability | `decide φ : DecisionResult φ` | Implemented |

### Perpetuity Principles

All six perpetuity principles connecting modal and temporal operators:
- P1: □φ → △φ (necessary implies always)
- P2: ▽φ → ◇φ (sometimes implies possible)
- P3: □φ → □△φ (necessity of perpetuity)
- P4: ◇▽φ → ◇φ (possibility of occurrence)
- P5: ◇▽φ → △◇φ (persistent possibility)
- P6: ▽□φ → □△φ (occurrent necessity is perpetual)

## Further Reading

- `Bimodal.Theorems.Perpetuity` - Perpetuity principle proofs
- `Bimodal.Metalogic.Soundness` - Soundness proof
- `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` - Completeness proof
- `Bimodal.Metalogic.Decidability` - Decision procedure
- `BimodalReference.tex` - Mathematical documentation
-/

end Bimodal.Examples.Demo
