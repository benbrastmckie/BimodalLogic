# Critic Findings: Verifying Prior Claims and Finding Overlooked Paths

**Researcher**: Teammate C (Critic)
**Date**: 2026-05-17
**Task**: 157 -- Expressive completeness of {S,U} over integer time
**Focus**: Rigorous verification of claims made by prior implementation agents

---

## Executive Summary

After reading every relevant Lean file and running code experiments, I find that most prior claims are **confirmed** with important nuances, one claim is **critically refuted** (Claim 1, with major implications for the plan), and two **overlooked paths** exist that prior agents missed. The primary refutation has concrete consequences for Phase 6.

---

## Verified Claims

### Claim 3: CONFIRMED -- abstract_untl + substitute back breaks separation

The claim that "after abstracting untl(A,B) to atom p, we get a formula with atom p, and substituting untl(A,B) back creates U-under-S" is **confirmed**, but the mechanics are more precise than stated.

**Code evidence** (`Hierarchy.lean` lines 277-288):
```lean
def abstract_untl (phi A B : Formula) (p : Atom) : Formula :=
  match phi with
  | .snce psi1 psi2 => .snce (abstract_untl psi1 A B p) (abstract_untl psi2 A B p)
  ...
```

The abstraction descends into snce args. When phi is a separated formula:
- `phi'` (separated witness) has untl A B at top-level boolean positions
- After abstracting to fresh atom `fresh`: phi'' is U-free, so `snce phi'' psi''` is separated
- Substituting `fresh -> untl A B` back: the OUTER snce's arg phi'' now contains untl A B
- This breaks U-freeness of the outer snce's arg -- exactly U-under-S

**Why the claim is incomplete**: The problematic positions are the OUTER snce's args, not inner snce of phi'. In a separated phi', untl A B cannot be inside snce args of phi' (those args must be U-free). So the atom `fresh` in phi'' appears only at top-level boolean positions or inside non-snce operators. After substituting back, the outer snce sees the untl.

**Cases 5-8 necessity**: This is confirmed by code test. The formula `snce (untl p q) (untl p q)` (Case 5 situation) satisfies `no_S_nested_in_U` but is NOT separated. Its separability IS provable (`all_separable _` succeeds) but requires going beyond Cases 1-4.

### Claim 4: CONFIRMED but misdescribed -- expand_temporal increases junction_depth

The claim that "expand_temporal makes formulas larger so WF induction on size fails" is **confirmed** with the correct technical statement.

**Code evidence** (`TemporalClosure.lean` lines 591-600):
```lean
def expand_temporal : Formula → Formula
  | .all_past φ => Formula.neg (.snce (Formula.neg (expand_temporal φ)) Formula.top)
  | .all_future φ => Formula.neg (.untl (Formula.neg (expand_temporal φ)) Formula.top)
```

Computation: `junction_depth (expand_temporal (.all_past (.untl A B)))` where A, B are S-free:
- `expand(.all_past (.untl A B)) = neg(snce(neg(.untl (expand A)(expand B)))(top))`
- `junction_depth` of this = `junction_depth_S(neg(.untl (expand A)(expand B)))` = `1 + max(jd(expand A))(jd(expand B))`
- vs `junction_depth(.all_past (.untl A B)) = junction_depth(.untl A B) = 0` (when A,B S-free)

So `expand_temporal` can INCREASE junction_depth from 0 to 1 for `all_past(untl ...)`.

**Correct statement**: The formula `all_past (untl A B)` (with S-free A,B) has junction_depth 0 but its expansion has junction_depth 1. WF induction on junction_depth of the EXPANDED formula does NOT immediately give a smaller subformula to apply IH to.

**Why this is manageable**: The key insight from `TemporalClosure.lean` (line 515-519) is:
```lean
theorem snce_of_boxfree_sep_jd_le_one
```
This theorem shows that `snce phi' psi'` where phi', psi' are separated has junction_depth ≤ 1 REGARDLESS of the original formula. So the WF induction only needs to handle depth 0 and depth 1 as base cases. The plan's approach is still viable but the claim is imprecisely stated.

