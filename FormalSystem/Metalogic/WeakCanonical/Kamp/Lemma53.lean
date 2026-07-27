/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAFormula
import FormalSystem.Metalogic.WeakCanonical.Kamp.PriorINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.OnBuilder
import Mathlib.Data.List.OfFn

/-!
# Rabinovich Lemma 5.3 (PDF p.8): the `Oₙ` induction, all `βᵢ` equivalent to True

Transcribes the instance of Lemma 5.1 that Rabinovich proves first (PDF p.8), stated for the
case where `α₀`, `αₙ` and all `βᵢ` are equivalent to True:

> **Lemma 5.3.** `¬∃x₁…∃xₙ (z₀ < x₁ < ⋯ < xₙ < z₁) ∧ ⋀ᵢ₌₁ⁿ Pᵢ(xᵢ)` is equivalent over Dedekind
> complete chains to a `∨∃⃗∀` formula `Oₙ(P₁,…,Pₙ,z₀,z₁)`.

Cite Rabinovich by **PDF page only**. The companion `.md` conversion is corrupt: it drops every
displayed equation — and Lemma 5.3 *is* displayed equations — and inverts `k ≠ m` to `k = m`.

## The printed proof (PDF p.8), verbatim in structure

Induction on `n`.

* **Basis.** `¬(∃x₁)^{<z₁}_{>z₀}P₁(x₁)` is equivalent to `(∀y)^{<z₁}_{>z₀}¬P₁(y)`.
* **Inductive step** `n ↦ n+1`. Assuming a `∨∃⃗∀` formula `Oₙ` has been defined, `Oₙ₊₁` is the
  disjunction of "`(z₀,z₁)` is empty" and:
  1. `(∀y)^{<z₁}_{>z₀}¬P₁(y)`
  2. `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`
  3. `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁))`

  where eq (5.2) is
  `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀}¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))`.

  The paper's Case 2 obtains `r₀ := inf{z ∈ (z₀,z₁) | P₁(z)}` "by Dedekind completeness", and
  splits on `r₀ = z₀` (which holds **iff** `K⁺(P₁)(z₀)`, giving disjunct 2) versus
  `r₀ ∈ (z₀,z₁)` (giving disjunct 3).

## Why `Oₙ` must be *syntax*, not a predicate

`Oₙ` is quantified as a **formula** — an inhabitant of `VVecEA2` — and hoisted out of `M`,
`atomMap`, `z₀`, `z₁`. This is not incidental packaging; it is the entire content. Were `Oₙ`
allowed to be an arbitrary `Prop`-valued predicate, the statement would be discharged by taking
`Oₙ := ¬(bracket holds)` itself and would say nothing whatsoever — the same contentless-witness
failure `Prop42Vacuity.lean` refutes for `∃ v', v'.holds`. The claim has content precisely
because `Oₙ` must live in the `∨∃⃗∀` syntactic class and must be uniform in the model and in the
points.

## Scope of this file, and the eq (5.2) boundary

Landed here, sorry-free:

* `allTopBracket` — Lemma 5.3's left-hand side as a `BracketFormula` (Notation 5.2 with every
  `βᵢ` instantiated to `⊤`), plus the characterization collapsing the vacuous segment clauses.
