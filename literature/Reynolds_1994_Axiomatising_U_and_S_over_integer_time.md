A x i o m a t i z i n g   U  and  S  over  Integer  T i m e

M  Reynolds 1

Imperial College
LONDON SW7  2AZ.

A b s t r a c t .   We give a  Hilbert  style axiomatization for the  set  of formu-
las  in  the  temporal  language  with  Until and  Since which  are  valid over
the  integer  number  flow  of time.  We  prove weak  completeness  for  this
orthodox axiom system.

1

I n t r o d u c t i o n

We  continue  a  long  tradition  of axiomatizing  temporal  logics.  Variations  on  the
theme  have  been  achieved by  varying the  language  used  to  talk  about  events  in
time  and  by  varying  the  assumptions  made  about  the  nature  of  time.  In  this
paper  we  consider  the  particularly  interesting  case  of the  language  with  "until"
and  "since"  over integer  number  time.

Early  axiomatization  results  were  for  the  language  with  two  temporal  con-
nectives:  F  for  "will"  and  P  for  "was".  Completeness  of axiomatizations  for this
language  over  various  flows  of  time  can  be  proved  by  tinkering  with  Henkin
constructions  (see  for  example  11).

The  stronger,  more  expressive,  language  with  "until"  (U)  and  "since"  (S)
presents  more difficulties. Burgess  1  gives a  more complicated Henkin construc-
tion  which  is  sufficient  to  prove  completeness  when  we  consider  certain  whole
classes  of flows  of time  such  as  linear  flows.

Axiomatization  over  the  rational  numbers  fall  out  of  Burgess'  work  easily.
However,  it  is  generally more  difficult  again  to  get  completeness  results  for spe-
cific flows of time.  Although axioms for U  over the more  "useful" natural numbers
flow appear  with  an  involved proof in  4  an  axiomatization  of U  and  S  over the
natural  numbers  flow  (along  with  other  classes  of well-orderings)  has  only just
been  given  in  12.

In  this  paper,  we use  the  techniques  developed in  9

to  provide an  axiomati-
zation  for  U  and  S  over the  integers.  After  defining the  logic in  the  next  section
we will show that  only a  weak completeness result  can be  expected.  Thus  we can
only find  a  syntactic  analogue  of the  consistency of a  single formula rather  than
being able to find an  analogue of the  general consequence relation.  It  will be  seen
that  the  weak  form  of  completeness  is  still  very  useful:  in  fact  the  distinction
between  weak  and  strong  here  is  subtle  enough  to  be  often  ignored.

i  The  author  would  like  to  thank  the  temporal  logic  group  at  Imperial  College  for
suggesting  many improvements.  The  work  was  supported  by the  U.K.  Science and
Engineering Research  Council under the  Metatem  project  (GR/F/28526).

118

Then,  we present the  axiomatization, and comment on its obvious soundness.
for the  reals  and  unlike that
It  is important  to note that  like our  result  in  9
in  3,  our  axiomatization  does  not  use  any  unorthodox  rules  of inference  such
this  rule  is  slightly
as  the  IRR  rule  of  7.  For  reasons  discussed  in  9  and  12,
controversial  and  it  is  important  to  show that  it  is  not  necessary.

In  most  of  the  rest  of  the  paper  we  prove  the  completeness  result  devot-
ing sections to finding a  rational-flowed model, proving expressive completeness,
proving  Dedekind  completeness for  a  certain  type  of definable equivalence,  find-
ing a  integer-flowed model  and  concluding the  proof.

The  integer  numbers  flow of time  is  obviously a  useful  model  for  situations
in  which  we  have  discrete  moments  of time  but  have  neither  a  beginning  or  an
end  of time.  We  see  an  example  of a  such  a  situation  in  the  temporal  database
work  of  2  where  the  axiom  system  presented  here  is  modified  into  an  axiom
system for resoning with  updates  of databases.

2

T h e   L o g i c

In this paper  temporal structures, which we will often just  call structures,  will be
linear.  Thus  they  consist  of a  domain  T,  an  irreflexive linear  order  <  on  T  and
a  valuation  h  assigning each p  of a  countable  set  of atoms  to  a  subset  h(p) C T.
The  underlying  linear  order  (T, <)  of a  structure  (T, <, h)  is  called  the  flow  of
time  of (T, <, h).

The  temporal  language  will usually  be  that  generated  by  the  connectives  U
and  S.  The  set  of formulas  is  defined recursively to  contain  the  atoms,T  and  _L
and  for  formulas  A  and  B,  we  include  ~A  and  A  A B  along  with  U(A, B)  and
S(A, B).  U(A, B)  is read  "until A,  B"  or  "B  until  A".  Similarly S  is to  be  read
as  "since".

Formulas  are  evaluated  at  points  of  the  flow  of  time.  The  readings  above
suggest  the  semantics  but  more  formally truth  is  defined recursively as  follows.
Suppose  that,  inductively, we  have  defined the  truth  of formulas  A  and  B  in  a
structure  (T, <, h)  at  all  points  t:  now define
(T, <, h)  ~  p(t)
(T, <, h)  ~  T(t)
(T, <, h)  ~= A_(t)
iff (T, <, h) ~= A(t)
(T, <, h) ~  (-~A)(t)
( T , < , h )   ~  (d  A B)(t)  iff ( T , < , h )   ~  A(t)  and  ( T , < , h )   ~  B(t)
(T, <, h)  ~  U(A, B)(t)  iff there  is  s  >  t  such  that

iff t  E  h(p),  for p  atomic

(T, <, h) ~  A(s)  and
for  a l l u E T ,

i f t < u < s t h e n ( T , < , h ) ~ B ( u )

(T, <, h)  ~  S(A, B)(t)  iff there  is  s  <  t  such  that

(T, <, h) ~  A(s)  and
for  all  u  E T,  if s  <  u  <  t  then  (T, <, h) ~  B(u)

