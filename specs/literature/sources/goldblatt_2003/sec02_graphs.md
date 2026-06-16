### Graphs

In this paper, a *graph* will be a pair $G = (V, E)$, where $V$ is a non-empty set of 'vertices' and $E$ is an irreflexive symmetric binary 'edge' relation on $V$. A set $S \subseteq V$ is said to be *independent* if for all $x, y \in S$ we have $(x, y) \notin E$. For an integer $k$, a *$k$-colouring* of $G$ is a partition of $V$ into $k$ independent sets. The *chromatic number* of $G$ is the smallest $k$ for which it has a $k$-colouring, and $\infty$ if it has no $k$-colouring for any finite $k$. A *cycle* in $G$ is a sequence $(x_1, \ldots, x_k)$ of distinct nodes of $V$, such that $k \geq 3$ and $(x_1, x_2), \ldots, (x_{k-1}, x_k), (x_k, x_1)$ are all in $E$.[^4] The *length* of the cycle is $k$. By definition, no graph has cycles of length $< 3$. It is well known that a graph has chromatic number at most two if, and only if, it has no cycles of odd length. For a proof, see, e.g., [8, proposition 1.6.1]. The result holds for both finite and infinite graphs; the implicit assumption in [8, p. 2] that graphs are finite is not needed in the proof in [8].

[^4]: In graph theory, $(x_1, \ldots, x_k)$, $(x_2, \ldots, x_k, x_1)$, and $(x_k, \ldots, x_1)$ are regarded as the same cycle; but this is not important here.

We often identify (notationally) a graph, algebra, structure, or frame, with its domain --- for example, in the above context, we will often write $G$ for $V$.

---

## 2. The algebraic approach

We now give a detailed presentation of the algebraic approach. We begin with a rundown of the necessary concepts and notation, and then we review a general method by which we may prove a variety to be canonical. Much or all of this material will be familiar to algebraists. It will then be quite easy to show that the variety we introduce in Section 2.3 is canonical but not elementarily generated.

### 2.1. Boolean algebras with operators (BAOs)

We assume familiarity with basic ideas from model theory and universal algebra, such as the notions of homomorphism, product, subalgebra, ultraproduct, ultrapower, ultraroot, equation, universal formula, and equational class (variety). We also presuppose some acquaintance with Boolean algebra theory, including notions such as atom, atomicity, completeness, ideal and (ultra)filter, and Stone representation theory. Readers may consult, e.g., [2, chapter 5], [4], [31], or [29, chapter 2] for background.

A similarity type $L$ of BAOs will consist of the boolean function symbols $+, -$ and the constants $0, 1$, plus additional function symbols for operators. An $L$-BAO is an $L$-structure $\mathcal{A}$ whose reduct to the signature $\{+, -, 0, 1\}$ is a boolean algebra and in which the interpretations of the additional function symbols are 'operators': i.e., normal (taking value zero whenever any argument is zero), and additive (hence monotonic) in each argument. We write $x \cdot y$ for $-(-x + -y)$. We often use the same notation for a symbol in $L$ and its interpretation in an $L$-BAO. Given $L$-BAOs $\mathcal{A}_i$ ($i \in I$), and an ultrafilter $D$ on $I$, we write $\prod_D \mathcal{A}_i$ for the ultraproduct of the $\mathcal{A}_i$ over $D$. $\mathbf{S}, \mathbf{P}, \mathbf{Pu}, \mathbf{Ru}$ denote closure of a class under isomorphic copies of: subalgebras, products, ultraproducts, and ultraroots, respectively.

A *discriminator* on an $L$-BAO $\mathcal{A}$ is a unary function $d$ on $\mathcal{A}$ such that $d(0) = 0$ and $d(x) = 1$ for all non-zero $x$ in $\mathcal{A}$. A class $\mathcal{K}$ of $L$-BAOs is a *discriminator class* if some $L$-term $t(x)$ defines a discriminator on each BAO in $\mathcal{K}$. The following is almost immediate from Givant's results [15, theorem 2.2, lemma 2.3].

> **Proposition 2.1.** *If $\mathcal{K}$ is a discriminator class of BAOs with $\mathbf{Pu}\,\mathcal{K} \subseteq \mathbf{S}\,\mathcal{K}$, then $\mathbf{S}\,\mathbf{P}\,\mathcal{K}$ is a variety whose class of subdirectly irreducible members is $\mathbf{S}\,\mathcal{K}$.*

