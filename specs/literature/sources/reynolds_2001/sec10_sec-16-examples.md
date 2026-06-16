## §16. Examples.

1. The following validity is one that can be used as an axiom to capture limit 
closure in the CTL language: 
AG(p ->EXp) 
-> (p ->EGp). 
To derive it in our system use the LC axiom 
A G(E p - 
E X( (Efalse) U(E p))) -> (E p - 
E G((Efalse) 
U(E p))) 
after showing F p ↔ E p and F p ↔ ((Efalse) U((E p)). 
2. This example comes from [Stirling, 1992]: 
F- AG(Aa 
-> EXFA 
a) 
> (A a - 
EGFA a). 
To derive it, simply apply the LC axiom 
A G(E A a 
> E X((E true) U(E A a))) 
>(E A a -> E G((E true) U(E A a))) 
after showing F E A a ↔ A a. 
3. We prove the following using both AA and LC: 
k (A G(p - E X r) A A G(r - E X p)) - (p - E G(F p A F r)). 
If every p place has an r successor and every r place has a p successor then there 
is a fullpath on which both p and r hold infinitely often. The idea behind the proof 
we present involves the setting up of an automaton with three states b, c and e. We 
establish the existence of a path on which it alternates between state b at a place 
where p holds and state c at a place where r holds. The state e will indicate that we 
have gone astray. 
To use the AA rule we define L 
{p, r} and Q = {b, c, e}. The specified set of 
formulas using atoms only from L contains al 
-=p A -r, a2= 
¬p Ar, Y3= p A -ir 
and a4 
p A r. The function p : (Q x { 1, 2, 3, 4}) 
Q (capturing the transition 
table of the automaton) is given by: 
p 
11 2 13 l4 
b 
e e 
c e 
c 
e be 
b 
e 
e 
e 
e 
e

The functionally L + Q-expandable formula 0 is b A 01 A 02 where 
01 =AGAA(q 
A ai -* A Xp(q, i)) 
Q i 
and 
02=AGA- 
(qAq'). 
q~lq' 
Let y = A G(p -* EXr) 
A A G(r -* EXp) 
and o = y A --e A 01 A (p V r). 
In the full derivation there are long stretches of reasoning within ⊢_B (bundled 
derivability) including PLTL reasoning. This can be quite subtle (eg., using the 
induction C6) but we will omit such steps. For our purposes, we just concentrate 
on the couple of steps where LC and AA are used. 
We have ⊢_B E a -* E X E a from which more bundled reasoning gives us 
⊢_B A G(E a -* E X((Efalse) U(E a))). 
The LC axiom (and modus ponens) allows us to conclude 
F E a - E G((Efalse) U(E a))). 
from which we easily derive F- E a -* E G E a. 
As ⊢_B (y A 0 A p) -* Ea and ⊢_B Fa -* --e we conclude that 
(1) 
F- y A A p -* EG -e 
i.e. under the given assumptions, there is a fullpath on which the automaton never 
visits e. 
It is interesting to note here that, although the acceptance criteria of the automa- 
ton do not play a part in the AA rule, we are bringing them in here: the automaton 
playing its role in guiding our intuitions in this derivation, accepts exactly paths 
which never visit e. In this derivation we are looking for a path which is accepted 
by the automaton. 
Some PLTL reasoning (guided by intuitions about the transition function) gives 
us 
⊢_B (G -e A0) - (G(p -Xr) A G(r - Xp)) 
and 
⊢_B (pA G(p -* Xr) A G(r -Xp)) 
-* G(Fp A Fr). 
Bringing (1) in as well gives us 
F- 0 -* (y A p - E G(F p A F r)) 
and so the AA rule gives us 
Fy A p - EG(Fp 
AFr) 
as required. 
Note that it is very hard to see how this could be derived without the AA rule. 
Using LC we could certainly derive that from y A p it follows that there is a fullpath 
on which p holds infinitely often and on which either p or r holds at each state. 
However, to deduce that both p and r hold infinitely often seems beyond the 
capabilities of LC. In order to do away with AA one may propose other forms

of limit closure axioms which can cope with two events being required to recur. 
However, an infinite set of axioms will probably be needed to cope with any number 
n of such recurring events. 
4. Here is another example using both the AA and LC rules: 
let y = A G(p -* EX((-iq) U(¬q A X p))) A A G(p -* EX(q U(q A X p))); 
let s = GF(¬q A X p) A GF(q A X p)) A G(((--q) U p) V (q U p))); 
and we will show F- y - 
(p - 
Es ). 
Use al = -p A -q, a2 = -p A q, a3 = p A -q and a(4 
p A q along with 
Q= {bo,..., bio} p given by: 
I_ 
4-p A-q 
-p A q p A-q 
p A q 
bo 
b3 
b4 
b2 
bi 
b1 
b3 
b4 
b5 
b5 
b2 
b3 
b4 
b2 
b 
b3 
b3 
blo 
b2 
b 
b4 
b4 
b5 
b5 
b5 
b8 
b6 
b7 
b6 
b8 
bo 
bo 
b7 
b8 
b6 
b7 
b8 
b8 
b6 
b7 
b9 
blo 
bo 
bo 
blo 
blo 
blo 
blo 
and the corresponding expandable formula 0 = bo A 01 A 02 analogous to that in 
the last example. 
The automaton which guides our intuition is defined by the transition table above 
with acceptance determined by bo coming up infinitely often. The reader can check 
that any path accepted by this automaton is a model of 6. To see this note that the 
initial state bo is only reached again after b5 has been visited and ¬q immediately 
followed by p holds (i.e. ¬q A X p has been true). The state b5 will only be reached 
after bo when q A X p has just held. The states b1 - b4 record the progress between 
bo and b5: for example, b1 indicates that p A q has just been seen while b4 is 
encountered during a sequence of q A -p states. The states b6 - bg are for similar 
purposes in recording the progress between b5 and bo. If ((¬q) Up) V (q Up) is 
ever violated then the automaton ends up in the sink state b1o (and so does not 
accept the structure). 
Define a = y A bo A 01 A 02. We can show that when a holds then it holds 
again at some later state: ⊢_B A G(Ea 
-* EX((E true) U(Ea)). 
The LC axiom 
allows us to deduce that then there is a fullpath on which a holds infinitely often: 
E a -> EG((Etrue) 
U(E a)). 
Now EXEaa holds at the root: ⊢_B y A p A 0 -* EXEa. 
Any path of recurring 
E a is accepted by the automaton and so satisfies 6: ⊢_B G((E true) U(E a)) -* 
. 
Putting these together we deduce that there is a fullpath satisfying 6: K 0 -* (y - 
(p -* E)). 
The AA rule finishes the derivation.

Again, this example would be a good test of any alternative axiom systems. It 
is not good enough here just to establish that there is a fullpath on which either 
E(q U(q A X p)) or E((-q) U(-q A X p)) holds at every state and that both these 
formulas hold infinitely often. Instead, it is required that either q U(q A X p) or 
(¬q) U(¬q A Xp) holds along the chosen fullpath at every state (and each holds 
infinitely often). 

## §17. Conclusion. We have been able to give a simple axiomatization of validity

in standard CTL*. 
Interesting aspects of the system include a very intuitive limit closure axiom and 
a slightly complicated, but possibly more generally useful, rule for the systematic 
introduction of fresh atoms into a proof. 
Interesting aspects of the completeness proof include the use of a linear Rabin au- 
tomaton and the use of a new banning mechanism working alongside a strict variant 
of the usual scheduling mechanism in the vaguely filtration-based construction. 
The result and proof suggest several avenues for future work. The most important 
question regarding this axiomatization is whether the auxiliary atoms rule is really 
needed. Even if the rule is not needed, and especially if it is, there is the possibility 
of using it to good effect in other similar logics such as other branching time 
logics, including those from philosophical logic, or in more general areas of modal 
and temporal logic reasoning. Interesting examples are the CTL* logic with past 
operators from [Zanardo and Carmo, 1993] as well as the long-unaxiomatized logic 
of historical necessity. 

## References

- **[Bernholtz and Grumberg, 1994]** 0. BERNHOLTZ and 0. GRUMBERG, Buy one, get onefree!!!, Temporal
logic, Proceedings of ICTL'94 (D. Gabbay and H. Ohlbach, editors), LNAI, no. 827, Springer-Verlag, 
1994, pp. 210-224. 
- **[Burgess, 1980]** J. P. BURGESS, Decidabilityfor branching time, Studia Logica, vol. 39 (1980), pp. 203-
218. 
- **[Clarke and Emerson, 1981]** E. CLARKE and E. EMERSON, Synthesis of synchronization skeletons for
branching time temporal logic, Proc. IBM Workshop on Logic of Programs, Yorktown Heights, NY 
(Berlin), Springer, 1981, pp. 52-71. 
- **[Dam, 1992]** M. DAM, R-generability, and definability in branching time logics, Information Processing
Letters, vol. 41 (1992), pp. 281-287. 
- **[Emerson, 1983]** E. EMERSON, Alternative semantics for temporal logics, Theoretical Computer Sci-
ence, vol. 26 (1983). 
- **[Emerson, 1996]** 
, Automated temporal reasoning for reactive systems, Logicsfor concurrency 
(F. Moller and G. Birtwistle, editors), Springer Verlag, 1996, pp. 41-101. 
- **[Emerson and Halpern, 1982]** E. EMERSON and J. HALPERN, Decision procedures and expressiveness
in the temporal logic of branching time, Proc. 14th ACM Symp. on Theory of Computing, 1982. 
- **[Emerson and Halpern, 1986]** 
, 'Sometimes' and 'not never' revisited: on branching versus 
linear time, Journal of the ACM, vol. 33 (1986). 
- **[Emerson and Jutla, 1988]** E. EMERSON and C. JUTLA, Complexity of tree automata and modal logics
of programs, 29th IEEE Foundations of Computer Science, Proceedings, IEEE, 1988. 
- **[Emerson and Sistla, 1984]** E. EMERSON and A. SISTLA, Decidingfull branching time logic, Information
and Control, vol. 61 (1984), pp. 175-201. 
- **[Emerson, 1990]** E. A. EMERSON, Temporal and modal logic, Handbook of theoretical computer science
(J. van Leeuwen, editor), vol. B, Elsevier, Amsterdam, 1990.

- **[Gabbay, Hodkinson, and Reynolds, 1994]** D. GABBAY, I. HODKINSON, and M. REYNOLDS, Temporal
logic: Mathematicalfoundations and computational aspects, vol. 1, Oxford University Press, 1994. 
- **[Gabbay, 1981]** D. M. GABBAY, An irreflexivity lemma with applications to axiomatizations of con-
ditions on tense frames, Aspects of philosophical logic (U. Monnich, editor), Reidel, Dordrecht, 1981, 
pp. 67-89. 
- **[Gabbay, Pnueli, Shelah, and Stavi, 1980]** D. M. GABBAY, A. PNUELI, S. SHELAH, and J. STAVI, On the
temporal analysis offairness, 7th A CM Symposium on Principles of Programming Languages, Las Vegas, 
1980, pp. 163-173. 
- **[Kaivola, 1996]** R. KAIvoLA, Axiomatising extended computation tree logic, in trees in algebra a
programming, CAAP'96, 21st International Colloquium, Proceedings, vol. 1059, Springer, 1996, pp. 87- 
101. 
- **[Kesten and Pnueli, 1995]** YONIT KESTEN and AMIR PNUELI, A complete proof systems for QPTL,
Proceedings, Tenth Annual IEEE Symposium on Logic in Computer Science (San Diego, California), 
IEEE Computer Society Press, 26-29 June 1995, pp. 2-12. 
- **[McNaughton, 1966]** R. MCNAUGHTON,
Testing and generating infinite sequences byfinite automata, 
Information and Control, vol. 9 (1966), pp. 521-530. 
- **[Pnueli, 1977]** A. PNUELI, The temporal logic of programs, Proceedings of the Eighteenth Symposium
on Foundations of Computer Science (Providence, RI), 1977, pp. 46-57. 
- **[Safra, 1988]** S. SAFRA, On the complexity of ω-automata, Proceedings of 29th IEEE Symposium on
the Foundations of Computer Science, 1988. 
- **[Stirling, 1992]** C. STIRLING, Modal and temporal logics, Handbook of Logic in Computer Science,
- **[Thomason, 1984]** R. THOMASON, Combinations of tense and modality, Handbook of philosophical
logic, Vol 11: Extensions of classical logic (D. Gabbay and F. Guenthner, editors), Reidel, Dordrecht, 
1984, pp. 135-165. 
- **[Vardi and Stockmeyer, 1985]** M. VARDI and L. STOCKMEYER, Improved upper and lower bounds for
modal logics of programs, 17th ACMSymp. on Theory of Computing, Proceedings, ACM, 1985, pp. 240- 
251. 
- **[Walukiewicz, 1995]** I. WALUKIEWICZ, A complete deductive system for the μ-calculus, BRICS Re-
search Report RS-95-6, Department of Computer Science, University of Aarhus, Denmark, 1995. 
- **[Zanardo, 1985]** A. ZANARDO, A finite axiomatization of the set of strongly valid Ockamist formulas,
Journal of Philosophical Logic, vol. 14 (1985), pp. 447-468. 
- **[Zanardo, 1996]** 
, Branching-time logic with quantification over branches: the point of view of 
modal logic, this JOURNAL, vol. 61 (1996), pp. 1-39. 
- **[Zanardo, Barcellan, and Reynolds, 1999]** A. ZANARDO, B. BARCELLAN, and M. REYNOLDS, Non-
definability of the class of complete bundled trees, Logic Journal of the IGPL, vol. 7 (1999), no. 1, 
pp. 125-136. 
- **[Zanardo and Carmo, 1993]** ALBERTO ZANARDO and Jost CARMO, Ockhamist computational logic.
Past-sensitive necessitation in CTL, Journal of Logic and Computation, vol. 3 (1993), no. 3, pp. 249-268. 
SCHOOL OF INFORMATION 
TECHNOLOGY 
MURDOCH 
UNIVERSITY 
SOUTH STREET 
PERTH, WESTERN 
AUSTRALIA 
6150 
E-mail: m.reynoldsgmurdoch.edu.au