## 2.8 The SN$\Xi$-theorem

We are now ready to prove our main completeness theorem for a versatile logic having other non-$\xi$ rules besides $IR_D$.

**Definition 2.8.1.**
Let $S$ be a versatile similarity type containing the $D$-operator, $\Sigma$ a set of Sahlqvist formulas and $\Xi$ a set of arbitrary formulas. $K^v_S D^+(\Sigma, -\Xi)$ is the logic $K^v_S D^+$ extended with the axioms $\Sigma$ and the non-$\xi$ rules for all $\xi \in \Xi$. $\square$

Recall that the above definition implies that the *rules* of $K^v_SD^+(\Sigma, -\Xi)$ are $MP$, $UG$, $SUB$, $IR_D$ and $\{N\xi R \mid \xi \in \Xi\}$.

If the similarity type contains only constants and diamonds, then the system has the following *axioms*:

- $(CT)$ all classical tautologies
- $(DB)$ $\Box(p \to q) \to (\Box p \to \Box q)$
- $(CV)$ $\phi \to \Box\Diamond^{-1}p$
- $(D1)$ $p \to \underline{D}Dp$
- $(D2)$ $DDp \to (p \lor Dp)$
- $(D3)$ $\Diamond p \to p \lor Dp$
- $(\Sigma)$ $\Sigma$

If there are also triangles around, then the system has the versatility axiom $V$ too (cf. 2.7.2).

Note that the class $\mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}$ was defined as the class of standard versatile $S$-frames with

$$\begin{aligned}
\mathfrak{z} &\models \sigma \quad \text{for all } \sigma \text{ in } \Sigma \\
\mathfrak{z}, w &\not\models \xi \quad \text{for all } w \text{ in } \mathfrak{z}, \xi \text{ in } \Xi
\end{aligned}$$

If all $\xi$'s have local first order equivalents $\xi^f(x)$ on the frame level (for example, if every $\xi$ is a Sahlqvist formula too), then $\mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}$ is elementary, as we have

$$\mathfrak{z} \text{ in } \mathrm{Fr}_{-\xi} \iff \mathfrak{z} \models \forall x \neg \xi^f(x).$$

So, the theory below takes care of many classes of frames, for example the asymmetric or intransitive frames (cf. the characterizations given in the introduction).

**Theorem 2.8.2. SN$\Xi$-THEOREM.**
Let $S, \Sigma$ and $\Xi$ be as in definition 2.8.1. Then

$$K^v_SD^+(\Sigma, -\Xi) \text{ is strongly sound and complete for } \mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}.$$

The proof of Theorem 2.8.2 is in fact a straightforward adaptation of the proof in section 2.7. There we started with a MCS $\Delta$ and inserted in $\Delta$, for every $s \in 2^*$ and formula $\phi \in \Delta$, formulas $W(Op, s, \phi)$, in order to witness the $R_D$-irreflexivity of all worlds connected to $\Delta$. Here we will add more formulas (of the form $W(\neg\xi(p_1, \ldots, p_n), s, \phi)$), this time in order to ensure that the canonical-like general frame we end with is not only standard (with respect to $R_D$), but also in $\mathrm{Fr}_{-\Xi}$. So we set

**Definition 2.8.3.**
A set $\Delta$ of $S$-formulas is *witnessing* if it is distinguishing and satisfies that for all sequences $s \in 2^*$, formulas $\phi \in \Delta$ and $\xi \in \Xi$, there are propositional variables $p_1, \ldots, p_n$ with $W(\neg\xi(p_1, \ldots, p_n), s, \phi) \in \Delta$. $\square$

**Lemma 2.8.4.**
Every maximal consistent $\Delta$ has a witnessing extension $\Delta'$.

**Proof.**
An straightforward analogon of 2.7.12. $\square$

**Definition 2.8.5.**
A *w(itnessing)-canonical frame* is of the form $\mathfrak{z}^w = (W^w, R^w_\nabla)_{\nabla \in S}$ where $W^w$ is a $\sim_D$-connected set of witnessing theories and $R^w_\nabla$ is the canonical accessibility relation of $\nabla$, restricted to $W^w$. *Witnessing models* and *witnessing general frames* are also defined in the obvious way. For a w-theory $\Delta$, *the* w-canonical frame (model, etc.) of $\Delta$ is the w-canonical frame with $\Delta \in W^w$. If we want to make the set $\Xi$ explicit, we use the term *w-canonical structure witnessing against* $\Xi$. $\square$

**Lemma 2.8.6: Truth Lemma.**
Let $\mathfrak{M}^w$ be a w-canonical model, $\Delta$ a world of $\mathfrak{M}^w$. Then

