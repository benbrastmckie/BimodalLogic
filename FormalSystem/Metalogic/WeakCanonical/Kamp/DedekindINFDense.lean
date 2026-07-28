/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.DedekindINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation
import FormalSystem.Metalogic.WeakCanonical.PriorDefsDense

/-!
# The first-occurrence carrier over a *dense* Prior structure

This module derives Rabinovich's eq (5.2) first-occurrence carrier from the **dense** Prior
hypotheses `SemanticPriorU` / `SemanticPriorS` (`PriorDefsDense.lean`) — with **no** discreteness
assumption and **no** attainment assumption. It is the dense sibling of `prior_hasDedekindINF`
(`DedekindINF.lean:232`), which is a one-liner off `prior_hasAttainedINF` and therefore consumes
the *integer* hypothesis `SemanticPriorUZ`, refuted on every dense flow by
`semanticPriorUZ_fails_of_interval_witness` (`PriorDefsDense.lean:271`).

`DedekindINF.lean` and `PriorINF.lean` are **read, not edited** by this module.

## The endpoint guard, and why it is not optional

The target was originally the unguarded `HasDedekindINF` (`DedekindINF.lean:136`). **That
statement is false over a dense Prior structure**, and this module proves it false rather than
leaving it to be discovered inside a later proof:
`hasDedekindINF_fails_of_interval_witness` refutes it on *any* densely ordered flow carrying a
formula that holds at a point `z₀` **and** throughout an interval `(z₀,z₁)` above it, and
`hasDedekindINF_fails_on_dense_window` instantiates that at Phase 9's `denseWindowFlow` — a
structure which satisfies `SemanticPriorU` and `SemanticPriorS` outright. Both disjuncts fail
there for structural reasons:

* the **left** disjunct `kplus M atomMap P z₀` is unavailable because `kplus`
  (`PriorINF.lean:86`) demands `¬P(z₀)` as its first conjunct, and `P(z₀)` holds;
* the **right** disjunct demands a `P`-free interval `(z₀,r₀)`, which density forbids when `P`
  holds throughout `(z₀,z₁)`.

The situation is Rabinovich's `r₀ = z₀` subcase with `P` true at `z₀`, which this tree's `kplus`
cannot express. The repair is to state the hypothesis under which the source's own claim is
correct. Rabinovich writes (PDF p.8) *"Note that `r₀ = z₀` iff `K⁺(P₁)(z₀)`"*; read literally
that biconditional is false — its left-to-right direction needs `¬P₁(z₀)`, since `K⁺` carries
`¬P₁(z₀)` in its first conjunct while `r₀ = inf{z ∈ (z₀,z₁) | P₁(z)} = z₀` does not. In
Rabinovich's Lemma 5.3 the infimum is always taken at a point of the negation chain at which the
relevant predicate fails, so the hypothesis is discharged by his construction and never appears
in his prose. `HasGuardedDedekindINF` below carries it explicitly.

**The guard is a hypothesis, not a weakening of the conclusion.** The conclusion is
`HasDedekindINF`'s disjunction verbatim, character for character. Nothing is softened, no
`sorry` stands anywhere in this module, and the derivation is complete from `SemanticPriorU`
alone.

Consuming direction: `HasDedekindINF.toHasGuardedDedekindINF` shows the guarded carrier is
*implied* by the unguarded one, so every landed supplier of `HasDedekindINF` — and hence, via
`HasAttainedINF.toHasDedekindINF` / `HasDefinableINF.toHasDedekindINF` (`DedekindINF.lean:172`,
`:185`), the whole discrete pipeline — supplies the guarded carrier too. A consumer written
against `HasGuardedDedekindINF` therefore serves the discrete and the dense instance at once;
`hasGuardedDedekindINF_not_implies_hasDedekindINF` records that the converse fails, so the
guarded carrier is strictly the weaker of the two.

## What this carrier EXCLUDES (Rule 6)

`HasGuardedDedekindINF` says nothing whatever about intervals whose left endpoint satisfies `P`.
On a dense flow that is not a gap in the transcription but the true state of affairs: there is no
first occurrence to name, `K⁺` is definitionally inapplicable, and
`hasDedekindINF_fails_of_interval_witness` proves that *no* carrier of `HasDedekindINF`'s exact
shape can cover that case. Any downstream consumer must therefore establish `¬P(z₀)` at its call
site — for the negation-chain construction of Rabinovich Lemma 5.3 this is the construction's own
invariant, not a new obligation.

## Non-vacuity

