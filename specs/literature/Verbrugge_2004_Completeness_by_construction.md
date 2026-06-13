# Completeness by Construction for Tense Logics of Linear Time

**Dick de Jongh, Frank Veltman, Rineke Verbrugge**

*ILLC University of Amsterdam & AI Groningen*

---

## 1 Introduction

It is rather unusual for the recipient of a Liber Amicorum to be the co-author of one of the contributions. With this article such a strange situation does occur, but hopefully without the recipient knowing anything about it until he received this Liber Amicorum.

The present article is based on a manuscript written by the three of us in the mid-eighties, when Rineke Verbrugge, then an undergraduate student, took a course on intensional logics by Dick de Jongh and Frank Veltman, and tried to apply their "constructive" method to tense logics for linear discrete structures consisting of a number of consecutive copies of **Z**. This constructive method had been developed in the seventies and was in wide use in Amsterdam, where several researchers contributed to it. The method was used to prove completeness of many tense logics (see e.g. [1, Theorem II.2.3.18] for a completeness proof of the logic for the rationals using "construction by finite stages" and [4] for many examples that also appear in this paper), of conditional logics, and of interpretability logics [5].

Even though the standard way to prove completeness for tense logics is the one pioneered by Segerberg [6], using filtration and transformations like bulldozing on canonical models, Burgess has always been a proponent of the constructive method [3], which has lately found its way into standard modal logic texts as the step-by-step-method [2].

In the mid-eighties, we were rather ambitious and wanted to characterize all complete tense logics of discrete and dense time. In the second edition of *The Logic of Time*, Van Benthem even announced that we had succeeded to do so in our unpublished "All logics for dense and discrete linear time" [1, Addenda and corrigenda]. The manuscript was promptly hidden in a deep drawer.

In the present version, composed by Rineke Verbrugge and Frank Veltman, the goal of the paper is more modest: simply to present some short and elegant step-by-step completeness proofs for some interesting tense logics for dense and discrete linear time.

## 2 Preliminaries

In the literature (e.g. [6]) one can find a number of tense-logical systems, here called **Lin**, **P**, **D**, **Z**, **Q** and **R**, which in this order have been proved to be complete with respect to all linear time structures, all successive (i.e. satisfying ∀x∃y(x < y) and ∀x∃y(x > y)) time structures, all successive discrete time structures, and the specific structures **Z**, **Q** and **R**. Of course, **D** and **Q** are both extensions of **P**, **Z** is an extension of **D**, and **R** is an extension of **Q**. The logic **Q** is also the logic that is complete with respect to all dense, successive linear time structures.

We will describe a number of interesting tense-logical extensions of **D** and **Q**. We have chosen for our logic **D** for discrete time to include the axioms P⊤ and F⊤ expressing successiveness to avoid some uninteresting complications which would otherwise ensue. Since our completeness proofs for the new logics to be introduced depend to a large extent on the manner of proof we use in the completeness proofs for the above mentioned well-known logics we will start in section 3 with giving the latter, even though the results are not new.

In addition to the usual truth-functional connectives, including ⊤ and ⊥, we use G and H. The operators F, P and □ are defined: Fϕ standing for ¬G¬ϕ, Pϕ for ¬H¬ϕ, and □ϕ for Hϕ ∧ ϕ ∧ Gϕ. The language will always be considered to be countable. The rules of all the systems are, as usual, modus ponens and necessitation, for G as well as for H. The axioms and rules for the different systems are as follows:

### Axiom schemas for Lin:

1. All tautologies.
2. (a) G(ϕ → ψ) → (Gϕ → Gψ)
   (b) H(ϕ → ψ) → (Hϕ → Hψ)
3. (a) PGϕ → ϕ
   (b) FHϕ → ϕ
4. Gϕ → GGϕ
5. (a) Fϕ → G(ϕ ∨ Pϕ ∨ Fϕ)
   (b) Pϕ → H(ϕ ∨ Pϕ ∨ Fϕ)

### Rules for all systems:

1. ϕ, ϕ → ψ ⊢ ψ
2. If ⊢ ϕ then ⊢ Gϕ
3. If ⊢ ϕ then ⊢ Hϕ

### Additional successiveness axioms for P over Lin:

- **(P1)** ¬H⊥
- **(P2)** ¬G⊥

### Additional density axiom for Q over P:

- **(Q)** GGϕ → Gϕ

### Additional discreteness axioms for D over P:

- **(D1)** (ϕ ∧ Gϕ) → PGϕ
- **(D2)** (ϕ ∧ Hϕ) → FHϕ

### Additional continuity axiom for R over Q as well as for Z over D:

- **(R)** (Gϕ → PGϕ) → (Gϕ → Hϕ)

A well-known alternative axiomatization for **Z** over **P** consists of:

- **(Z1)** G(Gϕ → ϕ) → (FGϕ → Gϕ)
- **(Z2)** H(Hϕ → ϕ) → (PHϕ → Hϕ)

It is well-known that these axioms are indeed characteristic of the structural properties mentioned, see e.g. [3, 1].

The following definition and basic facts are often used in completeness proofs. Let S be one of the tense logics defined above.

**Definition 1** (Maximal consistent set). A set of formulae Γ is *maximal S-consistent* if it is S-consistent and for all Γ′ ⊃ Γ, Γ′ is not S-consistent.

**Lemma 1** (Lindenbaum Lemma). For all S-consistent sets Γ, there exists a maximal S-consistent set Γ′ ⊇ Γ.

*Proof:* standard, see e.g. [2]. ∎

**Proposition 1.** The logic **Lin** proves the following equivalences:

- G(ϕ ∧ ψ) ↔ (Gϕ ∧ Gψ)
- H(ϕ ∧ ψ) ↔ (Hϕ ∧ Gψ)
- F(ϕ ∨ ψ) ↔ (Fϕ ∨ Fψ)
- P(ϕ ∨ ψ) ↔ (Pϕ ∨ Pψ)

## 3 Proofs of Strong Completeness for Lin, P, Q, R and D

The variables Γ, Δ, with or without subscripts, will in this section always run over maximal consistent sets in the system under consideration. Σ is used as a variable over arbitrary sets of formulae.

**Definition 2.** Γ ≺ Δ iff for each Gϕ ∈ Γ, ϕ ∈ Δ.

**Lemma 2.** The following three conditions are equivalent to Γ ≺ Δ:

- (i) for each ϕ ∈ Δ, Fϕ ∈ Γ,
- (ii) for each Hϕ ∈ Γ, ϕ ∈ Δ,
- (iii) for each ϕ ∈ Γ, Pϕ ∈ Γ.

