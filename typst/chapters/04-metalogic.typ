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
Soundness is fully proven for all four frame classes.
Completeness, however, is not merely unresolved for *TM* itself: it is *provably absent*, for a structural reason worth understanding before the technical development below, and this is the headline correction this chapter makes relative to earlier drafts of this book.
Completeness is instead carried by machine-checked $op("BL")^+$ systems built on the canonical-model infrastructure developed here.
The chapter closes with the tableau-based decision procedure and the live module structure of `Metalogic/`.

== Soundness

Soundness establishes that only logical consequences are derivable.
It is proven separately for each frame class, matching the `FrameClass` parameter on derivations.

#theorem("Soundness")[
  If $Gamma tack.r phi.alt$ then $Gamma tack.r.double phi.alt$.#footnote[Proven sorry-free as `soundness` in `Metalogic/Soundness.lean`.]
]

#theorem("Frame-Class Soundness")[
  Derivability at frame class `Dense` (respectively `Discrete`, `Dedekind`) implies validity over densely ordered (respectively discrete, dense-Dedekind-complete) task frames.#footnote[Proven sorry-free as `soundness_dense`, `soundness_discrete`, and `soundness_dedekind`, all in the single unified `Metalogic/Soundness.lean` module -- not the separate per-class files an earlier draft of this book cited; the module structure changed from per-class files to one unified module. `FrameClass.Dedekind` corresponds to the paper's $op("TM")^+_(d c)$ (dense-and-complete, i.e. the real flow), not $op("TM")^+_c$ (completeness alone, whose models are $ZZ$ and $RR$ up to isomorphism) -- see @sec:frame-classes for why no `FrameClass` constructor targets $op("TM")^+_c$ itself.]
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

=== Why *TM* Is Incomplete

*TM* and its extensions $op("TM")_f$, $op("TM")_d$, $op("TM")_c$, and $op("TM")_(d c)$ are sound over their respective classes of all, discrete, dense, complete, and dense-and-complete task frames, but *none is established as complete*.#footnote[`cor:tm-completeness` --- an anchor outside the 26 tracked by `specs/paper-definitions-of-record.md`, re-verified directly against the live paper for this citation rather than assumed. @brastmckie2026possibleworlds]
Completeness is instead carried by machine-checked $op("BL")^+$ systems (@sec:formulas's Until/Since-and-store/recall-extended language sits above $op("BL")^+$; see `def:BLplus-language`):

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header([*System*], [*Status*]),
    table.hline(),
    [$op("TM")^+_d$], [Weakly complete over the full *Dense* class; machine-checked, sorry-free.],
    [$op("TM")^+_f$], [Weakly complete over $ZZ$-time, machine-checked directly over the successor-Archimedean class.],
    [$op("TM")^+_c$], [Weakly complete over the dense-and-complete class (exactly $RR$), machine-checked directly, aligned with `def:TMplus-c`'s Reynolds-triple basis for $op("BX")_c$.],
    [$op("TM")^+$], [Weak completeness over all task frames is the stated Lean-formalization target; one proof obligation remains outstanding, so this is *not yet* an established theorem.],
    table.hline(),
  ),
  caption: [Completeness status of the $op("BL")^+$ systems, per `cor:tm-completeness`.],
)

The reason *TM* itself resists a complete BL-level axiomatization is one of the more interesting facts about the system, and it turns on the temporal order being an ordered abelian group (@sec:metalogic's payoff on the choice foreshadowed in the introduction):

#theorem("Discrete-or-Dense Dichotomy")[
  Every nontrivial totally ordered abelian group $D$ is either discrete (has a least positive element) or dense, and never both.
]#footnote[Translation invariance is what makes the dichotomy exhaustive: if there is no least positive element then some positive $e < y - x$ exists for any $x < y$ (else $y - x$ would itself be least positive), giving $x < x+e < y$; conversely a least positive element $e$ forbids anything strictly between $x$ and $x+e$. The dichotomy *fails* for bare linear orders --- e.g. a copy of $ZZ$ followed by a copy of $QQ$ is neither uniformly discrete nor uniformly dense --- which is exactly why `def:temporal-order` requires the group structure and not merely a linear order. @brastmckie2026possibleworlds]

