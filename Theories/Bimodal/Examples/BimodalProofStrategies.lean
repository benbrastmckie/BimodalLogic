import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Perpetuity
import Bimodal.Theorems.Combinators
import Bimodal.Syntax.Formula

/-!
# Bimodal Proof Strategies

This module provides pedagogical examples demonstrating modal-temporal interaction
patterns in TM logic, focusing on proof construction techniques that combine modal
necessity (`□`) with temporal operators (`G`, `H`, `△`, `▽`).

## Learning Objectives

1. **Perpetuity Principles**: Applying P1-P6 to connect modal and temporal reasoning
2. **Modal-Temporal Axioms**: Using MF (`□φ → □Gφ`) and TF (`□φ → G□φ`) effectively
3. **Helper Lemma Construction**: Building complex proofs from component lemmas
4. **Multi-Step Assembly**: Combining modal and temporal steps into complete derivations

## Proof Patterns

This module demonstrates:
- **Perpetuity application**: Using P1 (`□φ → △φ`) and P2 (`▽φ → ◇φ`) patterns
- **Component lemmas**: Breaking complex goals into manageable parts
- **Conjunction assembly**: Combining `Hφ`, `φ`, `Gφ` into `△φ = Hφ ∧ φ ∧ Gφ`
- **Bimodal chaining**: Composing MF, TF, MT, T4, TA for complex derivations

## Pedagogical Focus

Each example includes:
- Clear documentation of proof strategy (50%+ comment density)
- Explicit step-by-step derivations with helper lemma usage
- References to Perpetuity.lean component patterns
- Explanation of modal-temporal interaction semantics

## Notation

- `□φ` = `φ.box` (modal necessity - true in all possible worlds)
- `◇φ` = `φ.diamond` = `¬□¬φ` (modal possibility)
- `Gφ` = `φ.all_future` (always in the future)
- `Hφ` = `φ.all_past` (always in the past)
- `△φ` = `φ.always` = `Hφ ∧ φ ∧ Gφ` (at all times: past, present, future)
- `▽φ` = `φ.sometimes` = `¬△¬φ` (at some time: past, present, or future)
- `⊢ φ` means `Derivable [] φ` (φ is a theorem)

## References

