/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import FormalSystem.Metalogic.WeakCanonical.PriorDefs

/-!
# Abstract INF Hypothesis and Prior Instantiation

Defines the abstract first/last-occurrence hypotheses `HasDefinableINF` and
`HasDefinableSUP`, following Rabinovich 2014 Section 5. These capture the
property that for any TL-definable predicate, first (resp. last) occurrences
in an interval are "definable" in a sense adequate for the negation closure
argument.

## Abstract Hypotheses

The key property needed for Rabinovich's negation closure (Lemma 5.1) is:
given a TL-definable predicate P and an interval (z0, z1), if P occurs
somewhere in (z0, z1), then there exists a "definable infimum point" r0
near the first occurrence satisfying:
- z0 < r0 <= z1
- P does not hold in (z0, r0) (or more precisely, in the open interval)
- Either P(r0) holds (attained infimum) or K+(P)(r0) holds (P holds
  arbitrarily close from above)

where K+(P) is the "holds arbitrarily soon after" operator, TL-definable
as ¬(⊤ U ¬P) ∧ ¬P (i.e., P is dense to the right but does not hold at
the point itself). See Rabinovich eq 5.2.

## Prior Instantiation

For Prior structures (satisfying `SemanticPriorUZ`), first occurrences
are attained: the UZ axiom directly gives a point where P holds, with ¬P
between the current point and that first occurrence. The P(r0) disjunct
holds outright, and the K+ disjunct is vacuous.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5, eq (5.2)
- Rabinovich 2014, Proposition 4.2 (negation closure uses INF/SUP)
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## `kplus` — this tree's operator, and how it differs from the sources' `K⁺`

**This section's operator is NOT Reynolds' or Rabinovich's `K⁺`.** It is strictly stronger, by
one added conjunct. The doubt recorded in earlier drafts of this comment block — *"the Rabinovich
paper uses the notation differently"* — was correct, and is resolved here.

**What the sources define**, read verbatim from the corpus:

* Rabinovich 2014, `K⁺` definition, PDF p.3: *"`K+(F)` (respectively, `K−(F)`) is an abbreviation
  for `¬((¬F)UntilTrue)` (respectively, `¬((¬F)SinceTrue)`)"*, and semantically in the same
  passage: *"(3) `K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`"*
  (and *"(2) `K−(F)` holds at a moment `t` iff `t = sup({t′ | t′ < t and F holds at t′})`"*).
* Reynolds 1992, abbreviation table §1, printed p.168: `K⁺A` — *"for `¬U(⊤, ¬A)`"* — reading
  *"`A` will be true arbitrarily soon"*; `K⁻A` for `¬S(⊤,¬A)`. Corroborated by
  Gabbay-Hodkinson-Reynolds 1994 §10.3.1 (`K⁺q = ¬U(⊤,¬q)`).

Rabinovich's `Until` takes its eventuality as the *second* argument, so his `(¬F) Until True` is
Reynolds' `U(⊤,¬F)`: the two abbreviations are the same operator under mirrored argument
conventions. **Neither carries a `¬F` conjunct at the point of evaluation.**

**Where the source-exact spellings live in this tree:**

* `Formula.kPlus` / `Formula.kMinus` (`FormalSystem/Syntax/Formula.lean:180`, `:193`) — the
  object-level source-exact spelling, `(untl ⊤ φ.neg).neg`, carrying the **name-collision
  warning at `Formula.lean:163-179`** which says of `kplusFormula` below that *"substituting one
  for the other silently transcribes a different axiom"*. `Axiom.prior_U_gap`
  (`ProofSystem/Axioms.lean:377`), `Axiom.prior_S_gap` (`:387`) and `Axiom.sep` (`:390`) are
  stated with these.
* `kplusOpen` / `kminusOpen` (`Kamp/KPlusFaithful.lean`) — their `Prop`-level reading, together
  with the bridge lemmas `kPlus_formula_correct` / `kMinus_formula_correct`. `kplusOpen` is
  exactly `kplus` below **without** its first conjunct, and
  `kplus_iff_not_and_kplusOpen` states the relation.