`hasGuardedDedekindINF_of_dense_window` / `hasGuardedDedekindSUP_of_dense_window` instantiate the
two theorems at `denseWindowFlow`, whose Prior-U antecedent is genuinely reachable
(`densePriorU_antecedent_reachable`, `PriorDefsDense.lean:391`). Both disjuncts of the conclusion
are reachable there: `denseWindow_kplus_at_zero` lands the **left** one at `z₀ = 0`, and
`denseWindow_guardedINF_right_disjunct` lands the **right** one at `z₀ = -1`, so neither
alternative is dead weight.

## References

- Rabinovich 2014, *A Proof of Kamp's Theorem*, Lemma 5.3 Case 2 and eq (5.2), **PDF p.8**
  (cited by PDF page only: the `.md` conversion of this paper is corrupt). Verbatim:
  `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀} ¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))`.
- Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
  **Prior-U / Prior-S, printed p.168**: `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p),p)` and its mirror. The
  derivations below instantiate Prior-U at `p := ¬P` — in words: *the guard says `¬P` holds at
  `z₀`, failure of `K⁺(P)(z₀)` says `¬P` persists throughout some initial stretch above `z₀`
  (Prior-U's first antecedent `U(⊤,¬P)`), and the occurrence of `P` inside `(z₀,z₁)` is
  Prior-U's second antecedent `F¬¬P`; Prior-U's conclusion `U(P ∨ K⁺(P), ¬P)(z₀)` is then eq
  (5.2) verbatim.*
- The endpoint guard itself, and the refutation of the unguarded statement, are **original glue**:
  they are a formalization-level correction to the biconditional quoted above, prompted by a
  machine-checked counterexample, and appear in neither source.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## The guarded carrier -/

/-- **Rabinovich's eq (5.2) carrier with the endpoint guard** (PDF p.8).

    Identical to `HasDedekindINF` (`DedekindINF.lean:136`) except for the added hypothesis
    `¬P(z₀)`. That hypothesis is exactly what makes the paper's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"*
    true: `kplus` (`PriorINF.lean:86`) carries `¬P(z₀)` in its first conjunct, so without the
    guard the `r₀ = z₀` subcase with `P` true at `z₀` is expressible by neither disjunct — see
    `hasDedekindINF_fails_of_interval_witness`.

    The conclusion is `HasDedekindINF.first_occ`'s disjunction verbatim. -/
structure HasGuardedDedekindINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The faithful disjunction, under the guard `¬P(z₀)`: the first-occurrence infimum is either
      at `z₀` (as `K⁺(P)(z₀)`) or is an eq (5.2) point strictly inside `(z₀,z₁)`. -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    ¬TemporalTruth M atomMap z0 P →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    kplus M atomMap P z0 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → ¬TemporalTruth M atomMap y P) ∧
        (TemporalTruth M atomMap r0 P ∨ kplus M atomMap P r0))

/-- The `Since`-direction dual of `HasGuardedDedekindINF`, guarded at the **right** endpoint.

    `kminus` (`PriorINF.lean:98`) carries `¬P(z₁)` in its first conjunct, so the mirror of the
    guard is `¬P(z₁)`. The conclusion is `HasDedekindSUP.last_occ`'s disjunction verbatim. -/
structure HasGuardedDedekindSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The faithful disjunction, mirrored, under the guard `¬P(z₁)`. -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    ¬TemporalTruth M atomMap z1 P →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    kminus M atomMap P z1 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, r0 < y → y < z1 → ¬TemporalTruth M atomMap y P) ∧
        (TemporalTruth M atomMap r0 P ∨ kminus M atomMap P r0))

/-! ## The trichotomy: the hypothesis-free form

`HasGuardedDedekindINF` discharges its guard at the *call* site. Every existing consumer of
`HasDedekindINF.first_occ` in this tree reaches it from a `by_cases` on whether `P` occurs at an
**interior** point of `(z₀,z₁)` and has no hypothesis whatever about `z₀`, so the guard is not
dischargeable there. The form such a consumer can actually use puts the missing case in the
*conclusion* instead: a third disjunct `P(z₀)`.

That trichotomy is Rabinovich's own case split on `r₀ = inf{z ∈ (z₀,z₁) | P₁(z)}` before he
collapses its first two cases:

* `r₀ = z₀` with `P₁(z₀)` — the disjunct `P(z₀)`;
* `r₀ = z₀` with `¬P₁(z₀)`, so `P₁` accumulates at `z₀` from above — the disjunct `K⁺(P)(z₀)`;
* `r₀ > z₀` — eq (5.2).

The paper's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* merges the first two, which is sound exactly under his
construction's standing `¬P₁(z₀)`. `HasDenseDedekindINF` keeps them apart, and is therefore the
faithful general statement rather than a weakening: it is hypothesis-free and, given `¬P(z₀)`,
collapses back to `HasDedekindINF`'s two-disjunct conclusion
(`HasDenseDedekindINF.toHasGuardedDedekindINF`). -/

