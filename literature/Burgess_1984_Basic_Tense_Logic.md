## Page 1

IL1: BASIC MODAL LOGIC 79

the results above, and gave a complicated example of frames which verify M
but have an ultraproduct which does not. It follows that the class of frames
verifying M is not (first-order) axiomatic, although Fine [1975] shows that
KM is characterized by the class of frames verifying it. (Therefore this class
of frames is characterised by some formula of second-order predicate logic,
as in the last part of Section 19.) This result was also proved independently
in Van Benthem [1975], by a direct method. Van Benthem [1976] proved
more of the results above, the published version using Goldblatt’ ultra-
products. The picture was completed in Goldblatt [1976], where there
is also a more detailed explanation of the ultraproduct of frames which
verify M.

24. TWO FURTHER RESULTS

We have found closure conditions for a modal axiomatic class of frames,
provided that it is closed under elementary equivalence and, hence, includes
enough saturated frames. Can closure conditions for axiomatic classes of
frames still be found when this condition is dropped? A rather complicated
answer is provided in Goldblatt and Thomason [1975] (originally part of
Thomason [1975]). Given a frame (W, R), choosing a general frame (W, R, P}
represents a choice of which ‘propositions’ are to be considered. In then
forming (U, S)= ({W, R, P)*)4, the members of U are the ultrafilters on P,
representing ‘states-of-affairs’, i.e., maximal consistent sets of ‘propositions’.
The natural definition of S on these ‘states-of-affairs’ is, as usual,

uSv iff (VXEP)(XEv>mgXEu).

Under what conditions will (U, S)again verify the formulas verified by (W, R)?
Firstly, there must be no ‘new propositions’ in (U, S), i.e.,

(VY S U) @YX EP) (Y = ¢(X)),
where ¢(X) = {u EU: X Eu},or
(VYSU)(3XEP)UEY>XEu).

Secondly, to carry out the necessary induction step on the value of 04, we
must have

(VuEUV)(VXEP)(mpX Eu~>(FvEu) uSva XE)).

If (U, §) satisfies these conditions for the carrier P of some subalgebra of
(W, R)*, then we say that (U, S) is SA-based on (W, R).

## Page 2

80 ROBERTBULL AND KRISTER SEGERBERG

It can be shown, by a fairly difficult proof, that (U, S) is frame-isomorphic
to a frame SA-based on (W, R) iff (U, $)* is a homomorphic image of a sub-
algebra of (W, R)*. Now a class of frames is modal axiomatic iff it is closed
under frame isomorphism, nontrivial disjoint unions, and the construction of
(U, §) SA-based on (W, R). It is easy to show that a modal axiomatic class is
closed under these conditions. For the converse, suppose that a class X of
frames is closed under these conditions. As in the theorem in Section 23 on
the closure conditions for the class of frames verifying a d-persistent set of
formulas, we take

Xt ={§": §ex),
P={4:§ EArF E€X),

and show that X is the class of frames verifying I'. Again §* verifies I iff it
is a homomorphic image of a subalgebra of a direct product of modal algebras
{7:1€1} in X*, where the direct product is isomorphic to (Z;e; &;)"* for
Zier F€X. By the lemma stated above § must be SA-based on Z;e; i,
and so FEX. Thus if § = I then §FE X, and the converse is clear.

We are familiar with the duality between modal algebras and descriptive
frames, and with the fact that we must shift from frames to descriptive
frames before a duality can be established. Can we, as an alternative, shift to
some other kind of algebra and then establish a duality with frames proper?
This is done in Thomason [1975]. The appropriate algebras are the complete
atomic modal algebras, i.e. modal algebras based on complete atomic Boolean
algebras with

IN{b;:i €1} = N{lb;: i €T,
mUh;:i €1} = Upmby: i €1},

