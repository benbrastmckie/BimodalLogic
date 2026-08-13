// ============================================================================
// 00-introduction.typ
// Introduction chapter for the Bimodal TM Logic Reference Manual
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count, rule-count
#import "@preview/cetz:0.3.4"

= Introduction

This book presents *TM*, a bimodal logic that unifies tense and modality in a single formally verified system, as implemented in the #proofchecker Lean 4 project.
*TM* combines an S5 modal operator for historical necessity with linear temporal operators for past and future, axiomatized by the Burgess-Xu proof system over Until/Since primitives and interpreted over task-frame semantics.
The semantic framework -- the construction of possible worlds as histories over task frames -- follows @brastmckie2026possibleworlds; the philosophical background that motivates constructing possible worlds rather than positing them (the eternalism debate, the perpetuity principles as a touchstone, and the abundance dilemma) is developed there and is not rehearsed in this book.
This book presents the bimodal system itself, in full: its formal specification (Part I) and its applications (Part II).

== What TM Is

*TM* combines S5 historical modal operators for necessity ($square.stroked$) and possibility ($diamond.stroked$) with linear temporal operators for past ($H$) and future ($G$), all built over an *Until/Since* primitive basis.
Precisely: *TM* is Until/Since temporal logic over linear orders ($ZZ$ discrete, $QQ$ dense) fused with S5, plus a load-bearing modal-temporal interaction axiom (MF) and uniformity axiom layers over task frames.
The Until/Since basis and the interaction axioms make *TM* a genuine fusion of temporal and modal reasoning rather than a temporal logic with a modal operator adjoined: the S5 modality quantifies across world histories, the temporal operators quantify within a single history, and the interaction axioms bind the two dimensions together (@sec:notes discusses the relationship to the published presentation in detail).
Beyond *TM* itself lies a natural extension hierarchy: *TM* $arrow.r$ *TM*#super[+] (Vlach store/recall operators for cross-referencing traces and times) $arrow.r$ the BL#super[⋆] tower, surveyed at the close of Part I.

*Why task frames rather than Kripke frames.*
A Kripke model for a bimodal logic would posit two independent primitives: a set of "worlds" with an accessibility relation for $square.stroked$, and, orthogonally, a set of "times" with an order for $H$/$G$ -- two structures glued together after the fact, with nothing to explain why they interact at all.
Task frames build the two dimensions out of a *single* underlying construction instead (@sec:world-histories).
A *world state* is an instant; a *task relation* $w arrow.r.double.long_x u$ says that a task of duration $x$ carries world state $w$ to world state $u$; and a *possible world*, in the sense $square.stroked$ quantifies over, is not a primitive point but a *total world history* -- a specific temporal trajectory built by chaining task-relation steps across every duration.
Modal accessibility between possible worlds is therefore *derived* from the finer-grained task relation between world states, rather than posited as an independent primitive alongside it, and this is exactly what makes the interaction axiom MF (below) a substantive discovery about the construction rather than a stipulation bolted on afterward.
This is the sense in which the source paper is about *constructing* possible worlds rather than positing them.

