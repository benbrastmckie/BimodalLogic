# Handoff: Phase 3 Dispatch 2 — n=0 case proved, n=1 analysis complete

## Immediate Next Action

Prove the n=1 case of `nf_nvar_exist_all_depths` at KampPrior.lean:406. This is the SOLE blocker for the main theorem `kamp_prior_expressive_completeness` to be sorry-free.

## Current State

- **Phase**: 3 (IN PROGRESS)
- **Sorry count**: 2 (n=1 at line 406, n≥2 at line 409)
- **Build status**: passes
- **Critical path sorry**: n=1 case at depth k+1 (line 406)

### What was accomplished

1. **Restructured k+1 case** of `nf_nvar_exist_all_depths` with match on n:
   - n=0: PROVED — uses char_k1 (inlined nf_characterizable_temporal_prior at depth k+1)
   - n=1: sorry — critical path
   - n≥2: sorry — off critical path

2. **Built infrastructure** for n=1 proof:
   - `ih_exist_1`: exist at depth k for arity 2 (from IH), with Fin.cons bridge
   - `exist_tl_fn_k`: formula function at depth k for arity 2
   - `exist_tl_fn_k_correct`: correctness
   - `char_k1`: characteristic formula at depth k+1 arity 1
   - `char_k1_correct`: correctness

### What was NOT accomplished

The n=1 case at depth k+1 could not be proved. Extensive analysis (documented below) shows this is a genuine mathematical difficulty, not just a coding problem.

## Key Decisions

### Why n=0 works but n=1 doesn't

- **n=0**: The Fin 0 existential is trivial, so `∃ env : Fin 0, nf_eval_nf M (k+1) 1 (insertEnv env t) sub_nf` simplifies to `nf_eval_nf M (k+1) 1 (fun _ => t) sub_nf`, which is exactly what char_k1 characterizes.

- **n=1**: The condition `∃ x, nf_eval_nf M (k+1) 2 (x, t) sub_nf` requires a temporal formula for the 1-variable existential at depth k+1. This is equivalent to `(nf_characteristic M (k+2) 1 t).2 sub_nf = true`, so it depends on the depth-(k+2) arity-1 NF of t. Building a temporal formula for this requires char at depth k+2, which requires exist at depth k+1 (self-referential).

### The circularity problem

The formula for `exist(k+1, 1, sub_nf)` requires `char(k+2, nf')` for each good depth-(k+2) NF. And `char(k+2, nf')` = `nf_succ_char_formula(exist_1var_fn, nf')` where `exist_1var_fn = exist(k+1, 1, ·)`. So the formula for exist(k+1, 1, sub_nf) uses itself (for different sub_nf' values).

### Approaches analyzed and their status

1. **NF disjunction at depth k+2** (self-referential): The formula can be defined self-referentially as `f(sub) = disjunction over {nf' | nf'.2 sub} of nf_succ_char_formula(f, nf')`. The correctness proof uses a "P=Q" argument showing truth values must match the characteristic NF. ISSUE: The self-referential formula definition is not directly expressible in Lean (would need a fixed-point combinator for Formula, which doesn't exist).

2. **Mutual recursion** (char + exist at same depth): Define both char(k+2) and exist(k+1, 1) simultaneously. The combined definition has no self-reference (each uses the other). ISSUE: Lean's `mutual def` for noncomputable definitions with dependent types may be tricky.

3. **Well-founded recursion on 2k+n**: Measure `2(k+1)+1 = 2k+3`. Need exist(k, 1) which has measure 2k+1 < 2k+3. Works for n=0 at any depth. But for n=1, need char(k+2) which needs exist(k+1, 1) with measure 2k+3 = SAME. Circular.

4. **Inner induction on n** (reducing arity): For n≥2, the merge case (NfDepth0Generalized) reduces arity by identifying equal positions. This works for the atom layer but the quantifier layer merge proof needs additional work. For n=1 with strict order, no merge is possible.

5. **Since/Until with enhanced point types**: Build the formula directly using Since/Until chains where point types encode depth-k quantifier conditions from the IH. ISSUE: The quantifier conditions at the pair (x, t) involve the FULL pair, not just individual points. Encoding this in the Since/Until framework requires relating formulas evaluated at x to conditions at t, which is possible in principle but requires complex nested temporal formulas.

6. **Classical existence via nf_to_formula**: Convert the condition to a monadic formula and prove temporal definability abstractly. ISSUE: The monadic formula has QD k+2, and temporal definability at QD k+2 requires char(k+2), which is circular.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| KampPrior.lean | 406 | nf_nvar_exist_all_depths k+1 n=1 case | Temporal formula exists for 1-variable existential at depth k+1 | Self-referential formula definition cannot be expressed in Lean's type system without a fixed-point combinator | Try approach 2 (mutual definition) or approach 5 (direct Since/Until construction) |
| KampPrior.lean | 409 | nf_nvar_exist_all_depths k+1 n≥2 case | Off critical path | Main theorem only needs n=0 and n=1 | After n=1 is resolved |

## Recommended Approach for Next Dispatch

**Approach 2 (Mutual definition)** is the most promising:

1. Define a PAIR of functions simultaneously by Nat.rec on k:
   ```
   combined(k) := (
     char_{k+1} : NormalForm sig (k+1) 1 → Formula,
     exist_{k+1}_1 : NormalForm sig (k+1) 2 → Formula
   )
   ```
2. At depth 0: char_1 uses exist_0_1 from depth-0 infrastructure. exist_1_1 uses char_2... wait, still circular at the same level.

Actually, the most promising approach is **Approach 5 (direct Since/Until)** specialized to n=1:
1. The formula for `∃ x, nf_eval_nf M (k+1) 2 (x, t) sub_nf` with sub_nf saying x < t:
   - `[pred_t] ∧ (⊤ S ([pred_x] ∧ [quant_check]))`
2. The quant_check at x encodes ALL quantifier conditions simultaneously
3. Each quantifier condition involves `∃ y, nf_eval_nf M k 3 (y, x, t) qnf`
4. Decompose by y's position: y < x, x < y < t, y > t
5. For y < x: Since from x with depth-(k-1) conditions at y
6. For x < y < t: Until from x reaching toward t, with conditions at y
7. For y > t: Until from t (but we're inside a Since from t to x...)

The key insight: within the Since formula `⊤ S alpha_x` at t, the formula alpha_x is evaluated at x. Within alpha_x, temporal operators reference points relative to x. `phi U psi` at x finds points > x. `phi S psi` at x finds points < x.

So:
- y < x: use `beta_yx S alpha_y` inside alpha_x
- x < y < t: this is in the INTERVAL (x, t), which is the Since interval
  - Cannot directly reference t from alpha_x
  - But can use `beta_xy U alpha_y` inside alpha_x, where alpha_y requires y < t
  - y < t is not directly expressible... but any s > x found by Until could be y
- y > t: use Until at t level (outside the Since)

This is complex but may be feasible for the n=1 case. The quantifier conditions at (y, x, t) involve depth-k NFs, handled by the IH.

## References

- KampPrior.lean: lines 268-409 (the sorry site and surrounding infrastructure)
- NormalForm.lean: nf_to_formula (line 705), nf_to_formula_correct (line 719), doets_lemma_1_1 (line 433), nf_exists_unique (line 277)
- NfDepth0Generalized.lean: insertEnv (line 42), nf_nvar_exist_depth0_tl (line 1267)
- RabinovichTranslation.lean: ExistsForallSpec, translateEF1
