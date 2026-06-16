### Since and Until

Our discussion in the previous section was based on the basic temporal language having $G$ and $H$ as its only primitive operators. For many applications, however, this language is too poor in expressivity, and several extensions with new operators have been suggested. The most important of these are the dyadic operators $S$ and $U$ introduced by H. Kamp; their intended meaning is respectively 'since' and 'until', as in the sentences 'Ever since the roof caved in, it's been wet in the house' and 'Until we get the roof fixed, it will be damp in the house'. Let $\mathcal{L}_{su}$ denote the extension of the Priorean language with these two new connectives, the formal truth definition of which is given as follows.

$$
\begin{aligned}
\mathcal{M}, t \Vdash U\varphi\psi \quad &\text{if} \quad \mathcal{M}, s \Vdash \varphi \text{ for some } s \text{ such that } t < s \\
&\quad \text{and } \mathcal{M}, u \Vdash \psi \text{ for all } u \text{ with } t < u < s, \\
\mathcal{M}, t \Vdash S\varphi\psi \quad &\text{if} \quad \mathcal{M}, s \Vdash \varphi \text{ for some } s \text{ such that } s < t \\
&\quad \text{and } \mathcal{M}, u \Vdash \psi \text{ for all } u \text{ with } s < u < t.
\end{aligned}
$$

It is interesting to observe that the 'old' operators can be expressed in this new language, for instance $F\varphi$ may be seen to abbreviate $U\varphi\top$. But conversely, the new operators really add expressive power to the language; we can prove that they cannot be defined in terms of the old.

Another interesting temporal operator is the so-called *nexttime* or *tomorrow* operator $X$; the formula $X\varphi$ holds at a time point $t$ if $\varphi$ holds at the next moment in time (if there is such a next moment). Obviously, such an operator only makes sense in a discrete flow of time, as, for instance, in computer science, where one wants to talk about the next state of a process. However, adding this new connective to $\mathcal{L}_{su}$ would not add any expressive power, since $X\varphi$ can already be defined as an abbreviation for $U\varphi\bot$.

This raises the question whether perhaps *every* temporal operator can be defined in this apparently expressive language $\mathcal{L}_{su}$. The answer to this question is positive; that is, we can prove some sort of *functional completeness* result for $\mathcal{L}_{su}$.

**Theorem 4.1 (Kamp)** *Over the class of linear, continuous orderings, every temporal operator can be defined in $\mathcal{L}_{su}$.*

where by 'temporal operator' we mean any operator whose truth definition is expressible in first order logic. The restriction in the theorem to certain flows of time is essential. In particular, once we drop the condition of linearity, the results tend to be negative; for instance, over the class of all flows of time we cannot find a *finite* expressively complete set of operators.

Finally, for the language $\mathcal{L}_{su}$ one can ask the same kind of questions as for $\mathcal{L}_t$; and indeed, several results have been proved concerning definability, axiomatizability and decidability. In general these results are positive, but for lack of space we cannot go into detail here.

### Branching Time Languages

As mentioned above, allowing flows of time that branch to the future means that we can no longer assume that the past determines everything that is going to happen. But if our formalism has to take into account that there are many *different* courses of events possible, it seems appropriate to pay somewhat more attention to the truth definition of our future operator $F$. For, the intuitive meaning of $F\varphi$, namely 'it will be the case that $\varphi$', is now more ambiguous than in linear flows of time. Recall that the interpretation of $F\varphi$ that we may calculate from the truth definition (1) yields '$\varphi$ holds at some future moment of some possible course of events'. But it does not seem to be unreasonable to assume that 'it will be the case that $\varphi$' expresses the speaker's conviction that $\varphi$ will be the case, in the *actual* course of events, or perhaps *no matter what* course of events. These two interpretations give rise to respectively the Ockhamist and Peircean schools in branching time logic.

In order to compare these two approaches, assume our flows of time to be *trees*, that is, connected strict partial orders that do not branch to the past. (Connectedness forbids for instance parallel time lines.) A *branch* of a tree $\mathcal{T} = (T, <)$ is a maximal linearly ordered subset of $T$; the intuitive idea is that each branch through $t$ represents a possible course of events (for a point $t$ and a branch $b$, we say that *$t$ lies on $b$* or that *$b$ goes through $t$* if $t$ belongs to $b$). In this way, we can imagine a *possible future* of $t$ as the set of all *later* points on some fixed branch $b$ through $t$; since $\mathcal{T}$ is a tree, each point will have a unique past.

