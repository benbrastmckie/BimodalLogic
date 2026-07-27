/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAFormula

/-!
# The contentful Proposition 4.2: target statement, endpoint cases, Section 5 route

This file states the **target** that `Prop42Vacuity.lean` shows the tree does not yet have:
Rabinovich's actual Proposition 4.2, in a shape that is not satisfiable by the all-`⊤` block.
It then proves the fragment of that target which needs no `INF` machinery — the two endpoint
(de Morgan) cases — and records the Section 5 dependency chain the remaining bracket case
consumes.

Cite Rabinovich by **PDF page only**. The companion `.md` conversion is corrupt: it drops
displayed equations and inverts `k ≠ m` to `k = m`.

## The shape, and why the shape is the whole point

`Prop42Contentful` below hoists `v'` **out** of the point quantifiers:

```
∃ v', ∀ z0 z1, z0 < z1 → (v'.holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1)
```

Both weaker orderings are vacuous and must never be accepted as Proposition 4.2:

* `∀ z0 z1, ∃ v', v'.holds z0 z1` — closed by the all-`⊤` block. This is the shape
  `neg_2var_vec_ea` (`EANegationClosure.lean:722`) actually has; refuted from no hypotheses at
  all by `prop42_conclusion_is_vacuous` (`Prop42Vacuity.lean`).
* `∀ z0 z1, ∃ v', (v'.holds z0 z1 ↔ ¬v.holds z0 z1)` — **also** vacuous. With `z0`, `z1` fixed,
  `¬v.holds z0 z1` is a fixed truth value, so one picks the all-`⊤` block when it is true and
  an unsatisfiable block when it is false. The biconditional alone does not rescue it; the
  quantifier order does.

Hoisting `v'` forces it to be a function of `v` alone, uniform in the points — which is what
"the negation of a vec-EA formula *is itself* a vec-EA formula" means.

## Non-vacuity is compiler-checked, not asserted

`prop42_contentful_endpoint_instance` proves `Prop42Contentful` for the endpoint-only fragment.
That the target is *satisfiable* is therefore not in doubt. That it is *not trivially*
satisfiable is the content of `Prop42Vacuity.lean` plus the failed-vacuity check recorded in
this file's phase artifacts: the all-`⊤` block, which discharges the vacuous shape from nothing,
does **not** discharge `Prop42Contentful` — the `←` direction of the biconditional demands a
block that fails wherever `v` holds, and `⊤` fails nowhere.

## Section 5 dependency map for the remaining bracket case

The endpoint cases below are Case 1 of Lemma 5.1's proof (PDF p.9). The bracket case is what
Section 5 exists to supply, in this order:

| Result | PDF page | What it supplies |
|---|---|---|
| Notation 5.2 — `[α₀, β₁, …, αₙ₋₁, βₙ, αₙ](z₀,z₁)` | p.8 | The bracket object; `BracketFormula`
matches it |
| Lemma 5.3 — `¬∃x₁…xₙ(z₀<x₁<…<xₙ<z₁) ∧ ⋀Pᵢ(xᵢ)` is `∨∃⃗∀` | p.8 | Base machinery, induction on
`n`, all `βᵢ` = True |
| eq (5.2) — `INF(z₀,r₀,z₁,P₁)`, `r₀ := inf{z ∈ (z₀,z₁) \| P₁(z)}` | p.8 | Lemma 5.3 Case 2's
anchor; `r₀` **definable**, not chosen |
| Cor 5.4 — `Fₙ := αₙ`, `F₍ᵢ₋₁₎ := α₍ᵢ₋₁₎ ∧ (βᵢ Until Fᵢ)`, + Since mirror | p.9 | Generalizes
Lemma 5.3 to `βₙ` = True |
| Lemma 5.1 Case 1 — `¬α₀(z₀) ∨ K⁺(¬β₁)(z₀)` | p.9 | **The endpoint cases proved below.** No `INF`
needed |
| Lemma 5.1 Cases 2, 3 | pp.9-10 | Case 2 via Cor 5.4(2); Case 3 needs eq (5.3) |
| eq (5.3) — `INF^{¬β₁}(z₀,z,z₁)` | p.10 | Case 3's anchor; footnote 4: existence only, **no
uniqueness** |
| Closing induction — `Aᵢ`, `Bᵢ`, steps (a)-(e) | pp.10-11 | Discharges Case 3 |