Often,  because  of  the  symmetry  of  their  definitions,  results  involving  U
and/or  S  have dual or  mirror versions which can be stated  and proven by simply

119

swapping  U  and  S  for  each  other  and  swapping  <  and  >  in  the  original.  We
mention  these  frequently  but,  of course,  never bother  to  prove them.

As  usual  we  have  all  sorts  of abbreviations:  the  classical  ones  V,  --+  and  ++

along  with
for  U(A,T)
FA
for  S(A,T)
PA
for  -~F-~A
GA
HA
for-~P-~A
K+A  for  -~U(T, ~A)
K - A   for  -~S(T, -~A)  -  A  was  true  arbitrarily  recently.

-  A  will  be  true,
-  A  was  true,
-  A  will  always  be  true,
-  A  was  always  true,
-  A  will  be  true  arbitrarily  soon  and

For  formula  A  and  set  F  of formulas  we  write  F  ~  A  iff for  all  valuations  h
into  Z,  for all  t  E  Z,  if for all  B  E  F,  (Z, <, h)  ~  B(t)  then  (Z, <, h)  ~  A(t).  We
are  trying  to  find  a  syntactic  equivalent  to  this  consequence relation.

In  the  proof  we  will  have  to  consider  flows  of time  other  than  integers  but
throughout  this  paper  all  temporal  structures  will  be  assumed  to  have  linear
flows.

3  W e a k   v e r s u s   S t r o n g   C o m p l e t e n e s s

We  are  only  going to  be  able  to  prove a  weak  completeness  result  for this  logic.
Let  us  review  the  concepts  involved  before  seeing  why.  Suppose  that  we  are
dealing  with  a  class  ~  offiows  of time  and  an  axiom  system  Z  for  the  logic  of
some  temporal  language  s  over ~.  Assume  the  usual  definition of a  proof (in  Z)
of a  formula  A  from  a  set  F  of formulas.  Write  F  F z   A  if there  is  such  a  proof.
Since  each  inference  rule  only  has  one  formula  as  a  conclusion  in  such  axiom
systems  we  will  call  them  finitary  axiom  systems.

Assume  all  the  usual  definitions  for

-

syntactic  concepts  like  theorems,  consistent  sets,  consistent  formulas  and
maximal  consistent  sets  for  Z,

-  semantic  concepts  like  ~ : ,   models  of  sets  of  formulas,  satisfiability  and

validity for  t:  and
-  soundness  of Z  for ~.

Recall  that  Z  is  strongly  complete  (often just  written  complete)  for ~  iff one

of the  following two  equivalent  conditions  hold:

i f / "   is  Z-consistent  then  F  has  a  model  in  t:,

-
-  for  all  F,  A,  if F  ~ t :   A  then  F  Fz  A.

To  show  that  we  can  not  have  a strongly  complete  axiomatization  in the case
of  U  and  S  over  the  integers  we  will  use  the  concept  of compactness.  We  say
that  a  logic has  the  compactness property iff every  unsatisfiable  set of formulas
has  an  unsatisfiable  finite subset.

T h e o r e m   1.  If a logic has a sound  and strongly complete finitary  axiomatization
then  it  also has  the  compactness  property.

120

This  follows  easily  from  the  definitions  as  a  proof  of  inconsistency  of  a  set

only uses  a  finite  number  of formulas  from  that  set.

It  follows  that  there  can  be  no  sound  and  strongly  complete  finitary  ax-
iomatization  of the  logic  of  U  and  S  over  integer  time.  This  is  because  we  can
see  that  the  logic  is  not  compact  by  consisdering  the  set  {A,~  I n  E  N}  where
Ao  =  F(q  A H(-~q))  and  for  each  n  E  N,  A~+I  =  F(p  A A~).  The  set  is  clearly
unsatisfiable  while  all  its  finite  subsets  are.

Fortunately,  there  is  a  weaker notion  of complteness  which  is  still  useful.  We
say  Z  is  weakly  complete  for C  iff one  of the  following two  equivalent  conditions
hold:

if A  is  Z-consistent  then  A  has  a  model  in  C,

-

-  for  all  finite  F,  for  all  A,  i f / "   ~ :   A  then  F  Fz  A.

In  the  rest  of  this  paper  we  will  show  that  this  is  indeed  a  weaker  notion
by  showing  that  the  logic  of  U  and  S  over  the  integers  does  admit  a  weakly
complete  axiomatization.

4  T h e   A x i o m a t i z a t i o n

Our  system  U S / Z   has  the  usual  rules  for  a  temporal  logic:  i.e.  modus  ponens,
generalizations  and  substitution:

A, A  ~  B
B

A
GA

A(q)

A
"HA  A(q/B)

-

-

-

-

The  axioms  of U S / Z   are:

q)