*Proof:* Easy and well-known. ∎

**Definition 3.** A relation R is:

- (i) *not branching towards the future* if ∀x, y, z((xRy ∧ xRz) → (yRz ∨ y = z ∨ zRy)),
- (ii) *not branching towards the past* if ∀x, y, z((xRy ∧ yRz) → (xRy ∨ x = y ∨ yRx)),
- (iii) *not branching* if not branching towards the future and not branching towards the past.
- (iv) a *strict linear order* if it is transitive, irreflexive and connected (∀x, y, z(xRy ∨ yRx ∨ x = y)).

**Lemma 3.**

- (i) For any modal logic S the relation ≺ over maximal S-consistent sets is:
  - (a) not branching towards the future if (L1) ∈ S,
  - (b) not branching towards the past if (L2) ∈ S,
  - (c) successive if (P1), (P2) ∈ S,
  - (d) transitive if (4) ∈ S.
- (ii) if (4) ∈ S, then Γ ≺ Δ ⇒ (Gϕ ∈ Γ ⇒ Gϕ ∈ Δ)
- (iii) if (4) ∈ S, then Γ ≺ Δ ⇒ (Hϕ ∈ Δ ⇒ Hϕ ∈ Γ)

*Proof:* Well-known. ∎

Unfortunately, connectedness and irreflexivity are not expressible in the language of tense logic. That is the main reason why completeness proofs for linear tense logics are so complicated: the strict constraints on temporal structure cannot be captured in modal terms. Therefore, the structure underlying the canonical model is rather messy, and it takes a lot of work to show that it can be transformed into a linear ordering.

In the following we will take a different route: rather than distilling a model with the appropriate structure from the canonical model, we will construct it step by step starting from scratch.

**Lemma 4.**

- (i) For all systems considered, if ¬Gϕ ∈ Γ, there is some Δ such that Γ ≺ Δ, and ¬ϕ ∈ Δ.
- (ii) For all systems considered, if ¬Hϕ ∈ Γ, there is some Δ such that Δ ≺ Γ, and ¬ϕ ∈ Δ.

*Proof:* Well-known. ∎

**Theorem 1.** **Lin** is strongly complete with respect to all strict linear orderings.

*Proof:* Let Σ ⊬_Lin ϕ. It is sufficient to find a strictly linearly ordered set ⟨T, <⟩, with a maximal consistent set Γ_t associated to each t ∈ T in such a way that:

- (a) for some t\*, Γ_{t\*} is a maximal consistent extension of Σ ∪ {¬ϕ},
- (b) If t < t′, then Γ_t ≺ Γ_{t′},
- (c) if ¬Gϕ ∈ Γ_t, there is some t′ > t such that ¬ϕ ∈ Γ_{t′},
- (d) if ¬Hϕ ∈ Γ_t, there is some t′ < t such that ¬ϕ ∈ Γ_{t′}.

The frame ⟨T, <⟩ is constructed in stages. The construction is such that: for all n, after stage n there is a linearly ordered set T_n with a maximal consistent set Γ_t associated to each t ∈ T_n satisfying (a) and (b). Let ϕ₀, ϕ₁, ϕ₂, ... be an enumeration of all formulae in which each formula occurs infinitely many times.

**Stage 0:** T₀ = {t\*}, the associated Γ_{t\*} is taken to be a maximal consistent extension of Σ ∪ {¬ϕ}, which exists by the Lindenbaum Lemma 1.

**Stage n+1:** At this stage we take care of the formulae ¬Gϕ_n and ¬Hϕ_n for the points of T_n, i.e. new points with associated maximal consistent sets are added if that is necessary to insure (c) or (d) for some t ∈ T_n. We will just show how this is done for (c): (d) is analogous. There are three cases:

- If, for no t ∈ T_n, ¬Gϕ_n ∈ Γ_t, then there is nothing to do.
- If there is, assume t to be a maximal such point. (Note that, by Lemma 2.4(b), if ¬Gϕ_n ∈ Γ and t′ < t, then ¬Gϕ_n ∈ Γ_{t′}.)
  - If, for some t′ > t, ¬ϕ_n ∈ Γ_{t′}, then again there is nothing to do.
  - So, suppose for all t′ > t, ϕ_n ∈ Γ_{t′}. By Lemma 4, there is a Δ such that Γ ≺ Δ and ¬ϕ_n ∈ Δ. Add to T_n a node u as a new immediate successor to t with Δ = Γ_u. If t is maximal in T_n, then it is clear that we are done immediately. But if t is not maximal in T_n, we are done too. For, assume t′ to be the immediate successor of t in T_n, so Gϕ_n ∈ Γ_{t′} and ϕ_n ∈ Γ_{t′}. Then, since ≺ is not branching to the future, Γ_{t′} ≺ Δ or Γ_{t′} = Δ or Δ ≺ Γ_{t′}. The first case cannot apply, since Gϕ_n ∈ Γ_{t′} and ¬ϕ_n ∈ Δ, but neither can the second, because ϕ_n ∈ Γ_{t′} and ¬ϕ_n ∈ Δ; thus Δ ≺ Γ_{t′}. So, T_n ∪ {u} is linearly ordered and satisfies (b).

Finally, taking T = ⋃_{n ∈ ω} T_n obviously gives us a T which fulfills (a)-(d). ∎

**Theorem 2.** **P** is strongly complete with respect to all successive strict linear orderings.

*Proof:* The proof goes exactly the same as the proof of Theorem 1, except that when ϕ_n is ⊥, then, in stage n + 1 it is the case that for all t ∈ T_n, ¬Gϕ_n ∈ Γ_t, i.e. the maximal t in the proof such that ¬Gϕ_n ∈ Γ_t is maximal in T_n. This means that at each such stage a new point is created beyond all of T_n. Since the same thing happens when we consider ¬Hϕ_n, the constructed T will be successive. ∎

**Lemma 5.** For any tense logic S the relation ≺ over maximal S-consistent sets is dense if (Q) ∈ S.

*Proof:* Well-known. ∎

**Theorem 3.** **Q** is strongly complete with respect to **Q**.

*Proof:* Again the proof is very similar to the proof of Theorem 2. The only change we make is that the procedure of the above proof is just applied at the even stages (i.e. ϕ_n is treated at stage 2n + 2). This is sufficient to guarantee the satisfaction of Theorem 1 (a)-(d) in the limit.

At the odd stages density is taken care of as follows: Let t, u be any two successive points of T_n. A new point v between each such t and u is added. By Lemma 5 there exists a Δ such that Γ_t ≺ Δ ≺ Γ_u. We take Γ_v = Δ. Thus, the resulting linear order T will be dense. As we have assumed the language to be countable, T will also be countable and hence, because it is a successive linear order, by Cantor's theorem ⟨T, <⟩ is isomorphic to **Q**. ∎