* `kplus_formula_correct` — `K⁺(P₁)` as an **atom of the canonical expansion** (p.8: "`K⁺(P₁)(z₀)`
  is an atomic (and hence a `∨∃⃗∀`) formula in the canonical expansion"). `kplus_formula`
  (`PriorINF.lean:87`) already had the right definition but carried **no correctness lemma and no
  reference anywhere in the tree**; the printed proof's disjuncts (2) and (3) both need it.
* `lemma53_basis` — the printed Basis, `n = 1`.
* `O_zero_correct` — the `n = 0` degenerate case.

**Not landed here: the inductive step.** Its disjuncts (2) and (3) consume eq (5.2), which is
Phase 5's target. The phase boundary is respected rather than papered over with an inlined `INF`
construction. See `lemma53` below for the exact boundary and what discharging it requires.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## The `⊤` instantiation idiom

Rabinovich instantiates unused slots to True. `TemporalPred.top` is the live spelling, matching
`BracketFormula.trivial` (`VecEAFormula.lean:305`). -/

/-- `⊤` holds at every point. This is what makes the "all `βᵢ` equivalent to True" instantiation
    of Notation 5.2 collapse to a bare witness-existence claim.

    Source correspondence: Rabinovich 2014, Lemma 5.3, PDF p.8 (the `βᵢ = True` instance). -/
theorem TemporalPred.top_eval_at {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier) :
    TemporalPred.top.eval_at M atomMap t := by
  simp only [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]
  exact id

/-! ## Lemma 5.3's left-hand side (Notation 5.2, all `βᵢ` = True) -/

/-- Lemma 5.3's left-hand side as a bracket formula: `[⊤, P₁, ⊤, …, Pₙ, ⊤](z₀,z₁)`, i.e.
    Notation 5.2's `[α₀, β₁, …, αₙ₋₁, βₙ, αₙ]` with every `βᵢ` (and both `α₀`, `αₙ`)
    instantiated to True and the point types taken to be `P₁,…,Pₙ`.

    `(allTopBracket P).holds M atomMap z₀ z₁` unfolds to
    `∃x₁…∃xₙ (z₀ < x₁ < ⋯ < xₙ < z₁) ∧ ⋀ᵢ Pᵢ(xᵢ)` — Lemma 5.3's LHS under the `¬`.

    Source correspondence: Rabinovich 2014, Notation 5.2 and Lemma 5.3, PDF p.8. -/
def allTopBracket {n : Nat} (P : Fin n → TemporalPred) : BracketFormula n :=
  { pointTypes := P
    segmentTypes := fun _ => TemporalPred.top }

/-- With every `βᵢ` equal to `⊤`, all segment clauses of `BracketFormula.holds` are vacuous, and
    the bracket collapses to exactly Lemma 5.3's `∃x₁…∃xₙ (z₀ < x₁ < ⋯ < xₙ < z₁) ∧ ⋀ᵢ Pᵢ(xᵢ)`.

    This is the lemma that makes `allTopBracket` legible as the paper's LHS rather than merely
    asserted to be it.

    Source correspondence: Rabinovich 2014, Lemma 5.3, PDF p.8. -/
theorem allTopBracket_holds_succ {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier) :
    (allTopBracket P).holds M atomMap z0 z1 ↔
      ∃ x : Fin (n + 1) → M.carrier,
        (∀ i j : Fin (n + 1), i < j → x i < x j) ∧
        (∀ i : Fin (n + 1), z0 < x i ∧ x i < z1) ∧
        (∀ i : Fin (n + 1), (P i).eval_at M atomMap (x i)) := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, allTopBracket,
    IntervalPattern.holds]
  constructor
  · rintro ⟨x, h_inc, h_in, h_pt, -, -, -⟩
    exact ⟨x, h_inc, h_in, h_pt⟩
  · rintro ⟨x, h_inc, h_in, h_pt⟩
    exact ⟨x, h_inc, h_in, h_pt,
      fun y _ _ => TemporalPred.top_eval_at M atomMap y,
      fun _ y _ _ => TemporalPred.top_eval_at M atomMap y,
      fun y _ _ => TemporalPred.top_eval_at M atomMap y⟩

/-- The `n = 0` bracket holds on every interval: with no witnesses to place and the sole segment
    type `⊤`, the requirement is empty. Hence Lemma 5.3's LHS is `¬True` at `n = 0`, and `O₀` is
    the empty disjunction.

    Source correspondence: Rabinovich 2014, Lemma 5.3, PDF p.8 (degenerate case below the
    printed Basis, which starts at `n = 1`). -/
theorem allTopBracket_zero_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin 0 → TemporalPred) (z0 z1 : M.carrier) :
    (allTopBracket P).holds M atomMap z0 z1 := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, allTopBracket,
    IntervalPattern.holds]
  exact fun y _ _ => TemporalPred.top_eval_at M atomMap y

/-! ## `K⁺(P₁)` as an atom of the canonical expansion (PDF p.8)

