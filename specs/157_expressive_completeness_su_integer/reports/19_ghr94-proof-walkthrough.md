# GHR94 Chapter 10.2: Line-by-Line Proof Walkthrough

## Purpose

This document is the authoritative reference for the GHR94 separation proof structure (integer case, Section 10.2). It records EXACTLY what GHR94 says -- no interpretation, no shortcuts, no reference to "what the code does instead." Every statement, hypothesis, induction measure, and case split is documented from the primary source.

**Source**: Gabbay, Hodkinson, Reynolds. *Temporal Logic: Mathematical Foundations and Computational Aspects, Vol. 1* (1994), Chapter 10, Section 10.2 (pp. 569-581 in our markdown transcript).

---

## 1. Definitions

### 1.1 Syntactically Separated (Definition from p. 122 of ch10.md)

GHR94 does not give a formal definition with a `Definition` label in Section 10.2. Instead, the definition emerges from the running text after Lemma 10.2.3 (line 122 of the markdown):

> "Given a wff A, this process will eventually leave us with a syntactically separated wff, i.e. a wff B which is a boolean combination of atoms, wffs U(E, F) with E and F built without using S and wffs S(E, F) with E and F built without using U. Clearly, such a B is separated."

**Precise definition**: A wff is *syntactically separated* iff it is a boolean combination of:
- atoms,
- wffs of the form U(E, F) where E and F contain neither S nor U (wait -- re-read: "built without using S"),
- wffs of the form S(E, F) where E and F are "built without using U."

**Key subtlety**: The text says U(E, F) with "E and F built without using S" -- NOT "without S or U". So U(E, F) where E, F are S-free (but may contain U) counts as a "pure future" constituent. Similarly S(E, F) where E, F are U-free (but may contain S) counts as "pure past." This is consistent with the fact that U(p, U(q, r)) should be pure future.

**Confirmation from Ch 9 Definition 9.2.3**: A formula is *separable* if it is equivalent to "a boolean combination of pure past, pure future, and atomic wffs." GHR94 10.2 says "syntactic separation implies separation" because:
- atoms are pure present,
- U(E, F) with S-free E, F is pure future (its truth at t depends only on the future),
- S(E, F) with U-free E, F is pure past (its truth at t depends only on the past).

### 1.2 Junction Depth (Lemma 10.2.8, lines 189-199)

GHR94 gives an explicit recursive definition:

> "Suppose that B is a subformula of wff A in the language with U and S. We can define the *junction depth* (>= 0) of an appearance B in A as follows. If C_1, ..., C_n are subformulae of A such that
> - B is a subformula of C_1,
> - each C_i is a subformula of C_{i+1},
> - each C_i is either an Until (of the form U(D, E)) or a Since (of the form S(D, E)), and
> - the C_i's alternate between Until's and Since's
>
> then the junction depth of the appropriate appearance of B in A is at least n."

And: "The junction depth of a wff is the maximum junction depth of any of its appearances of subformulae."

**Worked example from GHR94**: In `S(a AND U(A, S(C, D)), S(S(C, D), E))`:
- The first appearance of C has junction depth 3 (C is inside S(C,D) which is inside U(...) which is inside the outer S(...) -- three alternating temporal operators: S, U, S).
- The second appearance of C has junction depth 1 (C is inside S(C,D) which is inside the second argument of the outer S, but S(C,D) is inside S(S(C,D), E) which is same-type S, so no alternation beyond the first S).
- The junction depth of the whole formula is 3.

**Critical observation**: Junction depth counts the maximum length of an ALTERNATING chain of U's and S's above any subformula occurrence. Same-type nesting (S inside S, or U inside U) does NOT increase junction depth.

### 1.3 "No S nested within a U" (Lemma 10.2.7)

GHR94 uses the phrase: "Suppose that wff D contains no S nested within a U."

This means: there is no subformula occurrence of S(E, F) that appears inside the argument of any U(A, B). Equivalently: for every U(A, B) subformula in D, the arguments A and B are S-free.

Note: S can still appear at top level or within other S-arguments. The restriction is specifically about S appearing beneath U.

### 1.4 "Maximum depth of nesting of Us beneath an S" (Lemma 10.2.7)

GHR94's induction measure for Lemma 10.2.7:

> "By induction on the maximum depth n of nesting of Us beneath an S."

This is the maximum number of nested U layers that can be found inside the arguments of some S. More precisely:
- Start from any S(C, F) node in the formula.
- Look at the U-nodes inside C or F.
- Those U-nodes may have further U-nodes inside their own arguments (since "no S nested in U" means U-arguments are S-free but may contain U).
- The depth counts how deeply U's are nested.

