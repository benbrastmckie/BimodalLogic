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