### Claim 5: CONFIRMED -- 500+ LOC estimate includes existing infrastructure, but gap is large

**Code evidence**: Current LOC count:
- `Hierarchy.lean`: 636 lines (Lemmas 10.2.5-10.2.6 implemented, using axioms via `all_separable`)
- `TemporalClosure.lean`: 813 lines (box normalization, expand_temporal, JD helpers -- all complete)
- `Eliminations.lean`: 462 lines (Cases 1-4 proved, Cases 5-8 redirect to `all_separable`)
- `SeparationThm.lean`: 273 lines (8 axioms + theorem shells)

**What's genuinely new for Phase 6**:
- `abstract_snce` (dual of `abstract_untl` at 86 lines): ~100 LOC needed
- `no_S_nested_in_U_separable` with WF induction: estimated 200-400 LOC
- Junction depth decrease lemmas: ~100 LOC
- Temporal closure derivation: ~80 LOC
- Axiom replacement: ~20 LOC

**Verified**: The 500+ LOC estimate is for NEW code only. The existing ~2,000 lines of separation infrastructure are supporting but not replacing.

---

## Refuted Claims

### Claim 1: REFUTED -- The snce case of no_S_nested_in_U_separable is NOT trivial

**This is the most important finding.** The plan (v7, Phase 6 overview item 3) states:

> "The snce case of no_S_nested_in_U_separable is TRIVIAL (U-free snce args mean already separated)"

This is **wrong**. Reading `Defs.lean` lines 320-328:

```lean
def no_S_nested_in_U : Formula -> Prop
  | .snce phi psi => no_S_nested_in_U phi ∧ no_S_nested_in_U psi
```

The snce case requires `no_S_nested_in_U phi` AND `no_S_nested_in_U psi` RECURSIVELY. It does **NOT** require `is_U_free phi` or `is_U_free psi`.

**Code verification** (test ran successfully):
```lean
-- .snce (.untl p q) r satisfies no_S_nested_in_U:
-- because no_S_nested_in_U (.untl p q) = is_S_free p ∧ is_S_free q = true
-- But it is NOT syntactically separated:
-- is_syntactically_separated (.snce (.untl p q) r) = is_U_free (.untl p q) = false!
example : no_S_nested_in_U (.snce (.untl p q) r) := by simp [...]  -- SUCCEEDS
example : is_syntactically_separated (.snce (.untl p q) r) = false := by simp [...]  -- SUCCEEDS
```

**Implications**: A formula like `snce (untl p q) r` satisfies `no_S_nested_in_U` but:
1. Has U nested under S (untl inside snce)
2. Is NOT syntactically separated
3. Requires non-trivial elimination (specifically Case 1) to prove separability

The snce case of `no_S_nested_in_U_separable` is therefore a **HARD case**, not trivial. It requires:
- Abstracting all `untl` subformulas from C and F
- Applying Cases 1-4 (and potentially Cases 5-8) to eliminate U-under-S
- The junction_depth argument to bound the induction

**Consequence for the plan**: Phase 6 has underestimated the snce case. The prior team research assertion that "the snce case is trivial because U-free args" was based on a misreading of the `no_S_nested_in_U` definition. The snce case IS the main difficulty of `no_S_nested_in_U_separable`.

### Claim 2: PARTIALLY REFUTED -- Cases 5-8 have a viable proof path without the current circular axioms

The claim that "Cases 5-8 cannot be proved without all_separable" is **overstated**. What is true is that Cases 5-8 cannot be proved with a simple strategy. However, there IS a viable non-circular approach:

**The actual situation**:
- Cases 5-8 in `NormalForm.lean` currently use `all_separable _` (line 161, 172, 183, 193)
- `all_separable` uses the temporal closure axioms
- The temporal closure axioms include `snce_separable` which is what we want to prove

