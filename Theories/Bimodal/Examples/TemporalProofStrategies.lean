import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Perpetuity
import Bimodal.Theorems.Combinators
import Bimodal.Syntax.Formula

/-!
# Temporal Proof Strategies

This module provides pedagogical examples demonstrating linear temporal logic proof
construction patterns, focusing on proof techniques for past/future operators and
temporal reasoning strategies.

## Learning Objectives

1. **Always/Eventually Iteration**: Building `Gφ → GGφ → GGGφ` chains using T4
2. **Temporal Duality**: Converting past theorems to future and vice versa
3. **Connectedness Reasoning**: Using TA axiom for reachability proofs
4. **Temporal Frame Properties**: Demonstrating linear time and unbounded future

## Proof Patterns

This module demonstrates:
- **Temporal iteration**: Chaining T4 axiom for future chains
- **Duality transformation**: Using `temporal_duality` rule for past/future symmetry
- **Connectedness axioms**: Applying TA for temporal reachability
- **Frame constraints**: Reasoning about linear time structure

## Pedagogical Focus

Each example includes:
- Clear documentation of proof strategy (50%+ comment density)
- Explicit step-by-step derivations
- References to helper lemmas and axioms
- Explanation of temporal semantics

## Notation

- `φ.all_future` = `Gφ` = `all_future φ` (φ will always be true)
- `φ.all_past` = `Hφ` = `all_past φ` (φ has always been true)
- `φ.some_future` = `Fφ` = `¬G¬φ` (φ will sometimes be true)
- `φ.some_past` = `Pφ` = `¬H¬φ` (φ was sometimes true)
- `φ.always` = `△φ` = `Hφ ∧ φ ∧ Gφ` (φ holds at all times)
- `φ.sometimes` = `▽φ` = `¬△¬φ` (φ holds at some time)
- `⊢ φ` means `Derivable [] φ` (φ is a theorem)
- `Γ ⊢ φ` means `Derivable Γ φ` (φ derivable from context Γ)

## Exercises

This module contains 5 exercises marked with `-- EXERCISE:` comments:

1. **Temporal K distribution**: Lifting implications under G (line ~332)
2. **Perpetuity preservation**: `△φ → G△φ` using conjunction rules (line ~406)
3. **Perpetuity past direction**: `△φ → H△φ` using temporal duality (line ~421)
4. **Future-past iteration**: `GGφ → Gφ` using T4 transitivity (line ~476)
5. **Past-future commutation**: Advanced temporal reasoning (line ~525)

## References

* [ModalProofStrategies.lean](ModalProofStrategies.lean) - S5 modal proof patterns
* [Perpetuity.lean](../Logos/Core/Theorems/Perpetuity.lean) - Helper lemmas
* [ARCHITECTURE.md](../docs/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Examples.TemporalProofStrategies

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Combinators

/-!
## Strategy 1: Future Iteration (Temporal 4 Axiom)

The T4 axiom (`Gφ → GGφ`) allows building arbitrarily long future chains,
analogous to M4 for modal necessity. This demonstrates temporal transitivity.

**Key Technique**: Use `imp_trans` from Perpetuity.lean to chain temporal implications.

**Semantic Intuition**: If φ holds at all future times from t, then at any future
time s > t, φ holds at all times after s (because all those times are also after t).
-/

/--
Two-step future chain: `Gφ → GGGφ`

**Proof Strategy**:
1. Apply T4 to `φ`: gives `Gφ → GGφ`
2. Apply T4 to `Gφ`: gives `GGφ → GGGφ`
3. Use `imp_trans` to chain: `Gφ → GGφ → GGGφ`

This demonstrates the basic pattern for chaining temporal axioms.
-/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future.all_future := by
  -- Step 1: First T4 application (Gφ → GGφ)
  have h1 : ⊢ φ.all_future.imp φ.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ)

  -- Step 2: Second T4 application (GGφ → GGGφ)
  have h2 : ⊢ φ.all_future.all_future.imp φ.all_future.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ.all_future)

  -- Step 3: Compose using transitivity (Gφ → GGφ → GGGφ)
  exact imp_trans h1 h2