Example: `S(U(p, U(q, r)), s)` has depth 2 (there is a U inside a U inside an S-argument).
Example: `S(U(p, q), U(r, s))` has depth 1 (U's appear in S-arguments but are not nested in each other).

**Crucially**: This is NOT "nesting of Us within U-args" in the sense of U inside U at the top level. It is specifically the depth of U-nesting BENEATH an S -- i.e., inside the arguments of an S-operator.

### 1.5 "Maximum number of nested S's above any U(A,B)" (Lemma 10.2.5)

GHR94's induction measure for Lemma 10.2.5:

> "By induction on the maximum number k of nested Ss above any U(A,B)."

Given that the formula has single U-type U(A,B), this counts the maximum number of S-operators in the ancestor chain above any occurrence of U(A,B). That is: how many S-nodes lie on the path from the root of the formula down to an occurrence of U(A,B).

Example: `S(a AND U(A,B), q)` has k = 1.
Example: `S(S(a AND U(A,B), q), r)` has k = 2.
Example: `U(A,B)` or `U(A,B) AND p` has k = 0.

---

## 2. Lemma-by-Lemma Walkthrough

### 2.1 Lemma 10.2.1 (Distribution Laws)

**Statement**: "The following are valid over linear time":
1. `U(A OR B, C) <-> U(A, C) OR U(B, C)`
2. `S(A OR B, C) <-> S(A, C) OR S(B, C)`
3. `U(A, B AND C) <-> U(A, B) AND U(A, C)`
4. `S(A, B AND C) <-> S(A, B) AND S(A, C)`

**Proof**: "Simple." (One word.)

**Structure**: Four equivalences. The first argument distributes over disjunction, the second over conjunction. These hold over ANY linear time (not just integer).

**Role in the proof**: These are used in Lemma 10.2.4 to decompose S(C, F) when C is in DNF and F is in CNF, reducing to the 8 atomic cases of Lemma 10.2.3.

**Observations**:
- GHR94 lists exactly four equivalences (two for U, two for S).
- There are no "two parts" to the lemma in the sense of distinct sub-lemmas; it is one lemma with four items.

### 2.2 Lemma 10.2.2 (Negation of Until/Since over Integer Time)

**Statement**: "The following hold over integer time":
1. `NOT U(A, B) <-> G(NOT A) OR U(NOT A AND NOT B, NOT A)`
2. `NOT S(A, B) <-> H(NOT A) OR S(NOT A AND NOT B, NOT A)`
3. `NOT U(A, B) <-> G(NOT A) OR U(NOT A AND NOT B, B AND NOT A)`
4. `NOT S(A, B) <-> H(NOT A) OR S(NOT A AND NOT B, B AND NOT A)`

**Proof**: "Simple."

**Observations**:
- There are FOUR equivalences, not two.
- Items 1-2 are one form; items 3-4 are a variant form.
- These hold specifically over INTEGER time (and discrete Dedekind complete time more generally). They do NOT hold over dense time (where the Dedekind-complete version uses K+, K-, Gamma connectives instead).
- These are used in Lemma 10.2.3 Case 2 (and elsewhere) to rewrite negations of U under S.

### 2.3 Lemma 10.2.3 (The 8 Elimination Cases)

**Statement**: "Let a, q, A, and B be atoms. Consider the following wffs:"

1. `S(a AND U(A, B), q)`
2. `S(a AND NOT U(A, B), q)`
3. `S(a, q OR U(A, B))`
4. `S(a, q OR NOT U(A, B))`
5. `S(a AND U(A, B), q OR U(A, B))`
6. `S(a AND NOT U(A, B), q OR U(A, B))`
7. `S(a AND U(A, B), q OR NOT U(A, B))`
8. `S(a AND NOT U(A, B), q OR NOT U(A, B))`

"Each of the wffs above is equivalent, over integer time, to another wff in which the only appearances of the until connective are as the wff U(A, B) and no appearance of that wff is in the scope of an S."

**Hypotheses on a, q, A, B**: ALL FOUR are ATOMS. GHR94 explicitly says "Let a, q, A, and B be atoms."

This is critical: a, q are atoms, AND A, B are atoms. This is NOT stating a general result for arbitrary A, B. The generalization to arbitrary A, B (with A, B being S-free and U-free) comes later in Lemma 10.2.4 where the reduction to atomic cases is done via DNF/CNF + distribution.

**Proof details for each case**:

**Case 1**: `S(a AND U(A, B), q)` is equivalent to:
```
   S(a, q) AND S(a, B) AND B AND U(A, B)
   OR [A AND S(a, B) AND S(a, q)]
   OR S(A AND q AND S(a, B) AND S(a, q), q)
```
Proof: "the original wff holds at t iff there is s < t and u > s such that a holds at s, A at u, B everywhere between s and u, and q everywhere between s and t. The three disjuncts correspond to the cases u > t, u = t, and u < t respectively."

**Case 2**: `S(a AND NOT U(A, B), q)` uses Lemmas 10.2.1 and 10.2.2. First note `S(a AND G(NOT A), q) <-> S(a, NOT A AND q) AND (NOT A) AND G(NOT A)`, then use elimination 1 and Lemma 10.2.2 in reverse. Result:
```
   [S(a, q AND NOT A) AND NOT A AND NOT U(A, B)]
   OR [NOT A AND NOT B AND S(a, NOT A AND q)]
   OR S(NOT A AND NOT B AND q AND S(a, NOT A AND q), q)
```

**Case 3**: `S(a, q OR U(A, B))` -- look at its negation, use Lemma 10.2.2 then elimination (2):
```
   S(a, q OR U(A, B))
   <-> NOT( H(NOT a)
   OR [S(NOT a AND NOT q, NOT a AND NOT A) AND NOT A AND (NOT U(A, B) OR NOT B)]
   OR S(NOT A AND NOT B AND NOT a AND S(NOT a AND NOT q, NOT A AND NOT a), NOT a) )
```

**Case 4**: `S(a, q OR NOT U(A, B))` -- "very straightforward to do semantically":
```
   S(a, NOT a AND [S(NOT q AND NOT a, NOT a AND B) => NOT A])
   AND (S(NOT q AND NOT a, NOT a AND B) => NOT [A OR (B AND U(A, B))])
```

**Case 5**: `S(a AND U(A, B), q OR U(A, B))`:
```
   S(a, B) AND [A OR (B AND U(A, B))]
   OR S(A AND S(a, B), A OR B OR NOT S(NOT q, NOT A))
      AND [A OR (B AND U(A, B))] AND NOT S(NOT q, NOT A)
```
"The first disjunct holds when the A from U(A, B) is true in the future or present and the second when it is true in the past."

**Case 6**: `S(a AND NOT U(A, B), q OR U(A, B))` -- consider when the first occurrence of NOT B after s is:
```
   [S(a, q AND NOT A) AND NOT A AND NOT (B AND U(A, B))]
   OR S(NOT B AND NOT A AND (q OR U(A, B)) AND S(a, q AND NOT A), q OR U(A, B))
```
Then "eliminations (3) and (5) can be used to finish the separating."

**Case 7**: `S(a AND U(A, B), q OR NOT U(A, B))` -- by considering when A is true:
```
   [S(A AND (q OR NOT U(A, B)) AND S(a, B AND q), q OR NOT U(A, B))]
   OR [S(a, B AND q) AND A]
   OR [S(a, B AND q) AND B AND U(A, B)]
```
"The first disjunct can be further eliminated by eliminations (8) and (4)."

**Case 8**: `S(a AND NOT U(A, B), q OR NOT U(A, B))` -- reduced to previous cases:
```
   NOT S(a AND z, q OR y) <-> H(NOT a OR NOT z)
      OR S(NOT q AND NOT y AND NOT a, NOT a OR NOT z)
      OR S(NOT q AND NOT y AND NOT z, NOT a OR NOT z)
```
Substituting y = z = NOT U(A, B) gives NOT D in terms of cases with positive U(A, B), "especially elimination (5)."

**Critical observation about dual results**: GHR94 states at line 35: "It should be noted that all the results in the rest of this section have dual results in which U and S exchange roles." This means there are implicitly 8 dual cases for U beneath S as well.

### 2.4 Lemma 10.2.4 (S(C, F) with Single U-Type at Top Level)

**Exact statement** (lines 124-126):

> "Suppose that A and B are wffs in which U and S do not appear and that both wffs C and F are such that each (if any) appearance of U in either of them is as U(A, B) and is not nested under any Ss."
>
> "Then S(C, F) is equivalent to a syntactically separated wff in which U only appears as the formula U(A, B)."

**Hypotheses -- EXACT**:
1. **A, B are "wffs in which U and S do not appear"** -- both U-free AND S-free. They are plain boolean combinations of atoms.
2. **C, F**: each appearance of U in C or F is as U(A, B), and no such appearance is nested under any S.
3. **Note**: C and F themselves may contain S -- just not S that has U(A,B) underneath it.

**Key point**: A, B are "without S or U" -- NOT just "without U." GHR94 is explicit: "U and S do not appear."

**Proof structure** (lines 128-139):

1. "If U(A,B) does not appear then we are done."
2. "Otherwise, by rearrangement of C and F into disjunctive and conjunctive normal form, respectively..."
   - C goes into DNF (disjunctive normal form)
   - F goes into CNF (conjunctive normal form)
3. "...and repeated use of lemma 10.2.1 we can rewrite S(C, F) equivalently as a boolean combination of wffs S(C_1, C_2) with no U appearing and wffs of the form either:
   - `S(C_1, C_2 OR +/-U(A, B))`, or
   - `S(C_1 AND +/-U(A, B), C_2 OR +/-U(A, B))`
   for some boolean combinations C_1 and C_2 of atoms and pure past formulae."
4. "Now the preceding lemma [10.2.3] shows that each such boolean constituent is equivalent to a boolean combination of formulae of the following three forms:
   - S(X, Y) where X and Y are built from C_1, C_2, A, and B just using S and not U,
   - C_1, C_2, A, and B, and
   - U(A, B)."
5. "Thus we have a separated equivalent."

**Observations**:
- The proof does NOT mention `replace_untl` or any substitution technique. It works by decomposing C and F into normal forms and distributing.
- After distribution by Lemma 10.2.1, the wffs that remain have the form of one of the 8 cases from Lemma 10.2.3, but with C_1 and C_2 being "boolean combinations of atoms and pure past formulae" rather than just atoms.
- GHR94 says "the preceding lemma shows..." -- it treats the result of Lemma 10.2.3 as applicable even though 10.2.3 was stated for ATOMS a, q, A, B. The idea is that once U(A,B) is isolated as a conjunct/disjunct (with the rest being U-free), the same semantic arguments apply.

### 2.5 Lemma 10.2.5 (Single U-Type Separation -- S-nesting induction)

**Exact statement** (lines 145-148):

> "Suppose that A and B are wffs built without S or U and that the only appearance of U in the wff D is as U(A, B)."
>
> "Then D is equivalent to a syntactically separated wff in which U only appears as the formula U(A, B)."

**Hypotheses -- EXACT**:
1. **A, B are "wffs built without S or U"** -- both S-free and U-free.
2. **D**: "the only appearance of U in the wff D is as U(A,B)" -- every untl node in D has arguments exactly (A, B).
3. D may contain S nodes (with U(A,B) possibly nested under them).

**Induction measure** (line 149):

> "By induction on the maximum number k of nested Ss above any U(A,B)."

This is what we might call `snce_depth_of_U` or `S_nesting_above_U` in the Lean code. It counts, for each occurrence of U(A,B) in D, how many S-operators are in the path from the root to that occurrence, and takes the maximum over all occurrences.

**Case k = 0** (line 152): "In this case D is already separated."

Reasoning: If no S is above any U(A,B), then U(A,B) appears only at the top level (under boolean connectives). Since A, B are S-free, U(A,B) is itself a pure future formula. And since U(A,B) only appears at top level (not under S), any S that appears in D has no U in its arguments, making it pure past. So D is already a boolean combination of atoms, pure future U(A,B), and pure past S-formulas.

**Case k > 0** (lines 153-155):

> "Apply the preceding lemma [10.2.4] to each of the most deeply nested S(C, F) in which U(A, B) appear and then we have an equivalent wff in which the maximum depth of nesting of U(A, B) is reduced."

**"Most deeply nested"**: This means the INNERMOST S that contains U(A,B) -- the S-node that is closest to the U(A,B) leaf. GHR94 says "most deeply nested S(C, F) in which U(A, B) appear" -- these are the S-nodes at the bottom of the nesting chain, the ones that directly contain U(A,B) without any intermediate S between them and U(A,B).

**Why Lemma 10.2.4 applies**: At such an innermost S(C, F), the U(A,B) occurrences in C and F are NOT nested under any further S (because this is the innermost S). So the hypothesis of 10.2.4 is satisfied.

**Effect**: After applying 10.2.4, U(A,B) is pulled out from beneath these innermost S-nodes. The result may still have U(A,B) under other (outer) S-nodes, but the maximum S-nesting depth above U(A,B) has decreased by at least 1.

**Is this LOCAL or GLOBAL?**: This is a LOCAL REWRITING approach. GHR94 says "Apply the preceding lemma to each of the most deeply nested S(C, F) in which U(A,B) appear" -- this is rewriting at specific positions (the innermost S-nodes containing U(A,B)), not a global transformation.

> "Note also that U still only appears in the form U(A, B). The induction hypothesis then gives us the result."

### 2.6 Lemma 10.2.6 (Multiple U-Types -- Induction on Count)

**Exact statement** (lines 159-161):

> "For each i = 1, ..., n let A_i and B_i be wffs built without S or U. Suppose that the only appearances of U in the wff D are in the form U(A_i, B_i)."
>
> "Then D is syntactically separable."

**Hypotheses -- EXACT**:
1. Each A_i and B_i is built without S or U (S-free AND U-free).
2. Every untl node in D has arguments (A_i, B_i) for some i in {1, ..., n}.

**Induction measure**: "Proceed by induction on n" -- the number of distinct U-types.

**Case n = 1** (line 165): "This is the preceding lemma [10.2.5]."

**Case n > 1** (lines 167-171):

> "First we separate only for U(A_n, B_n). For each i = 1, ..., n-1, we start this by replacing each appearance of U(A_i, B_i) by a new atom q_i to obtain a wff D'."

**Which U-type is abstracted?** The OTHERS (U(A_1,B_1) through U(A_{n-1},B_{n-1})) are replaced by fresh atoms. The LAST one (U(A_n, B_n)) is kept.

**Abstraction mechanism**: Replace each U(A_i, B_i) (for i = 1, ..., n-1) by a new (fresh) atom q_i. This produces D' which has single U-type U(A_n, B_n).

> "The preceding lemma [10.2.5] gives us syntactically separated E' equivalent to D' with U appearing only as U(A_n, B_n)."

**After separating**:

> "E' is separated and so is a boolean combination of atoms, of pure future wffs (i.e. U(A_n, B_n)) and pure past wffs D_j which are built from atoms including q_1, ..., q_{n-1}, those in A_n, and B_n, and others of D. Note that U(A_n, B_n) does not appear in any D_j."

**Back-substitution**:

> "Now substitute U(A_i, B_i) for each q_i (i = 1, ..., n-1) in each D_j and, using the induction hypothesis, separate them. Also substituting U(A_i, B_i) for any other q_i's gives us our result."

**How "pure past parts" are handled**: The pure past parts D_j of E' contain the fresh atoms q_1, ..., q_{n-1}. After substituting U(A_i, B_i) back for q_i, these D_j become formulas with at most n-1 distinct U-types (since U(A_n, B_n) does not appear in D_j). Apply the induction hypothesis.

**Is fresh atom substitution explicit?** YES. GHR94 explicitly says "replacing each appearance of U(A_i, B_i) by a new atom q_i." The use of fresh atoms is completely explicit. The atoms must be truly fresh (not appearing in D).

### 2.7 Lemma 10.2.7 (No S Nested in U => Separable)

**Exact statement** (lines 175-176):

> "Suppose that wff D contains no S nested within a U. Then D is syntactically separable."

**Induction measure** (line 177):

> "By induction on the maximum depth n of nesting of Us beneath an S."

**CRITICAL QUESTION: What exactly does this measure count?**

The measure is: across all S-nodes in D, look at the U-subformulas within their arguments. Since "no S nested in U" means all U-arguments are S-free, the U-arguments can contain further U's. The "depth of nesting of Us beneath an S" counts how deeply U's are nested within the arguments of S-nodes.

More precisely: for any S(C, F) subformula in D, look at the U-depth within C and F. The "U-depth" is the maximum nesting depth of U-within-U chains. The measure n is the maximum of this over all S(C, F) subformulas.

This is NOT "nesting of Us within U-args" in the sense of U inside U at the top level (which would be unrelated to S). It specifically counts U-nesting that is BENEATH (inside the arguments of) an S.

**Case n = 1** (line 179): "This is the case of the preceding lemma [10.2.6]."

When n = 1, U appears under S but there is no U nested inside another U's arguments (while under S). So within each S(C, F), the U-nodes in C, F have only atoms and booleans in their arguments (they are S-free by the "no S in U" hypothesis, and they have no U inside them by n = 1). Thus the U-arguments A_i, B_i in each S-context are both S-free and U-free. Lemma 10.2.6 applies.

**Case n > 1** (lines 181-186):

> "Let U(A_i, B_i) (i = 1, ..., N) be some subformulae of D such that every appearance of U in D is as a subformula of an appearance of one of the U(A_i, B_i)."

These are the OUTERMOST U-subformulas -- the ones that are not contained within any other U-subformula.

> "Each A_i and B_i are built up as a boolean combination from wffs of the form U(X_ij, Y_ij) and atoms."

Since no S is nested in U, the A_i and B_i are S-free. But they may contain U-subformulas U(X_ij, Y_ij) (the "inner" U-subformulas).

> "Replace each U(X_ij, Y_ij) in A_i and B_i by the new atom z_ij to form wffs A'_i and B'_i which are just boolean combinations of atoms. Thus when we substitute z_ij by U(X_ij, Y_ij) in A'_i and B'_i we obtain A_i and B_i respectively."

**Which U-subformulas are abstracted?** The INNER ones -- U(X_ij, Y_ij) that appear inside the arguments of the outer U(A_i, B_i). NOT the outer U(A_i, B_i) themselves.

**Are ALL inner U-subformulas abstracted at once, or one at a time?** GHR94 says "Replace each U(X_ij, Y_ij)" -- this abstracts ALL of them simultaneously, replacing each with its own fresh atom z_ij.

> "Replace each occurrence of U(A_i, B_i) (which is not contained within another U(A_i, B_i)) in D by U(A'_i, B'_i) to obtain D', which can be separated by the preceding lemma [10.2.6]."

After this replacement, D' has U-nodes of the form U(A'_i, B'_i) where A'_i and B'_i are boolean combinations of atoms (and z_ij atoms). These A'_i and B'_i are both S-free AND U-free (since all inner U's were replaced by atoms). So Lemma 10.2.6 applies.

