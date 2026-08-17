/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.DedekindINFDense

/-!
# The source-exact `K⁺`, its missing bridge, and the faithful dichotomy carrier

This module lands the **Prop-level reading of `Formula.kPlus`** (`FormalSystem/Syntax/Formula.lean`
`:180`), the **bridge lemma relating the two** — absent from this tree since `Formula.kPlus` was
written — and the eq (5.2) first-occurrence carrier stated with the *sources'* `K⁺` rather than
this tree's `kplus`.

## Three spellings of `K⁺`, and which transcribes which source

This tree carries three, and the reader must keep them apart. The name-collision warning at
`Syntax/Formula.lean:163-179` names the first two; this module adds the third and, with the bridge
lemmas below, reduces the number of *unbridged* spellings from two to zero.

| Spelling | Level | Definition | Transcribes |
|---|---|---|---|
| `Formula.kPlus` (`Syntax/Formula.lean:180`) | object | `(untl ⊤ φ.neg).neg` | **the sources, exactly** |
| `kplusOpen` (**this module**) | `Prop` | `∀ s > t, ∃ r ∈ (t,s), P(r)` | **the sources, exactly** — the semantic reading of `Formula.kPlus` |
| `kplus` (`Kamp/PriorINF.lean:86`) | `Prop` | `¬P(t) ∧ ∀ s > t, ∃ r ∈ (t,s), P(r)` | **neither source** — strictly stronger, by the added `¬P(t)` |
| `kplusFormula` (`Kamp/PriorINF.lean:~93`) | object | `P.neg ∧ ¬(⊤ U P.neg)` | the object-level spelling of `kplus`, not of the sources' `K⁺` |

The two source definitions, read verbatim from the corpus at this revision:

* **Rabinovich 2014**, *A Proof of Kamp's Theorem*, `K⁺` definition, **PDF p.3**:
  *"`K+(F)` (respectively, `K−(F)`) is an abbreviation for `¬((¬F)UntilTrue)` (respectively,
  `¬((¬F)SinceTrue)`)"*, and, spelled out semantically in the same passage,
  *"(3) `K+(F)` holds at a moment `t` iff `t = inf({t′ | t′ > t and F holds at t′})`."*
* **Reynolds 1992**, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
  abbreviation table, §1, **printed p.168**: `K⁺A` — *"for `¬U(⊤, ¬A)`"* — reading *"`A` will be
  true arbitrarily soon"*; with `U(A,B)(t)` iff *"there is `s > t` such that `A(s)` and for all
  `u`, if `t < u < s` then `B(u)`"*. Corroborated by Gabbay-Hodkinson-Reynolds 1994 §10.3.1
  (`K⁺q = ¬U(⊤,¬q)`), which `Syntax/Formula.lean:163-179` already cites.

**Neither source's `K⁺` carries a `¬A` conjunct at the point of evaluation.** Rabinovich's
`Until` takes its eventuality as the *second* argument, so his `(¬F) Until True` is Reynolds'
`U(⊤,¬F)` — the two abbreviations are the same operator written under mirrored argument
conventions, and `Formula.untl φ ψ` (`Table.lean:188`) follows Reynolds'.

## The bridge, and why its absence mattered

`Axiom.prior_U_gap` (`ProofSystem/Axioms.lean:377`), `Axiom.prior_S_gap` (`:387`) and `Axiom.sep`
(`:390`) are all stated with `Formula.kPlus` / `Formula.kMinus`, while the whole Prop-level carrier
apparatus — `kplus`, `HasDefinableINF`, `HasAttainedINF`, `HasDedekindINF`, `HasGuardedDedekindINF`,
`HasDenseDedekindINF` and the eight `*Faithful*` modules — is stated with `kplus`. Nothing in the
tree could read the axioms semantically, and nothing could move between the two spellings.
`kPlus_formula_correct` and `kMinus_formula_correct` below are that bridge, and they are
independently valuable to any later phase that must relate an axiom to a truth condition.

## The faithful carrier

`HasFaithfulDedekindINF` is `HasDedekindINF.first_occ` (`Kamp/DedekindINF.lean:136`)
character-for-character **except** that its left disjunct is `kplusOpen M atomMap P z₀` in place of
`kplus M atomMap P z₀`. That single change is the whole content of this module's carrier, and it is
what makes Rabinovich's *"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* (Lemma 5.3 Case 2, PDF p.8) a **definitional
restatement** — true verbatim under his own Definition (3) — rather than something requiring a
repair.

**What the carrier excludes** (honesty charter Rule 6). `HasFaithfulDedekindINF` forbids exactly
those structures in which some `P` occurs inside an interval `(z₀,z₁)` while *both*: `P` fails to
occur arbitrarily soon after `z₀`, *and* no eq (5.2) point exists inside `(z₀,z₁)`. On a densely
ordered flow this is a genuine restriction — but, unlike `HasDedekindINF`, it is **not** refuted by
a formula that holds at `z₀` and throughout `(z₀,z₁)`: see `kplusOpen_of_interval_witness` and
`hasFaithfulDedekindINF_survives_interval_witness` below, which are the machine-checked settlement
of that question. It admits the whole discrete/attained pipeline through
`HasDedekindINF.toHasFaithfulDedekindINF`, and it admits every dense structure satisfying
`SemanticPriorU` through `prior_hasFaithfulDedekindINF_dense`.