An atom of a Boolean algebra® = (B, 0, 1, -, N, U is an element a € B with
a<bvanb=0, foreachb€B.

Then B is atomic iff
Vb3a (aanatomaa <b),

and is complete iff it is closed under the operations N and U for arbitrary
subsets {b;:i € I} of B. In a complete atomic Boolean algebra, each element
b is determined by the set of atoms  with @ < b. The appropriate morphisms
for the category of complete atomic modal algebras are the complete homo-
morphisms, i.e., the homomorphisms ¢ with

## Page 3

IL1: BASIC MODAL LOGIC 81

(U = Ulp(s) i€ ).

This category is dual to the category of frames and frame morphisms. As far
as the structures go, for each frame & the usual modal algebra §* on B (W) is
complete and atomic. For each complete atomic modal algebra % with set of
atoms At(%), we take the frame %, = (At(¥), R) with

xRy iff x<my, foreachx,y€ At(¥).

For the morphisms, given frames § =(W,R), § =(W',R') and a frame
morphism ¥: § > §, define y*: F'* > F* by taking

V'(S) =y [S], for each S EP(W")

as before. In the other direction a new definition is needed. Given complete
atomic modal algebras U, B and a complete homomorphism ¢: A =B,
define ¢,: B, ~> A, by taking

¢.(v) =x iff y<¢(x), foreachx € At(A),y € A(B).

To see that this definition is valid, note that {$(x) :x € At(¥)} is a disjoint
cover of B, since At(%¥) is a disjoint cover of 4 and ¢ is a complete homo-
morphism. It can be checked that each frame § is ‘isomorphic’ to (§*)., and
that each complete atomic modal algebra ¥ is isomorphic to (%,)", so that
these categories are contravariantly dual to each other.

University of Canterbury, New Zealand
University of Auckland, New Zealand

REFERENCES

Ackerman, W.: 1956, ‘Begrindung einer strengen Implikation’, J. Symbolic Logic 21,
113-128.

Alban, M. J.: 1943, ‘Independence of the primitive symbols of Lewis’ calculi of prop-
ositions’, J. Symbolic Logic 8, 24-26.

Anderson, A. R. and Belnap, N. D.: 1975, Entailment: The Logic of Relevance and
Necessity, Vol. 1, Princeton University Press, Princeton.

Anderson, C. A.: 1980, ‘Some axioms for the logic of sense and denotation: Alternative
(0", Noiis 14,217-234.

Bayart, A.: 1959, ‘Quasi-adéquation de la logique modale du second ordre S5 et adéquation
de la logique du premier ordre §5, Logique et analyse 2,99-121.

Becker, O.: 1930, ‘Zur Logik der Modalititen’, Jahrbuch fiir Philosophie und phinom-
enologische Forschung 11, 496-548.

## Page 4

82 ROBERT BULL AND KRISTER SEGERBERG

Belnap, N. D.: 1981, ‘Modal and relevance logics: 1977, in E. Agazzi (ed.), Modern
Logic - A Survey, Reidel, Dordrecht, pp. 131-151.

Beth, E. W.: 1959, The Foundations of Mathematics: A Study in the Philosophy of
Science, North-Holland, Amsterdam.

Blok, W. 1.: 1980, The lattice of modal algebras: An algebraic investigation’, J. Symbolic
Logic 45, 221-236.

Blok, W. J.: 1980a, ‘Pretabular varieties of modal algebras’, Studia Logica 39, 101-124.

Boolos, G.: 1979, The Unprovability of Consistency: An Essay in Modal Logic, Cambridge
University Press, Cambridge.

Bowen, K. A.: 1978, Model Theory for Modal Logic, Reidel, Dordrecht.

Bull, R. A.: 1965, ‘An algebraic study of Diodorean modal systems’, J. Symbolic Logic
30, 58-64.

Bull, R. A.: 1965a, ‘A modal extension of intuitionistic logic’, Notre Dame J. Formal
Logic 6,142-146.

Bull, R. A.: 1966, ‘That all normal extensions of $4.3 have the finite model property’,
Zeit Math. Logik. Grund. 12,341-344.

Bull, R. A.: 1966a, MIPC as the formalization of an intuitionist concept of modality’,
J. Symbolic Logic 31, 609-616.

Bull, R. A.: 1967, ‘On the extension of $4 with CLMpMLp’, Notre Dame J. Formal
Logic 8,325-329.

Bull, R. A.: 1969, ‘On modal logic with propositional quantifiers’, J. Symbolic Logic 34,
257-263.

Bull, R. A.: 1982, Review, J. Symbolic Logic 47, 440-445.

Bull, R. A.: 1983, Review, J. Symbolic Logic 48,488-495.

Carnap, R.: 1942, Introduction to Semantics, Harvard University Press, Cambridge,
Mass.

Carnap, R.: 1947, Meaning and Necessity: A Study in Semantics and Modal Logic, The
University of Chicago Press, Chicago.

Chellas, B. F.: 1980, Modal Logic: An Introduction, Cambridge University Press,
Cambridge.

Church, A.: 1946, ‘A formulation of the logic of sense and denotation. Abstract’, J.
Symbolic Logic 11, 31.

Church, A.: 1951: ‘A formulation of the logic of sense and denotation’, in P. Henle et al.
(eds.), Structure, Method, and Meaning: Essays in Honor of Henry M. Scheffer, The
Liberal Arts Press, New York, pp. 3-24.

Church, A.: 1951a, ‘The weak theory of implication’, in Menne ef al. (eds.), Kon-
trolliertes Denken: Untersuchungen zum Logikkalkil und der Einzelwissenschaften,
Kommissions-Verlag Karl Alber, Munich, pp. 22-37.

Church, A.: 1973/4, ‘Outline of a revised formulation of the logic of sense and deno-
tation’, Noils 7,24-33; 8, 135-156.

Cresswell, M.: 1967, ‘A Henkin completeness theorem for T°, Notre Dame J. Formal
Logic 8,186-190.

Cutley, E. M.: 1975, ‘The development of Lewis’ theory of strict implication’, Notre
Dame J. Formal Logic 16, 517-521.

Curry, H. B.: 1950, A Theory of Formal Deducibility, University of Notre Dame Press,
Notre Dame, Ind.

## Page 5

IL.1:BASIC MODAL LOGIC 83

Dugundj, J.: 1940, ‘Note on a property of matrices for Lewis and Langford’s calculi of
propositions”, J. Symbolic Logic 5, 150-151.

Dummett, M. A. E. and Lemmon, E. J.: 1959, ‘Modal logics between S4 and S5, Zeit.
Math, Logik. Grund, 3, 250~

Esakia, L. and Meskhi, V.: 1977, ‘Five critical modal systems', Theoriz 43, 52-60.

Feys, R.: 1965, Modal Logics, Edited with some complements by Joseph Dopp, E.
Nauwelaerts, Louvain and Gauthier-Villars, Paris.

Fine, K.: 1970, ‘Propositional quantifiers in modal logic’, Theoria 36, 336-346.

Fine, K.: 1971, ‘The logics containing $4.3", Zeir. Math. Logik. Grund. 17, 371-376.

Fine, K.: 1972, ‘Logics containing $4 without the finite model property’, in W. Hodges
(ed.), Conference in Mathematical Logic, London 1970, Lecture Notes in Mathematics
255, Springer-Verlag, Berlin, Heidelberg, New York, pp. 88-102.

Fine, K. 1974, ‘An incomplete logic containing $4°, Theoria 40, 23-29.

Fine, K.: 1974, ‘An ascending chain of $4 logics’, Theoria 40, 110-116.

Fine, K.: 1974b, ‘Logics containing K4, Part ', J. Symbolic Logic 39, 31-42.

Fine, K.: 1975, ‘Some connections between elementary and modal logic’, in S. Kanger
(ed.), Proceedings of the Third Scandinavian Logic Symposium, North-Holland,
Amsterdam, pp. 15-31.

Fine,K.: 19752, ‘Normal forms in modal logic’, Notre Dame J. Formal Logic 16,
229-234.

Fine, K. 1977, *Prior on the construction of possible worlds and instants’, in A. N. Prior
and K. Fine (eds.), Worlds, Times and Selves, Duckworth, London, pp. 116-161.

Fine, K.: 1977a, ‘Properties, propositions and sets’, J. Philosophical Logic 6, 135-191.

Fine, K.: 1978/81, Model theory for modal logic’, J. Philosophical Logic 7, 125-156,
277-306, 10, 293-307.

Fine, K.: 1980/81/82, ‘First-order modal theories’, I: Sets, Nois 15, 177-205; II:
Propositions, Studia Logica 34,159-202; I1l: Facts, Synthese, 53, 43-122.

Fischer Servi, G.: 1977, ‘On modal logic with an intuitionist base’, Studia Logica 36,
141-149.

Fischer Servi, G.: 1981, ‘Semantics for a class of intuitionist modal calcul’, in Maria
Luisa Dalla Chiara (ed.), Italian Studies in the Philosophy of Science, Reidel, Dot-
drecht, pp. 59-72.

Fitch, F. B.: 1937, ‘Modal functions in two-valued logic’, J. Symbolic Logic 2, 125-128.

Fitch, F. B.: 1939, ‘Note on modal functions’, J. Symbolic Logic 4, 115-116.

Fitch, F. B.: 1948, ‘Intuitionistic modal logic with quantifiers’, Portugaliae Mathematica
7,113-118.

Fitch, F. B.: 1952, Symbolic Logic: An Introduction, Ronald Press, New York.

Fgllesdal, D.: ‘Von Wright's modal logic’, in P. A.Schilpp (ed.), The Philosophy of
Georg Henrik Von Wright, to appear.

Fgllesdal, D. and Hilpinen, R.: 1971, ‘Deontic logic: An introduction’, in Hilpinen
[1971], pp. 1-35.

Friedman, H.: 1975, ‘One hundred and two problems in mathematical logic’, J. Symbolic
Logic 40, 113-129.

Gabbay, D. M.: 1976, Investigations in Modal and Tense Logics with Applications to
Problems in Philosophy and Linguistics, Reidel, Dordrecht.

Gabbay, D. M.: 1981, Semantical Investigations in Heyting’s Intuitionistic Logic, Reidel,
Dordrecht.

## Page 6

84 ROBERT BULL AND KRISTER SEGERBERG

Gerson, M.: 1975, ‘The inadequacy of the neighbourhood semantics for modal logic’,
J. Symbolic Logic 40, 141-148.

Gerson, M.: 19753, ‘An extension of $4 complete for the neighbourhood semantics but
incomplete for the relational semantics’, Studia Logica 34, 333-342.

Gerson, M.: 1976, ‘A neighbourhood frame for T with no equivalent relational frame’,
Zeit. Math. Logik. Grund. 22,29-34.

Godel, K.: 1933, ‘Eine Interpretation des intuitionistischen Aussagenkalkiils’, Ergebnisse
eines mathematisches Kolloquiums 4,39-40.

Goldblatt, R. L: 1975, ‘First-order definability in modal logic’, J. Symbolic Logic 40,
3540.

Goldblatt, R. L: 1976, ‘Metamathematics of modal logic’, Reports on Mathematical
Logic 6,41-78;7, 21-52.

Goldblatt, R. I. and Thomason, S.K.: 1975, ‘Axiomatic classes in propositional modal
logic’, in J. N. Crossley (ed.), Algebra and Logic, Lecture Notes in Mathematics 450.
Springer-Verlag, Berlin, Heidelberg, New York, pp. 163-173.

Grzegorczyk, A.: 1981, ‘Individualistic formal approach to deontic logic’, Studia Logica
40,99-102.

Guillaume, M.: 1958, ‘Rapports entre calculs propositionnels modaux et topologie
impliqués par certaines extensions de la méthode de tableaux sémantiques’, Comptes
rendus hebdomaires des séances de I’Academie des Sciences 246, 1140-1142, 2207~
22105 247, 1281-1283, Gauthiers-Villars, Paris.

Halldén, S.: 1949, ‘Results concerning the decision problem of Lewis’s calculi $3 and
86°,J. Symbolic Logic 14, 230-236.

Hansson, B. and Gardenfors, P.: 1973, ‘A guide to intensional semantics’, in Modality,
Morality and Other Problems of Sense and Nonsense: Essays Dedicated to Séren
Halldén, Gleerup, Lund, pp. 151-167.

Hilpinen, R.: 1971, Deontic Logic: Introductory and Systematic Readings, Reidel,
Dordrecht.

Hintikka, J.: 1955, Form and content in quantification theory. Acta Philosophica
Fennica 8, 11-55.

Hintikka, J.: 1957, Quantifiers in Deontic Logic, Societas Scientiarum Fennica, Com-
mentationes humanarum litterarum 23:4. Helsingfors.

Hintikka, J.: 1961, ‘Modality and quantification’, Theoria 27, 119~128. Revised version
reprinted in Hintikka [1969].

Hintikka, J.: 1962, Knowledge and Belief: An Introduction to the Logic of the Two
Notions, Cornell University Press, Ithaca, N.Y.

Hintikka, J.: 1963, ‘The modes of modality’, Acta Philosophica Fennica 16, 65-82.
Reprinted in Hintikka (1969].

Hintikka, 1.: 1969, Models for Modalities: Selected Essays, Reidel, Dordrecht.
Hintikka, J.: 1969a, Review. J. Symbolic Logic 34, 305-306.
Hintikka, J.: 1975, ‘Carnap’s heritage in logical semantics’, In J. Hintikka (ed.), Rudolf

Carnap, Logical Empiricist: Materials and Perspectives, Reidel, Dordrecht, pp. 217~
22.
Hofstadter, A. and McKinsey, J. C. C.: 1939, ‘On the logic of imperatives. Philosophy
of Sciences 6,446-457.
Hughes, G. E. and Cresswell, M. 1.: 1968, An Introduction to Modal Logic, Methuen,
. London, 1968. Second edition 1972.

## Page 7

IL1:BASIC MODAL LOGIC 85

Jeffrey, R. C.: 1967, Formal Logic: Its Scope and Limits, McGraw-Hill, New York.

Jénsson, B.: 1967, ‘Algebras whose congruence lattices are distributive’, Mathematica
Scandinavica 21, 110-121.

Jénsson, E. and Tarski, A.: 1951, ‘Boolean algebras with operators. Part I', Am. J. Math.
73, 891-939.

Kamp, J. A. W.: 1968, ‘On tense logic and the theory of order’, PhD dissertation, UCLA.

Kanger, S.: 1957, Provability in logic, Dissertation, Stockholm.

Kanger, S.: 1957a, New Foundations for Ethical Theory, Stockholm. Reprinted in
Hilpinen [1971).

Kanger, S.: 1957b, ‘The Morning Star Paradox’, Theoria 23, 1-11.

Kanger, S.: 1957c, ‘A note on quantification and modalities’, Theoriz 23,131-134.

Kaplan, D.: 1966, Review, J. Symbolic Logic 31,120-122.

Kaplan, D.; 1970, ‘S5 with quantifiable propositional variables, Abstract’, J. Symbolic
Logic 35, 355.

Kneale, W. and Kneale, M.: 1962, The Development of Logic, Clarendon Press, Oxford.

Kripke, S. A.: 1959, ‘A completeness theorem in modal logic’, J. Symbolic Logic 24,
1-14.

Kripke, S. A.: 1963, ‘Semantical considerations on modal logic’, Acta Philosophica
Fennica 16, 83-94.

Kripke, S. A.: 1963a, ‘Semantical analysis of modal logic I: Normal propositional
calculi, Zeit, Math. Logik. Grund. 9, 67-96.

Kripke, S. A.: 1965, ‘Semantical analysis of modal logic II: Non-normal modal prop-
ositional calculi’, in J. W. Addison et al. (eds.), The Theory of Models, North-Holland,
Amsterdam, pp. 206-220.

Kuhn, S. T.: 1977, Many-sorted Modal Logics, Philosophical studies published by the
Philosophical Society and the Department of Philosophy, University of Uppsala,
Vol. 35, Uppsala.

Leivant, D.: 1981, ‘On the proof theory of the modal logic for arithmetic provability’,
J. Symbolic Logic 46, 531-538.

Lemmon, E. J.: 1957, ‘New foundations for Lewis modal systems", J. Symbolic Logic
22,176-186.

Lemmon, E. J.: 1966, ‘Algebraic semantics for modal logics’, J. Symbolic Logic 31,
46-65,191-218.

Lemmon, E. J.: 1977, An Introduction to Modal Logic, in collaboration with D. Scott,
Blackwell, Oxford.

Lewis, C. L.: 1912, ‘Implication and the algebra of logic’, Mind, n.s., 21,522-531.

Lewis, C. L: 1918, A Survey of Symbolic Logic, University of California Press, Berkeley.

Lewis, C. 1. and Langford, C. H.: 1932, Symbolic Logic. The Century Co., New York,
London, 1932. Second edn, Dover, New York, 1959.

Lewis, D.: 1973, Counterfactuals. Harvard University Press, Cambridge, Mass.

Lukasiewicz, J.: 1953, ‘A system of modal logic’, J. Computing Systems 1,111-149.

Lukasiewicz, J.: 1970, Selected Works, L. Borkowski (ed.), North-Holland, Amsterdam.

McCall, S.: 1967, Polish Logic 19201939, Clarendon Press, Oxford.

McKinsey, J. C. C.: 1941, ‘A solution of the decision problem for the Lewis systems S2
and $4 with an application to topology’,J. Symbolic Logic 6,117-134.

McKinsey, J. C. C.: 1945, On the syntactical construction of modal logic’, J. Symbolic
Logic 10, 83-96.

## Page 8

86 ROBERT BULL AND KRISTER SEGERBERG

McKinsey, J.C. C. and Tarski, A.: 1944, ‘The algebra of topology’, Annals of math-
ematics 45,141-191.

McKinsey, J. C.C. and Tarski, A.: 1948, ‘Some theorems about the sentenital calculi of
Lewis and Heyting’, J. Symbolic Logic 13, 1-15.

Makinson, D.: 1966, ‘On some completeness theorems in modal logic’, Zeit. Math. Logik.
Grund, 12,379-384.

Makinson, D.: 1969, ‘A normal modal calculus between T and S4 without the finite
model property’, J. Symbolic Logic 34, 35-38.

Makinson, D.: 1970, ‘A generalisation of the concept of a relational model for modal
logic’, Theoria 36, 331-335.

Makinson, D.: 1971, Aspectos de la logica modal, Instituto de matematica, Universidad
Nacional del Sur, Bahia Blanca.

Makinson, D.: 1971a, ‘Some embedding theorems for modal logic’, Notre Dame J.
Formal Logic 12, 252-254.

Maksimova, L. L. 1975, TperaGanatsic pactupennn norwicu S4 sionca |Pretabular exten-
sions of Lewis’ $4.), Algebra i logika 14, 28-55.

Malinowski, G.: 1977, ‘Historical note’, in R. Wéjcicki (ed.), Selected Papers on Eukas-
iewicz Sentential Calculi, Polish Academy of Sciences, Wroctaw, pp. 177-187.

Mally, E.: 1926, Grundgesetze des Sollens: Elemente der Logik des Willens, Lenscher &
Lugensky, Graz.

Montague, R.: 1963, ‘Syntactical treatments of modality, with corollaries on reflexion
principles and finite axiomatizability’, Acta Philosophica Fennica 16, 153-167.
Reprinted in Montague [1974].

Montague, R.: 1968, ‘Pragmatics’, in R. Klibansky (ed.), Contemporary Philosophy: A
Survey, Vol. 1, La Nuova Editrice, Florence, pp. 102-122. Reprinted in Montague
[1974].

Montague, R.: 1974, Formal Philosophy: Selected Papers of Richard Montague’, Edited
with an introduction by Richmond H. Thomason, Yale University Press, New Haven,
London.

Morgan, C.: 1979, ‘Modality, analogy, and ideal experiments according to C. S. Pierce’,
Synthese 41,65-83.

Mortimer, M.: 1974, ‘Some results in modal model theory’, J. Symbolic Logic 39, 496~
508.

Ohnishi, M. and Matsumoto, K.: 1957/59, ‘Gentzen method in modal calculi’, Osaka
Mathematical Journal 9,113-130; 11, 115-120.

Parry, W. T.: 1934, ‘The postulates for “strict implication””, Mind, n.s., 43, 78-80.

Parsons, C.: ‘Intensional logic in extensional language’, J. Symbolic Logic 47, 289-328.

Pratt, V. R.: 1980, ‘Application of modal logic to progamming’, Studia Logica 34,
257-274.

Prawitz, D.: 1965, Natural Deduction; a Proof-theoretic Study (Stockholm Studies in
Philosophy, 3), Almqvist and Wiksell, Stockholm.

Prior, A. N.: 1955, Formal Logic, Clarendon Press, Oxford. Second edition 1962.

Prior, A. N.: 1957, Time and Modality, Clarendon Press, Oxford.

Prior, A. N.: 1967, Past, Present and Future, Clarendon Press, Oxford.

Rasiowa, H. and Sikorski, R.: 1963, The Mathematics of Metamathematics, Patistwowe
Wydawnictwo Naukowe.

Rautenberg, W.: 1979, Klassische und nichtklassische Aussagenlogik, Vieweg, Braun-
schweig, Wiesbaden.

## Page 9

IL1:BASIC MODAL LOGIC 87

Rescher, N. and Urquhart, A.: 1971, Temporal Logic, Springer-Verlag, New York and
Vienna.

Ridder, J.: 1955, ‘Die Gentzensschen Schlussverfahren in modalen Aussagenlogiken I',
Indagationes mathematicae 17,163-276.

Sahlquist, H.: 1975, ‘Completeness and correspondence in the first and second order
semantics for modal logic’, in Stig Kanger (ed.), Proceedings of the Third Scan-
dinavian Logic Symposium, North-Holland, Amsterdam, pp. 110-143.

Schumm, G. F.: 1981, ‘Bounded properties in modal logic’, Zeir. Math. Logik. Grund.
27,197-200.

Schiitte, K.: 1968, Vollistandige Systeme modaler und intuitionistischer Logik, Springer-
Verlag, Berlin, Heidelberg and New York.

Scott, D.: 1971, ‘On engendering an illusion of understanding’, J. Philosophy 68, 787~
807.

Scroggs, S. J.: 1951, ‘Extensions of the Lewis system S5°,J. Symbolic Logic 16,112-120.

Segerberg, K.: 1968, Decidability of S4.1, Theoria 34, 7-20.

Segerberg, K.: 1970, ‘Modal logics with linear alternative relations’, Theoria 36,301-322.

Segerberg, K.: 1971, An Essay in Classical Modal Logic, Philosophical studies published
by the Philosophical Society and the Department of Philosophy, University of
Uppsala, Vol. 13, Uppsala.

Segerberg, K.: 1982, Classical Propositional Operators: An Exercise in the Foundations
of Logic, Clarendon Press, Oxford.

Segerberg, K.: [*], ‘Von Wright's tense-logic’, in P. A. Schilpp (ed.) The Philosophy of
Georg Henrik von Wright, to appear.

Shoesmith, D. J. and Smiley, T. J.: 1978, Multiple-Conclusion Logic, Cambridge Univer-
sity Press, Cambridge.

Smullyan, R. M.: 1968, First-order Logic, Springer-Verlag, New York, Heidelberg and
Berlin.

Snyder, D. P.: 1971, Modal Logicand its Applications, Van Nostrand Reinhold, New York.

Sobincifiski, B.: 1964, ‘Family K of the non-Lewis modal systems’, Notre Dame J.
Formal Logic 5, 313-318.

Solovay, R. S. M.: 1976, Provability interpretations of modal logic. Israel journal of
mathematics 25, 287-304.

Stalnaker, R.: 1968, ‘A theory of conditionals’, in N. Rescher (ed.), Studies in Logical
Theory, Blackwell, Oxford, pp. 98-112.

Thomason, S.K.: 1972, ‘Semantic analysis of tense logics’, J. Symbolic Logic 37,
150-158.

Thomason, S. K.: 1972a, “Noncompactness in propositional modal logic’, J. Symbolic
Logic 37,716-720.

Thomason, S.K.: 1974, ‘An incompleteness theorem in modal logic’, Theoria 40,
30-34.

Thomason, S. K.: 1975, ‘Categories of frames for modal logic’, J. Symbolic Logic 40,
439-442.

Van Benthem, J. F. A, K.: 1975, ‘A note on modal formulae and relational properties’,
J. Symbolic Logic 40, 55-58.

Van Benthem, J. F. A.K.: 1976, ‘Modal formulas are cither clementary or not TA-
clementary’, J. Symbolic Logic 41, 436-438.

Van Benthem, J. F. A. K.: 1978, ‘Two simple incomplete modal logics’, Theoria 44,
25-37.

## Page 10

88 ROBERT BULL AND KRISTER SEGERBERG

Van Benthem, J. F. A. K.: 1979, ‘Canonical modal logics and ultrafilter extensions’, J.
Symbolic Logic 44, 1-8.

Van Benthem, J. F. A. K.: 1979, ‘Syntactic aspects of modal incompleteness theorems’,
Theoria 45,67-81.

Van Benthem, J. F. A. K. and Blok, W.J.: 1978, ‘Transitivity follows from Dummett’s
axiom’, Theoria 44, 117-118.

Von Wright, . H.: 1951, An Essay in Modal Logic, North-Holland, Amsterdam.

Von Wright, G. H.: 1951a, ‘Deontic logic’, Mind, n.s., 60, 1-15.

Von Wright, G. H.: 1968, ‘An essay in deontic logic and general theory of action witha
bibliography of deontic and imperative logic’, Acta Philosophica Fennica 21.

Von Wright, G. H.: 1981, ‘Problems and prospects of deontic logic: A Survey’, in Evandro
Agazzi (ed.), Modern Logic - A Survey, Reidel Dordrecht, pp. 299-423.

Zeman, 1. 1.: 1973, Modal Logic: The Lewis-Modal Systems, Clarendon Press, Oxford.

## Page 11

CHAPTER I1.2

BASIC TENSE LOGIC*
byJOHN P. BURGESS

0. What is tense logic? 89
1. First steps in tense logic 96
2. A quick trip through tense logic 102
3. The decidability of tense logics 113
4. Temporal conjunctions and adverbs 116

A. Since, until, uninterruptedly, recently, soon 116

B. Now, then 121
5. Time periods 124
6. Glimpses around 127
References 132

0. WHAT IS TENSE LOGIC?
We approach this question through an example:

(0) Smith:  Have you heard? Jones is going to Albania!
Smythe: He won’t get in without an extra-special visa. Has he
remembered to apply for one?
Smith: Not yet, so far as  know.
Smythe: Then he’ll have to do so soon.

In this bit of dialogue the argument, such as it is, turns on issues of temporal
order. In English, as in all Indo-European and many other languages, such
order is expressed in part through changes in verb-form, or tenses. How
should the logician treat such tensed arguments?

A solution that comes naturally to mathematical logicians, and that has
been forcefully advocated in Quine [1960], is to regiment ordinary tensed
language to make it fit the patterns of classical logic. Thus (0) might be
reduced to the quasi-English (1) below, and thence to the ‘canonical notation’
of (2):

(1) Jones /visits/ Albania at some time later than the present.

* Research in part supported by U.S. National Science Foundation Grant #MCS-
8003254.

89

D. Gabbay and F. Guenthner (eds.) Handbook of Philosophical Logic, Vol. II, 89-133.
©1984 by D. Reidel Publishing Company.

## Page 12

90 JOHN P. BURGESS

At any time later than the present, if Jones /visits/ Albania then, then at
some earlier time Jones /applies/ for a visa.

At no time earlier than or equal to the present is it the case that Jones
/applies/ for a visa.

Therefore, Jones /applies/ for a visa at some time later than the present.

2) At(c<taA1)
V(e <t aP(t)~> Ju(u <t Q)
-3t <cvt=c)A Q1))
L3 <tA Q).