The printed proof asserts: *"`K⁺(P₁)(z₀)` is an atomic (and hence a `∨∃⃗∀`) formula in the
canonical expansion"*. Both disjunct (2) and eq (5.2)'s third conjunct depend on it.

`kplus_formula` (`PriorINF.lean:87`) already spells this correctly as `¬P ∧ ¬(⊤ U ¬P)` — note
`Formula.untl target between`, so `untl ⊤ P.neg` at `t` reads "`∃s > t` with `¬P` throughout
`(t,s)`", whose negation is `∀s > t, ∃r ∈ (t,s), P(r)`. But it carried **no correctness lemma and
no reference anywhere in the tree**, so it was an advertised definition, not a usable one. This
supplies the missing correctness statement. -/

/-- `kplus_formula P` defines `K⁺(P)` in the object language: its truth at `t` is exactly the
    semantic `kplus M atomMap P t`.

    This is what licenses the paper's claim that `K⁺(P₁)(z₀)` may be used as an atom of the
    canonical expansion, and hence that disjuncts (2) and (3) stay inside the `∨∃⃗∀` class.

    Source correspondence: Rabinovich 2014, Lemma 5.3 proof and eq (5.2), PDF p.8. -/
theorem kplus_formula_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Formula) (t : M.carrier) :
    temporal_truth M atomMap t (kplus_formula P) ↔ kplus M atomMap P t := by
  simp only [kplus_formula, kplus, Formula.and, Formula.neg, Formula.top, temporal_truth]
  constructor
  · intro h
    refine ⟨fun hP => ?_, fun s hs => ?_⟩
    · exact h (fun hnP => absurd hP hnP)
    · by_contra h_no
      push Not at h_no
      refine h (fun _ h_untl => h_untl ⟨s, hs, fun h0 => h0, fun r hr1 hr2 hPr => ?_⟩)
      exact h_no r hr1 hr2 hPr
  · rintro ⟨hnP, h_dense⟩ h
    refine h (fun hP => absurd hP hnP) ?_
    rintro ⟨s, hs, -, h_none⟩
    obtain ⟨r, hr1, hr2, hPr⟩ := h_dense s hs
    exact h_none r hr1 hr2 hPr

/-! ## `Oₙ`: the `∨∃⃗∀` right-hand side

`Oₙ` is a `VVecEA2` — a disjunction of `endpointLeft(z₀) ∧ endpointRight(z₁) ∧ bracket(z₀,z₁)`
blocks. `VVecEA2` rather than `VBracketFormula` is forced by disjunct (2), which conjoins the
endpoint predicate `K⁺(P₁)` at `z₀`. -/

/-- `O₀ := ⊥`, the empty disjunction. Matches `¬True`: the `n = 0` bracket holds everywhere
    (`allTopBracket_zero_holds`), so its negation holds nowhere.

    Source correspondence: Rabinovich 2014, Lemma 5.3, PDF p.8. -/
def O_zero : VVecEA2 := ⟨[]⟩

/-- `O₀` correctly negates the `n = 0` bracket: both sides are `False`.

    Source correspondence: Rabinovich 2014, Lemma 5.3, PDF p.8. -/
theorem O_zero_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin 0 → TemporalPred) (z0 z1 : M.carrier) :
    O_zero.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1 := by
  simp only [O_zero, VVecEA2.holds, List.not_mem_nil, false_and, exists_false]
  constructor
  · exact False.elim
  · intro h
    exact h (allTopBracket_zero_holds M atomMap P z0 z1)

/-- `O₁(P₁,z₀,z₁) := (∀y)^{<z₁}_{>z₀}¬P₁(y)` — the Basis of the printed induction, as a
    single-disjunct `∨∃⃗∀` formula: no witnesses, both endpoints `⊤`, sole segment type `¬P₁`.

    Source correspondence: Rabinovich 2014, Lemma 5.3 Basis, PDF p.8. -/
def O_one (P1 : TemporalPred) : VVecEA2 :=
  ⟨[⟨0, VecEA2.fromBracket (BracketFormula.trivial P1.neg)⟩]⟩

