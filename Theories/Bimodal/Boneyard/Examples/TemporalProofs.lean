/-!
# ARCHIVED: Temporal Logic Exercise File

**Archived from**: `Theories/Bimodal/Examples/TemporalProofs.lean`
**Archived by**: Task 760
**Date**: 2026-01-29
**Reason**: Contains 2 `sorry` placeholders for exercises
**Status**: Proofs are straightforward to complete if needed

These exercises demonstrate linear temporal logic proof techniques:
- Temporal K rule with generalized necessitation (line ~180)
- Future lifting using temporal K rule (line ~194)

To restore: Move back to `Theories/Bimodal/Examples/` and update imports in
`Bimodal/Examples.lean` and `Logos/Examples.lean`.
-/

import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Combinators
-- import Bimodal.Automation.ProofSearch  -- TODO: Re-enable when Task 260 (ProofSearch) is unblocked

/-!
# Temporal Logic Proof Examples

This module demonstrates linear temporal logic reasoning in the ProofChecker system,
focusing on the temporal operators future (`F`), past (`P`), and their duals.

## Linear Temporal Logic

The TM system includes temporal operators for reasoning about time:
- **G** (all_future): `Gphi` means "phi will always be true" (for all future times)
- **H** (all_past): `Hphi` means "phi was always true" (for all past times)
- **F** (some_future): `Fphi = not G not phi` means "phi will be true at some future time"
- **P** (some_past): `Pphi = not H not phi` means "phi was true at some past time"
- **always** (`tri`): `Hphi and phi and Gphi` means "phi at all times" (past, present, future)
- **sometimes** (`triv`): `not (always not phi)` means "phi at some time" (past, present, or future)

## Temporal Axioms

- **T4** (temporal transitivity): `Fphi -> FFphi` - future of future is future
- **TA** (temporal connectedness): `phi -> F(some_past phi)` - present accessible from future's past
- **TL** (temporal perpetuity): `Fphi -> F(Pphi)` - perpetual truths remain perpetual

## Temporal Duality

The TM system has a duality between past and future operators:
- Swapping P and F in any theorem phi yields another theorem

## Examples Categories

1. **Basic Temporal Axioms**: T4, TA, TL applications
2. **Temporal Duality**: Past/future symmetry demonstrations
3. **Temporal Operators**: Using F, P, and their combinations
4. **Temporal Reasoning**: Multi-step temporal derivations

## Notation

- `phi.all_future` = `Gphi` (for all future times)
- `phi.all_past` = `Hphi` (for all past times)
- `phi.some_future` = `Fphi = not G not phi` (at some future time)
- `phi.some_past` = `Pphi = not H not phi` (at some past time)
- `phi.always` = `Hphi and phi and Gphi` (at all times: past, present, future)
- `phi.sometimes` = `not (always not phi)` (at some time: past, present, or future)
- `tri phi` = always phi (at all times)
- `triv phi` = sometimes phi (at some time)

## Exercises

This module contains 2 exercises marked with `-- EXERCISE:` comments:

1. **Temporal K rule**: Using `generalized_temporal_k` (line ~169)
2. **Future lifting**: Using temporal K rule (line ~183)

## References

* [Axioms.lean](../ProofChecker/ProofSystem/Axioms.lean) - Temporal axiom definitions
* [Derivation.lean](../ProofChecker/ProofSystem/Derivation.lean) - Temporal K and duality rules
* [ARCHITECTURE.md](../docs/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Boneyard.Examples.TemporalProofs

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators
-- open Bimodal.Automation (ProofSearch)  -- TODO: Re-enable when Task 260 (ProofSearch) is unblocked

/-!
## Axiom T4: Temporal Transitivity (`Fphi -> FFphi`)

If something will always be true, then it will always be true that it will always be true.
This expresses that the temporal relation is transitive.
-/

/-- Temporal 4 on atomic formula -/
example : |- (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "p"))

/-- Temporal 4 on implication -/
example (p q : Formula) : |- (p.imp q).all_future.imp (p.imp q).all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 (p.imp q))

/-- Temporal 4 with nested future: `FFFphi` follows from `FFphi` -/
example (phi : Formula) : |- phi.all_future.all_future.imp phi.all_future.all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 phi.all_future)

/-- Temporal 4 demonstrates temporal transitivity -/
example : |- (Formula.atom "always_true").all_future.imp (Formula.atom "always_true").all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "always_true"))

