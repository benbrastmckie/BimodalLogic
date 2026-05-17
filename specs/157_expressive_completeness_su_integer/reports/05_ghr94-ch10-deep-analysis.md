# GHR94 Chapter 10 Deep Dive: Separation Theorem Case Analysis

## Executive Summary

This report presents a careful re-reading of GHR94 Chapter 10 (separation theorem for {S,U} over integer time Z) and Chapter 9 (framework definitions). It resolves the five research questions posed about the relationship between GHR94's text and our Lean formalization. The central findings are:

1. **GHR94's formula language includes ONLY S and U as temporal operators.** G and H are DERIVED operators (G(phi) = neg U(neg phi, top), H(phi) = neg S(neg phi, top)). Our Lean formalization has `all_future` and `all_past` as PRIMITIVES, creating a purity mismatch.

2. **"U-free" in GHR94 means NO U operator at all.** Since G is derived from U, a truly "U-free" formula in GHR94 contains no G either. Our `is_U_free` predicate allows `all_future` through, which is incorrect relative to GHR94.

3. **The Case 5 explicit formula IS incorrect on Z**, as previously documented. But the Dedekind complete proof (Lemma 10.3.11.5) reveals a reduction strategy: apply elimination (3) to Case 5, then handle residual U occurrences by re-applying Case 1. This strategy generalizes to Z.

4. **Cases 6-8 in GHR94 are genuinely reduced to earlier cases**, and GHR94 DOES acknowledge the structural complexity (Case 8 uses negation to introduce previous cases). The "two-U issue" is resolved by iterated elimination, exactly as report 04 analyzed.

5. **The induction structure is junction depth (Lemma 10.2.8), not formula size.** The hierarchy is: 8 cases -> single-U-under-S (10.2.5) -> multi-U-under-S (10.2.6) -> no-S-in-U (10.2.7) -> general (10.2.8). Our formalization collapses the hierarchy with axioms.

**Critical recommendation**: Fix `is_U_free` to reject `all_future` (and `is_S_free` to reject `all_past`), then implement the Case 3 -> Case 5 reduction following the Dedekind complete proof strategy.

---

## 1. GHR94 Language Definition

### 1.1 The Formal Language

GHR94 Chapter 9 (Section 9.1) defines the temporal language as built from connectives. The key connectives discussed are:

- **S (Since)**: `||S(p,q)||_t = 1 iff exists s < t: p(s) and forall y in (s,t): q(y)`
- **U (Until)**: `||U(p,q)||_t = 1 iff exists s > t: p(s) and forall y in (t,s): q(y)`
- **F (some_future)**: `||Fp||_t = 1 iff exists s > t: p(s)` -- noted as `F(p) = U(p, top)` in Example 9.1.3
- **P (some_past)**: `||Pp||_t = 1 iff exists s < t: p(s)` -- similarly `P(p) = S(p, top)`

Section 9.2 discusses G and H as the DUALS of F and P:

- **G (all_future)**: `G(phi) = neg F(neg phi) = neg U(neg phi, top)`
- **H (all_past)**: `H(phi) = neg P(neg phi) = neg S(neg phi, top)`

**Crucially**: Chapter 10.2 works exclusively in "the language with the connectives S and U." The section heading (10.2) says "Separation for S, U over Integer Time." G and H appear in the text (e.g., Lemma 10.2.2 uses G(neg A) and H(neg A)) but always as ABBREVIATIONS for neg U(neg A, top) and neg S(neg A, top).

### 1.2 G and H are Derived, Not Primitive

This is established explicitly:
- Example 9.1.3: "Fp = U(p, top)"
- Chapter 10.3 (p.248 in the markdown): K+ is introduced as neg U(top, neg q), showing U is the underlying operator.
- The separation definition (both integer and Dedekind) speaks of separating "the language with {U, S}"

GHR94 does NOT include G or H in its primitive connective set. They appear as notational conveniences.

### 1.3 Implication for Our Formalization

Our Lean `Formula` type has `all_future` and `all_past` as PRIMITIVE constructors (alongside `untl` and `snce`). This means:

