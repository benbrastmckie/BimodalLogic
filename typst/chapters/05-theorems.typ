// ============================================================================
// 05-theorems.typ
// Theorems chapter for Bimodal TM Logic Reference Manual
// ============================================================================

#import "../template.typ": *

= Theorems


== Perpetuity Principles <sec:perpetuity>

The perpetuity principles establish deep connections between modal necessity ($square.stroked$) and temporal operators ($triangle.stroked.t$, $triangle.stroked.b$); they are the touchstone principles P1--P6 of @brastmckie2026possibleworlds, proven here in Lean (`Theorems/Perpetuity/`).
P1 in particular is the formal counterpart of a thesis defended independently in the philosophical literature: every necessarily true proposition is always true @dorr2020diamonds.

#theorem("P1: Necessity Implies Always")[
  $tack.r square.stroked phi.alt arrow.r triangle.stroked.t phi.alt$
]

#theorem("P2: Sometimes Implies Possible")[
  $tack.r triangle.stroked.b phi.alt arrow.r diamond.stroked phi.alt$
]

#theorem("P3: Necessity of Perpetuity")[
  $tack.r square.stroked phi.alt arrow.r square.stroked triangle.stroked.t phi.alt$
]

#theorem("P4: Possibility of Occurrence")[
  $tack.r diamond.stroked triangle.stroked.b phi.alt arrow.r diamond.stroked phi.alt$
]

#theorem("P5: Persistent Possibility")[
  $tack.r diamond.stroked triangle.stroked.b phi.alt arrow.r triangle.stroked.t diamond.stroked phi.alt$
]

#theorem("P6: Occurrent Necessity is Perpetual")[
  $tack.r triangle.stroked.b square.stroked phi.alt arrow.r square.stroked triangle.stroked.t phi.alt$
]

#remark("Why the Perpetuity Principles Follow from MF and MT Alone")[
  None of P1--P6 needs a bespoke semantic argument: every one is a theorem of classical propositional and modal reasoning once two ingredients are in hand.
  MT ($square.stroked phi.alt arrow.r phi.alt$, the S5 reflexivity axiom) supplies "necessary implies actual"; MF ($square.stroked phi.alt arrow.r square.stroked G phi.alt$, the bimodal interaction axiom) supplies "necessary implies necessarily always future".
  Composing MF with MT (instantiating MT at $G phi.alt$) already derives TF ($square.stroked phi.alt arrow.r G square.stroked phi.alt$: necessity is preserved into the future's necessity) by nothing more than propositional substitution and modus ponens --- no fresh semantic insight, just classical bookkeeping on axioms already in hand.
  P1--P6 then follow from TF (and its past mirror, via temporal duality) together with classical propositional reasoning and the standard modal/tense duals ($diamond.stroked := not square.stroked not$, $triangle.stroked.b := not triangle.stroked.t not$): the *substance* of the perpetuity principles lives entirely in MF, and everything past that point is bookkeeping the Lean kernel checks mechanically rather than a further creative step.
]

All six perpetuity principles are fully proven (sorry-free) in the Lean implementation, in `Theorems/Perpetuity/` (`Principles.lean`, with P6 infrastructure in `MonotonicityDuality.lean`'s "Bridge Lemmas for P6 Derivation" section).

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(),
    table.header(
      [*Principle*], [*Lean Theorem*], [*Key Lemmas*],
    ),
    table.hline(),
    [P1], [`perpetuity_1`], [MF, TF, MT],
    [P2], [`perpetuity_2`], [Contraposition of P1],
    [P3], [`perpetuity3`], [P1, boxMono],
    [P4], [`perpetuity4`], [Contraposition],
    [P5], [`perpetuity5`], [modal5, temporal K],
    [P6], [`perpetuity6`], [P5, bridge lemmas],
    table.hline(),
  ),
  caption: none,
)

== Modal S5 Theorems

#theorem("T-Box-to-Diamond")[
  $tack.r square.stroked phi.alt arrow.r diamond.stroked phi.alt$
]

#theorem("Box Distributes Over Disjunction")[
  $tack.r (square.stroked phi.alt or square.stroked psi) arrow.r square.stroked (phi.alt or psi)$
]

#theorem("Box Preserves Contraposition")[
  $tack.r square.stroked (phi.alt arrow.r psi) arrow.r square.stroked (not psi arrow.r not phi.alt)$
]

#theorem("K Distribution for Diamond")[
  $tack.r square.stroked (phi.alt arrow.r psi) arrow.r (diamond.stroked phi.alt arrow.r diamond.stroked psi)$
]