**Theorem 4.** **R** is strongly complete with respect to **R**.

*Proof:* Since the axioms of **Q** are included in those of **R**, we can start the proof as the proof of Theorem 3 and obtain **Q** with associated maximal **R**-consistent sets satisfying (a)-(d). We now extend **Q** to **R** and adjoin to each irrational number r as its associated set a maximal consistent extension of

{ϕ | Gϕ ∈ Γ_q for some q < r} ∪ {ψ | Hψ ∈ Γ_q for some q > r}.

If this is possible, then the resulting structure will immediately satisfy (a), (b). To show that it is, we just have to show {ϕ | Gϕ ∈ Γ_q for some q < r} ∪ {ψ | Hψ ∈ Γ_q for some q > r} to be consistent.

Suppose it is not. Then, by Lemma 4 (b) and (c), and Proposition 1, there is some q < r and some q′ > r with some Gϕ ∈ Γ_q and Hψ ∈ Γ_{q′} such that ⊢_R ¬(ϕ ∧ ψ). However, there is some q″ with q < q″ < q′ for which then ϕ, ψ ∈ Γ_{q″}; so this is not possible.

What remains to prove is that the newly added points and their associates satisfy (c) and (d). We restrict ourselves to showing (c).

Assume, in contradiction with (c), that ¬Gϕ ∈ Γ_r and ϕ ∈ Γ_q for all q > r. As in Lemma 4 (b), ¬Gϕ ∈ Γ_q for all q < r. Moreover, because **Q** already satisfies (c), Gϕ ∈ Γ_q for all q > r and PGϕ ∈ Γ_q for all q > r. Again, because **Q** already satisfies (c), □(Gϕ → PGϕ) ∈ Γ_q for all q, whence by (R), Hϕ ∈ Γ_q for all q > r. This however, is inconsistent with the fact that ¬Gϕ ∈ Γ_r and hence ¬Gϕ ∈ Γ_q for some q < r and that **Q** satisfies (c) and (d). ∎

**Lemma 6.** If Γ is **D**-consistent, then so is {ϕ | Gϕ ∈ Γ} ∪ {¬ψ ∨ ¬Gψ | ¬Gψ ∈ Γ}.

*Proof:* Assume Γ is **D**-consistent, but {ϕ | Gϕ ∈ Γ} ∪ {¬ψ ∨ ¬Gψ | ¬Gψ ∈ Γ} is not. Then there are ϕ, ψ₁, ..., ψ_k ∈ Γ such that

⊢_D ϕ → (ψ₁ ∧ Gψ₁) ∨ ... ∨ (ψ_k ∧ Gψ_k).

It then follows,

⊢_D ϕ → PGψ₁ ∨ ... ∨ PGψ_k  (by D1),

⊢_D ϕ → P(Gψ₁ ∨ ... ∨ Gψ_k)  (by Proposition 1),

⊢_D Gϕ → GP(Gψ₁ ∨ ... ∨ Gψ_k)  (by necessitation and axiom 2a),

⊢_D Gϕ → (Gψ₁ ∨ ... ∨ Gψ_k) ∨ P(Gψ₁ ∨ ... ∨ Gψ_k)  (by the contrapositive of D2).

Now it follows from the axioms of **Lin** that P(Gψ₁ ∨ ... ∨ Gψ_k) → (Gψ₁ ∨ ... ∨ Gψ_k), so

⊢_D Gϕ → (Gψ₁ ∨ ... ∨ Gψ_k).

This last fact contradicts the consistency of Γ. ∎

**Theorem 5.** **D** is strongly complete with respect to the discrete, successive, strict linear orders.

*Proof:* As in the proof of the completeness of **Q**, at even stages we follow the line of the completeness proof for **Lin**. At each odd stage we assign an immediate successor u and an immediate predecessor v to each point t of T_n for which this has not been done at some previous stage. We will just show how to construct the associated set of the immediate successor u for some t from T_n in such a way that in the union these points will still be immediate successors, and hence a discrete, successive, linear ⟨T, <⟩ satisfying (a), (b), (c), (d) from the proof of Theorem 1 is constructed. We take Γ_u to be a maximal consistent extension of {ϕ | Gϕ ∈ Γ_t} ∪ {¬ψ ∨ ¬Gψ | ¬Gψ ∈ Γ_t} which by Lemma 6 is itself consistent. It will then never be necessary to introduce at an even stage a successor of t which is not a successor of u; for each ψ for which ¬Gψ ∈ Γ_t, either of the following two cases hold:

- also ¬Gψ ∈ Γ_u in which case the point which is constructed to verify ¬ψ will also be a successor of u, or
- ¬ψ ∈ Γ_t in which case there is no need to introduce a point to verify ¬ψ.

But neither will it ever be necessary to introduce a predecessor of u which is not a predecessor of t. For assume ¬Hψ ∈ Γ_u; we will show that ¬ψ ∨ ¬Hψ ∈ Γ_t. Suppose not, then ψ ∧ Hψ ∈ Γ_t. By (D2), FHψ ∈ Γ_t, i.e. ¬G¬Hψ ∈ Γ_t, whence by the construction, Hψ ∈ Γ_u or ¬G¬Hψ ∈ Γ_u. The first immediately contradicts the fact that Hψ ∈ Γ_t, but so does the second, since ⊢_Lin FHψ → Hψ. ∎

## 4 The Method C_adequate for Specific Discrete Structures

For the tense logic of the integers, compactness fails: there are infinite sets of formulae which are not satisfiable, despite the fact that all their finite subsets are. A counterexample for **Z** is provided by the set {FG¬p, Fp, FFp, FFFp, ...}. Thus, **Z** is not strongly complete with respect to the model **Z**.

The method we will use here for **Z** and logics for similar discrete structures is to use maximal consistent sets relativized to a specific class of finite sets of formulae (called *adequate sets*). This method was used in modal logic by Solovay (1973, unpublished) to prove the completeness of Lob's Provability logic **L** and was also in use in Amsterdam in the seventies and eighties for completeness proofs in modal and tense logic. It seems as if the method was "up in the air" during the early seventies and independently found by several researchers in different locations.

The method C_adequate, the step-by-step method restricted to finite sets of relevant formulae, has a wide range of applicability for proofs of completeness and decidability. The notion of an adequate set of formulae has to be specified for each completeness proof.

**Definition 4.** A set Σ of formulae is called *Z-adequate* iff

