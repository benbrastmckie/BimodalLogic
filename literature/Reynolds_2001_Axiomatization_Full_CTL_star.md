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
# ¬a 
iff u 
a 
Cl 
a A, 
iff C 
a and Cl= 
C#Xa 
if 
C>1ia 
C #a 
U/ 
iff thereis some i > 0 such that u>i #= 
and for each j, if 0 < j < i then C>j 1= a

If - l= a then we say that u is a model of ao. If a has a model then we say that 
a is satisfiable. If u l= a for any ω-structure u then we say that a is valid in PLTL 
and we write ⊨_L a. 
As well as the usual abbreviations V, -) and ↔ , we have Fa _ true U a and 
Ga _-F--ia. 
Complete axiom systems exists in various versions in the literature. The one we 
present here will be incorporated into our branching-time system. The rules are 
modus ponens and temporal generalization, 
a, a 
a 
/A 
Gax 
The axioms are all substitution instances of the following: 
CO any propositional tautology 
Cl 
F -, - a <-Fa 
C2 G (a -- PS) -- (Gt -- GPS) 
C3 Ga- 
(aAXaAX(Ga)) 
C4 X-ow 
a---Xa 
C5 X (a 
P) --) (Xo a 
X,8) 
C6 G (a 
X a) -*(ja 
G a) 
C7 (a UP) 
(1 V (a A X(a UIP)) 
C8 (a U/3) 
F/3 
We define derivability ⊢_L in the usual way and say that a formula a is consistent 
if we do not have ⊢_L a - false. 
Note that the original system in [Gabbay, Pnueli, Shelah, and Stavi, 1980] used 
axioms rather than substitution instances of axiom schemas and so also included 
the substitution rule. We will avoid the substitution rule in this paper as it is not 
valid for CTL*. 
In [Gabbay, Pnueli, Shelah, and Stavi, 1980], it was proved that 

**Theorem 1.** *The system above issound and completefor PLTL: i.e. K a if ⊨_L a.*

Soundness is established by the usual induction on the length of proofs. The 
vaguely filtration-based completeness proof, with a novel fair scheduling idea, is 
interesting and some of its elements appear in our branching-time completeness 
proof. 

### 2.1. Automata. Suppose that P is a finite set of propositional atoms. A de-

terministic (Rabin) automaton recognizing ω-sequences from p(P) is a 4-tuple 
A 
(Q.so, p, L) where 
* Q is a finite non-empty set called the set of states, 
* so 
Q is the initial state, 
* p: Q x p(P) -) Q is the transition function and 
* the finite set L C (p(Q) x p(Q)) is the set of accepting pairs. 
A run of A on an ω-structure u in the signature P is a sequence of states 
So, SI, S2, . . . from Q such that for each i < crn p(si, ui) = Si+1. 
We say that the Rabin automaton A = (Q, so, p, L) accepts u if there is some 
run SO, sI, .2 ... 
on u and some pair (U, V) c L such that no state in V is visited 
infinitely often but there is some state in U visited infinitely often. It is clear that we 
may assume that for each pair (U, V) we have U n V = 0: just replace each original

U by U' = U \ V. Note that a deterministic automaton will have a unique run on 
any given structure. 
We will be wanting to translate a temporal formula into an equivalent automaton: 
i.e. one that accepts exactly the models of the formula. Various well-known results 
including those in [McNaughton, 1966], and [Safra, 1988] give us: 

**Theorem 2.** *For any PLTL formula a using atoms from the finite set P there is a*

deterministic Rabin automaton (Q, so, p, {(Ul, V,), . . ., (Uk, Vk)}) which recognizes 
ω-sequences of elements of p(P) and accepts exactly the models of a. 

## §3. CTL*. The language of CTL* is used to describe several different types of

structures and so there are really several different logics here. We will be mostly 
interested in the logic of R-generable sets of paths on transition structures, which 
we will call Kripke structures. In most papers it is this logic which is referred to as 
CTL*: this is the standard CTL* logic. In the next section we briefly look at some 
other semantics for the language as we need to use some of them in the axiomatic 
completeness proof. 
We fix a countable set 2 of atomic propositions. 

**Definition 1.** For us a Kripke frame is a pair (S, R) where:

S 
is the non-empty set of states 
R is a total binary relation C S x S 
(i.e. for every s c S, there is some t c S such that (s, t) E R) 
Note that usually in modal logic a Kripke frame's accessibility relation R is not 
necessarily assumed to be total. 
Formulas are evaluated in (Kripke) structures: 

**Definition 2.** A structure is a triple M = (S, R, g) where:

(S, R) 
is a Kripke frame 
g 
: S -? p(Y) is a labelling of the states with sets of atoms 
Such structures are often called transition structures. 
Afullpath in M (or in (S, R)) is an infinite sequence so, S1, S2,. ..of 
states of M 
such that for each i, (si, si+i) c R. For the fullpath b = So, 
Si, S, 
and any 
i > 0 we write bi for the state si and b>j for the fullpath Si, Si+1, 
Si+2, 
The formulas of CTL* are built from true and the atomic propositions in 2 
recursively using classical connectives 
and A as well as the temporal connectives 
X, U and E: if a and ,6 are formulas then so are X a, a U / and E a. As well as 
the linear abbreviations, V, -, 
A, F and G, we have A a 
E ¬a. 
We shall write V < q if V is a subformula of b. If S is a finite set of formulas, 
define A S 
al A ... A an, 
after enumerating S = {a 
, 
an} 
in some particular 
order. 
Truth of formulas is evaluated at fullpaths in structures. We write M, b l= a iff 
the formula a is true of the fullpath b in the structure M = (S, R, g). This is defined 
formally recursively by:

M, b l true 
M, b 
p 
iff pEg(bo),anypcE2 
M,b #-a 
iff Mb p=a 
M,b 
a AA/ 
iff M,b ta 
and M,b t/A 
M,b 
Xa 
if 
M, b>1 i= a 
M,b 
a U/p 
if 
there is some i > 0 suchthatM, b>i tA 
and for each j, if 0 < j < i then M, b?j t a 
M, b 

∎

F a 
if 
there is some fullpath b' such that bo b= and M, b' 
a a 
We say that a is valid in CTL* if for all Kripke structures M, for all fullpaths b 
in M, we have M, b t a. Let us write tZC a in that case. The C in ⊨_C can stand 
for CTL* or, as we shall see, for complete. 
We say that a is satisfiable in CTL* if for some Kripke structure M and for some 
fullpath b in M, we have M, b tc a. Clearly a is satisfiable in a Kripke structure if 
c -a. 
Some presentations of CTL* proceed via the definition of a certain subset of the 
formulas which only depend, for their truth, on an evaluation point rather than 
fullpath. We can make some use of these formulas. Call a formula a state formula 
if it is a boolean combination of atoms and formulas of the form E P. It is easy to 
show that 

**Lemma 1.** *If a is a state formula and b and b' are fullpaths with bo b= then*

M,b tz a iffM,b' t a. 
In the case of a being a state formula we can thus write M, x 
a a to mean that 
for some, or equivalently all, fullpaths b with bo = x, we have M, b t a. 

## §4. Other semantics. There are other semantics for the formulas of CTL*. Sev-

eral are worth introducing as they are used in the proof or cast light on the issues. 
In the end we will see that there really are only two distinct notions of validity of 
interest to us here. 

### 4.1. Path structures. One of the most general semantics is on what I will call

path frames. A pair (S, II) is a path frame if S is a set (of states) and II is 
any set of paths, i.e. of ω-sequences from S. Three closure properties are often 
assumed of the set II of paths. We will assume two: Suffix Closure (SC), i.e. that 
H- is closed under taking suffixes of paths; and Fusion Closure (FC), i.e. that 
the beginning of one path (in II) can be joined at a common state to the tail of 
another path (in II) and the result is in II. A path structure is (S, II, g) where 
(S, LI) is a path frame and g: S -) p (2) is a labelling. We will say that the 
structure is an SC + FC path structure iff the set of paths LI is suffix and fusion 
closed. 
We can give the formulas of CTL* a new semantics by defining truth of formulas 
on paths from SC + FC path structures in the obvious way: temporal connectives 
are evaluated along paths while E allows switching to the same state on another 
path containing the current state. We define SC + FC path validity by saying ⊨_B a 
iff (S, II, g), ? t 
a for all SC + FC path structures (S, HI, g) and all paths 7r c H. 
We will see later that the B in ⊨_B stands for bundle.


### 4.2. R-generable validity. Various computing concerns to do with applications