$$\mathfrak{M}^w, \Delta \models \phi \iff \phi \in \Delta.$$

**Proof.**
In the same manner as in section 7, we prove that for every w-theory $\Delta$ and for every diamond $\Diamond$, triangle $\triangle$ we have

$$\begin{aligned}
\Diamond\phi \in \Delta &\iff \text{there is a w-theory } \Delta' \text{ with } (\Delta, \Delta') \in R^w_\Diamond \text{ and } \phi \in \Delta', \\
\phi_1\triangle\phi_2 \in \Delta &\iff \text{there are w-theories } \Delta_1, \Delta_2 \text{ with} \\
&\quad (\Delta, \Delta_1, \Delta_2) \in R^w_\triangle \text{ and } \phi_i \in \Delta_i.
\end{aligned}$$

As we can also show that $\mathfrak{z}^w$ is standard, the truth lemma follows by a straightforward formula induction. $\square$

**Lemma 2.8.7.**
Let $\mathfrak{G}^w = (\mathfrak{z}^w, A^w)$ be a w-canonical general versatile frame witnessing against $\Xi$. Then $\mathfrak{z}^w$ is in $\mathrm{Fr}^{v,\neq}_{-\Xi}$.

**Proof.**
Let $\Delta$ be a world of $\mathfrak{z}^w$. As $\Delta$ is a w-theory of the logic, we can find for every $\xi \in \Xi$ propositional variables $\vec{p}$ with $\neg\xi(\vec{p}) \in \Delta$. By the truth lemma then $\mathfrak{M}^w, u \models \neg\xi(\vec{p})$

So $\mathfrak{z}^w, \Delta \not\models \xi$, for all $\xi \in \Xi$. The proof that $\mathfrak{z}^w$ is standard and versatile just runs like in section 7. $\square$

**Proof of theorem 2.8.2.**
Soundness is already proved in the introduction to this chapter. For completeness, let $\Delta$ be a $K^v_SD^+(\Sigma, -\Xi)$-consistent set of formulas. By the extension lemma, $\Delta$ is contained in a w-theory $\Delta'$. Let $\mathfrak{M}^w$ be the w-canonical model of $\Delta'$. By the truth lemma,

$$\mathfrak{M}^w, \Delta' \models \phi \text{ for all } \phi \in \Delta'.$$

A (by now) standard argument shows that $\mathfrak{z}^w$ is versatile, so by lemma 2.8.7, $\mathfrak{z}^w$ is in $\mathrm{Fr}^{v,\neq}_{-\Xi}$. It is in $\mathrm{Fr}_\Sigma$ by the facts that $\mathfrak{G}^w$ is discrete (every w-theory is distinguishing!) and that $\mathfrak{G}^w \models \Sigma$. So we have satisfied $\Delta$ in a model based on a frame in the intended class $\mathrm{Fr}^{v,\neq}_{(\Sigma, -\Xi)}$. $\square$

Just like in section 6, we can prove a poorer version of Theorem 2.8.2 for arbitrary (not versatile) similarity types, but we leave this to the reader.

---

## 2.9 Conclusions, Remarks and Questions

### 2.9.1 General Conclusions

This chapter was a study in the semantics and axiomatics of non-$\xi$ rules, styled after Gabbay's (Generalized) Irreflexivity Rule.

On the semantic side, we defined $\mathrm{K}_{-\Xi}$ as the class of frames $\mathfrak{z}$ in K where no $\xi \in \Xi$ holds anywhere, i.e. for no $\xi \in \Xi$ is there a $w$ in $\mathfrak{z}$ with $\mathfrak{z}, w \models \xi$. In general, such a class will not be *definable* by a modal formula. Natural examples are formed by the irreflexive, asymmetric or transitive frames.

The main result of this chapter, the $SN\Xi$-theorem 2.8.2 states that under certain conditions, classes of the form $\mathrm{K}_{-\Xi}$ are *axiomatizable*, by a derivation system having a non-$\xi$ rule for every $\xi \in \Xi$. In the various sections of this chapter we have discussed these conditions.

The most elegant formulation of the $SN\Xi$-theorem is in the case where the similarity type is *versatile* and contains the $D$-operator. For such a similarity type, our result gives a nice derivation system for every class $\mathrm{K}_{-\Xi}$ where K is a class of $D$-standard, versatile frames which is characterized by a set of *Sahlqvist axioms*. For poorer similarity types, there are various options, of which we list a few:

- (i) If the similarity type is not versatile, we have to add a *schema* of non-$\xi$ rules (cf. sections 6 and 7).
- (ii) If not all diamonds are tense, only *Sahlqvist tense* formulas are allowed as axioms (cf. sections 5 and 6).
- (iii) If the similarity type $S$ does not contain the $D$-operator, the theorem does not apply directly.