> "Let E' be its separated form. E' will be a boolean combination of atoms (including the z_ij), pure future formulae (like U(A'_i, B'_i)) and pure past formulae (for example A'_i's and B'_i's nested under Ss)."

> "Furthermore, when we substitute in z_ij by U(X_ij, Y_ij) we obtain a wff E equivalent to D."

> "Unfortunately, E is not separated: what were pure past formulae in E' have become, on replacement of z_ij by U(X_ij, Y_ij), impure. To correct this we use the induction hypothesis on each of these pure past subformula of E."

**Why the IH applies**:

> "It is clear that we can do so as the level of nesting of U in U(A_i, B_i) must be strictly greater than that in its subformula U(X_ij, Y_ij)."

The key argument: the pure past parts of E' were S-formulas built with atoms including z_ij. After back-substitution, z_ij becomes U(X_ij, Y_ij). The U-nesting depth of these U(X_ij, Y_ij) is strictly less than n (since X_ij, Y_ij are "inner" to the original A_i, B_i, and so have lower nesting depth). The pure past parts after back-substitution still have "no S nested in U" (since the U(X_ij, Y_ij) formulas were originally S-free). So the IH applies.

**"Pure past parts"**: These are the S(E, F) subformulas and their boolean combinations that formed the pure-past constituent of the separated form E'. After back-substitution of z_ij -> U(X_ij, Y_ij), they acquire U-subformulas inside their S-arguments.

