<!-- Source: Blackburn, de Rijke & Venema (2001). Modal Logic. Cambridge University Press. Front matter, Table of Contents, and Preface (pages viii-xx). BibKey: Blackburn2001 -->





Modal Logic
Patrick Blackburn
patrick@coli.uni-sb.de
Maarten de Rijke
mdr@wins.uva.nl
Yde Venema
yde@wins.uva.nl






For Johan






Contents
Preface
page viii
Basic Concepts
1.1
Relational Structures
1.2
Modal Languages
1.3
Models and Frames
1.4
General Frames
1.5
Modal Consequence Relations
1.6
Normal Modal Logics
1.7
Historical Overview
1.8
Summary of Chapter 1
Models
2.1
Invariance Results
2.2
Bisimulations
2.3
Finite Models
2.4
The Standard Translation
2.5
Modal Saturation via Ultraﬁlter Extensions
2.6
Characterization and Deﬁnability
2.7
Simulation and Safety
2.8
Summary of Chapter 2
Notes
Frames
3.1
Frame Deﬁnability
3.2
Frame Deﬁnability and Second-Order Logic
3.3
Deﬁnable and Undeﬁnable Properties
3.4
Finite Frames
3.5
Automatic First-Order Correspondence
3.6
Sahlqvist Formulas
3.7
More about Sahlqvist Formulas
v



vi
0 Contents
3.8
Advanced Frame Theory
3.9
Summary of Chapter 3
Notes
Completeness
4.1
Preliminaries
4.2
Canonical Models
4.3
Applications
4.4
Limitative Results
4.5
Transforming the Canonical Model
4.6
Step-by-step
4.7
Rules for the Undeﬁnable
4.8
Finitary Methods I
4.9
Finitary Methods II
4.10
Summary of Chapter 4
Notes
Algebras and General Frames
5.1
Logic as Algebra
5.2
Algebraizing Modal Logic
5.3
The J´onsson-Tarski Theorem
5.4
Duality Theory
5.5
General Frames
5.6
Persistence
5.7
Summary of Chapter 5
Notes
Computability and Complexity
6.1
Computing Satisﬁability
6.2
Decidability via Finite Models
6.3
Decidability via Interpretations
6.4
Decidability via Quasi-models and Mosaics
6.5
Undecidability via Tiling
6.6
NP
6.7
PSPACE
6.8
EXPTIME
6.9
Summary of Chapter 6
Notes
Extended Modal Logic
7.1
Logical Modalities
7.2
Since and Until
7.3
Hybrid Logic
7.4
The Guarded Fragment



Contents
vii
7.5
Multi-Dimensional Modal Logic
7.6
A Lindstr¨om Theorem for Modal Logic
7.7
Summary of Chapter 7
Notes
Appendix A
A Logical Toolkit
Appendix B
An Algebraic Toolkit
Appendix C
A Computational Toolkit
Appendix D
A Guide to the Literature
Bibliography
Index



Preface
Ask three modal logicians what modal logic is, and you are likely to get at least
three different answers. The authors of this book are no exception, so we won’t
try to start off with a neat deﬁnition. Nonetheless, a number of general ideas guide
our thinking about the subject, and we’ll present the most important right away
as a series of three slogans. These are meant to be read now, and, perhaps more
importantly, referred back to occasionally; doing so will help you obtain a ﬁrm
grasp of the ideas and intuitions that have shaped this book. Following the slogans
we’ll discuss the aims and content of the book in more detail.
Our ﬁrst slogan is the simplest and most fundamental. It sets the basic theme on
which the others elaborate:
Slogan 1: Modal languages are simple yet expressive languages for talk-
ing about relational structures.
In this book we will be examining various propositional modal languages: that is,
the familiar language of propositional logic augmented by a collection of modal
operators. Like the familiar boolean connectives (:,
^,
_,
!,
?, and
>), modal
operators do not bind variables. Thus, as far as syntax is concerned, we will be
working with the simplest non-trivial languages imaginable.
But in spite of their simplicity, propositional modal languages turn out to be an
excellent way of talking about relational structures, and this book is essentially an
attempt to map out some of the ramiﬁcations of this. For a start, it goes a long
way towards explaining the recent popularity of modal languages in applied logic.
Moreover, it introduces one of the fundamental themes in the mathematical study
of modal logic: the use of relational structures (that is, relational semantics, or
Kripke semantics) to explicate the logical structure of modal systems.
A relational structure is simply a set together with a collection of relations on
that set. Given the broad nature of this deﬁnition, it is unsurprising that relational
structures are to be found just about everywhere. Virtually all familiar mathe-
viii



