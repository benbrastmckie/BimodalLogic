// ============================================================================
// FormalFoundations.typ
// Formal Foundations of Bimodal TM Logic: Completeness and Representation
//
// A standalone research report on the formal foundations of the bimodal logic
// TM: a compressed system overview, the three pain points of the axiomatization
// (temporal-axiom contingency, split-validity incompleteness, the axiomatization
// of the strongest objective modality), the completeness construction as
// actually implemented in FormalSystem/Metalogic/, and a reasoned outline of
// the way forward toward a general representation theorem.
//
// This document is NOT a chapter of BimodalReference.typ and is not #include'd
// by it. It imports the book's notation and template modules so that notation
// cannot drift between this report and the book, and cites the book's shared
// bibliography.
// ============================================================================

// Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
// Released under Apache 2.0 license as described in the file LICENSE.

// ============================================================================
// Package Imports
// ============================================================================

#import "@preview/cetz:0.3.4"

// Local notation and template (includes thmbox theorem environments)
#import "notation/bimodal-notation.typ": *
#import "template.typ": thmbox-show, URLblue, definition, theorem, lemma, axiom, remark, proof, corollary, proposition

// ============================================================================
// Document Configuration -- matches BimodalReference.typ's type settings
// verbatim, so a "~10 pages of body text" budget is measured on the same
// scale as the book.
// ============================================================================

#set document(
  title: "Formal Foundations of Bimodal TM Logic: Completeness and Representation",
  author: "Benjamin Brast-McKie",
)

#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(
  justify: true,
  leading: 0.55em,
  spacing: 0.55em,
  first-line-indent: 1.8em,
)

#set page(
  numbering: "1",
  number-align: center,
  margin: 1.75in,
)

#show heading: set block(above: 1.4em, below: 1em)

// Automatically bold "TM" throughout the document, matching the book.
#show "TM": strong

// ============================================================================
// Theorem Environment Initialization
// ============================================================================

#show: thmbox-show

#show link: set text(fill: URLblue)
#show figure.where(kind: "thmbox"): set block(breakable: true)

#let HRule = line(length: 100%, stroke: 0.5pt)

// ============================================================================
// Title Block
// ============================================================================

#align(center)[
  #HRule
  #v(0.3cm)
  #text(size: 18pt, weight: "bold")[Formal Foundations of Bimodal TM Logic]
  #v(0.15cm)
  #text(size: 13pt, style: "italic")[Completeness and Representation]
  #v(0.3cm)
  #HRule
  #v(0.4cm)
  #text(size: 11pt, style: "italic")[Benjamin Brast-McKie]
  #v(0.1cm)
  --- #datetime.today().display("[month repr:long] [day], [year]") ---
]

#v(0.6cm)

*Abstract.*
This report states, precisely and compressed, what is actually proved about the bimodal logic
*TM* -- a fusion of S5 metaphysical modality with a Burgess--Xu tense logic over task-frame
semantics -- what is not, and what it would take to close the gap. Section 1 compresses the
system; Section 2 states the load-bearing theorems and the exact completeness and decidability
status, unsoftened. Sections 3-5 are the three genuine pain points of the axiomatization: the
metaphysical contingency of the temporal axioms, a sharp split-validity incompleteness result for
*TM* itself, and the higher-order cost of axiomatizing the strongest objective modality. Section 6
gives an honest, measured account of the completeness construction as it is actually implemented
in this repository's Lean 4 development, and Section 7 closes with the early steps toward a
representation theorem and a reasoned outline of the way forward for a general, weaker base
bimodal logic assuming neither density nor discreteness nor Dedekind-completeness.

#v(0.3cm)

= The System, Compressed <sec:system>

== Languages

The base language is $#taskframe = chevron.l "SL", bot, arrow.r, square.stroked, allpast, allfuture chevron.r$ where $"SL" := {p_i : i in NN}$#footnote[`sub:Logic` (untracked prose, cited by key only -- no environment block exists at this site to quote). @brastmckie2026possibleworlds] -- one-place *Past* ($#allpast$) and *Future* ($#allfuture$) as primitives, alongside classical connectives and the S5 necessity operator $square.stroked$.
The extended language replaces $#allpast$/$#allfuture$ with binary *Since* / *Until*:

$op("BL")^+ = chevron.l "SL", bot, arrow.r, square.stroked, S, U chevron.r$, with $S(phi.alt, psi)$ ("$psi$ since $phi.alt$") and $U(phi.alt, psi)$ ("$psi$ until $phi.alt$") in the Burgess *event-first* convention: $phi.alt$ is the event, true at some witness time, $psi$ the guard, true throughout the intervening interval.#footnote[`def:BLplus-language`. @brastmckie2026possibleworlds]

$#allpast, #allfuture, #somepast, #somefuture, #always, #sometimes$ and the propositional connectives are then *defined* operators of $op("BL")^+$#footnote[`def:BLplus-defined`. @brastmckie2026possibleworlds] (e.g. $#allfuture phi.alt := not U(not phi.alt, top)$), and $op("BL")$ embeds into $op("BL")^+$ unconditionally: every $op("BL")$-theorem is recovered under the Past/Future reduction.#footnote[`thm:BLplus-PastFuture` (untracked, cited by key). @brastmckie2026possibleworlds] Over discrete frames, $op("BL")^+$ additionally defines *Next* / *Previous* operators witnessing the immediate successor/predecessor.#footnote[`thm:BLplus-NextPrevious` (untracked, cited by key). @brastmckie2026possibleworlds]

== Task-Frame Semantics

A *temporal order* is a nontrivial totally ordered abelian group $#Dur = (D, +, 0, lt.eq)$ with *positive cone* $D^+ := {x in D : x gt.eq 0}$.#footnote[`def:temporal-order`. @brastmckie2026possibleworlds] A *task relation* on world states $#worldstate$ over $#Dur$ is $w arrow.r.double.long_(x) u$ for $x in D^+$, extended by the *converse convention* $w arrow.r.double.long_(-x) u := u arrow.r.double.long_(x) w$; it determines the fiber $"Fib"(w,x) := {u : w arrow.r.double.long_(x) u}$, cone $(w)_x := union.big_(|y|<x) "Fib"(w,y)$, and segment $[w,v]_x^y := "Fib"(w,x) inter "Fib"(v,-y)$.#footnote[`def:task-relation`. @brastmckie2026possibleworlds]