### 2.8 Lemma 10.2.8 (Full Separation / Hierarchy Theorem)

**Exact statement** (lines 189-190):

> "Any wff of the language with U and S is syntactically separable over the integer flow of time."

**Proof structure**:

**Junction depth definition** is given in full (see Section 1.2 above).

**Induction** (lines 208-209):

> "Now we begin the proof, being given a wff D. We proceed by induction on the junction depth of D."

**Case junction depth 0 or 1** (lines 210-211):

> "If it is zero or one then D is already syntactically separated."

Junction depth 0: D has no temporal operators (just atoms and booleans), OR every temporal operator is the same type. Specifically, no alternation.
Junction depth 1: There is one level of alternation -- e.g., U appears inside S but not S inside U inside S.

Wait -- let us re-read carefully. Junction depth 0 means no alternating chain of length >= 1. This means no subformula occurrence has an alternating chain of temporal operators above it. This happens when there is no mixed nesting at all.

Junction depth 1 means the maximum alternating chain has length 1. A chain of length 1 is a single temporal operator -- which means some subformula is inside exactly one temporal operator, with no further alternation. That is trivially the case for any formula.

Actually, re-reading the definition more carefully: "the junction depth of the appropriate appearance of B in A is at least n" where n is the length of the alternating chain C_1, ..., C_n. So junction depth 0 means no subformula is inside any temporal operator at all? No -- the C_i must ALTERNATE between U and S. A formula like S(S(p, q), r) has junction depth 1 because p is inside S(p,q) which is inside S(..., r), but both are S-type so they don't form an alternating chain of length 2. The chain of length 1 counts the outer S.

Hmm, actually the definition counts chains where "the C_i's alternate between Until's and Since's." A chain of length 1 is just a single U or S. So any formula with at least one temporal operator has junction depth >= 1.

Junction depth <= 1 means: there is no alternation. Every temporal operator subformula is either always under same-type operators, or at the top level. Specifically, no U is nested under an S and no S is nested under a U. This means D is already syntactically separated (U-arguments are S-free and S-arguments are U-free).

**Case junction depth >= 2** (lines 211-219):

> "D is a boolean combination of atoms, wffs of the form S(D_1, D_2) and wffs of the form U(D_1, D_2). We are done when we syntactically separate the latter two forms. Because of the dual nature of the results so far we need only demonstrate the syntactic separation of a wff of the form S(D_1, D_2)."

> "Let U(A_i, B_i) (i = 1, ..., N) be the subformulae covering the maximal appearances of U, i.e. every appearance of U in D is as a subformula of an appearance of one of the U(A_i, B_i)."

These are the OUTERMOST U-subformulas within S(D_1, D_2).

> "Since the junction depth of D is at least two, there are some subformulae of some U(A_i, B_i) which are of the form S(E, F)."

These are S-nodes nested inside U-arguments.

> "Replace each maximal such subformula in U(A_i, B_i) by its own new atom z_ij to obtain U(A'_i, B'_i). Change S(D_1, D_2) into E' by replacing each U(A_i, B_i) by U(A'_i, B'_i)."

