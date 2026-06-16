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