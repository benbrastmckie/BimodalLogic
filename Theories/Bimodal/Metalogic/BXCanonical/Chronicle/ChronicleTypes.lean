import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.BXCanonical.Frame
import Mathlib.Data.Rat.Defs

/-!
# Chronicle Types for Burgess 1982 Construction

This module defines the chronicle data structure from Burgess 1982, Section 2,
adapted for irreflexive (strict) temporal semantics.

## Overview

A **chronicle** is a triple `(f, g, dom)` where:
- `f : Rat -> Set Formula` maps rational time points to maximal consistent sets (MCS)
- `g : Rat -> Rat -> Set Formula` maps adjacent intervals to deductively closed sets (DCS)
- `dom : Finset Rat` is the finite domain of defined time points

## Key Definitions

- `SetDeductivelyClosed`: A set of formulas closed under derivation
- `rRelation`: The r-relation from Burgess Lemma 2.3
- `rMaximal`: B is a maximal DCS with r(A, B)
- `Chronicle`: The core data structure
- `Chronicle.c0`-`c5'`: The chronicle conditions

## Design Notes

The r-relation captures Until-propagation conditions that g_content alone cannot
provide. Where g_content(A) = {phi | G(phi) in A} captures universal future
propagation, the r-relation additionally tracks which Until-obligations from A
are resolved vs. continuing in the interval set B. This is exactly why the
chronicle needs a binary interval function g(x,y) rather than the unary
g_content approach used in the existing chain construction.

## Adaptation for Open Guard Semantics (Task 113)

Under open guard semantics, the Until operator `phi U psi` at time t requires
a witness s > t (strict) with psi(s) and guard phi on (t,s) (open interval).
The evaluation point t is NOT in the guard interval.

Key consequences:
- BX9 (until_elim) is REMOVED: `(phi U psi) -> (phi ∨ psi)` is invalid
- until_guard axiom is REMOVED: `(phi U psi) -> phi` is invalid
- `rRelation_of_superset_mcs` and `rRelationSince_of_superset_mcs` are REMOVED (invalid)

The Burgess construction uses BX4 (connect_future), BX5 (self_accum_until),
and BX10 (until_F: phi U psi -> F(psi)) as replacements.

## References

- Burgess 1982: "Axioms for tense logic II: Time periods"
- Burgess 1984: "Basic tense logic"
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/-! ## Deductively Closed Sets (DCS) -/

/-- A set is closed under derivation if every consequence of its elements is also in it.
This is Burgess 1982's definition of "deductively closed set" (DCS).
Note: does NOT require consistency. `Set.univ` is `ClosedUnderDerivation`. -/
def ClosedUnderDerivation (S : Set Formula) : Prop :=
  ∀ (L : List Formula) (φ : Formula),
    (∀ ψ ∈ L, ψ ∈ S) → (DerivationTree L φ) → φ ∈ S

/--
A set of formulas is **deductively closed** if it is consistent and closed
under derivation: whenever all premises of a derivation are in the set,
the conclusion is also in the set.

Every MCS is deductively closed, but not every DCS is maximal.
DCS are used for the interval function `g(x,y)` in the chronicle,
which describes the formulas that hold throughout an interval.
-/
def SetDeductivelyClosed (S : Set Formula) : Prop :=
  SetConsistent S ∧ ClosedUnderDerivation S

/-- Every MCS is deductively closed. -/
theorem mcs_is_dcs {S : Set Formula} (h : SetMaximalConsistent S) :
    SetDeductivelyClosed S :=
  ⟨h.1, fun L _ hL hd => SetMaximalConsistent.closed_under_derivation h L hL hd⟩

/-- A DCS contains all theorems. -/
theorem dcs_contains_theorems {S : Set Formula} (h : SetDeductivelyClosed S)
    {φ : Formula} (hd : DerivationTree [] φ) : φ ∈ S :=
  h.2 [] φ (fun _ h => absurd h List.not_mem_nil) hd

