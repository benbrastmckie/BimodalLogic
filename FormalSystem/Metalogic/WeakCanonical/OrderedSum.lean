/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.NEquivalence

/-!
# Ordered Sum Theorems for Monadic Structures

Contains the key theorems about ordered sums of monadic structures,
building on definitions from NEquivalence.lean.

## Key theorems
- `doets_lemma_1_4`: ordered sum preserves k-equivalence (via KEquivalenceFramework)

## Status
- `doets_lemma_1_4`: closed (delegates to KEquivalenceFramework.sum_preservation)
- `doets_lemma_1_5`: **re-stated in live code** as
  `RealModel/ShuffleReal.lean`'s `doets_lemma_1_5`, in Doets 1987 3.1.8's *coloured index order*
  form rather than the archived draft's type-matching form. Still unproved there, but as a
  documented strategic `sorry` with a named follow-up rather than as an archived draft.
  The archived draft in `Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean` sits behind
  `#exit`, uses the stale names `k_type_of`/`k_equiv`, and is superseded: its hypothesis
  (matching *sets* of realized k-types) does not in fact imply its conclusion, since it takes no
  account of the order in which the types occur. Do not revive it.

## References
- Doets 1989, Lemmas 1.4, 1.5: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Lemma 16 (uses Doets 1.4/1.5):
`literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
-/
namespace FormalSystem.Metalogic.WeakCanonical

/-! ## Doets Lemma 1.4 -/

/--
Doets Lemma 1.4: k-equivalence is preserved by ordered sums.

If for all i, m(i) is k-equivalent to m'(i), then the ordered sums
are k-equivalent.

**Status**: Closed. Delegates to KEquivalenceFramework.sum_preservation.
-/
theorem doets_lemma_1_4 (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) (I : Type) [LinearOrder I]
    (m m' : I → OrderedMonadicStructure sig)
    (h_equiv : ∀ i, KEquiv sig k (m i) (m' i)) :
    KEquiv sig k (orderedSum sig I m) (orderedSum sig I m') :=
  KEquivalenceFramework.sum_preservation k I m m' h_equiv

-- NOTE: `finite_structures_k_equiv_to_Z_interval` and `finite_structures_k_equiv_for_all_k`
-- were archived to FormalSystem/Boneyard/VacuousKEquiv.lean. They proved only
-- reflexivity (⟨M, rfl⟩) rather than genuine Z-interval equivalence.

end FormalSystem.Metalogic.WeakCanonical