/-- **Lemma 5.3, Basis (PDF p.8)**, verbatim:
    `¬(∃x₁)^{<z₁}_{>z₀}P₁(x₁)` is equivalent to `(∀y)^{<z₁}_{>z₀}¬P₁(y)`.

    Needs no Dedekind completeness and no `INF`: it is the pure duality of `∃` and `∀` over the
    open interval. Note the equivalence is unconditional in `z₀`, `z₁` — it does not require
    `z₀ < z₁`, since both sides are vacuously true on an empty interval.

    Source correspondence: Rabinovich 2014, Lemma 5.3 Basis, PDF p.8. -/
theorem lemma53_basis {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin 1 → TemporalPred) (z0 z1 : M.carrier) :
    (O_one (P 0)).holds M atomMap z0 z1 ↔
      ¬(allTopBracket P).holds M atomMap z0 z1 := by
  rw [allTopBracket_holds_succ]
  simp only [O_one, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
  constructor
  · rintro h_all ⟨x, -, h_in, h_pt⟩
    have h_neg := h_all (x 0) (h_in 0).1 (h_in 0).2
    simp only [TemporalPred.eval_at, TemporalPred.neg, Formula.neg, temporal_truth] at h_neg
    exact h_neg (h_pt 0)
  · intro h_no y hy0 hy1
    simp only [TemporalPred.eval_at, TemporalPred.neg, Formula.neg, temporal_truth]
    intro h_Py
    refine h_no ⟨fun _ => y, ?_, fun _ => ⟨hy0, hy1⟩, ?_⟩
    · -- `Fin 1` has no strictly increasing pair, so this clause is vacuous.
      intro i j hij
      exfalso
      have hi := i.isLt
      have hj := j.isLt
      rw [Fin.lt_def] at hij
      omega
    · -- The sole witness index is `0`, where `P 0` holds by `h_Py`.
      intro i
      have hi : i = 0 := Fin.ext (by have := i.isLt; omega)
      rw [hi]
      exact h_Py

/-! ## The inductive step, and the eq (5.2) boundary

Disjuncts (2) and (3) of the printed construction both consume eq (5.2) — disjunct (3) contains
`INF(z₀,r₀,z₁,P₁)` outright, and disjunct (2) is precisely the `r₀ = z₀` subcase of the Case 2
`r₀ := inf{z ∈ (z₀,z₁) | P₁(z)}` construction. eq (5.2) is Phase 5's target, so the inductive
step stops here rather than inlining an `INF` construction.

`lemma53` below is therefore a **skeleton**: `n = 0` and `n = 1` are discharged outright from the
sorry-free lemmas above, and the strategic sorry is isolated to `n ≥ 2` — the step that needs
eq (5.2). -/

/-- **`HasDefinableINF` is not the eq (5.2) carrier: it silently deletes disjunct (2).**

    Assuming `HasDefinableINF` (`PriorINF.lean:108`) makes the `K⁺(P₁)(z₀)` case *unreachable*
    whenever `P₁` occurs in `(z₀,z₁)` — which is exactly the case p.8's disjunct (2)
    `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` exists to handle, and exactly the paper's
    `Subcase r₀ = z₀` (p.8: *"Note that `r₀ = z₀` iff `K⁺(P₁)(z₀)`"*).

    **This is machine-checked, not asserted.** The proof is immediate: `first_occ` hands back an
    `r₀ > z₀` with `¬P₁` throughout `(z₀,r₀)`, while `K⁺(P₁)(z₀)` says `P₁` occurs in *every*
    interval above `z₀` — instantiate the latter at `r₀` and the two collide.

    **Consequence for the transcription.** Rabinovich's Lemma 5.3 is claimed over *all* Dedekind
    complete chains, and `HasDefinableINF` does not hold over all of them: on `ℝ` with `P₁`
    interpreted as `{x | x > 0}` and `z₀ = 0`, `inf{z ∈ (0,1) | P₁(z)} = 0 = z₀`, so no `r₀ > z₀`
    has `¬P₁` below it and `first_occ` fails — yet `ℝ` is Dedekind complete and the paper handles
    this structure via disjunct (2). So `HasDefinableINF` is **strictly stronger** than the
    Dedekind completeness Lemma 5.3 assumes.

    The faithful eq (5.2) carrier is the *disjunction* of the paper's two subcases:
    `K⁺(P₁)(z₀) ∨ (∃r₀ ∈ (z₀,z₁), z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀}¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀)))`
    — `HasDefinableINF` is the right disjunct alone (modulo `r₀ ≤ z₁` vs `r₀ < z₁`).

    Constructing that carrier is Phase 5's task ("reconcile with `PriorINF.lean` … verify the
    correspondence rather than assuming it; **record the delta if it does not**"). This theorem
    *is* that delta, recorded as a machine-checked fact rather than a claim.

    Source correspondence: Rabinovich 2014, Lemma 5.3 proof, Case 2 and its `Subcase r₀ = z₀`,
    and eq (5.2), PDF p.8. -/
theorem hasDefinableINF_excludes_kplus {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_inf : HasDefinableINF M atomMap)
    (P : Formula) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ temporal_truth M atomMap x P) :
    ¬kplus M atomMap P z0 := by
  rintro ⟨-, h_dense⟩
  obtain ⟨r0, h_z0_r0, -, h_none, -⟩ := h_inf.first_occ P z0 z1 h_lt h_occ
  obtain ⟨r, hr1, hr2, hPr⟩ := h_dense r0 h_z0_r0
  exact h_none r hr1 hr2 hPr

