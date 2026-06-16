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


