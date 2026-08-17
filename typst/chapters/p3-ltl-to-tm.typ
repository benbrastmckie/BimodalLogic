// ============================================================================
// p3-ltl-to-tm.typ
// Part I chapter -- From LTL to TM
//
// Framing constraint: TM is never described as a mere juxtaposition of LTL
// with an S5 modality; the interaction and the constructed history space
// carry the chapter. Paper sources: possible_worlds.tex:1412-1533 (LTS
// reading, product landscape, LTL/CTL/HyperLTL triangulation,
// branching-time neighbors).
// ============================================================================

#import "../template.typ": *

= From LTL to TM <sec:ltl-to-tm>

#chapter-header(
  description: [Where *TM* sits relative to the temporal logics of the model-checking literature: what is genuinely shared with LTL, what is different by design, and why the difference is a matter of semantic architecture rather than a bolted-on modality.],
  dependencies: [Chapters 1--3 (syntax, semantics, proof theory); @sec:design-choices for the strict-semantics convention.],
)


== The Thesis

Readers arriving from computer science will recognize much of *TM*'s operator vocabulary from linear temporal logic @pnueli1977 @baierkatoen2008 @demrigorankolange2016, and the recognition is legitimate -- but the identification is not.
Stated precisely: *TM* is Until/Since temporal logic over linear orders -- durations form a totally ordered abelian group, and the operators quantify strictly -- fused with an S5 metaphysical modality through the interaction axiom MF and the uniformity axioms, interpreted over task frames in which possible worlds are task-constrained functions from convex sets of durations to world states.
The modality is not a second primitive Kripke dimension laid alongside the temporal one: $square.stroked$ quantifies over the _constructed_ history space $H_(cal(F))$, and it is the time-shift invariance of that construction that validates the perpetuity principles connecting the two operator families (see the Time-Shift section of the semantics chapter and the perpetuity theorems P1--P6 of the theorems chapter; they are not restated here).
Every contrast drawn in this chapter unpacks some part of that sentence.

== Traces versus Task Frames

LTL is interpreted over traces: $omega$-sequences of states (or of atomic-proposition labelings), with a distinguished initial point, a primitive next-step operator, and a non-strict Until @pnueli1977 @baierkatoen2008 @demrigorankolange2016.
*TM* is interpreted over the task frames of the semantics chapter, and the differences are structural rather than notational:

- *Time domain.* A trace is indexed by $NN$; a *TM* history $tau : X arrow.r W$ has a convex domain $X$ in an arbitrary totally ordered abelian group of durations -- discrete, dense, or neither -- and may be bi-infinite or partial.
- *Initial point.* A trace begins somewhere, and LTL validity is anchored at that initial position; a task-frame history has no distinguished start, and *TM* validity is floating -- quantified over all frames, histories, _and_ times.
- *The underlying system.* A task frame is itself a labeled transition system in which the transition labels are durations carrying group structure @baierkatoen2008, so the model-checking reading of "system plus runs" transfers directly: a history is a labeled run of the system.
  What LTL calls the set of traces of a system, *TM* constructs as the history space $H_(cal(F))$ -- and then quantifies over it with $square.stroked$ in the object language.

The semantics chapter (@sec:truth) gives the full truth conditions; nothing in this comparison modifies them.

== Operator Conventions

Against the shared Until vocabulary, four conventions differ, each adjudicated elsewhere in this book and only collected here:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Convention*], [*LTL*], [*TM*]),
    table.hline(),
    [Until reading], [Non-strict (present included)], [Strict/irreflexive (@sec:design-choices)],
    [Next step], [Primitive operator], [Derived: $"Prev"$/$"Next"$ as $bot #snce phi.alt$ / $bot #untl phi.alt$, unfold lemmas `prev_unfold`/`next_unfold` (frame-classes chapter)],
    [Past operators], [Absent (future-only)], [Present: Since is primitive alongside Until],
    [Validity], [Anchored at the initial position], [Floating over all frames, histories, and times],
    table.hline(),
  ),
  caption: [Operator-convention deltas between LTL and *TM*.],
)

The future-only convention of LTL is principled, not an oversight: over discrete $NN$-like flows the past-free fragment is already expressively adequate -- the Kamp-theorem discussion of @ch:vlach-blstar explains why, and why the reduction is unavailable over *TM*'s general duration groups, where Since does independent work.

== Translating LTL into TM

