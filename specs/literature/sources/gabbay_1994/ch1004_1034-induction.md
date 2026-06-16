### 10.3.4 Induction

For the benefit of the next chapter we need to account for the rewrites we use in separating wffs.

**Definition 10.3.12** An *acceptable rewrite* of wff σ is any change accomplished by replacing subwff ν of σ by ξ where ξ is got from ν by:

- boolean rearrangement,
- replacing K⁺(x) by ¬U(c, ¬x) and similarly K⁻,
- one of the simple U/S(A ∨ B, C), U/S(A, B ∧ C), K±(A ∨ B) and Γ±(A ∧ B) equivalences,
- one of the four K± eliminations,
- replacing a boolean constituent Γ±(A) of σ by K∓(¬A) ∧ ¬K±(¬A),
- one of the four Γ± eliminations,
- one of the eight U/S eliminations,
- or several of such steps.

**Definition 10.3.13** Write *acceptably separated* for acceptably rewritten as a syntactically separated wff.

Note that acceptable rewriting preserves equivalence over Dedekind complete linear orders in which c is relatively dense.

We now have the necessary tools to prove the separation theorem of Since and Until over Dedekind complete time.

**Lemma 10.3.14** Suppose that A and B are wffs of {U, S, K±, Γ±} in which U and S do not appear and that E and F are wffs in which U only appears as U(A, B) and never nested within S, K± or Γ±.

Then each of S(E, F), K±(E), and Γ±(E) can be acceptably rewritten as a boolean combination of wffs of the following forms:

- atoms,
- U(A, B), and
- S(E₁, F₁), K±(E₁) and Γ±(E₁) in which U does not appear.

Furthermore, we do not have to use the acceptable rewrite of replacing Γ± by K±s in doing so.

*Proof.* By using boolean rearrangement, which is an acceptable rewrite, and rules about taking disjuncts (in the case of E) or conjuncts (in the case of F) out of connectives, we can without loss suppose that U(A, B) (possibly negated) only appears as a conjunct in E and/or a disjunct of F.

Now use the appropriate one of the 16 eliminations to remove the U(A, B) from within the K±, Γ± or S. An inspection of the results of these eliminations will reveal that we have our proof.

Remember that A and B are not necessarily atoms when doing the inspection. □

**Lemma 10.3.15** Suppose that A and B are wffs of {U, S, K±, Γ±} in which U and S do not appear and that in both wffs C and F the only appearances of U, if any, are as the subformula U(A, B) and are never nested below S, K±, or Γ±.

Then S(C, F) can be acceptably separated as a wff in which U only appears as the formula U(A, B).

*Proof.* So C and F are boolean combinations of atoms, of wffs (built from K±, Γ±, or S) not containing U and of appearances of U(A, B) itself. As in the integer case we rewrite in normal forms and use lemma 10.2.1 to acceptably rewrite S(C, F) as a boolean combination of wffs S(C₁, C₂) with no U appearing and of wffs of the form either:

- S(C₁, C₂ ∨ ±U(A, B)), or
- S(C₁ ∧ ±U(A, B), C₂ ∨ ±U(A, B)),

for some wffs C₁ and C₂ not containing U.

Using the S eliminations it can be seen that we can acceptably rewrite wffs of these latter forms as boolean combinations of:

