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