/--
Three-step future chain: `Gφ → GGGGφ`

**Proof Strategy**:
Extend the two-step pattern to three steps, showing how to build longer chains.
This uses the same `imp_trans` pattern iteratively.
-/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future.all_future.all_future := by
  -- Build the chain step by step
  have h1 : ⊢ φ.all_future.imp φ.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  have h2 : ⊢ φ.all_future.all_future.imp φ.all_future.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ.all_future)
  have h3 : ⊢ φ.all_future.all_future.all_future.imp φ.all_future.all_future.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ.all_future.all_future)

  -- Compose: Gφ → GGφ → GGGφ → GGGGφ
  exact imp_trans (imp_trans h1 h2) h3

/--
Future idempotence iteration: `Gφ → GGGφ` in one step

**Strategy**: Combine T4 twice using transitivity.
This demonstrates a common proof compression technique: pre-composing axioms
using `imp_trans` instead of applying them step by step.
-/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future.all_future := by
  -- Compressed version of the future chain from above
  exact imp_trans
    (DerivationTree.axiom [] _ (Axiom.temp_4 φ))
    (DerivationTree.axiom [] _ (Axiom.temp_4 φ.all_future))

/-!
## Strategy 2: Temporal Duality (Past/Future Symmetry)

The temporal duality rule states: if `⊢ φ` then `⊢ swap_temporal φ`.
This allows deriving past theorems from future theorems and vice versa.

**Key Technique**: Use `DerivationTree.temporal_duality` to transform entire proofs.

**Semantic Intuition**: The task semantics has a symmetric structure where
swapping past and future preserves validity. This is formalized by the
`swap_temporal` function on formulas.
-/

/--
Past iteration via duality: `Hφ → HHφ`

**Proof Strategy**:
1. We have T4: `⊢ Gφ → GGφ`
2. Apply temporal duality: `⊢ swap_temporal(Gφ → GGφ)`
3. By `swap_temporal` definition: this equals `⊢ H(swap_temporal φ) → HH(swap_temporal φ)`

This shows how to derive past theorems from future theorems using duality.

