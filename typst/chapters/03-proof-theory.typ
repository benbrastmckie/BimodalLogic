// ============================================================================
// 03-proof-theory.typ
// Proof Theory chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: ProofSystem/Axioms.lean (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *
#import "../generated/status.typ": axiom-count, rule-count, base-count, dense-only-count, discrete-only-count

= Proof Theory <sec:proof-theory>


The Lean proof system for *TM* is the *Burgess-Xu (BX) axiom system*: a Hilbert-style calculus over the Until/Since language of @sec:formulas, with *#axiom-count axiom constructors* organized into eight layers and *#rule-count inference rules*.
Derivations are parameterized by a *frame class* (`Base`, `Dense`, or `Discrete`), which gates the frame-dependent axiom layers.
The system is deliberately more fine-grained than the economical 12-schema presentation of *TM* in @brastmckie2026possibleworlds; the correspondence is explained in @sec:paper-contrast.

== The Burgess-Xu Axiom System

The #axiom-count axiom schemata are the constructors of the inductive family `Axiom` in `ProofSystem/Axioms.lean`.
Throughout, $U(phi.alt, psi)$ and $S(phi.alt, psi)$ follow the *Burgess convention* used by the Lean constructors `untl`/`snce`: the first argument is the *event* (true at the witness time) and the second is the *guard* (true at all strictly intermediate times); see @sec:formulas.
Derived operators: $F phi.alt = U(phi.alt, top)$, $P phi.alt = S(phi.alt, top)$, $G phi.alt = not F not phi.alt$, $H phi.alt = not P not phi.alt$, and $top = bot arrow.r bot$.

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

=== Layer 2: S5 Modal (5)

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [MT], [`Axiom.modal_t`], [$square.stroked phi.alt arrow.r phi.alt$],
    [M4], [`Axiom.modal_4`], [$square.stroked phi.alt arrow.r square.stroked square.stroked phi.alt$],
    [MB], [`Axiom.modal_b`], [$phi.alt arrow.r square.stroked diamond.stroked phi.alt$],
    [M5], [`Axiom.modal_5_collapse`], [$diamond.stroked square.stroked phi.alt arrow.r square.stroked phi.alt$],
    [MK], [`Axiom.modal_k_dist`], [$square.stroked (phi.alt arrow.r psi) arrow.r (square.stroked phi.alt arrow.r square.stroked psi)$],
    table.hline(),
  ),
  caption: none,
)

The metaphysical necessity operator $square.stroked$ is S5: it quantifies over all admissible world histories at the current time.

=== Layer 3: BX Temporal (22)