**What `kplus` below is.** The unwinding recorded in earlier drafts of this comment is correct as
arithmetic and is retained: `(⊤ U ¬P)(t) = ∃ s > t, ∀ r ∈ (t,s), ¬P(r)` — a *gap* in `P` above
`t`, not `F(¬P)` — so `¬(⊤ U ¬P)(t) = ∀ s > t, ∃ r ∈ (t,s), P(r)`, "`P` is dense above `t`".
That last formula **is** the sources' `K⁺`. `kplus` conjoins `¬P(t)` to it. The extra conjunct is
this tree's addition; it is not attributable to either paper, and it is what
`hasDedekindINF_fails_of_interval_witness` (`Kamp/DedekindINFDense.lean:455`) turns on.

**`kplus` is not edited.** It is internally coherent with `kplusFormula` — `kplus_formula_correct`
(`Kamp/Lemma53.lean:162`) proves them equivalent — and the discrete pipeline depends on both. The
mismatch is external: the carrier apparatus built on `kplus` transcribes a different `K⁺` from the
one the axioms are stated with. `Kamp/KPlusFaithful.lean` supplies the faithful carrier beside it
and the shims relating the two; neither this file's statements nor its proofs change.
-/

/-- K+(P)(t) **as this tree defines it — not as the sources define it**: `P` holds arbitrarily
    soon after `t`, **and** `P` does not hold at `t`.

    Semantically: `¬P(t) ∧ ∀ s > t, ∃ r ∈ (t, s), P(r)`.
    TL-definable as `kplusFormula P = P.neg ∧ ¬(⊤ U P.neg)`.

    **The first conjunct is this tree's addition.** Rabinovich's `K⁺` (PDF p.3, Definition (3):
    *"`K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`"*) and
    Reynolds' (printed p.168: `K⁺A` for `¬U(⊤,¬A)`) are the second conjunct alone. The
    source-exact operator is `kplusOpen` (`Kamp/KPlusFaithful.lean`), the `Prop`-level reading of
    `Formula.kPlus` (`Syntax/Formula.lean:180`); see the name-collision warning at
    `Formula.lean:163-179` and this section's comment block above. `kplus` is strictly stronger,
    and `kplus_iff_not_and_kplusOpen` states the difference exactly. -/
def kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ¬TemporalTruth M atomMap t P ∧
  ∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r < s ∧ TemporalTruth M atomMap r P

/-- K+(P) is TL-definable: the formula P.neg ∧ ¬(⊤ U P.neg). -/
noncomputable def kplusFormula (P : Formula) : Formula :=
  Formula.and P.neg (Formula.imp (Formula.untl Formula.top P.neg) Formula.bot)

/-- K-(P)(t) **as this tree defines it — not as the sources define it**: the dual of `kplus`,
    for the Since direction. `P` holds arbitrarily close before `t`, **and** not at `t` itself.

    Same caveat as `kplus`: the first conjunct is this tree's addition. Rabinovich's `K⁻`
    (PDF p.3, Definition (2): *"`K−(F)` holds at a moment `t` iff
    `t = sup({t′ | t′ < t and F holds at t′})`"*) and Reynolds' (printed p.168: `K⁻A` for
    `¬S(⊤,¬A)`) are the second conjunct alone. The source-exact operator is `kminusOpen`
    (`Kamp/KPlusFaithful.lean`), the `Prop`-level reading of `Formula.kMinus`
    (`Syntax/Formula.lean:193`). -/
def kminus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ¬TemporalTruth M atomMap t P ∧
  ∀ s : M.carrier, s < t → ∃ r : M.carrier, s < r ∧ r < t ∧ TemporalTruth M atomMap r P

/-! ## Abstract INF/SUP Hypotheses -/

/-- A structure has definable infima for TL-predicates:
    for any TL-definable predicate P and interval (z0, z1),
    if P occurs somewhere in (z0, z1), then there exists r0 with z0 < r0 ≤ z1
    such that P does not hold in (z0, r0) and either P(r0) or K+(P)(r0).

    Note: r0 < z1 is the strict version (adequate for the proof when z1 is
    the right boundary). We use r0 ≤ z1 to handle the case where the first
    occurrence is at the right boundary. -/
