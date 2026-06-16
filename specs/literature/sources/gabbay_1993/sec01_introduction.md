<!-- Page 1 -->

TEMPORAL EXPRESSIVE COMPLETENESS
IN THE PRESENCE OF GAPS
D. M. GABBAY, I. M. HODKINSON, and M. A. REYNOLDS
1
Abstract
It is known that the temporal connectives until and since are ex-
pressively complete for Dedekind complete flows of time but that the
Stavi connectives are needed to achieve expressive completeness for
general linear time which may have "gaps" in it. We present a full
proof of this result.
We introduce some new unary connectives which, along with until
and since are expressively complete for general linear time. We ax-
iomatize the new connectives over general linear time, define a notion
of complexity on gaps and show that since and until are themselves
expressively complete for flows of time with only isolated gaps. We
also introduce new unary connectives which are less expressive than
the Stavi connectives but are, nevertheless, expressively complete for
flows of time whose gaps are of only certain restricted types. In this
connection we briefly discuss scattered flows of time.
§1. Introduction: the problem of expressive completeness.
This section will present the problem of expressive completeness of temporal
connectives within the more general model theoretic concept of the existence of
a finite G-basis for m-adic theories. The known results in this area will then be
outlined.
We begin with the ordinary propositional temporal logic. Assume we are given
a flow of time (T, <), where T is the set of moments of time and < is a transitive
and irreflexive relation on T, thought of as the earlier-later relation. We define
the notion of m-dimensional temporal logic on (T, <). An m-dimensional atomic
proposition q on (T, <) can be associated with a subset Q of Γ
m, representing
the set of all m-tuples of moments of time where q is true. The boolean logical
operations on temporal formulas, such as Λ, V, ~ and —» correspond naturally to
operations on these subsets. It is clear that a temporal assignment h to the atoms
associating with atoms ςrt subsets ft(</t) C Γ
m, gives rise to an ordinary model for
(T, <, <3, , =). To be able to express formally the connections between propositional
temporal formulas and subsets of Γ
m, we need to use the m-adic language with
(T, <, <2t, =), where ζ)t Q T
m are m-place predicates and = is equality.
lrΓhe work of M. Reynolds was supported by the U.K. Science and Engineering Research
Council under the MetateM project (GR/F/28526).


<!-- Page 2 -->

90 
D. GABBAY, I. HODKINSON, M. REYNOLDS
DEFINITION 1.1.
1. We define the temporal propositional language Z/[CΊ, . . . , Cn], with con-
nectives CΊ, . . . , Cn as follows:
(a) Any atom q is a wff.
(b) If A and B are wffs so are A Λ B, A V B, ~ A and A -» B.
(c) If Ct is noplace and Aλ, . . . , An. are wffs so is Ci(Al^ . . . , An.).
2. Let (T, <) be a flow of time. Let Π be a set ofm-place predicates. The
m-adic theory (T, <, Π, =) is defined as the language with (<, =, Qt €
Π) and wffs as follows:
(a) Q,(XI, . . . , £m),
 xi =
 xj
 and %i < Xj are wffs, for Xj variables and