/-- A DCS is consistent. -/
theorem dcs_consistent {S : Set Formula} (h : SetDeductivelyClosed S) :
    SetConsistent S := h.1

/-- Modus ponens in a DCS: if phi -> psi and phi are in S, then psi is in S. -/
theorem dcs_modus_ponens {S : Set Formula} (h : SetDeductivelyClosed S)
    {φ ψ : Formula} (h_imp : φ.imp ψ ∈ S) (h_phi : φ ∈ S) : ψ ∈ S := by
  apply h.2 [φ, φ.imp ψ] ψ
  · intro χ h_mem
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
    rcases h_mem with rfl | rfl
    · exact h_phi
    · exact h_imp
  · exact DerivationTree.modus_ponens [φ, φ.imp ψ] φ ψ
      (DerivationTree.assumption _ (φ.imp ψ) (by simp))
      (DerivationTree.assumption _ φ (by simp))

/-- A DCS is closed under conjunction: if phi, psi in S then phi ∧ psi in S. -/
theorem dcs_conj_closed {S : Set Formula} (h : SetDeductivelyClosed S)
    {φ ψ : Formula} (h_phi : φ ∈ S) (h_psi : ψ ∈ S) : Formula.and φ ψ ∈ S := by
  -- phi ∧ psi = ¬(phi → ¬psi)
  -- We have ⊢ phi → (psi → phi ∧ psi) (pairing)
  have h_pair := dcs_contains_theorems h (Bimodal.Theorems.Combinators.pairing φ ψ)
  exact dcs_modus_ponens h (dcs_modus_ponens h h_pair h_phi) h_psi

/-! ## Adjacency predicate -/

/--
Two domain points x < y are **adjacent** in the domain dom if there is
no z in dom strictly between them.
-/
def Adjacent (dom : Finset Rat) (x y : Rat) : Prop :=
  x ∈ dom ∧ y ∈ dom ∧ x < y ∧ ∀ z ∈ dom, ¬(x < z ∧ z < y)

/-! ## The r-Relation (Burgess Lemma 2.3) -/

/--
The **r-relation** `rRelation A B` from Burgess Section 2.

For an MCS A and a set B (typically a DCS), `rRelation A B` holds when:
for all formulas gamma and delta, if `Until(gamma, delta) in A`,
then `delta in B` or (`gamma in B` and `Until(gamma, delta) in B`).

This captures: B is a valid continuation of A with respect to Until-obligations.
At B, either the Until-eventuality is resolved (delta holds) or the guard
continues (gamma holds and the Until persists).

Under open guard semantics, this connects to:
- BX5 (self_accum_until): phi U psi -> (phi ∧ (phi U psi)) U psi
- BX10 (until_F): phi U psi -> F(psi)
Note: BX9 (until_elim: phi U psi -> phi ∨ psi) has been REMOVED (task 113).
-/
def rRelation (A B : Set Formula) : Prop :=
  ∀ (γ δ : Formula),
    Formula.untl γ δ ∈ A →
    δ ∈ B ∨ (γ ∈ B ∧ Formula.untl γ δ ∈ B)

/--
Symmetric r-relation for Since: `rRelationSince A B`.

For all gamma, delta: if `Since(gamma, delta) in A`, then `delta in B`
or (`gamma in B` and `Since(gamma, delta) in B`).
-/
def rRelationSince (A B : Set Formula) : Prop :=
  ∀ (γ δ : Formula),
    Formula.snce γ δ ∈ A →
    δ ∈ B ∨ (γ ∈ B ∧ Formula.snce γ δ ∈ B)

/-! ## Three-Argument r-Relation (Burgess 2.3, adapted)

The three-argument r-relation r3(A, B, C) captures interval-endpoint compatibility:
B is a valid interval set between left endpoint A and right endpoint C.

The condition is: rRelation A B AND rRelationSince C B. That is, B propagates
Until-obligations from A correctly AND Since-obligations from C correctly.
This dual constraint is what makes the three-argument r-relation strictly stronger
than the two-argument version and is essential for the omega-chain invariant:
it ensures that g-values inserted between endpoints are compatible with BOTH sides.

