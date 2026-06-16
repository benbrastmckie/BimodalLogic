# Axioms for Tense Logic II. Time Periods

**John P. Burgess**

*Notre Dame Journal of Formal Logic*, Volume 23, Number 4, October 1982, pp. 375--383.

---

The latest fashion in tense logic is for systems based on time periods rather than durationless instants. The present note provides an axiomatizability result for the period-based tense logic of the rationals and the reals, inspired by the work of P. Roper [1].

## 1 Structures

### 1.1 Instant-based case

Here we work with structures $\mathfrak{X} = (X, <)$ where $X$ is a nonempty set, $<$ a binary relation on $X$. Intuitively, $X$ represents the set of instants of time, and $<$ the earlier/later relation. In the present note we will consider only those $\mathfrak{X}$ that are dense linear orders without first or last element. This of course takes in the usual orders on the rational and real numbers, denoted $\mathfrak{Q}$ and $\mathfrak{R}$, respectively. Let $\mathcal{K}$ be the class of all such orders. For $\mathfrak{X} = (X, <) \in \mathcal{K}$ the order relation $<$ on $X$ determines also a topology on $X$, having as basis the open intervals $]x,y[ \;= \{z : x < z < y\}$ of $\mathfrak{X}$. Thus such topological notions as regular open set and nowhere dense set can be applied to subsets of $X$.

### 1.2 Period-based case

Here we work with structures $\mathfrak{Y} = (Y, \sqsubseteq, <_1)$ where $Y$ is a nonempty set, $\sqsubseteq$ and $<_1$ binary relations on $Y$. Intuitively, $Y$ represents the set of all nonempty finite uninterrupted periods of time, and $\sqsubseteq$ and $<_1$ the inclusion and earlier/later relations among such periods. For $\mathfrak{X} = (X, <) \in \mathcal{K}$ we introduce the structure $I(\mathfrak{X}) = \mathfrak{Y} = (Y, \sqsubseteq, <_1)$ given by:

- $Y$ = the set of nonempty open intervals $]x,y[$ of $\mathfrak{X}$
- $\sqsubseteq$ = the usual set-theoretic inclusion relation
- $<_1$ = the natural order relation induced by $<$, namely: $]x,y[ \;<_1\; ]z,w[$ iff $y < z$

Let $\mathcal{L}$ be the class of all $I(\mathfrak{X})$ for $\mathfrak{X} \in \mathcal{K}$, and $\mathit{Th}_{\mathcal{L}}$ the closure of $\mathcal{L}$ under isomorphism. In the present note we will consider only those $\mathfrak{Y} = (Y, \sqsubseteq, <_1)$ that belong to $\mathit{Th}_{\mathcal{L}}$. An intrinsic characterization of such $\mathfrak{Y}$ is provided by 1.3 below; other such characterizations are known, and form part of the folklore of period-based tense logic.

We make use of the defined notion of *abutment*:

$$a \mathbin{\dagger} b \quad\text{iff}\quad a <_1 b \;\wedge\; \neg\exists c\,(a <_1 c <_1 b).$$

### 1.3 Proposition

A structure $\mathfrak{Y} = (Y, \sqsubseteq, <_1)$ belongs to $\mathit{Th}_{\mathcal{L}}$ iff it satisfies the following postulates:

- **(P0)** $a \mathbin{\dagger} b \;\wedge\; a \mathbin{\dagger} b' \;\wedge\; a' \mathbin{\dagger} b \;\Rightarrow\; a' \mathbin{\dagger} b'$
- **(P1)** $\exists c\,(a \mathbin{\dagger} c \;\wedge\; c \mathbin{\dagger} b) \;\Rightarrow\; \exists d\,\exists e\,(a \mathbin{\dagger} d \;\wedge\; d \mathbin{\dagger} e \;\wedge\; e \mathbin{\dagger} b)$
- **(P2)** $\neg(a \mathbin{\dagger} b \;\wedge\; b \mathbin{\dagger} a)$
- **(P3)** $\exists a\,(a \mathbin{\dagger} b) \;\wedge\; \exists c\,(b \mathbin{\dagger} c)$
- **(P4)** $a \mathbin{\dagger} b \;\wedge\; b \mathbin{\dagger} c \;\wedge\; a \mathbin{\dagger} b' \;\wedge\; b' \mathbin{\dagger} c \;\Rightarrow\; b = b'$
- **(P5)** $a \mathbin{\dagger} b \;\wedge\; c \mathbin{\dagger} d \;\Rightarrow\; (a \mathbin{\dagger} d \;\vee\; c \mathbin{\dagger} b \;\vee\; \exists e\,(a \mathbin{\dagger} e \;\wedge\; e \mathbin{\dagger} d) \;\vee\; \exists e\,(c \mathbin{\dagger} e \;\wedge\; e \mathbin{\dagger} b))$
- **(Q0)** $a \sqsubseteq b \;\Leftrightarrow\; a \mathbin{\dagger} b \;\vee\; \exists c\,(a \mathbin{\dagger} c \;\wedge\; c \mathbin{\dagger} b)$  *(Note: this should be read as the inclusion relation being determined by abutment --- see the proof below for the actual formulation)*
- **(Q0)** $a <_1 b \;\Leftrightarrow\; a \mathbin{\dagger} b \;\vee\; \exists c\,(a \mathbin{\dagger} c \;\wedge\; c \mathbin{\dagger} b)$
- **(Q1)** $a \sqsubseteq b \;\Leftrightarrow\; \forall c\,(c <_1 b \;\Rightarrow\; c <_1 a) \;\wedge\; \forall c\,(b <_1 c \;\Rightarrow\; a <_1 c)$

*Proof:* The necessity of the postulates is a routine exercise. For the sufficiency, suppose $\mathfrak{Y}$ satisfies P0--P5, Q0, and Q1. Let $W$ be the set of all pairs $(a, b)$ from $Y$ satisfying $a \mathbin{\dagger} b$. Define a relation on $W$ by: $(a,b) \approx (a', b')$ iff $a \mathbin{\dagger} b'$. P0 implies that $\approx$ is an equivalence relation. Denote by $\langle a, b\rangle$ the $\approx$-equivalence class of $(a, b)$, and by $X$ the set of all $\langle a, b\rangle$. Define a relation on $X$ by: $\langle a, b\rangle < \langle c, d\rangle$ iff $\exists e\,(a \mathbin{\dagger} e \;\wedge\; e \mathbin{\dagger} d)$. P0 implies that $<$ is well-defined (independent of choice of equivalence class representatives). P1 then implies that $<$ is transitive, and together with P2 that $<$ is antisymmetric. P5 then implies that $<$ is a linear order. P1 then implies that this order is dense, and P3 that it has no first or last element, so $\mathfrak{X} = (X, <) \in \mathcal{K}$. Define a function $f$ from $Y$ to the open intervals of $\mathfrak{X}$ by sending $b$ to $]\langle a, b\rangle, \langle b, c\rangle[$ for some/any $a$ and $c$ with $a \mathbin{\dagger} b$ and $b \mathbin{\dagger} c$ (such exist by P3). It is easily seen that $f$ is well-defined and bijective, injectivity using P4. Moreover, under $f$ the relation $\mathbin{\dagger}$ on $Y$ corresponds to the abutment relation in $I(\mathfrak{X})$. Q0, Q1 then imply that $f$ is an isomorphism between $\mathfrak{Y}$ and $I(\mathfrak{X})$ as required to show $\mathfrak{Y} \in \mathit{Th}_{\mathcal{L}}$. $\square$

## 2 Valuations

### 2.1 The problem of interpretation

We fix a stock $p, q, r, \ldots$ of variables. A *valuation* in a structure is a function assigning each variable a subset of the universe of the structure. In instant-based tense logic, given a valuation $V$ in $\mathfrak{X} = (X, <)$, say belonging to $\mathcal{K}$, we think of each variable $\alpha$ as representing a statement that is tensed and whose truth-value may thus vary from time to time, and of $V(\alpha)$ as giving us the set of times when $\alpha$ is true. In period-based tense logic, given a valuation $W$ in $\mathfrak{Y} = (Y, \sqsubseteq, <_1)$, say belonging to $\mathit{Th}_{\mathcal{L}}$, we think of $W(\alpha)$ as giving us the set of periods with respect to which $\alpha$ is true. But what is truth 'with respect to' a period? This is the central problem of interpretation for period-based tense logic.

To approach a partial solution, we consider for any valuation $V$ in $\mathfrak{X} = (X, <) \in \mathcal{K}$ two derived valuations $I(V)$, $J(V)$ in $I(\mathfrak{X}) = \mathfrak{Y} = (Y, \sqsubseteq, <_1) \in \mathcal{L}$ defined by letting the following hold for all variables $\alpha$:

$$(I(V))(\alpha) = \{]x,y[ \;\in Y : ]x,y[ \;- V(\alpha) \text{ is empty}\}$$

$$(J(V))(\alpha) = \{]x,y[ \;\in Y : ]x,y[ \;- V(\alpha) \text{ is nowhere dense}\}.$$

Now if a valuation $W$ in $\mathfrak{Y}$ is of form $I(V)$, we can with some plausibility interpret $a \in W(\alpha)$ as meaning that $\alpha$ is *always* true during period $a$. And if $W$ is of form $J(V)$, we can interpret it as meaning that $\alpha$ is *almost always* true during period $a$, provided we take 'except for a nowhere dense set of instants' as our reading of 'almost'. More generally, if $\mathfrak{Y} \in \mathit{Th}_{\mathcal{L}}$ we can adopt the 'always' (respectively, 'almost always') reading of $a \in W(\alpha)$ provided there is an isomorphism of $\mathfrak{Y}$ with an element $I(\mathfrak{X})$ of $\mathcal{L}$ under which $W$ corresponds to a valuation of form $I(V)$ (respectively $J(V)$). It is also possible to give more intrinsic characterizations, but this requires some preliminaries.

### 2.2 Definitional preliminaries

Let $\mathfrak{Y} = (Y, \sqsubseteq, <_1) \in \mathit{Th}_{\mathcal{L}}$ and $A \subseteq Y$. We say $a, c \in Y$ *meet* if $\exists e\,(e \sqsubseteq a \;\wedge\; e \sqsubseteq c)$. We say $c, d \in Y$ *weakly split* $A$ if $c \mathbin{\dagger} d$ and:

$$\exists a \in A\,(a, c \text{ meet}) \;\wedge\; \exists a \in A\,(a, d \text{ meet}) \;\wedge\; \neg\exists a \in A\,(a, c \text{ meet} \;\wedge\; a, d \text{ meet}).$$

We say $c, d \in Y$ *strongly split* $A$ if $\exists e\,(c <_1 e \;\wedge\; e <_1 d)$ and the above condition holds. We say $b \in A$ *covers* $A$ if $\forall a \in A\,(a \sqsubseteq b)$ and *exactly covers* $A$ if further $\forall b'\,(b' \text{ covers } A \;\Rightarrow\; b \sqsubseteq b')$. We say $b$ *unites* $A$ if $b$ exactly covers $A$ and $A$ cannot be weakly split. We say $b$ *sums* $A$ if $b$ exactly covers $A$ and $A$ cannot be strongly split, which last condition reduces to:

$$\forall b' \sqsubseteq b\;\exists a \in A\;(b' \text{ meets } a).$$