all  classical  tautologies,
the  six  Burgess-Xu  axioms
(u(p, r)  U(q, r))
c(p
G(p  --+ q)  --+ (U(r,p)  --+ U(r,q))
p  A U(q, r)  -+  U(q A S(p, r), r)
U(p, q)  -+ U(p, q A U(p, q))
U(q A V(p, q), q)  -+  U(p, q)
U(p, q) A u(r,  s)

U(p A r,q  A s)  V U(p A s,q A s)  V U(q A r, q A s)

along  with  each  of their  duals,
plus  axioms  for  discreteness  and  no  end  points:
U(T, (cid:127)
and  suitable  versions  of the  Prior  axioms:
Prior-UZ:  Fp  -+  U(p,-~p)
Prior-SZ:  Pp  --~ S(p,-~p)

and  S ( T ,  (cid:127)

Soundness  is  clear:  we  are  going  to  spend  the  rest  of the  time  proving  weak
completeness.  The  next  few  sections  establish  a  variety  of  useful  preliminary
results.

Notions  such  as  maximal  consistent  and  F- are  assumed  to  refer to  the  logic
of U  and  S  over the  integers  and  our  system  U S / Z   unless  otherwise  specified.

121

5  The  Burgess-Xu  Result

Our  task  in  this  section is  to  find a  model of a  consistent formula which  has  a
vaguely integer-like flow  of time  and  is  one  in  which  U(T, l ) ,   S(T, l )   and  all
substitution  instances  of the  Prior  axioms  are  valid.  Fortunately,  most  of the
work has  been  done  already. Burgess in  1  proves  soundness  and  completeness
of a  set  of axioms for  linear  time.  Xu,  in  13,  simplifies  the  set  of axioms  and
the  proof.

T h e o r e m  2.  The  Burgess-Xu  system  (the  six  axioms  and  duals,  propositional
tautologies  and  the four  rules)  is  sound  and  strongly  complete  for  the  US  logic
on  the  class  of all  linear frames.

Although neither  Burgess  nor  Xu  mention  strong  completeness their  proofs

do  establish that.  This  is just  as  well for we need strong completeness.

Let us  see  how we can use this  theorem.
Now  suppose  that  we  have  a  set  F  of formulas  consistent  with  the  system
U S / Z .   Knowing Lindenbaum's lemma, we can, without loss of generality, assume
that  F  is  maximal consistent.

By the theorem, since F  is also consistent with the Burgess-Xu system, there
will  be  a  linear  model  for  F:  i.e.  a  linear  structure  in  which  there  is  a  point,  t
say,  at  which all the formulas in F  hold.

By  looking at  Burgess's  construction  (or  using  LSwenheim-Skolem) we  can

suppose  that  the  structure is  countable.

Since  GU(T, _L)  and  its  mirror  must  be  true  at  t,  the  order  does  not  have

end  points  and the  order is  discrete.

Because  it  says  so  in  F,  all  the  substitution  instances  of the  other  axioms

hold everywhere so we have...

C o r o l l a r y  3.  For every US~Z-consistent  set F  of formulas,  there  is  a temporal
structure  M  and  t  E M  such  that

1.  the flow  of time  of M  is  countable,  discrete  and  without  end points,
2.  for  all A  e  F,  M  ~  A(t)  and
3.  all  substitution  instances  of the  axioms  Prior-UZ  and  Prior-SZ  are  valid  in

M.

6  Expressive  and  Dedekind  Completeness

An  important technique in  our  proof is  that  of switching between the  temporal
language  and  an  associated  first-order  one.  Let  us  introduce  the  concepts  and
results  needed.

We  will  associate  a  temporal  language  with  a  first-order  one  called  the
monadic  language because  it  is  built  from  a  signature  containing  only  1-ary
predicate  symbols  along  with  the  binary  <  predicate  symbol.  Each  atom p  in

122

the temporal language corresponds to a predicate symbol P.  We can make a tem-
poral structure  (T, <, h)  into a first-order structure in the monadic language, by
interpreting  <  as  <  and  each P  as  being true  of exactly those points  in  h(p).

If,  as  will  later  be  the  case,  we restrict  to  a  temporal  language with  a  finite
number of atoms then the monadic signature is finite but otherwise it will contain
a  countable number  of 1-ary predicate symbols.

It  turns  out,  unsurprisingly,  that  the  temporal  formula  U(p,q)  is  true  at

exactly those points  in  a  structure  where the  monadic formula

r

=  3s  >  t(P(s)  AVu(t  <  u A u   < s  -+ Q(t)))

holds.  A  simple  induction,  (see  for  example  5),  establishes  that  all  temporal
formulas A  have  a  corresponding monadic formula CA in  one free variable such
that,  for all structures  (T, <),  for all valuations h,  for all t  E T,

(T, <,h)  ~  A(t)  iff (T, <,h)  ~  CA(t).

We call CA  the  table of A.  The  induction generalises to  show that  provided the
connectives of the  language have first-order tables,  as  U  and  S  do,  then  all the
temporal  formulas of any temporal language have first-order tables.

One  may  ask  whether  all  first-order formulas with  one free  variable  can  be
got  as  tables  of temporal  formulas.  This,  of course,  depends  on  the  temporal
connectives used in the language, but it also depends on what class of structures
we  restrict  attention  to.  Let  us  be  more  precise.  Suppose  that  8  is  a  class  of
temporal  structures.  We  say that  a  temporal  language is  expressively  complete
with one free variable, there
over 8  if and only if for each monadic formula r
is a temporal formula A of the temporal language such that for all  (T, <, h)  C 8,
for all t  C T,

(T, <, h)  ~  r

iff (T, <, h)  ~  A(t).

Note  the  uniformity  of the  translation  over the whole  of S.

One  of the  first expressive  completeness  results  was  that  of Kamp's  in  8.
Kamp  showed  expressive  completeness  for (the language  with)  U  and  S  over the
class of all structures  whose  underlying  flow  of time  is Dedekind  complete.

As  shown  in  5,  U  and  S  are  still expressively  complete  even  if we  allow
isolated  gaps  in the structure  but  as has  been  known  for while,  and  as is shown
in  5,  lemma  3,  over  the  whole  class  of  structures  whose  underlying  flow  of
time  is  linear,  U  and  S  are  not  expressively  complete.  To  achieve  expressive
completeness for the  class of all  structures  with linear flows we  need to  use the
so called Stavi  connectives U'  and  S'  which were  defined in  4.  U'(A, B)  holds
if B  is true  from now until  a  gap  in  time  after which B  is  arbitrarily soon false
but  after which A  is true  for a  while:  U~(A, B)  is  as pictured

B

<. . . . .

B

now

0
a  gap

A

S ~ is  defined dually. Despite  involving a  gap,  U ~ is  in  fact  a  first-order  con-

nective and  its table  is  given by:

123

U' (p, q)  -
t < s
3s
AVu  (
(

v

t < u < s - ~
Bv(u  <  v  A Vw(t  <  w  <  v  --4 q(w))
v v ( u   <  v  <  s  -~  p 0 ) )
~v(t  <  v  <  u  A  - q ( v ) )

A

))

A  ~ut  <  u  <  s  ^  ~q(~)
A 3 0   <  u  <  s  A w ( t   <  v  <  ~  -+  q(~))

We  have

T h e o r e m 4 .   The  language  with  {U, S, U', S'}  is  expressively  complete  for  the
class  of structures  with  linear flow  of time.

direct  proof -  is in  5.  In  6

This  result  is  mentioned  in  4  without  proof.  The  first  published  proof  -  a
is  a  proof using the  separation  technique of Gabbay.
Obviously  there  is  some  connection  between  definable  gaps  and  our  Prior
axioms.  Call  a  linear  temporal  structure  a  Prior  structure  if it  satisfies  all  sub-
stitution  instances  of

Prior-U:U(q-,p)  A F~p  -+  V(-~p V K+(-~p),p)

and  its  dual  Prior-S.  It  is easy to  see that  then  there  are  no  definable  gaps.  Note
that  this  result  also  holds  for our  stronger  Prior  axioms  Prior-UZ  and  Prior-SZ
(the  weaker  axioms  are  useful  in  non-discrete  structures).  It  is  now  not  hard  to
prove the  following  (see  3,  proposition  4.2).

T h e o r e m   5.  The  language  with  U  and  S  is  expressively  complete  for  the  class
of Prior  structures.

Proof.  By the  expressive completeness of {U, S, U', S'}  over all linear  structures,
it  suffices  to  prove  that  for  any  {U, S, U', S'}-formula  B',  there  is  a  {U,S}-
formula  B  such  that  B'  ++ B  is  valid  in  all  Prior  structures.

This  can  be  achieved  by  a  simple  induction  on  the  construction  of such  Bq
The  cases  of atoms  and  A,  -~,  U  and  S  are  immediate.  Let  us  look  at  U'(A, B)
when,  by  induction,  we  can  suppose  that  A  and  B  are  US-formulas.  We  claim
that  U'(A, B)  ++ J_ is  valid  in  all  Prior  structures.

Suppose  for contradiction that  M  ~  U'(A, B)(t)  in  some  Prior  structure  M.
Thus  B  holds  for a  while  up  until  a  gap  after  which  -~B  is  true  arbitrarily  soon.
By  Prior-U  applied  to  B  we  have  M  ~  U(-~B  V  K+(~B),B)(t)  which  is  the
contradiction.

The  case  of S'  is  similar.

7  N o   g a p s   b e t w e e n

e q u i v a l e n c e

c l a s s e s

We  know  that  the  Prior  axioms  ensure that  there  will not  be  any definable  gaps
in  a  model.  To show  that  our  model  can  be  made  into  a  model  over the  integers

124

we  actually  need  a  stronger  result.  We  need  to  know  that  a  certain  type  of
definable  equivalence  relation  also  does  not  have  its  equivalence  classes  ending
at  gaps.  First  some  definitions.

The  intervals  of a  structure  M  are just  the  convex subsets  of M  and  we  will

use  the  usual  (a, b,  etc.,  notation  for them.

If S  is  a  subset  of the  domain  of a  temporal  structure  M  (usually  S  will  be
an  interval  here)  then  we  write  M  I S  for  the  temporal  structure  with  domain
S,  ordering  as  in  M  and  interpretation  of  atoms  just  the  restrictions  of  the
interpretations  in  M  to  S.  M  I S  is called  the  substructure  of M  with  domain  S.
Suppose  that  ~(x, y)  is  a  monadic  formula  with  two  free  variables  x  and  y.
We  say  that  ~  defines  a  contemporaneous  equivalence  relation  if  and  only  if on
any  temporal  structure  M,  if we  define the  binary  relation  ~'~M by

a  ~M  b iff  ~  s(a,b),

then

"~M  is  an  equivalence relation  on  the  domain  of M,
~M  partitions  M  into  intervals  and

-

-

-  ~ depends  only  on  contemporary properties:  i.e.  for  all  a, b E  M,

r

b)  iff  I a,  b  ~  r

b).

A  binary relation ~  on a  structure  M  is called a  contemporaneous  equivalence

relation  if and  only if it  is  defined  as  ~M  by  such  an  ~.

We prove that  no so defined contemporaneous equivalence relation has  equiv-

alence  classes  ending  at  gaps  in  any  Prior  structures.

Given  such  an  s,  define  p(x)  as

Sy  >  x  -~(x, y)

A

<  z  A

z)  A vy(

  <  y  <

y))).

