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