Preface
ix
matical structures can be thought of as relational structures. Moreover, the enti-
ties commonly used to model the phenomena of interest in various applications
often turn out to be relational structures. For example, theoretical computer sci-
entists use labeled transition systems to model program execution, but a labeled
transition system is just a set (the states) together with a collection of binary re-
lations (the transition relations) that model the behavior of programs. Moreover,
relational structures play a fundamental modeling role in many other disciplines,
including knowledge representation, computational linguistics, formal semantics,
economics, and philosophy. As modal languages are the simplest languages in
which relational structures can be described, constrained, and reasoned about, it is
hardly surprising that applied modal logic has blossomed in recent years.
But relational structures have also played a fundamental role in the development
of the mathematics of modal logic: their use turned modal logic from a rather
esoteric branch of syntax manipulation into an concrete and intuitively compelling
ﬁeld. In fact, it is difﬁcult to overstate the importance of relational models to modal
logic: their (re)discovery in the late 1950s and early 1960s was the biggest single
impetus to the development of the ﬁeld. An early application was completeness
theory, the classiﬁcation of modal logics in relational terms. More recently, rela-
tional semantics has played an important role in mapping out the computational
complexity of modal systems.
Modal languages may be simple — but what makes them special? Our next slogan
tries to pin this down:
Slogan 2: Modal languages provide an internal, local perspective on rela-
tional structures.
That is, modal languages talk about relational structures in a special way: ‘from
the inside’ and ‘locally.’ Rather than standing outside a relational structure and
scanning the information it contains from some celestial vantage point, modal for-
mulas are evaluated inside structures, at a particular state. The function of the
modal operators is to permit the information stored at other states to be scanned
— but, crucially, only the states accessible from the current point via an appropri-
ate transition may be accessed in this way. This idea will be made precise in the
following chapter when we deﬁne the satisfaction deﬁnition. In the meantime, the
reader who pictures a modal formula as a little automaton standing at some state in
a relational structure, and only permitted to explore the structure by making jour-
neys to neighboring states, will have grasped one of the key intuitions of modal
model theory.
The internal perspective modal languages offer makes them natural for many
applications. For a start, the decidability of many important modal systems stems
from the local step-by-step way that modal formulas are evaluated. Moreover, in



x
Preface
a number of disciplines, description languages have been devised which offer an
internal perspective on relational structures; often these (independently invented)
systems have turned out to be variants of well-known modal systems, and can
be analyzed using modal techniques. For example, Kasper-Rounds logic (used in
computational linguistics) is essentially a natural notation for a certain fragment of
propositional dynamic logic with intersection, and many of the description logics
used in knowledge representation can be usefully viewed as (fragments of) modal
languages. Finally, it is also the stepwise way in which modal formulas are eval-
uated which explains why the notion of bisimulation, a crucial tool in the process
theoretic study of labeled transition systems, unlocks the door to important charac-
terizations of modal expressivity.
So far there have been only two characters in this discussion: modal languages and
the structures which interpret them. Now it is certainly true that for much of its
history modal logic was studied in isolation, but the true richness of the subject
only becomes apparent when one adopts a broader perspective. Accordingly, the
reader should bear in mind that:
Slogan 3: Modal languages are not isolated formal systems.
One of the key lessons to have emerged since about 1970 is that it is fruitful to
systematically explore the way modal logic is related to other branches of math-
ematical logic. In the pair
hMODAL LANGUAGES, RELATIONAL STRUCTURES
i,
there are two obvious variations that should be considered: the relationships with
other languages for describing relational structures, and the use of other kinds of
structures for interpreting modal languages.
As regards the ﬁrst option, there are many well-known alternative languages
for talking about relational structure: most obviously, ﬁrst- or second-order clas-
sical languages. And indeed, every modal language has corresponding classical
languages that describe the same class of structures. But although both modal
and classical languages talk about relational structures, they do so very differently.
Whereas modal languages take an internal perspective, classical languages, with
their quantiﬁers and variable binding, are the prime example of how to take an
external perspective on relational structures. In spite of this, there is a standard
translation of any modal language into its corresponding classical language. This
translation provides a bridge between the worlds of modal and classical logic, en-
abling techniques and results to be imported and exported. The resultant study is
called correspondence theory, and it is one of the cornerstones of modern modal
logic.
In the most important example of the second variation, modal logic is linked
up with universal algebra via the apparatus of duality theory. In this framework,
modal formulas are viewed as algebraic terms which have a natural algebraic se-