## What is read, not edited

`Syntax/Formula.lean`, `ProofSystem/Axioms.lean`, `Kamp/PriorINF.lean` (statements and proofs),
`Kamp/DedekindINF.lean`, `Kamp/Lemma53.lean`, `Kamp/DedekindINFDense.lean` (statements and proofs)
and all eight `*Faithful*` modules are **read** by this module and not edited by it. Nothing landed
by `DedekindINFDense.lean` is deleted, reverted, restated or deprecated: the guard/trichotomy
apparatus stays exactly as it is, it stays the tree's record of the `kplus` deviation, and
`HasFaithfulDedekindINF.toHasDenseDedekindINF` keeps it supplied.

## References

- Rabinovich 2014, `K⁺` definition (PDF p.3); Lemma 5.3 Case 2 and eq (5.2) (PDF p.8)
- Reynolds 1992, abbreviation table §1 and Prior-U / Prior-S (printed p.168)
- Gabbay-Hodkinson-Reynolds 1994, §10.3.1
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## The source-exact `K⁺` at the `Prop` level -/

/-- **The sources' `K⁺`, at the `Prop` level**: `P` holds arbitrarily soon after `t`.

    Rabinovich 2014, `K⁺` definition, PDF p.3: *"`K+(F)` holds at a moment `t` iff
    `t = inf({t′ | t′ > t and F holds at t′})`"*. Reynolds 1992, abbreviation table §1, printed
    p.168: `K⁺A` for `¬U(⊤,¬A)`, *"`A` will be true arbitrarily soon"*.

    **This is `kplus` (`Kamp/PriorINF.lean:86`) minus its first conjunct**, and the first conjunct
    `¬P(t)` is **this tree's addition, not the sources'**. Neither Rabinovich's nor Reynolds'
    `K⁺` says anything about whether `P` holds at the point of evaluation. `kplus` is therefore
    strictly stronger than the operator both papers define; `kplusOpen` is what they define.

    `kplus_iff_not_and_kplusOpen` below states the exact relation, and
    `kplusOpen_not_implied_by_truth_at` exhibits a point at which `kplusOpen` fails while `P`
    holds, so the difference is not an artefact of presentation. -/
def kplusOpen {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r < s ∧ TemporalTruth M atomMap r P

/-- **The sources' `K⁻`, at the `Prop` level**: `P` held arbitrarily recently before `t`.

    The past mirror of `kplusOpen`. Rabinovich 2014, PDF p.3: *"(2) `K−(F)` holds at a moment `t`
    iff `t = sup({t′ | t′ < t and F holds at t′})`"*; Reynolds 1992, printed p.168: `K⁻A` for
    `¬S(⊤,¬A)`, *"`A` was true arbitrarily recently"*.

    **This is `kminus` (`Kamp/PriorINF.lean:98`) minus its first conjunct**, which is again this
    tree's addition and not the sources'. -/
def kminusOpen {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) : Prop :=
  ∀ s : M.carrier, s < t → ∃ r : M.carrier, s < r ∧ r < t ∧ TemporalTruth M atomMap r P

/-! ## The missing bridge

`Formula.kPlus` (`Syntax/Formula.lean:180`) has stood in this tree, beside `kplusFormula`
(`Kamp/PriorINF.lean:~93`) and a name-collision warning, with **no lemma relating either to a
truth condition**. These two lemmas are that bridge. -/

/-- **The bridge: `Formula.kPlus` is `kplusOpen`.**

    `TemporalTruth M atomMap t (Formula.kPlus P) ↔ kplusOpen M atomMap P t`.

    `Formula.kPlus P` is `(untl ⊤ P.neg).neg` (`Syntax/Formula.lean:180`), which is Reynolds'
    `¬U(⊤,¬P)` (abbreviation table §1, printed p.168) letter for letter under
    `Formula.untl`'s truth clause (`Table.lean:188`). Unwinding: `U(⊤,¬P)(t)` says some `(t,s)` is
    entirely `P`-free, so its negation says every `(t,s)` contains a point at which `P` holds —
    which is `kplusOpen`, and which is Rabinovich's Definition (3) (PDF p.3).

    **This is the lemma the tree has never had.** `Axiom.prior_U_gap`
    (`ProofSystem/Axioms.lean:377`) and `Axiom.sep` (`:390`) are stated with `Formula.kPlus`;
    before this lemma nothing in the tree could read their `K⁺` semantically. -/
theorem kPlus_formula_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) :
    TemporalTruth M atomMap t (Formula.kPlus P) ↔ kplusOpen M atomMap P t := by
  constructor
  · intro h s hs
    by_contra h_none
    refine (temporal_truth_neg M atomMap t (Formula.untl P.neg Formula.top)).mp h ?_
    refine ⟨s, hs, temporal_truth_top M atomMap s, fun r hr hrs => ?_⟩
    rw [temporal_truth_neg]
    exact fun hP => h_none ⟨r, hr, hrs, hP⟩
  · intro h
    rw [Formula.kPlus, temporal_truth_neg]
    rintro ⟨s, hs, -, h_neg⟩
    obtain ⟨r, hr, hrs, hPr⟩ := h s hs
    exact (temporal_truth_neg M atomMap r P).mp (h_neg r hr hrs) hPr

