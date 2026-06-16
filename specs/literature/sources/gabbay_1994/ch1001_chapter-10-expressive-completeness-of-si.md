# Chapter 10: Expressive Completeness of Since and Until over Integer and Real Time

## 10.1 Introduction

In this chapter we will show how the separation theorem — theorem 9.3.1 — can be used to prove the expressive completeness of the language with Until and Since over some very important flows of time. To do this we need to show the separation of the language over the flows. First, in section 10.2, we examine the discrete Dedekind complete flows of time, concentrating on the integers. This serves as a simple introduction to the techniques which we then use in section 10.3 to show separation of this language over any class of Dedekind complete flows of time. The separation procedure is performed in two stages: first some basic equivalences, called eliminations, are shown; then we show how to put eliminations together in the right order to achieve separation.

## 10.2 Separation for S, U over Integer Time

In this section we prove that the language with the connectives S and U has the separation property over the flow of time of the integers. This proof appeared in [Gabbay, 1989a]. It can be seen that the proof will also work for the natural numbers.

Wffs of the language may contain nested occurrences of S and U, one inside the other, as does, for example, S(a ∧ U(b, c ∨ S(x, y)), d). We shall describe a syntactic procedure for pulling out the Us systematically from inside the Ss (and vice versa depending on the case at hand) until we arrive at an equivalent wff with the property that no U is in the scope of an S and no S is in the scope of a U. A wff with this property is already separated, because any wff beginning with U and containing only atoms and Us is pure future. Anything with S only is pure past and the atoms are of course pure present. The process is very simple. As we shall see there are eight cases of nested occurrences of U within an S to worry about. Each case is not difficult to deal with and this should practically finish the proof since for any given A, we can keep on eliminating Us and Ss as required.

First we need some equivalences of relations over flow of time.

**Lemma 10.2.1** The following are valid over linear time:

- U(A ∨ B, C) ↔ U(A, C) ∨ U(B, C),
- S(A ∨ B, C) ↔ S(A, C) ∨ S(B, C),
- U(A, B ∧ C) ↔ U(A, B) ∧ U(A, C),
- S(A, B ∧ C) ↔ S(A, B) ∧ S(A, C).

*Proof.* Simple. □

**Lemma 10.2.2** The following hold over integer time:

- ¬U(A, B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A),
- ¬S(A, B) ↔ H(¬A) ∨ S(¬A ∧ ¬B, ¬A),
- ¬U(A, B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, B ∧ ¬A),
- ¬S(A, B) ↔ H(¬A) ∨ S(¬A ∧ ¬B, B ∧ ¬A).

*Proof.* Simple. □

Now we describe some more equivalences which we will call eliminations because they allow us to eliminate a nested occurrence of a U from beneath an S.

It should be noted that all the results in the rest of this section have dual results in which U and S exchange roles.

**Lemma 10.2.3** Let a, q, A, and B be atoms. Consider the following wffs:

1. S(a ∧ U(A, B), q),
2. S(a ∧ ¬U(A, B), q),
3. S(a, q ∨ U(A, B)),
4. S(a, q ∨ ¬U(A, B)),
5. S(a ∧ U(A, B), q ∨ U(A, B)),
6. S(a ∧ ¬U(A, B), q ∨ U(A, B)),
7. S(a ∧ U(A, B), q ∨ ¬U(A, B)), and
8. S(a ∧ ¬U(A, B), q ∨ ¬U(A, B)).

Each of the wffs above is equivalent, over integer time, to another wff in which the only appearances of the until connective are as the wff U(A, B) and no appearance of that wff is in the scope of an S.

*Proof.* Some proofs here involve semantic argument, some involve just the use of other eliminations and equivalences from preceding lemmas and some involve both types of argument. We will only present some of the details.

1. It is very easy to show that S(a ∧ U(A, B), q) is equivalent to

   S(a, q) ∧ S(a, B) ∧ B ∧ U(A, B)
   ∨ [A ∧ S(a, B) ∧ S(a, q)]
   ∨ S(A ∧ q ∧ S(a, B) ∧ S(a, q), q).

   To see this notice that the original wff holds at t iff there is s < t and u > s such that a holds at s, A at u, B everywhere between s and u, and q everywhere between s and t. The three disjuncts correspond to the cases u > t, u = t, and u < t respectively. Note that we make essential use of the linearity of time.