for CTL* (including the desire to reason explicitly about fairness constraints) mo- 
tivate us to restrict our attention further to certain classes of path frames: in par- 
ticular, we can require the other closure property of interest, Limit Closure (LC), 
i.e. that if for any n, a path ? agrees up to its nth state with a path in H` then 7E itself 
is in H. 
The conjunction of all three closure properties is interesting because, as shown 
by Emerson in [Emerson, 1983], this is equivalent to HI being the set of all fullpaths 
in some Kripke frame (S, R). In the case that II is the set of all paths, we say that it 
is R-generable. We thus can talk of R-generable validity of CTL* formulas: i.e. a 
is R-generable valid iff, for all path frames (S, H) in which HI is R-generable, for all 
labellings g, for all 7T E II, we have (S, HI, g), 2 ;= a. 

### 4.3. Trees. It has been observed, for example in [Emerson and Sistla, 1984], that

it is sometimes useful to consider satisfiability of CTL* formulas in special tree-like 
structures. Indeed, we find it so in this paper. Let us define an ω-tree (frame) 
to be a pair (T, <) where < is transitive and irreflexive, for each t E T, the past 
{s c TIs < t} of t is linearly ordered by <, there is a <-smallest element and each 
maximal linearly <-ordered subset of T is order-isomorphic to the natural numbers. 
In an ω-tree each point t will have a non-empty set Nt of immediate successors, 
and the future {s It < s } is the disjoint union of Nt and the futures of each of the 
elements of Nt. A branch of an r-)-tree frame is an cr-sequence (to, t .... ) such that 
each ti+1 is an immediate successor of ti. 

### 4.4. Bundled tree validity. A set B of branches on an ω-tree frame (T, <) is a

bundle iff every point t c T lies on at least one branch in B and the set B is suffix 
closed and also closed under superbranches, i.e. if b is a branch of (T, <) and for 
some n, b>n c B then b c B. Say that (T, <, B) is a bundled ω-tree frame. We 
give the formulas of CTL* the bundled semantics on bundled ω-tree structures 
(T, <, B, g). Truth is defined recursively at branches 7r c B in a straightforward 
way with the clauses for atoms using the labelling g at the initial point of the branch 
and the temporal connectives directed along the branch. The clause for E is as 
follows: 
(T, <, B, g), 7c FE a 
if 
there is some ' e B such that 7o = zr and 
(T, <,B, g), 7r' 
a 
We thus have a notion of bundled ω-tree validity. 

### 4.5. Complete tree validity. Let B(T, <) be the set of all branches of the ω-tree

(T, <). In case that the bundle B is just B(T, <) then we talk of complete con- 
tree frames and complete ω-tree validity, or sometimes just ω-tree validity. Write 
(T. <,g), i 
a for (T, <,B(T, <),g), 7 
a. 

### 4.6. Ockhamist frames. In our completeness proof we will make use of yet an-

other semantics. 

**Definition 3.** A (floored) Ockhamist frame (of countable height) is (T. <,-)

where: 
1) T is the set of points; 
2) < is transitive, anti-symmetric, irreflexive order satisfying 
Vxyz(x < y A x < z -) (y < z V y = z V z < y)) and

hi 
dl 
e2 
g4 
bl 
b2 
c3 -_ 
c4 
al- 
a2 
a3 
a4 

*Figure 1. An Ockhamist frame*

Vxyz(y < x Az < x -) (y < z V y 
z V z < y)) 
(that is, < is a strict linear order which may have parallel lines but may not 
have branching); 
3) for each x c T, {yIy < x} is finite; 
4) _ is an equivalence relation such that: 
if x 
y then we do not have x < y 
if x 
y and u < x then there is v < y such that u _ v; and 
5) there is an element 0 c T, such that for each t c T, 
there is t' c T such that 0 _ t' and either t' < t or t' = t 
(0/_ is known as the floor). 
Our use of the word Ockhamist here derives from its use in a more general 
(not necessarily countable) setting in [Zanardo, 1996]. Such Ockhamist frames 
are closely related to the Kamp frames seen in [Thomason, 1984]. In this paper 
we will later find it useful to think of the points in T as being arranged in an 
imperfect two-dimensional grid with < increasing vertically and _ relating some 
of the points on each horizontal level. Figure 1 portrays a very simple exam- 
ple. As we will see below, when we consider the semantics of CTL* formulas on 
Ockhamist frames, a state in a Kripke or path based structure corresponds to a 
whole =-class of Ockhamist points and a path corresponds to a vertical line of 
points.

I 
d 
e 
g 
b 
c 
a 

*Figure 2. The corresponding tree*

Despite using an Ockhamist frame in our completeness proof construction we 
do not actually use any notion of Ockhamist validity or even of truth of CTL* 
formulas on Ockhamist frames. However, both notions can be developed and it is 
worth doing so to aid with understanding the proof. First we need to impose extra 
restrictions on the frames and labellings of points. 
The vertical lines of points need to be isomorphic to the whole natural numbers. 
Say that the Ockhamist frame (T, <, _) is an (N x W)-frame if 
(1) there is some set W such that T = N x W and 
(2) the order < is defined by (n, u) < (m, v) iff n < m and u = v. 
We also need to require that labels of all points in any --class agree on the 
atoms. Say that the structure (T, <,-, g) is an (N x W)-structure iff (T, <,-=) is 
an (N x W)-frame and for all n c N, for all u, v c W, if (n, u) _ (n, v) then 
g(n, u) = g(n, v). 
Truth in Ockhamist structures is a more traditional modal logic concept as formu- 
las are evaluated at points (rather than at states on paths). We define truth by having 
the temporal connectives operate vertically upwards and E allow a horizontal move 
within an --class. For example, 
(T,<, 
,g),(n,u) 
X a 
iff (T,<, 
,g),(n+ 
1,u) = a, and 
(T <,¬g), 
(n, u) 
E a 
iff there is some v c W with (n,u) -(n, v) and 
(T, <,=,g), 
(n, v) c a.

Corresponding to each (N x W)-structure is a bundled ω-tree structure. We sim- 
ply take the nodes of the tree to be the equivalence classes, define successors using < 
and let the bundle contain each branch of the form up(n, w) = {(m, w)/_In < m} 
for each (n, w) c T. Figure 2 shows the tree corresponding to the frame in figure 1; 
the bundle contains all suffixes of the four maximal branches shown. In particular 
note that a point in an Ockhamist frame corresponds to the combined notion of 
a state on a path. This correspondence preserves truth of CTL* formulas in the 
obvious way. 
With such an Ockhamist semantics we can define a notion of what might be called 
(N x W)-Ockhamist validity on (N x W)-structures. In lemma 2 below we show 
(using the correspondence) that this notion of validity is just bundled validity. 
However, to find an Ockhamist version of the notion of validity identified in 
lemma 3 below requires a complicated extra restriction of the frame in a similar 
vein to the limit closure property. We omit this as we do not use either of these 
definitions of validity anyway. 

### 4.7. Equivalence results. There are two equivalence results which are useful for

relating some of the semantic approaches to CTL*. The proofs are straightforward. 

**Lemma 2.** *The following are equivalent:*

a) ⊨_B validity i.e. SC + FC path frame validity; 
b) bundled ω-tree validity; 
c) (N x W)-Ockhamist validity. 
The following equivalence result is of vital importance to the proof of soundness 
of our axiom system for ⊨_C. It follows from results in [Emerson and Sistla, 1984]. 

**Lemma 3.** *The following are equivalent:*

a) =c validity i.e. Kripke validity 
b) suffix,fusion and limit closedpath frame validity 
c) R-generable path frame validity 
d) complete ω-tree validity 
Note that the equivalence between a) and d) follows from a particularly close 
relationship between Kripke frames and ω-trees: a tree is just a Kripke frame with 
the accessibility relation defined in terms of immediate successors while a tree can 
be produced by unraveling the fullpaths on a given Kripke frame. 

### 4.8. An inequivalence result. We now show that ⊨_B and =c are distinct notions

of validity. 
Note that for complete ω-trees we have ⊨_C y where y = A G(p -* EX p) 
> 
(p -* E G p). 
However, this is not valid on bundled trees. To see this, in a slightly indirect way, 
consider the (N x W)-frame shown in figure 3 in which W = N and (n, u) -(m, v) if 
either (n,u) = (m, v) orn = m andbothn < u andn < v. Supposethatp E g(n, u) 
iffn < u. It is clear that we have (T, <,--, g), (0, 0) = A G(p -* E X p) A p A A F -p 
and so V=B Y. 
It is very interesting to also consider the bundled ω-tree corresponding to this 
Ockhamist structure. Take T = {(n,m) c N x NIn < m}. Put (a,b) < (c,d) 
iff(a = c and b < d) or a = b < c. Let D = {(n, n)In c N} E B(T, <) and define

-I 
-PI 
PI 
P I 
o 
0 
0 
_ 
_ 
-IP 
¬PI 
if 
__ 
o 
0 
0 
0 
__0_ 
--lpl-, 
IP 
1 
I 
__ 
P t I 
_ 
P t I 
_ 
o 
0 
_ 
_ 
0 
_ 
-PtI 
P_ 
P I 
P I 
o 
0 
__ 
0 
__ 
0 
__ 
0 
_ 
P tI 
_ _ 
P t 
___ 
P t 
___ 
P t 
___ 
P t 
___ 
o 
0 
0 
0 
0 
etc. 

*Figure 3. The Ockhamist Counter-example*

the bundle to be B = B(T, <) \ {D}. Finally define g so that (n, m) E g(p) iff 
n = m. See figure 4. Of course we have (T, <,B, g), (0,0) t 
-y as well. 
m 
P 
P 
P 
P 
P 
n 

*Figure 4. The Counter-example, tree-style*


### 4.9. Emergent branches. As well as establishing the inequivalence Of ⊨_B

and 
oc, this example also gives a good illustration of the idea of an emergent branch 
appearing from an Ockhamist construction. In particular note that the branch

D in the ω-tree does not correspond to any set up(n, w) in the Ockhamist frame. 
It is not in the bundle defined in the correspondence. In general converting an 
Ockhamist frame, even with a countable set W, to an ω-tree can produce a possibly 
uncountable number of such emergent branches. This fact will cause us a major 
difficulty in the completeness proof: we can make sure all the constructed branches 
satisfy a desired property at all finite stages of the construction of an Ockhamist 
frame but then discover a large number of extra branches emerge when we take the 
limit. We will need extra machinery to make sure that these emergent branches 
satisfy the desired property. 
In terms of Kripke structures the fact(problem) of emergent branches is seen here 
by viewing the ω-tree (T, <) as a Kripke structure (T, R, g) where (n, m)R(n, m + 1) 
and (n, n)R(n + 1, n + 1). This is just the Kripke structure we get by defining R in 
terms of immediate <-successors as we need to do in lemma 3. It is clear that we 
have a fullpath ((0, 0), (1, 1), (2, 2).... ) which is not in the bundle which is defined 
by the Ockhamist frame. The fullpath is emergent. 

## §5. The axiom system for bundled trees. Axioms for bundled validity will form

part of our final axiom system. Consider a system for bundled validity. The 
inference rules are modus ponens and temporal and path generalization: 
a, a-fi 
a 
a 
fi 
Ga 
A a' 
The axiom schemes include the usual ones for PLTL (as seen earlier): plus axioms 
ensuring that the path modality A behaves as in the modal logic S5 
C9 A(a- *fi) --(Aa 
--Af) 
CIO Aa--*AAa 
Cli 
A a- +a 
C12 a - 
AEa 
C13 A -a <--, Ea 
plus propositional atoms only depend on states 
C14 
p -* A p, for each atomic proposition p 
plus some interaction between modalities 
C15 A Xa- *XA a 
We define derivability ⊢_B using this system in the usual way. 
Note that we do not use a substitution rule as it is not valid for ⊨_B. 
For example 
tB 
(E p -* p) is valid for each atomic proposition p (and can be derived easily) 
but FrB (E a -- a ) is not generally valid. 
We could show that 

**Lemma 4** ([Stirling, 1992])**.** *⊢_B is sound and (weakly) complete for ⊨_B-*

Soundness is the usual straightforward induction on the lengths of proofs. Com- 
pleteness (for an equivalent but slightly different set of axioms) is shown in [Stir- 
ling, 1992] by building a SC+FC path structure. In what is actually quite a similar 
technique, despite appearances, one could also use a step by step method via Ock- 
hamist frames to produce a bundled ω-tree structure. This style of proof is seen in 
proofs by Burgess, Zanardo and von Kutschera for logics of historical necessity. In 
fact, this method forms the basis for our ⊨_C completeness proof later in the paper.

By removing most of the machinery associated with the automaton and the banning 
procedure, we would be left with a completeness proof for [-B. 
Note that the example y from the previous section shows that the system for H-B 
is incomplete for ⊨_C. 
Of course, this system is sound for ⊨_C. 
In the next two 
sections we introduce a new axiom and new rules of inference to allow us to derive 
the extra validities. 

## §6. The limit closure axiom. Intuitively, the new limit closure (LC) axiom schema

captures a particular form of limit closure. Suppose that some state formula E a, 
say, is always (at all points on all branches) at the start of a finite path of E fi states 
leading up to a new E a state. Also suppose that E a holds at some node. Then it 
is clear that from that node extends a branch on which (E f) U(E a) always holds. 
LC: 
A G(E a - 
EX((E/3) 
U(E a))) 
-* 
(Ea 
-* E G((Efi) U(Ea))) 

**Lemma 5.** *The LC axiom schema is soundfor ⊨_C.*

PROOF. Suppose that (T, <, V) is a (complete) ω-tree structure with a node to c T 
and 
(T, <, V), to t A G(E a - 
E X((E /) 
U(E a))) A E a. 
We are to show that (T, <, V), to # E G((E/3) U(Ea)). 
We will find a sequence of nodes to < t1 < ... from T such that 
* (T,<, V),tk -E a and 
* for each s such that tk < 
< tk+1, we have (T, <, V), s t Ei. 
We already have to chosen. Suppose for the induction we have chosen an appro- 
priate tk with (T, <, V), tk t Ea. By assumption 
(T, <, V), tk t EX((E P) U(E a)). 
This gives us some tk+1 > tk along some branch starting at tk, with (7T, <, V), tk+1 # 
Ea and (T, <, V), s t E/ for each s such that tk <s < tk+l. 
Let 7r be the branch of (T, <) which starts at to and includes to < t1 < .... 
By construction we have 
(T. <, V), 7r t- G((E P) U(E a)): 
for all n < co, either 7n = to when we put k = 0 or there is some k > 0 such 
that tkl I < mC < tic and so we have (T7 <, V), tk t Ea and at any s with Cn < 
s < tk we have (T, <, V), s t E/. 
It follows immediately that (T. <, V), to t 
E G((E P) U(E a)). 
So the LC axiom is valid on ω-tree structures. By lemma 3, it is valid for ⊨_C. 

∎


## §7. The auxiliary atoms rule. The Auxiliary Atoms (AA) rule allows the use of

a certain arrangement of fresh atoms in a proof. Suppose that L and Q are disjoint 
sets of atoms. Suppose that A, which only uses atoms from L, is the formula which 
we are interested in deriving. The rule will involve another formula 0, using atoms 
from L U Q. The formula 0 describes the arrangement of the fresh atoms, ie those in 
Q, in terms of those in L. The AA rule will allow F t to be derived from F- (0 A 
) 
under certain side-conditions.

As we will see in example derivations below in section 16, the AA rule can be 
used in conjunction with the LC schema to derive a formula stating the existence of 
a fullpath satisfying a certain desired property The LC schema allows us to deduce 
the existence of the infinite fullpath from the existence of a finite cycle of states. The 
fresh atoms can be used as markers placed along the cycle for various reasons. For 
example they can be used to record that various states are visited in the cycle. They 
can also be used to distinguish several visits to one state within the cycle, indicating 
that at one visit a certain successor state should be chosen and on another visit a 
different successor state should be chosen. For the purposes of theorem-proving, 
deriving V say, the AA rule will be used as follows. First show that V is true when 
the fresh atoms are arranged according to 0, i.e. show F- (0 A) 
and then use the 
AA rule to immediate effect. 
Of course, the rule is also "used" in our completeness proof. We use the fresh 
atoms to record the states of a certain linear time automaton as it trundles along the 
branches of a tree. We eventually want to check whether the branches are accepted 
or not to see whether they satisfy a certain temporal formula. In the completeness 
proof, we will have assumed that a formula -AV, say, is consistent and we will be 
wanting to build a model of ¬A. Using the AA rule (in a contrapositive way) we 
will immediately know that 0 A -V is also consistent. The specific formula 0 which 
we will use here will describe an arrangement of the atoms to record the running 
of our automaton. So ¬V being consistent implies a description of a model of - 
with the automaton's state recorded in fresh atoms is also consistent. 
Note that there is no necessary connection between the AA rule and automata. 
(In fact, the acceptance criteria of automata has no counterpart in the AA rule, and 
so we should really only be discussing finite state machines here). The AA rule is 
just a rule which allows fresh atoms to be introduced into a proof in accordance with 
a fairly prescriptive arrangement. However, in our completeness proof we are going 
to use the rule to allow our construction to make use of an automaton. Further, as 
we will see in some example derivations later, uses of the AA rule in theorem-proving 
may well be motivated by consideration of certain automata. Finally, we will see 
that an understanding of automata will help with an intuitive understanding of the 
rule. 
Obviously the AA rule must have a substantial side-condition: it can not always 
be sound to derive F- V from F- (0 - 
V). In terms of consistency/satisfiability, we 
must state sufficient conditions on 0 under which 0 can be added as a conjunct to 
any formula ¬V with satisfiability preserved. 
In fact, a very general class of such formulas 0 exists. It is easy to see that we 
just need to require that, given any ω-tree structure in the language of L, and any 
point, we can choose the valuations of the atoms in Q so that the state formula 
0 holds at that point of the expanded structure. We might call such formulas 
L + Q-expandable. However, this is a semantic condition on 0 and we instead find 
a syntactic condition which is sufficient to ensure that 0 is in this class. 
The actual syntactic side-condition we uSe for our purposes is slightly compli- 
cated. It says that 0 is a formula which prescribes exactly which atom from Q to 
make true at each point in any w-tree structure in the language of L by working up 
from the root along each branch. We require that 0 makes use of a finite pairwise- 
inconsistent set { al, . . . }, 
an 
of state formulas in the language of L and a function

p to determine which atom to make true at the next point along a branch. We will 
say that such formula 0 is functionally L + Q-expandable. 

**Definition 4.** Say that {a I,

., 
} is a set of formulas using atoms only from 
L such that 
* each ai is a state formula, i.e. a boolean combination of atoms and formulas 
of the form Ef,, 
* for each i #4 j, (ai A aj) 
-* false is a substitution instance of a classical 
tautology and 
* V 
a ai is a substitution instance of a classical tautology 
Suppose that Q is finite (and enumerated in some way), there is bo C Q and a 
function p: (Q x {1, . . ., 
* Q such that 
n 
0 bo A A GAA((b A ai)- 
A Xp(b, i))AA 
A -A(b A b'). 
bcQ i=1 
blb'CQ 
Then we say that 0 is functionally L + Q-expandable. 
We state the AA rule using this concept as follows: 
AA: 
provided there are disjoint sets L and Q of atoms such that: 
* V only uses atoms from L 
* 0 is functionally L + Q-expandable. 

**Lemma 6.** *The AA rule is soundfor ⊨_C.*

PROOF. We prove this by contraposition: suppose that ¬V is satisfiable, i.e. has a 
complete ω-tree model in the language of L. Say that - 
is true of the branch 2. 
But now a simple recursion on the length of finite prefixes of branches starting at 
no, defines an interpretation of the Q atoms to make 0 true of 2. 
We have a complete ω-tree model of 0 A ¬T and so, via lemma 3, have our 
result. 

∎


## §8. The theorem. Now we have all the axioms and rules of our proof system for

standard CTL* validity. 

**Definition 5.** Let ⊢_C be derivability in the system which results from adding

the limit closure axiom schema and the auxiliary atoms rule to the system ⊢_B for 
bundled trees. 

**Theorem 3.** *⊢_C is sound and (weakly) complete for standard CTL* validity, c.*

PROOF. Soundness follows from the usual induction on the lengths of proofs. We 
can show validity of the axioms including LC in lemma 5 and, from lemma 6, we 
know that the rules preserve validity. Most of the rest of the paper contains the 
completeness proof. We will show that any given consistent formula has a Kripke 
model.

Note that, as with PLTL and =B, the logic is not compact and we can thus only 
manage a weak completeness result. 

∎


## §9. Completeness preliminaries. In what follows we have fixed a CTL* formula

q which is supposed to be Kc-consistent, i.e. V-/c ¬q. We are to show that it has a 
Kripke model. We use F- for ⊢_C throughout the proof. Let L be the set of atoms 
appearing in q. 
In this section we outline the quite intricate completeness proof and motivate the 
need to use three languages: the CTL* language of 0 with atoms from L, a PLTL 
language and an extended CTL* language with some fresh atoms. 
We will use a step-by-step construction to build an Ockhamist frame with each 
point t labelled by a set of formulas A(t). After taking the limit (T. <, ) of this 
construction we will factor out by _ and be left with a Kripke structure (S, R) with 
R defined in terms of --classes of <-successor points. By making sure that A does 
not vary on atoms within =-classes we will be able to use it to define a labelling g 
on S and we will be able to show, via a truth lemma relating labels to true formulas, 
that (S, R, g) is a model of 0 as required. 
The first of many complications is that we deal with only a finite set of formulas 
of interest. This is because we need to be fair in our scheduling of labels as we make 
choices in our construction. We do this for exactly the same reason that it is done 
in the proof of completeness for the PLTL system: we need to satisfy eventualities 
such as ae U/J. There are subtleties here and it is important for our proof to be 
familiar with the (PLTL) idea of working with finite labels instead of the usual 
infinite maximal consistent sets of formulas. In particular, note that as we proceed 
in the construction we can make choices about which label to place on the new 
successor to an existing labelled point. 
So, for some purposes including proving the truth lemma, we restrict our attention 
to the finite set of subformulas of q and their negations. The simplest of the several 
closure sets of formulas used in the proof is thus 
clO 
{v'-v' V' ? 0} 
recalling that tV < 0 denotes that i is a subformula of 0. This set is not quite closed 
under taking negations of its formulas. However, in the proof we can use V as the 
negation of -,. 
A straightforward step-by-step construction using such labels and fair scheduling 
will eventually produce an Ockhamist model of 0. The maximal sets of <-related 
points will each give us a branch. Unfortunately, this construction will not in general 
give us a Kripke model but only a bundled model. This is because, in taking the 
limit of the construction, a possibly uncountable number of new branches emerge 
in addition to the ones which were constructed as maximal sets of <-related points. 
(See the example in section 4.9 above.) 
The problem with emergent branches in our construction can be briefly described 
as follows. When we add a new labelled point, most importantly a successor to 
an existing point, to our finite Ockhamist frame, we need to decide on its label. 
Obviously for our truth lemma to work there are strict requirements on this new 
label. One of the most important is that if E a is in the label then we also need ¬a 
in the label. This will eventually ensure that the fullpath built from the equivalence

class of that point and the points <-above does not make a true. However, it may 
be that an emergent fullpath beginning at this class does make a true. In that case 
we will not after all have E a holding here as required by the truth lemma. 
We might call emergent fullpaths bad if they mess up the truth lemma in this way. 
Our task, then, is to prevent the construction of bad emergent fullpaths. 
The solution we employ is as follows. We first note that we can tell which formulas 
will hold along a fullpath (even an emergent one) by looking at the ω-sequence of 
sets of formulas of the form E / appearing in the labels of points along the fullpath. 
Due to the fact that labels of points in --classes agree on such formulas we do not 
even have be careful of which representative we look at. So now to ensure that no 
fullpaths are bad we just need to ensure the truth, along each fullpath, of a certain 
PLTL formula which has atoms corresponding to the E 
formulas. Hence the next 
few definitions. 
Defineecl$ 
{E g,E-gV 
< 0} andforeachc 
C eclq let 
Cc A EN A 
A 
-EV. 
E V/c 
E yVC(edl 
O\c) 
If a is a subformula or the negation of a subformula of a formula in ecl 0, then 
we define a formula oa of the linear language with atoms from ecl q$ {E f i E f_ 
ecl(q)}. Simplyput trie = true, _ _Epforatomsp C L, -=a = 
ra, a A fi 
a-AP, 
a U 
i= 
U /, X a = X oa and E / is just the atom E i itself. For any c C eclq5, 
let c = {PI3 E c}. 
Now we are able to introduce the PLTL formula which must be satisfied by every 
fullpath in the limit model. Define 
0 = G A (Y 
-> Ey), 
Yccli() 
a PLTL formula in the language with atoms from ecl(q). 
For any given fullpath (emergent or otherwise) we can interpret the atom E f in 
ecl(q) in accordance with the appearance of E f in the label of a point along the 
fullpath. We must make sure that on no fullpath the ω-sequence so defined is a 
model of ¬yo. Such a fullpath would be a bad one. 
The task is to ensure this by making the right choices (of labels) during the 
finite construction. We need some way of constructing many interconnected PLTL 
models (of %o) in a step-by-step way. To help us do this we now bring in the promised 
automaton to tell us how well we are approaching the goal (of a model of /o) on 
each fullpath. The simple form of the Rabin acceptance criteria is the key to guiding 
our construction. Essentially we can tell how we are going by looking at the history 
of the construction so far and we can thus assess our progress on emergent and 
constructed fullpaths alike. 
So by theorem 2, find a deterministic Rabin automaton A = (Q, so, p, { (U1, V1), 
* , ( UK, VK) }) recognizing ω-sequences of subsets of ecl(q) and accepting exactly 
the models of ¬yo. Thus p: Q x (p(eclq0)) -* 
Q and each Ui, Vi C Q. We can 
choose Q so that Q n ecl(q) 
0 and, as mentioned in section 2, we can choose the 
(Ui, Vi) sothateach Ui n Vi 
0.

Given the automaton our task can now be restated as the requirement to proceed 
so that in the limit no fullpaths will be accepted by A. So somehow we have to make 
sure that as A runs along any fullpath (and interprets the labels appropriately) there 
is no i = 1, . 
K such that a state in Uj comes up infinitely often while no state in 
Vi does. 
The next step is to realize that in achieving this goal during our construction we 
do need to look ahead a little to make sure that we do not force ourselves to end 
up with a bad path by making a bad choice (of label) at a finite stage. In order to 
make sure that we can consistently continue after making a particular choice we 
need to bring the whole automata machinery (and a banning mechanism which we 
will meet later) inside the language, as it were. That is, we need to be able to reason 
about the progress of the automaton within the language of the labels. This is a 
crucial observation and motivates the need for the AA rule. In particular, we need 
to bring in fresh atoms to record the current state of A (if it started at the floor of 
our frame and worked up to any given point). 
So now we introduce our third language: a CTL* language with atoms from L 
and some new ones as well. We use the symbols of Q as the new atoms and define 
the following branching formula using atoms from Q U L: 
OA- SO A AG 
A ((s A C) - A Xp(s,c))A 
AG A -IrAs). 
sCQ,cCecl 0 
s=IrCQ 
This formula, which we want to hold at the root, will ensure that the atoms in Q 
are interpreted exactly according to the state which A would be in at that point if it 
trundled along reading the PLTL version of the labels as we desire it to. Note that 
for each c C ecl(b), the truth of the CTL* state formula Cc (or its appearance in a 
label) is exactly what we mean by saying that the automaton is reading the current 
set of ecl(o) atoms as being `c. 
In order to allow us to reason ahead about whether we are in danger of cre- 
ating a bad fullpath we also define vi = Vscv, s, and ui = Vscu, s and let 
V[KJ1(FG ¬vi A GFpui). 
Thus, given the described setting, X1 holds at a 
fullpath b if A accepts b iff b is bad. 
Now we have a language which allows us to specify a model of 0 in which we 
have no fullpaths accepted by A. We simply use the formula +$= 
OAA A$ A -E %1 
in the CTL* language with the fresh atoms. 
Fortunately, the AA rule and a little PLTL reasoning allows us to conclude that 
0+ is consistent. 

**Lemma 7.** *If 0 is consistent then so is 0+ = OA A q$ A -E %1.*

PROOF The proof proceeds via three claims. 

**Claim 1.** *In PLTL we have the following:*

⊢_L (X1 
A 
so A G A (s A -c Xp(s C)) 
A G A -r A s)) -*-Xo. 
sCQ,cCecldo 
r=IsCQ 
PROOF. Suppose that a is an w-sequence of subsets of ecl 0 U Q such that 
a u X1 A so A G A (s A c -X 
p(s, c)) 
A 
GA 
-,(r A s). 
sCQ~cCecl 0 
r=IsCQ

