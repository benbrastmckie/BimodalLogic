// ============================================================================
// 01-syntax.typ
// Syntax chapter for Bimodal TM Logic Reference Manual
// Lean name ground truth: Syntax/Formula.lean (see ../SYNC-MAP.md).
// ============================================================================

#import "../template.typ": *

= Syntax


== Formulas <sec:formulas>

Formulas are defined inductively with six primitive constructors, with *Since* and *Until* as the primitive temporal operators.

#definition("Formula")[
  The type `Formula` is defined by:
  $ phi.alt, psi ::= p | bot | phi.alt arrow.r psi | square.stroked phi.alt | phi.alt #snce psi | phi.alt #untl psi $
  where $p$ ranges over sentence letters (type `Atom`).#footnote[`Atom` (`Syntax/Atom.lean`) pairs a base string with an optional freshness index, so that a fresh atom exists outside any finite set of atoms; `Formula.atomS` builds an atom formula directly from a string.]
]

The two temporal primitives are written infix and are *guard-first*: in $#snceOp($phi.alt$, $psi$)$ the *guard* is $phi.alt$, holding at all times strictly between a past witness and now, and the *event* is $psi$, witnessed at that strictly past time.
$#untlOp($phi.alt$, $psi$)$ is the future mirror: the guard $phi.alt$ holds at all times strictly between now and a future witness, at which the event $psi$ is true.#footnote[Part of the literature, following Burgess's axiomatization of Until and Since @burgess1982axioms, instead writes the two operators prefix and event-first: there $U(psi, phi.alt)$ has the event $psi$ first and the guard $phi.alt$ second. The infix guard-first form used here reads aloud directly --- "$phi.alt$ since $psi$", "$phi.alt$ until $psi$" --- with the guard in subject position.]

// CONFIRM(lean): Formula.snce and Formula.untl (Syntax/Formula.lean) take arguments guard-first, matching def:BLplus-semantics
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
    [$phi.alt #snce psi$], [Since], [`snce`], ["$phi.alt$ since $psi$"],
    [$phi.alt #untl psi$], [Until], [`untl`], ["$phi.alt$ until $psi$"],
    table.hline(),
  ),
  caption: none,
)

This Since/Until basis is the book's language throughout: the one-place tense operators $P$, $F$, $H$, and $G$ arise as derived operators below.

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
  The one-place tense operators are defined from Since and Until with a vacuous guard:
  $
    P phi.alt &:= top #snce phi.alt \
    F phi.alt &:= top #untl phi.alt \
    H phi.alt &:= not P not phi.alt \
    G phi.alt &:= not F not phi.alt \
    triangle.stroked.t phi.alt &:= H phi.alt and phi.alt and G phi.alt \
    triangle.stroked.b phi.alt &:= P phi.alt or phi.alt or F phi.alt
  $
]#footnote[The tense-primitive sublanguage --- taking the one-place $H$ and $G$ as primitive and lacking Since and Until --- embeds into the full language under these definitions. That sublanguage, and the proof system axiomatized over it, is a deferred subsystem of this book: the Frame Classes chapter's conservativity note and the back matter's axiom map record its intended development.]

// CONFIRM(lean): Formula.prev (bot snce-guard-first) and Formula.next (bot untl-guard-first) exist as def abbreviations
//   in Syntax/Formula.lean with unfold lemmas matching the discrete-frame characterization stated below.
#definition("Next and Previous")[
  Over discrete temporal orders, the one-step operators are defined with an unsatisfiable guard:
  $
    "Prev" phi.alt &:= bot #snce phi.alt \
    "Next" phi.alt &:= bot #untl phi.alt
  $
  Since no time can lie strictly between the witness and now while $bot$ holds there, the witness must be an immediate neighbor: over discrete frames $"Next" phi.alt$ holds exactly when $phi.alt$ holds at the immediate successor, and $"Prev" phi.alt$ exactly when $phi.alt$ holds at the immediate predecessor. Over a dense order the guard is never dischargeable and both operators are unsatisfiable, so their intended reading is specific to the discrete frame classes.
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
    [$P phi.alt$], [Sometime past], [`somePast`], ["it has been $phi.alt$"],
    [$F phi.alt$], [Sometime future], [`someFuture`], ["it is going to be $phi.alt$"],
    [$H phi.alt$], [Always past], [`allPast`], ["it has always been $phi.alt$"],
    [$G phi.alt$], [Always future], [`allFuture`], ["it is always going to be $phi.alt$"],
    [$triangle.stroked.t phi.alt$], [Always], [`always`], ["always $phi.alt$"],
    [$triangle.stroked.b phi.alt$], [Sometimes], [`sometimes`], ["sometimes $phi.alt$"],
    table.hline(),
  ),
  caption: none,
)

Because $P$, $F$, $H$, and $G$ are `def` abbreviations rather than constructors, they unfold definitionally; the semantics chapter gives their truth conditions as derived characterizations.

== Temporal Duality

The `swapTemporal` function exchanges past and future operators.

#definition("Temporal Swap")[
  The function $chevron.l S chevron.r : "Formula" arrow.r "Formula"$ is defined by recursion on the primitive constructors (`Syntax/Formula.lean`):
  $
    chevron.l S chevron.r p &= p \
    chevron.l S chevron.r bot &= bot \
    chevron.l S chevron.r (phi.alt arrow.r psi) &= (chevron.l S chevron.r phi.alt arrow.r chevron.l S chevron.r psi) \
    chevron.l S chevron.r square.stroked phi.alt &= square.stroked chevron.l S chevron.r phi.alt \
    chevron.l S chevron.r (phi.alt #snce psi) &= chevron.l S chevron.r phi.alt #untl chevron.l S chevron.r psi \
    chevron.l S chevron.r (phi.alt #untl psi) &= chevron.l S chevron.r phi.alt #snce chevron.l S chevron.r psi
  $
  On the derived operators this exchanges $H$ with $G$ and $P$ with $F$.
]

#theorem("Involution")[
  $chevron.l S chevron.r chevron.l S chevron.r phi.alt = phi.alt$#footnote[Proven as `swap_temporal_involution` in `Syntax/Formula.lean`.]
]