Now consider a valuation $W$ in $\mathfrak{Y}$. We say $W$ is *distributive* (or *persistent*) if the following holds for all variables $\alpha$:

- **(C1)** $\forall a\,\forall b\,(a \in W(\alpha) \;\wedge\; b \sqsubseteq a \;\Rightarrow\; b \in W(\alpha)).$

We say $W$ is *weakly cumulative* if:

- **(C2)** $\forall A \subseteq Y\;\forall b\,(A \subseteq W(\alpha) \;\wedge\; b \text{ unites } A \;\Rightarrow\; b \in W(\alpha)).$

We say $W$ is *strongly cumulative* if:

- **(C3)** $\forall A \subseteq Y\;\forall b\,(A \subseteq W(\alpha) \;\wedge\; b \text{ sums } A \;\Rightarrow\; b \in W(\alpha)).$

We say $W$ is *homogeneous* if it is distributive and strongly cumulative. We say $W$ is *generic* if:

- **(C4)** $\forall a\,(\forall b \sqsubseteq a\;\exists c \sqsubseteq b\,(c \in W(\alpha)) \;\Rightarrow\; a \in W(\alpha)).$

A valuation $V$ in $\mathfrak{X} = (X, <) \in \mathcal{K}$ will be said to be *open* (respectively, *regular open*) if for each variable $\alpha$ it is the case that $V(\alpha)$ is an open (respectively, regular open) set. Let now $\mathfrak{X} = (X, <) \in \mathcal{K}$, $I(\mathfrak{X}) = \mathfrak{Y} = (Y, \sqsubseteq, <_1) \in \mathcal{L}$.