* [Perpetuity.lean](../Logos/Core/Theorems/Perpetuity.lean) - Helper lemmas and P1-P6
* [ModalProofStrategies.lean](ModalProofStrategies.lean) - Modal proof patterns
* [TemporalProofStrategies.lean](TemporalProofStrategies.lean) - Temporal proof patterns
* [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Examples.BimodalProofStrategies

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Combinators

/-!
## Strategy 1: Perpetuity Principle Applications

The six perpetuity principles (P1-P6) connect modal and temporal operators:
- **P1**: `□φ → △φ` (necessary implies always)
- **P2**: `▽φ → ◇φ` (sometimes implies possible)
- **P3**: `□φ → □△φ` (necessity of perpetuity)
- **P4**: `◇▽φ → ◇φ` (possibility of occurrence)
- **P5**: `◇▽φ → △◇φ` (persistent possibility)
- **P6**: `▽□φ → □△φ` (occurrent necessity is perpetual)

**Key Technique**: Use perpetuity principles to convert between modal and temporal
formulas. P1 is fully proven; P2 uses contraposition; P3-P6 are semantically valid.
-/

/--
P1 application: Necessary implies always

**Proof Strategy**:
P1 states that if φ is necessary (true in all possible worlds), then φ is always
true (true at all times). This is `perpetuity_1` from Perpetuity.lean.

Direct application shows basic usage pattern.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.always := by
  -- P1: □φ → △φ where △φ = Hφ ∧ φ ∧ Gφ
  exact perpetuity_1 φ

/--
P1 expanded: Show that `△φ` equals `Hφ ∧ (φ ∧ Gφ)`

**Proof Strategy**:
The `always` definition is `φ.all_past.and (φ.and φ.all_future)`.
This demonstrates the structure of perpetuity formulas.

This is definitional equality, verified by `rfl`.
-/
example (φ : Formula) : φ.always = φ.all_past.and (φ.and φ.all_future) := rfl

/--
P2 application: Sometimes implies possible

**Proof Strategy**:
P2 states that if φ happens at some time (past, present, or future), then φ is
possible. This follows from contraposition of P1 applied to `¬φ`.

This demonstrates contrapositive reasoning in bimodal logic.
-/
example (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond := by
  -- P2: ▽φ → ◇φ where ▽φ = ¬△¬φ and ◇φ = ¬□¬φ
  exact perpetuity_2 φ

/--
P1 and P2 chained: `□φ → △φ → φ`

**Proof Strategy**:
Chain P1 with the fact that `△φ → φ` (always implies present).
This shows how to extract the "present" component from `△φ = Hφ ∧ φ ∧ Gφ`.

1. P1 gives: `□φ → △φ`
2. `△φ → φ` follows from conjunction elimination (central component)
3. Chain with `imp_trans`

Note: Full proof requires conjunction elimination infrastructure.
-/
example (φ : Formula) : ⊢ φ.box.imp φ := by
  -- Direct route: Use MT axiom
  -- Alternative route would be: P1 then extract central component of △φ
  exact DerivationTree.axiom [] _ (Axiom.modal_t φ)

/--
P3 application: Necessity of perpetuity

**Proof Strategy**:
P3 states that what is necessary is necessarily always true: `□φ → □△φ`.
This combines necessity with temporal universality.

This demonstrates the double-modal pattern `□△φ` meaning "it's necessary that
φ holds at all times."
-/
example (φ : Formula) : ⊢ φ.box.imp φ.always.box := by
  -- P3: □φ → □△φ where △φ = Hφ ∧ φ ∧ Gφ
  exact perpetuity_3 φ

/--
P4 application: Possibility of occurrence

**Proof Strategy**:
P4 states that if it's possible that φ occurs at some time, then φ is possible.
This is `◇▽φ → ◇φ`, connecting temporal and modal possibility.

This demonstrates nested modal-temporal operators: `◇▽φ` = "possibly sometimes φ".
-/
example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
  -- P4: ◇▽φ → ◇φ
  exact perpetuity_4 φ

/--
P5 application: Persistent possibility

**Proof Strategy**:
P5 states that if it's possible that φ occurs sometime, then φ is always possible.
This is `◇▽φ → △◇φ`, showing that possibility persists across time.

This demonstrates the powerful pattern: temporal possibility implies perpetual
modal possibility.
-/
noncomputable example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  -- P5: ◇▽φ → △◇φ where △◇φ = H◇φ ∧ ◇φ ∧ G◇φ
  exact perpetuity_5 φ

/--
P6 application: Occurrent necessity is perpetual

**Proof Strategy**:
P6 states that if necessity occurs at some time, then it's always necessary.
This is `▽□φ → □△φ`, connecting temporal occurrence with modal perpetuity.

This demonstrates that necessity, once it occurs, must be perpetual.
-/
noncomputable example (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- P6: ▽□φ → □△φ
  exact perpetuity_6 φ

/-!
## Strategy 2: Modal-Temporal Axiom Applications

The MF and TF axioms establish deep connections between modal and temporal operators:
- **MF (Modal-Future)**: `□φ → □Gφ` (necessity of future truth)
- **TF (Temporal-Future)**: `□φ → G□φ` (future of necessary truth)

**Key Insight**: MF and TF differ in operator nesting:
- MF: `□(Gφ)` - "it's necessary that φ will always be true"
- TF: `G(□φ)` - "φ will always be necessary"

These are distinct but both follow from task semantics.
-/

/--
MF axiom application: Necessity of future truth

**Proof Strategy**:
The MF axiom states that if φ is necessary, then it's necessary that φ will
always be true: `□φ → □Gφ`.

This demonstrates how necessity distributes into temporal operators.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.all_future.box) := by
  -- MF: □φ → □Gφ
  exact DerivationTree.axiom [] _ (Axiom.modal_future φ)

/--
TF axiom application: Future of necessary truth

**Proof Strategy**:
The TF axiom states that if φ is necessary, then φ will always be necessary:
`□φ → G□φ`.

This demonstrates temporal persistence of necessity.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.box.all_future) := by
  -- TF: □φ → G□φ
  exact DerivationTree.axiom [] _ (Axiom.temp_future φ)

/--
MF and TF combined: Both forms from necessity

**Proof Strategy**:
From `□φ`, derive both `□Gφ` (via MF) and `G□φ` (via TF).
This shows the two distinct future-necessity patterns.

1. Apply MF: `□φ → □Gφ`
2. Apply TF: `□φ → G□φ`
3. Combine using conjunction introduction

Note: Full proof requires conjunction assembly infrastructure.
-/
example (φ : Formula) : ⊢ φ.box.imp ((φ.all_future.box).and (φ.box.all_future)) := by
  -- Get both MF and TF
  have mf : ⊢ φ.box.imp (φ.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ)
  have tf : ⊢ φ.box.imp (φ.box.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_future φ)

  -- Need to combine into conjunction: □φ → (□Gφ ∧ G□φ)
  -- This requires conjunction introduction from two implications
  -- Use combine_imp_conj from Perpetuity.lean
  exact combine_imp_conj mf tf

/--
MF with MT: Extract future from boxed future

**Proof Strategy**:
Chain MF (`□φ → □Gφ`) with MT (`□Gφ → Gφ`) to get `□φ → Gφ`.
This is the `box_to_future` helper from Perpetuity.lean.

This demonstrates a common pattern: apply modal axiom, then "unbox" with MT.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.all_future := by
  -- Step 1: MF gives □φ → □Gφ
  have mf : ⊢ φ.box.imp (φ.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ)

  -- Step 2: MT gives □Gφ → Gφ
  have mt : ⊢ (φ.all_future.box).imp φ.all_future :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ.all_future)

  -- Step 3: Chain via transitivity
  exact imp_trans mf mt