/-! ## The `allTopBracket` ↔ `chainAllTrue` bridge

The inductive step does **not** need to be transcribed here: it is already in the tree, as
`negChainOn_iff` (`EANegationFix/OnBuilder.lean:159`), which is Lemma 5.3 in fixed-formula form
over `List TemporalPred` and on the **attained** carrier. See
`Kamp/Section5Correspondence.lean` for the full page-cited correspondence table — that guard
exists because this transcription was re-planned from scratch more than once while present and
sorry-free.

What is left is bookkeeping: `negChainOn_iff` is phrased against `chainAllTrue Ps` for
`Ps : List TemporalPred`, and `lemma53` is phrased against `allTopBracket P` for
`P : Fin n → TemporalPred`. The two brackets are the *same object* — both are
`{pointTypes := ·, segmentTypes := fun _ => ⊤}` — so the bridge is `List.ofFn` plus a
`Fin`-cast, not mathematics. -/

/-- The `Fin`-reindexing congruence for `allTopBracket`. Needed because `List.ofFn P` has length
    *propositionally* `n`, not definitionally, so `chainAllTrue (List.ofFn P)` and
    `allTopBracket P` live at indices that must be transported. -/
theorem allTopBracket_congr {sig : MonadicSignature} {n m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h : n = m) (P : Fin n → TemporalPred) (Q : Fin m → TemporalPred)
    (hPQ : ∀ i : Fin n, P i = Q (Fin.cast h i)) (z0 z1 : M.carrier) :
    (allTopBracket P).holds M atomMap z0 z1 ↔ (allTopBracket Q).holds M atomMap z0 z1 := by
  subst h
  have hEq : P = Q := funext fun i => by simpa using hPQ i
  subst hEq
  exact Iff.rfl

/-- `chainAllTrue Ps` **is** `allTopBracket (Ps.get ·)` — the same structure literal, so this is
    `rfl`. This is what makes `negChainOn_iff` directly reusable here. -/
theorem chainAllTrue_eq_allTopBracket (Ps : List TemporalPred) :
    chainAllTrue Ps = allTopBracket (fun i => Ps.get i) := rfl

/-- The bridge: `chainAllTrue (List.ofFn P)` and `allTopBracket P` hold on exactly the same
    intervals. -/
theorem chainAllTrue_ofFn_iff_allTopBracket {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin n → TemporalPred) (z0 z1 : M.carrier) :
    (chainAllTrue (List.ofFn P)).holds M atomMap z0 z1 ↔
      (allTopBracket P).holds M atomMap z0 z1 := by
  rw [chainAllTrue_eq_allTopBracket]
  exact allTopBracket_congr M atomMap (List.length_ofFn) _ P
    (fun i => List.get_ofFn P i) z0 z1

