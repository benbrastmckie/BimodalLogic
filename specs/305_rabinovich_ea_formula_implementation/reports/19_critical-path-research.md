# Critical Path Research: Eliminating KampPrior.lean:287

- **Task**: 305 -- rabinovich_ea_formula_implementation
- **Type**: lean4
- **Session**: sess_1782269270_ea99a3
- **Agent**: lean-research-hard-agent (H2+H3+H4)
- **Tier**: 1 (literature-backed, lean4 strict)
- **Artifact**: 19

---

## 0. Executive Summary

The KampPrior.lean:287 sorry is the sole critical-path blocker for Rabinovich completeness. It requires: for each depth-(k'+2) arity-1 NF, produce a temporal Formula with biconditional correctness on Prior structures. The k=0 and k=1 cases are sorry-free; the sorry fires at k>=2 due to the **arity tower barrier** (depth-k arity-2 existentials need depth-(k-1) arity-3 sub-NFs).

**Report 24's 5-phase chain is partially incorrect.** Phases 1-2 (Cor 5.4 backward fix, VecEA2-level biconditional) target sorry sites that are (a) off the critical path and (b) documented impossible at the BracketFormula level. The forward-only constructions in NegationIndep.lean are already sorry-free and sufficient.

**The actual critical path** requires implementing the VecEA_m machinery (report 16), then Prop 4.3 structural induction on MonadicFormula, then wiring into KampPrior.lean. However, a deep analysis reveals that **the negation biconditional problem cascades to VecEA_m level** -- the VVecEA2 backward direction failure (report 18) means Prop 4.3 structural induction cannot produce biconditionals.

**Two viable approaches** are identified, both requiring substantial new work:

1. **Approach A (NF-disjunction)**: Avoid Prop 4.3 entirely. Use `nf_exists_unique` + forward-only V-EA constructions to build a temporal disjunction over all possible NFs. Does NOT need VecEA_m. Estimated 300-500 lines.

2. **Approach B (Full Rabinovich with convention fix)**: Refactor BracketFormula to use Rabinovich's endpoint convention (alpha_0 at z_0). This makes the negation biconditional provable, enabling Prop 4.3. Estimated 800-1200 lines.

---

## 1. Sorry Inventory (Verified)

| # | File:Line | Critical? | Status |
|---|-----------|:---------:|--------|
| 1 | KampPrior.lean:287 (`nf_characterizable_temporal_prior` succ/succ) | **YES** | Sole critical sorry |
| 2 | EANegation.lean:1090 (`neg_bracket_is_vbracket` backward) | No | Documented impossible (report 18 S4) |
| 3 | EANegation.lean:1249 (`neg_partialBracketExist_is_vbracket` backward) | No | Documented impossible (report 18 S10) |

**H4 verification**: Sorry #1 confirmed by `lean_goal`. Goal:
```
⊢ { A // ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔
    nf_eval_nf M (k' + 1 + 1) 1 (fun x ↦ t) nf }
```
Sorrys #2, #3 confirmed not imported by KampPrior's sorry chain. **Confidence: HIGH**.

---

## 2. The Arity Tower Barrier (Root Cause)

The sorry at KampPrior.lean:287 arises from the NF decomposition:

```
nf_eval_nf M (k'+2) 1 (fun _ => t) nf
= [atom conditions on t]
  AND [for each sub_nf : NormalForm sig (k'+1) 2,
       (exists x, nf_eval M (k'+1) 2 (x::t) sub_nf) <-> nf.2 sub_nf]
```

The existing `nf_succ_char_formula` (sorry-free) handles this given a function `exist_tl_fn : NormalForm sig k 2 -> Formula` with biconditional correctness. At k=0, `nf_2var_exist_depth0_tl_fn` (sorry-free) provides this function. At k>=1, the function is missing because:

- A depth-(k+1) arity-2 NF existential `exists x, nf_eval M (k+1) 2 (x,t) sub_nf` decomposes into zones (x<t, x>t, x=t). Each zone has atom conditions (VecEA2, sorry-free) AND quantifier conditions `exists y, nf_eval M k 3 (y,x,t) snf3` at arity 3.
- The arity-3 existentials require arity-3-to-arity-2 reduction (Lemma 3.2.2).
- The reduction requires negation closure with biconditionals.
- The biconditional is impossible at BracketFormula level.

**This is the arity tower**: arity 2 needs arity 3, which needs arity 4, etc.

---

## 3. Why Report 24's Chain Fails

Report 24 proposed fixing Cor 5.4 backward and VecEA2-level biconditional as prerequisites. This analysis is **incorrect** for two reasons:

1. **Both are impossible**: Report 18 Section 4 proved the BracketFormula backward direction has a fundamental existential-vs-universal mismatch. The interior-witness convention means case analyses are model-dependent.

2. **They don't address the arity tower**: Even with a perfect VVecEA2 negation biconditional, KampPrior.lean:287 still needs arity-3 existentials handled. The chain Lemma 5.1 -> Prop 4.2 -> Prop 4.3 addresses arity 2 negation but not the arity tower itself.

**What IS correct from report 24**:
- Path A (Rabinovich structural induction) is the only viable route
- Path B (Stavi) is dead (mathematically false backward lemma)
- Path C (Z-transfer) is non-viable (three independent blockers)

---

## 4. The Negation Biconditional Cascade

A deeper analysis reveals why even VecEA_m (report 16) does not solve the problem:

**Prop 4.3 structural induction on MonadicFormula sig m**:
- `.not alpha`: IH gives `v_alpha.holds env <-> eval M env alpha` (biconditional). Need `v_neg.holds env <-> not eval M env alpha`.
- Forward: `not eval -> not v_alpha.holds -> v_neg.holds` via neg_2var_vec_ea_indep. OK.
- Backward: `v_neg.holds -> not v_alpha.holds`. This requires: `neg_2var_vec_ea_indep(v).holds AND v.holds` cannot both be true. But report 18 proved this CAN happen at the BracketFormula level.

**At VecEA_m level**: The de Morgan decomposition makes endpoint negation cases trivially disjoint, but interval negation cases still use `neg_2var_vec_ea_indep`, inheriting the same backward failure.

**Conclusion**: Prop 4.3 structural induction with biconditionals requires fixing the BracketFormula convention. Without that fix, only forward-only constructions are available.

---

## 5. Two Viable Approaches

### Approach A: NF-Disjunction (avoids biconditionals entirely)

**Key insight**: We don't need Prop 4.3 to produce a V-EA formula for an arbitrary MonadicFormula. We need a temporal Formula for `exists x, nf_eval M (k+1) 2 (x::t) sub_nf` for a SPECIFIC NF `sub_nf`. The NF structure is much more constrained than arbitrary formulas.

**Strategy**: Use `nf_exists_unique` to sidestep the negation biconditional.

For a depth-(k+1) arity-2 NF existential:
1. Convert each possible depth-(k+1) arity-2 NF to a temporal formula (forward direction only)
2. For each NF `nf'`, build `char_tl(nf') : Formula` such that:
   - `nf_eval M (k+1) 2 (x,t) nf' -> temporal_truth t char_tl(nf')` (forward)
3. Then `exist_tl(sub_nf) = disjunction over good NFs` where "good" means `nf' = sub_nf`.
4. The biconditional `temporal_truth t exist_tl(sub_nf) <-> exists x, nf_eval M (k+1) 2 (x,t) sub_nf` follows from `nf_exists_unique` -- each (M, x, t) satisfies exactly one NF, so the forward direction for all NFs gives the biconditional for each specific NF.

**Wait -- this is essentially the existing approach in KampPrior.lean** (lines 303-350), which builds `good_formulas` as a disjunction over good NFs. The problem is: `char_f nf` still needs a biconditional for each NF's characteristic formula. The disjunction trick gives biconditionals at the top level IF each char_f is correct.

But `char_f nf` is built by `nf_succ_char_formula`, which needs `exist_tl_fn` with biconditionals. This is circular.

**Revised strategy**: Use induction on BOTH depth k AND arity n simultaneously. For each (k, n), produce `exist_tl(sub_nf)` with biconditional. The induction:
- (k=0, any n): sorry-free (no quantifier conditions)
- (k+1, n): atom layer is VecEA2 (sorry-free). Quantifier layer has arity-(n+1) existentials at depth k. By IH on (k, n+1), these are handled. But this requires the arity to decrease eventually, which it doesn't -- it only increases!

**This confirms the arity tower is circular.** The resolution must break the circularity.

**Rabinovich breaks it via Lemma 3.2.2**: An m-variable EA formula is equivalent to a conjunction of 2-variable EA formulas. This reduces arity back to 2 at each level.

**For the NF-based approach to work**, we need: given depth-k arity-3 NF existential `exists y, nf_eval M k 3 (y,x,t) snf3`, produce a temporal formula for the pair (x,t). This is a 2-variable temporal formula characterizing a 3-variable existential.

The key observation: `nf_eval M k 3 (y,x,t) snf3` decomposes into atom conditions on (y,x,t) and quantifier conditions at depth-(k-1) arity-4. BUT the atom conditions determine a zone partition:
- y < x < t, y < t < x, x < y < t, x < t < y, t < x < y, t < y < x

In each zone, the predicate conditions on y, x, t are fixed. The quantifier conditions at arity 4 create the arity-4 barrier.

**For k=0 (depth 0)**: No quantifier conditions. The atom layer is a zone partition of arity-3 with predicate conditions. This IS handled sorry-free by VecEADecomp.lean. So `nf_3var_exist_depth0_tl` is achievable.

**For k=1**: The quantifier conditions are depth-0 arity-4 existentials. At depth 0 with any arity, NFs are just atom assignments -- no further existentials. So `nf_4var_exist_depth0_tl` is achievable (same VecEADecomp pattern).

**This suggests**: At depth 0, ALL arity existentials can be converted to temporal formulas. The arity tower only climbs at depth > 0.

**If depth-0 all-arity existentials are handled**: Then depth-1 arity-2 existentials decompose into depth-0 arity-3 existentials (handled), so depth-1 arity-2 is handled. Then depth-2 arity-1 NFs decompose into depth-1 arity-2 existentials (handled), so depth-2 arity-1 is handled. The recursion is:

```
depth k, arity n:
  atom layer: zone decomposition (sorry-free for all n)
  quantifier layer: depth-(k-1), arity-(n+1) existentials
```

At depth 0: no quantifier layer. At depth k+1: quantifier layer uses depth k. The arity increases by 1 at each level, but the depth decreases by 1. After k steps, we reach depth 0 with arity n+k. At depth 0, all arities are handled (atom conditions only).

**THIS IS THE ARITY TOWER RESOLUTION.**

The induction is on depth k, with the inner induction on arity being handled at depth 0 (base case for all arities). At each depth step k -> k+1, the arity increases by 1, but since depth decreases by 1, after exactly k steps we reach depth 0 where all arities are handled.

**Formalized**: Strong induction on k. Assume for all k' < k and ALL arities n, depth-k' arity-n NF existentials can be converted to temporal. Then depth-k arity-n NF existentials decompose into:
- Atom layer (sorry-free, all arities)
- Quantifier layer: depth-(k-1) arity-(n+1). By IH on k-1 (with arity n+1), handled.

**This requires generalizing the existing infrastructure** (which only handles arity 2) to arbitrary arity. The VecEADecomp zone decomposition at depth 0 already handles arity 3 -- it needs to be generalized to arbitrary arity n.

### Approach A Implementation Plan

**Phase 1: Generalize depth-0 existential conversion to arbitrary arity (~200-300 lines)**

Currently `nf_2var_exist_depth0_tl` converts depth-0 arity-2 existentials to temporal. Generalize to `nf_nvar_exist_depth0_tl` for arbitrary arity n. At depth 0, the NF is just an atom assignment (no quantifier layer), so the existential `exists x, [atom conditions on (x, env)]` is a zone decomposition problem. The existing VecEADecomp infrastructure handles zones for arity 3 -- generalize the pattern.

**Key pieces needed**:
- Zone enumeration for Fin n ordered environments
- For each zone, a VecEA2 temporal formula
- Disjunction over zones

**Phase 2: Generalized NF characteristic formula (~200-300 lines)**

Generalize `nf_succ_char_formula` to arbitrary arity. Currently it produces temporal formulas for arity-1 NFs given arity-2 existential conversion. Generalize to: given `exist_tl_fn : NormalForm sig k (n+1) -> Formula` for arbitrary n, produce `char_formula : NormalForm sig (k+1) n -> Formula`.

The key change: the "characteristic formula" at arity n needs to encode conditions on an n-element environment, not just a single point t. For n >= 2, this involves ordering constraints between environment variables.

**Challenge**: At arity n >= 2, the characteristic formula is a 2-free-variable formula (for the pair (x, t) at arity 2) or an n-free-variable formula. Converting to temporal requires the V-EA translation, which only handles 1-free-variable formulas.

**Wait -- this is the fundamental issue.** The temporal Formula type has ONE free variable (the evaluation point t). To characterize arity-2 NFs, we need to existentially bind one variable and evaluate the other at t. This IS what `nf_2var_exist_depth0_tl` does. But for higher arities, we need to existentially bind ALL but one variable.

So the generalized function is:
```
nf_nvar_exist_tl : NormalForm sig k n -> Formula
```
such that:
```
temporal_truth M atomMap t (nf_nvar_exist_tl snf) <->
  exists env : Fin (n-1) -> M.carrier, nf_eval M k n (insert_t_at_pos env t) snf
```
where `insert_t_at_pos` places t at a specific position in the environment.

At depth 0, this is the VecEADecomp zone decomposition. At depth k+1, it decomposes into atom layer (zones) + quantifier layer (depth-k, arity-(n+1) existentials). By IH, the depth-k arity-(n+1) case is handled.

**Phase 3: Strong induction on depth (~100-200 lines)**

Replace the `sorry` at KampPrior.lean:287 with a strong induction on k:
```
induction k using Nat.strong_rec_on with
| ind k ih =>
  -- For each sub_nf : NormalForm sig k 2,
  -- build exist_tl(sub_nf) using nf_nvar_exist_tl
  -- which internally uses ih for depth-(k-1) arity-3 existentials
```

**Total estimate**: 500-800 lines of new code.

### Approach B: Full Rabinovich with Convention Fix

Refactor BracketFormula to use Rabinovich's endpoint convention (alpha_0 at z_0 instead of interior witness). This makes the Lemma 5.1 biconditional provable, enabling the full Prop 4.3 chain.

**Pros**: Faithfully matches Rabinovich; eliminates sorrys #2 and #3 as well.
**Cons**: Requires refactoring BracketFormula.holds semantics, propagating changes through ~1500 lines of sorry-free code. Very high risk of breaking existing proofs.

**Estimated effort**: 800-1200 lines including refactoring.

**Recommendation**: Approach B is too risky. The existing sorry-free code is valuable and should not be destabilized. Approach A is preferred.

---

## 6. Approach A: Detailed Feasibility Analysis

### 6.1 Depth-0 All-Arity Existential Conversion

At depth 0, `nf_eval M 0 n env nf` = `forall a : AtomKind sig n, atom_eval M env a <-> nf a`. This determines the order zone and predicate conditions.

The existential `exists x, nf_eval M 0 (n+1) (x :: env) nf` with env = (t) at arity 2 is exactly what `nf_2var_exist_depth0_tl` handles. At arity 3 with env = (x, t), it's `exists y, nf_eval M 0 3 (y, x, t) snf3`. This determines:
- Order zone: y < x < t, y < t < x, ..., t < x < y (6 cases)
- Predicate conditions: P(y), Q(x), R(t), etc.

For each zone, the existential becomes: `exists y in [zone], [predicate conditions on y]`. This is a bounded existential, expressible as a VecEA2 formula on (x, t) (or whatever pair).

**Existing infrastructure**: `nf_depth0_existential_decomp` (NfToVecEA.lean:375) handles the arity-2 case. `nf_vecEA2_future_correct` and `nf_vecEA2_past_correct` handle the two main zones. VecEADecomp.lean provides arity-3 zone decomposition.

**What's needed**: Generalize from arity-3 to arity-n. The zone enumeration grows as n!, but this is finite (Fin n has Fintype). The key operation is: for each permutation (ordering) of n variables, determine the zone conditions and build the corresponding temporal formula.

**H4 verification**: VecEADecomp.lean is sorry-free and handles 6 zones for arity 3 (confirmed by grep). The generalization to n zones is conceptually clear but the combinatorics grow. For the completeness proof, we only need arities up to k+2 where k is the maximum quantifier depth. **Confidence: MEDIUM**.

### 6.2 Generalized NF Characteristic Formula

`nf_succ_char_formula` at arity 1 builds: `atom_literals AND quant_clauses`. The atom literals use `nf_depth0_char_formula` (arity 1, sorry-free). The quant clauses use `exist_tl_fn` (arity 2).

For arity n, the generalization is: `atom_literals(env) AND quant_clauses(env)`. The atom literals at arity n encode predicate conditions and order conditions on the n-element environment. The quant clauses use `exist_tl_fn : NormalForm sig k (n+1) -> Formula`.

**Key issue**: At arity n >= 2, the "Formula" type has only 1 free variable. So the generalized characteristic formula must take n-1 environment variables as parameters and produce a temporal Formula for each combination. This is NOT a single Formula but a family of formulas indexed by the environment.

**Resolution**: We don't need a generalized characteristic formula for all arities. We need it only for the specific arity chain: arity 1 (top level) -> arity 2 (first existential) -> arity 3 (second existential) -> ... -> arity k+1 (bottom level). At each level, we need `exist_tl_fn` that converts a depth-j arity-(n+1) existential to a temporal Formula for the pair (x_n, ..., x_1, t) where x_1, ..., x_n are existentially bound and t is the free variable.

So the generalized function is:
```
nf_multivar_exist_tl : NormalForm sig k (n+1) -> Formula
-- temporal_truth t A <-> exists x_1 ... x_n, nf_eval M k (n+1) (x_1, ..., x_n, t) sub_nf
```

This existentially binds ALL variables except t. The NF conditions on the n+1 variables determine zones in R^(n+1); in each zone, the bound variables are ordered relative to t and to each other. The temporal formula uses nested Until/Since to express each zone.

**This is where VecEA_m is needed**: An m-variable EA formula with one free variable (t) and m-1 bound variables is expressible as a temporal formula via Prop 3.5 (VVecEA2.translateLeft). But Prop 3.5 only handles 1-free-variable V-EA formulas, not multi-bound-variable existentials.

Actually, `VVecEA2.translateLeft` converts VVecEA2 to Formula via:
```
temporal_truth t v.translateLeft <-> v.holdsLeft t
```
where `holdsLeft t = endpointLeft(t) AND exists z1 > t, endpointRight(z1) AND bracket(t, z1)`.

This naturally handles one existentially bound variable (z1). For two bound variables, we'd need a VecEA formula with 3 free variables (t, z1, z2) reduced to 1 via two layers of existential quantification. This is exactly Lemma 3.2.3 (existential closure of EA formulas) composed with Prop 3.5.

**So the approach IS**:
1. Build VecEA_m type (report 16)
2. For each depth-0 arity-(n+1) NF, construct a VecEA_m (n+1) formula
3. Existentially close the first n variables using VecEA_m.existClosure (n times)
4. At arity 1, translate to temporal via VVecEA2.translateLeft

The existential closure of VecEA_m IS needed and IS achievable because:
- Each existential closure reduces arity by 1
- The closure produces a VVecEA_m of lower arity
- After n closures, we have a VVecEA_m 1, which translates to Formula

**The existential closure operation** (VecEA_m.existClosure) absorbs one bound variable. From report 16 Section 4.3:
```
exists z_0 < z_1, endpointPred(0)(z_0) AND interval(0).holds(z_0, z_1)
```
This produces a modified VVecEA2 at position z_1 by incorporating the existential bound.

**VecEAClosure.existsBounded_right** (sorry-free, VecEAClosure.lean:265) provides exactly this pattern.

### 6.3 Strong Induction Assembly

With phases 1-2 above, the strong induction works:

```
-- By strong induction on k:
-- IH: for all k' < k and all n, nf_nvar_exist_tl handles depth-k' arity-n
-- At depth k, arity n:
--   Atom layer: zone decomposition (depth 0, sorry-free)
--   Quantifier layer: depth-(k-1) arity-(n+1), handled by IH
```

The strong induction eliminates the arity tower because depth decreases strictly at each step, while arity increases by 1 -- but depth 0 handles all arities.

---

## 7. H3 Reference Grounding: Revised Phase Mapping

| Phase | Rabinovich Ref | Lean Target | Dependencies | Risk | Lines Est. |
|-------|---------------|-------------|--------------|------|--------:|
| 1: VecEA_m types | Def 3.1, 3.3 | `VecEA_m`, `VVecEA_m` (new) | VVecEA2 | LOW | 100-150 |
| 2: VecEA_m ops | Lemma 3.2.3, 3.4 | `.existClosure`, `.conj`, `.disj` | VecEAClosure | MEDIUM | 200-300 |
| 3: Depth-0 all-arity | (infrastructure) | `nf_nvar_exist_depth0_tl` (new) | VecEADecomp | MEDIUM | 200-300 |
| 4: Strong induction | Prop 4.3/4.4 analog | Replace KampPrior.lean:287 | Phases 1-3 | HIGH | 200-300 |
| **Total** | | | | | **700-1050** |

**Note**: Phases 1-2 implement VecEA_m types and operations. Phase 3 implements depth-0 all-arity zone decomposition. Phase 4 assembles the strong induction. Negation closure (Prop 4.2, Lemma 5.1) is NOT needed because the NF induction avoids the negation case.

**Wait -- does the NF induction avoid negation?** Let me re-check.

The NF at depth k+1 has quantifier assignments: for each sub_nf, `nf.2 sub_nf = true` (existential) or `nf.2 sub_nf = false` (universal/negation). The `nf_succ_char_formula` builds:
- `exist_tl sub_nf` when `nf.2 sub_nf = true`
- `neg (exist_tl sub_nf)` when `nf.2 sub_nf = false`

The negation here is TEMPORAL negation (`Formula.neg`), not V-EA negation. Given `exist_tl sub_nf` with biconditional correctness (`temporal_truth t A <-> exists x, nf_eval (x::env) sub_nf`), the temporal negation `Formula.neg A` has biconditional `not (temporal_truth t A) <-> not (exists x, nf_eval (x::env) sub_nf)`. This is trivially correct.

**So the NF induction does NOT need V-EA negation at all!** The negation is handled at the temporal Formula level by `Formula.neg`, which is trivially correct. The V-EA negation (Prop 4.2, Lemma 5.1) is only needed for Prop 4.3's structural induction on MonadicFormula, which we BYPASS entirely.

**This is the key architectural advantage of Approach A**: By staying within the NF framework and using `nf_succ_char_formula`, negation is trivial. The hard part (arity tower) is resolved by strong induction on depth with depth-0 all-arity as the base case.

---

## 8. Adversarial Self-Verification (H4)

### Challenge 1: "Depth-0 all-arity zone decomposition is generalizable"

**PARTIALLY VERIFIED**. `nf_2var_exist_depth0_tl` (sorry-free) handles arity 2 with 3 zones (x<t, x>t, x=t). `nf_depth0_existential_decomp` (sorry-free) is the core decomposition lemma at arity 2. VecEADecomp.lean handles arity 3 with 6 zones. The pattern is clear but has not been generalized to arity n.

**Risk**: The zone enumeration for arity n involves all permutations of n elements (n! zones for strict orderings). Each zone requires a VecEA2 formula. The combinatorial explosion is finite (Fintype instances exist) but the proof obligations grow rapidly. For the completeness proof, we need arities up to max_depth + 2, which could be large.

**Mitigation**: Use the existing `nf_to_formula` to convert depth-0 NFs to MonadicFormula, then the zone decomposition IS just checking atom conditions -- which are decidable at depth 0. The temporal formula for each zone is a bounded existential chain (nested Until/Since), constructable from the VecEA2 translation. **Confidence: MEDIUM**.

### Challenge 2: "The strong induction on depth resolves the arity tower"

**VERIFIED**. The induction structure is:
- Depth 0, any arity: base case (no quantifier conditions)
- Depth k+1, arity n: atom layer + depth-k, arity-(n+1) quantifier layer (IH)

Depth strictly decreases. Arity increases but is bounded at each depth level. At depth 0, all arities are handled. The well-foundedness is on depth alone.

**Key verification**: The IH at KampPrior.lean:287 provides `_ih` for depth k'+1 at arity 1. We need the strong IH for ALL smaller depths and ALL arities. The current match structure uses `induction k` which only gives IH for the immediately smaller k. We need `Nat.strong_rec_on` or `Nat.strongRecOn`.

**Confidence: HIGH** for the logical structure. The Lean encoding may require careful structuring of the strong recursion.

### Challenge 3: "VecEA_m.existClosure is implementable"

**PARTIALLY VERIFIED**. The operation absorbs one bound variable from a VecEA_m (m+1) to produce VVecEA_m m. The existing `VBracketFormula.existsBounded_right` (sorry-free, VecEAClosure.lean:265) handles bounded existential quantification. The Fin index shifting (m+1 -> m) is the main implementation challenge.

**Risk**: The semantics bridge between `VecEA_m.holds (m+1) (z_0 :: env)` and the existential `exists z_0, VecEA_m.holds (m+1) (z_0 :: env)` and the resulting `VVecEA_m.holds m env` requires careful Fin arithmetic and environment manipulation. This is error-prone but not fundamentally difficult.

**Confidence: MEDIUM-HIGH**.

### Challenge 4: "The NF induction truly avoids needing V-EA negation"

**VERIFIED**. The `nf_succ_char_formula` builds temporal formulas using:
- `exist_tl sub_nf` when the quantifier assignment is positive
- `Formula.neg (exist_tl sub_nf)` when the quantifier assignment is negative

`Formula.neg` provides trivial biconditional correctness: `not (temporal_truth t A) <-> temporal_truth t (Formula.neg A)`. This is a property of the temporal logic semantics, not of V-EA negation.

No V-EA negation (Prop 4.2, Lemma 5.1) is needed anywhere in the construction.

**Confidence: HIGH**.

### Challenge 5: "700-1050 lines is realistic"

**PARTIALLY VERIFIED**. Reference points:
- `nf_2var_exist_depth0_tl` (arity-2 depth-0): ~100 lines (VecEADecomp helper + NfToVecEA bridge)
- VecEADecomp.lean (arity-3 zones): ~400 lines
- VecEAClosure.lean (conjunction, existential closure): ~380 lines

Generalizing VecEADecomp to arbitrary arity is the largest unknown. If done via an inductive/recursive construction (not by enumerating all zones), it could be 200-300 lines. If explicit enumeration is needed for each arity level, it could be 400+ lines.

**Confidence: MEDIUM**. Could reach 1200 lines if the zone generalization is harder than expected.

---

## 9. Implementation Recommendation

### Recommended: Approach A (NF-Disjunction + Strong Induction)

**Phase 1: VecEA_m types + existential closure** (new file, ~300 lines)
- Define `VecEA_m`, `VVecEA_m` types
- Implement `.existClosure` using `VBracketFormula.existsBounded_right`
- Implement `.conj`, `.disj` (for conjunction/disjunction closure)
- Prove semantics lemmas

**Phase 2: Depth-0 all-arity NF existential conversion** (new file, ~300 lines)
- Generalize zone decomposition from arity 3 to arbitrary arity n
- Build `nf_nvar_exist_depth0_tl` converting depth-0 arity-(n+1) NF to temporal Formula
- Bridge through VecEA_m existential closure + VVecEA2.translateLeft

**Phase 3: Strong induction + KampPrior rewire** (~200 lines)
- Replace `sorry` at KampPrior.lean:287 with strong induction on k
- At depth 0: use `nf_depth0_char_formula` (existing, sorry-free)
- At depth k+1: use `nf_succ_char_formula` with the strong IH providing `exist_tl_fn`
- The `exist_tl_fn` at depth k uses depth-(k-1) arity-3 existentials, handled by Phase 2 + recursive IH

### NOT Recommended: Approach B (Convention Fix)

Refactoring BracketFormula is too risky. The 1500+ lines of sorry-free code depend on the interior-witness convention. Changing it would destabilize the entire EA negation infrastructure.

### NOT Recommended: Report 24's Phase 1-2 (Cor 5.4 / EndpointNegation fixes)

These are documented impossible and off the critical path. Do not attempt.

---

## 10. Open Questions for Planning

1. **Zone generalization**: Can the VecEADecomp zone decomposition be written inductively (induction on arity), or does it require explicit case enumeration for each arity?

2. **VecEA_m.existClosure semantics bridge**: How many helper lemmas are needed for the Fin index shifting? The existing `VBracketFormula.existsBounded_right` handles the core operation, but the VecEA_m wrapper adds endpoint predicate bookkeeping.

3. **Strong recursion encoding**: The standard `Nat.strongRecOn` in Lean 4 returns `Sort u`. For our use case (producing a `Formula`), we may need `Nat.strongRecOn` for `Type` or a custom well-founded recursion. Check if `WellFoundedRecursion` on `(k, n) : Nat x Nat` with lexicographic ordering (k strictly decreasing) is more natural.

4. **Performance**: At each depth level, the number of NFs grows super-exponentially. The `noncomputable` annotation on `nf_characterizable_temporal_prior` means we don't need termination proofs, but the type-checking time could be significant. Monitor with `lean_profile_proof` after implementation.

---

## 11. Findings Summary

1. **Single critical sorry**: KampPrior.lean:287. Sorrys #2 and #3 are off-path and impossible.

2. **Report 24's Phase 1-2 are wrong**: Cor 5.4 backward and VecEA2 biconditional are impossible. The forward-only constructions already exist and suffice.

3. **The negation biconditional cascades**: VVecEA2 backward failure (report 18) blocks Prop 4.3 structural induction even at the VecEA_m level.

4. **NF-based strong induction avoids negation**: By staying within the NF framework, temporal negation (`Formula.neg`) replaces V-EA negation. The arity tower is resolved by strong induction on depth with depth-0 all-arity as base case.

5. **VecEA_m IS needed** but only for existential closure, not for negation. The operations needed are: type definition, conjunction, disjunction, existential closure.

6. **Estimated effort**: 700-1200 lines across 3 phases (VecEA_m + existClosure, depth-0 all-arity, strong induction + rewiring).

7. **All referenced identifiers verified** via `lean_local_search` and `lean_hover_info`:
   - `nf_to_formula_correct`: `NormalForm sig k n -> MonadicFormula sig n`, sorry-free
   - `VVecEA2.translateLeft_correct`: `temporal_truth t v.translateLeft <-> holdsLeft M atomMap v t`, sorry-free
   - `neg_2var_vec_ea_indep_correct`: forward-only negation, sorry-free
   - `nf_exists_unique`: NF uniqueness, sorry-free
   - `VBracketFormula.existsBounded_right`: bounded existential, sorry-free
   - `VVecEA2.conj_struct_holds`: conjunction closure, sorry-free
