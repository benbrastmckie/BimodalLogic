// ============================================================================
// 04-metalogic.typ
// Metalogic chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: FormalSystem/ (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count
#import "@preview/cetz:0.3.4"

= Metalogic <sec:metalogic>


The metalogic for the bimodal logic *TM* relates the BX proof system of the previous chapter to the task semantics.
Soundness holds for all four frame classes.
Completeness holds in the strongest form each frame class admits: strong completeness over all task frames and over the dense frames, and weak completeness over $ZZ$-time and over the dense-and-complete class --- where strong completeness *provably fails*, by non-compactness.
The chapter develops the canonical-model infrastructure carrying these results, states the completeness theorems, and closes with the tableau-based decision procedure and the module structure of `Metalogic/`.

== Soundness

Soundness establishes that only logical consequences are derivable.
It is proven separately for each frame class, matching the `FrameClass` parameter on derivations.

#theorem("Soundness")[
  If $Gamma tack.r phi.alt$ then $Gamma tack.r.double phi.alt$.#footnote[`soundness` in `Metalogic/Soundness.lean`.]
]

#theorem("Frame-Class Soundness")[
  Derivability at frame class `Dense` (respectively `Discrete`, `Dedekind`) implies validity over densely ordered (respectively discrete, dense-and-complete) task frames.#footnote[`soundness_dense`, `soundness_discrete`, and `soundness_dedekind`, all in the single unified `Metalogic/Soundness.lean` module. `FrameClass.Dedekind` hosts the complete extension *TM*#sub[c] (dense-and-complete orders, i.e. the real flow); the frame-classes chapter of Part II details the correspondence.]
]

The proof proceeds by induction on the derivation structure:
- *Axioms*: Each of the #axiom-count axiom constructors is proven valid on the frames of its minimum frame class (base axioms on all linear orders, `density`/`dense_indicator` on dense orders, `prior_UZ`/`prior_SZ`/`z1` on discrete orders, `prior_U_gap`/`prior_S_gap`/`sep` on dense-Dedekind-complete orders)
- *Assumptions*: Assumed formulas are true by hypothesis
- *Modus ponens*: Validity preserved under implication elimination
- *Necessitation*: Valid formulas become necessarily valid
- *Temporal necessitation*: Valid formulas become always-future valid
- *Temporal duality*: Past-future swap preserves validity
- *Weakening*: Adding premises preserves semantic consequence

The axiom validity lemmas live in `Metalogic/SoundnessLemmas/` (with `Core.lean`, `DenseValidity.lean`, and `FrameClassVariants.lean`), and the frame-condition semantics for the Base/Dense/Discrete classes is developed in the top-level `FrameConditions/` directory (the Dedekind class's semantic side lives in `WeakCanonical/RealModel/`, per @sec:frame-classes).
The modal-temporal interaction axiom MF uses time-shift invariance (via `timeShift` on world histories) to relate truth at different times.

== Core Infrastructure

The completeness proof requires three foundational components: the deduction theorem, maximal consistent sets, and Lindenbaum's lemma.

=== Deduction Theorem

#theorem("Deduction Theorem")[
  If $A :: Gamma tack.r B$ then $Gamma tack.r A arrow.r B$.#footnote[Proven in `Metalogic/Core/`; see `deductionTheorem`.]
]

The proof uses well-founded induction on derivation height, handling each of the following rules:
- *Axiom*: Use S axiom to weaken
- *Assumption*: Identity if same, S axiom if different
- *Modus ponens*: Use K axiom distribution
- *Weakening*: Case analysis on assumption membership
- *Modal/temporal rules*: Do not apply (require empty context)

=== Consistency

#definition("Consistent")[
  A context $Gamma$ is *consistent* if $Gamma tack.r.not bot$.
]

#definition("Maximal Consistent")[
  A set of formulas $S$ is *maximal consistent* if it is consistent and for all $phi.alt in.not S$, the set $S union {phi.alt}$ is inconsistent.#footnote[Formalized at the set level as `SetMaximalConsistent`, parameterized by frame class.]
]

Maximal consistent sets (MCS) are negation-complete: for every formula $phi.alt$, exactly one of $phi.alt$ or $not phi.alt$ is a member.
This property is essential for canonical constructions, as it ensures that every formula has a definite truth value in each MCS.

=== Lindenbaum's Lemma