/-- **The hypothesis-free first-occurrence carrier over a dense flow**: Rabinovich's full case
    split on `r₀ = inf{z ∈ (z₀,z₁) | P(z)}`, with the `r₀ = z₀` case kept split into its two
    genuine subcases (`P(z₀)`, and `K⁺(P)(z₀)`) instead of merged.

    This is the form downstream consumers can use unchanged: it asks nothing at the call site
    that `HasDedekindINF` did not already ask, and pays for the extra generality with one extra
    case in the conclusion — a case that is genuinely reachable on a dense flow
    (`hasDedekindINF_fails_on_dense_window` is precisely a point where it is the only one that
    holds). -/
structure HasDenseDedekindINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The faithful trichotomy: the first occurrence at-or-above `z₀` is `z₀` itself (either
      because `P` holds there, or as `K⁺(P)(z₀)`), or is an eq (5.2) point inside `(z₀,z₁)`. -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    TemporalTruth M atomMap z0 P ∨
      kplus M atomMap P z0 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → ¬TemporalTruth M atomMap y P) ∧
        (TemporalTruth M atomMap r0 P ∨ kplus M atomMap P r0))

/-- The `Since`-direction dual of `HasDenseDedekindINF`, with the extra disjunct at `z₁`. -/
structure HasDenseDedekindSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The faithful trichotomy, mirrored. -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    TemporalTruth M atomMap z1 P ∨
      kminus M atomMap P z1 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, r0 < y → y < z1 → ¬TemporalTruth M atomMap y P) ∧
        (TemporalTruth M atomMap r0 P ∨ kminus M atomMap P r0))

/-- The trichotomy collapses to the guarded two-disjunct conclusion under the guard. -/
theorem HasDenseDedekindINF.toHasGuardedDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDenseDedekindINF M atomMap) : HasGuardedDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_guard h_occ := by
    rcases h.first_occ P z0 z1 h_lt h_occ with h_at | h_rest
    · exact absurd h_at h_guard
    · exact h_rest

/-- The `SUP` mirror: the trichotomy collapses under the right-endpoint guard. -/
theorem HasDenseDedekindSUP.toHasGuardedDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDenseDedekindSUP M atomMap) : HasGuardedDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_guard h_occ := by
    rcases h.last_occ P z0 z1 h_lt h_occ with h_at | h_rest
    · exact absurd h_at h_guard
    · exact h_rest

/-- Conversely, the guarded carrier yields the trichotomy: split on `P(z₀)`. So the two are
    interderivable, and the trichotomy is exactly `HasGuardedDedekindINF` with its side condition
    moved from the hypothesis into the conclusion. -/
theorem HasGuardedDedekindINF.toHasDenseDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasGuardedDedekindINF M atomMap) : HasDenseDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    by_cases h_at : TemporalTruth M atomMap z0 P
    · exact Or.inl h_at
    · exact Or.inr (h.first_occ P z0 z1 h_lt h_at h_occ)

/-- The `SUP` mirror of `HasGuardedDedekindINF.toHasDenseDedekindINF`. -/
theorem HasGuardedDedekindSUP.toHasDenseDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasGuardedDedekindSUP M atomMap) : HasDenseDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := by
    by_cases h_at : TemporalTruth M atomMap z1 P
    · exact Or.inl h_at
    · exact Or.inr (h.last_occ P z0 z1 h_lt h_at h_occ)

/-! ## Compatibility with the landed carriers

The guarded carrier is *implied* by the unguarded one, so it can be consumed wherever the landed
ones are supplied. Composed with `HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`) and
`HasDefinableINF.toHasDedekindINF` (`:185`), these give the guarded carrier on the whole discrete
pipeline for free. -/

/-- `HasDedekindINF` implies the guarded carrier: the guard is simply discarded. -/
theorem HasDedekindINF.toHasGuardedDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDedekindINF M atomMap) : HasGuardedDedekindINF M atomMap where
  first_occ P z0 z1 h_lt _ h_occ := h.first_occ P z0 z1 h_lt h_occ

/-- `HasDedekindSUP` implies the guarded carrier: the guard is simply discarded. -/
theorem HasDedekindSUP.toHasGuardedDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDedekindSUP M atomMap) : HasGuardedDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt _ h_occ := h.last_occ P z0 z1 h_lt h_occ

/-- `HasDedekindINF` implies the trichotomy: its own two disjuncts are the trichotomy's second
    and third. Composed with the shims at `DedekindINF.lean:172`/`:185`, the whole discrete
    pipeline supplies `HasDenseDedekindINF`, so a consumer re-based onto the trichotomy serves the
    discrete and the dense instance at once. -/
