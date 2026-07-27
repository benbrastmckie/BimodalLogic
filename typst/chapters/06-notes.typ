// ============================================================================
// 06-notes.typ
// Notes chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: FormalSystem/ (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count, rule-count

= Notes <sec:notes>


== Implementation Status

The syntax (six primitive constructors over the Until/Since basis), the task-frame semantics with strict truth conditions, and the BX proof system (#axiom-count axiom constructors in eight layers, #rule-count inference rules, frame-class parameter) are complete in Lean.
Soundness for all three frame classes, the deduction theorem, and the perpetuity principles P1--P6 are proven.
A canonical-model construction toward completeness is developed via `completeness` (`Metalogic/BXCanonical/`), with completeness itself remaining an open problem; the tableau decision procedure has soundness proven (`decide_sound`), and its finite-model-property component is discussed below.

== Relation to the Published Presentation

This section documents differences between the paper @brastmckie2026possibleworlds and the Lean implementation.
The Lean source is authoritative for all implementation claims; the paper is authoritative for the informal narrative and target vocabulary.

=== Terminology

- The paper uses "perpetuity principles" for P1--P6; the Lean code uses the same terminology.
- The paper's notation $triangle.stroked.t$ and $triangle.stroked.b$ for "always" and "sometimes" is preserved in the Lean implementation as `always` and `sometimes`.
- The paper's *Reflection* constraint on task frames is the Lean field `converse` (in biconditional form); the paper's *Nullity* is strengthened to the Lean field `nullity_identity`.

=== Language Basis

The paper's base language $cal(L)$ takes $H$ and $G$ as primitive tense operators, and extends to $cal(L)^+$ with Until and Since; the corresponding proof systems are *TM* and *TM*#super[+], related by a conservative-extension theorem.
The Lean formalization works in the Until/Since basis throughout: `untl` and `snce` are primitive, $H$/$G$/$F$/$P$ are derived (see @sec:formulas).

The module `Metalogic/ConservativeExtension/` contains `lift_derivation_qfree` (`Metalogic/ConservativeExtension/Lifting.lean`), a Goldblatt/BdRV-style fresh-atom naming lemma supporting the irreflexivity argument of @sec:design-choices (see @sec:conservative-extension in the Frame Classes chapter).
It is distinct from the paper's $cal(L)$-vs-$cal(L)^+$ conservative-extension theorem, which is a paper-side result: no Lean module formalizes it.

=== Axiom Correspondence

The paper presents *TM* with twelve schemata; the Lean BX system has #axiom-count constructors (granularity, not extra strength --- see the proof-theory chapter).
The paper's schemata map to Lean as follows:

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    table.header(
      [*Paper Name*], [*Lean Counterpart*], [*Status in BX*],
    ),
    table.hline(),
    [MP], [`DerivationTree.modus_ponens`], [Inference rule],
    [MN], [`DerivationTree.necessitation`], [Inference rule],
    [TD], [`DerivationTree.temporal_duality`], [Inference rule],
    [MK], [`Axiom.modal_k_dist`], [Axiom],
    [MT], [`Axiom.modal_t`], [Axiom],
    [M5], [`Axiom.modal_5_collapse`], [Axiom],
    [MF], [`Axiom.modal_future`], [Axiom],
    [TK], [`temp_k_dist_derived`], [Derived theorem],
    [T4], [`temp_4_derived`], [Derived theorem],
    [TB], [`Axiom.serial_future`], [Axiom],
    [TA], [`Axiom.connect_future`], [Axiom],
    [TL], [`Axiom.temp_linearity`], [Axiom],
    table.hline(),
  ),
  caption: none,
)

