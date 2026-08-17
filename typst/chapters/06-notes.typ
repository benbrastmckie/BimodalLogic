// ============================================================================
// 06-notes.typ
// Notes chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: FormalSystem/ (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count, rule-count

= Notes <sec:notes>


== System Overview

The book's system comprises the syntax (six primitive constructors over the Since/Until basis), the task-frame semantics with strict truth conditions, and the BX proof system (#axiom-count axiom constructors in nine layers, #rule-count inference rules, frame-class parameter).
Soundness for all four frame classes (Base, Dense, Discrete, Dedekind), the deduction theorem, and the perpetuity principles P1--P6 are carried by the anchors of @sec:metalogic; the canonical-model construction (`Metalogic/BXCanonical/`) carries the completeness theorems stated there.
The tableau decision procedure is presented operationally in the Decidability-in-Practice chapter.
// CONFIRM(lean): scripts/typst-status-counts.sh --json reports sorry_total_excl_boneyard = 0

== Design Notes

This chapter records the *permanent, intended* design facts of the mechanized presentation --- choices made deliberately, not progress markers.

=== Terminology

- The perpetuity principles are named P1--P6, in prose and in the Lean code alike.
- The notation $triangle.stroked.t$ and $triangle.stroked.b$ for "always" and "sometimes" corresponds to the Lean derived operators `always` and `sometimes`.
- There is no *Reflection* axiom: negative durations come from the converse convention of the task-relation definition, packaged as the Lean field `converse` (in biconditional form); *Nullity* is a derived lemma, not an axiom, strengthened to the Lean field `nullity_identity` (the Task Frames section of the Semantics chapter has the full account of that strengthening as a design fact of the mechanization).

=== Language Basis

The book's language takes Since and Until as its temporal primitives; `snce` and `untl` are the primitive constructors, and $P$/$F$/$H$/$G$ are derived (see @sec:formulas).
The tense-primitive sublanguage --- one-place $H$ and $G$ primitive, no Since or Until --- embeds into the full language unconditionally; the subsystem axiomatized over it is *deferred*, and a proof-system conservativity theorem relating it to the full system is that subsystem's own future result (@sec:conservative-extension in the Frame Classes chapter).

=== The Deferred Subsystem's Axiom Map

The deferred tense-primitive subsystem is presented economically by twelve schemata.
This table is the subsystem's axiom map: it records, for each of the twelve, where its content lives in the book's full system.

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    table.header(
      [*Name*], [*Lean Counterpart*], [*Status in BX*],
    ),
    table.hline(),
    [MP], [`DerivationTree.modus_ponens`], [Inference rule],
    [MN], [`DerivationTree.necessitation`], [Inference rule],
    [TD], [`DerivationTree.temporal_duality`], [Inference rule],
    [MK], [`Axiom.modal_k_dist`], [Axiom],
    [MT], [`Axiom.modal_t`], [Axiom],
    [M5], [`Axiom.modal_5_collapse`], [Axiom],
    [MF], [`Axiom.modal_future`], [Axiom],
    [TK], [`temporalKDistDerived`], [Derived theorem],
    [T4], [`temporal4Derived`], [Derived theorem],
    [TB], [`Axiom.serial_future`], [Axiom],
    [TA], [`Axiom.connect_future`], [Axiom],
    [TL], [`Axiom.temp_linearity`], [Axiom],
    table.hline(),
  ),
  caption: none,
)

The full system additionally includes M4 (`Axiom.modal_4`) and MB (`Axiom.modal_b`) as primitive S5 axioms (derivable from the core but convenient in Hilbert-style derivations), the full Burgess-Xu Since/Until layer with primed past mirrors, and the frame-class layers (uniformity, Prior, Z1, density, Reynolds Dedekind) that gate the extended systems.
TF ($square.stroked phi.alt arrow.r G square.stroked phi.alt$) is derived as `temporalFutureDerived` (`Theorems/Combinators.lean`) from MF, MT, and M4.

=== Completeness