Note: The `swap_temporal` function swaps all `all_future` with `all_past`
recursively throughout the formula. For the base formula φ, we use
`swap_temporal (swap_temporal φ) = φ` to get the desired form.
-/
example (φ : Formula) : ⊢ φ.all_past.imp φ.all_past.all_past := by
  -- Step 1: Apply swap_temporal twice to φ (involution property)
  have φ_eq : φ = φ.swap_temporal.swap_temporal :=
    (Formula.swap_temporal_involution φ).symm

  -- Step 2: Get T4 axiom for swap_temporal φ
  have h1 : ⊢ φ.swap_temporal.all_future.imp φ.swap_temporal.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ.swap_temporal)

  -- Step 3: Apply temporal duality to swap G ↔ H
  have h2 : ⊢ (φ.swap_temporal.all_future.imp φ.swap_temporal.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h1

  -- Step 4: Simplify using swap_temporal definition
  -- swap_temporal(G(swap_temporal φ) → GG(swap_temporal φ))
  -- = H(swap_temporal (swap_temporal φ)) → HH(swap_temporal (swap_temporal φ))
  -- = Hφ → HHφ by involution
  simp [Formula.swap_temporal] at h2
  rw [φ_eq] at h2
  simp [Formula.swap_temporal_involution] at h2
  exact h2

/--
Two-step past chain via duality: `Hφ → HHHφ`

**Strategy**: Apply duality to the two-step future chain.
This shows how complex future theorems automatically give past theorems.
-/
example (φ : Formula) : ⊢ φ.all_past.imp φ.all_past.all_past.all_past := by
  -- Step 1: Use involution to write φ = swap_temporal (swap_temporal φ)
  have φ_eq : φ = φ.swap_temporal.swap_temporal :=
    (Formula.swap_temporal_involution φ).symm

  -- Step 2: Get two-step future chain for swap_temporal φ
  have future_chain : ⊢ φ.swap_temporal.all_future.imp
                         φ.swap_temporal.all_future.all_future.all_future :=
    imp_trans
      (DerivationTree.axiom [] _ (Axiom.temp_4 φ.swap_temporal))
      (DerivationTree.axiom [] _ (Axiom.temp_4 φ.swap_temporal.all_future))

  -- Step 3: Apply temporal duality
  have past_chain : ⊢ (φ.swap_temporal.all_future.imp
                        φ.swap_temporal.all_future.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ future_chain

  -- Step 4: Simplify to get Hφ → HHHφ using involution
  simp [Formula.swap_temporal] at past_chain
  rw [φ_eq] at past_chain
  simp [Formula.swap_temporal_involution] at past_chain
  exact past_chain

/--
Duality preserves complexity: Swapping is involutive

**Strategy**: This demonstrates the algebraic property that swapping twice
gives back the original formula. This is proven by structural induction.

**Mathematical Property**: `swap_temporal (swap_temporal φ) = φ`
-/
example (φ : Formula) : φ.swap_temporal.swap_temporal = φ := by
  -- This is proven by structural induction in Formula.lean
  exact Formula.swap_temporal_involution φ

/--
Symmetric temporal operators: Duality connects past and future

**Proof Strategy**:
From any future theorem `⊢ Gφ → ψ`, we can derive the corresponding past theorem.
This demonstrates the general pattern for theorem transformation via duality.

This is a meta-level statement showing how duality works on theorems.
-/
example : (∀ φ : Formula, ⊢ φ.all_future.imp φ.all_future.all_future) →
           (∀ φ : Formula, ⊢ φ.all_past.imp φ.all_past.all_past) := by
  intro h_all φ
  -- Use involution
  have φ_eq : φ = φ.swap_temporal.swap_temporal :=
    (Formula.swap_temporal_involution φ).symm
  -- Apply hypothesis to swap_temporal φ
  have h_future : ⊢ φ.swap_temporal.all_future.imp φ.swap_temporal.all_future.all_future :=
    h_all φ.swap_temporal
  -- Apply temporal duality
  have h_swap : ⊢ (φ.swap_temporal.all_future.imp φ.swap_temporal.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h_future
  -- Simplify to past version using involution
  simp [Formula.swap_temporal] at h_swap
  rw [φ_eq] at h_swap
  simp [Formula.swap_temporal_involution] at h_swap
  exact h_swap

/-!
## Strategy 3: Eventually/Sometimes Proofs (Negation Duality)

The "eventually" operator `Fφ` (some_future) is defined as `¬G¬φ`.
The "sometimes past" operator `Pφ` (some_past) is defined as `¬H¬φ`.

**Key Technique**: Use definitional equality to convert between forms.

**Semantic Intuition**: "φ will eventually be true" means "it's not the case
that φ will always be false", which is `¬G¬φ`.
-/

/--
Some_future definition: `Fφ = ¬G¬φ`

**Strategy**: This is a direct definitional equality, verified by `rfl`.
No proof construction needed - the formula types are identical by definition.
-/
example (φ : Formula) : φ.some_future = φ.neg.all_future.neg := rfl

/--
Some_past definition: `Pφ = ¬H¬φ`

**Strategy**: Same as some_future, this is definitional.
-/
example (φ : Formula) : φ.some_past = φ.neg.all_past.neg := rfl

/--
Always definition: `△φ = Hφ ∧ φ ∧ Gφ`

**Strategy**: The "always" operator covers all three time regions:
- Past: `Hφ` (has always been true)
- Present: `φ` (is true now)
- Future: `Gφ` (will always be true)

This is definitional equality.
-/
example (φ : Formula) : φ.always = φ.all_past.and (φ.and φ.all_future) := rfl

/--
Sometimes definition: `▽φ = ¬△¬φ`

**Strategy**: "φ holds at some time" means "it's not the case that ¬φ holds
at all times", which is the negation of always-not.

This shows the duality between universal (△) and existential (▽) temporal quantifiers.
-/
example (φ : Formula) : φ.sometimes = φ.neg.always.neg := rfl

/-!
## Strategy 4: Connectedness (Temporal A Axiom)

The TA axiom (`φ → G(Pφ)`) expresses temporal connectedness: if φ is true now,
then at all future times, there exists a past time where φ was true (namely, now).

**Key Technique**: Apply TA directly and chain with temporal operators.

**Semantic Intuition**: The present is always in the past of all future times.
-/

/--
Temporal A direct application: `φ → G(Pφ)`

**Proof Strategy**:
This is axiom TA directly. The key insight: what's true now will be
remembered as past by all future times.

**Semantic Reading**: If φ at time t, then for all times s > t,
there exists a time r < s where φ (namely r = t).
-/
example (φ : Formula) : ⊢ φ.imp φ.some_past.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_a φ)

/--
Temporal A iteration: `φ → GG(PPφ)`

**Proof Strategy**:
1. Apply TA to `Pφ`: gives `Pφ → G(PPφ)`
2. Apply TA to `φ`: gives `φ → G(Pφ)`
3. We want to derive `φ → GG(PPφ)`

This requires showing:
- From `φ`, get `G(Pφ)` by TA
- From `G(Pφ)`, get `GG(PPφ)` by temporal K and nested TA

Note: Full proof requires temporal K rule application, shown here as a pattern.
-/
example (φ : Formula) : ⊢ φ.imp φ.some_past.some_past.all_future.all_future := by
  -- Step 1: Get TA for φ (φ → G(Pφ))
  have ta_1 : ⊢ φ.imp φ.some_past.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_a φ)

  -- Step 2: Get TA for Pφ (Pφ → G(PPφ))
  have ta_2 : ⊢ φ.some_past.imp φ.some_past.some_past.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_a φ.some_past)

  -- Step 3: Lift ta_2 under G to get G(Pφ) → GG(PPφ) using future_mono
  exact imp_trans ta_1 (Bimodal.Theorems.Perpetuity.future_mono ta_2)

