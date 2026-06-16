## A5. Frames and Algebras

We now have two kinds of semantics for our modalities: relational Kripke structures and Boolean algebras with operators. A framework unifying these approaches is that of general frames, which can be seen as both Kripke frames and complex algebras:

**Definition A17: General Frames and Complex Algebras.**
Let $S = (O, \rho)$ be a similarity type, $\nabla$ an $n$-adic operator in $S$, $\mathfrak{F} = (W, I)$ an $S$-frame. We define the $n$-ary operation $m_\nabla$ on the powerset $P(W)$ of $W$ by

$$m_\nabla(X_1, \ldots, X_n) = \{w \mid \exists w_1 \ldots \exists w_n(\bigwedge_{0 < i \leq n} w_i \in X_i \wedge R_\nabla(w, w_1, \ldots, w_n))\}$$

A *general $S$-frame* is a pair $\mathfrak{G} = (\mathfrak{F}, A)$ where $\mathfrak{F} = (W, I)$ is an $S$-frame and $A \subseteq P(W)$ is closed under Boolean operations and under the operations $m_\nabla$ for all $\nabla$ in $S$.

Let $\mathfrak{G}$ be a general $S$-frame $(\mathfrak{F}, A)$. The *complex algebra* $\mathfrak{Cm}\mathfrak{G}$ of $\mathfrak{G}$ is given as $\mathfrak{A} = (A, \cup, ^c, m_\nabla)_{\nabla \in S}$. The *complex algebra* of a Kripke frame $\mathfrak{F} = (W, I)$ is the complex algebra of the general frame $\mathfrak{G} = (\mathfrak{F}, P(W))$.

For K a class of (general) frames, $\mathbf{Cm}\mathrm{K}$ denotes the class of all complex algebras of frames in K.

We now turn to a comparison of the set of formulas holding in a class of (general) frames with the set of equations valid in the corresponding class of complex algebras.

**Definition A18: Translations.**
Let $Q = \{q_i \mid i < \zeta\}$ and $X = \{x_i \mid i < \zeta\}$ be sets of propositional modal resp. algebraic variables. We assume the existence of a bijection identifying $q_i$ with $x_i$. Thus we are allowed to identify the sets of modal formulas $M(S, Q)$ with the set of algebraic terms $M(S, X)$.

Let $\phi$ be a modal formula. Its *corresponding algebraic equation* $\phi^a$ is given as $\phi = 1$.

Let $\eta$ be an algebraic equation. Seen as a modal formula, its normal term (cf. A13) is called the *corresponding modal formula* of $\eta$, notation: $\eta^\mu$.

For sets $\Sigma$, $E$ of formulas resp. equations, $\Sigma^a$ and $E^\mu$ have their usual meaning.

**Theorem A19.**
Let $\mathfrak{F}$ be a frame, $\phi$ an $S$-formula, K a class of frames. Then

$$\mathfrak{F} \models \phi \iff \mathfrak{Cm}\mathfrak{F} \models \phi = 1$$

$$\Theta(\mathrm{K}) = (\mathit{Equ}(\mathbf{Cm}\mathrm{K}))^\mu.$$

**Definition A20. Atom structures.**
We assume familiarity with the notions of *atoms* in Boolean Algebra and *atomic* BAs. Now let $\mathfrak{A} = (A, +, -, f_\nabla)_{\nabla \in S}$ be an atomic Boolean $S$-algebra. The set of atoms in $\mathfrak{A}$ is denoted by $\mathrm{At}\mathfrak{A}$, the *atom structure* of $\mathfrak{A}$ is the $S$-frame $(\mathrm{At}\mathfrak{A}, R_\nabla)_{\nabla \in S}$ where $R_\nabla$ is given by

$$R_\nabla(a_0, a_1, \ldots, a_n) \iff a_0 \leq f_\nabla(a_1, \ldots, a_n).$$

For a class K of algebras, we let $\mathrm{At}\mathrm{K}$ denote the class of atom structures of atomic algebras in K.

