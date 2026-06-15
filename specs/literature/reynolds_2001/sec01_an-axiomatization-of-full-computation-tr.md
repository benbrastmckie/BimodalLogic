# An Axiomatization of Full Computation Tree Logic

**M. Reynolds**

*The Journal of Symbolic Logic*, Volume 66, Number 3, September 2001, pp. 1011–1057.

**Abstract.** We give a sound and complete axiomatization for the full computation tree logic, CTL\*, of R-generable models. This solves a long standing open problem in branching time temporal logic.

---


## §1. Introduction. CTL*, which is occasionally called full computation tree logic,

was first described in [Emerson and Sistla, 1984] and [Emerson and Halpern, 1986]. 
By using a slightly unusual semantics based on paths through Kripke (or transition) 
structures, CTL* is able to extend, in expressiveness, both the computation tree 
logic, CTL, of [Clarke and Emerson, 1981], a simple branching logic, and the 
standard propositional linear temporal logic, PLTL of [Pnueli, 1977]. 
The language of CTL*, which is a propositional temporal language, is built 
recursively from the atomic propositions using the next X and until U operators 
of PLTL, and the existential path switching operator E of CTL as well as classical 
connectives. This language is appropriate for describing any situation with paths as 
countable sequences of states, the propositions having a truth evaluation at states 
and the possibility of at least some states lying on more than one path. We will be 
interested in the logic obtained by restricting attention to Kripke structures with 
states, a total accessibility relation between them and the set of all paths which arise 
by moving from state to state along the accessibility relation (which is usually called 
R). This standard semantics for CTL* is thus called the semantics over R-generable 
models. 
The main uses of CTL* in computer science are for developing and checking the 
correctness of complex reactive systems. See [Emerson, 1990] for a survey. CTL* is 
also used widely as a framework for comparing other languages more appropriate 
for specific reasoning tasks of this type. See the description in [Emerson, 1996]. 
These include the purely linear and purely branching sub-languages as well as 
languages such as [Bernholtz and Grumberg, 1994] which allow a limited amount 
of interplay between these two aspects. 
Validity of formulas of CTL* is known to be decidable. This was proved in 
- **[Emerson and Sistla, 1984]** using an automata-theoretic approach. Essentially one
Received November 18, 1998; revised March 10, 1999. 
The work was partially supported by EPSRC grants GR/K54946 and GR/L82441. 
Thanks to 
Alberto Zanardo, Colin Stirling, the Logic and Computation Group at Manchester Metropolitan Uni- 
versity and the Algebraic Logic Group at the University of London for helpful discussions. Especial 
thanks to the anonymous referee for very careful reading, many useful suggestions and some serious 
rewrites. 
© 2001, Association for Symbolic Logic
0022-4812/01 
/6603-0002/$5.70 

finds an equivalent Rabin tree automaton to the negation of the formula, i.e. one 
accepting exactly the models of the negated formula, and then tests the automaton 
for emptiness. To get efficient procedures, one is able to exploit a normal form result 
to allow most of the work to be done by procedures for finding linear automata 
equivalents to PLTL formulas. Making use of the specific form of such linear 
automata allowed [Emerson and Jutla, 1988] to describe a decision procedure of 
deterministic double exponential time complexity in the length of the formula. This 
agrees with the lower bound found in [Vardi and Stockmeyer, 1985]. 
Even though a decision procedure exists, and so we know that CTL* is certainly 
recursively axiomatisable, there are still reasons why an explicit and simple axioma- 
tization might be useful and interesting. The immediate CTL* uses of a sound and 
complete axiomatization include providing intuitive axioms for manual proofs, for 
automated proof assistance, and for providing a means of showing completeness of 
other theorem proving methods ( such as tableau or resolution based approaches). 
As pointed out in [Emerson and Sistla, 1984], [Emerson, 1990], [Stirling, 1992] and 
- **[Kaivola, 1996]** , up until now, providing such an axiomatization has remained an
open problem. 
There are some related results in computer science. In [Stirling, 1992], an axiom- 
atization is given for a logic VLTFC which uses the language of CTL* but uses a 
more general semantics. In this logic we may restrict the use of the path quantifier to 
a given subset of all of the paths through a Kripke structure. The only requirements 
are that the chosen set of paths is closed under taking suffixes (i.e. it is suffix closed) 
and is closed under putting together a finite prefix of one path with the suffix of any 
other path such that the prefix ends at the same state as the suffix begins (i.e. the set 
is fusion closed). This logic can also be defined over trees of height ω provided we 
again restrict the path quantifier to a certain set, or bundle, of paths (or branches). 
Thus, in this paper we call this the logic of bundled ω-trees. 
If we restrict this logic by requiring the bundle to contain all the branches of 
the tree, i.e. we consider the completely bundled ω-trees, then the resulting logic is 
standard CTL* again. This restriction is effectively the same as putting an extra 
closure condition on the set of paths which define the semantics of VLTFC. The 
extra restriction is that the set of paths must be limit closed, i.e. if a sequence of 
prefixes of paths from the set is strictly increasing then the path which is the limit 
of the sequence is also in the set. 
These equivalent restrictions 
requiring completeness of the bundle or limit clo- 
sure of the path set 
result in some extra validities and so, to get an axiomatization 
for CTL* we need to add some extra axioms or rules to Stirling's axiomatization 
for VLTFC (i.e. for bundled ω-trees). 
There are other logics in which the extra limit closure condition causes problems 
for axiomatization. In computer science the problem has been solved in the case of 
the less expressive CTL (in [Emerson and Halpern, 1982] and) in [Stirling, 1992] by 
the addition of a simple induction axiom (seen later as example 1 in section 16 here) 
and recently in the case of the much more expressive vCTL* in [Kaivola, 1996] by 
the addition of a limit closure rule. 
In philosophical considerations of branching time, such as in the logics of his- 
torical necessity of [Burgess, 1980], [Zanardo, 1996], the move from bundled trees