/-- Lift a `VBracketFormula` into `VVecEA2` with `⊤` endpoints. `negChainOn` produces a
    `VBracketFormula`; `lemma53` is stated in `VVecEA2` (forced by disjunct (2), which conjoins
    an endpoint predicate). -/
def VBracketFormula.toVVecEA2 (v : VBracketFormula) : VVecEA2 :=
  ⟨v.disjuncts.map fun bf => ⟨bf.1, VecEA2.fromBracket bf.2⟩⟩

/-- The lift is semantically transparent: `⊤` endpoints contribute nothing. -/
theorem VBracketFormula.toVVecEA2_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VBracketFormula) (z0 z1 : M.carrier) :
    v.toVVecEA2.holds M atomMap z0 z1 ↔ v.holds M atomMap z0 z1 := by
  simp only [toVVecEA2, VVecEA2.holds, VBracketFormula.holds, List.mem_map]
  constructor
  · rintro ⟨_, ⟨⟨m, bf⟩, hmem, rfl⟩, hh⟩
    exact ⟨⟨m, bf⟩, hmem, (VecEA2.fromBracket_holds M atomMap bf z0 z1).mp hh⟩
  · rintro ⟨⟨m, bf⟩, hmem, hh⟩
    exact ⟨⟨m, VecEA2.fromBracket bf⟩, ⟨⟨m, bf⟩, hmem, rfl⟩,
      (VecEA2.fromBracket_holds M atomMap bf z0 z1).mpr hh⟩

/-- A bracket with at least one witness can only hold on a non-empty interval: the witness has
    to fit strictly inside. This discharges the `¬(z₀ < z₁)` case, where `negChainOn_iff` does
    not apply. -/
theorem allTopBracket_succ_lt {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : Fin (n + 1) → TemporalPred) (z0 z1 : M.carrier)
    (h : (allTopBracket P).holds M atomMap z0 z1) : z0 < z1 := by
  rw [allTopBracket_holds_succ] at h
  obtain ⟨x, -, h_in, -⟩ := h
  exact lt_trans (h_in 0).1 (h_in 0).2

/-- On an empty interval, a non-empty `negChainOn` holds outright: its never-`P₁` disjunct
    `[¬P₁]` is vacuously satisfied when there is no point strictly between. -/
theorem negChainOn_holds_of_not_lt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) (hne : Ps ≠ []) (z0 z1 : M.carrier) (h : ¬ z0 < z1) :
    (negChainOn Ps).holds M atomMap z0 z1 := by
  match Ps with
  | [] => exact absurd rfl hne
  | P :: rest =>
    refine ⟨⟨0, BracketFormula.trivial P.neg⟩, by simp [negChainOn], ?_⟩
    rw [BracketFormula.trivial_holds]
    intro y hy0 hy1
    exact absurd (lt_trans hy0 hy1) h

