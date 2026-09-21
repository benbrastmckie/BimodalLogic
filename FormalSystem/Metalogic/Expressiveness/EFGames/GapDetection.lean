/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.EFGames.TypeFormulas

/-!
# Gap Detection Formulas

The gap detection formulas of GHR93 Definition 8.5 and their rank bounds: `leftFormulaBase`,
`leftFormula`, `rightFormulaBase`, `rightFormula`, and the depth bounds
`stavi_depth_left_formula` and `stavi_depth_right_formula`.

This is the definitions module of the gap-detection development. Its siblings are:

- `EFGames/MuRelativizedTruth.lean` — mu-relativized truth at actual points, which does not
  depend on the formulas defined here;
- `EFGames/GapDetectionLeft.lean` — GHR93 Lemma 9, left direction (`left_formula_gap_detection`);
- `EFGames/GapDetectionRight.lean` — GHR93 Lemma 9, right direction
  (`right_formula_gap_detection`).
-/

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax

/-! ## Gap Detection Formulas (GHR93 Definition 8.5)

The `leftFormula` and `rightFormula` functions convert properties of gaps
into properties of actual points. Given a StaviFormula A (describing what
holds at a gap) and a StaviFormula D (the gap-defining formula), `leftFormula A D`
produces a StaviFormula that, when evaluated at an actual point m, detects
whether there is a D-defined gap gamma > m where A^mu holds at gamma.

### Definition by structural induction on A:

```
left(p, D)         = bot                    (atoms are false at gaps)
left(neg A, D)     = U'(top, D) and neg left(A, D)
left(A and B, D)   = left(A, D) and left(B, D)
left(U(A,B), D)    = U'(B and U(A,B), D)
left(U'(A,B), D)   = U'(B and U'(A,B), D)
left(S(A,B), D)    = U(D and B and S(A,B) and U'(top, B and D) and neg U'(D, B and D), D)
left(S'(A,B), D)   = U(D and B and S'(A,B) and U'(top, B and D) and neg U'(D, B and D), D)
```

### References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], Chapter 9, Definition 8.5
* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], Lemma 9: Gap detection correctness
-/

/-- Helper: leftFormula for base (standard temporal) formulas.
    Structural recursion on Formula is straightforward since all Formula
    constructors have structurally smaller subterms.

    For the `.snce` case, the GHR93 definition produces `U(X, D)` where X
    contains Stavi connectives. We use `std_untl` to represent standard Until
    of StaviFormula arguments, avoiding the need for `flattenStavi` (which
    maps U'/S' to bot, breaking the semantics for compound formulas). -/
noncomputable def leftFormulaBase (D : StaviFormula) : Formula → StaviFormula
  | .atom _ => .base .bot
  | .bot => .base .bot
  | .imp φ ψ =>
    -- A → B = ¬(A ∧ ¬B), so left(A→B, D) = left(¬(A ∧ ¬B), D)
    -- = U'(⊤, D) ∧ ¬left(A ∧ ¬B, D)
    -- = U'(⊤, D) ∧ ¬(left(A, D) ∧ left(¬B, D))
    -- = U'(⊤, D) ∧ ¬(left(A, D) ∧ (U'(⊤,D) ∧ ¬left(B, D)))
    .conj (.stavi_untl (.base Formula.top) D)
      (.neg (.conj (leftFormulaBase D φ)
        (.conj (.stavi_untl (.base Formula.top) D)
          (.neg (leftFormulaBase D ψ)))))
  | .box _ => .base .bot  -- box-subformulas are treated as atoms
  | .untl ψ φ =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    .stavi_untl (.conj (.base ψ) (.base (.untl ψ φ))) D
  | .snce ψ φ =>
    -- left(S(A,B), D) = U(D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D), D)
    -- Uses std_untl to represent standard Until of StaviFormula arguments.
    let bD := .base ψ  -- B as StaviFormula
    let sAB := .base (.snce ψ φ)  -- S(A,B) as StaviFormula
    let bAndD := StaviFormula.conj bD D  -- B ∧ D
    let uPrimTopBD := StaviFormula.stavi_untl (.base Formula.top) bAndD  -- U'(⊤, B∧D)
    let negUPrimDBD := StaviFormula.neg (StaviFormula.stavi_untl D bAndD)  -- ¬U'(D, B∧D)
    let compound := StaviFormula.conj D
      (StaviFormula.conj bD
        (StaviFormula.conj sAB
          (StaviFormula.conj uPrimTopBD negUPrimDBD)))
    -- U(compound, D): standard Until of StaviFormula arguments
    .std_untl compound D

