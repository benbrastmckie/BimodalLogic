# Derivation Rules as Anti-Axioms in Modal Logic

**Yde Venema**
Faculteit der Wijsbegeerte
Rijksuniversiteit Utrecht
Heidelberglaan 8
3584 CS Utrecht
e-mail: yde@phil.ruu.nl

August 20, 2003

## Abstract

We discuss a 'negative' way of defining frame classes in (multi-)modal logic, and address the question whether these classes can be axiomatized by *derivation rules*, the 'non-$\xi$ rules', styled after Gabbay's Irreflexivity Rule. The main result of this paper is a meta-theorem on completeness, of the following kind: If $\Lambda$ is a derivation system having a set of axioms that are special Sahlqvist formulas, and $\Lambda^+$ is the extension of $\Lambda$ with a set of non-$\xi$ rules, then $\Lambda^+$ is strongly sound and complete with respect to the class of frames determined by the axioms and the rules.

**Keywords:** (multi-)modal logic, completeness, derivation rules, modal definability.
**1980 Mathematical Subject Classification:** 03B45, 03C90.

---

## 1 Introduction

### 1.1 Rules as anti-axioms

When we are saying that a modal formula $\phi$ *characterizes* a class $\mathsf{K}$ of frames, we usually mean that any modal frame $\mathfrak{F} = (W, R)$ is in $\mathsf{K}$ if and only if $\phi$ is valid in $\mathfrak{F}$ (i.e. in every model $(\mathfrak{F}, V)$ based on $\mathfrak{F}$, $\phi$ is true in every world of $\mathfrak{F}$). The standard examples are $p \to \Diamond p$ and $\Diamond\Diamond p \to \Diamond p$ characterizing the reflexive respectively the transitive frames. *Correspondence theory* (cf. van Benthem [2, 3]) is the branch of modal logic studying the relation of the modal formalism to the first order frame language (the one having one predicate, referring to the accessibility relation) as ways of talking about frames. It is also a well-known correspondence-theoretic result that not all first order definable properties have modal correspondents: the standard example here being *irreflexivity*.

However, there are different ways of characterizing frame classes: consider a world $w$ in a frame $\mathfrak{F} = (W, R)$. Clearly $w$ is irreflexive iff $\{w\} \cap \{v | Rwv\} = \emptyset$. Thus, a world $w$ is irreflexive iff we can make the formula $p \to \Diamond p$ *false* at $w$. This gives us a way of characterizing the irreflexive frames:

$$\mathfrak{F} \models \forall x \neg Rxx \iff \forall w \exists V \ \big(\mathfrak{F}, V, w \models \neg(p \to \Diamond p)\big).$$

In the same way, we can show that a frame is intransitive iff we can falsify the formula $\Box p \to \Diamond\Diamond p$ at every world.

Classes allowing such a characterization will be called *negatively definable* and form the subject of this paper. These classes occur abundantly in (multi-)modal logic, especially in contexts with a more-dimensional flavour: in the next section we will give some more examples. However, the main topic that we will address in this paper is not so much definability as *axiomatizability*.

Let us return to the properties of transitivity and reflexivity. It belongs to the basic facts of modal logic that for these properties, the modal formulas characterizing them are also sufficient to *axiomatize* the formulas valid in the corresponding frame classes. For example, adding $\Diamond\Diamond p \to \Diamond p$ as an axiom to the basic modal logic $K$, we obtain a complete axiomatization for the class of transitive frames. It is less clear however, how to axiomatize the irreflexive frames, as there is not an obvious candidate axiom. The usual procedure consists of starting with some model $\mathfrak{M}$ for a consistent set of formulas $\Sigma$ and then transforming $\mathfrak{M}$ into an *irreflexive* model $\mathfrak{M}'$ for $\Sigma$. In this way one can show that $K$ *itself*[^1] is complete for the class of irreflexive frames.

A different road was taken by Gabbay in [8]. Instead of using axioms, he suggested to add (to a similar logic) a special derivation rule, which he baptized the *irreflexivity rule*. This rule can be formulated as follows[^2]:

$(IR) \qquad \vdash \neg(p \to \Diamond p) \to \phi \ \Rightarrow \ \vdash \phi, \text{ if } p \text{ does not occur in } \phi.$

Gabbay's completeness proof then consists of constructing a transitive irreflexive model right away, without passing through models that may be bad in the sense that they have reflexive points.

Let us now have a closer look at the irreflexivity rule: one intuition behind it is expressed by the following reading: "if we can prove $\phi$ under the condition that we are in an irreflexive world, then we accept $\phi$ as a theorem". But perhaps it is more perspicuous if we concentrate on the converse statement:

$(IR')$ &emsp;&emsp;&emsp; If $\phi$ is consistent and does not use $p$, then $\phi \wedge \neg(p \to \Diamond p)$ is consistent.

[^1]: In this sense, the example of irreflexivity is not representative; this matter is discussed in section 9.
[^2]: To be precise, this relatively simple version of the rule only works for *tense* logics, cf. section 6.

With this formulation, it will be clear immediately that $IR$ is *sound* with respect to the logic of the irreflexive frames: if $\phi$ can be made to hold at a world $w$ in an irreflexive model $(\mathfrak{F}, V)$, then by taking a valuation $V'$ which is just like $V$ except for sending $p$ to $\{w\}$, we can satisfy $\phi \wedge \neg(p \to \Diamond p)$ in the irreflexive model $(\mathfrak{F}, V')$.

The interesting question of course is whether adding the irreflexivity rule to a logic gives us *completeness* of the arising derivation system with respect to irreflexivity --- as we already mentioned, Gabbay gives an affirmative answer for the tense logics studied in [8].

The idea of converting the negative definability of a property into a derivation rule can of course be applied in many other contexts, and in fact several authors have followed Gabbay's original paper. Examples include Burgess [6], Zanardo [45] for branching-time temporal logics, Kuhn [22] and Venema [37, 38, 39, 42, 43] for many-dimensional modal logics (of intervals), and Gabbay & Hodkinson [11], de Rijke [28], Roorda [30]. There is an originally independent Bulgarian line of papers: Passy-Tinchev [26], Gargov & Goranko [12], Gargov, Passy & Tinchev [13], Goranko [17] where similar rules are used in a context of enriched modal formalisms. Finally, in the first order temporal logic of program verifications there is a related concept called 'clock rule' (cf. Sain [34], Andreka, Nemeti & Sain [1] and the references therein). Gabbay [10] contains a lot of new material concerning the irreflexivity and related rules, for example giving a general procedure to find axiomatizations for *any* first order definable temporal connective, over the class of linear orders.

So the question naturally arises whether anything general can be said about logics having rules like the irreflexivity rule --- in fact, the abstract, general perspective is already present in Gabbay [8]. In some way, the situation mirrors the ordinary one in modal logic: if a formula $\phi$ characterizes the class $\mathsf{Fr}_\phi$ of frames where $\phi$ is valid, but this does not necessarily imply that $K\phi$ (the basic logic $K$ extended with $\phi$ as an axiom) axiomatizes this class. Likewise, a formula $\xi$ is a negative characterization of the class $\mathsf{Fr}_{-\xi}$, but does this mean that $K(-\xi)$ ($K$ extended with the non-$\xi$ rule, i.e. the $\xi$-analogon of the irreflexivity rule) forms a complete axiomatization for $\mathsf{Fr}_{-\xi}$? And, what happens when we have an *interplay* of both axioms and these non-$\xi$ rules? These questions form the topic of this paper.

**Outline.**
This introduction proceeds with a subsection in which we give some basic terminology and notation. In section 2 we give a more precise and rigorous formulation of the problem. The following section discusses the formulas that will be allowed as axioms in our general theorem; for these a so-called persistence result is proved. Section 4 contains a concise introduction to $D$, a special modal operator having the inequality relation as its intended accessibility relation. In the sections 5, 7 and 8 we prove, ever more general versions of our main result: section 5 contains the basic idea, in a context with only monadic modal operators and only one special derivation rule; in section 7 we add polyadic operators, and in section 8 we allow arbitrarily many derivation rules. There is a perhaps surprising difference in behaviour between sets of operators in which every monadic operator has a converse (like in tense logic) and sets where this is not the case. These matters are discussed in section 6. We finish off in section 9 by drawing some conclusions, and mentioning some questions for further research.

**Acknowledgements.**
The author of this paper is deeply indebted to Johan van Benthem who taught him modal logic, to Dov Gabbay for many discussions on modal derivation rules, and to Ian Hodkinson and Maarten de Rijke. Finally, an anonymous referee suggested several improvements, and detected some errors.

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

## 2 Negative definability and rules as anti-axioms

In this section we give more formal definitions of the notions introduced in the previous section, and we state the main problem addressed in the paper.

**Definition 2.1** *For a modal formula $\phi$ resp. a set $\Phi$ of modal formulas we define $\mathsf{Fr}_\phi$ (resp. $\mathsf{Fr}_\Phi$) as the class of frames where $\phi$, resp. $\Phi$ is valid. For $\mathsf{Fr}_\top$, the class of all frames, we write $\mathsf{Fr}$. If we want to distinguish this kind of characterization from other sorts, we call it a* positive *characterization.*

*Now let $\xi$ be a modal formula, $\mathsf{K}$ a class of frames. We define $\mathsf{K}_{-\xi}$ as the class of non-$\xi$ frames in $\mathsf{K}$, i.e. those $\mathfrak{F} = (W, I)$ in $\mathsf{K}$ satisfying*

*for every world $w$ there is a valuation $V$ such that $\mathfrak{F}, V, w \models \neg\xi$.*

*For $\Xi$ a set of formulas, we define $\mathsf{K}_{-\Xi}$ as the intersection of all $\mathsf{K}_{-\xi}$, $\xi \in \Xi$. Classes of the form $\mathsf{Fr}_{-\Xi}$ we call* negatively *definable.*

Informally, a frame $\mathfrak{F}$ is a non-$\xi$ frame iff "everywhere in $\mathfrak{F}$, we can get $\xi$ false", by choosing a suitable valuation. Note that this is not the same as saying that we can get $\xi$ "false everywhere": the valuation needed may depend on the particular world where we want to make $\xi$ false.

In fact, we can distinguish *three* classes of frames, all defined using the negation of $\xi$:

1. $\mathsf{Fr}_{\neg\xi}$ (i.e. the class of frames where $\neg\xi$ is valid)
2. $\overline{\mathsf{Fr}_\xi}$ (i.e. the complement of $\mathsf{Fr}_\xi$)
3. $\mathsf{Fr}_{-\xi}$.

These classes need not be identical, for $\mathfrak{F}$ is in $\mathsf{Fr}_{\neg\xi}$ iff *for all* valuations $V$ and *all* worlds $w$, $\mathfrak{F}, V, w \models \neg\xi$; $\mathfrak{F}$ is in the second class iff *there are* a valuation $V$ and a world $w$ with $\mathfrak{F}, V, w \models \neg\xi$, and $\mathfrak{F} \in \mathsf{Fr}_{-\xi}$ means that *for every* world $w$ *there is* a valuation $V$ with $\mathfrak{F}, V, w \models \neg\xi$.

This means, so to speak, that $-\xi$ 'corresponds' to the second order formula

$$\forall x_1 \exists P_0 \ldots P_n \neg\xi^1(x_0),$$

where $\xi^1(x_0)$ is the local model correspondent[^3] of $\xi$, every monadic predicate $P_i$ being the first order counterpart of the propositional variable $p_i$ in $\xi$. Thus we are studying classes of frames that are definable in a version of second order logic where we have a restricted possibility to use existential quantification over monadic predicates.

[^3]: cf. subsection 1.2, or van Benthem [2, 3].

As an example from tense logic, consider the formula $\xi = Gp \to Pp$ (for a definition of our conventions in tense logic, we refer to subsection 1.2), which is locally equivalent on the frame level to $\exists y(Rxy \wedge R^{-1}xy)$. So $\mathsf{Fr}_{-\xi}^t$ is the class of frames $\mathfrak{F}$ with $\mathfrak{F} \models \forall x \forall y(Rxy \to \neg R^{-1}xy)$ i.e. the class of *asymmetric* frames, while the tense frames in $\overline{\mathsf{Fr}_\xi}$ are those frames $\mathfrak{F}$ with $\mathfrak{F} \models \exists x \forall y(Rxy \to \neg R^{-1}xy)$. The negation $Gp \wedge H\neg p$ of $\xi$ can be shown to be globally equivalent to the formula $\neg\exists x \exists y Rxy$, so $\mathsf{Fr}_{-\xi}^t$ finally is the class of frames with empty $R$. As another example, one can show $\mathsf{Fr}_{-(Gp \to FFp)}$ to be the class of *intransitive* frames.

To mention some other examples: let $\mathfrak{F} = (W, R_0, R_1)$ be a frame where we want $R_0$ and $R_1$ to be each others *complement*. One requirement to $R_0$ and $R_1$ is that their intersection is empty. It is easy to verify that this disjointness property is negatively characterized by the formula $\Box_0 p \to \Diamond_1 p$.

Negative definability is abundant in (multi-)modal formalisms with a many-dimensional flavour, cf. the references mentioned in the introduction. The problematic properties needed to be characterized here usually have to do with the fact that the dimensions of the system should not overlap, and are thus often related to the 'disjointness'-property mentioned above.

In all these examples the second order definition of $\mathsf{Fr}_{-\xi}$ can be replaced by a first order one, but this need not always be the case: consider the formula $\delta \equiv (Fp \wedge FG\neg p) \to F(HFp \wedge G\neg p)$, which characterizes the Dedekind-complete frames among the linear orderings. The class $\mathsf{Fr}_{-\delta}$ cannot be elementary, since its intersection with the class of linear frames consists of those $\mathfrak{F} = (W, <)$ having a 'gap' above each point (a gap above $t \in W$ is a partition $X, Y$ of $W$ with $X$ downward closed and $t \in X$, such that $X$ does not have a maximum, nor $Y$ a minimum).

