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
