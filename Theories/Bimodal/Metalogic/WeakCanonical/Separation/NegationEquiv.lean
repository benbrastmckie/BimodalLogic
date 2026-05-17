import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Duality
import Bimodal.Metalogic.WeakCanonical.Separation.IntHelpers

/-!
# Negation Equivalences (GHR94 Lemma 10.2.2)

The integer-specific negation of U and S. This is the KEY Z-dependent step
in the separation proof: it uses the well-ordering property of Z (discreteness)
to find the "first failure" point.

## Key Results

- `neg_until_equiv`: not U(A,B) <-> G(not A) v U(not A ^ not B, not A)
- `neg_since_equiv`: not S(A,B) <-> H(not A) v S(not A ^ not B, not A)

## References

- GHR94, Lemma 10.2.2, p. 572
- The proof uses discreteness of Z (well-ordering to find first failure)
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Negation of Until -/

/-- not U(A,B) <-> G(not A) v U(not A ^ not B, not A) over integer time.

    KEY: uses discreteness of Z. The proof:
    (->): If not U(A,B) at t, then either A never holds in the future (G(not A)),
      or there exists a future point where the guard B fails (before any A).
      At that first failure point, not A ^ not B holds, with not A holding between t and it.
      In integer time, "first failure" exists by well-ordering of N.
    (<-): If G(not A) then clearly not U(A,B). If U(not A ^ not B, not A), then at the
      witness s we have not A ^ not B, and not A holds between t and s, so U(A,B) fails.

    This is the main Z-dependent lemma. Over dense time (reals), this equivalence
    does NOT hold because there might be no "first" failure point. -/
theorem neg_until_equiv (A B : Formula) :
    int_equiv (Formula.neg (.untl A B))
      (Formula.or (.all_future (Formula.neg A))
        (.untl (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A))) := by
  intro M t
  constructor
  · -- (→): not U(A,B) -> G(not A) v U(not A ^ not B, not A)
    intro hnotU hnotG
    -- hnotU : (∃ s > t, A(s) ∧ B on (t,s)) → False
    -- hnotG : (∀ s > t, A(s) → False) → False
    have hexA : ∃ s, t < s ∧ int_truth M s A := by
      by_contra hall; push_neg at hall
      exact hnotG (fun s hts => hall s hts)
    haveI : DecidablePred (fun s => int_truth M s A) := Classical.decPred _
    obtain ⟨u, htu, hAu, hminA⟩ := Int.exists_least_above hexA
    have hexnotB : ∃ r, t < r ∧ r < u ∧ ¬(int_truth M r B) := by
      by_contra hall; push_neg at hall
      exact hnotU ⟨u, htu, hAu, fun r hr1 hr2 => hall r hr1 hr2⟩
    haveI : DecidablePred (fun s => ¬(int_truth M s B)) := Classical.decPred _
    have hexnotB' : ∃ r, t < r ∧ ¬(int_truth M r B) := by
      obtain ⟨r, hr1, _, hr3⟩ := hexnotB; exact ⟨r, hr1, hr3⟩
    obtain ⟨m, htm, hnotBm, hminB⟩ := Int.exists_least_above hexnotB'
    have hmu : m < u := by
      obtain ⟨r, hr1, hr2, hr3⟩ := hexnotB
      by_contra hge; push_neg at hge
      exact hminB r hr1 (by omega) hr3
    have hnotAm : ¬(int_truth M m A) := fun hAm => hminA m htm hmu hAm
    refine ⟨m, htm, ?_, ?_⟩
    · -- int_truth M m (and (neg A) (neg B)) = ¬(¬A(m) → ¬¬B(m))
      -- After intro h: h : ¬A(m) → ¬¬B(m), goal: False
      intro h
      exact h hnotAm hnotBm
    · -- ∀ r ∈ (t,m), ¬A(r)
      intro r htr hrm hAr
      exact hminA r htr (lt_trans hrm hmu) hAr
  · -- (←): G(not A) v U(not A ^ not B, not A) -> not U(A,B)
    intro hrhs huntl
    obtain ⟨u, htu, hAu, hBguard⟩ := huntl
    have hnotGnotA : (∀ s, t < s → int_truth M s A → False) → False :=
      fun h => h u htu hAu
    obtain ⟨m, htm, hnotAnotBm, hnotAguard⟩ := hrhs hnotGnotA
    -- hnotAnotBm : int_truth M m (and (neg A) (neg B)) = (¬A(m) → ¬¬B(m)) → False
    -- Extract ¬A(m): if A(m), then (¬A(m) → anything) is vacuously true, contradicting hnotAnotBm
    have hnotAm : ¬(int_truth M m A) := by
      intro hAm
      exact hnotAnotBm (fun hnotA _ => hnotA hAm)
    -- Extract ¬B(m): given ¬A(m), (¬A(m) → ¬¬B(m)) reduces to ¬¬B(m)
    have hnotBm : ¬(int_truth M m B) := by
      intro hBm
      exact hnotAnotBm (fun _ hnotB => hnotB hBm)
    -- Derive contradiction by trichotomy on m vs u
    rcases lt_trichotomy m u with hmu | hmu | hmu
    · exact hnotBm (hBguard m htm hmu)
    · exact hnotAm (hmu ▸ hAu)
    · exact hnotAguard u htu hmu hAu