Preface
xi
mantics in terms of boolean algebras with operators, and, from this perspective,
modal logic is essentially the study of certain varieties of equational logic. Now,
even in isolation, this algebraic perspective is of interest — but what makes it a
truly formidable tool is the way it interacts with the perspective provided by re-
lational structures. Roughly speaking, relational structures can be constructed out
of algebras, and algebras can be constructed out of relational structures, and both
constructions preserve essential logical properties. The key technical result that
underlies this duality is the J´onsson-Tarski theorem, a Stone-like representation
theorem for boolean algebras with operators. This opens the door to the world of
universal algebra and, as we will see, the powerful techniques to be found there
lend themselves readily to the analysis of modal logic.
Slogan 3 is fundamental to the way the material in this book is developed: modal
logic will be systematically linked to the wider logical world by both correspon-
dence and duality theory. We don’t view modal logic as a ‘non-classical logic’ that
studies ‘intensional phenomena’ via ‘possible world semantics.’ This is one inter-
pretation of the machinery we will discuss — but the real beauty of the subject lies
deeper.
Let’s try and summarize our discussion. Modal languages are syntactically simple
languages that provide an internal perspective on relational structures. Because of
their simplicity, they are becoming increasingly popular in a number of applica-
tions. Moreover, modal logic is surprisingly mathematically rich. This richness
is due to the intricate interplay between modal languages and the relational struc-
tures that interpret them. At its most straightforward, the relational interpretation
gives us a natural semantic perspective from which to attack problems directly.
But the interplay runs deeper. By adopting the perspective of correspondence the-
ory, modal logic can be regarded as a fragment of ﬁrst- or second-order classical
logic. Moreover, by adopting an algebraic perspective, we obtain a different (and
no less classical) perspective: modal logic as equational logic. The fascination of
modal logic ultimately stems from the (still not fully understood) links between
these perspectives.
What this book is about
This book is a course in modal logic, intended for both novices and more experi-
enced readers, that presents modal logic as a powerful and ﬂexible tool for working
with relational structures. It provides a thorough grounding in the basic relational
perspective on modal logic, and applies this perspective to issues in completeness,
computability, and complexity. In addition, it introduces and develops in some
detail the perspectives provided by correspondence theory and algebra.
This much is predictable from our earlier discussion. However three additional



