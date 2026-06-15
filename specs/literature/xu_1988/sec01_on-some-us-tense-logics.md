# On Some $U,S$-Tense Logics

**Ming Xu**

*Journal of Philosophical Logic* **17** (1988) 181--202.

---

## 1. Introduction

In his thesis [1], John P. Burgess presented a series of $U,S$-tense logics for the case of linear time. The aims of this paper are (i) to show how the methods of proving completeness for $U,S$-tense logics developed in [1] could be applied to the general case of (possibly) non-linear time; and (ii) to present some results concerning the expressibility of $U,S$-tense language.

To achieve (i), we will first show in Section 2 that the minimal $U,S$-tense logic does exist, and then show in Section 3 how to establish logics for "branching time", such as the logics for the classes of all transitive frames and of all transitive and left-connected frames.

At the end of Section 2, we will show sketchily that every $U,S$-tense logic is complete for the class of all its "models" as well as for the class of all its "general frames".

The reader may be familiar with the fact that the expressibility of $U,S$-tense language is stronger than that of ordinary $G,H$-tense language. But in fact, it is not strong enough to yield any $U,S$-tense formula corresponding to first-order conditions such as irreflexiveness, asymmetry and antisymmetry -- all three of which are of interest to logicians working on tense logic. The stronger expressibility of $U,S$-tense language does give us some formulas corresponding to certain first-order conditions to each of which no $G,H$-tense formula can correspond, as will be shown in Sections 3 and 4. But it also makes it easy to find incomplete tense logics, as will be shown in Section 4.

We begin with the following preliminaries.

$U,S$-tense formulas (briefly, formulas) are constructed from propositional variables $p, q, r, s, \ldots$, using connectives $\neg$ (negation) and $\to$ (material implication), and binary tense operators $U$ (until) and $S$ (since). As usual, $\top$ (constant true), $\bot$ (constant false), $\lor$, $\land$, $\leftrightarrow$ and $F$, $P$, $G$, $H$ can be introduced as abbreviations. We will use $\alpha, \beta, \gamma, \ldots$ to range over formulas.

A frame $\mathscr{F}$ is an ordered couple $(T, <)$ consisting of a nonempty set $T$ with a binary relation $<$ on $T$. A valuation on a frame $\mathscr{F}$ is any function $V$ assigning each propositional variable a subset of $T$. For a valuation $V$ on a frame $\mathscr{F}$, a formula $\alpha$ and an element $t$ of $T$, $(\mathscr{F}, V) \vDash \alpha[t]$ is defined recursively as follows:

- (i) $(\mathscr{F}, V) \vDash p[t]$ iff $t \in V(p)$, for every propositional variable $p$

- (ii) $(\mathscr{F}, V) \vDash \neg\beta[t]$ iff $(\mathscr{F}, V) \nvDash \beta[t]$ (i.e., not $(\mathscr{F}, V) \vDash \beta[t]$)

- (iii) $(\mathscr{F}, V) \vDash \beta \to \gamma[t]$ iff if $(\mathscr{F}, V) \vDash \beta[t]$, then $(\mathscr{F}, V) \vDash \gamma[t]$

- (iv) $(\mathscr{F}, V) \vDash U(\beta, \gamma)[t]$ iff for some $t' \in T$ with $t < t'$, $(\mathscr{F}, V) \vDash \beta[t']$ and for every $t'' \in T$ with $t < t''$ and $t'' < t'$, $(\mathscr{F}, V) \vDash \gamma[t'']$

- (v) $(\mathscr{F}, V) \vDash S(\beta, \gamma)[t]$ iff for some $t' \in T$ with $t' < t$, $(\mathscr{F}, V) \vDash \beta[t']$ and for every $t'' \in T$ with $t' < t''$ and $t'' < t$, $(\mathscr{F}, V) \vDash \gamma[t'']$.

$\alpha$ is valid for $\mathscr{F}$, denoted by $\mathscr{F} \vDash \alpha$, if $(\mathscr{F}, V) \vDash \alpha[t]$ for every $t \in T$ and every valuation $V$ on $\mathscr{F}$. Let $\Sigma$ be a set of formulas. We write $\mathscr{F} \vDash \Sigma$ to indicate that $\mathscr{F} \vDash \alpha$ for every $\alpha \in \Sigma$. $\alpha$ is a semantic consequence of $\Sigma$, denoted by $\Sigma \vDash \alpha$, if for every frame $\mathscr{F}$, $\mathscr{F} \vDash \Sigma$ only if $\mathscr{F} \vDash \alpha$.

Let $\alpha$ be a formula and $\alpha^*$ a sentence of a first-order language with $=$ and a binary predicate constant $<$. We say that $\alpha$ defines $\alpha^*$ if the following holds:

$$\text{For every frame } \mathscr{F}, \ \mathscr{F} \vDash \alpha \text{ iff } \mathscr{F} \vDash \alpha^*,$$

where, at the right hand, $\mathscr{F}$ serves as a structure for the first-order language described above, and $\vDash$ as the usual satisfaction relation of model theory.

---

## Axioms and Logics

A $U,S$-tense logic is a set $TL_{US}$ of formulas which (i) contains all classical tautologies together with the following

$$\text{(1)} \quad G(p \to q) \to (U(r, p) \to U(q, r)) \land (U(r, p) \to U(r, q))$$

$$\text{(2)} \quad H(p \to q) \to (S(p, r) \to S(q, r)) \land (S(r, p) \to S(r, q))$$

$$\text{(3)} \quad p \land U(q, r) \to U(q \land S(p, r), r)$$

$$\text{(4)} \quad p \land S(q, r) \to S(q \land U(p, r), r),$$

and (ii) is closed under the rules of Uniform Substitution, Modus Ponens and Temporal Generalization (i.e., from $\alpha$ to infer $G\alpha$ and $H\alpha$). We use $TL_{US}(\Sigma)$ to denote the smallest $U,S$-tense logic containing the set $\Sigma$ of formulas. Note that every $U,S$-tense logic is closed under the (derived) rule of Substitution of Equivalents (cf. [1]).

For any set $\Sigma$ of formulas, $TL_{US}(\Sigma)$ is complete if

$$\text{for every } \alpha, \ \Sigma \vDash \alpha \text{ iff } \alpha \in TL_{US}(\Sigma).$$

For any class $\mathscr{C}$ of frames, we write $\mathrm{Th}(\mathscr{C})$ to denote the set $\{\alpha \mid \text{for every } \mathscr{F} \in \mathscr{C}, \ \mathscr{F} \vDash \alpha\}$. Another version of the completeness of $TL_{US}(\Sigma)$ is that

$$\text{for some class } \mathscr{C} \text{ of frames}, \ TL_{US}(\Sigma) = \mathrm{Th}(\mathscr{C}).$$

Clearly, these two versions are equivalent.

---