#lemma("Lindenbaum")[
  Every consistent set of formulas extends to a maximal consistent set.#footnote[Proven as `set_lindenbaum` in `Metalogic/Core/MaximalConsistent.lean`.]
]

The proof applies Zorn's lemma to the partially ordered collection of consistent supersets of the given set.
The key step is showing that the union of any chain of consistent sets is itself consistent: any derivation of $bot$ uses only finitely many premises, which would be contained in some member of the chain, contradicting that member's consistency.

== Completeness

=== Completeness Theorems <sec:completeness-theorems>

Where $Gamma tack.r.double_C phi.alt$ restricts logical consequence to models over task frames in a class $C$, a proof system is *strongly complete* over $C$ just in case $Gamma tack.r.double_C phi.alt$ implies $Gamma tack.r phi.alt$ for every set of premises $Gamma$, and *weakly complete* over $C$ just in case $tack.r.double_C phi.alt$ implies $tack.r phi.alt$.
Completeness is carried by the four systems of the frame-class hierarchy, each in the strongest form its class admits:

// LEAN-ANCHOR-MAY-MOVE: canonical-completeness -- see typst/README.md
// CONFIRM(lean): a set-premise strong completeness theorem for FrameClass.Base exists in Metalogic/ and is axiom-free
// CONFIRM(lean): completeness (FrameClass.Base weak, Metalogic/BXCanonical/Completeness.lean) is axiom-free
//   (WeakCanonical.countermodel_discrete discharged)
#theorem("Strong Completeness (Base)")[
  *TM* is strongly complete over the class of all task frames: if $Gamma tack.r.double phi.alt$ over all task frames, then $Gamma tack.r phi.alt$.
]

// CONFIRM(lean): a set-premise strong completeness theorem for FrameClass.Dense exists in Metalogic/ and is axiom-free
// CONFIRM(lean): completeness_dense (Metalogic/BXCanonical/Completeness.lean) remains axiom-free
#theorem("Strong Completeness (Dense)")[
  *TM*#sub[d] is strongly complete over the dense task frames: if $Gamma tack.r.double phi.alt$ over the dense frames, then $Gamma tack.r_(op("Dense")) phi.alt$.
]

// LEAN-ANCHOR-MAY-MOVE: canonical-completeness -- see typst/README.md
// CONFIRM(lean): completeness_discrete (Metalogic/BXCanonical/Completeness.lean) remains axiom-free
#theorem("Weak Completeness (Discrete)")[
  *TM*#sub[f] is weakly complete over $ZZ$-time: every formula valid over the integer flow is derivable at frame class `Discrete`.
]

// CONFIRM(lean): completeness_dedekind (Metalogic/StrongCompleteness.lean) remains axiom-free
#theorem("Weak Completeness (Dedekind)")[
  *TM*#sub[c] is weakly complete over the dense-and-complete class (exactly $RR$ up to isomorphism): every formula valid over the real flow is derivable at frame class `Dedekind`.
]

Weak completeness is the *appropriate target* for the Discrete and Dedekind classes, because the strong form is provably false there:

#theorem("Failure of Strong Completeness over $ZZ$ and $RR$")[
  Strong completeness fails for $ZZ$-time and for the dense-and-complete class: compactness fails over both flows, so a consistent set of premises can be unsatisfiable.
  Over $ZZ$-time the set ${F p} union {not op("Next")^n p : n gt.eq 0}$ is finitely satisfiable yet unsatisfiable --- every finite subset places the witness for $F p$ beyond the mentioned horizon, while the whole set forbids $p$ at every future time.
]

The negative results are permanent mathematics, not artifacts of any particular proof method: no strengthening of the axioms restores strong completeness over a non-compact flow.

=== The Discrete-or-Dense Dichotomy <sec:dichotomy>

The frame-class correspondence rests on a structural fact about temporal orders:

#theorem("Discrete-or-Dense Dichotomy")[
  Every nontrivial totally ordered abelian group $D$ is either discrete (has a least positive element) or dense, and never both.
] <thm-dichotomy>
#footnote[Translation invariance is what makes the dichotomy exhaustive: if there is no least positive element then some positive $e < y - x$ exists for any $x < y$ (else $y - x$ would itself be least positive), giving $x < x+e < y$; conversely a least positive element $e$ forbids anything strictly between $x$ and $x+e$. The dichotomy *fails* for bare linear orders --- e.g. a copy of $ZZ$ followed by a copy of $QQ$ is neither uniformly discrete nor uniformly dense --- which is exactly why the temporal-order definition requires the group structure and not merely a linear order.]