/--
Gap detection formula `left(A, D)` from GHR93 Definition 8.5.

Given a StaviFormula A (describing what should hold at a gap) and a
StaviFormula D (the gap-defining formula), `leftFormula A D` produces
a StaviFormula that detects whether there is a D-defined gap gamma > m
where A^mu holds at gamma, with D holding on all points between m and gamma.

The definition is by structural induction on A, following GHR93 exactly
for all cases. For the S/S' cases, the result uses `std_untl` to encode
standard Until of Stavi-enriched subformulas (replacing the old
`flattenStavi` approach which incorrectly mapped U'/S' to bot).
-/
noncomputable def leftFormula : StaviFormula → StaviFormula → StaviFormula
  | .base φ, D => leftFormulaBase D φ
  | .neg A, D =>
    -- left(¬A, D) = U'(⊤, D) ∧ ¬left(A, D)
    .conj (.stavi_untl (.base Formula.top) D) (.neg (leftFormula A D))
  | .conj A B, D =>
    -- left(A ∧ B, D) = left(A, D) ∧ left(B, D)
    .conj (leftFormula A D) (leftFormula B D)
  | .stavi_untl A B, D =>
    -- left(U'(A,B), D) = U'(B ∧ U'(A,B), D)
    .stavi_untl (.conj B (.stavi_untl A B)) D
  | .stavi_snce A B, D =>
    -- left(S'(A,B), D) = U(D ∧ B ∧ S'(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D), D)
    -- Same structure as the S case but with S' instead of S.
    let bAndD := StaviFormula.conj B D  -- B ∧ D
    let uPrimTopBD := StaviFormula.stavi_untl (.base Formula.top) bAndD  -- U'(⊤, B∧D)
    let negUPrimDBD := StaviFormula.neg (StaviFormula.stavi_untl D bAndD)  -- ¬U'(D, B∧D)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.stavi_snce A B)
          (StaviFormula.conj uPrimTopBD negUPrimDBD)))
    -- Standard Until of StaviFormula arguments
    .std_untl compound D
  | .std_untl A B, D =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    .stavi_untl (.conj B (.std_untl A B)) D
  | .std_snce A B, D =>
    -- left(S(A,B), D) = U(D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D), D)
    let bAndD := StaviFormula.conj B D
    let uPrimTopBD := StaviFormula.stavi_untl (.base Formula.top) bAndD
    let negUPrimDBD := StaviFormula.neg (StaviFormula.stavi_untl D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.std_snce A B)
          (StaviFormula.conj uPrimTopBD negUPrimDBD)))
    .std_untl compound D

/-- Helper: rightFormula for base (standard temporal) formulas.
    Dual of leftFormulaBase: swaps U↔S and U'↔S' throughout. -/