This  says  that  x's  K-class  ends  in  a  gap  on  the  right.  Dually  we  can  define  A(x)
about  left  ends.  Note  that  the  end  of the  whole  structure  is  not  a  gap  and  that
p  will  not  hold  of points  in  the  last  "~M  class  (if there  is  such  a  class).

Now  by the  expressive  completeness  of U  and  S  there  is  temporal  R  true  in

any  Prior  structure  exactly where  p(x)  is.

L e m m a   6.  Suppose  that ~  defines  the  contemporaneous  equivalence  relation  ~'~N
on  any  structure  N .

Then  there  is  an  US-formula  R  which  holds  in  any  Prior  structure  N  exactly

at  those  points  whose  ..~g-class  ends  in  a  gap  on  the  right.

Dually  L.

Now  suppose  that  M  is  a  Prior  structure  and  that  ~ = ~ M

is  a  contempora-

neous  equivalence relation  defined  by  e.

125

L e m m a   7.  The  maximal  intervals  in  which R  holds  are  open  intervals  which,  if
bounded,  have  elements  of M  as  their  (excluded)  end points.

Proof.  Suppose  that  R  holds  at  t  E  M.  Clearly  p  holding  at  t  implies  that  R
will  hold  for  a  while  after  t:  up  until  a  gap  in  fact.  Thus  t  is  in  a  non-singleton
interval  of R.  It  is  possible  that  R  holds  for  ever  after  t.

If R  does  not  hold for ever  after t  then  Prior-U  applied  to  R  implies  that  M
contains  a  last  point  of this  stretch  of R  (plainly  impossible  given  p)  or  a  first
point  of -~R.  This  is  as  claimed.