1. Σ is closed under forming subformulae;
2. Σ is closed under single negations (i.e. if ϕ ∈ Σ and ϕ is not of the form ¬ψ then ¬ϕ ∈ Σ);
3. Σ contains G⊥ and H⊥;
4. if Gϕ ∈ Σ and ϕ is not of the form ¬Gψ, then G¬Gϕ ∈ Σ;
   if Hϕ ∈ Σ and ϕ is not of the form ¬Hψ, then H¬Hϕ ∈ Σ.

The first two conditions classically appear in the definition of 'adequate' and condition (iii) is always added in case ¬G⊥ and ¬H⊥ occur among the axioms. In the following lemmas and definitions that will be used often in the sequel, let S be any of the tense logics extending **D** that we will introduce in this section.

**Lemma 7.** If Φ is finite, then the minimal S-adequate set of formulae containing Φ is also finite.

*Proof:* For each specific S, the definition of S-adequate set has been constructed in such a way that finiteness is preserved; we leave the proofs to the reader. ∎

**Definition 5.** Γ ⊆ Σ is *maximal S-consistent in the S-adequate set Σ*, if Γ is S-consistent and there are no S-consistent subsets of Σ properly extending Γ.

We have to redefine ≺ for these relativized maximal consistent sets.

**Definition 6.** Γ ≺ Δ if

- (i) for each Gϕ ∈ Γ, ϕ, Gϕ ∈ Δ
- (ii) for each Hϕ ∈ Δ, ϕ, Hϕ ∈ Γ

Conditions (i) and (ii) are standard for systems which contain Gϕ → GGϕ as an axiom, and are necessary if one strives for a transitive ordering. Note that in order to preserve finiteness, the definition of adequate set does not contain a clause like "if Gϕ ∈ Σ, then GGϕ ∈ Σ", so the axiom Gϕ → GGϕ cannot be directly used to take care of transitivity of ≺.

Note that in the relativized case, (ii) does not follow from (i), for FHϕ ⊢_Z ϕ is of no use if FHϕ ∉ Σ.

**Lemma 8.** Let Σ be an adequate set of formulae and let Γ be maximal S-consistent in Σ. Suppose ϕ₁, ..., ϕ_n ∈ Γ and χ_i ∈ Γ or θ_i ∈ Γ for i ∈ {1, ..., k}, and ψ ∈ Σ.

1. If ⊢_S (ϕ₁ ∧ ... ∧ ϕ_n) → ψ, then ψ ∈ Γ.
2. If ⊢_S (ϕ₁ ∧ ... ∧ ϕ_n) ∧ (χ₁ ∨ θ₁) ∧ ... ∧ (χ_k ∨ θ_k) → ψ, then ψ ∈ Γ.

*Proof:* The lemma follows straightforwardly from the definition of maximal S-consistency in Σ. ∎

**Lemma 9.** Suppose Γ is maximal S-consistent in Σ, and suppose Gψ₁, ..., Gψ_m ∈ Γ and ¬Hχ_i ∈ Γ or ¬χ_i ∈ Γ for i ∈ {1, ..., k}. If

⊢_S (Gψ₁ ∧ ... ∧ Gψ_m ∧ ψ₁ ∧ ... ∧ ψ_m ∧ ¬Hχ₁ ∧ ... ∧ ¬Hχ_k) → ξ,

then

⊢_S (Gψ₁ ∧ ... ∧ Gψ_m ∧ (¬Hχ₁ ∨ ¬χ₁) ∧ ... ∧ (¬Hχ_k ∨ ¬χ_k)) → Gξ.

*Proof:* Suppose

⊢_S (Gψ₁ ∧ ... ∧ Gψ_m ∧ ψ₁ ∧ ... ∧ ψ_m ∧ ¬Hχ₁ ∧ ... ∧ ¬Hχ_k) → ξ.

Then, by necessitation, transitivity and axiom 2(a),

⊢_S (Gψ₁ ∧ ... ∧ Gψ_m ∧ G¬Hχ₁ ∧ ... ∧ G¬Hχ_k) → Gξ,

so, because ⊢_Lin (¬Hχ_i ∨ ¬χ_i) → G¬Hχ_i for i ∈ {1, ..., k}, we have the desired

⊢_S (Gψ₁ ∧ ... ∧ Gψ_m ∧ (¬Hχ₁ ∨ ¬χ₁) ∧ ... ∧ (¬Hχ_k ∨ ¬χ_k)) → Gξ. ∎

### 4.1 Completeness of Z

Now we have all the materials at hand to prove completeness of **Z** with respect to the integers.

**Theorem 6.** **Z** is complete with respect to **Z**.

*Proof:* Suppose Φ ⊬_Z ϕ (Φ finite). Consider the minimal adequate set Σ containing Φ ∪ {¬ϕ}. Note that Σ is finite by Lemma 7. As before we proceed in stages. In stage 0 as before a point t₀ is created with as its associate a maximal consistent extension Γ₀ of Φ ∪ {¬ϕ}.

Since Σ is finite, the number of G- and H-formulae in Σ is finite. Hence it is clear that among the Δ with Γ₀ ≺ Δ, there are "maximal" Δ containing a maximal number of G-formulae and a minimal number of H-formulae. In stage 1 we introduce a t_r > t₀ with such a maximal Γ_r as its associate, and a t_l < t₀ with a dually introduced "minimal" Γ_l (with a maximal number of H-formulae and a minimal number of G-formulae) as its associate. If Γ₀ is already maximal and/or minimal, there is no need to introduce t_r and/or t_l, and we start stage 2 with one or two points instead of three.

Beginning in stage 2 we treat those ¬G-formulae in Γ_l for which Gϕ ∈ Γ_r and those ¬H-formulae in Γ_r for which Hϕ ∈ Γ_l. We do this in such a way that each such formula will have to be treated once only, whence this period will just last a finite number of stages. We will just show how this is done for ¬G-formulae. So, let ¬Gϕ ∈ Γ_t, Gϕ ∈ Γ_r (so t < r). We distinguish two cases:

**(a)** ¬G¬Gϕ ∈ Γ_t.

In this case a new point t′ > t and an associate Γ_{t′} ≻ Γ_t with ¬ϕ, Gϕ ∈ Γ_{t′} can be introduced. For, suppose not. Then

{Gψ, ψ | Gψ ∈ Γ_t} ∪ {¬Hχ | ¬Hχ ∈ Γ_t or ¬χ ∈ Γ_t} ∪ {¬ϕ, Gϕ}

is inconsistent. Thus,

⊢_Z (Gψ₁ ∧ ... ∧ Gψ_m ∧ ψ₁ ∧ ... ∧ ψ_m ∧ ¬Hχ₁ ∧ ... ∧ ¬Hχ_k) → (Gϕ → ϕ)