#definition("Frame")[
  A *frame* $#taskframe = (#worldstate, #Dur, arrow.r.double.long_(dot.c))$ satisfies, for $x, y gt.eq 0$: *Compositionality* (biconditional) $w arrow.r.double.long_(x+y) v$ iff $w arrow.r.double.long_(x) u$ and $u arrow.r.double.long_(y) v$ for some $u$; *Seriality*: some $u,v$ have $w arrow.r.double.long_(x) u$, $v arrow.r.double.long_(x) w$; *Limit*: $inter.big_(x>0) (w)_x = {w}$; *Spherical*: $inter.big cal(S) eq.not emptyset$ for any directed family $cal(S)$#footnote[`def:directed`. @brastmckie2026possibleworlds] of nonempty fibers and segments.
]#footnote[`def:frame` (all four sub-anchors), a biconditional load-bearing in both directions. @brastmckie2026possibleworlds]

Nullity ($w arrow.r.double.long_(0) w$ for every $w$, every frame) is *derived* from Seriality (at $x=0$) and Limit, not a fifth axiom.#footnote[`lem:nullity`, derived, choice-free. @brastmckie2026possibleworlds]

A *partial history* over $#taskframe$ is $tau : X arrow.r #worldstate$ on nonempty $X subset.eq D$ with $tau(x) arrow.r.double.long_(y-x) tau(y)$; a *world history* has convex domain; a world history is *total* -- equivalently a *possible world* -- iff $X = D$, and $H_(#taskframe)$ denotes all total world histories.#footnote[`def:world-history`. @brastmckie2026possibleworlds] Every partial history extends to a total world history (`thm:extension`, Zorn's lemma), hence to a world state occurring at any prescribed time (`cor:occurrence`) -- both ZFC results, unlike Nullity's choice-free derivation; a *finite*-$W$ frame satisfies *Spherical* choice-free instead (`cor:spherical-finite`).#footnote[@brastmckie2026possibleworlds Both tracked.]

A model $#model = (#worldstate, #Dur, arrow.r.double.long_(dot.c), |dot.c|)$ interprets atoms $|p| subset.eq H_(#taskframe) times D$; $#model, tau, x #satisfies square.stroked phi.alt$ iff $#model, sigma, x #satisfies phi.alt$ for every $sigma in H_(#taskframe)$ -- $square.stroked$ quantifies over *all* total world histories.#footnote[`def:BL-model`, `def:BL-semantics` (box clause). @brastmckie2026possibleworlds] Frame validity ($#taskframe #satisfies phi.alt$), logical consequence ($Gamma #satisfies phi.alt$), and global validity ($#satisfies phi.alt$) close the semantic layer.#footnote[`def:frame-validity`, `def:logical-consequence`. @brastmckie2026possibleworlds]

== Proof Systems

#definition("S5")[The smallest CPL-extension closed under MK, MT, M5, MP, MN.]#footnote[`def:S5`. @brastmckie2026possibleworlds]

#definition("BX")[The *Base Burgess--Xu Tense Logic*: TN, TD (temporal necessitation, past/future duality); the seriality/linearity/connectedness triple TB, TL, CN; the primary Since/Until axioms TA, UE, UT, UI, UC, UF, UG, SU; and uniformity axioms NP, NF, NA, NB, vacuous unless discrete.]#footnote[`def:BX`. @brastmckie2026possibleworlds]

