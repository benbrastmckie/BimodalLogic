# Metalogic/Conservativity/Fragments

Conservativity of TM over the fragments of its own language `L`.

A fragment has no proof system of its own. Its logic is the part of TM whose derivations stay
inside it: the axiom instances and rule applications all of whose formulas lie in the fragment.
`Calculus.lean` states that as a `Prop`-valued calculus over an abstract sublanguage.

`PropComplete.lean` proves that the calculus of any sublanguage is propositionally complete: a
tautology whose variables are the atoms and the formulas with a non-Boolean main operator is
derivable inside the sublanguage it lies in. The proof is Kalmár's, on the deduction theorem of
the calculus.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Conservativity/Fragments -->
| File | Lines | Description |
|------|------:|-------------|
| `Calculus.lean` | 204 | The closure conditions `Sublanguage` on a set of formulas, the `Prop`-valued calculus `CellDerivable` of derivations that stay inside one, and its deduction theorem by induction on the derivation. |
| `PropComplete.lean` | 236 | Propositional completeness inside a sublanguage, by Kalmár: `evalProp`, `Tautology`, the lemma `kalmar`, the elimination of variables `eliminate`, and `tautology_derivable`. |
<!-- END GENERATED -->

## Key Results

- `CellDerivable.deduction` — the deduction theorem inside a sublanguage, by induction on the
  derivation
- `CellDerivable.toDerivationTree` — a derivation inside a sublanguage is a derivation of TM
- `tautology_derivable` — a propositional tautology of a sublanguage is derivable inside it, at
  every frame class
