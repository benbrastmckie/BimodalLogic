# Teammate A Findings: Correct Mathematical Approach for Phase 6 Cases 5-8

**Date**: 2026-05-17
**Role**: Primary Approach -- Re-reading GHR94 for Cases 5-8 proof strategy
**Task**: 157 -- Expressive completeness of {S,U} over integer time

---

## Executive Summary

After carefully re-reading GHR94 Chapter 10.2 and analyzing all prior research, the core finding is:

**The plan's Case 7 formula was misread from GHR94.** The formula GHR94 gives for Case 7 has three disjuncts, not two. The plan's "Disjunct 2" `S(S(a,B^q) ^ A ^ (q v NOT U), NOT U v q)` is actually GHR94's FIRST disjunct, not the second. GHR94 then says this first disjunct is further eliminated by eliminations (8) and (4) -- it is NOT already separated. GHR94's second and third disjuncts (`S(a, B^q) ^ A` and `S(a, B^q) ^ B ^ U(A,B)`) are separated for atoms, but the first disjunct requires more work.

**The correct approach for Cases 5-8 is NOT the Dedekind formula approach from GHR94 Section 10.3.** Section 10.3 is specifically for Dedekind complete (dense) time and introduces K+, K-, Gamma+/- connectives that are vacuous on Z. The correct approach for Z is what GHR94 Section 10.2 actually describes:

1. **Cases 5-8 are NOT handled by giving explicit separated equivalents at the level of Lemma 10.2.3.** Instead, they are reduced to earlier cases (1-4) via semantic reasoning, and the FULL INDUCTION in Lemmas 10.2.5-10.2.8 handles the remaining nested-U situations.

2. **The correct induction structure is junction depth (Lemma 10.2.8)**, NOT a single-level structural induction on `no_S_nested_in_U`. The plan's approach of trying to make Cases 5-8 self-contained (without the hierarchy) runs counter to GHR94's actual proof architecture.

3. **For atoms a, q, A, B** (which is what the current code assumes), Cases 5-8 CAN be handled via reductions to earlier cases, but these reductions still introduce formulas that require the hierarchy to separate (they produce intermediate S-formulas with U in non-atom positions).

**Recommended action**: Implement the junction-depth hierarchy (GHR94 Lemma 10.2.8) as the path forward, not the Dedekind formula approach. The key infrastructure -- `junction_depth`, `abstract_untl`, `abstract_snce` -- is either already in the codebase or was specified in prior research. This approach is mathematically complete and does not depend on finding magic "direct" separated equivalents for Cases 5-8.

**Confidence: HIGH (90%)** on the analysis. **MEDIUM (70%)** on LOC and difficulty estimate for the junction-depth approach.

---

## Key Finding 1: What GHR94 Actually Says About Cases 5-8

### Case 7 -- The Misread Formula

The plan (plan v8, Task 6.C) claims:

> Case 7: S(a ^ U(A,B), q v NOT U(A,B))
> Dedekind formula on Z produces two disjuncts:
> - Disjunct 1: S(a, B^q) ^ (A v (B^U(A,B))) -- separated
> - Disjunct 2: S(S(a,B^q) ^ A ^ (q v NOT U), NOT U v q) -- "U-free event, S-free guard, directly separated"

**This is INCORRECT.** Reading GHR94 Lemma 10.2.3, Case 7 (lines 95-101 of the literature markdown):

```
S(a ∧ U(A, B), q ∨ ¬U(A, B)) is equivalent to:

  [S(A ∧ (q ∨ ¬U(A, B)) ∧ S(a, B ∧ q), q ∨ ¬U(A, B))]   ← Disjunct 1
  ∨ [S(a, B ∧ q) ∧ A]                                       ← Disjunct 2
  ∨ [S(a, B ∧ q) ∧ B ∧ U(A, B)].                           ← Disjunct 3

The first disjunct can be further eliminated by eliminations (8) and (4).
```

The plan misidentified GHR94's first disjunct as the plan's second disjunct. **GHR94 itself says the first disjunct is NOT yet separated** -- it requires "further elimination by eliminations (8) and (4)."

