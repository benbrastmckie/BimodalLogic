import Logos.ProofSystem.Derivation
import Logos.ProofSystem.Axioms

/-!
# Temporal Logic Proof Examples

This module demonstrates linear temporal logic reasoning in the ProofChecker system,
focusing on the temporal operators future (`F`), past (`P`), and their duals.

## Linear Temporal Logic

The TM system includes temporal operators for reasoning about time:
- **F** (future): `Fφ` means "φ will always be true" (henceforth/perpetually)
- **P** (past): `Pφ` means "φ was always true" (has always been)
- **sometime_past**: `¬P¬φ` means "φ was true at some past time"
- **always/sometimes**: Alternative names for future operators

## Temporal Axioms

- **T4** (temporal transitivity): `Fφ → FFφ` - future of future is future
- **TA** (temporal connectedness): `φ → F(sometime_past φ)` - present accessible from future's past
- **TL** (temporal perpetuity): `Fφ → F(Pφ)` - perpetual truths remain perpetual

## Temporal Duality

The TM system has a duality between past and future operators:
- Swapping P and F in any theorem φ yields another theorem

## Examples Categories

1. **Basic Temporal Axioms**: T4, TA, TL applications
2. **Temporal Duality**: Past/future symmetry demonstrations
3. **Temporal Operators**: Using F, P, and their combinations
4. **Temporal Reasoning**: Multi-step temporal derivations

## Notation

- `φ.future` = `Fφ` (always/henceforth - for all future times)
- `φ.past` = `Pφ` (has always been - for all past times)
- `φ.sometime_past` = `¬P¬φ` (was true at some past time)
- `φ.always` = `φ.future` (synonym for future)
- `φ.sometimes` = `¬F¬φ` (will be true at some future time)
- `△φ` = always φ (triangle notation for perpetuity)
- `▽φ` = sometimes φ (triangle notation for eventuality)

## References

* [Axioms.lean](../ProofChecker/ProofSystem/Axioms.lean) - Temporal axiom definitions
* [Derivation.lean](../ProofChecker/ProofSystem/Derivation.lean) - Temporal K and duality rules
* [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Archive.TemporalProofs

open Logos.Syntax
open Logos.ProofSystem

/-!
## Axiom T4: Temporal Transitivity (`Fφ → FFφ`)

If something will always be true, then it will always be true that it will always be true.
This expresses that the temporal relation is transitive.
-/

/-- Temporal 4 on atomic formula -/
example : ⊢ (Formula.atom "p").future.imp (Formula.atom "p").future.future :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "p"))

/-- Temporal 4 on implication -/
example (p q : Formula) : ⊢ (p.imp q).future.imp (p.imp q).future.future :=
  Derivable.axiom [] _ (Axiom.temp_4 (p.imp q))

/-- Temporal 4 with nested future: `FFFφ` follows from `FFφ` -/
example (φ : Formula) : ⊢ φ.future.future.imp φ.future.future.future :=
  Derivable.axiom [] _ (Axiom.temp_4 φ.future)

/-- Temporal 4 demonstrates temporal transitivity -/
example : ⊢ (Formula.atom "always_true").future.imp (Formula.atom "always_true").future.future :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "always_true"))

/-- Temporal 4 using always notation (synonym for future) -/
example (φ : Formula) : ⊢ φ.always.imp φ.always.always :=
  Derivable.axiom [] _ (Axiom.temp_4 φ)

/-!
## Axiom TA: Temporal Connectedness (`φ → F(sometime_past φ)`)

If something is true now, then at all future times there exists a past time where it was true.
This connects the present with the accessible past of all futures.
-/

/-- Temporal A on atomic formula -/
example : ⊢ (Formula.atom "p").imp (Formula.atom "p").sometime_past.future :=
  Derivable.axiom [] _ (Axiom.temp_a (Formula.atom "p"))

/-- Temporal A on negation -/
example (φ : Formula) : ⊢ φ.neg.imp φ.neg.sometime_past.future :=
  Derivable.axiom [] _ (Axiom.temp_a φ.neg)