theorem HasDedekindINF.toHasDenseDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDedekindINF M atomMap) : HasDenseDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := Or.inr (h.first_occ P z0 z1 h_lt h_occ)

/-- `HasDedekindSUP` implies the mirrored trichotomy. -/
theorem HasDedekindSUP.toHasDenseDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDedekindSUP M atomMap) : HasDenseDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := Or.inr (h.last_occ P z0 z1 h_lt h_occ)

/-- `HasAttainedINF` implies the guarded carrier, through `HasDedekindINF`. -/
theorem HasAttainedINF.toHasGuardedDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedINF M atomMap) : HasGuardedDedekindINF M atomMap :=
  h.toHasDedekindINF.toHasGuardedDedekindINF

/-- `HasAttainedSUP` implies the guarded carrier, through `HasDedekindSUP`. -/
theorem HasAttainedSUP.toHasGuardedDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedSUP M atomMap) : HasGuardedDedekindSUP M atomMap :=
  h.toHasDedekindSUP.toHasGuardedDedekindSUP

/-! ## The derivation from the dense Prior hypotheses

Rabinovich 2014, Lemma 5.3 Case 2 and eq (5.2), PDF p.8, obtained from Reynolds' Prior-U
(printed p.168) instantiated at `p := ¬P`. No discreteness, no attainment, no flow completeness:
`SemanticPriorU` alone. -/

/-- **`SemanticPriorU` yields the guarded eq (5.2) carrier** (Rabinovich 2014, Lemma 5.3 Case 2
    and eq (5.2), PDF p.8; derived from Reynolds 1992, Prior-U, printed p.168).

    The derivation instantiates Prior-U at `p := ¬P`, following the paper's Case 2 exactly:

    1. If `K⁺(P)(z₀)` holds, take the left disjunct and stop — this is the paper's
       *"Subcase `r₀ = z₀`"*.
    2. Otherwise, since the guard already supplies `¬P(z₀)`, the failure of `K⁺(P)(z₀)` must be
       in its second conjunct: `¬P` holds throughout some initial stretch above `z₀`. That is
       Prior-U's first antecedent `U(⊤,¬P)(z₀)`.
    3. `P` occurs inside `(z₀,z₁)`, which is Prior-U's second antecedent `F¬¬P(z₀)`.
    4. Prior-U's conclusion `U(P ∨ K⁺(P), ¬P)(z₀)` supplies `r₀ > z₀` with `¬P` throughout
       `(z₀,r₀)` and `P(r₀) ∨ K⁺(P)(r₀)`.
    5. `r₀ < z₁`, because `P` occurs at some `x ∈ (z₀,z₁)` while `¬P` holds on `(z₀,r₀)`, forcing
       `r₀ ≤ x < z₁`.
    6. Steps 4-5 are eq (5.2) verbatim — the right disjunct.

    **This derivation does not route through `prior_hasAttainedINF` (`PriorINF.lean:230`) and
    therefore carries no discreteness.** That is the whole point: `prior_hasAttainedINF` consumes
    `SemanticPriorUZ`, which `semanticPriorUZ_fails_of_interval_witness`
    (`PriorDefsDense.lean:271`) refutes on every densely ordered flow carrying a formula true
    throughout an open interval. No attainment hypothesis and no completeness hypothesis on the
    flow is used here either. -/
