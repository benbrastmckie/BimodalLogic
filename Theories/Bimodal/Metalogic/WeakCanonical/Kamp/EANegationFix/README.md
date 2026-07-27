# EANegationFix — De Morgan Negation Fixpoints for the EA Encoding

7 live `.lean` files / 3,227 lines. Implements the negation-normalization fixpoints
that the existential/universal (EA) vector encoding needs in order to push negation
inward without leaving the fragment.

## Modules

| File | Lines | Role |
|------|------:|------|
| `BoundedFix.lean` | 864 | The bounded negation fixpoint construction |
| `NegFix.lean` | 706 | Core negation-fixpoint definitions and their correctness |
| `NegFixOne.lean` | 563 | The single-step case, from which the general fold is built |
| `BoundedFixAnchored.lean` | 490 | Bounded fixpoint at an anchored position |
| `OnBuilder.lean` | 285 | Builder combinators used to assemble the fixpoints |
| `VecEANegFix.lean` | 192 | `VecEA2.negFix` / `VVecEA2.negFix` — the De Morgan fold at vector level |
| `ConcatPin.lean` | 127 | Concatenation pinning lemma used by the fold |

## Why It Is a Separate Directory

Negation is where the EA encoding is most likely to leave its fragment, so the fixpoint
argument that keeps it inside is substantial enough to be its own development rather
than a section of a larger file. `VecEANegFix.lean` is the interface the rest of
`Kamp/` consumes; the other six are its construction.

## Position in the Layering

Inside `Kamp/`, which is inside `WeakCanonical/` — the Kamp/Reynolds completeness
route. Consumed by the Prop 4.2 / 4.3 transcriptions (`Prop42Contentful.lean`,
`Prop43Translate.lean`) and by `Kamp/EANegationFix.lean`, the loose module beside this
directory that re-exports it.

## Related Documentation

- [Kamp README](../README.md)
- [WeakCanonical README](../../README.md)
- [Metalogic architecture map](../../../README.md)

## References

- Rabinovich 2014, Propositions 4.2 and 4.3 — the source these modules transcribe
