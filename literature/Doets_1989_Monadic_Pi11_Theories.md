224

Notre  Dame Journal  of  Formal  Logic
Volume  30,  Number 2,  Spring  1989

Monadic  Π{-Theories  of  Π{-Properties

KEES DOETS*

Abstract  Axiomatizations  are provided  for  the monadic universal second-
order theories of:  scattered orderings, well-orderings,  complete orderings, the
ordering  of  the natural numbers, of  the reals,  and of  well-founded  trees.
Proofs  employ the Ehrenfeucht-Fraϊsse-game.

For  some  Πj-statements  vRφ{R),  results  of  the  following  type
Summary
,Xk)  is
are proved:  Suppose  that a monadic Π} -sentence VXX...  y/Xkφ(Xι9...
a  consequence  of  VRφ(R),
then  the  first-order  sentence  ψ(Uι,.  . ., Uk)  is
already  a  consequence  of  the first-order  schema  corresponding  to  vRφ(R)9
which  requires  φ(R)  only  for  R  which  are (parametrically)  first-order  definable
. . .,  Uk).  Cases  considered  here are:  scattered  order-
in the language  of  ψ(Uu
ings,  well-orderings,  complete orderings,  models  of  order type ω, of  order  type
λ,  and  well-founded  trees.  The  method  of  proof  uses  the  Ehrenfeucht-
Fraϊsse-game.

1  Introduction
Some  natural  axioms  of  a  number  of  theories  are  of  the
second-order  (Π{)  form  vRφ(R),  where  φ is  a first-order  predicate and R  is a
second-order  variable.  For instance, the induction principle of  arithmetic, the
completeness of  the reals,  Zermelo's Aussonderungsaxiom,  and the Fraenkel-
Skolem  replacement axiom in set theory  are of  this type.  As  to first-order ver-
sions of  these principles, the natural option is to require φ(R)  not for  all R but
for parametrically first-order definable R  only, thus replacing  the second-order
axiom  by  its  corresponding  first-order  schema.

Obviously, the new theory will have models  not allowed  by the old one (by
the Lόwenheim-Skolem-Tarski  Theorem for  instance) and hence it may turn out
to  be  strictly  weaker  than  its  second-order  companion. For instance,  second-

*I wish to thank Johan van Benthem for  his questions (to which 3.1, 4.6, and 4.9 below
form  the answers)  and his stimulating  interest in the topic of  this paper.1

Received July  21,  1986; revised October 16, 1986 and April  30, 1987

Πl-THEORIES

225

order  arithmetic is categorical, hence it implies  first-order  sentences beyond the
scope of the first-order  induction schema.

On the other hand, if the language is restricted  sufficiently,  conservation
may occur. This paper contains a number of examples of this. They all concern
theories of (partial) orderings, in which  conservation is proved  with  respect to
monadic Π} -sentences. The method of proof  consists  in showing  how  to trans-
fer  counterexamples t o a Πj -sentence on a "nonstandard" model to a standard
model.

To be more  precise  (cf. the  condition of Theorem  1.2(ii) below),  I will
prove  results  of the  following  type.  Let L be a first-order  language  contain-
ing < and unary predicates Ux,..., Uk.  Let Oil = (M,<, Uγ,..., Uk)  be a model
of  the first-order  L-schema  corresponding to the  Πj-property  vRφ(R);
i.e.,
each R C M which is first-order  definable  on 311 satisfies  φ(R)  on 311. Then for
each L-sentence ψ( U{,..., Uk)  true in 311 there is a model  (N,<)  of the origi-
nal  Πj -sentence vRφ(R)  satisfying  3^ . .. lXkψ(Xu

. .. 9Xk).

To explain  how this is done we need the notion of ^-equivalence. Models
are called  n-equivalent  (denoted by =") iff they satisfy  the same first-order  sen-
tences of quantifier-rank  <n.  In the sequel,  our languages  will be finite  and do
not  contain operation  symbols.  Under these  circumstances,  we  have  the  fol-
lowing:

1.1  Lemma
order formulas  of quantifier-rank <n  in the free  variables  JCO>  >Xk-\  in each
language.

Up  to logical equivalence, there are  only finitely  many first-

Proof: Induction with respect to n. For n = 0, notice that there are only  finitely
many atomic formulas  in these variables  and use disjunctive  normal forms. For
the  induction step, choose a finite  set  Σ of formulas  of quantifier-rank  <n in
the  free  variables  x0,...
,xk such that every  such  formula  has an equivalent  in
Σ. Now, consider  disjunctive  normal forms  over  "atoms" Vxkφ  and 3xkφ  where
φGΣ.

It  follows  that ^-equivalence  has only  finitely  many equivalence  classes in
each  language  of the  type  considered.  This  is the  main  important  fact  used
below.

The n-characteristic σ of a model 3IZ is the conjunction of all  sentences of
quantifier-rank  <n  valid in 311. Thus,  31  1= σ iff 31 =n 311. ^-equivalence  has
been neatly characterized by Ehrenfeucht using  his game  (for  more on this, cf.
[3],  pp.  93-96,  247-252,  and  359-361).

In the following  basic  theorem Σ is a set of first-order  sentences in a lan-
guage L and  vRφ(R)  is a Π} -sentence over  L.  Let Xu.  . . ,Xk be  new  unary
relation-symbols  and Lk = L U {Xu...
,Xk}. (Lk~) definably-φ is, by defini-
tion, the set of universal  closures of L^-formulas  obtained from  φ by  replacing
each  occurrence of R{tx,...,
tm) by  some fixed  Z^-formula  η{tx,...,  tm) (tak-
ing  measures to avoid  the clashing  of variables).  Thus, L^-definably-φ  intui-
tively requires  φ(R)  only when R is (parametrically) first-order  definable  in the
language Lk.

The union over  all k of these schemata is the first-order schema correspond-

ing to  vRφ(R).

226

KEES DOETS

The following  two  conditions are equivalent:

1.2  Theorem
(i) for  each first-order formula  ψ = ψ(Xι,.
vRφ(R)  N vXx  . .. vXkψ,  then  Σ + Lk-definably-φ  \-ψ(XΪ9...
(ii)  each  model  (911, C/i,..., t/*)  o/ Σ + Lk-definably-φ  has  an  n-equiυalent
satisfying Σ + VRφ(R) for  each n.

. . ,Xk)  in  the  language Lk:  ifΣ  +

9Xk);

Proof:  (i)  => (ii):  Let  (9K, Uu  . . ., Uk)  1= Σ  +  L^-definably-φ  have  the Λ-
characteristic τ(Xu...
If  such  a model  does  not exist,  then Σ + vRφ(R)  1=  VΛ^  ..  . vA^-ir;  hence by
(i),  Σ + L^-definably-φ  \=  -ιτ(X\,...
9Xk),  contradicting the  assumptions  on
(3K, £/!,..., £/*).

,Λ^).  We  want a model of  Σ + VRφ(R) + aΛ^ . ..  aΛ^r.

(//)  =*(/): Assume  Σ + vRφ(R)  \=vXx...  VXkψ  and let  (911,(7!,...,  f/*)
be  a  model  of  Σ + L^-definably-φ.  By  (ii), there is  an  ^-equivalent  satisfying
VRφ(R)  + Σ where  we  take  n to be  the quantifier  rank  of  ψ.  By  assumption,
,Xk)  is  also  satisfied,
this  ^-equivalent  satisfies  vXi  . .. vXkψ,  hence ψ(Xι,...
so  (9H, U\,.  . ., Uk)  must  satisfy  this  formula  as  well.

The Σ of  the theorem below  will always be finite.  Therefore we may require
that the ^-equivalent  of  (ii) satisfies  vRφ(R)  only, without invalidating  the truth
of  (ii) => (i): simply  let n be at least the maximum of  quantifier  ranks of  formulas
in Σ.

In what  follows,  results  of  type (ii) are proved. According  to the theorem,
this  shows  that, in  the  context  of  Σ, the first-order schema corresponding to
VRφ(R)  suffices  to prove  all  monadic  U\-consequences  of  this second-order
statement.  (Actually,  Theorem 4.9  below  does  a little better.)

In  particular,  when  1.2(i)  or  (ii)  holds,  the  monadic Πj-theory  of  Σ +
vRφ(R)  is  recursively  enumerable  (cf.  [1]  for  decidability  results  in this con-
text).

All  models encountered here will have the form  3H =  (M,<, Uu  . . .,  Uk),

where  <  orders Mand  Uu.
..  ,UkC  M.  If  Xc  M,  then  DC  (and sometimes  X
as  well) denotes  the  submodel  of  3Π with  universe  X.  I  C M  is  an  interval if
x  < y  < z  and x,zG  I imply y  G /;  notations like  (x,z)  and  [x,z)  denote spe-
cific  intervals  as  usual.

If /is  an ordered set and m a function  on / associating  a model m(i)  with
every  / e  /, we may  form  the ordered sum  Σ/ e /m(/),  being  the model obtained
from  the m(i)  by  gluing  (disjoint  copies of)  them one after  the other according
to the ordering  of  /. Formally, ΣιGlm(i)  can be defined  as the model with uni-
iff  /  <rj9
verse  (J  (m(i)  x  {/})  with  the  ordering  defined  by:  (a,i)  <  (bj)

iGl

or:  / =j  and  a  <z  b  (here,  <7  and  <7  denote the  orderings  of  m(i)  and  / ); and
if  Un is  the  /?-th unary  relation  of  m(i)  (1  <  n  <  k)  then  Un  =  \J  (Uι

n  x

{/})

i(Ξl

is  the corresponding  one of  the ordered  sum.

A  condensation of  an ordered model ΐftl is a partition of  ΐίϊl into intervals.
Any  condensation P  of  3H inherits an ordering  from  3H by  putting, for p,q  E
P: p  < q  iff  for  some a E p  and Z?  E # (equivalently,  iff  for  all  a E /? and Z?  E
q)  a <b.  Hence, a condensation P  of  3TC  is nothing but a way  of  writing  911 as
an  ordered  sum,  ΐPfί  =  ΣpGPp.

If  the condensation P is  induced by  the equivalence  ~  (such  equivalences

are  called  congruences by  some), we  write  P  — M/~.

Πl -THEORIES

227

1.3  Lemma
Define ~  =  ~R  by:  a -  b  iff  one  of  the following  holds:

Let R  be any transitive binary relation  on  the ordered model ΐftl.

(ϊ)a  = b
(ii) a <  b  and for  all c,d  such that  a <  c  <  d  <  b:  cRd
(iii)  b  <  a and for  all c,d  such that  b  <  c <  d  <  a:  cRd.
Then ~  induces a condensation.

Proof: The proof  is  straightforward.

All  condensations  used  in the sequel  are  defined  in this  fashion.

1.4  Lemma

If for  all  i E I m(i)  =n  ιn'(0,  then  ΣiGίm(i)  =n

ΣisIm'(i).

Proof: It is  straightforward  to describe  a winning  strategy  for  the second  player
in  the Ehrenfeucht ft-game between  these  sums  under the condition given.

The  following  generalization  of  Lemma  1.4  is  needed  in  Section  4.

1.5  Lemma
Suppose that I and J are ordered sets and that m and m'  associ-
ate ordered models m(i), respectively mf{j),  to each i E /, respectively j  E /, such
that:

(*)

(7,{/jm(0  N σ})σ€ΞΣ  ssΛ
acteristics. Then ΣiGlm(i)  =n

  (JΛJ\M'U)

t= σ])σGΣ  where Σ is  the set  of n-char-

ΣjGjmf{j).

Proof: Use the Ehrenfeucht  game-technique.  If  the  first  player  chooses,  say,
a E  Σ/m(/),  the second  player  locates  the / E / for  which  a E  m(i),  then  uses
(*)  to find  ay  corresponding  to /; in particular,  tn'(y)  =n  *n(/), and a counter-
move  is  readily  found;  etc.

1.6  Examples where 1.2(ii)  fails

1. (Due to van  Benthem.) Consider  the Π} statement  vXφ(X)

in the lan-
guage of  < where  φ(X)  means that X  and its complement cannot both be  cofi-
nal.  Obviously,  every  ordered model of  vXφ(X)  has a greatest  element. On the
other  hand, the first-order  schema  corresponding  to φ does  not imply  this.  A
countermodel  is  (ω,<):  notice  that  each  definable  set  here  is  either finite  or
cofinite. {Proof: Using games,  it is easy  to verify  by  induction on n that order-
ings  of  type  ω and  ω + ζ are ^-equivalent  for  all  n.  Now, let  ψ(x)  be  any  for-
mula in the free  variable  x.  If  no a E  f  satisfies  ψ in ω + f  then 3jVx(y  < x -*
-iψ)  holds  in ω + f  therefore  it holds  in ω and the set  defined  by  ψ in ω must
be  finite.  On the other hand, if  some ί/Gf  satisfies  ψ in ω + f  then every  a E
f  satisfies  ψ  in  ω 4-  f—this  is  so  because  for  each  pair  a,b  E  f  there  is  an
automorphism  h of  ω + f  such that Λα = 6.  Hence, 3^Vx(^ < x -> ψ)  holds in
ω + f;  therefore,  it holds  in ω and the set  defined  by  ψ in ω must  be  cofinite.)
2.  In theories defining  a pairing the restriction to monadic languages  is only
apparent  and  results  like  ours  can fail  badly.  We  mentioned the case  of  arith-
metic; also,  each model of  set  theory  certainly  is  definably  well-founded,  nev-
ertheless  such  models  need  not  have  a  well-founded  π-equivalent  for  n  large
enough: well-founded  models  have  standard integers,  therefore  they  are arith-
metically  correct; but,  Gόdel sentences  are arithmetical.

228

KEES DOETS

2  Monadic H\-theory of scattered orderings  A linear  ordering  3ΪI = (M,<)
is  called  scattered if it does  not embed the ordering  (Q,<) of the rationals.

Q  embeds  every countable ordering; in particular, it embeds  ω*. It follows

that  every  well-ordering  is scattered.  I shall  need the following  lemma:

2.1  Lemma

A  scattered ordered sum of scattered orderings is scattered.

Proof: Suppose  Q C Σ/(Ξ/ra(/). If some Q Π m(i) contains at least  two ratio-
nals,  it contains the interval  between  them and so m(i) cannot be scattered.
Hence,  sending p  G Q to the / G / for which p  G m{i) embeds  Q in /, a con-
tradiction.

There  is more  than  one way to formalize  scatteredness  into  a Πj-state-

ment, and not every  formalization  is a good  one from  our point of view.

Let δ express  that < is a dense ordering  containing at least two
2.2  Example
elements. φ(X) is the formula  obtained  from  -ιδ by relativizing  quantifiers to
membership in (the set) X.  Clearly,  ΐftl is scattered iff  it satisfies  VXφ(X).  Here
is an example of a model ΐftl = (M,<,^, Y,Z) which is definably-φ but has no
scattered  3-equivalent.  Partition  Q into  dense  subsets  R, S, T and  put 311  =
Σ9 G QM9,  where Mq = {2,<,X«,  Yq,Zq)  and Xq  = Z if q G R; Xq  is empty
otherwise;  similarly,  Yq  = Z or 0  depending  on whether  q G S or not; and
Zq  = Z or 0  depending  on whether  q G T. Notice that  each  interval  Mq of
OH is a set of indiscernibles  of WL  (use automorphisms of Mq); hence, if A  is a
definable set of 9ϊl, either A  Π Mq = 0  or Mq C A.  Therefore,  no nonempty
definable  set of ΐftl is densely  ordered  and it follows  that 3ϊl is definably-φ. On
the other hand, the fact  that 3TC satisfies  sentences  such as (Vx G X)(Vy G Y)
(x  < y -> ( 3 Z G Z ) ( X < Z < ^ )) shows  that no 3-equivalent  of ΐftl can be scat-
tered.

A  "good"  formalization  of scatteredness  should  avoid  this counterexample.

2.3  Lemma
sation.

An ordering is scattered iff it has no densely ordered conden-

Proof: Only if: Use the axiom of choice. If: Suppose that Q C M. Define ~ by
way  of 1.3 where aRb iff  a < b and (α, b) Π Q is finite.  It is easy  to see that —
induces  a dense condensation.

The (dyadic!) Πj -characterization of scatteredness  contained in this lemma
is  a "good"  one according  to the following  theorem,  where  we call  a model
definably scattered if no definable equivalence  partitions  31Z into a dense order-
ing  of intervals.  Notice that the model of 2.2 is not definably  scattered in this
sense.

2.4  Theorem
for  each n.

IfΐPXis  definably scattered,  then it has scattered n-equivalents

Proof: I use what  Rosenstein [3] calls a condensation argument,  which  originated
with  Hausdorff.  Define  ~ in the fashion  of  1.3 with  aRb meaning  that (a,b)
has a scattered  ^-equivalent  (if a < b). By 2.1, R is transitive.  Hence, —  induces
a  condensation by 1.3. Moreover,  -  is definable: there are only finitely  many
^-characteristics; let Γ be the (finite)  set of ^-characteristics  belonging  to scat-

Πl -THEORIES

229

tered  models.  Then  (c,d) has a scattered  π-equivalent iff  ϋH H V  τ( c' ^,  where

τ(c,d)  js obtained  from  r by relativizing  quantifiers  to membership  in (c,d).  It
is  now clear  that  ~ can be defined  as well.

Claim  1

Each  equivalence  class has a scattered  n-equivalent.

Proof:  Let / be an equivalence  class and a E I.

(i) / has a greatest  element  b. Then  a ~ b  and I~a  = [x E I\a < x] =

[tf,6]  has  a scattered  λz-equivalent  by definition.

(ii) If not,  choose a sequence ao = a < ax < .. .<  a%  < ...  (ζ < a)  cofinal

in /. Each  (a^a^+{)
and hence  each  [a^a^+x)  has a scattered  ^-equivalent A%.
Hence I~a = Σξ < α[ ^ , ^+ 1)  has the ^-equivalent  Σ^<aAξ  by 1.4 which, by 2.1,
is  scattered.

Argue  similarly  for I<a  = {x E I\x < a}; so / = I<a  + / -" has a scattered

^-equivalent.

Claim  2

77ze induced  ordering  of  the equivalence  classes is dense.

Proof: Suppose  that I < J are equivalence  classes  and no equivalence  class is
between / and /. Let a E / and b E 7, and suppose  that a < c < d < b. Then
(c,rf)  has a scattered  ^-equivalent:  if  c, J  E / or c9d E / this  is clear,  and  if
c E / and cf E / we know  from  the previous  proof  that />c and J<d  have scat-
tered ^-equivalents;  but,  (c,d) = I>c  + J<d.  Therefore, a -  b, a contradiction.

Since 311 is definably  scattered, ~ cannot have more than one equivalence
class: M itself. Consequently, ΐftl must have a scattered ^-equivalent by the  first
claim.

By 2.2 and 2.3, we have  two Π}-formalizations  of scattered-
2.5  Remark
ness; however,  the first-order  schema corresponding to the second one (defin-
able  scatteredness) is strictly  stronger  than the first-order  schema belonging to
the  first.

2.6  Corollary
enumerable.

The monadic  H\-theory  of scattered orderings is recursively

Proof: Use 2.4 and 1.2.

3  Monadic ϊl\-theory of  ω and of  the class of finite  orderings
It is clear
what it means for an ordered set to satisfy complete induction  when there is a
least  element and every  element has an immediate successor.  Definable induc-
tion  requires  that  every  definable set containing the least  element and closed
under  immediate successors  contains every  element. Complete induction  is the
usual Π{ -instrument transforming  a suitable  set of first-order  axioms  of quan-
tifier  rank <3 into a categorical description of the order type ω. Definable induc-
tion does not come close to this, but it suffices  for the monadic ΐl\ -theory:

7/(1) (M,<) Ξ3 (ω, <) and (2) OH = (M,<,XU  ...  ,Xk) sat-
3.1  Theorem
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
Suppose that  the tree 911 is definably  well-founded.  If  a < b in
9TC then, for  each n,  ((#T)\ (6ΐ),  [a,b))  has an n-equiυalent (91,β)  such that
β is well-ordered and all components ofN\β  are definably well-founded (see Fig-
ure 1).

Figure  1.

Thus,  91  can  be  used  as  a  substitute  (within  ^-equivalence)  of  the part
(flft)\  (6ΐ)  of  911, thereby exchanging  [a,b)  for  the well-ordered β and preserv-
ing  definable  well-foundedness  of  the  rest,  component-wise. The  other  two
lemmas are similar in spirit. The proof  of  5.1  finally  will show how to carry out
such  substitutions  repeatedly,  thereby  eventually  arriving  at  the desired  well-
founded  ^-equivalent. To see that such substitutions actually work, the  following
remark  is needed.

236

KEES DOETS

Remark
In what  follows,  a lot of  cutting and pasting  of  trees has to be per-
formed.  To  see  that  in  each  case  ^-equivalence  is  preserved,  the Ehrenfeucht
game  technique can be  applied.  The general  procedure is  as  follows.  Suppose
that  911' is obtained from  911 by exchanging  some part 91 by an ^-equivalent 91'.
In  all  cases  occurring it will be  clear  how  this  exchange-process  has  to be per-
formed,  since the way  91 is "attached" to 911 \ 91 will be particularly  simple. Let
/ be  the identity-map on 911 \ 91.

5.2.1  Lemma
Suppose that, for  each partial isomorphism h between 91 and
91',  the  union /U  h is a partial isomorphism between 9H and 91Γ. (In applica-
tions it always will be rather obvious  that this condition is satisfied.)  Then it will
be  the  case that  911 =n  91Γ.

Proof: Consider the fl-game between  9TC and  91Γ. The second player  wins  this
if,  to answer  moves by the first  one in either 91 or 91', he uses a winning  strategy
for  the «-game between these models, and if  he copies the first  player  on 911 \ 91.

Proof  of  5.2:  Let X  be the set of  b e  Msuch that for  all a < b, (tfί\Z?ΐ,[#,&))
has  an ^-equivalent  of  the type  desired.  The lemma asserts  that X  = M.

Suppose that XφM.  Observe  that X  is  definable:  there are only  finitely
many ^-characteristics of  models (91,β)  such that β is well-ordered  and all com-
ponents of N\β  are definably  well-founded;  moreover, that  (αT\Z?T,[α,Z?» satis-
fies  a  given  characteristic  is  a  first-order  property  of  (ΐί\l,a,b).  By  definable
well-foundedness,  M\X,  assumed  to  be  nonempty, has  a  minimal element  b.
Suppose  a <  b  is  such  that a  corresponding  ^-equivalent  of  the required  type
does  not  exist.  Obviously,  b  cannot have  an  immediate predecessor.  Choose
a0  = a  <  ax  < . . . < #$  < . . . ( £<  α)  cofinal  in  bϊ.  By  the  minimality  of  b,
choose  (Nξ,βξ)  =n  (tf£Ϊ\tf£+1ΐ,[tf£,tf£+1))  such that β$ is  well-ordered  and all
components of  N^\β^ are definably  well-founded  for  each £ < a  (see Figure 2).

/

t

/

'

I
/

JWβ2

Figure 2.

Πj-THEORIES

237

The model Σξ<a(Nξ,βζ),  obtained by gluing the β% one after  the other now
forms a counterexample to the choice of a and b: to see that this is an «-equiv-
alent of (#?\&T, [#,£)),  apply the remark to (αΐ\&t, [#,&)) = (J  ( ^ ΐ \ ^+ 1ί,

[aξ,aξ+ι))  and  Σξ<a(Nξ,βξ).

Suppose  the tree 9Π is definably  well-founded and b E M.
5.3  Corollary
Then, for each n, (9K,6)  has an n-equiυalent  (ΐffl'9b')  such  that b'l  is  well-
ordered and all components  of M'\ (b'l) are definably well-founded.

Proof: If b is minimal in 311, then  (911, fe) itself  satisfies  the stipulations. Other-
wise, let a be the least element of bl. By 5.2, (αΐ\6ΐ, [a,b)) has an ^-equivalent
(91,β)  with β well-ordered and all components of N\β definably  well-founded.
Replace  (tfΐ\6t,[α,Z?)) in 3ft by (91,j8); the result is 911'. In 911', bi = β. Thus,
putting b' = b makes b'l  well-ordered.  The components of M'\(b'l)
are the
ones of N\β plus bt plus the OΠ-components different  from  the one  contain-
ing b (if any); these are all definably  well-founded.  Finally, (9ΪΓ,&') =n (9K,&)
follows  from  the remark  above.

The  next  lemma is the version  of 5.3 with  finitely  many b's at the same

time:

Suppose  that the tree 9ft is definably  well-founded and A C M

5.4  Lemma
is finite.  Then, for each n, ((^(ί,a)aeA  has an n-equiυalent (^l\a')aeA
such that
each a'I (a EA) is well-ordered and all components  of M' \  (J a'I are defin-

ably  well-founded.
Proof: By induction on the number of elements in A. To start with, we have 5.3.
For the induction step, choose a E A and put B = A \ {a}. Apply  the inductive
hypothesis to (9K,tf)  and B to obtain (ΐfϊί\a'9b')beβ
with all b' I (b E B) well-
ordered  and M'\  (J b'l  definably  well-founded — component-wise.

\a(ΞΆ

\b(ΞB

Case 1: Suppose that for some b E By a < b. Then a' < b', a'l is well-

ordered, M'\  \J a'l  = M'\  \J b'l,  and we are  done.

\aGA

\b<EB

Case 2: If not, let C be the component of M '\  (J b'l  containing a'.

By 5.3, obtain (β',a")  =n (G,af)  with a"I well-ordered and C'\(a")l
defin-
ably  well-founded,  component-wise. Replace ((3,#') in ΐίϊl' by (Q',a")  to obtain
the  desired  model

(ΐPίl"9a'\b')beB.

\bGB

We  are now ready for the proof  of 5.1.

Proof: Define a sequence of models  9K0,9Ili,9Il2,...  and sets  T°, Tι, Γ2,. ..
such that:

1.  ΐHlo = ΐP(l;  T° = 0
2.  Tι is a well-founded  downward-closed  part of OH/ and every component

of  Mt\Tι  is definably  well-founded

3.  TlJtX  (considered as a submodel  of 9]Zί+1) is an end-extension  of  T'

238

KEES  DOETS

(considered as a submodel  of 911/)  (i.e.,  V  C Ti+\  and for a,b G  7"'+1,
if ft G Γ7 and  α < b then α G Γ'")

4.  (9K/,0/er  Ξ"  (9R/+i>0/er
5.  for all a G M/XΓ7  there  is a 6 G Ti+ι  such  that  ( ϋ H/ 5ί , α ) ,e Γ/  Ξ " "1

(9rc/+1,f,Z0,er.

9ΪI/+1 and  Γ '+1 will be obtained  from  911, and  V  by replacing  M/NΓ' in 311,  by
an  ^-equivalent  with  a well-founded  initial  part  (namely,  Tι+ι\Tι)
preserving
definable  well-foundedness  component-wise.  This  will  take  care of 2-4.  How-
ever,  Tι+ι  must be big enough  so as to satisfy  5. This is achieved  in the  follow-
ing  manner:

Let  C be a component of M{\Tι.  Choose A C C such  that for each c G C
there is an a G A  with  (6,#)  =n~ι  (C,c)  and  such  that A  is finite —this  can be
has  an ^-equivalent  (<3\a')aGA  with
done  according  to 1.1.  By 5.4,  (Q9a)asA
every  a'ϊ  well-ordered  and  C"\  |J  #'4 definably  well-founded,  component-

wise.

9H/+1  is  obtained  from  311/ by exchanging  6  for G' and  making  simi-

lar  replacements  for every  other  component of Mt\Tι.  Γ/ +1 is Tι plus  all the
(J  ( α 'i  U {ar}) so encountered.

It  is now  obvious  that 2-5 are satisfied.
Now,  put  91 = (J  T.  By 2-3,  91 is well-founded.  I claim  that  91 is  an

/^-equivalent  of 9H.  Consider  the  Ehrenfeucht-ft-game  between  these  models.
Notice  that,  as Tι c  9ϊl, , in order  to win  it suffices  for the  second  player to
choose  his  moves  in such  a way  that  after  his  k-ύi  move  the  sequences
a0,...,
ak-ι  G M  and  tθ9...  Jk_ι  G A^ have  been  played  such  that  for all /, if
/0, . . . , ί * -i  G r  then

[*],-

( 9 H , αo, . . . , ^ - i) ^ " "^  ( 9 K / , ί o , . . . , ^ - i ).

Notice  that  / <j  and  [*]/  imply  [*]y by condition 4  above.

Now,  the  second  player  can  keep  up  with  this  requirement:  First, if k = 0

then  [*]o  holds  since  9H0 =  3TZ.

Next,  suppose  the  players  have  arrived  at a position  where  [*],  still  is

satisfied.

(a)  Let  the  first  player  choose  tk  G N, say,  tk  G TJ. If j  < / then  [*],- pro-
(9H ,

vides  the  second  player  with  an ak G Msuch  that  (ΐPfί,a0,...  ,ak) —n~k~ι
tQi...Jk)Λΐi<

y,  simply  use [*]y.

(b)  Assume  that  the  first  player  chooses  ak  G M. By [*],-,  there is a w  G

Mi  such  that  (3K,ύr0,. ..,ak)  =n~k~x  (<3Kht0,.  . .,tk_uu).
If, by a  stroke of
luck,  u G Γ', we are  done. If not, by condition 5 there is a tk  G Γ '+1 such  that
( 9 t t/ + 1, / , ^ )/ er  - " -1 ( 9 t t / , M / )/ er, in particular,  ( 9 H/ + 1, ί0, .. . , 4)  ΞΞ"-*-1
(9K/,r0,..
ftk)\  so the
second  player  chooses  tk,  thereby  ensuring  that  [*]/+i  holds  for the  resulting
sequences.

, ^ _ ! , w ).  Hence, (911,α0,... ,ak)  =n'k~l

(ΐί\li+utOi...

6  Appendix:  Strengthening  2.4 and 4.4  Let 9H0  be the smallest  class of
order  types  such  that

Π}-THEORIES

239

(1)  1 G  9Ko
(2) α,|8G  ^ 0 =^ OL  + βG 9K0
(3) a E 9H0 => α ω,α ω* E 9Π0.

By  2.1, all types  in 3TC0 are scattered.  By a theorem of  Laύchli and Leonard
([3], Theorem 7.9, p. 115) 9TC0 contains ^-equivalents  for each scattered order-
ing and for all n. Their  method of proof  shows  that the extra  unary  relations
of  our models do not spoil  this situation:

2.4'  Theorem
with order type in ΐί\ί0for  each n.

Ifΐίϊί  is definably  scattered, it has (scattered)  n-equivalents

Proof: On M, define  ~ by way of 1.3 with aRb meaning: a < b and (a,b)  has
an  ^-equivalent  with  order  type  in 9ϊl0.  By (1) and (2),  R is transitive,  so  —
induces a condensation.

Claim 1

Each equivalence class has an n-equivalent with order type in 9ϊlo
Proof: If the class  / is unbounded, choose a < a0 < ax < a2 < . ..  cofinal  in /
(by Lόwenheim-Skolem, assume 911 is countable). For / <j,  let h(ij)  be the n-
characteristic of  [ahaj).  By Ramsey's  Theorem,  there is an infinite  set A  C  IN
and a σ such that if / < j  and ij  E A  then h(ij)  — σ. Let / = min A  and choose
7V0  = "  [a,aϊ) and  TV\= σ with  order  types  in 3ΐl0.  Then I-a  =n No + N  ω  and
this  model has order  type in UTC0 by (2) and  (3).

The same  goes  for I<a, etc.

As  before,  M/~  must be either dense or consist of one class  only; since the

first  alternative  cannot obtain, the proof  is  finished.

Next, let JC be the smallest  class  of order  types  such that

(1)  1  G3C
(2) ot,β E 3C => a + β E K
(3) a E JC =» α ω E  JC.
Clearly,  JC C 3H0  AH  types  in X  are well-ordered  and it is easy  to see

(using  Cantor  normal  forms)  that  a  E  K  iff  0 <  a  < ωω. K  contains n-
equivalents  for each well-ordering  and for all n (it is easy to see that no smaller
class  has this  property). Again,  extra  unary  relations do not change this  state
of  affairs:

4.4'  Theorem
equivalents with order-type in JC for  each n.

// 9U is  definably  well-ordered, it  has (well-ordered) n-

Proof: Define X  = {a \ Vό < a [b, a) has an ^-equivalent  with order type in 3C}.
X  is definable,  hence if X  Φ M then M\X  has a least element a. Pick b < a such
that  [b,a) has no ^-equivalent  with type in JC. By (1) and (2), a cannot be a suc-
cessor.  Now, choose b < bo<  b{  < . ..  cofinal  in [b,a)  and argue as in the pre-
vious  proof.

Corollary (Ehrenfeucht- [3], Theorem 6.22,  p. 108)  ωω = (OR, <)  (where
OR  is the class of all ordinals).

Proof: If / starts an (n + l)-game with a move a E OR, // answers  with an n-
equivalent  β in ωω. (Notice that αΐ = OR and βί =  ωω.)

240

KEES DOETS

The  classes  3H0

 a nd  ^  w e re  inductively  defined  by  closure  properties  ob-
tained  by  looking  at  what  it  takes  to  prove  2.4  and  4.4.  In the  same  way,  one
may  find,  e.g.,  a  class  6  of  order  types  such  that  each  completely  and  densely
ordered  model  without  endpoints  has  /7-equivalents  with  types  in  6;  closure
properties  needed  here  are

(1)  λe  C
( 2 ) α , βe  e  =>  a  +  l  +  βe
(3)α  G C  =>  (a  4-  l)  ω,  (1  +  α)  ω*  G C
(4) if  A:  R  -• e  has  A[R]  finite  and  all  {x  G R|A(x)  =  σ}  (σ  G  A[R])

e

dense  in  R  then  Σx G R(l  +  h(x)  +  1)  G  β.

NOTE

1.  After  this paper had been completed my attention was  drawn to  [1] (by Burgess).  It
appears  that the material  below  displays  the following  points  of  overlap  with that
work,  which  precedes  mine by  at last  three years.  First, Gurevich already  identified
Property  I (cf.  4.7  below). As  a matter of  fact,  he presents it in its monadic  universal
second-order  form  using  a selector-set  (this is similar  to the phenomenon of  two  for-
mulations  of  scatteredness,  cf.  2.5  below).  Second, much of  the proofs  of  4.1  and
4.9  (in particular, the proper way  to handle the condensation argument and the use
of  shufflings)  can be  found  in their  paper.  Third, there are  remarks  identical  with
4.10  and 4.11. However,  their paper supercedes  mine with  respect to 4.13, as it even
shows  decidability of  the theories  involved.

REFERENCES

[1]  Burgess,  J.  P. and Y.  Gurevich, "The decision problem  for  linear temporal  logic,"

Notre  Dame  Journal  of  Formal Logic, vol.  26  (1985), pp.  115-126.

[2]  Kunen, K.,  Inaccessibility Properties of  Cardinals, Dissertation  Thesis,  Stanford

University,  1968.

[3]  Rosenstein,  J.  G., Linear  Orderings, Academic  Press,  New York,  1982.

Mathematisch  Instituut
Plant age Muidergracht 24
1018 TL Amsterdam
The Netherlands