Say that the run of A on a ele!t is (SO, Si .... ) So that Si+1 = p(si, ai l 
). 
I claim that for all i < c, for all s c Q, we have s C vi if s 
Si. We prove this by 
induction on i. After we prove the converse direction, the forward direction follows 
from the fact that a tz GAr1 7sCQ -(r A s). The case of i = 0 follows as a 
z so. 
Now assume that the hypothesis holds for i > 0: we show the converse direction 
for i + 1. Thus we are to show that Si+1 C c7i.+ 
We know that cr>i t AsEQcCeCdI(is 
A CC ) Xp(s, 
)) and si c ui. 
Thus 
U> i t si A SC - 
Xp(si, c) where c = {,6 c eclq 
| c H7} so that C = cil eclqO 
Now for each V C eclq$, if E 
c 
C c then E V c ai so uri ?t 
E v. Similarly, if 
EN g eclq \ c then > i #-E 
. Thus u>i t Cc. 
Since u>i t si we can conclude that Ski 
- X p(si c). But p(si, c) = p(Si, ui ec) 
- 
si+? so >i+l t sji+. We conclude that Si+1 c ui+l as required. 
Thus we have shown that for all i < w), for all s c Q, we have s c ai if s = si 
Since a t X1 there is some j = 1, . . ., K such that, no atom in Vj comes up 
infinitely often in the sequence a of sets of atoms but some atom from Uj does. By 
the foregoing, in the run (SO, si, S2, . .. ) no state in Vj is visited infinitely often but 
some state in Uj is. Thus A accepts u ecI-. We deduce that a t -Xo as required. Li 
CLAIM 
2. K OA -E 
X1. 
PROOF. C9, Cli, C14 and some simple PLTL reasoning imply that 
KO A A EX1 - E(Xj A so A G A (s A Cc - Xp(s,,) 
A G 
A 
-i(r A s)). 
sEQ,cCeclb 
r-ISEQ 
From claim 1, we know that the PLTL axiom system can be used to show 
⊢_L (X1 A so A G 
A 
(s A c )- Xp(s, 
)) A G A 
(r A s)) 
sEQ,cCecld 
r7IsEQ 
-(-G A (A Y-)). 
yEdc q 
Following the same proof in our axiom system using E y substituted for each atom 
E y gives us 
K (X1 A so A G A (s A Cc - Xp(s,,) 
A G A (r A s)) 
sEQ,cCecldb 
rISEQ 
-*(-G A (Ay -y)). 
y Ccq 
But C12 can be used to show that for all y C cl X, K A y - 
y. So 
KG A (Ay - 
y). 
yc! 
0 
Putting this altogether we conclude that OA A E Xi is inconsistent as required. 

∎


**Claim 3.** *If KO A Aq - EX, thenk- lq.*

PROOF. Propositional reasoning from claim 2 and the assumption implies that 
K OA ) -X

Now we can show that OA is functionally L + Q-expandable. Say that gv(ecl d)) - 
{C1, . . ., CN}. 
We use the set {fC,. . ., 
CCN } of formulas and a function p' : Q x 
{1 ,N} 
-J 
Q given by p'(s, i) = p(s, ci). Since -iq$ uses atoms only from L, we 
may apply the AA rule with premise F- OA 
) -b 
This gives us F- -4 as required. 

∎

Our lemma follows immediately. 

∎

