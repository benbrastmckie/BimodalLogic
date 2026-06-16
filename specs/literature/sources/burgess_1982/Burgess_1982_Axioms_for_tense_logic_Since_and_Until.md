# Axioms for Tense Logic

## I. "Since" and "Until"

**JOHN P. BURGESS**

*Notre Dame Journal of Formal Logic*
Volume 23, Number 4, October 1982

---

## 1 Preliminaries

In his thesis [1], H. Kamp enriched tense logic by the addition of two new binary connectives, the *since* operator $S$ and the *until* operator $U$. Some time afterward, he announced axiomatizability results for the $S$, $U$-tense logics of various classes of linear orders. His completeness proofs were (in his own words) "by no means simple", and have never been published, though a manuscript treating certain classes of linear orders is in existence. We will present below axiomatizations for the classes of arbitrary linear orders and of dense and discrete orders, with and without first and last elements. Our completeness proofs, although not entirely trivial, are (relatively) simple modifications of the usual proofs for ordinary tense logic without $S$ and $U$, using maximal consistent sets.

### 1.1 Formal syntax

We start with a stock of *propositional variables* $p_i$ for $i = 0, 1, 2, \ldots$, writing $p, q, r, s$ for the first few of them. *Formulas* are built up from the $p_i$ using negation ($\sim$), conjunction ($\wedge$), until ($U$), and since ($S$). We reserve $\alpha, \beta, \gamma, \delta$ to range over formulas, and $A, B, C, D$ to range over sets of formulas. The *mirror image* of $\alpha$ is the result of replacing each occurrence of $U$ in $\alpha$ by $S$, and vice versa. In the usual way, inclusive disjunction ($\vee$), material conditional ($\supset$), material biconditional ($\equiv$), constant true ($\top$), and constant false ($\bot$) can be introduced as abbreviations. Further abbreviations, with their suggested readings ('it___the case that') include:

| Symbol | Definition | Reading |
|--------|-----------|---------|
| $F\alpha$ | for $U(\alpha, \top)$ | will be |
| $P\alpha$ | for $S(\alpha, \top)$ | was |
| $G\alpha$ | for $\sim F \sim \alpha$ | is always going to be |
| $H\alpha$ | for $\sim P \sim \alpha$ | has always been |
| $G'\alpha$ | for $U(\top, \alpha)$ | is for some time going to be uninterruptedly |
| $H'\alpha$ | for $S(\top, \alpha)$ | has for some time been uninterruptedly |
| $F'\alpha$ | for $\sim G' \sim \alpha$ | will arbitrarily soon be |
| $P'\alpha$ | for $\sim H' \sim \alpha$ | has arbitrarily recently been |

### 1.2 Formal semantics

A *valuation* in a linear order $(X, <)$ is a function $V$ assigning each $p_i$ a subset of $X$. Intuitively, $X$ can be thought of as the set of instants of time, $<$ as the earlier/later relation, and $V$ as telling us when the tensed statement $p_i$ was/is/will be true. $V$ is extended inductively to all formulas thus:

$$V(\sim\alpha) = X - V(\alpha)$$

$$V(\alpha \wedge \beta) = V(\alpha) \cap V(\beta)$$

$$V(U(\alpha,\beta)) = \{x : \exists y(x < y \wedge y \in V(\alpha) \wedge \forall z(x < z < y \supset z \in V(\beta)))\}$$

$$V(S(\alpha,\beta)) = \{x : \exists y(y < x \wedge y \in V(\alpha) \wedge \forall z(y < z < x \supset z \in V(\beta)))\}$$

Intuitively, $U(p,q)$ means that there will be a future occasion of $p$'s truth up until which $q$ is going to be uninterruptedly true. The formal semantics of the more familiar connectives $G$, $H$ works out to what it should be:

$$V(G\alpha) = \{x : \forall y(x < y \supset y \in V(\alpha))\}$$

We say $\alpha$ is *valid* for $(X, <)$ if $V(\alpha) = X$ for all valuations, and *satisfiable* if $V(\alpha) \neq \emptyset$ for some valuation. If $\mathscr{K}_0$ is the class of all linear orders, we say $\alpha$ is *valid* (over $\mathscr{K}_0$) if it is valid for every $(X, <) \in \mathscr{K}_0$, and *satisfiable* if it is satisfiable for some $(X, <)$. Alternatively, satisfiability is the failure of validity for the negation.

