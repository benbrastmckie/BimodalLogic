// ============================================================================
// 04-metalogic.typ
// Metalogic chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: FormalSystem/ (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count

= Metalogic


The metalogic for the bimodal logic *TM* relates the BX proof system of the previous chapter to the task semantics.
Soundness is fully proven for all three frame classes.
Completeness is approached through a canonical-model construction developed end-to-end for each frame class; the argument's open steps lie in the chronicle construction for the dense case and in the discrete transfer pipeline, and the completeness of *TM* remains an open problem.
The chapter closes with the tableau-based decision procedure and the live module structure of `Metalogic/`.

== Soundness

Soundness establishes that only logical consequences are derivable.
It is proven separately for each frame class, matching the `FrameClass` parameter on derivations.

#theorem("Soundness")[
  If $Gamma tack.r phi.alt$ then $Gamma tack.r.double phi.alt$.#footnote[Proven sorry-free as `soundness` in `Metalogic/Soundness.lean`.]
]

#theorem("Frame-Class Soundness")[
  Derivability at frame class `Dense` (respectively `Discrete`) implies validity over densely ordered (respectively discrete) task frames.#footnote[Proven sorry-free as `soundness_dense` in `Metalogic/DenseSoundness.lean` and `soundness_discrete` in `Metalogic/DiscreteSoundness.lean`.]
]

The proof proceeds by induction on the derivation structure:
- *Axioms*: Each of the #axiom-count axiom constructors is proven valid on the frames of its minimum frame class (base axioms on all linear orders, `density`/`dense_indicator` on dense orders, `prior_UZ`/`prior_SZ`/`z1` on discrete orders)
- *Assumptions*: Assumed formulas are true by hypothesis
- *Modus ponens*: Validity preserved under implication elimination
- *Necessitation*: Valid formulas become necessarily valid
- *Temporal necessitation*: Valid formulas become always-future valid
- *Temporal duality*: Past-future swap preserves validity
- *Weakening*: Adding premises preserves semantic consequence

The axiom validity lemmas live in `Metalogic/SoundnessLemmas/` (with `Core.lean`, `DenseValidity.lean`, and `FrameClassVariants.lean`), and the frame-condition semantics for the Base/Dense/Discrete classes is developed in the top-level `FrameConditions/` directory.
The modal-temporal interaction axiom MF uses time-shift invariance (via `time_shift` on world histories) to relate truth at different times.

== Core Infrastructure

The completeness proof requires three foundational components: the deduction theorem, maximal consistent sets, and Lindenbaum's lemma.

=== Deduction Theorem

#theorem("Deduction Theorem")[
  If $A :: Gamma tack.r B$ then $Gamma tack.r A arrow.r B$.#footnote[Proven in `Metalogic/Core/`; see `deduction_theorem`.]
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

The completeness theorem is stated for each frame class, with the base-class theorem as the primary entry point.

#theorem("Completeness (Base)")[
  If $tack.r.double phi.alt$, then there is a derivation of $phi.alt$ at frame class `Base`.#footnote[Stated as `completeness` in `Metalogic/BXCanonical/Completeness.lean`: `valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)`. The open steps of the proof are described at the end of this section.]
]

#theorem("Completeness (Dense, Discrete)")[
  Validity over densely ordered frames implies derivability at frame class `Dense`; validity over discrete frames implies derivability at frame class `Discrete`.#footnote[Stated as `completeness_dense` and `completeness_discrete` in `Metalogic/BXCanonical/Completeness.lean`.]
]

=== Proof Architecture

The proof is by contraposition.
If $phi.alt$ is not derivable, then ${not phi.alt}$ is consistent, and Lindenbaum's lemma extends it to an MCS $M$ containing $not phi.alt$.
A countermodel for $phi.alt$ is then built from $M$ by a three-way case split on the discreteness indicator $U(top, bot)$ ("there is an immediate successor"):