xii
Preface
desiderata have helped shape the book. First, we have attempted to emphasize the
ﬂexibility of modal logic as a tool for working with relational structures. One still
encounters with annoying frequency the view that modal logic amounts to rather
simple-minded uses of two operators
3 and
. This view has been out of date at
least since the late 1960s (say, since Hans Kamp’s expressive completeness result
for since/until logic, to give a signiﬁcant, if arbitrary, example), and in view of such
developments as propositional dynamic logic and arrow logic it is now hopelessly
anachronistic and unhelpful. We strongly advocate a liberal attitude in this book:
we switch freely between various modal languages and in the ﬁnal chapter we
introduce a variety of further ‘upgrades.’ And as far as we’re concerned, it’s all
just modal logic.
Second, two pedagogic goals have shaped the writing and selection of material:
we want to explicate a range of proof techniques which we feel are signiﬁcant and
worth mastering, and, where appropriate, we want to draw attention to some impor-
tant general results. These goals are pursued fairly single mindedly: on occasion,
a single result may be proved by a variety of methods, and every chapter (except
the following one) proves at least one very general and (we hope) very interesting
result. The reader looking for a catalogue of facts about his or her favorite modal
system probably won’t ﬁnd it here. But such a reader may well ﬁnd the technique
needed to algebraize it, to analyze its expressive power, to prove a completeness
result, or to establish its decidability or undecidability — and may even discover
that the relevant results are a special case of something known.
Finally, contemporary modal logic is profoundly inﬂuenced by its applications,
particularly in theoretical computer science. Indeed, some of the most interesting
advances in the subject (for example, the development of propositional dynamic
logic, and the investigation of modal logic from a complexity-theoretic standpoint)
were largely due to computer scientists, not modal logicians. Such inﬂuences must
be acknowledged and incorporated, and we attempt to do so.
What this book is not about
Modal logic is a broad ﬁeld, and inevitably we have had to leave out a lot of in-
teresting material, indeed whole areas of active research. There are two principle
omissions: there is no discussion of ﬁrst-order modal systems or of non-Hilbert-
style proof theory and automated reasoning techniques.
The ﬁrst omission is relatively easy to justify. First-order modal logic is an en-
terprise quite distinct from the study of propositional systems: its principle concern
is how best to graft together classical logic and propositional modal logic. It is an
interesting ﬁeld, and one in which there is much current activity, but its concerns
lie outside the scope of this book.
The omission of proof theory and automated reasoning techniques calls for a



Preface
xiii
little more explanation. A considerable proportion of this book is devoted to com-
pleteness theory and its algebraic ramiﬁcations; however, as is often the case in
modal logic, the proof systems discussed are basically Hilbert-style axiomatic sys-
tems. There is no discussion of natural deduction, sequent calculi, labeled deduc-
tive systems, resolution, or display calculi. A (rather abstract) tableau system is
used once, but only as a tool to prove a complexity result. In short, there’s little
in this book that a proof theorist would regard as real proof theory, and nothing
on implementation. Why is this? Essentially because modal proof theory and au-
tomated reasoning are still relatively youthful enterprises; they are exciting and
active ﬁelds, but as yet there is little consensus about methods and few general re-
sults. Moreover, these ﬁelds are moving fast; much that is currently regarded as
state of the art is likely to go rapidly out of date. For these reasons we have decided
— rather reluctantly — not to discuss these topics.
In addition to these major areas, there are a host of more local omissions. One
is provability and interpretability logic. While these are fascinating examples of
how modal logical ideas can be applied in mathematics, the principle interest of
these ﬁelds is not modal logic itself (which is simply used as a tool) but the formal
study of arithmetic: a typical introduction to these topics (and several excellent
ones exist, for example Boolos [66, 67], and Smory´nski [409]) is typically about
ten percent modal and ninety percent arithmetical. A second omission is a topic
that is a traditional favorite of modal logicians: the ﬁne structure of the lattice of
normal modal logics in the basic
3 and
2 language; we conﬁne ourselves in this
book to the relatively easy case of logics extending S4.3. The reader interested in
learning more about this type of work should consult Bull and Segerberg [73] or
Chagrov and Zakharyaschev [86]. Other omissions we regret include: a discussion
of meta-logical properties such as interpolation, a detailed examination of local
versus global consequence, and an introduction to the modal
-calculus and model
checking. Restrictions of space and time made their inclusion impossible.
Audience and prerequisites
The book is aimed at people who use or study modal logic, and more generally,
at people working with relational structures. We hope that the book will be of use
to two distinct audiences: a less experienced audience, consisting of students of
logic, computer science, artiﬁcial intelligence, philosophy, linguistics, and other
ﬁelds where modal logic and relational structures are of importance, and a more
experienced audience consisting of colleagues working in one or more of the above
research areas who would like to learn and apply modal logic in their own area.
To this end, there are two distinct tracks through this book: the basic track (this
consists of selected sections from each chapter, and will be described shortly) and
an advanced track (that is, the entire book).



