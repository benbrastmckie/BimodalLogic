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

