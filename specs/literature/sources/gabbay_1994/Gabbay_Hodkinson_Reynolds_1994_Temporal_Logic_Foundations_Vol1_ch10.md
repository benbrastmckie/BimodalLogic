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

### 10.3.1 Introduction

To show separation over Dedekind complete time, we follow a similar procedure for eliminating occurrences of S from under the scope of a U and U from under S to that we have just finished above. Here the elimination and induction is slightly more complicated.

We will need to consider some new connectives:

- K⁺q = ¬U(⊤, ¬q), and
- K⁻q = ¬S(⊤, ¬q).

We have K⁺q true at t iff q is true arbitrarily close to t from the future, i.e.:

‖K⁺q‖ₜ = 1 iff ∀z > t, ∃y (t < y < z ∧ ‖q‖ᵧ = 1).

Similarly,

‖K⁻q‖ₜ = 1 iff ∀z < t, ∃y (z < y < t ∧ ‖q‖ᵧ = 1).

In integer time, these connectives are not very interesting for K⁺q = K⁻q = ⊤.

Now consider the wff PK⁺q. This wff is actually pure past — its truth at time t depends only on the behaviour of q in the past of t. More generally, if we build any wff out of S, K⁻, K⁺ only, we will obtain a pure past wff as long as any K⁺ is under the scope of an S (or a K⁻). The reason for this last restriction is that K⁺q itself is pure future, but under the scope of any S it does no harm since it expresses 'local' properties.

Thus, in doing eliminations as we did in the last section, we may leave K⁺ within the scope of an S, and still have a separated wff. This is just as well for in the language with just U and S it is impossible to rewrite such wffs as PK⁺q in such a way that there is no U in the scope of an S and vice versa.

In order to make our lives easier we will extend our temporal language to include K⁺ and K⁻ as connectives. It is clear that, since these new connectives can be defined in terms of U and S, separation and expressive completeness either hold for both or fail for both the temporal language with just U and S and its extension, which includes the K±.

Now it is possible to define syntactic separation in this extended language and then go through the eliminations and inductions to prove that any wff can be syntactically separated. However, for the benefit of the next chapter, we are going to make things slightly more complicated.

We will introduce still more connectives (Γ±), use a special atom (c) whose interpretation is restricted, and keep a close watch on how we go about rewriting wffs when we separate them. All this extra machinery means more work in this chapter (for example the Γ± eliminations are really redundant here) but saves us work in chapter 11.

First we define

**Definition 10.3.1**

Γ⁺(B) = ¬K⁺(¬B) ∧ K⁻(¬B)

and

Γ⁻(B) = ¬K⁻(¬B) ∧ K⁺(¬B).

Again note that the expressive power has clearly not been increased from that of U and S.

Next we introduce a new atom c and require that it is always interpreted *relatively densely* in the linear order, i.e. c is true somewhere in each interval of the form

- (a, b] = {z ∈ T | a < z ≤ b}, or
- [a, b) = {z ∈ T | a ≤ z < b},

for a < b from T. This seeming restriction on the structures which we are looking at is not really one in this chapter, as to any temporal structure we can add c to the language and interpret it as true everywhere. We do have

**Lemma 10.3.2** Over Dedekind complete time with c interpreted relatively densely K⁺(A) ↔ ¬U(c, ¬A) and the dual result.

In the rest of this chapter we will work in the language with connectives {U, S, K±, Γ±} and a special atom c. All equivalences will be valid in Dedekind complete structures with c interpreted relatively densely.

**Definition 10.3.3** A wff of {U, S, K±, Γ±} is *syntactically separated* iff it is a boolean combination of wffs of the form:

- atoms,
- U(A, B) without S,
- S(A, B) without U,
- K⁺(A) without S, and
- K⁻(A) without U.

For example, K⁺(S(p, q)) is not syntactically separated but S(K⁺(S(p, q)), r) is.

Note that Γ± must only appear nested below other temporal connectives.

**Lemma 10.3.4** Syntactic separation implies separation.

*Proof.* It is not difficult to prove by induction on the construction of any wff A of {U, S, K±, Γ±} that

- if A does not contain S then its truth at t ∈ T is determined by any s < t along with the interpretation of the atoms on {u ∈ T | s < u},
- and dually for U.

Then, given any wff U(A, B) with A and B not containing S, we know that its truth at t ∈ T depends just on the valuations of A and B at points > t but by the above these are determined by the interpretation of the atoms on {u ∈ T | t < u}, i.e. on the future of t.