*Why the temporal order is an ordered abelian group, not a bare linear order.*
Durations need to *add*: a task of duration $x$ followed by one of duration $y$ composes into a single task of duration $x + y$ (`def:frame`'s *Compositionality* axiom, @sec:world-histories), and negative durations recover the converse of a task by the sign of its duration.
A bare linear order has no addition to state this with, so the temporal order $D$ is required to be a nontrivial totally ordered abelian group.
That choice pays off far downstream, and it is worth flagging early because the payoff is genuinely striking: *every* nontrivial totally ordered abelian group is either discrete (has a least positive element) or dense, and never both -- a dichotomy that *fails* for bare linear orders (a copy of $ZZ$ followed by a copy of $QQ$ is neither) and holds for ordered abelian groups only because translation invariance globalizes any local gap or density witness into a global one.
This single algebraic fact is the reason *TM*'s frame classes split into `Dense`/`Discrete`/`Dedekind` branches (@sec:frame-classes), and it is also the reason *TM* itself turns out to be *provably* incomplete over the class of all task frames rather than merely open (@sec:metalogic) -- the headline correction this edition of the book makes to its predecessor.

*What the bimodal interaction axiom MF buys.*
MF ($square.stroked phi.alt arrow.r square.stroked G phi.alt$: whatever is necessary is necessarily always going to be the case) is the one axiom that makes the fusion more than two logics sharing a page.
Without it, S5 and the Until/Since temporal logic would be two non-interacting systems: nothing would connect what $square.stroked$ says across histories to what $G$ says within one.
Together with the S5 axiom MT, MF derives the theorem TF ($square.stroked phi.alt arrow.r G square.stroked phi.alt$: necessity is preserved into the future's necessity) by classical reasoning alone, and TF together with MF is exactly what the perpetuity principles P1--P6 need (@sec:perpetuity) -- the theses, defended independently in the philosophical literature @dorr2020diamonds, that whatever is necessary is always the case and whatever is sometimes the case is possible.
The perpetuity principles are the clearest evidence that the fusion is doing real work: they are theses *about* the interaction of $square.stroked$ with $H$/$G$, and no treatment of either dimension alone could so much as state them.

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    // A single timelike world history through x, with its past/future light
    // cones opening along the trajectory direction. Time increases along tau.
    let theta = 20deg          // inclination of the world history
    let alpha = 34deg          // light-cone half-angle
    let L = 1.9                // cone edge length
    let pt(ang, r) = (calc.cos(ang) * r, calc.sin(ang) * r)

    let x = (0, 0)

    // Past light cone (blue) - opens backward along -tau
    line(
      x, pt(theta + alpha + 180deg, L), pt(theta - alpha + 180deg, L),
      close: true,
      fill: blue.transparentize(85%),
      stroke: gray.lighten(40%),
    )

    // Future light cone (orange) - opens forward along +tau
    line(
      x, pt(theta + alpha, L), pt(theta - alpha, L),
      close: true,
      fill: orange.transparentize(85%),
      stroke: gray.lighten(40%),
    )

    // Two candidate trajectories (dotted) -- one forward into the future cone,
    // one backward into the past cone -- each carrying its own direction arrow.
    let dstroke = (paint: gray.lighten(35%), thickness: 1pt, dash: "dotted")
    // forward candidate: leaves x along tau, then peels upward
    bezier(x, pt(42deg, 1.75), (0.55, 0.15), pt(42deg, 1.2),
      stroke: dstroke, mark: (end: ">", fill: gray.lighten(35%)))
    // backward candidate: leaves x along -tau, then peels downward
    bezier(x, pt(214deg, 1.75), (-0.55, -0.15), pt(214deg, 1.2),
      stroke: dstroke, mark: (end: ">", fill: gray.lighten(35%)))

    // The actual world history tau: ONE smooth S threading through x.
    // S0, x, S1 are collinear (along theta), so the curve must cross that
    // center line at x. Both lobes share a single tangent at x that is
    // STEEPER than the line (~38deg): the past lobe stays below the line as a
    // single concave-up arc, the future lobe stays above as a single
    // concave-down arc, giving exactly one inflection point at x.
    let S0 = pt(theta + 180deg, 2.7)
    let S1 = pt(theta, 2.7)
    // past lobe: single concave-up arc, tail nearly flat -> steepens into x
    bezier(S0, x, (-1.45, -0.77), (-0.71, -0.55),
      stroke: (paint: blue.darken(40%), thickness: 2pt))
    // future lobe: single concave-down arc, leaves x with the same tangent
    bezier(x, S1, (0.71, 0.55), (1.45, 0.77),
      stroke: (paint: blue.darken(40%), thickness: 2pt),
      mark: (end: ">", fill: blue.darken(40%)))

    // Label tau near the past end of the world history
    content((S0.at(0) + 0.2, S0.at(1) + 0.3),
      text(fill: blue.darken(40%), size: 10pt)[$tau$])

    // Marked point x
    circle(x, radius: 0.08, fill: blue.darken(40%), stroke: none)
    content((0.0, -0.32), text(size: 10pt)[$x$])
  })
]

#align(center)[
  #text(size: 0.85em, style: "italic")[
    A single world history $tau$ (the actual evolution, solid) through task-frame state space. From point $x$, the past/future light cones (shaded) contain the states that are modally accessible via $square.stroked$/$diamond.stroked$; the temporal operators $H$/$G$ quantify strictly within a single history's past/future. Dotted paths are *not* alternative histories in *TM*'s formalization.
  ]
]

The solid curve $tau$ above represents a single world history -- a temporal sequence of states.
From any point $x$ along a history, the past and future light cones contain all states that are modally accessible.
The necessity operator $square.stroked$ quantifies over all possible histories, though we may often restrict to those histories that pass through the world state $tau(x)$.
The temporal operators $H$ and $G$ quantify over past and future times which, given a particular history, determine the range of past and future world states that history occupies relative to a given time.
These primitive operators may then be used to define a host of combined operators of interest (@sec:formulas).

== Why Tense and Modality Together

