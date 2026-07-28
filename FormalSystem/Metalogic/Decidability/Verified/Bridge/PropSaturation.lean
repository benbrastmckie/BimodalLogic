/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation

/-!
# The branching propositional rule, on a saturated branch

`CountermodelExtraction.lean` proves the `sat_*` family for every rule the truth lemma's induction
consumes **except one**: `impPos`. That is not an oversight about a minor case — `imp` is the only
primitive propositional connective besides `bot`, so the truth lemma's `imp` case has no
saturation fact to run on without it, whatever the gap policy turns out to be.

It is missing because `impPos` is the only *branching* rule among the propositional ones, and the
existing family is written against `.linear` and `.persistent` arms. `findApplicableRule`'s
`.branching` arm reads

```
if ruleSelfGuarded rule then some …
else if ruleMintsFreshLabel rule then (if witnessPresent … then none else some …)
else if bss.any (fun fs => fs.all branch.contains) then none
else some …
```

and `impPos` is neither self-guarded nor fresh-label-minting, so the only way it can fail to be
applicable is the third test: **some arm of the split is already wholly on the branch**. For
`T(ψ → χ)` the arms are `[F(ψ)]` and `[T(χ)]`, so that test is exactly the disjunction
`F(ψ) ∈ b ∨ T(χ) ∈ b` — the classical `impPos` reading of a saturated open branch.

`sat_imp_pos` below states and proves it. It lives here rather than in
`CountermodelExtraction.lean` for the reason `BoxSaturation.lean` gives for its own contents: the
proof unfolds `applyRule` and needs `maxHeartbeats 1600000`, and an elaboration timeout in an
engine-adjacent file would take the whole green prefix down with it.

## Relation to the gap refutation

Nothing here depends on the gap policy, and the gap policy's refutation
(`Bridge/Valuation.lean`, `not_truthLemma_branchGapVal`) does not touch this: the `imp` case of the
truth lemma needs `sat_imp_pos` at *placed* labels, where the branch dictates the valuation
outright and no gap point is involved.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-! ## Local copies of the saturation plumbing

`CountermodelExtraction.lean`'s versions are `private`, and so are `BoxSaturation.lean`'s.
Restated once more here rather than de-privatised anywhere, so that this module stays additive.
-/

/-- `findUnexpanded b = none` says every formula on `b` is expanded. -/
private theorem all_expanded_of_saturated' (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none) :
    ∀ sf ∈ b, isExpanded sf b (timeOrd := timeOrd) = true := by
  intro sf hsf
  unfold findUnexpanded at hSat
  have h := List.find?_eq_none.mp hSat sf hsf
  simp only [Bool.not_eq_true, Bool.decide_eq_false, Bool.not_eq_eq_eq_not, Bool.not_true,
    Bool.not_eq_false] at h
  exact h

private theorem mem_iff_contains' (b : Branch) (sf : SignedFormula) :
    Branch.contains b sf = true ↔ sf ∈ b := by
  simp only [Branch.contains, List.any_eq_true]
  constructor
  · rintro ⟨x, hx, heq⟩
    exact beq_iff_eq.mp heq ▸ hx
  · intro h
    exact ⟨sf, h, beq_self_eq_true _⟩

/-! ## The branching propositional rule -/

set_option maxHeartbeats 1600000 in
/--
**`impPos` saturation.** `T(ψ → χ)` at a label on a saturated branch puts `F(ψ)` or `T(χ)` at that
same label.

The disjunction is not a case split the proof performs — it is what the `.branching` guard
literally says: `findApplicableRule` declines `impPos` exactly when *some* arm of its split is
already wholly contained in the branch, and its two arms are the singletons `[F(ψ)]` and `[T(χ)]`.

Sound by the material reading of `→`: any model of the branch satisfies `ψ → χ` at the label, so
it falsifies `ψ` or satisfies `χ` there.
-/
theorem sat_imp_pos (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (ψ χ : Formula) (l : Label)
    (hmem : (⟨.pos, .imp ψ χ, l⟩ : SignedFormula) ∈ b) :
    (⟨.neg, ψ, l⟩ : SignedFormula) ∈ b ∨ (⟨.pos, χ, l⟩ : SignedFormula) ∈ b := by
  have hExp := all_expanded_of_saturated' b timeOrd hSat ⟨.pos, .imp ψ χ, l⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have h := hExp .impPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  by_cases hneg : Branch.contains b (SignedFormula.neg ψ l) = true
  · exact Or.inl ((mem_iff_contains' b _).mp hneg)
  · by_cases hpos : Branch.contains b (SignedFormula.pos χ l) = true
    · exact Or.inr ((mem_iff_contains' b _).mp hpos)
    · exfalso
      simp [isApplicable, applyRule, ruleSelfGuarded, ruleMintsFreshLabel, hneg, hpos] at h

end FormalSystem.Metalogic.Decidability.Verified.Bridge