αeΠ.
(b) Ifφ and φ are wffs so areφλψ, φVψ, ~φ, φ — > ψ, Vxφ and 3xφ.
3. The temporal language and the m-adic language can be connected in
the following manner.
(a) Enumerate the atomic propositions of L[C1? . . . , Cn] as ςfl5 g2>
and enumerate the m-adic predicates of Π as Qi,Qi,... and as-
sociate qi with Qt.
(b) Associate with the connective C(pι, . . . ,pn), where px, . . . ,pn are
propositional variables, a formula Φc(tiι 
. , tm, /\, . . . , Pn) with
m free variables ίl7 . . . , tm and n m-adic variables P1? . . . , Pn. ψc
is called a table for C.
(c) Any model (Γ, <, Π) of the m-adic language will now give rise to
an m-dimensional temporal model as follows. Let the assignment
h be
Extend ft to all wff by the equations:
h(A/\B] 
= 
h(A)Πh(B)
h(~A) 
= T
m-h(A)
h(C(Aϊy...,An)) 
= {(<,,... ,tm) I (Γ,<,Π)μ
for any connective C.
It is obvious from Definition 1.1 that any formula VK*ι> 
ιtmjQiι 
?Qn)
defines an n-place connective Cφ(ql^ . . . , qn) via the following truth table:
C^(ςfι,...,ί«) holds at ^,...,tm iff φ(tl9. . .,*m,Qι,. . . ,Qn) holds, where Qt =
{(^i, - - - , O I 9, holds at (sl7 . . . , sm)}.
In particular the connectives since (S) and unh7 (U) correspond to the
monadic tables:
<As(ί, Qι,Q3) = 3s


<!-- Page 3 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
91
and
>u>t-> Q2(u))).
Clearly we can use the connectives S(p,q) and U(p,q) to build arbitrary
wffs A(ql,...,qn). 
It is easy to see that for each A, there exists a formula
V>Λ(*>Qι> 
>Φn) °f tne monadic language such that for all t and 
ft,...,9n,
Λ(ft> 
> 0n) hol
ds at * iff Vu(*, <2ι» - - - > Q») holds, where Q, = {5 | ςr, holds at *}.
The family of all ψA can be defined inductively as follows:
DEFINITION 1.2. Let Wi({V>s,^ι/}) be tie smallest set of well formed formulas
of the monadic language with one free variable satisfying the following conditions:
1. Q4(t) € Wl for Qi atomic.
2. Ifφ, ψ € Wl so are φ Λ ψ, ~φ, φ V φ and φ — » ψ.
3. Φu.ΦseW^
4. If ψ(t, Qi, . . . , Qn) € WΊ with t the free variable and Qt the monadic
letters in ψ and if Φi(t) G Wly for i = 1, . . . , n then ψ(t, φ^ . . . , 0n) is
also in Wl9 where ψ(t, ^i, . . , Ψn) is obtained from ψ(t, Qι,..., Qn) by
substituting simultaneously λtψ^t) for λtQ^t), i = 1, . . . , n.
DEFINITION 1.3. In general given formulas V>ι(*ι, - - , *m)> - - , Ψk(tι> - 
? *m)
with m free variables the set Wm({^ . . . , φk}) can be defined in the m-adic lan-
guage as follows:
• Qi(tι, 
, tm) € Wm for Qi atomic.
• Ifφ,ψ€ Wm so are φ Λ ψ, ~φ, φ V ψ and φ —> ψ.
• If V>(*!, . . , *m, Qi, . , Qn) € VΓm witi <!,..., tm exactly tie free vari-
ables of V> and Qi exactly the m-adic predicates in ψ and if ^t*(*ι> 
> ^m)
Wm, for ί = 1, . . . , n tien
j's also in W^, wiere ^(^i, - . - , <m> ^ι> 
> 0n) is obtained from ψ(tl9 . . . , t
Qi, - - , Qn)
 b7 substituting simultaneously λt1? . . . , tmφi(t^ . . . , tm) for