Tense and modality interact, and the interaction is where the logical substance lies -- the previous section already showed what MF and the perpetuity principles buy philosophically.
What that interaction costs *technically* is the point of this section: the metatheory of the combined system -- its canonical models, its frame correspondences, its decision procedures -- is substantially subtler than the metatheory of S5 and of Until/Since temporal logic taken separately, and Part I develops that metatheory in full.
S5-hood alone, moreover, does not single out the reading of $square.stroked$ as *metaphysical* necessity rather than some other stable modality; @sec:notes returns to this point once the tools for stating it precisely are in hand.

A second motivation is verification.
Every axiom, inference rule, and derived theorem presented in Part I resolves to a named declaration in the live Lean 4 source under `FormalSystem/`, and the machine appendix at the end of the book lists the correspondence explicitly.
This discipline pays for itself: formal statements in prose are easy to drift out of alignment with a developing formalization, whereas a book whose claims are checked against source admits a sharp distinction between what is proven, what is constructed but open, and what is paper-side mathematics.
The book maintains that distinction throughout: proven results are cited by Lean name; open problems are stated as open problems; and results belonging to the companion papers rather than the formalization are attributed to the papers.

== Outline

The book proceeds in two parts, matching the live document's own part divisions.

+ *Part I -- The Bimodal System.* Syntax (@sec:formulas); task-frame semantics; the Burgess-Xu proof system; frame classes and their extensions (@sec:frame-classes, now four: Base, Dense, Discrete, Dedekind); the metalogic (@sec:metalogic, including why *TM* itself is sound but provably incomplete); decidability in practice (the tableau procedure and its status); the perpetuity theorems (@sec:perpetuity); and three positioning chapters closing out the part -- LTL-to-*TM* (@sec:ltl-to-tm), the Vlach/BL#super[⋆] tower (@ch:vlach-blstar), and the decidability frontier (@sec:decidability-frontier).
+ *Part II -- Applications.* Proof automation and the bounded proof-search engine, the dual-signal training-data pipeline (proof traces and countermodels, every output deterministically checkable), and dual-verification worked examples.

Back matter closes the book: implementation-status notes and design-choice discussion (@sec:notes), and a machine-readable appendix cross-referencing every Lean declaration cited in the text.

== How to Read This Book

The parts are ordered by logical dependency, but several shorter paths through the material are available.

- *The core system.* The syntax, semantics, and proof-theory chapters form the spine of Part I; every later chapter presupposes them. A reader who wants only the definition of *TM* and its axiomatization can stop after the proof-theory chapter.
- *The metatheory.* The frame-classes, metalogic, and decidability-in-practice chapters develop soundness, the canonical-model construction, and the tableau decision procedure. These chapters presuppose the spine but are independent of the derived-theorem library.
- *Comparative positioning.* The closing chapters of Part I -- the LTL comparison, the Vlach/BL#super[⋆] survey, and the decidability frontier -- locate *TM* among its neighbors and can be read independently after the spine.
- *Applications.* Part II is self-contained given the spine and the decidability chapter: proof automation, the training-data pipeline, and dual verification each occupy one chapter.

Formal claims are typeset with their Lean identifiers in fixed-width font (e.g. `perpetuity_1`); each such identifier names a declaration in the live source, and the machine appendix indexes the full correspondence.

== Project Structure

The Lean 4 implementation is in the `FormalSystem/` directory:
- `Syntax/` -- Defines the formula language with 6 primitive constructors (atoms, $bot$, implication, $square.stroked$, Until, Since) and derived operators.
- `ProofSystem/` -- The Burgess-Xu (BX) axiom system: #axiom-count axiom constructors in 8 layers and #rule-count inference rules forming a Hilbert-style proof system, parameterized by frame class (Base/Dense/Discrete/Dedekind).
- `Semantics/` -- Task frames model possible worlds; world histories model time (partial, then convex/world, then total -- @sec:world-histories); strict (irreflexive) truth conditions define meaning; `Extension/` runs the paper's existence machinery (Constraint Lemma through the Extension Theorem) as a machine-checked chain.
- `FrameConditions/` -- Frame-class semantics (dense, discrete) and per-class validity.
- `Metalogic/` -- Soundness (proven for all four frame classes: Base, Dense, Discrete, Dedekind), deduction theorem and Lindenbaum lemma (proven), canonical-model machinery underlying the machine-checked $op("BL")^+$ completeness results of @sec:metalogic (*TM* itself is sound but provably incomplete over its frame classes), and a tableau-based decision procedure (soundness proven).
- `Theorems/` -- Perpetuity principles (P1--P6, proven), modal and propositional theorem libraries, and derived temporal axioms.
- `Automation/`, `Examples/` -- Proof tactics, the training-data pipeline, and worked examples, covered in Part II.