Now  look  to  the  left  of t.  Looking back  from just  after  t  we  can  use  Prior-S
and  see  that  either  R  is  true  always  before  t,  there  is  a  last  point  of  -~R  just
before this  stretch  of R  or  there  is  no  last  point  of -~R,  but  instead  a  first  point
of  R.  We  must  rule  out  the  third  case.  Note  that  in  the  case  of  M  not  being
dense there may be both  a  last point of -~R and  a first point of R:  this possibility,
subsumed  in  the  second  case  above,  is  acceptable  in  that  it  implies  an  excluded
end  point.

Suppose,  for  contradiction,  that  s  is  this  first  point  of R  so  that  M  ~  (R A
K-(-~R))(s).  The  ,-~-class  containing  s  can  not  stretch  for  ever  into  the  future
for then  it  does not  end in a  gap.  Neither can it  stretch to the end of the  maximal
interval  of R  as  it  would  again  not  end  at  a  gap.

Thus  there  are  other  classes  in  this  interval  continuing  on  the  other  side  of
the  gap  which  ends  s's.  And  for a  while  after the  gap  R  continues to  be true:  we
have  not  reached  the  end  of the  interval  yet.  Thus  R  A K-(-~R)  does  not  hold
at  the  left  hand  end  of any  of these  classes.

Let  B  be  the  temporal  formula saying that  the  ,~-class  we  are  now in  begins
with  a  point  satisfying  R  A K-(-~R).  B  exists  by  expressive  completeness.  B
holds  in  s's  class  up  to  the  gap  and  is  false  arbitrarily  soon  after  the  gap.  This
contradicts  Prior-U  applied  to  B.

L e m m a   8.  There  is  no  last  class  and  no first  class  in  any  maximal  interval  of
R.

Proof.  The  last  class  in  a  maximal  interval  of R  wouldn't  end  in  a  gap.

By  expressive  completeness,  the  formula

p(x)  A

<

y)

