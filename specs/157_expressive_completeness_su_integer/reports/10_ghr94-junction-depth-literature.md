# GHR94 Junction-Depth Induction: Literature Analysis

## Executive Summary

GHR94's Lemma 10.2.8 resolves the mutual dependency between U-elimination and S-elimination via **junction depth** -- a measure counting the maximum number of alternating U/S layers on any root-to-leaf path. The induction decreases junction depth by at least 2 at each step (extracting S-subformulas from inside U, applying the lower hierarchy, then resubstituting). The key architectural insight is that GHR94 treats G/H as DERIVED from U/S (not primitive), which means "U-free" genuinely means "contains no future temporal content at all." Our formalization's primitive `all_future`/`all_past` constructors create a genuine additional complication, but one that can be resolved by treating `all_future`/`all_past` as transparent for junction-depth counting (which the current code already does).

---

## 1. Exact GHR94 Junction-Depth Definition

### 1.1 The Formal Definition (Lemma 10.2.8, p. 189 of ch10.md)

Given a formula A and a subformula occurrence B within A, the **junction depth** of B in A is defined as:

> If C_1, ..., C_n are subformulas of A such that:
> 1. B is a subformula of C_1
> 2. Each C_i is a subformula of C_{i+1}
> 3. Each C_i is either an Until (U(D,E)) or a Since (S(D,E))
> 4. The C_i's **alternate** between Until's and Since's
>
> Then the junction depth of B in A is at least n.

The **junction depth of a formula** is the maximum junction depth over all subformula occurrences.

### 1.2 Key Properties of the Measure