$op("TM")^+$, the base logic for $op("BL")^+$, is $"S5" + "BX" + "MF"$ ($square.stroked phi.alt arrow.r square.stroked #allfuture phi.alt$), with discrete/dense/complete extensions adding the axioms distinguishing $op("BX")_f$/$op("BX")_d$/$op("BX")_c$:

#figure(
  table(
    columns: 2, stroke: none, align: (left,left),
    table.hline(), table.header([*System*],[*Additional axioms*]), table.hline(),
    [$op("BX")_f$ / $op("TM")^+_f$], [UZ, Z1 (backward induction; successor-Archimedean, i.e. $ZZ$-time, by Hölder)],
    [$op("BX")_d$ / $op("TM")^+_d$], [DN ($#allfuture#allfuture phi.alt arrow.r #allfuture phi.alt$), NN ($not "Next"top$)],
    [$op("BX")_c$ / $op("TM")^+_c$], [Prior-U, Sep (the *Reynolds triple*, with Prior-S the TD-mirror of Prior-U); CO is a *derived theorem* from Prior-U alone, not a further axiom],
    table.hline(),
  ),
  caption: [The three frame-class extensions of $op("TM")^+$.],
)#footnote[`def:TMplus-f`, `def:TMplus-d`, `def:TMplus-c`, `def:TMplus`. @brastmckie2026possibleworlds Whether TMP-CO alone axiomatizes the same $op("BL")^+$-logic as the full Reynolds triple is *open* (conjectured to fail, via an unformalized pen-and-paper sketch; not established).]

The *BL-level* system this report's pain points concern is $op("TM")$ itself, the smallest CPL-extension closed under MP, MN, MK, MT, M5 (S5, as above), MF (the sole bimodal-interaction axiom), and TD, TK, T4, TB, TA, TL (temporal necessitation, future-K, transitivity, seriality, past/future exchange, linearity) -- axiomatized directly over $#allpast$/$#allfuture$, with no Since/Until primitives.#footnote[Untracked prose (`sub:Logic`), cited by key only -- these twelve axiom/rule keys are not individually quoted verbatim here. @brastmckie2026possibleworlds] Its discrete/dense/complete extensions $op("TM")_f, op("TM")_d, op("TM")_c, op("TM")_(d c)$ add DF, DN, CO respectively (@sec:contingency). $op("TM")$ is the paper's *economical* presentation; $op("BX")$ is the Lean development's more fine-grained, frame-class-parameterized proof system (@sec:construction) -- the two are related but not silently identified (@sec:construction states the open cross-reference precisely).

= Key Theorems, Completeness Status, and Decidability <sec:key-theorems>

== Existence, Soundness, Correspondence

Every partial history extends to a total one by a Step Lemma#footnote[`lem:step`, the sole *Spherical* application site. @brastmckie2026possibleworlds] driving a Zorn's-lemma argument (`thm:extension`), hence `cor:occurrence`; both are ZFC results, not choice-free. This matters for a Lean/paper mismatch worth flagging once: "choice-free" in the paper's sense means *no further use of AC given classical logic*, whereas Lean's single `Classical.choice` axiom already yields both excluded middle and choice jointly, so `#print axioms` cannot express the paper's finer distinction directly -- this repository has separately machine-checked that *Spherical* on a finite carrier implies weak excluded middle, so no `Classical.choice`-free Lean proof of `thm:extension` could exist even for the finite case.

*Soundness*: if $tack.r phi.alt$ then $#satisfies phi.alt$, for TM and each of its four frame-class extensions.#footnote[`thm:TM-soundness`. Representative validity proofs: `thm:M5-valid` ($#satisfies diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$, via $square.stroked$'s universal quantification over $H_(#taskframe)$ itself), plus TD, TA, TL, MF. @brastmckie2026possibleworlds]

The three correspondence theorems are compressed to statement and one-line idea -- these are *not* the "give in full" exceptions (@sec:split-validity's dichotomy and (DD) are):

#figure(
  table(
    columns: 2, stroke: none, align: (left,left),
    table.hline(), table.header([*Correspondence*],[*Idea*]), table.hline(),
    [DF valid over $#taskframe$ iff $#Dur$ Discrete], [both directions via the translation-flow frame $W=D$, $w arrow.r.double.long_d u :<=> u=w+d$],
    [DN valid over $#taskframe$ iff $#Dur$ Dense], [same frame, DN forces/is forced by an interpolant],
    [CO valid over $#taskframe$ iff $#Dur$ Complete], [same frame with $|p| = L$ for a Dedekind cut $(L,U)$],
    table.hline(),
  ),
  caption: [The three frame-property correspondences (`app:discrete`, `app:dense`, `app:complete`), against the four frame-class predicates of `def:frame-properties`.],
)#footnote[@brastmckie2026possibleworlds]

== Perpetuity and the Collapse Theorems

The perpetuity principles P1-P6 and TF ($square.stroked phi.alt arrow.r #allfuture square.stroked phi.alt$) follow from MF and MT by short classical chains at `sub:Logic`; four modal-temporal collapses are worth naming, since they bound the language's real expressive complexity: $#sometimes square.stroked phi.alt arrow.l.r square.stroked phi.alt$ (Pthm:13), $#always square.stroked phi.alt arrow.l.r square.stroked phi.alt$ (Pthm:14), $square.stroked #always phi.alt arrow.l.r square.stroked phi.alt$ (Pthm:18), $diamond.stroked phi.alt arrow.l.r diamond.stroked #sometimes phi.alt$ (Pthm:20) -- each a short ($lt.eq 6$-line) chain from P1-P6, TF, MN, MK, M5.#footnote[Untracked, cited by key; paraphrased, not quoted verbatim. @brastmckie2026possibleworlds]

By Hölder's theorem, a nontrivial *discrete* Archimedean totally ordered abelian group is isomorphic to $ZZ$, and a nontrivial *Dedekind-complete* one is Archimedean hence isomorphic to $ZZ$ or $RR$ -- so the complete class is exactly ${ZZ, RR}$ up to isomorphism, and the dense-and-complete class is exactly $RR$.#footnote[`def:TMplus-f`, `def:TMplus-c` footnotes. @brastmckie2026possibleworlds The paper names Hölder's theorem without a bibliography entry, a standard-result convention this report matches.]

== Completeness -- Stated Exactly, Unsoftened <sec:completeness-status>

#theorem("Completeness")[
  TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ are sound over their respective classes of all, discrete, dense, complete, and dense-and-complete task frames, but *none is complete*. Completeness is instead carried by $op("BL")^+$ systems: $op("TM")^+_d$ is weakly complete over the full Dense class (machine-checked, sorry-free); $op("TM")^+_f$ is weakly complete over $ZZ$-time (machine-checked over the successor-Archimedean class); $op("TM")^+_c$ is weakly complete over the dense-and-complete class, exactly $RR$ (machine-checked); $op("TM")^+$'s weak completeness over *all* task frames is the stated formalization *target*, with one proof obligation outstanding -- *not* an established theorem.
]#footnote[`cor:tm-completeness`. @brastmckie2026possibleworlds]

*Strong* completeness -- consequence from a possibly infinite premise set -- is the aim for $op("TM")^+$ and $op("TM")^+_d$, with no known obstruction to a fully compact treatment of the base and dense classes; it *provably fails* for $ZZ$-time and for the dense-and-complete class $RR$, where compactness fails. Nothing is asserted about compactness of the full discrete class in either direction, or about $op("TM")_c$'s completeness over ${ZZ,RR}$, which is not claimed even weakly.

The former conservative-extension theorem is deleted from the paper; its replacement is a four-part footnote at `def:TMplus`: the *backward* direction ($op("BL")$-theorems of TM/$op("TM")_f$/$op("TM")_d$/$op("TM")_c$ remain theorems of $op("TM")^+$ and its extensions) holds unconditionally, since $op("BL")$ embeds into $op("BL")^+$; the *forward* direction fails for the base case, witnessed by (DD) (@sec:split-validity); fails unconditionally for the discrete extension via TMP-Z1 over $ZZ times_"lex" ZZ$; and remains *open* for the dense and complete extensions, with no known counterexample. No conservativity claim is made for $op("TM")^+$ over TM.

== Decidability -- Faithfully Open

#theorem("Decidability")[Whether TM, $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ are decidable is *open*.]#footnote[`cor:tm-decidability`. @brastmckie2026possibleworlds]

A recursively axiomatized system's theorems are recursively enumerable regardless of completeness status; decidability additionally needs the *non*-theorems to be r.e., standardly secured via a finite model property (FMP). A former blanket FMP-over-$D=ZZ$ premise is *retracted as false*, witnessed twice: DF is a non-theorem of TM, $op("TM")_d$, $op("TM")_c$, $op("TM")_(d c)$ yet valid in every model over $D=ZZ$; CO is a non-theorem of $op("TM")_f$, witnessed by $ZZ times_"lex" ZZ$, yet likewise valid over $D=ZZ$. A repaired FMP must therefore be *class-specific*, ranging over effective non-Archimedean carriers such as $ZZ times_"lex" ZZ$. What exists: a verified sound tableau procedure, and ongoing formalization of a semantic, truth-connected FMP for the $ZZ$-time discrete case (@sec:construction). What would suffice: the two intersection reductions -- $op("Log")("all task frames") = op("Log")("Discrete") inter op("Log")("Dense")$ and $op("Log")("complete frames") = op("Th")(ZZ) inter op("Th")(RR)$ -- each reducing decidability to that of the two factor logics. This is a target *strategy*, not a result; no decidability theorem is proposed here.

= Pain Point One: The Contingency of the Temporal Axioms <sec:contingency>

The three frame conditions Discrete/Dense/Complete (`def:frame-properties`) are characterized by axioms DF, DN, CO respectively (`app:discrete`, `app:dense`, `app:complete`), giving systems $op("TM")_f, op("TM")_d, op("TM")_c$, with $op("TM")_(d c)$ the minimal common extension of $op("TM")_d$ and $op("TM")_c$. No temporal order is both discrete and dense, so TM cannot consistently contain both DF and DN.

*The worry, at full strength.* Since every possible world is defined over the frame's own temporal order $#Dur$, the structure $#Dur$ has -- discrete or dense, and in either case Dedekind complete or not -- holds *of metaphysical necessity* for that system: if $#Dur$ is dense, DN and its necessitation $square.stroked(#allfuture#allfuture phi.alt arrow.r #allfuture phi.alt)$ are both valid over that frame. This is not idiosyncratic to task semantics; it is an instance of frame validity being closed under necessitation (the Kripke B/symmetry precedent: over symmetric frames, B and its necessitation are both valid, so symmetry is necessary-if-true wherever it holds). Dorr and Goodman @dorr2020diamonds express sympathy for an account of metaphysical modality able to express theses about the contingency of the structure of time -- a real cost, not a strawman, and one the present framework must answer.

*The irregular-worlds response*, quoted in full since the price must be stated exactly:

#quote(block: true, quotes: false)[
  "Within the present framework one might give voice to such contingency by relaxing totality, admitting *irregular worlds* -- functions $tau : X arrow.r W$ where $X subset.neq D$ is a *coset domain*, a translate $G+c$ of a nontrivial subgroup $G lt.eq #Dur$, and $tau(x) arrow.r.double.long_(y-x) tau(y)$ for all $x,y in X$ -- and defining consequence over the irregular and possible worlds alike. Cosets rather than subgroups, since a family of translates is closed under ambient translation and so preserves MF and the perpetuity principles, which the subgroup formulation loses. The price is exact: every nontrivial ordered abelian group contains a discrete cyclic subgroup, so DN is then valid over no frame whatever, and DF fails over discrete orders possessing a subgroup that is itself dense, such as $QQ times_"lex" ZZ$, so the correspondence results of `app:discrete`, `app:dense`, and `app:complete` collapse together. These considerations recommend possible over irregular worlds."
]
#footnote[Quoted verbatim from the live footnote at `sub:Extension` (unlabeled -- no `\label` exists to track via `specs/paper-definitions-of-record.md`'s mechanism, so this quote is re-verified directly against the paper at authoring time rather than pinned). @brastmckie2026possibleworlds]

*The price, stated exactly*: (i) DN is valid over *no* frame whatever, since every nontrivial ordered abelian group contains a discrete cyclic subgroup; (ii) DF fails over discrete orders possessing a dense subgroup, such as $QQ times_"lex" ZZ$; (iii) `app:discrete`, `app:dense`, `app:complete` *lapse together*; (iv) the broadened operator, while still factive, normal, and closed under necessitation relative to the broadened consequence relation, is *displaced* from its standing as the strongest objective modality. Point (iv) is this report's own analysis, not a paper quotation -- the paper's sentence stating it is currently commented out in the live source (`sub:Extension`, immediately following the footnote above) and must not be cited as live text; it is grounded here directly in `def:strongest`/`thm:exist` (@sec:objective-modality) plus the observation that broadening the consequence relation changes which operator is $prec.eq$-least.

*The defense*, live paper text quotable directly: necessity-if-true of density is an instance of the general fact that frame validity is closed under necessitation, with the Kripke B/symmetry precedent above; structural disputes about metaphysical accessibility (S4 vs.~S5, closure under converses validating B) are already conducted as questions about which frame class and logic are correct, never as claims that transitivity or symmetry is itself metaphysically contingent; since possible worlds are only ever defined over a single frame, no modality quantifies across frames.#footnote[@brastmckie2026possibleworlds `sub:Extension`, live prose.]

*What irregular worlds do and do not deliver*: contingency in the *structure and cardinality* of the time series -- but not composition contingency of the catastrophe or proper-initial-segment kind, since a difference-closed domain is a subgroup (or a translate of one) and so unbounded in both directions either way.

*The residual question*, stated, not resolved: is there a semantics recovering temporal-structure contingency without lapsing the correspondence results? The paper's own target is a semantic class *closed under disjoint union*, under which the Halldén phenomenon of @sec:split-validity dissolves structurally -- @sec:split-validity develops exactly why the unrestricted class is *not* such a class, and @sec:representation returns to this target directly.

= Pain Point Two: Split Validity and TM's Semantic Incompleteness <sec:split-validity>

#theorem("Discrete-or-Dense Dichotomy")[Every nontrivial totally ordered abelian group $#Dur$ is either discrete (has a least positive element) or dense, and never both.]#footnote[`cor:tm-completeness`'s proof. @brastmckie2026possibleworlds Give in full, briefly, per this report's own remit.]
#proof[Translation invariance makes it exhaustive: if there is no least positive element, some positive $e<y-x$ exists for any $x<y$ (else $y-x$ would itself be least positive), giving $x<x+e<y$; a least positive element $e$ conversely forbids anything strictly between $x$ and $x+e$. Depends essentially on the *group* structure -- fails for a bare linear order (e.g.\ a copy of $ZZ$ followed by a copy of $QQ$), which is why `def:temporal-order` requires a group, not merely a linear order.]

Consequently $op("Log")("all task frames") = op("Log")("Discrete") inter op("Log")("Dense")$: the class of all task frames is a disjoint union of incompatible subclasses, *not closed under disjoint union*. Unions of logics characteristically admit *split validities* -- disjunctions valid on every frame yet unprovable from either disjunct's axioms alone -- and TM exhibits exactly this:

#theorem("The (DD) Split Validity")[The schema $square.stroked phi.alt_(op("DF")) or square.stroked psi_(op("DN"))$ (no variable-disjointness restriction; TD supplies the past mirrors), for arbitrary instances of DF and DN, is valid over every task frame yet *TM*-unprovable.]#footnote[Part of `cor:tm-completeness`'s proof. @brastmckie2026possibleworlds Give in full, briefly.]
#proof[A two-fibre countermodel (one fibre $ZZ$, one $RR$, $square.stroked$ read globally across both) is TM-sound -- no TM axiom or rule constrains how $square.stroked$ interacts across fibres -- while refuting both disjuncts of a variable-sharing instance. In $op("BL")^+$, (DD) is already a theorem with no added axiom: TMP-NB and M5 give $tack.r_(op("TM")^+) square.stroked "Next" top or square.stroked not "Next" top$, and since $"Next" top arrow.r phi.alt_(op("DF"))$ and $not "Next" top arrow.r psi_(op("DN"))$ are $op("BL")^+$-valid, $op("TM")^+$'s weak completeness (inheriting its own outstanding base-case obligation, @sec:key-theorems) gives the two conditionals as theorems, whence necessitation and distribution yield (DD).]

#figure(
  cetz.canvas({
    import cetz.draw: *
    let yZ = 1.1
    let yR = 0.0
    let xL = -2.4
    let xR = 2.4
    line((xL, yZ), (xR, yZ), stroke: (paint: blue.darken(20%), thickness: 1.5pt))
    for i in range(-4, 5) {
      let x = i * 0.5
      line((x, yZ - 0.08), (x, yZ + 0.08), stroke: (paint: blue.darken(20%), thickness: 1pt))
    }
    content((xR + 0.5, yZ), text(size: 8pt, fill: blue.darken(20%))[fibre $ZZ$])
    content((0, yZ + 0.3), text(size: 7.5pt, fill: blue.darken(20%))[$"Next"top$ true here])
    line((xL, yR), (xR, yR), stroke: (paint: orange.darken(10%), thickness: 1.5pt))
    content((xR + 0.5, yR), text(size: 8pt, fill: orange.darken(20%))[fibre $RR$])
    content((0, yR - 0.3), text(size: 7.5pt, fill: orange.darken(20%))[$not "Next"top$ true here])
    line((-1.5, yR), (-1.5, yZ), stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"),
      mark: (end: ">", start: ">", fill: gray.darken(20%)))
    content((-1.5, (yZ + yR) / 2), anchor: "west", text(size: 7.5pt, fill: gray.darken(20%))[ $square.stroked$ reads globally])
  }),
  caption: [The two-fibre (DD) countermodel: a discrete $ZZ$ fibre (ticked) where $"Next"top$ holds, a dense $RR$ fibre (unticked) where it fails, $square.stroked$ reading globally across both.],
)

*The taxonomy, kept unblurred*: TM is *semantically* incomplete (a formula valid but unprovable), *not* Halldén-incomplete. $"TM" + "(DD)"$ would *create* Halldén-incompleteness: a provable variable-disjoint disjunction with neither disjunct provable, since each fails soundness on the complementary subclass. Halldén-incompleteness of $op("Log")("all task frames")$ *itself is a theorem* -- the correct formal signature of a class that is a union of two incompatible kinds, and not a defect to be repaired.

In $op("BL")^+$, (DD) is already a theorem with no added axiom, as the footnote above derives -- inheriting $op("TM")^+$'s own outstanding base-case obligation, a hedge carried explicitly rather than dropped. The schematic form (DD) takes in $op("BL")$ records nothing about the semantics and everything about the *language*: $op("BL")$ has no sentence naming discreteness, so it must disjoin schemas where $op("BL")^+$ disjoins a sentence ($"Next"top$) with its negation.

$op("TM")_c$ fails identically over ${ZZ,RR}$, compounded by the further, independent open question of whether CO alone axiomatizes the same $op("BL")^+$-logic as the full Reynolds triple (@sec:system). $op("TM")_f$'s status *differs and must not be lumped in*: it is sound over *every* discrete frame (DF is valid there), but its completeness over that broader class is *open* -- the machine-checked discrete result is for $op("BX")_f$ over $ZZ$-time specifically, a narrower and deductively stronger system than $op("TM") + "DF"$, and no counterexample to $op("TM")_f$'s completeness over the full discrete class is known. The paper states no separate incompleteness argument for $op("TM")_d$; its status is covered only by `cor:tm-completeness`'s flat "none is complete" headline, not by a dedicated countermodel.#footnote[This section's material is reused, with permission of its own authorship lineage, from the verbatim quotes and derivations already independently verified against the live paper in this report's companion book chapter (`typst/chapters/04-metalogic.typ`) -- re-confirmed current at this report's own authoring pass rather than re-derived from scratch. @brastmckie2026possibleworlds]

= Pain Point Three: Axiomatizing the Strongest Objective Modality <sec:objective-modality>

$op("BL")$ is extended with a primitive propositional identity operator $equiv$ and higher-order quantifiers: `def:id`'s Ref, Imp, LL axiomatize $equiv$ minimally (not assumed Boolean), and operator variables range over an unrestricted domain of operations on propositions.#footnote[@brastmckie2026possibleworlds] The objective modalities are *axiomatized* by a primitive predicate $O$ on operator terms, following the theory of necessities in Bacon @bacon2022necessities, rather than *defined* outright -- *predicativity* (operator comprehension confined to formulas with no operator variables and no occurrence of $O$) blocks Russell--Myhill and keeps the system consistent with a fine-grained identity; Walsh @walsh2016predicativity proves consistency of a predicative restriction of Church's intensional logic. Predicativity could be dropped by strengthening the theory of identity instead, since coarse-grained identity also blocks Russell--Myhill.

$Q$ is a *strongest objective normal modal operator in $L$* -- $op("Str")^O_L (Q)$ -- iff (1) $tack.r O(Q)$ and (2) $tack.r forall P [O(P) arrow.r (Q prec.eq P)]$, with $prec.eq$ the dominance ordering; objectivity and normality need not be stated separately, since clause (1) already entails them.#footnote[`def:strongest`. @brastmckie2026possibleworlds] $op("Str")^O_L (B m)$: the meet operator witnesses *existence* -- clause (1) is the second conjunct of O-Meet, clause (2) follows from the first, T/N/K/necessitation-closure obtained by detaching O-Fac, O-Ax, O-Nec at $B m$.#footnote[`thm:exist`, *replacing* reliance on the separate, weaker `cor:exists` route (gated by a coarse-grained identity the paper does not assume) -- `cor:exists` is not the paper's existence result. @brastmckie2026possibleworlds]

Any two strongest objective normal modal operators are provably equivalent (`lem:uniq`); $op("Str")^O_L (Q)$ yields S4 for $Q$ (`thm:s4`) and B/Symmetry for $Q$ (`thm:sym`, a $tilde.op 15$-line chain compressed here to result-and-cite). Under $op("Str")^O_L (square.stroked)$: `lem:uniq` gives $tack.r forall p (square.stroked p arrow.l.r B m p)$, `thm:s4` gives S4, `thm:sym` gives B, factivity and necessitation follow by detaching O-Fac and O-Nec -- together delivering an S5 logic for $square.stroked$.#footnote[@brastmckie2026possibleworlds]

*The orthogonality point*, foregrounded: S5-hood alone cannot single $square.stroked$ out. The paper's own restricted case is the counterexample -- the *Stability* modality ($M,tau,x #satisfies "Stability" phi.alt$ iff $phi.alt$ holds at every $sigma$ agreeing with $tau$ at $x$) is likewise S5, since its accessibility partitions $H_(#taskframe)$ into equivalence classes, yet on non-temporal formulas $phi.alt arrow.r "Stability" phi.alt$ is valid, collapsing it to the trivial modality on that fragment.#footnote[Live `Stability` footnote, immediately following its semantic clause at `sub:RestrictedModalities`. @brastmckie2026possibleworlds] A strictly narrower accessibility relation can carry a strictly stronger logic; it is $prec.eq$-leastness, not S5-hood, that picks $square.stroked$ out. This general lesson is this report's *own analysis*, grounded in the live *Stability* footnote plus `def:strongest`/`thm:exist` -- the paper's own sentence stating the lesson generally is currently commented out in the live source (immediately after the *Stability* footnote's citing site) and must not be cited as paper text.

