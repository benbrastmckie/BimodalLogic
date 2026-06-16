## A9. Versatility

Nearly always, the frames one has in mind for a modal language, satisfy some extra conditions. An important example is formed by tense logic:

**Definition A40. Tense.**
Assume that a subset $T$ of the diamonds of $S$ is given as $T = \{F_j, P_j \mid j \in J\}$. Diamonds in this set are called *tense diamonds*, their duals *tense boxes*. We call $F_j$ the *converse* of $P_j$ and the other way round. If $\Diamond$ is a tense diamond, its converse is denoted by $\Diamond^{-1}$. A diamond that is not in $T$ is called *uni-directional*. If all diamonds of a similarity type are in $T$, we call it a *tense similarity type*.

A frame $(W, R_\nabla)_{\nabla \in S}$ for $S$ is called a *tense frame* if for every $\Diamond \in T$, the accessibility relations of $\Diamond$ and $\Diamond^{-1}$ are each other's converse, i.e. $R_{\Diamond^{-1}} = (R_\Diamond)^{-1}$. For a class K of $S$-frames, we let $\mathrm{K}^t$ denote the class of tense frames in K.

With emphasis, we want to note that the above definition should be understood as to include the case where a modal operator is its *own* converse.

**Definition A41. Tense Logics.**
Let $S, T$ be as above. The *minimal tense logic* $K^t_S$ is the minimal $S$-logic $K_S$ extended with the following axiom for every $\Diamond \in T$:

$(CV)$ $p \to \Box\Diamond^{-1}p$

**Theorem A42.**
$K^t_S$ is strongly sound and complete with respect to the class of all tense frames.

We want to generalize these concepts to operators of higher rank:

**Definition A43: Versatility.**
A *versatile* similarity type is a modal similarity type $S = (O, \rho)$ where the set $O$ of operators is given as a (disjoint) union of sets, $O = \bigcup_{j \in J} O_j$, such that $O_j = \{\nabla_{j0}, \ldots, \nabla_{j,n_j}\}$ and all operators in $O_j$ have the same rank $n_j - 1$.

A *versatile frame* for such an $S$ is an $S$-frame $(W, I)$ where for all $j \in J$, $i \leq n_j$ one has

$$I(\nabla_{ji}) = \{(w_0, w_1, \ldots, w_{n_j}) \mid (w_1, \ldots, w_{n_j}, w_0) \in I(\nabla_{j,i+1})\}$$

For a class K of $S$-frames, we let $\mathrm{K}^v$ denote the class of versatile frames in K.

We do not exclude the possibility that $O_j = \{\nabla, \ldots, \nabla\}$, i.e. all operators are identical. Once we know that a frame is versatile, it is not necessary to give all of its accessibility relations. For example, a frame $\mathfrak{F} = (W, R_\Diamond, R_{\Diamond^{-1}})$ can be identified with $\mathfrak{F} = (W, R_\Diamond)$ if $R_{\Diamond^{-1}} = (R_\Diamond)^{-1}$.

Note that the notion 'tense' only applies to diamonds: in a tense similarity type $S$ there is no constraint on the operators of rank $> 2$. Only if all operators of $S$ are constants or diamonds, do the concepts of 'tense' and 'versatility' coincide, and do we have $\mathrm{K}^t = \mathrm{K}^v$.

The notions of tense and versatile operators are known in the theory of Boolean Algebras with Operators under the names of conjugates and residuals.

---

---

# Appendix B. Consequences of Derivation Systems

## Outline

We discuss an alternative for our notion of semantic consequence ($\Sigma \models \phi$) and show that in the context of non-$\xi$ rules, our option behaves nicer.

---

Recall that we defined a *local* consequence relation for modal formulas by setting

$$\Sigma \models_\mathrm{K} \phi \iff \text{for all models } \mathfrak{M} = (\mathfrak{F}, V) \text{ with } \mathfrak{F} \text{ in K and every world } w \text{ in } \mathfrak{M}: \mathfrak{M}, w \models \Sigma \Rightarrow \mathfrak{M}, w \models \phi.$$

There is a different, *global* paradigm in modal logic, where:

$$\Sigma \models^*_\mathrm{K} \phi \iff \text{for all models } \mathfrak{M} = (\mathfrak{F}, V) \text{ with } \mathfrak{F} \text{ in K}: \mathfrak{M} \models \Sigma \Rightarrow \mathfrak{M} \models \phi.$$

We face an analogous choice in first order logic, if we want to decide what $\Sigma \models \phi$ means, when $\Sigma$ and $\phi$ contain *free variables*. (Note that for the formalism $L^*_\alpha$ the question is not only analogous to, but indeed the very same as for $CML_\alpha$.)