/-- **The bridge, mirrored: `Formula.kMinus` is `kminusOpen`.**

    `Formula.kMinus P` is `(snce ⊤ P.neg).neg` (`Syntax/Formula.lean:193`), Reynolds' `¬S(⊤,¬P)`
    (printed p.168). `Axiom.prior_S_gap` (`ProofSystem/Axioms.lean:387`) and `Axiom.sep` (`:390`)
    are stated with it. -/
theorem kMinus_formula_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) :
    TemporalTruth M atomMap t (Formula.kMinus P) ↔ kminusOpen M atomMap P t := by
  constructor
  · intro h s hs
    by_contra h_none
    refine (temporal_truth_neg M atomMap t (Formula.snce P.neg Formula.top)).mp h ?_
    refine ⟨s, hs, temporal_truth_top M atomMap s, fun r hr hrs => ?_⟩
    rw [temporal_truth_neg]
    exact fun hP => h_none ⟨r, hr, hrs, hP⟩
  · intro h
    rw [Formula.kMinus, temporal_truth_neg]
    rintro ⟨s, hs, -, h_neg⟩
    obtain ⟨r, hr, hrs, hPr⟩ := h s hs
    exact (temporal_truth_neg M atomMap r P).mp (h_neg r hr hrs) hPr

/-! ## Relating the two `Prop`-level spellings

The relation is exactly one conjunct, in one direction only. These lemmas make the trichotomy's
weakness precise rather than asserted. -/

/-- **`kplus` is `kplusOpen` plus this tree's extra conjunct**, definitionally.

    Reading right to left: to get the tree's `kplus` from the sources' `K⁺` one must *add*
    `¬P(t)`, which neither source's definition contains. -/
theorem kplus_iff_not_and_kplusOpen {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) :
    kplus M atomMap P t ↔ ¬TemporalTruth M atomMap t P ∧ kplusOpen M atomMap P t :=
  Iff.rfl

/-- **`kminus` is `kminusOpen` plus this tree's extra conjunct**, definitionally. -/
theorem kminus_iff_not_and_kminusOpen {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) :
    kminus M atomMap P t ↔ ¬TemporalTruth M atomMap t P ∧ kminusOpen M atomMap P t :=
  Iff.rfl