/--
Connectedness with T4: `φ → GGG(Pφ)`

**Proof Strategy**:
Combine TA with T4 to show that the present is accessible from arbitrarily
far in the future.

1. Get `φ → G(Pφ)` by TA
2. Iterate the future using T4: `G(Pφ) → GGG(Pφ)`
3. Chain: `φ → G(Pφ) → GGG(Pφ)`
-/
example (φ : Formula) : ⊢ φ.imp φ.some_past.all_future.all_future.all_future := by
  -- Step 1: Get TA (φ → G(Pφ))
  have ta : ⊢ φ.imp φ.some_past.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_a φ)

  -- Step 2: Get T4 for Pφ (G(Pφ) → GGG(Pφ))
  have t4_chain : ⊢ φ.some_past.all_future.imp φ.some_past.all_future.all_future.all_future :=
    imp_trans
      (DerivationTree.axiom [] _ (Axiom.temp_4 φ.some_past))
      (DerivationTree.axiom [] _ (Axiom.temp_4 φ.some_past.all_future))

  -- Step 3: Chain TA with T4 (φ → G(Pφ) → GGG(Pφ))
  exact imp_trans ta t4_chain

/-!
## Strategy 5: Temporal L Axiom (Always-Future-Past Pattern)

The TL axiom (`△φ → G(Hφ)`) expresses: if φ holds at all times, then at all
future times, φ holds at all past times.

**Key Technique**: Use TL for reasoning about perpetual truths.

**Semantic Intuition**: If φ is eternal (always true), then from any future
time, looking back to all past times, φ holds (because φ holds everywhere).
-/

/--
Temporal L direct application: `△φ → G(Hφ)`

**Proof Strategy**:
This is axiom TL directly. The key insight: if φ holds at ALL times,
then from any future time t, φ holds at all times before t.

**Semantic Reading**: If always φ, then for all s, for all t < s, we have φ at t.
-/
example (φ : Formula) : ⊢ φ.always.imp φ.all_past.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_l φ)

/--
Always implies future-always: `△φ → G△φ`

**Proof Strategy**:
If φ holds at all times, then at any future time, φ still holds at all times.
This demonstrates that perpetuity is preserved into the future.