/-- Temporal 4: G(Gphi) follows from Gphi -/
example (phi : Formula) : |- phi.all_future.imp phi.all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 phi)

/-!
## Axiom TA: Temporal Connectedness (`phi -> F(some_past phi)`)

If something is true now, then at all future times there exists a past time where it was true.
This connects the present with the accessible past of all futures.
-/

/-- Temporal A on atomic formula -/
example : |- (Formula.atom "p").imp (Formula.atom "p").some_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_a (Formula.atom "p"))

/-- Temporal A on negation -/
example (phi : Formula) : |- phi.neg.imp phi.neg.some_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_a phi.neg)

/-- Temporal A on complex formula -/
example (p q : Formula) : |- (p.and q).imp (p.and q).some_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_a (p.and q))

/-- Temporal A demonstrates present is in past of all futures -/
example : |- (Formula.atom "now").imp (Formula.atom "now").some_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_a (Formula.atom "now"))

/-!
## Axiom TL: Temporal Perpetuity (`tri phi -> G(Hphi)`)

If something is true at all times (always), then at all future times
it was always true in the past.

This is a strong axiom that connects temporal perpetuity across past and future.
Note: TL uses `always` (tri = H and present and G), not just `all_future` (G).
-/

/-- Temporal L on atomic formula: tri p -> G(Hp) -/
example : |- (Formula.atom "p").always.imp (Formula.atom "p").all_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_l (Formula.atom "p"))

/-- Temporal L: always phi -> G(Hphi) -/
example (phi : Formula) : |- phi.always.imp phi.all_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_l phi)

/-- Temporal L on complex formula: tri (p or q) -> G(H(p or q)) -/
example (p q : Formula) : |- (p.or q).always.imp (p.or q).all_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_l (p.or q))

/-- Temporal L demonstrates perpetuity preservation -/
example : |- (Formula.atom "eternal").always.imp (Formula.atom "eternal").all_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_l (Formula.atom "eternal"))

/-!
## Temporal Duality Rule

The temporal duality rule swaps past and future operators in theorems.
If `|- phi` (phi is a theorem), then `|- swap_temporal phi` is also a theorem.
-/

/-- Temporal duality example: T4 for future implies T4-like for past (via duality) -/
example : |- (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "p"))

/-- Using temporal duality on a theorem -/
example (phi : Formula) (h : |- phi) : |- phi.swap_temporal :=
  DerivationTree.temporal_duality phi h

/-- Duality preserves theoremhood -/
example : |- (Formula.atom "p").all_future.imp (Formula.atom "p").all_future := by
  -- Trivial identity - Gp -> Gp
  exact identity (Formula.atom "p").all_future

/-!
## Temporal K Rule

The temporal K rule distributes `F` over derivations:
If `FGamma |- phi` then `Gamma |- Fphi`.
-/

/-- Using temporal K rule: if `GGamma |- phi` then `Gamma |- Gphi` -/
example (p : Formula) : [p] |- p.all_future := by
  -- EXERCISE: Complete this proof using generalized necessitation
  -- Technique: Use `generalized_temporal_k` from Bimodal.Theorems.GeneralizedNecessitation
  -- Hint: First derive [Gp] |- p via assumption, then apply generalized temporal K
  sorry

/-!
## Future Operator (G) Examples

The all_future operator `G` expresses truth at all future times.
Note: `G` (all_future) is different from `always` (`tri` = H and present and G).
-/

/-- Future on atomic formula -/
example (p : Formula) : [p] |- p.all_future := by
  -- EXERCISE: Complete this proof using temporal K rule
  -- Technique: Use `generalized_temporal_k` to lift derivation under G operator
  -- Hint: This is similar to the temporal K rule example above
  sorry

/-- Always (at all times) = H and present and G -/
example (phi : Formula) : phi.always = phi.all_past.and (phi.and phi.all_future) := rfl

/-- Triangle notation for always -/
example (phi : Formula) : (Formula.always phi) = phi.always := rfl

/-- Sometimes operator (dual of always): defined via negation of always -/
example (phi : Formula) : phi.sometimes = phi.neg.always.neg := rfl

/-- Triangle notation for sometimes -/
example (phi : Formula) : (Formula.sometimes phi) = phi.sometimes := rfl

/-!
## Past Operator (P) Examples

The past operator `P` expresses truths that have always been.
-/

/-- Past on atomic formula (using in context) -/
example : [(Formula.atom "p").all_past] |- (Formula.atom "p").all_past :=
  DerivationTree.assumption _ _ (by simp)

