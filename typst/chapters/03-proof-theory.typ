// ============================================================================
// 03-proof-theory.typ
// Proof Theory chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: ProofSystem/Axioms.lean (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count, rule-count, base-count, dense-only-count, ztime-only-count, rtime-only-count

= Proof Theory <sec:proof-theory>


The proof system for *TM* is the *Burgess-Xu (BX) axiom system*: a Hilbert-style calculus over the Since/Until language of @sec:formulas, with *#axiom-count axiom constructors* organized into nine layers and *#rule-count inference rules*.
The axiom constructors are exactly the paper's primitive schemata; every past mirror, and the S5 schemata 4 and B, are derived theorems (`DerivedAxioms`).
Derivations are parameterized by a *frame class* (`Base`, `Dense`, `ZTime`, or `RTime`), which gates the frame-dependent axiom layers.
The system is deliberately fine-grained at the constructor level; @sec:paper-contrast records the deferred tense-primitive subsystem and the intended presentation choices of the axiomatization.

== The Burgess-Xu Axiom System

The #axiom-count axiom schemata are the constructors of the inductive family `Axiom` in `ProofSystem/Axioms.lean`.
Throughout, $phi.alt #snce psi$ and $phi.alt #untl psi$ are the guard-first infix primitives of @sec:formulas: the *guard* $phi.alt$ holds at all strictly intermediate times and the *event* $psi$ at the witness time.
Derived operators: $P phi.alt = top #snce phi.alt$, $F phi.alt = top #untl phi.alt$, $H phi.alt = not P not phi.alt$, $G phi.alt = not F not phi.alt$, and $top = bot arrow.r bot$.
Alongside its structural name (BX1, BX2G, ...), each temporal schema carries a *short name* (TB, UG, UC, TA, ...) shown in the tables below; the short names are the citation form used when an axiom is invoked individually, and the extended systems of the metalogic chapter are picked out by which short-named axioms they add.
Past mirrors (primed rows) are the time-reflection images of their future counterparts, carry no separate short name, and are *derived theorems* rather than axiom constructors: each is proved by one application of the TR rule to its primary.

=== Layer 1: Propositional (4)

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [K], [`Axiom.prop_k`], [$(phi.alt arrow.r (psi arrow.r chi)) arrow.r ((phi.alt arrow.r psi) arrow.r (phi.alt arrow.r chi))$],
    [S], [`Axiom.prop_s`], [$phi.alt arrow.r (psi arrow.r phi.alt)$],
    [EFQ], [`Axiom.ex_falso`], [$bot arrow.r phi.alt$],
    [Peirce], [`Axiom.peirce`], [$((phi.alt arrow.r psi) arrow.r phi.alt) arrow.r phi.alt$],
    table.hline(),
  ),
  caption: none,
)

Together with modus ponens, these four schemata axiomatize classical propositional logic (K and S give the implicational fragment; EFQ and Peirce restore classical negation over the primitive $bot$).

=== Layer 2: S5 Modal (3 primitive; M4 and MB derived)

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [MT], [`Axiom.modal_t`], [$square.stroked phi.alt arrow.r phi.alt$],
    [M4], [`DerivedAxioms.modal4`], [$square.stroked phi.alt arrow.r square.stroked square.stroked phi.alt$],
    [MB], [`DerivedAxioms.modalB`], [$phi.alt arrow.r square.stroked diamond.stroked phi.alt$],
    [M5], [`Axiom.modal_5_collapse`], [$diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$],
    [MK], [`Axiom.modal_k_dist`], [$square.stroked (phi.alt arrow.r psi) arrow.r (square.stroked phi.alt arrow.r square.stroked psi)$],
    table.hline(),
  ),
  caption: none,
)