xiv
Preface
The book starts at the beginning, and doesn’t presuppose prior acquaintance
with modal logic; but, even on the basic track, prior acquaintance with ﬁrst-order
logic and its semantics is essential. Furthermore, the development is essentially
mathematical and assumes that the reader is comfortable with such things as sets,
functions, relations and so on, and can follow mathematical argumentation, such as
proofs by induction. In addition, although we have tried to make their basic track
material as self contained as possible, two of the later chapters probably require a
little more background knowledge than this. In particular, a reader who has never
encountered boolean (or some other) algebras before is likely to ﬁnd Chapter 5
hard going, and the reader who has never encountered the concept of computable
and uncomputable functions will ﬁnd Chapter 6 demanding. That said, only a
relatively modest background knowledge in these areas is required to follow the
basic track material; certainly the main thrust of the development should be clear.
The requisite background material in logic, algebra and computability can be found
in Appendices A, B, and C.
Needless to say, we have also tried to make the advanced track material as read-
able and understandable as possible. However, largely because of the different
kinds of background knowledge required in different places, advanced track read-
ers may sometimes need to supplement this book with a background reading in
model theory, universal algebra or computational complexity. Again, the required
material is sketched in the appendices.
Contents
The chapter-by-chapter breakdown of the material is as follows.
Chapter 1. Basic Concepts. This chapter introduces a number of key modal lan-
guages (namely the basic modal language, modal languages of arbitrary similarity
type, the basic temporal language, the language of propositional dynamic logic,
and arrow languages), and shows how they are interpreted on various kinds of re-
lational structures (namely models, frames and general frames). It also establishes
notation, discusses some basic concepts such as satisfaction, validity, logical con-
sequence and normal modal logics, and places them in historical perspective. The
entire chapter is essentially introductory; all sections lie on the basic track.
Chapter 2. Models. This chapter examines modal languages as tools for talking
about models. In the ﬁrst ﬁve sections we prove some basic invariance results,
introduce bisimulations, discuss the use of ﬁnite models, and, by describing the
standard translation, initiate the study of correspondence theory. All ﬁve sections
are fundamental to later developments — indeed the sections on bisimulations and
the standard translation are among the most important in the entire book — and



Preface
xv
together they constitute the basic track selection. The remaining two sections are
on the advanced track. They probe the expressive power of modal languages using
ultraﬁlter extensions, ultraproducts, and saturated models; establish the fundamen-
tal role of bisimulations in correspondence theory; and introduce the concepts of
simulation and safety.
Chapter 3. Frames. This chapter examines modal languages as tools for talk-
ing about frames; all sections, save the very last, lie on the basic track. The ﬁrst
three sections develop the basic theory of frame correspondence: we give exam-
ples of frame deﬁnability, show that relatively simple modal formulas can deﬁne
frame conditions beyond the reach of any ﬁrst-order formula (and explain why
this happens), and introduce the concepts needed to state the celebrated Goldblatt-
Thomason theorem. After a short fourth section which discusses ﬁnite frames, we
embark on the study of the Sahlqvist fragment. This is a large class of formulas,
each of which corresponds to a ﬁrst-order frame condition, and we devote three
sections to it. In the ﬁnal (advanced) section we introduce some further frame
constructions and prove the Goldblatt-Thomason theorem model theoretically.
Chapter 4. Completeness. This chapter has two parts; all sections, save the very
last, lie on the basic track. The ﬁrst part, consisting of the ﬁrst four sections, is an
introduction to basic completeness theory (including canonical models, complete-
ness-via-canonicity proofs, canonicity failure, and incompleteness). The second
part is a survey of methods that can be used to show completeness when canonic-
ity fails. We discuss transformation methods, the step-by-step technique, the use
of rules for the undeﬁnable, and devote the ﬁnal two sections to a discussion of
ﬁnitary methods. The ﬁrst of these sections proves the completeness of Proposi-
tional Dynamic Logic (PDL). The second (the only section on the advanced track)
examines extensions of S4.3, proving (among other things) Bull’s Theorem.
Chapter 5. Algebras and General Frames. The ﬁrst three sections lie on the ba-
sic track: we discuss the role of algebra in logic, show how algebraic ideas can
be applied to modal logic via boolean algebras with operators, and then prove the
fundamental J´onsson-Tarski theorem. With the basics thus laid we turn to duality
theory, which soon leads us to an algebraic proof of the Goldblatt-Thomason the-
orem (which was proved model theoretically in Chapter 3). In the two remaining
sections (which lie on the advanced track) we discuss general frames from an al-
gebraic perspective, introduce the concept of persistence (a generalization of the
idea of canonicity) and use it to prove the Sahlqvist Completeness Theorem, the
completeness-theoretic twin of the correspondence result proved in Chapter 3.



