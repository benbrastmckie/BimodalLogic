## 1.5 Logic

The set $L_{\infty\omega}$ of (infinitary) formulas of $L$ is the least one such that:

1. all atomic formulas are in $L_{\infty\omega}$;
2. if $\varphi \in L_{\infty\omega}$ then $\neg\varphi \in L_{\infty\omega}$;
3. if $\Phi \subseteq L_{\infty\omega}$ is any set then $\bigwedge\Phi$ and $\bigvee\Phi$ are in $L_{\infty\omega}$;
4. if $\varphi \in L_{\infty\omega}$ and $x$ is a variable then $\forall x\,\varphi$ and $\exists x\,\varphi$ are in $L_{\infty\omega}$.

The **quantifier rank** $\text{qr}(\varphi)$ of $\varphi \in L_{\infty\omega}$ is an ordinal recursively defined as follows:

1. $\text{qr}(\varphi) = 0$ if $\varphi$ is atomic;
2. $\text{qr}(\neg\varphi) = \text{qr}(\varphi)$;
3. $\text{qr}(\bigwedge\Phi) = \text{qr}(\bigvee\Phi) = \sup\{\text{qr}(\varphi) \mid \varphi \in \Phi\}$;
4. $\text{qr}(\forall x\,\varphi) = \text{qr}(\exists x\,\varphi) = \text{qr}(\varphi) + 1$.

**1.5.1 Theorem.** *$h \in I_\alpha(\mathbf{A}, \mathbf{B})$ iff for every $\varphi \in L_{\infty\omega}$ with $\text{qr}(\varphi) < \alpha$ and every valuation $f$ of the free variables of $\varphi$ into $\text{Dom}\,h$: $\mathbf{A} \models \varphi[f]$ iff $\mathbf{B} \models \varphi[h \circ f]$ (i.e., $h$ preserves satisfaction of quantifier-rank $< \alpha$-formulas).*

## 1.6 Scott-Sentences

**1.6.1 Definition.** Fix an enumeration $v_0, v_1, v_2, \ldots$ of all variables. For $\mathbf{A} = (A, \ldots)$, $\mathbf{a} = (a_0, \ldots, a_{k-1}) \in A^k$ and $\alpha$ an ordinal, define the formula $[\![\mathbf{a}]\!]^\alpha = [\![(\mathbf{A}, \mathbf{a})]\!]^\alpha$ (the **$\alpha$-characteristic** of $\mathbf{a}$ in $\mathbf{A}$) as follows:

1. $[\![\mathbf{a}]\!]^0$ is the conjunction of all atomic or negated atomic formulas in $v_0, \ldots, v_{k-1}$ satisfied by $\mathbf{a}$ in $\mathbf{A}$;
2. $[\![\mathbf{a}]\!]^{\alpha+1} = \bigwedge_{a \in A} \exists v_k\, [\![\mathbf{a}a]\!]^\alpha \wedge \forall v_k \bigvee_{a \in A} [\![\mathbf{a}a]\!]^\alpha$;
3. $[\![\mathbf{a}]\!]^\alpha = \bigwedge_{\xi < \alpha} [\![\mathbf{a}]\!]^\xi$ when $\alpha$ is a limit.

**1.6.3 Theorem.** *For $\mathbf{a} \in A^k$ and $\mathbf{b} \in B^k$ the following are equivalent:*

1. *$\mathbf{a} \equiv^\alpha \mathbf{b}$;*
2. *$\mathbf{B} \models [\![\mathbf{a}]\!]^\alpha[\mathbf{b}]$;*
3. *$[\![\mathbf{b}]\!]^\alpha = [\![\mathbf{a}]\!]^\alpha$.*

## 1.7 The Finite Case

**1.7.1 Lemma.** *If the language of $\mathbf{A}$ is finite then, for all $k, n \in \mathbb{N}$, there are only finitely many $n$-characteristics belonging to sequences of length $k$.*

**1.7.2 Theorem.** *For models $\mathbf{A}$, $\mathbf{B}$ of the same finite language, when $\mathbf{a} \in A^k$, $\mathbf{b} \in B^k$, $n \in \omega$, the following are equivalent:*

1. *$\mathbf{a} \equiv^n \mathbf{b}$;*
2. *for all finite formulas $\varphi$ of quantifier-rank $\leq n$ in the appropriate number of free variables: $\mathbf{A} \models \varphi[\mathbf{a}] \Leftrightarrow \mathbf{B} \models \varphi[\mathbf{b}]$.*

## 1.8 The Unbounded Case

$\mathbf{A}$ and $\mathbf{B}$ are called **partially isomorphic** if a non-empty set $I$ of partial isomorphisms exists with the back-and-forth property.

**1.8.1 Theorem.** *The following are equivalent:*

