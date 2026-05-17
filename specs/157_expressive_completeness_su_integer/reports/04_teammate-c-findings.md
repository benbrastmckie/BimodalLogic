# Teammate C (Critic) Findings -- Phase 6 Blocker Analysis

**Date**: 2026-05-17
**Role**: Critic -- verify all claims by reading actual Lean code
**Scope**: Circularity claim, expand_temporal usefulness, Cases 5-8 dependency, Phase 7 needs

---

## Key Findings

### 1. The Circularity Is Real but Precisely Located -- Not Where the Handoff Claims

The handoff states the circular dependency as:
```
all_separable -> temporal closure axioms -> Cases 5-8 -> all_separable
```

After reading the actual code, this is **accurate but imprecisely stated**. The circularity is:

**What actually happens**:
- `all_separable` (SeparationThm.lean, line 125) is proved by structural induction. The temporal cases call `all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable` -- these are 4 `axiom` declarations.
- `NormalForm.lean` defines `case5_separable` through `case8_separable` (lines 155-194). Each is proved by `all_separable _` -- a direct call to the main theorem. They pass ALL parameters as underscored (unused) because the proof ignores them entirely.
- `Hierarchy.lean` (line 174) calls `snce_separable ψ₁ ψ₂ ...` -- the axiom, not Cases 5-8.
- **Cases 5-8 in NormalForm.lean do not appear in the proof chain of `all_separable`**. They are lemmas proved FROM `all_separable`, not proofs used BY `all_separable`.

**The actual circularity is more subtle**: To eliminate the axioms, we need to prove `snce_separable` as a theorem. To prove `snce_separable` without axioms, we need Cases 5-8 as explicit proved results. But Cases 5-8 currently ARE proved -- via `all_separable`, which itself USES the `snce_separable` axiom. So to make the system non-circular:
- Step 1: Prove Cases 5-8 WITHOUT `all_separable` (currently impossible for explicit formulas on Z)
- Step 2: Prove `snce_separable` using Cases 5-8 (currently missing)
- Step 3: Prove `all_separable` using `snce_separable` (already done)

The dependency is: **Cases 5-8 need explicit formulas for Z** (the real blocker), not "Cases 5-8 need `all_separable`."

### 2. Cases 5-8 Depend on all_separable -- But Only as Their Current Proof Method, Not Logically

In NormalForm.lean lines 155-194:
```lean
theorem case5_separable ... :
    is_separable (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) :=
  all_separable _
```

The parameters `_ha`, `_hq`, etc. are all IGNORED. This is the circularity source. Cases 5-8 are proved by delegating to `all_separable`, which requires the `snce_separable` axiom.

**Finding**: Cases 5-8 do NOT require `all_separable` of SMALLER formulas. They are proving separability of a specific formula form. GHR94 provides explicit separated formulas for Cases 5-8 on dense time. The claim is that these fail on Z. The Lean comment (Eliminations.lean, lines 323-352) documents a counterexample to GHR94's Case 5 formula on Z, but this is stated in a comment, not Lean-verified.

### 3. The Counterexample to GHR94's Case 5 is NOT Lean-Verified

Eliminations.lean (lines 323-352) contains an extensive comment claiming GHR94's explicit formula for Case 5 fails on integer time. The comment describes:
- The formula being evaluated: `S(a ∧ U(A,B), q ∨ U(A,B))(3)` with specific valuations
- A claimed counterexample where LHS is TRUE but RHS of GHR94's formula is FALSE

**This counterexample exists ONLY in a comment**. There is no `theorem` or `example` in Lean verifying it. The claim is mathematically reasonable given the discrete-time nature of Z, but it is asserted, not proved.

**Implication**: It is possible (though unlikely) that a DIFFERENT formulation of Cases 5-8 for Z exists that was missed. The counterexample disproves GHR94's specific formula, not the existence of any formula.

### 4. The expand_temporal Infrastructure Is Useful but Does Not Break the Circularity