/-- The tree's `K⁺` implies the sources' `K⁺`: drop the extra conjunct. -/
theorem kplusOpen_of_kplus {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {P : Formula} {t : M.carrier} (h : kplus M atomMap P t) : kplusOpen M atomMap P t :=
  h.2

/-- The tree's `K⁻` implies the sources' `K⁻`: drop the extra conjunct. -/
theorem kminusOpen_of_kminus {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {P : Formula} {t : M.carrier} (h : kminus M atomMap P t) : kminusOpen M atomMap P t :=
  h.2

/-- **The sources' `K⁺` splits into the trichotomy's first two disjuncts**:
    `kplusOpen P t → P(t) ∨ kplus P t`.

    Split on `P(t)`; where it fails, `kplusOpen` *is* `kplus`. This is the step that lets the
    faithful dichotomy supply Phase 10's trichotomy — see
    `HasFaithfulDedekindINF.toHasDenseDedekindINF`. -/
theorem truth_or_kplus_of_kplusOpen {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {P : Formula} {t : M.carrier} (h : kplusOpen M atomMap P t) :
    TemporalTruth M atomMap t P ∨ kplus M atomMap P t := by
  by_cases h_at : TemporalTruth M atomMap t P
  · exact Or.inl h_at
  · exact Or.inr ⟨h_at, h⟩

/-- **The sources' `K⁻` splits into the mirrored trichotomy's first two disjuncts.** -/
theorem truth_or_kminus_of_kminusOpen {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {P : Formula} {t : M.carrier} (h : kminusOpen M atomMap P t) :
    TemporalTruth M atomMap t P ∨ kminus M atomMap P t := by
  by_cases h_at : TemporalTruth M atomMap t P
  · exact Or.inl h_at
  · exact Or.inr ⟨h_at, h⟩

/-! ### The converse fails, machine-checked

`truth_or_kplus_of_kplusOpen` has no converse: `P(t)` alone does **not** give `kplusOpen P t`.
The witness below is what makes the trichotomy's third disjunct *uninformative* — a consumer that
lands in `P(z₀)` learns nothing about whether the first occurrence sits at `z₀` — and it is
simultaneously the reason `HasDenseDedekindINF → HasFaithfulDedekindINF` is unavailable. -/

/-- **The closed left ray**: the real line with one predicate true exactly on `(-∞,0]`.

    Original scaffolding for the witness below; the sibling of Phase 9's `denseRayFlow` and
    `denseWindowFlow` (`PriorDefsDense.lean`) with a *closed* endpoint, which is exactly what
    separates "`P` holds here" from "`P` holds arbitrarily soon after here". -/
noncomputable abbrev denseClosedRayFlow : OrderedMonadicStructure densePriorSig :=
  realFlowStructure (fun x => x ≤ 0)

/-- **`P(t)` does not imply `kplusOpen P t`**: on the closed left ray at `t = 0` the predicate
    holds, and yet it holds nowhere in `(0,1)`.

    Consequences, both load-bearing:
    * `truth_or_kplus_of_kplusOpen` is a strict one-way implication, so the trichotomy
      `HasDenseDedekindINF` (`DedekindINFDense.lean:187`) is **strictly weaker at the left
      disjunct** than the dichotomy `HasFaithfulDedekindINF` below.
    * `HasDenseDedekindINF → HasFaithfulDedekindINF` is **not** available and is not attempted
      here: a consumer handed the trichotomy's `P(z₀)` disjunct cannot recover `kplusOpen P z₀`,
      because `P(z₀)` does not imply that `P` recurs above `z₀` at all. The shim lattice below
      therefore runs one way only. -/
theorem kplusOpen_not_implied_by_truth_at :
    ∃ (M : OrderedMonadicStructure densePriorSig) (atomMap : Formula → densePriorSig.preds)
      (P : Formula) (t : M.carrier),
      TemporalTruth M atomMap t P ∧ ¬kplusOpen M atomMap P t := by
  refine ⟨denseClosedRayFlow, densePriorAtomMap, denseWindowAtom, 0, ?_, ?_⟩
  · simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]; norm_num
  · intro h
    obtain ⟨r, hr0, -, hPr⟩ := h 1 one_pos
    simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom] at hPr
    linarith

/-! ## The faithful dichotomy carrier

Rabinovich 2014, Lemma 5.3 Case 2 and eq (5.2), PDF p.8:

> *"Case 2: If case 1 does not hold then let `r₀ = inf{z ∈ (z₀, z₁) | P₁(z)}` … Note that
> `r₀ = z₀` iff `K⁺(P₁)(z₀)`. If `r₀ > z₀` then `r₀ ∈ (z₀, z₁)` and `r₀` is definable by the
> following ∨∃⃗∀ formula:"* then
> `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀} ¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))` **(5.2)**.

Under Rabinovich's own Definition (3) — *"`K+(F)` holds at `t` iff
`t = inf({t′ | t′ > t and F holds at t′})`"*, PDF p.3 — the quoted biconditional
*"`r₀ = z₀` iff `K⁺(P₁)(z₀)`"* is a **definitional restatement**, true verbatim. The carriers
below are that dichotomy, stated at the source's `K⁺`. -/

/-- **Rabinovich's eq (5.2) carrier at the *source's* `K⁺`** (Lemma 5.3 Case 2, PDF p.8, with
    `K⁺` per his Definition (3), PDF p.3; Reynolds' abbreviation table, printed p.168).

    `HasDedekindINF.first_occ` (`Kamp/DedekindINF.lean:136`) character-for-character **except**
    that the left disjunct is `kplusOpen M atomMap P z₀` in place of `kplus M atomMap P z₀`. The
    right disjunct is literally `HasDedekindINF`'s, `kplus` included: `P(r₀) ∨ kplusOpen P r₀` and
    `P(r₀) ∨ kplus P r₀` are interderivable *as disjunctions* (`truth_or_kplus_of_kplusOpen` one
    way, `kplusOpen_of_kplus` the other), so nothing is gained or lost by changing it and the two
    carriers' right disjuncts stay syntactically identical for the re-base.

    **This is a dichotomy, not a trichotomy.** No endpoint guard and no third disjunct: the left
    disjunct at the source's `K⁺` already covers Rabinovich's `r₀ = z₀` subcase *whether or not*
    `P` holds at `z₀`, which is precisely what this tree's `kplus` could not express.

    **What it excludes** (honesty charter Rule 6). It forbids exactly those structures carrying a
    `P` and an interval `(z₀,z₁)` in which `P` occurs, such that `P` does *not* occur arbitrarily
    soon after `z₀` and no eq (5.2) point lies inside `(z₀,z₁)`. It **admits**: the whole
    discrete/attained pipeline (`HasDedekindINF.toHasFaithfulDedekindINF`, composed with
    `HasAttainedINF.toHasDedekindINF` and `HasDefinableINF.toHasDedekindINF`); every dense
    structure satisfying `SemanticPriorU` (`prior_hasFaithfulDedekindINF_dense`); and — unlike
    `HasDedekindINF` — the dense-window configuration at which
    `hasDedekindINF_fails_on_dense_window` refutes the tree's carrier
    (`hasFaithfulDedekindINF_survives_interval_witness`). -/
structure HasFaithfulDedekindINF {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The source-exact dichotomy: the first occurrence at-or-above `z₀` sits at `z₀` — which, at
      the sources' `K⁺`, is exactly `kplusOpen P z₀` — or is an eq (5.2) point strictly inside
      `(z₀,z₁)`. -/
  first_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    kplusOpen M atomMap P z0 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, z0 < y → y < r0 → ¬TemporalTruth M atomMap y P) ∧
        (TemporalTruth M atomMap r0 P ∨ kplus M atomMap P r0))

/-- **The `Since`-direction dual of `HasFaithfulDedekindINF`** (Rabinovich 2014, eq (5.2)
    mirrored, PDF p.8; `K⁻` per his Definition (2), PDF p.3).

    `HasDedekindSUP.last_occ` (`Kamp/DedekindINF.lean:153`) character-for-character except that
    the left disjunct is `kminusOpen M atomMap P z₁` in place of `kminus M atomMap P z₁`. Same
    exclusion statement as `HasFaithfulDedekindINF`, mirrored at the right endpoint. -/
structure HasFaithfulDedekindSUP {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- The source-exact dichotomy, mirrored. -/
  last_occ : ∀ (P : Formula) (z0 z1 : M.carrier),
    z0 < z1 →
    (∃ x : M.carrier, z0 < x ∧ x < z1 ∧ TemporalTruth M atomMap x P) →
    kminusOpen M atomMap P z1 ∨
      (∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
        (∀ y : M.carrier, r0 < y → y < z1 → ¬TemporalTruth M atomMap y P) ∧
        (TemporalTruth M atomMap r0 P ∨ kminus M atomMap P r0))

/-! ## The shim lattice

The faithful carrier is a **weakening** of `HasDedekindINF`, so every current supplier keeps
working, and it is a **strengthening** of Phase 10's trichotomy at the left disjunct, so Phase 10's
landed carrier stays supplied. The lattice runs one way at each edge; the missing edge is recorded
below with its reason. -/

/-- `HasDedekindINF` implies the faithful carrier: the left disjunct's extra conjunct is
    discarded (`kplusOpen_of_kplus`), the right disjunct is passed through unchanged.

    **This is the edge that keeps the discrete pipeline supplied.** Composed with
    `HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`) and
    `HasDefinableINF.toHasDedekindINF` (`:185`), everything that supplies a first-occurrence
    carrier today supplies this one. -/
theorem HasDedekindINF.toHasFaithfulDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDedekindINF M atomMap) : HasFaithfulDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    rcases h.first_occ P z0 z1 h_lt h_occ with h_left | h_right
    · exact Or.inl h_left.2
    · exact Or.inr h_right

/-- `HasDedekindSUP` implies the mirrored faithful carrier. -/
theorem HasDedekindSUP.toHasFaithfulDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasDedekindSUP M atomMap) : HasFaithfulDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := by
    rcases h.last_occ P z0 z1 h_lt h_occ with h_left | h_right
    · exact Or.inl h_left.2
    · exact Or.inr h_right