for some Gψ₁, ..., Gψ_m ∈ Γ_t, ¬Hχ₁ ∈ Γ_t or ¬χ₁ ∈ Γ_t, ..., ¬Hχ_k ∈ Γ_t or ¬χ_k ∈ Γ_t. Hence, by Lemma 9,

⊢_Z (Gψ₁ ∧ ... ∧ Gψ_m ∧ (¬Hχ₁ ∨ ¬χ₁) ∧ ... ∧ (¬Hχ_k ∨ ¬χ_k)) → G(Gϕ → ϕ).

Thus by (Z1),

⊢_Z (Gψ₁ ∧ ... ∧ Gψ_m ∧ (¬Hχ₁ ∨ ¬χ₁) ∧ ... ∧ (¬Hχ_k ∨ ¬χ_k)) → (FGϕ → Gϕ).

However, this is not possible, since FGϕ ≡ ¬G¬Gϕ ∈ Γ_t, so by Lemma 8 (b), Gϕ ∈ Γ_t, contradicting the assumption.

Hereafter, ¬Gϕ will not have to be treated again, because since Gϕ ∈ Γ_{t′}, t′ > u for any u with ¬Gϕ ∈ Γ_u.

**(b)** ¬G¬Gϕ ∉ Γ_l.

This can have two reasons, both turning out to lead to an inconsistency.

- G¬Gϕ ∈ Γ_l. This would imply G¬Gϕ ∈ Γ_r as Γ_l ⪯ Γ_r and, hence, since Gϕ ∈ Γ_r and ⊢_Lin G¬Gϕ ∧ Gϕ → G⊥, also G⊥ ∈ Γ_r, in contradiction with (P2).

- ¬G¬Gϕ ∉ Σ. This can only be because for some ψ, ϕ = ¬Gψ. Thus, ¬G¬Gψ ∈ Γ_l, G¬Gψ ∈ Γ_r. Since ⊢_Lin G¬Gψ ∧ Gψ → G⊥, this implies ¬Gψ ∈ Γ_r. By the maximality of Γ_r it then follows that there is no Δ with Γ ≺ Δ and Gψ ∈ Δ. So, ⊢_Z Gψ₁ ∧ ... ∧ Gψ_m ∧ ψ₁ ∧ ... ∧ ψ_m ∧ ¬Hχ₁ ∧ ... ∧ ¬Hχ_k → ¬Gψ, for some Gψ₁, ..., Gψ_m ∈ Γ_l, ¬Hχ₁ ∈ Γ_l or ¬χ₁ ∈ Γ_l, ..., ¬Hχ_k ∈ Γ_l or ¬χ_k ∈ Γ_l. But then, as in case (a),

  ⊢_Z (Gψ₁ ∧ ... ∧ Gψ_m ∧ G¬Hχ₁ ∧ ... ∧ G¬Hχ_k) → G¬Gψ.

  Hence, since ⊢_Lin (¬Hχ_i ∨ ¬χ_i) → G¬Hχ_i for i ≤ k, we can conclude by Lemma 8 that G¬Gψ ∈ Γ_l, contradicting the starting assumption.

We have now obtained a finite stretch which is going to be the middle part of our model. To obtain a model isomorphic to **Z** we extend both ends of this finite stretch infinitely. We will show how the extension is done in the direction of the future. That Γ_r was chosen maximal means that, if Γ_r ≺ Γ, then Γ_r and Γ contain exactly the same G- and H-formulae. That means that in going towards the future from Γ_r each time the same ¬G-formulae are up for treatment. The same holds for the ¬H-formulae, which means that we can ignore them: they have been treated already at or to the left of t_r. Suppose ¬Gϕ₁, ..., ¬Gϕ_k are the ¬G-formulae in Γ_r. Note that k ≥ 1, because, in any case, ¬G⊥ is an element of Γ_r. The formulae ¬Gϕ_i are treated cyclically to obtain successors with ¬ϕ_i. That this is possible is easier to prove than the above under (a), so we will leave this proof out. ∎

### 4.2 Completeness of D with respect to Z ⊙ Z and similar structures

In [1, Chapter I.2], Van Benthem convincingly argues that time might consist of more than one consecutive copies of the integers. In general, for a linear structure A, the structure **Z** ⊙ A consists of A, where each point has been replaced by a copy of **Z**. In this subsection, we will consider **Z** ⊙ A for infinite A, while in the next section we turn our attention to structures of the form **Z** ⊙ n.

First, let us investigate **Z** ⊙ **Z**. As in the case of **Z**, we cannot hope for **D** (or for any other tense logic) to be strongly complete with respect to **Z** ⊙ **Z**, because compactness fails again. This time, the set Φ that contains p₀ and for each pair r < r′ ∈ **Q** the formulae:

□(p_r → F(p_{r′} ∧ H¬p_{r′} ∧ G¬p_{r′}))

□(p_{r′} → F(p_r ∧ H¬p_r ∧ G¬p_r))

provides an example. For Φ to have a model on **Z** ⊙ **Z** requires that a copy of **Q** can be embedded in **Z** ⊙ **Z**, which is impossible.

Therefore, we will once again use maximal consistent sets relativized to an adequate set containing finitely many formulae.

We note in passing that once we have proved completeness of **D** with respect to **Z** ⊙ **Z**, we get completeness of **D** with respect to **Z** ⊙ **Q** (which in some quarters is called **Q** ⊙ **Z** and consists of **Q** with each point replaced by a copy of **Z**) for free. This is a corollary to [1, Theorem II.2.1.6], where filtration and 'inflation' are used to prove that **Z** ⊙ **Z** and **Z** ⊙ **Q** possess the same tense logical theory. In fact, his model-theoretical proof can be easily adapted to show that all frames of the form **Z** ⊙ A, where A is any infinite linear order, have the same tense logical theory; by our completeness theorem, that theory is just **D**, the logic for discrete structures.

The definition of an adequate set of formulae differs only slightly from the one needed to prove completeness of **Z**.

**Definition 7.** A set Σ of formulae is called *D-adequate* iff (i), (ii) and (iii) of Definition 4 hold, and moreover

- (v.a) If Gϕ ∈ Σ and ϕ is not of the form ¬Gψ or ¬Hψ, then H¬Gϕ ∈ Σ and G¬Gϕ ∈ Σ.
- (v.b) If Hϕ ∈ Σ and ϕ is not of the form ¬Gψ or ¬Hψ, then H¬Hϕ ∈ Σ and G¬Hϕ ∈ Σ.

