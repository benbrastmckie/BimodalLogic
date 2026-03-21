# Research 001: Atom Type Freshness Debt Analysis

## Date: 2026-03-14

## Problem Statement

The `canonicalR_irreflexive` axiom in `Canonical/CanonicalIrreflexivityAxiom.lean`
is a mathematically standard result (Goldblatt 1992, BdRV 2001) that cannot be
proved with the current `String` atom type because the proof requires a
**freshness property**: for any finite set of atoms, there exists an atom not
in the set.

With `String` atoms, for every string `s`, the tautology `G(s ∨ ¬s)` is in any
MCS M (by temporal necessitation), so `s ∨ ¬s ∈ GContent(M)` with
`s ∈ (s ∨ ¬s).atoms`. No string is fresh for `GContent(M)`.

## Current Status

The result is hypothesized as an `axiom` with high confidence:

```lean
axiom canonicalR_irreflexive :
  ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M
```

## Downstream Dependencies

From this axiom, the following are proved (not sorry'd):
- `NoMaxOrder` on dense timeline quotient (CantorApplication.lean)
- `NoMinOrder` on dense timeline quotient (CantorApplication.lean)
- `DenselyOrdered` on dense timeline quotient (CantorApplication.lean)
- `NoMaxOrder` on discrete timeline quotient (DiscreteTimeline.lean)
- `NoMinOrder` on discrete timeline quotient (DiscreteTimeline.lean)
- `canonicalR_strict`: `CanonicalR M N → ¬CanonicalR N M`
- `canonicalR_antisymmetric_strict`: mutual accessibility is impossible

## Resolution Path

### Option A: Structured Atom Type (Recommended)

Change the atom type from `String` to a type with an explicit freshness index:

```lean
structure Atom where
  base : String
  fresh_index : Option ℕ  -- None = base atom, Some n = fresh atom #n
```

This preserves backward compatibility (base atoms = existing formulas) while
providing infinitely many fresh atoms for any finite set.

**Effort estimate**: Medium (8-16 hours). Requires:
1. Define new `Atom` type with `DecidableEq`, `Countable`, `Encodable`
2. Refactor `Formula` to use `Atom` instead of `String`
3. Update all pattern matches on `Formula.atom`
4. Prove freshness: `∀ (S : Finset Atom), ∃ a, a ∉ S`
5. Complete the irreflexivity proof using Gabbay IRR rule
6. Remove the axiom, replacing it with the theorem

### Option B: ℕ × ℕ Atoms

Use `ℕ × ℕ` as the atom type with the second component for freshness:

```lean
def Atom := ℕ × ℕ
```

Simpler type but loses the human-readable `String` base. Freshness is trivial:
for any finite set of pairs, pick `(0, max_snd + 1)`.

### Option C: Typeclass-Based Freshness

Add a freshness typeclass:

```lean
class HasFreshness (α : Type) where
  fresh : Finset α → α
  fresh_not_mem : ∀ S, fresh S ∉ S
```

Most general but requires propagating the typeclass through all of `Formula`,
`ProofSystem`, `Metalogic`, etc.

## Recommendation

Option A is the best balance of correctness, backward compatibility, and
implementation effort. The `Option ℕ` fresh index means existing proofs about
`Formula.atom "p"` become `Formula.atom ⟨"p", none⟩` — a mechanical refactor.

## References

- `Canonical/CanonicalIrreflexivityAxiom.lean`: Axiom declaration and documentation
- `Bundle/CanonicalIrreflexivity.lean`: Failed proof attempt (2 sorries, blocked by String)
- Goldblatt (1992), *Logics of Time and Computation*, Ch. 6
- Blackburn, de Rijke, Venema (2001), *Modal Logic*, Ch. 4.8