And similarly for the other cases. □

### 10.3.2 Pre-eliminations

As before we have a useful negation lemma:

**Lemma 10.3.5** The following hold over Dedekind complete flows of time:

- ¬U(A, B) ↔ K⁺(¬B) ∨ ¬U(A, ⊤) ∨ U(¬A ∧ ¬B, ¬A) ∨ U(¬A ∧ Γ⁻(B), ¬A),
- ¬S(A, B) ↔ K⁻(¬B) ∨ ¬S(A, ⊤) ∨ S(¬A ∧ ¬B, ¬A) ∨ S(¬A ∧ Γ⁺(B), ¬A).

Now let us look more closely at the basic eliminations which we will need to carry out. Our elimination procedure may disregard any K⁺ in the scope of S or K⁻. However, since K± are allowed in the scope of S, a U may be under the scope of a K⁺ or a K⁻ which is itself in the scope of an S. Thus we must pull the U out of the scope of the K±, in order to pull it out further from under the scope of S. For example, in S(a ∧ K⁻(p ∧ U(A, B)), q) we must obtain the U out of the scope of K⁻ and then out of the scope of S.

Because of facts like K⁺(p ∨ q) being equivalent to K⁺(p) ∨ K⁺(q) it turns out that, in addition to the eight cases of eliminations needed for the integers, for this section we have to consider the four additional elimination cases seen in lemma 10.3.8.

We need similar results for Γ± but first a technical lemma:

**Lemma 10.3.6** Let Q(A, B, C) be the abbreviation

[C ⇒ ¬K⁺(¬B)]
∧ [(¬B ∨ Γ⁻(B)) ⇒ (S(C, ¬A) ⇒ A)].

1. If
   - ∀z ∈ (t₀, t₁), ‖C ⇒ U(A, B)‖_z = 1,
   - and ‖[(A ∧ ¬C) ∨ K⁺(A) ∨ U(A, B)]‖_{t₀} = 1,

   then ∀z ∈ (t₀, t₁), ‖Q(A, B, C)‖_z = 1.

2. If
   - ∀z ∈ (t₀, t₁), ‖Q(A, B, C)‖_z = 1,
   - and ‖A ∨ K⁻(A) ∨ (B ∧ U(A, B))‖_{t₁} = 1,

   then ∀z ∈ (t₀, t₁), ‖C ⇒ U(A, B)‖_z = 1.

*Proof.* Let Q = Q(A, B, C).

1. Suppose the conditions are true and z ∈ (t₀, t₁). If ‖C‖_z = 1 then ‖U(A, B)‖_z = 1 so we certainly have ‖¬K⁺(¬B)‖_z = 1.

   Assume ‖(¬B ∨ Γ⁻(B))‖_z = 1 and ‖S(C, ¬A)‖_z = 1. We show that ‖A‖_z = 1.

   There is u < z with ‖C‖_u = 1 and for all w ∈ (u, z), ‖¬A‖_w = 1. There are two cases:

   - u < t₀: when the initial conditions on t₀ imply that ‖U(A, B)‖_{t₀} = 1. Put u = t₀.
   - t₀ < u < z: when C being true at u implies that ‖U(A, B)‖_u = 1.

   In each case, since A is not true between u (where U(A, B) holds) and z, and B does not remain true past z, we must have A true at z, as required.

2. Suppose the conditions are true and z ∈ (t₀, t₁). Assume that ‖C‖_z = 1 and we show that ‖U(A, B)‖_z = 1.

   Let y = sup{z' ∈ (z, t₁) | for all u ∈ (z, z'), ‖B‖_u = 1}. Since ‖¬K⁺(¬B)‖_z = 1 we know that y exists and is > z. There are two cases:

   - z < y < t₁: Now we have either ¬B or Γ⁻(B) holding at y and thus, since Q also holds there we have ‖S(C, ¬A) ⇒ A‖_y = 1. If A is true anywhere between z and y then we are done (as B holds everywhere on that interval) but otherwise we have A holding at y (since S(C, ¬A) does) and we are again finished.
   - y = t₁: when it follows directly from the initial conditions on t₁ that U(A, B) is true at z as required.

□

**Lemma 10.3.7** The following hold over Dedekind complete flows of time:

- K⁺(A ∨ B) ↔ K⁺A ∨ K⁺B,
- K⁻(A ∨ B) ↔ K⁻A ∨ K⁻B.

