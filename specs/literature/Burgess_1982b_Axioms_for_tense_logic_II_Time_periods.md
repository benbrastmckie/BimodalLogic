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

### 4.1 The axioms

As is well known, the following system $\mathcal{J}$ provides a sound and complete axiomatization for the instant-based tense logic of dense linear orders without first or last element: As axioms of $\mathcal{J}$ we take all truth-functional tautologies plus the following and their 'mirror images'. (The mirror image of a formula is the result of replacing each occurrence of $G$ by $H$ and vice versa.)

- **(A1)** $G(p \supset q) \supset (Gp \supset Gq)$
- **(A2)** $PGp \supset p$
- **(A3)** $Gp \supset GGp$
- **(A4)** $Fp \wedge Fq \supset F(p \wedge Fq) \vee F(p \wedge q) \vee F(Fp \wedge q)$

As rules of inference of $\mathcal{J}$ we take Substitution, Modus Ponens, and Temporal Generalization (TG): From $\alpha$ to infer $G\alpha$ and $H\alpha$.

Let us now consider the extension $\mathcal{S}$ of $\mathcal{J}$ obtained by adding the following extra axiom, together with its mirror image:

- **(A5)** $Gp \supset p$

Our goal is to show that $\mathcal{S}$ gives a sound and complete axiomatization for the period-based tense logic of $\mathfrak{Q}$ and of $\mathfrak{R}$, subject to our homogeneity restriction.

But first we consider a slight variant $\mathcal{S}'$ of $\mathcal{S}$ obtained by replacing A4 and A5 by:

- **(A6)** $G(Gp \supset q) \vee G(Gq \supset p)$

$\mathcal{S}'$ was used by Roper in [1], where it is shown that A5 is a thesis of $\mathcal{S}'$. It can also be shown that A4 is a thesis of $\mathcal{S}'$. (Indeed, the negation of the consequent of A4 yields $G(p \supset G{\sim}q) \wedge G(q \supset G{\sim}p)$. But A6 yields $G(G{\sim}q \supset {\sim}p) \vee G(G{\sim}p \supset {\sim}q)$. Combining these we get $G(p \supset {\sim}p) \vee G(q \supset {\sim}q)$, and so get the negation of the antecedent of A4.)

Conversely, it can be shown that A6 is a thesis of $\mathcal{S}$. (Indeed, A5 allows us to drop the middle disjunct in the consequent of A4. Then substituting $Gp \wedge {\sim}q$ for $p$ and $Gq \wedge {\sim}p$ for $q$ in the modified A4, the negation of A6 implies:

$$F(Gp \wedge {\sim}q \wedge F(Gq \wedge {\sim}p)) \vee F(Gq \wedge {\sim}p \wedge F(Gp \wedge {\sim}q))$$

which is refutable in $\mathcal{J}$.) Thus the two systems are equivalent. $\mathcal{S}$ better exhibits the relation between instant- and period-based tense logic; $\mathcal{S}'$ is a neater formulation if one is interested only in period-based tense logic.

### 4.2 Soundness Theorem

Every thesis of $\mathcal{S}$ is valid for $\mathit{Th}_{\mathcal{L}}$.

*Proof:* A stronger result (soundness for a wider class than $\mathit{Th}_{\mathcal{L}}$) can be found in [1] (except that no proof of 3.3 is provided there). That tautologies are valid is the content of 3.3. It is a routine exercise to verify the validity of each of A1--A5 (this is actually done in [1] for A1--A3 and A6). That substitution preserves validity follows from 3.2. That Modus Ponens preserves validity is proved much like 3.3. That Temporal Generalization preserves validity is trivial. $\square$

### 4.3 Completeness Theorem

Every formula consistent with $\mathcal{S}$ is satisfiable in $I(\mathfrak{Q})$.

