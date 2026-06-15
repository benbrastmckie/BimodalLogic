## 6.9 Lemma

*If $a, b$ are elements of finite Kripke models in $K$ and $[\![a]\!]^{2\rho a + 1} = [\![b]\!]^{2\rho a + 1}$ then $[\![a]\!]^n = [\![b]\!]^n$ for all $n \in \mathbb{N}$.*

*Proof.* Induction on $\rho a$. First, if $\rho a = 0$, $a$ is maximal and the result is obvious. Next, assume $\rho a = n > 0$, $[\![a]\!]^{2n+1} = [\![b]\!]^{2n+1}$ and $m$ is minimal such that $[\![a]\!]^m \neq [\![b]\!]^m$. Let $I$ use a winning strategy in the $m$-game on $(a, b)$ which always picks elements of minimal possible rank. If, using this strategy, $I$ starts picking $a'$ or $b'$, $II$ answers $b'$ resp. $a'$ and $I$ "looses a tempo": there are $m - 1$ moves left for either player and so $II$ can win by choice of $m$. If $I$ starts with $a' > a$, $II$ picks $b' \geq b$ with $[\![b']\!]^{2n} = [\![a']\!]^{2n}$ and wins by the inductive hypothesis. If $I$ starts with $b' > b$, $II$ picks $a' \geq a$ such that $[\![a']\!]^{2n} = [\![b']\!]^{2n}$. There are two cases to distinguish.

(i) $a' \neq a$. Then $\rho a' < \rho a$ and $II$ wins by the inductive hypothesis.

(ii) $a' = a$. Consider the second move of $I$. This cannot be $a'$ or $b'$ for tempo-loss will result. Also, it cannot be $b'' > b'$ since $I$'s strategy picks elements of least rank, so it would have chosen $b''$ as a first move already. Therefore, it will be some $a'' > a'$ and $II$ wins by the inductive hypothesis. $\boxtimes$

## 6.10 Problem

For each $k \in U$, we know by 6.9 that $[\![k]\!]^{2\rho k + 1}$ defines $k$ in the sense that $k$ is the only element of $U$ at which the formula is forced. Determine for each $k \in U$ the *least* $n$ such that $[\![k]\!]^n$ defines $k$ (and give a more manageable equivalent of $[\![k]\!]^n$). A special case of this problem has a simple answer, cf. chapter 9 below.

## 6.11 Lemma

*For all $k \in U$ and $n \in \mathbb{N}$ there is an $l \in U$ such that*

1. *$[\![l]\!]^n = [\![k]\!]^n$;*
2. *$\rho l \leq n$.*

*Proof.* Similar to the one of 6.7. Induction on $n$. For $n = 0$, this is clear. Next, let $C$ be the set of $l \in \bigcup_{i \leq n} U_i$ such that for some $k' > k$, $[\![l]\!]^n = [\![k']\!]^n$. Let $A$ be the set of minimal elements of $C$. The required $l$ is constructed from $A$ and $\sigma k$. $\boxtimes$

## 6.12 On Normal Forms

*Let $\varphi$ be a formula of modal rank $n$. On Kripke models in $K$, $\varphi$ is equivalent with $\bigvee\{[\![k]\!]^n \mid \rho k \leq n \wedge k \Vdash \varphi\}$.*

---

# Chapter 3: Monadic $\Pi^1_1$-Theories of $\Pi^1_1$-Properties: Linear Orderings (pp. 36--57)

## Part II: Completeness

## 3.1 Introduction: $\omega$ and finite orderings

Natural axioms of a number of theories are of the second-order ($\Pi^1_1$-) form $\forall R\,\varphi(R)$, where $\varphi$ is first-order and $R$ is a second-order variable. For instance, the induction principle of arithmetic, completeness of the reals, Zermelo's Aussonderungsaxiom and the Fraenkel-Skolem replacement axiom in set theory are of this type.