The temporal core consists of eleven schemata in future/past mirror pairs, following Burgess @burgess1982axioms @burgess1984basic and Xu @xu1988until for Until/Since logic on linear orders.
The primed names denote past mirrors.

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [BX1], [`Axiom.serial_future`], [$top arrow.r F top$],
    [BX1$'$], [`Axiom.serial_past`], [$top arrow.r P top$],
    [BX2G], [`Axiom.left_mono_until_G`], [$G(phi.alt arrow.r chi) arrow.r (U(psi, phi.alt) arrow.r U(psi, chi))$],
    [BX2H], [`Axiom.left_mono_since_H`], [$H(phi.alt arrow.r chi) arrow.r (S(psi, phi.alt) arrow.r S(psi, chi))$],
    [BX3], [`Axiom.right_mono_until`], [$G(phi.alt arrow.r psi) arrow.r (U(phi.alt, chi) arrow.r U(psi, chi))$],
    [BX3$'$], [`Axiom.right_mono_since`], [$H(phi.alt arrow.r psi) arrow.r (S(phi.alt, chi) arrow.r S(psi, chi))$],
    [BX4], [`Axiom.connect_future`], [$phi.alt arrow.r G P phi.alt$],
    [BX4$'$], [`Axiom.connect_past`], [$phi.alt arrow.r H F phi.alt$],
    [BX5], [`Axiom.self_accum_until`], [$U(psi, phi.alt) arrow.r U(psi, phi.alt and U(psi, phi.alt))$],
    [BX5$'$], [`Axiom.self_accum_since`], [$S(psi, phi.alt) arrow.r S(psi, phi.alt and S(psi, phi.alt))$],
    [BX6], [`Axiom.absorb_until`], [$U(phi.alt and U(psi, phi.alt), phi.alt) arrow.r U(psi, phi.alt)$],
    [BX6$'$], [`Axiom.absorb_since`], [$S(phi.alt and S(psi, phi.alt), phi.alt) arrow.r S(psi, phi.alt)$],
    [BX7], [`Axiom.linear_until`], [$U(psi, phi.alt) and U(theta, chi) arrow.r U(psi and theta, phi.alt and chi) or U(psi and chi, phi.alt and chi) or U(phi.alt and theta, phi.alt and chi)$],
    [BX7$'$], [`Axiom.linear_since`], [$S(psi, phi.alt) and S(theta, chi) arrow.r S(psi and theta, phi.alt and chi) or S(psi and chi, phi.alt and chi) or S(phi.alt and theta, phi.alt and chi)$],
    [BX10], [`Axiom.until_F`], [$U(psi, phi.alt) arrow.r F psi$],
    [BX10$'$], [`Axiom.since_P`], [$S(psi, phi.alt) arrow.r P psi$],
    [BX11], [`Axiom.temp_linearity`], [$F phi.alt and F psi arrow.r F(phi.alt and psi) or F(phi.alt and F psi) or F(F phi.alt and psi)$],
    [BX11$'$], [`Axiom.temp_linearity_past`], [$P phi.alt and P psi arrow.r P(phi.alt and psi) or P(phi.alt and P psi) or P(P phi.alt and psi)$],
    [BX12], [`Axiom.F_until_equiv`], [$F phi.alt arrow.r U(phi.alt, top)$],
    [BX12$'$], [`Axiom.P_since_equiv`], [$P phi.alt arrow.r S(phi.alt, top)$],
    [BX13], [`Axiom.enrichment_until`], [$p and U(psi, phi.alt) arrow.r U(psi and S(p, phi.alt), phi.alt)$],
    [BX13$'$], [`Axiom.enrichment_since`], [$p and S(psi, phi.alt) arrow.r S(psi and U(p, phi.alt), phi.alt)$],
    table.hline(),
  ),
  caption: [BX temporal layer. Gaps in the numbering (BX2, BX8, BX9, BX14) mark schemata of Burgess @burgess1982axioms that were removed as unsound or unnecessary under the strict-witness/open-guard semantics; see the source comments in `ProofSystem/Axioms.lean`.],
)

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

=== Layer 5: Uniformity (5)

The uniformity axioms concern the discreteness witness $U(top, bot)$ ("there is an immediate successor": the guard interval to the witness is empty).
They encode the *uniformity of discreteness* in ordered abelian groups --- by translation invariance, a gap at one point exists at every point and in every accessible world --- and are therefore valid on *all* frames (frame class `Base`).

#figure(
  table(
    columns: 2,
    stroke: none,
    align: (left, left),
    table.hline(),
    table.header([*Lean Constructor*], [*Schema*]),
    table.hline(),
    [`Axiom.discrete_symm_fwd`], [$U(top, bot) arrow.r S(top, bot)$],
    [`Axiom.discrete_symm_bwd`], [$S(top, bot) arrow.r U(top, bot)$],
    [`Axiom.discrete_propagate_fwd`], [$U(top, bot) arrow.r G(U(top, bot))$],
    [`Axiom.discrete_propagate_bwd`], [$U(top, bot) arrow.r H(U(top, bot))$],
    [`Axiom.discrete_box_necessity`], [$U(top, bot) arrow.r square.stroked (U(top, bot))$],
    table.hline(),
  ),
  caption: none,
)

=== Layers 6--7: Prior and Z1 (3, discrete-only)

Valid on discrete linear orders (frame class `Discrete`), these axioms encode well-ordering for definable sets.

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [Prior-UZ], [`Axiom.prior_UZ`], [$F phi.alt arrow.r U(phi.alt, not phi.alt)$],
    [Prior-SZ], [`Axiom.prior_SZ`], [$P phi.alt arrow.r S(phi.alt, not phi.alt)$],
    [Z1], [`Axiom.z1`], [$G(G phi.alt arrow.r phi.alt) arrow.r (F G phi.alt arrow.r G phi.alt)$],
    table.hline(),
  ),
  caption: none,
)

Prior-UZ says that if $phi.alt$ holds somewhere in the future, there is a *nearest* future $phi.alt$-point @reynolds1992 (Venema's axiom (W)); Z1 is the characteristic backward-induction axiom of successor-Archimedean orders such as $ZZ$ @doets1987.

=== Layer 8: Density (2, dense-only)

Valid on densely ordered frames (frame class `Dense`).

#figure(
  table(
    columns: 3,
    stroke: none,
    align: (left, left, left),
    table.hline(),
    table.header([*Name*], [*Lean Constructor*], [*Schema*]),
    table.hline(),
    [DN], [`Axiom.density`], [$G G phi.alt arrow.r G phi.alt$],
    [DI], [`Axiom.dense_indicator`], [$not U(top, bot)$],
    table.hline(),
  ),
  caption: none,
)

On a dense order no point has an immediate successor, so the discreteness witness $U(top, bot)$ is false everywhere (DI, the Burgess density axiom for Until/Since @burgess1982axioms).
DI is included alongside DN because the density schema alone provably fails to derive it.

== Frame Classes <sec:frame-classes>

Derivations are parameterized by a frame class, making frame-dependent reasoning a structural invariant rather than a side condition.

#definition("Frame Class")[
  The type `FrameClass` has three values: `Base`, `Dense`, and `Discrete`, partially ordered with `Base` below both `Dense` and `Discrete`, which are incomparable.
  Each axiom constructor is assigned a minimum frame class by `Axiom.minFrameClass`: the #base-count axioms of layers 1--5 are `Base`; Prior-UZ, Prior-SZ, and Z1 (#discrete-only-count axioms) are `Discrete`; DN and DI (#dense-only-count axioms) are `Dense`.
]

The axiom rule of the proof system admits an axiom into a derivation at frame class `fc` only when its minimum frame class is at most `fc`.
Derivations are monotone along the order: `DerivationTree.lift` coerces a derivation at `Base` into one at `Dense` or `Discrete`.

This mirrors the paper's hierarchy of *TM* extensions (@brastmckie2026possibleworlds §3.3): frame class `Base` corresponds to the base system (*TM*#super[+], the paper's Until/Since extension of *TM*, of which *TM* is a conservative reduct --- see `Metalogic/ConservativeExtension/`), `Dense` to the dense extension *TM*#sub[d], and `Discrete` to the discrete extension *TM*#sub[f].
The paper's complete extension *TM*#sub[c] (order-completeness) and combined *TM*#sub[dc] are paper-side extensions and do not correspond to frame classes in the Lean formalization.

== Derived Axioms <sec:derived-axioms>

Several schemata that are primitive axioms of the paper's *TM* presentation are *derived theorems* of BX:

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
Two further schemata of the paper's presentation are BX axioms under different names: the paper's TB ($F top$, seriality) is BX1 `serial_future`, and the paper's TA ($phi.alt arrow.r G P phi.alt$) is BX4 `connect_future`.
The paper's TL (future linearity) is BX11 `temp_linearity`.

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

#definition("Temporal Duality")[
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

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    table.header(
      [*Rule*], [*Lean Constructor*], [*Context Requirement*],
    ),
    table.hline(),
    [Axiom], [`DerivationTree.axiom`], [Any (gated by `minFrameClass`)],
    [Assumption], [`DerivationTree.assumption`], [Any],
    [Modus Ponens], [`DerivationTree.modus_ponens`], [Any],
    [Necessitation], [`DerivationTree.necessitation`], [Empty only],
    [Temp. Necessitation], [`DerivationTree.temporal_necessitation`], [Empty only],
    [Temporal Duality], [`DerivationTree.temporal_duality`], [Empty only],
    [Weakening], [`DerivationTree.weakening`], [Any],
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

== Relation to the Paper's Presentation <sec:paper-contrast>

The paper presents *TM* economically, as the smallest extension of classical propositional logic closed under twelve schemata: the rules MP, MN, and TD, and the axioms MK, MT, M5, MF, TK, T4, TB, TA, and TL (with H/G primitive in the base language $cal(L)$).
The Lean system is the constructor-level *BX* axiomatization of the paper's *TM*#super[+] (the Until/Since system of the paper's §3.3, proven there to extend *TM* conservatively).
The differences are presentational granularity, not logical strength:

- *CPL is spelled out*: the paper subsumes classical propositional logic in a single phrase; Lean lists its four Hilbert schemata (Layer 1) explicitly.
- *S5 is closed under theorems*: Lean includes M4 and MB alongside the paper's MT, M5, MK --- derivable in S5 but convenient as primitives.
- *Until/Since replaces H/G as the temporal engine*: with $U$/$S$ primitive, the paper's TK and T4 become derived theorems, TB and TA reappear as BX1 and BX4, and TL is BX11 (@sec:derived-axioms).
- *Past mirrors are primed constructors*: the paper generates past duals by the TD rule; Lean additionally includes primed mirror constructors (BX1$'$--BX13$'$), which makes derivations at non-empty contexts more direct.
- *Frame-class axioms are gated structurally*: the paper's extensions *TM*#sub[f] and *TM*#sub[d] become the `Discrete` and `Dense` frame classes of @sec:frame-classes rather than separate systems.

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