/-- not S(A,B) <-> H(not A) v S(not A ^ not B, not A) over integer time.
    Dual of neg_until_equiv. -/
theorem neg_since_equiv (A B : Formula) :
    int_equiv (Formula.neg (.snce A B))
      (Formula.or (.all_past (Formula.neg A))
        (.snce (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A))) := by
  intro M t
  constructor
  · -- (→): not S(A,B) -> H(not A) v S(not A ^ not B, not A)
    intro hnotS hnotH
    have hexA : ∃ s, s < t ∧ int_truth M s A := by
      by_contra hall; push_neg at hall
      exact hnotH (fun s hst => hall s hst)
    haveI : DecidablePred (fun s => int_truth M s A) := Classical.decPred _
    obtain ⟨u, hut, hAu, hminA⟩ := Int.exists_greatest_below hexA
    -- hminA : ∀ k, u < k → k < t → ¬ int_truth M k A
    have hexnotB : ∃ r, u < r ∧ r < t ∧ ¬(int_truth M r B) := by
      by_contra hall; push_neg at hall
      exact hnotS ⟨u, hut, hAu, fun r hr1 hr2 => hall r hr1 hr2⟩
    haveI : DecidablePred (fun s => ¬(int_truth M s B)) := Classical.decPred _
    have hexnotB' : ∃ r, r < t ∧ ¬(int_truth M r B) := by
      obtain ⟨r, _, hr2, hr3⟩ := hexnotB; exact ⟨r, hr2, hr3⟩
    obtain ⟨m, hmt, hnotBm, hminB⟩ := Int.exists_greatest_below hexnotB'
    -- hminB : ∀ k, m < k → k < t → ¬¬ int_truth M k B
    have hum : u < m := by
      obtain ⟨r, hr1, hr2, hr3⟩ := hexnotB
      by_contra hge; push_neg at hge
      -- m >= r would mean r is in (m, t) but we need m < r for hminB to apply to r...
      -- Actually: m is the greatest point < t with ¬B. r is < t with ¬B. So m >= r.
      -- If m < r, then hminB r ... wouldn't apply since hminB says for k > m, ¬¬B(k).
      -- We want to show m >= some point in (u, t) with ¬B, hence m > u.
      -- hge : m <= u. Since u < r (from hexnotB), m <= u < r < t.
      -- hminB applied to r: m < r → r < t → ¬¬B(r). But we need m < r.
      -- We have m <= u < r, so m < r. Apply hminB r (by omega) hr2 to get ¬¬B(r). Contradicts hr3.
      exact (hminB r (by omega) hr2) hr3
    have hnotAm : ¬(int_truth M m A) := fun hAm => hminA m hum hmt hAm
    refine ⟨m, hmt, ?_, ?_⟩
    · intro h; exact h hnotAm hnotBm
    · intro r hmr hrt hAr; exact hminA r (lt_trans hum hmr) hrt hAr
  · -- (←): H(not A) v S(not A ^ not B, not A) -> not S(A,B)
    intro hrhs hsnce
    obtain ⟨u, hut, hAu, hBguard⟩ := hsnce
    have hnotHnotA : (∀ s, s < t → int_truth M s A → False) → False :=
      fun h => h u hut hAu
    obtain ⟨m, hmt, hnotAnotBm, hnotAguard⟩ := hrhs hnotHnotA
    -- hnotAguard : ∀ r, m < r → r < t → int_truth M r (neg A)
    have hnotAm : ¬(int_truth M m A) := by
      intro hAm; exact hnotAnotBm (fun hnotA _ => hnotA hAm)
    have hnotBm : ¬(int_truth M m B) := by
      intro hBm; exact hnotAnotBm (fun _ hnotB => hnotB hBm)
    rcases lt_trichotomy u m with hum | hum | hum
    · -- u < m: m in (u, t), so B(m) by hBguard. Contradicts ¬B(m).
      exact hnotBm (hBguard m hum hmt)
    · -- u = m: A(m) = A(u). Contradicts ¬A(m).
      exact hnotAm (hum ▸ hAu)
    · -- m < u: u in (m, t), so ¬A(u) by hnotAguard. But A(u) holds.
      exact hnotAguard u hum hut hAu

end Bimodal.Metalogic.WeakCanonical.Separation