/-- `HasAttainedINF` implies the faithful carrier, through `HasDedekindINF`. -/
theorem HasAttainedINF.toHasFaithfulDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedINF M atomMap) : HasFaithfulDedekindINF M atomMap :=
  h.toHasDedekindINF.toHasFaithfulDedekindINF

/-- `HasAttainedSUP` implies the mirrored faithful carrier, through `HasDedekindSUP`. -/
theorem HasAttainedSUP.toHasFaithfulDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasAttainedSUP M atomMap) : HasFaithfulDedekindSUP M atomMap :=
  h.toHasDedekindSUP.toHasFaithfulDedekindSUP

/-- **The faithful carrier supplies Phase 10's trichotomy**
    (`HasDenseDedekindINF`, `DedekindINFDense.lean:187`), via `truth_or_kplus_of_kplusOpen`.

    So nothing Phase 10 landed is stranded by the re-base: `DedekindINFDense.lean`'s carrier
    remains derivable, remains consumed, and remains the tree's record of the `kplus` deviation. -/
theorem HasFaithfulDedekindINF.toHasDenseDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasFaithfulDedekindINF M atomMap) : HasDenseDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    rcases h.first_occ P z0 z1 h_lt h_occ with h_left | h_right
    · rcases truth_or_kplus_of_kplusOpen h_left with h_at | h_kplus
      · exact Or.inl h_at
      · exact Or.inr (Or.inl h_kplus)
    · exact Or.inr (Or.inr h_right)

/-- **The mirrored faithful carrier supplies Phase 10's mirrored trichotomy.** -/
theorem HasFaithfulDedekindSUP.toHasDenseDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasFaithfulDedekindSUP M atomMap) : HasDenseDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := by
    rcases h.last_occ P z0 z1 h_lt h_occ with h_left | h_right
    · rcases truth_or_kminus_of_kminusOpen h_left with h_at | h_kminus
      · exact Or.inl h_at
      · exact Or.inr (Or.inl h_kminus)
    · exact Or.inr (Or.inr h_right)

/-- The faithful carrier also supplies the *guarded* carrier
    (`HasGuardedDedekindINF`, `DedekindINFDense.lean:128`), by composing with
    `HasDenseDedekindINF.toHasGuardedDedekindINF`. Recorded so that no consumer of Phase 10's
    material has to route through the trichotomy by hand. -/
theorem HasFaithfulDedekindINF.toHasGuardedDedekindINF {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasFaithfulDedekindINF M atomMap) : HasGuardedDedekindINF M atomMap :=
  h.toHasDenseDedekindINF.toHasGuardedDedekindINF

/-- The mirrored faithful carrier supplies the mirrored guarded carrier. -/
theorem HasFaithfulDedekindSUP.toHasGuardedDedekindSUP {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h : HasFaithfulDedekindSUP M atomMap) : HasGuardedDedekindSUP M atomMap :=
  h.toHasDenseDedekindSUP.toHasGuardedDedekindSUP

/-! ### The edge that does not exist