Consequently $op("Log")("all task frames") = op("Log")(op("Discrete")) inter op("Log")(op("Dense"))$: the class of all task frames is the disjoint union of its discrete and dense subclasses, and it is *not closed under disjoint union*.
Unions of logics characteristically admit *split validities* --- disjunctions valid on every frame yet unprovable from either disjunct's axioms alone --- and *TM* exhibits exactly this.

#theorem("The (DD) Split Validity")[
  The schema $square.stroked phi.alt_(op("DF")) or square.stroked psi_(op("DN"))$, for arbitrary $phi.alt_(op("DF")), psi_(op("DN"))$ instantiating axioms DF and DN, is valid over every task frame yet *TM*-unprovable: a two-fibre countermodel (one fibre over $ZZ$, one over $RR$, with $square.stroked$ read globally across both) is *TM*-sound --- every *TM* axiom and rule remains valid, since none of them constrains how $square.stroked$ interacts across the two fibres --- while refuting both disjuncts of a variable-sharing instance.
]#footnote[(DD), part of `cor:tm-completeness`'s proof. @brastmckie2026possibleworlds In $op("BL")^+$, (DD) is already a theorem with no added axiom: axioms TMP-NB and M5 give $tack.r_(op("TM")^+) square.stroked op("Next") top or square.stroked not op("Next") top$, and since $op("Next") top arrow.r phi.alt_(op("DF"))$ and $not op("Next") top arrow.r psi_(op("DN"))$ are $op("BL")^+$-valid, $op("TM")^+$'s weak completeness (inheriting its own outstanding base-case obligation) gives the two conditionals as theorems, whence necessitation and distribution yield (DD).]

#align(center)[
  #cetz.canvas({
    import cetz.draw: *

    let yZ = 1.4
    let yR = 0.0
    let xL = -2.6
    let xR = 2.6

    // Fibre 1: Z (discrete ticks)
    line((xL, yZ), (xR, yZ), stroke: (paint: blue.darken(20%), thickness: 1.5pt))
    for i in range(-4, 5) {
      let x = i * 0.55
      line((x, yZ - 0.09), (x, yZ + 0.09), stroke: (paint: blue.darken(20%), thickness: 1pt))
    }
    content((xR + 0.55, yZ), text(size: 9pt, fill: blue.darken(20%))[fibre $ZZ$])
    content((0, yZ + 0.35), text(size: 8pt, fill: blue.darken(20%))[$op("Next")top$ true here])

    // Fibre 2: R (continuous line)
    line((xL, yR), (xR, yR), stroke: (paint: orange.darken(10%), thickness: 1.5pt))
    content((xR + 0.55, yR), text(size: 9pt, fill: orange.darken(20%))[fibre $RR$])
    content((0, yR - 0.35), text(size: 8pt, fill: orange.darken(20%))[$not op("Next")top$ true here])

    // Box arrow crossing both fibres
    line((-1.7, yR), (-1.7, yZ), stroke: (paint: gray.darken(20%), thickness: 1pt, dash: "dashed"),
      mark: (end: ">", start: ">", fill: gray.darken(20%)))
    content((-1.7, (yZ + yR) / 2), anchor: "west", text(size: 8pt, fill: gray.darken(20%))[ $square.stroked$ reads globally])
  })
]

#align(center)[
  #text(size: 0.85em, style: "italic")[
    The two-fibre countermodel witnessing (DD): a discrete $ZZ$ fibre (ticked) where $op("Next")top$ holds, and a dense $RR$ fibre (unticked) where it fails, with $square.stroked$ reading globally across both. Every *TM* axiom and rule is sound on this structure -- none constrains how $square.stroked$ interacts across fibres -- yet $square.stroked phi.alt_(op("DF")) or square.stroked psi_(op("DN"))$ is refuted by a variable-sharing instance, since each disjunct fails on its complementary fibre.
  ]
]

*TM* does not prove (DD), so *TM* is nowhere shown *Halldén*-incomplete --- it is *semantically* incomplete instead, a different defect: a formula valid but unprovable, rather than a provable variable-disjoint disjunction with no provable disjunct.
$op("TM") + op("(DD)")$ would instead *create* Halldén-incompleteness, proving the variable-disjoint disjunction while proving neither disjunct (each fails soundness on the complementary subclass).
$op("Log")("all task frames")$ itself contains (DD) and neither disjunct, so *Halldén-incompleteness of the target logic is a theorem* --- the correct formal signature of a class that is a union of two incompatible kinds, and not a defect to be repaired.

