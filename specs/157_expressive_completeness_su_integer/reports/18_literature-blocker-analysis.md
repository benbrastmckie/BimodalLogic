# Research Report: Task #157 -- GHR94 Proof Structure Analysis for Phase 3 Blocker

**Task**: 157 -- Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Mode**: Deep literature analysis + codebase investigation
**Session**: sess_1779214591_6c5f29
**Focus**: How GHR94 avoids the callback termination issue; feasibility of approaches (a), (b), (c)

---

## 1. Executive Summary

1. **GHR94 10.2.5 uses a REWRITING approach, not a callback approach.** The proof says: find the most deeply nested S(C,F) containing U(A,B), apply 10.2.4 LOCALLY to rewrite it, reducing S-nesting depth by 1. This is fundamentally different from the codebase's callback pattern. The termination issue arises entirely because the implementation chose a different architecture.

2. **The callback formulas ARE directly handleable by 10.2.4** without recursion. When `no_S_nested_in_U_separable_param_jd` is applied to a formula with `snce_depth_of_U = 1`, its callback formulas have the form `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free. This is EXACTLY a boolean combination of atoms and U(A,B), which is 10.2.4's domain. A single non-recursive application of 10.2.4 suffices.

3. **The box-normalization issue with `has_single_U_type` is real but solvable.** `replace_box_with_top` does NOT preserve `has_single_U_type` when A or B contain `.box`. However, the standard solution is to box-normalize A and B as well, working with `A' = replace_box_with_top A` and `B' = replace_box_with_top B` throughout. Since `replace_box_equiv` gives semantic equivalence, this is sound.

4. **Approach (b) -- inlining everything into one well-founded recursion -- is the cleanest path.** The key insight: define a SINGLE function that does strong induction on `snce_depth_of_U` for single-U-type formulas. At the `.snce C F` case, recursively separate C and F (which have smaller `snce_depth_of_U`), box-normalize, then directly apply 10.2.4 (which is entirely non-recursive). No callbacks needed.

5. **The `_gen` variants and `lemma_10_2_4_gen` are already in place** (Tasks 3.6, 3.8 completed). The remaining gap is the DNF/CNF decomposition step that reduces a general `.snce C F` (where C and F are boolean combinations of atoms and U(A,B)) to the 8 specific case forms.

---

## 2. GHR94 Proof Structure Analysis

### 2.1 Lemma 10.2.4 (Exact Proof Structure)

**Statement**: Suppose A and B are wffs without S or U, and C and F are wffs where each appearance of U is as U(A,B) and is not nested under any S. Then S(C, F) is equivalent to a syntactically separated wff in which U only appears as U(A,B).

**Proof Structure**:
1. "By rearrangement of C and F into disjunctive and conjunctive normal form, respectively, and repeated use of lemma 10.2.1, we can rewrite S(C, F) equivalently as a boolean combination of..."
2. Three types of constituents:
   - `S(C1, C2)` with no U (already separated)
   - `S(C1, C2 +/- U(A,B))` (guard contains U)
   - `S(C1 ^ +/-U(A,B), C2 +/- U(A,B))` (event and guard both contain U)
3. "Now the preceding lemma [10.2.3] shows that each such boolean constituent is equivalent to a boolean combination of [separated forms]."

**Key Point**: The DNF/CNF decomposition is the critical step. C is put into DNF (disjunction of conjunctions), F is put into CNF (conjunction of disjunctions). Then `S(C_disj, F_conj)` distributes using Lemma 10.2.1:
- `S(A v B, C) <-> S(A, C) v S(B, C)` (distributes S over disjunction in event)
- `S(A, B ^ C) <-> S(A, B) ^ S(A, C)` (distributes S over conjunction in guard)

After distribution, each conjunct of the event is either:
- a purely boolean atom/negation (no U), OR
- `+/-U(A,B)` (since every U in C is U(A,B))

And each disjunct of the guard is either:
- a purely boolean literal (no U), OR
- `+/-U(A,B)`

So the event has the form `a ^ +/-U(A,B)` (with a = conjunction of U-free literals) and the guard has the form `q v +/-U(A,B)` (with q = disjunction of U-free literals). This gives exactly the 8 cases of 10.2.3.

### 2.2 Lemma 10.2.5 (Exact Proof Structure)

**Statement**: Suppose A, B are wffs without S or U, and the only appearance of U in D is as U(A,B). Then D is equivalent to a syntactically separated wff in which U only appears as U(A,B).

**Proof**: By induction on k = maximum number of nested Ss above any U(A,B).

**Case k = 0**: D is already separated. (Every `.snce` has U-free args, and every `.untl` is U(A,B) with S-free args.)

**Case k > 0**: "Apply the preceding lemma [10.2.4] to each of the most deeply nested S(C, F) in which U(A,B) appear."

**Critical Detail**: GHR94 applies 10.2.4 at SPECIFIC `.snce` nodes -- the ones at maximum S-nesting depth above U(A,B). After rewriting, the S-nesting depth of U(A,B) decreases by at least 1. The IH then applies.

**Why This Avoids Callbacks**: 10.2.4 takes a `.snce C F` where U(A,B) is NOT under any S within C or F, and produces a syntactically separated equivalent. This is a DIRECT rewriting. The output does not need further recursive processing for the specific U(A,B) -- it's already separated w.r.t. that U.

### 2.3 Lemma 10.2.6 (Multiple U-types)

**Statement**: For each i = 1,...,n, let A_i, B_i be wffs without S or U. Suppose the only appearances of U in D are in the form U(A_i, B_i). Then D is syntactically separable.

**Proof**: By induction on n.
- **n = 1**: This is Lemma 10.2.5.
- **n > 1**: Replace each U(A_i, B_i) for i < n with fresh atoms q_i. The result D' has single U-type U(A_n, B_n). Apply 10.2.5 to get separated E'. Back-substitute. The pure-past parts of E' now contain U(A_i, B_i) for i < n. Apply IH with n-1 U-types.

### 2.4 Lemma 10.2.7 (No S nested in U)

**Statement**: Suppose D contains no S nested within a U. Then D is syntactically separable.

**Proof**: By induction on n = maximum depth of nesting of Us beneath an S (= `U_nesting_depth`).
- **n = 1**: This is Lemma 10.2.6. (All U-args are U-free, so all U-types U(A_i, B_i) have A_i, B_i without S or U.)
- **n > 1**: Abstract inner U-subformulas (those nested inside U-args) with fresh atoms. The result has U-nesting depth <= 1. Apply 10.2.6. Back-substitute. The pure-past parts now have U-nesting depth < n. Apply IH.

### 2.5 Lemma 10.2.8 (Full separation)

**Statement**: Any wff is syntactically separable.

**Proof**: By induction on junction depth.
- **JD 0-1**: Already separated.
- **JD >= 2**: Abstract S-subformulas from inside U-args (reducing junction depth). Apply 10.2.7 to get separated form. Back-substitute. The back-substituted S-subformulas have junction depth <= JD - 2. Apply IH.

---

## 3. Current Implementation Analysis

### 3.1 Architecture Comparison

| Aspect | GHR94 | Current Lean Implementation |
|--------|-------|-----------------------------|
| 10.2.5 approach | Local rewriting at specific `.snce` nodes | Global abstract-substitute-callback |
| 10.2.5 measure | S-nesting depth above U(A,B) (`snce_depth_of_U`) | `count_U_subformulas` (inside `no_S_nested_in_U_separable_param`) |
| 10.2.5 termination | Local rewriting preserves single-U-type and reduces S-nesting | Callback creates NEW formulas whose relationship to original is opaque |
| 10.2.4 integration | Called LOCALLY at specific `.snce` nodes | Cases 1-8 exist but no general DNF/CNF decomposition |
| 10.2.6 | Explicit n-induction on number of U-types | Implicitly handled by `no_S_nested_in_U_separable_param` via `count_U_subformulas` |
| 10.2.7 | Explicit induction on `U_nesting_depth` | Not implemented as standalone; folded into `all_formulas_separable_aux` via junction depth |

### 3.2 The Callback Problem in Detail

`no_S_nested_in_U_separable_param_jd` (line 1884) does:
1. Strong induction on `count_U_subformulas phi`.
2. If U-free: done (syntactically separated).
3. Else: extract one U(A,B), abstract with `abstract_untl`, get phi' with fewer U-subformulas.
4. Recursively (by IH) prove phi' is separable. Get separated psi equiv phi'.
5. Substitute back: `subst_formula psi p (.untl A B)` equiv phi.
6. At each `.snce c d` in psi (where c, d are U-free): invoke CALLBACK on `.snce (subst c p (.untl A B)) (subst d p (.untl A B))`.

The callback is external. It receives formulas with:
- `no_S_nested_in_U` (proved)
- `junction_depth <= 1` (proved by `callback_jd_le_one`)
- `has_single_U_type` when A, B are U-free (proved by `callback_has_single_U_type`)

For `single_U_formula_separable_noax`, the plan says: use `snce_depth_of_U` induction. At `.snce C F`:
- IH separates C and F. Get C', F' separated.
- `.snce C' F'` has `snce_depth_of_U = 1` (after box-normalization).
- Apply `no_S_nested_in_U_separable_param_jd` with callback = `single_U_formula_separable_noax`.
- Callback receives new formulas. Need `snce_depth_of_U < original` for termination.

**WHY THIS FAILS**: The callback formula `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` has `snce_depth_of_U = 1` (same as the `.snce C'' F''` we started with). No strict decrease. The `count_U_subformulas` decrease happens INSIDE `no_S_nested_in_U_separable_param_jd` but is invisible to the external callback.

### 3.3 The Box-Normalization Complication

`separated_boxnorm_snce_depth_zero` (line 1566) proves `snce_depth_of_U (replace_box_with_top phi) = 0` when phi is separated. This is needed because raw `is_syntactically_separated` does NOT imply `snce_depth_of_U = 0` (`.box` is opaque to separation but transparent to `snce_depth_of_U`).

However, `replace_box_with_top` does NOT preserve `has_single_U_type` when A or B contain `.box`. Example: if `A = .box(.atom 0)`, then `has_single_U_type (.untl A B) A B` is true, but after box-normalization, the `.untl` node becomes `.untl (.imp .bot .bot) (replace_box_with_top B)`, and `has_single_U_type` w.r.t. the original `A, B` is false.

### 3.4 Import Graph

```
SeparationThm.lean  <-- Hierarchy.lean (line 2, `import SeparationThm`)
Hierarchy.lean  ---uses---> SeparationThm.lean axioms (all_separable, snce_separable)
```

**Current**: Hierarchy.lean imports SeparationThm.lean and uses its axioms.
**Phase 5 goal**: SeparationThm.lean should import Hierarchy.lean to replace axioms with theorems.

**Circular dependency risk**: HIGH. Currently `Hierarchy -> SeparationThm`. Phase 5 needs `SeparationThm -> Hierarchy`. Cannot have both.

**Solution**: Phase 5 Task 5.4 must REMOVE the `SeparationThm` import from Hierarchy.lean. This requires eliminating all uses of `all_separable` and `snce_separable` from Hierarchy.lean first. Currently, `all_separable` is used at lines 1767, 1999, and 2032 as the callback for `no_S_nested_in_U_separable_param_jd`. Once `single_U_formula_separable_noax` and `no_S_nested_in_U_separable_direct` are proved axiom-free, these can be replaced, and the import removed.

---

## 4. Approach Evaluation

### 4.1 Approach (a): Modify `no_S_nested_in_U_separable_param` to expose count decrease

**Idea**: Change the callback signature to include a count bound:
```lean
callback : forall (chi : Formula), no_S_nested_in_U chi ->
           count_U_subformulas chi < count_bound -> is_separable chi