Consequently every task frame is outright discrete or outright dense, $op("Log")("all task frames") = op("Log")(op("Discrete")) inter op("Log")(op("Dense"))$, and the three-way case split of the canonical construction below is exhaustive.

=== Proof Architecture

The proof is by contraposition.
If $phi.alt$ is not derivable, then ${not phi.alt}$ is consistent, and Lindenbaum's lemma extends it to an MCS $M$ containing $not phi.alt$.
A countermodel for $phi.alt$ is then built from $M$ by a three-way case split on the discreteness indicator $bot #untl top$ ("there is an immediate successor"), exhaustive by the dichotomy of @sec:dichotomy:

+ *Dense case* ($square.stroked not (bot #untl top) in M$): a countermodel is constructed on the rational timeline $QQ$ via the Burgess-style *chronicle construction* @burgess1982axioms.#footnote[`Metalogic/BXCanonical/Chronicle/`, entry point `countermodel_dense` in `ChronicleToCountermodelBasic.lean`, drawing on the D-parametric truth lemma in `Metalogic/Algebraic/`.]
+ *Discrete case* ($square.stroked (bot #untl top) in M$): a countermodel is constructed on the integer timeline $ZZ$ via the Reynolds/Doets pipeline @reynolds1992 @doets1987.#footnote[`Metalogic/WeakCanonical/`, transfer step in `WeakCanonical/Transfer.lean`.]
+ *Mixed case*: eliminated outright --- an MCS cannot be undecided about discreteness.#footnote[`mcs_mixed_case_absurd` in `Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean`.]

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    let root = (0, 1.9)
    let dense = (-3.6, 0)
    let discrete = (0, 0)
    let mixed = (3.6, 0)

    line(root, dense, stroke: (paint: gray.darken(20%), thickness: 1pt))
    line(root, discrete, stroke: (paint: gray.darken(20%), thickness: 1pt))
    line(root, mixed, stroke: (paint: gray.darken(20%), thickness: 1pt))

    content(root, box(fill: white, stroke: (paint: black, thickness: 1pt), inset: 6pt, radius: 3pt)[
      #text(size: 8pt)[MCS $M$: decide $bot #untl top$]
    ])
    content(dense, box(fill: blue.transparentize(85%), stroke: (paint: blue.darken(20%), thickness: 1pt), inset: 6pt, radius: 3pt, width: 3.2cm)[
      #align(center)[#text(size: 7.5pt)[Dense case \ $square.stroked not (bot #untl top) in M$ \ chronicle on $QQ$]]
    ])
    content(discrete, box(fill: orange.transparentize(85%), stroke: (paint: orange.darken(20%), thickness: 1pt), inset: 6pt, radius: 3pt, width: 3.2cm)[
      #align(center)[#text(size: 7.5pt)[Discrete case \ $square.stroked (bot #untl top) in M$ \ Reynolds/Doets on $ZZ$]]
    ])
    content(mixed, box(fill: red.transparentize(88%), stroke: (paint: red.darken(20%), thickness: 1pt), inset: 6pt, radius: 3pt, width: 3.2cm)[
      #align(center)[#text(size: 7.5pt)[Mixed case \ eliminated: absurd]]
    ])
  })
]

#align(center)[
  #text(size: 0.85em, style: "italic")[
    The three-way case split driving the completeness construction, on the discreteness indicator $bot #untl top$ ("there is an immediate successor"). An MCS cannot be undecided about discreteness, so the mixed branch is eliminated outright rather than handled.
  ]
]

The construction rests on shared infrastructure:
- *Bundled families of MCSs* (`Metalogic/Bundle/`): time-indexed families of maximal consistent sets with G/H coherence conditions, used by all completeness paths.
- *Algebraic parametric completeness* (`Metalogic/Algebraic/`): a truth lemma parametric in the duration type $D$, which turns a coherent MCS family into a task model.
- *Chronicles* (`Metalogic/BXCanonical/Chronicle/`): the Burgess @burgess1982axioms dense-order construction, filling in witnesses for Until/Since eventualities over $QQ$.
- *Filtration and quasimodels* (`Metalogic/BXCanonical/Filtration/`, `Quasimodel/`): finitary approximations used in the canonical chain construction.

