# Section 7.2: Since and Until

> **Source**: Blackburn, P., de Rijke, M., and Venema, Y. (2002). *Modal Logic*. Cambridge Tracts in Theoretical Computer Science 53. Cambridge University Press.
>
> **Extract**: Chapter 7 "Extended Modal Logic", Section 7.2 "Since and Until", pages 428--436.
>
> **Note**: This is a manual transcription of the mathematical content for use in formal verification. All theorem/definition/lemma numbering follows the original text.

---

## 7.2 Since and Until

The modal operators considered in previous chapters all have satisfaction definitions involving only existential or only universal quantifiers. In this section we look at a popular temporal logic whose operators are based on modalities with more complex satisfaction definitions: $S$ (since) and $U$ (until). The main reason for considering these modalities is, again, to achieve an increase in expressive power. We'll first give some examples demonstrating why the increased expressivity is useful. We'll then learn that (over Dedekind complete frames) we have actually achieved expressive *completeness*: any expression in the first-order correspondence language (in one free variable) has an equivalent in the modal language in $S$ and $U$. Finally, we'll show that this (first-order) *expressive* completeness leads to (modal) *deductive* completeness.

### Basic definitions

The basic operators needed for temporal reasoning seem to be $F$ and $P$. These allow us to say things like 'Something good will happen' and 'Something bad has happened.'

But in several application areas this is not enough. For example, in the semantics of concurrent programs one often needs to be able to express properties of executions of programs that have the general format 'Something good is going to happen, *and until that time nothing bad will happen.*' Or, more concretely: $p$ will be the case, and until that time $q$ will hold.

Such properties are sometimes called *guarantee properties* in the computational literature. To state them, the binary *until* operator $U$ can be used; its satisfaction definition reads:

$$t \Vdash U(\phi, \psi) \quad\text{iff}$$
$$\text{there is a } v > t \text{ such that } v \Vdash \phi \text{ and for all } s \text{ with } t < s < v\colon\; s \Vdash \psi.$$

The mirror image of $U$ is the *since* operator $S$:

$$t \Vdash S(\phi, \psi) \quad\text{iff}$$
$$\text{there is a } v < t \text{ such that } v \Vdash \phi \text{ and for all } s \text{ with } v < s < t\colon\; s \Vdash \psi.$$

That's the basic idea -- but before going further, let's make our discussion a little more precise. The set of $S, U$*-formulas* is built up from a collection $\Phi$ of proposition letters, the usual boolean connectives, and the *binary* operators $S$ and $U$. The *mirror image* of a formula $\phi$ is obtained by simultaneously substituting $S$ for $U$ and $U$ for $S$ in $\phi$.

$S, U$-formulas are interpreted on frames of the form $\mathfrak{F} = (T, <)$, where $T$ is a set of time points and $<$ is a binary relation on $T$. $U$ looks forward along $<$, and $S$ looks backwards. We use the notation $(T, <)$ for frames (rather than our usual $(T, R)$) because here we are primarily interested in the temporal interpretation of $S$ and $U$. In fact, will be working with frames $(T, <)$ such that $<$ is a Dedekind complete order -- more on this below. To emphasize our interest in the temporal interpretation, we will often refer to frames as *flows of time*. As usual, a valuation is a function assigning subsets of $T$ to the proposition letters in the language.

How does the language in $S$ and $U$ relate to the basic temporal language? First, observe that $F$ and $P$ are definable in the language with $S$ and $U$: we can define $F\phi := U(\phi, \top)$, $P\phi := S(\phi, \top)$, $G\phi := \neg F\neg\phi$ and $H\phi := \neg P\neg\phi$. Thus the language with $S$ and $U$ is at least as strong as the basic temporal language. In fact, it is strictly stronger. For a start, we saw in Exercise 2.2.4 that the basic temporal language couldn't define $U$. Moreover, as the following proposition shows, even if we restrict attention to models based on the real numbers, the basic temporal language still isn't strong enough to define $U$.

**Proposition 7.10.** *$U$ is not definable over $(\mathbb{R}, <)$ using $F$ and $P$.*

*Proof.* We will give two models that agree on all formulas in the language with $F$ and $P$ only, but that can be distinguished using the until operator. Consider the following model $\mathfrak{M}_1$ based on the reals:

$V_1(p) = \{r \mid r \in \mathbb{Z}\}$, and $V_1(q) = \{0\} \cup \{r \mid \exists n \in \mathbb{N}\,(-2n - 1 < r < -2n)\} \cup \{r \mid \exists n \in \mathbb{N}\,(2n < r < 2n+1)\}$.