```

**Feasibility**: MEDIUM-HIGH. The internal `count_U_subformulas` decrease in `no_S_nested_in_U_separable_param` is already proved. Exposing it to the callback requires threading the bound through `subst_in_separated_separable`. The key lemma needed:

```lean
theorem subst_in_separated_count_bound (psi : Formula) (p : Atom) (A B : Formula)
    (hsep : is_syntactically_separated psi = true) :
    -- For each .snce callback: count of callback < count of subst(psi, p, U(A,B))
    ...
```

This is non-trivial because `subst_formula psi p (.untl A B)` can expand: each occurrence of atom p becomes `(.untl A B)`, increasing the formula size. However, `count_U_subformulas` of the callback `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free equals the number of occurrences of p in c and d. Meanwhile, the parent formula `subst_formula psi p (.untl A B)` has count equal to the number of p-occurrences in ALL of psi. Since c, d come from ONE `.snce` node in psi, the callback's count is strictly less than the whole formula's count (as long as there are other nodes in psi that also contain p, or the parent formula has additional structure).

Actually, this is NOT guaranteed. If psi = `.snce c d` (just one node), then the callback IS the whole substituted formula, and `count_U_subformulas(callback) = count_U_subformulas(subst_formula psi p (.untl A B))`. No decrease.