Regimentation involves introducing quantification over instants ¢, u, . . . of
time, plus symbols of the present instant ¢ and the earlier-later relation <.
Above all, it involves treating such a linguistic item as ‘Jones is visiting
Albania’ not as a complete sentence expressing a proposition and having a
truth-value, to be symbolized by a sentential variable p, q, . . ., but rather as
a predicate expressing a property on instants, to be symbolized by a one-place
predicate variable P, Q, . ... Regimentation has been called detensing since
the verb in, say, ‘Jones /visits/ Albania at time ¢’, written here in the gram-
matical present tense, ought really to be regarded as tenseless; for it states not
a present fact but a timeless or ‘eternal’ property of the instant ¢. Bracketing
is one convention for indicating such tenselessness.

The knack for regimenting or detensing, for reducing something like (0) to
something like (2), is easily acquired. The analysis, however, cannot stop
there. For a tensed argument like that above must surely be regarded as an
enthymeme, having as unstated premises certain assumptions about the struc-
ture of Time. Smith and Smythe, for instance, probably take it for granted
that of any two distinct instants, one is earlier than the other. And if this
assumption is formalized and added as an extra premise, then (2), invalid as it
stands, becomes valid.

Of course it is the job of the cosmologist, not the logician, to judge
whether such an assumption is physically or metaphysically correct. What is
the logician’s job is to formalize such assumptions, correct or not, in logical
symbolism. Fortunately, most assumptions people make.about the structure
of Time go over readily into first- or, at worst, second-order formulas:

0.1. Postulates for Earlier-Later

(B0) Antisymmetry VxWy 2 (x<yay<x)
(B1) Transitivity VxVyVz(x <y Ay <z->x<z)

## Page 13

IL.2: BASIC TENSE LOGIC 91