On the other hand, $\mathsf{Fr}_{-\xi}$ may be first order definable while $\mathsf{Fr}_\xi$ is not: consider the Lob formula $L = (\Box(\Box p \to p) \to \Box p)$. It is well-known that $\mathsf{Fr}_L$ consists of the frames $\mathfrak{F} = (W, R)$ with $R$ transitive and its converse well-founded. However (as Johan van Benthem observed), $\mathsf{Fr}_{-L}$ contains precisely the frames where every world has a successor, i.e. $\mathsf{Fr}_{-L} = \mathsf{Fr}_{\Diamond\top}$.

It is still a matter of research, whether we can give a structural characterization of negative definability, analogous to the Goldblatt-Thomason result (cf. [16]) for positive definability.

We now turn to axiomatics; we are interested in the logic $\Theta(\mathsf{Fr}_{-\xi})$ consisting of all formulas valid in $\mathsf{Fr}_{-\xi}$. For a generalization of the irreflexivity rule, we follow Gabbay [8], though we use the name 'non-$\xi$ rule' instead of his '$I\xi$-rule':

**Definition 2.2** *Let $\xi(p_0, \ldots, p_{n-1})$ be a modal formula. The $\neg\xi$-consistency rule, or shorter: the non-$\xi$ rule is the following derivation rule:*

$(N\xi R) \qquad \vdash \neg\xi(p_0, \ldots, p_{n-1}) \to \phi \ \Rightarrow \ \vdash \phi, \quad \text{if } \vec{p} \notin \phi.$

*If $\Lambda$ is a derivation system and $\xi$ a formula ($\Xi$ a set of formulas), then $\Lambda(-\xi)$ ($\Lambda(-\Xi)$) denotes the system $\Lambda$ extended with the non-$\xi$ rule (all non-$\xi$ rules, $\xi \in \Xi$).*

Just like for the irreflexivity rule, the best way to understand the non-$\xi$ rule is by its soundness over the class of non-$\xi$ frames:

**Lemma 2.3** *If $\mathsf{Fr}_{-\xi} \models \neg\xi(p_0, \ldots, p_{n-1}) \to \phi$ and no $p_i$ occurs in $\phi$, then $\mathsf{Fr}_{-\xi} \models \phi$.*

**Proof.**
We will prove the lemma by showing that

> If $\phi$ is $\Theta(\mathsf{Fr}_{-\xi})$-consistent and none of the $p_i$ occurs in $\phi$, then the formula $\phi \wedge \neg\xi(p_0, \ldots, p_{n-1})$ is $\Theta(\mathsf{Fr}_{-\xi})$-consistent.

Let $\phi$ be a $\Theta(\mathsf{Fr}_{-\xi})$-consistent formula, then there is a model $\mathfrak{M} = (\mathfrak{F}, V)$ with $\mathfrak{F}$ is in $\mathsf{Fr}_{-\xi}$, and a world $w$ in $\mathfrak{M}$ where $\mathfrak{M}, w \models \phi$. Let $p_0, \ldots, p_{n-1}$ be *new* propositional variables, in the sense that they are not elements of $Dom(V)$. As $\mathfrak{F}, w \not\models \xi$, there is a valuation $V'$ such that $\mathfrak{F}, V', w \models \neg\xi(p_0, \ldots, p_{n-1})$. Now let $V''$ be defined by

$$V''(q) = V(q) \quad \text{if } q \in Dom(V)$$
$$V''(p_i) = V'(p_i) \quad \text{for } i = 0, \ldots, n-1.$$

then clearly we have $(\mathfrak{F}, V''), w \models \phi \wedge \neg\xi$, which proves the lemma. $\square$

The aim however is of course to try and show *completeness* for non-$\xi$ rules; this is the main subject of this paper. As we have already mentioned in the introduction, in general we do not have an isolated $N\xi R$ added to a minimal (tense) logic, but a situation in which we add possibly more than one $N\xi R$ to a logic having other axioms besides the basics.

So the general situation, described by Gabbay [8, 10] is the following: we have a similarity type $S$, an $S$-logic $\Lambda$ which is (strongly) sound and complete with respect to a class of frames $\mathsf{K}$, and a set of formulas $\Xi$. The question now is the following

> Is $\Lambda(-\Xi)$ strongly complete with respect to $\mathsf{K}_{-\Xi}$ ?

Gabbay proves a 'generalized irreflexivity lemma' stating that a $\Lambda(-\xi)$-consistent set $\Sigma$ of formulas has a model $\mathfrak{M}$ with $\mathfrak{M} \models \Theta(\mathsf{Fr}_{\Lambda, -\Xi})$. Unfortunately, this is not enough to prove completeness, for we have to find a model $\mathfrak{M}$ such that the underlying *frame* is in $\mathsf{Fr}_{-\Xi}$.

In general this seems to be difficult and maybe even impossible to establish. Therefore we concentrate on logics with a special, nice kind of axioms, viz. so-called Sahlqvist tense formulas, which form the topic of the next section.

---

## 3 Sahlqvist tense formulas

In this section we discuss the formulas that are allowed as axioms in the derivation systems to which our main result on completeness will apply.

It is well-known that on the level of frames every formula $\phi$ locally and globally has a *second order* equivalent $\phi^2$. In many important cases however, it turns out that this formula $\phi^2$ has a much simpler *first order* equivalent (in the corresponding frame language $L_S$). Well-known examples include reflexivity for $p \to \Diamond p$ and the Church-Rosser property for $\Diamond\Box p \to \Box\Diamond p$. A general theorem in this direction was found by Sahlqvist (cf. [31]). The *correspondence* part of Sahlqvist's theorem gives a decidable set of modal $S$-formulas having a local equivalent in $L_S$. In [3], van Benthem provides a quite perspicuous algorithm to find this first order correspondent $\phi^*$ of a Sahlqvist formula $\phi$. (At the end of this section, we will give our version of his *substitution method*.) The second, *completeness* part of the Sahlqvist theorem states that adding a set $\Sigma$ of Sahlqvist axioms to the minimal $S$-logic $K_S$, we obtain a complete axiomatization for the class of frames $\mathsf{Fr}_\Sigma$. An accessible version of the proof of this part can be found in Sambin & Vaccaro [35], from which we took some terminology. The correspondence and completeness part of Sahlqvist's theorem are closely connected; in Kracht [21] they are studied in a unifying framework.

**Definition 3.1** *A* strongly positive formula *is a conjunction of formulas $\Box_1 \ldots \Box_m p_i$ ($m \ge 0$). A formula is* positive (negative) *if every propositional variable occurs under an even (odd) number of negation symbols. A modal formula is* untied *if it is obtained from strongly positive formulas and negative ones by applying only $\wedge$ and arbitrary existential modal operators. Formulas of the form $\phi \to \psi$ with $\phi$ an untied formula and $\psi$ a positive one, are called* Sahlqvist formulas[^4].

[^4]: In fact, we may even consider the wider set of formulas obtained from (basic) Sahlqvist formulas by applying *duals* of existential modal operators.

**Theorem 3.2** *(SAHLQVIST)*
*Let $\sigma$ be a Sahlqvist formula. Then*
**(i)** *$\sigma$ is canonical: $\mathfrak{F}_{K\sigma}^c \models \sigma$.*
**(ii)** *$K\sigma$ is strongly sound and complete with respect to $\mathsf{Fr}_\sigma$.*
**(iii)** *There is an effectively obtainable first order $L_S$-formula $\sigma^*(x_0)$ such that for all frames $\mathfrak{F}$, all $w$ in $\mathfrak{F}$:*

$$\mathfrak{F}, w \models \sigma \iff \mathfrak{F} \models \sigma^*[x_0 \mapsto w].$$

**Proof.**
For **(i)** we refer to Sambin & Vaccaro [35]; **(ii)** is immediate by **(i)**. The last part **(iii)** will be proved at the end of this section, after we have given the algorithm to find $\sigma^*(x_0)$ in 3.15.
$\square$

A typical example of a formula which is *not* Sahlqvist, is $\Box\Diamond p \to \Diamond\Box p$. A typical example of a Sahlqvist formula is $\Diamond\Box p \to \Box\Diamond p$; its first order correspondent is $\forall y_0 y_1((Rxy_0 \wedge Rxy_1) \to \exists z(Ry_0 z \wedge Ry_1 z))$.

In the above theorem we saw that a Sahlqvist formula is *canonical*: if it holds in the canonical model, then it is valid on all models on the underlying canonical frame. In this paper we develop and use non-standard notions of canonical structures, for which we have to adapt the proof of the Sahlqvist theorem. In fact we will show that van Benthem's substitution method (which deals with Kripke frames) also works for the following class of *general* frames:

**Definition 3.3** *A general frame $\mathfrak{G} = (\mathfrak{F}, A)$ is* discrete *if for all worlds $w$ in $\mathfrak{F}$, $\{w\} \in A$.*

For our definitions concerning tense logic, we refer to subsection 1.2.

**Definition 3.4** *A Sahlqvist tense formula, or shortly: an St-formula is a Sahlqvist formula satisfying the extra constraint that all boxes occurring in strongly positive formulas are tense boxes.*

As an example of a Sahlqvist formula which is not an St-formula, we can take the Church-Rosser formula $\Diamond\Box p \to \Box\Diamond p$ (at least, if $\Diamond$ is not a tense diamond). The 'tense axiom' $p \to \Box^{-1}\Diamond p$ itself is an St-formula. Note that in a tense similarity type, there is no distinction between Sahlqvist formulas and St-formulas.

The theorem that we need is the following:

**Theorem 3.5** *Let $\mathfrak{G} = (\mathfrak{F}, A)$ be a discrete general tense frame and $\sigma$ a Sahlqvist tense formula such that $\mathfrak{G} \models \sigma$. Then $\mathfrak{F} \models \sigma$.*

The remainder of this section is devoted to prove Theorem 3.5; as a side result, we can give an easy formulation of the algorithm producing the first order correspondent of a Sahlqvist formula.

The definition of Sahlqvist formulas is a syntactic one, but in fact the important constraint on the consequent is a semantic one, viz. monotonicity:

**Definition 3.6** *Let $V$ and $V'$ be two valuations on a frame $\mathfrak{F}$. $V'$ is* wider *than $V$, notation: $V \le V'$, if for all atoms $p$, $V(p) \subseteq V'(p)$. A modal formula $\phi$ is* monotone *if for all $\mathfrak{F}$, $V$, $V'$ and $w$:*

$$\mathfrak{F}, V, w \models \phi \text{ and } V \le V' \text{ imply } \mathfrak{F}, V', w \models \phi$$

We also need related concepts for the first order model-language.

**Definition 3.7** *Let $Q$ be the set of propositional variables of the language. Recall that $L_{S,Q}$ denotes the first order language with $S$-accessibility predicates and a monadic predicate $P_i$ for every propositional variable $p_i \in Q$. The sign of an occurrence of a predicate $T$ in a formula $\phi$ is defined by induction to $\phi$: $T$ occurs positively in the atomic formula $Tx_0 \ldots x_{n-1}$. If $T$ occurs positively (negatively) in $\phi$, then it occurs negatively (positively) in $\neg\phi$, and positively (negatively) in $\phi \vee \psi$ and $\exists x\phi$. An $L_{S,Q}$-formula is* positive (negative) *if all occurrences of $Q$-predicates are positive (negative).*
*An $L_{S,Q}$-formula $\phi(x_1, \ldots, x_n)$ is* monotone *if for all valuations $V, V'$ and all $n$-tupels $w_1, \ldots, w_n$:*

$$\mathfrak{F}, V \models \phi[w_1, \ldots, w_n] \text{ and } V \le V' \text{ imply } \mathfrak{F}, V' \models \phi[w_1, \ldots, w_n].$$

Note that in the above definition it does not matter how the *accessibility* predicates occur in a formula. There is a lot to be said about the above concepts, but we confine ourselves to the following facts, of which the proof is standard:

**Lemma 3.8** **(i)** *If $\phi$ is positive (negative), then so is its model correspondent $\phi^1$.*
**(ii)** *Negations of positive (negative) formulas are equivalent to negative (positive) ones.*
**(iii)** *Positive formulas are monotone.*

To prove Theorem 3.5, from here until definition 3.15 we fix a St-formula $\sigma$ and a general frame $\mathfrak{G} = (\mathfrak{F}, A)$, $\mathfrak{F} = (W, R_\nabla)_{\nabla \in S}$ such that $\mathfrak{G} \models \sigma$. To establish the validity of $\sigma$ in $\mathfrak{F}$, we must prove that for every valuation $V$, we have $\mathfrak{F}, V \models \sigma$. So, let us start with defining a set of valuations for which we already know that $\mathfrak{F}, V \models \sigma$.

**Definition 3.9** *A valuation $V$ is* admissible *if $V(p) \in A$ for all atoms $p$.*

**Lemma 3.10** *For all admissible valuations $V$, $\mathfrak{F}, V \models \sigma$.*

**Proof.**
Immediate by $\mathfrak{G} \models \sigma$ and the definitions. $\square$

We now proceed to define a second kind of valuations, intuitively those forming the *minimal* valuations needed to make the strongly positive formulas, (these being the 'real' antecedent of the Sahlqvist formula $\sigma$,) true in a world of $W$.