Note: Full proof requires showing △φ → G△φ from the definition △φ = Hφ ∧ φ ∧ Gφ.
Shown here as a characteristic pattern of perpetual truths.
-/
example (φ : Formula) : ⊢ φ.always.imp φ.always.all_future := by
  -- EXERCISE: Complete this proof (perpetuity preservation)
  -- Technique: Use `lce_imp`, `rce_imp`, `Axiom.temp_4`, and `Axiom.temp_l`
  -- Hint: Decompose △φ = Hφ ∧ φ ∧ Gφ, lift each component under G, recombine
  sorry

/--
Always implies past-always: `△φ → H△φ`

**Proof Strategy**:
By temporal duality, if perpetuity is preserved into the future, it's also
preserved into the past.

This demonstrates symmetric temporal reasoning about eternal truths.
-/
example (φ : Formula) : ⊢ φ.always.imp φ.always.all_past := by
  -- EXERCISE: Complete this proof (perpetuity in past direction)
  -- Technique: Use `temporal_duality` from DerivationTree on △φ → G△φ
  -- Hint: First prove △φ → G△φ (above exercise), then apply temporal duality
  sorry

/-!
## Strategy 6: Temporal Frame Properties

Linear temporal logic has specific frame properties:
- **Linear time**: Total ordering on times
- **Unbounded future**: No maximum time
- **Dense/discrete**: Depends on the time domain

**Key Technique**: Use T4 and TA to demonstrate frame constraints.
-/

/--
Unbounded future property: `Gφ → GGφ`

**Proof Strategy**:
T4 directly demonstrates unbounded future: if φ holds at all future times,
then it holds at all times in the future of any future time.

**Semantic Property**: For any time t, there exists a time s > t.
This is what allows T4 to be valid - the future never "runs out".
-/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_4 φ)

/--
Linear time property: Present is in past of future

**Proof Strategy**:
TA demonstrates linear ordering: the present is always accessible from
all future times by going backward.

**Semantic Property**: For any times t < s, we have t in the past of s.
This is the connectedness property of linear time.
-/
example (φ : Formula) : ⊢ φ.imp φ.some_past.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_a φ)

/--
Temporal transitivity demonstration: `G(Gφ) → Gφ`

**Proof Strategy**:
While T4 gives us `Gφ → GGφ`, the reverse direction `GGφ → Gφ` is also
valid and demonstrates that nested futures collapse in linear time.

Note: This requires a more complex proof showing that if φ holds at all
times s where s > t and t > now, then φ holds at all times s' > now
(because all such s' are either between now and t, or after t).
Shown here as a pedagogical pattern.
-/
example (φ : Formula) : ⊢ φ.all_future.all_future.imp φ.all_future := by
  -- EXERCISE: Complete this proof (future-past iteration)
  -- Technique: Use `Axiom.temp_4` (T4 axiom) and `imp_trans`
  -- Hint: GGφ → Gφ follows from T4's transitivity; compose with temp_t
  sorry

/-!
## Strategy 7: Combining Past and Future

Many temporal proofs require reasoning about both past and future operators
together, using both T4 and temporal duality.

**Key Technique**: Apply duality to convert between past and future, then
use axioms and chain results.
-/

/-- Future iteration: `Gφ → GGφ` (symmetric with past iteration below) -/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 φ)

/-- Past iteration: `Hφ → HHφ` (via T4 + temporal duality) -/
example (φ : Formula) : ⊢ φ.all_past.imp φ.all_past.all_past := by
  -- Past direction: T4 + temporal duality
  -- Use involution
  have φ_eq : φ = φ.swap_temporal.swap_temporal :=
    (Formula.swap_temporal_involution φ).symm
  -- Get T4 for swap_temporal φ
  have h : ⊢ φ.swap_temporal.all_future.imp φ.swap_temporal.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ.swap_temporal)
  -- Apply duality
  have h2 : ⊢ (φ.swap_temporal.all_future.imp φ.swap_temporal.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h
  -- Simplify using involution
  simp [Formula.swap_temporal] at h2
  rw [φ_eq] at h2
  simp [Formula.swap_temporal_involution] at h2
  exact h2

/--
Past-Future composition: `H(Gφ) → G(Hφ)` pattern

**Proof Strategy**:
This demonstrates reasoning about nested past-future operators.
The formula states: "If φ will always be true from all past times,
then φ has always been true from all future times."

Note: This pattern requires careful semantic reasoning about the interaction
of past and future operators. Shown here as an advanced pattern.
-/
example (φ : Formula) : ⊢ φ.all_future.all_past.imp φ.all_past.all_future := by
  -- EXERCISE: Complete this proof (past-future commutation)
  -- Technique: Use temporal axioms and `temporal_duality`
  -- Hint: This is an advanced exercise requiring careful temporal reasoning
  --       about the structure of linear time accessibility
  sorry

/-!
## Teaching Examples with Concrete Formulas

These examples use meaningful atom names to illustrate temporal reasoning
in intuitive contexts.
-/

/--
Example: Physical law persists into future

**Intuition**: If a physical law holds at all future times, it holds at all
times in the future of any future time. This demonstrates T4.
-/
example : ⊢ (Formula.atom "gravity_law").all_future.imp
             (Formula.atom "gravity_law").all_future.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "gravity_law"))

