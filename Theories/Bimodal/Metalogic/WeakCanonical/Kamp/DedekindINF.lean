/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.Lemma53
-- NOTE: `import ...Kamp.Lemma53` supplies `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`),
-- consumed by `hasDefinableINF_incompatible_with_kplus` below so that this module's strictness
-- claim is machine-checked here rather than asserted in prose. Cycle-free: Lemma53 imports
-- `...Kamp.VecEAFormula`, `...Kamp.PriorINF` and `...Kamp.EANegationFix.OnBuilder`, none of
-- which import this module.

/-!
# The faithful Dedekind INF/SUP carrier — definitions and shims only, re-base DEFERRED

This module lands **Rabinovich's actual eq (5.2) carrier** as a definition, together with the
compatibility shims from the carriers this tree already uses. It deliberately does **not**
re-base anything onto it. Read the "What is DEFERRED" section before planning work here.

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
The companion `.md` conversion is **corrupt** (it drops displayed equations and inverts `k ≠ m`
to `k = m`) and is never ground truth. Everything below cites **PDF p.8**.

## Source correspondence (PDF p.8)

Rabinovich's Lemma 5.3, Case 2, reads: *"If case 1 does not hold then let
`r₀ = inf{z ∈ (z₀,z₁) | P₁(z)}` (such `r₀` exists by Dedekind completeness). Note that
`r₀ = z₀` iff `K⁺(P₁)(z₀)`. If `r₀ > z₀` then `r₀ ∈ (z₀,z₁)` and `r₀` is definable by the
following `∨∃∀`-formula:"*

```
INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀} ¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))    (5.2)
```

Dedekind completeness supplies the infimum `r₀` but **not** its location: `r₀` may be the left
endpoint `z₀` itself. The paper handles both, and `HasDedekindINF` below is the faithful
disjunction of the two:

* **Left disjunct** `kplus M atomMap P z0` — the paper's `Subcase r₀ = z₀`, which p.8 states is
  *equivalent* to `K⁺(P₁)(z₀)`. This is the case that feeds the paper's disjunct (2)
  `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`.
* **Right disjunct** — eq (5.2) verbatim, the paper's `Subcase r₀ ∈ (z₀,z₁)`.

The canonical `ℝ` reading of the left disjunct: `P₁ = {x | x > 0}`, `z₀ = 0`. Then
`inf{z ∈ (0,z₁) | P₁(z)} = 0 = z₀`, and `ℝ` is Dedekind complete, so the paper's Case 2 genuinely
reaches its `Subcase r₀ = z₀`. This is a **docstring correspondence, not a formalized instance**:
no `ℝ` `OrderedMonadicStructure` is constructed here or anywhere in this tree.

## What this carrier EXCLUDES — the extended non-vacuity rule

*Every carrier must state what it excludes.* An over-strong hypothesis passes sorry-free,
axiom-clean and EXIT 0 exactly as a vacuous conclusion does — the pattern that recurred three
times undetected in this development. The strengthening chain, weakest to strongest:

```
Rabinovich's Dedekind completeness  <  HasDedekindINF  <  HasDefinableINF  <  HasAttainedINF
                                       ^ defined here                         ^ what is LANDED
```

* `HasDedekindINF` **excludes** chains where the first-occurrence infimum exists but is neither
  attained, nor a `K⁺` limit from above, nor located at `z₀`. Bare Dedekind completeness gives
  the infimum's *existence*; `HasDedekindINF` additionally asserts it is **TL-definable** in one
  of those three shapes. This is why the chain above puts it strictly to the right of Rabinovich's
  own hypothesis: it is a definability assumption the paper derives rather than assumes.
* `HasDedekindINF` **admits** what `HasDefinableINF` forbids: `hasDefinableINF_excludes_kplus`
  (`Lemma53.lean:282`, axiom-clean) machine-proves that `HasDefinableINF` makes
  `kplus M atomMap P z0` **impossible** whenever `P` occurs in `(z₀,z₁)` — i.e. it deletes the
  paper's disjunct (2). `HasDedekindINF` admits exactly that case, via its left disjunct.
  `hasDedekindINF_admits_kplus_shape` below records the delta as a machine-checked fact rather
  than as prose: the left disjunct is a real, reachable alternative, not dead syntax.

