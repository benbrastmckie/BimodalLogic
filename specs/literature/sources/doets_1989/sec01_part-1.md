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