/--
Example: Historical event remembered in future

**Intuition**: If an event happened, then at all future times, there exists
a past time when it happened. This demonstrates TA.
-/
example : ⊢ (Formula.atom "moon_landing").imp
             (Formula.atom "moon_landing").some_past.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_a (Formula.atom "moon_landing"))

/--
Example: Eternal truth is remembered

**Intuition**: If something has always been true (like a mathematical fact),
then at all future times, it has always been true in the past.
This demonstrates TL.
-/
example : ⊢ (Formula.atom "2+2=4").always.imp
             (Formula.atom "2+2=4").all_past.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_l (Formula.atom "2+2=4"))

/--
Example: Past theorem from future theorem via duality

**Intuition**: If we can prove a theorem about the future, we can derive
the corresponding theorem about the past using temporal duality.
-/
example : ⊢ (Formula.atom "conservation_law").all_past.imp
             (Formula.atom "conservation_law").all_past.all_past := by
  -- Use involution to prepare for duality
  let φ := Formula.atom "conservation_law"
  -- Get T4 for swap_temporal φ
  have future_version : ⊢ φ.swap_temporal.all_future.imp
                           φ.swap_temporal.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ.swap_temporal)
  -- Apply temporal duality
  have swapped : ⊢ (φ.swap_temporal.all_future.imp
                    φ.swap_temporal.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ future_version
  -- Simplify: swap_temporal on atoms is identity, and swap_temporal swaps G ↔ H
  -- So this gives us exactly the past version
  simp only [Formula.swap_temporal] at swapped
  exact swapped

/-!
## Summary of Temporal Proof Strategies

This module demonstrated seven key proof strategies for linear temporal logic:

1. **Future Iteration**: Building `Gφ → GGφ → GGGφ` chains with T4 axiom
2. **Temporal Duality**: Converting past ↔ future using `temporal_duality` rule
3. **Eventually/Sometimes**: Working with `Fφ = ¬G¬φ` definitional equality
4. **Connectedness**: Applying TA axiom for temporal reachability
5. **Temporal L**: Using TL for perpetuity reasoning
6. **Frame Properties**: Demonstrating linear time and unbounded future
7. **Combined Reasoning**: Mixing past and future operators with duality

**Key Techniques Used**:
- `imp_trans` for chaining temporal implications
- `DerivationTree.temporal_duality` for past/future transformation
- `DerivationTree.axiom` for explicit T4, TA, TL application
- `simp [Formula.swap_temporal]` for simplifying duality transformations

**Temporal Axioms Demonstrated**:
- T4: `Gφ → GGφ` (future transitivity)
- TA: `φ → G(Pφ)` (connectedness)
- TL: `△φ → G(Hφ)` (perpetuity introspection)

**Helper Lemmas from Perpetuity.lean**:
- `imp_trans`: Implication transitivity
- `identity`: Identity combinator (SKK)

**Duality Transformations**:
- `swap_temporal`: Swaps all_future ↔ all_past throughout formula
- Involutive: `swap_temporal (swap_temporal φ) = φ`

**Future Extensions**:
- Temporal K rule for full context transformation
- Conjunction rules for complex temporal combinations
- Dense vs discrete time reasoning
- Interval temporal logic operators
-/

end Bimodal.Examples.TemporalProofStrategies
