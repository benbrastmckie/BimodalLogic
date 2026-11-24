# Metalogic/Conservativity/Fragments

Conservativity of TM over the fragments of its own language `L`.

A fragment has no proof system of its own. Its logic is the part of TM whose derivations stay
inside it: the axiom instances and rule applications all of whose formulas lie in the fragment.
`Calculus.lean` states that as a `Prop`-valued calculus over an abstract sublanguage.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Conservativity/Fragments -->
| File | Lines | Description |
|------|------:|-------------|
| `Calculus.lean` | 204 | The closure conditions `Sublanguage` on a set of formulas, the `Prop`-valued calculus `CellDerivable` of derivations that stay inside one, and its deduction theorem by induction on the derivation. |
<!-- END GENERATED -->

## Key Results

- `CellDerivable.deduction` — the deduction theorem inside a sublanguage, by induction on the
  derivation
- `CellDerivable.toDerivationTree` — a derivation inside a sublanguage is a derivation of TM