== Decidability

The decision procedure for *TM* is tableau-based: it is sound (`decide_sound`), and its completeness route runs through the finite-filtration finite-model-property statement (`fmp_completeness`).
The full operational account -- entry points, fuel semantics, certificate/countermodel extraction, the finite-model-property statement, and the tableau complexity table -- is given in @sec:decidability-practice.

== Module Structure

The live metalogic code is organized as follows (`FormalSystem/Metalogic/`):

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header(
      [*Module*], [*Contents*],
    ),
    table.hline(),
    [`Core/`], [MCS theory, provability interface, deduction theorem, Lindenbaum lemma (`set_lindenbaum`); `RestrictedMCS/` subtree],
    [`Bundle/`], [Time-indexed MCS families (BFMCS) with coherence conditions],
    [`Algebraic/`], [D-parametric algebraic completeness and truth lemma],
    [`BXCanonical/`], [`Completeness.lean` (Base/Dense/Discrete completeness), `CompletenessDedekind.lean`; `Chronicle/` (dense case), `Filtration/`, `Quasimodel/`],
    [`WeakCanonical/`], [Reynolds/Doets discrete completeness path; `Separation/`; Kamp-style expressiveness modules (`Kamp/`); `RealModel/` (Dedekind/real-flow semantics), `IntegerModel/`, `EFGames/`, `Expressiveness/`, `DenseModelSurgery/`],
    [`Decidability/`], [Tableau decision procedure; `FMP/` finite model property (discrete-only, @sec:decidability-practice); `Propositional/`, `Verified/`],
    [`SoundnessLemmas/`], [Per-axiom validity lemmas, dense/discrete/Dedekind variants],
    [`Soundness.lean`], [Unified soundness theorem for all four frame classes: `soundness`, `soundness_dense`, `soundness_discrete`, `soundness_dedekind`],
    [`StrongCompleteness.lean`], [`completeness_dedekind`, `consequence_completeness_dedekind`],
    [`Decidability.lean`], [Decidability interface],
    table.hline(),
  ),
  caption: [`Metalogic/` module structure.],
)

== Formalization Anchors

Which Lean theorems carry which results of this chapter:

// LEAN-ANCHOR-MAY-MOVE: canonical-completeness -- see typst/README.md
// CONFIRM(lean): scripts/typst-status-counts.sh --json reports sorry_total_excl_boneyard = 0
#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header([*Result*], [*Lean Anchor*]),
    table.hline(),
    [Soundness (all four frame classes)], [`soundness`, `soundness_dense`, `soundness_discrete`, `soundness_dedekind` (`Metalogic/Soundness.lean`)],
    [Deduction theorem], [`deductionTheorem` (`Metalogic/Core/`)],
    [Lindenbaum's lemma], [`set_lindenbaum` (`Metalogic/Core/MaximalConsistent.lean`)],
    [Weak completeness, Base], [`completeness` (`Metalogic/BXCanonical/Completeness.lean`)],
    [Weak completeness, Dense], [`completeness_dense` (`Metalogic/BXCanonical/Completeness.lean`)],
    [Weak completeness, Discrete ($ZZ$-time)], [`completeness_discrete` (`Metalogic/BXCanonical/Completeness.lean`)],
    [Weak completeness, Dedekind], [`completeness_dedekind` (`Metalogic/StrongCompleteness.lean`)],
    [Perpetuity principles P1--P6], [`Theorems/Perpetuity/`],
    [Decision-procedure soundness], [`decide_sound` (`Metalogic/Decidability/`)],
    table.hline(),
  ),
  caption: [The set-premise strong completeness theorems for the Base and Dense classes carry their own anchors when they land; the CONFIRM obligations of @sec:completeness-theorems name them.],
)

=== Semantic Convention

The completeness architecture is built for the *strict (irreflexive) temporal semantics* of @sec:truth: G and H quantify over strictly future and strictly past times, so the temporal T-axioms $G phi.alt arrow.r phi.alt$ and $H phi.alt arrow.r phi.alt$ are *not* valid, and seriality is supplied axiomatically by BX1/BX1$'$.#footnote[`Semantics/Truth.lean` and the module docstring of `Metalogic.lean` document this convention.]