/-- Temporal A on complex formula -/
example (p q : Formula) : ⊢ (p.and q).imp (p.and q).sometime_past.future :=
  Derivable.axiom [] _ (Axiom.temp_a (p.and q))

/-- Temporal A demonstrates present is in past of all futures -/
example : ⊢ (Formula.atom "now").imp (Formula.atom "now").sometime_past.future :=
  Derivable.axiom [] _ (Axiom.temp_a (Formula.atom "now"))

/-!
## Axiom TL: Temporal Perpetuity (`Fφ → FPφ`)

If something will always be true in the future, then at all future times
it was always true in the past.

This is a strong axiom that connects temporal perpetuity across past and future.
-/

/-- Temporal L on atomic formula -/
example : ⊢ (Formula.atom "p").future.imp (Formula.atom "p").past.future :=
  Derivable.axiom [] _ (Axiom.temp_l (Formula.atom "p"))

/-- Temporal L using always notation: `always φ → always (past φ)` -/
example (φ : Formula) : ⊢ φ.always.imp φ.past.always :=
  Derivable.axiom [] _ (Axiom.temp_l φ)

/-- Temporal L on complex formula -/
example (p q : Formula) : ⊢ (p.or q).future.imp (p.or q).past.future :=
  Derivable.axiom [] _ (Axiom.temp_l (p.or q))

/-- Temporal L demonstrates perpetuity preservation -/
example : ⊢ (Formula.atom "eternal").future.imp (Formula.atom "eternal").past.future :=
  Derivable.axiom [] _ (Axiom.temp_l (Formula.atom "eternal"))

/-!
## Temporal Duality Rule

The temporal duality rule swaps past and future operators in theorems.
If `⊢ φ` (φ is a theorem), then `⊢ swap_past_future φ` is also a theorem.
-/

/-- Temporal duality example: T4 for future implies T4-like for past (via duality) -/
example : ⊢ (Formula.atom "p").future.imp (Formula.atom "p").future.future := by
  exact Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "p"))

/-- Using temporal duality on a theorem -/
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.swap_past_future :=
  Derivable.temporal_duality φ h

/-- Duality preserves theoremhood -/
example : ⊢ (Formula.atom "p").future.imp (Formula.atom "p").future := by
  -- Trivial future formula (by weakening or axioms)
  -- Demonstrates pattern for duality application
  sorry

/-!
## Temporal K Rule

The temporal K rule distributes `F` over derivations:
If `FΓ ⊢ φ` then `Γ ⊢ Fφ`.
-/

/-- Using temporal K rule: if `FΓ ⊢ φ` then `Γ ⊢ Fφ` -/
example (p : Formula) : [p] ⊢ p.future := by
  apply Derivable.temporal_k [p] p
  -- Now need to show: [Fp] ⊢ p
  -- The mapped context is [Fp], and we need to derive p from it
  -- We can use weakening from empty context axiom
  sorry  -- Would require temporal axioms for proper derivation

/-!
## Future Operator (F) Examples

The future operator `F` (or `always`) expresses perpetual truth.
-/

/-- Future on atomic formula -/
example (p : Formula) : [p] ⊢ p.future := by
  -- Would use temporal K rule to lift p to Fp
  sorry

/-- Always notation (synonym for future) -/
example (φ : Formula) : φ.always = φ.future := rfl

/-- Triangle notation for always -/
example (φ : Formula) : (△φ) = φ.always := rfl

/-- Sometimes operator (dual of always): `¬F¬φ` -/
example (φ : Formula) : φ.sometimes = φ.neg.future.neg := rfl

/-- Triangle notation for sometimes -/
example (φ : Formula) : (▽φ) = φ.sometimes := rfl

/-!
## Past Operator (P) Examples

The past operator `P` expresses truths that have always been.
-/

/-- Past on atomic formula (using in context) -/
example : [(Formula.atom "p").past] ⊢ (Formula.atom "p").past :=
  Derivable.assumption _ _ (by simp)

