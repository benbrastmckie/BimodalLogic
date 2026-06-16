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