As to first-order versions of these principles, the natural option is to require $\varphi(R)$ not for all $R$ but for parametrically first-order definable $R$ only, thus replacing the second-order axiom by its corresponding first-order schema.

Obviously, the new theory will have models not allowed by the old one (by the Löwenheim-Skolem-Tarski theorem for instance) and hence it may turn out to be strictly weaker than its second-order companion. For instance, second-order arithmetic is categorical, hence it implies first-order sentences beyond the scope of the first-order induction schema.

On the other hand, if the language is restricted sufficiently, conservation may occur. This chapter contains a number of examples. They all concern theories of linear orderings (but see chapter 4 below where one of our examples is generalized to trees); conservation is proved with respect to monadic $\Pi^1_1$-sentences.

The method of proof consists in showing how to transfer counter-examples to a $\Pi^1_1$-sentence on a "non-standard" model to a standard model.

**3.1.1 Theorem.** *If 1. $(M, <) \equiv^n (\omega, <)$ and 2. $\mathbf{M} = (M, <, X_1, \ldots, X_k)$ satisfies definable induction, then $\mathbf{M}$ has $n$-equivalents of order type $\omega$ for every $n$.*

*Proof.* By the Löwenheim-Skolem theorem, we may assume $\mathbf{M}$ to be countable. Define $X = \{a \in M \mid \forall b < a\,([b, a) \text{ has a finite } n\text{-equivalent})\}$.

Now, $X$ is a definable set: $[b, a)$ has a finite $n$-equivalent iff it satisfies an $n$-characteristic belonging to a finite model; and of these, there are only finitely many (see 1.7.1). Hence, $X$ is defined by the formula $\forall y < x\,\bigvee\{\tau^{[y,x)} \mid \tau \in Z\}$, where $Z$ is the set of such characteristics and $\tau^{[y,x)}$ denotes relativisation of quantifiers in $\tau$ to the interval $[y, x)$. Trivially, $X$ contains the least element of $M$. Also, $X$ is closed under immediate successors: if $S$ is a finite $n$-equivalent of $[b, a)$ and $c$ is the immediate successor of $a$ then it is clear that the ordered sum $S + \{a\}$ is the required finite $n$-equivalent of $[b, c)$. By definable induction then, $X = M$. Let $a_0$ be the least element of $\mathbf{M}$ and choose $a_0 < a_1 < a_2 < \cdots$ cofinal in $M$ (which we have assumed to be countable!). Choose a finite $n$-equivalent $S_i$ of $[a_i, a_{i+1})$ for each $i$. Then $S = \sum_i S_i$ is the required $n$-equivalent of order type $\omega$. (For the handling of ordered sums, cf. below, in particular 3.1.7.) $\boxtimes$

**3.1.2 Theorem.** *If the linearly ordered model $\mathbf{M}$: 1. has least and greatest element and every non-maximal element has an immediate successor; 2. satisfies definable restricted induction; then $\mathbf{M}$ has finite $n$-equivalents for all $n$.*

### Key Tools: Condensations and Ordered Sums

**3.1.6 Lemma.** *Let $R$ be any transitive binary relation on the ordered model $M$. Define $\sim = \sim_R$ by: $a \sim b$ iff one of the following holds: (i) $a = b$; (ii) $a < b$ and for all $c, d$ such that $a < c < d < b$: $cRd$; (iii) $b < a$ and for all $c, d$ such that $b < c < d < a$: $cRd$. Then $\sim$ induces a condensation.*

**3.1.7 Lemma.** *If for all $i \in I$, $m(i) \equiv^n m'(i)$, then $\sum_{i \in I} m(i) \equiv^n \sum_{i \in I} m'(i)$.*

