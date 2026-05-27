import Bimodal.Metalogic.WeakCanonical.EFGames.TypeFormulas

/-!
# Gap Detection Formulas and Lemma 9

Gap detection formulas and Lemma 9 (both directions): the core EF game characterization.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Gap Detection Formulas (GHR93 Definition 8.5)

The `left_formula` and `right_formula` functions convert properties of gaps
into properties of actual points. Given a StaviFormula A (describing what
holds at a gap) and a StaviFormula D (the gap-defining formula), `left_formula A D`
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

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.5
- GHR93 Lemma 9: Gap detection correctness
- Task 155 plan: Phase 4B, Task 4B.4
-/

/-- Helper: left_formula for base (standard temporal) formulas.
    Structural recursion on Formula is straightforward since all Formula
    constructors have structurally smaller subterms.

    For the `.snce` case, the GHR93 definition produces `U(X, D)` where X
    contains Stavi connectives. We use `std_untl` to represent standard Until
    of StaviFormula arguments, avoiding the need for `flatten_stavi` (which
    maps U'/S' to bot, breaking the semantics for compound formulas). -/
noncomputable def left_formula_base (D : StaviFormula) : Formula → StaviFormula
  | .atom _ => .base .bot
  | .bot => .base .bot
  | .imp φ ψ =>
    -- A → B = ¬(A ∧ ¬B), so left(A→B, D) = left(¬(A ∧ ¬B), D)
    -- = U'(⊤, D) ∧ ¬left(A ∧ ¬B, D)
    -- = U'(⊤, D) ∧ ¬(left(A, D) ∧ left(¬B, D))
    -- = U'(⊤, D) ∧ ¬(left(A, D) ∧ (U'(⊤,D) ∧ ¬left(B, D)))
    .conj (.stavi_untl (.base Formula.top) D)
      (.neg (.conj (left_formula_base D φ)
        (.conj (.stavi_untl (.base Formula.top) D)
          (.neg (left_formula_base D ψ)))))
  | .box _ => .base .bot  -- box-subformulas are treated as atoms
  | .untl φ ψ =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    .stavi_untl (.conj (.base ψ) (.base (.untl φ ψ))) D
  | .snce φ ψ =>
    -- left(S(A,B), D) = U(D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D), D)
    -- Uses std_untl to represent standard Until of StaviFormula arguments.
    let bD := .base ψ  -- B as StaviFormula
    let sAB := .base (.snce φ ψ)  -- S(A,B) as StaviFormula
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
StaviFormula D (the gap-defining formula), `left_formula A D` produces
a StaviFormula that detects whether there is a D-defined gap gamma > m
where A^mu holds at gamma, with D holding on all points between m and gamma.

The definition is by structural induction on A, following GHR93 exactly
for all cases. For the S/S' cases, the result uses `std_untl` to encode
standard Until of Stavi-enriched subformulas (replacing the old
`flatten_stavi` approach which incorrectly mapped U'/S' to bot).
-/
noncomputable def left_formula : StaviFormula → StaviFormula → StaviFormula
  | .base φ, D => left_formula_base D φ
  | .neg A, D =>
    -- left(¬A, D) = U'(⊤, D) ∧ ¬left(A, D)
    .conj (.stavi_untl (.base Formula.top) D) (.neg (left_formula A D))
  | .conj A B, D =>
    -- left(A ∧ B, D) = left(A, D) ∧ left(B, D)
    .conj (left_formula A D) (left_formula B D)
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

/-- Helper: right_formula for base (standard temporal) formulas.
    Dual of left_formula_base: swaps U↔S and U'↔S' throughout. -/
noncomputable def right_formula_base (D : StaviFormula) : Formula → StaviFormula
  | .atom _ => .base .bot
  | .bot => .base .bot
  | .imp φ ψ =>
    -- right(A→B, D) = S'(⊤, D) ∧ ¬right(A ∧ ¬B, D)
    .conj (.stavi_snce (.base Formula.top) D)
      (.neg (.conj (right_formula_base D φ)
        (.conj (.stavi_snce (.base Formula.top) D)
          (.neg (right_formula_base D ψ)))))
  | .box _ => .base .bot
  | .untl φ ψ =>
    -- right(U(A,B), D) = S(D ∧ B ∧ U(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D), D)
    -- Uses std_snce to represent standard Since of StaviFormula arguments.
    let bD := .base ψ
    let uAB := .base (.untl φ ψ)
    let bAndD := StaviFormula.conj bD D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj bD
        (StaviFormula.conj uAB
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    .std_snce compound D
  | .snce φ ψ =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    .stavi_snce (.conj (.base ψ) (.base (.snce φ ψ))) D

/--
Gap detection formula `right(A, D)` from GHR93 Definition 8.5.

Dual of `left_formula`: detects whether there is a D-defined gap gamma < m
where A^mu holds at gamma, with D holding on all points between gamma and m.

Obtained from `left_formula` by swapping U↔S and U'↔S' throughout.
-/
noncomputable def right_formula : StaviFormula → StaviFormula → StaviFormula
  | .base φ, D => right_formula_base D φ
  | .neg A, D =>
    -- right(¬A, D) = S'(⊤, D) ∧ ¬right(A, D)
    .conj (.stavi_snce (.base Formula.top) D) (.neg (right_formula A D))
  | .conj A B, D =>
    -- right(A ∧ B, D) = right(A, D) ∧ right(B, D)
    .conj (right_formula A D) (right_formula B D)
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

/-- The operator_depth of flatten_stavi A is bounded by stavi_depth A.
    This is crucial for the rank bounds of left_formula/right_formula
    in cases where flatten_stavi is used to encode standard Until/Since
    of Stavi-enriched subformulas. -/
private theorem operator_depth_flatten_stavi_le (A : StaviFormula) :
    operator_depth (flatten_stavi A) ≤ stavi_depth A := by
  induction A with
  | base φ =>
    simp [flatten_stavi, stavi_depth]
  | neg A ih =>
    simp only [flatten_stavi, stavi_depth, Formula.neg, operator_depth]
    omega
  | conj A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, Formula.and, Formula.neg, operator_depth]
    omega
  | stavi_untl A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, Formula.and, Formula.neg, operator_depth]
    omega
  | stavi_snce A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, Formula.and, Formula.neg, operator_depth]
    omega
  | std_untl A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, operator_depth]
    omega
  | std_snce A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, operator_depth]
    omega

/-- Helper: stavi_depth of left_formula_base is bounded.

    GHR93 claims rank(left(A,D)) ≤ max(rank(A), rank(D)) + 2 with rank counting
    each temporal connective as +1. Our `stavi_depth`/`operator_depth` counts +2
    per connective, so the corresponding bound is +4 in our encoding.

    The S/S' cases contain U'(...) subformulas inside a U(...) wrapper, giving
    two levels of temporal connective nesting beyond the max of the sub-depths. -/
private theorem stavi_depth_left_formula_base (D : StaviFormula) (φ : Formula) :
    stavi_depth (left_formula_base D φ) ≤ max (operator_depth φ) (stavi_depth D) + 4 := by
  induction φ with
  | atom _ =>
    simp [left_formula_base, stavi_depth, operator_depth]
  | bot =>
    simp [left_formula_base, stavi_depth, operator_depth]
  | imp φ ψ ih_φ ih_ψ =>
    simp only [left_formula_base, stavi_depth, operator_depth, Formula.top] at *
    omega
  | box _ =>
    simp [left_formula_base, stavi_depth, operator_depth]
  | untl φ ψ =>
    simp only [left_formula_base, stavi_depth, operator_depth]
    omega
  | snce φ ψ =>
    -- The snce case uses std_untl. stavi_depth of std_untl compound D =
    -- max (stavi_depth compound) (stavi_depth D) + 2. The compound contains
    -- U' subformulas giving +2, so total depth is bounded by
    -- max(operator_depth φ, operator_depth ψ, stavi_depth D) + 4.
    simp only [left_formula_base, stavi_depth, operator_depth, Formula.top]
    omega

/--
**Rank bound** (GHR93 Definition 8.5): The depth of left_formula(A, D) is
bounded by max(stavi_depth A, stavi_depth D) + 4.

GHR93 states the bound as max(rank(A), rank(D)) + 2 using a rank function
that counts +1 per temporal connective. Our `stavi_depth` counts +2 per
connective, so the corresponding bound is +4. The S/S' cases contain
U'(...) subformulas inside a U(...) wrapper, giving two levels of temporal
connective nesting beyond the max of the sub-depths.