- In GHR94: `G(phi)` is syntactic sugar for `neg U(neg phi, top)`, which is `(phi.neg.untl .bot.neg.imp .bot).imp .bot ... ` -- a complex expression using `imp`, `bot`, and `untl`.
- In our formalization: `all_future phi` is a single constructor, syntactically distinct from any `untl` expression.

This difference is NOT just cosmetic. It affects the meaning of "U-free" and "S-free" as detailed in Section 2.

---

## 2. GHR94 Separation Definitions

### 2.1 What "U-free" Means in GHR94

Since GHR94 works in a language where G is DEFINED as `neg U(neg phi, top)`, the term "U-free" means:

**(b) No U and no G** -- because G IS a U formula.

A formula is "U-free" in GHR94's sense if it contains no `U` subformula whatsoever, including the derived operator `G`. Concretely, a U-free formula in GHR94 is built from atoms, boolean connectives, S, and (crucially) NOT G or F.

Conversely, "S-free" means no S subformula, including H and P.

### 2.2 Syntactic Separation in GHR94 (Integer Case)

The text after Lemma 10.2.3 (line 122 in our markdown) says:

> "Given a wff A, this process will eventually leave us with a syntactically separated wff, i.e. a wff B which is a boolean combination of atoms, wffs U(E, F) with E and F built without using S and wffs S(E, F) with E and F built without using U."

This definition is key:
- A formula is syntactically separated if it is a boolean combination of:
  1. **Atoms** (pure present)
  2. **U(E, F)** where E, F contain no S (pure future)
  3. **S(E, F)** where E, F contain no U (pure past)

Since G is a U-formula: in a syntactically separated formula, `G(phi)` CAN appear inside `U(E, F)` (since E, F are S-free, not U-free), and `H(phi)` CAN appear inside `S(E, F)`.

But `G(phi)` CANNOT appear at top level or inside `S(E, F)` (because G contains U, violating the "E, F contain no U" requirement for S-arguments).

### 2.3 Comparison with Our Lean Definition

Our `is_syntactically_separated` (in Defs.lean):
```
| .all_past phi => is_U_free phi
| .all_future phi => is_S_free phi
| .untl phi psi => is_S_free phi && is_S_free psi
| .snce phi psi => is_U_free phi && is_U_free psi
```

And our `is_U_free`:
```
| .all_future phi => is_U_free phi   -- ALLOWS all_future through!
```

**This is the purity mismatch.** Our `is_U_free` returns `true` for `all_future phi` when `phi` is U-free. But in GHR94, `G(phi) = neg U(neg phi, top)` is NOT U-free regardless of `phi`. So `all_future phi` should be treated as containing a U.

Similarly, `is_S_free` returns `true` for `all_past phi` when `phi` is S-free, but `H(phi)` in GHR94 is NOT S-free.

### 2.4 Impact of the Mismatch

The mismatch means our `is_syntactically_separated` is **more permissive** than GHR94's definition:
- We accept `all_past(U_free_phi)` as separated, but GHR94 wouldn't allow a standalone `H(phi)` in a separated formula unless it's inside `S(E, F)`.
- We accept `all_future(S_free_phi)` as separated, but GHR94 wouldn't allow a standalone `G(phi)` unless it's inside `U(E, F)`.

However, there's a subtlety: in GHR94, `H(phi)` IS pure past (it depends only on times < t), so `H(phi)` at top level in a separated formula is semantically fine. The issue is purely syntactic -- GHR94's separation is syntactic, and `H(phi) = neg S(neg phi, top)` is already a boolean combination of atoms and S-formulas.

In our formalization with primitive `all_past`, the formula `all_past phi` is semantically pure past, and syntactically it's a single constructor. So accepting it as a "separated unit" is semantically correct, even if it doesn't match GHR94's syntactic criterion exactly.

**The real problem is**: when our `is_U_free` says `all_future phi` is "U-free", it allows `all_future phi` to appear inside `snce` arguments. But `G(phi) = neg U(neg phi, top)` inside S is NOT something GHR94's separation allows -- it's a U-under-S, which is exactly what separation is supposed to eliminate.