**`HasDenseDedekindINF → HasFaithfulDedekindINF` is not available**, and no attempt at it is made
here. A consumer handed the trichotomy's third disjunct `P(z₀)` cannot recover
`kplusOpen M atomMap P z₀`, because `P(z₀)` does not imply that `P` recurs above `z₀` at all —
`kplusOpen_not_implied_by_truth_at` exhibits the point. This is the precise sense in which the
trichotomy's endpoint disjunct is *uninformative*: it does not say `r₀ = z₀`, so a consumer that
lands in it learns nothing it can use, which is why the two hard re-base sites have no case slot
for it. The lattice is therefore strictly one-way at this edge, and the faithful dichotomy is the
stronger of the two carriers at the left disjunct while being weaker than `HasDedekindINF`. -/

/-! ## The derivation from the dense Prior hypotheses, with no guard

Reynolds 1992, Prior-U / Prior-S, printed p.168, instantiated at `p := ¬P`. The case split is on
the **interval**, never on `z₀`, which is why no guard appears anywhere below. -/

/-- **`SemanticPriorU` yields the faithful eq (5.2) dichotomy, hypothesis-free**
    (Rabinovich 2014, Lemma 5.3 Case 2 and eq (5.2), PDF p.8; derived from Reynolds 1992,
    Prior-U, printed p.168).

    The derivation, following the paper's Case 2 at the paper's own `K⁺`:

    1. If `K⁺(P)(z₀)` — i.e. `kplusOpen M atomMap P z₀` — take the left disjunct and stop. This is
       Rabinovich's *"Subcase `r₀ = z₀`"* (PDF p.8), and at his `K⁺` it needs no side condition.
    2. Otherwise some `(z₀,s)` is entirely `P`-free. That is Prior-U's first antecedent
       `U(⊤,¬P)(z₀)`, obtained **directly from the failure of `kplusOpen`** — no `¬P(z₀)` is
       needed, because `kplusOpen` says nothing about `z₀`.
    3. `P` occurs inside `(z₀,z₁)`, which is Prior-U's second antecedent `F¬¬P(z₀)`.
    4. Prior-U's conclusion `U(P ∨ K⁺(P), ¬P)(z₀)` supplies `r₀ > z₀` with `¬P` throughout
       `(z₀,r₀)` and `P(r₀) ∨ K⁺(P)(r₀)`.
    5. `r₀ < z₁`, because `P` occurs at some `x ∈ (z₀,z₁)` while `¬P` holds on `(z₀,r₀)`.
    6. Steps 4-5 are eq (5.2) verbatim — the right disjunct.

    **Compare `prior_hasGuardedDedekindINF_dense` (`DedekindINFDense.lean:326`)**, which needs the
    endpoint guard `¬P(z₀)` at step 2 precisely because the failure of the tree's `kplus` might be
    in its *first* conjunct rather than its second. At the source's `K⁺` there is no first
    conjunct, so there is nothing to guard. The two derivations are otherwise the same proof.

    No discreteness, no attainment, no completeness hypothesis on the flow: `SemanticPriorU`
    alone, exactly as at Phase 10. -/
theorem prior_hasFaithfulDedekindINF_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_U : SemanticPriorU M atomMap) : HasFaithfulDedekindINF M atomMap where
  first_occ P z0 z1 h_lt h_occ := by
    -- Step 1: the paper's `Subcase r₀ = z₀`, at the paper's own `K⁺`.
    by_cases h_k : kplusOpen M atomMap P z0
    · exact Or.inl h_k
    refine Or.inr ?_
    -- Step 2: the failure of `kplusOpen` *is* `U(⊤,¬P)(z₀)`. No guard is used.
    have h_gap : ∃ s : M.carrier, z0 < s ∧
        ∀ r : M.carrier, z0 < r → r < s → TemporalTruth M atomMap r P.neg := by
      simp only [kplusOpen, not_forall, not_exists] at h_k
      obtain ⟨s, hs_lt, h_none⟩ := h_k
      refine ⟨s, hs_lt, fun r hr hrs => ?_⟩
      rw [temporal_truth_neg]
      intro hPr
      exact h_none r ⟨hr, hrs, hPr⟩
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

/-- **`SemanticPriorS` yields the faithful eq (5.2) dichotomy, mirrored and hypothesis-free**
    (Rabinovich 2014, eq (5.2) mirrored, PDF p.8; from Reynolds 1992, Prior-S, printed p.168).

    The exact mirror of `prior_hasFaithfulDedekindINF_dense`: the failure of `kminusOpen P z₁`
    gives Prior-S's first antecedent `S(⊤,¬P)(z₁)` with no `¬P(z₁)` guard, the occurrence of `P`
    inside `(z₀,z₁)` gives `P¬¬P(z₁)`, and Prior-S's conclusion `S(P ∨ K⁻(P), ¬P)(z₁)` is the
    mirrored eq (5.2). -/
theorem prior_hasFaithfulDedekindSUP_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_S : SemanticPriorS M atomMap) : HasFaithfulDedekindSUP M atomMap where
  last_occ P z0 z1 h_lt h_occ := by
    by_cases h_k : kminusOpen M atomMap P z1
    · exact Or.inl h_k
    refine Or.inr ?_
    have h_gap : ∃ s : M.carrier, s < z1 ∧
        ∀ r : M.carrier, s < r → r < z1 → TemporalTruth M atomMap r P.neg := by
      simp only [kminusOpen, not_forall, not_exists] at h_k
      obtain ⟨s, hs_lt, h_none⟩ := h_k
      refine ⟨s, hs_lt, fun r hr hrz => ?_⟩
      rw [temporal_truth_neg]
      intro hPr
      exact h_none r ⟨hr, hrz, hPr⟩
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