This bound ensures that left_formula produces formulas within the rank
budget of the EF game.
-/
theorem stavi_depth_left_formula (A D : StaviFormula) :
    stavi_depth (left_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 := by
  induction A with
  | base φ =>
    simp only [left_formula, stavi_depth]
    have h := stavi_depth_left_formula_base D φ
    omega
  | neg A ih =>
    simp only [left_formula, stavi_depth, Formula.top, operator_depth] at *
    omega
  | conj A B ihA ihB =>
    simp only [left_formula, stavi_depth]
    omega
  | stavi_untl A B =>
    simp only [left_formula, stavi_depth]
    omega
  | stavi_snce A B =>
    -- left(S'(A,B), D) = std_untl compound D
    simp only [left_formula, stavi_depth, operator_depth, Formula.top]
    omega
  | std_untl A B =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    simp only [left_formula, stavi_depth]
    omega
  | std_snce A B =>
    -- left(S(A,B), D) = std_untl compound D
    simp only [left_formula, stavi_depth, operator_depth, Formula.top]
    omega

/--
**Rank bound** for right_formula: The depth of right_formula(A, D) is
bounded by max(stavi_depth A, stavi_depth D) + 4.

Symmetric to `stavi_depth_left_formula` by the U↔S, U'↔S' swap.
-/
theorem stavi_depth_right_formula (A D : StaviFormula) :
    stavi_depth (right_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 := by
  induction A with
  | base φ =>
    -- right_formula_base D φ is symmetric to left_formula_base D φ
    -- with U↔S and U'↔S' swapped. The depth analysis is identical.
    simp only [right_formula, stavi_depth]
    induction φ with
    | atom _ => simp [right_formula_base, stavi_depth, operator_depth]
    | bot => simp [right_formula_base, stavi_depth, operator_depth]
    | imp φ ψ ih_φ ih_ψ =>
      simp only [right_formula_base, stavi_depth, operator_depth, Formula.top] at *; omega
    | box _ => simp [right_formula_base, stavi_depth, operator_depth]
    | untl φ ψ =>
      -- right_formula_base now uses std_snce instead of flatten_stavi
      simp only [right_formula_base, stavi_depth, operator_depth, Formula.top]
      omega
    | snce φ ψ => simp only [right_formula_base, stavi_depth, operator_depth]; omega
  | neg A ih =>
    simp only [right_formula, stavi_depth, Formula.top, operator_depth] at *
    omega
  | conj A B ihA ihB =>
    simp only [right_formula, stavi_depth]
    omega
  | stavi_untl A B =>
    -- right(U'(A,B), D) = std_snce compound D
    simp only [right_formula, stavi_depth, operator_depth, Formula.top]
    omega
  | stavi_snce A B =>
    -- right(S'(A,B), D) = S'(B ∧ S'(A,B), D)
    simp only [right_formula, stavi_depth]
    omega
  | std_untl A B =>
    -- right(U(A,B), D) = std_snce compound D
    simp only [right_formula, stavi_depth, operator_depth, Formula.top]
    omega
  | std_snce A B =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    simp only [right_formula, stavi_depth]
    omega

/-! ### Mu-Relativized Truth at Actual Points

Key infrastructure lemma: at an actual point (extendPoint m), the mu-relativized
temporal truth agrees with standard temporal truth. This is because mu-points in
M_r are exactly the actual points from M, and the ordering among actual points in
M_r is the same as in M. -/

/-- extendPoint preserves strict order. -/
theorem extendPoint_lt_iff {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x y : M.carrier) :
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) x <
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) y ↔ x < y := by
  simp only [extendPoint]
  constructor
  · intro ⟨hle, hne⟩; exact lt_of_le_of_ne (show x ≤ y from hle) (fun h => hne (h ▸ le_refl y))
  · intro h; exact ⟨le_of_lt h, fun hyx => not_lt.mpr (show y ≤ x from hyx) h⟩

/-- For standard temporal formulas, mu-relativized truth at an actual point equals
    standard temporal truth. -/
theorem temporal_truth_mu_at_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (m : M.carrier) (φ : Formula) :
    temporal_truth_mu M atomMap r (extendPoint m) φ ↔
    temporal_truth M atomMap m φ := by
  induction φ generalizing m with
  | atom a =>
    simp only [temporal_truth_mu, temporal_truth, extendedStructure, extendPoint]
  | bot =>
    simp only [temporal_truth_mu, temporal_truth]
  | imp φ ψ ihφ ihψ =>
    simp only [temporal_truth_mu, temporal_truth]
    exact Iff.imp (ihφ m) (ihψ m)
  | box φ =>
    simp only [temporal_truth_mu, temporal_truth, extendedStructure, extendPoint]
  | untl φ ψ ihφ ihψ =>
    constructor
    · intro ⟨s, hms, hmu, hphi, hpsi⟩
      obtain ⟨s', rfl⟩ := hmu
      have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
      exact ⟨s', hms', (ihφ s').mp hphi, fun u hmu' hus =>
        (ihψ u).mp (hpsi (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu')
          ((extendPoint_lt_iff u s').mpr hus) ⟨u, rfl⟩)⟩
    · intro ⟨s, hms, hphi, hpsi⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ⟨s, rfl⟩,
        (ihφ s).mpr hphi, fun u hmu hus hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihψ u').mpr (hpsi u' ((extendPoint_lt_iff m u').mp hmu)
        ((extendPoint_lt_iff u' s).mp hus))
  | snce φ ψ ihφ ihψ =>
    constructor
    · intro ⟨s, hsm, hmu, hphi, hpsi⟩
      obtain ⟨s', rfl⟩ := hmu
      have hsm' : s' < m := (extendPoint_lt_iff s' m).mp hsm
      exact ⟨s', hsm', (ihφ s').mp hphi, fun u hsu hum =>
        (ihψ u).mp (hpsi (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
          ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩)⟩
    · intro ⟨s, hsm, hphi, hpsi⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ⟨s, rfl⟩,
        (ihφ s).mpr hphi, fun u hsu hum hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihψ u').mpr (hpsi u' ((extendPoint_lt_iff s u').mp hsu)
        ((extendPoint_lt_iff u' m).mp hum))

/-- For Stavi formulas, mu-relativized truth at an actual point equals
    standard temporal truth. -/
theorem stavi_truth_mu_at_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (m : M.carrier) (A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) A ↔
    stavi_temporal_truth M atomMap m A := by
  induction A generalizing m with
  | base φ =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    exact temporal_truth_mu_at_point m φ
  | neg A ih =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    exact Iff.not (ih m)
  | conj A B ihA ihB =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    exact Iff.and (ihA m) (ihB m)
  | stavi_untl A B ihA ihB =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · -- mp: mu-relativized → standard
      intro ⟨s, hms, h_body, ⟨u_fail, hmu_fail, hus_fail, hmu_fail_mu, hB_fail⟩,
             ⟨u_init, hmu_init, hus_init, hmu_init_mu, hB_init⟩⟩
      -- Get M.carrier representatives
      obtain ⟨uf, rfl⟩ := hmu_fail_mu
      obtain ⟨ui, rfl⟩ := hmu_init_mu
      -- We need s' : M.carrier with s' > m. The witness s might be a gap.
      -- Use a point in the complement of s's gap (if s is a gap), or s itself.
      -- For the bound, we need s' such that uf < s' and ui < s'.
      -- Key: s > extendPoint uf and s > extendPoint ui.
      -- Take s' : find a point in M.carrier above both uf and ui.
      -- Option: use s if it's a point, otherwise use complement element.
      -- Actually we can just pick a point above both witnesses.
      -- Since the body only needs to hold on (m, s'), we can pick s' > uf, ui.
      -- But we need s' > uf AND s' > ui. Without NoMaxOrder, just take max(uf, ui) + 1?
      -- Actually, we have s > extendPoint uf in ExtendedCarrier. If s is a gap g,
      -- then uf ∈ g.val.cut. Since g.val.cut ≠ univ (proper), ∃ s' ∉ g.val.cut.
      -- Such s' satisfies extendPoint s' > Sum.inr g > extendPoint uf, so s' > uf.
      -- Similarly s' > ui.
      -- If s is a point extendPoint s', then s' > uf and s' > ui directly.
      -- In either case, we get s' > max(uf, ui) > m.
      -- Let's handle both cases of s:
      rcases s with s' | g
      · -- s = extendPoint s'
        have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
        refine ⟨s', hms', ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (m, s'), disjunction
          intro u hmu hus'
          have h_disj := h_body (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu)
            ((extendPoint_lt_iff u s').mpr hus') ⟨u, rfl⟩
          cases h_disj with
          | inl h =>
            left
            obtain ⟨v, huv, hv_mu, hBv⟩ := h
            obtain ⟨v', rfl⟩ := hv_mu
            exact ⟨v', (extendPoint_lt_iff u v').mp huv,
              fun w hmw hwv' => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff m w).mpr hmw) ((extendPoint_lt_iff w v').mpr hwv') ⟨w, rfl⟩)⟩
          | inr h =>
            right
            obtain ⟨hA, v', hmv', hv'u, hv'_mu, hBv'⟩ := h
            obtain ⟨v'', rfl⟩ := hv'_mu
            exact ⟨fun v huv hvs' => (ihA v).mp (hA (extendPoint v)
                ((extendPoint_lt_iff u v).mpr huv) ((extendPoint_lt_iff v s').mpr hvs') ⟨v, rfl⟩),
              v'', (extendPoint_lt_iff m v'').mp hmv', (extendPoint_lt_iff v'' u).mp hv'u,
              fun h => hBv' ((ihB v'').mpr h)⟩
        · -- Fail: ∃ u ∈ (m, s'), ¬B(u)
          exact ⟨uf, (extendPoint_lt_iff m uf).mp hmu_fail,
            (extendPoint_lt_iff uf s').mp hus_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init: ∃ u ∈ (m, s'), B on (m, u)
          exact ⟨ui, (extendPoint_lt_iff m ui).mp hmu_init,
            (extendPoint_lt_iff ui s').mp hus_init,
            fun v hmv hvu => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff m v).mpr hmv) ((extendPoint_lt_iff v ui).mpr hvu) ⟨v, rfl⟩)⟩
      · -- s = Sum.inr g (a gap)
        -- uf, ui ∈ g.val.cut since extendPoint uf/ui < Sum.inr g
        have huf_cut : uf ∈ g.val.cut := (extendPoint_le_gap_iff uf g).mp (le_of_lt hus_fail)
        have hui_cut : ui ∈ g.val.cut := (extendPoint_le_gap_iff ui g).mp (le_of_lt hus_init)
        -- gap cut cofinal: every element has a larger one in the cut
        have gap_cut_cofinal : ∀ (x : M.carrier), x ∈ g.val.cut → ∃ y, y ∈ g.val.cut ∧ x < y := by
          intro x hx; by_contra h_all; push_neg at h_all
          exact g.val.no_sup ⟨x, ⟨h_all, fun b hb => hb hx⟩, hx⟩
        -- max(uf, ui) ∈ cut
        have hmax_cut : max uf ui ∈ g.val.cut := by
          rcases le_or_lt uf ui with h | h
          · simp [max_eq_right h]; exact hui_cut
          · simp [max_eq_left (le_of_lt h)]; exact huf_cut
        obtain ⟨y, hy_cut, hmax_y⟩ := gap_cut_cofinal (max uf ui) hmax_cut
        have huf_y : uf < y := lt_of_le_of_lt (le_max_left uf ui) hmax_y
        have hui_y : ui < y := lt_of_le_of_lt (le_max_right uf ui) hmax_y
        -- Use y as the bound in M.carrier
        have hm_y : m < y := lt_trans ((extendPoint_lt_iff m uf).mp hmu_fail) huf_y
        refine ⟨y, hm_y, ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (m, y), disjunction
          intro u hmu huy
          -- u < y and y ∈ cut → u ∈ cut (downward_closed)
          have hu_cut : u ∈ g.val.cut := g.val.downward_closed y u hy_cut (le_of_lt huy)
          have hu_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) < Sum.inr g :=
            lt_of_le_of_ne ((extendPoint_le_gap_iff u g).mpr hu_cut) (fun h => by cases h)
          have h_disj := h_body (extendPoint u)
            ((extendPoint_lt_iff m u).mpr hmu) hu_s (mu_holds_point u)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, huv, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨xv, (extendPoint_lt_iff u xv).mp huv,
              fun w hmw hwv => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff m w).mpr hmw) ((extendPoint_lt_iff w xv).mpr hwv) ⟨w, rfl⟩)⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', hmv', hv'u, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            -- xv' < y because xv' < u < y... actually v' < u < s=gap.
            -- For A quantifier: ∀ v ∈ (u, s=gap) with mu → A. At M.carrier: ∀ v ∈ (u, y).
            -- v ∈ (u, y) → v ∈ cut → extendPoint v < Sum.inr g, so within (u, s).
            exact ⟨fun v huv hvy => by
                have hv_cut : v ∈ g.val.cut := g.val.downward_closed y v hy_cut (le_of_lt hvy)
                have hv_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r) v) < Sum.inr g :=
                  lt_of_le_of_ne ((extendPoint_le_gap_iff v g).mpr hv_cut) (fun h => by cases h)
                exact (ihA v).mp (hA (extendPoint v)
                  ((extendPoint_lt_iff u v).mpr huv) hv_s ⟨v, rfl⟩),
              xv', (extendPoint_lt_iff m xv').mp hmv',
                (extendPoint_lt_iff xv' u).mp hv'u,
                fun h => hBv' ((ihB xv').mpr h)⟩
        · -- Fail
          exact ⟨uf, (extendPoint_lt_iff m uf).mp hmu_fail, huf_y,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init
          exact ⟨ui, (extendPoint_lt_iff m ui).mp hmu_init, hui_y,
            fun v hmv hvu => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff m v).mpr hmv) ((extendPoint_lt_iff v ui).mpr hvu) ⟨v, rfl⟩)⟩
    · -- mpr: standard → mu-relativized
      intro ⟨s, hms, h_body, ⟨uf, hmuf, hufs, hBuf⟩, ⟨ui, hmui, huis, hBui⟩⟩
      -- Use extendPoint s as the witness (s is an actual point, NOT mu-restricted)
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ?_, ?_, ?_⟩
      · -- Body
        intro u hmu hus hmu_holds
        obtain ⟨u', rfl⟩ := hmu_holds
        have hmu' : m < u' := (extendPoint_lt_iff m u').mp hmu
        have hus' : u' < s := (extendPoint_lt_iff u' s).mp hus
        have h_disj := h_body u' hmu' hus'
        cases h_disj with
        | inl h =>
          left
          obtain ⟨v, huv, hBv⟩ := h
          exact ⟨extendPoint v, (extendPoint_lt_iff u' v).mpr huv, ⟨v, rfl⟩,
            fun w hmw hwv hw_mu => by
              obtain ⟨w', rfl⟩ := hw_mu
              exact (ihB w').mpr (hBv w' ((extendPoint_lt_iff m w').mp hmw)
                ((extendPoint_lt_iff w' v).mp hwv))⟩
        | inr h =>
          right
          obtain ⟨hA, v', hmv', hv'u, hBv'⟩ := h
          exact ⟨fun v huv hvs hv_mu => by
              obtain ⟨v', rfl⟩ := hv_mu
              exact (ihA v').mpr (hA v' ((extendPoint_lt_iff u' v').mp huv)
                ((extendPoint_lt_iff v' s).mp hvs)),
            extendPoint v', (extendPoint_lt_iff m v').mpr hmv',
              (extendPoint_lt_iff v' u').mpr hv'u, ⟨v', rfl⟩,
              fun h => hBv' ((ihB v').mp h)⟩
      · -- Fail
        exact ⟨extendPoint uf, (extendPoint_lt_iff m uf).mpr hmuf,
          (extendPoint_lt_iff uf s).mpr hufs, ⟨uf, rfl⟩,
          fun h => hBuf ((ihB uf).mp h)⟩
      · -- Init
        exact ⟨extendPoint ui, (extendPoint_lt_iff m ui).mpr hmui,
          (extendPoint_lt_iff ui s).mpr huis, ⟨ui, rfl⟩,
          fun v hmv hvu hv_mu => by
            obtain ⟨v', rfl⟩ := hv_mu
            exact (ihB v').mpr (hBui v' ((extendPoint_lt_iff m v').mp hmv)
              ((extendPoint_lt_iff v' ui).mp hvu))⟩
  | stavi_snce A B ihA ihB =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · -- mp: mu-relativized → standard (past dual)
      intro ⟨s, hsm, h_body, ⟨u_fail, hsu_fail, hum_fail, hmu_fail_mu, hB_fail⟩,
             ⟨u_init, hsu_init, hum_init, hmu_init_mu, hB_init⟩⟩
      obtain ⟨uf, rfl⟩ := hmu_fail_mu
      obtain ⟨ui, rfl⟩ := hmu_init_mu
      rcases s with s' | g
      · -- s = extendPoint s'
        have hs'm : s' < m := (extendPoint_lt_iff s' m).mp hsm
        refine ⟨s', hs'm, ?_, ?_, ?_⟩
        · intro u hsu hum
          have h_disj := h_body (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
            ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩
          cases h_disj with
          | inl h =>
            left
            obtain ⟨v, hvu, hv_mu, hBv⟩ := h
            obtain ⟨v', rfl⟩ := hv_mu
            exact ⟨v', (extendPoint_lt_iff v' u).mp hvu,
              fun w hvw hwm => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff v' w).mpr hvw) ((extendPoint_lt_iff w m).mpr hwm) ⟨w, rfl⟩)⟩
          | inr h =>
            right
            obtain ⟨hA, v', huv', hv'm, hv'_mu, hBv'⟩ := h
            obtain ⟨v'', rfl⟩ := hv'_mu
            exact ⟨fun v hsv hvu => (ihA v).mp (hA (extendPoint v)
                ((extendPoint_lt_iff s' v).mpr hsv) ((extendPoint_lt_iff v u).mpr hvu) ⟨v, rfl⟩),
              v'', (extendPoint_lt_iff u v'').mp huv', (extendPoint_lt_iff v'' m).mp hv'm,
              fun h => hBv' ((ihB v'').mpr h)⟩
        · exact ⟨uf, (extendPoint_lt_iff s' uf).mp hsu_fail,
            (extendPoint_lt_iff uf m).mp hum_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · exact ⟨ui, (extendPoint_lt_iff s' ui).mp hsu_init,
            (extendPoint_lt_iff ui m).mp hum_init,
            fun v huv hvm => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff ui v).mpr huv) ((extendPoint_lt_iff v m).mpr hvm) ⟨v, rfl⟩)⟩
      · -- s = Sum.inr g (gap) — find s' in complement below m
        -- uf, ui ∉ g.val.cut since Sum.inr g < extendPoint uf/ui
        have huf_not_cut : uf ∉ g.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff uf g).mpr h) hsu_fail
        have hui_not_cut : ui ∉ g.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff ui g).mpr h) hsu_init
        -- complement_no_min → ∃ z < uf/ui ∉ cut
        have compl_no_min := g.val.complement_no_min
        have ⟨z₁, hz₁_not_cut, hz₁_uf⟩ : ∃ z, z ∉ g.val.cut ∧ z < uf := by
          by_contra h_all; push_neg at h_all
          exact compl_no_min ⟨uf, huf_not_cut, fun y hy => h_all y hy⟩
        have ⟨z₂, hz₂_not_cut, hz₂_ui⟩ : ∃ z, z ∉ g.val.cut ∧ z < ui := by
          by_contra h_all; push_neg at h_all
          exact compl_no_min ⟨ui, hui_not_cut, fun y hy => h_all y hy⟩
        have hmin_not_cut : min z₁ z₂ ∉ g.val.cut := by
          rcases le_or_lt z₁ z₂ with h | h
          · simp [min_eq_left h]; exact hz₁_not_cut
          · simp [min_eq_right (le_of_lt h)]; exact hz₂_not_cut
        -- Use s' = min z₁ z₂
        have hs'm : min z₁ z₂ < m := by
          calc min z₁ z₂ ≤ z₁ := min_le_left z₁ z₂
            _ < uf := hz₁_uf
            _ < m := (extendPoint_lt_iff uf m).mp hum_fail
        refine ⟨min z₁ z₂, hs'm, ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (min z₁ z₂, m), disjunction
          intro u hsu hum
          -- u > min z₁ z₂, min ∉ cut → u ∉ cut → Sum.inr g < extendPoint u
          have hu_not_cut : u ∉ g.val.cut := by
            intro hu_in
            exact hmin_not_cut (g.val.downward_closed u (min z₁ z₂) hu_in (le_of_lt hsu))
          have hu_above_g : @LT.lt (ExtendedCarrier M atomMap r)
              extendedLinearOrder.toLT (Sum.inr g) (Sum.inl u) :=
            ⟨hu_not_cut, fun h => hu_not_cut h⟩
          have h_disj := h_body (extendPoint u) hu_above_g
            ((extendPoint_lt_iff u m).mpr hum) (mu_holds_point u)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨xv, (extendPoint_lt_iff xv u).mp hvu,
              fun w hvw hwm => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff xv w).mpr hvw) ((extendPoint_lt_iff w m).mpr hwm) ⟨w, rfl⟩)⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', huv', hv'm, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            exact ⟨fun v hsv hvu => by
                have hv_not_cut : v ∉ g.val.cut := by
                  intro hv_in
                  exact hmin_not_cut (g.val.downward_closed v (min z₁ z₂) hv_in (le_of_lt hsv))
                have hv_above_g : @LT.lt (ExtendedCarrier M atomMap r)
                    extendedLinearOrder.toLT (Sum.inr g) (Sum.inl v) :=
                  ⟨hv_not_cut, fun h => hv_not_cut h⟩
                exact (ihA v).mp (hA (extendPoint v) hv_above_g
                  ((extendPoint_lt_iff v u).mpr hvu) ⟨v, rfl⟩),
              xv', (extendPoint_lt_iff u xv').mp huv',
                (extendPoint_lt_iff xv' m).mp hv'm,
                fun h => hBv' ((ihB xv').mpr h)⟩
        · -- Fail
          exact ⟨uf, lt_of_le_of_lt (min_le_left z₁ z₂) hz₁_uf,
            (extendPoint_lt_iff uf m).mp hum_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init
          exact ⟨ui, lt_of_le_of_lt (min_le_right z₁ z₂) hz₂_ui,
            (extendPoint_lt_iff ui m).mp hum_init,
            fun v hvu hvm => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff ui v).mpr hvu) ((extendPoint_lt_iff v m).mpr hvm) ⟨v, rfl⟩)⟩
    · -- mpr: standard → mu-relativized
      intro ⟨s, hsm, h_body, ⟨uf, hsuf, hufm, hBuf⟩, ⟨ui, hsui, huim, hBui⟩⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ?_, ?_, ?_⟩
      · intro u hsu hum hmu_holds
        obtain ⟨u', rfl⟩ := hmu_holds
        have hsu' : s < u' := (extendPoint_lt_iff s u').mp hsu
        have hu'm : u' < m := (extendPoint_lt_iff u' m).mp hum
        have h_disj := h_body u' hsu' hu'm
        cases h_disj with
        | inl h =>
          left
          obtain ⟨v, hvu, hBv⟩ := h
          exact ⟨extendPoint v, (extendPoint_lt_iff v u').mpr hvu, ⟨v, rfl⟩,
            fun w hvw hwm hw_mu => by
              obtain ⟨w', rfl⟩ := hw_mu
              exact (ihB w').mpr (hBv w' ((extendPoint_lt_iff v w').mp hvw)
                ((extendPoint_lt_iff w' m).mp hwm))⟩
        | inr h =>
          right
          obtain ⟨hA, v', hu'v', hv'm, hBv'⟩ := h
          exact ⟨fun v hsv hvu hv_mu => by
              obtain ⟨v', rfl⟩ := hv_mu
              exact (ihA v').mpr (hA v' ((extendPoint_lt_iff s v').mp hsv)
                ((extendPoint_lt_iff v' u').mp hvu)),
            extendPoint v', (extendPoint_lt_iff u' v').mpr hu'v',
              (extendPoint_lt_iff v' m).mpr hv'm, ⟨v', rfl⟩,
              fun h => hBv' ((ihB v').mp h)⟩
      · exact ⟨extendPoint uf, (extendPoint_lt_iff s uf).mpr hsuf,
          (extendPoint_lt_iff uf m).mpr hufm, ⟨uf, rfl⟩,
          fun h => hBuf ((ihB uf).mp h)⟩
      · exact ⟨extendPoint ui, (extendPoint_lt_iff s ui).mpr hsui,
          (extendPoint_lt_iff ui m).mpr huim, ⟨ui, rfl⟩,
          fun v huv hvm hv_mu => by
            obtain ⟨v', rfl⟩ := hv_mu
            exact (ihB v').mpr (hBui v' ((extendPoint_lt_iff ui v').mp huv)
              ((extendPoint_lt_iff v' m).mp hvm))⟩
  | std_untl A B ihA ihB =>
    -- Standard Until at an actual point: same structure as temporal_truth_mu_at_point untl case
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · intro ⟨s, hms, hmu, hAs, hBu⟩
      obtain ⟨s', rfl⟩ := hmu
      have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
      exact ⟨s', hms', (ihA s').mp hAs, fun u hmu' hus =>
        (ihB u).mp (hBu (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu')
          ((extendPoint_lt_iff u s').mpr hus) ⟨u, rfl⟩)⟩
    · intro ⟨s, hms, hAs, hBu⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ⟨s, rfl⟩,
        (ihA s).mpr hAs, fun u hmu hus hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihB u').mpr (hBu u' ((extendPoint_lt_iff m u').mp hmu)
        ((extendPoint_lt_iff u' s).mp hus))
  | std_snce A B ihA ihB =>
    -- Standard Since at an actual point: same structure as temporal_truth_mu_at_point snce case
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · intro ⟨s, hsm, hmu, hAs, hBu⟩
      obtain ⟨s', rfl⟩ := hmu
      have hsm' : s' < m := (extendPoint_lt_iff s' m).mp hsm
      exact ⟨s', hsm', (ihA s').mp hAs, fun u hsu hum =>
        (ihB u).mp (hBu (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
          ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩)⟩
    · intro ⟨s, hsm, hAs, hBu⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ⟨s, rfl⟩,
        (ihA s).mpr hAs, fun u hsu hum hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihB u').mpr (hBu u' ((extendPoint_lt_iff s u').mp hsu)
        ((extendPoint_lt_iff u' m).mp hum))

/-! ### Gap Uniqueness for Lemma 9

Infrastructure for the gap detection correctness theorem. The key fact:
given D, m, there is at most one gap γ > m with gap_definable_on_left D
and D holding at all actual points between m and γ. This uses the
D-between condition to rule out multiple gaps.
-/

/-- Two gaps satisfying the Lemma 9 conditions for the same D and m must be equal.
    The key property: D holds at all actual points u with m < u and u ∈ γ.cut.
    If γ₁.cut ⊊ γ₂.cut, elements of γ₂.cut \ γ₁.cut are in γ₁.complement with D
    holding (by γ₂'s D-between condition), giving an initial segment of γ₁.complement
    where D holds, contradicting γ₁ being D-definable on the left. -/
theorem gap_detection_unique {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {γ₁ γ₂ : Gap M.carrier} {D : StaviFormula} {m : M.carrier}
    (h₁_def : gap_definable_on_left M atomMap γ₁ D)
    (h₂_def : gap_definable_on_left M atomMap γ₂ D)
    (h₁_bet : ∀ u : M.carrier, m < u → u ∈ γ₁.cut →
      stavi_temporal_truth M atomMap u D)
    (h₂_bet : ∀ u : M.carrier, m < u → u ∈ γ₂.cut →
      stavi_temporal_truth M atomMap u D)
    (hm₁ : m ∈ γ₁.cut)
    (hm₂ : m ∈ γ₂.cut) :
    γ₁ = γ₂ := by
  apply gap_ext
  by_contra hne
  -- WLOG γ₁.cut ⊊ γ₂.cut
  wlog h : ¬(γ₂.cut ⊆ γ₁.cut) with H
  · push_neg at hne
    rcases gap_cuts_total γ₁ γ₂ with hsub | hsub
    · exact h fun h' => hne (Set.Subset.antisymm hsub h')
    · exact H h₂_def h₁_def h₂_bet h₁_bet hm₂ hm₁ (Ne.symm hne)
        (fun h' => hne (Set.Subset.antisymm hsub h').symm)
  -- ∃ x ∈ γ₂.cut \ γ₁.cut
  obtain ⟨x, hx₂, hx₁⟩ := Set.not_subset.mp h
  -- γ₁ D-def-left: no initial segment of γ₁.complement has D
  obtain ⟨_, h_no_init⟩ := h₁_def
  -- Derive contradiction: D holds at an initial segment of γ₁.complement
  apply h_no_init
  -- Witness: x ∉ γ₁.cut, and D at all u ∉ γ₁.cut with u ≤ x
  refine ⟨x, hx₁, fun u hu_not_in hu_le => ?_⟩
  -- u ∉ γ₁.cut, so u > m (since m ∈ γ₁.cut and complement elements are above cut)
  have hmu : m < u := by
    by_contra h_not
    push_neg at h_not
    exact hu_not_in (γ₁.downward_closed m u hm₁ h_not)
  -- u ≤ x ∈ γ₂.cut, so u ∈ γ₂.cut by downward-closure
  have hu_in_2 : u ∈ γ₂.cut := γ₂.downward_closed x u hx₂ hu_le
  -- D(u) by the D-between condition for γ₂
  exact h₂_bet u hmu hu_in_2

/-! ### Core Gap Detection Helper: U'(X, D) at actual points

The fundamental connection between U'(X, D) evaluated at an actual point m
and the existence of a D-defined gap. This is the linchpin of Lemma 9:
all temporal cases of left_formula reduce to applications of this lemma.

**Forward direction** (U' → gap exists):
From U'(X, D)(m) with FO-table witness s, the gap γ is defined as the
boundary where D transitions from holding to failing in (m, s).
Gap cut = {x | ∀ u, m < u → u ≤ x → D(u)}.

**Backward direction** (gap → U'):
Given γ with gap conditions, choose s = some point in complement above γ
where ¬D holds. The FO table conditions follow from the gap axioms.
-/

/-- Core helper: U'(X, D) at an actual point m in M_r detects a D-defined
    gap γ > m where X holds at all complement points of γ below some bound,
    with D holding on all actual points between m and γ.
    This is the "engine" behind all temporal cases of Lemma 9.

    Note: The conclusion provides X at complement points (actual points above γ)
    rather than X^mu(γ), because atoms evaluate to False at gaps. Callers that
    need X^mu(γ) for temporal X can derive it from complement-point truth via
    the structure of temporal evaluation at gaps. -/
theorem stavi_untl_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (X D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (.stavi_untl X D) ↔
    (∃ (γ : RDefinableGap M atomMap r) (s_bound : M.carrier),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m < Sum.inr γ ∧
      s_bound ∉ γ.val.cut ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      (∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
        stavi_temporal_truth M atomMap u X)) := by
  -- Convert LHS from mu-relativized at actual point to standard evaluation
  rw [stavi_truth_mu_at_point m (.stavi_untl X D)]
  simp only [stavi_temporal_truth]
  -- Now LHS is the FO table: ∃ s > m, conditions (1)(2)(3)
  -- RHS is: ∃ γ, m < γ ∧ gap_definable_on_left γ D ∧ D-between(m,γ) ∧ X^mu(γ)
  constructor
  · -- **Forward direction** (FO table → gap):
    intro ⟨s, hms, h_body, ⟨u_fail, hmu_fail, hus_fail, hD_fail⟩,
           ⟨u_init, hmu_init, hus_init, hD_init⟩⟩
    -- Define gap cut via D-cofinality: x ∈ cut iff at every u ∈ (m, x],
    -- ∃ v > u with D on all of (m, v). Ensures cut has no sup in itself.
    let cut : Set M.carrier :=
      {x | ∀ u, m < u → u ≤ x →
        ∃ v, u < v ∧ ∀ w, m < w → w < v → stavi_temporal_truth M atomMap w D}
    have hm_in_cut : m ∈ cut :=
      fun u hmu hum => absurd (lt_of_lt_of_le hmu hum) (lt_irrefl m)
    have hu_fail_not_cut : u_fail ∉ cut := by
      intro h; obtain ⟨v, hfv, hDv⟩ := h u_fail hmu_fail le_rfl
      exact hD_fail (hDv u_fail hmu_fail hfv)
    have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
      intro x hx; by_contra h; push_neg at h
      exact hu_fail_not_cut (fun u hmu huf => hx u hmu (le_trans huf h))
    have h_cut_lt_s : ∀ x ∈ cut, x < s :=
      fun x hx => lt_trans (h_cut_lt_uf x hx) hus_fail
    have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
      fun x y hx hyx u hmu huy => hx u hmu (le_trans huy hyx)
    have h_proper : cut ≠ Set.univ := by
      intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
    -- Key: condition (1) right disjunct fails when all points below u are cofinal
    have h_cofinal_propagate :
        ∀ u, m < u → u < s →
        (∀ w, m < w → w < u →
          ∃ v, w < v ∧ ∀ z, m < z → z < v → stavi_temporal_truth M atomMap z D) →
        ∃ v, u < v ∧ ∀ z, m < z → z < v → stavi_temporal_truth M atomMap z D := by
      intro u hmu hus h_below
      cases h_body u hmu hus with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', hmv', hv'u, hDv'⟩ := h
        obtain ⟨v₂, hv'v₂, hDv₂⟩ := h_below v' hmv' hv'u
        exact absurd (hDv₂ v' hmv' hv'v₂) hDv'
    have hu_init_cut : u_init ∈ cut := by
      intro u hmu huu_init
      exact h_cofinal_propagate u hmu (lt_of_le_of_lt huu_init hus_init)
        (fun w hmw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
          fun z hmz hz_init => hD_init z hmz hz_init⟩)
    have h_D_at_cut : ∀ u, m < u → u ∈ cut → stavi_temporal_truth M atomMap u D := by
      intro u hmu hu_cut
      obtain ⟨v, huv, hDv⟩ := hu_cut u hmu le_rfl
      exact hDv u hmu huv
    -- Cut has no supremum in cut
    have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
      intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
      have hmp : m < p := lt_of_lt_of_le hmu_init (h_ub hu_init_cut)
      obtain ⟨v, hpv, hDv⟩ := hp_cut p hmp le_rfl
      have hvs : v < s := by
        by_contra h; push_neg at h
        exact hD_fail (hDv u_fail hmu_fail (lt_of_lt_of_le hus_fail h))
      have hv_cut : v ∈ cut := by
        intro u hmu huv
        rcases eq_or_lt_of_le huv with rfl | huv'
        · -- u = v (renamed), need cofinal at u
          exact h_cofinal_propagate u (lt_trans hmp hpv) hvs
            (fun w hmw hwu => ⟨u, hwu, hDv⟩)
        · exact ⟨v, huv', hDv⟩
      exact not_le.mpr hpv (h_ub hv_cut)
    -- Complement has no minimum
    have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
      intro ⟨b, hb_not, hb_min⟩
      have hmb : m < b := by
        by_contra h; push_neg at h; exact hb_not (h_dc m b hm_in_cut h)
      have hbs : b < s := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hus_fail
      have h_below_b : ∀ y, y < b → y ∈ cut := by
        intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
      cases h_body b hmb hbs with
      | inl h_cof =>
        exact hb_not (fun u hmu hub => by
          rcases eq_or_lt_of_le hub with rfl | hub'
          · exact h_cof
          · exact (h_below_b u hub') u hmu le_rfl)
      | inr h =>
        obtain ⟨_, v', hmv', hv'b, hDv'⟩ := h
        obtain ⟨v₂, hv'v₂, hDv₂⟩ := (h_below_b v' hv'b) v' hmv' le_rfl
        exact hDv' (hDv₂ v' hmv' hv'v₂)
    -- Construct the Gap
    let γ_gap : Gap M.carrier :=
      ⟨cut, ⟨m, hm_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
    -- gap_definable_on_left: D holds on final segment of cut (witness: m),
    -- and D does NOT hold on any initial segment of complement.
    have h_no_init_compl : ¬∃ t, t ∉ cut ∧
        ∀ u, u ∉ cut → u ≤ t → stavi_temporal_truth M atomMap u D := by
      intro ⟨t, ht_not, hDt⟩
      have hmt : m < t := by
        by_contra h; push_neg at h; exact ht_not (h_dc m t hm_in_cut h)
      have hts : t < s := by
        by_contra h; push_neg at h
        exact hD_fail (hDt u_fail hu_fail_not_cut (le_trans (le_of_lt hus_fail) h))
      -- Show t ∈ cut by showing cofinal at every u ∈ (m, t].
      -- For any u ∈ (m, t] with u < s, condition (1) right disjunct fails:
      -- any ¬D witness v' ∈ (m, u) has D(v') (from h_D_at_cut or hDt). So left holds.
      suffices t ∈ cut from ht_not this
      intro u hmu hut
      have hus : u < s := lt_of_le_of_lt hut hts
      exact h_cofinal_propagate u hmu hus (fun w hmw hwu => by
        have hws : w < s := lt_trans hwu hus
        exact h_cofinal_propagate w hmw hws (fun z hmz hzw => by
          have hzs : z < s := lt_trans hzw hws
          -- z ∈ (m, s). Right disjunct requires ¬D at v' ∈ (m, z).
          -- But v' < z < w < u ≤ t, so D(v') from cut or complement.
          cases h_body z hmz hzs with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hmv', hv'z, hDv'⟩ := h
            have : stavi_temporal_truth M atomMap v' D := by
              by_cases hv'_cut : v' ∈ cut
              · exact h_D_at_cut v' hmv' hv'_cut
              · exact hDt v' hv'_cut (le_trans (le_of_lt hv'z)
                  (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
            exact absurd this hDv'))
    have h_def_left : gap_definable_on_left M atomMap γ_gap D :=
      ⟨⟨u_init, hu_init_cut, fun u hmu hu_cut =>
        h_D_at_cut u (lt_of_lt_of_le hmu_init hmu) hu_cut⟩, h_no_init_compl⟩
    -- r-definability: D has depth ≤ r and defines the gap on the left
    have h_r_def : r_definable_gap M atomMap γ_gap r :=
      ⟨D, hD, Or.inl h_def_left⟩
    -- Package as RDefinableGap
    let γ_rdef : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
    refine ⟨γ_rdef, s, ?_, ?_, ?_, ?_, ?_⟩
    · -- extendPoint m < Sum.inr γ_rdef ↔ m ∈ cut (for point vs gap, < ↔ ∈ cut)
      constructor
      · exact hm_in_cut
      · intro h; exact h hm_in_cut
    · -- s ∉ cut: s is a complement point (cut points are all < s)
      intro hs_cut; exact not_lt.mpr le_rfl (h_cut_lt_s s hs_cut)
    · -- gap_definable_on_left M atomMap γ_rdef.val D
      exact h_def_left
    · -- D-between: ∀ u, m < u → u ∈ cut → D^mu(u)
      intro u hmu hu_cut
      exact (stavi_truth_mu_at_point u D).mpr
        (h_D_at_cut u hmu hu_cut)
    · -- X at complement points below s:
      -- For any complement point u < s, the right disjunct of condition (1)
      -- at a smaller complement point u₀ < u gives X at (u₀, s) ⊇ {u}.
      intro u hu_not_cut hus
      -- u ∉ cut, so m < u (complement points are above cut points, m ∈ cut)
      have hmu : m < u := by
        by_contra h; push_neg at h; exact hu_not_cut (h_dc m u hm_in_cut h)
      -- Since complement has no minimum, ∃ u₀ < u with u₀ ∉ cut
      have ⟨u₀, hu₀_not, hu₀u⟩ : ∃ u₀, u₀ ∉ cut ∧ u₀ < u := by
        by_contra h_all; push_neg at h_all
        exact h_comp_no_min ⟨u, hu_not_cut, fun y hy => h_all y hy⟩
      have hmu₀ : m < u₀ := by
        by_contra h; push_neg at h; exact hu₀_not (h_dc m u₀ hm_in_cut h)
      have hu₀s : u₀ < s := lt_trans hu₀u hus
      -- At complement point u₀: left disjunct would imply u₀ ∈ cut, so right holds
      have h_right_u₀ :
          (∀ v, u₀ < v → v < s → stavi_temporal_truth M atomMap v X) ∧
          ∃ v', m < v' ∧ v' < u₀ ∧ ¬stavi_temporal_truth M atomMap v' D := by
        cases h_body u₀ hmu₀ hu₀s with
        | inl h_left =>
          -- Left disjunct: ∃ v > u₀, D on (m, v). This implies u₀ ∈ cut.
          exfalso; apply hu₀_not
          obtain ⟨v, hu₀v, hDv⟩ := h_left
          intro u' hmu' hu'u₀
          exact ⟨v, lt_of_le_of_lt hu'u₀ hu₀v, hDv⟩
        | inr h_right => exact h_right
      -- From right disjunct at u₀: X at all points in (u₀, s), including u
      exact h_right_u₀.1 u hu₀u hus
  · -- **Backward direction** (gap → FO table):
    intro ⟨γ, s_bound, hm_lt_γ, hs_bound_not, h_def_left, h_D_bet, hX_compl⟩
    have hm_in_cut : m ∈ γ.val.cut :=
      (extendPoint_le_gap_iff m γ).mp (le_of_lt hm_lt_γ)
    obtain ⟨⟨t_cut, ht_in, ht_D_final⟩, h_no_init_seg⟩ := h_def_left
    -- Helper: from negation of initial segment condition, get ¬D witnesses
    have h_neg_init : ∀ t, t ∉ γ.val.cut →
        ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
      intro t ht; by_contra h_all; push_neg at h_all
      exact h_no_init_seg ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
    -- Helper: complement points are above all cut points (including m)
    have h_compl_gt_m : ∀ x, x ∉ γ.val.cut → m < x := by
      intro x hx; by_contra h; push_neg at h
      exact hx (γ.val.downward_closed m x hm_in_cut h)
    -- Complement is non-empty (cut is proper)
    have h_compl_ne : ∃ x, x ∉ γ.val.cut := by
      by_contra h_all; push_neg at h_all
      exact γ.val.proper (Set.eq_univ_iff_forall.mpr h_all)
    -- Use s_bound as s₀ (a complement point)
    refine ⟨s_bound, h_compl_gt_m s_bound hs_bound_not, ?_, ?_, ?_⟩
    · -- Condition (1): ∀ u ∈ (m, s_bound), disjunction
      intro u hmu hus
      by_cases hu_cut : u ∈ γ.val.cut
      · -- u ∈ cut: first disjunct — D cofinal above u
        left
        -- Since u ∈ cut and cut has no sup, ∃ y ∈ cut with y > u
        have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
          by_contra h_all; push_neg at h_all
          exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
        exact ⟨y, huy, fun w hmw hwy =>
          (stavi_truth_mu_at_point w D).mp
            (h_D_bet w hmw (γ.val.downward_closed y w hy_in (le_of_lt hwy)))⟩
      · -- u ∉ cut: second disjunct — X on (u, s_bound) and ¬D witness below u
        right
        refine ⟨?_, ?_⟩
        · -- ∀ v, u < v → v < s_bound → X(v)
          -- All points between two complement points are complement (upward-closed).
          -- hX_compl gives X at complement points below s_bound.
          intro v huv hvs
          -- v is between u (complement) and s_bound (complement), so v ∉ cut
          have hv_not : v ∉ γ.val.cut := by
            intro hv_in
            exact hu_cut (γ.val.downward_closed v u hv_in (le_of_lt huv))
          exact hX_compl v hv_not hvs
        · -- ∃ v', m < v' ∧ v' < u ∧ ¬D(v')
          -- complement_no_min gives y < u with y ∉ cut, then h_neg_init gives ¬D witness
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt_m w hw_not, lt_of_le_of_lt hwy hyu, hDw⟩
    · -- Condition (2): ∃ u ∈ (m, s_bound), ¬D(u)
      -- complement_no_min: s_bound is not the minimum, so ∃ y < s_bound in complement
      have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s_bound := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_bound_not, fun z hz => h_all z hz⟩
      -- h_neg_init gives ¬D witness at or below y
      obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
      exact ⟨w, h_compl_gt_m w hw_not, lt_of_le_of_lt hwy hys, hDw⟩
    · -- Condition (3): ∃ u ∈ (m, s_bound), D on (m, u)
      -- From no_sup: ∃ y ∈ cut with y > m
      have ⟨y, hy_in, hmy⟩ : ∃ y ∈ γ.val.cut, m < y := by
        by_contra h_all; push_neg at h_all
        exact γ.val.no_sup ⟨m, ⟨fun x hx => h_all x hx, fun b hb => hb hm_in_cut⟩, hm_in_cut⟩
      -- y < s_bound since y ∈ cut, s_bound ∉ cut, and cut is downward-closed
      have hys : y < s_bound := by
        by_contra h; push_neg at h
        exact hs_bound_not (γ.val.downward_closed y s_bound hy_in h)
      exact ⟨y, hmy, hys, fun v hmv hvy =>
        (stavi_truth_mu_at_point v D).mp
          (h_D_bet v hmv (γ.val.downward_closed y v hy_in (le_of_lt hvy)))⟩

-- std_untl_gap_detection: DELETED (provably false).
-- U(X,D) has no D-failure condition, so gap_definable_on_left fails for D = top.
-- Backward direction also fails: complement points have X but D fails near gap.
-- Affected cases in left/right_formula_gap_detection proved directly instead.

/-! ### Lemma 9: Gap Detection Correctness (GHR93)

The crucial bridge: `left_formula(A,D)` evaluated at an actual point m
detects whether there is a D-defined gap gamma > m where A^mu holds at gamma.

Precisely: for an actual point m in M, and a gap gamma in M_r:

  stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) ↔
    ∃ (γ : RDefinableGap M atomMap r),
      extendPoint m < Sum.inr γ ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A
-/

/--
**GHR93 Lemma 9** (Gap detection correctness, left direction):
left_formula(A, D) evaluated at an actual point m in M_r detects
whether A^mu holds at a gap gamma that is D-defined on the left,
with gamma > m and D holding at all actual points between m and gamma.

This is the core of the gap detection machinery: it converts a property
of a gap (A^mu holds there, gap is D-defined) into a temporal formula
evaluable at actual points.

NOTE: The full proof of Lemma 9 requires careful case analysis on the
structure of A, connecting the syntactic left_formula definition with
the semantic gap properties. The S/S' cases use `std_untl`/`std_snce`
constructors to correctly represent standard Until/Since of Stavi-enriched
subformulas. This is sorry'd pending the full game-theoretic proof in
Phase 4C.
-/
theorem left_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m < Sum.inr γ ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A) := by
  induction A generalizing m with
  | base φ =>
    -- left_formula (.base φ) D = left_formula_base D φ
    -- This case requires sub-induction on the Formula φ.
    -- All sub-cases reduce to the same pattern as the outer StaviFormula cases
    -- because left_formula_base maps atom/bot/box to .base .bot (both sides False)
    -- and imp/untl/snce to formulas that mirror the neg/conj/stavi_untl patterns.
    -- For now we handle this via a sub-induction on φ.
    simp only [left_formula]
    induction φ with
    | atom a =>
      -- left_formula_base D (atom a) = .base .bot
      simp only [left_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | bot =>
      -- left_formula_base D bot = .base .bot
      simp only [left_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | box f =>
      -- left_formula_base D (box f) = .base .bot
      simp only [left_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | imp f g ih_f ih_g =>
      -- left_formula_base D (f.imp g) = U'(⊤,D) ∧ ¬(left_base(f) ∧ (U'(⊤,D) ∧ ¬left_base(g)))
      -- The neg/conj outer cases handle this pattern using gap_detection_unique.
      -- imp = ¬(f ∧ ¬g), so (.base (f.imp g))^mu at γ = (f^mu → g^mu) at γ.
      -- Strategy: use the proved neg and conj outer-case patterns with gap uniqueness.
      constructor
      · -- Forward direction
        intro hLHS
        -- Unfold left_formula_base
        simp only [left_formula_base] at hLHS
        -- hLHS : stavi_temporal_truth_mu ... (.conj (.stavi_untl (.base top) D) (.neg (.conj (left_formula_base D f) (.conj (.stavi_untl (.base top) D) (.neg (left_formula_base D g))))))
        simp only [stavi_temporal_truth_mu] at hLHS
        obtain ⟨hU, hNeg⟩ := hLHS
        -- Extract gap from U'(⊤,D)(m)
        have hU' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
            (.stavi_untl (.base Formula.top) D) := by
          simp only [stavi_temporal_truth_mu]; exact hU
        obtain ⟨γ, _s_bound, hγ_lt, _hs_not, hγ_def, hγ_bet, _⟩ :=
          (stavi_untl_gap_detection (.base Formula.top) D hD m).mp hU'
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        -- Need: (.base (f.imp g))^mu(γ) = temporal_truth_mu M atomMap r (Sum.inr γ) (f.imp g)
        simp only [stavi_temporal_truth_mu, temporal_truth_mu]
        intro hf_at_γ
        -- From f^mu(γ), by IH backward: left_formula_base D f at m
        have hLeft_f : stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula_base D f) :=
          ih_f.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hf_at_γ⟩
        -- From ¬(left_base(f) ∧ U'(⊤,D) ∧ ¬left_base(g)) and left_base(f) and U'(⊤,D): left_base(g)
        have hLeft_g : stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula_base D g) := by
          by_contra h
          exact hNeg ⟨hLeft_f, hU, h⟩
        -- From left_base(g), by IH forward: ∃ γ', ... ∧ g^mu(γ')
        obtain ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hg_at_γ'⟩ := ih_g.mp hLeft_g
        -- γ = γ' by gap_detection_unique
        have hm_in : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        have hm_in' : m ∈ γ'.val.cut :=
          (extendPoint_le_gap_iff m γ').mp (le_of_lt hγ'_lt)
        have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
        have hγ'_bet_std : ∀ u, m < u → u ∈ γ'.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ'_bet u hmu hu_in)
        have heq : γ.val = γ'.val :=
          gap_detection_unique hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_in hm_in'
        rw [Subtype.ext heq]
        exact hg_at_γ'
      · -- Backward direction
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hfg_at_γ⟩
        simp only [left_formula_base, stavi_temporal_truth_mu]
        constructor
        · -- U'(⊤,D)(m): from γ, construct stavi_untl_gap_detection
          have h_compl : ∃ x, x ∉ γ.val.cut := by
            by_contra h; push_neg at h; exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
          obtain ⟨s_b, hs_b⟩ := h_compl
          have hTop_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_b →
              stavi_temporal_truth M atomMap u (.base Formula.top) := by
            intro u _ _
            simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
          have := (stavi_untl_gap_detection (.base Formula.top) D hD m).mpr
            ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_compl⟩
          simp only [stavi_temporal_truth_mu] at this
          exact this
        · -- ¬(left_base(f) ∧ U'(⊤,D)(m) ∧ ¬left_base(g))
          intro ⟨hLf, _, hNLg⟩
          obtain ⟨γ₁, hγ₁_lt, hγ₁_def, hγ₁_bet, hf_at_γ₁⟩ := ih_f.mp hLf
          have hm_in : m ∈ γ.val.cut :=
            (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
          have hm_in₁ : m ∈ γ₁.val.cut :=
            (extendPoint_le_gap_iff m γ₁).mp (le_of_lt hγ₁_lt)
          have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
          have hγ₁_bet_std : ∀ u, m < u → u ∈ γ₁.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ₁_bet u hmu hu_in)
          have heq : γ₁.val = γ.val :=
            gap_detection_unique hγ₁_def hγ_def hγ₁_bet_std hγ_bet_std hm_in₁ hm_in
          -- f → g at γ, so g^mu(γ)
          simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hfg_at_γ
          have hg_at_γ := hfg_at_γ ((Subtype.ext heq) ▸ hf_at_γ₁)
          exact hNLg (ih_g.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hg_at_γ⟩)
    | untl f g _ _ =>
      -- left_formula_base D (untl f g) = .stavi_untl (.conj (.base g) (.base (untl f g))) D
      -- This mirrors the stavi_untl outer case
      simp only [left_formula_base]
      rw [stavi_untl_gap_detection (.conj (.base g) (.base (.untl f g))) D hD m]
      constructor
      · -- Forward: complement-point truth of g ∧ U(f,g) → U(f,g)^mu at γ
        intro ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        -- hX_compl: ∀ u ∉ γ.cut, u < s_bound → g(u) ∧ U(f,g)(u)
        -- Need: U(f,g)^mu at Sum.inr γ
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth, temporal_truth_mu]
        -- U(f,g)^mu at γ: ∃ s > γ, mu_holds s ∧ f^mu(s) ∧ ∀ v ∈ (γ,s), mu_holds v → g^mu(v)
        -- Pick a complement point u₀ above γ where U(f,g) holds
        have ⟨u₀, hu₀_not, hu₀s⟩ : ∃ u₀, u₀ ∉ γ.val.cut ∧ u₀ < s_bound := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
        have hX_u₀ := hX_compl u₀ hu₀_not hu₀s
        simp only [stavi_temporal_truth, temporal_truth] at hX_u₀
        obtain ⟨hg_u₀, s₁, hu₀s₁, hf_s₁, hg_between⟩ := hX_u₀
        -- s₁ ∉ γ.cut (since u₀ ∉ γ.cut and u₀ < s₁, and cut is downward closed)
        have hs₁_not : s₁ ∉ γ.val.cut := by
          intro h; exact hu₀_not (γ.val.downward_closed s₁ u₀ h (le_of_lt hu₀s₁))
        refine ⟨extendPoint s₁, ⟨hs₁_not, hs₁_not⟩, ⟨s₁, rfl⟩,
          (temporal_truth_mu_at_point s₁ f).mpr hf_s₁, fun v hγv hvs hmu => ?_⟩
        obtain ⟨v₀, rfl⟩ := hmu
        have hv₀_not : v₀ ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint v₀ ≤ Sum.inr γ from h) hγv
        have hv₀_s₁ : v₀ < s₁ := (extendPoint_lt_iff v₀ s₁).mp hvs
        apply (temporal_truth_mu_at_point v₀ g).mpr
        by_cases hv_u₀ : u₀ < v₀
        · exact hg_between v₀ hv_u₀ hv₀_s₁
        · push_neg at hv_u₀
          have hv₀_sb : v₀ < s_bound := lt_of_le_of_lt hv_u₀ hu₀s
          exact (hX_compl v₀ hv₀_not hv₀_sb).1
      · -- Backward: U(f,g)^mu at γ → complement-point truth of g ∧ U(f,g)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
        simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hUA
        obtain ⟨s, hγs, hmu_s, hf_s, hg_mu⟩ := hUA
        obtain ⟨s₁, rfl⟩ := hmu_s
        have hs₁_not : s₁ ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint s₁ ≤ Sum.inr γ from h) hγs
        refine ⟨γ, s₁, hγ_lt, hs₁_not, hγ_def, hγ_bet, fun u hu_not hu_s₁ => ?_⟩
        simp only [stavi_temporal_truth, temporal_truth]
        constructor
        · -- g(u): u is a complement point between γ and s₁
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ) (extendPoint u) := by
            show u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu ((extendPoint_lt_iff u s₁).mpr hu_s₁) ⟨u, rfl⟩)
        · -- U(f,g)(u): use s₁ as witness
          refine ⟨s₁, hu_s₁, (temporal_truth_mu_at_point s₁ f).mp hf_s, fun v huv hvs₁ => ?_⟩
          have hv_not : v ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ) (extendPoint v) := by
            show v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
          exact (temporal_truth_mu_at_point v g).mp
            (hg_mu (extendPoint v) hγv ((extendPoint_lt_iff v s₁).mpr hvs₁) ⟨v, rfl⟩)
    | snce f g _ _ =>
      -- left_formula_base D (.snce f g) = .std_untl compound D where
      -- compound = D ∧ g ∧ S(f,g) ∧ U'(⊤, g∧D) ∧ ¬U'(D, g∧D)
      simp only [left_formula_base]
      rw [stavi_truth_mu_at_point m (.std_untl _ D)]
      simp only [stavi_temporal_truth]
      constructor
      · -- Forward: std_untl(compound, D)^mu(m) → gap conditions
        intro ⟨s, hms, hcompound_s, hD_bet⟩
        obtain ⟨hDs, hgs, hSnce_s, hU'_gD_s, hNotU'D_gD_s⟩ := hcompound_s
        obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_gD_s
        obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hgD_fail⟩ := h_fail
        obtain ⟨u_init, hsu_init, hu_init_s₁, hgD_init⟩ := h_init
        -- Build B∧D-cofinal cut (mirrors stavi_untl_gap_detection)
        let gD : M.carrier → Prop := fun u =>
          temporal_truth M atomMap u g ∧ stavi_temporal_truth M atomMap u D
        let cut : Set M.carrier :=
          {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → gD w}
        have hs_in_cut : s ∈ cut :=
          fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
        have hu_fail_not_cut : u_fail ∉ cut := by
          intro h; obtain ⟨v, hfv, hgDv⟩ := h u_fail hsu_fail le_rfl
          exact hgD_fail (hgDv u_fail hsu_fail hfv)
        have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
          intro x hx; by_contra h; push_neg at h
          exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
        have h_cut_lt_s₁ : ∀ x ∈ cut, x < s₁ :=
          fun x hx => lt_trans (h_cut_lt_uf x hx) hu_fail_s₁
        have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
          fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
        have h_proper : cut ≠ Set.univ := by
          intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
        have h_cofinal_propagate :
            ∀ u, s < u → u < s₁ →
            (∀ w, s < w → w < u →
              ∃ v, w < v ∧ ∀ z, s < z → z < v → gD z) →
            ∃ v, u < v ∧ ∀ z, s < z → z < v → gD z := by
          intro u hsu hus₁ h_below
          cases h_body u hsu hus₁ with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hsv', hv'u, hgDv'⟩ := h
            obtain ⟨v₂, hv'v₂, hgDv₂⟩ := h_below v' hsv' hv'u
            exact absurd (hgDv₂ v' hsv' hv'v₂) hgDv'
        have hu_init_cut : u_init ∈ cut := by
          intro u hsu huu_init
          exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
            (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
              fun z hsz hz_init => hgD_init z hsz hz_init⟩)
        have h_gD_at_cut : ∀ u, s < u → u ∈ cut → gD u := by
          intro u hsu hu_cut
          obtain ⟨v, huv, hgDv⟩ := hu_cut u hsu le_rfl
          exact hgDv u hsu huv
        have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
          intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
          have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
          obtain ⟨v, hpv, hgDv⟩ := hp_cut p hsp le_rfl
          have hvs₁ : v < s₁ := by
            by_contra h; push_neg at h
            exact hgD_fail (hgDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
          have hv_cut : v ∈ cut := by
            intro u hsu huv
            rcases eq_or_lt_of_le huv with rfl | huv'
            · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
                (fun w hsw hwu => ⟨u, hwu, hgDv⟩)
            · exact ⟨v, huv', hgDv⟩
          exact not_le.mpr hpv (h_ub hv_cut)
        have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
          intro ⟨b, hb_not, hb_min⟩
          have hsb : s < b := by
            by_contra h; push_neg at h; exact hb_not (h_dc s b hs_in_cut h)
          have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
          have h_below_b : ∀ y, y < b → y ∈ cut := by
            intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
          cases h_body b hsb hbs₁ with
          | inl h_cof =>
            exact hb_not (fun u hsu hub => by
              rcases eq_or_lt_of_le hub with rfl | hub'
              · exact h_cof
              · exact (h_below_b u hub') u hsu le_rfl)
          | inr h =>
            obtain ⟨_, v', hsv', hv'b, hgDv'⟩ := h
            obtain ⟨v₂, hv'v₂, hgDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
            exact hgDv' (hgDv₂ v' hsv' hv'v₂)
        -- Construct the Gap
        let γ_gap : Gap M.carrier :=
          ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
        -- Show D-definable-on-left
        -- Part 1: D cofinal in cut (from gD cofinal → D cofinal)
        have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
            ∀ u, t ≤ u → u ∈ γ_gap.cut → stavi_temporal_truth M atomMap u D :=
          ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
            (h_gD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
        -- Part 2a: No initial complement segment with gD
        have h_no_init_compl_gD : ¬∃ t, t ∉ γ_gap.cut ∧
            ∀ u, u ∉ γ_gap.cut → u ≤ t → gD u := by
          intro ⟨t, ht_not, hgDt⟩
          have hst : s < t := by
            by_contra h; push_neg at h; exact ht_not (h_dc s t hs_in_cut h)
          have hts₁ : t < s₁ := by
            by_contra h; push_neg at h
            exact hgD_fail (hgDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
          suffices t ∈ cut from ht_not this
          intro u hsu hut
          exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
            (fun w hsw hwu =>
              h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
                (fun z hsz hzw => by
                  cases h_body z hsz (lt_trans hzw (lt_trans hwu
                      (lt_of_le_of_lt hut hts₁))) with
                  | inl h => exact h
                  | inr h =>
                    obtain ⟨_, v', hsv', hv'z, hgDv'⟩ := h
                    have : gD v' := by
                      by_cases hv'_cut : v' ∈ cut
                      · exact h_gD_at_cut v' hsv' hv'_cut
                      · exact hgDt v' hv'_cut (le_trans (le_of_lt hv'z)
                          (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                    exact absurd this hgDv'))
        -- D-failure: D fails somewhere in (s, s₁)
        have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
            ¬stavi_temporal_truth M atomMap u_D D := by
          by_contra h_all_D; push_neg at h_all_D
          apply hNotU'D_gD_s
          exact ⟨s₁, hss₁,
            fun u hsu hus₁ => by
              cases h_body u hsu hus₁ with
              | inl h => left; exact h
              | inr h =>
                right
                exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁,
                       h.2⟩,
            ⟨u_fail, hsu_fail, hu_fail_s₁, hgD_fail⟩,
            ⟨u_init, hsu_init, hu_init_s₁, hgD_init⟩⟩
        obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
        have hu_D_not_cut : u_D ∉ cut := by
          intro h; exact hD_fail_D (h_gD_at_cut u_D hsu_D h).2
        -- Complement points are > all cut points
        have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
          intro x hx y hy; by_contra h; push_neg at h
          exact hx (h_dc y x hy h)
        -- Part 2b: No initial complement segment with D
        have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
            ∀ u, u ∉ γ_gap.cut → u ≤ t →
              stavi_temporal_truth M atomMap u D := by
          intro ⟨t, ht_not, hDt⟩
          have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
          -- t < u_D (otherwise D(u_D) from hDt)
          have ht_uD : t < u_D := by
            by_contra h; push_neg at h
            exact hD_fail_D (hDt u_D hu_D_not_cut h)
          have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
          -- Construct U'(D, gD)(s) with bound t, contradicting hNotU'D_gD_s
          apply hNotU'D_gD_s
          refine ⟨t, hst, ?_, ?_, ?_⟩
          · -- Condition 1
            intro u hsu hut
            cases h_body u hsu (lt_trans hut hts₁) with
            | inl h => left; exact h
            | inr h =>
              right
              exact ⟨fun v huv hvt => by
                by_cases hv_cut : v ∈ cut
                · exact (h_gD_at_cut v (lt_trans hsu huv) hv_cut).2
                · exact hDt v hv_cut (le_of_lt hvt),
                h.2⟩
          · -- Condition 2: gD fails in (s, t)
            by_contra h_no_fail; push_neg at h_no_fail
            apply h_no_init_compl_gD
            -- All complement points ≤ t have gD? We need a complement point with ¬gD
            -- complement_no_min gives ∃ c < t with c ∉ cut
            obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
              by_contra h; push_neg at h
              exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
            -- h_no_fail says: ∀ u, s < u → u < t → gD u (no gD failure in (s,t))
            -- c is complement, s < c < t, so gD(c) from h_no_fail
            have hsc : s < c := h_compl_gt_cut c hc_not s hs_in_cut
            have hgDc := h_no_fail c hsc hct
            -- But then c is complement with gD: initial complement has gD
            exact ⟨c, hc_not, fun u hu huc => by
              have hsu' : s < u := h_compl_gt_cut u hu s hs_in_cut
              have hut' : u < t := lt_of_le_of_lt huc hct
              exact h_no_fail u hsu' hut'⟩
          · -- Condition 3: gD initial in (s, t)
            have : u_init < t := h_compl_gt_cut t ht_not u_init hu_init_cut
            exact ⟨u_init, hsu_init, this, hgD_init⟩
        have h_def_left_D : gap_definable_on_left M atomMap γ_gap D :=
          ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
        have h_r_def : r_definable_gap M atomMap γ_gap r :=
          ⟨D, hD, Or.inl h_def_left_D⟩
        let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
        refine ⟨γ, ?_, ?_, ?_, ?_⟩
        · -- extendPoint m < Sum.inr γ: m ∈ cut
          have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
          constructor
          · exact hm_in
          · intro h; exact h hm_in
        · exact h_def_left_D
        · -- D^mu at cut points above m
          intro u hmu hu_cut
          by_cases hsu : s < u
          · exact (stavi_truth_mu_at_point u D).mpr (h_gD_at_cut u hsu hu_cut).2
          · push_neg at hsu
            rcases eq_or_lt_of_le hsu with rfl | hus
            · exact (stavi_truth_mu_at_point u D).mpr hDs
            · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
        · -- S(f,g)^mu at γ: use witness from S(f,g)(s)
          simp only [temporal_truth] at hSnce_s
          obtain ⟨q, hqs, hf_q, hg_qs⟩ := hSnce_s
          have hq_cut : q ∈ cut := h_dc s q hs_in_cut (le_of_lt hqs)
          show temporal_truth_mu M atomMap r (Sum.inr γ) (f.snce g)
          exact ⟨extendPoint q, ⟨hq_cut, fun h => h hq_cut⟩, ⟨q, rfl⟩,
            (temporal_truth_mu_at_point q f).mpr hf_q,
            fun u hqu huγ hmu => by
              obtain ⟨p, rfl⟩ := hmu
              apply (temporal_truth_mu_at_point p g).mpr
              have hp_cut : p ∈ cut := huγ.1
              have hqp : q < p := (extendPoint_lt_iff q p).mp hqu
              by_cases hps : p ≤ s
              · rcases eq_or_lt_of_le hps with rfl | hps'
                · exact hgs
                · exact hg_qs p hqp hps'
              · push_neg at hps
                exact (h_gD_at_cut p hps hp_cut).1⟩
      · -- Backward: gap conditions → std_untl(compound, D)^mu(m)
        -- Given D-gap γ with S(f,g)^mu(γ), construct std_untl(compound, D)(m)
        -- where compound = D ∧ g ∧ S(f,g) ∧ U'(⊤, g∧D) ∧ ¬U'(D, g∧D)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
        -- S(f,g)^mu(γ): ∃ t < γ (mu-point), f^mu(t) ∧ g^mu on (t, γ)
        simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hSnce_mu
        obtain ⟨t_ext, ht_γ, ⟨t_pt, rfl⟩, hf_t, hg_mu⟩ := hSnce_mu
        -- t_pt is in the cut
        have ht_cut : t_pt ∈ γ.val.cut :=
          (extendPoint_le_gap_iff t_pt γ).mp (le_of_lt ht_γ)
        -- m is in the cut
        have hm_cut : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        -- Find a cut point s above both m and t_pt (cut has no sup)
        have ⟨s, hs_cut, hms, hts⟩ : ∃ s, s ∈ γ.val.cut ∧ m < s ∧ t_pt < s := by
          -- Cut has no sup, so there exist cut points above any cut member.
          -- We need one above both m and t_pt.
          -- First get one above m:
          have ⟨s₁, hs₁, hms₁⟩ : ∃ s₁ ∈ γ.val.cut, m < s₁ := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨m, ⟨h, fun _ hb => hb hm_cut⟩, hm_cut⟩
          -- Then get one above max(s₁, t_pt):
          have hmax_cut : max s₁ t_pt ∈ γ.val.cut := by
            rcases le_or_lt s₁ t_pt with h | h
            · simp [max_eq_right h]; exact ht_cut
            · simp [max_eq_left (le_of_lt h)]; exact hs₁
          have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max s₁ t_pt < s₂ := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨max s₁ t_pt, ⟨h, fun _ hb => hb hmax_cut⟩, hmax_cut⟩
          exact ⟨s₂, hs₂,
            lt_trans hms₁ (lt_of_le_of_lt (le_max_left s₁ t_pt) hmax_s₂),
            lt_of_le_of_lt (le_max_right s₁ t_pt) hmax_s₂⟩
        -- Properties at s (cut point above m and t_pt):
        -- D(s) from D-between
        have hDs : stavi_temporal_truth M atomMap s D :=
          (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
        -- g(s) from S(f,g)^mu(γ): s is a cut point above t_pt
        have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t_pt) (extendPoint s) :=
          (extendPoint_lt_iff t_pt s).mpr hts
        have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint s) (Sum.inr γ) := by
          exact ⟨hs_cut, fun h => h hs_cut⟩
        have hgs : temporal_truth M atomMap s g :=
          (temporal_truth_mu_at_point s g).mp
            (hg_mu (extendPoint s) hγs hγs' ⟨s, rfl⟩)
        -- S(f,g)(s): witness t_pt with f(t_pt) and g on (t_pt, s)
        have hSnce_s : temporal_truth M atomMap s (f.snce g) := by
          simp only [temporal_truth]
          refine ⟨t_pt, hts, (temporal_truth_mu_at_point t_pt f).mp hf_t, fun u htu hus => ?_⟩
          have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t_pt) (extendPoint u) :=
            (extendPoint_lt_iff t_pt u).mpr htu
          have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (Sum.inr γ) := ⟨hu_cut, fun h => h hu_cut⟩
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu huγ ⟨u, rfl⟩)
        -- D on (m, s): all points between m and s are cut points and have D
        have hD_bet_ms : ∀ u, m < u → u < s → stavi_temporal_truth M atomMap u D := by
          intro u hmu hus
          have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_cut)
        -- Extract gap definability conditions
        obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
        -- Helper: complement points > cut points
        have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
          intro x hx y hy; by_contra h; push_neg at h
          exact hx (γ.val.downward_closed y x hy h)
        -- Helper: ¬D witnesses at complement points
        have h_neg_init : ∀ t, t ∉ γ.val.cut →
            ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
          intro t ht; by_contra h_all; push_neg at h_all
          exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
        -- Get a complement point for U'(⊤, g∧D) bound
        have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
          by_contra h; push_neg at h
          exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
        have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
        -- g∧D at cut points above s
        have h_gD_cut : ∀ u, s < u → u ∈ γ.val.cut →
            temporal_truth M atomMap u g ∧ stavi_temporal_truth M atomMap u D := by
          intro u hsu hu_cut
          exact ⟨(temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u)
              ((extendPoint_lt_iff t_pt u).mpr (lt_trans hts hsu))
              ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
            (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
        refine ⟨s, hms, ⟨hDs, hgs, hSnce_s, ?_, ?_⟩, hD_bet_ms⟩
        · -- U'(⊤, g∧D)(s): bound c₀
          refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
          · -- Condition (1): body
            intro u hsu huc₀
            by_cases hu_cut : u ∈ γ.val.cut
            · -- u ∈ cut: left disjunct (gD cofinal)
              left
              have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
                by_contra h_all; push_neg at h_all
                exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
              exact ⟨y, huy, fun w hsw hwy =>
                h_gD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
            · -- u ∉ cut: right disjunct (⊤ trivial + ¬gD witness)
              right
              refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
              have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
                by_contra h_all; push_neg at h_all
                exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
              obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
              exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
                fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (2): ¬gD failure in (s, c₀)
            have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
              fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (3): gD initial in (s, c₀)
            have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
            exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
              h_gD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
        · -- ¬U'(D, g∧D)(s): by contradiction using two-step D-transfer argument
          intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
          obtain ⟨u_fail, hsu_fail, huf_s₁, hgD_fail⟩ := h_fail
          have huf_not_cut : u_fail ∉ γ.val.cut := by
            intro h; exact hgD_fail (h_gD_cut u_fail hsu_fail h)
          -- Left disjunct fails at any complement point: ¬D below blocks gD on (s,v)
          have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
              ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
                temporal_truth M atomMap w g ∧ stavi_temporal_truth M atomMap w D) := by
            intro u hsu _ hu_not ⟨v, huv, hgDv⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact hDw (hgDv w (h_compl_gt w hw_not s hs_cut)
              (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
          -- Two-step argument: D holds at ALL complement points in (s, s₁)
          have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
              stavi_temporal_truth M atomMap u D := by
            intro u hsu hus₁ hu_not
            -- Step 1: right branch at u gives v' ∈ (s, u) complement
            have h_right_u := (h_body u hsu hus₁).resolve_left
              (h_left_fails u hsu hus₁ hu_not)
            obtain ⟨_, v', hsv', hv'u, hgD_v'⟩ := h_right_u
            have hv'_not : v' ∉ γ.val.cut := by
              intro h; exact hgD_v' (h_gD_cut v' hsv' h)
            -- Step 2: right branch at v' gives D on (v', s₁)
            have hv'_s₁ : v' < s₁ := lt_trans hv'u hus₁
            have h_right_v' := (h_body v' hsv' hv'_s₁).resolve_left
              (h_left_fails v' hsv' hv'_s₁ hv'_not)
            -- D(u) from D on (v', s₁) since v' < u < s₁
            exact h_right_v'.1 u hv'u hus₁
          -- Contradiction: initial D-segment in complement violates gap condition (2)
          have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
          apply h_no_init_D
          exact ⟨t, ht_not, fun u hu_not hut =>
            hD_all_compl u (h_compl_gt u hu_not s hs_cut)
              (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩
  | neg A ih =>
    -- left_formula (.neg A) D = .conj (.stavi_untl (.base top) D) (.neg (left_formula A D))
    simp only [left_formula, stavi_temporal_truth_mu]
    constructor
    · -- Forward: U'(top, D)(m) ∧ ¬left(A,D)(m) → ∃ γ with ¬A^mu(γ)
      intro ⟨hU, hNot⟩
      -- Use stavi_untl_gap_detection to extract gap from U'(top, D)(m)
      -- First reconstruct the stavi_untl term from the expanded goal
      have hU' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
          (.stavi_untl (.base Formula.top) D) := by
        simp only [stavi_temporal_truth_mu]; exact hU
      obtain ⟨γ, _s_bound, hγ_lt, _hs_not, hγ_def, hγ_bet, _⟩ :=
        (stavi_untl_gap_detection (.base Formula.top) D hD m).mp hU'
      -- From ¬left(A,D)(m), by IH we get ¬(∃ γ with A^mu(γ))
      -- But actually we get: ¬ left_formula(A,D)(m), so by IH: not (∃ γ, ... ∧ A^mu(γ))
      have hNot' : ¬(∃ (γ' : RDefinableGap M atomMap r),
          extendPoint m < Sum.inr γ' ∧
          gap_definable_on_left M atomMap γ'.val D ∧
          (∀ u, m < u → u ∈ γ'.val.cut → stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
          stavi_temporal_truth_mu M atomMap r (Sum.inr γ') A) := by
        rwa [← ih m]
      -- Therefore γ has ¬A^mu(γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      intro hA_at_γ
      exact hNot' ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_at_γ⟩
    · -- Backward: ∃ γ with ¬A^mu(γ) → U'(top, D)(m) ∧ ¬left(A,D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hNot_A⟩
      constructor
      · -- U'(top, D)(m)
        -- Need s_bound ∉ cut. Get one from complement_no_min or properness.
        have h_compl : ∃ x, x ∉ γ.val.cut := by
          by_contra h; push_neg at h; exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
        obtain ⟨s_b, hs_b⟩ := h_compl
        -- top holds at all complement points (trivially)
        have hTop_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_b →
            stavi_temporal_truth M atomMap u (.base Formula.top) := by
          intro u _ _
          simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
        have := (stavi_untl_gap_detection (.base Formula.top) D hD m).mpr
          ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_compl⟩
        simp only [stavi_temporal_truth_mu] at this
        exact this
      · -- ¬left(A,D)(m)
        rw [ih m]
        intro ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hA_at_γ'⟩
        -- γ and γ' must be equal by gap_detection_unique
        have hm_in : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        have hm_in' : m ∈ γ'.val.cut :=
          (extendPoint_le_gap_iff m γ').mp (le_of_lt hγ'_lt)
        have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_in
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
        have hγ'_bet_std : ∀ u, m < u → u ∈ γ'.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_in
          exact (stavi_truth_mu_at_point u D).mp (hγ'_bet u hmu hu_in)
        have heq : γ.val = γ'.val :=
          gap_detection_unique hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_in hm_in'
        have : γ = γ' := Subtype.ext heq
        rw [this] at hNot_A
        exact hNot_A hA_at_γ'
  | conj A B ihA ihB =>
    -- left_formula (.conj A B) D = .conj (left_formula A D) (left_formula B D)
    simp only [left_formula, stavi_temporal_truth_mu]
    constructor
    · -- Forward: left(A,D)(m) ∧ left(B,D)(m) → ∃ γ with (A ∧ B)^mu(γ)
      intro ⟨hA, hB⟩
      obtain ⟨γA, hγA_lt, hγA_def, hγA_bet, hγA_val⟩ := (ihA m).mp hA
      obtain ⟨γB, hγB_lt, hγB_def, hγB_bet, hγB_val⟩ := (ihB m).mp hB
      -- γA and γB must be equal by gap_detection_unique
      have hm_in_A : m ∈ γA.val.cut :=
        (extendPoint_le_gap_iff m γA).mp (le_of_lt hγA_lt)
      have hm_in_B : m ∈ γB.val.cut :=
        (extendPoint_le_gap_iff m γB).mp (le_of_lt hγB_lt)
      -- Convert D-between conditions to use stavi_temporal_truth
      have hγA_bet' : ∀ u, m < u → u ∈ γA.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hmu hu_in
        exact (stavi_truth_mu_at_point u D).mp (hγA_bet u hmu hu_in)
      have hγB_bet' : ∀ u, m < u → u ∈ γB.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hmu hu_in
        exact (stavi_truth_mu_at_point u D).mp (hγB_bet u hmu hu_in)
      have heq : γA.val = γB.val :=
        gap_detection_unique hγA_def hγB_def hγA_bet' hγB_bet' hm_in_A hm_in_B
      refine ⟨γA, hγA_lt, hγA_def, hγA_bet, ?_, ?_⟩
      · exact hγA_val
      · have : γA = γB := Subtype.ext heq
        rw [this]
        exact hγB_val
    · -- Backward: ∃ γ with (A ∧ B)^mu(γ) → left(A,D)(m) ∧ left(B,D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val, hB_val⟩
      exact ⟨(ihA m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val⟩,
             (ihB m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hB_val⟩⟩
  | stavi_untl A B _ _ =>
    -- left_formula (.stavi_untl A B) D = .stavi_untl (.conj B (.stavi_untl A B)) D
    -- Need: U'(B ∧ U'(A,B), D)(m) ↔ ∃ γ, ... ∧ U'(A,B)^mu(γ)
    simp only [left_formula]
    constructor
    · -- Forward: from U'(B ∧ U'(A,B), D)(m), get gap with (B ∧ U'(A,B)) at complement points
      -- Extract U'(A,B) at complement points, then construct U'(A,B)^mu(γ)
      intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩ :=
        (stavi_untl_gap_detection (.conj B (.stavi_untl A B)) D hD m).mp h
      -- Extract stavi_untl(A,B) and B at complement points below s_bound
      have hUA_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u (.stavi_untl A B) :=
        fun u hu hus => (hX_compl u hu hus).2
      have hB_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u B :=
        fun u hu hus => (hX_compl u hu hus).1
      -- Pick complement point u₁ < s_bound
      have ⟨u₁, hu₁_not, hu₁s⟩ : ∃ u₁, u₁ ∉ γ.val.cut ∧ u₁ < s_bound := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
      -- FO table of stavi_untl(A,B) at u₁
      have hUA_u₁ := hUA_compl u₁ hu₁_not hu₁s
      simp only [stavi_temporal_truth] at hUA_u₁
      obtain ⟨s₁, hu₁s₁, h_body₁, ⟨wf, hwf_u₁, hwf_s₁, hBwf⟩,
              ⟨wi, hwi_u₁, hwi_s₁, hBwi⟩⟩ := hUA_u₁
      -- s₁ ∉ cut (upward-closed complement: s₁ > u₁ ∉ cut)
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed s₁ u₁ h (le_of_lt hu₁s₁))
      -- wf ∉ cut (wf > u₁)
      have hwf_not : wf ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed wf u₁ h (le_of_lt hwf_u₁))
      -- wi ∉ cut (wi > u₁)
      have hwi_not : wi ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed wi u₁ h (le_of_lt hwi_u₁))
      -- Construct stavi_untl(A,B)^mu(Sum.inr γ):
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      -- Need: stavi_temporal_truth_mu M atomMap r (Sum.inr γ) (.stavi_untl A B)
      -- Use (stavi_truth_mu_at_point u₁ (.stavi_untl A B)).mpr to convert back
      -- Actually, construct directly in the mu-relativized form
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
      refine ⟨extendPoint s₁, ?_, ?_, ?_, ?_⟩
      · -- Sum.inr γ < extendPoint s₁: s₁ ∉ cut
        exact ⟨hs₁_not, hs₁_not⟩
      · -- Condition (1): ∀ mu-point u ∈ (γ, extendPoint s₁), FO body
        intro u hγu hus₁ hmu
        obtain ⟨u_pt, rfl⟩ := hmu
        -- u_pt ∉ cut (Sum.inr γ < extendPoint u_pt means u_pt ∉ cut)
        have hu_pt_not : u_pt ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
        -- u_pt < s₁ (extendPoint u_pt < extendPoint s₁)
        have hu_pt_s₁ : u_pt < s₁ := (extendPoint_lt_iff u_pt s₁).mp hus₁
        -- Case split: u_pt > u₁ (use inner FO table) or u_pt ≤ u₁ (B-cofinal)
        by_cases hu_pt_u₁ : u₁ < u_pt
        · -- u_pt > u₁: use h_body₁ at u_pt
          cases h_body₁ u_pt hu_pt_u₁ hu_pt_s₁ with
          | inl h_cof =>
            -- LEFT: ∃ v > u_pt, B on (u₁, v). Extend to B on (γ, v) using hB_compl.
            left
            obtain ⟨v, hu_pt_v, hBv⟩ := h_cof
            refine ⟨extendPoint v, (extendPoint_lt_iff u_pt v).mpr hu_pt_v, ⟨v, rfl⟩,
              fun w hγw hwv hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_pt_v : w_pt < v := (extendPoint_lt_iff w_pt v).mp hwv
            have hw_pt_not : w_pt ∉ γ.val.cut := by
              intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
            -- w_pt is a complement point. If w_pt > u₁, use hBv. If w_pt ≤ u₁, use hB_compl.
            by_cases hwu₁ : u₁ < w_pt
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hwu₁ hw_pt_v)
            · push_neg at hwu₁
              -- w_pt ≤ u₁. w_pt ∉ cut and w_pt < s_bound (w_pt < v < s₁, s₁ > u₁, u₁ < s_bound)
              -- Need w_pt < s_bound. w_pt ≤ u₁ < s_bound.
              have hw_sb : w_pt < s_bound := lt_of_le_of_lt hwu₁ hu₁s
              exact (stavi_truth_mu_at_point w_pt B).mpr (hB_compl w_pt hw_pt_not hw_sb)
          | inr h_right =>
            -- RIGHT: A on (u_pt, s₁) and ¬B witness v' ∈ (u₁, u_pt)
            right
            obtain ⟨hA_above, v', hmv', hv'u, hBv'⟩ := h_right
            refine ⟨fun v hv hvs hmu_v => ?_, ?_⟩
            · -- A^mu(v) for v mu-point in (u_pt, s₁)
              obtain ⟨v_pt, rfl⟩ := hmu_v
              exact (stavi_truth_mu_at_point v_pt A).mpr
                (hA_above v_pt ((extendPoint_lt_iff u_pt v_pt).mp hv)
                  ((extendPoint_lt_iff v_pt s₁).mp hvs))
            · -- ∃ v' mu-point ∈ (γ, u_pt) with ¬B^mu(v')
              refine ⟨extendPoint v', ?_, (extendPoint_lt_iff v' u_pt).mpr hv'u,
                ⟨v', rfl⟩, ?_⟩
              · -- Sum.inr γ < extendPoint v': v' > u₁ > γ (v' ∈ (u₁, u_pt))
                show v' ∉ γ.val.cut ∧ ¬(v' ∈ γ.val.cut)
                have hv'_not : v' ∉ γ.val.cut := by
                  intro h; exact hu₁_not (γ.val.downward_closed v' u₁ h (le_of_lt hmv'))
                exact ⟨hv'_not, hv'_not⟩
              · exact mt (stavi_truth_mu_at_point v' B).mp hBv'
        · -- u_pt ≤ u₁: B holds at u_pt (from hB_compl) and at all complement points below wi
          -- Use LEFT disjunct: B cofinal
          push_neg at hu_pt_u₁
          left
          -- Need ∃ v_mu > u_pt with B^mu on (γ, v_mu)
          -- Use v_mu = extendPoint wi (wi from inner FO table: B on (u₁, wi))
          refine ⟨extendPoint wi, (extendPoint_lt_iff u_pt wi).mpr (lt_of_le_of_lt hu_pt_u₁ hwi_u₁),
            ⟨wi, rfl⟩, fun w hγw hwwi hmu_w => ?_⟩
          obtain ⟨w_pt, rfl⟩ := hmu_w
          have hw_pt_not : w_pt ∉ γ.val.cut := by
            intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
          have hw_pt_wi : w_pt < wi := (extendPoint_lt_iff w_pt wi).mp hwwi
          by_cases hwu₁ : u₁ < w_pt
          · -- w_pt > u₁: B at w_pt from hBwi (B on (u₁, wi))
            exact (stavi_truth_mu_at_point w_pt B).mpr (hBwi w_pt hwu₁ hw_pt_wi)
          · -- w_pt ≤ u₁: B at w_pt from hB_compl
            push_neg at hwu₁
            exact (stavi_truth_mu_at_point w_pt B).mpr
              (hB_compl w_pt hw_pt_not (lt_of_le_of_lt hwu₁ hu₁s))
      · -- Condition (2): ∃ mu-point in (γ, s') with ¬B^mu
        refine ⟨extendPoint wf, ?_, (extendPoint_lt_iff wf s₁).mpr hwf_s₁,
          ⟨wf, rfl⟩, mt (stavi_truth_mu_at_point wf B).mp hBwf⟩
        show wf ∉ γ.val.cut ∧ ¬(wf ∈ γ.val.cut)
        exact ⟨hwf_not, hwf_not⟩
      · -- Condition (3): ∃ mu-point in (γ, s') with B^mu initial
        -- Use u₁ as the initial segment witness: B holds at all complement points in (γ, u₁)
        -- because complement points below u₁ are below s_bound, so hB_compl applies.
        -- But we need the initial mu-point between γ and s₁ where B holds from γ to that point.
        -- Wait: we need ∃ u_init ∈ (γ, s'), B^mu on (γ, u_init). The interval (γ, u_init)
        -- should contain only complement points where B holds.
        -- Pick u₁ itself if B at all complement points below u₁.
        -- Actually, from hBwi: B on (u₁, wi). Combined with hB_compl for complement points
        -- below u₁, we can use wi as the initial segment bound: B on complement points in (γ, wi).
        -- But we need u_init to satisfy: u_init ∈ (γ, s') and B^mu on (γ, u_init).
        -- complement_no_min gives us complement points below u₁ where B holds.
        -- Use wi as u_init: B holds on all complement points in (γ, wi).
        refine ⟨extendPoint wi, ?_, (extendPoint_lt_iff wi s₁).mpr hwi_s₁,
          ⟨wi, rfl⟩, fun v hγv hvwi hmu_v => ?_⟩
        · show wi ∉ γ.val.cut ∧ ¬(wi ∈ γ.val.cut)
          exact ⟨hwi_not, hwi_not⟩
        · obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_pt_not : v_pt ∉ γ.val.cut := by
            intro h; exact not_lt.mpr (show extendPoint v_pt ≤ Sum.inr γ from h) hγv
          have hv_pt_wi : v_pt < wi := (extendPoint_lt_iff v_pt wi).mp hvwi
          by_cases hvu₁ : u₁ < v_pt
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBwi v_pt hvu₁ hv_pt_wi)
          · push_neg at hvu₁
            exact (stavi_truth_mu_at_point v_pt B).mpr
              (hB_compl v_pt hv_pt_not (lt_of_le_of_lt hvu₁ hu₁s))
    · -- Backward: from gap with U'(A,B)^mu(γ), construct U'(B ∧ U'(A,B), D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      -- From U'(A,B)^mu(γ), extract complement-point truth of B ∧ U'(A,B)
      -- U'(A,B)^mu(γ) gives FO table at the gap with witnesses among complement points
      simp only [stavi_temporal_truth_mu] at hUA
      obtain ⟨s_ua, hγ_s_ua, h_body_ua, ⟨wf_ua, hγ_wf, hwf_s, hmu_wf, hBwf_ua⟩,
              ⟨wi_ua, hγ_wi, hwi_s, hmu_wi, hBwi_ua⟩⟩ := hUA
      -- Extract s_ua bound. All mu-points above γ are complement points.
      -- From the FO table, B and stavi_untl(A,B) hold at specific complement points.
      -- We need to provide (conj B (stavi_untl A B)) at complement points for .mpr
      -- Get a complement point as s_bound for .mpr
      obtain ⟨wf_pt, rfl⟩ := hmu_wf
      obtain ⟨wi_pt, rfl⟩ := hmu_wi
      have hwf_not : wf_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint wf_pt ≤ Sum.inr γ from h) hγ_wf
      have hwi_not : wi_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint wi_pt ≤ Sum.inr γ from h) hγ_wi
      -- Strategy: use stavi_untl_gap_detection.mpr.
      -- Pick s_bound as a complement point below BOTH wf_pt and wi_pt.
      -- This ensures:
      --   (a) B holds at complement points u < s_bound (from hBwi_ua, since u < wi_pt)
      --   (b) U'(A,B)(u) can be constructed with wf_pt as ¬B witness and wi_pt as B-initial,
      --       both in the interval (u, s_pt) where s_pt is a carrier bound above wf_pt and wi_pt.
      -- First, get a carrier bound s_pt from s_ua above both witnesses.
      have ⟨s_pt, hs_pt_wf, hs_pt_wi, hs_pt_s_ua⟩ :
          ∃ s_pt : M.carrier, wf_pt < s_pt ∧ wi_pt < s_pt ∧ extendPoint s_pt ≤ s_ua := by
        rcases s_ua with s₁ | g_ua
        · refine ⟨s₁, (extendPoint_lt_iff wf_pt s₁).mp hwf_s,
            (extendPoint_lt_iff wi_pt s₁).mp hwi_s, le_rfl⟩
        · have hwf_cut : wf_pt ∈ g_ua.val.cut :=
            (extendPoint_le_gap_iff wf_pt g_ua).mp (le_of_lt hwf_s)
          have hwi_cut : wi_pt ∈ g_ua.val.cut :=
            (extendPoint_le_gap_iff wi_pt g_ua).mp (le_of_lt hwi_s)
          have hmax_cut : max wf_pt wi_pt ∈ g_ua.val.cut := by
            rcases le_or_lt wf_pt wi_pt with h | h
            · simp [max_eq_right h]; exact hwi_cut
            · simp [max_eq_left (le_of_lt h)]; exact hwf_cut
          have ⟨y, hy_cut, hmax_y⟩ : ∃ y, y ∈ g_ua.val.cut ∧ max wf_pt wi_pt < y := by
            by_contra h_all; push_neg at h_all
            exact g_ua.val.no_sup ⟨max wf_pt wi_pt,
              ⟨h_all, fun b hb => hb hmax_cut⟩, hmax_cut⟩
          exact ⟨y, lt_of_le_of_lt (le_max_left _ _) hmax_y,
            lt_of_le_of_lt (le_max_right _ _) hmax_y,
            le_of_lt (lt_of_le_of_ne
              ((extendPoint_le_gap_iff y g_ua).mpr hy_cut) (fun h => by cases h))⟩
      -- Pick s_bound = min(wf_pt, wi_pt). Both ∉ γ.cut.
      let s_bound := min wf_pt wi_pt
      have hs_bound_not : s_bound ∉ γ.val.cut := by
        simp only [s_bound, min_def]; split
        · exact hwf_not
        · exact hwi_not
      -- Apply stavi_untl_gap_detection.mpr
      apply (stavi_untl_gap_detection (.conj B (.stavi_untl A B)) D hD m).mpr
      refine ⟨γ, s_bound, hγ_lt, hs_bound_not, hγ_def, hγ_bet, fun u hu_not hu_sb => ?_⟩
      -- u is a complement point with u < s_bound = min(wf_pt, wi_pt)
      -- So u < wf_pt AND u < wi_pt
      have hu_wf : u < wf_pt := lt_of_lt_of_le hu_sb (min_le_left wf_pt wi_pt)
      have hu_wi : u < wi_pt := lt_of_lt_of_le hu_sb (min_le_right wf_pt wi_pt)
      have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint u) := by
        show u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
      simp only [stavi_temporal_truth]
      constructor
      · -- B(u): from hBwi_ua, u is between γ and wi_pt
        exact (stavi_truth_mu_at_point u B).mp
          (hBwi_ua (extendPoint u) hγu ((extendPoint_lt_iff u wi_pt).mpr hu_wi) ⟨u, rfl⟩)
      · -- U'(A,B)(u): FO table at u with bound s_pt
        refine ⟨s_pt, lt_trans hu_wf hs_pt_wf, ?_, ?_, ?_⟩
        · -- Body: ∀ w ∈ (u, s_pt), disjunction
          intro w huw hws
          have hw_not : w ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed w u h (le_of_lt huw))
          have hγw : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint w) := by
            show w ∉ γ.val.cut ∧ ¬(w ∈ γ.val.cut); exact ⟨hw_not, hw_not⟩
          have hw_s_ua : extendPoint w < s_ua :=
            lt_of_lt_of_le ((extendPoint_lt_iff w s_pt).mpr hws) hs_pt_s_ua
          -- Apply mu-body at w
          have h_disj := h_body_ua (extendPoint w) hγw hw_s_ua ⟨w, rfl⟩
          cases h_disj with
          | inl h_cof =>
            -- Left: ∃ v mu-point > w, B^mu on (γ, v). Restrict to (u, v).
            left
            obtain ⟨v, hwv, hmu_v, hBv⟩ := h_cof
            obtain ⟨v_pt, rfl⟩ := hmu_v
            refine ⟨v_pt, (extendPoint_lt_iff w v_pt).mp hwv, fun z huz hzv => ?_⟩
            have hz_not : z ∉ γ.val.cut := by
              intro h; exact hu_not (γ.val.downward_closed z u h (le_of_lt huz))
            have hγz : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (Sum.inr γ) (extendPoint z) := by
              show z ∉ γ.val.cut ∧ ¬(z ∈ γ.val.cut); exact ⟨hz_not, hz_not⟩
            exact (stavi_truth_mu_at_point z B).mp
              (hBv (extendPoint z) hγz ((extendPoint_lt_iff z v_pt).mpr hzv) ⟨z, rfl⟩)
          | inr h_take =>
            -- Right: A^mu on (w, s_ua), ¬B^mu at v' ∈ (γ, w)
            obtain ⟨hA_above, v', hγv', hv'w, hmu_v', hBv'_neg⟩ := h_take
            obtain ⟨v'_pt, rfl⟩ := hmu_v'
            -- v'_pt is in (γ, w). Since u < wf_pt ≤ min(wf_pt, wi_pt) and u < wi_pt,
            -- if v'_pt ≤ u then v'_pt < wi_pt, so B(v'_pt) from hBwi_ua.
            -- But ¬B(v'_pt) contradicts. So v'_pt > u.
            have hv'u : u < v'_pt := by
              by_contra h_neg; push_neg at h_neg
              have hv'_wi : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                  (extendPoint v'_pt) (extendPoint wi_pt) :=
                (extendPoint_lt_iff v'_pt wi_pt).mpr (lt_of_le_of_lt h_neg hu_wi)
              exact hBv'_neg ((stavi_truth_mu_at_point v'_pt B).mpr
                ((stavi_truth_mu_at_point v'_pt B).mp
                  (hBwi_ua (extendPoint v'_pt) hγv' hv'_wi ⟨v'_pt, rfl⟩)))
            right
            refine ⟨fun v hwv hvs => ?_,
              v'_pt, hv'u, (extendPoint_lt_iff v'_pt w).mp hv'w,
              fun h => hBv'_neg ((stavi_truth_mu_at_point v'_pt B).mpr h)⟩
            have hv_not : v ∉ γ.val.cut := by
              intro h; exact hw_not (γ.val.downward_closed v w h (le_of_lt hwv))
            exact (stavi_truth_mu_at_point v A).mp
              (hA_above (extendPoint v) ((extendPoint_lt_iff w v).mpr hwv)
                (lt_of_lt_of_le ((extendPoint_lt_iff v s_pt).mpr hvs) hs_pt_s_ua)
                ⟨v, rfl⟩)
        · -- ¬B witness: wf_pt is in (u, s_pt) and ¬B(wf_pt)
          exact ⟨wf_pt, hu_wf, hs_pt_wf,
            fun h => hBwf_ua ((stavi_truth_mu_at_point wf_pt B).mpr h)⟩
        · -- B initial: wi_pt is in (u, s_pt) and B on (u, wi_pt)
          refine ⟨wi_pt, hu_wi, hs_pt_wi, fun v huv hvwi => ?_⟩
          have hv_not : v ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint v) := by
            show v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
          exact (stavi_truth_mu_at_point v B).mp
            (hBwi_ua (extendPoint v) hγv ((extendPoint_lt_iff v wi_pt).mpr hvwi) ⟨v, rfl⟩)
  | stavi_snce A B _ _ =>
    -- left_formula (.stavi_snce A B) D = .std_untl compound D
    -- compound = D ∧ B ∧ S'(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)
    -- Same compound decomposition as std_snce; S'(A,B) FO table differs from S(A,B)
    simp only [left_formula]
    rw [stavi_truth_mu_at_point m (.std_untl _ D)]
    simp only [stavi_temporal_truth]
    constructor
    · -- Forward: compound at s → gap with S'(A,B)^mu(γ)
      intro ⟨s, hms, ⟨hDs, hBs, hSnce_s, hU'_BD_s, hNotU'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_BD_s
      obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩ := h_init
      -- Gap construction (identical to std_snce: uses U'(⊤,B∧D) + ¬U'(D,B∧D))
      let bD : M.carrier → Prop := fun u =>
        stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D
      let cut : Set M.carrier :=
        {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → bD w}
      have hs_in_cut : s ∈ cut :=
        fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
      have hu_fail_not_cut : u_fail ∉ cut := by
        intro h; obtain ⟨v, hfv, hBDv⟩ := h u_fail hsu_fail le_rfl
        exact hBD_fail (hBDv u_fail hsu_fail hfv)
      have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
        intro x hx; by_contra h; push_neg at h
        exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
      have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
        fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
      have h_cofinal_propagate :
          ∀ u, s < u → u < s₁ →
          (∀ w, s < w → w < u → ∃ v, w < v ∧ ∀ z, s < z → z < v → bD z) →
          ∃ v, u < v ∧ ∀ z, s < z → z < v → bD z := by
        intro u hsu hus₁ h_below
        cases h_body u hsu hus₁ with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', hsv', hv'u, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := h_below v' hsv' hv'u
          exact absurd (hBDv₂ v' hsv' hv'v₂) hBDv'
      have hu_init_cut : u_init ∈ cut := by
        intro u hsu huu_init
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
          (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
            fun z hsz hz_init => hBD_init z hsz hz_init⟩)
      have h_bD_at_cut : ∀ u, s < u → u ∈ cut → bD u := by
        intro u hsu hu_cut
        obtain ⟨v, huv, hBDv⟩ := hu_cut u hsu le_rfl
        exact hBDv u hsu huv
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
        obtain ⟨v, hpv, hBDv⟩ := hp_cut p hsp le_rfl
        have hvs₁ : v < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
        exact not_le.mpr hpv (h_ub (show v ∈ cut from fun u hsu huv => by
          rcases eq_or_lt_of_le huv with rfl | huv'
          · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
              (fun w hsw hwu => ⟨u, hwu, hBDv⟩)
          · exact ⟨v, huv', hBDv⟩))
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not, hb_min⟩
        have hsb : s < b := by
          by_contra h; push_neg at h; exact hb_not (h_dc s b hs_in_cut h)
        have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hsb hbs₁ with
        | inl h_cof =>
          exact hb_not (fun u hsu hub => by
            rcases eq_or_lt_of_le hub with rfl | hub'
            · exact h_cof
            · exact (h_below_b u hub') u hsu le_rfl)
        | inr h =>
          obtain ⟨_, v', hsv', hv'b, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
          exact hBDv' (hBDv₂ v' hsv' hv'v₂)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
      have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
          ∀ u, t ≤ u → u ∈ γ_gap.cut → stavi_temporal_truth M atomMap u D :=
        ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
          (h_bD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
      have h_no_init_compl_bD : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → bD u := by
        intro ⟨t, ht_not, hBDt⟩
        have hst : s < t := by
          by_contra h; push_neg at h; exact ht_not (h_dc s t hs_in_cut h)
        have hts₁ : t < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
        suffices t ∈ cut from ht_not this
        intro u hsu hut
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
          (fun w hsw hwu =>
            h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
              (fun z hsz hzw => by
                cases h_body z hsz (lt_trans hzw (lt_trans hwu
                    (lt_of_le_of_lt hut hts₁))) with
                | inl h => exact h
                | inr h =>
                  obtain ⟨_, v', hsv', hv'z, hBDv'⟩ := h
                  have : bD v' := by
                    by_cases hv'_cut : v' ∈ cut
                    · exact h_bD_at_cut v' hsv' hv'_cut
                    · exact hBDt v' hv'_cut (le_trans (le_of_lt hv'z)
                        (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                  exact absurd this hBDv'))
      have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
          ¬stavi_temporal_truth M atomMap u_D D := by
        by_contra h_all_D; push_neg at h_all_D
        apply hNotU'D_BD_s
        exact ⟨s₁, hss₁,
          fun u hsu hus₁ => by
            cases h_body u hsu hus₁ with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁, h.2⟩,
          ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩,
          ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩⟩
      obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
      have hu_D_not_cut : u_D ∉ cut := by
        intro h; exact hD_fail_D (h_bD_at_cut u_D hsu_D h).2
      have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h; exact hx (h_dc y x hy h)
      have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → stavi_temporal_truth M atomMap u D := by
        intro ⟨t, ht_not, hDt⟩
        have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
        have ht_uD : t < u_D := by
          by_contra h; push_neg at h; exact hD_fail_D (hDt u_D hu_D_not_cut h)
        have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
        apply hNotU'D_BD_s
        refine ⟨t, hst, ?_, ?_, ?_⟩
        · intro u hsu hut
          cases h_body u hsu (lt_trans hut hts₁) with
          | inl h => left; exact h
          | inr h => right
                     exact ⟨fun v huv hvt => by
                       by_cases hv_cut : v ∈ cut
                       · exact (h_bD_at_cut v (lt_trans hsu huv) hv_cut).2
                       · exact hDt v hv_cut (le_of_lt hvt), h.2⟩
        · by_contra h_no_fail; push_neg at h_no_fail
          apply h_no_init_compl_bD
          obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
            by_contra h; push_neg at h
            exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
          exact ⟨c, hc_not, fun u hu huc =>
            h_no_fail u (h_compl_gt_cut u hu s hs_in_cut) (lt_of_le_of_lt huc hct)⟩
        · exact ⟨u_init, hsu_init, h_compl_gt_cut t ht_not u_init hu_init_cut, hBD_init⟩
      have h_def_left_D : gap_definable_on_left M atomMap γ_gap D :=
        ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, ⟨D, hD, Or.inl h_def_left_D⟩⟩
      refine ⟨γ, ?_, ?_, ?_, ?_⟩
      · have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
        exact ⟨hm_in, fun h => h hm_in⟩
      · exact h_def_left_D
      · intro u hmu hu_cut
        by_cases hsu : s < u
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_cut u hsu hu_cut).2
        · push_neg at hsu
          rcases eq_or_lt_of_le hsu with rfl | hus
          · exact (stavi_truth_mu_at_point u D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
      · -- S'(A,B)^mu(γ): from S'(A,B)(s) with B∧D at cut points above s
        obtain ⟨s₂, hs₂s, h_body_snce, ⟨uf_snce, hs₂_uf, huf_s, hBuf⟩,
                ⟨ui_snce, hs₂_ui, hui_s, hBui⟩⟩ := hSnce_s
        have hs₂_cut : s₂ ∈ cut := h_dc s s₂ hs_in_cut (le_of_lt hs₂s)
        have huf_cut : uf_snce ∈ cut := h_dc s uf_snce hs_in_cut (le_of_lt huf_s)
        have hui_cut : ui_snce ∈ cut := h_dc s ui_snce hs_in_cut (le_of_lt hui_s)
        simp only [stavi_temporal_truth_mu]
        refine ⟨extendPoint s₂, ⟨hs₂_cut, fun h => h hs₂_cut⟩, ?_, ?_, ?_⟩
        · -- Body: ∀ mu-point u ∈ (s₂, γ), body^mu(u)
          intro u hs₂u huγ hmu
          obtain ⟨u_pt, rfl⟩ := hmu
          have hu_cut : u_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff u_pt γ).mp (le_of_lt huγ)
          have hs₂_upt : s₂ < u_pt := (extendPoint_lt_iff s₂ u_pt).mp hs₂u
          by_cases hups : u_pt < s
          · -- u_pt < s: use original body from S'(A,B)(s)
            cases h_body_snce u_pt hs₂_upt hups with
            | inl h_cof =>
              left
              obtain ⟨v, hvu, hBv⟩ := h_cof
              have hv_cut : v ∈ cut := h_dc s v hs_in_cut (le_of_lt (lt_trans hvu hups))
              refine ⟨extendPoint v, (extendPoint_lt_iff v u_pt).mpr hvu,
                ⟨v, rfl⟩, fun w hvw hwγ hmu_w => ?_⟩
              obtain ⟨w_pt, rfl⟩ := hmu_w
              have hw_cut : w_pt ∈ γ.val.cut :=
                (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
              have hvw_pt : v < w_pt := (extendPoint_lt_iff v w_pt).mp hvw
              by_cases hwps : w_pt < s
              · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hvw_pt hwps)
              · push_neg at hwps
                rcases eq_or_lt_of_le hwps with rfl | hwps'
                · exact (stavi_truth_mu_at_point s B).mpr hBs
                · exact (stavi_truth_mu_at_point _ B).mpr (h_bD_at_cut _ hwps' hw_cut).1
            | inr h_right =>
              right
              obtain ⟨hA_above, v', hu_v', hv'_s, hBv'⟩ := h_right
              have hv'_cut : v' ∈ cut := h_dc s v' hs_in_cut (le_of_lt hv'_s)
              refine ⟨fun v hs₂v hvu hmu_v => ?_, ?_⟩
              · obtain ⟨v_pt, rfl⟩ := hmu_v
                exact (stavi_truth_mu_at_point v_pt A).mpr
                  (hA_above v_pt ((extendPoint_lt_iff s₂ v_pt).mp hs₂v)
                    ((extendPoint_lt_iff v_pt u_pt).mp hvu))
              · exact ⟨extendPoint v', (extendPoint_lt_iff u_pt v').mpr hu_v',
                  ⟨hv'_cut, fun h => h hv'_cut⟩, ⟨v', rfl⟩,
                  mt (stavi_truth_mu_at_point v' B).mp hBv'⟩
          · -- u_pt ≥ s: cut point above s, B cofinal from B∧D
            push_neg at hups
            left
            -- Use ui_snce (B-init witness) extended: B at all cut points above ui_snce
            -- since B on (ui_snce, s) from hBui + B at cut above s from h_bD_at_cut
            refine ⟨extendPoint ui_snce, (extendPoint_lt_iff ui_snce u_pt).mpr
              (lt_of_lt_of_le hui_s hups),
              ⟨ui_snce, rfl⟩, fun w huiw hwγ hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_cut : w_pt ∈ γ.val.cut :=
              (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
            have hui_wpt : ui_snce < w_pt := (extendPoint_lt_iff ui_snce w_pt).mp huiw
            by_cases hwps : w_pt < s
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBui w_pt hui_wpt hwps)
            · push_neg at hwps
              rcases eq_or_lt_of_le hwps with rfl | hsw'
              · exact (stavi_truth_mu_at_point s B).mpr hBs
              · exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_cut w_pt hsw' hw_cut).1
        · -- Fail: ∃ mu-point in (s₂, γ) with ¬B^mu
          exact ⟨extendPoint uf_snce, (extendPoint_lt_iff s₂ uf_snce).mpr hs₂_uf,
            ⟨huf_cut, fun h => h huf_cut⟩, ⟨uf_snce, rfl⟩,
            mt (stavi_truth_mu_at_point uf_snce B).mp hBuf⟩
        · -- Init: ∃ mu-point in (s₂, γ) with B^mu on (init, γ)
          refine ⟨extendPoint ui_snce, (extendPoint_lt_iff s₂ ui_snce).mpr hs₂_ui,
            ⟨hui_cut, fun h => h hui_cut⟩, ⟨ui_snce, rfl⟩,
            fun v huiv hvγ hmu_v => ?_⟩
          obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_cut : v_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff v_pt γ).mp (le_of_lt hvγ)
          have hui_vpt : ui_snce < v_pt := (extendPoint_lt_iff ui_snce v_pt).mp huiv
          by_cases hvps : v_pt < s
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBui v_pt hui_vpt hvps)
          · push_neg at hvps
            rcases eq_or_lt_of_le hvps with rfl | hvs
            · exact (stavi_truth_mu_at_point s B).mpr hBs
            · exact (stavi_truth_mu_at_point _ B).mpr (h_bD_at_cut _ hvs hv_cut).1
    · -- Backward: gap with S'(A,B)^mu(γ) → compound at m
      -- Same compound structure as std_snce backward but S'(A,B) FO table
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
      -- Expand S'(A,B)^mu(γ): FO table with bound, body, fail, init for B
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth] at hSnce_mu
      obtain ⟨s_bound_ext, hs_bound_γ, h_body_AB, ⟨uf_ext, hs_uf, huf_γ, hmu_uf, hBuf⟩,
              ⟨ui_ext, hs_ui, hui_γ, hmu_ui, hBui⟩⟩ := hSnce_mu
      obtain ⟨uf_pt, rfl⟩ := hmu_uf
      obtain ⟨ui_pt, rfl⟩ := hmu_ui
      have huf_cut : uf_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff uf_pt γ).mp (le_of_lt huf_γ)
      have hui_cut : ui_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff ui_pt γ).mp (le_of_lt hui_γ)
      have hm_cut : m ∈ γ.val.cut :=
        (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
      -- Find cut point s above m, uf_pt, ui_pt
      have ⟨s, hs_cut, hms, hufs, huis⟩ :
          ∃ s, s ∈ γ.val.cut ∧ m < s ∧ uf_pt < s ∧ ui_pt < s := by
        have hmax3_cut : max m (max uf_pt ui_pt) ∈ γ.val.cut := by
          rcases le_or_lt m (max uf_pt ui_pt) with h | h
          · simp [max_eq_right h]
            rcases le_or_lt uf_pt ui_pt with h' | h'
            · simp [max_eq_right h']; exact hui_cut
            · simp [max_eq_left (le_of_lt h')]; exact huf_cut
          · simp [max_eq_left (le_of_lt h)]; exact hm_cut
        have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max m (max uf_pt ui_pt) < s₂ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨_, ⟨h, fun _ hb => hb hmax3_cut⟩, hmax3_cut⟩
        exact ⟨s₂, hs₂,
          lt_of_le_of_lt (le_max_left _ _) hmax_s₂,
          lt_of_le_of_lt (le_trans (le_max_left _ _) (le_max_right _ _)) hmax_s₂,
          lt_of_le_of_lt (le_trans (le_max_right _ _) (le_max_right _ _)) hmax_s₂⟩
      have hDs : stavi_temporal_truth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
      have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint s) (Sum.inr γ) := ⟨hs_cut, fun h => h hs_cut⟩
      have hBs : stavi_temporal_truth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hBui (extendPoint s) ((extendPoint_lt_iff ui_pt s).mpr huis) hγs' ⟨s, rfl⟩)
      have hD_bet_ms : ∀ u, m < u → u < s → stavi_temporal_truth M atomMap u D := by
        intro u hmu hus
        exact (stavi_truth_mu_at_point u D).mp
          (hγ_bet u hmu (γ.val.downward_closed s u hs_cut (le_of_lt hus)))
      -- S'(A,B)(s): construct via mu-form restriction from (s_bound, γ) to (s_bound, s)
      have hSnce_s : stavi_temporal_truth M atomMap s (.stavi_snce A B) := by
        rw [← stavi_truth_mu_at_point s (.stavi_snce A B)]
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
        refine ⟨s_bound_ext, lt_trans hs_uf ((extendPoint_lt_iff uf_pt s).mpr hufs), ?_, ?_, ?_⟩
        · -- body: restrict from (s_bound, γ) to (s_bound, extendPoint s)
          intro u hsu hus hmu
          cases h_body_AB u hsu (lt_trans hus hγs') hmu with
          | inl h_left =>
            left; obtain ⟨v, hvu, hmu_v, hBv⟩ := h_left
            exact ⟨v, hvu, hmu_v, fun w hvw hws hmu_w =>
              hBv w hvw (lt_trans hws hγs') hmu_w⟩
          | inr h_right =>
            right; obtain ⟨hA, v', huv', hv'γ, hmu_v', hBv'⟩ := h_right
            have hv'_s : v' < extendPoint s := by
              by_contra h; push_neg at h
              exact hBv' (hBui v'
                (lt_of_lt_of_le ((extendPoint_lt_iff ui_pt s).mpr huis) h)
                hv'γ hmu_v')
            exact ⟨hA, v', huv', hv'_s, hmu_v', hBv'⟩
        · -- fail: uf_pt with ¬B
          exact ⟨extendPoint uf_pt, hs_uf,
            (extendPoint_lt_iff uf_pt s).mpr hufs, ⟨uf_pt, rfl⟩, hBuf⟩
        · -- init: ui_pt with B on (ui_pt, s), restricted from (ui_pt, γ)
          exact ⟨extendPoint ui_pt, hs_ui,
            (extendPoint_lt_iff ui_pt s).mpr huis, ⟨ui_pt, rfl⟩,
            fun v huiv hvs hmu_v =>
              hBui v huiv (lt_trans hvs hγs') hmu_v⟩
      -- Extract gap definability conditions (same as std_snce backward)
      obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
      have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hx (γ.val.downward_closed y x hy h)
      have h_neg_init : ∀ t, t ∉ γ.val.cut →
          ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
        intro t ht; by_contra h_all; push_neg at h_all
        exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
      have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
        by_contra h; push_neg at h
        exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
      have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
      have h_bD_cut : ∀ u, s < u → u ∈ γ.val.cut →
          stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D := by
        intro u hsu hu_cut
        exact ⟨(stavi_truth_mu_at_point u B).mp
          (hBui (extendPoint u)
            ((extendPoint_lt_iff ui_pt u).mpr (lt_trans huis hsu))
            ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
          (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
      -- Provide the S'(A,B)(s) part of the goal
      have hSnce_s_expanded : ∃ s_1 < s,
          (∀ u, s_1 < u → u < s →
            (∃ v < u, ∀ w, v < w → w < s → stavi_temporal_truth M atomMap w B) ∨
            (∀ v, s_1 < v → v < u → stavi_temporal_truth M atomMap v A) ∧
              ∃ v', u < v' ∧ v' < s ∧ ¬stavi_temporal_truth M atomMap v' B) ∧
          (∃ u, s_1 < u ∧ u < s ∧ ¬stavi_temporal_truth M atomMap u B) ∧
          ∃ u, s_1 < u ∧ u < s ∧
            ∀ v, u < v → v < s → stavi_temporal_truth M atomMap v B := by
        simp only [stavi_temporal_truth] at hSnce_s
        exact hSnce_s
      refine ⟨s, hms, ⟨hDs, hBs, hSnce_s_expanded, ?_, ?_⟩, hD_bet_ms⟩
      · -- U'(⊤, B∧D)(s): same as std_snce backward
        refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
        · intro u hsu huc₀
          by_cases hu_cut : u ∈ γ.val.cut
          · left
            have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
            exact ⟨y, huy, fun w hsw hwy =>
              h_bD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
          · right
            refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
          exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
            h_bD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
      · -- ¬U'(D, B∧D)(s): same two-step D-transfer as std_snce backward
        intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hsu_fail, huf_s₁, hBD_fail⟩ := h_fail
        have huf_not_cut : u_fail ∉ γ.val.cut := by
          intro h; exact hBD_fail (h_bD_cut u_fail hsu_fail h)
        have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
              stavi_temporal_truth M atomMap w B ∧ stavi_temporal_truth M atomMap w D) := by
          intro u hsu _ hu_not ⟨v, huv, hBDv⟩
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact hDw (hBDv w (h_compl_gt w hw_not s hs_cut)
            (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
        have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hsu hus₁ hu_not
          have h_right_u := (h_body u hsu hus₁).resolve_left
            (h_left_fails u hsu hus₁ hu_not)
          obtain ⟨_, v', hsv', hv'u, hBD_v'⟩ := h_right_u
          have hv'_not : v' ∉ γ.val.cut := by
            intro h; exact hBD_v' (h_bD_cut v' hsv' h)
          have h_right_v' := (h_body v' hsv' (lt_trans hv'u hus₁)).resolve_left
            (h_left_fails v' hsv' (lt_trans hv'u hus₁) hv'_not)
          exact h_right_v'.1 u hv'u hus₁
        have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
        exact h_no_init_D
          ⟨t, ht_not, fun u hu_not hut =>
            hD_all_compl u (h_compl_gt u hu_not s hs_cut)
              (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩
  | std_untl A B _ _ =>
    -- left_formula (.std_untl A B) D = .stavi_untl (.conj B (.std_untl A B)) D
    -- Same pattern as stavi_untl: U'(B ∧ U(A,B), D)(m) ↔ ∃ γ, ... ∧ U(A,B)^mu(γ)
    simp only [left_formula]
    constructor
    · -- Forward: from U'(B ∧ U(A,B), D)(m), get complement point truth, derive U(A,B)^mu(γ)
      intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩ :=
        (stavi_untl_gap_detection (.conj B (.std_untl A B)) D hD m).mp h
      -- hX_compl gives conj B (std_untl A B) at complement points
      -- Extract std_untl(A,B) at complement points and construct std_untl(A,B)^mu(γ)
      have hUA_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u (.std_untl A B) :=
        fun u hu hus => (hX_compl u hu hus).2
      -- std_untl(A,B)^mu(γ): ∃ mu-point s > γ, A^mu(s) ∧ ∀ mu-point u ∈ (γ,s), B^mu(u)
      -- Pick complement point u₁ < s_bound. std_untl(A,B)(u₁) gives ∃ s > u₁, A(s) ∧ B on (u₁, s).
      -- B at complement points below u₁ from hX_compl.
      have ⟨u₁, hu₁_not, hu₁s⟩ : ∃ u₁, u₁ ∉ γ.val.cut ∧ u₁ < s_bound := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
      have hB_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u B :=
        fun u hu hus => (hX_compl u hu hus).1
      have hUA_u₁ := hUA_compl u₁ hu₁_not hu₁s
      -- std_untl(A,B)(u₁): ∃ s₁ > u₁, A(s₁) ∧ B on (u₁, s₁)
      simp only [stavi_temporal_truth] at hUA_u₁
      obtain ⟨s₁, hu₁s₁, hAs₁, hB_between⟩ := hUA_u₁
      -- Construct std_untl(A,B)^mu(γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [stavi_temporal_truth_mu]
      -- Need: ∃ s > γ, mu_holds s ∧ A^mu(s) ∧ ∀ mu-pt u ∈ (γ,s), B^mu(u)
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed s₁ u₁ h (le_of_lt hu₁s₁))
      refine ⟨extendPoint s₁, ⟨hs₁_not, hs₁_not⟩, ⟨s₁, rfl⟩,
        (stavi_truth_mu_at_point s₁ A).mpr hAs₁, fun u hγu hus hmu => ?_⟩
      obtain ⟨u_pt, rfl⟩ := hmu
      have hu_pt_not : u_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
      have hu_pt_s₁ : u_pt < s₁ := (extendPoint_lt_iff u_pt s₁).mp hus
      by_cases hu_u₁ : u₁ < u_pt
      · exact (stavi_truth_mu_at_point u_pt B).mpr (hB_between u_pt hu_u₁ hu_pt_s₁)
      · push_neg at hu_u₁
        exact (stavi_truth_mu_at_point u_pt B).mpr
          (hB_compl u_pt hu_pt_not (lt_of_le_of_lt hu_u₁ hu₁s))
    · -- Backward: from gap with U(A,B)^mu(γ), construct U'(B ∧ U(A,B), D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      -- U(A,B)^mu(γ) = ∃ s > γ, mu_holds s ∧ A^mu(s) ∧ ∀ mu-pt u ∈ (γ,s), B^mu(u)
      simp only [stavi_temporal_truth_mu] at hUA
      obtain ⟨s_ua, hγ_s_ua, hmu_s, hA_s, hB_mu⟩ := hUA
      obtain ⟨s₁, rfl⟩ := hmu_s
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint s₁ ≤ Sum.inr γ from h) hγ_s_ua
      -- Apply stavi_untl_gap_detection.mpr with s_bound = s₁
      -- Need: (B ∧ U(A,B)) at complement points u with u ∉ γ.cut and u < s₁
      apply (stavi_untl_gap_detection (.conj B (.std_untl A B)) D hD m).mpr
      refine ⟨γ, s₁, hγ_lt, hs₁_not, hγ_def, hγ_bet, fun u hu_not hu_s₁ => ?_⟩
      -- u is a complement point above γ with u < s₁
      -- Show B(u) ∧ U(A,B)(u)
      have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint u) := by
        show u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
      simp only [stavi_temporal_truth]
      constructor
      · -- B(u): from hB_mu, since γ < extendPoint u < extendPoint s₁
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hγu ((extendPoint_lt_iff u s₁).mpr hu_s₁) ⟨u, rfl⟩)
      · -- U(A,B)(u): ∃ s' > u, A(s') ∧ B on (u, s'). Pick s' = s₁.
        refine ⟨s₁, hu_s₁, (stavi_truth_mu_at_point s₁ A).mp hA_s, fun v huv hvs₁ => ?_⟩
        -- v is between u and s₁, both complement points, so v ∉ γ.cut
        have hv_not : v ∉ γ.val.cut := by
          intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
        have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (Sum.inr γ) (extendPoint v) := by
          show v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
        exact (stavi_truth_mu_at_point v B).mp
          (hB_mu (extendPoint v) hγv ((extendPoint_lt_iff v s₁).mpr hvs₁) ⟨v, rfl⟩)
  | std_snce A B _ _ =>
    -- left_formula (.std_snce A B) D = .std_untl compound D
    -- compound = D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)
    -- Same compound decomposition as base.snce; S(A,B)^mu has simple structure
    simp only [left_formula]
    rw [stavi_truth_mu_at_point m (.std_untl _ D)]
    simp only [stavi_temporal_truth]
    constructor
    · -- Forward: compound at s → gap with S(A,B)^mu(γ)
      -- Identical compound decomposition as base.snce, only temporal part differs
      intro ⟨s, hms, ⟨hDs, hBs, ⟨q, hqs, hAq, hBqs⟩, hU'_BD_s, hNotU'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_BD_s
      obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩ := h_init
      let bD : M.carrier → Prop := fun u =>
        stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D
      let cut : Set M.carrier :=
        {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → bD w}
      have hs_in_cut : s ∈ cut :=
        fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
      have hu_fail_not_cut : u_fail ∉ cut := by
        intro h; obtain ⟨v, hfv, hBDv⟩ := h u_fail hsu_fail le_rfl
        exact hBD_fail (hBDv u_fail hsu_fail hfv)
      have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
        intro x hx; by_contra h; push_neg at h
        exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
      have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
        fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
      have h_cofinal_propagate :
          ∀ u, s < u → u < s₁ →
          (∀ w, s < w → w < u → ∃ v, w < v ∧ ∀ z, s < z → z < v → bD z) →
          ∃ v, u < v ∧ ∀ z, s < z → z < v → bD z := by
        intro u hsu hus₁ h_below
        cases h_body u hsu hus₁ with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', hsv', hv'u, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := h_below v' hsv' hv'u
          exact absurd (hBDv₂ v' hsv' hv'v₂) hBDv'
      have hu_init_cut : u_init ∈ cut := by
        intro u hsu huu_init
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
          (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
            fun z hsz hz_init => hBD_init z hsz hz_init⟩)
      have h_bD_at_cut : ∀ u, s < u → u ∈ cut → bD u := by
        intro u hsu hu_cut
        obtain ⟨v, huv, hBDv⟩ := hu_cut u hsu le_rfl
        exact hBDv u hsu huv
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
        obtain ⟨v, hpv, hBDv⟩ := hp_cut p hsp le_rfl
        have hvs₁ : v < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
        exact not_le.mpr hpv (h_ub (show v ∈ cut from fun u hsu huv => by
          rcases eq_or_lt_of_le huv with rfl | huv'
          · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
              (fun w hsw hwu => ⟨u, hwu, hBDv⟩)
          · exact ⟨v, huv', hBDv⟩))
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not, hb_min⟩
        have hsb : s < b := by
          by_contra h; push_neg at h; exact hb_not (h_dc s b hs_in_cut h)
        have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hsb hbs₁ with
        | inl h_cof =>
          exact hb_not (fun u hsu hub => by
            rcases eq_or_lt_of_le hub with rfl | hub'
            · exact h_cof
            · exact (h_below_b u hub') u hsu le_rfl)
        | inr h =>
          obtain ⟨_, v', hsv', hv'b, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
          exact hBDv' (hBDv₂ v' hsv' hv'v₂)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
      have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
          ∀ u, t ≤ u → u ∈ γ_gap.cut → stavi_temporal_truth M atomMap u D :=
        ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
          (h_bD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
      have h_no_init_compl_bD : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → bD u := by
        intro ⟨t, ht_not, hBDt⟩
        have hst : s < t := by
          by_contra h; push_neg at h; exact ht_not (h_dc s t hs_in_cut h)
        have hts₁ : t < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
        suffices t ∈ cut from ht_not this
        intro u hsu hut
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
          (fun w hsw hwu =>
            h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
              (fun z hsz hzw => by
                cases h_body z hsz (lt_trans hzw (lt_trans hwu
                    (lt_of_le_of_lt hut hts₁))) with
                | inl h => exact h
                | inr h =>
                  obtain ⟨_, v', hsv', hv'z, hBDv'⟩ := h
                  have : bD v' := by
                    by_cases hv'_cut : v' ∈ cut
                    · exact h_bD_at_cut v' hsv' hv'_cut
                    · exact hBDt v' hv'_cut (le_trans (le_of_lt hv'z)
                        (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                  exact absurd this hBDv'))
      have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
          ¬stavi_temporal_truth M atomMap u_D D := by
        by_contra h_all_D; push_neg at h_all_D
        apply hNotU'D_BD_s
        exact ⟨s₁, hss₁,
          fun u hsu hus₁ => by
            cases h_body u hsu hus₁ with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁, h.2⟩,
          ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩,
          ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩⟩
      obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
      have hu_D_not_cut : u_D ∉ cut := by
        intro h; exact hD_fail_D (h_bD_at_cut u_D hsu_D h).2
      have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h; exact hx (h_dc y x hy h)
      have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → stavi_temporal_truth M atomMap u D := by
        intro ⟨t, ht_not, hDt⟩
        have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
        have ht_uD : t < u_D := by
          by_contra h; push_neg at h; exact hD_fail_D (hDt u_D hu_D_not_cut h)
        have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
        apply hNotU'D_BD_s
        refine ⟨t, hst, ?_, ?_, ?_⟩
        · intro u hsu hut
          cases h_body u hsu (lt_trans hut hts₁) with
          | inl h => left; exact h
          | inr h => right
                     exact ⟨fun v huv hvt => by
                       by_cases hv_cut : v ∈ cut
                       · exact (h_bD_at_cut v (lt_trans hsu huv) hv_cut).2
                       · exact hDt v hv_cut (le_of_lt hvt), h.2⟩
        · by_contra h_no_fail; push_neg at h_no_fail
          apply h_no_init_compl_bD
          obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
            by_contra h; push_neg at h
            exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
          exact ⟨c, hc_not, fun u hu huc =>
            h_no_fail u (h_compl_gt_cut u hu s hs_in_cut) (lt_of_le_of_lt huc hct)⟩
        · exact ⟨u_init, hsu_init, h_compl_gt_cut t ht_not u_init hu_init_cut, hBD_init⟩
      have h_def_left_D : gap_definable_on_left M atomMap γ_gap D :=
        ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, ⟨D, hD, Or.inl h_def_left_D⟩⟩
      refine ⟨γ, ?_, ?_, ?_, ?_⟩
      · have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
        exact ⟨hm_in, fun h => h hm_in⟩
      · exact h_def_left_D
      · intro u hmu hu_cut
        by_cases hsu : s < u
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_cut u hsu hu_cut).2
        · push_neg at hsu
          rcases eq_or_lt_of_le hsu with rfl | hus
          · exact (stavi_truth_mu_at_point u D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
      · -- S(A,B)^mu(γ): from S(A,B)(s), same construction as base.snce
        have hq_cut : q ∈ cut := h_dc s q hs_in_cut (le_of_lt hqs)
        exact ⟨extendPoint q, ⟨hq_cut, fun h => h hq_cut⟩, ⟨q, rfl⟩,
          (stavi_truth_mu_at_point q A).mpr hAq,
          fun u hqu huγ hmu => by
            obtain ⟨p, rfl⟩ := hmu
            have hp_cut : p ∈ cut := huγ.1
            have hqp : q < p := (extendPoint_lt_iff q p).mp hqu
            by_cases hps : p ≤ s
            · rcases eq_or_lt_of_le hps with rfl | hps'
              · exact (stavi_truth_mu_at_point p B).mpr hBs
              · exact (stavi_truth_mu_at_point p B).mpr (hBqs p hqp hps')
            · push_neg at hps
              exact (stavi_truth_mu_at_point p B).mpr (h_bD_at_cut p hps hp_cut).1⟩
    · -- Backward: gap with S(A,B)^mu(γ) → compound at m
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
      obtain ⟨t_ext, ht_γ, ⟨t_pt, rfl⟩, hA_t, hB_mu⟩ := hSnce_mu
      have ht_cut : t_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff t_pt γ).mp (le_of_lt ht_γ)
      have hm_cut : m ∈ γ.val.cut :=
        (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
      have ⟨s, hs_cut, hms, hts⟩ : ∃ s, s ∈ γ.val.cut ∧ m < s ∧ t_pt < s := by
        have ⟨s₁, hs₁, hms₁⟩ : ∃ s₁ ∈ γ.val.cut, m < s₁ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨m, ⟨h, fun _ hb => hb hm_cut⟩, hm_cut⟩
        have hmax_cut : max s₁ t_pt ∈ γ.val.cut := by
          rcases le_or_lt s₁ t_pt with h | h
          · simp [max_eq_right h]; exact ht_cut
          · simp [max_eq_left (le_of_lt h)]; exact hs₁
        have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max s₁ t_pt < s₂ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨max s₁ t_pt, ⟨h, fun _ hb => hb hmax_cut⟩, hmax_cut⟩
        exact ⟨s₂, hs₂,
          lt_trans hms₁ (lt_of_le_of_lt (le_max_left s₁ t_pt) hmax_s₂),
          lt_of_le_of_lt (le_max_right s₁ t_pt) hmax_s₂⟩
      have hDs : stavi_temporal_truth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
      have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint t_pt) (extendPoint s) :=
        (extendPoint_lt_iff t_pt s).mpr hts
      have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint s) (Sum.inr γ) := ⟨hs_cut, fun h => h hs_cut⟩
      have hBs : stavi_temporal_truth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hB_mu (extendPoint s) hγs hγs' ⟨s, rfl⟩)
      have hSnce_s : ∃ s_1 < s, stavi_temporal_truth M atomMap s_1 A ∧
          ∀ u, s_1 < u → u < s → stavi_temporal_truth M atomMap u B := by
        refine ⟨t_pt, hts, (stavi_truth_mu_at_point t_pt A).mp hA_t, fun u htu hus => ?_⟩
        have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
        have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t_pt) (extendPoint u) :=
          (extendPoint_lt_iff t_pt u).mpr htu
        have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint u) (Sum.inr γ) := ⟨hu_cut, fun h => h hu_cut⟩
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hγu huγ ⟨u, rfl⟩)
      have hD_bet_ms : ∀ u, m < u → u < s → stavi_temporal_truth M atomMap u D := by
        intro u hmu hus
        exact (stavi_truth_mu_at_point u D).mp
          (hγ_bet u hmu (γ.val.downward_closed s u hs_cut (le_of_lt hus)))
      obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
      have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hx (γ.val.downward_closed y x hy h)
      have h_neg_init : ∀ t, t ∉ γ.val.cut →
          ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
        intro t ht; by_contra h_all; push_neg at h_all
        exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
      have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
        by_contra h; push_neg at h
        exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
      have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
      have h_bD_cut : ∀ u, s < u → u ∈ γ.val.cut →
          stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D := by
        intro u hsu hu_cut
        exact ⟨(stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u)
            ((extendPoint_lt_iff t_pt u).mpr (lt_trans hts hsu))
            ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
          (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
      refine ⟨s, hms, ⟨hDs, hBs, hSnce_s, ?_, ?_⟩, hD_bet_ms⟩
      · -- U'(⊤, B∧D)(s): same as base.snce backward
        refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
        · intro u hsu huc₀
          by_cases hu_cut : u ∈ γ.val.cut
          · left
            have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
            exact ⟨y, huy, fun w hsw hwy =>
              h_bD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
          · right
            refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
          exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
            h_bD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
      · -- ¬U'(D, B∧D)(s): same two-step D-transfer as base.snce
        intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hsu_fail, huf_s₁, hBD_fail⟩ := h_fail
        have huf_not_cut : u_fail ∉ γ.val.cut := by
          intro h; exact hBD_fail (h_bD_cut u_fail hsu_fail h)
        have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
              stavi_temporal_truth M atomMap w B ∧ stavi_temporal_truth M atomMap w D) := by
          intro u hsu _ hu_not ⟨v, huv, hBDv⟩
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact hDw (hBDv w (h_compl_gt w hw_not s hs_cut)
            (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
        have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hsu hus₁ hu_not
          have h_right_u := (h_body u hsu hus₁).resolve_left
            (h_left_fails u hsu hus₁ hu_not)
          obtain ⟨_, v', hsv', hv'u, hBD_v'⟩ := h_right_u
          have hv'_not : v' ∉ γ.val.cut := by
            intro h; exact hBD_v' (h_bD_cut v' hsv' h)
          have h_right_v' := (h_body v' hsv' (lt_trans hv'u hus₁)).resolve_left
            (h_left_fails v' hsv' (lt_trans hv'u hus₁) hv'_not)
          exact h_right_v'.1 u hv'u hus₁
        have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
        exact h_no_init_D ⟨t, ht_not, fun u hu_not hut =>
          hD_all_compl u (h_compl_gt u hu_not s hs_cut)
            (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩

/-! ### GHR93 Lemma 9 (Gap detection correctness, right direction)

right_formula(A, D) evaluated at an actual point m in M_r detects
whether A^mu holds at a gap gamma that is D-defined on the right,
with gamma < m and D holding at all actual points between gamma and m.
-/

/-- Core helper for right: S'(X, D) at an actual point m detects a D-defined
    gap γ < m where X holds at cut points above some bound, with D holding at
    complement points between γ and m. Dual of stavi_untl_gap_detection.

    RHS uses "X at cut points above s_bound" rather than X^mu at the gap,
    matching the stavi_untl_gap_detection pattern. -/
theorem stavi_snce_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (X D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (.stavi_snce X D) ↔
    (∃ (γ : RDefinableGap M atomMap r) (s_bound : M.carrier),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m > Sum.inr γ ∧
      s_bound ∈ γ.val.cut ∧
      gap_definable_on_right M atomMap γ.val D ∧
      (∀ u : M.carrier, u < m → u ∉ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      (∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
        stavi_temporal_truth M atomMap u X)) := by
  -- Dual of stavi_untl_gap_detection: reverse direction, complement ↔ cut roles swapped
  rw [stavi_truth_mu_at_point m (.stavi_snce X D)]
  simp only [stavi_temporal_truth]
  -- LHS: ∃ s < m, body(1) ∧ (2) D fails somewhere ∧ (3) D holds on final segment
  constructor
  · -- **Forward direction** (FO table → gap):
    intro ⟨s, hsm, h_body, ⟨u_fail, hsu_fail, hum_fail, hD_fail⟩,
           ⟨u_init, hsu_init, hum_init, hD_init⟩⟩
    -- Dual cut: complement (= points where D is cofinal toward m from below)
    let compl : Set M.carrier :=
      {x | ∀ u, x ≤ u → u < m →
        ∃ v, v < u ∧ ∀ w, v < w → w < m → stavi_temporal_truth M atomMap w D}
    have hm_in_compl : m ∈ compl :=
      fun u hmu hum => absurd (lt_of_lt_of_le hum hmu) (lt_irrefl u)
    have hu_fail_not_compl : u_fail ∉ compl := by
      intro h; obtain ⟨v, hvu, hDv⟩ := h u_fail le_rfl hum_fail
      exact hD_fail (hDv u_fail hvu hum_fail)
    let cut : Set M.carrier := {x | x ∉ compl}
    -- Classical conversion: x ∉ cut ↔ x ∈ compl
    have h_not_cut_compl : ∀ x, x ∉ cut → x ∈ compl := fun x h => by
      by_contra hx; exact h hx
    have h_compl_not_cut : ∀ x, x ∈ compl → x ∉ cut := fun x hx h => h hx
    have huf_in_cut : u_fail ∈ cut := hu_fail_not_compl
    have hm_not_cut : m ∉ cut := h_compl_not_cut m hm_in_compl
    -- compl is upward-closed; cut is downward-closed
    have h_compl_up : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
      fun x y hx hxy u hyu hum => hx u (le_trans hxy hyu) hum
    have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
      fun x y hx hyx hy => hx (h_compl_up y x hy hyx)
    -- All cut points < all compl points
    have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
      intro x hx y hy; by_contra h; push_neg at h
      exact hx (h_compl_up y x hy h)
    have h_proper : cut ≠ Set.univ := by
      intro h; exact hm_not_cut (h ▸ Set.mem_univ m)
    -- Cofinal propagation (dual): body condition left ⟹ compl membership
    have h_cofinal_propagate :
        ∀ u, s < u → u < m →
        (∀ w, u < w → w < m →
          ∃ v, v < w ∧ ∀ z, v < z → z < m → stavi_temporal_truth M atomMap z D) →
        ∃ v, v < u ∧ ∀ z, v < z → z < m → stavi_temporal_truth M atomMap z D := by
      intro u hsu hum h_above
      cases h_body u hsu hum with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', huv', hv'm, hDv'⟩ := h
        obtain ⟨v₂, hv₂v', hDv₂⟩ := h_above v' huv' hv'm
        exact absurd (hDv₂ v' hv₂v' hv'm) hDv'
    -- u_init ∈ compl: D on (u_init, m) and body LEFT at u_init
    have h_cofinal_u_init :
        ∃ v, v < u_init ∧ ∀ w, v < w → w < m → stavi_temporal_truth M atomMap w D := by
      cases h_body u_init hsu_init hum_init with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', huv', hv'm, hDv'⟩ := h
        exact absurd (hD_init v' huv' hv'm) hDv'
    have hu_init_compl : u_init ∈ compl := by
      intro u huu_init hum
      rcases eq_or_lt_of_le huu_init with rfl | hlt
      · exact h_cofinal_u_init
      · exact ⟨u_init, hlt, fun w hw hwm => hD_init w hw hwm⟩
    -- D at compl points
    have h_D_at_compl : ∀ u, u ∈ compl → u < m →
        stavi_temporal_truth M atomMap u D := by
      intro u hu hum; obtain ⟨v, hvu, hDv⟩ := hu u le_rfl hum
      exact hDv u hvu hum
    -- No sup in cut
    have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
      intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
      have hpm : p < m := h_cut_lt_compl p hp_cut m hm_in_compl
      have hps : s < p := by
        by_contra h; push_neg at h
        exact not_le.mpr (lt_of_le_of_lt h hsu_fail) (h_ub huf_in_cut)
      apply hp_cut
      intro u hpu hum
      rcases eq_or_lt_of_le hpu with rfl | hpu'
      · exact h_cofinal_propagate p hps hum (fun w hpw hwm => by
          have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
          exact this w le_rfl hwm)
      · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
        exact this u le_rfl hum
    -- Complement has no minimum
    have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
      intro ⟨b, hb_compl, hb_min⟩
      have hbm : b < m := by
        rcases eq_or_lt_of_le (hb_min m (fun h => h hm_in_compl)) with rfl | h
        · exact absurd (hb_min u_init (fun h => h hu_init_compl)) (not_le.mpr hum_init)
        · exact h
      have hb_in_compl : b ∈ compl := h_not_cut_compl b hb_compl
      have hsb : s < b := by
        by_contra h; push_neg at h
        have hs_compl := h_compl_up b s hb_in_compl h
        obtain ⟨v, hvu, hDv⟩ := hs_compl u_fail (le_of_lt hsu_fail) hum_fail
        exact hD_fail (hDv u_fail hvu hum_fail)
      cases h_body b hsb hbm with
      | inl h_cof =>
        obtain ⟨v, hvb, hDv⟩ := h_cof
        by_cases hvs : s < v
        · have hvm : v < m := lt_trans hvb hbm
          cases h_body v hvs hvm with
          | inl h2 =>
            obtain ⟨v₂, hv₂v, hDv₂⟩ := h2
            have hv_compl : v ∈ compl := by
              intro u hvu hum
              rcases eq_or_lt_of_le hvu with rfl | hvu'
              · exact ⟨v₂, hv₂v, hDv₂⟩
              · exact ⟨v, hvu', hDv⟩
            exact absurd (hb_min v (h_compl_not_cut v hv_compl)) (not_le.mpr hvb)
          | inr h2 =>
            obtain ⟨_, v', hvv', hv'm, hDv'⟩ := h2
            exact absurd (hDv v' hvv' hv'm) hDv'
        · push_neg at hvs
          exact absurd (hDv u_fail (lt_of_le_of_lt hvs hsu_fail) hum_fail) hD_fail
      | inr h_right =>
        obtain ⟨_, v', hbv', hv'm, hDv'⟩ := h_right
        have hv'_not_compl : v' ∉ compl := by
          intro hv'; exact hDv' (h_D_at_compl v' hv' hv'm)
        exact not_lt.mpr (le_of_lt hbv') (h_cut_lt_compl v' hv'_not_compl b hb_in_compl)
    -- No final-cut segment with D
    have h_no_final_cut : ¬∃ t, t ∈ cut ∧ ∀ u, t ≤ u → u ∈ cut →
        stavi_temporal_truth M atomMap u D := by
      intro ⟨t, ht_cut, hDt⟩
      have htm : t < m := h_cut_lt_compl t ht_cut m hm_in_compl
      have hst : s < t := by
        by_contra h; push_neg at h
        exact hD_fail (hDt u_fail (le_trans h (le_of_lt hsu_fail)) huf_in_cut)
      apply ht_cut
      cases h_body t hst htm with
      | inl h =>
        intro u htu hum
        rcases eq_or_lt_of_le htu with rfl | htu'
        · exact h
        · obtain ⟨v, hvt, hDv⟩ := h
          exact ⟨t, htu', fun w htw hwm => by
            by_cases hw_cut : w ∈ cut
            · exact hDt w (le_of_lt htw) hw_cut
            · exact h_D_at_compl w (h_not_cut_compl w hw_cut) hwm⟩
      | inr h =>
        obtain ⟨_, v', htv', hv'm, hDv'⟩ := h
        by_cases hv'_cut : v' ∈ cut
        · exact absurd (hDt v' (le_of_lt htv') hv'_cut) hDv'
        · exact absurd (h_D_at_compl v' (h_not_cut_compl v' hv'_cut) hv'm) hDv'
    -- Initial complement segment has D
    have h_init_compl : ∃ t, t ∉ cut ∧ ∀ u, u ∉ cut → u ≤ t →
        stavi_temporal_truth M atomMap u D :=
      ⟨u_init, h_compl_not_cut u_init hu_init_compl,
        fun u hu huu => h_D_at_compl u (h_not_cut_compl u hu) (lt_of_le_of_lt huu hum_init)⟩
    -- Build Gap
    let γ_gap : Gap M.carrier :=
      ⟨cut, ⟨u_fail, huf_in_cut⟩, h_proper, h_cut_dc, h_no_sup, h_comp_no_min⟩
    have h_def_right : gap_definable_on_right M atomMap γ_gap D :=
      ⟨h_init_compl, h_no_final_cut⟩
    have h_r_def : r_definable_gap M atomMap γ_gap r :=
      ⟨D, hD, Or.inr h_def_right⟩
    let γ_rdef : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
    -- X at cut points: from body right disjunct
    have h_X_at_cut : ∀ u : M.carrier, u ∈ cut → u_fail < u →
        stavi_temporal_truth M atomMap u X := by
      intro u hu_cut huf_u
      have hum : u < m := h_cut_lt_compl u hu_cut m hm_in_compl
      have hsu : s < u := lt_trans hsu_fail huf_u
      have ⟨z, hz_cut, huz⟩ : ∃ z ∈ cut, u < z := by
        by_contra h_all; push_neg at h_all
        exact h_no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
      have hzm : z < m := h_cut_lt_compl z hz_cut m hm_in_compl
      have hsz : s < z := lt_trans hsu huz
      have h_right_z : (∀ v, s < v → v < z → stavi_temporal_truth M atomMap v X) ∧
          ∃ v', z < v' ∧ v' < m ∧ ¬stavi_temporal_truth M atomMap v' D := by
        cases h_body z hsz hzm with
        | inl h_left =>
          exfalso; apply hz_cut
          obtain ⟨v, hvz, hDv⟩ := h_left
          intro w hzw hwm; exact ⟨v, lt_of_lt_of_le hvz hzw, hDv⟩
        | inr h_right => exact h_right
      exact h_right_z.1 u hsu huz
    refine ⟨γ_rdef, u_fail, ?_, huf_in_cut, h_def_right, ?_, ?_⟩
    · -- m > γ
      show m ∉ cut ∧ ¬(m ∈ cut); exact ⟨hm_not_cut, hm_not_cut⟩
    · -- D at complement points < m
      intro u hum hu_not
      exact (stavi_truth_mu_at_point u D).mpr (h_D_at_compl u (h_not_cut_compl u hu_not) hum)
    · -- X at cut points above u_fail
      exact fun u hu_cut huf_u => h_X_at_cut u hu_cut huf_u
  · -- **Backward direction** (gap → FO table):
    intro ⟨γ, s_bound, hm_gt_γ, hs_bound_in, h_def_right, h_D_bet, hX_cut⟩
    have hm_not_cut : m ∉ γ.val.cut := by
      intro h; exact not_lt.mpr (show extendPoint m ≤ Sum.inr γ from h) hm_gt_γ
    obtain ⟨⟨t_compl, ht_not_cut, ht_D_init⟩, h_no_final_cut⟩ := h_def_right
    have h_neg_final : ∀ t, t ∈ γ.val.cut →
        ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬stavi_temporal_truth M atomMap w D := by
      intro t ht; by_contra h_all; push_neg at h_all
      exact h_no_final_cut ⟨t, ht, fun w hwt hw_cut => h_all w hw_cut hwt⟩
    have h_cut_lt_m : ∀ x, x ∈ γ.val.cut → x < m := by
      intro x hx; by_contra h; push_neg at h
      exact hm_not_cut (γ.val.downward_closed x m hx h)
    -- Complement points above cut: for v ∉ cut, all cut < v
    have h_compl_gt_cut : ∀ v, v ∉ γ.val.cut → ∀ x, x ∈ γ.val.cut → x < v := by
      intro v hv x hx; by_contra h; push_neg at h
      exact hv (γ.val.downward_closed x v hx h)
    -- Use s_bound as s (s_bound ∈ cut, so s_bound < m)
    refine ⟨s_bound, h_cut_lt_m s_bound hs_bound_in, ?_, ?_, ?_⟩
    · -- Condition (1): ∀ u ∈ (s_bound, m), disjunction
      intro u hsu hum
      by_cases hu_cut : u ∈ γ.val.cut
      · -- u ∈ cut: RIGHT disjunct — X on (s_bound, u) and ¬D witness above u
        right
        refine ⟨fun v hsv hvu => ?_, ?_⟩
        · have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
          exact hX_cut v hv_cut hsv
        · have ⟨z, hz_cut, huz_strict⟩ : ∃ z ∈ γ.val.cut, u < z := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
          obtain ⟨w₂, hw₂_cut, hz_w₂, hDw₂⟩ := h_neg_final z hz_cut
          exact ⟨w₂, lt_of_lt_of_le huz_strict hz_w₂, h_cut_lt_m w₂ hw₂_cut, hDw₂⟩
      · -- u ∉ cut: LEFT disjunct — D cofinal below u
        left
        have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
        exact ⟨y, hyu, fun w hyw hwm => by
          have hw_not : w ∉ γ.val.cut := by
            intro h; exact hy_not (γ.val.downward_closed w y h (le_of_lt hyw))
          exact (stavi_truth_mu_at_point w D).mp (h_D_bet w hwm hw_not)⟩
    · -- Condition (2): ∃ u ∈ (s_bound, m), ¬D(u)
      have ⟨z, hz_cut, hsz⟩ : ∃ z ∈ γ.val.cut, s_bound < z := by
        by_contra h_all; push_neg at h_all
        exact γ.val.no_sup ⟨s_bound,
          ⟨h_all, fun b hb => hb hs_bound_in⟩, hs_bound_in⟩
      obtain ⟨w, hw_cut, hzw, hDw⟩ := h_neg_final z hz_cut
      exact ⟨w, lt_of_lt_of_le hsz hzw, h_cut_lt_m w hw_cut, hDw⟩
    · -- Condition (3): ∃ u ∈ (s_bound, m), D on (u, m)
      have ⟨y, hy_not, hym⟩ : ∃ y, y ∉ γ.val.cut ∧ y < m := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨m, hm_not_cut, fun z hz => h_all z hz⟩
      have hsy : s_bound < y := h_compl_gt_cut y hy_not s_bound hs_bound_in
      refine ⟨y, hsy, hym, fun v hyv hvm => by
        have hv_not : v ∉ γ.val.cut := by
          intro h; exact hy_not (γ.val.downward_closed v y h (le_of_lt hyv))
        exact (stavi_truth_mu_at_point v D).mp (h_D_bet v hvm hv_not)⟩

-- std_snce_gap_detection: DELETED (provably false, past dual of std_untl_gap_detection).
-- Same issue: S(X,D) has no D-failure condition. See std_untl_gap_detection comment above.

theorem gap_detection_unique_right {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {γ₁ γ₂ : Gap M.carrier} {D : StaviFormula} {m : M.carrier}
    (h₁_def : gap_definable_on_right M atomMap γ₁ D)
    (h₂_def : gap_definable_on_right M atomMap γ₂ D)
    (h₁_bet : ∀ u : M.carrier, u < m → u ∉ γ₁.cut →
      stavi_temporal_truth M atomMap u D)
    (h₂_bet : ∀ u : M.carrier, u < m → u ∉ γ₂.cut →
      stavi_temporal_truth M atomMap u D)
    (hm₁ : m ∉ γ₁.cut)
    (hm₂ : m ∉ γ₂.cut) :
    γ₁ = γ₂ := by
  apply gap_ext
  by_contra hne
  wlog h : ¬(γ₁.cut ⊆ γ₂.cut) with H
  · push_neg at hne
    rcases gap_cuts_total γ₁ γ₂ with hsub | hsub
    · exact H h₂_def h₁_def h₂_bet h₁_bet hm₂ hm₁ (Ne.symm hne)
        (fun h' => hne (Set.Subset.antisymm hsub h'))
    · exact h (fun h' => hne (Set.Subset.antisymm h' hsub))
  obtain ⟨x, hx₁, hx₂⟩ := Set.not_subset.mp h
  obtain ⟨_, h_no_init⟩ := h₁_def
  apply h_no_init
  refine ⟨x, hx₁, fun u hxu hu_in₁ => ?_⟩
  have hu_not₂ : u ∉ γ₂.cut := by
    intro h'; exact hx₂ (γ₂.downward_closed u x h' hxu)
  have hum : u < m := by
    by_contra h_not; push_neg at h_not
    exact hm₁ (γ₁.downward_closed u m hu_in₁ h_not)
  exact h₂_bet u hum hu_not₂

theorem right_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (right_formula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m > Sum.inr γ ∧
      gap_definable_on_right M atomMap γ.val D ∧
      (∀ u : M.carrier, u < m → u ∉ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A) := by
  induction A generalizing m with
  | base φ =>
    simp only [right_formula]
    induction φ with
    | atom a =>
      simp only [right_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | bot =>
      simp only [right_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | box a =>
      simp only [right_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | imp f g ih_f ih_g =>
      -- right_formula_base D (.imp f g) = S'(⊤,D) ∧ ¬(right_base(f) ∧ S'(⊤,D) ∧ ¬right_base(g))
      -- Mirrors left base.imp with stavi_snce_gap_detection
      constructor
      · -- Forward direction
        intro hLHS
        simp only [right_formula_base] at hLHS
        simp only [stavi_temporal_truth_mu] at hLHS
        obtain ⟨hS, hNeg⟩ := hLHS
        have hS' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
            (.stavi_snce (.base Formula.top) D) := by
          simp only [stavi_temporal_truth_mu]; exact hS
        obtain ⟨γ, _s_bound, hγ_lt, _hs_in, hγ_def, hγ_bet, _⟩ :=
          (stavi_snce_gap_detection (.base Formula.top) D hD m).mp hS'
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        simp only [stavi_temporal_truth_mu, temporal_truth_mu]
        intro hf_at_γ
        have hRight_f : stavi_temporal_truth_mu M atomMap r (extendPoint m) (right_formula_base D f) :=
          ih_f.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hf_at_γ⟩
        have hRight_g : stavi_temporal_truth_mu M atomMap r (extendPoint m) (right_formula_base D g) := by
          by_contra h
          exact hNeg ⟨hRight_f, hS, h⟩
        obtain ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hg_at_γ'⟩ := ih_g.mp hRight_g
        have hm_not : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        have hm_not' : m ∉ γ'.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ').mpr h) hγ'_lt
        have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
        have hγ'_bet_std : ∀ u, u < m → u ∉ γ'.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ'_bet u hum hu_not)
        have heq : γ.val = γ'.val :=
          gap_detection_unique_right hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_not hm_not'
        rw [Subtype.ext heq]
        exact hg_at_γ'
      · -- Backward direction
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hfg_at_γ⟩
        simp only [right_formula_base, stavi_temporal_truth_mu]
        constructor
        · -- S'(⊤,D)(m): from γ, construct stavi_snce_gap_detection
          have h_compl : ∃ x, x ∈ γ.val.cut := by
            obtain ⟨x, hx⟩ := γ.val.nonempty
            exact ⟨x, hx⟩
          obtain ⟨s_b, hs_b⟩ := h_compl
          have hTop_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_b < u →
              stavi_temporal_truth M atomMap u (.base Formula.top) := by
            intro u _ _
            simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
          have := (stavi_snce_gap_detection (.base Formula.top) D hD m).mpr
            ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_cut⟩
          simp only [stavi_temporal_truth_mu] at this
          exact this
        · -- ¬(right_base(f) ∧ S'(⊤,D)(m) ∧ ¬right_base(g))
          intro ⟨hRf, _, hNRg⟩
          obtain ⟨γ₁, hγ₁_lt, hγ₁_def, hγ₁_bet, hf_at_γ₁⟩ := ih_f.mp hRf
          have hm_not : m ∉ γ.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
          have hm_not₁ : m ∉ γ₁.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ₁).mpr h) hγ₁_lt
          have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
          have hγ₁_bet_std : ∀ u, u < m → u ∉ γ₁.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ₁_bet u hum hu_not)
          have heq : γ₁.val = γ.val :=
            gap_detection_unique_right hγ₁_def hγ_def hγ₁_bet_std hγ_bet_std hm_not₁ hm_not
          simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hfg_at_γ
          have hg_at_γ := hfg_at_γ ((Subtype.ext heq) ▸ hf_at_γ₁)
          exact hNRg (ih_g.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hg_at_γ⟩)
    | untl f g _ _ =>
      -- right_formula_base D (.untl f g) = .std_snce compound D where
      -- compound = D ∧ g ∧ U(f,g) ∧ S'(⊤, g∧D) ∧ ¬S'(D, g∧D)
      -- Mirrors left base.snce with direction reversed
      simp only [right_formula_base]
      rw [stavi_truth_mu_at_point m (.std_snce _ D)]
      simp only [stavi_temporal_truth]
      constructor
      · -- Forward: std_snce(compound, D)(m) → gap conditions
        intro ⟨s, hsm, hcompound_s, hD_bet⟩
        obtain ⟨hDs, hgs, hUntl_s, hS'_gD_s, hNotS'D_gD_s⟩ := hcompound_s
        obtain ⟨s₁, hs₁s, h_body, h_fail, h_init⟩ := hS'_gD_s
        obtain ⟨u_fail, hs₁_uf, huf_s, hgD_fail⟩ := h_fail
        obtain ⟨u_init, hs₁_ui, hui_s, hgD_init⟩ := h_init
        -- Build g∧D-cofinal complement (past direction, mirrors left's cut)
        let gD : M.carrier → Prop := fun u =>
          temporal_truth M atomMap u g ∧ stavi_temporal_truth M atomMap u D
        let compl : Set M.carrier :=
          {x | ∀ u, u < s → x ≤ u → ∃ v, v < u ∧ ∀ w, v < w → w < s → gD w}
        have hs_in_compl : s ∈ compl :=
          fun u hus hsu => absurd (lt_of_le_of_lt hsu hus) (lt_irrefl s)
        have hu_fail_not_compl : u_fail ∉ compl := by
          intro h; obtain ⟨v, hvuf, hgDv⟩ := h u_fail huf_s le_rfl
          exact hgD_fail (hgDv u_fail hvuf huf_s)
        have h_compl_gt_uf : ∀ x ∈ compl, u_fail < x := by
          intro x hx; by_contra h; push_neg at h
          exact hu_fail_not_compl (fun u hus huf => hx u hus (le_trans h huf))
        have h_compl_gt_s₁ : ∀ x ∈ compl, s₁ < x :=
          fun x hx => lt_trans hs₁_uf (h_compl_gt_uf x hx)
        have h_compl_uc : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
          fun x y hx hxy u hus hyu => hx u hus (le_trans (le_trans hxy hyu) le_rfl)
        -- cut = complement of compl (reversed from left's cut)
        let cut : Set M.carrier := {x | x ∉ compl}
        have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut := by
          intro x y hx hyx hy; exact hx (h_compl_uc y x hy hyx)
        have h_proper : cut ≠ Set.univ := by
          intro h; have := h ▸ Set.mem_univ s; exact this hs_in_compl
        have h_cofinal_propagate :
            ∀ u, s₁ < u → u < s →
            (∀ w, u < w → w < s →
              ∃ v, v < w ∧ ∀ z, v < z → z < s → gD z) →
            ∃ v, v < u ∧ ∀ z, v < z → z < s → gD z := by
          intro u hs₁u hus h_above
          cases h_body u hs₁u hus with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', huv', hv's, hgDv'⟩ := h
            obtain ⟨v₂, hv₂v', hgDv₂⟩ := h_above v' huv' hv's
            exact absurd (hgDv₂ v' hv₂v' hv's) hgDv'
        have h_cofinal_u_init :
            ∃ v, v < u_init ∧ ∀ w, v < w → w < s → gD w := by
          cases h_body u_init hs₁_ui hui_s with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hv'ui, hv's, hgDv'⟩ := h
            exact absurd (hgD_init v' hv'ui hv's) hgDv'
        have hu_init_compl : u_init ∈ compl := by
          intro u hus huu_init
          rcases eq_or_lt_of_le huu_init with rfl | hlt
          · exact h_cofinal_u_init
          · exact ⟨u_init, hlt, fun z huz hzs => hgD_init z huz hzs⟩
        have h_gD_at_compl : ∀ u, u ∈ compl → u < s → gD u := by
          intro u hu hus; obtain ⟨v, hvu, hgDv⟩ := hu u hus le_rfl
          exact hgDv u hvu hus
        have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
          intro x hx y hy; by_contra h; push_neg at h
          exact hx (h_compl_uc y x hy h)
        -- No sup in cut (mirrors stavi_snce_gap_detection)
        have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
          intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
          have hps : p < s := h_cut_lt_compl p hp_cut s hs_in_compl
          have hs₁p : s₁ < p := by
            by_contra h; push_neg at h
            exact not_le.mpr (lt_of_le_of_lt h hs₁_uf) (h_ub hu_fail_not_compl)
          apply hp_cut
          intro u hus hpu
          rcases eq_or_lt_of_le hpu with rfl | hpu'
          · exact h_cofinal_propagate p hs₁p hus (fun w hpw hws => by
              have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
              exact this w hws le_rfl)
          · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
            exact this u hus le_rfl
        have h_not_cut_of_compl : ∀ x, x ∈ compl → x ∉ cut :=
          fun x hx hx_cut => hx_cut hx
        -- No min in complement (mirrors stavi_snce_gap_detection)
        have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
          intro ⟨b, hb_not_cut, hb_min⟩
          have hb_compl : b ∈ compl := by by_contra h; exact hb_not_cut (show b ∈ cut from h)
          have hbs : b < s := lt_of_le_of_lt (hb_min u_init (h_not_cut_of_compl _ hu_init_compl)) hui_s
          have hs₁b : s₁ < b := h_compl_gt_s₁ b hb_compl
          have h_below_b : ∀ y, y < b → y ∈ cut := by
            intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
          cases h_body b hs₁b hbs with
          | inl h_cof =>
            obtain ⟨v, hvb, hgDv⟩ := h_cof
            by_cases hvs₁ : v ≤ s₁
            · exact hgD_fail (hgDv u_fail (lt_of_le_of_lt hvs₁ hs₁_uf) huf_s)
            · push_neg at hvs₁
              have hv_compl : v ∈ compl := by
                intro u hus hvu
                rcases eq_or_lt_of_le hvu with rfl | hvu'
                · exact h_cofinal_propagate v hvs₁ (lt_trans hvb hbs)
                    (fun w hvw hws => ⟨v, hvw, hgDv⟩)
                · exact ⟨v, hvu', hgDv⟩
              exact absurd hvb (not_lt.mpr (hb_min v (show v ∉ cut from fun hv_cut => hv_cut hv_compl)))
          | inr h =>
            obtain ⟨_, v', hbv', hv's, hgDv'⟩ := h
            exact hgDv' (h_gD_at_compl v' (h_compl_uc b v' hb_compl (le_of_lt hbv')) hv's)
        -- Construct Gap
        let γ_gap : Gap M.carrier :=
          ⟨cut, ⟨u_fail, show u_fail ∈ cut from hu_fail_not_compl⟩, h_proper, h_cut_dc, h_no_sup, h_comp_no_min⟩
        -- D-definable-on-right: D cofinal in complement, no initial D in cut
        -- Part 1: D cofinal in complement (from gD cofinal → D cofinal)
        have h_D_compl_cofinal : ∃ t, t ∉ γ_gap.cut ∧ ∀ u, u ∉ γ_gap.cut → u ≤ t →
            stavi_temporal_truth M atomMap u D :=
          ⟨u_init, fun h => h hu_init_compl, fun u hu hut =>
            (h_gD_at_compl u (by by_contra h'; exact hu h') (lt_of_le_of_lt hut hui_s)).2⟩
        -- D fails somewhere in (s₁, s): from ¬S'(D, gD)(s)
        have hD_fails : ∃ u_D, s₁ < u_D ∧ u_D < s ∧
            ¬stavi_temporal_truth M atomMap u_D D := by
          by_contra h_all_D; push_neg at h_all_D
          apply hNotS'D_gD_s
          exact ⟨s₁, hs₁s,
            fun u hs₁u hus => by
              cases h_body u hs₁u hus with
              | inl h => left; exact h
              | inr h => right; exact ⟨fun v hsv hvu => h_all_D v hsv (lt_trans hvu hus), h.2⟩,
            ⟨u_fail, hs₁_uf, huf_s, hgD_fail⟩,
            ⟨u_init, hs₁_ui, hui_s, hgD_init⟩⟩
        obtain ⟨u_D, hs₁_uD, huD_s, hD_fail_D⟩ := hD_fails
        -- Part 2: No initial D in cut
        -- Mirrors left's h_no_init_compl_D. Strategy: assume ∃ t ∈ cut with D at
        -- all cut points ≥ t. Construct S'(D, gD)(s) with bound t contradicting
        -- hNotS'D_gD_s. Body: u ∈ cut uses right disjunct (D from hDt), u ∈ compl
        -- uses left disjunct (from compl defn). Fail: u_fail ∈ cut with ¬gD.
        -- Init: u_init ∈ compl with gD on (u_init, s).
        have h_no_init_cut_D : ¬∃ t, t ∈ γ_gap.cut ∧ ∀ u, t ≤ u → u ∈ γ_gap.cut →
            stavi_temporal_truth M atomMap u D := by
          intro ⟨t, ht_cut, hDt⟩
          by_cases htu : t ≤ u_D
          · exact hD_fail_D (hDt u_D htu (show u_D ∉ compl from fun h => hD_fail_D (h_gD_at_compl u_D h huD_s).2))
          · push_neg at htu
            -- u_D < t. Construct S'(D, gD)(s) with bound t, contradicting hNotS'D_gD_s.
            -- All points in (t, s) have D: cut points ≥ t get D from hDt,
            -- compl points get gD → D from h_gD_at_compl.
            apply hNotS'D_gD_s
            have hts : t < s := h_cut_lt_compl t ht_cut s hs_in_compl
            refine ⟨t, hts, ?_, ?_, ?_⟩
            · -- Body: ∀ u ∈ (t, s), left or right disjunct
              intro u htu' hus
              have hs₁u : s₁ < u := lt_trans (lt_trans hs₁_uD htu) htu'
              cases h_body u hs₁u hus with
              | inl h => left; exact h
              | inr h =>
                right
                exact ⟨fun v htv hvu => by
                  by_cases hv_compl : v ∈ compl
                  · exact (h_gD_at_compl v hv_compl (lt_trans hvu hus)).2
                  · exact hDt v (le_of_lt htv) (show v ∈ γ_gap.cut from hv_compl), h.2⟩
            · -- Fail: ∃ u ∈ (t, s) with ¬gD(u)
              -- cut has no sup → ∃ u₂ ∈ cut with u₂ > t
              have ⟨u₂, hu₂_cut, htu₂⟩ : ∃ u₂, u₂ ∈ cut ∧ t < u₂ := by
                by_contra h; push_neg at h
                exact h_no_sup ⟨t, ⟨fun x hx => h x hx,
                  fun ub hub => hub ht_cut⟩, ht_cut⟩
              have hu₂s : u₂ < s := h_cut_lt_compl u₂ hu₂_cut s hs_in_compl
              have hs₁u₂ : s₁ < u₂ := lt_trans (lt_trans hs₁_uD htu) htu₂
              -- h_body at u₂: left → u₂ ∈ compl contradiction, so right
              rcases h_body u₂ hs₁u₂ hu₂s with ⟨v, hvu₂, hgDv⟩ | ⟨_, v', hv'u₂, hv's, hngD⟩
              · exfalso
                exact hu₂_cut (show u₂ ∈ compl from
                  fun u' hu's hu₂u' => ⟨v, lt_of_lt_of_le hvu₂ hu₂u', hgDv⟩)
              · exact ⟨v', lt_trans htu₂ hv'u₂, hv's, hngD⟩
            · -- Init: ∃ u ∈ (t, s) with gD on (u, s)
              have ht_ui : t < u_init :=
                h_cut_lt_compl t ht_cut u_init hu_init_compl
              exact ⟨u_init, ht_ui, hui_s, hgD_init⟩
        have h_def_right : gap_definable_on_right M atomMap γ_gap D :=
          ⟨h_D_compl_cofinal, h_no_init_cut_D⟩
        have h_r_def : r_definable_gap M atomMap γ_gap r :=
          ⟨D, hD, Or.inr h_def_right⟩
        let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
        refine ⟨γ, ?_, h_def_right, ?_, ?_⟩
        · -- extendPoint m > Sum.inr γ: m ∉ cut (m is above all cut points)
          have hm_compl : m ∈ compl := h_compl_uc s m hs_in_compl (le_of_lt hsm)
          show @GT.gt (ExtendedCarrier M atomMap r) _ (extendPoint m) (Sum.inr γ)
          exact ⟨fun h => h hm_compl, fun h => h hm_compl⟩
        · -- D at complement points below m
          intro u hum hu_not_cut
          have hu_compl : u ∈ compl := by by_contra h'; exact hu_not_cut h'
          by_cases hus : u < s
          · exact (stavi_truth_mu_at_point u D).mpr (h_gD_at_compl u hu_compl hus).2
          · push_neg at hus
            rcases eq_or_lt_of_le hus with rfl | hsu
            · exact (stavi_truth_mu_at_point s D).mpr hDs
            · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hsu hum)
        · -- U(f,g)^mu at γ
          simp only [temporal_truth] at hUntl_s
          obtain ⟨s₂, hss₂, hf_s₂, hg_bet⟩ := hUntl_s
          show temporal_truth_mu M atomMap r (Sum.inr γ) (f.untl g)
          have hs_compl : s ∈ compl := hs_in_compl
          refine ⟨extendPoint s₂, ?_, ⟨s₂, rfl⟩,
            (temporal_truth_mu_at_point s₂ f).mpr hf_s₂, ?_⟩
          · -- Sum.inr γ < extendPoint s₂
            show @LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inr γ) (extendPoint s₂)
            have : @LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inr γ) (extendPoint s) :=
              ⟨fun h => h hs_compl, fun h => h hs_compl⟩
            exact lt_trans this ((extendPoint_lt_iff s s₂).mpr hss₂)
          · -- g^mu at mu-points between γ and s₂
            intro u hγu hus₂ hmu
            obtain ⟨p, rfl⟩ := hmu
            apply (temporal_truth_mu_at_point p g).mpr
            have hps₂ : p < s₂ := (extendPoint_lt_iff p s₂).mp hus₂
            by_cases hps : s ≤ p
            · rcases eq_or_lt_of_le hps with rfl | hsp
              · exact hgs
              · exact hg_bet p hsp hps₂
            · push_neg at hps
              have hp_compl : p ∈ compl := by
                by_contra hp_cut
                exact not_le.mpr hγu ((extendPoint_le_gap_iff p γ).mpr hp_cut)
              exact (h_gD_at_compl p hp_compl hps).1
      · -- Backward: gap conditions → std_snce(compound, D)(m)
        -- Mirrors left base.snce backward with direction reversed
        -- Left backward: gap above m, s = cut point above m+t_pt, S(f,g)^mu → compound above m
        -- Right backward: gap below m, s = compl point below m where compound holds
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUntl_mu⟩
        -- U(f,g)^mu(γ): ∃ t > γ (mu-point), f^mu(t) ∧ g^mu on (γ, t)
        simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hUntl_mu
        obtain ⟨t_ext, hγ_t, ⟨t_pt, rfl⟩, hf_t, hg_mu⟩ := hUntl_mu
        -- t_pt is a complement point (above gap)
        have ht_not_cut : t_pt ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff t_pt γ).mpr h) hγ_t
        -- m is a complement point (above gap)
        have hm_not_cut : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        -- Find complement point s: below m, below t_pt (for g from g^mu on (γ, t_pt))
        have ⟨s, hs_not_cut, hsm, hst⟩ :
            ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < t_pt := by
          -- complement has no min, so we can find complement points below any complement point.
          -- We need s < m, s > t_pt, s ∉ cut.
          -- Since t_pt ∉ cut and m ∉ cut and cut is downward closed:
          -- any point between t_pt and m that's ∉ cut works, or if t_pt < m, m is one.
          -- But we need s STRICTLY < m.
          -- All complement points > t_pt that are < m work (there are infinitely many since
          -- between any two complement points there's another complement point).
          -- Actually, complement may not be dense. But cut has no sup so cut points go
          -- arbitrarily high. Between cut points and complement points there may be structure.
          -- Simplest: if t_pt < m, find any point between them that's not in cut.
          -- All points above cut are not in cut (cut is downward closed).
          -- But cut could extend above t_pt... no, t_pt ∉ cut and cut is downward closed,
          -- so ALL points ≥ t_pt are ∉ cut? NO! Cut is downward closed means:
          -- x ∈ cut ∧ y ≤ x → y ∈ cut. So if t_pt ∉ cut, then no point ≥ t_pt is in cut?
          -- NO: cut is downward closed, so if x ∈ cut, any y ≤ x is in cut.
          -- But there CAN be cut points above t_pt if t_pt is not in cut.
          -- Example: cut = (-∞, 0) ∪ {1}, then 0.5 ∉ cut but 1 ∈ cut. But this contradicts
          -- downward closure: 0.5 ≤ 1 would require 0.5 ∈ cut.
          -- So actually, if t_pt ∉ cut and cut is downward closed, then ∀ u ≥ t_pt, u ∉ cut.
          -- Great! So any point ≥ t_pt is ∉ cut.
          -- We need s with t_pt < s < m. By linear order density? Not necessarily dense.
          -- But m and t_pt are carrier points. There might not be a carrier point between them.
          -- We need to handle the case t_pt < m vs t_pt ≥ m separately.
          by_cases htm : t_pt < m
          · -- Need s with t_pt < s < m, s ∉ cut
            -- Since complement has no minimum (relative to points above gap), and m is in complement,
            -- there exists a complement point below m that is above γ.
            -- All points above t_pt are complement (since cut is downward closed and t_pt ∉ cut).
            -- So any carrier point between t_pt and m works.
            -- But are there carrier points between t_pt and m?
            -- Not necessarily in a discrete order! t_pt could be pred(m).
            -- In that case, use t_pt itself as the witness (need t_pt < m, which holds).
            -- Wait, we need s ∉ cut. And t_pt ∉ cut. So s = t_pt works if t_pt < m!
            -- But the problem says s < m AND t_pt < s. We need s STRICTLY above t_pt.
            -- Hmm, do we really need s above t_pt? Let me re-read the left proof.
            -- In left: s was a cut point above BOTH m and t_pt. It needed t_pt < s for g(s).
            -- In right: we need s between γ and m. For g(s), we need t_pt < s so g(s) comes from
            -- g^mu on (γ, t_pt). Wait, actually g^mu on (γ, t_pt) gives g at mu-points between
            -- γ and t_pt. If s > t_pt, then s is NOT between γ and t_pt, so we can't get g(s).
            -- Unless t_pt was the UPPER bound and g^mu goes from γ to t_pt.
            -- U(f,g)^mu(γ) = ∃ t > γ, f(t) ∧ g on (γ, t). So g holds between γ and t_pt.
            -- We need s between γ and t_pt for g(s)! Not above t_pt.
            -- So s should satisfy: γ < s < t_pt (to get g(s)) AND s < m.
            -- If t_pt < m, then γ < s < t_pt < m gives both s < m and s in range for g.
            -- But we need s ∉ cut. Since γ < s: s could be in cut or not.
            -- Actually, cut goes up to γ (cut = below gap), and s > γ so s ∉ cut.
            -- Wait, but cut is downward closed and has no sup. So cut could extend beyond γ.
            -- NO: γ represents a gap between cut and complement. Cut is EXACTLY the set below γ.
            -- And complement = above γ. So for any s with extendPoint s > Sum.inr γ, s ∉ cut.
            -- And for any s with extendPoint s ≤ Sum.inr γ (i.e., s ∈ cut), s IS in cut.
            -- So: s ∈ cut ↔ extendPoint s ≤ Sum.inr γ ↔ s ∈ γ.val.cut (by definition).
            --
            -- So for s > γ (i.e., s ∉ cut), we need γ < s < t_pt (for g) and s < m.
            -- Such s exists because: between γ and t_pt there must be complement points
            -- (complement has no minimum, and t_pt is in complement).
            -- Actually, t_pt ∉ cut, so all we know is extendPoint t_pt > Sum.inr γ.
            -- We need s ∉ cut with s < t_pt.
            -- Since complement has no minimum, there's a complement point below t_pt.
            -- That complement point is also > γ (since all complement points are above the gap).
            -- So ∃ s, s ∉ cut ∧ s < t_pt.
            have ⟨s, hs_not, hs_t⟩ : ∃ s, s ∉ γ.val.cut ∧ s < t_pt := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨t_pt, ht_not_cut,
                fun z hz => h_all z hz⟩
            exact ⟨s, hs_not, lt_trans hs_t htm, hs_t⟩
          · -- t_pt ≥ m: need s < m ≤ t_pt, s ∉ cut
            push_neg at htm
            have ⟨s, hs_not, hs_m⟩ : ∃ s, s ∉ γ.val.cut ∧ s < m := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨m, hm_not_cut,
                fun z hz => h_all z hz⟩
            exact ⟨s, hs_not, hs_m, lt_of_lt_of_le hs_m htm⟩
        -- Properties at s (complement point below m):
        -- D(s) from D-between
        have hDs : stavi_temporal_truth M atomMap s D :=
          (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
        -- g(s) from U(f,g)^mu(γ): s is a complement point below t_pt
        have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (Sum.inr γ) (extendPoint s) := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
        have hst' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint s) (extendPoint t_pt) := (extendPoint_lt_iff s t_pt).mpr hst
        have hgs : temporal_truth M atomMap s g :=
          (temporal_truth_mu_at_point s g).mp
            (hg_mu (extendPoint s) hγs hst' ⟨s, rfl⟩)
        -- U(f,g)(s): witness t_pt with f(t_pt) and g on (s, t_pt)
        have hUntl_s : temporal_truth M atomMap s (f.untl g) := by
          simp only [temporal_truth]
          refine ⟨t_pt, hst, (temporal_truth_mu_at_point t_pt f).mp hf_t, fun u hsu hut => ?_⟩
          have hu_not_cut : u ∉ γ.val.cut := by
            intro h
            have : @LE.le (ExtendedCarrier M atomMap r) _ (extendPoint u) (Sum.inr γ) :=
              (extendPoint_le_gap_iff u γ).mpr h
            exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu)) this
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint u) :=
            ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
          have hut' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (extendPoint t_pt) := (extendPoint_lt_iff u t_pt).mpr hut
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu hut' ⟨u, rfl⟩)
        -- D on (s, m): complement points between s and m have D
        have hD_bet_sm : ∀ u, s < u → u < m → stavi_temporal_truth M atomMap u D := by
          intro u hsu hum
          have hu_not_cut : u ∉ γ.val.cut := by
            intro h
            have : @LE.le (ExtendedCarrier M atomMap r) _ (extendPoint u) (Sum.inr γ) :=
              (extendPoint_le_gap_iff u γ).mpr h
            exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu)) this
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not_cut)
        -- Extract gap definability conditions
        obtain ⟨⟨t_D, ht_D_not, hD_init⟩, h_no_final_D⟩ := hγ_def
        -- Helper: cut points < complement points
        have h_cut_lt : ∀ x, x ∈ γ.val.cut → ∀ y, y ∉ γ.val.cut → x < y := by
          intro x hx y hy; by_contra h; push_neg at h
          exact hy (γ.val.downward_closed x y hx h)
        -- Helper: ¬D witnesses at cut points
        have h_neg_final : ∀ t, t ∈ γ.val.cut →
            ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬stavi_temporal_truth M atomMap w D := by
          intro t ht; by_contra h_all; push_neg at h_all
          exact h_no_final_D ⟨t, ht, fun w htw hw_cut => h_all w hw_cut htw⟩
        -- Get a cut point for S'(⊤, g∧D) bound
        have ⟨c₀, hc₀_cut⟩ : ∃ c₀, c₀ ∈ γ.val.cut := by
          obtain ⟨z, hz⟩ := γ.val.nonempty
          exact ⟨z, hz⟩
        have hc₀s : c₀ < s := h_cut_lt c₀ hc₀_cut s hs_not_cut
        -- g∧D at complement points below s
        have h_gD_compl : ∀ u, u < s → u ∉ γ.val.cut →
            temporal_truth M atomMap u g ∧ stavi_temporal_truth M atomMap u D := by
          intro u hus hu_not_cut
          constructor
          · -- g from g^mu on (γ, t_pt): u is between γ and s < t_pt
            have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (Sum.inr γ) (extendPoint u) :=
              ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
            have hut' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (extendPoint u) (extendPoint t_pt) :=
              lt_trans ((extendPoint_lt_iff u s).mpr hus) hst'
            exact (temporal_truth_mu_at_point u g).mp
              (hg_mu (extendPoint u) hγu hut' ⟨u, rfl⟩)
          · -- D from hγ_bet: u < m and u ∉ cut
            exact (stavi_truth_mu_at_point u D).mp
              (hγ_bet u (lt_trans hus hsm) hu_not_cut)
        refine ⟨s, hsm, ⟨hDs, hgs, hUntl_s, ?_, ?_⟩, hD_bet_sm⟩
        · -- S'(⊤, g∧D)(s): bound c₀ (a cut point below s)
          refine ⟨c₀, hc₀s, ?_, ?_, ?_⟩
          · -- Condition (1): body
            intro u hc₀u hus
            by_cases hu_not_cut : u ∉ γ.val.cut
            · -- u ∉ cut (complement): left disjunct (gD cofinal below u)
              left
              have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
                by_contra h_all; push_neg at h_all
                exact γ.val.complement_no_min ⟨u, hu_not_cut, fun z hz => h_all z hz⟩
              exact ⟨y, hyu, fun w hyw hws =>
                h_gD_compl w hws (fun h_cut =>
                  hy_not (γ.val.downward_closed w y h_cut (le_of_lt hyw)))⟩
            · -- u ∈ cut: right disjunct (⊤ trivial + ¬gD witness)
              push_neg at hu_not_cut
              right
              refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
              have ⟨y, hy_cut, huy⟩ : ∃ y, y ∈ γ.val.cut ∧ u < y := by
                by_contra h_all; push_neg at h_all
                exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun _ hb => hb hu_not_cut⟩,
                  hu_not_cut⟩
              obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
              exact ⟨w, lt_of_lt_of_le huy hyw, h_cut_lt w hw_cut s hs_not_cut,
                fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (2): ¬gD failure in (c₀, s)
            have ⟨y, hy_cut, hc₀y⟩ : ∃ y, y ∈ γ.val.cut ∧ c₀ < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨c₀, ⟨fun x hx => h_all x hx, fun _ hb => hb hc₀_cut⟩,
                hc₀_cut⟩
            obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
            exact ⟨w, lt_of_lt_of_le hc₀y hyw, h_cut_lt w hw_cut s hs_not_cut,
              fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (3): gD initial in (c₀, s)
            have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨s, hs_not_cut, fun z hz => h_all z hz⟩
            exact ⟨y, h_cut_lt c₀ hc₀_cut y hy_not, hys, fun v hyv hvs =>
              h_gD_compl v hvs (fun hv_cut =>
                hy_not (γ.val.downward_closed v y hv_cut (le_of_lt hyv)))⟩
        · -- ¬S'(D, g∧D)(s): by contradiction using two-step D-transfer argument
          intro ⟨s₁, hs₁s, h_body, h_fail, h_init⟩
          obtain ⟨u_fail, hs₁_uf, huf_s, hgD_fail⟩ := h_fail
          -- u_fail ∈ cut (complement points have gD from h_gD_compl)
          have huf_cut : u_fail ∈ γ.val.cut := by
            by_contra huf_not
            exact hgD_fail (h_gD_compl u_fail huf_s huf_not)
          -- Left disjunct fails at cut points
          have h_left_fails : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
              ¬(∃ v, v < u ∧ ∀ w, v < w → w < s →
                temporal_truth M atomMap w g ∧ stavi_temporal_truth M atomMap w D) := by
            intro u _ _ hu_cut ⟨v, hvu, hgDv⟩
            have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
            have ⟨y, hy_cut, hvy⟩ : ∃ y, y ∈ γ.val.cut ∧ v < y := by
              by_contra h; push_neg at h
              exact γ.val.no_sup ⟨v, ⟨h, fun _ hb => hb hv_cut⟩, hv_cut⟩
            obtain ⟨w', hw'_cut, hyw', hDw'⟩ := h_neg_final y hy_cut
            exact hDw' (hgDv w' (lt_of_lt_of_le hvy hyw')
              (h_cut_lt w' hw'_cut s hs_not_cut)).2
          -- Two-step: D at ALL cut points in (s₁, s)
          have hD_all_cut : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
              stavi_temporal_truth M atomMap u D := by
            intro u hs₁u hus hu_cut
            have h_right_u := (h_body u hs₁u hus).resolve_left
              (h_left_fails u hs₁u hus hu_cut)
            obtain ⟨_, v', hv'u, hv's, hgD_v'⟩ := h_right_u
            have hv'_cut : v' ∈ γ.val.cut := by
              by_contra hv'_not; exact hgD_v' (h_gD_compl v' hv's hv'_not)
            have ⟨u', hu'_cut, huu'⟩ : ∃ u', u' ∈ γ.val.cut ∧ u < u' := by
              by_contra h; push_neg at h
              exact γ.val.no_sup ⟨u, ⟨h, fun _ hb => hb hu_cut⟩, hu_cut⟩
            have hu's : u' < s := h_cut_lt u' hu'_cut s hs_not_cut
            have h_right_u' := (h_body u' (lt_trans hs₁u huu') hu's).resolve_left
              (h_left_fails u' (lt_trans hs₁u huu') hu's hu'_cut)
            exact h_right_u'.1 u hs₁u huu'
          -- s₁ ∈ cut (if ∉ cut, u_fail also ∉ cut — contradiction)
          have hs₁_cut : s₁ ∈ γ.val.cut := by
            by_contra hs₁_not
            exact not_le.mpr (h_cut_lt u_fail huf_cut s₁ hs₁_not) (le_of_lt hs₁_uf)
          have ⟨t₀, ht₀_cut, hs₁t₀⟩ : ∃ t₀, t₀ ∈ γ.val.cut ∧ s₁ < t₀ := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨s₁, ⟨h, fun _ hb => hb hs₁_cut⟩, hs₁_cut⟩
          exact h_no_final_D ⟨t₀, ht₀_cut, fun u ht₀u hu_cut =>
            hD_all_cut u (lt_of_lt_of_le hs₁t₀ ht₀u)
              (h_cut_lt u hu_cut s hs_not_cut) hu_cut⟩
    | snce f g _ _ =>
      -- right_formula_base D (.snce f g) = S'(g ∧ S(f,g), D)
      -- Mirrors left base.untl with stavi_snce_gap_detection
      simp only [right_formula_base]
      rw [stavi_snce_gap_detection (.conj (.base g) (.base (.snce f g))) D hD m]
      constructor
      · -- Forward: cut-point truth of g ∧ S(f,g) → S(f,g)^mu at γ
        intro ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth, temporal_truth_mu]
        -- Need S(f,g)^mu at γ: ∃ s < γ (mu), f^mu(s) ∧ g^mu on (s, γ)
        -- Pick a cut point u₀ above s_bound
        have ⟨u₀, hu₀_in, hu₀s⟩ : ∃ u₀, u₀ ∈ γ.val.cut ∧ s_bound < u₀ := by
          by_contra h_all; push_neg at h_all
          exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
        have hX_u₀ := hX_cut u₀ hu₀_in hu₀s
        simp only [stavi_temporal_truth, temporal_truth] at hX_u₀
        obtain ⟨hg_u₀, t₁, ht₁u₀, hf_t₁, hg_between⟩ := hX_u₀
        -- t₁ ∈ cut (since t₁ < u₀ and u₀ ∈ cut, cut is downward closed)
        have ht₁_in : t₁ ∈ γ.val.cut :=
          γ.val.downward_closed u₀ t₁ hu₀_in (le_of_lt ht₁u₀)
        -- Witness: s = extendPoint t₁
        refine ⟨extendPoint t₁, ⟨ht₁_in, fun h => h ht₁_in⟩, ⟨t₁, rfl⟩,
          (temporal_truth_mu_at_point t₁ f).mpr hf_t₁, fun v hvt₁ hvγ hmu => ?_⟩
        obtain ⟨v₀, rfl⟩ := hmu
        have hv₀_in : v₀ ∈ γ.val.cut :=
          (extendPoint_le_gap_iff v₀ γ).mp (le_of_lt hvγ)
        have hv₀_t₁ : t₁ < v₀ := (extendPoint_lt_iff t₁ v₀).mp hvt₁
        apply (temporal_truth_mu_at_point v₀ g).mpr
        by_cases hv_u₀ : v₀ < u₀
        · exact hg_between v₀ hv₀_t₁ hv_u₀
        · push_neg at hv_u₀
          have hv₀_sb : s_bound < v₀ := lt_of_lt_of_le hu₀s hv_u₀
          exact (hX_cut v₀ hv₀_in hv₀_sb).1
      · -- Backward: S(f,g)^mu at γ → cut-point truth of g ∧ S(f,g)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
        simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hSA
        obtain ⟨s, hsγ, hmu_s, hf_s, hg_mu⟩ := hSA
        obtain ⟨t₁, rfl⟩ := hmu_s
        have ht₁_in : t₁ ∈ γ.val.cut :=
          (extendPoint_le_gap_iff t₁ γ).mp (le_of_lt hsγ)
        refine ⟨γ, t₁, hγ_lt, ht₁_in, hγ_def, hγ_bet, fun u hu_in hu_t₁ => ?_⟩
        simp only [stavi_temporal_truth, temporal_truth]
        constructor
        · -- g(u): u is a cut point between t₁ and γ
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (Sum.inr γ) := by
            exact ⟨hu_in, fun h => h hu_in⟩
          have hut₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t₁) (extendPoint u) :=
            (extendPoint_lt_iff t₁ u).mpr hu_t₁
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hut₁ hγu ⟨u, rfl⟩)
        · -- S(f,g)(u): use t₁ as witness
          refine ⟨t₁, hu_t₁, (temporal_truth_mu_at_point t₁ f).mp hf_s, fun v htv hvu => ?_⟩
          have hv_in : v ∈ γ.val.cut := by
            exact γ.val.downward_closed u v hu_in (le_of_lt hvu)
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint v) (Sum.inr γ) := ⟨hv_in, fun h => h hv_in⟩
          have hvt₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t₁) (extendPoint v) :=
            (extendPoint_lt_iff t₁ v).mpr htv
          exact (temporal_truth_mu_at_point v g).mp
            (hg_mu (extendPoint v) hvt₁ hγv ⟨v, rfl⟩)
  | neg A ih =>
    simp only [right_formula, stavi_temporal_truth_mu]
    constructor
    · intro ⟨hS, hNot⟩
      have hS' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
          (.stavi_snce (.base Formula.top) D) := by
        simp only [stavi_temporal_truth_mu]; exact hS
      obtain ⟨γ, _s_bound, hγ_lt, _hs_in, hγ_def, hγ_bet, _⟩ :=
        (stavi_snce_gap_detection (.base Formula.top) D hD m).mp hS'
      have hNot' : ¬(∃ (γ' : RDefinableGap M atomMap r),
          extendPoint m > Sum.inr γ' ∧
          gap_definable_on_right M atomMap γ'.val D ∧
          (∀ u, u < m → u ∉ γ'.val.cut → stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
          stavi_temporal_truth_mu M atomMap r (Sum.inr γ') A) := by
        rwa [← ih m]
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      intro hA_at_γ
      exact hNot' ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_at_γ⟩
    · intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hNot_A⟩
      constructor
      · have h_compl : ∃ x, x ∈ γ.val.cut := by
          obtain ⟨x, hx⟩ := γ.val.nonempty
          exact ⟨x, hx⟩
        obtain ⟨s_b, hs_b⟩ := h_compl
        have hTop_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_b < u →
            stavi_temporal_truth M atomMap u (.base Formula.top) := by
          intro u _ _
          simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
        have := (stavi_snce_gap_detection (.base Formula.top) D hD m).mpr
          ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_cut⟩
        simp only [stavi_temporal_truth_mu] at this
        exact this
      · rw [ih m]
        intro ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hA_at_γ'⟩
        have hm_not : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        have hm_not' : m ∉ γ'.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ').mpr h) hγ'_lt
        have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hum hu_not
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
        have hγ'_bet_std : ∀ u, u < m → u ∉ γ'.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hum hu_not
          exact (stavi_truth_mu_at_point u D).mp (hγ'_bet u hum hu_not)
        have heq : γ.val = γ'.val :=
          gap_detection_unique_right hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_not hm_not'
        have : γ = γ' := Subtype.ext heq
        rw [this] at hNot_A
        exact hNot_A hA_at_γ'
  | conj A B ihA ihB =>
    simp only [right_formula, stavi_temporal_truth_mu]
    constructor
    · intro ⟨hA, hB⟩
      obtain ⟨γA, hγA_lt, hγA_def, hγA_bet, hγA_val⟩ := (ihA m).mp hA
      obtain ⟨γB, hγB_lt, hγB_def, hγB_bet, hγB_val⟩ := (ihB m).mp hB
      have hm_not_A : m ∉ γA.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γA).mpr h) hγA_lt
      have hm_not_B : m ∉ γB.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γB).mpr h) hγB_lt
      have hγA_bet' : ∀ u, u < m → u ∉ γA.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hum hu_not
        exact (stavi_truth_mu_at_point u D).mp (hγA_bet u hum hu_not)
      have hγB_bet' : ∀ u, u < m → u ∉ γB.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hum hu_not
        exact (stavi_truth_mu_at_point u D).mp (hγB_bet u hum hu_not)
      have heq : γA.val = γB.val :=
        gap_detection_unique_right hγA_def hγB_def hγA_bet' hγB_bet' hm_not_A hm_not_B
      refine ⟨γA, hγA_lt, hγA_def, hγA_bet, ?_, ?_⟩
      · exact hγA_val
      · have : γA = γB := Subtype.ext heq
        rw [this]
        exact hγB_val
    · intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val, hB_val⟩
      exact ⟨(ihA m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val⟩,
             (ihB m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hB_val⟩⟩
  | stavi_untl A B ihA ihB =>
    -- right_formula (.stavi_untl A B) D = .std_snce compound D
    -- compound = D ∧ B ∧ U'(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D)
    -- Same compound decomposition as right base.untl with U'(A,B) instead of U(f,g)
    simp only [right_formula]
    rw [stavi_truth_mu_at_point m (.std_snce _ D)]
    simp only [stavi_temporal_truth]
    constructor
    · -- Forward: std_snce(compound, D)(m) → gap conditions
      intro ⟨s, hsm, ⟨hDs, hBs, hUntl_s, hS'_BD_s, hNotS'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hs₁s, h_body, h_fail, h_init⟩ := hS'_BD_s
      obtain ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hs₁_ui, hui_s, hBD_init⟩ := h_init
      -- Gap construction (identical to base.untl)
      let bD : M.carrier → Prop := fun u =>
        stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D
      let compl : Set M.carrier :=
        {x | ∀ u, u < s → x ≤ u → ∃ v, v < u ∧ ∀ w, v < w → w < s → bD w}
      have hs_in_compl : s ∈ compl :=
        fun u hus hsu => absurd (lt_of_le_of_lt hsu hus) (lt_irrefl s)
      have hu_fail_not_compl : u_fail ∉ compl := by
        intro h; obtain ⟨v, hvuf, hBDv⟩ := h u_fail huf_s le_rfl
        exact hBD_fail (hBDv u_fail hvuf huf_s)
      have h_compl_gt_uf : ∀ x ∈ compl, u_fail < x := by
        intro x hx; by_contra h; push_neg at h
        exact hu_fail_not_compl (fun u hus huf => hx u hus (le_trans h huf))
      have h_compl_uc : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
        fun x y hx hxy u hus hyu => hx u hus (le_trans (le_trans hxy hyu) le_rfl)
      let cut : Set M.carrier := {x | x ∉ compl}
      have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut := by
        intro x y hx hyx hy; exact hx (h_compl_uc y x hy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; have := h ▸ Set.mem_univ s; exact this hs_in_compl
      have h_cofinal_propagate :
          ∀ u, s₁ < u → u < s →
          (∀ w, u < w → w < s → ∃ v, v < w ∧ ∀ z, v < z → z < s → bD z) →
          ∃ v, v < u ∧ ∀ z, v < z → z < s → bD z := by
        intro u hs₁u hus h_above
        cases h_body u hs₁u hus with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', huv', hv's, hBDv'⟩ := h
          obtain ⟨v₂, hv₂v', hBDv₂⟩ := h_above v' huv' hv's
          exact absurd (hBDv₂ v' hv₂v' hv's) hBDv'
      have hu_init_compl : u_init ∈ compl := by
        intro u hus huu_init
        rcases eq_or_lt_of_le huu_init with rfl | hlt
        · cases h_body u_init hs₁_ui hui_s with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hv'ui, hv's, hBDv'⟩ := h
            exact absurd (hBD_init v' hv'ui hv's) hBDv'
        · exact ⟨u_init, hlt, fun z huz hzs => hBD_init z huz hzs⟩
      have h_bD_at_compl : ∀ u, u ∈ compl → u < s → bD u := by
        intro u hu hus; obtain ⟨v, hvu, hBDv⟩ := hu u hus le_rfl
        exact hBDv u hvu hus
      have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hx (h_compl_uc y x hy h)
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hps : p < s := h_cut_lt_compl p hp_cut s hs_in_compl
        have hs₁p : s₁ < p := by
          by_contra h; push_neg at h
          exact not_le.mpr (lt_of_le_of_lt h hs₁_uf) (h_ub hu_fail_not_compl)
        apply hp_cut
        intro u hus hpu
        rcases eq_or_lt_of_le hpu with rfl | hpu'
        · exact h_cofinal_propagate p hs₁p hus (fun w hpw hws => by
            have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
            exact this w hws le_rfl)
        · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
          exact this u hus le_rfl
      have h_not_cut_of_compl : ∀ x, x ∈ compl → x ∉ cut :=
        fun x hx hx_cut => hx_cut hx
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not_cut, hb_min⟩
        have hb_compl : b ∈ compl := by by_contra h; exact hb_not_cut (show b ∈ cut from h)
        have hbs : b < s := lt_of_le_of_lt (hb_min u_init (h_not_cut_of_compl _ hu_init_compl)) hui_s
        have hs₁b : s₁ < b := lt_trans hs₁_uf (h_compl_gt_uf b hb_compl)
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hs₁b hbs with
        | inl h_cof =>
          obtain ⟨v, hvb, hBDv⟩ := h_cof
          by_cases hvs₁ : v ≤ s₁
          · exact hBD_fail (hBDv u_fail (lt_of_le_of_lt hvs₁ hs₁_uf) huf_s)
          · push_neg at hvs₁
            have hv_compl : v ∈ compl := by
              intro u hus hvu
              rcases eq_or_lt_of_le hvu with rfl | hvu'
              · exact h_cofinal_propagate v hvs₁ (lt_trans hvb hbs)
                  (fun w hvw hws => ⟨v, hvw, hBDv⟩)
              · exact ⟨v, hvu', hBDv⟩
            exact absurd hvb (not_lt.mpr (hb_min v (show v ∉ cut from fun hv_cut => hv_cut hv_compl)))
        | inr h =>
          obtain ⟨_, v', hbv', hv's, hBDv'⟩ := h
          exact hBDv' (h_bD_at_compl v' (h_compl_uc b v' hb_compl (le_of_lt hbv')) hv's)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨u_fail, show u_fail ∈ cut from hu_fail_not_compl⟩, h_proper, h_cut_dc, h_no_sup, h_comp_no_min⟩
      have h_D_compl_cofinal : ∃ t, t ∉ γ_gap.cut ∧ ∀ u, u ∉ γ_gap.cut → u ≤ t →
          stavi_temporal_truth M atomMap u D :=
        ⟨u_init, fun h => h hu_init_compl, fun u hu hut =>
          (h_bD_at_compl u (by by_contra h'; exact hu h') (lt_of_le_of_lt hut hui_s)).2⟩
      have hD_fails : ∃ u_D, s₁ < u_D ∧ u_D < s ∧
          ¬stavi_temporal_truth M atomMap u_D D := by
        by_contra h_all_D; push_neg at h_all_D
        apply hNotS'D_BD_s
        exact ⟨s₁, hs₁s,
          fun u hs₁u hus => by
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v hsv hvu => h_all_D v hsv (lt_trans hvu hus), h.2⟩,
          ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩,
          ⟨u_init, hs₁_ui, hui_s, hBD_init⟩⟩
      obtain ⟨u_D, hs₁_uD, huD_s, hD_fail_D⟩ := hD_fails
      have hu_D_not_compl : u_D ∉ compl := by
        intro h; exact hD_fail_D (h_bD_at_compl u_D h huD_s).2
      have h_no_init_cut_D : ¬∃ t, t ∈ γ_gap.cut ∧ ∀ u, t ≤ u → u ∈ γ_gap.cut →
          stavi_temporal_truth M atomMap u D := by
        intro ⟨t, ht_cut, hDt⟩
        by_cases htu : t ≤ u_D
        · exact hD_fail_D (hDt u_D htu (show u_D ∉ compl from hu_D_not_compl))
        · push_neg at htu
          apply hNotS'D_BD_s
          have hts : t < s := h_cut_lt_compl t ht_cut s hs_in_compl
          refine ⟨t, hts, ?_, ?_, ?_⟩
          · intro u htu' hus
            have hs₁u : s₁ < u := lt_trans (lt_trans hs₁_uD htu) htu'
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h =>
              right
              exact ⟨fun v htv hvu => by
                by_cases hv_compl : v ∈ compl
                · exact (h_bD_at_compl v hv_compl (lt_trans hvu hus)).2
                · exact hDt v (le_of_lt htv) (show v ∈ γ_gap.cut from hv_compl), h.2⟩
          · have ⟨u₂, hu₂_cut, htu₂⟩ : ∃ u₂, u₂ ∈ cut ∧ t < u₂ := by
              by_contra h; push_neg at h
              exact h_no_sup ⟨t, ⟨fun x hx => h x hx,
                fun ub hub => hub ht_cut⟩, ht_cut⟩
            have hu₂s : u₂ < s := h_cut_lt_compl u₂ hu₂_cut s hs_in_compl
            have hs₁u₂ : s₁ < u₂ := lt_trans (lt_trans hs₁_uD htu) htu₂
            rcases h_body u₂ hs₁u₂ hu₂s with ⟨v, hvu₂, hBDv⟩ | ⟨_, v', hv'u₂, hv's, hngD⟩
            · exfalso
              exact hu₂_cut (show u₂ ∈ compl from
                fun u' hu's hu₂u' => ⟨v, lt_of_lt_of_le hvu₂ hu₂u', hBDv⟩)
            · exact ⟨v', lt_trans htu₂ hv'u₂, hv's, hngD⟩
          · exact ⟨u_init, h_cut_lt_compl t ht_cut u_init hu_init_compl, hui_s, hBD_init⟩
      have h_def_right : gap_definable_on_right M atomMap γ_gap D :=
        ⟨h_D_compl_cofinal, h_no_init_cut_D⟩
      have h_r_def : r_definable_gap M atomMap γ_gap r :=
        ⟨D, hD, Or.inr h_def_right⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
      refine ⟨γ, ?_, h_def_right, ?_, ?_⟩
      · have hm_compl : m ∈ compl := h_compl_uc s m hs_in_compl (le_of_lt hsm)
        show @GT.gt (ExtendedCarrier M atomMap r) _ (extendPoint m) (Sum.inr γ)
        exact ⟨fun h => h hm_compl, fun h => h hm_compl⟩
      · intro u hum hu_not_cut
        have hu_compl : u ∈ compl := by by_contra h'; exact hu_not_cut h'
        by_cases hus : u < s
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_compl u hu_compl hus).2
        · push_neg at hus
          rcases eq_or_lt_of_le hus with rfl | hsu
          · exact (stavi_truth_mu_at_point s D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hsu hum)
      · -- U'(A,B)^mu at γ: extend FO table of U'(A,B)(s) from (s, s₂) to (γ, s₂)
        obtain ⟨s₂, hss₂, h_body_AB, ⟨wf_AB, hswf, hwfs₂, hBwf_AB⟩,
                ⟨wi_AB, hswi, hwis₂, hBwi_AB⟩⟩ := hUntl_s
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
        refine ⟨extendPoint s₂, ?_, ?_, ?_, ?_⟩
        · -- Sum.inr γ < extendPoint s₂: s₂ > s > γ (s₂ ∉ cut)
          have hs₂_compl : s₂ ∈ compl := h_compl_uc s s₂ hs_in_compl (le_of_lt hss₂)
          exact ⟨fun h => h hs₂_compl, fun h => h hs₂_compl⟩
        · -- Condition (1): ∀ mu-point u ∈ (γ, s₂), FO body
          intro u hγu hus₂ hmu
          obtain ⟨u_pt, rfl⟩ := hmu
          have hu_pt_not_cut : u_pt ∉ γ_gap.cut := by
            intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
          have hu_pt_compl : u_pt ∈ compl := by by_contra h'; exact hu_pt_not_cut h'
          have hu_pt_s₂ : u_pt < s₂ := (extendPoint_lt_iff u_pt s₂).mp hus₂
          by_cases hus : u_pt < s
          · -- u_pt ∈ (γ, s): complement point below s. B holds from h_bD_at_compl.
            left
            refine ⟨extendPoint s, (extendPoint_lt_iff u_pt s).mpr hus, ⟨s, rfl⟩,
              fun w hγw hws hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_pt_s : w_pt < s := (extendPoint_lt_iff w_pt s).mp hws
            have hw_pt_not_cut : w_pt ∉ γ_gap.cut := by
              intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
            have hw_pt_compl : w_pt ∈ compl := by by_contra h'; exact hw_pt_not_cut h'
            exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_compl w_pt hw_pt_compl hw_pt_s).1
          · -- u_pt ≥ s: use h_body_AB from U'(A,B)(s)
            push_neg at hus
            rcases eq_or_lt_of_le hus with rfl | hsu
            · -- u_pt = s: B-cofinal using wi_AB
              left
              refine ⟨extendPoint wi_AB, (extendPoint_lt_iff s wi_AB).mpr hswi, ⟨wi_AB, rfl⟩,
                fun w hγw hwwi hmu_w => ?_⟩
              obtain ⟨w_pt, rfl⟩ := hmu_w
              have hw_pt_wi : w_pt < wi_AB := (extendPoint_lt_iff w_pt wi_AB).mp hwwi
              have hw_pt_not_cut : w_pt ∉ γ_gap.cut := by
                intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
              have hw_pt_compl : w_pt ∈ compl := by by_contra h'; exact hw_pt_not_cut h'
              by_cases hws : w_pt < s
              · exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_compl w_pt hw_pt_compl hws).1
              · push_neg at hws
                rcases eq_or_lt_of_le hws with rfl | hsw
                · exact (stavi_truth_mu_at_point s B).mpr hBs
                · exact (stavi_truth_mu_at_point w_pt B).mpr (hBwi_AB w_pt hsw hw_pt_wi)
            · -- u_pt > s: use h_body_AB
              cases h_body_AB u_pt hsu hu_pt_s₂ with
              | inl h_cof =>
                left
                obtain ⟨v, hu_v, hBv⟩ := h_cof
                refine ⟨extendPoint v, (extendPoint_lt_iff u_pt v).mpr hu_v, ⟨v, rfl⟩,
                  fun w hγw hwv hmu_w => ?_⟩
                obtain ⟨w_pt, rfl⟩ := hmu_w
                have hw_pt_v : w_pt < v := (extendPoint_lt_iff w_pt v).mp hwv
                have hw_pt_not_cut : w_pt ∉ γ_gap.cut := by
                  intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
                have hw_pt_compl : w_pt ∈ compl := by by_contra h'; exact hw_pt_not_cut h'
                by_cases hws : w_pt < s
                · exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_compl w_pt hw_pt_compl hws).1
                · push_neg at hws
                  rcases eq_or_lt_of_le hws with rfl | hsw
                  · exact (stavi_truth_mu_at_point s B).mpr hBs
                  · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hsw hw_pt_v)
              | inr h_right =>
                right
                obtain ⟨hA_above, v', hmv', hv'u, hBv'⟩ := h_right
                refine ⟨fun v hv hvs hmu_v => ?_, ?_⟩
                · obtain ⟨v_pt, rfl⟩ := hmu_v
                  exact (stavi_truth_mu_at_point v_pt A).mpr
                    (hA_above v_pt ((extendPoint_lt_iff u_pt v_pt).mp hv)
                      ((extendPoint_lt_iff v_pt s₂).mp hvs))
                · refine ⟨extendPoint v', ?_, (extendPoint_lt_iff v' u_pt).mpr hv'u,
                    ⟨v', rfl⟩, mt (stavi_truth_mu_at_point v' B).mp hBv'⟩
                  have hv'_compl : v' ∈ compl := h_compl_uc s v' hs_in_compl (le_of_lt hmv')
                  exact ⟨fun h => h hv'_compl, fun h => h hv'_compl⟩
        · -- Condition (2): ∃ mu-point ∈ (γ, s₂) with ¬B^mu
          have hwf_compl : wf_AB ∈ compl := h_compl_uc s wf_AB hs_in_compl (le_of_lt hswf)
          refine ⟨extendPoint wf_AB, ?_, (extendPoint_lt_iff wf_AB s₂).mpr hwfs₂,
            ⟨wf_AB, rfl⟩, mt (stavi_truth_mu_at_point wf_AB B).mp hBwf_AB⟩
          exact ⟨fun h => h hwf_compl, fun h => h hwf_compl⟩
        · -- Condition (3): ∃ mu-point ∈ (γ, s₂) with B^mu initial
          have hwi_compl : wi_AB ∈ compl := h_compl_uc s wi_AB hs_in_compl (le_of_lt hswi)
          refine ⟨extendPoint wi_AB, ?_, (extendPoint_lt_iff wi_AB s₂).mpr hwis₂,
            ⟨wi_AB, rfl⟩, fun v hγv hvwi hmu_v => ?_⟩
          · exact ⟨fun h => h hwi_compl, fun h => h hwi_compl⟩
          · obtain ⟨v_pt, rfl⟩ := hmu_v
            have hv_pt_wi : v_pt < wi_AB := (extendPoint_lt_iff v_pt wi_AB).mp hvwi
            have hv_pt_not_cut : v_pt ∉ γ_gap.cut := by
              intro h; exact not_lt.mpr (show extendPoint v_pt ≤ Sum.inr γ from h) hγv
            have hv_pt_compl : v_pt ∈ compl := by by_contra h'; exact hv_pt_not_cut h'
            by_cases hvs : v_pt < s
            · exact (stavi_truth_mu_at_point v_pt B).mpr (h_bD_at_compl v_pt hv_pt_compl hvs).1
            · push_neg at hvs
              rcases eq_or_lt_of_le hvs with rfl | hsv
              · exact (stavi_truth_mu_at_point s B).mpr hBs
              · exact (stavi_truth_mu_at_point v_pt B).mpr (hBwi_AB v_pt hsv hv_pt_wi)
    · -- Backward: gap below m with U'(A,B)^mu → std_snce(compound, D)(m)
      -- Mirrors base.untl backward with U'(A,B) replacing U(f,g)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth] at hUA
      obtain ⟨s_sa, hs_sa_γ, h_body_sa, ⟨wf_sa, hs_wf, hwf_sa, ⟨wf_pt, rfl⟩, hBwf_sa⟩,
              ⟨wi_sa, hs_wi, hwi_sa, ⟨wi_pt, rfl⟩, hBwi_sa⟩⟩ := hUA
      -- wf_pt, wi_pt are complement points (above gap, between γ and s_sa)
      have hwf_not_cut : wf_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wf_pt γ).mpr h) hs_wf
      have hwi_not_cut : wi_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wi_pt γ).mpr h) hs_wi
      have hm_not_cut : m ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
      -- Find complement point s below m, wf_pt, wi_pt
      have ⟨s, hs_not_cut, hsm, hswf, hswi⟩ :
          ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < wf_pt ∧ s < wi_pt := by
        -- Pick any complement point below all three
        have ⟨s₁, hs₁_not, hs₁_m⟩ : ∃ s₁, s₁ ∉ γ.val.cut ∧ s₁ < m := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨m, hm_not_cut, fun z hz => h_all z hz⟩
        have ⟨s₂, hs₂_not, hs₂_wf⟩ : ∃ s₂, s₂ ∉ γ.val.cut ∧ s₂ < wf_pt := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨wf_pt, hwf_not_cut, fun z hz => h_all z hz⟩
        have ⟨s₃, hs₃_not, hs₃_wi⟩ : ∃ s₃, s₃ ∉ γ.val.cut ∧ s₃ < wi_pt := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨wi_pt, hwi_not_cut, fun z hz => h_all z hz⟩
        -- Take the minimum of s₁, s₂, s₃ — but simpler: find a complement point below all
        have ⟨s₀, hs₀_not, hs₀_min⟩ : ∃ s₀, s₀ ∉ γ.val.cut ∧
            s₀ < min s₁ (min s₂ s₃) := by
          have hmin_not : min s₁ (min s₂ s₃) ∉ γ.val.cut := by
            intro h_in
            rcases le_or_lt s₁ (min s₂ s₃) with h | h
            · simp only [min_eq_left h] at h_in; exact hs₁_not h_in
            · simp only [min_eq_right (le_of_lt h)] at h_in
              rcases le_or_lt s₂ s₃ with h' | h'
              · simp only [min_eq_left h'] at h_in; exact hs₂_not h_in
              · simp only [min_eq_right (le_of_lt h')] at h_in; exact hs₃_not h_in
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨min s₁ (min s₂ s₃), hmin_not,
            fun z hz => h_all z hz⟩
        exact ⟨s₀, hs₀_not,
          lt_of_lt_of_le hs₀_min (le_trans (min_le_left _ _) (le_of_lt hs₁_m)),
          lt_of_lt_of_le hs₀_min (le_trans (min_le_right _ _) (le_trans (min_le_left _ _) (le_of_lt hs₂_wf))),
          lt_of_lt_of_le hs₀_min (le_trans (min_le_right _ _) (le_trans (min_le_right _ _) (le_of_lt hs₃_wi)))⟩
      have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint s) := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
      -- D(s) from D-between
      have hDs : stavi_temporal_truth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
      -- B(s) from U' init condition: s between γ and wi_pt
      have hBs : stavi_temporal_truth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hBwi_sa (extendPoint s) hγs
            ((extendPoint_lt_iff s wi_pt).mpr hswi) ⟨s, rfl⟩)
      -- U'(A,B)(s): restrict FO table from (γ, s_sa) to (s, s_sa)
      have hUA_s : stavi_temporal_truth M atomMap s (.stavi_untl A B) := by
        apply (stavi_truth_mu_at_point s (.stavi_untl A B)).mp
        show stavi_temporal_truth_mu M atomMap r (extendPoint s) (.stavi_untl A B)
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
        refine ⟨s_sa, lt_trans ((extendPoint_lt_iff s wf_pt).mpr hswf) hwf_sa, ?_, ?_, ?_⟩
        · intro u hsu hus_sa hmu
          cases h_body_sa u (lt_trans hγs hsu) hus_sa hmu with
          | inl h_cof =>
            left
            obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
            exact ⟨v, hvu, hmu_v, fun w hsw hwv hmu_w => hBv w (lt_trans hγs hsw) hwv hmu_w⟩
          | inr h_right =>
            right
            obtain ⟨hA_below, v', hv'γ, hv'u, hmu_v', hBv'⟩ := h_right
            have hv's : extendPoint s < v' := by
              by_contra h; push_neg at h
              exact hBv' (hBwi_sa v' hv'γ
                (lt_of_le_of_lt h ((extendPoint_lt_iff s wi_pt).mpr hswi)) hmu_v')
            exact ⟨hA_below, v', hv's, hv'u, hmu_v', hBv'⟩
        · exact ⟨extendPoint wf_pt, (extendPoint_lt_iff s wf_pt).mpr hswf,
            hwf_sa, ⟨wf_pt, rfl⟩, hBwf_sa⟩
        · exact ⟨extendPoint wi_pt, (extendPoint_lt_iff s wi_pt).mpr hswi,
            hwi_sa, ⟨wi_pt, rfl⟩,
            fun v hsv hvwi hmu => hBwi_sa v (lt_trans hγs hsv) hvwi hmu⟩
      -- D on (s, m)
      have hD_bet_sm : ∀ u, s < u → u < m → stavi_temporal_truth M atomMap u D := by
        intro u hsu hum
        have hu_not_cut : u ∉ γ.val.cut := by
          intro h; exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu))
            ((extendPoint_le_gap_iff u γ).mpr h)
        exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not_cut)
      -- Gap definability
      obtain ⟨⟨t_D, ht_D_not, hD_init⟩, h_no_final_D⟩ := hγ_def
      have h_cut_lt : ∀ x, x ∈ γ.val.cut → ∀ y, y ∉ γ.val.cut → x < y := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hy (γ.val.downward_closed x y hx h)
      have h_neg_final : ∀ t, t ∈ γ.val.cut →
          ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬stavi_temporal_truth M atomMap w D := by
        intro t ht; by_contra h_all; push_neg at h_all
        exact h_no_final_D ⟨t, ht, fun w htw hw_cut => h_all w hw_cut htw⟩
      have ⟨c₀, hc₀_cut⟩ : ∃ c₀, c₀ ∈ γ.val.cut := γ.val.nonempty
      have hc₀s : c₀ < s := h_cut_lt c₀ hc₀_cut s hs_not_cut
      have h_bD_compl : ∀ u, u < s → u ∉ γ.val.cut →
          stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D := by
        intro u hus hu_not_cut
        constructor
        · exact (stavi_truth_mu_at_point u B).mp
            (hBwi_sa (extendPoint u) ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
              (lt_trans ((extendPoint_lt_iff u s).mpr hus) ((extendPoint_lt_iff s wi_pt).mpr hswi))
              ⟨u, rfl⟩)
        · exact (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hus hsm) hu_not_cut)
      refine ⟨s, hsm, ⟨hDs, hBs, hUA_s, ?_, ?_⟩, hD_bet_sm⟩
      · -- S'(⊤, B∧D)(s): bound c₀ (a cut point below s)
        refine ⟨c₀, hc₀s, ?_, ?_, ?_⟩
        · -- Condition (1): body
          intro u hc₀u hus
          by_cases hu_not_cut : u ∉ γ.val.cut
          · left
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_not_cut, fun z hz => h_all z hz⟩
            exact ⟨y, hyu, fun w hyw hws =>
              h_bD_compl w hws (fun h_cut =>
                hy_not (γ.val.downward_closed w y h_cut (le_of_lt hyw)))⟩
          · push_neg at hu_not_cut
            right
            refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
            have ⟨y, hy_cut, huy⟩ : ∃ y, y ∈ γ.val.cut ∧ u < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨u, ⟨h_all, fun _ hb => hb hu_not_cut⟩, hu_not_cut⟩
            obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
            exact ⟨w, lt_of_lt_of_le huy hyw, h_cut_lt w hw_cut s hs_not_cut,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · -- Condition (2): ¬(B∧D) failure
          have ⟨y, hy_cut, hc₀y⟩ : ∃ y, y ∈ γ.val.cut ∧ c₀ < y := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨c₀, ⟨h_all, fun _ hb => hb hc₀_cut⟩, hc₀_cut⟩
          obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
          exact ⟨w, lt_of_lt_of_le hc₀y hyw, h_cut_lt w hw_cut s hs_not_cut,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · -- Condition (3): (B∧D) initial
          have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨s, hs_not_cut, fun z hz => h_all z hz⟩
          exact ⟨y, h_cut_lt c₀ hc₀_cut y hy_not, hys, fun v hyv hvs =>
            h_bD_compl v hvs (fun hv_cut =>
              hy_not (γ.val.downward_closed v y hv_cut (le_of_lt hyv)))⟩
      · -- ¬S'(D, B∧D)(s): two-step D-transfer contradiction
        intro ⟨s₁, hs₁s, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hs₁_uf, huf_s, hbD_fail⟩ := h_fail
        have huf_cut : u_fail ∈ γ.val.cut := by
          by_contra huf_not
          exact hbD_fail (h_bD_compl u_fail huf_s huf_not)
        have h_left_fails : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
            ¬(∃ v, v < u ∧ ∀ w, v < w → w < s →
              stavi_temporal_truth M atomMap w B ∧ stavi_temporal_truth M atomMap w D) := by
          intro u _ _ hu_cut ⟨v, hvu, hbDv⟩
          have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
          have ⟨y, hy_cut, hvy⟩ : ∃ y, y ∈ γ.val.cut ∧ v < y := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨v, ⟨h, fun _ hb => hb hv_cut⟩, hv_cut⟩
          obtain ⟨w', hw'_cut, hyw', hDw'⟩ := h_neg_final y hy_cut
          exact hDw' (hbDv w' (lt_of_lt_of_le hvy hyw')
            (h_cut_lt w' hw'_cut s hs_not_cut)).2
        have hD_all_cut : ∀ u, s₁ < u → u < s → u ∈ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hs₁u hus hu_cut
          have h_right_u := (h_body u hs₁u hus).resolve_left
            (h_left_fails u hs₁u hus hu_cut)
          obtain ⟨_, v', hv'u, hv's, hbD_v'⟩ := h_right_u
          have hv'_cut : v' ∈ γ.val.cut := by
            by_contra hv'_not; exact hbD_v' (h_bD_compl v' hv's hv'_not)
          have ⟨u', hu'_cut, huu'⟩ : ∃ u', u' ∈ γ.val.cut ∧ u < u' := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨u, ⟨h, fun _ hb => hb hu_cut⟩, hu_cut⟩
          have hu's : u' < s := h_cut_lt u' hu'_cut s hs_not_cut
          have h_right_u' := (h_body u' (lt_trans hs₁u huu') hu's).resolve_left
            (h_left_fails u' (lt_trans hs₁u huu') hu's hu'_cut)
          exact h_right_u'.1 u hs₁u huu'
        have hs₁_cut : s₁ ∈ γ.val.cut := by
          by_contra hs₁_not
          exact not_le.mpr (h_cut_lt u_fail huf_cut s₁ hs₁_not) (le_of_lt hs₁_uf)
        have ⟨t₀, ht₀_cut, hs₁t₀⟩ : ∃ t₀, t₀ ∈ γ.val.cut ∧ s₁ < t₀ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨s₁, ⟨h, fun _ hb => hb hs₁_cut⟩, hs₁_cut⟩
        exact h_no_final_D ⟨t₀, ht₀_cut, fun u ht₀u hu_cut =>
          hD_all_cut u (lt_of_lt_of_le hs₁t₀ ht₀u)
            (h_cut_lt u hu_cut s hs_not_cut) hu_cut⟩
  /-  -- wf_pt and wi_pt are complement points (above gap)
      have hwf_not_cut : wf_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wf_pt γ).mpr h) hwf_γ
      have hwi_not_cut : wi_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wi_pt γ).mpr h) hwi_γ
      -- m is a complement point (above gap)
      have hm_not_cut : m ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
      -- Find complement point s below m, below wf_pt and wi_pt
      have ⟨s, hs_not_cut, hsm, hswf, hswi⟩ :
          ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < wf_pt ∧ s < wi_pt := by
        -- complement has no min, so there are complement points below any complement point
        have ⟨s₁, hs₁_not, hs₁_min⟩ : ∃ s₁, s₁ ∉ γ.val.cut ∧
            s₁ < min (min wf_pt wi_pt) m := by
          have hmin_not : min (min wf_pt wi_pt) m ∉ γ.val.cut := by
            simp only [min_def]; split_ifs with h
            · simp only [min_def] at *; split_ifs with h' <;> assumption
            · exact hm_not_cut
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨min (min wf_pt wi_pt) m, hmin_not,
            fun z hz => h_all z hz⟩
        exact ⟨s₁, hs₁_not,
          lt_of_lt_of_le hs₁_min (min_le_right _ _),
          lt_of_lt_of_le hs₁_min (le_trans (min_le_left _ _) (min_le_left _ _)),
          lt_of_lt_of_le hs₁_min (le_trans (min_le_left _ _) (min_le_right _ _))⟩
      -- s_sa ≤ extendPoint s (s_sa is below or at s, since s ∉ cut means s > gap,
      -- and s_sa < gap = Sum.inr γ, so s_sa could be below or a gap itself)
      -- Actually, s_sa is below the gap (or at gap), and s is above the gap.
      -- So s_sa < Sum.inr γ ≤ extendPoint s? No: Sum.inr γ < extendPoint s
      -- because s ∉ cut. So s_sa < extendPoint s.
      have hs_sa_s : s_sa < extendPoint s := by
        calc s_sa < Sum.inr γ := hs_sa_γ
        _ < extendPoint s := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
      -- D(s) from D-between (s < m and s ∉ cut)
      have hDs : stavi_temporal_truth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
      -- B(s) from hBwi_sa (s is between s_sa and wi_pt)
      -- Hmm, hBwi_sa is the B-init condition: B at all mu-points in (s_sa, wi_pt).
      -- But wait, s < wi_pt and s_sa < s, so extendPoint s is between s_sa and extendPoint wi_pt.
      -- Actually hBwi_sa says: ∀ v, s_sa < v → v < extendPoint wi_pt → mu(v) → B(v)
      -- Wait, let me re-check. The goal structure showed:
      -- wi: ∃ u, s_1 < u ∧ u < s_1 ∧ ∀ v, s < v → v < u → B(v)
      -- Actually the FO table for U'(A,B)(s) has condition (3): ∃ wi_pt ∈ (s_sa, s₁),
      -- B on (wi_pt, s₁). So hBwi_sa : ∀ v, wi_pt < v → v < ? → B(v).
      -- Hmm, I need to re-read what hBwi_sa actually is. From the obtain:
      -- ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩ := hUA_mu
      -- This is from condition (3) of U'(A,B) FO table:
      -- ∃ wi, s_sa < wi ∧ wi < s₁ ∧ mu(wi) ∧ B on (s_sa, wi)
      -- Wait no, I need to look at the exact FO table structure. Let me check.
      -- Actually from the simp/obtain: the last condition gives
      -- ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩
      -- hBwi_sa is probably: ∀ v, s_sa < v → v < extendPoint wi_pt → B^mu(v)
      -- Wait, the Stavi Until FO table condition (3) is: ∃ u_init, B on (s_sa, u_init).
      -- So hBwi_sa : ∀ v, s_sa < v → v < extendPoint wi_pt → B(v)... or similar.
      --
      -- Let me look at how the left proof handles this. In the left proof for stavi_snce backward
      -- (lines 5823-5929 which I just uncommented), the B condition is handled via hBwi_sa.
      --
      -- Actually, I need to re-check the exact structure. The obtain pattern was:
      -- ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩
      -- In the U' FO table, condition (3) = ∃ u_init ∈ (s_sa, s₁), B-init.
      -- So wi_sa = u_init position, hs_wi = s_sa < wi_sa, hwi_γ = wi_sa < s₁ = Sum.inr γ,
      -- hmu_wi = ⟨wi_pt, rfl⟩ (it's a mu-point), hBwi_sa = B on final segment.
      -- Actually, the FO table condition (3) for U' says:
      -- ∃ u_init, s < u_init ∧ u_init < bound ∧ ∀ v, s < v → v < u_init → D'(v)
      -- Wait no, the condition (3) is B-init: B holds on (s, u_init).
      -- Actually hBwi_sa is: ∀ v, s_sa < v → v < extendPoint wi_pt → B(v)... wait,
      -- this doesn't look right for "B on init segment from s_sa to wi_pt".
      -- Let me check what the actual obtain pattern destructures.
      --
      -- The FO table for U'(A,B) at point s is:
      -- ∃ s₁ > s, body ∧ fail ∧ init
      -- where:
      -- body = ∀ u ∈ (s, s₁), (cofinal B) ∨ (A below ∧ ¬B witness)
      -- fail = ∃ u ∈ (s, s₁), ¬B(u)
      -- init = ∃ u ∈ (s, s₁), B on (s, u) [= ∀ v ∈ (s, u), B(v)]
      --
      -- At gap γ, this becomes U'(A,B)^mu(γ):
      -- ∃ s_sa > γ, body_mu ∧ fail_mu ∧ init_mu
      -- s_sa was obtained as the bound.
      -- init_mu: ∃ wi_sa ∈ (γ, s_sa), mu(wi_sa) ∧ ∀ v, γ < v → v < wi_sa → mu(v) → B^mu(v)
      -- Hmm, wait. Actually, B on initial segment means ∀ v ∈ (γ, wi_sa), B(v).
      -- In mu form at gap, this is:
      -- ∃ wi_sa, s_sa_lower < wi_sa ∧ wi_sa < s_sa_upper ∧ mu(wi_sa) ∧
      --   ∀ v, s_sa_lower < v → v < wi_sa → B^mu(v) [wait, or just B(v)?]
      --
      -- Actually, looking at the goal output more carefully:
      -- The obtain pattern for U'(A,B)^mu(γ) was:
      -- ⟨s_sa, hs_sa_γ, h_body_sa, ⟨wf_sa, hs_wf, hwf_γ, hmu_wf, hBwf_sa⟩,
      --         ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩⟩
      --
      -- This destructures the expanded FO table. Based on the goal, condition (3) gives:
      -- ∃ u, s₁ < u ∧ u < s₁ ∧ ∀ v, s < v → v < u → B(v)
      -- In our case at gap: ∃ wi_sa > Sum.inr γ, wi_sa < s_sa, mu(wi_sa),
      --   ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → B^mu(v)
      --
      -- Wait, I'm getting confused because this is in the wrong direction.
      -- Let me just check: hBwi_sa type.
      -- From the obtain: hBwi_sa is the last element after hmu_wi.
      -- The FO table init condition for U'(A,B) gives:
      -- ∃ u_init ∈ (s_sa, s₁), ∀ v ∈ (s_sa, u_init), B(v)
      -- At the gap level, s₁ = Sum.inr γ (the gap, which is the lower bound since U' goes upward).
      -- Wait, U'(A,B) at gap γ means the FO table is evaluated at Sum.inr γ.
      -- But Sum.inr γ < extendPoint m means the gap is BELOW m. U' looks to the FUTURE (above).
      -- So the FO table for U'(A,B) at gap γ looks ABOVE γ:
      -- ∃ s_sa > Sum.inr γ, body ∧ fail ∧ init
      -- where body, fail, init are about the interval (Sum.inr γ, s_sa).
      --
      -- So hBwi_sa should be:
      -- ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → mu(v) → B^mu(v)
      -- Wait, no. The FO table init condition is:
      -- ∃ u_init ∈ (Sum.inr γ, s_sa), B on (Sum.inr γ, u_init)
      -- And "B on (Sum.inr γ, u_init)" means ∀ v, Sum.inr γ < v → v < u_init → B(v)
      -- In mu form: ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → B^mu(v)... no.
      -- The FO table at a gap has mu-quantification. The init condition becomes:
      -- ∃ wi, Sum.inr γ < wi ∧ wi < s_sa ∧ mu(wi) ∧
      --   ∀ v, Sum.inr γ < v → v < wi ∧ mu(v) → B^mu(v)
      -- Hmm, actually I'm not sure about the exact mu-quantification pattern.
      --
      -- Actually, from the original obtain, the structure matches stavi_temporal_truth
      -- after simp. So hBwi_sa is probably just:
      -- ∀ v, Sum.inr γ < v → v < extendPoint wi_pt → stavi_temporal_truth M atomMap (carrier_of v) B
      -- But this doesn't have mu-quantification...
      --
      -- I think the actual type depends on how stavi_temporal_truth is defined for U'.
      -- Let me just use lean_hover_info to check.

      -- Actually, let me take a simpler approach. I know from the left proof template
      -- that B(s) can be obtained. In the left proof, hgs is proved using hg_mu
      -- (g on (γ, t_pt)) with s between γ and t_pt. For the right version, I need
      -- B(s) from the U'(A,B) FO table. Since s is between γ and wi_pt (in the complement),
      -- and hBwi_sa gives B on the initial segment, B(s) should follow.
      --
      -- Let me just write the proof and check with lean_goal.
      -/
  | stavi_snce A B _ _ =>
    -- right_formula (.stavi_snce A B) D = S'(B ∧ S'(A,B), D)
    -- Mirrors left's stavi_untl case with stavi_snce_gap_detection
    simp only [right_formula]
    constructor
    · intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩ :=
        (stavi_snce_gap_detection (.conj B (.stavi_snce A B)) D hD m).mp h
      have hSA_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
          stavi_temporal_truth M atomMap u (.stavi_snce A B) :=
        fun u hu hus => (hX_cut u hu hus).2
      have hB_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
          stavi_temporal_truth M atomMap u B :=
        fun u hu hus => (hX_cut u hu hus).1
      -- S'(A,B)^mu at γ from S'(A,B) at cut points: mirrors left stavi_untl forward
      -- Pick cut point u₁ above s_bound
      have ⟨u₁, hu₁_in, hu₁s⟩ : ∃ u₁, u₁ ∈ γ.val.cut ∧ s_bound < u₁ := by
        by_contra h_all; push_neg at h_all
        exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
      -- FO table of S'(A,B) at u₁
      have hSA_u₁ := hSA_cut u₁ hu₁_in hu₁s
      simp only [stavi_temporal_truth] at hSA_u₁
      obtain ⟨s₁, hs₁u₁, h_body₁, ⟨wf, hs₁wf, hwfu₁, hBwf⟩,
              ⟨wi, hs₁wi, hwiu₁, hBwi⟩⟩ := hSA_u₁
      -- s₁ ∈ cut (s₁ < u₁ ∈ cut, downward closure)
      have hs₁_in : s₁ ∈ γ.val.cut :=
        γ.val.downward_closed u₁ s₁ hu₁_in (le_of_lt hs₁u₁)
      -- wf ∈ cut (wf < u₁)
      have hwf_in : wf ∈ γ.val.cut :=
        γ.val.downward_closed u₁ wf hu₁_in (le_of_lt hwfu₁)
      -- wi ∈ cut (wi < u₁)
      have hwi_in : wi ∈ γ.val.cut :=
        γ.val.downward_closed u₁ wi hu₁_in (le_of_lt hwiu₁)
      -- Construct S'(A,B)^mu(Sum.inr γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
      refine ⟨extendPoint s₁, ?_, ?_, ?_, ?_⟩
      · -- extendPoint s₁ < Sum.inr γ: s₁ ∈ cut
        exact ⟨hs₁_in, fun h => h hs₁_in⟩
      · -- Condition (1): ∀ mu-point u ∈ (extendPoint s₁, Sum.inr γ), FO body
        intro u hs₁u huγ hmu
        obtain ⟨u_pt, rfl⟩ := hmu
        have hu_pt_in : u_pt ∈ γ.val.cut :=
          (extendPoint_le_gap_iff u_pt γ).mp (le_of_lt huγ)
        have hu_pt_s₁ : s₁ < u_pt := (extendPoint_lt_iff s₁ u_pt).mp hs₁u
        by_cases hu_pt_u₁ : u_pt < u₁
        · -- u_pt between s₁ and u₁: use h_body₁
          cases h_body₁ u_pt hu_pt_s₁ hu_pt_u₁ with
          | inl h_cof =>
            left
            obtain ⟨v, hvu_pt, hBv⟩ := h_cof
            refine ⟨extendPoint v, (extendPoint_lt_iff v u_pt).mpr hvu_pt, ⟨v, rfl⟩,
              fun w hvw hwγ hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_pt_in : w_pt ∈ γ.val.cut :=
              (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
            have hw_pt_v : v < w_pt := (extendPoint_lt_iff v w_pt).mp hvw
            by_cases hwu₁ : w_pt < u₁
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hw_pt_v hwu₁)
            · push_neg at hwu₁
              have hw_sb : s_bound < w_pt := lt_of_lt_of_le hu₁s hwu₁
              exact (stavi_truth_mu_at_point w_pt B).mpr (hB_cut w_pt hw_pt_in hw_sb)
          | inr h_right =>
            right
            obtain ⟨hA_below, v', hv'u_pt, hv'u₁, hBv'⟩ := h_right
            refine ⟨fun v hv hvs hmu_v => ?_, ?_⟩
            · obtain ⟨v_pt, rfl⟩ := hmu_v
              exact (stavi_truth_mu_at_point v_pt A).mpr
                (hA_below v_pt ((extendPoint_lt_iff s₁ v_pt).mp hv)
                  ((extendPoint_lt_iff v_pt u_pt).mp hvs))
            · refine ⟨extendPoint v', (extendPoint_lt_iff u_pt v').mpr hv'u_pt, ?_,
                ⟨v', rfl⟩, mt (stavi_truth_mu_at_point v' B).mp hBv'⟩
              have hv'_in : v' ∈ γ.val.cut :=
                γ.val.downward_closed u₁ v' hu₁_in (le_of_lt hv'u₁)
              exact ⟨hv'_in, fun h => h hv'_in⟩
        · -- u_pt ≥ u₁: B holds at u_pt from hB_cut. Use LEFT disjunct.
          push_neg at hu_pt_u₁
          left
          refine ⟨extendPoint wi, (extendPoint_lt_iff wi u_pt).mpr (lt_of_lt_of_le hwiu₁ hu_pt_u₁),
            ⟨wi, rfl⟩, fun w hwwi hwγ hmu_w => ?_⟩
          obtain ⟨w_pt, rfl⟩ := hmu_w
          have hw_pt_in : w_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
          have hw_pt_wi : wi < w_pt := (extendPoint_lt_iff wi w_pt).mp hwwi
          by_cases hwu₁ : w_pt < u₁
          · exact (stavi_truth_mu_at_point w_pt B).mpr (hBwi w_pt hw_pt_wi hwu₁)
          · push_neg at hwu₁
            exact (stavi_truth_mu_at_point w_pt B).mpr
              (hB_cut w_pt hw_pt_in (lt_of_lt_of_le hu₁s hwu₁))
      · -- Condition (2): ∃ mu-point in (s₁, γ) with ¬B^mu
        have hwf_lt_γ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint wf) (Sum.inr γ) := ⟨hwf_in, fun h => h hwf_in⟩
        refine ⟨extendPoint wf, (extendPoint_lt_iff s₁ wf).mpr hs₁wf,
          hwf_lt_γ,
          ⟨wf, rfl⟩, mt (stavi_truth_mu_at_point wf B).mp hBwf⟩
      · -- Condition (3): ∃ mu-point in (s₁, γ) with B^mu on final segment to γ
        have hwi_lt_γ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint wi) (Sum.inr γ) := ⟨hwi_in, fun h => h hwi_in⟩
        refine ⟨extendPoint wi, (extendPoint_lt_iff s₁ wi).mpr hs₁wi,
          hwi_lt_γ,
          ⟨wi, rfl⟩, fun v hwiv hvγ hmu_v => ?_⟩
        · obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_pt_in : v_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff v_pt γ).mp (le_of_lt hvγ)
          have hv_pt_wi : wi < v_pt := (extendPoint_lt_iff wi v_pt).mp hwiv
          by_cases hvu₁ : v_pt < u₁
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBwi v_pt hv_pt_wi hvu₁)
          · push_neg at hvu₁
            exact (stavi_truth_mu_at_point v_pt B).mpr
              (hB_cut v_pt hv_pt_in (lt_of_lt_of_le hu₁s hvu₁))
    · -- Backward: stavi_snce backward direction (restored from comment)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
      simp only [stavi_temporal_truth_mu] at hSA
      obtain ⟨s_sa, hs_sa_γ, h_body_sa, ⟨wf_sa, hs_wf, hwf_γ, hmu_wf, hBwf_sa⟩,
              ⟨wi_sa, hs_wi, hwi_γ, hmu_wi, hBwi_sa⟩⟩ := hSA
      obtain ⟨wf_pt, rfl⟩ := hmu_wf
      obtain ⟨wi_pt, rfl⟩ := hmu_wi
      have hwf_in : wf_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff wf_pt γ).mp (le_of_lt hwf_γ)
      have hwi_in : wi_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff wi_pt γ).mp (le_of_lt hwi_γ)
      -- Get a carrier bound s_pt below s_sa (and below both wf_pt, wi_pt)
      have ⟨s_pt, hs_pt_wf, hs_pt_wi, hs_sa_s_pt⟩ :
          ∃ s_pt : M.carrier, s_pt < wf_pt ∧ s_pt < wi_pt ∧ s_sa ≤ extendPoint s_pt := by
        rcases s_sa with s₁ | g_sa
        · refine ⟨s₁, (extendPoint_lt_iff s₁ wf_pt).mp hs_wf,
            (extendPoint_lt_iff s₁ wi_pt).mp hs_wi, le_rfl⟩
        · have hwf_not : wf_pt ∉ g_sa.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wf_pt g_sa).mpr h) hs_wf
          have hwi_not : wi_pt ∉ g_sa.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff wi_pt g_sa).mpr h) hs_wi
          have hmin_not : min wf_pt wi_pt ∉ g_sa.val.cut := by
            rcases le_or_lt wf_pt wi_pt with h | h
            · simp [min_eq_left h]; exact hwf_not
            · simp [min_eq_right (le_of_lt h)]; exact hwi_not
          have ⟨y, hy_not, hy_min⟩ : ∃ y, y ∉ g_sa.val.cut ∧ y < min wf_pt wi_pt := by
            by_contra h_all; push_neg at h_all
            exact g_sa.val.complement_no_min ⟨min wf_pt wi_pt, hmin_not,
              fun z hz => h_all z hz⟩
          exact ⟨y, lt_of_lt_of_le hy_min (min_le_left _ _),
            lt_of_lt_of_le hy_min (min_le_right _ _),
            le_of_lt (show @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr g_sa) (extendPoint y) from ⟨hy_not, hy_not⟩)⟩
      -- Pick s_bound = max(wf_pt, wi_pt). Both ∈ γ.cut.
      let s_bound := max wf_pt wi_pt
      have hs_bound_in : s_bound ∈ γ.val.cut := by
        simp only [s_bound, max_def]; split
        · exact hwi_in
        · exact hwf_in
      -- Apply stavi_snce_gap_detection.mpr
      apply (stavi_snce_gap_detection (.conj B (.stavi_snce A B)) D hD m).mpr
      refine ⟨γ, s_bound, hγ_lt, hs_bound_in, hγ_def, hγ_bet, fun u hu_in hu_sb => ?_⟩
      -- u is a cut point with s_bound < u, so wf_pt < u AND wi_pt < u
      have hu_wf : wf_pt < u := lt_of_le_of_lt (le_max_left wf_pt wi_pt) hu_sb
      have hu_wi : wi_pt < u := lt_of_le_of_lt (le_max_right wf_pt wi_pt) hu_sb
      have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint u) (Sum.inr γ) := ⟨hu_in, fun h => h hu_in⟩
      simp only [stavi_temporal_truth]
      constructor
      · -- B(u): from hBwi_sa, u is between wi_pt and γ
        exact (stavi_truth_mu_at_point u B).mp
          (hBwi_sa (extendPoint u) ((extendPoint_lt_iff wi_pt u).mpr hu_wi) huγ ⟨u, rfl⟩)
      · -- S'(A,B)(u): FO table at u with bound s_pt
        refine ⟨s_pt, lt_trans hs_pt_wf hu_wf, ?_, ?_, ?_⟩
        · -- Body: ∀ w ∈ (s_pt, u), disjunction
          intro w hsw hwu
          have hw_in : w ∈ γ.val.cut :=
            γ.val.downward_closed u w hu_in (le_of_lt hwu)
          have hwγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint w) (Sum.inr γ) := ⟨hw_in, fun h => h hw_in⟩
          have hs_sa_w : s_sa < extendPoint w :=
            lt_of_le_of_lt hs_sa_s_pt ((extendPoint_lt_iff s_pt w).mpr hsw)
          have h_disj := h_body_sa (extendPoint w) hs_sa_w hwγ ⟨w, rfl⟩
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, hvw, hmu_v, hBv⟩ := h_cof
            obtain ⟨v_pt, rfl⟩ := hmu_v
            refine ⟨v_pt, (extendPoint_lt_iff v_pt w).mp hvw, fun z hzv hzu => ?_⟩
            have hz_in : z ∈ γ.val.cut :=
              γ.val.downward_closed u z hu_in (le_of_lt hzu)
            have hzγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (extendPoint z) (Sum.inr γ) := ⟨hz_in, fun h => h hz_in⟩
            exact (stavi_truth_mu_at_point z B).mp
              (hBv (extendPoint z) ((extendPoint_lt_iff v_pt z).mpr hzv) hzγ ⟨z, rfl⟩)
          | inr h_take =>
            obtain ⟨hA_below, v', hv'_above_w, hv'_below_γ, hmu_v', hBv'_neg⟩ := h_take
            obtain ⟨v'_pt, rfl⟩ := hmu_v'
            have hv'_w : w < v'_pt := (extendPoint_lt_iff w v'_pt).mp hv'_above_w
            have hv'_in : v'_pt ∈ γ.val.cut :=
              (extendPoint_le_gap_iff v'_pt γ).mp (le_of_lt hv'_below_γ)
            by_cases hv'u : v'_pt < u
            · -- v'_pt between w and u: use RIGHT disjunct with v'_pt as ¬B witness
              right
              constructor
              · intro v hsv hvu
                exact (stavi_truth_mu_at_point v A).mp
                  (hA_below (extendPoint v) (lt_of_le_of_lt hs_sa_s_pt ((extendPoint_lt_iff s_pt v).mpr hsv))
                    ((extendPoint_lt_iff v w).mpr hvu) ⟨v, rfl⟩)
              · exact ⟨v'_pt, hv'_w, hv'u,
                  mt (stavi_truth_mu_at_point v'_pt B).mpr hBv'_neg⟩
            · -- v'_pt ≥ u > wi_pt: B(v'_pt) from hBwi_sa contradicts ¬B(v'_pt)
              push_neg at hv'u
              exfalso
              exact hBv'_neg
                (hBwi_sa (extendPoint v'_pt)
                  ((extendPoint_lt_iff wi_pt v'_pt).mpr (lt_of_lt_of_le hu_wi hv'u))
                  ⟨hv'_in, fun h => h hv'_in⟩ ⟨v'_pt, rfl⟩)
        · -- Condition (2): ¬B witness
          exact ⟨wf_pt, hs_pt_wf, hu_wf, mt (stavi_truth_mu_at_point wf_pt B).mpr hBwf_sa⟩
        · -- Condition (3): B on final segment
          exact ⟨wi_pt, hs_pt_wi, hu_wi, fun v hwiv hvu =>
            (stavi_truth_mu_at_point v B).mp
              (hBwi_sa (extendPoint v) ((extendPoint_lt_iff wi_pt v).mpr hwiv)
                (⟨γ.val.downward_closed u v hu_in (le_of_lt hvu),
                  fun h => h (γ.val.downward_closed u v hu_in (le_of_lt hvu))⟩)
                ⟨v, rfl⟩)⟩
  | std_untl A B _ _ =>
    -- right_formula (.std_untl A B) D = .std_snce compound D
    -- compound = D ∧ B ∧ U(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D)
    -- Same compound decomposition as stavi_untl with U(A,B) instead of U'(A,B)
    simp only [right_formula]
    rw [stavi_truth_mu_at_point m (.std_snce _ D)]
    simp only [stavi_temporal_truth]
    constructor
    · -- Forward: std_snce(compound, D)(m) → gap conditions
      intro ⟨s, hsm, ⟨hDs, hBs, hUntl_s, hS'_BD_s, hNotS'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hs₁s, h_body, h_fail, h_init⟩ := hS'_BD_s
      obtain ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hs₁_ui, hui_s, hBD_init⟩ := h_init
      -- Gap construction (identical to stavi_untl compound decomposition)
      let bD : M.carrier → Prop := fun u =>
        stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D
      let compl : Set M.carrier :=
        {x | ∀ u, u < s → x ≤ u → ∃ v, v < u ∧ ∀ w, v < w → w < s → bD w}
      have hs_in_compl : s ∈ compl :=
        fun u hus hsu => absurd (lt_of_le_of_lt hsu hus) (lt_irrefl s)
      have hu_fail_not_compl : u_fail ∉ compl := by
        intro h; obtain ⟨v, hvuf, hBDv⟩ := h u_fail huf_s le_rfl
        exact hBD_fail (hBDv u_fail hvuf huf_s)
      have h_compl_gt_uf : ∀ x ∈ compl, u_fail < x := by
        intro x hx; by_contra h; push_neg at h
        exact hu_fail_not_compl (fun u hus huf => hx u hus (le_trans h huf))
      have h_compl_uc : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
        fun x y hx hxy u hus hyu => hx u hus (le_trans (le_trans hxy hyu) le_rfl)
      let cut : Set M.carrier := {x | x ∉ compl}
      have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut := by
        intro x y hx hyx hy; exact hx (h_compl_uc y x hy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; have := h ▸ Set.mem_univ s; exact this hs_in_compl
      have h_cofinal_propagate :
          ∀ u, s₁ < u → u < s →
          (∀ w, u < w → w < s → ∃ v, v < w ∧ ∀ z, v < z → z < s → bD z) →
          ∃ v, v < u ∧ ∀ z, v < z → z < s → bD z := by
        intro u hs₁u hus h_above
        cases h_body u hs₁u hus with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', huv', hv's, hBDv'⟩ := h
          obtain ⟨v₂, hv₂v', hBDv₂⟩ := h_above v' huv' hv's
          exact absurd (hBDv₂ v' hv₂v' hv's) hBDv'
      have hu_init_compl : u_init ∈ compl := by
        intro u hus huu_init
        rcases eq_or_lt_of_le huu_init with rfl | hlt
        · cases h_body u_init hs₁_ui hui_s with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hv'ui, hv's, hBDv'⟩ := h
            exact absurd (hBD_init v' hv'ui hv's) hBDv'
        · exact ⟨u_init, hlt, fun z huz hzs => hBD_init z huz hzs⟩
      have h_bD_at_compl : ∀ u, u ∈ compl → u < s → bD u := by
        intro u hu hus; obtain ⟨v, hvu, hBDv⟩ := hu u hus le_rfl
        exact hBDv u hvu hus
      have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hx (h_compl_uc y x hy h)
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hps : p < s := h_cut_lt_compl p hp_cut s hs_in_compl
        have hs₁p : s₁ < p := by
          by_contra h; push_neg at h
          exact not_le.mpr (lt_of_le_of_lt h hs₁_uf) (h_ub hu_fail_not_compl)
        apply hp_cut
        intro u hus hpu
        rcases eq_or_lt_of_le hpu with rfl | hpu'
        · exact h_cofinal_propagate p hs₁p hus (fun w hpw hws => by
            have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
            exact this w hws le_rfl)
        · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
          exact this u hus le_rfl
      have h_not_cut_of_compl : ∀ x, x ∈ compl → x ∉ cut :=
        fun x hx hx_cut => hx_cut hx
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not_cut, hb_min⟩
        have hb_compl : b ∈ compl := by by_contra h; exact hb_not_cut (show b ∈ cut from h)
        have hbs : b < s := lt_of_le_of_lt (hb_min u_init (h_not_cut_of_compl _ hu_init_compl)) hui_s
        have hs₁b : s₁ < b := lt_trans hs₁_uf (h_compl_gt_uf b hb_compl)
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hs₁b hbs with
        | inl h_cof =>
          obtain ⟨v, hvb, hBDv⟩ := h_cof
          by_cases hvs₁ : v ≤ s₁
          · exact hBD_fail (hBDv u_fail (lt_of_le_of_lt hvs₁ hs₁_uf) huf_s)
          · push_neg at hvs₁
            have hv_compl : v ∈ compl := by
              intro u hus hvu
              rcases eq_or_lt_of_le hvu with rfl | hvu'
              · exact h_cofinal_propagate v hvs₁ (lt_trans hvb hbs)
                  (fun w hvw hws => ⟨v, hvw, hBDv⟩)
              · exact ⟨v, hvu', hBDv⟩
            exact absurd hvb (not_lt.mpr (hb_min v (show v ∉ cut from fun hv_cut => hv_cut hv_compl)))
        | inr h =>
          obtain ⟨_, v', hbv', hv's, hBDv'⟩ := h
          exact hBDv' (h_bD_at_compl v' (h_compl_uc b v' hb_compl (le_of_lt hbv')) hv's)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨u_fail, show u_fail ∈ cut from hu_fail_not_compl⟩, h_proper, h_cut_dc, h_no_sup, h_comp_no_min⟩
      have h_D_compl_cofinal : ∃ t, t ∉ γ_gap.cut ∧ ∀ u, u ∉ γ_gap.cut → u ≤ t →
          stavi_temporal_truth M atomMap u D :=
        ⟨u_init, fun h => h hu_init_compl, fun u hu hut =>
          (h_bD_at_compl u (by by_contra h'; exact hu h') (lt_of_le_of_lt hut hui_s)).2⟩
      have hD_fails : ∃ u_D, s₁ < u_D ∧ u_D < s ∧
          ¬stavi_temporal_truth M atomMap u_D D := by
        by_contra h_all_D; push_neg at h_all_D
        apply hNotS'D_BD_s
        exact ⟨s₁, hs₁s,
          fun u hs₁u hus => by
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v hsv hvu => h_all_D v hsv (lt_trans hvu hus), h.2⟩,
          ⟨u_fail, hs₁_uf, huf_s, hBD_fail⟩,
          ⟨u_init, hs₁_ui, hui_s, hBD_init⟩⟩
      obtain ⟨u_D, hs₁_uD, huD_s, hD_fail_D⟩ := hD_fails
      have hu_D_not_compl : u_D ∉ compl := by
        intro h; exact hD_fail_D (h_bD_at_compl u_D h huD_s).2
      have h_no_init_cut_D : ¬∃ t, t ∈ γ_gap.cut ∧ ∀ u, t ≤ u → u ∈ γ_gap.cut →
          stavi_temporal_truth M atomMap u D := by
        intro ⟨t, ht_cut, hDt⟩
        by_cases htu : t ≤ u_D
        · exact hD_fail_D (hDt u_D htu (show u_D ∉ compl from hu_D_not_compl))
        · push_neg at htu
          apply hNotS'D_BD_s
          have hts : t < s := h_cut_lt_compl t ht_cut s hs_in_compl
          refine ⟨t, hts, ?_, ?_, ?_⟩
          · intro u htu' hus
            have hs₁u : s₁ < u := lt_trans (lt_trans hs₁_uD htu) htu'
            cases h_body u hs₁u hus with
            | inl h => left; exact h
            | inr h =>
              right
              exact ⟨fun v htv hvu => by
                by_cases hv_compl : v ∈ compl
                · exact (h_bD_at_compl v hv_compl (lt_trans hvu hus)).2
                · exact hDt v (le_of_lt htv) (show v ∈ γ_gap.cut from hv_compl), h.2⟩
          · have ⟨u₂, hu₂_cut, htu₂⟩ : ∃ u₂, u₂ ∈ cut ∧ t < u₂ := by
              by_contra h; push_neg at h
              exact h_no_sup ⟨t, ⟨h, fun ub hub => hub ht_cut⟩, ht_cut⟩
            have hu₂s : u₂ < s := h_cut_lt_compl u₂ hu₂_cut s hs_in_compl
            have hs₁u₂ : s₁ < u₂ := lt_trans (lt_trans hs₁_uD htu) htu₂
            rcases h_body u₂ hs₁u₂ hu₂s with ⟨v, hvu₂, hBDv⟩ | ⟨_, v', hv'u₂, hv's, hngD⟩
            · exfalso
              exact hu₂_cut (show u₂ ∈ compl from
                fun u' hu's hu₂u' => ⟨v, lt_of_lt_of_le hvu₂ hu₂u', hBDv⟩)
            · exact ⟨v', lt_trans htu₂ hv'u₂, hv's, hngD⟩
          · exact ⟨u_init, h_cut_lt_compl t ht_cut u_init hu_init_compl, hui_s, hBD_init⟩
      have h_def_right : gap_definable_on_right M atomMap γ_gap D :=
        ⟨h_D_compl_cofinal, h_no_init_cut_D⟩
      have h_r_def : r_definable_gap M atomMap γ_gap r :=
        ⟨D, hD, Or.inr h_def_right⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
      refine ⟨γ, ?_, h_def_right, ?_, ?_⟩
      · have hm_compl : m ∈ compl := h_compl_uc s m hs_in_compl (le_of_lt hsm)
        show @GT.gt (ExtendedCarrier M atomMap r) _ (extendPoint m) (Sum.inr γ)
        exact ⟨fun h => h hm_compl, fun h => h hm_compl⟩
      · intro u hum hu_not_cut
        have hu_compl : u ∈ compl := by by_contra h'; exact hu_not_cut h'
        by_cases hus : u < s
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_compl u hu_compl hus).2
        · push_neg at hus
          rcases eq_or_lt_of_le hus with rfl | hsu
          · exact (stavi_truth_mu_at_point s D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hsu hum)
      · -- U(A,B)^mu at γ: simpler than U'(A,B) — just extend interval
        obtain ⟨s₂, hss₂, hA_s₂, hB_on⟩ := hUntl_s
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
        have hs₂_compl : s₂ ∈ compl := h_compl_uc s s₂ hs_in_compl (le_of_lt hss₂)
        refine ⟨extendPoint s₂,
          (⟨fun h => h hs₂_compl, fun h => h hs₂_compl⟩ :
            @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ) (extendPoint s₂)),
          ⟨s₂, rfl⟩, (stavi_truth_mu_at_point s₂ A).mpr hA_s₂,
          fun u hγu hus₂ hmu => ?_⟩
        obtain ⟨u_pt, rfl⟩ := hmu
        have hu_pt_not_cut : u_pt ∉ γ_gap.cut := by
          intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
        have hu_pt_s₂ : u_pt < s₂ := (extendPoint_lt_iff u_pt s₂).mp hus₂
        by_cases hus : u_pt < s
        · have hu_compl : u_pt ∈ compl := by by_contra h'; exact hu_pt_not_cut h'
          exact (stavi_truth_mu_at_point u_pt B).mpr (h_bD_at_compl u_pt hu_compl hus).1
        · push_neg at hus
          rcases eq_or_lt_of_le hus with rfl | hsu
          · exact (stavi_truth_mu_at_point s B).mpr hBs
          · exact (stavi_truth_mu_at_point u_pt B).mpr (hB_on u_pt hsu hu_pt_s₂)
    · -- Backward: gap below m with U(A,B)^mu → std_snce(compound, D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth] at hUA
      obtain ⟨s_sa, hs_sa_γ, ⟨t_pt, rfl⟩, hA_t, hB_mu⟩ := hUA
      -- t_pt is a complement point above gap with A(t_pt)
      have ht_not_cut : t_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff t_pt γ).mpr h) hs_sa_γ
      -- Find complement point s between γ and min(m, t_pt)
      have hm_not_cut : m ∉ γ.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
      have ⟨s, hs_not_cut, hsm, hst⟩ :
          ∃ s, s ∉ γ.val.cut ∧ s < m ∧ s < t_pt := by
        have ⟨s₁, hs₁_not, hs₁_m⟩ : ∃ s₁, s₁ ∉ γ.val.cut ∧
            s₁ < min m t_pt := by
          have hmin_not : min m t_pt ∉ γ.val.cut := by
            simp only [min_def]; split_ifs with h
            · exact hm_not_cut
            · exact ht_not_cut
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨min m t_pt, hmin_not, fun z hz => h_all z hz⟩
        exact ⟨s₁, hs₁_not,
          lt_of_lt_of_le hs₁_m (min_le_left _ _),
          lt_of_lt_of_le hs₁_m (min_le_right _ _)⟩
      have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint s) := ⟨fun h => hs_not_cut h, fun h => hs_not_cut h⟩
      -- D(s) from D-between
      have hDs : stavi_temporal_truth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hsm hs_not_cut)
      -- B(s) from B^mu on (γ, t_pt): s is between γ and t_pt
      have hBs : stavi_temporal_truth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hB_mu (extendPoint s) hγs ((extendPoint_lt_iff s t_pt).mpr hst) ⟨s, rfl⟩)
      -- U(A,B)(s): witness t_pt > s with A(t_pt) and B on (s, t_pt)
      have hUA_s : stavi_temporal_truth M atomMap s (.std_untl A B) := by
        simp only [stavi_temporal_truth]
        refine ⟨t_pt, hst, (stavi_truth_mu_at_point t_pt A).mp hA_t,
          fun u hsu hut => ?_⟩
        have hu_not_cut : u ∉ γ.val.cut := by
          intro h; exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu))
            ((extendPoint_le_gap_iff u γ).mpr h)
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u)
            ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
            ((extendPoint_lt_iff u t_pt).mpr hut) ⟨u, rfl⟩)
      -- D on (s, m)
      have hD_bet_sm : ∀ u, s < u → u < m → stavi_temporal_truth M atomMap u D := by
        intro u hsu hum
        have hu_not_cut : u ∉ γ.val.cut := by
          intro h; exact not_le.mpr (lt_trans hγs ((extendPoint_lt_iff s u).mpr hsu))
            ((extendPoint_le_gap_iff u γ).mpr h)
        exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not_cut)
      -- Gap definability
      obtain ⟨⟨t_D, ht_D_not, hD_init⟩, h_no_final_D⟩ := hγ_def
      have h_cut_lt : ∀ x, x ∈ γ.val.cut → ∀ y, y ∉ γ.val.cut → x < y := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hy (γ.val.downward_closed x y hx h)
      have h_neg_final : ∀ t, t ∈ γ.val.cut →
          ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬stavi_temporal_truth M atomMap w D := by
        intro t ht; by_contra h_all; push_neg at h_all
        exact h_no_final_D ⟨t, ht, fun w htw hw_cut => h_all w hw_cut htw⟩
      have ⟨c₀, hc₀_cut⟩ : ∃ c₀, c₀ ∈ γ.val.cut := γ.val.nonempty
      have hc₀s : c₀ < s := h_cut_lt c₀ hc₀_cut s hs_not_cut
      have h_bD_compl : ∀ u, u < s → u ∉ γ.val.cut →
          stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D := by
        intro u hus hu_not_cut
        constructor
        · exact (stavi_truth_mu_at_point u B).mp
            (hB_mu (extendPoint u) ⟨fun h => hu_not_cut h, fun h => hu_not_cut h⟩
              (lt_trans ((extendPoint_lt_iff u s).mpr hus) ((extendPoint_lt_iff s t_pt).mpr hst))
              ⟨u, rfl⟩)
        · exact (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hus hsm) hu_not_cut)
      refine ⟨s, hsm, ⟨hDs, hBs, hUA_s, ?_, ?_⟩, hD_bet_sm⟩
      · -- S'(⊤, B∧D)(s): bound c₀ (a cut point below s)
        refine ⟨c₀, hc₀s, ?_, ?_, ?_⟩
        · intro u hc₀u hus
          by_cases hu_not_cut : u ∉ γ.val.cut
          · left
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_not_cut, fun z hz => h_all z hz⟩
            exact ⟨y, hyu, fun w hyw hws =>
              h_bD_compl w hws (fun h_cut =>
                hy_not (γ.val.downward_closed w y h_cut (le_of_lt hyw)))⟩
          · push_neg at hu_not_cut
            right
            refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
            have ⟨y, hy_cut, huy⟩ : ∃ y, y ∈ γ.val.cut ∧ u < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨u, ⟨h_all, fun _ hb => hb hu_not_cut⟩, hu_not_cut⟩
            obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
            exact ⟨w, lt_of_lt_of_le huy hyw, h_cut_lt w hw_cut s hs_not_cut,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_cut, hc₀y⟩ : ∃ y, y ∈ γ.val.cut ∧ c₀ < y := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨c₀, ⟨h_all, fun _ hb => hb hc₀_cut⟩, hc₀_cut⟩
          obtain ⟨w, hw_cut, hyw, hDw⟩ := h_neg_final y hy_cut
          exact ⟨w, lt_of_lt_of_le hc₀y hyw, h_cut_lt w hw_cut s hs_not_cut,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨s, hs_not_cut, fun z hz => h_all z hz⟩
          exact ⟨y, h_cut_lt c₀ hc₀_cut y hy_not, hys, fun v hyv hvs =>
            h_bD_compl v hvs (fun hv_cut =>
              hy_not (γ.val.downward_closed v y hv_cut (le_of_lt hyv)))⟩
      · -- ¬S'(D, B∧D)(s): two-step D-transfer contradiction
        intro ⟨s₁', hs₁s', h_body', h_fail', h_init'⟩
        obtain ⟨u_fail', hs₁_uf', huf_s', hbD_fail'⟩ := h_fail'
        have huf_cut : u_fail' ∈ γ.val.cut := by
          by_contra huf_not
          exact hbD_fail' (h_bD_compl u_fail' huf_s' huf_not)
        have h_left_fails : ∀ u, s₁' < u → u < s → u ∈ γ.val.cut →
            ¬(∃ v, v < u ∧ ∀ w, v < w → w < s →
              stavi_temporal_truth M atomMap w B ∧ stavi_temporal_truth M atomMap w D) := by
          intro u _ _ hu_cut ⟨v, hvu, hbDv⟩
          have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
          have ⟨y, hy_cut, hvy⟩ : ∃ y, y ∈ γ.val.cut ∧ v < y := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨v, ⟨h, fun _ hb => hb hv_cut⟩, hv_cut⟩
          obtain ⟨w', hw'_cut, hyw', hDw'⟩ := h_neg_final y hy_cut
          exact hDw' (hbDv w' (lt_of_lt_of_le hvy hyw')
            (h_cut_lt w' hw'_cut s hs_not_cut)).2
        have hD_all_cut : ∀ u, s₁' < u → u < s → u ∈ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hs₁u hus hu_cut
          have h_right_u := (h_body' u hs₁u hus).resolve_left
            (h_left_fails u hs₁u hus hu_cut)
          obtain ⟨_, v', hv'u, hv's, hbD_v'⟩ := h_right_u
          have hv'_cut : v' ∈ γ.val.cut := by
            by_contra hv'_not; exact hbD_v' (h_bD_compl v' hv's hv'_not)
          have ⟨u', hu'_cut, huu'⟩ : ∃ u', u' ∈ γ.val.cut ∧ u < u' := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨u, ⟨h, fun _ hb => hb hu_cut⟩, hu_cut⟩
          have hu's : u' < s := h_cut_lt u' hu'_cut s hs_not_cut
          have h_right_u' := (h_body' u' (lt_trans hs₁u huu') hu's).resolve_left
            (h_left_fails u' (lt_trans hs₁u huu') hu's hu'_cut)
          exact h_right_u'.1 u hs₁u huu'
        have hs₁_cut : s₁' ∈ γ.val.cut := by
          by_contra hs₁_not
          exact not_le.mpr (h_cut_lt u_fail' huf_cut s₁' hs₁_not) (le_of_lt hs₁_uf')
        have ⟨t₀, ht₀_cut, hs₁t₀⟩ : ∃ t₀, t₀ ∈ γ.val.cut ∧ s₁' < t₀ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨s₁', ⟨h, fun _ hb => hb hs₁_cut⟩, hs₁_cut⟩
        exact h_no_final_D ⟨t₀, ht₀_cut, fun u ht₀u hu_cut =>
          hD_all_cut u (lt_of_lt_of_le hs₁t₀ ht₀u)
            (h_cut_lt u hu_cut s hs_not_cut) hu_cut⟩
  | std_snce A B _ _ =>
    -- right_formula (.std_snce A B) D = S'(B ∧ S(A,B), D)
    -- Same pattern as base.snce with S(A,B) instead of S(f,g)
    simp only [right_formula]
    rw [stavi_snce_gap_detection (.conj B (.std_snce A B)) D hD m]
    constructor
    · -- Forward: cut-point truth of B ∧ S(A,B) → S(A,B)^mu at γ
      intro ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth, temporal_truth_mu]
      have ⟨u₀, hu₀_in, hu₀s⟩ : ∃ u₀, u₀ ∈ γ.val.cut ∧ s_bound < u₀ := by
        by_contra h_all; push_neg at h_all
        exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
      have hX_u₀ := hX_cut u₀ hu₀_in hu₀s
      simp only [stavi_temporal_truth, temporal_truth] at hX_u₀
      obtain ⟨hB_u₀, t₁, ht₁u₀, hA_t₁, hB_between⟩ := hX_u₀
      have ht₁_in : t₁ ∈ γ.val.cut :=
        γ.val.downward_closed u₀ t₁ hu₀_in (le_of_lt ht₁u₀)
      refine ⟨extendPoint t₁, ⟨ht₁_in, fun h => h ht₁_in⟩, ⟨t₁, rfl⟩,
        (stavi_truth_mu_at_point t₁ A).mpr hA_t₁, fun v hvt₁ hvγ hmu => ?_⟩
      obtain ⟨v₀, rfl⟩ := hmu
      have hv₀_in : v₀ ∈ γ.val.cut :=
        (extendPoint_le_gap_iff v₀ γ).mp (le_of_lt hvγ)
      have hv₀_t₁ : t₁ < v₀ := (extendPoint_lt_iff t₁ v₀).mp hvt₁
      apply (stavi_truth_mu_at_point v₀ B).mpr
      by_cases hv_u₀ : v₀ < u₀
      · exact hB_between v₀ hv₀_t₁ hv_u₀
      · push_neg at hv_u₀
        have hv₀_sb : s_bound < v₀ := lt_of_lt_of_le hu₀s hv_u₀
        exact (hX_cut v₀ hv₀_in hv₀_sb).1
    · -- Backward: S(A,B)^mu at γ → cut-point truth of B ∧ S(A,B)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
      simp only [stavi_temporal_truth_mu] at hSA
      obtain ⟨s, hsγ, hmu_s, hA_s, hB_mu⟩ := hSA
      obtain ⟨t₁, rfl⟩ := hmu_s
      have ht₁_in : t₁ ∈ γ.val.cut :=
        (extendPoint_le_gap_iff t₁ γ).mp (le_of_lt hsγ)
      refine ⟨γ, t₁, hγ_lt, ht₁_in, hγ_def, hγ_bet, fun u hu_in hu_t₁ => ?_⟩
      simp only [stavi_temporal_truth]
      constructor
      · have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint u) (Sum.inr γ) := ⟨hu_in, fun h => h hu_in⟩
        have hut₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t₁) (extendPoint u) :=
          (extendPoint_lt_iff t₁ u).mpr hu_t₁
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hut₁ hγu ⟨u, rfl⟩)
      · refine ⟨t₁, hu_t₁, (stavi_truth_mu_at_point t₁ A).mp hA_s, fun v htv hvu => ?_⟩
        have hv_in : v ∈ γ.val.cut :=
          γ.val.downward_closed u v hu_in (le_of_lt hvu)
        have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint v) (Sum.inr γ) := ⟨hv_in, fun h => h hv_in⟩
        have hvt₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t₁) (extendPoint v) :=
          (extendPoint_lt_iff t₁ v).mpr htv
        exact (stavi_truth_mu_at_point v B).mp
          (hB_mu (extendPoint v) hvt₁ hγv ⟨v, rfl⟩)


end Bimodal.Metalogic.WeakCanonical