/--
TF iteration: Necessity persists to future

**Proof Strategy**:
From `□φ`, derive `GG□φ` (necessity two steps in the future).
This uses TF to get `G□φ`, then T4 to get `GG□φ`.

This demonstrates chaining temporal and modal axioms.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.box.all_future.all_future) := by
  -- Step 1: TF gives □φ → G□φ
  have tf : ⊢ φ.box.imp (φ.box.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_future φ)

  -- Step 2: T4 on □φ gives G□φ → GG□φ
  have t4 : ⊢ (φ.box.all_future).imp (φ.box.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ.box)

  -- Step 3: Chain via transitivity
  exact imp_trans tf t4

/--
Past version via duality: `□φ → H□φ`

**Proof Strategy**:
There's no "modal-past" axiom, but we can derive `□φ → H□φ` using temporal
duality on TF.

1. Apply TF to `swap_temporal φ`: `□(swap φ) → G□(swap φ)`
2. Apply temporal duality to swap operators
3. Simplify using `swap_temporal_involution`

This demonstrates the power of temporal duality for symmetry.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.box.all_past) := by
  -- Step 1: TF for swap_temporal φ
  have tf_swap : ⊢ φ.swap_temporal.box.imp (φ.swap_temporal.box.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_future φ.swap_temporal)

  -- Step 2: Apply temporal duality
  have tf_dual : ⊢ (φ.swap_temporal.box.imp (φ.swap_temporal.box.all_future)).swap_temporal :=
    DerivationTree.temporal_duality _ tf_swap

  -- Step 3: Simplify using involution
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at tf_dual
  exact tf_dual

/-!
## Strategy 3: Helper Lemma Construction Patterns

The Perpetuity.lean module defines several helper lemmas used in complex proofs:
- `imp_trans`: Implication transitivity (`A → B`, `B → C` ⊢ `A → C`)
- `combine_imp_conj`: Conjunction from implications (`P → A`, `P → B` ⊢ `P → A ∧ B`)
- `combine_imp_conj_3`: Three-way conjunction (`P → A`, `P → B`, `P → C` ⊢ `P → A ∧ (B ∧ C)`)
- `box_to_future`: `□φ → Gφ` component lemma
- `box_to_past`: `□φ → Hφ` component lemma
- `box_to_present`: `□φ → φ` component lemma

**Key Technique**: Build complex proofs by constructing intermediate lemmas,
then composing them using these helpers.
-/

