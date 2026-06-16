## 3 IRR

There does already exist a weakly complete axiomatization of $U$ and $S$ over the reals. However Gabbay and Hodkinson in [8] use an extra rule as well as the usual four inference rules along with their axioms. Let us try and argue the worth of presenting yet another axiomatization just so that we do not have to use this *irreflexivity rule* (IRR).

Recall that a binary relation $<$ on a set $T$ is irreflexive if we do not have $t < t$ for any $t \in T$.

Gabbay introduced IRR in [6]. It allows

$$\frac{q \wedge H(\neg q) \to A}{A} \quad \text{provided that the atom } q \text{ does not appear in } A.$$

A short proof (see for example [8], Proposition 2.2.1) establishes that, if $\mathcal{I}$ is a class of irreflexive partial orders, then IRR is a valid rule in the class of all structures whose underlying flow of time comes from $\mathcal{I}$.

The original motivation for the use of this rule concerned the impossibility of writing an axiom to enforce irreflexivity of flows (see for example [1]). The usual technique in a completeness proof is to construct some model of a consistent formula and then turn it into an irreflexive model. IRR allows immediate construction of an irreflexive model. This is because it is always consistent to posit the truth of $q \wedge H(\neg q)$ (for some 'new' atom $q$) at any point as we do the construction.

The benefits of this rule for doing a completeness proof are enormous. Much use of it is made in [7]. Venema [16] gives a long list of results proved using IRR or similar rules: examples include branching time logics [19] and two-dimensional modal logics [14].

In fact, the major benefit of IRR is a side-effect of its purpose. Not only can we construct a model which is irreflexive but we can construct a model in which each point has a unique name (as the first point where a certain atom holds). To see how this helps, and because our proof follows theirs closely in some parts, let us look at the completeness proof in [8].

Most of the axioms of [8] are the axioms for $F$ and $P$ over the rationals. This is because, if you have a unique name of the form $r \wedge H(\neg r)$ for each point then their axiom

$$(UU) \quad r \wedge H(\neg r) \to [U(p, q) \leftrightarrow F(p \wedge H[Pr \to q])]$$

and its dual (SS) essentially define $U$ and $S$ in terms of $F$ and $P$.

Thus [8] can use the usual Henkin construction with $F$ and $P$ to find a rational-flowed model for their consistent formula, while because we want to start in the same way, but in the absence of names, $U$ and $S$ are not definable in terms of $F$ and $P$, the more complicated $U$ and $S$ construction of Burgess [2] (see section 4) is necessary for us.

Ensuring definable Dedekind completeness can be done by the Prior axioms,

$$FGq \wedge F\neg q \to F(Gq \wedge \neg PGq)$$

and its dual, if names are available, or by our stronger Prior-U and Prior-S if not.

Both [8] and us then arrive at a model of the formula, which has a rational flow of time but which is definably Dedekind complete and in which all substitution instances of the respective Sep axioms are valid.

Both proofs then finish off by applying a result of Kees Doets in [4] for finding a real-flowed model of the formula. We do this in section 8. An important prerequisite for using this theorem is showing that the equivalence classes of a certain type of definable equivalence relation do not end at gaps. This is much the same as showing definable Dedekind completeness for sets defined by a first-order formula with one parameter. This follows immediately if your parameter has a temporal name but as will be seen in section 6, working nameless we have to work much harder.

Now the IRR rule, as well as making the completeness proof easier, also arguably makes proving from a set of axioms easier. This is because, being able to consistently introduce names for points into an axiomatic proof makes the temporal system more like the perhaps more intuitive first-order one. There are none of the problems such as with losing track of "now".