*The pain, stated plainly*: what is axiomatized is a *higher-order* theory of the objective modalities, not a $op("BL")$- or $op("BL")^+$-level proof system -- the connection between the two levels is a *hypothesis* ($op("Str")^O_L (square.stroked)$) adopted afresh for each system under study, not a theorem of TM or $op("TM")^+$. Left open: whether the leastness characterization is expressible or derivable at the propositional level at all; what a propositional axiomatization would have to add; whether the frame-relative plurality of $square.stroked$ operators is genuinely benign (the paper argues it is, since no cross-frame rival is formulable within the theory, and a reader wanting absoluteness may take the universal system); and how @sec:contingency's irregular-worlds broadening interacts, given that it *displaces* $square.stroked$ from its standing as $op("Str")^O_L (square.stroked)$ -- these two pain points are *not independent*.

= The Completeness Construction as Implemented Here <sec:construction>

*Core layer* (`Metalogic/Core/`): consistency, maximal consistent sets (MCS, negation-complete), the deduction theorem, and Lindenbaum's lemma via Zorn (`set_lindenbaum` in `MaximalConsistent.lean`); the set-level `SetConsistent`/`SetMaximalConsistent` layer is correctly finitary.

*Architecture*: by contraposition, if $phi.alt$ is underivable then ${not phi.alt}$ is consistent and extends to an MCS $M in.rev not phi.alt$. A countermodel is then built by a *three-way case split* on the discreteness indicator $U(top,bot)$ ("there is an immediate successor," i.e. whether $square.stroked not "Next"top$ or $not square.stroked not "Next"top$ is in $M$), with the *mixed case eliminated outright* by `mcs_mixed_case_absurd` (`BXCanonical/Chronicle/MCSMixedCase.lean`): an MCS cannot be undecided about discreteness.