The Lean system additionally includes M4 (`Axiom.modal_4`) and MB (`Axiom.modal_b`) as primitive S5 axioms (derivable from the paper's core but convenient in Hilbert-style derivations), the full Burgess-Xu Until/Since layer with primed past mirrors, and the frame-class layers (uniformity, Prior, Z1, density) that the paper treats as extensions of *TM*.
TF ($square.stroked phi.alt arrow.r G square.stroked phi.alt$) is derived as `temp_future_derived` (`Theorems/Combinators.lean`) from MF, MT, and M4.

=== Completeness Status

The paper @brastmckie2026possibleworlds sketches completeness for *TM* and its extensions.
In Lean the completeness theorems are stated for each frame class (`completeness`, `completeness_dense`, `completeness_discrete` in `Metalogic/BXCanonical/Completeness.lean`) and approached through the canonical-model construction; the open steps lie on the construction path (chronicle construction for the dense case, discrete truth lemma and transfer), and completeness remains an open problem.
Soundness, the deduction theorem, the Lindenbaum lemma, and the perpetuity principles are fully proven.
The discrete case runs through Kamp-theorem expressiveness @kamp1971formalproperties and likewise remains open.

=== Decidability Implementation

The implementation includes a tableau-based decision procedure for validity.
Soundness is proven (`decide_sound`): if the procedure returns "valid", the formula is semantically valid.
The completeness direction rests on the finite model property, developed in `Metalogic/Decidability/FMP/`: the module is sorry-free (see the Part II "Decidability in Practice" chapter), but its `fmp_completeness` theorem quantifies over a finite closure-MCS-bundle filtration rather than directly over semantic validity, and the bridge from "true in every closure MCS bundle" to full semantic validity is an open problem.

== Design Choices <sec:design-choices>

=== Strict (Irreflexive) Temporal Semantics

The temporal operators $G$ and $H$ can be interpreted with either *strict* or *reflexive* quantification over times.
*TM* uses strict semantics --- the "A2 guard convention", documented in `Semantics/Truth.lean`:

#definition("Strict Temporal Semantics (Current)")[
  Temporal quantification excludes the present moment:
  $
    cal(M), tau, x tack.r.double G phi.alt &<=> cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" x < y \
    cal(M), tau, x tack.r.double H phi.alt &<=> cal(M), tau, y tack.r.double phi.alt "for all" y : D "where" y < x
  $
  Until and Since use a strict witness with an open guard.
  The temporal T-axioms $G phi.alt arrow.r phi.alt$ and $H phi.alt arrow.r phi.alt$ are *invalid*; seriality is supplied axiomatically (BX1/BX1$'$).
  This matches the truth conditions in @sec:truth and the paper's semantics, which quantifies tense operators strictly.
]

Under the alternative reflexive convention ($lt.eq$/$gt.eq$), the temporal T-axioms are definitionally valid, the frame-class axioms trivialize, and the completeness architecture collapses to a single theorem; the strict convention was adopted together with the Burgess-Xu axiom system precisely to preserve these distinctions.
The paper likewise distinguishes the irreflexive tense operators (primitive) from their reflexive companions (definable, but not conversely).

=== Consequences of Strict Semantics

- *Frame definability is real*: density ($G G phi.alt arrow.r G phi.alt$), discreteness (Prior/Z1), and seriality genuinely characterize frame classes, which is what makes the `Base`/`Dense`/`Discrete` frame-class parameter of the proof system meaningful.
  Under reflexive semantics all of these collapse to trivial validity.
- *Three completeness targets*: the base, dense, and discrete systems each get their own completeness statement (`completeness`, `completeness_dense`, `completeness_discrete`), matching the paper's *TM*#super[+] extensions.
- *Irreflexivity is not modally definable* @blackburnderijkevenema2001: no axiom forces the canonical accessibility to be irreflexive.
  The construction compensates with fresh-atom machinery --- the structured `Atom` type exists precisely so that a fresh atom is available outside any finite set --- and with the chronicle/transfer constructions of the metalogic chapter rather than a naive canonical model.
- *Seriality is axiomatic, not automatic*: BX1/BX1$'$ ($top arrow.r F top$, $top arrow.r P top$) require every time to have a strict successor and predecessor time, which holds in every nontrivial ordered abelian group of durations.

=== Historical Context

#remark("Prior's Tradition")[
  Arthur Prior established tense logic using *strict* semantics: $F$ and $P$ quantify over strictly future and strictly past times, and temporal axioms genuinely characterize frame properties.
  This tradition continues through Burgess @burgess1982axioms @burgess1984basic, Xu @xu1988until, Goldblatt, van Benthem, and Blackburn-de Rijke-Venema @blackburnderijkevenema2001, and the BX axiom system places the implementation squarely within it.
]

#remark("Computer Science Conventions")[
  Model checking traditions often use reflexive conventions (CTL's "AG $phi.alt$" includes the current state), trading frame-theoretic expressiveness for simpler boundary conditions.
  *TM* takes the opposite trade: reasoning about contingency across dense and discrete temporal orders requires the frame distinctions that only strict semantics can express.
]

#remark("The Reflexive Alternative")[
  A reflexive convention ($lt.eq$) yields a single collapsed completeness target in which the frame classes are indistinguishable; the strict convention ($<$, the A2 guard convention) supports the Burgess-Xu axioms, replaces the temporal T-axioms with seriality axioms, and sustains three genuinely distinct frame classes.
]
