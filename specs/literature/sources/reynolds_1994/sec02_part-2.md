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