**Verdict**: Approach (a) does NOT work in general. The callback for a single `.snce` node is the ENTIRE substituted formula, giving no count decrease.

### 4.2 Approach (b): Single inlined well-founded recursion

**Idea**: Write `single_U_formula_separable_noax` as a SINGLE function doing strong induction on `snce_depth_of_U`. At the `.snce C F` case, instead of calling `no_S_nested_in_U_separable_param_jd`, directly:

1. Recursively separate C (smaller `snce_depth_of_U`). Get C' separated.
2. Recursively separate F. Get F' separated.
3. Box-normalize: C'' = `replace_box_with_top C'`, F'' = `replace_box_with_top F'`.
4. Now `snce_depth_of_U C'' = 0` and `snce_depth_of_U F'' = 0`.
5. `.snce C'' F''` has `no_S_nested_in_U` and `snce_depth_of_U = 1`.
6. Apply 10.2.4 DIRECTLY (non-recursive, single step) to get separated result.

**Critical Question for Step 6**: Can we apply 10.2.4 without further recursion?

YES. `no_S_nested_in_U_separable_param_jd` at `snce_depth_of_U = 1` does:
- Extract one U(A',B') from `.snce C'' F''`.
- Abstract it: phi' = `abstract_untl (.snce C'' F'') A' B' p`.
- phi' is U-free (since all U in `.snce C'' F''` are U(A',B') and `abstract_untl` replaces them all).
- U-free + `has_no_allpast_allfuture` -> syntactically separated. Get separated psi.
- Substitute back: `subst_formula psi p (.untl A' B')`.
- At each `.snce c d` in psi: the callback formula `.snce (subst c p (.untl A' B')) (subst d p (.untl A' B'))` has `has_single_U_type A' B'` and `snce_depth_of_U <= 1`.

The callback formula at `snce_depth_of_U = 1` has U(A',B') only at "top level" in the `.snce` args (c, d are U-free, so substitution places U(A',B') only where p was). This is EXACTLY what Lemma 10.2.4 handles.

But we need the DNF/CNF decomposition to reduce the general form to Cases 1-8. The existing `lemma_10_2_4_gen` handles the 8 specific forms but not the general decomposition.

**What's Missing**: A theorem that says:

```lean
theorem snce_single_U_depth_one_separable (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hd : snce_depth_of_U phi = 1)
    (hsingle : has_single_U_type phi A B)
    (hA_sf : is_S_free A) (hB_sf : is_S_free B)
    (hA_uf : is_U_free A) (hB_uf : is_U_free B) :
    is_separable phi
```

This requires the DNF/CNF decomposition step. However, there's a much simpler alternative:

**USE `no_S_nested_in_U_separable_param_jd` as a black box, with the callback handling ONLY the depth-0 case.**

At `snce_depth_of_U = 1`:
1. Apply `no_S_nested_in_U_separable_param_jd` with callback = `fun chi _ _ => snce_depth_zero_case chi`.
2. The callback receives formulas with `no_S_nested_in_U` and `junction_depth <= 1`.
3. KEY: inside `no_S_nested_in_U_separable_param_jd`, ALL U(A',B') are abstracted away. The callback receives the BACK-SUBSTITUTED form. But after the inner strong induction on `count_U_subformulas` bottoms out, the separated form is U-free. Substituting BACK gives formulas where U(A',B') appears but only at "top level."

Actually, I need to be more precise. `no_S_nested_in_U_separable_param_jd` does its own strong induction on `count_U_subformulas`. Let me trace what happens:

**Trace of `no_S_nested_in_U_separable_param_jd` on `.snce C'' F''` (depth 1, single U-type U(A',B'))**:

Step 1: phi = `.snce C'' F''`, not U-free (contains U(A',B')).
Step 2: Extract U-type: gets (A', B').
Step 3: Abstract: phi' = `abstract_untl (.snce C'' F'') A' B' p`.
  - Since `snce_depth_of_U C'' = 0`, C'' has U-free `.snce` args. The U(A',B') in C'' is at "surface level" (not under `.snce`).
  - phi' replaces ALL U(A',B') with atom p. phi' is U-free.
Step 4: phi' has `count_U_subformulas = 0`. No more recursion needed.
  - phi' is U-free and `has_no_allpast_allfuture` -> syntactically separated.
  - Get separated psi equiv phi'. Since phi' is already syntactically separated, psi = phi'.
Step 5: Substitute back: `subst_formula psi p (.untl A' B')` = `subst_formula phi' p (.untl A' B')` = phi (by roundtrip).
  - Wait, psi is the separated form of phi'. If phi' IS already separated, then psi = phi' (could pick phi' itself as the witness). Then `subst_formula phi' p (.untl A' B') = phi` by the roundtrip property.