**Definition 3.11** *First we define* basic rudimentary formulas, *or short,* br-formulas: *a basic rudimentary formula of length 0 is of the form $\beta(x, y) \equiv x = y$. If $\beta(x, x_n)$ is a basic rudimentary formula of length $n$ and $R_\Diamond$ is the accessibility symbol of a tense diamond, then $\exists x_n(\beta(x, x_n) \wedge R_\Diamond x_n y)$ is a basic rudimentary formula of length $n + 1$.*

*A* rudimentary formula, *or short, an* r-formula, *is of the form*

$$\rho(x_1, \ldots, x_n, y) \equiv \bigvee_{1 \le i \le n} \beta_i(x_i, y),$$

*where every $\beta_i$ is a disjunction of basic rudimentary formulas in $x_i$ and $y$.*
*A subset $X$ of $W$ is* rudimentary *if it is rudimentary in some $w_1, \ldots, w_n \in W$, i.e. for some rudimentary formula $\rho(x_1, \ldots, x_n, y)$, $X = \{v \in W \mid \mathfrak{F} \models \rho(w_1, \ldots, w_n, v)\}$.*
*A valuation $V$ is* rudimentary *if for all atoms $p$, $V(p)$ is rudimentary.*

Note that, intuitively, a basic rudimentary formula $\beta(x, y)$ of length $n$ describes the existence and form of an path from $x$ to $y$ following tense accessibility relations. A rudimentary formula $\rho(x_1, \ldots, x_n, y)$ describes the position of $y$ with respect to $x_1, \ldots, x_n$ in the frame, in terms of 'tense paths' leading from $x_i$ to $y$, for every $x_i$.

**Lemma 3.12** *Rudimentary valuations on discrete general tense frames are admissible.*

**Proof.**
It is sufficient to prove that for every r-formula $\rho(x_1, \ldots, x_n, y)$, the sets $X_{p,\vec{w}} = \{v \in W \mid \mathfrak{F} \models \rho(\vec{w}, v)\}$ are in $A$ for all $n$-tupels $\vec{w} = (w_1, \ldots, w_n)$ of worlds in $W$. Because $A$ is closed under finite unions, it suffices to show the above for *basic* rudimentary formulas. By induction to the length $k$ of a basic formula $\beta(x, y)$ we prove the following claim:

> For every $w \in W$, $X_{\beta,w} \in A$.

For $k = 0$, we have $X_{\beta,w} = \{w\} \in A$ by the discreteness of $\mathfrak{G}$.
For $k = m + 1$, let $\beta(x, y)$ be of the form $\exists x_n(\beta'(x, x_n) \wedge R_\Diamond x_n y)$ where $\Diamond$ is a tense diamond. Now $X_{\beta,w} = \{v \in W \mid \mathfrak{F} \models \beta(w, v)\}$ is the set of worlds $v$ such that there is a $u \in W$ with $\mathfrak{F} \models \beta'(w, u)$ and $\mathfrak{F} \models R_\Diamond uv$.

So $X_{\beta,w}$ contains precisely the worlds having an $R_\Diamond$-predecessor in $X_{\beta',w}$, or

$$X_{\beta,w} = \{v \in W \mid v \text{ has an } R_{\Diamond^{-1}}\text{-successor in } X_{\beta',w}\}.$$

By the induction hypothesis, $X_{\beta',w}$ is in $A$, and by the fact that we are in a *tense* frame, $(R_\Diamond)^{-1}$ is the accessibility relation of $\Diamond^{-1}$. So $X_{\beta,w} = m_{\Diamond^{-1}}(X_{\beta',w}) \in A$, by definition of a general frame (cf. subsection 1.2). $\square$

Note that in the above proof it is essential to have *tense* operators in *tense* frames.

**Lemma 3.13** *Let $\psi$ be an untied formula. Then its first order model-equivalent $\psi^1(x_0)$ is equivalent to*

$$\exists x_1 \ldots x_n\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y) \wedge \bigwedge_{j < m} N_j(u_j)\big).$$

*where the $x_i$'s are distinct variables different from $x_0$, all the variables $u_i$ are among $x_0, \ldots, x_n$, $\pi$ is a conjunction of atomic $L_S(x_0, \ldots, x_n)$-formulas (i.e. atomic accessibility formulas of the form $R_\nabla(x_{i_0}, \ldots, x_{i_{\rho(\nabla)}})$ with $\nabla$ an arbitrary $S$-operator and every variable in $\{x_0, \ldots, x_n\}$), the $\rho_i$'s are suitable rudimentary formulas, and the $N_j$'s are negative.*

**Proof.**
By a straightforward induction to the complexity of untied formulas, cf. Sambin & Vaccaro [35]. $\square$

**Lemma 3.14** *Let $\sigma = \psi_1 \to \psi_2$ be a Sahlqvist formula. Then $\sigma^1(x_0)$ is equivalent to*

$$\forall x_1 \ldots x_n\Big(\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)\big) \to \gamma_2(x_0, \ldots, x_n)\Big).$$

*where the antecedent is as in the previous lemma and the consequent $\gamma_2$ is some positive formula.*

**Proof.**
Let $N(x_0, \ldots, x_n)$ be the formula $\bigwedge_{j < m} N_j(u_j)$, then $N$ is negative. By the previous lemma, the local model correspondent $\sigma^1(x_0)$ of $\sigma$ is equivalent to

$$\forall x_1 \ldots x_n\Big(\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y) \wedge N\big) \to \psi_2^1(x_0)\Big).$$

So, by moving the negative $N$ from the antecedent to the consequent, we obtain

$$\forall x_1 \ldots x_n\Big(\big(\pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)\big) \to \big(\neg N \vee \psi_2^1(x_0)\big)\Big).$$

where the antecedent is already as desired, and the consequent is positive as it is a disjunction of two positive formulas (cf. lemma 3.8). $\square$

**Proof of Theorem 3.5**
Let $\sigma$ be of the form $\psi_1 \to \psi_2$, where $\psi_1$ is untied and $\psi_2$ is positive. We use the notation of the previous lemmas and set

$$\gamma_1(x_0, \ldots, x_n) \equiv \pi \wedge \bigwedge_{i < k} \forall y(\rho_i(\vec{x}, y) \to P_i y)$$

Obviously, $\sigma^1(x_0)$ is equivalent to $\forall x_1 \ldots x_n(\gamma_1 \to \gamma_2)$, where $\gamma_2$ is positive and hence monotone.
So by the fact that $\mathfrak{G} = (\mathfrak{F}, A) \models \sigma$ we get

$$\text{for all admissible valuations } V, \quad \mathfrak{F}, V \models \forall x_0 \ldots x_n(\gamma_1 \to \gamma_2). \tag{1}$$

Our aim is to show that this implies $\mathfrak{F} \models \sigma$, or equivalently

$$\text{for all valuations } V, \quad \mathfrak{F}, V \models \forall x_0 \ldots x_n(\gamma_1 \to \gamma_2). \tag{$\dagger$}$$

So let a valuation $V$ be given, together with worlds $w_0, w_1, \ldots, w_n \in W$ for which we have

$$\mathfrak{F}, V \models \gamma_1(w_0, w_1, \ldots, w_n). \tag{2}$$

Now let $V^-$ be the rudimentary valuation that precisely 'fits' in $\gamma_1$, i.e. $V^-(p_i) = \{v \in W \mid \mathfrak{F} \models \rho_i(\vec{w}, v)\}$ and $V^-(q) = \emptyset$ if $q$ is not one of the $p_i$. Then

$$\mathfrak{F}, V^- \models \gamma_1(w_0, w_1, \ldots, w_n). \tag{3}$$

$V^-$ is admissible by lemma 3.12, so (1) and (3) give

$$\mathfrak{F}, V^- \models \gamma_2(w_0, w_1, \ldots, w_n). \tag{4}$$

But by (2) and definition of $V^-$, we have $V^- \le V$. Together with the fact that $\gamma_2$ is monotone, this yields

$$\mathfrak{F}, V \models \gamma_2(w_0, w_1, \ldots, w_n), \tag{5}$$

which ensures ($\dagger$). $\square$

As a matter of fact, from this proof it is only a minor step to give the algorithm producing the correspondent $\sigma^*(x_0)$ of an arbitrary (i.e. not necessarily tense) Sahlqvist formula:

**Definition 3.15** *For a Sahlqvist formula $\sigma$, let $\sigma^*(x_0)$ be the $L_S$-formula*

$$\forall x_1 \ldots x_n(\pi \to (\gamma_2(x_0, \ldots, x_n)[\rho_i(\vec{x}, u)/P_i u]))$$

*(i.e. we substitute, everywhere in $\gamma_2$, $\rho_i(\vec{x}, u)$ for an atomic formula of the form $P_i u$, and $\bot$ for any of the other atomic formulas $Qu$.)*

**Proof of Theorem 3.2(iii)** *(SAHLQVIST CORRESPONDENCE).*
We have to prove, for $\sigma$ an arbitrary Sahlqvist formula, $w$ a world in a frame $\mathfrak{F}$:

$$\mathfrak{F}, w_0 \models \sigma \iff \mathfrak{F} \models \sigma^*[x_0 \mapsto w_0].$$

($\Rightarrow$) Let $w_1, \ldots, w_n$ be such that $\mathfrak{F} \models \pi[w_0, \ldots, w_n]$. This implies that, with $V^-$ the valuation such that

$$V^-(p_i) = \{v \in W \mid \mathfrak{F} \models \rho_i(\vec{w}, v)\},$$

we have

$$\mathfrak{F}, V^- \models \pi \wedge \forall y(\rho_i(\vec{x}, y) \to P_i y)[w_0, \ldots, w_n].$$

So by the assumption $\mathfrak{F}, w_0 \models \sigma$, lemma 3.14 gives $\mathfrak{F}, V^- \models \gamma_2(w_0, \ldots, w_n)$. By definition of $V^-$ we immediately obtain

$$\mathfrak{F} \models (\gamma_2(x_0, \ldots, x_n)[\rho_i(\vec{x}, u)/P_i u])[w_0, \ldots, w_n],$$

which is what we desired.

($\Leftarrow$) Here we can copy the proof of Theorem 3.5, after making the observation that now

$$\mathfrak{F}, V^-, w_0 \models \sigma$$

by definition of $\sigma^*$ and the assumption $\mathfrak{F} \models \sigma^*[w_0]$. $\square$

---

## 4 The $D$-operator

An important role in this paper is played by the so-called *difference* operator $D$. This operator is special in having the *inequality* relation as its intended accessibility relation:

**Definition 4.1** *Let $S$ be a similarity type containing the monadic modal operator $D$. An $S$-frame $\mathfrak{F} = (W, R_\nabla)_{\nabla \in S}$ is called $(D$-)standard if*

$$R_D = \{(s,t) \in {}^2W \mid s \ne t\}.$$

*As abbreviations we use $\underline{D}\phi \equiv \neg D\neg\phi$, $O\phi \equiv \phi \wedge \underline{D}\neg\phi$, $E\phi \equiv \phi \vee D\phi$.*
*For $\mathsf{K}$ a class of $S$-frames, we denote the class of standard frames in $\mathsf{K}$ by $\mathsf{K}^\ne$.*

When referring to standard frames, we will suppress mentioning the inequality relation $R_D$. Thus we may identify standard frames for $S$ with the frames for the similarity type obtained by dropping $D$ from $S$. In the sequel we will frequently omit the adjective 'standard' when referring to the intended semantics, explicitly using the term 'non-standard' for the frames with $R_D \ne \{(s,t) \in {}^2W \mid s \ne t\}$. Note that in a standard model we have

- $\mathfrak{M}, w \models D\phi$ &emsp; iff &emsp; there is a $v \ne w$ with $\mathfrak{M}, v \models \phi$,
- $\mathfrak{M}, w \models O\phi$ &emsp; iff &emsp; $w$ is the *only* world with $\mathfrak{M}, w \models \phi$,
- $\mathfrak{M}, w \models E\phi$ &emsp; iff &emsp; there is a world $v$ with $\mathfrak{M}, v \models \phi$.

In many examples the $D$-operator is *definable* in the poorer language; for example, over the class $\mathsf{LI}$ of irreflexive linear orderings we have

$$\mathsf{LI} \models D\phi \leftrightarrow (F\phi \vee P\phi).$$

The $D$-operator was introduced independently by various authors, including, in (probably) chronological order: Sain [32, 33], Koymans [20] and Gargov-Passy-Tinchev [13]. A nice feature of this new operator, and the main reason for its introduction, is the fact that it greatly increases the expressive power of the language. For example, *irreflexivity* is easily seen to be characterized by the formula $\Diamond p \to Dp$. Maarten de Rijke proved many results on the expressiveness and completeness of modal and tense logics having a $D$-operator, cf. [28]. We only need the following:

**Definition 4.2** *Let $S$ be a similarity type containing $D$. For $\Lambda$ an $S$-logic, $\Lambda D$ denotes the logic $\Lambda$ extended with the following axioms:*

- $(D1)$ &emsp; $p \to \underline{D}Dp$
- $(D2)$ &emsp; $DDp \to (p \vee Dp)$
- $(D3_\nabla)$ &emsp; $\nabla(p_1, \ldots, p_n) \to \bigwedge Ep_i$.

*$\Lambda D^+$ is the logic $\Lambda D$ extended with the irreflexivity rule for $D$:*

$(IR_D) \qquad \vdash Op \to \phi \ \Rightarrow \ \vdash \phi, \text{ if } p \notin \phi.$

*Instead of $K_{\{D\}}$ (the minimal $D$-logic), we write $K_D$, instead of $K_D D$: $KD$.*

Note that the rule $IR_D$ is an example of a non-$\xi$ rule.

**Theorem 4.3** *For any similarity type $S$, both $K_S D$ and $K_S D^+$ are strongly sound and complete with respect to the class of standard $S$-frames.*