az(y  <  z  <  A

has  a  temporal  equivalent  which  is  true  only  in  the  first  classes  of  maximal
intervals  of  R.  If  there  is  a  first  class  then  no  immediately  subsequent  classes
satisfy this  and  so we  have this  formula holding  up  to  a  gap  and  false arbitrarily
soon  afterwards.  This  contradicts  Prior-U.

L e m m a   9.  If  a  temporal formula  holds  somewhere  in  one  ~-cIass  in  a  maximal
interval  of R,  then  it  holds  somewhere  in  each  ,~-class  in  the  interval.

Furthermore,  each  pair  of the  ,,~-classes  in  a  maximal  interval  of R  are  ele-

mentarily  equivalent  (  taken  as  substructures  of M).

t26

Proof.  For  a  contradiction  to  the  first  statement,  suppose  that  A  holds  in  one
class  but  not  anywhere  in  some  other  class  in  the  same  maximal  interval  of R.

Using  expressive  completeness  and  ~,  find  B  which  is  true  at  points  only  if
A  occurs  somewhere  in  their  ,-~-class.  By  using  -~B  instead  if necessary  we  may
suppose  that  we have B  holding throughout  one  ,~-class in  our maximal  interval
of R  and  false  throughout  a  later  class.  Choose  a  point  t  in  this  former  class  in
which  B  holds.  B  holds  in the  whole of a  class if it  is true  anywhere at  all in the
class  so  it  continues  for  a  while  after  t.  By  Prior-U  there  is  either  a  last  point
where  B  holds  after  t  (not  possible  as  B  must  continue  for  a  while)  or  a  first
point  s  >  t  where  -~B A K - ( B )   holds.

So  s  must  be  the  left  hand  end  point  of its  ,~-class.  Look at  the  gap  at  right
hand  end  of this  class.  We can  not  have B  arbitrarily soon  after the  gap  because
of Prior-U.  Thus  for  a  while  after  this  class  B  stays  false.

Let  C  be  the  temporal  formula saying  that  we  are  now  in  a  class  whose  teft
hand  end  point  is  also  in  the  class  and  at  that  point  K - ( B )   holds.  Now  C  is
true  in  s's  class  but  false  afterwards  contradicting  Prior-U.

Now  consider the  second statement  in  the  lemma.  Given  a  monadic  sentence
r  we  relativise  it  by  restricting  quantifiers  to  where  e ( x , - )   holds.  We  get  a
formula  r
of one  free  variable.  By  expressive  completeness  this  is  equivalent
to  a  temporal  formula.  This  is  true  exactly  throughout  ,-~-classes  which  model
r  Then,  by  the  first  part  of  the  lemma,  it  can't  be  true  somewhere  and  false
elsewhere  in  the  interval.

We  define  a  bad point  to  be  where  R  V L  holds.  We  define  a  bad interval  as

a  non-empty  and  maximal  one  in  which  R  Y L  holds  throughout.

L e m m a   10.  Bad points  only  occur  in  non-singleton  bad  intervals.

In  any  bad  interval  both R  and  L  hold  throughout.  Any  bad  interval,  if
bounded,  has  excluded  end  points  in  M  (neither  R  nor  L  holds  at  these  end
points).

Proof,  We  first  show  that  L  holds  wherever  R  does.  Suppose  for  contradiction
that  we have a  maximal  interval of R  in  which  L  fails to  hold  somewhere.  So  ~L
holds throughout  at  least  one ,~-class.  By the  definition of L, there are two cases.
Either  this  particular  N-class  is  one  which  includes  its  left  hand  end  point  or  it
is one which  begins just  after some  point  of M.  The  class  can  not  be  unbounded
below  for then  it  would  be  first  in  this  bad  interval.

In  fact  we  can  not  have a  class  beginning just  after  a  point  r  of M.  Since the
class  can  not  be  first  in  the  bad  interval  r  itself must  be  in  a  ,-~-class  in  the  bad
interval.  But  r's  class  can  not  end  in  a  gap  on  the  right  when  r  must  be  its  right
hand  end  point.

Thus  we  have  a  class  in  the  bad  interval  which  includes  its  left  hand  end
point.  Its  not  hard  to  use  the  previous  result  to  show  that  throughout  the  bad
interval  all  classes  include  their  left  hand  end  points.

Let B  be  a  temporal formula true  at  times  which  are not  left hand  end points
of their  H-classes.  B  is  then  true  continuously  in  any  class  from  just  after  the

127

left  hand  end  point  up  until  the  gap  at  the  right  hand  end  point.  B  must  be
false  arbitrarily soon after the  gap  contradicting Prior-U.

Using  mirror images  of the  above and  previous results  we  get  our proof.

L e m m a   11.  If a formula  B  is  true for  a  while  at  the  start  of a H-class  in  a  bad
interval  then  it  holds  throughout  the  bad interval.  Similarly  at  the  end.

If  a formula  is  true  anywhere  in  a  bad  interval  it  is  true  arbitrarily  close  to

each  end  of  each  class  in  the  interval.

Proof.  Suppose  that  ?  <  5  are  gaps  and  that  (% 5)  is  a  ,-,-class  within  a  bad
interval.

Suppose  that  B  holds  for  a  while  after  7  but  that  -~B  holds  somewhere  in

the  bad  interval.  By lemma  4,  -~B also holds somewhere in  (% 5).

Using z and expressive completeness we can find a temporal formula C  which
is  true  only  at  points  within  a  u-class  after  some  -~B  in  that  class.  C  will  be
false for  a  while  at  the  beginning  of each  class  and  then  true  for a  while  at  the
end.

In  fact  C  is  true  for  a  while  up  to  the  gap  at  the  end  and  false  arbitrarily

soon  after the  gap.  This  contradicts Prior-U.

Applying the  above to  the  negation of a  formula gives  us  the  second part.

Let  us  see  what  happens  if  we  interfere with  M  by  replacing  a  whole  bad

interval by one of its  ,---classes.

Let  Q -   be  the  subset  of the  domain  of M  being  all  that  precedes the  bad
interval.  Let  Q+  be  all  that  follows.  Either  or  both  of these  may be  empty.  Let
Qo  be  the  bad  interval itself and  I  be  any one of its  ,-~-classes.

We look at  N,  the  substructure of M  whose domain  is just  Q -   u  I  u  Q+.

L e m m a  12.  For  all  temporal formulas  A,  for  all  t  E N,

A(t)  iff N  ~  A(t)

Proof.  We  proceed by  induction  on  the  construction of A.  The  cases  of atomic
and  boolean  A  are immediate.  Now consider  U(A, B):  S(A, B)  is  similar.

( 0 ) :   Consider then when M  ~  U(A,B)(t)  with t  C N.  Say that  s  E M,  that

t < s ,

t h a t M ~ A ( s )

a n d f o r a l l u E M ,

i f t < u < s t h e n M ~ B ( u ) .

There are  several cases.

1.  t  <  s  E  Q- :  Apply  the  induction  hypothesis  to  A  and  B  at  s  and  at  all

points  in  between.

2.  t  E  Q -   and  s  E  Qo:  A  holds somewhere in  Qo  so somewhere in  I  (by lemma
6).  So  holds  there  in  I  in  N.  B  holds  for  a  while  into  Q0  so,  by  lemma  6,
holds  everywhere in  Qo.  By  the  induction  hypothesis,  B  holds  everywhere
in  I  in  iV.  Hence result.

3.  t  E  Q -   and  s  E  Q+:  We  can  deduce  that  B  holds  throughout  I  in  both  M

and  N  and  get the  result.

4.  t  <  s  E I:  Straight  forward use of inductive hypothesis.

128

5.  t  E  I  and  s  later  in  Q0:  Again  by  l e m m a   6  we  have  B  true  throughout  I  in
M  and  so  in  N.  Since  A  is  true  somewhere  in  Q0  in  M,  l e m m a   6  tells  us
t h a t   A  is  true  arbitrarily  close  to  the  end  of I  in  M  and  so in  N.  This  gives
us  our  result.

6.  t  E  I  and  s  E  Q+:  B  is  true  throughout  I  and  we  have  our  result.
7.  t  <  s  E  Q+:  Apply  induction  hypothesis  to  A  and  B  at  s  and  at  all  points

in  between.

( ~ )   :  Consider  then  when  N  ~  U(A,B)(t).  Say  t h a t   t  <  s,  t h a t   N  ~  A(s)

and  for  all  u  E  N ,   if t  <  u  <  s  then  N  ~  B(u).

Again  there  are  several  cases:

1.  t  <  s  E  Q - :   Apply  induction  hypothesis  to  A  and  B  at  s  and  at  all  points

in  between.

2.  t  E  Q -   and  s  E  I:  B  holds  from  t  up  until  the  end  of  Q -   in  both  M  and
N.  B  holds  at  the  beginning  of  I  in  N  and  so  in  M.  By  l e m m a   6  B  holds
throughout  Q0.  A  holds  in  I  in  N  and  so  in  M  and  we  have  our  result.
3.  t  E  Q -   and  s  E  Q+:  B  holds  throughout  I  in  N  and  so in  M.  L e m m a   6  tells

us  B  holds  throughout  Q0  in  M.

4.  t  <  s  E  I:  Straight  forward  use  of inductive  hypothesis.
5.  t  E  I  and  s  C  Q+:  B  is  true  throughout  I  and  we  have  our  result.
6.  t  <  s  E  Q+:  Apply  induction  hypothesis  to  A  and  B  at  s  and  at  all  points

in  between.

L e m m a   13.  In fact  there  can't  have  been any  bad points  anyway.

Proof.  By  l e m m a   7,  R  holds  in  I  in  N.

But  by  l e m m a   1,  R  holds  at  a  point  in  any  Prior  structure  (not  just  M )   if
and  only  if  the  ,,~-class  of  the  point  ends  in  a  gap  (where  ,~  is  the  appropraite
equivalence  relation  for  the  structure).  And  N  is  a  Prior  structure:  we  still  have
all  the  instances  of  P r i o r - U / S   continuing  to  hold  as  any  counterexample  point
in  N  is  also  one  in  M.

By  the  contemporaneity  of c,  I  as  a  subset  of N ,   like  I  as  a  subset  of  M,  is

all  in  one  ~',y-cass.  Could  the  class  be  bigger  now?

R  is true  of this  class so t h a t   it  is bounded  above amongst  other  things.  Thus
Q+  is  non-empty  and  by  l e m m a   5  begins  with  a  point  q  say.  Also  by  l e m m a   5
-~R  holds  at  q  in  M  and  so  in  N .   Clearly  q  is  not  in  the  class  of  I  in  N.  Thus
the  class  ends  just  before  q.

R  can  not  have  been  true  in  this  class  after  all.

Thus  we  have  proven...

T h e o r e m   14.  Suppose  that  ,,~  is  a  contemporaneous  equivalence  relation  on  a
Prior structure  M.

Then  the  ,,~-classes do  not  end  at gaps.

129

8

U s i n g   C o n t e m p o r a n e i t y

o n   t h e

I n t e g e r s

Let  us  see  how  we  can  use  the  theorem  above  in  our  proof.  Note  that  here  we
are  working  in  a  language  with  only  a  finite  number  of atoms  though.

T h e o r e m   15.  Suppose  that  M
that

is  a  temporal  structure  in  a finite  language  such

the  flow  of  time  of M
all  substitution  instances  of  the  axioms  Prior-UZ  and  Prior-SZ  are  valid  in
M.

is  countable,  discrete  and  without  end  points,

Then for  all k  <  w,  there  is  a  temporal  structure  with flow  of time  the  integers
satisfying  the  same  monadic  first-order  sentences  of  quantifier  depth  at  most  k
as  M  does.

Proof.  First  some  preliminaries.  Fix  k  >_ 3.

Here a  structure  will mean  a  linear temporal  structure  in  our finite  language.
If M  and  N  are  structures  we  write  M  =--k N  if and  only  if M  and  N  agree
on the  t r u t h   of monadic  sentences of quantifier depth  at  most  k.  Note  that  since
k  _> 3, if M  - k   N  then  M  and  N  either both  have a  right(respectively left)  hand
end  point  or  both  do not  have  a  right(resp,  left)  hand  end  point.  Discreteness  is
also  preserved.

We  assume  familiarity with  lexicographic sums  of linear  orders  and  with  the

fact  that  --k  is  preserved under  such  sums.  See  10,  3  or  9

for  details.

If  a  is  an  element  of  a  discrete  structure  M

then  we  write  a  -  1  for  its
immediate  predecessor  if it  has  one  and  a  +  1  for  its  immediate  successor,  if it
has  one.

Say  that  M  is  good if and  only  if there  is  some  N  - k   M  such  that  the  flow

of time  of N  is  an  interval  of the  integers.

Say  that  M  is  very  good  if and  only  if,  for  all  t  _< u  in  M,  the  substructure

M  lt  ,u

is  good.

L e m m a   16.  If N

is  countable  and  very  good  then  it  is  good.

Proof.  All  finite  structures  are  good  so  suppose  that  N  has  countably  infinite
domain.  If N  has  two  end  points  then  it  is  clearly  good.  First  consider  the  case
when  N  has  a  beginning  a0  but  no  (right  hand)  end.

Choose ai  E  N  for each positive integer i  such that  i  <  j  implies  ai  <  aj  and
for  all  t  E  N,  there  is j  such  that  t  <  aj.  Since N  is  very good,  N  I ai,ai+l
-  1
is  good.  For  i  =  0, 1, ...,  take  Z~  --k  N  I ai,  ai+l  -  1  with  a  finite  interval  of  Z
as  a flow.

Because  --k  is preserved  under  lexicographic  sums,

the  latter  having  flow isomorphic to  a  (half)  subinterval  of Z.

N  --k  ~ e N ( Z ~ )

130

If  N  has  an  end  but  no  begining  then  the  proof  is  similar.  If  N  has  no
end  points  then  choose  a0  E  N,  use  the  above  arguments  on  (-c~,a0
and
a0  +  1, +co),  and  then  use  the  lexicographic  sum  result  to  add  appropriate
structures  together.

Define  "~M on  a  temporal  structure  M  by  for  any  a, b E  M,  a  "~M  b if and

only if

- -   a : b ~
-  a  <  b and  M  I a,  b  is  very good  or
-  b <  a  and  M  I b,  a  is  very good.

L e m m a l T .   ~ M
any  M .

is  a  contemporaneous  equivalence  relation  on  the  domain  o f

Proof.  Clearly there  are  only finitely many  logically inequivalent  maximal  con-
sistent  conjunctions  7  of sentences  of quantifier  depth  _< k.  Any  structure  is  a
model  of just  one  such  7,  so  if N1  ~  7  then  N2  --k  N1  iff N2  ~  7.  Only  some
will be  true  of good  structures-  {71,  .-.,%}  say.  N  is  good  iff N  ~  Vi<s 7i.

Let  7(z, t)  be  the  result  of  relativizing  the  quantifiers  of  V~<8 v~  to  z,  t,

where  z  and  t  are  new  variables.

Then

s ( x , y ) =

x  <  y  ~  Y z t ( x   <  z  <  t  <  y  ~ / ( z , t ) )
A  y  <  x  --+ V z t ( y   <  z  <  t  <  x - +   V(z,t))

is  a  formula defining  "~M-

To  show  that  ~  is  contemporaneous,  we  first  show that  it  is  an  equivalence
relation.  The  difficult part  is  transitivity.  Suppose  that  a  <  b <  c  are  in  M  and
a  ~M  b  and  b  "~M  c.  We  show  that  M    a,  c  is  very  good  by  showing  that  if
a  _< t  <  u  <  c  then  M  I It, u  is  good.

If t  and  u  are  on  the  same  side  of b then  this  is  clear.  If b =  t  or  b =  u  then

use  a  lexicographic sum.

So  assume  that  a  <  t  <  b  <  u  _< c.  First  note  that  since  M  I  b,c

is  very
good  then  it  is  als0  good  (even  if it  is  not  countable).  Thus  its  flow  is  discrete
and  there  is  a  successor  b +  1  of  b.  Now  M
  It, b  and  M  I  b  +  1,u  are  both
good.  Choose  Z1  -=k  M  I t,  b  and  Z2  ~k  M  I b  +  1, u  each  with  flow a  subset
of Z.  Then  we  know  that  M  t  It, u  - k   Z1  +  Z2  whose  flow is  isomorphic  to  an
interval  of Z  itself.

That  the  "~M  classes  are  intervals  follows from  the  fact  that  very  goodness

is  inherited  by  substructures  on  subintervals.

Contemporaneity  then  follows from  the  fact  that  the  definition of  ~M  is  in

terms  of exactly the  right  substructure.

Now  let  us  turn  to  the  proof of the  main  theorem.
If M  is good then  we are  done.  So suppose  not.  Thus  M  is not  very good.  So
there  is  a  <  b C  M  such  that  M    a,  b  is  not  good.  Thus  M    a,  b  is  not  very
good  and  we have  two  disjoint  ~  classes.

131

Now  a's  class  can  not  end  at  a  gap  on  the  right  (by  theorem  5  and  the  fact
that  Prior-UZ  and  dual  imply  Prior-U  and  dual)  so  it  must  include  a  point  c
but  not  the  successor  c +  1  of c.  This  can  not  be  because  M  I c,  c +  1,  like  all
finite  structures  is  very good  and  ~  is  transitive.

