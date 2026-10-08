/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Saturation

/-!
# Step 5b — saturation proper, and the finite-family cover of a monadic target

**What this module is about, and what it is not.** The results below concern **targets
definable by a depth-`≤ k` monadic sentence over the coloured `ℤ`-block** — predicates on
colourings `c : sig.preds → ℤ → Prop` that depend only on `kTypeOf sig k (zFiber sig c)`. They
are **not** a decidability result, and they are **not** a statement about `⊡`: getting from a
`⊡` fibre condition over the seam-gluing path space to such a target is the seam interface's
business (`Decidability/RaySummary/SeamMulti.lean`), where it is a finite conjunction over the
realized family triples with no hypothesis bundle — and where the realized set is named as not
computed. This module does not attempt it. No complexity bound is claimed, here or anywhere in
the cluster.

**The chain correspondence.** This is Büchi's step 5 in his own shape (Thomas 1997, *Languages,
Automata, and Logic*, §5.1, p. 30): each family `(τneg)^(ω*) · τzero · (τpos)^ω` is **wholly
inside or wholly disjoint from** the target (`family_saturation`), and — since there are
finitely many family triples (`finite_family_triples`, from step 2's `kType_finite`) — the target
is the union of the families it contains (`target_eq_union_of_families`). The structural
references in cslib are `Cslib.Automata.NA.Buchi.buchiFamily_saturation` and
`Cslib.ωLanguage.IsRegular.fin_cover_saturates_compl`; they are cited for shape and not
depended on. The hinge is step 5a: the block `k`-type is a function of the family
(`kTypeOf_zFiber_eq_of_inFamily`, `Saturation.lean`), so a `k`-type-determined target cannot
distinguish two members of one family.

**The abstraction is non-vacuous.** `DeterminedByKType` is the abstract hypothesis "the target
is determined by the block's `k`-type"; `determinedByKType_nfEval` exhibits the intended
instances — the truth of any depth-`k` normal form `nf` on the block — so the saturation theorem
has something to apply to. It is proved by unfolding `kTypeOf` and reading the `nf`-coordinate
of the `k`-type equation, exactly as `k_equiv_monotone` (`NEquivalence.lean`) does.
`determinedByKType_eval` generalises it from normal forms to every depth-`≤ k` sentence `ψ`
through Doets's Lemma 1.1 (`doets_lemma_1_1`, `Expressiveness/NormalForm.lean`): the `nf`-pointwise
reading of the `k`-type equation is exactly that lemma's hypothesis. This is the shape the seam
interface's `determined` field is discharged in — for any sentence target, not only a normal form.

## Main definitions and results

* `DeterminedByKType` — a target is determined by the block's `k`-type.
* `determinedByKType_nfEval` — the truth of a depth-`k` normal form on the block is such a target.
* `determinedByKType_eval` — the truth of any depth-`≤ k` sentence on the block is such a target
  (Doets 1989, Lemma 1.1); `determinedByKType_nfEval` is its normal-form instance.
* `family_saturation` — each family is inside or disjoint from a `k`-type-determined target.
* `finite_family_triples` — there are finitely many family triples.
* `target_eq_union_of_families` — a `k`-type-determined target is the union of the families it
  contains.

## References

* [K. Doets, *Monadic $\Pi^1_1$-Theories of $\Pi^1_1$-Properties*][doets1989], Section 1
  (`k`-types determine depth-`k` truth).
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

/-! ## The target abstraction -/

/-- **A target determined by the block's `k`-type**: a predicate on colourings that cannot
distinguish two coloured `ℤ`-blocks with the same depth-`k` monadic type. This is the only
property of a target that saturation uses. -/
def DeterminedByKType (sig : MonadicSignature) (k : ℕ)
    (T : (sig.preds → ℤ → Prop) → Prop) : Prop :=
  ∀ c c' : sig.preds → ℤ → Prop,
    kTypeOf sig k (zFiber sig c) = kTypeOf sig k (zFiber sig c') → (T c ↔ T c')

/-- **The abstraction is non-vacuous**: for every depth-`k` normal form `nf`, the target "the
block satisfies `nf`" is determined by the block's `k`-type — the `k`-type is, by definition,
the record of which normal forms hold, so this is the `nf`-coordinate of the `k`-type equation. -/
theorem determinedByKType_nfEval (sig : MonadicSignature) (k : ℕ) (nf : NormalForm sig k 0) :
    DeterminedByKType sig k (fun c => NfEvalNf (zFiber sig c) k 0 Fin.elim0 nf) := by
  intro c c' h
  unfold kTypeOf at h
  have h_pt := congr_fun h nf
  simp only [decide_eq_decide] at h_pt
  exact h_pt

/-- **Every sentence target of depth at most `k` is `k`-type-determined** (Doets 1989, Lemma
1.1): two blocks with the same `k`-type agree on every normal form, hence — by
`doets_lemma_1_1` — on every depth-`≤ k` sentence. `determinedByKType_nfEval` is its normal-form
instance; this is the form in which the seam interface's `determined` field is discharged for an
arbitrary sentence target. -/
theorem determinedByKType_eval (sig : MonadicSignature) (k : ℕ) (ψ : MonadicFormula sig 0)
    (hψ : ψ.quantifierDepth ≤ k) :
    DeterminedByKType sig k (fun c => eval (zFiber sig c) Fin.elim0 ψ) := by
  intro c c' h
  refine doets_lemma_1_1 k 0 ψ hψ (zFiber sig c) (zFiber sig c') Fin.elim0 Fin.elim0 ?_
  intro nf
  unfold kTypeOf at h
  have h_pt := congr_fun h nf
  simp only [decide_eq_decide] at h_pt
  exact h_pt

/-! ## Saturation -/

/-- **Step 5b of the chain, saturation proper: each family is wholly inside or wholly disjoint
from a `k`-type-determined target.** Either some member of the family satisfies `T`, in which
case every member does, because two members of one family have equal block `k`-types
(`kTypeOf_zFiber_eq_of_inFamily`) and `T` cannot tell them apart; or no member does. -/
theorem family_saturation (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) {T : (sig.preds → ℤ → Prop) → Prop} (hT : DeterminedByKType sig k T)
    (τneg τzero τpos : KType sig k) :
    (∀ c, InFamily sig k τneg τzero τpos c → T c) ∨
      (∀ c, InFamily sig k τneg τzero τpos c → ¬ T c) := by
  by_cases h : ∃ c, InFamily sig k τneg τzero τpos c ∧ T c
  · obtain ⟨c₀, hc₀, hT₀⟩ := h
    left
    intro c hc
    exact (hT c₀ c (kTypeOf_zFiber_eq_of_inFamily sig k τneg τzero τpos c₀ c hc₀ hc)).mp hT₀
  · right
    intro c hc hTc
    exact h ⟨c, hc, hTc⟩

/-! ## The finite-family cover -/

-- linter.unusedFintypeInType, linter.unusedDecidableInType: the `[Fintype sig.preds]` and
-- `[DecidableEq sig.preds]` binders are the cluster's recorded interface for the finite-index
-- fact (`kType_finite` carries them, and `InFamily`/`SegmentFactorization` require them), and
-- they are consumed by the proof rather than by the conclusion, which mentions only `KType`.
-- Declaration-scoped, as for `kType_finite` and `exists_matching_factorization`.
set_option linter.unusedFintypeInType false in
set_option linter.unusedDecidableInType false in
/-- **There are finitely many family triples.** The count is left visible rather than buried
inside the cover theorem; from step 2, `kType_finite`. **No cardinality bound is stated** — the
cluster claims no complexity result. -/
theorem finite_family_triples (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) :
    Finite (KType sig k × KType sig k × KType sig k) := by
  haveI := kType_finite sig k
  infer_instance

/-- **A `k`-type-determined target is the union of the families it contains** — Büchi's licensed
consequence of saturation together with the Ramsey cover: a block satisfies `T` iff it lies in
some family every member of which satisfies `T`. Forward: the block lies in some family
(`family_cover`), and by `family_saturation` that family is wholly inside `T` since the block
witnesses that it is not disjoint from it. Backward: the block is one of the members. With
`finite_family_triples`, the right-hand side ranges over finitely many families. -/
theorem target_eq_union_of_families (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) {T : (sig.preds → ℤ → Prop) → Prop}
    (hT : DeterminedByKType sig k T) :
    ∀ c, T c ↔ ∃ τneg τzero τpos : KType sig k,
      InFamily sig k τneg τzero τpos c ∧
        (∀ c', InFamily sig k τneg τzero τpos c' → T c') := by
  intro c
  constructor
  · intro hc
    obtain ⟨τneg, τzero, τpos, hin⟩ := family_cover sig k c
    refine ⟨τneg, τzero, τpos, hin, ?_⟩
    rcases family_saturation sig k hT τneg τzero τpos with hall | hnone
    · exact hall
    · exact absurd hc (hnone c hin)
  · rintro ⟨τneg, τzero, τpos, hin, hall⟩
    exact hall c hin

end FormalSystem.Metalogic.WeakCanonical