noncomputable def rightFormulaBase (D : StaviFormula) : Formula → StaviFormula
  | .atom _ => .base .bot
  | .bot => .base .bot
  | .imp φ ψ =>
    -- right(A→B, D) = S'(⊤, D) ∧ ¬right(A ∧ ¬B, D)
    .conj (.stavi_snce (.base Formula.top) D)
      (.neg (.conj (rightFormulaBase D φ)
        (.conj (.stavi_snce (.base Formula.top) D)
          (.neg (rightFormulaBase D ψ)))))
  | .box _ => .base .bot
  | .untl ψ φ =>
    -- right(U(A,B), D) = S(D ∧ B ∧ U(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D), D)
    -- Uses std_snce to represent standard Since of StaviFormula arguments.
    let bD := .base ψ
    let uAB := .base (.untl ψ φ)
    let bAndD := StaviFormula.conj bD D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj bD
        (StaviFormula.conj uAB
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    .std_snce compound D
  | .snce ψ φ =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    .stavi_snce (.conj (.base ψ) (.base (.snce ψ φ))) D

/--
Gap detection formula `right(A, D)` from GHR93 Definition 8.5.

Dual of `leftFormula`: detects whether there is a D-defined gap gamma < m
where A^mu holds at gamma, with D holding on all points between gamma and m.

Obtained from `leftFormula` by swapping U↔S and U'↔S' throughout.
-/
noncomputable def rightFormula : StaviFormula → StaviFormula → StaviFormula
  | .base φ, D => rightFormulaBase D φ
  | .neg A, D =>
    -- right(¬A, D) = S'(⊤, D) ∧ ¬right(A, D)
    .conj (.stavi_snce (.base Formula.top) D) (.neg (rightFormula A D))
  | .conj A B, D =>
    -- right(A ∧ B, D) = right(A, D) ∧ right(B, D)
    .conj (rightFormula A D) (rightFormula B D)
  | .stavi_untl A B, D =>
    -- right(U'(A,B), D) = S(D ∧ B ∧ U'(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D), D)
    let bAndD := StaviFormula.conj B D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.stavi_untl A B)
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    -- Standard Since of StaviFormula arguments
    .std_snce compound D
  | .stavi_snce A B, D =>
    -- right(S'(A,B), D) = S'(B ∧ S'(A,B), D)
    .stavi_snce (.conj B (.stavi_snce A B)) D
  | .std_untl A B, D =>
    -- right(U(A,B), D) = S(D ∧ B ∧ U(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D), D)
    let bAndD := StaviFormula.conj B D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.std_untl A B)
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    .std_snce compound D
  | .std_snce A B, D =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    .stavi_snce (.conj B (.std_snce A B)) D

/-! ### Rank Bounds for Gap Detection Formulas -/

/-- The operatorDepth of flattenStavi A is bounded by staviDepth A.
    This is crucial for the rank bounds of leftFormula/rightFormula
    in cases where flattenStavi is used to encode standard Until/Since
    of Stavi-enriched subformulas. -/
private theorem operator_depth_flatten_stavi_le (A : StaviFormula) :
    operatorDepth (flattenStavi A) ≤ staviDepth A := by
  induction A with
  | base φ =>
    simp [flattenStavi, staviDepth]
  | neg A ih =>
    simp only [flattenStavi, staviDepth, Formula.neg, operatorDepth]
    omega
  | conj A B ihA ihB =>
    simp only [flattenStavi, staviDepth, Formula.and, Formula.neg, operatorDepth]
    omega
  | stavi_untl A B ihA ihB =>
    simp only [flattenStavi, staviDepth, operatorDepth]
    omega
  | stavi_snce A B ihA ihB =>
    simp only [flattenStavi, staviDepth, operatorDepth]
    omega
  | std_untl A B ihA ihB =>
    simp only [flattenStavi, staviDepth, operatorDepth]
    omega
  | std_snce A B ihA ihB =>
    simp only [flattenStavi, staviDepth, operatorDepth]
    omega

/-- Helper: staviDepth of leftFormulaBase is bounded.

    GHR93 claims rank(left(A,D)) ≤ max(rank(A), rank(D)) + 2 with rank counting
    each temporal connective as +1. Our `staviDepth`/`operatorDepth` counts +2
    per connective, so the corresponding bound is +4 in our encoding.

    The S/S' cases contain U'(...) subformulas inside a U(...) wrapper, giving
    two levels of temporal connective nesting beyond the max of the sub-depths. -/
private theorem stavi_depth_left_formula_base (D : StaviFormula) (φ : Formula) :
    staviDepth (leftFormulaBase D φ) ≤ max (operatorDepth φ) (staviDepth D) + 4 := by
  induction φ with
  | atom _ =>
    simp [leftFormulaBase, staviDepth, operatorDepth]
  | bot =>
    simp [leftFormulaBase, staviDepth, operatorDepth]
  | imp φ ψ ih_φ ih_ψ =>
    simp only [leftFormulaBase, staviDepth, operatorDepth, Formula.top] at *
    omega
  | box _ =>
    simp [leftFormulaBase, staviDepth, operatorDepth]
  | untl ψ φ =>
    simp only [leftFormulaBase, staviDepth, operatorDepth]
    omega
  | snce ψ φ =>
    -- The snce case uses std_untl. staviDepth of std_untl compound D =
    -- max (staviDepth compound) (staviDepth D) + 2. The compound contains
    -- U' subformulas giving +2, so total depth is bounded by
    -- max(operatorDepth φ, operatorDepth ψ, staviDepth D) + 4.
    simp only [leftFormulaBase, staviDepth, operatorDepth, Formula.top]
    omega

/--
**Rank bound** (GHR93 Definition 8.5): The depth of leftFormula(A, D) is
bounded by max(staviDepth A, staviDepth D) + 4.

GHR93 states the bound as max(rank(A), rank(D)) + 2 using a rank function
that counts +1 per temporal connective. Our `staviDepth` counts +2 per
connective, so the corresponding bound is +4. The S/S' cases contain
U'(...) subformulas inside a U(...) wrapper, giving two levels of temporal
connective nesting beyond the max of the sub-depths.

This bound ensures that leftFormula produces formulas within the rank
budget of the EF game.
-/
theorem stavi_depth_left_formula (A D : StaviFormula) :
    staviDepth (leftFormula A D) ≤ max (staviDepth A) (staviDepth D) + 4 := by
  induction A with
  | base φ =>
    simp only [leftFormula, staviDepth]
    have h := stavi_depth_left_formula_base D φ
    omega
  | neg A ih =>
    simp only [leftFormula, staviDepth, Formula.top, operatorDepth] at *
    omega
  | conj A B ihA ihB =>
    simp only [leftFormula, staviDepth]
    omega
  | stavi_untl A B =>
    simp only [leftFormula, staviDepth]
    omega
  | stavi_snce A B =>
    -- left(S'(A,B), D) = std_untl compound D
    simp only [leftFormula, staviDepth, operatorDepth, Formula.top]
    omega
  | std_untl A B =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    simp only [leftFormula, staviDepth]
    omega
  | std_snce A B =>
    -- left(S(A,B), D) = std_untl compound D
    simp only [leftFormula, staviDepth, operatorDepth, Formula.top]
    omega

/--
**Rank bound** for rightFormula: The depth of rightFormula(A, D) is
bounded by max(staviDepth A, staviDepth D) + 4.

Symmetric to `stavi_depth_left_formula` by the U↔S, U'↔S' swap.
-/
theorem stavi_depth_right_formula (A D : StaviFormula) :
    staviDepth (rightFormula A D) ≤ max (staviDepth A) (staviDepth D) + 4 := by
  induction A with
  | base φ =>
    -- rightFormulaBase D φ is symmetric to leftFormulaBase D φ
    -- with U↔S and U'↔S' swapped. The depth analysis is identical.
    simp only [rightFormula, staviDepth]
    induction φ with
    | atom _ => simp [rightFormulaBase, staviDepth, operatorDepth]
    | bot => simp [rightFormulaBase, staviDepth, operatorDepth]
    | imp φ ψ ih_φ ih_ψ =>
      simp only [rightFormulaBase, staviDepth, operatorDepth, Formula.top] at *; omega
    | box _ => simp [rightFormulaBase, staviDepth, operatorDepth]
    | untl ψ φ =>
      -- rightFormulaBase now uses std_snce instead of flattenStavi
      simp only [rightFormulaBase, staviDepth, operatorDepth, Formula.top]
      omega
    | snce ψ φ => simp only [rightFormulaBase, staviDepth, operatorDepth]; omega
  | neg A ih =>
    simp only [rightFormula, staviDepth, Formula.top, operatorDepth] at *
    omega
  | conj A B ihA ihB =>
    simp only [rightFormula, staviDepth]
    omega
  | stavi_untl A B =>
    -- right(U'(A,B), D) = std_snce compound D
    simp only [rightFormula, staviDepth, operatorDepth, Formula.top]
    omega
  | stavi_snce A B =>
    -- right(S'(A,B), D) = S'(B ∧ S'(A,B), D)
    simp only [rightFormula, staviDepth]
    omega
  | std_untl A B =>
    -- right(U(A,B), D) = std_snce compound D
    simp only [rightFormula, staviDepth, operatorDepth, Formula.top]
    omega
  | std_snce A B =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    simp only [rightFormula, staviDepth]
    omega

end FormalSystem.Metalogic.Expressiveness