Hmm, but `subst_in_separated_separable_jd` is called on psi (the separated witness). At each `.snce c d` in psi:
  - c and d are U-free (from `is_syntactically_separated`).
  - The callback is invoked on `.snce (subst c p (.untl A' B')) (subst d p (.untl A' B'))`.

So the callback IS invoked. And the callback formula has `snce_depth_of_U = 1` (if c or d contains p) or 0 (if neither does).

For the depth-0 callbacks: trivially separated (U-free `.snce` args).
For the depth-1 callbacks: these have single-U-type U(A',B'), `junction_depth <= 1`, `no_S_nested_in_U`. They need to be proved separable.

But here's the key: these depth-1 callback formulas have a SPECIFIC structure. They are `.snce (subst c p (.untl A' B')) (subst d p (.untl A' B'))` where c, d are U-free. Since c is U-free, `subst c p (.untl A' B')` is a formula where every occurrence of atom p in c has been replaced by `.untl A' B'`. The result is a boolean combination of atoms and `.untl A' B'`.

This is the EXACT setup for Lemma 10.2.4. But applying 10.2.4 requires decomposing `subst c p (.untl A' B')` into DNF form to match one of the 8 cases.

**Alternative**: Instead of DNF decomposition, we can prove a GENERAL version of Lemma 10.2.4 that works on arbitrary boolean combinations of atoms and U(A,B), not just the 8 specific case forms.

**Best Alternative**: Use `no_S_nested_in_U_separable_param` (the non-JD version, line 1717) RECURSIVELY inside itself. At `snce_depth_of_U = 1`, the callback formula is `.snce (subst c p (.untl A' B')) (subst d p (.untl A' B'))`. Apply `no_S_nested_in_U_separable_param` to THIS formula with the SAME callback. Since this formula also has `snce_depth_of_U = 1`, the inner call abstracts U(A',B') again, separates (getting a U-free separated form), and substitutes back. The inner callback receives `.snce (subst c' p' (.untl A' B')) (subst d' p' (.untl A' B'))` -- but c' and d' come from the INNER separated form, which may be different.

This chain eventually terminates because `count_U_subformulas` decreases at each call to `no_S_nested_in_U_separable_param`. But the callback is EXTERNAL to that induction, so termination is not visible.

**REAL SOLUTION**: Inline the callback. Instead of passing a callback, have `no_S_nested_in_U_separable_param` DIRECTLY handle the `.snce` substitution case by applying 10.2.4.

### 4.3 Approach (c): Completely different proof structure following GHR94 literally

**Idea**: Implement GHR94 10.2.5 as a REWRITING function that:
1. Takes a formula D with single U-type U(A,B).
2. Finds the innermost `.snce C F` containing U(A,B).
3. Applies 10.2.4 to that specific node, producing a rewritten formula.
4. The S-nesting depth of U(A,B) in the result is strictly less.
5. Iterates until S-nesting depth = 0.

**Feasibility**: LOW-MEDIUM. This requires:
1. A "find innermost S containing U" function.
2. A "rewrite at a specific position" function (context + hole).
3. Proof that rewriting preserves semantic equivalence.
4. Proof that S-nesting depth strictly decreases.
5. The 10.2.4 application requires DNF/CNF decomposition within the local `.snce` args.

This is a significant engineering effort (~300+ LOC) and introduces new infrastructure (formula contexts, position-based rewriting) that doesn't exist.

**Verdict**: Correct but impractical given existing codebase.

### 4.4 Recommended Approach: (b') -- Modified Inlined Recursion

The recommended approach combines the best elements:

**Core Idea**: Prove `single_U_formula_separable_noax` by strong induction on `(snce_depth_of_U, count_U_subformulas)` lexicographic order.

```lean
theorem single_U_formula_separable_noax (phi A B : Formula)
    (hA_sf : is_S_free A) (hB_sf : is_S_free B)
    (hA_uf : is_U_free A) (hB_uf : is_U_free B)
    (h_single : has_single_U_type phi A B) :
    is_separable phi
```

**Proof by well-founded induction on `(snce_depth_of_U phi, sizeOf phi)` lexicographic**:

- **`.atom`, `.bot`**: Trivially separated.
- **`.imp a b`**: `snce_depth_of_U a <= snce_depth_of_U (.imp a b)` and `sizeOf a < sizeOf (.imp a b)`. By IH, a and b are separable. Use `imp_separable`.
- **`.box a`**: Same.
- **`.untl a b`**: `has_single_U_type` forces a = A, b = B. `.untl A B` is separated (A, B are S-free).
- **`.snce C F`** (the hard case):
  - **Sub-case: both C, F are U-free**: `.snce C F` is separated.
  - **Sub-case: not both U-free** (`snce_depth_of_U (.snce C F) >= 1`):
    1. C and F have `snce_depth_of_U < snce_depth_of_U (.snce C F)` (strict decrease in first component).
    2. By IH: C is separable (first component strictly decreases). Get separated C' equiv C.
    3. By IH: F is separable. Get separated F' equiv F.
    4. Box-normalize: C'' = `replace_box_with_top C'`, F'' = `replace_box_with_top F'`.
    5. `snce_depth_of_U C'' = 0` (by `separated_boxnorm_snce_depth_zero`).
    6. `snce_depth_of_U F'' = 0`.
    7. `.snce C'' F''` equiv `.snce C F`.
    8. `.snce C'' F''` has `no_S_nested_in_U` (by `snce_of_boxfree_sep_no_S_nested`).
    9. Now apply `no_S_nested_in_U_separable_param_jd` to `.snce C'' F''` with the following callback:
       - The callback receives chi with `no_S_nested_in_U chi` and `junction_depth chi <= 1`.
       - chi has the form `.snce (subst c p (.untl A' B')) (subst d p (.untl A' B'))` where c, d U-free.
       - chi has `has_single_U_type chi A' B'` (by `callback_has_single_U_type`, since A' = A' extracted from C''/F'').
       - **KEY QUESTION**: Does chi have `snce_depth_of_U chi < snce_depth_of_U (.snce C F)`? Or at least `(snce_depth_of_U chi, sizeOf chi) < (snce_depth_of_U (.snce C F), sizeOf (.snce C F))` lexicographically?