The event of the first disjunct is `A ∧ (q ∨ ¬U(A, B)) ∧ S(a, B ∧ q)`.

- `S(a, B∧q)` is U-free for atoms (is_U_free(snce a (and B q)) = T). Correct.
- `q ∨ ¬U(A,B)`: is_U_free(or q (neg (untl A B))) = is_U_free(or q ...) = false because neg(untl A B) is not U-free.

So `is_U_free(A ∧ (q ∨ ¬U(A, B)) ∧ S(a, B ∧ q)) = false`. The event is NOT U-free. The first disjunct is NOT separated. The plan's claim that "D2" is "U-free event, S-free guard, directly separated" is WRONG -- the event contains `neg(untl A B)` which is not U-free.

GHR94's second and third disjuncts ARE separated for atoms:
- Disjunct 2: `S(a, B∧q) ∧ A` -- S has U-free args; A is an atom; separated.
- Disjunct 3: `S(a, B∧q) ∧ B ∧ U(A,B)` -- S has U-free args; B, U(A,B) are separated; separated.

But Disjunct 1 requires Cases 8 and 4. This is what triggered the blocker.

### Cases 5-8: The Book's Actual Proof Strategy

GHR94's actual proof strategy for Cases 5-8 in Lemma 10.2.3:

| Case | Book's Strategy |
|------|-----------------|
| Case 5 | Semantic: "three disjuncts corresponding to u > t, u = t, and u < t" (where u is the A-witness for U(A,B)) |
| Case 6 | "by considering when the first occurrence of ¬B after s is"; uses eliminations (3) and (5) |
| Case 7 | Reduces to Cases (8) and (4) (the first disjunct of the reduction formula) |
| Case 8 | Negation + substitution + uses elimination (5) (Case 5) |

**The critical observation**: Cases 6, 7, 8 ALL explicitly reduce to other cases in Lemma 10.2.3's proof. They are NOT self-contained. The reductions produce formulas that themselves require further separation, handled by the higher-level Lemmas 10.2.4-10.2.8.

### Case 8 -- GHR94's Explicit Negation Reduction

GHR94 Case 8 (lines 103-118) gives an exact formula:
```
Let D = S(a ∧ ¬U(A, B), q ∨ ¬U(A, B)).

¬D ↔ H(¬a ∨ U(A, B))
     ∨ S(¬q ∧ ¬a ∧ U(A, B), ¬a ∨ U(A, B))
     ∨ S(¬q ∧ U(A, B), ¬a ∨ U(A, B)).
```
(The last disjunct is redundant.)

Now: `H(¬a ∨ U(A,B))` = `all_past(neg(or a (neg(untl A B))))` ... wait, `H(phi) = neg S(neg phi, top)`. So `H(¬a ∨ U(A,B)) = neg S(neg(neg a ∨ U(A,B)), top)`. This has U under S -- needs further separation.

The second disjunct `S(¬q ∧ ¬a ∧ U(A, B), ¬a ∨ U(A, B))` has U(A,B) in both event AND guard -- this is Case 5 pattern. The book says "especially elimination (5)."

**Conclusion**: Case 8 explicitly depends on Case 5. The dependency graph is:
- Case 5 is independent (semantic argument with explicit witness analysis)
- Case 8 depends on Case 5
- Case 7 depends on Cases 8 and 4
- Case 6 depends on Cases 3 and 5

This is a DAG: 5 → 8 → 7. Case 6 depends on 3 and 5.

---

## Key Finding 2: The Correct Proof Structure is Junction-Depth Induction

### GHR94 Does NOT Intend Cases 5-8 to Be Self-Contained

The paragraph after Lemma 10.2.3 (line 122 of the literature markdown) is key:

> "We now know the basic steps in our proof of separation. We simply keep pulling out Us from under the scopes of Ss and vice versa until there are no more."

The word **"keep"** is critical. The 8 cases are ITERATIVE STEPS, not terminal rules. After applying Case 7's reduction, you get new formulas that may themselves require more reduction steps. The termination is guaranteed by the junction-depth decreasing at each step.