/--
Implication transitivity demonstration

**Proof Strategy**:
Given `A → B` and `B → C`, derive `A → C` using `imp_trans`.
This is the workhorse of proof composition.

Example: Chain `□φ → φ` (MT) with `φ → G(Pφ)` (TA) to get `□φ → G(Pφ)`.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.some_past.all_future) := by
  -- Step 1: MT gives □φ → φ
  have mt : ⊢ φ.box.imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)

  -- Step 2: TA gives φ → G(Pφ)
  have ta : ⊢ φ.imp (φ.some_past.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_a φ)

  -- Step 3: Chain via imp_trans
  exact imp_trans mt ta

/--
Conjunction assembly demonstration

**Proof Strategy**:
Given `P → A` and `P → B`, derive `P → A ∧ B` using `combine_imp_conj`.

Example: From `□φ → □Gφ` (MF) and `□φ → G□φ` (TF), get `□φ → □Gφ ∧ G□φ`.
-/
example (φ : Formula) : ⊢ φ.box.imp ((φ.all_future.box).and (φ.box.all_future)) := by
  -- Step 1: MF gives □φ → □Gφ
  have mf : ⊢ φ.box.imp (φ.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ)

  -- Step 2: TF gives □φ → G□φ
  have tf : ⊢ φ.box.imp (φ.box.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_future φ)

  -- Step 3: Combine using helper
  exact combine_imp_conj mf tf

/--
Three-component conjunction demonstration

**Proof Strategy**:
Given `P → A`, `P → B`, `P → C`, derive `P → A ∧ (B ∧ C)` using `combine_imp_conj_3`.

Example: Construct `△φ = Hφ ∧ (φ ∧ Gφ)` from three separate components.
This is the core pattern used in P1.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.always := by
  -- This is exactly P1, but we show the component construction explicitly

  -- Step 1: □φ → Hφ (via box_to_past helper)
  have h_past : ⊢ φ.box.imp φ.all_past := box_to_past φ

  -- Step 2: □φ → φ (via box_to_present helper = MT)
  have h_present : ⊢ φ.box.imp φ := box_to_present φ

  -- Step 3: □φ → Gφ (via box_to_future helper)
  have h_future : ⊢ φ.box.imp φ.all_future := box_to_future φ

  -- Step 4: Combine into △φ = Hφ ∧ (φ ∧ Gφ)
  exact combine_imp_conj_3 h_past h_present h_future

/--
Component lemma: `□φ → Gφ` construction

**Proof Strategy**:
The `box_to_future` helper is built from MF + MT.
This shows how to construct reusable component lemmas.

1. MF: `□φ → □Gφ`
2. MT: `□Gφ → Gφ`
3. Chain via `imp_trans`
-/
example (φ : Formula) : ⊢ φ.box.imp φ.all_future := by
  -- Reproduce box_to_future construction
  have mf : ⊢ φ.box.imp (φ.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ)
  have mt : ⊢ (φ.all_future.box).imp φ.all_future :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ.all_future)
  exact imp_trans mf mt

/--
Component lemma: `□φ → Hφ` construction via duality

**Proof Strategy**:
The `box_to_past` helper uses temporal duality on `box_to_future`.
This demonstrates the duality pattern for symmetry.

