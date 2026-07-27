// ============================================================================
// 01-syntax.typ
// Syntax chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: Syntax/Formula.lean (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *

= Syntax


== Formulas <sec:formulas>

Formulas are defined inductively with six primitive constructors, with *Until* and *Since* as the primitive temporal operators.

#definition("Formula")[
  The type `Formula` is defined by:
  $ phi.alt, psi ::= p | bot | phi.alt arrow.r psi | square.stroked phi.alt | U(phi.alt, psi) | S(phi.alt, psi) $
  where $p$ ranges over sentence letters (type `Atom`).#footnote[`Atom` (`Syntax/Atom.lean`) pairs a base string with an optional freshness index, so that a fresh atom exists outside any finite set of atoms; `Formula.atomS` builds an atom formula directly from a string.]
]

The binary temporal operators follow the *Burgess convention* @burgess1982axioms (`Syntax/Formula.lean`): in $U(phi.alt, psi)$ the first argument $phi.alt$ is the *event*, true at some strictly future witness time, and the second argument $psi$ is the *guard*, true at all times strictly between now and the witness.
$S(phi.alt, psi)$ is the past mirror: the event held at some strictly past time, with the guard holding strictly in between.

#figure(
  table(
    columns: 4,
    stroke: none,
    table.hline(),
    table.header(
      [*Symbol*], [*Name*], [*Lean*], [*Reading*],
    ),
    table.hline(),
    [$p, q, r$], [Atom], [`atom a`], [sentence letter],
    [$bot$], [Bottom], [`bot`], [falsity],
    [$phi.alt arrow.r psi$], [Implication], [`imp`], ["if $phi.alt$, then $psi$"],
    [$square.stroked phi.alt$], [Necessity], [`box`], ["necessarily $phi.alt$"],
    [$U(phi.alt, psi)$], [Until], [`untl`], ["$psi$ until $phi.alt$"],
    [$S(phi.alt, psi)$], [Since], [`snce`], ["$psi$ since $phi.alt$"],
    table.hline(),
  ),
  caption: none,
)

The paper's base language $cal(L)$ for *TM* instead takes the one-place tense operators $H$ and $G$ as primitive, introducing Until and Since only in its extended language $cal(L)^+$.
The Lean formalization works with the Until/Since basis throughout --- a conservative change of presentation (the paper's *TM*#super[+] extends *TM* conservatively), under which $H$, $G$, $F$, and $P$ become derived operators.

== Derived Operators

The following operators are defined in terms of the primitives; each equation is the Lean `def` from `Syntax/Formula.lean`.

#definition("Propositional")[
  $
    top &:= bot arrow.r bot \
    not phi.alt &:= phi.alt arrow.r bot \
    phi.alt and psi &:= not (phi.alt arrow.r not psi) \
    phi.alt or psi &:= not phi.alt arrow.r psi
  $
]

#figure(
  table(
    columns: 4,
    stroke: none,
    table.hline(),
    table.header(
      [*Symbol*], [*Name*], [*Lean*], [*Reading*],
    ),
    table.hline(),
    [$top$], [Top], [`top`], [truth],
    [$not phi.alt$], [Negation], [`neg`], ["it is not the case that $phi.alt$"],
    [$phi.alt and psi$], [Conjunction], [`and`], ["$phi.alt$ and $psi$"],
    [$phi.alt or psi$], [Disjunction], [`or`], ["$phi.alt$ or $psi$"],
    table.hline(),
  ),
  caption: none,
)

#definition("Modal")[
  $
    diamond.stroked phi.alt &:= not square.stroked not phi.alt
  $
]

#figure(
  table(
    columns: 4,
    stroke: none,
    table.hline(),
    table.header(
      [*Symbol*], [*Name*], [*Lean*], [*Reading*],
    ),
    table.hline(),
    [$diamond.stroked phi.alt$], [Possibility], [`diamond`], ["possibly $phi.alt$"],
    table.hline(),
  ),
  caption: none,
)

#definition("Temporal")[
  Following Burgess @burgess1982axioms, the one-place tense operators are defined from Until and Since with a vacuous guard:
  $
    F phi.alt &:= U(phi.alt, top) \
    P phi.alt &:= S(phi.alt, top) \
    G phi.alt &:= not F not phi.alt \
    H phi.alt &:= not P not phi.alt \
    triangle.stroked.t phi.alt &:= H phi.alt and phi.alt and G phi.alt \
    triangle.stroked.b phi.alt &:= P phi.alt or phi.alt or F phi.alt
  $
]

#figure(
  table(
    columns: 4,
    stroke: none,
    table.hline(),
    table.header(
      [*Symbol*], [*Name*], [*Lean*], [*Reading*],
    ),
    table.hline(),
    [$F phi.alt$], [Sometime future], [`someFuture`], ["it is going to be that $phi.alt$"],
    [$P phi.alt$], [Sometime past], [`somePast`], ["it has been that $phi.alt$"],
    [$G phi.alt$], [Always future], [`allFuture`], ["it is always going to be that $phi.alt$"],
    [$H phi.alt$], [Always past], [`allPast`], ["it has always been that $phi.alt$"],
    [$triangle.stroked.t phi.alt$], [Always], [`always`], ["always $phi.alt$"],
    [$triangle.stroked.b phi.alt$], [Sometimes], [`sometimes`], ["sometimes $phi.alt$"],
    table.hline(),
  ),
  caption: none,
)

Because $F$, $P$, $G$, and $H$ are `def` abbreviations rather than constructors, they unfold definitionally; the semantics chapter gives their truth conditions as derived characterizations.

== Temporal Duality

The `swapTemporal` function exchanges past and future operators.

#definition("Temporal Swap")[
  The function $chevron.l S chevron.r : "Formula" arrow.r "Formula"$ is defined by recursion on the primitive constructors (`Syntax/Formula.lean`):
  $
    chevron.l S chevron.r p &= p \
    chevron.l S chevron.r bot &= bot \
    chevron.l S chevron.r (phi.alt arrow.r psi) &= (chevron.l S chevron.r phi.alt arrow.r chevron.l S chevron.r psi) \
    chevron.l S chevron.r square.stroked phi.alt &= square.stroked chevron.l S chevron.r phi.alt \
    chevron.l S chevron.r U(phi.alt, psi) &= S(chevron.l S chevron.r phi.alt, chevron.l S chevron.r psi) \
    chevron.l S chevron.r S(phi.alt, psi) &= U(chevron.l S chevron.r phi.alt, chevron.l S chevron.r psi)
  $
  On the derived operators this exchanges $G$ with $H$ and $F$ with $P$.
]

#theorem("Involution")[
  $chevron.l S chevron.r chevron.l S chevron.r phi.alt = phi.alt$#footnote[Proven as `swap_temporal_involution` in `Syntax/Formula.lean`.]
]