So $\mathfrak{M}_1, 0 \Vdash U(p,q)$.

Next, consider the model $\mathfrak{M}_2$ which differs from $\mathfrak{M}_1$ only in that $q$ holds on $(-1, 0)$ rather than at $0$ in the region around the origin. Then $\mathfrak{M}_2, 0 \nVdash U(p,q)$.

We leave it to the reader to show that the models $\mathfrak{M}_1$ and $\mathfrak{M}_2$ agree on all formulas in $F$ and $P$, but that $\mathfrak{M}_1, 0 \Vdash U(p,q)$, whereas $\mathfrak{M}_2, 0 \nVdash U(p,q)$ (see Exercise 7.2.1). $\dashv$

So the temporal language in $S$ and $U$ is expressive -- but just how expressive is it? To answer such questions we need a correspondence language and a standard translation of $S$ and $U$ into the correspondence language. Let $\Phi$ be a collection of proposition letters, and let $\mathcal{L}^1_{<}(\Phi)$, or simply $\mathcal{L}^1_{<}$, be the first-order language with unary predicate symbols corresponding to the proposition letters in $\Phi$, and with $=$ and $<$ as binary relation symbols. We use $\mathcal{L}^1_{<}(x)$ to denote the set of $\mathcal{L}^1_{<}$ formulas having one free variable $x$. Note: this is the familiar correspondence language for the basic temporal language, except that we are using $<$ rather than $R$ as the binary relation symbol.

The *standard translation* $ST_x$ for the until operator $U$ is

$$ST_x(U(\phi, \psi)) \;=\; \exists z\,(x < z \;\wedge\; ST_z(\phi) \;\wedge\; \forall y\,(x < y < z \;\to\; ST_y(\psi))).$$

The standard translation of $S$ is the mirror image of that of $U$. Observe that we need 3 variables to specify the translation of since and until! We only needed 2 variables to specify the translation of the basic modal operators (see Proposition 2.49).

Let $\mathsf{K}$ be a class of models, $ML$ a modal or temporal language, and $\mathcal{L}$ a classical language. Then $ML$ is *expressively complete over* $\mathsf{K}$, if every $\mathcal{L}^1_{<}(x)$-formula has an equivalent (over $\mathsf{K}$) in the modal language $ML$. The study of expressive completeness is an important theme in temporal logics with since and until because of the following remarkable result: the language with $S$ and $U$ is expressively complete over the class of all Dedekind complete flows of time (we will define this class shortly). Moreover, below we will define an even richer temporal language that is expressively complete for the class of *all* linear flows of time. In the remainder of this section we will briefly explain these expressive completeness results, and use them to obtain a deductive completeness result for since and until over well-ordered flows of time.

### Further preliminaries

A flow of time is called *Dedekind complete* if every subset with an upper bound has a least upper bound. The standard examples are the reals $(\mathbb{R}, <)$ and the natural numbers $(\mathbb{N}, <)$. A flow of time is *well-ordered* if every non-empty subset has a smallest element; the canonical example here is $(\mathbb{N}, <)$.

To arrive at our goal of axiomatizing the well-ordered flows of time, we make a detour through a still richer temporal language built using the *Stavi connectives*.

**Definition 7.11 (The Stavi Connectives).** To introduce the Stavi connectives we need the notion of a gap. A *gap* of a frame $\mathfrak{F} = (T, <)$ is a proper subset $g \subset T$ which is downward closed (that is, $t \in g$ and $s < t$ implies $s \in g$), and which does not have a supremum. One can think of a gap as a hole in a Dedekind-incomplete flow of time; see Figure 7.1. Now, $U'(\phi, \psi)$ holds at a point $t$ if the situation depicted in the figure holds; that is, if

(i) there are a point $s$ and a gap $g$ such that $t \in g$ and $s \notin g$;
(ii) $\psi$ holds between $t$ and $g$;
(iii) $\phi$ holds between $s$ and $g$; and
(iv) $\neg\psi$ is true arbitrarily soon after $g$.

$S'(\phi, \psi)$ is the mirror image of $U'(\phi, \psi)$.

The above informal second-order definition (we quantify over gaps, and hence over sets) can be replaced by a first-order definition; see Exercise 7.2.2. $\dashv$

**Theorem 7.12 (Expressive Completeness).**