**Proof.**
Cf. de Rijke [28]. $\square$

As a corollary of this completeness theorem some nice semantic properties of the operators are also *provable*:

**Lemma 4.4** *Let $S$ be a similarity type containing the $D$-operator and $\nabla$. Then*
**(i)** &emsp; $KD^{(+)} \vdash E(Op \wedge \phi) \wedge E(Op \wedge \neg\phi) \to \bot$.
**(ii)** &emsp; $K_S D^{(+)} \vdash (\nabla(\ldots, Op \wedge \phi, \ldots) \wedge \nabla(\ldots, Op \wedge \neg\phi, \ldots)) \to \bot$.
**(iii)** &emsp; $K_S D^{(+)} \vdash \bigwedge_i \nabla(\ldots, Op \wedge \phi_i, \ldots) \to \nabla(\ldots, Op \wedge \bigwedge_i \phi_i, \ldots)$.

**Proof.**
By showing that the above schemes of formulas are semantically *valid* in standard frames, and then using the completeness theorem for $KD^{(+)}$. $\square$

*Combining* the notions of Sahlqvist (tense) formulas and the $D$-operator, we seem to have two options. Because of the general result on Sahlqvist correspondence, we know that every Sahlqvist formula $\sigma$ has a local correspondent $\sigma^{s'}(x_0)$ in the language $L_S$ where $R_D$ is the symbol for the accessibility relation of $D$. However, we are almost exclusively interested in the way this equivalence works out for the *standard* $S$-frames; this means that we will only consider interpretations where $R_D$ is the inequality relation. It is then very natural to let this preference be reflected in the syntax, by a slight abuse of notation:

**Definition 4.5** *Let $S$ be a similarity type and $\sigma$ a Sahlqvist formula. If $S$ does not contain the $D$-operator, $\sigma^s(x_0)$ denotes the ordinary first order Sahlqvist equivalent of $\sigma$ given in Definition 3.15. If $S$ does contain $D$, $\sigma^{s'}(x_0)$ denotes this ordinary first order equivalent, $\sigma^s(x_0)$ is $\sigma^{s'}(x_0)$ with every occurrence of $R_D$ replaced by $\ne$.*

As an example, the Sahlqvist correspondent of $\Diamond p \to Dp$ is not $\forall x_1(Rx_0 x_1 \to R_D x_0 x_1)$, but $\forall x_1(Rx_0 x_1 \to x_0 \ne x_1)$, (or even better: $\neg Rx_0 x_0$.) With this notation we have equivalence of $\sigma$ and $\sigma^s$ for the standard frames:

**Theorem 4.6** *Let $\sigma$ be a Sahlqvist formula, $w$ a world in a standard frame $\mathfrak{F}$. Then*

$$\mathfrak{F}, w \models \sigma \iff \mathfrak{F} \models \sigma^s(w_0).$$

**Proof.**
Straightforward by Theorem 3.2 and the definitions of $\sigma^s$ and standard frames. $\square$

However, by restricting our attention to standard frames we lose the automatic completeness of Sahlqvist's theorem: where we do have, for a set of Sahlqvist axioms $\Sigma$,

> $K_S D\Sigma$ is strongly sound and complete w.r.t. $\mathsf{Fr}_\Sigma$,

we are not (yet) sure whether

> $K_S D^+\Sigma$ is strongly sound and complete w.r.t. $\mathsf{Fr}_\Sigma^\ne$.

In the next section we will prove the above statement, for Sahlqvist *tense* axioms.

---

## 5 The main proof

This subsection contains the main idea on the proof of the Sahlqvist theorem in a context with non-$\xi$ rules. To keep notation as simple as possible, we consider a tense similarity type $S$ having besides the difference operator $D$ only one pair $\{F, P\}$ of tense operators. We let $\Diamond$ range over the monadic modal operators, $\Box$ is the dual of $\Diamond$, and $\Diamond^{-1}$ is the converse of $\Diamond$, i.e. $F^{-1} = P$, $P^{-1} = F$ and $D^{-1} = D$. Note that for this similarity type there is no distinction between ordinary Sahlqvist formulas and Sahlqvist tense formulas. We intend to prove the following theorem, keeping some generalizations and corollaries for later subsections.

**Theorem 5.1** *(SD-THEOREM --- monadic operators)*
*Let $S$ be a tense similarity type with three diamonds $F$, $P$ and $D$, and let $\sigma$ be a Sahlqvist formula. Then $K^t D^+\sigma$ is strongly sound and complete with respect to $\mathsf{Fr}_{\sigma}^{t,\ne}$.*

Recall that $K^t D^+\sigma$ has the following axioms:

- $(CT)$ &emsp; all classical tautologies
- $(DB)$ &emsp; $\Box(p \to q) \to (\Box p \to \Box q)$
- $(CV)$ &emsp; $p \to HFp$
- $(D1)$ &emsp; $p \to \underline{D}Dp$
- $(D2)$ &emsp; $DDp \to (p \vee Dp)$
- $(D3)$ &emsp; $\Diamond p \to p \vee Dp$
- $(\sigma)$ &emsp; $\sigma$

Its derivation rules are

- $(MP)$ &emsp; Modus Ponens
- $(UG)$ &emsp; Universal Generalization
- $(SUB)$ &emsp; Substitution

and the irreflexivity rule for $D$:

$(IR_D) \qquad \vdash Op \to \phi \ \Rightarrow \ \vdash \phi, \text{ if } p \notin \phi.$

Note that the above theorem is not an automatic corollary of the ordinary Sahlqvist theorem, because of the special interpretation for the accessibility relation of $D$ that we have in mind, namely the inequality relation. A proof of Theorem 5.1 via the ordinary canonical model-method seems to be impossible, as the $K^t D^+\sigma$-canonical frame need not be standard.

As an example, let $\sigma$ express $S5$-behaviour of $F$, and consider a $D$-standard model $\mathfrak{M} = (W, R_F, V)$ with total $R_F$ and two worlds $w, w'$ verifying the same atoms. We easily show that $\mathfrak{M}, w \models \phi \to D\phi$ for all formulas $\phi$. So the set $\Delta = \{\psi | \mathfrak{M}, w \models \psi\}$, being a maximal consistent set and thus a world of the $K^t D^+\sigma$-canonical frame, must be $R_D$-reflexive.

So it turns out that the canonical frame is bad because it may contain $R_D$-reflexive worlds. A naive approach to this problem is to simply throw them out of the canonical universe. This is not sufficient however: consider the set

$$\{p_0 \wedge \underline{D}\neg p_0\} \cup \{F\top\} \cup \{G(\phi \to D\phi) \mid \phi \text{ a formula}\}.$$

Without too many problems, we can again find a $\sigma$ for which this set is $K^t D^+\sigma$-consistent, so it has a maximal consistent extension $\Delta \in W^c$. $\Delta$ itself is not $R_D$-reflexive, but all of its $R_F$-successors are. So $\Delta$, having at least one $R_F$-successor, is an unwelcome inhabitant of the canonical frame too.

Now instead of successively throwing bad MCSs out of the canonical frame, we feel it is better to follow a more constructive path, defining a canonical-like model consisting only of good MCSs. To give this notion of a 'good' MCS, we need some auxiliary definitions, the intuition behind which is the following: suppose we have a MCS $\Gamma$ with a formula $\phi$ of the form

$$\phi_0 \wedge \Diamond_1(\phi_1 \wedge \ldots \Diamond_{n-1}(\phi_{n-1} \wedge \Diamond_n \phi_n)),$$

in $\Gamma$. In the canonical model, we have the existence of the path $\Gamma = \Gamma_0 R_{\Diamond_1} \Gamma_1 \ldots R_{\Diamond_n} \Gamma_n$ such that every $\phi_i \in \Gamma_i$. In our version of the canonical model, we want an additional condition to be satisfied, viz. each $\Gamma_i$ should be $R_D$-irreflexive. The idea is now to envisage this already in $\Gamma$, by demanding that in $\phi$, we can put 'next to' each $\phi_i$, a formula $Op_i$ witnessing this $R_D$-irreflexivity.

**Definition 5.2** *We denote the relation '$\psi$ is a subformula of $\phi$' by $\psi \unlhd \phi$. Assume that we do not identify different occurrences of $\psi$ in $\phi$ (for instance, $\phi$ has two distinct occurrences in $\phi \wedge \phi$.) For notational elegance, instead of $\vee$ we take $\wedge$ as our basic boolean connective.*

Now let $\phi, \psi, \chi$ be formulas such that $\psi \unlhd \phi$. We define $W(\chi, \psi, \phi)$ ('$\phi$ with $\chi$ witnessing at $\psi$') by induction on the structure of $\phi$ above $\psi$ --- i.e., $\psi$ is treated as atomic in $\phi$.

$$W(\chi, \psi, q) = q \quad (\text{provided } \psi \ne q)$$
$$W(\chi, \psi, \psi) = \chi \wedge \psi$$
$$W(\chi, \psi, \neg\phi) = \neg\phi$$
$$W(\chi, \psi, \phi \wedge \phi') = W(\chi, \psi, \phi) \wedge W(\chi, \psi, \phi')$$
$$W(\chi, \psi, \Diamond\phi) = \Diamond W(\chi, \psi, \phi)$$

A maximal consistent set $\Sigma$ is *distinguishing*, or a *d-theory* if for every $\phi$ in $\Sigma$ and every $\psi \unlhd \phi$, there is a propositional variable $p$ with $W(Op, \psi, \phi)$ in $\Sigma$.

Note that as d-theories are MCSs, the canonical accessibility relations $R_F^c$, $R_P^c$ and $R_D^c$ for $F$, $P$ and $D$ have the ordinary meaning:

$$R_\Diamond^c \Sigma \Delta \text{ iff for all } \phi \in \Delta, \ \Diamond\phi \in \Sigma$$

We want to take the d-theories as the possible worlds in our version of the canonical model, the definition ensuring that any d-theory is $R_D$-irreflexive. A minimal constraint which a canonical-ish model must meet is that every consistent set of formulas is somehow to be found as (part of) a possible world. In our setting this means that every consistent set must have a distinguishing extension.

First we need a lemma of a rather technical nature:

**Lemma 5.3** *If $p$ does not occur in $\phi$ or $\eta$, then for any $\psi \unlhd \phi$ we have $\vdash W(Op, \psi, \phi) \to \eta \Rightarrow \vdash \phi \to \eta$.*

**Proof.**
By induction to the structure of $\phi$ above $\psi$.

In the case where $\phi = \psi$, we find $W(Op, \psi, \phi) = Op \wedge \phi$, so we get $\vdash (Op \wedge \phi) \to \eta \Rightarrow \vdash Op \to (\phi \to \eta)$ $\Rightarrow \vdash \phi \to \eta$, where the last step is by one application of $IR_D$.

The induction steps for the Boolean cases we leave to the reader, concentrating on the case where $\phi$ is of the form $\Diamond\phi'$. Note that $W(Op, \psi, \phi) = \Diamond W(Op, \psi, \phi')$. The claim is proved by

