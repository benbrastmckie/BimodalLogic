### 4.3. Decidability Via Mosaics

Another interesting application of the mosaic technique, which we pursue here,
is in proving the decidability of a given logic and in obtaining an asymptotic
upper-bound on its decision problem. We will show how mosaics can be used
in order to prove decidability of the logics considered in the paper in the par-
ticular case of basic structures. The proof follows the idea of the decidability
proofs in [14] and [19].

**Theorem 4.11.** The problem of checking satisfiability of formulas in the logic
L(C, ()), for C a class of linear orders, is decidable.

*Proof.* Let A be a satisfiable formula. By following the same construction as
in the proof of left-to-right direction of Theorem 3.15 (just consider the finite
set Γ as consisting only of A), we can show that there exists a C-()-structure
of mosaics for A on the smallest C-()-closed set Λ of formulas containing A.

Since Λ is finite, the number of possible mosaics, and thus of structures
of mosaics, on it is also finite. Given that checking coherence and saturation
conditions is decidable, we can take each pair of sets of mosaics in turn and
check whether it is a C-()-structure of mosaics for A.
$\square$

We can obtain an asymptotic upper bound by observing that the cardi-
nality of the set Λ, as defined in the proof of Theorem 4.11, is O(n), where n
is the complexity of A. It follows that the number of possible mosaics on that
set is O(2n) and the number of structures of mosaics is O(22n). Coherence and
saturation conditions can be checked in polynomial time.
It is easy to see that the argument in the proof of Theorem 4.11 does not
extend to the logics L(C, D) for D ̸= (). Namely, when there is some interaction
between the vertical and the horizontal components, the simple translation of
a model into sets of mosaics described in the proof above produces a structure
that does not necessarily satisfy all the saturation conditions required. This is
of course also related to the results of Sect. 4.2, where an analytic version of
the tableau system has been proven to be sound and complete only in the case
of the target branching class being the basic one. The possibility of cutting
with respect to the full language F is necessary there in order to get tableaux
completeness for logics L(C, D) where D ̸= (); analogously, considering mosaics
defined on Λ = F would allow the construction of the proof of Theorem 4.11
to provide a structure of mosaics satisfying all the saturation conditions (but
then the result of decidability would not follow since the number of possible
mosaics on F is infinite).
In order to get a proof of decidability based on mosaics also for the other
classes of logics8, it might be useful to consider a more complex, and branch-
ing-oriented, notion of mosaic (more on this in Sect. 5).
The proof of decidability given here seems extremely appealing because
of its simplicity. We observe that it should also be possible to define a deci-
sion procedure for the C-()-logics based on the tableau system of Sect. 4.2, by
exploiting analyticity of the cut rule in that case and properly avoiding the
repeated curing of the same defect.

## 5. Conclusions

We have proposed an extension of the mosaic method from a class of linear
temporal logics to a two-dimensional logic obtained by adding an “orthogonal”
S5-like component, and we have treated several applications of the method.
Namely we have shown how the mosaic techniques can be used to prove com-
pleteness for the corresponding Hilbert-style axiomatization, to define a sound
and complete tableau system and to obtain a decision procedure for the logic
considered as well as to establish an asymptotic upper-bound on its complexity.
8 We recall that decidability of the logic L((), (Wdc + Sdc + Mb−)) is proved in [1], using
Rabin’s Theorem [18], which states the decidability of the monadic second order theory of
infinite binary trees. In [7], such a proof is adapted to the case with atomic harmony.