(i) *$U$, $S$ is complete over Dedekind complete flows of time.*
(ii) *$U$, $S$, $U'$, $S'$ are complete over all linear flows of time.*

Next, we need a complete axiom system for the class of linear flows of time:

**Definition 7.13.** Consider the following collection of axioms:

| Label | Axiom |
|-------|-------|
| (A1a) | $G(p \to q) \to (U(p,r) \to U(q,r))$ |
| (A2a) | $G(p \to q) \to (U(r,p) \to U(r,q))$ |
| (A3a) | $p \wedge U(q,r) \to U(q \wedge S(p,r), r)$ |
| (A4a) | $U(p,q) \wedge \neg U(p,r) \to U(q \wedge \neg r, q)$ |
| (A5a) | $U(p,q) \to U(p, q \wedge U(p,q))$ |
| (A6a) | $U(q \wedge U(p,q), q) \to U(p,q)$ |
| (A7a) | $U(p,q) \wedge U(r,s) \to U(p \wedge r, q \wedge s) \vee U(p \wedge s, q \wedge s) \vee U(q \wedge r, q \wedge s)$ |
| (A$i$b) | the mirror images of (A1a)--(A7a) |
| (D) | $(F\top \to U(\top, \bot)) \wedge (P\top \to S(\top, \bot))$ |
| (L) | $H\bot \vee PH\bot$ |
| (W) | $Fp \to U(p, \neg p)$ |
| (N) | $\mathsf{D} \wedge \mathsf{L} \wedge F\top$ |

$\dashv$

Axioms (D), (L), (W), and (N) are discussed in Lemma 7.14 and Exercise 7.2.3 below. As to the other axioms, (A1a) and (A2a) can be viewed as counterparts of the familiar distribution or K axiom $\Box(p \to q) \to (\Box p \to \Box q)$. (A3a) captures the fact that $U$ and $S$ explore relations that are each other's converse. (A4a) and (A5a) connect the current and the future point (at which something good is going to happen) on the one hand with the points in between on the other hand. (A6a) expresses transitivity of the flow of time, and, finally, (A7a) forces the flow of time to be linearly ordered.

**Lemma 7.14.** *Let $\mathfrak{F}$ be a linear flow of time. Then*

(i) *$\mathfrak{F} \models \mathsf{D}$ iff $\mathfrak{F}$ is a discrete ordering.*
(ii) *$\mathfrak{F} \models \mathsf{W} \wedge \mathsf{L}$ iff $\mathfrak{F}$ is a well-ordering.*
(iii) *$\mathfrak{F} \models \mathsf{W} \wedge \mathsf{N}$ iff $\mathfrak{F} \cong (\mathbb{N}, <)$.*

The proof of Lemma 7.14 is left as Exercise 7.2.3.

Next, we define three axiom systems: **B**, **BW**, and **BN**. The set of axioms of **B** consists of all classical tautologies, (A1a)--(A7a), and (A1b)--(A7b). **BW** extends **B** with W, and **BN** extends **BW** with N. All three derivation systems have modus ponens, temporal generalization, and uniform substitution as derivation rules:

| Rule | Statement |
|------|-----------|
| (MP) | If $\vdash \phi$ and $\vdash \phi \to \psi$, then $\vdash \psi$. |
| (TG) | If $\vdash \phi$, then $\vdash G\phi$ and $\vdash H\phi$. |
| (SUB) | If $\vdash \phi$, then $\vdash [\psi/p]\phi$. |

A model $\mathfrak{M}$ is called an **X-model** if it has $\mathfrak{M} \models \phi$ for all **X**-theorems $\phi$, where $\mathbf{X} \in \{\mathbf{B}, \mathbf{BW}, \mathbf{BN}\}$.

For future use we state the following axiomatic completeness result:

**Theorem 7.15.** *For all sets of $S,U$-formulas $\Sigma$ and formulas $\phi$: $\Sigma \vdash_{\mathbf{B}} \phi$ iff $\Sigma \models_{\mathbf{B}} \phi$.*

We need one more preliminary result, on definable properties. By Exercise 7.2.4, well-foundedness is a condition on linear frames which cannot be expressed in first-order logic: it involves an essential second-order quantification over all subsets of the universe. However, to arrive at our expressive completeness result we can get by with less, namely the condition that every *first-order definable* non-empty subset must have a smallest element; one can show that definably well-ordered models are sufficiently similar to genuine well-ordered models.

The following definition and lemma capture what we need.