### 2.5 Resolution Options

**Option A (Strict GHR94 compliance)**: Redefine `is_U_free` to return `false` for `all_future`, and `is_S_free` to return `false` for `all_past`. This matches GHR94 exactly.

**Option B (Semantic correctness)**: Keep the current definitions but add a clause to `is_syntactically_separated` that handles `all_past` and `all_future` at top level. This is semantically correct but deviates from GHR94's syntactic definition.

**Recommendation: Option A.** The mismatch with GHR94 causes confusion in the proofs and may introduce subtle bugs. Aligning with GHR94 makes the literature correspondence exact.

---

## 3. Case 5 Analysis

### 3.1 GHR94's Integer Case 5 (Lemma 10.2.3.5)

The text states:

> S(a and U(A, B), q or U(A, B)) is equivalent to
>
> S(a, B) and [A or (B and U(A, B))]
> or S(A and S(a, B), A or B or neg S(neg q, neg A))
>   and [A or (B and U(A, B))] and neg S(neg q, neg A).
>
> The first disjunct holds when the A from U(A,B) is true in the future or present and the second when it is true in the past.

### 3.2 Error Analysis (Confirmed)

As documented in report 02, the formula is incorrect on Z. The counterexample is:

- a(0)=true, A(1)=true, B=false everywhere, q(1)=q(2)=true
- LHS at t=3: TRUE (witness s=0, U(A,B)(0) via u=1 with vacuous B, guard q on {1,2})
- RHS at t=3: FALSE (both disjuncts require `A(3) or (B(3) and U(A,B)(3))` which is false)

The root cause is that on Z, `U(A,B)(n)` can hold via a vacuous B-guard when A(n+1) is true (since `(n, n+1)_Z = {}`). GHR94's formula assumes the U-chain "propagates" B-coverage to the evaluation point t, which only works in dense time.

### 3.3 The Dedekind Complete Case 5 Strategy (Key Insight)

Lemma 10.3.11.5 handles Case 5 for Dedekind complete time with a COMPLETELY DIFFERENT strategy than the integer version. Instead of giving a direct semantic argument, it says:

> "To separate S(a and U(A,B), q or U(A,B)) use elimination (3) to rewrite it equivalently..."

The proof APPLIES Case 3's formula to the whole formula, treating `a and U(A,B)` as the "a" parameter of Case 3. The resulting formula still contains U(A,B) but in positions that can be further separated by Case 1.

Concretely, the strategy is:
1. Apply Case 3 to `S(a and U(A,B), q or U(A,B))` with a_param = `a and U(A,B)`, q_param = `q`
2. The result contains `S(a and U(A,B), q)` (which is Case 1) and other terms involving `a and U(A,B)` in S-arguments
3. Apply Case 1 to separate `S(a and U(A,B), q)` and to the alpha-expression
4. Further applications of Case 1 separate the nested S(alpha, Q)

### 3.4 Can This Strategy Work for Integers?

**Yes, with modification.** The integer Case 3 formula (Lemma 10.2.3.3) is:

```
S(a, q or U(A,B)) <->
  not( H(not a) or [S(not a and not q, not a and not A) and not A and (not U(A,B) or not B)]
       or S(not A and not B and not a and S(not a and not q, not A and not a), not a) )
```

This is derived semantically and is correct for ANY formula `a`, not just atoms. If we substitute `a := a_orig and U(A,B)`:

```
S(a_orig and U(A,B), q or U(A,B)) <->
  not( H(not(a_orig and U(A,B))) or [negation terms...] )
```

The negation `not(a_orig and U(A,B))` = `not a_orig or not U(A,B)`, which contains U. So the result has U appearing under S (inside the H and the inner S formulas).

But this is exactly the "iterated elimination" situation: the result has fewer U-S junctions than the original (U(A,B) in the guard has been eliminated; only U(A,B) in the expanded negation terms remains). The remaining U-under-S can be handled by further applications of Cases 1-4 (since the remaining U appears in simpler structural positions).