#figure(
  cetz.canvas({
    import cetz.draw: *
    let root = (0, 1.5)
    let dense = (-3.3, 0)
    let discrete = (0, 0)
    let mixed = (3.3, 0)
    line(root, dense, stroke: (paint: gray.darken(20%), thickness: 1pt))
    line(root, discrete, stroke: (paint: gray.darken(20%), thickness: 1pt))
    line(root, mixed, stroke: (paint: gray.darken(20%), thickness: 1pt))
    content(root, box(fill: white, stroke: (paint: black, thickness: 1pt), inset: 5pt, radius: 3pt)[
      #text(size: 7.5pt)[MCS $M$: decide $U(top, bot)$]
    ])
    content(dense, box(fill: blue.transparentize(85%), stroke: (paint: blue.darken(20%), thickness: 1pt), inset: 5pt, radius: 3pt, width: 3cm)[
      #align(center)[#text(size: 7pt)[Dense case \ $square.stroked not U(top,bot) in M$ \ chronicle on $QQ$]]
    ])
    content(discrete, box(fill: orange.transparentize(85%), stroke: (paint: orange.darken(20%), thickness: 1pt), inset: 5pt, radius: 3pt, width: 3cm)[
      #align(center)[#text(size: 7pt)[Discrete case \ $square.stroked U(top,bot) in M$ \ Reynolds/Doets on $ZZ$]]
    ])
    content(mixed, box(fill: red.transparentize(88%), stroke: (paint: red.darken(20%), thickness: 1pt), inset: 5pt, radius: 3pt, width: 3cm)[
      #align(center)[#text(size: 7pt)[Mixed case \ eliminated: absurd]]
    ])
  }),
  caption: [The three-way case split on $U(top,bot)$. Same dichotomy that breaks $op("BL")$ (@sec:split-validity) makes $op("BL")^+$ go through: $op("BL")^+$ has a sentence naming discreteness where $op("BL")$ does not.],
)