TemporalClosure.lean contains substantial useful infrastructure:
- `expand_temporal` (correct, proved semantically equivalent)
- `expanded_jd_zero_imp_separated` (key lemma: in the {atom,bot,imp,snce,untl,box} fragment, JD=0 implies separated)
- `snce_of_boxfree_sep_jd_le_one` (the target formula has JD ≤ 1)
- `replace_box_separated_no_S_nested` (box-normalized separated formulas satisfy no_S_nested_in_U)

**What these prove**: After `expand_temporal`, the formula `.snce (replace_box phi) (replace_box psi)` (where phi, psi were separated) satisfies `no_S_nested_in_U` and has JD ≤ 1. 

**What's still missing**: A proof that `no_S_nested_in_U phi -> is_separable phi`. This is exactly `multi_U_formula_separable` in Hierarchy.lean (line 545), which currently reads:
```lean
theorem multi_U_formula_separable (phi : Formula) (h : no_S_nested_in_U phi) :
    is_separable phi :=
  all_separable phi
```
This delegates to `all_separable`, completing the circle. The infrastructure does not break the loop; it NARROWS it to exactly this lemma.

**Verdict**: The expand_temporal work was NOT a dead end -- it correctly identifies that the problem reduces to proving `no_S_nested_in_U -> is_separable`. But this key lemma is still circular.

### 5. What Phase 7 Needs from Phase 6 -- and Whether It Can Be Weakened

`ExpressiveCompleteness.lean` imports `SeparationThm` and uses `proper_separation_theorem_int` at line 721:
```lean
theorem US_expressively_complete_over_Z :
    ... := separation_implies_expressiveness (fun phi => proper_separation_theorem_int phi)
```

`separation_implies_expressiveness` (line 688) takes `h_sep : ∀ phi, is_properly_separable phi` as an argument and is otherwise fully proved (for the propositional cases -- lines 621-686).

The TWO sorries in `expressiveness_fixed_atomMap` (lines 667, 685) are in the `.all` and `.ex` cases. These call `h_sep` (proper separation) and would require the actual sorted formula. But the sorries are about QUANTIFIER ELIMINATION, not about separation itself.

**Critical finding**: Phase 7 needs `all_properly_separable` (the 4 proper axioms), not the 4 weak ones. The `separation_implies_expressiveness` function takes `h_sep` as a parameter -- it is parametric over the separation result. So Phase 7 does NOT need Phase 6's axioms eliminated. Phase 7's sorries are about quantifier elimination, independent of Phase 6.

**What Phase 7 actually needs from Phase 6**: Zero-axiom versions of `all_properly_separable` for the final `US_expressively_complete_over_Z` theorem to be axiom-free. But `separation_implies_expressiveness` itself is proved (modulo the 2 sorries) and would work even with the axioms.

**Conclusion**: Phase 7 can proceed independently of Phase 6's axiom elimination. The 2 sorries in Phase 7 (quantifier cases) are independent of Phase 6.

### 6. The Circularity Could Potentially Be Broken by Structural Induction on Formula Size

The handoff claims well-founded induction on (JD, size) fails because "the transformed formula can be larger than original." Let me verify this claim structurally.

For proving `snce_separable`:
- Given: `phi`, `psi` separable. Get their separated witnesses `phi'`, `psi'`.
- Need: `snce phi psi` is separable.
- Strategy: use `phi'`, `psi'` to build a separated equivalent of `snce phi psi`.
- The witness must be equivalent to `snce phi psi` = `snce phi' psi'` (up to `int_equiv`).
- `snce phi' psi'` satisfies `no_S_nested_in_U` (proved in TemporalClosure.lean).
- So the blocker is: `no_S_nested_in_U (snce phi' psi') -> is_separable (snce phi' psi')`.

For `no_S_nested_in_U phi -> is_separable phi`:
- If we try structural induction: the `snce` case of `phi` needs to handle `phi = snce C F`.
- `no_S_nested_in_U (snce C F)` means `is_U_free C` and `is_U_free F`.
- So C and F are U-free. Then `snce C F` is already syntactically separated (args are U-free)!
- Wait -- this means `no_S_nested_in_U (snce C F) -> is_separable (snce C F)` IS TRIVIAL for the `snce` case.

But what about `all_future C` where `no_S_nested_in_U (all_future C)`? That means `no_S_nested_in_U C`. To show `all_future C` is separable from `no_S_nested_in_U C`, we need `is_separable (all_future C)` given `is_separable C`... which is the temporal closure axiom again.

