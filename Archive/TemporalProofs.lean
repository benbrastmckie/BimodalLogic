import Logos.Core.ProofSystem.Derivation
import Logos.Core.ProofSystem.Axioms

/-!
# Temporal Logic Proof Examples

This module demonstrates linear temporal logic reasoning in the ProofChecker system,
focusing on the temporal operators future (`F`), past (`P`), and their duals.

## Linear Temporal Logic

The TM system includes temporal operators for reasoning about time:
- **G** (all_future): `Gφ` means "φ will always be true" (for all future times)
- **H** (all_past): `Hφ` means "φ was always true" (for all past times)
- **F** (some_future): `Fφ = ¬G¬φ` means "φ will be true at some future time"
- **P** (some_past): `Pφ = ¬H¬φ` means "φ was true at some past time"
- **always** (`△`): `Hφ ∧ φ ∧ Gφ` means "φ at all times" (past, present, future)
- **sometimes** (`▽`): `¬(always ¬φ)` means "φ at some time" (past, present, or future)

## Temporal Axioms

- **T4** (temporal transitivity): `Fφ → FFφ` - future of future is future
- **TA** (temporal connectedness): `φ → F(some_past φ)` - present accessible from future's past
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

- `φ.all_future` = `Gφ` (for all future times)
- `φ.all_past` = `Hφ` (for all past times)
- `φ.some_future` = `Fφ = ¬G¬φ` (at some future time)
- `φ.some_past` = `Pφ = ¬H¬φ` (at some past time)
- `φ.always` = `Hφ ∧ φ ∧ Gφ` (at all times: past, present, future)
- `φ.sometimes` = `¬(always ¬φ)` (at some time: past, present, or future)
- `△φ` = always φ (at all times)
- `▽φ` = sometimes φ (at some time)

## References

* [Axioms.lean](../ProofChecker/ProofSystem/Axioms.lean) - Temporal axiom definitions
* [Derivation.lean](../ProofChecker/ProofSystem/Derivation.lean) - Temporal K and duality rules
* [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Archive.TemporalProofs

open Logos.Core.Syntax
open Logos.Core.ProofSystem

/-!
## Axiom T4: Temporal Transitivity (`Fφ → FFφ`)

If something will always be true, then it will always be true that it will always be true.
This expresses that the temporal relation is transitive.
-/

/-- Temporal 4 on atomic formula -/
example : ⊢ (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "p"))

/-- Temporal 4 on implication -/
example (p q : Formula) : ⊢ (p.imp q).all_future.imp (p.imp q).all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 (p.imp q))

/-- Temporal 4 with nested future: `FFFφ` follows from `FFφ` -/
example (φ : Formula) : ⊢ φ.all_future.all_future.imp φ.all_future.all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 φ.all_future)

/-- Temporal 4 demonstrates temporal transitivity -/
example : ⊢ (Formula.atom "always_true").all_future.imp (Formula.atom "always_true").all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "always_true"))

/-- Temporal 4: G(Gφ) follows from Gφ -/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 φ)

/-!
## Axiom TA: Temporal Connectedness (`φ → F(some_past φ)`)

If something is true now, then at all future times there exists a past time where it was true.
This connects the present with the accessible past of all futures.
-/

/-- Temporal A on atomic formula -/
example : ⊢ (Formula.atom "p").imp (Formula.atom "p").some_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_a (Formula.atom "p"))

/-- Temporal A on negation -/
example (φ : Formula) : ⊢ φ.neg.imp φ.neg.some_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_a φ.neg)

/-- Temporal A on complex formula -/
example (p q : Formula) : ⊢ (p.and q).imp (p.and q).some_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_a (p.and q))

/-- Temporal A demonstrates present is in past of all futures -/
example : ⊢ (Formula.atom "now").imp (Formula.atom "now").some_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_a (Formula.atom "now"))

/-!
## Axiom TL: Temporal Perpetuity (`△φ → G(Hφ)`)

If something is true at all times (always), then at all future times
it was always true in the past.

This is a strong axiom that connects temporal perpetuity across past and future.
Note: TL uses `always` (△ = H ∧ present ∧ G), not just `all_future` (G).
-/

/-- Temporal L on atomic formula: △p → G(Hp) -/
example : ⊢ (Formula.atom "p").always.imp (Formula.atom "p").all_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_l (Formula.atom "p"))

/-- Temporal L: always φ → G(Hφ) -/
example (φ : Formula) : ⊢ φ.always.imp φ.all_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_l φ)

/-- Temporal L on complex formula: △(p ∨ q) → G(H(p ∨ q)) -/
example (p q : Formula) : ⊢ (p.or q).always.imp (p.or q).all_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_l (p.or q))

/-- Temporal L demonstrates perpetuity preservation -/
example : ⊢ (Formula.atom "eternal").always.imp (Formula.atom "eternal").all_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_l (Formula.atom "eternal"))

/-!
## Temporal Duality Rule

The temporal duality rule swaps past and future operators in theorems.
If `⊢ φ` (φ is a theorem), then `⊢ swap_temporal φ` is also a theorem.
-/

/-- Temporal duality example: T4 for future implies T4-like for past (via duality) -/
example : ⊢ (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future := by
  exact Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "p"))

/-- Using temporal duality on a theorem -/
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.swap_temporal :=
  Derivable.temporal_duality φ h

/-- Duality preserves theoremhood -/
example : ⊢ (Formula.atom "p").all_future.imp (Formula.atom "p").all_future := by
  -- Trivial future formula (by weakening or axioms)
  -- Demonstrates pattern for duality application
  sorry

/-!
## Temporal K Rule

