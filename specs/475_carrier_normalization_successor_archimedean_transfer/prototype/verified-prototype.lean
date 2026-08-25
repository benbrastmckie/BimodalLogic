import FormalSystem.Semantics.Validity
import Mathlib.Algebra.Order.Hom.Monoid
import Mathlib.GroupTheory.ArchimedeanDensely
import Mathlib.Order.SuccPred.Archimedean
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred

namespace Probe

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [Nontrivial D]

/-- The successor of `0` is the least strictly positive element. -/
theorem isLeast_pos_succ_zero :
    IsLeast {y : D | 0 < y} (Order.succ (0 : D)) :=
  ⟨Order.lt_succ (0 : D), fun _ hy => Order.succ_le_of_lt hy⟩

/-- In an ordered group with a successor structure, `succ` is translation by `succ 0`. -/
theorem succ_eq_add_succ_zero (z : D) : Order.succ z = z + Order.succ (0 : D) := by
  have hu : (0 : D) < Order.succ (0 : D) := Order.lt_succ (0 : D)
  refine le_antisymm ?_ ?_
  · exact Order.succ_le_of_lt (lt_add_of_pos_right z hu)
  · have h1 : (0 : D) < Order.succ z - z := sub_pos.mpr (Order.lt_succ z)
    have h2 : Order.succ (0 : D) ≤ Order.succ z - z :=
      (isLeast_pos_succ_zero (D := D)).2 h1
    rw [le_sub_iff_add_le, add_comm] at h2
    exact h2

theorem succ_iterate_zero (n : ℕ) :
    (Order.succ)^[n] (0 : D) = n • Order.succ (0 : D) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih, succ_eq_add_succ_zero, succ_nsmul]

/-- **Successor-Archimedean forces additively Archimedean.** -/
theorem archimedean_of_succ [IsSuccArchimedean D] : Archimedean D := by
  refine ⟨fun x y hy => ?_⟩
  rcases le_or_gt x 0 with hx | hx
  · exact ⟨0, by simpa using hx⟩
  · obtain ⟨n, hn⟩ := exists_succ_iterate_of_le (le_of_lt hx)
    refine ⟨n, ?_⟩
    rw [← hn, succ_iterate_zero]
    exact nsmul_le_nsmul_right ((isLeast_pos_succ_zero (D := D)).2 hy) n

/-- The full transfer. -/
noncomputable def intIso [IsSuccArchimedean D] : D ≃+o ℤ :=
  letI : Archimedean D := archimedean_of_succ
  LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos
    (isLeast_pos_succ_zero (D := D))

end Probe



namespace Probe
open FormalSystem.Semantics