xvi
Preface
Chapter 6. Computability and Complexity. This chapter has two main parts. The
ﬁrst, comprising the ﬁrst ﬁve sections, is an introduction to decidability and un-
decidability in modal logic. We introduce the basic ideas involved in computing
modal satisﬁability and validity problems, and then discuss three ways of proving
decidability results: the use of ﬁnite models, the method of interpretations, and
the use of quasi-models and mosaics. The ﬁfth section gives two simple exam-
ples which illustrate how easily undecidable — and indeed, highly undecidable —
modal logics can arise. All of the ﬁrst part lies on the basic track. The remaining
three sections examine modal logic from the perspective of computational com-
plexity. In particular, the modal relevance of three central complexity classes (NP,
PSPACE, and EXPTIME) is discussed in some detail. We pay particular attention
to PSPACE, proving Ladner’s general PSPACE-hardness result in detail. These
sections lie on the advanced track, but this is partly because computational com-
plexity is likely to be a new subject for some readers. The material is elegant and
interesting, and we have tried to make these sections as self-contained and acces-
sible as possible.
Chapter 7. Extended Modal Logic. This chapter has a quite different ﬂavor from
the others: it’s essentially the party at the end of the book in which we talk about
some of our favorite examples of extended modal systems. We won’t offer any
advice about what to read here — simply pick and choose and enjoy. The topics
covered are: boosting the expressive power of modal languages with the aid of log-
ical modalities, performing evaluation at sequences of states in multi-dimensional
modal logic, naming states with the help of hybrid logics, and completeness-via-
completeness proofs in since/until logic. We also show how to export modal ideas
back to ﬁrst-order logic by deﬁning the guarded fragment, and conclude by proving
a Lindstr¨om Theorem for modal logic.
Nearly all sections end with exercises. Each chapter starts with a chapter guide out-
lining the main themes of the sections that follow. Moreover, each chapter ﬁnishes
with a summary, and — except the ﬁrst — with a section entitled Notes. These give
references for results discussed in the text. (In general we don’t attribute results in
the text, though where a name has become ﬁrmly attached — for example, Bull’s
Theorem or Lindenbaum’s Lemma — we use it.) The Notes also give pointers to
relevant work not covered in the text. The ﬁnal section of Chapter 1 sketches the
history of modal logic, and Appendix D gives a brief guide to textbooks, survey
articles, and other material on modal logic.
Teaching the book
The book can be used as the basis for a number of different courses. Here are some
suggestions.