Let us perform the four eliminations for U beneath K± first:

**Lemma 10.3.8** Over Dedekind complete time we have the following equivalences in which the abbreviation Q(A, B, p) is as defined in the Q lemma. Note that in the results U only appears as U(A, B) and not under S, K± or Γ±.

1. K⁺(p ∧ U(A, B))
   ↔ [K⁺p ∧ U(A, B)] ∨ [K⁺p ∧ K⁻(A ∧ S(p, B))].

2. K⁻(p ∧ U(A, B))
   ↔ [K⁻p ∧ A ∧ ¬K⁻(¬B)]
   ∨ [K⁻p ∧ ¬K⁻(¬B) ∧ B ∧ U(A, B)]
   ∨ [K⁻p ∧ K⁻(S(p, B) ∧ A)].

3. K⁺(p ∧ ¬U(A, B))
   ↔ K⁺p ∧ ¬U(A, B) ∧ [¬K⁺A ∨ K⁺(¬Q(A, B, p))].

4. K⁻(p ∧ ¬U(A, B))
   ↔ [K⁻p ∧ K⁻(¬Q(A, B, p))]
   ∨ [K⁻p ∧ ¬(A ∨ K⁻A ∨ (B ∧ U(A, B)))].

*Proof.* These are all very straightforward semantic arguments, the last two of which are simplified somewhat by use of the Q lemma. □

Notice that we sometimes don't end up with a syntactically separated wff after using the above equivalences: for example S appears (in Q) beneath K⁺ in the third. This doesn't matter in the proof where we just require the U(A, B) to be removed from beneath the K±.

Next the Γs.

**Lemma 10.3.9**

Γ⁺(A ∧ B) ↔ [Γ⁺(A) ∧ ¬K⁺(¬B)] ∨ [Γ⁺(B) ∧ ¬K⁺(¬A)],

and similarly Γ⁻(A ∧ B).

**Lemma 10.3.10** Each wff below is equivalent (over Dedekind complete time) to a wff in which U only appears as U(A, B) and is not nested beneath S, K±, or Γ±:

1. Γ⁻(q ∨ U(A, B));
2. Γ⁺(q ∨ U(A, B));
3. Γ⁻(q ∨ ¬U(A, B));
4. Γ⁺(q ∨ ¬U(A, B)).

Dual results with Γ⁺ exchanged with Γ⁻ and U exchanged with S hold.

In fact, we have:

1. Γ⁻(q ∨ U(A, B))
   ↔ [Γ⁻(q) ∧ ¬U(A, B) ∧ (¬K⁺(A) ∨ K⁺(¬Q))]
   ∨ [K⁺(¬q) ∧ ¬U(A, B) ∧ (¬K⁺(A) ∨ K⁺(¬Q)) ∧ ¬K⁻(¬Q) ∧ A]
   ∨ [K⁺(¬q) ∧ ¬U(A, B) ∧ Γ⁻(¬A) ∧ ¬K⁻(¬Q)]
   ∨ [K⁺(¬q) ∧ ¬U(A, B) ∧ Γ⁻(Q) ∧ K⁻(A)].

2. Γ⁺(q ∨ U(A, B))
   ↔ [Γ⁺(q) ∧ K⁻(¬Q)]
   ∨ [Γ⁺(q) ∧ ¬A ∧ ¬K⁻(A) ∧ (¬B ∨ ¬U(A, B))]
   ∨ [U(A, B) ∧ K⁻(¬q) ∧ ¬K⁻(¬Q) ∧ (¬B ∨ Γ⁻(B))]
   ∨ [U(A, B) ∧ K⁻(¬q) ∧ ¬A ∧ ¬K⁻(A) ∧ ¬B]
   ∨ [K⁺(A) ∧ Γ⁻(Q) ∧ K⁻(¬q)]
   ∨ [Γ⁻(¬A) ∧ ¬K⁺(¬Q) ∧ K⁻(¬q) ∧ ¬A ∧ (¬B ∨ ¬U(A, B))].

3. Γ⁻(q ∨ ¬U(A, B))
   ↔ [Γ⁻(q) ∧ U(A, B)]
   ∨ [Γ⁻(q) ∧ K⁺(A ∧ S(¬q, B))]
   ∨ [(¬A ∨ K⁻(¬B))
   ∧ ((Γ⁻(B) ∨ ¬B) ∧ ¬K⁻(S(¬q, B) ∧ A) ∧ K⁺(¬q) ∧ U(A, B))
   ∨ (¬(¬K⁻(¬B) ∧ B ∧ U(A, B))
   ∧ Γ⁻(¬A ∨ ¬S(¬q, B)) ∧ K⁺(¬q))].