*The structural rhyme*, this report's single most illuminating connection: this is the *same* discrete/dense dichotomy that breaks TM at the $op("BL")$ level (@sec:split-validity) -- the difference is that $op("BL")^+$ has a sentence naming discreteness ($not "Next"top$) and $op("BL")$ does not, so exactly the fact producing (DD)'s unprovable-but-valid disjunction at the $op("BL")$ level is what the $op("BL")^+$ completeness architecture case-splits on to make the canonical-model construction go through.

*Dense path*: the Burgess-style *chronicle construction* over $QQ$ (`Metalogic/BXCanonical/Chronicle/`, `singletonChronicle` #sym.arrow.r `omegaChain` #sym.arrow.r `limit_chronicle`), filling in Until/Since eventualities, with `completeness_dense` in `BXCanonical/Completeness.lean`.#footnote[@burgess1982axioms]

*Discrete path*: the Reynolds/Doets pipeline over $ZZ$ (`Metalogic/WeakCanonical/`, `IntegerModel/ReynoldsBridge.lean`'s `countermodel_discrete_reynolds_v2`), running through a Kamp-theorem-based expressive-completeness argument (`WeakCanonical/Kamp/`, `Separation/`, `EFGames/`, `Expressiveness/`).#footnote[@reynolds1992 @doets1987 @kamp1971formalproperties]

*Dedekind path*, which the reference book currently omits entirely: `BXCanonical/CompletenessDedekind.lean` (`completeness_dedekind_engine`), `Metalogic/StrongCompleteness.lean` (`completeness_dedekind`, `consequence_completeness_dedekind`), and the `WeakCanonical/RealModel/` subtree (Doets, shuffle, order-isomorphism to $RR$), on the Reynolds-triple basis Prior-U + Sep with CO derived.

*Shared infrastructure*: bundled families of MCSs with G/H coherence (`Metalogic/Bundle/BFMCS.lean`, `modal_forward`/`modal_backward`), enabling a Henkin-style construction where $square.stroked$ quantifies over *bundled* histories; the *D-parametric* algebraic truth lemma (`Metalogic/Algebraic/FlowFrame.lean`, `multiFamTaskFrameGen`) that turns a coherent MCS family into a task model once, generically, for every duration type $D$ -- its *Spherical* discharge (the deterministic-fiber argument) is a *third* pattern distinct from the finite-$W$ (`cor:spherical-finite`) and general-Zorn (`thm:extension`) routes; filtration and quasimodels (`BXCanonical/Filtration/`, `Quasimodel/`).

*Status discipline* (measured 2026-08-13 at commit c2b8da5d6 via `scripts/typst-status-counts.sh` and `scripts/check-module-invariants.sh`'s check C2/C3 -- see this task's `reports/02_measured-status.md`; re-stamped at this report's final pass, @sec:key-theorems's discipline applies here identically): `completeness_dense`, `completeness_discrete`, `countermodel_dense` each carry exactly `[propext, Classical.choice, Quot.sound]` -- sorry-free; `completeness` (the general Base-frame theorem) alone carries `sorryAx`, traced to a single dead-code dependency in `WeakCanonical/Transfer.lean`'s `countermodel_discrete`, whose *live* replacement `countermodel_discrete_reynolds_v2` is what `completeness_discrete` actually calls. The algebraic layer's sorry count measures zero directly, contradicting `UltrafilterMCS.lean`'s own stale docstring ("Contains sorries pending MCS helper lemmas") -- the measured fact is reported here; the docstring is not edited (non-goal) and its stale prose is not repeated. `completeness_dedekind_engine`'s four declarations are likewise confirmed `[propext, Classical.choice, Quot.sound]`, no `sorryAx`, per that module's own axiom-audit section. No `Boneyard/` content is described as live anywhere in this account.

*Terminology, settled project-wide*: "strong completeness" is reserved for consequence from a possibly-infinite premise set; because `Context := List Formula` is finite, every finite-context consequence result is inter-derivable with weak completeness via the deduction theorem and is called *consequence completeness*, never strong -- paraphrasing `StrongCompleteness.lean`'s own module docstring, the in-tree authority.

*BX/TM discipline*: this architecture is stated in `Metalogic/`'s own vocabulary (`FrameClass.Dense`/`Discrete`/`Base`) throughout -- `completeness_dense` is never silently renamed "$op("TM")_d$'s completeness." Whether these BX-level theorems resolve, contradict, or are orthogonal to `cor:tm-completeness`'s $op("TM")_d$/$op("TM")_f$ status is explicitly *open* and not adjudicated here.

*Decidability* (@sec:key-theorems's companion): the tableau decision procedure's soundness (`decide_sound`) is sorry-free; the finite-model-property completeness result (`fmp_completeness`) is sorry-free as a finite-filtration statement whose semantic-validity bridge is a separately open obligation, not yet closed.

= Early Representation Work and the Way Forward <sec:representation>

== A Superseded Waypoint, Heeded

An earlier, unpublished draft (`metalogic.tex`, not `\input`-ed by the live paper) sketched a Representation Theorem; it is cited here only as a historical waypoint, with its defects named rather than any content lifted: (1) its canonical temporal order is hard-coded to $ZZ$, not $D$-parametric, unlike the live construction (@sec:construction); (2) its representation theorem and frame-characterization corollary assert TM is sound *and complete* over the class of all task semantic frames, directly contradicting `cor:tm-completeness`; (3) its Truth Lemma's $square.stroked$ case assumes global agreement across all canonical histories directly from the S5 axioms, rather than deriving it from an accessibility/modal-saturation construction -- the live architecture instead routes through BFMCS `modal_forward`/`modal_backward` coherence (@sec:construction), a materially different and actually-discharged argument; (4) its weak- and strong-completeness claims for TM are exactly what `cor:tm-completeness` and `StrongCompleteness.lean`'s docstring both refute. No definition, theorem statement, or proof step from this draft is restated here.

== What Actually Exists: The Algebraic Layer, and Only It

Of three candidate "early representation work" items, exactly *one* is live Lean development: `Metalogic/Algebraic/` (`BooleanStructure.lean`, `LindenbaumQuotient.lean`, `UltrafilterMCS.lean`, `InteriorOperators.lean`, `FlowFrame.lean`) -- the Lindenbaum--Tarski algebra, its ultrafilters, and an interior-operator treatment of the modalities, measured sorry-free (@sec:construction). The other two are targets, not existing work, and are stated as such below.

*The shift-set representation programme* is *not started*: no `ShiftSet` or `shiftSet` identifier exists anywhere under `FormalSystem/`. What exists is a design document stating the target in both directions: a shift set $chevron.l Omega, D, "sh", A chevron.r$ ($D$ an ordered abelian group, $Omega$ a nonempty type carrying a $D$-action via $"sh" : Omega arrow.r D arrow.r Omega$, $A : "Atom" arrow.r Omega arrow.r "Prop"$) would induce a task model by construction, and conversely; the payoff would be first-order axiomatizability of the task-model class over the two-sorted signature $chevron.l Omega, D; <, +, 0, "sh", (A_p) chevron.r$, since the frame's algebraic content reaches truth only through the atom clause. The design document's literal Lean snippets predate the completed total-history refactor and would need restatement (the underlying argument is recorded as surviving; the exact signature does not). Shift-set names are ordinary math and prose here, not Lean identifiers, and are never backticked as such.

*The Jönsson--Tarski programme* -- the complex algebra $"Cm"(cal(F))$ of a task frame, the ultrafilter frame $"Uf"(A)$ of an abstract algebra, and the canonical embedding $eta(a) = {U : a in U}$ -- is an *archived target*: this material was moved out of the live tree into an archived subtree, with revival tracked only as an unstarted future item. No content under that archived subtree is live. The important obstruction on revival: *Spherical* for an ultrafilter frame is a genuinely nontrivial *new* obligation, and the finite-$W$ discharge pattern (`cor:spherical-finite`) does not apply -- ultrafilter frames are typically infinite.

#figure(
  cetz.canvas({
    import cetz.draw: *
    let start = (-4.4, 0)
    let algMid = (-1.3, 1.0)
    let algEnd = (1.5, 1.0)
    let jtEnd = (4.2, 1.0)
    let ssMid = (-1.3, -1.0)
    let ssEnd = (4.2, -1.0)
    let boxstyle(fill-c, stroke-c) = (fill: fill-c, stroke: (paint: stroke-c, thickness: 1pt), inset: 4pt, radius: 3pt, width: 2.5cm)
    content(start, box(fill: white, stroke: (paint: black, thickness: 1pt), inset: 4pt, radius: 3pt)[#text(size: 7pt)[task-model class]])
    line(start, algMid, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(algMid, box(..boxstyle(green.transparentize(85%), green.darken(20%)))[#align(center)[#text(size: 6.5pt)[Lindenbaum--Tarski algebra -- *live*]]])
    line(algMid, algEnd, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(algEnd, box(..boxstyle(green.transparentize(85%), green.darken(20%)))[#align(center)[#text(size: 6.5pt)[ultrafilters, interior ops -- *live*]]])
    line(algEnd, jtEnd, stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"), mark: (end: ">"))
    content(jtEnd, box(..boxstyle(red.transparentize(88%), red.darken(20%)))[#align(center)[#text(size: 6.5pt)[Jönsson--Tarski duality -- *archived target*]]])
    line(start, ssMid, stroke: (paint: gray.darken(20%), thickness: 1pt), mark: (end: ">"))
    content(ssMid, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 6.5pt)[shift-set design doc -- *target*]]])
    line(ssMid, ssEnd, stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"), mark: (end: ">"))
    content(ssEnd, box(..boxstyle(orange.transparentize(85%), orange.darken(20%)))[#align(center)[#text(size: 6.5pt)[ultraproduct pipeline -- *not started*]]])
  }),
  caption: [The representation-theorem landscape: two routes, each starting live and ending in a target. Solid arrows mark completed steps; dashed arrows mark the gap.],
)

== The Way Forward

*(a) What must be weakened.* Of `def:frame`'s four axioms, *Spherical* is the prime suspect -- hardest to discharge at infinite carriers, and exactly where the Jönsson--Tarski route stumbles. Three discharge patterns are known (finite-$W$ choice-free, general Zorn, the $D$-parametric deterministic-fiber argument of @sec:construction); whether a weaker saturation condition suffices for the Step Lemma (`lem:step`) is open.

*(b) The group structure as crux, both ways -- this report's single most valuable analysis.* The discrete-or-dense dichotomy (@sec:split-validity) is a theorem about ordered abelian *groups* and fails for bare linear orders, so dropping $D$ to a linearly ordered set (or a monoid, or a partially ordered group) *dissolves the (DD) obstruction outright*. The cost: MF and the perpetuity principles depend on translation invariance; the converse convention depends on negation; Compositionality is stated in terms of addition. What survives each weakening is exactly what a general representation theorem must reckon with, and is not yet worked out.

*(c) Disjoint-union closure.* Is the coset-domain construction of @sec:contingency the right route -- whose price is precisely a loss of the correspondence results a representation theorem would want -- or is a genuinely multi-frame semantics needed, and what would $square.stroked$ then quantify over? Open.

*(d) Algebraic vs.~shift-set.* The shift-set route's payoff is first-order axiomatizability and hence a compactness/ultraproduct argument; the Jönsson--Tarski route's payoff is a canonical embedding and duality. The design document's own recorded route: a feasibility gate, a bespoke two-sorted ultraproduct (Mathlib's single-sorted `FirstOrder.Language` was rejected as an encoding target), a Łoś lemma for truth, model existence/compactness, then per-class strong completeness -- with four named risks: the dependent ultraproduct of carriers as the largest unknown; the box case of Łoś needing a choice-function argument; a `Type`-vs-`Type*` universe constraint that must be asserted early; and the honest verdict "promising, not certain." Whether the two routes are the same theorem twice is itself open.

*(e) What would count as adequate.* Quoted from the in-tree acceptance standard directly: a sorry-free Lean statement of *both* directions with `#print axioms` reporting no `sorryAx`. A statement that type-checks with a sorry body does not count; one direction does not count; a prose argument does not count.

*(f) What is foreclosed.* Genuine strong completeness is *impossible* for $ZZ$-time and for $RR$ (compactness fails; an explicit non-compactness witness exists for the successor-Archimedean discrete case, and Reynolds @reynolds1992 establishes the analogous failure over $RR$). Base and Dense are *open*, not settled -- the missing piece is a model-existence theorem (every consistent set satisfiable in a class frame), which does not follow from the single-formula countermodel engines already built. Any way forward promising strong completeness for $ZZ$-time or $RR$ is wrong on arrival.

#bibliography("bibliography.bib")
