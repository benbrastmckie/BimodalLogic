import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.CanonicalEmbedding
import Bimodal.Metalogic.Bundle.CanonicalReachable
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Mathlib.Order.Antisymmetrization

/-!
# Canonical Quotient Construction

This module constructs the Antisymmetrization quotient of the canonical reachable fragment,
obtaining a LinearOrder suitable for FMCS Int construction.

## Overview

Given a root MCS `M₀`, the reachable fragment `CanonicalReachable M₀ h_mcs₀` forms a total
preorder under `CanonicalR`. The Antisymmetrization quotient identifies mutually CanonicalR-related
MCSes (which share the same GContent by `gcontent_eq_of_mutual_R`), yielding a `LinearOrder`.

## Main Definitions

- `Preorder (CanonicalReachable M₀ h_mcs₀)` - via CanonicalR (reflexive + transitive)
- `IsTotal` - from `canonical_reachable_comparable`
- `CanonicalQuotient M₀ h_mcs₀` - the Antisymmetrization quotient type
- `LinearOrder (CanonicalQuotient M₀ h_mcs₀)` - automatic from Mathlib

## Main Results

- `Nonempty (CanonicalQuotient M₀ h_mcs₀)` - lifted from root element
- `quotient_eq_of_mutual_R` - mutually R-related elements are identified
- `quotient_gcontent_eq` - equivalence class members share GContent
- `CanonicalQuotient.le_implies_canonicalR` - ordering implies CanonicalR between representatives

## References

- Task 922 research-004.md: Team research confirming Antisymmetrization approach
- Mathlib.Order.Antisymmetrization: Quotient construction infrastructure
- CanonicalReachable.lean: Total preorder on reachable fragment
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## Preorder Instance on CanonicalReachable

The canonical future relation CanonicalR defines a preorder on the reachable fragment:
- Reflexivity: `canonicalR_reflexive` (via T-axiom)
- Transitivity: `canonicalR_transitive` (via Temporal 4 axiom)
-/

/--
Preorder on the reachable fragment via CanonicalR.

`a ≤ b` iff `CanonicalR a.world b.world` iff `GContent(a.world) ⊆ b.world`.
-/
noncomputable instance : Preorder (CanonicalReachable M₀ h_mcs₀) where
  le a b := CanonicalR a.world b.world
  le_refl a := canonicalR_reflexive a.world a.is_mcs
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc

/--
Explicit `IsPreorder` instance for the CanonicalR-based ordering.

This is derivable from `Preorder` but must be stated explicitly due to elaboration
timing issues with `toAntisymmetrization` instance resolution.
-/
noncomputable instance : IsPreorder (CanonicalReachable M₀ h_mcs₀) (· ≤ ·) := inferInstance

/--
The preorder is total: any two reachable MCSes are comparable.

This follows from `canonical_reachable_comparable`, which provides the disjunction
`CanonicalR a b ∨ CanonicalR b a ∨ a.world = b.world`. The third case collapses
to the first via extensional equality and reflexivity.
-/
noncomputable instance : IsTotal (CanonicalReachable M₀ h_mcs₀) (· ≤ ·) where
  total a b := by
    rcases canonical_reachable_comparable a b with h1 | h2 | h3
    · exact Or.inl h1
    · exact Or.inr h2
    · exact Or.inl (CanonicalReachable.ext h3 ▸ le_refl b)

/--
Classical decidability for the preorder relation.
-/
noncomputable instance : DecidableRel (α := CanonicalReachable M₀ h_mcs₀) (· ≤ ·) :=
  fun _ _ => Classical.dec _

/--
Classical decidability for the strict order relation.
-/
noncomputable instance : DecidableRel (α := CanonicalReachable M₀ h_mcs₀) (· < ·) :=
  fun _ _ => Classical.dec _

/--
The total preorder satisfies Std.Total (needed for LinearOrder on Antisymmetrization).
-/
noncomputable instance : Std.Total (α := CanonicalReachable M₀ h_mcs₀) (· ≤ ·) :=
  ⟨IsTotal.total⟩

