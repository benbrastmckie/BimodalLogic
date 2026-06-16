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
