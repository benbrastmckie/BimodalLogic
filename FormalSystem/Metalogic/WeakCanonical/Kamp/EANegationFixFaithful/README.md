# EANegationFixFaithful — Rabinovich's Lemma 5.1 and Corollary 5.4 over the faithful carrier

Rabinovich's negation-fix recursion, landed over the *faithful* Dedekind carrier
(`HasFaithfulDedekindINF`) rather than over the general one.

The chain runs bottom-up: Lemma 5.1 is settled first at a single witness
(`NegFixOneFaithful.lean`), then by induction over a witness list
(`NegFixListFaithful.lean`); Corollary 5.4 is landed at the innermost fold goal
(`BoundedFixFaithful.lean`) and then at an arbitrary anchor
(`BoundedFixAnchoredFaithful.lean`); and `VecEANegFixFaithful.lean` lifts the recursion up to
the disjunction level via Propositions 4.2 and 4.3.

Page references are to the PDF pagination of Rabinovich's paper, matching the citations in the
module docstrings.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `BoundedFixAnchoredFaithful.lean` | 376 | The anchored mirrors of the above: Corollary 5.4(1)/(2) at an arbitrary anchor `α`, the point type sitting at the moving endpoint after the outermost peel (PDF pp.9-10). |
| `BoundedFixFaithful.lean` | 394 | Corollary 5.4(1)/(2) at `VVecEA2`, at the `α := ⊤` innermost fold goal (PDF p.9). |
| `NegFixListFaithful.lean` | 670 | The inductive step of the same argument, over a witness list (PDF pp.10-11). |
| `NegFixOneFaithful.lean` | 885 | Lemma 5.1 at one witness (PDF pp.9-10). Rabinovich's explicit three-case split, with output shape `∨ᵢ (Condᵢ ∧ Formᵢ)`. |
| `VecEANegFixFaithful.lean` | 336 | The Proposition 4.2 / 4.3 lift chain, carrying Lemma 5.1's recursion up to the disjunction level over `HasFaithfulDedekindINF` alone (PDF p.6 and pp.10-11). |

## Key Results

- Lemma 5.1 over the faithful carrier, at one witness and over a list.
- Corollary 5.4(1)/(2), plain and anchored.
- The Proposition 4.2 / 4.3 lift, which is what downstream Kamp modules consume.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.WeakCanonical.Kamp` (the `VVecEA2` vocabulary and
  `HasFaithfulDedekindINF`)
- **Imported by**: `FormalSystem.Metalogic.WeakCanonical.Kamp` aggregators

## Related Documentation

- [Kamp README](../README.md)
- [WeakCanonical README](../../README.md)

---

**Last verified**: 2026-08-25
