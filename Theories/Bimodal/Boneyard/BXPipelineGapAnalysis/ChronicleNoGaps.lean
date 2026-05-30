import Bimodal.Metalogic.WeakCanonical.PriorExpressiveness
import Bimodal.Metalogic.WeakCanonical.EFGames.Defs
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel

#exit  -- Boneyard: archived by task 225 (BX pipeline dead code)

/-!
# Chronicle-Level No-Gaps Proof (Reynolds Theorem 14 at Chronicle Level)

This file provides the architectural foundation for proving that the chronicle's
`LimitDomSubtype` has no Dedekind gaps, thereby establishing `IsSuccArchimedean`
and closing the `succ_cofinal` sorry in ChronicleToCountermodel.lean.

## Background

The abstract `no_gaps_prior` (ReynoldsNoGaps.lean) is mathematically false without
a faithfulness hypothesis. The Z+Z counterexample with constant predicates satisfies
all hypotheses but has a Dedekind gap.

The chronicle construction HAS built-in faithfulness: `chronicle_temporal_truth_effective`
(Transfer.lean) shows that temporal truth on the chronicle monadic structure corresponds
to MCS membership of the effective formula. This makes Reynolds' gap-elimination
argument go through at the chronicle level.

## Proof Strategy (Plan v11, Path B)

The argument proceeds by contradiction. Assuming the domain is NOT IsSuccArchimedean:

1. **Gap construction**: By `gap_of_not_succ_archimedean_local`, a Dedekind Gap exists.
   The cut C = {x : ∃ n, x ≤ succ^[n](a)} is successor-closed with no max;
   the complement has no min.

2. **Distinguishing formula**: Build an `OrderedMonadicStructure` on `LimitDomSubtype`
   with the cut predicate as a monadic predicate. Use `US_expressively_complete_over_prior`
   to obtain a temporal formula R equivalent to "in C" on this structure.