theorem prior_hasGuardedDedekindINF_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_U : SemanticPriorU M atomMap) : HasGuardedDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_guard h_occ := by
    -- Step 1: the paper's `Subcase r₀ = z₀`.
    by_cases h_kplus : kplus M atomMap P z0
    · exact Or.inl h_kplus
    refine Or.inr ?_
    -- Step 2: `¬K⁺(P)(z₀)` plus the guard `¬P(z₀)` is `U(⊤,¬P)(z₀)`.
    have h_gap : ∃ s : M.carrier, z0 < s ∧
        ∀ r : M.carrier, z0 < r → r < s → TemporalTruth M atomMap r P.neg := by
      by_contra h_no
      refine h_kplus ⟨h_guard, ?_⟩
      intro s hs
      by_contra h_none
      refine h_no ⟨s, hs, ?_⟩
      intro r hr hrs
      rw [temporal_truth_neg]
      exact fun hPr => h_none ⟨r, hr, hrs, hPr⟩
    -- Step 3: the occurrence of `P` inside `(z₀,z₁)` is `F¬¬P(z₀)`.
    obtain ⟨x, h_z0x, h_xz1, h_Px⟩ := h_occ
    have h_F : ∃ u : M.carrier, z0 < u ∧ ¬TemporalTruth M atomMap u P.neg :=
      ⟨x, h_z0x, by rw [temporal_truth_neg]; exact fun h => h h_Px⟩
    -- Step 4: Prior-U at `p := ¬P`.
    obtain ⟨s, h_z0s, h_on, h_end⟩ := h_U z0 P.neg h_gap h_F
    have h_none : ∀ y : M.carrier, z0 < y → y < s → ¬TemporalTruth M atomMap y P := by
      intro y hy hys
      have hy' := h_on y hy hys
      rw [temporal_truth_neg] at hy'
      exact hy'
    -- Step 5: `r₀ < z₁`, from the occurrence at `x` and `¬P` on `(z₀,r₀)`.
    have h_sz1 : s < z1 :=
      lt_of_le_of_lt (not_lt.mp fun hxs => h_none x h_z0x hxs h_Px) h_xz1
    -- Step 6: eq (5.2) verbatim.
    refine ⟨s, h_z0s, h_sz1, h_none, ?_⟩
    rcases h_end with h_notneg | ⟨h_neg, h_acc⟩
    · rw [temporal_truth_neg] at h_notneg
      exact Or.inl (not_not.mp h_notneg)
    · rw [temporal_truth_neg] at h_neg
      refine Or.inr ⟨h_neg, ?_⟩
      intro u hu
      obtain ⟨r, hsr, hru, hr⟩ := h_acc u hu
      rw [temporal_truth_neg] at hr
      exact ⟨r, hsr, hru, not_not.mp hr⟩

/-- **`SemanticPriorS` yields the guarded eq (5.2) carrier, mirrored** (Rabinovich 2014, Lemma 5.3
    Case 2 and eq (5.2) mirrored, PDF p.8; derived from Reynolds 1992, Prior-S, printed p.168).

    The exact mirror of `prior_hasGuardedDedekindINF_dense`, instantiating Prior-S at `p := ¬P`:
    the guard `¬P(z₁)` plus failure of `K⁻(P)(z₁)` gives Prior-S's first antecedent `S(⊤,¬P)(z₁)`,
    the occurrence of `P` inside `(z₀,z₁)` gives `P¬¬P(z₁)`, and Prior-S's conclusion
    `S(P ∨ K⁻(P), ¬P)(z₁)` is the mirrored eq (5.2).

    As with the `INF` direction, this routes through neither `prior_hasAttainedSUP` nor any
    completeness hypothesis on the flow, and so carries no discreteness. -/
theorem prior_hasGuardedDedekindSUP_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_S : SemanticPriorS M atomMap) : HasGuardedDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_guard h_occ := by
    by_cases h_kminus : kminus M atomMap P z1
    · exact Or.inl h_kminus
    refine Or.inr ?_
    have h_gap : ∃ s : M.carrier, s < z1 ∧
        ∀ r : M.carrier, s < r → r < z1 → TemporalTruth M atomMap r P.neg := by
      by_contra h_no
      refine h_kminus ⟨h_guard, ?_⟩
      intro s hs
      by_contra h_none
      refine h_no ⟨s, hs, ?_⟩
      intro r hr hrz
      rw [temporal_truth_neg]
      exact fun hPr => h_none ⟨r, hr, hrz, hPr⟩
    obtain ⟨x, h_z0x, h_xz1, h_Px⟩ := h_occ
    have h_P : ∃ u : M.carrier, u < z1 ∧ ¬TemporalTruth M atomMap u P.neg :=
      ⟨x, h_xz1, by rw [temporal_truth_neg]; exact fun h => h h_Px⟩
    obtain ⟨s, h_sz1, h_on, h_end⟩ := h_S z1 P.neg h_gap h_P
    have h_none : ∀ y : M.carrier, s < y → y < z1 → ¬TemporalTruth M atomMap y P := by
      intro y hy hyz
      have hy' := h_on y hy hyz
      rw [temporal_truth_neg] at hy'
      exact hy'
    have h_z0s : z0 < s :=
      lt_of_lt_of_le h_z0x (not_lt.mp fun hsx => h_none x hsx h_xz1 h_Px)
    refine ⟨s, h_z0s, h_sz1, h_none, ?_⟩
    rcases h_end with h_notneg | ⟨h_neg, h_acc⟩
    · rw [temporal_truth_neg] at h_notneg
      exact Or.inl (not_not.mp h_notneg)
    · rw [temporal_truth_neg] at h_neg
      refine Or.inr ⟨h_neg, ?_⟩
      intro u hu
      obtain ⟨r, hur, hrs, hr⟩ := h_acc u hu
      rw [temporal_truth_neg] at hr
      exact ⟨r, hur, hrs, not_not.mp hr⟩