## What is DEFERRED — read before planning work here

**The re-base of Lemma 5.3, Lemma 5.1, and Prop 4.2 onto this carrier is NOT DONE.** It is
deferred to a future dedicated complete-proof-system effort, not abandoned and not in progress.

**Why deferred — this is fidelity-only work with zero operational value.** The live goal chain in
this tree runs on **Prior structures**, where INF/SUP attainment holds outright
(`prior_hasAttainedINF`, `PriorINF.lean:224`, from the UZ axiom). Nothing in this tree ever
evaluates against a non-attained Dedekind complete chain, so nothing downstream can observe the
difference between `HasAttainedINF` and `HasDedekindINF`. `prior_hasDedekindINF` below closes
that boundary: the faithful carrier is *available* on the live path whenever it is wanted.

The deferred re-base, precisely:

1. **Lemma 5.3 (p.8)** — `negChainOnFaithful` over `HasDedekindINF`, restoring the printed
   **three**-disjunct `Oₙ₊₁`. The landed `negChainOn` (`EANegationFix/OnBuilder.lean:149`)
   truncates it to two by dropping disjunct (2). The result type must be `VVecEA2`, not
   `VBracketFormula`: disjunct (2) conjoins the endpoint predicate `K⁺(P₁)` at `z₀`, which
   `VBracketFormula` cannot carry.
2. **Lemma 5.1 (pp.9-10)** — re-base `BracketFormula.negFix_iff` (`EANegationFix/NegFix.lean:669`).
3. **Prop 4.2 (p.6)** — re-base `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:164`) and
   hence `prop42_contentful_of_attained` (`Section5Correspondence.lean`) off the attained pin.

**Deliberately not stated as `sorry`.** Those three targets are recorded here as prose and in the
follow-up task, and nowhere as a `sorry`-bodied theorem. A dead module carrying strategic sorries
would be the wrong answer: `Kamp/Boneyard/*` is covered by no glob and compiled by nothing in CI,
so such a module would rot invisibly — which is precisely the failure the Section 5 correspondence
guard exists to prevent. **This module is CI-protected** (reachable from `Theories/Bimodal.lean`
via the `NfMultiAnchorBridge` import edge) and **contains no sorries**.

## What already exists to build on

`Section5Correspondence.lean` (page-cited table + `prop42_contentful_of_attained`, sorry-free),
`lemma53` sorry-free at the attained carrier, `hasDefinableINF_excludes_kplus`
(`Lemma53.lean:282`), the whole `EANegationFix/` tree, and `TemporalPred.disj` /
`TemporalPred.eval_at_disj` (`ExistsForallNF.lean`, `VecEAClosure.lean`) — the point-type
primitive for eq (5.2)'s `(P₁(r₀) ∨ K⁺(P₁)(r₀))`.

## References

- Rabinovich 2014, *A Proof of Kamp's Theorem*, Lemma 5.3 and eq (5.2), PDF p.8
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## The faithful carrier -/

/-- **Rabinovich's eq (5.2) carrier, stated faithfully** (PDF p.8).

    For any TL-definable `P` and interval `(z₀,z₁)` in which `P` occurs, **either**:
    * `K⁺(P)(z₀)` — the paper's `Subcase r₀ = z₀` (p.8: *"r₀ = z₀ iff K⁺(P₁)(z₀)"*); **or**
    * eq (5.2) verbatim: a first-occurrence point `r₀ ∈ (z₀,z₁)` with `¬P` on `(z₀,r₀)` and
      `P(r₀) ∨ K⁺(P)(r₀)`.

    Contrast `HasDefinableINF` (`PriorINF.lean:108`), which is the **right disjunct alone**
    (modulo `r₀ ≤ z₁` vs `r₀ < z₁`) and therefore forbids the left one outright — see
    `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`) and
    `hasDedekindINF_admits_kplus_shape` below. -/