Before we continue with the completeness proof, let us look ahead to the truth 
lemma to see how the three languages and the automaton come together. We will 
define a Kripke frame (S, R) from equivalences classes in the limit (T, <, _) of our 
Ockhamist construction and on it we will define a (L U Q)-labelling g from the 
labels A(t) on the points t in the construction. A point t of the Ockhamist limit will 
determine the state [t] which is an equivalence class of =-related points and it will 
also determine a fullpath up(t) in (S, R) being the sequence of equivalence classes 
of points <-above t. 
The truth lemma will establish, by induction on the construction of formulas in 
cl(Q), that truth of a formula on up(t) in (S, R, g) agrees exactly with membership 
of the formula in A(t). 
There are two difficult parts of the truth lemma. One is to show that if a formula 
of the form a U/i is in A(t) then fi eventually makes it into the label of a point 
above t. This involves fair scheduling argument (just as in the PLTL proof) but is 
somewhat complicated by our banning mechanism. More about this later. 
The other difficult case is, as we have foreshadowed, showing that if Ea holds 
of up(t) in (S, R, g) then Ea is in A(t). So we assume that there is a fullpath b 
starting at [t] in (S, R) on which a holds. The emergent paths cause the trouble here 
because the fullpath b might be emergent and thus not of the form up(t') for any t'. 
So we need to show Ea is in N(t) but we do not necessary have immediate access 
to any label N(t') containing a. Note that if we were just attempting a bundled 
completeness proof then we would define the bundle to contain only the up(t') 
fullpaths and at this stage of that proof we could use the bundled semantics to give 
us the required t'. 
Instead, we need some other guarantee that we have E a in A(t). This is where the 
automaton A and the idea of bad paths comes in. We can define an ω-sequence u in 
the PLTL language of ecl(q$) by saying that E B is in oi iff E / is in any (equivalently 
all) A(t') for t' in the _-class bi. We know that (S, R, g), b t a. Our truth lemma 
inductive hypothesis (on subformulas of a) will, in lemma 25, be able to be used 
to show that u t -a. This is partly just the observation that the truth of CTL* 
formulas along fullpaths is determined by the linear arrangement of truth of E /i 
formulas along the fullpath. Of course, we also need the inductive hypothesis in the 
truth lemma to relate truth of these formulas to the contents of labels (which is how 
u is defined). 
From the fact that c ti a and that we were able to ensure that each fullpath, and 
in particular b is not bad, it follows that c t Ea. This is because we have seen 
that badness can be defined in terms of being a model of ¬Xo. Note that the actual 
argument at this stage is slightly complicated by the need to start certain fullpaths at 
the floor of the structure to reason correctly about the behaviour of the automaton. 
It follows immediately, by definition of u, that A(t) contains E a and we are done.


## §10. The standard basis of the construction. In this section we consider the stan-

dard modal logic aspects of our step-by-step construction of a labelled Ockhamist 
frame. We will be building a model of 0+= 
OA A q A E XI under the assumption 
that it is consistent- which we have just determined happens when q is consistent. 
The construction will be the usual procedure of laying out maximal consistent sub- 
sets of some closure set of formulas and putting accessibility relations between them. 
The unusual aspects will be a fair approach to scheduling the use of the sets and a 
banning mechanism for preventing the use of some of them. 
At each stage of the step-by-step construction we will have part of an Ockhamist 
structure, a vaguely grid-like two-dimensional structure with points labelled by what 
we will call hues. Construction proceeds by adding a successor to a point. We might 
say that we cure a defect. 
In picturing the construction we will, as usual, think of the irreflexive transitive 
order < as increasing vertically and the equivalence relation _ as being horizontal. 
The hues which label points will indicate which formulas from a small finite closure 
set are to hold at that point. This closure setfcl q+ contains all the subformulas of 
q+ and is closed under one application of both negation and E. Recall that in an 
Ockhamist frame the equivalence relation 
relates points which collapse to a state 
under the usual branching time semantics. Thus we need to ensure that equivalent 
points' labels agree on state formulas. 
The hue of a point will also indicate which other hues will hold at other points 
which are -=-related to that point. A set of hues sported by the members of a whole 
--class of points will be called a colour. All equivalent points will share a colour 
and so it is not surprising that corresponding to a colour will be a state formula yc: 
the colour is a property of the whole equivalence class. This fact will ensure that we 
will be able to talk about the sequence of colours (but not hues) along the emergent 
fullpaths in the limit of our construction. 
Let us formalize hues and colours. 

### 10.1. Colours and hues. Let

ftlo+ = aV_,FEW 
-EV,EA,-E-VlV 
< 0+}. 
For a c pg(fclq5+), define 
, = A6AA 
A -a 
5Ca 
6E(fcl(0+)\a) 
(with the conjunction taken in some fixed order). 
Let C = p(p(fcl +$)): the set of q+$-colours. For c c C define 
Yc = AEla 
A 
A 
iEoa 
arc 
aE(p(fcl q+)\c) 
Given a colour c c C the various a C c determine what we will call the hues of c. 
So c has at most Ic different hues. The hue h(a, c) of c corresponding to a c c is 
given by 
h (a, c) 
{1 EC a } U {-i1 

∎

Cfcl q+ \ a } U 
{Eb 
lb C c} U {¬Eb 
lb c v(fclq$+) \ c}.

The set H(q+) of all hues of q+ is 
H(q+) = {h (a, c) a C c C C}. 

**Lemma 8.** *Each hue is a hue of exactly one colour.*

PROOF. We claim that c = {b e p(fcl 0+) I Ebb c h (a, c)}; from this the lemma is 
immediate. The inclusion C follows by definition. For the other inclusion, consider 
b c p (fcl q+) with E 6b C h(a, c). By definition of h(a, c) we could either have 
Ebb c a or b c c. In the latter case we are done but the former case can be 
eliminated by a consideration of lengths of formulas as follows. We show that in 
general, for a c p V(fcl 0+), we do not have E 6a c fcl0 /+. 
Suppose that the length Io+ I of q+ is n. Clearly each formula infcl 0+ has length 
atmostn + 3. 
But q+, -+, 
E+ , 
FE 0+, 
F - 
E Q+ are six distinct formulas in ftl 0+ 
and for each of them, either the formula or its negation is a separate conjunct of 
E6a. This makes I E a I at least 6n + 10 and gives us our result. 

∎

If h is a hue of a colour then we denote the colour by h*. From the proof of the 
lemma we see that h* 
{b c pg(fcl q+)I Ebb c h} and that h is a hue of h*. 
As usual, we will say that a set F of formulas is ([-c-)inconsistent iff there is 
some al,..., 
an C F such that F- (Ai>n1 
ai) 
-* false. Otherwise, we will say the 
set F is (⊢_C-)consistent. By the way, due to the lack of compactness of the logic, 
a consistent set of formulas is not necessarily satisfiable. We will sometimes need 
to relate hues and colours to the maximally Fc-consistent sets of formulas: called 
MCSs. As usual we define the relations Rx and RA on MCSs: FRXA iff for all a, 
if Xa c F then a c A; and FRAA iff for all a, if A a c F then a C A. 
Often we will use the fact that if F is an MCS then A 
a{ X a C F} is also one: 
to prove this just uses axioms from PLTL. 
Also, the usual Lindenbaum technique gives us: 

**Lemma 9.** *If E is a consistent set offormulas then there is an MCS F D E.*

Let 
hcl b+ = {I, -I1 G fcl 0+ } U {E 6b , - E b I b C g(fcl q+$)}. 
Then for each MCS A, the set h = A n hcl q+ is a hue. Furthermore, for each A this 
is the only hue which satisfies h C A. 
We say that a hue is consistent if it is consistent as a set of formulas. We say that 
a colour c is consistent iff yc is a consistent formula. Note that 

**Lemma 10.** *a consistent hue h is maximally consistent in hcl 0+, i.e. for all a C*

hclq$+, either a c h, --a c h or a = -/ and/i C h. 
We define two useful relations on H(q+). Say that hRxh' iff there are MCSs F 
and F' such that h C F, h' C F' and FRxF'. Say that hRAh' iff there are MCSs F 
and F' such that h C F, h' C F' and FRAF'. 
We say that a hue is in Vi (or Us) if it contains an atom s C Q which is in Vi (or 
Ui respectively). We say that a colour is in Vi (or Ui) iff it has a hue which is in Vi 
(or Ui respectively). 

### 10.2. Some lemmas. Consideration of the constituents of hues, some simple uses

of C9-C14, and extensions to MCSs give us:

LEMMA 1 1. 1) Consistent hues of the same colour agree on atoms and on formulas 
of theform E Fl. 
2) If h is a consistent hue then h* is consistent (i.e. Yh* is) and all hues of h * are 
consistent. 
The following "down and across" lemma will allow us to fill in hues in the past 
of each of the members of the equivalence class of a new point. 

**Lemma 12.** *If hlRxh2l then each hue h22 of h 1 has a (consistent) predecessor hue*

h12 of h1l, i.e. h12Rxh22. 
21 . same . . 
colour 
Rx 
Rx 
same 
colour 
PROOF. As hlRxh2l we have MCSs F D hl1 and A D h2l with FRXA. 
If h22 is a hue of h2* then there is a c h51 with 
h22 = {616 C a} U {-bat16 efcol+ 
\a} U 
{Eb lb C h~l} U {-Ebb bC pg(fclq+) \ h*l}. 
Also we have E(6a A Yh*) c A. Thus XE(&, A Yh*) 
c F. By the contrapositive of 
C15, EX(6a A Yh*) is also in F. 
By C9-C13, {X(6a A Yh)} 
U {a I A a cE F} is consistent and can be extended to 
an MCS E say. Let h12 =-E 
n hcl q+: this is a consistent hue. 
We can show that h12 is a hue of h*1. We just need to show that E&b c hl1 iff 
Ebb c h12. Assuming Ebb c h*1, we have Ebb c F and so AEbb c F (C12 and 
CIO). Thus Ebb c E.and 
in hl2 as required. Similarly if Ebb c hll. 
Finally we show hl2Rxh22 as required. We just need to show that if a c h22 then 
Xa e C A. 
In the case of a being in fl$ 0+ then F- X6a 
-* 
X a and so X a C Ed. 
Otherwise, a is Ebb or Ebb for some b c p (fcl 0+). But then we have F- Yh* -) a 
and XYh* c 
C 
to give us our result. 
F] 

## §11. The idea of banning. We have seen that the basis of the construction is that

for building a bundled model of 0+. However, not just any bundled model of q+ 
will do because of the "no bad fullpaths" requirement. 
We must ensure that when all the branches/fullpaths of the structure are included 
in the model- in particular the possibly uncountable number of "emergent" ones 
that were never constructed explicitly at any finite stage- then the truth of formulas 
along constructed branches is unaffected. We have seen that it is sufficient to ensure 
that along all branches, even emergent ones, we have Xo holding on the sequence 
of state formulas in the labels of the points, i.e. reading E y in a label as the atom 
E y holding. Thus we require the automaton A to not accept any branch and thus, 
as XI captures its acceptance criteria, we require XI to be false along every branch. 
This means that we want to avoid constructing a fullpath on which some colour in

some Ui occurs infinitely often while colours in the corresponding Vi occur only 
finitely often. The banning mechanism will be used to provide an effective finite 
mechanism for bringing about this infinite property. 
The basic idea of banning is as follows. We label each point with a list [(cl, Pl).... 
(Cn, 
PXn)] of banned colour-index pairs. The aim is to not allow any ci to occur again 
as the colour of a hue above the point unless some colour in Vp, occurs first. So, 
if we see a colour c in some Up occurring on a branch in the construction but no 
colour in Vp has recently occurred (on that branch) then we will want to place (c, p) 
in the banned list. The banned list is inherited by successors with specific changes 
in certain circumstances. 
The same banned list will apply to all points within an equivalence class. This 
ensures that we will be able to talk about banned lists (like colours) in the context 
of emergent fullpaths. 
There are many subtleties. In particular note that we put colour-index pairs in the 
banned list and not just colours. One may wonder why we just don't keep a list of 
banned colours and ban all colours in Ui if we see that no colour in Vi has come up 
for long enough. The reason is that branches bifurcate during the construction and 
ideas of waiting long enough cease to be coherent in that situation: after bifurcation, 
a long unseen colour may turn up. For example, consider constructing a branch on 
which G(q A E X ¬q) holds. After a million steps in which we have seen the atom q 
being put in the label of every point of this branch at every stage, we are still going 
to want to make a new, parallel, branch (vertical line of points) of =--related points 
(with the same coloured labels up until then) and extend it by adding a successor 
point (not -=-related to any point on the original branch) with a hue not containing 
q. The possibility of bifurcation requires that we only place colours conditionally 
in the banned list. If (c, p) is in the list then a colour in Vp might well eventually 
turn up above here (but not necessarily vertically above) in a new related branch 
and so we will want to unban c. 
There is another conditionality which we capture by recording the banned pairs 
in a list rather than just a set. Suppose that we ban (cl, 1) at some stage. Because of 
the strict relationships between hues and successor hues, this might have the effect 
of subsequently stopping all colours in V2 and V3 from occurring along this branch. 
Thus, later on we may ban c2 C U2 and C3 C U3. Now, after a bifurcation, colours 
in V1 may suddenly start showing up. However, the continued banning of c2 may 
prevent colours in V3 appearing and vice versa. It might turn out that if we allowed 
c2 and C3 to appear again then colours in V2 and V3 can show up too. In some 
sense the undesirability of c2 and C3 was actually dependent on the banning of cl. 
We do not want to continue banning C2 and C3 in this situation: banning too much 
will frustrate our efforts to make sure that eventualities are satisfied along branches. 
The solution we use is to record bannings in a certain order and remove all later 
listed pairs when we unban a pair. There is plenty of time for colours to get banned 
again. 
The actual order of listing of pairs (as specified in a clause K4B below) is not 
exactly the order of being put in the list. It turns out to be easier to reason with an 
equally effective order based on the order of Vps ceasing to appear. 
Another important subtlety is that we must plan ahead a little to prevent being 
forced, by a limited choice of successors hues, to choose a hue of a colour which

contravenes the banning condition. This planning ahead effectively limits our choice 
of successor hues as we avoid early errors. 
To explain this idea and help with notation we introduce a formula TL which 
captures the requirement in terms of the current banned list L. Recall that the 
formula vi identifies when an atom in Vi holds while pi identifies Ui. If L 
- **[(c1, p1), . . ., (c,]** , p,)] is a finite sequence from C x {1, . . ., Kthen
we put 
CL = XI V X((-IvP) 
UYc,) 
V ... 
V X((-iVp 
A 
A 
vp",) UyC,,). 
If L is empty then CL = Xi- 
The purpose of iL is to describe a path which is either bad or leads through a finite 
sequence of colours to a future place where the banning requirement is contravened. 
In order to prevent us making a bad choice of hue, we make sure (in K5A below) 
that 
V/ colour now -> E TL 
holds at each point. In our construction, we choose the successor hue which satisfies 
this restriction but, to ensure fairness, has been used least recently 
Consider a banned list L as above. The first disjunct of TL says that there is a bad 
fullpath starting here. The second disjunct (if there is one) says that the path goes 
on to avoid Vp, and ends up at cp,: a clear contravention. Later disjuncts reflect 
the conditionality of the ordering of the list. Consider the third disjunct. It says 
that the path proceeds to a point coloured with cP2 without any colour in either Vp, 
or VP2 showing up on the way. Again this is a contravention as (c2, P2) would have 
remained banned until then. 

### 11.1. Lulls. It will be important in our construction to prevent too much frenetic

banning and unbanning behaviour. This is because we want to use the PLTL 
completeness proof idea of fair scheduling to make sure that eventualities of the 
form a U/i are satisfied by fi occurring in a label at a point above (if not in the 
current label itself). The fair scheduling idea requires us to try all possible hues 
and it is easy to see how banning could get in the way: a hue could infinitely often 
be allowed to appear at a later point but constantly be prevented by the time we 
actually get there. 
Thus, after some colour-index pair becomes unbanned then we want to try to 
wait for quite a while to see if some colour in some Vi shows up before newly 
banning a colour in Ui. A new banning should only be instituted if we have waited 
long enough since the last time that some colour was unbanned. Hence, we here 
introduce the idea of a lull in unbanning. 
Note that there is no need to wait after a new banning before making a subsequent 
new banning: bannings only further restrict the possibility of colours in Vi coming 
up. 
We will see later that the appropriate "waiting time", during a lull in unbanning, 
is eH -2JH(0 
)1 
Let x be a point in our construction which has a successor x+. Suppose that the 
list of banned pairs at x is bl(x) and the list of banned pairs at x+ is bl(x+). We say 
that there has been an unbanning at x+ iff bl(x) is not a prefix of bl(x+) (written 
blx 
As blff 
An 
)\

Suppose that there has been an unbanning at x+, so bl(x) : bl(x+). Say that 
[(ci, pi),... 
(ca, p,)] is the longest common prefix of bl(x) and bl(x+), 
bl(x)= 
[(Cl, Pi), 
(Cn, Pn), (Cn+l XPn+l) 
(Cm ,Pm)] 
and 
bl(x +)= [(Cl, P1), 
(Cn, Pn), (c'+1, P'+I (C).(cP, 
I)]. 
Then we say that each (ci, pi), for i c {n + 1, . . ., m }, has been unmanned and each 
(c', P'), for i c {n + 1, . . ., m'}, has been newly banned at x+. It is clear that if there 
is an unbanning at x+ then something is unbanned at x+. 
If Xn < Xn+1 < 
... 
< Xn+eH are points in our construction such that each xi+, 
is the (immediate) successor of xi and there has not been an unbanning at any 
xi (n < i < n + eH) then we say that there has been a lull in unbanning between Xn 
and Xn+eH. 

## §12. Chronicles. At each stage during the construction and in the limit, we will

have a chronicle. 
A chronicle is (T, <,_, i, bl, Xo) where: 
(T. <, _) is a floored Ockhamist frame; 
AI: T -* H(+); 
bl : T -* 
(<0(C x{1, . . ., K})) (where K, recall, is the number of accepting 
pairs of A); 
Xo c T; 
such that for all x, y c T: 
KO 
The floor is Xo/- and q+ is in (Xo). 
KI 
A(x) is consistent. 
K2 
If x has an immediate <-successor in (T, <) -call it x+: it is unique 
then 2(x)Rx2(x+). 
K3A 
If x _ y then A(x) and A(y) are hues of the same colour. 
K3B 
If h is a hue of A* (x) then there is y c T such that x _ y and h = A(y). 
K4A 
If (c, p) occurs in bl(x) then: 
1) c has appeared at or below x (i.e. c =A(y) 
for some y < x); and 
2) there is a lull in unbanning reaching its eHth step below x such that 
no colour in Vp appears between the start of the lull and x; 
K4B 
If (d, q) precedes (c, p) in bl(x) then: 1) the most recent appearance of 
Vq (if any) below x is below (or equal to) the most recent appearance 
of Vp; and 2) if there is no appearance of Vp before x then there is no 
appearance of Vq before x. 
K4C 
If x _ y then bl(x) = bl(y). 
K5A 
7 ye *(x) - Ezbl(x) - 
K5B 
If x+ exists and (c, p) occurs in bl(x) then A* (x+) 54 c. 
K5C 
No (c, p) occurs more than once in bl(x). 
K5D 
If x+ exists and (c, p) is newly banned at x+ then A* (x+) = c.

Most of this definition is motivated by the standard modal logic ideas of step-by- 
step model construction. The clauses K4A-K5A have been motivated in section 11 
above. K5B says that a currently banned colour does not appear in a label, K5C 
ensures banned lists stay manageable and K5D says that only the current colour is 
allowed to enter the banned list at a point. 
Throughout our construction we will have a finite chronicle, i.e. T is finite. Only 
in the limit will T be infinite but even then each point will only have a finite past in 
accordance with the requirements of an Ockhamist frame. 
A straightforward induction using KO (in particular OA c A(Xo)), KI, K2, K3A 
and lemma 11 gives us the following useful result about the distribution within the 
labels of the atoms from Q, the atoms of the automaton's state. 

**Lemma 13.** *For each x in a chronicle we have the following:*

a) A G AsEQ cCeC0((s 
A c) -> A Xp(s, c)) c A(x) andfor all s C Q andfor all 
c C ecl 0, if each of the conjuncts of Cc is in A(x), s c A (x) and x+ exists then 
p (s, -c) C A (x+). 
b) A GkAs7rEQ 
-(r A s) c A(x) and there is only one s from Q in A(x). 
This will allow us to deduce that the atoms do reflect the states of A as it reads 
the ecl(q) versions of the labels along branches. See lemma 26 below for a formal 
statement of this when we need it. 