So given all these recommendations one is brought back to the question of why is it useful to do away with IRR. The growing body of theoretical work (see for example [16], [17]) trying to formalise conditions under which the orthodox (to use Venema's term) system of rules needs to be augmented by something like IRR can be justified as follows:

- adding a new rule of inference to the usual temporal ones is arguably a much more drastic step than adding axioms and it is always important to question whether such additions are necessary;
- (as pointed out by the referee), in making an unorthodox derivation one may need to go beyond the original language in order to prove a theorem, which makes such axiomatizations less attractive from the point of view of 'resource awareness';
- (as argued in [17]), using an atom to perform the naming task of an individual variable in predicate logic is not really in the spirit of temporal/modal logic; and
- (also as mentioned in [17]), unorthodox axiomatizations do not have some of the nice mathematical properties that orthodox systems have.

This paper contributes an interesting and potentially useful negative example to these investigations.

## 4 The Burgess--Xu Result

Our task in this section is to find a rational flow model of our formula and, in particular, one in which all substitution instances of the Prior axioms and Sep are valid. Fortunately, most of the work has been done already. Burgess in [2] proves soundness and completeness of a set of axioms for linear time. Xu, in [18], simplifies the set of axioms and the proof.

**Theorem 1.** *The Burgess--Xu system (the six axioms and duals, propositional tautologies and the four rules) is sound and strongly complete for the US logic on the class of all linear frames.*

Although neither Burgess nor Xu mention *strong* completeness their proofs do establish that. This is just as well for we need strong completeness. For details of the proof see [2] and comments on it in [18]. Soundness is just the usual easy induction: let us outline the basic idea of the completeness part.

We use the rationals as a base board on which we successively place whole maximal consistent sets of formulas as points which will eventually make up a flow of time.

Starting with our given maximal consistent set placed at zero say, we look for counter-examples to either of the following rules:

1. if $U(A, B) \in \Gamma$ placed at $t$ then there should be some $\Delta$ placed at $s > t$ with $A \in \Delta$ and so that theories placed in between $t$ and $s$ all contain $B$

2. if $\neg U(A, B) \in \Gamma$ placed at $t$ and $A \in \Delta$ placed at $s > t$ then there should be $\Xi$ placed somewhere in between with $\neg B \in \Xi$.

By carefully choosing a single maximal consistent set to right the counter-example and satisfy some other stringent conditions kept holding throughout the construction, we can ensure that the particular tuple $(t, U(A, B))$ or $(t, s, \neg U(A, B))$ never again forms a counter-example. Because there are only countable numbers of points and formulas involved, in the limit we can effect that we end up with a counter-example-free arrangements of sets. This is so nice that if we define a valuation on the order of sets by

$$M \models p(\Gamma) \quad \text{iff} \quad p \in \Gamma$$

then the flow of time consisting of those sets becomes a structure $M$ satisfying, for all $\Gamma \in M$, for all $A \in \Gamma$,

$$M \models A(\Gamma) \quad \text{iff} \quad A \in \Gamma.$$

This is thus our model.

Let us see how we can use this theorem.

Now suppose that we have a set $\Gamma$ of formulas consistent with the system **US/R**. Without loss of generality $\Gamma$ is maximal consistent.

By the theorem, since $\Gamma$ is also consistent with the Burgess--Xu system, there will be a linear model for $\Gamma$: i.e. a linear structure in which there is a point, $t$ say, at which all the formulas in $\Gamma$ hold.

By looking at Burgess's construction (or using Lowenheim--Skolem) we can suppose that the structure is countable.

Since $F\top \wedge GF\top$ and its mirror must be true at $t$, the order does not have end points. Since $H(K^- \top \wedge K^+ \top) \wedge (K^- \top \wedge K^+ \top) \wedge G(K^- \top \wedge K^+ \top)$ is true at $t$, the order is dense. Thus, by Cantor's theorem, the underlying flow of time may as well be the rationals, $t$ may as well be 0.

Because it says so in $\Gamma$, all the substitution instances of the other axioms hold everywhere so we have...

**Corollary 1.** *For every **US/R**-consistent set $\Gamma$ of formulas, there is a temporal structure $M$ such that*

1. *the flow of time of $M$ is the rationals,*
2. *for all $A \in \Gamma$, $M \models A(0)$ and*
3. *all substitution instances of the axioms Prior-U, Prior-S and Sep are valid in $M$.*

## 5 Expressive and Dedekind Completeness

An important technique in our proof is that of switching between the temporal language and an associated first-order one. Let us introduce the concepts and results needed.

We will associate a temporal language with a first-order one called the *monadic* language because it is built from a signature containing only 1-ary predicate symbols along with the binary $<$ predicate symbol. Each atom $p$ in the temporal language corresponds to a predicate symbol $P$. We can make a temporal structure $(T, <, h)$ into a first-order structure in the monadic language, by interpreting $<$ as $<$ and each $P$ as being true of exactly those points in $h(p)$.

If, as will later be the case, we restrict to a temporal language with a finite number of atoms then the monadic signature is finite but otherwise it will contain a countable number of 1-ary predicate symbols.

It turns out, unsurprisingly, that the temporal formula $U(p, q)$ is true at exactly those points in a structure where the monadic formula

$$\psi_{U(p,q)}(t) = \exists s > t(P(s) \wedge \forall u(t < u \wedge u < s \to Q(u)))$$

holds. A simple induction, (see for example [9]), establishes that all temporal formulas $A$ have a corresponding monadic formula $\psi_A$ in one free variable such that, for all structures $(T, <)$, for all valuations $h$, for all $t \in T$,

$$(T, <, h) \models A(t) \quad \text{iff} \quad (T, <, h) \models \psi_A(t).$$

We call $\psi_A$ the *table* of $A$. The induction generalises to show that provided the connectives of the language have first-order tables, as $U$ and $S$ do, then all the temporal formulas of any temporal language have first-order tables.

One may ask whether all first-order formulas with one free variable can be got as tables of temporal formulas. This, of course, depends on the temporal connectives used in the language, but it also depends on what class of structures we restrict attention to. Let us be more precise. Suppose that $\mathcal{S}$ is a class of temporal structures. We say that a temporal language is *expressively complete* over $\mathcal{S}$ if and only if for each monadic formula $\phi(t)$ with one free variable, there is a temporal formula $A$ of the temporal language such that for all $(T, <, h) \in \mathcal{S}$, for all $t \in T$,

$$(T, <, h) \models \phi(t) \quad \text{iff} \quad (T, <, h) \models A(t).$$

Note the uniformity of the translation over the whole of $\mathcal{S}$.

One of the first expressive completeness results was that of Kamp's in [13]. Kamp showed expressive completeness for (the language with) $U$ and $S$ over the class of all structures whose underlying flow of time is Dedekind complete.

As shown in [9], $U$ and $S$ are still expressively complete even if we allow isolated gaps in the structure but as has been known for a while, and as is shown in [9], lemma 3, over the whole class of structures whose underlying flow of time is linear, $U$ and $S$ are not expressively complete. The problem is intimately connected with the possibility of definable gaps. Given a temporal formula $A$, we can define a connective $\gamma^+$ by saying that $\gamma^+(A)$ holds exactly when $A$ remains true for a while after now but only up until a gap after which $A$ is arbitrarily soon false. If $\gamma^+(A)$ is true anywhere we call the indicated gap an $A$ *left gap* and more generally a *definable gap*. Dually there is $\gamma^-$ and *right gaps*.

The connective $\gamma^+$ has a first-order table, in fact it can be defined in terms of $U$ by

$$\gamma^+(A) \leftrightarrow (U(\neg A, \top) \wedge U(A, A) \wedge \neg U(\neg A, A) \wedge \neg U(\neg U(\top, A), A)).$$

We can go on to define the closely related *isolated gap* connective $\gamma_0^+$ by writing $\gamma_0^+(A)$ whenever $\gamma^+(A)$ holds but after the gap $\gamma^+(A)$ doesn't hold for a while. In [9], lemma 3, this is shown to be not expressible in terms of $U$ and $S$ but, as is not hard to do, it can be shown to have a first-order table.

In fact by adding $\gamma_0^+$ and $\gamma_0^-$ to $U$ and $S$ we end up with a language which is expressively complete over the class of all structures with linear flows. However, such a language had been achieved before when the so called Stavi connectives $U'$ and $S'$ were defined in [10]. $U'(A, B)$ holds if $B$ is true from now until a gap in time after which $B$ is arbitrarily soon false but after which $A$ is true for a while: $U'(A, B)$ is as pictured

$$\underset{\text{now}}{\longleftarrow} \quad B \quad \overset{\longleftarrow \cdots}{\underset{\text{a gap}}{\longleftarrow}} \quad \neg B \quad () \quad A$$

$S'$ is defined dually. Despite involving a gap, $U'$ is in fact a first-order connective and its table is given by:

$$U'(p, q) \equiv \exists s\ t < s \wedge \forall u\ (t < u < s \to$$
$$\quad ([\neg \exists v(u < v \wedge \forall w(t < w < v \to q(w)))]$$
$$\quad \vee [\forall w(u < w < s \to p(w)) \wedge \exists v(t < v < u \wedge \neg q(v))]))$$
$$\quad \wedge \exists u[t < u < s \wedge \neg q(u)]$$
$$\quad \wedge \neg \exists u[t < u < s \wedge \forall v(t < v < u \to q(v))]$$