#theorem("S5 Collapse")[
  $tack.r diamond.stroked square.stroked phi.alt arrow.l.r square.stroked phi.alt$
]

#theorem("Box-Conjunction")[
  $tack.r square.stroked (phi.alt and psi) arrow.l.r (square.stroked phi.alt and square.stroked psi)$
]

#theorem("Diamond-Disjunction")[
  $tack.r diamond.stroked (phi.alt or psi) arrow.l.r (diamond.stroked phi.alt or diamond.stroked psi)$
]

#theorem("S5 Diamond-Box to Truth")[
  $tack.r diamond.stroked square.stroked phi.alt arrow.r phi.alt$
]

#theorem("T-Box Consistency")[
  $tack.r square.stroked (phi.alt and not phi.alt) arrow.r bot$
]

== Modal S4 Properties

The following S4 properties are derived from the TM axiom system.

#theorem("Modal 5")[
  $tack.r diamond.stroked phi.alt arrow.r square.stroked diamond.stroked phi.alt$
]

#theorem("Diamond 4")[
  $tack.r diamond.stroked diamond.stroked phi.alt arrow.r diamond.stroked phi.alt$
]

#theorem("Box Monotonicity")[
  If $tack.r phi.alt arrow.r psi$ then $tack.r square.stroked phi.alt arrow.r square.stroked psi$.
]

#theorem("Diamond Monotonicity")[
  If $tack.r phi.alt arrow.r psi$ then $tack.r diamond.stroked phi.alt arrow.r diamond.stroked psi$.
]

== Propositional Theorems

#theorem("Identity")[
  $tack.r phi.alt arrow.r phi.alt$
]

#theorem("Double Negation Introduction")[
  $tack.r phi.alt arrow.r not not phi.alt$
]

#theorem("Double Negation Elimination")[
  $tack.r not not phi.alt arrow.r phi.alt$
]

#theorem("Contraposition")[
  If $tack.r phi.alt arrow.r psi$ then $tack.r not psi arrow.r not phi.alt$.
]

#theorem("De Morgan Disjunction")[
  $tack.r not (phi.alt or psi) arrow.l.r (not phi.alt and not psi)$
]

#theorem("De Morgan Conjunction")[
  $tack.r not (phi.alt and psi) arrow.l.r (not phi.alt or not psi)$
]

== Combinator Infrastructure

The combinator infrastructure provides Hilbert-style proof tools.

#theorem("B Combinator")[
  $tack.r (B arrow.r C) arrow.r ((A arrow.r B) arrow.r (A arrow.r C))$
]

#theorem("Implication Transitivity")[
  If $tack.r A arrow.r B$ and $tack.r B arrow.r C$ then $tack.r A arrow.r C$.
]

#theorem("Pairing")[
  $tack.r A arrow.r (B arrow.r (A and B))$
]

#theorem("Classical Merge")[
  $tack.r (P arrow.r Q) arrow.r ((not P arrow.r Q) arrow.r Q)$
]

== Generalized Necessitation

#theorem("Generalized Modal Necessitation")[
  If $Gamma tack.r phi.alt$ then $square.stroked Gamma tack.r square.stroked phi.alt$
  where $square.stroked Gamma = [square.stroked psi | psi in Gamma]$.
]

#theorem("Generalized Temporal Necessitation")[
  If $Gamma tack.r phi.alt$ then $G Gamma tack.r G phi.alt$
  where $G Gamma = [G psi | psi in Gamma]$.
]

== Module Organization

The `Theorems/` directory is organized as follows:

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
    [`Perpetuity/`], [P1--P6 principles (`Principles.lean`, `MonotonicityDuality.lean`, `Helpers.lean`); re-exported by `Perpetuity.lean`],
    [`Propositional/`], [Classical propositional theorems (`Core.lean`, `Connectives.lean`, `Reasoning.lean`)],
    [`ModalS5.lean`], [S5 characteristic theorems],
    [`ModalS4.lean`], [S4 properties (modal5, diamond4)],
    [`Combinators.lean`], [B, I, S combinators, impTrans, `temporalFutureDerived` (TF)],
    [`TemporalDerived.lean`], [Derived temporal axioms: `temporalKDistDerived` (TK), `temporal4Derived` (T4)],
    [`ContextualProofs.lean`], [Derivations at non-empty contexts],
    [`GeneralizedNecessitation.lean`], [Context-level necessitation],
    table.hline(),
  ),
  caption: none,
)

The entire `Theorems/` tree is sorry-free.