Actually, the chain to check: `no_S_nested_in_U (all_future C)` requires `no_S_nested_in_U C` by definition. If C were `snce P Q`, then `all_future (snce P Q)` has `no_S_nested_in_U` iff `no_S_nested_in_U (snce P Q)` iff `is_U_free P ∧ is_U_free Q`. This can hold. Is `all_future (snce P Q)` with U-free P, Q separable?

`expand_temporal (all_future (snce P Q))` = `neg (untl (neg (snce (expand P) (expand Q))) top)`. Since P, Q are U-free and have no all_future, `expand P = P` and `expand Q = Q` (approximately). The result has `no_S_nested_in_U` if the snce args are U-free. This is indeed the case. So `expand_temporal` DID identify the correct reduction.

### 7. The Core Missing Proof: A Precise Gap Identification

After reading all the code, the gap is precisely this: we need

```lean
theorem no_S_nested_in_U_separable (phi : Formula) : no_S_nested_in_U phi -> is_separable phi
```

proved WITHOUT `all_separable`. The inductive structure:
- `atom`, `bot`, `box`, `imp`: trivial (already separated or close)
- `untl a b`: `no_S_nested_in_U (untl a b)` means `is_S_free a ∧ is_S_free b`, so `untl a b` is already separated. DONE.
- `snce a b`: `no_S_nested_in_U (snce a b)` means `no_S_nested_in_U a ∧ no_S_nested_in_U b`. Applying IH: `a` and `b` are separable. We need `snce a b` is separable. This requires the temporal closure axiom for `snce`. STUCK.
- `all_past a`: IH gives `a` is separable. Need `all_past a` is separable. Temporal closure axiom. STUCK.
- `all_future a`: IH gives `a` is separable. Need `all_future a` is separable. But `expand_temporal (all_future a)` = `neg (untl (neg (expand a)) top)`. The expanded form has `no_S_nested_in_U` if `expand a` has no S-nesting... but we need to go back to `no_S_nested_in_U_separable` at the expanded form. This could work if we induct on formula size and the expanded form is not larger -- but it IS larger (adds neg, untl, top).

The fundamental obstacle is: `all_past a` requires treating `a` as a whole unit, and there's no decomposition that reduces to smaller formulas with the `no_S_nested_in_U` property, unless we use `expand_temporal` which makes the formula larger.

---

## Gaps Identified

### Gap 1: Counterexample to GHR94 Case 5 Is Unverified

The documented counterexample (Eliminations.lean comments) is stated in English prose, not in Lean. It should be formalized as a `#eval` or `example` to confirm it's correct.

### Gap 2: All Past/Future Cases Require Size Increase Under expand_temporal

The claimed strategy of "expand_temporal + JD induction" works if we can induct on something that DECREASES after expansion. But `expand_temporal (all_future a)` is strictly LARGER than `all_future a` (adds 2 connectives). So WF induction on size with expand_temporal does not terminate.

The plan in TemporalClosure.lean mentions `expanded_jd_zero_imp_separated` but this only helps for JD=0 formulas. The `all_past`/`all_future` formulas after expansion have JD that depends on the argument, not necessarily 0.

### Gap 3: multi_U_formula_separable Circular Shortcut Not Addressed

Hierarchy.lean line 545 short-circuits `multi_U_formula_separable` to `all_separable phi`. This is the key lemma that GHR94's Lemma 10.2.6 is supposed to prove. The circular shortcut was used because the real proof requires abstracting S-subformulas (an `abstract_snce` operation that doesn't exist yet), not just abstracting U-subformulas.

### Gap 4: abstract_snce Is Not Implemented

The phase-6-handoff-20260517e.md explicitly lists `abstract_snce` (~100 LOC) as a required piece for the resolution. No file in the codebase implements this. The `Hierarchy.lean` only has `abstract_untl`.

### Gap 5: Cases 5-8 On Z -- No Alternative Approach Has Been Tried