Preface
xvii
Modal Logic and Relational Structures. (1 Semester, 2 hours a week)
All of Chapter 1, all the basic track sections in Chapter 2, and all the basic track
sections in Chapter 3. This course introduces modal logic from a semantically ori-
ented perspective. It is not particularly technical (in fact, only Section 2.5 is likely
to cause any difﬁculties), and the student will come away with an appreciation of
what modal languages are and the kind of expressivity they offer. It’s deliberately
one-sided — it’s intended as an antidote to traditional introductions.
An Introduction to Modal Logic. (1 Semester, 4 hours a week)
All of Chapter 1, all the basic track material in Chapter 2, the ﬁrst six or seven
sections of Chapter 3, the ﬁrst six or seven sections of Chapter 4, and the ﬁrst four
sections of Chapter 6. In essence, this course adds to the previous one the contents
of a traditional introduction to modal logic (namely completeness-via-canonical
models, and decidability-via-ﬁltrations) and includes extra material on decidability
which we believe should become traditional. This course gives a useful and fairly
balanced picture of many aspects of modern modal logic.
Modal Logic for Computer Scientists. (1 Semester, 4 hours a week)
All of Chapter 1, the ﬁrst four sections of Chapter 2, the ﬁrst four sections of
Chapter 3, the ﬁrst four sections of Chapter 4 plus Section 4.8 (completeness of
PDL), all of Chapter 6, and a selection of topics from Chapter 7. In our opinion,
this course is more valuable than the previous one, and in spite of its title it’s not
just for computer science students. This course teaches basic notions of modal
expressivity (bisimulation, the standard translation, and frame deﬁnability), key
ideas on completeness (including incompleteness), covers both computability and
complexity, and will give the student an impression of the wide variety of options
available in modern modal logic. It comes close to our ideal of what a modern,
well-rounded, introduction to modal logic should look like.
Mathematical Aspects of Modal Logic. (1 Semester, 4 hours a week)
Chapter 1, 2, and 3, the ﬁrst four sections of Chapter 4, and all of Chapter 5. If
you’re teaching logicians, this is probably the course to offer. It’s a demanding
course, and requires background knowledge in both model theory and algebra, but
we think that students with this background will like the way the story unfolds.
Modal Logic. (2 Semesters, 4 hours a week)
But of course, there’s another option: teach the whole book. Given enough back-
ground knowledge and commitment, this is do-able in 2 semesters. Though we
should confess right away that the course’s title is highly misleading: once you
get to the end of the book, you will discover that far from having learned every-



xviii
Preface
thing about modal logic, you have merely arrived at the beginning of an unending
journey . . .
2.1–2.5
2.6
2.7
3.7
3.1–3.6
3.8
4.1–4.8
4.9
5.6
5.5
5.1–5.4
6.1–6.5
6.6
6.7
6.8
7.1–7.6
Fig. 1. Dependency Diagram
Hopefully these suggestions will spark further ideas. There is a lot of material here,
and by mixing and matching, perhaps combined with judicious use of other sources
(see Appendix D, the Guide to the Literature, for some suggestions) the instructor
should be able to tailor courses for most needs. The dependency diagram (see
Figure 1) will help your planning.
Electronic support
We have set up a home page for this book, where we welcome feedback, and where
we will make selected solutions to the exercises and teaching materials available,
as well as any corrections that may need to be made. The URL is
http://www.mlbook.org
Acknowledgments
We want to thank the following colleagues for their helpful comments and useful
suggestions: Carlos Areces, Johan van Benthem, Giacomo Bonanno, Jan van Eijck,
Joeri Engelfriet, Paul Gochet, Rob Goldblatt, Val Goranko, Ian Hodkinson, Ramon
Jansana, Theo Janssen, Tim Klinger, Johan W. Kl¨uwer, Holger Schlingloff, Moshe
Vardi, and Rineke Verbrugge. Special thanks are due to Maarten Marx who worked