We have

**Theorem 2.** *The language with $\{U, S, U', S'\}$ is expressively complete for the class of structures with linear flow of time.*

This result is mentioned in [10] without proof. The first published proof -- a direct proof -- is in [9]. In [11] is a proof using the separation technique of Gabbay (see [7]).

Obviously there is some connection between definable gaps and our Prior axioms. Call a linear temporal structure a *Prior structure* if it satisfies all substitution instances of Prior-U and Prior-S. It is easy to see that then there are no definable gaps. Note that this result does not hold for the original Prior axioms in the language of $F$ and $P$. It is now not hard to prove the following (see [8], proposition 4.2).

**Theorem 3.** *The language with $U$ and $S$ is expressively complete for the class of Prior structures.*

**Proof.** By the expressive completeness of $\{U, S, U', S'\}$ over all linear structures, it suffices to prove that for any $\{U, S, U', S'\}$-formula $B'$, there is a $\{U, S\}$-formula $B$ such that $B' \leftrightarrow B$ is valid in all Prior structures.

This can be achieved by a simple induction on the construction of such $B'$. The cases of atoms and $\wedge$, $\neg$, $U$ and $S$ are immediate. Let us look at $U'(A, B)$ when, by induction, we can suppose that $A$ and $B$ are $US$-formulas. We claim that $U'(A, B) \leftrightarrow \bot$ is valid in all Prior structures.

Suppose for contradiction that $M \models U'(A, B)(t)$ in some Prior structure $M$. Thus $B$ holds for a while up until a gap after which $\neg B$ is true arbitrarily soon. By Prior-U applied to $B$ we have $M \models U(\neg B \vee K^+(\neg B), B)(t)$ which is the contradiction.

The case of $S'$ is similar. $\blacksquare$