2. S(a ∧ ¬U(A, B), q) can be rewritten by using lemmas 10.2.1 and 10.2.2, noting that S(a ∧ G(¬A), q) is equivalent to S(a, ¬A ∧ q) ∧ (¬A) ∧ G(¬A), using the first elimination and then using lemma 10.2.2 again (in reverse).

   We end up with S(a ∧ ¬U(A, B), q) equivalent to

   [S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A, B)]
   ∨ [¬A ∧ ¬B ∧ S(a, ¬A ∧ q)]
   ∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q).

3. To separate S(a, q ∨ U(A, B)) we look at its negation and use lemma 10.2.2 and then elimination (2) above to obtain:

   S(a, q ∨ U(A, B))
   ↔ ¬( H(¬a)
   ∨ [S(¬a ∧ ¬q, ¬a ∧ ¬A) ∧ ¬A ∧ (¬U(A, B) ∨ ¬B)]
   ∨ S(¬A ∧ ¬B ∧ ¬a ∧ S(¬a ∧ ¬q, ¬A ∧ ¬a), ¬a) ).

4. The case of S(a, q ∨ ¬U(A, B)) is very straightforward to do semantically. It is equivalent to

   S(a, ¬a ∧ [S(¬q ∧ ¬a, ¬a ∧ B) ⇒ ¬A])
   ∧ (S(¬q ∧ ¬a, ¬a ∧ B) ⇒ ¬[A ∨ (B ∧ U(A, B))]).

5. S(a ∧ U(A, B), q ∨ U(A, B)) is equivalent to

   S(a, B) ∧ [A ∨ (B ∧ U(A, B))]
   ∨ S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A))
   ∧ [A ∨ (B ∧ U(A, B))] ∧ ¬S(¬q, ¬A).

   The first disjunct holds when the A from U(A, B) is true in the future or present and the second when it is true in the past.

6. The case of S(a ∧ ¬U(A, B), q ∨ U(A, B)). Let s be the time in the past indicated by the S. The wff is separated by considering when the first occurrence (if any) of ¬B after s is. We obtain an equivalent wff with two disjuncts:

   [S(a, q ∧ ¬A) ∧ ¬A ∧ ¬(B ∧ U(A, B))]
   ∨ S(¬B ∧ ¬A ∧ (q ∨ U(A, B)) ∧ S(a, q ∧ ¬A), q ∨ U(A, B)).

   Eliminations (3) and (5) can be used to finish the separating.

7. S(a ∧ U(A, B), q ∨ ¬U(A, B)). By considering when A is true we deduce that our formula is equivalent to the disjunction:

   [S(A ∧ (q ∨ ¬U(A, B)) ∧ S(a, B ∧ q), q ∨ ¬U(A, B))]
   ∨ [S(a, B ∧ q) ∧ A]
   ∨ [S(a, B ∧ q) ∧ B ∧ U(A, B)].

   The first disjunct can be further eliminated by eliminations (8) and (4).

8. The case D = S(a ∧ ¬U(A, B), q ∨ ¬U(A, B)) can be reduced to cases already discussed since

   ¬S(a ∧ z, q ∨ y) ↔ H(¬a ∨ ¬z)
   ∨ S(¬q ∧ ¬y ∧ ¬a, ¬a ∨ ¬z)
   ∨ S(¬q ∧ ¬y ∧ ¬z, ¬a ∨ ¬z).

   Substituting y = z = ¬U(A, B) we obtain

   ¬D ↔
   H(¬a ∨ U(A, B))
   ∨ S(¬q ∧ ¬a ∧ U(A, B), ¬a ∨ U(A, B))
   ∨ S(¬q ∧ U(A, B), ¬a ∨ U(A, B)).

   Notice the last disjunct in ¬D is redundant.

   These are cases we can handle by other eliminations, especially elimination (5).

□

We now know the basic steps in our proof of separation. We simply keep pulling out Us from under the scopes of Ss and vice versa until there are no more. Given a wff A, this process will eventually leave us with a syntactically separated wff, i.e. a wff B which is a boolean combination of atoms, wffs U(E, F) with E and F built without using S and wffs S(E, F) with E and F built without using U. Clearly, such a B is separated.