It is a bit more difficult to prove completeness of **D** with respect to **Z** ⊙ **Z** than to prove completeness of **Z**. However, many of the ideas used in that proof can be easily adapted, so we will refer to the proof of Theorem 6 whenever possible.

**Lemma 10.**

- (i) If ¬Gϕ ∈ Γ and Γ is **D**-consistent, then so is
  {Gψ, ψ | Gψ ∈ Γ} ∪ {¬Hχ | ¬Hχ ∈ Γ or ¬χ ∈ Γ} ∪ {¬ϕ}
- (ii) If ¬Hϕ ∈ Γ and Γ is **D**-consistent, then so is
  {Hψ, ψ | Hψ ∈ Γ} ∪ {¬Gχ | ¬Gχ ∈ Γ or ¬χ ∈ Γ} ∪ {¬ϕ}

*Proof:* (i) Assume that ¬Gϕ ∈ Γ and Γ is **D**-consistent, but {Gψ, ψ | Gψ ∈ Γ} ∪ {¬Hχ | ¬Hχ ∈ Γ or ¬χ ∈ Γ} ∪ {¬ϕ} is not. Then there are Gψ₁, ..., Gψ_n ∈ Γ and χ₁, ..., χ_k with ¬Hχ_i ∈ Δ or ¬χ_i ∈ Γ for i = 1, ..., k, such that

⊢_D (Gψ₁ ∧ ψ₁ ∧ ... ∧ Gψ_n ∧ ψ_n ∧ ¬Hχ₁ ∧ ... ∧ ¬Hχ_k) → ϕ

By Lemma 9 we have

⊢_D (Gψ₁ ∧ ... ∧ Gψ_n ∧ G¬Hχ₁ ∧ ... ∧ G¬Hχ_k) → Gϕ

This is impossible: since ¬Gϕ ∈ Γ and ⊢_Lin (Hχ_i ∨ ¬χ_i) → G¬Hχ_i for i = 1, ..., k, Lemma 8 (b) gives Gϕ ∈ Γ, contradicting the assumption.

Analogously, we can prove (ii). ∎

**Theorem 7.** **D** is complete with respect to **Z** ⊙ **Z**.

*Proof:* Suppose Φ finite with Φ ⊬_D ϕ, and let Σ be the minimal adequate set containing Φ ∪ {¬ϕ}. As in the proof of Theorem 6, we introduce a point t₀ with as its associate a maximal consistent extension Γ₀ of Σ ∪ {¬ϕ}, and points t_l ≤ t₀, t_r ≥ t₀ associated with a 'minimal' Γ_l and a 'maximal' Γ_r respectively. As before, we start the next stage with three points or, if Γ₀ is already minimal and/or maximal, with one or two points.

In the following round of stages, we treat those ¬G-formulae for which ¬Gϕ ∈ Γ_l and Gϕ ∈ Γ_r and those ¬H-formulae for which ¬Hϕ ∈ Γ_r and Hϕ ∈ Γ_l. This time we cannot expect to obtain a finite stretch of points between t_l and t_r: the result will be of the form **n** or **N** + **Z** ⊙ **n** + **N**\*. Therefore, this period will not necessarily last a finite number of stages.

As we did before, we will restrict our attention to ¬G-formulae. Let t be the maximal point such that ¬Gϕ ∈ Γ_t, and let u be its successor, whose associate Γ_u contains Gϕ (as does Γ_r). Assume moreover that for all t′ with t < t′ ≤ t_r, ϕ ∈ Γ_{t′}; otherwise we do not need to do anything.

Lemma 10(a) now provides us with a new point v > t and an associate Γ_v ≻ Γ_t with ¬ϕ ∈ Γ_v. If Gϕ ∈ Γ_v as well, we are finished with the formula ¬Gϕ. On the other hand, if ¬Gϕ ∈ Γ_v we have to distinguish four cases.

**(a)** ¬H¬Gϕ ∈ Γ_u. With the help of Lemma 10 (ii) we can introduce a new point s < u and an associate Γ_s with Gϕ ∈ Γ_s and Γ_t ≺ Γ_v ≺ Γ_s ≺ Γ_u. If ¬ϕ ∈ Γ_s, we are finished with the formula ¬Gϕ. Otherwise we procrastinate further treatment until ¬Gϕ comes up in our next round, where we treat all relevant ¬G- and ¬H-formulae again.

**(b)** ¬H¬Gϕ ∉ Γ_u. This can have three reasons, the first two of which will lead to an inconsistency.

1. H¬Gϕ ∈ Γ_u. By the contraposition of (D1), we conclude that either ¬ϕ ∈ Γ_u or ¬Gϕ ∈ Γ_u, both possibilities contradicting our earlier assumptions.

2. ¬H¬Gϕ ∉ Σ and ϕ is of the form ¬Gψ. We know that ¬ϕ ≡ Gψ ∈ Γ_v, while ϕ ≡ ¬Gψ ∈ Γ_u. As Γ_v ≺ Γ_u, this is impossible.

3. ¬H¬Gϕ ∉ Σ and ϕ is of the form ¬Hψ. As ϕ ∈ Γ_u, Lemma 4.3(b) enables us to introduce a w < u and an associate Γ_w, with ¬ψ ∈ Γ_w. The contraposition of Axiom 3b gives ⊢_Lin ¬ψ → G¬Hψ, so G¬Hψ ≡ Gϕ ∈ Γ_w and so Γ_t ≺ Γ_v ≺ Γ_w ≺ Γ_u. If ¬ϕ ∈ Γ_w as well, we won't have to treat ¬Gϕ anymore. Otherwise, we put off its treatment until the next round, as in case (a).

After an enumerable number of rounds, we have obtained a middle part of our model isomorphic to **n** or to **N** + **Z** ⊙ **n** + **N**\*. First, we extend this middle part to a model isomorphic to **Z** or to **Z** ⊙ (**n** + 2) respectively, exactly as was done in the last paragraph of the proof of Theorem 6.

Extending this model to one that is isomorphic to **Z** ⊙ **Z** does not present any additional difficulties. We will only show how the extension works in the direction of the future.

Suppose we have just obtained r_i, Γ_{r_i} for i ≥ 1 with r < r₁ < r₂ < .... It is easy to see that for all i, j ≥ 1, Γ_{r_i} ≺ Γ_{r_j}.

(Proof: First, note that all Γ_i for i ≥ 1 contain the same G- and H-formulae. (a) Suppose Gϕ ∈ Δ_{r_i}, then Gϕ ∈ Γ_r by its maximality, so ϕ, Gϕ ∈ Γ_{r_j}. (b) Suppose Hϕ ∈ Γ_{r_j}, then Hϕ ∈ Γ_{r_{i+1}}, so Hϕ, ϕ ∈ Γ_{r_i}.)