$op("TM")_c$ fails identically over ${ZZ, RR}$, for the same reason, compounded by the further, independent open question of whether axiom CO alone axiomatizes the same $op("BL")^+$-logic as the full Reynolds triple (@sec:proof-theory).
$op("TM")_f$'s status differs: it is sound over every discrete frame, but whether it is complete over that class is *open* --- the machine-checked discrete completeness result is for the Reynolds-axiom system $op("BX")_f$ over $ZZ$-time specifically, a narrower and deductively stronger system than $op("TM") + op("DF")$, and no counterexample to $op("TM")_f$'s completeness over the broader discrete class is known.
The paper states no separate incompleteness argument for $op("TM")_d$; its status is covered only by the corollary's flat "none is complete" headline, not by a dedicated countermodel.

=== The BX Canonical-Model Infrastructure

The Lean development's own canonical-model chain is stated for the more fine-grained, frame-class-parameterized $op("BX")$ proof system of @sec:proof-theory (Base/Dense/Discrete/Dedekind), not for the paper's economical *TM* presentation directly (@sec:paper-contrast explains the correspondence).

#theorem("Completeness (Dense, Discrete)")[
  Validity over densely ordered frames implies derivability at frame class `Dense`; validity over discrete frames implies derivability at frame class `Discrete`.
]#footnote[Stated as `completeness_dense` and `completeness_discrete` in `Metalogic/BXCanonical/Completeness.lean`, sorry-free per that file's own axiom audit.
// LEAN-ANCHOR-MAY-MOVE: canonical-completeness -- see typst/README.md
How these frame-class-indexed BX results relate to `cor:tm-completeness`'s claim that $op("TM")_d$'s and $op("TM")_f$'s own completeness is not established (open for $op("TM")_f$, unstated for $op("TM")_d$) is not resolved in this book; it is recorded as an open cross-reference in this task's findings note rather than adjudicated here.]

#theorem("Completeness (Base)")[
  If $tack.r.double phi.alt$, then there is a derivation of $phi.alt$ at frame class `Base`.
]#footnote[Stated as `completeness` in `Metalogic/BXCanonical/Completeness.lean`: `valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)`. This statement currently carries `sorryAx`, with the module's own audit attributing the sole source to a deprecated dead-code dependency in its discrete branch, not to an identified mathematical obstruction --- but a Base-frame completeness theorem, if closed as stated, would need to be reconciled with `cor:tm-completeness`'s (DD)-witnessed incompleteness of *TM* over the same class.
// LEAN-ANCHOR-MAY-MOVE: canonical-completeness -- see typst/README.md
This tension is recorded in this task's findings note and is not resolved here.]

=== Proof Architecture

The proof is by contraposition.
If $phi.alt$ is not derivable, then ${not phi.alt}$ is consistent, and Lindenbaum's lemma extends it to an MCS $M$ containing $not phi.alt$.
A countermodel for $phi.alt$ is then built from $M$ by a three-way case split on the discreteness indicator $U(top, bot)$ ("there is an immediate successor"):

+ *Dense case* ($square.stroked not U(top, bot) in M$): a countermodel is constructed on the rational timeline $QQ$ via the Burgess-style *chronicle construction* @burgess1982axioms.#footnote[`Metalogic/BXCanonical/Chronicle/`, entry point `countermodel_dense` in `ChronicleToCountermodelBasic.lean`, drawing on the D-parametric truth lemma in `Metalogic/Algebraic/`.]
+ *Discrete case* ($square.stroked U(top, bot) in M$): a countermodel is constructed on the integer timeline $ZZ$ via the Reynolds/Doets pipeline @reynolds1992 @doets1987.#footnote[`Metalogic/WeakCanonical/`, transfer step in `WeakCanonical/Transfer.lean`.]
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
      #text(size: 8pt)[MCS $M$: decide $U(top, bot)$]
    ])
    content(dense, box(fill: blue.transparentize(85%), stroke: (paint: blue.darken(20%), thickness: 1pt), inset: 6pt, radius: 3pt, width: 3.2cm)[
      #align(center)[#text(size: 7.5pt)[Dense case \ $square.stroked not U(top,bot) in M$ \ chronicle on $QQ$]]
    ])
    content(discrete, box(fill: orange.transparentize(85%), stroke: (paint: orange.darken(20%), thickness: 1pt), inset: 6pt, radius: 3pt, width: 3.2cm)[
      #align(center)[#text(size: 7.5pt)[Discrete case \ $square.stroked U(top,bot) in M$ \ Reynolds/Doets on $ZZ$]]
    ])
    content(mixed, box(fill: red.transparentize(88%), stroke: (paint: red.darken(20%), thickness: 1pt), inset: 6pt, radius: 3pt, width: 3.2cm)[
      #align(center)[#text(size: 7.5pt)[Mixed case \ eliminated: absurd]]
    ])
  })
]