DEFINITION 1.4.
J. Tie problem of expressive completeness for a set of m-adic 
wffs
over a class /C of flows of time is the question of whether Wm({φij . . . ,
is essentially the set of all m-adic wffs over 1C: namely whether for any
ψ there exists φ 6 Wm such that 1C \= φ *-* φ.


<!-- Page 4 -->

92 
D. GABBAY, I. HODKINSON, M. REYNOLDS
2. The problem of finite Gm-basis for the m-adίc language over a class 1C
of Hows (T, <) is whether the m-adic language can be represented as
equal to a Wm({φι,..., φk}} for some finite set [φλ,..., φk}.
3. The problem of expressive completeness of since and until over a class
1C is whether {ΨuiΨs} f°τm a finite G^basis for all monadic wffs over
the class 1C of models (T, <, Π).
The problem of finite basis is a general model theoretic one. Let 1C be a class
of models in some language, e.g. it might be the class Q of all groups.
Let (Q, Qi, <32? ...,=) be the m-adic theory of Q where Qt are new additional
m-ary relational variables. Let φλ,..., φk be m-adic formulas with m free variables.
We can still define Wm({φl,... ,φk}) and ask whether Wm essentially equals the
set of all m-adic wffs over Q. We can thus ask whether the theory of groups admits
a finite Gm-basis for its m-adic theory.
H. Kamp in [K] has shown that since and until form a finite Gα-basis for the
monadic theory of Dedekind complete linear orderings. J. Stavi put forward two
additional connectives which are shown in Theorem 3 to be a finite Gj-basis for
general linear time. A first complete proof of this result is given in this paper.
Schlingloff [S] has produced a finite Gx-basis for binary trees. The current paper
studies finite bases for linear orderings with manageable gaps.
The problem of the existence of a finite Gm-basis for a class of models 1C is
related to the notion of Gabbay's /^-dimension.
DEFINITION 1.5.
1. A theory T is said to have a finite Hm-dimension < n over a ciass of
models 1C iff every wff φ(tl,..., tm, QlJ..., Qk) with at most m free
variables t± and arbitrary number k of m-adic predicates is equivalent
over 1C to a wff φ(tl^..., tm, Q 1 ?..., Qk) where ψ uses no more than n
distinct bound variable letters.
2. The minimal n satisfying '(a) above is called the Hm-dimension ofT.
THEOREM 1 [GHR].
t A class 1C of models has a finite Hm-dimension if it has a finite Gm -basis.
• Let the class 1C have Hm-dimension n, then it has a finite Gm+n-basis.
• There is a class 1C of models with HI -dimension 3 but with no finite
G i-basis.
Another notion of interest is that of weak m/m'-dimensional logic where
1 < m' < m. This notion arises from m dimensional logic where the atoms
Qi(tι,...,tm) depend only on the first m' places. For example for m
7 = 1 the
weak (m/1) m-dimensional temporal logic has the Q{ unary. In this case the
existence of a finite Grbasis implies the existence of a finite Gm/1-basis for any m.


<!-- Page 5 -->

TEMPORAL EXPRESSIVE COMPLETENESS 
93
Of special interest for applications are one or two dimensional temporal logics
over a linear flow of time. In intuitive terms we are evaluating formulas at points or
at intervals (or pairs of points). The problem of finding an expressively complete
set of connectives is of special importance. Such connectives are extensively studied
in [GHR]. We quote one theorem here of relevance.
DEFINITION 1.6. Let 1C be a class of linear flows of time.
1. A formula A of a one-dimensional temporal logic is said to be pure
future (past) iff its truth value at a point of any (T, h) for any T € 1C
and any i, depends only on the value of the atoms at the future (past)
of that point.
2. A set of one-dimensional connectives is said to have the separation
property over 1C iff every formula A can be rewritten equivalently (over
K) as a boolean combination of pure past, atomic and pure future
formulas.
THEOREM 2. A set of one-dimensional connectives {CΊ,..., Ck} has the sep-
aration property over 1C iff it forms a Gl -basis over 1C.
Separation can be combinatorially checked by trying actually to rewrite any
formula into a separated boolean combination. In the case of linear ordering the
presence of gaps seems to be of combinatorial importance. As atoms are true or
false over stretches of time, the first or last point of truth is very useful. If no
such point exists we have a gap. We therefore need to study temporal behaviour
around gaps. The case of Dedekind complete flows is simple. Since and until form
a Gj-basis.
If the flow allows for gaps then a lot depends on the kind of gaps allowed.
It is clear that in the general case new connectives are needed. It is not hard to
show, and indeed our Lemma 3 below shows, that U and S are then not adequate
to express some first-order connectives. However, as mentioned in [GPSS], Stavi
was able to introduce two new connectives U
1 and S
f so that the set {{/, 5, {/', S'}
is expressively complete over all linear time. We present what we believe is the
first full published proof of this result in Section 8.
For the sake of completeness, we consider the question of whether there are
intermediate connectives appropriate for structures in which the gaps are in certain
senses nice. In this paper we classify the gaps appearing in linear orders and are
then able to introduce new connectives to talk about the behaviour of atoms in the
neighbourhood of such gaps. Natural questions arise about the expressive power
of sets of these connectives and we are able to present a fairly comprehensive
(although by no means complete) range of answers.
The authors would like to thank Tony Hunter, Rob Hubbard and Robin Hirsch
for many useful discussions during the development of this work.