**The Answer**: chi has `snce_depth_of_U <= 1`. The original `.snce C F` has `snce_depth_of_U >= 1`. So if `snce_depth_of_U (.snce C F) >= 2`, then `snce_depth_of_U chi <= 1 < snce_depth_of_U (.snce C F)` -- strict decrease in first component.

If `snce_depth_of_U (.snce C F) = 1` (the problematic case):
- C and F have `snce_depth_of_U = 0` (from the strict decrease property of `.snce`).
- They are U-free? No -- `snce_depth_of_U = 0` does NOT mean U-free. `.untl a b` has `snce_depth_of_U = 0`.
- Since C and F have `snce_depth_of_U = 0`, by IH they are separable. Separated C', F'.
- Box-normalize to C'', F''. `.snce C'' F''` has `snce_depth_of_U = 1` (since C'' and F'' have depth 0 but are NOT both U-free).
- `no_S_nested_in_U_separable_param_jd` abstracts ALL U(A',B') at once (strong induction on count). After full abstraction, the formula is U-free, hence separated. Back-substitution into the single `.snce` node gives callbacks.
- The callback has `snce_depth_of_U <= 1`.
- Since `snce_depth_of_U (.snce C F) = 1`, we have `snce_depth_of_U chi <= 1 = snce_depth_of_U (.snce C F)`. NO strict decrease.

So at depth 1, the callback's `snce_depth_of_U` is NOT strictly less. We need a secondary measure.

**Secondary measure -- `count_U_subformulas`**:
- The callback chi comes from substituting into a U-free `.snce c d` of the separated form.
- `count_U_subformulas chi = count_U_subformulas (subst c p (.untl A' B')) + count_U_subformulas (subst d p (.untl A' B'))`.
- This equals the number of occurrences of p in c plus the number in d.
- Meanwhile, the TOTAL `count_U_subformulas` of the back-substituted formula `subst_formula psi p (.untl A' B')` includes ALL occurrences of p in psi.
- Since chi comes from ONE `.snce c d` in psi, and psi may have other nodes containing p, `count_U_subformulas chi <= count_U_subformulas (subst_formula psi p (.untl A' B'))`.

But we need a comparison with the ORIGINAL `.snce C'' F''`, not the back-substituted form. The back-substituted form equals the original (by roundtrip), so `count_U_subformulas (subst_formula psi p (.untl A' B')) = count_U_subformulas (.snce C'' F'')`.

Now, does `count_U_subformulas chi < count_U_subformulas (.snce C'' F'')`? This is true IF psi has more than one `.snce` node containing p (then each callback takes a proper subset of the U-occurrences). But if psi has ONLY ONE `.snce` node (e.g., psi = `.snce c d` itself after abstraction), then `count_U_subformulas chi = count_U_subformulas (.snce C'' F'')`. No decrease.

Wait -- actually, `no_S_nested_in_U_separable_param_jd` does strong induction on `count_U_subformulas` INTERNALLY. It abstracts one U(A',B') (reducing count), separates, substitutes back, and calls the callback. The internal induction may do MULTIPLE rounds of abstraction/substitution before calling the callback. So the callback may receive formulas with FEWER U-subformulas than the original.

But the callback is invoked for EACH `.snce` node in each intermediate separated form, and the internal induction accounts for the total count. The callback's count IS strictly less than what the internal induction started with, but it's compared to an INTERMEDIATE count, not the original.

This is getting complicated. Let me reconsider.

**The SIMPLEST correct approach**: Don't use `no_S_nested_in_U_separable_param_jd` at all for the depth-1 case. Instead, directly implement 10.2.4.

At `snce_depth_of_U (.snce C F) = 1` with single-U-type U(A,B):
- `snce_depth_of_U C = 0` and `snce_depth_of_U F = 0`.
- C and F contain U only as U(A,B), not under any `.snce`.
- After box-normalization, C'' and F'' have `snce_depth_of_U = 0`, meaning every `.snce` in C''/F'' has U-free args.
- The U(A,B) in C''/F'' appears only at "top level" (not under `.snce`).

This is EXACTLY Lemma 10.2.4's precondition: "C and F are wffs in which each appearance of U is as U(A,B) and is not nested under any Ss."

So we need a DIRECT proof that `.snce C'' F''` is separable when C'', F'' have `snce_depth_of_U = 0` and single-U-type. This is Lemma 10.2.4.

The implementation of 10.2.4 already EXISTS as `no_S_nested_in_U_separable_param_jd`. But using it creates the callback problem. The ALTERNATIVE is to implement 10.2.4 WITHOUT callbacks.

**Implementation of 10.2.4 without callbacks**:

The key step is: put C'' in DNF and F'' in CNF, distribute S using Lemma 10.2.1, and get forms that match Cases 1-8.

Specifically, for `.snce C'' F''`:
1. C'' = bool_combo(atoms, U(A,B)). Put in DNF: C'' = d1 v d2 v ... v dk where each di = conjunction of literals and +/-U(A,B).
2. F'' = bool_combo(atoms, U(A,B)). Put in CNF: F'' = c1 ^ c2 ^ ... ^ cm where each ci = disjunction of literals and +/-U(A,B).
3. By Lemma 10.2.1: `.snce (d1 v ... v dk) F'' <-> .snce d1 F'' v ... v .snce dk F''`.
4. And `.snce di (c1 ^ ... ^ cm) <-> .snce di c1 ^ ... ^ .snce di cm`.
5. Each `.snce di cj` has event = conjunction of U-free literal and +/-U(A,B), guard = disjunction of U-free literal and +/-U(A,B). This matches Cases 1-8.

The problem: this requires DNF/CNF conversion and distribution lemmas that may not exist in the codebase.

Let me check.

Actually, looking more carefully, `no_S_nested_in_U_separable_param` (without JD) already does this implicitly. It abstracts U(A,B) with a fresh atom, then the abstracted formula (U-free) is separated via `restricted_u_free_separated`. The separated form has U-free `.snce` args. Back-substitution places U(A,B) into the separated form.

