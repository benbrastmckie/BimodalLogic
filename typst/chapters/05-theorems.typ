// ============================================================================
// 05-theorems.typ
// Theorems chapter for Bimodal TM Logic Reference Manual
// ============================================================================

#import "../template.typ": *

= Theorems


== Perpetuity Principles <sec:perpetuity>

The perpetuity principles establish deep connections between modal necessity ($square.stroked$) and temporal operators ($triangle.stroked.t$, $triangle.stroked.b$); they are the touchstone principles P1--P6 of @brastmckie2026possibleworlds, proven here in Lean (`Theorems/Perpetuity/`).

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

All six perpetuity principles are fully proven (sorry-free) in the Lean implementation, in `Theorems/Perpetuity/` (`Principles.lean`, with P6 infrastructure in `Bridge.lean`).

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
    [P3], [`perpetuity_3`], [P1, box_mono],
    [P4], [`perpetuity_4`], [Contraposition],
    [P5], [`perpetuity_5`], [modal_5, temporal K],
    [P6], [`perpetuity_6`], [P5, bridge lemmas],
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
    [`Perpetuity/`], [P1--P6 principles (`Principles.lean`, `Bridge.lean`, `Helpers.lean`); re-exported by `Perpetuity.lean`],
    [`Propositional/`], [Classical propositional theorems (`Core.lean`, `Connectives.lean`, `Reasoning.lean`)],
    [`ModalS5.lean`], [S5 characteristic theorems],
    [`ModalS4.lean`], [S4 properties (modal_5, diamond_4)],
    [`Combinators.lean`], [B, I, S combinators, imp_trans, `temp_future_derived` (TF)],
    [`TemporalDerived.lean`], [Derived temporal axioms: `temp_k_dist_derived` (TK), `temp_4_derived` (T4)],
    [`ContextualProofs.lean`], [Derivations at non-empty contexts],
    [`GeneralizedNecessitation.lean`], [Context-level necessitation],
    table.hline(),
  ),
  caption: none,
)

The entire `Theorems/` tree is sorry-free.