The hierarchy that GHR94 builds:

```
Lemma 10.2.8 (junction depth induction)
  → Lemma 10.2.7 (no S in U, induction on U-nesting depth)
    → Lemma 10.2.6 (multiple U-types, induction on count)
      → Lemma 10.2.5 (single U-type, induction on S-nesting depth k)
        → Lemma 10.2.4 (single S with top-level U(A,B), 8 cases)
          → Lemma 10.2.3 (the 8 elimination cases)
```

The 8 cases are the base tools. The hierarchy builds termination on top of them.

### The "Direct Proof" Fallacy

Several previous plans attempted to find "direct" separated equivalents for Cases 5-8 -- formulas that are syntactically separated AND semantically equivalent to the Case 5-8 LHS. GHR94 does NOT claim to give such formulas. GHR94's proof of Lemma 10.2.3 only gives INTERMEDIATE equivalents that still require further separation steps (handled by the hierarchy).

The attempt to find self-contained separated equivalents for Cases 5-8 is not what GHR94 does, and it is the root cause of the recurring blocker.

---

## Key Finding 3: Case 5 Semantic Proof IS Independent

Despite the above, Case 5 CAN be proved independently using semantic arguments, as GHR94 describes:

> "S(a ∧ U(A, B), q ∨ U(A, B)) is equivalent to
> S(a, B) ∧ [A ∨ (B ∧ U(A, B))]
> ∨ S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A)) ∧ [A ∨ (B ∧ U(A, B))] ∧ ¬S(¬q, ¬A).
> The first disjunct holds when the A from U(A,B) is true in the future or present and the second when it is true in the past."

However, this formula is **incorrect on Z** (documented in report 02). The issue is:
- On Z, U(A,B)(t) can hold via A(t+1) with vacuous B-guard (since (t, t+1)_Z = {})
- GHR94's formula requires B to hold from s to the A-witness, which fails for the vacuous case

So GHR94's Case 5 formula is only valid for dense/Dedekind-complete time, not Z.

### Case 5 for Z: The Correct 3-Disjunct Formula

As established by the Dedekind specialization in report 05_teammate-d-findings.md, the correct formula for Case 5 on Z is:

```
S(a ^ U(A,B), q v U(A,B)) <->
   S(a ^ U(A,B), q)                                              [D1]
   v (S(alpha, Q) ^ (A v (B ^ U(A,B))))                         [D2]
   v S(A ^ (q v U(A,B)) ^ S(alpha, Q), q)                       [D3]

where:
  Q     = B v NOT S(not q, not A) v A
  alpha = (a ^ U(A,B)) v (not q ^ U(A,B) ^ S(a ^ U(A,B), q))
```

This formula IS semantically correct on Z. The problem is that D2 and D3 are not themselves syntactically separated -- they contain `Q` (which has `snce` in it, making it non-S-free) and complex alpha expressions.

**The Dedekind formula approach does not eliminate the need for the hierarchy -- it shifts the problem from "prove Cases 5-8" to "prove S(alpha, Q) with non-S-free guard Q".**

---

## Key Finding 4: What the Current Code Has and What Is Missing

### Currently Available

1. `elim_case_1_gen` (Eliminations.lean): Case 1 with U-free (not S-free) guard q -- PROVED
2. `elim_case_2_gen` (Eliminations.lean): Case 2 with U-free (not S-free) guard q -- PROVED
3. `junction_depth` (TemporalClosure.lean): The induction measure -- DEFINED
4. `abstract_untl` (Hierarchy.lean): Replace U(A,B) with fresh atom -- PROVED with preservation lemmas
5. `multi_U_formula_separable` (Hierarchy.lean): Uses `all_separable` (AXIOM-BACKED)
6. Cases 1-4 in Eliminations.lean: PROVED
7. `neg_until_equiv` (NegationEquiv.lean): NOT U <-> G(NOT A) v U(NOT A ^ NOT B, NOT A) -- PROVED

### Critical Missing Pieces

