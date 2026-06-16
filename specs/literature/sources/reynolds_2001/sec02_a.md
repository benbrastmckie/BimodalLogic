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
