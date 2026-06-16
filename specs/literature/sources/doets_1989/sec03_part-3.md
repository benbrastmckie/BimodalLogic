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