### 1.3 Axiomatic system

Our basic axiomatic system $\mathscr{J}_0$ takes as axioms all truth-functional tautologies, plus the following together with their mirror images (the latter being labeled A1b--A7b):

| | |
|---|---|
| **A1a** | $G(p \supset q) \supset (U(p,r) \supset U(q,r))$ |
| **A2a** | $G(p \supset q) \supset (U(r,p) \supset U(r,q))$ |
| **A3a** | $p \wedge U(q, r) \supset U(q \wedge S(p, r), r)$ |
| **A4a** | $U(p, q) \wedge \sim U(p, r) \supset U(q \wedge \sim r, q)$ |
| **A5a** | $U(p, q) \supset U(p, q \wedge U(p, q))$ |
| **A6a** | $U(q \wedge U(p, q), q) \supset U(p, q)$ |
| **A7a** | $U(p, q) \wedge U(r, s) \supset U(p \wedge r, q \wedge s) \vee U(p \wedge s, q \wedge s) \vee U(q \wedge r, q \wedge s)$ |

As rules of inference for $\mathscr{J}_0$ we take Substitution, Modus Ponens (MP), plus Temporal Generalization (TG): From $\alpha$ to infer $G\alpha$ and $H\alpha$. The purport of this last is that logical truth is timeless.

As usual, a *deduction* (in $\mathscr{J}_0$) is a finite string of formulas each of which is either an axiom (of $\mathscr{J}_0$) or follows from earlier items by a rule of inference. A *thesis* is anything appearing as the last item in a deduction. We do not define deductions-from-hypotheses, but say that $\beta$ is a *consequence* of $A$ if there exist $\alpha_1, \ldots, \alpha_n \in A$ such that $(\alpha_1 \wedge \ldots \wedge \alpha_n \supset \beta)$ is a thesis. Taking $n = 0$, every thesis is a consequence of $A$. $A$ is *consistent* if $\bot$ is not a consequence of $A$. These notions apply to a single formula $\alpha$ by taking $A = \{\alpha\}$. $A$ is *deductively closed* if it contains all its consequences. We will be interested in deductively closed sets (DCSs), and in maximal consistent sets (MCSs), and assume familiarity with their basic properties from ordinary $G$, $H$-tense logic or elsewhere. For instance, a DCS is an MCS iff it has the property: $\sim\alpha \in A$ iff $\alpha \notin A$.

Our main goal is to prove that a formula $\alpha$ is valid (over $\mathscr{K}_0$) iff it is a thesis (of $\mathscr{J}_0$).

### 1.4 Soundness

*Every thesis of $\mathscr{J}_0$ is valid over $\mathscr{K}_0$.*

*Proof:* Inductive. It must be verified that each axiom is valid, and that each rule of inference preserves validity. For the reader familiar with ordinary $G$, $H$-tense logic, this is a tedious but routine exercise.

### 1.5 Completeness

*Every formula consistent with $\mathscr{J}_0$ is satisfiable over $\mathscr{K}_0$.*

*Proof:* Given below.

### 1.6 Variants

By adding extra axioms to $\mathscr{J}_0$ we can get sound and complete axiomatizations for the $S$, $U$-tense logics of various subclasses of $\mathscr{K}_0$, characterized by additional postulates on the order relation $<$. We tabulate the results:

| Postulates on $<$ | Axioms for $S$, $U$ |
|--------------------|---------------------|
| Density | $F'\top$ |
| Discreteness | $G'\bot \wedge H'\bot$ |
| First Element | $FPH\bot$ |
| Last Element | $PFG\bot$ |
| No First Element | $P\top$ |
| No Last Element | $F\top$ |

For the reader familiar with ordinary $G$, $H$-tense logic, the adaptation of our work below to prove these variants is a routine exercise.

### 1.7 Decidability

The recursive decidability of the set of valid formulas is an immediate consequence of Rabin's theorem on the decidability of the monadic second-order theory of the rational order. We omit details.

---

## 2 The completeness proof

We must show that any formula consistent (with $\mathscr{J}_0$) is satisfiable (over $\mathscr{K}_0$). We need several preliminary lemmas.