After this replacement, the U-arguments A'_i, B'_i are S-free (all S-subformulas have been replaced by fresh atoms). So E' = S(D'_1, D'_2) has "no S nested in U."

> "The preceding lemma [10.2.7] now tells us how to separate E' into a wff E'_1."

Lemma 10.2.7 applies because E' has no S nested in U.

> "If we resubstitute the original wffs for each z_ij then we will have a formula equivalent to S(D_1, D_2) but of one less junction depth and we may use the induction hypothesis."

**How does junction depth decrease?** After separating E' and back-substituting:
- The separated form E'_1 is a boolean combination of atoms (including z_ij), pure future parts, and pure past parts.
- The z_ij were S(E_ij, F_ij) -- S-subformulas that were inside U-arguments.
- After back-substitution, z_ij -> S(E_ij, F_ij), the pure past parts now contain S-formulas with S-subformulas inside them.
- BUT the junction depth of S(E_ij, F_ij) was at most d - 2 (two fewer alternations than D), so the back-substituted result has junction depth at most d - 1.
- Actually GHR94 says "one less junction depth" which suggests d - 1, but the text in the Dedekind version (10.3.19) is more precise: "S(Eij, Fij) of junction depth <= d - 2" and after back-substitution the U-forms have depth "<= d - 1."

**Role of the S-abstraction from U-args**: This is the KEY step that enables the reduction. By abstracting S-subformulas from U-arguments, we create a formula with "no S nested in U" that can be handled by Lemma 10.2.7. The junction depth decreases because the S-subformulas that were creating the alternation (S inside U inside S) have been removed and will be re-inserted at a lower level.

---

## 3. Key Observations

### 3.1 The A, B Hypothesis Progression

The hypotheses on A, B change through the lemma sequence:

| Lemma | A, B hypothesis |
|-------|-----------------|
| 10.2.1 | Arbitrary wffs |
| 10.2.2 | Arbitrary wffs |
| 10.2.3 | A, B are ATOMS |
| 10.2.4 | A, B are "wffs in which U and S do not appear" (U-free AND S-free) |
| 10.2.5 | A, B are "wffs built without S or U" (same as 10.2.4) |
| 10.2.6 | Each A_i, B_i "built without S or U" (same) |
| 10.2.7 | No hypothesis on individual A, B; instead: "no S nested within a U" |
| 10.2.8 | No hypothesis; arbitrary wff |

The key strengthening happens at 10.2.7: instead of requiring U-arguments to be explicitly S-free and U-free, it only requires "no S nested in U" and handles U-within-U arguments by the abstraction + back-substitution + IH pattern.

### 3.2 "Atoms" in Lemma 10.2.3 vs. Generalization

Lemma 10.2.3 states a, q, A, B are atoms. But Lemma 10.2.4 applies these results to cases where a, q are "boolean combinations of atoms and pure past formulae" (not just atoms). The justification is implicit: the semantic arguments in 10.2.3 don't truly require a, q to be atoms; they work for any S-free formulas in those positions. The DNF/CNF decomposition + distribution by 10.2.1 reduces to the case where a, q, A, B play the role of atoms.

However, there is an important subtlety: in Lemma 10.2.4's proof, after using 10.2.1 to distribute, the resulting C_1 and C_2 are "boolean combinations of atoms and pure past formulae" -- which may include S-subformulas. The eliminations of 10.2.3 produce S-formulas in the output (e.g., Case 1 produces `S(a, q)`, `S(a, B)`, `S(A AND q AND S(a, B) AND S(a, q), q)`). The claim is that these output S-formulas have U appearing only as U(A,B) at the top level.

### 3.3 Lemma 10.2.7 Abstraction: ALL at Once, Not Iteratively

GHR94 explicitly abstracts ALL inner U-subformulas simultaneously in Lemma 10.2.7:

> "Replace each U(X_ij, Y_ij) in A_i and B_i by the new atom z_ij to form wffs A'_i and B'_i which are just boolean combinations of atoms."

This is a single-step transformation, not an iterated one. All inner U's are replaced by fresh atoms at once.

### 3.4 Lemma 10.2.7: n = 1 IS Lemma 10.2.6

GHR94 says "Case n = 1: This is the case of the preceding lemma." 

When n = 1, the U-nesting depth beneath S is 1. This means inside each S(C, F), U-nodes appear but their arguments have no further U-nodes. Combined with "no S nested in U" (so U-arguments are S-free), this means U-arguments are both S-free and U-free. So Lemma 10.2.6 applies directly.

Note: GHR94 says n = 1 for Lemma 10.2.7 but says n = 0 would mean "no U beneath any S at all" which would be junction depth 0 or 1 (already separated). So the base case is truly n = 1, not n = 0. This is a slight departure from the typical "base case 0" pattern.

### 3.5 Ambiguity: Junction Depth 0 vs 1

The claim "If [junction depth] is zero or one then D is already syntactically separated" deserves attention. 

- Junction depth 0: No temporal operator appears, or all temporal operators are at the outermost level with no nesting. Actually, junction depth 0 would mean no subformula occurrence is inside any alternating chain. This means: for every temporal subformula U(A,B) or S(A,B), the path from the root to it does not pass through any temporal operator of the OPPOSITE type. In other words: no U is inside an S, and no S is inside a U. This is exactly "syntactically separated."

- Junction depth 1: There is a single alternation somewhere -- e.g., a U inside an S, or an S inside a U, but no further alternation within. Wait: a chain of length 1 is a single temporal operator. The chain C_1 consists of just one U or S, and B is a subformula of C_1. Any formula with temporal operators has junction depth >= 1 (since atoms inside S(a, q) have C_1 = S(a,q), giving depth >= 1). So junction depth 1 means the maximum alternating chain is length 1, which means there is never a U-inside-S or S-inside-U. SAME as junction depth 0 for the formula itself.