### 2.3 Proposition

For any valuation $W$ in $\mathfrak{Y}$ the following are equivalent:

- (a) $W = I(V)$ for some open valuation $V$ in $\mathfrak{X}$
- (b) $W = I(V)$ for some valuation $V$ in $\mathfrak{X}$
- (c) $W$ is distributive and weakly cumulative.

### 2.4 Proposition

For any valuation $W$ in $\mathfrak{Y}$ the following are equivalent:

- (a) $W = I(V)$ for some regular open valuation $V$ in $\mathfrak{X}$
- (b) $W = J(V)$ for some valuation $V$ in $\mathfrak{X}$
- (c) $W = J(V)$ for some regular open valuation $V$ in $\mathfrak{X}$
- (d) $W$ is homogeneous
- (e) $W$ is distributive and generic.

*Proofs:* Let us see what the definitions of 2.2 amount to in this context. Let $A \subseteq Y$, and let $\bigcup A \subseteq X$ be the set-theoretic union of the elements of $A$. Clearly $a, c \in Y$ meet iff they have nonempty intersection. Also, $A$ can be weakly split iff $\bigcup A$ is not convex (i.e., there exist $x < y < z$ with $x, z \in \bigcup A$ and $y \notin \bigcup A$). Similarly, $A$ can be strongly split iff there exist $x < z < w < y$ with $x, y \in \bigcup A$ and $]z,w[ \;\cap\; \bigcup A$ empty. Further, clearly $b$ covers $A$ if $\bigcup A \subseteq b$, and $b$ exactly covers $A$ if $b$ is the smallest interval containing $\bigcup A$. Finally, $b$ unites $A$ if $b = \bigcup A$, and $b$ sums $A$ iff $\bigcup A \subseteq b$ and no subinterval of $b$ is disjoint from $\bigcup A$, which last condition reduces to: $b$ is the smallest regular open set containing $\bigcup A$. (We write $\Sigma A$ for the smallest regular open set containing $\bigcup A$.)

Now in 2.3, (a) trivially implies (b), and (b) easily implies (c). So assume (c) to prove (a). Define an open valuation $V$ in $\mathfrak{X}$ by $V(\alpha) = \bigcup W(\alpha)$. Trivially, if $b \in W(\alpha)$, then $b \subseteq V(\alpha)$. Conversely, if $b \subseteq V(\alpha)$, then by distributivity $A = \{a : a \sqsubseteq b \;\wedge\; a \in W(\alpha)\}$ satisfies $b = \bigcup A$. So by weak cumulativity, $b \in W(\alpha)$. This shows $W = I(V)$, proving (a).

Now in 2.4, (a), (b), and (c) are equivalent by the elementary topological fact that for any valuation $V$ in $\mathfrak{X}$ we have $J(V) = I(V')$ where:

$$V'(\alpha) = \operatorname{interior}(\operatorname{closure}(\operatorname{interior}\; V(\alpha))).$$

In particular, if $V$ is already a regular open valuation, $V' = V$ and $I(V) = J(V)$. Also (a) implies (d) and (b) implies (e), in each case distributivity being trivial. To get strong cumulativity from (a), use our characterization of '$b$ sums $A$' as meaning $b = \Sigma A$. To get genericity from (b), use the observation that $\forall b \sqsubseteq a\;\exists c \sqsubseteq b\,(c \in W(\alpha))$ iff $\bigcup W(\alpha)$ is dense in $a$.

Conversely, (d) implies (a) and (e) implies (b), in each case considering the open valuation defined by $V(\alpha) = \bigcup W(\alpha)$. Assuming (d) we have $W = J(V)$ much as in the proof of 2.3 just given. Assuming (e) the observation just made above shows that if $\bigcup W(\alpha)$ is dense in $a$, then genericity applies to give us $a \in W(\alpha)$; we then have $W = J(V)$.

The equivalence of 2.4(d) and 2.4(e) is true for any $\mathfrak{Y} \in \mathit{Th}_{\mathcal{L}}$ (just consider an isomorphic element of $\mathcal{L}$).

For the remainder of the present note we will work only with homogeneous valuations. Intuitively, one way to justify the restriction to such valuations is to read $a \in W(\alpha)$ as '$\alpha$ is almost always true during the period $a$'. Another way would be to read it as '$\alpha$ is always true during period $a$' and argue somehow that 'anything that goes on in time and that we might wish to describe' occupies a suitably 'regular open' portion of time. The latter is, in fact, argued in [1], and the example given there is instructive: Roper says, "If it is cloudy all morning and cloudy all afternoon, then it is cloudy all day long". The assumption made here is that it couldn't clear up for just an instant at the very stroke of noon.

## 3 Connectives

### 3.1 Basic definitions

We now consider formulas built up from our variables by the binary connective of conjunction ($\wedge$) and the singulary connectives of negation ($\sim$), strong future ($G$), and strong past ($H$). We treat disjunction ($\vee$), conditional ($\supset$), weak future ($F = {\sim}G{\sim}$), and weak past ($P = {\sim}H{\sim}$) as abbreviations in the usual way.

Given a homogeneous valuation $W$ in $\mathfrak{Y} = (Y, \sqsubseteq, <_1) \in \mathit{Th}_{\mathcal{L}}$ we extend $W$ to a function defined not just on variables but on all formulas---but by abuse of notation still denoted $W$---inductively as follows:

$$W(\alpha \wedge \beta) = W(\alpha) \cap W(\beta)$$

$$W({\sim}\alpha) = \{a : \forall b \sqsubseteq a\,(b \notin W(\alpha))\}$$

$$W(G\alpha) = \{a : \forall b\,\forall c\,(b \sqsubseteq a \;\wedge\; b <_1 c \;\Rightarrow\; c \in W(\alpha))\}$$

$$W(H\alpha) = \{a : \forall b\,\forall c\,(b \sqsubseteq a \;\wedge\; c <_1 b \;\Rightarrow\; c \in W(\alpha))\}$$

The reader may wish to expand the definitions of $W(\alpha \vee \beta)$, $W(\alpha \supset \beta)$, $W(F\alpha)$, $W(P\alpha)$ to see what they work out to. The expression for $W(\alpha \supset \beta)$ can be simplified (using homogeneity) to:

$$W(\alpha \supset \beta) = \{a : \forall b \sqsubseteq a\,(b \in W(\alpha) \;\Rightarrow\; b \in W(\beta))\}.$$

A formula $\alpha$ will be called *valid* for a subclass $\mathcal{N}$ of $\mathit{Th}_{\mathcal{L}}$ (which may consist of a single structure, e.g., $\mathfrak{Q}$ or $\mathfrak{R}$) provided $W(\alpha) = Y$ for all homogeneous valuations $W$ in all $\mathfrak{Y} \in \mathcal{N}$. A formula $\alpha$ will be called *satisfiable* in $\mathcal{N}$ if $W(\alpha) \neq \emptyset$ for some homogeneous valuation in some $\mathfrak{Y} \in \mathcal{N}$, or equivalently if ${\sim}\alpha$ is not valid for $\mathcal{N}$.

It would be more or less pointless to restrict ourselves to homogeneous valuations were 3.2 below not true. (And it would not be true had we defined, say:

$$W({\sim}\alpha) = Y - W(\alpha)$$

$$W(G\alpha) = \{a : \forall b\,(a <_1 b \;\Rightarrow\; b \in W(\alpha))\}.$$

This explains our choice of connectives!)

### 3.2 Lemma

Let $W$ be a homogeneous valuation in $\mathfrak{Y} \in \mathit{Th}_{\mathcal{L}}$. Then conditions C1 and C4 in fact hold not just for variables but for all formulas.

*Proof:* A routine verification. The hypothesis $\mathfrak{Y} \in \mathit{Th}_{\mathcal{L}}$ is not really needed. $\square$

### 3.3 Lemma

All truth-functional tautologies are valid for $\mathit{Th}_{\mathcal{L}}$.

*Proof:* Let $W$ be a homogeneous valuation in $\mathfrak{Y} = (Y, \sqsubseteq, <_1) \in \mathit{Th}_{\mathcal{L}}$. Then $(Y, \sqsubseteq)$ can be viewed as a Kripke model for intuitionistic logic, since the definitions of $W(\alpha \wedge \beta)$ and $W({\sim}\alpha)$ are precisely those of Kripke semantics. This means that every thesis of intuitionistic logic will be valid. But a celebrated theorem of Godel tells us that for formulas involving only $\wedge$ and $\sim$, intuitionistic and classical logic agree. The hypotheses that $W$ is homogeneous and $\mathfrak{Y} \in \mathit{Th}_{\mathcal{L}}$ are not really needed. $\square$

## 4 Axiomatizability
