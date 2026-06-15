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