$$\Rightarrow \quad \vdash \Diamond W(Op, \psi, \phi')) \to \eta \qquad \text{(assumption)}$$
$$\Rightarrow \quad \vdash W(Op, \psi, \phi') \to \Box^{-1}\eta \qquad \text{(tense logic)}$$
$$\Rightarrow \quad \vdash \phi' \to \Box^{-1}\eta \qquad \text{(induction hypothesis)}$$
$$\Rightarrow \quad \vdash \Diamond\phi' \to \eta \qquad \text{(tense logic)}$$

and we are finished. $\square$

The following propositions form our version of Gabbay's generalized Irreflexivity Lemma (cf. [10]):

**Lemma 5.4** *(Extension Lemma)*
*Let $\Sigma$ be a consistent set in which the variable $p$ does not occur, and $\phi \in \Sigma$. Then $\Sigma \cup \{W(Op, \psi, \phi)\}$ is consistent for all $\psi \unlhd \phi$.*

**Proof.**
Suppose otherwise, then $\vdash W(Op, \psi, \phi) \to \neg\chi$ for some $\psi \unlhd \phi$ and $\chi = \chi_0 \wedge \ldots \wedge \chi_n$, all $\chi_i \in \Sigma$. By lemma 5.3 this would imply $\vdash \phi \to \neg\chi$, contradicting the consistency of $\Sigma$. $\square$

**Lemma 5.5** *If $\Sigma$ is a consistent set, then there is a distinguishing $\Sigma'$ containing $\Sigma$.*

**Proof.**
Let $Q$ be the set of propositional variables in $\Sigma$, assume that $Q$ is countable[^5] and let $p_0, p_1, \ldots$ be mutually distinct propositional variables not in $Q$; set, for $0 \le \xi \le \omega$, $Q_\xi = Q \cup \{p_i \mid i < \xi\}$.

[^5]: This restriction can easily be lifted.

For a set $\Delta$ of formulas in $Q_\omega$, let $PV(\Delta)$ be the set of propositional variables appearing in (formulas of) $\Delta$. A theory $\Delta$ is called an *approximation* if $\Delta$ is consistent, $\Sigma \subseteq \Delta$ and $PV(\Delta) = Q_n$ for some $n < \omega$. In this case $p_n$ is called the *new variable* for $\Delta$ and denoted by $p_\Delta$.

Now let $\Delta$ be an approximation and $(\phi, \psi)$ a *potential shortcoming*, i.e. $\phi$ is a formula in $Q_\omega$ and $\psi \unlhd \phi$. The pair $(\phi, \psi)$ is called a *shortcoming* of $\Delta$ if $\phi \in \Delta$ while no witness $W(Op, \psi, \phi)$ is in $\Delta$. Assume that we have an enumeration $\mathcal{W}$ of the set of potential shortcomings. If $\Delta$ has shortcomings, let $(\phi^\Delta, \psi^\Delta)$ be the first (in $\mathcal{W}$) of $\Delta$'s shortcomings. Now set

$$\Delta^+ = \begin{cases} \Delta & \text{if } \Delta \text{ has no shortcomings} \\ \Delta \cup \{W(Op_\Delta, \psi^\Delta, \phi^\Delta)\} & \text{otherwise} \end{cases}$$

We claim that if $\Delta$ is an approximation, then so is $\Delta^+$:
$\Delta^+$ is consistent by lemma 5.4; the other conditions are straightforward.

We now define the following sequence of theories $\Sigma_0, \Sigma_1, \ldots$; let $\phi_0, \phi_1, \ldots$ be an enumeration of all $Q_\omega$-formulas.

$$\Sigma_0 = \Sigma$$
$$\Sigma_{2n+1} = \begin{cases} \Sigma_{2n} \cup \{\phi_n\} & \text{if } \Sigma_{2n+1} \cup \{\phi_n\} \text{ is consistent} \\ \Sigma_{2n} \cup \{\neg\phi_n\} & \text{otherwise} \end{cases}$$
$$\Sigma_{2n+2} = \begin{cases} (\Sigma_{2n+1})^+ & \text{if } \Sigma_{2n+1} \text{ has shortcomings} \\ \Sigma_{2n+1} & \text{otherwise} \end{cases}$$

and set $\Sigma' = \bigcup_{n < \omega} \Sigma_n$.

It is then straightforward to prove that (1) $(\Sigma_n)_{n < \omega}$ is an increasing sequence, (2) every $\Sigma_n$ is an approximation, (3) for every $Q_\omega$-formula $\phi$, either $\phi$ or $\neg\phi$ is in $\Sigma'$, and (4) for every $Q_\omega$-formula $\phi$ and $\psi \unlhd \phi$, there is a witness $W(Op, \psi, \phi)$ in $\Sigma'$.

This gives all the desired properties of $\Sigma'$. $\square$

The fact that any consistent set is contained in a d-theory, means that in a certain sense there are *enough* distinguishing sets. Note however, that we needed to extend the language to prove lemma 5.5. This could mean that problems might arise if we want to show that every d-theory $\Gamma$ containing a formula $\Diamond\phi$ has a distinguishing $\Diamond$-successor $\Delta$ with $\phi \in \Delta$. For, in context of ordinary maximal consistent sets, this proposition is proved by showing that the set

$$\{\phi\} \cup \{\psi \mid \Box\psi \in \Gamma\}$$

has a maximal consistent extension. We might do the same here, but then we have to show that this set has a distinguishing extension *in the same proposition letters*. We choose a different proof, using the fact that because the language has the $O$-operator, the distinguishing theory $\Gamma$ contains a complete description of $\Delta$:

**Lemma 5.6** *If $\Gamma$ is a d-theory and $\Diamond\phi \in \Gamma$, then there is a d-theory $\Delta$ with $\phi \in \Delta$ and $R_\Diamond^c \Gamma \Delta$.*

**Proof.**
As $\Diamond\phi$ is in $\Gamma$, so is $\Diamond(\phi \wedge Op)$ for some atom $p$. Let $\Delta$ be the set $\{\psi \mid \Diamond(Op \wedge \psi) \in \Gamma\}$. $\Delta$ is consistent, for assume otherwise, then there are $\psi_1, \ldots, \psi_n$ in $\Delta$ with every $\Diamond(Op \wedge \psi_i)$ in $\Gamma$ and

$$\vdash (\bigwedge_i \psi_i) \to \bot$$

By lemma 4.4 we have

$$\vdash \bigwedge_i (\Diamond(Op \wedge \psi_i)) \to \Diamond(Op \wedge \bigwedge_i \psi_i)$$

So $\Diamond(Op \wedge \bigwedge_i \psi_i)$ and hence $\Diamond\bot$ is in $\Gamma$, contradicting its consistency.

As $\Diamond Op \in \Gamma$, for every $\psi$ either $\Diamond(Op \wedge \psi)$ or $\Diamond(Op \wedge \neg\psi)$ is in $\Gamma$, so clearly $\Delta$ is maximal. The fact that $R_\Diamond^c \Gamma \Delta$ is immediate by definition of $\Delta$.

To prove that $\Delta$ is distinguishing, let $\psi \in \Delta$, and $\chi \unlhd \psi$. We have to show that for some $q$, $W(Oq, \chi, \psi)$ is in $\Delta$:

By definition of $\Delta$, $\Diamond(Op \wedge \psi) \in \Gamma$. As $\Gamma$ is distinguishing, by definition there is a $q$ with $W(Oq, \chi, \Diamond(Op \wedge \psi))$ is in $\Gamma$, whence $W(Oq, \psi, \chi) \in \Delta$. $\square$

These two lemmas are sufficient to establish that there are *enough* d-theories. There is still one difference with the ordinary case which we need to discuss: suppose we would take the set of *all* distinguishing sets to form the universe of our canonical model. Then there would be *too many* worlds, for consider two $D$-theories $\Delta, \Delta'$ with $p \wedge \underline{D}\neg p \in \Delta$, $p \wedge \underline{D}p \in \Delta'$. If both were to be in our 'canonical' model, the underlying frame would be non-standard, for $\Delta'$ is not an $R_D$-successor of $\Delta$, while clearly $\Delta \ne \Delta'$. This inspires the following definition:

**Definition 5.7** *Two distinguishing theories $\Gamma$ and $\Delta$ are* connected, *notation: $\Gamma \sim_D \Delta$, if either $\Gamma = \Delta$ or $R_D^c \Gamma \Delta$. A set of d-theories is* connected *if all pairs of its members are.*

**Lemma 5.8** *$\sim_D$ is an equivalence relation.*

**Proof.**
Reflexivity of $\sim_D$ is immediate.
For symmetry, let $\Gamma \sim_D \Delta$. If $\Gamma = \Delta$, we are finished. If not, we have $R_D^c \Gamma \Delta$. Now $R_D^c$ is a symmetric relation (this is an immediate consequence of having the Sahlqvist axiom $D1$ in the logic). So we have $R_D^c \Delta \Gamma$, implying $\Delta \sim_D \Gamma$.
For transitivity of $\sim_D$, it suffices to show that $R_D^c$ is *pseudo-transitive*:

$$\forall x \forall y \forall z ((xRy \wedge yRz) \to (x = z \vee xRz))$$

But this is immediate by the fact that pseudo-transitivity is the Sahlqvist correspondent of axiom $D2$, and the completeness part of Sahlqvist's theorem. $\square$

**Definition 5.9** *A* d(istinguishing)-canonical frame *is of the form $\mathfrak{F}^d = (W^d, R_F^d, R_P^d, R_D^d)$ where $W^d$ is a connected set of distinguishing theories, and the $R^d$'s are the $R^c$'s restricted to $W^d$.*
*Define also* d-canonical models $\mathfrak{M}^d = (\mathfrak{F}^d, V^d)$ *and* d-canonical general frames $\mathfrak{G}^d = (\mathfrak{F}^d, A^d)$, *where $V^d$ is $V^c$ restricted to $W^d$ and $A$ is given by $X \in A^d$ iff $X = V^d(\phi)$ for some $\phi$.*

In the sequel we will have a particular d-canonical model, frame, etc. in mind, viz. the one consisting of all worlds connected to a fixed d-theory $\Sigma$. Therefore, we will frequently speak about *the* d-canonical model, frame, etc.

We need several nice properties of the d-canonical model. The easiest to establish is the truth lemma, via the fact that the d-canonical frame is a tense frame and standard:

**Lemma 5.10** *Let $\mathfrak{F}^d$ be a d-canonical frame, then*
**(i)** *$R_F^d$ and $R_P^d$ are each others converse.*
**(ii)** *$R_D^d$ is the inequality relation.*

**Proof.**
(i) is immediate by the fact that $\mathfrak{F}^d$ is a substructure of the canonical frame.
For (ii), the connectedness of $\mathfrak{F}^d$ implies that $\Gamma \ne \Delta \Rightarrow R_D^d \Gamma \Delta$. The fact that every d-theory contains a witness $p \wedge \underline{D}\neg p$ ensures that no element of $W^d$ is $R_D^d$-reflexive, so $R_D^d$ is contained in the inequality relation. $\square$

**Lemma 5.11** *(TRUTH LEMMA) For all d-canonical models $\mathfrak{M}^d$ and all $w \in \mathfrak{M}^d$:*

$$\mathfrak{M}^d, w \models \phi \quad \text{iff} \quad \phi \in w.$$

**Proof.**
By a formula induction, of which we only give the induction step for the modal operators.

First, let $\phi$ be of the form $F\psi$. By the truth definition, $\mathfrak{M}^d, w \models F\psi$ implies the existence of a $v$ with $R_D^d wv$ and $\mathfrak{F}^d, v \models \psi$. By the induction hypothesis, this gives $\psi \in v$, so by definition of $R_F^d$, $F\psi$ is in $w$. Conversely, by lemma 5.6 $F\psi \in w$ implies the existence of a distinguishing $v$ with $R_F^d wv$ and $\psi \in v$. By axiom $D3$, $R_F^d wv$ gives $R_D wv$ or $w = v$, so $v$ is a world of $\mathfrak{M}^d$. (Note that this is the only place in the proof where we need axiom $D3$.) The induction hypothesis yields that $\mathfrak{M}^d, v \models \psi$, so indeed we obtain $\mathfrak{M}^d, w \models F\psi$.

The proof for $\phi$ of the form $P\psi$ is exactly the same; for $\phi$ of the form $D\psi$ the above procedure gives $D\psi \in w$ iff there is a $v$ with $R_D^d wv$ and $\mathfrak{M}^d, v \models \psi$. This is sufficient, as $R_D$ is identical to the inequality relation by the previous lemma. $\square$

So it is left to prove that the underlying d-canonical frame is in $\mathsf{Fr}_\sigma$, or, equivalently, to show that $\mathfrak{F}^d, V \models \sigma$ for all valuations $V$. This is immediate by the following lemma and Theorem 3.5.

**Lemma 5.12** *Any d-canonical general frame is discrete.*

**Proof.**
Let $w$ be a d-theory or world in a d-canonical general frame $\mathfrak{G}^d = (\mathfrak{F}^d, A^d)$. Let $p$ be a propositional variable such that $Op \in w$, then by the truth lemma $w$ is the *only* d-theory of $\mathfrak{G}^d$ with $Op \in w$. So $\{w\} = V^d(Op) \in A^d$. $\square$

**Proof of theorem 5.1**
Soundness is immediate.
For completeness, suppose $\Sigma \nvdash \phi$, then $\Sigma \cup \{\neg\phi\}$ is consistent, so by lemma 5.5 there is a d-theory $\Sigma'$ with $\Sigma \cup \{\neg\phi\} \subseteq \Sigma'$. Let $\mathfrak{M}^d = (\mathfrak{F}^d, V^d)$ be the d-canonical model with $\Sigma' \in W^d$. By lemma 5.12 and Theorem 3.5, $\mathfrak{F}^d \models \sigma$ and by the truth lemma, $\mathfrak{M}^d, \Sigma \models \psi$ for all $\psi \in \Sigma \cup \{\neg\phi\}$.
So we obtained $\Sigma \not\models_{\mathsf{Fr}_\sigma^\ne} \phi$. $\square$

---

## 6 Uni-directional Complications

In this section, which is not needed for understanding the sequel, we will see where our proof fails for a similarity type $S$ which contains uni-directional diamonds. It suffices to take the case where we have only one diamond $F$ besides $D$. We would like to extend the results of the previous section to this case, but there seem to be two problems:

The first of these was already noted by Gabbay [8] and is also discussed in Gargov & Goranko [12]. The point is the following: in the previous section we saw that it is not sufficient to prove completeness by purging the canonical frame of $R_D$-reflexive points: their predecessors also need to be thrown out, and the predecessors of those, ad infinitum. In our 'constructive' approach this problem arises in the following way: it is not sufficient to show that $Op \wedge \phi$ is consistent if $\phi$ is so, we must also prove that $\phi_0 \wedge \Diamond_1(Op \wedge \phi_1)$ is all right if $\phi_0 \wedge \Diamond_1 \phi_1$ is, etc. In the tense-logical situation, we can do this by changing our 'perspective' on the formula, namely by moving the $\phi_1$-position to the top level: we look at $\phi_1 \wedge \Diamond_1^{-1}\phi_0$ (which is consistent iff $\phi_0 \wedge \Diamond_1 \phi_1$ is so), then we insert $Op$, obtaining $(Op \wedge \phi_1) \wedge \Diamond_1^{-1}\phi_0$. Returning to the old 'perspective' we see that indeed $\phi_0 \wedge \Diamond_1(\phi_1 \wedge Op)$ is consistent if $\phi_0 \wedge \Diamond_1 \phi_1$ is consistent. It will be clear that *tense operators* are indispensable instruments for this surgery.

We will now prove that it really goes wrong in the uni-directional case:

**Definition 6.1** *Assume that we have a uni-directional similarity type with two operators: $F$ and $D$.*
*Let $\rho$ be the formula $G(p \to Dp)$, $\rho'$ the formula $\rho \wedge F\top$.* $\square$

Note that $\rho$ is a Sahlqvist formula (cf. the footnote to definition 3.1), its equivalent $\rho^{s'}$ is $\forall x \forall y(Rxy \to R_D yy)$. So $\rho$ says: all $R$-successors are $R_D$-reflexive.

Now, recall that $K_F D^+\rho'$ is the axiom system with as axioms: $CT$, $DB$, the $D$-axioms and $\rho'$. Its derivation rules are $MP$, $UG$, $SUB$ and $IR_D$. If we had an analogon of theorem 5.1 for this logic, $K_F D^+\rho'$ should be inconsistent, for we have

**Lemma 6.2** $\mathsf{K}_{\rho'}^\ne = \emptyset$.

**Proof.**
It suffices to show that $\rho'$ cannot be valid in a standard frame. Assume $\mathfrak{F} \models \rho'$, where $\mathfrak{F} = (W, R, R_D)$ and $w$ is a world of $\mathfrak{F}$. By $\mathfrak{F}, w \models F\top$, $w$ has a successor $v$, by $\mathfrak{F} \models \rho^{s'}(w)$, $v$ is $R_D$-reflexive. But then $\mathfrak{F}$ is not standard. $\square$

But, $K_F D^+(\rho')$ is *not* inconsistent, as we can easily show by considering non-standard frames again:

**Lemma 6.3** $K_F D^+(\rho') \nvdash \bot$.

**Proof.**
Consider the following non-standard frame $\mathfrak{F} = (W, R, R_D)$:

$$W = \{w_n | n \in \omega\} \cup \{v\}$$
$$R = W \times \{v\}$$
$$R_D = \{(s,t) | s \ne t\} \cup \{(v, v)\},$$

and set $\Delta = \{\phi \mid \mathfrak{F}, w_0 \models \phi\}$. Clearly then $\bot \notin \Delta$. We show that $\Delta$ contains the axioms of $K_F D^+\rho'$ and is closed under its rules. For the axioms, this is fairly trivial: for instance, $\rho'$ is in $\Delta$ as $\mathfrak{F}, w_0 \models \forall y(Rxy \to R_D yy)$. Concerning the rules: $\Delta$ is closed under $IR_D$, as $w_0$ is $R_D$-irreflexive.

To show that $\Delta$ is closed under Universal Generalization, it suffices to prove that $\mathfrak{F}, w_0 \models \phi$ implies (1) $\mathfrak{F}, v \models \phi$ and (2) $\mathfrak{F}, w_n \models \phi$, for all $n$. The second claim is trivial by symmetry; for (1) we define a p-morphism $f : \mathfrak{F} \to \mathfrak{F}$ such that $f(w_0) = v$, and then we use the well-known p-morphism lemma giving $\mathfrak{F}, x \models \psi \Rightarrow \mathfrak{F}, fx \models \psi$. The map $f$ is given by

$$f(w_0) = v, f(w_{n+1}) = w_n \text{ and } f(v) = v.$$

It is left to the reader to check that $f$ is indeed a p-morphism. $\square$

This problem is not difficult to mend: a close inspection of the completeness proof in the previous section reveals that the essential property that we need to prove the extension lemma 5.4 and which tense logics automatically give us, is the following:

**Definition 6.4** *A derivation system $\Lambda$ has the* deep insertion property *iff*

$(DIP) \qquad \vdash W(Op, \psi, \phi) \to \eta \ \Rightarrow \ \vdash \phi \to \eta$
&emsp;&emsp;&emsp;&emsp;&emsp; *for all $\psi \unlhd \phi$ and $p$ not occurring in $\phi$ or $\eta$.*

The idea is now to extend the definition of the irreflexivity rule so as to obtain a logic in which the extension lemma holds again:

**Definition 6.5** *Define the following set of derivation rules:*

$(IR_D^*) \qquad \vdash \neg W(Op, \psi, \phi) \ \Rightarrow \ \vdash \neg\phi$
&emsp;&emsp;&emsp;&emsp;&emsp; *provided $\psi \unlhd \phi$ and $p \notin \phi$.*

**Lemma 6.6** *Let $\Lambda$ be a logic having $IR_D^*$. Then $\Lambda$ has DIP.*

**Proof.**
By the following chain of consequences (where we assume that $p$ does not occur in $\phi$ or in $\eta$):

$$\vdash W(Op, \psi, \phi) \to \eta \qquad \text{(assumption)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge W(Op, \psi, \phi)) \qquad \text{(proplog)}$$
$$\Rightarrow \quad \vdash \neg W(Op, \psi, \neg\eta \wedge \phi) \qquad \text{(evaluation of } W\text{)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge \phi) \qquad (IR_D^*)$$
$$\Rightarrow \quad \vdash \phi \to \eta \qquad \text{(proplog)} \qquad \dashv$$

So for a similarity type where not all diamonds have converses, it is necessary to have the rule $IR_D^*$ instead of $IR_D$. This was already noted by Gabbay [8] and by Gargov & Goranko [12], from which we derived the above example. It is not yet clear whether this extension is also *sufficient* to prove the analogon of the $SD$-theorem, at least if we want to consider axiom systems with *arbitrary* Sahlqvist axioms. For, there is another difference between the tense logical case and the unidirectional one.

This second problem seems to be more serious; assume that, analogous again to the previous section, we have constructed a d-canonical model $\mathfrak{M}^d$ for a MCS $\Sigma$. We want to prove $\mathfrak{F}^d \models \sigma$, where $\sigma$ is the Sahlqvist axiom added to the logic $K_S D^+$. In the tense logical case, we could do this, by using a special kind of valuations which we called *rudimentary*. We showed that for such a valuation $\mathfrak{F}^d, V \models \sigma$. This path however can only be taken if we have the converse diamond of $\mathfrak{F}$ in the language (cf. the proof of Lemma 3.12); in the uni-directional case, rudimentary valuations need not be *admissible*. It even turns out that the 'discrete persistency result' (Theorem 3.5) does not hold for arbitrary Sahlqvist formulas in a uni-directional similarity type:

**Lemma 6.7** *There is a Sahlqvist formula $\gamma$ and a discrete general frame $\mathfrak{G} = (\mathfrak{F}, A)$ such that $\mathfrak{G} \models \gamma$, $\mathfrak{F} \not\models \gamma$.*

**Proof.**
Let $\gamma$ be the formula $\sigma = FGp \to GFp$.
We have already met $\gamma$ in section 3; its first order equivalent is the *Church-Rosser* formula

$$\gamma^*(x) = \forall y \forall z(Rxy \wedge Rxz \to \exists t(Ryt \wedge Rzt)).$$

Consider the following (standard) frame $\mathfrak{F} = (W, R)$:
The set of possible worlds is given as $W = \{u, v, w, x\} \cup \{v_n, w_n \mid n \in \omega\}$. The accessibility relation $R$ holds as follows: $Ruv$, $Ruw$, $Rvv_n$ and $Rww_n$, all $n$, $Rv_n x$ and $Rw_n x$, all $n$, and $Rxx$.

Finally, we base a general frame $\mathfrak{G} = (\mathfrak{F}, A)$ on $\mathfrak{F}$, by defining $A$ as the set of finite and cofinite subsets of the universe $W$.

To check that $\mathfrak{G}$ is indeed a general frame, the key observation is that for any $X \subseteq W$, $m_F(X)$ is finite if $x \notin X$, cofinite if $x \in X$. In order to prove that $\mathfrak{G} \models \gamma$, it suffices to look at $w$. Suppose that for some admissible $V$, $FGp$ holds at $w$. Without loss of generality we may assume that $\mathfrak{F}, V, v \models Gp$, so $p$ holds at all $v_i$. Then $V(p)$ is not finite and hence co-finite. So there are (co-finitely many) $w_i$ with $\mathfrak{F}, V, w_i \models p$. But then $Fp$ holds at $w$ and thus $GFp$ at $u$.

It is easy to show that $\mathfrak{F} \not\models \gamma$, by considering the valuation $V(p) = \{v_n \mid n \in \omega\}$. Here $\mathfrak{F}, V, u \models FGp$ as $\mathfrak{F}, V, v \models Gp$, but $\mathfrak{F}, V, u \not\models GFp$, as $\mathfrak{F}, V, w \not\models Fp$. $\square$

Sahlqvist *tense* formulas however are still persistent for discrete general frames. Note that for a uni-directional similarity type, atoms are the only strongly positive formulas, so the set of St-formulas is rather small. Still, for this restricted set we do have a completeness theorem:

**Definition 6.8** *Let $S$ be an arbitrary similarity type of constants and diamonds. $K_S D^*$ is the basic $S$-logic extended with the set of rules $IR_D^*$.*

**Theorem 6.9** *Let $S$ be an arbitrary similarity type of constants and diamonds, and $\Sigma$ a set of Sahlqvist tense formulas. Then*

$$K_S D^*\Sigma \text{ is strongly sound and complete for } \mathsf{K}_\Sigma^\ne.$$

**Proof.**
An copy of the proof in section 5, using lemma 6.6 instead of lemma 5.4. $\square$

We conjecture that for any *individual* set of Sahlqvist axioms, the completeness like in Theorem 6.9 can be shown to hold, but we are doubtful whether there is a uniform proof (analogous to that of Theorem 5.1) taking care of all Sahlqvist axiomatizations at once. On the other hand, Goranko [17] announces a general *weak completeness proof*, for arbitrary canonical formulas.

---

## 7 The SD-theorem

There are some problems involved, mainly of a technical nature, in extending the completeness proof of the SD-theorem to languages having dyadic operators. Note that recently, dyadic modal operators have received some attention in e.g. van Benthem [4], Roorda [30] and Venema [38, 39].

First of all we have to make clear what we mean by a Sahlqvist (tense) formula in a dyadic language. In fact, the definitions and results of section 3 already apply to arbitrary similarity types. The following point is worth some discussion, however: in a similarity type with only diamonds and constants, we allow boxed atoms in the strongly positive formulas. A naive approach to define Sahlqvist triangle formulas would then be to allow duals of dyadic operators too. But de Rijke showed that the formula

$$(p \triangle p) \triangle p \to (p \triangle p) \triangle p$$

is *not acceptable* as a Sahlqvist formula, as it does not have a first order equivalent on the frame level. So for triangle similarity types, the atoms and negative formulas are the only admissible building blocks of Sahlqvist antecedents. This implies that for arbitrary similarity types, the difference between Sahlqvist *tense* formulas and ordinary Sahlqvist formulas is caused by the nature of the *diamonds* alone.

However, we saw in the previous section that there were two reasons to prefer tense similarity types above uni-directional ones: besides a larger set of axioms for which our procedure works, there is also the advantage of a simple, transparent formulation of the non-$\xi$ derivation rules. This second aspect is the same for similarity types having polyadic modal operators, so we have to generalize the concept of 'tense' to an arbitrary similarity type. Hereto we introduce the following notion:

**Definition 7.1** *A* versatile *similarity type is a modal similarity type $S = (O, \rho)$ where the set $O$ of operators is given as a (disjoint) union of sets, $O = \bigcup_{j \in J} O_j$, such that $O_j = \{\nabla_{j0}, \ldots, \nabla_{j,n_j}\}$ and all operators in $O_j$ have the same rank $n_j - 1$.*
*A versatile frame for such an $S$ is an $S$-frame $(W, I)$ where for all $j \in J$, $i \le n_j$ one has*

$$I(\nabla_{j_1}) = \{(w_0, w_1, \ldots, w_{n_j}) \mid (w_1, \ldots, w_{n_j}, w_0) \in I(\nabla_{j,i+1})\}$$

*For a class $\mathsf{K}$ of $S$-frames, we let $\mathsf{K}^v$ denote the class of versatile frames in $\mathsf{K}$.*

We do not exclude the possibility that $O_j = \{\nabla, \ldots, \nabla\}$, i.e. all operators are identical. Note that the notion 'tense' only applies to diamonds: in a tense similarity type $S$ there is no constraint on the operators of rank $> 2$. Only if all operators of $S$ are constants or diamonds, do the concepts of 'tense' and 'versatility' coincide, and do we have $\mathsf{K}^t = \mathsf{K}^v$.

The analogy with the monadic case is the following: if we consider a language and semantics which are not versatile, one irreflexivity rule is not sufficient, but we have to add infinitely many rules, allowing the building in of witnesses at all depths in a formula. To avoid these technical complications, we have to get familiar with the versatile *logic* of polyadic operators.

Let us for the moment consider a similarity type consisting of three dyadic operators $\triangle_0$, $\triangle_1$ and $\triangle_2$. Frames for this similarity type have the form $\mathfrak{F} = (W, R_0, R_1, R_2)$, where $R_i$ is the ternary accessibility relation of $\triangle_i$. Recall that the truth definition of a dyadic operator gives

$$u \models \phi \ \triangle_i \ \psi \iff \text{there are } v, w \text{ with } R_i uvw, \ v \models \phi \text{ and } w \models \psi.$$

In the intended *versatile* semantics, the three $R_i$'s are 'directions' of one ternary relation $R$; as a standard we take $R = R_0$. A frame $\mathfrak{F} = (W, R_0, R_1, R_2)$ is a *versatile* frame if it satisfies the following conditions, for $i = 0, 1, 2$ (we write $2 + 1 = 0$):

$(Qi) \qquad \forall u, v, w \ (R_i uvw \to R_{i+1} vwu)$

Analogous to the monadic case, the class $\mathsf{Fr}^v$ of versatile frames can be quite easily characterized and axiomatized:

**Definition 7.2** *Define the following formulas, for $i = 0, 1, 2$:*

$(Vi) \qquad \big(p \wedge \neg(r \ \triangle_{i+1} \ p) \ \triangle_i \ r\big) \to \bot,$

*and set $V \equiv V1 \wedge V2 \wedge V3$.*
*Let $K_S^v$ be the versatile $S$-logic, i.e. the minimal $S$-logic $K_S$ extended with the axiom $V$.*

Note that $Vi$ is a Sahlqvist formula: $p$ is strongly positive, $\neg(r \ \triangle_{i+1} \ p)$ is negative and $r$ is again strongly positive, so $p \wedge \neg(r \ \triangle_{i+1} \ p) \ \triangle_i \ r$ is untied, and as $\bot$ is positive, we are finished.

This means that we immediately have the following:

**Lemma 7.3** *For $i = 0, 1, 2$: $\mathfrak{F} \models Qi \iff \mathfrak{F} \models Vi$.*

**Proof.**
The proposition is immediate by the Sahlqvist theorem, but we give a direct proof (taking $i = 0$):
($\Rightarrow$) Suppose that for some model $\mathfrak{M}$ on $\mathfrak{F}$, $\mathfrak{M}, u \models p \wedge \neg(r \ \triangle_1 \ p) \ \triangle_0 \ r$. By the truth definition of $\triangle_0$, there are $v, w$ with $R_0 uvw$, $v \models \neg(r \ \triangle_1 \ p)$, $w \models r$, while $u \models p$. $\mathfrak{F} \models Q0$ implies $R_1 vwu$, so by the truth definition of $\triangle_1$ we get $v \models r \ \triangle_1 \ p$ and find the desired contradiction.
($\Leftarrow$) Let $(u, v, w)$ be in $R_0$. We want to show $(v, w, u) \in R_1$. Suppose otherwise and consider a valuation $V$ with $V(p) = \{u\}$, $V(r) = \{w\}$. Then $v \models \neg(r \ \triangle_1 \ p)$, so $u \models \neg(r \ \triangle_1 \ p) \ \triangle_0 \ r$. By $\mathfrak{F} \models V_1$ we then have $u \models \neg p$, contradicting $V(p) = \{u\}$. $\square$

**Theorem 7.4** *$K_S^v$ is strongly sound and complete with respect to the versatile $S$-frames.*

**Proof.**
Immediate by the fact that the axioms are Sahlqvist formulas and lemma 7.3. $\square$

**Lemma 7.5** *The following deduction rule is a derived rule of $K_S^v$:*

$$\vdash \neg(\phi \wedge \psi \ \triangle_i \ \chi) \iff \vdash \neg(\psi \wedge \chi \ \triangle_{i+1} \ \phi).$$

**Proof.**
By the observation that the rule is *sound* in the class of $S$-versatile frames. $\square$

Note that intuitively, $\mathfrak{M} \models \neg(p \wedge q \ \triangle_i \ r)$ denotes the impossibility of a triple $(u, v, w)$ in $R$ with $u \models p$, $v \models q$ and $w \models r$.
We can easily generalize this idea to operators of rank $\ne 2$. For example, for the monadic case we have

$$\vdash \neg(p \wedge \Diamond q) \iff \vdash \neg(q \wedge \Diamond^{-1}p)$$

as a derived rule of the minimal tense logic.

Now we are ready to add monadic tense operators, including the $D$-operator, to the language.

**Definition 7.6** *Let $S$ be a versatile similarity type having constants, monadic tense operators $\{\Diamond_i, \Diamond_i^{-1} \mid i < \alpha\}$ and dyadic operators $\{\triangle_0^j, \triangle_1^j, \triangle_2^j \mid j < \beta\}$.*
*The versatile $S$-logic $K_S^v$ is defined as the extension of the minimal $S$-logic $K_S$ with the tense axiom $CV$ for every diamond pair, and the versatility axiom $V$ for every triple of triangles.*

**Theorem 7.7** *SD-THEOREM*
*Let $S$ be a versatile similarity type containing $D$ and $\Sigma$ a set of Sahlqvist formulas. Then*

$$K_S^v D^+\Sigma \text{ is strongly sound and complete for } \mathsf{K}_\Sigma^{v,\ne}.$$

**Proof.**
For notational simplicity, we assume that $S = \{D, F, P, \triangle_0, \triangle_1, \triangle_2\}$ and that $\Sigma$ is a singleton $\{\sigma\}$. From now on we abbreviate the logic $K_S^t D^+\sigma$ by $\Lambda$. The proof is essentially the same as in section 5, so we only give the following details.

The definition of $W(\chi, \psi, \phi)$ is extended with a clause for dyadic operators:

$$W(\chi, \psi, \phi \ \triangle \ \phi') = W(\chi, \psi, \phi) \ \triangle \ W(\chi, \psi, \phi')$$

We show that for all $\psi \unlhd \phi$ and $q$ not occurring in $\phi$ or $\eta$, we have $\vdash W(Oq, \psi, \phi) \to \eta$ implies $\vdash \phi \to \eta$; consider the case in the induction step where $\phi = \phi_0 \ \triangle_0 \ \phi_1$ and $\psi \unlhd \phi_0$. Then $W(Oq, \psi, \phi) = W(Oq, \psi, \phi_0) \ \triangle_0 \ \phi_1$ and we get

$$\vdash W(Oq, \psi, \phi_0) \ \triangle_0 \ \phi_1 \to \eta \qquad \text{(assumption)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge W(Oq, \psi, \phi_0) \ \triangle_0 \ \phi_1) \qquad \text{(propositional logic)}$$
$$\Rightarrow \quad \vdash \neg(W(Oq, \psi, \phi_0) \wedge \phi_1 \ \triangle_1 \ \neg\eta) \qquad \text{(Lemma 7.5)}$$
$$\Rightarrow \quad \vdash \neg(\phi_0 \wedge \phi_1 \ \triangle_1 \ \neg\eta) \qquad \text{(Induction Hypothesis)}$$
$$\Rightarrow \quad \vdash \neg(\neg\eta \wedge \phi_0 \ \triangle_0 \ \phi_1) \qquad \text{(Lemma 7.5)}$$
$$\Rightarrow \quad \vdash \phi \to \eta \qquad \text{(propositional logic)}$$

This ensures that we can prove the analogon of lemma 5.4.

To show the same for lemma 5.5, we prove the following: if $\Gamma$ is distinguishing and $\phi \ \triangle \ \pi \in \Gamma$, then there are d-theories $\Phi$ and $\Pi$ with $\phi \in \Phi$, $\pi \in \Pi$ and $R_\triangle^c \Gamma \Phi \Pi$. For, as $\phi \ \triangle \ \pi$ is in $\Gamma$, we have $(\phi \wedge Of) \ \triangle \ (\pi \wedge Op)$ in $\Gamma$ for some propositional variables $f$ and $p$. We set

$$\Phi = \{\alpha \mid (\alpha \wedge Of) \ \triangle \ Op \in \Gamma\}$$
$$\Pi = \{\psi \mid Of \ \triangle \ (\psi \wedge Op) \in \Gamma\},$$

and the proof that these $\Phi$ and $\Pi$ have the desired properties, runs like in lemma 5.5.

The remainder of the proof is a copy of that in section 5. $\square$

---

## 8 The $SN\Xi$-theorem

We are now ready to prove our main completeness theorem for a versatile logic having other non-$\xi$ rules besides $IR_D$.

**Definition 8.1** *Let $S$ be a versatile similarity type containing the $D$-operator, $\Sigma$ a set of Sahlqvist formulas and $\Xi$ a set of arbitrary formulas. $K_S^v D^+(\Sigma, -\Xi)$ is the logic $K_S^v D^+$ extended with the axioms $\Sigma$ and the non-$\xi$ rules for all $\xi \in \Xi$.*

Recall that the above definition implies that the *rules* of $K_S^v D^+(\Sigma, -\Xi)$ are $MP$, $UG$, $SUB$, $IR_D$ and $\{N\xi R \mid \xi \in \Xi\}$. If the similarity type contains only constants and diamonds, then the system has the following *axioms*:

- $(CT)$ &emsp; all classical tautologies
- $(DB)$ &emsp; $\Box(p \to q) \to (\Box p \to \Box q)$
- $(CV)$ &emsp; $p \to \Box\Diamond^{-1}p$
- $(D1)$ &emsp; $p \to \underline{D}Dp$
- $(D2)$ &emsp; $DDp \to (p \vee Dp)$
- $(D3)$ &emsp; $\Diamond p \to p \vee Dp$
- $(\Sigma)$ &emsp; $\Sigma$

If there are also triangles around, then the system has the versatility axiom $V$ too (cf. 7.2).

With respect to the semantics, note that the class $\mathsf{Fr}_{(\Sigma, -\Xi)}^{v,\ne}$ is defined as the class of $D$-standard versatile $S$-frames with

$$\mathfrak{F} \models \sigma \qquad \text{for all } \sigma \text{ in } \Sigma$$
$$\mathfrak{F}, w \not\models \xi \qquad \text{for all } w \text{ in } \mathfrak{F}, \ \xi \text{ in } \Xi$$

If every $\xi$ has a local first order equivalent $\xi^f(x)$ on the frame level (for example, if all $\xi$'s are Sahlqvist formulas too), then $\mathsf{Fr}_{(\Sigma, -\Xi)}^{v,\ne}$ is elementary, as we have

$$\mathfrak{F} \text{ in } \mathsf{Fr}_{-\xi} \iff \mathfrak{F} \models \forall x \neg\xi^f(x).$$

So, the theory below takes care of many classes of frames, for example the asymmetric or intransitive frames (cf. the characterizations given in the introduction).

**Theorem 8.2** *(SN$\Xi$-THEOREM)*
*Let $S$, $\Sigma$ and $\Xi$ be as in definition 8.1. Then*

$$K_S^v D^+(\Sigma, -\Xi) \text{ is strongly sound and complete for } \mathsf{Fr}_{(\Sigma, -\Xi)}^{v,\ne}.$$

**Proof.**
We can use a straightforward adaptation of the proof in the previous section. There we started with a consistent $\Delta$ and inserted in $\Delta$, for every $\phi \in \Delta$ and $\psi \unlhd \phi$, a formula $W(Op, \psi, \phi)$, in order to witness the $R_D$-irreflexivity of all worlds connected to $\Delta$. Here we will add more formulas (of the form $W(\neg\xi(p_1, \ldots, p_n), \psi, \phi)$)), this time in order to ensure that the canonical-like general frame we end with is not only standard (with respect to $R_D$), but also in $\mathsf{Fr}_{-\Xi}$.

So we call a set $\Delta$ of $S$-formulas *witnessing (against $\Xi$)* if it is distinguishing and for all formulas $\phi \in \Delta$, $\psi \unlhd \phi$ and $\xi \in \Xi$, there are propositional variables $p_1, \ldots, p_n$ with $W(\neg\xi(p_1, \ldots, p_n), \psi, \phi) \in \Delta$.

*W(itnessing)-canonical frames, models*, etc. are defined analogous to distinguishing ones.

Now for completeness, we consider a consistent set $\Delta$, extend it to a witnessing set $\Delta'$, and we construct the witnessing canonical model $\mathfrak{M}$ of which $\Delta'$ is a world. By the truth lemma, every formula in $\Delta'$ is true at $\Delta'$. By an argument like in the previous section, the underlying witnessing canonical frame $\mathfrak{F}$ is versatile, $D$-standard, and it validates the axioms $\Sigma$. By the truth lemma and the fact that every MCS of $\mathfrak{M}$ contains a formula $W(\neg\xi(p_1, \ldots, p_n), \psi, \phi)$, we see that $\mathfrak{F}$ is in $\mathsf{Fr}_{-\Xi}$. This proves the theorem. $\square$

Just like in section 6, we can prove a poorer version of Theorem 8.2 for arbitrary (not versatile) similarity types, but we leave this to the reader.

---

## 9 Conclusions, Remarks and Questions

### 9.1 General Conclusions

This paper was a study in the semantics and (mainly) the axiomatics of non-$\xi$ rules, styled after Gabbay's Irreflexivity Rule.

On the semantic side, we defined $\mathsf{K}_{-\Xi}$ as the class of frames $\mathfrak{F}$ in $\mathsf{K}$ where no $\xi \in \Xi$ holds anywhere, i.e. for no $\xi \in \Xi$ there is a $w$ in $\mathfrak{F}$ with $\mathfrak{F}, w \models \xi$. In general, such a class will not be *definable* by a modal formula. Natural examples are formed by the irreflexive, asymmetric or transitive frames; the phenomenon is abundant in many-dimensional modal logic, and thus, in algebraic logic, cf. Venema [42].

The main result of this paper, the $SN\Xi$-theorem 8.2 states that under certain conditions, classes of the form $\mathsf{K}_{-\Xi}$ are *axiomatizable*, by a derivation system having a non-$\xi$ rule for every $\xi \in \Xi$. In the various sections of this paper we have discussed these conditions.

The most elegant formulation of the $SN\Xi$-theorem is in the case where the similarity type is *versatile* and contains the $D$-operator. For such a similarity type, our result gives a nice derivation system for every class $\mathsf{K}_{-\Xi}$ where $\mathsf{K}$ is a class of $D$-standard, versatile frames which is positively characterized by a set of *Sahlqvist axioms*. For poorer similarity types, there are various options, of which we list a few:

1. If the similarity type is not versatile, we have to add a *schema* of non-$\xi$ rules (cf. section 6).
2. If not all diamonds are tense, only *Sahlqvist tense* formulas are allowed as axioms (cf. sections 6 and 7).
3. If the similarity type $S$ does not contain the $D$-operator, the theorem does not apply directly.

Fortunately, this does not mean that the full power of the $SN\Xi$-theorem is lost for these poorer similarity types; one only has to work a bit harder for it. To give an example: in many cases, over the class $\mathsf{K}_{-\Xi}$ we can *define* the $D$-operator in the poorer formalism, so that we can work with this defined $D'$-operator. Examples of this idea can be found in Venema [43, 42].

So, rather than a theorem, the $SN\Xi$-concept is a *procedure* to find axiomatizations for non-$\xi$ classes:

1. Find the proper characterization of the class (maybe in an extended similarity type).
2. Apply the $SN\Xi$-theorem, immediately obtaining a strongly sound and complete derivation system.
3. Try to simplify this system.

It would be unfair not to mention the fact that axiomatizations using non-$\xi$ rules have some *disadvantages* too: first of all, such axiomatizations may not have all the nice mathematical properties that orthodox axiomatizations have. For example (cf. Goldblatt [15]): define, for a logic $\Lambda$, the corresponding algebraic variety $\mathsf{V}_\Lambda$ of Boolean Algebras with Operators as the class of algebras where the set of equations $\{\phi = 1 \mid \Lambda \vdash \phi\}$ is valid. Now for a finite *orthodox* $\Lambda$, the complement of $\mathsf{V}_\Lambda$ will be closed under ultraproducts, while this need not be the case for an unorthodox $\Lambda$.

Second, by the nature of the derivation rule, it may be necessary to add new propositional variables to the language in order to derive a formula $\phi$, whence we have *less control* on derivations in these unorthodox systems.

These disadvantages take us to the question, in which cases a non-$\xi$ rule can be *eliminated* from a system.

### 9.2 Conservativity

An interesting point which has not been discussed yet concerns the question whether non-$\xi$ rules add new theorems to a logic. Some scattered results are known:
In the introduction we saw an example where a rule is *admissible*: the logic $K^t 4$ already axiomatizes the class of irreflexive transitive tense frames, so adding $IR$ does not produce any new theorem.

On the other hand, adding $IR$ to $K^t L(Gp \to p)$ makes this logic inconsistent, so here $IR$ is not conservative. In Zanardo [46], Zanardo replaced the irreflexivity rule used in Burgess [6] to axiomatize a branching-time temporal logic, by (infinitely many) axioms. An similar case is found in cylindric modal logic and the modal logic of relation algebras (cf. Venema [42, 43]), where adding a non-$\xi$ rule to a finite set of axioms creates a finite derivation system for a logic which is known not to be finitely axiomatizable when only the orthodox derivation rules $MP$, $UG$ and $SUB$ are allowed. A striking difference between a uni-directional similarity type and its tense counterpart concerns the modal logic of the two-dimensional 'domino relation', where an axiomatization of the uni-directional modal logic needs *both* infinitely many axioms *and* a non-$\xi$ rule (cf. Kuhn [22]), while the tense logic allows a finite and orthodox axiomatization (cf. Venema [41]).

The general question

> Are there natural criteria deciding when a non-$\xi$ rule is admissible over a derivation system?

lies (almost) completely open. We have one minor result: recall that a formula is *closed* if it does not contain propositional variables (only constants).

**Definition 9.1** *A logic $\Lambda$ has the* interpolation property $(IP)$ *if $\Lambda \vdash \phi \to \psi$ implies the existence of an interpolant $\chi$ in the common language of $\phi$ and $\psi$, such that $\Lambda \vdash \phi \to \chi$ and $\Lambda \vdash \chi \to \psi$.*

**Lemma 9.2** *Let $\Lambda$ be a logic and $\xi$ a formula, such that (i) $\Lambda$ has the IP, and (ii) for every closed formula $\gamma$, $\Lambda(-\xi) \vdash \gamma$ implies $\Lambda \vdash \gamma$.*
*Then $N\xi R$ is conservative over $\Lambda$.*

**Proof.**
Assume that $\Lambda$ and $\xi$ satisfy (i) and (ii). Denote derivability in $\Lambda$ by $\vdash$. To show that $N\xi R$ is conservative over $\Lambda$, we must prove

$$\vdash \neg\xi(\vec{p}) \to \phi \ \Rightarrow \ \vdash \phi, \text{ if no } p_i \text{ occurs in } \phi$$

So assume $\vdash \neg\xi(\vec{p}) \to \phi$ where $\vec{p} \notin \phi$. By (i) there is an interpolant $\gamma$ for $\neg\xi(\vec{p})$ and $\phi$; $\gamma$ must be closed, as $\neg\xi(\vec{p})$ and $\phi$ do not share any variables.
As $\vdash \neg\xi(\vec{p}) \to \gamma$, one application of $N\xi R$ shows that $\gamma$ is a $\Lambda(-\xi)$-theorem, so by (ii), $\vdash \gamma$. Now $\vdash \phi$ is immediate by $\vdash \gamma \to \phi$. $\square$

### 9.3 Questions and Remarks

We end this paper with some miscellaneous questions and remarks:

1. The most obvious question is whether the $SN\Xi$-result can be extended to similarity types not having the $D$-operator or tense diamonds, and to arbitrary canonical formulas. Independently from our result, Goranko [17] announces a similar meta-theorem on *weak* completeness, for arbitrary canonical formulas. Hodkinson [10] extends our result to a similarity type where diamonds come in pairs too, here having *complementary* accessibility relations ($R_{-\Diamond} = (R_\Diamond)^c$).

2. Call a class *negatively definable* if it is of the form $\mathsf{Fr}_{-\Xi}$. There seems to be an interesting connection between this notion and what Kracht calls *describable properties*, cf. [21]. Is there a *structural characterization* for negatively definable classes, like there is for modally definable classes? It is not difficult to see that negatively definable classes are closed under disjoint unions and generated subframes; any $\mathsf{Fr}_{-\Xi}$ *reflects* p-morphic images, and if it is elementary, ultrafilter extensions too. Do these preservation properties give the desired characterization for (elementary) negatively definable classes?

3. Let $\Lambda$ be the set of formulas $\Theta(\mathsf{Fr}_{(\Sigma, -\Xi)})$, and $\mathsf{Fr}_\Lambda$ the class of frames where $\Lambda$ is valid. What is the relation between $\mathsf{Fr}_{(\Sigma, -\Xi)}$ and $\mathsf{Fr}_\Lambda$? Note that for $\Sigma = \emptyset$ and $\Xi$ only containing a formula characterizing irreflexivity, we have that $\mathsf{Fr}_\Lambda$ is the class of p-morphic images of $\mathsf{Fr}_{(\Sigma, -\Xi)}$.

4. Consider the tense similarity type with diamonds $\{F, P, D\}$. To axiomatize the irreflexive frames, we now have the choice between the $F$-irreflexivity *rule* and the *axiom* $Fp \to Dp$. When and how can rules be replaced by axioms, and vice versa?

5. An interesting aspect of non-$\xi$ rules is that in some sense they behave like axioms; in the introduction we already saw how they *characterize* the class $\mathsf{K}_{-\xi}$ as the class of frames where $N\xi R$ is *sound*.

   Maybe it is better to use the term *anti-axioms*[^6], however, according to their behaviour in derivation systems: in a logic having a rule $N\xi R$, we strongly want to *avoid* $\xi$ as a theorem; it would go to far to add the negation of $\xi$ as a theorem (for instance, an irreflexive frame can have a reflexive p-morphic image), but a formula $\phi$ that provably implies $\xi$ (under the usual restriction concerning the variables), is so 'bad' that we accept $\neg\phi$ as a theorem.

   In this 'rules as anti-axioms perspective', it might be interesting to investigate non-$\xi$ rules as operators in the lattice of modal (tense) logics.

[^6]: This explains our notation '$-\xi$'

---

## References

[1] H. Andreka, I. Nemeti and I. Sain, "On the strength of temporal proofs", *Theoretical Computer Science* **80** (1991) 125--151.

[2] J.F.A.K. van Benthem, "Correspondence theory", in: [9], 167--247.

[3] J.F.A.K. van Benthem, *Modal Logic and Classical Logic*, Bibliopolis, Naples, 1985.

[4] J.F.A.K. van Benthem, *Language in Action*, North-Holland, Amsterdam, 1991.

[5] P. Blackburn, *Nominal Tense Logic*, PhD Dissertation, University of Edinburgh, Edinburgh, 1989.

[6] J.P. Burgess, "Decidability for branching time", *Studia Logica*, **39** (1980), 203-218.

[7] J. Crossley (ed.), *Algebra and Logic*, Lecture Notes in Mathematics **450**, Springer, Berlin, 1975.

[8] D.M. Gabbay, "An irreflexivity lemma with applications to axiomatizations of conditions on linear frames", in: [24], pp. 67--89

[9] D.M. Gabbay and F. Guenthner, (eds.), *Handbook of Philosophical Logic, vol II*, Reidel, Dordrecht, 1984.

[10] D.M. Gabbay, in collaboration with I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and Computational Aspects*, Oxford University Press, Oxford, 1992, to be published.

[11] D.M. Gabbay and I.M. Hodkinson, "An axiomatization of the temporal logic with Since and Until over the real numbers", *Journal of Logic and Computation* **1** (1990) 229--259.

[12] G. Gargov and V. Goranko, "Modal logic with names", in: [29], 81--103.

[13] G. Gargov, S. Passy and T. Tinchev, "Modal environment for boolean speculations", in: [36], 253--263.

[14] R. Goldblatt, "Metamathematics of modal logic", *Reports on Mathematical Logic*, **6** (1976) 41--77, **7** (1976) 21--52.

[15] R. Goldblatt, "Varieties of complex algebras", *Annals of Pure and Applied Logic*, **44** (1989) 173--242.

[16] R. Goldblatt and S. Thomason, "Axiomatic classes in propositional modal logic", in [7], 163--173.

[17] V. Goranko, "Applications of quasi-structural rules to axiomatizations in modal logic" (abstract), in: [23], p. 119.

[18] B. Jonsson and Alfred Tarski, "Boolean algebras with operators", *American Journal of Mathematics*, **73** (1951) 891--939, **74** (1952) 127--162.

[19] S. Kanger (ed.), *Proc. of the Third Scandinavian Logic Symposium Uppsala 1973*, North-Holland, Amsterdam, 1975.

[20] R. Koymans, *Specifying Message Passing and Time-Critical Systems with Temporal Logic*, PhD Dissertation, Eindhoven University of Technology, 1989.

[21] M. Kracht, "How completeness and correspondence theory got married", in [29], 161--185.

[22] S. Kuhn, "The domino relation: flattening a two-dimensional logic", *Journal of Philosophical Logic*, **18** (1989) 173--195.

[23] Logic Colloquium '91, *Abstracts of the 9th International Congress of Logic, Methodology and Philosophy of Sciences, Uppsala, 1991*, Volume I: Logic.

[24] U. Monnich (ed.), *Aspects of Philosophical Logic*, Reidel, Dordrecht, 1981.

[25] I. Nemeti, "Algebraizations of quantifier logics: an introductory overview", *Studia Logica*, **50** (1991) 485--570.

[26] S. Passy and T. Tinchev, "PDL with Data Constants", *Information Processing Letters*, **20** (1985) 35--41.

[27] M. Reynolds, *Complete Axiomatization for Until and Since over the Reals --- IRR Rule Not Needed*, *Studia Logica*, **51** (1992) 165--194.

[28] M. de Rijke, *The Modal Logic of Inequality*, *Journal of Symbolic Logic*, **57** (1992) 566--584.

[29] M. de Rijke (ed.), *Colloquium on Modal Logic 1991*, Dutch Network for Language, Logic and Information, Amsterdam, 1991.

[30] D. Roorda, *Resource Logics: Proof-theoretical Investigations*, PhD Dissertation, University of Amsterdam, 1991.

[31] H. Sahlqvist, "Completeness and correspondence in the first and second order semantics for modal logic", in: [19], pp. 110--143.

[32] I. Sain, *Successor Axioms Increase the Program Verification Powers of the "Sometime + Next-time" Logic*, Preprint No. **23** (1983), Mathematical Institute of the Hungarian Academy of Sciences, Budapest.

[33] I. Sain, "Is 'Some-Other-Time' sometimes better than 'Sometime' for proving partial correctness of programs?" *Studia Logica*, **47** (1988) 279--301.

[34] I. Sain, "Temporal logics need their clocks", *Theoretical Computer Science*, **95** (1992), 75--96.

[35] G. Sambin and V. Vaccaro, "A new proof of Sahlqvist's theorem on modal definability and completeness", *Journal of Symbolic Logic*, **54** (1989) 992--999.

[36] D. Skordev (ed.), *Mathematical Logic and its Applications*, Plenum Press, New York, 1987.

[37] Y. Venema, "Expressivenes and completeness of an interval tense logic", *Notre Dame Journal of Formal Logic*, **31** (1990) 529--547.

[38] Y. Venema, *Two-dimensional Modal Logics for Relation Algebras and Temporal Logic of Intervals*, ITLI-prepublication series LP-89-03, University of Amsterdam, Amsterdam, 1989.

[39] Y. Venema, "A modal logic for chopping intervals", *Journal of Logic and Computation*, **1** (1991) 453--476.

[40] Y. Venema, "Completeness by completeness: Since and Until", in: [29], 279--285.

[41] Y. Venema, "The tense logic of dominoes", *Journal of Philosophical Logic*, **21** (1992) 173--182.

[42] Y. Venema, "Many-dimensional modal logic", doctoral dissertation, University of Amsterdam, 1991.

[43] Y. Venema, *Cylindric Modal Logic*, 1992, manuscript, submitted.

[44] A. Zanardo, "A finite axiomatization of the set of strongly valid Ockhamist formulas", *Journal of Philosophical Logic*, **14** (1985), 447--468.

[45] A. Zanardo, "A complete deductive system for Since-Until branching-time logic", *Journal of Philosophical Logic*, **20** (1991), 131--148.

[46] A. Zanardo, "Axiomatization of 'Peircean' branching-time logic", *Studia Logica*, **49** (1990) 183--196.