to complete trees is also a long standing open problem as far as providing a com- 
plete axiom system is concerned. The language is usually Prior's F and P along 
with a branch-switching modality 0, and the models are much more general trees 
but the problem is very similar. A complete axiom system for the bundled version 
has been given in [Zanardo, 1985]. The problem with completeness is surveyed in 
- **[Zanardo, 1996]** .
The general problem of definability in many of these branching time temporal 
logics is considered in [Dam, 1992] and [Zanardo, Barcellan, and Reynolds, 1999]. 
Here we consider the question of finding formulas whose validity on a frame across 
all possible valuations for the atoms is equivalent to the completeness of the frame. 
In the latter paper it is shown that a simple formula called 6, which looks very much 
like a possible limit closure axiom, defines completeness in the class of all bundled 
ω-trees. In contrast, as shown in the former paper, there is no such formula which 
defines limit closure within the class of all suffix and fusion closed path frames. This 
just shows that (frame) definability is certainly not closely related to axiomatization 
questions. 
In this paper we are able to provide a sound and complete explicit (Hilbert-style) 
axiom system for the standard CTL* logic, i.e. over R-generable models. 
The axiomatization itself provides some interest. There is a new axiom and a new 
rule. The new axiom is, as is probably widely expected, clearly an inductive path 
construction axiom. I call this the limit closure (LC) axiom. It has similarity with 
the limit closure axiom for CTL, the limit closure rule of [Kaivola, 1996] and the 
formula 4 of [Zanardo, Barcellan, and Reynolds, 1999], which defines limit closure 
in the class of all bundled ω-trees. 
The new rule is novel. I call it the Auxiliary Atoms rule (AA). It has some 
affinity with Gabbay's IRR rule [Gabbay, 1981] (for characterizing irreflexivity of 
time in general temporal logics) and generalizations (see, for example, [Gabbay, 
Hodkinson, and Reynolds, 1994]). Like the IRR rule, AA allows the introduction 
of fresh atoms to a proof and allows the interpretation of the fresh atoms to have 
particular properties. Also like the IRR rule, which by design is only generally 
useful when the flow of time is irreflexive, the AA rule is generally only useful when 
the Kripke (transition) frame is a tree. See the proof of lemma 6 for details. Unlike 
the IRR rule which involves one fresh atom, the AA rule allows the simultaneous 
expansion of the language by a possibly large (but finite) number of fresh atoms. 
The assumption we can make about their interpretations is also quite complex, 
although, particularly for automata users, it should be easily able to be applied and 
understood intuitively. Most of the work in stating the conditions of application of 
the rule is done in the side condition and so this is a little complicated. To some 
extent, then, like other IRR-style rules, the AA rule might be regarded as an infinite 
set of rules. However, the side condition is clearly an easily decidable syntactic test 
and so the AA rule is no worse than the common substitution rule of many logics 
(-a rule which, incidentally, is not valid for CTL*). 
The axiomatic completeness proof used here is also interesting. Of course, as 
CTL* is not compact we can only manage a weak completeness result, i.e. showing 
that any given consistent formula is satisfiable in some Kripke structure. We use 
a basic step-by-step filtration style construction but we let a deterministic Rabin

