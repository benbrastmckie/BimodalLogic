# Task 956: Archived Int/Rat-Dependent Approaches

**Archived**: 2026-03-09
**Reason**: Importing Int or Rat as the duration domain D is STRICTLY FORBIDDEN

## What's Here

These files used Int or Rat as the duration domain D, or were part of dependency
chains that required Int/Rat imports. They have been archived because the project
requires D to emerge from pure syntax via the K-Relational strategy.

## Archived Files

| File | Original Location | Why Archived |
|------|------------------|--------------|
| `TemporalDomain.lean` | `Bundle/TemporalDomain.lean` | Imports `Mathlib.Algebra.Order.Ring.Rat` |
| `TranslationGroup.lean` | `Bundle/TranslationGroup.lean` | D via Holder's theorem chain |
| `FragmentCompleteness.lean` | `Bundle/FragmentCompleteness.lean` | Uses FMCS Int, Int-indexed chains |
| `DenseQuotient.lean` | `Bundle/DenseQuotient.lean` | Part of Int-indexed construction |
| `RestrictedFragment.lean` | `Bundle/RestrictedFragment.lean` | Dependency of TemporalDomain |
| `CanonicalCompleteness.lean` | `Bundle/CanonicalCompleteness.lean` | Uses BFMCS Int |
| `BidirectionalReachable.lean` | `Bundle/BidirectionalReachable.lean` | Part of Int-indexed construction |
| `CanonicalChain.lean` | `Bundle/CanonicalChain.lean` | Uses FMCS Int |

## Files NOT Yet Archived (Still Active)

The following files use Int but are still part of the active build chain
(imported by Representation.lean). They will be replaced by the K-Relational
strategy (Phases 2-7 of implementation-010.md):

- `TemporalCoherentConstruction.lean` - provides `construct_saturated_bfmcs_int`
- `DovetailingChain.lean` - provides dovetailing chain construction
- `CanonicalConstruction.lean` - provides canonical construction from BFMCS Int
- `Representation.lean` - standard completeness (uses all above)

## The Right Way

D must emerge from the temporal axioms via:
1. Relational completeness (no D)
2. Canonical timeline properties (countable, dense, no endpoints)
3. Cantor isomorphism: T ~ Q
4. D = (Q, +), discovered not imported

See: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-010.md`