### `INF` is the witness-pinning mechanism (PDF pp.10-11)

The recorded obstruction (`Boneyard/NegationIndep.lean:341-345`) is that the bracket's witnesses
are existential, so "the IH gives negation on a specific sub-interval `(r₀, z₁)` but the bracket
witness `w₀` could be `> r₀`, giving a different sub-interval `(w₀, z₁)`" — the arrangement
varies per model.

Rabinovich never faces this, because he never leaves the arrangement existential. Page 11 states
the decomposition that dissolves it: for the interval `(z₀,z₁)` non-empty,

```
[α₀, β₁, …, βₙ₊₁, αₙ₊₁](z₀,z₁)  ⇔  (∀z)^{<z₁}_{>z₀}(⋁ᵢ Aᵢ ∨ ⋁ᵢ Bᵢ)
[α₀, β₁, …, βₙ₊₁, αₙ₊₁](z₀,z₁)  ⇔  (∃z)^{<z₁}_{>z₀}(⋁ᵢ Aᵢ ∨ ⋁ᵢ Bᵢ)
```

Both quantifiers give the same thing, and that is the mechanism, not a curiosity: the `Aᵢ` /
`Bᵢ` family (p.10) is **exhaustive relative to an arbitrary fixed `z`** — every witness `xⱼ` is
either below `z` (`Aᵢ` splits the bracket at a segment containing `z`) or equal to it (`Bᵢ`
splits at a witness). So the decomposition holds *at whatever `z` one names*, and naming `z`
pins the arrangement without knowing where the witnesses are.

Negating at a fixed `z` therefore turns the per-model existential arrangement into a
**conjunction over a fixed split point** (p.11):

```
(∃z)^{<z₁}_{>z₀}φ(z) ∧ ¬[α₀, β₁, …, βₙ₊₁, αₙ₊₁](z₀,z₁)
  ⇔  (∃z)^{<z₁}_{>z₀}(φ(z) ∧ ⋀ⁿᵢ₌₁ ¬Aᵢ ∧ ⋀ⁿ⁺¹ᵢ₌₁ ¬Bᵢ)
```

and the induction hypothesis is then applied to the sub-intervals `(z₀,z)` and `(z,z₁)`, which
are fixed rather than witness-dependent. eq (5.3) supplies the `z` as `INF^{¬β₁}`, making it
definable; footnote 4 (p.10) waives uniqueness, so only existence is owed.

This is the sense in which Dedekind completeness is an anchor factory rather than a model
filter: it is what makes `inf{…}` exist so that `z` can be *named by a formula*.

### The hypothesis carrier for eq (5.2) / eq (5.3): use `HasDefinableINF`, not `HasAttainedINF`

Both live in `PriorINF.lean`. The faithful carrier is **`HasDefinableINF`** (`:108`), not
`HasAttainedINF` (`:202`):

* `HasDefinableINF.first_occ` concludes `… ∧ (temporal_truth M atomMap r0 P ∨ kplus M atomMap P
  r0)` — this is eq (5.2)'s `(P₁(r₀) ∨ K⁺(P₁)(r₀))` **verbatim**, `K⁺` disjunct included.
* `HasAttainedINF.first_occ` concludes `… ∧ temporal_truth M atomMap r0 P` — it **drops** the
  `K⁺` disjunct, and so is strictly stronger than what the paper assumes.

