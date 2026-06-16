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