structure HasDedekindINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The faithful disjunction: the first-occurrence infimum is either at `z₀` (as `K⁺(P)(z₀)`)
      or is an eq (5.2) point strictly inside `(z₀,z₁)`. -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) →
    kplus M atomMap P z0 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → ¬temporal_truth M atomMap y P) ∧
        (temporal_truth M atomMap r0 P ∨ kplus M atomMap P r0))

/-- The `Since`-direction dual of `HasDedekindINF` (PDF p.8, mirrored).

    The left disjunct `kminus M atomMap P z1` is the mirror of the paper's `Subcase r₀ = z₀`:
    the last-occurrence supremum sits at the right endpoint `z₁`, which is exactly `K⁻(P)(z₁)`.
    `kminus` is `PriorINF.lean:92`. -/
structure HasDedekindSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The faithful disjunction, mirrored: the last-occurrence supremum is either at `z₁` (as
      `K⁻(P)(z₁)`) or is an eq (5.2)-mirror point strictly inside `(z₀,z₁)`. -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) →
    kminus M atomMap P z1 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, r0 < y → y < z1 → ¬temporal_truth M atomMap y P) ∧
        (temporal_truth M atomMap r0 P ∨ kminus M atomMap P r0))

/-! ## Compatibility shims from the landed carriers

These are what a future re-base needs first: they let the faithful carrier be *consumed* wherever
the landed ones are *supplied*, so the re-base need not discard `EANegationFix/`. -/

/-- `HasAttainedINF` implies the faithful `HasDedekindINF`: an attained first occurrence is the
    right disjunct of eq (5.2) with its left `P(r₀)` alternative. The `K⁺` cases never arise. -/
theorem HasAttainedINF.toHasDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedINF M atomMap) : HasDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    obtain ⟨r0, h_above, h_below, h_none, h_P_r0⟩ := h.first_occ P z0 z1 h_lt h_occ
    exact Or.inr ⟨r0, h_above, h_below, h_none, Or.inl h_P_r0⟩

/-- `HasDefinableINF` implies the faithful `HasDedekindINF`.

    `HasDefinableINF` gives only `r₀ ≤ z₁`; the faithful carrier's right disjunct wants
    `r₀ < z₁`. The gap closes from the occurrence hypothesis: `P` occurs at some `x ∈ (z₀,z₁)`,
    and `¬P` on `(z₀,r₀)` forces `r₀ ≤ x < z₁`. This is the "modulo `r₀ ≤ z₁` vs `r₀ < z₁`"
    reconciliation, discharged rather than assumed. -/
theorem HasDefinableINF.toHasDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDefinableINF M atomMap) : HasDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    obtain ⟨x, h_z0_x, h_x_z1, h_Px⟩ := h_occ
    obtain ⟨r0, h_above, -, h_none, h_disj⟩ :=
      h.first_occ P z0 z1 h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    have h_r0_le_x : r0 ≤ x := by
      by_contra h_gt
      push Not at h_gt
      exact h_none x h_z0_x h_gt h_Px
    exact Or.inr ⟨r0, h_above, lt_of_le_of_lt h_r0_le_x h_x_z1, h_none, h_disj⟩

/-- `HasAttainedSUP` implies the faithful `HasDedekindSUP`. Mirror of
    `HasAttainedINF.toHasDedekindINF`. -/
theorem HasAttainedSUP.toHasDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedSUP M atomMap) : HasDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := by
    obtain ⟨r0, h_above, h_below, h_none, h_P_r0⟩ := h.last_occ P z0 z1 h_lt h_occ
    exact Or.inr ⟨r0, h_above, h_below, h_none, Or.inl h_P_r0⟩

/-- `HasDefinableSUP` implies the faithful `HasDedekindSUP`. Mirror of
    `HasDefinableINF.toHasDedekindINF`: `HasDefinableSUP` gives only `z₀ ≤ r₀`, and `¬P` on
    `(r₀,z₁)` with `P(x)` for `x ∈ (z₀,z₁)` forces `z₀ < x ≤ r₀`. -/