/-! ## THE PROBE: does the interval-witness refutation survive the conjunct-free antecedent?

`hasDedekindINF_fails_of_interval_witness` (`DedekindINFDense.lean:455`) refutes `HasDedekindINF`
on any densely ordered flow carrying a formula that holds at `z₀` **and** throughout `(z₀,z₁)`.
Its left-disjunct arm is `exact h_left.1 h_at` — it kills `kplus`'s **first conjunct**, the one
neither source has. The question this section settles by machine is whether the refutation still
goes through when that conjunct is removed. -/

/-- **The refutation's own hypotheses *establish* the faithful left disjunct.**

    If the flow is densely ordered and `P` holds throughout `(z₀,z₁)`, then `P` holds arbitrarily
    soon after `z₀` — which is `kplusOpen M atomMap P z₀`, the sources' `K⁺`.

    Note what is **not** assumed: `TemporalTruth M atomMap z₀ P` plays no role. The very
    configuration that makes `hasDedekindINF_fails_of_interval_witness` fire is a configuration in
    which the source-exact left disjunct holds outright. -/
theorem kplusOpen_of_interval_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hdense : ∀ x y : M.carrier, x < y → ∃ z : M.carrier, x < z ∧ z < y)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_on : ∀ y : M.carrier, z0 < y → y < z1 → TemporalTruth M atomMap y P) :
    kplusOpen M atomMap P z0 := by
  intro s hs
  by_cases h_sz1 : s ≤ z1
  · obtain ⟨r, hr0, hrs⟩ := hdense z0 s hs
    exact ⟨r, hr0, hrs, h_on r hr0 (lt_of_lt_of_le hrs h_sz1)⟩
  · push Not at h_sz1
    obtain ⟨r, hr0, hr1⟩ := hdense z0 z1 h_lt
    exact ⟨r, hr0, lt_trans hr1 h_sz1, h_on r hr0 hr1⟩

/-- **The mirror**: if `P` holds throughout `(z₀,z₁)` on a densely ordered flow, then
    `kminusOpen M atomMap P z₁`. -/
theorem kminusOpen_of_interval_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hdense : ∀ x y : M.carrier, x < y → ∃ z : M.carrier, x < z ∧ z < y)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_on : ∀ y : M.carrier, z0 < y → y < z1 → TemporalTruth M atomMap y P) :
    kminusOpen M atomMap P z1 := by
  intro s hs
  by_cases h_z0s : z0 ≤ s
  · obtain ⟨r, hsr, hr1⟩ := hdense s z1 hs
    exact ⟨r, hsr, hr1, h_on r (lt_of_le_of_lt h_z0s hsr) hr1⟩
  · push Not at h_z0s
    obtain ⟨r, hr0, hr1⟩ := hdense z0 z1 h_lt
    exact ⟨r, lt_trans h_z0s hr0, hr1, h_on r hr0 hr1⟩

/-- **THE PROBE, stated head to head.** Under *exactly* the hypotheses of
    `hasDedekindINF_fails_of_interval_witness` (`DedekindINFDense.lean:455`) — a densely ordered
    flow, `P` at `z₀`, `P` throughout `(z₀,z₁)` — the tree's carrier `HasDedekindINF` is refuted
    while the source-exact carrier's **left disjunct holds**.

    **So the refutation does not survive the conjunct-free antecedent.** The interval-witness
    refutation is a theorem about the extra `¬P(z₀)` conjunct that `kplus`
    (`Kamp/PriorINF.lean:86`) carries and that neither Rabinovich's nor Reynolds' `K⁺` has. Under
    the sources' `K⁺` there is no failure to refute: `P` is true arbitrarily soon after `z₀`, so
    the paper's `Subcase r₀ = z₀` fires and eq (5.2) is never needed.

    **Consequence, machine-checked rather than argued**: the endpoint guard
    (`HasGuardedDedekindINF`), the third disjunct `P(z₀)` and the trichotomy
    (`HasDenseDedekindINF`) are a formalization-level repair for this tree's `kplus`. They have no
    counterpart in either source, and a carrier stated at the source's `K⁺` does not need them.
    They stay landed, unedited, and supplied by `HasFaithfulDedekindINF.toHasDenseDedekindINF`. -/
theorem hasFaithfulDedekindINF_survives_interval_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (hdense : ∀ x y : M.carrier, x < y → ∃ z : M.carrier, x < z ∧ z < y)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_at : TemporalTruth M atomMap z0 P)
    (h_on : ∀ y : M.carrier, z0 < y → y < z1 → TemporalTruth M atomMap y P) :
    kplusOpen M atomMap P z0 ∧ ¬HasDedekindINF M atomMap :=
  ⟨kplusOpen_of_interval_witness M atomMap hdense P z0 z1 h_lt h_on,
    hasDedekindINF_fails_of_interval_witness M atomMap hdense P z0 z1 h_lt h_at h_on⟩