**3.1.8 Lemma.** *Suppose that $I$ and $J$ are ordered sets and that $m$ and $m'$ associate ordered models $m(i)$ resp. $m'(j)$ to each $i \in I$ resp. $j \in J$ such that: $(I, \{i \mid m(i) \models \sigma\})_{\sigma \in Z} \equiv^n (J, \{j \mid m'(j) \models \sigma\})_{\sigma \in Z}$, where $Z$ is the set of $n$-characteristics. Then $\sum_{i \in I} m(i) \equiv^n \sum_{j \in J} m'(j)$.*

### The Conservation Theorem

**3.1.5 Theorem.** *The following two conditions are equivalent:*

*(i) for each first-order formula $\varphi = \psi(X_1, \ldots, X_k)$ in the language $L_k$: if $\Sigma + \forall R\,\varphi(R) \models \forall X_1 \cdots \forall X_k\,\psi$, then $\Sigma + L_k\text{-definably-}\varphi \models \psi(X_1, \ldots, X_k)$;*

*(ii) each model $(M, U_1, \ldots, U_k)$ of $\Sigma + L_k\text{-definably-}\varphi$ has an $n$-equivalent satisfying $\Sigma + \forall R\,\varphi(R)$ for each $n$.*

## 3.2 Monadic $\Pi^1_1$-theory of scattered orderings

A linear ordering $M = (M, <)$ is called **scattered** if it does not embed the ordering $(\mathbb{Q}, <)$ of the rationals.

**3.2.3 Lemma.** *An ordering is scattered iff it has no densely ordered condensation.*

**3.2.4 Theorem.** *If $\mathbf{M}$ is definably scattered, then it has scattered $n$-equivalents for each $n$.*

*Proof.* Define $\sim$ in the fashion of 3.1.6 with $aRb$ meaning that $(a, b)$ has a scattered $n$-equivalent (if $a < b$). By 3.2.1, $R$ is transitive. Hence, $\sim$ induces a condensation by 3.1.6. Also, $\sim$ is definable.

*Claim 1:* each equivalence class has a scattered $n$-equivalent.

*Claim 2:* the induced ordering of the equivalence classes is dense.

Since $\mathbf{M}$ is definably scattered, $\sim$ cannot have more than one equivalence class: $M$ itself. Consequently, $\mathbf{M}$ must have a scattered $n$-equivalent by the first claim. $\boxtimes$

## 3.3 Monadic $\Pi^1_1$-theory of complete orderings, well-orderings and of the reals

The ordering $(M, <)$ is **complete** if each non-empty set with an upper bound has a least upper bound (a sup). Hence, $\mathbf{M}$ is called **definably complete** if this holds for definable sets.

**3.3.1 Theorem.** *If $\mathbf{M}$ is definably complete, it has complete $n$-equivalents for each $n$.*

*Proof.* Define $\sim$ in the fashion of 3.1.6 with $aRb$ meaning: $a < b$ and $(a, b)$ has a complete $n$-equivalent. Notice that $R$ is transitive. Hence, $\sim$ induces a condensation by 3.1.6. Furthermore, $\sim$ is definable.

*Claim 1:* each equivalence class with an upper (lower) bound has a greatest (resp. least) element and each equivalence class has a complete $n$-equivalent.

*Claim 2:* the induced ordering on the class $M/{\sim}$ of equivalence classes is dense.

*Claim 3:* there is a proper (open) interval $D$ of $M/{\sim}$ and a set $Z \subseteq T$ such that (i) every $I \in D$ has $\tau(I) \in Z$, and (ii) if $\sigma \in Z$ then $\{I \in D \mid \tau(I) = \sigma\}$ is dense in $D$.

*Claim 4:* $D$ has but one element.

The contradiction follows by constructing a complete $n$-equivalent $N$ of the submodel $\bigcup E$ as $N = \sum_{x \in \mathbb{R}} h(x)$, where $h\colon \mathbb{R} \to Z$ is any partition of $\mathbb{R}$ into $|Z|$ classes each of which is dense in $\mathbb{R}$. $\boxtimes$

**3.3.3 Lemma.** *$\mathbf{M}$ is (definably) well-ordered iff it is (definably) complete, has a least element, and every non-maximal element has an immediate successor.*

**3.3.4 Corollary.** *If $\mathbf{M}$ is definably well-ordered, it has well-ordered $n$-equivalents for each $n$.*

### The Suslin Property and $\mathbb{R}$

**3.3.7 Definition.** $\mathbf{M}$ has **property $\mathcal{I}$** if each densely ordered condensation of $\mathbf{M}$ has a dense set of singletons.

**3.3.8 Lemma.** *Models of order type $\lambda$ and, more generally, all complete orderings with the Suslin property have property $\mathcal{I}$.*

**3.3.9 Theorem.** *If $\mathbf{M}$ is definably-$\mathcal{I}$, definably complete and densely ordered without endpoints, then it has $n$-equivalents of order type $\lambda$ for each $n$.*

**3.3.10 Corollary.** *Every ordering which has $\mathcal{I}$, is complete and is densely ordered without endpoints satisfies the monadic $\Pi^1_1$-theory of $\mathbb{R}$.*

## 3.4 Appendix: Strengthening 3.2.4 and 3.3.4

Let $\mathcal{M}_0$ be the smallest class of order types such that (1) $1 \in \mathcal{M}_0$; (2) $\alpha, \beta \in \mathcal{M}_0 \Rightarrow \alpha + \beta \in \mathcal{M}_0$; (3) $\alpha \in \mathcal{M}_0 \Rightarrow \alpha \cdot \omega, \alpha \cdot \omega^* \in \mathcal{M}_0$.

**3.2.4' Theorem.** *If $\mathbf{M}$ is definably scattered, it has (scattered) $n$-equivalents with order type in $\mathcal{M}_0$ for each $n$.*

Let $K$ be the smallest class of order types such that (1) $1 \in K$; (2) $\alpha, \beta \in K \Rightarrow \alpha + \beta \in K$; (3) $\alpha \in K \Rightarrow \alpha \cdot \omega \in K$. Clearly, $K \subseteq \mathcal{M}_0$. All types in $K$ are well-ordered and it is easy to see that $\alpha \in K$ iff $0 < \alpha < \omega^\omega$.

**3.3.4' Theorem.** *If $\mathbf{M}$ is definably well-ordered, it has (well-ordered) $n$-equivalents with order-type in $K$ for each $n$.*

**3.4.1 Corollary.** *(Ehrenfeucht) $\omega \equiv^\infty (\text{OR}, <)$ (where OR is the class of all ordinals).*

---

# Chapter 1: Fraissé-Ehrenfeucht Theory for $L_{\infty\omega}$ and Some of Its Fragments (pp. 1--22)

## Part I: Definability

> *It were not best that we should all think alike; it is difference of opinion that makes horse-races.* — Pudd'nhead Wilson's Calendar

## 1.0 Introduction

This chapter introduces five guises of $\alpha$-equivalence between models, where $\alpha$ is an arbitrary ordinal.

For $\alpha = \omega$, this relation (called *elementary equivalence* and denoted by $\equiv$) is a basic one in model theory. For models of the same finite similarity-type, $\mathbf{A} \equiv \mathbf{B}$ just means that $\mathbf{A}$ and $\mathbf{B}$ have the same true (first-order) sentences. However, there are some uses for refinements, as is argued below.

$\alpha$-Equivalence for *finite* $\alpha$ is explained game-theoretically as follows. Suppose $\mathbf{A}$ and $\mathbf{B}$ are models (of the same similarity type) and $n \in \mathbb{N}$. The *$n$-game* on $\mathbf{A}$ and $\mathbf{B}$, $G(\mathbf{A}, \mathbf{B}, n)$, has two players, $I$ and $II$. They move alternately. $I$ is allowed the first move; each player is allowed $n$ moves. A **move** consists of an element in either $A$ or $B$. However, if player $I$ chooses an element in $A$ (resp. $B$) then player $II$ has to counter in $B$ (resp. $A$). Therefore, a move of player $I$ and the following counter-move of player $II$ form an ordered pair in $A \times B$ (where $A$ and $B$ are the *universes* of $\mathbf{A}$ and $\mathbf{B}$ respectively).

When the game is over, the set of ordered pairs of moves is an at most $n$-element relation $h \subseteq A \times B$. $II$ has **won** the play by definition if $h$ is a **partial isomorphism** between $\mathbf{A}$ and $\mathbf{B}$, that is, if $h$ is an injection on its domain which preserves the structure of the models. Of course, the larger $n$, the better $I$'s chances to defeat $II$.

Finally, $\mathbf{A}$ and $\mathbf{B}$ are called **$n$-equivalent** if $II$ has a **winning strategy** for $G(\mathbf{A}, \mathbf{B}, n)$, that is, a method by which he can beat $I$ no matter the choice of moves by $I$. So, in the example above, $(\mathbb{Z}, R)$ and $(\mathbb{Z}, R)/(9)$ are 3-equivalent but not 4-equivalent.

**1.0.1 Proposition.** *Finite linear orderings $\mathbf{A}$ and $\mathbf{B}$ are $n$-equivalent iff $|A| = |B|$ or $|A|, |B| \geq 2^n - 1$.*

**1.0.2 Lemma.** *Suppose that $\mathbf{A} = (A, <)$ and $\mathbf{B} = (B, <)$ are linear orderings. Then $\mathbf{A} \equiv^{n+1} \mathbf{B}$ iff ("back") for all $b \in B$ there exists $a \in A$ such that $a{\downarrow} \equiv^n b{\downarrow}$ and $a{\uparrow} \equiv^n b{\uparrow}$ and ("forth") for all $a \in A$ there exists $b \in B$ such that $a{\downarrow} \equiv^n b{\downarrow}$ and $a{\uparrow} \equiv^n b{\uparrow}$.*

**1.0.3 Example.** (i) If $m \geq 2^n - 1$, then $m \equiv^n \omega + \omega^*$. (ii) For all $n$: $\omega \equiv^n \omega + \zeta$.

## 1.1 Notation and Terminology

A **model** is a complex $\mathbf{A} = (A, \ldots)$ consisting of a set $A$ (which, contrary to usual logical convention, often is allowed to be empty) together with any number of ("finitary") relations. Thus, functions (and, often, constants as well) are excluded from models.

A **language** (or **similarity-type**) is a set of relation-symbols, together with a specification of the number of arguments (the **arity**) for each symbol in the set.

$h\colon A \to B$ is an **isomorphism** between the $L$-models $\mathbf{A} = (A, {}^*)$ and $\mathbf{B} = (B, {}^\circ)$ if it is bijective and preserves corresponding relations.

## 1.2 $\alpha$-Equivalence

$h\colon A \to B$ is a **partial isomorphism** between the $L$-models $\mathbf{A} = (A, {}^*)$ and $\mathbf{B} = (B, {}^\circ)$ if $\text{Dom}\,h$ is finite and $h$ is an isomorphism between $\mathbf{A}|\text{Dom}\,h$ and $\mathbf{B}|\text{Ran}\,h$.

**1.2.1 Definition.** For $L$-models $\mathbf{A}$, $\mathbf{B}$ and ordinals $\alpha$, $I_\alpha(\mathbf{A}, \mathbf{B})$ is a set of partial isomorphisms between $\mathbf{A}$ and $\mathbf{B}$ defined as follows:

- (i) $I_0(\mathbf{A}, \mathbf{B})$ consists of all partial isomorphisms between $\mathbf{A}$ and $\mathbf{B}$;
- (ii) $h \in I_{\alpha+1}(\mathbf{A}, \mathbf{B})$ iff ("back") for all $b \in B$ there is an $a \in A$ such that $h \cup \{(a, b)\} \in I_\alpha(\mathbf{A}, \mathbf{B})$ and ("forth") for all $a \in A$ there is a $b \in B$ such that $h \cup \{(a, b)\} \in I_\alpha(\mathbf{A}, \mathbf{B})$;
- (iii) for $\alpha$ a limit: $I_\alpha(\mathbf{A}, \mathbf{B}) = \bigcap_{\xi < \alpha} I_\xi(\mathbf{A}, \mathbf{B})$.

$\mathbf{a} = (a_0, \ldots, a_{k-1}) \in A^k$ and $\mathbf{b} = (b_0, \ldots, b_{k-1}) \in B^k$ are called **$\alpha$-equivalent** (notation: $\mathbf{a} \equiv^\alpha \mathbf{b}$) iff the correspondence $(\mathbf{a}, \mathbf{b}) = \{(a_i, b_i) \mid i < k\}$ is in $I_\alpha(\mathbf{A}, \mathbf{B})$. ($\omega$-equivalence usually is called elementary equivalence.)

**1.2.2 Lemma.** *If $\alpha < \beta$ then $I_\beta(\mathbf{A}, \mathbf{B}) \subseteq I_\alpha(\mathbf{A}, \mathbf{B})$.*

## 1.3 Ordinal-bounded Ehrenfeucht Games

Suppose that $\mathbf{A}$ and $\mathbf{B}$ are models for the same language, that $h \in I_0(\mathbf{A}, \mathbf{B})$ and that $\alpha$ is some ordinal. $G(\mathbf{A}, \mathbf{B}, h, \alpha)$ is the following game for two players $I$ and $II$: $I$ and $II$ make moves alternately as follows. $I$ begins. His first move consists of three things: (i) an ordinal $\alpha_0 < \alpha$; (ii) one of the models $\mathbf{A}$, $\mathbf{B}$; (iii) one element of the model chosen under (ii). $II$ now is allowed, as a counter-move, to choose one element from the model not chosen by $I$. This goes on with the proviso that the sequence of ordinals picked by $I$ must be strictly descending. After a finite number of moves, player $I$ must pick the ordinal 0 eventually.

**1.3.2 Theorem.** *In each game $G(\mathbf{A}, \mathbf{B}, h, \alpha)$, one of the players has a winning strategy.*

**1.3.3 Theorem.** *For $h \in I_0(\mathbf{A}, \mathbf{B})$ and $\alpha$ an ordinal the following are equivalent:*

- *(i) $h \in I_\alpha(\mathbf{A}, \mathbf{B})$;*
- *(ii) $II$ has a winning strategy for $G(\mathbf{A}, \mathbf{B}, h, \alpha)$.*

## 1.4 Fraissé-Karp Sequences

A **Karp sequence** for $\mathbf{A}, \mathbf{B}, h, \alpha$ is a sequence $\langle I_\xi \mid \xi \leq \alpha \rangle$ of length $\alpha + 1$ such that:

1. (i) $I_\xi \subseteq I_0(\mathbf{A}, \mathbf{B})$ for all $\xi \leq \alpha$; (ii) $\xi < \delta \leq \alpha \Rightarrow I_\delta \subseteq I_\xi$; (iii) $h \in I_\alpha$;
2. for all $\xi < \alpha$ and $g \in I_{\xi+1}$: ("back") for all $b \in B$ there exists $a \in A$ such that $g \cup \{(a, b)\} \in I_\xi$; ("forth") for all $a \in A$ there exists $b \in B$ such that $g \cup \{(a, b)\} \in I_\xi$.

**1.4.1 Theorem.** *$h \in I_\alpha(\mathbf{A}, \mathbf{B})$ iff there is a Karp sequence for $\mathbf{A}, \mathbf{B}, h, \alpha$.*