1. **`abstract_snce`** (~120 LOC): Dual of `abstract_untl`. Needed to replace S(C,D) subformulas with fresh atoms inside U-arguments. This is what makes the junction-depth induction terminate (JD decreases when you abstract the deepest S inside U).

2. **`count_S_subformulas`** (~20 LOC): Dual of existing `count_U_subformulas`. Needed for the compound measure.

3. **Mutual WF theorems** (`no_S_nested_in_U_separable` and `no_U_nested_in_S_separable`): These are the core theorems that break the circular axiom dependency. The junction-depth induction calls each through the other.

4. **`snce_separable` as a theorem** (not axiom): Follows from the mutual WF theorems.

### Why the Circularity Exists

The current circularity `snce_separable ← single_U_formula_separable ← multi_U_formula_separable ← all_separable ← snce_separable` is circular because `single_U_formula_separable` uses `snce_separable` for its snce case. This is correct for the INDUCTIVE approach:

In GHR94's Lemma 10.2.5, the proof of "single U-type formula is separable" works by induction on the maximum number of nested Ss above any U(A,B). The snce case (adding one more S nesting) is exactly what the induction handles -- and the IH provides separability of the snce's arguments, from which we need to conclude separability of the snce itself.

The key insight GHR94 uses: if D = S(C, F) and both C and F are separable (by IH), we don't directly conclude S(C,F) is separable. Instead, we use Lemma 10.2.4 to reduce S(C,F) where U appears at top level to the 8 cases. Lemma 10.2.4 works because after separating C and F (by IH), U(A,B) appears only at top level in the separated C and F (not under nested S). Then the 8 cases handle the top-level appearances.

The correct implementation of `single_U_formula_separable` should NOT call `snce_separable`. Instead:
1. For snce case: apply Lemma 10.2.4 directly (after IH reduces C and F to single-U-type separated forms)
2. The 8 cases handle each configuration

---

## Key Finding 5: The Correct Implementation Path

Based on the GHR94 structure, here is the CORRECT path:

### Path A: Full Junction-Depth Hierarchy (~500-720 LOC)

This directly implements GHR94's proof structure:

1. Implement `abstract_snce` (~120 LOC) -- dual of `abstract_untl`
2. Implement `count_S_subformulas` and compound measure `(junction_depth, count_U + count_S)` (~40 LOC)
3. Prove `no_S_nested_in_U_separable` by WF induction on `(count_U_subformulas phi, size phi)`:
   - Base: count_U = 0 means U-free. But U-free does NOT mean separated (may contain `all_future(snce ...)`)! This is the "purity mismatch" problem identified in report 05.
   - For the snce case: apply Lemma 10.2.4 reduction (8 cases) at the deepest S containing U
4. Prove `no_U_nested_in_S_separable` dually via `swap_temporal`
5. Derive temporal closure theorems as corollaries

### Path B: Atomic-Only Cases 5-8 via Semantic Arguments (~300 LOC)

Since the plan's theorem signatures require only `is_U_free` and `is_S_free` hypotheses (which for the purposes of the Cases 5-8 theorems in NormalForm.lean means atoms or atom-like formulas), there is a SIMPLER path:

For the specific theorems `case5_separable`, `case6_separable`, `case7_separable`, `case8_separable` as stated in NormalForm.lean:

**Case 7** (simplest): Use GHR94's three-disjunct formula. Disjuncts 2 and 3 are directly separated. Disjunct 1 = `S(A ∧ (q ∨ ¬U(A,B)) ∧ S(a, B∧q), q ∨ ¬U(A,B))` needs further elimination.

For Disjunct 1: apply `neg_until_equiv` to `¬U(A,B)` to expand it:
- `¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A)`
- In our formalization: `neg(untl A B) ↔ all_future(neg A) v untl(and(neg A)(neg B))(neg A)`

After substitution, distribute S over disjunctions (Lemma 10.2.1 = our `since_distrib_or_left`). Each resulting S-formula has SINGLE U-type with S-free A, B arguments. These fall under Cases 1-4 (provable without hierarchy for atomic a, q, A, B).