/-- **The probe at the concrete configuration** — `denseWindowFlow` (`PriorDefsDense.lean:336`),
    `z₀ = 1/2`, `z₁ = 1`, `P` the atom true exactly on `(0,1)`.

    This is precisely the point at which `denseWindow_endpoint_disjunct_forced`
    (`DedekindINFDense.lean:595`) proves that `P(z₀)` holds and **both** of `HasDedekindINF`'s
    disjuncts fail, forcing the trichotomy's third disjunct. At the source's `K⁺` the left
    disjunct holds there, so no third disjunct is forced. -/
theorem denseWindow_kplusOpen_at_half :
    kplusOpen denseWindowFlow densePriorAtomMap denseWindowAtom (1 / 2) :=
  kplusOpen_of_interval_witness denseWindowFlow densePriorAtomMap
    (realFlowStructure_dense _) denseWindowAtom (1 / 2) 1 (by norm_num)
    (by
      intro y hy hy1
      simp only [denseWindowAtom, temporalTruth_realFlowStructure_atom]
      constructor <;> linarith)

/-- **The probe's verdict, as a single machine-checked statement.** At the dense window flow there
    is a configuration in which the tree's carrier is refuted and the source-exact carrier's left
    disjunct holds — and the structure satisfies both dense Prior hypotheses.

    Read out: *"the guard/trichotomy apparatus is a repair for the tree's `kplus`, and is not
    needed by a source-exact carrier."* -/
theorem denseWindow_probe_verdict :
    SemanticPriorU denseWindowFlow densePriorAtomMap ∧
      SemanticPriorS denseWindowFlow densePriorAtomMap ∧
      TemporalTruth denseWindowFlow densePriorAtomMap (1 / 2 : denseWindowFlow.carrier)
        denseWindowAtom ∧
      kplusOpen denseWindowFlow densePriorAtomMap denseWindowAtom (1 / 2) ∧
      ¬HasDedekindINF denseWindowFlow densePriorAtomMap :=
  ⟨semanticPriorU_of_dense_window, semanticPriorS_of_dense_window,
    denseWindow_endpoint_disjunct_forced.1, denseWindow_kplusOpen_at_half,
    hasDedekindINF_fails_on_dense_window⟩

/-! ## Anti-vacuity

The plan's gate, in both halves: a positive witness for the new hypothesis, and the re-base
corollary showing the weakening is **strict**. -/

/-- **Anti-vacuity, positive**: the faithful carrier holds on Phase 9's dense window flow, by
    instantiating `prior_hasFaithfulDedekindINF_dense` at `semanticPriorU_of_dense_window`. -/
theorem hasFaithfulDedekindINF_of_dense_window :
    HasFaithfulDedekindINF denseWindowFlow densePriorAtomMap :=
  prior_hasFaithfulDedekindINF_dense _ _ semanticPriorU_of_dense_window

/-- **Anti-vacuity, positive, mirrored.** -/
theorem hasFaithfulDedekindSUP_of_dense_window :
    HasFaithfulDedekindSUP denseWindowFlow densePriorAtomMap :=
  prior_hasFaithfulDedekindSUP_dense _ _ semanticPriorS_of_dense_window

/-- **Anti-vacuity, re-base corollary**: the weakening `HasDedekindINF → HasFaithfulDedekindINF`
    is **strict**, and consumed.

    `denseWindowFlow` satisfies both dense Prior hypotheses, satisfies the faithful carrier, and
    **refutes** `HasDedekindINF` (`hasDedekindINF_fails_on_dense_window`,
    `DedekindINFDense.lean:526`). So the shim is not an equivalence in disguise and the re-base
    buys something real: a structure the faithful carrier admits and the tree's carrier does not.

    Note that this is the *same* separation `hasGuardedDedekindINF_not_implies_hasDedekindINF`
    (`DedekindINFDense.lean:554`) records for the guarded carrier — but obtained here with **no
    guard and no third disjunct**. -/
theorem hasFaithfulDedekindINF_not_implies_hasDedekindINF :
    ∃ (M : OrderedMonadicStructure densePriorSig) (atomMap : Formula → densePriorSig.preds),
      SemanticPriorU M atomMap ∧ SemanticPriorS M atomMap ∧
        HasFaithfulDedekindINF M atomMap ∧ ¬HasDedekindINF M atomMap :=
  ⟨denseWindowFlow, densePriorAtomMap, semanticPriorU_of_dense_window,
    semanticPriorS_of_dense_window, hasFaithfulDedekindINF_of_dense_window,
    hasDedekindINF_fails_on_dense_window⟩

/-- **The mirrored re-base corollary.** -/
theorem hasFaithfulDedekindSUP_not_implies_hasDedekindSUP :
    ∃ (M : OrderedMonadicStructure densePriorSig) (atomMap : Formula → densePriorSig.preds),
      SemanticPriorU M atomMap ∧ SemanticPriorS M atomMap ∧
        HasFaithfulDedekindSUP M atomMap ∧ ¬HasDedekindSUP M atomMap :=
  ⟨denseWindowFlow, densePriorAtomMap, semanticPriorU_of_dense_window,
    semanticPriorS_of_dense_window, hasFaithfulDedekindSUP_of_dense_window,
    hasDedekindSUP_fails_on_dense_window⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