/-- **Lemma 5.3 (PDF p.8)** — target statement.

    `¬∃x₁…∃xₙ (z₀ < x₁ < ⋯ < xₙ < z₁) ∧ ⋀ᵢ₌₁ⁿ Pᵢ(xᵢ)` is equivalent over Dedekind complete
    chains to a `∨∃⃗∀` formula `Oₙ(P₁,…,Pₙ,z₀,z₁)`.

    **The shape carries the content.** `O` is hoisted out of `M`, `atomMap`, `z₀` and `z₁`, so it
    is a function of `P` alone — uniform in the model and in the points, which is what "is
    equivalent to a `∨∃⃗∀` formula" means. The per-point ordering
    `∀ M atomMap z₀ z₁, ∃ O, O.holds ↔ ¬…` is **vacuous** and must never be accepted here: with
    the points fixed, `¬(allTopBracket P).holds` is a fixed truth value, so one picks the all-`⊤`
    block when it is true and `O_zero` when it is false. That control was established by a
    vacuity probe which compiles for the vacuous ordering and fails for this one.

    **STATUS: sorry-free, at the ATTAINED carrier.** `n = 0` and `n = 1` (the printed Basis) are
    discharged outright from `O_zero_correct` and `lemma53_basis`, neither of which touches the
    `INF` hypothesis. The `n ≥ 2` arm — the printed inductive step, whose disjuncts (2) and (3)
    consume eq (5.2) — is discharged from `negChainOn_iff` (`EANegationFix/OnBuilder.lean:159`),
    which already transcribes exactly that induction, via the `allTopBracket` ↔ `chainAllTrue`
    bridge above.

    **What the carrier excludes — read before citing.** The hypothesis is `HasAttainedINF`, which
    is **strictly stronger** than the Dedekind completeness this lemma is claimed over in the
    paper. It is stronger even than `HasDefinableINF`, which `hasDefinableINF_excludes_kplus`
    above machine-refutes as *already* too strong: it deletes the paper's disjunct (2)
    `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`. The strengthening chain is

        Rabinovich's Dedekind completeness < HasDedekindINF (faithful) < HasDefinableINF
                                          < HasAttainedINF  ← what is assumed here

    so **this is Lemma 5.3 restricted to attained structures, not Lemma 5.3**. `OnBuilder.lean`'s
    own docstring admits the same deviation ("the K⁺ disjunct is vacuous"). The prior
    `HasDefinableINF` hypothesis was not faithful either and has been replaced rather than
    reused: it was strictly weaker than what the proof needs, and strictly stronger than what the
    paper assumes.

    Building the **faithful** carrier — the disjunction of the paper's two subcases,
    `K⁺(P₁)(z₀) ∨ (∃r₀ ∈ (z₀,z₁), …)` — is separately owned and is not done here. Reaching it
    additionally needs `BracketFormula.cons` (a witness-shifting prepend; `VecEAFormula.lean` has
    `leftPart`/`rightPart` but no prepend) and `TemporalPred` disjunction (`VecEAFormula.lean` has
    `neg` and `conj` but no `disj`), which disjunct (3)'s point type `P₁ ∨ K⁺(P₁)` needs.

    Source correspondence: Rabinovich 2014, Lemma 5.3, PDF p.8; correspondence table in
    `Kamp/Section5Correspondence.lean`. -/
theorem lemma53 {sig : MonadicSignature} {n : Nat} (P : Fin n → TemporalPred) :
    ∃ O : VVecEA2, ∀ (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds),
      HasAttainedINF M atomMap →
      ∀ z0 z1 : M.carrier,
        O.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1 := by
  match n, P with
  | 0, P =>
    -- `O₀ := ⊥`; the `n = 0` bracket holds everywhere, so its negation holds nowhere.
    exact ⟨O_zero, fun M atomMap _ z0 z1 => O_zero_correct M atomMap P z0 z1⟩
  | 1, P =>
    -- The printed Basis (p.8): `O₁ := (∀y)^{<z₁}_{>z₀}¬P₁(y)`. Needs no `INF`.
    exact ⟨O_one (P 0), fun M atomMap _ z0 z1 => lemma53_basis M atomMap P z0 z1⟩
  | (k + 2), P =>
    -- The printed inductive step (p.8), already transcribed as `negChainOn` / `negChainOn_iff`
    -- on the attained carrier. `O` is `negChainOn (List.ofFn P)` lifted to `VVecEA2`; it is a
    -- function of `P` alone, as the hoisted shape demands.
    refine ⟨(negChainOn (List.ofFn P)).toVVecEA2, fun M atomMap h_INF z0 z1 => ?_⟩
    rw [VBracketFormula.toVVecEA2_holds]
    by_cases hlt : z0 < z1
    · -- Non-empty interval: `negChainOn_iff` applies; the bridge re-indexes its `chainAllTrue`.
      rw [negChainOn_iff M atomMap h_INF _ z0 z1 hlt]
      exact not_congr (chainAllTrue_ofFn_iff_allTopBracket M atomMap P z0 z1)
    · -- Empty interval: both sides hold. No witness fits, so the bracket fails; and the
      -- never-`P₁` disjunct of `negChainOn` is vacuously satisfied.
      constructor
      · intro _ hb
        exact hlt (allTopBracket_succ_lt M atomMap P z0 z1 hb)
      · intro _
        exact negChainOn_holds_of_not_lt M atomMap (List.ofFn P)
          (by simp) z0 z1 hlt

end Bimodal.Metalogic.WeakCanonical.Kamp
