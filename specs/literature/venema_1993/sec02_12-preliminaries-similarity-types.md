### 1.2 Preliminaries: Similarity types

We follow the conventions in non-classical logics and its semantics as laid down in e.g. Goldblatt [14] or Gabbay & Guenthner [9]. For future reference however, we want to be quite general in the sense that we consider multi-modal languages with arbitrarily many operators, sometimes of arbitrary adity. We briefly summarize here our generalized terminology; especially, because this paper is concerned with non-standard derivation rules, we will go into detail in casu the notion of a derivation system.

**Definition 1.1 Languages** A *modal similarity type* is a pair $S = (O, \rho)$ with $O$ a set of *modal operators*, and $\rho : O \mapsto \omega$ a map assigning to each operator of $O$ a finite *rank* or *adity*. Modal operators of rank 0 are called *constants*, monadic operators: *diamonds*, and dyadic ones: *triangles*. We usually assume the rank of operators known and make no distinction between $S$ and $O$. As variables ranging over operators we use $\nabla, \nabla_1, \ldots$. If the operators are zero-adic or constants, we use $\delta, \lambda, \pi, \sigma, \ldots$, for monadic symbols we use $\Diamond, \Diamond_1, F, P, D, \ldots$ and for dyadics we take $\triangle, \triangle_1, \circ, \ldots$

A *modal language* is a pair $M = (S, Q)$, where $S$ is a similarity type and $Q$ is a set of *propositional variables*. When no confusion arises we write $M(S)$, $M(Q)$ or $M$. The set $\Phi(M)$ of *formulas in* $M$ is inductively defined as usual: the atomic formulas are the constants and the propositional variables, and a formula is either atomic or of the form $\neg\phi_0$, $\phi_1 \vee \phi_2$ or $\nabla(\phi_1, \ldots, \phi_n)$, with every $\phi_i$ a formula. If the variable $p$ does not occur in $\phi$, we write $p \notin \phi$.

For an operator $\nabla$, we abbreviate $\overline{\nabla}(\phi_1, \ldots, \phi_n) = \neg\nabla(\neg\phi_1, \ldots, \neg\phi_n)$ and call $\overline{\nabla}$ the *dual* of $\nabla$. Duals of diamonds are called *boxes*: $\Box\phi = \neg\Diamond\neg\phi$.

To increase readability, we will suppress brackets. We list the operators by decreasing priority: (i) monadic operators ($\neg, \Diamond, \Box$), (ii) polyadic modal operators, (iii) $\{\wedge, \vee\}$, (iv) $\{\to, \leftrightarrow\}$.

Let $M = (S, Q)$ be a modal language, with $S = \{\nabla_i \mid i < \xi\}$, $Q = \{p_j \mid j < \zeta\}$. The *correspondence map* $\ell$ assigns an *accessibility relation symbol* $\ell(\nabla_i)$ of adity $\rho(\nabla_i) + 1$ to each operator $\nabla_i$ of $S$ and a monadic relation symbol $P_j$ to each propositional variable $p_j$ in $Q$. The *corresponding (classical) frame language* $L_S$ has as its predicate symbols the set $\{\ell(\nabla) \mid \nabla \in O\}$. The *corresponding (classical) model language* $L_M$ is $L_S$ extended with all monadic symbols $P_j$, $j < \zeta$.

Unless otherwise stated, all definitions in this subsection are understood with respect to a fixed modal similarity type $S$, c.q. a fixed modal language $M = (S, Q)$.

**Definition 1.2 Semantics**
A *frame* is a pair $\mathfrak{F} = (W, I)$, which is a structure for $L_S$ in the sense of ordinary first order model theory, i.e. $W$ is a set called the *universe* and $I$ is presented as an interpretation function associating an $n + 1$-ary *accessibility relation* with each $S$-operator of rank $n$. Elements of $W$ are called *possible worlds*. We occasionally present a frame as $\mathfrak{F} = (W, R_\nabla)_{\nabla \in S}$. For an $n$-ary operator $\nabla$, we define the $n$-ary operation $m_\nabla$ on the powerset $\mathcal{P}(W)$ of $W$ by

$$m_\nabla(X_1, \ldots, X_n) = \{w \mid \exists w_1 \ldots \exists w_n(\bigwedge_{0 < i \le n} w_i \in X_i \wedge R_\nabla(w, w_1, \ldots, w_n))\}.$$