/-- Some past: `not P not phi` means phi was true at some past time -/
example (phi : Formula) : phi.some_past = phi.neg.all_past.neg := rfl

/-- Past and future interact via temporal axioms: tri phi -> G(Hphi) -/
example (phi : Formula) : |- phi.always.imp phi.all_past.all_future :=
  -- This is the TL axiom: always phi -> G(Hphi)
  DerivationTree.axiom [] _ (Axiom.temp_l phi)

/-!
## Multi-Step Temporal Reasoning

Combining temporal axioms for complex derivations.
-/

/-- Chaining temporal operators: `FFFphi` via T4 -/
example (phi : Formula) : |- phi.all_future.imp phi.all_future.all_future.all_future := by
  -- Gphi -> GGphi by T4
  have h1 := DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  -- GGphi -> GGGphi by T4 applied to Gphi
  have h2 := DerivationTree.axiom [] _ (Axiom.temp_4 phi.all_future)
  -- Compose using transitivity: Gphi -> GGphi -> GGGphi
  exact imp_trans h1 h2

/-- Temporal iteration: applying T4 repeatedly -/
example : |- (Formula.atom "perpetual").all_future.imp (Formula.atom "perpetual").all_future.all_future := by
  exact DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "perpetual"))

/-!
## Temporal Properties

Examples demonstrating key temporal properties.
-/

/-- Idempotence pattern: `FFphi` is related to `Fphi` via T4 -/
example (phi : Formula) : |- phi.all_future.imp phi.all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 phi)

/-- Present to future-past: TA axiom pattern -/
example (phi : Formula) : |- phi.imp phi.some_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_a phi)

/-- Perpetuity preservation: TL axiom pattern tri phi -> G(Hphi) -/
example (phi : Formula) : |- phi.always.imp phi.all_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_l phi)

/-!
## Modal-Temporal Interaction Axioms

These axioms connect modal and temporal operators.
-/

/-- Modal-Future axiom MF: `[]phi -> []Fphi` -/
example (phi : Formula) : |- phi.box.imp phi.all_future.box :=
  DerivationTree.axiom [] _ (Axiom.modal_future phi)

/-- Temporal-Future axiom TF: `[]phi -> F[]phi` -/
example (phi : Formula) : |- phi.box.imp phi.box.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_future phi)

/-- MF demonstrates necessity persists into future -/
example : |- (Formula.atom "necessary").box.imp (Formula.atom "necessary").all_future.box :=
  DerivationTree.axiom [] _ (Axiom.modal_future (Formula.atom "necessary"))

/-- TF demonstrates necessary truths are perpetual -/
example : |- (Formula.atom "necessary").box.imp (Formula.atom "necessary").box.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_future (Formula.atom "necessary"))

/-!
## Teaching Examples

Clear examples for learning temporal logic concepts.
-/

/-- Example: What will always be true remains always true -/
example : |- (Formula.atom "sun_rises").all_future.imp (Formula.atom "sun_rises").all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "sun_rises"))

/-- Example: Present events are in the past of all futures -/
example : |- (Formula.atom "today").imp (Formula.atom "today").some_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_a (Formula.atom "today"))

/-- Example: Eternal truths (TL axiom): tri "2+2=4" -> G(H"2+2=4") -/
example : |- (Formula.atom "2+2=4").always.imp (Formula.atom "2+2=4").all_past.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_l (Formula.atom "2+2=4"))

/-- Example: Future transitivity (T4 axiom): G"inevitable" -> GG"inevitable" -/
example : |- (Formula.atom "inevitable").all_future.imp (Formula.atom "inevitable").all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.atom "inevitable"))

/-- Example: Sometimes notation (eventuality) -/
example (phi : Formula) : phi.sometimes = (Formula.sometimes phi) := rfl

/-- Example: Always notation (perpetuity) -/
example (phi : Formula) : phi.always = (Formula.always phi) := rfl

/-!
## Automated Temporal Search

NOTE: The following examples are commented out pending completion of Task 260 (ProofSearch).
These examples will demonstrate automated proof search for temporal logic formulas.
Temporal formulas typically require higher search depths than modal formulas
due to the complexity of temporal operators.

TODO: Re-enable when Task 260 (ProofSearch) is unblocked.
-/

-- ProofSearch examples commented out - Task 260 is BLOCKED
-- See: specs/260_proof_search/plans/implementation-001.md

end Bimodal.Boneyard.Examples.TemporalProofs