9

C o m p l e t e n e s s

Finally

T h e o r e m   18.  The  system  U S / Z   is  sound  and  weakly  complete  for  the  seman-
tics  over  structures  with  integers flow.

Proof.  Soundness  is  straightforward.

To  show  weak  completeness,  we  suppose  that  we  are  given  a  formula  Ao
consistent  with  U S / Z .   We  will find  a  model  of it  with  flow of time  the  integers.
First  use  Burgess-Xu  Corollary  1  to  furnish  us  with  a  structure  M0  and

to  E  M0  such  that

1.  the  flow of time  of M0  is  countable,  discrete  and  without  end  points,
2.  Mo  ~  Ao(to)  and
3.  all  substitution  instances  of the  axioms  Prior-UZ  and  Prior-SZ  are  valid  in

Mo.

By  ignoring  all  the  atoms  which  don't  appear  in  Ao  we  have  a  temporal

structure  M  from  a  finite  language.  M  is  still  a  model  of Ao.

Thus  we  can  apply  theorem  6.
Let  k  be  one  greater  than  the  quantifier  depth  of the  table  a(t)  of  Ao.  We
have  a  temporal  structure  2 ,   with  flow of time  the  integers,  satisfying the  same
monadic  sentences  of quantifier  depth  at  most  k  as  M  does.