// LEAN-ANCHOR-MAY-MOVE: canonical-completeness -- see typst/README.md
The completeness theorems of the system --- strong over the Base and Dense classes, weak over $ZZ$-time and the dense-and-complete class, with the strong forms provably false over the non-compact flows --- are stated once, in the metalogic chapter (@sec:metalogic), and are not restated here.
The discrete case runs through Kamp-theorem expressiveness @kamp1971formalproperties; a machine-checked Kamp theorem is a separate result in its own right (@ch:vlach-blstar), distinct from the completeness theorems.

=== Decidability

The tableau-based decision procedure, its correctness properties, and its finite-model-property component are presented in the Decidability-in-Practice chapter of Part II, which also carries the decidability obligations.

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
  This matches the truth conditions in @sec:truth.
]

Under the alternative reflexive convention ($lt.eq$/$gt.eq$), the temporal T-axioms are definitionally valid, the frame-class axioms trivialize, and the completeness architecture collapses to a single theorem; the strict convention was adopted together with the Burgess-Xu axiom system precisely to preserve these distinctions.
The irreflexive tense operators (primitive) are distinguished from their reflexive companions, which are definable from them --- but not conversely.

=== Consequences of Strict Semantics

- *Frame definability is real*: density ($G G phi.alt arrow.r G phi.alt$), discreteness (Prior/Z1), and seriality genuinely characterize frame classes, which is what makes the `Base`/`Dense`/`Discrete` frame-class parameter of the proof system meaningful.
  Under reflexive semantics all of these collapse to trivial validity.
- *Four completeness targets*: the base, dense, discrete, and Dedekind systems each get their own soundness statement (`soundness`, `soundness_dense`, `soundness_discrete`, `soundness_dedekind`) and their own completeness theorem, each in the strongest form its frame class admits (@sec:metalogic).
- *Irreflexivity is not modally definable* @blackburnderijkevenema2001: no axiom forces the canonical accessibility to be irreflexive.
  The construction compensates with fresh-atom machinery --- the structured `Atom` type exists precisely so that a fresh atom is available outside any finite set --- and with the chronicle/transfer constructions of the metalogic chapter rather than a naive canonical model.
- *Seriality is axiomatic, not automatic*: BX1/BX1$'$ ($top arrow.r F top$, $top arrow.r P top$) require every time to have a strict successor and predecessor time, which holds in every nontrivial ordered abelian group of durations.

=== S5-Hood Does Not Single Out Metaphysical Necessity

#remark("Why S5 Alone Underdetermines the Reading of Box")[
  $square.stroked$ is S5 because $H_(cal(F))$-quantification is an equivalence-free but frame-wide universal: nothing about the *proof system* forces the reading "necessarily" onto $square.stroked$ rather than some other modality that happens to validate the same schemata.
  The point is made by a deliberately close counterexample rather than an abstract worry: a *stability* operator $op("Stability") phi.alt$, true at a possible world $tau$ and time $x$ just in case $phi.alt$ holds at every possible world *agreeing with $tau$ at $x$* (not every possible world whatsoever), is monomodal S5 for exactly the same reason $square.stroked$ is --- membership in the same equivalence class --- yet it is manifestly *not* metaphysical necessity: for non-temporal $phi.alt$ it collapses to the trivial modality, since agreement at $x$ already fixes $phi.alt$'s truth value there.
  S5-hood is therefore necessary but not sufficient for the metaphysical-necessity reading; what does the further work is the specific choice to quantify over *all* of $H_(cal(F))$ rather than a restricted equivalence class, which is a modeling decision the axioms alone do not force.
]#footnote[Stability quantifies over the agreement class $chevron.l tau chevron.r_x := { sigma in H_(cal(F)) : sigma(x) = tau(x) }$; the Vlach/BL#super[⋆] chapter develops the restricted-modality apparatus. @bacon2022necessities]
// CONFIRM(paper): sub:RestrictedModalities develops the restricted-modality material this note mentions.

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
  A reflexive convention ($lt.eq$) yields a single collapsed completeness target in which the frame classes are indistinguishable; the strict convention ($<$, the A2 guard convention) supports the Burgess-Xu axioms, replaces the temporal T-axioms with seriality axioms, and sustains four genuinely distinct frame classes (Base, Dense, Discrete, Dedekind).
]