This difference in semantic perspective is reflected in the interpretation of *derivation systems*.

In our approach, $\Sigma \vdash_\Lambda \phi$ holds if there are $\sigma_1, \ldots, \sigma_n \in \Sigma$ with $\vdash_\Lambda (\sigma_1 \wedge \ldots \wedge \sigma_n) \to \phi$, i.e. derivation rules may only be applied to logical theorems.

In the other line of thinking, $\Sigma \vdash^*_\Lambda \phi$ holds if there is a derivation $\phi_0, \ldots, \phi_n = \phi$ such that every $\phi_i$ is either an axiom of $\Lambda$ *or in* $\Sigma$, or obtained from an earlier $\phi_j$ by an application of a derivation rule. In other words: the formulas in $\Sigma$ are to be used as if they were axioms.

In principle, two choices, both out of two alternatives, would give us four possible pairs consisting of a semantic and an axiomatic notion. Of these, the pairs $\{\models^*, \vdash\}$ and $\{\models, \vdash^*\}$ are ruled out if we want the axiomatic relation to be (strongly) sound and complete with respect to the semantic one: the fact that $p \models^* \Box p$ and $p \nvdash \Box p$ implies that $\vdash$ cannot be complete with respect to $\models^*$, and likewise, the pair $\{\models, \vdash^*\}$ will give problems concerning *soundness*, as $p \not\models \Box p$, yet $p \vdash^* \Box p$.

In this appendix we briefly compare the remaining pairs $\{\models, \vdash\}$ and $\{\models^*, \vdash^*\}$, which we will call 'our' or the 'local' paradigm, respectively the '$*$-style' or 'global' paradigm.

For algebraists, the choice for the $*$-style paradigm seems to be obvious, as equations are always implicitly understood to be universally quantified, and one is interested in an algebra as a whole.

In the *possible world semantics* of modal logic however, we have a strong preference for the *local* paradigm, and we believe that our reasons for this opinion could lead algebraic logicians to think that the local perspective is at least *interesting*. Our motivation for the local variant of semantic consequence and derivation systems is threefold:

First, one can show that $\models$ is *more informative* than $\models^*$. For example (abbreviate $\Box^0\phi = \phi$, $\Box^{n+1}\phi = \Box\Box^n\phi$):

$$\{p_0\} \cup \{\Box^n(p_n \to (\neg p_{n+1} \wedge \Diamond p_{n+1})) \mid n \in \omega\} \models_\mathrm{K} \bot \tag{1}$$

provides us with information about the class K, namely that

$$\text{no K-frame contains an infinite sequence } w_0 R w_1 R w_2 \ldots \tag{2}$$

The global version of (1) is vacuously true, so it does not tell us anything. It is not clear to us how to express (2) using $\models^*$, *unless one adds to the language operators enabling a local perspective*, for example the 'only here' operator $O$. Following an idea by Johan van Benthem, we can show that, letting $p$ be a new variable for $\Sigma, \phi$,

$$\Sigma \models \phi \iff \{EOp\} \cup \{p \to \sigma \mid \sigma \in \Sigma\} \models^* p \to \phi.$$

On the other hand, $\models^*$ can always be reduced to $\models$: let us, in the context of this dissertation, assume (footnote 1) that we have an operator $\boxplus$ such that $\boxplus\phi$ holds in a world $w$ iff $\phi$ holds in *every* world somehow accessible from $w$. Define $\boxplus\Sigma = \{\boxplus\sigma \mid \sigma \in \Sigma\}$. Then we have

$$\Sigma \models^* \phi \iff \boxplus\Sigma \models \boxplus\phi, \tag{3}$$

as a simple proof shows.

> Footnote 1: This idea stems from Goranko and Passy [46]; using proposition 2.33 in van Benthem [14], one can reduce $\models^*$ to $\models$ in *any* similarity type.

A second, more philosophical reason to prefer $\vdash$ to $\vdash^*$ is that in our opinion, it is an essential characteristic of modal logic that there is not one single notion of validity, not one single logic. This makes for a distinction between logics and theories and it is not clear to us how to represent this distinction in the $*$-style paradigm. We may identify an (orthodox) derivation system $\Lambda$ with its set of axioms, but there should be a *conceptual difference* between $\Lambda_1 \vdash_{\Lambda_2} \phi$ and $\Lambda_2 \vdash_{\Lambda_1} \phi$. In the $*$-approach however, both $\Lambda_1 \vdash^*_{\Lambda_2} \phi$ and $\Lambda_2 \vdash^*_{\Lambda_1} \phi$ reduce to $\Lambda_1 \cup \Lambda_2 \vdash^*_K \phi$, where $K$ is the minimal modal logic of the similarity type.