**Definition 7.16.** Let $\alpha$ be a first-order formula in $\mathcal{L}^1_{<}(x)$, $\mathfrak{M} = (T, <, V)$ a model for $\mathcal{L}^1_{<}$. Define $X_\alpha$ to be the set defined by $\alpha$, that is, $X_\alpha := \{t \in T \mid \mathfrak{M} \models \alpha[t]\}$. Then, $\mathfrak{M}$ is called *definably well-ordered* if for all $\alpha(x) \in \mathcal{L}^1_{<}$, the set $X_\alpha$ has a smallest element.

Two $\mathcal{L}^1_{<}$-models $\mathfrak{M}_1$ and $\mathfrak{M}_2$ are called *$n$-equivalent*, notation $\mathfrak{M}_1 \equiv^n_{FOL} \mathfrak{M}_2$, if for all first-order sentences $\alpha \in \mathcal{L}^1_{<}$ of quantifier depth at most $n$, $\mathfrak{M}_1 \models \alpha$ iff $\mathfrak{M}_2 \models \alpha$. $\dashv$

**Proviso.** For the remainder of this section we will assume that our collection of proposition letters $\Phi$ is finite. This is not an essential restriction, but it simplifies some of the arguments below (see Exercise 7.2.5 for a way of circumventing the assumption).

**Lemma 7.17.** *Let $n \in \mathbb{N}$. Then every definably well-ordered linear model is $n$-equivalent to a fully well-ordered model.*

*Proof.* Let $\mathfrak{M} = (T, <, V)$ be a definably well-ordered linear model. For $a, b \in T$ such that $b < a$, define $[b, a) = \{t \in T \mid b \le t < a\}$, and $(\infty, a) = \{t \in T \mid t < a\}$. Obviously, we can view such sets -- with the ordering and valuation induced by $\mathfrak{M}$ -- as linear $\mathcal{L}^1_{<}$-models in their own right. Define

$$Z := \{a \in T \mid \forall b < a\;([b,a) \text{ has a well-ordered } n\text{-equivalent})\}.$$

By Exercise 7.2.6 there are only finitely many first-order formulas $\alpha(x,y)$ of quantifier depth at most $n$, say $\alpha_1(x,y), \ldots, \alpha_m(x,y)$. Let $\beta_1(x,y), \ldots, \beta_k(x,y) \in \{\alpha_1(x,y), \ldots, \alpha_m(x,y)\}$ be such that if $\mathfrak{M} \models \beta_i(x,y)[ab]$ then $[b,a)$ has a well-ordered $n$-equivalent. Then $Z$ is defined by the formula

$$\alpha(x) := \forall y\left(y \le x \to \bigvee_{i \le k} \beta(x,y)\right).$$

As a consequence, $T \setminus Z$ (the complement of $Z$ in $\mathfrak{M}$) is definable as well. We will now show that $T \setminus Z$ is empty. For, suppose otherwise. Then $Z$ must have a smallest element $a$ (as $\mathfrak{M}$ is definably well-ordered). Distinguish the following cases:

(i) $a$ is the first element of $T$,
(ii) $a$ has an immediate successor, and
(iii) there exists an ascending sequence $(b_\xi)_{\xi < \lambda}$, which is cofinal in $[b, a)$ and such that $b_0 = b$. (That is, $b_0 = b$, $b_i < b_j$ whenever $i < j$, and for all $c \in [b, a)$ there exists a $b_i > c$.)

It is easy to see that the first two cases lead to contradictions. As to the third case, since $a$ is the minimal element of $T \setminus Z$, all $b_\xi$ are in $Z$. So, by definition, every interval $[b_\xi, b_{\xi+1})$ has a well-ordered $n$-equivalent $\mathfrak{M}_\xi$. By Exercise 7.2.7 the lexicographic sum $\sum_{\xi < \lambda} \mathfrak{M}_\xi$ is well-ordered and an $n$-equivalent to $[b, a)$. But then $a \in Z$ -- a contradiction.

Therefore $T \setminus Z = \varnothing$, and hence $Z = T$, so every interval $[b, a)$ of $T$ has an $n$-equivalent well-ordered model. By using Exercise 7.2.7 again, we see that $\mathfrak{M}$ must have a well-ordered $n$-equivalent, as required. $\dashv$

### Completeness via completeness

With the above preliminaries out of the way, we are now in a position to use the expressive completeness result recorded in Theorem 7.12 to arrive at an axiomatic completeness result for **BW** over well-ordered flows of time.

We need the following lemma.