### 12.1. Pioneers. We will identify some of the elements of T as pioneers of their

--classes and some others as the siblings of pioneers. Note that some elements of 
T may be neither pioneers nor siblings of pioneers. We need to know which points 
are pioneers because the fair hue scheduling technique will only apply to them. 
We will ensure: 
P1: Every point in T is below (or equal to) a pioneer or sibling of a pioneer. 
P2: If x is a pioneer or sibling of a pioneer and x+ exists then x+ is a pioneer. 
P3: If x is a pioneer and x+ exists then 
v (A N(x) A x(A W(x?))) 
-_ E Cb1(). 
P4: If x is a pioneer and x+ exists then ;,(x+) is a fair choice amongst the possible 
hues which satisfy P3 in the sense that there are no other such hues which have 
come up less recently as (y) in the past {y Iy < x} of x. 
P3 is a stronger property than K5A but for the same purpose: we need to make 
sure that when we choose a successor hue then the fact of the combined pair of hues 
being successors does not force us to go on contravene the banning restrictions. 

### 12.2. The start.


**Lemma 14.** *There is afinite chronicle satisfying P 1-P4.*

PROOF. Let F0 be any MCS extending 0+ and let h = 
r0 
hcl q+. Say that h* 
has n hues, ho, . . ., hn_1 including h = ho. We know that these will be consistent 
hues. Choose n objects Xo, . . ., X- 1. 
Our construction starts with (To, <o,, =o , o bNO, 
X0) where To 
{Xo, . 
Xn }, 
<0, and blo(Xo) . . ., blo(Xn-1 ) are empty, _0= {(Xi, Xj) Ii, j < n} and Ro(Xi) = hi. 
It is a simple matter to check that the conditions hold. K5A holds as 
EX, is in 
each (Xi). We have -E X c fcl 0+ C hcl 0+. We also have -EFyi C Fo as it is a

conjunct of q+$. Thus -E XI c ho. By lemma 1 1, -E XI is in each hi. We will say 
that Xo is the pioneer of the -O-class and the other Xi are its siblings. 

∎


## §13. Curing a defect. In this section we show that we can add a successor to any

point in a chronicle. 

