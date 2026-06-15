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