Now Peircean branching time logic interprets the proposition 'it will be the case that $\varphi$' in the second way indicated above, namely that $\varphi$ is bound to happen in every possible future. To make this more precise, define the Peircean tense language as the extension of the Priorean one with the future operator $F_\Box$; this operator has a second order definition, involving a quantification over all branches through the actual time point:

$\mathcal{M}, t \Vdash F_\Box\varphi$ if on each branch through $t$ there is some $s > t$ with $\mathcal{M}, s \Vdash \varphi$. (4)

In the Ockhamist approach on the other hand, it is *meaningless* to ask about the truth value of formulas of the form $F\varphi$ or $G\varphi$ at a time point $t$, unless we have specified which of the possible futures of $t$ we have in mind. In order to be able to express that something that will be the case no matter what form the future will take, Ockhamists extend the language with an alethic modal operator $\Box$. Ockhamist tense logic is thus an interesting combination of modal and tense logic; perhaps the easiest way to work out the idea formally, is to require that in Ockhamist semantics the truth value of *any* formula is evaluated at a *pair* consisting of a time point and a branch through this point (representing the actual course of events). We thus arrive at the following truth definition.

$$
\begin{aligned}
\mathcal{M}, t, b \Vdash q &\quad \text{if} \quad \pi(t)(q) = 1, \\
\mathcal{M}, t, b \Vdash \lnot\varphi &\quad \text{if} \quad \text{not } \mathcal{M}, t, b \Vdash \varphi, \\
\mathcal{M}, t, b \Vdash \varphi \land \psi &\quad \text{if} \quad \mathcal{M}, t, b \Vdash \varphi \text{ and } \mathcal{M}, t, b \Vdash \psi, \\
\mathcal{M}, t, b \Vdash G\varphi &\quad \text{if} \quad \mathcal{M}, s, b \Vdash \varphi \text{ for all } s \text{ on } b \text{ with } t < s, \\
\mathcal{M}, t, b \Vdash H\varphi &\quad \text{if} \quad \mathcal{M}, s, b \Vdash \varphi \text{ for all } s \text{ on } b \text{ with } t > s, \\
\mathcal{M}, t, b \Vdash \Box\varphi &\quad \text{if} \quad \mathcal{M}, t, c \Vdash \varphi \text{ for all branches } c \text{ through } t.
\end{aligned}
\tag{5}
$$

It is interesting to note that the Peircean language can be seen as a *fragment* of the Ockhamist one; consider the inductively defined translation $(\cdot)^o$ mapping Peircean formulas to Ockhamist ones. The only non-trivial clause of this map concerns the future operators: $(F_\Box\varphi)^o = \Box F\varphi^o$ and $(G\varphi)^o = \Box G\varphi^o$. It is straightforward to prove that for all tree models $\mathcal{M}$, all points $t$ in $\mathcal{M}$ and all branches $b$ through $t$, we have that

$$
\mathcal{M}, t \Vdash \varphi \text{ iff } \mathcal{M}, t, b \Vdash \varphi^o.
$$

Many results are known concerning Peircean and Ockhamist logic; for instance, axiomatizations have been found for the Peircean logic of the class of all trees. This logic is also known to be decidable, as is its Ockhamist alternative. It is an outstanding open problem to find an explicit axiomatization for the Ockhamist tree logic.

Finally, it is obvious that one can extend these branching time logics even further, for instance with the Since and Until operators defined earlier. The 'future fragment' of such systems is closely related to so-called *computational tree logics* that have been developed within theoretical computer science for the purpose of reasoning about paths through labeled transition systems, which in their turn form perhaps the simplest mathematical models of the notion of computation. It is interesting to note that the Peircean and the Ockhamist approaches in philosophical logic find (much more technically inspired) counterparts in the development of the computational tree logics: CTL and CTL\*, respectively.

## 5 Time Periods

So far we have applied a point-based paradigm to represent time. Nevertheless, it seems that in every field where temporal logics are used or studied, at a certain moment systems are designed in which *periods* are the central entities, or at least, play a more prominent role.

### Motivations

The point-based perspective has never been without philosophical objections. For instance, Zeno's paradox of the flying arrow, which, it is argued, cannot change position at a isolated moment of time and thus cannot move at all, makes it clear that there is something problematic concerning the representation of time as a series of durationless moments if we want to describe the concept of movement. Some temporal predicates seem simply not to apply to time points. Suppose that $p$ is a proposition formalizing the statement that Zeno's arrow moves. Obviously, the flying of an arrow is an activity that is extended in time; hence, one might argue that it is pointless to evaluate the truth of $p$ at moments of time. It thus seems that we at least need the existence of time periods for the evaluation of certain expressions.