Preface
xix
through earlier incarnations of Chapter 6 in great detail; his comments transformed
the chapter. We are also grateful for the detailed comments Ian Hodkinson made
on a later version of this chapter. We are also extremely grateful to Costas Koutras
for his extensive comments based on his experience of teaching the book.
We had the good fortune of being able to try out (parts of) the material on stu-
dents in Amsterdam, Barcelona, Braga, Budapest, Cape Town, Chiba, Chia-Yi,
Johannesburg, Lisbon, Saarbr¨ucken, Utrecht and Warwick. We want to thank all
our students, and in particular Maarten Stol, and the students of the 1999 and 2000
Amsterdam classes on modal logic.
We would like to thank our editor, David Tranah, for his support and advice, and
the anonymous referees for their valuable feedback.
We began the book when we were employed by the Netherlands Organization
for Scientiﬁc Research (NWO), project 102/62-356 ‘Structural and Semantic Par-
allels in Natural Languages and Programming Languages.’ We are grateful for the
ﬁnancial support by NWO. During the later stages of the writing, Patrick Black-
burn was based at the Department of Computational Linguistics at the University of
Saarland, Maarten de Rijke was supported by the Spinoza project ‘Logic in Action’
at ILLC, the University of Amsterdam, and Yde Venema by a fellowship of the
Royal Netherlands Academy of Arts and Sciences, and later, also by the Spinoza
project ‘Logic in Action’. We also want to thank the Department of Mathematics
and Computer Science of the Free University in Amsterdam for the facilities they
provided.
Patrick Blackburn
Maarten de Rijke
Yde Venema



Basic Concepts
Languages of propositional modal logic are propositional languages to which sen-
tential operators (usually called modalities or modal operators) have been added.
In spite of their syntactic simplicity, such languages turn out to be useful tools for
describing and reasoning about relational structures. A relational structure is a
non-empty set on which a number of relations have been deﬁned; they are wide-
spread in mathematics, computer science, artiﬁcial intelligence and linguistics, and
are also used to interpret ﬁrst-order languages.
Now, when working with relational structures we are often interested in struc-
tures possessing certain properties. Perhaps a certain transitive binary relation is
particularly important. Or perhaps we are interested in applications where ‘dead
ends,’ ‘loops,’ and ‘forkings’ are crucial, or where each relation is a partial func-
tion. Wherever our interests lie, modal languages can be useful, for modal oper-
ators are essentially a simple way of accessing the information contained in rela-
tional structures. As we will see, the local and internal access method that modali-
ties offer is strong enough to describe, constrain, and reason about many interesting
and important aspects of relational structures.
Much of this book is essentially an exploration and elaboration of these remarks.
The present chapter introduces the concepts and terminology we will need, and the
concluding section places them in historical context.
Chapter guide
Section 1.1: Relational Structures. Relational structures are deﬁned, and a num-
ber of examples are given.
Section 1.2: Modal Languages. We are going to talk about relational structures
using a number of different modal languages. This section deﬁnes the
basic modal language and some of its extensions.
Section 1.3: Models and Frames. Here we link modal languages and relational
structures. In fact, we introduce two levels at which modal languages can



1 Basic Concepts
be used to talk about structures: the level of models (which we explore
in Chapter 2) and the level of frames (which is examined in Chapter 3).
This section contains the fundamental satisfaction deﬁnition, and deﬁnes
the key logical notion of validity.
Section 1.4: General Frames. In this section we link modal languages and rela-
tional structures in yet another way: via general frames. Roughly speak-
ing, general frames provide a third level at which modal languages can be
used to talk about relational structures, a level intermediate between those
provided by models and frames. We will make heavy use of general frames
in Chapter 5.
Section 1.5: Modal Consequence Relations. Which conclusions do we wish to
draw from a given a set of modal premises? That is, which consequence
relations are appropriate for modal languages? We opt for a local conse-
quence relation, though we note that there is a global alternative.
Section 1.6: Normal Modal Logics. Both validity and local consequence are de-
ﬁned semantically (that is, in terms of relational structures). However, we
want to be able to generate validities and draw conclusions syntactically.
We take our ﬁrst steps in modal proof theory and introduce Hilbert-style
axiom systems for modal reasoning. This motivates a concept of central
importance in Chapters 4 and 5: normal modal logics.
Section 1.7: Historical Overview. The ideas introduced in this chapter have a long
and interesting history. Some knowledge of this will make it easier to
understand developments in subsequent chapters, so we conclude with a
historical overview that highlights a number of key themes.