+ *Dense case* ($square.stroked not U(top, bot) in M$): a countermodel is constructed on the rational timeline $QQ$ via the Burgess-style *chronicle construction* @burgess1982axioms.#footnote[`Metalogic/BXCanonical/Chronicle/`, entry point `countermodel_dense` in `ChronicleToCountermodelBasic.lean`, drawing on the D-parametric truth lemma in `Metalogic/Algebraic/`.]
+ *Discrete case* ($square.stroked U(top, bot) in M$): a countermodel is constructed on the integer timeline $ZZ$ via the Reynolds/Doets pipeline @reynolds1992 @doets1987.#footnote[`Metalogic/WeakCanonical/`, transfer step in `WeakCanonical/Transfer.lean`.]
+ *Mixed case*: eliminated outright --- an MCS cannot be undecided about discreteness.#footnote[`mcs_mixed_case_absurd` in `Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean`.]

The construction rests on shared infrastructure:
- *Bundled families of MCSs* (`Metalogic/Bundle/`): time-indexed families of maximal consistent sets with G/H coherence conditions, used by all completeness paths.
- *Algebraic parametric completeness* (`Metalogic/Algebraic/`): a truth lemma parametric in the duration type $D$, which turns a coherent MCS family into a task model.
- *Chronicles* (`Metalogic/BXCanonical/Chronicle/`): the Burgess @burgess1982axioms dense-order construction, filling in witnesses for Until/Since eventualities over $QQ$.
- *Filtration and quasimodels* (`Metalogic/BXCanonical/Filtration/`, `Quasimodel/`): finitary approximations used in the canonical chain construction.

=== Open Steps in the Completeness Argument

The completeness of *TM* with respect to its frame classes is an open problem.
The open steps are concentrated in the chronicle construction (coherence of the constructed MCS family) and in the discrete-case truth lemma and transfer (`WeakCanonical/TruthLemma.lean`, `Transfer.lean`, and the Kamp-style expressiveness modules @kamp1971formalproperties).
The discrete path runs through a Kamp-theorem-based expressive-completeness argument, developed in `WeakCanonical/`, which likewise remains open.

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
    [`Core/`], [MCS theory, provability interface, deduction theorem],
    [`Bundle/`], [Time-indexed MCS families (BFMCS) with coherence conditions],
    [`Algebraic/`], [D-parametric algebraic completeness and truth lemma],
    [`BXCanonical/`], [Completeness theorem; `Chronicle/` (dense case), `Filtration/`, `Quasimodel/`],
    [`WeakCanonical/`], [Reynolds/Doets discrete completeness path; `Separation/`; Kamp-style expressiveness modules],
    [`ConservativeExtension/`], [Conservative extension results],
    [`Decidability/`], [Tableau decision procedure; `FMP/` finite model property],
    [`SoundnessLemmas/`], [Per-axiom validity lemmas, dense/discrete variants],
    [`Soundness.lean`], [Soundness theorem (sorry-free)],
    [`DenseSoundness.lean`, `DiscreteSoundness.lean`], [Frame-class soundness (sorry-free)],
    [`Completeness.lean`], [MCS properties and Lindenbaum lemma],
    [`Decidability.lean`], [Decidability interface],
    table.hline(),
  ),
  caption: [Live `Metalogic/` module structure.],
)

== Implementation Status

Soundness in all three frame-class variants, the deduction theorem, the MCS/Lindenbaum infrastructure, the perpetuity principles P1--P6, and the entire `Syntax/`, `Semantics/`, `ProofSystem/`, and `Theorems/` trees are fully proven in Lean under `FormalSystem/`.
The canonical-model construction toward completeness is developed end-to-end for each frame class, with the open steps localized as described above; completeness itself remains an open problem.
The decision procedure's soundness (`decide_sound`) and the finite-filtration FMP statement (`fmp_completeness`) are likewise proven, with the semantic-validity bridge treated in @sec:decidability-practice.

=== Semantic Convention

The completeness architecture is built for the *strict (irreflexive) temporal semantics* of @sec:truth: G and H quantify over strictly future and strictly past times, so the temporal T-axioms $G phi.alt arrow.r phi.alt$ and $H phi.alt arrow.r phi.alt$ are *not* valid, and seriality is supplied axiomatically by BX1/BX1$'$.#footnote[`Semantics/Truth.lean` and the module docstring of `Metalogic.lean` document this convention.]

