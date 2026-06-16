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