**Lemma 7.18.** *Every linear **BW**-model is definably well-ordered.*

*Proof.* Let $\mathfrak{M}$ be a linear model satisfying all instances of the **BW**-theorems. We will prove that every non-empty $\mathcal{L}^1_{<}$-definable subset of $T$ has a smallest element via detour using the Stavi connectives $S'$ and $U'$.

Let $X$ be a non-empty $\mathcal{L}^1_{<}$-definable subset of $T$. By Theorem 7.12.2 it follows that $X$ has a defining formula $\phi$ in the language with $S$, $U$, $S'$, $U'$. If we can show that $\phi$ does in fact belong to the sublanguage with $S$ and $U$, then we are done, because then we can use the validity of the axioms W and L to show that there must be a *minimal* element in $X$.

It suffices to show that *every* formula in the language with $S$, $U$, $S'$, $U'$ is equivalent to an $S,U$-formula over $\mathfrak{M}$. To this end we argue by induction of formulas in the richer language. The only non-trivial case is for formulas of the form $U'(\phi, \psi)$ (and their mirror images), where $\phi$ and $\psi$ are already assumed to equivalent to $S$, $U$ formulas by the induction hypothesis. So assume $\mathfrak{M}, t \Vdash U'(\phi, \psi)$. Then there is a gap $g$ after $t$ such that (i) $\psi$ holds everywhere between $t$ and $g$, and (ii) $\psi$ is false arbitrarily soon after $g$. Now (i) implies that $\mathfrak{M}, t \Vdash F\psi$, so by the validity of the W axiom in $\mathfrak{M}$ it follows that $\mathfrak{M}, t \Vdash U(\neg\psi, \psi)$. But this contradicts (ii). $\dashv$

**Theorem 7.19.** ***BW** is (weakly) complete for the class of all well-ordered flows of time.*

*Proof.* Let $\phi$ be a **BW**-consistent formula. Construct a maximal **BW**-consistent set $\Delta$ with $\phi \in \Delta$. As **BW** extends **B**, $\Delta$ must also be **B**-consistent. By Theorem 7.15 there exists a linear model $\mathfrak{M} = (T, <, V)$ in which $\Delta$ is satisfiable. Clearly, for every $S,U$-formula $\psi$, the formula $HW(\psi) \wedge W(\psi) \wedge GW(\psi)$ is in $\Delta$, where $W(\psi)$ is the W axiom instantiated for $\psi$. Thus $\mathfrak{M}$ is a **BW**-model, and hence, by Lemma 7.18 it is definably well-ordered.

Now, for the final step, let $n$ be the quantifier rank of $ST(\phi)$. By Lemma 7.17 there is well-ordered model $\mathfrak{M}^*$ that is $n+1$-equivalent to $\mathfrak{M}$. Therefore, $\mathfrak{M}^* \models \exists x\, ST(\phi)(x)$, and we are done. $\dashv$

Using Theorem 7.19 it is easy to obtain a further completeness result, for the temporal logic of the natural numbers.

**Theorem 7.20.** ***BN** is weakly complete for $(\omega, <)$, the natural numbers with their standard ordering.*

The proof of Theorem 7.20 is left as Exercise 7.2.8.

### Exercises for Section 7.2

**7.2.1** Supply the missing details for the proof of Proposition 7.10.

**7.2.2** Give a first-order definition for the Stavi connectives introduced in Definition 7.11 -- you may assume that we are working on linear flows of time.

**7.2.3** Prove Lemma 7.14. That is, show that D defines discrete orderings, that $\mathsf{W} \wedge \mathsf{L}$ defines well-orderings, and that $\mathsf{W} \wedge \mathsf{N}$ picks out the natural numbers in their usual ordering up to isomorphism.

**7.2.4** Show that well-foundedness is a condition on linear frames which cannot be expressed in first-order logic.

**7.2.5** Throughout this section we assumed that the collection of proposition symbols that we are working with is finite. Show that this assumption can be lifted.

**7.2.6** Show that, over a finite vocabulary, there are at only finitely many non-equivalent first-order formulas $\alpha(x,y)$ of quantifier depth at most $n$.

**7.2.7** Show that the lexicographic sum of a collection of structures that are well-ordered and $n$-equivalent to a given structure $\mathfrak{M}$, is again well-ordered and $n$-equivalent to $\mathfrak{M}$.

**7.2.8** Prove Theorem 7.20: show that **BN** is weakly complete for $(\omega, <)$, the natural numbers with their standard ordering.