The dual $(n+1)$-ary relation symbol for an $n$-ary operator symbol $f \in L$ will be written $R_f$, and we write $L^a$ for the similarity type consisting of these relation symbols. In this context, a 'structure' will usually mean an $L^a$-structure. We write $\mathcal{A}_+$ for the *canonical structure* of an $L$-BAO $\mathcal{A}$; it consists of the set of all ultrafilters of (the boolean reduct of) $\mathcal{A}$, made into an $L^a$-structure via $\mathcal{A}_+ \models R_f(\mu_1, \ldots, \mu_n, \nu)$ iff $f(a_1, \ldots, a_n) \in \nu$ whenever $a_1 \in \mu_1, \ldots, a_n \in \mu_n$. We write $S^+$ for the *complex algebra* over the structure $S$; it consists of the set of all subsets of $S$, made into an $L$-BAO by defining $f(X_1, \ldots, X_n)$ to be the set of all $y$ in $S$ such that $S \models R_f(x_1, \ldots, x_n, y)$ for some $x_1 \in X_1, \ldots, x_n \in X_n$. The *canonical extension* $(\mathcal{A}_+)^+$ of a BAO $\mathcal{A}$ will be denoted by $\mathcal{A}^\sigma$; up to isomorphism, this is the 'perfect extension' of $\mathcal{A}$ defined by Jonsson and Tarski in [37]. A class of BAOs is said to be *canonical* if it is closed under taking canonical extensions. For a class $\mathcal{C}$ of structures, we write $\mathcal{C}^+$ for $\{S^+ : S \in \mathcal{C}\}$, and $\operatorname{Var} \mathcal{C}$ for the smallest variety containing $\mathcal{C}^+$; this is called the variety *generated by* $\mathcal{C}$. A variety of the form $\operatorname{Var} \mathcal{C}$ for an elementary class $\mathcal{C}$ is said to be *elementarily generated*. For a variety $\mathcal{V}$ of BAOs, we write $\operatorname{Cst} \mathcal{V} = \{\mathcal{A}_+ : \mathcal{A} \in \mathcal{V}\}$, and $\operatorname{Str} \mathcal{V} = \{S : S^+ \in \mathcal{V}\}$.

If $S, T$ are $L^a$-structures, a map $\theta : S \to T$ is called a *bounded morphism* if for all $n$-ary operator symbols $f \in L$ and all $a \in S$, $b_1, \ldots, b_n \in T$, we have $T \models R_f(b_1, \ldots, b_n, \theta(a))$ iff there are $a_1, \ldots, a_n \in S$ with $S \models R_f(a_1, \ldots, a_n, a)$ and $\theta(a_1) = b_1, \ldots, \theta(a_n) = b_n$. If $S$ is a substructure of $T$ and the inclusion map from $S$ to $T$ is a bounded morphism, then $S$ is called an *inner substructure* of $T$. If $S_i$ ($i \in I$) are pairwise disjoint inner substructures of $T$ with $\bigcup_{i \in I} S_i = T$, we say that $T$ is the *disjoint union* of the $S_i$, and write $T = \sum_{i \in I} S_i$. $\mathbf{Ud}\,\mathcal{C}$ will denote the closure under disjoint union of a class $\mathcal{C}$ of structures.

### 2.2. Canonical structures of products

The following is the specialisation to BAOs of a result proved in [14], with the main argument, concerning Stone spaces, going back to [12]. It is not so hard to give a proof in the BAO case, so we will do so to make our paper more self-contained (we will also use parts of the proof later on).

> **Theorem 2.2.** *If $\mathcal{K}$ is a canonical class of BAOs that is closed under ultraproducts, then $\mathbf{P}\,\mathcal{K}$ is also canonical.*

**Notation.** Throughout this subsection, let $I$ be a non-empty set and let $\mathcal{A}_i$ ($i \in I$) be a collection of similar BAOs. Write $\mathcal{A} = \prod_{i \in I} \mathcal{A}_i$ and $S = \mathcal{A}_+$. Let $\operatorname{Spec} I$ denote the set of ultrafilters on $I$. For $X \subseteq I$ define $1_X \in \mathcal{A}$ by

$$
(1_X)_i = \begin{cases} 1, & \text{if } i \in X, \\ 0, & \text{otherwise.} \end{cases}
$$

Define the *support set* $\sigma(a)$ of $a = \langle a_i : i \in I \rangle \in \mathcal{A}$ to be $\sigma(a) = \{i \in I : a_i \neq 0\}$. Finally, for $\mu \in \mathcal{A}_+$, define $\sigma(\mu) = \{\sigma(a) : a \in \mu\}$.

