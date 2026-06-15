## 5 Conjugated Varieties

In this short section we provide a proof of Theorem 2. The crucial property of conjugated algebras causing the smooth behavior of conjugated varieties is the fact that their operators are *completely* additive. This will be made clear by the following proposition.

**Proposition 5.1** *Let $\mathfrak{A}$ be an atomic boolean algebra with operators, and let $\mathfrak{F}$ be its atom structure. Then*

1. *The map $r : x \mapsto \{a \in At\,\mathfrak{A} \mid a \leq x\}$ embeds $\mathfrak{A}$ into $\mathfrak{F}^+$ if and only if $\mathfrak{A}$ is completely additive.*
2. *In particular, if $\mathfrak{A}$ is completely additive then $\mathfrak{F}^\circ \hookrightarrow \mathfrak{A} \hookrightarrow \mathfrak{F}^+$.*

*Proof.* First observe that part 2 of the proposition follows from part 1, since $\mathfrak{F}^\circ$ and $\mathfrak{F}^+$ are the smallest and the largest complex algebra over $\mathfrak{F}$, respectively. Of part 1, we leave the easy left-to-right direction of the proof to the reader.

For the other direction, let $\mathfrak{A}$ be an atomic, completely additive boolean algebra with operators. Let $r : A \to \mathcal{P}(At\,\mathfrak{A})$ be the map given in the statement of the Theorem. We claim that $r$ preserves infinite joins and embeds $\mathfrak{A}$ into $\mathfrak{At}\,\mathfrak{A}^+$ --- this is clearly sufficient.

The result that $r$ is an embedding seems to be folklore, (cf. Goldblatt [2]), while Hirsch & Hodkinson [4] prove that $r$ preserves arbitrary joins. Let us just show here that $r$ is a homomorphism with respect to an arbitrary unary operator $f$, i.e., that

$$r(fc) = m_{R_f}(r(c)). \tag{1}$$

First note that

$$r(fc) = r\!\left(f\!\left(\bigvee_{c \geq b \in At\,\mathfrak{A}} b\right)\right) = r\!\left(\bigvee_{c \geq b \in At\,\mathfrak{A}} fb\right), \tag{2}$$

by the fact that $f$ is completely additive. Second, since $r$ preserves arbitrary joins, we have that

$$r\!\left(\bigvee_{c \geq b \in At\,\mathfrak{A}} fb\right) = \bigcup_{c \geq b \in At\,\mathfrak{A}} r(fb). \tag{3}$$

Combining (2) and (3) yields:

$$r(fc) = \{a \in At\,\mathfrak{A} \mid \exists b \in At\,\mathfrak{A}\,(b \leq c \;\&\; a \in r(fb))\}.$$

Thus, using the definitions of the map $r$ and the relation $R_f$ on $At\,\mathfrak{A}$, we obtain

$$\begin{aligned}
r(fc) &= \{a \in At\,\mathfrak{A} \mid \exists b \in At\,\mathfrak{A}\,(b \in r(c) \;\&\; a \leq fb)\} \\
&= \{a \in At\,\mathfrak{A} \mid \exists b \in At\,\mathfrak{A}\,(b \in r(c) \;\&\; R_f ab)\},
\end{aligned}$$

which by definition of $m_{R_f}$ is nothing but $m_{R_f}(c)$. Thus we have proved (1). $\square$

From this Proposition the proof of Theorem 2 is more or less immediate:

**Proof of Theorem 2.** We first prove part 2. Let $\mathsf{V}$ be an arbitrary conjugated variety of BAOs. From Proposition 5.1 and the fact that all conjugated BAOs are completely additive it follows immediately that $\mathsf{At\,V} = \mathsf{Wst\,V}$, or equivalently, that $\mathsf{V}$ is atom-sensitive. Then $\mathsf{V}$ is atom-elementary by Proposition 3.9, while the stronger result concerning the axiomatization of $\mathsf{At\,V}$ follows by Theorem 3.