*Proof:* A weaker result (completeness for a class of structures properly including $\mathit{Th}_{\mathcal{L}}$) is in [1]. Suppose $\eta$ is consistent with $\mathcal{S}$, and so a fortiori with $\mathcal{J}$. The usual completeness theorem for instant-based tense logic provides us with a valuation $V$ in $\mathfrak{Q}$ such that $0 \in V(\eta)$. Define a function $T$ from the rationals to the class of all maximal-consistent sets of formulas by:

$$(0) \quad T(x) = \{\beta : x \in V(\beta)\}.$$

Then $T$ is readily verified to satisfy the following for all rationals and all formulas:

$$(1) \quad (a)\; G\beta \in T(x) \;\wedge\; x < y \;\Rightarrow\; \beta \in T(y)$$
$$(1) \quad (b)\; H\beta \in T(x) \;\wedge\; y < x \;\Rightarrow\; \beta \in T(y)$$

$$(2) \quad (a)\; G\beta \notin T(x) \;\Rightarrow\; \exists y\,(x < y \;\wedge\; \beta \notin T(y))$$
$$(2) \quad (b)\; H\beta \notin T(x) \;\Rightarrow\; \exists y\,(y < x \;\wedge\; \beta \notin T(y))$$

Now using the fact that $\eta$ is actually consistent with $\mathcal{S}$, it is possible to obtain $V$ and $T$ so that we further have:

$$(3) \quad (a)\; G\beta \in T(x) \;\Rightarrow\; \beta \in T(x)$$
$$(3) \quad (b)\; H\beta \in T(x) \;\Rightarrow\; \beta \in T(x)$$

(Indeed, let $L\beta = H\beta \wedge \beta \wedge G\beta$, and let $\Lambda$ be the set of all $L\beta$ where $\beta$ is any substitution instance of A5 or its mirror image. Since $\eta$ is $\mathcal{S}$-consistent, the set $\Pi = \{\eta\} \cup \Lambda$ is $\mathcal{S}$-consistent, and the original $V$ and $T$ could have been chosen to have $\Pi \subseteq T(0)$, from which (3) follows.)

Let now $\mathfrak{Q}_2$ be the set of pairs of rational numbers equipped with the lexicographic order: $(x,y) < (x',y')$ iff $x < x'$ or ($x = x'$ and $y < y'$). Define a valuation $V'$ in $\mathfrak{Q}_2$ by letting the following hold for any variable $\alpha$:

$$V'(\alpha) = \{(x,y) : x \in V(\alpha)\}.$$

Define a function $T'$ from pairs of rationals to maximal consistent sets of formulas by $T'(x,y) = T(x)$. Then $T'$ inherits property (2) from $T$, and has property (1) because $T$ had properties (1) and (3). Using (1) and (2) for $T'$ it is readily verified that (0) holds with $V'$, $T'$ in place of $V$, $T$. In particular, $(0,0) \in V'(\eta)$.

Now $\mathfrak{Q}_2$, being a countable dense linear order without first or last element, is isomorphic to $\mathfrak{Q}$ by a celebrated theorem of Cantor. Pulling back $V'$ under an isomorphism $i: \mathfrak{Q}_2 \to \mathfrak{Q}$, we see that we could have chosen the original valuation $V$ to satisfy:

$$(4) \quad x \in V(\beta) \;\Rightarrow\; \exists y\,\exists z\,(y < x < z \;\wedge\; \forall w\,(y < w < z \;\Rightarrow\; w \in V(\beta)))$$

because $V'$ has the corresponding property.

Note that (4) implies that for any variable $\alpha$, $V(\alpha)$ is both open and closed, and in particular, is a regular open set. Thus $W = I(V)$ is a regular open valuation in $I(\mathfrak{Q})$. To complete the proof it suffices to apply 4.4 below to any sufficiently small interval $h$ containing $0$, to show that $h \in W(\eta)$ and $\eta$ is satisfiable in $I(\mathfrak{Q})$ as required. $\square$

### 4.4 Claim

For all intervals and formulas we have:

$$(5) \quad ]y,z[ \;\in W(\beta) \;\text{ iff }\; \forall x\,(y < x < z \;\Rightarrow\; x \in V(\beta)).$$

*Proof:* By induction on the complexity of $\beta$, the case $\beta$ a variable being immediate from the definitions, the induction step for $\wedge$ being trivial, and that for $\sim$ an easy application of (4). The cases $\beta = G\gamma$ and $\beta = H\gamma$ are similar, and we treat the former.

In case we have $x \in V(G\gamma)$ for all $x \in a = \;]y,z[$, given any $b \sqsubseteq a$ and $b <_1 c$, consider any $w \in c$. For any $x \in b$ we have $x \in V(G\gamma)$ by the case hypothesis; and $x < w$. So $w \in V(\gamma)$, and by induction hypothesis it follows that $c \in W(\gamma)$. This shows $a \in W(G\gamma)$ as required in this case.

In case we have $x \notin V(G\gamma)$ for some $x \in a$, there is a $w$ with $x < w$ and $w \notin V(\gamma)$. Let $z' = \min(z, x + w/2)$, $b = \;]y, z'[$, $c = \;]z', w+1[$. Then $b \sqsubseteq a$, $b <_1 c$, but by induction hypothesis $c \notin W(\gamma)$. This shows $a \notin W(G\gamma)$ as required in this case. $\square$

### 4.5 Completeness Theorem

Every formula consistent with $\mathcal{S}$ is satisfiable in $I(\mathfrak{R})$.

*Proof:* We retain the notation used above. Here $a, b, c$ will denote open intervals in $\mathfrak{Q}$, and $A, B, C$ open intervals in $\mathfrak{R}$. For any $a$, $a^*$ denotes the $A$ having the same endpoints as $a$. The valuation $W^+$ in $I(\mathfrak{R})$ is defined by letting the following hold for all variables:

$$(6) \quad A \in W^+(\alpha) \;\Leftrightarrow\; \forall a\,(a^* \subseteq A \;\Rightarrow\; a \in W(\alpha)).$$

Clearly $W^+$ is distributive. To prove $W^+$ generic and hence homogeneous, assume $\forall B \subseteq A\;\exists C \subseteq B\,(C \in W^+(\alpha))$ to prove $A \in W^+(\alpha)$. By genericity of $W$ it suffices to prove $\forall a^* \subseteq A\;\exists c \subseteq a\,(c \in W(\alpha))$. Well, if $B = a^* \subseteq A$, then by hypothesis $\exists C \subseteq B\,(C \in W^+(\alpha))$. Taking any $c^* \subseteq C$ we have $c \subseteq a$ and $c \in W(\alpha)$ as required.

We now claim that the following holds for all $a$ and all formulas:

$$(7) \quad a^* \in W^+(\beta) \;\Leftrightarrow\; a \in W(\beta).$$

(7) clearly will suffice to complete the proof. (7) itself is proved by induction on the complexity of $\beta$, it being immediate from the definitions for $\beta$ a variable, and a routine exercise using (6) for the induction steps. We omit details. $\square$

---

In closing we remark that the extent of our dependence on Roper's work is insufficiently apparent from the few citations of [1] above. In fact most of our crucial notions (in particular, that of a homogeneous valuation) have been taken over from him. The only respect in which we have definitely improved on [1] is that our models $I(\mathfrak{Q})$ and $I(\mathfrak{R})$, unlike the 'canonical models' of [1], satisfy:

$$a < b \;\Rightarrow\; \neg\exists c\,(c \sqsubseteq a \;\wedge\; c \sqsubseteq b).$$

This does seem to us important if we want our models 'to achieve some resemblance to the intuitive order of time'.

## Reference

[1] Roper, P., "Intervals and tenses," *Journal of Philosophical Logic*, vol. 9 (1980), pp. 451--469.

---

*Department of Philosophy, Princeton University, Princeton, New Jersey 08544*

*Received April 3, 1981*