/-- **`SemanticPriorU` yields the hypothesis-free trichotomy** — the headline result of this
    module, and the form downstream consumes.

    Immediate from `prior_hasGuardedDedekindINF_dense` by splitting on `P(z₀)`: where `P` holds at
    `z₀` the first disjunct fires, and where it does not the guard is discharged and the guarded
    carrier supplies `HasDedekindINF`'s own two-disjunct conclusion verbatim.

    No discreteness, no attainment, no completeness of the flow. -/
theorem prior_hasDenseDedekindINF_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_U : SemanticPriorU M atomMap) : HasDenseDedekindINF M atomMap :=
  (prior_hasGuardedDedekindINF_dense M atomMap h_U).toHasDenseDedekindINF

/-- **`SemanticPriorS` yields the hypothesis-free trichotomy, mirrored.** -/
theorem prior_hasDenseDedekindSUP_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_S : SemanticPriorS M atomMap) : HasDenseDedekindSUP M atomMap :=
  (prior_hasGuardedDedekindSUP_dense M atomMap h_S).toHasDenseDedekindSUP

/-! ## The exclusion lemma: the *unguarded* carrier is refutable on a dense flow

The dense counterpart of `semanticPriorUZ_fails_of_interval_witness` (`PriorDefsDense.lean:271`),
and the reason the guard above is a hypothesis rather than an oversight. -/

/-- **On a densely ordered flow, `HasDedekindINF` fails as soon as some formula holds at a point
    `z₀` and throughout an interval above it.**

    Both disjuncts of `HasDedekindINF.first_occ` are unavailable: the left one because `kplus`
    (`PriorINF.lean:86`) demands `¬P(z₀)`, the right one because it demands a `P`-free interval
    `(z₀,r₀)`, which density populates with points of `(z₀,z₁)` where `P` holds by hypothesis.

    This is Rabinovich's `r₀ = z₀` subcase with `P` true at `z₀` (PDF p.8). It names exactly which
    structures the *unguarded* carrier admits — those in which no formula holds both at a point
    and on an interval immediately above it, in particular the discrete ones, where the interval
    below the successor is empty — and which it forbids. -/
theorem hasDedekindINF_fails_of_interval_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hdense : ∀ x y : M.carrier, x < y → ∃ z : M.carrier, x < z ∧ z < y)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_at : TemporalTruth M atomMap z0 P)
    (h_on : ∀ y : M.carrier, z0 < y → y < z1 → TemporalTruth M atomMap y P) :
    ¬HasDedekindINF M atomMap := by
  intro h
  obtain ⟨m, h_z0m, h_mz1⟩ := hdense z0 z1 h_lt
  rcases h.first_occ P z0 z1 h_lt ⟨m, h_z0m, h_mz1, h_on m h_z0m h_mz1⟩ with
    h_left | ⟨r0, h_z0r0, h_r0z1, h_none, -⟩
  · -- `kplus` demands `¬P(z₀)`, refuted by `h_at`.
    exact h_left.1 h_at
  · -- Density puts a point of `(z₀,z₁)` inside the demanded `P`-free interval `(z₀,r₀)`.
    obtain ⟨y, h_z0y, h_yr0⟩ := hdense z0 r0 h_z0r0
    exact h_none y h_z0y h_yr0 (h_on y h_z0y (lt_trans h_yr0 h_r0z1))

/-- The `Since`-direction mirror of `hasDedekindINF_fails_of_interval_witness`: `HasDedekindSUP`
    fails on a densely ordered flow as soon as some formula holds at `z₁` and throughout an
    interval below it. `kminus` (`PriorINF.lean:98`) demands `¬P(z₁)`. -/
theorem hasDedekindSUP_fails_of_interval_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hdense : ∀ x y : M.carrier, x < y → ∃ z : M.carrier, x < z ∧ z < y)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_at : TemporalTruth M atomMap z1 P)
    (h_on : ∀ y : M.carrier, z0 < y → y < z1 → TemporalTruth M atomMap y P) :
    ¬HasDedekindSUP M atomMap := by
  intro h
  obtain ⟨m, h_z0m, h_mz1⟩ := hdense z0 z1 h_lt
  rcases h.last_occ P z0 z1 h_lt ⟨m, h_z0m, h_mz1, h_on m h_z0m h_mz1⟩ with
    h_left | ⟨r0, h_z0r0, h_r0z1, h_none, -⟩
  · exact h_left.1 h_at
  · obtain ⟨y, h_r0y, h_yz1⟩ := hdense r0 z1 h_r0z1
    exact h_none y h_r0y h_yz1 (h_on y (lt_trans h_z0r0 h_r0y) h_yz1)