### 3.5 Why This Works (Well-Foundedness)

The key measure is the **number of U-S junctions** (places where U appears under S or S appears under U). In Case 5, the original formula `S(a and U(A,B), q or U(A,B))` has U(A,B) appearing twice under S (once in event, once in guard).

After applying Case 3 (treating the whole formula as `S(event, q or U(A,B))`), the U(A,B) in the guard position is eliminated. The result still has U(A,B) in certain positions (from the expansion of `not event`), but these U occurrences are in "simpler" structural positions that can be handled by Cases 1-4.

The well-foundedness argument is: each application of an elimination case reduces the total number of U-S junctions (or more precisely, reduces the junction depth in the sense of Lemma 10.2.8).

### 3.6 Concrete Reduction for Integer Case 5

Here is the step-by-step reduction:

**Step 1**: Apply Case 3 formula to `S(a', q or U(A,B))` where `a' = a and U(A,B)`.

The Case 3 result is (from our proved theorem):
```
not( H(not a') or [S(not a' and not q, not a' and not A) and not A and (not U(A,B) or not B)]
     or S(not A and not B and not a' and S(not a' and not q, not A and not a'), not a') )
```

Substituting `not a' = not a or not U(A,B)`:
```
not( H(not a or not U(A,B))
     or [S((not a or not U(A,B)) and not q, (not a or not U(A,B)) and not A) and not A and (not U(A,B) or not B)]
     or S(not A and not B and (not a or not U(A,B)) and S((not a or not U(A,B)) and not q, not A and (not a or not U(A,B))), not a or not U(A,B)) )
```

**Step 2**: Each component containing `not U(A,B)` under S needs further elimination.

- `H(not a or not U(A,B))`: The `not U(A,B)` here is under H (which is `all_past`). In GHR94's framework, H = neg S(neg phi, top), so this is really S-related. Apply `neg_until_equiv` to expand `not U(A,B)` first.

- The S-formulas containing `not U(A,B)` can be expanded using `neg_until_equiv`: `not U(A,B) <-> G(not A) or U(not A and not B, not A)`. Then distribute and apply Cases 1-4 to the resulting single-U formulas.

**Step 3**: After expanding all `not U(A,B)` occurrences, each S-subformula has at most one U-formula (either U(A,B) from the original, or `U(not A and not B, not A)` from the negation expansion -- but not both in the same S). These are all Cases 1-4 patterns.

**The key point**: applying Case 3 with `a' = a and U(A,B)` is semantically correct. The resulting formula is more complex but has lower junction depth. The expansion of `not U(A,B)` via `neg_until_equiv` introduces a second U-formula, but it's in a DISJUNCTION with `G(not A)` (which is U-free in the formula-as-syntax sense, being `all_future(neg A)`, though in GHR94 it would be a U-formula). After distributing the disjunction, each disjunct has only a single U-formula under each S.

### 3.7 Why GHR94 Doesn't Explain This for Integers

GHR94's integer proof (Lemma 10.2.3.5) gives a direct semantic argument with an explicit formula. The authors likely intended the formula to be correct and didn't anticipate the vacuous-guard issue specific to discrete time.

The Dedekind complete proof (Lemma 10.3.11.5) uses the reduction-to-Case-3 strategy because it HAS to: the explicit formula involves K+, K-, and Gamma operators that don't exist in the simpler integer language. But the reduction strategy is actually MORE robust because it avoids discrete-time pitfalls.

---

## 4. Cases 6-8 Analysis

### 4.1 Case 6: S(a and not U(A,B), q or U(A,B))

GHR94's approach (Lemma 10.2.3.6): "The case is separated by considering when the first occurrence (if any) of not B after s is." The formula has two disjuncts, and GHR94 says "Eliminations (3) and (5) can be used to finish the separating."

This means Case 6 is EXPLICITLY REDUCED to Cases 3 and 5. GHR94 does NOT acknowledge the "two-U issue" as a problem because the reduction goes through the HIGHER-LEVEL lemmas (10.2.4-10.2.8) that handle multiple U-formulas.