Apart from such semantic considerations, it is clear that time points are not the kind of objects that we can directly perceive. Due to years of exposure to the scientific view on time we may not always realize this, but if we want to base reality on our direct experience, then time points will come out as highly abstract and complex artifacts. Thus, it has been argued, it is a dubious enterprise to take points as having primitive ontological status; periods form a far sounder base. This second argument has been taken up, with a more practical twist, within Artificial Intelligence. Here the idea has been advocated that period-based representations of time are simpler and more natural in formalizing common sense reasoning than the standard scientific models. (Obviously, this argument may be pushed further, questioning the Newtonian perspective in which absolute Time exists regardless of anything happening in it. Such objections may lead to *event-based* ontologies which due to lack of space we cannot discuss here.)

Finally, in our discussion until now we have assumed that there is a clear and intuitive distinction between points and periods. This is questionable as well, however; one can quite convincingly argue that there is a notion of *granularity* involved here. A good example can be taken from Computer Science, where the addition of two numbers may be taken as an atomic, durationless action of a high-level programming language, whereas it may be implemented in terms of many operations on the lower level of the machine language.

### Time in Periods

It is important to observe that the need for a more prominent role of periods does not necessarily commit one to model time in structures in which periods are *primitive* entities; they might as well be *derived* objects.

Indeed, one could well start from a flow of time $\mathcal{T} = (T, <)$ as described earlier, and then consider the question how to represent chunks of time within such a structure. For instance, periods could be defined as *convex sets*: subsets $C$ of $T$ that are uninterrupted in the sense that whenever $s$ and a later point $t$ belong to $C$, then so does any point between $s$ and $t$. A set-theoretically slightly simpler option is to only consider (closed) intervals; in this approach, the period $\{u \in T \mid s \leq u \leq t\}$ can simply be represented as the *pair* $[s, t]$. Observe that this approach has the advantage that properties of periods can be expressed by binary predicates in the first order frame language, whereas for convex sets we have to use some kind of higher-order logic.

If one opts for periods as primitive entities, the simplest mathematical modeling will involve structures consisting of a set $P$ of periods equipped with a collection of natural relations on $P$. But in contrast to the point-based approach where the temporal precedence relation is *the* candidate for such a relation, we now have many options. For instance, since one is obviously still interested in temporal precedence, the relation $\prec$, with $p \prec q$ holding if the entire period $p$ precedes the entire period $q$, is a natural candidate, but so is the inclusion relation $\sqsubset$, with $p \sqsubset q$ holding if $p$ is a proper part of $q$. And in fact, one widespread period-based modeling of time is that in structures of the form $\mathcal{P} = (P, \prec, \sqsubset)$. But $\prec$ and $\sqsubset$ are not the only candidates. If we are interested in relations that are close to our common sense experience, then the relation of one period overlapping with another is quite relevant as well. And we are not confined to binary relations at all: we may need a unary predicate informing us whether a period is of zero duration (and hence, point-like), whereas there are also interesting ternary relation such as the relation $C$ holding of a triple $p$, $q$, $r$ if $p$ can be 'chopped' into the two pieces $q$ and $r$. Of course, just like in the point-based case, one needs to impose conditions on period structures to make them useful as models of time. For instance, in a structure of the kind $\mathcal{P} = (P, \prec, \sqsubset)$ one will want $\prec$ and $\sqsubset$ to be strict partial orders that are related by conditions like $\forall xyz\,(x \sqsubset y \prec z \to x \prec z)$ and others.

The reader may have realized how hard it is to gather one's intuitions and make a complete list of such conditions without taking resort to talking about points after all. The concept of a point in time has obviously been very useful in our thinking about time. Hence, even if periods are to be taken as the primitive entities of one's ontology, it is at least interesting, if not a test for the viability of the proposal, to see whether one can *construct* point-based flows of time from period structures. Various ways have been worked out for this purpose. Perhaps the simplest method is to take as points those periods that have zero duration --- of course, this only works if such entities are around and we have access to this information (for instance, through a zero-duration predicate as we mentioned above). But even if our period structure does not have atomic periods, there are ways to extract a point structure from it, for instance, by defining a point to be any maximal set of mutually overlapping pairs of periods. Finally, once there are ways to construct point structures from period structures and vice versa, the obvious question is to see how such constructions interact. This line of research has been taken up with great mathematical sophistication, in a number of cases even leading to interesting categorical dualities.