The purity issue: `all_future(neg A)` -- is_U_free returns true for this (our formalization), but GHR94 would call this a U-formula. Our `is_syntactically_separated` accepts `snce x (all_future y)` if `is_U_free(all_future y) = true`. For atoms, this works because `is_U_free(all_future(neg A)) = is_U_free(neg A) = true` for atom A.

**Case 5** (for atoms): GHR94's formula is INCORRECT on Z. The correct approach:
- Use the three-disjunct formula from the Dedekind specialization (report 05_teammate-d-findings.md)
- D1 = S(a^U,q): Case 1 (proved)
- D2 = S(alpha, Q)^beta: Apply `elim_case_1_gen` to each disjunct of alpha after distributing S via Lemma 10.2.1. Q is U-free (verified). alpha = (a^U) v (not q ^ U ^ S(a^U,q)). Both disjuncts are Case 1 patterns with U-free guard Q.
- D3 = S(A ^ (q v U) ^ S(alpha,Q), q): After D2 is separated, S(alpha,Q) is replaced by its separated form phi'. Then D3 = S(A ^ (q v U) ^ phi', q). Distributing with Lemma 10.2.1 and applying generalized Case 1.

**Case 8** (reduce to Case 5): Use GHR94's explicit formula. `¬Case8 ↔ H(...) v S(...)`. The second S-formula is a Case 5 pattern. Separate Case 5 first, negate.

**Case 6** (reduce to Cases 2+5): Use `neg_until_equiv` on `¬U` in the event, distribute, each resulting formula falls under Case 2 or Case 5.

### Path B Roadblock

Path B still requires:
1. Proving the Dedekind-specialized Case 5 formula is semantically correct on Z (~100 LOC, a semantic argument)
2. Proving S(alpha, Q) is separable where Q = `B v NOT S(not q, not A) v A` is non-S-free

Point 2 is the core difficulty. `elim_case_1_gen` handles `S(a^U, Q)` when Q is U-free. Q = `B v NOT S(not q, not A) v A` IS U-free (for atoms B, q, A). The issue is that `a` in D2 is `alpha = (a^U) v (not q^U^S(a^U,q))`. After case 1 is applied, the "a" part becomes complex. But the key insight is:

**`elim_case_1_gen` requires: a is U-free, q is U-free, A is U-free, B is U-free, A is S-free, B is S-free.**

For D2, the "a" parameter is `alpha`, not atomic. After applying Lemma 10.2.1 (distribution) to S(alpha, Q) to split on the disjunction in alpha, we get:
- S(a^U(A,B), Q): "a" is an atom (U-free, S-free). `elim_case_1_gen` applies directly.
- S(not q ^ U(A,B) ^ S(a^U,q), Q): "a" parameter is `not q ^ S(a^U,q)` which is U-free (for atoms). Q is U-free. `elim_case_1_gen` applies.

So **Path B is feasible**! The key is to distribute S over alpha first (using Lemma 10.2.1), then apply `elim_case_1_gen` to each piece.

---

## Confidence Level

**High (90%)** on the misidentification of GHR94's Case 7 formula (the plan's "D2" is GHR94's D1, which is not separated and needs further elimination).

**High (85%)** on the claim that the Dedekind Case 5 3-disjunct formula is semantically correct on Z. This has been verified by Teammate D against the documented counterexample.

**High (80%)** on Path B feasibility. The mathematical argument is sound:
1. GHR94 explicitly gives the Case 5 semantic equivalence (verified as correct for Z via the Dedekind specialization)
2. `elim_case_1_gen` handles S(U-free-event, U-free-guard)
3. The alpha distribution (Lemma 10.2.1 = `since_distrib_or_left`) separates alpha into U-free components

**Medium (65%)** on LOC estimate and time to implement. The semantic equivalence proofs (showing D1 v D2 v D3 ↔ Case 5 LHS) may be 150-200 LOC of careful case analysis.

**Lower (50%)** on whether the full junction-depth approach (Path A) is faster or more reliable than Path B given the history of failed attempts.

---