**Our analysis (confirmed by report 04, Section 1.7)**: After applying `neg_until_equiv` to expand `not U(A,B)` in the event:
- Disjunct 1: `S(a and G(neg A), q or U(A,B))` -- this is Case 3 (proved)
- Disjunct 2: `S(a and U(A', B'), q or U(A,B))` -- two U-formulas

Disjunct 2 can be handled by the iterated elimination approach: treat U(A,B) as a fresh atom, apply Case 1 to eliminate U(A',B'), substitute back, then re-separate using Cases 1-5.

**Dependency: Cases 1, 3, and potentially 5.**

### 4.2 Case 7: S(a and U(A,B), q or not U(A,B))

GHR94's approach (Lemma 10.2.3.7): "By considering when A is true we deduce that our formula is equivalent to [a three-disjunct formula]. The first disjunct can be further eliminated by eliminations (8) and (4)."

Case 7 reduces to Cases 4 and 8. Looking at the formula:

```
[S(A and (q or not U(A,B)) and S(a, B and q), q or not U(A,B))]
or [S(a, B and q) and A]
or [S(a, B and q) and B and U(A,B)].
```

Disjuncts 2 and 3 are already separated (S has U-free args; A and B are atoms; U(A,B) at top level). Disjunct 1 has `not U(A,B)` in both event and guard, which is Case 8 pattern (after expansion). GHR94 then says "use the eighth and fourth eliminations."

**After applying `neg_until_equiv` to `not U(A,B)`**: the guard `q or not U(A,B)` becomes `q or G(neg A) or U(A', B')`. The event `A and (q or not U(A,B)) and S(a, B and q)` also expands. Each disjunct after distribution has at most one U-formula under S.

**Dependency: Cases 4, 8 (which itself depends on 3 and 5).**

### 4.3 Case 8: S(a and not U(A,B), q or not U(A,B))

GHR94's approach (Lemma 10.2.3.8) is the most explicit about the reduction:

> "can be reduced to cases already discussed since
> not S(a and z, q or y) <-> H(not a or not z) or S(not q and not y and not a, not a or not z) or S(not q and not y and not z, not a or not z).
> Substituting y = z = not U(A,B) we obtain
> not D <-> H(not a or U(A,B)) or S(not q and not a and U(A,B), not a or U(A,B)) or S(not q and U(A,B), not a or U(A,B)).
> Notice the last disjunct in not D is redundant.
> These are cases we can handle by other eliminations, especially elimination (5)."

This is the KEY reduction for Case 8. By negating the formula and applying `neg_since_equiv` (substituting `y = z = not U(A,B)`, so `not y = not z = not not U(A,B) = U(A,B)`), GHR94 obtains:

```
not D <-> H(not a or U(A,B)) or S(not q and U(A,B) and not a, not a or U(A,B))
```

(The third disjunct is redundant as noted.)