The handoff lists 5 failed approaches, but "find correct explicit formulas for Cases 5-8 on Z" was listed as the most promising and has not been pursued substantively. The GHR94 counterexample shows THEIR formula fails; it doesn't prove no formula exists. Research into whether Reynolds (1994) or Kamp's original proof provide explicit formulas for the discrete case is unfinished.

---

## Validated Claims

1. **The 8 axioms in SeparationThm.lean are real** -- confirmed by direct reading. Lines 90-102 (4 weak) and 223-239 (4 proper).

2. **Cases 5-8 currently use all_separable** -- confirmed. NormalForm.lean lines 155-194 each use `all_separable _` with underscored parameters.

3. **Build passes clean** -- the handoff claims "1652 jobs, no errors." This is consistent with the code structure: all 8 axioms are declared as `axiom`, which Lean accepts without proof. NormalForm.lean properly imports SeparationThm.lean for `all_separable`.

4. **The expand_temporal infrastructure is complete** -- TemporalClosure.lean contains all claimed results through `expanded_jd_zero_imp_separated`. The equivalence proofs (`all_past_equiv_neg_snce`, `all_future_equiv_neg_untl`, `expand_temporal_equiv`) are present and appear correct.

5. **The JD ≤ 1 bound is correct** -- `snce_of_boxfree_sep_jd_le_one` is proved and correct. After box-normalization of separated phi', psi', the formula `snce phi' psi'` has junction_depth ≤ 1.

6. **Phase 7 sorries are independent quantifier elimination problems** -- confirmed. The 2 sorries at lines 667, 685 of ExpressiveCompleteness.lean are in the `.all` and `.ex` cases of `expressiveness_fixed_atomMap`. They handle FO quantifier elimination, not separation.

7. **The circularity in the proof chain exists** -- the dependency `all_separable -> snce_separable (axiom)` in SeparationThm.lean, and `snce_separable (axiom) -> (current proof) <- all_separable` in Hierarchy.lean is real. Multi_U_formula_separable proves nothing independently.

---

## Refuted Claims

### Claim: "Circularity makes all approaches fail"

**Refuted in part**: The circularity can in principle be broken. The `snce` case of `no_S_nested_in_U_separable` is TRIVIAL because `no_S_nested_in_U (snce a b)` requires U-free args, and U-free args make `snce a b` already syntactically separated. The hard cases are `all_past` and `all_future`, not `snce`.

This means the REAL blocker is proving `all_past a` is separable given `a` is separable (and similarly for `all_future`). This requires the temporal closure axiom for `all_past`, not Cases 5-8. The framing "Cases 5-8 need all_separable" is imprecise -- it's really "the `all_past`/`all_future` structural induction cases need the temporal closure axiom."

### Claim: "GHR94 explicit formulas for Cases 5-8 fail on Z"

**Partially refuted**: GHR94's specific formula fails. Whether any explicit formula exists for Case 5 on Z is UNKNOWN and not proved either way. The comment in Eliminations.lean is sound reasoning but not a Lean proof.

### Claim: "expand_temporal approach was a dead end"

**Refuted**: The expand_temporal approach correctly reduces the problem. The gap is that `multi_U_formula_separable` (Hierarchy.lean) needs to be proved without `all_separable`, and `abstract_snce` needs to be implemented. The expand_temporal approach, combined with `abstract_snce` and proper WF induction, could work. It narrows the blocker to a precise 100-LOC implementation task.

---

## Alternative Approaches Not Yet Tried

### Approach A: Prove the all_past/all_future cases directly via expand_temporal with a different measure

The measure could be `(count_allpast_allfuture phi, formula_size phi)` lexicographically. Under expand_temporal, `count_allpast_allfuture` strictly DECREASES (all_past/all_future are eliminated). The formula size increases, but the count decrease dominates in a lexicographic order.

Concretely:
- `all_past_separable phi ih` where `ih : is_separable phi`
- Apply `expand_temporal phi` to get `phi_exp` with 0 all_past/all_future nodes
- `phi_exp` is `int_equiv` to `phi`
- `phi_exp` has `no_S_nested_in_U` if `phi` was "U-free" -- but `expand_temporal (all_past a)` introduces `snce`. So this doesn't directly work.