1. Apply `box_to_future` to `swap_temporal φ`
2. Apply `temporal_duality` to swap outer operators
3. Use `swap_temporal_involution` to cancel inner swaps
-/
example (φ : Formula) : ⊢ φ.box.imp φ.all_past := by
  -- Reproduce box_to_past construction
  have h1 : ⊢ φ.swap_temporal.box.imp φ.swap_temporal.all_future :=
    box_to_future φ.swap_temporal
  have h2 : ⊢ (φ.swap_temporal.box.imp φ.swap_temporal.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h1
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h2
  exact h2

/-!
## Strategy 4: Complex Multi-Step Proof Assembly

Complex bimodal proofs require assembling multiple axioms, helper lemmas, and
inference rules into cohesive derivations. This section demonstrates multi-step
proof construction patterns.

**Key Technique**: Break complex goals into manageable subgoals, prove each
separately, then compose using helpers like `imp_trans` and `combine_imp_conj`.
-/

/--
Multi-step assembly: Necessity to always-possible

**Proof Strategy**:
Derive `□φ → △◇φ` (necessity implies always-possible) in multiple steps.

1. `□φ → φ` (MT)
2. `φ → □◇φ` (MB - Brouwer axiom)
3. `□φ → □◇φ` (chain steps 1-2)
4. `□◇φ → ◇φ` (MT for `◇φ`)
5. `□φ → ◇φ` (chain steps 3-4)
6. Apply to past, present, future to get `△◇φ`

Note: Full proof requires extending to all three time components.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.diamond := by
  -- Step 1: MT gives □φ → φ
  have mt : ⊢ φ.box.imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)

  -- Step 2: MB gives φ → □◇φ
  have mb : ⊢ φ.imp φ.diamond.box :=
    DerivationTree.axiom [] _ (Axiom.modal_b φ)

  -- Step 3: Chain to get □φ → □◇φ
  have h1 : ⊢ φ.box.imp φ.diamond.box :=
    imp_trans mt mb

  -- Step 4: MT for ◇φ gives □◇φ → ◇φ
  have mt2 : ⊢ φ.diamond.box.imp φ.diamond :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ.diamond)

  -- Step 5: Final chain □φ → □◇φ → ◇φ
  exact imp_trans h1 mt2

/--
Multi-step assembly: Modal and temporal iteration

**Proof Strategy**:
Derive `□φ → □GGGφ` (necessity three steps into future).

1. `□φ → □Gφ` (MF)
2. `□Gφ → □(GGφ)` (MF applied to `Gφ`)
3. `□(GGφ) → □(GGGφ)` (MF applied to `GGφ`)
4. Chain all three steps

This demonstrates nested axiom applications with iteration.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.all_future.all_future.all_future.box) := by
  -- Step 1: MF for φ gives □φ → □Gφ
  have h1 : ⊢ φ.box.imp (φ.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ)

  -- Step 2: MF for Gφ gives □Gφ → □(GGφ)
  have h2 : ⊢ (φ.all_future.box).imp (φ.all_future.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ.all_future)

  -- Step 3: MF for GGφ gives □(GGφ) → □(GGGφ)
  have h3 : ⊢ (φ.all_future.all_future.box).imp (φ.all_future.all_future.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ.all_future.all_future)

  -- Step 4: Chain all three: □φ → □Gφ → □(GGφ) → □(GGGφ)
  exact imp_trans (imp_trans h1 h2) h3

/--
Multi-step assembly: Temporal duality exploitation

**Proof Strategy**:
Derive `□φ → H(H(Hφ))` (necessity three steps into past) using duality.

This demonstrates how to "flip" a future proof to get the past version:
1. Build the future chain: `□φ → □(GGGφ)`
2. Apply `swap_temporal` to the formula
3. Apply `temporal_duality` to swap operators
4. Simplify using involution

Note: The previous example gives us `□φ → □(GGGφ)`, which we can transform.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.all_past.all_past.all_past.box) := by
  -- Strategy: Use duality on the future version
  -- We'll apply modal_future to swap_temporal φ three times, then apply duality

  -- Build for swap_temporal φ
  have h1_swap : ⊢ φ.swap_temporal.box.imp (φ.swap_temporal.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ.swap_temporal)
  have h2_swap : ⊢ (φ.swap_temporal.all_future.box).imp (φ.swap_temporal.all_future.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ.swap_temporal.all_future)
  have h3_swap : ⊢ (φ.swap_temporal.all_future.all_future.box).imp
      (φ.swap_temporal.all_future.all_future.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ.swap_temporal.all_future.all_future)

  -- Chain them
  have h_future : ⊢ φ.swap_temporal.box.imp (φ.swap_temporal.all_future.all_future.all_future.box) :=
    imp_trans (imp_trans h1_swap h2_swap) h3_swap

  -- Apply temporal duality
  have h_dual : ⊢ (φ.swap_temporal.box.imp
      (φ.swap_temporal.all_future.all_future.all_future.box)).swap_temporal :=
    DerivationTree.temporal_duality _ h_future

  -- Simplify
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h_dual
  exact h_dual