`HasAttainedINF` is nonetheless sound to use: `HasAttainedINF.toHasDefinableINF` (`:215`) proves
it implies the definable form, and `prior_hasAttainedINF` (`:224`) proves Prior structures
satisfy it outright ("the K⁺ case never arises"). But a Section 5 transcription that assumes it
is assuming more than Rabinovich does, and would silently drop the `K⁺` branch that p.8's
`Subcase r₀ = z₀` and p.10's eq (5.3) both explicitly carry. Transcribe against
`HasDefinableINF`; discharge via `prior_hasAttainedINF` only at the live-path boundary.

Note also that neither carrier covers p.8's `Subcase r₀ = z₀` (both require `z0 < r0`). That
subcase is not meant to be carried by the `INF` hypothesis — the paper handles it at the formula
level, via the disjunct `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` (p.8, item 2).

## Scope

The bracket case is **not** attempted here, and must not be attempted at the `BracketFormula`
level without the `INF` anchors above — that route is ruled unfixable by two independent
in-tree analyses (`Boneyard/NegationIndep.lean:346-364`) and is a three-strikes target.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- **Rabinovich's Proposition 4.2, contentfully stated** (2014, *Proof of Kamp's Theorem*,
    PDF p.6; proved in Section 5, pp.7-11).

    The negation of the `VVecEA2` formula `v` **is itself** a `VVecEA2` formula: there is a
    single `v'`, depending on `v` alone, that is equivalent to `¬v` at every pair of points.

    The `∃ v'` is hoisted outside `∀ z0 z1` deliberately. Both weaker orderings are vacuous —
    see this file's module docstring and `Prop42Vacuity.lean`. Any candidate Proposition 4.2
    that does not have this shape is rejected. -/
def Prop42Contentful {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) : Prop :=
  ∃ v' : VVecEA2, ∀ z0 z1 : M.carrier, z0 < z1 →
    (v'.holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1)

/-! ### Local helpers

`TemporalPred.eval_at_neg'` and the `⊤` facts already exist in `EANegationClosure.lean`, but
that module is not importable from here without dragging in the whole model-dependent negation
development (and its vacuous `neg_2var_vec_ea`). Both facts are one-line unfoldings, so they
are reproved locally under private names rather than imported. -/

/-- `(P.neg).eval_at` iff `¬(P.eval_at)`. Local copy of `TemporalPred.eval_at_neg'`
    (`EANegationClosure.lean:48`), which is not importable from this module. -/
private theorem tp_neg_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (t : M.carrier) :
    P.neg.eval_at M atomMap t ↔ ¬P.eval_at M atomMap t := by
  simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]

/-- `⊤` holds at every point. -/
private theorem tp_top_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) : TemporalPred.top.eval_at M atomMap t := by
  simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]