Under Burgess's construction, r3(A, B, C) means the interval (x,y) with
f(x) = A, f(y) = C has interval set g(x,y) = B that correctly propagates
temporal obligations in both directions.
-/

/--
The **three-argument r-relation** `r3Relation A B C`: B is a valid interval set
between endpoints A (left) and C (right).

Combines forward propagation (rRelation A B) with backward propagation
(rRelationSince C B): for all Until formulas in A, B either resolves or
continues them; for all Since formulas in C, B either resolves or continues them.
-/
def r3Relation (A B C : Set Formula) : Prop :=
  rRelation A B ∧ rRelationSince C B

/--
Mirror for the Since direction: `r3RelationSince A B C` where A is
the right endpoint and C is the left endpoint.

Combines backward propagation (rRelationSince A B) with forward propagation
(rRelation C B).
-/
def r3RelationSince (A B C : Set Formula) : Prop :=
  rRelationSince A B ∧ rRelation C B

/-! ## R-Maximality -/

/--
**R-maximality**: `rMaximal A B` means B is a maximal DCS satisfying `rRelation A B`.

B is R-maximal with respect to A if:
1. B is deductively closed
2. rRelation A B holds
3. No proper DCS extension of B still satisfies rRelation A

R-maximality ensures interval sets contain as many formulas as possible
while maintaining consistency and the r-relation.
-/
def rMaximal (A B : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  rRelation A B ∧
  ∀ (C : Set Formula),
    SetDeductivelyClosed C →
    B ⊂ C →
    ¬rRelation A C

/--
R-maximality for Since.
-/
def rMaximalSince (A B : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  rRelationSince A B ∧
  ∀ (C : Set Formula),
    SetDeductivelyClosed C →
    B ⊂ C →
    ¬rRelationSince A C

/--
**Three-argument R-maximality**: `R3Maximal A B C` means B is a maximal DCS
satisfying `r3Relation A B C`.

B is R3-maximal with respect to endpoints A and C if:
1. B is deductively closed
2. r3Relation A B C holds (both rRelation A B and rRelationSince C B)
3. No proper DCS extension of B satisfies r3Relation A - C
-/
def R3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  r3Relation A B C ∧
  ∀ (D : Set Formula),
    SetDeductivelyClosed D →
    B ⊂ D →
    ¬r3Relation A D C

/--
Three-argument R-maximality for Since direction.
-/
def R3MaximalSince (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  r3RelationSince A B C ∧
  ∀ (D : Set Formula),
    SetDeductivelyClosed D →
    B ⊂ D →
    ¬r3RelationSince A D C

/-! ## Burgess r-Relation (Content-Based)

Burgess's r-relation is fundamentally different from the codebase's `rRelation`:

- **Codebase rRelation(A, B)**: For all gamma U delta in A, either delta in B or
  (gamma in B and gamma U delta in B). This is OBLIGATION PROPAGATION: Until
  formulas from A propagate to B. MONOTONE in B.

- **Burgess r(A, beta, C)**: For all gamma in C, untl(beta, gamma) in A.
  This is CONTENT: beta is a guard such that any formula from C can serve as
  the event in an Until formula in A. ANTI-MONOTONE in B (at set level).

Neither implies the other in general.
-/

/--
**Burgess r-relation for a single element**: `burgessR A beta C` holds when
for all gamma in C, `untl(beta, gamma) in A`.
-/
def burgessR (A : Set Formula) (β : Formula) (C : Set Formula) : Prop :=
  ∀ γ ∈ C, Formula.untl β γ ∈ A

/--
**Burgess r-relation for a set**: `burgessRSet A B C` holds when
for all beta in B, `burgessR A beta C`.
-/
def burgessRSet (A B C : Set Formula) : Prop :=
  ∀ β ∈ B, burgessR A β C

/--
**Burgess r-relation for Since (single element)**: `burgessRSince A beta C` holds
when for all gamma in C, `snce(beta, gamma) in A`.
-/
def burgessRSince (A : Set Formula) (β : Formula) (C : Set Formula) : Prop :=
  ∀ γ ∈ C, Formula.snce β γ ∈ A

/--
**Burgess r-relation for Since (set)**: `burgessRSetSince A B C` holds when
for all beta in B, `burgessRSince A beta C`.
-/
def burgessRSetSince (A B C : Set Formula) : Prop :=
  ∀ β ∈ B, burgessRSince A β C

/--
**Combined Burgess r-relation**: `burgessR3 A B C` holds when
burgessRSet(A, B, C) AND burgessRSetSince(C, B, A).

This captures both forward (Until from A through B to C) and backward
(Since from C through B to A) relationships.
-/
def burgessR3 (A B C : Set Formula) : Prop :=
  burgessRSet A B C ∧ burgessRSetSince C B A

/--
**BurgessR3Maximal**: B is a maximal DCS satisfying `burgessR3(A, B, C)`.

This is Burgess's Definition 2.5 (R-maximality) using the correct content-based
r-relation. B is maximal among ALL `ClosedUnderDerivation` proper extensions
(including inconsistent ones like `Set.univ`), matching Burgess 1982 exactly.

The maximality clause uses `ClosedUnderDerivation` (not `SetDeductivelyClosed`)
because Burgess's "deductively closed" does NOT require consistency. This is
essential: when B is MCS, no *consistent* proper extension exists, but `Set.univ`
is a `ClosedUnderDerivation` proper extension. The maximality clause must rule
out `burgessR3(A, Set.univ, C)` to provide useful neg-until witnesses.
-/
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C

/--
**No universal burgessR3**: For ANY pair of MCS A, C, `burgessR3(A, Set.univ, C)` fails.

This is a structural property needed for the Zorn construction of `BurgessR3Maximal`:
the strengthened maximality clause (over `ClosedUnderDerivation`) must rule out
inconsistent extensions, which are all equal to `Set.univ`. Without this condition,
the Zorn proof cannot establish maximality over `ClosedUnderDerivation` sets.

**Semantic justification**: On any linear order with strict/open guard semantics,
`untl(⊥, gamma)` requires ⊥ to hold at all intermediate points. On a dense order,
there are always intermediate points, making ⊥ ∧ true impossible. So
`untl(⊥, gamma) = ⊥` semantically, and `burgessR3(A, Set.univ, C)` fails.

This condition is NOT derivable from J₀ axioms alone (since J₀ is also complete
for discrete orders where `untl(⊥, gamma)` can hold vacuously). It is a property
specific to the dense-order chronicle construction.
-/
def NoUnivBurgessR3 : Prop :=
  ∀ A C : Set Formula, SetMaximalConsistent A → SetMaximalConsistent C →
    ¬burgessR3 A Set.univ C

/-! ## Chronicle Structure -/

/--
A **Chronicle** is a triple `(f, g, dom)` representing a finite temporal
model over the rationals, as defined in Burgess 1982 Section 2.

The chronicle assigns:
- An MCS `f(x)` to each rational time point x in the domain
- A DCS `g(x,y)` to each pair of adjacent time points x < y in the domain,
  representing formulas that hold throughout the interval (x,y)
-/
structure Chronicle where
  /-- Point assignment: maps rational time points to sets of formulas -/
  f : Rat → Set Formula
  /-- Interval assignment: maps pairs (x,y) with x < y to sets of formulas -/
  g : Rat → Rat → Set Formula
  /-- Finite domain of time points -/
  dom : Finset Rat

/-! ## Chronicle Conditions -/

/-- **C0**: Every point in the domain maps to an MCS. -/
def Chronicle.c0 (χ : Chronicle) : Prop :=
  ∀ x ∈ χ.dom, SetMaximalConsistent (χ.f x)

/-- **C1**: Every pair x < y in the domain maps to a DCS. -/
def Chronicle.c1 (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → x < y → SetDeductivelyClosed (χ.g x y)

/-- **C2**: The three-argument r-relation holds for all pairs x < y in the domain.
For x < y in dom, r3Relation(f(x), g(x,y), f(y)) holds. -/
def Chronicle.c2 (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → x < y → r3Relation (χ.f x) (χ.g x y) (χ.f y)

/-- **C2'**: BurgessR3Maximal for adjacent pairs (Burgess Definition 2.5).

At finite stages, g(x,y) must be a maximal DCS satisfying burgessR3(f(x), g(x,y), f(y))
for adjacent pairs (x,y). This is the CORRECT formulation matching Burgess 1982's
R-maximality requirement in C2'. Maximality ensures the interval sets contain as many
formulas as possible while maintaining the r-relation, which is needed for:
1. The C4 hard case (gamma not in g implies gamma.neg in an MCS extending g)
2. Xu's Lemma 3.2.1 (closure of B under Until/Since formation)
3. The truth lemma (g-values faithfully represent interval truth)

At the limit, the domain is dense (no adjacent pairs), so c2' is vacuously true.
The `burgessR3Maximal_exists_from_seed` theorem in RRelation.lean produces maximal
DCS from seed elements. -/
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)

/-- **C3**: Three-way interval decomposition (Burgess 1982, p. 372).
For all x < y < z in dom, g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z).

This is the CORRECT C3 from Burgess. The three-way intersection including f(y)
is essential: it gives g(x,z) ⊆ f(y) immediately, which is the key property
for the truth lemma. The earlier two-way version (omitting f(y)) was a
transcription error that blocked 21 research rounds. -/
def Chronicle.c3 (χ : Chronicle) : Prop :=
  ∀ x y z : Rat, x ∈ χ.dom → y ∈ χ.dom → z ∈ χ.dom →
    x < y → y < z → χ.g x z = χ.g x y ∩ χ.f y ∩ χ.g y z

/-- **C4**: Backward counterexample condition for Until (Burgess 1982, C4a).
For all x, y in dom with x < y: if `¬(γ U δ) ∈ f(x)` and `δ ∈ f(y)`,
then there exists z in dom with `x < z < y` and `¬γ ∈ f(z)`.

In `untl γ δ`: γ is the GUARD, δ is the EVENT.
Burgess C4a checks the EVENT (δ) at f(y) and negates the GUARD (γ) at f(z).

Intuition: If Until(γ,δ) is false at x but the eventuality δ holds at some
future point y, then the guard γ must have failed somewhere between x and y --
otherwise γ would hold throughout [x,y) and δ at y, satisfying Until.

Note: Burgess C4a applies to ALL pairs x < y in the domain, not just adjacent
pairs. The adjacency restriction was a transcription error that made C4
vacuously true at the dense limit (where no adjacent pairs exist). -/
def Chronicle.c4 (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → x < y →
    ∀ (γ δ : Formula),
      (Formula.untl γ δ).neg ∈ χ.f x →
      δ ∈ χ.f y →
      ∃ z ∈ χ.dom, x < z ∧ z < y ∧ γ.neg ∈ χ.f z

/-- **C4'**: Backward counterexample condition for Since (mirror of C4, Burgess C4b).
For all x, y in dom with y < x: if `¬(γ S δ) ∈ f(x)` and `δ ∈ f(y)`,
then there exists z in dom with `y < z < x` and `¬γ ∈ f(z)`.

In `snce γ δ`: γ is the GUARD, δ is the EVENT.
Checks EVENT (δ) at f(y), negates GUARD (γ) at f(z).

Note: Like C4, this applies to ALL pairs y < x, not just adjacent pairs. -/
def Chronicle.c4' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, x ∈ χ.dom → y ∈ χ.dom → y < x →
    ∀ (γ δ : Formula),
      (Formula.snce γ δ).neg ∈ χ.f x →
      δ ∈ χ.f y →
      ∃ z ∈ χ.dom, y < z ∧ z < x ∧ γ.neg ∈ χ.f z

/-- **C5**: Forward Until witness condition.
For x in dom: if `gamma U delta in f(x)`, then there exists y in dom
with x < y such that delta in f(y) and the guard gamma holds at all
intermediate domain points. -/
def Chronicle.c5 (χ : Chronicle) : Prop :=
  ∀ x ∈ χ.dom,
    ∀ (γ δ : Formula),
      Formula.untl γ δ ∈ χ.f x →
      ∃ y ∈ χ.dom, x < y ∧ δ ∈ χ.f y ∧
        ∀ z ∈ χ.dom, x < z → z < y →
          γ ∈ χ.f z ∧ Formula.untl γ δ ∈ χ.f z

/-- **C5'**: Backward Since witness condition (mirror of C5). -/
def Chronicle.c5' (χ : Chronicle) : Prop :=
  ∀ x ∈ χ.dom,
    ∀ (γ δ : Formula),
      Formula.snce γ δ ∈ χ.f x →
      ∃ y ∈ χ.dom, y < x ∧ δ ∈ χ.f y ∧
        ∀ z ∈ χ.dom, y < z → z < x →
          γ ∈ χ.f z ∧ Formula.snce γ δ ∈ χ.f z

/--
A **valid chronicle** satisfies all the core chronicle conditions.
This is the target state after the omega-chain construction in Phase 4.
-/
structure ValidChronicle extends Chronicle where
  /-- C0: Points map to MCS -/
  hc0 : toChronicle.c0
  /-- C1: All pairs map to DCS -/
  hc1 : toChronicle.c1
  /-- C2: Three-argument r-relation for all pairs -/
  hc2 : toChronicle.c2
  /-- C2': R3-maximality for adjacent pairs -/
  hc2' : toChronicle.c2'
  /-- C3: Three-way interval decomposition -/
  hc3 : toChronicle.c3
  /-- C4: Backward counterexample for Until -/
  hc4 : toChronicle.c4
  /-- C4': Backward counterexample for Since -/
  hc4' : toChronicle.c4'
  /-- C5: Forward Until witnesses -/
  hc5 : toChronicle.c5
  /-- C5': Backward Since witnesses -/
  hc5' : toChronicle.c5'

/-! ## C3 Consequences -/

/--
Key consequence of three-way C3: g(x,z) ⊆ f(y) for x < y < z in dom.
Since g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z), the intersection is contained in f(y).
This is the critical property for the truth lemma.
-/
theorem c3_interval_subset_point (χ : Chronicle) (h_c3 : χ.c3)
    {x y z : Rat} (hx : x ∈ χ.dom) (hy : y ∈ χ.dom) (hz : z ∈ χ.dom)
    (hxy : x < y) (hyz : y < z) :
    χ.g x z ⊆ χ.f y := by
  have h_eq := h_c3 x y z hx hy hz hxy hyz
  intro φ hφ
  rw [h_eq] at hφ
  exact hφ.1.2

/--
C3 implies g(x,z) ⊆ g(x,y) for x < y < z in dom.
-/
theorem c3_interval_subset_left (χ : Chronicle) (h_c3 : χ.c3)
    {x y z : Rat} (hx : x ∈ χ.dom) (hy : y ∈ χ.dom) (hz : z ∈ χ.dom)
    (hxy : x < y) (hyz : y < z) :
    χ.g x z ⊆ χ.g x y := by
  have h_eq := h_c3 x y z hx hy hz hxy hyz
  intro φ hφ
  rw [h_eq] at hφ
  exact hφ.1.1

/--
C3 implies g(x,z) ⊆ g(y,z) for x < y < z in dom.
-/
theorem c3_interval_subset_right (χ : Chronicle) (h_c3 : χ.c3)
    {x y z : Rat} (hx : x ∈ χ.dom) (hy : y ∈ χ.dom) (hz : z ∈ χ.dom)
    (hxy : x < y) (hyz : y < z) :
    χ.g x z ⊆ χ.g y z := by
  have h_eq := h_c3 x y z hx hy hz hxy hyz
  intro φ hφ
  rw [h_eq] at hφ
  exact hφ.2

/-! ## ChronicleInvariant Bundle -/

/--
Bundle of chronicle invariants maintained at every finite stage of the
omega-chain construction. This replaces the previous approach of tracking
only C0.

The key insight (Burgess 1982): maintaining C0, C1, C2' (adjacent), and C3
at every finite stage enables the limit to satisfy C4/C5 (which are ensured
by counterexample elimination), and the truth lemma follows from C3 alone
(no need for g_content_chain_property).

Note: C2 (r3Relation for ALL pairs) is NOT maintained at finite stages.
It is derivable at the limit from C2' + C3 + density via Lemma 2.5
absorption (see `burgessR3_absorption` in RRelation.lean). The finite-stage
invariant only needs C2' because non-adjacent g values are defined by C3
and the r-relation for non-adjacent pairs follows from Lemma 2.5.
-/
structure ChronicleInvariant (χ : Chronicle) : Prop where
  /-- C0: Every domain point maps to an MCS -/
  hc0 : χ.c0
  /-- C1: Every pair x < y maps to a DCS -/
  hc1 : χ.c1
  /-- C2': BurgessR3Maximal for adjacent pairs (Burgess Definition 2.5).
  Uses the content-based Burgess r-relation (burgessR3) with maximality.
  C2 (r3Relation for ALL pairs) is derivable at the limit via Lemma 2.5 absorption.
  The finite-stage invariant only needs C2' for adjacent pairs. -/
  hc2' : χ.c2'
  /-- C3: Three-way interval decomposition -/
  hc3 : χ.c3

/-! ## Basic Properties -/

/-- The r-relation is monotone in the second argument: if B subset C and r(A, C),
then r(A, B) does NOT necessarily hold. But r-relation IS monotone contravariantly:
if B subset C and r(A, B), then for gamma U delta in A, if delta in B then delta in C. -/
theorem rRelation_subset {A B C : Set Formula}
    (h_r : rRelation A B) (h_sub : B ⊆ C) : rRelation A C := by
  intro γ δ h_until
  rcases h_r γ δ h_until with h_delta | ⟨h_gamma, h_u⟩
  · exact Or.inl (h_sub h_delta)
  · exact Or.inr ⟨h_sub h_gamma, h_sub h_u⟩

/-- Similarly for Since. -/
theorem rRelationSince_subset {A B C : Set Formula}
    (h_r : rRelationSince A B) (h_sub : B ⊆ C) : rRelationSince A C := by
  intro γ δ h_since
  rcases h_r γ δ h_since with h_delta | ⟨h_gamma, h_s⟩
  · exact Or.inl (h_sub h_delta)
  · exact Or.inr ⟨h_sub h_gamma, h_sub h_s⟩

-- rRelation_of_superset_mcs: REMOVED (task 113 Phase 3). INVALID under open guard.
-- rRelationSince_of_superset_mcs: REMOVED (task 113 Phase 3). INVALID under open guard.
-- Both archived in Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean.

/-! ## Three-Argument r-Relation Properties -/

/-- Bridge lemma: r3Relation implies rRelation (weakening, drops the C constraint). -/
theorem r3Relation_implies_rRelation {A B C : Set Formula}
    (h : r3Relation A B C) : rRelation A B := h.1

/-- Bridge lemma: r3Relation implies rRelationSince from C. -/
theorem r3Relation_implies_rRelationSince {A B C : Set Formula}
    (h : r3Relation A B C) : rRelationSince C B := h.2

/-- r3Relation is monotone in B (superset direction, covariant). -/
theorem r3Relation_subset {A B B' C : Set Formula}
    (h : r3Relation A B C) (h_sub : B ⊆ B') : r3Relation A B' C :=
  ⟨rRelation_subset h.1 h_sub, rRelationSince_subset h.2 h_sub⟩

/-- R3Maximal implies rMaximal (weakening, R3-maximal sets are at least R-maximal
    within the class of DCS satisfying the three-argument constraint). -/
theorem R3Maximal_dcs {A B C : Set Formula} (h : R3Maximal A B C) :
    SetDeductivelyClosed B := h.1

/-- R3Maximal implies r3Relation. -/
theorem R3Maximal_r3 {A B C : Set Formula} (h : R3Maximal A B C) :
    r3Relation A B C := h.2.1

/-- R3Maximal implies rRelation (via bridge). -/
theorem R3Maximal_rRelation {A B C : Set Formula} (h : R3Maximal A B C) :
    rRelation A B := h.2.1.1

/-! ## DCS Intersection Properties -/

/--
The intersection of two DCS is deductively closed (when consistent).
If S₁ and S₂ are both deductively closed and their intersection is consistent,
then S₁ ∩ S₂ is deductively closed.

Proof: If all premises of a derivation are in S₁ ∩ S₂, they are in both S₁ and S₂.
Since both are closed under derivation, the conclusion is in both, hence in the
intersection.
-/
theorem dcs_inter_dcs {S₁ S₂ : Set Formula}
    (h₁ : SetDeductivelyClosed S₁) (h₂ : SetDeductivelyClosed S₂)
    (h_cons : SetConsistent (S₁ ∩ S₂)) :
    SetDeductivelyClosed (S₁ ∩ S₂) := by
  constructor
  · exact h_cons
  · intro L φ hL hd
    constructor
    · exact h₁.2 L φ (fun ψ hψ => (hL ψ hψ).1) hd
    · exact h₂.2 L φ (fun ψ hψ => (hL ψ hψ).2) hd

/--
The intersection of a DCS with an MCS is deductively closed (when consistent).
-/
theorem dcs_inter_mcs {S₁ S₂ : Set Formula}
    (h₁ : SetDeductivelyClosed S₁) (h₂ : SetMaximalConsistent S₂)
    (h_cons : SetConsistent (S₁ ∩ S₂)) :
    SetDeductivelyClosed (S₁ ∩ S₂) :=
  dcs_inter_dcs h₁ (mcs_is_dcs h₂) h_cons

/--
A subset of a consistent set is consistent (for derivation-based consistency).
If S ⊆ T and T is consistent, then S is consistent.
-/
theorem SetConsistent_of_subset {S T : Set Formula}
    (h_sub : S ⊆ T) (h_cons : SetConsistent T) : SetConsistent S := by
  intro L hL hd
  exact h_cons L (fun ψ hψ => h_sub (hL ψ hψ)) hd

/--
The three-way intersection g(w,x) ∩ f(x) ∩ B is consistent when it is
a subset of a consistent set (e.g., B).
-/
theorem three_way_inter_consistent {S₁ S₂ S₃ : Set Formula}
    (h₃_cons : SetConsistent S₃) :
    SetConsistent (S₁ ∩ S₂ ∩ S₃) :=
  SetConsistent_of_subset (fun _ h => h.2) h₃_cons

/--
The three-way intersection of two DCS and an MCS is deductively closed.
Used for C1 verification when defining g values by C3.
-/
theorem dcs_inter_mcs_inter_dcs {S₁ S₂ S₃ : Set Formula}
    (h₁ : SetDeductivelyClosed S₁) (h₂ : SetMaximalConsistent S₂)
    (h₃ : SetDeductivelyClosed S₃)
    (h_cons : SetConsistent (S₁ ∩ S₂ ∩ S₃)) :
    SetDeductivelyClosed (S₁ ∩ S₂ ∩ S₃) := by
  constructor
  · exact h_cons
  · intro L φ hL hd
    refine ⟨⟨h₁.2 L φ (fun ψ hψ => (hL ψ hψ).1.1) hd,
            (mcs_is_dcs h₂).2 L φ (fun ψ hψ => (hL ψ hψ).1.2) hd⟩,
            h₃.2 L φ (fun ψ hψ => (hL ψ hψ).2) hd⟩

end Bimodal.Metalogic.BXCanonical.Chronicle
