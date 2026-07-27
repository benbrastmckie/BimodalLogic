import FormalSystem.Metalogic.WeakCanonical.PriorExpressiveness
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import FormalSystem.Metalogic.WeakCanonical.EFGames.Defs

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Archived Dead Definitions from ReynoldsNoGaps.lean

Four definitions extracted from `ReynoldsNoGaps.lean` during BX pipeline dead
code cleanup. All had zero external references at time of removal.

## Definitions

1. `no_gaps_discrete_archimedean`: Archimedean specialization of `no_gaps_discrete`.
   The premise (not contemp_equiv) is always false in archimedean orders, so the
   conclusion holds vacuously. Zero external references.

2. `no_gaps_prior`: **Mathematically false as stated** -- missing faithfulness
   hypothesis. The Z+Z counterexample (constant predicates on two disjoint copies
   of integers) satisfies all hypotheses but has a Dedekind Gap. Superseded by
   `chronicle_no_gaps` (ChronicleNoGaps.lean) which works at the chronicle level
   where faithfulness holds by construction. Contains a sorry.

3. `prior_implies_succ_archimedean`: Derives `IsSuccArchimedean` from Prior-UZ/SZ
   hypotheses via contrapositive of `gap_of_not_succ_archimedean` + `no_gaps_prior`.
   Dead because `no_gaps_prior` is deprecated.

4. `one_class_implies_succ_archimedean`: Thin wrapper around
   `prior_implies_succ_archimedean`. Dead for the same reason.

Also removed: `orbit_le_succ_closed` (private helper, unused by any definition
including the live `gap_of_not_succ_archimedean`).

## Live Definitions (NOT archived)

The following remain in `ReynoldsNoGaps.lean`:
- `very_good_of_archimedean` (used by GoodStructuresModelSurgery.lean)
- `one_class_archimedean` (used by GoodStructuresModelSurgery.lean)
- `gap_of_not_succ_archimedean` (used by GoodStructuresModelSurgery.lean)
-/

#exit

-- ============================================================================
-- The code below is archived reference only and does not compile.
-- The #exit above prevents Lean from processing it.
-- ============================================================================

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/--
**Archimedean No-Gaps Theorem**: Specialization of `no_gaps_discrete` for
archimedean orders. The premise ¬contemp_equiv a b is always false
(by `one_class_archimedean`), so the conclusion holds vacuously.

This version does NOT require Prior-UZ/SZ. It can be used in place of
`no_gaps_discrete` wherever the underlying order is archimedean.
-/
theorem no_gaps_discrete_archimedean (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier]
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- The premise is always false: all points are contemp_equiv in archimedean orders
  exact absurd (one_class_archimedean sig k M a b) h_diff_class

/-- Helper: the successor orbit set {x : ∃ n, x ≤ succ^[n] a} is closed under
    successor: if x ∈ orbit_le, then succ(x) ∈ orbit_le. -/
private theorem orbit_le_succ_closed {T : Type} [LinearOrder T] [SuccOrder T]
    [NoMaxOrder T] (a : T) :
    ∀ x : T, (∃ n : Nat, x ≤ Order.succ^[n] a) →
      (∃ n : Nat, Order.succ x ≤ Order.succ^[n] a) := by
  intro x ⟨n, hx⟩
  rcases eq_or_lt_of_le hx with hx_eq | hx_lt
  · -- x = succ^[n] a. Then succ(x) = succ^[n+1] a.
    exact ⟨n + 1, by rw [Function.iterate_succ']; exact le_of_eq (congrArg Order.succ hx_eq)⟩
  · -- x < succ^[n] a. Then succ(x) ≤ succ^[n] a (by succ_le_of_lt).
    exact ⟨n, Order.succ_le_of_lt hx_lt⟩

/--
**DEPRECATED -- MATHEMATICALLY FALSE AS STATED**

`no_gaps_prior` is mathematically incorrect without an additional faithfulness
hypothesis. The missing hypothesis is that `temporal_truth` faithfully reflects
the monadic structure's predicate interpretation.

**Counterexample**: M.carrier = Z + Z (two disjoint copies of integers), with
M.interp p x = True for all predicates p and all points x (constant predicates).
This satisfies SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, h_surj, Prior-UZ,
and Prior-SZ (all temporal formulas evaluate to constants because predicates are
constant). But Z + Z has a Dedekind Gap between the two copies.

**Status**: OFF the critical path. The completeness pipeline uses
`chronicle_no_gaps` (ChronicleNoGaps.lean) instead, which proves the no-gaps
result specifically at the `ChronicleAsPriorModel` level where faithfulness
holds by construction (via `chronicle_temporal_truth_effective` in Transfer.lean).

The downstream theorems `prior_implies_succ_archimedean` and
`one_class_implies_succ_archimedean` remain sound -- they would work correctly
if `no_gaps_prior` were corrected with a faithfulness hypothesis.
-/
theorem no_gaps_prior (sig : MonadicSignature) (k : Nat) (hk : k ≥ 1)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap) :
    IsEmpty (Gap M.carrier) := by
  -- DEPRECATED: This theorem is mathematically false as stated.
  -- See docstring above for the Z+Z counterexample.
  -- The chronicle-level proof in ChronicleNoGaps.lean bypasses this theorem.
  sorry

/--
**Prior Implies Succ-Archimedean**: In a discrete linear order without endpoints
satisfying Prior-UZ and Prior-SZ, the order is IsSuccArchimedean.

This combines `no_gaps_prior` (no Dedekind gaps in Prior structures) with
`gap_of_not_succ_archimedean` (NOT archimedean implies gap exists).

Requires h_surj (atomMap surjective onto sig.preds) for the expressive
completeness argument in no_gaps_prior.
-/
theorem prior_implies_succ_archimedean (sig : MonadicSignature) (k : Nat) (hk : k ≥ 1)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap) :
    @IsSuccArchimedean M.carrier inferInstance (inferInstance : SuccOrder M.carrier) := by
  -- By contrapositive: if NOT archimedean, then gap exists.
  -- But no_gaps_prior says no gaps. Contradiction.
  by_contra h_not_arch
  have ⟨γ⟩ := gap_of_not_succ_archimedean h_not_arch
  exact (no_gaps_prior sig k hk M atomMap h_surj h_prior_UZ h_prior_SZ).elim γ

/--
**One-Class Implies Succ-Archimedean (revised)**: Derives IsSuccArchimedean from
Prior-UZ/SZ hypotheses. Requires h_surj for the expressive completeness argument.

This replaces the earlier version that lacked h_surj (which was mathematically
incorrect: constant-predicate structures can satisfy Prior-UZ/SZ and one_class
without being archimedean).
-/
theorem one_class_implies_succ_archimedean (sig : MonadicSignature) (k : Nat) (hk : k ≥ 1)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap) :
    @IsSuccArchimedean M.carrier inferInstance (inferInstance : SuccOrder M.carrier) :=
  prior_implies_succ_archimedean sig k hk M atomMap h_surj h_prior_UZ h_prior_SZ

end Bimodal.Metalogic.WeakCanonical