The metaphysical necessity operator $square.stroked$ is S5: it quantifies over all possible worlds at the current time.
The primitive schemata are MT, M5 and MK (the paper's `def:S5`); M4 and MB are derived from them (`DerivedAxioms.modal4`, `DerivedAxioms.modalB`).

=== Layer 3: BX Temporal (11 primitive; mirrors derived by TR)

The temporal core consists of eleven schemata in future/past mirror pairs, following Burgess @burgess1982axioms @burgess1984basic and Xu @xu1988until for Until/Since logic on linear orders.
The primed names denote past mirrors, which are derived by the TR rule rather than primitive.

#{
  show figure: set block(breakable: true)
  figure(
  table(
    columns: 4,
    stroke: none,
    align: (left, left, left, left),
    table.hline(),
    table.header([*Name*], [*Short*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [BX1], [TB], [`Axiom.serial_future`], [$F top$],
    [BX1$'$], [], [`DerivedAxioms.serialPast`], [$top arrow.r P top$],
    [BX2G], [UG], [`Axiom.left_mono_until_G`], [$G(phi.alt arrow.r chi) arrow.r ((phi.alt #untl psi) arrow.r (chi #untl psi))$],
    [BX2H], [], [`DerivedAxioms.leftMonoSinceH`], [$H(phi.alt arrow.r chi) arrow.r ((phi.alt #snce psi) arrow.r (chi #snce psi))$],
    [BX3], [UC], [`Axiom.right_mono_until`], [$G(phi.alt arrow.r psi) arrow.r ((chi #untl phi.alt) arrow.r (chi #untl psi))$],
    [BX3$'$], [], [`DerivedAxioms.rightMonoSince`], [$H(phi.alt arrow.r psi) arrow.r ((chi #snce phi.alt) arrow.r (chi #snce psi))$],
    [BX4], [TA], [`Axiom.connect_future`], [$phi.alt arrow.r G P phi.alt$],
    [BX4$'$], [], [`DerivedAxioms.connectPast`], [$phi.alt arrow.r H F phi.alt$],
    [BX5], [UF], [`Axiom.self_accum_until`], [$(phi.alt #untl psi) arrow.r ((phi.alt and (phi.alt #untl psi)) #untl psi)$],
    [BX5$'$], [], [`DerivedAxioms.selfAccumSince`], [$(phi.alt #snce psi) arrow.r ((phi.alt and (phi.alt #snce psi)) #snce psi)$],
    [BX6], [UI], [`Axiom.absorb_until`], [$(phi.alt #untl (phi.alt and (phi.alt #untl psi))) arrow.r (phi.alt #untl psi)$],
    [BX6$'$], [], [`DerivedAxioms.absorbSince`], [$(phi.alt #snce (phi.alt and (phi.alt #snce psi))) arrow.r (phi.alt #snce psi)$],
    [BX7], [CN], [`Axiom.linear_until`], [$(phi.alt #untl psi) and (chi #untl theta) arrow.r ((phi.alt and chi) #untl (psi and theta)) or (((phi.alt and chi) #untl (psi and chi)) or ((phi.alt and chi) #untl (phi.alt and theta)))$],
    [BX7$'$], [], [`DerivedAxioms.linearSince`], [$(phi.alt #snce psi) and (chi #snce theta) arrow.r ((phi.alt and chi) #snce (psi and theta)) or ((phi.alt and chi) #snce (psi and chi)) or ((phi.alt and chi) #snce (phi.alt and theta))$],
    [BX10], [UE], [`Axiom.until_F`], [$(phi.alt #untl psi) arrow.r F psi$],
    [BX10$'$], [], [`DerivedAxioms.sinceP`], [$(phi.alt #snce psi) arrow.r P psi$],
    [BX11], [TL], [`Axiom.temp_linearity`], [$F phi.alt and F psi arrow.r F(F phi.alt and psi) or (F(phi.alt and psi) or F(phi.alt and F psi))$],
    [BX11$'$], [], [`DerivedAxioms.tempLinearityPast`], [$P phi.alt and P psi arrow.r P(phi.alt and psi) or P(phi.alt and P psi) or P(P phi.alt and psi)$],
    [BX12], [UT], [`Axiom.F_until_equiv`], [$F phi.alt arrow.r (top #untl phi.alt)$],
    [BX12$'$], [], [`DerivedAxioms.pSinceEquiv`], [$P phi.alt arrow.r (top #snce phi.alt)$],
    [BX13], [SU], [`Axiom.enrichment_until`], [$p and (phi.alt #untl psi) arrow.r (phi.alt #untl (psi and (phi.alt #snce p)))$],
    [BX13$'$], [], [`DerivedAxioms.enrichmentSince`], [$p and (phi.alt #snce psi) arrow.r (phi.alt #snce (psi and (phi.alt #untl p)))$],
    table.hline(),
  ),
  caption: [BX temporal layer. Gaps in the structural numbering (BX2, BX8, BX9, BX14) mark schemata of Burgess @burgess1982axioms that were removed as unsound or unnecessary under the strict-witness/open-guard semantics; see the source comments in `ProofSystem/Axioms.lean`. TB, TL and CN are stated as the paper states them, with 3-way disjunctions right-associated; their pre-paper forms ($top arrow.r F top$, and TL and CN in the former disjunct order and grouping) are derived (`DerivedAxioms.serialFutureImp`, `DerivedAxioms.tempLinearityLegacy`, `DerivedAxioms.linearUntilLegacy`). The primed rows are derived by TR.],
  )
}

Highlights of the layer:
- *Seriality* (BX1/BX1$'$) replaces the temporal T-axioms, which are invalid under the strict semantics: every time has a strictly later and a strictly earlier time.
- *Monotonicity* (BX2G/BX2H, BX3/BX3$'$) lets Until and Since respect implications holding over the guard interval and at the event.
- *Connectedness* (BX4/BX4$'$) places the present in the past of every future time and in the future of every past time.
- *Self-accumulation and absorption* (BX5/BX6 and mirrors) resolve Until-eventualities axiomatically: an eventuality enriches its own guard, and deferred eventualities collapse.
- *Linearity* (BX7, BX11 and mirrors) orders witnesses linearly, as required on linear temporal orders.
- *Eventuality bridges* (BX10, BX12 and mirrors) connect Until/Since to the derived $F$/$P$ operators.
- *Enrichment* (BX13/BX13$'$, Burgess A3a/A3b @burgess1982axioms) carries information about the current point into the event of an Until/Since formula.

=== Layer 4: Modal-Temporal Interaction (1)

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [MF], [`Axiom.modal_future`], [$square.stroked phi.alt arrow.r square.stroked G phi.alt$],
    table.hline(),
  ),
  caption: none,
)

MF is the sole bimodal interaction axiom: necessary truths remain necessary in the future.
Its companion TF ($square.stroked phi.alt arrow.r G square.stroked phi.alt$) is *derived* (see @sec:derived-axioms).

=== Layer 5: Uniformity (4)

The uniformity axioms concern the discreteness witness $bot #untl top$ ("there is an immediate successor": the guard interval to the witness is empty).
They encode the *uniformity of discreteness* in ordered abelian groups --- by translation invariance, a gap at one point exists at every point and in every accessible world --- and are therefore valid on *all* frames (frame class `Base`).

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Short*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [NP], [`Axiom.discrete_symm_fwd`], [$(bot #untl top) arrow.r (bot #snce top)$],
    [], [`DerivedAxioms.discreteSymmBwd`], [$(bot #snce top) arrow.r (bot #untl top)$],
    [NF], [`Axiom.discrete_propagate_fwd`], [$(bot #untl top) arrow.r G(bot #untl top)$],
    [NA], [`Axiom.discrete_propagate_bwd`], [$(bot #untl top) arrow.r H(bot #untl top)$],
    [NB], [`Axiom.discrete_box_necessity`], [$(bot #untl top) arrow.r square.stroked (bot #untl top)$],
    table.hline(),
  ),
  caption: [`discrete_symm_bwd` is the converse of NP, derived by time reflection, and carries no separate short name.],
)

=== Layers 6--7: Prior and Z1 (2, discrete-only)

Valid on discrete linear orders (frame class `ZTime`), these axioms encode well-ordering for definable sets. Prior-SZ is the TR mirror of Prior-UZ, derived at every frame class that admits UZ.

#figure(
  table(
    columns: 4,
    stroke: none,
    align: (left, left, left, left),
    table.hline(),
    table.header([*Name*], [*Short*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [Prior-UZ], [UZ], [`Axiom.prior_UZ`], [$F phi.alt arrow.r (not phi.alt #untl phi.alt)$],
    [Prior-SZ], [], [`DerivedAxioms.priorSZ`], [$P phi.alt arrow.r (not phi.alt #snce phi.alt)$],
    [Z1], [Z1], [`Axiom.z1`], [$G(G phi.alt arrow.r phi.alt) arrow.r (F G phi.alt arrow.r G phi.alt)$],
    table.hline(),
  ),
  caption: none,
)

Prior-UZ says that if $phi.alt$ holds somewhere in the future, there is a *nearest* future $phi.alt$-point @reynolds1992 (Venema's axiom (W)); Z1 is the characteristic backward-induction axiom of successor-Archimedean orders such as $ZZ$ @doets1987.

=== Layer 8: Density (2, dense-only)

Valid on densely ordered frames (frame class `Dense`).

#figure(
  table(
    columns: 4,
    stroke: none,
    align: (left, left, left, left),
    table.hline(),
    table.header([*Name*], [*Short*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [DN], [DN], [`Axiom.density`], [$G G phi.alt arrow.r G phi.alt$],
    [DI], [NN], [`Axiom.dense_indicator`], [$not (bot #untl top)$],
    table.hline(),
  ),
  caption: none,
)

On a dense order no point has an immediate successor, so the discreteness witness $bot #untl top$ is false everywhere (DI, the Burgess density axiom for Until/Since @burgess1982axioms).
DI is included alongside DN because the density schema alone provably fails to derive it.

=== Layer 9: Reynolds Dedekind (2, Dedekind-only)

Valid on the RTime frame class (dense-and-complete, real-flow orders), these axioms are Reynolds' definable-gap-freeness triple for Until/Since over the reals @reynolds1992, less the past form of Prior-U, which is derived.
They are stated with the recurrence abbreviations
$ K^+ phi.alt := not (not phi.alt #untl top), quad quad K^- phi.alt := not (not phi.alt #snce top), $
where $K^+ phi.alt$ says that $phi.alt$ recurs arbitrarily soon in the future and $K^- phi.alt$ that it recurred arbitrarily recently in the past.

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Short*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [Prior-U], [`Axiom.prior_U_gap`], [$(phi.alt #untl top) and F not phi.alt arrow.r (phi.alt #untl (not phi.alt or K^+ not phi.alt))$],
    [], [`DerivedAxioms.priorSGap`], [$(phi.alt #snce top) and P not phi.alt arrow.r (phi.alt #snce (not phi.alt or K^- not phi.alt))$],
    [Sep], [`Axiom.sep`], [$K^+ phi.alt and not K^+ (phi.alt and (not phi.alt #untl phi.alt)) arrow.r K^+ (K^+ phi.alt and K^- phi.alt)$],
    table.hline(),
  ),
  caption: [Only the future/until direction of Prior-U is axiomatic; its past mirror `prior_S_gap` is the time-reflection image, derived. These axioms enforce *definable* Dedekind completeness --- no temporal formula characterizes completeness outright.],
)

Prior-U says a bounded region where $phi.alt$ has held throughout acquires a definable upper endpoint; Sep is Reynolds' separation axiom, semantically backed by the separability of the reals.
The axiom CO ($triangle.stroked.t (H phi.alt arrow.r F H phi.alt) arrow.r (H phi.alt arrow.r G phi.alt)$) is *derivable* over this layer rather than axiomatic: it follows from Prior-U together with the base axioms alone (`Theorems/DedekindDerived.lean` `coDerived`).

== Frame Classes <sec:frame-classes>

Derivations are parameterized by a frame class, making frame-dependent reasoning a structural invariant rather than a side condition.

#definition("Frame Class")[
  The type `FrameClass` has four values: `Base`, `Dense`, `ZTime`, and `RTime`, partially ordered with `Base` below every other class, `RTime` above `Dense`, and `ZTime` incomparable with both `Dense` and `RTime`:
  $ "Base" lt.eq "Dense" lt.eq "RTime", quad quad "Base" lt.eq "ZTime". $
  Each axiom constructor is assigned a minimum frame class by `Axiom.minFrameClass`: the #base-count axioms of layers 1--5 are `Base`; Prior-UZ and Z1 (#ztime-only-count axioms) are `ZTime`; DN and DI (#dense-only-count axioms) are `Dense`; Prior-U and Sep (#rtime-only-count axioms) are `RTime`. The derived mirrors Prior-SZ and Prior-S are theorems at the class of their primaries.
]

The axiom rule of the proof system admits an axiom into a derivation at frame class `fc` only when its minimum frame class is at most `fc`.
Derivations are monotone along the order: `DerivationTree.lift` coerces a derivation at a lower frame class into one at any higher class.

The four classes carry the book's hierarchy of proof systems: `Base` is the base system *TM* itself; `Dense` is the dense extension *TM*#sub[d] (adding DN and DI); `ZTime` is the discrete extension *TM*#sub[f] (adding UZ, its mirror, and Z1); and `RTime` is the complete extension *TM*#sub[c] (adding the Reynolds triple of Layer 9, for the dense-and-complete, real-flow orders).
The frame-classes chapter of Part II develops the semantic side of this correspondence in detail.

== Derived Axioms <sec:derived-axioms>

Several schemata that are primitive axioms of the tense-primitive subsystem's twelve-schema presentation (@sec:paper-contrast) are *derived theorems* of BX:

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Schema*], [*Derived As*]),
    table.hline(),
    [TK], [$G(phi.alt arrow.r psi) arrow.r (G phi.alt arrow.r G psi)$], [`temporalKDistDerived` (`Theorems/TemporalDerived.lean`)],
    [T4], [$G phi.alt arrow.r G G phi.alt$], [`temporal4Derived` (`Theorems/TemporalDerived.lean`)],
    [TF], [$square.stroked phi.alt arrow.r G square.stroked phi.alt$], [`temporalFutureDerived` (`Theorems/Combinators.lean`)],
    table.hline(),
  ),
  caption: none,
)

TK and T4 follow from the BX Until/Since axioms; TF follows from MF together with MT and M4.
The short names of the layer tables above locate the remaining schemata of that presentation among the BX axioms directly: TB (seriality) is BX1 `serial_future`, TA is BX4 `connect_future`, and TL (future linearity) is BX11 `temp_linearity`.

== Inference Rules

The proof system has #rule-count inference rules, given as the constructors of `DerivationTree`.
Here $Gamma tack.r_(f c) phi.alt$ abbreviates `DerivationTree fc Γ φ`; the plain turnstile $Gamma tack.r phi.alt$ fixes the frame class to `Base`.

#definition("Axiom Rule")[
  If $phi.alt$ matches an axiom schema whose minimum frame class is at most $f c$, then $Gamma tack.r_(f c) phi.alt$.
]

#definition("Assumption Rule")[
  If $phi.alt in Gamma$, then $Gamma tack.r_(f c) phi.alt$.
]

#definition("Modus Ponens")[
  $
    (Gamma tack.r_(f c) phi.alt arrow.r psi quad quad Gamma tack.r_(f c) phi.alt) / (Gamma tack.r_(f c) psi)
  $
]

#definition("Necessitation")[
  $
    (tack.r_(f c) phi.alt) / (tack.r_(f c) square.stroked phi.alt)
  $
  Applies only to theorems (empty context).
]

#definition("Temporal Necessitation")[
  $
    (tack.r_(f c) phi.alt) / (tack.r_(f c) G phi.alt)
  $
  Applies only to theorems (empty context).
]

#definition("Time Reflection")[
  $
    (tack.r_(f c) phi.alt) / (tack.r_(f c) chevron.l S chevron.r phi.alt)
  $
  Applies only to theorems (empty context).
]

#definition("Weakening")[
  $
    (Gamma tack.r_(f c) phi.alt quad quad Gamma subset.eq Delta) / (Delta tack.r_(f c) phi.alt)
  $
]

#let derivation-tree-rule(name) = raw(name.replace(".", "." + sym.zws))
#figure(
  table(
    columns: (auto, 1fr, auto),
    stroke: none,
    table.hline(),
    table.header(
      [*Rule*], [*Lean Constructor*], [*Context Requirement*],
    ),
    table.hline(),
    [Axiom], [#derivation-tree-rule("DerivationTree.axiom")], [Any (gated by `minFrameClass`)],
    [Assumption], [#derivation-tree-rule("DerivationTree.assumption")], [Any],
    [Modus Ponens], [#derivation-tree-rule("DerivationTree.modus_ponens")], [Any],
    [Necessitation], [#derivation-tree-rule("DerivationTree.necessitation")], [Empty only],
    [Temp. Necessitation], [#derivation-tree-rule("DerivationTree.temporal_necessitation")], [Empty only],
    [Time Reflection], [#derivation-tree-rule("DerivationTree.time_reflection")], [Empty only],
    [Weakening], [#derivation-tree-rule("DerivationTree.weakening")], [Any],
    table.hline(),
  ),
  caption: none,
)

== Derivation Trees

Derivations are represented as inductive trees.

#definition("Derivation Tree")[
  `DerivationTree fc Γ φ` (written $Gamma tack.r_(f c) phi.alt$) is an inductive type representing a derivation of $phi.alt$ from context $Gamma$ at frame class $f c$, using only axioms whose minimum frame class is at most $f c$.
]

#definition("Height")[
  The height of a derivation tree:
  - Base cases (axiom, assumption): height 0
  - Unary rules: height of subderivation + 1
  - Modus ponens: max of both subderivations + 1
]

`DerivationTree` is a `Type` (not a `Prop`), so derivations can be pattern-matched and measured; the height function enables well-founded recursion in metalogical proofs (notably the deduction theorem).

// CONFIRM(paper): def:S5 + def:BX + def:TMplus jointly state the system this chapter axiomatizes.
//   The three anchor ids are unchanged, but their texts moved in the paper's 2026-09 wave: all
//   three now cite the Logic/Extensions sections for their axioms instead of displaying them, and
//   def:TMplus names the system TM (no + superscript) for the language BL (no + superscript),
//   with extensions TM_z / TM_d / TM_r over BX_z / BX_d / BX_r.
== The Tense-Primitive Subsystem <sec:paper-contrast>

The system of this chapter takes Since and Until as its temporal primitives.
There is also a *tense-primitive subsystem*: the logic of the one-place $H$/$G$ sublanguage (@sec:formulas), presentable economically as extending classical propositional logic to include twelve schemata --- the rules MP, MN, and TR, and the axioms MK, MT, M5, MF, TK, T4, TB, TA, and TL.
That subsystem is *deferred* in this book: its axiom map is recorded in the back matter's design-notes chapter, and the Frame Classes chapter's conservativity note states what its intended future development delivers.
The full system presented here is the book's object of study throughout.

Several presentation choices of the axiomatization are *design facts*, intended rather than incidental:

- *CPL is spelled out*: classical propositional logic is often subsumed in a single phrase; this axiomatization lists its four Hilbert schemata (Layer 1) explicitly, so that derivations are fully constructor-level.
- *S5 is the paper's*: the primitives are MT, M5 and MK; M4 and MB are derived theorems (`DerivedAxioms.modal4`, `DerivedAxioms.modalB`).
- *Since/Until is the temporal engine*: with the two-place primitives, TK and T4 become derived theorems, and TB, TA, TL live inside the BX layer (@sec:derived-axioms).
- *Past mirrors are derived*: past duals are generated by the TR rule alone, so the primed mirrors (BX1$'$--BX13$'$) are derived theorems with context-lifted forms (`DerivedAxioms`), not axiom constructors, exactly as in the paper.
- *Frame-class axioms are gated structurally*: the extensions *TM*#sub[f], *TM*#sub[d], and *TM*#sub[c] are the `ZTime`, `Dense`, and `RTime` frame classes of @sec:frame-classes rather than separately axiomatized systems.

== Notation

#figure(
  table(
    columns: 2,
    stroke: none,
    table.hline(),
    table.header(
      [*Notation*], [*Lean*],
    ),
    table.hline(),
    [$Gamma tack.r phi.alt$], [`Γ ⊢ φ` i.e. `DerivationTree FrameClass.Base Γ φ`],
    [$Gamma tack.r_(f c) phi.alt$], [`Γ ⊢[fc] φ` i.e. `DerivationTree fc Γ φ`],
    [$tack.r phi.alt$], [`DerivationTree FrameClass.Base [] φ`],
    table.hline(),
  ),
  caption: none,
)
