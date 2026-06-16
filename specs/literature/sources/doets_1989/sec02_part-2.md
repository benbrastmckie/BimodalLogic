isfies  definable  induction,  then 3TC has n-equiυalents of order type  ω for  every n.

Proof: by the Lόwenheim-Skolem  Theorem, we may assume  UH to be countable.
Define X— [a E M| VZ? < a([b,a)  has a finite  ^-equivalent)).  Just as in the case

230

KEES DOETS

of  ~  in the proof  of  2.4,  it is  easy  to see that X  is  a definable set.  Trivially,  X
contains the least  element of  911. Also,  Xis  closed under immediate successors:
if  S is a finite  ^-equivalent  of  [b9a)  and c is the immediate successor  of  a then
it  is  clear  that the ordered  sum  S +  {a}  is  the required  finite  ^-equivalent  of
[bfc).  By  definable  induction then, X  = M.  Let a0  be the least  element of 911
and  choose  a0  <  a{  <  a2  < . . . cofinal  in  M  (which  we  have  assumed  to  be
countable!).  Choose a  finite  /7-equivalent  S, of  [ahai+ι)
for  each /. Then S =
Σ/S/ is  the required  ^-equivalent  of  order  type ω.

Virtually  the same  proof  works  for  the class  of finite  ordered models.
Notice  that  a  linear  ordering  (M,<) is  finite  if  it  contains a  least  and a
greatest  element, every  nonmaximal element  has  an immediate successor  and
restricted induction is satisfied,  which says that every  set containing the least ele-
ment and closed  under immediate successors  (insofar  as they exist)  contains the
greatest  element  as  well.  (Of  course  other  characterizations  work  as  well.)
Restricted induction brings  along  its  first-order  companion: definable restricted
induction.

3.2  Theorem
(1) has  a least and  a greatest element  and  every nonmaximal  element  has an

If  the  linearly ordered model 9ΪZ

immediate  successor, and

(2) satisfies definable restricted induction,
then  911 has finite  n-equivalents for  all n.

Proof: Begin  as in the proof  of  3.1. Definable  restricted induction now  shows
^Γto contain the greatest  element b of  311. Thus,  [a,b)  has a finite  Az-equivalent
and  so  does  [a,b]  = 911, as  required.

The following  models show that we cannot strengthen the con-
3.3  Examples
clusions  of  3.1  and  3.2  to:  911 has  an  elementary  equivalent  (i.e., a  model n-
equivalent  with  9H for  all n simultaneously)  which has order type ω (respectively
which is  finite).  For the second, let 9H have  order type ω + ω* and let the Xt  be
empty. For the first,  consider  91Z + 91 where  9H is  the previous  model and 91
has  order  type  ω —but  Xo  = N  this  time.  The  bigger  n  is,  the  longer  an n-
equivalent  of  9H has  to  be  (namely,  at  least  2"  — 1)  and  hence the larger  the
first  element of  Xo  in an ^-equivalent  of  911 + 91 is.

The direct method of  proof  of  3.1  and 3.2  works  for  the class
3.4  Remark
of  well-ordered  models too; however,  I shall  derive  that result  from  the corre-
sponding  one for  the order-complete models.

3.5  Remark
are recursively  enumerable. (Compare 2.6.)

The monadic Πj -theories of  ω and the class  of  finite  orderings

4  Monadic H\ -theory of  complete orderings, of  well-orderings,  and  of  the
The ordering  (M,<) is complete if  each nonempty set  with  an upper
reals
bound has a least upper bound (a sup).  Hence, 911 is called definably complete
if  this  holds  for  definable sets.

4.1  Theorem
each n.

IfΐPίί  is definably  complete, it has complete n-equivalents  for

Π} -THEORIES

231

Before  proving  4.1, here are an example  and a  corollary.

4.2  Example
the  conclusion  of 4.1 to requiring  an elementary  equivalent  of 9ίl.

The following  model shows that it is impossible  to strengthen

Choose  rationals  q0  < qx  < q2  < . ..  and r0  > rx  > r2  > .. .  such  that
limg,  = lim η  is irrational; take  A  = {qt\i E IN) U (/ / | / G N)  and consider
9K = (Q,<,A).  For each n, the models  (R,<,{1,.. . ,mj) for m > 2n  -  1  are
^-equivalents  of 9K. On the other hand, suppose  that  (N,<,B)  is a complete ele-
mentary  equivalent  of Oil. It follows  that B has order  type  ω + a for some α:
TV must contain a sup of the first  ω elements of B. However,  911 lacks an element
which  is a limit  of Ά's — a contradiction.

OH is  (definably)  well-ordered  if  each  nonempty  subset  of M (which is

parametrically  first-order  definable  on 9TC) has a least  element.

The following  trivial  lemma may  look  surprising,  as completeness usually

is  considered  only  in the context  of dense  orderings.

4.3  Lemma
a  least element, and every nonmaximal  element has an immediate successor.

9ϊl is (definably)  well-ordered iff it is (definably) complete,  has

Proof:  Suppose  that  0  Φ X  C M and X  has no minimum.  Put Y = {y E
M\ VJC E X(y  < x)}. Fis definable  if Jf is definable.  Since the least  element of
ΐί\ί must  be in Y, Yis  nonempty;  moreover,  every x E X  is SLΠ  upper  bound of
Y. Thus,  Y has  a sup y. If y E F, the immediate  successor  of y is minimal in
X.  Hence, y £  Y. But then y  must  be minimal in X,  a contradiction.

4.4  Corollary
equivalents for  each n.

If  OH is  definably  well-ordered, it  has  well-ordered it-

Proof: Notice that 4.3 defines  well-order as completeness plus a quantifier  rank
3 statement. By 4.3, 3TC is definably  complete. Thus, let m = max(«,3)  and take
91 to be a complete ra-equivalent of 9K by 4.1. By 4.3 again,  91 is the model
required.

We  say that an ordered  sum Σ/G//77(/) is completely ordered  if the order-

ing  of / is complete.

4.5  Lemma
(i) Completely ordered sums of complete orderings with endpoints are complete.
(ii)  Well-ordered sums of complete orderings with least elements are complete.

Proof: (i): Let XC  ΣieIm(i)  have  an upper  bound in m(i0).  Then /= {j\XΠ
m(j)  Φ 0)  has the upper  bound  /0. Let j  = sup /. Case 1: j  E J. Then max
m(j)  is an upper  bound  for X  Π m(j)  and sup X  — sup(^Γ Π m(j)).  Case 2:
j £ J. Then sup X  = min m(j).  (ii): Similar.

Proof of 4.1:  Define  — in the fashion  of 1.3 with  aRb meaning: a < b and (a9b)
has  a complete  ^-equivalent.

Notice that R is transitive.  Hence, ~ induces a condensation by 1.3. (N.B.
this  would  not have  been so obvious  in case we had defined  x ~ y to mean that
(x,y)  had a complete  ^-equivalent  only.)

Furthermore, ~ is definable:  compare the proof  of 2.4.  Hence, the equiva-

lence  classes are definable  as well.

232

KEES DOETS

Each equivalence class with an upper (lower) bound has a greatest

Claim 1
(respectively  least)  element  and each  equivalence  class has a complete n-
equivalent.

Proof: Let / be an equivalence class  and a G I. If / has no upper bound, choose
a0  — a < ax < a2 < . .. < a$.  < . .. (ξ < a) cofinal  in /. Choose a complete n-
equivalent N%  of  [^,αξ + 1)  for each ξ < a. Then Σξ<aNξ  is a complete π-equiv-
alent of Σξ[a^,a^+ι)  = (xG I\a < x] = I~a. If/has  an upper bound, it must
have a sup s by definable  completeness. I claim that sΈ I (and so, s is the max-
imum of /, I~a = [a,s] and hence (a,s) and, therefore, I~a as well,  has a com-
plete  ^-equivalent  by definition).  For if  not choose a0 = a < ax < a2 < . .. <
#£ < . ..  cofinal  in / again  to show  that  (a9s) has a complete zz-equivalent as
before;  a similar  argument will  show  that a ~ s.

Much the same goes  for the other half  I<a  = {x E I\x < a] of /, and  so

the  claim has been  proved.

Claim 2
dense.

The induced  ordering on the class M/~ of equivalence classes  is

Proof: Suppose that I < J are neighbors  in M/~.  Then a = sup / and b = inf
/are  neighbors in 3TI; moreover, a E /and b E /. Hence, (a,b) is empty; there-
fore,  a — ό — a contradiction.

If there is but cwe equivalence  class we are done. So,  assume not. The rest

of  the proof  works  towards  a contradiction.

The following  argument is taken from  [3] (Theorem 7.17,  p. 117). Choose
a  complete ^-equivalent  r (/)  for each / with / E Λf/~  in such a way that T =
{r(I)\I  E M/~} is  finite  (this  is possible  by  1.1). Now, if  for  some  σ E Γ,
{/ E M/~ |r(/)  = σ} is «oί dense  in the ordering  of M/~,  there  must  be a
proper  interval  Co C M/~  such  that no / E Co has τ(/) = σ. Repeating this
argument  (first  with  Co and  7Λ [σ] etc.) using  induction on the finite  cardinal
| Γ |,  one ultimately  arrives  at the following:

Claim 3
There is a proper  (open) interval D of M/~  and a set Σ C T such
that (i) every IGD  has τ(I) E Σ, and (ii) if σ E Σ then  {I<ED\τ(I)  = σ} is dense
in D.

The  contradiction aimed  for is contained in the next  claim.

Claim 4  D has but one element.

Proof: Suppose  that a,b E  (J D and a < b. We need to show  that  (a,b)  has
a  complete /z-equivalent.  Suppose that a E /, b E /. If / = /, there is nothing
to  prove.  Let E be the interval  (/,/) in D. Now,  (a,b) = I>a  + \j  E +  J<b;
therefore it suffices  to show that these components have complete ^-equivalents.
For I>a  and J<b
9  this is already  known (cf. the  proof  of Claim  1). Therefore,
it  remains to show  that  (J E has such an ^-equivalent  as well.

First,  notice that Claim 3 remains valid  if we replace D by E. Now, con-
struct a complete /^-equivalent  91 of the submodel  (J E — ΣίeEI  of ϋϊl as fol-
lows:  let h: R -> Σ be any partition of  1R into  | Σ| classes  [x E R\h(x)  =  σ]
(σ  E Σ), each of which  is dense in 1R and put dl =  ΣxG]Rh(x).

Π}-THEORIES

233

By 4.5 and Claim  1, VI is completely  ordered. It remains to show  that 01

is  ^-equivalent  to  U E.

First,  notice that the models  (£,<,{/G  E\τ(I)  = σ})σeΣ  and (R,<,{xG
IR| /Z(ΛΓ) = σ})σGΣ  (with  | Σ| unary  relations  each) are partially  isomorphic and
a fortiori  n-equivalent. (The argument  for dense  orderings  is well-known; the
extra  structure  involved  here —partitions  into  |Σ|-many  dense  sets —does not
complicate it terribly  much.) The result  now follows  from  1.5.

This  completes the proof  of 4.1.

The most prominent type of (dense) complete ordering is λ, the order type
of  the set of reals.  The following  example  shows  that we cannot strengthen the
conclusion  of  4.1 by  requiring  the ^-equivalent  to be of  type  λ,  under the
assumption  that the ordering  of ΐίϊί is dense.

ForxGlR, let m(x) = ([O,l],<,0) if x is rational, andm(x) =
3TC has the complete

4.6  Example
([0,1] ,<, [0,1])  otherwise.  Consider  ΐί\l = ΣxG]Rm(x).
order type  (1 + λ + 1)  λ (cf. 4.5), so it certainly is definably  complete. On the
other  hand, the proof  of Lemma 4.8 below  shows  that it lacks  a  5-equivalent
of  order  type λ: each complete 5-equivalent  of 311 has a definable  equivalence
splitting  the model in an uncountable number of proper intervals — contradicting
the  Suslin property  of  1R. Hence,  the Suslin  property  of  IR contributes to its
monadic Π} -theory.

The  following  definition,  suggested by 4.6, isolates  this contribution:

4.7  Definition
has  a dense set of  singletons.

ΐftl has property I if each densely  ordered condensation of ΐftl

4.8  Lemma  Models of order type λ and, more generally,  all complete order-
ings with the Suslin property,  have property I.

Proof: Suppose  that P is a densely  ordered  condensation of a Suslin  ordering.
Suppose  that p  < q in P but (p,q) does not contain a singleton.  By Suslinity,
(p,q)  must be countable; hence, it has the order  type of the rationals. There-
fore,  (p,q) has as many bounded sets  without sup as there are irrationals. Let
K be such a set. Then  (J K is a bounded set in the original  ordering without sup.

4.9  Theorem
without endpoints,  then  it has n-equivalents of  order type  λfor  each n.

If ΐfll is definably-I, definably complete, and densely ordered

Proof: First, we follow  the proof  of 4.1 with  some  slight  modifications.

To begin  with,  we may assume  by the Lδwenheim-Skolem  Theorem that

3TC is only  countable.

Now,  define  ~ by the scheme of  1.3 with  aRb meaning: a < b and  (a,b)

has an ^-equivalent  of order type λ. Again,  R is transitive,  so ~ induces a con-
densation by 1.3.

Claim 1
Each equivalence class has an n-equivalent of one of the following
types:  1, λ + 1 (if it begins ΐffl),  1 + λ (if it ends  ΐίϊl),  λ (if it does  both),  or
1  + λ+ 1.

Proof: Much as before.  Notice that we need to form  only countable sums  since
ΐPίl is countable, thus preserving  the separability  of the models involved,  thereby
guaranteeing  one of the order  types  required.

234

KEES DOETS

Claim 2  M/~ is densely  ordered.

Proof: Use the fact  that the ordering of 911 is dense.

Again,  it suffices  to show  that M is the only  class  in M/~.  Suppose it is

not.

There is a proper  (open)  interval D of M/~  and a finite  set Σ of

Claim 3
models of order type either  1 or 1 + λ + 1 such that
(i) every IE  D has an n-equiυalent in Σ,  and
then  {I E D\I =n  σ] is dense in D.
(ii) ifσEΣ

Proof: As  before.

In order to reach the desired  contradiction, and  stepping  over  some obvi-
ous details (cf. the proof  of 4.1, Claim 4), construct an ^-equivalent  91 of  \J D
of  order  type  λ as  follows:

Since 911 is definably-/,  M/~ has a dense set of singletons;  hence Σ con-
tains a singleton  model τ0. Take h: IR -> Σ partitioning R into  | Σ| classes  {x E
R\h(x)  = σ]  (σ E Σ) each of which is dense and such that  {JCE  R\h(x)  = τ0}
happens to be the set of irrationals.

Put  91 = ΣxGRh(x).  By 4.5, 91 is complete as before  and it is easy to  see

that 91 has a countable dense set this time, whence 91 has the order type λ. That
91 =n  (J D follows  as before,  using 1.5.

4.10  Corollary
ordered without endpoints satisfies the monadic  U\-theory  o/IR.

Every  ordering  which has I, is complete,  and is densely

4.11  Example
ties  (and differs  from  λ for a > ωi, since α>i φ λ).

For each ordinal a, λ + (1 + λ)  a has the  required proper-

4.12  Remark

Section  17 of  [2] contains a Π}-characterization of (1R,<).

4.13  Remark
The theorems  above  imply  recursive  enumerability  of the
monadic Πj -theories of complete orderings,  well-orderings,  and R. (Note that
these  theories  are in fact  decidable. For the first  and last  one this  is due  to
Gurevich.  The decidability  of the second  one is due to Rabin. Cf. [1].)

Previous  sections  dealt  with
5  Monadic H\-theory of  well-founded trees
linearly  ordered models only; the scope is widened here somewhat to the notion
of  a tree.

A  partially  ordered set 9H = (M,<) is called  a tree iff,  for each m E M,

the set ml  = \m' E M\m' < m] is linearly  ordered.

The Πj -property considered  here is well-foundedness:  9H is  well-founded
iff  each nonempty set has a minimal element; equivalently,  when 9ΐl is a tree:
iff  each mi  is  well-ordered.

Definable well-foundedness, of course, restricts  this to definable sets.
The  proof  of Theorem 5.1 below  can be considered as a paradigm  for a
method applicable in a variety  of situations, where the models considered belong
to  certain types  of partial  orderings  (trees being the simplest  example) and the
Πj -property  involved  can be either  well-foundedness,  converse well-founded-
ness, or, more generally,  some kind of completeness as in Section 4. It did not

Πl-THEORIES

235

seem useful,  however, to aim for  this greater generality  here, as a most general
result  probably  does  not  exist  and  the generalizations  obtained  of  the  result
below  all  appeared to be  rather  arbitrary.

5.1  Theorem
is definably  well-founded, then  it  has  well-founded n-equivalents for  all n.

is a tree with finitely  many extra unary relations which

If  ^

Again,  we  have  the companion result  on  recursive  enumerability  of  the

monadic Π{ -theory of  well-founded  trees.

Before  embarking on the proof,  we need some surgical terminology on trees

and  three lemmas.

A  component  of  911 is  a maximal  connected subset.  An  element of  9ΐl  is
minimal iff  it is the least  element of  its  component. In particular, components
are  (first-order  parametrically)  definable.

Therefore, if  911 is definably  well-founded,  so are its components. The con-
verse  of  this holds as well:  Piet Rodenburg (by private communication) recently
proved —in a setting more general than this one —that the restriction of  a defin-
able set to a component must be definable  on that component. This result is not
used here, however,  which makes for  some complications in the formulation of
the  lemmas  below.

If X  C M is downward closed (i.e., if  a < b E X  implies that a E X)  then

M\X

is  upward closed, and vice  versa.

I  shall  use  the  following  notations. If  X  C M  then  (ΐfll,X)  denotes the
expansion  of  911 obtained by  adding X  as  a new unary relation. If  a G M then
#ΐ  equals  {c E M\a  < c). Notice that, somewhat arbitrarily, a E #ΐ, but a (£ ai.

5.2  Lemma