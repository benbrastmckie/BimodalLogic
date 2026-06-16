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