(B2) Comparability VxVy(x <yvx=yvy<x)
(B3) (a) Maximum Ixvy(y <xvy=x)
(b) Minimum Vy(x<yvx=y)
(B4) (a) No Maximals Vx3y(x <y)
(b) No Minimals vx3y(y <x)
(B5) Density WxVy(x <y ->3z(x<zaz<y))
(B6) (a) Successors VxAy(x <y a~3z(x <z Az <y))
(b) Predecessors vx3y(y <xa-3z2(y<zaz<x))
(B7) Completeness YU((3x U(x) A 3x - U(x) A VxVp(U(X) A

A~U(y) = x <p)) > (3x(Ux) A
AVY(x <y >=U(y) vAx(~UX) A
AVy(y <x->U(»)))
(B8) Wellfoundedness YU(IxU(x) > Ix(U(x) > A Vy(y <x >
=>-U())
(B9) (a) Upper Bounds VxVyAz(x <z ay<z)
(b) Lower Bounds VxVy3z(z <xaz<y).

For more on the development of the logic of time as a branch of applied first-
and second-order logic, see Van Benthem [1978].

The alternative to regimentation is the development of an autonomous
tense logic (also called temporal logic or chronological logic), first undertaken
in Prior [1957] (though several precursors are cited in Prior [1967]). Tense
logic takes seriously the idea that items like ‘Jones is visiting Albania’ are
already complete sentences expressing propositions and having truth-values,
and that they should therefore be symbolized by sentential variablesp, q, . . . .
Of course, the truth-value such a sentence has today may well differ from the
one it had yesterday or will have tomorrow; or to put the matter a different
way, the truth-value of a sentence in the present tense may well differ from
that of the corresponding sentence in the past or future tense. Hence, tense
logic will need some way of symbolizing the relations between sentences that
differ only in the tense of the main verb. At its simplest, tense logic adds for
this purpose to classical truth-functional sentential logic just two one-place
connectives: The future-tense or ‘will’ operator F and the past-tense or ‘was’
operator P. Thus, if p symbolizes ‘Jones is visiting Albania’, then Fp and Pp
respectively symbolize something like ‘Jones is sooner or later going to visit
Albania’ and ‘Jones has at least once visited Albania’. In reading tense-
logical symbolism aloud, F and P may be read respectively as ‘it will be the
case that’ and ‘it was the case that’. Then —F-, usually abbreviated G, and
—P~, usually abbreviated H, may be read respectively as ‘it is always going to

## Page 14

92 JOHN P. BURGESS

be the case that’ and ‘it has always been the case that’. Actudlly, for many
purposes it is preferable to take G and H as primitive, defining F and P as
~G— and —H~ respectively. Armed with this notation, the tense-logician will
reduce (0) above first to the stylized (3) and then to the tense-logical (4):

3) Future-tense (Jones visits Albania)

Not future-tense (Jones visits Albania and not past-tense (Jones applies
for a visa)).

Not past-tense (Jones applies for a visa) and not Jones applies to a visa.

Therefore, future-tense (Jones applies for a visa)

@ Fr
~F(pA—Pq)
~Pga=q
~Fq.
Of course, we will want some axioms and rules for the new temporal oper-
ators F, P, G, H. All the axiomatric systems considered in this survey will
share the same standard format:

0.2. Standard Format

We start from a stock of sentential variables po, 1, P2, . . - , usually writing p
for po and q for p,. The (well-formed) formulas of tense logic are built up
from the variables using negation (—), and conjunction (A), and the strong
future (G) and strong past (H) operators. The mirror image of a formula is
the result of replacing each occurrence of G by H and vice versa. Disjunction
(v), material conditional (=), material biconditional (<), constant true (T),
constant false (1), weak future (F), and weak past (P) can be introduced as
abbreviations.

Asaxioms we take all substitution instances of truth-functional tautologies.
In addition, each particular system will take as axioms all substitution
instances of some finite list of extra axioms, called the characteristic axioms
of the system. As rules of inference we take Modus Ponens (MP) plus the
specifically tense-logical:

Temporal Generalization (TG): From « to infer Ga and Ha

The theses of a system are the formulas obtainable from its axioms by these
rules. A formula is consistent if its negation is not a thesis; a set of formulas
is consistent if the conjunction of any finite subset is. These notions are, of
course, relative to a given system.

## Page 15

IL2: BASIC TENSE LOGIC 93

The systems considered in this survey will have characteristic axioms
drawn from the following list:

0.3. Postulates for Past-Present-Future

(A0) () G(p~q)~(Gp~Gq) (b) H(p~q)~ (Hp ~Hq)
(c) p->GPp () p-HFp

(A1) (@ Gp->GGp (b) Hp-HHp

(A2) () FpaFq~>F(paFq)v F(paq)vF(Fpaq)
(b) PpaPq~>P(pAPg)vP(paq)vPPpAq)

(A3) (8 GLVFGL (b) HLvPHL
(A4) (a) Gp->Fp (b) Hp-Pp

(AS)  (a) Fp~FFp (b) Pp—>PPp
(A6) (a) pnHp~FHp (b) pAGp~>PGp

(A7) (a) FpAFG-p-F(HFpAG-p)
(b) Pp A PH-p ~P(GPp A H-p)
(A8)  H(Hp~p)~Hp
(A9) (a) FGp~GFp (b) PHp—HPp.

A few definitions are needed before we can state precisely the basic prob-
lem of tense logic, that of finding characteristic axioms that ‘correspond’ to
various assumptions about Time.

0.4. Formal Semantics

A frame is a nonempty set X equipped with a binary relation R. A valuation
in a frame (X, R) is a function V assigning each variable p; a subset of X.
Intuitively, X can be thought of as representing the set of instants of time, R
the earlier-later relation, V' the function telling us when each p; is the case. We
extend ¥ to a function defined on all formulas, by abuse of notation still
called V, inductively as follows:

V(ca) = X—W()

Vanp) = V(@) N V(B)

V(Ga) = {xEX:VyEX(xRy~>y EV(x))}
V(Hoe) = {xEX:Yy EX(YRx -y E V(a))}.

(Some writers prefer a different notation. Thus, what we have expressed as
X € V() may appear as |||y = TRUE or as (X, R, V) afx].) A formula &
is valid in a frame (X, R) if V() = X for every valuation ¥ in (X, R), and is

## Page 16

94 JOHN P. BURGESS

satisfiable in (X, R) if V(a)# @ for some valuation V in (X, R), or-equiv-
alently if ~a is not valid in (X, R). Further, a is valid over a class % of frames
if it is valid in every (X, R) € ¥; and is satisfiable over ¥'if it is satisfiable in
some (X, R) € %, or equivalently if ~a is not valid over %, A system L in
standard format is sound for ¥ if every thesis of L is valid over % and a
sound system L is complete for % if conversely every formula valid over ¥ is
a thesis of L, or equivalently, if every formula consistent with L is satisfiable
over #. Any set (let us say, finite) ® of first- or second-order axioms about
the earlier-later relation < determines a class #(®) of frames, the class of its
models. The basic correspondence problem of tense logic is, given @ to find
characteristic axioms for a system L that will be sound and complete for
H(®). The next two sections of this survey will be devoted to presenting the
solution to this problem for many important .

0.5. Motivation

But first it may be well to ask, why bother? Several classes of motives for
developing an autonomous tense logic may be cited:

(a) Philosophical motives were behind much of the pioneering work of
A.N. Prior, to whom the following point seemed most important: Whereas
our ordinary language is tensed, the language of physics is mathematical and
so untensed. Thus, there arise opportunities for confusions between different
‘terms of ideas’. Now working in tense logic, what we learn is precisely how
to avoid confusing the tensed and the tenseless, and how to clarify their
relations (e.g. we learn that essentially the same thought can be formulated
tenselessly as, ‘Of any two distinct instants, one /is/ earlier and the other /is/
later’, and tensedly as, ‘Whatever is going to have been the case either already
has been or now is or is sometime going to be the case). Thus, the study of
tense logic can have at least a ‘therapeutic’ value. Later writers have stressed
other philosophical applications, and some of these are treated elsewhere in
this Handbook.

(b) Exegetical applications again interested Prior (see his [1967], Chapter
7). Much was written about the logic of time (especially about future con-
tigents) by such ancient writers as Aristotle and Diodoros Kronos (whose
works are unfortunately lost), and by such mediaeval ones as William of
Ockham or Peter Auriole. It is tempting to try to bring to bear insights from
modern logic to the interpretation of their thought. But to pepper the text of

## Page 17

1.2: BASIC TENSE LOGIC 95

an Aristotle or an Ockham with such regimenters’ phrases as ‘at time ¢’ is an
almost certain guarantee of misunderstanding. For these earlier writers
thought of such an item as ‘Socrates is running’ as being already complete as
it stands, not as requiring supplementation before it could express a propo-
sition or have a truth-value. Their standpoint, in other words, was like that of
modern tense logic, whose notions and notations are likely to be of most use
in interpreting their work, if any modern developments are.

(c) Linguistic motivations are behind much recent work in tense logic. See
Gabbay and Guenthner [to appear] among other items in our bibliography. A
certain amount of controversy surrounds the application of tense logic to
natural language. See, e.g., Van Benthem [1978, 1981] for a critic’s views. To
avoid pointless disputes it should be emphasized from the beginning that
tense logic does not attempt the faithful replication of every feature of the
deep semantic structure (and still less of the surface syntax) of English or
any other language; rather, it provides an idealized model giving the sym-
pathetic linguist food for thought. An example: In tense logic, P and F can be
iterated indefinitely to form, e.g., PPPFp or FPFPp. In English, there are four
types of verbal modifications indicating temporal reference, each applicable
at most once to the main verb of a sentence: Progressive (be + ing), Perfect
(have + en), Past (+ ed), and Modal Auxiliaries (including will, would). Tense
logic, by allowing unlimited iteration of its operators, departs from English,
to be sure. But by doing so, it enables us to raise the question of whether the
multiple compounds formable by such iteration are really all distinct in mean-
ing; and a theorem of tense logic (see section 2.5 below) tells us that on
reasonable assumptions they are not, e.g. PPPFp and FPFPp both collapse to
PFp (which is equivalent to FPp). And this may suggest why English does not
need to allow unlimited iteration of its temporal verb modifications.

(d) Computer Science: Both tense logic itself and, even more so, the closely
related so-called dynamic logic have recently been the objects of much
investigation by theorists interested in program verification. Temporal oper-
ators have been used to express such properties of programs as termination,
correctness, safety, deadlock freedom, clean behavior, data integrity, access-
ibility, responsiveness, and fair scheduling. These studies are mainly con-
cened only with future temporal operators, and so fall technically within
the province of modal logic. See Harel [I1.10], Pratt [1980] among other
items in our bibliography.

## Page 18

96 JOHN P. BURGESS

() Mathematics: Some taste of the purely mathematical interest of tense
logic will, it is hoped, be apparent from the survey to follow. Moreover, tense
logic is not an isolated subject within logic, but rather has important links
with modal logic, intuitionistic logic, and (monadic) second-order logic.

Thus, the motives for investigating tense logic are many and varied.

1. FIRST STEPS IN TENSE LOGIC

Let L, be the system in standard format with characteristic axioms (A0a, b, ¢,
d). Let ¥, be the class of all frames. We will show that L, is (sound and)
complete for ¥, and thus deserves the title of minimal tense logic. The
method of proof will be applied to other systems in the next section.
Throughout this section, thesishood and consistency are understood relative
to Ly, validity and satisfiability relative to %;.

1.1. SOUNDNESS THEOREM: L, is sound for %¥;.

Proof. We must show that any thesis (of Lo) is valid (over %;). For this it
suffices to show that each axiom is valid, and that each rule preserves validity.
The verification that tautologies are valid, and that substitution and MP pre-
serves validity is a bit tedious, but entirely routine.

To check that (AQa) is valid, we must show that for all relevant X, R, V,
and x, if x € V(G(p - q)) and x € V(Gp), then x € V(Gq). Well, the hypoth-
eses here mean, first that whenever xRy and y € V(p), then y € ¥(q); and
second that whenever xRy, then y € V(p). The desired conclusion is that
whenever xRy, then y € ¥(q); which follows immediately. Intuitively, (AOa)
says that if g is going to be the case whenever p is, and p is always going to
be the case, then g is always going to be the case. The treatment of AOb is
similar.

To check that AQc is valid, we must show that for all relevant X, R, V, and
x, if x € V(p), then x € V(GPp). Well, the desired conclusion here is that for
every y with xRy there is a z with zZRy and z € V(p). It suffices to take z = x.
Intuitively, AOc says that whatever is now the case is always going to have
been the case. The treatment of (A0d) is similar.

To check that TG preserves validity, we must show that if for all relevant
X, R, V, and x we have x € V(a), then for all relevant X, R, V, and x we have
xE€V(Ha) and x € V(Ga), in other words, that whenever yRx we have
¥ € V() and whenever xRy we have y € V(). But this is immediate. Intuit-
ively, TG says that if something is now the case for logical reasons alone, then
for logical reasons alone it always has been and is always going to be the case:
Logical truth is eternal. O

## Page 19

I.2: BASIC TENSE LOGIC 97

In future, verifications of soundness will be left as exercises for the reader.
Our proof of the completeness of Ly for g will use the method of maximal
consistent sets, first developed for first-order logic by L. Henkin, adapted to
nonclassical logics by S.Kripke, systematically applied to tense logic by
E.J. Lemmon and D. Scott (in notes never fully published), and refined and
perfected by Gabbay [1975].

Thé completeness of Lo for % is due to Lemmon. We need a number of
preliminaries.

1.2. DERIVED RULES: The following rules of inference preserve
thesishood:

(a) from ay, a, . . . , &, to infer any truth-functional consequence 8

(b) from a > B to infer Ga - G and Ha~ HB

(c) from a < B and 6(c/p) to infer 8(B/p)

(d) from a to infer its mirror image

Proof. (a) To say that 8 is a truth-functional consequence of a;, ay, ...,
@, is to say that (@;A @ A ... Aoy~ f) or equivalently a; > (o > (...
(an = P) ...)) is an instance of a tautology, and hence is an axiom. We then
apply MP.

(b) From a— B we first obtain G(a = f) by TG, and then Ga - Gf by AOa
and MP. Similarly for H.

(c) Here (a/p) denotes substitution of a for the variable p. It suffices to
prove that if a—p and 8->« are theses, then so are f(a/p) > 6(B/p) and
0(B/p) > 0(a/p). This is proved by induction on the complexity of 8, using
part (b) for the cases 8 = Gx and 8 = Hx. In particular, part (c) allows us to
insert and remove double negations freely. We write a ~ § to indicate that
a < B is a thesis.

(d) This follows from the fact that the tense-logical axioms of L, come in
‘mirror-image pairs, (AOa, b) and (AOc, d). Unlike parts (a)~(c), part (d) will
not necessarily hold for every extension of Lo. o

1.3. THESES: We present a deduction in Ly, labeling some theses for future
reference:

(1) G(p~>q)~>G(~q~>~p) from a tautology by 1.2b
(2) G(~q~>-p)~>(G~g~>G-p) (Aa)

@ () Gp->q)~>(Fp~Fq) from 1,2 by 1.2a
(4) Gp~>G(@~pnq) from a tautology by 1.2b

(5) Gla»pnq)~>(Fq~>F(paq) 3

## Page 20

98

JOHN P. BURGESS

(b) (6) Gp AFg->F(pnagq) from 4, 5 by 1.2a
(7) p~>GPp (A0c)
(8) GPpAFq~F(Ppaq) 6
() (9 pAFg~>FPpngq) from 7,8 by 1.2a
(0 gg:g:gz from tautologies by 1.2b
(11) Glg~»prq)~>(Ga~>G(@Aq) (Ada)
(@ (12) Gpa Gg+—G(prq) from 4, 10, 11 by 1.2a
(13) G-pAG~q~>G(-p A—q) 12
(14) G-pAG-q~>G~(pvq) from 13 by 1.3¢

(e) (15) FpvFq<—Flpvq)
(16) Gp~>G(p vq)

from 14 by 1.2a
from tautologies by 1.2b

Gq~>G(pvq)
6 (17) GpvGqa~>G(pvq) from 16 by 1.2a
(18) G-pvG-q~>G(-pv—q) 17

(19) G-pvG~q>G~(pnq)
(® (20) Flpaq)>FpaFq

(21) ~p~>HF-p

(22) ~p>H-Gp
(h) (23) PGp~>p

Also the mirror images of 1.3a-h are theses by 1.2d.
We assume familiarity with the following:

1.4. LINDENBAUM’S LEMMA: Any consistent set of formulas can be
extended to a maximal consistent set.

from 18 by 1.2¢
from 19 by 1.2a
(A0d)

from 21 by 1.2¢
from 22 by 1.2a

1.5. LEMMA: Let A bea maximal consistent set of formulas. For all formulas
we have:

@Ifay,...,0,€A and oyA...A
(b)~a€4 iffadd

(c) (@np)EA iffa€A
(d)(avB)EA iffa€A or

oy, > Bis a thesis, then B € A.

and PEA
BEA

They will be used tacitly below.

Intuitively, a maximal consistent set - henceforth abbreviated MCS -
represents a full description of a possible state of affairs. For MCSs 4, B we
say that 4 is potentially followed by B, and write A -3 B, if the conditions of
Lemma 1.6 below are met. Intuitiviely, this means that a situation of the sort
described by A could be followed by one of the sort described by B.

## Page 21

11.2: BASIC TENSE LOGIC 99

1.6. LEMMA: For any MCSs A, B, the following are equivalent:

(a) whenever o« € A, we have Pa € B,
(b) whenever 3 € B, we have FBE A,
(© whenever Gy € A, we havey €B,
(d) whenever H5 € B, we have § € A.

Proof. To show (a) implies (c): Assume (a) and let Gy € A. Then PGy € B,
50 by Thesis 1.3h we have y € B as required by (c).

To show (c) implies (b): Assume (c) and let § € B. Then ~f ¢ B, so G—f
¢ A, and FB = ~G-BE A as required by (b).

Similarly (b) implies (d) and (d) implies (a). [m]

1.7. LEMMA: Let C be an MCS, y any formula:

(a) if Fy €C, then there exists an MCS B with C 3 Band Y E B,

(b) if Py €C, then there exists an MCS A with A 3 Cand Yy EA.

Proof. We treat (a): It suffices (by criterion Lemma 1.6a) to obtain an
MCS B containing By = {Pa:a € C}U {y}. For this it suffices (by Linden-
baum’s Lemma) to show that B, is consistent. For this it suffices (by the
closure of C under conjunction plus the mirror image of Thesis 1.3g) to show
that for any a €C, Pa Ay is consistent. For this it suffices (since TG guaran-
tees that —F5 is a thesis whenever 8 is) to show that F(Pa A ) is consistent.
And for this it suffices to show that F(Pa A y) belongs to C - as it must by
1.3c. |m}

1.8. DEFINITION: A chronicle on a frame (X, R) is a function T assigning
each x € X an MCS T(x). Intuitively, if X is thought of as representing the set
of instants, and R the earlier-later relation, T should be thought of as provid-
ing a complete description of what goes on at each instant. T is coherent if
we have T(x) T(y) whenever xRy. T is prophetic (resp. historic) if it is
coherent and satisfies the first (resp. second) condition below:

(a) whenever Fy € T(x) there is a y with xRy and ¥ € T(y),
(b) whenever Py € T(x) there is ay with yRx and y € T(»).

T is perfect if it is both prophetic and historic. Note that T is coherent iff it
satisfies the two following conditions:

(c) whenever Gy € T(x) and xRy, theny € T(y),
(d) whenever Hy € T(x) and yRx, then y € T(y).

If V is a valuation in (X, R), the induced chronicle Ty is defined by

## Page 22

100 JOHN P. BURGESS

Ty(x) = {y:x € V(y)}; Tv is always perfect. If T is a perfect chronicle on
(X, R), the induced valuation ¥ is defined by Vr(p;) = {x:p; € T(x)}. We
have:

1.9. CHRONICLE LEMMA: Let T be a perfect chronicle on a frame (X, R).
If V=V is the valuation induced by T, then T = T, the chronicle induced
by V. In other words, for all formulas y we have:

V) = ey T}