**Lemma 15.** *Suppose (T, <,*

,i, bl, Xo) is afinite chronicle satisfying P1-P4. Say 
that x C T and there is no y C T with x < y. 
We can define a new chronicle 
(T', <',-', 
i', bi', Xo) to slightly extend (T. <,A, i, bl, Xo) with the addition of a new 
element to be x+ andprobably some other new elements as well. (T', <', _', i', bl', XO) 
is also afinite chronicle satisfying P1 -P4. 
The rest of this section is devoted to proving this. 
If it wasn't for the banning mechanism then the set of possible hues we use as 
i'(x+) 
is 
{h C H(q+) I(x)Rxh}. 
In order to respect banning we have to be a little more selective. For a hue h and 
banned list B we will define the set Pn (h, B) of hues to contain just those which we 
will allow after a point with hue h and banned list B: 

**Definition 6.** Suppose that h c H(q$+) and B C (`o(C x{1, . . ., K})).

We 
define Pn(h, B) to be the set of h' c H(q$+) such that 
V (Ah AX(Ah )) - ETB. 
We now show that Pn(A(x), bl(x)) is non-empty (and some other useful things). 
LEMMA16. Suppose h c H (q$+) and B c (`0 (C x { 1, . . ., K })). Then 
1. if h and B satisfy K5A, i.e. f Yh* -* 
ETB, then Pn(h, B) is non-empty; 
2. all the hues in Pn(h, B) are consistent; and 
3. if h' C Pn(h, B) then hRxh'. 
PROOF. (1.) Suppose for contradiction that it is. This means that for all h' C 
H(q+$), we have F- (Ah AXAh') 
-* 
E TB. Since F- Vh cH(O+) Ah', as it is just 
a substitution instance of a propositional tautology, we have, using a few PLTL 
axioms, that F- A h 3_ Vh'CH(+) (A h A XA h')). Putting these facts together gives 
us F- Ah -* 
ETB. 
Now, suppose that h =h(a,c) so that a c c 
h*. As yh* is 
just a conjunction of formulas of the form E fi and their negations, and E 6a is one 
of the conjuncts, we can use the S5 axioms to show that F- Yh* -* E(6a A Yh*). But 
clearly, F- (6a A Yh*) -- A h. This gives us F- Yh* -* 
E TB contradicting K5A. 
(2.) follows as 
V (AR(x) AxAh') - ETB 
for all h' c Pn(A(x), bl(x)). 
(3.) Assume h' c Pn (h, B). Then A h A X A h' is consistent and we can extend 
it to an MCS F say. Let A = {a I X a C F}. This is also an MCS and, as h' c A, it 
is clear that hRxh' as required. 

∎

Say that all the elements of T which are below x are exactly 
X1 < 
X2 < 
*- 
< 
Xr = 
X.

This gives us a sequence of hues hi = 
j(xi). Choose a possible hue h which we 
can put at x+, so that h has come up least recently as an hi. That is, for each 
h c PnQ((x),bl(x)), put l(h) = max({-1} U {i h = hi}). Choose one of the 
h c Pn (Q(x), bl(x)) with the smallest I (h). Say it is h+. 
Say that the hues of h+ are exactly h?, . . ., hn-I with h? = h+. 
We first choose new objects zo, . .Zn- 
IV T. Also, for each predecessor xj (j 
1, . . ., r) of x (including x = x. itself) and each i = 1, . . ., n-1, 
choose a new 
object zij. 
LetT'= 
TU{zoX 
UZn- 
}U{z1ij 
1. 
n-1,j 
= 1.,r}. 
Extend<to 
<' as follows: 
U{(xj,zo)Ij 
.r} 
U{(zij,zi)i 
= 
. 
n-1,j 
= l,.,r} 
U{(zij,zik)Ji 
1. 
n-1, j = 1,.. 
r,k =?j + 1,. 
r}. 
Thus zo is the successor of x in (T', <', _'). Extend _ to _' by adding 
{(zi, zq)} U {(xj, zij)} U {(Zij, xj)} U {(Zij, Zkj)} U {(y, zij), (Zij, Y) y -xj}. 
In Figure 5, we can see the new successor zo added above x = x. and the grid 
of n - 1 parallel vertical towers, each of height r + 1, added along side the old 
chronicle to preserve K3B and the property of being an Ockhamist frame (amongst 
other things). 
zo 
/ 
Z1 
_ 
/ 
*-/ 
Zn-1 
* 
... 
<.t 
<It 
</t 
Xi- = X 
- 
Z1r 
= 
Z2r 
/*-= 
Z(n-I)r 
OLD 
t 
<'t 
<;f 
... 
CHRONICLE 
< 
< 
< 
< 
X2 
* 
Z12 
Z(n-1)2 
< t 
/ 
</t </t - 
.. 
X1 
Z11 
Z21 
* 
Z(n-1)1 

*Figure 5. The new elements*


We call zo = x+ the pioneer of its -'-class and z1,..., z,_1 its siblings. Other 
new points are neither pioneers nor siblings. Old points inherit their previous 
classifications. 
Let i'(zi) = h+. We fill in the hues of their predecessors from the top down using 
"the down and across lemma", lemma 12. That is we choose appropriate hues in 
the order 
i'(Zlr), 
i'(Z2r-), 
Xi(Z(nl)r), 
/i(Zl(rl)), 
i(Z2(r-l)). 
Xi(Z(n-1)0) 

### 13.1. Bannings. We also need to decide on what to ban at x+ (and its siblings).

Recall that for any y, if bl(y) is not a prefix of bl(y+) then we say that there is an 
unbanning at y+. 
First, what to unban. Suppose that bl(x) = [(c1, P1), 
(Cn, Pn)]A f*(x+) 
I 
Vp, for all i < n then put e = n; otherwise let e be such that %'*(x+) C VP,+ 
but '*(x?) 
, Vp, for all i < e. Then we are only going to keep (at most) 
- **[(cl, Pl), . . . (Ce, Pe)]** in the new banned list. Recall that any pairs from (Ce+2, Pe+2)
onwards are unbanned because their banning is deemed to be dependent on the 
banning of (Ce+i, Pe+l) which is now rescinded. 
Now let us consider whether we want to ban anything new. The general idea is 
to newly ban (* (x+), p) at x+ (and its siblings) if and only if * (x+) c Up and 
there are points y < z < x+ such that 
* the period (y, z) contained no unbannings and was over eH steps long (-we 
will see later that this is long enough for the process of cycling through hues 
to have covered all hues it will ever get to-) and 
* no colour in Vp appeared between y and x+. 
The order of listing these new banned pairs (if there are more than one) is 
determined by which Vp came up least recently in the past: the least recent ones go 
into the list first. Say that the order so determined for the new pairs is 
- **[(/'* (x+), q1), . .., (A'* (x+), ql)]** *
Recall that the purpose of this ordering as stipulated in K4B is to reflect a condi- 
tionality on the banning. 
All the new banned pairs are added after the ones surviving from bl(x). However, 
some of the new banned pairs might be more important to put earlier in the new 
banned list than some surviving (ci, pi) pairs. We just need look at qi versus 
P1, . . ., Pe. Suppose that in the past of x, the latest appearance of Vq,, if there 
was one, was before the latest appearance of VpJ (f < e) but after (or equal to) 
the latest appearance of Vp, for each i < f . Alternatively suppose that there has 
been no appearance of Vq, or Vp, for each i < f but that VpJ. has appeared. In 
either of those cases we throw away (Cf , pf 
. 
, (Ce, Pe) as well. We might say that 
(C. 
pf ), . . . (Ce, Pe) are usurped by (P *(x+) q1 . 
('* (x+), qi). Note that this 
counts as an unbanning. 
If, in the past of x, the latest appearance of Vq, was not strictly before the latest 
appearance of Vq, then we do not throw away any extra pairs. Put f = e +1. 
The new banned list is 
bl'(x+) = [(c1,p1),..., 
(cf.*1, pf-1) 
(A'*(x+),qi) 
(X+)ql)]- 
The banned list at all the siblings of x+ is the same as that at x+.

Note that we will see soon (in lemma 18) that no successor hue can be a hue of 
a currently banned colour: thus the colours we newly ban at a particular point are 
not already in the banned list. 
To preserve K4C we put bl'(zij) = bl(xj) for each i, j. 

### 13.2. A new chronicle? We check that (T', <=/

l', bi', Xo) is a new chronicle. 
It is clear that (T', <', =') is a finite floored Ockhamist frame satisfying PI and 
P2. P3 and P4 hold by construction. 
KG continues to hold and KI holds as the new hues we have used as labels were 
all chosen to be consistent. 
K2 follows from lemma 16(part 3) and our down-and-across construction. 
K3A-K4C and K5D all hold by construction. 
It remains to check that K5A, K5B and K5C continue to hold. First K5A. In 
this lemma we establish a sufficient condition for K5A to be preserved. It is a not 
particularly strong condition, allowing some flexibility in what we unban and newly 
ban, but it is clearly satisfied by our actual banning procedure. The lemma is crucial 
(and is where the new LC axiom is used) so we go into some detail in the proof. 

**Lemma 17.** *Suppose that h, h' E H(q$+) and B, B' E <' (C x {1, . . ., K}). Sup-*

pose that h' E Pn(h, B). Suppose that B = [(ci,Pi), . 
(Cpn)], 
m < n and 
B' = [(cipi),..). 
(cpn), 
(hl*,q),., 
(h/*,qi)], 
with h/* not in VP, for all i = 1.., 
m and h/* in Uq, for all i = 1,.., 1. Then 
I/ Yh'* 
>- E -cB1. 
PROOF. Suppose for contradiction that K Yh'* - 
F TB', i.e. that choosing the hue 
h' will inevitably lead to the new banning condition B' being contravened. 
First assume I > 0: we return to the case of I = 0 below. 
The case of I > 1 follows from the argument for I = 1 as, for each j, 
m 
i 
m 
K X((A 
-V-I P A -vqi) U2Yhf*) + x((A- 
VP, A ivq1) U2Yhf*) 
i=1 
i=1 
i=1 
showing that K TB; -> 
CB (with obvious definitions). 
So we now assume that 1= 1. 
If m = 0 then put 0 =false and otherwise put 
0 = X((--vp,) U yc,) V X((¬vp A ¬vp2) U y2c) V 
V X((¬vp, A- 
VP2 A * A -vp,,,) UyC,,) 
and 
'/ = X((¬vp, A- VP2 A * A -vp,}, A ivq1) UYhf*) 
so that CBX1 
V 0 V 0/ and our assumption is K Yhf* -- E(yI V 0 V 0'). 
Some basic uses of C9-C 13 gives us 
K (Yh'* A ¬Ei 
A ¬E) 
-> E0'. 
Let a= 
Yhf* A ¬F1 
A - E 0, and / 
= ¬vp, A A-vp,, A -vq so that Cll gives 
us K Ea -> E0'. 
Now a will hold at any point with hue h' which is also the successor of a point with 
banned list B (or even just the mr-long prefix of B). We have thus just established that

an =-class of points containing one satisfying a must begin a finite path witnessing 
0'. The next few steps of the proof will show that such a path will not pass through 
VpI,..., 
Vp,/, Vq1 (i.e., fi will constantly hold) and will end up at another point 
satisfying a. 
From F- Ea 
-> EX((E/3) 
UYhf*), CO-C13 allows us to deduce that F- a 

∎

E X((E /) 
U(Yhl* A (- EyI V E 1X))). Further uses, distributing connectives over 
disjunction gives us F- Ea -> (EX((E/3) U(yhl* A ¬Ey1)) V EX((E/3) U(Yhl* A 
E 1))). 
As F- F E 
->E 
I and F- E a 
> E 1, it follows that 
F- Ea -> EX((E/3) 
U(Yh,* A ¬Eyi)). 
Now[- EX((E/3) 
U(yh,* A--E 1 AEO)) 
> FO andsowecansimilarlyconclude 
that 
F- Ea -> EX((E3) 
U(Ea)). 
Intuitively, any point with hue h' which is also the successor of a point with 
banned list B must begin a finite path avoiding V.,,..., 
Vp,>,, Vq, and ending at 
another such point. What follows is a use of the LC axiom to allow us to deduce 
that such a point begins an infinite sequence of such finite paths joined end to end. 
By generalization we have 
F- A G(Ea - EX((E/3) U(Ea))) 
and so modus ponens and the LC axiom give us 
[-F Ea - EG((E13) U(Ea)). 
The infinite path is clearly bad: a short proof using the PLTL system gives us 
F- G((E/3) U(E a)) -> Z 
as h'* is in Uq, and not in Vql. This needs the assumption that Vq, n Uq1 0. 
Putting these together we get 
F- Ea -> Ey 
which, by using C9-C13, gives us 
F- (Yhf* A ¬Ey1 A ¬ES) 
-> Ey1. 
Thus, from F- A h' -> Yh*, it follows that the formula (A h' A - Fx A -E 0) is 
inconsistent. 
The following claim gives us our contradiction to h' E Pn (h, B): it is not accept- 
able to choose the hue h' at a successor to a point with banned list B. The proof 
above has established that the hue h' necessarily begins a fullpath which is either 
bad or satisfies 0. 
The claim is that F- (Ah AXAh') 
-> E'B, ie h' f Pn (h, B). 

*Proof.* From above we have, F- A h' -> E(Z1 V 0).
Also, as h'* is not in any VP, F- Ah' -> A>=I -VP1 and so [- Ah' -> E(1 V

By C14, F- XE, 
- 
EX C (for any C), so 
m 
i 
F- xAh' 
--e E(Xyi V V x((A -vpi) U yc)). 
j=l 
i=l 
And[-Xyi 
->yi sol- (AhAXAh') 
->E(y1V 0). Itisclearthat[-E(yIvO) 
> 
E TB and the claim is proved. 

∎

The case of I = 0 is a simplified version of the above: it follows almost immediately 
from the initial assumption that A h' A E Xi A E 0 is inconsistent. We then just 
use the claim above to conclude the argument. 

∎

Now we must show that K5B continues to hold. First consider x which we have 
just given a successor. 

**Lemma 18.** *If (c, p) occurs in bl(x) then we do not have A`*(x+) = c.*

PROOF. Assume otherwise and suppose that bl(x) = [(cl, pi),.. 
(Cn, Pn )]. As 
A'(x+) E Pn(A, bl(x)), we have 
vAA/\(x) Ax A AI(x+) >- E(ZI A (- vP,) Uycl A ..A 
(- vp, A 
A -vp,,) UyCn" 
and il*(x+) = cj for some j. Now we can not have -vP,..., 
vp, all in A(x) 
because then 
k- A\(x) 
Ax A I'(x+) 
VP 
(( 
I A ..A 
--vp;) U Yci) 
Thus there is some i < j with -vpi 
A 
A(x), i.e. A*(x) is in VP,. Thus (ci, pi) 
would have been unbanned at x if it was in the banned list of the predecessor of x. 
The only way it could be in bl(x) is if it was put in at x. Thus ci is A* (x) and ci in 
Upi. Given lemma 13, this contradicts our assumption about the Rabin automaton 
that each Up, n VP, is empty. 

∎

K5B continues to hold for any old points. It remains to check it for the zi1 
as the zj do not have successors. However, bl'(zij) = bl(x1), by definition, and 
i'* (zi) =-A* (xj), by the construction using the down and across lemma, so we just 
need to call on K5B for xi to give us our result. 
From lemma 18 we can see that K5C also continues to hold. This is because the 
pairs (c, p) which are added into the banned list bl'(x+) all have c = i'* (x+). By 
lemma 18, such pairs do not appear amongst the pairs which are inherited from 
bl(x). We also do not add repeats amongst the new pairs. 

## §14. The limit. If we begin with the simple starting chronicle described above

(lemma 14) and continue to cure defects, i.e. add successor points, using lemma 15 
in such a way that every point eventually gets a successor, then we clearly end up 
with a chronicle satisfying P1 and P2. 
The limit chronicle (T, <, _, A, bi, Xo) has a few extra properties: 
LI every point has an immediate successor; 
L2 and every point has a pioneer above it.


### 14.1. A Kripke structure. Now we use the standard correspondence between a

(N x W)-frame and a bundled ω-tree (as described above in section 4). The tree 
can be seen as a Kripke structure and this will be our model. 
Let S = T/-. 
Define R C S x S by (s, s') E R if there is some t E s with 
t+ E s'. This is total. Defined: S -> p(L U Q) by p E g(s) if there is some t E s 
with p E A(t). Thus (S, R, g) is a Kripke-structure. 
For each t E T we shall write [t] for the --class t/= E S. By K3A and K4C, we 
can define A* ([t]) = A*(t) and bl([t]) = bl(t) and these are well-defined. 
For each t E T define a sequence to, tl,... 
by to = t and tj+j = t[+. This gives us 
a fullpath up(t) = ([to], [t1], [t2],... 
) in (S, R). 
It is important to realise that the up(t) are generally not the only fullpaths through 
the Kripke structure (S, R). As we have seen in the example in section 4, there maybe 
other "emergent" fullpaths. Recall that a fullpath through (S, R) is any sequence 
so, s,.... 
from S such that each (si, si+ ) E R. It may not be possible to find some 
t e so such that each tj is in si. A lot of the work we have done and we still have to 
do will be to make sure that we can handle these emergent fullpaths along with the 
constructed up(t) ones in the truth lemma. 
Note that as (T, <, _) is floored, with [Xo] as the floor, for every s E S there is a 
fullpath starting at [Xo] and passing through s. 

### 14.2. Universal non-acceptance. In this subsection we show that no fullpaths, not

even emergent ones, are bad: none are accepted by the automaton A. We show that 
along any fullpath in (S, R) we do not have some i = 1, . . ., K such that there are an 
infinite number of labels along the fullpath containing an atom from Uj but only a 
finite number containing an atom from V1. Recall that this is a crucial observation 
to allow the truth lemma to work. 
We will talk of colour-index pairs becoming newly banned and unbanned along 
a fullpath and of lulls (in unbanning) along a fullpath. These terms are defined in 
the analogous way to the respective terms for points in the chronicles in terms of the 
banned list bl(si) at each --class s5 along a fullpath. Equivalently we could define 
them by inheriting the terms from any <-related _-class representatives. 
First a helpful lemma implying that there are infinitely many lulls along any 
fullpath. 

**Lemma 19.** *Along any fullpath (so, si,... ) in (S, R) there are infinitely many dif-*

ferent pairs of indices (j, k) such that k > j + eH and there is no unbanning at any 
t e si with j < i < k; i.e there are infinitely many lulls. 
PROOF. Assume otherwise for contradiction, i.e there are only finitely many lulls 
along the fullpath. Thus there must be some pair (c, p) which is newly banned and 
unbanned infinitely often. To be newly banned infinitely often, c must come up as 
A* (si) infinitely often (K5D). There are two cases. 
A colour in Vp may come up infinitely often along the fullpath. But then after 
the end of the last lull, and after a subsequent appearance of a colour in Vp, (c, p) 
can not be newly banned (K4A). So this case does not occur. 
Thus we may assume that colours in Vp only come up finitely often along the 
fullpath. Consider the non-empty set G of such pairs (c', p') with c' e Up, ap- 
pearing infinitely often, colours in Vp, appearing only finitely often and the pair 
(c', p') being newly banned and unbanned infinitely often. Of all the pairs in G,

find one (c', p') of those such that the very last appearance of a colour in Vp, along 
the fullpath is earliest. 
Now find an index i after the end of the last lull along a = (so, sI, . . . ) and after all 
the colours not in infc(a) = {c E C Ic = A*(sj) for infinitely many j} have stopped 
coming up forever. Find a later index after all the colours in inf(a) have come up at 
least once subsequently. Also, wait until from then on, the only pairs being added 
or taken away from the banned lists are those which will do so infinitely often. Find 
the next index at which (c', p') is newly banned. 
We can show that (c', p') can never subsequently be unbanned and this will be 
our contradiction. If it is unbanned then it is not because a colour in Vp, has come 
up. Thus, there must be a pair (d, q) before (or equal to) (c', p') in the banned 
list which either gets directly unbanned (by Vq coming up) or gets usurped by an 
"older" pair. 
Because (d, q) is before (or equal to) (c', p') we know that the most recent 
appearance of Vq was before or equal to the most recent appearance of Vp, (K4B). 
This was long enough ago for us to deduce that Vq only comes up finitely often: 
no colour in Vq has come up since i and yet all members in infc(a) have. Thus the 
unbanning is not because Vq came up. 
This leaves the possibility that a colour e E U, comes up such that the most recent 
appearance of Vr was strictly before the most recent appearance of (d, q) and so 
strictly before the most recent appearance of Vp,. It is clear that (e, r) is in G: e 
has come up since i, no colour in Vr has and yet the colours coming up since i are 
precisely those that come up infinitely often. But then we have a contradiction to 
the choice of (c', p'). Such an e is thus not a possibility. 
This completes the proof. 

∎

So now let us state our main claim. Recall that we say that a colour is in Vs (or 
Us) if it has a hue containing an atom which is in Vs (or Us respectively). 

**Lemma 20.** *Along any fullpath (so, si, . . . ) in (S, R) we do not have some i =*

1, . . ., K such that there are an infinite number of js with A* (sj) in Uj but only afinite 
number of js with A* (sj) in V1. 
PROOF. Suppose for contradiction that there were such a fullpath i = (so, s1,...) 
in (S, R) and such an p = 1, . . ., K. Say that the colour c E Up comes up infinitely 
often (as A* (sj)) but no colour in Vp does. 
Consider the non-empty set G of such pairs (c', p') with c' E Up, appearing 
infinitely often, and all colours in Vp, appearing only finitely often. Of all the pairs 
in G, choose one (c', p') of those such that the very last appearance of any colour 
in Vp, along r is earliest. The rest of the proof is similar to that of the previous 
lemma. 
Find an index i after all the colours not in inf(2t) 
{c E CIc = 
A*c(s) 
for infinitely many I}, (so including all those in Vp,) have stopped coming up 
forever in r. Find a later index after all the colours in inf (7), have come up sub- 
sequently. Using the last lemma we know that there are infinitely many lulls along 
2r so we can find an even greater index after the end of a subsequent lull. Find the 
next index i' at which c' comes up. Clearly (c', p') will be put in the banned list 
here.

We claim that it is never subsequently unbanned. If it is unbanned then there 
must be a pair (d, q) before (or equal to) (c', p') in the banned list which either gets 
directly unbanned (by Vq coming up) or gets usurped by an "older" pair. 
Because (d, q) is before (or equal to) (c', p') we know that the most recent 
appearance of Vq was before or equal to the most recent appearance of Vp,. This 
was long enough ago for us to deduce that Vq only comes up finitely often. Thus 
the unbanning is not because Vq came up. 
This leaves the possibility that a colour e E Ur comes up such that the most recent 
appearance of Vr was strictly before the most recent appearance of (d, q) and so 
strictly before the most recent appearance of Vp,. As in the proof of the previous 
lemma, it is clear that (e, r) is in G. But then we have a contradiction to the choice 
of (c', p'). Such an e is thus not a possibility. 
So we can conclude that (c', p') is never subsequently unbanned. By K5B, this is 
a contradiction to our assumption that c' comes up infinitely often. 

∎


### 14.3. Hue scheduling. Assuming that there is no unbanning going on, how long

does it take to try all the possible hues which are ever going to come up? Here we 
will show that eH - 
2 H(0q)I 
steps is long enough. 
Our result follows from the following graph theoretic result. 
Suppose that we have a finite set H and a sequence of relations E = (Eo, E1,...). 
Denote {h' e H IEhh'} by E (h). Call (H, E) an evaporating graph iff P for all 
h e H, Ei+1(h) C E (h). 
For a finite sequence a = (ho, h1, . . ., hn-1) let I a 
n and for a an ω-sequence 
let Jul = co. 

**Definition 7.** We say that a finite or co sequence ho, hl, h2, ...

from H is a fair 
path through the evaporating graph (H, E) iff each hi+1 E E (hi) and each hi+1 
is either new (not seen so far as hj for j < i) or all the elements of E (hi) have 
appeared before and hi+1 is the one which appeared least recently. 

**Lemma 21.** *Suppose that (H, E) is an evaporating graph and n = (xo, xl,...*

) is a 
fair path through it. Then 
(i) X21HI already occurs in {x i IO 
i < min(21HI, 
Iz)}, and 
(ii) ran (7r) = {xilPi < l1r1} 
C fxil? 
< i < min(2 1HI, 
17E1)I- 
PROOF. (A more reader friendly version courtesy of the referee.) We prove (i) and 
(ii) by induction on IHI. Note that (ii) easily follows from (i) by a subinduction. 
To prove (i) let k = 2H1 
so 2IHI = 2k. Suppose for contradiction that the 
claim does not hold: that is, all the elements xo, 
X2k 1 are distinct from X2k. It is 
easy to see that now any subsequence (xi, xi+1, . . 
.. 
x) with 0 < i and i < 2k must 
be a fair path through (H', E') where H' = H \ {xi } and each E (h) = E (h) n H'. 
Hence, from IH(i) on the path (Xk1, 
X2k-1) it follows that X2k-1 occurs earlier 
on the list, say, as Xa with k - 1 < a < 2k - 2. Now if X2k occurs somewhere 
in the sequence (xO. 
, Xa+1) we are finished, so suppose otherwise; in particular, 
this means that X2k 
Xa+?1. Now consider the sequence (xO, . . ., Xa+1) which is a 
fair path through (H', E'), so by IH(ii) Xa+1 has already appeared in the sequence 
(xO, . . ., Xk-1). 
But then it is unfair not to take X2k as Xa+1. 

∎


Let xo be a point in our limit construction. Suppose that its successors are 
Xn+1 = X+. Let hi 
A(xi) for each i. Suppose that the banned list bl(xi) at xi is 
Li. 
We show that, if there is no unbanning between xo and XN 
i.e. LO < LI < 
... < LN (prefix inclusion) 
and eH< N then there is i E {O 
0, 1 
, eH } such that 
hi = hN 

**Lemma 22.** *Suppose that a = (ho, hi.... ) is a finite or infinite sequence of hues*

from H(0+) and (LO, L1.... ) is a sequence of elements of C x {1, . . ., K} such that 
1. each hi+1 E Pn (hi, Li) 
2. each Li < Li+, 
3. each hi+1 is either new or is the least recent member of Pn (hi, Li) to show up. 
Then {hili < lul} C {hili < eH}. 
PROOF. For all i, for all h let Ei(h) = Pn(h,Li). As Li < 
i ⊢_L 

∎

> 
- 
Li+ 
and so Ei+1 (h) C Es (h). Thus (H(0+), E) is an evaporating graph. 
Clearly (ho, hi, ... ) is a fair path through it and so lemma 21 gives us the result. D 

## §15. Truth lemma. KO and the truth lemma below gives us our result as (S, R, g),

up(Xo) I= q$ 
For each a e cl /, for each t e T, 
a E A (t) iff (S, R, g), up(t) 1= a 
PROOF. By induction on the construction of a. 
p, (m): As up(t)o is just the =-class of t, p E g(up(t)o). 
p, (I=): 
So there is some t' _ t such that p E A(t'). By K1, K3A and lemma 11, 
P E i(t). 
true, -a, a A /6, (X): 
Use the fact that A(t) is maximally consistent in hc1 A+ 
and the inductive hypothesis. 
X a, (>): 
By K2 and LI, a E A(t+). 
By the inductive hypothesis, 
(S, R, g), up(t+) 
( a. By definition of up and the semantics of X, (S, R, g), up(t) I 
X a as required. 
X a, (I=): 
So (S, R, g), up(t+) 
( a. By the inductive hypothesis, a e A (t+). 
By K2, KI and lemma 10, Xa e A (t) as required. 
a U/P, (*): 
Say that a UPi e A(t). Recall that we have let to = t and defined 
each ti+1 as the immediate <-successor of each ti. We are going to use the fair 
scheduling idea to show that /i must turn up in some A(ti) with a in all the labels in 
between. 
If / E A(t) then, by IH, (S, R, g), up(t) I= / and we have our result. 
Otherwise, as A(t) is consistent we have a e A(t) by axiom C7. Also by K2, 
A(to)RxA(t1). Thus there are MCSs F and A such that A(to) C F, (F, A) e Rx and 
A(tl) C A. By C7 we must have /i V (a A X(a U/i)) E F. As we have assumed 
that i ~ F, we have X(a U/i)) E F. By definition of Rx, a U/ 
E A. Thus 
a U/i c A(t). 
Continuing in this way we either find some n > 0 such that i E A (tn) and for all 
j, if 0 < j < n then a e A (tj) (which means we are done) or a, a U/i and ¬f/ are

in each A(ti) for i > 0. We must rule out this latter case. Assume for contradiction 
that it happens. 
If we follow up(t) up high enough then all the points in up(t) above there will be 
pioneers of their -=-classes (L2 and P2). Call this the pioneering region of up(t). 
Eventually, in the pioneering region of up(t) there is a lull from unbanning: this 
follows from the infinite lulls lemma 19. Choose any one lull totally contained in the 
pioneering region. We work within the pioneering region because we need to use 
properties of fair scheduling of hues and in other areas of the structure hues are not 
necessarily chosen fairly, they may be chosen by the down and across construction. 
Say that the banned list at the end of the lull (i.e. after eH steps) is B. Note 
that because there is no unbanning during the lull, the banning restrictions become 
stricter: colours which are allowed by B, so to speak, are allowed all through the lull. 
The general idea now is to consider a hypothetical construction which continues, 
after the end of the lull, fairly choosing a sequence of hues under the assumption 
that the banning list remains fixed as B. We use the fair scheduling idea to conclude 
that any hue which can ever come up above here must have come up during the 
lull. Because a UPf is a consequence of the hues here (so fi should come up in the 
future) but so is -',6 (so fi does not come up) we will derive our contradiction. 
Say that the lull starts at tn and so extends to tn+eH. 
For i = n,..., n + eH, put 
Bi = bl(ti) and hi = A(ti). Let B = Bn+eH, the banned list at the end of the lull. 
We have assumed that a, a U/i and ¬f/ are in each hue hi with n < i < n + eH. We 
can also conclude (from K4A part 2) that for any such hue h, for any pair (c, p) 
occurring in B, h is not in Vp. 
To derive a contradiction we need to consider the set of hues which would come 
up infinitely often if we continued forever fair scheduling of hues respecting a fixed 
banning condition B. So now we see how to recursively choose hi for each i > n + eH 
such that V A 
F TB . The inductive hypothesis (ih') that we can do so holds for 
n + eH. Assume (ih') true for i > n + eH. By lemma 16, Pn(hi, B) is non-empty. 
Select hi+, E Pn(hi, B) fairly in terms of the previous h1(j = n, .. ., i). We also 
know that hi+, is not in any Vp for p mentioned in B: lemma 22 implies that hi+, 
has come up during the lull in the actual construction and we have just seen that it is 
impossible that such a p is mentioned in B. By lemma 17, the inductive hypothesis 
(ih') holds for i + 1. 
We put I = {h E Ha+ Ih = hi for infinitely many i}. 
Note that by the hue scheduling lemma 22, all the hues in I came up during the 
lull in the actual construction, i.e. as hi for some i with n < i < n + eH. Thus we 
have 
V1) for all h E I, a, a UP and -, 
are in h; 
V2) for all h E I, h is not in Vp for any p mentioned in B; 
V3) for all h E I, V A h - E TB (from ih' and the fact that 
yh* 
>- 
EAh). 
Let 0 = VhcI A h: so 0 says that a point satisfies one of the hues in I. Fair 
scheduling allows us to conclude that 0 must be preserved from point to successor 
(unless we contravene the B restriction): 

**Lemma 23.** *F- 0 -3 (XO V EB).*

PROOF. Suppose not, i.e. there is an MCS F extending 0 A - E TB A - X 0. Let A 
be the MCS containing {f(5 X(5 e F}. Let hi = F n hcl q+ and h2 = A n hcl q+. It

is clear that hI E I but h2 X I. We are done if we show that h2 E Pn(hi, B): if hI 
comes up infinitely often then so should h2 and this would imply that h2 should be 
in I. 
For contradiction suppose that F- A h A X A h2 -> E TB. But then F would be 
inconsistent. 

∎

The rest of this argument is a fairly straightforward proof theoretic version of 
the idea that it is contradictory to have 0 holding forever when it implies fi is both 
eventually true and never true. The only complication is the constant assumption 
associated with the banning condition. 
By V2, we have F- 0 > AP mentioned in B 'VP so that some simple uses of CO-C1 3 
gives us F- (0 A XE TB) -> ETB. 
Combining this with lemma 23 gives us 
F- (0 A -ETB) 
-> X(0 A -1ETB)) 
By generalization and C6, F- 0 A -F TB -> GO. 
We have noted in VI that a, a U/P and -,/ are all in each h E I. Thus each 
F- Ah -, (aA(a U P)A -AP). ThusF- 0 -* 
(aA(a 
U/3)A -/). 
ThusF- (OA -ETB) 
-) 
((a UP)AG A-/). 
ByC8, F- 0 --ETB. 
Nowchooseanyh 
E I. ThusF- Ah -*0 
and so F- A h -* E TB contradicting V3. 
So we are done. 
a U/i, (<=): 
Suppose that (S, R, g), up(t) F a U/P. Say up(t) = (SO, S1, S2...) 
which are the classes of t 
to < t1 < t2 < ... respectively. 
So there is i > 0 such that (S. R g), (Si, Si+, Si+2, 
and for any j, if 
0 < j < i then (S. R. g), (Sj, Sj+l, Sj+2..).. 
a. 
By IH, P E A (ti). If i = O then we are done. Otherwise, ifO < j < i then a e A (tj) 
and without loss of generality we can assume -, 
E A(tj). Also a e A(to). Suppose 
for contradiction that -(a U/i) e A(to). By C7, -(a U/i) E A(th). Continuing in 
this way we show that -(a U/i) e A(ti) and /i e A(ti) contrary to C7. 
Ea, (=>): 
So Ea e Ai(t). By the lemma below, there is a hue h' of i*(t) 
with 
a E h'. Say that t" is the pioneer of the =-class of t. So i* (t) = i* (t") and to has a 
sibling, t' say, with A (t') = h'. So t' 
t and a e A (t'). By IH, (S, R, g), up(t') K a. 
But up(t')o = up(t)o is the =-class of both t and t'. So (S, R, g), up(t) K E a. 
LEMMA 
24. If E a E cl E and E 
E h e H(0+) and h is consistent then h * has a 
hue h' such that a E h'. 
PROOF. Just extend h to an MCS F. Let E 
{a} U {fPIAfl E F}. This is 
consistent by C9-12. Extend E to an MCS A. Let h' = A n hcl h+. 
To show 
* = h *, just consider any Ebb for b E p fcl A+): it is clearly in A if it is in F. 

∎

Ea. (a, 
): 
Say (S,R,g),up(t) 
}= E a. Let b be an R-path through S starting 
at bo = [Xo] and going through bN = [t] such that (S, R, g), b>N F a. We are to 
show that E a is in A(t). 
As has been mentioned, emergent paths cause the trouble here because b might 
be emergent and thus not of the form up(t'). If b was up(t') then we could use 
the inductive hypothesis to immediate effect. If we were attempting a completeness 
proof for a bundled logic then we could have defined the bundle to contain only 
paths of the form up(t') and so we would thus be able to conclude the proof.

Instead, we need some other guarantee that we have E a in A(t) and it is here that 
the automaton, the fresh atoms and the banning procedure are brought together. 
Recall that concept of bad fullpaths plays an important role here. These are full- 
paths which are accepted by A. First we clarify how a linear automaton recognizing 
sequences of subsets of ecl 0 can have a run along a fullpath through the Kripke 
structure. Define an ω-sequence a of subsets of ecl <b via E3 c ai iff there is some 
te E bi such that E5 E A(t1{). We intend A to read the E5 formulas in the labels 
along b: by lemma 1 1, this is well-defined. 
We know that (S, R, g), b>N F a. Our truth lemma inductive hypothesis is now 
able to be used to show that cY>N 
da. This is partly just the observation that the 
truth of CTL* formulas along fullpaths is determined by the linear arrangement of 
truth of E 
subformulas along the fullpath. We need the inductive hypothesis in 
the truth lemma to relate truth of these formulas to the contents of labels (which is 
how a is defined). That c>N 
- a follows from: 

**Lemma 25.** *For all linear temporal combinations /3 of the subformulas of a, for*

all i, 
u~i += P iff(S, R, g), b~i 
A 
PROOF. By induction on the construction of f. The cases of true, atoms, negation, 
conjunction, X and U are immediate. This leaves the case of E /? being a subformula 
of a. 
If u>i l= Ei then EFi E A(t') for some t' E bi. By the overall inductive 
hypothesis, (S, R, g), up(t') F EP and so (S, R, g), b>i FE P. 
Conversely, (S,R,g),b>i 
F/ P implies that (S,R,g),up(t') 
I= E/ for any 
t' E bi; now apply the overall inductive hypothesis (on a). (Note that the inductive 
hypothesis appliesonly to paths of the form up(t).) So we have E/ E A(t') and by 
definition, P>i 
E F/, as required. 
a 
Next, in preparation for recognizing bad paths, we show that the distribution of 
Q atoms along the path represents the run of the automaton A along b. Consider 
the run (qo,q, ...) of A on c. 
LEMMA26. For all i < co, for all s e Q, we have s E g(bi) iff s = qi. 
PROOF. We prove this by induction on i. After we prove the converse direction, 
the forward direction follows from lemma 13 and lemma 11. The case of i = 0 
follows from KG. Now assume that the hypothesis holds for i > 0: we show the 
converse direction for i + 1. Thus we are to show that qi+i E g (bi+ ). 
Let c = {/i e ecll// 
e cia}. Now choose some ti e bi with tt E bi+e. 
By 
the inductive hypothesis and lemma 11, we will have qi c A(ti). I claim that 
each conjunct of Cc is in A(ti): lemma 13 will then tell us that, as qi j 
A(ti), 
qi+l = p(qi, c) E A(tt). This gives us qi+l E g(bi+ ) as required. 
To prove this claim we need consider conjuncts of two forms: E q E c and E VI 
for E 
E ec /E \ c. 
If E qi cc then E 
e ai. Thusthereissomet' 
e bi suchthatE 
c c A(t'). By 
lemma 11, E q E A(t). 
If E tc E ecl X \ c then Eqi y 
ai. Thus there is no t' c bi with E qi c A(t') and, 
in particular, E y1 f A (t). As ecl h 
C fhl /+, and, A(t) is maximally consistent in 
fcbl +, we have- E V E A(t) as required. 
El

From the facts that c>N 
+ a and that we were able to ensure that each fullpath, 
and in particular b is not bad, it follows that c>N 
W Ea: 
LEMMA27. 
U>N 
W Ea. 
PROOF. Suppose not for contradiction. So a 1= ¬O and A accepts C. Thus there 
is some i = 1, . . ., K such that the run (qo, q1, . . . ) of A on a contains only a finite 
number of occurrences of states in Vi but an infinite number of occurences of states 
in U1. 
Thus, by lemmas 11 and 26, along b, atoms in Vs are in the labels only finitely often 
while atoms in Uj are in the labels infinitely often. By universal non-acceptance 
(lemma 20) this can not happen. 

∎

By definition of a and lemma 11, Ea e A (t) and we are done. 

∎


## §16. Examples.

1. The following validity is one that can be used as an axiom to capture limit 
closure in the CTL language: 
AG(p ->EXp) 
-> (p ->EGp). 
To derive it in our system use the LC axiom 
A G(E p - 
E X( (Efalse) U(E p))) -> (E p - 
E G((Efalse) 
U(E p))) 
after showing F p ↔ E p and F p ↔ ((Efalse) U((E p)). 
2. This example comes from [Stirling, 1992]: 
F- AG(Aa 
-> EXFA 
a) 
> (A a - 
EGFA a). 
To derive it, simply apply the LC axiom 
A G(E A a 
> E X((E true) U(E A a))) 
>(E A a -> E G((E true) U(E A a))) 
after showing F E A a ↔ A a. 
3. We prove the following using both AA and LC: 
k (A G(p - E X r) A A G(r - E X p)) - (p - E G(F p A F r)). 
If every p place has an r successor and every r place has a p successor then there 
is a fullpath on which both p and r hold infinitely often. The idea behind the proof 
we present involves the setting up of an automaton with three states b, c and e. We 
establish the existence of a path on which it alternates between state b at a place 
where p holds and state c at a place where r holds. The state e will indicate that we 
have gone astray. 
To use the AA rule we define L 
{p, r} and Q = {b, c, e}. The specified set of 
formulas using atoms only from L contains al 
-=p A -r, a2= 
¬p Ar, Y3= p A -ir 
and a4 
p A r. The function p : (Q x { 1, 2, 3, 4}) 
Q (capturing the transition 
table of the automaton) is given by: 
p 
11 2 13 l4 
b 
e e 
c e 
c 
e be 
b 
e 
e 
e 
e 
e

The functionally L + Q-expandable formula 0 is b A 01 A 02 where 
01 =AGAA(q 
A ai -* A Xp(q, i)) 
Q i 
and 
02=AGA- 
(qAq'). 
q~lq' 
Let y = A G(p -* EXr) 
A A G(r -* EXp) 
and o = y A --e A 01 A (p V r). 
In the full derivation there are long stretches of reasoning within ⊢_B (bundled 
derivability) including PLTL reasoning. This can be quite subtle (eg., using the 
induction C6) but we will omit such steps. For our purposes, we just concentrate 
on the couple of steps where LC and AA are used. 
We have ⊢_B E a -* E X E a from which more bundled reasoning gives us 
⊢_B A G(E a -* E X((Efalse) U(E a))). 
The LC axiom (and modus ponens) allows us to conclude 
F E a - E G((Efalse) U(E a))). 
from which we easily derive F- E a -* E G E a. 
As ⊢_B (y A 0 A p) -* Ea and ⊢_B Fa -* --e we conclude that 
(1) 
F- y A A p -* EG -e 
i.e. under the given assumptions, there is a fullpath on which the automaton never 
visits e. 
It is interesting to note here that, although the acceptance criteria of the automa- 
ton do not play a part in the AA rule, we are bringing them in here: the automaton 
playing its role in guiding our intuitions in this derivation, accepts exactly paths 
which never visit e. In this derivation we are looking for a path which is accepted 
by the automaton. 
Some PLTL reasoning (guided by intuitions about the transition function) gives 
us 
⊢_B (G -e A0) - (G(p -Xr) A G(r - Xp)) 
and 
⊢_B (pA G(p -* Xr) A G(r -Xp)) 
-* G(Fp A Fr). 
Bringing (1) in as well gives us 
F- 0 -* (y A p - E G(F p A F r)) 
and so the AA rule gives us 
Fy A p - EG(Fp 
AFr) 
as required. 
Note that it is very hard to see how this could be derived without the AA rule. 
Using LC we could certainly derive that from y A p it follows that there is a fullpath 
on which p holds infinitely often and on which either p or r holds at each state. 
However, to deduce that both p and r hold infinitely often seems beyond the 
capabilities of LC. In order to do away with AA one may propose other forms

of limit closure axioms which can cope with two events being required to recur. 
However, an infinite set of axioms will probably be needed to cope with any number 
n of such recurring events. 
4. Here is another example using both the AA and LC rules: 
let y = A G(p -* EX((-iq) U(¬q A X p))) A A G(p -* EX(q U(q A X p))); 
let s = GF(¬q A X p) A GF(q A X p)) A G(((--q) U p) V (q U p))); 
and we will show F- y - 
(p - 
Es ). 
Use al = -p A -q, a2 = -p A q, a3 = p A -q and a(4 
p A q along with 
Q= {bo,..., bio} p given by: 
I_ 
4-p A-q 
-p A q p A-q 
p A q 
bo 
b3 
b4 
b2 
bi 
b1 
b3 
b4 
b5 
b5 
b2 
b3 
b4 
b2 
b 
b3 
b3 
blo 
b2 
b 
b4 
b4 
b5 
b5 
b5 
b8 
b6 
b7 
b6 
b8 
bo 
bo 
b7 
b8 
b6 
b7 
b8 
b8 
b6 
b7 
b9 
blo 
bo 
bo 
blo 
blo 
blo 
blo 
and the corresponding expandable formula 0 = bo A 01 A 02 analogous to that in 
the last example. 
The automaton which guides our intuition is defined by the transition table above 
with acceptance determined by bo coming up infinitely often. The reader can check 
that any path accepted by this automaton is a model of 6. To see this note that the 
initial state bo is only reached again after b5 has been visited and ¬q immediately 
followed by p holds (i.e. ¬q A X p has been true). The state b5 will only be reached 
after bo when q A X p has just held. The states b1 - b4 record the progress between 
bo and b5: for example, b1 indicates that p A q has just been seen while b4 is 
encountered during a sequence of q A -p states. The states b6 - bg are for similar 
purposes in recording the progress between b5 and bo. If ((¬q) Up) V (q Up) is 
ever violated then the automaton ends up in the sink state b1o (and so does not 
accept the structure). 
Define a = y A bo A 01 A 02. We can show that when a holds then it holds 
again at some later state: ⊢_B A G(Ea 
-* EX((E true) U(Ea)). 
The LC axiom 
allows us to deduce that then there is a fullpath on which a holds infinitely often: 
E a -> EG((Etrue) 
U(E a)). 
Now EXEaa holds at the root: ⊢_B y A p A 0 -* EXEa. 
Any path of recurring 
E a is accepted by the automaton and so satisfies 6: ⊢_B G((E true) U(E a)) -* 
. 
Putting these together we deduce that there is a fullpath satisfying 6: K 0 -* (y - 
(p -* E)). 
The AA rule finishes the derivation.

Again, this example would be a good test of any alternative axiom systems. It 
is not good enough here just to establish that there is a fullpath on which either 
E(q U(q A X p)) or E((-q) U(-q A X p)) holds at every state and that both these 
formulas hold infinitely often. Instead, it is required that either q U(q A X p) or 
(¬q) U(¬q A Xp) holds along the chosen fullpath at every state (and each holds 
infinitely often). 

## §17. Conclusion. We have been able to give a simple axiomatization of validity

in standard CTL*. 
Interesting aspects of the system include a very intuitive limit closure axiom and 
a slightly complicated, but possibly more generally useful, rule for the systematic 
introduction of fresh atoms into a proof. 
Interesting aspects of the completeness proof include the use of a linear Rabin au- 
tomaton and the use of a new banning mechanism working alongside a strict variant 
of the usual scheduling mechanism in the vaguely filtration-based construction. 
The result and proof suggest several avenues for future work. The most important 
question regarding this axiomatization is whether the auxiliary atoms rule is really 
needed. Even if the rule is not needed, and especially if it is, there is the possibility 
of using it to good effect in other similar logics such as other branching time 
logics, including those from philosophical logic, or in more general areas of modal 
and temporal logic reasoning. Interesting examples are the CTL* logic with past 
operators from [Zanardo and Carmo, 1993] as well as the long-unaxiomatized logic 
of historical necessity. 

## References

- **[Bernholtz and Grumberg, 1994]** 0. BERNHOLTZ and 0. GRUMBERG, Buy one, get onefree!!!, Temporal
logic, Proceedings of ICTL'94 (D. Gabbay and H. Ohlbach, editors), LNAI, no. 827, Springer-Verlag, 
1994, pp. 210-224. 
- **[Burgess, 1980]** J. P. BURGESS, Decidabilityfor branching time, Studia Logica, vol. 39 (1980), pp. 203-
218. 
- **[Clarke and Emerson, 1981]** E. CLARKE and E. EMERSON, Synthesis of synchronization skeletons for
branching time temporal logic, Proc. IBM Workshop on Logic of Programs, Yorktown Heights, NY 
(Berlin), Springer, 1981, pp. 52-71. 
- **[Dam, 1992]** M. DAM, R-generability, and definability in branching time logics, Information Processing
Letters, vol. 41 (1992), pp. 281-287. 
- **[Emerson, 1983]** E. EMERSON, Alternative semantics for temporal logics, Theoretical Computer Sci-
ence, vol. 26 (1983). 
- **[Emerson, 1996]** 
, Automated temporal reasoning for reactive systems, Logicsfor concurrency 
(F. Moller and G. Birtwistle, editors), Springer Verlag, 1996, pp. 41-101. 
- **[Emerson and Halpern, 1982]** E. EMERSON and J. HALPERN, Decision procedures and expressiveness
in the temporal logic of branching time, Proc. 14th ACM Symp. on Theory of Computing, 1982. 
- **[Emerson and Halpern, 1986]** 
, 'Sometimes' and 'not never' revisited: on branching versus 
linear time, Journal of the ACM, vol. 33 (1986). 
- **[Emerson and Jutla, 1988]** E. EMERSON and C. JUTLA, Complexity of tree automata and modal logics
of programs, 29th IEEE Foundations of Computer Science, Proceedings, IEEE, 1988. 
- **[Emerson and Sistla, 1984]** E. EMERSON and A. SISTLA, Decidingfull branching time logic, Information
and Control, vol. 61 (1984), pp. 175-201. 
- **[Emerson, 1990]** E. A. EMERSON, Temporal and modal logic, Handbook of theoretical computer science
(J. van Leeuwen, editor), vol. B, Elsevier, Amsterdam, 1990.

- **[Gabbay, Hodkinson, and Reynolds, 1994]** D. GABBAY, I. HODKINSON, and M. REYNOLDS, Temporal
logic: Mathematicalfoundations and computational aspects, vol. 1, Oxford University Press, 1994. 
- **[Gabbay, 1981]** D. M. GABBAY, An irreflexivity lemma with applications to axiomatizations of con-
ditions on tense frames, Aspects of philosophical logic (U. Monnich, editor), Reidel, Dordrecht, 1981, 
pp. 67-89. 
- **[Gabbay, Pnueli, Shelah, and Stavi, 1980]** D. M. GABBAY, A. PNUELI, S. SHELAH, and J. STAVI, On the
temporal analysis offairness, 7th A CM Symposium on Principles of Programming Languages, Las Vegas, 
1980, pp. 163-173. 
- **[Kaivola, 1996]** R. KAIvoLA, Axiomatising extended computation tree logic, in trees in algebra a
programming, CAAP'96, 21st International Colloquium, Proceedings, vol. 1059, Springer, 1996, pp. 87- 
101. 
- **[Kesten and Pnueli, 1995]** YONIT KESTEN and AMIR PNUELI, A complete proof systems for QPTL,
Proceedings, Tenth Annual IEEE Symposium on Logic in Computer Science (San Diego, California), 
IEEE Computer Society Press, 26-29 June 1995, pp. 2-12. 
- **[McNaughton, 1966]** R. MCNAUGHTON,
Testing and generating infinite sequences byfinite automata, 
Information and Control, vol. 9 (1966), pp. 521-530. 
- **[Pnueli, 1977]** A. PNUELI, The temporal logic of programs, Proceedings of the Eighteenth Symposium
on Foundations of Computer Science (Providence, RI), 1977, pp. 46-57. 
- **[Safra, 1988]** S. SAFRA, On the complexity of ω-automata, Proceedings of 29th IEEE Symposium on
the Foundations of Computer Science, 1988. 
- **[Stirling, 1992]** C. STIRLING, Modal and temporal logics, Handbook of Logic in Computer Science,
- **[Thomason, 1984]** R. THOMASON, Combinations of tense and modality, Handbook of philosophical
logic, Vol 11: Extensions of classical logic (D. Gabbay and F. Guenthner, editors), Reidel, Dordrecht, 
1984, pp. 135-165. 
- **[Vardi and Stockmeyer, 1985]** M. VARDI and L. STOCKMEYER, Improved upper and lower bounds for
modal logics of programs, 17th ACMSymp. on Theory of Computing, Proceedings, ACM, 1985, pp. 240- 
251. 
- **[Walukiewicz, 1995]** I. WALUKIEWICZ, A complete deductive system for the μ-calculus, BRICS Re-
search Report RS-95-6, Department of Computer Science, University of Aarhus, Denmark, 1995. 
- **[Zanardo, 1985]** A. ZANARDO, A finite axiomatization of the set of strongly valid Ockamist formulas,
Journal of Philosophical Logic, vol. 14 (1985), pp. 447-468. 
- **[Zanardo, 1996]** 
, Branching-time logic with quantification over branches: the point of view of 
modal logic, this JOURNAL, vol. 61 (1996), pp. 1-39. 
- **[Zanardo, Barcellan, and Reynolds, 1999]** A. ZANARDO, B. BARCELLAN, and M. REYNOLDS, Non-
definability of the class of complete bundled trees, Logic Journal of the IGPL, vol. 7 (1999), no. 1, 
pp. 125-136. 
- **[Zanardo and Carmo, 1993]** ALBERTO ZANARDO and Jost CARMO, Ockhamist computational logic.
Past-sensitive necessitation in CTL, Journal of Logic and Computation, vol. 3 (1993), no. 3, pp. 249-268. 
SCHOOL OF INFORMATION 
TECHNOLOGY 
MURDOCH 
UNIVERSITY 
SOUTH STREET 
PERTH, WESTERN 
AUSTRALIA 
6150 
E-mail: m.reynoldsgmurdoch.edu.au