variable {D E : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [AddCommGroup E] [LinearOrder E] [IsOrderedAddMonoid E] [Nontrivial E]

/-- Transport a task frame along an ordered-group isomorphism of duration types. -/
def TaskFrame.map (F : TaskFrame D) (e : D ≃+o E) : TaskFrame E where
  WorldState := F.WorldState
  nonempty := F.nonempty
  TaskRel := fun w d u => F.TaskRel w (e.symm d) u
  nullity_identity := by
    intro w u
    simpa using F.nullity_identity w u
  comp := by
    intro w v x y hx hy
    have hx' : (0 : D) ≤ e.symm x := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
    have hy' : (0 : D) ≤ e.symm y := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
    have := F.comp w v (e.symm x) (e.symm y) hx' hy'
    simpa [map_add] using this
  converse := by
    intro w d u
    simpa [map_neg] using F.converse w (e.symm d) u
  serial := by
    intro w x hx
    have hx' : (0 : D) ≤ e.symm x := by
      simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
    exact F.serial w (e.symm x) hx'
  limit := by
    intro w u h
    refine F.limit w u ?_
    intro x hx
    obtain ⟨n, hn, hR⟩ := h (e x) (by simpa using (map_lt_map_iff e (a := 0) (b := x)).mpr hx)
    refine ⟨e.symm n, ?_, hR⟩
    have : |e.symm n| = e.symm |n| := (map_abs e.symm n).symm
    rw [this]
    have := (map_lt_map_iff e.symm (a := |n|) (b := e x)).mpr hn
    simpa using this
  spherical := by
    intro S hS hmem
    refine F.spherical S hS ?_
    intro s hs
    obtain ⟨hfs, hne⟩ := hmem s hs
    refine ⟨?_, hne⟩
    rcases hfs with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · exact Or.inl ⟨w, e.symm x, rfl⟩
    · refine Or.inr ⟨w, v, e.symm x, e.symm y, ?_, ?_, ?_⟩
      · simpa using (map_le_map_iff e.symm (a := 0) (b := x)).mpr hx
      · simpa using (map_le_map_iff e.symm (a := 0) (b := y)).mpr hy
      · simp [TaskFrame.Seg, TaskFrame.Fib, map_neg]

end Probe

namespace Probe
open FormalSystem.Semantics FormalSystem.Syntax

variable {D E : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [AddCommGroup E] [LinearOrder E] [IsOrderedAddMonoid E] [Nontrivial E]

def TaskModel.map {F : TaskFrame D} (M : TaskModel F) (e : D ≃+o E) :
    TaskModel (TaskFrame.map F e) where
  valuation := M.valuation

def WorldHistory.map {F : TaskFrame D} (τ : WorldHistory F) (e : D ≃+o E) :
    WorldHistory (TaskFrame.map F e) where
  domain := fun n => τ.domain (e.symm n)
  nonempty_domain := by
    obtain ⟨t, ht⟩ := τ.nonempty_domain
    exact ⟨e t, by simpa using ht⟩
  states := fun n h => τ.states (e.symm n) h
  respects_task := by
    intro s t hs ht
    have := τ.respects_task (e.symm s) (e.symm t) hs ht
    show F.TaskRel _ (e.symm (t - s)) _
    simpa [map_sub] using this
  convex := by
    intro x z hx hz y hxy hyz
    exact τ.convex (e.symm x) (e.symm z) hx hz (e.symm y)
      ((map_le_map_iff e.symm).mpr hxy) ((map_le_map_iff e.symm).mpr hyz)

/-- Two histories over corresponding frames agree pointwise under `e`. -/
structure Aligned {F : TaskFrame D} (e : D ≃+o E)
    (σ : WorldHistory F) (σ' : WorldHistory (TaskFrame.map F e)) : Prop where
  dom : ∀ n, σ'.domain n ↔ σ.domain (e.symm n)
  st : ∀ (n : E) (h' : σ'.domain n) (h : σ.domain (e.symm n)),
        σ'.states n h' = σ.states (e.symm n) h

theorem aligned_map {F : TaskFrame D} (e : D ≃+o E) (τ : WorldHistory F) :
    Aligned e τ (WorldHistory.map τ e) :=
  ⟨fun _ => Iff.rfl, fun _ _ _ => rfl⟩

theorem isTotal_map {F : TaskFrame D} (e : D ≃+o E) {σ : WorldHistory F}
    {σ' : WorldHistory (TaskFrame.map F e)} (ha : Aligned e σ σ') (h : σ.IsTotal) :
    σ'.IsTotal := fun n => (ha.dom n).mpr (h _)

end Probe

namespace Probe
open FormalSystem.Semantics FormalSystem.Syntax

variable {D E : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [AddCommGroup E] [LinearOrder E] [IsOrderedAddMonoid E] [Nontrivial E]

/-- Pull a history back along `e` from the transported frame to the original. -/
def WorldHistory.comap {F : TaskFrame D} (e : D ≃+o E)
    (σ' : WorldHistory (TaskFrame.map F e)) : WorldHistory F where
  domain := fun t => σ'.domain (e t)
  nonempty_domain := by
    obtain ⟨n, hn⟩ := σ'.nonempty_domain
    exact ⟨e.symm n, by simpa using hn⟩
  states := fun t h => σ'.states (e t) h
  respects_task := by
    intro s t hs ht
    have := σ'.respects_task (e s) (e t) hs ht
    have h2 : (TaskFrame.map F e).TaskRel (σ'.states (e s) hs) (e t - e s) (σ'.states (e t) ht) :=
      this
    show F.TaskRel _ (t - s) _
    have : e.symm (e t - e s) = t - s := by simp [map_sub]
    simpa [TaskFrame.map, this] using h2
  convex := by
    intro x z hx hz y hxy hyz
    exact σ'.convex (e x) (e z) hx hz (e y)
      ((map_le_map_iff e).mpr hxy) ((map_le_map_iff e).mpr hyz)

theorem aligned_comap {F : TaskFrame D} (e : D ≃+o E)
    (σ' : WorldHistory (TaskFrame.map F e)) : Aligned e (WorldHistory.comap e σ') σ' := by
  constructor
  · intro n
    show σ'.domain n ↔ σ'.domain (e (e.symm n))
    simp
  · intro n h' h
    show σ'.states n h' = σ'.states (e (e.symm n)) h
    exact WorldHistory.states_eq_of_time_eq σ' n (e (e.symm n)) (by simp) h' h

end Probe

namespace Probe
open FormalSystem.Semantics FormalSystem.Syntax

variable {D E : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [AddCommGroup E] [LinearOrder E] [IsOrderedAddMonoid E] [Nontrivial E]

theorem truthAt_map {F : TaskFrame D} (e : D ≃+o E) (M : TaskModel F) (φ : Formula) :
    ∀ (σ : WorldHistory F) (σ' : WorldHistory (TaskFrame.map F e)), Aligned e σ σ' →
      ∀ t : D, (TruthAt M σ t φ ↔ TruthAt (TaskModel.map M e) σ' (e t) φ) := by
  induction φ with
  | atom p =>
    intro σ σ' ha t
    constructor
    · rintro ⟨ht, hv⟩
      have ht' : σ'.domain (e t) := (ha.dom (e t)).mpr (by simpa using ht)
      refine ⟨ht', ?_⟩
      have := ha.st (e t) ht' (by simpa using ht)
      show (TaskModel.map M e).valuation (σ'.states (e t) ht') p
      rw [this]
      show M.valuation (σ.states (e.symm (e t)) _) p
      rw [σ.states_eq_of_time_eq (e.symm (e t)) t (by simp) _ ht]
      exact hv
    · rintro ⟨ht', hv⟩
      have ht : σ.domain t := by
        have := (ha.dom (e t)).mp ht'
        simpa using this
      refine ⟨ht, ?_⟩
      have heq := ha.st (e t) ht' (by simpa using ht)
      rw [heq] at hv
      rw [σ.states_eq_of_time_eq (e.symm (e t)) t (by simp) _ ht] at hv
      exact hv
  | bot => intro σ σ' ha t; exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
    intro σ σ' ha t
    exact imp_congr (ihψ σ σ' ha t) (ihχ σ σ' ha t)
  | box ψ ih =>
    intro σ σ' ha t
    constructor
    · intro h ρ' hρ'
      exact (ih (WorldHistory.comap e ρ') ρ' (aligned_comap e ρ') t).mp
        (h _ (fun s => hρ' (e s)))
    · intro h ρ hρ
      exact (ih ρ (WorldHistory.map ρ e) (aligned_map e ρ) t).mpr
        (h _ (isTotal_map e (aligned_map e ρ) hρ))
  | untl ψ χ ihψ ihχ =>
    intro σ σ' ha t
    constructor
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e s, (map_lt_map_iff e).mpr hts, (ihχ σ σ' ha s).mp hχ, ?_⟩
      intro r htr hrs
      have hr : t < e.symm r := by simpa using (map_lt_map_iff e.symm).mpr htr
      have hr2 : e.symm r < s := by simpa using (map_lt_map_iff e.symm).mpr hrs
      have := (ihψ σ σ' ha (e.symm r)).mp (hψ _ hr hr2)
      simpa using this
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e.symm s, ?_, ?_, ?_⟩
      · simpa using (map_lt_map_iff e.symm).mpr hts
      · refine (ihχ σ σ' ha (e.symm s)).mpr ?_; simpa using hχ
      · intro r htr hrs
        refine (ihψ σ σ' ha r).mpr (hψ (e r) ((map_lt_map_iff e).mpr htr) ?_)
        simpa using (map_lt_map_iff e).mpr hrs
  | snce ψ χ ihψ ihχ =>
    intro σ σ' ha t
    constructor
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e s, (map_lt_map_iff e).mpr hts, (ihχ σ σ' ha s).mp hχ, ?_⟩
      intro r hsr hrt
      have hr : s < e.symm r := by simpa using (map_lt_map_iff e.symm).mpr hsr
      have hr2 : e.symm r < t := by simpa using (map_lt_map_iff e.symm).mpr hrt
      have := (ihψ σ σ' ha (e.symm r)).mp (hψ _ hr hr2)
      simpa using this
    · rintro ⟨s, hts, hχ, hψ⟩
      refine ⟨e.symm s, ?_, ?_, ?_⟩
      · simpa using (map_lt_map_iff e.symm).mpr hts
      · refine (ihχ σ σ' ha (e.symm s)).mpr ?_; simpa using hχ
      · intro r hsr hrt
        refine (ihψ σ σ' ha r).mpr (hψ (e r) ?_ ((map_lt_map_iff e).mpr hrt))
        simpa using (map_lt_map_iff e).mpr hsr

end Probe

namespace Probe
open FormalSystem.Semantics FormalSystem.Syntax

def ValidInt (φ : Formula) : Prop :=
  ∀ (F : TaskFrame ℤ) (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal) (t : ℤ),
    TruthAt M τ t φ

theorem validDiscrete_iff_validInt (φ : Formula) : ValidDiscrete φ ↔ ValidInt φ := by
  constructor
  · intro h F M τ hτ t
    exact h ℤ F M τ hτ t
  · intro h D _ _ _ _ _ _ _ _ F M τ hτ t
    let e : D ≃+o ℤ := intIso
    refine (truthAt_map e M φ τ (WorldHistory.map τ e) (aligned_map e τ) t).mpr ?_
    exact h (TaskFrame.map F e) (TaskModel.map M e) (WorldHistory.map τ e)
      (isTotal_map e (aligned_map e τ) hτ) (e t)

end Probe

#print axioms Probe.validDiscrete_iff_validInt