Therefore, we can extend our middle part to the right with a structure isomorphic to **Z** ⊙ **N**. All copies of **Z** in this structure look identical, containing an **N**\*-part all points of which are associated with Γ_{r₁}, followed by an **N**-part consisting of points associated with Γ_{r₁}, Γ_{r₂}, Γ_{r₃}, etc. ∎

**Theorem 8.** **D** is complete with respect to **Z** ⊙ A, where A is any infinite linear order.

*Proof:* This can be proved model-theoretically by using Theorem 7 and then adapting the proof of [1, Theorem II.2.1.6] to show that **Z** ⊙ A has the same logic as **Z** ⊙ **Z**. Here, we give a direct completeness proof. Suppose Φ finite with Φ ⊬_D ϕ. We follow the proof of Theorem 7 to construct a model Φ ∪ {¬ϕ} on **Z** ⊙ **Z**. Now we can modify this model to an isomorphic copy of **Z** ⊙ A. In the extension towards the future (respectively the past) as constructed above, it is of course not essential that the copies of **Z** be ordered like **N** (respectively **N**\*): any linear order will do.

It remains to prove that we can insert any number of copies of **Z** between two adjacent copies Z_i < Z_{i+1} as formed in the construction of the middle part **Z** ⊙ (**n** + 2). So, consider the set of all points in Z_i greater than some t₀ ∈ Z_i. As there are only finitely many maximal **D**-consistent sets in Σ, there is a maximal **D**-consistent set Γ which is associated with an infinite number of these points. Now we can insert copies of **Z** in between Z_i and Z_{i+1}, all of these copies consisting of an **N**\*-part all points of which are associated with Γ, followed by an **N**-part which looks the same as the **N**-part following some chosen point associated with Γ in Z_i.

### 4.3 Finitely many copies of Z: Z ⊙ n

Theorem 8 states that the logical theory of structures of the form **Z** ⊙ A is rather weak: the tense logic **D** of discrete structures suffices. On the other hand, the tense logical theory of **Z** is rather strong, containing the continuity axiom R. We will now investigate the tense logical theory of structures in between these two extremes, namely those of the form **Z** ⊙ n.

```
 Z₁        Z₂         Z₃         Z₄
 p₁,p₂,p₃  ¬p₁,p₂,p₃  ¬p₁,¬p₂,p₃  ¬p₁,¬p₂,¬p₃
```
*Figure 1: ψ₃ is true in Z₁*

Unfortunately, we can prove that **D**, which is complete with respect to the limit **Z** ⊙ **Z**, is not complete with respect to any **Z** ⊙ n.

**Lemma 11.** **D** is not complete with respect to **Z** ⊙ n for any fixed n.

*Proof:* Consider the following sentence ψ_n:

G(Hp₁ → FHp₁) ∧ ... ∧ G(Hp_n → FHp_n) ∧ FHp₁ ∧ F(¬p₁ ∧ Hp₂ ∧ F(¬p₂ ∧ Hp₃ ... ∧ F(¬p_{n−1} ∧ Hp_n ∧ F¬p_n) ...))

This sentence does have a model on **Z** ⊙ **Z**, and even one on **Z** ⊙ (n + 1): one in which the set of sentences forced by every point in Z_i (i = 1, ..., n + 1) is {¬p₁ ... ¬p_{i−1}, p_i, ..., p_n}. However, ψ_n does not have a model of the form **Z** ⊙ n. For, let t ∈ **Z** ⊙ n, e.g. t ∈ Z_{i₀}, and t ⊨ ψ_n; then t ⊨ FHp₁ ∧ G(Hp₁ → FHp₁), so for all t′ ∈ Z_{i₀}, t′ ⊨ p₁. This implies that ¬p₁ ∧ Hp₂ ∧ F(¬p₂ ∧ ... (... ∧ F¬p_n) ...) can only be satisfied in Z_{i₁} for some i₁ > i₀. In the same way we can show that ¬p₂ ∧ Hp₃ ∧ F(¬p₃ ∧ ... (... F¬p_n) ...) can only be satisfied in Z_{i₂} for some i₂ > i₁, etc., so that a model of ψ_n should have at least n copies of **Z** after Z_{i₀}. ∎

This counterexample, where a sentence ψ_n can only be satisfied on structures with at least n gaps, suggests a hypothesis for a tense logic which is complete with respect to **Z** ⊙ n: we should add an axiom to **D** expressing that "there are less than n gaps".

We take **D** with as an additional axiom

**(G_n)** [G(Hϕ₁ → FHϕ₁) ∧ ... ∧ G(Hϕ_n → FHϕ_n) ∧ FHϕ₁ ∧ F(¬ϕ₁ ∧ Hϕ₂ ∧ F(¬ϕ₂ ∧ Hϕ₃ ∧ F(... ∧ F(¬ϕ_{n−2} ∧ Hϕ_{n−1} ∧ F¬ϕ_{n−1}) ...)))] → G(¬Hϕ_{n−1} → (Hϕ_n → Gϕ_n))

The formula G_n indeed expresses that the structure contains less than n gaps. For n = 1, G₁ is (G(Hϕ → FHϕ) ∧ FHϕ) → G(Hϕ → Gϕ), which is essentially just (R), the additional axiom for **Z** over **D**, in disguise.

In general, let **Z_n** be the theory **D** + (G_n), thus for example **Z₂** is **D** + (G₂):

**(G₂)** [G(Hϕ → FHϕ) ∧ G(Hψ → FHψ) ∧ FHϕ ∧ F¬ϕ] → G(¬Hϕ → (Hψ → Gψ)).

We will only prove completeness of **Z₂** with respect to **Z** ⊙ 2. Working out a proof for the general claim about **Z_n** with respect to **Z** ⊙ n in all its nitty-gritty details does not seem to be particularly attractive. As the reader will observe, the proof for n = 2 is already complicated enough. The definition of an adequate set is rather more involved than the ones used previously for **Z** and **D**.

**Definition 8.** A set Σ of formulae is called *Z₂-adequate* iff (i), (ii), (iii), (v.a) of Definition 7 hold, and moreover:

- (vi.a) If Hϕ ∈ Σ and ϕ is not of the form ¬Gψ or ¬Hψ, then H¬Hϕ ∈ Σ.
- (vi.b) If Hϕ ∈ Σ, then FHϕ ∈ Σ (no restrictions on ϕ).
- (vii) If FHϕ ∈ Σ, then F¬ϕ ∈ Σ.
- (viii) If Hϕ, FHϕ, Hψ, FHψ, F¬ϕ, Gψ ∈ Σ, then [G(Hϕ → FHϕ) ∧ G(Hψ → FHψ) ∧ FHϕ ∧ F¬ϕ] → G(¬Hϕ → (Hψ → Gψ)) ∈ Σ.