## Recommended Approach

Implement **Path B** (atomic-only Cases 5-8 via semantic arguments + distribution + generalized Case 1) in this order:

### Step 1: Prove Case 5 Semantic Equivalence (~150 LOC)
Prove that `Case5_LHS ↔ D1 v D2 v D3` where D1, D2, D3 are the Dedekind-specialized 3-disjunct formula. This is a semantic argument. Key: witness analysis on the position of A-witness u relative to t (u > t, u = t, u < t for D1, and the third-past case for D2/D3).

Actually, the Dedekind formula DOES NOT use the 3-case trichotomy of the original Case 5. It uses a different analysis. The semantic equivalence needs to be proved from scratch for Z using the correct Z semantics (where vacuous guards are possible).

**Alternative to the semantic proof**: Use the equivalent of Case 3 applied to the whole formula. Case 3 says:
```
S(event, q v U(A,B)) ↔ NOT(...) [complex formula]
```
For Case 5, event = `a ^ U(A,B)`. Apply Case 3 with this event. The result has U(A,B) in positions derived from `not event`. Then:
- `not event = not(a ^ U(A,B)) = not a v not U(A,B)`
- Apply neg_until_equiv to `not U(A,B)`: `not U(A,B) ↔ all_future(not A) v U(not A ^ not B, not A)`
- Distribute S over disjunctions
- Each piece falls under Cases 1-4

The advantage: Case 3 is already proved (no new semantic argument needed). The result has lower junction depth by construction.

### Step 2: Prove Case 7 (~100 LOC)
- State the 3-disjunct GHR94 formula for Case 7
- D2 = S(a, B^q) ^ A is directly separated for atoms
- D3 = S(a, B^q) ^ B ^ U(A,B) is directly separated for atoms
- D1 = S(A ^ (q v NOT U) ^ S(a, B^q), q v NOT U) requires Cases 8 and 4

For D1: expand `not U(A,B)` via neg_until_equiv in both event and guard. This introduces G(not A) terms:
- `q v G(not A) v U(not A ^ not B, not A)` as the guard
- `A ^ (q v G(not A) v U(not A ^ not B, not A)) ^ S(a, B^q)` as the event

After distribution, each piece falls under Cases 1-4 (since the U in the guard is U(not A ^ not B, not A) with S-free args, and the S-term in the event is U-free).

### Step 3: Prove Case 8 (~80 LOC)
Use GHR94's negation reduction explicitly. `NOT Case8 ↔ H(not a v U(A,B)) v S(not q ^ not a ^ U(A,B), not a v U(A,B))`.
- The S-term is a Case 5 pattern (U in both event and guard) -- use Step 1.
- H(not a v U(A,B)) = all_past(neg(or(neg a)(neg(untl A B)))): This is `all_past(and a (neg(untl A B)))`. For atoms a, A, B: `a ^ neg U(A,B)` is U-free? No! neg(untl A B) has untl. BUT: in our formalization, `all_past phi` is separable as long as `phi` is separable. Once Case 5 is proved, `phi = a ^ U(A,B)` (after double negation) is separable. Actually `H(not a v U(A,B)) = neg S(neg(not a v U(A,B)), top) = neg S(a ^ not U(A,B), top)`. This is neg of a Case 2 pattern! Case 2 is proved. So `H(...)` is separable as neg of a separated Case 2 result.

Actually: `neg S(a ^ not U(A,B), top)` = `NOT H(...)` no wait. `H(phi) = neg S(neg phi, top)`. So `H(not a v U(A,B)) = neg S(neg(not a v U(A,B)), top) = neg S(a ^ neg U(A,B), top)`. This IS provable:
- `S(a ^ neg U(A,B), top)` is Case 2 (event = a^NOT U, guard = top = TRUE). Case 2 is proved.
- Therefore `neg S(a ^ neg U(A,B), top)` = neg of a separated Case 2 formula, which is separable.

