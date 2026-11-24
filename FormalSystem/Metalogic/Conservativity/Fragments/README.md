# Metalogic/Conservativity/Fragments

Conservativity of TM over the fragments of its own language `L`.

A fragment has no proof system of its own. Its logic is the part of TM whose derivations stay
inside it: the axiom instances and rule applications all of whose formulas lie in the fragment.
`Calculus.lean` states that as a `Prop`-valued calculus over an abstract sublanguage.

`PropComplete.lean` proves that the calculus of any sublanguage is propositionally complete: a
tautology whose variables are the atoms and the formulas with a non-Boolean main operator is
derivable inside the sublanguage it lies in. The proof is Kalmár's, on the deduction theorem of
the calculus.

`Translation.lean` states the argument for a conservativity edge once. A map on formulas that
commutes with implication, sends each admissible axiom instance to a formula derivable inside
the sublanguage, preserves that derivability under necessitation, temporal necessitation and time
reflection, and is the identity on the sublanguage, gives the edge by one induction on the
derivation.

`Collapse.lean` defines the translation used for the Boolean and modal edges. It reads a formula
in a model with a single moment: Until and Since become `g ∧ e` under the dense reading and `e`
under the discrete reading, and `□` is kept or read as the identity. Two readings are needed
because the density axiom requires "next" to be false and the prior axiom for the integers
requires it to be true.

`Edges.lean` proves the two edges, each at every frame class: a formula with no operator that TM
derives is derivable inside the Boolean sublanguage, and a formula whose only operator is `□`
that TM derives is derivable inside the sublanguage with `□`. Neither needs a completeness
theorem for the smaller logic.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Conservativity/Fragments -->
| File | Lines | Description |
|------|------:|-------------|
| `Calculus.lean` | 204 | The closure conditions `Sublanguage` on a set of formulas, the `Prop`-valued calculus `CellDerivable` of derivations that stay inside one, and its deduction theorem by induction on the derivation. |
| `Collapse.lean` | 163 | The sublanguages `BooleanFormula` and `ModalFormula`, the collapse translation `collapse` with its dense and discrete readings, and the lemmas the parametric theorem asks of it: identity on the target, range in the target, and preservation of derivability under the three rules for theorems. |
| `Edges.lean` | 129 | The two edges at every frame class, `boolean_conservative` and `modal_conservative`, with the derivability of each translated axiom: a tautology when `□` is erased, and T, 5, K, necessitation and tautologies when it is kept. |
| `PropComplete.lean` | 236 | Propositional completeness inside a sublanguage, by Kalmár: `evalProp`, `Tautology`, the lemma `kalmar`, the elimination of variables `eliminate`, and `tautology_derivable`. |
| `Translation.lean` | 85 | The parametric theorem `conservative_of_translation`: a translation satisfying three hypotheses gives conservativity of a sublanguage, by induction on the derivation. |
<!-- END GENERATED -->

## Key Results

- `CellDerivable.deduction` — the deduction theorem inside a sublanguage, by induction on the
  derivation
- `CellDerivable.toDerivationTree` — a derivation inside a sublanguage is a derivation of TM
- `tautology_derivable` — a propositional tautology of a sublanguage is derivable inside it, at
  every frame class
- `conservative_of_translation` — conservativity of a sublanguage from a translation satisfying
  three hypotheses
- `boolean_conservative` — the Boolean sublanguage is conserved by TM at every frame class
- `modal_conservative` — the sublanguage with `□` is conserved by TM at every frame class

*Last verified: 2026-11-23*