4. Γ⁺(q ∨ ¬U(A, B))
   ↔ [Γ⁺(q) ∧ A ∧ ¬K⁻(¬B)]
   ∨ [Γ⁺(q) ∧ ¬K⁻(¬B) ∧ B ∧ U(A, B)]
   ∨ [Γ⁺(q) ∧ K⁻(S(¬q, B) ∧ A)]
   ∨ [K⁻(¬q) ∧ ¬U(A, B) ∧ ¬K⁺(A ∧ S(¬q, B) ∧ A ∧ ¬K⁻(¬B))]
   ∨ [K⁻(¬q) ∧ ¬U(A, B) ∧ Γ⁺(¬A ∨ ¬S(¬q, B))].

*Proof.* Rewrite Γ± in terms of K± and use the K± eliminations. Then rearrange and reform some Γ±s. □

### 10.3.3 Eliminations

Remember that the simple equivalences of lemma 10.2.1, such as that involving S(A ∨ B, C), hold in any linear order.

Now we consider the cases of elimination which were also seen in the integer separations.

**Lemma 10.3.11** Consider the following wffs with a, q, A, and B being atoms:

1. S(a ∧ U(A, B), q),
2. S(a ∧ ¬U(A, B), q),
3. S(a, q ∨ U(A, B)),
4. S(a, q ∨ ¬U(A, B)),
5. S(a ∧ U(A, B), q ∨ U(A, B)),
6. S(a ∧ ¬U(A, B), q ∨ U(A, B)),
7. S(a ∧ U(A, B), q ∨ ¬U(A, B)), and
8. S(a ∧ ¬U(A, B), q ∨ ¬U(A, B)).

Over Dedekind complete time each of the above wffs can be syntactically separated in such a way that the only appearance of U in the separated wff is as U(A, B).

*Proof.*

1. In this case, the wff here is equivalent to the same wff obtained in the case of the integers in lemma 10.2.3, i.e. S(a ∧ U(A, B), q) is equivalent to

   [S(a, q) ∧ S(a, B) ∧ B ∧ U(A, B)]
   ∨ [A ∧ S(a, B) ∧ S(a, q)]
   ∨ S(A ∧ q ∧ S(a, B) ∧ S(a, q), q).

2. It is straightforward to show that S(a ∧ ¬U(A, B), q)
   ↔ S(K⁺(¬B) ∧ a, q)
   ∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)
   ∨ S(¬A ∧ Γ⁻(B) ∧ q ∧ S(a, ¬A ∧ q), q)
   ∨ [S(a, ¬A ∧ q) ∧ ¬A ∧ (¬B ∨ ¬U(A, B))].

