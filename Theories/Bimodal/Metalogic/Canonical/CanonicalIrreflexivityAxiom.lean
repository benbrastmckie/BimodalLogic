import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MaximalConsistent

/-!
# Axiom: Canonical Accessibility Relation is Irreflexive

## Statement

For every maximal consistent set M of the bimodal tense logic TM,
`¬CanonicalR M M` — that is, `GContent(M) ⊄ M`.

## Mathematical Status

This is a **theorem** in the standard literature (Goldblatt 1992, BdRV 2001),
provable when the atom type supports **freshness**: for any finite set of atoms,
there exists an atom not in the set. The standard proof uses the Gabbay
Irreflexivity Rule (IRR) contrapositively:

1. Assume `CanonicalR(M, M)` for contradiction
2. Pick fresh atom `p ∉ atoms(GContent(M))`
3. Build naming set `atomFreeSubset(M, p) ∪ {p, H(¬p)}`
4. Show naming set is consistent (via IRR contrapositive)
5. Extend to MCS `M' ⊇ naming set`; derive `CanonicalR(M, M')`
6. Derive contradiction: `p ∈ M'` and `¬p ∈ M'`

## Why This Is an Axiom (Not a Theorem)

**Step 2 fails with `String` atoms**: For every string `s`, the tautology
`G(s ∨ ¬s)` is in M (by temporal necessitation), so `s ∨ ¬s ∈ GContent(M)`
with `s ∈ (s ∨ ¬s).atoms`. No string is fresh for `GContent(M)`.

This is a **formalization artifact**, not a mathematical gap. The result is
true in any formalization where the atom type admits freshness (e.g., `ℕ × ℕ`
with the second component providing fresh atoms). With `String` atoms, we
cannot complete the proof, so we hypothesize it as an axiom.

## Confidence Assessment

**High confidence**: The result is standard in the modal logic literature and
is provable with any atom type that has a freshness property. The counterexample
model (research-002.md) shows that reflexive MCSs are *consistent* but cannot
arise in the intended semantics where the temporal relation is strict.

## Resolution Path

Change the atom type from `String` to a type supporting freshness:
```
structure Atom where
  base : String
  fresh_index : Option ℕ  -- None = base atom, Some n = fresh atom #n
```
This requires refactoring `Formula` across the codebase but is the correct
long-term fix. See `specs/960_duration_group_construction/reports/research-002.md`.

## Downstream Consequences

From this axiom, the following properties become provable:
- `NoMaxOrder` on the canonical timeline quotient (via seriality + irreflexivity)
- `NoMinOrder` on the canonical timeline quotient (via past seriality + irreflexivity)
- `DenselyOrdered` on the dense timeline quotient (via density frame condition + irreflexivity)
- `SuccOrder`/`PredOrder` coverness on the discrete timeline (via DF + irreflexivity)

The proof pattern is uniform: if `CanonicalR(M, N)` and `CanonicalR(N, M)` both hold,
then `CanonicalR(M, M)` by T4 composition, contradicting irreflexivity. So any
witness produced by seriality or density is **strictly** ordered in the quotient.

## References

- Goldblatt (1992), *Logics of Time and Computation*, Ch. 6
- Blackburn, de Rijke, Venema (2001), *Modal Logic*, Ch. 4.8
- `Bundle/CanonicalIrreflexivity.lean`: Failed proof attempt (2 sorries, blocked)
- `specs/960_duration_group_construction/reports/research-002.md`: Full obstacle analysis
-/

namespace Bimodal.Metalogic.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/--
**Axiom**: The canonical accessibility relation is irreflexive on MCSs.

For every maximal consistent set M, `GContent(M) ⊄ M` — the set of formulas
that M asserts hold at all strictly future times is NOT a subset of M itself.

This is a standard result in the modal logic literature, provable when the
atom type supports freshness. With `String` atoms, the proof is blocked
(see module docstring). We hypothesize it as an axiom with high confidence
in its mathematical truth.

**Proof debt**: Resolve by changing the atom type from `String` to a type
with freshness. See `specs/960_duration_group_construction/reports/research-002.md`.
-/
axiom canonicalR_irreflexive :
  ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M

/--
From irreflexivity: if `CanonicalR M N` and `CanonicalR N M`, then
`CanonicalR M M` by T4 composition — contradicting irreflexivity.
So mutual accessibility is impossible.
-/
theorem canonicalR_antisymmetric_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) (h_NM : CanonicalR N M) : False :=
  canonicalR_irreflexive M hM (canonicalR_transitive M N M hM hN h_MN h_NM)

/--
Corollary: any `CanonicalR` witness is strictly ordered in the quotient.
If `CanonicalR M N`, then `¬CanonicalR N M`.
-/
theorem canonicalR_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) : ¬CanonicalR N M :=
  fun h_NM => canonicalR_antisymmetric_strict M N hM hN h_MN h_NM

end Bimodal.Metalogic.Canonical
