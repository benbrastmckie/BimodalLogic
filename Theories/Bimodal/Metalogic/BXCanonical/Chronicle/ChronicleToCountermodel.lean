import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Algebra.Order.Archimedean.Basic

/-!
# Chronicle-to-Countermodel Integration

Converts the Burgess chronicle construction into a countermodel suitable for
the BX completeness theorem.

## Strategy

The chronicle construction produces, for any MCS A:
- `limit_dom A h_mcs`: a countable set of rationals containing 0
- `limit_f A h_mcs`: a function assigning MCS to each domain point
- `limit_f_zero`: limit_f(0) = A
- `limit_c0`: every domain point maps to an MCS
- `limit_forward_G`/`limit_backward_H`: G/H propagation on domain
- `limit_satisfies_c5_strong`/`limit_satisfies_c5'_strong`: Until/Since (C5)
- `limit_satisfies_c4`/`limit_satisfies_c4'`: Counterexample elimination (C4)

To build a BFMCS Rat, we need to extend `limit_f` to ALL rationals while
preserving forward_G, backward_H, and the coherence conditions.

## Status: BLOCKED

The extension of `limit_f` to non-domain rationals requires an MCS assignment
satisfying forward_G (G(phi) in mcs(t) and t < t' implies phi in mcs(t')) and
backward_H (symmetric) for ALL pairs of rationals, including non-domain ones.

The previous Cantor isomorphism approach (X ~= Q via DenselyOrdered) made
ALL rationals domain points, avoiding the extension problem entirely. After
removing density (Phase 3), DenselyOrdered cannot be proved, so the Cantor
iso is unavailable.

The natural inclusion approach requires a mathematically non-trivial extension
argument. See `.handoff-phase4.md` for detailed analysis.

## References

- Burgess 1982: "Axioms for tense logic II: Time periods"
- Task 117 plan: specs/117_.../plans/03_natural-inclusion-refactor.md
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
open Bimodal.Semantics
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Perpetuity
open Bimodal.Metalogic.BXCanonical
open Classical

/-! ## Limit Domain Properties

The subtype `{q : Rat // q ∈ limit_dom A h_mcs}` inherits `LinearOrder` from `Rat`.
We prove the typeclass prerequisites `Countable`, `NoMinOrder`, `NoMaxOrder`, `Nonempty`.
-/

/-- The limit domain as a subtype of the rationals. -/
abbrev LimitDomSubtype (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :=
  {q : Rat // q ∈ limit_dom A h_mcs}

/--
`LimitDomSubtype` is countable: `limit_dom` is a countable union of finite sets
(each `omega_chain_val(n).dom` is a `Finset Rat`).
-/
instance limitDomSubtype_countable (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    Countable (LimitDomSubtype A h_mcs) :=
  Subtype.countable

/--
Helper: for any x in `limit_dom`, there exists y > x in `limit_dom`.

Proof: The seriality axiom `serial_future` gives `F(top)` in every MCS.
Since `limit_c0` assigns an MCS to x, we have `F(top) ∈ limit_f(x)`.
Then `limit_F_resolution` produces y > x in `limit_dom`.
-/
theorem limit_dom_no_max (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    ∃ y ∈ limit_dom A h_mcs, x < y := by
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_top : (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    theorem_in_mcs h_mcs_x (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_F_top : Formula.some_future (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x (DerivationTree.axiom [] _ Axiom.serial_future)) h_top
  obtain ⟨y, hy, hxy, _⟩ := limit_F_resolution A h_mcs x hx _ h_F_top
  exact ⟨y, hy, hxy⟩

/--
Helper: for any x in `limit_dom`, there exists y < x in `limit_dom`.

Proof: The seriality axiom `serial_past` gives `P(top)` in every MCS.
Since `limit_c0` assigns an MCS to x, we have `P(top) ∈ limit_f(x)`.
Then `limit_P_resolution` produces y < x in `limit_dom`.
-/
theorem limit_dom_no_min (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    ∃ y ∈ limit_dom A h_mcs, y < x := by
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_top : (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    theorem_in_mcs h_mcs_x (Bimodal.Theorems.Combinators.identity Formula.bot)
  have h_P_top : Formula.some_past (Formula.bot.imp Formula.bot) ∈ limit_f A h_mcs x :=
    SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x (DerivationTree.axiom [] _ Axiom.serial_past)) h_top
  obtain ⟨y, hy, hyx, _⟩ := limit_P_resolution A h_mcs x hx _ h_P_top
  exact ⟨y, hy, hyx⟩

/--
`LimitDomSubtype` has no maximum element: from seriality + `limit_F_resolution`.
-/
instance limitDomSubtype_noMaxOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    NoMaxOrder (LimitDomSubtype A h_mcs) where
  exists_gt := by
    intro ⟨a, ha⟩
    obtain ⟨y, hy, hay⟩ := limit_dom_no_max A h_mcs a ha
    exact ⟨⟨y, hy⟩, hay⟩

/--
`LimitDomSubtype` has no minimum element: from seriality + `limit_P_resolution`.
-/
instance limitDomSubtype_noMinOrder (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    NoMinOrder (LimitDomSubtype A h_mcs) where
  exists_lt := by
    intro ⟨a, ha⟩
    obtain ⟨y, hy, hya⟩ := limit_dom_no_min A h_mcs a ha
    exact ⟨⟨y, hy⟩, hya⟩

/--
`LimitDomSubtype` is nonempty: from `zero_mem_limit_dom`.
-/
instance limitDomSubtype_nonempty (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    Nonempty (LimitDomSubtype A h_mcs) :=
  ⟨⟨0, zero_mem_limit_dom A h_mcs⟩⟩

/-! ## Countermodel Construction (BLOCKED)

The previous Cantor-isomorphism-based construction has been removed because
`DenselyOrdered (LimitDomSubtype A h_mcs)` cannot be proved after removing
the density counterexample kind from the chronicle.

A replacement construction using natural inclusion (X ⊂ Q with Lindenbaum
extension for non-domain rationals) is needed. The key challenge is proving
forward_G and backward_H for the extended MCS assignment at non-domain
rationals. See the handoff document for mathematical analysis.

The `dd_countermodel_chronicle` theorem (used by `bx_completeness`) will be
restored once the extension approach is resolved.
-/

-- Placeholder: dd_countermodel_chronicle will be reconstructed after
-- resolving the forward_G/backward_H extension blocker.
-- The theorem statement should be:
--
-- theorem dd_countermodel_chronicle (M : Set Formula) (h_mcs : SetMaximalConsistent M)
--     (φ : Formula) (h_neg_in : φ.neg ∈ M) :
--     ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
--       (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
--       (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
--       (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
--       ¬truth_at TM Omega τ t φ

end Bimodal.Metalogic.BXCanonical.Chronicle