In [14] the mosaic method has been proposed for the general linear-time
logics together with some variants capturing particular (i.e., dense, discrete,
bounded/unbounded) linear flows of time. The approach presented here can be
seen as a conservative extension of that method, in the sense that our presen-
tation is modularized with respect to a vertical (linear-time) and a horizontal
(S5-like) component, in such a way that the first one consists of definitions
and proofs just imported from [14].
We have also considered the possibility of having interactions between
the two components, in order to treat logics that capture the idea of branch-
ing-time. To that aim, our treatment has been parameterized along both the
two components: with respect to the class of linear orders considered, ranging
from the general to more specific ones (i.e., dense, discrete, etc.), and with
respect to the class of branching structures, according to a hierarchy leading
from the basic ones, where the two orthogonal components are independent,
to “more branching” ones, like the Ockhamist structures of, e.g., [29].
Namely, by letting C range over classes of linear orders and D over sets of
branching properties, we have considered a broad class of Ockhamist branch-
ing-time logics L(C, D) and defined for them, by means of a fully modular
presentation, an extension of the mosaic method. Indeed, this two-dimensional
view allows for dealing, in a clear way, with the logics defined over Ockhamist
structures where all the vertical components are in the same class of linear
orders, or, which is equivalent, to the class of bundled trees such that all the
paths are in the same class of linear orders. However while, as long as the
vertical and the horizontal component behave independently, all the results
in [14] (proof of Hilbert-style completeness, definition of a complete tableau
system and proof of decidability) can be proved to propagate, in the case when
interactions between the two components are considered we have some restric-
tions: a tableau system can only be defined by allowing a non-analytic version
of the cut rule and thus the proof of decidability does not apply.
We believe that our approach, presented here with a focus on temporal
logics, can be seen as more generally suitable for dealing with many-dimen-
sional modal logics without interactions between the dimensions [9]. In such
a context, mosaics can be seen as an alternative to other techniques typically
used in order to get (the transfer of) decidability or completeness results, such
as fibring [8].
Further work is required in order to capture properly, i.e., in a way that
allows for proving decidability, also logics where interactions are considered,
such as the branching-time logics seen in this paper or several logics of knowl-
edge and time [5,11] which present similar interaction frame properties. Our
future research will consider the possibility of having a more complex notion of
mosaic, in some way taking into account, already in the definition of the basic
components of our structures, the possible interactions between the dimensions
(i.e., in the case of temporal logics, their branching nature). As an example,
we recall the treatment in [19], where the decidability of a logic defined over
rectangular frames consisting of the cross product of a (vertical) linear order
and a (horizontal) set of worlds, is proved by using mosaics that are pairs of

horizontal segments of points. We are aware that, as a trade-off, an approach of
this kind would probably compromise (at least part of) the desirable modular-
ity properties, with respect to the linear treatment of [14], that the presentation
proposed here enjoys.

## Acknowledgements

The authors are grateful to Andrea Masini and Alberto Zanardo for several
fruitful discussions on the subject of this paper, and to the anonymous referee
for valuable remarks on an earlier version of this paper.

## References

[1] Burgess, J.P.: Logic and time. J. Symb. Log. 44(4), 566–582 (1979)
[2] Burgess, J.P.: Decidability for branching time. Stud. Log. 39, 203–218 (1980)
[3] Burgess, J.P.: Axioms for tense logic. I. “Since” and “until”. Notre Dame J.
Form. Log. 23(4), 367–374 (1982)
[4] Di Maio, M.C., Zanardo, A.: Synchronized Histories in Prior-Thomason Repre-
sentation of Branching Time. In: Gabbay, D.M., Ohlbach, H.J. (eds.) ICTL ’94,
LNCS, vol. 827, pp. 265–282. Springer, Berlin, Heidelberg (1994)
[5] Fagin, R., Halpern, J., Moses, Y., Vardi, M.: Reasoning About Knowledge. The
MIT Press, Cambridge-Massachusetts, London-England (1995)
[6] Gabbay, D.M.: An irreflexivity lemma with applications to axiomatizations of
conditions on tense frames. In: M¨onnich, U. (ed.) Aspects of philosophical logic
(T¨ubingen, 1977), vol. 147, pp 67–89. Synthese Library, Reidel, Dordrecht (1981)
[7] Gabbay, D.M., Hodkinson, I., Reynolds, M.: Temporal Logic: Mathematical
Foundations and Computational Aspects, vol. 1. Oxford University Press-
Clarendon Press, Oxford (1994)
[8] Gabbay, D.M., Shehtman, V.B.: Products of Modal Logics, Part 1. Log. J. IGPL
6(1), 73–146 (1998)
[9] Gabbay, D.M., Kurucz, A., Wolter, F., Zakharyaschev, M.: Many-Dimensional
Modal Logics: Theory and Applications. Studies in Logic, vol. 148. Elsevier Sci-
ence (2003)
[10] Goranko, V., Zanardo, A.: From linear to Branching-time temporal logics: trans-
fer of semantics and definability. Log. J. IGPL 15(1), 53–76 (2007)
[11] Halpern, J.Y., Van der Meyden, R., Vardi, M.Y.: Complete axiomatizations for
reasoning about knowledge and time. SIAM J. Comput. 33(3), 674–703 (2004)
[12] Hirsch, R., Hodkinson, I., Marx, M., Mikul´as, S., Reynolds, M.: Mosaics and
step-by-step. Remarks on “A modal logic of relations”. In: Logic at Work. Essays
Dedicated to the Memory of Helena Rasiowa, pp. 158–167. Springer, Berlin,
Heidelberg (1999)
[13] Kurucz, A.: Combining modal logics. In: van Benthem, J., Blackburn, P., Wolter,
F. (eds.) Handbook of Modal Logic, pp. 869–924. Elsevier, Amsterdam (2007)
[14] Marx, M., Mikul´as, S., Reynolds, M.: The mosaic method for temporal logics.
In: Dyckhoff, R. (ed.) TABLEAUX, LNCS, vol. 1847, pp. 324–340. Springer,
Berlin, Heidelberg (2000)