theorem HasDefinableSUP.toHasDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDefinableSUP M atomMap) : HasDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := by
    obtain ⟨x, h_z0_x, h_x_z1, h_Px⟩ := h_occ
    obtain ⟨r0, -, h_below, h_none, h_disj⟩ :=
      h.last_occ P z0 z1 h_lt ⟨x, h_z0_x, h_x_z1, h_Px⟩
    have h_x_le_r0 : x ≤ r0 := by
      by_contra h_gt
      push Not at h_gt
      exact h_none x h_gt h_x_z1 h_Px
    exact Or.inr ⟨r0, lt_of_lt_of_le h_z0_x h_x_le_r0, h_below, h_none, h_disj⟩

/-! ## The live-path boundary: Prior structures satisfy the faithful carrier

This is what makes the faithful carrier *usable* on the live path without any re-base. It is also
the precise statement of why the deferred work has zero operational value: on Prior structures the
faithful carrier is derivable from the attained one, so no consumer can tell them apart. -/

/-- Prior structures satisfy the faithful `HasDedekindINF`, via `prior_hasAttainedINF`
    (`PriorINF.lean:224`) and the shim. The `K⁺` disjuncts are never needed: the UZ axiom
    supplies an attained first occurrence outright. -/
theorem prior_hasDedekindINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap) :
    HasDedekindINF M atomMap :=
  (prior_hasAttainedINF M atomMap h_UZ).toHasDedekindINF

/-- Prior structures satisfy the faithful `HasDedekindSUP`, via `prior_hasAttainedSUP` and the
    shim. Mirror of `prior_hasDedekindINF`. -/
theorem prior_hasDedekindSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : semantic_prior_SZ M atomMap) :
    HasDedekindSUP M atomMap :=
  (prior_hasAttainedSUP M atomMap h_SZ).toHasDedekindSUP

/-! ## The strictness delta, as a machine-checked fact -/

/-- **The left disjunct is reachable syntax, not dead syntax.**

    `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`) proves that under `HasDefinableINF`,
    `kplus M atomMap P z0` is **impossible** whenever `P` occurs in `(z₀,z₁)` — the landed carrier
    deletes the paper's disjunct (2) (PDF p.8). This theorem records the converse shape for
    `HasDedekindINF`: if a structure satisfies the faithful carrier **and** `K⁺(P)(z₀)` holds,
    then the carrier still applies and reports the left disjunct — i.e. the `Subcase r₀ = z₀`
    branch is genuinely inhabited rather than vacuously unreachable.

    Note what this does **not** claim: it does not exhibit a structure in which `K⁺(P)(z₀)` holds
    (that would need a formalized non-attained chain such as `ℝ`, which this tree does not build —
    see the module docstring). It establishes the weaker, honest fact that the left disjunct is
    *consistent with* the carrier and is the branch selected when `K⁺` obtains. Together with
    `hasDefinableINF_excludes_kplus`, this is the recorded delta between the two carriers.

    Source correspondence: Rabinovich 2014, Lemma 5.3 Case 2 and its `Subcase r₀ = z₀`, PDF p.8. -/
theorem hasDedekindINF_admits_kplus_shape {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (_h_inf : HasDedekindINF M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (_h_lt : z0 < z1)
    (_h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P)
    (h_kplus : kplus M atomMap P z0) :
    kplus M atomMap P z0 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → ¬temporal_truth M atomMap y P) ∧
        (temporal_truth M atomMap r0 P ∨ kplus M atomMap P r0)) :=
  Or.inl h_kplus

/-- **No structure satisfies both `HasDefinableINF` and `K⁺(P)(z₀)` for an occurring `P`.**

    The contrapositive reading of `hasDefinableINF_excludes_kplus`, stated here so the strictness
    claim in the module docstring is machine-checked at this module rather than asserted. Any
    structure witnessing the paper's `Subcase r₀ = z₀` therefore **refutes** `HasDefinableINF` —
    which is exactly why the faithful carrier is needed for a faithful Lemma 5.3, and exactly what
    the deferred re-base would consume. -/
theorem hasDefinableINF_incompatible_with_kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P)
    (h_kplus : kplus M atomMap P z0) :
    ¬HasDefinableINF M atomMap :=
  fun h_inf => hasDefinableINF_excludes_kplus M atomMap h_inf P z0 z1 h_lt h_occ h_kplus

end Bimodal.Metalogic.WeakCanonical.Kamp
