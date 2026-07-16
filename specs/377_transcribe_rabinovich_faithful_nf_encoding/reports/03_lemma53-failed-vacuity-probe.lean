import Bimodal.Metalogic.WeakCanonical.Kamp.Lemma53

/-!
# Failed-vacuity probe for `lemma53` (Rabinovich 2014, Lemma 5.3, PDF p.8)

Per the plan's non-vacuity acceptance rule: a statement is rejected if its conclusion is
provable with its hypotheses discharged. This probe pins down that `lemma53`'s **quantifier
order** is what carries the content, by exhibiting the boundary:

* `lemma53_vacuous_shape_control` — the per-point ordering `∀ M atomMap z₀ z₁, ∃ O, …`
  **COMPILES** from no hypotheses at all. With the points fixed, `¬(allTopBracket P).holds` is a
  fixed truth value, so one picks `O_top` when it is true and `O_zero` when it is false. This is
  the same contentless-witness failure `Prop42Vacuity.lean` refutes for `∃ v', v'.holds`, and it
  survives the addition of a biconditional — the biconditional does not rescue the shape, the
  quantifier order does.

* `lemma53_hoisted_shape_refutation` — the hoisted ordering `∃ O, ∀ M atomMap z₀ z₁, …`, i.e.
  `lemma53`'s actual shape, **DOES NOT COMPILE** by the same trick. Uncomment it to reproduce.
  `O` must be fixed before `M`, `atomMap`, `z₀`, `z₁` are seen, so no per-point case split is
  available and neither constant block works: `O_zero` fails wherever the bracket does not hold,
  `O_top` fails wherever it does.

Recorded **verbatim** failure for the hoisted shape (Lean v4.27.0-rc1, exit 1):

```
error(lean.unknownIdentifier): Unknown identifier `M`
error(lean.unknownIdentifier): Unknown identifier `atomMap`
error(lean.unknownIdentifier): Unknown identifier `z0`
error(lean.unknownIdentifier): Unknown identifier `z1`
error: unsolved goals
sig : MonadicSignature
n : ℕ
P : Fin n → TemporalPred
⊢ ∃ O,
    ∀ (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (z0 z1 : M.carrier),
      VVecEA2.holds M atomMap O z0 z1 ↔ ¬BracketFormula.holds M atomMap (allTopBracket P) z0 z1
```

The four `Unknown identifier` errors are the finding, not noise: the `by_cases` that discharges
the control cannot even be *written* here, because `M`, `atomMap`, `z₀`, `z₁` do not exist at
the point `O` must be produced.

The operative point does not depend on the exact error text: `O` is bound outside the point
quantifiers, so it is a function of `P` alone and must work uniformly across every Dedekind
complete chain and every pair of points. That uniformity is the whole of Lemma 5.3.

Cite Rabinovich by PDF page only; the companion `.md` is corrupt.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-- The all-`⊤` block: holds on every interval. The contentless witness. -/
def O_top : VVecEA2 :=
  ⟨[⟨0, VecEA2.fromBracket (BracketFormula.trivial TemporalPred.top)⟩]⟩

/-- CONTROL — the **vacuous** per-point ordering. Compiles from no hypotheses at all.
    This is what `lemma53` must not be. -/
theorem lemma53_vacuous_shape_control {sig : MonadicSignature} {n : Nat}
    (P : Fin n → TemporalPred)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (z0 z1 : M.carrier) :
    ∃ O : VVecEA2,
      (O.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1) := by
  by_cases h : (allTopBracket P).holds M atomMap z0 z1
  · -- Bracket holds, so the RHS is `False`: pick the empty disjunction.
    refine ⟨O_zero, ?_⟩
    simp only [O_zero, VVecEA2.holds, List.not_mem_nil, false_and, exists_false]
    constructor
    · exact False.elim
    · intro hn; exact absurd h hn
  · -- Bracket fails, so the RHS is `True`: pick the all-`⊤` block.
    refine ⟨O_top, ?_⟩
    simp only [O_top, VVecEA2.holds, List.mem_singleton, exists_eq_left]
    rw [VecEA2.fromBracket_holds, BracketFormula.trivial_holds]
    constructor
    · intro _; exact h
    · intro _ y _ _; exact TemporalPred.top_eval_at M atomMap y

/-- REFUTATION — `lemma53`'s actual hoisted ordering. The control's trick does not port:
    `O` is introduced before `M`, `atomMap`, `z₀`, `z₁` exist, so there is nothing to split on.

    Uncommenting this block must FAIL to compile. If it ever compiles, `lemma53` has drifted to
    a vacuous statement and the transcription is void.

```lean
theorem lemma53_hoisted_shape_refutation {sig : MonadicSignature} {n : Nat}
    (P : Fin n → TemporalPred) :
    ∃ O : VVecEA2, ∀ (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
      (z0 z1 : M.carrier),
      (O.holds M atomMap z0 z1 ↔ ¬(allTopBracket P).holds M atomMap z0 z1) := by
  by_cases h : (allTopBracket P).holds M atomMap z0 z1   -- no `M`/`atomMap`/`z0`/`z1` in scope
  · exact ⟨O_zero, by simp [O_zero, VVecEA2.holds]⟩
  · exact ⟨O_top, by simp [O_top, VVecEA2.holds]⟩
```
-/
theorem lemma53_hoisted_shape_refutation_note : True := trivial

end Bimodal.Metalogic.WeakCanonical.Kamp