Fortunately, this does not mean that the full power of the $SN\Xi$-theorem is lost for these poorer similarity types; one only has to work a bit harder for it. To give an example: in many cases, over the class $\mathrm{K}_{-\Xi}$ we can *define* the $D$-operator in the poorer formalism, so that we can work with this defined $D'$-operator. Each chapter of this thesis contains a worked out example of this idea.

So, more than a theorem, the $SN\Xi$-concept is a *procedure* to find axiomatizations for non-$\xi$ classes:

- (i) Find the proper characterization of the class (maybe in an extended similarity type).
- (ii) Apply the $SN\Xi$-theorem, immediately obtaining a strongly sound and complete derivation system.
- (iii) Try to simplify this system.

This schedule will be used throughout this dissertation.

It would be unfair not to mention the fact that axiomatizations using non-$\xi$ rules have some *disadvantages* too: first of all, such axiomatizations may not have all the nice mathematical properties that orthodox axiomatization have. For example (cf. Goldblatt [43]): define, for a logic $\Lambda$, the corresponding algebraic variety $\mathrm{V}_\Lambda$ of Boolean Algebras with Operators as the class of algebras where the set of equations $\{\phi = 1 \mid \Lambda \vdash \phi\}$ is valid. Now for a finite *orthodox* $\Lambda$, the complement of $\mathrm{V}_\Lambda$ will be closed under ultraproducts, while this need not be the case for an unorthodox $\Lambda$. Second, by the nature of the derivation rule, it may be necessary to add new propositional variables to the language in order to derive a formula $\phi$, whence we have *less control* on derivations in these unorthodox systems.

These disadvantages take us to the question, in which cases a non-$\xi$ rule can be *eliminated* from a system.

### 2.9.2 Conservativity

An interesting point which has not been discussed yet concerns the question whether non-$\xi$ rules add new theorems to a logic.

Some scattered results are known:

In the introduction we saw an example where a rule is *conservative*: the logic $K^t4$ already axiomatizes the class of irreflexive transitive tense frames, so adding $IR$ does not produce any new theorem.

On the other hand, adding $IR$ to $K^tL(Gp \to p)$ makes this logic inconsistent, so here $IR$ is not conservative. In Zanardo [141], Zanardo replaced the irreflexivity rule used in Burgess [23] to axiomatize a branching-time temporal logic, by (infinitely many) axioms. An similar case is found in cylindric modal logic and the modal logic of relation algebras (cf. Venema [131, 132]), where adding a non-$\xi$ rule to a finite set of axioms creates a finite derivation system for a logic which is known not to be finitely axiomatizable when only the orthodox derivation rules $MP$, $UG$ and $SUB$ are allowed. A striking difference between a uni-directional similarity type and its tense counterpart concerns the modal logic of the two-dimensional 'domino relation', where an axiomatization of the uni-directional modal logic needs *both* infinitely many axioms *and* a non-$\xi$ rule (cf. Kuhn [68]), while the tense logic allows a finite and orthodox axiomatization (cf. Venema [135]).

The general question

> Are there natural (syntactic/semantic) criteria deciding when a non-$\xi$ rule is conservative over a derivation system?

lies (almost) completely open. We have one minor result: recall that a formula is *closed* if it does not contain propositional variables (only constants).

**Definition 2.9.1.**
A logic $\Lambda$ has the *interpolation property* $(IP)$ if $\Lambda \vdash \phi \to \psi$ implies the existence of an *interpolant* $\chi$ in the common language of $\phi$ and $\psi$, such that $\Lambda \vdash \phi \to \chi$ and $\Lambda \vdash \chi \to \psi$. $\square$

**Proposition 2.9.2.**
Let $\Lambda$ be a logic and $\xi$ a formula, such that

- (i) $\Lambda$ has the $IP$.
- (ii) for every closed formula $\gamma$, $\Lambda(-\xi) \vdash \gamma$ implies $\Lambda \vdash \gamma$.

Then $N\xi R$ is conservative over $\Lambda$.

**Proof.**
Assume that $\Lambda$ and $\xi$ satisfy (i) and (ii). Denote derivability in $\Lambda$ by $\vdash$. To show that $N\xi R$ is conservative over $\Lambda$, we must prove

$$\vdash \neg\xi(\vec{p}) \to \phi \ \Rightarrow\ \vdash \phi, \text{ if no } p_i \text{ occurs in } \phi$$

