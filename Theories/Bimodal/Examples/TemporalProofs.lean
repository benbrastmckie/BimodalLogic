import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Combinators
import Bimodal.Automation

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

## Temporal Axioms (BX System)

Under the BX refactor, the old discrete axiom set (T4, TA, TL) has been replaced by:
- **BX1/BX1'**: Reflexivity of G/H (temp_t_future/past)
- **BX2-BX7**: Until/Since axioms for linear temporal orders

Many of the examples below that previously used T4, TA, TL directly are now sorry'd
pending derivation from the BX axiom system.

## References

* [Axioms.lean](../ProofChecker/ProofSystem/Axioms.lean) - Temporal axiom definitions
* [Derivation.lean](../ProofChecker/ProofSystem/Derivation.lean) - Temporal K and duality rules
* [ARCHITECTURE.md](../docs/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Examples.TemporalProofs

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators
open Bimodal.Automation

/-!
## BX1: Temporal Reflexivity (`G(φ) → φ` and `H(φ) → φ`)

Under reflexive semantics, what holds at all future-or-present times holds now.
-/

/-- BX1: Temporal T (future) on atomic formula -/
example : ⊢ (Formula.atom_s "p").all_future.imp (Formula.atom_s "p") :=
  DerivationTree.axiom [] _ (Axiom.temp_t_future (Formula.atom_s "p"))

/-- BX1': Temporal T (past) on atomic formula -/
example : ⊢ (Formula.atom_s "p").all_past.imp (Formula.atom_s "p") :=
  DerivationTree.axiom [] _ (Axiom.temp_t_past (Formula.atom_s "p"))

/-!
## Temporal 4 (`Gφ → GGφ`) — Derived from BX1

Under BX with reflexive G, temp_4 should be derivable. These are sorry'd pending
that derivation.
-/

/-- Temporal 4 on atomic formula (sorry'd - derive from BX1) -/
example : ⊢ (Formula.atom_s "p").all_future.imp (Formula.atom_s "p").all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-- Temporal 4 on implication (sorry'd - derive from BX1) -/
example (p q : Formula) : ⊢ (p.imp q).all_future.imp (p.imp q).all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-- Temporal 4 with nested future -/
example (φ : Formula) : ⊢ φ.all_future.all_future.imp φ.all_future.all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-- Temporal 4 demonstrates temporal transitivity -/
example : ⊢ (Formula.atom_s "always_true").all_future.imp (Formula.atom_s "always_true").all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-- Temporal 4: G(Gφ) follows from Gφ -/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-!
## Axiom TA: Temporal Connectedness (`φ → G(Pφ)`)

Under BX, this should be derivable from BX4 (connectedness).
-/

/-- Temporal A on atomic formula (sorry'd - derive from BX4) -/
example : ⊢ (Formula.atom_s "p").imp (Formula.atom_s "p").some_past.all_future :=
  sorry /- BX: derive temp_a from BX4 -/

/-- Temporal A on negation -/
example (φ : Formula) : ⊢ φ.neg.imp φ.neg.some_past.all_future :=
  sorry /- BX: derive temp_a from BX4 -/

/-- Temporal A on complex formula -/
example (p q : Formula) : ⊢ (p.and q).imp (p.and q).some_past.all_future :=
  sorry /- BX: derive temp_a from BX4 -/

/-- Temporal A demonstrates present is in past of all futures -/
example : ⊢ (Formula.atom_s "now").imp (Formula.atom_s "now").some_past.all_future :=
  sorry /- BX: derive temp_a from BX4 -/

/-!
## Axiom TL: Temporal Perpetuity (`△φ → G(Hφ)`)

Under BX, this must be derived from BX axioms.
-/

/-- Temporal L on atomic formula: △p → G(Hp) -/
example : ⊢ (Formula.atom_s "p").always.imp (Formula.atom_s "p").all_past.all_future :=
  sorry /- BX: derive temp_l from BX axioms -/

/-- Temporal L: always φ → G(Hφ) -/
example (φ : Formula) : ⊢ φ.always.imp φ.all_past.all_future :=
  sorry /- BX: derive temp_l from BX axioms -/

/-- Temporal L on complex formula: △(p ∨ q) → G(H(p ∨ q)) -/
example (p q : Formula) : ⊢ (p.or q).always.imp (p.or q).all_past.all_future :=
  sorry /- BX: derive temp_l from BX axioms -/

/-- Temporal L demonstrates perpetuity preservation -/
example : ⊢ (Formula.atom_s "eternal").always.imp (Formula.atom_s "eternal").all_past.all_future :=
  sorry /- BX: derive temp_l from BX axioms -/

/-!
## Temporal Duality Rule

The temporal duality rule swaps past and future operators in theorems.
If `⊢ φ` (φ is a theorem), then `⊢ swap_temporal φ` is also a theorem.
-/

/-- Using temporal duality on a theorem -/
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.swap_temporal :=
  DerivationTree.temporal_duality φ h

/-- Duality preserves theoremhood -/
example : ⊢ (Formula.atom_s "p").all_future.imp (Formula.atom_s "p").all_future := by
  -- Trivial identity - Gp → Gp
  exact identity (Formula.atom_s "p").all_future

/-!
## Temporal K Rule

The temporal K rule distributes `G` over derivations:
If `GΓ ⊢ φ` then `Γ ⊢ Gφ`.
-/

/-- Using temporal K rule: if `GΓ ⊢ φ` then `Γ ⊢ Gφ` -/
example (p : Formula) : [p] ⊢ p.all_future := by
  -- EXERCISE: Complete this proof using generalized necessitation
  sorry

/-!
## Future Operator (G) Examples

The all_future operator `G` expresses truth at all future times.
-/

/-- Future on atomic formula -/
example (p : Formula) : [p] ⊢ p.all_future := by
  -- EXERCISE: Complete this proof using temporal K rule
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
-/

/-- Past on atomic formula (using in context) -/
example : [(Formula.atom_s "p").all_past] ⊢ (Formula.atom_s "p").all_past :=
  DerivationTree.assumption _ _ (by simp)

/-- Some past: `¬P¬φ` means φ was true at some past time -/
example (φ : Formula) : φ.some_past = φ.neg.all_past.neg := rfl

/-- Past and future interact via temporal axioms: △φ → G(Hφ) -/
example (φ : Formula) : ⊢ φ.always.imp φ.all_past.all_future :=
  sorry /- BX: derive temp_l from BX axioms -/

/-!
## Multi-Step Temporal Reasoning
-/

/-- Chaining temporal operators: `GGGφ` via T4 -/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future.all_future := by
  sorry /- BX: needs temp_4 derived from BX1 -/

/-- Temporal iteration: applying T4 repeatedly -/
example : ⊢ (Formula.atom_s "perpetual").all_future.imp (Formula.atom_s "perpetual").all_future.all_future := by
  sorry /- BX: needs temp_4 derived from BX1 -/

/-!
## Temporal Properties
-/

/-- Idempotence pattern: `GGφ` is related to `Gφ` via T4 -/
example (φ : Formula) : ⊢ φ.all_future.imp φ.all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-- Present to future-past: TA axiom pattern -/
example (φ : Formula) : ⊢ φ.imp φ.some_past.all_future :=
  sorry /- BX: derive temp_a from BX4 -/

/-- Perpetuity preservation: TL axiom pattern △φ → G(Hφ) -/
example (φ : Formula) : ⊢ φ.always.imp φ.all_past.all_future :=
  sorry /- BX: derive temp_l from BX axioms -/

/-!
## Modal-Temporal Interaction Axioms

These axioms connect modal and temporal operators.
-/

/-- Modal-Future axiom MF: `□φ → □Gφ` -/
example (φ : Formula) : ⊢ φ.box.imp φ.all_future.box :=
  DerivationTree.axiom [] _ (Axiom.modal_future φ)

/-- Temporal-Future axiom TF: `□φ → G□φ` -/
example (φ : Formula) : ⊢ φ.box.imp φ.box.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_future φ)

/-- MF demonstrates necessity persists into future -/
example : ⊢ (Formula.atom_s "necessary").box.imp (Formula.atom_s "necessary").all_future.box :=
  DerivationTree.axiom [] _ (Axiom.modal_future (Formula.atom_s "necessary"))

/-- TF demonstrates necessary truths are perpetual -/
example : ⊢ (Formula.atom_s "necessary").box.imp (Formula.atom_s "necessary").box.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_future (Formula.atom_s "necessary"))

/-!
## Teaching Examples
-/

/-- Example: What will always be true remains always true -/
example : ⊢ (Formula.atom_s "sun_rises").all_future.imp (Formula.atom_s "sun_rises").all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-- Example: Present events are in the past of all futures -/
example : ⊢ (Formula.atom_s "today").imp (Formula.atom_s "today").some_past.all_future :=
  sorry /- BX: derive temp_a from BX4 -/

/-- Example: Eternal truths (TL axiom): △"2+2=4" → G(H"2+2=4") -/
example : ⊢ (Formula.atom_s "2+2=4").always.imp (Formula.atom_s "2+2=4").all_past.all_future :=
  sorry /- BX: derive temp_l from BX axioms -/

/-- Example: Future transitivity (T4 axiom): G"inevitable" → GG"inevitable" -/
example : ⊢ (Formula.atom_s "inevitable").all_future.imp (Formula.atom_s "inevitable").all_future.all_future :=
  sorry /- BX: derive temp_4 from BX1 -/

/-- Example: Sometimes notation (eventuality) -/
example (φ : Formula) : φ.sometimes = (▽φ) := rfl

/-- Example: Always notation (perpetuity) -/
example (φ : Formula) : φ.always = (△φ) := rfl

/-!
## Automated Temporal Search

The `temporal_search` tactic uses bounded proof search to automatically find
derivations for temporal logic goals. Under BX, it can find proofs using
BX1 (temp_t_future/past) and modal-temporal interaction axioms.
-/

/-- Automated proof of BX1 (temp_t_future) using temporal_search -/
example : ⊢ (Formula.atom_s "p").all_future.imp (Formula.atom_s "p") := by
  temporal_search

/-- Automated proof of BX1' (temp_t_past) using temporal_search -/
example : ⊢ (Formula.atom_s "p").all_past.imp (Formula.atom_s "p") := by
  temporal_search

/-- Automated proof of modal-future axiom MF using modal_search -/
example (φ : Formula) : ⊢ φ.box.imp φ.all_future.box := by
  modal_search

/-- Automated proof of temporal-future axiom TF using modal_search -/
example (φ : Formula) : ⊢ φ.box.imp φ.box.all_future := by
  modal_search

end Bimodal.Examples.TemporalProofs