3. **Prior-SZ contradiction**: For any s in the complement:
   - P(R) holds at s (past R-points in C)
   - Prior-SZ gives S(R, ¬R): last R-point s' < s with ¬R on (s', s)
   - s' ∈ C, so succ(s') ∈ C (succ-closed) and succ(s') ∈ (s', s)
   - R holds at succ(s') (since succ(s') ∈ C), contradicting ¬R on (s', s)

## Open Problem

Step 2 requires proving semantic Prior-UZ/SZ for the OrderedMonadicStructure where
the predicate is "in C" (NOT the MCS interpretation). This is the core mathematical
difficulty, requiring either:

(a) Showing the cut IS expressible via MCS membership (omega-chain analysis), or
(b) Full Reynolds model surgery (Lemmas 6-13) adapted to the chronicle level, or
(c) Using the faithfulness bridge to transfer between the MCS-based and cut-based
    structures.

## Status

The `chronicle_gap_contradiction` sorry in ChronicleToCountermodel.lean captures the
core mathematical content. Once this module provides a sorry-free proof, downstream
consumers (ChronicleExtraction, Transfer, Completeness) become sorry-free automatically
since `limitDomSubtype_isSuccArchimedean` derives from `succ_cofinal` which derives from
`chronicle_gap_contradiction`.

## References

- Reynolds 1994, Theorem 14 (gap elimination via model surgery, pp.124-129)
- Reynolds 1994, Theorem 5 (US expressive completeness, pp.123-124)
- Plan v11: specs/202_reynolds_k_equivalence_bypass/plans/10_chronicle-level-plan.md
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.Metalogic.BXCanonical.Chronicle

/-! ## Gap Existence from Non-Archimedean (Local Copy)

This is a local copy of `gap_of_not_succ_archimedean` from ReynoldsNoGaps.lean,
reproduced here to avoid circular imports (ReynoldsNoGaps -> GoodStructures ->
OrderedSum -> NEquivalence -> ChronicleExtraction -> ChronicleToCountermodel).

The `Gap` structure and `gap_cut_succ_closed`/`gap_complement_pred_closed` are
imported from EFGames.Defs (no circular dependency).
-/

/--
If a discrete linear order without endpoints is NOT IsSuccArchimedean,
there exists a Dedekind Gap. Local copy to avoid import cycle with
ReynoldsNoGaps.lean.
-/
theorem gap_of_not_succ_archimedean_local {T : Type} [LinearOrder T]
    [SuccOrder T] [PredOrder T] [NoMaxOrder T] [NoMinOrder T]
    (h_not_arch : ¬ @IsSuccArchimedean T inferInstance inferInstance) :
    Nonempty (Gap T) := by
  have h_exists : ∃ a b : T, a ≤ b ∧ ∀ n : Nat, Order.succ^[n] a ≠ b := by
    by_contra h_all
    push_neg at h_all
    exact h_not_arch ⟨fun {a b} hab => h_all a b hab⟩
  obtain ⟨a, b, hab, h_unreach⟩ := h_exists
  have h_lt : ∀ n : Nat, Order.succ^[n] a < b := by
    intro n
    induction n with
    | zero => simp; exact lt_of_le_of_ne hab (h_unreach 0)
    | succ n ih =>
      have h_le : Order.succ^[n + 1] a ≤ b := by
        rw [Function.iterate_succ']
        exact Order.succ_le_of_lt ih
      exact lt_of_le_of_ne h_le (h_unreach (n + 1))
  let cut : Set T := {x | ∃ n : Nat, x ≤ Order.succ^[n] a}
  refine ⟨⟨cut, ?_, ?_, ?_, ?_, ?_⟩⟩
  · exact ⟨a, 0, le_refl a⟩
  · intro h_all
    have hb : b ∈ cut := h_all ▸ Set.mem_univ b
    obtain ⟨n, hn⟩ := hb
    exact not_le.mpr (h_lt n) hn
  · intro x y ⟨n, hx⟩ hyx
    exact ⟨n, le_trans hyx hx⟩
  · intro ⟨s, h_lub, hs⟩
    obtain ⟨n, hsn⟩ := hs
    have h_succ_in : Order.succ s ∈ cut :=
      ⟨n + 1, by rw [Function.iterate_succ']; exact Order.succ_le_succ hsn⟩
    have h_succ_gt : s < Order.succ s := Order.lt_succ_of_not_isMax (not_isMax s)
    exact not_le.mpr h_succ_gt (h_lub.1 h_succ_in)
  · intro ⟨m, hm_not, hm_min⟩
    have hm_above : ∀ n : Nat, Order.succ^[n] a < m := by
      intro n
      by_contra h
      push_neg at h
      exact hm_not ⟨n, h⟩
    have h_not_min : ¬ IsMin m := by
      intro h_min
      exact not_isMin_of_lt (hm_above 0) h_min
    have h_succ_pred : Order.succ (Order.pred m) = m :=
      Order.succ_pred_of_not_isMin h_not_min
    have h_pred_in : Order.pred m ∈ cut := by
      by_contra h_pred_not
      exact not_le.mpr (Order.pred_lt_of_not_isMin h_not_min)
        (hm_min (Order.pred m) h_pred_not)
    obtain ⟨n, hn⟩ := h_pred_in
    have : m ≤ Order.succ^[n + 1] a := by
      rw [← h_succ_pred, Function.iterate_succ']
      exact Order.succ_le_succ hn
    exact not_le.mpr (hm_above (n + 1)) this

/-! ## Cut-Complement Boundary Properties

Additional properties of the gap boundary needed for the Prior-SZ
contradiction argument. The base properties `gap_cut_succ_closed` and
`gap_complement_pred_closed` are from EFGames.Defs.
-/

/-- Every element of the cut is strictly below every element of the complement.
    Follows from downward-closure of the cut. -/
theorem gap_cut_lt_complement {T : Type} [LinearOrder T]
    (γ : Gap T) (t : T) (ht : t ∈ γ.cut) (s : T) (hs : s ∉ γ.cut) :
    t < s := by
  rcases lt_or_ge t s with h | h
  · exact h
  · exact absurd (γ.downward_closed t s ht h) hs

/-- succ(t) is strictly below s for any t in cut and s in complement.
    Combines gap_cut_succ_closed with gap_cut_lt_complement. -/
theorem gap_succ_cut_lt_complement {T : Type} [LinearOrder T] [SuccOrder T]
    [NoMaxOrder T]
    (γ : Gap T) (t : T) (ht : t ∈ γ.cut) (s : T) (hs : s ∉ γ.cut) :
    Order.succ t < s :=
  gap_cut_lt_complement γ (Order.succ t) (gap_cut_succ_closed γ t ht) s hs

end Bimodal.Metalogic.WeakCanonical