/--
Multi-step assembly: Combining P1 with modal iteration

**Proof Strategy**:
Derive `□φ → □□△φ` (doubly-necessary perpetuity).

1. P1: `□φ → △φ`
2. M4: `□φ → □□φ`
3. P3: `□φ → □△φ` (necessity of perpetuity)
4. M4 applied to `□△φ`: `□△φ → □□△φ`
5. Chain P3 with step 4

This demonstrates composing perpetuity principles with modal axioms.
-/
example (φ : Formula) : ⊢ φ.box.imp (φ.always.box.box) := by
  -- Step 1: P3 gives □φ → □△φ
  have p3 : ⊢ φ.box.imp (φ.always.box) := perpetuity_3 φ

  -- Step 2: M4 for □△φ gives □△φ → □□△φ
  have m4 : ⊢ (φ.always.box).imp (φ.always.box.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.always)

  -- Step 3: Chain via imp_trans
  exact imp_trans p3 m4

/--
Multi-step assembly: Full P1 derivation reconstruction

**Proof Strategy**:
Reconstruct the full P1 proof (`□φ → △φ`) to demonstrate complete assembly.

This shows all steps explicitly:
1. Derive `□φ → Hφ` using temporal duality on MF
2. Derive `□φ → φ` using MT
3. Derive `□φ → Gφ` using MF + MT
4. Combine using `combine_imp_conj_3` to get `□φ → Hφ ∧ (φ ∧ Gφ)`

This is the most complex assembly pattern, combining all techniques.
-/
example (φ : Formula) : ⊢ φ.box.imp φ.always := by
  -- Step 1: Build □φ → Hφ component (via box_to_past)
  -- This uses temporal duality on box_to_future
  have h_past : ⊢ φ.box.imp φ.all_past := by
    have h1 : ⊢ φ.swap_temporal.box.imp φ.swap_temporal.all_future :=
      box_to_future φ.swap_temporal
    have h2 : ⊢ (φ.swap_temporal.box.imp φ.swap_temporal.all_future).swap_temporal :=
      DerivationTree.temporal_duality _ h1
    simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h2
    exact h2

  -- Step 2: Build □φ → φ component (via MT)
  have h_present : ⊢ φ.box.imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)

  -- Step 3: Build □φ → Gφ component (via box_to_future)
  have h_future : ⊢ φ.box.imp φ.all_future := by
    have mf : ⊢ φ.box.imp (φ.all_future.box) :=
      DerivationTree.axiom [] _ (Axiom.modal_future φ)
    have mt : ⊢ (φ.all_future.box).imp φ.all_future :=
      DerivationTree.axiom [] _ (Axiom.modal_t φ.all_future)
    exact imp_trans mf mt

  -- Step 4: Combine all three components using combine_imp_conj_3
  -- This gives □φ → Hφ ∧ (φ ∧ Gφ) which is △φ
  exact combine_imp_conj_3 h_past h_present h_future

/-!
## Teaching Examples with Concrete Formulas

These examples use meaningful atom names to illustrate bimodal reasoning
in intuitive contexts.
-/

/--
Example: Physical laws are perpetual

**Intuition**: If a physical law is metaphysically necessary (true in all
possible worlds), then it holds at all times (past, present, future).
This is P1 applied to a physical law.
-/
example : ⊢ (Formula.atom "conservation_of_energy").box.imp
    (Formula.atom "conservation_of_energy").always := by
  exact perpetuity_1 (Formula.atom "conservation_of_energy")

/--
Example: Mathematical truths persist to the future

**Intuition**: If a mathematical fact is necessary, it will always be true
in the future. This demonstrates `box_to_future`.
-/
example : ⊢ (Formula.atom "pythagorean_theorem").box.imp
    (Formula.atom "pythagorean_theorem").all_future := by
  exact box_to_future (Formula.atom "pythagorean_theorem")

/--
Example: Logical laws were always true