- A and B,
- S(C', F') containing no U,
- U(A, B), and
- K⁻(C') containing no U.

Checking each elimination will reveal that there are no other possibilities.

Now we are almost finished as all these subformulae are pure except possibly boolean constituents of A and B. The only possible offenders are constituents of the form Γ±(C') where C', like A and B, contains neither U nor S. We simply rewrite such Γs as Ks and we are done. □

**Lemma 10.3.16** Suppose that A and B are wffs of {U, S, K±, Γ±} in which U and S do not appear and that in both wffs C and F the only appearances of U, if any, are as the subformula U(A, B).

Then S(C, F) can be acceptably separated as a wff in which U only appears as the formula U(A, B).

*Proof.* If U(A, B) does not appear then we are done. Assume otherwise. The proof is by induction on the maximum depth k of nested occurrences of S, K± or Γ± within S(C, F) which contain U (i.e. U(A, B)) in their scope.

*k = 1:* This is just the last lemma.

*k > 1:* Let Dⱼ, j = 1, ..., N be all the wffs of the forms S(C₁, C₂), K±(C₁), Γ±(C₁) such that C₁ and C₂ may contain U(A, B) but contain no nested occurrence of U(A, B) within K±, Γ± or S.

By the moving-up-of-Us lemma these can be acceptably rewritten not using the Γ± to K± rewrite so that U still only appears as U(A, B) but no longer nested within S, K±, or Γ±. Replacing these Dⱼs by their rewritten form is an acceptable rewrite of S(C, F) but reduces the depth of nesting and allows us to use the induction hypothesis to finish.

□

**Lemma 10.3.17** For each i = 1, ..., n let Aᵢ and Bᵢ be wffs built without S or U. Suppose that the only appearances of U in the wff D are in the form U(Aᵢ, Bᵢ).

Then D is acceptably separable.

*Proof.* Proceed by induction on n as in the integers case, lemma 10.2.6.

When n = 1 we have the preceding lemma so suppose that n > 1. First replace each appearance of U(Aᵢ, Bᵢ) by a new atom qᵢ for each i = 1, ..., n−1 to obtain a new wff D'. Now acceptably separate D' to E' using the last lemma. Substitute the U(Aᵢ, Bᵢ) back in for the qᵢ to obtain E and it is clear that this is an acceptable rewrite of D.

Remembering that E' is syntactically separated let us show how to acceptably separate each boolean constituent of E. These will be of the following forms:

- (old) atoms which are already pure,
- U(Aₙ, Bₙ) which are pure future,
- K⁺(Eᵢ) containing no S (so already separated), and
- K⁻(Eᵢ) and S(Eᵢ, Fᵢ) containing U only in the forms U(Aᵢ, Bᵢ) for i ≤ n−1.

Rewriting the K⁻(Eᵢ)s as ¬S(c, ¬Eᵢ)s we note that in these latter K⁻ and S cases we can use the induction hypothesis to finish. □

**Lemma 10.3.18** Suppose that wff S(C, F) contains no S nested within a U.

Then S(C, F) is acceptably separable.

*Proof.* By induction on the maximal depth n of nesting of Us beneath any S.

*Case n = 1:* This is the case of the preceding lemma.

*Case n > 1:* Let U(Aᵢ, Bᵢ) (i = 1, ..., N) be the subformulae covering the least deeply nested appearances of U, i.e. every appearance of U in S(C, F) is as a subformula of an appearance of one of the U(Aᵢ, Bᵢ). Each Aᵢ and Bᵢ are built up as a combination from wffs of the form U(Xᵢⱼ, Yᵢⱼ) and atoms using boolean connectives, Γ± and K±. Replace each U(Xᵢⱼ, Yᵢⱼ) in Aᵢ and Bᵢ by the new atom zᵢⱼ to form wffs A'ᵢ and B'ᵢ which are now just combinations of atoms. Thus when we substitute in A'ᵢ and B'ᵢ the value zᵢⱼ = U(Xᵢⱼ, Yᵢⱼ) we obtain Aᵢ and Bᵢ respectively.

Replace each occurrence of U(Aᵢ, Bᵢ) in D by U(A'ᵢ, B'ᵢ) to obtain D'. D' can be acceptably separated by the preceding lemma. Let E' be its separated form. E' will be a boolean combination of

- atoms (including the zᵢⱼ),
- pure future formulae (like U(A'ᵢ, B'ᵢ)), and
- pure past formulae (for example A'ᵢs and B'ᵢs nested under Ss).

Furthermore, when we substitute in zᵢⱼ = U(Xᵢⱼ, Yᵢⱼ) we obtain a wff E which is an acceptable rewrite of D.

Unfortunately, E is not necessarily separated: what were pure past formulae in E' have become, on replacement of zᵢⱼ by U(Xᵢⱼ, Yᵢⱼ), impure. To correct this we use the induction hypothesis on each of these pure past subformula of E. Wff K⁻(C) will have to be rewritten as ¬S(c, ¬C) in order to do so.

This can be done since the level of nesting of U in U(Aᵢ, Bᵢ) must be strictly greater than that in its subformula U(Xᵢⱼ, Yᵢⱼ).

□

Let us bring in all the assumptions when we write out our final lemma:

**Lemma 10.3.19** Suppose that D₁ and D₂ are wffs from the language with {U, S, K±, Γ±} and special atom c.

Then any wff of the form D = U(D₁, D₂) or D = S(D₁, D₂) can be acceptably rewritten as a wff which is

- equivalent to D over any Dedekind complete flow of time in which c is interpreted relatively densely, and
- syntactically separated.

*Proof.* Again this is similar to lemma 10.2.8. We define junction depth just as we did there: i.e. we ignore the K± and Γ± as we do the classical connectives.

Now we begin the proof being given a wff D of one of the above forms. We proceed by induction on the junction depth d of D.

If it is zero or one then D is already syntactically separated. So assume the induction hypothesis and that the junction depth of D is at least two.

Again because of the dual nature of the results so far we need only demonstrate the syntactic separation of a wff of the form D = S(D₁, D₂).

Let U(Aᵢ, Bᵢ) (i = 1, ..., N) be the subformulae covering the least deeply nested appearances of U, i.e. every appearance of U in S(D₁, D₂) is as a subformula of an appearance of one of the U(Aᵢ, Bᵢ).

There are some subformulae of U(Aᵢ, Bᵢ) which are of the form S(E, F). We note that the junction depth of any of these subformulae is at most d − 2. Replace each least deeply nested such subformula S(Eᵢⱼ, Fᵢⱼ) in U(Aᵢ, Bᵢ) by its own new atom zᵢⱼ to obtain U(A'ᵢ, B'ᵢ). Change S(D₁, D₂) into D' by replacing each U(Aᵢ, Bᵢ) by U(A'ᵢ, B'ᵢ). The preceding lemma now tells us how to acceptably separate D' into a wff E'.

Now E' will be a boolean combination of subformulae of the form:

- zᵢⱼ,
- other atoms,
- S(C₁, C₂) not containing U,
- U(C₁, C₂) not containing S,
- K⁺(C₁) not containing S, and
- K⁻(C₁) not containing U.

To finish we resubstitute in the original S(Eᵢⱼ, Fᵢⱼ) (of junction depth ≤ d − 2) for each zᵢⱼ in each of the forms of subformulae above to obtain E which is an acceptable rewrite of S(D₁, D₂). We still need to acceptably separate each subformula.

What was zᵢⱼ in E' has become S(Eᵢⱼ, Fᵢⱼ) in E but this has junction depth at most d − 2 so we can use the induction hypothesis.

Atoms are pure.

Those of the form S(C₁, C₂) now have junction depth at most d − 2 while those of the form U(C₁, C₂) have depth less than or equal to d − 1 so our induction hypothesis completes the proof.

Consider K⁺(C₁) not containing S changed into K⁺(C') by resubstitutions for each zᵢⱼ. We can rewrite this as ¬U(c, ¬C') and we see that the junction depth is one greater than that of the greatest of the S(Eᵢⱼ, Fᵢⱼ) used. This is still at most d − 1 and we can use the induction hypothesis.

Finally, consider K⁻(C') which we rewrite as ¬S(c, ¬C'). Here, resubstitution doesn't increase the depth above the maximum of the S(Eᵢⱼ, Fᵢⱼ) and we can apply the induction hypothesis.

□

**Theorem 10.3.20** (Separation Theorem) Over Dedekind complete time, each wff in the language with {U, S} is equivalent to a separated wff.

*Proof.* All the separation equivalences hold with c interpreted as true everywhere so we can ignore this special atom.

The wff is a boolean combination of atoms and wffs of the form U(A, B) and S(A, B). The latter two types of subformula can be syntactically separated in the extended language with K± by the preceding lemma. This leaves us with a syntactically separated, and hence separated, formula. By rewriting any appearances of K± or Γ± using only U and S we can preserve the purity of the appropriate subformulae (which is a semantic property), and hence separation. □

**Theorem 10.3.21** The language {U, S} is *expressively complete* over Dedekind complete time.

*Proof.* This follows from the separation theorem and the results of chapter 9. □