Thus  Z  like  M  is  a  model  of 3ta(t).  Say  b E  Z  and  2;  ~  a(b).
We  have  2;  ~  A0 (b)  as  promised.

Axiomatizing  U  and  S  over  the  natural  numbers  can  be  done  in  a  similar

manner.

R e f e r e n c e s

1.  J  P  Burgess.  Axioms for tense logic  I:  "since"  and  "until".  Notre  Dame  J  Formal

Logic, 23(2):367-374,  1982.

2.  Marcelo Finger.  Handling database  updates in two-dimensional temporal logic.  J.

of Applied  Non-Classical  Logic, pages  201-224,  1992.

3.  D  M  Gabbay  and  I  M  Hodkinson.  An  axiomatisation  of the  temporal  logic  with
until and since over the real numbers.  Journal  of Logic and  Computation,  1(2):229
-  260,  1990.

4.  D.M.  Gabbay,  A.  Pnueli,  S.  Shelah,  and  J.  Stavi.  On  the  temporal  analysis  of
fairness.  In  7th  ACM  Symposium  on  Principles  of Programming  Languages,  Las
Vegas, pages  163-173,  1980.

132

5.  D  M  Gabbay, I  M Hodkinson,  and  M  A Reynolds.  Temporal expressive  complete-
ness  in the  presence of gaps.  In  Proceedings ASL  European  Meeting  1990, Lecture
Notes  in  Logic.  Springer-Verlag,  1993.

6.  D  Gabbay, I  Hodkinson, and  M Reynolds.  Temporal  Logic: Mathematical Founda-

tions  and  Computational  Aspects,  Vol. 1.  OUP,  to  appear  1994.

7.  D  M Gabbay.  An irreflexivity lemma with applications to aximatizations of condi-
tions  on tense frames.  In U  Monnich, editor,  Aspects  of Philosophical  Logic, pages
67-89.  Reidel,  Dordrecht,  1981.

8.  J  Kamp.  Tense  Logic and  the  theory  of linear  order.  PhD  thesis,  Michigan  State

University,  1968.

9.  M  Reynolds.  An  axiomatization  for  Until  and  Since  over  the  reals  without  the

IRR rule.  Studia  Logica, 51:165-194,  1992.

10.  J  G  Rosenstein.  Linear  orderings.  Academic Press,  New York,  1982.
11.  J  van  Bentham.  The  Logic of  Time.  Reidel,  Dordrecht,  1983.
12.  Y  Venema.  Completeness  via completeness.  In  M de Rijke,  editor~ Colloquium  on
Modal  Logic, 1991. ITLI-Network Publication,  Instit.  for  Lang.,  Logic  and  Infor-
mation,  University of Amsterdam,  1991.

13.  Ming Xu.  On some U, S-Tense Logics.  Journal  of Philosophical  Logic~ 17:181-202,

1988.