Our third and main motivation to focus on the local consequence relation is related to the notion of a non-$\xi$ rule.

Let us consider the simplest case of the irreflexivity rule $IR_D$ for the $D$-operator:

$$(IR_D) \qquad (p \wedge \neg Dp) \to \phi \ / \ \phi, \quad \text{if } p \notin \phi.$$

For this rule, problems will rise concerning *soundness* if we adhere to the $*$-paradigm. For, it lies in the *nature* of the $D$-operator that any standard model $\mathfrak{M}$ can have at most one world where $p \wedge \neg Dp$ is true. This implies that in any non-trivial standard model $\mathfrak{M}$, $\mathfrak{M} \models \neg(p \wedge \neg Dp)$, or equivalently, $\mathfrak{M} \models (p \wedge \neg Dp) \to \bot$. If we want $IR_D$ to be $*$-sound, by the instance $(p \wedge \neg Dp) \to \bot / \bot$ of $IR_D$ we are forced to conclude $\mathfrak{M} \models \bot$, which is clearly undesirable.

So at this particular point, the focus on the *local* consequence relation is *essential*:

> in the global paradigm non-$\xi$ rules make no sense.

Turning to the example of cylindric modal logic and related notions, we can go even further and claim that no finite $*$-style derivation system can be a sound and complete axiomatization for the cylindric modal formulas valid in the cubes, or the $\mathcal{CC}6$-formulas valid in the squares (footnote 2).

> Footnote 2: The same claim applies to the equations holding in representable cylindric algebras, typeless valid formulas, etc.

**Theorem B.1.**
Let $\Lambda = (MA, MD)$ be a derivation system for cylindric modal logic of dimension $n < \omega$, and suppose that $\Lambda$ is $*$-style sound and complete with respect to cube validity, i.e. $\Sigma \models^*_{C_n} \phi \iff \Sigma \vdash^*_\Lambda \phi$.

Then either $MA$ or $MD$ is infinite.

**Proof.**
We will show that unorthodox derivation *rules* can be replaced by *axioms*, in any derivation system which is $*$-style strongly sound and complete with respect to cube validity. Our 'non-finite derivability result' then follows by Monks theorem that $\mathit{Equ}(\mathrm{RCA}_n)$ is not finitely axiomatizable (and hence, it can be strengthened along the lines of Andreka [5], cf. the remarks below definition 4.1.8).

For a sketch of the proof, suppose that $\Lambda = (MA, MR \cup \{R\})$ is a finite derivation system which is $*$-style sound and complete with respect to the cubes, where $R : \alpha / \beta$ is an unorthodox derivation rule. (The proof can easily be adapted for rules having constraints.)

Let $\Lambda^A$ be the derivation system $(MA \cup \{A\}, MR)$, where $A$ is the axiom (schema) $\boxplus\alpha \to \boxplus\beta$. We have to show that

$$\Sigma \vdash^*_\Lambda \phi \iff \Sigma \vdash^*_{\Lambda^A} \phi.$$

To prove ($\Leftarrow$), it is sufficient to show that $\boxplus\alpha' \to \boxplus\beta'$ is a theorem of $\Lambda$, for every instance $(\alpha', \beta')$ of $(\alpha, \beta)$. Now as $\Lambda$ is $*$-style sound, we have $\alpha' \models^* \beta'$, implying $\models^* \boxplus\alpha' \to \boxplus\beta'$ by (3). By the supposed completeness of $\Lambda$, this implies $\vdash^*_\Lambda \boxplus\alpha' \to \boxplus\beta'$.

For ($\Rightarrow$), we have to prove that $\alpha / \beta$ is a derived rule of $\Lambda^A$. This is rather easy, as the following ($*$-style) derivation shows:

| | |
|---|---|
| (1) $\alpha'$ | (assumption) |
| (2) $\boxplus\alpha'$ | (1, $UG$) |
| (3) $\boxplus\alpha' \to \boxplus\beta'$ | (axiom) |
| (4) $\boxplus\beta'$ | (2, 3, $MP$) |
| (5) $\beta'$ | (4, $\boxplus$ is S5) |

This proves Theorem B.1.

**Conclusion.**
The *local* perspective on derivation systems and the semantic consequence relation is *essential* in the idea to use *unorthodox* derivation rules as a means to get round the *non-finite axiomatizability results* in algebraic logic.