structure HasDefinableINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is a first-occurrence point r0. -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 ≤ z1 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬TemporalTruth M atomMap y P) ∧
      (TemporalTruth M atomMap r0 P ∨ kplus M atomMap P r0)

/-- A structure has definable suprema for TL-predicates:
    dual of `HasDefinableINF`, for the Since direction. -/
structure HasDefinableSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is a last-occurrence point r0. -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    ∃ r0 : M.carrier, z0 ≤ r0 ∧ r0 < z1 ∧
      (∀ y : M.carrier, r0 < y → y < z1 → ¬TemporalTruth M atomMap y P) ∧
      (TemporalTruth M atomMap r0 P ∨ kminus M atomMap P r0)

/-! ## Prior Structure Instantiation -/

/-- Prior structures (satisfying `SemanticPriorUZ`) have definable infima.

    **Proof**: The UZ axiom directly gives an attained first occurrence.
    Given P occurring in (z0, z1), apply UZ at z0 with P to get r0 > z0
    where P(r0) holds and ¬P on (z0, r0). Since z0 < x < z1 for some x
    with P(x), the first occurrence r0 satisfies r0 ≤ x < z1, so r0 < z1
    (hence r0 ≤ z1). The P(r0) disjunct holds outright; K+(P)(r0) is vacuous. -/
theorem prior_hasDefinableINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : SemanticPriorUZ M atomMap) :
    HasDefinableINF M atomMap where
  first_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    -- Apply SemanticPriorUZ at z0 with formula P
    have h_exists : ∃ s, z0 < s ∧ TemporalTruth M atomMap s P := ⟨x, h_z0_x, h_Px⟩
    obtain ⟨r0, h_z0_r0, h_Pr0, h_neg⟩ := h_UZ z0 P h_exists
    -- r0 is the first occurrence of P above z0
    -- We need r0 ≤ z1. Since P(r0) and r0 is the FIRST occurrence above z0,
    -- and x > z0 with P(x), we have r0 ≤ x < z1.
    have h_r0_le_x : r0 ≤ x := by
      by_contra h_gt
      push Not at h_gt
      -- r0 > x, but h_neg says ¬P on (z0, r0), and z0 < x < r0, so ¬P(x)
      have := h_neg x h_z0_x h_gt
      -- But h_neg gives TemporalTruth at P.neg, which is ¬TemporalTruth at P
      simp only [Formula.neg, TemporalTruth] at this
      exact this h_Px
    exact ⟨r0, h_z0_r0, le_trans h_r0_le_x (le_of_lt h_x_z1),
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, TemporalTruth] at this
             exact this,
           Or.inl h_Pr0⟩

/-- Prior structures (satisfying `SemanticPriorSZ`) have definable suprema.
    Dual of `prior_hasDefinableINF`. -/
theorem prior_hasDefinableSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : SemanticPriorSZ M atomMap) :
    HasDefinableSUP M atomMap where
  last_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    -- Apply SemanticPriorSZ at z1 with formula P
    have h_exists : ∃ s, s < z1 ∧ TemporalTruth M atomMap s P := ⟨x, h_x_z1, h_Px⟩
    obtain ⟨r0, h_r0_z1, h_Pr0, h_neg⟩ := h_SZ z1 P h_exists
    -- r0 is the last occurrence of P below z1
    -- We need z0 ≤ r0. Since P(r0) is the last occ and x < z1 with P(x), r0 ≥ x > z0.
    have h_x_le_r0 : x ≤ r0 := by
      by_contra h_gt
      push Not at h_gt
      have := h_neg x h_gt h_x_z1
      simp only [Formula.neg, TemporalTruth] at this
      exact this h_Px
    exact ⟨r0, le_trans (le_of_lt h_z0_x) h_x_le_r0, h_r0_z1,
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, TemporalTruth] at this
             exact this,
           Or.inl h_Pr0⟩

/-! ## Attained INF (Specialized for Prior Structures)