In particular, any member of any T(x) is satisfiable in (X, R).
Proof. (+) is proved by induction on the complexity of 7. As a sample,
we treat the induction step for G: Assume (+) for v, to prove it for Gy:
On the one hand, if Gy € T(x), then by Defintion 1.8c, whenever xRy we
have y € T(p) and by induction hypothesis y € V(). This shows x € V(Gy).
On the othe hand, if Gy & T(x), then F~y ~ ~Gy € T(x), so by Definition
1.8a for some y with xRy we have ~y € T(y) and y & T(y), whence by
induction hypothesis, y € V(y). This shows x ¢ V(Gy). o

To prove the completeness of Lo for #, we must show that every con-
sistent formula 7, is satisfiable. Now Lemma 1.9 suggests an obvious strategy
for proving 7, satisfiable, namely to construct a perfect chronicle 7' on some
frame (X, R) containing an X, with 7o € T(x,). We will construct X, R, and T’
piecemeal.

1.10. DEFINITION: Fix a denumerably infinite set W. Let M be the set of
all triples (X, R, T') such that:

(a) X is a nonempty finite subset of W,
(b) R is an antisymmetric binary relation on X,
(c) T is a coherent chronicle on (X, R).

For u=(X, R, T) and &' = (X', R, T') in M we say ' extends u if (when
relations and functions are identified with sets of ordered pairs) we have:

@) xc<x'
®) R=R'NXxX)
(c) T<T

A conditional requirement of form 1.8a or b will be called unborn for
u=(X, R, T)EM if its antecedent is not fulfilled; that is, if x ¢ X or if
X €X but Fy or Py as the case may be does not belong to T(x). It will be

## Page 23

IL.2: BASIC TENSE LOGIC 101

called alive for p if its antecedent is fulfilled but its consequent is not; in
other words, there is no y €X with xRy or yRx as the case may be and
7ET(Y).

It will be called dead for u if its consequent is fulfilled. Perhaps no mem-
ber of M is perfect; but any imperfect member of M can be improved:

1.11. KILLING LEMMA: Let u=(X, R, T) EM. For any requirement of
form 1.8a or b which is alive for , there exists an extension u' = (X',R', T")
€M of u for which that requirement is dead.

Proof. We treat a requirement of form 1.8a. If x €X and Fy € T(x), by
1.7a there is an MCS B with T(x) -3 B and y € B. It therefore suffices to fix
¥ € W-X and set:

@  X'=xu{y}

()  R'=RU{x,»)}

©  T'=Tu{yB} o

1.12. COMPLETENESS THEOREM: L, is complete for ¥,

Proof. Given a consistent formula o, we wish to construct a frame (X, R)
and a perfect chronicle T on it, with yo € T(x,) for some x,. To this end we
fix an enumeration xo, X, X5, . . . of W, and an enumeration yo, 71,72, - . . of
all formulas. To the requirement of form 1.8a (resp. 1.8b) for x = x; and
7y =7, we assign the code number 2'5"7 (resp. 3'5"7). Fix an MCS C, with
Y0 € Co, and let pp = (Xo, Ry, To) where Xo = {xo}, Ro =0, and T = {(xo,
Co)}. If iy, is defined, consider the requirement, which among all those which
are alive for y,, has the least code number. Let y,,,, be an extension of u,, for
which that requirement is dead, as provided by the Killing Lemma. Let
(X, R, T) be the union of the y,, = (X, Ry, Tp,); more precisely, let X be the
union of the X, R of the R,,, and T of the T,,. It is readily verified that T is
a perfect chronicle on (X, R), as required. a

The observant reader may be wondering why in Definition 1.10b the
relation R was required to be antisymmetric. The reason was to enable us to
make the following remark: Our proof actually shows that every thesis of
L, is valid over the class % of all frames, and that every formula consistent
with Ly is satisfiable over the class Fany; of antisymmetric frames. Thus, %,
and Hgn; give rise to the same tense logic; or to put the matter differently,
there is no characteristic axiom for tense logic which ‘corresponds’ to the
assumption that the earlier-later relation on instants of time is antisymmetric.

In this connection a remark is in order: Suppose we let X be the set of all

## Page 24

102 JOHN P. BURGESS

MCSs, R the relation -3, ¥ the valuation V(p;) = {x:p; € x}. Then using 1.6
and 1.7 it can be checked that V(y) = {x:y € x} forall y. In this way we get
a quick proof of the completeness of L, for #g. However, this (X, R) is not
antisymmetric. Two MCSs A and B may be clustered in the sense that 4 3 B
and B -3 A. There is a trick, known as ‘bulldozing’, though, for converting
nonantisymmetic frames to antisymmetric ones, which can be used here to
give an alternative proof of the completeness of Lo for Hgn;. See Bull and
Segerberg [this volume, Chapter I1.1] and Segerberg [1970].

2. AQUICK TRIP THROUGH TENSE LOGIC

The material to be presented in this section was developed piecemeal in the late
1960s. In addition to persons already mentioned, R. Bull and N. Cocchiarella
should be cited as important contributors to this development. Since little
was published at the time, it is now hard to assign credits.

2.1. Partial Orders

Let L, be the extension of Lo obtained by adding (Ala) as an extra axiom.
Let %] be the class of partial orders, that is, of antisymmetric, transitive
frames. We claim L, is (sound and) complete for #;. Leaving the verification
of soundness as an exercise for the reader, we sketch the modifications in the
work of the preceding section needed to establish completeness.

First of all, we must now understand the notions of thesishood and con-
sistency and, hence, of MCS and chronicle, as relative to L,. Next, we must
revise clause 1.10b in the definition of M to read:

(by) R is a partial order on X.

This necessitates a revision in clause 1.11b in the proof of the Killing Lemma.
Namely, in order to guarantee that R' will be a partial order on X', that
clause must now read:

(b)) R =RU{x»}V{(.7):0Rx}.

But now it must be checked that 7", as defined by clause 1.11c, remains a
coherent chronicle under the revised definition of R'. Namely, it must be
checked that if vRx, then T(v)-8 B. To show this (and so complete the
proof) the following suffices:

## Page 25

1.2: BASIC TENSE LOGIC 103

LEMMA: Let A, C, Bbe MCSs. If A 3Cand C -3 B, then A 3 B.

Proof. We use criterion 1.6¢ for 3: Assume Gy € 4, to prove y € B. Well,
by the new axiom (Ala) we have GGy €A. Then since A 3 C, we have
Gy €C, and since C-3 B, we have y €B. a

It is worth remarking that the mirror image Alb of Ala is equally valid
over partial orders, and must thus by the completeness theorem be a thesis
of L. To find a deduction of it is a nontrivial exercise.

2.2. Total Orders

Let L, be the extension of L, obtained by adding (A2a, b) as extra axioms.
Let ¥ be the class of total orders, or frames satisfying antisymmetry, trans-
itivity, and comparability. Leaving the verification of soundness to the reader,
we sketch the modifications in the work of Section 2.1 above, beyond simply
understanding thesishood and related notions as relative to L,, needed to
show L, complete for #;.

To begin with, we must revise clause 1.10b in the definition of M to read:

(bz)  Risatotal order on X.

This necessitates revisions in the proof of the Killing Lemma, for which the
following will be useful:

LEMMA: Let A, B, C be MCSs. If A 3 B and A 3 C, then either B=C or
B3CorC-3B

Proof. Suppose for contradition that the two hypotheses hold but none of
the three alternatives in the conclusion holds. Using criterion 1.6b for -3, we
see that there must exist a yo €C with Fyo ¢ B (else B3 C) and a f, €B
with Fo ¢ C (else C -3 B). Also there must exist a § with & €B, & & C (else
B=C). Let=PoA~Fyon8 €EB,y=79oA "FPoA =85 EC.We have FBE A
(since A 3 B) and Fy €A (since A 3 C). Hence, by A2a, one of F(8 A Fy),
F(FBA7), F(BA7) must belong to A. But this is impossible since all three
are easily seen (using 1.3g) to be inconsistent. m]

Turmning now to the Killing Lemma, consider a requirement of form 1.8a
which is alive for a certain p = (X, R, T) €M. We claim there is an extension
W' =(X', R, T') for which it is dead. This is proved by induction on the
number 7 of successors which x hasin (X, R). We fix an MCS B with T(x) 3 B
and y €B. If n =0, it suffices to define u' as was done in Section 2.1 above.

## Page 26

104 JOHN P. BURGESS