**Theorem A21.**
$\mathfrak{F} \simeq \mathfrak{At}\mathfrak{A} \iff \mathfrak{A} \simeq \mathfrak{Cm}\mathfrak{F}$.

**Definition A22. Canonical structures and embedding algebras.**
Let $\mathfrak{A}$ be a Boolean $S$-algebra.

A subset $F$ of $A$ is a *filter* of $\mathfrak{A}$ if (i) $1 \in F$, (ii) $a, b \in F \Rightarrow a \cdot b \in F$ and (iii) $a \in F$ & $b \geq a \Rightarrow b \in F$. An *ultrafilter* of $\mathfrak{A}$ is a filter $U$ satisfying (iv) $a \notin U \Leftrightarrow -a \in U$.

The *canonical structure* of $\mathfrak{A}$ is the frame $\mathfrak{Cs}\mathfrak{A} = (W, R_\nabla)_{\nabla \in S}$ where $W$ is the set of ultrafilters of $\mathfrak{A}$ and $R_\nabla$ is given by

$$R_\nabla(U_0, \ldots, U_n) \iff f_\nabla(a_1, \ldots, a_n) \in U_0 \text{ for all } a_1 \in U_1, \ldots, a_n \in U_n.$$

The *embedding algebra* $\mathfrak{Em}\mathfrak{A}$ of $\mathfrak{A}$ is the complex algebra of canonical extension of $\mathfrak{A}$: $\mathfrak{Em}\mathfrak{A} = \mathfrak{Cm}\mathfrak{Cs}\mathfrak{A}$.

---

## A6. Modal Logics

**Definition A23: Substitutions.**
A *substitution* is a function $\sigma : Q \mapsto \Phi(M)$. A substitution $\sigma$ can be uniquely extended to a homomorphism $\sigma : \mathfrak{F}\mathfrak{m}_M \mapsto \mathfrak{F}\mathfrak{m}_M$ by setting

$$\sigma(\neg\phi) = \neg\sigma(\phi)$$

$$\sigma(\phi \wedge \psi) = \sigma(\phi) \wedge \sigma(\psi)$$

$$\sigma(\nabla(\phi_1, \ldots, \phi_n)) = \nabla(\sigma\phi_1, \ldots, \sigma\phi_n).$$

Let $\sigma$ be a substitution such that $\sigma p_i = \phi$, $\sigma p_j = p_j$ if $p_j \neq p_i$. In this case, we denote $\sigma\psi$ by $\psi[\phi/p_i]$.

In this thesis we identify logics with derivation systems.

**Definition A24: Derivation Systems.**
A *derivation system* is a pair $MD = (MA, MR)$ with $MA$ a set of formulas called *axioms* and $MR$ a set of derivation rules, a notion for which we only give a semi-formal definition.

A *derivation rule* is usually given in the form '$R : \Delta / \phi$, provided $C$', or, if $\Delta$ is a singleton $\{\psi\}$:

$$(R) \qquad \vdash \psi \Rightarrow \vdash \phi, \text{ provided } C.$$

where $\phi$ and $\psi$ are schemas of formulas and $\Delta$ is a set of such schemas, and $C$ a *constraint* on $R$.

A set $\Sigma$ of formulas is said to be *closed under $R$* if any instantiation of $\phi$ is in $\Sigma$ whenever the corresponding instantiation of $\Delta$ is contained in $\Sigma$ and the constraint $C$ is met.

A derivation rule is called *orthodox* if it is one of the following three, *Modus Ponens*, *Universal Generalization* or *Substitution*:

$(MP)$ If $\phi \in \Lambda$ and $\phi \to \psi \in \Lambda$ then $\psi \in \Lambda$.

$(UG)$ If $\phi \in \Lambda$ and $\nabla$ is an $n$-adic operator in $M$, then $\underline{\nabla}(\phi_1, \ldots, \phi_{i-1}, \phi, \phi_{i+1}, \ldots, \phi_n)$ is in $\Lambda$.