A *general frame* is a pair $\mathfrak{G} = (\mathfrak{F}, A)$ where $\mathfrak{F} = (W, I)$ is an $S$-frame and $A \subseteq \mathcal{P}(W)$ is closed under Boolean operations and under the operations $m_\nabla$ for all $\nabla$ in $S$.

An $M$-*model* is a structure $\mathfrak{M} = (W, I')$ for $L_M$. We usually present a model $\mathfrak{M}$ as a pair $\mathfrak{M} = (\mathfrak{F}, V)$ with $\mathfrak{F} = (W, I)$ an $S$-frame and $V$ a *valuation*, i.e. a function mapping proposition letters in $Q$ to subsets of $W$. (This presentation can be brought in accordance with the formal definition by setting $I' = I \cup V$.) $V$ can be extended to a map assigning sets of possible worlds to *all* $M$-formulas, by the following inductive definition: $V(\phi \vee \psi) = V(\phi) \cup V(\psi)$, $V(\neg\phi) = W - V(\phi)$ and $V(\nabla(\phi_1, \ldots, \phi_n)) = m_\nabla(V(\phi_1), \ldots, V(\phi_n))$. We define the notion of *truth*: a formula $\phi$ is *true* at $w$ in $\mathfrak{M}$, notation: $\mathfrak{M}, w \models \phi$, if $w \in V(\phi)$.

Missing symbols in '$\mathfrak{F}, V, w \models \phi$' are always understood to be universally quantified, e.g. $\mathfrak{F}, w \models \phi$ iff for all valuations $V$, $\mathfrak{F}, V, w \models \phi$. For a general frame $\mathfrak{G} = (\mathfrak{F}, A)$ we set $\mathfrak{G} \models \phi$ iff for all valuations $V$ with every $V(p)$ in $A$, $\mathfrak{F}, V \models \phi$. $\phi$ is *valid* in a class $\mathsf{K}$ of frames if $\mathfrak{F} \models \phi$ for all $\mathfrak{F}$ in $\mathsf{K}$. For $\mathsf{K}$ a class of models or frames, let $\Theta_S(\mathsf{K})$ be the set of $S$-formulas holding in $\mathsf{K}$. For $\Sigma$ a set of formulas, let $\mathsf{Fr}_\Sigma$ be the class of frames in which $\Sigma$ holds. For a formula $\phi$, we write $\mathsf{Fr}_\phi$ instead of $\mathsf{Fr}_{\{\phi\}}$. A formula $\phi$ is a *semantic consequence* of a set of formulas $\Sigma$ over a class of frames $\mathsf{K}$, notation: $\Sigma \models_\mathsf{K} \phi$ if for every model $\mathfrak{M}$ based on a frame in $\mathsf{K}$, and every world $w$ in $\mathfrak{M}$, $\mathfrak{M}, w \models \phi$ if $\mathfrak{M}, w \models \sigma$ for all $\sigma \in \Sigma$. A set of formulas $\Sigma$ *characterizes* a class of frames $\mathsf{K}$ if $\mathsf{K} = \mathsf{Fr}_\Sigma$.

**Correspondence** By induction to the complexity of formulas in $M$ we define, for every modal formula $\phi$ in $M$ its classical *local model correspondent* $\phi^1(x_0)$ in $L_M$: $(p_i)^1 = P_i x_0$ (where $P_i$ is the corresponding monadic predicate $\ell(p_i)$ of $p_i$), $(\neg\phi)^1 = \neg\phi^1$, $(\phi \vee \psi)^1 = \phi^1 \vee \psi^1$ and
$(\nabla(\phi_1, \ldots, \phi_n))^1 = \exists x_1 \ldots x_n(R_\nabla(x_0, x_1, \ldots, x_n) \wedge \bigwedge_{0 < i \le n} \phi_i^1(x_i/x_0))$.

The *(classical) local frame correspondent* is defined as the second order formula $\phi^2(x_0) \equiv \forall P_1 \ldots \forall P_m \phi^1(x_0)$, where the second order quantifications ($\forall P_i$) take place over those predicates $P_i = \ell(p_i)$ with $p_i$ occurring in $\phi$. The *global* correspondents are defined by a universal first order quantification over the appropriate local correspondents, so the *global model correspondent* is $\forall x_0 \phi^1(x_0)$ and the *global frame correspondent* is $\forall x_0 \phi^2(x_0)$. Modal formulas and their classical correspondents are equivalent on the appropriate level, e.g. $\mathfrak{F} \models \phi$ iff $\mathfrak{F} \models \forall x_0 \phi^2$.