/-!
## The Canonical Quotient

The Antisymmetrization quotient identifies elements `a, b` when both `a ≤ b` and `b ≤ a`.
For CanonicalR: `AntisymmRel (· ≤ ·) a b ↔ CanonicalR a.world b.world ∧ CanonicalR b.world a.world`.

This is exactly "mutually CanonicalR-related", which by `gcontent_eq_of_mutual_R` means
the identified MCSes share the same GContent.
-/

/--
The canonical quotient: Antisymmetrization of the reachable fragment by the CanonicalR preorder.

This quotient collapses mutually CanonicalR-related MCSes into single equivalence classes.
The resulting type carries a `LinearOrder` (from Mathlib's Antisymmetrization + IsTotal).
-/
abbrev CanonicalQuotient (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  Antisymmetrization (CanonicalReachable M₀ h_mcs₀) (· ≤ ·)

/--
The canonical quotient is nonempty (the root M₀ maps to a quotient element).
-/
instance : Nonempty (CanonicalQuotient M₀ h_mcs₀) :=
  ⟨toAntisymmetrization (· ≤ ·) CanonicalReachable.root⟩

/-!
## Quotient Element Construction and Representative Selection
-/

/--
Map a reachable MCS to its equivalence class in the canonical quotient.
-/
noncomputable def CanonicalQuotient.mk (a : CanonicalReachable M₀ h_mcs₀) :
    CanonicalQuotient M₀ h_mcs₀ :=
  toAntisymmetrization (· ≤ ·) a

/--
Get a representative CanonicalReachable element from a quotient element.
Uses Mathlib's `ofAntisymmetrization` which picks a canonical representative.
-/
noncomputable def CanonicalQuotient.repr (q : CanonicalQuotient M₀ h_mcs₀) :
    CanonicalReachable M₀ h_mcs₀ :=
  ofAntisymmetrization _ q

/--
The quotient element corresponding to the root MCS M₀.
-/
noncomputable def CanonicalQuotient.root : CanonicalQuotient M₀ h_mcs₀ :=
  CanonicalQuotient.mk CanonicalReachable.root

/--
Roundtrip: mapping to the quotient and back gives the original quotient element.
-/
theorem CanonicalQuotient.mk_repr (q : CanonicalQuotient M₀ h_mcs₀) :
    CanonicalQuotient.mk q.repr = q :=
  toAntisymmetrization_ofAntisymmetrization (· ≤ ·) q

/--
The representative's world is an MCS.
-/
theorem CanonicalQuotient.repr_is_mcs (q : CanonicalQuotient M₀ h_mcs₀) :
    SetMaximalConsistent q.repr.world :=
  q.repr.is_mcs

/--
The representative is CanonicalR-reachable from M₀.
-/
theorem CanonicalQuotient.repr_reachable (q : CanonicalQuotient M₀ h_mcs₀) :
    CanonicalR M₀ q.repr.world :=
  q.repr.reachable

/-!
## Ordering and CanonicalR Correspondence

The quotient ordering corresponds to CanonicalR between representatives.
Mathlib's `toAntisymmetrization_le_toAntisymmetrization_iff` and
`ofAntisymmetrization_le_ofAntisymmetrization_iff` provide the key interface.
-/

/--
Ordering on quotient elements is equivalent to ordering on their representatives.
-/
theorem CanonicalQuotient.repr_le_iff (q₁ q₂ : CanonicalQuotient M₀ h_mcs₀) :
    q₁ ≤ q₂ ↔ q₁.repr ≤ q₂.repr :=
  ofAntisymmetrization_le_ofAntisymmetrization_iff.symm

/--
If `q₁ ≤ q₂` in the quotient, then CanonicalR holds between their representatives.
-/
theorem CanonicalQuotient.le_implies_canonicalR (q₁ q₂ : CanonicalQuotient M₀ h_mcs₀) (h : q₁ ≤ q₂) :
    CanonicalR q₁.repr.world q₂.repr.world := by
  rwa [CanonicalQuotient.repr_le_iff] at h

/--
Strict ordering on the quotient corresponds to strict ordering on representatives.
-/
theorem CanonicalQuotient.repr_lt_iff (q₁ q₂ : CanonicalQuotient M₀ h_mcs₀) :
    q₁ < q₂ ↔ q₁.repr < q₂.repr :=
  ofAntisymmetrization_lt_ofAntisymmetrization_iff.symm

/--
Ordering is preserved when mapping to the quotient.
-/
theorem CanonicalQuotient.mk_le_mk (a b : CanonicalReachable M₀ h_mcs₀) :
    CanonicalQuotient.mk a ≤ CanonicalQuotient.mk b ↔ a ≤ b :=
  toAntisymmetrization_le_toAntisymmetrization_iff

/--
Strict ordering is preserved when mapping to the quotient.
-/
theorem CanonicalQuotient.mk_lt_mk (a b : CanonicalReachable M₀ h_mcs₀) :
    CanonicalQuotient.mk a < CanonicalQuotient.mk b ↔ a < b :=
  toAntisymmetrization_lt_toAntisymmetrization_iff

/-!
## Equivalence Class Properties

Elements identified by the quotient share GContent and agree on all G-formulas and F-formulas.
-/

/--
Mutually CanonicalR-related reachable MCSes map to the same quotient element.

This captures the fundamental property that the quotient identifies exactly the
mutually R-related elements.
-/
theorem quotient_eq_of_mutual_R (a b : CanonicalReachable M₀ h_mcs₀)
    (h_ab : CanonicalR a.world b.world) (h_ba : CanonicalR b.world a.world) :
    CanonicalQuotient.mk a = CanonicalQuotient.mk b :=
  Quotient.sound ⟨h_ab, h_ba⟩

/--
Members of the same equivalence class share GContent.

Since `GContent M = {phi | G(phi) ∈ M}`, this means mutually CanonicalR-related MCSes
agree on all G-formulas (and hence all F-formulas, since `F(phi) = neg(G(neg(phi)))`).
-/
theorem quotient_gcontent_eq (a b : CanonicalReachable M₀ h_mcs₀)
    (h_eq : CanonicalQuotient.mk a = CanonicalQuotient.mk b) :
    GContent a.world = GContent b.world := by
  have h_rel := Quotient.exact h_eq
  exact gcontent_eq_of_mutual_R a.world b.world a.is_mcs b.is_mcs h_rel.1 h_rel.2

/-!
## CanonicalR Successor Lifting

Lemmas for lifting CanonicalR successors to the quotient ordering.
-/

/--
A CanonicalR-successor of a reachable MCS maps to a quotient element that is at least as large.
-/
theorem canonicalR_successor_quotient_le (a : CanonicalReachable M₀ h_mcs₀)
    (W : Set Formula) (h_W_mcs : SetMaximalConsistent W) (h_R : CanonicalR a.world W) :
    CanonicalQuotient.mk a ≤ CanonicalQuotient.mk (a.successor W h_W_mcs h_R) := by
  rw [CanonicalQuotient.mk_le_mk]
  exact h_R

/--
A CanonicalR-successor that is NOT mutually related maps to a strictly greater quotient element.
-/
theorem canonicalR_successor_quotient_lt (a : CanonicalReachable M₀ h_mcs₀)
    (W : Set Formula) (h_W_mcs : SetMaximalConsistent W) (h_R : CanonicalR a.world W)
    (h_not_reverse : ¬CanonicalR W a.world) :
    CanonicalQuotient.mk a < CanonicalQuotient.mk (a.successor W h_W_mcs h_R) := by
  rw [CanonicalQuotient.mk_lt_mk]
  exact ⟨h_R, fun h_le => h_not_reverse h_le⟩

end Bimodal.Metalogic.Bundle