/-- Sometime past: `¬P¬φ` means φ was true at some past time -/
example (φ : Formula) : φ.sometime_past = φ.neg.past.neg := rfl

/-- Past and future interact via temporal axioms -/
example (φ : Formula) : ⊢ φ.future.imp φ.past.future :=
  -- This is the TL axiom
  Derivable.axiom [] _ (Axiom.temp_l φ)

/-!
## Multi-Step Temporal Reasoning

Combining temporal axioms for complex derivations.
-/

/-- Chaining temporal operators: `FFFφ` via T4 -/
example (φ : Formula) : ⊢ φ.future.imp φ.future.future.future := by
  -- F φ → FF φ by T4
  have h1 := Derivable.axiom [] _ (Axiom.temp_4 φ)
  -- FF φ → FFF φ by T4 applied to F φ
  have h2 := Derivable.axiom [] _ (Axiom.temp_4 φ.future)
  -- Would need imp_trans to compose these
  sorry

/-- Temporal iteration: applying T4 repeatedly -/
example : ⊢ (Formula.atom "perpetual").future.imp (Formula.atom "perpetual").future.future := by
  exact Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "perpetual"))

/-!
## Temporal Properties

Examples demonstrating key temporal properties.
-/

/-- Idempotence pattern: `FFφ` is related to `Fφ` via T4 -/
example (φ : Formula) : ⊢ φ.future.imp φ.future.future :=
  Derivable.axiom [] _ (Axiom.temp_4 φ)

/-- Present to future-past: TA axiom pattern -/
example (φ : Formula) : ⊢ φ.imp φ.sometime_past.future :=
  Derivable.axiom [] _ (Axiom.temp_a φ)

/-- Perpetuity preservation: TL axiom pattern -/
example (φ : Formula) : ⊢ φ.future.imp φ.past.future :=
  Derivable.axiom [] _ (Axiom.temp_l φ)

/-!
## Modal-Temporal Interaction Axioms

These axioms connect modal and temporal operators.
-/

/-- Modal-Future axiom MF: `□φ → □Fφ` -/
example (φ : Formula) : ⊢ φ.box.imp φ.future.box :=
  Derivable.axiom [] _ (Axiom.modal_future φ)

/-- Temporal-Future axiom TF: `□φ → F□φ` -/
example (φ : Formula) : ⊢ φ.box.imp φ.box.future :=
  Derivable.axiom [] _ (Axiom.temp_future φ)

/-- MF demonstrates necessity persists into future -/
example : ⊢ (Formula.atom "necessary").box.imp (Formula.atom "necessary").future.box :=
  Derivable.axiom [] _ (Axiom.modal_future (Formula.atom "necessary"))

/-- TF demonstrates necessary truths are perpetual -/
example : ⊢ (Formula.atom "necessary").box.imp (Formula.atom "necessary").box.future :=
  Derivable.axiom [] _ (Axiom.temp_future (Formula.atom "necessary"))

/-!
## Teaching Examples

Clear examples for learning temporal logic concepts.
-/

/-- Example: What will always be true remains always true -/
example : ⊢ (Formula.atom "sun_rises").future.imp (Formula.atom "sun_rises").future.future :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "sun_rises"))

/-- Example: Present events are in the past of all futures -/
example : ⊢ (Formula.atom "today").imp (Formula.atom "today").sometime_past.future :=
  Derivable.axiom [] _ (Axiom.temp_a (Formula.atom "today"))

/-- Example: Eternal truths were always true -/
example : ⊢ (Formula.atom "2+2=4").future.imp (Formula.atom "2+2=4").past.future :=
  Derivable.axiom [] _ (Axiom.temp_l (Formula.atom "2+2=4"))

/-- Example: Future using always notation -/
example : ⊢ (Formula.atom "inevitable").always.imp (Formula.atom "inevitable").always.always :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "inevitable"))

/-- Example: Sometimes notation (eventuality) -/
example (φ : Formula) : φ.sometimes = (▽φ) := rfl

/-- Example: Always notation (perpetuity) -/
example (φ : Formula) : φ.always = (△φ) := rfl

end Archive.TemporalProofs