If n>0, let x' be the immediate successor of x in (X, R). We cannot have
Y ET(x') or else our requirement would already be dead for p. If Fy € T(x"),
we can reduce to the case n — 1 by replacing x by x'. So suppose Fy & T(x').
Then we have neither B = T(x") nor T(x')-3 B. Hence, by the Lemma, we
must have B -3 T(x"). Therefore it suffices to fix y € W-X and set:

X' =Xxu{y}
R = RU{(x»),(»,x)}V{(@¥):0Rx} U {(»,7):(xRo)}
T' = TU{(y,B)}.

In other words, we insert a point between x and x', assigning it the set B.
Requirements of form 1.8b are handled similarly, using a mirror image of the
Lemma, proved using (A2b). No further modifications in the work of Section
2.1 above are called for. o

The foregoing argument also establishes the following: Let Lyyee be the
extension of L, obtained by adding A2b as an extra axiom. Let F;ye be the
class of trees, defined for present purposes as those partial orders in which
the predecessors of any element are totally ordered. Then Ly, is complete
for #ree-

It is worth remarking that the following are valid over total orders:

FPp—>PpvpvFp, PFp->PpvpvFp.

To find deductions of them in L, is a nontrivial exercise. As a matter of fact,
these two items could have been used instead of (A2a, b) as axioms for total
orders. One could equally well have used their contrapositives:

HpApnaGp—GHp, HpApAGp—HGp.

The converses of these four items are valid over partial orders.

2.3. Extrema (Maxima, Minima)

2.4. No Extremals (No Maximals, No Minimals)

Let L; (resp. Ly) be the extension of L, obtained by adding (A3a, b) (resp.
(Ada, b)) as extra axioms. Let %; (resp. #3) be the class of total orders hav-
ing (resp. not having) a maximum and a minimum. Beyond understanding the
notions of consistency and MCS relative to L or L, as the case may be, no
modification in the work of Section 2.2 above is needed to prove Ly com-
plete for #; and L, for #;. The following observations suffice:

## Page 27

1L.2: BASIC TENSE LOGIC 105

On the one hand, understanding consistency and MCS relative to Ls, if
(X, R) is any total order and T any perfect. chronicle on it, then for any
X € X, either GL € T(x) itself, or FGL € T(x) and so GL € T() for some y
with xRy - this by (A3a). But if GL € T(z), then any w with zZRw would have
to have 1 € T(w), which is impossible, so z must be the maximum of (X, R).
Similarly, A3b guarantees the existence of a minimum in (X, R). o

On the other hand, understanding consistency and MCS relative to Ly, if
(X, R) is any total order and T any perfect chronicle on it, then for any
x €X we have GT > FT € T(x), and hence FT € T(x), so there must be a y
with (T € T(y) and) xRy - this by (A4a). Similarly, A4b guarantees that for
any x there is ay with yRx. ]

The foregoing argument also establishes that the extension of L, obtained
by adding (A4a, b) is complete for the class of partial orders having no
‘maximal or minimal elements.

It hardly needs saying that one can axiomatize the view (charateristic of
Western religious cosmologies) that Time had a beginning, but will have no
end, by adding (A3b) and (A4a) to L,.

2.5. Density

The extension Ls of L, obtained by adding (ASa) (or equivalently (A5b)) is
complete for the class ¥ of dense total orders. The main modification in the
work of Section 2.2 above needed to show this is that in addition to require-
ments of forms 1.8a, b we need to consider requirements of the form:

(e if xRy, then there exists a z with xRz and zRy.

To ‘kill’ such a requirement, given a coherent chronicle T on a finite total
order (X, R) and x, y € X with y immediately succeeding x, we need to be
able to insert a point z between x and y, and find a suitable MCS to assign
toz. For this the following suffices:

LEMMA: Let A, B be MCSs with A 3 B. Then there exists an MCS C with
A3CandC3B.

Proof. The problem quickly reduces to showing {Pa:a €4} U {FB:BE B}
consistent. For this it suffices to show that if a€A4 and BEB, then
F(Paun FB)EA. Now if BEB, then since A 3 B, FBE A, and by (ASa),
FFBE A. An appeal to 1.3¢ completes the proof. g

## Page 28

106 JOHN P. BURGESS

| HoesGHy
p‘/F e >PGp
~ SSep,
Tp
HPp
Fig. 1.
TABLEI

GGHp ~ GHp FGHp ~ GHp
GFHp ~ GHp FFHp ~ FHp
GPGp ~ Gp FPGp ~ FGp
GPHp =~ PHp FPHp =~ PHp
GFGp ~ FGp FFGp ~ FGp
GHPp ~ HPp FHPp ~ HPp
GGFp ~ GFp FGFp ~ GFp
GGPp ~ GPp FGPp =~ FPp
GHFp ~ GFp FHFp ~ Fp
GFPp ~ FPp FFPp ~ FPp

Similarly, the extension Lq of L, obtained by adding A4a, b and ASa is
complete for the class of dense total orders without maximum or minimum.
A famous theorem tells us that any countable order of this class is isomorphic
to the rational numbers in their usual order. Since our method of proof
always produces a countable frame, we can conclude that Lq is the tense
logic of the rationals. The accompanying diagram (Figure 1) indicates some
implications that are valid over dense total orders without maximum or
minimum, and hence theses of Lq; no further implications among the for-
mulas considered are valid. A theorem of C. L. Hamblin tells us that in Lq
any sequence of Gs, Hs, Fs and Ps prefixed to the variable p is provably
equivalent to one of the 15 formulas in our diagram. It obviously suffices
to prove this for sequences of length three. The reductions listed in the
accompanying Table I together with their mirror images, suffice to prove this.
It is a pleasant exercise to verify all the details.

## Page 29

11.2: BASIC TENSE LOGIC 107

2.6. Discreteness

The extension Lg of L, obtained by adding (A6a, b) is complete for the class
Hj of total orders in which every element has an immediate successor and an
immediate predecessor. The proof involves quite a few modifications in the
work of Section 2.2 above, beginning with:

LEMMA: For any MCS A there exists an MCS B such that:
(a) whenever Fy €A, theny vFy €B.
Moreover, any such MCS further satisfies:

(b) whenever P§ € B, then § vP§ €A,
(c) whenever A -3 C, then either B=CorB 3 C,
(d) whenever C 3 B, then either A = Cor C 3 A.

Proof. (a) The problem quickly reduces to proving the consistency of any
finite set of formulas of the forms Pa for € 4 and y vFy for Fy €A. To
establish this, one notes that the following is valid over total orders, hence a
thesis of (L, and a fortiori of) Ls:

FpoAFpyA...ANFp, >
F((PovFpo) A (PyVFPI)A ... A (D VEP,))

(b) We prove the contrapositive. Suppose 5 VP8 & A. By (A6a), FH—6 €A.
By part (a), H-~8 vFH—8 € B. But FHp - Hp is valid over total orders, hence
a thesis of (L, and a fortiori of) Ls. So H~8 €B and P5 & B as required.

(c) Assume for contradiction that 4 -3 C but neither B =C nor B3 C.
Then there exist a v €C with v, ¢ B and a v, €C with Fy, €B. Let
¥ =7 A7;. Then y € C and since 4 -3 C, Fy EA. But y vFy & B, contrary
to (a).

(d) Similarly follows from (b). a

We write A 3' B to indicate that A, B are related as in the above Lemma.
Intuitively this means that a situation of the sort described by 4 could be
immediately followed by one of the sort described by B.

We now take M to be the set of quadruples (X, R, S, T) where on the one
hand, as always X is a nonempty finite subset of W, R a total order on X, and
T a coherent chronicle on (X, R); while on the other hand, we have:

(d) whenever xSy, then y immediately succeeds x in (X, R),
(e) whenever xSy, then T(x) 3" T(y),

## Page 30

108 JOHN P. BURGESS

Intuitively xSy means that no points are ever to be added between x and y.
We say (X', R', S', T'") extends (X, R, S, T) if on the one hand, as always,
Definition 1.10a’, &', ¢ hold; while on the other hand, $ € ' In addition to
requirements of the forms 1.8a, b we need to consider requirements of the
forms:

(e) there exists a y with xSy,
(@) there exists a y with ySx.

To “kill’ a requirement of form (e), take an MCS B with T(x) 3'B. If x is the
maximum of (X, R) it suffices to fix z € W-X and set:

X' =Xxufz}, R' = RU{(x,2)}U{(v,2):vRx},
§'=85U{(x,2)}, T =TU{EB)}
Otherwise, let y immediately succeed x in (X, R). If B = T(p) set:

' =X, R =R,
S =SU{(x,y)} T =T.

Otherwise, we have B 3 T(»), and it suffices to fix z € W-X and set:

X' = XUz, R' = RU{(x,2),(z,»)}V
U {(v,2):vRx} U {(z,v):yRv},
§' =Su{(x2)} T =TU{@B)}

Similarly, to kill a requirement of form (f) we use the mirror image of the
Lemma above, proved using (A6b).

It is also necessary to check that when xSy we never need to insert a point
between x and y in order to kill a requirement of form 1.8a or b. Reviewing
the construction of Section 2.2 above, this follows from parts (c), (d) of the
Lemma above. The remaining details are left to the reader.

A total order is discrete if every element but the maximum (if any) has an
immediate successor, and every element but the minimum (if any) has an
immediate predecessor. The foregoing argument establishes that we get a
complete axiomatization for the tense logic of discrete total orders by adding
to L, the following weakened versions of (A6a, b):

pAHp->GLvFHp, pAGp—>HLvVPGp.

]

A total order is homogeneous if for any two of its points x, y there exists
an automorphism carrying x to y. Such an order cannot have a maximum or
minimum and must be either dense or discrete. In Burgess [1979] it is indi-
cated that a complete axiomatization of the tense logic is homogeneous orders

## Page 31

I1.2: BASIC TENSE LOGIC 109

is obtainable by adding to L, the following whict®should be compared with
AS5aand A6a, b:

(Fp > FFp) v[(q A Hq ~ FHq) A (q A Gq > PGq)].

2.7. Continuity

A cut in a total order (X, R) is a partition (Y, Z) of X into two nonempty
pieces, such that whenever y €Y and z €Z we have yRz. A gap is a cut
(Y, Z) such that Y has no maximum and Z no minimum. (X, R) is complete
if it has no gaps. The completion (X*, R*) of a total order (X, R) is the com-
plete total order obtained by inserting, for each gap (¥, Z) in (X, R), an
element w(Y, Z) after all elements of Y and before all elements of Z. For
example, the completion of the rational numbers in their usual order is the
real numbers in their usual order. The extension L, of L, obtained by adding
(AT7a, b) is complete for the class ¥; of complete total orders. The proof
requires a couple of Lemmas:

LEMMA: Let T be a perfect chronicle on a total order (X, R), and (Y, Z)a
gap in (X, R). Then if Ga € T(z) for all z €Z, then Ga € T(y) for some
yEY.

Proof. Suppose for contradiction that Ga € T\(z) for all z €Z but Fa~
~Ga€E€T(y) for all yEY. For any yo €Y we have F-~aa FGa € T().
Hence, by A7a, F(Gan HF—a) € T(,), and there is an x with yoRx and
Ga €EHF~a €T(x). But this is impossible, since if x €Y then Ga € T(x),
while if x €Z then HF-a & T(x). m]

LEMMA: Let T be a perfect chronicle on a total order (X, R). Then T can be
extended to a perfect chronicle T* on its completion (X*, R*).
Proof. For each gap (Y, Z) in (X, R), the set:

C(Y,2) = {Pa:3y EY(@ET(y)} U {Fa:3z €Z(a € T(2))}

is consistent. This is because any finite subset, involving only yy, ..., Vm
from Y and zy, ..., z, from Z will be contained in T(x) where x is any
element of Y after all the y; or any element of Z before all the z;. Hence, we
can define a coherent chronicle 7* on (X*, R*) by taking T*(w(Y, Z)) to be
some MCS extending C(Y, Z). Now if Fa € T*(w(Y, Z)), we claim that
Fa € T(z) for some z €Z. For if not, then G~a € T(z) for all z €Z, and by
the previous Lemma, G~a € T(y) for some y € Y. But then PG—a, which

## Page 32

110 JOHN P. BURGESS

implies ~Fa, would belong to C(Y, Z) € T*(w(Y, Z)), a contradiction. It
hardly needs saying that if Fa € T(z), then there is some x with zRx and a
fortiori w(Y,Z)R*x having a € T(x). This shows T* is prophetic. Axiom A7b
gives us a mirror image to the previous Lemma, which can be used to show
T* historic. [m}

To prove the completeness of L, for ¥, given a consistent v, use the
work of Section 2.2 above to construct a perfect chronicle T on a frame
(X, R) such that v, € T(x,) for some x,. Then use the foregoing Lemma to
extend to a perfect chronicle on a complete total order, as required to prove
satisfiability. a

Similarly, Ly, the extension of L, obtained by adding (A4a, b) and (ASa)
and (A7a, b) is complete for the class of complete dense total orders without
maximum or minimum, sometimes called continuous orders. As a matter of
fact, our construction shows that any formula consistent with this theory is
satisfiable in the completion of the rationals, that is, in the reals. Thus Ly, is
the tense logic of real time and, hence, of the time of classical physics.

2.8. Well-Orders

The extension Lg of L, obtained by adding A8 is complete for the class #g of
all well-orders. For the proof it is convenient to introduce the abbreviations
Ip for Ppvp vFp or ‘p sometime’, and Bp for p A—Pp or ‘p for the first
time’. An easy consequence of A8 is /p — IBp: If something ever happens,
then there is a first time when it happens. The reader can check that the
following are valid over total orders; hence, theses of (L, and a fortiori of
Ls):

(1) Ipalg~>IPoAq)vI(paq) vi(pAPq),
) 1(q A Fr).n I(PBp A Bq) > I(p A FY).

Now, understanding consistency, MCS, and related notions relative to Lg, let
8, be any consistent formula and D, any MCS containing it. Let 8y, ..., 8,
be all the proper subformulas of 8,. Let T' be the set of formulas of form

() A ()1 A A ()

where each &; appears once, plain or negated. Note that distinct elements of I'
are truth-functionally inconsistent. Let I' = {y €': Iy € D}. Note that for
each y €T we have IBy € Dy, and that for distinct v, v’ € I" we must by (1)

## Page 33

1L.2: BASIC TENSE LOGIC 111