/-- The `⊤` bracket holds on every interval. -/
private theorem triv_top_bracket_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    (BracketFormula.trivial TemporalPred.top).holds M atomMap z0 z1 :=
  (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
    (fun y _ _ => tp_top_holds M atomMap y)

/-! ### The all-`⊤` block, and the two endpoint cases -/

/-- The all-`⊤` `VecEA2` block: the witness that makes the *vacuous* Prop 4.2 shape provable
    from no hypotheses (`prop42_conclusion_is_vacuous`, `Prop42Vacuity.lean`). Named here so
    the failed-vacuity check can be stated against the same object. -/
def topBlock : VecEA2 0 :=
  { endpointLeft := TemporalPred.top
    endpointRight := TemporalPred.top
    bracket := BracketFormula.trivial TemporalPred.top }

theorem topBlock_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    topBlock.holds M atomMap z0 z1 :=
  ⟨tp_top_holds M atomMap z0, tp_top_holds M atomMap z1,
   triv_top_bracket_holds M atomMap z0 z1⟩

/-- The all-`⊤` `VVecEA2`: the exact witness that discharges the vacuous Prop 4.2 shape from no
    hypotheses at all. -/
def topVVec : VVecEA2 := ⟨[⟨0, topBlock⟩]⟩

theorem topVVec_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    topVVec.holds M atomMap z0 z1 :=
  ⟨⟨0, topBlock⟩, List.mem_singleton.mpr rfl, topBlock_holds M atomMap z0 z1⟩

/-- **The failed-vacuity check, in positive form.**

    On the *vacuous* shape `∃ v', v'.holds z0 z1`, the all-`⊤` block is a free pass: it
    discharges the goal from nothing, for every `v`, which is precisely why that shape is not
    Proposition 4.2 (`prop42_conclusion_is_vacuous`, `Prop42Vacuity.lean`).

    On `Prop42Contentful` the same escape hatch is closed. Offering `topVVec` as `v'` does not
    discharge the goal — it *commits* the offerer to `v` being unsatisfiable on every ordered
    pair, as this theorem shows. Since `⊤` holds everywhere, the `→` direction of the
    biconditional forces `¬v.holds` everywhere. So `topVVec` witnesses `Prop42Contentful M
    atomMap v` only for the `v` that never hold, and cannot be used for a general `v`.

    That is the structural reason `Prop42Contentful` is non-vacuous, and it is checked here by
    the compiler rather than asserted in prose. The corresponding negative check — that the
    all-`⊤` proof term does **not** typecheck against `Prop42Contentful` — is recorded verbatim
    in this phase's handoff. -/
theorem topVVec_contentful_forces_unsat {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2)
    (h : ∀ z0 z1 : M.carrier, z0 < z1 →
          (topVVec.holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1)) :
    ∀ z0 z1 : M.carrier, z0 < z1 → ¬v.holds M atomMap z0 z1 :=
  fun z0 z1 hlt => (h z0 z1 hlt).mp (topVVec_holds M atomMap z0 z1)

/-- The `VecEA2` block asserting only `¬a(z0)`: Case 1a of `neg_vecEA2_indep`
    (`Boneyard/NegationIndep.lean:193`), and the left half of Lemma 5.1's Case 1 (PDF p.9,
    `¬α₀(z₀)`). -/
def endpointLeftNegBlock (a : TemporalPred) : VecEA2 0 :=
  { endpointLeft := a.neg
    endpointRight := TemporalPred.top
    bracket := BracketFormula.trivial TemporalPred.top }

/-- The `VecEA2` block asserting only `¬b(z1)`: Case 1b of `neg_vecEA2_indep`
    (`Boneyard/NegationIndep.lean:196`). -/
def endpointRightNegBlock (b : TemporalPred) : VecEA2 0 :=
  { endpointLeft := TemporalPred.top
    endpointRight := b.neg
    bracket := BracketFormula.trivial TemporalPred.top }

/-- **Endpoint case, left** (Rabinovich 2014, Lemma 5.1 Case 1, PDF p.9): the `¬α₀(z₀)`
    disjunct is sound for negation.

    This is a de Morgan step. It consumes **no** `INF` machinery, no Dedekind completeness, and
    no `HasAttainedINF` — matching the paper, where Case 1 is discharged by the remark that it
    "is already explicitly described by the `∨∃⃗∀` formula". -/
theorem endpointLeftNegBlock_sound {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier) :
    (endpointLeftNegBlock vea.endpointLeft).holds M atomMap z0 z1 →
    ¬vea.holds M atomMap z0 z1 := by
  rintro ⟨hNeg, -, -⟩ ⟨hL, -, -⟩
  exact (tp_neg_iff M atomMap vea.endpointLeft z0).mp hNeg hL

/-- **Endpoint case, right** (Rabinovich 2014, Lemma 5.1 Case 1, PDF p.9): the `¬αₙ(z₁)`
    disjunct is sound for negation. The mirror of `endpointLeftNegBlock_sound`; likewise free
    of `INF` machinery. -/
theorem endpointRightNegBlock_sound {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier) :
    (endpointRightNegBlock vea.endpointRight).holds M atomMap z0 z1 →
    ¬vea.holds M atomMap z0 z1 := by
  rintro ⟨-, hNeg, -⟩ ⟨-, hR, -⟩
  exact (tp_neg_iff M atomMap vea.endpointRight z1).mp hNeg hR

/-! ### A complete instance of the contentful shape