linear automaton loose in the background and we impose an elaborate banning 
mechanism as we go along. 
The basic filtration-like idea is to build a model from sets of formulas maximally 
consistent in some finite closure set determined by the given formula. Certain 
equivalence classes of these sets form the states of the model. The way of defining the 
accessibility relation between states (and hence defining paths) has some similarities 
with the scheduling ideas of the bundled completeness proof in [Stirling, 1992] but 
is more akin to the usual step-by-step construction in historical necessity proofs 
such as [Zanardo, 1985]. Because these latter proofs, and ours, generally use the 
same set of formulas at many different places in the construction we rather think of 
the set of formulas as a label on some abstract point objects. 
The reason that such proofs have trouble with the limit closure condition on 
paths is that, in the limit, the step-by-step construction produces many more paths 
than were ever chosen explicitly to start being constructed at any finite stage. In a 
filtration-based completeness proof we want each of the points of the limit structure 
to model exactly the formulas in its label. However, there is no guarantee that one of 
these non-explicit paths will make a formula A V true at its initial point even if A V is 
in the label of that point. The solution adopted here is to consider a particular linear 
automaton A which can be set loose on each path- whether explicitly constructed 
or not. We make sure that the automaton accepts exactly paths which mess up our 
construction in this way. We also make sure that no paths at all are accepted by A. 
So how do we make sure that no paths are accepted? The answer is as follows. 
We use the AA rule to introduce fresh atoms corresponding to each state of the 
automaton A and we interpret the atoms according to the state that A would be 
in if it traveled to that point of the construction. A is deterministic so there is 
only one such state. The Rabin acceptance condition is defined by a set of pairs 
(WU, Vi) of sets of its states and requires that there is some such pair such that some 
state in Ui comes up infinitely often along the path and no state in Vi does. To 
ensure non-acceptance along each path of our construction, we impose a banning 
mechanism which ensures that atoms from Ui do not come up very often in labels 
of points after it seems that atoms from Vi have stopped being in the labels. 
A linear automaton is also used in an axiomatic completeness proof in [Kesten 
and Pnueli, 1995]. Here, the linear time logic with quantification of propositions is 
axiomatized and the proof uses a back and forth technique involving automata. Of 
course, having quantification of propositions available in the logic makes AA style 
rules unnecessary. 
Another use of a linear automaton is made in [Kaivola, 1996] in which a sound 
and complete axiomatization is given for the extended CTL* logic, vCTL*, which 
allows operators of the linear time mμ-calculus (which is more expressive than 
PLTL) as well as the path operator A. The models are R-generable and so Kaivola 
has the same problem as we have in ensuring limit closure of the constructed 
model. The solution in this case involves the combination of a deterministic Rabin 
automaton (of an even more restricted form) and the transformation of formulas to 
a corresponding normal form. The axiom system, however, needs no new rule apart 
from a new limit closure rule to succeed, because the fixed-point operators in v CTL* 
allow any number of extra propositions with carefully defined interpretations to be 
brought to bear on the proof.

We can also mention that an automaton is used to deal with infinite paths in 
a tableau refutation in [Walukiewicz, 1995] in the proof of completeness for an 
axiom system for the modal μ-calculus. Modal ,μ-calculus, like CTL*, is a logic 
for reasoning about transition structures but it uses fixpoint operators and is more 
expressive. There is no issue of limit closure, however, as infinite paths are only 
definable in the calculus in terms of limits of successor relations. Essentially there 
is limit closure by definition. 
In this paper we first review the linear temporal logic PLTL, its axiom system and 
the result about Rabin automata which we need. After defining CTL* in section 3, 
we look at some of the variant semantics and relate the corresponding logics. In 
section 5, we recall the axiom system for bundled ω-trees and then, in the next two 
sections, introduce our new axiom LC and rule AA. Most of the remainder of the 
paper consists of a fairly detailed presentation of the completeness proof of the full 
system. 
After a few examples of the axiom system in action, we mention a few possible 
extensions to this work and suggestions for how the results or techniques might 
have other applications. One important question is whether the AA rule is really 
necessary. Another is whether it, along with the use of an automaton, could have 
benefits in finding complete axiomatizations of other similar logics. 

### 1.1. General notation. A sequence will usually mean an ω-sequence (so, S,...)

(unless otherwise specified). If J = (sO, SI, S2,...) 
is a sequence (of anything) then 
we will refer to Si as as and the suffix sequence (si, Si+l, 
Si+2.... 
) as u>i. The set of 
all consequences of objects from a set S will be denoted by 'OS. 
The set of all finite sequences of objects from a set S will be denoted by '"S. 
The set of all subsets of a set S will be denoted p(S). 
If A C C and a c w(p(C)) then the restriction CgA of a to A is the sequence 
(po n A, 1 n A,... ) from w(p(A)). 

## §2. Propositional linear temporal logic. Much of the work in the completeness

proof is done by reasoning along branches of trees so we review the linear temporal 
logic PLTL. 
We fix a countable set 2 of atomic propositions. Formulas are evaluated in 
ω-structure in the signature 2. 
An ω-structure a = (Co, Cl,... ) is a countable 
sequence of subsets of Y where p E 0i represents the atom p being true at time i in 
the structure. 
The formulas of PLTL are built from true and the atomic propositions in 2 
recursively using classical connectives 
and A as well as the temporal connectives 
X and U: if a and ,6 are formulas then so are X a and a U /. 
Truth of formulas is evaluated at ω-structure. We write C l= a iff the formula a 
is true of the sequence C. This is defined formally recursively by: 
a = true 
C 
P 
iff peCo,anyp-c2 