The temporal K rule distributes `F` over derivations:
If `FΓ ⊢ φ` then `Γ ⊢ Fφ`.
-/

/-- Using temporal K rule: if `GΓ ⊢ φ` then `Γ ⊢ Gφ` -/
example (p : Formula) : [p] ⊢ p.all_future := by
  -- The temporal K rule has specific requirements about the context
  -- This is a simplified example that would need proper setup
  sorry  -- Would require temporal axioms for proper derivation

/-!
## Future Operator (G) Examples

The all_future operator `G` expresses truth at all future times.
Note: `G` (all_future) is different from `always` (`△` = H ∧ present ∧ G).
-/

/-- Future on atomic formula -/
example (p : Formula) : [p] ⊢ p.all_future := by
  -- Would use temporal K rule to lift p to Fp
  sorry

/-- Always (at all times) = H ∧ present ∧ G -/
example (φ : Formula) : φ.always = φ.all_past.and (φ.and φ.all_future) := rfl

/-- Triangle notation for always -/
example (φ : Formula) : (△φ) = φ.always := rfl

/-- Sometimes operator (dual of always): defined via negation of always -/
example (φ : Formula) : φ.sometimes = φ.neg.always.neg := rfl

/-- Triangle notation for sometimes -/
example (φ : Formula) : (▽φ) = φ.sometimes := rfl

/-!
## Past Operator (P) Examples

The past operator `P` expresses truths that have always been.
-/

/-- Past on atomic formula (using in context) -/
example : [(Formula.atom "p").all_past] ⊢ (Formula.atom "p").all_past :=
  Derivable.assumption _ _ (by simp)

/-- Some past: `¬P¬φ` means φ was true at some past time -/
example (φ : Formula) : φ.some_past = φ.neg.all_past.neg := rfl

/-- Past and future interact via temporal axioms: △φ → G(Hφ) -/
example (φ : Formula) : ⊢ φ.always.imp φ.all_past.all_future :=
  -- This is the TL axiom: always φ → G(Hφ)
  Derivable.axiom [] _ (Axiom.temp_l φ)

/-!
## Multi-Step Temporal Reasoning

Combining temporal axioms for complex derivations.
-/

/-- Chaining temporal operators: `FFFφ` via T4 -/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future.all_future := by
  -- F φ → FF φ by T4
  have h1 := Derivable.axiom [] _ (Axiom.temp_4 φ)
  -- FF φ → FFF φ by T4 applied to F φ
  have h2 := Derivable.axiom [] _ (Axiom.temp_4 φ.all_future)
  -- Would need imp_trans to compose these
  sorry

/-- Temporal iteration: applying T4 repeatedly -/
example : ⊢ (Formula.atom "perpetual").all_future.imp (Formula.atom "perpetual").all_future.all_future := by
  exact Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "perpetual"))

/-!
## Temporal Properties

Examples demonstrating key temporal properties.
-/

/-- Idempotence pattern: `FFφ` is related to `Fφ` via T4 -/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 φ)

/-- Present to future-past: TA axiom pattern -/
example (φ : Formula) : ⊢ φ.imp φ.some_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_a φ)

/-- Perpetuity preservation: TL axiom pattern △φ → G(Hφ) -/
example (φ : Formula) : ⊢ φ.always.imp φ.all_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_l φ)

/-!
## Modal-Temporal Interaction Axioms

These axioms connect modal and temporal operators.
-/

/-- Modal-Future axiom MF: `□φ → □Fφ` -/
example (φ : Formula) : ⊢ φ.box.imp φ.all_future.box :=
  Derivable.axiom [] _ (Axiom.modal_future φ)

/-- Temporal-Future axiom TF: `□φ → F□φ` -/
example (φ : Formula) : ⊢ φ.box.imp φ.box.all_future :=
  Derivable.axiom [] _ (Axiom.temp_future φ)

/-- MF demonstrates necessity persists into future -/
example : ⊢ (Formula.atom "necessary").box.imp (Formula.atom "necessary").all_future.box :=
  Derivable.axiom [] _ (Axiom.modal_future (Formula.atom "necessary"))

/-- TF demonstrates necessary truths are perpetual -/
example : ⊢ (Formula.atom "necessary").box.imp (Formula.atom "necessary").box.all_future :=
  Derivable.axiom [] _ (Axiom.temp_future (Formula.atom "necessary"))

/-!
## Teaching Examples

Clear examples for learning temporal logic concepts.
-/

/-- Example: What will always be true remains always true -/
example : ⊢ (Formula.atom "sun_rises").all_future.imp (Formula.atom "sun_rises").all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "sun_rises"))

/-- Example: Present events are in the past of all futures -/
example : ⊢ (Formula.atom "today").imp (Formula.atom "today").some_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_a (Formula.atom "today"))

/-- Example: Eternal truths (TL axiom): △"2+2=4" → G(H"2+2=4") -/
example : ⊢ (Formula.atom "2+2=4").always.imp (Formula.atom "2+2=4").all_past.all_future :=
  Derivable.axiom [] _ (Axiom.temp_l (Formula.atom "2+2=4"))

/-- Example: Future transitivity (T4 axiom): G"inevitable" → GG"inevitable" -/
example : ⊢ (Formula.atom "inevitable").all_future.imp (Formula.atom "inevitable").all_future.all_future :=
  Derivable.axiom [] _ (Axiom.temp_4 (Formula.atom "inevitable"))

/-- Example: Sometimes notation (eventuality) -/
example (φ : Formula) : φ.sometimes = (▽φ) := rfl

/-- Example: Always notation (perpetuity) -/
example (φ : Formula) : φ.always = (△φ) := rfl

end Archive.TemporalProofs