have either I(PBy A By') or I(PBy' A By) in D,. Enumerate the elements of
' a5 Yo, V1, -+ Yn.s0 that I(PBy; A By;) €Dy iff i <j. We write i< if
I(y; A Fy;) € Do. This clearly holds whenever i <j, but may also hold in other
cases. A crucial observation is:

+) Ifi<j<k and k<li, thenj<qi

This follows from (2).

These tedious preliminaries out of the way, we will now define a set X of
ordinals and a function ¢ from X to I'. Let a, b, c, . .. range over positive
integers:

We put 0 € X and set #(0) = yo.

1f 0<1 0 we also put eacha € X and set #(a) = 7.

We put w € X and set {(w) = 7.

If 111 we also put each £ = w * b € X and set #(¢) = v,.

If 1<10 we also put each £ = w + b +a € X and set £(§) = yo.
We put w? € X and set {(w?) = 7,.

If 2<02 we also put each §=cw?-c€X and set #E)=7,.
If 2<I1 we also puteach £ = w?+ ¢ + w * b €X, and set 1(§) =v,.
If 2<10 we alse put each f=w? *c+w-b+a€X and set
E) =0

And so on.

Using (+) one sees that whenever én € X and & <n, then i<Ij where

t(¢)=1; and t(n) =1;. Conversely, inspection of the construction shows
that:

(a) whenever £ € X and #(¢) =; and j<I k, then there is an n € X
with§ <nand#(n) =17,

(b) whenever £ € X and #(§) =v; and i <j, then there is an n€ X
withn <% and t(n) =7;.

For £ € X let T(¥) be the set of conjuncts of #(£). Using (a) and (b) one sees

that T satisfies all the requirements 1.8a, b, c, d for a perfect chronicle, so far

as these pertain to subformulas of 8. Inspection of the proof of Lemma

1.9 then shows that this suffices to prove 8, satisfiable in the well-order

X, <. u}

Without entering into details here, we remark that variants of Lg provide
axiomatizations of the tense logics of the integers, the natural numbers, and
of finite total orders. In particular, for the natural numbers one uses L,,,, the

## Page 34

112 JOHNP. BURGESS

extension of L, obtained by adding A8 and p A Gp > HL vPGp. L,,, is the
tense logic of the notion of time appropriate for discussing the workings of a
digital computer, or of the mental mathematical constructions of Brouwer’s
‘creative subject’.

2.9. Lattices

The extension Ly of L, obtained by adding (A4a, b) and (A9a, b) is complete
for the class ¥; of partial orders without maximal or minimal elements in
which any two elements have an upper and a lower bound. We sketch the
modifications in the work of Section 2.2 above needed to prove this:
To begin with, we must revise clause 1.10b in the definition of M to read:
(bg) R isa partial order on X having a maximum and a minimum.
This necessitates revisions in the proof of the Killing Lemma, for which the
following will be useful:

LEMMA: Let A, B, C be MCSs. If A3 B and A 3 C, then there exists an
MCS D such that B-3 Dand C-3 D.

Proof. The problem quickly reduces to showing {§:GB € B} U {y:Gy € C}
consistent. For this it suffices (using 1.3d) to show that A v is consistent
whenever GBE B, Gy €C. Now in that case we have FGB, FGy € A, since
A 3B, C. By A9a, we then have GFB € A, and by 1.3b we then have F(FB A
Gy)€EA and FF(BAy)€EA, which suffices to prove Ay consistent as
required. [m)

Turning now to the Killing Lemma, trouble arises when for a given
(X, R, T) EM a requirement of form Definition 1.8a is to be ‘killed’ for some
X other than the maximum y of (X, R) and some Fy € T(x). Fixing an MCS B
with T(x) -3 B and y € B, and az € W-X, we would like to add z to x placing
it after x and assigning it the MCS B. But we cannot simply do this, else the
resulting partial order would have no maximum. (For y and z would be
incomparable.) So we apply the Lemma (with A = T(x), C = T(»)) to obtain
an MCS D with B-3 D and T(y) -3 D. We fix aw € W-X distinct from z, and
set:

X' =XUfz,w),
R = RU{(x,2),(z, W)} U{(v,2):0Rx} U {(v, w):vEX}.
T' = TU{(z,B),(w,D)}.

Similarly, a requirement of form 1.8b involving an element other than the

## Page 35

1.2: BASIC TENSE LOGIC 113

minimum is treated using the mirror image of the Lemma above, proved using
A9b.

Now given a formula 7, consistent with Lo, the construction of Definition
1.10 above produces a perfect chronicle T on a partial order (X, R) with
Yo € T(x,) for some x,. The work of Section 2.4 above shows that (X, R) will
have no maximal or minimal elements. Moreover, (X, R) will be a union of
partial orders (X, R,,) satisfying (by). Then any x, y € X will have an R-upper
bound and an R-lower bound, namely the R,-maximum and R,-minimum
elements of any X,, containing them both. Thus, (X, R) € ¥ and 7, is satis-
fiable over ;. [m}

A lattice is a partial order in which any two elements have a least upper
bound and a greatest lower bound. Actually, our proof shows that Ly is com-
plete for the class of lattices without maximum or minimum. It is worth
mentioning that A9a, b could have been replaced by:

FpAFq—>F(PoaPq),  PoaPq~P(FpnFg).

Weakened versions of these axioms can be used to give an axiomatization for
the tense logic of arbitrary lattices.

3. THE DECIDABILITY OF TENSE LOGICS

All the systems of tense logic we have considered so far are recursively
decidable. Rather than give an exhaustive (and exhausting) survey, we treat
here two examples, illustrating the two basic methods of proving decidability:
One method, borrowed from modal logic, is that of using so-called filtrations
to establish what is known as the finite model property. The other, borrowed
from model theory, is that of using so-called interpretations in order to be
able to exploit a powerful theorem of Rabin [1966].

3.1. THEOREM: L, is decidable.

Proof. Let % be the class of models of (B1) and (B9a, b); thus ¥ is like
Hq except that we do not require antisymmetry. Let %' be the class of
finite elements of #". It is readily verified that Ly is sound for % and a
fortiori for %" We claim that Lo is complete for %" This provides an effec-
tive procedure for testing whether a given formula a is a thesis of Lo or not, as
follows: Search simultaneously through all deductions in the system Ly and
through all members of "'~ or more precisely, of some nice countable sub-
class of %' containing at least one representative of each isomorphism-type.

## Page 36

114 JOHN P. BURGESS

Eventually one either finds a deduction of @, in which case « is a thesis, or
one finds an element of % 'in which —a is satisfiable, in which case by our
completeness claim, « is not a thesis.

To prove our completeness claim, let o be consistent with Ly. We showed
in Section 2.9 above how to construct a perfect chronicle T on a frame
(X, R) € Ky € X having v, € T(x,) for some x,. For x € X, let #(x) be the
set of subformulas of v, in T(x). Define an equivalence relation on Xby:

xoy iff  Hx)=1p).

Let [x] denote the equivalence class of x, X' the set of all [x]. Note that X"
is finite, having no more than 2% elements, where k is the number of sub-
formulas of . Consider the relations on X' defined by:

aR*b iff xRy forsomex Eaandy Eb,
aR'b  iff  for some finite sequence a=co,Cy, . ..,Cp-y,Cp =b
we have ¢;R*c;,, foralli<n.

Clearly R’ is transitive, while R* and, hence, R’ inherit from R the properties
expressed by B9a, b. Thus (X', R')E %" Define a function ¢’ on X' by let-
ting #'(@) be the common value of #(x) for all x €a. In particular for
ao = [xo] we have 7, €(ao). We claim that ¢ satisfies clauses 1.8a, b, ¢, d
of the definition of a perfect chronicle so far as these pertain to subformulas
of 7o As remarked in Section 2.8 above, this suffices to show 7, satisfiable in
(X', R") and, hence, satisfiable over ¥, as required.
In connection with Definition 1.8a, what we must show is:

(a) whenever Fy € #(a) there is a b with aR'b and y € t(b)

Well, let @ = [x], so Fy €t(x) € T(x). There is a y with xRy and y € #(y)
since T is prophetic. Letting b = [y] we have aR*b and so aR'b.
In connection with Definition 1.8¢ what we must show is:

(c')  whenever Gy €#(a) and aR'b, then y € #(b).
For this it clearly suffices to show:
(c*)  whenever Gy € t(a) and aR*b, then y € t(b) and Gy € #(b).

To show this, assuming the two hypotheses, fix x €a and y €b with xRy.
We have Gy €1(x) € T(x), so by Ala, GGy € T(x). Hence, y Et(y) and
Gy E€1(y), since T is coherent — which completes the proof.

Definitions 1.8b, d are treated similarly. o

## Page 37

I.2: BASIC TENSE LOGIC 115

3.2. THEOREM: Ly, is decidable.

Proof. We introduce an alternative definition of validity which is useful in
other contexts. To each tense-logical formula o we associate a first-order
formula & as follows: For a sentential variable p; we set p; = Py(x) where P; is
a one-place predicate variable. We then proceed inductively:

(-0)" =g,
@np)’ = anp
(Ga)” = Wy(x<y~>a(yhx),

(Ha)” = Vy(y <x-~>a(y/x)).

Here (y/x) represents the result of substituting for x the alphabetically first
variable y not occurring yet. Given a valuation ¥ in a frame (X, R) we have an
interpretation in the sense of first-order model theory, in which R interprets
the symbol < and ¥(p;) the symbol P;. Unpacking the definitions it is entirely
trivial that we always have:

(*) €V iff (X,R,V(po), V(p1), V(pa),.. )k alx),

Where [ is the usual satisfaction relation of model theory. We now further
define:

o* = VPGVP,. .. VP Vxi(x),

where po, Py, . . ., Py, include all the variables occurring in a. Note that ¢* is a
second-order formula of the simplest kind: It is monadic (all its second-order
variables are one-place predicate variables) and universal (consisting of a string
of universally-quantified second-order variables prefixed to a first-order
formula). It is entirely trivial that:

+) aisvalidin (X,R) iff (X,R)Ea*.

It follows that to prove the decidability of the tense logic of a given class ¥~
of frames it will suffice to prove the decidability of the set of universal
monadic (second-order) formulas true in all members of ¥~

Let 2<w be the set of all finite 0, 1-sequences. Let *0 be the function
assigning the argument s = (i, iy, . . ., i,) € 2<¢ the value s*0 = (ip, iy, . . . ,
ip, 0), and similarly for *1. Rabin proves the decidability of the set S2S of
monadic (second-order) formulas true in the structure (2<¢, x0, *1). He
deduces as an easy corollary the decidability of the set of-monadic formulas
true in the frame (Q, <) consisting of the rational numbers with their usual
order. This immediately yields the decidability of the system Lq of Section
2.5 above. Further corollaries relevant to tense logic are the decidability of

## Page 38

116 JOHN P. BURGESS

the set of monadic formulas true in all countable total orders, and similarly
for countable well-orders.

It only remains to reduce the decision problem for L, to that for Lg. The
work of 2.7 above shows that a formula « is satisfiable in the frame (R, <)
consisting of the real numbers with their usual order, iff it is satisfiable in the
frame (Q, <) by a valuation ¥ with the property:

1) V(o) = Q for every substitution instance & of A7a or b.
Inspection of the proof actually shows that it suffices to have:

? V(o) = Q where & is the conjunction of all instances of A7a or
b obtainable by substituting subformulas of « for vari-
ables.

A little thought shows that this amounts to demanding:
3) V(en GHe') # .

In other words, « is satisfiable in (R, <) iff & A GHo!' is satisfiable in (R, <),
which effects the desired reduction. For the lengthy original proof see Bull
[1969]. Other applications of Rabin’s theorem are in Gabbay [1975]. Rabin’s
proof uses automata-theoretic methods of Biichi; these are avoided by Shelah
[1975].

4. TEMPORAL CONJUNCTIONS AND ADVERBS

4A. Since, Until, Uninterruptedly, Recently, Soon

All the systems discussed so far have been based on the primitives ~, A, G, H.
It is well-known that any truth function can be defined in terms of -, A. Can
we say something comparable about temporal operators and G, H? When this
question is formulated precisely, the answer is a resounding NO.

4.1. DEFINITION: Let ¢ be a first-order formula having one free variable x
and no nonlogical symbols but the two-place predicate < and the one-place
predicates Py, .. ., P,. Corresponding to ¢ we introduce a new n-place con-
nective, the (first-order, one-dimensional) temporal operator O(p). We
describe the formal semantics of O(yp) in terms of the alternative approach of
Theorem 3.2 above: We add to the definition of ~ the clause:

O, - - . n)) = @l@/Py, ..., &n/Pn)

## Page 39

IL2: BASIC TENSE LOGIC 117