The key insight I keep coming back to: the callback formula from `no_S_nested_in_U_separable_param` is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free. This formula has `snce_depth_of_U <= 1`. If `snce_depth_of_U = 0`, it's U-free and separated. If `snce_depth_of_U = 1`, it has single U-type U(A,B) at depth 1.

For depth 1: we need to prove `.snce (bool_combo(atoms, U(A,B))) (bool_combo(atoms, U(A,B)))` is separable. This is 10.2.4. And 10.2.4 can be proved by DNF/CNF decomposition into Cases 1-8.

**BUT**: We can avoid the full DNF/CNF decomposition by using the EVENT-SPLIT technique already in the codebase. `since_event_split_separable` (NormalForm.lean line 481) says:

```
S(a, F) <-> S(a ^ U(A,B), F) v S(a ^ -U(A,B), F)
```

If both branches are separable, then `S(a, F)` is separable. Similarly for the guard:

```
S(event, q v U(A,B)) -> handled by Cases 3/5/6
S(event, q v -U(A,B)) -> handled by Cases 4/7/8
S(event, q) where q is U-free -> trivially separable
```

The general boolean combo can be decomposed by:
1. Event-split: `S(C, F) <-> S(C ^ U, F) v S(C ^ -U, F)`.
2. For `S(C ^ U, F)`: C ^ U simplifies (since U(A,B) is now definitely true in the event). But this isn't quite right -- event-split is on whether U(A,B) holds AT THE EVENT TIME.

Actually, the event-split is a semantic equivalence:
```
S(event, guard) <-> S(event ^ U(A,B), guard) v S(event ^ -U(A,B), guard)
```

After event-split, the event has the form `C' ^ +/-U(A,B)` where C' is the part of C that doesn't contain U(A,B). But C is a BOOLEAN COMBINATION, so C' may still contain U(A,B) in nested boolean positions.

The CORRECT decomposition uses the `replace_untl` technique already in the codebase (Hierarchy.lean line 1597). `replace_untl C A B top` replaces all U(A,B) in C with `top`. Then:

```
C ^ U(A,B) <-> replace_untl(C, A, B, top) ^ U(A,B)
```

This is the `single_U_and_conj_simplify` lemma (line 1696). After replacement, `replace_untl(C, A, B, top)` is U-free (proved by `replace_untl_U_free`). So the event becomes `a ^ U(A,B)` where `a = replace_untl(C, A, B, top)` is U-free.

Similarly for the guard, using guard-split on U(A,B):
```
guard = F = q v U(A,B) or q v -U(A,B) or q (U-free)
```
where `q = replace_untl(F, A, B, bot)` is U-free.

This decomposition IS implementable and avoids the full DNF/CNF machinery. The steps:
1. Event-split: `.snce C F <-> .snce (C ^ U(A,B)) F v .snce (C ^ -U(A,B)) F`.
2. Simplify events: `C ^ U(A,B) <-> replace_untl(C,A,B,top) ^ U(A,B)`, and `C ^ -U(A,B) <-> replace_untl(C,A,B,bot) ^ -U(A,B)`.
3. Guard-split similarly on F.
4. After both event and guard are split, we have Cases 1-8.
5. Apply `lemma_10_2_4_gen`.

This decomposition is essentially a 2-step process: split on whether U(A,B) appears positively or negatively in the event, then in the guard.

**IMPORTANT**: The `replace_untl` function already exists (line 1597) and `replace_untl_U_free` and `single_U_and_conj_simplify` are already proved. The guard-split equivalents may need to be proved.

---

## 5. Recommended Path Forward

### 5.1 The Plan

**Step 1**: Prove `single_U_formula_separable_noax` by strong induction on `snce_depth_of_U phi`.

- `.atom`, `.bot`, `.imp`, `.box`, `.untl` cases: straightforward (same as current `single_U_formula_separable` but without axioms).
- `.snce C F` case with `snce_depth_of_U >= 1`:
  a. By IH (strict decrease): C is separable -> get C' separated, and `has_single_U_type C' A B` (see Step 1a below).
  b. By IH: F is separable -> get F' separated, `has_single_U_type F' A B`.
  c. Box-normalize: C'' = `replace_box_with_top C'`, F'' = `replace_box_with_top F'`.
  d. A' = `replace_box_with_top A`, B' = `replace_box_with_top B`. (Box-normalized U-args.)
  e. `.snce C'' F''` equiv `.snce C F`, has `no_S_nested_in_U`, has `has_single_U_type C'' A' B'` (since box-normalization commutes with single-U-type when working with A', B').
  f. Apply the LEAF CASE (Lemma 10.2.4) to `.snce C'' F''` -- this is the event-guard decomposition using `replace_untl` + event-split + Cases 1-8.

**Step 1a**: Strengthen the IH to return `has_single_U_type`.