### 2.1 Replacement Lemma

*If $\alpha \equiv \beta$ is a thesis, then so is $\phi(\alpha/p_i) \equiv \phi(\beta/p_i)$, where the slash ($/$) denotes substitution. In particular, if $\phi(\alpha/p_i)$ is a thesis, so is $\phi(\beta/p_i)$.*

*Proof:* Resembles that of the corresponding result in ordinary $G$, $H$-tense logic, and proceeds by induction on the complexity of the context $\phi$. As a sample we treat the case $\phi = U(\psi, \chi)$. Assuming $\alpha \equiv \beta$ is a thesis, we have the following outline of a deduction, where in the interests of perspicuity we omit the '$/ p_i$':

| | | |
|---|---|---|
| (i) | $\psi(\alpha) \supset \psi(\beta)$ | Induction Hypothesis |
| (ii) | $\chi(\alpha) \supset \chi(\beta)$ | Induction Hypothesis |
| (iii) | $G(\psi(\alpha) \supset \psi(\beta))$ | i, TG |
| (iv) | $G(\chi(\alpha) \supset \chi(\beta))$ | ii, TG |
| (v) | $U(\psi(\alpha), \chi(\alpha)) \supset U(\psi(\beta), \chi(\alpha))$ | iii, A1a |
| (vi) | $U(\psi(\beta), \chi(\alpha)) \supset U(\psi(\beta), \chi(\beta))$ | iv, A2a |
| (vii) | $\phi(\alpha) \supset \phi(\beta)$ | v, vi, Truth-Functional Logic |

The converse is of course similar. Below 2.1 will be used tacitly.

### 2.2 Consistency Criterion

*If $A$ is an MCS and $U(\gamma, \delta) \in A$, then $\gamma$ is consistent.*

*Proof:* If $\gamma$ is inconsistent, then $\sim\gamma$ is a thesis, so $G\sim\gamma = \sim F\sim\sim\gamma$ is a thesis by TG, so $\sim U(\gamma, \top) = \sim F\gamma$ is a thesis by 2.1, so $\sim U(\gamma, \delta)$ is a thesis using A2a, and $U(\gamma, \delta)$ is inconsistent, and so cannot belong to the MCS $A$.

2.2 has a mirror image, proved the same way: If $A$ is an MCS and $S(\gamma, \delta) \in A$, then $\gamma$ is consistent. In the future we leave the formulation of such obvious mirror images to the reader.

### 2.3 Lemma

*Let $A$, $C$ be MCSs. The following are equivalent for any $\beta$:*

*(a) $\forall \gamma \in C\, (U(\gamma, \beta) \in A)$*

*(b) $\forall \alpha \in A\, (S(\alpha, \beta) \in C)$.*

*Proof:* We show that (a) implies (b): Assume (a) and suppose for contradiction that $\alpha \in A$ is a counterexample to (b). That is, $\sim S(\alpha, \beta) \in C$. By (a), $U(\sim S(\alpha, \beta), \beta) \in A$. By A3a, $U(\sim S(\alpha, \beta) \wedge S(\alpha, \beta), \beta) \in A$, contrary to 2.2.