**Lemma 10.2.4** Suppose that A and B are wffs in which U and S do not appear and that both wffs C and F are such that each (if any) appearance of U in either of them is as U(A, B) and is not nested under any Ss.

Then S(C, F) is equivalent to a syntactically separated wff in which U only appears as the formula U(A, B).

*Proof.* If U(A, B) does not appear then we are done. Otherwise, by rearrangement of C and F into disjunctive and conjunctive normal form, respectively, and repeated use of lemma 10.2.1 we can rewrite S(C, F) equivalently as a boolean combination of wffs S(C₁, C₂) with no U appearing and wffs of the form either:

- S(C₁, C₂ ∨ ±U(A, B)), or
- S(C₁ ∧ ±U(A, B), C₂ ∨ ±U(A, B)),

for some boolean combinations C₁ and C₂ of atoms and pure past formulae. Now the preceding lemma shows that each such boolean constituent is equivalent to a boolean combination of formulae of the following three forms:

- S(X, Y) where X and Y are built from C₁, C₂, A, and B just using S and not U,
- C₁, C₂, A, and B, and
- U(A, B).

Thus we have a separated equivalent. □

Next let us begin the inductive process of removing Us from under Ss. We break the induction into a series of step-by-step lemmas.

First consider the case of one level of U beneath Ss and where U only appears in copies of one subformula U(A, B).

**Lemma 10.2.5** Suppose that A and B are wffs built without S or U and that the only appearance of U in the wff D is as U(A, B).

Then D is equivalent to a syntactically separated wff in which U only appears as the formula U(A, B).

*Proof.* By induction on the maximum number k of nested Ss above any U(A, B).

*Case k = 0:* In this case D is already separated.

*Case k > 0:* Apply the preceding lemma to each of the most deeply nested S(C, F) in which U(A, B) appear and then we have an equivalent wff in which the maximum depth of nesting of U(A, B) is reduced. Note also that U still only appears in the form U(A, B). The induction hypothesis then gives us the result.

□

Now consider one level of U beneath Ss.

**Lemma 10.2.6** For each i = 1, ..., n let Aᵢ and Bᵢ be wffs built without S or U. Suppose that the only appearances of U in the wff D are in the form U(Aᵢ, Bᵢ).

Then D is syntactically separable.

*Proof.* Proceed by induction on n:

*Case n = 1:* This is the preceding lemma.

*Case n > 1:* First we separate only for U(Aₙ, Bₙ). For each i = 1, ..., n−1, we start this by replacing each appearance of U(Aᵢ, Bᵢ) by a new atom qᵢ to obtain a wff D'. The preceding lemma gives us syntactically separated E' equivalent to D' with U appearing only as U(Aₙ, Bₙ).

E' is separated and so is a boolean combination of atoms, of pure future wffs (i.e. U(Aₙ, Bₙ)) and pure past wffs Dⱼ which are built from atoms including q₁, ..., qₙ₋₁, those in Aₙ, and Bₙ, and others of D. Note that U(Aₙ, Bₙ) does not appear in any Dⱼ. Now substitute U(Aᵢ, Bᵢ) for each qᵢ (i = 1, ..., n − 1) in each Dⱼ and, using the induction hypothesis, separate them. Also substituting U(Aᵢ, Bᵢ) for any other qᵢs gives us our result.

□

Next we allow nestings of Us beneath nestings of Ss but no S within a U.

**Lemma 10.2.7** Suppose that wff D contains no S nested within a U. Then D is syntactically separable.

*Proof.* By induction on the maximum depth n of nesting of Us beneath an S.

*Case n = 1:* This is the case of the preceding lemma.

*Case n > 1:* Let U(Aᵢ, Bᵢ) (i = 1, ..., N) be some subformulae of D such that every appearance of U in D is as a subformula of an appearance of one of the U(Aᵢ, Bᵢ). Each Aᵢ and Bᵢ are built up as a boolean combination from wffs of the form U(Xᵢⱼ, Yᵢⱼ) and atoms. Replace each U(Xᵢⱼ, Yᵢⱼ) in Aᵢ and Bᵢ by the new atom zᵢⱼ to form wffs A'ᵢ and B'ᵢ which are just boolean combinations of atoms. Thus when we substitute zᵢⱼ by U(Xᵢⱼ, Yᵢⱼ) in A'ᵢ and B'ᵢ we obtain Aᵢ and Bᵢ respectively.