The IH must prove: exists phi', `is_syntactically_separated phi'` AND `int_equiv phi phi'` AND `has_single_U_type phi' A B`. This requires the separation witnesses to preserve single-U-type. For the current structural induction approach (where separated witnesses are built from IH witnesses), this should hold because:
- `imp_separable` builds `.imp` from separated sub-witnesses (preserves single-U-type).
- `snce` case builds new separated witness from Cases 1-8 applied to event/guard-split forms.

Actually, the IH needs careful formulation. The simplest approach: prove `single_U_formula_separable_noax` returns NOT just `is_separable phi` but `exists phi', is_syntactically_separated phi' /\ int_equiv phi phi' /\ has_single_U_type phi' A B`. The Cases 1-8 produce syntactically separated witnesses that still contain U only as U(A,B), so `has_single_U_type` is preserved.

ALTERNATIVE (simpler): Instead of preserving `has_single_U_type` through the IH, observe that we don't need it. After separating C and F individually, we have `.snce C' F'` where C', F' are separated. We need `.snce C' F'` to be separable. Since C' and F' are separated and single-U-type (from the original), after box-normalization the `.snce` has `no_S_nested_in_U`. Then we can apply `no_S_nested_in_U_separable_param` with a LEAF callback that handles single-U-type formulas at depth 1.

But this brings back the callback problem. The cleanest solution: implement the leaf case (Lemma 10.2.4 general form) as a standalone lemma.

**Step 2**: Implement `snce_depth_one_single_U_separable` (Lemma 10.2.4 general form).

This is a NON-RECURSIVE function that proves `.snce C F` is separable when:
- `snce_depth_of_U C = 0` and `snce_depth_of_U F = 0`
- `has_single_U_type (.snce C F) A B` with S-free, U-free A, B
- `no_S_nested_in_U (.snce C F)`

Proof:
1. Event-split on U(A,B): `.snce C F <-> .snce (C ^ U(A,B)) F v .snce (C ^ -U(A,B)) F`.
2. Simplify: `C ^ U(A,B) <-> replace_untl(C,A,B,top) ^ U(A,B)` (by `single_U_and_conj_simplify`).
3. Similarly: `C ^ -U(A,B) <-> replace_untl(C,A,B,bot) ^ -U(A,B)` (need dual lemma).
4. Let a_pos = `replace_untl(C, A, B, top)`, a_neg = `replace_untl(C, A, B, bot)`. Both U-free.
5. Guard-split on F:
   - F is a boolean combination of atoms and U(A,B).
   - After event-split, need to handle `.snce (a ^ +/-U) F`.
   - Guard decomposition: split F into `q v +/-U(A,B)` where q is U-free.
   - This uses `replace_untl(F, A, B, bot)` for q.
6. After full decomposition: each piece matches Cases 1-8.
7. Apply `lemma_10_2_4_gen`.

**Estimated effort**: ~100-150 LOC for the guard decomposition lemmas + the main theorem.

**Step 3**: Use `single_U_formula_separable_noax` in `all_formulas_separable_aux`.

Replace the `all_separable` calls at lines 1999 and 2032 with direct calls through the new axiom-free path.

### 5.2 Alternative Simpler Path

There is a potentially simpler approach that avoids the general DNF/CNF decomposition entirely:

**Use `no_S_nested_in_U_separable_param` (the non-JD version) at the depth-1 leaf case, with the callback receiving formulas that are GUARANTEED to be at depth 0.**

The claim: when `no_S_nested_in_U_separable_param` is applied to a formula with `snce_depth_of_U = 1` and `has_single_U_type`, the callback formulas have `snce_depth_of_U = 0`.

Is this true? The callback formula is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free. `snce_depth_of_U` of this is:
- If both `subst c p (.untl A B)` and `subst d p (.untl A B)` are U-free: 0.
- Else: 1 + max(snce_depth_of_U(subst c p (.untl A B)), snce_depth_of_U(subst d p (.untl A B))).

But `subst c p (.untl A B)` with U-free c: the result has U only where p was. `snce_depth_of_U (subst c p (.untl A B))`:
- At `.snce` nodes in c (which have U-free args, since c is U-free): args remain U-free after substitution (p is an atom, substitution only affects atom p). Wait -- if c has `.snce e f` where e contains atom p, then `subst e p (.untl A B)` is NOT U-free. So the `.snce` in the substituted form may have NON-U-free args.

So the callback's `snce_depth_of_U` can be 1 if the substituted c contains `.snce` nodes where one arg had atom p. This means depth-1 callbacks are possible.

But wait, c comes from a SEPARATED form. In a separated form, `.snce` args are U-free. And U-free formulas don't contain `.untl`. But they CAN contain atom p. After substitution, the `.snce` args may contain `.untl A B` (from substituting p). So `snce_depth_of_U` of the inner `.snce` becomes 1.

So the callback CAN have `snce_depth_of_U = 1`. No guarantee of depth 0.

However, the callback's `count_U_subformulas` IS strictly less than the parent's if the parent has more than one `.snce` containing p. But for a single `.snce` at top level, it's the same.

### 5.3 Final Recommendation

**The recommended approach is (b') with a self-contained leaf case.**

Concretely:

1. **Prove `snce_single_U_depth_one_separable`** (~120 LOC): The general Lemma 10.2.4 for `.snce C F` where C, F have `snce_depth_of_U = 0` and `has_single_U_type`. Uses event-guard decomposition via `replace_untl` + event-split + Cases 1-8. This is a LEAF function (no recursion, no callbacks).

2. **Prove `single_U_formula_separable_noax`** (~80 LOC): Strong induction on `snce_depth_of_U`. The `.snce` case calls the IH on C, F (strict decrease), box-normalizes, then calls `snce_single_U_depth_one_separable`. No callbacks.

3. **The box-normalization issue is handled** by working with `A' = replace_box_with_top A` and `B' = replace_box_with_top B` throughout. Since `int_equiv A A'` and `int_equiv B B'`, replacing U(A,B) with U(A',B') preserves semantic equivalence.

4. **Total estimated effort**: ~200 LOC for new code, plus ~50 LOC for lemmas connecting box-normalized U-args to the existing infrastructure.

---

## 6. Impact of Task 3.5 Deviation

### 6.1 The Deviation

Task 3.5 was renamed from `is_syntactically_separated_snce_depth_zero` to `separated_boxnorm_snce_depth_zero` because the original theorem is FALSE: `is_syntactically_separated phi = true` does NOT imply `snce_depth_of_U phi = 0`. The fix uses `replace_box_with_top`.

### 6.2 Impact on Task 3.7

The box-normalization requirement propagates throughout the proof:

- **IH outputs**: When the IH produces separated C', we must box-normalize to C'' before using `snce_depth_of_U C'' = 0`.
- **Single-U-type tracking**: After box-normalization, the U-args change from A to `replace_box_with_top A`. The `has_single_U_type` predicate must use the box-normalized versions.
- **Cases 1-8 application**: `lemma_10_2_4_gen` requires U-free and S-free A, B. Box-normalized A', B' preserve these properties (by `replace_box_preserves_U_free` and `replace_box_preserves_S_free`).

### 6.3 Impact on Downstream (Phases 4-5)

The box-normalization is already used in `all_formulas_separable_aux` (lines 1973-1974). So downstream code already works with box-normalized forms. The deviation in Task 3.5 aligns with the existing architecture.

---

## 7. Import Graph Analysis

### 7.1 Current Import Chain

```
SeparationThm.lean  (axioms: 9)
    imports: Defs, Eliminations, FormulaOps, Distributivity, Duality