Actually, I think I need to re-read the definition. A chain C_1, ..., C_n must alternate between U and S. For a chain of length 1, there is just one C_1 which is either U or S -- no alternation constraint needed (there's nothing to alternate with). For length 2, C_1 and C_2 must be different types. So junction depth >= 2 means there IS a U inside an S or an S inside a U.

So junction depth 0 means no temporal operator at all (or the formula is atomic/boolean-only). Junction depth 1 means temporal operators exist but don't alternate. Junction depth >= 2 means there is at least one case of S-inside-U or U-inside-S.

This makes the base case clear: if junction depth <= 1, there is no mixed nesting, so the formula is syntactically separated.

### 3.6 GHR94 Does NOT Use the Term "replace_untl"

GHR94 uses plain language: "replacing each appearance of U(A_i, B_i) by a new atom q_i" or "Replace each U(X_ij, Y_ij) by the new atom z_ij." There is no named operation. The freshness of the atoms is stated as "new atom" without formal machinery.

### 3.7 Back-Substitution Correctness is Unstated

GHR94 takes for granted that:
1. Replacing a subformula by a fresh atom and then substituting back recovers the original.
2. Semantic equivalence is preserved under this round-trip.

Neither is proved explicitly. These are implicitly standard substitution lemmas.

---

## 4. The Abstraction Pattern

GHR94 uses the "abstract, separate, back-substitute" pattern in three places:

### 4.1 Lemma 10.2.6 (Abstract other U-types)

- **Abstract**: Replace U(A_i, B_i) for i = 1..n-1 by fresh atoms q_i.
- **Separate**: Apply Lemma 10.2.5 to the single-U-type result.
- **Back-substitute**: Replace q_i by U(A_i, B_i) in the pure past parts.
- **Apply IH**: The pure past parts now have at most n-1 U-types.

### 4.2 Lemma 10.2.7 (Abstract inner U-subformulas)

- **Abstract**: Replace each U(X_ij, Y_ij) inside U(A_i, B_i) arguments by fresh atoms z_ij.
- **Result**: U-arguments become U-free (and are already S-free by hypothesis), so Lemma 10.2.6 applies.
- **Separate**: Apply Lemma 10.2.6.
- **Back-substitute**: Replace z_ij by U(X_ij, Y_ij) in the pure past parts.
- **Apply IH**: The pure past parts have U-nesting depth < n.

### 4.3 Lemma 10.2.8 (Abstract S from U-arguments)

- **Abstract**: Replace maximal S(E, F) inside U-arguments by fresh atoms z_ij.
- **Result**: U-arguments become S-free, so "no S nested in U" holds, and Lemma 10.2.7 applies.
- **Separate**: Apply Lemma 10.2.7.
- **Back-substitute**: Replace z_ij by S(E, F).
- **Apply IH**: The junction depth has decreased.

### 4.4 Freshness and Roundtrip

GHR94 is explicit that atoms are "new" (fresh) but does not formally define freshness or prove roundtrip properties. The implicit requirement is:
- The fresh atom does not appear in the original formula D.
- Substituting back recovers D exactly (syntactic roundtrip).
- Semantic equivalence of D' (after abstraction) under a valuation that maps the fresh atom to the truth set of the abstracted subformula gives the same truth values as D.

---

## 5. BLOCKER ANALYSIS: Lemma 10.2.7 Depth >= 2

This section provides the deep analysis needed for the first implementation blocker: the case n >= 2 of Lemma 10.2.7.

### 5.1 The Exact GHR94 Text (Lemma 10.2.7, Case n > 1)

Quoting from lines 181-186 of the chapter 10 transcript:

> "Let U(A_i, B_i) (i = 1, ..., N) be some subformulae of D such that every appearance of U in D is as a subformula of an appearance of one of the U(A_i, B_i). Each A_i and B_i are built up as a boolean combination from wffs of the form U(X_ij, Y_ij) and atoms. Replace each U(X_ij, Y_ij) in A_i and B_i by the new atom z_ij to form wffs A'_i and B'_i which are just boolean combinations of atoms. Thus when we substitute z_ij by U(X_ij, Y_ij) in A'_i and B'_i we obtain A_i and B_i respectively."
>
> "Replace each occurrence of U(A_i, B_i) (which is not contained within another U(A_i, B_i)) in D by U(A'_i, B'_i) to obtain D', which can be separated by the preceding lemma. Let E' be its separated form. E' will be a boolean combination of atoms (including the z_ij), pure future formulae (like U(A'_i, B'_i)) and pure past formulae (for example A'_i's and B'_i's nested under Ss). Furthermore, when we substitute in z_ij by U(X_ij, Y_ij) we obtain a wff E equivalent to D."
>
> "Unfortunately, E is not separated: what were pure past formulae in E' have become, on replacement of z_ij by U(X_ij, Y_ij), impure. To correct this we use the induction hypothesis on each of these pure past subformula of E. It is clear that we can do so as the level of nesting of U in U(A_i, B_i) must be strictly greater than that in its subformula U(X_ij, Y_ij)."

### 5.2 What Does "Inner U-Subformulas" Mean?

GHR94 says: "Each A_i and B_i are built up as a boolean combination from wffs of the form U(X_ij, Y_ij) and atoms."

The U(A_i, B_i) are the OUTERMOST U-subformulas of D -- the ones that "cover" all U appearances (every U in D is inside some U(A_i, B_i)). The U(X_ij, Y_ij) are the immediate sub-U-formulas inside the ARGUMENTS of U(A_i, B_i).

Since "no S nested in U" holds, A_i and B_i are S-free. Since n >= 2, A_i and B_i contain U-subformulas (the U(X_ij, Y_ij)). These U(X_ij, Y_ij) are the "inner U-subformulas."

**Precisely**: "Inner" means U-subformulas that are INSIDE the arguments of a covering U. They are one level deeper in the U-nesting hierarchy. They are NOT U-subformulas at the same level or at the top level.

### 5.3 One at a Time or All at Once?

GHR94 abstracts ALL inner U-subformulas simultaneously.

Quoting: "Replace **each** U(X_ij, Y_ij) in A_i and B_i by the new atom z_ij"

The indexing z_ij uses two indices: i (which covering U(A_i, B_i) this is inside) and j (which inner U-subformula within that covering U). ALL such U(X_ij, Y_ij) for ALL i and ALL j are replaced at once.

The result: A'_i and B'_i are "just boolean combinations of atoms" -- meaning they are both S-free (inherited from the original A_i, B_i being S-free by hypothesis) AND U-free (because all U-subformulas were replaced by atoms).

### 5.4 Does GHR94 Guarantee the Abstracted U Has U-Free Args?

YES, and this is the key point.

After abstraction:
- D' is obtained by replacing each U(A_i, B_i) in D by U(A'_i, B'_i).
- A'_i and B'_i are "just boolean combinations of atoms" -- they are U-free AND S-free.
- Therefore each U(A'_i, B'_i) in D' has U-free AND S-free arguments.
- D' satisfies the hypotheses of Lemma 10.2.6: "the only appearances of U in D' are in the form U(A'_i, B'_i)" where each A'_i, B'_i is "built without S or U."

This is why GHR94 says "D', which can be separated by the preceding lemma [10.2.6]."

### 5.5 After Abstraction, What is the U-Nesting Depth?

After abstraction, D' has U_nesting_depth = 1 beneath any S.

**Why**: In D', each U(A'_i, B'_i) has U-free arguments. So inside any S-argument of D', U-nodes appear but their own arguments have no further U. This is exactly U-nesting depth 1 beneath S.

GHR94 does NOT claim the depth merely "decreases by 1." The depth drops to EXACTLY 1 (or 0 if the S-context had no U in it). The abstraction is aggressive enough to remove ALL inner U-nesting in a single step.

This is why case n = 1 (Lemma 10.2.6) suffices for D'.

### 5.6 How Does Back-Substitution Work?

After separating D' to get E':

1. E' is "a boolean combination of atoms (including the z_ij), pure future formulae (like U(A'_i, B'_i)) and pure past formulae."

2. The pure future parts: U(A'_i, B'_i). After back-substitution z_ij -> U(X_ij, Y_ij), these become U(A_i, B_i) -- the original covering U-subformulas. These are STILL pure future (they have no S in their arguments by the "no S in U" hypothesis).

3. The atoms z_ij: After back-substitution, z_ij becomes U(X_ij, Y_ij). If z_ij appeared at the top level of the boolean combination (as a "pure present" atom), it now becomes U(X_ij, Y_ij) which is pure future (since X_ij, Y_ij are S-free). This is fine.

4. The pure past parts D_j: These are S-formulas that may contain z_ij atoms. After back-substitution, z_ij -> U(X_ij, Y_ij), the pure past parts now contain U-subformulas inside their S-arguments. They are no longer pure past.

**What GHR94 says to do about the pure past parts**:

> "To correct this we use the induction hypothesis on each of these pure past subformulae of E."

So: take each pure past subformula of E' (which is some expression built from S, atoms, and z_ij). After back-substitution, it becomes a formula with U-subformulas (the U(X_ij, Y_ij)) inside S-arguments. This formula:
- Has "no S nested in U" (because U(X_ij, Y_ij) originally had S-free arguments, and back-substitution only puts U's inside S, not S inside U).
- Has U-nesting depth < n (because the U(X_ij, Y_ij) are inner subformulas with strictly lower nesting depth than the covering U(A_i, B_i)).

So the IH applies to each such pure past subformula.

### 5.7 Why the U-Nesting Depth Strictly Decreases

GHR94 says: "the level of nesting of U in U(A_i, B_i) must be strictly greater than that in its subformula U(X_ij, Y_ij)."

This is because U(X_ij, Y_ij) is a PROPER subformula of U(A_i, B_i) -- it is inside A_i or B_i. The U-nesting depth of U(A_i, B_i) is at least 1 + (depth of U(X_ij, Y_ij)), since U(X_ij, Y_ij) is one level deeper.

After back-substitution, the pure past parts contain U(X_ij, Y_ij) (not U(A_i, B_i)). The U(A_i, B_i) formulas appear only in the pure future parts. So the U-nesting depth beneath S in the pure past parts is bounded by max depth of U(X_ij, Y_ij), which is < n.

### 5.8 Implications for the Lean Implementation

The current Lean code's `extract_U_type` finds any surface U-type, but at depth >= 2, the args of that U-type may NOT be U-free. GHR94's approach is different:

1. Find the OUTERMOST U-subformulas U(A_i, B_i) that cover all U in D.
2. Inside their arguments A_i, B_i, find the immediate U-subformulas U(X_ij, Y_ij).
3. Replace the INNER U's (X_ij, Y_ij) by fresh atoms z_ij.
4. This makes the OUTER U's arguments U-free.

The Lean code should NOT be looking for a U-type with U-free args (there may be none at depth >= 2). Instead, it should:
- Identify the covering U-subformulas.
- Abstract the inner U-subformulas from their arguments.
- The result then has U-free args for the covering U's.
- Apply Lemma 10.2.6.

This is fundamentally different from "find a U-type and separate it." It is "restructure the formula so that all U-types have U-free args, then apply 10.2.6."

---

## 6. BLOCKER ANALYSIS: Lemma 10.2.5 Depth >= 2

This section provides the deep analysis needed for the second implementation blocker: whether Lemma 10.2.5 is self-contained or needs the full separation theorem.

### 6.1 The Exact GHR94 Text (Lemma 10.2.5 Proof)

From lines 149-155 of the transcript:

> "*Proof.* By induction on the maximum number k of nested Ss above any U(A, B)."
>
> "*Case k = 0:* In this case D is already separated."
>
> "*Case k > 0:* Apply the preceding lemma [10.2.4] to each of the most deeply nested S(C, F) in which U(A, B) appear and then we have an equivalent wff in which the maximum depth of nesting of U(A, B) is reduced. Note also that U still only appears in the form U(A, B). The induction hypothesis then gives us the result."

### 6.2 Is 10.2.5 Self-Contained?

YES. Lemma 10.2.5 is completely self-contained. It does NOT need to call back to the full separation theorem.

The induction is on k (the maximum number of nested S's above any U(A,B)). At each step:
1. Find the INNERMOST S-nodes that contain U(A,B) -- "the most deeply nested S(C, F) in which U(A, B) appear."
2. Apply Lemma 10.2.4 to each such S(C, F).
3. The result has lower k (the S-nesting depth above U(A,B) decreased by at least 1).
4. Apply the IH.

No step requires calling 10.2.6, 10.2.7, or 10.2.8. The only external dependency is Lemma 10.2.4, which itself depends only on 10.2.1 and 10.2.3.

### 6.3 What Happens at S-Nesting Depth k >= 2?

At depth k >= 2, there are U(A,B) occurrences nested under at least 2 layers of S. For example:

```
S(p AND S(q AND U(A,B), r), s)
```

Here, U(A,B) is under S(q AND U(A,B), r) which is under the outer S.

**Step 1**: Find the most deeply nested S containing U(A,B). That is `S(q AND U(A,B), r)`.

**Step 2**: Apply Lemma 10.2.4 to `S(q AND U(A,B), r)`. The hypotheses are satisfied:
- A, B are S-free and U-free (by the hypothesis of 10.2.5).
- In `S(q AND U(A,B), r)`, U only appears as U(A,B).
- U(A,B) is not nested under any S within this particular subformula (this is the INNERMOST S containing U(A,B), so within its arguments, U(A,B) is at the top level w.r.t. S-nesting).

**Wait**: Is the last point always true? At depth k >= 2, could there be S's inside the arguments of the innermost S?

No. The "most deeply nested S(C, F) in which U(A,B) appear" is by definition the S that is closest to U(A,B). There is no S between this S and U(A,B). So within this S(C, F), U(A,B) appears at top level (not nested under any further S).

Actually, we need to be more careful. The innermost S containing U(A,B) might have both arguments containing U(A,B), and one argument might have another S between it and U(A,B). Let me reconsider.

Consider: `S(S(p, U(A,B)), U(A,B))`. Both arguments contain U(A,B). The inner `S(p, U(A,B))` is a "more deeply nested S containing U(A,B)." So the MOST deeply nested S containing U(A,B) is `S(p, U(A,B))`, not the outer S.

OK, so the algorithm finds the deepest S that still contains U(A,B). Within THAT S, there may be other S's, but they do NOT contain U(A,B) (otherwise those would be deeper). So within the selected S(C, F), U(A,B) appears in C and/or F but there is no S in C or F that itself contains U(A,B). Therefore, U(A,B) is "at top level" within C, F in the sense required by Lemma 10.2.4: "each appearance of U in either of them is as U(A, B) and is not nested under any Ss."

**The key insight**: There MAY be S-nodes in C and F, but those S-nodes do NOT contain U(A,B). So U(A,B) is not "nested under" those S-nodes. Lemma 10.2.4's hypothesis is about U(A,B) being "not nested under any Ss," and this is satisfied.

**Step 3**: After applying 10.2.4, the innermost S(C, F) is replaced by an equivalent formula in which U(A,B) no longer appears under S (it appears only at the boolean top level or in pure-future positions). The S-nesting depth k above U(A,B) decreases by at least 1.

**Step 4**: Apply the IH (which applies to formulas with S-nesting depth < k).

### 6.4 Does the IH Apply DIRECTLY?

Yes. After applying 10.2.4 to each innermost S containing U(A,B):
- The result is a wff D' where the S-nesting depth above U(A,B) is at most k - 1.
- D' still has single U-type U(A,B) (GHR94: "Note also that U still only appears in the form U(A, B)").
- D' still has A, B being S-free and U-free.
- So the IH applies directly to D'.

No additional infrastructure is needed. The induction is straightforward: apply 10.2.4 at the bottom, reduce k by at least 1, use IH.

### 6.5 Is Depth >= 2 Just Repeated Application of the Depth 1 Case?

YES. The depth >= 2 case is literally repeated application of the depth 1 argument:
- At depth 1, there is one S above U(A,B). Apply 10.2.4 to remove U(A,B) from under that S. Done (k = 0, already separated).
- At depth 2, find the innermost S above U(A,B). Apply 10.2.4. Now k = 1. Apply 10.2.4 again (through the IH). Now k = 0. Done.
- At depth k, apply 10.2.4 k times (each time reducing the depth by 1).

This is why Lemma 10.2.5 does NOT need the full separation theorem. It is a simple outer induction that peels off one S-layer at a time, using 10.2.4 as the workhorse.

### 6.6 Why the Current Lean Code Has a Circular Dependency

The current Lean implementation's `single_U_formula_separable_noax` at depth >= 2 calls `no_S_nested_in_U_separable_param` which needs `all_separable` as a callback. This creates an axiom dependency because the code conflates two different things:

1. **What GHR94 10.2.5 actually needs**: Just apply 10.2.4 to innermost S-nodes containing U(A,B), reducing S-nesting depth. The IH handles the rest. No call to 10.2.6 or higher is needed.

2. **What the Lean code does instead**: It treats the `snce` case as needing the full separation theorem to handle S(C, F) where C, F might be arbitrary. But in 10.2.5, C and F have a very specific structure: they have single U-type U(A,B) with A, B being S-free and U-free.

The fix is to make the `snce` case in 10.2.5 call 10.2.4 directly (which handles S(C, F) when U(A,B) appears at top level in C, F), and use the IH for the recursive case. There should be no need to route through the full separation machinery.

### 6.7 Precise Procedure for the Lean Implementation

For Lemma 10.2.5, depth k >= 2:

1. The formula D has structure involving `.snce` nodes with U(A,B) underneath.
2. **Structural induction on D** (or induction on k):
   - At `.snce C F` where U(A,B) appears in C or F:
     - If U(A,B) is at "top level" in C and F (not under any S within C, F): apply 10.2.4.
     - If U(A,B) is nested under S within C or F: recursively apply the IH to C and F first (which have single U-type and lower S-nesting depth since they are subformulas), THEN apply 10.2.4 to the resulting `.snce`.
   - Actually, GHR94's approach is cleaner: use the measure k (S-nesting depth above U) and find the innermost S. This doesn't require structural induction on D at all; it uses the measure k directly.

The simplest Lean encoding: strong induction on `S_nesting_above_U D`. At each step, find an innermost S containing U(A,B), apply 10.2.4 to that S (as a local rewrite), producing D' with `S_nesting_above_U D' < S_nesting_above_U D`, and apply IH.

---

## 7. Comparison Notes (Implementation Divergences)

These are brief flags only; solutions are NOT provided here.

### 7.1 Measure Definitions

The Lean code defines several measures (`junction_depth`, `U_depth_under_S`, `S_nesting_above_U`, `count_U_subformulas`). GHR94 uses:
- Lemma 10.2.5: "maximum number of nested Ss above any U(A,B)" -- corresponds to `S_nesting_above_U`
- Lemma 10.2.6: induction on n (number of distinct U-types) -- loosely related to `count_U_subformulas` but GHR94 counts distinct TYPE PAIRS, not total count
- Lemma 10.2.7: "maximum depth of nesting of Us beneath an S" -- corresponds to `U_depth_under_S`
- Lemma 10.2.8: junction depth -- corresponds to `junction_depth`

The Lean `U_depth_under_S` resets at S-nodes (line 361: `| .snce _ _ => 0`). This may not correctly capture what GHR94 means. GHR94's measure looks at U-nesting WITHIN S-arguments (looking down from S), whereas `U_depth_under_S` counts U-depth upward from the formula root. These may produce different values.

### 7.2 has_single_U_type vs GHR94

The Lean predicate `has_single_U_type` requires every `untl` node to have arguments exactly (A, B). GHR94's Lemma 10.2.5 says "the only appearance of U in the wff D is as U(A,B)." These are equivalent.

### 7.3 Lemma 10.2.3 Generality

GHR94 states Lemma 10.2.3 for atoms a, q, A, B. The Lean implementation may need to handle the generalization to arbitrary S-free/U-free formulas in those positions (as needed by Lemma 10.2.4).

### 7.4 The `snce_separable` Axiom

The Lean code uses a temporal closure axiom `snce_separable` as a placeholder in `single_U_formula_separable`. In GHR94, this role is played by the S-nesting induction of Lemma 10.2.5 itself -- the `snce` case applies Lemma 10.2.4 (which handles one layer of S). The axiom should be eliminated by the full induction.

### 7.5 `no_S_nested_in_U` Definition

The Lean predicate requires `is_S_free phi = true AND is_S_free psi = true` at each `untl phi psi` node. This matches GHR94's "no S nested within a U" exactly: every U-argument is S-free.

### 7.6 Junction Depth Mutual Recursion

The Lean code uses a mutual recursion (`junction_depth`, `junction_depth_U`, `junction_depth_S`) to track alternation. `junction_depth_U` adds 1 at `snce` nodes (tracking S-after-U alternation), and `junction_depth_S` adds 1 at `untl` nodes (tracking U-after-S alternation). This is a reasonable encoding of GHR94's alternating-chain definition, though the correctness of the equivalence would need verification.

---

## 8. Summary of Proof Dependencies

```
Lemma 10.2.1 (distribution)
  |
  v
Lemma 10.2.2 (negation over integers)
  |
  v
Lemma 10.2.3 (8 elimination cases)  <-- uses 10.2.1, 10.2.2, semantic arguments
  |
  v
Lemma 10.2.4 (S(C,F) single U-type, top level)  <-- uses 10.2.1 (DNF/CNF), 10.2.3
  |
  v
Lemma 10.2.5 (single U-type, any nesting)  <-- induction on S-nesting above U; uses 10.2.4
  |
  v
Lemma 10.2.6 (multiple U-types, all with S/U-free args)  <-- induction on count; uses 10.2.5 + abstraction
  |
  v
Lemma 10.2.7 (no S in U => separable)  <-- induction on U-depth under S; uses 10.2.6 + abstraction
  |
  v
Lemma 10.2.8 (any formula separable)  <-- induction on junction depth; uses 10.2.7 + abstraction
  |
  v
Theorem 10.2.9 (Separation Theorem)  <-- direct from 10.2.8
  |
  v
Theorem 10.2.10 (Expressive Completeness)  <-- 10.2.9 + Chapter 9 results
```

Each lemma in the chain 10.2.4 -> 10.2.5 -> 10.2.6 -> 10.2.7 -> 10.2.8 uses the "abstract, separate by preceding lemma, back-substitute, apply IH" pattern, with a different induction measure at each level.