1. *$I_\alpha(\mathbf{A}, \mathbf{B}) = I_{\alpha+1}(\mathbf{A}, \mathbf{B}) \neq \varnothing$;*
2. *$II$ has a winning strategy for $G(\mathbf{A}, \mathbf{B}, \varnothing)$;*
3. *$\mathbf{A}$ and $\mathbf{B}$ are partially isomorphic;*
4. *$\mathbf{A} \equiv^{\infty} \mathbf{B}$ (i.e., they have the same $L_{\infty\omega}$-theory).*

**1.8.2 Corollary.** *(Barwise [1973]) Countable partially isomorphic models are isomorphic.*

## 1.9 Basis Results

**1.9.1 Theorem.**

1. *If $|A| = n < \omega$ then $\mathbf{A} \equiv^\infty \mathbf{B}$ iff $\mathbf{A} \cong \mathbf{B}$ iff $\mathbf{A} \equiv^{n+1} \mathbf{B}$;*
2. *If $\mathbf{A}$ and $\mathbf{B}$ are infinite then $\mathbf{A} \equiv^\infty \mathbf{B}$ iff $\mathbf{A} \equiv^\alpha \mathbf{B}$, where $\alpha$ is the least ordinal of power $> |A|, |B|$.*

**1.9.2 Theorem.** *Let $\mathcal{A}$ be an admissible set such that $L, \mathbf{A}, \mathbf{B} \in \mathcal{A}$ and let $\alpha = \mathcal{A} \cap \text{OR}$ be the set of ordinals in $\mathcal{A}$. If $\mathbf{A} \equiv^\alpha \mathbf{B}$ then $\mathbf{A} \equiv^\infty \mathbf{B}$.*

The **Scott-rank** $\text{sr}(\mathbf{A})$ of $\mathbf{A}$ is the least ordinal $\alpha$ such that for all $k$ and $\mathbf{a}, \mathbf{b} \in A^k$: if $\mathbf{a} \equiv^\alpha \mathbf{b}$ then $\mathbf{a} \equiv^{\alpha+1} \mathbf{b}$.

**1.9.3 Theorem.** *If $\mathcal{A}$ is admissible and $\mathbf{A} \in \mathcal{A}$ then $\text{sr}(\mathbf{A}) < \mathcal{A} \cap \text{OR}$.*

For $\alpha = \text{sr}(\mathbf{A})$, the **Scott-sentence** of $\mathbf{A}$ is

$$\sigma_{\mathbf{A}} = [\![\varnothing]\!]^\alpha \wedge \bigwedge_a \forall x\,([\![\mathbf{a}]\!]^\alpha \to [\![\mathbf{a}]\!]^{\alpha+1}).$$

**1.9.4 Theorem.**

1. *$\text{qr}(\sigma_{\mathbf{A}}) = \text{sr}(\mathbf{A}) + \omega$;*
2. *$\mathbf{A} \models \sigma_{\mathbf{A}}$;*
3. *$\mathbf{B} \models \sigma_{\mathbf{A}}$ iff $\mathbf{B} \cong^{\omega} \mathbf{A}$.*

---

## References (from thesis bibliography, selected)

- Barwise, K.J. [1973]. Back and forth through infinitary logic. In *Studies in Model Theory*, MAA Studies in Math. vol. 8.
- Barwise, K.J. [1975]. *Admissible Sets and Structures.* Springer.
- van Benthem, J.F.A.K. [1983]. *Modal Logic and Classical Logic.* Bibliopolis.
- Chang, C.C. [1968]. Some remarks on the model theory of infinitary languages. In *The Syntax and Semantics of Infinitary Languages*, Springer LNM 72.
- de Jongh, D.H.J., R. Verbrugge, and A. Visser [1986]. A completeness result for Z. Preprint, University of Amsterdam.
- Ehrenfeucht, A. [1961]. An application of games to the completeness problem for formalized theories. *Fund. Math.* 49, pp. 129--141.
- Fraissé, R. [1955]. Sur quelques classifications des relations, basées sur des isomorphismes restreints. *Publ. Sci. Univ. Alger*, Sér. A, 2, pp. 15--60.
- Karp, C.R. [1965]. Finite-quantifier equivalence. In *The Theory of Models*, North-Holland.
- Rosenstein, J.G. [1982]. *Linear Orderings.* Academic Press.
- Scott, D. [1965]. Logic with denumerably long formulas and finite strings of quantifiers. In *The Theory of Models*, North-Holland.
- Segerberg, K. [1970]. Modal logics with linear alternative relations. *Theoria* 36, pp. 301--322.
- Sehtman (Shehtman), V.B. [1978]. On some two-dimensional modal logics. In *Proc. 8th Internat. Congress of Logic, Methodology and Philos. of Science*, Moscow.
- Shelah, S. [1975]. The monadic theory of order. *Annals of Math.* 102, pp. 379--419.