Replace each occurrence of U(Aᵢ, Bᵢ) (which is not contained within another U(Aᵢ, Bᵢ)) in D by U(A'ᵢ, B'ᵢ) to obtain D', which can be separated by the preceding lemma. Let E' be its separated form. E' will be a boolean combination of atoms (including the zᵢⱼ), pure future formulae (like U(A'ᵢ, B'ᵢ)) and pure past formulae (for example A'ᵢs and B'ᵢs nested under Ss). Furthermore, when we substitute in zᵢⱼ by U(Xᵢⱼ, Yᵢⱼ) we obtain a wff E equivalent to D.

Unfortunately, E is not separated: what were pure past formulae in E' have become, on replacement of zᵢⱼ by U(Xᵢⱼ, Yᵢⱼ), impure. To correct this we use the induction hypothesis on each of these pure past subformula of E. It is clear that we can do so as the level of nesting of U in U(Aᵢ, Bᵢ) must be strictly greater than that in its subformula U(Xᵢⱼ, Yᵢⱼ).

□

**Lemma 10.2.8** Any wff of the language with U and S is syntactically separable over the integer flow of time.

*Proof.* We first introduce some notation. Suppose that B is a subformula of wff A in the language with U and S. We can define the *junction depth* (≥ 0) of an appearance B in A as follows. If C₁, ..., Cₙ are subformulae of A such that

- B is a subformula of C₁,
- each Cᵢ is a subformula of Cᵢ₊₁,
- each Cᵢ is either an Until (of the form U(D, E)) or a Since (of the form S(D, E)), and
- the Cᵢs alternate between Until's and Since's

then the junction depth of the appropriate appearance of B in A is at least n. If the junction depth of a certain appearance of B in A is at least n but not at least n + 1, then it is n. The junction depth of a wff is the maximum junction depth of any of its appearances of subformulae.

For example, in

```
S(a ∧ U(A, S(C, D)), S(S(C, D), E))
```

the junction depth of the first appearance of C is 3 while its second appearance has junction depth 1. The junction depth of the whole formula is 3.

Now we begin the proof, being given a wff D. We proceed by induction on the junction depth of D.

If it is zero or one then D is already syntactically separated. So assume the induction hypothesis and that the junction depth of D is at least two.

D is a boolean combination of atoms, wffs of the form S(D₁, D₂) and wffs of the form U(D₁, D₂). We are done when we syntactically separate the latter two forms. Because of the dual nature of the results so far we need only demonstrate the syntactic separation of a wff of the form S(D₁, D₂).

Let U(Aᵢ, Bᵢ) (i = 1, ..., N) be the subformulae covering the maximal appearances of U, i.e. every appearance of U in D is as a subformula of an appearance of one of the U(Aᵢ, Bᵢ).

Since the junction depth of D is at least two, there are some subformulae of some U(Aᵢ, Bᵢ) which are of the form S(E, F). Replace each maximal such subformula in U(Aᵢ, Bᵢ) by its own new atom zᵢⱼ to obtain U(A'ᵢ, B'ᵢ). Change S(D₁, D₂) into E' by replacing each U(Aᵢ, Bᵢ) by U(A'ᵢ, B'ᵢ). The preceding lemma now tells us how to separate E' into a wff E'₁.

If we resubstitute the original wffs for each zᵢⱼ then we will have a formula equivalent to S(D₁, D₂) but of one less junction depth and we may use the induction hypothesis.

□

**Theorem 10.2.9** (Separation Theorem) Each wff in the language with {U, S} is equivalent, over the integer flow of time, to a separated wff.

*Proof.* This follows directly from the preceding lemma because, as we have already noted, syntactic separation implies separation. □

**Theorem 10.2.10** The language {U, S} is *expressively complete* over integer time.

*Proof.* This follows from the separation theorem and the results of chapter 9. □

## 10.3 Separation for U and S over Dedekind Complete Time