Note that clause (viii) is just axiom G₂. The notions of Z₂-consistency and ≺ are defined in the obvious way.

**Theorem 9.** **Z₂** is complete with respect to **Z** ⊙ 2.

*Proof:* Suppose Φ ⊬_{Z₂} ϕ (Φ finite), and let Σ be the minimal Z₂-adequate set containing Φ ∪ ¬ϕ -- the reader can check that Σ is finite. Again, we introduce a point t₀ associated with a maximal consistent extension Γ₀ of Φ ∪ {¬ϕ}, and points t_l ≤ t₀, t_r ≥ t₀ associated with a minimal Γ_l and a maximal Γ_r respectively.

Our next round of stages will provide us with the middle part of our model, a stretch isomorphic to some **n** or to **N** + **N**\*. During this period, we take care of those ¬G-formulae for which Gϕ ∈ Γ_r and those ¬H-formulae for which Hϕ ∈ Γ_l in the manner described in the proof of Theorem 7. However, we now have one extra task: we have to prove that no more than one 'gap' (i.e. a substructure of the form **N** + **N**\*) will result from our treatment of ¬H- and ¬G-formulae. The construction used in the proof of Theorem 7 can give rise to two kinds of gap:

- (a) those for which a formula Fψ holds on the left side (the **N**-part) and ¬Fψ on the right side (the **N**\*-part);
- (b) those for which a formula Hψ holds on the left side and ¬Hψ on the right side.

To prove the completeness result, we shall prove the following two claims:

**Claim I.** If there is a gap of either kind (a) or (b), we can find a formula ϕ such that:

- (\*) G(Hϕ → FHϕ) ∧ FHϕ ∧ F¬ϕ ∈ Γ_l and
- (\*\*) ¬Hϕ ∈ Γ for all t on the right side of the gap.

**Claim II.** To the right of such a point t with ¬Hϕ ∈ Γ_t, our construction does not produce any additional gaps.

**Proof of Claim I.**

Suppose that the construction gives rise to a gap of type (a), and that Fψ ∈ Γ_l, ¬Fψ ∈ Γ_r. There are three possibilities, the second leading to an inconsistency.

1. HFψ ∈ Σ, and so, by Definition 8 (vi.b) and (vii), FHFψ ∈ Σ and F¬Fψ ∈ Σ as well. We observe immediately that for ϕ ≡ Fψ, (\*) and (\*\*) hold.

2. HFψ ∉ Σ and ψ is of the form Gχ. In this case, Fψ ≡ FGχ ∈ Γ_l, so there is a Γ ≻ Γ_l with Gχ ∈ Γ. Because Γ_r is maximal with respect to G-formulae, we can conclude Gχ ∈ Γ_r, in contradiction with our assumption that ¬Gψ ≡ G¬Gχ ∉ Γ_r.

3. HFψ ∉ Σ and ψ is of the form Hχ, so Fψ ≡ FHχ. By Definition 8, both Hχ ∈ Σ and F¬χ ∈ Σ, and we see that for ϕ ≡ χ, (\*) and (\*\*) are satisfied.

Suppose, on the other hand, that the construction of the middle part produces a gap of type (b), and that Hψ ∈ Γ_l, while ¬Hψ ∈ Γ_r. This time, there is only one possibility:

1. FHψ ∈ Σ, and therefore F¬ψ ≡ ¬Gψ ∈ Σ as well. It is clear that (\*) and (\*\*) hold for ϕ ≡ ψ.

**Proof of Claim II.**

With minimal adaptations of the proof of Claim I, we can prove that if there is a gap to the right of a point t for which ¬Hϕ ∈ Γ_t (with ϕ such that G(Hϕ → FHϕ) ∧ Hϕ ∧ F¬ϕ ∈ Γ_l), then there is a formula χ such that Hχ ∈ Γ_t, F¬χ ∈ Γ_t and G(Hχ → FHχ) ∈ Γ_l. We can conclude that for this χ, G(Hϕ → FHϕ) ∧ G(Hχ → FHχ) ∧ FHϕ ∧ F¬ϕ ∈ Γ_l, while G(¬Hϕ → (Hχ → Gχ)) ∉ Γ_l, in contradiction with (G₂). The details of this proof are left to the reader.

Finally, the middle part constructed above can be extended to a structure of the form **Z** ⊙ 2 by an easy modification of the proof for **Z** ⊙ **Z**; we leave the details to the reader. ∎

## 5 Discussion and Conclusions

Perhaps what was shown for **D**, also holds for **Q**. In particular:

- Is **Q** complete with respect to **R** ⊙ A for any infinite linear order A?
- Is **Q** + G_n complete with respect to **R** ⊙ n?
- And if so, how close have we come to a characterization of all reasonable -- in some sense of the word -- logics of time?

We, Rineke Verbrugge and Frank Veltman, look forward to investigating such questions together with our co-author Dick de Jongh, who will now have all the time for them.

## 6 Acknowledgements

The authors would like to thank Johan van Benthem for his insightful remarks and suggestions on the 1988 version of this paper, many of which we still plan to follow up.

## References

[1] J.F.A.K. van Benthem. *The Logic of Time: A Model-Theoretic Investigation into the Varieties of Temporal Ontology and Temporal Discourse*. Kluwer Academic Publishers, Dordrecht, 1991.

[2] P. Blackburn, M. de Rijke, and Y. Venema. *Modal Logic*, volume 53 of Cambridge Tracts in Theoretical Computer Science. Cambridge University Press, 2001.

[3] John P. Burgess. Basic tense logic. In D. Gabbay and F. Guenthner, editors, *Handbook of Philosophical Logic, Second Edition, Volume 7*, pages 1--42. Kluwer Academic Publishers, Dordrecht, 2002.

[4] D.H.J. de Jongh and F.J.M.M. Veltman. *Intensional Logic*. University of Amsterdam, Amsterdam, 1983. Unpublished course text.

[5] D.H.J. de Jongh and F.J.M.M. Veltman. Provability logics for relative interpretability. In P. Petkov, editor, *Proceedings of the Heyting 1988 Summer School in Varna*, pages 31--42. Plenum Press, Boston, 1990.

[6] K. Segerberg. *An Essay in Classical Modal Logic*. Filosofiska Foreningen och Filosofiska Institutionen vid Uppsala Universitet, Uppsala, 1971.
