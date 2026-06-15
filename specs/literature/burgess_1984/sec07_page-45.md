## Page 45

1L2: BASIC TENSE LOGIC 123

the cases @ = GB or = Hp being nontrivial. In, for instance, the latter case,
we use the fact that any truth-function can be put into disjunctive normal
form, plus the following valid equivalence:

®)  w(prg)an) > ((JpaH(g vr) v(~Jp A Hr))

Details are left to the reader. Our second step is to observe that if B is
reduced, then it is equivalent to the result §~ of dropping all its occurrences
of J. It thus suffices to set a* = (ag)". m)

The foregoing theorem says that in the presence only of truth-functions
and G and H, the operator J is, in a sense, redundant. By contrast, examples
(0)~(3) suggest that in contexts with propositional attitudes, J is not redun-
dant; the lack of a generally-accepted formalization of the logic of propo-
sitional attitudes makes it impossible to turn this suggestion into a rigorous
theorem. But in contexts with quantifiers, Kamp does prove rigorously that J
is irredundant. Consider:

(€] The Academy of Arts rejected an applicant who was to become a
terrible dictator and start a great war.

® The Academy of Arts has rejected an applicant who is to become
a terrible dictator and start a great war.

The following formalizations suggest themselves:

@) P(3x(R(x) A FD(x))
(5)  P3Ax(R(x) A JFD(x)),

the difference between (4) and (5) lying precisely in the fact that the latter,
unlike the former, definitely places the dictatorship and war in the hearer’s
future. What Kamp proves is that (5') cannot be expressed by a G, H-formula
with quantifiers.

Returning to sentential tense logic, Theorem 4.11 obviously reduces the
decision problem for G, H, J-tense logic to that for G, H-tense logic. As for
axiomatizability, obviously we cannot adopt the standard format of G, H-
tense logic, since the rule TG does not preserve validity for G, H, J-formulas.
For instance:

D0) p—Jp

is valid, but G(p <— Jp) and H(p «— Jp) are not. Kamp overcomes this dif-
ficulty, and shows how, in very general contexts, to obtain from a com-
plete axiomatization of a logic without J, a complete axiomatization of the

## Page 46

124 JOHN P. BURGESS

same logic with J. For the sentential G, H, J-tense logic of total orders, the
axiomatization takes a particularly simple form: Take as sole rule MP. Let Lp
abbreviate Hp Ap A Gp. Take as axioms all substitution instances of tautol-
ogies, of (DO) above, and of La, where a may be any item on the lists (D1),
(D2) below, or the mirror image of such an item:

(1)  G(p~>q)~>(Gp~Gq)
p~>GPp
Gp < GGp
Lp < GHp

D2) Jpe—-ip
Jpng)<—Jpalq
~L~Jp < Lip
Lp~Jp.

(In outline, the proof of completeness runs thus: Using D1 one deduces
Lp - LLp. 1t follows that the class of theses deducible without use of DO is
closed under TG. Our work in Section 2.2 shows that we then get the com-
plete G, H-tense logic of total orders. We then use (D2) to prove the equiv-
alence (R) in the proof of Theorem 4.11 above. More generally, for any a,
a<>ap is deducible without using (DO). Moreover, using DO, p <~ is
deducible for any reduced formula . Thus in general o <— a* is a thesis,
completing the proof.)

5. TIME PERIODS

The geometry of Space can be axiomatized taking unextended points as basic
entities, but it can equally well be axiomatized by taking as basic certain
regular open solid regions such as spheres. Likewise, the order of Time can be
described either (as in Section 0.1) in terms of instants or in terms of periods
of nonzero duration. Recently it has become fashionable to try to redo tense
logic, taking periods rather than instants as basic. Humberstone [1979] seems
to be the first to have come out in print with such a proposal. This approach
has become so popular that we must give at least a brief account of it; further
discussion can be found in Van Benthem [1983]. (Cf. also Kuhn’s discussion
in Volume IV of the Handbook.)

In part, the switch from instants to periods is motivated by a desire to
model certain features of natural language. One of these is aspect, the verbal
feature which indicates whether we are thinking of an occurrence as an event
whose temporal stages (if any) do not concern us, or as a protracted process,