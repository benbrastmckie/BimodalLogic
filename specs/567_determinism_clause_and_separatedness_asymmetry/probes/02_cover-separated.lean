import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Ray
import FormalSystem.Semantics.Extension.Extension

namespace Probe567b
open FormalSystem FormalSystem.Semantics FormalSystem.Semantics.Presheaf
variable {F : TaskFrame}

/-- Cover-relative separatedness of `Beh F` for the Johnstone coverage, at NO frame hypothesis:
two sections agreeing on both halves of a cut agree. -/
theorem cover_separated {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l) (σ τ : Beh F l)
    (h1 : Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) σ
        = Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) τ)
    (h2 : Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) σ
        = Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) τ) :
    σ = τ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z; exact propext ((σ.property z).trans (τ.property z).symm)
  · intro r hr hr'
    obtain ⟨hr0, hrl⟩ := (σ.property r).mp hr
    rcases le_total r p with hrp | hpr
    · have hd : (Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) σ).val.domain r :=
        ⟨hr0, hrp⟩
      have hd' : (Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) τ).val.domain r :=
        ⟨hr0, hrp⟩
      have h0r : (0 : F.Duration) ≤ 0 + r := by rw [zero_add]; exact hr0
      have hrl0 : (0 : F.Duration) + r ≤ l := by rw [zero_add]; exact hrl
      have hx := states_eq_of_eq h1 r hd hd'
      rw [Beh.restrict_states 0 p le_rfl hp _ σ r hd (Beh.mem_dom σ h0r hrl0),
          Beh.restrict_states 0 p le_rfl hp _ τ r hd' (Beh.mem_dom τ h0r hrl0)] at hx
      rw [PartialHistory.states_eq_of_time_eq σ.val r (0 + r) (zero_add r).symm hr
            (Beh.mem_dom σ h0r hrl0),
          PartialHistory.states_eq_of_time_eq τ.val r (0 + r) (zero_add r).symm hr'
            (Beh.mem_dom τ h0r hrl0)]
      exact hx
    · have hsub : (0 : F.Duration) ≤ r - p := sub_nonneg.mpr hpr
      have hsubl : r - p ≤ l - p := by
        exact sub_le_sub_right hrl p
      have hd : (Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) σ).val.domain (r - p) := ⟨hsub, hsubl⟩
      have hd' : (Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) τ).val.domain (r - p) := ⟨hsub, hsubl⟩
      have heq : p + (r - p) = r := by rw [add_sub_cancel]
      have hpd : (0 : F.Duration) ≤ p + (r - p) := by rw [heq]; exact hr0
      have hpdl : p + (r - p) ≤ l := by rw [heq]; exact hrl
      have hx := states_eq_of_eq h2 (r - p) hd hd'
      rw [Beh.restrict_states p (l - p) hp _ _ σ (r - p) hd (Beh.mem_dom σ hpd hpdl),
          Beh.restrict_states p (l - p) hp _ _ τ (r - p) hd' (Beh.mem_dom τ hpd hpdl)] at hx
      rw [PartialHistory.states_eq_of_time_eq σ.val r (p + (r - p)) heq.symm hr
            (Beh.mem_dom σ hpd hpdl),
          PartialHistory.states_eq_of_time_eq τ.val r (p + (r - p)) heq.symm hr'
            (Beh.mem_dom τ hpd hpdl)]
      exact hx

end Probe567b

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
#print axioms Probe567b.cover_separated