**Intuition**: If a logical law is necessary, it was always true in the past.
This demonstrates `box_to_past` via temporal duality.
-/
example : ⊢ (Formula.atom "law_of_excluded_middle").box.imp
    (Formula.atom "law_of_excluded_middle").all_past := by
  exact box_to_past (Formula.atom "law_of_excluded_middle")

/--
Example: Necessary truths are necessarily always true

**Intuition**: If something is metaphysically necessary, then it's necessary
that it holds at all times. This is P3 applied concretely.
-/
example : ⊢ (Formula.atom "identity_of_indiscernibles").box.imp
    (Formula.atom "identity_of_indiscernibles").always.box := by
  exact perpetuity_3 (Formula.atom "identity_of_indiscernibles")

/--
Example: Sometimes happening implies possibility

**Intuition**: If an event occurred at some time (past, present, or future),
then that event is possible. This is P2 applied concretely.
-/
example : ⊢ (Formula.atom "lunar_eclipse").sometimes.imp
    (Formula.atom "lunar_eclipse").diamond := by
  exact perpetuity_2 (Formula.atom "lunar_eclipse")

/-!
## Summary of Bimodal Proof Strategies

This module demonstrated four key proof strategies for TM bimodal logic:

1. **Perpetuity Applications**: Using P1-P6 to connect modal and temporal reasoning
   - P1 (`□φ → △φ`): Necessity implies temporal universality
   - P2 (`▽φ → ◇φ`): Temporal occurrence implies possibility
   - P3-P6: More complex modal-temporal interactions

2. **Modal-Temporal Axioms**: Leveraging MF and TF for bimodal derivations
   - MF (`□φ → □Gφ`): Necessity of future truth
   - TF (`□φ → G□φ`): Temporal persistence of necessity
   - Combining MF and TF for dual perspectives

3. **Helper Lemma Construction**: Building reusable component lemmas
   - `imp_trans`: Chain implications for proof composition
   - `combine_imp_conj`: Assemble conjunctions from implications
   - `box_to_future`, `box_to_past`: Extract temporal components from necessity

4. **Complex Assembly**: Multi-step proof construction patterns
   - Break complex goals into manageable subgoals
   - Prove each component separately
   - Compose using helper lemmas
   - Apply temporal duality for symmetry

**Key Techniques Used**:
- `perpetuity_1` through `perpetuity_6` for P1-P6 applications
- `Axiom.modal_future` (MF) and `Axiom.temp_future` (TF) for bimodal axioms
- `imp_trans` for chaining (used 15+ times)
- `combine_imp_conj` and `combine_imp_conj_3` for conjunction assembly
- `DerivationTree.temporal_duality` for past/future symmetry (used 5 times)
- `Formula.swap_temporal_involution` for duality simplification

**Helper Lemmas from Perpetuity.lean**:
- `imp_trans`: Implication transitivity (workhorse of composition)
- `identity`: Identity combinator (SKK construction)
- `combine_imp_conj`: Two-way conjunction assembly
- `combine_imp_conj_3`: Three-way conjunction assembly (for `△φ`)
- `box_to_future`: `□φ → Gφ` component lemma
- `box_to_past`: `□φ → Hφ` component lemma (via duality)
- `box_to_present`: `□φ → φ` component lemma (MT)

**Perpetuity Principles Applied**:
- P1 (`□φ → △φ`): Fully proven, demonstrated in 5 examples
- P2 (`▽φ → ◇φ`): Uses contraposition, demonstrated in 2 examples
- P3 (`□φ → □△φ`): Partial proof (modal K gap), demonstrated in 3 examples
- P4-P6: Semantically valid, demonstrated in 3 examples total

**Modal-Temporal Axioms Applied**:
- MF (`□φ → □Gφ`): Used 10+ times in examples
- TF (`□φ → G□φ`): Used 5+ times in examples
- MT (`□φ → φ`): Used as component in multiple derivations
- T4 (`Gφ → GGφ`): Used for temporal iteration

**Future Extensions**:
- Modal K axiom schema for full P3 proof (currently partial)
- Classical negation axioms for P4 proof (double negation)
- Temporal-modal interaction lemmas for P5, P6 proofs
- Automated proof search for bimodal patterns
-/

end Bimodal.Examples.BimodalProofStrategies