The convention deltas above compose into a systematic translation.
An LTL trace -- an $omega$-sequence of states -- embeds into the task-frame setting as a history over the duration group $ZZ$ with convex domain ${ x : x gt.eq 0 }$, realized in the frame whose task relation is trivial: the identity at duration $0$ and the total relation at every other duration (this relation satisfies the *Compositionality*, *Seriality*, *Limit*, and *Spherical* frame axioms outright).
Position $i$ of the trace becomes time $i$ of the history, and atoms are false at times outside the domain, matching the semantics chapter's convention.
On formulas, each non-strict LTL operator has a strict *TM* rendering:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*LTL operator*], [*TM rendering*], [*Comment*]),
    table.hline(),
    [$X phi.alt$], [$bot #untl phi.alt$], [$"Next"$, exact over discrete frames],
    [$psi thin U^"ns" phi.alt$], [$phi.alt or (psi and (psi #untl phi.alt))$], [Non-strict Until: witness now, or strictly later with the guard from now],
    [$F^"ns" phi.alt$], [$phi.alt or F phi.alt$], [Reflexive "eventually"],
    [$G^"ns" phi.alt$], [$phi.alt and G phi.alt$], [Reflexive "henceforth"],
    table.hline(),
  ),
  caption: [Non-strict LTL operators rendered over *TM*'s strict primitives.],
)

The translation is truth-preserving position by position, and two worked examples show where the care pays off.

*Next and self-duality.*
LTL validates $not X phi.alt arrow.l.r X not phi.alt$: every trace position has exactly one successor, so "not: $phi.alt$ next" and "next: not $phi.alt$" coincide.
In *TM* the rendering $bot #untl phi.alt$ makes this equivalence a *frame-class* fact rather than a logical one.
Over $ZZ$, $bot #untl phi.alt$ holds at $x$ exactly when $phi.alt$ holds at $x + 1$, and self-duality follows; over a dense order, no point has an immediate successor, so $bot #untl phi.alt$ is false for *every* $phi.alt$ -- both $X phi.alt$ and $X not phi.alt$ fail while $not X phi.alt$ holds.
The equivalence is thus valid over discrete frames and invalid over dense ones: what LTL builds into its models, *TM* exposes as a frame-class distinction.

*Anchoring.*
LTL validity is truth at position $0$ of every trace; *TM* validity is floating over all frames, histories, and times.
The translation preserves truth pointwise, so it maps LTL *truth conditions* faithfully, but validity does not transfer in either direction without an anchoring argument: an LTL-valid formula's rendering must be checked at arbitrary evaluation points (not just a designated start), and over arbitrary duration groups (not just $NN$-like ones).
The frame-class machinery is exactly the instrument for that check -- renderings that depend on discreteness, like the Next self-duality above, hold over discrete frames and not in general.

== Neither Fusion nor Product

The many-dimensional modal logic literature provides the right vocabulary for the combination itself @gabbay2003manyvalued.
Two stock recipes combine a temporal logic with S5: the _fusion_, which imposes no interaction between the operator families, and the _product_, which imposes full commutation interaction by evaluating at pairs of a time and a world.
*TM* is neither.
It is more than the fusion, because MF (and the derived TF) are theorems relating $square.stroked$ to the temporal operators; and it is not literally the product of a linear tense logic with S5, because its interaction principles are not _imposed_ on a two-dimensional grid of evaluation points -- they _hold_ in virtue of the construction of the history space, whose time-shift invariance makes perpetuity come out valid.
In the general product landscape such principles must be stipulated frame condition by frame condition; here a single semantic decision -- worlds are shift-invariant families of task-respecting functions -- yields them wholesale.
This distinction matters again at the decidability frontier, since products and fusions have sharply different computational profiles -- the final chapter of this part surveys that landscape.

== Linear, Branching, and Hyper

*TM* sits inside the classical triangle of linear-time, branching-time, and hyper logics, and the coordinates are worth restating.
Individual possible worlds are linearly ordered, as in LTL @pnueli1977; the set of possible worlds passing through a given world state branches, as in CTL @clarke1982; and CTL#super[$star$] combines path quantifiers with temporal operators freely @emerson1986, in the debate initiated by Lamport @lamport1980 and pressed to its "final showdown" by Vardi @vardi2001.
The key difference from the branching-time family is that $square.stroked$ quantifies over _all_ possible worlds in $H_(cal(F))$ at the evaluation time, rather than employing the state-relativized path quantifiers $A$ and $E$ of CTL; it is precisely this unrestricted quantification, combined with time-shift invariance, that validates perpetuity.
HyperLTL provides the sharpest contrast: it extends LTL with quantifiers $forall pi$ and $exists pi$ that bind trace variables in the object language @clarkson2014, and that binding power makes its satisfiability problem undecidable @finkbeiner2016.
*TM*'s $square.stroked$ binds nothing -- it is a modal operator over the constructed history space, not a first-order quantifier over traces -- and the language stays on the modal side of that line.
The cost profile of crossing it is the business of @sec:decidability-frontier.

== Branching-Time Neighbors

Two philosophical traditions posit branching outright.
The STIT theory of Belnap, Perloff, and Xu @belnap2001 and Rumberg's transition semantics @rumberg2016 -- following Thomason's reconstruction of the Ockhamist tradition @thomason1984 -- take the temporal order itself to be a partial order with incomparable moments branching toward the future.
*TM* keeps the duration order total and locates indeterminism in the task relation instead: the relation $arrow.r.double.long_x$ need not be functional, so the space of histories through a world state _unfolds into_ a tree without a tree ever being posited.
When the state space is finite and durations are the integers, the complete histories form a shift of finite type in the sense of symbolic dynamics @lind2021 -- the finite-discrete instance of the same construction.

== The Conservativity Bridge

One last bookkeeping point lets this chapter compare *TM* with LTL operator-by-operator without changing systems mid-argument.
The *language* embedding is unconditional: the tense-primitive sublanguage is recovered inside the book's Since/Until language, whose `snce` and `untl` are the primitive constructors with $P$/$F$/$H$/$G$ derived (see the Language Basis note of @sec:notes) -- so the LTL-style operator vocabulary is the native one here.
Proof-system conservativity for the tense-primitive subsystem is that deferred subsystem's own matter, treated at @sec:conservative-extension; the comparison in this chapter rests only on the unconditional language embedding.