We write $r(A, \beta, C)$ to indicate that $A$, $C$ are MCSs related as in 2.3. We write $r(A, B, C)$ to indicate that $B$ is a DCS and that $r(A, \beta, C)$ holds for all $\beta \in B$. We write $R(A, B, C)$ to indicate that $B$ is maximal with respect to the property $r(A, \text{---}, C)$; i.e., $r(A, B, C)$ holds, but $r(A, B', C)$ never holds for any proper extension $B'$ of $B$. Note that whenever $r(A, B, C)$ holds, so does $r(A, B', C)$ where $B'$ is the set of consequences of $B$. Note that whenever $R(A, B, C)$ holds and $\delta \notin B$ there must exist a $\beta \in B$ such that $r(A, \beta \wedge \delta, C)$ does not hold (else consider $B' =$ consequences of $B \cup \{\delta\}$). Hence in this case for some $\gamma \in C$, $U(\gamma, \beta \wedge \delta) \notin A$.

Intuitively, an MCS represents a complete description of a possible state of affairs. $R(A, B, C)$ then means that a state of affairs of the sort described by $A$ could be followed by one of the sort described by $C$, with $B$ being a complete description of everything that remains true throughout the entire intervening period. Keeping this intuition in mind, the following lemmas should not appear unreasonable.

### 2.4 Lemma

*Let $A$ be an MCS and suppose $U(\gamma, \beta) \in A$. Then there exist $B$, $C$ such that $\beta \in B$, $\gamma \in C$, and $R(A, B, C)$ holds.*

*Proof:* Let $C_0 = \{\gamma\} \cup \{S(\alpha, \beta) : \alpha \in A\}$. We claim $C_0$ is consistent. Now A1a, A2a easily yield $S(\alpha \wedge \alpha', \beta) \supset S(\alpha, \beta) \wedge S(\alpha', \beta)$, and $A$ being an MCS it is closed under $\wedge$. Hence it will suffice to show that any particular formula $\gamma \wedge S(\alpha, \beta)$ with $\alpha \in A$ is consistent. But when $\alpha \in A$, since $U(\gamma, \beta) \in A$ by hypothesis, A3a yields $U(\gamma \wedge S(\alpha, \beta), \beta) \in A$, whence 2.2 yields the consistency of $\gamma \wedge S(\alpha, \beta)$, completing the proof of the consistency of $C_0$.

Now let $C$ be any MCS extending $C_0$. We have $r(A, \beta, C)$ by construction, using criterion 2.3b for $r$. So it suffices to let $B$ be maximal with respect to the properties that $\beta \in B$ and $r(A, B, C)$ to complete the proof.

### 2.5 Lemma

*Suppose we have $R(A, B, C)$, $r(A, B', D)$, $r(D, B'', C)$ and $B \subseteq B' \cap D \cap B''$. Then in fact $B = B' \cap D \cap B''$.*

*Proof:* By the maximality property of $B$ it suffices to show that $r(A, B^+, C)$ holds where $B^+ = B' \cap D \cap B''$. Using criterion 2.3a for $r$, it suffices to consider $\delta \in B^+$, $\gamma \in C$ and show $U(\gamma, \delta) \in A$.

Well, since $\delta \in B''$ and $r(D, B'', C)$ we have $U(\gamma, \delta) \in D$. Since also $\delta \in D$, we have $\delta \wedge U(\gamma, \delta) \in D$. Since $\delta \in B'$ and $r(A, B', D)$ we have $U(\delta \wedge U(\gamma, \delta), \delta) \in A$. Then A6a yields the desired conclusion $U(\gamma, \delta) \in A$.

### 2.6 Lemma

*Suppose we have $R(A, B, C)$ and $\delta \notin B$. Then there exist $B'$, $D$, $B''$ such that $\sim\delta \in D$ and $R(A, B', D)$, $R(D, B'', C)$ and $B = B' \cap D \cap B''$.*

*Proof:* Let $D_0 = \{S(\alpha, \beta) : \alpha \in A, \beta \in B\} \cup B \cup \{\sim\delta\} \cup \{U(\gamma, \beta) : \gamma \in C, \beta \in B\}$. We claim $D_0$ is consistent. Much as in the proof of 2.4 it suffices to show that any particular

$$\zeta = S(\alpha, \beta) \wedge \beta \wedge \sim\delta \wedge U(\gamma, \beta)$$

with $\alpha \in A$, $\beta \in B$, $\gamma \in C$ is consistent. To that end we note that by an earlier remark there exist $\beta_0 \in B$, $\gamma_0 \in C$ with $\sim U(\gamma_0, \beta_0 \wedge \delta) \in A$. We may suppose (replacing $\beta$, $\gamma$ by $\beta \wedge \beta_0$, $\gamma \wedge \gamma_0$, respectively, if necessary) that $\sim U(\gamma, \beta \wedge \delta) \in A$. But $U(\gamma, \beta) \in A$ by hypothesis $r(A, B, C)$, and so $U(\gamma, \beta \wedge U(\gamma, \beta)) \in A$ using A5a. Now A4a applies and tells us that $U(\beta \wedge U(\gamma, \beta) \wedge \sim\delta, \beta) \in A$. Using A3a we then have $U(\beta \wedge U(\gamma, \beta) \wedge \sim\delta \wedge S(\alpha, \beta), \beta) \in A$, from which the consistency of $\zeta$ follows by 2.2, proving our claim.

Now let $D$ be any MCS extending $D_0$, and let $B'$, $B''$ be maximal with respect to the properties $B \subseteq B' \wedge r(A, B', D)$ and $B \subseteq B'' \wedge r(D, B'', C)$ respectively. Note we have $B = B' \cap D \cap B''$ by 2.5 to complete the proof.

### 2.7 Lemma

*Suppose we have $R(A, B, C)$ and $U(\xi, \eta) \in A$ and $\eta \notin B$. Then there exist $B'$, $D$, $B''$ such that $\eta \in B'$, $\xi \in D$, and $R(A, B', D)$, $R(D, B'', C)$ and $B = B' \cap D \cap B''$.*

*Proof:* Much as in the proof of 2.6 the problem reduces to proving the consistency of the set of formulas of form

$$\zeta = S(\alpha, \beta \wedge \eta) \wedge \beta \wedge \xi \wedge U(\gamma, \beta)$$

for $\alpha \in A$, $\beta \in B$, $\gamma \in C$, or what comes to the same thing, of each particular such $\zeta$. To this end we note that there are $\beta_0 \in B$, $\gamma_0 \in C$ with $\sim U(\gamma_0, \beta_0 \wedge \eta) \in A$, and we may suppose $\beta_0 = \beta$, $\gamma_0 = \gamma$. But $U(\gamma, \beta)$, $U(\xi, \eta) \in A$ by hypothesis, whence $U(\gamma, \beta \wedge U(\gamma, \beta))$, $U(\xi, \eta \wedge U(\xi, \eta)) \in A$ using A5a. Now letting $\theta = \beta \wedge U(\gamma, \beta) \wedge \xi \wedge U(\xi, \eta)$, A7a applies to tell us that one of the following must belong to $A$: $U(\gamma \wedge \xi, \theta)$, $U(\gamma \wedge U(\xi, \eta), \theta)$, or $U(\beta \wedge U(\gamma, \beta) \wedge \xi, \theta)$. Since $\sim U(\gamma, \beta \wedge \eta) \in A$, using A1a and A2a the first two candidates can be ruled out, so it must be the third. Using A3a we then get $U(\xi, \beta \wedge \eta) \in A$, whence the consistency of $\zeta$ follows, completing (our account of) the proof.

### 2.8 Lemma

*Suppose we have $R(A, B, C)$ and $U(\xi, \eta) \in A$ and $\sim(\xi \vee (\eta \wedge U(\xi, \eta))) \in C$. Then the conclusion of 2.7 holds.*

*Proof:* The proof of 2.7 needs only slight modification. Given $\alpha \in A$, $\beta \in B$, $\gamma \in C$, to prove the consistency of $\zeta$ as above, we apply A7a to $U(\gamma \wedge \gamma', \beta \wedge U(\gamma \wedge \gamma', \beta)) \in A$ and $U(\xi, \eta \wedge U(\xi, \eta)) \in A$, where $\gamma' = \sim(\xi \vee (\eta \wedge U(\xi, \eta))) \in C$.

We obtain three disjuncts, one of which must belong to $A$. Again we can rule out two candidates and are left with the third, from which the consistency of $\zeta$ follows using A3a. Details are left to the reader.

---

These preliminaries out of the way, we can turn to the heart of the completeness proof. Let $\mathscr{F}$ be the set of all pairs $(f, g)$ satisfying:

**(C0)** $f$ is a function from a subset of the rational numbers to the set of all MCSs.

**(C0')** The domain, dom $f$, of $f$ is finite.

**(C1)** $g$ is a function from $\{(x, y) : x, y \in \text{dom}\, f \wedge x < y\}$ to the set of all DCSs.

**(C2)** Whenever $x, y \in \text{dom}\, f$ and $x < y$, then $r(f(x), g(x,y), f(y))$ holds.

**(C2')** Whenever $x, y \in \text{dom}\, f$ and $x$ immediately precedes $y$ in dom $f$, then $R(f(x), g(x,y), f(y))$ holds.

**(C3)** Whenever $x, y, z \in \text{dom}\, f$ and $x < y < z$, then $g(x,z) = g(x,y) \cap f(y) \cap g(y,z)$.

Recall that one function *extends* another if its domain is larger and the two agree wherever both are defined. We say $(f', g') \in \mathscr{F}$ *extends* $(f, g) \in \mathscr{F}$ if $f'$ extends $f$ and $g'$ extends $g$. Intuitively, $(f, g) \in \mathscr{F}$ should be thought of as a *chronicle* describing part of the course of history. Here $f(x)$ tells us what went on/is going on/will go on at time $x$, while $g(x,y)$ tells us what remained true/is to remain true throughout the whole period between $x$ and $y$. A total chronicle ought to have the following additional properties, as well as their mirror images (denoted C4b, C5b):

**(C4a)** Whenever $x, y \in \text{dom}\, f$ and $x < y$ and $\sim U(\gamma, \delta) \in f(x)$ and $\gamma \in f(y)$, there is some $z \in \text{dom}\, f$ with $x < z < y$ and $\sim\delta \in f(z)$.

**(C5a)** Whenever $x \in \text{dom}\, f$ and $U(\xi, \eta) \in f(x)$, there is some $y \in \text{dom}\, f$ with $x < y$ and $\xi \in f(y)$ and $\eta \in g(x, y)$.

A finite chronicle cannot in general satisfy all cases of C4, C5, but we have the following:

### 2.9 Counterexample Lemma

*Let $(f, g) \in \mathscr{F}$ and suppose $x$, $y$, $\gamma$, $\delta$ constitute a counterexample to C4a for $(f, g)$. Then there exists an extension $(f', g') \in \mathscr{F}$ of $(f, g)$ for which $x$, $y$, $\gamma$, $\delta$ do not constitute a counterexample to C4a.*

*Proof:* What we claim is that it is possible to add a single point $z$ lying between $x$ and $y$ to dom $f$, and extend $f$ and $g$ to functions $f'$ and $g'$ on this enlarged domain, in such a way that $\sim\delta \in f'(z)$, and all the conditions for membership in $\mathscr{F}$ are satisfied by $(f', g')$. We prove this by induction on the number $n$ of elements of dom $f$ lying between $x$ and $y$.

*Case $n = 0$.* By C2' we have $R(f(x), g(x,y), f(y))$ and so we can apply 2.6 to $A = f(x)$, $B = g(x,y)$, $C = f(y)$ to obtain $B'$, $D$, $B''$. Let $z = (x + y)/2$. Set $f'(z) = D$. Set $g'(x,z) = B'$, $g'(z,y) = B''$, and let C3 determine the other values of $g'(w,z)$ and $g'(z,w)$.

*Case $n = m + 1$.* Let $x'$ immediately succeed $x$ in dom $f$. If $\sim U(\gamma, \delta) \in f(x')$, we can reduce to the case $n = m$ by replacing $x$ by $x'$. If $U(\gamma, \delta) \in f(x')$, note first that we must have $\delta \in f(x')$, else $x$, $y$, $\gamma$, $\delta$ would not be a counterexample. Let $\gamma' = \delta \wedge U(\gamma, \delta) \in f(x')$. Using A3a we see $\sim U(\gamma', \delta) \in f(x)$, so we can reduce to the case $n = 0$ by replacing $\gamma$ by $\gamma'$ and $y$ by $x'$.

### 2.10 Counterexample Lemma

*Let $(f, g) \in \mathscr{F}$ and suppose $x$, $\xi$, $\eta$ constitute a counterexample to C5a for $(f, g)$. Then there exists an extension $(f', g') \in \mathscr{F}$ of $(f, g)$ for which $x$, $\xi$, $\eta$ do not constitute a counterexample to C5a.*

*Proof:* What we claim is that it is possible to add a single point $y$ lying after $x$ to dom $f$, and extend $f$ and $g$ to functions $f'$ and $g'$ on this enlarged domain, in such a way that $\xi \in f'(y)$, $\eta \in g'(x, y)$, and all the requirements for membership in $\mathscr{F}$ are satisfied by $(f', g')$. We prove this by induction on the number $n$ of elements of dom $f$ lying after $x$.

*Case $n = 0$.* We can apply 2.4 to $A = f(x)$ obtaining $B$, $C$. Set $y = x + 1$, $f'(y) = C$, $g'(x, y) = B$, and let C3 determine the other values of $g'(w, y)$.

*Case $n = m + 1$.* Let $x'$ immediately succeed $x$ in dom $f$. If (i) both $\eta \wedge U(\xi, \eta) \in f(x')$ and $\eta \in g(x, x')$, then we can reduce to the case $n = m$ by replacing $x$ by $x'$. If (i) fails, note also that we cannot have (ii) both $\xi \in f(x')$ and $\eta \in g(x, x')$; else $x$, $\xi$, $\eta$ would not be a counterexample. But if (i) and (ii) both fail, then the hypotheses either of 2.7 or else of 2.8 must hold for $A = f(x)$, $B = g(x, x')$, $C = f(x')$. So we can obtain $B'$, $D$, $B''$ as in the conclusion of 2.7. Set $z = (x + x')/2$, $f'(z) = D$, $g'(x, z) = B'$, $g'(z, x') = B''$, and let C3 determine the other values of $g'(w, z)$ and $g'(z, w)$. As in 2.9, the details of the verification that $(f', g') \in \mathscr{F}$ are left to the reader.

---

These lemmas out of the way, we are ready to finish the proof of the completeness of $\mathscr{J}_0$ for $\mathscr{K}_0$. Let $\alpha_0$ be any consistent formula, to find a linear order $(X, <)$ in which $\alpha_0$ is satisfiable. We fix an MCS $A_0$ with $\alpha_0 \in A_0$, and define $(f_0, g_0) \in \mathscr{F}$ by letting dom $f_0 = \{0\}$, $f_0(0) = A_0$, $g_0 =$ empty function. We wish to form a sequence $(f_n, g_n)$ of elements of $\mathscr{F}$, each extending the one before, in such a way that whenever we have a counterexample to C4a or b, or C5a or b for a given $(f_m, g_m)$, there will eventually be an $(f_n, g_n)$ with $n > m$ for which it is no longer a counterexample. This is accomplished by repeated application of 2.9 and 2.10 and their mirror images to handle C4a and C5a and their mirror images, respectively. Since the construction closely resembles one used in ordinary $G$, $H$-tense logic, we omit details. We now let $X$ be the union of the sets dom $f_n$, and $f$ and $g$ the unions of the $f_n$ and $g_n$ respectively. Then $(f, g)$ satisfies C0--C5. We define a valuation $V$ in $(X, <)$---the order being the usual order on the rationals---by letting the following hold for any $x \in X$ and $\alpha = p_i$:

$$(\mathord{+}) \qquad x \in V(\alpha) \text{ iff } \alpha \in f(x).$$

### 2.11 Claim

*($\mathord{+}$) in fact holds for all $\alpha$.*

*Proof:* By induction on the complexity of $\alpha$. As a sample we treat the case $\alpha = U(\beta, \gamma)$. If $\alpha \in f(x)$, then by C5a there is a $y \in X$ with $x < y$ and $\gamma \in f(y)$ and $\beta \in g(x, y)$. If $z \in X$ and $x < z < y$, then by C3 we have $g(x, y) \subseteq f(z)$, whence $\beta \in f(z)$. By induction hypothesis $y \in V(\gamma)$ and $z \in V(\beta)$ for any $z$ with $x < z < y$, whence $x \in V(\alpha)$. If instead $\sim\alpha \in f(x)$, then for any $y \in X$ with $x < y$ and $y \in V(\gamma)$, we have by induction hypothesis $\gamma \in f(y)$, and hence by C4a there must be a $z \in X$ with $x < z < y$ and $\sim\beta \in f(z)$, whence by induction hypothesis $z \notin V(\beta)$. It follows that $x \notin V(\alpha)$ as required.

Now since $\alpha_0 \in f(0)$, ($\mathord{+}$) tells us that $V(\alpha_0) \neq \emptyset$, so $\alpha_0$ is satisfiable, completing the proof.

---

## Reference

[1] Kamp, J. A. W., *Tense Logic and the Theory of Linear Order*, doctoral dissertation, University of California at Los Angeles, 1968.

---

*Department of Philosophy*
*Princeton University*
*Princeton, New Jersey 08544*

*Received April 3, 1981*