#align(center)[
  #text(size: 0.85em, style: "italic")[
    The three-way case split driving the completeness construction, on the discreteness indicator $U(top, bot)$ ("there is an immediate successor"). An MCS cannot be undecided about discreteness, so the mixed branch is eliminated outright rather than handled.
  ]
]

The construction rests on shared infrastructure:
- *Bundled families of MCSs* (`Metalogic/Bundle/`): time-indexed families of maximal consistent sets with G/H coherence conditions, used by all completeness paths.
- *Algebraic parametric completeness* (`Metalogic/Algebraic/`): a truth lemma parametric in the duration type $D$, which turns a coherent MCS family into a task model.
- *Chronicles* (`Metalogic/BXCanonical/Chronicle/`): the Burgess @burgess1982axioms dense-order construction, filling in witnesses for Until/Since eventualities over $QQ$.
- *Filtration and quasimodels* (`Metalogic/BXCanonical/Filtration/`, `Quasimodel/`): finitary approximations used in the canonical chain construction.

=== Open Steps in the Base-Frame Completeness Derivation

The general Base-frame `completeness` theorem above is the one member of this family not yet closed.
Its documented open step is entirely engineering debt, not a mathematical gap: the discrete branch still routes through a deprecated dead-code dependency (`WeakCanonical.countermodel_discrete`) rather than the sorry-free Reynolds/Doets pipeline that `completeness_discrete` already uses on its own.
// LEAN-ANCHOR-MAY-MOVE: canonical-completeness -- see typst/README.md
Closing this step does not by itself resolve the tension flagged above with *TM*'s own (DD)-witnessed incompleteness over the Base class; that reconciliation is out of scope for this book and is recorded in the findings note.

== Decidability

The decision procedure for *TM* is tableau-based, with `decide_sound` (soundness) proven sorry-free and the finite-model-property completeness result (`fmp_completeness`) also sorry-free as a finite-filtration statement whose semantic-validity bridge is separately open.
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
    [`Soundness.lean`], [Unified soundness theorem for all four frame classes: `soundness`, `soundness_dense`, `soundness_discrete`, `soundness_dedekind` (sorry-free) -- not separate per-class files],
    [`StrongCompleteness.lean`], [`completeness_dedekind`, `consequence_completeness_dedekind`],
    [`Decidability.lean`], [Decidability interface],
    table.hline(),
  ),
  caption: [Live `Metalogic/` module structure. The former conservative-extension module no longer exists -- see @sec:conservative-extension for the paper's actual conservativity status.],
)

== Implementation Status

Soundness in all four frame-class variants (Base, Dense, Discrete, Dedekind), the deduction theorem, the MCS/Lindenbaum infrastructure, the perpetuity principles P1--P6, and the entire `Syntax/`, `Semantics/`, `ProofSystem/`, and `Theorems/` trees are fully proven in Lean under `FormalSystem/`.
The canonical-model construction is developed end-to-end for each frame class and underlies the machine-checked $op("BL")^+$ completeness results above; *TM* itself is sound but provably incomplete over its own frame classes, per `cor:tm-completeness`, so no amount of further canonical-model work closes that gap for *TM* -- only for the $op("BL")^+$ systems built on top of it.
The decision procedure's soundness (`decide_sound`) and the finite-filtration FMP statement (`fmp_completeness`) are likewise proven, with the semantic-validity bridge treated in @sec:decidability-practice.

=== Semantic Convention

The completeness architecture is built for the *strict (irreflexive) temporal semantics* of @sec:truth: G and H quantify over strictly future and strictly past times, so the temporal T-axioms $G phi.alt arrow.r phi.alt$ and $H phi.alt arrow.r phi.alt$ are *not* valid, and seriality is supplied axiomatically by BX1/BX1$'$.#footnote[`Semantics/Truth.lean` and the module docstring of `Metalogic.lean` document this convention.]