Finally, we turn to part 1. By Theorem 1 it suffices to show that AC implies AD for conjugated varieties. Hence, assume that $\mathsf{V}$ is a variety of conjugated BAOs which is atom-canonical and consider two atomic algebras $\mathfrak{A}$ and $\mathfrak{B}$ with isomorphic atom structures. In order to prove that $\mathsf{V}$ is atom-determined, it suffices to prove that $\mathfrak{B}$ is in $\mathsf{V}$ if $\mathfrak{A}$ is in $\mathsf{V}$, so assume the latter. Let $\mathfrak{F}$ be the atom structure of $\mathfrak{A}$; it follows from (AC) that $\mathfrak{F}^+$ is in $\mathsf{V}$. But Proposition 5.1 implies that $\mathfrak{B}$ can be embedded in $\mathfrak{F}^+$. It is then immediate that $\mathfrak{B}$ is in $\mathsf{V}$. $\square$

---

## 6 Conclusions and Questions

Let me finish the paper with briefly mentioning some open problems in the field.

1. Most intriguing I find the question, whether *every* variety is atom-elementary. I conjecture that this is not the case, but I do not have a counterexample. Note that it follows by a result of Goldblatt that the class $\mathsf{At\,V}$ of a variety $\mathsf{V}$ is always closed under ultraproducts (cf. Corollary 5.3 in Goldblatt [2]).

2. It also seems worth while to try and find out what the relation is between the concepts introduced here and the notion of canonicity. In particular, I would like to know whether every atom-canonical variety is canonical. And, if the answer to this question is negative, then I would be interested to learn whether every atom-canonical variety with the finite algebra property is canonical.

3. There are a number of concepts defined in this paper (including the notion of atom-sensitivity) of which the precise relation is still unclear. For instance, I do not know whether:
   - (a) $AC = AD$
   - (b) $AX \leq AE$, or $AE \leq AX$

4. Is every variety of BAOs generated by its atomic members? (This question was raised at the conference.)

5. In this paper we have confined ourselves to the relation between algebraic and relational *structures*. One might bring morphisms into the picture as well, and investigate the property of the operation $\mathfrak{At}$ as a map between the *categories* of BAOs with homomorphisms and frames with bounded morphisms.

6. A related question, raised by A. Simon, is how closure properties of a class (not necessarily a variety) of BAOs are reflected in properties of the associated class of atom structures.

---

## References

- [1] R. Goldblatt. Varieties of complex algebras. *Annals of Pure and Applied Logic*, 44:173--242, 1989.

- [2] R. Goldblatt. Elementary generation and canonicity for varieties of boolean algebras with operators. *Algebra Universalis*, 34:551--607, 1995.

- [3] L. Henkin, J. D. Monk, and A. Tarski. *Cylindric Algebras Part I & II*. North-Holland, Amsterdam, 1971 & 1985.

- [4] R. Hirsch and I. Hodkinson. Complete representations in algebraic logic. Technical report, Department of Computing, Imperial College, London, 1994. To appear in *Journal of Symbolic Logic*.

- [5] I. Hodkinson. Atom structures of relation algebras and cylindric algebras. Submitted. Available as manuscript from the Department of Computing, Imperial College, London, 1994.

- [6] B. Jonsson and A. Tarski. Boolean algebras with operators. Parts I and II. *American Journal of Mathematics*, 73:891--939, 1951. and 74:127--162, 1952.

- [7] Y. Venema. Atom structures and Sahlqvist equations. Research Report 96-173, Mathematics Department, Victoria University of Wellington, 1996. To appear in *Algebra Universalis*.

---

[^1]: Most of the unexplained notions are formally defined in section 2.
[^2]: One may also find the notion of atom structure defined for non-atomic BAOs, but we will not do so here.
[^3]: Algebraists tend to write $R_f b_1 \ldots b_n a$ instead of $R_f a b_1 \ldots b_n$.
[^4]: Here $\mathsf{Str\,V}$ denotes the class of structures for $\mathsf{V}$, that is, all frames $\mathfrak{F}$ with $\mathfrak{F}^+$ in $\mathsf{V}$.
[^5]: An inspection of the proof of Theorem 2 reveals that the result can be truly stated for every variety of BAOs in which all operators are *completely additive*. Since conjugacy is the only equational property implying complete additivity that we are aware of, we have refrained from a more general formulation along these lines.
[^6]: In this paper I only consider properties of *varieties* of BAOs. However, many of the questions also apply to larger classes like quasi-varieties or universal classes, and many of the results go through. For instance, the proof of Theorem 3 can easily be adapted to the case of $\mathsf{V}$ being a universal class instead of a variety.
[^7]: The definitions and proofs of this section can be understood without prior exposition to modal correspondence theory.
