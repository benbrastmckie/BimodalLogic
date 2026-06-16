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