**The overlooked non-circular path**: In the WF induction on junction_depth, Cases 5-8 situations only arise at junction_depth 1 (one level of U-under-S with S-free U-args). At this level, the induction hypothesis provides separability for all formulas of junction_depth 0. The proof is:

1. The formula `snce (a ^ untl A B) (q v untl A B)` has junction_depth 1 (the untl under snce contributes 1 to junction_depth_S)
2. After applying `neg_until_equiv`: `¬(untl A B) ↔ G(¬A) ∨ untl(¬A∧¬B, ¬A)` (valid on Z)
3. The resulting formula still has junction_depth 1 (same U-under-S structure with S-free args)
4. The KEY: after abstracting the ONE untl A B type and substituting back using Cases 1-4, the resulting formula has junction_depth 0 (U appears only at top level, not under S)
5. junction_depth 0 means separated (by `expanded_jd_zero_imp_separated`)

This path AVOIDS Cases 5-8 as standalone lemmas by handling them WITHIN the WF induction.

---

## Overlooked Paths

### Path 1: Combined measure (count_U_under_S, count_U_formulas) avoids the architectural blocker

All prior approaches treat `no_S_nested_in_U_separable` as requiring junction_depth induction at the "formula level." The overlooked path uses a **pair measure**: `(count_U_subformulas_inside_S phi, count_U_subformulas phi)` where:

- `count_U_subformulas_inside_S`: count of untl nodes that are direct args of some snce (not nested under another snce)
- `count_U_subformulas`: total untl count

This pair decreases lexicographically under the abstraction-Case-1-4 cycle:
- `abstract_untl` reduces `count_U_subformulas` by at least 1
- Case 1-4 application to `snce (a ^ untl A B) q` produces an equivalent formula where the specific `untl A B` inside the snce's arg is replaced by top-level terms
- The result has FEWER untl-inside-snce, even if total untl count is unchanged

The plan already has `count_U_subformulas` in Defs.lean (line 252). A new helper `count_U_under_S` would be needed (~20 LOC). This composite measure is more direct than junction_depth and avoids the Cases 5-8 "both in event and guard" difficulty: in each step, we eliminate ONE untl from under ONE snce.

### Path 2: Prove separability for the `no_S_nested_in_U` predicate directly by structural induction

The current approach tries to prove `no_S_nested_in_U phi -> is_separable phi` by WF induction on junction_depth. An alternative is to prove this by **structural induction** using a STRENGTHENED induction hypothesis:

```lean
theorem no_S_nested_in_U_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi ∧ ∀ q, no_S_nested_in_U q → is_separable (snce phi q)
```

The second conjunct provides that `phi` can be used as an argument of any `snce` with another `no_S_nested_in_U` formula. This allows the `snce` case to call the IH on both arguments AND use the separability of the combination.

Why this might work: The `snce` case of `no_S_nested_in_U phi` gives `no_S_nested_in_U C ∧ no_S_nested_in_U F`. The IH applied to C gives:
- `is_separable C`
- `∀ q, no_S_nested_in_U q → is_separable (snce C q)`

Applying the second clause to F (since `no_S_nested_in_U F`): `is_separable (snce C F)` -- DONE!