3. Below we show that S(a, U(A, B) ∨ q)
   ↔ S(a, q)
   ∨ [S(α, Q) ∧ β]
   ∨ S(A ∧ (q ∨ U(A, B)) ∧ S(α, Q), q)
   ∨ S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q),

   where

   α = a ∨ ((¬q ∨ Γ⁻(q)) ∧ S(a, q) ∧ (q ∨ U(A, B))),

   and

   β = A ∨ K⁻(A) ∨ [B ∧ U(A, B)].

   Elimination (1) used several times will give us separation.

   Let us outline the proof of the equivalence above:

   (⇒) Assume that S(a, U(A, B) ∨ q) holds at t. So there is s < t such that ‖a‖_s = 1 and U(A, B) ∨ q is true everywhere between s and t.

   Let

   L = {z ∈ (s, t) | ∀y ∈ (s, z), ‖q‖_y = 1},

   l = sup L (or l = s if L is empty),

   R = {z ∈ (s, t) | ∀y ∈ (z, t), ‖q‖_y = 1}

   and r = inf R (or r = t if R is empty).

   If L = (s, t) then ‖S(a, q)‖_t = 1 and we are done. So suppose that l < t.

   Clearly, l < r < t. Now either s = l so the first disjunct of α holds at l or s < l so the second holds. In each case K⁺(A) ∨ U(A, B) is true at l. We thus have S(α, Q) true at r.

   There are three cases:

   - r = t: Now we must have K⁻(¬q) true at t so K⁻(U(A, B)) also. This implies β and hence S(α, Q) ∧ β holds at t.
   - r < t and U(A, B) is false at r: We must have q true at r but since r = inf R we need also have Γ⁺(q) true here. Because K⁻(¬q) so K⁻(U(A, B)) holds and we have A ∨ K⁻(A). Thus S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q) holds at t and we finish.
   - r < t and U(A, B) holds at r: Suppose that w > r witnesses the until. It is clear then that Q is true at r and up until w so we have further sub-cases:
     - r < w < t: S(A ∧ S(α, Q), q) holds at t.
     - t ≤ w: Now A ∨ (B ∧ U(A, B)) holds at t so we have S(α, Q) ∧ β there.

   (⇐) Suppose that one of the four disjuncts holds at t. It is clear that if the first does then S(a, U(A, B) ∨ q) holds at t, as required. Now consider the cases of the other disjuncts holding.

   If the second disjunct holds put u = t and β holds here.

   If the third or fourth disjuncts hold let u < t witness the since so we have either A or K⁻(A) holding at u and q true between u and t.

   In each case we have a point u < t with ‖S(α, Q)‖_u = 1 and various other truth conditions depending on the case. Thus there is v < u where a holds and Q is true everywhere on (v, u). Either a holds at v when we put s = v or, if the other disjunct of α holds at v, there is s < v witnessing S(a, q).

   We are done when we show that q ∨ U(A, B) holds everywhere in (s, t). Consider z from this interval.

   - If s < z < v then q holds at z.
   - If s < z = v then q ∨ U(A, B) holds.
   - If v < z < u then since Q holds on (v, u) and β holds at u we have the Q lemma implying q ∨ U(A, B) at z.
   - If z = u < t then we have disjuncts three or four holding and the desired result.
   - If u < z < t then we have q true at z and we are done.

4. S(a, ¬U(A, B) ∨ q)
   ↔ ¬[ K⁻(U(A, B) ∧ ¬q)
   ∨ ¬S(a, ⊤)
   ∨ S(¬a ∧ U(A, B) ∧ ¬q, ¬a)
   ∨ S(¬a ∧ Γ⁺(¬U(A, B) ∨ q), ¬a) ]

   By lemma 10.3.3 the first disjunct can be separated. By the first elimination the third disjunct can be separated and by lemmas on Γ± and elimination (1) or (2) the fourth disjunct can be separated.

5. To separate S(a ∧ U(A, B), q ∨ U(A, B)) use elimination (3) to rewrite it equivalently as

   S(a ∧ U(A, B), q)
   ∨ [S(α, Q) ∧ β]
   ∨ S(A ∧ (q ∨ U(A, B)) ∧ S(α, Q), q)
   ∨ S(Γ⁺(q) ∧ q ∧ (A ∨ K⁻(A)) ∧ S(α, Q), q),

   where Q = Q(A, B, ¬q),

   α = (a ∧ U(A, B))
   ∨ ((¬q ∨ Γ⁻(q)) ∧ S(a ∧ U(A, B), q) ∧ (q ∨ U(A, B))),

   and

   β = A ∨ K⁻(A) ∨ [B ∧ U(A, B)].

   The first elimination will separate the first disjunct and the expression α. Further use of that elimination will separate S(α, Q) and finally also the expression which the latter is nested within.

6. To separate S(a ∧ ¬U(A, B), q ∨ U(A, B)) use elimination (3) and then elimination (2) in a similar manner to the preceding elimination.

7. S(U(A, B) ∧ a, ¬U(A, B) ∨ q)
   ↔ S(a, B ∧ q) ∧ (A ∨ (B ∧ U(A, B)))
   ∨ S(S(a, B ∧ q) ∧ A ∧ (q ∨ ¬U(A, B)), ¬U(A, B) ∨ q).

   We then use the eighth and fourth eliminations.

8. S(¬U(A, B) ∧ a, ¬U(A, B) ∨ q)

   ↔ ¬[ K⁻(U(A, B) ∧ ¬q)
   ∨ ¬S(¬U(A, B) ∧ a, ⊤)
   ∨ S((U(A, B) ∨ ¬a) ∧ U(A, B) ∧ ¬q, U(A, B) ∨ ¬a)
   ∨ S((U(A, B) ∨ ¬a) ∧ Γ⁺(¬U(A, B) ∧ q), U(A, B) ∨ ¬a) ].

   This can be separated by lemmas 10.3.3, and eliminations (2) and (5).

□

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