For Prior structures, the first occurrence is always attained (P(r0) holds directly).
The K+ disjunct is vacuous. This simplification avoids the limit-point case analysis
needed for general Dedekind-complete chains. -/

/-- A structure has attained infima: like `HasDefinableINF`, but the first occurrence
    is always attained (P(r0) holds). No K+ case. Strictly stronger than `HasDefinableINF`. -/
structure HasAttainedINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is an attained first-occurrence point r0
      with P(r0) and ¬P on (z0, r0). -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → ¬TemporalTruth M atomMap y P) ∧
      TemporalTruth M atomMap r0 P

/-- `HasAttainedINF` implies `HasDefinableINF`. -/
theorem HasAttainedINF.toHasDefinableINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedINF M atomMap) : HasDefinableINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    obtain ⟨r0, hr0_above, hr0_below, h_no_before, h_P_r0⟩ := h.first_occ P z0 z1 h_lt h_occ
    exact ⟨r0, hr0_above, le_of_lt hr0_below, h_no_before, Or.inl h_P_r0⟩

/-- Prior structures have attained infima.
    This is strictly stronger than `prior_hasDefinableINF`: the K+ case never arises. -/
theorem prior_hasAttainedINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : SemanticPriorUZ M atomMap) :
    HasAttainedINF M atomMap where
  first_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    have h_exists : ∃ s, z0 < s ∧ TemporalTruth M atomMap s P := ⟨x, h_z0_x, h_Px⟩
    obtain ⟨r0, h_z0_r0, h_Pr0, h_neg⟩ := h_UZ z0 P h_exists
    have h_r0_le_x : r0 ≤ x := by
      by_contra h_gt
      push Not at h_gt
      have := h_neg x h_z0_x h_gt
      simp only [Formula.neg, TemporalTruth] at this
      exact this h_Px
    exact ⟨r0, h_z0_r0, lt_of_le_of_lt h_r0_le_x h_x_z1,
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, TemporalTruth] at this
             exact this,
           h_Pr0⟩

/-! ## Attained SUP (Specialized for Prior Structures)

Mirror of `HasAttainedINF` for the Since direction.
For Prior structures, the last occurrence is always attained (P(r0) holds directly).
The K- disjunct is vacuous. This is the surrogate for the Dedekind-completeness
sup in Rabinovich's Corollary 5.4(2) / Lemma 5.1 Case 3 mirror. -/

/-- A structure has attained suprema: like `HasDefinableSUP`, but the last occurrence
    is always attained (P(r0) holds). No K- case. Strictly stronger than `HasDefinableSUP`. -/
structure HasAttainedSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- For any TL-definable predicate P and interval (z0, z1), if P occurs
      somewhere in (z0, z1), then there is an attained last-occurrence point r0
      with P(r0) and ¬P on (r0, z1). -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      (∀ y : M.carrier, r0 < y → y < z1 → ¬TemporalTruth M atomMap y P) ∧
      TemporalTruth M atomMap r0 P

/-- Prior structures have attained suprema.
    Mechanical mirror of `prior_hasAttainedINF`, consuming `SemanticPriorSZ`
    in place of `SemanticPriorUZ`. The K- case never arises. -/
theorem prior_hasAttainedSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : SemanticPriorSZ M atomMap) :
    HasAttainedSUP M atomMap where
  last_occ := by
    intro P z0 z1 _h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    have h_exists : ∃ s, s < z1 ∧ TemporalTruth M atomMap s P := ⟨x, h_x_z1, h_Px⟩
    obtain ⟨r0, h_r0_z1, h_Pr0, h_neg⟩ := h_SZ z1 P h_exists
    have h_x_le_r0 : x ≤ r0 := by
      by_contra h_gt
      push Not at h_gt
      have := h_neg x h_gt h_x_z1
      simp only [Formula.neg, TemporalTruth] at this
      exact this h_Px
    exact ⟨r0, lt_of_lt_of_le h_z0_x h_x_le_r0, h_r0_z1,
           fun y hy1 hy2 => by
             have := h_neg y hy1 hy2
             simp only [Formula.neg, TemporalTruth] at this
             exact this,
           h_Pr0⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