/-! ## The witnesses

Instantiations at Phase 9's `denseWindowFlow` (`PriorDefsDense.lean:336`) — the real line with a
single predicate true exactly on `(0,1)`, which satisfies `SemanticPriorU` and `SemanticPriorS`
outright and whose Prior-U antecedent is genuinely reachable. -/

/-- The single atom available on `densePriorSig`, named once for the witnesses below. -/
def denseWindowAtom : Formula := Formula.atom (Atom.mkBase "p")

/-- **The guarded carrier holds on the dense window flow** — the anti-vacuity instantiation of
    `prior_hasGuardedDedekindINF_dense`. -/
theorem hasGuardedDedekindINF_of_dense_window :
    HasGuardedDedekindINF denseWindowFlow densePriorAtomMap :=
  prior_hasGuardedDedekindINF_dense _ _ semanticPriorU_of_dense_window

/-- **The guarded `SUP` carrier holds on the dense window flow** — the anti-vacuity instantiation
    of `prior_hasGuardedDedekindSUP_dense`. -/
theorem hasGuardedDedekindSUP_of_dense_window :
    HasGuardedDedekindSUP denseWindowFlow densePriorAtomMap :=
  prior_hasGuardedDedekindSUP_dense _ _ semanticPriorS_of_dense_window

/-- **The trichotomy holds on the dense window flow** — the anti-vacuity instantiation of the
    module's headline result. -/
theorem hasDenseDedekindINF_of_dense_window :
    HasDenseDedekindINF denseWindowFlow densePriorAtomMap :=
  prior_hasDenseDedekindINF_dense _ _ semanticPriorU_of_dense_window

/-- **The mirrored trichotomy holds on the dense window flow.** -/
theorem hasDenseDedekindSUP_of_dense_window :
    HasDenseDedekindSUP denseWindowFlow densePriorAtomMap :=
  prior_hasDenseDedekindSUP_dense _ _ semanticPriorS_of_dense_window

/-- **The unguarded `HasDedekindINF` is refuted on the dense window flow**, at `P` the atom,
    `z₀ = 1/2`, `z₁ = 1`: the predicate holds at `1/2` and throughout `(1/2,1)`.

    This is the machine-checked form of the finding that forced the endpoint guard. -/
theorem hasDedekindINF_fails_on_dense_window :
    ¬HasDedekindINF denseWindowFlow densePriorAtomMap :=
  hasDedekindINF_fails_of_interval_witness denseWindowFlow densePriorAtomMap
    (realFlowStructure_dense _) denseWindowAtom (1 / 2) 1 (by norm_num)
    (by simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]; norm_num)
    (by
      intro y hy hy1
      simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]
      constructor <;> linarith)

/-- **The unguarded `HasDedekindSUP` is refuted on the dense window flow**, at `z₀ = 0`,
    `z₁ = 1/2`: the predicate holds at `1/2` and throughout `(0,1/2)`. -/
theorem hasDedekindSUP_fails_on_dense_window :
    ¬HasDedekindSUP denseWindowFlow densePriorAtomMap :=
  hasDedekindSUP_fails_of_interval_witness denseWindowFlow densePriorAtomMap
    (realFlowStructure_dense _) denseWindowAtom 0 (1 / 2) (by norm_num)
    (by simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]; norm_num)
    (by
      intro y hy hy1
      simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]
      constructor <;> linarith)

/-- **The route-critical separation, machine-checked**: a structure satisfying both dense Prior
    hypotheses which satisfies the *guarded* carrier and refutes the *unguarded* one.

    So `HasGuardedDedekindINF` is strictly weaker than `HasDedekindINF`, the guard cannot be
    dropped from `prior_hasGuardedDedekindINF_dense`, and no theorem of the form
    `SemanticPriorU M atomMap → HasDedekindINF M atomMap` exists. -/
theorem hasGuardedDedekindINF_not_implies_hasDedekindINF :
    ∃ (M : OrderedMonadicStructure densePriorSig) (atomMap : Formula → densePriorSig.preds),
      SemanticPriorU M atomMap ∧ SemanticPriorS M atomMap ∧
        HasGuardedDedekindINF M atomMap ∧ ¬HasDedekindINF M atomMap :=
  ⟨denseWindowFlow, densePriorAtomMap, semanticPriorU_of_dense_window,
    semanticPriorS_of_dense_window, hasGuardedDedekindINF_of_dense_window,
    hasDedekindINF_fails_on_dense_window⟩

/-! ### Both disjuncts are reachable

The plan requires recording which disjunct the witness lands in. It lands in either, depending on
the interval: the left one wherever the predicate accumulates at `z₀` from above without holding
there, the right one wherever it does not. -/