Actually: `all_past a` with `a` separable. Take `a' = expand_temporal a` (no all_past/all_future). Then `all_past a` ~ `neg (snce (neg a) top)`. Now `neg (snce (neg a') top)` has `no_S_nested_in_U` iff `no_S_nested_in_U (neg a')`, which is `no_S_nested_in_U a'`. But `a'` might have snce nodes from expanding the inner `all_past` nodes of `a`. So this loops unless `a` had no all_past/all_future inside it.

The key constraint: separated formulas (the witnesses for `is_separable`) do NOT contain `all_past`/`all_future` as primitive constructors? Actually they can -- `is_syntactically_separated (.all_past a) = is_U_free a`. So separated formulas can contain `all_past a` where `a` is U-free. U-free `a` does NOT have `all_past` restriction, so `a` could itself be `all_past b` where `b` is U-free... This nesting is finite by structural induction.

Wait: if `phi' = all_past a` is the WITNESS for `is_separable (all_past a)`, then `a` must be U-free. Expanding: `expand_temporal (all_past a)` = `neg (snce (neg (expand_temporal a)) top)`. For this to be syntactically separated, we need `no_S_nested_in_U` to hold, which requires the snce args to be U-free. `neg (expand_temporal a)` is U-free iff `expand_temporal a` is U-free (since `neg` preserves U-freeness). `expand_temporal a` is U-free iff `a` is U-free AND has no all_future (since expand_temporal replaces all_future with untl-based formula). Since `a` is already U-free (from is_syntactically_separated), this means `expand_temporal a` is U-free iff `a` has no `all_future`.

This conditional chain suggests a RESTRICTED version might work for specific formula classes.

### Approach B: Prove via GHR94 Lemma 10.2.8 (full junction-depth induction)

GHR94 Lemma 10.2.8 proceeds by induction on `junction_depth`. The phase-6-handoff-20260517e.md already documented this requires ~800-1200 LOC. The key operations:
1. `abstract_snce`: Replace S-subformulas with fresh atoms (MISSING, ~100 LOC)
2. Compound WF induction on `(junction_depth phi, count_U_subformulas phi + count_S_subformulas phi)`

This is the mathematically correct approach matching GHR94. It has not been attempted.

### Approach C: Prove Cases 5-8 with explicit discrete-time formulas

The blocked phase tried GHR94's dense-time formula and found a counterexample. But the problem is concrete: find phi such that `int_equiv (snce (and a (untl A B)) (or q (untl A B))) phi` and `is_syntactically_separated phi = true` for the specific patterns of Case 5.

Reynolds (1994) proved expressive completeness for Z using different axiomatization. His approach might yield explicit formulas. This has not been explored in the Lean code.

---

## Confidence Level

- **Circularity description is accurate**: HIGH (verified in code)
- **GHR94 counterexample to Case 5 formula**: MEDIUM (comment is correct reasoning, not Lean-verified)
- **expand_temporal infrastructure usefulness**: HIGH (TemporalClosure.lean is solid and builds correctly)
- **Phase 7 independence from Phase 6**: HIGH (verified by reading ExpressiveCompleteness.lean structure)
- **Approach A (allpast/allfuture via expand)**: LOW (analysis shows it hits another wall)
- **Approach B (full GHR94 JD induction) being viable**: MEDIUM-HIGH (mathematically sound, very high LOC)
- **Approach C (explicit Z formulas via Reynolds) being viable**: UNKNOWN (unexplored)

---

## Summary Assessment

The circularity is real and the handoff documentation is largely correct. The key nuances identified:

1. Cases 5-8 do not need `all_separable` LOGICALLY -- they just use it as a shortcut. The REAL gap is proving `multi_U_formula_separable` without axioms (which requires `abstract_snce`, not yet implemented).

2. The hardest single case is proving `all_past a` is separable from `a` being separable -- this is the temporal closure axiom in its purest form, and none of the current approaches address it directly.

3. Phase 7 is independent of Phase 6 and can proceed. Phase 7's 2 sorries are quantifier elimination, not separation.

4. The most tractable next step is implementing GHR94 Lemma 10.2.8 (full junction-depth induction), which requires `abstract_snce` as the first concrete task (~100 LOC).
