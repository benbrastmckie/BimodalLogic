import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery

/-!
# No-Gaps Discrete Proof (Reynolds Theorem 14) and One-Class Theorem

This file provides sorry-free versions of `no_gaps_discrete` and `one_class`
by delegating to `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean).

## Import Cycle Resolution

The import cycle is:
- `GoodStructuresModelSurgery.lean` imports `GoodStructures.lean`
- `GoodStructures.lean` cannot import `GoodStructuresModelSurgery.lean`

This file resolves the cycle by sitting downstream of both:
- Imports `GoodStructuresModelSurgery.lean` (which transitively imports `GoodStructures.lean`)
- Provides `no_gaps_discrete` by delegating to `no_gaps_discrete_model_surgery`
- Provides `one_class` using `no_gaps_discrete` + `no_boundary_at_successor`

## Theorem Chain
- `no_gaps_discrete_model_surgery` (GoodStructuresModelSurgery.lean, sorry-free)
  -> `no_gaps_discrete` (this file, sorry-free)
  -> `one_class` (this file, sorry-free)

The `chronicle_is_good_direct` theorem in ShiftAndGlue.lean independently
inlines this same proof pattern for the chronicle-level application.
-/

open Bimodal.Syntax
open Bimodal.Metalogic.Core

namespace Bimodal.Metalogic.WeakCanonical

/-! ## No-Gaps Theorem (Discrete Case) -/

/--
NO GAPS THEOREM (Reynolds 1994, Theorem 14 + Lemmas 6-13):

In a discrete linear order without endpoints satisfying the Prior-UZ and
Prior-SZ axioms semantically, the contemporaneous equivalence relation ~M
has no equivalence classes that "end at gaps."

More precisely: for any two points a b : M.carrier, if a is NOT ~M-equivalent
to b, then there exists a boundary c where a ~M c but NOT a ~M (succ c).

This version delegates to `no_gaps_discrete_model_surgery` which provides
the full model surgery proof (Reynolds Lemmas 6-13). The types match because
`semantic_prior_UZ` and `semantic_prior_SZ` are abbrevs that unfold to the
expanded form used here.
-/
theorem no_gaps_discrete (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ.neg)
    (h_prior_SZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ.neg)
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) :=
  no_gaps_discrete_model_surgery sig k M atomMap h_surj h_prior_UZ h_prior_SZ a b h_diff_class

/-! ## One-Class Theorem -/

/--
ONE-CLASS THEOREM (Reynolds, Theorem 15 discrete case):
All points are contemporaneously equivalent in any discrete Prior structure
without endpoints.

The proof follows Reynolds 1994 Section 8 (page 131):
1. Suppose not (a ~M b) for some a, b.
2. By `no_gaps_discrete`, there exists c: a ~M c and not (a ~M succ c).
3. By `no_boundary_at_successor`: c ~M succ(c).
4. By transitivity of ~M: a ~M succ(c). Contradicts step 2.

NO `IsSuccArchimedean` needed. The proof uses only:
- `no_gaps_discrete` (sorry-free, delegates to `no_gaps_discrete_model_surgery`)
- `no_boundary_at_successor` (sorry-free, from GoodStructures.lean)
- `contemp_equiv_is_equiv` (sorry-free, no IsSuccArchimedean)
-/
theorem one_class (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ.neg)
    (h_prior_SZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ.neg) :
    ∀ (a b : M.carrier), contemp_equiv sig k M a b := by
  intro a b
  by_contra h_diff
  -- By no_gaps_discrete: there exists c with a ~M c but not (a ~M succ c)
  obtain ⟨c, hac, h_not_succ⟩ := no_gaps_discrete sig k M atomMap h_surj h_prior_UZ h_prior_SZ a b h_diff
  -- By no_boundary_at_successor: c ~M succ(c)
  have hc_succ : contemp_equiv sig k M c (Order.succ c) :=
    no_boundary_at_successor sig k M c
  -- By transitivity of ~M: a ~M succ(c). Contradiction.
  have hac_succ : contemp_equiv sig k M a (Order.succ c) :=
    (contemp_equiv_is_equiv sig k M).trans hac hc_succ
  exact h_not_succ hac_succ

end Bimodal.Metalogic.WeakCanonical