### Step 4: Prove Case 6 (~80 LOC)
Apply neg_until_equiv to expand NOT U in the event. Split:
- S(a ^ G(not A), q v U(A,B)): event is `a ^ all_future(not A)`. `all_future(not A)` is U-free. So event is U-free. This is Case 3 (U only in guard).
- S(a ^ U(not A ^ not B, not A), q v U(A,B)): This has two different U-formulas, but BOTH have S-free arguments (not A, not B, not A are S-free atoms). Apply Lemma 10.2.6 (multi_U_formula_separable) -- but that uses the axiom!

Actually for Case 6, the guard's U(A,B) and the event's U(not A ^ not B, not A) are DIFFERENT U-formulas. GHR94 says "use eliminations (3) and (5)":
- First separate for U(A,B) (the guard) treating U(not A^not B, not A) as a fresh atom q1. This is Case 3 or Case 5 with q1 as an atom.
- Then substitute back q1 = U(not A^not B, not A) and re-separate using the induction hypothesis.

This IS the Lemma 10.2.6 argument -- and it requires the multi-U induction! However, there's a simpler path for atoms: since both U-formulas have S-free args (for atoms), and the formula as a whole satisfies `no_S_nested_in_U`, it falls under `multi_U_formula_separable` -- which currently uses `all_separable` (axiom). This is exactly the circular dependency.

**The non-circular path for Case 6**: Since our two U-formulas are U(A,B) and U(not A ^ not B, not A), and both have S-free args, we can apply:
1. `abstract_untl` on U(A,B) with fresh atom q1 to get a formula with only U(not A^not B, not A)
2. Apply Lemma 10.2.5 (which handles the single-U case) to separate this
3. Substitute back q1 = U(A,B) in the separated result
4. Now we have a formula with U(A,B) in separated positions (not under S) -- it's already separated for the U(A,B) part

The `abstract_untl` machinery is already in the codebase. The issue is that step 3 (substitution and re-separation) requires proving that subst into a separated formula preserves separability -- which is `subst_preserves_separation`, a needed lemma.

---

## Summary of Findings

| Question | Answer |
|----------|--------|
| Does GHR94 use Dedekind formula for Cases 5-8 on Z? | NO. Dedekind formula is for Section 10.3 (dense time). Integer Section 10.2 uses direct semantic arguments + iterative elimination |
| Is the Case 7 D2 formula from the plan correct? | NO. The plan misread GHR94. GHR94's D1 (= plan's D2) is NOT separated; it requires eliminations 8 and 4 |
| Is there a single-level induction for no_S_nested_in_U? | NO. GHR94 uses multi-level: 8 cases → 10.2.4 → 10.2.5 → 10.2.6 → 10.2.7 → 10.2.8 |
| Can Case 7 be proved without the full hierarchy? | YES for atoms, by expanding NOT U via neg_until_equiv in D1, then applying Cases 1-4 |
| Can Case 5 be proved without the full hierarchy? | POSSIBLY, via the Dedekind 3-disjunct formula + elim_case_1_gen on each component |
| Does Case 8 depend on Case 5? | YES, explicitly stated in GHR94 |
| What is the recommended path? | Path B: semantic proofs for Cases 5-8 in dependency order (5 → 8 → 7, 5+2 → 6) using neg_until_equiv + distribution + elim_case_1/2_gen |

---

## References

- `/home/benjamin/Projects/ProofChecker/literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` (lines 80-120 for Cases 5-8; lines 140-220 for Lemmas 10.2.4-10.2.8)
- `/home/benjamin/Projects/ProofChecker/specs/157_expressive_completeness_su_integer/handoffs/phase-6-handoff-20260517T200000.md` (Phase 6 blocker details)
- `/home/benjamin/Projects/ProofChecker/specs/157_expressive_completeness_su_integer/reports/05_teammate-d-findings.md` (Dedekind formula analysis, K+=K-=FALSE verification)
- `/home/benjamin/Projects/ProofChecker/specs/157_expressive_completeness_su_integer/reports/05_ghr94-ch10-deep-analysis.md` (purity mismatch analysis)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Cases 1-2 proofs, elim_case_1_gen, elim_case_2_gen)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (abstract_untl machinery)