Hierarchy.lean  (the main proof file)
    imports: NormalForm, SeparationThm, TemporalClosure, DedekindZ

NormalForm.lean
    imports: Eliminations, DedekindZ, ... (no SeparationThm)

Eliminations.lean, DedekindZ.lean
    imports: Defs, FormulaOps, ... (no SeparationThm)
```

### 7.2 Phase 5 Circular Dependency Risk

**HIGH RISK**. Phase 5 needs SeparationThm.lean to import Hierarchy.lean (to replace axioms with theorems from `all_formulas_separable`). But Hierarchy.lean currently imports SeparationThm.lean (to use `all_separable`, `snce_separable`).

**Resolution**: Before Phase 5, Hierarchy.lean must be made independent of SeparationThm.lean. This requires:
1. Eliminating `all_separable` uses (lines 1767, 1999, 2032) -- replaced by `single_U_formula_separable_noax` and `no_S_nested_in_U_separable_direct`.
2. Eliminating `snce_separable` use (line 187 in `single_U_formula_separable`) -- this function is superseded by `single_U_formula_separable_noax`.
3. Removing the `import SeparationThm` line.

After these changes:
```
Hierarchy.lean
    imports: NormalForm, TemporalClosure, DedekindZ (no SeparationThm)

SeparationThm.lean
    imports: Defs, Eliminations, FormulaOps, Distributivity, Duality, Hierarchy
```

No circular dependency.

### 7.3 Intermediate State Risk

During Phase 3-4 (before Phase 5), Hierarchy.lean still imports SeparationThm. The new axiom-free proofs coexist with the old axiom-dependent ones. This is safe because:
- The new `_noax` versions don't use any SeparationThm axioms.
- The old versions remain for backward compatibility until Phase 5 replaces them.
- `lake build` will pass throughout.

---

## 8. Detailed Code Outline for the Recommended Approach

### 8.1 New Guard Decomposition Lemma

```lean
/-- Guard decomposition: F = (replace_untl F A B bot) v U(A,B) semantically
    when F has single-U-type U(A,B) and U(A,B) appears in F. -/
theorem guard_decompose_pos (F A B : Formula)
    (hsingle : has_single_U_type F A B)
    (hdepth : snce_depth_of_U F = 0)
    (hnotUfree : is_U_free F = false) :
    int_equiv F (Formula.or (replace_untl F A B .bot) (.untl A B))
```

A dual for the negative case is also needed.

### 8.2 Leaf Case: Depth-1 Single-U Separation

```lean
/-- Lemma 10.2.4 (general form): .snce C F where C, F have snce_depth_of_U = 0
    and has_single_U_type, is separable. Non-recursive. -/
theorem snce_single_U_depth_one_separable (C F A B : Formula)
    (hA_sf : is_S_free A) (hB_sf : is_S_free B)
    (hA_uf : is_U_free A) (hB_uf : is_U_free B)
    (hsingle_C : has_single_U_type C A B)
    (hsingle_F : has_single_U_type F A B)
    (hdC : snce_depth_of_U C = 0) (hdF : snce_depth_of_U F = 0)
    (hns : no_S_nested_in_U (.snce C F)) :
    is_separable (.snce C F)
```

Proof sketch:
1. Event-split on U(A,B).
2. For `.snce (C ^ U(A,B)) F`: simplify event to `a ^ U(A,B)` where `a = replace_untl C A B top` (U-free).
3. Guard decomposition of F: either F is U-free (done, Cases 1/2), or F = `q v +/-U(A,B)` where `q = replace_untl F A B bot` (U-free).
4. Match to Cases 1-8 and apply `lemma_10_2_4_gen`.

### 8.3 Main Theorem

```lean
/-- GHR94 Lemma 10.2.5 (axiom-free): single-U-type formula is separable.
    By strong induction on snce_depth_of_U. -/
theorem single_U_formula_separable_noax (phi A B : Formula)
    (hA_sf : is_S_free A) (hB_sf : is_S_free B)
    (hA_uf : is_U_free A) (hB_uf : is_U_free B)
    (h_single : has_single_U_type phi A B) :
    is_separable phi
```

Proof: Strong induction on `snce_depth_of_U phi`.
- `.snce C F` at depth >= 1: IH on C, F (strict decrease). Separate. Box-normalize. Apply `snce_single_U_depth_one_separable`.

---

## References

- GHR94 Ch 10.2, Lemmas 10.2.1-10.2.8: Primary literature source
- Hierarchy.lean: Lines 169-187 (axiom-dependent `single_U_formula_separable`), 1144-1172 (`subst_in_separated_separable`), 1281-1340 (`snce_depth_of_U`), 1425-1500 (`U_nesting_depth`), 1510-1548 (callback single-U-type), 1566-1583 (`separated_boxnorm_snce_depth_zero`), 1596-1709 (`replace_untl` + simplification), 1717-1759 (`no_S_nested_in_U_separable_param`), 1884-1926 (`no_S_nested_in_U_separable_param_jd`), 1938-2043 (`all_formulas_separable_aux`)
- NormalForm.lean: Lines 276-295 (`lemma_10_2_4_gen`), 481-486 (`since_event_split_separable`)
- TemporalClosure.lean: Lines 56-62 (`replace_box_with_top`), 281-303 (`snce_of_boxfree_sep_no_S_nested`)
- SeparationThm.lean: Lines 89-101 (4 is_separable axioms), 220-276 (5 proper axioms)