The two endpoint cases assemble into a **fully proved** instance of `Prop42Contentful` for the
endpoint-only fragment (bracket `⊤`, so the bracket contributes nothing). This is the cheapest
evidence that the hoisted shape is workable: `v'` is produced from `v` alone, both directions
of the biconditional hold, and no `INF` hypothesis is used. -/

/-- The endpoint-only fragment: `a(z0) ∧ b(z1)`, with a `⊤` bracket. -/
def endpointOnly (a b : TemporalPred) : VVecEA2 :=
  ⟨[⟨0, { endpointLeft := a, endpointRight := b,
          bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩

/-- Its negation, by de Morgan: `¬a(z0) ∨ ¬b(z1)`. A function of `a` and `b` alone. -/
def endpointOnlyNeg (a b : TemporalPred) : VVecEA2 :=
  ⟨[⟨0, endpointLeftNegBlock a⟩, ⟨0, endpointRightNegBlock b⟩]⟩

/-- **A complete, sorry-free instance of `Prop42Contentful`** (Rabinovich 2014, Lemma 5.1
    Case 1, PDF p.9).

    `Prop42Contentful` is satisfiable, and satisfiable by a `v'` built from `v` alone with both
    directions of the biconditional discharged — with no `HasAttainedINF` and no Dedekind
    completeness, exactly as the paper's Case 1 requires.

    Note what this does *not* do: it does not make `Prop42Contentful` trivially provable. The
    all-`⊤` block cannot serve as `v'` here (it holds everywhere, so it fails the `←`
    direction wherever `v` holds); the remaining bracket case is what Section 5's `INF` anchors
    exist to supply. -/
theorem endpointOnly_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (a b : TemporalPred) (z0 z1 : M.carrier) :
    (endpointOnly a b).holds M atomMap z0 z1 ↔
      (a.eval_at M atomMap z0 ∧ b.eval_at M atomMap z1) := by
  constructor
  · rintro ⟨vea, hmem, hA, hB, -⟩
    simp only [endpointOnly, List.mem_singleton] at hmem
    subst hmem
    exact ⟨hA, hB⟩
  · rintro ⟨hA, hB⟩
    exact ⟨_, List.mem_singleton.mpr rfl, hA, hB, triv_top_bracket_holds M atomMap z0 z1⟩

theorem endpointOnlyNeg_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (a b : TemporalPred) (z0 z1 : M.carrier) :
    (endpointOnlyNeg a b).holds M atomMap z0 z1 ↔
      (¬a.eval_at M atomMap z0 ∨ ¬b.eval_at M atomMap z1) := by
  constructor
  · rintro ⟨vea, hmem, hL, hR, -⟩
    simp only [endpointOnlyNeg, List.mem_cons, List.not_mem_nil, or_false] at hmem
    rcases hmem with h | h
    · subst h; exact Or.inl ((tp_neg_iff M atomMap a z0).mp hL)
    · subst h; exact Or.inr ((tp_neg_iff M atomMap b z1).mp hR)
  · rintro (hA | hB)
    · exact ⟨⟨0, endpointLeftNegBlock a⟩, by simp [endpointOnlyNeg],
             (tp_neg_iff M atomMap a z0).mpr hA, tp_top_holds M atomMap z1,
             triv_top_bracket_holds M atomMap z0 z1⟩
    · exact ⟨⟨0, endpointRightNegBlock b⟩, by simp [endpointOnlyNeg],
             tp_top_holds M atomMap z0, (tp_neg_iff M atomMap b z1).mpr hB,
             triv_top_bracket_holds M atomMap z0 z1⟩

theorem prop42_contentful_endpoint_instance {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (a b : TemporalPred) :
    Prop42Contentful M atomMap (endpointOnly a b) := by
  refine ⟨endpointOnlyNeg a b, fun z0 z1 _ => ?_⟩
  rw [endpointOnlyNeg_holds, endpointOnly_holds]
  tauto

end Bimodal.Metalogic.WeakCanonical.Kamp