/-- **The left disjunct is reachable**: `K⁺(P)(0)` holds on the window flow, since the predicate
    fails at `0` and holds arbitrarily soon after it. So `hasDedekindINF_admits_kplus_shape`'s
    case (`DedekindINF.lean`) is live at a dense Prior structure, not merely at a discrete one. -/
theorem denseWindow_kplus_at_zero :
    kplus denseWindowFlow densePriorAtomMap denseWindowAtom 0 := by
  refine ⟨by simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]; norm_num, ?_⟩
  intro s hs
  have h_pos : (0 : ℝ) < min s 1 := lt_min hs one_pos
  have h_le_s : min s 1 ≤ s := min_le_left _ _
  have h_le_one : min s 1 ≤ 1 := min_le_right _ _
  refine ⟨min s 1 / 2, by linarith, by linarith, ?_⟩
  simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]
  constructor <;> linarith

/-- **The left disjunct is not always the one taken**: `K⁺(P)(-1)` fails on the window flow,
    because the predicate is absent from `(-1,-1/2)`. -/
theorem denseWindow_kplus_fails_at_neg_one :
    ¬kplus denseWindowFlow densePriorAtomMap denseWindowAtom (-1) := by
  intro h
  obtain ⟨r, _, h_r_lt, h_Pr⟩ := h.2 (-1 / 2) (by norm_num)
  simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom] at h_Pr
  linarith [h_Pr.1]

/-- **The trichotomy's endpoint disjunct is not decorative**: at `z₀ = 1/2`, `z₁ = 1` on the
    window flow, `P(z₀)` holds and **both** of `HasDedekindINF`'s disjuncts fail. This is the
    counterexample of `hasDedekindINF_fails_on_dense_window` displayed disjunct by disjunct, and
    it is the exact reason the unguarded two-disjunct carrier is unavailable here. -/
theorem denseWindow_endpoint_disjunct_forced :
    TemporalTruth denseWindowFlow densePriorAtomMap (1 / 2 : denseWindowFlow.carrier)
        denseWindowAtom ∧
      ¬(kplus denseWindowFlow densePriorAtomMap denseWindowAtom (1 / 2) ∨
        (∃ r0 : denseWindowFlow.carrier, (1 / 2 : denseWindowFlow.carrier) < r0 ∧ r0 < 1 ∧
          (∀ y : denseWindowFlow.carrier, (1 / 2 : denseWindowFlow.carrier) < y → y < r0 →
            ¬TemporalTruth denseWindowFlow densePriorAtomMap y denseWindowAtom) ∧
          (TemporalTruth denseWindowFlow densePriorAtomMap r0 denseWindowAtom ∨
            kplus denseWindowFlow densePriorAtomMap denseWindowAtom r0))) := by
  have h_half : TemporalTruth denseWindowFlow densePriorAtomMap
      (1 / 2 : denseWindowFlow.carrier) denseWindowAtom := by
    simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]; norm_num
  refine ⟨h_half, ?_⟩
  rintro (h_kplus | ⟨r0, h_lo, h_hi, h_none, -⟩)
  · exact h_kplus.1 h_half
  · refine h_none ((1 / 2 + r0) / 2) (by linarith) (by linarith) ?_
    simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]
    constructor <;> linarith

/-- **The right disjunct is reachable**: at `z₀ = -1`, `z₁ = 2` the guarded carrier must produce
    an eq (5.2) point strictly inside `(-1,2)`, since the left disjunct is refuted by
    `denseWindow_kplus_fails_at_neg_one`. -/
theorem denseWindow_guardedINF_right_disjunct :
    ∃ r0 : denseWindowFlow.carrier, (-1 : denseWindowFlow.carrier) < r0 ∧ r0 < 2 ∧
      (∀ y : denseWindowFlow.carrier, (-1 : denseWindowFlow.carrier) < y → y < r0 →
        ¬TemporalTruth denseWindowFlow densePriorAtomMap y denseWindowAtom) ∧
      (TemporalTruth denseWindowFlow densePriorAtomMap r0 denseWindowAtom ∨
        kplus denseWindowFlow densePriorAtomMap denseWindowAtom r0) := by
  rcases hasGuardedDedekindINF_of_dense_window.first_occ denseWindowAtom (-1) 2 (by norm_num)
      (by simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]; norm_num)
      ⟨1 / 2, by norm_num, by norm_num, by
        simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]; norm_num⟩ with
    h_left | h_right
  · exact absurd h_left denseWindow_kplus_fails_at_neg_one
  · exact h_right

end FormalSystem.Metalogic.WeakCanonical.Kamp