Here &/P denotes substitution of the formula & for the predicate variable P.
We then let formula (*) of Theorem 3.2 above define V() for formulas
involving O(p). Examples 4.2 below illustrate this rather involved definition.
If ={0(¢1), - .., O(gx)} is a set of temporal operators, an &-formula is
one built up from sentential variables using -, A, and elements of . A tem-
poral operator O(y) is O-definable over a class ¥ of frames if there is an
O-formula a such that O(g)(py, . .., Pp) <>« is valid over ¥. & is tem-
porally complete over ¥ if every temporal operator is ¢-definable over ¥
Note that the smaller ¥ is - it may consist of a single frame - the easier it is
to be temporally complete over it.

4.2. EXAMPLES:

1O WE<y->P0O),

(@) Vy(y <x->Py(3)),

3) y(x <y AVz(x <z Az <y =>Py(2))),

@) y(y <xaVz(y<zaz<x->Pyz))),

(%) y(x <y AP(Y)AVz(x <z nz <y =>Py2))),
(6) Iy(y <x APy(¥) A Vz(y <z Az <x > Py(2))).

For (1), O(y) is just G. For (2), O(y) is just H. For (3), O(p) will be written
G', and may be read ‘p is going to be uninterruptedly the case for some time’.
For (4), O(y) will be written H', and may be read ‘p has been uninterruptedly
the case for some time. For (5), O(p) will be written U, and U(p, q) may be
read ‘until p, ¢’; it predicts a future occasion of p’s being the case, up until
which g is going to be uninterruptedly the case. For (6), O(y) will be written
S, and S(p, q) may be read ‘since p,q’. In terms of G’ we define F' = ~G'~,
read ‘p is going to be the case arbitrarily soon’. In terms of H' we define
P =-H'-, read ‘p has been the case arbitrarily recently’. Over all frames, Gp
is definable as ~U(—p, T), and G' as U(T, p). Similarly, H and H' are defin-
able in terms of S. The following examples are due to H. Kamp:

4.3. PROPOSITION: G' is not G, H-definable over the frame (R, <).
Sketch of Proof. Define two valuations over that frame by:
V(p) = {0, 1,£2,£3,..}  W(p) = V(p)U{t},2}24,.. )

Then intuitively it is plausible, and formally it can be proved that for any G,
H-formula o we have 0 € V(a) iff 0 € W(a). But 0 € V(G'p) - W(G'p). o

## Page 40

118 JOHN P. BURGESS

4.4. PROPOSITION: U is not G, H, G', H'-definable over the frame (R, <).
Sketch of Proof. Define two valuations by:

V(p) = {+1,£2,£3,4,..} W(p) = {£2,%3,+4,..}
V(g) = W(g) = the union of the open intervals
ey (=5,—4),(=3,-2), (-1, +1),
(+2,+3),(+4,+5),...

Then intuitively it is plausible, and formally it can be proved that for any
G, H, G', H'-formula @ we have 0 € V(a) iff 0 € W(c). But 0 € V(U(p, q)) —
WU(p, 9)- o

Such examples might inspire pessimism, but Kamp [1968] proves:

4.5. THEOREM: The set {U, S} is temporally complete over continous
orders.

We will do no more than outline the difficult proof (in an improved ver-
sion due to Gabbay): Let ¢ be a set of temporal operators, % a class of
frames. An -formula « is purely past over ¥ if whenever (X, R) € ¥ and
x €K and V, W are valuations in (X, R) agreeing before x (so that for all i,
V(p;) N {y:yRx} = W(p;) N {y :yRx}) then x € V() iff x € W(a). Similarly,
one defines purely present and purely future, and one defines pure to mean
purely past, or present, of future. Note that Hp, H'p, S(p, q), are purely past,
their mirror images purely future, and any truth-functional compound of vari-
ables purely present. & has the separation property over ¥ if for every -
formula « there exists a truth-functional compound § of ¢-formulas pure
over ¥ such that a < f is valid over #. O is strong over ¥ if G, H are O-
definable over #. Gabbay [1983] proves:

4.6. CRITERION: Over any given class ¥ of total orders, if  is strong and
has the separation property, then it is temporally complete.

A full proof being beyond the scope of this survey, we offer a sketch: We
wish to find for any first-order formula p(x, <, Py, ..., P,) an J-formula
&Py, - .., Pn) representing it in the sense that for any (X, R) € # and any
valuation ¥ and any @ € X we have:

a€V(® iff (X.R.V(p..... V(p,)) E wla/x).
The proof procedes by induction on the depth of nesting of quantifiers in ¢,

## Page 41

11.2: BASIC TENSE LOGIC 119

the key step being ¢(x) = 3y¥(x, »). In this case, the atomic subformulas of
¥ are of the forms Py(x), Pi(z),z <x,z =x,x<z,z=w,z <w, where z and
w are variables other than x. Actually, we may assume there are no sub-
formulas of form Py(x) since these can be brought outside the quantifier 3y.
We introduce new singulary predicates Q~, Q°, Q* and replace the sub-
formulas of ¥ of forms z <x, z =x, x <z by 07(z), 0°(z), @*(z), to obtain
a formula 8(p, <, P, ...,P,, 0", 0% Q%) to which we can apply our induc-
tion hypothesis, obtaining an Zformula 8 (py, .. .,Pa, 47, ¢°, q*) represent-
ing it. Let ¥(p1, - .. ,Pa) =8Py, . . ., Pn, Fq,q, Pq),and =Py vy vFy. It
is readily verified that for any (X, R) € ¥ and any a, b € X and any valuation
V with V(q) = {a} that we have:

bEV(Y) iff (X,R,V(py),..., V(pa))F Y(alx, b]y),
a€V(p) iff (X,R,V(py),...,V(pn)Ewlalx).

By hypothesis, § is equivalent over ¥ to a truth-functional compound of
purely past formulas §;, purely present ones B, and purely future ones f;. In
each B; (resp. B7) (resp. Bi) replace g by L (resp. T) (resp. 1) to obtain an
O-formula a. 1t is readily verified that « represents .

It ‘only’ remains to show:

4.7. LEMMA: The set {U, S} has the separation property over complete
orders.

Though a full proof is beyond the scope of this survey, we sketch the
method for achieving separation for a formula « in which there is a single
occurrence of an S within the scope of a U. This case (and its mirror image) if
the first and most important in a general inductive proof.

To begin with, using conjunctive and disjunctive normal forms and such
easy equivalences as:

Ulp vq, 1) <> U(p, 1) vU(@, 1),
U(p,q ar) <> U(p,q) A Ulp, ),
=8(q,r) <= 8(-r,~q) vP'-r,
we can achieve a reduction to the case where  has one of the forms:
(a) U(p ~S(a, ), 1)
()  Up.anse,0)

For (a), an equivalent which is a truth-functional compound of pure
formulas is provided by:

## Page 42

120 JOHN P. BURGESS

@) [S@r)ve)aUp,rad] vU@AUlp,rat), 1)
For (b) we have:
®)  {SE, A vrIAUE, ) vUE, DI} VB

where B is: F'=t A U(p, q v S(r, 1)). This, despite its complexity, is purely
future. The observant reader should be able to see how completeness is
needed for the equivalence of (b) and (b').

Unfortunately, U and S take us no further, for Kamp proves:

4.8. PROPOSITION: The set {U, S} is not temporally complete over (@, <).

Without entering into details, we note that one undefinable operator is
O(p) where ¢ says:

Ppx<yaVzx<zaz<y->
(Yw(x <waw<z->P,(W)vVwiz<wa w<y->P,(w))))

Over complete orders O(p)(p, q) amounts to U(G'q A (p vq), p).
Recently J. Stavi has found two new operators U’, ' and proved:

4.9. THEOREM: The set {U, S, U', S'} is temporally complete over total
orders.

Gabbay has greatly simplified the proof: The idea is to try to prove the
separation property over arbitrary total orders, and see what operators one
needs. One quickly hits on the right U’, S'. The combinatorial details cannot
detain us here.

What about axiomatizability for U, S-tense logic? Some years ago Kamp
announced (but never published) finite axiomatizability for various classes of
total orders. Some are treated in Burgess [1982], where the system for dense
orders takes a particularly simple form: We depart from standard format only
to the extent of taking U, S as our primitives. As characteriztic axioms, it
suffices to take the following and their mirror images:

G(p > q) > (U(p,r) > Ulg, ) A (U, p) > UL, 9))

pAUg,r) > UlgnS(p,n, 1),

U(p, q) <= U(p, 4 A U(p, q)) <= Ulq A U(p, ), 9),

U(p,q) A —~U(p,r) > Ulg a -, q),

U(p, ) AU, ) > Upar,qns) vU(pAs, qas)vU@AT, qAs).
A particularly important axiomatizability result is in Gabbay et al. [1980].

## Page 43

1.2: BASIC TENSE LOGIC 121

What about decidability? Rabin’s theorem applies in most cases, the not-
able exceptions being complete orders, continuous orders, and (R, <). Here
techniques of monadic second-order logic are useful. Decidability for the
cases of complete and continuous orders is established in Gurevich [1977,
Appendix]; and for (R, <) in Burgess and Gurevich [to appear]. A fact (due to
Gurevich) from the latter paper worth emphasizing is that the U, S-tense
logics of (R, <) and of arbitrary continuous orders are not the same.

4B. Now, Then

We have seen that simple G, H-tense logic is inadequate to express certain
temporal operators expressible in English. Indeed it turns out to be inade-
quate to express even the shortest item in the English temporal vocabulary,
the word ‘now’. Just what role this word plays is unclear — some incautious
writers have even claimed it is semantically redundant - but Kamp [1971]
gives a thorough analysis. Let us consider some examples:

(0) The seismologist predicted that there would be an earthquake.

[63] The seismologist predicted that there would be an earthquake
now.

(@) The seismologist predicted that there would already have been an
earthquake before now.

3) The seismologist predicted that there would be an earthquake,
but not till after now.

As Kamp says:

The function of the word ‘now’ in (1) is to make the clause to which it applies - i.e.
‘there would be an earthquake’ - refer to the moment of utterance of (1) and not to the
moment of moments (indicated by other temporal modifiers that occur in the sentence)
to which the clause would refer (as it does in (0)) if the word ‘now’ were absent.

4.10. Formal Semantics

To formalize this observation, we introduce a new one-place connective J (for
jetzt). We define a pointed frame to be a frame with a designated element. A
valuation in a pointed frame (X, R, xo) is just a valuation in (X, R). We
extend the definition of 0.4 above to G, H, J-formulas by adding the clause:

Vo) = X ifxo€W(@), 9 ifxoV(a)

is valid in (X, R, x,) if xo € V(«) for all valuations V.

## Page 44

122 JOHN P. BURGESS

An alternative approach is to define a 2-valuation in a frame (X, R) to be
a function assigning each p; a subset of the Cartesian product X2 . Parallel to
0.4 above we have the following inductive definition:

V(~a) = X*—¥(a),

V(enB) = V(@) N V(p),

V(Ge) = {(x,»):Vx'(xRx' > (x', y) € V(@)},
V(Ha), similarly,

Vo) = {(x,):(»,») EV(e)}

isvalid in (X, R) if {(y,y):y € X} € V(o) for all 2-valuations V.

The two alternatives are related as follows: Given a 2-valuation ¥ in the
frame (X, R), for each y € X consider the valuation V', in the pointed frame
(X,R, ) given by V,(py) = {x:(x, ) € V(p;)}. Then we always have (y, y) €
V(a) iffy € Vy(a).

The second approach has the virtue of making it clear that though J is not
a temporal operator in the sense of the preceding section, it is in a sense that
can be made precise a two-dimensional tense operator. This suggests the
project of investigating two- and multi-dimensional operators generally. Some
such operators, for instance the ‘then’ of Vlach [1973], have a natural reading
in English. Among other items in our bibliography, Gabbay [1976] and
Gabbay and Guenthner [1982] contain much information on this topic.

Using J we can express (0)—(3) as follows:

o) P (seismologist says: F (earthquake occurs)),
(1')  P(seismologist says: J (earthquake occurs)),
(2')  P(seismologist says: JP (earthquake occurs)),
3" P (seismologist says: JF (earthquake occurs)).

The observant reader will have noted that (0')~(3') are not really represent-
able by G, H, J-formulas since they involve the notion of ‘saying’ or ‘predict-
ing’), a propositional attitude. Gabbay, too, gives many examples of uses of
‘now’ and related operators, and on inspection these, too, turn out to involve
propositional attitudes. That this is no accident is shown by the following
result of Kamp:

4.11. ELIMINABILITY THEOREM: For any G, H. J-formula « there is a
G, H-formula o* equivalent over all pointed frames.

Proof. Call a formula reduced if it contains no occurrence of aJ within the
scope of a G or an H. Our first step is to find for each formula & an equivalent
reduced formula ag. This is done by induction on the complexity of e, only

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