Now:
- `H(not a or U(A,B))`: has U under H (= under S in GHR94's framework)
- `S(not q and U(A,B) and not a, not a or U(A,B))`: U(A,B) appears in both event AND guard

The second S-formula IS a Case 5 pattern (with `a' = not q and not a`, `q' = not a`, and U(A,B) in both positions).

So `D <-> not [H(...) or S(...)]` is separated by taking the negation of a separated formula (which preserves separation).

**Dependency: Case 5 (explicitly stated by GHR94), plus Case 1 for the H term.**

### 4.4 GHR94's Awareness of the Two-U Issue

GHR94 does NOT explicitly discuss the "two-U issue" as a problem. This is because their proof architecture handles it naturally through the HIGHER-LEVEL lemmas:

- **Lemma 10.2.4** (single S with top-level U(A,B)): Uses normal forms + Lemma 10.2.1 to reduce to the 8 cases. The U(A,B) that appears can be in event, guard, or both.
- **Lemma 10.2.5** (single U formula): Induction on S-nesting depth above U(A,B).
- **Lemma 10.2.6** (multiple U formulas): Induction on the number n of distinct U-formulas. The proof replaces n-1 of them by fresh atoms, separates for the remaining one, then re-substitutes and re-separates.

When Case 6 introduces two U-formulas via `neg_until_equiv`, the resulting formula falls under Lemma 10.2.6 with n=2. The proof of 10.2.6 handles this by fresh-atom substitution + iterated elimination.

So GHR94's answer to the two-U issue is: it's handled by the induction in Lemma 10.2.6, not by the individual elimination cases. The 8 cases only handle SINGLE U-formula instances.

---

## 5. Induction Structure

### 5.1 The Full Proof Hierarchy

The separation proof in GHR94 Chapter 10.2 has the following structure:

```
Theorem 10.2.9 (Separation Theorem)
  |
  v
Lemma 10.2.8 (General case -- junction depth induction)
  |
  v
Lemma 10.2.7 (No S within U -- U-nesting depth induction)
  |
  v
Lemma 10.2.6 (Multiple U formulas -- induction on number n)
  |
  v
Lemma 10.2.5 (Single U formula -- induction on S-nesting depth k)
  |
  v
Lemma 10.2.4 (Single S with top-level U(A,B) -- normal form reduction)
  |
  v
Lemma 10.2.3 (8 elimination cases -- the CORE)
  |
  v
Lemma 10.2.2 (neg_until_equiv, neg_since_equiv)
Lemma 10.2.1 (distribution lemmas)
```

### 5.2 Junction Depth (Lemma 10.2.8)

The main induction measure is **junction depth**, defined as follows (slightly rephrased from GHR94):

Given a formula A and a subformula B appearing in A: the subformula occurrences C_1, ..., C_n are chosen such that B is a subformula of C_1, each C_i is a subformula of C_{i+1}, each C_i is either U or S, and the C_i ALTERNATE between U and S. The junction depth of B in A is the maximum such n.

The junction depth of a formula is the maximum junction depth over all subformula appearances.

**Example** from GHR94: `S(a and U(A, S(C, D)), S(S(C, D), E))`:
- The first C has junction depth 3 (C under S under U under S, alternating S-U-S)
- The second C has junction depth 1 (C under S, and the outer S doesn't alternate)
- The whole formula has junction depth 3

**Induction**: If junction depth is 0 or 1, the formula is already separated. For depth >= 2, the proof:
1. Takes an S(D1, D2) (or U(D1, D2) by duality)
2. Finds maximal U-subformulas U(A_i, B_i) covering all U appearances in S(D1, D2)
3. Finds S-subformulas S(E, F) inside the U(A_i, B_i)
4. Replaces them by fresh atoms z_ij
5. Applies Lemma 10.2.7 to the simplified formula
6. Re-substitutes and uses the induction hypothesis (junction depth has decreased by at least 2)

### 5.3 How the 8 Cases Fit

The 8 cases (Lemma 10.2.3) are used at the BOTTOM of the hierarchy, inside Lemma 10.2.4. When Lemma 10.2.4 reduces `S(C, F)` to normal form using Lemma 10.2.1, each resulting S-formula falls into one of the 8 cases.

The induction hypothesis does NOT directly provide something stronger than our assumption. Rather, the hierarchy builds up from the 8 cases through increasingly general situations, with each level using the level below it.

### 5.4 Our Formalization's Approach

Our SeparationThm.lean collapses the entire hierarchy:
- `all_separable` is proved by structural induction on the formula
- The temporal cases (`all_past`, `all_future`, `untl`, `snce`) use four axioms (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`)
- These axioms encapsulate Lemmas 10.2.4-10.2.8

This approach works but pushes all the complexity into the axioms. To eliminate the axioms, we would need to implement the full hierarchy.

---

## 6. Comparison with Our Formalization

### 6.1 Specific Mismatches

| Aspect | GHR94 | Our Lean Code | Impact |
|--------|-------|---------------|--------|
| Temporal primitives | S, U only | S, U, all_past, all_future | Purity definitions differ |
| G/H status | Derived from U/S | Primitive constructors | is_U_free/is_S_free wrong |
| "U-free" meaning | No U at all (includes no G) | No untl constructor (allows all_future) | is_U_free too permissive |
| "S-free" meaning | No S at all (includes no H) | No snce constructor (allows all_past) | is_S_free too permissive |
| Separation predicate | Boolean combo of atoms, U(E,F) S-free, S(E,F) U-free | Same but all_past/all_future treated as units | More permissive |
| Case 5 | Explicit formula (incorrect on Z) | Axiom | Sound but not proved |
| Cases 6-8 | Reduced to earlier cases | Axioms | Could be proved |
| Temporal closure | Follows from 8 cases + induction | 4 axioms | Could be proved |

### 6.2 The all_future Purity Problem

Our `is_U_free` predicate passes through `all_future`:
```lean
| .all_future phi => is_U_free phi
```

This means `is_U_free (all_future (neg A))` = `is_U_free (neg A)` = `true` (when A is an atom).

But in GHR94, `G(neg A) = neg U(neg (neg A), top)` contains U, so it is NOT U-free.

Consequence: our `is_syntactically_separated` accepts formulas like `snce (all_future (neg A)) q` (because `is_U_free (all_future (neg A)) = true`). But in GHR94, `S(G(neg A), q)` is NOT separated because G(neg A) contains U.

This means our elimination cases prove something WEAKER than what GHR94 proves. When Case 2's proof says "is_syntactically_separated psi_l" with `psi_l = S(a and G(neg A), q)`, it relies on `is_U_free (all_future (neg A)) = true`, which GHR94 would not accept.

However, the semantic content is correct: `S(a and G(neg A), q)` IS pure past (H depends only on past and present, and G(neg A) depends only on the future, but inside S it becomes past-dependent). The mismatch is between our syntactic criterion and GHR94's.

### 6.3 Axiom Count

Currently we have:
- 4 elimination case axioms: `elim_case_5_axiom`, `elim_case_6_axiom`, `elim_case_7_axiom`, `elim_case_8_axiom`
- 4 temporal closure axioms: `all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`
- Total: **8 axioms**

---

## 7. Recommendations

### 7.1 Fix is_U_free and is_S_free (HIGH PRIORITY)

Change the definitions to:
```lean
def is_U_free : Formula -> Bool
  | .all_future _ => false  -- G is derived from U in GHR94
  | .untl _ _ => false
  -- rest unchanged

def is_S_free : Formula -> Bool
  | .all_past _ => false  -- H is derived from S in GHR94
  | .snce _ _ => false
  -- rest unchanged
```

**Impact**: This will break some existing proofs (particularly the `is_syntactically_separated` checks in Cases 1-4 where `all_future` appears in results). But these need to be fixed anyway -- the results need to be expressed differently.

Specifically, in Case 2, the sub-formula `S(a and G(neg A), q)` would need to be replaced by `S(a and neg U(neg (neg A), top), q)` = `S(a and neg F(neg A), q)` which expands to `S(a and neg (neg A).all_future.neg, q)`. Actually, we should express G as a derived operator: `all_future phi = neg (untl (neg phi) bot).neg ... `. This gets complex.

**Alternative**: Instead of changing `is_U_free`, add a separate predicate `is_GHR_U_free` that correctly reflects GHR94's definition, and use it in the separation proof. Keep the existing `is_U_free` for other purposes where the current semantics is appropriate.

### 7.2 Implement Case 5 via Case 3 Reduction (HIGH PRIORITY)

Following the Dedekind complete proof strategy:

1. State and prove that Case 3's formula is correct for arbitrary `a` (not just atoms). This is already true of our Case 3 proof -- the theorem requires `is_U_free a = true` and `is_S_free a = true`, but these are just the separation conditions, not atomicity.

2. For Case 5, apply Case 3 with `a' = a and U(A,B)`. Since `a' = Formula.and a (untl A B)`, we have `is_U_free a' = false` and `is_S_free a' = true`. Case 3 requires `is_U_free a = true`, so we CANNOT directly apply our `elim_case_3`.

3. **The fix**: State and prove a GENERALIZED Case 3 that allows the `a` parameter to contain U, as long as U only appears as the specific U(A,B) being eliminated. The semantic proof is the same; only the syntactic preconditions change.

4. After applying generalized Case 3, the result has U(A,B) in positions derived from `not a' = not(a and U(A,B))`. Apply `neg_until_equiv` to expand `not U(A,B)`, distribute, and apply Cases 1-4 to each resulting single-U disjunct.

**Estimated effort**: 400-600 LOC for the generalized Case 3 + Case 5 reduction.

### 7.3 Prove Cases 6-8 via Iterated Elimination (MEDIUM PRIORITY)

As detailed in report 04 and confirmed here:
- Case 6: `neg_until_equiv` + Case 3 + iterated Case 1 + re-separation via Cases 1-5
- Case 7: Explicit formula reduction (from GHR94) to Cases 4 and 8
- Case 8: Negation reduction (from GHR94 explicitly) to Cases 3 and 5

**Estimated effort**: 600-800 LOC total for Cases 6-8.

### 7.4 Prove Temporal Closure Axioms (LOWER PRIORITY)

The four temporal closure axioms (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`) can be proved by implementing the Lemma 10.2.4-10.2.8 hierarchy.

However, this depends on how `all_future` and `all_past` are handled:
- If we fix `is_U_free` (Recommendation 7.1), then `all_future phi` inside `snce` is NOT U-free, and the separation proof must explicitly handle the G-under-S case by expanding G into U.
- The temporal closure for `all_past phi` would prove: if phi is separable (= has a separated equivalent), then `all_past phi` is separable. The proof: take the separated equivalent psi, then `all_past psi` has `all_past` applied to a separated formula. If psi is U-free (a pure-past part of separation), then `all_past (pure_past)` is still pure past. If psi contains U-subformulas (pure-future parts), then `all_past (pure_future)` creates a new U-S junction, handled by the elimination cases.

**Estimated effort**: 800-1200 LOC for the full hierarchy.

### 7.5 Recommended Execution Order

1. **Fix is_U_free / is_S_free** (or add GHR-compatible variants) -- unblocks everything
2. **Implement generalized Case 3** -- enables Case 5 reduction
3. **Prove Case 5 via Case 3 reduction** -- eliminates `elim_case_5_axiom`
4. **Prove Case 8 via GHR94's negation reduction** -- uses Case 5
5. **Prove Case 7 via GHR94's explicit reduction** -- uses Cases 4 and 8
6. **Prove Case 6 via neg_until_equiv + iterated elimination** -- uses Cases 1, 3, 5
7. **Prove temporal closure** -- uses the full 8-case machinery

This eliminates all 8 axioms in a well-ordered sequence.

### 7.6 A Word of Caution on the is_U_free Fix

Changing `is_U_free` to reject `all_future` has cascading effects. Every proof that currently establishes `is_U_free phi = true` or `is_syntactically_separated phi = true` must be re-examined. The elimination case results (the `psi` formulas) may need to be restructured to avoid `all_future` in U-free contexts.

An alternative that avoids this cascade: **encode G as a derived operator in the elimination case results.** Instead of producing `all_future (neg A)` as a subformula, produce `(neg A).neg.untl bot |>.neg` (which is `neg U(neg(neg A), bot)` = `neg F(neg A)` = `G(A)` semantically, but uses only `untl` and boolean connectives syntactically). This would satisfy the stricter `is_U_free` check because the `untl` would appear at top level (inside an S), and the S-arguments would be genuinely U-free.

However, this approach makes the formula expressions much more complex. The recommended path is to carefully evaluate whether the semantic approach (keeping `all_future` as a "unit" that counts as pure-future) is adequate for the overall proof, and only change to the strict GHR94 definitions if the semantic approach creates genuine problems.

---

## References

- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1*. Clarendon Press, Oxford. Chapters 9-10.
- Reynolds, M. (1994). "Axiomatising first-order temporal logic: Until and since over linear time." *Studia Logica* 57, pp. 118-138.
- Kamp, H.W. (1968). *Tense logic and the theory of linear order*. PhD thesis, University of California, Los Angeles.