**Definition 1.3 Axiomatics**
A *derivation system* is a pair $MD = (MA, MR)$ with $MA$ a set of formulas called *axioms* and $MR$ a set of derivation rules, a notion for which we only give a semi-formal definition. A *derivation rule* is usually given in the form '$R : \Delta/\phi$, provided $C$', or, if $\Delta$ is a singleton $\{\psi\}$:

$(R) \qquad \vdash \psi \ \Rightarrow \ \vdash \phi, \text{ provided } C.$

where $\phi$ and $\psi$ are schemas of formulas and $\Delta$ is a set of such schemas, and $C$ a *constraint* on $R$. A set $\Sigma$ of formulas is said to be *closed under* $R$ if any instantiation of $\phi$ is in $\Sigma$ whenever the corresponding instantiation of $\Delta$ is contained in $\Sigma$ and the constraint $C$ is met. We understand as known the notion of a substitution. A derivation rule is called *orthodox* if it is one of the following three, *Modus Ponens*, *Universal Generalization* or *Substitution*:

- $(MP)$ &emsp; $\phi, \phi \to \psi \ / \ \psi$,
- $(UG)$ &emsp; $\phi \ / \ \overline{\nabla}(\phi_1, \ldots, \phi_{i-1}, \phi, \phi_{i+1}, \ldots, \phi_n)$, for any $n$-adic operator $\nabla$ in $M$,
- $(SUB)$ &emsp; $\phi \ / \ \sigma\phi$, for any substitution $\sigma$.

A *(normal) modal logic* in a language $M$ is a subset $\Lambda$ of $\Phi(M)$ such that
(i) $\Lambda$ contains the following axioms, the *classical tautologies* and *distribution*:

- $(CT)$ &emsp; all classical tautologies
- $(DB)$ &emsp; $\overline{\nabla}(p_1, \ldots, p_{i-1}, p \to p', p_{i+1}, \ldots, p_n) \to$
  $\overline{\nabla}(p_1, \ldots, p_{i-1}, p, p_{i+1}, \ldots, p_n) \to \overline{\nabla}(p_1, \ldots, p_{i-1}, p', p_{i+1}, \ldots, p_n)$

(ii) $\Lambda$ is closed under the orthodox derivation rules.

A derivation system is called *orthodox* if it has no derivation rules besides the orthodox ones. The *minimal* or *basic logic* $K_S$ of a similarity type $S$ is defined as having *only* $(CT)$ and $(DB)$ as its axioms, *only* $(MP)$, $(UG)$ and $(SUB)$ as its derivation rules. Let $MA$ be a set of axioms and $MR$ a set of derivation rules; the logic $\Lambda(MA, MR)$ is the least set of formulas in $M$ containing $MA$ which is closed under the derivation rules in $MR$. This allows us in the sequel to feel free to identify logics with derivation system, provided that no confusion arises concerning the set of derivation rules. For a formula $\sigma$ we let $\Lambda\sigma$ denote the derivation system $\Lambda$ extended with $\sigma$ as an axiom. $\Lambda\Sigma$ is defined likewise.

**Derivations.** A *derivation* in $\Lambda$ is a finite sequence $\phi_0, \ldots, \phi_n$ such that every $\phi_i$ is either an axiom or obtainable from $\phi_0, \ldots, \phi_{i-1}$ by a derivation rule. A *theorem* of $\Lambda$ is any formula that can appear as the last item of a derivation. Theoremhood of a formula $\phi$ in a logic $\Lambda$ is denoted by $\vdash_\Lambda \phi$. A formula $\phi$ is *derivable* in a logic $\Lambda$ from a set of formulas $\Sigma$, notation: $\Sigma \vdash_\Lambda \phi$, if there are $\sigma_1, \ldots, \sigma_n$ in $\Sigma$ with $\vdash_\Lambda (\sigma_1 \wedge \ldots \wedge \sigma_n) \to \phi$. A formula $\phi$ is *consistent* if its negation $\neg\phi$ is not a theorem. A set of formulas is *consistent* if the conjunction of any finite subset is consistent and *maximal consistent* if it is consistent while it has no consistent proper extension (in the same language). We usually abbreviate 'maximal consistent set' by 'MCS'.

**Canonical structures.** For $\Lambda$ a logic in a language $M$, the $\Lambda$-*canonical universe* $W_\Lambda^c$ is the set of all maximal $\Lambda$-consistent sets in $M$. For $\nabla$ an $n$-adic modal operator in $M$, its *canonical accessibility relation* $R_\nabla^c$ is defined on $W^c$ by $R_\nabla^c(\Delta_0, \ldots, \Delta_n)$ iff for all $\phi_1 \in \Delta_1, \ldots, \phi_n \in \Delta_n$: $\nabla(\phi_1, \ldots, \phi_n) \in \Delta_0$. The $\Lambda$-*canonical frame* is given as $\mathfrak{F}_\Lambda^c = (W_\Lambda^c, I^c)$, where $I^c$ is the *canonical interpretation* mapping every operator to its canonical accessibility relation. The *canonical* $\Lambda$-*model* is the pair $\mathfrak{M}_\Lambda^c = (\mathfrak{F}_\Lambda^c, V^c)$, where $V_\Lambda^c$ is the *canonical valuation* assigning to every $p_i \in Q$ the set of MCSs containing $p_i$, i.e. $V_\Lambda^c(p_i) = \{\Delta \in W_\Lambda^c \mid p_i \in \Delta\}$.

The $\Lambda$-*canonical general frame* is the pair $\mathfrak{G}_\Lambda^c = (\mathfrak{F}_\Lambda^c, A_\Lambda^c)$ where $X \in A_\Lambda^c$ iff $X = V_\Lambda^c(\phi)$ for some $\phi \in \Phi(M)$. The most important property of the canonical model is the *Truth Lemma*: $\mathfrak{M}^c, \Gamma \models \phi \iff \phi \in \Gamma$.

**Properties of logics** Let $\Lambda$ be a logic, $\mathsf{K}$ a class of frames. $\Lambda$ is called *sound* with respect to $\mathsf{K}$ if $\Lambda \subset \Theta(\mathsf{K})$, and *complete* if $\Theta(\mathsf{K}) \subset \Lambda$. $\Lambda$ is *strongly sound* if $\Sigma \vdash_\Lambda \phi \Rightarrow \Sigma \models_\mathsf{K} \phi$, *strongly complete* if $\Sigma \models_\mathsf{K} \phi \Rightarrow \Sigma \vdash_\Lambda \phi$ for all sets of formulas $\Sigma$ and formulas $\phi$.

If $\Lambda$ is (a derivation system $(A, D)$ which is) sound and complete for a class $\mathsf{K}$ of frames, we call $\Lambda$ an axiomatization for $\mathsf{K}$. A logic $\Lambda$ is *canonical* if $\Lambda$ is valid not only on its canonical model (which is always the case, by the truth lemma), but on *every* model based on the canonical frame, i.e. if $\mathfrak{F}_\Lambda^c \models \Lambda$. A formula $\phi$ is canonical if the logic $K_S\phi$ is canonical.

The following are well-known facts: (i) $K_S$ is strongly sound and complete with respect to $\mathsf{Fr}_S$, and (ii) any canonical logic $\Lambda$ is strongly sound and complete with respect to $\mathsf{Fr}_\Lambda$.

**Definition 1.4 Tense** Assume that a subset $T$ of the diamonds of $S$ is given as $T = \{F_j, P_j \mid j \in J\}$. Diamonds in this set are called *tense diamonds*, their duals *tense boxes*. We call $F_j$ the *converse* of $P_j$ and the other way round. The duals of $F_j$ and $P_j$ are denoted by $G_j$ resp. $H_j$. If $\Diamond$ is a tense diamond, its converse is denoted by $\Diamond^{-1}$. A diamond that is not in $T$ is called *uni-directional*. If all diamonds of a similarity type are in $T$, we call it a *tense similarity type*. A frame $(W, R_\nabla)_{\nabla \in S}$ for $S$ is called a *tense frame* if for every $\Diamond \in T$, the accessibility relations of $\Diamond$ and $\Diamond^{-1}$ are each other's converse, i.e. $R_{\Diamond^{-1}} = (R_\Diamond)^{-1}$ $(= \{(u, v) | (v, u) \in R_\Diamond\})$. For a class $\mathsf{K}$ of $S$-frames, we let $\mathsf{K}^t$ denote the class of tense frames in $\mathsf{K}$. The *minimal tense logic* $K_S^t$ is the minimal $S$-logic $K_S$ extended with the following axiom for every $\Diamond \in T$:

$(CV)$ &emsp; $p \to \Box\Diamond^{-1}p$

(With emphasis, we want to note that the above definition should be understood as to include the case where a modal operator is its *own* converse.)

The following is a well-known fact: $K_S^t$ is strongly sound and complete with respect to the class of all tense frames.

---