- Junction depth 0: The formula has no U-S alternation at all. Either it is purely boolean/atomic, or all temporal operators nest homogeneously (only S-under-S or only U-under-U).
- Junction depth 1: There is at most one "layer" of temporal nesting. E.g., `U(S(p,q), r)` has junction depth 1 (the S is under a U, but there's no further alternation below the S).
- Junction depth >= 2: There are at least two alternations, e.g., `S(a, U(A, S(C,D)))` has junction depth >= 2 because C is under S-under-U-under-S.

### 1.3 What GHR94 Ignores in the Count

GHR94 counts ONLY U and S as "junctions." Classical connectives (negation, conjunction, disjunction, implication) and -- crucially -- G, H, F, P are all transparent to junction depth because in GHR94's language, G/H/F/P are just abbreviations for expressions built from U/S and boolean connectives.

For example, `G(neg A) = neg U(neg(neg A), top)` -- this is a U-formula. So in GHR94, `S(a, G(neg A))` has the same junction depth as `S(a, neg U(A, top))`, which has junction depth 1 (U under S).

### 1.4 The Example from GHR94

GHR94 gives this example:
```
S(a ^ U(A, S(C, D)), S(S(C, D), E))
```

- First occurrence of C: junction depth 3 (C is under S, which is under U, which is under S -- alternating S-U-S gives 3)
- Second occurrence of C: junction depth 1 (C is under S(S(C,D),E), but the two nested S's don't alternate -- they're both S. The first alternation is S under the outer S, but same-type nesting doesn't count. Actually re-reading: S(C,D) is under S(S(C,D),E) which is under the outer S. The outer S contains the inner S(S(C,D),E), which doesn't alternate. The inner S(C,D) is inside an S-argument -- same type, so no alternation. Junction depth of the second C is 1 (just the nesting of S(C,D) under the top-level S).)
- Formula junction depth: 3

---

## 2. How GHR94 Handles the Base Cases

### 2.1 Junction Depth 0 or 1: Already Separated

GHR94 states (Lemma 10.2.8 proof):

> "If it is zero or one then D is already syntactically separated."

**Junction depth 0** means: no U appears under any S, and no S appears under any U. The formula is a boolean combination of atoms, U-formulas (with only boolean and U inside), and S-formulas (with only boolean and S inside). This is exactly the definition of syntactic separation.

**Junction depth 1** means: U may appear under S (or vice versa), but NOT both directions. E.g., `S(D1, D2)` where D1, D2 may contain U-subformulas, but those U-subformulas contain no S. This is still syntactically separated: each U(E,F) has S-free E,F, and each S(E,F) has U-free E,F.

**No special integer-specific equivalences are needed for the base cases.** Junction depth 0 or 1 is already separated by the syntactic definition alone.

### 2.2 Why This Base Case Works

The insight is that "syntactically separated" in GHR94 means:
- Boolean combination of atoms, U(E,F) with S-free E,F, and S(E,F) with U-free E,F

And junction depth <= 1 means:
- Any U-subformula that is inside an S has no S inside it (depth 1, not 2)
- Any S-subformula that is inside a U has no U inside it (depth 1, not 2)

These are the same condition! So junction depth <= 1 is equivalent to syntactic separation.

---

## 3. How GHR94 Handles the Inductive Step

### 3.1 The Inductive Step (Junction Depth >= 2)

Given a formula D of junction depth >= 2, D is a boolean combination of atoms, U(D1,D2), and S(D1,D2). By duality, it suffices to handle S(D1,D2).

**Step 1: Identify maximal U-subformulas.** Let U(A_i, B_i) cover all maximal appearances of U in S(D1, D2). "Maximal" means no U(A_i, B_i) is contained in another U(A_j, B_j).

**Step 2: Find S-subformulas inside the U's.** Since junction depth >= 2, some U(A_i, B_i) contain S-subformulas S(E, F).

**Step 3: Replace S-subformulas by fresh atoms.** Replace each maximal S(E_ij, F_ij) inside U(A_i, B_i) by a new atom z_ij, obtaining U(A'_i, B'_i).

**Step 4: Apply Lemma 10.2.7 (no S within U).** Change S(D1, D2) into D' by replacing each U(A_i, B_i) by U(A'_i, B'_i). Now D' has no S nested within any U. Apply Lemma 10.2.7 to separate D' into E'.

**Step 5: Resubstitute.** Replace each z_ij back with S(E_ij, F_ij). The result E is equivalent to the original S(D1, D2).

**Step 6: Apply induction hypothesis.** After resubstitution:
- What were "pure past" parts in E' may now contain S(E_ij, F_ij), making them impure.
- But each S(E_ij, F_ij) has junction depth at most d-2 (it was inside a U that was inside an S -- removing two alternation layers).
- The induction hypothesis (junction depth < d) applies to separate each impure part.

### 3.2 Why Junction Depth Decreases by at Least 2

This is the critical well-foundedness argument:

The S-subformulas S(E_ij, F_ij) were originally nested as:
```
S(D1, D2) > U(A_i, B_i) > S(E_ij, F_ij)
```

That's three layers of alternation (S-U-S). The inner S(E_ij, F_ij) has junction depth that is at most d-2 relative to the outer formula's junction depth d, because:
- The outer S contributes +1 to the alternation count
- The U(A_i, B_i) between them contributes +1
- Together they add 2 to whatever junction depth S(E_ij, F_ij) has internally

So `junction_depth(S(E_ij, F_ij)) <= d - 2`.

After substitution into E', the atom z_ij (which had depth 0) is replaced by S(E_ij, F_ij) (depth <= d-2). In the worst case, z_ij appeared inside a U-context in E', giving a new junction depth of at most (d-2)+1 = d-1 for U-terms and d-2 for S-terms. The text confirms the details:

> "Those of the form S(C1, C2) now have junction depth at most d-2 while those of the form U(C1, C2) have depth less than or equal to d-1."

So the induction hypothesis applies in all cases.

### 3.3 How Lemmas 10.2.5-10.2.7 Fit Inside the Induction

The hierarchy is:

```
Lemma 10.2.8 (junction depth induction)
  calls -> Lemma 10.2.7 (no S within U -- applied to D' after atom replacement)
    calls -> Lemma 10.2.6 (multi-U by count induction)
      calls -> Lemma 10.2.5 (single-U by S-nesting induction)
        calls -> Lemma 10.2.4 (normal form + 8 cases)
          calls -> Lemma 10.2.3 (the 8 elimination cases)
```

Lemma 10.2.8 only directly calls 10.2.7 and the IH. The lower lemmas handle the details of pulling U out from under S when no S is nested inside U (the simplified case after atom-replacement in step 3).

### 3.4 How Circularity Is Avoided

The hierarchy avoids circularity through a layered induction:

1. **Within 10.2.7 (no S in U)**: The formula has U-nesting under S, but no S re-entering any U. This means applying the 8 elimination cases can only produce formulas with the same property (no S in U). The U-nesting depth strictly decreases.

2. **Within 10.2.6 (multi-U)**: Multiple U-formula types are handled by replacing all but one with atoms, separating the remaining one via 10.2.5, substituting back. The U-count strictly decreases.

3. **Within 10.2.5 (single U)**: The S-nesting depth above U(A,B) strictly decreases with each case elimination.

4. **Within 10.2.8 (junction depth)**: The junction depth strictly decreases (by at least 2) at each step.

None of these inductions call themselves circularly because each level only calls the level below it, and the induction measures are different at each level.

---

## 4. How G/H Are Treated: GHR94 vs Our Formalization

### 4.1 In GHR94: G and H Are Derived

GHR94 works in "the language with the connectives S and U" (Section 10.2 heading). G and H appear as abbreviations:
- G(phi) = neg F(neg phi) = neg U(neg phi, top)
- H(phi) = neg P(neg phi) = neg S(neg phi, top)

They are not separate constructors. They are syntactic sugar for complex U/S expressions.

Consequences:
- "U-free" means "no U anywhere" which entails "no G and no F"
- "S-free" means "no S anywhere" which entails "no H and no P"
- `G(S(p,q))` in GHR94 is really `neg U(neg S(p,q), top)` -- a U-formula containing an S-subformula
- Junction depth of `G(S(p,q))`: the S is inside a U (the hidden U in the G definition), so depth = 1

### 4.2 In Our Formalization: G and H Are Primitive Constructors

Our `Formula` inductive type has:
```lean
| all_past : Formula -> Formula    -- H(phi)
| all_future : Formula -> Formula  -- G(phi)
| untl : Formula -> Formula -> Formula  -- U(phi, psi)
| snce : Formula -> Formula -> Formula  -- S(phi, psi)
```

`all_future` and `all_past` are separate constructors, NOT derived from `untl`/`snce`.

### 4.3 What `is_U_free` Means in Each Framework

| Property | GHR94 | Our Formalization |
|----------|-------|-------------------|
| `is_U_free(G(phi))` | FALSE (G contains U) | TRUE (`is_U_free` passes through `all_future`) |
| `is_S_free(H(phi))` | FALSE (H contains S) | TRUE (`is_S_free` passes through `all_past`) |
| `is_U_free(all_future phi)` | N/A (no such formula) | TRUE |
| `S(a, G(neg A))` separated? | NO (U under S) | YES (by our `is_syntactically_separated`) |

### 4.4 Impact on Junction Depth

Our `junction_depth` passes transparently through `all_past` and `all_future`:
```lean
| .all_past phi => junction_depth phi
| .all_future phi => junction_depth phi
```

This means `all_future(snce p q)` has the same junction depth as `snce p q` -- the `all_future` wrapper adds no alternation.

In GHR94, `G(S(p,q)) = neg U(neg S(p,q), top)` -- the hidden U DOES count as an alternation layer. So `G(S(p,q))` has junction depth 1 in GHR94 but junction depth 0 in our formalization (since `all_future` is transparent and `snce p q` alone has depth 0).

### 4.5 The `is_properly_separated` Predicate

The codebase already has a second, stricter predicate:
```lean
def is_properly_separated : Formula -> Bool
  | .all_past phi => is_past_only phi
  | .all_future phi => is_future_only phi
  | .untl phi psi => is_future_only phi && is_future_only psi
  | .snce phi psi => is_past_only phi && is_past_only psi
```

Where `is_past_only` rejects both `all_future` and `untl`, and `is_future_only` rejects both `all_past` and `snce`. This correctly captures GHR94's semantic separation requirement.

---

## 5. Does Primitive G/H Create a Genuine Additional Complication?

### 5.1 The Core Question

In GHR94, `G(S(p,q))` = `neg U(neg S(p,q), top)` has junction depth 1 and is NOT syntactically separated (U under S pattern).

In our formalization, `all_future(snce p q)` has junction depth 0 and IS syntactically separated by `is_syntactically_separated`.

**Question**: Does this mean our formalization needs less work (because more things are already "separated") or MORE work (because the weaker notion of separation doesn't imply semantic purity)?

### 5.2 Answer: It Creates a Genuine Complication for Theorem 9.3.1

The `is_syntactically_separated` predicate is TOO WEAK for Theorem 9.3.1 (expressive completeness). The substitution step in 9.3.1 requires that "past parts" evaluate ONLY at past times. But `all_future(phi)` inside an S-argument evaluates phi at future times -- violating the substitution correctness proof.

This is exactly the blocker documented in the Phase 1 handoff: `is_U_free(all_future phi) = true` allows `all_future phi` inside S-arguments, breaking the semantic purity requirement.

### 5.3 But It Does NOT Complicate the Separation Proof Itself

For the SEPARATION PROOF (showing every formula has a separated equivalent), our treatment actually simplifies things:

1. `all_future phi` is already "syntactically separated" in our weak sense (junction depth 0)
2. We never need to "eliminate G from under S" because G is a separate constructor that doesn't count as U

However, if we use the STRONGER `is_properly_separated` predicate (which the code already defines), then:
- `all_future(snce p q)` is NOT properly separated (since `snce p q` is not `future_only`)
- This means we DO need to separate `all_future(snce p q)` further
- The semantically correct separated equivalent is: `neg(untl (snce p q).neg .bot).neg` -- which unwraps G back into U form and creates a genuine junction depth

### 5.4 Two Proof Strategies

**Strategy A: Use `is_syntactically_separated` (weaker) for the separation proof, then bridge to `is_properly_separated` (stronger) for Theorem 9.3.1.**

The bridge lemma would state: every syntactically separated formula is equivalent to a properly separated formula. The proof: for each `all_future phi` in a "past context" (inside snce), expand it to `neg(untl phi.neg top)` and apply the junction-depth elimination machinery.

**Strategy B: Prove separation directly for `is_properly_separated`.** This means the separation proof must handle the `all_future`/`all_past` cases more carefully -- they must be eliminated (expanded into U/S form) whenever they appear in the "wrong" temporal context.

The codebase currently implements Strategy A (separate with the weak predicate, then has axioms for the proper separation theorem).

### 5.5 The Simplest Path

The simplest formalization path is:

1. **Keep the existing `is_syntactically_separated`** and prove `all_separable` (every formula has a weakly-separated equivalent). This is what the code already does, modulo the 4 temporal closure axioms.

2. **Prove a bridge lemma**: `is_syntactically_separated phi = true -> is_properly_separable phi`. This lemma would show that every weakly-separated formula can be further rewritten to a properly-separated one, by expanding `all_future`/`all_past` when they appear in wrong-polarity contexts.

3. **Derive `all_properly_separable`** from `all_separable` + bridge lemma.

The bridge lemma is straightforward because in a weakly-separated formula:
- `all_past phi` with `is_U_free phi = true`: if phi contains `all_future`, expand each `all_future psi` to `neg(untl psi.neg top)`, creating a new U-under-S junction. But the junction depth is bounded (each expansion adds exactly 1 layer). Apply the elimination machinery to the resulting formula.
- `all_future phi` with `is_S_free phi = true`: dual.

This bridge can actually be proved using `all_separable` itself (since the expanded formula is just another formula that has a separated equivalent).

---

## 6. Concrete Recommendation

### 6.1 For the Junction-Depth Induction (Eliminating Temporal Closure Axioms)

The current 4 temporal closure axioms assert:
```lean
axiom all_past_separable (phi) (h : is_separable phi) : is_separable (.all_past phi)
axiom all_future_separable (phi) (h : is_separable phi) : is_separable (.all_future phi)
axiom untl_separable (phi psi) (h1 h2) : is_separable (.untl phi psi)
axiom snce_separable (phi psi) (h1 h2) : is_separable (.snce phi psi)
```

To prove these as theorems, implement GHR94's hierarchy:

**Lemma 10.2.7 (no S within U)**: If D has no `snce` nested within any `untl`, then D is separable. Proof by induction on U-depth-under-S (already defined as `U_depth_under_S` in Defs.lean).

**Lemma 10.2.8 (junction depth)**: Given D of junction depth d:
- d <= 1: D is already separated (trivial check)
- d >= 2: Extract maximal `untl` subterms, find `snce` subformulas inside them, replace with fresh atoms, apply Lemma 10.2.7, resubstitute, apply IH (junction depth decreased by >= 2)

**For `untl_separable`/`snce_separable`**: Direct application of junction-depth induction. The formula `.untl phi psi` (or `.snce phi psi`) has some junction depth d. Apply Lemma 10.2.8.

**For `all_past_separable`/`all_future_separable`**: Since `all_past`/`all_future` are transparent to junction depth, `all_past phi` has the same junction depth as phi. But we need to show the RESULT is separated.

The argument: if phi has a separated equivalent phi', then `all_past phi'` is equivalent to `all_past phi`. Now check if `all_past phi'` is itself separated:
- If `is_U_free phi' = true`: then `all_past phi'` satisfies `is_syntactically_separated` directly.
- If phi' contains `untl`: then `all_past phi'` is NOT separated (U under past context). But `all_past(untl A B)` has junction depth = junction depth of `untl A B` (transparent wrapper). We can treat `all_past phi'` as a formula to be separated. Its junction depth is the same as phi', which was the separated equivalent, hence has at most the junction depth of the original phi.

Actually, the cleanest proof: since `all_past phi` is just a formula with the SAME junction depth as phi, apply `junction_depth_separable` directly. The `all_past` wrapper doesn't add junction depth, so the induction on junction depth handles it automatically.

**Key realization**: If we prove `junction_depth_separable` by strong induction on junction depth (using Lemmas 10.2.7 and 10.2.8's argument), then ALL four temporal closure axioms become trivial corollaries -- they're just special cases of "every formula is separable."

### 6.2 The Minimal Approach to Eliminate All Axioms

The minimal proof structure that eliminates all axioms:

```
theorem junction_depth_separable (D : Formula) : is_separable D := by
  -- Strong induction on junction_depth D
  -- Base: junction_depth D <= 1 -> already separated
  -- Step: junction_depth D >= 2 ->
  --   D is bool combo of atoms, untl(D1,D2), snce(D1,D2), all_past(D1), all_future(D1)
  --   For each snce(D1,D2): apply the fresh-atom extraction + 10.2.7 + IH argument
  --   For each untl(D1,D2): dual
  --   For each all_past(D1): treat as transparent (same junction depth as D1)
  --   For each all_future(D1): treat as transparent
  --   For bool/atom: already separated
```

This replaces ALL 8 axioms (4 temporal closure + 4 elimination case axioms, if those are still present) with a single well-founded induction.

### 6.3 LOC Estimate

- Lemma 10.2.7 implementation: ~300-400 LOC (induction on U-depth, calls existing Cases 1-4 + fresh-atom machinery)
- Lemma 10.2.8 / junction_depth_separable: ~400-600 LOC (junction depth induction, fresh-atom extraction, resubstitution, IH application)
- Total: ~700-1000 LOC to eliminate all temporal closure axioms

---

## 7. Summary of Answers to Research Questions

| Question | Answer |
|----------|--------|
| 1. What is GHR94's junction depth? | Max alternation count of U-S nesting on any root-to-leaf path. Only U and S count as layers; boolean connectives and G/H are transparent. |
| 2. How are base cases handled? | Junction depth 0 or 1 = already syntactically separated. No special integer equivalences needed. |
| 3. How is the inductive step handled? | Extract S-subformulas from inside U's (via fresh atoms), apply Lemma 10.2.7 to the simplified formula, resubstitute, apply IH (depth decreased by >= 2). |
| 4. How is circularity avoided? | Layered induction: each level (10.2.5, 10.2.6, 10.2.7, 10.2.8) calls only LOWER levels. Well-foundedness measures differ at each layer (S-nesting, U-count, U-depth, junction-depth). |
| 5. Does GHR94 treat G/H as primitive or derived? | **DERIVED**. G = neg U(neg phi, top), H = neg S(neg phi, top). "U-free" means "no G either." |
| 6. Does our primitive G/H create a genuine complication? | **YES for Theorem 9.3.1** (semantic purity), **NO for the separation proof itself** (junction depth handles it automatically since all_future/all_past are transparent). The bridge between weak and strong separation is the remaining challenge. |

---

## References

- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1*. Chapter 10, Section 10.2, Lemmas 10.2.1-10.2.9.
- Prior research reports: 05 (GHR94 deep analysis), 08 (hierarchy-first strategy)
- Lean source: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (junction_depth definition)
- Lean source: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (current axioms)