[15] Mikul´as, S.: Taming first-order logic. J. IGPL 6(2), 305–316 (1998)
[16] N´emeti, I.: Free Algebras and Decidability in Algebraic Logic. PhD Thesis, Hun-
garian Academy of Sciences, Budapest (1986)
[17] N´emeti, I.: Decidable versions of first order logic and cylindric-relativized set
algebras. In: Logic Colloquium ’92, pp. 171–241. CSLI Publications, Stanford
(1995)
[18] Rabin, M.O.: Decidability of second-order theories and automata on infinite
trees. Trans. Am. Math. Soc. 141, 1–35 (1969)
[19] Reynolds, M.: A decidable temporal logic of parallelism. Notre Dame J. Form.
Log. 38, 419–436 (1996)
[20] Reynolds, M.: Axioms for branching time. J. Log. Comput. 12(4), 679–697 (2002)
[21] Reynolds, M.: The complexity of the temporal logic with “until” over general
linear time. J. Comput. Syst. Sci. 66(2), 393–426 (2003)
[22] Reynolds, M.: Dense time reasoning via mosaics. In: TIME ’09, pp. 3–10. IEEE
Computer Society, Los Alamitos, CA, USA (2009)
[23] Reynolds, M.: The complexity of decision problems for linear temporal logics. J.
Stud. Log. 3(1), 19–50 (2010)
[24] Reynolds, M.: The complexity of temporal logic over the reals. Ann. Pure Appl.
Log. 161, 1063–1096 (2010)
[25] Thomason, R.H.: Combinations of tense and modality. In: Handbook of Philo-
sophical Logic: Extensions of Classical Logic, pp. 135–165. Reidel, Dordrecht
(1984)
[26] Van Dalen, D.: Logic and Structure. Springer, Berlin, Heidelberg (1994)
[27] Venema, Y., Marx, M.: A modal logic of relations. In: Logic at Work: Essays
Dedicated to the Memory of Helena Rasiowa. Physica-Verlag, Heidelberg, New
York (1999)
[28] Zanardo, A.: A finite axiomatization of the set of strongly valid Ockhamist for-
mulas. J. Philos. Log. 14, 447–468 (1985)
[29] Zanardo, A.: Branching-time logic with quantification over branches: the point
of view of modal logic. J. Symb. Log. 61(1), 1–39 (1996)
Carlos Caleiro and Marco Volpe
Departamento de Matem´atica, Instituto Superior T´ecnico
SQIG, Instituto de Telecomunica¸c˜oes
Universidade T´ecnica de Lisboa
Lisbon, Portugal
e-mail: ccal@math.ist.utl.pt;
mvolpe@math.ist.utl.pt
Luca Vigan`o
Dipartimento di Informatica
Universit`a di Verona
Verona, Italy
e-mail: luca.vigano@univr.it
Received: August 1, 2011.
Accepted: October 20, 2012.