It is clear that $\sigma(1_X) = X$ and $\sigma(\mu) = \{X \subseteq I : 1_X \in \mu\}$.

> **Lemma 2.3.** *For each $\mu \in \mathcal{A}_+$, $\sigma(\mu)$ is an ultrafilter on $I$.*

*Proof.* Clearly, $1 \in \mu$ and $\sigma(1) = I$, so $I \in \sigma(\mu)$. If $a \in \mu$ and $\sigma(a) \subseteq X \subseteq I$, then $1_X \geq a$ so $1_X \in \mu$ and $X = \sigma(1_X) \in \sigma(\mu)$. If $a, b \in \mu$ then $\sigma(a) \cap \sigma(b) \supseteq \sigma(a \cdot b) \in \sigma(\mu)$, so $\sigma(\mu)$ is closed under finite intersection. Finally, for any $X \subseteq I$, we have $X \in \sigma(\mu)$ iff $1_X \in \mu$, iff $1_{I \setminus X} = -1_X \notin \mu$, iff $I \setminus X \notin \sigma(\mu)$. So $\sigma(\mu)$ is an ultrafilter on $I$. $\square$

Let $D \in \operatorname{Spec} I$. The map $a \mapsto a/D$ is a surjective homomorphism $\mathcal{A} \to \prod_D \mathcal{A}_i$. By duality (see [2, theorem 5.47]), its inverse yields an injective bounded morphism $\nu_D : (\prod_D \mathcal{A}_i)_+ \to \mathcal{A}_+$. Write $\operatorname{rng} \nu_D$ for its range.

> **Lemma 2.4.** $\operatorname{rng}(\nu_D) = \{\mu \in \mathcal{A}_+ : \sigma(\mu) = D\}$.

*Proof.* Let $f \in (\prod_D \mathcal{A}_i)_+$. If $a \in \nu_D(f)$ then $a/D \in f$, so $\prod_D \mathcal{A}_i \models a/D \neq 0$. This implies that $\sigma(a) \in D$. This holds for all such $a$; hence, by lemma 2.3, $\sigma(\nu_D(f)) = D$.

Conversely, if $\mu \in \mathcal{A}_+$ and $\sigma(\mu) = D$, the set $f = \{a/D : a \in \mu\}$ is easily seen to be an ultrafilter of $\prod_D \mathcal{A}_i$ with $\nu_D(f) = \mu$. $\square$

> **Theorem 2.5.** *For any similar BAOs $\mathcal{A}_i$ ($i \in I$), we have*
> $$\left(\prod_{i \in I} \mathcal{A}_i\right)_+ \cong \sum_{D \in \operatorname{Spec} I} \left(\prod_D \mathcal{A}_i\right)_+,$$
> $$\left(\prod_{i \in I} \mathcal{A}_i\right)^\sigma \cong \prod_{D \in \operatorname{Spec} I} \left(\prod_D \mathcal{A}_i\right)^\sigma.$$

*Proof.* Each $\operatorname{rng}(\nu_D)$ is (the domain of) an inner substructure of $\mathcal{A}_+$. By lemmas 2.3 and 2.4, the ranges of the $\nu_D$ for distinct $D$ are pairwise disjoint, and $\bigcup_{D \in \operatorname{Spec} I} \operatorname{rng}(\nu_D) = \mathcal{A}_+$. So $\mathcal{A}_+ = \sum_{D \in \operatorname{Spec} I} \operatorname{rng}(\nu_D) \cong \sum_{D \in \operatorname{Spec} I} (\prod_D \mathcal{A}_i)_+$, proving the first line. The second line follows by duality (see [2, theorem 5.48]). $\square$

*Proof of theorem 2.2.* Let $\prod_{i \in I} \mathcal{A}_i \in \mathbf{P}\,\mathcal{K}$ be given, with the $\mathcal{A}_i$ in $\mathcal{K}$. By our assumptions on $\mathcal{K}$, for each ultrafilter $D$ on $I$, $\prod_D \mathcal{A}_i \in \mathcal{K}$, and so $(\prod_D \mathcal{A}_i)^\sigma \in \mathcal{K}$. So $\prod_{D \in \operatorname{Spec} I} ((\prod_D \mathcal{A}_i)^\sigma) \in \mathbf{P}\,\mathcal{K}$. By the theorem, this is isomorphic to $(\prod_{i \in I} \mathcal{A}_i)^\sigma$ which is therefore in $\mathbf{P}\,\mathcal{K}$ as required (recall that $\mathbf{P}$ denotes closure under isomorphic copies of products). $\square$
