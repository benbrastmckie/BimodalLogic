import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Bundle.CanonicalIrreflexivity

/-!
# Theorem: Canonical Accessibility Relation is Irreflexive

## Statement

For every maximal consistent set M of the bimodal tense logic TM,
`¬CanonicalR M M` — that is, `GContent(M) ⊄ M`.

## Mathematical Status

This is now a **proven theorem** (Task 967). The proof uses the Gabbay
Irreflexivity Rule (IRR) contrapositively with the T-axiom for past
(`H(φ) → φ`), which is valid under the reflexive temporal semantics.

## Proof Strategy (Gabbay IRR with T-axiom)

1. Assume `CanonicalR(M, M)` for contradiction
2. Choose any atom `p` (freshness not required with T-axiom approach)
3. Build naming set `atomFreeSubset(M, p) ∪ {p, H(¬p)}`
4. Show naming set is consistent (via IRR contrapositive)
5. Extend to MCS `M' ⊇ naming set` via Lindenbaum
6. From naming set: `p ∈ M'` and `H(¬p) ∈ M'`
7. Apply T-axiom: `H(¬p) → ¬p`, so `¬p ∈ M'` (modus ponens)
8. Both `p` and `¬p` in M' contradicts MCS consistency

## Historical Note

The previous approach attempted to use atom freshness (Step 2 required a fresh
atom not in `atoms(GContent(M))`). This failed with `String` atoms since every
string appears in tautologies. The resolution (Task 967) adopted reflexive
temporal semantics, making the T-axiom valid, which provides an alternative
path through Step 7 that does not require freshness.

## Downstream Consequences

From this theorem, the following properties are provable:
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
- `Bundle/CanonicalIrreflexivity.lean`: Complete proof using T-axiom
- `specs/967_change_atom_type_for_freshness/reports/research-002.md`: T-axiom analysis
-/

namespace Bimodal.Metalogic.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/--
**Theorem**: The canonical accessibility relation is irreflexive on MCSs.

For every maximal consistent set M, `GContent(M) ⊄ M` — the set of formulas
that M asserts hold at all reflexive-future times is NOT a subset of M itself.

The proof uses the Gabbay Irreflexivity Rule with the T-axiom for past
(`H(φ) → φ`), which is valid under reflexive temporal semantics.

**Resolved (Task 967)**: This was previously an axiom due to String atom
freshness issues. Now proven via T-axiom approach with reflexive semantics.
-/
theorem canonicalR_irreflexive :
  ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M :=
  Bimodal.Metalogic.Bundle.canonicalR_irreflexive

/--
From irreflexivity: if `CanonicalR M N` and `CanonicalR N M`, then
`CanonicalR M M` by T4 composition — contradicting irreflexivity.
So mutual accessibility is impossible.
-/
theorem canonicalR_antisymmetric_strict
    (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) (h_NM : CanonicalR N M) : False :=
  canonicalR_irreflexive M hM (canonicalR_transitive M N M hM h_MN h_NM)

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