So assume $\vdash \neg\xi(\vec{p}) \to \phi$ where $\vec{p} \notin \phi$. By (i) there is an interpolant $\gamma$ for $\neg\xi(\vec{p})$ and $\phi$; $\gamma$ must be closed, as $\neg(\vec{p})$ and $\phi$ do not share any variables. As $\vdash \neg\xi(\vec{p}) \to \gamma$, one application of $N\xi R$ shows that $\gamma$ is a $\Lambda(-\xi)$-theorem, so by (ii), $\vdash \gamma$. Now $\vdash \phi$ is immediate by $\vdash \gamma \to \phi$. $\square$

### 2.9.3 Questions and Remarks

We end this chapter with some miscellaneous questions and remarks:

- (i) The most obvious question is whether the $SN\Xi$-result can be extended to similarity types not having the $D$-operator or tense diamonds, and to arbitrary canonical formulas. Independently from our result, Goranko [45] announces a similar meta-theorem on *weak* completeness, for arbitrary canonical formulas. Hodkinson [35] extends our result to a similarity type where diamonds come in pairs too, here having *complementary* accessibility relations ($R_{-\Diamond} = (R_\Diamond)^c$).

- (ii) Call a class *negatively definable* if it is of the form $\mathrm{Fr}_{-\Xi}$. There seems to be an interesting connection between this notion and what Kracht calls *describable properties*, cf. [66]. Is there a *structural characterization* for negatively definable classes, like there is for modally definable classes? It is not difficult to see that negatively definable classes are closed under disjoint unions and generated subframes; any $\mathrm{Fr}_{-\Xi}$ *reflects* p-morphic images, and if it is elementary, ultrafilter extensions too. Do these preservation properties give the desired characterization for (elementary) negatively definable classes?

- (iii) Let $\Lambda$ be the set of formulas $\Theta(\mathrm{Fr}_{(\Sigma, -\Xi)})$, and $\mathrm{Fr}_\Lambda$ the class of frames where $\Lambda$ is valid. What is the relation between $\mathrm{Fr}_{(\Sigma, -\Xi)}$ and $\mathrm{Fr}_\Lambda$?

- (iv) Consider the tense similarity type with diamonds $\{F, P, D\}$. To axiomatize the irreflexive frames, we now have the choice between the $F$-irreflexivity rule and the *axiom* $Fp \to Dp$. When and how can rules be replaced by axioms, and vice versa?

- (v) An interesting aspect of non-$\xi$ rules is that in some sense they behave like axioms; in the introduction we already saw how they *characterize* the class $\mathrm{K}_{-\xi}$ where $N\xi R$ is *sound*. Maybe it is better to use the term *anti-axioms*$^7$, however, according to their behaviour in derivation systems: an orthodox derivation system $MD = (AX, \{MP, UG, SUB\})$ generates a logic, to be precisely, the *smallest* set of formulas $AX$ which is closed under $MP$, $UG$ and $SUB$. For the set $\Lambda$ of formulas generated by the axiom system $MD(-\xi) = (AX, \{MP, UG, SUB, N\xi R\})$, we may add the clause that $\Lambda$, if consistent, must also be the *least* set of formulas *not containing* the formula $\xi$ (to be more precisely, not containing $\xi$ in any 'existential position', like in $\Diamond(\delta \land \xi)$).

- (vi) In the following chapters we will see *examples* of applications of the $SN\Xi$-theorem in algebraic logic, but there is also a *general* perspective. Recall that in the theory of Boolean Algebras with Operators one is interested in representing algebras over sets, and defines *canonical extensions* for this aim. Now in fact, our 'constructive' way of defining distinguishing and witnessing theories, leading to the notion of distinguishing resp. witnessing canonical frames, constitutes a *new set representation of free algebras* over sets. In this new way of representing algebras, one seems to have *more control* on the properties of the frame than in the ordinary representation over ultrafilters. Obvious questions are to extend the construction to *arbitrary* algebras, and to investigate its (algebraic) properties.

---

$^1$In this sense the example is not representative: For $K^t4$, the irreflexivity rule is *conservative* (cf. section 7).

$^2$In fact, we may even consider the wider set of formulas obtained from (basic) Sahlqvist formulas by applying *duals* of existential modal operators.

$^3$An equivalent definition, which is perhaps more perspicuous from the algebraic point of view, is: a *Sahlqvist equation* is of the form $r = 0$, where $r$ is an *untied term*.

$^4$This important observation was made by Johan van Benthem, cf. section 3.3.5.

$^5$To be precise, we define a function from $S$-formulas to formulas in the extended similarity type with the dummy operator.

$^6$This restriction can easily be lifted.

$^7$This explains our notation '$-\xi$'