$(SUB)$ If $\phi \in \Lambda$ and $\sigma$ is a substitution then $\sigma\phi \in \Lambda$.

**Definition A25: Logics.**
A *(normal) modal logic* in a language $M$ is a subset $\Lambda$ of $\Phi(M)$ such that

(i) $\Lambda$ contains the following axioms, the *classical tautologies* and *distribution*:

$(CT)$ all classical tautologies

$(DB)$ $\underline{\nabla}(p_1, \ldots, p_{i-1}, p, p_{i+1}, \ldots, p_n) \leftrightarrow \underline{\nabla}(p_1, \ldots, p_{i-1}, p, p_{i+1}, \ldots, p_n) \to \underline{\nabla}(p_1, \ldots, p_{i-1}, p', p_{i+1}, \ldots, p_n)$

(ii) $\Lambda$ is closed under the orthodox derivation rules.

A derivation system is called *orthodox* if it contains no derivation rules besides the orthodox ones.

Let $MA$ be a set of axioms and $MD$ a set of derivation rules; the logic $\Lambda(MA, MD)$ is the least set of formulas in $M$ containing $MA$ which is closed under the derivation rules in $MD$.

For a formula $\sigma$ we let $\Lambda\sigma$ denote the derivation system $\Lambda$ extended with $\sigma$ as an axiom. For a set $\Sigma$ of formulas we have an analogous convention.

**Definition A26: Derivations.**
A *derivation* in $\Lambda$ is a finite sequence $\phi_0, \ldots, \phi_n$ such that every $\phi_i$ is either an axiom (footnote 3) or obtainable from $\phi_0, \ldots, \phi_{i-1}$ by a derivation rule. A *theorem* of $\Lambda$ is any formula that can appear as the last item of a derivation. Theoremhood of a formula $\phi$ in a logic $\Lambda$ is denoted by $\vdash_\Lambda \phi$. A formula $\phi$ is *derivable* in a logic $\Lambda$ from a set of formulas $\Sigma$, notation: $\Sigma \vdash_\Lambda \phi$, if there are $\sigma_1, \ldots, \sigma_n$ in $\Sigma$ with $\vdash (\sigma_1 \wedge \ldots \wedge \sigma_n) \to \phi$.

A formula $\phi$ is *consistent* if its negation $\neg\phi$ is not a theorem. A set of formulas is *consistent* if the conjunction of any finite subset is consistent and *maximal consistent* if it is consistent while it has no consistent proper extension (in the same language). We usually abbreviate 'maximal consistent set' by 'MCS'.

> Footnote 3: Cf. Appendix B for a motivation of this definition.

**Definition A26: Properties of logics.**
Let $\Lambda$ be a logic, K a class of frames. $\Lambda$ is called *sound* with respect to K if $\Lambda \subset \Theta(\mathrm{K})$, and *complete* if $\Theta(\mathrm{K}) \subset \Lambda$. $\Lambda$ is *strongly sound* if $\Sigma \vdash_\Lambda \phi \Rightarrow \Sigma \models_\mathrm{K} \phi$, *strongly complete* if $\Sigma \models_\mathrm{K} \phi \Rightarrow \Sigma \vdash_\Lambda \phi$, for all sets of formulas $\Sigma$ and formulas $\phi$.

If $\Lambda$ is (a derivation system $(A, D)$ which is) sound and complete for a class K of frames, we call $\Lambda$ an *axiomatization* for K.

**Definition A27: Minimal modal logics.**
The *minimal* or *basic* logic $K_S$ of a similarity type $S$ is a defined as having *only* (CT) and (DB) as its axioms, *only* (MP), (UG) and (SUB) as its derivation rules.

**Theorem A28.**
$K_S$ is strongly sound and complete with respect to $\mathrm{Fr}_S$.

---

## A7. Algebraic derivations

**Definition A29. Algebraic derivation systems.**
We assume familiarity with the notion of a *subterm (subformula)* of a given term (formula). Let $X$ be a set of variables, $S$ a similarity type.

An *algebraic derivation system* over $X$ is a pair $AD = (AA, AR)$ consisting of a set $AA$ of *axioms*, i.e. equations over $X$, and a set $AR$ of *derivation rules* (of which notion we will not give a formal definition, but cf. A24). For a derivation system $AD = (AA, AR)$, we define $\mathit{Equ}(AD)$, the set of equations *generated* by $AD$, as the smallest set of equations over $X$ that contains $AA$ and is closed under every rule in $AR$.

If $\Sigma$ is a set of equations over $X$, then the *orthodox $S$-derivation system* $D_S(\Sigma)$ *over* $\Sigma$ is the derivation system defined by the following set $\Sigma^+$ of axioms:

(i) $s = s$ for all $s \in M(X)$.

(ii) Axioms governing the Boolean part of the algebras.

(iii) $N$ and $A$, stating that the $S$-operators are normal resp. additive.

(iv) $\Sigma$.

and the following set $R_S$ of rules:

(i) $s = t$ / $t = s$.

(ii) $r = s$, $s = t$ / $r = t$.

(iii) Replacement: $s = t$ / $r[s/x] = r[t/x]$.

(iv) Substitution: $s = t$ / $s[r/x] = t[r/x]$.

Derivation systems are meant to provide recursive enumerations of the equations that are valid in some variety:

**Definition A30.**
Let $D$ be a derivation system, K a class of algebras, $\Sigma$ a set of equations. $D$ is *sound* for K if $\mathit{Equ}(D) \subseteq \mathit{Equ}(\mathrm{K})$, *complete* if $\mathit{Equ}(\mathrm{K}) \subseteq \mathit{Equ}(D)$. $\Sigma$ is an *axiomatization* for K if $D_S(\Sigma)$ is a sound and complete derivation system for K.

Note that the difference between axiomatizations and derivation systems is that the first may only have the 'orthodox' algebraic derivation rules (i) ... (iv).

We now turn to the relation between modal logics and algebraic derivation systems. For *orthodox* modal derivation systems, this relation is well-known:

**Theorem A31.**
Let $\Lambda = (\Sigma, \{MP, UG, SUB\})$ be an orthodox modal derivation system which is sound and complete with respect to a class of frames K. Then $\Sigma^a$ is an algebraic axiomatization for $\mathbf{Cm}\mathrm{K}$.

For modal axiomatizations having non-orthodox rules, we have to work a little harder:

**Definition A32.**
Let '$R : \Delta$ / $\phi$, provided $C$' be a modal derivation rule. Its *algebraic version* $R^A$ is defined as '$R^A : \Delta^a$ / $\phi^a$, provided $C$'.

Let $\Lambda = (\Sigma, \{R_i \mid i \in I\})$ be a modal derivation system. Its *algebraic version* is defined as the orthodox algebraic derivation system $D_S(\Sigma^a)$ augmented with the algebraic versions of the *non-orthodox* rules $R_i$.

**Theorem A33.**
Let $\Lambda = (\Sigma, D)$ be a modal derivation system which is sound and complete with respect to a class of frames K. Then the algebraic version $\Lambda^A$ of $\Lambda$ is a sound and complete algebraic derivation system for $\mathbf{Cm}\mathrm{K}$.

**Proof sketch.**
For notational simplicity, we assume that '$R : \Delta/\phi$, provided $C$' is the only non-orthodox derivation rule of $\Lambda$.

To prove soundness, it suffices to show that $\mathit{Equ}(\mathbf{Cm}\mathrm{K})$ is closed under $R^A$, because the equations in $\Sigma^a$ hold in $\mathbf{Cm}\mathrm{K}$ by A19, and the ordinary algebraic axioms and derivation rules raise no problems. So assume that $\Delta^a \subseteq \mathit{Equ}(\mathbf{Cm}\mathrm{K})$, and that the constraint $C$ is met. By A.19, $\Delta \subseteq \Theta(\mathrm{K})$, so by soundness of $\Lambda$, $\phi \in \Theta(\mathrm{K})$. But then $\phi^a \in \mathit{Equ}(\mathbf{Cm}\mathrm{K})$ by A.19.

For completeness, assume that the equation $\eta$ is valid in K. Without loss of generality (cf. A.14) we may assume that $\eta$ is in normal form $\phi = 1$. By A.19, $\mathrm{K} \models \phi$, so by completeness of $\Lambda$, $\vdash_\Lambda \phi$.

So it remains to be proved that the algebraic equations corresponding to $\Lambda$-theorems are derivable in $\Lambda^A$. This is easily done by induction to the length of the derivation in $\Lambda$: for the orthodox modal derivation rules the induction step is standard, for the unorthodox $R$ it is immediate by the definition of $R^A$.

---

## A8. Canonical structures

**Definition A34: Canonical Structures.**
For $\Lambda$ a logic in a language $M$, the *$\Lambda$-canonical universe* $W^c_\Lambda$ is the set of all maximal $\Lambda$-consistent sets in $M$. For $\nabla$ an $n$-adic modal operator in $M$, its *canonical accessibility relation* $R^c_\nabla$ is defined on $W^c$ by

$$R^c_\nabla(\Delta_0, \ldots, \Delta_{n-1}) \iff \text{for all } \phi_1 \in \Delta_1, \ldots, \phi_n \in \Delta_n : \nabla(\phi_1, \ldots, \phi_n) \in \Delta_0.$$

The $\Lambda$-*canonical frame* is given as $\mathfrak{F}^c_\Lambda = (W^c_\Lambda, I^c)$, where $I^c$ is the *canonical interpretation* mapping every operator to its canonical accessibility relation. The *canonical $\Lambda$-model* is the pair $\mathfrak{M}^c_\Lambda = (\mathfrak{F}^c_\Lambda, V^c)$, where $V^c_\Lambda$ is the *canonical valuation* assigning to every $p_i \in Q$ the set of MCSs containing $p_i$, i.e.

$$V^c_\Lambda(p_i) = \{\Delta \in W^c_\Lambda \mid p_i \in \Delta\}.$$

The $\Lambda$-*canonical general frame* is the pair $\mathfrak{G}^c_\Lambda = (\mathfrak{F}^c_\Lambda, A^c_\Lambda)$ where $X \in A^c_\Lambda$ iff $X = V^c_\Lambda(\phi)$ for some $\phi \in \Phi(M)$.

If we want to make the set $Q$ of variables for the language $M = (S, Q)$ explicit, we may write $\mathfrak{F}^c_\Lambda(Q)$, etc.

**Theorem A35: Truth Lemma.**

$$\mathfrak{M}^c, \Gamma \models \phi \iff \phi \in \Gamma.$$

**Proof.**
The proof is by induction to the complexity of $\phi$. For the atomic case the claim follows by definition. The only non-standard case in the induction step is where $\phi = \nabla(\psi_0, \ldots, \psi_{n-1})$, $\nabla$ an $n$-adic operator. We assume $n = 2$ and write $\phi = \psi \triangle \chi$.

First, suppose $\mathfrak{M}^c, \Gamma \models \psi\triangle\chi$. By the truth definition, there are MCSs $\Pi, \Sigma$ with $R^c\Gamma\Pi\Sigma$, $\mathfrak{M}, \Pi \models \psi$ and $\mathfrak{M}, \Sigma \models \chi$. By the Induction Hypothesis, $\psi \in \Pi$ and $\chi \in \Sigma$. By definition of $R^c$ then, $\psi\triangle\chi \in \Gamma$.

For the opposite direction it is sufficient to prove the following claim:

> If $\Gamma$ is an MCS and $\psi\triangle\chi \in \Gamma$, then there are MCSs $\Pi$, $\Sigma$ with $R^c\Gamma\Pi\Sigma$, $\psi \in \Pi$ and $\chi \in \Sigma$.

To show this, let $\phi_0, \phi_1, \ldots$ be an enumeration of the formulas in the language. We will define in a simultaneous, Lindenbaum-like construction, two sequences of sets of formulas $\Pi_0 \subset \Pi_1 \subset \ldots$, $\Sigma_0 \subset \Sigma_1 \subset \ldots$ such that $\Pi_0 = \{\psi\}$, $\Sigma_0 = \{\chi\}$, all $\Pi_n$ and $\Sigma_n$ are finite and consistent, $\Pi_{n+1}$ is either $\Pi_n \cup \{\phi_n\}$ or $\Pi_n \cup \{\neg\phi_n\}$ and likewise for $\Sigma_n$. Furthermore, setting $\pi_n$ ($\sigma_n$) as the conjunction of all formulas in $\Pi_n$ ($\Sigma_n$), we will have $\pi_n\triangle\sigma_n \in \Gamma$ for all $n$.

The key observation for the induction step of the definition is the following:

$$\pi_n \triangle \pi_n \in \Gamma$$

$$\Rightarrow \pi_n \wedge (\phi_n \vee \neg\phi_n)\triangle\sigma_n \wedge (\phi_n \vee \neg\phi_n) \in \Gamma$$

$$\Rightarrow ((\pi_n \wedge \phi_n) \vee (\pi_n \wedge \neg\phi_n))\triangle((\sigma_n \wedge \phi_n) \vee (\sigma_n \wedge \neg\phi_n))$$

$$\Rightarrow \text{one of } (\pi_n \wedge \phi_n)\triangle(\sigma_n \wedge \phi_n), \quad (\pi_n \wedge \phi_n)\triangle(\sigma_n \wedge \neg\phi_n),$$

$$(\pi_n \wedge \neg\phi_n)\triangle(\sigma_n \wedge \phi_n), \quad (\pi_n \wedge \neg\phi_n)\triangle(\sigma_n \wedge \neg\phi_n) \quad \text{is in } \Gamma.$$

Now for instance in the second case, we take $\Pi_{n+1} = \Pi_n \cup \{\phi_n\}$ and $\Sigma_{n+1} = \Sigma_n \cup \{\neg\phi_n\}$, etc.

It is then straightforward to prove that the $\Pi_n$, $\Sigma_n$ have the properties mentioned above.

Let $\Pi = \bigcup_{n < \omega} \Pi_n$, $\Sigma = \bigcup_{n < \omega} \Sigma_n$, then one can easily verify that $\Pi$ and $\Sigma$ are MCSs and that $R^c\Gamma\Pi\Sigma$.

**Definition A36: Properties of logics.**
A logic $\Lambda$ is *canonical* if $\Lambda$ is valid not only on its canonical model (which is always the case, by the truth lemma), but on *every* model based on the canonical frame, i.e. if $\mathfrak{F}^c_\Lambda \models \Lambda$. A formula $\phi$ is *canonical* if the logic $K_S\phi$ is canonical.

**Theorem A37.**
Let $\Lambda$ be a canonical logic. Then $\Lambda$ is strongly sound and complete with respect to $\mathrm{Fr}_\Lambda$.

**Definition A38. Free Algebras.**
Let $Q$ be a set of variables, K a class of Boolean $S$-algebras. We assume familiarity with the notion of the *$Q$-generated free algebra* $\mathfrak{A}_\mathrm{K}(Q)$ over K. For a variety axiomatized by a set of equations $H$, we denote the free algebra by $\mathfrak{A}_H(Q)$.

The canonical frames are the canonical extensions of the free algebras:

**Theorem A39.**
Let $\Lambda$ be a modal logic, $Q$ a set of propositional variables. Then

$$\mathfrak{F}^c_\Lambda(Q) = \mathfrak{Cs}\mathfrak{A}_{\Lambda^a}(Q).$$

---