**This is the most promising overlooked path.** The strengthened IH makes the snce case trivial (use IH's second clause directly). The remaining obligation is to prove the second conjunct for each case, which requires showing that the composition of two `no_S_nested_in_U` formulas under `snce` is separable. This IS the hard case, but it can be proved using Cases 1-4 + `abstract_untl` iteratively.

**Key insight**: The strengthened IH for the ATOM case is: `is_separable (atom a) ∧ ∀ q, no_S_nested_in_U q → is_separable (snce (atom a) q)`. The second part needs `snce (atom a) q` to be separable when `q` is `no_S_nested_in_U`. Since `atom a` is U-free, `snce (atom a) q` with `no_S_nested_in_U q` reduces to the same problem recursively -- but `q` is structurally smaller.

---

## Key Code Evidence

### Definition of no_S_nested_in_U (Defs.lean lines 320-328)

```lean
def no_S_nested_in_U : Formula -> Prop
  | .atom _ => True
  | .bot => True
  | .imp phi psi => no_S_nested_in_U phi ∧ no_S_nested_in_U psi
  | .box phi => no_S_nested_in_U phi
  | .all_past phi => no_S_nested_in_U phi
  | .all_future phi => no_S_nested_in_U phi
  | .untl phi psi => is_S_free phi = true ∧ is_S_free psi = true
  | .snce phi psi => no_S_nested_in_U phi ∧ no_S_nested_in_U psi
```

The snce case is RECURSIVE, not U-free check. The untl case IS an S-free check.

### Cases 5-8 use all_separable (NormalForm.lean lines 155-194)

```lean
theorem case5_separable ... := all_separable _
theorem case6_separable ... := all_separable _
theorem case7_separable ... := all_separable _
theorem case8_separable ... := all_separable _
```

These are proofs by axiom, not by explicit formula construction. The circular dependency is real.

### Temporal closure axioms (SeparationThm.lean lines 90-103)

```lean
axiom all_past_separable (φ : Formula) (h : is_separable φ) : is_separable (.all_past φ)
axiom all_future_separable (φ : Formula) (h : is_separable φ) : is_separable (.all_future φ)
axiom untl_separable (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) : is_separable (.untl φ ψ)
axiom snce_separable (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) : is_separable (.snce φ ψ)
```

Plus 4 more for proper separability (lines 222-241). Total: 8 axioms to eliminate.

### Existing infrastructure that IS sufficient (TemporalClosure.lean)

```lean
theorem snce_of_boxfree_sep_jd_le_one -- junction_depth of snce(sep)(sep) <= 1
theorem replace_box_separated_no_S_nested -- box-normalized separated => no_S_nested_in_U
theorem expanded_jd_zero_imp_separated -- in restricted fragment, JD=0 => separated
```

These three lemmas together form the skeleton of the proof: if we can show that the WF induction at JD <= 1 closes, everything follows.

---

## Confidence Level

| Claim | Verdict | Confidence |
|-------|---------|------------|
| Claim 1: snce case trivial | REFUTED | HIGH (verified by reading definition, confirmed by code test) |
| Claim 2: Cases 5-8 need all_separable | PARTIALLY REFUTED | MEDIUM (circular path exists; non-circular path exists via WF induction) |
| Claim 3: abstract_untl + subst breaks separation | CONFIRMED | HIGH (mechanically verified by tracing through the code) |
| Claim 4: expand_temporal makes formulas larger | CONFIRMED (misdescribed) | HIGH (the size issue is junction_depth increase, not a blocker) |
| Claim 5: 500+ LOC for full hierarchy | CONFIRMED | HIGH (existing 2000 LOC is supporting infrastructure; 500 LOC is additional new code) |

### Most Important Finding

**Claim 1's refutation is the most impactful finding.** The plan's description of Phase 6 as "snce case is TRIVIAL" misread the `no_S_nested_in_U` definition. The correct reading is that the snce case is the HARD case. This changes the difficulty estimate:

- Prior plan: snce trivial, hard cases are all_past/all_future
- Correct: snce is HARD (requires Cases 1-4 iteration), all_past/all_future handled by expand_temporal

The GOOD news from Overlooked Path 2: the **strengthened induction hypothesis** approach may make the snce case tractable by letting the IH directly provide `is_separable (snce C F)` without separate proof. This bypasses the Cases 5-8 circularity entirely.

---

## Recommended Next Action

1. **Immediate**: Fix the Phase 6 plan to correctly characterize the snce case as hard, not trivial
2. **Implementation target**: Try Overlooked Path 2 (strengthened IH for structural induction) as the primary approach for `no_S_nested_in_U_separable`
3. **Fallback**: If strengthened IH fails, use the compound measure (count_U_under_S, count_U) from Overlooked Path 1
4. **Do NOT try**: Junction_depth WF induction as the primary approach -- the prior blockers document correctly shows this was tried 4+ times and fails at the Cases 5-8 joint recursion
